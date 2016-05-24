# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oasforeman/version'

Gem::Specification.new do |spec|
  spec.name          = "oasforeman"
  spec.version       = Oasforeman::VERSION
  spec.authors       = ["Oficina Asesora de Sistemas"]
  spec.email         = ["computo@udistrital.edu.co"]

  spec.summary       = %q{Todo lo relacionado con The Foreman en la OAS.}
  spec.description   = %q{Aprovisionado de The Foreman para la OAS.}
  spec.homepage      = "https://portalws.udistrital.edu.co/oas"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://katello.udistritaloas.edu.co"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.executables   << "oasforeman"
  spec.executables   << "oasforeman-installer"

  spec.add_development_dependency "bundler", "~> 1.7.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "hiera", "~> 1.3.4"
  spec.add_development_dependency "hiera-eyaml", "~> 2.1.0"
  spec.add_development_dependency "hammer_cli_foreman", "~> 0.6.2"
end
