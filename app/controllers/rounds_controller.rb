class RoundsController < ApplicationController
  def create
    game = Game.find_by(token: params[:game_id])
    game.rounds.create(round_number: 1)
    game.started!
    redirect_to game_path(game.token)
  end
end
