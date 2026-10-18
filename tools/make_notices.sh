#!/usr/bin/env bash
# Join licenses/README.md and every licence text in licenses/ into one file.
#
#   tools/make_notices.sh OUTPUT [COMMIT [SOURCE_URL]]
#
# OUTPUT      path of the file to write (THIRD-PARTY-NOTICES.txt).
# COMMIT      optional commit of this repository that the app is built from. It
#             is named in the LGPL note, so a user knows which source to rebuild.
# SOURCE_URL  optional web address of the repository that holds that commit
#             (default: https://github.com/kaskabayev/nfsu-ios).
#
# Works with bash 3.2 (macOS) and GNU bash.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIC="$HERE/licenses"
OUT="${1:-}"
COMMIT="${2:-}"
SOURCE_URL="${3:-https://github.com/kaskabayev/nfsu-ios}"
if [ -z "$OUT" ] || [ ! -f "$LIC/README.md" ]; then
    echo "usage: tools/make_notices.sh OUTPUT [COMMIT [SOURCE_URL]]" >&2
    exit 2
fi

RULE="================================================================================"
{
    echo "THIRD-PARTY NOTICES"
    echo "$RULE"
    echo
    echo "This app contains the components listed below. Each one is under its own"
    echo "licence. The licence texts follow the list."
    echo
    cat "$LIC/README.md"
    echo
    echo "$RULE"
    echo "LGPL-2.1-or-later: how to rebuild and relink"
    echo "$RULE"
    echo
    echo "Some files in this app come from xemu and are under the GNU Lesser General"
    echo "Public License, version 2.1 or later. They are linked statically."
    echo "The full source code and the build scripts of this app are available at:"
    echo
    echo "  $SOURCE_URL"
    echo
    echo "You can change those files, rebuild the app and relink it:"
    echo
    echo "  1. Get the source from that address."
    if [ -n "$COMMIT" ]; then
        echo "     This app was built from commit $COMMIT."
    fi
    echo "  2. Lift the game from your own default.xbe with tools/lift.sh."
    echo "  3. Build the app as the README describes (CMake, or the build-ipa"
    echo "     workflow on GitHub Actions)."
    echo
    echo "The repository does not contain the game's code. You need your own copy"
    echo "of the game for step 2."
    echo
    # Every text file except the index, in a fixed order.
    # (LC_ALL=C sort: the same output on every machine.)
    find "$LIC" -maxdepth 1 -type f ! -name README.md | LC_ALL=C sort | while IFS= read -r f; do
        echo "$RULE"
        basename "$f"
        echo "$RULE"
        echo
        cat "$f"
        echo
    done
} > "$OUT"
echo "wrote $OUT ($(wc -c < "$OUT" | tr -d ' ') bytes)"
