# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "hanami-sasso"

module AppFixture
  # Yields an absolute `root` with app/assets/css/<files> written.
  def with_app(stylesheets, source_dir: "app/assets/css")
    Dir.mktmpdir do |root|
      dir = File.join(root, source_dir)
      FileUtils.mkdir_p(dir)
      stylesheets.each do |name, content|
        path = File.join(dir, name)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, content)
      end
      yield root
    end
  end

  def read_build(root, output, build_dir: "public/assets/css")
    File.read(File.join(root, build_dir, output))
  end
end
