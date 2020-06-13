class Game < ApplicationRecord
  has_many :game_participants
  has_many :rounds

  enum state: {
    initial: 0,
    started: 5,
    finished: 10
  }

  before_create :set_token

  def as_json(**args)
    super(args.merge(include: { game_participants: {}, rounds: { include: [:round_boards, :round_scores] } }))
  end

  private

  def set_token
    self.token = SecureRandom.hex(3)
  end
end
