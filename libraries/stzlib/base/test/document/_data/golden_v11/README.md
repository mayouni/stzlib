# golden_v11 — 24 realistic documents with known structure

This folder is an independent golden set for scoring document readers, such as Docling and
Softanza's native PDF reader. It holds 24 whole documents, `r01` to `r24`, of the kinds that real
organisations produce. Each document has three files:

- `rNN.html`: the source, which is the only authority for what is on the page;
- `rNN.pdf`: the source printed by headless Chrome;
- `rNN.expected.json`: the expected structure (title, headings, key sentences in reading order,
  tables, list items, furniture, languages, code, notes).

## How it was made

- Each document is described once, in a Python generator kept outside the repository. The same
  description writes the HTML and the expected JSON, so every expected text is the visible text of
  the source. Expected texts have tags removed, entities decoded, soft hyphens removed,
  non-breaking spaces turned into spaces, whitespace runs collapsed, and `<br>` inside a cell
  turned into one space. Code blocks are kept exactly as written.
- PDFs were printed with
  `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch profile> --print-to-pdf=<pdf> <file URL>`
  (Chrome 155). Running headers, running footers and page numbers are CSS `@page` margin boxes,
  except in r22, where each page is a fixed A4 box with its header and footer drawn in the body.
- Page counts were read from the raw PDF bytes (`/Type /Page` objects and `/Count`). Both agree
  for every file. Where the furniture depends on the page count (for example "Página 1 de 2"),
  it was generated from that count.
- Layout was checked only by screenshots of the HTML sources in headless Chrome.

**Independence.** The author of this set never ran, imported or opened any PDF-to-text or
document-conversion tool, any PDF rasterizer, any reader's code, or any reader's output. The author
did not look at golden_v1 to golden_v10. All organisations, people, places, products and
identifiers are invented. Domains use `.example`.

## Conventions a scorer must know

- `headings`: the title comes first at level 1, sections are level 2, subsections level 3.
  A letterhead's organisation name is furniture, never a heading. Run-in headings (r08) are given
  without their trailing period. Small-caps headings (r08) are given in source case, so compare
  them case-insensitively. Letter-spaced headings are given as their plain words.
- `key_sentences` follow reading order. Side-by-side boxes are read box by box: the left box first
  in left-to-right documents, the right box first in right-to-left documents. CSS columns are read
  column by column. Sentences that carry a footnote marker are left out. Paragraph numbers such as
  `3.1` (r11) are not part of the sentence.
- `tables`: the header rows come first; a two-level header gives two header rows. A merged cell
  repeats its text in every grid cell it covers. A table that continues across pages is one table,
  and its header row appears once even when Chrome repeats it on the next page (r05). In
  right-to-left documents, cells are listed in reading order, rightmost column first. A cell
  of two lines is given with its lines joined by one space. Empty cells are `""`.
- `list_items` keep a marker that is typed in the text (`a)`, `(i)`, `۱.`, `[1]`, `- `, shirt
  numbers). They have no marker when CSS draws it (bullets, decimal or Persian counters, `::before`
  dashes and check marks, string markers).
- `furniture` lists a running header or footer once, but lists page numbers once per page.
- Persian (r06) keeps its zero-width non-joiners (U+200C). Text is precomposed (NFC).

## The documents

| id | pages | language | kind | main difficulties |
|---|---|---|---|---|
| r01 | 1 | en | commercial invoice (software firm) | letterhead with the title at the right; key/value meta table; two pairs of side-by-side boxes; line items with subtotal, VAT and total rows that span four columns; a two-line cell |
| r02 | 3 | fr | municipal council minutes | three letterhead lines; running header absent on page 1; `— n —` page numbers; numbered headings at two levels; CSS-numbered agenda; row-spanning and column-spanning cells; vote summary table; side-by-side signature blocks |
| r03 | 1 | ar | medical laboratory report | right-to-left; four-column key/value grid; results table with section rows that span all columns; left-to-right numeric ranges isolated in RTL cells; Arabic-Indic and Western digits; CSS bullets |
| r04 | 2 | de | technical installation manual (heat pump) | margin-box header and footers; numbered headings 1 / 1.1; warning box; a two-column CSS section with soft hyphens in long compounds; typed `a)` list; INI code block |
| r05 | 2 | es | bank account statement | zebra-striped transaction table that crosses the page break, with its header repeated by the browser; empty debit or credit cells; one-row summary table; `Página n de N` |
| r06 | 2 | fa | university course syllabus | right-to-left; Persian digits; ZWNJ inside words; typed Persian list markers; CSS Persian-numeral list; weekly table; first-page and later-page footers |
| r07 | 2 | sw | NGO water project quarterly report | coloured letterhead band; two-level table header; side-by-side achievement and challenge boxes with lists; budget table with a negative amount and totals; forced page break; typed `(i)` list |
| r08 | 2 | en | motor insurance policy schedule | small-caps, letter-spaced headings; four-column key/value grid; cover table with two-line cells; five run-in headings; three footer margin boxes |
| r09 | 1 | pt | hotel banquet event order | centred letterhead; two side-by-side key/value boxes; programme table; dash list drawn by CSS; small equipment table; side-by-side signatures |
| r10 | 1 | tr | electricity utility bill | dense one-page layout; side-by-side key/value boxes; boxed amount line; bill detail with labels that span three columns; a horizontal six-month table |
| r11 | 2 | he | residential lease contract | right-to-left; side-by-side party boxes; clause paragraph numbers that are not list items; payment schedule with a spanning total; circle bullets; drawn signature lines |
| r12 | 3 | en | scientific research article | two CSS columns; a table that spans both columns with a two-level header; footnote marker and footnote; typed `[n]` reference list; first-page licence footer; running header on pages 2-3 |
| r13 | 1 | ha | farmers' cooperative notice | framed poster layout; hooked Hausa letters; capitalised title on a colour band; distribution table with a spanning total; check-mark list drawn by CSS; warning box |
| r14 | 1 | it | school report card | letter-spaced capital title; two-level grades table; behaviour row that spans two columns per term; four-column key/value grid; side-by-side signatures |
| r15 | 1 | nl | bus timetable leaflet | landscape A4; a wide 13-column table with a two-level header; `\|` pass-through cells; route badge; side-by-side note boxes below the table |
| r16 | 1 | ur | mosque committee annual accounts | Nastaliq face; right-to-left; side-by-side income and expense tables; spanning totals; typed Urdu-digit list; bidi-reordered phone number |
| r17 | 2 | en | software deployment runbook | letter-spaced capital headings; environment table with inline code; CSS-numbered steps split by four code blocks (shell, YAML); running header with an INTERNAL mark |
| r18 | 1 | pl | district football bulletin | side-by-side line-up boxes, each with a two-column list; typed shirt numbers; zebra standings table; fixtures list |
| r19 | 1 | id | retail purchase order | side-by-side supplier and order boxes; line items with two-line cells (name + SKU); totals that span six columns; dot thousands separators; amount in words; typed terms list; three signature blocks |
| r20 | 2 | el | municipal gallery events programme | letter-spaced letterhead; calendar table with month section rows that span all columns; CSS string list markers; level-3 subheadings; running header only on page 2 |
| r21 | 1 | am | municipal health office job vacancy | Ge'ez script; Ethiopian calendar date; Ethiopic punctuation; six-column vacancies table; title on a colour band |
| r22 | 2 | ru | laboratory test protocol (concrete) | page furniture placed in the body (fixed page boxes); letterhead; key/value table; results table with a two-level header, section rows and spanning mean rows; decimal commas |
| r23 | 1 | vi | outpatient prescription | A5 page; Vietnamese diacritics; four-column key/value grid; dosage cells of two lines; typed hyphen list; footer line under a dashed rule |
| r24 | 3 | en | charity financial statements | partly ruled tables; section rows with blank cells; subtotal rows without a label; numbers in parentheses; two-level header; notes with level-3 headings; one statement per page |

Twelve documents have two or three pages. Nineteen languages appear besides English.
