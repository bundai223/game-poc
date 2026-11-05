#!/bin/sh
set -eu

version=${GDUNIT4_VERSION:?GDUNIT4_VERSION is required}
url=${GDUNIT4_URL:?GDUNIT4_URL is required}
expected_sha256=${GDUNIT4_SHA256:?GDUNIT4_SHA256 is required}
addon=addons/gdUnit4

if [ -e "$addon" ]; then
	installed_version=$(sed -n 's/^version="\([^"]*\)"$/\1/p' "$addon/plugin.cfg" 2>/dev/null || true)
	if [ "$installed_version" = "$version" ] && [ -f "$addon/bin/GdUnitCmdTool.gd" ]; then
		exit 0
	fi
	echo "既存の $addon が GdUnit4 $version ではないか不完全です。既存ファイルを保護するため変更しません。" >&2
	exit 1
fi

mkdir -p addons
tmp=$(mktemp -d "addons/.gdunit4.XXXXXX")
lock=addons/.gdUnit4-installing
lock_owned=false
cleanup() {
	rm -rf "$tmp"
	if [ "$lock_owned" = true ]; then
		rmdir "$lock" 2>/dev/null || true
	fi
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

if ! mkdir "$lock" 2>/dev/null; then
	echo "GdUnit4 setup is already running (or left an install lock at $lock)." >&2
	exit 1
fi
lock_owned=true
if [ -e "$addon" ]; then
	echo "既存の $addon があるため上書きしません。" >&2
	exit 1
fi

curl -fL "$url" -o "$tmp/gdunit4.tar.gz"
actual_sha256=$(shasum -a 256 "$tmp/gdunit4.tar.gz" | awk '{print $1}')
if [ "$actual_sha256" != "$expected_sha256" ]; then
	echo "GdUnit4 archive SHA256 mismatch: $actual_sha256" >&2
	exit 1
fi

mkdir "$tmp/unpacked"
tar -xzf "$tmp/gdunit4.tar.gz" -C "$tmp/unpacked"
source_addon=$(find "$tmp/unpacked" -type f -path '*/addons/gdUnit4/plugin.cfg' -print -quit | sed 's#/plugin.cfg$##')
if [ -z "$source_addon" ]; then
	echo "GdUnit4 $version archive does not contain addons/gdUnit4/plugin.cfg" >&2
	exit 1
fi
archive_version=$(sed -n 's/^version="\([^"]*\)"$/\1/p' "$source_addon/plugin.cfg")
if [ "$archive_version" != "$version" ] || [ ! -f "$source_addon/bin/GdUnitCmdTool.gd" ]; then
	echo "GdUnit4 archive contents do not match version $version" >&2
	exit 1
fi

mv "$source_addon" "$addon"
