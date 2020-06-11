class CreateRounds < ActiveRecord::Migration[6.0]
  def change
    create_table :rounds do |t|
      t.belongs_to :game
      t.belongs_to :game_participant

      t.integer :round_number
      t.integer :state, default: 0
      t.integer :move_state, default: 0
      t.integer :drawn_card
      t.integer :current_discard

      t.timestamps
    end
  end
end
