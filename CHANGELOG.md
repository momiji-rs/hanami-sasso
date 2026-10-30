# Changelog

All notable changes to **hanami-sasso** are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This gem versions independently of the `sasso` compiler gem — it depends on a
*range* of it, so its own number could not honestly name a compiler version.
Each release notes the range it requires; `Sasso::CORE_VERSION` reports the
compiler actually installed.

## [Unreleased]

Works with the `sasso` gem **0.21.0**. The requirement stays **>= 0.14.0, < 1**.

### Changed

- **Verified against `sasso` 0.21.0** (core 0.21.0), green with no code change
  (9 runs, 30 assertions). The floor is not raised: this gem calls only
  `Sasso.compile`, whose signature 0.21.0 keeps, and a lower floor lets an app
  hold the compiler back while it fixes its stylesheets (below).
- **A `bundle update` can now break `sasso:compile`.** The `< 1` range admits
  0.21.0, and its compiler is stricter than 0.14's: some stylesheets that
  compiled before now raise `Sasso::CompileError`, which fails `sasso:compile`
  and therefore `assets:precompile`. The usual causes are a built-in given an
  argument name it does not declare (`math.max(1, 2, $x: 999)`), an argument
  passed both by position and by name, and selectors dart-sass's grammar rejects
  (`[a=1]`, `a^b`). Some output also changes, a few cases in meaning. The engine
  gem's
  [CHANGELOG](https://github.com/momiji-rs/sasso-ruby/blob/main/CHANGELOG.md)
  (section `0.21.0`) lists every change. To stay on the old compiler while you
  fix them, pin it in your app's Gemfile: `gem "sasso", "< 0.21"`.
- **A new warning, `bogus-combinators`**, prints during `sasso:compile` when a
  rule with a repeated or leading combinator (`a > + b`) is dropped. The rule was
  dropped before too, silently. This gem does not yet forward the engine's new
  `silence_deprecations:` option, so the warning can only be fixed at its source.

### Added

- Ruby 4.0 on the CI matrix. On 4.0, `sasso` resolves to 0.14.1 or later, the
  first release with a Ruby 4.0 binary.

## [0.1.3] - 2026-09-17

Now requires the `sasso` gem **>= 0.14.0** (was `>= 0.2.7`), and **Ruby >= 3.2**.

### Removed

- **Ruby 3.1 support** (`required_ruby_version` is now `>= 3.2.0`), following the
  `sasso` engine gem, which dropped it in 0.14.0. It is off the CI matrix too.

### Changed

- Bumped the `sasso` engine-gem floor to **>= 0.14.0**. From that release the
  engine gem's version tracks the compiler crate it bundles, so the floor names
  the compiler as well: core 0.14.0, at **dart-sass 1.104.1** parity, where 0.2.7
  carried core 0.6.3 (1.101.0).
- **Your compiled CSS changes**, because the compiler's output moved with the
  core. It remains byte-identical to dart-sass; it is not byte-identical to what
  0.2.7 wrote, so `assets:precompile` output — and anything digesting it — sees
  one round of churn. The engine gem's
  [CHANGELOG](https://github.com/momiji-rs/sasso-ruby/blob/main/CHANGELOG.md)
  lists every change; the two most likely to appear in a Hanami app:
  - **Serialization only** — the CSS means the same thing, spelled differently.
    Compressed `hsl`/`hwb` route through `rgb`, and a legacy color with a
    fractional channel writes percentages, so `darken(#336699, 10%)` compresses
    to `rgb(15%,30%,45%)` rather than `hsl(210,50%,30%)`.
  - **Not serialization only** — global `whiteness()` / `blackness()` are no
    longer built-ins and now pass through as plain CSS, matching dart-sass. This
    one changes what the browser does: `whiteness(#f00)` used to compile to `0%`,
    and now emits an unknown CSS function, which makes the declaration invalid
    and the browser drop it. It is also silent — no error, no warning — so it is
    the one to grep for. Use `color.whiteness()` via `@use "sass:color"`.
- No change to this gem's own rake tasks or configuration. Verified green against
  `sasso` 0.14.0 (9 runs, 30 assertions).

## [0.1.2] - 2026-06-25

### Changed

- Now requires the `sasso` gem **>= 0.2.7** (was `>= 0.2.3`), whose library API
  omits the trailing newline (adopting core sasso 0.6.3, byte-for-byte dart-sass
  parity). The compiler re-adds the conventional trailing newline when writing a
  build artifact, matching dart-sass's CLI for both styles: expanded builds are
  unchanged (and source-mapped expanded builds keep dart's blank line before the
  `sourceMappingURL` footer), and compressed builds now end with a single
  newline too (previously none).

## [0.1.1] - 2026-06-15

### Changed

- Now requires the `sasso` gem **>= 0.2.3**, which brings two dart-sass parity
  fixes contributed upstream by [@shyim](https://github.com/shyim):
  - `!default` no longer evaluates its right-hand side when the variable is
    already set (fixes a spurious "incompatible units" error in
    Bootstrap-on-Shopware setups).
  - Legacy `rgb()` / `hsl()` preserve the caller's `rgba` / `hsla` spelling in
    special-value passthroughs (e.g. `rgba(var(--bs-body-color-rgb), …)`), which
    Bootstrap relies on.

## [0.1.0] - 2026-06-14

Initial release. Requires the `sasso` gem **>= 0.2.0**; targets **Hanami 2.1+**.

### Added

- `sasso:compile` / `sasso:watch` / `sasso:clobber` rake tasks that compile
  configured Sass/SCSS entrypoints with the pure-Rust `sasso` compiler
  in-process (no Node, no Dart, no subprocess) and write the CSS into `public/`.
- Runs `sasso:compile` before Hanami's `assets:precompile` on deploy.
- `HanamiSasso.configure` for builds / style / load_paths / source_dir /
  build_dir / source_map (env-aware defaults: compressed + no map in production).
