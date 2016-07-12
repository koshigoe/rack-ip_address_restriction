require 'rack/ip_address_restriction/version'
require 'ipaddr'
require 'uri'
require 'pathname'

module Rack
  class IpAddressRestriction
    DEFAULT_MAPPING = { '/' => %w(127.0.0.1) }.freeze
    private_constant :DEFAULT_MAPPING

    def initialize(app, options = {})
      @app = app
      options = DEFAULT_MAPPING if options.empty?
      @mapping = create_mapping(options)
    end

    def call(env)
      if allow?(env)
        @app.call(env)
      else
        [403, { 'Content-Type' => 'text/html', 'Content-Length' => '0' }, []]
      end
    end

    private

    def create_mapping(config)
      mapping = config.map do |location, ip_masks|
        host, path = parse_location(location)
        raise ArgumentError, 'paths need to start with /' if path[0] != '/'
        path_prefix = Pathname.new(path).cleanpath.to_s

        ip_masks = ip_masks.map { |addr| addr.is_a?(IPAddr) ? addr : IPAddr.new(addr) }

        [host, path_prefix, ip_masks]
      end
      mapping.sort_by { |(host, path_prefix, _)| [host ? -host.size : (-1.0 / 0.0), -path_prefix.size] }
    end

    def parse_location(location)
      uri = URI.parse(location)
      if uri.host
        [uri.host, uri.path]
      else
        [nil, location]
      end
    end

    def allow?(env)
      return true unless ip_masks = ip_masks_for_current_path(env)

      request = Request.new(env)
      ip_masks.any? { |addr| addr.include?(IPAddr.new(request.ip)) }
    end

    def ip_masks_for_current_path(env)
      path = Pathname.new(env["PATH_INFO"].to_s).cleanpath.to_s

      @mapping.each do |host, path_prefix, ip_masks|
        next if host && ![env['HTTP_HOST'], env['SERVER_NAME']].include?(host)
        next if path !~ %r{\A#{Regexp.quote(path_prefix)}(.*)\z}i || !($1.empty? || $1[0] == '/')

        return ip_masks
      end

      nil
    end
  end
end
