#!/usr/bin/env bash
# install.sh — put foodnoms on PATH.
#
# One Python file with no third-party dependencies, so installing is a copy.
# PREFIX defaults to ~/.local; set it to install elsewhere.
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BIN="$PREFIX/bin"
SRC="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$BIN"
install -m 0755 "$SRC/foodnoms" "$BIN/foodnoms"
echo "installed $BIN/foodnoms"

case ":$PATH:" in
    *":$BIN:"*) ;;
    *)
        echo
        echo "PATH action required — add this to your shell profile, then open a new terminal:"
        echo "  export PATH=\"$BIN:\$PATH\""
        ;;
esac

echo
echo "Next: foodnoms doctor"
