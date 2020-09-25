Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Blacklight::Engine => '/'
  
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users, controllers: {sessions: 'user/sessions'}, path: '/'
  
  mount Hydra::RoleManagement::Engine => '/'

  # get 'pages/:pageType', to: 'pages#index'
  # get 'help', to: 'pages#index'
  # get 'about', to: 'pages#index'

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  get '/user_mgmt/new', controller: 'users', to: 'users#new' 
  post '/user_mgmt/new', controller: 'users', to: 'users#create'
  get '/user_mgmt/edit/:user_id', controller: 'users', to: 'users#admin_edit' 
  patch '/user_mgmt/update', controller: 'users', to: 'users#admin_update'
  delete '/user_mgmt/delete/:user_id', controller: 'users', to: 'users#destroy' 
  get '/user_mgmt/pwd/:user_id', controller: 'users', to: 'users#admin_pwd' 
  patch '/user_mgmt/pwd_update', controller: 'users', to: 'users#admin_pwd_update'
  get '/user_mgmt/pwd_change/:user_id', controller: 'users', to: 'users#user_pwd_change' 
  patch '/user_mgmt/user_pwd_update', controller: 'users', to: 'users#user_pwd_update'
  get '/user_mgmt/active', controller: 'users', to: 'users#active_users' 
  get '/user_mgmt/download_report', controller: 'users', to: 'users#download_report' 
  get 'file_downloads/:id', to: 'file_downloads#show'
  get 'usage_reports/:reportType', to: 'usage_reports#index'
  get 'usage_reports_download/download_report', to: 'usage_reports#download_report'
  get 'search_history/', to: 'search_history#index'
  get 'search_history/download_report', to: 'search_history#download_report'
  get 'deposit_history/:type', to: 'deposit_history#index'
  get 'deposit_history/', to: 'deposit_history#index'
  get 'deposit_report/download_report', to: 'deposit_history#download_report'
  get 'collection_report/', to: 'collection_report#index'
  get 'collection_report/download_report', to: 'collection_report#download_report'
  get 'pages/:pageType', to: 'pages#index'

  # API routes
  scope '/api' do
    scope '/v1' do
      scope '/collections' do
        get '/findAll', controller: 'api/v1/collections', action: :findAll
      end
      scope '/generic_works' do
        get '/findAll', controller: 'api/v1/generic_works', action: :findAll
        get '/search', controller: 'api/v1/generic_works', action: :search
      end
    end
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
