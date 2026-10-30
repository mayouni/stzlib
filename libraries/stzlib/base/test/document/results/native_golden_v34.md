# native on golden_v34

Scored by `_doc_score.py`, the same function for every reader. Total 0.109 s.

| doc | difficulty | text | order | headings | tables | lists | furniture | code | s |
|---|---|---|---|---|---|---|---|---|---|
| x01 | medium: drawn letterhead, borderless key/value block, grid table with wrapped and two-line cells and spanned totals rows, bullets | 1.00 | 1.00 | 1.00 | 1.00 | 0.00 | 0.80 | -- | 0.002 |
| x02 | hard: 3 pages, zebra table, table continued across pages with section rows, nested lists with typed markers, monospaced formula block, running header and page x of y | 1.00 | 1.00 | 1.00 | 1.00 | 0.67 | 1.00 | 1.00 | 0.005 |
| x03 | medium: French, embedded TrueType, key/value block, header-rule table with wrapped cells, zebra table, a) b) lists, 1) with (i) nesting | 1.00 | 1.00 | 1.00 | 0.82 | 1.00 | 1.00 | -- | 0.005 |
| x04 | hard: German, standard-14, table continued across pages with repeated header, zebra rows, section rows, Courier article codes, two-line cells | 1.00 | 1.00 | 1.00 | 1.00 | 0.00 | 1.00 | -- | 0.003 |
| x05 | medium: Spanish, standard-14 Times, attendance table, agenda 1) list, multi-line cells in an action table, signature block | 1.00 | 1.00 | 1.00 | 0.80 | 1.00 | 0.60 | -- | 0.002 |
| x06 | medium: Russian Cyrillic, embedded Arial, grid table with totals, 1. and Cyrillic-letter lists, multi-page | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | -- | 0.002 |
| x07 | hard: data sheet, side-by-side boxes read box by box, grid + header-rule tables, Courier code block, many symbols in cells | 1.00 | 1.00 | 1.00 | 1.00 | 0.38 | 1.00 | 1.00 | 0.002 |
| x08 | hard: Greek, landscape, grid timetable with a cell spanning two rows, two-line cells, Greek-letter list, page break between sections | 1.00 | 1.00 | 1.00 | 0.94 | 1.00 | 1.00 | -- | 0.002 |
| x09 | hard: 3 pages, embedded Georgia, headings to level 3, wrapped table across pages, (a)/(i)/1) lists, Courier command, footer with page x of y | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.004 |
| x10 | hard: low-level canvas, full-grid transaction table continued on page 2 with repeated header, key/value summary, bullets drawn as circles, footnote marker | 1.00 | 1.00 | 1.00 | 0.78 | 1.00 | 0.71 | -- | 0.005 |
| x11 | hard: Japanese, embedded MS Gothic (TTC subfont), drawn grid table with spanned totals, typed ・ and （1） markers, stamp box | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.17 | -- | 0.002 |
| x12 | medium: form with boxed fields, empty values, drawn check boxes (no text markers), Times standard-14, declaration text, signature lines | 1.00 | 1.00 | 1.00 | 0.50 | 0.00 | 0.44 | -- | 0.001 |
| x13 | hard: Chinese, SimSun and YaHei embedded, drawn grid table over two pages with repeated header, spanned totals, numbered lists | 1.00 | 1.00 | 1.00 | 0.92 | 1.00 | 1.00 | -- | 0.002 |
| x14 | hard: two-column paper, full-width title block and abstract, header-rule table inside a column, typed [n] references, monospaced block, equation line | 1.00 | 1.00 | 1.00 | 0.52 | 0.89 | 1.00 | 1.00 | 0.009 |
| x15 | very hard: Arabic (shaped, right-to-left), embedded Arial, RTL tables (first column at the right), Arabic-letter list, numbers inside RTL text | 1.00 | 1.00 | 1.00 | 1.00 | 0.43 | 1.00 | -- | 0.008 |
| x16 | very hard: Hebrew right-to-left, embedded Arial, RTL tables, Hebrew-letter agenda list, key/value header, signature captions | 1.00 | 1.00 | 1.00 | 0.83 | 0.43 | 0.60 | -- | 0.007 |
| x17 | hard: Korean, embedded Malgun Gothic, grid tables with spanned section rows, nested 1) / 가. lists, hyphen list, key/value block | 0.60 | 1.00 | 0.83 | 0.95 | 1.00 | 0.50 | -- | 0.018 |
| x18 | medium: Italian, standard-14 Helvetica/Times/Courier via insert_text, rules between rows, section rows, table continued over a page break, 1) and hyphen lists | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.83 | -- | 0.004 |
| x19 | hard: matplotlib canvas, TrueType (Type 42) fonts, grid + zebra table, side-by-side boxes, monospaced calculation block, single dense page | 1.00 | 1.00 | 1.00 | 0.85 | 1.00 | 1.00 | 1.00 | 0.003 |
| x20 | hard: Portuguese, matplotlib Type 3 fonts (glyph outlines as procedures), table continued across pages, borderless financial table, a) i. 1. lists | 1.00 | 1.00 | 1.00 | 0.63 | 0.88 | 1.00 | -- | 0.003 |
| x21 | very hard: Arabic invoice from the GDI print path, right-to-left grid table continued over a page break, boxes side by side (right first), spanned totals, lettered list | 1.00 | 0.75 | 0.60 | 1.00 | 1.00 | 1.00 | -- | 0.005 |
| x22 | medium: office-print GDI letter, letterhead, running header on page 2, grid + zebra tables, nested 1. / (a) list, two pages | 1.00 | 1.00 | 0.25 | 1.00 | 1.00 | 0.88 | -- | 0.004 |
| x23 | hard: GDI timetable with many narrow numeric columns in monospace, two grid tables, aligned borderless fares table, code-like text block, one dense page | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.75 | 0.00 | 0.006 |
| x24 | medium: Turkish with dotted/dotless i, Calibri via GDI, numbered 1. + a) nesting, program table and totals table, 2 pages | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 0.50 | -- | 0.004 |
| **macro** | | 0.98 | 0.99 | 0.94 | 0.90 | 0.78 | 0.82 | 0.83 | |
