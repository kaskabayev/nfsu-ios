# Licences of the components in the iOS app

This folder holds the licence texts of the code that the iOS app (NFSU2 and
NFSU1) contains. `tools/make_notices.sh` joins this file and all texts into
one `THIRD-PARTY-NOTICES.txt`. The build-ipa workflow puts this folder and
that file into the app.

The versions below are the ones that `.github/workflows/build-ipa.yml` pins.
Each text was fetched unchanged from the upstream repository at the tag or
commit in the "Text from" column. If a component has no `NOTICE` file at that
tag, the table says so.

## Code in the app

| Component | Version | Licence | Used for | Files |
|---|---|---|---|---|
| This project (kaskabayev fork): iOS port, NFSU1 port, unified build, runtime fixes | this repository, the commit named in the notices | MIT | the app | `nfsu-ios-MIT.txt` |
| xboxrecomp ([sp00nznet/xboxrecomp](https://github.com/sp00nznet/xboxrecomp)): the runtime, the Xbox kernel layer and the renderers | vendored in `xboxrecomp/` | MIT | the runtime | `xboxrecomp-MIT.txt` |
| xemu files in `xboxrecomp/src/apu/` and `xboxrecomp/src/nv2a/` ([xemu](https://github.com/xemu-project/xemu): espes, Jannik Vogel, Matt Borgerson) | vendored in `xboxrecomp/` | LGPL-2.1-or-later, **statically linked** (see the relink note below) | Xbox sound chip and GPU register code | `xemu-LGPL-2.1.txt` |
| Upstream port ([antoxa2584x/nfsu2-sw](https://github.com/antoxa2584x/nfsu2-sw), Anton Artemov), commit 6e19726 | vendored (base of `src/` and of the renderer and APU work) | **No licence stated.** The upstream repository has no licence file. No licence is claimed or granted here for this code. | the base of the port | none |
| SDL | 2.30.9 (`release-2.30.9`), linked statically | zlib | window, input, audio | `SDL2-zlib.txt` |
| SDL: HIDAPI (iOS controller code inside SDL) | in SDL 2.30.9 | BSD-style, chosen from the three HIDAPI licences | game controllers | `SDL2-hidapi-README.txt`, `SDL2-hidapi-BSD.txt`, `SDL2-hidapi-orig.txt` |
| SDL: yuv2rgb | in SDL 2.30.9 | BSD-3-Clause | video format conversion | `SDL2-yuv2rgb-BSD-3-Clause.txt` |
| glslang | 15.1.0, linked statically | Several licences in one file: BSD-3-Clause, BSD-2-Clause, MIT, Apache-2.0, and GPL-3.0 with a Bison exception (the last section of the file); see the file | compiles the Vulkan shaders at run time | `glslang-LICENSE.txt` |
| SPIRV-Tools | commit 4d2f0b40bfe290dea6c6904dafdf7fd8328ba346 (the commit glslang 15.1.0 pins in `known_good.json`), linked statically | Apache-2.0 | shader optimiser used by glslang | `SPIRV-Tools-Apache-2.0.txt` |
| SPIRV-Headers | commit 3f17b2af6784bfa2c5aa5dbb8e0e74a607dd8b3b (pinned by the same `known_good.json`), compiled into SPIRV-Tools | MIT-style Khronos licence | SPIR-V definitions | `SPIRV-Headers-LICENSE.txt` |
| Vulkan-Headers | v1.3.296 (headers only) | Apache-2.0 OR MIT | Vulkan API declarations | `Vulkan-Headers-LICENSE.md`, `Vulkan-Headers-Apache-2.0.txt`, `Vulkan-Headers-MIT.txt` |
| MoltenVK | v1.4.2, prebuilt `MoltenVK.framework` in the app | Apache-2.0 | Vulkan on top of Metal | `MoltenVK-Apache-2.0.txt` |
| SPIRV-Cross (inside MoltenVK) | commit 6c09849fe88c48eaed08413aa022aaa136a3a057 | Apache-2.0 | shader translation | `SPIRV-Cross-Apache-2.0.txt` |
| volk (inside MoltenVK) | commit 776893306c5d3b22b6185b5d4a258b81d94572bf | MIT | Vulkan function loader | `Volk-MIT.txt` |
| cereal (inside MoltenVK) | commit a56bad8bbb770ee266e930c95d37fff2a5be7fea | BSD-3-Clause | serialisation | `cereal-BSD-3-Clause.txt` |

MoltenVK v1.4.2 also contains its own copies of SPIRV-Tools (commit
0d6fd73ca73830ccab5fa1f00ed5ed40124e2c55), SPIRV-Headers (commit
29981f65241605e08b0ede4cfeb999fe3b723c6a) and Vulkan-Headers (commit
e3b1eec08173d6b825cd3ac88c885a63b621504a). They are listed in its
`ExternalRevisions` folder. Their licences are the ones in the rows above.

Where the texts come from, all anonymously from the upstream repositories:

- SDL: `https://github.com/libsdl-org/SDL` at tag `release-2.30.9`
  (`LICENSE.txt`, `src/hidapi/LICENSE*.txt`, `src/video/yuv2rgb/LICENSE`).
- glslang: `https://github.com/KhronosGroup/glslang` at tag `15.1.0`
  (`LICENSE.txt`).
- SPIRV-Tools: `https://github.com/KhronosGroup/SPIRV-Tools` at the commit
  above (`LICENSE`).
- SPIRV-Headers: `https://github.com/KhronosGroup/SPIRV-Headers` at the commit
  above (`LICENSE`).
- Vulkan-Headers: `https://github.com/KhronosGroup/Vulkan-Headers` at tag
  `v1.3.296` (`LICENSE.md`, `LICENSES/Apache-2.0.txt`, `LICENSES/MIT.txt`).
- MoltenVK: `https://github.com/KhronosGroup/MoltenVK` at tag `v1.4.2`
  (`LICENSE`).
- SPIRV-Cross: `https://github.com/KhronosGroup/SPIRV-Cross` at the commit
  above (`LICENSE`).
- volk: `https://github.com/zeux/volk` at the commit above (`LICENSE.md`).
- cereal: `https://github.com/USCiLab/cereal` at the commit above (`LICENSE`).
- xboxrecomp: `xboxrecomp/LICENSE` in this repository. xemu LGPL text:
  `xboxrecomp/LICENSES/LGPL-2.1.txt` in this repository.
- This project: `LICENSE` in this repository.

No `NOTICE` file exists at the tag or commit used for SDL, glslang,
SPIRV-Tools, SPIRV-Headers, Vulkan-Headers, MoltenVK, SPIRV-Cross, volk and
cereal (checked). The `NOTICE` file of xboxrecomp is `xboxrecomp/NOTICE` in
this repository; it lists the xemu files.

## LGPL-2.1-or-later parts (xemu files)

The xemu files are linked statically into the app. The LGPL asks that a user
can change those files and relink the app. The full source and the build
scripts of the app are in this repository (`xboxrecomp/`, `CMakeLists.txt`,
`tools/lift.sh`, `.github/workflows/build-ipa.yml`). To relink, lift the game
from your own `default.xbe` with `tools/lift.sh`, then build the app with
the changed files as the README describes. `THIRD-PARTY-NOTICES.txt` names
the commit of this repository that the app was built from.

## Not in the iOS app

These are in the repository or in other builds, but the iOS app does not
contain them, so their licences are not part of the app notices:

- FFmpeg (VP6 decoder): used only when a build sets `NFSU2_FFMPEG_DIR`. The
  build-ipa workflow does not set it. The iOS app plays the movies with the
  decoder lifted from the game.
- The Mesa/NVK patch, libnx, devkitPro: Switch builds only.
- OpenSSL: not linked on iOS (`xboxrecomp/src/kernel/CMakeLists.txt`).
- libepoxy: used by the Linux OpenGL renderer only.
- Capstone, Pillow, DejaVu fonts, msvc-wine: build and developer tools. They
  run on the build machine and are not part of the app.
- Apple system frameworks (UIKit, Metal and others) and the C++ runtime: part
  of iOS.

## The game

The game belongs to Electronic Arts. The app contains the game's program
code, translated ahead of time, and none of its assets. See
`LICENSE-NOTES.md`. This project has no rights to the game.
