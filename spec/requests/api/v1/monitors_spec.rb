require "rails_helper"

RSpec.describe "Api::V1::Monitors" do
  describe "GET /api/v1/monitors" do
    it "returns a paginated list of monitors" do
      create_list(:site_monitor, 3)

      get "/api/v1/monitors"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
      expect(json_response[:meta][:total_count]).to eq(3)
    end

    it "orders monitors by created_at desc" do
      old = create(:site_monitor, name: "Old", created_at: 2.days.ago)
      new_mon = create(:site_monitor, name: "New", created_at: 1.hour.ago)

      get "/api/v1/monitors"

      expect(json_data.first[:name]).to eq("New")
      expect(json_data.last[:name]).to eq("Old")
    end

    it "respects pagination params" do
      create_list(:site_monitor, 5)

      get "/api/v1/monitors", params: { page: 2, per_page: 2 }

      expect(json_data.length).to eq(2)
      expect(json_response[:meta][:current_page]).to eq(2)
      expect(json_response[:meta][:per_page]).to eq(2)
      expect(json_response[:meta][:total_pages]).to eq(3)
    end
  end

  describe "GET /api/v1/monitors/:id" do
    it "returns a single monitor" do
      monitor = create(:site_monitor)

      get "/api/v1/monitors/#{monitor.id}"

      expect(response).to have_http_status(:ok)
      expect(json_data[:id]).to eq(monitor.id)
      expect(json_data[:name]).to eq(monitor.name)
      expect(json_data[:url]).to eq(monitor.url)
    end

    it "returns 404 for non-existent monitor" do
      get "/api/v1/monitors/#{SecureRandom.uuid}"

      expect(response).to have_http_status(:not_found)
      expect(json_errors[:status]).to eq(404)
    end
  end

  describe "POST /api/v1/monitors" do
    let(:valid_params) do
      {
        monitor: {
          name: "My API",
          url: "https://api.example.com/health",
          http_method: "GET",
          expected_status: 200,
          check_interval_seconds: 60,
          timeout_ms: 5000
        }
      }
    end

    it "creates a new monitor" do
      expect {
        post "/api/v1/monitors", params: valid_params
      }.to change(SiteMonitor, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json_data[:name]).to eq("My API")
      expect(json_data[:url]).to eq("https://api.example.com/health")
    end

    it "returns 422 for invalid params" do
      post "/api/v1/monitors", params: { monitor: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_errors[:details]).to be_an(Array)
    end

    it "returns 400 when monitor key is missing" do
      post "/api/v1/monitors", params: { name: "test" }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "PATCH /api/v1/monitors/:id" do
    it "updates a monitor" do
      monitor = create(:site_monitor)

      patch "/api/v1/monitors/#{monitor.id}", params: { monitor: { name: "Updated" } }

      expect(response).to have_http_status(:ok)
      expect(json_data[:name]).to eq("Updated")
      expect(monitor.reload.name).to eq("Updated")
    end

    it "returns 422 for invalid update" do
      monitor = create(:site_monitor)

      patch "/api/v1/monitors/#{monitor.id}", params: { monitor: { url: "not-a-url" } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/monitors/:id" do
    it "deletes a monitor and returns 204" do
      monitor = create(:site_monitor)

      expect {
        delete "/api/v1/monitors/#{monitor.id}"
      }.to change(SiteMonitor, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for non-existent monitor" do
      delete "/api/v1/monitors/#{SecureRandom.uuid}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/monitors/:id/checks" do
    it "returns paginated checks for a monitor" do
      monitor = create(:site_monitor)
      create_list(:check, 3, site_monitor: monitor)

      get "/api/v1/monitors/#{monitor.id}/checks"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
      expect(json_data.first).to have_key(:status_code)
      expect(json_data.first).to have_key(:response_time_ms)
    end

    it "paginates checks" do
      monitor = create(:site_monitor)
      create_list(:check, 5, site_monitor: monitor)

      get "/api/v1/monitors/#{monitor.id}/checks", params: { per_page: 2 }

      expect(json_data.length).to eq(2)
      expect(json_response[:meta][:total_count]).to eq(5)
    end
  end

  describe "GET /api/v1/monitors/:id/uptime" do
    it "returns uptime percentages for all periods" do
      monitor = create(:site_monitor)
      create_list(:check, 3, :successful, site_monitor: monitor)

      get "/api/v1/monitors/#{monitor.id}/uptime"

      expect(response).to have_http_status(:ok)
      expect(json_data).to have_key(:"24h")
      expect(json_data).to have_key(:"7d")
      expect(json_data).to have_key(:"30d")
      expect(json_data).to have_key(:"90d")
    end

    it "returns null for periods with no checks" do
      monitor = create(:site_monitor)

      get "/api/v1/monitors/#{monitor.id}/uptime"

      expect(response).to have_http_status(:ok)
      expect(json_data[:"24h"]).to be_nil
    end
  end
end
