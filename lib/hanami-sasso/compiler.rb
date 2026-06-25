# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"
require "sasso"

module HanamiSasso
  # Compiles configured Sass/SCSS entrypoints to plain CSS files. Deliberately
  # framework-free so it can be unit-tested with a plain temp `root:` — the rake
  # tasks just wire the Hanami app root + configuration in.
  #
  #   HanamiSasso::Compiler.new(
  #     root:       Dir.pwd,
  #     builds:     { "app.scss" => "app.css" },
  #     style:      :expanded,
  #     load_paths: [],                  # extra dirs, in addition to the source dir
  #     source_dir: "app/assets/css",
  #     build_dir:  "public/assets/css",
  #   ).build
  class Compiler
    Error = Class.new(StandardError)

    ALLOWED_STYLES = %i[expanded compressed].freeze

    attr_reader :root, :builds, :style, :load_paths, :source_dir, :build_dir, :source_map

    def initialize(root:, builds:, style: :expanded, load_paths: [],
                   source_dir: "app/assets/css",
                   build_dir: "public/assets/css", source_map: false)
      @root       = File.expand_path(root.to_s)
      @builds     = normalize_builds(builds)
      @style      = normalize_style(style)
      @load_paths = Array(load_paths).map(&:to_s)
      @source_dir = source_dir.to_s
      @build_dir  = build_dir.to_s
      @source_map = source_map ? true : false
    end

    # Compile every entrypoint; returns the list of written output paths.
    def build
      builds.map { |input, output| build_one(input, output) }
    end

    # Remove the generated CSS (and any sidecar maps) for every entrypoint.
    def clobber
      builds.filter_map do |_input, output|
        dest = File.join(@root, @build_dir, output)
        [dest, "#{dest}.map"].select { |f| File.file?(f) }.each { |f| FileUtils.rm_f(f) }
        File.directory?(File.dirname(dest)) ? dest : nil
      end
    end

    # Compile a single `input` (relative to source_dir) to `output` (relative to
    # build_dir), returning the absolute path written.
    def build_one(input, output)
      src = File.join(@root, @source_dir, input)
      raise Error, "hanami-sasso: input stylesheet not found: #{src}" unless File.file?(src)

      dest = File.join(@root, @build_dir, output)
      FileUtils.mkdir_p(File.dirname(dest))

      # `Sasso.compile` already searches the entry file's own directory first
      # (for sibling @use/@import); pass any extra include dirs after it.
      if @source_map
        result = ::Sasso.compile(src, style: @style, load_paths: @load_paths, source_map: true)
        write_source_map(dest, result.source_map)
        File.write(dest, result.css + source_map_footer(File.basename(dest)))
      else
        # sasso >= 0.2.7's library API omits the trailing newline; a built CSS
        # artifact conventionally ends with one (and dart-sass's CLI writes it).
        File.write(dest, "#{::Sasso.compile(src, style: @style, load_paths: @load_paths)}\n")
      end
      dest
    end

    # Recompile whenever a watched source file changes. Dependency-free poll loop
    # (no `listen` gem): a cheap mtime scan of the source + load_path trees.
    # Blocks. A compile error (including on the FIRST pass) is reported and the
    # loop keeps running — the watcher must survive a mid-edit broken file.
    def watch(interval: 1.0)
      safe_build
      snapshot = source_mtimes
      loop do
        sleep interval
        current = source_mtimes
        next if current == snapshot

        snapshot = current
        safe_build
      end
    end

    private

    def write_source_map(dest, source_map)
      from_dir = File.dirname(dest)
      source_map["file"] = File.basename(dest)
      source_map["sources"] = Array(source_map["sources"]).map { |s| relative_source(s, from_dir) }
      File.write("#{dest}.map", JSON.generate(source_map))
    end

    def source_map_footer(css_basename)
      comment = "/*# sourceMappingURL=#{css_basename}.map */"
      # sasso >= 0.2.7's `result.css` has no trailing newline, so the expanded
      # footer supplies the line terminator AND dart's blank separator line.
      @style == :compressed ? "#{comment}\n" : "\n\n#{comment}\n"
    end

    def relative_source(url, from_dir)
      Pathname.new(url).relative_path_from(Pathname.new(from_dir)).to_s
    rescue ArgumentError
      url
    end

    def safe_build
      build
    rescue ::Sasso::CompileError, Error => e
      warn e.message
    end

    def source_mtimes
      dirs = [File.join(@root, @source_dir), *@load_paths]
      dirs.flat_map { |d| Dir.glob(File.join(d, "**", "*.{scss,sass}")) }
          .uniq.sort.each_with_object({}) do |f, h|
        h[f] = File.mtime(f).to_f
      rescue Errno::ENOENT
        # raced with a delete; skip
      end
    end

    def normalize_builds(builds)
      hash = builds.respond_to?(:to_h) ? builds.to_h : nil
      if hash.nil? || hash.empty?
        raise Error, 'hanami-sasso: builds must be a non-empty Hash of { "input.scss" => "output.css" }'
      end

      hash
    end

    def normalize_style(style)
      sym = style.to_s.to_sym
      unless ALLOWED_STYLES.include?(sym)
        raise Error, "hanami-sasso: style must be one of #{ALLOWED_STYLES.inspect}, got #{style.inspect}"
      end

      sym
    end
  end
end
