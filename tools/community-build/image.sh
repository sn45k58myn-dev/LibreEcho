#!/usr/bin/env bash
set -euo pipefail
recipe=$(cd "$(dirname "$0")" && pwd)
deps=/build/tmp-other
export LIBREECHO_PUBLIC_DEPS_ROOT="$deps/public-deps"
export LIBREECHO_PRODUCT_SRC=/build/sources/product LIBREECHO_TOOLING_SRC=/build/sources/platform
export LIBREECHO_KERNEL_SRC=/build/sources/linux LIBREECHO_UI_SRC=/build/sources/ui
export LIBREECHO_KERNEL_OUT=/build/kernel-out LIBREECHO_COMPONENT_CACHE_ROOT=/build/component-cache
export LIBREECHO_REUSE_COMPONENT_CACHE=1 GIT_OPTIONAL_LOCKS=0 PYTHONDONTWRITEBYTECODE=1
export RUNNER_TEMP=/build/runtime GITHUB_WORKSPACE=/build
export GITHUB_PATH="$RUNNER_TEMP/github-path" GITHUB_OUTPUT="$RUNNER_TEMP/github-output"
install -d -m 0700 /scratch "$RUNNER_TEMP"
export TMPDIR=/scratch LE_AUDIO_ENGINE_SENDPIN_FIXTURE_ROOT=/scratch/ase LE_AUDIO_ENGINE_SENDPIN_SCRATCH_ROOT=/scratch
export PATH="$deps/ota-build-venv/bin:$deps/host-bin:$deps/armhf-cross-shim:$PATH"
export LD_LIBRARY_PATH="$deps/armhf-root/usr/lib/x86_64-linux-gnu:$deps/host-bin"
bash "$recipe/bootstrap.sh" --anchors-only
export LIBREECHO_MUSL_SYSROOT=/build/toolchain LIBREECHO_OTA_MUSL_NATIVE_ROOT=/build/toolchain LIBREECHO_OTA_MUSL_SYSROOT=/build/toolchain
export LIBREECHO_MUSL_CROSS_PREFIX=/build/toolchain/usr/bin/armv7-alpine-linux-musleabihf- AUDIO_CC=/build/toolchain/usr/bin/armv7-alpine-linux-musleabihf-gcc
export CROSS="$deps/armhf-root/usr/bin/arm-linux-gnueabihf-" LIBREECHO_UI_CROSS="$deps/armhf-root/usr/bin/arm-linux-gnueabihf-"
export LIBREECHO_CORE_RUNTIME_SYSROOT="$deps/armhf-root/usr/arm-linux-gnueabihf" LIBREECHO_CORE_GCC_LIBDIR="$deps/armhf-root/usr/lib/gcc-cross/arm-linux-gnueabihf/13"
src=$LIBREECHO_PUBLIC_DEPS_ROOT
export LIBREECHO_BUSYBOX_SOURCE_ARCHIVE="$src/busybox-1.37.0.tar.bz2" LIBREECHO_MUSL_SOURCE_ARCHIVE="$src/musl-1.2.5.tar.gz"
export LIBREECHO_WPA_SUPPLICANT_SOURCE_ARCHIVE="$src/wpa_supplicant-2.10.tar.gz" LIBREECHO_LIBNL_SOURCE_ARCHIVE="$src/libnl-3.11.0.tar.gz"
export LIBREECHO_WIRELESS_TOOLS_SOURCE_ARCHIVE="$src/wireless-tools_30~pre9.orig.tar.gz" LIBREECHO_WIRELESS_REGDB_SOURCE_ARCHIVE="$src/wireless-regdb-2025.10.07.tar.xz"
export LIBREECHO_LIBSODIUM_SOURCE_ARCHIVE="$src/libsodium-1.0.18.tar.gz" LIBREECHO_ADBD_SOURCE="$src/aosp-system-core"
export LIBREECHO_ADBD_KERNEL_HEADERS="$deps/kernel-uapi/include" LIBREECHO_OPUS_ARCHIVES_DIR="$src"
export LIBREECHO_MBEDTLS_SOURCE_ARCHIVE="$src/mbedtls-3.6.7.tar.bz2" LIBREECHO_MBEDTLS_BUILD_PYTHON="$deps/mbedtls-build-venv/bin/python"
export LIBREECHO_TTS_NORTHERN_MALE_MODEL="$src/northern-male.derived.onnx" LIBREECHO_TTS_FEMALE_MODEL="$src/southern-female.derived.onnx"
export LIBREECHO_TTS_TOKENS="$src/tts-tokens.txt" LIBREECHO_STT_MODEL_ROOT="$src"
export LIBREECHO_WAKE_ORT_SOURCE="$src/onnxruntime-source" LIBREECHO_ORT_BUILD="$src/neural/onnxruntime-build"
export LIBREECHO_ORT_PREFIX="$src/neural/onnxruntime-prefix" LIBREECHO_WAKE_FLATBUFFERS_PYTHON="$src/neural/flatbuffers-python"
export LIBREECHO_SHERPA_SOURCE="$src/sherpa-onnx-source" LIBREECHO_SHERPA_PREFIX="$src/neural/sherpa-onnx-prefix"
export LIBREECHO_ESPEAK_SOURCE="$src/espeak-ng-source" LIBREECHO_TTS_ESPEAK_DATA="$src/neural/espeak-ng-data"
export LIBREECHO_AIRPLAY_SYSROOT="$src/airplay-sysroot" LIBREECHO_AIRPLAY_CXX="$deps/armhf-root/usr/bin/arm-linux-gnueabihf-g++"
export LIBREECHO_AIRPLAY_ALSA_DATA="$src/airplay-sysroot/usr/share/alsa"
export LIBREECHO_AIRPLAY_ALSA_DATA_COPYRIGHT="$src/airplay-sysroot/usr/share/doc/libasound2-data/copyright"
export LIBREECHO_AIRPLAY_ALSA_UCM_COPYRIGHT="$src/airplay-sysroot/usr/share/doc/alsa-ucm-conf/copyright"
export LIBREECHO_FLITE_SOURCE="$src/flite-source" LIBREECHO_FLITE_ROOT="$src/neural/flite-root" LIBREECHO_SPEEX_PREFIX="$src/neural/speexdsp-prefix"
export LIBREECHO_MDNS_RUNTIME_ROOT="$deps/mdns-runtime" LIBREECHO_MDNS_RUNTIME_SOURCE_MAP="$deps/mdns-runtime-provenance.json"
export LIBREECHO_MDNS_RUNTIME_MANIFEST_SHA256
LIBREECHO_MDNS_RUNTIME_MANIFEST_SHA256=$(sha256sum "$deps/mdns-runtime/manifest.json" | cut -d' ' -f1)

export LIBREECHO_OTA_SIGNING_KEY="${LIBREECHO_OWNER_SEED:-/owner/ota-seed.hex}"
export LIBREECHO_OTA_SIGNING_MODE=local LIBREECHO_OTA_FORMAT=v3 LIBREECHO_OTA_RELEASE=0.16.8
export LIBREECHO_TARGETS=radar_puffin LIBREECHO_SSH_ENABLED=0 LIBREECHO_UPDATE_CHANNEL=dev
export LIBREECHO_PRIVATE_ROOT=/build/owner-build-inputs
install -d -m 0700 "$LIBREECHO_PRIVATE_ROOT"
python "$recipe/stage-key.py" "$LIBREECHO_OTA_SIGNING_KEY"
export LIBREECHO_OTA_EXPECTED_PUBLIC_KEY_SHA256
LIBREECHO_OTA_EXPECTED_PUBLIC_KEY_SHA256=$(sha256sum "$LIBREECHO_TOOLING_SRC/tools/mt8163-arm32/ota/ota-public-key.hex" | cut -d' ' -f1)
[[ "$(cat "$LIBREECHO_UI_SRC/VERSION")" == 0.16.8 ]]
source_id=$(for repo in product platform linux ui; do git -C "/build/sources/$repo" rev-parse HEAD; done | sha256sum | cut -c1-16)
short=$(git -C "$LIBREECHO_PRODUCT_SRC" rev-parse --short=7 HEAD)
export LIBREECHO_TARGET_RELEASE_TAG="radar-puffin-build-$short-$source_id-$(date -u +%Y%m%d%H%M%S%2N)"
export LIBREECHO_BUILD_ROOT="/build/runs/$LIBREECHO_TARGET_RELEASE_TAG"
mkdir -p "$LIBREECHO_BUILD_ROOT"
log="$LIBREECHO_BUILD_ROOT/build.log"
cd "$LIBREECHO_PRODUCT_SRC"
bash build/ci/build-public-release.sh --targets radar_puffin --release-output image-and-features --no-publish | tee "$log"
run=$(sed -n 's/^run=//p' "$log" | tail -n 1)
[[ "$run" == "$LIBREECHO_BUILD_ROOT"/out/runs/* && -f "$run/CURRENT.candidate" ]]
bash "$recipe/package.sh" "$run"
