# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jakewendt-simply_helpful}
  s.version = "2.0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["George 'Jake' Wendt"]
  s.date = %q{2010-11-10}
  s.description = %q{longer description of your gem}
  s.email = %q{github@jake.otherinbox.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "generators/simply_helpful/USAGE",
     "generators/simply_helpful/simply_helpful_generator.rb",
     "generators/simply_helpful/templates/autotest_simply_helpful.rb",
     "generators/simply_helpful/templates/javascripts/simply_helpful.js",
     "generators/simply_helpful/templates/simply_helpful.rake",
     "lib/simply_helpful.rb",
     "lib/simply_helpful/autotest.rb",
     "lib/simply_helpful/form_helper.rb",
     "lib/simply_helpful/rails_helpers.rb",
     "lib/simply_helpful/tasks.rb",
     "lib/simply_helpful/test_tasks.rb",
     "lib/tasks/database.rake",
     "lib/tasks/rcov.rake"
  ]
  s.homepage = %q{http://github.com/jakewendt/simply_helpful}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{one-line summary of your gem}
  s.test_files = [
    "test/app/controllers/application_controller.rb",
     "test/app/controllers/home_controller.rb",
     "test/config/routes.rb",
     "test/unit/helpful/form_helper_test.rb",
     "test/unit/helpful/rails_helpers_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 2"])
    else
      s.add_dependency(%q<rails>, ["~> 2"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 2"])
  end
end

