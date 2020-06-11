class ParticipantChannel < ApplicationCable::Channel
  def subscribed
    stream_from "participants_#{params[:game_token]}"
  end
end
