require 'rubygems'
require 'net/https'
# and see https://github.com/jamesgolick/always_verify_ssl_certificates
module Errors
  class ConnectionError < StandardError; end
end

module Utils
  class Connection
    attr_reader :max_tries, :timeout, :message
    attr_writer :url
    attr_accessor :max_redirects
  
    def initialize(url)
      @max_tries = 3
      @url = url
      @timeout = 60
      @max_redirects = 2
    end

    def open_uri
      safe_open
    end
    
    def body
      open_uri.read_body
    end
  
    private
  
    def safe_open
      @max_tries.times do |try|
        @timeout += 60 #increase timeout by 60 seconds each try
        begin
          return open_url
        rescue Exception => e
          if try+1 == @max_tries
            raise Errors::ConnectionError, "Failed connecting to #{@url} after #{try+1} tries, with Timeout #{@timeout} seconds.\n#{e.message}\n #{@message}", caller
          end
        end
      end
    end
    
    def url=(url)
      @url = url || "nil"
    end
    
    def open_url
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = @timeout 
      http.read_timeout = @timeout 
      http.use_ssl = (uri.scheme == 'https')
      follow_response(http.request_get( uri.request_uri ) )
    end
    
    def follow_response(response = nil)
      if response.kind_of?(Net::HTTPRedirection)
        if @max_redirects > 0
          @max_redirects -= 1
          puts "Redirecting from #{@url}"
          @url = redirect_url(response)
          puts "Redirecting to #{@url}"
          open_url
        else
          puts "Too many redirects"
        end
      else
        http_result(response)
      end
    end

    def http_result(response = nil)
      if response
        @message = "Class: #{response.class}, Code: #{response.code}, Header-Content-Length: #{response["content-length"].to_i}, Actual Length: #{response.body.length}, Message: #{response.message}, #{response.value} -- Full Headers #{response.to_hash.inspect}\n"
      end
      if full_message_received?(response)
        response
      else
        raise "Full Message Not Received"
      end
    end
     def redirect_url(response)
       if response['location'].nil?
        response.body.match(/<a href=\"([^>]+)\">/i)[1]
      else
       response['location']
      end
    end 
    # return true if no content-length response header.
    def full_message_received?(response)
      content_length = response["content-length"] || ""
      (content_length == "") ? true : content_length.to_i == response.body.length
    end
  end
end
