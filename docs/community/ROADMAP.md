# Hardware expansion roadmap

This is the roadmap for the independent experimental forks maintained under
[`sn45k58myn-dev`](https://github.com/sn45k58myn-dev). The original LibreEcho
project, architecture and existing device work are by Andy Slater and the
[LibreEcho contributors](https://github.com/aslater3/LibreEcho). This roadmap
does not announce support, working drivers, an unlock method or a release for
an additional board.

Read the [disclaimer](../../DISCLAIMER.md) and the existing
[upstream-derived porting guide](../porting/README.md) before proposing work.
Research is welcome; no delivery dates or support commitments are promised.

## Current evidence

See the [release history](RELEASE_HISTORY.md) and [0.16.3 build record](0.16.3.md) for the exact builds and test conditions.

| Hardware | Status in these forks | What the evidence establishes |
| --- | --- | --- |
| Full-size Amazon Echo 2nd Generation (2017), `radar_puffin` | Experimental source release with limited hardware verification | One unit passed first install on 0.15.0, native Sendspin on 0.15.1, and signed OTA plus one two-way iPhone Safari call on 0.16.3. A fresh 0.16.3 installation and repeated intercom tests still need hardware evidence. |
| Amazon Echo Dot 2nd Generation, `biscuit` | Upstream-supported target; untested in this fork | Existing upstream target code is retained. These forks have not built and hardware-qualified a Dot release. |
| Amazon Echo 3rd Generation | Research proposal only; unsupported | No port, target descriptor, compatible image or physical acceptance is provided here. |
| Amazon Echo Studio | Research proposal only; unsupported | No port, target descriptor, compatible image or physical acceptance is provided here. |
| Other Echo models, board revisions or replacement boards | Research proposal only; unsupported | Each needs its own identity, architecture, boot, power and peripheral evidence. Similar appearance or connectors do not establish compatibility. |

Inherited upstream `hardware_accepted` fields describe upstream target history.
They do not establish hardware acceptance for a modified build from these
forks. A new target must remain unaccepted until its exact build has completed
the documented hardware gates.

## Echo 2 development priorities

1. **Repeat installation and OTA tests.** Start with a prepared, compatible full-size Echo 2 and try a fresh 0.16.3 installation. Record setup, reboot and slot health. Test update recovery separately using the matching signing trust.
2. **Measure audio reliability.** Repeat Sendspin group starts and leave/rejoin tests. Measure offset across longer sessions and confirm wake-word pickup, playback ducking and resume. Repeat two-way phone calls and check call cleanup when the browser closes or Wi-Fi is interrupted.
3. **Validate room-to-room drop-in.** The Home Assistant prototype can route a spoken room name to simulated endpoints. A pair of physical intercom-capable speakers must still prove two-way audio, room routing, busy handling, mute and call cleanup. See the [drop-in development notes](../audio/drop-in.md).
4. **Keep future hardware model-specific.** Echo Dot 2, Echo 3 and Echo Studio need their own evidence before any new support claim. Use the [board proposal template](BOARD_PROPOSAL.md) to track hardware research.

## Keep the four-repository architecture

Extend the existing target model rather than adding independent copies of the
whole system for every speaker:

| Repository | Owns |
| --- | --- |
| [LibreEcho](https://github.com/sn45k58myn-dev/LibreEcho) | Project coordination, Product target schema and descriptors, installer identity checks, source ledger, release packaging and documentation. |
| [LibreEcho-Linux](https://github.com/sn45k58myn-dev/LibreEcho-Linux) | SoC support, kernel configuration, device trees, kernel drivers and hardware contracts. |
| [LibreEcho-Platform](https://github.com/sn45k58myn-dev/LibreEcho-Platform) | Tools profiles, initramfs, recovery, image verification, audio transport and tuning, feature packaging and update generation. |
| [LibreEcho-UI](https://github.com/sn45k58myn-dev/LibreEcho-UI) | Device services, microphone processing and geometry, wake-word and voice lifecycle, controls, APIs and web interface. |

The current Product schema pins MT8163/ARM32 and the existing tools profile.
The upstream-derived porting guide identifies Echo 3 and Echo Studio as a
different SoC family requiring a kernel/platform port, a tools profile and a
schema extension first. That architectural work must be justified for the
actual model and board revision. Relabelling an MT8163 image is not a port.

Use one Product coordination issue and link focused component pull requests.
Keep the same target identity and intended release version across repositories.
Unknown or mismatched targets must continue to fail closed. A web installer
change, if later needed, is a separate dependency; the four forks do not claim
to contain or deploy the upstream hosted installer.

## Staged acceptance

### 1. Identify and document the board

Complete a [board proposal](BOARD_PROPOSAL.md) with the retail model, visible
model markings, board revision and dated public sources. Record the SoC,
memory, storage, codecs/amplifiers, microphone front end, LEDs, buttons,
wireless interfaces and power arrangement where verified. Mark unknowns as
unknown. Remove device serials, MAC addresses, network names and credentials
from every photograph and log.

### 2. Establish feasibility and recovery

Compare the model's own stock device tree and available source releases with
the proposed kernel and tools profile. Record the actual partition layout,
boot-chain generation, signed/unlocked state and recovery limitations using
model-specific evidence. Establish a recoverable development route before
hardware writes are proposed. Never assume that another model's pads,
voltages, marker partition, flash geometry or recovery button is suitable.

Keep the upstream boot-chain protections. Check the model and recovery path before writing to storage, and use the release documentation for the exact target and boot-chain generation.

### 3. Add kernel, profile and verification contracts

Implement the needed SoC/kernel configuration, device tree and drivers in the
kernel repository. Add a separate Platform tools profile and target verifier
when the existing profile is unsuitable. Extend the Product schema, registry
and installer mappings coherently, retaining rejection of unknown targets and
mismatched images. New descriptors start with `hardware_accepted: false`.

Use contract tests and actual cross-compilation. Preserve existing targets'
behavior and expected output where the change is not intended to affect them.
Do not publish a permissive descriptor merely to make a build or installer run.

### 4. Prove a recoverable development boot

On explicitly authorized test hardware, record the exact source commits,
artifact hashes, board revision and boot-chain state. Demonstrate boot,
identity files, storage layout, startup readiness and service health. Capture
relevant kernel logs and investigate panics, memory faults and repeated
service restarts. A source test, USB enumeration or successful image build
does not satisfy this gate.

### 5. Qualify the physical controls and audio

Record evidence for all peripherals present on that model:

- Wi-Fi connection, reconnection and discovery; other radios only where
  implemented and claimed.
- Correct speaker/codec/amplifier routing, conservative gain, startup/shutdown
  behavior, clipping/limiting and measured playback latency.
- Every actual microphone channel, its order and array geometry, capture
  quality, wake-word pickup and command responsiveness.
- Physical microphone mute and its indicator. Software must not defeat a
  hardware privacy latch.
- All buttons, LED positions/colors/brightness and relevant sensors.
- Echo cancellation while the device's own speaker is playing, plus behavior
  with television or other background sound. A quiet-room wake test is not an
  AEC test.

Use safe test levels and measurements appropriate to the board. Do not infer
a working microphone array from one channel or copy another model's tuning
without evidence.

### 6. Qualify the complete voice and music paths

Exercise Home Assistant discovery, secure connection and room routing; wake,
listen, command, spoken reply, cancellation and repeated turns; mute and
reconnection; and Music Assistant/Sendspin playback, pause, stop and volume.
If synchronized playback is claimed, measure it and record the clock/latency
behavior. Keep local and optional remote services clearly identified.

### 7. Qualify installation and updates

Produce one coherent, signed build from a frozen cross-repository source
ledger. Verify the boot image and every feature payload against the same
signed target generation. Prove model mismatch rejection, the model-specific
fresh-install route, post-boot health/slot confirmation and the documented
recovery route. Before claiming OTA support, demonstrate a signed update to
the same target and the intended failed/unconfirmed-update recovery behavior.
Do not reuse another target's baseline or a private owner's update identity.

### 8. Review and document the exact supported build

Attach sanitized host/CI, image and physical hardware evidence separately to
the coordination issue. Include limitations, regressions, licence/source-offer
obligations and the exact component commits, version, artifact hashes and
signing-key fingerprint. Update the support table only after those gates are
reviewed. A proposed board, merged descriptor or AI-generated implementation
does not become a supported device automatically.

## How to help

Submit board documentation, reproducible measurements, host-test fixes or
focused component changes to these forks. State where AI tools contributed
and how the result was checked. Preserve original copyright and third-party
licence notices. Do not upload private credentials, signing seeds, owner-only
firmware or material without redistribution permission. Reports do not create
a commitment to provide repairs, recovery assistance or a completed port.
