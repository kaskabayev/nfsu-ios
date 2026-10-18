#!/usr/bin/env bash
# Old name of tools/lift.sh for NFSU2. Same environment, same output.
exec "$(dirname "${BASH_SOURCE[0]}")/lift.sh" nfsu2 "$@"
