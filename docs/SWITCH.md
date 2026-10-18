# Nintendo Switch

The Switch port was made by Anton Artemov
([antoxa2584x/nfsu2-sw](https://github.com/antoxa2584x/nfsu2-sw)). The text
below comes from the README of that project at commit 6e19726 (version 0.5),
with small edits for this tree. This tree does not contain the later upstream
work (0.5.13 and newer). For newer Switch builds and releases, use the
upstream project. Only NFSU2 builds for the Switch; NFSU1 does not.

No game data is included. You need your own copy of the Xbox disc,
extracted (`default.xbe`, `NFSUNDER/`, ...).

## Features

- Native code: the whole game runs as recompiled C, built with
  [xboxrecomp](https://github.com/sp00nznet/xboxrecomp).
- Two renderers: Vulkan (NVK on Switch) and OpenGL, with render scaling up to 4x.
- Widescreen 16:9 by default, using the game's own wide mode.
- Full-screen movies decoded with FFmpeg (VP6).
- Audio through an emulated Xbox APU, with 5.1 downmixed to stereo.
- Two-player split screen, with Joy-Con pairs or one sideways Joy-Con per player.
- Rumble on Switch HD rumble and SDL controllers.
- Switch wording in the menus (Start becomes `+`, no Xbox Live or hard-disk names).
- Saves stay next to the game in `game/UDATA`.

## Playing on Switch

1. Copy the NRO to `sdmc:/switch/nfsu2x/` (`nfsu2x-vulkan.nro` for the Vulkan
   build).
2. Copy the **extracted** disc (not the ISO) to `sdmc:/switch/nfsu2x/game/`.
3. Start it with **title takeover**: hold **R** while launching any game.
   Applet mode leaves too little memory.

```
sdmc:/switch/nfsu2x/
├── nfsu2x-vulkan.nro
├── nfsu2x_env.txt      optional settings, KEY=VALUE per line
├── nfsu2x_options.txt  written by the in-game options (see below)
└── game/
    ├── default.xbe
    └── ...
```

Buttons map by label (Switch A = Xbox A). Settings go in `nfsu2x_env.txt`
(see [SETTINGS.md](SETTINGS.md)) and the log is written to the same folder.

NFSU2 has its own rows in the game's Options menu: Video has Car Reflections
(On/Off) and, in the Vulkan build only, Resolution Scale (1x to 2.5x; applies
at the next start) and Anisotropic (a cap: Off to 16x); Gameplay has Vibration
(Off, 10% to 100%).
The Audio volumes are kept across launches. All of it is stored in
`nfsu2x_options.txt` (`reflections=`, `scale=`, `aniso=`, `vibration=` and one
key per volume, 0 to 1). `NFSU2_OPTIONS=0` turns the rows and the file off.
Anti-Aliasing and Square Pixels rows of upstream 0.5.13 are not in this tree
yet. The Switch reports its frame rate to SaltyNX (Status Monitor);
`NFSU2_SALTYNX=0` turns that off. When sys-clk or Horizon OC runs, the
`NFSU2_*_MHZ` lines are ignored (`NFSU2_CLOCK_FORCE=1` overrides).

Races run at 30 fps by default in this tree (only the iOS build sets
`RECOMP_PRESENT_INTERVAL=1`). `RECOMP_PRESENT_INTERVAL=1` in `nfsu2x_env.txt`
runs them at 60 fps; upstream 0.5.13 runs them at 60 by default.

## Building the NRO

You need devkitA64, switch-sdl2 and switch-mesa from devkitPro, and the
lifted C of your own `default.xbe` (see the README, "Lift the game").

```sh
NFSU2_GEN_DIR=/path/to/gen NFSU2_GAME_SRC=/path/to/game switch/build.sh
# Vulkan build (needs mesa-switch NVK and glslang built for the Switch)
VULKAN=1 JOBS=6 NFSU2_GEN_DIR=/path/to/gen NFSU2_GAME_SRC=/path/to/game \
  NVK_SDK=/path/to/mesa-sdk/usr/local GLSLANG_DIR=/path/to/glslang-switch \
  switch/build.sh
```

The movies use a small FFmpeg build with only the VP6 decoder
(`tools/build_ffmpeg_vp6.sh switch`, then `FFMPEG_DIR=...`). Without it the
lifted decoder plays them, slowly. Do not link devkitPro's `switch-ffmpeg`: it
is built with `--enable-gpl`.

Engineering notes about the Switch port are in
[dev-notes-nfsu2.md](dev-notes-nfsu2.md), [PERF_NOTES.md](PERF_NOTES.md) and
[VULKAN_NOTES.md](VULKAN_NOTES.md).

## Status

| Platform | State (upstream 0.5) |
|---|---|
| Switch hardware | Boot, movies, profile load/create, Main Menu, races |

Open: cube maps on OpenGL (Vulkan has them: car reflections), bump and
dot-product texture modes, fixed-function lighting.
