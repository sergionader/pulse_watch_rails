class NotificationChannel < ApplicationRecord
  enum :channel_type, { email: 0, slack: 1, discord: 2, webhook: 3 }

  validates :channel_type, presence: true
  validates :config, presence: true

  scope :active, -> { where(active: true) }
end
