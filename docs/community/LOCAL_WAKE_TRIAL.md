# Comparing on-device and Home Assistant wake detection

This development branch targets the existing LibreEcho Linux installation on the full-size second-generation Echo (Radar/Puffin). Its first test compares an owner-supplied openWakeWord classifier with the Home Assistant wake pipeline during music playback. A second classifier runs temporarily on the speaker. Both receive the same mono 16 kHz microphone signal after the speaker's echo cancellation. Home Assistant continues to answer requests during the comparison.

## What changes

The development runtime supports the normalization operations used by some openWakeWord classifiers and reads the score output name from the model. The stock Alexa classifier is still supported. The comparison tool uses the same decoder, sensitivity mapping and voice activity detection code as the speaker. It prints detection scores, sample positions, processing time and dropped-frame counts. The temporary process keeps its audio buffer in memory. Only the existing Home Assistant connection receives audio off-device.

The public branch contains code for the detector. Each owner supplies the model weights separately. The released 0.16.8 runtime cannot load classifiers that require the new operations. No firmware installation is needed to run this trial on an Echo already using LibreEcho.

The host model tool also supports this branch. With the dependencies in `tools/wakeword/requirements.txt` installed, run `python3 tools/wakeword/wakeword_model.py check --profile local-trial "$LOCAL_CLASSIFIER"` to check an export. The default profile checks compatibility with the released firmware. [UI and wake detector source](https://github.com/sn45k58myn-dev/LibreEcho-UI/tree/feature/on-device-wake-word) · [ARM runtime source](https://github.com/sn45k58myn-dev/LibreEcho-Platform/tree/feature/on-device-wake-word)

## Build and run

1. On x86-64 Linux with Docker, run the following command from this branch. The first build downloads and compiles public dependencies. The output is a standalone ARM32 executable. The build does not require an OTA signing key.

   ```sh
   bash tools/community-build/build-wake-trial.sh ./wake-trial-output
   ```

2. From a computer with Python 3 and an existing authorised ADB connection, run a preflight. Use the device identifier listed by `adb devices`. The Echo must already be connected to Home Assistant with server wake detection active.

   ```sh
   python3 tools/wakeword/compare-local.py --serial "$ECHO_SERIAL" --preflight
   ```

3. Play music on the Echo at its usual volume. Keep the track, listening position and volume fixed. Start a 90-second comparison using the classifier you want to test.

   ```sh
   python3 tools/wakeword/compare-local.py --serial "$ECHO_SERIAL" \
     --binary ./wake-trial-output/wake-trial-arm32 --model "$LOCAL_CLASSIFIER" \
     --context music --seconds 90
   ```

4. After `ready`, leave ten seconds of music alone, then try the wake phrase five times from the same spot. Follow each with a short request and allow the reply to finish. Count the answers you hear. Use the detection events and a Home Assistant Assist trace to distinguish local detections, server detections and spoken answers. Repeat at the same distance and volume on another track before changing the default detector. To collect a quiet comparison, pause playback and pass `--context quiet`.

## Reading a result

A valid run reports its frame count, scores, detections, peak score and maximum inference time. A high score alone does not establish a detection. Count unintended detections during the music-only interval separately. An invalid run, a gap in the stream, or missing server evidence cannot establish which detector heard more attempts. Local wake detection still uses Home Assistant for speech recognition and replies in this setup.

The launcher starts at the speaker's configured sensitivity. For a second run you can pass `--trial-sensitivity 100` for a threshold of 0.41, the most sensitive setting in the device's slider range. Check a music-only interval at that setting before comparing spoken attempts. This flag applies only to the temporary detector.

## First hardware comparison

The smaller ARM runtime was built from public source and exercised directly on Echo 2 hardware. With one synthetic voice, its classifier scored 0.971 for the wake phrase alone, 0.962 for the phrase digitally mixed with music at equal RMS level, and 0.00084 for the same music alone. A different synthetic voice scored 0.002 on the same phrase. These digital fixtures test the inference path. The room test below also includes the speaker, microphone array and echo cancellation.

On one full-size Echo 2, both systems listened during two 120-second music trials. The reference ARM build ran the first trial. The second used the smaller ARM executable built by the public recipe. Each run processed 12,000 consecutive microphone frames and 1,500 classifier scores with zero dropped blocks.

| Trial | Local threshold | Local detections | Home Assistant wake detections | Highest local score |
| --- | ---: | ---: | ---: | ---: |
| Configured sensitivity, five attempts | 0.551 | 0 | 2 | 0.451 |
| Maximum trial sensitivity, five attempts | 0.410 | 1 | 3 | 0.811 |

The single local detection in the second trial aligned with a Home Assistant detection. Its score also exceeded the original threshold, so the second result cannot be attributed to the threshold change alone. These results support keeping the existing server detector as the default on that unit. Other models, voices, rooms and playback levels need their own measurements.

The trial ends automatically and its launcher removes the temporary classifier and executable. It makes no changes to the installed wake model, OTA settings, speaker volume or Assist pipeline. The existing firmware and the public component sources are credited in [Attribution](../../ATTRIBUTION.md).
