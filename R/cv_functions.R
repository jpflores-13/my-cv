library(dplyr)
library(glue)
library(htmltools)

# Convert [text](url) and **bold** markdown to HTML
render_md <- function(text) {
  if (is.na(text) || text == "" || text == "N/A") return("")
  text <- gsub("\\*\\*(.+?)\\*\\*", "<strong>\\1</strong>", text, perl = TRUE)
  text <- gsub("\\[([^]]+)\\]\\(([^)]+)\\)",
               '<a href="\\2" target="_blank">\\1</a>', text, perl = TRUE)
  text
}

# Build "end–start" timeline string per design system date format
make_timeline <- function(start, end) {
  s <- if (is.na(start)) NA_character_ else as.character(start)
  e <- if (is.na(end))   NA_character_ else as.character(end)
  if (is.na(s) || s == e) {
    if (is.na(e)) "" else e
  } else {
    paste0(e, "–", s)
  }
}

# Render a single CV entry as an HTML string
entry_html <- function(title, org, loc, timeline, bullets, badge = NULL) {
  title_h <- render_md(title)
  org_h   <- render_md(org)

  loc_span <- if (!is.na(loc) && nzchar(trimws(loc)))
    paste0(' <span class="entry-loc">· ', loc, "</span>")
  else ""

  valid_b <- bullets[!is.na(bullets) & nzchar(trimws(bullets))]
  bullets_html <- if (length(valid_b) > 0) {
    items <- paste0("<li>", sapply(valid_b, render_md), "</li>", collapse = "\n")
    paste0('<ul class="entry-bullets">', items, "</ul>")
  } else ""

  badge_html <- if (!is.null(badge))
    paste0('<span class="article-badge badge-', badge$cls, '">', badge$label, '</span>')
  else ""

  paste0(
    '<div class="entry">',
    '<div class="entry-date">', timeline, '</div>',
    '<div class="entry-content">',
    '<div class="entry-title">', title_h, badge_html, '</div>',
    '<div class="entry-org">', org_h, loc_span, '</div>',
    bullets_html,
    '</div>',
    '</div>'
  )
}

# Print all entries in a section, newest first — returns htmltools::HTML
print_section <- function(data, section_id) {
  rows <- data %>%
    filter(section == section_id) %>%
    arrange(desc(end))

  if (nrow(rows) == 0) return(HTML(""))

  desc_cols <- grep("^description_", names(rows), value = TRUE)
  parts     <- character(nrow(rows))

  for (i in seq_len(nrow(rows))) {
    row     <- rows[i, ]
    bullets <- unlist(row[desc_cols])
    parts[i] <- entry_html(
      title    = row$title,
      org      = row$institution,
      loc      = row$loc,
      timeline = make_timeline(row$start, row$end),
      bullets  = bullets
    )
  }

  HTML(paste(parts, collapse = "\n"))
}

# Print Academic Articles grouped by field — returns htmltools::HTML
print_articles_by_field <- function(data) {
  articles  <- data %>%
    filter(section == "academic_articles") %>%
    arrange(desc(end))

  desc_cols <- grep("^description_", names(articles), value = TRUE)
  output    <- character(0)

  for (fld in c("Science", "Policy & Outreach", "Qualitative")) {
    group <- articles %>% filter(field == fld)
    if (nrow(group) == 0) next

    parts <- character(nrow(group))
    for (i in seq_len(nrow(group))) {
      row     <- group[i, ]
      bullets <- unlist(row[desc_cols])
      is_first  <- !is.na(row$author_role) & row$author_role == "first"
      badge     <- if (is_first) list(cls = "first", label = "First author") else NULL
      parts[i] <- entry_html(
        title    = row$title,
        org      = row$institution,
        loc      = row$loc,
        timeline = as.character(row$end),
        bullets  = bullets,
        badge    = badge
      )
    }

    output <- c(
      output,
      paste0('<div class="field-group" data-field="', fld, '">'),
      paste0('<div class="field-label">', fld, '</div>'),
      parts,
      '</div>'
    )
  }

  HTML(paste(output, collapse = "\n"))
}

# Inline Lucide SVG icon for the sidebar contact list
lucide_icon <- function(name, size = 13) {
  if (name == "bluesky") {
    return(paste0(
      '<svg xmlns="http://www.w3.org/2000/svg" width="', size, '" height="', size,
      '" viewBox="0 0 24 24" fill="currentColor">',
      '<path d="M12 10.8c-1.087-2.114-4.046-6.053-6.798-7.995C2.566.944 1.561 1.26.828 1.677.116 2.098-.023 2.54.004 3.52c.03 1.044.114 4.14.285 5.243.542 3.51 2.496 4.553 4.494 4.777 3.124.355 5.898-1.278 5.898-1.278-.028.27-.062.54-.084.808C10.32 16.127 8.1 17.51 5.9 19.4c-1.067.915-1.64 2.28-1.64 3.6 0 2.21 1.79 4 4 4 1.655 0 3.08-.998 3.72-2.432C12.64 23.003 12.91 22 12.91 22h.18s.27 1.003.93 2.568C14.66 25.002 16.085 26 17.74 26c2.21 0 4-1.79 4-4 0-1.32-.573-2.685-1.64-3.6-2.2-1.89-4.42-3.273-4.697-6.248-.022-.268-.056-.538-.084-.808 0 0 2.774 1.633 5.898 1.278 1.998-.224 3.952-1.267 4.494-4.777.171-1.103.255-4.199.285-5.243.027-.98-.112-1.422-.824-1.843-.733-.417-1.738-.733-4.374 1.128C14.047 4.747 13.087 8.686 12 10.8Z"/>',
      '</svg>'
    ))
  }
  icons <- list(
    mail     = '<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,12 2,6"/>',
    github   = '<path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/>',
    link     = '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>',
    linkedin = '<path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z"/><rect x="2" y="9" width="4" height="12"/><circle cx="4" cy="4" r="2"/>',
    twitter  = '<path d="M23 3a10.9 10.9 0 0 1-3.14 1.53 4.48 4.48 0 0 0-7.86 3v1A10.66 10.66 0 0 1 3 4s-4 9 5 13a11.64 11.64 0 0 1-7 2c9 5 20 0 20-11.5a4.5 4.5 0 0 0-.08-.83A7.72 7.72 0 0 0 23 3z"/>'
  )
  inner <- if (!is.null(icons[[name]])) icons[[name]] else icons[["link"]]
  paste0(
    '<svg xmlns="http://www.w3.org/2000/svg" width="', size, '" height="', size,
    '" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"',
    ' stroke-linecap="round" stroke-linejoin="round">', inner, '</svg>'
  )
}
