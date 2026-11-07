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
