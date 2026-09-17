# Changelog

All notable changes to **hanami-sasso** are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This gem versions independently of the `sasso` compiler gem — it depends on a
*range* of it, so its own number could not honestly name a compiler version.
Each release notes the range it requires; `Sasso::CORE_VERSION` reports the
compiler actually installed.

## [Unreleased]

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
  - Compressed `hsl`/`hwb` route through `rgb`, and a legacy color with a
    fractional channel writes percentages — `darken(#336699, 10%)` compresses to
    `rgb(15%,30%,45%)`, not `hsl(210,50%,30%)`.
  - Global `whiteness()` / `blackness()` are **no longer built-ins** and pass
    through as plain CSS (`whiteness(#f00)` instead of `0%`), matching dart-sass.
    Silent — no error, no warning — so grep for it.
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
