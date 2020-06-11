class CreateRoundBoards < ActiveRecord::Migration[6.0]
  def change
    create_table :round_boards do |t|
      t.belongs_to :game_participant
      t.belongs_to :round

      t.json :board

      t.timestamps
    end
  end
end
