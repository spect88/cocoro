# frozen_string_literal: true

require_relative "lib/cocoro/version"

Gem::Specification.new do |spec|
  spec.name          = "cocoro"
  spec.version       = Cocoro::VERSION
  spec.authors       = ["Tomasz Szczęśniak-Szlagowski"]
  spec.email         = ["spect88@gmail.com"]

  spec.summary       = "An unofficial Cocoro Air client"
  spec.description   = "A client library talking to the same API that the Cocoro Air mobile apps " \
                       "do. Not affiliated with SHARP, this is a completely unofficial library " \
                       "which may break at any moment, so use it at your own risk."
  spec.homepage      = "https://github.com/spect88/cocoro"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/spect88/cocoro"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "faraday", "~> 1.8"
  spec.add_dependency "faraday-cookie_jar", ">= 0.0.7"
  spec.add_dependency "faraday_middleware", "~> 1.2"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its", "~> 1.3.0"
  spec.add_development_dependency "rubocop", "~> 1.7"
  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
