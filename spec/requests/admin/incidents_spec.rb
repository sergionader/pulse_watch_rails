require "rails_helper"

RSpec.describe "Admin::Incidents" do
  let!(:incident) { create(:incident, title: "Test Incident") }

  before { sign_in }

  describe "GET /admin/incidents" do
    it "returns 200 and lists incidents" do
      get admin_incidents_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Test Incident")
    end
  end

  describe "GET /admin/incidents/:id" do
    it "returns 200 and shows the incident" do
      get admin_incident_path(incident)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Test Incident")
    end
  end

  describe "GET /admin/incidents/new" do
    it "returns 200" do
      get new_admin_incident_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/incidents" do
    context "with valid params" do
      it "creates an incident and redirects" do
        expect {
          post admin_incidents_path, params: { incident: { title: "New Incident", severity: "minor" } }
        }.to change(Incident, :count).by(1)

        created_incident = Incident.find_by(title: "New Incident")
        expect(response).to redirect_to(admin_incident_path(created_incident))
      end
    end

    context "with invalid params" do
      it "renders new with unprocessable entity" do
        post admin_incidents_path, params: { incident: { title: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /admin/incidents/:id" do
    it "updates the incident and redirects" do
      patch admin_incident_path(incident), params: { incident: { title: "Updated Incident" } }
      expect(response).to redirect_to(admin_incident_path(incident))
      expect(incident.reload.title).to eq("Updated Incident")
    end
  end

  describe "PATCH /admin/incidents/:id/resolve" do
    it "resolves the incident and redirects" do
      patch resolve_admin_incident_path(incident)
      expect(response).to redirect_to(admin_incident_path(incident))
      expect(incident.reload).to be_resolved
    end
  end

  describe "POST /admin/incidents/:incident_id/incident_updates" do
    it "creates an incident update" do
      expect {
        post admin_incident_incident_updates_path(incident), params: {
          incident_update: { message: "We are investigating", status: "investigating" }
        }
      }.to change(IncidentUpdate, :count).by(1)

      expect(response).to redirect_to(admin_incident_path(incident))
    end

    it "updates the incident status when provided" do
      post admin_incident_incident_updates_path(incident), params: {
        incident_update: { message: "Root cause identified", status: "identified" }
      }

      expect(incident.reload).to be_identified
    end
  end
end
