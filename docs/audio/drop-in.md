# Room-to-room drop-in

**Development status.** An experimental Home Assistant bridge is being developed for local, two-way calls between two LibreEcho speakers. Host tests exercised routing and audio relay with simulated endpoints. A full call between two physical speakers still awaits validation. The published **0.16.3** test covered one foreground iPhone Safari call to one Echo 2. [Phone intercom guide](intercom.md) · [0.16.3 release](https://github.com/sn45k58myn-dev/LibreEcho/releases/tag/echo2-source-v0.16.3)

## How it works

Say your configured wake phrase and a request such as **“Drop in on the kitchen.”** Home Assistant uses the initiating Assist satellite and the requested room to identify the source and destination. A configured list of permitted directions controls which room pairs can call. Each speaker still controls whether it allows calls.

The bridge requires two compatible LibreEcho intercom endpoints, two configured Home Assistant Assist satellites, local speaker accounts and trusted HTTPS from Home Assistant to each speaker. Both speakers must be reachable on the local network. A stock ESPHome or Sendspin endpoint needs a compatible intercom adapter to participate in two-way audio.

## What needs a hardware test

1. Verify [phone intercom](intercom.md) independently on both speakers, including the call cue, ring indicator and microphone privacy controls.
2. Start a permitted room-to-room call by voice and confirm audio travels both ways. Check that an unlisted room pair and an unavailable speaker both refuse the call.
3. Stop the call from Home Assistant. Check that the indicators clear and normal Assist returns on both speakers.
4. Check that disabling calls, muting a speaker's microphone or enabling its physical privacy control prevents or ends the call. Verify cleanup after a connection loss.

When reporting a test, give the build and device model for each endpoint, the outcome in each audio direction and the result of the privacy checks. Use sample room names and remove addresses, credentials, session data and recordings from shared reports.
