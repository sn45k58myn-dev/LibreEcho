# Build and validation status

The [Echo 2 release history](RELEASE_HISTORY.md) documents the progression from the first install to Sendspin recovery and two-way iPhone calling.

The [0.16.8 build record](0.16.8.md) covers the signed OTA confirmation, the iPhone listening test and the offline first-install checks for the full-size Echo 2.

For a new owner, the [public source builder](BUILD_ECHO2_0.16.8.md) fetches the matching sources and generates a personal signing identity on the build machine. The checksum file shipped with the resulting kit identifies that owner's firmware.

| Check | Evidence |
| --- | --- |
| 0.16.8 initial install | Complete bundle, signature and five feature bindings passed offline preparation. Fresh hardware installation on a second unit is pending. |
| 0.16.8 OTA and intercom | Confirmed after restart on one Echo 2. The iPhone caller reported less echo. The Sendspin listener and Home Assistant connection returned. |
| Initial install and owner setup | Passed on one Echo 2 with 0.15.0. The 0.16.3 initial-install bundle passed local preparation and awaits a separate hardware trial. |
| Native Sendspin | Playback and voice stop/restart passed on 0.15.1. Two-speaker alignment was judged by ear after restarting the group. Long-duration or instrumented sync remains open. |
| 0.16.3 signed OTA | Passed on the same Echo 2 and Home Assistant reconnected after restart. OTA requires compatible firmware and matching signing trust. |
| 0.16.3 phone intercom | One foreground iPhone Safari call had audio in both directions. The connection closed at hang-up. |
| Voice room-to-room intercom | A separate [Home Assistant prototype](../audio/drop-in.md) has host test evidence. A physical two-speaker trial is pending. |

## Original 0.15.0 candidate

The original 0.15.0 validation manifest recorded `PREPARED_NOT_FLASHED` at build preparation. Hardware installation and setup subsequently passed on one unit. The [release history](RELEASE_HISTORY.md) records the later result. The manifest remains the record of the original automated checks.

The exact four source commits, observed local checks and artifact hashes are
recorded in [build-validation.json](build-validation.json). The source trees
used to build the image were clean; the exported four-repository source archive
was freshly extracted on Linux and checked for exact Git identities and integrity.

Local checks passed: full UI `make test`; JavaScript and OpenAPI checks;
supplemental Opus, real HTTPS PEM, USB boot-pin and Sendspin header contracts;
ARM32 kernel and complete image build; independent image contract; three release
completeness checks; local-file installer preparation; personal Ed25519 signature;
exact five-payload signed-generation binding; exported-file and archive hashes.
These are local automated observations, not remote CI, a security audit or physical
hardware evidence.

## Public-source relationship

The frozen source ledger remains authoritative for the already-built candidate.
Publication readmes, attribution, disclaimers and roadmaps do not retroactively
change that binary's source identity. The publication plan records the original
upstream base and tested source tree for each component. No private signing seed,
Wi-Fi credentials, account sessions or home-network configuration is included.

## Open validation

The immediate pre-first-PCM radio pause/parent-death guard race remains documented;
the passing established-playback regression does not fix it. The HTTP rejection
repair was tested on plain HTTP; no HTTPS relay repair is claimed.

The [hardware roadmap](ROADMAP.md) tracks repeat tests for install and recovery, microphone and mute behavior, repeated voice turns, music synchronization and local intercom.

The tested build uses a fork-specific verification key. Use the matching signing identity for an OTA to that build. The public source pre-releases do not provide a hosted installer or automatic update channel.

Read [the disclaimer](../../DISCLAIMER.md), [AI disclosure](../../AI_DISCLOSURE.md)
and [hardware roadmap](ROADMAP.md). No device repair or recovery support is promised.
