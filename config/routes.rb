Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :api do
    namespace :v1 do
      resources :monitors, only: %i[index show create update destroy] do
        member do
          get :checks
          get :uptime
        end
      end

      resources :incidents, only: %i[index show create update] do
        member do
          patch :resolve
        end
      end

      resource :status, only: [:show]
    end
  end

  root "status#index"

  namespace :admin do
    resources :monitors do
      member do
        get :checks
      end
    end

    resources :incidents do
      member do
        patch :resolve
      end
      resources :incident_updates, only: [:create]
    end
  end
end
