require "rails_helper"

RSpec.describe IncidentManager do
  let(:monitor) { create(:site_monitor, :up) }
  let(:manager) { described_class.new }

  describe "#process_check_result" do
    context "when fewer than 3 consecutive failures" do
      before do
        create(:check, :successful, site_monitor: monitor, created_at: 3.minutes.ago)
        create(:check, :failed, site_monitor: monitor, created_at: 2.minutes.ago)
      end

      it "does not create an incident" do
        check = create(:check, :failed, site_monitor: monitor)

        expect { manager.process_check_result(check) }
          .not_to change(Incident, :count)
      end
    end

    context "when 3 consecutive failures occur" do
      before do
        create(:check, :successful, site_monitor: monitor, created_at: 5.minutes.ago)
        create(:check, :failed, site_monitor: monitor, created_at: 3.minutes.ago)
        create(:check, :failed, site_monitor: monitor, created_at: 2.minutes.ago)
      end

      it "creates an incident" do
        check = create(:check, :failed, site_monitor: monitor)

        expect { manager.process_check_result(check) }
          .to change(Incident, :count).by(1)

        incident = Incident.last
        expect(incident.title).to include(monitor.name)
        expect(incident.severity).to eq("minor")
        expect(incident.status).to eq("investigating")
        expect(incident.site_monitors).to include(monitor)
      end

      it "sets the monitor status to down" do
        check = create(:check, :failed, site_monitor: monitor)
        manager.process_check_result(check)

        expect(monitor.reload.current_status).to eq("down")
      end

      it "enqueues a notification job" do
        check = create(:check, :failed, site_monitor: monitor)

        expect { manager.process_check_result(check) }
          .to have_enqueued_job(SendNotificationJob).with("incident_created", anything)
      end
    end

    context "when an active incident already exists" do
      before do
        create(:check, :failed, site_monitor: monitor, created_at: 4.minutes.ago)
        create(:check, :failed, site_monitor: monitor, created_at: 3.minutes.ago)
        create(:check, :failed, site_monitor: monitor, created_at: 2.minutes.ago)

        incident = create(:incident, :investigating, :minor)
        incident.site_monitors << monitor
        monitor.update!(current_status: :down)
      end

      it "does not create a duplicate incident" do
        check = create(:check, :failed, site_monitor: monitor)

        expect { manager.process_check_result(check) }
          .not_to change(Incident, :count)
      end
    end

    context "when recovery occurs" do
      let(:monitor) { create(:site_monitor, :down) }

      before do
        incident = create(:incident, :investigating, :minor)
        incident.site_monitors << monitor
      end

      it "resolves the active incident" do
        check = create(:check, :successful, site_monitor: monitor)
        manager.process_check_result(check)

        incident = Incident.last
        expect(incident.status).to eq("resolved")
        expect(incident.resolved_at).not_to be_nil
      end

      it "sets the monitor status to up" do
        check = create(:check, :successful, site_monitor: monitor)
        manager.process_check_result(check)

        expect(monitor.reload.current_status).to eq("up")
      end

      it "enqueues a notification job for resolution" do
        check = create(:check, :successful, site_monitor: monitor)

        expect { manager.process_check_result(check) }
          .to have_enqueued_job(SendNotificationJob).with("incident_resolved", anything)
      end
    end
  end
end
