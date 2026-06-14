# hanami-sasso

Compile **Sass/SCSS in [Hanami](https://hanamirb.org) 2.1+** with
[**sasso**](https://github.com/momiji-rs/sasso-ruby) — a pure-Rust,
zero-dependency, byte-for-byte [dart-sass](https://sass-lang.com) alternative.

Hanami's assets pipeline is esbuild-based with no native Sass step. This gem adds
`sasso:compile` / `sasso:watch` / `sasso:clobber` rake tasks that compile your
Sass/SCSS **in-process** — no Node toolchain, no Dart VM, no subprocess — and
write the CSS straight into `public/`.

- **No Node for CSS.** Compile Sass with zero JavaScript tooling.
- **In-process.** No process spawn per build — sasso is a native Ruby gem.
- **Byte-for-byte dart-sass.** Same CSS as `dart-sass`, just faster.

## Installation

```ruby
# Gemfile
gem "hanami-sasso"
```

```sh
bundle install
```

Load the rake tasks from your `Rakefile` (after Hanami's, so the
`assets:precompile` hook attaches):

```ruby
# Rakefile
require "hanami/rake_tasks"
require "hanami-sasso/rake_tasks"
```

Put your entrypoint (and partials) in `app/assets/css/` — e.g.
`app/assets/css/app.scss`. Compile it:

```sh
bundle exec rake sasso:compile     # -> public/assets/css/app.css
bundle exec rake sasso:watch       # recompile on change
bundle exec rake sasso:clobber     # remove generated CSS
```

`sasso:compile` runs automatically before `assets:precompile`, so deploys
regenerate the CSS. Link it from your layout:

```erb
<link rel="stylesheet" href="/assets/css/app.css">
```

## Configuration

Configure in your `Rakefile` (or a `config/sasso.rb` you require) — all optional,
defaults shown:

```ruby
HanamiSasso.configure do |c|
  # { "<input under source_dir>" => "<output under build_dir>" }
  c.builds     = { "app.scss" => "app.css" }
  # nil = :compressed in production (HANAMI_ENV=production), :expanded else.
  c.style      = nil
  c.load_paths = []                      # extra @use/@import dirs
  c.source_dir = "app/assets/css"
  c.build_dir  = "public/assets/css"     # compiled straight into public/
  c.source_map = nil                     # nil = sidecar .map outside production
end
```

> **Prefer Hanami's esbuild pipeline?** Set `c.build_dir = "app/assets/css"` and
> `import` the compiled `.css` from `app/assets/js/app.js`; esbuild will then
> bundle and fingerprint it. The default compiles straight into `public/` so
> CSS needs no Node at all.

## Performance

`sasso` compiles the same CSS as dart-sass, byte-for-byte, but much faster — and
with no Node runtime. Benchmarked on an Apple M2 Max, all engines dart-sass
1.101, against the Node frontend's default Sass engine (`sass`, dart2js):

**In-process** (how this gem compiles — inside the Ruby process):

| workload | hanami-sasso | Node `sass` (dart2js) |
|----------|--------------|-----------------------|
| ~360 rules  | **1.2 ms** | 8.0 ms (**6.4× slower**) |
| ~3000 rules | **9.9 ms** | 71.5 ms (**7.2× slower**) |

**Cold per-build** (one-shot compile incl. runtime startup):

| workload | hanami-sasso | dart-sass (native) | Node `sass` (dart2js) |
|----------|--------------|--------------------|-----------------------|
| ~360 rules  | **3.0 ms** | 27.5 ms (9×) | 185 ms (**63× slower**) |
| ~3000 rules | **10.9 ms** | 64.2 ms (6×) | 348 ms (**32× slower**) |

Output is byte-identical to dart-sass, so this is pure speedup with no behavior
change. (Synthetic workloads; ratios are the takeaway, absolute numbers are
machine-specific.)

## License

MIT, matching the Sass ecosystem. (The core `sasso` compiler crate is dual
MIT OR Apache-2.0.)
