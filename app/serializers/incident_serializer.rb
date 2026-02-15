class IncidentSerializer
  def initialize(record, include_updates: false)
    @record = record
    @include_updates = include_updates
  end

  def as_json(*)
    data = {
      id: @record.id,
      title: @record.title,
      status: @record.status,
      severity: @record.severity,
      resolved_at: @record.resolved_at&.iso8601,
      monitor_ids: @record.site_monitor_ids,
      created_at: @record.created_at.iso8601,
      updated_at: @record.updated_at.iso8601
    }

    if @include_updates
      data[:incident_updates] = IncidentUpdateSerializer.collection(@record.incident_updates)
    end

    data
  end

  def self.collection(records)
    records.map { |r| new(r).as_json }
  end
end
