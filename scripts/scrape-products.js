const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const CATEGORIES = [
  { slug: 'ror', url: 'https://www.dahl.se/kategorier/ror', name: 'Rör' },
  { slug: 'montage-och-utrustning', url: 'https://www.dahl.se/kategorier/montage-och-utrustning', name: 'Montage och utrustning' },
  { slug: 'vatten-varme-och-kyla', url: 'https://www.dahl.se/kategorier/vatten-varme-och-kyla', name: 'Vatten, värme och kyla' },
  { slug: 'sanitet-och-blandare', url: 'https://www.dahl.se/kategorier/sanitet-och-blandare', name: 'Sanitet och blandare' },
  { slug: 'brunnar-och-avloppssystem', url: 'https://www.dahl.se/kategorier/brunnar-och-avloppssystem', name: 'Brunnar och avloppssystem' },
];

const OUTPUT_PATH = path.join(__dirname, '..', 'mobile', 'DahlPrototype', 'DahlPrototype', 'MockData', 'products.json');

// Price ranges per category (SEK, realistic VVS pricing)
const PRICE_RANGES = {
  'Rör': [45, 850],
  'Montage och utrustning': [120, 4500],
  'Vatten, värme och kyla': [250, 12000],
  'Sanitet och blandare': [800, 8500],
  'Brunnar och avloppssystem': [350, 3200],
};

function mockPrice(category) {
  const [min, max] = PRICE_RANGES[category] || [100, 1000];
  // Return amount in SEK (not öre, as the mock data is for display)
  const price = Math.round((Math.random() * (max - min) + min) * 10) / 10;
  return price;
}

function skuFromUrl(url) {
  // URL like /produkt/kopparror-22x1-0-mm-2-5-meter-harda-altech-4816004
  // SKU is the trailing numeric ID
  const match = url.match(/-(\d{5,})$/);
  return match ? `VVS-${match[1]}` : null;
}

async function scrapeCategory(page, category) {
  console.log(`Scraping: ${category.name}`);

  await page.goto(category.url, { waitUntil: 'domcontentloaded', timeout: 30000 });

  // Wait for product tiles to appear in the DOM
  await page.waitForSelector('[data-test="product-tile-wrapper"]', { timeout: 15000 });

  const products = await page.evaluate((categoryName) => {
    const tiles = document.querySelectorAll('[data-test="product-tile-wrapper"]');
    const results = [];

    for (const tile of tiles) {
      // Name
      const nameEl = tile.querySelector('h2.product-tile__heading a, .product-tile__heading a');
      const name = nameEl ? nameEl.textContent.trim() : null;
      if (!name) continue;

      // URL (for SKU extraction)
      const linkEl = tile.querySelector('a[href*="/produkt/"]');
      const href = linkEl ? linkEl.getAttribute('href') : null;

      // Image — prefer data-src (real URL), fall back to src if not a placeholder gif
      const imgEl = tile.querySelector('.product-tile__image img, .c-image img');
      let image = null;
      if (imgEl) {
        const dataSrc = imgEl.getAttribute('data-src');
        const src = imgEl.getAttribute('src');
        // data-src holds real URL; src may be a base64 placeholder when lazy-loaded
        image = dataSrc || (src && !src.startsWith('data:') ? src : null);
        if (image) image = image.replace('w=120&h=120', 'w=400&h=400');
      }

      results.push({ name, href, image, category: categoryName });
      if (results.length >= 5) break;
    }

    return results;
  }, category.name);

  console.log(`  Found ${products.length} products`);
  return products;
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    locale: 'sv-SE',
    viewport: { width: 1280, height: 900 },
  });

  const page = await context.newPage();
  const allProducts = [];

  for (const category of CATEGORIES) {
    try {
      const raw = await scrapeCategory(page, category);
      for (const p of raw) {
        allProducts.push({
          name: p.name,
          sku: p.href ? skuFromUrl(p.href) : null,
          price: mockPrice(category.name),
          currency: 'SEK',
          category: p.category,
          image: p.image,
        });
      }
    } catch (err) {
      console.error(`  Error scraping ${category.name}: ${err.message}`);
    }
  }

  await browser.close();

  const outputDir = path.dirname(OUTPUT_PATH);
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

  const output = { products: allProducts };
  fs.writeFileSync(OUTPUT_PATH, JSON.stringify(output, null, 2));
  console.log(`\nWrote ${allProducts.length} products to ${OUTPUT_PATH}`);
}

main().catch(err => {
  console.error('Fatal:', err);
  process.exit(1);
});
