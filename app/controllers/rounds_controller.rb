class RoundsController < ApplicationController
  def create
    game = Game.find_by(token: params[:game_id])
    if game.rounds.none?
      game.rounds.create(round_number: 1)
      game.started!
    end
    redirect_to game_path(game.token)
  end
end
