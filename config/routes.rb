Rails.application.routes.draw do
 get '/searches/suggestions', to: 'searches#suggestions'
  post '/searches', to: 'searches#create'

  resources :searches, only: %i[index create]
  root 'searches#index'
end
