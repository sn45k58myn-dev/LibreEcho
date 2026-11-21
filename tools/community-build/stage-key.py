"""Install only the owner's public verification key in the local Platform checkout."""
import hashlib
import os
from pathlib import Path
import subprocess
import sys

from nacl.signing import SigningKey

platform = Path("/build/sources/platform")
base = "160dd390362a1e322c8799b4be0ac3dd21f982a6"
relative = "tools/mt8163-arm32/ota/ota-public-key.hex"


def git(*args, env=None):
    return subprocess.check_output(["git", "-C", platform, *args], text=True, env=env).strip()


def stage(seed_path):
    if seed_path.is_symlink() or not seed_path.is_file():
        raise ValueError("Expected a regular file containing the owner's signing seed")
    public = SigningKey(bytes.fromhex(seed_path.read_text().strip())).verify_key.encode().hex() + "\n"
    if git("status", "--porcelain"):
        raise ValueError("Platform checkout has uncommitted changes")
    head = git("rev-parse", "HEAD")
    if head != base and (git("rev-parse", "HEAD^") != base or git("diff", "--name-only", base, head) != relative):
        raise ValueError("Unexpected Platform source for this release")
    dest = platform / relative
    if head != base and dest.read_text() != public:
        raise ValueError("This build volume belongs to a different signing key. Use a new volume.")
    if dest.read_text() != public:
        dest.write_text(public, encoding="ascii")
        git("add", "--", relative)
        # A stable, generic commit for this key makes resumed builds auditable.
        date = git("show", "-s", "--format=%cI", base)
        env = {**os.environ, "GIT_AUTHOR_DATE": date, "GIT_COMMITTER_DATE": date}
        git("-c", "user.name=Local LibreEcho builder", "-c", "user.email=builder@localhost",
            "commit", "-qm", "Use the owner's OTA verification key", env=env)
    print("OTA public-key file SHA-256", hashlib.sha256(dest.read_bytes()).hexdigest())


if __name__ == "__main__":
    stage(Path(sys.argv[1]))
