#!/usr/bin/env bash
# CI helper: get the game's XBE, check it, lift it to C, write a manifest.
# The build-ipa workflow calls this in both layouts, so the logic lives once:
#
#   private repository: Linux "lift" job, then the macOS "ipa" job
#   public repository:  one macOS job (the lifted C never becomes an artifact)
#
# Environment:
#   GAME              nfsu2 or nfsu1 (required)
#   IS_PRIVATE        "true" when the repository is private
#   XBE_URL_NFSU2     secret: direct download URL of the NFSU2 default.xbe
#   XBE_URL_NFSU1     secret: the same for NFSU1
#   XBE_TOKEN         secret, optional: sent as "Authorization: Bearer" with
#                     "Accept: application/octet-stream". For a GitHub release
#                     asset API URL of a private repository, for example
#                     https://api.github.com/repos/<owner>/<repo>/releases/assets/<id>
#   XBE_RELEASE       private repository only, used when the URL secret of the
#                     game is empty: tag of the release (in this repository)
#                     that holds <game>.xbe
#   GH_TOKEN          needed for the release download (github.token)
#   GITHUB_REPOSITORY owner/name, set by GitHub Actions
#   GEN               output folder of the lifted C (default: gen)
#   MANIFEST          manifest file (default: gen.manifest)
#   RUNNER_TEMP       scratch folder (default: /tmp)
#
# The URL and the token are never printed. In a public repository the job log
# is public, so the output of the lifter goes to a file in RUNNER_TEMP and only
# the stage lines are printed.
#
# Works with bash 3.2 (macOS) and GNU bash.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAME="${GAME:-}"
IS_PRIVATE="${IS_PRIVATE:-}"
GEN="${GEN:-gen}"
MANIFEST="${MANIFEST:-gen.manifest}"
TMPD="${RUNNER_TEMP:-/tmp}"
XBE_RELEASE="${XBE_RELEASE:-}"

err() { echo "::error::$*"; exit 1; }

case "$GAME" in
    nfsu2|nfsu1) ;;
    *) err "Unknown game: '$GAME'. Use nfsu2 or nfsu1." ;;
esac
GAME_UP="$(printf '%s' "$GAME" | tr '[:lower:]' '[:upper:]')"
SECRET_NAME="XBE_URL_$GAME_UP"
URL="${!SECRET_NAME:-}"

# Where the XBE comes from.
if [ -n "$URL" ]; then
    SOURCE=url
elif [ "$IS_PRIVATE" = "true" ]; then
    SOURCE=release
    case "$XBE_RELEASE" in
        ''|-*|*[!A-Za-z0-9._/-]*)
            err "xbe_release must be a release tag: letters, digits, dot, underscore, slash and hyphen only, no leading hyphen." ;;
    esac
else
    err "In a public repository the game file must come from the secret $SECRET_NAME. A release in a public repo publishes the game's executable: do not use one. Add the secret in Settings > Secrets and variables > Actions."
fi

if [ "$SOURCE" = url ]; then
    case "$URL" in
        https://*) ;;
        *) err "The secret $SECRET_NAME must be an https:// URL." ;;
    esac
    case "$URL" in
        *[\"\\]*|*[[:space:]]*|*[[:cntrl:]]*)
            err "The secret $SECRET_NAME holds a character that is not allowed in a URL (quote, backslash, space or control character)." ;;
    esac
fi

sha256_cmd() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$@"
    else
        shasum -a 256 "$@"
    fi
}

mkdir -p "$TMPD/xbe"
XBE="$TMPD/xbe/default.xbe"
rm -f "$XBE"

# 1. Download
if [ "$SOURCE" = url ]; then
    echo "XBE source: secret $SECRET_NAME"
    # The URL and the token go to curl through a config on stdin, not through
    # the command line. curl's own messages are dropped: they can hold the
    # host name.
    rc=0
    {
        printf 'url = "%s"\n' "$URL"
        if [ -n "${XBE_TOKEN:-}" ]; then
            printf 'header = "Authorization: Bearer %s"\n' "$XBE_TOKEN"
            printf 'header = "Accept: application/octet-stream"\n'
        fi
    } | curl -fsL --proto '=https' --proto-redir '=https' --retry 3 -o "$XBE" -K - 2>/dev/null || rc=$?
    if [ "$rc" -ne 0 ]; then
        rm -f "$XBE"
        err "Cannot download the game file from the secret $SECRET_NAME (curl exit code $rc). Check the URL. For a GitHub release asset of a private repository, use the asset API URL and set the secret XBE_TOKEN."
    fi
else
    echo "XBE source: release '$XBE_RELEASE' of this repository"
    if ! gh release download "$XBE_RELEASE" -R "$GITHUB_REPOSITORY" \
           -p "$GAME.xbe" -O "$XBE" --clobber; then
        err "Cannot download $GAME.xbe from release '$XBE_RELEASE' of this repository. Create the release and attach the file, or set the secret $SECRET_NAME."
    fi
fi
unset XBE_TOKEN XBE_URL_NFSU2 XBE_URL_NFSU1 URL GH_TOKEN
test -s "$XBE" || err "The downloaded game file is empty."

# 2. Check
P="$HERE/games/$GAME/game_profile.h"
WANT="$(grep -A1 'define NFSU_XBE_SHA256' "$P" | grep -oE '"[0-9a-f]{64}"' | tr -d '"' || true)"
TID="$(grep -oE 'NFSU_XBE_TITLE_ID +0x[0-9A-Fa-f]+' "$P" | awk '{print $2}' || true)"
if [ "${#WANT}" -ne 64 ] || [ -z "$TID" ]; then
    err "Cannot read NFSU_XBE_SHA256 or NFSU_XBE_TITLE_ID from games/$GAME/game_profile.h."
fi
HAVE="$(sha256_cmd "$XBE" | cut -d' ' -f1)"
echo "expected sha256: $WANT"
echo "found sha256:    $HAVE"
if [ "$HAVE" != "$WANT" ]; then
    err "The game file is not the expected one. This build needs default.xbe of the NTSC-U disc of $GAME (title ID $TID, SHA-256 $WANT). The file you provided has SHA-256 $HAVE."
fi

# 3. Lift
T0=$(date +%s)
if [ "$IS_PRIVATE" = "true" ]; then
    XBE="$XBE" GEN="$GEN" "$HERE/tools/lift.sh" "$GAME"
else
    LOG="$TMPD/lift-$GAME.txt"
    echo "Lifting (the log of a public repository is public: full output goes to a private file)."
    rc=0
    XBE="$XBE" GEN="$GEN" "$HERE/tools/lift.sh" "$GAME" >"$LOG" 2>&1 || rc=$?
    grep -E '^(==|lift .* done in)' "$LOG" || true
    if [ "$rc" -ne 0 ]; then
        echo "::group::last lines of the lifter output"
        tail -n 20 "$LOG"
        echo "::endgroup::"
        err "The lift failed (exit code $rc)."
    fi
fi
SECS=$(( $(date +%s) - T0 ))
echo "Lift time: $SECS s"
if [ -n "${GITHUB_ENV:-}" ]; then echo "LIFT_SECS=$SECS" >> "$GITHUB_ENV"; fi
test -f "$GEN/recomp_funcs.h" || err "The lift wrote no recomp_funcs.h."
rm -f "$XBE"

# 4. Manifest (hashes only)
if command -v sha256sum >/dev/null 2>&1; then SHA=(sha256sum); else SHA=(shasum -a 256); fi
(cd "$GEN" && find . -type f ! -name xbe_analysis.json | sed 's|^\./||' \
    | LC_ALL=C sort | tr '\n' '\0' | xargs -0 "${SHA[@]}") > "$MANIFEST"
LINES="$(wc -l < "$MANIFEST" | tr -d ' ')"
SUM="$(sha256_cmd "$MANIFEST" | cut -d' ' -f1)"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    {
        echo "### Lift: $GAME"
        echo
        echo "- Lift time: $SECS s"
        echo "- Files in the manifest: $LINES"
        echo "- SHA-256 of the manifest: \`$SUM\`"
    } >> "$GITHUB_STEP_SUMMARY"
fi
echo "manifest lines: $LINES"
echo "manifest sha256: $SUM"
