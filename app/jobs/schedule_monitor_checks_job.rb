class ScheduleMonitorChecksJob < ApplicationJob
  queue_as :critical

  def perform
    SiteMonitor.active.find_each do |monitor|
      next unless check_due?(monitor)

      ExecuteMonitorCheckJob.perform_later(monitor.id)
    end
  end

  def self.build_schedule
    {
      "schedule_monitor_checks" => {
        "cron" => "* * * * *",
        "class" => "ScheduleMonitorChecksJob",
        "queue" => "critical",
        "description" => "Dispatches monitor checks every minute"
      }
    }
  end

  private

  def check_due?(monitor)
    monitor.last_checked_at.nil? ||
      monitor.last_checked_at <= monitor.check_interval_seconds.seconds.ago
  end
end
