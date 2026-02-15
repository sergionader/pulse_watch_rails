module Admin
  class MonitorsController < BaseController
    before_action :set_monitor, only: %i[show edit update destroy checks]

    def index
      @monitors = SiteMonitor.order(:name)
    end

    def show
      @uptime = UptimeCalculator.new(@monitor.id).calculate_all
      @recent_checks = @monitor.checks.recent(20)
    end

    def new
      @monitor = SiteMonitor.new
    end

    def create
      @monitor = SiteMonitor.new(monitor_params)
      if @monitor.save
        redirect_to admin_monitor_path(@monitor), notice: "Monitor created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @monitor.update(monitor_params)
        redirect_to admin_monitor_path(@monitor), notice: "Monitor updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @monitor.destroy!
      redirect_to admin_monitors_path, notice: "Monitor deleted."
    end

    def checks
      checks = @monitor.checks
        .unscoped
        .where(monitor_id: @monitor.id)
        .where(created_at: 24.hours.ago..)
        .order(created_at: :asc)

      render json: checks.map { |c|
        { time: c.created_at.iso8601, response_time_ms: c.response_time_ms, successful: c.successful }
      }
    end

    private

    def set_monitor
      @monitor = SiteMonitor.find(params[:id])
    end

    def monitor_params
      params.require(:site_monitor).permit(
        :name, :url, :http_method, :expected_status,
        :check_interval_seconds, :timeout_ms, :is_active
      )
    end
  end
end
