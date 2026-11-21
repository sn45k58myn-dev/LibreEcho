"""Verify the completed release using the public key and the installer's offline checks."""

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile

from nacl.signing import VerifyKey


def check_assets(assets: Path, public_key: Path, installer_path: Path) -> None:
    target = "radar_puffin"
    tag = assets.name
    prefix = f"libreecho-{tag}"
    packaged_key = (assets / f"{prefix}-ota-public-key.hex").read_bytes()
    if packaged_key != public_key.read_bytes():
        raise ValueError("Release key differs from the build verification key")
    if (assets / f"{prefix}-installer.py").read_bytes() != installer_path.read_bytes():
        raise ValueError("Packaged host installer differs from the pinned Product source")

    spec = importlib.util.spec_from_file_location("libreecho_offline_installer", installer_path)
    installer = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = installer
    sys.path.insert(0, str(installer_path.parent))
    spec.loader.exec_module(installer)
    with tempfile.TemporaryDirectory(prefix="echo2-first-install-") as cache:
        manifest, _ = installer._prepare(assets, Path(cache), tag, target)
    v3 = installer.load_v3_target(assets, tag, target)
    if v3 is None:
        raise ValueError("Missing signed v3 target generation")
    VerifyKey(bytes.fromhex(packaged_key.decode().strip())).verify(
        v3["manifest"], bytes.fromhex(v3["signature"].decode().strip())
    )
    installer._v3_matches_bundle(v3, manifest)
    plan = json.loads((assets / f"{prefix}-feature-plan.json").read_bytes())
    if plan["version"] != "0.16.8" or plan["release"] != tag or plan["board"] != target:
        raise ValueError("Wrong board, version or release in the feature plan")
    expected_features = {"airplay2", "assistant", "stt", "tts", "wakeword"}
    if set(v3["features"]) != expected_features:
        raise ValueError("Initial install must contain all five signed feature pairs")
    if manifest["ota_public_key"]["sha256"] != hashlib.sha256(packaged_key).hexdigest():
        raise ValueError("Initial install is bound to another public key")
    print("Offline first-install preparation, Ed25519 signature and five feature pairs passed")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("assets", type=Path)
    parser.add_argument("public_key", type=Path)
    parser.add_argument("installer", type=Path)
    args = parser.parse_args()
    check_assets(args.assets.resolve(), args.public_key.resolve(), args.installer.resolve())
