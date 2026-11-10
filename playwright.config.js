const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests/e2e',
  use: { baseURL: 'http://127.0.0.1:8000', viewport: { width: 1152, height: 648 } },
  webServer: {
    command: 'python3 -m http.server 8000 --bind 127.0.0.1 --directory build/web',
    url: 'http://127.0.0.1:8000/index.html',
    reuseExistingServer: false,
  },
});
