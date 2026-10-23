# golden_v9 -- realistic PDF documents with known structure

Twenty-four whole documents of the kinds real organisations produce, each given as

- `pNN.html` -- the source the author wrote,
- `pNN.pdf` -- that source printed to PDF by headless Chrome,
- `pNN.expected.json` -- the structure a document reader should recover: title, headings in
  order, key body sentences in reading order, tables as cell grids, visible list items, page
  furniture, languages, code blocks, and notes for the scorer.

The set is meant to score document readers (Docling and Softanza's native PDF reader). Every
organisation, person, address, account and number in it is invented.

## How it was made

1. Each document was written by hand as HTML with its own CSS (fonts, sizes, colours, column
   layouts, alignment), using `@page { size: A4 }` (landscape for p12) and, for running
   headers, footers and page numbers, CSS page-margin boxes (`@top-*`, `@bottom-*` with
   `counter(page)` / `counter(pages)`). Letterheads and closing footer lines are placed in the body.
2. Each HTML file was printed with
   `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch profile> --print-to-pdf=<pdf> <file url>`
   (Chrome 155), so no browser header or footer is added.
3. The page count in `pages` was read from the raw PDF bytes (number of `/Type /Page` objects,
   checked equal to `/Count`) and compared with the page count the author designed; all 24 match.
4. Headings, list items, tables (rowspan/colspan expanded so a merged cell repeats its text in every
   grid cell it covers) and code blocks were read back from the author's OWN HTML source with
   Python's `html.parser`, so the expected structure cannot drift from what was written. Key
   sentences and furniture lines were written by the author and checked to occur in the source,
   key sentences in increasing source order (the reading order: no CSS reordering is used).
5. Text conventions: whitespace collapsed; soft hyphens (p03) removed, so a word broken at a soft
   hyphen is given whole; words holding a hard hyphen are kept on one line (`white-space: nowrap`)
   so no hard hyphen falls at a line end; no CSS `text-transform`; right-to-left text and tables in
   logical order; list markers drawn by CSS are not in the text, typed markers are; a repeated
   running header is listed once, a page-number line once per page (`Page 1 of 3`, `Page 2 of 3`);
   where a margin row has a left and a right box they are separate furniture entries; a table header
   that the browser repeats on each page is in the expected table once.

## Independence

The author of this set never ran, imported or opened any PDF-to-text or document-conversion tool,
any PDF rasterizer, any reader's code or any reader's output, and never looked at golden_v1 to
golden_v8. Nothing in the PDFs was inspected beyond the page-object count in their raw bytes; the
expected structure comes from the HTML source alone. Layout statements in `notes` (columns,
side-by-side boxes, repeated table headers, where a page breaks) describe what the CSS asks for;
nobody has looked at the rendered pages yet.

## Documents

| id | kind | languages | pages | difficulty | main difficulties |
|---|---|---|---|---|---|
| p01 | Commercial: supplier tax invoice | en | 1 | easy | letterhead band, side-by-side address blocks and key/value table, line items with merged total labels, bank footer |
| p02 | Medical: hospital discharge letter | fr | 2 | medium | running header from page 2, 'Page n/N', two-level lab table with rowspan/colspan and caption, bulleted lists, œ |
| p03 | Legal: residential lease | de | 3 | hard | 3 pages, justified serif text with soft hyphens in compounds, paragraph numbers that are not lists, unmarked annex list, rent table with total |
| p04 | Educational: university syllabus | es | 2 | medium | title on a colour band, key/value table, zebra programme table, CSS-numbered bibliography, '— n —' page numbers |
| p05 | Municipal: water-cut notice | ar | 1 | medium | right-to-left Arabic, RTL table in logical order, number runs inside RTL text, two-sided letterhead |
| p06 | Technical: operations runbook | en | 2 | medium | four code blocks (shell, YAML), three heading levels, nested list, monospace table cells, left+right footer boxes |
| p07 | Financial: credit cooperative quarterly report | pt | 2 | hard | two-column board message, two-level header table, wide 7-column statement, captions as paragraphs, forced page break |
| p08 | Retail: supermarket weekly flyer | en | 1 | medium | 4-column card grid (neither table nor list), masthead band, two-column bottom with hours table |
| p09 | NGO: community water newsletter | sw | 2 | hard | two columns with rule, table spanning both columns mid-flow, pull quote, lead paragraph |
| p10 | Agricultural: seed and fertiliser distribution report | en | 3 | hard | 3 pages, long table across pages with repeated header, section rows, subtotals, grand total |
| p11 | Hospitality: hotel booking confirmation | it | 1 | easy | centred letter-spaced letterhead, borderless key/value table, cost table with merged summary labels, CSS dash markers |
| p12 | Transport: bus timetable | nl | 2 | hard | LANDSCAPE, two 13-column timetables with two-level headers, '–' cells, legend list with typed symbols, side-by-side boxes |
| p13 | Educational: school progress report | tr | 1 | medium | partly ruled grade table (horizontal rules only), merged average label, side-by-side table and comment, monogram badge |
| p14 | Municipal: property tax notice | he | 1 | medium | right-to-left Hebrew, key/value and payment tables in logical order, shekel amounts, addressee block |
| p15 | NGO / public health: bilingual polio campaign leaflet | en, ha | 1 | medium | parallel English and Hausa columns (ɗ, ƙ, apostrophes), banner title, bilingual zebra table |
| p16 | Technical: heat-pump product datasheet | pl | 2 | medium | zebra spec table with section rows, two-level performance table, side box, forced page break |
| p17 | Administrative: village meeting minutes | id | 2 | medium | kop-surat letterhead, typed-number agenda list, CSS-numbered decisions, fully ruled budget table with sections and totals |
| p18 | Financial: bank account statement | en | 3 | hard | 3 pages, ~100-row zebra transaction table across pages, summary table beside address block, three margin boxes |
| p19 | Medical: appointment reminder card | am, en | 1 | medium | Amharic (Ethiopic script) with English in the same cells, side-by-side bilingual notices, Ethiopian clock times |
| p20 | Municipal: council minutes extract | fr | 2 | medium | typed-number agenda, four tables incl. empty cells, guillemets, 'feuillet n° n' footer, boxed mention |
| p21 | Legal: mutual non-disclosure agreement | en | 2 | hard | clause numbering that is not a list, typed (1)/(a) lists, footnote marker and footnote, bare page number, signature table with empty cells |
| p22 | Hospitality: restaurant menu | es | 1 | medium | two columns of borderless header-less tables (name + italic description in one cell, price), boxed set menu |
| p23 | Technical: IT change request | de | 2 | medium | nginx and JSON code blocks on a dark background, ruled key/value table, risk table with wrapped cells, subtitle heading |
| p24 | Educational: mathematics exam paper | en | 2 | medium | typed question/sub-part list at two levels with marks, horizontal frequency table, U+2212 and ², empty candidate cells |

Languages besides English: French, German, Spanish, Arabic, Portuguese, Swahili, Italian, Dutch,
Turkish, Hebrew, Hausa, Polish, Indonesian, Amharic. Documents of 2 or 3 pages (15):
p02, p03, p04, p06, p07, p09, p10, p12, p16, p17, p18, p20, p21, p23, p24.
