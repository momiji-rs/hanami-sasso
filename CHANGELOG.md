# Changelog

All notable changes to **hanami-sasso** are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
