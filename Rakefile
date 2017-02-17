require "rake/testtask"

$rgfaversion=Gem::Specification.load("rgfa.gemspec").version.to_s

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/test_*.rb"
  t.verbose = true
end

desc "Run tests"
task :default => :test

desc "Build gem"
task :build do
  system("gem build rgfa.gemspec")
end

desc "Install gem"
task :install => :build do
  system("gem install rgfa")
end

desc "Rm files created by rake build"
task :clean do
  system("rm -f rgfa-*.gem")
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

desc "Typeset cheatsheet"
task :cheatsheet do
  system("echo #$rgfaversion > cheatsheet/version")
  system("latexmk cheatsheet/rgfa-cheatsheet.tex "+
         "-pdf -outdir=cheatsheet")
  system("mv cheatsheet/rgfa-cheatsheet.pdf"+
         "   cheatsheet/rgfa-cheatsheet-#$rgfaversion.pdf")
end

desc "Create a PDF documentation"
task :pdf do
  require "erb"
  File.open("pdfdoc/cover.html", "w") do |f|
    f.puts ERB.new(IO.read("pdfdoc/cover.html.erb")).result(binding)
  end
  system("yard2.0 --one-file --no-api private -o pdfdoc")
  system("wkhtmltopdf cover pdfdoc/cover.html "+
                     "toc "+
                     "pdfdoc/index.html "+
                     "--user-style-sheet pdfdoc/print.css "+
                     "pdfdoc/rgfa-api-#$rgfaversion.pdf")
end

desc "Create the RGFA manual"
task :manual do
  system("cd manual; pandoc $(cat chapters) -o manual.pdf")
end

desc "Create the gfapy manual"
task :pymanual do
  system("cd gfapy_manual; pandoc $(cat chapters) -o gfapy-manual.pdf")
end

desc "Run python tests"
task :pytest do
    system("python3 -m unittest discover")
end

