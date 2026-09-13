Rails.application.routes.draw do
  get "admin" => "admin#index"

  resources :support_requests, only: %i[ index update ]

  resources :users
  resource :session
  resources :passwords, param: :token
  resources :products

  scope "(:locale)" do
    resources :orders
    resources :line_items do
      member do
        patch :decrement
      end
    end
    resources :carts
    root "store#index", as: "store_index", via: :all
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
