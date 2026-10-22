# Golden document set v1

Ten small PDF documents with a known expected structure, written to score
document-conversion tools (Docling now, a native Softanza PDF reader later).
Each document has one main difficulty.

Each document `dNN` has three files:

- `dNN.html`: the source, written by hand-authored data (invented content: no
  real persons or companies).
- `dNN.pdf`: the PDF rendered from that HTML.
- `dNN.expected.json`: what a correct reader should recover. It was written
  from the text put INTO the HTML, never from anything read back out of the
  PDF.

## Independence

The author of this set never ran, installed, imported or looked at the output
of any PDF-to-text or document-conversion tool (no Docling, pdfminer, pypdf,
pdftotext or OCR) while making it. The only checks made on the PDFs were:
the file exists and is not empty, and the page count, read by counting
`/Type /Page` objects and the `/Count` of the `/Pages` node in the raw bytes.
The layouts of d05 and d08 were looked at as browser screenshots of the HTML.
An expected value that disagrees with a reader is therefore a disagreement
with the source, not with another extractor.

## How it was made

- Date: 2026-10-22.
- Renderer: Google Chrome headless, version 155.0.8059.80 (read from the
  `chrome.exe` file properties; `chrome.exe --version` prints nothing on
  Windows).
- Command, per document:
  `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf="<abs>\dNN.pdf" "file:///<abs>/dNN.html"`
- Page set by CSS `@page { size: A4; margin: 2cm }`. Body font Arial 11pt,
  left aligned, no hyphenation. Code in Consolas / Courier New.

## expected.json

Keys: `id`, `difficulty`, `pages`, `title`, `headings` (level + text, in
order), `key_sentences` (4 to 10 exact body sentences in reading order),
`tables` (caption + grid rows, header row(s) first; a merged cell is repeated
in every grid cell it spans), `list_items` (level + text, without the bullet
or number), `furniture` (running header/footer text that is not body),
`languages`, `code` (exact code text, lines joined with `\n`), `notes`
(what a scorer must know about this document).

Text matches the rendered text exactly after collapsing runs of whitespace to
one space (except `code`, where line breaks and leading spaces are exact). All
apostrophes and quotes are ASCII. UTF-8, NFC.

## The documents

| id  | pages | difficulty |
|-----|-------|------------|
| d01 | 1 | plain multi-paragraph letter |
| d02 | 2 | heading hierarchy (h1, h2, h3), forced page break |
| d03 | 1 | simple table: 1 header row + 6 rows x 4 columns |
| d04 | 1 | table with merged cells (rowspan and colspan) and a caption |
| d05 | 1 | two-column article (CSS columns): reading order is column 1 then column 2 |
| d06 | 1 | bulleted and numbered lists, one nested level each |
| d07 | 3 | repeated running header and "Page N of 3" footer: furniture, not body |
| d08 | 1 | French with accents, plus an Arabic right-to-left paragraph |
| d09 | 1 | monospace code block, and formulas written as plain text (E = mc^2, m1/m2) |
| d10 | 1 | mixed: heading, paragraphs, small captioned table, list, footnote |
