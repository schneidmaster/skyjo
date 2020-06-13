class RoundBoard < ApplicationRecord
  belongs_to :game_participant
  belongs_to :round

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
end
