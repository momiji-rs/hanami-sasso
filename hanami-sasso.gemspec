# frozen_string_literal: true

require_relative "lib/hanami-sasso/version"

Gem::Specification.new do |spec|
  spec.name        = "hanami-sasso"
  spec.version     = HanamiSasso::VERSION
  spec.author      = "momiji-rs"
  spec.summary     = "Compile Sass/SCSS in Hanami with the pure-Rust sasso compiler — no Node, no Dart"
  spec.description = "A Hanami integration for sasso, a pure-Rust, zero-dependency, byte-for-byte " \
                     "dart-sass alternative. Adds sasso:compile/watch/clobber rake tasks (and runs " \
                     "before assets:precompile) that compile your Sass/SCSS in-process — no Node " \
                     "toolchain, no Dart VM, no subprocess. For Hanami 2.1+."
  spec.homepage    = "https://github.com/momiji-rs/hanami-sasso"
  spec.license     = "MIT"

  spec.metadata = {
    "homepage_uri"          => spec.homepage,
    "source_code_uri"       => spec.homepage,
    "changelog_uri"         => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true",
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|script|spec|features)/}) || f.match(%r{^\.})
  end
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1.0"

  # The gem's runtime code requires only the compiler (+ Rake for the tasks); it
  # integrates with Hanami's `assets:precompile` when present but never loads the
  # framework itself. Targets Hanami 2.1+.
  spec.add_dependency "rake", ">= 13.0"
  spec.add_dependency "sasso", ">= 0.2.3", "< 1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest", "~> 5.0"
end
