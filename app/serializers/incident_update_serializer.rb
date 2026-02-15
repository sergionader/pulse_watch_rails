class IncidentUpdateSerializer
  def initialize(record)
    @record = record
  end

  def as_json(*)
    {
      id: @record.id,
      incident_id: @record.incident_id,
      message: @record.message,
      status: @record.status,
      created_at: @record.created_at.iso8601,
      updated_at: @record.updated_at.iso8601
    }
  end

  def self.collection(records)
    records.map { |r| new(r).as_json }
  end
end
