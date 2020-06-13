class GamesController < ApplicationController
  def index
    if params[:token]
      redirect_to game_path(params[:token])
    end
  end

  def show
    @game = Game.find_by(token: params[:id])
    @participant = @game.game_participants.find_by(id: session[:participant_id])
    redirect_to games_path unless @game.initial? || @participant
  end

  def create
    game = Game.create
    redirect_to game_path(game.token)
  end
end
