require "rails_helper"

RSpec.describe SendNotificationJob do
  let(:incident) { create(:incident) }

  describe "#perform" do
    context "with active notification channels" do
      before do
        create(:notification_channel, :email, active: true)
        create(:notification_channel, :slack, active: true)
      end

      it "logs a notification for each active channel" do
        allow(Rails.logger).to receive(:info).and_call_original

        described_class.perform_now("incident_created", incident.id)

        expect(Rails.logger).to have_received(:info)
          .with(match(/\[SendNotificationJob\] Sending/)).twice
      end
    end

    context "with inactive notification channels" do
      before do
        create(:notification_channel, :email, active: true)
        create(:notification_channel, :inactive)
      end

      it "skips inactive channels" do
        allow(Rails.logger).to receive(:info).and_call_original

        described_class.perform_now("incident_created", incident.id)

        expect(Rails.logger).to have_received(:info)
          .with(match(/\[SendNotificationJob\] Sending/)).once
      end
    end

    context "when a channel delivery fails" do
      before do
        create(:notification_channel, :email, active: true)
        create(:notification_channel, :slack, active: true)
      end

      it "continues notifying other channels" do
        notification_count = 0
        allow(Rails.logger).to receive(:info) do |msg|
          if msg.is_a?(String) && msg.include?("[SendNotificationJob] Sending")
            notification_count += 1
            raise StandardError, "Delivery failed" if notification_count == 1
          end
        end
        allow(Rails.logger).to receive(:error)

        expect { described_class.perform_now("incident_created", incident.id) }
          .not_to raise_error
      end
    end
  end
end
