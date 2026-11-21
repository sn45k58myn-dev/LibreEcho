# Build 0.16.8 for a full-size Echo 2

This recipe builds the 2017 Echo 2 (`radar_puffin`) firmware from four pinned public source trees. It includes native Sendspin and the iPhone intercom echo fix. You can build the kit before connecting a speaker. The build uses your own signing key and requires no previous LibreEcho firmware archive.

## Build on Linux

Use an x86-64 Linux machine with Docker Engine, Git, Bash, Python 3 and `flock`. Docker must be able to reach the public package and source repositories during dependency preparation. Allow substantial disk space and several hours for a first build. Keep the working files on a Linux filesystem.

```sh
git clone --depth 1 --branch docs/community-publication https://github.com/sn45k58myn-dev/LibreEcho.git
cd LibreEcho
bash tools/community-build/build.sh
```

The command creates a local Docker build volume, fetches and checks the source commits and trees, prepares the compilers and dependencies, and builds the image and five feature packages. The last stage checks the signed OTA and prepares the initial-install bundle using the matching installer without accessing hardware. A successful run prints the output directory. Pass a directory as the single argument to select another destination.

The compiler and neural runtimes default to two parallel jobs. On a machine with spare CPU and memory, prefix the build command with `LIBREECHO_BUILD_JOBS=4` to use four for these stages.

For the initial publication, all four source checkouts and the 67-entry public input inventory have been verified from an empty build volume. Full image and first-install verification are in progress for the new owner-key recipe. The previously tested firmware and its hardware results are recorded in the [0.16.8 build record](0.16.8.md).

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
