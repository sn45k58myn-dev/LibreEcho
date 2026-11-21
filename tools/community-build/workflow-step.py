"""Run an audited dependency setup step from the pinned Product workflow."""
from pathlib import Path
import subprocess
import sys

import yaml


def main():
    job, name = sys.argv[1:]
    path = Path("/build/sources/product/.github/workflows/build-release.yml")
    steps = yaml.safe_load(path.read_bytes())["jobs"][job]["steps"]
    body, = [step["run"] for step in steps if step.get("name") == name]
    if "${{" in body:
        raise ValueError(f"Step requires a GitHub expression: {name}")
    print(f"Preparing dependencies: {name}", flush=True)
    subprocess.run(["bash", "-eu", "-o", "pipefail", "-c", body], check=True)


if __name__ == "__main__":
    main()
