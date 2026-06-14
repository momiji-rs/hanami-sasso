# frozen_string_literal: true

require "hanami-sasso/version"
require "hanami-sasso/configuration"
require "hanami-sasso/compiler"

# Compile Sass/SCSS in a Hanami app with the pure-Rust `sasso` compiler — no
# Node, no Dart, no subprocess. Provide the rake tasks by requiring
# "hanami-sasso/rake_tasks" from your Rakefile.
module HanamiSasso
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield(config)
    end

    def reset_configuration!
      @config = Configuration.new
    end

    def production?
      (ENV["HANAMI_ENV"] || ENV["RACK_ENV"] || "development").to_s == "production"
    end

    # Build a Compiler from the current configuration, resolving the env-aware
    # defaults (style + source maps) to concrete values.
    def compiler
      c = config
      Compiler.new(
        root:       c.root || Dir.pwd,
        builds:     c.builds,
        style:      c.style || (production? ? :compressed : :expanded),
        load_paths: c.load_paths,
        source_dir: c.source_dir,
        build_dir:  c.build_dir,
        source_map: c.source_map.nil? ? !production? : c.source_map
      )
    end
  end
end
