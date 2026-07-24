#!/usr/bin/env bash
# Headless smoke: Korean reply + Korean session title.
set -euo pipefail

export PATH="/opt/homebrew/bin:${HOME}/.local/bin:${PATH}"

if ! command -v grok-ko >/dev/null; then
  echo "grok-ko not on PATH" >&2
  exit 1
fi

echo "=== version ==="
grok-ko --version
VER_LINE="$(grok-ko --version 2>&1)"
if echo "$VER_LINE" | grep -q '0ce7dd5'; then
  echo "REFUSING: PATH grok-ko is still stale hash 0ce7dd5" >&2
  exit 3
fi

TMP="$(mktemp -d "${TMPDIR:-/tmp}/grok-ko-smoke.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"
REAL="$(pwd -P)"
echo "cwd=$REAL"

echo "=== headless single-turn ==="
OUT="$TMP/out.txt"
ERR="$TMP/err.txt"
set +e
grok-ko --always-approve -p "한 줄로만 답해. 지금 CLI 이름은? 한국어로." \
  >"$OUT" 2>"$ERR"
EC=$?
set -e
echo "exit=$EC"
echo "--- stdout ---"
cat "$OUT"
if [[ ! -s "$OUT" ]]; then
  echo "empty stdout" >&2
  echo "--- stderr ---"
  tail -50 "$ERR" || true
  exit 1
fi
if [[ "$EC" -ne 0 ]]; then
  echo "--- stderr ---"
  tail -50 "$ERR" || true
  exit "$EC"
fi

# Find newest summary for this cwd under ~/.grok/sessions
TITLE=""
SUM_PATH=""
while IFS= read -r sum; do
  [[ -z "$sum" ]] && continue
  cwd="$(python3 -c "import json;print(json.load(open(r'''$sum''')).get('info',{}).get('cwd',''))" 2>/dev/null || true)"
  if [[ "$cwd" == "$REAL" || "$cwd" == "$TMP" || "$cwd" == "/private${TMP}" ]]; then
    TITLE="$(python3 -c "import json;d=json.load(open(r'''$sum'''));print(d.get('generated_title') or d.get('session_summary') or '')")"
    SUM_PATH="$sum"
    break
  fi
done < <(find "$HOME/.grok/sessions" -name summary.json -mmin -15 2>/dev/null | xargs ls -t 2>/dev/null | head -40)

echo "=== generated_title ==="
echo "summary_path=${SUM_PATH:-none}"
echo "title=${TITLE:-"(not found)"}"

if [[ -n "$TITLE" ]]; then
  if printf '%s' "$TITLE" | python3 -c "import sys,re; t=sys.stdin.read(); sys.exit(0 if re.search(r'[가-힣]', t) else 2)"; then
    echo "title_korean: YES"
  else
    echo "title_korean: NO"
    exit 2
  fi
else
  echo "title_korean: SKIP (no summary yet)"
fi

if ! python3 -c "import re,sys; t=open(r'''$OUT''').read(); sys.exit(0 if re.search(r'[가-힣]', t) else 2)"; then
  echo "reply_korean: NO" >&2
  exit 2
fi
echo "reply_korean: YES"
echo "smoke ok"
