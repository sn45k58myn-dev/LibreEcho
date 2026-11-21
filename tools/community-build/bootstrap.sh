#!/usr/bin/env bash
# Run in the Ubuntu build container with its dedicated /build volume.
set -euo pipefail
recipe=$(cd -- "$(dirname -- "$0")" && pwd -P)
product=/build/sources/product
platform=/build/sources/platform
export RUNNER_TEMP=/build/tmp-other GITHUB_WORKSPACE=/build GIT_OPTIONAL_LOCKS=0
export GITHUB_OUTPUT="$RUNNER_TEMP/bootstrap-output" GITHUB_PATH="$RUNNER_TEMP/bootstrap-path"
export GIT_TERMINAL_PROMPT=0 PYTHONDONTWRITEBYTECODE=1
export PATH="$RUNNER_TEMP/host-bin:$RUNNER_TEMP/armhf-cross-shim:$PATH"
export LD_LIBRARY_PATH="$RUNNER_TEMP/host-bin:$RUNNER_TEMP/armhf-root/usr/lib/x86_64-linux-gnu"
cd "$product"

step() {
    /usr/bin/python3 "$recipe/workflow-step.py" "$@"
}

anchors() {
    # The target glibc linker scripts refer to these paths inside the container.
    local path expected
    for path in /usr/arm-linux-gnueabihf /usr/lib/gcc-cross/arm-linux-gnueabihf; do
        expected="$RUNNER_TEMP/armhf-root$path"
        if [[ -e "$path" || -L "$path" ]]; then
            [[ "$(readlink -f "$path")" == "$expected" ]] || {
                echo "Unexpected existing ARMHF sysroot at $path" >&2
                return 1
            }
        fi
    done
    step build-image "Anchor ARMHF sysroot at its packaged absolute paths"
    step build-image "Expose ARMHF cross tools on PATH"
}

case "${1:-}" in
    --anchors-only) anchors; exit ;;
    "") ;;
    *) echo "Usage: bootstrap.sh [--anchors-only]" >&2; exit 2 ;;
esac

mkdir -p "$RUNNER_TEMP"
exec 9>"$RUNNER_TEMP/bootstrap.lock"
flock -x 9
# Resume individual successful stages. Editing a later stage leaves verified
# earlier outputs usable in the same volume.
state="$RUNNER_TEMP/community-bootstrap"
mkdir -p "$state"

phase() {
    local name=$1 stamp digest
    shift
    stamp="$state/$name.done"
    digest=$({
        git rev-parse HEAD HEAD^{tree}
        printf '%s\n' "$@"
        if declare -F "$1" >/dev/null; then declare -f "$1"; fi
        sha256sum "$recipe/workflow-step.py"
        case "$name" in
            sources) sha256sum "$recipe/prepare-ort.py" "$recipe/stage-sources.py" ;;
            ort-mirror|neural) sha256sum "$recipe/prepare-wake-deps.py" "$recipe/cmake-with-ort-mirror" ;;
        esac
    } | sha256sum | cut -d' ' -f1)
    if [[ ! -f "$stamp" || $(cat "$stamp") != "$digest" ]]; then
        printf 'Preparing %s\n' "$name"
        "$@"
        printf '%s\n' "$digest" > "$stamp.new"
        mv -T "$stamp.new" "$stamp"
    fi
}

fetch_sources() {
    local input_dir="$RUNNER_TEMP/public-deps"
    local stage="$RUNNER_TEMP/public-deps.incomplete"
    local mirror="$RUNNER_TEMP/ort-public.git"
    python3 "$recipe/prepare-ort.py" "$mirror"
    # fetch-public-deps clones source-git inputs and requires a new path. Keep
    # incomplete work out of the final location on a network failure.
    rm -rf -- "$stage"
    if [[ -e "$input_dir" ]]; then
        # Power loss between rename and the phase marker still leaves a complete input set.
        (cd "$input_dir" && sha256sum --quiet -c SHA256SUMS)
        return
    fi
    python3 "$recipe/stage-sources.py" "$stage" "$mirror"
    (cd "$stage" && sha256sum --quiet -c SHA256SUMS)
    mv -T "$stage" "$input_dir"
}

cross_compiler() {
    apt-get update
    step prepare-public-inputs "Install public ARMHF build packages"
}

python_tools() {
    python3.11 -m venv "$RUNNER_TEMP/ota-build-venv"
    PATH="$RUNNER_TEMP/ota-build-venv/bin:$PATH" step build-image "Install reviewed OTA signing dependency closure"
    step build-image "Install the pinned mbedTLS build interpreter"
    step build-image "Derive reviewed TTS voice models"
}

mdns() {
    # The archive fallback returns to the Product checkout to read its lock.
    GITHUB_WORKSPACE="$product" step prepare-public-inputs "Acquire exact shared mDNS dependency packages"
    step prepare-public-inputs "Record exact shared mDNS package provenance"
    step build-image "Build and verify the shared mDNS discovery runtime"
}

host_tools() {
    step build-image "Stage qemu-arm-static for runtime contract checks"
    step build-image "Stage device-tree tools for the DTB contract"
    step build-image "Stage host build tools (xxd, mksquashfs, cpio)"
    (cd /build && step build-image "Export Linux UAPI headers")
}

phase sources fetch_sources
phase armhf cross_compiler
anchors
phase python python_tools
phase musl bash build/ci/build-public-toolchain.sh /build/toolchain
phase ort-mirror python3 "$recipe/prepare-wake-deps.py" "$RUNNER_TEMP/public-deps/onnxruntime-source" "$RUNNER_TEMP/ort-cmake-mirror"
install -D -m0755 "$recipe/cmake-with-ort-mirror" "$RUNNER_TEMP/host-bin/cmake"
phase neural bash build/ci/build-public-neural-deps.sh "$RUNNER_TEMP/public-deps" "$RUNNER_TEMP/armhf-root"
airplay() {
    # A failed download can leave this generated directory partially populated.
    # The upstream stage requires an empty destination on every rebuild.
    rm -rf -- "$RUNNER_TEMP/public-deps/airplay-sysroot"
    step build-image "Stage public ARMHF AirPlay sysroot"
}
phase airplay airplay
phase mdns mdns
phase host-tools host_tools
printf '%s\n' 'Public build dependencies ready.'
