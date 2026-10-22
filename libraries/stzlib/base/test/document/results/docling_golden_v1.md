# docling on golden_v1

Scored by `_doc_score.py`, the same function for every reader. Total 31.55 s.

| doc | difficulty | text | order | headings | tables | lists | furniture | code | s |
|---|---|---|---|---|---|---|---|---|---|
| d01 | plain multi-paragraph letter | 1.00 | 1.00 | -- | -- | -- | -- | -- | 15.913 |
| d02 | heading hierarchy (h1, h2, h3), 2 pages | 1.00 | 1.00 | 1.00 | -- | -- | -- | -- | 1.732 |
| d03 | simple table | 1.00 | 1.00 | 1.00 | 1.00 | -- | -- | -- | 2.607 |
| d04 | table with merged cells (rowspan and colspan) and a caption | 1.00 | 1.00 | 1.00 | 0.86 | -- | -- | -- | 2.601 |
| d05 | two-column article layout (reading order) | 1.00 | 1.00 | 1.00 | -- | -- | -- | -- | 1.143 |
| d06 | bulleted and numbered lists, one nested level | 1.00 | 1.00 | 1.00 | -- | 1.00 | -- | -- | 1.104 |
| d07 | repeated page header and footer with page numbers (furniture) | 1.00 | 1.00 | 1.00 | -- | -- | 1.00 | -- | 2.832 |
| d08 | French accents and an Arabic right-to-left paragraph | 0.75 | 1.00 | 1.00 | -- | -- | -- | -- | 0.967 |
| d09 | code block (monospace) and inline formulas written as text | 1.00 | 1.00 | 1.00 | -- | -- | -- | 0.00 | 1.034 |
| d10 | mixed: heading, paragraph, small table, list, footnote | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | -- | -- | 1.617 |
| **macro** | | 0.97 | 1.00 | 1.00 | 0.95 | 1.00 | 1.00 | 0.00 | |
