Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Routing resources for authenthentication controller
  devise_for :users

  # Default routing
  root to: "profiles#index"

  # Profiles controller routing
  # Default profiles controller routing
  resources :profiles
  # Extended routing for profiles controller: search capability
  get "/search/best_match", to: "profiles#search_best_match", as: "search_best_match"
  get "/search/nearby", to: "profiles#search_nearby", as: "search_nearby"

  # user internal messaging routes
  get "messages/index"
  get "conversations/index"
  resources :conversations, only: [:index, :create] do
    resources :messages, only: [:index, :create]
  end

  # Blocklist routing
  resources :blocklists, only: [:index, :create, :destroy]
end
