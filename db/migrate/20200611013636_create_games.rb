class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :token
      t.integer :state, default: 0

      t.timestamps
    end
  end
end
