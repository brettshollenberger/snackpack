Rails.application.routes.draw do
  devise_for :users

  root to: "home#index"

  devise_scope :user do
    get "login", to: "devise/sessions#new", :as => "login"
    get "logout", to: "devise/sessions#destroy", :as => "logout"
  end

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      resources :users, :only => [:index, :show]
    end
  end
end
