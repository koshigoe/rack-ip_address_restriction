# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/ip_address_restriction/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-ip_address_restriction"
  spec.version       = Rack::IpAddressRestriction::VERSION
  spec.authors       = ["koshigoe"]
  spec.email         = ["koshigoeb@gmail.com"]

  spec.summary       = %q{Restrict access by IP Address.}
  spec.description   = %q{Inspired by Rack::Access provided by https://github.com/rack/rack-contrib.}
  spec.homepage      = "https://github.com/koshigoe/rack-ip_address_restriction"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
