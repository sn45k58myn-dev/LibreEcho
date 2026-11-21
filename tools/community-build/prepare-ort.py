"""Materialize the public ONNX Runtime source pin used by the 0.16.8 builder."""
import hashlib
from pathlib import Path
import subprocess
import sys
import tempfile
from urllib.request import Request, urlopen

COMMIT = "8f0278c77bf44b0cc83c098c6c722b92a36ac4b5"
TREE = "5ea4a49d0be5e5a620cabaa01f85d924b2fa5995"
PACK_SHA256 = "6cc3dbb41072be096e078a7e3d93e44f23663e6342fded069906133bc32f64df"
SIZE = 247947046
URL = ("https://github.com/sn45k58myn-dev/LibreEcho/releases/download/"
       "echo2-source-v0.16.8/onnxruntime-8f0278c-public-source.pack")


def git(repository, *args, source=None):
    return subprocess.check_output(["git", "-C", repository, *args], stdin=source).decode().strip()


def verify(repository):
    if git(repository, "rev-parse", "HEAD", "HEAD^{tree}").splitlines() != [COMMIT, TREE]:
        raise ValueError("Unexpected ONNX Runtime Git source identity")
    git(repository, "fsck", "--full", "--no-dangling")


def prepare(destination):
    if destination.exists():
        verify(destination)
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=destination.parent) as work:
        work = Path(work)
        repository, pack = work / "source.git", work / "pinned.pack"
        digest = hashlib.sha256()
        size = 0
        req = Request(URL, headers={"User-Agent": "LibreEcho-source-builder"})
        with urlopen(req, timeout=120) as response, pack.open("xb") as out:
            while block := response.read(1024 * 1024):
                size += len(block)
                if size > SIZE:
                    raise ValueError("ONNX Runtime source download exceeds its pinned size")
                digest.update(block)
                out.write(block)
        if size != SIZE or digest.hexdigest() != PACK_SHA256:
            raise ValueError("ONNX Runtime source download did not match the pinned digest")
        subprocess.run(["git", "init", "--quiet", "--bare", "--initial-branch=source", repository], check=True)
        with pack.open("rb") as stream:
            git(repository, "index-pack", "--stdin", source=stream)
        (repository / "shallow").write_text(COMMIT + "\n", encoding="ascii")
        git(repository, "update-ref", "refs/heads/source", COMMIT)
        verify(repository)
        repository.rename(destination)


if __name__ == "__main__":
    prepare(Path(sys.argv[1]))
