# Board proposal template

Copy this template into a Product issue in
[`sn45k58myn-dev/LibreEcho`](https://github.com/sn45k58myn-dev/LibreEcho).
This starts research; it does not add support or authorize a hardware write.
Read the [roadmap](ROADMAP.md) and [disclaimer](../../DISCLAIMER.md).

## Summary and requested scope

- Retail model and generation:
- Model marking and board revision:
- Proposed target identifier, if justified:
- Requested work: documentation / feasibility / driver / bring-up / other:
- Owner of the test hardware and contributor availability:
- Current status: research only / host prototype / authorized hardware trial:

Do not include device serials, MAC addresses, Wi-Fi details, account identifiers
or credentials. Use publicly shareable model/board markings only.

## Verified facts and unknowns

For each claim, provide a source, photograph or sanitized measurement. Include
the source date or tested revision. Keep guesses in the Unknown column.

| Area | Verified finding and evidence | Unknown or conflicting evidence |
| --- | --- | --- |
| SoC and architecture | | |
| RAM and storage | | |
| Bootloader and boot-chain generation | | |
| Read-only partition/layout information | | |
| Existing recovery route and limits | | |
| Power and connector identification | | |
| Speaker drivers and amplifier/codec | | |
| Microphone front end, count and channel map | | |
| Physical mute/privacy circuitry | | |
| Buttons and LED hardware | | |
| Wi-Fi, Bluetooth and other interfaces | | |
| Relevant stock DTS/source availability | | |

A matching connector, green LED, USB identifier or processor name alone does
not prove an install path or firmware compatibility. Do not request random
pad shorting or reuse another model's flash commands to fill a gap in evidence.

## Source provenance and redistribution

- Public source/release URLs, version and licence information:
- Teardown/documentation authors and attribution:
- Firmware or vendor files required for research:
- Which required inputs may be redistributed, and on what basis:
- Inputs that must remain owner-supplied:

Do not attach owner-only dumps, copyrighted firmware without permission,
private signing material or credentials. Do not claim permission from silence.

## Proposed architecture and repository ownership

- Product schema, identity/installer and source-ledger changes:
- Linux SoC/configuration/DTS/driver changes:
- Platform tools profile, image verifier, audio/recovery/update changes:
- UI microphone geometry, voice/controls/API changes:
- Any separate installer or other repository dependency:
- Existing behavior that must remain unchanged:
- Linked component issues or pull requests:

If the SoC or architecture differs from the current MT8163/ARM32 schema,
describe that prerequisite explicitly. Keep every new target unaccepted and
installer rejection intact until model-specific evidence is reviewed.

## Recovery and hardware trial plan

- Proposed recoverable development route and its evidence:
- Known failure modes and recovery limits:
- How model/board/partition/boot-chain identity will be established:
- Backup and restore feasibility, including unverified steps:
- Hardware changes, power arrangements or measurements needed:
- Explicitly authorized trial scope, if a trial is being proposed:

No trial is authorized by submitting this form. A proposed method must be
reviewed for the actual model before any irreversible operation. Preserve
model-specific boot-chain protections and physical microphone privacy.

## Acceptance and evidence plan

- [ ] Exact component commits, target profile and artifact hashes recorded.
- [ ] Host/CI checks and cross-compilation identified separately from hardware tests.
- [ ] Image, target identity and signed-generation mismatch checks planned.
- [ ] Recoverable boot, startup readiness and kernel/service health planned.
- [ ] Wi-Fi/reconnection/discovery and claimed radios planned.
- [ ] Speaker routing, gain/limiting and latency measurements planned.
- [ ] Every microphone lane and geometry, mute/privacy and AEC tests planned.
- [ ] All buttons, LEDs and applicable sensors planned.
- [ ] Home Assistant voice lifecycle and repeated/cancelled turns planned.
- [ ] Music Assistant/Sendspin playback, stop and volume planned.
- [ ] Fresh install, slot health, recovery and same-target signed update tests planned.
- [ ] Existing-target regression checks planned.
- [ ] Licence/source-offer review and sanitized documentation planned.

Replace planned items with dated evidence only when the check actually runs.
Record failures, skipped checks and limitations. Do not label a board supported
from a passing build alone.

## AI assistance disclosure

- AI tools used, if any:
- Which research, code or documents used their output:
- How claims and generated changes were independently checked:
- Remaining uncertain or unreviewed output:

## Acknowledgement

- [ ] I understand this is an independent experimental fork of LibreEcho.
- [ ] I have read the disclaimer and understand a proposal provides no
  compatibility, repair, recovery or support guarantee.
- [ ] I have removed private identifiers and have the right to share each attachment.
- [ ] I have separated verified evidence from assumptions and unknowns.
