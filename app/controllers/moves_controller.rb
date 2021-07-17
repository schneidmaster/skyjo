class MovesController < ApplicationController
  def create
    participant = GameParticipant.find(session[:participant_id])
    board = round.round_boards.find_by(game_participant: participant)
    evaluator = MoveEvaluator.new(
      board: board,
      params: params.slice(:move_type, :x, :y)
    )
    evaluator.call
  end
end
