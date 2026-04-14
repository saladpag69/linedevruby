Rails.application.routes.draw do
  # Devise authentication
  devise_for :users

  # Home - use home action
  root "siamcosmo#landing"
  get "home" => "siamcosmo#landing"
  get "landing" => "siamcosmo#landing"
  get "siamcosmo" => "siamcosmo#landing"
  get "siamcosmo/:id" => "siamcosmo#show", as: :service

  # Language
  get "/set_language" => "siamcosmo#set_language"
  get "/set_language/:locale" => "siamcosmo#set_language"

  # Chat
  get "/chat" => "chat#index"
  get "/chat/provider" => "chat#providers", as: :chat_providers
  get "/chat/contractor" => "chat#contractors", as: :chat_contractors
  get "/chat/transport" => "chat#transport", as: :chat_transport
  get "/chat/rental" => "chat#rental", as: :chat_rental
  get "/chat/documents" => "chat#documents", as: :chat_documents
  get "/chat/projects" => "chat#projects", as: :chat_projects
  get "/chat/:service_id" => "chat#index", as: :chat_service
  post "/chat" => "chat#create_message"
  post "/chat/calculate" => "chat#calculate"

  # Legacy routes (for now)
  get "/cart", to: "cart#show"
  post "/cart/add", to: "cart#add", as: :cart_add
  get "/products", to: "application#products"
  get "/aboutus.json", to: "application#about"
  get "/aboutus", to: "application#about"

  # Service Calculator (SiamCosmo)
  get "/calculator" => "calculator#quick", as: :calculator
  get "/calculator/step1" => "calculator#step1"
  get "/calculator/step2/:service_type_slug" => "calculator#step2", as: :calculator_step2
  post "/calculator/step3" => "calculator#step3", as: :calculator_step3
  post "/calculator/step4" => "calculator#step4", as: :calculator_step4
  get "/calculator/preview" => "calculator#preview", as: :calculator_preview
  get "/calculator/pdf/:id" => "calculator#pdf", as: :pdf_calculator
  post "/calculator/send_line/:id" => "calculator#send_line", as: :send_line_calculator

  # LINE Bot Webhook
  post "/line_bot/callback" => "line_bot#callback"

  # Legacy Calculator
  post "/calculator/calculate_area", to: "calculator#calculate_area"
  post "/calculator/calculate_wall", to: "calculator#calculate_wall"
  post "/calculator/calculate_volume", to: "calculator#calculate_volume"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # API - Baansiam Prices
  namespace :api do
    get "prices" => "prices#index"
  end
end
