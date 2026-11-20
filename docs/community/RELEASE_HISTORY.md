# Echo 2 release history

These source pre-releases record the development builds for the **full-size Echo 2nd Generation (2017), Radar/Puffin**. Each one links the exact source commits and records its validation. The signed images stay local because the audio FPGA component is marked as blocked for redistribution.

| Version | Main change | Hardware and validation |
| --- | --- | --- |
| [0.16.3](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.3) | Verified two-way iPhone intercom | Signed OTA and startup passed. One foreground iPhone Safari call had audible audio in both directions. The Echo released the audio connection when the call ended. A fresh 0.16.3 installation still awaits a hardware test. |
| [0.16.2](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.2) | Phone audio recovery | Signed OTA from 0.16.0 passed and Home Assistant reconnected. The subsequent iPhone call reached the Echo and played its cue, then disconnected. |
| [0.16.1](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.1) | Persistent intercom settings | Focused tests, signed image checks and read-only preflight passed. The candidate stayed at preparation stage and was skipped in the hardware update sequence. |
| [0.16.0](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.0) | First local intercom | Signed OTA and startup passed. The initial iPhone trials exposed a persistent-settings mismatch and phone audio interruptions. Two-way audio was unconfirmed on this build. |
| [0.15.1](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.15.1) | Native Sendspin recovery | Signed OTA passed on the same Echo. The owner verified native playback, voice stop and restart, and judged two-speaker playback aligned after a fresh group start. Acoustic offset and long-duration sync were unmeasured. |
| [0.15.0](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.15.0) | First Echo 2 build | Initial installation, boot and owner setup passed on one full-size Echo 2. Native Sendspin playback was unreliable, so AirPlay served as the temporary music route. |

Start with the [0.16.3 build record](0.16.3.md) for the current Sendspin and intercom implementation. The older releases document progress and evidence. For a fresh compatible unit, the 0.16.3 initial-install bundle can be used as the first LibreEcho version once the device is prepared. For an existing compatible LibreEcho installation, the 0.16.3 OTA requires the matching personal signing trust.

The [Sendspin setup guide](https://github.com/sn45k58myn-dev/LibreEcho/blob/feature/intercom-guide/docs/audio/sendspin.md) covers pairing a native Music Assistant player. The [intercom guide](https://github.com/sn45k58myn-dev/LibreEcho/blob/feature/intercom-guide/docs/audio/intercom.md) covers trusted HTTPS, call permission and the microphone. Use a separate device name, owner account, Music Assistant pairing and HTTPS certificate for each speaker.

See [upstream attribution](../../ATTRIBUTION.md), the [AI disclosure](../../AI_DISCLOSURE.md) and the [full disclaimer](../../DISCLAIMER.md).
