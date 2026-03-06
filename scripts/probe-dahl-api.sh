#!/bin/bash
# Probe Dahl.se API endpoints to discover request/response formats
# Usage: ./scripts/probe-dahl-api.sh [output_dir]

set -eo pipefail

OUTPUT_DIR="${1:-/tmp/dahl-api-probe}"
mkdir -p "$OUTPUT_DIR"

BASE="https://prd-api.dahl.se"
SEARCH_BASE="https://sgds-dahl-prd.54proxy.com"
CDN_BASE="https://dahlprdcdnassets.s3.eu-north-1.amazonaws.com"

# Common headers mimicking a browser / Nuxt SSR request
COMMON_HEADERS=(
  -H "Accept: application/json"
  -H "Content-Type: application/json"
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
  -H "Origin: https://www.dahl.se"
  -H "Referer: https://www.dahl.se/"
)

probe() {
  local label="$1"
  local method="$2"
  local url="$3"
  shift 3
  local extra_args=("$@")

  local outfile="$OUTPUT_DIR/$(echo "$label" | tr ' /' '_-').json"
  echo "=== $label ==="
  echo "  $method $url"

  local http_code
  if [[ ${#extra_args[@]} -gt 0 ]]; then
    http_code=$(curl -s -o "$outfile" -w "%{http_code}" \
      -X "$method" \
      "${COMMON_HEADERS[@]}" \
      --max-time 15 \
      "${extra_args[@]}" \
      "$url" 2>/dev/null || echo "000")
  else
    http_code=$(curl -s -o "$outfile" -w "%{http_code}" \
      -X "$method" \
      "${COMMON_HEADERS[@]}" \
      --max-time 15 \
      "$url" 2>/dev/null || echo "000")
  fi

  echo "  Status: $http_code"

  if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
    echo "  Response (first 500 chars):"
    head -c 500 "$outfile" 2>/dev/null | python3 -m json.tool 2>/dev/null || head -c 500 "$outfile" 2>/dev/null
    echo ""
  elif [[ -s "$outfile" ]]; then
    echo "  Error body (first 300 chars):"
    head -c 300 "$outfile" 2>/dev/null
    echo ""
  fi
  echo ""
}

probe_with_headers() {
  local label="$1"
  local method="$2"
  local url="$3"
  shift 3
  local extra_args=("$@")

  local outfile="$OUTPUT_DIR/$(echo "$label" | tr ' /' '_-').txt"
  echo "=== $label (with response headers) ==="
  echo "  $method $url"

  if [[ ${#extra_args[@]} -gt 0 ]]; then
    curl -s -D "$outfile.headers" -o "$outfile.body" \
      -X "$method" \
      "${COMMON_HEADERS[@]}" \
      --max-time 15 \
      "${extra_args[@]}" \
      "$url" 2>/dev/null || true
  else
    curl -s -D "$outfile.headers" -o "$outfile.body" \
      -X "$method" \
      "${COMMON_HEADERS[@]}" \
      --max-time 15 \
      "$url" 2>/dev/null || true
  fi

  if [[ -f "$outfile.headers" ]]; then
    echo "  Response headers:"
    cat "$outfile.headers"
  fi
  if [[ -f "$outfile.body" ]]; then
    echo "  Body (first 500 chars):"
    head -c 500 "$outfile.body" 2>/dev/null | python3 -m json.tool 2>/dev/null || head -c 500 "$outfile.body" 2>/dev/null
    echo ""
  fi
  echo ""
}

echo "============================================"
echo "  Dahl.se API Probe — $(date)"
echo "  Output: $OUTPUT_DIR"
echo "============================================"
echo ""

# ------------------------------------------------------------------
# 1. Product Information Service
# ------------------------------------------------------------------
echo ">>> PRODUCT INFORMATION SERVICE"
probe "PIS products list" GET "$BASE/product-information-service/v3/products"
probe "PIS products query koppar" GET "$BASE/product-information-service/v3/products?q=koppar"
probe "PIS products query limit" GET "$BASE/product-information-service/v3/products?limit=5"
probe "PIS single product sample sku" GET "$BASE/product-information-service/v3/products/1234567"
probe "PIS categories" GET "$BASE/product-information-service/v3/categories"
probe "PIS product by article" GET "$BASE/product-information-service/v3/articles"
probe "PIS v3 root" GET "$BASE/product-information-service/v3"

# ------------------------------------------------------------------
# 2. Assortment Service
# ------------------------------------------------------------------
echo ">>> ASSORTMENT SERVICE"
probe "Assortment list" GET "$BASE/assortment-service/v1/assortments"
probe "Assortment categories" GET "$BASE/assortment-service/v1/categories"
probe "Assortment tree" GET "$BASE/assortment-service/v1/tree"
probe "Assortment root" GET "$BASE/assortment-service/v1"

# ------------------------------------------------------------------
# 3. Search (SGDS / 54proxy)
# ------------------------------------------------------------------
echo ">>> SEARCH SERVICE (SGDS)"
probe "SGDS search GET koppar" GET "$SEARCH_BASE/search?q=koppar"
probe "SGDS search v3 GET" GET "$SEARCH_BASE/v3/search?q=koppar"
probe "SGDS search POST" POST "$SEARCH_BASE/search" -d '{"q":"koppar"}'
probe "SGDS search v3 POST" POST "$SEARCH_BASE/v3/search" -d '{"query":"koppar","limit":5}'
probe "SGDS autocomplete" GET "$SEARCH_BASE/autocomplete?q=kopp"
probe "SGDS suggest" GET "$SEARCH_BASE/suggest?q=kopp"
probe "SGDS root" GET "$SEARCH_BASE/"

# Try with X-API-Key header patterns
probe "SGDS search with dahl header" GET "$SEARCH_BASE/search?q=koppar" \
  -H "X-Client-Id: dahl-ecom"
probe "SGDS v3 products" GET "$SEARCH_BASE/v3/products?q=koppar"

# ------------------------------------------------------------------
# 4. Price Service
# ------------------------------------------------------------------
echo ">>> PRICE SERVICE"
probe "Price root" GET "$BASE/price-service"
probe "Price prices" GET "$BASE/price-service/prices"
probe "Price by sku" GET "$BASE/price-service/prices?sku=1234567"
probe "Price v1" GET "$BASE/price-service/v1/prices"

# ------------------------------------------------------------------
# 5. Stock Service
# ------------------------------------------------------------------
echo ">>> STOCK SERVICE"
probe "Stock root" GET "$BASE/stock-service"
probe "Stock query" GET "$BASE/stock-service/stock"
probe "Stock by sku" GET "$BASE/stock-service/stock?sku=1234567"
probe "Stock v1" GET "$BASE/stock-service/v1/stock"

# ------------------------------------------------------------------
# 6. Location Service
# ------------------------------------------------------------------
echo ">>> LOCATION SERVICE"
probe "Location root" GET "$BASE/location-service"
probe "Location stores" GET "$BASE/location-service/stores"
probe "Location v1 stores" GET "$BASE/location-service/v1/stores"
probe "Location locations" GET "$BASE/location-service/locations"

# ------------------------------------------------------------------
# 7. Campaign Service
# ------------------------------------------------------------------
echo ">>> CAMPAIGN SERVICE"
probe "Campaign root" GET "$BASE/campaign-service/v1"
probe "Campaign list" GET "$BASE/campaign-service/v1/campaigns"

# ------------------------------------------------------------------
# 8. Auth Service (discovery only)
# ------------------------------------------------------------------
echo ">>> AUTH SERVICE (discovery)"
probe "Auth root" GET "$BASE/auth-service"
probe "Auth wellknown" GET "$BASE/auth-service/.well-known/openid-configuration"
probe "Auth login" GET "$BASE/auth-service/login"

# ------------------------------------------------------------------
# 9. Cart & Order (discovery only)
# ------------------------------------------------------------------
echo ">>> CART & ORDER SERVICE (discovery)"
probe "Cart root" GET "$BASE/cart-service"
probe "Order root" GET "$BASE/order-service/v1"

# ------------------------------------------------------------------
# 10. Dahl.se frontend — fetch product page for embedded data
# ------------------------------------------------------------------
echo ">>> FRONTEND PRODUCT PAGE SCRAPE"
probe_with_headers "Frontend homepage" GET "https://www.dahl.se/" \
  -H "Accept: text/html" -H "Content-Type: text/html"

# ------------------------------------------------------------------
# 11. Sitemap
# ------------------------------------------------------------------
echo ">>> SITEMAP"
probe "Products sitemap 0" GET "$CDN_BASE/sitemaps/products-0.xml"
probe "Main sitemap" GET "$CDN_BASE/sitemaps/sitemap.xml"
probe "Sitemap index" GET "https://www.dahl.se/sitemap.xml"

# ------------------------------------------------------------------
# 12. POND Product Data
# ------------------------------------------------------------------
echo ">>> POND (product data)"
probe "POND root" GET "https://pond.prod.sgds.io/dahl/v1"
probe "POND products" GET "https://pond.prod.sgds.io/dahl/v1/products"
probe "POND product search" GET "https://pond.prod.sgds.io/dahl/v1/products?q=koppar"

echo "============================================"
echo "  Probe complete. Results in: $OUTPUT_DIR"
echo "============================================"

# Summary
echo ""
echo ">>> SUMMARY OF HTTP STATUS CODES"
echo ""
for f in "$OUTPUT_DIR"/*.json; do
  label=$(basename "$f" .json | tr '_-' ' ')
  if [[ -s "$f" ]]; then
    size=$(wc -c < "$f" | tr -d ' ')
    echo "  $label: ${size} bytes"
  else
    echo "  $label: empty"
  fi
done
