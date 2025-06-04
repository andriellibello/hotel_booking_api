Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  get "up" => "rails/health#show", as: :rails_health_check
  resources :rooms, only: [:index, :show]
  resources :reservations, only: [:create, :index, :show]
  resources :reservations do
    put :cancel, on: :member
  end
  get "available_rooms", to: "rooms#available"
end
