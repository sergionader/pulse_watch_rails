require "rails_helper"

RSpec.describe MonitoringService do
  let(:monitor) { create(:site_monitor, url: "https://example.com/health", expected_status: 200) }

  describe "#execute" do
    context "when the request succeeds with expected status" do
      before do
        stub_request(:get, "https://example.com/health")
          .to_return(status: 200, body: "OK", headers: { "content-type" => "text/plain" })
      end

      it "returns a successful result" do
        result = described_class.new(monitor).execute

        expect(result.success).to be true
        expect(result.status_code).to eq(200)
        expect(result.response_time_ms).to be_a(Integer)
        expect(result.response_time_ms).to be >= 0
        expect(result.error_message).to be_nil
        expect(result.headers).to include("content-type" => "text/plain")
      end
    end

    context "when the response has an unexpected status" do
      before do
        stub_request(:get, "https://example.com/health")
          .to_return(status: 500, body: "Error")
      end

      it "returns an unsuccessful result with the status code" do
        result = described_class.new(monitor).execute

        expect(result.success).to be false
        expect(result.status_code).to eq(500)
        expect(result.error_message).to be_nil
      end
    end

    context "when the request times out" do
      before do
        stub_request(:get, "https://example.com/health").to_timeout
      end

      it "returns an unsuccessful result with a timeout error" do
        result = described_class.new(monitor).execute

        expect(result.success).to be false
        expect(result.status_code).to be_nil
        expect(result.error_message).to match(/Timeout/i)
      end
    end

    context "when a connection error occurs" do
      before do
        stub_request(:get, "https://example.com/health")
          .to_raise(SocketError.new("getaddrinfo: Name or service not known"))
      end

      it "returns an unsuccessful result with a connection error" do
        result = described_class.new(monitor).execute

        expect(result.success).to be false
        expect(result.status_code).to be_nil
        expect(result.error_message).to match(/Connection error/i)
      end
    end

    context "when using POST method" do
      let(:monitor) { create(:site_monitor, url: "https://example.com/api", http_method: "POST", expected_status: 201) }

      before do
        stub_request(:post, "https://example.com/api")
          .to_return(status: 201, body: "Created")
      end

      it "uses the correct HTTP method" do
        result = described_class.new(monitor).execute

        expect(result.success).to be true
        expect(result.status_code).to eq(201)
        expect(a_request(:post, "https://example.com/api")).to have_been_made.once
      end
    end
  end
end
