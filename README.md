# Echo 2 0.15.1 · Native Sendspin recovery

For the full-size Amazon Echo 2nd Generation (2017), Radar/Puffin.

## Changes

- Preserved Sendspin lifecycle replies through speaker engine recovery.
- Added real SDK and sink regression coverage for resuming, skipping and two-player timing.

## Validation

Signed OTA passed on the same Echo. The owner verified native playback, voice stop and restart, and judged two-speaker playback aligned after a fresh group start. Acoustic offset and long-duration sync were unmeasured.

## Exact build sources

Public source commit IDs reflect an authorship metadata cleanup. The source files match the inputs of the tested firmware.

Build `radar-puffin-build-ebca7eb-6cbe12b1742fc622-2026111921451769`.

| Component | Commit |
| --- | --- |
| Product | [`dc560d5b57a533888c8558217ae9bf57271ebc62`](https://github.com/sn45k58myn-dev/LibreEcho/commit/dc560d5b57a533888c8558217ae9bf57271ebc62) |
| UI | [`4e38d3b45fe110242d79a54e6274093318f2d6a0`](https://github.com/sn45k58myn-dev/LibreEcho-UI/commit/4e38d3b45fe110242d79a54e6274093318f2d6a0) |
| Platform | [`99197eff816d2696cc8760a4a1cd86cc4fe216b0`](https://github.com/sn45k58myn-dev/LibreEcho-Platform/commit/99197eff816d2696cc8760a4a1cd86cc4fe216b0) |
| Linux | [`5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0`](https://github.com/sn45k58myn-dev/LibreEcho-Linux/commit/5bc811d3cd7091e8d70f9faa0bc12c5cf4e77ae0) |

The signed firmware stays local because the audio FPGA component is marked as blocked for redistribution. GitHub's generated archives contain this release record and its source pins.

This independent, AI-assisted fork builds on [LibreEcho by Andy Slater and contributors](https://github.com/aslater3/LibreEcho). See [attribution](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/ATTRIBUTION.md), [AI disclosure](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/AI_DISCLOSURE.md), and the [full disclaimer](https://github.com/sn45k58myn-dev/LibreEcho/blob/docs/community-publication/DISCLAIMER.md). The fork offers no device repair, recovery or replacement service.
