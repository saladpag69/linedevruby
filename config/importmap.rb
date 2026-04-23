# Pin npm packages from CDN
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/dist/stimulus.js"

# Pin application entry point
pin "application", to: "application.js"

# Pin controllers
pin "controllers/calculator_controller", to: "controllers/calculator_controller.js"