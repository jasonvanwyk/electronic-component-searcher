# Supplier Search Reference

## Local Suppliers (ZAR, no import costs)

### Communica (communica.co.za)

**Platform:** Shopify
**Search method:** Shopify JSON API (primary), WebSearch fallback

**Primary — Shopify suggest endpoint:**
```
GET https://www.communica.co.za/search/suggest.json?q=<term>&resources[type]=product
```
Returns JSON with product suggestions including title, price (inc-VAT — divide by 1.15 for ex-VAT), availability, URL, and image.

**Fallback — product page JSON:**
Append `.json` to any product URL to get structured data.

**WebSearch fallback:**
```
site:communica.co.za <search term>
```

**Pricing notes:**
- Online prices include VAT — divide by 1.15 for ex-VAT
- Part numbering: CHC0603 = chip capacitor 0603, CHR0603 = chip resistor 0603

**Stock visibility:** "Sold Out" or available (no quantity counts)

**Strengths:** Common passives (0603 caps, resistors), LEDs, TH diodes, switches
**Weaknesses:** No bare IC modules, no SMD TVS diodes, no LDO regulators, no tantalum caps

---

### Mantech (mantech.co.za)

**Platform:** Legacy ASP.NET WebForms — no API, no JSON
**Search method:** Google `site:` search (their native search is broken)

**Search approach:**
1. WebSearch: `site:mantech.co.za <search term>`
2. Look for `ProductInfo.aspx?Item=<stock-code>` URLs in results
3. WebFetch the product page to extract details

**Product page structure (HTML labels):**
| Label ID | Content |
|----------|---------|
| Label1 | Stock code |
| Label3 | Description |
| Label5 | Manufacturer |
| Label7 | Unit |
| Label8 | MOQ |
| Label9 | Detailed description |
| Label20 | Price tier 1 |
| Label21 | Price tier 2 |
| Label23 | Price tier 3 |

**Pricing notes:**
- All prices ex-VAT
- Tiered volume pricing displayed on product pages

**Stock visibility:** NONE — no in-stock/out-of-stock indicator anywhere on the site

**Strengths:** Voltage regulators (AMS1117), slide switches, TH passives, 118K+ products
**Weaknesses:** Broken native search, no stock visibility, some SMD parts reel-only (5,000pc MOQ)

**Tip:** Look for `*DBK*` (debulk) variants for smaller quantities of SMD parts.

---

## International Suppliers (convert to ZAR, add import overhead)

### Octopart (octopart.com) — Aggregator

**Coverage:** 679 distributors including Digi-Key, Mouser, RS Components, Farnell, Arrow, Avnet
**Does NOT cover:** Communica, Mantech, LCSC

**Search method:**
1. WebSearch: `octopart.com <MPN>`
2. WebFetch the product page to extract distributor pricing

**What you get:** Real-time stock, quantity-adjusted pricing, datasheets, lifecycle status, distributor URLs

**Pricing notes:**
- Shows prices from multiple distributors
- Prices typically in USD — convert to ZAR
- Add SA import overhead (29-35%) for landed cost — see `sa-import-costs.md`

---

### LCSC (lcsc.com) — Direct

**Coverage:** 560,000+ SKUs, tight integration with JLCPCB
**Strengths:** Dramatically cheaper for semiconductors, bare modules, SMD passives

**Search method:**
1. WebSearch: `lcsc.com <MPN or LCSC part number>`
2. WebFetch the product page for pricing and stock

**Pricing notes:**
- All prices in USD
- Add shipping ($15-50 depending on method) + SA import overhead
- For small orders: add ~R400 clearance fee per shipment
- See `sa-import-costs.md` for full landed cost calculation

**LCSC part numbers:** Format `C######` (e.g., C701341 for ESP32-WROOM-32E)
