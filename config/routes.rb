Rails.application.routes.draw do
  root to: 'games#index'
  
  resources :games, only: [:index, :show, :create] do
    resources :game_participants, only: [:create]
    resources :rounds, only: [:create] do
      resources :moves, only: [:create]
    end
  end
end
