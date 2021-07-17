class MovesController < ApplicationController
  def create
    round = Round.find(params[:round_id])
    game = round.game
    participant = GameParticipant.find(session[:participant_id])
    board = round.round_boards.find_by(game_participant: participant)

    case params[:move_type].to_sym
    when :initial_flip
      if round.initial? && board.board.flatten.reject { |cell| cell == 'X' }.count < 2
        board.board[params[:x]][params[:y]] = round.round_deck.draw!
        board.save
        ActionCable.server.broadcast("moves_#{round.game.token}", board)

        if round.round_boards.all? { |board| board.board.flatten.reject { |cell| cell == 'X' }.count == 2 }
          round.in_progress!
          round.update(game_participant: round.round_boards.max_by(&:initial_sum).game_participant)
          ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)
        end
      end

    when :draw_card
      return unless round.game_participant == participant && round.move_initial?
      round.update(drawn_card: round.round_deck.draw!, move_state: :drawn_card)
      ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)

    when :draw_discard
      return unless round.game_participant == participant && round.move_initial?
      round.update(drawn_card: round.current_discard, current_discard: nil, move_state: :drawn_discard)
      ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)

    when :discard_card
      return unless round.game_participant == participant && round.drawn_card?
      round.update(drawn_card: nil, current_discard: round.drawn_card, move_state: :discarded_card)
      ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)

    when :select_card
      return unless round.game_participant == participant
      return if round.move_initial?

      if round.drawn_card? || round.drawn_discard?
        old_value =
          if board.board[params[:x]][params[:y]] == 'X'
            round.round_deck.draw!
          else
            board.board[params[:x]][params[:y]]
          end
        board.board[params[:x]][params[:y]] = round.drawn_card
        board.save
        ActionCable.server.broadcast("moves_#{round.game.token}", board)
        round.update(drawn_card: nil, current_discard: old_value)
      elsif round.discarded_card?
        board.board[params[:x]][params[:y]] = round.round_deck.draw!
        board.save
        ActionCable.server.broadcast("moves_#{round.game.token}", board)
      end

      if (col = board.completed_col)
        round.update(current_discard: board.board[0][col])
        board.remove_col!(col)
        ActionCable.server.broadcast("moves_#{round.game.token}", board)
      end

      if board.board.flatten.none? { |cell| cell == 'X' }
        round.end_round!(participant)
      else
        participant_idx = game.game_participants.find_index { |part| part == participant }
        if participant_idx == game.game_participants.count - 1
          round.update(game_participant: game.game_participants.first)
        else
          round.update(game_participant: game.game_participants[participant_idx + 1])
        end
        round.move_initial!
      end
      ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)
    end
  end
end
