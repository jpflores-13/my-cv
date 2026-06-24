## JP Flores CV Workflow

Personal CV built with [Quarto](https://quarto.org) and backed by Google Sheets as the data source.

Live at: [jpflores-13.github.io/my-cv](https://jpflores-13.github.io/my-cv)

## Structure

- `index.qmd` — CV document. Reads from Google Sheets, renders to `docs/index.html`.
- `_quarto.yml` — Quarto project config (outputs to `docs/`).
- `cv-styles.css` — Full design system CSS (tokens, layout, print styles).
- `R/cv_functions.R` — Helper functions: `print_section`, `print_articles_by_field`, `render_md`.
- `gather_data.R` — Loads CV data from Google Sheets.
- `jpflores-cv-design/` — Design system reference (tokens, components, UI kit).
- `docs/` — Built output served by GitHub Pages.

## Data

CV content lives in a [Google Sheet](https://docs.google.com/spreadsheets/d/1kzVjmxlzmNsFXYa_A9A6OpZcMWZC1zOY62Ra5Xd9OPE/). The `entries` tab includes four classification columns added in 2026: `field`, `type`, `status`, `author_role`. Academic Articles are grouped by `field` (Science · Policy & Outreach · Qualitative) with client-side filter buttons.

## Rendering

Rendering happens automatically in CI, no need to render locally or commit `docs/`.

**If you updated a `.qmd` or other source file:**
```bash
git add <changed files>
git commit -m "your message"
git push
```
GitHub Actions will render and deploy on push to `master`.

**If you only updated the Google Sheet:**
No commit needed. The workflow re-renders automatically every Monday at 8am. To trigger it immediately, go to the repo's **Actions tab** → "Publish CV" → **Run workflow**.

**To preview locally before pushing:**
```bash
quarto preview
```

## PDF

Click **Download PDF** in the sidebar, or use the browser's print dialog. Filter buttons and other screen-only elements are hidden automatically via `@media print`.

## Credits

Original pagedown scaffold by [Nick Strayer](https://github.com/nstrayer/cv). Rebuilt as a Quarto site in 2026.
