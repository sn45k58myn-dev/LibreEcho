# Frozen candidate and publication status

The personal `0.15.0` Echo 2 candidate is **PREPARED_NOT_FLASHED**. This is a
source-only community publication, not a hardware-qualified firmware release.

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

## Remaining work

The immediate pre-first-PCM radio pause/parent-death guard race remains documented;
the passing established-playback regression does not fix it. The HTTP rejection
repair was tested on plain HTTP; no HTTPS relay repair is claimed.

Before any hardware trial, establish exact model/board identity, boot-chain
generation, partition layout and the appropriate install/recovery route. Then
record boot/slot health, every microphone, physical mute/privacy, buttons/LEDs,
speaker/AUX, Wi-Fi/discovery, repeated Home Assistant voice turns, Music Assistant
playback and signed update behavior. Host tests and a signature do not establish
any of those physical results.

The personal image has its own update trust root. Official upstream OTA packages
are not interchangeable; returning to official trust needs the official reinstall
route. Inherited workflows remain unadapted for fork publication and must stay
disabled. No automatic update pointer, hosted installer or stable release is
created by publishing these source repositories.

Read [the disclaimer](../../DISCLAIMER.md), [AI disclosure](../../AI_DISCLOSURE.md)
and [hardware roadmap](ROADMAP.md). No device repair or recovery support is promised.
