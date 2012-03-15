# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','gwtf/version.rb'])

spec = Gem::Specification.new do |s|
  s.name = 'gwtf'
  s.version = Gwtf::VERSION
  s.author = 'R.I.Pienaar'
  s.email = 'rip@devco.net'
  s.homepage = 'http://devco.net/'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Go With The Flow'
  s.description = "A Unix cli centric todo manager"
# Add your other files here if you make them
  s.files = FileList["{README.md,COPYING,bin,lib}/**/*"].to_a
  s.require_paths << 'lib'
  s.has_rdoc = false
  s.bindir = 'bin'
  s.executables << 'gwtf'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_dependency 'json'
  s.add_dependency 'gli', "~>1.5.1"
  s.add_dependency 'boxcar_api', '~> 1.2.0'
end
