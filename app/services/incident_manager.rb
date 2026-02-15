class IncidentManager
  CONSECUTIVE_FAILURES_THRESHOLD = 3

  def process_check_result(check)
    monitor = check.site_monitor

    if check.successful?
      handle_recovery(monitor) if monitor.down? || monitor.degraded?
    else
      handle_failure(monitor)
    end
  end

  private

  def handle_failure(monitor)
    consecutive_failures = count_consecutive_failures(monitor)

    if consecutive_failures >= CONSECUTIVE_FAILURES_THRESHOLD
      monitor.update!(current_status: :down) unless monitor.down?
      create_or_escalate_incident(monitor, consecutive_failures)
    end
  end

  def handle_recovery(monitor)
    active_incidents = monitor.incidents.active

    active_incidents.each do |incident|
      incident.resolve!
      incident.incident_updates.create!(
        message: "Monitor #{monitor.name} has recovered.",
        status: :resolved
      )
      SendNotificationJob.perform_later("incident_resolved", incident.id)
    end

    monitor.update!(current_status: :up)
  end

  def count_consecutive_failures(monitor)
    Check.unscoped
      .where(monitor_id: monitor.id)
      .order(created_at: :desc)
      .each_with_object([]) do |check, failures|
        break failures if check.successful?
        failures << check
      end
      .size
  end

  def create_or_escalate_incident(monitor, consecutive_failures)
    existing = monitor.incidents.active.first

    if existing
      escalate_incident(existing, consecutive_failures)
    else
      create_incident(monitor, consecutive_failures)
    end
  end

  def create_incident(monitor, consecutive_failures)
    severity = determine_severity(consecutive_failures)

    incident = Incident.create!(
      title: "#{monitor.name} is down",
      status: :investigating,
      severity: severity
    )
    incident.site_monitors << monitor

    incident.incident_updates.create!(
      message: "Monitor #{monitor.name} has failed #{consecutive_failures} consecutive checks.",
      status: :investigating
    )

    SendNotificationJob.perform_later("incident_created", incident.id)

    incident
  end

  def escalate_incident(incident, consecutive_failures)
    new_severity = determine_severity(consecutive_failures)

    if Incident.severities[new_severity] > Incident.severities[incident.severity]
      incident.update!(severity: new_severity)
      incident.incident_updates.create!(
        message: "Incident escalated to #{new_severity}. #{consecutive_failures} consecutive failures.",
        status: incident.status
      )
    end
  end

  def determine_severity(consecutive_failures)
    case consecutive_failures
    when 3..5 then :minor
    when 6..10 then :major
    else :critical
    end
  end
end
