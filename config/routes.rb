require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  root "home#index"

  resources :subscribers, only: [:create]
  resources :articles, only: [:index]

  get "/go/:token", to: "redirects#show", as: :tracked_redirect
  get "/unsubscribe/:signed_id", to: "unsubscribes#show", as: :unsubscribe
  get "/confirm/:signed_id", to: "confirmations#show", as: :confirm_subscription

  namespace :admin do
    root "dashboard#index"

    resource :session, only: [:new, :create, :destroy]

    resources :blogs
    resources :articles
    resources :newsletter_issues
    resources :subscribers
    resources :tracked_links
    resources :clicks, only: [:index, :show, :destroy]

    constraints(->(request) { request.session[:admin_authenticated] }) do
      mount Sidekiq::Web => "/sidekiq"
    end
  end

  get "up" => "rails/health#show", :as => :rails_health_check
end
