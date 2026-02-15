require "rails_helper"

RSpec.describe UptimeCalculator do
  let(:monitor) { create(:site_monitor) }

  describe "#calculate" do
    context "when there are no checks" do
      it "returns nil" do
        result = described_class.new(monitor.id).calculate("24h")
        expect(result).to be_nil
      end
    end

    context "when all checks are successful" do
      before do
        create_list(:check, 5, :successful, site_monitor: monitor, created_at: 1.hour.ago)
      end

      it "returns 100.0" do
        result = described_class.new(monitor.id).calculate("24h")
        expect(result).to eq(100.0)
      end
    end

    context "when there is a mix of successful and failed checks" do
      before do
        create_list(:check, 3, :successful, site_monitor: monitor, created_at: 2.hours.ago)
        create_list(:check, 1, :failed, site_monitor: monitor, created_at: 1.hour.ago)
      end

      it "returns the correct percentage" do
        result = described_class.new(monitor.id).calculate("24h")
        expect(result).to eq(75.0)
      end
    end

    context "when checks are outside the requested range" do
      before do
        create_list(:check, 5, :successful, site_monitor: monitor, created_at: 48.hours.ago)
      end

      it "returns nil when no checks fall within the period" do
        result = described_class.new(monitor.id).calculate("24h")
        expect(result).to be_nil
      end
    end
  end

  describe "#calculate_all" do
    before do
      create_list(:check, 3, :successful, site_monitor: monitor, created_at: 1.hour.ago)
      create_list(:check, 1, :failed, site_monitor: monitor, created_at: 2.hours.ago)
    end

    it "returns a hash with all periods" do
      result = described_class.new(monitor.id).calculate_all

      expect(result.keys).to contain_exactly("24h", "7d", "30d", "90d")
      expect(result["24h"]).to eq(75.0)
      expect(result["7d"]).to eq(75.0)
      expect(result["30d"]).to eq(75.0)
      expect(result["90d"]).to eq(75.0)
    end
  end
end
