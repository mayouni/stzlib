# golden_v22 -- 24 realistic documents with known structure

An independent golden set for scoring document readers (Docling and Softanza's native PDF reader).
Each document `eNN` has three files:

- `eNN.html` -- the source, written by hand-authored generator code;
- `eNN.pdf` -- the same page printed by headless Chrome;
- `eNN.expected.json` -- the structure the PDF is known to contain.

## How it was made

Each document was written in Python as content plus layout. The same call that wrote a sentence, heading, table
cell, list item, code line or furniture line into the HTML also recorded it for `expected.json`, so the expected
text is the text that was typeset, not a reading of the PDF. The HTML was then printed with

    chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch profile> --print-to-pdf=eNN.pdf file:///.../eNN.html

(Chrome 156, Windows 11). Running headers, footers and page numbers are CSS `@page` margin boxes
(`counter(page)`/`counter(pages)`, with `arabic-indic`, `persian`, `devanagari` and `thai` counter styles where the
document's language uses them). The page counts in `expected.json` were read from the raw PDF bytes
(`/Type /Page` objects and `/Count`); the per-page page-number furniture lines were generated from that count.

Checks made before and after rendering:

- every font family named in the CSS is installed in `C:\Windows\Fonts` (checked against the name tables), and
  none of them is a variable font (no `fvar` table);
- every character of every document exists in the cmap of each font face it is set in (regular, bold, italic,
  bold italic) -- zero missing characters in all 24 documents; code blocks were checked against their
  monospaced font (Consolas or Courier New);
- after rendering, the `/BaseFont` names in the raw PDF bytes were mapped back to the installed font files:
  every embedded font is one the document asked for, and no fallback font was embedded in any document.

**The author never ran a PDF-to-text extractor, document converter or rasterizer on these PDFs, never looked at
any reader's code or output, and never opened golden_v1 to golden_v21.** All organisations, people, addresses,
numbers and e-mail domains (`.example`) are invented.

## Conventions used in expected.json

- `headings`: document order, title first at level 1. Letterhead organisation names, box labels, table header
  cells and form labels are not headings. Typed section numbers ("1.", "§ 1.", "I.", "一、") are part of the
  heading text.
- `key_sentences`: 4 to 10 body sentences, exactly as typeset, in reading order. A sentence carrying a footnote
  marker is never included. Non-breaking spaces are given as ordinary spaces.
- `tables`: header row(s) first. A two-level header gives two header rows; a merged cell repeats its text in
  every grid cell it covers (including merged total rows and section rows). Key/value panels have no header
  row. A table that continues across pages is one table with its header row once, even where Chrome repeats the
  header on the next page. Right-to-left tables list cells in logical order, rightmost column first. A cell of
  several lines is given with its lines joined by one space, except in Chinese, Japanese and Thai, where cells
  wrap without spaces and join with none. Empty cells are `""`.
- `list_items`: level 0 is the outermost. Typed markers are part of the text, followed by one space -- except
  the CJK markers in e05 and e08 (`（１）`, `①`, `ア`, `（一）`), which are written directly against the text and
  are recorded with no space. Markers drawn by CSS (`<ul>`/`<ol>` markers and `::before` dashes) are not in the text.
  Each document's `notes` say which of its markers are typed and which CSS draws.
- `furniture`: letterhead lines, running header/footer lines (once each), then one page-number line per page.
- Real hyphens (Paul-Émile, Lindqvist-Obi, PS-400) are part of the words; Chrome applied no automatic
  hyphenation, so no word is broken by a soft hyphen.
- All text is NFC. Arabic and Persian use no diacritics and no zero-width non-joiners.

## Documents

| id | lang | kind | pages | difficulty | main difficulties |
|---|---|---|---|---|---|
| e01 | en | Trade invoice (joinery firm) | 1 | medium | letterhead + boxed key/value panel beside it; two side-by-side address boxes; full-grid line items with merged total rows and a two-line cell; payment panel beside a nested CSS list |
| e02 | fr | Association general-meeting minutes | 2 | medium | running header; borderless attendee table; typed "1." / "a)" agenda with hanging indent; CSS en-dash list; typed "•" list; budget table with section and total rows, rules between rows; multi-line top-aligned cells; side-by-side signatures |
| e03 | de | Installation guide (print server) | 2 | hard | two-level header with row/col spans and a 4-column merged row; CSS <ol> decimal + lower-alpha; shell and INI code blocks (Consolas); header-rule-only table; typed en-dash list; note box |
| e04 | ar | Quarterly performance report (water utility) | 2 | hard | RTL; Arabic-Indic digits incl. margin-box page numbers; zebra KPI table; ruled budget table with total row; CSS nested bullets; typed Arabic-letter markers; typed Arabic-Indic numbered list with nested dash |
| e05 | ja | Company regulation (telework rules) | 1 | hard | chapter/article heading levels; typed full-width （１）, circled ①, katakana ア markers with no space; full grid with centred wrapping cells; no-space line joins |
| e06 | en | Two-column technical report | 2 | hard | full-width title + abstract over two CSS columns read column by column across 2 pages; footnoted sentence; pseudo-code block; booktabs-style table; typed [n] references |
| e07 | he | Office lease agreement | 2 | hard | RTL; boxed parties panel; typed 1.1 / (א) clause numbering with hanging indent; full-grid payment schedule with merged total; side-by-side signature boxes read right first |
| e08 | zh | Purchase order | 1 | medium | letterhead; two side-by-side key/value boxes; line items with header rule only and merged total; typed 一、 headings; typed （一） and nested 1. lists; no-space joins |
| e09 | ru | Laboratory test report | 2 | hard | approval block; key/value grid; two-level header with rowspans; multi-line vertically centred cells; Cyrillic а) markers; typed 1) inline notes; ruled equipment table |
| e10 | en | Conference programme | 1 | medium | banner furniture; main column + shaded sidebar read box by box; zebra timetable with section rows and two-line cells; CSS square bullets in the sidebar; borderless key/value |
| e11 | es | Renovation estimate | 2 | hard | letterhead; side-by-side boxes; ONE long table crossing pages 1-2 with repeated header, chapter (section) rows, subtotal and total rows; partly ruled; typed a) list with nested typed dashes; running header from page 2 |
| e12 | el | Municipal press release | 1 | easy | centred letterhead; kicker and dateline that are not headings; typed en-dash list inline; table with no lines; end mark ### |
| e13 | en | Software release notes | 2 | medium | three-level CSS list (disc/circle/square); typed 1. list; shell and YAML code blocks (Courier New); known-issues table with rules between rows and multi-line cells |
| e14 | hi | School circular | 1 | medium | Devanagari letterhead; full-grid timetable with two-line cells; typed Devanagari-digit markers १. with nested (क); Devanagari page-number margin box |
| e15 | fa | Sales invoice | 1 | hard | RTL; Persian digits; seller/buyer boxes read right box first; partly ruled line items with three merged total rows; typed ۱- list inline |
| e16 | en | Staff handbook chapter | 3 | hard | 3 pages; typed Roman-numeral headings; floating key/value panel beside text; typed (a)/(i) nested lists; full grid with two-line cell; zebra table; CSS list with bold lead-ins |
| e17 | ko | Quotation | 1 | medium | letter-spaced title; two side-by-side panels (borderless key/value and full-grid supplier form); full-grid items with merged totals and empty cells; typed 가. and nested 1) markers |
| e18 | tr | Monthly maintenance report | 1 | medium | boxed key/value; zebra table; CSS upper-roman <ol> with nested lower-alpha; typed • list with hanging indent |
| e19 | en | Savings account statement | 3 | hard | 3 pages; wide 7-column table (Arial Narrow) running across all three pages with repeated header; empty cells; merged closing-total row; side-by-side address and summary panel; running header from page 2 |
| e20 | vi | Recruitment notice (administrative layout) | 2 | hard | two-block national header as furniture; full grid with two-line cells and merged empty cell; typed dash and 1./a) lists; boxed contact panel; side-by-side recipients list and signature |
| e21 | pl | Housing-cooperative regulation | 2 | hard | § headings; three typed list levels 1. / 1) / a) with hanging indents; zebra fee table with a two-line cell; Polish quotation marks |
| e22 | en | Product data sheet | 1 | medium | colour band furniture; two side-by-side CSS lists; two-level spec header with spans; floating key/value panel beside text; table with no lines |
| e23 | sw | Cooperative annual report | 2 | medium | caption below table; header-rule-only table; CSS bullets; typed (i)/(ii) roman markers; boxed finance panel; typed 1. inline with nested a) |
| e24 | th | Company announcement (system maintenance) | 1 | hard | Thai digits incl. page number; no spaces between words; full grid with wrapping cells; typed ๑. and nested ก. markers |

Side-by-side boxes read box by box: e01, e08, e10, e11, e15, e17, e19, e20, e22 (e07 and e15 read the right box
first, being right-to-left). Tables across pages: e11, e19. Code blocks: e03, e06, e13.

## Fonts embedded (from the /BaseFont entries of each PDF)

Subset prefixes (`AAAAAA+`) are omitted. e10 asks for "Franklin Gothic Medium" for its headings; Chrome resolved it
to the Franklin Gothic Demi face (FRADM.TTF), which is installed and was included in the character check. e20
embeds Tahoma twice because Chrome synthesises an oblique for the italic date line (Tahoma has no italic face);
SimSun bold in e08 is likewise synthesised.

| id | families named in the CSS | embedded /BaseFont |
|---|---|---|
| e01 | Calibri | Calibri, Calibri-Bold |
| e02 | Georgia | Georgia-Italic, Georgia, Georgia-Bold |
| e03 | Segoe UI, Consolas | SegoeUI, SegoeUI-Semibold, SegoeUI-Bold, Consolas |
| e04 | Sakkal Majalla | SakkalMajalla, SakkalMajalla-Bold |
| e05 | Yu Gothic | YuGothic-Regular, YuGothic-Bold |
| e06 | Cambria, Calibri, Consolas | Calibri, Calibri-Bold, Cambria, Cambria-Italic, Calibri-BoldItalic, Consolas, Cambria-Bold |
| e07 | Times New Roman, Arial | ArialMT, Arial-BoldMT, TimesNewRomanPSMT, TimesNewRomanPS-BoldMT |
| e08 | SimSun, Microsoft YaHei | SimSun, MicrosoftYaHei-Bold |
| e09 | Times New Roman | TimesNewRomanPSMT, TimesNewRomanPS-BoldMT |
| e10 | Franklin Gothic Book, Franklin Gothic Medium, Franklin Gothic Demi | FranklinGothic-Book, FranklinGothic-Demi |
| e11 | Verdana | Verdana, Verdana-Bold, Verdana-Italic |
| e12 | Palatino Linotype | PalatinoLinotype-Bold, PalatinoLinotype-Roman, PalatinoLinotype-Italic |
| e13 | Segoe UI, Courier New | SegoeUI, SegoeUI-Bold, CourierNewPSMT |
| e14 | Nirmala UI | NirmalaUI, NirmalaUI-Bold |
| e15 | Tahoma | Tahoma, Tahoma-Bold |
| e16 | Constantia, Gill Sans MT | GillSansMT, Constantia, GillSansMT-Bold, Constantia-Bold |
| e17 | Malgun Gothic | MalgunGothic, MalgunGothicBold |
| e18 | Roboto | Roboto-Regular, Roboto-Bold |
| e19 | Arial, Arial Narrow | ArialMT, Arial-BoldMT, ArialNarrow, ArialNarrow-Bold |
| e20 | Tahoma | Tahoma, Tahoma-Bold, Tahoma |
| e21 | Candara | Candara, Candara-Bold, Candara-Italic |
| e22 | Corbel | Corbel, Corbel-Bold |
| e23 | Book Antiqua, Century Gothic | CenturyGothic, CenturyGothic-Bold, BookAntiqua-Italic, BookAntiqua |
| e24 | Leelawadee UI | LeelawadeeUI, LeelawadeeUI-Bold |
