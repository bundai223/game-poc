const { test, expect } = require('@playwright/test');

test('Web 版で形を描いてリセットできる', async ({ page }) => {
  await page.goto('/');
  const canvas = page.locator('canvas');
  await expect(canvas).toBeVisible();
  await expect(page.locator('#status')).toBeHidden({ timeout: 30000 });
  const before = await canvas.screenshot();
  const box = await canvas.boundingBox();
  expect(box).not.toBeNull();

  await page.mouse.move(box.x + 100, box.y + 150);
  await page.mouse.down();
  await page.mouse.move(box.x + 250, box.y + 150);
  await page.mouse.move(box.x + 175, box.y + 300);
  await page.mouse.up();
  await expect.poll(async () => (await canvas.screenshot()).equals(before)).toBe(false);

  await page.keyboard.press('r');
  await expect.poll(async () => (await canvas.screenshot()).equals(before)).toBe(true);
});

test('Web 版で接触IDが0以外のタッチから形を描ける', async ({ browser }) => {
  const context = await browser.newContext({
    viewport: { width: 1152, height: 648 },
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  });
  try {
    const page = await context.newPage();
    await page.goto('/');
    const canvas = page.locator('canvas');
    await expect(canvas).toBeVisible();
    await expect(page.locator('#status')).toBeHidden({ timeout: 30000 });
    const before = await canvas.screenshot();
    const box = await canvas.boundingBox();
    expect(box).not.toBeNull();
    const cdp = await context.newCDPSession(page);
    const points = [[100, 150], [250, 150], [175, 300], [100, 150]].map(([x, y]) => ({
      x: box.x + x,
      y: box.y + y,
      id: 1,
      radiusX: 5,
      radiusY: 5,
      force: 1,
    }));

    await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [points[0]] });
    for (const point of points.slice(1)) {
      await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [point] });
    }
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });

    await expect.poll(async () => !(await canvas.screenshot()).equals(before)).toBe(true);
  } finally {
    await context.close();
  }
});

test('Web 版から3D Craftへ移動して2Dへ戻れる', async ({ page }) => {
  await page.goto('/');
  const canvas = page.locator('canvas');
  await expect(canvas).toBeVisible();
  await expect(page.locator('#status')).toBeHidden({ timeout: 30000 });
  const box = await canvas.boundingBox();
  expect(box).not.toBeNull();
  const drawing = await canvas.screenshot();

  await page.mouse.click(box.x + box.width - 120, box.y + 156);
  await expect.poll(async () => !(await canvas.screenshot()).equals(drawing)).toBe(true);
  await page.mouse.click(box.x + 432, box.y + 116);
  await expect.poll(async () => (await canvas.screenshot()).equals(drawing)).toBe(true);
});

test('Web 版で削除モードから図形を個別に削除できる', async ({ page }) => {
  await page.goto('/');
  const canvas = page.locator('canvas');
  await expect(canvas).toBeVisible();
  await expect(page.locator('#status')).toBeHidden({ timeout: 30000 });
  const box = await canvas.boundingBox();
  expect(box).not.toBeNull();
  await page.mouse.click(box.x + box.width - 120, box.y + 250);
  await page.mouse.click(box.x + box.width - 120, box.y + 250);
  await page.mouse.move(box.x + 50, box.y + 50);
  await page.waitForTimeout(200);
  const empty = await canvas.screenshot();
  await page.mouse.click(box.x + box.width - 120, box.y + 250);
  await page.mouse.move(box.x + 100, box.y + 400);
  await page.mouse.down();
  await page.mouse.move(box.x + 250, box.y + 400);
  await page.mouse.move(box.x + 250, box.y + 500);
  await page.mouse.move(box.x + 100, box.y + 500);
  await page.mouse.up();
  await page.waitForTimeout(1500);
  await page.mouse.click(box.x + box.width - 120, box.y + 250);
  await page.mouse.click(box.x + box.width - 120, box.y + 250);
  await expect.poll(async () => (await canvas.screenshot()).equals(empty)).toBe(false);
  await page.mouse.click(box.x + 175, box.y + 560);
  await page.mouse.move(box.x + 50, box.y + 50);
  await expect.poll(async () => (await canvas.screenshot()).equals(empty)).toBe(true);
});
