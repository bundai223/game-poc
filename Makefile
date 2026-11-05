GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot
GDUNIT4_VERSION := 6.2.3
GDUNIT4_URL := https://github.com/godot-gdunit-labs/gdUnit4/archive/refs/tags/v$(GDUNIT4_VERSION).tar.gz
GDUNIT4_SHA256 := 42dc61721b1b6bc40dac0ff34a71d2b0811ca92109add0b923ad01f96f04abf8

.PHONY: setup editor run import test export-web

setup:
	GDUNIT4_VERSION="$(GDUNIT4_VERSION)" GDUNIT4_URL="$(GDUNIT4_URL)" GDUNIT4_SHA256="$(GDUNIT4_SHA256)" ./scripts/setup-gdunit4.sh

editor: setup
	"$(GODOT)" --editor --path .

run: setup
	"$(GODOT)" --path .

import: setup
	"$(GODOT)" --headless --path . --import

test: setup
	@command -v "$(GODOT)" >/dev/null || { echo "Godot が実行できません: $(GODOT)"; exit 1; }
	@case "$$('$(GODOT)' --version)" in 4.7.2.*) ;; *) echo "Godot 4.7.2 が必要です: $$('$(GODOT)' --version)"; exit 1;; esac
	@test -f addons/gdUnit4/bin/GdUnitCmdTool.gd || { echo "GdUnit4 runner がありません。make setup を実行してください。"; exit 1; }
	@test -n "$$(find tests -type f -name 'test_*.gd' -print -quit)" || { echo "tests/ に test_*.gd がありません。"; exit 1; }
	"$(GODOT)" --headless --editor --path . --quit
	@output=$$('$(GODOT)' --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests 2>&1); status=$$?; printf '%s\n' "$$output"; test $$status -eq 0 || exit $$status; printf '%s\n' "$$output" | grep -Eq 'Executed test cases : \([1-9][0-9]*/'

export-web: setup
	mkdir -p build/web
	"$(GODOT)" --headless --path . --export-release Web build/web/index.html
