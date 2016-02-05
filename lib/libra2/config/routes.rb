Rails.application.routes.draw do

   resources :admin_catalog, only: 'index'

end