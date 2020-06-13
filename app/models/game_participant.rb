class GameParticipant < ApplicationRecord
  belongs_to :game

  has_many :round_boards
  has_many :round_scores
end
