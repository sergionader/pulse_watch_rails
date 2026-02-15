class StatusController < ApplicationController
  def index
    @monitors = SiteMonitor.active.order(:name)
    @incidents = Incident.active.order(created_at: :desc)
    @overall_status = determine_overall_status
  end

  private

  def determine_overall_status
    return :operational unless @monitors.exists?

    if @incidents.where(severity: :critical).exists?
      :major_outage
    elsif @incidents.where(severity: :major).exists?
      :partial_outage
    elsif @monitors.down.exists? || @incidents.exists?
      :degraded
    elsif @monitors.degraded.exists?
      :degraded
    else
      :operational
    end
  end
end
