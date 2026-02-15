module Admin
  class IncidentsController < BaseController
    before_action :set_incident, only: %i[show edit update resolve]

    def index
      @active_incidents = Incident.active.order(created_at: :desc)
      @resolved_incidents = Incident.resolved.order(resolved_at: :desc).limit(10)
    end

    def show
      @incident_update = IncidentUpdate.new
    end

    def new
      @incident = Incident.new
      @monitors = SiteMonitor.active.order(:name)
    end

    def create
      @incident = Incident.new(incident_params)

      if params[:incident][:monitor_ids].present?
        @incident.site_monitors = SiteMonitor.where(id: params[:incident][:monitor_ids])
      end

      if @incident.save
        redirect_to admin_incident_path(@incident), notice: "Incident created."
      else
        @monitors = SiteMonitor.active.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @monitors = SiteMonitor.active.order(:name)
    end

    def update
      if @incident.update(incident_params)
        if params[:incident].key?(:monitor_ids)
          @incident.site_monitors = SiteMonitor.where(id: params[:incident][:monitor_ids] || [])
        end
        redirect_to admin_incident_path(@incident), notice: "Incident updated."
      else
        @monitors = SiteMonitor.active.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def resolve
      @incident.resolve!
      redirect_to admin_incident_path(@incident), notice: "Incident resolved."
    end

    private

    def set_incident
      @incident = Incident.find(params[:id])
    end

    def incident_params
      params.require(:incident).permit(:title, :severity, :status)
    end
  end
end
