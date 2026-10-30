# native on golden_v36

Scored by `_doc_score.py`, the same function for every reader. Total 0.075 s.

| doc | difficulty | text | order | headings | tables | lists | furniture | code | s |
|---|---|---|---|---|---|---|---|---|---|
| z01 | medium: letterhead, key/value box, rules-only table with section rows and totals, zebra table across a page break with repeated header, running header, page x of y | 1.00 | 1.00 | 1.00 | 0.76 | 1.00 | 0.83 | -- | 0.003 |
| z02 | medium: German, Times standard-14, full grid tables, nested (a) lists, totals row, numbered headings, no page compression | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.83 | -- | 0.001 |
| z03 | medium: Cyrillic, embedded Arial, zebra table, roman and Cyrillic-letter nested list, totals row, third-level heading | 1.00 | 1.00 | 1.00 | 1.00 | 0.89 | 0.60 | -- | 0.003 |
| z04 | medium: Chinese embedded YaHei (TTC), CJK wrapping, kv grid of four columns, drawn check boxes, empty table cells, typed bullet glyph and numerals | 1.00 | 1.00 | 0.86 | 0.78 | 1.00 | 1.00 | -- | 0.002 |
| z05 | hard: two-column pages, three heading levels, table inside one column, drawn square bullets, band header, embedded Georgia | 1.00 | 1.00 | 1.00 | 1.00 | 0.00 | 1.00 | -- | 0.004 |
| z06 | hard: Spanish, three pages, header-rule-only tables with multi-line cells continued across pages with repeated header and totals, nested 1) a) lists, embedded Times New Roman | 1.00 | 1.00 | 1.00 | 0.16 | 0.50 | 0.67 | -- | 0.006 |
| z07 | hard: two pages, key/value form, two tables side by side, monospaced medication block, drawn check boxes, lab table with section rows across a page break, dash and numeric lists | 1.00 | 1.00 | 1.00 | 0.88 | 1.00 | 0.80 | 1.00 | 0.003 |
| z08 | medium: narrow 80 mm receipt page, monospaced Courier, borderless aligned columns drawn with drawString, dashed drawn separators, hyphen list with hanging indent, drawn barcode | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.17 | -- | 0.002 |
| z09 | medium: French, two timetables side by side, drawn circle bullets and drawn dash bullets, band header, rule-only price table drawn as aligned columns | 1.00 | 1.00 | 0.71 | 0.81 | 1.00 | 0.83 | -- | 0.002 |
| z10 | hard: Greek, landscape certificate with letter-spaced title, centred wrapped text, small table drawn with lines, signature captions, second page with bare columns and Greek-letter list | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.86 | -- | 0.002 |
| z11 | hard: Korean, embedded Malgun Gothic, word-wrapped lines joined with spaces, nested 1./가. lists, grid table, boxed form with drawn check boxes, 2 pages | 1.00 | 1.00 | 1.00 | 0.65 | 0.73 | 0.80 | -- | 0.002 |
| z12 | hard: Arabic right-to-left through MuPDF HTML (shaping, bidi), Arabic-Indic digits, tables whose first logical column sits on the right, Arabic lettered list, two pages | 1.00 | 1.00 | 0.83 | 0.04 | 0.33 | 1.00 | -- | 0.007 |
| z13 | hard: Hebrew right-to-left through insert_htmlbox, Arial, Hebrew-letter list markers, zebra key/value table, hyphen list, two pages each a separate htmlbox | 1.00 | 1.00 | 0.83 | 0.00 | 0.22 | 1.00 | -- | 0.007 |
| z14 | hard: Thai (no spaces between words, stacked tone marks), HarfBuzz-shaped, Thai numerals and letters as list markers, spanned section rows, totals rows with an empty date cell | 0.00 | -- | 0.00 | 0.36 | 0.00 | 1.00 | -- | 0.004 |
| z15 | hard: positioned insert_text lines, Helvetica base-14 not embedded, Courier block, boxed hazard check list with drawn boxes, tables drawn with draw_rect/draw_line (grid, rules, zebra), two tables side by side, 2 pages | 1.00 | 1.00 | 0.90 | 1.00 | 1.00 | 0.80 | 0.00 | 0.005 |
| z16 | hard: Devanagari shaped by HarfBuzz (conjuncts, matras), Devanagari numerals and (क) list markers, zebra table, daṇḍa sentence ends, Nirmala UI from a TTC, two pages | 0.00 | -- | 0.00 | 0.17 | 0.00 | 1.00 | -- | 0.004 |
| z17 | hard: matplotlib fig.text lines, two text columns, table inside one column, side-by-side boxes (typed vs drawn bullets), kv grid, wrapped hanging-indent references | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.80 | -- | 0.003 |
| z18 | hard: Japanese in a Type 3 font (MS Gothic from a TTC), no spaces between words, '一、' typed markers with no gap, '・' bullets, drawn circle bullets, two pages | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.80 | -- | 0.002 |
| z19 | medium: matplotlib text lines in Times New Roman (fonttype 42), uncompressed, Unicode symbols (degree, superscript two, Greek), monospaced formula block, three-level question list (1. (a) (i)), data table | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.002 |
| z20 | hard: Arabic right-to-left through GDI+ DrawString (StringFormat DirectionRightToLeft), Tahoma, plain-weight headings, boxed form with empty cells, drawn check boxes, Arabic-Indic numerals, totals row | 1.00 | 1.00 | 1.00 | 0.50 | 0.50 | 0.80 | -- | 0.003 |
| z21 | medium: GDI Times New Roman with plain-weight headings only slightly larger than body, key/value rules table, header-rule-only table, hyphen list, 1./(a) nested list, drawn check boxes and empty boxed form | 1.00 | 1.00 | 1.00 | 0.87 | 0.70 | 0.80 | -- | 0.002 |
| z22 | hard: GDI Segoe UI, band letterhead, boxed key/value form, long charges table split across two pages with the header repeated by hand, spanned section rows, totals rows, hyphen list | 1.00 | 1.00 | 0.75 | 0.91 | 1.00 | 0.80 | -- | 0.002 |
| z23 | medium: Chinese CV through GDI+ (Microsoft YaHei), plain-weight headings, boxed form grid with labels, header-rule table, drawn circle bullets, typed numerals and hyphens, CJK line breaks, two pages | 0.50 | -- | 0.88 | 1.00 | 0.82 | 1.00 | -- | 0.002 |
| z24 | hard: GDI Calibri, key/value boxed form, subject grid with section rows and multi-line comment cells, two small tables side by side, roman-numeral list, hyphen list, empty signature form, plain-weight headings | 1.00 | 1.00 | 1.00 | 0.90 | 0.88 | 1.00 | -- | 0.003 |
| **macro** | | 0.90 | 1.00 | 0.86 | 0.74 | 0.73 | 0.84 | 0.67 | |
