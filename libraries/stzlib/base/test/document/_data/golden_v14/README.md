# golden_v14 — 24 realistic documents for scoring document readers

This folder is an **independent golden test set** of 24 whole, realistic documents (ids `w01` to `w24`), each given as the HTML source, the PDF printed from it, and an `expected.json` describing the structure a perfect reader should recover: title, headings with levels, key body sentences in reading order, tables as cell grids, list items, page furniture, languages, code blocks, and notes for the scorer. It is meant to score document readers such as Docling and Softanza's native PDF reader.

## How it was made

- Every document is invented: organisations, people, addresses, account numbers and figures are fictional (totals are arithmetically consistent). The kinds cover commerce, logistics, medicine, utilities, law, education, NGO work, finance, culture, aviation, agriculture, hospitality, housing, science, religion, insurance, energy, mining, sports, telecom, transport and retail, in 19 languages: Amharic, Arabic, Dutch, English, French, German, Greek, Hausa, Hebrew, Indonesian, Italian, Persian, Polish, Portuguese, Russian, Spanish, Swahili, Turkish, Vietnamese. Three are right-to-left (Arabic, Persian, Hebrew).
- One Python generator (kept outside the repository) builds each document from a single description, so the HTML and its `expected.json` come from the same strings: a table is written once and emitted both as HTML (with `colspan`/`rowspan`) and as the expected grid with merged texts repeated; a key sentence is written once and both printed and recorded.
- Each HTML was printed to PDF with headless Chrome 155 (`--headless=new --disable-gpu --no-pdf-header-footer`, separate profile), A4. Most documents lay out their own pages (`@page { margin: 0 }`, one fixed-height `section.page` per page, furniture placed in the body), so page content and page numbers are fixed by the author. Three documents (w06, w14, w24) are flowed with `@page { margin: 2cm }`-style margins and their running headers and page numbers drawn as CSS page-margin boxes; their page count is the one Chrome produced. w21 is landscape.
- Checks used, none of which reads text back out of a PDF: (1) before printing, the same HTML was laid out by headless Chrome with `--dump-dom` and a script measured, page by page, that no content reaches the footer or crosses the right margin; (2) after printing, the raw PDF bytes were scanned (including inflated object streams) for `/Type /Page`, `/Count` and `/BaseFont` names; (3) character coverage of the intended fonts was read from the TrueType `cmap` tables in `C:\Windows\Fonts`. A probe confirmed that page-margin-box text is rendered (its font, used nowhere else, was embedded).
- **The author never ran, imported or opened any PDF-to-text or document-conversion tool, any PDF rasterizer, any reader's code or any reader's output, and did not look at golden_v1 to golden_v13.** Nothing in this set was copied from them.

## Conventions for scoring

- Texts are the visible text with whitespace runs collapsed to one space; no-break spaces (U+00A0, U+202F) count as plain spaces. Ligatures are given as their letters. No word is hyphenated by the renderer (no `hyphens: auto`); hyphens in the expected text are real hyphens.
- Text typed in capitals in the source is given in capitals; letter-spaced text is given as plain words. No CSS `text-transform` is used.
- `headings`: document order, the title first at level 1. A letterhead's organisation name, table header cells, address labels and form-like labels are not headings. Box titles that are styled as headings are headings (each document's notes say which).
- `key_sentences`: 4 to 10 full body sentences, in reading order; a sentence carrying a footnote marker is never included.
- `tables`: header rows first; merged cells repeat their text in every grid cell they cover; totals, subtotal and section rows are rows of the same table; a cell of two lines is its two lines joined with one space; an empty cell is ""; a table continued across pages is ONE table with its header rows once, whether or not the document (or the renderer, for `<thead>` in flowed documents) repeats them; right-to-left tables list cells in logical order, rightmost column first. Key/value tables have no header row. `caption` is the caption text or null.
- `list_items`: only visible lists; `text` carries the marker when the marker is typed text (e.g. "1.", "a)", "•", "–", "[1]", "۱."), joined to the item by one space, and no marker when CSS draws it (all CSS markers here are drawn boxes or dots, never generated text).
- `furniture`: letterhead, running header and footer lines, one visible line per entry; a line repeated on several pages is listed once; page-number lines that differ per page ("Page 1 of 2", "Page 2 of 2") are each listed.
- Right-to-left text is in logical order. Persian words contain U+200C (zero-width non-joiner) as written; a scorer may treat it as ignorable.
- Side-by-side boxes or columns are read box by box (left box first in left-to-right documents, right box first in right-to-left ones); each document's `notes` says where.
- `code`: exact text of each code block, lines joined with "\n", leading spaces kept.

## The 24 documents

| id | kind | language | pages | difficulty | main difficulties |
|---|---|---|---|---|---|
| w01 | Freight forwarder tax invoice (logistics, commercial) | English | 1 | medium | letterhead; two side-by-side box pairs read box by box; line-item table with spanning total rows; key/value tables without header |
| w02 | Hospital discharge letter (medical) | French | 2 | hard | 2 pages; running header on page 2; two-level lab table with row and column spans; no-break spaces; typed and CSS lists; headings at 3 levels |
| w03 | Municipal water bill (water, utilities, municipal) | Arabic | 1 | hard | Arabic RTL; side-by-side boxes read right first; bill table with spanning subtotal rows; Arabic-Indic list markers; CSS list |
| w04 | Software installation guide (technical) | German | 2 | medium | 2 pages; numbered headings at 3 levels; two code blocks (shell, TOML); inline code; typed steps; CSS list |
| w05 | Residential lease contract (legal, housing) | Spanish | 3 | medium | 3 pages; justified serif text; letter-spaced capital section headings; clause headings at level 3; Roman and a) lists; signature boxes side by side |
| w06 | University course syllabus (educational) | English | 3 | medium | flowed 3 pages; CSS page-margin running header and "– n –" numbers; zebra schedule table with two-line cells, may break across pages; footnote |
| w07 | NGO quarterly report (NGO, health) | Swahili | 2 | hard | Swahili; 2 pages in two explicit columns read column by column; full-width table with caption; typed and CSS lists |
| w08 | Cooperative balance sheet (financial, agricultural) | Portuguese | 2 | hard | Portuguese; one table across 2 pages with two-level header repeated on page 2; section rows spanning 6 columns; printed page numbers 14 and 15 |
| w09 | Public library regulations (cultural, administrative) | Persian | 1 | hard | Persian RTL; Persian digits and separators; ZWNJ inside words; fee table; typed and CSS lists |
| w10 | Airline ground-handling bulletin (aviation) | English | 2 | hard | 2 pages; wide holdover table with two-level header and row spans; letter-spaced running header; Courier New code block; CSS checkbox list |
| w11 | Agricultural extension leaflet (agricultural) | Hausa | 1 | medium | Hausa with hooked letters; zebra calendar table with two-line cells; side note box beside the main column |
| w12 | Hotel meeting-package offer (hospitality) | Turkish | 1 | medium | Turkish; two package boxes side by side with CSS lists; room-rate table; typed "1)" conditions |
| w13 | Residents' meeting minutes (housing) | Hebrew | 2 | hard | Hebrew RTL; 2 pages; budget table with total; typed and CSS lists; geresh/gershayim; signature boxes read right first |
| w14 | Groundwater technical note (scientific, water) | English | 2 | hard | flowed two-column layout over 2 pages; margin-box running header; caption below table; footnote marker; typed references |
| w15 | Parish Sunday-school programme (religious) | Amharic | 1 | medium | Amharic in Ge'ez script (Ebrima); schedule table; CSS and typed lists; Ethiopic punctuation |
| w16 | Home insurance policy schedule (insurance) | Polish | 2 | medium | Polish; 2 pages; three key/value tables; coverage table with two-line cells and total; two-level typed list |
| w17 | Household electricity bill (energy, utilities) | English | 1 | medium | side-by-side account and meter boxes; zebra charges table with spanning total rows; minus signs; CSS list |
| w18 | Monthly mine production report (mining) | Indonesian | 2 | hard | Indonesian; wide 8-column table across 2 pages WITHOUT repeated header; two-level header; pit section rows and subtotals |
| w19 | Sports club fixtures and fees (sports) | Greek | 1 | easy | Greek; fixtures and fees tables; Greek-letter list markers; letter-spaced capital letterhead |
| w20 | Mobile telecom bill (telecom) | Vietnamese | 1 | medium | Vietnamese with stacked diacritics; charges table with spanning rows; APN configuration block in Courier New; CSS list |
| w21 | Regional bus timetable (transport) | Italian | 1 | hard | Italian; landscape page; 11-column timetable with two-level header; side-by-side boxes; symbol list markers |
| w22 | Web-shop order confirmation (retail) | Dutch | 1 | medium | Dutch; side-by-side address and order boxes; order lines with two-line cells; spanning total rows; no-break spaces after "€" |
| w23 | Festival volunteer handbook (cultural, administrative) | English | 3 | medium | 3 pages; three-level typed list; zebra shift table with two-line cells; side-by-side boxes; contacts table |
| w24 | Scientific conference programme (scientific) | Russian | 2 | medium | Russian; flowed 2 pages; margin-box header and "Стр. n из N"; three schedule tables with two-line cells; CSS and typed lists |

## Fonts embedded (from the `/BaseFont` names in each PDF)

Every family named in the CSS was checked against `C:\Windows\Fonts` (and the registry font list) before rendering; no variable font is used; code blocks use Consolas or Courier New. After rendering, every PDF embeds only the families its CSS names: no fallback font appeared in any document. One naming quirk: w01 asks for "Franklin Gothic Medium" and Chrome embeds the face named FranklinGothic-Demi.

| id | embedded fonts | PDF bytes |
|---|---|---|
| w01 | FranklinGothic-Book, FranklinGothic-Demi | 66439 |
| w02 | Calibri, Calibri-Bold, Cambria-Bold, Cambria-BoldItalic | 102342 |
| w03 | SakkalMajalla, SakkalMajalla-Bold, SimplifiedArabic-Bold | 76793 |
| w04 | Consolas, Tahoma, Tahoma-Bold, Verdana, Verdana-Bold | 102837 |
| w05 | BookAntiqua, BookAntiqua-Bold, Garamond, Garamond-Bold, Garamond-Italic | 134485 |
| w06 | Georgia, Georgia-Bold, GillSansMT, GillSansMT-Bold | 110690 |
| w07 | Candara, Candara-Bold, Candara-Italic, Rockwell | 81661 |
| w08 | ArialNarrow, ArialNarrow-Bold, TimesNewRomanPSMT | 137120 |
| w09 | Tahoma, Tahoma-Bold | 73314 |
| w10 | Arial-Black, Arial-BoldMT, ArialMT, CourierNewPSMT | 113181 |
| w11 | SegoeUI, SegoeUI-Bold, SegoeUIBlack | 55168 |
| w12 | Constantia, Constantia-Bold, Corbel | 52250 |
| w13 | Arial-BoldMT, ArialMT, TimesNewRomanPS-BoldMT | 86260 |
| w14 | LucidaBright, LucidaBright-Demi, LucidaSans, LucidaSans-Demi, LucidaSans-Italic | 88307 |
| w15 | Ebrima, Ebrima-Bold | 59378 |
| w16 | Roboto-Bold, Roboto-Regular, RobotoCondensed-Bold, RobotoCondensed-Regular | 61741 |
| w17 | OpenSans, OpenSans-Bold | 51383 |
| w18 | TwCenMT-Bold, TwCenMT-Condensed, TwCenMT-Regular | 111520 |
| w19 | PalatinoLinotype-Bold, PalatinoLinotype-BoldItalic, PalatinoLinotype-Roman | 119398 |
| w20 | CourierNewPSMT, Tahoma, Tahoma-Bold, TimesNewRomanPS-BoldMT | 137771 |
| w21 | CenturyGothic, CenturyGothic-Bold, GillSansMT-Condensed | 93074 |
| w22 | TrebuchetMS, TrebuchetMS-Bold | 62702 |
| w23 | BookmanOldStyle, BookmanOldStyle-Bold, CenturySchoolbook, CenturySchoolbook-Bold | 118604 |
| w24 | Constantia, Constantia-Italic, SegoeUI, SegoeUI-Semibold | 98179 |

## Files

`wNN.html` (source, UTF-8), `wNN.pdf` (printed by Chrome), `wNN.expected.json` (UTF-8, keys: id, difficulty, pages, title, headings, key_sentences, tables, list_items, furniture, languages, code, notes). The PDF is the test input; the HTML is kept so that a person can see exactly what was printed.
