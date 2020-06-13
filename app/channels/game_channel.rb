class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "games_#{params[:game_token]}"
  end
end
