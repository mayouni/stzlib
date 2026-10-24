# golden_v18 -- independent golden set of realistic PDF documents

24 whole documents of the kinds real organisations produce, each given as

- `aNN.html` -- the source page,
- `aNN.pdf` -- the same page printed to PDF by headless Chrome,
- `aNN.expected.json` -- the structure a reader should recover (title, headings, key sentences
  in reading order, tables, lists, page furniture, languages, code blocks, notes).

Every organisation, person, address, phone number, account number and amount is invented.
Places, laws and scripture references are used only as setting.

## How it was made

1. The documents were written by hand as small Python builders. Each builder emits the HTML and,
   from the same calls, the expected structure, so every expected string is the string that was
   placed on the page (normalised: NFC, whitespace runs collapsed, `**`/inline markup removed,
   two-line cells joined with a space).
2. Pages are explicit: each page is a fixed A4 box (`break-after: page`) holding its own header,
   body and footer, so page furniture and page numbers are known exactly. Documents a09, a12, a13,
   a14, a18 and a24 use `@page { size: A4; margin: 2cm }` with a 170 x 256.6 mm box; the others need
   furniture near the paper edge and use `@page { margin: 0 }` with the margins inside the box.
3. Before printing, every page was laid out by headless Chrome on an instrumented copy of the HTML
   (kept outside the repository) that measured each page body for overflow and listed every character
   with the font family, weight and style it is set in. Each character was checked against the cmap of
   the installed font file for that family and face (fontTools). No overflow and no missing glyph remain.
   Every family named is installed in `C:\Windows\Fonts`; no variable font is used.
4. Rendering: `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<scratch
   profile> --print-to-pdf=<abs>\aNN.pdf file:///<abs>/aNN.html` (Chrome 155, scratch profile outside
   the repository).
5. After rendering, page counts were taken from the raw PDF bytes (`/Type /Page` objects and the
   `/Count` of the page tree) and match `pages` in every expected file; embedded fonts were taken
   from the raw `/BaseFont` names (table below).
6. A self-consistency script checked that every expected heading, key sentence, list item, table
   cell, caption and furniture line occurs in the HTML source text, that tables are rectangular and
   that every document has 4-10 key sentences. Screenshots of the HTML (not of the PDF) were taken
   with headless Chrome to look at the layout.

**The author never ran a PDF-to-text extractor, document converter or PDF rasterizer on these files,
never looked at any reader's code or output, and never opened golden_v1 .. golden_v17.** The
expected files are therefore independent of every reader being scored.

## Conventions (beyond the task's own)

- Headings: the title is the first heading at level 1; levels follow the HTML (`h1`..`h3`).
  Letterhead names, box labels, table header cells and form labels are not headings.
- Key sentences are body sentences exactly as visible, in reading order. In Chinese and Japanese,
  consecutive sentences of one paragraph and wrapped lines join with no space. In Thai, a key
  sentence is a stretch between the spaces Thai uses to separate sentences (see a13 notes).
- Lists: a TYPED list carries its marker in the text (`1.`, `a)`, `(i)`, `–`, `•`, `١.`, `१.`, `가.`,
  `א.`); a CSS-drawn list (disc, circle, square, `"– "` string marker, decimal, arabic-indic) has no
  marker in the text. Each document's notes say which is which.
- Tables: header row(s) first; spanned cells repeated in every covered grid cell; a table continued
  across pages (a11, a19) is one table, header once, with the first part's caption; right-to-left
  tables (a04, a15) list cells rightmost column first.
- Furniture: one visible line per entry; repeated lines once; page-number lines once per page.
- Real hyphens (semi-arid, Stage 4 pre-strip) are part of the word even when a line breaks after them;
  no document uses soft hyphenation.
- Side-by-side boxes/columns read box by box in: a01, a03, a05, a07, a09, a10, a16 (two-column
  body), a20, a21, a23 (and the sign-off blocks of a19).

## Fonts embedded (raw `/BaseFont` names, subset prefix removed)

| id | fonts embedded |
|---|---|
| a01 | Segoe UI (Regular, Light, Semibold, Bold) |
| a02 | Garamond (Regular, Bold, Italic) |
| a03 | Arial (ArialMT, Bold, Italic) |
| a04 | Simplified Arabic (Regular, Bold), Tahoma (Regular, Bold) |
| a05 | Yu Gothic (Medium, Bold) |
| a06 | Calibri (Regular, Bold), Consolas |
| a07 | Book Antiqua (Regular, Bold, Italic, Bold Italic) |
| a08 | Georgia (Regular, Bold, Italic, Bold Italic) |
| a09 | Palatino Linotype (Roman, Bold, Italic) |
| a10 | Constantia, Corbel (Regular, Bold) |
| a11 | Microsoft YaHei (Regular, Bold) |
| a12 | Nirmala UI (Regular, Bold) |
| a13 | Leelawadee UI (Regular, Bold) |
| a14 | Malgun Gothic (Regular, Bold) |
| a15 | Times New Roman (Regular, Bold), Arial (Regular, Bold) |
| a16 | Cambria (Regular, Bold, Italic) |
| a17 | Trebuchet MS (Regular, Bold) |
| a18 | Verdana (Regular, Bold, Italic) |
| a19 | Franklin Gothic Book, Rockwell, Consolas |
| a20 | Times New Roman (Regular, Bold, Italic, Bold Italic) |
| a21 | Candara (Regular, Bold) |
| a22 | Arial Narrow (Regular, Bold), Arial Bold, Courier New |
| a23 | Perpetua (Regular, Bold, Italic), Gill Sans MT |
| a24 | Century Gothic (Regular, Bold) |

Every document embeds exactly the families it names; no fallback font appears in any PDF.
(One finding on the way: CSS `font-family: 'Franklin Gothic Demi'` silently fell back to Times New
Roman in Chrome, because DirectWrite files that face under the family "Franklin Gothic"; a19's
headings were moved to Rockwell, and the /BaseFont check is what caught it.)

## The documents

| id | lang | pages | kind | main difficulties |
|---|---|---|---|---|
| a01 | en | 1 | Freight forwarder tax invoice (logistics) | dark letterhead band; side-by-side boxes; line items with two-line cells; merged subtotal/VAT/total rows; 4-column key/value bank table |
| a02 | fr | 2 | Hospital discharge summary (medical) | letterhead p.1, running header p.2; two-level lab table; zebra medication table; CSS and typed lists; three heading levels |
| a03 | de | 2 | Annual water and sewage bill (municipal utility, water) | address window beside info box; two-level meter table; section rows, subtotals, total; running header p.2 |
| a04 | ar | 2 | Ministry circular on irrigation subsidies (agricultural) | right-to-left; Arabic-Indic digits; typed and CSS arabic-indic lists; two RTL tables; Arabic page numbers |
| a05 | ja | 1 | Hotel guest information (hospitality) | no word spaces; letter-spaced title; two boxes side by side; two-line table cell |
| a06 | en | 2 | Network change runbook (telecom) | numbered headings at three levels; shell and YAML code blocks; typed and CSS ordered lists |
| a07 | es | 3 | Residential lease contract (housing, legal) | justified legal prose; letter-spaced headings; typed lists; side-by-side signature boxes; inventory table |
| a08 | ru | 2 | University course syllabus (educational) | Cyrillic; two-level header table with totals; CSS string-marker list; typed bullet and numbered lists; "— 1 —" page numbers |
| a09 | el | 1 | Ferry timetable (ports, transport) | Greek; ten-column zebra timetable; two small tables side by side; CSS circle list |
| a10 | en | 2 | Home insurance policy schedule (insurance) | boxes side by side; cover table with section rows; premium totals; typed endorsement codes |
| a11 | zh | 2 | Public library annual report (libraries) | Chinese; table continued across pages with repeated header; totals; "第 1 页 共 2 页" |
| a12 | hi | 1 | Polling station notice (elections) | Devanagari digits; total row; typed Devanagari-numbered list; CSS list |
| a13 | th | 1 | National park regulations and fees (forestry, tourism) | Thai without word spaces; Thai digits; two-level header; cell spanning four columns |
| a14 | ko | 1 | Sports centre programme notice (sports) | Korean; two-level header; row-spanning cells; typed 가. 나. 다. list |
| a15 | he | 1 | Appeals committee hearing notice (courts) | right-to-left Hebrew; typed Hebrew-letter list; RTL table; gershayim as ASCII quotes |
| a16 | en | 2 | Two-column scientific short communication (scientific) | two-column flow; full-width abstract and table; superscripts; typed references; journal page numbers 211-212 |
| a17 | pt | 2 | NGO quarterly progress report (NGO) | partly ruled budget table with section rows and total; typed en-dash list; CSS list |
| a18 | tr | 1 | Customs information note (customs) | Turkish dotted/dotless i; borderless table; key/value table |
| a19 | en | 3 | Monthly mine operations report (mining) | KPI two-level header; nine-column table continued p.2 to p.3; INI block; typed and CSS lists |
| a20 | vi | 1 | Fishing cooperative board minutes (fisheries) | Vietnamese diacritics; two-block administrative header; Roman-numeral headings; signatures side by side |
| a21 | sw | 1 | Weekly parish bulletin (religious) | masthead; two columns read column by column; contributions table with totals |
| a22 | en | 2 | Aircraft maintenance work order (aviation) | condensed font; key/value grid; two-line task cells; fault log in Courier New; "Sheet N of 2" |
| a23 | it | 2 | Concert season brochure (cultural) | letter-spaced headings; borderless programme with multi-line cells; price boxes side by side |
| a24 | en | 1 | Electricity tariff schedule (energy, utilities) | wide two-level header; row-spanning code and charge cells; typed notes |

Languages besides English: French, German, Arabic, Japanese, Spanish, Russian, Greek, Chinese,
Hindi, Thai, Korean, Hebrew, Portuguese, Turkish, Vietnamese, Swahili, Italian (17).
Multi-page documents: 13 (a02, a03, a04, a06, a07, a08, a10, a11, a16, a17, a19, a22, a23).
Code/configuration blocks: a06 (2), a19 (1), a22 (1).
