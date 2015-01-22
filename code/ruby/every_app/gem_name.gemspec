# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "#{GEM_NAME}/version"

Gem::Specification.new do |spec|
  spec.name          = "#{GEM_NAME}"
  spec.version       = GEM_NAME::VERSION
  spec.email         = ["TODO"]
  author_file        = File.expand_path('AUTHORS', File.dirname(__FILE__))
  spec.authors       = File.readlines(author_file, :encoding => Encoding::UTF_8).map(&:strip)
  spec.summary       = "TODO"
  spec.description   = "TODO"
  spec.homepage      = "TODO"
  spec.license       = "MIT"
  spec.platform      = Gem::Platform::RUBY
  spec.required_ruby_version       = ">= 1.9.0"
  spec.required_rubygems_version   = ">= 1.3.6"

  # # used with gem i GEM_NAME -P HighSecurity
  # s.cert_chain  = ["certs/#{USER_NAME}.pem"]
  # # Sign gem when evaluating spec with `gem` command
  # #  unless ENV has set a SKIP_GEM_SIGNING
  # if ($0 =~ /gem\z/) and not ENV.include?('SKIP_GEM_SIGNING')
  #   s.signing_key = File.join(Gem.user_home, '.ssh', 'gem-private_key.pem')
  # end

    gem_path = File.expand_path("..", __FILE__)
    tracked_files = `git ls-files #{gem_path} -z`.split("\x0")
    excluded_dirs = %r{\Aetc}
    files         = tracked_files.reject{|file| file[excluded_dirs] }
    test_files    = files.grep(%r{^(test|spec|features)/})
  spec.files                = files
  spec.test_files           = test_files
  spec.executables          = []
  spec.default_executable   = ""
  spec.require_paths        = ["lib"]

  spec.has_rdoc             = true
  spec.extra_rdoc_files     = ["CHANGELOG.md", "CONTRIBUTING.md", "TODO.md", "LICENSE"]
  spec.rdoc_options         = ["--main", "README.md"]

  # spec.add_runtime_dependency "redcard"

  spec.add_development_dependency "bundler",          "~> 1.7"
  spec.add_development_dependency "rake",             "~> 10.0"
  spec.add_development_dependency "rspec",            "~> 3.1"
  spec.add_development_dependency "simplecov",        "~> 0.9"
  spec.add_development_dependency "code_notes"
end
