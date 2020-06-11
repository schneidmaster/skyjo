class CreateRoundDecks < ActiveRecord::Migration[6.0]
  def change
    create_table :round_decks do |t|
      t.belongs_to :round

      t.json :deck

      t.timestamps
    end
  end
end
