#!/usr/bin/env bash
# Build and run the game time step smoother test (dt_smooth_step in
# games/nfsu2/recomp_manual.c) on Linux. The test compiles the real code
# between the DT_SMOOTH_BEGIN and DT_SMOOTH_END markers.
# Usage: tools/tests/run_dt_smooth_test.sh [-v] [build-dir] [source.c]
#   -v          print every frame
#   source.c    take the block from this file (default: recomp_manual.c)
set -eu

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../.." && pwd)"
g="$root/games/nfsu2"
verbose=""
if [ "${1:-}" = "-v" ]; then verbose="-v"; shift; fi
out="${1:-${DTTEST_DIR:-/tmp/nfsu2_dttest}}"
src="${2:-$g/recomp_manual.c}"
[ -f "$src" ] || { echo "no $src" >&2; exit 2; }
mkdir -p "$out"

sed -n '/DT_SMOOTH_BEGIN/,/DT_SMOOTH_END/p' "$src" > "$out/dt_block.h"
[ -s "$out/dt_block.h" ] || { echo "no DT_SMOOTH markers in $src" >&2; exit 2; }

gcc -std=gnu11 -O1 -g -Wall -Wextra -DDT_BLOCK="\"$out/dt_block.h\"" \
    "$g/tests/dt_smooth_test.c" -o "$out/dt_smooth_test" -lm
"$out/dt_smooth_test" $verbose
