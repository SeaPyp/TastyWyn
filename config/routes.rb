Rails.application.routes.draw do
  root 'users#new'

  # Sessions
  get    '/login'  => 'sessions#new'
  post   '/login'  => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  # Users
  resources :users do
    collection do
      get :welcome_user
      get :new_user_profile
    end
  end

  # Wines
  resources :wines

  # Posts with nested comments
  resources :posts do
    resources :comments, only: [:create, :destroy]
  end
end
