class Check < ApplicationRecord
  belongs_to :site_monitor, foreign_key: :monitor_id, inverse_of: :checks

  validates :response_time_ms, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :successful, -> { where(successful: true) }
  scope :failed, -> { where(successful: false) }
  scope :recent, ->(limit = 10) { order(created_at: :desc).limit(limit) }
  scope :in_time_range, ->(from, to) { where(created_at: from..to) }

  default_scope { order(created_at: :desc) }
end
