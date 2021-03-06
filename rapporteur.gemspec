# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rapporteur/version'

Gem::Specification.new do |spec|
  spec.name          = 'rapporteur'
  spec.version       = Rapporteur::VERSION
  spec.authors       = ['Envy Labs', 'Code School']
  spec.email         = ['']
  spec.description   = 'An engine that provides common status polling endpoint.'
  spec.summary       = 'An engine that provides common status polling endpoint.'
  spec.homepage      = 'https://github.com/envylabs/rapporteur'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'i18n', '>= 0.6', '< 2'

  spec.add_development_dependency 'appraisal', '~> 2.1'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'combustion', '~> 0.5', '>= 0.5.1'
  spec.add_development_dependency 'rails', '>= 3.1', '< 6'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.2'
end
