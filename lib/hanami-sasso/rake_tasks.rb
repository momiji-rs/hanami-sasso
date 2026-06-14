# frozen_string_literal: true

require "rake"
require "hanami-sasso"

# Adds `sasso:compile` / `sasso:watch` / `sasso:clobber`, and runs `sasso:compile`
# before Hanami's `assets:precompile` on deploy. Require this AFTER
# `require "hanami/rake_tasks"` in your Rakefile so the precompile hook attaches:
#
#   # Rakefile
#   require "hanami/rake_tasks"
#   require "hanami-sasso/rake_tasks"
#   HanamiSasso.configure { |c| c.builds = { "app.scss" => "app.css" } }  # optional

namespace :sasso do
  desc "Compile Sass/SCSS entrypoints with sasso"
  task :compile do
    HanamiSasso.compiler.build
  end

  desc "Watch sources and recompile on change"
  task :watch do
    HanamiSasso.compiler.watch
  end

  desc "Remove the generated CSS"
  task :clobber do
    HanamiSasso.compiler.clobber
  end
end

# Compile before Hanami fingerprints/serves assets on deploy. No-op if the
# Hanami assets tasks weren't loaded before this file.
Rake::Task["assets:precompile"].enhance(["sasso:compile"]) if Rake::Task.task_defined?("assets:precompile")
