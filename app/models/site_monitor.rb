class SiteMonitor < ApplicationRecord
  include ActionView::RecordIdentifier

  self.table_name = "monitors"

  has_many :checks, foreign_key: :monitor_id, dependent: :destroy, inverse_of: :site_monitor
  has_and_belongs_to_many :incidents, join_table: :incidents_monitors, foreign_key: :monitor_id

  enum :current_status, { up: 0, down: 1, degraded: 2 }

  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :http_method, presence: true, inclusion: { in: %w[GET POST PUT PATCH DELETE HEAD OPTIONS] }
  validates :expected_status, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 100, less_than: 600 }
  validates :check_interval_seconds, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 30 }
  validates :timeout_ms, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: 30_000 }

  after_update_commit :broadcast_status_change, if: :saved_change_to_current_status?

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }

  def last_check
    checks.order(created_at: :desc).first
  end

  private

  def broadcast_status_change
    broadcast_replace_to "monitor_status",
      target: dom_id(self),
      partial: "status/monitor",
      locals: { monitor: self }

    broadcast_replace_to "monitor_status",
      target: "overall_status",
      partial: "status/overall_status",
      locals: { overall_status: determine_overall_status }
  end

  def determine_overall_status
    active_incidents = Incident.active
    active_monitors = SiteMonitor.active

    if active_incidents.where(severity: :critical).exists?
      :major_outage
    elsif active_incidents.where(severity: :major).exists?
      :partial_outage
    elsif active_monitors.down.exists? || active_incidents.exists?
      :degraded
    elsif active_monitors.degraded.exists?
      :degraded
    else
      :operational
    end
  end
end
