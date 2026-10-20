# Licence notes

This file records what is known about the licences in this tree. The
[LICENSE](LICENSE) file holds the MIT licence for the changes that kaskabayev
made in this repository.

## What is in the tree

| Part | Licence | Source of the fact |
|---|---|---|
| Upstream port ([antoxa2584x/nfsu2-sw](https://github.com/antoxa2584x/nfsu2-sw), Anton Artemov, and the contributors Babbs966 and BaZZtian): the base of `src/`, `switch/` and the renderer and APU work. This tree is based on 6e19726 and includes upstream up to d3bbc30 (0.5.13). | **None stated.** The upstream repository has no licence file. No licence is claimed or granted here for this code. | Upstream repository |
| The toolkit as sp00nznet publishes it ([sp00nznet/xboxrecomp](https://github.com/sp00nznet/xboxrecomp) and its contributors) | MIT | `xboxrecomp/LICENSE` |
| Changes inside `xboxrecomp/` made by the upstream port (Anton Artemov). The dev notes call the copy "xboxrecomp main + PR #128 + all port changes". Likely examples: the Vulkan renderer `src/nv2a_vk/` (upstream pull request #16 "vulkan"; it is not named in the toolkit's README or contributor list), the OpenGL renderer work, the SDL audio output, the Switch platform layer. The history of this tree is shallow, so which file is whose is not provable here. | **None stated.** The MIT label of the toolkit does not cover these changes. | `docs/dev-notes-nfsu2.md`, upstream README at 6e19726 ("vendored with this port's changes: NV2A renderers (Vulkan, OpenGL), SDL audio, Switch platform layer, translator fixes") |
| xemu-derived files in `xboxrecomp/src/apu/` and `xboxrecomp/src/nv2a/` | LGPL-2.1-or-later | File headers, `xboxrecomp/NOTICE`, `xboxrecomp/LICENSES/LGPL-2.1.txt`. See [CREDITS.md](CREDITS.md) for the files that `NOTICE` does not list. |
| `xboxrecomp/tools/conformance/msvc-wine/` | ISC | `LICENSE.msvc-wine.txt`, header of `msvctricks.cpp` |
| Changes made by kaskabayev in this repository: the iOS port, the NFSU1 port, the unified build, runtime fixes, `tools/make_art.py` and its artwork, the docs. Files this project added under `xboxrecomp/`: `src/platform/ios_keyboard.m`, `ios_touch_overlay.m`, `ios_vblank.m`, `cpu_report.c/.h`, `app_id.h`, `src/input/xinput_ios.c/.h`, `src/kernel/xbox_xiso.c/.h` (disc image reader). This project also edited existing files in `xboxrecomp/` (for example `src/nv2a_vk/nv2a_vk.c`, `src/kernel/kernel_bridge.c`). | **MIT** ([LICENSE](LICENSE)), to the extent their author can license them. See below. | Git history of this tree (commits by kaskabayev) |

Where these changes are edits inside upstream files, they cannot be
licensed separately from the upstream code. A licence for those parts needs
the upstream author's permission.

## Licence of the changes in this project

The changes kaskabayev made in this repository are MIT licensed
([LICENSE](LICENSE)), to the extent their author can license them. This covers
the files this project added (for example `games/nfsu1/`, `src/ios_launcher.m`, `tools/lift.sh`,
`tools/make_art.py`, and the iOS files under `xboxrecomp/` listed above) and
its own edits.

Edits inside upstream files cannot be licensed apart from the upstream code.
The licence status of that code stays as the table above states.

## Game data and lifted code

The game, its code and its data belong to Electronic Arts. Two things must be
told apart: this repository, and the released app.

**This repository** holds none of the game's files and never must:

- no disc image, no `default.xbe`, no game files;
- no lifted C (the output of `tools/lift.sh`). It is the game's code in
  another form;
- no IPA, NRO or other build made from lifted C.

`.gitignore` keeps these out. The rule against committing lifted C stays.

**The released app** (the IPAs on the Releases page) contains the game's
program code. The code was translated ahead of time from x86 to C and compiled
into the app, as other static recompilation projects ship theirs (for example
[bep1s69/nfsmw-ios](https://github.com/bep1s69/nfsmw-ios)). The app contains
**none** of the game's assets: no textures, models, sounds, music, videos, text
or tracks. It does not download anything. It reads the game's data from a disc
image that the user provides.

You must own the game. Use a disc image made from your own NTSC-U disc. Do not
ask for, or share, disc images or game files in this project's issues.

The program code in the released app belongs to Electronic Arts. This project
has no rights to it and gives no licence for it.

People can also build the IPA themselves from their own `default.xbe`, in a
fork or in a private copy of the repository (see the README).

## Third-party code in the released app

The app contains code from other projects. Their licence texts are in
[licenses/](licenses/README.md). The IPA carries them in `Licenses/` and in
`THIRD-PARTY-NOTICES.txt`. The xemu files (LGPL-2.1-or-later) are linked
statically. The full source and the build scripts of the app are in this
repository, so users can rebuild and relink the app from their own
`default.xbe`.
