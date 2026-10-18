# Settings reference

Environment variables of the runtime. The text and the tables come from the
README of the upstream project
([antoxa2584x/nfsu2-sw](https://github.com/antoxa2584x/nfsu2-sw), Anton
Artemov, at 6e19726; the tree includes upstream up to 0.5.13) and were
extended for this fork. Keys that start with
`NFSU2_` apply to NFSU1 as well; the key names did not change. Most keys are for
debugging. The defaults are the normal configuration.

For a short list of the keys most players need, see the README.

## Environment variables

On Linux these are ordinary environment variables. On the Switch they go in
`sdmc:/switch/nfsu2x/nfsu2x_env.txt`, one `KEY=VALUE` per line (`#` starts a
comment). On iOS they go in `Documents/<game>_env.txt` (`nfsu2_env.txt` or
`nfsu1_env.txt`); the settings panel in the game writes the same file. Anything left out runs at its default, which is the fastest normal
configuration. Most of the list is for debugging, so the sections below are folded.

```ini
# sdmc:/switch/nfsu2x/nfsu2x_env.txt
RECOMP_GL_SCALE=1.5
RECOMP_WIDESCREEN=0
```

<details>
<summary><b>Build and code generation</b></summary>

| Variable | Meaning |
|---|---|
| `XBOXRECOMP_DIR` | Toolkit to build or regenerate with (default: the vendored `xboxrecomp/`). |
| `XBE` (or `NFSU2_XBE`) | `default.xbe` to lift (`tools/lift.sh`, required). |
| `GEN` (or `NFSU2_GEN_DIR`) | Directory for the lifted C (`tools/lift.sh` and `switch/build.sh`: required; CMake default `src/recomp/gen`, which is git ignored). |
| `LIFT_ONLY=1` | `lift.sh`: skip disasm / function id / ABI analysis and only re-lift (enough after translator or `recomp_manual.c` changes; seed changes need the full run). |
| `RECOMP_LEAF_LOCALS=0` | Translator: keep MMX leaf-function registers in globals instead of C locals. |
| `RECOMP_REG_LOCALS=0` | Translator: keep eax..edi/esp in globals instead of C locals. |
| `RECOMP_X87_LOCALS=0` | Translator: keep the x87 stack top in its global instead of a local. |
| `NFSU2_GAME_SRC` | `switch/build.sh`: extracted disc to stage (required). |
| `SD_ROOT` | `switch/build.sh`: staging SD-card root (default `<repo>/switch_sd`). |
| `BUILD_DIR` | `switch/build.sh`: build directory (default `<repo>/build-switch`, `build-switch-vk` with `VULKAN=1`). |
| `JOBS` | `switch/build.sh`: parallel compile jobs (6 fits `-O2` in RAM). |
| `VULKAN=1` | `switch/build.sh`: build the Vulkan renderer (`nfsu2x-vulkan.nro`). |
| `NVK_SDK`, `GLSLANG_DIR` | `switch/build.sh` with `VULKAN=1` (both required): mesa-switch NVK install and Switch glslang. |
| `FFMPEG_DIR` | `switch/build.sh`: LGPL VP6-only FFmpeg for the movies (`tools/build_ffmpeg_vp6.sh`; default `<repo>/build-ffmpeg-vp6-switch`). |

</details>

<details>
<summary><b>Game and host</b></summary>

| Variable | Meaning |
|---|---|
| `NFSU2_GAME_DIR` | Extracted disc or a folder with one `.iso` (Linux; default `./game`; iOS: `Documents`). The Switch always uses `sdmc:/switch/nfsu2x/game/`. |
| `NFSU2_ISO=<path>` | Use this disc image. `NFSU2_ISO=0` turns image reading off. |
| `NFSU2_GL=0` | Use the executor's CPU renderer instead of the GPU renderer. |
| `NFSU2_APU=0` | With `RECOMP_AC97_READY=plain`: no emulated APU (no sound). |
| `NFSU2_SIM_STEPS` | Longest game-time step per frame, in 1/60 s (default 6 = 100 ms; 3 = the original 50 ms cap, which slows races below 20 fps). |
| `NFSU2_NATIVE_VP6` | Movie decoder: 1 = FFmpeg (default when built with it), 0 = the lifted decoder, 2 = both and compare. |
| `NFSU2_MOVIE_FLASH=1` | Keep the opening trailer's white flash frames (shown black by default). |
| `NFSU2_SWITCH_TEXT` | Switch wording in the menus (Start → +, no Xbox Live/hard-disk names): 1 on (Switch default), 0 off. |
| `NFSU2_EXIT_TRACE=1` | Print the guest state at exit. |
| `NFSU2_OPTIONS=0` | NFSU2: no in-game option rows (Car Reflections, Resolution Scale, Anisotropic, Vibration), no `nfsu2x_options.txt`, no audio volume restore, no option labels. Default 1; 0 on iOS (set 1 in `nfsu2_env.txt` to turn them on). |
| `RECOMP_OPTION_SCALE=1\|0` | NFSU2, Vulkan: the Resolution Scale row decides the render scale (1) or `RECOMP_GL_SCALE` does and the row is hidden (0). Default 1; 0 on iOS. |
| `RECOMP_WIDESCREEN=0` | Tell the game the TV is 4:3 (default 16:9). |
| `RECOMP_CMDLINE` | Command line handed to the title (e.g. `+map intro`). |
| `HOME`, `XDG_DATA_HOME` | Linux: fallback save directory (`$XDG_DATA_HOME/xboxrecomp`, else `~/.local/share/xboxrecomp`) when none is configured. NFSU2's own saves go to `<game>/UDATA`. |

</details>

<details>
<summary><b>Switch (Horizon)</b></summary>

| Variable | Meaning |
|---|---|
| `NFSU2_NO_LOG=1` / `NFSU2_LOG=0` | No log file, no `[perf]` reports, no profiler. |
| `NFSU2_LOG_SYNC=1` | Write every log line to the card at once (slow; for hangs). |
| `NFSU2_LOADER=0` | No loading screen (logo + bar) before the first frame. |
| `RECOMP_NX_PROFILE` | Sampling profiler into `prof.bin`: 1 = busy threads, 2 = every thread above 2%. |
| `RECOMP_NX_SHM=1` | Guest RAM from shared memory instead of code memory. |
| `RECOMP_NX_AUDIO_PRIO=0` | Leave the APU and SDL audio threads at priority 59 (default: above the game threads). |
| `RECOMP_NX_GUEST_RT=1` | Run the time-critical guest thread (EA mixer) at a real-time host priority. |
| `RECOMP_NX_JOYCON=single` | One sideways Joy-Con per player. |
| `RECOMP_NX_JOYCON_ROTATE=0` | Don't rotate the sideways Joy-Con stick. |
| `RECOMP_GUEST_ONE_CORE` | 1 = pin guest threads to one core, 2 = guest threads only (interrupts float). |
| `NFSU2_CPU_MHZ`, `NFSU2_GPU_MHZ`, `NFSU2_MEM_MHZ` | Clock requests in MHz (opt-in). Ignored while sys-clk or Horizon OC runs; a rate already at or above the request is left alone. |
| `NFSU2_CLOCK_FORCE=1` | Apply the `NFSU2_*_MHZ` lines even when sys-clk or Horizon OC is running. |
| `NFSU2_SALTYNX=0` | Do not report the frame rate to SaltyNX (Status Monitor FPS). |

</details>

<details>
<summary><b>Scheduling and kernel</b></summary>

| Variable | Meaning |
|---|---|
| `RECOMP_GIL=0` | No guest lock (guest threads run in parallel; races the title's streaming). |
| `RECOMP_GIL_EAGER=1` | Hand the guest lock over by guest priority (main thread and time-critical threads pre-empt). |
| `RECOMP_KERNEL_FAST=0` | Release the guest lock in every kernel call, even the cheap time queries and IRQL changes. |
| `RECOMP_FRAME_LAG=1` | Wait on the previous frame's fence instead of the current one (game and GPU work overlap). |
| `RECOMP_VBLANK` | Vblank interrupt for D3D (default 1). |
| `RECOMP_WORKERS=inline` | Run the title's worker routines inline instead of on threads. |
| `RECOMP_ASYNC_IO=1` | Asynchronous NtReadFile. |
| `RECOMP_CS_MODE=single` | Every guest critical section behind one recursive lock. |
| `RECOMP_NATIVE=0` | Use the lifted culling functions instead of the native C versions. |
| `RECOMP_NATIVE_CHECK=1` | Run both and report any difference. |
| `RECOMP_QUIET` | 1 = no periodic kernel/GPU summaries (Switch default), 0 = show them. |
| `RECOMP_NO_LOG=1` | No `xbox_kernel.log`. |
| `XBOX_LOG_LEVEL` | Kernel log level (0 errors … trace). |
| `RECOMP_KERNEL_LOG_BUDGET` | Kernel calls logged before the log goes quiet. |

</details>

<details>
<summary><b>Graphics (GL and Vulkan renderers)</b></summary>

| Variable | Meaning |
|---|---|
| `RECOMP_PB_EXEC` | Execute the NV2A pushbuffer (default 1; the title draws through it). |
| `RECOMP_GL_SCALE` | Render resolution multiple, 0.5..4 (fractions allowed). |
| `RECOMP_GL_THREAD=1` | GL renderer: GL calls on their own thread. |
| `RECOMP_GL_DIRECT=0` | Convert every vertex to float4 instead of uploading it as stored. |
| `RECOMP_GL_DXT=0` | Decode DXT textures on the CPU instead of uploading them compressed. |
| `RECOMP_GL_SHARED_Z=0` | One depth buffer per colour surface (old behaviour; lights show through walls). |
| `RECOMP_GL_TEX_MB` | Texture cache budget in MB (least recently used go first). |
| `RECOMP_PROG_CACHE` | Shader/pipeline cache file (`progcache.bin`), `=0` off. |
| `RECOMP_VP=0` | No vertex programs (their batches are skipped). |
| `RECOMP_GL_DUMP=<prefix>[,every]` | Write presented frames as BMP (every N frames, default 60). |
| `RECOMP_GL_WATCH=<hex va>` | Log draws into or sampling that address, with pixel read-backs. |
| `RECOMP_GL_TRACE=1` | Shader sources and compile/link errors. |
| `RECOMP_GL_FINISH=1` | Wait for the GPU after every operation (finds the call that hangs it). |
| `RECOMP_FPS_LOG=1` | Presented frames per 10 s. |
| `RECOMP_VK_CUBE=0` | Vulkan: no cube maps (car reflections off). The in-game Car Reflections row does the same at run time. |
| `RECOMP_VK_SNAP=1\|0` | Vulkan vertex snap: 1 puts each position where a title edge there would land, per axis; 0 shifts both axes by one constant (the rule before 0.5.13). They differ at render scales of 2 and up. Default 1; 0 on iOS and in NFSU1. |
| `RECOMP_PB_RUN=1\|0` | Take vertex-constant and index runs of the pushbuffer in one loop and skip the per-word survey. Default 1; 0 on iOS and in NFSU1. |
| `RECOMP_VK_DUMP_ALL=1` | With `RECOMP_GL_DUMP`: dump every surface too, as `<prefix><frame>_<va>.bmp`. |
| `RECOMP_DRAW_MERGE_STATS=1` | With `RECOMP_DRAW_STATS=1`: also survey draws that match the previous one (hashes every index; slow). |
| `RECOMP_VK_HEADLESS=1` | Vulkan on Linux: no window (also implied by `SDL_VIDEODRIVER=offscreen`). |
| `RECOMP_VK_VALIDATION=1` | Vulkan on Linux: Khronos validation layer. |
| `RECOMP_VK_TRACE=<n>` | Vulkan: name every step of the first n draws/clears/flips. |
| `RECOMP_TEX_STATS=1` | List each texture format and size decoded. |
| `RECOMP_TEX_STATE=1`, `RECOMP_TEX_DUMP=<prefix>`, `RECOMP_TEX_DUMP_EVERY=<n>` | Texture register state; dump textures to BMP. |
| `RECOMP_FB_DUMP=<prefix>`, `RECOMP_FB_WINDOW=1`, `RECOMP_FB_VA=<va>`, `RECOMP_FB_WINDOW_DUMP_EVERY=<n>` | Framebuffer window / dumps (CPU presenter). |
| `RECOMP_FFP_TRACE`, `RECOMP_SKIP_TRACE`, `RECOMP_TRACE_FLIP=<n>`, `RECOMP_PB_EXEC_VERBOSE`, `RECOMP_PB_UNHANDLED_ALL`, `RECOMP_PB_SCAN`, `RECOMP_NV2A_TRACE`, `RECOMP_RASTER_TEST`, `RECOMP_FIND_NAN`, `RECOMP_FIND_QUAD` | Pushbuffer / NV2A debugging traces. |
| `RECOMP_FMV_HOST`, `RECOMP_FMV_DUMP=<prefix>` | Host-side movie player (off) and movie frame dumps. |


Upstream 0.5.13 keys that this tree does not build yet (the renderer parts are
not ported; see the CHANGELOG): `RECOMP_VK_FXAA`, `RECOMP_VK_SQUARE`,
`RECOMP_GL_SCALE_X`, `RECOMP_VK_NAT`, `RECOMP_VK_SYNC`,
`RECOMP_VK_ASYNC_PRESENT`, `RECOMP_VK_STATE_CACHE`. Setting them does nothing.

</details>

<details>
<summary><b>Audio</b></summary>

| Variable | Meaning |
|---|---|
| `RECOMP_AUDIO=0` | No host audio device (the APU then paces by wall clock). |
| `RECOMP_AUDIO_VOLUME` | Master volume 0..100 (default 50; output is soft-limited to −6 dBFS). |
| `RECOMP_AUDIO_BLOCKS` | Host queue depth in 256-sample blocks (default 8, Switch 12). |
| `RECOMP_AUDIO_DUMP=<path>,<start s>,<secs>` | Record the exact PCM sent to the device (48 kHz s16 stereo), written once full. |
| `RECOMP_APU_VOICE_DUMP=<voice hex>,<path>,<start s>,<secs>` | Record one APU voice before/after its filter (float32) and log its registers once a second (v0F4 = menu music). |
| `RECOMP_AC97_READY` | AC97 codec presence for DirectSound (default `plain`). |
| `RECOMP_APU_MIXDOWN_ALL=0` | Mix only bins 0/1 to stereo instead of every bin. |
| `RECOMP_APU_DSP_ACK=<addr,...>`, `RECOMP_DSP_ACK=<addr,...>` | Acknowledge DSP command doorbells at these guest addresses. |
| `RECOMP_APU_TRACE=1` | Front-end methods and a per-second voice summary (disturbs the audio itself). |
| `RECOMP_APU_RING_STATS=1` | Stale ring-voice reads every 10 s (Linux; always on in the Switch `[perf]` report). |

</details>

<details>
<summary><b>Input</b></summary>

| Variable | Meaning |
|---|---|
| `RECOMP_USB` | Emulated OHCI USB with the pads (default 1). |
| `RECOMP_USB_PADS=1` | Only one pad (default two). |
| `RECOMP_USB_PORT`, `RECOMP_USB_PORT2` | Root port of pad 1 / pad 2 (0-based). |
| `RECOMP_USB_HC`, `RECOMP_USB_NDP` | Host controller for the pads and its number of ports. |
| `RECOMP_PAD_LAYOUT=position` | Map buttons by position (Xbox layout) instead of by label. |
| `RECOMP_PAD_SCRIPT`, `RECOMP_PAD2_SCRIPT` | Timed presses, e.g. `4000:start:300,9000:a:200` (ms from the first pad read). |
| `RECOMP_PAD_PRESS=<mask>` | Press these buttons periodically. |
| `RECOMP_KEYBOARD=1` | Keyboard as a pad (Linux). |
| `RECOMP_RUMBLE=0` | No rumble. |
| `RECOMP_RUMBLE_TRACE=1`, `RECOMP_INPUT_DIAG=1`, `RECOMP_KEY_TRACE=1`, `RECOMP_USB_TRACE=1` | Input debugging traces. |

</details>

<details>
<summary><b>Debugging</b></summary>

| Variable | Meaning |
|---|---|
| `RECOMP_WATCHDOG_SECS=<s>` | Snapshot the main guest thread after s seconds without progress (and exit). |
| `RECOMP_WATCHDOG_KEEP=1` | Keep running after the watchdog snapshot. |
| `RECOMP_WATCH=<addr>`, `RECOMP_WATCH_RAW=1` | Name the guest code that changes a guest dword. |
| `RECOMP_KERNEL_WATCH=<addr>`, `RECOMP_KERNEL_WATCH_ALL=1` | Sample a guest dword around every kernel call. |
| `RECOMP_PEEK=<addr,...>`, `RECOMP_PEEK_CHAIN=<addr,off,...>` | Print guest dwords / follow a pointer chain periodically. |
| `RECOMP_POKE=<addr:val,...>` | Write guest dwords at boot. |
| `RECOMP_TRAP_NULL=1` | Fault on guest null-page access. |
| `RECOMP_UNIMPL_TRAP=1` | Abort at the first unimplemented instruction. |
| `RECOMP_IRQL_TRACE=1` | Log the first IRQL transitions. |
| `RECOMP_CS_WATCH=<va>`, `RECOMP_CS_TRACE_CRT=1` | Critical-section tracing. |
| `RECOMP_TRACE_ARGS=<n>`, `RECOMP_TRACE_DEREF=1`, `RECOMP_TRACE_BUDGET`, `RECOMP_TRACE_PROFILE=1` | Function-entry traces (functions chosen at regen) and a call profile. |
| `RECOMP_FORCE_RETURN` | Read but currently has no effect. |

</details>
