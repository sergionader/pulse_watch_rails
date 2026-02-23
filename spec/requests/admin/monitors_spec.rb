require "rails_helper"

RSpec.describe "Admin::Monitors" do
  let!(:monitor) { create(:site_monitor, name: "Test Monitor") }

  before { sign_in }

  describe "GET /admin/monitors" do
    it "returns 200 and lists monitors" do
      get admin_monitors_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Test Monitor")
    end
  end

  describe "GET /admin/monitors/:id" do
    it "returns 200 and shows the monitor" do
      get admin_monitor_path(monitor)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Test Monitor")
    end
  end

  describe "GET /admin/monitors/new" do
    it "returns 200" do
      get new_admin_monitor_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/monitors" do
    let(:valid_params) do
      {
        site_monitor: {
          name: "New Monitor",
          url: "https://example.com",
          http_method: "GET",
          expected_status: 200,
          check_interval_seconds: 60,
          timeout_ms: 5000,
          is_active: true
        }
      }
    end

    context "with valid params" do
      it "creates a monitor and redirects" do
        expect {
          post admin_monitors_path, params: valid_params
        }.to change(SiteMonitor, :count).by(1)

        created_monitor = SiteMonitor.find_by(name: "New Monitor")
        expect(response).to redirect_to(admin_monitor_path(created_monitor))
        follow_redirect!
        expect(response.body).to include("Monitor created successfully.")
      end
    end

    context "with invalid params" do
      it "renders new with unprocessable entity" do
        post admin_monitors_path, params: { site_monitor: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /admin/monitors/:id/edit" do
    it "returns 200" do
      get edit_admin_monitor_path(monitor)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/monitors/:id" do
    context "with valid params" do
      it "updates the monitor and redirects" do
        patch admin_monitor_path(monitor), params: { site_monitor: { name: "Updated Name" } }
        expect(response).to redirect_to(admin_monitor_path(monitor))
        expect(monitor.reload.name).to eq("Updated Name")
      end
    end

    context "with invalid params" do
      it "renders edit with unprocessable entity" do
        patch admin_monitor_path(monitor), params: { site_monitor: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /admin/monitors/:id" do
    it "deletes the monitor and redirects" do
      expect {
        delete admin_monitor_path(monitor)
      }.to change(SiteMonitor, :count).by(-1)

      expect(response).to redirect_to(admin_monitors_path)
    end
  end

  describe "GET /admin/monitors/:id/checks" do
    it "returns JSON of recent checks" do
      create(:check, site_monitor: monitor, created_at: 1.hour.ago)

      get checks_admin_monitor_path(monitor), as: :json
      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data).to be_an(Array)
      expect(data.first).to include("time", "response_time_ms", "successful")
    end
  end
end
