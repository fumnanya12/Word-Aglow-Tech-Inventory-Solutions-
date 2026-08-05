Rails.application.routes.draw do
  get "checkouts/show"
  get "orders/index"
  get "orders/show"
  get "carts/show"
  get "customer_profiles/show"
  get "customer_profiles/edit"
  devise_for :customers
  get "products/index"
  get "products/show"
  get "home/index"
  get "pages/show"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
  get "/about", to: "pages#about"
  get "/contact", to: "pages#contact"
  get "/products", to: "products#index"
  resources :products
  # Generic CMS pages
  get "/pages/:slug", to: "pages#show", as: :page


  resource :customer_profile,
          only: [ :show, :edit, :update ],
          controller: "customer_profiles"

  resource :cart, only: [ :show ]

resources :cart_items, only: [ :create, :update, :destroy ]
resource :checkout, only: [ :show, :create ]
resources :orders, only: [ :index, :show ]
resources :order_items
end
