GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot

.PHONY: editor run import test export-web

editor:
	"$(GODOT)" --editor --path .

run:
	"$(GODOT)" --path .

import:
	"$(GODOT)" --headless --path . --import

test:
	@echo "テスト基盤は未導入です。Issue #16 を参照してください。"; exit 1

export-web:
	@echo "Web エクスポートは未設定です。Issue #17 を参照してください。"; exit 1
