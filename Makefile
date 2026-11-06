GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot
GGG ?= ggg

.PHONY: setup editor run import test export-web

setup:
	@command -v "$(GGG)" >/dev/null || { echo "ggg 0.6.0 が必要です。README の開発環境手順に従ってインストールするか、make setup GGG=/path/to/ggg を指定してください。"; exit 1; }
	@"$(GGG)" --version | grep -qx 'ggg 0.6.0' || { echo "ggg 0.6.0 が必要です。"; exit 1; }
	@command -v "$(GODOT)" >/dev/null || { echo "Godot が実行できません: $(GODOT)"; exit 1; }
	"$(GGG)" sync --godot "$$(command -v "$(GODOT)")"

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
