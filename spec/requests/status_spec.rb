require "rails_helper"

RSpec.describe "Status Page" do
  describe "GET /" do
    it "returns 200" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "displays monitors" do
      monitor = create(:site_monitor, name: "API Server")
      get root_path
      expect(response.body).to include("API Server")
    end

    it "displays active incidents" do
      incident = create(:incident, title: "Database Outage")
      get root_path
      expect(response.body).to include("Database Outage")
    end

    it "shows All Systems Operational when everything is up" do
      create(:site_monitor, :up)
      get root_path
      expect(response.body).to include("All Systems Operational")
    end

    it "shows degraded status when a monitor is down" do
      create(:site_monitor, :down)
      get root_path
      expect(response.body).to include("Degraded Performance")
    end
  end
end
