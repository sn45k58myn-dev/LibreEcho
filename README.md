# Echo 2 0.16.1 · Persistent intercom settings

For the full-size Amazon Echo 2nd Generation (2017), Radar/Puffin.

## Changes

- Made the native intercom service use the same persistent settings as the web interface.
- Added a regression test for the factory defaults and live settings paths.

## Validation

Focused tests, signed image checks and read-only preflight passed. The candidate stayed at preparation stage and was skipped in the hardware update sequence.

## Exact build sources

Public source commit IDs reflect an authorship metadata cleanup. The source files match the inputs of the tested firmware.

Build `radar-puffin-build-fcf7294-c719fec4016562fa-2026112000023083`.

| Component | Commit |
| --- | --- |
| Product | [`595daa2a723f84204cd9cd6d5256ab0eab0ea10c`](https://github.com/sn45k58myn-dev/LibreEcho/commit/595daa2a723f84204cd9cd6d5256ab0eab0ea10c) |
| UI | [`a45745e554f392b263084fbdcc534e5da3443731`](https://github.com/sn45k58myn-dev/LibreEcho-UI/commit/a45745e554f392b263084fbdcc534e5da3443731) |
| Platform | [`6989f31f364287f53a6fc5570953a9493e4489eb`](https://github.com/sn45k58myn-dev/LibreEcho-Platform/commit/6989f31f364287f53a6fc5570953a9493e4489eb) |
| Linux | [`5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0`](https://github.com/sn45k58myn-dev/LibreEcho-Linux/commit/5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0) |

The signed firmware stays local because the audio FPGA component is marked as blocked for redistribution. GitHub's generated archives contain this release record and its source pins.

This independent, AI-assisted fork builds on [LibreEcho by Andy Slater and contributors](https://github.com/aslater3/LibreEcho). See [attribution](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/ATTRIBUTION.md), [AI disclosure](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/AI_DISCLOSURE.md), and the [full disclaimer](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/DISCLAIMER.md). The fork offers no device repair, recovery or replacement service.
