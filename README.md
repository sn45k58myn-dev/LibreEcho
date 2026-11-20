# Echo 2 0.15.0 · First Echo 2 build

For the full-size Amazon Echo 2nd Generation (2017), Radar/Puffin.

## Changes

- Added optional Home Assistant listening chimes and fixed silent voice turns and HTTP request cleanup.
- Built the personal signed firmware and five matching feature packs.

## Validation

Initial installation, boot and owner setup passed on one full-size Echo 2. Native Sendspin playback was unreliable, so AirPlay served as the temporary music route.

## Exact build sources

Public source commit IDs reflect an authorship metadata cleanup. The source files match the inputs of the tested firmware.

Build `radar-puffin-build-6059a7e-20ee4e9eea21de8a-2026111822324915`.

| Component | Commit |
| --- | --- |
| Product | [`6059a7ea6fd14ee32621d6c61fb13add523e66f8`](https://github.com/sn45k58myn-dev/LibreEcho/commit/6059a7ea6fd14ee32621d6c61fb13add523e66f8) |
| UI | [`7119e28fc7464c321375f5b5df9d95c0051d3929`](https://github.com/sn45k58myn-dev/LibreEcho-UI/commit/7119e28fc7464c321375f5b5df9d95c0051d3929) |
| Platform | [`99197eff816d2696cc8760a4a1cd86cc4fe216b0`](https://github.com/sn45k58myn-dev/LibreEcho-Platform/commit/99197eff816d2696cc8760a4a1cd86cc4fe216b0) |
| Linux | [`5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0`](https://github.com/sn45k58myn-dev/LibreEcho-Linux/commit/5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0) |

The signed firmware stays local because the audio FPGA component is marked as blocked for redistribution. GitHub's generated archives contain this release record and its source pins.

This independent, AI-assisted fork builds on [LibreEcho by Andy Slater and contributors](https://github.com/aslater3/LibreEcho). See [attribution](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/ATTRIBUTION.md), [AI disclosure](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/AI_DISCLOSURE.md), and the [full disclaimer](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/DISCLAIMER.md). The fork offers no device repair, recovery or replacement service.
