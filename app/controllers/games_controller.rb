class GamesController < ApplicationController
  def index; end

  def show
    @game = Game.find_by(token: params[:id])
    @participant = GameParticipant.find_by(id: session[:participant_id])
    redirect_to games_path unless @game.initial? || @participant
  end

  def create
    game = Game.create
    redirect_to game_path(game.token)
  end

  def update
    game = Game.find_by(token: params[:id])

    if params[:start_game]
      game.started!
    end

    redirect_to game_path(game.token)
  end
end
