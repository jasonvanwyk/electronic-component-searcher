---
name: find-part
description: >
  Search for electronic components across SA local and international distributors.
  Returns pricing, stock status, and supplier URLs in a comparison table.
  Triggers: find part, search component, price check, stock check, MPN lookup,
  component search, find component, part search, source component
---

# Find Part — Electronic Component Search

You search for electronic components across multiple suppliers and present a unified comparison. You have access to reference files in the `references/` directory for supplier-specific search methods, SA import cost calculations, and known pricing for sanity-checking results.

## Input Formats

The argument can be:

1. **Single part** — MPN, LCSC code, or description:
   - `/find-part AMS1117-3.3`
   - `/find-part C701341`
   - `/find-part 0603 100nF capacitor`

2. **Comma-separated list** — multiple MPNs or LCSC codes:
   - `/find-part AMS1117-3.3, ESP32-WROOM-32E, PESD5V0S1BA`

3. **File path** — a `.csv`, `.xlsx`, or `.ods` file containing a BOM or parts list:
   - `/find-part /path/to/bom.csv`
   - `/find-part ~/projects/fairfield/bom.xlsx`

### File Parsing

When given a file path:
1. Use the Bash tool to inspect the file: `libreoffice --headless --convert-to csv <file> --outdir /tmp` for `.xlsx`/`.ods`, or read directly for `.csv`
2. Look for columns that contain part numbers — common headers: `MPN`, `Part Number`, `Manufacturer Part`, `Component`, `Value`, `LCSC`, `Digi-Key`
3. If no obvious MPN column, look for a `Description` or `Value` column and use those as search terms
4. Extract the list of unique parts to search
5. If there's a `Qty` or `Quantity` column, include quantities in the output
6. Ask the user to confirm the parsed parts list before searching if more than 10 parts are found

### Multi-Part Behaviour

When searching multiple parts:
- Search parts sequentially (one at a time) to avoid rate-limiting on supplier endpoints
- Present results for each part under its own heading: `## Part 1: AMS1117-3.3`
- After all parts, add a **Summary** section with a consolidated table showing the best price per part
- If quantities are known, calculate extended costs (qty × unit price) in the summary

## Process

### 1. Parse the Query

Determine if the argument is:
- **A file path** — ends in `.csv`, `.xlsx`, `.ods`, or starts with `/` or `~/` → see File Parsing above
- **A comma-separated list** — contains commas → split and search each part
- **An MPN** (manufacturer part number) — e.g., `AMS1117-3.3`, `ESP32-WROOM-32E`, `PESD5V0S1BA`
- **An LCSC code** — e.g., `C701341`, `C6186` (starts with `C` followed by digits)
- **A description** — e.g., `0603 100nF capacitor`, `SOT-223 3.3V LDO`

For descriptions, extract key parameters: package/footprint, value, voltage rating, tolerance.

### 2. Search All Suppliers in Parallel

Run ALL of these searches concurrently (they are independent):

**Communica (local):**
1. WebFetch `https://www.communica.co.za/search/suggest.json?q=<term>&resources[type]=product`
2. Parse the JSON response for matching products
3. If no results or endpoint fails, fall back to WebSearch `site:communica.co.za <term>`
4. Prices returned include VAT — divide by 1.15 for ex-VAT

**Mantech (local):**
1. WebSearch `site:mantech.co.za <term>`
2. Look for `ProductInfo.aspx?Item=<code>` URLs in results
3. WebFetch the top 1-2 product page URLs to extract pricing
4. Look for price information in the page content (Label20/21/23 are tiered prices)
5. Prices are already ex-VAT

**Octopart (international aggregator):**
1. WebSearch `octopart.com <MPN or description>`
2. Extract whatever pricing/stock data is visible in the search result snippets
3. Do NOT WebFetch octopart.com — it returns 403. Rely on search snippets only.
4. If snippets mention specific distributors and prices, include them. Otherwise report "See Octopart link for details"
5. Covers Digi-Key, Mouser, RS Components, Farnell, Arrow
6. Does NOT cover Communica, Mantech, or LCSC

**LCSC (international):**
1. WebSearch `lcsc.com <MPN or LCSC code>`
2. WebFetch the product page for pricing and stock
3. Prices in USD — convert to ZAR using current rate (~R16.50/USD as of March 2026)

### 3. Format Results

Present results in two sections:

#### Local Suppliers (no import costs)

| Supplier | Part | Price (ex-VAT) | Stock | URL |
|----------|------|---------------|-------|-----|
| Communica | ... | R... | In stock / Sold out | ... |
| Mantech | ... | R... | Unknown | ... |

#### International Suppliers (add import overhead)

| Supplier | Part | Unit Price | ZAR equiv | Stock | URL |
|----------|------|-----------|-----------|-------|-----|
| Digi-Key (via Octopart) | ... | $... | R... | 1,234 | ... |
| LCSC | ... | $... | R... | 5,000 | ... |

**Notes on international pricing:**
- ZAR equivalent is the unit price converted at current exchange rate (NOT landed cost)
- Add ~30% import overhead + R400 clearance fee per shipment for true landed cost
- See `references/sa-import-costs.md` for the full formula

### 4. Recommendation

After the tables, provide:

1. **Best local price** — cheapest in-stock option from Communica/Mantech
2. **Best international price** — cheapest from Octopart/LCSC distributors
3. **LCSC landed cost note** — if LCSC is cheapest, estimate landed cost: `unit price × R16.50 × 1.30 + R400/N` where N is number of line items in a typical order
4. **Package/footprint warnings** — flag if results include different packages (e.g., SOD-882 vs SOD-323, TO-220 vs SOT-223)
5. **Stock warnings** — note if Mantech stock is unknown, or if any supplier shows low stock

### 5. Sanity Check

Compare results against `references/known-pricing.md`. If a live price is more than 2x different from the known price for the same part, flag it:
> ⚠️ Price for [part] from [supplier] (R[price]) is significantly different from known March 2026 price (R[known]). Verify manually.

## Important Notes

- Always search ALL four sources (Communica, Mantech, Octopart, LCSC) — even if one seems unlikely to have the part. Surprising results are valuable.
- If a search returns no results for a supplier, show "No results" in the table rather than omitting the row.
- For description-based searches, try multiple search term variations if the first attempt returns poor results (e.g., try both "100nF 0603" and "0603 100N capacitor").
- Communica's Shopify JSON may rate-limit or block — if WebFetch fails on the suggest endpoint, fall back to WebSearch immediately without retrying.
- Never fabricate pricing data. If you can't extract a price from a page, say "Price not extracted" rather than guessing.
