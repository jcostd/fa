class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :jobs do |t|
      t.date :date, null: false
      t.datetime :start_at  # Ex "from" di details
      t.datetime :end_at    # Ex "to" di details

      # Testo e Descrizioni
      t.text :description
      t.text :notes         # Ex "note" di details

      # Flag attivi
      t.boolean :with_video, null: false, default: false

      # Qui dentro ci andrà {"colour": true, "digital": true, "old_code": "12345"}
      t.json :legacy_data, default: {}

      t.virtual :display_title,
                type: :string,
                as: "COALESCE(NULLIF(TRIM(description), ''), 'Servizio del ' || strftime('%d/%m/%Y', date))",
                stored: false

      t.timestamps
    end

    add_index :jobs, :date
    add_index :jobs, :with_video
  end
end
