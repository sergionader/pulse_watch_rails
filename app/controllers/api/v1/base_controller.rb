module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: { message: e.message, status: 404 } }, status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: {
          error: {
            message: "Validation failed",
            status: 422,
            details: e.record.errors.full_messages
          }
        }, status: :unprocessable_entity
      end

      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: { message: e.message, status: 400 } }, status: :bad_request
      end

      private

      def pagination_params
        page = [ (params[:page] || 1).to_i, 1 ].max
        per_page = [ (params[:per_page] || 20).to_i, 1 ].max
        per_page = [ per_page, 100 ].min
        { page: page, per_page: per_page }
      end

      def paginate(scope)
        pp = pagination_params
        total_count = scope.count
        total_pages = (total_count.to_f / pp[:per_page]).ceil
        records = scope.offset((pp[:page] - 1) * pp[:per_page]).limit(pp[:per_page])

        {
          records: records,
          meta: {
            current_page: pp[:page],
            per_page: pp[:per_page],
            total_count: total_count,
            total_pages: total_pages
          }
        }
      end

      def render_success(data, meta: {}, status: :ok)
        body = { data: data }
        body[:meta] = meta unless meta.empty?
        render json: body, status: status
      end
    end
  end
end
