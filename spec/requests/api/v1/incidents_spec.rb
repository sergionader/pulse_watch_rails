require "rails_helper"

RSpec.describe "Api::V1::Incidents" do
  describe "GET /api/v1/incidents" do
    it "returns a paginated list of incidents" do
      create_list(:incident, 3)

      get "/api/v1/incidents"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
      expect(json_response[:meta][:total_count]).to eq(3)
    end

    it "filters by status" do
      create(:incident, :investigating)
      create(:incident, :resolved)

      get "/api/v1/incidents", params: { status: "investigating" }

      expect(json_data.length).to eq(1)
      expect(json_data.first[:status]).to eq("investigating")
    end

    it "does not include incident_updates in index" do
      incident = create(:incident)
      create(:incident_update, incident: incident)

      get "/api/v1/incidents"

      expect(json_data.first).not_to have_key(:incident_updates)
    end
  end

  describe "GET /api/v1/incidents/:id" do
    it "returns a single incident with nested updates" do
      incident = create(:incident)
      update = create(:incident_update, incident: incident)

      get "/api/v1/incidents/#{incident.id}"

      expect(response).to have_http_status(:ok)
      expect(json_data[:id]).to eq(incident.id)
      expect(json_data[:incident_updates]).to be_an(Array)
      expect(json_data[:incident_updates].first[:id]).to eq(update.id)
    end

    it "returns 404 for non-existent incident" do
      get "/api/v1/incidents/#{SecureRandom.uuid}"

      expect(response).to have_http_status(:not_found)
      expect(json_errors[:status]).to eq(404)
    end
  end

  describe "POST /api/v1/incidents" do
    let(:valid_params) do
      {
        incident: {
          title: "API Outage",
          status: "investigating",
          severity: "major"
        }
      }
    end

    it "creates a new incident" do
      expect {
        post "/api/v1/incidents", params: valid_params
      }.to change(Incident, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json_data[:title]).to eq("API Outage")
      expect(json_data[:severity]).to eq("major")
    end

    it "accepts monitor_ids to associate monitors" do
      monitor = create(:site_monitor)

      post "/api/v1/incidents", params: {
        incident: {
          title: "Monitor down",
          status: "investigating",
          severity: "critical",
          monitor_ids: [ monitor.id ]
        }
      }

      expect(response).to have_http_status(:created)
      expect(json_data[:monitor_ids]).to include(monitor.id)
    end

    it "returns 422 for invalid params" do
      post "/api/v1/incidents", params: { incident: { title: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_errors[:details]).to be_an(Array)
    end
  end

  describe "PATCH /api/v1/incidents/:id" do
    it "updates an incident" do
      incident = create(:incident)

      patch "/api/v1/incidents/#{incident.id}", params: {
        incident: { title: "Updated Title", severity: "critical" }
      }

      expect(response).to have_http_status(:ok)
      expect(json_data[:title]).to eq("Updated Title")
      expect(json_data[:severity]).to eq("critical")
    end

    it "updates monitor associations" do
      incident = create(:incident)
      monitor = create(:site_monitor)

      patch "/api/v1/incidents/#{incident.id}", params: {
        incident: { monitor_ids: [ monitor.id ] }
      }

      expect(json_data[:monitor_ids]).to include(monitor.id)
    end
  end

  describe "PATCH /api/v1/incidents/:id/resolve" do
    it "resolves an incident" do
      incident = create(:incident, :investigating)

      patch "/api/v1/incidents/#{incident.id}/resolve"

      expect(response).to have_http_status(:ok)
      expect(json_data[:status]).to eq("resolved")
      expect(json_data[:resolved_at]).not_to be_nil
    end

    it "returns 404 for non-existent incident" do
      patch "/api/v1/incidents/#{SecureRandom.uuid}/resolve"

      expect(response).to have_http_status(:not_found)
    end
  end
end
