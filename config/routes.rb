Rails.application.routes.draw do
  root 'home#index'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  devise_scope :user do
    get 'users/session', to: 'users/sessions#validate_session'
  end

  namespace :api do
    namespace :v0 do
      resources :pages, only: [:index, :show], format: :json do
        resources :versions, only: [:index, :show, :create]
        resources :changes,
          # Allow :id to be ":from_uuid..:to_uuid" or just ":change_id"
          constraints: { id: /(?:[\w\-]*\.\.[\w\-]+)|(?:[\w\-]+\.\.[\w\-]*)|(?:[^\.\/]+)/ },
          only: [:index, :show] do
            resources :annotations, only: [:index, :show, :create]
            member do
              get 'diff/:type', to: 'diff#show'
            end
        end
        resources :maintainers, except: [:new, :edit], format: :json
        resources :tags, except: [:new, :edit], format: :json
      end

      resources :versions, only: [:index, :show], format: :json
      resources :imports, only: [:create, :show], format: :json
      resources :maintainers, except: [:new, :edit, :destroy], format: :json
      resources :tags, except: [:new, :edit, :destroy], format: :json
    end
  end

  get 'admin', to: 'admin#index'
  post 'admin/invite'
  get 'admin/invite', to: redirect('admin')
  delete 'admin/cancel_invitation'
  post 'admin/cancel_invitation'
  delete 'admin/destroy_user'
  post 'admin/destroy_user'
  put 'admin/promote_user_to_admin'
  post 'admin/promote_user_to_admin'
  put 'admin/demote_user_from_admin'
  post 'admin/demote_user_from_admin'
  get 'healthcheck', to: 'healthcheck#index'
end
