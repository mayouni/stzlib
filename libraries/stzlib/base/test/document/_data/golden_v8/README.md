# golden_v8 -- 24 realistic documents with known structure

Version 8 of the independent golden set used to score document readers (Docling and
Softanza's native PDF reader). Each document is a whole, realistic document of a kind
real organisations produce -- invoices, a quotation, a discharge summary, a municipal
notice, a lease, a datasheet, a runbook, a report card, field and annual reports, a
dispatch note, minutes, a permit decision, a syllabus, an SOP, a bank statement, a menu,
a vacancy, a utility bill, a configuration guide, a lab report, a purchase order with
terms, and a municipal budget. Every organisation, person, address, phone number,
account and identifier in them is invented; domains use the reserved `.example` TLD.

## Files

For each id `n01` .. `n24`:

- `<id>.html` -- the source, self-contained (inline CSS, system fonts only, no images, no scripts)
- `<id>.pdf` -- the HTML printed to PDF by headless Chrome
- `<id>.expected.json` -- the expected structure: `id`, `difficulty`, `pages`, `title`,
  `headings`, `key_sentences`, `tables`, `list_items`, `furniture`, `languages`, `code`, `notes`

## How it was made

1. Each document was written as Python data in a generator kept OUTSIDE this repository.
   The same Python strings produce both the HTML and the expected JSON, so every expected
   heading, sentence, table cell, list item, furniture line and code block is the text
   that was placed in the page (HTML tags removed, entities decoded, whitespace runs
   collapsed, non-breaking spaces given as spaces). Table grids are computed from the
   real `rowspan`/`colspan` of the HTML, repeating a merged cell's text in every grid cell
   it covers. Tables split across pages were emitted from one row list cut in two, and
   their expected form is that one list with the header row(s) once.
2. Each HTML was printed with
   `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch profile> --print-to-pdf=<id>.pdf file:///.../<id>.html`.
   Single-page documents use `@page { size: A4; margin: 2cm }` (n24: A4 landscape);
   multi-page documents use `@page { margin: 0 }` with one fixed-size A4 sheet per page so
   that letterheads, running headers, footers and page numbers sit at known places and
   every page break is decided by the author, never by the browser.
3. Page counts were checked from the raw PDF bytes (`/Type /Page` objects and the
   `/Count` of the page tree) -- all 24 match `pages` in the JSON.
4. Layout was checked in the same headless Chrome by loading a scratch copy of each HTML
   with a measuring script (DOM geometry only): no sheet overflows its body area, no
   table or code block is wider than its column, and no furniture line wraps -- so each
   furniture entry is one visible line.

The author of this set **never ran a PDF-to-text extractor, a document converter or a
PDF rasterizer on these files, never read any reader's code or output, and never looked
at golden_v1 .. golden_v7**. The expected JSON is therefore independent of every reader
it will score. No human has yet looked at the rendered PDFs; the checks above are
instrumental (page counts, DOM geometry), not visual.

## Conventions a scorer must know

- `title` is the first level-1 heading; a letterhead's organisation name is furniture, never a heading.
- `key_sentences` are 4-10 full body sentences in reading order. For two-column pages the
  left column is read before the right; for right-to-left pages, text is in logical order.
- `tables`: header row(s) first; merged cells repeat their text; totals, subtotals and
  section rows are rows of the same table (a section row repeats its label across the row,
  or has empty other cells where the HTML has empty cells); a table continued across pages
  is one table with its header once; right-to-left tables list the rightmost column first.
  Key/value boxes that are real HTML tables with no header row (n03, n19) are listed with
  all rows as data.
- `list_items`: markers drawn by CSS (`<ol>`/`<ul>`) are not included; markers typed in the
  text (`I.`, `1.`) are.
- `furniture`: letterhead lines, running headers, footers and page numbers, one visible
  line per entry; an identical line repeated on several pages is listed once, while page
  numbers that differ from page to page are listed once each. Where a header or footer
  has a left part and a right part on the same baseline, the two parts are separate entries.
- Hard hyphens inside compounds (`follow-up`, `Heizungs- und`) are part of the text; no
  document uses soft or automatic hyphenation.
- Each document's `notes` field names its own traps.

## Coverage

- Languages besides English: Arabic, German, Spanish, French, Hausa, Italian, Dutch, Portuguese, Swahili, Turkish.
- 11 documents of 2 or 3 pages; 20 with a letterhead on page 1.
- Tables continued across pages: n11 (balance sheet), n15 (schedule), n17 (RTL bank
  transactions), n21 (parameter reference).
- Code or configuration blocks: n07 (shell, YAML), n15 (R), n21 (TOML, shell, console).

## The 24 documents

| id | kind | language | pages | difficulty | main difficulties |
|---|---|---|---|---|---|
| n01 | Commercial tax invoice (ship chandler) | English | 1 | easy | letterhead with org name as largest text; line-item table with merged total rows; address and meta blocks that are not tables |
| n02 | Quotation (devis) for school furniture | French | 1 | medium | French; centred letterhead; table with section rows, sub-total rows and merged total rows; non-breaking spaces as thousands separators; amount in words; two-column signature block |
| n03 | Hospital discharge summary | English | 2 | medium | 2 pages; letterhead on p1 and a different running header on p2; footer split left/right with page numbers; key/value table without header; lab table with two-level header (rowspan + colspan); medication table; CSS lists |
| n04 | Municipal public notice (business licence renewal) | Arabic | 1 | medium | Arabic RTL; centred letterhead; reference/date line split right and left; RTL table with caption; CSS-numbered list with Arabic-Indic markers; fixed footer |
| n05 | Residential lease agreement | Spanish | 3 | medium | Spanish; 3 pages, no letterhead; justified serif text; numbered clauses as level-3 headings; typed Roman-numeral list; inventory table; footer split left/right with 'Página X de 3' |
| n06 | Technical product datasheet (centrifugal pump) | German | 1 | hard | German; letterhead with org left and contacts right; two-column grid (read left column first); borderless two-column table; partly ruled spec table with section rows; transposed table with row headers; suspended hyphen 'Heizungs- und' |
| n07 | Operations runbook (software deployment) | English | 2 | hard | 2 pages; running header split left/right and footer with 'N/2' page numbers; numbered headings typed in the text; nested lists (ordered with bulleted sub-items); four code blocks (shell and YAML) with line continuations; contacts table |
| n08 | School end-of-year report card (registo de avaliação) | Portuguese | 1 | medium | Portuguese; letterhead with a logo box of initials; table with two-level header (rowspan + colspan) and a totals row; signature columns |
| n09 | NGO quarterly field report (water and sanitation) | Swahili | 2 | medium | Swahili; 2 pages; letterhead on p1, running header on p2, centred page-number footer; numbered headings typed in text; two tables with captions, one with a totals row and bracketed negative; bulleted and CSS-numbered lists |
| n10 | Public health leaflet (childhood vaccination) | Hausa | 1 | medium | Hausa with hooked letters (ɓ ɗ ƙ); letterhead; two-column grid read left column first; schedule table; CSS bullets and a typed numbered list; footer split in two |
| n11 | Annual report excerpt (consolidated financial statements) | English | 3 | hard | 3 pages numbered 42-44 (offset page numbers); running header split left/right; income statement with two-level header (rowspan + colspan-free year/unit rows); comprehensive income table; balance sheet table CONTINUED across pages 2-3 with the header repeated; section and subtotal rows; bracketed negatives; continuation label |
| n12 | Dispatch note (sevk irsaliyesi) | Turkish | 1 | easy | Turkish (dotted/dotless i, ç, ş, ğ); letterhead left with document box right; recipient and carrier blocks; line-item table with a merged total row; signature boxes; footer sentence |
| n13 | Minutes of a condominium general meeting (verbale di assemblea) | Italian | 2 | medium | Italian; 2 pages; letterhead of the managing agent on p1, running header on p2; footer split left/right; CSS-numbered agenda list; quotes table; voting table with two-level header and caption |
| n14 | Municipal permit decision letter (omgevingsvergunning) | Dutch | 2 | medium | Dutch; 2 pages; right-aligned letterhead; window address block; reference block (labels and values, not a table); question-form headings; fees table with total; footer page numbers and a running header on p2 |
| n15 | University course syllabus (plan de cours) | French | 2 | hard | French; 2 pages; letterhead; schedule table CONTINUED across pages with repeated header; evaluation table with total row; CSS-numbered and bulleted lists; R code block; non-breaking spaces before colons and percent signs; footer 'ECO 2104 ...' plus '— N —' page numbers |
| n16 | Laboratory standard operating procedure | English | 1 | medium | letterhead; document-control table above the title; numbered headings typed in text; materials table; ordered list with nested lower-alpha sub-steps; degree signs and en dashes; footer split left/right |
| n17 | Bank account statement | Arabic | 2 | hard | Arabic RTL; 2 pages; letterhead on p1, running header on p2; account details block; transaction table CONTINUED across pages with repeated header; empty debit/credit cells; LTR numbers and reference codes inside RTL cells; summary table; two-line footer |
| n18 | Restaurant menu (cardápio) | Portuguese | 1 | hard | Brazilian Portuguese; letterhead with tagline; two-column grid read left column first; dish lines with dotted leaders and right-aligned prices (div layout, not a table); one real drinks table; footer |
| n19 | NGO job vacancy announcement | English | 1 | easy | letterhead with logo box; key/value table without header; bulleted lists with a nested level; email address inside a sentence; two-line footer |
| n20 | Household electricity bill | English | 1 | hard | letterhead; address and account summary blocks side by side (not tables); main column plus sidebar (read main column first); meter table with two-level header; charges table with section rows and totals; borderless usage-history table in the sidebar |
| n21 | Software administrator guide chapter (configuration reference) | English | 2 | hard | 2 pages, no letterhead; running header split left/right; chapter-style page numbers 3-1 / 3-2 placed on alternating sides; numbered headings; TOML, shell and console code blocks; note box; parameter table CONTINUED across pages with repeated header; quoted values inside cells |
| n22 | Clinical laboratory results report | Spanish | 1 | medium | Spanish (Mexico); letterhead; patient details grid (not a table); results table with uppercase section rows, flagged values '(A)'/'(B)', micro sign and superscript; legend line; footer split left/right |
| n23 | Public-sector purchase order with terms and conditions | English | 2 | hard | 2 pages; letterhead on p1, running header on p2; supplier/delivery/order blocks (not tables); 8-column line-item table with merged total rows; dense two-column small print on p2 (CSS columns) with bold run-in clause titles; footer split left/right |
| n24 | Municipal budget summary (budget primitif) | French | 1 | hard | French; A4 LANDSCAPE; letterhead; two side-by-side blocks (budget table left, investment table and text right); budget table with two-level header (rowspan + colspan), section rows and total rows; signed percentages; non-breaking spaces in numbers and before % |
