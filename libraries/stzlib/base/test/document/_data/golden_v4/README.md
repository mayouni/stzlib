# golden_v4 -- independent golden set for PDF document readers

Sixteen one- or two-page PDF documents, each with the HTML it was printed from and a hand-written
expectation file. The set scores document readers (Docling and Softanza's native PDF reader) on
layout difficulties that a plain text dump gets wrong: soft hyphens, ligatures, right-to-left
scripts, typed list markers, merged table cells, multi-column reading order, page furniture,
heading levels without size cues, small caps, code gutters and French spacing.

## Files

For every id `g01` .. `g16`:

| file | what it is |
|---|---|
| `gNN.html` | the source: one self-contained page, Windows system fonts only, no scripts, no images |
| `gNN.pdf` | that page printed by headless Chrome |
| `gNN.expected.json` | what a correct reader must find, written from the source |

`expected.json` keys: `id`, `difficulty`, `pages`, `title`, `headings` (document order, title first at
level 1), `key_sentences` (4 to 10 body sentences exactly as visible, in reading order), `tables`
(header row first; a merged cell repeats its text in every grid cell it covers; a table continued
across pages is one table with its header once), `list_items` (with the marker when it is typed in
the text), `furniture` (running headers and footers), `languages`, `code` (exact text, lines joined
with `\n`), `notes` (what a scorer must know about that document).

Text conventions: ligatures are written as their letters (`office`); a soft-hyphenated word is written
whole, without hyphen and without U+00AD; whitespace runs collapse to one space except in `code`;
non-breaking spaces are written as ordinary spaces; Arabic and Hebrew are in logical (storage) order.

## How it was made

1. A Python generator (kept outside the repository) wrote each HTML page and, from the SAME source
   strings, its expectation file -- the sentences in `key_sentences` are the strings that were put in
   the page, with soft-hyphen marks removed.
2. Three documents make a claim about line breaking: g01 (soft hyphens DO break at line ends), g02 (they
   do NOT) and g07 (one breaks at the bottom of column 1, another at the bottom of column 2). Their column
   widths and heights were chosen by measuring Chrome's own layout of the HTML through the DOM
   (`getClientRects` on each soft-hyphenated word), and only a setting that held under a font-size jitter
   of plus and minus 0.8 percent was kept, so that a small difference between screen and print text
   metrics does not move a break. The words found are named in each document's `notes`.
3. Each page was printed with
   `chrome --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf=gNN.pdf file:///.../gNN.html`,
   CSS `@page { size: A4; margin: 2cm }` (g10 uses `margin: 0` and places its header and footers in the body).
4. Page counts were read from the raw PDF bytes (`/Type /Page` objects and `/Count`), and matched the
   intended count for all sixteen.

## Independence

The author of this set never ran, imported or opened any PDF-to-text or document-conversion tool, any PDF
rasterizer, any reader's code or any reader's output, and never looked at golden_v1, golden_v2 or golden_v3.
Every expectation was written from what was put into the source. The PDFs were never inspected beyond
their size and their page count; the layout claims above rest on Chrome's layout of the HTML, not on the PDF.

**Not yet perceived:** no person has looked at these PDFs. A reader's disagreement with an expectation
should be settled by opening the PDF, not by trusting either side.

## The documents

| id | pages | language | difficulty |
|---|---|---|---|
| g01 | 1 | en | justified serif text in a narrow column; several soft-hyphenated (&shy;) long words break at line ends |
| g02 | 1 | en | soft-hyphenated words that do NOT break (they stay whole inside a line) in a sans text, plus fi/fl/ffi ligature words |
| g03 | 1 | ar | Arabic right-to-left page; one sentence holds a Latin acronym in parentheses, a year and a percentage |
| g04 | 1 | he | Hebrew right-to-left page; brackets [ ] around a Latin word; a sentence that ends with a quotation in guillemets |
| g05 | 1 | en | four lists whose markers are typed in the text: arrow, bullet character, check mark, hyphen-minus |
| g06 | 1 | en | numbered list typed as '1)', '2)' with a nested list typed in roman numerals 'i.', 'ii.', 'iii.' |
| g07 | 1 | en | three-column justified prose; a soft-hyphenated word breaks at the bottom of column 1 and another at the bottom of column 2 |
| g08 | 1 | en | bordered table with a merged header (colspan) and a merged first column (rowspan); caption below the table |
| g09 | 1 | en | borderless table with right-aligned numbers and a bold totals row |
| g10 | 2 | en | two pages: running header with the chapter title, 'Page 1' / 'Page 2' footers, a table continued on page 2 with its header repeated |
| g11 | 1 | en | headings at four levels; h3 and h4 have the same size and differ only by bold versus italic |
| g12 | 1 | en | a pull quote in larger italic type floated to the right of the body text |
| g13 | 1 | en | a sentence set in small caps (font-variant: small-caps) and a letter-spaced heading |
| g14 | 1 | en | a code listing with line numbers in a separate gutter column, and a shell transcript |
| g15 | 1 | fr | French text: ligatures œ and æ, guillemets « », non-breaking spaces before : ; ? ! and inside guillemets |
| g16 | 1 | en | mixed layout: centred title, a two-column section, a full-width table, then a second two-column section |

Made 2026-10-22 by a Claude Code session (claude-opus-5-5) for the stzlib document-intelligence work.
