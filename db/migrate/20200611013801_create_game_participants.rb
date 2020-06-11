class CreateGameParticipants < ActiveRecord::Migration[6.0]
  def change
    create_table :game_participants do |t|
      t.belongs_to :game
      t.string :name

      t.timestamps
    end
  end
end
