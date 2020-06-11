class RoundScore < ApplicationRecord
  belongs_to :game_participant
  belongs_to :round
end
