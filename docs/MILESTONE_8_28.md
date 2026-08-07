# Milestone 8.28 — Audible Adaptive Score and Battlefield Mix

Version 8.28 makes the existing adaptive score reliably audible and separates musical and environmental mixing responsibilities.

## Stem normalization

The 24-second Calm, Tension, and Assault WAV stems are normalized to a consistent average loudness with controlled true peaks. Transitioning into combat no longer causes a perceived loudness drop.

## Adaptive director reliability

- Score peaks use a stronger audible range while remaining controlled by the Music slider.
- A two-second fade-in avoids an abrupt soundtrack start.
- Once-per-second playback checks restart stopped stems at the active synchronized position.
- Combat intensity above 76% gradually applies up to 2 dB of ducking for weapon clarity.
- Startup prints an explicit adaptive-score-active confirmation.

## Bus separation

Battlefield ambience now routes through a dedicated Ambience bus. Its level follows 55% of the Effects setting, while the score remains exclusively controlled by Music. New profiles use a 75% Music default; existing profile values are preserved.

## Compatibility

Audio changes are graphical-client presentation only. Headless servers do not instantiate the soundtrack or ambience. Objectives, combat, bots, classes, network messages, and protocol 341 are unchanged.
