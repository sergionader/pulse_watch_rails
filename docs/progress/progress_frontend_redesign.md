# Frontend Redesign — Dark Mode & Modern Minimalist UI (2026-02-22)

> **Last Updated:** 2026-02-22 19:17 EST

## Summary

Implemented a complete frontend redesign for PulseWatch Rails with a modern, minimalist aesthetic defaulting to dark mode. Added a theme toggle (dark/light) via Stimulus controller with localStorage persistence, Google Fonts (Outfit + IBM Plex Mono), Tailwind CSS component classes, and dark mode variants across all 20+ view files, helpers, and the Chart.js controller.

## Status: ✅ Complete

All views, partials, layouts, helpers, and JavaScript controllers have been updated with dark mode support and the new design system.

## Key Decisions

- **Dark mode strategy**: Tailwind `@custom-variant dark` with class-based toggling on `<html>` element
- **Default to dark**: `<html class="dark">` set by default, with inline FOUC-prevention script that reads localStorage before paint
- **Typography**: Google Fonts — **Outfit** for display/body, **IBM Plex Mono** for data/timestamps
- **Color palette**: Indigo-600/400 as primary accent, emerald for success states, rose for errors, amber for warnings
- **Component classes**: Created reusable `.card`, `.btn-primary`, `.btn-secondary`, `.input-field`, `.label-field` in Tailwind `@layer components`
- **Background**: Dark mode uses `#0a0a0f` (near-black) for depth; light mode uses `#f8fafc` (slate-50)
- **Admin navbar**: Always dark (gray-900/gray-950) regardless of theme, with pill-style active nav indicators
- **Theme toggle**: Sun/moon SVG icons that swap based on current mode, persisted to `localStorage`

## Changes Made

| File | Change |
|------|--------|
| `app/assets/tailwind/application.css` | Added `@custom-variant dark`, base layer styles, component classes (`.card`, `.btn-primary`, `.btn-secondary`, `.input-field`, `.label-field`, `.badge`, `.btn-success`) |
| `app/javascript/controllers/theme_controller.js` | Created — Stimulus controller for dark/light toggle with localStorage persistence, SVG icon swap |
| `app/views/layouts/application.html.erb` | Added `class="dark"` on `<html>`, Google Fonts preconnect/link, FOUC-prevention script, dark body classes |
| `app/views/layouts/admin.html.erb` | Added `class="dark"` on `<html>`, Google Fonts preconnect/link, FOUC-prevention script, dark body classes |
| `app/views/shared/_navbar.html.erb` | Redesigned with dark mode classes, theme toggle button with sun/moon icon |
| `app/views/shared/_admin_navbar.html.erb` | Redesigned with pill-style active nav, Status Page opens in new tab with external icon, theme toggle, user email + sign out |
| `app/views/shared/_flash.html.erb` | Updated with emerald/rose/blue dark variants using `dark:bg-*/20` transparency |
| `app/views/sessions/new.html.erb` | Redesigned login page with centered card, PulseWatch icon, dark mode classes |
| `app/views/status/index.html.erb` | Added `dark:` classes for headings, empty states |
| `app/views/status/_overall_status.html.erb` | Status banner with colored backgrounds (works in both modes) |
| `app/views/status/_monitor.html.erb` | Dark mode for monitor rows, IBM Plex Mono for timestamps, emerald/rose/amber status dots |
| `app/views/status/_incident.html.erb` | Dark mode for incident cards and timeline |
| `app/views/admin/monitors/index.html.erb` | Table with `.card`, dark headers, dark row dividers, indigo links |
| `app/views/admin/monitors/show.html.erb` | Stats grid with `.card`, dark table, dark chart container |
| `app/views/admin/monitors/new.html.erb` | Dark heading |
| `app/views/admin/monitors/edit.html.erb` | Dark heading |
| `app/views/admin/monitors/_form.html.erb` | Uses `.input-field`, `.label-field`, `.btn-primary`, `.btn-secondary`, dark error box |
| `app/views/admin/monitors/_check_row.html.erb` | Dark mode for check table rows |
| `app/views/admin/incidents/index.html.erb` | Active incident cards with `.card`, dark resolved table, emerald "no incidents" banner |
| `app/views/admin/incidents/show.html.erb` | Dark details card, dark timeline, dark update form |
| `app/views/admin/incidents/new.html.erb` | Dark heading |
| `app/views/admin/incidents/edit.html.erb` | Dark heading |
| `app/views/admin/incidents/_form.html.erb` | Uses `.input-field`, `.label-field`, dark error display, dark checkbox styling |
| `app/views/admin/incidents/_incident_update.html.erb` | Dark timeline entries with indigo icon |
| `app/views/admin/incidents/_update_form.html.erb` | Uses `.input-field`, `.label-field`, `.btn-primary` |
| `app/helpers/status_helper.rb` | All badge methods updated with `dark:` variants — emerald/rose/amber/orange/blue/gray |
| `app/javascript/controllers/chart_controller.js` | Added dark mode detection for grid colors, tick colors, title colors, fill opacity |

## Technical Details

### Theme System Architecture

1. **FOUC Prevention**: Inline `<script>` in `<head>` reads `localStorage.getItem("theme")` before first paint and applies `dark` class immediately
2. **Stimulus Controller** (`theme_controller.js`): Handles toggle clicks, updates `<html>` class, persists to localStorage, swaps SVG icons
3. **CSS Custom Variant**: `@custom-variant dark (&:where(.dark, .dark *))` enables `dark:` prefix classes throughout Tailwind
4. **Component Classes**: Defined in `@layer components` for consistency — buttons, cards, inputs all have built-in dark variants

### Color System

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Background | `#f8fafc` (slate-50) | `#0a0a0f` (near-black) |
| Cards | `bg-white` | `bg-gray-900` |
| Card borders | `border-gray-200` | `border-gray-800` |
| Primary text | `text-gray-900` | `text-gray-50/100` |
| Secondary text | `text-gray-500` | `text-gray-400` |
| Primary accent | `indigo-600` | `indigo-400` |
| Success | `emerald-100/800` | `emerald-900/30 + emerald-300` |
| Error | `rose-100/800` | `rose-900/30 + rose-300` |
| Warning | `amber-100/800` | `amber-900/30 + amber-300` |

### Fonts

- **Outfit** (Google Fonts) — Used for all headings and body text via `font-[Outfit]` on `<body>`
- **IBM Plex Mono** (Google Fonts) — Used for data display (timestamps, check intervals) via `font-['IBM_Plex_Mono']`

## Outstanding Tasks

- [ ] Rebuild Docker to see changes: `docker compose down -v --remove-orphans && docker volume prune -f && docker compose up --build`
- [ ] Verify visual appearance in browser at `http://localhost:3020`
- [ ] Run test suite to confirm no regressions: `docker compose exec web bundle exec rspec`

---

## Session Log

### 2026-02-22 19:17 EST

- User invoked `/frontend-design:frontend-design` with args: "modern and minimalist. Default to dark mode, but shows selector to toggling the modes."
- Created Tailwind CSS configuration with `@custom-variant dark` and reusable component classes
- Created `theme_controller.js` Stimulus controller for dark/light toggle with localStorage persistence
- Updated both layouts (`application.html.erb`, `admin.html.erb`) with Google Fonts (Outfit + IBM Plex Mono), FOUC-prevention inline script, and dark body classes
- Redesigned all 3 shared partials: navbar (theme toggle), admin navbar (pill nav, external status page link, theme toggle, user info), flash (emerald/rose/blue dark variants)
- Updated all 20+ view files across status pages, login, admin monitors, and admin incidents with dark mode `dark:` variant classes
- Updated `status_helper.rb` badge methods with dark mode color variants (emerald, rose, amber, orange, blue)
- Updated `chart_controller.js` with dark mode detection for grid, tick, and fill colors
- Verified all files post-completion — all views consistently use the new design system
