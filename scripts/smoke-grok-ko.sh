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

TMP="$(mktemp -d /tmp/grok-ko-smoke.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

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
if [[ "$EC" -ne 0 ]]; then
  echo "--- stderr ---"
  tail -40 "$ERR"
  exit "$EC"
fi

# Resolve session dir for this cwd (URL-encoded)
ENC="$(python3 -c "import urllib.parse, os; print(urllib.parse.quote(os.path.realpath('$TMP'), safe=''))")"
# macOS /tmp -> /private/tmp
ENC2="$(python3 -c "import urllib.parse; print(urllib.parse.quote('/private$TMP' if not '$TMP'.startswith('/private') else '$TMP', safe=''))")"

TITLE=""
for base in "$HOME/.grok/sessions/$ENC" "$HOME/.grok/sessions/$ENC2"; do
  if [[ -d "$base" ]]; then
    SUM="$(find "$base" -name summary.json -mmin -10 2>/dev/null | head -1 || true)"
    if [[ -n "${SUM:-}" ]]; then
      TITLE="$(python3 -c "import json; d=json.load(open('$SUM')); print(d.get('generated_title') or d.get('session_summary') or '')")"
      echo "summary: $SUM"
      break
    fi
  fi
done

echo "=== generated_title ==="
echo "${TITLE:-"(not found — may be ok if session not written)"}"

# Heuristic: title should contain Hangul if present
if [[ -n "$TITLE" ]]; then
  if printf '%s' "$TITLE" | python3 -c "import sys,re; t=sys.stdin.read(); sys.exit(0 if re.search(r'[가-힣]', t) else 2)"; then
    echo "title_korean: YES"
  else
    echo "title_korean: NO (got ${TITLE@Q})"
    exit 2
  fi
fi

echo "smoke ok"
