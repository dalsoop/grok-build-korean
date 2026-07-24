#!/usr/bin/env bash
# Install side-by-side grok-ko next to official grok (does not replace it).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARTIFACT="${ROOT}/target/release/grok-ko"
PREFIX="${PREFIX:-$HOME/.local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
BREW_BINDIR="${BREW_BINDIR:-/opt/homebrew/bin}"

if [[ ! -x "$ARTIFACT" ]]; then
  echo "missing $ARTIFACT — run: make build" >&2
  exit 1
fi

mkdir -p "$BINDIR"
install -m 755 "$ARTIFACT" "$BINDIR/grok-ko"
echo "installed: $BINDIR/grok-ko"

if [[ -w "$BREW_BINDIR" ]]; then
  install -m 755 "$ARTIFACT" "$BREW_BINDIR/grok-ko"
  echo "installed: $BREW_BINDIR/grok-ko"
fi

command -v grok-ko
grok-ko --version
echo "official grok (unchanged): $(command -v grok 2>/dev/null || echo none)"
