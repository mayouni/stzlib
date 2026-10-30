# golden_v36

An independent golden test set of 24 realistic PDF documents (z01..z24) with known expected structure, for testing document readers (Docling and Softanza's native PDF reader) on files that did NOT come from a browser. It is the third NON-Chrome set, written by a different author from golden_v34 and golden_v35. No PDF here was made with Chrome, Edge or any browser.

Each document has three files: `<id>.pdf`, `<id>.expected.json` (keys: id, difficulty, pages, title, headings, key_sentences, tables, list_items, furniture, languages, code, notes) and `<id>.src.txt` (one line: producer and approach).

## How it was made

Every document is drawn by a generator script kept outside the repository; the expected JSON is built from the same data structures that draw the text, so the expected text is the text drawn. Producers: 7 ReportLab 5.0.1 Platypus, 4 ReportLab canvas, 5 PyMuPDF 1.28.2 (Story HTML+CSS, insert_htmlbox, insert_text/draw_*; used only to write), 3 matplotlib 3.11.2 (fonttype 42 and 3), 5 Microsoft Print to PDF driven from PowerShell with System.Drawing.Printing. Languages: 10 English, plus German, Russian, Chinese (x2), Spanish, French, Greek, Korean, Arabic (x2), Hebrew, Thai, Hindi and Japanese. Three documents are right to left (z12, z13, z20). Every character was checked against the cmap of the font it is drawn in (fontTools; Latin-1/WinAnsi for the standard-14 documents). Page counts and font lists were taken from raw PDF bytes (/Type /Page, /Count, /BaseFont, /FontFile*).

## Independence

The author never ran, imported for reading or opened any PDF-to-text or document-conversion tool, text-extraction function, rasterizer or renderer, or any reader code or output, and did not open golden_v1..golden_v35, list the _data folder, or open the engine folder or any results file. The PDFs were never looked at after being written: **no person or program has perceived these files** (unperceived is a state, not a pass). Layout was controlled by measured string widths and fit assertions only, so overlaps or odd shapes that a viewer would show are possible. Known risks: z18 (Type 3 text, probably no ToUnicode), z12/z13/z14/z16/z20 (RTL and complex-script shaping may leave glyphs in visual order or unjoined in a text map), and the GDI files (anonymous CIDFont names).

## Documents

| id | producer | kind | lang | fonts | pages | size | main difficulties |
|---|---|---|---|---|---|---|---|
| z01 | ReportLab 5.0.1 Platypus | Electricity bill | en | Helvetica std-14 (not embedded) | 2 | 6 KB | letterhead band, kv box, rules-only table with section/total rows, zebra table split over a page with repeated header |
| z02 | ReportLab 5.0.1 Platypus | Bank loan offer | de | Times std-14 (not embedded) | 2 | 16 KB | grid tables with totals row, nested 1. / (a) list, uncompressed streams |
| z03 | ReportLab 5.0.1 Platypus | Board meeting agenda | ru | Arial embedded | 2 | 119 KB | Cyrillic, zebra table, I./II./III. and Cyrillic-letter markers, level-3 heading |
| z04 | ReportLab 5.0.1 Platypus | Product warranty card | zh | Microsoft YaHei (TTC) embedded | 2 | 143 KB | CJK wrapping, drawn check boxes, empty table cells, typed bullets |
| z05 | ReportLab 5.0.1 Platypus (multi-column Frames) | Seed catalogue page | en | Georgia embedded | 2 | 181 KB | two columns, table inside one column, drawn square bullets, three heading levels |
| z06 | ReportLab 5.0.1 Platypus | Municipal tender notice | es | Times New Roman embedded | 3 | 221 KB | 3 pages, header-rule-only tables with multi-line cells and totals, 1) / a) lists |
| z07 | ReportLab 5.0.1 Platypus | Hospital discharge summary | en | Helvetica + Courier std-14 (not embedded) | 2 | 6 KB | side-by-side tables, monospaced medication block, lab table with section rows, drawn check boxes |
| z08 | ReportLab 5.0.1 canvas | Library loan receipt | en | Courier + Helvetica std-14 (not embedded) | 1 | 6 KB | 80 mm page, borderless aligned columns, dashed drawn rules, drawn barcode |
| z09 | ReportLab 5.0.1 canvas | Bus route leaflet | fr | Helvetica std-14 (not embedded) | 2 | 4 KB | two timetables side by side, drawn circle and dash bullets, price table with header rule only |
| z10 | ReportLab 5.0.1 canvas | Award certificate with table | el | Times New Roman embedded | 2 | 147 KB | landscape, letter-spaced title, centred wrapped text, signature captions, Greek-letter list |
| z11 | ReportLab 5.0.1 canvas | Parking permit notice | ko | Malgun Gothic embedded | 2 | 75 KB | boxed form, drawn check boxes, 1./가. lists, space-wrapped Korean |
| z12 | PyMuPDF 1.28.2 Story | Vaccination record | ar | Tahoma embedded (whole font) | 2 | 1013 KB | RTL tables (first logical cell at right), Arabic-Indic digits, Arabic letter markers |
| z13 | PyMuPDF 1.28.2 insert_htmlbox | Job offer letter | he | Arial embedded (whole font) | 2 | 1123 KB | RTL Hebrew, Hebrew-letter markers, zebra tables |
| z14 | PyMuPDF 1.28.2 Story | Hotel folio | th | Leelawadee UI embedded | 2 | 374 KB | Thai shaping, no word spaces, spanned section rows, Thai numerals as markers |
| z15 | PyMuPDF 1.28.2 insert_text/draw_* | Chemical safety data sheet | en | Helvetica + Courier std-14 (not embedded) | 2 | 27 KB | hand-drawn tables of three styles, side-by-side tables, hazard check boxes, Courier block |
| z16 | PyMuPDF 1.28.2 Story | School circular | hi | Nirmala UI (from TTC) embedded | 2 | 773 KB | Devanagari conjuncts, Devanagari numerals, (क) markers, zebra table |
| z17 | matplotlib 3.11.2 PdfPages (fonttype 42) | Research poster abstract sheet | en | Segoe UI embedded TrueType | 2 | 55 KB | two columns, table in a column, typed vs drawn bullets in side-by-side boxes |
| z18 | matplotlib 3.11.2 PdfPages (fonttype 3) | Wedding programme | ja | MS Gothic as Type 3 glyph procedures | 2 | 106 KB | Type 3 text recovery, markers with no gap, drawn circle bullets |
| z19 | matplotlib 3.11.2 PdfPages (fonttype 42, uncompressed) | Physics problem sheet | en | Times New Roman + Courier New embedded TrueType | 2 | 183 KB | three-level question list, Unicode symbols, monospaced formula block |
| z20 | Microsoft Print to PDF (GDI+) | Insurance claim form | ar | Tahoma subset (anonymous CIDFont) | 2 | 156 KB | GDI RTL, boxed forms with empty cells, drawn check boxes, totals row |
| z21 | Microsoft Print to PDF (GDI+) | Job offer letter | en | Times New Roman subset (anonymous CIDFont) | 2 | 279 KB | plain-weight headings, rules / header-rule tables, empty boxed form, drawn check boxes |
| z22 | Microsoft Print to PDF (GDI+) | Hotel folio | en | Segoe UI subset (anonymous CIDFont) | 2 | 225 KB | table split over two pages with hand-repeated header, section and totals rows |
| z23 | Microsoft Print to PDF (GDI+) | CV / resume | zh | Microsoft YaHei subset (anonymous CIDFont) | 2 | 199 KB | boxed kv grid, drawn circle bullets, plain-weight headings |
| z24 | Microsoft Print to PDF (GDI+) | School report card | en | Calibri subset (anonymous CIDFont) | 2 | 503 KB | section rows with multi-line cells, two side-by-side tables, roman list, empty signature form |

Key/value tables have no header row; the first expected row is the first pair. Section rows repeat their text in every grid cell. Right-to-left tables list cells in logical order, first cell at the right of the page.
