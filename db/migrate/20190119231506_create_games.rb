class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.references :user, index: true, foreign_key: true
      t.datetime :finished_at
      t.integer :current_level, default: 0, null: false
      t.boolean :is_failed
      t.integer :prize, default: 0, null: false

      t.timestamps
    end
  end
end
