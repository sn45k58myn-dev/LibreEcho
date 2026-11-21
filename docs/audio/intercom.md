# Local phone intercom

Local intercom lets a phone place a two-way call to a LibreEcho speaker on the home network. Build **0.16.8** reduces the sound of the caller's voice returning through the Echo's room microphone. An iPhone caller heard the improvement on a full-size Echo 2 after a signed update. [0.16.8 results and first-install guide](../community/0.16.8.md)

Keep Safari in the foreground and the phone unlocked during the call. Background reception, calling away from home and longer calls are outside the validated setup. See the [room-to-room drop-in development status](drop-in.md) for calls between speakers.

## Set up the speaker and phone

1. Use a LibreEcho build that includes the intercom service and select **Home Assistant** voice mode on the speaker.
2. Set up HTTPS on the speaker. Its certificate must cover the exact address you open in Safari. If you use a private certificate authority, give each speaker its own certificate and key, then add and trust the authority's public certificate on the iPhone. Keep private keys in protected storage. [Apple certificate trust instructions](https://support.apple.com/en-ie/102390) · [WebKit microphone access requirements](https://webkit.org/blog/7763/a-closer-look-into-webrtc/#security-origin-policy-for-media-capture)
3. On home Wi-Fi, open the speaker's HTTPS page in Safari and sign in with a local speaker account.
4. In **Intercom**, turn on **Allow calls to this speaker**. The setting starts disabled and applies to this speaker. While enabled, its signed-in local accounts can place calls.
5. Press **Call room**, grant Safari microphone access and wait for the connected state. The speaker sounds a cue and lights its ring before live audio starts.
6. Use **Mute my microphone** for the phone's microphone or **End call** to finish. Turn off **Allow calls to this speaker** to revoke permission and end any pending or active call.

## Privacy and troubleshooting

One caller can use a speaker at a time. The speaker service checks call permission, microphone mute, physical privacy, Do Not Disturb and audio availability. It pauses Assist during the call and releases it when the call ends. Use the feature on a trusted local network. [Intercom protocol and privacy checks](https://github.com/sn45k58myn-dev/LibreEcho-UI/blob/984ebc22cf68f1900e931d1129357db91951ea06/docs/INTERCOM_PROTOCOL.md)

If the call fails before connecting, check the certificate against the address you opened, Safari microphone permission, Home Assistant voice mode and the speaker's call permission. Check the mute and Do Not Disturb settings if the room refuses the call. For a report, include the build, browser, call stage and redacted error text. Keep network addresses, session information and recordings private.

Phone intercom carries live conversation. Music Assistant handles synchronized music through [Sendspin](sendspin.md).
