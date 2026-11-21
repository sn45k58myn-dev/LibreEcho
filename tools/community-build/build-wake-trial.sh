#!/usr/bin/env bash
# Build a standalone on-device wake-word comparison tool on x86-64 Linux.
set -euo pipefail
recipe=$(cd -- "$(dirname -- "$0")" && pwd -P)
out=${1:-"$PWD/wake-trial-output"}
jobs=${LIBREECHO_BUILD_JOBS:-2}
deps_volume=${LIBREECHO_BUILD_VOLUME:-libreecho-wake-trial-dependencies}
dev_volume=${LIBREECHO_WAKE_TRIAL_VOLUME:-libreecho-wake-trial-work}
if [[ $# -gt 1 || $out == --help ]]; then
    echo 'Usage: bash tools/community-build/build-wake-trial.sh [output-directory]'
    exit "$(( $# > 1 ))"
fi
[[ $(uname -s)/$(uname -m) == Linux/x86_64 && $jobs =~ ^[1-9][0-9]*$ && $deps_volume != "$dev_volume" ]] || {
    echo 'Use x86-64 Linux, a positive build job count and two distinct Docker volumes.' >&2
    exit 1
}
mkdir -p -- "$out"
out=$(cd -- "$out" && pwd -P)
iid=$(mktemp)
trap 'rm -f -- "$iid"' EXIT
docker build --platform linux/amd64 --iidfile "$iid" "$recipe"
image=$(<"$iid")
common=(--rm --platform linux/amd64 -e "JOBS=$jobs"
    --mount "type=volume,src=$deps_volume,dst=/build"
    --mount "type=volume,src=$dev_volume,dst=/work"
    --mount "type=bind,src=$recipe/wake-trial-container.sh,dst=/trial.sh,readonly")
lock=(flock --exclusive /build/community-build.lock flock --exclusive /work/trial.lock)
docker run "${common[@]}" "$image" "${lock[@]}" bash -ec 'bash /recipe/sources.sh; bash /recipe/bootstrap.sh; bash /trial.sh fetch'
docker run "${common[@]}" --network none --mount "type=bind,src=$out,dst=/out" \
    -e "OUTPUT_UID=$(id -u)" -e "OUTPUT_GID=$(id -g)" "$image" "${lock[@]}" bash /trial.sh compile
