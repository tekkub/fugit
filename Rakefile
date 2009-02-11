require 'rake'

begin
	require 'jeweler'
	Jeweler::Tasks.new do |s|
		s.name = "fugit"
		s.email = "tekkub@gmail.com"
		s.homepage = "http://github.com/tekkub/fugit"
		s.description = "A cross-platform replacement for git-gui based on wxruby"
		s.summary = s.description
		s.authors = ["Tekkub"]
		s.bindir = 'bin'
		s.add_dependency('wxruby', [">= 1.9.9"])
	end
rescue LoadError
	puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

task :default => :gemspec
