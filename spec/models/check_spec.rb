require "rails_helper"

RSpec.describe Check do
  describe "associations" do
    it { is_expected.to belong_to(:site_monitor) }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:response_time_ms).only_integer.is_greater_than_or_equal_to(0).allow_nil }
  end

  describe "scopes" do
    let(:monitor) { create(:site_monitor) }
    let!(:success_check) { create(:check, :successful, site_monitor: monitor) }
    let!(:failed_check) { create(:check, :failed, site_monitor: monitor) }

    describe ".successful" do
      it "returns only successful checks" do
        expect(described_class.successful).to contain_exactly(success_check)
      end
    end

    describe ".failed" do
      it "returns only failed checks" do
        expect(described_class.failed).to contain_exactly(failed_check)
      end
    end

    describe ".recent" do
      it "returns checks ordered by most recent, limited" do
        expect(described_class.recent(1).count).to eq(1)
      end
    end

    describe ".in_time_range" do
      it "returns checks within the given time range" do
        results = described_class.in_time_range(1.hour.ago, Time.current)
        expect(results).to include(success_check, failed_check)
      end
    end
  end
end
