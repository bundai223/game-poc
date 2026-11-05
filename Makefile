GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot

.PHONY: editor run import test export-web

editor:
	"$(GODOT)" --editor --path .

run:
	"$(GODOT)" --path .

import:
	"$(GODOT)" --headless --path . --import

test:
	@command -v "$(GODOT)" >/dev/null || { echo "Godot が実行できません: $(GODOT)"; exit 1; }
	@case "$$('$(GODOT)' --version)" in 4.7.2.*) ;; *) echo "Godot 4.7.2 が必要です: $$('$(GODOT)' --version)"; exit 1;; esac
	@test -f addons/gdUnit4/bin/GdUnitCmdTool.gd || { echo "GdUnit4 runner がありません。addons/gdUnit4 を復元してください。"; exit 1; }
	@test -n "$$(find tests -type f -name 'test_*.gd' -print -quit)" || { echo "tests/ に test_*.gd がありません。"; exit 1; }
	"$(GODOT)" --headless --editor --path . --quit
	@output=$$('$(GODOT)' --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests 2>&1); status=$$?; printf '%s\n' "$$output"; test $$status -eq 0 || exit $$status; printf '%s\n' "$$output" | grep -Eq 'Executed test cases : \([1-9][0-9]*/'

export-web:
	mkdir -p build/web
	"$(GODOT)" --headless --path . --export-release Web build/web/index.html
