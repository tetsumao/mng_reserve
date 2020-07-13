Rails.application.routes.draw do
  root "mng_reservations#status"
  get :login, to: 'sessions#new'
  resource :session, only: [:create, :destroy]
  resources :items
  resources :staffs
  resources :mng_reservations do
    collection do
      get :status
    end
  end
  resources :web_reservations, except: [:new, :create] do
    member do
      post :determination
    end
  end
  controller :rest_comm do
    post :rest_req, to: 'rest_comm#req'
  end
end
