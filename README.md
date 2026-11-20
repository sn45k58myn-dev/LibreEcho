# Echo 2 0.16.3 · Verified two-way iPhone intercom

For the full-size Amazon Echo 2nd Generation (2017), Radar/Puffin.

## Changes

- Kept intercom calls open through brief speaker audio startup stalls and retained a timeout for sustained stalls.
- Included the earlier Sendspin recovery and persistent intercom settings changes.

## Validation

Signed OTA and startup passed. One foreground iPhone Safari call had audible audio in both directions. The Echo released the audio connection when the call ended. A fresh 0.16.3 installation still awaits a hardware test.

## Exact build sources

Public source commit IDs reflect an authorship metadata cleanup. The source files match the inputs of the tested firmware.

Build `radar-puffin-build-fcf7294-80e7bdd1bc59720b-2026112001052454`.

| Component | Commit |
| --- | --- |
| Product | [`595daa2a723f84204cd9cd6d5256ab0eab0ea10c`](https://github.com/sn45k58myn-dev/LibreEcho/commit/595daa2a723f84204cd9cd6d5256ab0eab0ea10c) |
| UI | [`527a53de615400b82b64d3ae7853b05364c23708`](https://github.com/sn45k58myn-dev/LibreEcho-UI/commit/527a53de615400b82b64d3ae7853b05364c23708) |
| Platform | [`6989f31f364287f53a6fc5570953a9493e4489eb`](https://github.com/sn45k58myn-dev/LibreEcho-Platform/commit/6989f31f364287f53a6fc5570953a9493e4489eb) |
| Linux | [`5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0`](https://github.com/sn45k58myn-dev/LibreEcho-Linux/commit/5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0) |

The signed firmware stays local because the audio FPGA component is marked as blocked for redistribution. GitHub's generated archives contain this release record and its source pins.

This independent, AI-assisted fork builds on [LibreEcho by Andy Slater and contributors](https://github.com/aslater3/LibreEcho). See [attribution](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/ATTRIBUTION.md), [AI disclosure](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/AI_DISCLOSURE.md), and the [full disclaimer](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/DISCLAIMER.md). The fork offers no device repair, recovery or replacement service.
