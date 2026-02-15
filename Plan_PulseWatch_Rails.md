**PulseWatch**

Open Source Status Page & Uptime Monitor

**Rails Edition**

Project Plan

Sergio Nader

February 2026

1\. PROJECT OVERVIEW

PulseWatch Rails is an open-source status page and uptime monitoring
system built idiomatically in Ruby on Rails. This version proves
expertise in the Rails ecosystem while implementing the same core
architecture as the Laravel version, demonstrating framework-agnostic
architectural thinking.

1.1 Project Goals

- Build a production-ready status page and uptime monitor in Rails

- Demonstrate Ruby and Rails proficiency alongside PHP expertise

- Show ability to implement consistent architecture across frameworks

- Establish comprehensive RSpec testing practices (\>80% coverage)

- Prove competence with Rails conventions and modern patterns

1.2 Why This Project

- **Broadens Job Prospects:** Demonstrates capability beyond
  PHP/Laravel, positioning for Ruby roles.

- **Framework Agility:** Same architecture proves thinking transcends
  specific technology stacks.

- **Testing Focus:** RSpec fills testing gaps from a Ruby perspective
  (model, service, request, system specs).

- **Production-Grade:** Uses Redis, Sidekiq, PostgreSQL,
  ActionCable---proving full-stack Rails maturity.

- **Real-Time Web:** Hotwire (Turbo + Stimulus) demonstrates modern
  Rails SPA capabilities.

2\. TECH STACK

  ------------------ -------------------- ------------- --------------------
  **Layer**             **Technology**     **Version**      **Purpose**

  Framework             Ruby on Rails          8.0           Full-stack
                                                             framework,
                                                          convention over
                                                               config

  Language                   Ruby              3.3      Interpreted language
                                                              runtime

  Frontend             Hotwire (Turbo +        8.0       Real-time SPA-like
                          Stimulus)                       behavior without
                                                              heavy JS

  Styling                Tailwind CSS          4.x       Utility-first CSS
                                                             framework

  API                   Rails API mode      built-in      RESTful JSON API
                                                             endpoints

  Background Jobs          Sidekiq             7.x      Reliable background
                                                           job processing

  Job Scheduling         Sidekiq-Cron        latest     Recurring scheduled
                                                          jobs (monitoring
                                                              checks)

  Database                PostgreSQL           16        Primary relational
                                                              database

  Cache/Queue               Redis              7.x        Cache layer and
                                                          Sidekiq backend

  Testing Framework         RSpec             3.13       BDD test framework

  Test Data               FactoryBot         latest     Clean, factory-based
                                                             test data

  E2E Testing        Capybara + Selenium     latest     System/browser tests

  Coverage                SimpleCov          latest        Code coverage
                                                             reporting

  Error Tracking         Sentry Ruby         latest       Production error
                                                             monitoring

  Request Profiling   rack-mini-profiler     latest         Performance
                                                            diagnostics

  Containerization     Docker + Compose      latest        Local dev and
                                                             deployment

  CI/CD                 GitHub Actions         \-        Automated testing
                                                            and linting
  ------------------ -------------------- ------------- --------------------

3\. ARCHITECTURE

3.1 Core Data Models

- Monitor -- has_many :checks, has_and_belongs_to_many :incidents

- Check -- belongs_to :monitor (records individual monitoring attempts)

- Incident -- has_many :incident_updates, has_and_belongs_to_many
  :monitors

- IncidentUpdate -- belongs_to :incident (public incident timeline)

- NotificationChannel -- polymorphic config (Email, Slack, Discord
  future)

3.2 REST API Design

> *Note: This version uses REST + JSON. GraphQL is reserved for the
> Laravel version.*

**Monitor Endpoints:**

- GET /api/v1/monitors -- List with pagination

- GET /api/v1/monitors/:id -- Show with recent checks

- POST /api/v1/monitors -- Create

- PATCH /api/v1/monitors/:id -- Update

- DELETE /api/v1/monitors/:id -- Soft delete

- GET /api/v1/monitors/:id/checks -- List checks (date range filter)

- GET /api/v1/monitors/:id/uptime -- Uptime stats (24h, 7d, 30d, 90d)

**Incident Endpoints:**

- GET /api/v1/incidents -- List incidents (paginated)

- POST /api/v1/incidents -- Create incident

- PATCH /api/v1/incidents/:id -- Update incident

- POST /api/v1/incidents/:id/updates -- Add public incident update

- PATCH /api/v1/incidents/:id/resolve -- Resolve incident

**Public Status Page:**

- GET /api/v1/status -- Public status page JSON (no auth)

- GET /health -- Health check endpoint

- GET /api/v1/monitors/:id/badge.svg -- Uptime badge (stretch feature)

3.3 Database Schema

**monitors table:**

- id (uuid), name, url, http_method (GET/POST), expected_status (default
  200)

- check_interval_seconds, timeout_ms, is_active (boolean)

- current_status (enum: up/down/degraded), last_checked_at, timestamps

**checks table:**

- id (uuid), monitor_id (indexed), status_code, response_time_ms,
  successful (boolean)

- error_message (nullable), headers (jsonb), created_at (indexed for
  fast range queries)

**incidents table:**

- id (uuid), title, status (enum:
  investigating/identified/monitoring/resolved)

- severity (enum: minor/major/critical), resolved_at, timestamps

**incident_updates table:**

- id (uuid), incident_id (indexed), status, message (public update
  text), created_at

**incidents_monitors (join table):**

- incident_id, monitor_id (composite primary key)

**notification_channels table:**

- id (uuid), channel_type (polymorphic), config (jsonb, encrypted
  at-rest)

- active (boolean), timestamps

3.4 Real-Time with Hotwire

- **Turbo Streams:** Live status updates on public status page (via
  ActionCable broadcasts).

- **Turbo Frames:** Inline editing of monitors and incidents without
  full page reload.

- **Stimulus Controllers:** Response time charts (Chart.js) with
  reactive data binding.

- **ActionCable:** Bidirectional WebSocket broadcasts from
  MonitorStatusChannel.

4\. FEATURE LIST

4.1 MVP Features (5-Day Sprint)

- Monitor CRUD (create, read, update, delete) with full REST API

- Sidekiq-Cron scheduled monitoring checks (configurable interval)

- Auto-incident creation on N consecutive check failures

- Public status page with Turbo Stream live updates

- Incident management with status workflow (investigating → resolved)

- Incident timeline with public updates

- JSON REST API v1 with versioning

- Email notifications via Action Mailer (incident created, resolved)

- Uptime calculation (24h, 7d, 30d, 90d percentages)

- Response time chart (Stimulus + Chart.js)

- Docker Compose for local development (app + postgres + redis +
  sidekiq)

- RSpec test suite with \>80% coverage target

- Capybara system tests (browser automation with Selenium)

- GitHub Actions CI pipeline (RuboCop, RSpec, coverage)

4.2 Stretch Features (Post-MVP)

- Slack/Discord notifications (Active Job + HTTP adapter)

- API token authentication (token_authenticatable gem or JWT)

- Rate limiting (Rack::Attack middleware)

- Custom status page themes (user-selectable color schemes)

- Maintenance windows (scheduled downtime exceptions)

- Health check: GET /health returns JSON status

- Badge endpoint: GET /api/v1/monitors/:id/badge.svg

- Webhook integrations (notify external systems on status change)

5\. PROJECT STRUCTURE

> pulsewatch-rails/
>
> ├── app/
>
> │ ├── channels/
>
> │ │ └── monitor_status_channel.rb \# ActionCable for live updates
>
> │ ├── controllers/
>
> │ │ ├── api/
>
> │ │ │ └── v1/
>
> │ │ │ ├── monitors_controller.rb
>
> │ │ │ ├── incidents_controller.rb
>
> │ │ │ └── status_controller.rb
>
> │ │ ├── monitors_controller.rb
>
> │ │ ├── incidents_controller.rb
>
> │ │ └── status_page_controller.rb
>
> │ ├── jobs/
>
> │ │ ├── execute_monitor_check_job.rb \# Sidekiq job for checks
>
> │ │ └── send_notification_job.rb \# Async notifications
>
> │ ├── mailers/
>
> │ │ └── monitor_mailer.rb
>
> │ ├── models/
>
> │ │ ├── monitor.rb
>
> │ │ ├── check.rb
>
> │ │ ├── incident.rb
>
> │ │ ├── incident_update.rb
>
> │ │ ├── notification_channel.rb
>
> │ │ └── concerns/ \# Shared behavior (Monitorable, etc)
>
> │ ├── serializers/
>
> │ │ ├── monitor_serializer.rb
>
> │ │ ├── check_serializer.rb
>
> │ │ └── incident_serializer.rb
>
> │ ├── services/
>
> │ │ ├── monitoring_service.rb \# HTTP checks, error handling
>
> │ │ ├── uptime_calculator.rb \# Math for uptime %
>
> │ │ └── incident_manager.rb \# State transitions
>
> │ ├── views/
>
> │ │ ├── status_page/
>
> │ │ │ ├── show.html.erb \# Public page with Turbo Streams
>
> │ │ │ └── \_monitor_row.html.erb
>
> │ │ ├── monitors/
>
> │ │ │ ├── index.html.erb
>
> │ │ │ ├── show.html.erb
>
> │ │ │ └── \_form.html.erb
>
> │ │ └── incidents/
>
> │ │ ├── index.html.erb
>
> │ │ ├── show.html.erb
>
> │ │ └── \_form.html.erb
>
> │ └── javascript/
>
> │ └── controllers/
>
> │ ├── chart_controller.js \# Chart.js with Stimulus
>
> │ └── clipboard_controller.js
>
> ├── config/
>
> │ ├── routes.rb
>
> │ ├── sidekiq.yml
>
> │ └── initializers/
>
> │ ├── sidekiq.rb
>
> │ └── sentry.rb
>
> ├── db/
>
> │ ├── migrate/
>
> │ │ ├── 001_create_monitors.rb
>
> │ │ ├── 002_create_checks.rb
>
> │ │ ├── 003_create_incidents.rb
>
> │ │ └── \...
>
> │ └── seeds.rb
>
> ├── spec/
>
> │ ├── models/
>
> │ │ ├── monitor_spec.rb
>
> │ │ ├── check_spec.rb
>
> │ │ └── incident_spec.rb
>
> │ ├── requests/
>
> │ │ ├── api/v1/monitors_spec.rb
>
> │ │ ├── api/v1/incidents_spec.rb
>
> │ │ └── api/v1/status_spec.rb
>
> │ ├── services/
>
> │ │ ├── monitoring_service_spec.rb
>
> │ │ ├── uptime_calculator_spec.rb
>
> │ │ └── incident_manager_spec.rb
>
> │ ├── jobs/
>
> │ │ └── execute_monitor_check_job_spec.rb
>
> │ ├── system/
>
> │ │ ├── status_page_spec.rb \# Capybara + Selenium
>
> │ │ └── monitors_crud_spec.rb
>
> │ ├── factories/
>
> │ │ ├── monitors.rb
>
> │ │ ├── checks.rb
>
> │ │ └── incidents.rb
>
> │ ├── support/
>
> │ │ └── shared_examples/
>
> │ └── rails_helper.rb
>
> ├── docker-compose.yml
>
> ├── Dockerfile
>
> ├── Gemfile
>
> ├── Procfile
>
> ├── .github/
>
> │ └── workflows/
>
> │ └── ci.yml
>
> ├── .rubocop.yml
>
> ├── README.md
>
> └── LICENSE

6\. TESTING STRATEGY

6.1 Model Specs (RSpec)

- Validations (presence, format, uniqueness)

- Associations (has_many, belongs_to, HABTM)

- Scopes (active monitors, recent checks, resolved incidents)

- State machines / enums (monitor status transitions, incident workflow)

- Monitor: test interval validation, status change logic

- Check: test success/failure detection, response_time capture

- Incident: test status workflow transitions and auto-resolution

6.2 Service Specs

- **MonitoringService:** HTTP execution, timeout handling, failure
  counting, retry logic

- **UptimeCalculator:** Percentage math, edge cases, time range queries,
  uptime rollover

- **IncidentManager:** Auto-create on failure, resolution, notification
  trigger, state updates

6.3 Request Specs (API)

- Full API endpoint testing (GET, POST, PATCH, DELETE)

- JSON response format verification (serializers)

- Pagination, filtering, sorting

- Error responses (404, 400, 422)

- Authorization (API token validation)

- Rate limiting responses

6.4 System Specs (Capybara + Selenium)

- Visit public status page, verify monitors render

- Create/edit/delete monitor through web interface

- Create/update/resolve incident

- Verify Turbo Stream updates work (WebSocket handshake)

- Verify response time chart renders with data

6.5 Job Specs

- ExecuteMonitorCheckJob: enqueues, executes, creates Check record

- SendNotificationJob: sends email, integrates with Mailer

6.6 CI Pipeline (GitHub Actions)

- RuboCop linting (\--format document \--fail-level F)

- RSpec with SimpleCov (\--format documentation)

- Coverage threshold: 80% minimum

- Capybara with headless Chrome (no GUI)

- DB migrate and seed before tests

- Matrix: PostgreSQL 16, Redis 7, Ruby 3.3

7\. RAILS-SPECIFIC PATTERNS & IDIOMS

7.1 Concerns (Shared Model Behavior)

> *Use Rails Concerns (app/models/concerns/) for DRY shared behaviors.*

- Monitorable: shared methods for status calculation, last_check

- Notifiable: shared notification dispatch logic

7.2 Service Objects (Business Logic)

> *Service objects keep models slim and testable. Avoid fat models.*

- MonitoringService handles HTTP execution, timeout, parsing

- UptimeCalculator separates uptime math from model logic

- IncidentManager orchestrates state transitions and side effects

7.3 Serializers (API Responses)

> *Use serializers (not jbuilder) for consistent API JSON structure.*

- MonitorSerializer: id, name, url, current_status, uptime_24h, etc

- IncidentSerializer: id, title, status, severity, updates (nested)

7.4 Sidekiq-Cron (Scheduled Jobs)

> *Schedule monitoring checks via Sidekiq-Cron, not system crontab.*

- ExecuteMonitorCheckJob enqueued per monitor\'s check_interval_seconds

- Stored in config/sidekiq.yml with cron syntax

7.5 ActionCable + Turbo Streams (Real-Time)

> *Combine ActionCable channels with Turbo Stream responses.*

- MonitorStatusChannel broadcasts status changes to subscribers

- Turbo Streams replace DOM elements without full reload

7.6 Strong Parameters + Form Objects

- Strong params in controllers for security

- Form objects (optional) for complex multi-step workflows

7.7 Database-Level Enums (Rails 7+ Style)

> *Use Rails enum for type safety: enum status: { up: 0, down: 1,
> degraded: 2 }*

- Scopes generated automatically (Monitor.up, Incident.resolved)

- Type validation at DB level

8\. DEPLOYMENT

8.1 Docker & Compose

> *docker-compose.yml orchestrates app, postgres, redis, sidekiq,
> sidekiq-web.*

- Dockerfile based on official Ruby image (ruby:3.3-slim)

- Multi-stage build: builder stage installs deps, app stage runs

- Volume mounts for development hot-reload

- environment: ENV variables for DB, Redis URLs, Sentry DSN

8.2 Procfile (Heroku Compatibility)

> *Procfile enables quick deployment to Heroku or similar PaaS.*

- web: bin/rails server -b 0.0.0.0

- worker: bundle exec sidekiq -c 5 -v

8.3 Health Check Endpoint

> *GET /health returns { \"status\": \"ok\", \"version\": \"1.0.0\",
> \"timestamp\": \"2026-02-14T\...\" }*

8.4 Configuration

- Rails credentials (config/credentials.yml.enc) for secrets

- ENV variables for 12-factor compliance

- DATABASE_URL, REDIS_URL, SENTRY_DSN, RAILS_MASTER_KEY

9\. GAPS FILLED

**✓** *Gap covered: Testing -- RSpec (\>80% coverage, model, service,
request, system specs)*

**✓** *Gap covered: Code Quality -- RuboCop linting, SimpleCov coverage
reporting*

**✓** *Gap covered: Observability -- Sentry error tracking,
rack-mini-profiler request diagnostics*

**✓** *Gap covered: Real-Time Web -- Hotwire (Turbo Streams +
ActionCable) for live updates*

**✓** *Gap covered: GitHub Visibility -- Public repo, professional
README, live demo URL*

***Note:***

> *GraphQL is NOT included in this Rails version. GraphQL fills a gap in
> the Laravel version. This Rails version uses REST + JSON.*

10\. 5-DAY IMPLEMENTATION TIMELINE

  --------- ------------------- --------------------------------
  **Day**        **Focus**            **Key Deliverables**

  1           Setup & Models         Rails new, DB schema,
                                migrations, 5 models, factories,
                                 docker-compose, models working
                                           in console

  2           Background Jobs          MonitoringService,
                                    ExecuteMonitorCheckJob,
                                    Sidekiq-Cron scheduler,
                                   auto-incident creation on
                                            failures

  3              REST API        API controllers, serializers,
                                  routes, full CRUD endpoints,
                                  status/uptime endpoints, API
                                         documentation

  4         Web UI & Real-Time    Public status page, Hotwire
                                     views, Turbo Streams,
                                ActionCable, charts (Stimulus +
                                 Chart.js), incident management

  5          Testing & Polish    RSpec suite (\>80% coverage),
                                   Capybara system tests, CI
                                pipeline, Sentry setup, README,
                                   deploy docs (half-day may
                                            suffice)
  --------- ------------------- --------------------------------

> *Bonus (if time permits): API token auth, rate limiting, Slack
> notifications, badge endpoint, healthcheck endpoint.*

11\. SUCCESS CRITERIA

- All 5 models defined with proper associations and validations

- Full REST API (v1) with JSON serialization and pagination

- Monitoring checks execute on schedule via Sidekiq-Cron

- Auto-incidents created on N consecutive failures

- Public status page with live Turbo Stream updates

- Incident management workflow (create, update, resolve, timeline)

- RSpec test suite with \>80% code coverage

- GitHub Actions CI passing (RuboCop, RSpec, coverage check)

- Docker Compose local development environment working

- Professional README with architecture diagram, setup instructions, API
  docs

- Live demo deployed and publicly accessible

12\. REFERENCES & RESOURCES

**Rails Guides:**

- https://guides.rubyonrails.org/

- https://guides.rubyonrails.org/api_app.html (Rails API mode)

**Gems & Libraries:**

- Hotwire (Turbo + Stimulus): https://hotwired.dev/

- Sidekiq: https://sidekiq.org/

- RSpec: https://rspec.info/

- Capybara: https://teamcapybara.github.io/capybara/

**Related Projects:**

- PulseWatch Laravel: GraphQL + REST API version
  (https://github.com/\...)

- Open Status Monitoring: Community inspiration
