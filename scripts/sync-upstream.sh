#!/usr/bin/env bash
# Fetch upstream and print merge guidance. Does not auto-merge.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream https://github.com/xai-org/grok-build.git
fi

git fetch upstream --tags
echo "local:    $(git rev-parse --short HEAD) $(git log -1 --pretty=%s)"
echo "upstream: $(git rev-parse --short upstream/main) $(git log -1 --pretty=%s upstream/main)"
echo
echo "To merge (careful — re-check Korean prompt/UI strings after conflicts):"
echo "  git merge upstream/main"
echo "  make build && make install && make smoke"
