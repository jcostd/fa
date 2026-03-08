class CreateJobLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :job_locations do |t|
      t.references :job, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true

      t.integer :position, null: false, default: 1
      t.string :note

      t.timestamps
    end

    add_index :job_locations, [ :job_id, :position ], unique: true
  end
end
