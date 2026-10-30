# golden_v35: independent golden set, second NON-Chrome set

24 realistic one-to-three page documents (`y01` .. `y24`), each with `<id>.pdf`, `<id>.expected.json`
(the exact schema of the task: id, difficulty, pages, title, headings, key_sentences, tables, list_items,
furniture, languages, code, notes) and a one-line `<id>.src.txt` naming producer and approach.

This is the second set made without Chrome, Edge or any browser, by a different author from `golden_v34`.
Its purpose is to test document readers (Docling and Softanza's native PDF reader) on PDFs from producers that
real files come from other than a browser: ReportLab (Platypus and the low-level canvas), PyMuPDF/MuPDF
(`Story` HTML+CSS, writing only), matplotlib (`PdfPages`, Type 3 and TrueType text) and the Windows
"Microsoft Print to PDF" driver fed by GDI+ `DrawString` from PowerShell.

## How it was made

* One generator script per document (kept outside the repository, in a scratch folder). Every script builds the
  drawn content and the expected structure from the SAME data lists, so the expected text is the text that was
  drawn. Tables, key sentences, list items, headings, furniture lines and code blocks are recorded at the moment
  they are drawn, not typed a second time.
* Glyph coverage was checked with fontTools `cmap` for every TrueType font used (and WinAnsi encodability for
  the standard-14 documents) before the PDF was accepted.
* Page counts and the font report in each `notes` field come from the raw PDF bytes only: `/Type /Page`
  and `/Count` (object streams inflated), and `/FontName` + `/FontFile*` descriptors versus font dictionaries
  without a descriptor (standard-14, not embedded) and `/Subtype /Type3`. `validate.py` (not in the repository)
  re-checked all 24 files: schema keys, page count equal to the raw count, 4 to 10 key sentences, NFC, collapsed
  whitespace, rectangular tables, first heading equal to the title.
* Table splits across pages and the repeated header rows were confirmed from the generators' own layout
  traces (ReportLab `afterFlowable`, the canvas layouter's page-break log), not from rendering.

## Honest limits (read before scoring)

* The author never ran a text extractor, a converter or a renderer on these files and never looked at them
  rendered: no PDF was rasterised or viewed. Layout (overlaps, line fits, exact glyph positions) was controlled
  by arithmetic from font metrics, so a geometry defect that only an eye would catch can exist. In particular the
  right-to-left documents (y10, y11, y24) and the Devanagari/Thai documents (y16, y17) rely on the shaping done
  by GDI+ and by MuPDF; their shaping was NOT verified by looking. State of perception: UNPERCEIVED.
* The author did not open or read `golden_v1` .. `golden_v34`, any reader's code or output, any `*.tsv`/results
  file, the scripts and memo named in the task, or anything under `libraries\stzlib\engine`. Two incidental
  contacts, disclosed: a directory listing of `_data` printed the last three folder names (names only), and
  PyMuPDF `page.get_fonts()` was called once on `y16.pdf` to list font names (no text was read).
  PyMuPDF was otherwise used only to write: Story/DocumentWriter, `insert_htmlbox`, `draw_line`, `draw_rect`,
  and a save with garbage collection.
* The Microsoft Print to PDF driver names every embedded font `CIDFont+F1`, `F2`, ...; the family used is given in
  each `notes` field.
* No real persons or companies appear; all names, numbers and addresses are invented.

## The documents

Fonts: **E** = embedded (TrueType subset or whole font), **S** = standard-14, not embedded, **T3** = Type 3.
(ReportLab always lists a default Helvetica resource on each page; it is only counted as used where noted.)

| id | producer / approach | kind (language) | fonts | pages | main difficulties |
|---|---|---|---|---|---|
| y01 | ReportLab Platypus, flate+ASCII85 | payslip (en) | S Helvetica | 1 | letterhead, header-less key/value grid, zebra table with coloured header, rules-only table, grid summary, drawn-disc bullets, plain-weight heading |
| y02 | ReportLab Platypus, flate | school report card (fr) | E Calibri | 2 | merged section rows in a grid, multi-line cells, a four-row table split by the page break, drawn check boxes, `a)` list with nested `1.` |
| y03 | ReportLab canvas, text objects line by line | GP referral letter (en) | S Times | 2 | words broken with a trailing hyphen at line ends, drawn bullets and ticks, borderless results block, grid table, letterhead + running header |
| y04 | Print to PDF (GDI+) | flight itinerary (en) | E Arial | 2 | bare aligned-column segment tables with two-line cells, layover section rows, drawn check boxes, nested `1.`/`(a)` list |
| y05 | PyMuPDF Story, 2 columns | museum guide (de) | E built-in Nimbus/Charis | 2 | column reading order, grid inside a column, typed list markers, monospaced block, boxes side by side |
| y06 | matplotlib, `pdf.fonttype 3` | recipe card, 6x9 in (en) | T3 Georgia | 1 | string-by-string Type 3 text without ToUnicode, section rows, drawn diamond bullets, two boxes |
| y07 | ReportLab Platypus, ASCII85 | water test report (ru) | E Arial, Consolas | 2 | Cyrillic, section rows, `1.`/`1)` lists, code block, signature table with rules only |
| y08 | ReportLab Platypus, CJK wrap | product manual (zh) | E Microsoft YaHei (ttc) | 2 | no spaces between words, wrapped lines join without space, circled digits, fullwidth-bracket numbering, two-cause cells |
| y09 | Print to PDF (GDI+) | health check notice (ja) | E Yu Gothic | 2 | no spaces, punctuation at line ends, merged section rows, typed middle-dot bullets, fullwidth `（1）` nesting, drawn check boxes |
| y10 | Print to PDF (GDI+, RTL) | building safety inspection (he) | E Arial, Courier New | 2 | right-to-left lines and tables (rightmost column first), Hebrew-letter nesting, LTR code block on an RTL page, drawn boxes |
| y11 | PyMuPDF Story, `dir=rtl` | insurance policy summary (ar) | E Arial | 2 | shaped Arabic, RTL tables, Arabic-Indic and Western digits, nested list, RTL boxes, header/footer in RTL |
| y12 | ReportLab Platypus, UNCOMPRESSED | lease summary (en) | S Times | 3 | `(a)(i)` nested lists, typed `[x]` items, table across pages with repeated header, letterhead on page 1 only, plain-weight sub-heading |
| y13 | ReportLab canvas, uncompressed | course syllabus (es) | S Helvetica | 2 | letter-spaced headings (Tc), calendar table across pages, drawn dashes and ticks, accents in WinAnsi |
| y14 | ReportLab canvas, TTF | school meal menu (ko) | E Malgun Gothic | 1 | weekly grid with 4-line cells, circled-digit legend, `1.`/`가.` list, two boxes with drawn bullets/ticks |
| y15 | PyMuPDF Story, serif, 2 columns | conference abstract book (en) | E Charis SIL | 2 | superscript affiliation markers, colspan cells, grid in a column, check boxes drawn from element positions |
| y16 | PyMuPDF Story | exam timetable (hi) | E Nirmala UI (+ Noto Serif Devanagari, Nimbus Mono) | 2 | Devanagari shaping, single-weight font (headings plain), Devanagari numerals/letters as markers, zebra grids |
| y17 | PyMuPDF Story | hotel guest guide (th) | E Leelawadee UI, Nimbus Mono | 1 | Thai without word spaces, stacked marks, Thai numerals, grid, boxes |
| y18 | ReportLab Platypus, TTF | software licence summary (en) | E Open Sans, Consolas, Segoe UI Symbol | 3 | two code blocks, typed checkbox glyphs, `1.` and hyphen lists, merged section rows across pages |
| y19 | matplotlib, `pdf.fonttype 42` | weather bulletin (el) | E DejaVu Sans | 1 | Greek, zebra forecast grid, drawn warning triangles, `α)` `β)` list in boxes |
| y20 | matplotlib, `pdf.fonttype 3`, compression 9 | condominium notice (pt) | T3 Trebuchet MS | 2 | meter table across pages with totals, two text columns, nested list, drawn bullets/boxes |
| y21 | ReportLab Platypus, binary flate | grant budget (en) | S Helvetica | 3 | 31-row budget table across pages, section rows, subtotals and totals, `1)` and bullet lists |
| y22 | ReportLab canvas, Courier | shipping manifest (en) | S Courier | 2 | monospaced bare-column cargo table across pages, consignee section rows, subtotals, drawn check boxes |
| y23 | Print to PDF (GDI+) | tax form guide (en) | E Times New Roman, Courier New | 2 | form with empty fields, drawn check boxes, footnote marker (sentence excluded), monospaced worked example, boxes |
| y24 | Print to PDF (GDI+, RTL) | workshop registration form (ar) | E Tahoma, Courier New | 1 | shaped Arabic via GDI+, empty form cells, drawn boxes, Arabic-Indic numerals, LTR block |

Coverage summary: English 10 (y01, y03, y04, y06, y12, y15, y18, y21, y22, y23); 14 others in 13 languages
(fr, de, es, pt, ru, el, zh, ja, ko, he, ar x2, hi, th). Producers: ReportLab Platypus 7, ReportLab canvas 4,
PyMuPDF 5, matplotlib 3, Microsoft Print to PDF 5. Documents of 2 or 3 pages: 18.
