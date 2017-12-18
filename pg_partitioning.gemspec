$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pg_partitioning/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pg_partitioning"
  s.version     = PgPartitioning::VERSION
  s.authors     = ["Victor M."]
  s.email       = ["victor.magarlamov@gmail.com"]
  s.homepage    = "https://github.com/victor-magarlamov/pg_partitioning"
  s.summary     = "PostgreSQL partitioning assistant for Rails"
  s.description = "PostgreSQL partitioning assistant for Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "pg"
  s.add_development_dependency "rspec-rails"
  
  s.test_files = Dir["spec/**/*"]
end
