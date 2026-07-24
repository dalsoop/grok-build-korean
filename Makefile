# grok-build-korean — side-by-side Korean fork of Grok Build
# Binary: grok-ko (does not replace official `grok`)

.PHONY: help deps build install smoke version upstream-fetch clean

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
BREW_BINDIR ?= /opt/homebrew/bin
CARGO ?= cargo
PACKAGE ?= xai-grok-pager-bin
ARTIFACT ?= target/release/grok-ko
# jemalloc can trip arm64 ld fixup errors on large release links; sandbox-only is enough for ship.
CARGO_FEATURES ?= --no-default-features --features sandbox-enforce

help:
	@echo "grok-build-korean targets:"
	@echo "  make deps       Install build deps (dotslash, protobuf) via brew"
	@echo "  make build      Release-build grok-ko"
	@echo "  make install    Install grok-ko to $(BINDIR) (and brew bin if writable)"
	@echo "  make smoke      Headless one-shot smoke (Korean title)"
	@echo "  make version    Show installed + built versions"
	@echo "  make clean      cargo clean"
	@echo "  make upstream-fetch  Fetch xai-org/grok-build into remote 'upstream'"

deps:
	@command -v brew >/dev/null || { echo "brew required"; exit 1; }
	brew list dotslash >/dev/null 2>&1 || brew install dotslash
	brew list protobuf >/dev/null 2>&1 || brew install protobuf
	@echo "deps ok: $$(command -v dotslash) $$(command -v protoc)"

build:
	@export PATH="/opt/homebrew/bin:$$PATH"; \
	export MACOSX_DEPLOYMENT_TARGET="$${MACOSX_DEPLOYMENT_TARGET:-$$(sw_vers -productVersion | awk -F. '{print $$1".0"}')}"; \
	$(CARGO) build -p $(PACKAGE) --release $(CARGO_FEATURES)
	@test -x $(ARTIFACT)
	@echo "built: $(ARTIFACT)"
	@$(ARTIFACT) --version

install: build
	@mkdir -p "$(BINDIR)"
	install -m 755 "$(ARTIFACT)" "$(BINDIR)/grok-ko"
	@echo "installed: $(BINDIR)/grok-ko"
	@if [ -w "$(BREW_BINDIR)" ] 2>/dev/null; then \
		install -m 755 "$(ARTIFACT)" "$(BREW_BINDIR)/grok-ko"; \
		echo "installed: $(BREW_BINDIR)/grok-ko"; \
	fi
	@command -v grok-ko
	@grok-ko --version

smoke:
	@command -v grok-ko >/dev/null || { echo "grok-ko not on PATH — run make install"; exit 1; }
	@./scripts/smoke-grok-ko.sh

version:
	@echo "git: $$(git rev-parse --short HEAD) ($$(git log -1 --pretty=%s))"
	@echo -n "built: "; test -x $(ARTIFACT) && $(ARTIFACT) --version || echo "(missing)"
	@echo -n "PATH:  "; command -v grok-ko >/dev/null && grok-ko --version || echo "(not installed)"
	@echo -n "official grok: "; command -v grok >/dev/null && grok --version || echo "(none)"

upstream-fetch:
	@git remote get-url upstream >/dev/null 2>&1 || \
		git remote add upstream https://github.com/xai-org/grok-build.git
	git fetch upstream --tags
	@echo "upstream HEAD: $$(git rev-parse --short upstream/main 2>/dev/null || echo '?')"
	@echo "local HEAD:    $$(git rev-parse --short HEAD)"

clean:
	$(CARGO) clean
