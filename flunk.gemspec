Gem::Specification.new do |s|
  s.name                = "flunk"
  s.version             = "0.0.4"
  s.platform            = Gem::Platform::RUBY
  s.authors             = ["Adam Kirk"]
  s.email               = %q{atomkirk@gmail.com}
  s.homepage            = %q{https://github.com/mysterioustrousers/flunk}
  s.summary             = %q{A gem for testing Ruby on Rails web APIs by simulating a client.}
  s.description         = %q{A gem for testing Ruby on Rails web APIs by simulating a client.}

  s.files               = `git ls-files`.split("\n").reject {|path| path =~ /\.gitignore$/ }
  s.test_files          =`git ls-files -- test/*`.split("\n")
  s.require_paths       = ["lib"]

  s.required_ruby_version = ">= 1.9.2"
  s.add_dependency 'actionpack'
end
