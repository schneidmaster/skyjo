class MoveChannel < ApplicationCable::Channel
  def subscribed
    stream_from "moves_#{params[:game_token]}"
  end
end
