# Credits

This project stands on the work of many people. This file lists whose code is
in the tree, which libraries the builds use, and which projects gave ideas.
Each entry has a note on where the fact comes from. If a line is wrong, open an
issue.

## Code in this tree

| Who | What | Licence | Evidence |
|---|---|---|---|
| Anton Artemov ([antoxa2584x/nfsu2-sw](https://github.com/antoxa2584x/nfsu2-sw)) | The base of this tree: the NFSU2 port for Nintendo Switch and Linux, the renderers, the APU and movie work, `src/`, `switch/`. This tree forked upstream at commit 6e19726 (2026-10-06, "Merge pull request #16", version 0.5) and includes upstream up to d3bbc30 (0.5.13), merged by hand with the iOS and NFSU1 work. Parts of the renderer changes of 0.5.12 and 0.5.13 are not merged (see [CHANGELOG.md](CHANGELOG.md)). | **No licence file upstream.** This project does not grant or claim a licence for this code. | Git history of this tree. The upstream repository has no `LICENSE`. |
| Ned Heller ([sp00nznet](https://github.com/sp00nznet)), maintainer of [xboxrecomp](https://github.com/sp00nznet/xboxrecomp), and its contributors | `xboxrecomp/`: the lifter (disassembler, function finder, x86 to C translator), the Xbox kernel layer, the D3D8 and NV2A layers, the runtime. The other contributors are listed in [xboxrecomp/CONTRIBUTORS.md](xboxrecomp/CONTRIBUTORS.md). | MIT for the toolkit as sp00nznet publishes it, except the files below. The copy in this tree also holds changes by the upstream port and by this fork (see [LICENSE-NOTES.md](LICENSE-NOTES.md)); the MIT label does not cover those. | `xboxrecomp/LICENSE` ("Copyright (c) 2026 sp00nz"), `xboxrecomp/CONTRIBUTORS.md` ("Maintainer: Ned Heller"). The dev notes call this copy "xboxrecomp main + PR #128 + all port changes". |
| espes, Jannik Vogel, Matt Borgerson, and the other xemu contributors ([xemu](https://github.com/xemu-project/xemu)) | The MCPX APU and NV2A code extracted from xemu (list below) | LGPL-2.1-or-later | The file headers and `xboxrecomp/NOTICE`. Full text: `xboxrecomp/LICENSES/LGPL-2.1.txt`. |
| Martin Storsjo ([msvc-wine](https://github.com/mstorsjo/msvc-wine)) | The scripts under `xboxrecomp/tools/conformance/msvc-wine/` (install, download and wrapper scripts) | ISC | `xboxrecomp/tools/conformance/msvc-wine/README.md` ("Vendored from msvc-wine (ISC)") and `LICENSE.msvc-wine.txt`. |
| Huang Qinjin | `xboxrecomp/tools/conformance/msvc-wine/msvctricks.cpp` | ISC | File header: "Copyright (c) 2023 Huang Qinjin" with the ISC text. |
| Babbs966 ([Babbs966](https://github.com/Babbs966)) | SaltyNX frame-rate reporting for the Switch (`src/switch_saltynx.c`) and its fixes (upstream pull requests #24 and #28). The first of the commits has the author name "Domenico". | **No licence file upstream.** This project does not grant or claim a licence for this code. | Commit authors in the upstream history (`git log 6e19726..d3bbc30`). |
| BaZZtian | The per-swapchain-image "rendered" semaphore fix, from the PAL-EU pull request #26 (taken into upstream 0.5.10 by Anton Artemov, "without the rest of it"). | **No licence file upstream.** | The upstream commit message of 3911d7e. |
| kaskabayev (this fork) | The iOS port (UIKit shell, touch controls, settings panel, MoltenVK path, launch screen, disc image reading), the NFSU1 port, the unified build, runtime fixes, the original artwork. | Proposal: see [LICENSE-NOTES.md](LICENSE-NOTES.md) | Git history. |

Files from xemu (LGPL-2.1-or-later), with what each file header says:

- `xboxrecomp/src/apu/apu_core.c`, `apu_dsp.c`, `apu_vp.c`, `apu_regs.h`,
  `apu_state.h`, `apu_debug.h`, `fpconv.h`, and `src/nv2a/nv2a_regs.h`. These
  are listed in `xboxrecomp/NOTICE`.
- Files with an xemu origin that `xboxrecomp/NOTICE` does not list. Each one
  says so in its own header:
  - `xboxrecomp/src/nv2a/nv2a_core.c`: "Adapted from xemu (Copyright (c) 2012
    espes, 2015 Jannik Vogel, 2018-2025 Matt Borgerson) - LGPL v2+".
  - `xboxrecomp/src/nv2a/nv2a_state.h`: "Standalone adaptation of xemu's
    nv2a_int.h", same copyright line, LGPL v2+.
  - `xboxrecomp/src/apu/apu.h`: "Extracted from xemu (LGPL v2+)".
  - `xboxrecomp/src/nv2a/qemu_shim.h`: a shim that lets xemu's NV2A code
    build standalone. Its header has no licence line. Treat it like the files
    it serves.
  - `xboxrecomp/src/apu/apu_shim.h`: the same kind of shim for the APU. Its
    header gives the LGPL (version 2 or later) and the lines "Copyright (c)
    2026 Burnout 3 Static Recompilation Project" and "Based on xemu code:
    Copyright (c) 2012 espes, 2018-2025 Matt Borgerson et al."
- About the "Burnout 3 Static Recompilation Project" line: the xboxrecomp
  README and docs name Burnout 3 as the first game recompiled with the toolkit
  ("The origin title", sp00nznet/burnout3), and the README changelog says the
  runtime was "extracted from the Burnout 3 bring-up that started it". The
  include guard of `qemu_shim.h` is `BURNOUT3_QEMU_SHIM_H`. So the line names
  the origin project of the toolkit. No other source says more than this.

Algorithms credited by `xboxrecomp/NOTICE` (own implementations, no code
taken): Fabian Giesen's masked-increment swizzle trick (`d3d8_swizzle.h`) and
the xemu register-combiner behaviour (`d3d8_combiners.h`).

## Libraries used by the builds

These are not in the repository. The builds link them or download them.
The licence texts of the ones inside the iOS app are in
[licenses/](licenses/README.md).

| Name, version | Licence | Used for | Link |
|---|---|---|---|
| SDL 2.30.9 | zlib | window, input, audio (all hosts) | https://github.com/libsdl-org/SDL |
| MoltenVK 1.4.2 | Apache-2.0 | Vulkan on iOS | https://github.com/KhronosGroup/MoltenVK |
| glslang 15.1.0 | Mostly BSD-3-Clause, with BSD-2-Clause, MIT and Apache-2.0 parts (see its `LICENSE.txt`; generated parser files are GPL-3.0 with the Bison exception) | compiles the Vulkan shaders at run time | https://github.com/KhronosGroup/glslang |
| SPIRV-Tools (the version glslang pins) | Apache-2.0 | shader optimiser used by glslang | https://github.com/KhronosGroup/SPIRV-Tools |
| Vulkan-Headers 1.3.296 | Apache-2.0 or MIT (SPDX: `Apache-2.0 OR MIT`) | Vulkan API headers | https://github.com/KhronosGroup/Vulkan-Headers |
| FFmpeg release/7.1, VP6 decoder only | LGPL-2.1-or-later (a minimal LGPL configuration, no GPL parts; Linux and Switch builds only; `tools/build_ffmpeg_vp6.sh`) | decodes the NFSU2 intro movies | https://github.com/FFmpeg/FFmpeg |
| libnx | ISC | Switch system library | https://github.com/switchbrew/libnx |
| devkitPro toolchain and portlibs (devkitA64, switch-sdl2, switch-mesa) | mixed, see devkitPro | Switch builds | https://devkitpro.org |
| Mesa NVK for the Switch: [danfromtico/mesa-switch](https://github.com/danfromtico/mesa-switch), built with the patch `mesa/mesa-switch-nfsmw.patch` from [StevensND/nfsmw-nx](https://github.com/StevensND/nfsmw-nx) | MIT (Mesa). The licence of the patch is not checked: nfsmw-nx is GPL-3.0, see the open question in the notes below. | Vulkan driver on the Switch (build setup is in `docs/dev-notes-nfsu2.md`) | https://gitlab.freedesktop.org/mesa/mesa |
| libepoxy | MIT | OpenGL function loading (Linux OpenGL renderer) | https://github.com/anholt/libepoxy |
| OpenSSL | Apache-2.0 (3.x) | linked by the Linux kernel layer (`xboxrecomp/src/kernel/CMakeLists.txt`) | https://www.openssl.org |
| Capstone | BSD-3-Clause | x86 disassembly in the lifter (`pip install capstone`) | https://github.com/capstone-engine/capstone |
| Pillow, DejaVu fonts | HPND (Pillow); Bitstream Vera licence (DejaVu) | `tools/make_art.py` draws the artwork | https://python-pillow.org, https://dejavu-fonts.github.io |

Open question for the owner: `mesa-switch-nfsmw.patch` comes from a GPL-3.0
project. If the patch is GPL-3.0, a Switch Vulkan binary that a user builds with
it contains GPL-3.0 code. The patch is not in this repository.

Licence names in this table come from the library files cited where those were
at hand (glslang `LICENSE.txt`, Vulkan-Headers `LICENSE.md`, SPIRV-Tools
`LICENSE`) and from general knowledge for the others. Check the library's own
licence before you redistribute a build.

## Ideas and references (no code taken)

- [bep1s69/nfsmw-ios](https://github.com/bep1s69/nfsmw-ios) (GPL-3.0; its
  `LICENSE` was read): several iOS ideas: a point-resolution drawable on big
  iPads, a compact drawable (screen buffer at render size), and 30 fps when the
  phone is warm. The notes say "Idea from nfsmw-ios (GPLv3), no code taken."
- [StevensND/nfsmw-nx](https://github.com/StevensND/nfsmw-nx) (GPL-3.0):
  the idea to decode the movies with FFmpeg, and a reference for what works
  on the Switch (Vulkan on NVK, native rewrites of hot functions, LTO). The
  notes say "take ideas, not files". The one thing taken is a build input: its
  Mesa patch (see the libraries table).
- DemoxDev/NFSMW-Recompiled (GPL-3.0), myUdav4iik/nfsu2-ios and
  DevZer0D4Y/nfsu2-ios (ideas, for example `-ffp-contract=off`),
  PalindromicBreadLoaf/NXVK. The "ideas" label for these four comes from the
  maintainer, not from the notes in this tree.
- [xboxdevwiki.net](https://xboxdevwiki.net), [XboxDev](https://github.com/XboxDev)
  (extract-xiso, ghidra-xbe), [antangelo/xdvdfs](https://github.com/antangelo/xdvdfs),
  nxdk, [Cxbx-Reloaded](https://github.com/Cxbx-Reloaded/Cxbx-Reloaded),
  envytools, Fabian Giesen (the swizzle trick).
- [N64Recomp](https://github.com/N64Recomp/N64Recomp),
  [XenonRecomp](https://github.com/hedge-dev/XenonRecomp) and
  [RexGlue](https://github.com/rexglue/rexglue-sdk): the approach to static
  recompilation.

Tools a user needs on iOS: [LiveContainer](https://github.com/LiveContainer/LiveContainer)
and [SideStore](https://sidestore.io) for sideloading.

## See also

Related projects by the upstream author. This tree uses none of their code.

- [antoxa2584x/nfsu1-sw](https://github.com/antoxa2584x/nfsu1-sw): an NFSU1
  port for the Switch. The NFSU1 port in this tree was lifted independently
  with the vendored toolkit.
- [antoxa2584x/nfsc-sw](https://github.com/antoxa2584x/nfsc-sw)
- [antoxa2584x/burnout3-sw](https://github.com/antoxa2584x/burnout3-sw) (MIT)
- [antoxa2584x/flatout2-sw](https://github.com/antoxa2584x/flatout2-sw) (MIT)

Thanks to everyone who contributed to the upstream project. See the
[upstream contributors page](https://github.com/antoxa2584x/nfsu2-sw/graphs/contributors).

## Artwork

The icons and the loading-screen logo are original. `tools/make_art.py` draws
them. They use no logo, font or image of Electronic Arts.
