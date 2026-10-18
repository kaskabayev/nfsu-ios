# Need for Speed: Underground 1 and 2 — Xbox recompilation

This project runs the original Xbox (NTSC-U) versions of **Need for Speed:
Underground 2** and **Need for Speed: Underground** as native programs. A
tool lifts the game's x86 code to C. A runtime replaces the Xbox kernel, the
GPU, the sound chip and the USB pads. There is no emulator.

| Platform | NFSU2 | NFSU1 |
|---|---|---|
| iOS (iPhone, iPad) | runs, touch controls, settings panel | runs, same shell |
| Linux x86-64 | runs (SDL2, Vulkan or OpenGL) | runs (Vulkan) |
| Nintendo Switch | runs (see [docs/SWITCH.md](docs/SWITCH.md)) | not supported |

This tree is based on the upstream Switch/Linux port
[antoxa2584x/nfsu2-sw](https://github.com/antoxa2584x/nfsu2-sw) at commit
6e19726 (version 0.5) and includes upstream up to d3bbc30 (version 0.5.13).
Some renderer changes of 0.5.12 and 0.5.13 are not merged yet (see
[CHANGELOG.md](CHANGELOG.md)). See [CREDITS.md](CREDITS.md) for everyone whose work is
in this tree.

## Read this first

- This project is **not affiliated with or endorsed by Electronic Arts or
  Microsoft**. "Need for Speed" and "Underground" are trademarks of
  Electronic Arts. "Xbox" is a trademark of Microsoft.
- **You need your own copy of the game.** You must own an NTSC-U Xbox disc of
  the game and make a disc image of it yourself.
- **This repository has no game files and no game code.** There is no disc
  image, no `default.xbe`, no lifted C and no IPA here.
- The lifted C is the game's own code in another form. It belongs to
  Electronic Arts. The lift script creates it on your machine from your own
  `default.xbe`. Never commit it, upload it or share it. For the same reason
  there are no ready-made IPA or NRO files: they would contain that code.

## Features

- Both games run as recompiled C, built on
  [xboxrecomp](https://github.com/sp00nznet/xboxrecomp).
- Renderers: Vulkan (MoltenVK on iOS, NVK on Switch) and OpenGL. Render scale
  from 0.5x to 4x.
- iOS: touch controls (a Pad layout and a Drive layout, a layout editor,
  haptics, tilt steering), a settings panel, an optional launch screen, a
  60 fps race mode, and options to reduce heat.
- NFSU2: widescreen 16:9 with the game's own wide mode. Full-screen intro
  movies. Two-player split screen on the Switch.
- NFSU2: in-game options for car reflections, resolution scale, anisotropic
  filtering and vibration strength; the audio volumes are kept across
  launches (`nfsu2x_options.txt`, see [docs/SETTINGS.md](docs/SETTINGS.md)).
  On by default; off on iOS (`NFSU2_OPTIONS=1` turns them on).
- Disc images are read directly (XISO and Redump layouts). You do not need to
  unpack the disc on iOS.
- Audio through an emulated Xbox sound chip (APU).
- Gamepads and keyboards where the host supports them.

## Supported discs

Only the NTSC-U releases work. The lifted code is tied to one `default.xbe`
per game.

| Game | Title ID | Version | `default.xbe` SHA-256 | Entry point |
|---|---|---|---|---|
| NFSU2 | `0x4541005A` | 1 | `95c22b9c594f0c187f602ac6484fe4cb65a9d53dafe3110ed815598eb9dcb0bd` | `0x0021B1CE` |
| NFSU1 | `0x45410047` | 1 | `cdd562ffcc70906b3fecd841db4dc10fd463664b05e03f896a8fb38b9a7d878a` | `0x00164356` |

What the program checks at start (`src/main.c`):

- Disc image: the program reads `default.xbe` from the image. If the title ID
  is wrong, it stops with an error. If the version or the SHA-256 differs, it
  prints a warning in the log and continues.
- Extracted folder: the program does not check the XBE. Use the right folder.

At build time, CMake compares the entry point in the lifted code with the
entry point of the selected game. If they differ, configuration stops. This
stops you from building NFSU1 with the lifted code of NFSU2 (or the reverse).

## Install on iPhone or iPad

No IPA is distributed. You build it yourself from your own disc (see
"Build from source"). Then you install the unsigned IPA with a sideloading
tool.

1. Install [SideStore](https://sidestore.io) or
   [LiveContainer](https://github.com/LiveContainer/LiveContainer). A free
   Apple account allows only 3 sideloaded apps. LiveContainer runs several
   apps inside one app, so it is useful for two games.
2. Install your IPA (`NFSU2` or `NFSU1`) with it.
3. Open the app once. If it finds no game data, it shows a launch screen and
   creates its Documents folder. In the Files app, the folder is
   **On My iPhone > NFSU2** (or **NFSU1**).
4. Copy the disc image into that folder. Put it directly in the folder, not
   in a sub-folder. Open the app again.

Which file names the app accepts (`src/main.c`, `xboxrecomp/src/kernel/xbox_xiso.c`):

- The app looks for `default.xbe` in the Documents folder, then in these
  sub-folders, in this order. NFSU2: `NFSU2-data`, `game`, `nfsu2`, `NFSU2`.
  NFSU1: `NFSU1-data`, `game`, `nfsu1`, `NFSU1`.
- If it finds no `default.xbe`, it uses a disc image. It takes the first file
  in Documents whose name ends in `.iso` (any case), sorted by name. The
  launch screen shows `NFSU2.iso` or `NFSU1.iso` as the example name, but any
  name that ends in `.iso` works. Keep only one image per game folder.
- `NFSU2_ISO=<path>` in the settings file names an image directly.
- Saves go to a `UDATA` folder in the game folder. A disc image is never
  changed.

Under LiveContainer the app's Documents folder is the one that LiveContainer
gives to that app. To put the disc image there:

1. Open the Files app.
2. Open the LiveContainer folder.
3. Find the data folder of the NFSU2 or NFSU1 app inside it.
4. Copy the disc image into that folder.

If you are not sure which folder it is, open the app once. Then look for the
newest folder that holds `<game>_log.txt` (`nfsu2_log.txt` or `nfsu1_log.txt`).

An iPhone with an A17 Pro chip is the main test device. Other devices are
untested. A16 chips and older do not support BC (DXT) textures in hardware,
so the program decodes them on the CPU, which costs speed.

## Build from source

### 1. Get the tools

- Linux or macOS, `git`, `cmake` 3.20 or newer, a C compiler, `python3` 3.10
  or newer, and the Python package `capstone` (`pip install capstone`). The
  lifter needs only these.
- A disc image of your own game.

Get the repository and take `default.xbe` out of your disc image. The tool
for this is in the repository:

```sh
git clone https://github.com/kaskabayev/nfsu-ios.git && cd nfsu-ios
(cd xboxrecomp && python3 -m tools.xiso get /path/to/NFSU2.iso default.xbe -o /path/to/nfsu2/)
```

### 2. Lift the game

```sh
XBE=/path/to/nfsu2/default.xbe GEN=/path/to/gen-nfsu2 tools/lift.sh nfsu2
XBE=/path/to/nfsu1/default.xbe GEN=/path/to/gen-nfsu1 tools/lift.sh nfsu1
```

This takes about 4.5 minutes (NFSU1) to 7 minutes (NFSU2) on an 8-core Linux
machine and writes about 100 MB of C into `GEN`. The script first writes the
XBE analysis (`GEN/xbe_analysis.json`: sections and imports of your own
`default.xbe`) with `tools.xbe_parser`. That file is metadata of your disc: do
not commit it. Use one `GEN` folder per game. Lift the games one after the
other, not at the same time. The output is your own copy of EA's code in
another form: keep it private. `.gitignore` excludes the folder names `gen`, `gen-*` and
`gen_*` at the top of the repository. If you use another folder name, keep
the folder outside the repository.

Per-game settings for the lifter are in `games/<game>/config/`
(`lift.conf`, `seed_functions.json`).

### 3a. Build on Linux

Dependencies: SDL2, libepoxy and OpenSSL development files, and `pkg-config`.
The build needs libepoxy for every Linux configuration, also with Vulkan. For
the Vulkan renderer (`-DNFSU2_VULKAN=ON`) you also need a Vulkan loader and
headers, and glslang with SPIRV-Tools. Without `NFSU2_VULKAN` the OpenGL
renderer is used.

```sh
cmake -S . -B build-nfsu2 -DCMAKE_BUILD_TYPE=Release -DNFSU_GAME=nfsu2 \
      -DNFSU2_VULKAN=ON -DNFSU2_GEN_DIR=/path/to/gen-nfsu2
cmake --build build-nfsu2 -j8
NFSU2_GAME_DIR=/path/to/folder-with-the-iso build-nfsu2/nfsu2_recomp
```

For NFSU1 use `-DNFSU_GAME=nfsu1`, the `gen-nfsu1` folder and
`build-nfsu1/nfsu1_recomp`. Use the lifted code of the same game that you
select: CMake checks this.

Without `-DNFSU2_FFMPEG_DIR` the lifted movie decoder plays the NFSU2
movies. `tools/build_ffmpeg_vp6.sh linux` builds a small FFmpeg with only the
VP6 decoder (LGPL).

### 3b. Build for iOS

Linux cannot build the IPA. You need macOS with Xcode and its command line
tools. The configuration is documented at the top of the iOS section of
`CMakeLists.txt`:

```sh
cmake -S . -B build-ios -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 \
      -DCMAKE_OSX_SYSROOT=iphoneos -DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
      -DNFSU_GAME=nfsu2 -DNFSU2_GEN_DIR=/path/to/gen-nfsu2 -DNFSU2_VULKAN=ON \
      -DCMAKE_PREFIX_PATH=<SDL2 and glslang install> \
      -DMOLTENVK_FRAMEWORK=<MoltenVK.framework>
```

The libraries it needs: SDL 2.30.9 (static), glslang 15.1.0 with SPIRV-Tools,
Vulkan-Headers 1.3.296 and the MoltenVK 1.4.2 framework. Then wrap
`build-ios/nfsu2_recomp.app` into an unsigned IPA, with the icons from
`games/nfsu2/ios/`. Sideloading tools sign it when they install it.

If you have no Mac, build on GitHub Actions. See the next section.
The file `.github/workflows/ios-feasibility.yml` only builds the runtime
libraries for iOS. It needs no game files.

### Build the IPA on GitHub Actions

The workflow `build-ipa` lifts your own `default.xbe` on a Linux runner. Then
it builds the app on a macOS runner and gives you an unsigned IPA. You need a
**private** repository, because the lifted C is the game's code.

1. Make a private repository. A fork of a public repository cannot be
   private, so create a new private repository on GitHub. Then run:
   ```sh
   git clone https://github.com/kaskabayev/nfsu-ios.git && cd nfsu-ios
   git remote set-url origin <your private repo>
   git push -u origin main
   ```
2. Take `default.xbe` out of your disc image (see "Get the tools" above,
   `tools.xiso get`). Rename it to `nfsu2.xbe` or `nfsu1.xbe`.
3. In the private repository, create a release with the tag `xbe`. Attach the
   file. (A release of a private repository is private.)
4. Open Actions > build-ipa > Run workflow. Pick the game. Download the IPA
   artifact when the run is done. Install it as described in "Install on
   iPhone or iPad".

Notes:

- The lift runs on Linux and takes about 4 minutes. The iOS build runs on
  macOS. It takes about 4 minutes the first time, and about 1 minute later,
  when the libraries come from the cache.
- A private repository uses the Actions minutes of your account. One macOS
  minute counts as 10 minutes. So the first build uses about 45 minutes of
  your quota, and a later build about 15. (Measured on GitHub-hosted runners
  in October 2026. The free plan gives 2000 minutes per month.)
- The workflow compares the SHA-256 of your XBE with the value in
  `games/<game>/game_profile.h`. It stops if they differ.
- The workflow refuses to run in a public repository. The lifted code and the
  IPA hold the game's code. In a public repository, everyone could download
  them.
- The lifted code is kept as an artifact for 1 day. The IPA is kept for 3
  days.
- Optional inputs: `xbe_release` (another release tag) and `bundle_id`
  (default `io.github.<owner>.<game>`).
- Never upload the lifted code, the IPA or the XBE to a public place.

### 3c. Build for Nintendo Switch

See [docs/SWITCH.md](docs/SWITCH.md). NFSU2 only.

## Settings

On iOS, tap the gear button in the game to open the settings panel. It writes
`Documents/<game>_env.txt` (`nfsu2_env.txt` or `nfsu1_env.txt`). You can edit
the file by hand: one `KEY=VALUE` per line, `#` starts a comment. Most
changes need a restart. On Linux the same keys are environment variables. On
the Switch the file is `nfsu2x_env.txt` next to the NRO.

The launch screen is off by default. `NFSU2_LAUNCHER=1` turns it on. The app
always shows it when it finds no game data.

Main keys (the key names start with `NFSU2_` or `RECOMP_` for both games):

| Key | Values | Meaning |
|---|---|---|
| `RECOMP_GL_SCALE` | 0.5 to 4 (iOS default 2) | Render resolution, as a multiple of the original 640x480. |
| `RECOMP_WIDESCREEN` | 1 or 0 | NFSU2: 16:9 (default 1). NFSU1: leave it 0; it only stretches the 4:3 picture. |
| `RECOMP_PRESENT_INTERVAL` | 1 or 0 (iOS default 1) | 1 = races at 60 fps. 0 = the game's own 30 fps. |
| `RECOMP_VK_PACE` | 0 or 1 (iOS default 0) | 1 = show each frame at the screen refresh that keeps the game's rate. 0 = only measure (the default: measured on device, pacing gave no gain and added delay; kept for A/B). The `[pace]` line in the log (every 10 s) counts the refreshes each frame stayed on screen: `2v` is two refreshes (30 fps). Many frames in `3v`, `4+v` or `late` mean uneven motion. |
| `RECOMP_VK_PACE_MS` | 0 to 50 (default 12) | The least time in ms between the game's frame and the refresh that shows it. More time means fewer `late` frames and more delay. At 60 fps keep it below 14. |
| `NFSU2_GAMMA` | 0.5 to 2 | Brightness. |
| `RECOMP_VK_MIPS` | 1 or 0 | Mipmaps. |
| `RECOMP_VK_ANISO` | 1, 2, 4, 8, 16 (iOS default 4) | Texture filtering. |
| `RECOMP_VK_CUBE` | 1 or 0 | Car reflections (Vulkan). |
| `NFSU2_MOVIE_CROP` | 1 or 0 | NFSU2: movies fill a 16:9 screen. |
| `RECOMP_AUDIO_VOLUME` | 0 to 100 | Volume. |
| `SDL_AUDIO_CATEGORY` | `playback` | Stop mixing with the audio of other apps. |
| `NFSU2_TOUCH_LAYOUT` | `pad`, `drive` | Touch layout. |
| `NFSU2_TOUCH_AUTO` | 1 or 0 | Switch between Pad and Drive by the game state (experimental). |

Kill switches for the heat and battery changes. Each one turns one change
back to the old behaviour. Use them to find out which change causes a
problem on your device.

| Key | Meaning |
|---|---|
| `NFSU2_HOT_30=off\|lpm\|serious\|fair` | When the phone is hot (or in Low Power Mode), races run at 30 fps. Default `serious`. `off` never lowers the rate. |
| `NFSU2_COMPACT_DRAWABLE=0` | Do not shrink the screen buffer to the render size. |
| `RECOMP_QOS=0` | Do not raise the priority of the game and GPU threads. |
| `RECOMP_GIL_WAKE_ALL=1` | Old guest-lock wake-up scheme (more wake-ups). |
| `RECOMP_TICK_MS=1` | Old 1 ms clock thread (default 4 ms). |
| `RECOMP_FENCE_SLEEP=0` | Spin instead of sleeping while the game waits for the GPU. |
| `RECOMP_FENCE_SLEEP_US=1000` | Shorter sleep time while waiting for the GPU. |
| `RECOMP_FLAG_WAIT_US=4000` | Longer GPU flag thread wait (default 1000). |
| `RECOMP_CPU_LOG=10` | Print CPU use per thread to the log every 10 s (default on iOS). `0` turns it off. |
| `NFSU2_POINT_RES=0` | Big iPads: use the native pixel resolution instead of points. |

The full list of keys is in [docs/SETTINGS.md](docs/SETTINGS.md).

If you used NFSU1 builds u1-1 to u1-5: those builds used the NFSU2 file
names. The new build reads the old `nfsu2_env.txt` once and copies it to
`nfsu1_env.txt`. The touch layout files work differently: if
`nfsu1_touch_layout_phone.txt` (or `_pad.txt`) does not exist, the build reads
the old `nfsu2_touch_layout_*.txt`. The next save of the layout editor writes
the new name.

## Troubleshooting

The log file is `Documents/<game>_log.txt` on iOS (`nfsu2_log.txt` or
`nfsu1_log.txt`). On Linux the program writes the log to the terminal. On the
Switch it is next to the NRO.

- "No game data found": the app finds no `default.xbe` and no `.iso` in
  Documents. Check the folder and the file name.
- "wrong game ... title ID": the image is not the NTSC-U disc of this game.
- A warning "default.xbe differs from the build's disc": your disc is another
  printing than the one the lifted code was made from. The game may still
  run. Lift the code from your own `default.xbe` to be safe.
- The phone gets hot: leave `NFSU2_HOT_30` at `serious`, lower the render
  scale to 1.5 or 1, or set `RECOMP_PRESENT_INTERVAL=0`.

To report a problem, open an issue and attach the log file. The log has a
line that starts with `build ` (the version banner). Also write which game,
which device and which iOS version you use. Do not attach game files.

## Layout of the repository

| Path | What |
|---|---|
| `games/nfsu2/`, `games/nfsu1/` | per-game code: manual overrides, state reader, game profile, lifter config, icons |
| `src/` | shared startup code, iOS launch screen, movie decoder, Switch layer |
| `xboxrecomp/` | the toolkit: lifter, runtime, renderers, with this project's changes |
| `tools/` | `lift.sh` (lift a game), `make_art.py` (draws the icons), tests |
| `.github/` | issue template and workflows: `build-ipa.yml` (IPA from your own game file), `ios-feasibility.yml` (runtime libraries only) |
| `switch/` | Switch build script |
| `docs/` | developer notes, performance notes, Switch notes, settings reference |

## Credits and licence

[CREDITS.md](CREDITS.md) lists the code in this tree, the libraries the builds
use, and the projects that gave ideas.

Licence facts:

- The upstream port by Anton Artemov has no licence file. This project does
  not grant a licence for that code.
- The toolkit that sp00nznet publishes as `xboxrecomp` is MIT licensed
  (`xboxrecomp/LICENSE`). Some of its files come from xemu and are
  LGPL-2.1-or-later (`xboxrecomp/NOTICE`). The copy in this tree also holds
  changes made by the upstream port and by this fork (for example the Vulkan
  renderer in `xboxrecomp/src/nv2a_vk/`). The MIT label of the toolkit does not
  cover those changes. They keep the status of their authors. See
  [LICENSE-NOTES.md](LICENSE-NOTES.md).
- The changes made in this fork are MIT licensed ([LICENSE](LICENSE)), to the
  extent the fork's author can license them. Edits inside upstream files
  cannot be licensed apart from the upstream code. See
  [LICENSE-NOTES.md](LICENSE-NOTES.md).
- The game belongs to Electronic Arts. This project has no rights to it.
