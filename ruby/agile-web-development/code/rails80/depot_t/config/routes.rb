#---
# Excerpted from "Agile Web Development with Rails 8",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/rails8 for more book information.
#---
Rails.application.routes.draw do
  get "admin" => "admin#index"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users
  resources :products
  resource :session
  resources :passwords, param: :token

  scope "(:locale)" do
    resources :orders
    resources :line_items
    resources :carts
    root "store#index", as: "store_index", via: :all
  end
end
