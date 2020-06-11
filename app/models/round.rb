class Round < ApplicationRecord
  belongs_to :game
  belongs_to :game_participant
  has_many :round_boards
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
