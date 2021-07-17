class RoundDeck < ApplicationRecord
  belongs_to :round

  before_create :build_deck

  def draw!
    card = deck.shift

    if deck.none?
      current_discard = discard.pop
      self.deck = discard.shuffle
      self.discard = [current_discard]
    end

    save
    card
  end

  def discard!(card)
    self.discard << card
    save
  end

  private def build_deck
    deck_array = []

    num_participants = round.game.game_participants.count
    num_decks = (num_participants.to_f / 8).ceil

    num_decks.times do
      5.times { deck_array << -2 }

      (-1..12).each do |num|
        10.times { deck_array << num }
      end
    end

    self.deck = deck_array.shuffle
  end
end
