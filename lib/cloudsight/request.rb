module Cloudsight
  class Request
    class << self
      def send(options = {})
        raise RuntimeError.new("Need to define either oauth_options or api_key") unless Cloudsight.api_key || Cloudsight.oauth_options
        url = "#{Cloudsight::base_url}/image_requests"

        params = construct_params(options)
        response = Api.post(url, params)
        data = JSON.parse(response.body)
        raise ResponseException.new(data['error']) if data['error']
        raise UnexpectedResponseException.new(response.body) unless data['token']

        data
      end

      def repost(token, options = {})
        url = "#{Cloudsight::base_url}/image_requests/#{token}/repost"

        response = Api.post(url, options)
        return true if response.code == 200 and response.body.to_s.strip.empty?

        data = JSON.parse(response.body)
        raise ResponseException.new(data['error']) if data['error']
        raise UnexpectedResponseException.new(response.body) unless data['token']

        data
      end

      def construct_params(options)
        params = {}
        [:locale, :language, :latitude, :longitude, :altitude, :device_id, :ttl].each do |attr|
          params["image_request[#{attr}]"] = options[attr] if options.has_key?(attr)
        end

        if options[:focus]
          params['focus[x]'] = options[:focus][:x]
          params['focus[y]'] = options[:focus][:y]
        end

        params['image_request[remote_image_url]'] = options[:url] if options.has_key?(:url)
        params['image_request[image]'] = options[:file] if options.has_key?(:file)
        params
      end
    end
  end
end
