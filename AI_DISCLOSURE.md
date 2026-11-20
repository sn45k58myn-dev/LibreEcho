# AI-assisted development disclosure

**This community fork contains additions and modifications developed with the
assistance of AI coding tools.** The disclosure applies to this fork's work;
it makes no claim about how the original LibreEcho authors developed their
project.

AI assistance was used to inspect source code, investigate failures, propose
and implement changes, prepare build scripts and documentation, and run and
interpret automated checks. AI-generated or AI-assisted work can contain
incorrect assumptions, incomplete fixes, security problems and misleading
explanations. Passing tests does not remove those possibilities.

## What has been demonstrated

The [Echo 2 release history](docs/community/RELEASE_HISTORY.md) records the
exact sources and checks for each firmware build. One full-size Echo 2 passed
initial installation on 0.15.0, native Sendspin playback on 0.15.1, and signed
OTA plus one two-way iPhone call on 0.16.3. The fresh 0.16.3 install bundle passed
local preparation checks and awaits a separate hardware trial.

Apply each result to the named build, hardware, and test conditions. Wider
compatibility and reliability claims require separate physical tests.

A known radio startup/pause race remains: pausing before the first PCM output
can stop a child before its parent-death guard is armed. The established
playback path passed its tests. The published source and evidence must retain
that distinction until a separately reviewed fix is verified.

## Expectations for future work

Contributors should identify AI-assisted changes in their pull requests,
review generated code and cited sources, explain the behavior they intended
to change, and provide reproducible evidence. Do not submit generated results
as observations from hardware that was never tested. Do not invent board
pinouts, compatibility claims, test results, or recovery guarantees.

New boards, including Echo 3 and Echo Studio, remain research targets until
their device-specific access, kernel, audio, privacy controls, installation
and recovery paths have been implemented and verified. A roadmap entry is
not support and does not make an existing image suitable for another board.

Never upload credentials, private signing keys, personal voice recordings,
home-network configuration, or private diagnostic data to public issues or
repositories. AI tooling does not change the project's privacy and source
publication boundaries.

Read [ATTRIBUTION.md](ATTRIBUTION.md) for the original project's credit and
[DISCLAIMER.md](DISCLAIMER.md) before considering hardware use.
