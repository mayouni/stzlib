# golden_v12 -- independent golden set for document readers

24 realistic PDF documents (`s01` .. `s24`) with a hand-authored expected structure, made to score document readers
(Docling and Softanza's native PDF reader). Each document is a whole document of a kind real organisations produce;
every organisation, person and product in it is fictional (place names are sometimes real).

Each document has three files:

- `sNN.html` -- the source, written by the author of this set;
- `sNN.pdf` -- the HTML printed to PDF by headless Chrome 155 (`--headless=new --no-pdf-header-footer`, a separate scratch profile), A4 (s11 A4 landscape);
- `sNN.expected.json` -- the expected structure: `id, difficulty, pages, title, headings, key_sentences, tables, list_items, furniture, languages, code, notes`.

## How it was made

A small Python generator (kept outside the repository) builds every document from one description, so that the HTML and the
expected JSON come from the same text: each heading, key sentence, table cell, list item, furniture line and code block is
emitted into the HTML and recorded in the JSON in the same call, and every key sentence is asserted to occur verbatim in
the visible text of its paragraph. Visible text is the markup with tags removed, entities decoded, `<br>` and non-breaking
spaces turned into spaces and whitespace runs collapsed. Page counts were read from the raw PDF bytes (`/Type /Page` objects
and the `/Count` of the page tree, which agree for all 24), and were written into the JSON after rendering. Embedded fonts were
read from the raw PDF bytes (`/BaseFont` names, subset prefix removed). Layout heights were checked by laying the author's own
HTML out in the same browser on screen (never by reading a PDF).

**Independence.** The author of this set never ran, imported or opened any PDF-to-text or document-conversion tool, any PDF
rasterizer, any reader's code or any reader's output, and never looked at golden_v1 .. golden_v11. The only operations on the
PDFs were byte-level regular-expression reads of `/Type /Page`, `/Count` and `/BaseFont`.

Every font family named in the CSS was checked against the family names in the name tables of the files in
`C:\Windows\Fonts` before rendering; all were installed. After rendering, every intended family was found embedded; no
document fell back to an unintended font. Code blocks are set in Consolas (s06) or Courier New (s13, s19).

## Conventions a scorer must know

- Headings are in document order, the title first at level 1. A letterhead's organisation name, table header cells, form
  and box labels, subtitles under a title and unit captions are not headings.
- `key_sentences` are full body sentences exactly as visible, in reading order; a sentence carrying a footnote marker is
  never one. Sentences in list items are not used as key sentences.
- Tables: header row(s) first; a two-level header gives both header rows; merged cells repeat their text in every grid cell
  they cover (section rows therefore repeat across the row); empty cells are empty strings; a cell printed on two lines
  (a `<br>` or a smaller second line) is joined with one space; a table continued across a page is one table with its header
  once (Chrome repeats the header row on the next page). Right-to-left tables list cells in reading order, rightmost first.
- Lists: `text` includes the marker when it is typed in the text (`a)`, `(i)`, `[1]`, `1)`, `–`, `أولاً:`), and omits it when
  CSS draws it (disc, circle, square, decimal, lower-alpha, arabic-indic, persian, hebrew). `level` 0 is the outer list.
- Furniture: letterhead, running header and footer lines, one visible line per entry; a running line is listed once; page
  numbers are listed once per page (`Page 1/2`, `Page 2/2`). Running headers and footers are CSS page-margin boxes.
- Right-to-left text is in logical order. Letter-spaced text is given as its plain words. Typographic characters are kept as
  printed (U+2212 minus, U+2019 apostrophe, en and em dashes, guillemets, U+200C zero-width non-joiner in Persian).
- Reading order of side-by-side boxes and of CSS multi-column flow is box by box / column by column; each document's `notes`
  says where this applies.

## Documents

| id | kind | language | pages | difficulty | main difficulties |
|---|---|---|---|---|---|
| s01 | Commercial invoice (office supplies wholesaler) | English | 1 | medium | letterhead furniture; key/value meta table beside the letterhead; two address boxes side by side; line-item table with a two-line cell and totals rows with empty cells; letter-spaced title |
| s02 | Hospital discharge summary (cardiology) | French | 2 | hard | running header in two margin boxes from page 2, page-number footer; two-block letterhead; three heading levels; lab results table; prescription table with two-line cells; nested bullet lists; side-by-side signature line |
| s03 | Residential lease contract | Spanish | 3 | hard | three pages of justified serif text with first-line indents; centred dash page numbers and right running reference; letter-spaced section headings; clause headings at level 3; typed a)-e) list; economic-conditions table; inventory table that may break across a page; side-by-side signature boxes |
| s04 | University module description and semester plan | German | 2 | medium | numbered headings at two levels; key/value table; CSS-numbered list; zebra semester table with two-line cells; assessment table with two-level header (rowspan + colspan); typed [n] bibliography list; two-part footer |
| s05 | Municipal council meeting minutes | Arabic | 2 | hard | right-to-left Arabic throughout; letterhead with reference number; running header and Arabic page footer; key/value table; CSS arabic-indic numbered agenda; two RTL tables (budget with totals row, works programme); typed-marker decisions list; side-by-side signatures |
| s06 | Software installation and configuration guide | English | 2 | medium | three monospaced code/config blocks (shell, YAML, systemd INI with blank lines); requirements table; parameter table with wrapping cells; CSS-numbered steps with nested bullets; running header and two-part footer; callout box |
| s07 | Bank current-account statement | Portuguese (Brazil) | 2 | hard | long transaction table crossing a page with repeated header; running header and two-part footer; summary key/value table; account-holder box beside the period box; Brazilian number format; empty debit/credit cells |
| s08 | Garden centre seasonal price list | Italian | 1 | medium | two-column newspaper flow (CSS columns); small borderless price tables under level-2 headings; letterhead band and footer; intro paragraph spanning both columns |
| s09 | NGO annual report (water and sanitation) | Swahili | 2 | hard | two side-by-side boxes each with its own heading (box-by-box reading order); project table with region section rows and a totals row; finance table with section rows and subtotals; CSS-numbered list; two-part footer |
| s10 | Agricultural cooperative seed distribution report | Hausa | 1 | medium | Hausa hooked letters (ɓ ɗ ƙ) in Ebrima; letterhead; table with village section rows, per-village subtotal rows and a grand total; CSS bullet list and typed 1) list; footer with date and page |
| s11 | Regional bus timetable (landscape) | Dutch | 1 | hard | landscape A4; wide 13-column table with a two-level header (colspan groups, rowspan stop column); dashes for stops not served; footnote letters in header cells; condensed font; typed legend list; header band and footer |
| s12 | Hotel booking confirmation | Turkish | 1 | easy | Turkish dotted/dotless i and other diacritics; letterhead; two key/value tables side by side; small nightly-rate table with totals; CSS bullet list and typed dash list; footer |
| s13 | Scientific research article (agronomy field trial) | English | 2 | hard | two-column body after a full-width title and abstract; automatic hyphenation enabled; numbered headings at two levels; tables with captions inside a column, one with a two-level header; footnote marker and footnote; R code block in Courier New inside a column; typed [n] references; running header and bare page numbers |
| s14 | Museum exhibition programme | Persian | 1 | hard | right-to-left Persian with zero-width non-joiners and Persian digits; letterhead; weekly programme table and ticket table in RTL; CSS bullet list and CSS Persian-numbered list; guillemets in the title; footer |
| s15 | Parish weekly bulletin | Polish | 1 | medium | masthead with issue line; two boxes side by side (mass times table, office hours table) read box by box; CSS-numbered announcements; intentions table with two-line cells; Polish diacritics; footer |
| s16 | Sports club member handbook and fixture list | Indonesian | 2 | medium | fee table with two-line schedule cells; zebra fixture table that may break across the page; CSS-numbered rules with nested lower-alpha list; CSS bullets; level-3 heading; letterhead and two-part footer |
| s17 | Home insurance policy schedule | English | 2 | hard | letterhead; running header from page 2 and two-part footer; key/value policy table; cover table with a two-level header and merged 'Not covered' cells; premium table; level-3 endorsement headings; typed (a)/(i) nested exclusion list |
| s18 | Electricity utility bill | Vietnamese | 1 | medium | Vietnamese stacked diacritics; letterhead; two boxes side by side, each with a key/value table (box-by-box order); meter-reading table; tiered tariff table with subtotal, VAT and total rows; amount in words; footer |
| s19 | Export packing list (logistics) | Romanian | 1 | medium | Romanian comma-below diacritics; letterhead; two party boxes side by side; shipment key/value table; wide 8-column packing table with header cells of two lines and a totals row; shipping marks block in Courier New; signature boxes |
| s20 | Energy company quarterly operations report | Hebrew | 2 | hard | right-to-left Hebrew with embedded Latin units and numbers; running header and Hebrew page footer; production table with totals row and maintenance table with two-line cells (RTL); CSS bullet list and CSS Hebrew-letter numbered list; key/value table |
| s21 | Primary school half-year pupil report | Czech | 1 | easy | Czech diacritics (háček, kroužek); centred school letterhead; pupil key/value table; grades table with grade digit and word; small attendance table; typed legend list with en dashes; side-by-side signature lines |
| s22 | Regional administrative circular (livestock vaccination campaign) | French | 2 | hard | two-block administrative letterhead with reference number and date; address block; articles as level-2 headings; typed dash lists; campaign calendar table with two-line cells and totals; small price table; 'Ampliations' distribution list; page number footer 'n/N' |
| s23 | Medical laboratory test results | Greek | 1 | medium | Greek script with tonos; letterhead; two key/value tables side by side; results table with section rows spanning all columns, flag column with arrows and empty cells; comment paragraph; signature and footer |
| s24 | Interim financial statements (food manufacturer) | English | 3 | hard | three pages, one statement per page; balance sheet with section rows, subtotals, bracketed negatives and a two-level column header with an empty corner; income statement; segment table; footnote markers; running header and bare page numbers |

## Fonts embedded per document

Families named in the CSS (fallbacks in parentheses were named but not needed) and the `/BaseFont` names found in the PDF.

| id | families named | embedded (`/BaseFont`, subset prefix removed) |
|---|---|---|
| s01 | Calibri | Calibri, Calibri-Bold |
| s02 | Calibri, Cambria | Calibri, Calibri-Bold, Calibri-Italic, Cambria-Bold, Cambria-BoldItalic |
| s03 | Times New Roman | TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT, TimesNewRomanPSMT |
| s04 | Georgia, Verdana | Georgia, Georgia-Bold, Georgia-BoldItalic, Verdana, Verdana-Bold |
| s05 | Sakkal Majalla, Traditional Arabic | SakkalMajalla, SakkalMajalla-Bold, TraditionalArabic-Bold |
| s06 | Consolas, (Courier New), Segoe UI | Consolas, SegoeUI, SegoeUI-Bold, SegoeUI-Semibold |
| s07 | Arial | Arial-BoldMT, ArialMT |
| s08 | Georgia, Trebuchet MS | Georgia-Italic, TrebuchetMS, TrebuchetMS-Bold, TrebuchetMS-Italic |
| s09 | Candara | Candara, Candara-Bold, Candara-BoldItalic, Candara-Italic |
| s10 | Ebrima | Ebrima, Ebrima-Bold |
| s11 | (Arial), Arial Narrow, Century Gothic | ArialNarrow, ArialNarrow-Bold, CenturyGothic |
| s12 | Palatino Linotype, Tahoma | PalatinoLinotype-Roman, Tahoma, Tahoma-Bold |
| s13 | (Book Antiqua), Courier New, Palatino Linotype | CourierNewPSMT, PalatinoLinotype-Bold, PalatinoLinotype-Italic, PalatinoLinotype-Roman |
| s14 | Segoe UI, Tahoma | SegoeUI-Bold, Tahoma, Tahoma-Bold |
| s15 | Book Antiqua, Georgia, (Palatino Linotype) | BookAntiqua, BookAntiqua-Bold, BookAntiqua-Italic, Georgia |
| s16 | Gill Sans MT | GillSansMT, GillSansMT-Bold, GillSansMT-BoldItalic |
| s17 | Corbel | Corbel, Corbel-Bold, Corbel-Italic |
| s18 | Arial | Arial-BoldMT, Arial-ItalicMT, ArialMT |
| s19 | Courier New, Microsoft Sans Serif | CourierNewPSMT, MicrosoftSansSerif |
| s20 | Arial | Arial-BoldMT, ArialMT |
| s21 | Constantia | Constantia, Constantia-Bold, Constantia-Italic |
| s22 | Garamond, (Times New Roman) | Garamond, Garamond-Bold |
| s23 | Segoe UI | SegoeUI, SegoeUI-Bold, SegoeUI-Semibold |
| s24 | Calibri, Cambria | Calibri, Calibri-Bold, Calibri-Italic, Cambria, Cambria-Bold, Cambria-Italic |

Notes on fonts: Microsoft Sans Serif (s19) has no bold face, so its bold text is synthesised by the browser from the regular
face. Margin-box running headers and footers use the families named in their `@page` rules.

## Counts

39 pages in all; 13 documents of 2 or 3 pages; 65 tables; 126 list items; 5 code blocks; 19 languages (English and 18 others); 3 right-to-left documents (Arabic s05, Persian s14, Hebrew s20), each with tables and lists.
