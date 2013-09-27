# This module generates tickets compatible
# with the "mod_auth_tkt" apache module.
#
# Based on work by: MESO Web Scapes, Sascha Hanssen
# www.meso.net/auth_tkt_rails | hanssen@meso.net
# Derived from https://github.com/yabawock/devise_ticketable/blob/master/lib/devise_ticketable/model.rb

module AuthTicket
  CONFIG = {
    auth_tkt_encode: false,
    auth_tkt_ignore_ip: false,
    auth_tkt_secret: raise('set me'),

  }

  module_function

  # returns a string that contains the signed tkt
  def get_tkt_hash(request, options={})
    options.reverse_merge!({
      :encode     => CONFIG.fetch(:auth_tkt_encode),
      :ignore_ip  => CONFIG.fetch(:auth_tkt_ignore_ip),
    })

    timestamp  = current_time.to_i
    ip_address = options[:ignore_ip] ? '0.0.0.0' : request.remote_ip

    auth_tkt = build_auth_tkt(timestamp, ip_address)

    # base64 encode ticket, if needed
    if options[:encode]
      auth_tkt = encode_auth_tkt(auth_tkt)
    end

    auth_tkt
  end

  def current_time
    Clock.now
  end

  def build_auth_tkt(timestamp, ip_address)
    auth_tkt_secret = CONFIG.fetch(:auth_tkt_secret)

    # creating the signature
    digest0 = Digest::MD5.hexdigest(
      ip_timestamp(timestamp, ip_address) +
      auth_tkt_secret
    )

    digest  = Digest::MD5.hexdigest(
      digest0 +
      auth_tkt_secret
    )

    # concatenating signature and timestamp
    digest + timestamp.to_s(16)
  end

  def encode_auth_tkt(auth_tkt)
    require 'base64'
    Base64.encode64(auth_tkt).gsub("\n", '').strip
  end


  # set timestamp and binary string for timestamp and ip packed together
  def ip_timestamp(timestamp, ip_address)
    [ip2long(ip_address), timestamp].pack("NN")
  end

  # function adapted according to php: generates an IPv4 Internet network address
  # from its Internet standard format (dotted string) representation.
  def ip2long(ip)
    long = 0
    ip.split(/\./).reverse.each_with_index do |x, i|
      long += x.to_i << (i * 8)
    end
    long
  end
end
