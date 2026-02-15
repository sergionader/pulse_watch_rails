class Incident < ApplicationRecord
  has_many :incident_updates, dependent: :destroy
  has_and_belongs_to_many :site_monitors, join_table: :incidents_monitors, association_foreign_key: :monitor_id

  enum :status, { investigating: 0, identified: 1, monitoring: 2, resolved: 3 }
  enum :severity, { minor: 0, major: 1, critical: 2 }

  validates :title, presence: true

  after_create_commit :broadcast_new_incident
  after_update_commit :broadcast_incident_change

  scope :active, -> { where.not(status: :resolved) }
  scope :resolved, -> { where(status: :resolved) }
  scope :recent, ->(limit = 10) { order(created_at: :desc).limit(limit) }

  def resolve!
    update!(status: :resolved, resolved_at: Time.current)
  end

  private

  def broadcast_new_incident
    broadcast_prepend_to "monitor_status",
      target: "active_incidents",
      partial: "status/incident",
      locals: { incident: self }
  end

  def broadcast_incident_change
    if resolved?
      broadcast_remove_to "monitor_status"
    else
      broadcast_replace_to "monitor_status",
        partial: "status/incident",
        locals: { incident: self }
    end
  end
end
