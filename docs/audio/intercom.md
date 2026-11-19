# Local phone intercom

This is an experimental feature for the local 0.16.0 candidate. It has not
been validated on an Echo or iPhone yet. It is separate from Sendspin music
playback and from the existing spoken-broadcast feature.

The first version lets a phone start a call to one LibreEcho speaker and talk
both ways over home Wi-Fi. Open the speaker's own web page in Safari and keep
that page in the foreground throughout the call. Locking the phone, changing
tabs or leaving the page ends the call. Incoming intercom calls or background calling on iPhone,
room-to-room calling and calling from outside the home are not provided by
this version.

## Before the first call

The speaker needs a candidate image containing the intercom service, its
existing audio and wakeword services, Home Assistant voice mode, and a local
account. Calling starts disabled on each speaker. A configuration export does
not transfer permission to another speaker.

The phone must open the speaker over **trusted HTTPS**. Safari's microphone
access requires a secure origin; dismissing a certificate warning is not the
setup procedure. The certificate must cover the exact name or address used to
open the page. LibreEcho already accepts an owner-supplied certificate through
its HTTPS certificate API; see the UI repository's API reference. Keep the
private key on the speaker and in the owner's protected backup, never in a
Git repository or a diagnostic report.

A private home certificate authority can cover future speakers too, with a
separate server key and certificate on each speaker. The owner must install
and explicitly trust its public certificate on the iPhone. See
[Apple's certificate trust instructions](https://support.apple.com/en-ie/102390)
and [WebKit's media capture origin policy](https://webkit.org/blog/7763/a-closer-look-into-webrtc/#security-origin-policy-for-media-capture).
Certificate and real Safari setup remain acceptance checks for this candidate.

## Make a call

1. On home Wi-Fi, open the speaker's trusted HTTPS address and sign in.
2. Open **Intercom** and enable **Allow calls to this speaker**.
3. Press **Call room** and grant Safari microphone permission.
4. Wait for the connected message and the room's start cue. The ring indicates
   the call; speech can then travel both ways.
5. Use **Mute my microphone** to silence your phone, or **End call** to finish.

Only one caller can use a speaker at a time. Every signed-in local account can
use a speaker whose calling permission is enabled; the current account system
does not provide per-person calling roles. Disable **Allow calls to this
speaker** when calls should no longer be allowed.

The speaker's microphone mute, physical privacy switch and Do Not Disturb
reject or end calls. An unavailable audio service or privacy state also blocks
calling. The intercom temporarily holds Home Assistant Assist while connected
and releases that hold when the call ends. A crashed process cannot leave a
permanent Assist hold: its short lease expires.

## Future speakers

The browser control and audio protocol are reusable. Future LibreEcho boards
can supply the same native intercom endpoint while retaining their own audio,
echo-cancellation and physical privacy handling. Each new board needs its own
driver, packaging and hardware checks. An existing ESPHome or Sendspin player
does not automatically acquire an intercom microphone path.

The source contract is `docs/INTERCOM_PROTOCOL.md` in LibreEcho-UI. The initial
format is 16 kHz mono audio, with authenticated same-origin HTTPS/WSS control
and bounded live buffers. Sendspin continues to own synchronized music; call
audio does not become a synchronized music source.

## Validation status

Host tests use generated audio and simulated microphone/output endpoints. They
check both audio directions, authentication, stale-call cleanup, privacy and
mute gates, bounded queues and crash cleanup. These checks do not establish
real microphone pickup, acoustic echo cancellation, Safari routing or call
quality. Those remain device acceptance checks before the feature can be
described as working on a particular speaker.
