Rails.application.routes.draw do

  # libra-etd specific endpoints

  get 'logout' => 'dashboard#logout'
  #get 'development_login' => 'dashboard#development_login' # TODO-PER: Temp route to get login working quickly.
  get "/test_exception_notifier" => "dashboard#test_exception_notifier"
  get "/test_email" => "dashboard#test_email"
  get '/public_view/:id' => 'submission#public_view'
  post '/submit/:id' => 'submission#submit'
  get '/public_view/:id/unpublish' => 'submission#unpublish'
  get '/computing_id' => 'dashboard#computing_id'
  get '/orcid_search' => 'dashboard#orcid_search'

  # health check and version endpoints
  resources :healthcheck, only: [ :index ]
  resources :version, only: [ :index ]

  # api work endpoints
  get '/api/v1/works' => 'api_v1_works#all_works', :defaults => { :format => 'json' }
  get '/api/v1/works/search' => 'api_v1_works#search_works', :defaults => { :format => 'json' }
  get '/api/v1/works/:id' => 'api_v1_works#get_work'
  delete '/api/v1/works/:id' => 'api_v1_works#delete_work'
  put '/api/v1/works/:id' => 'api_v1_works#update_work'

  # api fileset endpoints
  get '/api/v1/filesets' => 'api_v1_filesets#all_filesets', :defaults => { :format => 'json' }
  get '/api/v1/filesets/:id' => 'api_v1_filesets#get_fileset'
  delete '/api/v1/filesets/:id' => 'api_v1_filesets#remove_fileset'
  post '/api/v1/filesets' => 'api_v1_filesets#add_fileset'
  put '/api/v1/filesets/:id' => 'api_v1_filesets#update_fileset'

  # api file endpoints
  match '/api/v1/files' => 'api_v1_files#add_file_options', via: :options
  post '/api/v1/files' => 'api_v1_files#add_file'

  # api download endpoints
  get '/api/v1/downloads/:id/content' => 'api_v1_downloads#get_content'
  get '/api/v1/downloads/:id/thumbnail' => 'api_v1_downloads#get_thumbnail'

  # api options endpoints
  get '/api/v1/options/degrees' => 'api_v1_options#degrees'
  get '/api/v1/options/departments' => 'api_v1_options#departments'
  get '/api/v1/options/embargos' => 'api_v1_options#embargos'
  get '/api/v1/options/languages' => 'api_v1_options#languages'
  get '/api/v1/options/rights' => 'api_v1_options#rights'

  # api audit endpoints
  get '/api/v1/audit/work/:id' => 'api_v1_audit#by_work', :defaults => { :format => 'json' }
  get '/api/v1/audit/user/:id' => 'api_v1_audit#by_user', :defaults => { :format => 'json' }
  get '/api/v1/audit' => 'api_v1_audit#search', :defaults => { :format => 'json' }

  concern :exportable, Blacklight::Routes::Exportable.new
  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  Hydra::BatchEdit.add_routes(self)
  mount Qa::Engine => '/authorities'

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_scope :user do
    get "/users/sign_up", to: redirect('/404')
    post "/users", to: redirect('/404')

    get "/login" => "users/sessions#new"

    # used only to prevent errors in development.
    # netbadge will catch this path in prod
    get "/logout", to: "users/sessions#new"
  end

  devise_for :users, controllers: { sessions: 'users/sessions' }
  
  mount CurationConcerns::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'dashboard#index'
  curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  namespace 'orcid' do
    get :landing
    delete :destroy
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  mount Sufia::Engine, at: '/'

end
