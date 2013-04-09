$:.unshift(File.dirname(__FILE__) + '/lib')
require 'knife-vcloud/version'

Gem::Specification.new do |s|
  s.name = 'knife-vcloud'
  s.version = KnifeVCloud::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE" ]
  s.summary = "VMWare vCloud Support for Chef's Knife Command"
  s.description = s.summary
  s.author = "Chirag Jog"
  s.email = "chirag@clogeny.com"
  s.homepage = "http://wiki.opscode.com/display/chef"
  s.require_path = 'lib'
  s.files = %w(LICENSE README.rdoc) + Dir.glob("lib/**/*")

  s.add_dependency "fog", ">= 1.10.1"
  s.add_dependency "chef", ">= 10.10"
  s.add_dependency "knife-windows"
end
