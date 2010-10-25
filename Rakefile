require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
	require 'jeweler'
	Jeweler::Tasks.new do |gem|
		gem.name = "jakewendt-simply_helpful"
		gem.summary = %Q{one-line summary of your gem}
		gem.description = %Q{longer description of your gem}
		gem.email = "github@jake.otherinbox.com"
		gem.homepage = "http://github.com/jakewendt/simply_helpful"
		gem.authors = ["George 'Jake' Wendt"]
		# gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings

		gem.files = FileList['lib/**/*.rb']
		gem.test_files = []
		gem.add_dependency('rails', '~> 2')
	end
	Jeweler::GemcutterTasks.new
rescue LoadError
	puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
