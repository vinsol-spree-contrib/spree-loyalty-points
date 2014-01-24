Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  resources :loyalty_points, only: [:index]

  namespace :admin do
    resources :users do
      resources :loyalty_points, only: [:index, :new, :create]
    end
  end

end
