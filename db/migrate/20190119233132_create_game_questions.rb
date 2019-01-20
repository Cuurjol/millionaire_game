class CreateGameQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :game_questions do |t|
      t.references :game, index: true, foreign_key: true
      t.references :question, index: true, foreign_key: true, null: false
      t.integer :a
      t.integer :b
      t.integer :c
      t.integer :d

      t.timestamps
    end
  end
end
