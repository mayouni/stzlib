# golden_v3 -- an independent golden set for PDF document readers

Fourteen small PDF documents (`f01` .. `f14`) with a known expected structure, written to
score document readers (Docling and the Softanza native PDF reader) on one or two layout
difficulties each.

Each document is three files:

| file | what it is |
|---|---|
| `fNN.html` | the source, the single place the content was written |
| `fNN.pdf` | the source printed to PDF by headless Chrome |
| `fNN.expected.json` | what a correct reader should return, written from the source |

## How it was made

1. One Python generator (kept outside the repository) holds every text, table and list
   once, and writes both `fNN.html` and `fNN.expected.json` from that same data, so the
   expectation cannot drift from the source. A soft hyphen is written `&shy;` in the HTML
   and removed from the expectation.
2. Each HTML file was printed with
   `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf=<abs>\fNN.pdf file:///<abs>/fNN.html`.
   Most pages use `@page { size: A4; margin: 2cm }`. The two documents with page furniture
   (f04, f05) use `@page { margin: 0 }` and explicit page sections in which the running
   header, footer and folio are absolutely positioned blocks.
3. Page counts were checked from the raw PDF bytes (`/Type /Page` objects and `/Count`),
   which is not a text extractor. f03 and f05 have 2 pages; all others have 1.
4. The column-break hyphen in f09 was made deterministic: the body is Courier New 10pt in
   two fixed-height columns whose width is a whole number of characters, the generator
   computed the line breaks in advance, and a SCREEN render of the same HTML (a Chrome
   screenshot, not the PDF) confirmed them. The f10 breaks were read from the same kind of
   screen render.

## Independence

The author of this set never ran, imported or opened any PDF-to-text or
document-conversion tool, any reader's code or any reader's output, and never looked at
golden_v1 or golden_v2. Every expectation was written from what the author put into the
source HTML. The content is invented: no real persons or companies are named.

## The expectation format

```
id, difficulty, pages, title (or null),
headings      [ {level, text} ]  document order, the title first at level 1
key_sentences 4..10 full BODY sentences, exactly as in the HTML, in reading order
tables        [ {caption, rows} ] header row first; a merged cell repeats its text in
              every grid cell it covers; a table continued across pages is ONE table
              with the header row once
list_items    [ {level, text} ]  without a generated marker, WITH a marker typed in the text
furniture     running headers, footers, folios -- text that is not body
languages, code (exact text, lines joined with \n), notes
```

Text matches the visible rendered text; whitespace runs collapse to one space, except in
`code`. A word broken across lines or columns by a soft hyphen is given WHOLE. RTL text
(f07, f08) is given in logical order. Read each file's `notes` before scoring it.

## The documents

| id | pages | difficulty | body font |
|---|---|---|---|
| f01 | 1 | borderless table, columns aligned only by padding, light grey header background, 6 rows x 4 columns | Verdana |
| f02 | 1 | borderless table with zebra-striped rows and a right-aligned numeric column | Georgia |
| f03 | 2 | bordered table (56 data rows) running over two pages, header row repeated on page 2 | Calibri |
| f04 | 1 | letter with a small grey running header line at the very top and a footer reference line at the very bottom | Times New Roman |
| f05 | 2 | report with bottom-centre folios "- 1 -" / "- 2 -" and a running header carrying the title | Trebuchet MS |
| f06 | 1 | numbered section headings typed in the text (bold, larger), then a genuine generated numbered list | Segoe UI |
| f07 | 1 | Arabic RTL page; a sentence embeds a number, a Latin brand name and a percentage, ending with a period | Segoe UI |
| f08 | 1 | Hebrew RTL page, two paragraphs, the second ending with a Latin abbreviation in parentheses | Arial |
| f09 | 1 | two columns; a long word is soft-hyphenated exactly at the foot of column 1 and continues in column 2 | Courier New |
| f10 | 1 | single narrow (50 mm) column with words broken at line ends by soft hyphens | Georgia |
| f11 | 1 | two-column scientific page with full-width title, author line and abstract above the columns | Times New Roman |
| f12 | 1 | square-bullet list (with a nested level) and a list whose arrow markers are typed in the text | Tahoma |
| f13 | 1 | bordered table with rowspan and colspan cells inside the left column of a two-column layout | Arial |
| f14 | 1 | ALL-CAPS bold headings at body size, two code blocks, and a blockquote | Palatino Linotype |
