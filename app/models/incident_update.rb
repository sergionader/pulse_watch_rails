class IncidentUpdate < ApplicationRecord
  belongs_to :incident

  enum :status, { investigating: 0, identified: 1, monitoring: 2, resolved: 3 }

  validates :message, presence: true

  default_scope { order(created_at: :desc) }
end
