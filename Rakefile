require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "comma-heaven"
    gem.summary = %Q{CSV exporter for Rails}
    gem.description = %Q{CommaHeaven permits easy exports of Rails models to CSV}
    gem.email = "silvano.stralla@sistrall.it"
    gem.homepage = "http://github.com/sistrall/comma-heaven"
    gem.authors = ["Silvano Stralla"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency "activerecord"
    gem.add_dependency "actionpack"
    gem.add_dependency "fastercsv"
    gem.files = FileList['lib/**/*.rb', 'spec/**/*'].to_a
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "comma-heaven #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
