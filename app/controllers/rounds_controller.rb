class RoundsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    game.lock!
    if game.rounds.none?
      game.rounds.create(round_number: 1)
      game.started!
      ActionCable.server.broadcast("games_#{game.token}", game)
    elsif game.rounds.all?(&:finished?)
      game.rounds.create(round_number: game.rounds.count + 1)
      ActionCable.server.broadcast("rounds_#{game.token}", game.rounds)
    end
  end
end
