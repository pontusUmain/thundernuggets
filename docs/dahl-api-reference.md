# Dahl.se API Reference

Reverse-engineered from the dahl.se Nuxt 3 frontend (dahl-ecom v4.307.0). Last probed: 2026-03-06.

## Infrastructure Overview

| Service | Base URL | Auth Required | Status |
|---------|----------|---------------|--------|
| Product Information | `prd-api.dahl.se/product-information-service/v3` | No | Working |
| Search (SGDS) | `sgds-dahl-prd.54proxy.com` | No (User-Id header) | Working |
| Assortment | `prd-api.dahl.se/assortment-service/v1` | Yes (401) | Requires auth |
| Price | `prd-api.dahl.se/price-service` | Yes (401) | Requires auth |
| Stock | `prd-api.dahl.se/stock-service` | Yes (401) | Requires auth |
| Location | `prd-api.dahl.se/location-service` | Yes (401) | Requires auth |
| Campaign | `prd-api.dahl.se/campaign-service/v1` | Yes (401) | Requires auth |
| Order | `prd-api.dahl.se/order-service/v1` | Yes (401) | Requires auth |
| POND | `pond.prod.sgds.io/dahl/v1` | Yes (403) | Requires auth token |
| CDN (images) | `d1d2wjk9lgo5fo.cloudfront.net` | No | Working |
| CDN (assets) | `dahlprdcdnassets.s3.eu-north-1.amazonaws.com` | No | Working |

---

## 1. Search Service (SGDS) — Primary Discovery

The search service is the main entry point for finding products. It runs on the SGDS/54proxy platform.

### Search Products

```
POST https://sgds-dahl-prd.54proxy.com/search
```

**Required Headers:**
```
Content-Type: application/json
Accept: application/json
Api-Version: V3
User-Id: <any-string>       # e.g. "anonymous" or a session ID
```

**Request Body:**
```json
{
  "query": "koppar"
}
```

**Response (200):**
```json
{
  "makesSense": true,
  "spellingSuggestions": { "count": 0, "items": [] },
  "relatedQueries": { "count": 0, "items": [] },
  "results": {
    "count": 313,
    "facets": [ ... ],
    "items": [ ... ]
  },
  "relatedResults": { "count": 0, "facets": [], "items": [] },
  "customData": { "VariantResults_TotalItems": "..." }
}
```

**Result Item Schema:**
```json
{
  "type": "Product",
  "id": "Product2G_1590827365690227",
  "attributes": [
    {
      "name": "variant",
      "type": "string",
      "values": ["<JSON-encoded variant string>"]
    }
  ]
}
```

Each item's `attributes[0].values` contains JSON-encoded variant strings. Parse them to get product details.

**Parsed Variant Schema:**
```json
{
  "id": "4816004",
  "productId": "Product2G_1590827365690227",
  "name": "KOPPARRÖR 22X1,0 MM 2,5 METER HÅRDA ALTECH",
  "articleNumber": "4816004",
  "variantSlug": "kopparror-22x1-0-mm-2-5-meter-harda-altech-4816004",
  "productSlug": "koppar-harda-2-5-meter-enligt-en-1057-r290-product2g-1590827365690227",
  "brands": [
    {
      "brand": "ALTECH",
      "assetUrl": "https://d1d2wjk9lgo5fo.cloudfront.net/logotyp-xxx.jpeg",
      "assetFallbackUrl": "https://d1d2wjk9lgo5fo.cloudfront.net/logotyp-xxx-fallback.jpeg"
    }
  ],
  "ean": "7332508109859",
  "description": "",
  "attributes": [
    { "attributeName": "articleNumber", "attributeLabel": "Art. nr.", "attributeValue": "4816004", "sort": 0 },
    { "attributeName": "Utvändig rördiameter", "attributeLabel": "Utvändig rördiameter", "attributeValue": "22 mm", "sort": 1 }
  ],
  "images": [
    { "assetUrl": "https://d1d2wjk9lgo5fo.cloudfront.net/xxx.jpeg", "assetType": "Bild 1" }
  ],
  "assets": [
    { "assetUrl": "https://...", "assetType": "Prestandadeklaration", "assetMimeType": "application/pdf" }
  ],
  "classifications": [
    { "classificationName": "CE", "classificationType": "Miljömärkningar", "assetUrl": "https://..." }
  ],
  "stockedAt": ["101", "105", "106"],
  "filterTags": ["express-pickup", "express-delivery"],
  "relations": {
    "kompletteraMed": {
      "label": "Komplettera med",
      "articleNumbers": ["1947239", "3858255"],
      "categories": ["rordelar-och-kopplingar/press/m-press/koppar"]
    }
  },
  "discontinued": false,
  "campaignIds": [],
  "assortmentIds": ["assortment-1", "..."],
  "categoryIds": ["ror/vatten-varme-och-gas/koppar/harda/kopparror"],
  "etimClass": "EC011533 - Kopparrör",
  "supplyGroup": "LAG",
  "keywords": ["kopparrör", "koppar"]
}
```

### AutoComplete

```
POST https://sgds-dahl-prd.54proxy.com/autoComplete
```

**Required Headers:** Same as search.

**Request Body:**
```json
{
  "query": "kopp"
}
```

**Response (200):**
```json
{
  "scopedQuery": {
    "query": "kopparrör",
    "scopes": [],
    "scopeAttributeName": "Category3"
  },
  "queries": {
    "count": 24,
    "items": [
      { "query": "kopparrör" },
      { "query": "koppar" },
      { "query": "koppar rör" },
      { "query": "koppling" }
    ]
  }
}
```

---

## 2. Product Information Service — Product Details

Use this to fetch full product detail pages with all variants.

### Get Product by ID

```
GET https://prd-api.dahl.se/product-information-service/v3/products/{productId}
```

**Headers:**
```
Accept: application/json
Content-Type: application/json
Origin: https://www.dahl.se
Referer: https://www.dahl.se/
```

> Note: `{productId}` can be either the product ID (e.g. `Product2G_1590827365690227`) or an article number (e.g. `4816004`).

**Response (200):**
```json
{
  "id": "Product2G_1590827365690227",
  "name": "Koppar hårda, 2,5 meter. Enligt EN 1057-R290",
  "text": "Altech hårt kopparrör R290 levereras i raka längder...",
  "categoryPaths": ["ror/vatten-varme-och-gas/koppar/harda/kopparror"],
  "categoryLeafs": ["Rör|Kopparrör"],
  "commonVariantAttributes": [
    { "attributeName": "Material", "attributeLabel": "Material", "attributeValue": "Koppar", "sort": 10 }
  ],
  "variantAttributes": [
    { "name": "articleNumber", "label": "Art. nr.", "sort": 0 },
    { "name": "Utvändig rördiameter", "label": "Utvändig rördiameter", "sort": 1 }
  ],
  "images": [
    { "assetUrl": "https://d1d2wjk9lgo5fo.cloudfront.net/xxx.jpeg", "assetType": "Bild 1" }
  ],
  "assets": [],
  "variants": [
    {
      "id": "4816000",
      "productId": "Product2G_1590827365690227",
      "name": "KOPPARRÖR 10X0,8 MM 2,5 METER HÅRDA ALTECH",
      "articleNumber": "4816000",
      "variantSlug": "kopparror-10x0-8-mm-2-5-meter-harda-altech-4816000",
      "productSlug": "koppar-harda-2-5-meter-...",
      "brands": [{ "brand": "ALTECH", "assetUrl": "..." }],
      "ean": "7332508109811",
      "attributes": [
        { "attributeName": "Utvändig rördiameter", "attributeValue": "10 mm" }
      ],
      "images": [{ "assetUrl": "...", "assetType": "Bild 1" }],
      "stockedAt": ["101", "105"],
      "filterTags": ["express-pickup", "express-delivery"],
      "discontinued": false
    }
  ]
}
```

**Error (404):** `{"message":"Entity not found"}` — invalid product/article ID.

---

## 3. Categories

Categories are hierarchical, extracted from the product sitemap at:
```
https://dahlprdcdnassets.s3.eu-north-1.amazonaws.com/sitemaps/products-0.xml
```

### Top-Level Categories (12)

| Slug | Swedish Name |
|------|-------------|
| `ror` | Rör |
| `rordelar-och-kopplingar` | Rördelar och kopplingar |
| `sanitet-och-blandare` | Sanitet och blandare |
| `vatten-varme-och-kyla` | Vatten, värme och kyla |
| `brunnar-och-avloppssystem` | Brunnar och avloppssystem |
| `montage-och-utrustning` | Montage och utrustning |
| `rorsystem-slang-och-brand` | Rörsystem, slang och brand |
| `ventilation-och-teknisk-isolering` | Ventilation och teknisk isolering |
| `el-och-ljus` | El och ljus |
| `geoteknik-markisolering-och-dranering` | Geoteknik, markisolering och dränering |
| `trafiksakerhet` | Trafiksäkerhet |
| `af-sortiment` | AF Sortiment |

Category paths follow the pattern: `https://dahl.se/kategorier/{level1}/{level2}/{level3}/...`

The search API returns categories as facets under `results.facets[name="categoryLeafs"]`.

---

## 4. Auth-Protected Services

The following endpoints require authentication (return 401/403 without tokens). They likely use JWT Bearer tokens obtained via the auth-service.

### Price Service
- `POST https://prd-api.dahl.se/price-service/prices` — GET returns 405, must use POST
- Likely accepts `{"articleNumbers": ["4816004"]}` with auth header

### Stock Service
- `POST https://prd-api.dahl.se/stock-service/stock` — GET returns 405, must use POST
- Likely accepts `{"articleNumbers": ["4816004"]}` with auth header

### Assortment Service
- `GET https://prd-api.dahl.se/assortment-service/v1/assortments` — returns 401

### Location Service
- `GET https://prd-api.dahl.se/location-service/locations` — returns 401

### Campaign Service
- `GET https://prd-api.dahl.se/campaign-service/v1/campaigns` — returns 401

### POND (Product Data)
- `GET https://pond.prod.sgds.io/dahl/v1` — returns 403 "Missing Authentication Token"

---

## 5. CDN & Image URLs

**Product images:**
```
https://d1d2wjk9lgo5fo.cloudfront.net/{image-id}.jpeg
```

**Brand logos:**
```
https://d1d2wjk9lgo5fo.cloudfront.net/logotyp-{id}.jpeg
https://d1d2wjk9lgo5fo.cloudfront.net/logotyp-{id}-fallback.jpeg
```

**Documents/assets:**
```
https://dahlprdcdnassets.s3.eu-north-1.amazonaws.com/documents/{doc-id}
```

**External product data sheets (RSK):**
```
https://www.rskdatabasen.se/infodocs/{type}/{filename}.pdf
```

---

## 6. Frontend URL Patterns

Product pages on dahl.se:
```
https://dahl.se/produkt/{productSlug}?articleNumber={articleNumber}
```

Category pages:
```
https://dahl.se/kategorier/{category-path}
```

---

## 7. Usage Notes for App Integration

1. **Search flow**: Use SGDS `POST /search` with `Api-Version: V3` and `User-Id` headers to find products
2. **Product detail flow**: Use PIS `GET /products/{articleNumber}` to fetch full product info with all variants
3. **Autocomplete**: Use SGDS `POST /autoComplete` for search-as-you-type suggestions
4. **Price/Stock**: Requires authenticated session — will need user login flow or server-side proxy
5. **Images**: CloudFront URLs are publicly accessible, no auth needed
6. **Rate limiting**: No rate limit headers observed; standard bot protection (Incapsula) on www.dahl.se but API endpoints are unprotected
