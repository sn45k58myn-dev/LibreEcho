#!/usr/bin/env bash
# Fetch only the four trees used for the Echo 2 0.16.8 release.
set -euo pipefail
export GIT_TERMINAL_PROMPT=0
mkdir -p /build/sources
fetch_source() {
    local component=$1 repository=$2 commit=$3 tree=$4
    local directory="/build/sources/$component" url="https://github.com/$repository.git"
    if [[ ! -d "$directory/.git" ]]; then
        git init -q "$directory"
        git -C "$directory" remote add origin "$url"
    fi
    [[ "$(git -C "$directory" remote get-url origin)" == "$url" ]]
    if ! git -C "$directory" cat-file -e "$commit^{commit}" 2>/dev/null; then
        git -C "$directory" fetch --quiet --no-tags --depth=1 origin "$commit"
    fi
    [[ "$(git -C "$directory" rev-parse "$commit^{tree}")" == "$tree" ]]
    # A resumed Platform build may have one local commit for the owner's public key.
    if [[ "$component" == platform ]] && git -C "$directory" rev-parse --verify HEAD^ >/dev/null 2>&1 &&
       [[ "$(git -C "$directory" rev-parse HEAD^)" == "$commit" ]]; then
        [[ "$(git -C "$directory" diff --name-only "$commit" HEAD)" == tools/mt8163-arm32/ota/ota-public-key.hex ]]
    else
        git -C "$directory" checkout --quiet --detach "$commit"
    fi
    [[ -z "$(git -C "$directory" status --porcelain)" ]]
    printf 'Verified %s at %s\n' "$component" "$commit"
}
fetch_source product sn45k58myn-dev/LibreEcho 595daa2a723f84204cd9cd6d5256ab0eab0ea10c 055071bc31ec3467e149ddd04dc2ec4c0c0e7996
fetch_source ui sn45k58myn-dev/LibreEcho-UI 984ebc22cf68f1900e931d1129357db91951ea06 41b650f94bd108acb2c57e6c073712cf70ce8dd6
fetch_source platform sn45k58myn-dev/LibreEcho-Platform 160dd390362a1e322c8799b4be0ac3dd21f982a6 14023617ec1e06167bd9ee35f7f70db369ad2a92
fetch_source linux aslater3/LibreEcho-Linux 5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0 a00c937c9ad7968de46ec5b8d08857b0c89a3fb7
