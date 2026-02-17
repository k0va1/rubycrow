# RubyCrow

A curated weekly newsletter for Ruby & Rails developers. Aggregates high-quality articles from 100+ Ruby community blogs and delivers them weekly to subscribers.

## Stack

- **Ruby 4.0.1 / Rails 8.1.2**
- **PostgreSQL** — primary database
- **Redis** — caching and job queue backend
- **Sidekiq** — background job processing with scheduler
- **Tailwind CSS 4** — via cssbundling-rails
- **esbuild** — via jsbundling-rails
- **Hotwire** — Turbo + Stimulus for real-time UI
- **Propshaft** — asset pipeline
- **Resend** — email delivery service

## Features

- **Blog Registry** — syncs from an external YAML registry of Ruby/Rails blogs, auto-discovers and tracks 100+ community sources
- **RSS Feed Parsing** — automatic feed syncing every 2 hours via Feedjira, with URL normalization and deduplication
- **Newsletter Issues** — editorial newsletter with 4 sections: Crow's Pick, Shiny Objects, Crow Call, Quick Gems
- **Link Tracking** — token-based click tracking with device detection, unique click counting, and per-issue analytics
- **Subscriber Management** — email signup via Turbo Stream, confirmed/unsubscribed status, signed unsubscribe links
- **Click Analytics** — IP-hashed uniqueness detection, device type classification, click-through rate calculation
- **Live Article Feed** — lazy-loaded via Turbo Frame on the landing page

## Getting Started

### Prerequisites

- Ruby 4.0.1
- Node.js (for esbuild/Tailwind)
- PostgreSQL
- Redis

### Local Services

```bash
docker-compose up -d  # Start PostgreSQL + Redis
```

### Setup

```bash
bundle install
bin/rails db:setup
yarn install
```

### Development

```bash
bin/dev  # Starts Rails server, CSS watcher, JS watcher, and Sidekiq
```

### Testing

```bash
bin/rails test           # Run all tests
bin/rails test:system    # System tests (Capybara + Chrome headless)
bundle exec standardrb   # Linting (Standard Ruby)
bin/brakeman             # Security scan
bin/bundler-audit        # Gem vulnerability check
```

## Background Jobs

| Job | Schedule | Description |
|---|---|---|
| `SyncBlogRegistryJob` | Every 6 hours | Syncs blog list from external YAML registry |
| `ParseRssFeedsJob` | Every 2 hours | Parses RSS feeds from all active blogs |
| `SendNewsletterJob` | Manual trigger | Sends newsletter issue to all active subscribers |
| `RecordClickJob` | On click event | Records and analyzes tracked link clicks |

Sidekiq admin dashboard is available at `/admin/sidekiq` (HTTP Basic Auth in production).

## Project Structure

```
app/
├── controllers/    # Home, Subscribers, Articles, Redirects, Unsubscribes
├── jobs/           # Newsletter sending, RSS parsing, blog sync, click recording
├── mailers/        # Newsletter mailer with HTML email template
├── models/         # Subscriber, Blog, Article, NewsletterIssue, TrackedLink, Click
├── javascript/
│   └── controllers/  # Stimulus: counters, scroll reveal, navbar, theme, live feed
└── views/          # ERB templates with Turbo Stream responses
data/
└── blogs.yml       # Blog registry (100+ Ruby/Rails blogs)
```

## CI/CD

GitHub Actions pipeline runs on every push:

- **scan_ruby** — Brakeman security scan + bundler-audit
- **lint** — Standard Ruby code style
- **test** — Minitest suite with PostgreSQL service
- **system-test** — Capybara system tests with headless Chrome

## Deployment

Docker-based deployment with a multi-stage build:

```bash
docker build -t rubycrow .
```

The Dockerfile produces a minimal runtime image exposing port 3000.
