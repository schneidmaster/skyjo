class RoundsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    participant = game.game_rounds.create(number: 1)
    game.started!
    redirect_to game_path(game.token)
  end
end
