module Api
  module V1
    class MonitorsController < BaseController
      before_action :set_monitor, only: %i[show update destroy checks uptime]

      def index
        monitors = SiteMonitor.order(created_at: :desc)
        result = paginate(monitors)
        render_success(MonitorSerializer.collection(result[:records]), meta: result[:meta])
      end

      def show
        render_success(MonitorSerializer.new(@monitor).as_json)
      end

      def create
        monitor = SiteMonitor.create!(monitor_params)
        render_success(MonitorSerializer.new(monitor).as_json, status: :created)
      end

      def update
        @monitor.update!(monitor_params)
        render_success(MonitorSerializer.new(@monitor).as_json)
      end

      def destroy
        @monitor.destroy!
        head :no_content
      end

      def checks
        checks = @monitor.checks
        result = paginate(checks)
        render_success(CheckSerializer.collection(result[:records]), meta: result[:meta])
      end

      def uptime
        data = UptimeCalculator.new(@monitor.id).calculate_all
        render_success(data)
      end

      private

      def set_monitor
        @monitor = SiteMonitor.find(params[:id])
      end

      def monitor_params
        params.require(:monitor).permit(
          :name, :url, :http_method, :expected_status,
          :check_interval_seconds, :timeout_ms, :is_active
        )
      end
    end
  end
end
