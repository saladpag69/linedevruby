Rails.application.routes.draw do
  get "/cart", to: "cart#show"
  post "/cart/add"
  post "/cart/reomove"
  resources :services
  resources :products

  # root "services#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/aboutus.json", to: "application#about"
  get "/aboutus", to: "application#about"
  get "/login", to: "application#login"
  # routes.rb
  post "/webhook/line", to: "line_bot#callback"
  post "/supplier_line", to: "supplier_lines#create", as: :supplier_line
  resource :cart, only: [ :show ] do
    post :add, on: :collection
    post :remove, on: :collection
    post :clear, on: :collection
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root "siamcosmo#index"
  # root "application#about"

  get "/set_language", to: "siamcosmo#change_language"

  # Service pages
  get "/calculator", to: "calculator#index"
  get "/documents", to: "documents#index"
  get "/price", to: "price#index"
  get "/contractor", to: "contractor#index"
  get "/projects", to: "projects#index"
  get "/rental", to: "rental#index"
  get "/it", to: "it#index"

  # Calculator API
  post "/calculator/calculate_area", to: "calculator#calculate_area"
  post "/calculator/calculate_wall", to: "calculator#calculate_wall"
  post "/calculator/calculate_volume", to: "calculator#calculate_volume"
end
