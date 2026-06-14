# frozen_string_literal: true

module HanamiSasso
  # Plugin configuration. Set it from your Rakefile (or a `config/sasso.rb` you
  # require) with `HanamiSasso.configure { |c| ... }`. Defaults target a stock
  # Hanami 2 layout and compile directly to `public/` (no Node, no esbuild).
  class Configuration
    attr_accessor :builds, :style, :load_paths, :source_dir, :build_dir, :source_map, :root

    def initialize
      # { "<input under source_dir>" => "<output under build_dir>" }
      @builds      = { "app.scss" => "app.css" }
      # nil = :compressed in production (HANAMI_ENV=production), :expanded else.
      @style       = nil
      # Extra @use/@import dirs; the entrypoint's own dir is always searched.
      @load_paths  = []
      @source_dir  = "app/assets/css"
      # Compile straight into public/ so the CSS is served with no Node/esbuild
      # step; link it with <link href="/assets/css/app.css">. Point this at
      # "app/assets/css" instead if you'd rather feed Hanami's esbuild pipeline.
      @build_dir   = "public/assets/css"
      # nil = sidecar .map outside production, off in production; true/false force.
      @source_map  = nil
      # nil = the working dir when the task runs (the Hanami app root).
      @root        = nil
    end
  end
end
