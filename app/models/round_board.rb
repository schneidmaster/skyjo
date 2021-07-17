class RoundBoard < ApplicationRecord
  belongs_to :game_participant
  belongs_to :round

  before_create :fill_with_blanks

  def initial_sum
    board.flatten.reject { |cell| cell == 'X' }.reduce(:+) || 0
  end

  def completed_col
    (0...board[0].count).find do |col|
      uniq_cells = board.map { |row| row[col] }.uniq
      uniq_cells.count == 1 && uniq_cells.first != 'X'
    end
  end

  def remove_col!(col)
    board.each { |row| row.delete_at(col) }
    save
  end

  def all_cards_flipped?
    board.flatten.none? { |cell| cell == 'X' }
  end

  def initial_two_cards_flipped?
    board.flatten.reject { |cell| cell == 'X' }.count >= 2
  end

  def flip_card!(x, y)
    board[x][y] = round.round_deck.draw!
    save
  end

  private def fill_with_blanks
    blank_board = []

    3.times do
      row = []

      4.times do
        row << 'X'
      end

      blank_board << row
    end

    self.board = blank_board
  end
end
