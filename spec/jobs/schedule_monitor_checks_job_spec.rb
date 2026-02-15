require "rails_helper"

RSpec.describe ScheduleMonitorChecksJob do
  describe "#perform" do
    context "when a monitor has never been checked" do
      let!(:monitor) { create(:site_monitor, last_checked_at: nil) }

      it "enqueues a check job" do
        expect { described_class.perform_now }
          .to have_enqueued_job(ExecuteMonitorCheckJob).with(monitor.id)
      end
    end

    context "when a monitor is due for a check" do
      let!(:monitor) { create(:site_monitor, check_interval_seconds: 300, last_checked_at: 10.minutes.ago) }

      it "enqueues a check job" do
        expect { described_class.perform_now }
          .to have_enqueued_job(ExecuteMonitorCheckJob).with(monitor.id)
      end
    end

    context "when a monitor was recently checked" do
      let!(:monitor) { create(:site_monitor, check_interval_seconds: 300, last_checked_at: 1.minute.ago) }

      it "does not enqueue a check job" do
        expect { described_class.perform_now }
          .not_to have_enqueued_job(ExecuteMonitorCheckJob)
      end
    end

    context "when a monitor is inactive" do
      let!(:monitor) { create(:site_monitor, :inactive, last_checked_at: nil) }

      it "does not enqueue a check job" do
        expect { described_class.perform_now }
          .not_to have_enqueued_job(ExecuteMonitorCheckJob)
      end
    end
  end

  describe ".build_schedule" do
    it "returns a valid Sidekiq-Cron schedule hash" do
      schedule = described_class.build_schedule

      expect(schedule).to have_key("schedule_monitor_checks")
      expect(schedule["schedule_monitor_checks"]["cron"]).to eq("* * * * *")
      expect(schedule["schedule_monitor_checks"]["class"]).to eq("ScheduleMonitorChecksJob")
    end
  end
end
