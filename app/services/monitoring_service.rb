class MonitoringService
  Result = Struct.new(:success, :status_code, :response_time_ms, :error_message, :headers, keyword_init: true)

  def initialize(monitor)
    @monitor = monitor
  end

  def execute
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    uri = URI.parse(@monitor.url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = @monitor.timeout_ms / 1000.0
    http.read_timeout = @monitor.timeout_ms / 1000.0

    request = build_request(uri)
    response = http.request(request)

    elapsed_ms = elapsed_since(start_time)

    Result.new(
      success: response.code.to_i == @monitor.expected_status,
      status_code: response.code.to_i,
      response_time_ms: elapsed_ms,
      error_message: nil,
      headers: response.each_header.to_h
    )
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Result.new(
      success: false,
      status_code: nil,
      response_time_ms: elapsed_since(start_time),
      error_message: "Timeout: #{e.message}",
      headers: {}
    )
  rescue SocketError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH => e
    Result.new(
      success: false,
      status_code: nil,
      response_time_ms: elapsed_since(start_time),
      error_message: "Connection error: #{e.message}",
      headers: {}
    )
  rescue StandardError => e
    Result.new(
      success: false,
      status_code: nil,
      response_time_ms: elapsed_since(start_time),
      error_message: "Unexpected error: #{e.message}",
      headers: {}
    )
  end

  private

  def build_request(uri)
    path = uri.request_uri
    case @monitor.http_method.upcase
    when "GET"     then Net::HTTP::Get.new(path)
    when "POST"    then Net::HTTP::Post.new(path)
    when "PUT"     then Net::HTTP::Put.new(path)
    when "PATCH"   then Net::HTTP::Patch.new(path)
    when "DELETE"  then Net::HTTP::Delete.new(path)
    when "HEAD"    then Net::HTTP::Head.new(path)
    when "OPTIONS" then Net::HTTP::Options.new(path)
    else Net::HTTP::Get.new(path)
    end
  end

  def elapsed_since(start_time)
    ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).round
  end
end
