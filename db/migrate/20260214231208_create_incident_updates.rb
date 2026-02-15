class CreateIncidentUpdates < ActiveRecord::Migration[8.1]
  def change
    create_table :incident_updates, id: :uuid do |t|
      t.references :incident, null: false, foreign_key: true, type: :uuid
      t.integer :status, null: false, default: 0
      t.text :message, null: false

      t.timestamps
    end
  end
end
