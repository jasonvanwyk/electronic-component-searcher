# Procurement Research Export — Component Sourcing Workflow

**Project:** Fairfield Dairy Phase 2 — IoT Water Monitoring
**Date:** 5 March 2026
**Purpose:** Context export for building Claude Code skills, APIs, and MCPs for electronic component sourcing and procurement workflow automation.

---

## 1. Problem Statement

We're building 24 IoT PCBs (4 variants × 6 boards) for water monitoring. The BOM has ~35 line items spanning passives, semiconductors, connectors, and modules. Current procurement is manual: email a spreadsheet to a distributor, wait for a quote, get back broken data (text in price columns, wrong products quoted), and repeat.

**Pain points discovered:**
- Local SA distributors (Communica, Mantech) don't stock ~30% of what we need (specialist SMD semiconductors, bare IC modules, specific TVS diodes, LDO regulators)
- When they do quote, they sometimes quote the wrong product entirely (dev boards instead of bare modules, PoE shields instead of breakout boards)
- No stock visibility on Mantech (you find out after ordering)
- Mantech's native search is broken (returns unrelated products)
- Prices vary 2-10× between suppliers for the same component
- Manual cross-checking across 4-6 supplier websites takes hours
- BOM quantity rollups had arithmetic errors that weren't caught until audit

**Goal:** Build tooling (Claude Code skills, MCP servers, API integrations) to automate and streamline component sourcing for small-run electronics projects.

---

## 2. SA Supplier Landscape

### 2.1 Local Distributors

#### Communica (communica.co.za)

| Property | Detail |
|----------|--------|
| Platform | **Shopify** |
| Search | Works reasonably well |
| Pricing | Visible online (inc/ex VAT) |
| Stock visibility | "Sold Out" or available (no quantities) |
| API potential | **Shopify JSON endpoints**: `/products.json`, `/search/suggest.json?q=<term>&resources[type]=product`, `/collections/<name>/products.json`, append `.json` to any product URL |
| Part numbering | Logical: CHC0603 = Chip Capacitor 0603, CHR0603 = Chip Resistor 0603 |
| Strengths | Common passives (0603 caps R0.36, resistors R0.10), LEDs, TH diodes, switches |
| Weaknesses | No bare IC modules, no SMD TVS diodes, no LDO regulators, no tantalum caps |
| Contact | Bongi Ntuli, bongin@communicagroup.com, +27 12 657 3500 |

**Shopify API endpoints (standard, likely accessible):**
```
GET https://www.communica.co.za/products.json?limit=250&page=1
GET https://www.communica.co.za/search/suggest.json?q=0603&resources[type]=product
GET https://www.communica.co.za/collections/passive-components/resistors/products.json
GET https://www.communica.co.za/products/<handle>.json
```

Returns structured JSON: title, price, variants, availability, images, tags.

#### Mantech (mantech.co.za)

| Property | Detail |
|----------|--------|
| Platform | **Legacy ASP.NET WebForms** (custom) |
| Search | **Broken** — searches stock codes, not descriptions. "1N5819" returns telephone cables. |
| Pricing | Visible online (ex-VAT, tiered volume breaks) |
| Stock visibility | **None** — no in-stock/out-of-stock indicators anywhere |
| API potential | **None** — VIEWSTATE postbacks, no REST API, no JSON. Sitemap has 118,627 product URLs. |
| Product URLs | `ProductInfo.aspx?Item=<stock-code>` (e.g., `?Item=64M0054`) |
| Workaround | Google `site:mantech.co.za <part description>` works well |
| Catalogue size | 118,627 products across 3 sitemaps |
| Strengths | Voltage regulators (AMS1117 R4.35), slide switches (SPDT TH R1.68), TH passives |
| Weaknesses | Broken search, no stock visibility, SMD passives often reel-only (5,000pc) |

**HTML scraping approach (if needed):**
- Product pages have predictable label IDs: Label1=stock code, Label3=description, Label5=manufacturer, Label7=unit, Label8=MOQ, Label9=detailed description, Label20/21/23=tiered prices
- Sitemap URLs: `sitemap1.xml`, `sitemap2.xml`, `sitemap3.xml`
- All 118,627 products fetchable via `ProductInfo.aspx?Item=<code>`

### 2.2 International Distributors

#### RS Components SA (za.rs-online.com)

| Property | Detail |
|----------|--------|
| Delivery | Next-day for local stock; 4-6 days from UK |
| Pricing | ZAR, visible online |
| Catalogue | 800,000+ products |
| Strengths | Genuine JST-PH connectors (545+ in stock), specialist parts, local warehouse |
| In aggregators | Yes — included in Octopart, KiCost |

#### Digi-Key (digikey.co.za)

| Property | Detail |
|----------|--------|
| Shipping | Free over R2,000; R600 under threshold |
| Delivery | ~4 days from USA |
| Import | CPT — duty/VAT/clearance due at delivery |
| Strengths | Bare ESP32 modules (~R79), massive catalogue, no MOQ |
| In aggregators | Yes — Octopart, KiCost |

#### Mouser (mouser.co.za)

| Property | Detail |
|----------|--------|
| Shipping | Similar to Digi-Key |
| Delivery | 3-5 days from USA via DHL/FedEx |
| SA Partner | TRX Electronics (Pretoria, Cape Town, Durban) |
| In aggregators | Yes — Octopart, KiCost |

#### LCSC (lcsc.com)

| Property | Detail |
|----------|--------|
| Ships to SA | Yes — DHL, FedEx, EMS, Singapore Post |
| Shipping cost | Weight-based, typically $15-30 (economy), $25-50 (DHL Express) |
| Delivery | 5-10 days (economy), 3-5 days (DHL Express) |
| Catalogue | 560,000+ SKUs |
| Strengths | **Dramatically cheaper** — ESP32 bare module $2.55 (R42), AMS1117 $0.16 (R1.80), PESD5V0S1BA $0.04 (R0.66) |
| Integration | Tight integration with JLCPCB for turnkey assembly |
| API | Has an API (details at lcsc.com) |

#### Farnell / element14 (export.farnell.com)

| Property | Detail |
|----------|--------|
| SA access | export.farnell.com/welcome-south-africa |
| Delivery | ~3 days from UK |
| Support | On-the-ground sales support in SA |
| In aggregators | Yes — Octopart, KiCost |

---

## 3. Aggregator Tools & APIs

### 3.1 Octopart (octopart.com) — Primary Recommendation

| Property | Detail |
|----------|--------|
| Owner | Altium (acquired 2015), part of Nexar platform |
| Coverage | **679 distributors**, 11,130 manufacturers, 83M+ components, 208M offers daily |
| Distributors | Digi-Key, Mouser, RS Components, Farnell, element14, Arrow, Avnet, TME, Newark, etc. |
| Does NOT include | Communica, Mantech (no API/data feed from these) |
| Features | Real-time stock, quantity-adjusted pricing, parametric search, datasheets, lifecycle status |
| BOM Tool | Free — upload CSV/Excel, auto-match MPNs, colour-coded lifecycle, preferred distributors |
| Octocart | Converts BOM into pre-filled shopping carts on distributor websites |
| Cost | **Free for web search and BOM tool** |
| API | **Nexar API** (nexar.com) — free evaluation tier of 1,000 lifetime part lookups. Paid tiers for higher volumes (contact nexar.com/compare-plans). GraphQL-based. |
| URL | octopart.com/bom-tool |

**Nexar API (programmatic access to Octopart data):**
- GraphQL API
- Endpoint: nexar.com/api
- Free tier: 1,000 lifetime lookups
- Returns: pricing, stock, specs, datasheets, lifecycle, distributor links
- Can query by MPN (Manufacturer Part Number)

### 3.2 FindChips (findchips.com)

| Property | Detail |
|----------|--------|
| Owner | Supplyframe |
| Coverage | 20+ distributors (Digi-Key, Mouser, Arrow, Avnet) |
| BOM tool | Yes, less polished than Octopart |
| Best for | Quick single-part stock checks, Asian market suppliers |
| Cost | Free, no registration for basic searches |

### 3.3 KiCost — KiCad Direct Integration

| Property | Detail |
|----------|--------|
| Type | Open source Python tool |
| Install | `pip install kicost` |
| Usage | `kicost -i bom.xml --num 24` |
| Input | KiCad schematic BOM XML |
| Queries | Digi-Key, Mouser, Farnell, RS Components, Arrow, Newark, TME |
| Output | Excel spreadsheet with per-distributor pricing, stock, price breaks, total board cost |
| GitHub | github.com/hildogjr/KiCost |
| Listed on | kicad.org/external-tools/kicost/ |

**Key requirement:** KiCad schematic components need MPN (Manufacturer Part Number) fields populated for KiCost to match parts.

### 3.4 Other Tools

| Tool | Type | Best For |
|------|------|----------|
| **KiBoM** (github.com/SchrodingersGat/KiBoM) | BOM generator | Clean, grouped BOMs from KiCad (no pricing) |
| **KiABOM** (github.com/Mage-Control-Systems-Ltd/KiABOM) | KiCost wrapper | Auto BOM with order codes and prices |
| **PartsBox** (partsbox.com) | Inventory + BOM + production | Track physical stock, manage builds. Free hobbyist tier. KiCad import. |
| **SnapEDA/SnapMagic** (snapeda.com) | CAD symbols + footprints | Shows some pricing alongside CAD data |
| **Component Search Engine** (componentsearchengine.com) | CAD library | Free KiCad symbols/footprints, some distributor data |

---

## 4. SA Import Considerations

| Factor | Detail |
|--------|--------|
| WTO ITA member | **No** — SA does not benefit from zero-duty on IT/electronic components |
| Import duty | 0-15% (typically 0-5% for HS 8541/8542 discrete semiconductors) |
| VAT | 15% on (customs value + 10% uplift + duty) |
| Clearance fee | R300-500 per shipment (charged by courier) |
| De minimis | Effectively R0 — all imports attract duty/VAT |
| Strategy | Consolidate into fewer shipments to minimise clearance fees |

**Example: R3,280 component order landed cost:**
- Customs value: R3,280
- +10% uplift: R3,608
- Duty (0-5%): R0-180
- VAT (15%): ~R541-568
- Clearance: ~R400
- **Overhead: ~R941-1,148 (29-35% on top of goods value)**

---

## 5. Optimal Procurement Strategy

### Split by supplier capability:

| Source | Components | Why |
|--------|-----------|-----|
| **LCSC** | Bare ESP32 modules, TVS diodes, LDO regulators, tantalum caps | 3-10× cheaper than local, large stock |
| **AliExpress** | W5500 breakout modules, PoE splitters | Commodity modules, not stocked by major distributors at reasonable prices |
| **Communica** (walk-in or web) | 0603 passives, TH resistors/caps, LEDs, common diodes (1N5819, SS14) | Local stock, fast, no import costs |
| **Mantech** (email BOM or walk-in) | Voltage regulators, slide switches, ceramic caps | Better prices on some items than Communica |
| **RS Components SA** | Genuine JST-PH connectors, specialist parts | Local warehouse, genuine parts, next-day |

### Price comparison summary (specialist components):

| Component | Communica | Digi-Key | **LCSC** | Saving vs local |
|-----------|-----------|----------|----------|----------------|
| ESP32-WROOM-32E bare | R134.78 (wrong product) | R79 | **R42** | 69% |
| W5500 module | R939.13 (wrong product) | R119 | **R50-80** (Ali) | 92-95% |
| AMS1117-3.3 | No bid | R4.40 | **R1.80** | — |
| LM1117T-3.3 | No bid | R25 | **R15** | — |
| PESD5V0S1BA SOD-323 | No bid | R4.90 | **R0.66** | — |
| 100µF tantalum | No bid | R13-25 | **R5-10** | — |
| PoE splitter 5V | R169 | R245 | **R50-100** (Ali) | 41-70% |

---

## 6. Tooling Opportunities (for the new project)

### 6.1 MCP Servers to Build

**Component Search MCP** — unified interface across suppliers:
- **Octopart/Nexar API** integration (GraphQL, 679 distributors)
- **Communica** Shopify JSON scraping (structured, reliable)
- **Mantech** HTML scraping (fragile but feasible — 118K products, predictable labels)
- **LCSC API** integration
- **RS Components SA** (check if they have an API)

**BOM Management MCP:**
- Upload/parse KiCad BOM XML or CSV
- Cross-reference against multiple suppliers simultaneously
- Track quantities needed vs quoted vs ordered
- Flag lifecycle issues (EOL/NRND)
- Calculate landed costs including SA import duty/VAT

### 6.2 Claude Code Skills to Build

**`/find-part <description or MPN>`** — search across all configured suppliers:
- Return pricing, stock, package info, datasheet links
- Highlight best price and local availability
- Flag package mismatches (e.g., SOD-882 vs SOD-323)

**`/price-bom <bom-file>`** — automated BOM pricing:
- Parse KiCad BOM XML, CSV, or Excel
- Query all suppliers via MCP
- Generate comparison spreadsheet
- Calculate per-board and total project cost
- Flag items with no local stock (suggest international alternatives)

**`/check-stock <supplier> <part-list>`** — real-time stock check:
- Query specific supplier for list of parts
- Return availability, pricing tiers, MOQs
- For Mantech: use Google `site:` search as fallback

**`/landed-cost <order-value> [duty-rate]`** — SA import cost calculator:
- Input: order value in USD/EUR/GBP
- Calculate: customs value + 10% uplift + duty + 15% VAT + clearance fee
- Output: total landed cost in ZAR

**`/procurement-split <bom-file>`** — optimal supplier allocation:
- Analyse BOM against all supplier inventories
- Recommend which items to buy from which supplier
- Minimise total cost including shipping and import overhead
- Consolidate international orders to reduce clearance fees

### 6.3 API Integrations Needed

| API | Type | Auth | Priority |
|-----|------|------|----------|
| Nexar/Octopart | GraphQL | API key (free tier: 1,000 lookups) | High |
| LCSC | REST (investigate) | TBD | High |
| Communica (Shopify) | REST (JSON endpoints) | None (public) | Medium |
| Digi-Key | REST API v4 | OAuth2 (developer account) | Medium |
| Mouser | REST API | API key (free registration) | Medium |
| RS Components | REST API (if available) | TBD | Low |
| Mantech | HTML scraping | None | Low (fragile) |

### 6.4 Data Model Considerations

**Component:**
- MPN (manufacturer part number) — primary key for matching
- Description, value, package/footprint
- Multiple supplier entries (price, stock, MOQ, lead time, URL)
- Lifecycle status (active, NRND, EOL)
- Datasheet URL

**BOM Line Item:**
- Reference designators (R1, C3, U1, etc.)
- Component reference (MPN)
- Quantity per board
- Quantity total (boards × per-board + spares)
- Preferred supplier + alternatives

**Order:**
- Supplier
- Line items with quantities and unit prices
- Shipping method and cost
- Import duty estimate
- VAT estimate
- Clearance fee
- Total landed cost

---

## 7. Reference Pricing Data (March 2026)

### Communica Confirmed Prices (ex-VAT)

| Part | Communica SKU | Price |
|------|--------------|-------|
| 100nF 50V X7R 0603 | CHC0603 100N X7R 50V | R0.36 |
| 1µF 16V X5R 0603 | CHC0603 1U0 X5R 16V | R0.48 |
| 10kΩ 1% 0603 | CHR0603 1% 10K | R0.10 |
| 1kΩ 1% 0603 | CHR0603 1% 1K | R0.10 |
| 10kΩ ¼W 1% metal film | MFR25F-10K | R0.35 |
| 100µF 16V electrolytic | 100UF 16VR | R0.50 |
| Green LED 3mm TH | L-934GD | R1.70 |
| SS14 Schottky SMA | SS14 | R1.20 |
| 1N5819 DO-41 | 1N5819 | R0.80 |
| Tactile SMD 3.5×6mm | DTSM32N | R3.11 |
| Tactile TH 6×6mm | TC0106X | R1.65 |
| 40-pin header strip | 608401 | R6.00 |
| PoE splitter Micro USB | POE SPLITTER MICRO USB PST | R169.00 |

### Mantech Confirmed Prices (ex-VAT)

| Part | Mantech Code | Price |
|------|-------------|-------|
| 100nF 0603 (Yageo) | CC0603KRX7R7BB104 | R0.23 |
| 100µF 10V tantalum | MTAP100UF/10V | R9.67-10.51 |
| 10µF 16V ceramic 0805 (Murata) | GRM21BR61C106KE15L | R4.53 |
| 100µF 10V electrolytic | E.CAP 100UF/10V | R0.33 |
| AMS1117-3.3 SOT-223 | 15M2287 | R4.35-4.73 |
| LD1117V33C TO-220 | 35M0998 | R4.49-4.88 |
| 1N5819-BP | 64M0054 | R0.90 |
| Green LED 0603 | CZ-0603YGD-6 / 35M1179 | R0.41 |
| SPDT slide switch SMD | DJS1270 | R3.00 |
| SPDT slide switch TH | SS-12F23 / 72M4455 | R1.68 |

### LCSC Reference Prices (USD, ex-VAT)

| Part | LCSC Code | USD | ~ZAR |
|------|----------|-----|------|
| ESP32-WROOM-32E-N4 | C701341 | $2.55 | R42 |
| W5500 bare IC | C32843 | $1.88 | R31 |
| AMS1117-3.3 | C6186 | $0.16 | R2.60 |
| LM1117T-3.3/NOPB | C201726 | $0.89-1.30 | R15-21 |
| PESD5V0S1BA,115 (Nexperia, SOD-323) | C19224 | $0.04 | R0.66 |

---

## 8. Known Issues / Flags

1. **PESD5V0S1BL is SOD-882 (DFN1006), not SOD-323** — the SOD-323 variant is **PESD5V0S1BA**. Verify KiCad schematic footprint before ordering.

2. **100µF 10V tantalum in 1206 (Type A)** — may not exist at that capacitance/voltage. More commonly Type B (3528 metric). Check if footprint needs updating.

3. **1.5KE5.0CA (5.0V standoff)** — uncommon variant. The **1.5KE6.8CA** is widely stocked. Verify circuit tolerates 6.8V standoff.

4. **Communica JST-PH connectors** — Bongi quoted R0.45 for "2-pin" but noted "THROUGH HOLE" — likely generic headers, not genuine JST-PH keyed connectors. RS Components SA has genuine B2B-PH-K-S (545+ in stock).

5. **Mantech "reel-only" SMD parts** — some 0603 resistors only sold in 5,000pc reels (R154.90). Look for `*DBK*` (debulk) variants for smaller quantities.

---

*Exported from Fairfield Water project — 5 March 2026*
*For use as context in component sourcing tooling project*
