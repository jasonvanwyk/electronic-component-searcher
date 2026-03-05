# SA Import Cost Reference

## Import Overhead Formula

For components ordered from international suppliers (LCSC, Digi-Key, Mouser, etc.):

```
Customs value       = order total in ZAR (use current exchange rate)
+ 10% uplift        = customs value × 1.10
+ Import duty       = uplifted value × duty rate (typically 0-5% for electronic components)
+ VAT               = (uplifted value + duty) × 15%
+ Clearance fee     = ~R400 per shipment (DHL/FedEx courier clearance)
= Total landed cost
```

**Typical overhead: 29-35% on top of goods value** (including clearance fee on a ~R3,000 order).

## Duty Rates for Electronic Components

| HS Code | Description | Typical Duty |
|---------|-------------|-------------|
| 8541 | Diodes, transistors, LEDs, discrete semiconductors | 0% |
| 8542 | ICs, microprocessors, memory, MCUs | 0% |
| 8532 | Capacitors | 0-5% |
| 8533 | Resistors | 0-5% |
| 8536 | Switches, connectors, fuses | 5-10% |
| 8534 | PCBs | 0-5% |

**Note:** SA is NOT a WTO ITA member, so no automatic zero-duty on IT products.

## Break-Even Guidance

LCSC orders make sense when:
- **Single component:** LCSC price is <50% of local price (to absorb per-item share of clearance fee)
- **Consolidated order >R2,000:** Clearance fee amortises well across many line items
- **Parts unavailable locally:** No break-even needed — LCSC/Digi-Key may be the only source

## Quick Estimate

For a rough landed cost estimate without detailed HS code lookup:
```
Landed cost ≈ USD price × exchange rate × 1.30 + (R400 ÷ number of line items)
```

The 1.30 multiplier covers the 10% uplift + ~3% average duty + 15% VAT.

## Exchange Rate

Use the current USD/ZAR rate. As of March 2026, approximately R16.50/USD.
Always check the live rate — this fluctuates significantly.
