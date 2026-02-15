class CreateIncidents < ActiveRecord::Migration[8.1]
  def change
    create_table :incidents, id: :uuid do |t|
      t.string :title, null: false
      t.integer :status, null: false, default: 0
      t.integer :severity, null: false, default: 0
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :incidents, :status
    add_index :incidents, :severity
  end
end
