Rails.application.routes.draw do
  # Devise authentication
  devise_for :users

  # Home - use home action
  root "siamcosmo#home"
  get "home" => "siamcosmo#landing"
  get "landing" => "siamcosmo#landing"
  get "siamcosmo" => "siamcosmo#landing"
  get "siamcosmo/:id" => "siamcosmo#show", as: :service

  # Language
  get "/set_language" => "siamcosmo#set_language"
  get "/set_language/:locale" => "siamcosmo#set_language"

  # Chat
  get "/chat" => "chat#index"
  get "/chat/:service_id" => "chat#index", as: :chat_service
  post "/chat" => "chat#create_message"
  post "/chat/calculate" => "chat#calculate"

  # Legacy routes (for now)
  get "/cart", to: "cart#show"
  get "/aboutus.json", to: "application#about"
  get "/aboutus", to: "application#about"

  # Calculator
  get "/calculator" => "calculator#index"
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
