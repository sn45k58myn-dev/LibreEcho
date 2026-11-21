#!/usr/bin/env bash
# Run on a Linux x86-64 host with Docker, Bash and Python 3.
set -euo pipefail
recipe=$(cd -- "$(dirname -- "$0")" && pwd -P)
state=${LIBREECHO_OWNER_DIR:-"$HOME/.local/share/libreecho-echo2"}
output=${1:-"$HOME/LibreEcho-builds/0.16.8"}
volume=${LIBREECHO_BUILD_VOLUME:-libreecho-community-0168}
jobs=${LIBREECHO_BUILD_JOBS:-2}
image=libreecho-echo2-community-builder:0.16.8
if [[ $# -gt 1 || "$output" == --help ]]; then
    echo 'Usage: bash tools/community-build/build.sh [output-directory]'
    exit "$(( $# > 1 ))"
fi
if [[ $(uname -s) != Linux || $(uname -m) != x86_64 ]]; then
    echo 'Run the builder on x86-64 Linux.' >&2
    exit 1
fi
for tool in docker python3 flock; do
    command -v "$tool" >/dev/null || { echo "Missing required command: $tool" >&2; exit 1; }
done
[[ $jobs =~ ^[1-9][0-9]*$ ]] || { echo 'LIBREECHO_BUILD_JOBS must be a positive integer.' >&2; exit 1; }
umask 077
mkdir -p -- "$state" "$output"
state=$(cd -- "$state" && pwd -P)
output=$(cd -- "$output" && pwd -P)
exec 9>"$state/build.lock"
flock -n 9 || { echo "A build is already running for this owner directory." >&2; exit 1; }
seed="$state/ota-seed.hex"
python3 - "$seed" <<'PY'
import os
import re
import secrets
import sys
from pathlib import Path
from tempfile import NamedTemporaryFile

p = Path(sys.argv[1])
if p.exists() or p.is_symlink():
    if p.is_symlink() or not p.is_file() or not re.fullmatch(rb"[0-9a-fA-F]{64}\n?", p.read_bytes()):
        raise SystemExit("The existing signing seed is invalid. Check your backup before continuing.")
    if p.stat().st_mode & 0o077:
        raise SystemExit("Make the signing seed private to its owner (chmod 600) before continuing.")
else:
    # Install a fully written file without replacing any existing identity.
    with NamedTemporaryFile(mode="w", dir=p.parent) as temporary:
        temporary.write(secrets.token_hex(32) + "\n")
        temporary.flush()
        os.fsync(temporary.fileno())
        os.link(temporary.name, p)
    print("Created your OTA signing key. Back it up privately before using the firmware.")
PY
# The build context contains only the public recipe, with no output or host key.
docker build --platform linux/amd64 -t "$image" "$recipe"
docker volume create "$volume" >/dev/null
common=(--rm --platform linux/amd64 --mount "type=volume,src=$volume,dst=/build" --mount "type=bind,src=$recipe,dst=/recipe,readonly")
lock=(flock --exclusive /build/community-build.lock)
docker run "${common[@]}" -e "JOBS=$jobs" "$image" "${lock[@]}" bash -ec 'bash /recipe/sources.sh; bash /recipe/bootstrap.sh'
docker run "${common[@]}" --network none -e "LIBREECHO_BUILD_JOBS=$jobs" --mount "type=bind,src=$seed,dst=/owner/ota-seed.hex,readonly" \
    --mount "type=bind,src=$output,dst=/out" -e "OUTPUT_UID=$(id -u)" -e "OUTPUT_GID=$(id -g)" \
    "$image" "${lock[@]}" bash /recipe/image.sh
printf 'Verified release directory under %s\n' "$output"
