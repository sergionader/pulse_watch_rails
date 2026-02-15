require "rails_helper"

RSpec.describe SiteMonitor do
  subject { build(:site_monitor) }

  describe "associations" do
    it { is_expected.to have_many(:checks).dependent(:destroy) }
    it { is_expected.to have_and_belong_to_many(:incidents) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:http_method) }

    it { is_expected.to validate_inclusion_of(:http_method).in_array(%w[GET POST PUT PATCH DELETE HEAD OPTIONS]) }

    it { is_expected.to validate_presence_of(:expected_status) }
    it { is_expected.to validate_numericality_of(:expected_status).only_integer.is_greater_than_or_equal_to(100).is_less_than(600) }

    it { is_expected.to validate_presence_of(:check_interval_seconds) }
    it { is_expected.to validate_numericality_of(:check_interval_seconds).only_integer.is_greater_than_or_equal_to(30) }

    it { is_expected.to validate_presence_of(:timeout_ms) }
    it { is_expected.to validate_numericality_of(:timeout_ms).only_integer.is_greater_than_or_equal_to(1000).is_less_than_or_equal_to(30_000) }

    it "rejects invalid URLs" do
      monitor = build(:site_monitor, url: "not-a-url")
      expect(monitor).not_to be_valid
    end

    it "accepts valid https URLs" do
      monitor = build(:site_monitor, url: "https://example.com")
      expect(monitor).to be_valid
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:current_status).with_values(up: 0, down: 1, degraded: 2) }
  end

  describe "scopes" do
    let!(:active_monitor) { create(:site_monitor, is_active: true) }
    let!(:inactive_monitor) { create(:site_monitor, :inactive) }

    describe ".active" do
      it "returns only active monitors" do
        expect(described_class.active).to contain_exactly(active_monitor)
      end
    end

    describe ".inactive" do
      it "returns only inactive monitors" do
        expect(described_class.inactive).to contain_exactly(inactive_monitor)
      end
    end
  end

  describe "#last_check" do
    let(:monitor) { create(:site_monitor) }

    it "returns nil when no checks exist" do
      expect(monitor.last_check).to be_nil
    end

    it "returns the most recent check" do
      old_check = create(:check, site_monitor: monitor, created_at: 1.hour.ago)
      new_check = create(:check, site_monitor: monitor, created_at: 1.minute.ago)

      expect(monitor.last_check).to eq(new_check)
    end
  end
end
