# Golden set v17 -- 24 realistic PDF documents with known structure

An independent golden test set for scoring document readers (Docling and Softanza's native
PDF reader). Each document `zNN` comes as three files:

- `zNN.html` -- the source page;
- `zNN.pdf` -- the same page printed to PDF by headless Chrome;
- `zNN.expected.json` -- what a reader should recover: title, headings with levels, 4 to 10
  key body sentences in reading order, tables (as grids), list items, page furniture,
  languages, code blocks, and notes naming any convention a scorer must know.

All organisations, people, places of business, addresses, phone numbers and figures are
invented. Domains use `.example`.

## How it was made

- One Python builder emits the HTML **and** the expected JSON from the same call, so every
  heading, sentence, list item, table cell and furniture line in the JSON is the exact text
  placed in the page (after the normalisation rules below). A separate check confirmed that
  every expected string occurs in the HTML text.
- Every page is an explicit A4 block (`@page { margin: 0 }`, page furniture placed in the
  body), so page breaks, running headers/footers and page numbers are known exactly. Before
  printing, each page was laid out in headless Chrome (DOM dump only) and checked for
  overflow; every page body fits with spare room, so no text is clipped.
- PDFs were printed with
  `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch profile> --print-to-pdf=...`
  (Chrome 155). Page counts were read from the raw PDF bytes (`/Type /Page` objects and the
  `/Pages /Count`); both agree with the intended count for all 24 files.
- Fonts: only static fonts installed in `C:\Windows\Fonts` were used (no variable fonts).
  Before rendering, every character of each document was checked against the cmap of every
  font family the document names (Regular and Bold files), and code text against its
  monospaced font. After rendering, the `/BaseFont` names in the raw PDF bytes were read: in
  every document the embedded fonts are exactly the families intended, with no fallback font.

**Independence.** The author of this set never ran, imported or opened any PDF-to-text or
document-conversion tool or PDF rasteriser, never looked at any reader's code or output, and
never saw golden sets v1 to v16. The PDFs were checked only through their raw bytes (page
objects and font names), never through an extractor.

## Conventions used in every `expected.json`

- Whitespace runs collapse to one space (no-break, narrow no-break and ideographic spaces
  count as spaces), except inside `code`. Text is NFC.
- A table cell or heading set on two lines is given with its lines joined by one space.
- Tables: header row(s) first; merged cells repeat their text in every grid cell they cover
  (two-level headers, section rows, total-row labels, row-spanning day cells); totals and
  section rows are rows of the same table; a table continued across pages is ONE table with
  its header once; right-to-left tables list cells in logical order (rightmost column first).
  Key/value tables without a header row start with their first data row.
- Lists: a marker typed in the text (`1.`, `a)`, `–`, `•`, `（1）`, `(क)`, `1°` ...) is part of the
  item text; a marker drawn by CSS (disc, circle, square, decimal, Devanagari numerals, a
  CSS string marker) is not. Each document's notes say which is which.
- Furniture: one entry per separate visible text block of letterheads, running headers and
  footers; parts of the same header/footer row that sit apart are separate entries; a
  repeated running header/footer is listed once; page-number lines are listed once per page.
  A letterhead organisation name is never a heading.
- Letter-spaced text is given as its plain words. No document uses CSS `text-transform`:
  every capitalised title or heading is typed in capitals and expected in capitals.
- Side-by-side boxes or columns are read box by box (left first in left-to-right documents);
  the notes name every such place.
- Sentences carrying a footnote marker are left out of `key_sentences`.

## Fonts embedded (from the PDF `/BaseFont` names)

| id | embedded fonts |
|---|---|
| z01 | CenturyGothic, Corbel, Corbel-Bold |
| z02 | ArialMT, Arial-BoldMT, Arial-BoldItalicMT |
| z03 | Garamond, Garamond-Bold, Garamond-Italic |
| z04 | Georgia, Georgia-Bold, Georgia-Italic, Verdana, Verdana-Bold |
| z05 | TimesNewRomanPSMT, TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT |
| z06 | Tahoma, Tahoma-Bold, SakkalMajalla-Bold |
| z07 | ArialMT, Arial-BoldMT, SegoeUI-Bold |
| z08 | Calibri, Calibri-Bold, Cambria-Bold |
| z09 | Calibri, Calibri-Italic, PalatinoLinotype-Roman, PalatinoLinotype-Bold, PalatinoLinotype-Italic |
| z10 | Ebrima, Ebrima-Bold |
| z11 | NirmalaUI, NirmalaUI-Bold |
| z12 | LeelawadeeUI, LeelawadeeUI-Bold |
| z13 | SegoeUI, SegoeUI-Semibold, Consolas |
| z14 | GillSansMT, GillSansMT-Bold, GillSansMT-Italic, LucidaBright, LucidaBright-Demi |
| z15 | Cambria, Cambria-Bold, Cambria-Italic |
| z16 | TrebuchetMS, TrebuchetMS-Bold |
| z17 | ArialMT, Arial-BoldMT, ArialNarrow, ArialNarrow-Bold, CourierNewPSMT |
| z18 | MicrosoftSansSerif (bold is synthesised: the family has no bold file), Constantia-Bold |
| z19 | TwCenMT-Regular, TwCenMT-Bold, Rockwell, Rockwell-Bold |
| z20 | BookAntiqua, BookAntiqua-Bold, BookAntiqua-Italic, Candara, Candara-Bold |
| z21 | Roboto-Regular, Roboto-Bold, Roboto-Italic, Roboto-BoldItalic, Cambria-Bold |
| z22 | Gadugi, Gadugi-Bold |
| z23 | YuGothic-Regular, YuGothic-Bold |
| z24 | CenturySchoolbook, CenturySchoolbook-Bold, CenturySchoolbook-Italic, RobotoCondensed-Regular, RobotoCondensed-Bold |

## The 24 documents

| id | kind | language | pages | main difficulties |
|---|---|---|---|---|
| z01 | Commercial tax invoice (timber merchant) | English | 1 | letterhead; two address boxes side by side plus a key/value block; line-item table with merged Subtotal/VAT/Total rows; CSS bullets |
| z02 | Hospital discharge letter | German | 2 | letterhead then running header; key/value patient table; lab table; medication table with two-line cells; typed numbered list; three heading levels |
| z03 | Residential lease contract | French | 3 | justified Garamond; letter-spaced capital title; roman-numbered parts and articles; typed `–`, `a)`, `1°` lists and CSS lists; French no-break spaces; side-by-side signature boxes; running header and initials footer |
| z04 | University course guide (hydrology) | Spanish | 2 | table across the page break with repeated header; two-level evaluation header; nested CSS lists (disc/circle) and square bullets; key/value table with a two-line cell |
| z05 | Municipal council minutes | English | 2 | letter-spaced letterhead; three attendance columns side by side (plain lines, not lists); numbered agenda headings; captioned rents and vote tables; typed `(a)` list; page numbers `– 1 –` |
| z06 | Water utility bill | Arabic (RTL) | 1 | right-to-left; Arabic-Indic digits, Arabic decimal and percent signs; key/value table; tiered consumption table with fee and total rows; caption under table; RTL CSS bullets |
| z07 | Library loan rules and annual report | Hebrew (RTL) | 2 | right-to-left; loan-period table; quarterly statistics with totals; typed numbered list and CSS square list in RTL; gershayim |
| z08 | Freight consignment note | Russian | 1 (landscape) | landscape page; three party boxes side by side; nine-column goods table with two-line cells, no-break-space thousands and merged Итого; two-column lower area; CSS string marker list |
| z09 | Hotel guest information and price list | Greek | 2 | letter-spaced letterhead; two shaded boxes side by side; two-level price header with caption under the table; typed Greek-letter list; CSS ordered list; key/value tables |
| z10 | Seed and fertiliser distribution notice (cooperative) | Amharic (Ethiopic) | 1 | Ethiopic script and punctuation; Ethiopian calendar dates; schedule and price tables; typed numbered list |
| z11 | Voter guide (election office) | Hindi (Devanagari) | 2 | Devanagari page numbers; CSS list numbered in Devanagari digits; typed `(क)` list; nukta letters; key/value and document tables; two-line timetable cell |
| z12 | Mobile plan summary (telecom) | Thai | 1 | no word spaces, no full stops; zebra plan table with a two-line cell and a caption under it; typed `1)` list; CSS circle list; Buddhist-era year |
| z13 | Database TLS rotation runbook | English | 3 | four Consolas code/config blocks (shell, INI, YAML, one-liner); three heading levels; key/value tables; CSS ordered steps; symptoms table with two-line cells; running header and footer |
| z14 | Pension fund quarterly report | English | 2 | key-figures box beside summary column; two-level performance header with zebra rows; borderless allocation table with section rows; parentheses for negatives; glossary table |
| z15 | Scientific article (limnology) | English | 2 | two balanced CSS columns per page; full-width abstract; superscript affiliations; footnote; tables inside a column with captions above; typed `[1]` references; journal page numbers 117-118 |
| z16 | Insurance claim settlement letter | Portuguese | 1 | letterhead and address block; one-row reference table; settlement table with subtotal, total, negative deductible (U+2212) and final rows; CSS bullets with coloured markers |
| z17 | Airline crew briefing sheet | English | 1 | two key/value boxes side by side; sectors table in Arial Narrow; NOTAM block in Courier New; typed `•` bullets; letter-spaced capital headings |
| z18 | Customs duty statement (customs broker) | Turkish | 2 | items table across the page break with repeated header and a merged Toplam row; Turkish number format; dotted and dotless i; typed `a)` list; key/value tables |
| z19 | Football league bulletin | Italian | 1 | letter-spaced capital title; two columns side by side with tables and paragraphs; standings table with a three-group two-level header; typed `–` list |
| z20 | Parish weekly bulletin | Polish | 2 | Mass schedule with row-spanning day cells; two framed boxes side by side (table and CSS ordered list); daggers; CSS square list |
| z21 | Electricity tariff notice | Vietnamese | 1 | two-block letterhead; two-line title; tariff table with section rows and caption under it; stacked Vietnamese diacritics; typed `-` lists; side-by-side recipients and signature blocks |
| z22 | Rent increase letter (housing association) | Dutch | 1 | addressee block beside a reference table; rent table with a total row; CSS bullets |
| z23 | Fishing permit conditions | Japanese | 2 | no word spaces; ideographic spaces in headings and caption; full-width punctuation; typed `（1）` list; CSS list; ruled tables; page numbers `1／2` |
| z24 | Court daily cause list | English | 2 | letter-spaced letterhead; wide six-column table across pages WITHOUT a repeated header; courtroom section rows; two-line party cells; typed numbered notes |

Fourteen documents have two or three pages (z02, z03, z04, z05, z07, z09, z11, z13, z14,
z15, z18, z20, z23, z24). Seventeen languages besides English appear, in Latin, Greek,
Cyrillic, Arabic, Hebrew, Ethiopic, Devanagari, Thai and Japanese scripts.
