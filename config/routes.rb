Rails.application.routes.draw do
  # change default /user/action URLs for devise
  devise_for :users, path: '', path_names: { sign_in: 'signin', sign_out: 'signout', password: 'iforgot', confirmation: 'verification', unlock: 'unlock', registration: '', sign_up: 'signup' }

  # match on /page instead of the technically correct /pages/page
  # get 'pages/welcome'
  # get 'pages/about'
  match '/about', to: 'pages#about', via: 'get'
  match '/welcome', to: 'pages#welcome', via: 'get'

  # for the temporary resource
  resources :posts

  # fall through to root
  root 'pages#index'
end
