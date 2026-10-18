# Changelog

Short notes per release of this fork. The upstream Switch and Linux port has
its own release history in [antoxa2584x/nfsu2-sw](https://github.com/antoxa2584x/nfsu2-sw);
this tree is based on upstream version 0.5 (commit 6e19726). Version numbers
below are the fork's build tags.

## NFSU1 (iOS and Linux)

- u1-6: one tree with NFSU2, nfsu1_* file names, original icons.
- u1-5: less heat at 30 fps (the shared runtime changes of NFSU2 v32).
- u1-4: fix a crash in the EA Trax menu, race state for Auto Pad/Drive, the GPU wait sleeps.
- u1-3: keep textures the game freed while they are still drawn.
- u1-2: own app icon, 60 fps races.
- u1-1: first build; NFSU1 boots on the NFSU2 shell.

## NFSU2 (iOS, Linux, Switch)

- v33: one tree with NFSU1, original icons.
- v32: less heat at 30 fps: fewer wake-ups, screen buffer at render size, 30 fps when the phone is hot, CPU log lines.
- v31: the D3D fence wait sleeps instead of spinning.
- v30: keep textures the game freed while they are still drawn; no fused multiply-add in native math.
- v29: point-resolution drawable on big iPads; no launch screen at start.
- v28: full-press pedals by default, no floating sticks in Drive, d-pad as four arrow buttons.
- v27: mipmaps and anisotropic filtering (Vulkan), guest vblank locked to the display, app icon, quieter log, 60 fps races on by default on iOS.
- v26: cutscenes stay at 30 fps in the 60 fps mode; the white flash frames in the opening movie are shown black.
- v25: fix the speed-up of 60 fps races (main-loop time floor); relative steering with a narrower strip and a steering curve.
- v24: new touch controls: layer-based zones, driving-feel options, layout editor, captions and icons, pre-launch screen, Auto Pad/Drive, safe-area handling.
- v23: settings panel, second touch layout (Drive), hardware keyboard, disc image (XISO) reading, clear as load op on tile GPUs.
- v22: MoltenVK async submits, high-priority queue, background handshake, swapchain rebuild limiter, 10 s measurement lines.
- v21: fixes for rendering artifacts (snap shift, invariant position, 65536-vertex draws, gamma ramp ordering).
- v20: render scale 2 by default on iOS, thread priority option, pipeline cache saved more often, safe-area gear button, floating stick visuals, fix for the 17th settings line.
- v19: gamma pass rebuilt for Metal (pipeline rendering info, offscreen surface, LUT fixes).
- v18: gamma pass without push constants (MoltenVK crashed on them).
- v17: fix the black screen in the gamma present pass.
- v16: present interval forced where the game reads it; gamma pass on all platforms; stricter settings file reader.
- v14, v15: no tagged commits. Between v13 and v16 came the first form of `RECOMP_PRESENT_INTERVAL=1` (present every vblank) and the export of settings file keys to the environment.
- v13: corrected touch zone table, labels by zone id, overlay hides when a pad connects, FPS counter, shader caches in Documents.
- Before v13 (first iOS builds): runtime and Vulkan renderer build for iOS with SDL and MoltenVK; game and save folders in the app's Documents; touch pad overlay and layout; settings file keys exported to the environment; main-thread renderer start; crash reporter and boot log; fixes for the MoltenVK missing features (no triangle fans, optional vertex-input extension, per-layout pipelines).
