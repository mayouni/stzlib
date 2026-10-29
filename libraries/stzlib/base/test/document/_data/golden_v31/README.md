# golden_v31 -- independent golden set, version 31

24 realistic documents (s01 .. s24), each with three files: `sNN.html` (the source), `sNN.pdf` (the document to be read) and `sNN.expected.json` (the known structure: title, headings with level, key sentences in reading order, tables as grids, list items with level, page furniture, languages, code blocks, and notes for the scorer).

## What the set is

A test set for document readers (Docling and Softanza's native PDF reader). Every document is a whole document of a kind real organisations produce: invoice, circular, catalogue, manual, report, minutes, statement, contract terms, programme, quotation, payroll summary, rules, course outline, notice, itinerary, paper, release notes, brochure, financial summary, handbook, recipe booklet, inspection form. All organisations, products, places and figures are invented; no real person or company is named.

* Languages: English and sixteen others -- Arabic, Hebrew and Persian (right-to-left, with lists and tables), Russian, Chinese, Japanese, Korean, Hindi, German, French, Spanish, Turkish, Polish, Greek, Thai, Italian.
* 19 of the 24 documents have 2 or 3 pages; s12 is landscape.
* Tables: full grids, rules between rows only, rules under the header only, zebra bands, boxed key/value panels, tables with no lines, two-level headers, merged cells (row and column spans), section rows, total rows, wide tables, multi-line cells top-aligned and centred, a table continued across a page break (s21), tables beside text (s12, s20, s23).
* Lists: bullets drawn by CSS, typed bullets and dashes, decimal "1." / "1)" / "1.1" / "(1)", "(a)", "a)", roman numerals, "1°", letters of the Arabic, Hebrew, Greek, Devanagari, Thai, Hangul and Persian scripts, digits of the Arabic-Indic, Persian, Devanagari and Thai scripts, full-width CJK markers, circled digits; markers set apart by a hanging indent and markers inline; nested up to three levels. The `notes` of each expected file say which markers are typed and which are drawn by CSS.
* Boxes or columns side by side whose reading order is box by box: s01, s03, s07, s08, s11, s15, s19, s23, s24; a text column then a panel in s20 and s12; CSS text columns read column by column in s10 and s17.
* Page furniture: letterheads, running headers and footers, page numbers in forms such as "Page 1 of 2", "صفحة ١ من ٢", "第1页，共2页", "- 1 -", "1 / 2", "– 1 –", "Pagina 1 di 2", "หน้า 1/1"; in s21 the header and footer are drawn in the page margins by CSS (@page margin boxes).
* Code or configuration blocks: s04, s09, s17, s18 (Consolas or Courier New).

## How it was made

The author is a language-model session (Claude) working alone. For each document a small Python builder wrote the HTML and, from the very same call, recorded the expected structure, so the expected text is the visible text by construction (title, headings, sentences marked in the source, table cells with spans expanded to grid cells, list items with or without their typed markers, furniture lines). The HTML was then rendered with headless Chrome (`--headless=new --no-pdf-header-footer`, A4, page margin 0 with the furniture placed in the body, except s21 which uses a 2 cm page margin and CSS margin boxes). The page count in each expected file is the count of the rendered PDF, read from the raw PDF bytes (`/Type /Page` objects, checked against `/Count`). The generator scripts and the Chrome profile are kept outside the repository.

Checks run: every font family named is installed in `C:\Windows\Fonts` and none is a variable font; every character of every document is present in the union of the cmaps of the fonts named for it (read with fontTools, a font-file reader and not an extractor); the `/BaseFont` names in each PDF contain the intended fonts and no other font (so no fallback font was used); each page's content was measured in the browser (DOM geometry) to be free of overflow and clipping.

**The author never ran, imported or opened any PDF-to-text or document-conversion tool, any PDF rasterizer, any reader's code or any reader's output; never opened golden_v1 .. golden_v30; and never saw how any reader does on this set.** Nobody has looked at the rendered PDFs on a screen: layout was verified by DOM measurement, not by eye. This evidence is instrumental only (unperceived); the set should be looked at once by a person.

## Conventions a scorer must know (repeated in the `notes` of the files concerned)

* A furniture line made of a left, a centre and a right part (a header or a footer row) is ONE entry, with the parts joined by one space in reading order (logical order in right-to-left documents). A running header repeated on every page is listed once; page-number lines are listed once per page.
* Letterhead lines are furniture; the organisation name is not a heading. Table header cells, form labels and band subtitles are not headings.
* Merged table cells repeat their text in every grid cell they cover. A table continued across a page break is one table (s21: the repeated header row is drawn twice but listed once). Right-to-left tables list cells in logical order (rightmost first).
* `key_sentences` are complete sentences of body text. Sentences with a footnote marker (s17) are left out. Where a document has more than ten body sentences (s17, s22), `key_sentences` is an evenly spaced selection of ten, in reading order.
* Soft hyphens (s09) and non-breaking spaces are ignored; zero-width non-joiners in Persian text (s14) are part of the text. In Chinese, Japanese and Thai a line wrapped inside a sentence joins with no space.
* A typed marker is part of the list item text ("1) text"); a CSS-drawn marker is not.
* Form answer cells (s24) are empty strings.

## Fonts embedded

Fonts come from the raw PDF `/BaseFont` names (subset prefixes removed). Every document embeds exactly the fonts it was meant to; there was no fallback font and none was missing. Bold and italic faces are listed as Chrome names them.

## The 24 documents

| id | kind | lang | pages | fonts embedded | main difficulties | PDF bytes |
|---|---|---|---|---|---|---|
| s01 | Invoice with letterhead | en | 1 | Calibri-Bold, Calibri | section rows, zebra table, totals rows, key/value tables, Bill-to/Ship-to boxes side by side, CSS bullets | 71108 |
| s02 | Municipal circular (RTL) | ar | 2 | TraditionalArabic-Bold, TraditionalArabic, Tahoma-Bold, Tahoma | right-to-left, Arabic-letter and Arabic-Indic typed lists with hanging indent, schedule table, Arabic-Indic page numbers, running header | 104946 |
| s03 | Community-centre class catalogue (RTL) | he | 2 | SegoeUI-Bold, SegoeUI | right-to-left, Hebrew-letter typed list with nested digits, two boxes side by side (box by box), table with a two-line cell, colour band at the top | 54646 |
| s04 | Device installation manual | ru | 2 | Verdana-Bold, Verdana, Consolas | two-level table header with row/column spans, "1)" and "2.1" typed outline numbers, configuration code block, ruled-rows table with two-line cells, typed heading numbers | 74126 |
| s05 | Annual work report | zh | 2 | MicrosoftYaHei-Bold, MicrosoftYaHei | no spaces between words, full-width list markers (parenthesised ideographic numerals, full-width stop, ideographic comma), ruled grid table with caption and total row | 152267 |
| s06 | Meeting minutes | ja | 2 | YuGothic-Regular, YuGothic-Bold | no spaces between words, circled-digit and full-width parenthesised markers, borderless agenda table, boxed key/value panel, typed middle-dot bullets | 122283 |
| s07 | Maintenance-fee statement | ko | 2 | MalgunGothicBold, MalgunGothic | wide numeric table with section rows, subtotals and zebra bands, two summary boxes side by side, Hangul-letter typed markers | 83166 |
| s08 | School admission circular | hi | 2 | NirmalaUI-Bold, NirmalaUI | Devanagari typed numerals and letters, CSS-numbered Devanagari list, two-level header, centred two-line cells, two boxes side by side | 61382 |
| s09 | Contract terms (3 pages) | de | 3 | TimesNewRomanPS-BoldMT, TimesNewRomanPSMT, CourierNewPSMT | section-sign headings, (1)/a)/aa) three-level typed numbering inline, soft hyphens in justified text, row-rules price table, code block, CSS bullets | 120275 |
| s10 | Conference programme | fr | 2 | Garamond, Garamond-Italic, Garamond-Bold | two CSS text columns (reading column by column), borderless timetables, "1°" typed markers with nested en dashes, typed bullets, boxed key/value panel | 199291 |
| s11 | Renovation quotation | es | 2 | TrebuchetMS-Bold, TrebuchetMS | two-level header, chapter rows spanning the table, subtotal/total rows, European number format, nested typed lists, two signature boxes side by side | 81201 |
| s12 | Payroll summary (landscape) | tr | 1 | Tahoma-Bold, Tahoma | landscape page, nine-column wide table with wrapped header cells and total row, text beside a small table, typed "1)" notes | 78480 |
| s13 | Library rules | pl | 2 | Georgia-Bold, Georgia | "1)" / "a)" / dash three-level typed markers, zebra table, rules-only hours table, CSS check-mark bullets | 70632 |
| s14 | University course outline (RTL) | fa | 2 | Arial-BoldMT, ArialMT | right-to-left with zero-width non-joiners, Persian digits and letters as typed markers, key/value panel, zebra plan table | 76326 |
| s15 | Municipal works notice | el | 1 | Cambria-Bold, Cambria | Greek-letter and roman-numeral typed markers, centred letterhead, boxes side by side, header-and-foot-rules table | 48436 |
| s16 | Tour itinerary | th | 1 | LeelawadeeUI-Bold, LeelawadeeUI | no spaces between words, row-spanning day cells, Thai-digit and Thai-consonant typed markers, CSS bullets | 49416 |
| s17 | Two-column scientific paper (3 pages) | en | 3 | Constantia-Bold, Constantia, Constantia-Italic, Constantia-BoldItalic, Consolas | CSS columns read column by column, captioned booktabs table, inline roman markers, code listing, [1] references with hanging indent, footnote marker | 80341 |
| s18 | Software release notes | en | 2 | SegoeUI-Bold, SegoeUI, Consolas | three heading levels, three code blocks (shell, YAML, output), monospaced option column, typed numbered steps, CSS diamonds, typed dashes | 69582 |
| s19 | Committee minutes | en | 1 | Cambria-Bold, Cambria | (a)/(i) nested typed markers under 1.1 numbering, attendance boxes side by side, centred and top-aligned multi-line cells | 49634 |
| s20 | Product brochure | en | 2 | CenturyGothic-Bold, CenturyGothic | coloured hero band, text column beside a boxed spec panel, CSS round bullets, zebra table, nested typed care list, key/value contact table | 67485 |
| s21 | Financial summary | en | 2 | Tahoma, Georgia-Bold, Georgia, Verdana | page-margin furniture drawn by CSS, two-level header with section and total rows, a long table continued across a page break with repeated header | 169366 |
| s22 | Laboratory safety handbook (3 pages) | en | 3 | Candara-Bold, Candara | decimal-numbered headings (1, 1.1), CSS-numbered nested lists, warning boxes, centred matrix table, top-aligned multi-line cells, en-dash page numbers | 67126 |
| s23 | Recipe booklet | it | 2 | PalatinoLinotype-Roman, PalatinoLinotype-Italic, PalatinoLinotype-Bold | ingredient tables beside method lists, three typed marker conventions ("1." / "1)" / roman), CSS bullets, zebra summary table | 116264 |
| s24 | Inspection form | en | 2 | Arial-BoldMT, ArialMT | form labels that are not headings, empty answer cells, CSS check boxes, room section rows, two signature areas side by side, CSS-numbered instructions | 73456 |
