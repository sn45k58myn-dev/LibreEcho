# Echo 2 release history

These source pre-releases record the development builds for the **full-size Echo 2nd Generation (2017), Radar/Puffin**. Each one links the exact source commits and records its validation. The complete signed images stay in the local toolkit. The [0.16.8 build record](0.16.8.md#build-identification) explains the third-party component and source-offer records.

| Version | Main change | Hardware and validation |
| --- | --- | --- |
| [0.16.8](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.8) | Call-specific echo cancellation | Signed OTA confirmed on one Echo 2. The iPhone caller heard less echo. The complete first-install kit passed offline preparation. |
| [0.16.3](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.3) | Verified two-way iPhone intercom | Signed OTA and startup passed. One foreground iPhone Safari call had audible audio in both directions. The Echo released the audio connection when the call ended. A fresh 0.16.3 installation still awaits a hardware test. |
| [0.16.2](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.2) | Phone audio recovery | Signed OTA from 0.16.0 passed and Home Assistant reconnected. The subsequent iPhone call reached the Echo and played its cue, then disconnected. |
| [0.16.1](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.1) | Persistent intercom settings | Focused tests, signed image checks and read-only preflight passed. The candidate stayed at preparation stage and was skipped in the hardware update sequence. |
| [0.16.0](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.0) | First local intercom | Signed OTA and startup passed. The initial iPhone trials exposed a persistent-settings mismatch and phone audio interruptions. Two-way audio was unconfirmed on this build. |
| [0.15.1](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.15.1) | Native Sendspin recovery | Signed OTA passed on the same Echo. The owner verified native playback, voice stop and restart, and judged two-speaker playback aligned after a fresh group start. Acoustic offset and long-duration sync were unmeasured. |
| [0.15.0](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.15.0) | First Echo 2 build | Initial installation, boot and owner setup passed on one full-size Echo 2. Native Sendspin playback was unreliable, so AirPlay served as the temporary music route. |

### Changes since the previous public release

| Development build | Change included in 0.16.8 |
| --- | --- |
| 0.16.4 | Added timing measurements for Home Assistant voice turns. |
| 0.16.5 | Updated microphone processing and the playback reference used for echo cancellation. |
| 0.16.6 | Kept intercom speech flowing through short audio stalls. |
| 0.16.7 | Preserved the playback reference as sound starts and as the speaker falls silent. |
| 0.16.8 | Applied a separate filter to the room microphone audio sent to the phone during a call. |

Start with the [0.16.8 build record](0.16.8.md) for exact inputs and [first-install and OTA requirements](0.16.8.md#use-0168-on-the-next-echo-2). The older releases document progress and evidence.

The [Sendspin setup guide](../audio/sendspin.md) covers pairing a native Music Assistant player. The [phone intercom guide](../audio/intercom.md) covers trusted HTTPS, call permission and the microphone. Use a separate device name, owner account, Music Assistant pairing and HTTPS certificate for each speaker. Follow the [drop-in work](../audio/drop-in.md) for the separate room-to-room prototype.

See [upstream attribution](../../ATTRIBUTION.md), the [AI disclosure](../../AI_DISCLOSURE.md) and the [full disclaimer](../../DISCLAIMER.md).
