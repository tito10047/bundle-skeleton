# Symfony Bundle Skeleton

Create a new Symfony bundle in seconds. An [assistant](https://github.com/yceruto/bundle-flex) asks
a few questions and generates a bundle that follows the
[Symfony bundle best practices](https://symfony.com/doc/current/bundles/best_practices.html):
tested, documented and ready to publish.

## Requirements

- PHP 8.2 or higher
- Composer 2.6 or higher

Generated bundles support these Symfony versions:

| Symfony | PHP |
|---|---|
| 7.4 (LTS) | 8.2+ |
| 8.0 | 8.4+ |
| 8.1 | 8.4+ |

## Usage

```console
$ composer create-project yceruto/bundle-skeleton acme-blog-bundle
```

The assistant asks its questions, shows a summary of the names it derived and asks for
a confirmation. It then generates the bundle, installs its dependencies with a single
`composer update` and removes itself: the bundle does not depend on the skeleton.

### Questions

| Question | Default |
|---|---|
| Package name (`vendor/name`, the `-bundle` suffix is recommended) | `<GitHub user or "acme">/<directory name>-bundle` |
| Description | `<BundleClass> for Symfony` |
| Author name and email | your Git configuration |
| License | `MIT` |
| Configuration format of services and routes: `php`, `php-array` or `yaml` | `php` |

Every name is derived from the package name, e.g. `acme/blog-bundle` gives the namespace
`Acme\BlogBundle`, the class `AcmeBlogBundle`, the extension alias `acme_blog`, and
`AcmeBlog` as translation domain and Twig namespace.

Then, one question per feature:

| Feature | Default | Generates |
|---|---|---|
| Semantic configuration | yes | `config/definition.php`, loaded by the bundle class |
| Controllers | no | an invokable controller and `config/routes.<format>` |
| Twig templates | yes with controllers | `templates/`, namespaced `@AcmeBlog` |
| Translations | no | `translations/AcmeBlog.en.xlf` |
| Console command | no | an invokable command in `src/Command/` |
| Event listener | no | a listener in `src/EventListener/` |
| Doctrine entity | no | an entity in `src/Entity/` with its XML mapping in `config/doctrine/` |
| Public assets | no | `public/`, installed by `assets:install` |
| Symfony UX | no | a Stimulus controller in `assets/` |
| PHPStan | yes | `phpstan.dist.neon` (level max) |
| PHP-CS-Fixer | yes | `.php-cs-fixer.dist.php` (Symfony coding standards) |
| Rector | yes | `rector.php` |
| GitHub Actions | yes | a CI workflow testing every supported PHP and Symfony version |

Every bundle also gets a `composer.json`, `README.md`, `LICENSE`, `docs/index.md`, explicit
service definitions (no autowiring, private services) and PHPUnit tests with a test kernel.
Run `composer qa` in the generated bundle to run all its checks at once.

### Without interaction

Every answer can be preset with an environment variable. With `--no-interaction` presets
are used as is, otherwise they are proposed as default answers.

```console
$ BUNDLE_FLEX_NAME=acme/blog-bundle BUNDLE_FLEX_CONFIG_FORMAT=yaml BUNDLE_FLEX_ALL=1 \
  composer create-project yceruto/bundle-skeleton acme-blog-bundle --no-interaction
```

| Variable | Value |
|---|---|
| `BUNDLE_FLEX_NAME` | Composer package name, e.g. `acme/blog-bundle` |
| `BUNDLE_FLEX_DESCRIPTION` | package description |
| `BUNDLE_FLEX_AUTHOR_NAME`, `BUNDLE_FLEX_AUTHOR_EMAIL` | author (defaults to your Git configuration; `none` omits the email) |
| `BUNDLE_FLEX_LICENSE` | `MIT` (default), `Apache-2.0`, `BSD-2-Clause`, `BSD-3-Clause`, `GPL-3.0-or-later`, `LGPL-3.0-or-later`, `MPL-2.0`, `proprietary` |
| `BUNDLE_FLEX_CONFIG_FORMAT` | `php` (default), `php-array` or `yaml` |
| `BUNDLE_FLEX_ALL` | `1` enables every feature, `0` disables them all |
| `BUNDLE_FLEX_<FEATURE>` | `1` or `0` for a single feature, takes precedence over `BUNDLE_FLEX_ALL` |

Feature variables: `BUNDLE_FLEX_CONFIG`, `BUNDLE_FLEX_CONTROLLERS`, `BUNDLE_FLEX_TWIG`,
`BUNDLE_FLEX_TRANSLATIONS`, `BUNDLE_FLEX_COMMAND`, `BUNDLE_FLEX_EVENT_LISTENER`,
`BUNDLE_FLEX_DOCTRINE`, `BUNDLE_FLEX_PUBLIC_ASSETS`, `BUNDLE_FLEX_UX`, `BUNDLE_FLEX_PHPSTAN`,
`BUNDLE_FLEX_CS_FIXER`, `BUNDLE_FLEX_RECTOR`, `BUNDLE_FLEX_CI`. Booleans also accept
`true`/`false`, `yes`/`no`, `y`/`n` and `on`/`off`.

## Example

`acme/blog-bundle` with every feature enabled and the `php` format:

```
acme-blog-bundle/
├── .github/workflows/ci.yml
├── assets/
├── config/
│   ├── definition.php
│   ├── doctrine/
│   ├── routes.php
│   └── services.php
├── docs/index.md
├── public/
├── src/
│   ├── AcmeBlogBundle.php
│   ├── Command/
│   ├── Controller/
│   ├── Entity/
│   └── EventListener/
├── templates/
├── tests/
├── translations/AcmeBlog.en.xlf
├── .gitattributes
├── .gitignore
├── .php-cs-fixer.dist.php
├── composer.json
├── LICENSE
├── phpstan.dist.neon
├── phpunit.dist.xml
├── README.md
└── rector.php
```

## Learn more

- [Best Practices for Reusable Bundles](https://symfony.com/doc/current/bundles/best_practices.html)
- [Create a UX bundle](https://symfony.com/doc/current/frontend/create_ux_bundle.html)
- [The assistant (yceruto/bundle-flex)](https://github.com/yceruto/bundle-flex), to report issues with the generated code or to contribute

## License

This software is published under the [MIT License](LICENSE).
