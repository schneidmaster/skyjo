class Round < ApplicationRecord
  belongs_to :game
  belongs_to :game_participant, optional: true
  has_many :round_boards
  has_many :round_scores
  has_one :round_deck

  enum state: {
    initial: 0,
    in_progress: 20,
    finished: 30,
  }

  enum move_state: {
    move_initial: 0,
    drawn_card: 10,
    drawn_discard: 20,
    discarded_card: 30,
  }

  after_create :create_round_deck, :create_boards, :set_initial_discard

  def as_json(**args)
    super(args.merge(include: [:round_boards, :round_scores]))
  end

  def end_round!(ending_participant)
    round_boards.each do |board|
      board.board.map! do |row|
        row.map! do |cell|
          if cell == 'X'
            round_deck.draw
          else
            cell
          end
        end
      end
      board.save

      ActionCable.server.broadcast("moves_#{game.token}", board)

      score = board.board.flatten.reduce(:+)
      round_scores.create(game_participant: board.game_participant, score: score)
    end

    min_score = round_scores.map(&:score).min
    ender_score = round_scores.find_by(game_participant: ending_participant)
    if ender_score.score > min_score
      ender_score.update(score: ender_score.score * 2)
    end

    finished!

    if game.game_participants.any? { |participant| participant.round_scores.map(&:score).reduce(:+) > 10 }
      game.finished!
      ActionCable.server.broadcast("games_#{game.token}", game)
    end
  end

  private

  def create_boards
    game.game_participants.each do |participant|
      board = []
      3.times do
        row = []

        4.times do
          row << 'X'
        end

        board << row
      end

      round_boards.create(game_participant: participant, board: board)
    end
  end

  def set_initial_discard
    update(current_discard: round_deck.draw)
  end
end
