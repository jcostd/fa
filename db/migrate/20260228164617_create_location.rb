class CreateLocation < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :district

      t.timestamps
    end

    add_index :locations, [ :name, :district ], unique: true
    add_index :locations, :name
  end
end
