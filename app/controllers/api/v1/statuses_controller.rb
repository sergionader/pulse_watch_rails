module Api
  module V1
    class StatusesController < BaseController
      def show
        monitors = SiteMonitor.active
        incidents = Incident.active.order(created_at: :desc)

        render_success({
          overall_status: determine_overall_status(monitors),
          monitors: MonitorSerializer.collection(monitors),
          active_incidents: IncidentSerializer.collection(incidents)
        })
      end

      private

      def determine_overall_status(monitors)
        return "unknown" if monitors.none?
        return "major_outage" if monitors.any?(&:down?)
        return "degraded" if monitors.any?(&:degraded?)

        "operational"
      end
    end
  end
end
