#!/usr/bin/env bash
# Package a completed, signed Radar/Puffin build and run local-file checks.
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: bash package.sh <completed-image-run>" >&2
    exit 2
fi
run=$(realpath -e -- "$1")
test -f "$run/CURRENT.candidate"
if [[ -v OUTPUT_UID || -v OUTPUT_GID ]]; then
    if [[ ! ${OUTPUT_UID:-} =~ ^[0-9]+$ || ! ${OUTPUT_GID:-} =~ ^[0-9]+$ ]]; then
        echo "OUTPUT_UID and OUTPUT_GID must both be numeric" >&2
        exit 2
    fi
fi
script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
sources=/build/sources
product="$sources/product"
platform="$sources/platform"
target=radar_puffin
public_key="$platform/tools/mt8163-arm32/ota/ota-public-key.hex"
: "${LIBREECHO_OTA_EXPECTED_PUBLIC_KEY_SHA256:?missing build verification-key digest}"
export PYTHONDONTWRITEBYTECODE=1 LIBREECHO_PLATFORM_SOURCE="$platform"

cd -- "$product"
for component in product platform linux ui; do
    git -C "$sources/$component" diff --quiet HEAD --
    printf '%s=%s\n' "$component" "$(git -C "$sources/$component" rev-parse --verify HEAD)"
done > "$run/release-source-commits.txt"
printf '%s  %s\n' "$LIBREECHO_OTA_EXPECTED_PUBLIC_KEY_SHA256" "$public_key" | sha256sum --check --status
install -m 0644 -- "$public_key" "$run/ota-public-key.hex"

python3 build/ci/release_completeness.py stage --run "$run" --target "$target"
python3 build/ci/release_completeness.py check --run "$run" --target "$target" \
    --builder "$platform/tools/mt8163-arm32/recovery-install"
tag=$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["release"])' "$run/feature-plan.json")
if [[ ! $tag =~ ^radar-puffin-build-[a-f0-9]{7}-[a-f0-9]{16}-[a-f0-9]{16}$ ]]; then
    echo "Unexpected development release tag" >&2
    exit 1
fi
if [[ -e /out/$tag || -L /out/$tag ]]; then
    echo "Release output already exists: /out/$tag" >&2
    exit 1
fi
stage=$(mktemp -d /out/.echo2-package.XXXXXXXX)
trap 'rm -rf -- "$stage"' EXIT
assets="$stage/$tag"
python3 build/ci/prepare-dev-release.py --target "$target" --artifact-root "$run" \
    --product-commit "$(git rev-parse --verify HEAD)" --release-kind development --output-dir "$assets"
python3 build/ci/release_completeness.py check --assets "$assets" --target "$target"
python3 "$script_dir/verify.py" "$assets" "$public_key" "$product/tools/libreecho-install.py"
if [[ -v OUTPUT_UID ]]; then
    chown -h -- "+$OUTPUT_UID:+$OUTPUT_GID" "$assets" "$assets"/*
fi
mv -nT -- "$assets" "/out/$tag"
if [[ -d $assets ]]; then
    echo "A concurrent build created /out/$tag" >&2
    exit 1
fi
printf 'Verified 0.16.8 first-install and signed OTA files in /out/%s\n' "$tag"
