class MonitorSerializer
  def initialize(record)
    @record = record
  end

  def as_json(*)
    {
      id: @record.id,
      name: @record.name,
      url: @record.url,
      http_method: @record.http_method,
      expected_status: @record.expected_status,
      check_interval_seconds: @record.check_interval_seconds,
      timeout_ms: @record.timeout_ms,
      is_active: @record.is_active,
      current_status: @record.current_status,
      last_checked_at: @record.last_checked_at&.iso8601,
      created_at: @record.created_at.iso8601,
      updated_at: @record.updated_at.iso8601
    }
  end

  def self.collection(records)
    records.map { |r| new(r).as_json }
  end
end
