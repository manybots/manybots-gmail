ManybotsGmail::Engine.routes.draw do
  resources :gmail do
    member do 
      post  :import
      get   :list_folders
    end
    collection do
      get :callback
    end
  end
  
  root :to => 'gmail#index'
end
