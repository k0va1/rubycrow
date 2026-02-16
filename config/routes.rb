Rails.application.routes.draw do
  require "sidekiq/web"
  require "sidekiq-scheduler/web"

  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(username),
        Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_admin_name)) &&
        ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(password),
          Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq_admin_password))
    end
  end

  root "home#index"

  resources :subscribers, only: [:create]
  resources :articles, only: [:index]

  namespace :admin do
    mount Sidekiq::Web => "/sidekiq"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
