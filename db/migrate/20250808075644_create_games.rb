class CreateGames < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.integer :current_card
      t.integer :next_card
      t.string :guess
      t.boolean :result
      t.integer :score

      t.timestamps
    end
  end
end
