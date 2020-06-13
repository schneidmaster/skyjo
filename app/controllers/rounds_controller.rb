class RoundsController < ApplicationController
  def create
    game = Game.find_by(token: params[:game_id])
    if game.rounds.none?
      game.rounds.create(round_number: 1)
      game.started!
    else
      round = game.rounds.create(round_number: game.rounds.count + 1)
      ActionCable.server.broadcast("rounds_#{round.game.token}", round.as_json(include: :round_scores))
    end
    redirect_to game_path(game.token)
  end
end
