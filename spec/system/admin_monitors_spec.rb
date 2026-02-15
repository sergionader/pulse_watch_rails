require "rails_helper"

RSpec.describe "Admin Monitors", type: :system do
  it "creates a new monitor" do
    visit new_admin_monitor_path

    fill_in "Name", with: "My Website"
    fill_in "URL", with: "https://example.com"
    select "GET", from: "HTTP Method"
    fill_in "Expected Status", with: "200"
    fill_in "Check Interval (seconds)", with: "60"
    fill_in "Timeout (ms)", with: "5000"
    check "Active"

    click_button "Create Site monitor"

    expect(page).to have_content("Monitor created successfully.")
    expect(page).to have_content("My Website")
  end

  it "edits an existing monitor" do
    monitor = create(:site_monitor, name: "Old Name")

    visit edit_admin_monitor_path(monitor)

    fill_in "Name", with: "New Name"
    click_button "Update Site monitor"

    expect(page).to have_content("Monitor updated successfully.")
    expect(page).to have_content("New Name")
  end

  it "shows monitor details with chart" do
    monitor = create(:site_monitor, name: "Production API")
    create(:check, site_monitor: monitor)

    visit admin_monitor_path(monitor)

    expect(page).to have_content("Production API")
    expect(page).to have_css("canvas[data-chart-target='canvas']")
  end

  it "lists all monitors on the index page" do
    create(:site_monitor, name: "Service Alpha")
    create(:site_monitor, name: "Service Beta")

    visit admin_monitors_path

    expect(page).to have_content("Service Alpha")
    expect(page).to have_content("Service Beta")
  end
end
