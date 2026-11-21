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

The trial ends automatically and its launcher removes the temporary classifier and executable. It makes no changes to the installed wake model, OTA settings, speaker volume or Assist pipeline. The existing firmware and the public component sources are credited in [Attribution](../../ATTRIBUTION.md).
