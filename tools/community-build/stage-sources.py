"""Stage the reviewed inputs with the exact, shallow ONNX source mirror."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys


def main(destination, mirror):
    ci = Path("build/ci/fetch-public-deps.py")
    inventory = Path("build/inputs/public-inputs.json")
    sendspin = Path("/build/sources/platform/tools/mt8163-arm32/sendspin")
    lock = sendspin / "SOURCE.lock"
    # Run the same whole-inventory and patch-lock checks as the upstream CI.
    subprocess.run([sys.executable, ci, inventory, "--allow-generated",
                    "--source-lock", lock, "--patch-dir", sendspin / "patches"], check=True)
    spec = importlib.util.spec_from_file_location("product_inputs", ci)
    inputs = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = inputs
    spec.loader.exec_module(inputs)
    data = inputs.load(inventory)
    [record] = [entry for entry in data["inputs"] if entry["name"] == "onnxruntime-source"]
    if record["kind"] != "source-git" or record["url"] != "https://github.com/microsoft/onnxruntime.git":
        raise ValueError("Unrecognised ONNX Runtime inventory entry")
    # prepare-ort.py verified this shallow repository's Git objects and tree.
    # Materialising its exact current tree avoids negotiating missing history.
    expected = subprocess.check_output(["git", "-C", mirror, "rev-parse", "HEAD", "HEAD^{tree}"])
    if expected.decode().splitlines()[0] != record["commit"]:
        raise ValueError("ONNX Runtime mirror and Product inventory disagree")
    checkout = destination / record["name"]
    shutil.copytree(mirror, checkout / ".git")
    git = ["git", "-C", checkout]
    subprocess.run(git + ["config", "core.bare", "false"], check=True)
    subprocess.run(git + ["checkout", "--quiet", "--force", "--detach", record["commit"]], check=True)
    if subprocess.check_output(git + ["rev-parse", "HEAD", "HEAD^{tree}"]) != expected:
        raise ValueError("ONNX Runtime checkout did not match its verified mirror")
    data["inputs"].remove(record)
    inputs.stage(data, destination, inventory.parent, patch_dir=sendspin / "patches",
                 lock=json.loads(lock.read_text(encoding="utf-8")))


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]))
