# golden_v30

An independent golden test set of 24 realistic PDF documents with known expected structure, written to score document readers (Docling and Softanza's native PDF reader).

## What is in it

For each id `r01` .. `r24`:

- `rNN.html` - the source document (hand-composed HTML/CSS, no external resources, only fonts installed on the authoring machine),
- `rNN.pdf` - the HTML printed by headless Chrome (155) with no browser header or footer,
- `rNN.expected.json` - the expected structure: `id, difficulty, pages, title, headings, key_sentences, tables, list_items, furniture, languages, code, notes`.

Languages: English (6 documents) and 18 others - German, French, Spanish, Arabic (RTL), Hebrew (RTL), Japanese, Chinese, Korean, Russian, Greek, Hindi, Thai, Persian (RTL), Turkish, Georgian, Italian, Portuguese, Vietnamese. 19 of the 24 documents have 2 or 3 pages.

## How it was made

- A Python generator (kept outside the repository, in the author's scratch folder) builds each document from helper calls (heading, paragraph, list, table, code block, furniture line). The same call writes the HTML and records the expected entry, so the HTML and the expectation cannot drift apart: table grids (including merged cells repeated in every covered grid cell), list markers (typed markers are part of the text, CSS-drawn bullets are not), headings and key sentences are all derived from what was written into the HTML. Key sentences are asserted to be substrings of the visible paragraph text.
- Chrome command: `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch profile> --print-to-pdf=rNN.pdf file:///.../rNN.html`. Documents with fixed pages are built from A4 `.page` blocks with furniture placed in the body; documents marked "flowing" use `@page { size: A4; margin: ... }` and `@page` margin boxes for running headers and page numbers (`counter(page)`, `counter(pages)`), and their furniture entries are written from the final page count.
- Every font family named in the CSS was checked against the installed fonts (name tables read from `C:\Windows\Fonts`, no variable fonts), and every character of every document was checked against the cmap of the first font of its stack (regular and bold). No coverage problem remained. Code blocks use Consolas.
- Page counts and the embedded font names were read from the raw PDF bytes (`/Type /Page` objects, `/Count`, `/BaseFont`). A layout check measured the fixed `.page` blocks for overflow (none overflowed), and the table of the flowing documents r19 and r21 was measured to make sure it crosses a page boundary.

## Independence

The author of this set never ran, imported or opened any PDF-to-text or document-conversion tool, any PDF rasterizer, any reader's code or any reader's output, and never looked at `golden_v1` .. `golden_v29` (only a directory listing of the names was taken to check that `golden_v30` did not exist). Nothing in the expectations comes from an extractor: they come from the source text. For a layout sanity check the HTML sources of several documents were screenshotted by headless Chrome (a rendering of the HTML, not of a PDF).

## What was not verified

Because no extractor or PDF rasterizer was used, the following rest on the HTML and Chrome's known behaviour and were not looked at in the PDFs: the exact page-break positions of flowing documents (r04, r17, r18, r19, r21); the margin-box furniture of those documents (a probe showed Chrome 155 renders `@page` margin boxes with page counters; the page totals come from the PDF byte count); line wraps in right-to-left and no-space scripts; whether a soft hyphen breaks a word at a line end (r02 contains several; expected texts hold the whole words). Sylfaen (r16) has no bold face, so bold is synthesised by Chrome. Page counts and fonts below are from the raw PDF bytes.

## The documents

| id | kind | lang | pages | main difficulties | fonts embedded (/BaseFont) |
|---|---|---|---|---|---|
| r01 | Invoice (en) | en | 1 | letterhead, boxed kv panel, zebra grid with merged total rows, borderless table, typed dash list | Calibri, Calibri-Bold |
| r02 | Product datasheet (de) | de | 2 | two-level table header, hierarchical hanging list 2.1/2.1.1, (a) and bullet lists, INI code block, soft hyphens | Consolas, SegoeUI, SegoeUI-Bold, SegoeUI-Semibold |
| r03 | Meeting minutes (fr) | fr | 2 | running header, 1) / a) lists, H1-H3, rules-between-rows table, top-aligned multi-line cells, side-by-side signature boxes | Georgia, Georgia-Bold, Georgia-BoldItalic, Georgia-Italic |
| r04 | Telework policy (es), flowing | es | 3 | 1. / (a) / i. lists, typed bullets and dashes, rules table, question headings, margin-box header and page numbers | PalatinoLinotype-Bold, PalatinoLinotype-BoldItalic, PalatinoLinotype-Roman |
| r05 | Circular (ar, RTL) | ar | 2 | RTL letterhead, kv panel, Arabic-letter and Arabic-Indic lists, RTL table with 2-line cells, CSS square bullets | SegoeUI, SegoeUI-Bold |
| r06 | Service agreement (he, RTL) | he | 2 | RTL, Hebrew-letter list + nested 1), decimal clause list, price table with merged total, signature boxes | Arial-BoldMT, ArialMT |
| r07 | Quotation (ja) | ja | 2 | full-width (１) markers, circled digits, kanji-numeral list, middle-dot bullets, grid table with merged totals, no word spaces | YuGothic-Bold, YuGothic-Regular |
| r08 | User manual (zh) | zh | 2 | Chinese numeral headings, zebra spec table, 1. / （1） / （一） lists, boxed warning, no word spaces | MicrosoftYaHei, MicrosoftYaHei-Bold |
| r09 | Internal notice (ko) | ko | 2 | 1) / 가. lists, table with rowspan groups, CSS round bullets, closing 끝. | MalgunGothic, MalgunGothicBold |
| r10 | Job description (ru) | ru | 2 | two boxes side by side (rights | duties) with а) lists, 1.1. hanging list, KPI grid table, CSS squares | Cambria, Cambria-Bold |
| r11 | Recycling report (el) | el | 2 | α) lists with nested dashes, borderless table with total row, 1./α) list, Greek page numbers | PalatinoLinotype-Bold, PalatinoLinotype-BoldItalic, PalatinoLinotype-Italic, PalatinoLinotype-Roman |
| r12 | Scholarship notice (hi) | hi | 1 | Devanagari (क) and १. lists, kv panel, grid table | NirmalaUI, NirmalaUI-Bold |
| r13 | Event announcement (th) | th | 1 | Thai, no spaces between words, banner heading, Thai-digit list, schedule grid, CSS bullets | LeelawadeeUI, LeelawadeeUI-Bold |
| r14 | Course syllabus (fa, RTL) | fa | 2 | RTL, Persian digits, الف) nested list, ZWNJ words, zebra weekly table, bracketed reference list | Tahoma, Tahoma-Bold |
| r15 | Annual report summary (tr) | tr | 1 | dotted/dotless i, partly ruled table, CSS bullets, 1)/a) list, kv panel, running header/footer | Verdana, Verdana-Bold |
| r16 | Conference programme (ka) | ka | 1 | Georgian, side-by-side text+panel boxes, borderless time table, Georgian-letter list with nested 1) | Sylfaen |
| r17 | Command-line guide (en), flowing | en | 2 | three code blocks, zebra option table, text beside table, CSS bullets, numbered list with typed dashes | Consolas, SegoeUI, SegoeUI-Bold, SegoeUI-Semibold |
| r18 | Scientific paper (en), two columns | en | 2 | column-by-column reading order, abstract, booktabs table with caption below, footnote, [n] references | TimesNewRomanPS-BoldItalicMT, TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT, TimesNewRomanPSMT |
| r19 | Income statement (en), flowing | en | 3 | 8-column table across pages, full-width section rows, subtotal/total rows, numbered notes | ArialNarrow, ArialNarrow-Bold |
| r20 | Restaurant menu (pt) | pt | 2 | two boxes side by side with borderless two-line-cell price tables, kv panel, (1) allergen list | Candara, Candara-Bold, Candara-Italic |
| r21 | Tender specification (it), flowing | it | 3 | Art. headings, 1. / 1.1 / a) list, long partly ruled table across pages, a) duties list | Garamond, Garamond-Bold, Garamond-Italic |
| r22 | Community newsletter (en) | en | 2 | masthead, table beside article text, pull quote, CSS bullets, 1) list beside text, zebra fares table | TrebuchetMS, TrebuchetMS-Bold, TrebuchetMS-Italic |
| r23 | Laboratory report (en) | en | 2 | boxed 4-column kv panel, tables with 2-line top-aligned and centred cells, table footnote, roman list, signature boxes | Tahoma, Tahoma-Bold |
| r24 | Tour itinerary (vi) | vi | 2 | Vietnamese diacritics, rowspan day cells, hyphen and bullet lists, 1)/a) list, price table | Corbel, Corbel-Bold |

## Conventions (see each `notes` field for details)

- Merged table cells repeat their text in every grid cell they cover; right-to-left tables list cells in logical order (rightmost column first); a table that continues across pages is one table with its header row once.
- Typed list markers (`1.`, `a)`, `(i)`, Arabic letters, Hebrew letters, `（１）`, `①`, `-`, bullets typed as characters) are part of `list_items` text; bullets drawn by CSS shapes are not (documents r05, r09, r10, r13, r15, r17, r22 use them).
- Furniture: letterheads and mastheads, running headers (listed once) and footers/page numbers (one entry per page when the text differs).
- Side-by-side boxes (reading order box by box): r03 (signatures), r06, r10, r16, r17, r20, r22, r23.
- Text of the signature boxes, pull quotes and bylines is body text that is not in `key_sentences`.
