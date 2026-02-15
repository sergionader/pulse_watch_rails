# PulseWatch

Real-time uptime monitoring and status page application built with Ruby on Rails.

## Tech Stack

- **Framework:** Ruby on Rails 8.1
- **Database:** PostgreSQL
- **Background Jobs:** Sidekiq + sidekiq-cron
- **Real-time:** Turbo Streams (Action Cable)
- **Frontend:** Tailwind CSS, Stimulus, importmap-rails
- **Error Tracking:** Sentry
- **Testing:** RSpec, FactoryBot, Capybara, SimpleCov

## Prerequisites

- Ruby (see `.ruby-version`)
- PostgreSQL 16+
- Chrome/Chromium (for system tests)
- Redis (for Sidekiq)

## Setup

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start the server
bin/dev
```

## Running Tests

```bash
# Full test suite
bundle exec rspec

# Model specs
bundle exec rspec spec/models

# Request specs
bundle exec rspec spec/requests

# System specs (requires Chrome)
bundle exec rspec spec/system

# With coverage report
open coverage/index.html
```

## Docker

```bash
docker compose up --build
```

## API Overview

All API endpoints are under `/api/v1`.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/monitors` | List all monitors |
| POST | `/api/v1/monitors` | Create a monitor |
| GET | `/api/v1/monitors/:id` | Show a monitor |
| PATCH | `/api/v1/monitors/:id` | Update a monitor |
| DELETE | `/api/v1/monitors/:id` | Delete a monitor |
| GET | `/api/v1/monitors/:id/checks` | List checks for a monitor |
| GET | `/api/v1/monitors/:id/uptime` | Get uptime stats |
| GET | `/api/v1/incidents` | List incidents |
| POST | `/api/v1/incidents` | Create an incident |
| GET | `/api/v1/incidents/:id` | Show an incident |
| PATCH | `/api/v1/incidents/:id` | Update an incident |
| PATCH | `/api/v1/incidents/:id/resolve` | Resolve an incident |
| GET | `/api/v1/status` | Public status summary |

## Architecture

```
app/
├── controllers/
│   ├── api/v1/        # JSON API controllers
│   ├── admin/         # Admin web controllers
│   └── status_controller.rb  # Public status page
├── models/
│   ├── site_monitor.rb        # Monitor configuration
│   ├── check.rb               # Health check results
│   ├── incident.rb            # Incident tracking
│   ├── incident_update.rb     # Incident timeline updates
│   └── notification_channel.rb # Alert channels
├── services/
│   ├── monitoring_service.rb  # Performs HTTP checks
│   ├── uptime_calculator.rb   # Computes uptime percentages
│   └── incident_manager.rb    # Incident lifecycle management
└── jobs/
    └── ...                    # Background check jobs
```

## Linting

```bash
bundle exec rubocop
```

## Security Scanning

```bash
bin/brakeman --no-pager
bin/bundler-audit
```
