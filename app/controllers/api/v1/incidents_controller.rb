module Api
  module V1
    class IncidentsController < BaseController
      before_action :set_incident, only: %i[show update resolve]

      def index
        incidents = Incident.order(created_at: :desc)
        incidents = incidents.where(status: params[:status]) if params[:status].present?
        result = paginate(incidents)
        render_success(IncidentSerializer.collection(result[:records]), meta: result[:meta])
      end

      def show
        render_success(IncidentSerializer.new(@incident, include_updates: true).as_json)
      end

      def create
        incident = Incident.new(incident_params)

        if params[:incident][:monitor_ids].present?
          incident.site_monitors = SiteMonitor.where(id: params[:incident][:monitor_ids])
        end

        incident.save!
        render_success(IncidentSerializer.new(incident, include_updates: true).as_json, status: :created)
      end

      def update
        @incident.update!(incident_params)

        if params[:incident].key?(:monitor_ids)
          @incident.site_monitors = SiteMonitor.where(id: params[:incident][:monitor_ids])
        end

        render_success(IncidentSerializer.new(@incident, include_updates: true).as_json)
      end

      def resolve
        @incident.resolve!
        render_success(IncidentSerializer.new(@incident.reload, include_updates: true).as_json)
      end

      private

      def set_incident
        @incident = Incident.find(params[:id])
      end

      def incident_params
        params.require(:incident).permit(:title, :status, :severity)
      end
    end
  end
end
