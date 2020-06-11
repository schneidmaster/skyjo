class RoundBoard < ApplicationRecord
  belongs_to :game_participant
  belongs_to :round

  def initial_sum
    board.flatten.reject { |cell| cell == 'X' }.reduce(:+)
  end
end
