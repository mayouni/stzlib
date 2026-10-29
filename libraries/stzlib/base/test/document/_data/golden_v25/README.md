# Golden set v25 -- 24 realistic documents with known structure

Version 25 of the independent golden set used to score document readers
(Docling and Softanza's native PDF reader). Each document `hNN` comes as
three files:

- `hNN.html` -- the source page, written by hand;
- `hNN.pdf` -- that page printed to PDF by headless Chrome 156
  (`--headless=new --no-pdf-header-footer`, A4);
- `hNN.expected.json` -- what a correct reader must recover: title,
  headings, key sentences in reading order, tables as grids, list items,
  page furniture, languages, code blocks, and notes for the scorer.

## How it was made

All 24 documents were written in one session, 2026-10-29, by one author.
Every organisation, person, address, account and product in them is
fictitious. A small generator writes each page and its expected text from
the SAME source strings, so the expected text is the text printed on the
page, not a second copy typed by hand. Before a PDF was accepted, four
checks ran on the author's own HTML (never on a PDF):

1. every expected string (heading, key sentence, list item, cell,
   furniture line, code) is present in the page's visible text;
2. a layout probe in headless Chrome reported no content overflowing a page
   box or the page edge (pages laid out as fixed A4 boxes), and the PDF has
   exactly the intended number of pages (counted from the raw bytes:
   `/Type /Page` objects and `/Count`);
3. every character of every text run exists in the cmap of the installed
   font file that run is set in (checked with fontTools against
   `C:\Windows\Fonts`); no variable font is used;
4. the `/BaseFont` names in the raw PDF bytes show the intended fonts were
   embedded and no fallback font appeared. Two fallbacks found this way were
   fixed before release (a `·` missing from Goudy Old Style, and Chrome not
   resolving the family name "Franklin Gothic Demi").

Pages were also looked at as screenshots of the HTML while being made.

**Independence.** The author never ran a PDF-to-text extractor, document
converter or PDF rasterizer on these files, never looked at any reader's
code or output, and never opened golden sets v1 to v24. Layouts and
content are new.

## Conventions (all documents)

- Headings: the title is the first heading, level 1. A letterhead name, a
  box or panel label, a form label and a table header cell are not headings.
- Key sentences: 4 to 10 full body sentences, exactly as printed, in reading
  order. A sentence carrying a footnote marker is never a key sentence.
- Tables: header row(s) first; a merged cell's text is repeated in every
  grid cell it covers; totals and section rows belong to the table; a table
  continued across pages is one table with its header once; a cell printed
  on several lines is given with its lines joined by one space; right-to-left
  tables list cells in reading order (rightmost column first). Two-level
  headers give two header rows (h03, h12, h23).
- Lists: a TYPED marker is part of the item text (`"1.1 The ..."`, marker
  and text joined by one space); a marker DRAWN BY CSS is left out. Each
  document's notes say which is which.
- Furniture: letterhead, running header and footer lines, one visible line
  per entry; a repeated line is listed once; page-number lines once per page.
  In h06, h10, h17 and h21 the furniture is drawn by CSS `@page` margin boxes,
  so it exists in the PDF but not in the HTML body.
- Text: whitespace runs collapse to one space (no-break spaces count as
  spaces), except in code; NFC; right-to-left text in logical order;
  letter-spaced text as plain words; in Chinese, Japanese and Thai a sentence
  wrapped across lines joins with no space. No text is hyphenated by the
  layout: every token that contains a hyphen or en dash is kept on one line.

## Languages

English (h01, h06, h10, h15, h17, h21, h23, h24) and sixteen others:
French h02, German h03, Arabic h04, Japanese h05, Hebrew h07, Chinese h08,
Spanish h09, Russian h11, Hindi h12, Korean h13, Greek h14, Portuguese h16,
Persian h18, Vietnamese h19, Thai h20, Polish h22. Right-to-left documents
with lists and tables: h04, h07, h18. Eleven documents have 2 or 3 pages.

## The documents

| id | lang | pages | kind | main difficulties | fonts embedded |
|---|---|---|---|---|---|
| h01 | en | 2 | supplier invoice | full-grid line items crossing to page 2 with repeated header; section rows and totals spanning columns; two-line cells; boxed key/value panel; BILL TO / SHIP TO boxes side by side (box by box); CSS bullets nested | Calibri (Regular, Bold, Italic) |
| h02 | fr | 1 | town-hall letter | letterhead; borderless key/value reference block; typed inline "1)" items; small table ruled under header with caption; no title | Garamond (Regular, Bold, Italic) |
| h03 | de | 3 | quarterly report | running header in two parts; sidebar box beside lead paragraph; two-column section; zebra table with two-level header; CSS dash markers; typed "a)" with nested CSS bullets | Constantia (Regular, Bold, Italic), Corbel (Regular, Bold) |
| h04 | ar | 2 | HR circular (RTL) | Arabic-Indic digits; typed abjad markers; CSS arabic-indic list; typed nested "١." / "أ)"; RTL full-grid table with row spans | Sakkal Majalla (Regular, Bold), Simplified Arabic (Bold) |
| h05 | ja | 2 | meeting minutes | key/value grid; typed full-width "（１）" with nested "①"; typed "・"; CSS cjk-decimal; action table with row span and two-line cells; "- 1 -" page numbers | Yu Gothic (Regular, Bold) |
| h06 | en | 2 | software release notes | @page margin-box header and "Page n of N"; two Consolas code blocks (shell, YAML); table ruled under header only; CSS decimal/alpha nesting; typed en dashes | Segoe UI (Regular, Semibold), Consolas |
| h07 | he | 2 | office lease agreement (RTL) | party boxes side by side (right box first); typed "1.1" clauses with nested "(א)"; CSS hebrew-letter list; payment table with total spanning columns | Arial (Regular, Bold) |
| h08 | zh | 1 | purchase order | four-column key/value grid; full-grid items with category row spans and a capital-numeral total; typed "一、" with nested "（一）"; CSS decimal | Microsoft YaHei (Regular, Bold), SimSun |
| h09 | es | 2 | bank account statement | address block beside boxed summary panel; zebra transactions table crossing pages with repeated header; totals row; running header on page 2; CSS square bullets | Verdana (Regular, Bold) |
| h10 | en | 2 | station technical report | two-column body across pages; booktabs table inside a column beside text; footnote marker; typed "(a)" and "[1]" lists; @page margin boxes | Cambria (Regular, Bold, Italic) |
| h11 | ru | 1 | commercial offer | reference and addressee blocks; full-grid items with totals spanning five columns; no-break-space thousands; typed Cyrillic "а)"; CSS decimal with nested bullets | Cambria (Regular, Bold, Italic) |
| h12 | hi | 1 | school exam circular | Devanagari digits; two-level header table with spans; typed "१." with nested CSS bullets; CSS devanagari list set in two columns | Nirmala UI (Regular, Bold) |
| h13 | ko | 1 | quotation | customer block beside supplier panel with a vertical label spanning four rows; full-grid items with three totals rows; typed "1." with nested "가."; CSS hangul list | Malgun Gothic (Regular, Bold) |
| h14 | el | 1 | university course outline | two side-by-side column pairs; CSS lower-greek list; typed inline "α)"; weekly table with row rules only; key/value table | Palatino Linotype (Regular, Bold, Italic) |
| h15 | en | 1 | HR new-starter form | blank form fields and CSS checkboxes (labels are not text to extract as sentences); reversed section bars as headings; two boxes side by side; empty-value key/value grid | Franklin Gothic Book, Franklin Gothic Demi |
| h16 | pt | 2 | corporate travel policy | regulation style with inline "Art. 1º"; typed Roman "I –" with nested "a)"; CSS decimal; annex table with vertically centred row spans and two-line cells | Book Antiqua (Regular, Bold) |
| h17 | en | 1 | conference day programme (landscape) | wide grid of separated cells, no lines; plenary rows spanning four columns; workshop spanning two time rows; multi-line top-aligned cells; list beside a text column; @page footer | Century Gothic (Regular, Bold) |
| h18 | fa | 1 | warranty card (RTL) | Persian digits; ZWNJ inside words; key/value table beside a stamp box; zebra coverage table with a two-column span; CSS persian list; typed "الف)" | Tahoma (Regular, Bold) |
| h19 | vi | 1 | asset handover minutes | two-block administrative header; party boxes side by side; full-grid asset table with spans; typed "-" with nested "+", typed "a)" | Times New Roman (Regular, Bold, Italic) |
| h20 | th | 1 | job announcement | Thai digits and no inter-word spaces; zebra table without lines; CSS thai list beside typed "•" list; typed "๑)" | Leelawadee UI (Regular, Bold) |
| h21 | en | 2 | terms and conditions | two columns with column rule across pages; three-level typed clause numbering "2.1" / "(a)" / "(i)"; definitions key/value table; @page margin boxes | Goudy Old Style (Regular, Bold, Italic) |
| h22 | pl | 1 | installation manual | warning box; key/value spec table beside a CSS bullet list; CSS steps with nested typed "a)"; Courier New config block; troubleshooting table ruled under header | Trebuchet MS (Regular, Bold), Courier New |
| h23 | en | 1 | certificate of analysis | Product and Lot panels side by side; wide 9-column results table with two-level header and row rules only; literal "<" in cells; signatures side by side | Roboto (Regular, Bold), Roboto Condensed (Regular, Bold) |
| h24 | en | 2 | tenants' newsletter | masthead; three- and two-column articles with a pull quote; sidebar boxes read after the main area; zebra events table; typed date markers in a hanging list | Gill Sans MT (Regular, Bold, Italic), Rockwell (Regular, Bold) |

Each `expected.json` carries document-specific notes for the scorer
(reading order of side-by-side boxes, which markers are typed and which CSS
draws, spans, and anything else a scorer must know).
