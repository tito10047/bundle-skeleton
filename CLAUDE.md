# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A **Composer project template**, not a bundle with source code. It is published as
`yceruto/bundle-skeleton` and consumed with:

```bash
composer create-project yceruto/bundle-skeleton <directory>
```

All generation is done by the Composer plugin [`yceruto/bundle-flex`](https://github.com/yceruto/bundle-flex),
required in `require-dev` and allowed in `config.allow-plugins`. On `post-create-project-cmd` it
asks its questions (or reads the `BUNDLE_FLEX_*` presets), removes the skeleton's own files
(`README.md`, `LICENSE`, `.github`, `.gitattributes`, `CLAUDE.md`), generates the bundle, rewrites
`composer.json`, runs one `composer update` and removes itself.

Generated bundles support Symfony 7.4 LTS, 8.0 and 8.1 (PHP 8.2+ for 7.4, 8.4+ for 8.x).

## Files

- `composer.json`: the only file that matters to the plugin. `require` is the minimum the
  plugin rewrites anyway (`php >=8.2`, `symfony/http-kernel ^7.4 || ^8.0`); `require-dev` is
  `yceruto/bundle-flex ^1.0`.
- `.gitignore`, `LICENSE`, `README.md`: shipped in the dist archive.
- `.gitattributes`: export-ignores `.github/`, `CLAUDE.md` and itself so `create-project`
  does not ship them.
- `.github/e2e.sh`, `.github/workflows/ci.yml`: the end-to-end smoke test.

## Rules when editing

- Changes to the generated bundle (layout, files, questions, dependencies) belong in
  `bundle-flex`, not here.
- **Keep `composer.json` minimal.** The plugin's `ComposerJsonWriter` replaces the keys it owns
  (name, description, license, type, keywords, authors, require, require-dev, autoload, scripts)
  and **keeps every other key** in the generated bundle. Never add `minimum-stability`,
  `prefer-stable`, `repositories`, `extra`, `homepage`, etc. here: they would leak into every
  generated bundle. The e2e test fails on `repositories`, `minimum-stability` and `prefer-stable`.
- `composer.json` must pass `composer validate --strict`; `sort-packages` is on, keep lists sorted.
- No `composer.lock`, no `vendor/` (gitignored).
- A new repository-only file must be export-ignored in `.gitattributes` (and the plugin's
  `BundleCreator::SKELETON_FILES` should remove it too).

## Testing

```bash
composer validate --strict

# End-to-end: create-project from this checkout with a local bundle-flex checkout.
BUNDLE_FLEX_NAME=acme/blog-bundle BUNDLE_FLEX_AUTHOR_NAME="Jane Doe" BUNDLE_FLEX_ALL=1 BUNDLE_FLEX_CONFIG_FORMAT=yaml \
  .github/e2e.sh ../bundle-flex /tmp/blog-bundle
```

`.github/e2e.sh <bundle-flex-dir> <target-dir>` exports the skeleton with `git archive`
(tracked files including uncommitted changes, export-ignore applied), declares the plugin as a
path repository with version `E2E_PLUGIN_VERSION` (default `1.0.0`, must satisfy the
`require-dev` constraint) in a temporary `COMPOSER_HOME`, so the skeleton `composer.json` is
used unmodified. It then checks the generated `composer.json` (no leaked keys, no plugin
reference), runs `composer validate --strict`, `dump-autoload --strict-psr`, `php -l`, and the
bundle's `composer qa` (or `composer test`).

CI runs it for PHP 8.2 (Symfony 7.4) and 8.5 (Symfony 8.x) × presets {minimal, all} × formats
{php, php-array, yaml}. The plugin is checked out from `BUNDLE_FLEX_REPOSITORY`@`BUNDLE_FLEX_REF`
(workflow_dispatch inputs or repository variables, default `tito10047/bundle-flex`@`feat/symfony-8`).
Lint workflows with `docker run --rm -v "$PWD:/repo" -w /repo rhysd/actionlint`.
