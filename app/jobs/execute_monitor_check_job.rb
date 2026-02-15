class ExecuteMonitorCheckJob < ApplicationJob
  queue_as :monitoring

  discard_on ActiveRecord::RecordNotFound

  def perform(site_monitor_id)
    monitor = SiteMonitor.find(site_monitor_id)
    return unless monitor.is_active?

    result = MonitoringService.new(monitor).execute

    check = monitor.checks.create!(
      status_code: result.status_code,
      response_time_ms: result.response_time_ms,
      successful: result.success,
      error_message: result.error_message,
      headers: result.headers || {}
    )

    monitor.update!(last_checked_at: Time.current)

    IncidentManager.new.process_check_result(check)
  end
end
