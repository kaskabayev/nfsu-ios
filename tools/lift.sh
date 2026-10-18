#!/usr/bin/env bash
# Lift one game from its XBE to C: disasm -> func_id -> abi -> recomp.
#
#   tools/lift.sh nfsu2|nfsu1
#
# Environment:
#   XBE             default.xbe of the game (required)
#   GEN             output directory (required)
#   XBOXRECOMP_DIR  toolkit (default: the vendored xboxrecomp/)
#   ANALYSIS_JSON   XBE analysis JSON. Default: games/<game>/config/
#                   default_analysis.json when it exists (NFSU1), else the
#                   script writes one from the XBE with tools.xbe_parser
#                   into $GEN/xbe_analysis.json.
#   LIFT_ONLY=1     skip disasm/func_id/abi (enough after editing
#                   games/<game>/recomp_manual.c; seeds need the full run)
#
# NFSU2_XBE and NFSU2_GEN_DIR still work as names for XBE and GEN.
#
# Per-game settings are in games/<game>/config/lift.conf (the game name and
# the extra disasm options). The toolkit writes its intermediate files to
# xboxrecomp/tools/*/output/ (git ignored). They belong to the last game
# lifted. Lift games one after the other, not at the same time.
#
# Seeds (games/<game>/config/seed_functions.json) are entry points the static
# pass cannot see -- thread start routines and indirect-call targets found at
# runtime. Grow them with:
#   python3 -m tools.seed_from_log run.log default.xbe \
#     --functions tools/disasm/output/functions.json \
#     --seeds <this repo>/games/<game>/config/seed_functions.json
# and review every addition: a seed inside a function splits it.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAME="${1:-}"
CONF="$HERE/games/$GAME/config/lift.conf"
if [ -z "$GAME" ] || [ ! -f "$CONF" ]; then
    echo "usage: tools/lift.sh <game>   (games: $(cd "$HERE/games" && echo *))" >&2
    exit 2
fi
XBE="${XBE:-${NFSU2_XBE:-}}"
GEN="${GEN:-${NFSU2_GEN_DIR:-}}"
if [ -z "$XBE" ] || [ -z "$GEN" ]; then
    echo "set XBE (default.xbe) and GEN (output directory)" >&2
    exit 2
fi
TK="${XBOXRECOMP_DIR:-$HERE/xboxrecomp}"
# The toolkit runs from its own directory: make every path absolute first.
XBE="$(cd "$(dirname "$XBE")" && pwd)/$(basename "$XBE")"   # not readlink: the analysis JSON is looked up beside this path
mkdir -p "$GEN"
GEN="$(readlink -f "$GEN")"
[ -n "${ANALYSIS_JSON:-}" ] && ANALYSIS_JSON="$(readlink -f "$ANALYSIS_JSON")"

GAME_NAME=""
DISASM_FLAGS=()
# shellcheck source=/dev/null
. "$CONF"

ANALYSIS="${ANALYSIS_JSON:-}"
if [ -z "$ANALYSIS" ] && [ -f "$HERE/games/$GAME/config/default_analysis.json" ]; then
    ANALYSIS="$HERE/games/$GAME/config/default_analysis.json"
fi
# No analysis JSON given or shipped: the disassembler needs one (sections,
# imports), so write it from the XBE. It is metadata of your own disc: keep it
# in GEN, do not commit it.
if [ -z "$ANALYSIS" ] && [ "${LIFT_ONLY:-0}" != "1" ]; then
    ANALYSIS="$GEN/xbe_analysis.json"
    echo "== xbe_parser (writes $ANALYSIS)"
    (cd "$TK" && python3 -m tools.xbe_parser "$XBE" --quiet --json "$ANALYSIS")
fi
[ -n "$ANALYSIS" ] && DISASM_FLAGS+=(--analysis-json "$ANALYSIS")

cd "$TK"
T0=$SECONDS
if [ "${LIFT_ONLY:-0}" != "1" ]; then
    echo "== disasm"
    python3 -m tools.disasm "$XBE" --seed-functions "$HERE/games/$GAME/config/seed_functions.json" \
        ${DISASM_FLAGS[@]+"${DISASM_FLAGS[@]}"}
    echo "== func_id"
    python3 -m tools.func_id "$XBE"
    echo "== abi"
    python3 -m tools.abi_analysis "$XBE"
fi
mkdir -p "$GEN"
# recomp_types.h is written only when absent, so a stale copy would hide
# register-model changes in the toolkit. Nothing here edits it by hand.
rm -f "$GEN/recomp_types.h"
echo "== recomp"
python3 -m tools.recomp "$XBE" --game-name "$GAME_NAME" --all --split 250 \
    --gen-dir "$GEN" --exclude-manual "$HERE/games/$GAME/recomp_manual.c" \
    --mmio-sections DSOUND,XPP
echo "lift $GAME done in $((SECONDS - T0)) s"
