# golden_v33 -- independent golden set of 24 realistic PDF documents

Version 33 of the golden test set for document readers (Docling and Softanza's native PDF reader).
It has 24 whole documents, `u01` .. `u24`. Each has three files:

- `uNN.html` -- the source, hand-authored through a small generator (see "How it was made");
- `uNN.pdf` -- the HTML printed by headless Chrome (`--headless=new --no-pdf-header-footer`), A4;
- `uNN.expected.json` -- the expected structure: `id, difficulty, pages, title, headings, key_sentences, tables, list_items, furniture, languages, code, notes`.

## Independence

The author of this set never ran, imported, opened or looked at any PDF-to-text or document-conversion tool,
any PDF rasterizer, any reader's code, or any reader's output, and never looked at `golden_v1` .. `golden_v32` or at any
results or memo files of the readers. The expected structure was written at the same moment as the HTML, from the same
source structures, so it does not depend on what any reader extracts. Two disclosures: (1) while looking for a scratch
folder, the first 300 bytes of an older generator file left in the shared session scratch folder were printed by mistake
(its header named an invoice document of an earlier set); nothing from it was used, and every document here was written
from scratch in a new folder. (2) Layout was checked with headless Chrome measuring the HTML in a screen render
(page boxes, overflow) and by looking at PNG screenshots of the HTML; no PDF was ever rasterized or converted.

## How it was made

- A Python generator (kept outside the repository) builds each document as explicit A4 `section.page` boxes with `@page { size: A4; margin: 0 }`,
  so that letterheads, running headers, footers and page numbers (typed in each document's own language and form) are real page furniture and every page break is deliberate.
  Tables that continue across pages are split by hand and repeat their header row visually.
- The same call that writes a heading, table, list or code block into the HTML also writes it into the expected JSON;
  key sentences are checked to occur verbatim in the HTML paragraph they come from.
- Fonts: only fonts installed on the machine (checked against `C:\Windows\Fonts` with a glyph-coverage test of every character used);
  no variable fonts; code uses Consolas.
- Each PDF was checked from raw bytes (page count from `/Type /Page` and `/Count`; `/BaseFont` names): every page count equals the expected `pages`,
  and no document used a fallback font: the embedded fonts are those listed below.
- Languages: English, German, French, Spanish, Italian, Turkish, Russian, Greek, Arabic, Hebrew, Persian, Hindi, Bengali, Thai, Japanese, Chinese (Simplified), Korean, Georgian (17; 14 documents have 2 or 3 pages).

## Conventions a scorer must know

- Typed list markers (text in the page) are included in `list_items` text, joined to the item text by one space (CJK: no space); markers drawn by CSS (a filled circle, `list-style`, CSS counters/`list-style-type`) are NOT included. Each document's `notes` says which lists are which.
- Key/value panels are tables WITHOUT a header row. Merged cells repeat their text in every covered grid cell. A table continued on the next page is one table with its header once (two-level headers keep both header rows once: u06, u12, u18, u20).
- Right-to-left tables list cells in logical order, rightmost column first. Persian text keeps ZWNJ (U+200C) inside words. Soft hyphens in the German text are not in the expected text.
- In scripts without spaces (Japanese, Chinese, Thai) a line wrapped inside a sentence joins with no space; Thai sentences contain no internal spaces by construction.
- Letterhead organisation names, address lines, running headers/footers and page-number lines are `furniture` (a repeated running header or footer line is listed once; page-number lines once per page). Subtitle/date lines under a title, address panels, salutations, signatures, equations, figure drawings and footnote text are deliberately not scored.
- Multi-column and side-by-side layouts (u01, u05, u12, u13, u18, u22, u23, u24) read box by box / column by column; each document says so in `notes`.

## Documents

| id | kind | pages | fonts embedded (PDF /BaseFont families) | main difficulties |
|---|---|---|---|---|
| u01 | Invoice with letterhead (en) | 1 | Calibri | invoice with letterhead; side-by-side panels; section rows; merged total rows; row-rules-only table; multi-line cells; typed numbered notes; CSS bullets |
| u02 | House rules, Hausordnung (de) | 2 | Cambria | German house rules, 2 pages; numbered paragraphs (1) with hanging indent; a) b) lists nested; soft hyphens in justified text; boxed key/value panel; full grid table; CSS bullets; running header/footer with German page numbers |
| u03 | University circular (ar, RTL) | 1 | SakkalMajalla | Arabic right-to-left circular; letterhead; typed Arabic-letter list with hanging indent; CSS arabic-indic numbered list; RTL table in logical order with caption; Arabic-Indic digits |
| u04 | Meeting minutes (ja) | 2 | YuGothic | Japanese meeting minutes, 2 pages; full-width typed markers （１） ① ・ without spaces; lines wrap inside sentences (no spaces); key/value panel; table continued across pages with repeated header; page numbers "- 1 -" |
| u05 | School trip notice (he, RTL) | 1 | Arial, ArialMT | Hebrew right-to-left parent notice; letterhead; typed Hebrew-letter list with hanging indent; CSS hebrew-numbered list; CSS bullets; RTL schedule table in logical order; mixed digits |
| u06 | Device configuration manual (ru) | 3 | Consolas, Georgia | Russian technical manual, 3 pages; numbered headings 1. 2.1; typed Cyrillic-letter list а) б) and decimal 1) nested; two code blocks (Consolas, Cyrillic comments); two-level header table continued across pages; small icon table; running header and "Стр. N из 3" footers |
| u07 | Corporate notice with red letterhead (zh) | 2 | MicrosoftYaHei | Chinese (Simplified) corporate notice, 2 pages; red letterhead and document number; typed 一、（一）1. markers; zebra table; page numbers "第 1 页 共 2 页"; no-space wrapping |
| u08 | Course syllabus (ko) | 1 | MalgunGothic, MalgunGothicBold | Korean course syllabus, 1 page; boxed key/value panel; typed 1) and 가. markers; zebra weekly table; page number "- 1 -"; Hangul wrapping at spaces |
| u09 | Municipal announcement (el) | 1 | PalatinoLinotype | Greek municipal announcement, 1 page; centred letterhead in a box; typed Greek-letter list α) β) with hanging indent; CSS lower-greek list; zebra event table; CSS bullets; Greek page number |
| u10 | School circular (hi) | 2 | NirmalaUI | Hindi school circular, 2 pages; Devanagari typed numerals १. and (क) markers with hanging indent; CSS devanagari list; full-grid table; page numbers in Devanagari digits |
| u11 | Tour programme and price sheet (th) | 1 | LeelawadeeUI | Thai tour programme and price sheet, 1 page; no spaces between words; typed Thai-digit numbers ๑. and Thai-letter ก. markers; price table with rules between rows only; CSS bullets |
| u12 | Call for papers (fa, RTL) | 2 | Tahoma | Persian call for papers, 2 pages; right-to-left; ZWNJ inside words; typed Persian-digit list ۱- with hanging indent; CSS persian-numbered list; two boxes side by side; row-rules table; fee table with merged header; Persian page numbers |
| u13 | Municipal bulletin in two columns (fr) | 2 | Garamond | French municipal bulletin, 2 pages, newspaper layout in two text columns (column by column reading); typed 1° and a) markers nested; borderless table; CSS bullets; running header and footer with page numbers |
| u14 | Owners' meeting minutes with works budget (es) | 2 | Candara | Spanish minutes of a residents meeting with a budget table, 2 pages; borderless table with header underline and section rows; total rows merged; table continued across pages; typed 1. and a) lists; page numbers "Página 1 de 2" |
| u15 | Weekly class timetable (tr) | 1 | Verdana | Turkish class timetable, 1 page; wide 6-column grid with rowspans (double lessons) and a merged lunch row; centred coloured cells; boxed key/value table; typed 1) notes; Turkish capital İ and ı |
| u16 | Library rules (ka) | 1 | Sylfaen | Georgian library rules, 1 page; Mkhedruli script; typed Georgian-letter list ა) ბ) with hanging indent; CSS georgian-numbered list; row-rules table; CSS bullets; Georgian page number |
| u17 | Child vaccination bulletin (bn) | 1 | NirmalaUI | Bengali health bulletin, 1 page; Bengali script with conjuncts; typed Bengali-digit list ১. ২. with hanging indent; CSS bengali-numbered list; row-rules table; Bengali page number |
| u18 | Scientific paper in two columns (en) | 3 | TimesNewRomanPS, TimesNewRomanPSMT | scientific paper, 3 pages; full-width title block; two-column body (column by column); abstract box; headings of three levels; typed (i) list; footnote; equation lines; two tables (one in a column, one spanning both columns with a two-level header); figure with caption; reference list with hanging indent |
| u19 | Software release notes (en) | 2 | Consolas, SegoeUI | software release notes, 2 pages; typed bullet and dash markers with hanging indent; three code blocks (two shell, one JSON) in Consolas; key/value version panel; partly ruled table; numbered known issues; CSS bullets; page numbers "1 / 2" |
| u20 | Annual report extract with financial statements (en) | 3 | Georgia | annual report extract, 3 pages; letterhead; income statement with two-level header, section rows, subtotal and total rows; statement of financial position continued across pages 2-3; accounting numbers in parentheses; typed (i) notes; CSS bullets; page numbers "– 2 –" |
| u21 | Terms of service (en) | 3 | TimesNewRomanPS, TimesNewRomanPSMT | legal terms of service, 3 pages; three-level typed legal numbering 1.1 / (a) / (i) with hanging indents and numbering that continues around a table; justified text; headings with typed numbers; partly ruled fee table; running header and "Page N of 3" footer |
| u22 | Product datasheet (en) | 2 | TrebuchetMS | product datasheet, 2 pages; coloured band header; three feature boxes side by side (box by box); zebra key/value spec table beside a boxed bullet list; small tables of several styles (zebra, row rules, full grid); CSS-numbered steps; ordering table; running footer |
| u23 | Conference programme (it) | 2 | CenturyGothic | Italian conference programme, 2 pages; borderless timetable with rules, section rows, merged break rows and two-line centred cells; table in a sidebar beside text; typed a) inline list and I. list; CSS bullets; page numbers "Pagina 1 di 2" |
| u24 | Tax invoice (ar, RTL) | 1 | Arial, ArialMT | Arabic tax invoice, 1 page; right-to-left; two boxes side by side (customer, invoice data: read box by box, right box first); items table with Arabic-Indic digits, merged total rows; typed Arabic-Indic numbered notes; CSS bullets |
