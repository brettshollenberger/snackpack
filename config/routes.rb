Rails.application.routes.draw do
  devise_for :users

  root to: "home#index"

  devise_scope :user do
    get "login", to: "devise/sessions#new", :as => "login"
    get "logout", to: "devise/sessions#destroy", :as => "logout"
  end

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      get :auth_token, to: "auth_tokens#show"

      resources :users, :only => [:index, :show]
      resources :recipients, :only => [:index, :show, :create, :update, :destroy]
      resources :templates, :only => [:index, :show, :create, :update, :destroy]
      resources :deliveries, :only => [:index, :show, :create, :destroy]
      resources :campaigns, :only => [:index, :show, :create, :update, :destroy]
    end
  end
end
