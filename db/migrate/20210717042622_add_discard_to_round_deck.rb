class AddDiscardToRoundDeck < ActiveRecord::Migration[6.0]
  def change
    change_table :round_decks do |t|
      t.json :discard, default: []
    end
  end
end
