class CreateCrimes < ActiveRecord::Migration
  def change
    create_table :crimes do |t|
      t.string :title
      t.references :bandit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
