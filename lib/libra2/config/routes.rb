Rails.application.routes.draw do

  namespace :admin do
     resources :catalog, only: 'index'
  end

end