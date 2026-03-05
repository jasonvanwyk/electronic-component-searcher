# Electronic Component Searcher

Claude Code skills for automating electronic component sourcing across SA local and international distributors.

## Project Structure

```
skills/find-part/          # /find-part skill — unified component search
  SKILL.md                 # Skill definition (YAML frontmatter + instructions)
  references/              # Grounding data for the skill
    suppliers.md           # Per-supplier search methods and quirks
    sa-import-costs.md     # SA import overhead formula
    known-pricing.md       # Verified spot-check prices for sanity-checking
docs/supplier-research.md  # Full research export (reference only)
install.sh                 # Install skills to ~/.claude/skills/
```

## Development

- Skills are pure markdown — no build step
- Install with `bash install.sh find-part`
- Test by restarting Claude Code and running `/find-part <MPN or description>`

## Conventions

- All ZAR prices shown ex-VAT unless noted
- Use `R` prefix: R12.50
- International prices shown in USD with ZAR equivalent
- Supplier searches run in parallel via WebSearch/WebFetch
