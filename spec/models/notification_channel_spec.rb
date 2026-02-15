require "rails_helper"

RSpec.describe NotificationChannel do
  describe "validations" do
    it { is_expected.to validate_presence_of(:channel_type) }
    it { is_expected.to validate_presence_of(:config) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:channel_type).with_values(email: 0, slack: 1, discord: 2, webhook: 3) }
  end

  describe "scopes" do
    describe ".active" do
      it "returns only active channels" do
        active_channel = create(:notification_channel)
        create(:notification_channel, :inactive)

        expect(described_class.active).to contain_exactly(active_channel)
      end
    end
  end
end
