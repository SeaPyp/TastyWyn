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

  # Posts
  get    'posts/new'      => 'posts#new'
  get    'posts/:id'      => 'posts#show',    as: :post
  post   'posts'          => 'posts#create'
  get    'posts/:id/edit' => 'posts#edit',    as: :edit_post
  patch  'posts/:id'      => 'posts#update'
  delete 'posts/:id'      => 'posts#destroy'

  # Comments (nested under posts)
  post   'posts/:post_id/comments'     => 'comments#create', as: :post_comments
  delete 'posts/:post_id/comments/:id' => 'comments#destroy', as: :post_comment
end
