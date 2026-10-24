# golden_v19 -- independent golden set, table-rich (b01 .. b24)

Twenty-four whole documents of kinds that organisations really produce, each given as
`<id>.html` (the source), `<id>.pdf` (the rendering) and `<id>.expected.json` (the known
structure). The set is meant to score document readers. It is **table-rich**: every document carries
at least one table and 20 of the 24 carry two or more, in many styles, while remaining complete documents
with headings, paragraphs, lists and page furniture. All organisations, people, addresses,
telephone numbers and account numbers are invented.

## How it was made

- Each document was written as data in a Python generator (kept outside the repository).
  The same source produced the HTML and the expected JSON, so every expected text is
  derived from the text that was laid out, never retyped. Totals in invoices, budgets,
  statements and bills were computed by the generator.
- Multi-page documents are built as explicit A4 page boxes (`@page { size: A4; margin: 0 }`)
  so that running headers, footers and page numbers are real text in the page body and
  each page's content is known exactly. Every page box was checked for overflow in headless
  Chrome before rendering (no content clipped; the fullest page uses 94 % of its box).
- PDFs were rendered with headless Chrome 155:
  `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch> --print-to-pdf=<id>.pdf file:///.../<id>.html`
- Fonts: only fonts installed in `C:\Windows\Fonts`, none variable. Before rendering,
  every character of each text role (body, headings, code, letterhead) was checked against
  the cmap of the font set for it (fontTools); no character was missing. After rendering,
  the `/BaseFont` names were read from the raw PDF bytes and compared with the fonts
  intended: every document embeds exactly the intended fonts and no fallback font.
  (One fallback was caught this way during authoring -- "Franklin Gothic Demi" fell back
  to Times New Roman in b22 -- and the heading font was changed to Arial Narrow.)
- Page counts were checked from the raw bytes (`/Type /Page` objects and `/Count`) and
  equal the `pages` value in every expected file. All pages are A4 (b17 is A4 landscape).

**Independence.** The author of this set never ran, imported or opened any PDF-to-text or
document-conversion tool, any PDF rasterizer, any reader's code or any reader's output, and
never looked at golden_v1 .. golden_v18. The only rendering used for checking was headless
Chrome itself: layout measurements and a few screenshots of the author's own HTML pages.

## Conventions used in the expected files

- `headings`: document order, title first at level 1. Letterhead names, table header cells,
  captions, form labels ("Bill to", "Client", "Account summary") are not headings.
- `key_sentences`: body sentences exactly as visible, in reading order. Where two boxes
  or columns stand side by side the reading order is **box by box** (left box first, or
  right box first in right-to-left documents); b20 is in two CSS columns, read column by
  column.
- `tables`: header rows first (two header rows where the table has a two-level header);
  merged cells repeat their text in every grid cell they cover; section rows and totals
  rows are rows of the same table; a table continued across pages is one table with its
  header once, whether or not the header is repeated on the next page; cells of two lines
  are joined with one space; empty cells are `""`. Right-to-left tables list cells in
  logical order, rightmost column first.
- `list_items`: the marker is included when it is typed in the text (`a)`, `(1)`, `١.`,
  `※`, `–`, `가.` ...), and omitted when CSS draws it (disc, square, circle, decimal,
  lower-alpha, arabic-indic). Each document's notes say which.
- `furniture`: one visible line per entry; a running header or footer is listed once;
  page-number lines are listed once per page. Where a running footer text and a page
  number share a baseline at opposite margins they are two entries.
- No-break spaces (French punctuation, thousands separators) and the ideographic space
  (b05) count as ordinary spaces. Texts are NFC. No word is hyphenated anywhere; words
  containing hyphens, dashes or slashes are kept on one line.
- `code`: exact text, lines joined with `\n`, alignment spaces kept, no line numbers.

## Fonts embedded (from /BaseFont)

| id | fonts embedded |
|----|----------------|
| b01 | Calibri, Calibri-Bold, Cambria-Bold |
| b02 | SegoeUI, SegoeUI-Bold |
| b03 | Constantia, Constantia-Bold, Corbel-Bold, Corbel-Italic |
| b04 | SakkalMajalla, SakkalMajalla-Bold, Arial-BoldMT |
| b05 | YuGothic-Medium, YuGothic-Bold |
| b06 | Verdana, Verdana-Bold |
| b07 | PalatinoLinotype-Roman, -Bold, -Italic, GillSansMT, GillSansMT-Bold |
| b08 | TrebuchetMS, TrebuchetMS-Bold, Consolas |
| b09 | TimesNewRomanPSMT, TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT |
| b10 | ArialMT, Arial-BoldMT |
| b11 | Georgia, Georgia-Bold, Georgia-Italic |
| b12 | MicrosoftYaHei, MicrosoftYaHei-Bold |
| b13 | ArialMT, Arial-BoldMT, Arial-ItalicMT |
| b14 | CenturyGothic, CenturyGothic-Bold |
| b15 | Cambria, Cambria-Bold, Cambria-Italic |
| b16 | NirmalaUI, NirmalaUI-Bold |
| b17 | Candara, Candara-Bold, CourierNewPSMT |
| b18 | BookAntiqua, BookAntiqua-Bold, BookAntiqua-Italic |
| b19 | MalgunGothic, MalgunGothicBold |
| b20 | Garamond, Garamond-Bold, Garamond-Italic, Rockwell-Bold |
| b21 | Tahoma, Tahoma-Bold |
| b22 | FranklinGothic-Book, ArialNarrow, Consolas |
| b23 | LeelawadeeUI, LeelawadeeUI-Bold |
| b24 | CenturySchoolbook, -Bold, -Italic, TwCenMT-Regular, TwCenMT-Bold |

## The documents

| id | lang | pages | kind | main difficulties |
|----|------|-------|------|-------------------|
| b01 | en | 1 | Printer's tax invoice | letterhead furniture; bill-to box beside a key/value table (box by box); fully ruled line items with a two-line cell; subtotal/VAT/total rows merging four columns; typed a) b) c) list; letter-spaced title |
| b02 | fr | 2 | Bus line timetable | two WIDE timetables (11 and 7 columns) with header-only rules and '—' cells; price table; typed (1)(2)(3) notes; CSS disc list; footer text and page number on one baseline; French no-break spaces |
| b03 | de | 2 | Sports club half-year budget report | two-level header (rowspan + colspans), section rows, totals and result rows, U+2212 minus; captions above tables; nested CSS list |
| b04 | ar | 2 | School fee schedule (RTL) | right-to-left tables with rowspan-merged stage column; Arabic-Indic digits; typed ١. list and CSS arabic-indic list; RTL page furniture |
| b05 | ja | 1 | Health check-up results | four-column key/value table; results table with section rows; Japanese without spaces; typed ※ notes; letter-spaced title |
| b06 | en | 2 | Drinking-water test report | letterhead on page 1, running header on page 2; side-by-side boxes; zebra tables with two-line method cells; table continued on page 2 WITHOUT repeated header; µ, °, < |
| b07 | es | 2 | Technical conference programme | programme grids with colspan (plenaries) and rowspan (workshops); side-by-side info boxes; typed en-dash list |
| b08 | en | 2 | Software release notes and upgrade guide | YAML and shell code blocks; header-rule-only configuration table with wrapped descriptions; typed and CSS ordered lists with a nested level |
| b09 | ru | 2 | Asset inventory record | fully ruled 8-column table with two-level header, continued on page 2 WITH both header rows repeated; totals row with merged label and empty cell; no-break-space thousands |
| b10 | he | 1 | Building duty roster (RTL) | RTL roster with month cells merged over four rows; CSS disc list in RTL; contacts table |
| b11 | en | 1 | Tender comparison memo | memo key/value block; comparison table with two-line cells and totals; side-by-side Risks/Recommendation boxes; typed roman list |
| b12 | zh | 2 | Tea wholesale price list | zebra table with section rows continued on page 2 without header; Chinese without spaces; typed and CSS (circle) lists |
| b13 | en | 2 | Bank current-account statement | address beside account-summary box; transactions table with two-line descriptions continued on page 2 with repeated header and a 'continued' line; rates table |
| b14 | pt | 2 | Athletics championship results | eight tables, six of them event tables standing two by two side by side; DNF/DQ rows; team classification; legend key/value table |
| b15 | el | 1 | Hotel room price list | two-level header by season, section rows; key/value periods table; typed Greek-letter list; letter-spaced uppercase letterhead |
| b16 | hi | 1 | Municipal water-supply schedule | Devanagari; fully ruled schedule; typed Devanagari-digit list; danda-terminated sentences |
| b17 | en | 2 | Examination timetable (A4 landscape) | wide grid with two-level header and two-line cells; side-by-side course list and rules; iCalendar code block in Courier New |
| b18 | pl | 2 | Housing co-operative meeting minutes | typed agenda with nested a) b); voting table with wrapped cells; fully ruled task table; signature lines side by side |
| b19 | ko | 1 | Staff induction training schedule | date column merged over sessions; side-by-side boxes (list and key/value table); typed 가. 나. 다. list |
| b20 | en | 2 | Community newsletter | two CSS columns on both pages (column by column reading order); boxed list inside a column; borderless events table in a column; justified text |
| b21 | vi | 1 | Electricity bill | Vietnamese diacritics; customer key/value table; tier table with totals, VAT and grand-total rows merging four columns; typed hyphen list |
| b22 | en | 2 | Pump technical datasheet | two specification tables side by side with captions; performance table with two-line header cells; ordering-code table with rowspans; INI code block; Modbus register table |
| b23 | th | 1 | Dental clinic price list | Thai without spaces between words and without full stops; section rows; empty note cells; typed and CSS lists |
| b24 | it | 3 | Municipal pool regulations and tariffs | three-level headings; two-level header tariff table with section rows; opening-hours table with colspan and rowspans; typed a)..d) and CSS lists |

Languages: English plus sixteen others -- French, German, Arabic, Japanese, Spanish,
Russian, Hebrew, Chinese, Portuguese, Greek, Hindi, Polish, Korean, Vietnamese, Thai,
Italian. Fifteen documents have two or three pages.
