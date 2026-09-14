Rails.application.routes.draw do
  get "admin" => "admin#index"

  resources :support_requests, only: %i[ index update ]

  resources :users
  resource :session
  resources :passwords, param: :token
  resources :products
  resources :coupons, only: %i[ index new create destroy ]

  scope "(:locale)" do
    resources :orders
    resources :line_items do
      member do
        patch :decrement
        patch :increment
      end
    end
    resources :carts

    # Constrained here rather than on the whole scope: without it, :locale
    # is any path segment at all, so a stub link like "/questions" matches
    # this root route with locale="questions" instead of 404ing, hitting
    # the store page with a "translation not available" flash instead of a
    # normal not-found error. Constraining the whole scope instead breaks
    # positional URL helpers on the other resources here (e.g. cart_url(cart)
    # mis-assigns the cart to :locale) -- keeping it on just this route avoids
    # that.
    root "store#index", as: "store_index", via: :all,
      constraints: { locale: Regexp.union(I18n.available_locales.map(&:to_s)) }
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
