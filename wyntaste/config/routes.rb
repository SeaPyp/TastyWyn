Rails.application.routes.draw do
  # Root
  root "sessions#new"

  # Session routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # User routes
  resources :users do
    collection do
      get :welcome_user
    end
  end

  # Wine routes
  resources :wines

  # Post routes with nested comments
  resources :posts do
    resources :comments, only: [:create, :destroy]
  end

  # Like/Unlike
  resources :likes, only: [:create, :destroy]

  # Follow/Unfollow
  resources :follows, only: [:create, :destroy]

  # Feed
  get "/feed", to: "feed#index"

  # Favorites
  get "/favorites", to: "favorites#index"

  # Recommendations
  get "/recommendations", to: "recommendations#index"

  # Learning Paths
  resources :learning_paths, only: [:index, :show]

  # Quizzes
  resources :quizzes, only: [:new, :create, :show]

  # Admin namespace
  namespace :admin do
    get "/analytics", to: "analytics#index"
    get "/analytics/drink_logs", to: "analytics#drink_logs"
    get "/analytics/login_events", to: "analytics#login_events"
    get "/analytics/user_activity", to: "analytics#user_activity"
    resources :archivals, only: [:index, :create] do
      member do
        post :restore
      end
    end
  end
end
