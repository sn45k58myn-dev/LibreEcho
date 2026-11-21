# LibreEcho — independent experimental community fork

This development branch tests **on-device wake words on the full-size Echo 2**.
It lets the speaker and Home Assistant score the same microphone stream while
music plays. [Run the wake-word comparison](docs/community/LOCAL_WAKE_TRIAL.md).
For the released firmware and first-install recipe, use the
[0.16.8 builder tag](https://github.com/sn45k58myn-dev/LibreEcho/tree/echo2-builder-v0.16.8).

**Built on [LibreEcho](https://github.com/aslater3/LibreEcho), created by
Andy Slater ([aslater3](https://github.com/aslater3)) and the LibreEcho contributors.**
Full credit for the original project, architecture, hardware research and existing
features belongs to the original authors. Visit [libreecho.org](https://libreecho.org/)
and read [ATTRIBUTION.md](ATTRIBUTION.md). Original licences and copyright notices
remain unchanged.

This is an independent fork with **AI-assisted additions**. It is not an official
LibreEcho release and is not endorsed by upstream or Amazon. Read
[AI_DISCLOSURE.md](AI_DISCLOSURE.md) and the full [DISCLAIMER.md](DISCLAIMER.md).
**There is no promised repair, recovery, unbricking, replacement or support service.**

## Source and hardware status

[**Echo 2 0.16.8**](docs/community/0.16.8.md) reduces the caller's echo on the iPhone intercom and includes native Sendspin. A signed update and a normal iPhone call were verified on one full-size Echo 2. The complete first-install kit passed offline preparation and can be used directly on another prepared Radar/Puffin.

To build the first-install kit with your own signing key, follow [Build 0.16.8 for a full-size Echo 2](docs/community/BUILD_ECHO2_0.16.8.md). The recipe uses public sources and needs no earlier firmware archive.

See the [first-install and OTA guide](docs/community/0.16.8.md#use-0168-on-the-next-echo-2), [release history](docs/community/RELEASE_HISTORY.md), [Sendspin setup](docs/audio/sendspin.md) and [phone intercom setup](docs/audio/intercom.md). Voice commands for room-to-room [drop-in](docs/audio/drop-in.md) still need a physical two-speaker trial.

Echo Dot 2 support is inherited from upstream and has not been qualified in this
fork. Echo 3, Echo Studio and additional boards remain research targets.

## Four-repository layout

| Repository | Responsibility |
| --- | --- |
| [LibreEcho](https://github.com/sn45k58myn-dev/LibreEcho) | Project home, coordination, build/release tooling and documentation. |
| [LibreEcho-UI](https://github.com/sn45k58myn-dev/LibreEcho-UI) | Web interface, APIs and device/voice services. |
| [LibreEcho-Platform](https://github.com/sn45k58myn-dev/LibreEcho-Platform) | Initramfs, image and update tooling, audio and feature packaging. |
| [LibreEcho-Linux](https://github.com/sn45k58myn-dev/LibreEcho-Linux) | Kernel, device trees and drivers. |

## Hardware roadmap

See the [hardware roadmap](docs/community/ROADMAP.md),
[board proposal template](docs/community/BOARD_PROPOSAL.md) and
[build status](docs/community/BUILD_STATUS.md).
Use [CONTRIBUTING.community.md](CONTRIBUTING.community.md) for fork-specific routing
and preserve the existing source, test, licence and boot-chain rules.

## Build, installation and automation boundaries

GitHub hosts the source pre-releases and validation records. See the [0.16.8 build record](docs/community/0.16.8.md#build-identification) for the third-party components and why the complete signed kit stays local.
An OTA requires the signing trust configured on the installed build.

Inherited build/release workflows and download wrappers still contain upstream
repository defaults. They must not be presented as building or installing this
fork. Fork GitHub Actions are to remain disabled until checkout identities,
permissions, signing and release destinations have been adapted and reviewed.
No remote CI success is claimed by this source publication.

The original component documentation is preserved verbatim in
[README.upstream.md](README.upstream.md). It describes an upstream snapshot;
upstream badges, support claims, releases and install commands in that document
are **not evidence or instructions for this fork's modified candidate**.
Never bypass target, partition, boot-chain or signature checks to try a new board.

## Known limitation

The established-playback radio regression passes. A separate pre-existing race
can stop a just-starting radio child before its parent-death guard is armed when
pause happens before the first PCM. This fork does not claim that race is fixed.
See the project build-status page for the evidence limits and next gates.

## Exact tested source history

The [source-history bundle](docs/community/history/tested-source.bundle) preserves
the original local source commits and authorship on top of the upstream baseline.
It contains Git source objects, not device firmware or signing secrets. This also
keeps the frozen build ledger usable when GitHub's API creates a publication
commit with a new commit ID but the same checked source files.

On a Linux filesystem, after cloning this fork and making the upstream prerequisite
available, verify and fetch the bundle without flashing or changing device state:

```sh
git bundle verify docs/community/history/tested-source.bundle
git fetch docs/community/history/tested-source.bundle HEAD
git rev-parse FETCH_HEAD
```

The last command must print `6059a7ea6fd14ee32621d6c61fb13add523e66f8`.
The publication tree includes documentation above that frozen source; it does
not claim an already-built binary was rebuilt from a new publication commit.
