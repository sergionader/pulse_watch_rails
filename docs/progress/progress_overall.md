# PulseWatch Rails - Progress (2026-02-14)

## Summary

Implemented Days 1–5 of PulseWatch Rails: models/migrations (Day 1), background jobs/services (Day 2), JSON API layer (Day 3), web UI with real-time Turbo Streams (Day 4), and testing/polish (Day 5). Added model specs, admin request specs, Capybara system specs, CI test pipeline, Sentry integration, and professional README. 140 specs pass with 90.55% line coverage.

## Status: ✅ Day 5 Complete

Days 1–5 are fully implemented. Testing exceeds 80% coverage, CI runs tests, Sentry is configured, README is written.

## Key Decisions

- API controllers inherit from `ActionController::API` (not `ApplicationController`) to avoid browser-only features like `allow_browser`
- Used plain Ruby serializer classes (no gems) with `initialize(record)`, `as_json`, and `self.collection(records)` pattern
- Singular `resource :status` maps to `StatusesController` per Rails convention (not `StatusController`)
- `IncidentSerializer` supports opt-in `include_updates:` flag — true for show, false for collection
- No authentication for Day 3 — planned for a later day
- Consistent error JSON format: `{ error: { message:, status:, details?: } }`
- Pagination defaults: page=1, per_page=20, max=100
- Web `StatusController` (public) is separate from API `StatusesController` — different inheritance chains
- Admin controllers inherit from `Admin::BaseController` which sets `layout "admin"`
- Turbo Stream broadcasts live from model callbacks (`after_update_commit`, `after_create_commit`) — works with async adapter since callbacks fire in the web process
- Chart.js pinned via importmap CDN (`chart.js/auto` ESM build) — no npm needed
- Strong params key for admin monitors is `site_monitor` (Rails convention from model name)
- System specs use `rack_test` driver by default for speed; `selenium_headless` only for tests tagged `:js`
- Sentry enabled only in production/staging environments; DSN and sample rates via ENV vars
- CI test job uses PostgreSQL 16 service container with `DATABASE_URL` env var

## Changes Made

| File | Change |
|------|--------|
| `config/routes.rb` | Added `api/v1` namespace with monitors, incidents, and status routes (13 routes) |
| `app/controllers/api/v1/base_controller.rb` | Created — base API controller with error handling, pagination, `render_success` |
| `app/controllers/api/v1/monitors_controller.rb` | Created — CRUD + checks/uptime endpoints |
| `app/controllers/api/v1/incidents_controller.rb` | Created — CRUD + status filter + resolve endpoint |
| `app/controllers/api/v1/statuses_controller.rb` | Created — overall status, active monitors, active incidents |
| `app/serializers/monitor_serializer.rb` | Created — serializes SiteMonitor attributes |
| `app/serializers/check_serializer.rb` | Created — serializes Check attributes |
| `app/serializers/incident_serializer.rb` | Created — serializes Incident with optional nested updates |
| `app/serializers/incident_update_serializer.rb` | Created — serializes IncidentUpdate attributes |
| `spec/support/request_helpers.rb` | Created — `json_response`, `json_data`, `json_errors`, `json_meta` helpers |
| `spec/requests/api/v1/monitors_spec.rb` | Created — 15 examples covering CRUD, pagination, checks, uptime, errors |
| `spec/requests/api/v1/incidents_spec.rb` | Created — 13 examples covering CRUD, filtering, resolve, associations, errors |
| `spec/requests/api/v1/status_spec.rb` | Created — 7 examples covering all status states and filtering |
| `config/routes.rb` | Added root route (`status#index`) and `namespace :admin` with monitors, incidents, incident_updates routes |
| `config/importmap.rb` | Pinned `chart.js/auto` from jsdelivr CDN |
| `app/views/layouts/application.html.erb` | Added `action_cable_meta_tag`, navbar/flash partials, updated body structure |
| `app/models/site_monitor.rb` | Added `ActionView::RecordIdentifier`, `after_update_commit :broadcast_status_change` for Turbo Streams |
| `app/models/incident.rb` | Added `after_create_commit` and `after_update_commit` broadcast callbacks |
| `app/channels/application_cable/connection.rb` | Created — ActionCable connection base |
| `app/channels/application_cable/channel.rb` | Created — ActionCable channel base |
| `app/controllers/status_controller.rb` | Created — public status page with overall status determination |
| `app/controllers/admin/base_controller.rb` | Created — admin base with `layout "admin"` |
| `app/controllers/admin/monitors_controller.rb` | Created — full CRUD + `checks` JSON endpoint for Chart.js |
| `app/controllers/admin/incidents_controller.rb` | Created — CRUD + `resolve` action |
| `app/controllers/admin/incident_updates_controller.rb` | Created — `create` action for posting incident timeline updates |
| `app/helpers/status_helper.rb` | Created — `status_badge`, `severity_badge`, `incident_status_badge`, `overall_status_class/text` |
| `app/views/layouts/admin.html.erb` | Created — admin layout with dark navbar |
| `app/views/shared/_navbar.html.erb` | Created — public nav with logo + admin link |
| `app/views/shared/_admin_navbar.html.erb` | Created — admin nav with Monitors/Incidents links + active state |
| `app/views/shared/_flash.html.erb` | Created — flash messages with auto-dismiss via Stimulus |
| `app/views/status/index.html.erb` | Created — overall status banner, services list, active incidents with `turbo_stream_from` |
| `app/views/status/_overall_status.html.erb` | Created — colored banner partial (targeted by Turbo Streams) |
| `app/views/status/_monitor.html.erb` | Created — monitor row with status dot and badge |
| `app/views/status/_incident.html.erb` | Created — incident card with updates timeline |
| `app/views/admin/monitors/index.html.erb` | Created — table of monitors with status, actions |
| `app/views/admin/monitors/show.html.erb` | Created — details, uptime stats grid, Chart.js canvas, recent checks table |
| `app/views/admin/monitors/new.html.erb` | Created — wraps `_form` partial |
| `app/views/admin/monitors/edit.html.erb` | Created — wraps `_form` partial |
| `app/views/admin/monitors/_form.html.erb` | Created — all monitor fields with validation errors |
| `app/views/admin/monitors/_check_row.html.erb` | Created — single check table row |
| `app/views/admin/incidents/index.html.erb` | Created — active incidents cards + resolved table |
| `app/views/admin/incidents/show.html.erb` | Created — detail, resolve button, post update form, timeline |
| `app/views/admin/incidents/new.html.erb` | Created — wraps `_form` partial |
| `app/views/admin/incidents/edit.html.erb` | Created — wraps `_form` partial |
| `app/views/admin/incidents/_form.html.erb` | Created — title, severity, status, monitor checkboxes |
| `app/views/admin/incidents/_incident_update.html.erb` | Created — timeline entry with icon, status badge, timestamp |
| `app/views/admin/incidents/_update_form.html.erb` | Created — message textarea + status select |
| `app/javascript/controllers/chart_controller.js` | Created — fetches checks JSON, renders Chart.js line chart |
| `app/javascript/controllers/flash_controller.js` | Created — auto-dismiss after 5 seconds |
| `app/javascript/controllers/hello_controller.js` | Deleted — default scaffold file |
| `Gemfile` | Added capybara, selenium-webdriver, sentry-ruby, sentry-rails |
| `spec/support/capybara.rb` | Created — Capybara config with rack_test default, selenium_headless for `:js` |
| `spec/models/site_monitor_spec.rb` | Created — associations, validations, enums, scopes, `#last_check` |
| `spec/models/check_spec.rb` | Created — associations, validations, scopes |
| `spec/models/incident_spec.rb` | Created — associations, validations, enums, scopes, `#resolve!` |
| `spec/models/incident_update_spec.rb` | Created — associations, validations, enums |
| `spec/models/notification_channel_spec.rb` | Created — validations, enums, scopes |
| `spec/requests/status_spec.rb` | Created — public status page request specs (5 examples) |
| `spec/requests/admin/monitors_spec.rb` | Created — admin monitor CRUD request specs (10 examples) |
| `spec/requests/admin/incidents_spec.rb` | Created — admin incident CRUD + updates request specs (10 examples) |
| `spec/system/status_page_spec.rb` | Created — Capybara system tests for public status page (4 examples) |
| `spec/system/admin_monitors_spec.rb` | Created — Capybara system tests for admin monitor flows (4 examples) |
| `config/initializers/sentry.rb` | Created — Sentry error tracking initializer |
| `.github/workflows/ci.yml` | Added `test` job with PostgreSQL 16 service, schema load, rspec, coverage upload |
| `README.md` | Replaced placeholder with professional docs: tech stack, setup, API, architecture |
| `app/views/admin/monitors/_form.html.erb` | Fixed — added explicit `url:` to fix SiteMonitor routing mismatch |
| `app/views/admin/incidents/_update_form.html.erb` | Fixed — removed double-wrapped array in `form_with` model |

## Technical Details

- Model is `SiteMonitor` (with `self.table_name = "monitors"`), not `Monitor`
- UUIDs used as primary keys across all tables
- HABTM join table `incidents_monitors` links incidents to monitors
- `Check` and `IncidentUpdate` both have `default_scope { order(created_at: :desc) }`
- `UptimeCalculator` calculates uptime percentages for 24h, 7d, 30d, 90d periods
- `Incident#resolve!` sets status to resolved and resolved_at to current time

## Issues Resolved

### StatusController naming mismatch (Day 3)

- **Problem**: Rails singular `resource :status` routes to `StatusesController`, not `StatusController`
- **Solution**: Renamed controller class and file to `StatusesController` / `statuses_controller.rb`

### render_success keyword argument ambiguity (Day 3)

- **Problem**: `render_success(key: val, ...)` in status controller was interpreted as keyword args instead of a hash positional arg
- **Solution**: Wrapped hash in explicit braces: `render_success({ key: val, ... })`

### dom_id undefined in model callbacks (Day 4)

- **Problem**: `SiteMonitor#broadcast_status_change` called `dom_id(self)` but models don't include that helper by default — caused 7 test failures in `IncidentManager` specs
- **Solution**: Added `include ActionView::RecordIdentifier` to `SiteMonitor` model

### Monitor form routing mismatch (Day 5)

- **Problem**: `form_with(model: [:admin, monitor])` generated `admin_site_monitors_path` because model class is `SiteMonitor`, but routes define `resources :monitors` → `admin_monitors_path`
- **Solution**: Added explicit `url:` parameter: `url: monitor.persisted? ? admin_monitor_path(monitor) : admin_monitors_path`

### Incident update form double-wrapped array (Day 5)

- **Problem**: `form_with(model: [[:admin, incident, incident_update]], ...)` had an extra wrapping array causing `undefined method 'model_name' for Array`
- **Solution**: Changed to single array: `model: [:admin, incident, incident_update]`

## Outstanding Tasks

- [ ] Add authentication (planned for a later day)
- [ ] Add rate limiting for API endpoints
- [ ] Add API documentation (Swagger/OpenAPI)
- [x] ~~Web UI tests (controller/system specs for status page and admin CRUD)~~ — Done Day 5
- [ ] Redis/SolidCable adapter for ActionCable in production (currently async adapter)
- [ ] Increase branch coverage above 80% (currently 70.91%)

---

## Session Log

### 2026-02-14

- Explored existing codebase: models (SiteMonitor, Check, Incident, IncidentUpdate), services (UptimeCalculator, MonitoringService, IncidentManager), factories, and schema
- Added API v1 namespace to routes with all 13 endpoints
- Created `Api::V1::BaseController` with standardized error handling (404, 422, 400), pagination helpers, and `render_success` wrapper
- Created 4 plain Ruby serializers (Monitor, Check, Incident, IncidentUpdate)
- Created 3 API controllers (Monitors, Incidents, Statuses)
- Created request helpers and 3 comprehensive spec files (35 examples total for API layer)
- Fixed StatusController → StatusesController naming to match Rails singular resource convention
- Fixed `render_success` call in StatusesController by wrapping hash in explicit braces
- Final result: **66 examples, 0 failures** — Line coverage 93.61%, Branch coverage 80.39%

### 2026-02-14 — Day 4: Web UI & Real-Time

- Read existing models, controllers, schema, and importmap to understand codebase state
- Modified `config/routes.rb` — added `root "status#index"` and `namespace :admin` with full CRUD routes for monitors, incidents, and nested incident_updates
- Pinned `chart.js/auto` via CDN in `config/importmap.rb`
- Updated `application.html.erb` — added `action_cable_meta_tag`, navbar/flash partials, restructured body
- Created ActionCable base files (`connection.rb`, `channel.rb`)
- Created 5 controllers: `StatusController`, `Admin::BaseController`, `Admin::MonitorsController`, `Admin::IncidentsController`, `Admin::IncidentUpdatesController`
- Created `StatusHelper` with badge helpers for status, severity, incident status, and overall status
- Created 4 shared/layout views: admin layout, public navbar, admin navbar, flash partial
- Created 4 status page views with Turbo Stream subscription for live updates
- Created 6 admin monitor views including Chart.js response time chart on show page
- Created 7 admin incident views with timeline, update form, and resolve action
- Created 2 Stimulus controllers: `chart_controller.js` (Chart.js), `flash_controller.js` (auto-dismiss)
- Deleted default `hello_controller.js`
- Added Turbo Stream broadcast callbacks to `SiteMonitor` (`after_update_commit` on status change) and `Incident` (`after_create_commit`, `after_update_commit`)
- Fixed `dom_id` error by including `ActionView::RecordIdentifier` in `SiteMonitor`
- Final result: **66 examples, 0 failures** — all existing specs still pass
- Total files created: ~30, modified: 5, deleted: 1

### 2026-02-14 — Day 5: Testing & Polish

- Added capybara, selenium-webdriver, sentry-ruby, sentry-rails to Gemfile
- Created Capybara support config with `rack_test` default driver (fast), `selenium_headless` for `:js` tagged tests
- Created 5 model spec files covering all models: associations, validations, enums, scopes, instance methods (37 examples)
- Created 3 admin request spec files covering status page, monitors CRUD, incidents CRUD + updates (25 examples)
- Created 2 Capybara system spec files for status page and admin monitor workflows (8 examples)
- Added `test` job to CI pipeline (`.github/workflows/ci.yml`): PostgreSQL 16 service, Ruby setup with bundler-cache, `db:schema:load`, `rspec`, coverage artifact upload
- Created `config/initializers/sentry.rb` with DSN via ENV, breadcrumbs logger, traces/profiles sampling
- Replaced placeholder README with professional docs: tech stack, prerequisites, setup, testing, Docker, API overview table, architecture diagram, linting/security commands
- Fixed 2 pre-existing view bugs discovered through testing: monitor form routing mismatch and incident update form double-wrapped array
- Fixed rubocop offenses: array bracket spacing in sentry initializer, named subject in site_monitor_spec, let! setup in notification_channel_spec
- Final result: **140 examples, 0 failures** — Line coverage 90.55%, Branch coverage 70.91%
- Total new files: 12 created, 4 modified (Gemfile, ci.yml, README, 2 view fixes)

---

## How to Test (Step by Step)

### Prerequisites

- Ruby (version in `.ruby-version`)
- PostgreSQL 16+ running locally
- Chrome/Chromium (only needed for system specs tagged `:js`)
- Redis (only needed for Sidekiq background jobs)

### 1. Install Dependencies

```bash
bundle install
```

### 2. Create and Migrate Database

```bash
bin/rails db:create
bin/rails db:migrate
```

For test database specifically:

```bash
RAILS_ENV=test bin/rails db:create
RAILS_ENV=test bin/rails db:schema:load
```

### 3. Run the Full Test Suite

```bash
bundle exec rspec
```

Expected: **140 examples, 0 failures** with line coverage >80%.

### 4. Run Tests by Category

```bash
# Model specs only
bundle exec rspec spec/models

# Request specs (API + admin)
bundle exec rspec spec/requests

# System specs (Capybara browser tests)
bundle exec rspec spec/system

# Jobs and services
bundle exec rspec spec/jobs spec/services
```

### 5. View Coverage Report

After running specs, open the HTML coverage report:

```bash
open coverage/index.html
```

### 6. Run Linter

```bash
bundle exec rubocop
```

### 7. Start the Server (Manual Testing)

```bash
# Start Rails + Tailwind CSS watcher
bin/dev
```

Then visit:
- Public status page: http://localhost:3000/
- Admin monitors: http://localhost:3000/admin/monitors
- Admin incidents: http://localhost:3000/admin/incidents
- API status: http://localhost:3000/api/v1/status

### 8. Start Background Jobs (Optional)

```bash
bundle exec sidekiq
```

This runs `ExecuteMonitorCheckJob` and `ScheduleMonitorChecksJob` for periodic health checks.
