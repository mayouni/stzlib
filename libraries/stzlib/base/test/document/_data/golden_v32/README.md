# golden_v32 - independent golden set, version 32

24 whole, realistic documents (`t01` .. `t24`), each as `<id>.html` (source), `<id>.pdf` (Chrome print) and `<id>.expected.json` (known structure).
It is meant to score document readers (Docling and Softanza's native PDF reader) against ground truth that was written independently of any reader.

## How it was made

* The documents were written as HTML/CSS by a Python generator kept **outside** the repository. Every expected value (headings, key sentences, table cells, list items, furniture, code) is registered by the same helper call that writes the HTML, and the generator then checks that every expected string occurs in the normalised visible text of the HTML (whitespace collapsed, NBSP as space, NFC). The expected JSON therefore comes from the source, never from the PDF.
* Each HTML was rendered with headless Chrome (`--headless=new --no-pdf-header-footer`, own scratch profile) on A4. Page counts come from the raw PDF bytes (`/Type /Page`, `/Count`). Most documents are paginated by hand (one `section` per A4 page, `@page` margin 0) so that page furniture and page numbers are exact; t17 and t24 are flowing documents (`@page` margin, `position:fixed` header/footer in the margins) whose page breaks, and the tables breaking across them, are decided by the browser.
* Layout was checked with DOM geometry in headless Chrome (no section overflows its page, no clipped text, slack to the footer measured). **No PDF-to-text tool, no PDF rasterizer and no reader was ever run, and no output of any reader was seen.** The author never looked at golden_v1 .. golden_v31 or at any reader code, results file or memo. Consequence: the PDFs were not looked at as images; the position of the fixed header/footer of t17 and t24 in the page margins is by construction (negative offsets), not by sight.
* Fonts: every family used was checked against `C:\Windows\Fonts`; every character used was checked against the cmap of the font files that serve it (fontTools, which reads font files, not PDFs); no variable fonts. After rendering, the `/BaseFont` names in the raw PDF bytes were compared with the intended families: **all intended fonts are embedded in all 24 PDFs, and no unintended fallback font appears in any of them.**

## Conventions a scorer must know (details per document are in `notes`)

* `list_items`: text **with** the marker when the marker is typed in the text (e.g. `(a) ...`, `1) ...`, `- ...`, `• ...`, `١- ...`); **without** the marker when CSS draws it (native `ul`/`ol` markers). Each `notes` field says which lists are typed and which are CSS-drawn.
* Real hyphens inside words are part of the word; the generator keeps such words on one line (no break at a hyphen) so that no line-end hyphen is ambiguous. No soft hyphens and no automatic hyphenation are used.
* In scripts written without spaces (Japanese, Chinese, Thai) a line wrapped inside a sentence joins with no space; spaces that are really printed (e.g. between Thai clauses) are kept. Thai sentences carry no full stop.
* Right-to-left documents (t03, t05, t14) list text and table cells in logical order, first cell = rightmost column. Persian t14 keeps ZWNJ (U+200C) inside words.
* A merged cell repeats its text in every grid cell it covers (row and column spans, also inside two-level headers). Empty cells are empty strings.
* Tables that the browser breaks across pages (t17, t24) are ONE table in `tables`; the header row the browser repeats on the next page is not repeated in `rows`. Tables that are hand-split do not occur.
* Letterhead / organisation names are furniture, not headings. Form labels and table header cells are not headings. Footnote text (t15) and authors/affiliation lines (t15) are not listed anywhere; the sentence carrying the footnote marker is not a key sentence.
* Side-by-side boxes and columns are read box by box / column by column (stated in the notes of t01, t07, t11, t12, t15, t18, t19, t20, t22).
* Page-number lines are furniture, once per page, in the form printed (`Page 1 of 1`, `Seite 1 von 2`, `- 1 -`, `1 / 2`, `Page 4-1`, `Page one`, `2 - The Harbour Gazette - Autumn 2026` (with an em dash), bare `1`, digits of the document's own script...). Running headers/footers that repeat are listed once.

## Documents

| id | kind | lang | pages | fonts embedded (from /BaseFont) | main difficulties |
|---|---|---|---|---|---|
| t01 | English invoice with letterhead | en | 1 | Arial-BoldMT, ArialMT | two side-by-side key/value panels (box by box); line-item table with section rows and merged totals rows; typed hyphen list with a nested level; letterhead and footer furniture |
| t02 | German terms of delivery | de | 2 | TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT, TimesNewRomanPSMT | justified text; paragraph-sign headings; typed (1)/a) markers in a hanging indent; two small tables ruled under the header only; running header and "Seite n von 2" |
| t03 | Arabic university circular (right to left) | ar | 2 | Arial-BoldMT, Tahoma, Tahoma-Bold, TimesNewRomanPS-BoldMT | RTL logical order; Arabic-Indic digits; typed "١-" and Arabic-letter markers; RTL grid table with caption; boxed key/value table |
| t04 | Japanese meeting minutes | ja | 2 | MS-Gothic, YuGothic-Bold, YuGothic-Regular | no spaces between words (wraps join without space); typed full-width （１） ① ・ ア． markers; MS Gothic key/value table; "- n -" page numbers; CSS bullets |
| t05 | Hebrew price quotation (right to left) | he | 2 | Arial-BoldMT, ArialMT, Tahoma-Bold | RTL table with section rows and three totals rows; typed 1. and Hebrew-letter markers; ASCII quotes inside words; CSS bullets; second table |
| t06 | Russian pump manual | ru | 2 | Arial-BoldMT, ArialMT, Consolas, Georgia, Georgia-Bold | Cyrillic; Consolas config block with Cyrillic comment; boxed key/value table; fault table with two-line top-aligned cells; typed 1) and а) markers; CSS bullets |
| t07 | Greek course outline | el | 2 | PalatinoLinotype-Bold, PalatinoLinotype-Italic, PalatinoLinotype-Roman, Sylfaen | table beside text (side-by-side boxes, box by box); typed α) β) γ); borderless 12-row schedule; ruled assessment table; CSS decimal list |
| t08 | Chinese corporate notice | zh | 3 | MicrosoftYaHei, MicrosoftYaHei-Bold, SimSun | letter-spaced red letterhead; 一、-style headings; typed （一） / 1. / （1） markers; zebra table; borderless key/value; attachment table with total row; 3 pages |
| t09 | Korean public parking guide | ko | 2 | MalgunGothic, MalgunGothicBold | two-level header with row and column spans; typed 1. / 가. and ○ / - markers; two-line centred cells; CSS bullets |
| t10 | Hindi school circular | hi | 2 | NirmalaUI, NirmalaUI-Bold | Devanagari; typed १. / (क) markers; CSS devanagari-numbered list; two grid tables; footer in Devanagari digits |
| t11 | Thai hotel guest guide | th | 2 | LeelawadeeUI, LeelawadeeUI-Bold, Tahoma-Bold | no word spaces, wrapping inside clauses; paragraph beside a box with CSS bullets; typed Thai numerals and Thai letters; ruled and borderless tables |
| t12 | French association annual report | fr | 3 | Garamond, Garamond-Bold, Garamond-Italic, GillSansMT, GillSansMT-Bold | side-by-side boxes with CSS bullets; typed 1. / 1.1 / a) three-level list; zebra table; finance table with section and total rows and NBSP amounts; 3 pages |
| t13 | Turkish laboratory report | tr | 2 | Tahoma-Bold, Verdana, Verdana-Bold | Turkish letters; boxed key/value panel; results table ruled between rows with section rows; typed 1) / a) markers |
| t14 | Persian sales report (right to left) | fa | 2 | Arial-BoldMT, Tahoma, Tahoma-Bold, TimesNewRomanPS-BoldMT | Persian digits and ZWNJ; RTL zebra table with caption and total row; typed ۱- and الف) markers; CSS bullets; ruled table |
| t15 | English two-column scientific article | en | 3 | TimesNewRomanPS-BoldItalicMT, TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT, TimesNewRomanPSMT | two columns side by side (column order); abstract box; footnote-marker sentence excluded; booktabs tables with captions; typed [n] references; bare page numbers; 3 pages |
| t16 | English operations runbook | en | 2 | Consolas, SegoeUI, SegoeUI-Bold, SegoeUI-Semibold | four code blocks (Consolas); headings level 1-3; ruled option table; partly ruled error table; CSS nested lists; typed en-dash list |
| t17 | English consolidated financial statements (flowing) | en | 3 | Calibri, Calibri-Bold, Cambria-Bold | two-level header; tables breaking across pages (header repeated by the browser); section, sub-total and total rows; 7-column table; CSS roman list; typed (a)/(b); no page numbers |
| t18 | English committee agenda and minutes | en | 2 | TrebuchetMS, TrebuchetMS-Bold | two boxes side by side (CSS bullets / typed hyphens); borderless agenda; typed (a)-(c); CSS roman list with nested bullets; two-line top-aligned and centred cells |
| t19 | English product datasheet | en | 2 | CenturyGothic, CenturyGothic-Bold, Verdana, Verdana-Bold | sidebar beside main column (box by box); section rows; boxed key/value; typed bullets with nested en dashes; Century Gothic headings |
| t20 | English community newsletter | en | 2 | Georgia, Georgia-Bold, Georgia-Italic, PalatinoLinotype-Bold | three columns then two; pull quote; CSS bullets, typed bullets, typed numbers, CSS numbers; classifieds table; varied page-number forms |
| t21 | English employee-handbook section | en | 3 | PalatinoLinotype-Bold, PalatinoLinotype-BoldItalic, PalatinoLinotype-Roman | CSS roman list with nested alpha list; typed (a)/(i) hanging lists; ruled, borderless and grid tables; "Page 4-n" numbers; 3 pages |
| t22 | Spanish sanitary inspection report | es | 2 | Candara, Candara-Bold | two key/value panels side by side; checklist with section rows and coloured results; two-line cells; typed 1. / a); CSS alpha list |
| t23 | English packing list and shipping declaration | en | 2 | Roboto-Bold, Roboto-Regular, RobotoCondensed-Bold, RobotoCondensed-Regular | four-column form table without header; wide 8-column table with two-line cells and merged total row; signature table with empty cell; CSS list in small type |
| t24 | Vietnamese tour itinerary (flowing) | vi | 2 | Cambria-Bold, Tahoma, Tahoma-Bold | long table breaking across pages with day section rows; Vietnamese diacritics; typed bullets and dashes; CSS numbered terms |

Chrome embeds the bold/italic faces it actually used; a family listed in the table without its bold face simply did not use it in that document.
