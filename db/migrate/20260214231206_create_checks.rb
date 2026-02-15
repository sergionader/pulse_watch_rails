class CreateChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :checks, id: :uuid do |t|
      t.references :monitor, null: false, foreign_key: true, type: :uuid
      t.integer :status_code
      t.integer :response_time_ms
      t.boolean :successful, null: false, default: false
      t.text :error_message
      t.jsonb :headers, default: {}

      t.timestamps
    end

    add_index :checks, :created_at
    add_index :checks, [:monitor_id, :created_at]
  end
end
