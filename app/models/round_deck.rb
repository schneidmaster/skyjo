class RoundDeck < ApplicationRecord
  belongs_to :round

  before_create :shuffle_deck

  def draw
    if deck.none?
      self.deck = discard.shuffle
      self.discard = [deck.shift]
    end

    card = deck.shift
    save
    card
  end

  def discard_card(card)
    self.discard << card
    save
  end

  private

  def shuffle_deck
    deck_array = []

    num_decks = (round.game.game_participants.count.to_f / 8).ceil

    num_decks.times do
      5.times { deck_array << -2 }

      (-1..12).each do |num|
        10.times { deck_array << num }
      end
    end

    self.deck = deck_array.shuffle
  end
end
