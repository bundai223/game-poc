// Package main defines the local and CI checks for game-poc.
package main

import "dagger/game-poc/internal/dagger"

type GamePoc struct{}

// Verify builds the Web version and runs the Godot and browser tests.
func (m *GamePoc) Verify(source *dagger.Directory) *dagger.Directory {
	build := dag.Container(dagger.ContainerOpts{Platform: "linux/amd64"}).
		From("node:22-bookworm").
		WithExec([]string{"bash", "-c", `set -eu
apt-get update
apt-get install -y curl unzip xz-utils python3
curl -fL 'https://github.com/godotneers/ggg/releases/download/v0.6.0/ggg-x86_64-unknown-linux-gnu.tar.xz' -o /tmp/ggg.tar.xz
echo '769586eaec6c4a80efbe05f28f108da029058db01fdd326172b961f0b803249a  /tmp/ggg.tar.xz' | sha256sum -c -
mkdir -p /tmp/ggg
tar -xJf /tmp/ggg.tar.xz -C /tmp/ggg --strip-components=1
curl -fL 'https://downloads.godotengine.org/?version=4.7.2&flavor=stable&slug=linux.x86_64.zip&platform=linux.64' -o /tmp/godot.zip
unzip -q /tmp/godot.zip -d /tmp/godot
curl -fL 'https://downloads.godotengine.org/?version=4.7.2&flavor=stable&slug=export_templates.tpz&platform=templates' -o /tmp/templates.tpz
mkdir -p /root/.local/share/godot/export_templates/4.7.2.stable
unzip -q -j /tmp/templates.tpz 'templates/version.txt' 'templates/web*.zip' -d /root/.local/share/godot/export_templates/4.7.2.stable
`}).
		WithDirectory("/work", source, dagger.ContainerWithDirectoryOpts{Exclude: []string{".git", ".godot", "addons", "build", "reports", "node_modules", "test-results", ".dagger/internal"}}).
		WithWorkdir("/work").
		WithExec([]string{"bash", "-c", `set -eu
make import GODOT=/tmp/godot/Godot_v4.7.2-stable_linux.x86_64 GGG=/tmp/ggg/ggg
make test GODOT=/tmp/godot/Godot_v4.7.2-stable_linux.x86_64 GGG=/tmp/ggg/ggg
make export-web GODOT=/tmp/godot/Godot_v4.7.2-stable_linux.x86_64 GGG=/tmp/ggg/ggg
`}).
		Directory("/work/build/web")

	return dag.Container().From("node:22-bookworm").
		WithDirectory("/work", source, dagger.ContainerWithDirectoryOpts{Exclude: []string{".git", ".godot", "addons", "build", "reports", "node_modules", "test-results", ".dagger/internal"}}).
		WithDirectory("/work/build/web", build).
		WithWorkdir("/work").
		WithExec([]string{"bash", "-c", `set -eu
npm ci
npx playwright install --with-deps chromium
npm run test:e2e
`}).
		Directory("/work/build/web")
}
