class CreateRoundScores < ActiveRecord::Migration[6.0]
  def change
    create_table :round_scores do |t|
      t.belongs_to :game_participant
      t.belongs_to :round
      t.integer :score

      t.timestamps
    end
  end
end
