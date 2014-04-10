Spree::Core::Engine.routes.draw do
  # Add your extension routes here

  resources :loyalty_points, only: [:index]

  namespace :admin do
    resources :users do
      resources :loyalty_points_transactions,  except: [:show]  do
        get 'order_transactions/:order_id', action: :order_transactions, on: :collection
      end
    end
  end

end
