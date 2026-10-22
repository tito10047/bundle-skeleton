#!/usr/bin/env bash
#
# End-to-end trial of the skeleton: runs "composer create-project" against this
# checkout with the yceruto/bundle-flex plugin taken from a local directory, then
# checks the generated bundle.
#
# Usage: .github/e2e.sh <bundle-flex-dir> <target-dir>
#
# Answers are taken from the BUNDLE_FLEX_* environment variables (see README.md).
# E2E_PLUGIN_VERSION sets the version given to the local plugin; it must satisfy
# the skeleton's "yceruto/bundle-flex" constraint (default: 1.0.0).
#
# The skeleton is exported with "git archive" (tracked files, uncommitted changes
# included), so .gitattributes export-ignore rules apply as they do for the dist
# archive. Its composer.json is used unmodified: the plugin repository is declared
# in the global configuration of a temporary COMPOSER_HOME instead, so nothing
# test-specific can leak into the generated composer.json.

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <bundle-flex-dir> <target-dir>" >&2
    exit 64
fi

plugin_dir=$(realpath "$1")
target_dir=$(realpath -m "$2")
skeleton_dir=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
plugin_version=${E2E_PLUGIN_VERSION:-1.0.0}

fail() {
    echo "e2e: $*" >&2
    exit 1
}

group() {
    if [[ -n ${GITHUB_ACTIONS:-} ]]; then echo "::group::$*"; else echo "==> $*"; fi
}

endgroup() {
    if [[ -n ${GITHUB_ACTIONS:-} ]]; then echo "::endgroup::"; fi
}

[[ -f $plugin_dir/composer.json ]] || fail "$plugin_dir is not the bundle-flex repository"
[[ -e $target_dir ]] && fail "$target_dir already exists"

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

# Composer cache and credentials of the real home are kept.
COMPOSER_CACHE_DIR=${COMPOSER_CACHE_DIR:-$(composer config --global cache-dir)}
real_home=$(composer config --global home)
export COMPOSER_CACHE_DIR
export COMPOSER_HOME=$work_dir/composer-home
mkdir -p "$COMPOSER_HOME"
[[ -f $real_home/auth.json ]] && cp "$real_home/auth.json" "$COMPOSER_HOME/"

group "Export the skeleton"
mkdir "$work_dir/skeleton"
ref=$(git -C "$skeleton_dir" stash create)
git -C "$skeleton_dir" archive "${ref:-HEAD}" | tar -x -C "$work_dir/skeleton"
ls -A "$work_dir/skeleton"
for file in .gitattributes .github CLAUDE.md; do
    [[ -e $work_dir/skeleton/$file ]] && fail "$file is shipped in the dist archive, export-ignore it in .gitattributes"
done
endgroup

repository() {
    printf '{"type": "path", "url": "%s", "options": {"symlink": false, "versions": {"%s": "%s"}}}' "$1" "$2" "$3"
}

composer config --global repositories.bundle-flex "$(repository "$plugin_dir" yceruto/bundle-flex "$plugin_version")"

group "composer create-project"
composer create-project yceruto/bundle-skeleton "$target_dir" --no-interaction --no-progress \
    --repository="$(repository "$work_dir/skeleton" yceruto/bundle-skeleton 1.0.0)"
endgroup

cd "$target_dir"

group "Check the generated bundle"
# shellcheck disable=SC2016 # PHP code, not shell expansions
php -r '
    $json = json_decode(file_get_contents("composer.json"), true, flags: JSON_THROW_ON_ERROR);
    $errors = [];
    foreach (["repositories", "minimum-stability", "prefer-stable"] as $key) {
        if (array_key_exists($key, $json)) {
            $errors[] = "the skeleton leaked \"$key\"";
        }
    }
    if (str_contains(file_get_contents("composer.json"), "yceruto/bundle-flex")) {
        $errors[] = "yceruto/bundle-flex is still referenced";
    }
    if ("symfony-bundle" !== ($json["type"] ?? null)) {
        $errors[] = "the type is not \"symfony-bundle\"";
    }
    $name = getenv("BUNDLE_FLEX_NAME");
    if (false !== $name && $name !== ($json["name"] ?? null)) {
        $errors[] = "the name is not \"$name\"";
    }
    foreach ($errors as $error) {
        fwrite(STDERR, "e2e: composer.json: $error\n");
    }
    exit([] === $errors ? 0 : 1);
'
[[ -d vendor/yceruto/bundle-flex ]] && fail "the plugin is still installed"

composer validate --strict
composer dump-autoload --optimize --strict-psr

find . -path ./vendor -prune -o -name '*.php' -type f -print0 | xargs -0 -r -n1 php -l > /dev/null
endgroup

scripts=$(php -r 'echo implode("\n", array_keys(json_decode(file_get_contents("composer.json"), true)["scripts"] ?? []));')
for script in qa test; do
    if grep -qx "$script" <<< "$scripts"; then
        group "composer $script"
        composer "$script"
        endgroup
        exit 0
    fi
done

message='The generated bundle defines neither a "qa" nor a "test" script, only the static checks ran.'
if [[ -n ${GITHUB_ACTIONS:-} ]]; then echo "::warning::$message"; else echo "e2e: warning: $message" >&2; fi
