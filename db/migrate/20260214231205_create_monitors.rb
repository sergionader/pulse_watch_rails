class CreateMonitors < ActiveRecord::Migration[8.1]
  def change
    create_table :monitors, id: :uuid do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :http_method, null: false, default: "GET"
      t.integer :expected_status, null: false, default: 200
      t.integer :check_interval_seconds, null: false, default: 300
      t.integer :timeout_ms, null: false, default: 5000
      t.boolean :is_active, null: false, default: true
      t.integer :current_status, null: false, default: 0
      t.datetime :last_checked_at

      t.timestamps
    end

    add_index :monitors, :is_active
    add_index :monitors, :current_status
  end
end
