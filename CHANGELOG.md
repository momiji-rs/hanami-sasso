# Changelog

All notable changes to **hanami-sasso** are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.1.0] - 2026-06-14

Initial release. Requires the `sasso` gem **>= 0.2.0**; targets **Hanami 2.1+**.

### Added

- `sasso:compile` / `sasso:watch` / `sasso:clobber` rake tasks that compile
  configured Sass/SCSS entrypoints with the pure-Rust `sasso` compiler
  in-process (no Node, no Dart, no subprocess) and write the CSS into `public/`.
- Runs `sasso:compile` before Hanami's `assets:precompile` on deploy.
- `HanamiSasso.configure` for builds / style / load_paths / source_dir /
  build_dir / source_map (env-aware defaults: compressed + no map in production).
