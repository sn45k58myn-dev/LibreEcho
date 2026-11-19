# Frozen source history

The adjacent bundle preserves only the new source commits above upstream `8c6c2590620378ea1ae3fbd4a85a7526bd3ab7bb`. Its exact source head is `6059a7ea6fd14ee32621d6c61fb13add523e66f8`. Verify with `git bundle verify tested-source.bundle`, then fetch `HEAD` locally.

The original upstream commit must be available in the clone. If a shallow clone omits it, fetch that exact upstream base before verifying. No private signing seed, device data or firmware image is included.
