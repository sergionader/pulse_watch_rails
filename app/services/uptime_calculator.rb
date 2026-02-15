class UptimeCalculator
  PERIODS = {
    "24h" => 24.hours,
    "7d" => 7.days,
    "30d" => 30.days,
    "90d" => 90.days
  }.freeze

  def initialize(monitor_id)
    @monitor_id = monitor_id
  end

  def calculate(period_key)
    duration = PERIODS.fetch(period_key)
    from = duration.ago
    checks = Check.unscoped.where(monitor_id: @monitor_id, created_at: from..)

    return nil if checks.none?

    total = checks.count
    successful = checks.where(successful: true).count
    (successful.to_f / total * 100).round(2)
  end

  def calculate_all
    PERIODS.keys.each_with_object({}) do |period_key, hash|
      hash[period_key] = calculate(period_key)
    end
  end
end
