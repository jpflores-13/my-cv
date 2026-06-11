## JP Flores' pagedown CV

My personal CV and resume built with the [pagedown](https://pagedown.rbind.io) R package, using Google Sheets as the data source.

Live at: [jpflores-13.github.io/my-cv/cv.html](https://jpflores-13.github.io/my-cv/cv.html)

## Structure

- `cv.Rmd`: Source template for the full CV. Set `PDF_EXPORT` to `TRUE` for a PDF-ready version.
  - `cv.html`: Rendered HTML output.
  - `cv.pdf`: Exported PDF.
- `resume.Rmd`: Source template for the single-page resume.
  - `resume.html` / `resume.pdf`: Rendered resume outputs.
- `cv_printing_functions.R`: Helper functions for rendering position entries into HTML.
- `gather_data.R`: Loads CV data from Google Sheets (or CSVs as a fallback).
- `csvs/`: CSV versions of the data as a backup to Google Sheets.
- `css/`: Custom CSS files that modify the default pagedown resume template.

## Data

CV content is pulled from a Google Sheet. To use your own sheet, update `positions_sheet_loc` in the setup chunk of `cv.Rmd` and `resume.Rmd`.

## Rendering

Open `cv.Rmd` or `resume.Rmd` in RStudio and knit. To export a PDF, set `PDF_EXPORT <- TRUE` or use `pagedown::chrome_print()`.

## Credits

Built on the pagedown CV template originally created by [Nick Strayer](https://github.com/nstrayer/cv) and modified by [dcossyleon](https://github.com/dcossyleon/cv).
