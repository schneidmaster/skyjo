class GameParticipant < ApplicationRecord
  belongs_to :game

  has_many :round_boards
end
