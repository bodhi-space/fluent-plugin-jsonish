# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = 'fluent-plugin-jsonish'
  gem.version       = ENV.key?('RUBYGEM_VERSION') ? ENV['RUBYGEM_VERSION'] : '1.0.1'
  gem.authors       = ['Alex Yamauchi']
  gem.email         = ['oss@hotschedules.com']
  gem.homepage      = 'https://github.com/bodhi-space/fluent-plugin-jsonish'
  gem.description   = %q{Input parser for records which require minor text processing before they can be parsed as JSON}
  gem.summary       = %q{Input parser for records which require minor text processing before they can be parsed as JSON.  Also allows names of standard Time parser methods to be passed as time_format arguments and sets a reasonable default (iso8601).}
  gem.homepage      = 'https://github.com/bodhi-space/fluent-plugin-jsonish'
  gem.license       = 'Apache-2.0'
  gem.add_runtime_dependency 'fluentd', '>= 0.14.0'
  gem.files         = `git ls-files`.split("\n")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.signing_key   = File.expand_path( ENV.key?('RUBYGEM_SIGNING_KEY') ? ENV['RUBYGEM_SIGNING_KEY'] : '~/certs/oss@hotschedules.com.key' ) if $0 =~ /\bgem[\.0-9]*\z/
  gem.cert_chain    = %w[certs/oss@hotschedules.com.cert]
end
