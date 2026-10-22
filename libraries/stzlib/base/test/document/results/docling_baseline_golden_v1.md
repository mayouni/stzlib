# Docling baseline on golden_v1

Tool: docling 2.141.0, OCR off, CPU. Total 239.2 s.

| doc | difficulty | text | order | headings | tables | lists | furniture | code | s |
|---|---|---|---|---|---|---|---|---|---|
| d01 | plain multi-paragraph letter | 1.00 | 1.00 | -- | -- | -- | -- | -- | 83.17 |
| d02 | heading hierarchy (h1, h2, h3), 2 pages | 1.00 | 1.00 | 1.00 | -- | -- | -- | -- | 24.35 |
| d03 | simple table | 1.00 | 1.00 | 1.00 | 1.00 | -- | -- | -- | 21.56 |
| d04 | table with merged cells (rowspan and colspan) and a caption | 1.00 | 1.00 | 1.00 | 0.86 | -- | -- | -- | 20.75 |
| d05 | two-column article layout (reading order) | 1.00 | 1.00 | 1.00 | -- | -- | -- | -- | 8.39 |
| d06 | bulleted and numbered lists, one nested level | 1.00 | 1.00 | 1.00 | -- | 1.00 | -- | -- | 11.05 |
| d07 | repeated page header and footer with page numbers (furniture) | 1.00 | 1.00 | 1.00 | -- | -- | 1.00 | -- | 24.32 |
| d08 | French accents and an Arabic right-to-left paragraph | 0.75 | 1.00 | 1.00 | -- | -- | -- | -- | 9.39 |
| d09 | code block (monospace) and inline formulas written as text | 1.00 | 1.00 | 1.00 | -- | -- | -- | 0.00 | 14.51 |
| d10 | mixed: heading, paragraph, small table, list, footnote | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | -- | -- | 21.69 |
| **macro** | | 0.97 | 1.00 | 1.00 | 0.95 | 1.00 | 1.00 | 0.00 | |
