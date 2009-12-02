require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "misfit"
    gemspec.summary = "Manage Git repositories inside a SVN repository"
    gemspec.description = "A simple tool for importing and maintaining Git repositories in a SVN project folder structure"
    gemspec.email = "arvid@winstondesign.se"
    gemspec.homepage = "http://github.com/arvida/misfit"
    gemspec.authors = ["Arvid Andersson"]
    
    gemspec.add_dependency "thor", ">= 0.12.0"
    
    gemspec.files.include %w(lib/misfit.rb)

  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end