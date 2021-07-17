require "rails_helper"

RSpec.describe RoundDeck do
  context "#draw" do
    it "draws from initial deck" do
      deck = create(:round_deck)
      expect(deck.deck.count).to eq(145)
    end

    it "shuffles discard back to deck when last card is drawn" do
      round = create(:round)
      deck = create(:round_deck, round: round)
      current_discard = deck.deck.shift
      round.update(current_discard: current_discard)
      last_card = deck.deck.shift
      deck.update(deck: [last_card], discard: deck.deck + [current_discard])
      expect(deck.discard.length).to eq(144)

      card = deck.draw!
      expect(card).to eq(last_card)

      expect(deck.deck.count).to eq(143)
      expect(deck.discard.count).to eq(1)
      expect(deck.discard.last).to eq(current_discard)
    end
  end
end
