#!/usr/bin/env python3
"""Behavioral checks for the GitHub-backed component-cache boundary."""
from __future__ import annotations
import os
import subprocess
import tempfile
import time
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[2]
CACHE = ROOT / "build/component-cache.py"

class ComponentCacheTests(unittest.TestCase):
    def key(self, tree: Path) -> str:
        return subprocess.check_output(
            ["python3", str(CACHE), "key", "--component", "smoke", "--tree", f"root={tree}"],
            text=True,
        ).strip()

    def test_external_symlink_is_hashed_logically_without_following_private_state(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "tree"
            root.mkdir()
            (root / "payload").write_bytes(b"same")
            (root / "private-pointer").symlink_to("/external/private-state/CURRENT")
            first = self.key(root)
            (root / "private-pointer").unlink()
            (root / "private-pointer").symlink_to("/elsewhere/out/CURRENT")
            second = self.key(root)
            self.assertEqual(first, second)

    def test_same_content_in_different_directories_has_same_key(self):
        with tempfile.TemporaryDirectory() as left, tempfile.TemporaryDirectory() as right:
            a, b = Path(left) / "tree", Path(right) / "tree"
            for root in (a, b):
                (root / "nested").mkdir(parents=True)
                (root / "nested/item").write_bytes(b"stable")
            self.assertEqual(self.key(a), self.key(b))


class BuildStateLockTests(unittest.TestCase):
    """The shipped lock protects shared external state without changing sources."""

    def lock(self) -> str:
        builder = (ROOT / "build/build.sh").read_text()
        start = builder.index('mkdir -p "$KERNEL_OUT" "$RUNS"\n')
        end = builder.index(': >"$COMPONENT_TIMING_FILE"', start)
        return builder[start:end]

    def fixture(self, root: Path, name: str) -> Path:
        source = root / name
        (source / "build").mkdir(parents=True)
        (source / "README").write_text("tracked source\n")
        subprocess.run(["git", "init", "-q", str(source)], check=True, timeout=10)
        subprocess.run(["git", "-C", str(source), "add", "README"], check=True, timeout=10)
        subprocess.run(["git", "-C", str(source), "-c", "user.name=Build Test",
                        "-c", "user.email=build-test@localhost", "-c", "commit.gpgsign=false",
                        "commit", "-qm", "fixture"], check=True, timeout=10)
        return source

    def environment(self, source: Path, state: Path) -> dict[str, str]:
        state.mkdir(exist_ok=True)
        return {**os.environ, "PIPELINE": str(source / "build"),
                "BUILD_ROOT": str(state), "KERNEL_OUT": str(state / "kernel"),
                "RUNS": str(state / "out/runs")}

    def test_lock_keeps_product_source_clean(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = self.fixture(root, "product source")
            result = subprocess.run(["bash", "-euc", self.lock()],
                                    env=self.environment(source, root / "external state"),
                                    capture_output=True, text=True, timeout=10)
            self.assertEqual(result.returncode, 0, result.stderr)
            status = subprocess.check_output(["git", "-C", str(source), "status", "--porcelain"],
                                             text=True, timeout=10)
            self.assertEqual(status, "", "acquiring the build lock changed the source worktree")

    def test_same_build_state_is_locked_across_source_worktrees_and_released(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            first = self.fixture(root, "first source")
            second = self.fixture(root, "second source")
            state = root / "shared build state"
            ready = root / "lock-ready"
            environment = self.environment(first, state)
            environment["READY"] = str(ready)
            holder = subprocess.Popen(["bash", "-euc", self.lock() + '\n: >"$READY"\nread -r release'],
                                      env=environment, stdin=subprocess.PIPE,
                                      stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            try:
                deadline = time.monotonic() + 10
                while not ready.exists() and holder.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.01)
                self.assertTrue(ready.exists(), "first build did not acquire the lock")
                contender = subprocess.run(["bash", "-euc", self.lock()],
                                           env=self.environment(second, state),
                                           capture_output=True, text=True, timeout=10)
                self.assertNotEqual(contender.returncode, 0, "shared build state was not locked")
                self.assertIn("another build is already running", contender.stderr)
                independent = subprocess.run(["bash", "-euc", self.lock()],
                                             env=self.environment(second, root / "independent state"),
                                             capture_output=True, text=True, timeout=10)
                self.assertEqual(independent.returncode, 0, independent.stderr)
            finally:
                try:
                    holder.communicate("\n", timeout=10)
                except subprocess.TimeoutExpired:
                    holder.kill()
                    holder.communicate(timeout=10)
            released = subprocess.run(["bash", "-euc", self.lock()],
                                      env=self.environment(second, state),
                                      capture_output=True, text=True, timeout=10)
            self.assertEqual(released.returncode, 0, released.stderr)


class WakeDependencyClosureTests(unittest.TestCase):
    """Run the shipped staging loop: cached ORT must remain linkable."""

    def stage(self, source: Path, destination: Path):
        builder = (ROOT / "build/build.sh").read_text()
        start = builder.index("      for dep_archive in ")
        end = builder.index("      absl_count=0", start)
        return subprocess.run(
            ["bash", "-euc", builder[start:end]],
            env={**os.environ, "WAKE_ORT_BUILD": str(source),
                 "WAKE_ORT_WORK": str(destination)},
            capture_output=True, text=True, timeout=10,
        )

    # The pinned ORT 8f0278c7 produces these dependencies, not an nsync target.
    DEPENDENCIES = (
        "onnx-build/libonnx.a", "onnx-build/libonnx_proto.a",
        "protobuf-build/libprotobuf-lite.a", "flatbuffers-build/libflatbuffers.a",
    )

    def fixture(self, source: Path):
        for name in self.DEPENDENCIES:
            path = source / "_deps" / name
            path.parent.mkdir(parents=True, exist_ok=True)
            subprocess.run(["ar", "rcs", str(path)], check=True, timeout=10)

    def test_cached_pinned_ort_dependencies_can_be_linked_without_nsync(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source, cached = root / "source", root / "cached"
            self.fixture(source)
            archive = source / "_deps/onnx-build/libonnx_proto.a"
            (root / "dependency.c").write_text("int dependency_probe(void) { return 42; }\n")
            (root / "main.c").write_text(
                "int dependency_probe(void); int main(void) { return dependency_probe() != 42; }\n")
            subprocess.run(["cc", "-c", str(root / "dependency.c"), "-o", str(root / "dependency.o")],
                           check=True, timeout=10)
            subprocess.run(["ar", "rcs", str(archive), str(root / "dependency.o")],
                           check=True, timeout=10)
            result = self.stage(source, cached)
            self.assertEqual(result.returncode, 0, result.stderr)
            for name in self.DEPENDENCIES:
                restored = cached / "_deps" / name
                self.assertTrue(restored.is_file(), f"dependency lost from reduced ORT cache: {name}")
                self.assertEqual(restored.read_bytes(), (source / "_deps" / name).read_bytes())
            self.assertFalse((source / "_deps/nsync-build").exists())
            self.assertFalse((cached / "_deps/nsync-build").exists())
            restored = cached / "_deps/onnx-build/libonnx_proto.a"
            subprocess.run(["cc", str(root / "main.c"), str(restored), "-o", str(root / "probe")],
                           check=True, timeout=10)
            subprocess.run([str(root / "probe")], check=True, timeout=10)

    def test_each_missing_or_symlinked_required_dependency_is_rejected(self):
        for name in self.DEPENDENCIES:
            for symlink in (False, True):
                with self.subTest(name=name, symlink=symlink), tempfile.TemporaryDirectory() as temp:
                    root = Path(temp)
                    source = root / "source"
                    self.fixture(source)
                    archive = source / "_deps" / name
                    archive.unlink()
                    if symlink:
                        substitute = root / "other.a"
                        subprocess.run(["ar", "rcs", str(substitute)], check=True, timeout=10)
                        archive.symlink_to(substitute)
                    result = self.stage(source, root / "cached")
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn(name, result.stderr)

if __name__ == "__main__":
    unittest.main()
