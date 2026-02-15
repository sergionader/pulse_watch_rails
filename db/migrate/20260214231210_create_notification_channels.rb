class CreateNotificationChannels < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_channels, id: :uuid do |t|
      t.integer :channel_type, null: false, default: 0
      t.jsonb :config, null: false, default: {}
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :notification_channels, :channel_type
    add_index :notification_channels, :active
  end
end
