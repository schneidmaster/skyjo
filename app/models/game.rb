class Game < ApplicationRecord
  has_many :rounds

  enum state: {
    initial: 0,
    started: 5,
    finished: 10
  }
end
