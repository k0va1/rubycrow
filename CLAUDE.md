# RubyCrow

A curated weekly newsletter for Ruby & Rails developers.

## Stack

- Ruby 4.0.1, Rails 8.1.2
- PostgreSQL, Redis, Sidekiq
- Tailwind CSS 4 (via cssbundling-rails), esbuild (via jsbundling-rails)
- Hotwire (Turbo + Stimulus)
- Propshaft (asset pipeline)
- Lightning Rails template

## Development

```bash
bin/dev          # Start dev server (Procfile.dev: rails, css, js)
bin/rails test   # Run all tests
```

## Testing

- Minitest (not RSpec)
- Test files live in `test/`
- Controller tests are integration tests (`ActionDispatch::IntegrationTest`)
- Fixtures for test data (`test/fixtures/`)
- WebMock enabled, net connections disabled except localhost
- Mocha for mocking (`mocha/minitest`)

## Code Style

- Standard Ruby for linting (`bundle exec standardrb`)
- No ActiveStorage in this project — don't reference it
- Turbo Stream responses for form submissions
- Forms use `form_id` param to support multiple forms on one page

## Project Structure

- `app/views/home/index.html.erb` — Landing page (single-page design)
- `app/controllers/subscribers_controller.rb` — Email signup via Turbo Stream
- `app/views/subscribers/_form.html.erb` — Reusable subscribe form partial
- `app/assets/stylesheets/application.tailwind.css` — Custom theme and animations
- `app/javascript/controllers/` — Stimulus controllers

## Design System

- Fonts: Instrument Serif (display), DM Sans (body)
- Colors: crow-dark (#060506), ruby (#9B1B30), gold (#C9A84C), crow-sand (#c8bfa9)
- Dark editorial aesthetic with grain texture overlay
- CSS classes: `font-display`, `font-body`, `editorial-card`, `subscribe-input`, `subscribe-btn`, `divider-gold`, `section-label`, `social-link`

### IMPORTANT NOTES

- DO NOT GENERATE DOCUMENTATION UNLESS THE USER SPECIFICALLY ASKS FOR IT!
- ALWAYS USE `<%# locals: (field1:, field2:) -%>` style for erb templates when passing local variables
- DON'T ADD `<script>` TAGS DIRECTLY IN ERB FILES! ALWAYS USE STIMULUS CONTROLLERS FOR JAVASCRIPT FUNCTIONALITY!
- When creating a new Stimulus controller in `app/javascript/controllers/`, you MUST register it in `app/javascript/controllers/index.js`
- For commits use conventional commit messages: https://www.conventionalcommits.org/en/v1.0.0/
- DO NOT add Claude-related footers to commit messages (no "Generated with Claude Code", no "Co-Authored-By: Claude")
- DON'T USE TABS, USE SPACES FOR INDENTATION!
- DON'T WRITE ANY COMMENTS IN THE CODE THAT DESCRIBE THE CODE!!!! WRITE COMMENTS ONLY IF I ASK FOR THEM!
- Turbo Stream for all form submissions (no full page reloads)
