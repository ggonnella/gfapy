require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

desc "Build gem"
task :build do
  system("gem build gfa.gemspec")
end

desc "Install gem"
task :install => :build do
  system("gem install gfa")
end

desc "Rm files created by rake build"
task :clean do
  system("rm -f gfa-*.gem")
end

# make documentation generation tasks
# available only if yard gem is installed
begin
  require "yard"
  YARD::Tags::Library.define_tag("Developer notes", :developer)
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb']
    t.stats_options = ['--list-undoc']
  end
rescue LoadError
end
