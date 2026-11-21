"""Fetch the CMake inputs for LibreEcho's two ARM32 ONNX Runtime builds."""

import argparse
import hashlib
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from tempfile import NamedTemporaryFile
from urllib.parse import urlsplit
from urllib.request import urlopen


# Both builds use the CPU provider, a Linux x86_64 host and an ARM hard-float target.
# URLs and expected archive hashes come from the checked-out runtime's dependency lock.
PACKAGES = {
    "abseil_cpp", "date", "eigen", "flatbuffers", "json", "microsoft_gsl", "mp11",
    "onnx", "protobuf", "protoc_linux_x64", "pytorch_cpuinfo", "re2", "safeint",
}


def fetch(entry, mirror):
    name, url, expected = entry
    parts = urlsplit(url)
    if parts.scheme != "https" or parts.netloc != "github.com" or ".." in parts.path.split("/"):
        raise ValueError(f"Unexpected dependency URL for {name}")
    # ORT mirrors absolute HTTPS URLs as <mirror>/<host>/<path>.
    dest = mirror / parts.netloc / parts.path.lstrip("/")
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.is_file():
        with dest.open("rb") as cached:
            if hashlib.file_digest(cached, "sha1").hexdigest() == expected:
                return
    with NamedTemporaryFile(dir=dest.parent, delete=False) as incomplete:
        path = Path(incomplete.name)
        try:
            digest = hashlib.sha1()
            with urlopen(url, timeout=120) as source:
                while chunk := source.read(256 * 1024):
                    digest.update(chunk)
                    incomplete.write(chunk)
            if digest.hexdigest() != expected:
                raise ValueError(f"Archive hash mismatch for {name}")
            incomplete.close()
            path.replace(dest)
        finally:
            incomplete.close()
            path.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ort_source", type=Path)
    parser.add_argument("mirror", type=Path)
    args = parser.parse_args()
    entries = []
    for row in (args.ort_source / "cmake/deps.txt").read_text().splitlines():
        if row and not row.startswith("#"):
            name, url, sha1 = row.split(";")
            if name in PACKAGES:
                entries.append((name, url, sha1))
    if len(entries) != len(PACKAGES) or {name for name, _, _ in entries} != PACKAGES:
        raise ValueError("Pinned ORT dependency list is incomplete")
    with ThreadPoolExecutor(max_workers=4) as pool:
        list(pool.map(lambda item: fetch(item, args.mirror), entries))
    print(f"Verified {len(entries)} cross-build dependency archives for ONNX Runtime")


if __name__ == "__main__":
    main()
