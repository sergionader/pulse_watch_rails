class CheckSerializer
  def initialize(record)
    @record = record
  end

  def as_json(*)
    {
      id: @record.id,
      monitor_id: @record.monitor_id,
      status_code: @record.status_code,
      response_time_ms: @record.response_time_ms,
      successful: @record.successful,
      error_message: @record.error_message,
      headers: @record.headers,
      created_at: @record.created_at.iso8601,
      updated_at: @record.updated_at.iso8601
    }
  end

  def self.collection(records)
    records.map { |r| new(r).as_json }
  end
end
