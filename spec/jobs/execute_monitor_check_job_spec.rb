require "rails_helper"

RSpec.describe ExecuteMonitorCheckJob do
  let(:monitor) { create(:site_monitor, url: "https://example.com") }

  before do
    stub_request(:get, "https://example.com")
      .to_return(status: 200, body: "OK", headers: {})
  end

  describe "#perform" do
    it "creates a check record" do
      expect { described_class.perform_now(monitor.id) }
        .to change { monitor.checks.count }.by(1)
    end

    it "updates last_checked_at" do
      freeze_time do
        described_class.perform_now(monitor.id)
        expect(monitor.reload.last_checked_at).to eq(Time.current)
      end
    end

    it "calls IncidentManager" do
      incident_manager = instance_double(IncidentManager)
      allow(IncidentManager).to receive(:new).and_return(incident_manager)
      allow(incident_manager).to receive(:process_check_result)

      described_class.perform_now(monitor.id)

      expect(incident_manager).to have_received(:process_check_result).with(an_instance_of(Check))
    end

    context "when the monitor is inactive" do
      let(:monitor) { create(:site_monitor, :inactive, url: "https://example.com") }

      it "skips the check" do
        expect { described_class.perform_now(monitor.id) }
          .not_to change(Check, :count)
      end
    end

    context "when the monitor does not exist" do
      it "discards the job without raising" do
        expect { described_class.perform_now(SecureRandom.uuid) }
          .not_to raise_error
      end
    end
  end
end
