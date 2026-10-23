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

- u1-8: less CPU work per frame. The 4x4 matrix multiply (23% of the game thread) and the float-to-integer routine run as native C (`NFSU1_NATIVE_MAT=0`, `NFSU1_NATIVE_FTOL=0` or `RECOMP_NATIVE=0` turn them off; `RECOMP_NATIVE_CHECK=1` compares them with the lifted code); the bulk pushbuffer path is on (`RECOMP_PB_RUN=0` turns it off). Linux race: game thread 9.1 to 7.0 ms per frame. The renderer changes of NFSU2 v34g.
- u1-7: upstream 0.5.13 merged: lifter fixes (flag joins, rounding float to int, D3D to D3D function pointers, split-off stubs); the bulk pushbuffer path and the per-axis vertex snap are off.
- u1-6: one tree with NFSU2, nfsu1_* file names, original icons.
- u1-5: less heat at 30 fps (the shared runtime changes of NFSU2 v32).
- u1-4: fix a crash in the EA Trax menu, race state for Auto Pad/Drive, the GPU wait sleeps.
- u1-3: keep textures the game freed while they are still drawn.
- u1-2: own app icon, 60 fps races.
- u1-1: first build; NFSU1 boots on the NFSU2 shell.

## NFSU2 (iOS, Linux, Switch)

- v34j: cars keep their detailed models about 7.5 times as far away at the 1.5x render scale. The game picks a car model (A .. D) from the car's size on screen in 640x480 pixels, so at 1.5x each model switch covered 1.5 times the screen pixels it did on the Xbox (a traffic van, for example, changed its outline, mirrors and lights in one frame). The sizes are now divided by the render scale times 5 (`NFSU2_CAR_LOD`, 0 = the game's sizes). The switch still has no cross-fade: it happens farther away and is smaller on screen. With `RECOMP_DRAW_STATS=1` the `[vk]` line adds the vertices and indices per frame.
- v34i: the time step smoother takes its rate from the trimmed mean of the last 8 frames, for the small speed-ups in 30 fps races. At 30 fps the game often runs a long frame (about 4/60 s) and a quick one in a pair; the display queue hides it, and each frame stays on screen for two refreshes. The time step smoother of v34d took its rate from the median of the last 8 frames, and with four such pairs that median is the long frame: the car moved 3 or 4/60 s per 2-refresh frame, then slowed down to pay it back (iPhone: up to 92 such steps per 10 s, debt up to 325 ms). The rate now comes from the mean of the last 8 frames without the longest and the shortest, and a debt is paid back only past the step + 1/120 s (60 fps: unchanged, except clustered late and quick pairs, which gave 2/60 s steps). `tools/tests/run_dt_smooth_test.sh` runs the smoother on recorded patterns.
- v34h: no load forcing in races. In a race the game streams the track in bursts of about 10 read jobs every 5 s. The loading-screen rule of v34d took each burst for a load: it presented about 10 frames at every refresh and reset the smooth time step (iPhone: 12 to 24 such frames and up to 144 time step paybacks per 10 s). The rule now skips races (gameflow 6); loading screens are not gameflow 6 and stay fast. The `[load]` line adds the gameflow. The late-frame wait of v34g was not the cause. The speed-ups stayed (see v34i).
- v34g: less GPU memory traffic. A pass attaches the depth buffer only when a draw tests, writes or stencils it, or when it used depth the last time (`RECOMP_VK_DEPTH_LAZY=0` turns it off); a full depth clear that the next pass will not use waits for the next pass that needs the buffer (`RECOMP_VK_CLEAR_DEFER=0`); car reflection faces are copied before a pass begins, not in the middle of one (`RECOMP_VK_CUBE_EAGER=0`). Linux estimate for the iPhone's depth format, per race frame: 49 MB loaded and 58 MB stored before, 17 and 26 MB now (dry); 162 and 171 MB before, 78 and 87 MB now in rain. The `[ios-vk2]` line adds the passes left without depth and the depth restarts. At 30 fps a late frame on iOS waits for the next refresh instead of flipping at once (`NFSU2_LATE_WAIT=0` turns it off): the display cannot tear, so the immediate flip only put the next frame on screen for one refresh. The per-word pushbuffer survey runs only with `RECOMP_PB_SCAN=1`.
- v34f: measurement for heat. On iOS the `[cpu]` line adds the GPU time billed to the game (`gpu N%`) and the kernel's CPU energy estimate (`cpu energy N mW`, not the whole phone). The `[ios-vk2]` line (and `[vk]` with `RECOMP_DRAW_STATS=1`) adds the bytes a tile GPU loads and stores per frame at the start and end of each render pass, and the full-size passes per frame. On Linux a race frame in rain had about 28 full-size passes; 20 of them are 20 round trips between the screen and a 48x48 texture (one draw each way, each sampling the other): the rain drops on the camera lens. No change in rendering. On the iPhone the `gpu` field always reads 0 (iOS does not fill it); the energy field works.
- v34e: walls and bridges near the camera no longer flash for a frame (the bridge deck showed through its underside, or a wall turned black). The vertex shader clamped the depth of each vertex, which tilted the depth of triangles that cross the near plane; with depthClamp on the device (iPhone, Linux) depth now passes through and the GPU clamps it per pixel, as the NV2A does. `RECOMP_VK_ZCLAMP=1` brings the old clamp back for A/B; the log line `[VK] vertex z:` shows the choice. NFSU1 in this tree gets it too (compile-checked only); the Switch keeps the old clamp by default (`RECOMP_VK_ZCLAMP=0` drops it).
- v34d: smooth game time step in races (`NFSU2_DT_SMOOTH=0` turns it off): the game ran its physics by the real time of each frame, so a late frame and a quick one made the car move two frames' worth and then almost nothing, with an even 60 fps on the screen. The game now gets a whole number of 1/60 s (the median of the last 8 frames), and the difference is paid back one 1/60 s at a time. Cutscenes and load stalls keep the real step. The `[dt]` line shows the raw and the used ticks per frame, the number of paybacks and the largest debt. Loading screens at the game's 30 fps present every refresh (`RECOMP_LOAD_FAST=0` turns it off): the game reads one block per frame, so a load took twice as long as at 60 fps (Linux, Quick Race: the loading screen lasted about 22 s at 30 fps, 3 to 5 s with this). The `[load]` line gives the time and the frames of each load. The iOS settings panel has tabs (Controls, Display, Audio, Advanced) and opens on the last tab used.
- v34c: present pacing on iOS is off by default (`RECOMP_VK_PACE=1` turns it on): measured on the device, race frames were already shown for exactly two refreshes each, and pacing only added delay. The `[pace]` line still measures. NFSU2 logs a `[dt]` line every 10 s with the physics ticks per frame (`RECOMP_DT_HIST=0` turns it off).
- v34b: the per-axis vertex snap is on by default on iOS (it removes the black and pink seams at render scale 2). Present pacing on iOS: each frame is shown at a refresh that keeps the game's own rate (`RECOMP_VK_PACE=0` turns it off, `RECOMP_VK_PACE_MS` sets the least delay), and a `[pace]` line in the log every 10 s counts the refreshes each frame stayed on screen.
- v34: upstream 0.5.13 merged: lifter fixes (flag joins, rounding float to int, D3D to D3D function pointers, split-off stubs), one "rendered" semaphore per swapchain image, options for car reflections, resolution scale, anisotropic filtering, vibration and audio volumes (`NFSU2_OPTIONS=0` turns them off; they are off on iOS, `NFSU2_OPTIONS=1` turns them on), SaltyNX frame rate and clock manager fixes on the Switch. On iOS the bulk pushbuffer path (`RECOMP_PB_RUN`; on for NFSU1 since u1-8) and the per-axis vertex snap (`RECOMP_VK_SNAP`) are off, and the render scale stays with `RECOMP_GL_SCALE`.
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
