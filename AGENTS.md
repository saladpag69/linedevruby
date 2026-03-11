# AGENTS.md - Development Guide for This Rails Project

## Project Overview

This is a **Ruby on Rails 8.1.1** application integrated with **LINE Bot API** for e-commerce (shopping cart, products, orders). Uses SQLite3, Puma, Turbo/Stimulus for frontend, and Kamal for Docker deployment.

---

## Build / Lint / Test Commands

### Running the Application

```bash
# Start development server
bin/dev

# Run Rails console
rails console

# Run Rails server
rails server
```

### Running Tests

```bash
# Run all tests
rails test

# Run a single test file
rails test test/models/cart_test.rb

# Run a single test method
rails test test/models/cart_test.rb -n test_cart_exists
```

### Linting & Code Quality

```bash
# Run RuboCop (code style)
bundle exec rubocop

# Run RuboCop on specific file
bundle exec rubocop app/models/cart.rb

# Run security audit
bundle exec brakeman

# Run bundle audit for known gem vulnerabilities
bundle exec bundler-audit
```

### CI Commands

```bash
# Run CI pipeline (if configured)
bin/ci
```

### Database

```bash
# Setup database
rails db:setup

# Migrate database
rails db:migrate

# Reset database
rails db:reset
```

---

## Code Style Guidelines

This project uses **RuboCop Rails Omakase** style (the Rails team defaults). Key conventions:

### Formatting

- **2 spaces** for indentation (no tabs)
- **120 character** line length limit
- Use `bundle exec rubocop -a` to auto-fix many issues
- Empty lines should have no trailing whitespace

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Models | PascalCase, singular | `ActiveProduct`, `Cart` |
| Controllers | PascalCase, plural | `LineBotController`, `ServicesController` |
| Services | PascalCase | `MessageHandler`, `SupplierLineNotifier` |
| Database tables | snake_case, plural | `carts`, `orderables` |
| Methods | snake_case | `set_render_cart`, `trigger_supply_push` |
| Variables | snake_case | `@cart`, `chat_messages` |
| Constants | SCREAMING_SNAKE_CASE | `CHAT_MESSAGES_CACHE_KEY` |
| File names | snake_case.rb | `active_product.rb`, `line_bot_controller.rb` |

### Class Structure

```ruby
# app/models/example.rb
class Example < ApplicationRecord
  # Constants first
  DEFAULT_LIMIT = 10

  # Associations
  has_many :items

  # Validations
  validates :name, presence: true

  # Callbacks
  before_save :normalize_name

  # Class methods
  class << self
    def active
      where(active: true)
    end
  end

  # Instance methods
  def display_name
    name.titleize
  end

  private

  def normalize_name
    name.downcase!
  end
end
```

### Controller Structure

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # before_action / before_action filters
  before_action :set_render_cart

  # Public actions
  def index; end

  # Private methods (use private keyword)
  private

  def set_render_cart
    @render_cart = true
  end

  # Explicitly mark helper methods as private
  private :some_helper
end
```

### Error Handling

- Use `rescue StandardError => e` (not bare `rescue`)
- Always log errors with `Rails.logger.error`
- Return graceful fallbacks in controllers

```ruby
def about
  @products = ActiveProduct.search(@query)
rescue StandardError => e
  Rails.logger.error("Active product API failed: #{e.message}")
  @products = []
end
```

### Views & Helpers

- Use `.html.erb` for ERB templates
- Use `content_tag` for complex HTML, or plain HTML for simple cases
- Avoid inline styles; use Tailwind CSS classes if available

### Services / POROs

- Place in `app/services/`
- Use `call` method pattern for service objects: `MessageHandler.new(text).call`
- Use memoization for expensive operations: `@matcher ||= begin ... end`

### Models (ActiveRecord)

- Place in `app/models/`
- Use concerns for shared behavior in `app/models/concerns/`
- Use `ApplicationRecord` as base class

### Background Jobs

- Place in `app/jobs/`
- Use `perform_later` for async execution
- Example: `LinePushJob.perform_later(channel_id, message)`

### API Patterns

- Use `ActionController::API` for pure API controllers
- Return JSON with `render json:`
- Use status codes appropriately (200, 201, 400, 404, 500)

### Testing

- Use Rails Minitest (not RSpec)
- Place tests in `test/` directory
- Follow naming: `test/models/cart_test.rb` for `Cart` model
- Use fixtures in `test/fixtures/`

```ruby
# test/models/cart_test.rb
require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "cart exists" do
    cart = Cart.create
    assert cart.persisted?
  end
end
```

---

## Dependencies & Key Gems

| Gem | Purpose |
|-----|---------|
| `rails` 8.1.1 | Framework |
| `sqlite3` | Database |
| `line-bot-api` | LINE messaging |
| `openai` | AI integration |
| `jwt` | Authentication |
| `turbo-rails` | SPA navigation |
| `stimulus-rails` | JavaScript |
| `propshaft` | Asset pipeline |
| `puma` | Web server |
| `solid_cache/queue/cable` | Cache, jobs, action cable |

---

## Environment Variables

- LINE_CHANNEL_ID, LINE_CHANNEL_SECRET, LINE_ACCESS_TOKEN
- OPENAI_API_KEY
- DATABASE_URL (production)

Check `config/credentials.yml.enc` or `.env` files for secrets.

---

## Important File Locations

- Routes: `config/routes.rb`
- Database config: `config/database.yml`
- Application config: `config/application.rb`
- Environment configs: `config/environments/`
- LINE bot webhook: `app/controllers/line_bot_controller.rb`
- Jobs: `app/jobs/`
- Services: `app/services/`
- Models: `app/models/`

---

## General Tips

1. Run `bundle exec rubocop -a` before committing to auto-fix style issues
2. Use `rails routes` to see available routes
3. Use `rails db:migrate` after pulling changes
4. Check `log/` for application logs when debugging
5. The app uses Solid Queue for background jobs - check `tmp/sidekiq/` if jobs aren't running
