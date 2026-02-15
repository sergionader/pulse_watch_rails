module Admin
  class IncidentUpdatesController < BaseController
    before_action :set_incident

    def create
      @incident_update = @incident.incident_updates.build(incident_update_params)

      if params[:incident_update][:status].present?
        @incident.update!(status: params[:incident_update][:status])
      end

      if @incident_update.save
        redirect_to admin_incident_path(@incident), notice: "Update posted."
      else
        redirect_to admin_incident_path(@incident), alert: "Failed to post update: #{@incident_update.errors.full_messages.join(', ')}"
      end
    end

    private

    def set_incident
      @incident = Incident.find(params[:incident_id])
    end

    def incident_update_params
      params.require(:incident_update).permit(:message, :status)
    end
  end
end
