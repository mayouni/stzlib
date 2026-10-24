# Golden set v20 -- 24 realistic PDF documents with known structure

## What this set is

Twenty-four whole documents of the kinds real organisations produce (bills, minutes, notices, a judgment,
a task card, a syllabus, a policy schedule and so on), ids `c01` to `c24`. Each document comes as three files:

- `cNN.html` -- the source page;
- `cNN.pdf` -- the same page printed to PDF by headless Chrome;
- `cNN.expected.json` -- the structure a document reader should recover: title, headings in order,
  4 to 10 body sentences in reading order, tables as grids, visible lists, page furniture, languages, code
  blocks, and `notes` naming every convention a scorer must know for that document.

All organisations, people, addresses, numbers and identifiers are invented; e-mail and web domains use
`.example`. Seventeen languages besides English appear: fr, de, ar, he, ja, zh, ko, th, es, pt, ru, el, hi,
tr, sw, vi, pl. Two documents are right-to-left (c04 Arabic, c05 Hebrew), both with lists and tables.
Twelve documents have 2 or 3 pages. One is A4 landscape (c12).

## How it was made

1. One Python generator (kept outside the repository) describes each document once. From that single
   description it writes the HTML **and** the expected JSON, so every expected string is the text that was
   put on the page, normalised as the JSON rules require (tags removed, whitespace runs collapsed, soft
   hyphens removed, NFC). Key sentences were marked inside the source text; tables were expanded from their
   row and column spans into full grids (a merged cell repeats its text in every grid cell it covers).
2. Every page is a fixed-size box (210 x 297 mm, or 297 x 210 mm for c12) printed with `@page { margin: 0 }`,
   because every document carries letterheads, running headers, footers or page numbers placed in the margin
   area of the body. Page breaks are therefore chosen by the author, never by the browser: a table continued
   across pages is written as two tables with the header repeated, and recorded as ONE table with its header
   once.
3. Before printing, each page was loaded in headless Chrome with a checking script (in a separate copy of the
   HTML, never in the published one) that reported any page body whose content overflowed its box, any
   element running past the page or body edge, any furniture line that wrapped onto two lines, and every
   (font family, weight, style) with the characters set in it. Each character was looked up in the cmap of
   the installed font file that family, weight and style resolve to; every family was checked against the
   font files in `C:\Windows\Fonts`, and variable fonts were avoided. Final state: no overflow, no wrapped
   furniture line, no missing glyph, no synthesised bold or italic.
4. Printing: `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch profile>
   --print-to-pdf=<abs>\cNN.pdf file:///<abs>/cNN.html`.
5. After printing, the raw PDF bytes were read for the page count (`/Type /Page` objects and `/Count`, which
   agree with the number of page boxes in every file) and for the `/BaseFont` names of the embedded fonts,
   which were compared with the families the check reported. This found two problems, both fixed: Chrome
   resolved "Franklin Gothic Medium" to Franklin Gothic Demi, and "Franklin Gothic Demi" fell back to Times
   New Roman (c01, replaced by Candara); a prime sign missing from Tw Cen MT fell back to Times New Roman
   (c22, replaced by text). In the final files every embedded font is a face of a family the HTML names.
6. The HTML pages were also rendered to screenshots (of the HTML, not of the PDF) and looked at by the author.
   This found a totals row whose white text sat on a pale stripe (c20) and a spaced number reordered by the
   bidirectional algorithm (c04). Both were fixed.

**Independence.** The author of this set never ran, imported or opened any PDF-to-text or document-conversion
tool or any PDF rasterizer, never looked at any reader's code or output, and never opened golden_v1 to
golden_v19 or any results file. The PDFs were inspected only as raw bytes, for page counts and font names.

## Conventions shared by all 24 files

- Texts match the visible text: ligatures as their letters; soft-hyphenated words given whole; whitespace
  runs (including non-breaking and ideographic spaces) collapse to one space, except in `code`; NFC.
- Chinese, Japanese and Thai text joins a line wrapped inside a sentence with no space.
- Right-to-left text is given in logical order; right-to-left table rows list the rightmost column first.
- A table cell of several lines is given with its lines joined by one space.
- Lists: a TYPED marker is part of the item text (`"1.1 Dues are ..."`); a CSS-DRAWN marker (a box, disc, bar,
  triangle, diamond or cross painted by CSS, with no glyph in the text) is not. Each file's notes say which
  lists are which.
- The title is the first heading, at level 1. A letterhead's organisation name, table captions, titles of
  key/value boxes, table header cells and form labels are not headings.
- Furniture: one visible line per entry; a repeated running header or footer is listed once; page-number
  lines are listed once per page.
- Key sentences never include a sentence that carries a footnote marker.

## Documents

| id | document | kind | languages | pages | embedded font families | main difficulties |
|---|---|---|---|---|---|---|
| c01 | Port authority tariff schedule | ports | en | 2 | Candara, Franklin Gothic Book, Georgia | two-level header table across pages with section rows and a 4-column merged cell; typed 1.1 list; letter-spaced letterhead; running header on p.2 only |
| c02 | Medical laboratory report | medical | fr | 1 | Calibri | side-by-side key/value boxes; results table with section rows, two-line top-aligned cells, flagged values |
| c03 | Council meeting minutes | municipal | de | 2 | Gill Sans MT, Palatino Linotype | borderless key/value table; TOP agenda list, a)/b) and dash lists; two-level budget table with totals; soft-hyphenated compounds; side-by-side signatures |
| c04 | Water utility bill | water / utilities | ar | 1 | Sakkal Majalla, Simplified Arabic | RTL Arabic; Arabic-Indic digits; line items with subtotal, VAT and total; typed and CSS-drawn lists; key/value table |
| c05 | Library loan regulations | libraries | he | 2 | Arial, Times New Roman | RTL Hebrew; Hebrew-letter and decimal typed lists with nesting; CSS-drawn list; centred two-line cells; section rows |
| c06 | Railway timetable revision notice | railways / transport | ja | 1 | Yu Gothic | Japanese without spaces; full-width typed markers; row-spanning station cells; letter-spaced title |
| c07 | County rice-seed subsidy notice | agricultural / government | zh | 2 | Microsoft YaHei, SimSun | Chinese without spaces; red letterhead with document number; two-level header; totals row; typed and CSS-drawn lists |
| c08 | Health insurance benefit statement | health insurance | ko | 1 | Malgun Gothic | Korean; side-by-side key/value boxes; zebra claims table with merged totals cell; typed notes list |
| c09 | Hotel booking confirmation | hospitality / tourism | th | 1 | Leelawadee UI | Thai without word spaces; table beside text; price table with subtotal, service, VAT, total and balance; Buddhist-era dates |
| c10 | Home insurance policy schedule | insurance | es | 2 | Segoe UI, Segoe UI Semibold | side-by-side boxes; 4-column key/value table; coverage table across pages with section rows and centred two-line cells; premium totals; side-by-side signature boxes |
| c11 | Router field deployment guide | telecom / technical | en | 3 | Consolas, Trebuchet MS, Verdana | 3 pages; shell, YAML and INI code blocks; three heading levels; CSS-drawn and Step-n typed lists; two-line top-aligned cells |
| c12 | Pension fund annual statement | pensions / financial | pt | 1 | Corbel | A4 landscape; three side-by-side boxes; wide 7-column table with two-level header, italic allowance rows and totals; Portuguese number format |
| c13 | Underground mine safety instruction | mining | ru | 2 | Cambria | Russian; numbered typed lists with nested Cyrillic-letter items; CSS-drawn dash list; subscript formulas; approval block |
| c14 | Museum exhibition guide | cultural | el | 1 | Constantia | Greek; two flowing CSS columns with in-column headings; drop cap; full-width zebra programme table |
| c15 | Commercial court judgment | courts / legal | en | 3 | Times New Roman | 3 pages; numbered body paragraphs (not a list); footnote markers and footnotes; layout table for parties; running header from p.2 |
| c16 | Municipal election voter notice | elections | hi | 1 | Nirmala UI | Hindi (Devanagari); two-level header with merged totals; typed letter list and CSS-drawn diamond list |
| c17 | Aircraft maintenance task card | aviation | en | 2 | Arial Narrow, Courier New | condensed type; ACARS monospaced block; wide procedure table across pages with two-line cells; empty signature column |
| c18 | Customs import tax summary | customs / logistics | tr | 1 | Tahoma | Turkish; 4-column key/value table with two-line values; goods and tax tables with totals; two-column typed list |
| c19 | NGO water project quarterly report | NGO | sw | 1 | Century Gothic, Rockwell | Swahili; indicators table; expenditure table with section rows and totals; CSS-drawn and roman typed lists |
| c20 | Electricity bill | energy / utilities | en | 2 | Roboto, Roboto Condensed | recipient address block; side-by-side boxes; zebra charges table with negative credit and totals; wide 13-column usage table; payment slip |
| c21 | University course syllabus | educational | vi | 2 | Open Sans | Vietnamese (stacked diacritics); side-by-side letterhead blocks; 15-week table across pages; assessment totals; [n] reference list |
| c22 | Freight forwarding invoice | logistics / commercial | en | 1 | Tw Cen MT | three side-by-side party boxes; borderless, partly ruled charges table with section rows, subtotal, VAT and total; bank key/value box |
| c23 | Forest timber auction notice | forestry | pl | 1 | Bookman Old Style | Polish; two-level header; row-spanning forest-range cells; merged totals; nested typed lists; side-by-side signatures |
| c24 | Parish council annual report | religious / financial | en | 2 | Garamond, Perpetua | two-level financial statement with section rows, parentheses negatives and net row; table beside text; CSS-drawn cross markers; roman page numbers |

## Embedded fonts per document

PostScript names from `/BaseFont`, subset prefix removed.

- **c01**: Candara, Candara-Bold, FranklinGothic-Book, FranklinGothic-BookItalic, Georgia, Georgia-Italic
- **c02**: Calibri, Calibri-Bold, Calibri-Italic
- **c03**: GillSansMT, GillSansMT-Bold, GillSansMT-Italic, PalatinoLinotype-Bold, PalatinoLinotype-Roman
- **c04**: SakkalMajalla, SakkalMajalla-Bold, SimplifiedArabic-Bold
- **c05**: Arial-BoldMT, ArialMT, TimesNewRomanPS-BoldMT, TimesNewRomanPSMT
- **c06**: YuGothic-Bold, YuGothic-Regular
- **c07**: MicrosoftYaHei, MicrosoftYaHei-Bold, SimSun
- **c08**: MalgunGothic, MalgunGothicBold
- **c09**: LeelawadeeUI, LeelawadeeUI-Bold
- **c10**: SegoeUI, SegoeUI-Bold, SegoeUI-Semibold
- **c11**: Consolas, TrebuchetMS, TrebuchetMS-Bold, Verdana, Verdana-Bold
- **c12**: Corbel, Corbel-Bold, Corbel-Italic
- **c13**: Cambria, Cambria-Bold, Cambria-BoldItalic, Cambria-Italic
- **c14**: Constantia, Constantia-Bold, Constantia-BoldItalic, Constantia-Italic
- **c15**: TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT, TimesNewRomanPSMT
- **c16**: NirmalaUI, NirmalaUI-Bold
- **c17**: ArialNarrow, ArialNarrow-Bold, CourierNewPSMT
- **c18**: Tahoma, Tahoma-Bold
- **c19**: CenturyGothic, CenturyGothic-Bold, Rockwell-Bold
- **c20**: Roboto-Bold, Roboto-Regular, RobotoCondensed-Bold
- **c21**: OpenSans, OpenSans-Bold
- **c22**: TwCenMT-Bold, TwCenMT-Regular
- **c23**: BookmanOldStyle, BookmanOldStyle-Bold
- **c24**: Garamond, Garamond-Bold, Garamond-Italic, Perpetua, Perpetua-Bold
