#!/usr/bin/env python3
"""Compare an owner-provided classifier with a running Home Assistant wake pipeline."""
import argparse
import json
from pathlib import Path
import re
import socket
import subprocess
import sys


STOCK = "/run/libreecho/features/wakeword/root/usr/local/share/libreecho/openwakeword"
WAKE_SOCKET = "/run/libreecho/wakeword.sock"
ASSIST_STATUS = "/run/libreecho/esphome-status.json"


def wake_status(adb):
    # Ask waked for its live sensitivity without opening a microphone subscription.
    port = adb("forward", "tcp:0", "localfilesystem:" + WAKE_SOCKET).strip()
    if not port.isdecimal():
        raise ValueError("ADB did not allocate a local status port")
    try:
        with socket.create_connection(("127.0.0.1", int(port)), timeout=3) as conn:
            conn.sendall(b'{"v":1,"id":1,"cmd":"status","args":{}}\n')
            with conn.makefile("rb") as reply:
                response = json.loads(reply.readline(8192))
        if response.get("ok") is not True:
            raise ValueError("Wake service declined its status request")
        return response["data"]
    finally:
        adb("forward", "--remove", "tcp:" + port)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--adb", default="adb")
    parser.add_argument("--serial", required=True, help="Explicit authorised ADB device")
    parser.add_argument("--preflight", action="store_true", help="Only check device and wake state")
    parser.add_argument("--binary", type=Path)
    parser.add_argument("--model", type=Path, help="Local owner-provided ONNX classifier")
    parser.add_argument("--context", choices=("quiet", "music"))
    parser.add_argument("--seconds", type=int, default=90)
    args = parser.parse_args()
    if not 5 <= args.seconds <= 120:
        parser.error("choose a duration of 5 to 120 seconds")
    command = [args.adb, "-s", args.serial]

    def adb(*parts):
        return subprocess.check_output([*command, *parts], text=True, timeout=30)

    target = adb("shell", "cat", "/etc/libreecho/target").splitlines()
    if "target_id=radar_puffin" not in target:
        raise ValueError("Expected the full-size Radar/Puffin Echo 2")
    state = json.loads(adb("shell", "cat", ASSIST_STATUS))
    info = wake_status(adb)
    if not (state.get("connected") and state.get("server_wake_streaming") and info.get("capture_active")):
        raise ValueError("Comparison requires an active Home Assistant server wake stream and live capture")
    sensitivity, floor = info["sensitivity"], info["vad_floor_rms"]
    if type(sensitivity) is not int or not 0 <= sensitivity <= 100 or type(floor) is not int or not 0 < floor <= 16384:
        raise ValueError("Unexpected device sensitivity or VAD floor")
    threshold = max(0.30, min(0.85, 0.85 - sensitivity * 0.0044))
    print(f"Echo 2 streaming to Home Assistant. Device sensitivity {sensitivity}, "
          f"derived threshold {threshold:.4f}, VAD floor {floor}.", flush=True)
    if args.preflight:
        return 0
    if not (args.binary and args.binary.is_file() and args.model and args.model.is_file() and args.context):
        parser.error("a trial requires --binary, --model and --context")
    if not 0 < args.model.stat().st_size <= 8 * 1024 * 1024:
        raise ValueError("Classifier exceeds the supported file size or is empty")
    directory = adb("shell", "mktemp -d /tmp/libreecho-wake-trial.XXXXXX").strip()
    if not re.fullmatch(r"/tmp/libreecho-wake-trial\.[A-Za-z0-9]{6}", directory):
        raise ValueError("Unexpected device temporary directory")
    try:
        model_dir = directory + "/trial_word"
        adb("shell", "mkdir", "-m", "700", model_dir)
        for name in ("melspectrogram.onnx", "embedding_model.onnx"):
            adb("shell", "cp", STOCK + "/" + name, model_dir + "/" + name)
        adb("push", str(args.model), model_dir + "/alexa_v0.1.onnx")
        binary = directory + "/wake-trial"
        adb("push", str(args.binary), binary)
        adb("shell", "chmod", "700", binary)
        return subprocess.run([*command, "shell", binary, model_dir, str(args.seconds),
                               args.context, f"{threshold:.4f}", str(floor)],
                              timeout=args.seconds + 35).returncode
    finally:
        adb("shell", "rm", "-rf", directory)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        sys.exit(str(error))
