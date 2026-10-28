# Golden set v21 -- 24 realistic PDF documents with known structure

## What this set is

An independent golden test set for scoring document readers (Docling and Softanza's
native PDF reader). It holds 24 whole documents of the kinds real organisations
produce -- invoices, minutes, manuals, contracts, notices, reports, a newsletter --
each with three files:

- `dNN.html` -- the source, authored for this set;
- `dNN.pdf` -- the source printed by headless Chrome;
- `dNN.expected.json` -- the structure a perfect reader would return: title,
  headings with levels, key sentences in reading order, tables as grids, list items
  with levels, page furniture, languages, code blocks and notes for the scorer.

Every organisation, person, address, phone number, e-mail address and amount is
invented. E-mail domains use `.example`.

## How it was made

- Each document was written as HTML with fixed A4 page boxes (210 x 296 mm, `@page
  { size: A4; margin: 0 }`), so that page breaks, running headers, footers and page
  numbers are placed by the author and not left to the browser. A table that crosses
  a page is written twice with its header repeated, as a real print does.
- Each HTML was printed with headless Chrome, with no browser header or footer:
  `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch profile> --print-to-pdf=<dNN.pdf> file:///<dNN.html>`
- Only fonts installed on the authoring Windows machine were used, and no variable
  font. Before rendering, every character of every expected text was checked against
  the character map of the font files it is set in.
- After rendering, each PDF was checked from its raw bytes only: the page count from
  `/Type /Page` and `/Count`, and the embedded fonts from the `/BaseFont` names.
- `expected.json` follows one schema with exactly twelve keys (`id`, `difficulty`,
  `pages`, `title`, `headings`, `key_sentences`, `tables`, `list_items`, `furniture`,
  `languages`, `code`, `notes`), UTF-8, NFC. For d19-d24 the HTML and the expected
  texts were generated from the same strings, and every expected string was checked
  to occur in the HTML.

## Independence

The authors of this set never ran a PDF-to-text extractor, a document converter or
a PDF rasterizer on any of these files, never read any reader's code or output, and
never saw golden sets v1 to v20. PDFs were read only as raw bytes, for page counts
and `/BaseFont` names. The second author checked the layout of d19-d24 by looking at
screenshots of the HTML pages in headless Chrome, never of the PDFs.

## Two authors

The set was written by two authors in sequence:

- **author 1** wrote d01-d18 and stopped there because of an API error;
- **author 2** wrote d19-d24 and this README. Author 2 read d01-d18 (HTML and
  expected.json, and the PDFs as raw bytes only) to keep the conventions, to avoid
  repeating their kinds and languages, and to describe them here. Author 2 changed
  nothing in d01-d18.

## Totals against the brief

| requirement | in this set |
|---|---|
| at least six languages besides English | **19**: fr d02, de d03, ar d04, ja d05 d17, es d06, ru d08, he d09, zh d10, el d12, hi d13, ko d14, pt d16, tr d18, fa d19, vi d20, th d21, pl d22, nl d23, sv d24 (English: d01 d07 d11 d15) |
| at least ten documents of 2 or 3 pages | **17**: 2 pages d02 d03 d04 d07 d08 d10 d13 d15 d16 d17 d18 d19 d22 d23 d24; 3 pages d06 d20 |
| right-to-left documents with lists and tables | **3**: d04 Arabic, d09 Hebrew, d19 Persian -- each has lists (CSS and typed markers) and at least one table |
| two boxes or columns side by side, read box by box | **10**: d01 d02 d05 d06 d11 d18 d19 d21 d22 d23; flowing multi-column text in d07 (2 columns), d24 (3 then 2 columns), d20 (a 2-column list) |
| code or configuration blocks | **3** documents, 8 blocks: d03 (2, Consolas), d15 (3, Consolas), d23 (3, Courier New) |

## Conventions a scorer must know

- Headings: the title is the first heading, level 1. A letterhead's organisation
  name, table header cells, form labels and box labels are not headings.
- Key sentences are body text exactly as visible, in reading order. A sentence with
  a footnote marker is left out.
- Tables: header row first; a cell merged over several grid cells repeats its text
  in each of them; a two-level header gives two header rows; totals and section rows
  are rows of the same table; a table continued across pages is ONE table with its
  header once; right-to-left tables list cells rightmost column first.
- List items keep a marker when it is typed in the text and drop it when CSS draws
  it; each document's notes say which is which. Level 0 is the outermost.
- Furniture: header, footer and letterhead lines, one visible line per entry; a
  repeated running line is listed once; page-number lines once per page.
- Text: ligatures as letters; a word hyphenated across lines given whole; whitespace
  runs collapse to one space except in code; no-break spaces count as spaces;
  scripts written without spaces between words (zh, ja, th) join wrapped lines with
  no space; right-to-left text in logical order; letter-spaced text as plain words;
  NFC; a multi-line table cell or list item joined with one space.
- Persian (d19) keeps ZERO WIDTH NON-JOINER (U+200C) as written; a scorer should
  ignore U+200C when comparing.

## The 24 documents

| id | lang | pages | difficulty | kind | main difficulties |
|---|---|---|---|---|---|
| d01 | en | 1 | easy | supplier tax invoice | letterhead as furniture; two boxes side by side (bill-to, details key/value table); line items with totals spanning three columns; CSS square bullets |
| d02 | fr | 2 | medium | board meeting minutes of an association | two-part running header, "Page N sur 2"; CSS decimal agenda; typed en-dash list with CSS circle sub-list; typed "a)" with hanging indent; key/value table without header; side-by-side signature boxes |
| d03 | de | 2 | medium | IT operations manual (print server) | two code blocks; CSS disc bullets with CSS-string dash sub-level; CSS decimal steps; zebra port table; hint box as body |
| d04 | ar | 2 | hard | municipal circular | right-to-left; Arabic-Indic digits; running letterhead; CSS arabic-indic numbering; typed Arabic letter markers with hanging indent; table continued on page 2 with repeated header |
| d05 | ja | 1 | medium | quotation (御見積書) | letter-spaced title; recipient and issuer boxes side by side; totals spanning four columns; typed full-width "１．" markers; no word spaces |
| d06 | es | 3 | hard | commercial lease contract | 3 pages; letter-spaced section headings; typed roman numerals with hanging indent; typed "a)" inline; table ruled top and bottom only; side-by-side signatures |
| d07 | en | 2 | hard | journal article | two-column body read column by column; run-in "Abstract" heading; footnote; table inside one column; typed "[1]" references; bare page numbers |
| d08 | ru | 2 | hard | technical assignment (техническое задание) | approval block as body; typed numbered headings; typed Cyrillic letter markers; two-level table header; top-aligned multi-line cells |
| d09 | he | 1 | medium | school letter to parents | right-to-left; CSS Hebrew-letter markers; typed bullets inline; borderless schedule table; tear-off slip with form labels |
| d10 | zh | 2 | hard | company notice in official-document style | red issuer header; "— 1 —" page numbers; typed "一、" and "（一）" heading numbers; two-level table header; no word spaces |
| d11 | en | 1 | medium | conference programme | letter-spaced event line as furniture; programme grid with plenary rows spanning both halls; three keynote boxes side by side; CSS bullets |
| d12 | el | 1 | medium | press release | CSS lower-greek markers; typed em-dash list; small table; press-contact box |
| d13 | hi | 2 | hard | AGM notice of a housing cooperative | Devanagari; running letterhead; CSS devanagari numbering; typed "(क)" markers with hanging indent; danda sentence ends; total row |
| d14 | ko | 1 | medium | job posting | vertically centred multi-line cells; borderless key/value table; typed circled digits with hanging indent and typed "-" sub-items; "※" note |
| d15 | en | 2 | medium | API release notes | three code blocks (JSON, shell, YAML); CSS bullets nested three levels; CSS decimal steps; warning box |
| d16 | pt | 2 | hard | construction budget, landscape A4 | one wide 8-column table across both pages; section rows spanning 8 columns and subtotal labels spanning 7; typed "1)" markers |
| d17 | ja | 2 | hard | internal regulation (文書管理規程) | chapter and article headings at levels 2 and 3; typed "（１）" and "①" markers; CSS katakana-iroha sub-items; cell spanning two rows |
| d18 | tr | 2 | medium | annual report summary of a foundation | three KPI boxes side by side; zebra table with total; small table floating beside text; CSS decimal list with CSS lower-alpha sub-level |
| d19 | fa | 2 | hard | university course syllabus | right-to-left with Persian digits and ZWNJ; two boxes side by side read right box first; zebra weekly table; total row with an empty cell; CSS "persian" numbering with typed "الف)" sub-items on a hanging indent; typed "۱-" references restarting under level 3 headings |
| d20 | vi | 3 | medium | user manual for a rice cooker | 3 pages; Vietnamese stacked diacritics; brand letterhead letter-spaced; CSS disc bullets with typed "+" sub-items; typed "(1)" parts list laid out in two columns; typed "Bước 1:" steps on a hanging indent; two-level table header; troubleshooting table with a cell spanning two rows; old-style figures in Candara |
| d21 | th | 1 | hard | hotel booking confirmation | Thai without word spaces; Buddhist-era dates; dark letterhead band; guest and stay boxes side by side; charge summary labels spanning three columns; typed Thai-digit "๑." markers next to a CSS "thai" list that looks the same; two sections side by side |
| d22 | pl | 2 | hard | water laboratory test report | letterhead on page 1, running header on page 2; key/value table with two pairs per row; results table with two-level header, section rows spanning 7 columns, horizontal rules only, continued across pages; subscript in a unit; typed "1." remarks with typed en-dash sub-items; borderless abbreviation table; side-by-side signatures |
| d23 | nl | 2 | medium | work instruction (back-up procedure) | three code blocks in Courier New with exact indentation and aligned columns; revision table; borderless responsibilities table with centred codes; CSS decimal steps with typed "a." sub-items; typed en-dash list on a hanging indent; "Let op" and "Tip" boxes side by side; narrow word spaces of Gill Sans MT |
| d24 | sv | 2 | hard | housing-cooperative newsletter | masthead title; page 1 in three columns with sentences flowing across columns; page 2 with a full-width calendar table then two columns; zebra fee table with a real caption and no-break thousands separators; typed "»" and "•" markers next to CSS decimal and CSS-string dash lists |

## Fonts embedded in each PDF

Read from the `/BaseFont` names in the raw PDF bytes; the six-letter subset prefix is
left out.

| id | embedded fonts |
|---|---|
| d01 | SegoeUI, SegoeUI-Bold, SegoeUI-Light, SegoeUI-Semibold |
| d02 | Georgia, Georgia-Bold, Georgia-Italic, Verdana, Verdana-Bold |
| d03 | Calibri, Calibri-Bold, Consolas |
| d04 | Tahoma, Tahoma-Bold, SakkalMajalla-Bold |
| d05 | YuGothic-Regular, YuGothic-Bold |
| d06 | BookAntiqua, BookAntiqua-Bold, BookAntiqua-Italic |
| d07 | PalatinoLinotype-Roman, PalatinoLinotype-Bold, PalatinoLinotype-Italic |
| d08 | TimesNewRomanPSMT, TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT |
| d09 | ArialMT, Arial-BoldMT |
| d10 | MicrosoftYaHei-Bold, SimSun |
| d11 | CenturyGothic, CenturyGothic-Bold, Garamond, Garamond-Bold |
| d12 | Calibri, Calibri-Bold, Calibri-Italic, Cambria-Bold |
| d13 | NirmalaUI, NirmalaUI-Bold |
| d14 | MalgunGothic, MalgunGothicBold |
| d15 | Roboto-Regular, Roboto-Bold, Consolas |
| d16 | ArialNarrow, ArialNarrow-Bold |
| d17 | MS-PGothic (one font only: its bold text is synthesised from the regular face) |
| d18 | TrebuchetMS, TrebuchetMS-Bold, Corbel, Corbel-Bold |
| d19 | TraditionalArabic, TraditionalArabic-Bold, MicrosoftSansSerif |
| d20 | Candara, Candara-Bold, Constantia-Bold |
| d21 | LeelawadeeUI, LeelawadeeUI-Bold |
| d22 | FranklinGothic-Book, FranklinGothic-Demi |
| d23 | GillSansMT, GillSansMT-Bold, Rockwell, Rockwell-Bold, CourierNewPSMT |
| d24 | GoudyOldStyleT-Regular, GoudyOldStyleT-Italic, TwCenMT-Regular, TwCenMT-Bold |

Every PDF embeds the fonts its HTML names; none fell back to another font.

One trap for whoever extends the set: on the authoring machine Chrome does NOT
resolve the family name `"Franklin Gothic Demi"` -- it silently prints that text in
Times New Roman. d22 therefore asks for `font-family: "Franklin Gothic";
font-weight: bold`, which resolves to FranklinGothic-Demi. Always confirm the
`/BaseFont` names after rendering.
