# frozen_string_literal: true

require_relative "test_helper"

class TestHanamiSasso < Minitest::Test
  include AppFixture

  SCSS = <<~SCSS
    @use "sass:color";
    $brand: #3366cc;
    .card {
      color: $brand;
      .title { width: 8px * 2; }
      &:hover { color: color.adjust($brand, $lightness: 10%); }
      @at-root .footer { margin: 0; }
    }
  SCSS

  def compiler(root, **opts)
    HanamiSasso::Compiler.new(root: root, builds: { "app.scss" => "app.css" }, **opts)
  end

  def test_compiles_entrypoint_into_public
    with_app({ "app.scss" => SCSS }) do |root|
      compiler(root, style: :expanded).build
      css = read_build(root, "app.css")
      assert_includes css, "color: #3366cc;"      # variable resolved
      assert_includes css, "width: 16px;"          # 8px * 2
      assert_includes css, ".card .title {"        # nesting flattened
      assert_includes css, ".card:hover {"         # parent selector
      assert_match(/^\.footer \{/, css)            # @at-root hoisted to top level
    end
  end

  def test_matches_standalone_sasso_byte_for_byte
    with_app({ "app.scss" => SCSS }) do |root|
      compiler(root, style: :expanded).build
      reference = ::Sasso.compile(File.join(root, "app/assets/css/app.scss"), style: :expanded)
      assert_equal reference, read_build(root, "app.css")
    end
  end

  def test_compressed_style
    with_app({ "app.scss" => SCSS }) do |root|
      compiler(root, style: :compressed).build
      css = read_build(root, "app.css")
      assert_includes css, ".card{color:#36c}"
      refute_includes css, "\n  "                  # no expanded indentation
    end
  end

  def test_resolves_sibling_partials
    with_app({ "app.scss" => "@use \"buttons\";", "_buttons.scss" => ".btn { x: 1px; }" }) do |root|
      compiler(root, style: :expanded).build
      assert_includes read_build(root, "app.css"), ".btn {"
    end
  end

  def test_source_map_sidecar
    with_app({ "app.scss" => SCSS }) do |root|
      compiler(root, style: :expanded, source_map: true).build
      css = read_build(root, "app.css")
      assert_includes css, "/*# sourceMappingURL=app.css.map */"
      assert File.file?(File.join(root, "public/assets/css/app.css.map")), "expected .map sidecar"
    end
  end

  def test_clobber_removes_generated_css
    with_app({ "app.scss" => SCSS }) do |root|
      compiler(root, style: :expanded).build
      assert File.file?(File.join(root, "public/assets/css/app.css"))
      compiler(root, style: :expanded).clobber
      refute File.file?(File.join(root, "public/assets/css/app.css"))
    end
  end

  def test_missing_entrypoint_raises_clear_error
    with_app({}) do |root|
      err = assert_raises(HanamiSasso::Compiler::Error) { compiler(root, style: :expanded).build }
      assert_includes err.message, "input stylesheet not found"
    end
  end

  def test_invalid_style_raises
    with_app({ "app.scss" => SCSS }) do |root|
      assert_raises(HanamiSasso::Compiler::Error) { compiler(root, style: :nope).build }
    end
  end

  def test_compiler_factory_env_aware_defaults
    HanamiSasso.reset_configuration!
    HanamiSasso.configure { |c| c.root = "/tmp" }
    ENV["HANAMI_ENV"] = "production"
    assert_equal :compressed, HanamiSasso.compiler.style
    refute HanamiSasso.compiler.source_map
    ENV["HANAMI_ENV"] = "development"
    assert_equal :expanded, HanamiSasso.compiler.style
    assert HanamiSasso.compiler.source_map
  ensure
    ENV.delete("HANAMI_ENV")
    HanamiSasso.reset_configuration!
  end
end
