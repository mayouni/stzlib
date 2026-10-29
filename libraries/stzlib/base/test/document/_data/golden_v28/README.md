# Golden set v28 -- realistic documents with known structure

Twenty-four whole documents of the kinds organisations produce (invoices, letters, reports, forms,
statements, minutes, a contract, a pay slip, a safety data sheet, a newsletter, ...), each given as

- `nNN.html` -- the source, written by hand for this set;
- `nNN.pdf` -- the same page printed by headless Chrome;
- `nNN.expected.json` -- the expected structure: title, headings, key sentences, tables, list items,
  furniture, languages, code, and notes for the scorer.

The set is meant to score document readers (Docling, Softanza's native PDF reader) on reading order,
headings, tables, lists and page furniture.

## How it was made

- One author wrote every document in one session (2026-10-29). Each document is a small Python
  script that builds the HTML and the expected JSON from the same source strings, so every expected
  text is the text that was put on the page (tags stripped, entities decoded, whitespace collapsed,
  NFC). Hand-chosen conventions are stated in each file's `notes`.
- Rendering: `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<separate scratch profile> --print-to-pdf=nNN.pdf file:///.../nNN.html`.
  Multi-page documents (except n15) are built as fixed A4 page boxes with `@page { margin: 0 }` so
  that running headers, footers and page numbers are part of the body; single-page documents and n15
  use `@page { size: A4; margin: 2cm }` (n21 is A4 landscape). n15 is the one document whose page
  breaks were left to the browser.
- Checks run before and after printing (none of them is a PDF text extractor):
  - every font family named in the CSS was looked up in `C:\Windows\Fonts` by its name table; no
    variable font is used; every character of every text run (including CSS-generated list markers
    and `::before` content) was checked against the cmap of the exact face that run uses;
  - a DOM layout check in headless Chrome confirmed that no text overflows its page box;
  - from the raw PDF bytes: the page count from the `/Type /Page` objects and the `/Count` entry, and
    the embedded fonts from the `/BaseFont` names, compared with the intended faces. In all 24 PDFs
    the embedded fonts are exactly the intended ones; no fallback font appears.
- **The author never ran a PDF-to-text extractor, converter or rasterizer on these files, never
  looked at golden_v1 to golden_v27, and never looked at any reader's code or output.** Layout was
  inspected only through screenshots of the HTML source taken with headless Chrome.
- All organisations, people, addresses, account numbers and products are invented.

## Conventions used in expected.json

- `title` is the first level-1 heading. A letterhead's organisation name is furniture, not a heading;
  table header cells, form labels and box labels are not headings.
- `key_sentences` are full sentences of body paragraphs, in reading order; sentences carrying a
  footnote marker, salutations, signature blocks and pull quotes are excluded.
- Tables: header rows first (both rows of a two-level header are given); merged cells repeat their
  text in every grid cell they cover; a table continued across pages is one table with its header
  once; totals and section rows belong to the table; a cell of several lines is joined with one
  space; right-to-left tables list cells in logical order, rightmost column first. Key/value panels
  are tables without a header row.
- Lists: the marker is included when it is TYPED in the text (followed by one space when it is set
  apart by a hanging indent; with no space for the inline CJK markers of n05 and n09), and omitted
  when CSS draws it (`list-style-type` or `::before`). Each document's `notes` says which is which.
- `furniture`: one visible line per entry; a repeated running header or footer is listed once;
  page-number lines once per page.
- Side-by-side boxes or columns are read box by box, or column by column; each case is named in
  the notes.
- Text: ligatures as letters; no hyphenation was used; non-breaking spaces are spaces; letter-spaced
  text as plain words; scripts without word spaces (ja, zh, th) join wrapped lines with no space;
  right-to-left text in logical order; precomposed letters (NFC). Persian text keeps its zero-width
  non-joiners (U+200C).

## The documents

| id | lang | pages | difficulty | kind | main difficulties | fonts embedded (/BaseFont) |
|---|---|---|---|---|---|---|
| n01 | en | 1 | medium | Commercial invoice (marine supplier) | letterhead + borderless meta table; Bill to/Ship to boxes side by side (box by box); full-grid line items with 2-line cells and colspan totals rows; boxed bank key/value table beside a paragraph; CSS disc/circle nested bullets | Calibri, Calibri-Bold, Calibri-Light |
| n02 | fr | 1 | medium | Official letter from a municipality | letterhead and footer furniture; reference key/value table; subject line as title; table with rule under header only + caption; TYPED '1)' list with nested TYPED 'a)'; non-breaking spaces | Garamond, Garamond-Bold, Garamond-Italic |
| n03 | de | 3 | hard | Quarterly report (energy utility) | running header/footer 'Seite N von 3'; key-figures box above a 2-column CSS body; two-level header table with section rows; zebra table continued across pages 2-3 with repeated header; CSS square bullets, nested CSS decimal list | SegoeUI, SegoeUI-Semibold |
| n04 | ar | 2 | hard | Public tender notice, RTL | RTL logical order; Arabic-Indic digits; full-grid bill of quantities with row-spanning group cells; TYPED '(أ)' list with nested TYPED '١.'; CSS arabic-indic list with nested disc; boxed key/value dates panel | SimplifiedArabic, SimplifiedArabic-Bold |
| n05 | ja | 2 | medium | Board meeting minutes (condominium) | no-space script; key/value grid with th labels; headings '１．' / '（１）'; TYPED inline circled-digit and full-width markers; rules-between-rows table; boxed signature statement | YuGothic-Bold, YuGothic-Regular |
| n06 | es | 2 | hard | Bank account statement | two side-by-side boxes (key/value tables) read box by box; borderless zebra transactions table across pages with repeated header; 2-line concept cells; colspan closing row; TYPED en-dash list with nested middle-dot list | Verdana, Verdana-Bold |
| n07 | en | 2 | hard | IT runbook (database failover) | three Consolas code blocks (shell + YAML); warning box with heading; numbered headings '3.1'; TYPED '1.' lists with nested '1.1'; CSS bullets; rules-between-rows table and small full grid | Consolas, Roboto-Bold, Roboto-Regular |
| n08 | he | 1 | medium | HR procedure, RTL | coloured band furniture; 2-pairs-per-row key/value table; TYPED Hebrew-letter list 'א.' with nested '1.'; zebra table; CSS hebrew-numbered list; geresh/gershayim | Arial-BoldMT, ArialMT |
| n09 | zh | 2 | hard | Product specification sheet | list and parameter table side by side; section rows; row-spanning cells; TYPED inline markers '1.', '（1）', '（一）'; borderless packing list; mixed CJK/Latin spacing | MicrosoftYaHei, MicrosoftYaHei-Bold |
| n10 | ru | 2 | hard | Supply contract | TYPED clause numbers '1.1.' with nested Cyrillic 'а)'; specification grid with caption, 2-line cells and colspan totals; two signature boxes side by side (box by box); running header on page 2 only | TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT, TimesNewRomanPSMT |
| n11 | en | 1 | medium | Completed job application form | form sections as coloured bars (h2); key/value grids with colspans; header tables for education/employment; CSS-drawn check boxes; TYPED '(i)' roman list | CourierNewPSMT, FranklinGothic-Book, TwCenMT-Bold |
| n12 | ko | 1 | medium | School notice to parents with reply slip | header strip furniture; key/value table with th labels; dotted-rule schedule; two rounded boxes side by side (TYPED '가.' list vs CSS bullets); cut-off reply-slip table with empty cells | MalgunGothic, MalgunGothicBold |
| n13 | hi | 2 | hard | Government circular | letterhead; grid with row-spanning cells and Devanagari digits; TYPED '(क)' list with nested '१.'; CSS devanagari list; TYPED copy-to list; running header on page 2 | NirmalaUI, NirmalaUI-Bold |
| n14 | el | 1 | medium | Seminar programme | sidebar beside main column; programme grid with session rows, colspan break rows, chair cells spanning 3 rows, 2-line talk cells; CSS lower-greek list; TYPED 'α)' list | PalatinoLinotype-Bold, PalatinoLinotype-Italic, PalatinoLinotype-Roman |
| n15 | en | 3 | hard | Charity annual report and accounts (flow) | continuous flow paginated by the browser (no page furniture); two-level header SOFA table with section rows and totals; balance sheet with empty-label subtotal rows; footnote marker; CSS lower-alpha list with CSS ::before dash sub-list; TYPED '(a)' | BookAntiqua, BookAntiqua-Bold, GillSansMT, GillSansMT-Bold |
| n16 | pt | 1 | medium | Clinical laboratory report | boxed patient key/value panel before the title; result tables with section rows and 2-line top-aligned reference cells; typed asterisk flags; observations box with TYPED '1)' list | Trebuchet-BoldItalic, TrebuchetMS, TrebuchetMS-Bold |
| n17 | th | 1 | hard | Price quotation | Thai no-space script; customer box and key/value box side by side; item table with vertical rules; amount-in-words cell spanning 4 cols x 3 rows; TYPED Thai-digit list '๑.' with nested '๒.๑' | LeelawadeeUI, LeelawadeeUI-Bold |
| n18 | tr | 1 | medium | General-assembly invitation (association) | agenda as CSS decimal list in two CSS columns; two shaded boxes side by side (key/value table vs TYPED '-' list) | Corbel, Corbel-Bold |
| n19 | vi | 2 | hard | Course syllabus | two-block official header furniture; key/value grid; two-level header schedule table across pages with repeated header and colspan total; TYPED 'a)' list; CSS decimal list | Tahoma, Tahoma-Bold |
| n20 | fa | 1 | medium | Monthly pay slip, RTL | Persian digits and separators; ZWNJ; 3-pairs-per-row key/value panel; earnings and deductions tables side by side; framed net-pay line; CSS persian list; TYPED 'الف)' list | SegoeUI, SegoeUI-Bold |
| n21 | pl | 1 | hard | Waste collection schedule, A4 landscape | wide 13-column grid with district rows spanning all columns and CSS colour swatches; two columns below (TYPED '1)' list with nested 'a)'; boxed key/value panel) | OpenSans, OpenSans-Bold |
| n22 | sw | 2 | medium | NGO project progress report | colour band; main text with sidebar (CSS bullets) side by side; rules-only activity table; full-grid budget with totals; TYPED '(i)' list with nested '(a)'; CSS upper-roman list | Candara, Candara-Bold |
| n23 | en | 3 | hard | Safety data sheet | section bars (h2) and underlined subsections (h3); many key/value tables; two-level header exposure-limit table; composition grid with 2-line cells; TYPED P-code markers; nested CSS square bullets | ArialNarrow, ArialNarrow-Bold |
| n24 | en | 2 | hard | Staff newsletter | masthead title; lead article in 2 CSS columns beside a sidebar; news-in-brief in 3 columns; page 2 in 3 ruled columns with headings, TYPED '1.' list and pull quote; zebra table with caption | CenturyGothic, CenturyGothic-Bold, Georgia, Georgia-Bold, Georgia-Italic |

Languages: English plus eighteen others -- French, German, Arabic (RTL), Japanese, Spanish, Hebrew
(RTL), Chinese, Russian, Korean, Hindi, Greek, Portuguese, Thai, Turkish, Vietnamese, Persian (RTL),
Polish and Swahili. Thirteen documents have two or three pages.

## Known limits

- Code blocks appear in one document only (n07: three blocks in Consolas).
- Nobody has yet looked at the printed PDFs themselves: the author saw HTML screenshots, and the PDFs
  were checked only by byte-level page counts and font names. A human look at the printed pages is
  still owed.
