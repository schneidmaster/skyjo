class CreateRounds < ActiveRecord::Migration[6.0]
  def change
    create_table :rounds do |t|
      t.belongs_to :game
      t.integer :round_number

      t.timestamps
    end
  end
end
