# golden_v2 -- independent golden set for PDF document readers

Twelve PDF documents with a known, hand-declared expected structure, made to score
document readers (Docling, and Softanza's native PDF reader). Version 2 is harder and
more varied than a plain web page: each document carries one or two deliberate
difficulties (borderless tables, multi-column flow, floats, page-spanning tables,
right-to-left text, footnotes, forms, bold-only headings, lettered lists,
hyphenation, landscape pages, code).

## How it was made

1. A Python generator (kept outside the repository) wrote each `eNN.html` source and,
   from the SAME strings, its `eNN.expected.json`. Every expected text was written by
   the author from what was put into the source -- never read back from a PDF.
2. Each HTML was printed to PDF with headless Chrome, no browser header/footer:
   `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf=<pdf> file:///<html>`
   with `@page { size: A4; margin: 2cm }` (A4 landscape for e11).
3. Page counts were checked from the raw PDF bytes (`/Type /Page` objects and the
   `/Count` of the page tree), and the MediaBox for orientation. That is not an
   extractor.
4. Layout was checked by eye on Chrome screenshots of the HTML sources at the print
   content width (170 mm portrait, 257 mm landscape), and the e10 line break by a
   layout measurement (`getClientRects`) on a scratch copy of the source.

**Independence.** The author of this set never ran, imported or opened any PDF-to-text
or document-conversion tool, any reader's code, or any reader's output, and never saw
golden_v1. Expectations come only from the sources.

## Conventions (all documents)

- `title` is the main title; it is ALSO the first entry of `headings`, at level 1.
- `headings` are in intended reading order (see e03, where that differs from source order).
- `key_sentences`: 4 to 10 full sentences of body text, exactly as in the source, in
  reading order. They may be a subset of the body. Sentences that carry a footnote marker
  or an inline formula are left out (e06). Whitespace runs compare as one space.
- `tables`: header row(s) first; a merged cell's text is repeated in every grid cell it
  covers (e10); a table continued across pages is ONE table with its header row once (e04).
- `list_items`: text without the marker; `level` 0 is top level.
- `furniture`: running header/footer text that is not body.
- `code`: exact lines joined with `\n`; tabs are kept as `\t` (e12).
- `notes`: what a scorer must know for that document.

## The documents

| id  | pages | language | difficulty |
|-----|-------|----------|------------|
| e01 | 1 | en | 5 x 3 table with no borders or rules; columns aligned by padding only; header row not bold |
| e02 | 1 | en | three-column newsletter (CSS columns) with the title spanning all columns |
| e03 | 1 | en | sidebar box floated right beside the body; intended order: main text, then sidebar |
| e04 | 2 | en | long bordered table (44 rows) continuing onto page 2 with its header row repeated |
| e05 | 1 | he | right-to-left Hebrew with numbers and a Latin product name inside sentences |
| e06 | 1 | en | scientific page: serif, justified, superscript footnote markers, inline formula, running header and folio |
| e07 | 1 | en | form: label/value pairs in two side-by-side columns, plus a drawn signature line |
| e08 | 1 | en | headings marked by bold only, same size as body, one in ALL CAPS, no heading tags |
| e09 | 1 | fr | lettered list a) b) c) d) with nested dash sub-lists |
| e10 | 1 | de | umlauts and ß, a compound word hyphenated across a line (and column) break, table with rowspan/colspan header |
| e11 | 1 | en | A4 landscape page with two tables side by side |
| e12 | 1 | en | tab-indented code block, shell transcript, quotation block |

Each document is `eNN.html` (source), `eNN.pdf` (rendered) and `eNN.expected.json`.
All content is invented; no real persons or companies.
