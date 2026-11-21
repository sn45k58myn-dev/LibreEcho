# Build 0.16.8 for a full-size Echo 2

This recipe builds the 2017 Echo 2 (`radar_puffin`) firmware from four pinned public source trees. It includes native Sendspin and the iPhone intercom echo fix. You can build the kit before connecting a speaker. The build uses your own signing key and requires no previous LibreEcho firmware archive.

## Build on Linux

Use an x86-64 Linux machine with Docker Engine, Git, Bash, Python 3 and `flock`. Docker needs internet access during dependency preparation. Keep the working files on a Linux filesystem. Allow several hours for a first build and space for Docker images, temporary files and the finished kit. The test workspace occupied 10 GiB at completion and its export used another 723 MiB.

```sh
git clone --depth 1 --branch echo2-builder-v0.16.8 https://github.com/sn45k58myn-dev/LibreEcho.git
cd LibreEcho
bash tools/community-build/build.sh
```

The command creates a local Docker build volume, fetches and checks the source commits and trees, prepares the compilers and dependencies, and builds the image and five feature packages. The last stage checks the signed OTA and prepares the initial-install bundle using the matching installer without accessing hardware. A successful run prints the output directory. Pass a directory as the single argument to select another destination.

The compiler and neural runtimes default to two parallel jobs. On a machine with spare CPU and memory, prefix the build command with `LIBREECHO_BUILD_JOBS=4` to use four for these stages.

## Verification

Starting with an empty Docker volume, a Linux test fetched the four public source trees, checked the 67-entry dependency inventory, and rebuilt the compiler, neural libraries and firmware. It used a fresh signing key and no previous Echo firmware or owner files. The run took 1 h 52 min with independent tasks overlapped, including 30 min for the network-isolated image and packaging stage. Download speed, worker count and local hardware affect build time.

The kit contained 33 files. All 32 checksum entries, the Ed25519 signature, the five signed feature bindings and the matching installer's offline first-install preparation passed. The test checked the packed ARM executables and searched the export, unpacked boot ramdisk and feature packages for the test seed. Only the public verification key shipped.

The clean build's intercom, microphone, Sendspin and audio-engine executables matched the hardware-tested release byte for byte. A separate build using cached public compiler and library inputs matched all five original executables. Comparing that build to the clean build showed that the wake daemon and echo-cancellation object files also matched, including `voice_aec` and `voice_aec_guard`. The rebuilt ONNX Runtime session library and the final linked wake executable had different digests. A fresh physical installation of the independently signed kit has yet to be tested. [Hardware results for the original 0.16.8 build](0.16.8.md#what-was-verified)

## Keep the output and your signing key

- **First-install kit and OTA.** The default output is `~/LibreEcho-builds/0.16.8/<build-tag>/`. Keep the whole release directory together, including its installer, release-prefixed checksum file, public key, OTA, initial-install tar, and matching feature files. To check a copied kit, run `sha256sum -c *-SHA256SUMS` inside its release directory.
- **Signing key.** The first run generates `~/.local/share/libreecho-echo2/ota-seed.hex` on the host. Back it up privately before installing on a speaker. Future OTAs for that installation must match its signing trust. The key is mounted read-only during the signing stage and is excluded from the exported kit. The release identity and hashes change for an independently signed build. Use the checksum file produced by your own run.
- **Repeating a build.** Keep the Docker volume to reuse completed dependency work. Rerun the same command after a failed download. For an independent signing identity on the same computer, set both `LIBREECHO_OWNER_DIR` and `LIBREECHO_BUILD_VOLUME` to new locations. Each volume holds the Platform checkout for one public verification key.

## Use on the next speaker

Use the **initial-install** bundle for a compatible, prepared full-size Echo 2. An Echo still on factory software must separately meet the installer's model and boot-environment requirements. This build command does not put a factory speaker into that state. Another Echo can start directly on 0.16.8. On first boot, create its own owner account and configure the speaker's pairing and certificate. [First-install and intercom guide](0.16.8.md#use-0168-on-the-next-echo-2)

The Wake Word page lists **Alexa** as the stock on-device detector. If you configure Home Assistant to handle wake detection, the wake phrase comes from the speaker's assigned Assist pipeline. Uploading a model to the speaker only affects on-device detection. [Wake detection modes in 0.16.8](https://github.com/sn45k58myn-dev/LibreEcho-UI/blob/984ebc22cf68f1900e931d1129357db91951ea06/docs/HOME_ASSISTANT_VOICE.md#server-side-wake-word-optional-off-by-default)

## Source and dependency provenance

The build verifies the [four source commits and Git trees](echo2-0.16.8.json). The local Platform checkout adds one commit containing your **public** OTA verification key. The original Linux tree already contains the pinned microphone FPGA input. Third-party notices and the noncommercial voice-feature terms apply. [Component inventory](../../release/components.json)

The pinned Microsoft ONNX Runtime revision was preserved in LibreEcho's public dependency artifact. The build fetches a Git object pack containing that exact commit and its source tree, including its original licence and notices. It checks the download digest, Git object integrity, commit and tree before using it. The pack contains 11,462 reachable objects and excludes local Git configuration, branches and credentials. [Original public dependency artifact](https://github.com/aslater3/LibreEcho/actions/runs/44342649025/artifacts/14444681631) · [Microsoft ONNX Runtime](https://github.com/microsoft/onnxruntime)

| ONNX Runtime input | Identifier |
| --- | --- |
| Commit | `8f0278c77bf44b0cc83c098c6c722b92a36ac4b5` |
| Source tree | `5ea4a49d0be5e5a620cabaa01f85d924b2fa5995` |
| Git pack SHA-256 | `6cc3dbb41072be096e078a7e3d93e44f23663e6342fded069906133bc32f64df` |

LibreEcho was created by Andy Slater and the LibreEcho contributors. This community build recipe includes AI-assisted changes. [Attribution](../../ATTRIBUTION.md) · [AI disclosure](../../AI_DISCLOSURE.md) · [Disclaimer and support terms](../../DISCLAIMER.md)
