# golden_v16 -- realistic PDF documents with known expected structure

Twenty-four whole documents (y01 to y24) of the kinds real organisations produce, each as `<id>.html` (the source), `<id>.pdf` (rendered) and `<id>.expected.json` (the expected structure). The set scores document readers (Docling and Softanza's native PDF reader). All organisations, people, places and numbers are invented.

## How it was made

- One Python generator per group of documents builds BOTH the HTML and the expected JSON from the same source text, so every expected heading, sentence, table cell, list item, furniture line and code block is the text written into the page. Merged cells are expanded into the grid (text repeated in every covered cell); rows of a table are listed header first.
- Each HTML was printed to PDF with headless Chrome 155 (`--headless=new --disable-gpu --no-pdf-header-footer`, a separate profile outside the repository). Running headers, footers and page numbers are CSS `@page` margin boxes (or body elements for single-page documents), so they are real text in the PDF.
- Fonts: only fonts installed on the authoring machine (C:\Windows\Fonts), no variable fonts. Before rendering, every text node's computed font was checked against that font file's character map (fontTools), and characters a font lacked were replaced or the font changed. After rendering, the /BaseFont names in the raw PDF bytes were compared with the intended families: every document embeds exactly the intended families and no fallback font.
- Page counts come from the raw PDF bytes (`/Type /Page` objects and `/Count`).
- The author never ran a PDF-to-text extractor, a document converter or a PDF rasterizer on these files, never looked at any reader's code or output, and never opened golden_v1 to golden_v15. Visual checks were made on screenshots of the HTML in Chrome, not on the PDFs.

## Conventions a scorer must know

- Text is NFC; whitespace runs collapse to one space (non-breaking spaces count as spaces) except in `code`; a cell or list item of two visible lines is joined with one space. Hard hyphens in compounds (Villeneuve-sur-Ourne, SW-04) are part of the word; no automatic hyphenation was used.
- `title` is the main heading and is also the first entry of `headings` at level 1. Letterhead names, table header cells, form labels, box captions inside signature areas and subtitles are not headings.
- `key_sentences` are body sentences in reading order. Where two boxes or columns sit side by side, reading order is box by box (or column by column); each document's `notes` say so. A sentence carrying a footnote marker is left out.
- `list_items` keep the marker when it is typed in the text (e.g. "(a)", "1)", "–", "•", "۱-") and omit it when CSS draws it (discs, squares, circles, CSS numbers or letters); `notes` say which.
- `furniture` lists each visible line of letterheads, running headers and footers once; page-number lines are listed once per page ("Page 1 of 2", "Page 2 of 2"). A running header suppressed on page 1 is still listed once.
- A table continued across pages (y16, y24) is ONE table with its header row once, although Chrome repeats the header on the next page. Other tables and code blocks were kept unbroken on purpose (`break-inside: avoid`).
- Right-to-left documents (y12 Arabic, y13 Persian, y14 Hebrew): text in logical order; table cells listed in reading order, rightmost column first. y13 keeps U+200C (zero width non-joiner) inside Persian words; a scorer may strip it before comparing.
- Letter-spaced text is given as its plain words. No `text-transform` or small caps were used: capitals are capitals in the source.

## The documents

| id | pages | kind | language | fonts embedded (PDF /BaseFont) | main difficulties |
|---|---|---|---|---|---|
| y01 | 2 | Mining: quarterly environmental monitoring report | en | Calibri, Calibri-Bold, Cambria-Bold, Cambria-Italic | letterhead; running header from page 2; "Page n of N"; two-level header with row- and column-spans; zebra table; cells of two lines; CSS bullets and typed "(a)" list; three heading levels |
| y02 | 1 | Municipal water utility bill | el | SegoeUI, SegoeUI-Semibold | Greek with tonos; coloured letterhead band; two key/value boxes side by side; charges table with section, subtotal and total rows; CSS bullets |
| y03 | 2 | Hospitality/tourism: resort package and price list | vi | Arial-BoldMT, ArialMT, TimesNewRomanPS-BoldMT, TimesNewRomanPS-ItalicMT, TimesNewRomanPSMT | Vietnamese stacked diacritics; running header and "Trang n/N"; two-level price header; zebra; CSS square bullets and typed "–" lists; key/value table |
| y04 | 3 | Legal/housing: residential lease contract | fr | Garamond, Garamond-Bold, Garamond-Italic | 3 pages; justified text; letter-spaced division headings; three heading levels; typed "a)" lists; footnote marker excluded; partly ruled tables; side-by-side signature boxes; "— n —" footer |
| y05 | 2 | Agricultural cooperative harvest report | pt | Georgia, Georgia-Bold, Georgia-BoldItalic, Georgia-Italic, GillSansMT | two CSS columns read column by column; captions below tables; zebra table with total row; borderless key/value table; boxed quotation; "pág. n" |
| y06 | 1 | Transport: railway closure and replacement-bus timetable | cs | Tahoma, Tahoma-Bold | landscape; narrow and wide columns side by side; wide timetable with two-level header; typed "1)" notes; fixed bottom line |
| y07 | 2 | Medical: hospital discharge summary | pl | Verdana, Verdana-Bold | centred letterhead; running header from page 2; four-column key/value table; lab table with two-level header; CSS numbered list; "Strona n z N" |
| y08 | 2 | Education: university course syllabus | ro | PalatinoLinotype-Bold, PalatinoLinotype-Roman | comma-below ș ț; numbered three-column key/value tables; two-level header; cells of two lines; letter-spaced title; CSS bullets and typed "–" list |
| y09 | 1 | Energy: electricity bill | hu | TrebuchetMS, TrebuchetMS-Bold | double-acute ő ű; two boxes side by side; payment strip that is not a table; non-breaking-space thousands separators; section and total rows |
| y10 | 1 | Logistics/customs: dispatch note for an export container | tr | Candara, Candara-Bold | dotted/dotless i; title inside a letterhead box; two party boxes side by side; four-column key/value table; goods table with totals; typed "a)" list |
| y11 | 1 | Religious: church order of service | yo, en | Cambria, Cambria-Bold, Cambria-Italic | Yoruba tone marks with combining accents on dot-below letters; two CSS columns; typed "1." list and CSS bullets; small tables |
| y12 | 2 | NGO: annual report | ar | Arial-BoldMT, ArialMT, SakkalMajalla, SakkalMajalla-Bold | right-to-left; RTL tables in logical order with totals; zebra; CSS bullets at the right; typed Arabic ordinal markers; key-figure boxes; "صفحة n من N" |
| y13 | 1 | Insurance: home fire insurance policy schedule | fa | Tahoma, Tahoma-Bold | right-to-left Persian with ZWNJ; Persian digits; four-column key/value table; coverage table with total; typed "۱-" list and CSS squares; side-by-side signature boxes |
| y14 | 1 | Housing: tenants' meeting minutes | he | SegoeUI, SegoeUI-Bold, SegoeUI-Semibold | right-to-left Hebrew; CSS numbered list in RTL; typed "החלטה n:" decisions; budget table with total; side-by-side attendance paragraphs |
| y15 | 3 | Telecom/technical: field deployment guide | en | Consolas, Roboto-Bold, Roboto-Regular | 3 pages; three Consolas code/configuration blocks; side-by-side boxes; CSS numbered steps; two-level VLAN header; cells of two lines; bare page numbers |
| y16 | 2 | Aviation: aircraft line-maintenance work order | de | Corbel, Corbel-Bold | task-card table CONTINUES ACROSS PAGES with repeated header; ATA section rows; four-column key/value table; typed "–" list; boxed certificate |
| y17 | 1 | Fisheries: landing declaration and first-sale note | es | CenturyGothic, CenturyGothic-Bold, CenturyGothic-Italic | three boxes side by side; species cells of two lines (italic scientific names); totals; small right-aligned summary table; typed "1." list |
| y18 | 1 | Water: village water committee income and expenditure report | sw | Constantia, Constantia-Bold, Constantia-Italic, TwCenMT-Bold | section rows spanning all columns, subtotal and balance rows; borderless small table; CSS bullets and CSS lower-alpha list |
| y19 | 1 | Financial: microfinance loan account statement | ha | Ebrima, Ebrima-Bold | Hausa hooked letters ɓ ɗ ƙ ƴ and ʼ; two key/value blocks side by side; repayment schedule with total; typed "•" list |
| y20 | 1 | Forestry: tree-seedling distribution notice | am | Ebrima, Ebrima-Bold | Ethiopic script; Ethiopian calendar dates; boxed letterhead; table with total; CSS bullets and typed "1." list |
| y21 | 2 | Scientific: research article | en | Cambria, Cambria-Bold, Cambria-Italic, LucidaSans, LucidaSans-Demi, LucidaSans-Italic | two CSS columns with a full-width table between column blocks; footnote marker excluded; typed reference list; running header; subscript and superscript characters |
| y22 | 2 | Cultural: concert season brochure | it | BodoniMT, BodoniMT-Bold, DroidSerif, DroidSerif-Bold, DroidSerif-Italic | letter-spaced headings and furniture; zebra calendar with cells of two lines; two-level price header; two boxes side by side; CSS bullets and typed "—" lists |
| y23 | 1 | Sports: club annual report | sv | CenturySchoolbook, CenturySchoolbook-Bold, Rockwell-Bold | league table with abbreviations and a highlighted row; two columns side by side read column by column; borderless key/value table; typed and CSS lists |
| y24 | 2 | Retail: store inventory act | ru | OpenSans, OpenSans-Bold | inventory table CONTINUES ACROSS PAGES with repeated two-level header; department, subtotal and total rows; CSS numbered list; "Лист n из N" |

Languages: English plus 21 others -- Greek, Vietnamese, French, Portuguese, Czech, Polish, Romanian, Hungarian, Turkish, Yoruba, Arabic, Persian, Hebrew, German, Spanish, Swahili, Hausa, Amharic, Italian, Swedish, Russian. Twelve documents have 2 or 3 pages.

Code blocks: only y15 carries code (a YAML provisioning file, a CLI session and a command output), set in Consolas.

