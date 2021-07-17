class RoundDeck < ApplicationRecord
  belongs_to :round

  before_create :shuffle_deck

  def draw
    card = deck.shift
    save
    card
  end

  private

  def shuffle_deck
    deck_array = []

    num_decks = (round.round_boards.count / 8).ceil

    num_decks.times do
      5.times { deck_array << -2 }

      (-1..12).each do |num|
        10.times { deck_array << num }
      end
    end

    self.deck = deck_array.shuffle
  end
end
