puts "Seeding monitors..."

monitors = [
  { name: "GitHub", url: "https://github.com", http_method: "GET", expected_status: 200, check_interval_seconds: 300, current_status: :up },
  { name: "Google", url: "https://www.google.com", http_method: "GET", expected_status: 200, check_interval_seconds: 60, current_status: :up },
  { name: "Stripe API", url: "https://api.stripe.com/v1", http_method: "GET", expected_status: 401, check_interval_seconds: 120, current_status: :up },
  { name: "Example Down Service", url: "https://httpstat.us/500", http_method: "GET", expected_status: 200, check_interval_seconds: 300, current_status: :down },
  { name: "Slow API", url: "https://httpstat.us/200?sleep=3000", http_method: "GET", expected_status: 200, check_interval_seconds: 600, current_status: :degraded }
]

monitors.each do |attrs|
  SiteMonitor.find_or_create_by!(name: attrs[:name]) do |m|
    m.assign_attributes(attrs)
  end
end

puts "Seeding incidents..."

incident = Incident.find_or_create_by!(title: "Example Down Service outage") do |i|
  i.status = :investigating
  i.severity = :major
end

down_monitor = SiteMonitor.find_by!(name: "Example Down Service")
incident.site_monitors << down_monitor unless incident.site_monitors.exists?(down_monitor.id)

IncidentUpdate.find_or_create_by!(incident: incident, message: "We are investigating elevated error rates.") do |u|
  u.status = :investigating
end

IncidentUpdate.find_or_create_by!(incident: incident, message: "Root cause identified: upstream provider issue.") do |u|
  u.status = :identified
end

puts "Seeding notification channels..."

NotificationChannel.find_or_create_by!(channel_type: :email) do |nc|
  nc.config = { address: "ops@example.com" }
  nc.active = true
end

puts "Seeding complete!"
