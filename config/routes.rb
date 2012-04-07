ManybotsGmail::Engine.routes.draw do
  resources :emails do
    member do
      get 'from_gmail'
    end
  end
  
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
