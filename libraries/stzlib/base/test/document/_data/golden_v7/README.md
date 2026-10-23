# golden_v7 -- twenty realistic documents with known structure

This folder is an independent golden test set for document readers (Docling and the
Softanza native PDF reader). Each document `mNN` comes as three files:

- `mNN.html` -- the source page, written by hand
- `mNN.pdf` -- that page printed to PDF by headless Chrome
- `mNN.expected.json` -- what a reader should recover: title, headings, key sentences,
  tables, list items, page furniture, languages, code, page count and notes

## How it was made

A small generator, kept outside the repository, describes every document once. Each
heading, sentence, table cell, list item, furniture line and code block is written in
the generator, emitted into the HTML, and recorded in the expectations from the same
string. So the expectations come from what the author put into the source, not from
reading the PDF back.

The PDFs were printed with headless Chrome 155:
`chrome --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<separate profile> --print-to-pdf=mNN.pdf file:///.../mNN.html`.
Running headers, running footers and page numbers are CSS `@page` margin boxes, and page
numbers use `counter(page)` / `counter(pages)`. The `pages` value was counted from the
raw PDF bytes (`/Type /Page` objects, checked against the page tree's `/Count`). Every
document came out at the page count it was designed for.

**The author never ran a PDF-to-text extractor, a document converter or a PDF rasterizer
on these files. The author did not see golden_v1 to golden_v6, any reader's code, or any
reader's output.** The set does not copy earlier layouts or content. All organisations,
people, numbers and identifiers are invented. Place names are real.

## Conventions used in the expectations

- **Text** is the visible text. Whitespace runs collapse to one space, and non-breaking
  spaces count as spaces. Ligatures are given as their letters. No word is hyphenated
  across a line. Right-to-left text (Arabic m04, Hebrew m19) is in logical order.
- **headings**: in document order, with the title first at level 1. Subtitles, labels
  and price lines are body text, not headings.
- **key_sentences**: 4 to 10 whole sentences of body text, in reading order. A sentence
  that carries a footnote or note mark is never used.
- **tables**: the header row comes first. A merged cell repeats its text in every grid
  cell it covers, and this holds for multi-row headers too (m08, m13, m14). Section,
  total and summary rows are rows of the same table. A table that runs across pages is
  ONE table with its header row given once (m06, m20), although Chrome reprints the
  header on each page. In RTL documents the cells are given in reading order, rightmost
  column first. An empty cell is `""`.
- **Not tables**: labelled form-field grids (customs boxes in m03, the vessel strip in
  m20, the candidate and examiner boxes in m16), side-by-side address or detail blocks,
  signature blocks and CSS bar charts.
- **list_items**: only lists that look like lists. When CSS draws the marker (bullets,
  numbers, the dash in m12) the text has no marker. When the marker is typed ("a)",
  "(i)", "|"), the text keeps it.
- **furniture**: letterhead lines, text logos, legal footers, running headers and page
  numbers. A static running header or footer that repeats on every page is listed once.
  A page number is listed once per page ("Page 1 of 2", "Page 2 of 2"). A furniture line
  typed separately on two pages (m16 "Turn over ►") is listed twice.
- **code**: exact text with its indentation, lines joined with `\n`.

## The documents

| id  | kind | language | pages | main difficulties |
|-----|------|----------|-------|-------------------|
| m01 | Hotel invoice | fr | 1 | four-line letterhead, meta block beside it, six total rows in the table footer with labels over 5 columns, NBSP before €, two-line legal footer |
| m02 | Residential rental contract, 12 numbered clauses | pt | 3 | justified serif text, clause headings, typed a)-e) list, table inside a clause, running header + initials line + "Página n de N" |
| m03 | Export customs declaration | en, fr | 1 | bilingual form, grid of labelled boxes that is NOT a table, two-line bilingual header cells, TOTAL over 3 columns, stamp box, footer of three spans |
| m04 | Patient information leaflet | ar | 2 | right-to-left text, numbered sections and sub-headings, CSS bullets, a dosage table with one cell spanning 3 columns, Arabic page numbers in the margin |
| m05 | Secondary school timetable | sw | 1 | landscape, break rows over 5 columns, double periods over 2 rows, a second table in a side column, text logo |
| m06 | University transcript | es | 2 | 41-row grades table across two pages with year section rows, a footnoted sentence, verification code and "Hoja n/N" in the margins, text seal |
| m07 | Football league table and results | de | 1 | 16-row standings with coloured bands, U+2212 minus signs, a note mark inside a cell, a swatch legend that is not a table, green letterhead band |
| m08 | Regional train timetable | tr | 1 | landscape, stations as rows and trains as columns, 2-row header with a spanned label, "|" and "—" cell values, arrival and departure rows, typed notes list |
| m09 | Research poster (A3) | en | 1 | three columns read in order, banner with two text logos, superscript affiliations, Python code block, CSS bar chart, captioned table, numbered references |
| m10 | NGO rapid-assessment field report | en | 3 | running header, "- n -" page numbers, shaded key-findings box, nested numbered list, three captioned tables with total rows and an empty spanned cell |
| m11 | Agricultural extension sheet (millet) | ha | 1 | Hausa hooked letters ɓ ɗ ƙ, two columns, a CSS-numbered list, a rounded table, a tip box with a bold run-in label |
| m12 | Cooperative annual accounts | fr | 2 | income statement with section, total and result rows, a six-column balance sheet with assets and liabilities side by side, CSS dash list, NBSP thousands separators |
| m13 | Municipal budget summary | it | 2 | 2-row header with spanned columns, "–" values, dot thousands separators, italic source notes under tables, coat-of-arms box, running header |
| m14 | Election declaration of results | en | 2 | landscape 10-column table with a grouped candidate header, 20 polling stations plus a total, summary table with empty cells, formal declaration |
| m15 | Restaurant receipt (simplified invoice) | es | 1 | narrow monospaced till receipt centred on A4, dashed rules, VAT and total rows of the items table |
| m16 | Computer-science exam paper | en | 3 | cover page with instructions, typed (a)/(i) question parts with right-floated marks, Python and pseudocode blocks, a mostly empty trace table, "Turn over ►" |
| m17 | Veterinary patient card and vaccination record | nl | 1 | Calibri ligatures, side-by-side patient and owner cards, two record tables, letterhead split left and right, two-line legal footer |
| m18 | Household insurance policy schedule | de | 2 | letter layout with sender line and address window, key/value contract table, coverage and premium tables, masked IBAN, long legal line in the margin |
| m19 | Real-estate sale listing | he | 1 | right-to-left text, two columns, gershayim (״) and geresh (׳), a key-facts table, photo placeholders with no text, disclaimer footer |
| m20 | Outward cargo manifest | en | 2 | landscape 11-column table of 45 container rows across two pages, monospaced IDs, a TOTAL spanning 7 columns, a vessel-particulars form strip, print stamp in the margin |

Languages besides English: French, Portuguese, Arabic, Swahili, Spanish, German, Turkish,
Hausa, Italian, Dutch and Hebrew. Ten documents have 2 or 3 pages.
