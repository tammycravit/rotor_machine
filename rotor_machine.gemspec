
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rotor_machine/version'

Gem::Specification.new do |spec|
  spec.name          = 'rotor_machine'
  spec.version       = RotorMachine::VERSION
  spec.authors       = ['Tammy Cravit']
  spec.email         = ['tammycravit@me.com']

  spec.summary       = %q{Simple Enigma-like rotor machine in Ruby}
  spec.homepage      = 'https://github.com/tammycravit/rotor_machine'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'tcravit_ruby_lib', '~> 0.2'

  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'pry-byebug', '~> 3.6'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'guard-bundler', '~> 2.1'
  spec.add_development_dependency 'simplecov', '~> 0.15'
  spec.add_development_dependency 'simplecov-erb', '~> 0.1'
end
