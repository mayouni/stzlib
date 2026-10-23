# Golden set v10 — 24 realistic documents with known structure

## What this set is

Twenty-four whole documents of the kinds real organisations produce, each given as

- `qNN.html` — the authored source,
- `qNN.pdf` — the same page printed to PDF by headless Chrome,
- `qNN.expected.json` — the structure a document reader should recover from the PDF.

The set is for scoring document readers (Docling and Softanza's native PDF reader). Every
organisation, person, address, number and product in it is invented.

It covers 15 languages besides English (French, Arabic, Spanish, German, Swahili, Portuguese,
Hebrew, Turkish, Italian, Dutch, Hausa, Polish, Indonesian, Persian, Greek) and one bilingual
English/French document. Three documents are right-to-left (Arabic, Hebrew, Persian), and all
three have lists and tables. Twelve documents run to two or three pages.

## How it was made

1. Each document was written by hand as HTML. The author marked its structure with `data-*`
   attributes: `data-h` for headings, `data-title`, `data-k` for the chosen key sentences,
   `data-f` for page furniture, `data-li` for typed-marker list items, `data-t` for tables,
   `data-rep` for a header row that is repeated on a continued page, and `data-code` for code
   blocks. The attributes are still in the published HTML, so any expected value can be traced
   to the element it came from.
2. A small generator read those annotations out of the author's **own HTML** and wrote
   `expected.json`. Visible text was computed from the markup: tags removed, entities decoded,
   soft hyphens removed, runs of whitespace (non-breaking spaces included) collapsed to one
   space. Code blocks keep their exact text. A `<li>` takes its level from how deeply it is
   nested, and its text never includes a nested list. Merged table cells repeat their text in
   every grid cell they cover. Rows from a table continued on another page join the first part,
   and a repeated header row is left out.
3. Chrome printed each HTML file to PDF with no browser header or footer:
   `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch profile> --print-to-pdf=qNN.pdf file:///.../qNN.html`.
   The page count in `expected.json` was read from the PDF's raw bytes (`/Type /Page`
   objects, checked against the page tree's `/Count`). No text was extracted from the PDF.
4. Before printing, a headless Chrome pass over a copy of each HTML (`--dump-dom`, with a
   measuring script added to the copy only) checked that nothing overflowed. For fixed-page
   documents it checked that no page's content overflowed its box vertically or horizontally.
   For flowing documents it checked that nothing was wider than the printable width. Every
   document passed.

Two kinds of layout are used:

- **Fixed pages** (`@page { margin: 0 }`, one 210 × 296 mm box per page). These carry
  running headers, footers and page numbers placed in the body, so the author knows exactly
  what is on each page.
- **Normal flow** (`@page { size: A4; margin: 2cm }`, or A4 landscape with 12 mm margins for
  q09). Chrome breaks these pages itself. In q15, Chrome repeats the table header on each
  continued page; q19 continues in two columns from page to page.

## Independence

The author of this set never ran, imported or opened any PDF-to-text, document-conversion or
PDF-rasterising tool. The author never looked at any reader's code or output, and never saw
golden sets v1 to v9. The PDFs were produced only by Chrome's print-to-PDF. The expected
values come only from the author's own annotated HTML, so they do not depend on any reader.

## Conventions a scorer must know

- **Reading order.** Key sentences, headings and list items are in reading order, which is the
  DOM order. Where two boxes or columns sit side by side, the order is box by box (left box
  first; in right-to-left pages, right box first) and never line by line across. Each
  document's `notes` says where this applies.
- **Right-to-left text** is given in logical order. Right-to-left tables list cells in logical
  order, rightmost column first.
- **Furniture** lists each visible header, footer or letterhead line once. A running line that
  repeats on every page is listed once. Page numbers that differ ("Page 2 of 3") are listed once
  per page. A letterhead's organisation name is furniture, never a heading.
- **Headings** start with the title at level 1. A letter with no title (q14) has `title: null`,
  and its headings start at level 2.
- **Lists.** An item keeps its marker when the marker is typed in the text ("1.", "a)", "(1)",
  "١.", "א.", "[1]"). It has no marker when CSS draws one (disc, square, decimal, arabic-indic,
  dash and diamond string markers, check marks drawn by `::before`). Clause and paragraph
  numbers in q12 ("1.1", "4.2") are NOT list items, and section numbers inside headings are
  part of the heading text.
- **Tables.** The header row comes first, and a two-level header gives both header rows.
  Section, subtotal and total rows are rows of the same table. Empty cells are `""`. Key/value
  tables without a header row are tables. A table continued across pages is one table with its
  header given once (q13 repeats the header row on page 2, q15 has Chrome repeat it, q22 does
  not repeat it).
- **Footnotes.** A sentence that carries a footnote marker is never a key sentence (q06).
- **Hyphenation.** A word carrying a soft hyphen is given whole (q06 "heterogeneity").
- **Persian zero-width non-joiners** (U+200C) are kept in q21's expected text. A scorer may remove
  them from both sides before comparing.

## The documents

| id | kind | language | pages | main difficulties |
|---|---|---|---|---|
| q01 | Commercial tax invoice (analytics consultancy) | en | 1 | letterhead; side-by-side "Bill to" box and key/value box; line items with subtotal/VAT/total rows spanning three columns |
| q02 | Municipal council minutes | fr | 3 | two-part running header; "Page n / 3"; two side-by-side columns of attendee lists; CSS-numbered agenda; two-level budget table with section rows; vote table; non-breaking spaces |
| q03 | Water utility tariff notice | ar (RTL) | 2 | coloured letterhead band; RTL tables; borderless key/value table; CSS bullets, typed Arabic-Indic markers and CSS arabic-indic numbering; Arabic-Indic page numbers |
| q04 | Clinical laboratory report | es | 1 | side-by-side patient and sample boxes with key/value tables; results table with section rows, flags and empty unit cells |
| q05 | Pump controller operating manual | de | 3 | dark running header; "Seite n von 3"; warning box; spec table with section rows; typed steps with level-1 sub-steps; terminal table; INI configuration code block |
| q06 | Journal article (soil science) | en | 2 | title and abstract spanning the page above a two-column body; running headers that change between pages; journal page numbers; footnote; soft hyphen; table caption above; typed reference list |
| q07 | NGO quarterly report | sw | 2 | green letterhead band; key/value metadata; zebra tables; side-by-side achievements and challenges boxes; budget with total row; CSS-numbered next steps |
| q08 | Hotel booking confirmation | pt | 1 | centred letterhead; dotted key/value table; payment table with total, deposit and balance rows; side-by-side policy boxes; two-column amenities list with CSS check marks |
| q09 | Bus timetable | en | 1 (landscape) | wide 13-column zebra timetable with a two-level header; dash cells; side-by-side fares table and change list |
| q10 | School letter to parents | he (RTL) | 2 | letterhead with logo; Hebrew and civil date; RTL tables; break row spanning five columns; CSS bullets and typed Hebrew-letter markers; dashed reply slip |
| q11 | Agricultural cooperative price list | tr | 1 | partly ruled table with section rows; Turkish number format; typed "1)" notes; dotted capital İ |
| q12 | Master services agreement | en | 3 | three-part footer with initials blanks; numbered clauses that are not lists; typed party, recital and sub-clause markers; two fee tables; side-by-side signature blocks |
| q13 | Museum autumn-winter programme | it | 2 | masthead; main column with a shaded sidebar; events table continued on page 2 with a repeated header; two-level schools table; CSS diamond markers; "1/2" page numbers |
| q14 | Municipal letter on waste collection | nl | 1 | no title (subject line in a reference block); address block; calendar table; side-by-side yes/no boxes with bullets |
| q15 | Building society account statement | en | 2 | side-by-side account and summary boxes; 56-row transaction table that crosses the page break with the header repeated by Chrome; opening and closing balance rows |
| q16 | School report card (Niamey) | fr | 1 | framed header; side-by-side identity boxes; seven-column grades table with a two-level header, section rows and a total row; side-by-side results table and council remarks |
| q17 | Agricultural extension leaflet (millet) | ha | 1 | Hausa hooked letters; two newspaper columns with a rule; headings on colour bars; typed steps; small fertiliser table |
| q18 | Software release notes and runbook | en | 2 | monospaced running header; "— n —" page numbers; change table with inline code; three code blocks (shell, YAML, shell with JSON output) |
| q19 | Patient information leaflet | pl | 2 | whole text in two columns continuing across pages; no furniture; framed warning box; CSS-numbered contents; dash-marker lists; dosage table; borderless composition table |
| q20 | Restaurant menu | id | 1 | double frame; two menu columns; six borderless dish/price tables with CSS-drawn dotted leaders |
| q21 | Library membership regulations | fa (RTL) | 1 | Persian digits and thousands separator; zero-width non-joiners; RTL fee table; side-by-side boxes read right box first; typed Persian-digit rules |
| q22 | NGO grant budget narrative | en | 2 | logo letterhead; eight-column budget with a two-level header, section, subtotal, indirect-cost and grand-total rows, continuing across the page break without a repeated header |
| q23 | Bilingual vacancy announcement | en + fr | 1 | bilingual title and key/value table; English and French versions side by side, read column by column |
| q24 | Municipal water and sewerage bill | el | 1 | title on a colour bar; side-by-side customer and bill boxes; meter table; charges table with section rows and a spanning total; tear-off payment slip |
