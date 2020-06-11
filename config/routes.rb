Rails.application.routes.draw do
  resources :games, only: [:index, :show, :create, :update] do
    resources :game_participants, only: [:create]
    resources :rounds, only: [:create]
  end
end
