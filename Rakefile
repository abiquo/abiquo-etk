require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "abiquo-etk"
    gem.summary = %Q{Abiquo Elite Toolkit}
    gem.description = %Q{Tools to troubleshoot your Abiquo installation}
    gem.email = "sergio@rubio.name"
    gem.homepage = "http://github.com/rubiojr/abiquo-etk"
    gem.authors = ["Sergio Rubio"]
    gem.version = File.read 'VERSION'
    gem.add_dependency(%q<nokogiri>, [">= 1.4"])
    gem.add_dependency(%q<term-ansicolor>, [">= 1.0"])
    gem.add_dependency(%q<mixlib-cli>, [">= 1.2"])
    gem.files.include %w(
      scripts/*
      lib/**/*
      vendor/**/*
      VERSION
    )
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "abiquo-etk #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :tarball do
  version = File.read('VERSION').strip.chomp
  `cd .. && cp -r abiquo-etk abiquo-etk-#{version}`
  `cd .. && tar czvf abiquo-etk-#{version}.tar.gz abiquo-etk-#{version}`
  `cd .. && rm -rf abiquo-etk-#{version}`
end

task :updatepkg => [:build, :tarball] do
  version = File.read('VERSION').strip.chomp
  `rm ~/Work/abiquo/git/abiquo-ce-rpms/abiquo-platform/abiquo-etk/abiquo-etk*.tar.gz`
  `cp ../abiquo-etk-#{version}.tar.gz ~/Work/abiquo/git/abiquo-ce-rpms/abiquo-platform/abiquo-etk/`
  `cp abiquo-etk.spec ~/Work/abiquo/git/abiquo-ce-rpms/abiquo-platform/abiquo-etk/`
  `cp pkg/abiquo-etk-#{version}.gem ~/Work/abiquo/git/abiquo-ce-rpms/abiquo-platform/abiquo-etk/`
end


task :rpm do
  `clean_rpmbuild_root ~/rpmbuild/`
  `cp pkg/*gem ~/rpmbuild/SOURCES`
  `cp abiquo-etk.spec ~/rpmbuild/SPECS/`
  `rpmbuild -ba ~/rpmbuild/SPECS/abiquo-etk.spec`
  `cp ~/rpmbuild/RPMS/noarch/rubygem-abiquo-etk*.rpm packages`
  `repomanage -o packages/ |xargs rm`
end
