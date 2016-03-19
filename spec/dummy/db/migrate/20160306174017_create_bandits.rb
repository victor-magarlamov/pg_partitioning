class CreateBandits < ActiveRecord::Migration
  def change
    create_table :bandits do |t|
      t.string :name
      t.string :specialization
      t.date :date_of_birth
      t.references :gang, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
