require "rails_helper"

RSpec.describe "Status Page", type: :system do
  it "shows All Systems Operational banner" do
    create(:site_monitor, :up, name: "Web App")

    visit root_path

    expect(page).to have_content("All Systems Operational")
  end

  it "lists monitors" do
    create(:site_monitor, :up, name: "API Gateway")
    create(:site_monitor, :up, name: "Database Cluster")

    visit root_path

    expect(page).to have_content("API Gateway")
    expect(page).to have_content("Database Cluster")
  end

  it "shows active incidents" do
    create(:incident, title: "Elevated Error Rates", severity: :major)

    visit root_path

    expect(page).to have_content("Elevated Error Rates")
    expect(page).to have_content("Active Incidents")
  end

  it "shows no active incidents message when none exist" do
    visit root_path

    expect(page).to have_content("No active incidents")
  end
end
