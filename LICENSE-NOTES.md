# Licence notes

This file records what is known about the licences in this tree. The
[LICENSE](LICENSE) file holds the MIT licence for the changes made in this fork.

## What is in the tree

| Part | Licence | Source of the fact |
|---|---|---|
| Upstream port ([antoxa2584x/nfsu2-sw](https://github.com/antoxa2584x/nfsu2-sw), Anton Artemov): the base of `src/`, `switch/` and the renderer and APU work | **None stated.** The upstream repository has no licence file. No licence is claimed or granted here for this code. | Upstream repository |
| The toolkit as sp00nznet publishes it ([sp00nznet/xboxrecomp](https://github.com/sp00nznet/xboxrecomp) and its contributors) | MIT | `xboxrecomp/LICENSE` |
| Changes inside `xboxrecomp/` made by the upstream port (Anton Artemov). The dev notes call the copy "xboxrecomp main + PR #128 + all port changes". Likely examples: the Vulkan renderer `src/nv2a_vk/` (upstream pull request #16 "vulkan"; it is not named in the toolkit's README or contributor list), the OpenGL renderer work, the SDL audio output, the Switch platform layer. The history of this tree is shallow, so which file is whose is not provable here. | **None stated.** The MIT label of the toolkit does not cover these changes. | `docs/dev-notes-nfsu2.md`, upstream README at 6e19726 ("vendored with this port's changes: NV2A renderers (Vulkan, OpenGL), SDL audio, Switch platform layer, translator fixes") |
| xemu-derived files in `xboxrecomp/src/apu/` and `xboxrecomp/src/nv2a/` | LGPL-2.1-or-later | File headers, `xboxrecomp/NOTICE`, `xboxrecomp/LICENSES/LGPL-2.1.txt`. See [CREDITS.md](CREDITS.md) for the files that `NOTICE` does not list. |
| `xboxrecomp/tools/conformance/msvc-wine/` | ISC | `LICENSE.msvc-wine.txt`, header of `msvctricks.cpp` |
| Changes made in this fork: the iOS port, the NFSU1 port, the unified build, runtime fixes, `tools/make_art.py` and its artwork, the docs. Files the fork added under `xboxrecomp/`: `src/platform/ios_keyboard.m`, `ios_touch_overlay.m`, `ios_vblank.m`, `cpu_report.c/.h`, `app_id.h`, `src/input/xinput_ios.c/.h`, `src/kernel/xbox_xiso.c/.h` (disc image reader). The fork also edited existing files in `xboxrecomp/` (for example `src/nv2a_vk/nv2a_vk.c`, `src/kernel/kernel_bridge.c`). | **MIT** ([LICENSE](LICENSE)), to the extent the fork's author can license the changes. See below. | Git history of this tree (the fork's commits, author kaskabayev) |

Where the fork's changes are edits inside upstream files, they cannot be
licensed separately from the upstream code. A licence for those parts needs
the upstream author's permission.

## Licence of the changes in this fork

The changes made in this fork are MIT licensed ([LICENSE](LICENSE)), to the
extent the fork's author can license them. This covers the files the fork
added (for example `games/nfsu1/`, `src/ios_launcher.m`, `tools/lift.sh`,
`tools/make_art.py`, and the iOS files under `xboxrecomp/` listed above) and
the fork's own edits.

Edits inside upstream files cannot be licensed apart from the upstream code.
The licence status of that code stays as the table above states.

## Game data and lifted code

The game, its code and its data belong to Electronic Arts. This repository
holds none of them and never must:

- no disc image, no `default.xbe`, no game files;
- no lifted C (the output of `tools/lift.sh`). It is the game's code in
  another form;
- no IPA or NRO built from lifted C.

Each user makes the lifted C from their own copy of the game, on their own
machine.
