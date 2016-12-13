$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "accme_lib/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "accme_lib"
  s.version     = AccmeLib::VERSION
  s.authors     = ["Joshua F. Rountree"]
  s.email       = ["rountrjf@ucmail.uc.edu"]
  s.homepage    = "http://cme.uc.edu/"
  s.summary     = "A library to help better manage ties to the Accreditation Council for Continuing Medical Education"
  s.description = "A library to help better manage ties to the Accreditation Council for Continuing Medical Education"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # s.add_dependency "rails", "~> 4.1.x"

  # s.add_development_dependency "sqlite3"
end
