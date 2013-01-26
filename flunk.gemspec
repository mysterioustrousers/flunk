Gem::Specification.new do |s|
  s.name                = "flunk"
  s.version             = "0.0.8"
  s.platform            = Gem::Platform::RUBY
  s.authors             = ["Adam Kirk"]
  s.email               = %q{atomkirk@gmail.com}
  s.homepage            = %q{https://github.com/mysterioustrousers/flunk}
  s.summary             = %q{A gem for testing Ruby on Rails web APIs by simulating a client.}
  s.description         = %q{A gem for testing Ruby on Rails web APIs by simulating a client.}

  s.files               = `git ls-files -- lib`.split("\n").reject {|path| path =~ /\.gitignore$/ }
  s.test_files          = `git ls-files -- test/*`.split("\n")
  s.require_paths       = ["lib"]

end
