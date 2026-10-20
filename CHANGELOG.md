# Changelog

Short notes per release of this project. The upstream Switch and Linux port has
its own release history in [antoxa2584x/nfsu2-sw](https://github.com/antoxa2584x/nfsu2-sw);
this tree is based on upstream version 0.5 (commit 6e19726) and includes
upstream up to 0.5.13 (commit d3bbc30), except the renderer parts listed under
"Not yet ported" below. Version numbers below are this project's build tags.

## Not yet ported (upstream 0.5.12 and 0.5.13, Vulkan renderer)

These upstream changes are in `xboxrecomp/src/nv2a_vk/nv2a_vk.c` upstream. This
tree keeps its own renderer file and does not have them yet:

- fewer barriers between render passes (`RECOMP_VK_SYNC`), the uniform and
  descriptor state cache (`RECOMP_VK_STATE_CACHE`), presenting on a worker
  thread (`RECOMP_VK_ASYNC_PRESENT`);
- the early-Z shader variant (`RECOMP_VK_NAT`; the shader generator
  `nv2a_gl_psh_no_alpha_test` is merged, the renderer does not call it);
- FXAA in the present pass (`RECOMP_VK_FXAA`) and square pixels
  (`RECOMP_VK_SQUARE`, `RECOMP_GL_SCALE_X`), with the Anti-Aliasing and Square
  Pixels rows of the Video options (`NFSU2_FXAA_ROWS`);
- changing the render scale at run time (`rescale_surfaces`): the Resolution
  Scale row applies at the next start;
- the texture cache key by pitch, mip levels, format and palette, and the DXT
  mip levels in the texture hash (upstream 0.5.10);
- the motion blur edge change for square pixels (0.5.13);
- upstream's rewrite of the flip interval in the PGRAPH handler and its camera-sequence exception:
  our swap wrappers keep deciding the 60 fps races and the hot 30 fps cap.

## NFSU1 (iOS and Linux)

- u1-7: upstream 0.5.13 merged: lifter fixes (flag joins, rounding float to int, D3D to D3D function pointers, split-off stubs); the bulk pushbuffer path and the per-axis vertex snap are off.
- u1-6: one tree with NFSU2, nfsu1_* file names, original icons.
- u1-5: less heat at 30 fps (the shared runtime changes of NFSU2 v32).
- u1-4: fix a crash in the EA Trax menu, race state for Auto Pad/Drive, the GPU wait sleeps.
- u1-3: keep textures the game freed while they are still drawn.
- u1-2: own app icon, 60 fps races.
- u1-1: first build; NFSU1 boots on the NFSU2 shell.

## NFSU2 (iOS, Linux, Switch)

- v34f: measurement for heat. On iOS the `[cpu]` line adds the GPU time billed to the game (`gpu N%`) and the kernel's CPU energy estimate (`cpu energy N mW`, not the whole phone). The `[ios-vk2]` line (and `[vk]` with `RECOMP_DRAW_STATS=1`) adds the bytes a tile GPU loads and stores per frame at the start and end of each render pass, and the full-size passes per frame. On Linux a race frame had about 28 full-size passes; 20 of them are 20 round trips between the screen and a 48x48 texture (one draw each way, each sampling the other), probably the streetlight glows. No change in rendering.
- v34e: walls and bridges near the camera no longer flash for a frame (the bridge deck showed through its underside, or a wall turned black). The vertex shader clamped the depth of each vertex, which tilted the depth of triangles that cross the near plane; with depthClamp on the device (iPhone, Linux) depth now passes through and the GPU clamps it per pixel, as the NV2A does. `RECOMP_VK_ZCLAMP=1` brings the old clamp back for A/B; the log line `[VK] vertex z:` shows the choice. NFSU1 in this tree gets it too (compile-checked only); the Switch keeps the old clamp by default (`RECOMP_VK_ZCLAMP=0` drops it).
- v34d: smooth game time step in races (`NFSU2_DT_SMOOTH=0` turns it off): the game ran its physics by the real time of each frame, so a late frame and a quick one made the car move two frames' worth and then almost nothing, with an even 60 fps on the screen. The game now gets a whole number of 1/60 s (the median of the last 8 frames), and the difference is paid back one 1/60 s at a time. Cutscenes and load stalls keep the real step. The `[dt]` line shows the raw and the used ticks per frame, the number of paybacks and the largest debt. Loading screens at the game's 30 fps present every refresh (`RECOMP_LOAD_FAST=0` turns it off): the game reads one block per frame, so a load took twice as long as at 60 fps (Linux, Quick Race: the loading screen lasted about 22 s at 30 fps, 3 to 5 s with this). The `[load]` line gives the time and the frames of each load. The iOS settings panel has tabs (Controls, Display, Audio, Advanced) and opens on the last tab used.
- v34c: present pacing on iOS is off by default (`RECOMP_VK_PACE=1` turns it on): measured on the device, race frames were already shown for exactly two refreshes each, and pacing only added delay. The `[pace]` line still measures. NFSU2 logs a `[dt]` line every 10 s with the physics ticks per frame (`RECOMP_DT_HIST=0` turns it off).
- v34b: the per-axis vertex snap is on by default on iOS (it removes the black and pink seams at render scale 2). Present pacing on iOS: each frame is shown at a refresh that keeps the game's own rate (`RECOMP_VK_PACE=0` turns it off, `RECOMP_VK_PACE_MS` sets the least delay), and a `[pace]` line in the log every 10 s counts the refreshes each frame stayed on screen.
- v34: upstream 0.5.13 merged: lifter fixes (flag joins, rounding float to int, D3D to D3D function pointers, split-off stubs), one "rendered" semaphore per swapchain image, options for car reflections, resolution scale, anisotropic filtering, vibration and audio volumes (`NFSU2_OPTIONS=0` turns them off; they are off on iOS, `NFSU2_OPTIONS=1` turns them on), SaltyNX frame rate and clock manager fixes on the Switch. On iOS the bulk pushbuffer path (`RECOMP_PB_RUN`) and the per-axis vertex snap (`RECOMP_VK_SNAP`) are off, and the render scale stays with `RECOMP_GL_SCALE`.
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
