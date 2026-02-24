# PulseWatch Rails - Master Documentation

**Last Updated:** 2026-02-24 11:00 | Branch: `main` | Commit: `ffb1c60`

---

## Version History

| Version | Date | Author | Branch / Commit | Summary |
|---------|------|--------|-----------------|---------|
| 1.0 | 2026-02-24 11:00 | Claude | `main` @ `ffb1c60` | Initial master documentation covering full system: models, controllers, API, services, jobs, frontend, Docker, and deployment. |

---

## Table of Contents

- [Part I: System Overview](#part-i-system-overview)
  - [1. Introduction](#1-introduction)
  - [2. Tech Stack](#2-tech-stack)
  - [3. Architecture](#3-architecture)
  - [4. Project Structure](#4-project-structure)
- [Part II: Database Layer](#part-ii-database-layer)
  - [5. Schema Overview](#5-schema-overview)
  - [6. Models & Relationships](#6-models--relationships)
  - [7. Enums Summary](#7-enums-summary)
  - [8. Indexes & Constraints](#8-indexes--constraints)
- [Part III: User-Facing Application](#part-iii-user-facing-application)
  - [9. Authentication](#9-authentication)
  - [10. Public Status Page](#10-public-status-page)
  - [11. Real-Time Updates](#11-real-time-updates)
- [Part IV: Admin Application](#part-iv-admin-application)
  - [12. Admin Dashboard](#12-admin-dashboard)
  - [13. Monitor Management](#13-monitor-management)
  - [14. Incident Management](#14-incident-management)
- [Part V: API Specification](#part-v-api-specification)
  - [15. API Overview](#15-api-overview)
  - [16. Monitors API](#16-monitors-api)
  - [17. Incidents API](#17-incidents-api)
  - [18. Status API](#18-status-api)
- [Part VI: Services & Background Jobs](#part-vi-services--background-jobs)
  - [19. Services](#19-services)
  - [20. Background Jobs](#20-background-jobs)
- [Part VII: Frontend](#part-vii-frontend)
  - [21. Layouts & Views](#21-layouts--views)
  - [22. Stimulus Controllers](#22-stimulus-controllers)
  - [23. Styling & Design System](#23-styling--design-system)
  - [24. View Helpers](#24-view-helpers)
- [Part VIII: Operations](#part-viii-operations)
  - [25. Docker Development Environment](#25-docker-development-environment)
  - [26. Production Deployment](#26-production-deployment)
  - [27. Testing](#27-testing)
  - [28. Security & Code Quality](#28-security--code-quality)
- [Part IX: Appendices](#part-ix-appendices)
  - [A. Environment Variables](#a-environment-variables)
  - [B. Routes Reference](#b-routes-reference)
  - [C. Gemfile Dependencies](#c-gemfile-dependencies)

---

# Part I: System Overview

## 1. Introduction

PulseWatch is a real-time uptime monitoring and status page application built with Ruby on Rails 8.1. It continuously checks the health of web services, tracks response times, manages incidents, and provides a public-facing status page with real-time updates via WebSockets.

### Key Features

- **Automated Health Checks** - HTTP monitoring with configurable intervals, methods, and expected status codes
- **Public Status Page** - Real-time system status with Turbo Streams
- **Incident Management** - Full lifecycle from investigation through resolution with timeline updates
- **Admin Dashboard** - Monitor CRUD, incident management, response time charts, uptime statistics
- **REST API** - JSON API (v1) for programmatic access to monitors, incidents, and status
- **Notification System** - Configurable channels (email, Slack, Discord, webhook) for alerts
- **Dark Mode** - Theme toggle with localStorage persistence

## 2. Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Ruby on Rails | 8.1.2 |
| Language | Ruby | 3.3.10 |
| Database | PostgreSQL | 16 |
| Cache/Queue | Redis | 7 |
| Background Jobs | Sidekiq + sidekiq-cron | - |
| Web Server | Puma | >= 5.0 |
| CSS Framework | Tailwind CSS | via tailwindcss-rails |
| JS Framework | Stimulus (Hotwire) | via stimulus-rails |
| Navigation | Turbo (Hotwire) | via turbo-rails |
| JS Modules | importmap-rails | - |
| Asset Pipeline | Propshaft | - |
| Charts | Chart.js | 4.4.7 (CDN) |
| Authentication | bcrypt | ~> 3.1.7 |
| Error Tracking | Sentry | sentry-ruby + sentry-rails |
| Deployment | Kamal + Thruster | - |
| Containerization | Docker | Multi-stage build |

## 3. Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Public Internet                       │
├──────────┬──────────────────┬───────────────────────────┤
│  Browser │   API Clients    │   Monitored Services      │
│  (Turbo) │   (JSON)         │   (HTTP targets)          │
└────┬─────┴────────┬─────────┴───────────┬───────────────┘
     │              │                     │
     ▼              ▼                     │
┌─────────────────────────┐               │
│     Rails Application   │               │
│  ┌───────────────────┐  │               │
│  │  Status Controller │  │               │
│  │  Sessions Controller│  │               │
│  │  Admin Controllers │  │               │
│  │  API v1 Controllers│  │               │
│  └────────┬──────────┘  │               │
│           │              │               │
│  ┌────────▼──────────┐  │               │
│  │  Models / Services │◄─┼───────────────┘
│  │  MonitoringService │  │  (HTTP checks)
│  │  IncidentManager   │  │
│  │  UptimeCalculator  │  │
│  └────────┬──────────┘  │
│           │              │
│  ┌────────▼──────────┐  │
│  │  Action Cable      │  │
│  │  (WebSockets)      │  │
│  └───────────────────┘  │
└───────────┬─────────────┘
            │
     ┌──────┴──────┐
     ▼              ▼
┌──────────┐  ┌──────────┐
│PostgreSQL│  │  Redis   │
│ (data)   │  │ (cache,  │
│          │  │  queues, │
│          │  │  cable)  │
└──────────┘  └────┬─────┘
                   │
              ┌────▼─────┐
              │ Sidekiq  │
              │ (jobs)   │
              └──────────┘
```

### Request Flow

1. **Public Status Page**: Browser → StatusController → Active monitors + incidents → Turbo Stream subscription
2. **Admin Dashboard**: Browser → SessionsController (auth) → Admin controllers → CRUD operations
3. **API**: Client → API::V1 controllers → JSON responses with pagination
4. **Health Checks**: Sidekiq cron (every minute) → ScheduleMonitorChecksJob → ExecuteMonitorCheckJob → MonitoringService → Check record → IncidentManager → Turbo Stream broadcast

## 4. Project Structure

```
pulse_watch_rails/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── status_controller.rb
│   │   ├── sessions_controller.rb
│   │   ├── admin/
│   │   │   ├── base_controller.rb
│   │   │   ├── monitors_controller.rb
│   │   │   ├── incidents_controller.rb
│   │   │   └── incident_updates_controller.rb
│   │   └── api/v1/
│   │       ├── base_controller.rb
│   │       ├── monitors_controller.rb
│   │       ├── incidents_controller.rb
│   │       └── statuses_controller.rb
│   ├── models/
│   │   ├── site_monitor.rb          (table: monitors)
│   │   ├── check.rb
│   │   ├── incident.rb
│   │   ├── incident_update.rb
│   │   ├── user.rb
│   │   └── notification_channel.rb
│   ├── views/
│   │   ├── layouts/                  (application, admin, mailer)
│   │   ├── shared/                   (navbar, admin_navbar, flash)
│   │   ├── status/                   (public status page)
│   │   ├── sessions/                 (login form)
│   │   └── admin/                    (monitors/, incidents/)
│   ├── javascript/controllers/       (Stimulus: flash, theme, chart)
│   ├── helpers/status_helper.rb      (badge helpers)
│   ├── jobs/                         (schedule, execute, notify)
│   └── services/                     (monitoring, uptime, incidents)
├── config/
│   ├── routes.rb
│   ├── database.yml
│   ├── cable.yml
│   ├── sidekiq.yml
│   └── initializers/                 (sidekiq, sentry)
├── db/schema.rb
├── docker-compose.yml
├── Dockerfile / Dockerfile.dev
├── Procfile.dev
└── Gemfile
```

---

# Part II: Database Layer

## 5. Schema Overview

PostgreSQL with UUID primary keys (pgcrypto extension). Schema version: `2026_02_22_180000`.

### Tables

| Table | Model | Primary Key | Description |
|-------|-------|------------|-------------|
| `users` | User | UUID | Admin users for authentication |
| `monitors` | SiteMonitor | UUID | Monitored services/URLs |
| `checks` | Check | UUID | Individual health check results |
| `incidents` | Incident | UUID | Service incidents |
| `incident_updates` | IncidentUpdate | UUID | Timeline entries for incidents |
| `incidents_monitors` | (join table) | Composite | Links incidents to affected monitors |
| `notification_channels` | NotificationChannel | UUID | Alert delivery configuration |

### Entity Relationship Diagram

```
User (no relationships)

SiteMonitor (monitors)
  ├── has_many :checks (dependent: :destroy)
  │   └── Check → belongs_to :site_monitor
  └── has_and_belongs_to_many :incidents
      └── Incident
          ├── has_many :incident_updates (dependent: :destroy)
          │   └── IncidentUpdate → belongs_to :incident
          └── has_and_belongs_to_many :site_monitors

NotificationChannel (no relationships)
```

## 6. Models & Relationships

### 6.1 User

**Table:** `users`

| Column | Type | Null | Default | Constraints |
|--------|------|------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | PK |
| `email` | string | NO | - | UNIQUE |
| `password_digest` | string | NO | - | - |
| `created_at` | datetime | NO | - | - |
| `updated_at` | datetime | NO | - | - |

**Authentication:** `has_secure_password` (bcrypt)

**Validations:**
- `email`: presence, uniqueness (case-insensitive), format (URI::MailTo::EMAIL_REGEXP)

### 6.2 SiteMonitor

**Table:** `monitors` (via `self.table_name = "monitors"`)

| Column | Type | Null | Default | Constraints |
|--------|------|------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | PK |
| `name` | string | NO | - | - |
| `url` | string | NO | - | Must be http/https |
| `http_method` | string | NO | "GET" | GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS |
| `expected_status` | integer | NO | 200 | 100-599 |
| `check_interval_seconds` | integer | NO | 300 | Minimum: 30 |
| `timeout_ms` | integer | NO | 5000 | 1000-30000 |
| `is_active` | boolean | NO | true | - |
| `current_status` | integer | NO | 0 | Enum: up(0), down(1), degraded(2) |
| `last_checked_at` | datetime | YES | - | - |
| `created_at` | datetime | NO | - | - |
| `updated_at` | datetime | NO | - | - |

**Associations:**
- `has_many :checks` (foreign_key: `monitor_id`, dependent: `:destroy`)
- `has_and_belongs_to_many :incidents` (join_table: `incidents_monitors`, foreign_key: `monitor_id`)

**Scopes:**
- `active` - `where(is_active: true)`
- `inactive` - `where(is_active: false)`

**Callbacks:**
- `after_update_commit :broadcast_status_change` - Broadcasts via Turbo Streams when `current_status` changes

**Methods:**
- `last_check` - Returns most recent check
- `determine_overall_status` - System-wide status based on monitors and incidents

### 6.3 Check

**Table:** `checks`

| Column | Type | Null | Default | Constraints |
|--------|------|------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | PK |
| `monitor_id` | uuid | NO | - | FK → monitors |
| `status_code` | integer | YES | - | - |
| `response_time_ms` | integer | YES | - | >= 0 |
| `successful` | boolean | NO | false | - |
| `error_message` | text | YES | - | - |
| `headers` | jsonb | NO | {} | - |
| `created_at` | datetime | NO | - | - |
| `updated_at` | datetime | NO | - | - |

**Associations:**
- `belongs_to :site_monitor` (foreign_key: `monitor_id`)

**Default Scope:** `order(created_at: :desc)`

**Scopes:**
- `successful` - `where(successful: true)`
- `failed` - `where(successful: false)`
- `recent(limit = 10)` - Newest N checks
- `in_time_range(from, to)` - Checks within date range

### 6.4 Incident

**Table:** `incidents`

| Column | Type | Null | Default | Constraints |
|--------|------|------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | PK |
| `title` | string | NO | - | - |
| `status` | integer | NO | 0 | Enum: investigating(0), identified(1), monitoring(2), resolved(3) |
| `severity` | integer | NO | 0 | Enum: minor(0), major(1), critical(2) |
| `resolved_at` | datetime | YES | - | - |
| `created_at` | datetime | NO | - | - |
| `updated_at` | datetime | NO | - | - |

**Associations:**
- `has_many :incident_updates` (dependent: `:destroy`)
- `has_and_belongs_to_many :site_monitors` (join_table: `incidents_monitors`, association_foreign_key: `monitor_id`)

**Scopes:**
- `active` - Status is NOT resolved
- `resolved` - Status IS resolved
- `recent(limit = 10)` - Newest N incidents

**Callbacks:**
- `after_create_commit :broadcast_new_incident` - Prepends to Turbo Stream
- `after_update_commit :broadcast_incident_change` - Replaces or removes from Turbo Stream

**Methods:**
- `resolve!` - Sets status to `:resolved`, `resolved_at` to `Time.current`

### 6.5 IncidentUpdate

**Table:** `incident_updates`

| Column | Type | Null | Default | Constraints |
|--------|------|------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | PK |
| `incident_id` | uuid | NO | - | FK → incidents |
| `status` | integer | NO | 0 | Enum: investigating(0), identified(1), monitoring(2), resolved(3) |
| `message` | text | NO | - | - |
| `created_at` | datetime | NO | - | - |
| `updated_at` | datetime | NO | - | - |

**Associations:**
- `belongs_to :incident`

**Default Scope:** `order(created_at: :desc)`

**Validations:**
- `message`: presence

### 6.6 NotificationChannel

**Table:** `notification_channels`

| Column | Type | Null | Default | Constraints |
|--------|------|------|---------|-------------|
| `id` | uuid | NO | gen_random_uuid() | PK |
| `channel_type` | integer | NO | 0 | Enum: email(0), slack(1), discord(2), webhook(3) |
| `config` | jsonb | NO | {} | - |
| `active` | boolean | NO | true | - |
| `created_at` | datetime | NO | - | - |
| `updated_at` | datetime | NO | - | - |

**Scopes:**
- `active` - `where(active: true)`

**Validations:**
- `channel_type`: presence
- `config`: presence

### 6.7 Join Table: incidents_monitors

| Column | Type | Constraints |
|--------|------|-------------|
| `incident_id` | uuid | FK → incidents, UNIQUE with monitor_id |
| `monitor_id` | uuid | FK → monitors |

## 7. Enums Summary

| Model | Attribute | Values |
|-------|-----------|--------|
| SiteMonitor | `current_status` | up (0), down (1), degraded (2) |
| Incident | `status` | investigating (0), identified (1), monitoring (2), resolved (3) |
| Incident | `severity` | minor (0), major (1), critical (2) |
| IncidentUpdate | `status` | investigating (0), identified (1), monitoring (2), resolved (3) |
| NotificationChannel | `channel_type` | email (0), slack (1), discord (2), webhook (3) |

## 8. Indexes & Constraints

### Indexes

| Table | Index | Columns | Unique |
|-------|-------|---------|--------|
| users | index_users_on_email | email | YES |
| monitors | index_monitors_on_is_active | is_active | NO |
| monitors | index_monitors_on_current_status | current_status | NO |
| checks | index_checks_on_created_at | created_at | NO |
| checks | index_checks_on_monitor_id | monitor_id | NO |
| checks | index_checks_on_monitor_id_and_created_at | monitor_id, created_at | NO |
| incidents | index_incidents_on_status | status | NO |
| incidents | index_incidents_on_severity | severity | NO |
| incident_updates | index_incident_updates_on_incident_id | incident_id | NO |
| incidents_monitors | index_incidents_monitors_on_incident_id_and_monitor_id | incident_id, monitor_id | YES |
| incidents_monitors | index_incidents_monitors_on_incident_id | incident_id | NO |
| incidents_monitors | index_incidents_monitors_on_monitor_id | monitor_id | NO |
| notification_channels | index_notification_channels_on_channel_type | channel_type | NO |
| notification_channels | index_notification_channels_on_active | active | NO |

### Foreign Keys

| From | Column | To | On Delete |
|------|--------|----|-----------|
| checks | monitor_id | monitors(id) | CASCADE |
| incident_updates | incident_id | incidents(id) | CASCADE |
| incidents_monitors | incident_id | incidents(id) | - |
| incidents_monitors | monitor_id | monitors(id) | - |

---

# Part III: User-Facing Application

## 9. Authentication

Session-based authentication using `has_secure_password` (bcrypt).

### Login Flow

1. `GET /login` → Renders login form (`sessions/new.html.erb`)
2. `POST /login` → Authenticates email/password
   - Success: Sets `session[:user_id]`, redirects to `/admin/monitors`
   - Failure: Returns 422 with flash alert
3. `DELETE /logout` → Clears `session[:user_id]`, redirects to `/login`

### Authorization

- `ApplicationController#current_user` - Loads user from `session[:user_id]`
- `ApplicationController#require_authentication` - Redirects to login if not authenticated
- `Admin::BaseController` applies `require_authentication` as `before_action`

## 10. Public Status Page

**Route:** `GET /` (root) → `StatusController#index`

Displays real-time system status without authentication:

- **Overall Status Banner** - Color-coded: operational (green), degraded (yellow), partial outage (orange), major outage (red)
- **Services List** - All active monitors with status indicators (up/down/degraded), URL, and last check time
- **Active Incidents** - Current incidents with severity, status, affected monitors, and update timeline

### Overall Status Logic

| Condition | Status |
|-----------|--------|
| Critical severity incidents | `major_outage` |
| Major severity incidents | `partial_outage` |
| Any down monitors or active incidents | `degraded` |
| Any degraded monitors | `degraded` |
| All clear | `operational` |

## 11. Real-Time Updates

Uses Turbo Streams over Action Cable for live updates on the public status page.

**Channel:** `monitor_status`

**Broadcast Triggers:**
- `SiteMonitor#after_update_commit` - When `current_status` changes, replaces monitor partial and overall status
- `Incident#after_create_commit` - Prepends new incident to active incidents list
- `Incident#after_update_commit` - Replaces or removes incident partial

**Cable Configuration:**
- Development: `async` adapter (in-process)
- Production: `solid_cable` (database-backed, 0.1s polling, 1-day message retention)

---

# Part IV: Admin Application

## 12. Admin Dashboard

All admin routes are under `/admin` namespace, use `admin` layout, and require authentication via `Admin::BaseController`.

**Navigation:**
- Monitors tab (`/admin/monitors`)
- Incidents tab (`/admin/incidents`)
- Status Page link (opens public page in new tab)
- Theme toggle
- User email display and sign-out button

## 13. Monitor Management

### Routes

| Method | Path | Action |
|--------|------|--------|
| GET | /admin/monitors | index |
| GET | /admin/monitors/new | new |
| POST | /admin/monitors | create |
| GET | /admin/monitors/:id | show |
| GET | /admin/monitors/:id/edit | edit |
| PATCH | /admin/monitors/:id | update |
| DELETE | /admin/monitors/:id | destroy |
| GET | /admin/monitors/:id/checks | checks (JSON) |

### Monitor Show Page

- Status, HTTP method, expected status, check interval, active toggle
- Uptime statistics: 24h, 7d, 30d, 90d (color-coded: >99.9% green, >99% yellow, <99% red)
- Response time chart (Chart.js, last 24 hours)
- Recent checks table (last 20): time, status code, response time, result

### Monitor Form Fields

| Field | Type | Default | Validation |
|-------|------|---------|------------|
| Name | text | - | Required |
| URL | url | - | Required, must be http/https |
| HTTP Method | select | GET | GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS |
| Expected Status | number | 200 | 100-599 |
| Check Interval (seconds) | number | 300 | Minimum: 30 |
| Timeout (ms) | number | 5000 | 1000-30000 |
| Active | checkbox | true | - |

## 14. Incident Management

### Routes

| Method | Path | Action |
|--------|------|--------|
| GET | /admin/incidents | index |
| GET | /admin/incidents/new | new |
| POST | /admin/incidents | create |
| GET | /admin/incidents/:id | show |
| GET | /admin/incidents/:id/edit | edit |
| PATCH | /admin/incidents/:id | update |
| PATCH | /admin/incidents/:id/resolve | resolve |
| POST | /admin/incidents/:incident_id/incident_updates | create update |

### Incident Index

- **Active Incidents** - Cards with title, severity/status badges, affected monitors
- **Recently Resolved** - Table of last 10 resolved incidents

### Incident Show Page

- Title with severity/status badges
- Action buttons: Resolve (if active), Edit, Back
- Info: started time, resolved time (or "Ongoing"), affected monitors
- Update form (if not resolved): message textarea, optional status change
- Timeline: all incident updates with status badges and timestamps

### Incident Form Fields

| Field | Type | Validation |
|-------|------|------------|
| Title | text | Required |
| Severity | select | minor, major, critical |
| Status | select | investigating, identified, monitoring, resolved |
| Affected Monitors | checkboxes | Optional, multiple selection |

---

# Part V: API Specification

## 15. API Overview

**Base URL:** `/api/v1`

All API endpoints return JSON. The base controller (`Api::V1::BaseController`) provides:

- **Error Handling:**
  - `ActiveRecord::RecordNotFound` → 404 `{ "error": "not found" }`
  - `ActiveRecord::RecordInvalid` → 422 `{ "errors": [...] }`
  - `ActionController::ParameterMissing` → 400 `{ "error": "param missing" }`

- **Pagination:** Supported via `page` and `per_page` query params (max 100 per page)

- **Response Format:**
```json
{
  "data": { ... },
  "meta": {
    "current_page": 1,
    "per_page": 25,
    "total_count": 100,
    "total_pages": 4
  }
}
```

## 16. Monitors API

### GET /api/v1/monitors

Lists all monitors with pagination.

**Query Parameters:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `per_page` | integer | 25 | Items per page (max 100) |

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "url": "string",
      "http_method": "GET",
      "expected_status": 200,
      "check_interval_seconds": 300,
      "timeout_ms": 5000,
      "is_active": true,
      "current_status": "up",
      "last_checked_at": "datetime"
    }
  ],
  "meta": { ... }
}
```

### GET /api/v1/monitors/:id

Returns a single monitor.

**Response:** `200 OK`

### POST /api/v1/monitors

Creates a new monitor.

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Monitor name |
| `url` | string | Yes | URL to monitor (http/https) |
| `http_method` | string | No | HTTP method (default: GET) |
| `expected_status` | integer | No | Expected status code (default: 200) |
| `check_interval_seconds` | integer | No | Check interval (default: 300, min: 30) |
| `timeout_ms` | integer | No | Timeout in ms (default: 5000) |
| `is_active` | boolean | No | Active state (default: true) |

**Response:** `201 Created`

### PATCH /api/v1/monitors/:id

Updates a monitor. Accepts same fields as create.

**Response:** `200 OK`

### DELETE /api/v1/monitors/:id

Deletes a monitor and all associated checks.

**Response:** `204 No Content`

### GET /api/v1/monitors/:id/checks

Returns check history for a monitor with pagination.

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": "uuid",
      "status_code": 200,
      "response_time_ms": 150,
      "successful": true,
      "error_message": null,
      "created_at": "datetime"
    }
  ],
  "meta": { ... }
}
```

### GET /api/v1/monitors/:id/uptime

Returns uptime statistics for all time periods.

**Response:** `200 OK`
```json
{
  "data": {
    "24h": 99.95,
    "7d": 99.80,
    "30d": 99.72,
    "90d": 99.65
  }
}
```

## 17. Incidents API

### GET /api/v1/incidents

Lists incidents with optional status filter and pagination.

**Query Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `status` | string | Filter by status (investigating, identified, monitoring, resolved) |
| `page` | integer | Page number |
| `per_page` | integer | Items per page |

### GET /api/v1/incidents/:id

Returns a single incident with updates.

### POST /api/v1/incidents

Creates a new incident.

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Incident title |
| `status` | string | No | Status (default: investigating) |
| `severity` | string | No | Severity (default: minor) |
| `monitor_ids` | array | No | Associated monitor UUIDs |

**Response:** `201 Created`

### PATCH /api/v1/incidents/:id

Updates an incident. Accepts same fields as create.

### PATCH /api/v1/incidents/:id/resolve

Marks an incident as resolved.

**Response:** `200 OK`

## 18. Status API

### GET /api/v1/status

Returns current system-wide status.

**Response:** `200 OK`
```json
{
  "data": {
    "overall_status": "operational",
    "monitors": [ ... ],
    "active_incidents": [ ... ]
  }
}
```

**Overall Status Values:** `operational`, `degraded`, `major_outage`, `unknown`

---

# Part VI: Services & Background Jobs

## 19. Services

### 19.1 MonitoringService

**File:** `app/services/monitoring_service.rb`

Executes HTTP health checks against monitored URLs.

**Constructor:** `MonitoringService.new(monitor)`

**Method:** `execute` → Returns `Result` struct:

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Whether response status matches expected |
| `status_code` | integer | HTTP status code received |
| `response_time_ms` | integer | Request duration in ms |
| `error_message` | string | Error description (nil if successful) |
| `headers` | hash | Response headers |

**Supported Methods:** GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS

**Error Handling:**
- `Net::OpenTimeout` / `Net::ReadTimeout` → Timeout error
- `SocketError` → Connection error
- `StandardError` → Generic error

### 19.2 UptimeCalculator

**File:** `app/services/uptime_calculator.rb`

Calculates uptime percentages for monitors.

**Constructor:** `UptimeCalculator.new(monitor_id)`

**Methods:**
- `calculate(period_key)` - Uptime for one period ("24h", "7d", "30d", "90d"). Returns float (0-100) rounded to 2 decimals, or nil if no data.
- `calculate_all` - Returns hash of all periods: `{ "24h" => 99.5, "7d" => 98.2, ... }`

**Formula:** `(successful_checks / total_checks) * 100`

### 19.3 IncidentManager

**File:** `app/services/incident_manager.rb`

Manages automatic incident lifecycle based on check results.

**Entry Point:** `IncidentManager.process_check_result(check)`

**Behavior:**
- Successful check → Handle recovery (resolve incidents, update monitor to "up")
- Failed check → Count consecutive failures, create/escalate incident if threshold reached

**Constants:**
- `CONSECUTIVE_FAILURES_THRESHOLD = 3`

**Severity Mapping:**

| Consecutive Failures | Severity |
|---------------------|----------|
| 3-5 | minor |
| 6-10 | major |
| 11+ | critical |

**Actions:**
- Creates incident: `"#{monitor.name} is down"`
- Escalates severity if failures increase
- Triggers `SendNotificationJob` on incident creation and recovery
- Updates monitor `current_status` accordingly

## 20. Background Jobs

### 20.1 ScheduleMonitorChecksJob

**Queue:** `critical` | **Cron:** `* * * * *` (every minute)

Iterates all active monitors and enqueues `ExecuteMonitorCheckJob` for those past their check interval.

**Due Logic:** `last_checked_at.nil? || last_checked_at <= check_interval_seconds.seconds.ago`

### 20.2 ExecuteMonitorCheckJob

**Queue:** `monitoring`

1. Finds monitor (discards if not found or inactive)
2. Calls `MonitoringService.new(monitor).execute`
3. Creates `Check` record with results
4. Updates `monitor.last_checked_at`
5. Calls `IncidentManager.process_check_result(check)`

### 20.3 SendNotificationJob

**Queue:** `notifications` | **Retry:** 3 attempts with polynomial backoff

1. Loads incident and all active notification channels
2. Delivers notification via each channel
3. Logs delivery failures without failing the job

**Note:** Current implementation logs notifications (placeholder for real delivery).

### Sidekiq Queue Configuration

| Queue | Priority | Purpose |
|-------|----------|---------|
| critical | 4 | Monitor scheduling |
| monitoring | 3 | Health checks |
| notifications | 2 | Alert delivery |
| default | 1 | Other jobs |

---

# Part VII: Frontend

## 21. Layouts & Views

### Layouts

| Layout | Used By | Features |
|--------|---------|----------|
| `application.html.erb` | Public pages (status, login) | Light/dark mode, Google Fonts (Outfit, IBM Plex Mono), favicon, footer |
| `admin.html.erb` | Admin pages | Same as application but with admin navbar |
| `mailer.html.erb` | Email templates | Minimal HTML structure |

**Common Head Elements:**
- Viewport meta for mobile
- CSRF and CSP meta tags
- Action Cable meta tag
- Google Fonts preconnect
- Favicon: `/icon.png` (PNG), `/icon.svg` (SVG), apple-touch-icon
- Tailwind CSS via `stylesheet_link_tag :app`
- JavaScript via `javascript_importmap_tags`
- Theme persistence script (localStorage)

**Footer:** "Powered by TimeSaver Systems" with link to https://adaptai.chat/en/about

### Shared Partials

| Partial | Purpose |
|---------|---------|
| `_navbar.html.erb` | Public navbar: logo, theme toggle, Admin link |
| `_admin_navbar.html.erb` | Admin navbar: logo, Monitors/Incidents tabs, Status Page link, theme toggle, user email, sign-out |
| `_flash.html.erb` | Flash messages: success (emerald), alert (rose), default (blue). Auto-dismiss after 5 seconds. |

### Status Page Views

| View | Description |
|------|-------------|
| `status/index.html.erb` | Main status page with Turbo Stream subscription, overall status, monitors list, active incidents |
| `status/_overall_status.html.erb` | Color-coded status banner with last-updated time |
| `status/_monitor.html.erb` | Individual monitor row with status dot, name, URL, last check time |
| `status/_incident.html.erb` | Incident card with severity, status, affected monitors, last 3 updates |

### Admin Views

**Monitors:** index (table), show (details + chart + checks), new/edit (form), `_form.html.erb`, `_check_row.html.erb`

**Incidents:** index (active cards + resolved table), show (details + update form + timeline), new/edit (form), `_form.html.erb`, `_update_form.html.erb`, `_incident_update.html.erb`

## 22. Stimulus Controllers

### flash_controller.js

Auto-dismisses flash messages after 5 seconds. Manual dismiss via close button.

- **Actions:** `flash#dismiss`
- **Lifecycle:** Sets timeout on connect, clears on disconnect

### theme_controller.js

Toggles dark/light mode with localStorage persistence.

- **Targets:** `icon` (sun/moon SVG)
- **Actions:** `theme#toggle`
- **Storage:** `localStorage.theme` (default: "dark")
- **Behavior:** Toggles `dark` class on `<html>` element for Tailwind dark mode

### chart_controller.js

Renders 24-hour response time chart using Chart.js.

- **Values:** `url` (String) - endpoint for check data
- **Targets:** `canvas` - Chart.js canvas element
- **Library:** Chart.js 4.4.7 (CDN via importmap)
- **Features:** Line chart with filled area, color-coded points (green=success, red=fail), dark mode colors, responsive, max 12 x-axis ticks

## 23. Styling & Design System

### Color Scheme

**Light Mode:**
- Background: `slate-50`
- Text: `gray-900`
- Borders: `gray-200`
- Accent: `indigo-600`

**Dark Mode:**
- Background: `#0a0a0f` (custom near-black)
- Text: `gray-100`
- Borders: `gray-800`
- Accent: `indigo-400`

### Status Colors

| Status | Color |
|--------|-------|
| UP / Operational | emerald-400/600 (green) |
| DOWN / Major Outage | rose-400/800 (red) |
| DEGRADED / Partial Outage | amber-400/800 (yellow) |

### Severity Colors

| Severity | Color |
|----------|-------|
| Critical | rose-600/900 |
| Major | orange-600/900 |
| Minor | amber-600/900 |

### Incident Status Colors

| Status | Color |
|--------|-------|
| Investigating | rose |
| Identified | orange |
| Monitoring | blue |
| Resolved | emerald |

### Typography

- **Body:** Outfit (300-700 weights)
- **Monospace:** IBM Plex Mono (400, 500 weights)
- Loaded via Google Fonts

### Component Classes

- `.card` - Container with background, border, rounded corners
- `.btn-primary` - Indigo action button
- `.btn-secondary` - Gray action button
- `.btn-success` - Green action button
- `.label-field` - Form label
- `.input-field` - Form input (text, select, textarea)

### Icons

All inline SVG, stroke-based, responsive sizing (w-4/h-4 or w-6/h-6), color inherited from parent.

## 24. View Helpers

### StatusHelper

| Method | Parameters | Returns |
|--------|-----------|---------|
| `status_badge(status)` | :up, :down, :degraded | Styled `<span>` with colored badge |
| `severity_badge(severity)` | :critical, :major, :minor | Styled `<span>` with colored badge |
| `incident_status_badge(status)` | :investigating, :identified, :monitoring, :resolved | Styled `<span>` with colored badge |
| `overall_status_class(status)` | :operational, :degraded, :partial_outage, :major_outage | Background color class string |
| `overall_status_text(status)` | Same as above | Human-readable status text |

---

# Part VIII: Operations

## 25. Docker Development Environment

### docker-compose.yml Services

| Service | Image | Ports | Purpose |
|---------|-------|-------|---------|
| postgres | postgres:16 | 5434:5432 | Database |
| redis | redis:7 | 6379:6379 | Cache, queues, cable |
| web | Dockerfile.dev | 3020:3000 | Rails application |
| sidekiq | Dockerfile.dev | - | Background job worker |

### Volumes

- `postgres_data` - PostgreSQL data persistence
- `redis_data` - Redis data persistence
- `bundle_data` - Bundler gem cache
- `.:/rails` - Application source (bind mount)

### Dockerfile.dev

- **Base:** `ruby:3.3.10-slim`
- **Packages:** build-essential, git, libpq-dev, libyaml-dev, pkg-config, curl, libjemalloc2, libvips, postgresql-client
- **Entrypoint:** `/rails/bin/docker-entrypoint`
- **CMD:** `./bin/rails server -b 0.0.0.0`

### Local Development (without Docker)

**Procfile.dev:**
```
web: bin/rails server
css: bin/rails tailwindcss:watch
worker: bundle exec sidekiq -C config/sidekiq.yml
```

## 26. Production Deployment

### Dockerfile (Production)

Multi-stage build:

1. **Base stage:** Install runtime packages, set jemalloc
2. **Build stage:** Install build deps, bundle gems, precompile bootsnap + assets
3. **Final stage:** Non-root user (`rails:rails`), copy from build stage

**CMD:** `./bin/thrust ./bin/rails server` (via Thruster for HTTP acceleration)
**Expose:** Port 80

### Kamal Deployment

Configured via `config/deploy.yml`. Orchestrates Docker image building, container deployment, and zero-downtime rollouts.

### Production Database Strategy

Multi-database setup:
- **primary** - Main application data
- **cache** - solid_cache database
- **queue** - solid_queue database
- **cable** - solid_cable WebSocket database

## 27. Testing

### Stack

| Tool | Purpose |
|------|---------|
| RSpec | Test framework |
| FactoryBot | Test data factories |
| Faker | Realistic fake data |
| shoulda-matchers | Model/controller matchers |
| Capybara + Selenium | Browser testing |
| SimpleCov | Code coverage |
| webmock | HTTP request stubbing |

### Running Tests

```bash
# Full suite
bundle exec rspec

# With Docker
docker compose exec web bundle exec rspec

# Specific directories
bundle exec rspec spec/models
bundle exec rspec spec/requests
```

## 28. Security & Code Quality

### Tools

| Tool | Purpose | Command |
|------|---------|---------|
| Brakeman | Static security analysis | `bin/brakeman --no-pager` |
| bundler-audit | Dependency vulnerability scan | `bin/bundler-audit` |
| RuboCop | Code style/quality | `bundle exec rubocop` |

### Filtered Parameters

Sensitive data filtered from logs: `passw`, `email`, `secret`, `token`, `_key`, `crypt`, `salt`, `certificate`, `otp`, `ssn`, `cvv`, `cvc`

### Credentials

Encrypted credentials in `config/credentials.yml.enc`, decrypted with `RAILS_MASTER_KEY`.

---

# Part IX: Appendices

## A. Environment Variables

### Development

| Variable | Default | Description |
|----------|---------|-------------|
| `RAILS_ENV` | development | Rails environment |
| `DB_HOST` | localhost | Database host |
| `DB_PORT` | 5434 | Database port |
| `DB_USERNAME` | pulse_watch | Database user |
| `DB_PASSWORD` | pulse_watch | Database password |
| `REDIS_URL` | redis://localhost:6379/0 | Redis connection URL |
| `RAILS_MASTER_KEY` | - | Credentials decryption key |

### Production

| Variable | Required | Description |
|----------|----------|-------------|
| `RAILS_ENV` | Yes | Must be "production" |
| `RAILS_MASTER_KEY` | Yes | Credentials decryption key |
| `PULSE_WATCH_DATABASE_PASSWORD` | Yes | Production database password |
| `REDIS_URL` | Yes | Redis connection URL |
| `SENTRY_DSN` | No | Sentry error tracking DSN |
| `SENTRY_TRACES_SAMPLE_RATE` | No | Trace sampling rate (default: 0.1) |
| `SENTRY_PROFILES_SAMPLE_RATE` | No | Profile sampling rate (default: 0.1) |

## B. Routes Reference

```
GET    /                                          → status#index (root)
GET    /login                                     → sessions#new
POST   /login                                     → sessions#create
DELETE /logout                                    → sessions#destroy
GET    /up                                        → rails/health#show

GET    /api/v1/monitors                           → api/v1/monitors#index
GET    /api/v1/monitors/:id                       → api/v1/monitors#show
POST   /api/v1/monitors                           → api/v1/monitors#create
PATCH  /api/v1/monitors/:id                       → api/v1/monitors#update
DELETE /api/v1/monitors/:id                       → api/v1/monitors#destroy
GET    /api/v1/monitors/:id/checks                → api/v1/monitors#checks
GET    /api/v1/monitors/:id/uptime                → api/v1/monitors#uptime
GET    /api/v1/incidents                           → api/v1/incidents#index
GET    /api/v1/incidents/:id                       → api/v1/incidents#show
POST   /api/v1/incidents                           → api/v1/incidents#create
PATCH  /api/v1/incidents/:id                       → api/v1/incidents#update
PATCH  /api/v1/incidents/:id/resolve               → api/v1/incidents#resolve
GET    /api/v1/status                              → api/v1/statuses#show

GET    /admin/monitors                             → admin/monitors#index
GET    /admin/monitors/new                         → admin/monitors#new
POST   /admin/monitors                             → admin/monitors#create
GET    /admin/monitors/:id                         → admin/monitors#show
GET    /admin/monitors/:id/edit                    → admin/monitors#edit
PATCH  /admin/monitors/:id                         → admin/monitors#update
DELETE /admin/monitors/:id                         → admin/monitors#destroy
GET    /admin/monitors/:id/checks                  → admin/monitors#checks
GET    /admin/incidents                             → admin/incidents#index
GET    /admin/incidents/new                         → admin/incidents#new
POST   /admin/incidents                             → admin/incidents#create
GET    /admin/incidents/:id                         → admin/incidents#show
GET    /admin/incidents/:id/edit                    → admin/incidents#edit
PATCH  /admin/incidents/:id                         → admin/incidents#update
PATCH  /admin/incidents/:id/resolve                 → admin/incidents#resolve
POST   /admin/incidents/:id/incident_updates        → admin/incident_updates#create
```

## C. Gemfile Dependencies

### Production

| Gem | Version | Purpose |
|-----|---------|---------|
| rails | ~> 8.1.2 | Web framework |
| propshaft | - | Asset pipeline |
| pg | ~> 1.1 | PostgreSQL adapter |
| puma | >= 5.0 | Web server |
| importmap-rails | - | JavaScript ESM imports |
| turbo-rails | - | Hotwire Turbo |
| stimulus-rails | - | Hotwire Stimulus |
| tailwindcss-rails | - | Tailwind CSS |
| bcrypt | ~> 3.1.7 | Password hashing |
| sidekiq | - | Background jobs |
| sidekiq-cron | - | Cron scheduling |
| sentry-ruby | - | Error tracking |
| sentry-rails | - | Rails Sentry integration |
| solid_cache | - | Database-backed cache |
| solid_queue | - | Database-backed job queue |
| solid_cable | - | Database-backed Action Cable |
| kamal | - | Deployment orchestration |
| thruster | - | HTTP acceleration |
| bootsnap | - | Boot time optimization |
| image_processing | ~> 1.2 | Active Storage processing |

### Development / Test

| Gem | Purpose |
|-----|---------|
| rspec-rails | Testing framework |
| factory_bot_rails | Test data factories |
| shoulda-matchers | Validation/association matchers |
| faker | Fake data generation |
| simplecov | Code coverage |
| webmock | HTTP request stubbing |
| capybara | Integration testing |
| selenium-webdriver | Browser automation |
| bundler-audit | Dependency auditing |
| brakeman | Security analysis |
| rubocop + plugins | Code quality |
| web-console | In-browser REPL |
| debug | Ruby debugger |
