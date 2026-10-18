#!/usr/bin/env bash
# Build and run the race-state reader test (games/<game>/state.c) on Linux.
# Usage: [NFSU_GAME=nfsu2|nfsu1] tools/tests/run_state_test.sh [build-dir]
set -eu

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../.." && pwd)"
game="${NFSU_GAME:-nfsu2}"
g="$root/games/$game"
[ -f "$g/state.c" ] || { echo "no games/$game/state.c" >&2; exit 2; }
out="${1:-${STATETEST_DIR:-/tmp/${game}_statetest}}"
mkdir -p "$out"

gcc -std=gnu11 -O1 -g -Wall -Wextra -I"$g" \
    "$g/tests/state_test.c" "$g/state.c" -o "$out/state_test"
"$out/state_test"
