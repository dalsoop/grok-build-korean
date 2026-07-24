#!/usr/bin/env bash
# Structural check: Korean SSOT strings present in shipped sources / release binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
check_file() {
  local f="$1" needle="$2"
  if ! grep -Fq -- "$needle" "$ROOT/$f"; then
    echo "MISSING in $f: $needle" >&2
    fail=1
  else
    echo "ok $f :: $needle"
  fi
}
check_file crates/codegen/xai-grok-shell/src/session/helpers/session_summary.rs "새 세션"
check_file crates/codegen/xai-grok-shell/src/session/helpers/session_recap.rs "요약 —"
check_file crates/common/xai-grok-compaction/src/code_compaction/templates/full_replace_summary_prompt.txt "Write the entire summary body in Korean"
check_file crates/codegen/xai-grok-pager/src/slash/commands/compact.rs "대화 기록 압축"
check_file crates/codegen/xai-grok-pager/src/views/dashboard/row.rs 'NEW_SESSION_LABEL: &str = "새 세션"'
if [[ -x "$ROOT/target/release/grok-ko" ]]; then
  if ! python3 -c "from pathlib import Path; b=Path(r'$ROOT/target/release/grok-ko').read_bytes(); import sys; sys.exit(0 if '생각 중'.encode() in b else 1)"; then
    echo "MISSING hangul in release binary" >&2
    fail=1
  else
    echo "ok binary :: 생각 중"
  fi
  ver=$("$ROOT/target/release/grok-ko" --version)
  echo "version $ver"
  if echo "$ver" | grep -q 0ce7dd5; then
    echo "stale version" >&2
    fail=1
  fi
fi
exit $fail
