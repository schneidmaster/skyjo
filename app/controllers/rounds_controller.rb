class RoundsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    if game.rounds.none?
      game.rounds.create(round_number: 1)
      game.started!
      ActionCable.server.broadcast("games_#{game.token}", game)
    else
      round = game.rounds.create(round_number: game.rounds.count + 1)
      ActionCable.server.broadcast("rounds_#{round.game.token}", round.as_json(include: :round_scores))
    end
  end
end
