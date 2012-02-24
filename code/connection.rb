require 'rubygems'
require 'net/https'
# and see https://github.com/jamesgolick/always_verify_ssl_certificates
module Errors
  class ConnectionError < StandardError; end
end

module Utils
  class Connection
    attr_reader :max_tries, :timeout, :message, :redirect_message
    attr_writer :url
    attr_accessor :max_redirects
  
    def initialize(url, timeout=60)
      @max_tries = 3
      @url = url
      @timeout = timeout
      @max_redirects = 2
      @message = ""
      @redirect_message = ""
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
            raise Errors::ConnectionError, "Failed connecting to #{@url} after #{try+1} tries, with Timeout #{@timeout} seconds.\n#{e.message}\n #{@message} #{@redirect_message}", caller
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
      def http_result(response = nil)
        if response
          # if redirect, try the redirect url and continue from there.  (doesn't follow meta-content-refresh
          return redirect(response) if redirect?(response)
          #
          # response.value will raise Net::HTTPRetriableError: 301 "Moved Permanently" on a 301
          @message = "Class: #{response.class}, Code: #{response.code}, Header-Content-Length: #{response["content-length"].to_i}, Actual Length: #{response.body.length}, Message: #{response.message}, #{response.value} -- Full Headers #{response.to_hash.inspect}\n"
          if full_message_received?(response)
            # full message received, return response
            return response
          else
            raise "Full Message Not Received"
          end
        end
        raise "Something went wrong. No response?"
      end
      def redirect?(response)
        if response.code =~ /30\d/
          set_redirect_url(response)
          true
        # elsif
          # meta tag parsing stub, see with nokogiri https://github.com/postmodern/spidr/blob/master/lib/spidr/links.rb
          # meta_tag = response.body.scan(/<META HTTP-EQUIV=['" ]REFRESH["' ](.*)["' ]>/i)[1]
          # @url = meta_tag.match(/url=(\S+)$/))[1] if meta_tag
        else
          false
        end
      end
      def set_redirect_url(response)
        response_location = response['Location']
        if !response_location['http']
          @url = @url[/http[^\/]+\/\/[^\/]+/] + response_location
        else
          @url = response_location
        end
      end
      def redirect(response)
        @redirect_message += "\n *** Redirecting to #{@url} with code #{response.code}, #{response.class}\n" 
        puts "redirecting to #{@url}"
        open_url
      end
  end
end
