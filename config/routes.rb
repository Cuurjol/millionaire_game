Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'users#index'

  devise_for :users

  resources :users, only: [:index, :show]

  resources :games, only: [:create, :show] do
    put 'answer', on: :member
    put 'take_money', on: :member
  end
end
