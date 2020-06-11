class RoundChannel < ApplicationCable::Channel
  def subscribed
    stream_from "rounds_#{params[:game_token]}"
  end
end
