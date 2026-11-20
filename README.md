# Echo 2 0.16.0 · First local intercom

For the full-size Amazon Echo 2nd Generation (2017), Radar/Puffin.

## Changes

- Added foreground iPhone-to-Echo intercom with signed-in access over trusted HTTPS.
- Added a room call cue and ring indicator, explicit calling permission and Home Assistant voice coordination.

## Validation

Signed OTA and startup passed. The initial iPhone trials exposed a persistent-settings mismatch and phone audio interruptions. Two-way audio was unconfirmed on this build.

## Exact build sources

Public source commit IDs reflect an authorship metadata cleanup. The source files match the inputs of the tested firmware.

Build `radar-puffin-build-fcf7294-dd99ec42a8efa7cd-2026111923020004`.

| Component | Commit |
| --- | --- |
| Product | [`595daa2a723f84204cd9cd6d5256ab0eab0ea10c`](https://github.com/sn45k58myn-dev/LibreEcho/commit/595daa2a723f84204cd9cd6d5256ab0eab0ea10c) |
| UI | [`e2a7e4685ab1e54762f45c842ec41f35eeb01f70`](https://github.com/sn45k58myn-dev/LibreEcho-UI/commit/e2a7e4685ab1e54762f45c842ec41f35eeb01f70) |
| Platform | [`6989f31f364287f53a6fc5570953a9493e4489eb`](https://github.com/sn45k58myn-dev/LibreEcho-Platform/commit/6989f31f364287f53a6fc5570953a9493e4489eb) |
| Linux | [`5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0`](https://github.com/sn45k58myn-dev/LibreEcho-Linux/commit/5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0) |

The signed firmware stays local because the audio FPGA component is marked as blocked for redistribution. GitHub's generated archives contain this release record and its source pins.

This independent, AI-assisted fork builds on [LibreEcho by Andy Slater and contributors](https://github.com/aslater3/LibreEcho). See [attribution](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/ATTRIBUTION.md), [AI disclosure](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/AI_DISCLOSURE.md), and the [full disclaimer](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/DISCLAIMER.md). The fork offers no device repair, recovery or replacement service.
