# Where Jev could help: `/find-part` match decisions

26 October 2026. Background and the general pattern:
`~/tools/jev-tools/docs/research/2026-10-26-jev-ultrafast-component-tools.md`.

## The gap

The skill is markdown only, so Claude makes every judgement: which BOM
column is the MPN (`SKILL.md:35`), which search results are the right part
(`:67`), whether the package differs (`:121`), and whether a price looks
sane (`:127`). The full BOM test (STATUS) gave 6 warnings: wrong products
quoted, package mismatches and uncommon variants.

## What Jev would do

Keep the fetch steps as they are. For each supplier's result list, number
the listings and call `jevq ask` with two questions:

| Question | Type | Options |
|---|---|---|
| `match` | Choice | `1`..`N` listings + `NONE` |
| `same_package` | Noul | "the chosen listing has the same package as the requested part" |

Claude then sees one table per part with Jev's probabilities. It reads the
listings and writes the summary only for rows below the threshold. Fewer
wrong products quoted, and fewer Claude tokens per BOM.

No code is needed: a `questions.json` next to the skill and one `jevq`
line in `SKILL.md`.

## What Jev would not do

- Rephrase a failed search (`:133`). That is text generation, so it stays
  with Claude.
- Judge whether a price is sane. That is arithmetic against known prices,
  so it belongs in code.

## Status

Idea only. **The 6 warnings from the full BOM test are the first labelled
eval cases.** Wire this after the `dk bom` eval in `~/tools/digikey_api`,
which tests the same "pick the right part or none" question.
