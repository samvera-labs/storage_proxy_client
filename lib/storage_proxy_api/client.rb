require 'faraday'
require 'storage_proxy_api/response'


module StorageProxyAPI
  class Client
    attr_reader :base_url

    def initialize(base_url:)
      @base_url = base_url
    end

    def conn
      @conn ||= Faraday.new(url: base_url)
    end

    # Sends an API request and returns the response.
    def send_request(http_method:, action: '/', headers: nil, params: nil, body: nil)
      faraday_response = conn.send(http_method) do |faraday_request|
        faraday_request.url(action)
        faraday_request.params = params if params
        faraday_request.headers = headers if headers
        faraday_request.body = body if body
      end

      StorageProxyAPI::Response.new(
        status: faraday_response.status,
        body: faraday_response.body,
        headers: faraday_response.headers
      )
    rescue Faraday::ConnectionFailed => e
      StorageProxyAPI::Response.new(
          status: 503,
          body: {},
          headers: {}
      )
    end

    def status(service:, external_uri:, include_events: false)
      send_request(http_method: :get, action: build_url(service, 'status', external_uri), headers: { include_events: boolean_string(include_events) } )
    end

    def stage(service:, external_uri:)
      send_request(http_method: :post, action: build_url(service, 'stage', external_uri))
    end

    private

      def build_url(service, action, identifier)
        [service, action, identifier].join '/'
      end

      def boolean_string(value)
        case value
        when nil, 0, '0', '', false, 'false'
          '0'
        else
          '1'
        end
      end
  end
end
