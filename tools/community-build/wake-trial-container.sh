#!/usr/bin/env bash
set -euo pipefail
# These public component pins determine the trial binary. The stable firmware
# builder has its own pins and remains a separate entry point.
ui_commit=fbb883a42c9bfe2169fa3b0fab0aa02d18afdb48
platform_commit=b6890c96560ec381882e6571eab495fd003922be
checkout() {
    local repo=$1 pin=$2 dest="/work/sources/$2"
    mkdir -p "$dest"
    git -C "$dest" init -q
    if ! git -C "$dest" cat-file -e "$pin^{commit}" 2>/dev/null; then
        git -C "$dest" fetch --no-tags --depth=1 "https://github.com/sn45k58myn-dev/$repo.git" "$pin"
    fi
    git -C "$dest" checkout -q --detach "$pin"
    [[ $(git -C "$dest" rev-parse HEAD) == "$pin" && -z $(git -C "$dest" status --porcelain) ]]
}
case ${1:-} in
    fetch)
        checkout LibreEcho-UI "$ui_commit"
        checkout LibreEcho-Platform "$platform_commit"
        exit ;;
    compile) ;;
    *) exit 2 ;;
esac
deps=/build/tmp-other
public=$deps/public-deps
cache=/work/cache/$platform_commit
run=$(mktemp -d /work/trial.XXXXXXXX)
trap 'rm -rf -- "$run"' EXIT
mkdir "$run/ui"
git -C "/work/sources/$ui_commit" archive "$ui_commit" | tar -xf - -C "$run/ui"
export PATH="$deps/host-bin:$deps/armhf-cross-shim:$PATH"
export LD_LIBRARY_PATH="$deps/armhf-root/usr/lib/x86_64-linux-gnu:$deps/host-bin"
export LIBREECHO_WAKE_CROSS="$deps/armhf-root/usr/bin/arm-linux-gnueabihf-"
export LIBREECHO_WAKE_FLATBUFFERS_PYTHON="$public/neural/flatbuffers-python"
export LIBREECHO_WAKE_RE2_ARCHIVE="$public/neural/onnxruntime-prefix/lib/libre2.a"
export LIBREECHO_WAKE_RELINK_OUTPUT="$run/relink" PYTHONDONTWRITEBYTECODE=1
bash /recipe/bootstrap.sh --anchors-only
platform="/work/sources/$platform_commit"
ort="$cache/onnxruntime-wake-reduced"
bash "$platform/tools/mt8163-arm32/wakeword/build_runtime.sh" "$run/ui" "$public/onnxruntime-source" \
    "$ort" "$public/speexdsp-SpeexDSP-1.2.1.tar.gz" "$cache/speex" "$run/waked"
make -C "$run/ui" -f Makefile -f tools/wake-trial.mk CROSS_COMPILE="$LIBREECHO_WAKE_CROSS" \
    WAKE_ORT_SOURCE="$public/onnxruntime-source" WAKE_ORT_BUILD="$ort" ARM_SPEEX_PREFIX="$cache/speex" \
    RE2_ARCHIVE="$LIBREECHO_WAKE_RE2_ARCHIVE" build/wake-trial-arm32
binary="$run/ui/build/wake-trial-arm32"
file -b "$binary" | grep -Eq 'ELF 32-bit.*ARM.*statically linked'
staged=$(mktemp /out/.wake-trial.XXXXXXXX)
trap 'rm -f -- "$staged"; rm -rf -- "$run"' EXIT
install -m 0755 "$binary" "$staged"
chown "$OUTPUT_UID:$OUTPUT_GID" "$staged"
mv -fT -- "$staged" /out/wake-trial-arm32
sha256sum /out/wake-trial-arm32
