class GameParticipantsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    participant = game.game_participants.create(participant_params)
    session[:participant_id] = participant.id
    ActionCable.server.broadcast("participants_#{game.token}", participant)
    render json: participant
  end

  private

  def participant_params
    params.require(:game_participant).permit(:name)
  end
end
