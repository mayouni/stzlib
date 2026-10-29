# golden_v27 -- 24 realistic documents for scoring document readers

## What the set is

Twenty-four documents, `m01` to `m24`, of the kinds real organisations produce
and send to each other: invoices, quotations, an account statement, minutes,
circulars, reports, a technical specification, forms, a policy, rules, a data
sheet, a newsletter, a letter. They are written in 15 languages and 10 scripts,
are 42 A4 pages in all, and are used to score document readers: a reader is
given the PDF, and its output is compared with the expected JSON.

Each document has three files:

| file | what it is |
|---|---|
| `mNN.html` | the source page, with its CSS (`@page{size:A4 ...}`) |
| `mNN.pdf` | the HTML printed to PDF by headless Chrome |
| `mNN.expected.json` | what a reader should recover from the PDF |

Twelve documents are rated `medium` and twelve `hard` (the `difficulty` field).

## How it was made

One Python generator writes both the HTML and the expected JSON **from the same
strings**. Every heading, key sentence, table cell, list item and piece of page
furniture is recorded into the expected JSON by the same call that emits it
into the HTML, so the two cannot disagree about the text. The PDF is then
printed from the HTML by Chrome:

```
chrome.exe --headless=new --disable-gpu --no-pdf-header-footer
           --user-data-dir=<private profile> --print-to-pdf=mNN.pdf file:///.../mNN.html
```

Every PDF reports `Producer (Skia/PDF m155)` and a page size of
594.96 x 841.92 pt (A4). The only value in the expected JSON that comes from the
PDF is `pages`, read from the PDF's page tree after printing, so that per-page
furniture ("Page n of N") is generated for the real number of pages.

The generator lived in the author's session scratchpad (`lib.py`, `build.py`,
`docs_a.py` to `docs_h.py`, `probe.py`); it is not part of this repository.

### Checks the author's scripts ran

After printing each document, `lib.py` read the PDF **as raw bytes only** --
the uncompressed bytes plus every zlib-inflated stream -- and checked:

- **page count agrees with itself**: the number of `/Type /Page` objects must
  equal the page tree's `/Count`;
- **only the intended fonts are embedded**: every `/BaseFont` (subset prefix
  removed) must belong to a family the document declares, so a silent fallback
  font is reported as `UNEXPECTED embedded`;
- **every declared font is embedded**: a declared family with no embedded face
  is reported as `NOT EMBEDDED`;
- **glyph coverage**: every character of the visible text (and of the code
  blocks, for the monospace font) is looked up in the `cmap` of the declared
  family's installed faces (fontTools over `C:\Windows\Fonts`), so a character
  the font cannot draw is reported before anyone reads the PDF;
- **key-sentence count**: each document must mark between 4 and 10 key
  sentences.

`probe.py` printed one-paragraph test pages per font family to learn which
`/BaseFont` names Chrome embeds for each family before a family was used.
One document carries its own arithmetic check: the account statement (`m09`)
computes its running balance in the generator and asserts it never goes below
zero.

**Reproducibility, checked when this README was written**: each of the 24
builders was called again in memory (nothing written, nothing printed) and its
HTML and expected JSON compared with the files here -- all 24 HTML files and all
24 expected JSON files are identical to what the generator produces.

## Provenance

- The author wrote the set independently: they **never ran a text extractor or
  any document reader on these PDFs**, and **never saw golden_v1 to golden_v26
  or any reader's code or results**. The expected JSON is written from the
  generator's strings, not from anything a reader produced.
- The author was **stopped by a network error after finishing all 24
  documents**, before writing this README.
- **A second agent wrote this README from the set's own files**: the `.html`
  and `.expected.json` files, the PDFs read as raw bytes (for page counts and
  `/BaseFont` names), and the author's generator scripts. That agent also ran no
  PDF-to-text tool, converter or rasterizer, and read no reader, no score and no
  other golden set.

## The expected JSON

```
id, difficulty, pages, title, headings[{level, text}], key_sentences[],
tables[{caption, rows[][]}], list_items[{level, text}], furniture[],
languages[], code[], notes
```

`notes` is the author's plain-language description of what is tricky in that
document and how it is to be read. **Read it before scoring a document**; the
conventions below are gathered from all 24 notes.

## Conventions a scorer must know

### Text normalisation (applied to every expected string)

Tags are stripped and `<br>` becomes a space; soft hyphens U+00AD are removed;
no-break spaces U+00A0 and ideographic spaces U+3000 become an ordinary space;
runs of white space collapse to one space; the string is trimmed and put in NFC.
So a reader that gives `U+3000` (m05, m08) or the French no-break space before
`:` and `;` (m14) must be compared after the same folding. Typographic
characters that are really in the text stay: the minus sign U+2212 (m01, m16),
Polish quotation marks `„ ”` (m22), the Greek eta (m16).

Text that is **letter-spaced** in the page is given as the plain word
("PROGRAMME", "AQUAVENT", "УТВЕРЖДАЮ", the m05 title). A subscript digit is
given as a plain digit ("P2", m16).

### List markers: typed versus CSS-drawn

This is the convention a reader is most likely to get wrong.

- **Typed markers** are characters in the HTML text ("1)", "a)", "–", "•",
  "１．", "（１）", "١.", "أ-", "א.", "(क)", "๑.", "가.", "1°" ...). They are part of the expected item: `marker + " " + text`.
  The notes say whether they hang (hanging indent) or are set inline.
- **CSS-drawn markers** come from `list-style-type` (disc, circle, square,
  decimal, lower-alpha, lower-roman, arabic-indic, devanagari, hebrew,
  cjk-ideographic, and a string value giving an en dash in m24). They are **not
  in the text**, and the expected item is the item text alone, even when the
  PDF shows a number.
- `level` is the nesting depth, starting at 0.
- Several things that look like lists are not: drawn check boxes next to labels
  (m15, m20) are not list items.

### Reading order of side-by-side boxes

When two boxes, panels or columns sit side by side, the expected order is
**box by box**: everything in the first box, then everything in the second --
never line by line across the gap. The first box is the left one on a
left-to-right page and the right one on a right-to-left page (m10). Text set in
**CSS columns** reads column by column (m02, m18, m24). A sidebar reads before
its main area when it is on the left (m16, m24). Documents using this: m01,
m03, m05, m07, m10, m12, m16, m19, m24.

### Right-to-left documents (m04 Arabic, m10 Hebrew)

All text is in **logical order** (the order it is typed), not visual order.
Every table lists its cells **rightmost column first**. Numbers in Arabic-Indic
digits stay in those digits ("صفحة ١ من ٢").

### Scripts written without spaces (m05 Japanese, m08 Chinese, m23 Thai)

Words are not separated by spaces. A line wrapped inside a sentence (or, in
Thai, inside a phrase) **joins with no space**. In Thai, spaces separate phrases
and sentences and are kept as typed, and sentences have no final punctuation.
Korean (m17) does use spaces between words and is set with
`word-break: keep-all`, so a wrapped line joins with a space where the text has
one.

### Tables

- `rows` is a full grid. A cell spanning several rows or columns has its text
  **repeated in every cell it covers**.
- A table that **continues across pages is listed once**, with its header row
  once, even though Chrome repeats the header at the top of each continuation
  page (m09, a transaction table of 69 rows including its header, over three pages).
- A cell with two or three lines (explicit `<br>`) is joined with a space.
- Empty cells are empty strings; an entirely empty row is kept (m15, m20).
- Key/value panels and borderless two-column blocks are tables with no header
  row; boxed "summary strips" and total-amount boxes are not tables (m05, m09).
- `caption` is the caption text when the document has one, otherwise `null`.
  Tables are listed in reading order, which is not always caption order: in
  m18 "Table 2" (in the left column) comes before "Table 1".

### Furniture, headings, key sentences

- **Furniture** is letterheads, running headers and footers and page numbers.
  The left and right parts of one header or footer line are separate entries,
  and a page-number line is listed once per page it appears on. Several
  documents put a running header only from page 2 (m02, m09, m18), or the page
  number only from page 2 (m11).
- Body text that looks like furniture is **not** furniture: issuer blocks,
  reference/date lines, signature blocks, approval blocks, closing formulas
  ("끝.", the m02 registered-office line). The notes say which.
- **Headings** carry their typed numbering when the document types it ("1.1.",
  "TOP 1 –", "§ 1.", "一、", "（一）", "I."). Subtitles, kickers, box labels and
  form field labels are not headings. m14 has no title and no headings (`title`
  is `null`).
- **Key sentences** are 4 to 10 whole sentences per document that a reader
  must recover exactly. Sentences carrying a footnote marker, and footnotes,
  are never key sentences (m16, m18); fill-in lines of underscores are not
  sentences.
- **Code** (m06 only) is given verbatim, including the `$ ` shell prompts.

## Fonts, pages and languages per document

Fonts are the `/BaseFont` names embedded in the PDF, subset prefix removed.
Every page count below is the PDF's own (`/Type /Page` objects and `/Count`
agree) and equals `pages` in the expected JSON.

| id | pages | language | embedded fonts |
|---|---|---|---|
| m01 | 1 | en | Calibri, Calibri-Bold, Cambria, Cambria-Bold |
| m02 | 3 | fr | Garamond, Garamond-Bold, Garamond-Italic, GillSansMT, GillSansMT-Bold |
| m03 | 2 | de | Constantia, Constantia-Bold, Corbel, Corbel-Bold |
| m04 | 2 | ar | SakkalMajalla, SakkalMajalla-Bold, SimplifiedArabic |
| m05 | 1 | ja | YuGothic-Bold, YuGothic-Regular |
| m06 | 2 | en | Consolas, SegoeUI, SegoeUI-Bold, SegoeUI-Italic, SegoeUI-Semibold |
| m07 | 1 | es | Georgia, Georgia-Bold, TrebuchetMS, TrebuchetMS-Bold |
| m08 | 2 | zh | MicrosoftYaHei, MicrosoftYaHei-Bold, SimSun |
| m09 | 3 | en | LucidaSans, Tahoma, Tahoma-Bold |
| m10 | 2 | he | Arial-BoldMT, ArialMT, TimesNewRomanPS-BoldMT, TimesNewRomanPSMT |
| m11 | 2 | ru | Arial-BoldItalicMT, Arial-BoldMT, ArialMT, TimesNewRomanPS-BoldMT, TimesNewRomanPSMT |
| m12 | 2 | en | CalisMTBol, CalistoMT, CalistoMT-Italic, TwCenMT-Bold, TwCenMT-Regular |
| m13 | 1 | hi | NirmalaUI, NirmalaUI-Bold |
| m14 | 1 | fr | BookAntiqua, BookAntiqua-Bold, BookAntiqua-Italic, CenturyGothic, CenturyGothic-Bold |
| m15 | 2 | en | Rockwell, Verdana, Verdana-Bold |
| m16 | 1 | de | ArialNarrow, FranklinGothic-Book |
| m17 | 2 | ko | MalgunGothic, MalgunGothicBold |
| m18 | 2 | en | Candara, Candara-Bold, Candara-BoldItalic, Candara-Italic, CenturySchoolbook |
| m19 | 2 | el | PalatinoLinotype-Bold, PalatinoLinotype-Italic, PalatinoLinotype-Roman |
| m20 | 1 | tr | OpenSans, OpenSans-Bold, RobotoCondensed-Bold |
| m21 | 2 | en | BookmanOldStyle, BookmanOldStyle-Bold, GillSansMT, GillSansMT-Bold |
| m22 | 2 | pl | Cambria, Corbel, Corbel-Bold |
| m23 | 1 | th | LeelawadeeUI, LeelawadeeUI-Bold, Tahoma, Tahoma-Bold |
| m24 | 2 | en | BaskOldFace, GoudyOldStyleT-Bold, GoudyOldStyleT-Italic, GoudyOldStyleT-Regular |

**Totals**: 42 pages (8 one-page, 14 two-page, 2 three-page documents). Each
document is in one language; 15 languages in all -- English 8 documents, French
2, German 2, and one each of Arabic, Japanese, Spanish, Chinese (Simplified;
HTML `lang="zh-CN"`), Hebrew, Russian, Hindi, Korean, Greek, Turkish, Polish and
Thai. Scripts (10): Latin, Arabic, Hebrew, Cyrillic, Greek, Devanagari, Thai, Han,
Kana and Hangul.

## The 24 documents

Counts are from the expected JSON: H headings, K key sentences, T tables,
L list items.

| id | kind | lang | pages | diff | H/K/T/L | main difficulties |
|---|---|---|---|---|---|---|
| m01 | Tax invoice of a UK company | en | 1 | medium | 1/4/3/3 | Letter-spaced letterhead and bottom-margin registration line as furniture; two pairs of side-by-side boxes read box by box; key/value panels without header; total rows merging five columns; CSS disc bullets; U+2212 minus |
| m02 | Annual activity report of an association | fr | 3 | hard | 12/8/2/18 | Running header from page 2 only; two CSS columns; soft hyphens; typed "1)", "a)" and inline en-dash markers only; two-level table header with section rows, zebra bands and total; rule-less calendar table; forced page breaks |
| m03 | Minutes of a German owners' meeting (Eigentümerversammlung) | de | 2 | medium | 9/7/3/12 | Borderless key/value table; CSS decimal agenda next to typed "a)" lists with nested en dashes; table with rules under header only; voting table with a row-spanning cell; side-by-side signature blocks |
| m04 | University circular on final-exam rules | ar | 2 | hard | 5/6/2/13 | Right-to-left, logical order, tables rightmost column first; two-sided letterhead as furniture; Arabic-Indic page number; typed "١." and "أ-" markers next to a CSS arabic-indic list; table cells spanning two rows and holding two lines |
| m05 | Quotation (御見積書) | ja | 1 | medium | 1/4/3/6 | No spaces between words, wrapped lines join with no space; U+3000 as a space; letter-spaced title; side-by-side customer and issuer blocks; total-amount box that is not a table; typed full-width "１．" and "（１）" markers; merged total rows |
| m06 | Software deployment and operations guide | en | 2 | hard | 8/5/3/11 | Two Consolas code blocks (YAML, shell with `$ ` prompts); two-part running header and footer; parameter table with header rule only and cells with line breaks; full-grid troubleshooting table; CSS disc/circle and decimal/lower-alpha nested lists |
| m07 | School report card (Boletín de calificaciones) | es | 1 | medium | 2/4/3/3 | Boxed key/value panel; grades table with two-level header, section rows, zebra bands, a two-column "No calificable" cell and a three-column total label; side-by-side comments and grading-scale table; inline em-dash markers; return slip and signature line as body text |
| m08 | Customer-service centre work summary (nine months) | zh | 2 | hard | 7/6/2/11 | No spaces between words; U+3000 in header, page number and captions; typed "一、" and "（一）" heading numbers; typed half-width "1." and full-width "１．" markers next to a CSS cjk-ideographic list; row-spanning category cells; three-line table |
| m09 | Credit-union current account statement | en | 3 | hard | 3/4/3/3 | Zebra transaction table of 69 rows running over three pages with the header repeated by Chrome but expected once; two-line description cells; empty money cells; summary strip that is not a table; letterhead on page 1, running header from page 2; CSS square bullets |
| m10 | Price quotation for works | he | 2 | hard | 4/5/2/9 | Right-to-left, logical order, tables rightmost column first; footer parts that differ between pages; section and total rows spanning columns; typed "א." markers next to CSS decimal and CSS hebrew lists; side-by-side signature boxes read right box first |
| m11 | Technical specification (техническое задание) | ru | 2 | medium | 11/5/2/9 | Approval block as body text; two-line title of two sizes; typed heading numbers; page number at top centre from page 2 only; typed "1)" and Cyrillic "а)" markers with nested en dashes; full-grid tables with right-aligned captions and two-line cells |
| m12 | Conference programme | en | 2 | hard | 6/5/4/5 | Masthead with letter-spaced kicker; side-by-side main text and sidebar on both pages; borderless key/value table; programme tables with rows spanning three room columns, a cell spanning two rows, another spanning two columns, and cells of two or three lines |
| m13 | Notice of an annual general meeting | hi | 1 | medium | 3/5/1/10 | Devanagari script; Devanagari page number; reference/date line as body text; CSS devanagari-numbered agenda; typed "(क)" markers with nested en dashes; zebra table without vertical rules |
| m14 | Formal administrative letter | fr | 1 | medium | 0/5/0/5 | No title and no headings; letterhead and bottom-margin line as furniture; reference, address, date, "Objet :" and registered-mail lines as body text that are not sentences; typed "1°" and "a)" markers; French no-break spaces |
| m15 | Application form to hire a community hall | en | 2 | medium | 6/6/2/8 | Form fields and empty answer boxes that are neither headings nor tables; drawn check boxes that are not list items; CSS decimal list with nested CSS lower-roman; office-use table with an empty row; forced page break |
| m16 | Pump product data sheet | de | 1 | hard | 7/4/4/6 | Left sidebar read before the main column; four tables, among them a wide table whose header is the first row and whose labels are the first column; CSS square/disc bullets; footnote excluded from key sentences; U+2212, Greek eta, subscript digit |
| m17 | Internal job-training plan | ko | 2 | hard | 7/5/3/11 | Hangul with `word-break: keep-all`; page number "- n -"; three-level Korean typed markers "가.", "1)", "가)"; key/value control panel; course table with row-spanning categories and a three-column total label |
| m18 | Policy brief (street trees and summer heat) | en | 2 | hard | 10/6/2/8 | Full-width summary box above two CSS columns; booktabs table spanning both columns with empty first cells; small table inside a column; tables listed in reading order (Table 2 before Table 1); typed "1."/"(i)" and "[1]" markers; footnotes excluded |
| m19 | Tour itinerary (Peloponnese) | el | 2 | medium | 9/6/1/14 | Letter-spaced letterhead and italic motto as furniture; kicker and dates lines that are not headings; price table with a two-level header; side-by-side boxes with CSS discs on one side and inline en dashes on the other; typed "α)" markers with nested "•" |
| m20 | Annual-leave request form, filled in | tr | 1 | medium | 5/4/3/4 | Two-sided header box as furniture; full-grid key/value table of two pairs per row; table with an empty top-left header cell and an empty signature row; drawn check boxes that are not list items; typed "•" markers |
| m21 | Remote and hybrid working policy | en | 2 | medium | 8/5/3/13 | Typed upper-case roman heading numbers; boxed key/value control panel; borderless definitions table; three-level typed list "4.1", "(a)", "(i)" with hanging indents; table with tinted header and rules between rows; CSS disc bullets |
| m22 | Rules of a photography competition | pl | 2 | medium | 8/5/2/17 | Centred "§ n." headings; Polish legal hierarchy of typed markers "1.", "1)", "a)"; full-grid zebra table with a value spanning two columns; boxed key/value schedule with dotted rules; Polish quotation marks |
| m23 | Building announcement (water-supply and lift shutdown) | th | 1 | hard | 1/4/1/5 | No spaces between words, spaces kept between phrases, wrapped lines join with no space, no final punctuation; Thai-digit page number and markers "๑."; Thai-letter markers "ก."; Buddhist-era years; two-line title; row-spanning cells |
| m24 | Housing co-operative newsletter | en | 2 | hard | 6/6/4/8 | Masthead title; tinted left sidebar read before a two-column main area; box titles that are not headings; CSS list with string en-dash markers; forced page break; side-by-side boxes each holding a key/value table |
