$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "manybots_gmail/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "manybots_gmail"
  s.version     = ManybotsGmail::VERSION
  s.authors     = ["Alexandre L. Solleiro"]
  s.email       = ["alex@webcracy.org"]
  s.homepage    = "http://webcracy.org"
  s.summary     = "Add a Gmail Observer to your local Manybots."
  s.description = "Allows you to import your emails from Gmail into your local Manybots"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.1"
  s.add_dependency "jquery-rails"
  s.add_dependency "oauth"
  s.add_dependency "gmail"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "ore-core"
end
