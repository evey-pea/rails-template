Rails.application.routes.draw do
  resources :profiles
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "profiles#index"

  
  # user internal messaging routes
  get 'messages/index'
  get 'conversations/index'

  resources :conversations, only: [:index, :create] do
    resources :messages, only: [:index, :create]
  end
end
