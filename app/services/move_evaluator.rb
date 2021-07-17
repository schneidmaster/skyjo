class MoveEvaluator
  attr_reader :board, :move_type, :coordinates
  delegate :game_participant, :round, to: :board
  delegate :game, to: :round

  Coordinates = Struct.new(:x, :y)

  def initialize(board:, params:)
    @board = board
    @move_type = params[:move_type].to_sym
    if [:initial_flip, :select_card].include?(move_type)
      @coordinates = Coordinates.new(params[:x], params[:y])
    end
  end

  def call
    case move_type
    when :initial_flip then initial_flip!
    when :draw_card then draw_card!
    when :draw_discard then draw_discard!
    when :discard_card then discard_card!
    when :select_card then select_card!
    end
  end

  private def initial_flip!
    return unless round.initial?
    return if board.initial_two_cards_flipped?

    board.flip_card!(coordinates.x, coordinates.y)
    ActionCable.server.broadcast("moves_#{round.game.token}", board)

    return unless round.round_boards.reload.all?(&:initial_two_cards_flipped?)

    round.in_progress!
    round.update(game_participant: round.round_boards.max_by(&:initial_sum).game_participant)
    ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)
  end

  private def draw_card!
    return unless round.game_participant == game_participant
    return unless round.move_initial?

    round.update(drawn_card: round.round_deck.draw!, move_state: :drawn_card)
    ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)
  end

  private def draw_discard!
    return unless round.game_participant == game_participant
    return unless round.move_initial?

    round.update(drawn_card: round.current_discard, current_discard: nil, move_state: :drawn_discard)
    ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)
  end

  private def discard_card!
    return unless round.game_participant == game_participant
    return unless round.drawn_card?

    round.update(drawn_card: nil, current_discard: round.drawn_card, move_state: :discarded_card)
    ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)
  end

  private def select_card!
    return unless round.game_participant == game_participant
    return if round.move_initial?

    if round.drawn_card? || round.drawn_discard?
      replace_card_on_board!
    elsif round.discarded_card?
      flip_card_on_board!
    end

    check_for_completed_column!

    if board.all_cards_flipped?
      round.end_round!(game_participant)
    else
      advance_turn!
    end
    ActionCable.server.broadcast("rounds_#{round.game.token}", game.rounds)
  end

  private def replace_card_on_board!
    old_value =
      if board.board[coordinates.x][coordinates.y] == 'X'
        round.round_deck.draw!
      else
        board.board[coordinates.x][coordinates.y]
      end
    board.board[coordinates.x][coordinates.y] = round.drawn_card
    board.save
    ActionCable.server.broadcast("moves_#{round.game.token}", board)
    round.update(drawn_card: nil, current_discard: old_value)
  end

  private def flip_card_on_board!
    board.board[coordinates.x][coordinates.y] = round.round_deck.draw!
    board.save
    ActionCable.server.broadcast("moves_#{round.game.token}", board)
  end

  private def check_for_completed_column!
    if (col = board.completed_col)
      round.update(current_discard: board.board[0][col])
      board.remove_col!(col)
      ActionCable.server.broadcast("moves_#{round.game.token}", board)
    end
  end

  private def advance_turn!
    participant_idx = game.game_participants.find_index { |part| part == game_participant }
    if participant_idx == game.game_participants.count - 1
      round.update(game_participant: game.game_participants.first)
    else
      round.update(game_participant: game.game_participants[participant_idx + 1])
    end
    round.move_initial!
  end
end
