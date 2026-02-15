class CreateIncidentsMonitors < ActiveRecord::Migration[8.1]
  def change
    create_table :incidents_monitors, id: false do |t|
      t.references :incident, null: false, foreign_key: true, type: :uuid
      t.references :monitor, null: false, foreign_key: true, type: :uuid
    end

    add_index :incidents_monitors, [:incident_id, :monitor_id], unique: true
  end
end
