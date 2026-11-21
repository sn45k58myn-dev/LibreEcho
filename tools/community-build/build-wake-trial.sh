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
state=$(mktemp -d)
trap 'rm -rf -- "$state"' EXIT
install -m 0644 "$recipe/wake-trial-container.sh" "$state/trial.sh"
docker build --platform linux/amd64 --iidfile "$state/image-id" "$recipe"
image=$(<"$state/image-id")
[[ $image =~ ^sha256:[0-9a-f]{64}$ ]] || { echo 'Docker did not return an image ID.' >&2; exit 1; }
common=(--rm --platform linux/amd64 -e "JOBS=$jobs"
    --mount "type=volume,src=$dev_volume,dst=/work"
    --mount "type=bind,src=$state/trial.sh,dst=/trial.sh,readonly")
work_lock=(flock --exclusive /work/trial.lock)
docker run "${common[@]}" --mount "type=volume,src=$deps_volume,dst=/build" \
    "$image" flock --exclusive /build/community-build.lock "${work_lock[@]}" bash -ec 'bash /recipe/sources.sh; bash /recipe/bootstrap.sh; bash /trial.sh fetch'
docker run "${common[@]}" --network none --mount "type=volume,src=$deps_volume,dst=/build,readonly" \
    --mount "type=bind,src=$out,dst=/out" \
    -e "OUTPUT_UID=$(id -u)" -e "OUTPUT_GID=$(id -g)" "$image" flock --shared /build/community-build.lock "${work_lock[@]}" bash /trial.sh compile
