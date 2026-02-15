require "rails_helper"

RSpec.describe "Api::V1::Status" do
  describe "GET /api/v1/status" do
    it "returns operational when all monitors are up" do
      create(:site_monitor, :up)
      create(:site_monitor, :up)

      get "/api/v1/status"

      expect(response).to have_http_status(:ok)
      expect(json_data[:overall_status]).to eq("operational")
    end

    it "returns degraded when any monitor is degraded" do
      create(:site_monitor, :up)
      create(:site_monitor, :degraded)

      get "/api/v1/status"

      expect(json_data[:overall_status]).to eq("degraded")
    end

    it "returns major_outage when any monitor is down" do
      create(:site_monitor, :up)
      create(:site_monitor, :down)

      get "/api/v1/status"

      expect(json_data[:overall_status]).to eq("major_outage")
    end

    it "returns unknown when there are no active monitors" do
      create(:site_monitor, :inactive)

      get "/api/v1/status"

      expect(json_data[:overall_status]).to eq("unknown")
    end

    it "only includes active monitors" do
      create(:site_monitor, :up)
      create(:site_monitor, :inactive)

      get "/api/v1/status"

      expect(json_data[:monitors].length).to eq(1)
    end

    it "includes active incidents" do
      create(:incident, :investigating)
      create(:incident, :resolved)

      get "/api/v1/status"

      expect(json_data[:active_incidents].length).to eq(1)
      expect(json_data[:active_incidents].first[:status]).to eq("investigating")
    end

    it "returns empty arrays when no monitors or incidents exist" do
      get "/api/v1/status"

      expect(json_data[:overall_status]).to eq("unknown")
      expect(json_data[:monitors]).to eq([])
      expect(json_data[:active_incidents]).to eq([])
    end
  end
end
