# native on golden_v4

Scored by `_doc_score.py`, the same function for every reader. Total 0.179 s.

| doc | difficulty | text | order | headings | tables | lists | furniture | code | s |
|---|---|---|---|---|---|---|---|---|---|
| g01 | justified serif text in a narrow column; several soft-hyphenated (&shy;) long words break at line ends | 1.00 | 1.00 | 1.00 | -- | -- | -- | -- | 0.031 |
| g02 | soft-hyphenated words that do NOT break (they stay whole inside a line) in a sans text, plus fi/fl/ffi ligature words | 1.00 | 1.00 | 1.00 | -- | -- | -- | -- | 0.007 |
| g03 | Arabic right-to-left page; one sentence holds a Latin acronym in parentheses, a year and a percentage | 1.00 | 1.00 | 0.50 | -- | -- | -- | -- | 0.007 |
| g04 | Hebrew right-to-left page; brackets [ ] around a Latin word; a sentence that ends with a quotation in guillemets | 0.80 | 1.00 | 1.00 | -- | -- | -- | -- | 0.006 |
| g05 | four lists whose markers are typed in the text: arrow, bullet character, check mark, hyphen-minus | 1.00 | 1.00 | 1.00 | -- | 0.75 | -- | -- | 0.008 |
| g06 | numbered list typed as '1)', '2)' with a nested list typed in roman numerals 'i.', 'ii.', 'iii.' | 1.00 | 1.00 | 1.00 | -- | 0.71 | -- | -- | 0.008 |
| g07 | three-column justified prose; a soft-hyphenated word breaks at the bottom of column 1 and another at the bottom of column 2 | 1.00 | 1.00 | 1.00 | -- | -- | -- | -- | 0.022 |
| g08 | bordered table with a merged header (colspan) and a merged first column (rowspan); caption below the table | 1.00 | 1.00 | 1.00 | 1.00 | -- | -- | -- | 0.020 |
| g09 | borderless table with right-aligned numbers and a bold totals row | 1.00 | 1.00 | 1.00 | 0.20 | -- | -- | -- | 0.006 |
| g10 | two pages: running header with the chapter title, 'Page 1' / 'Page 2' footers, a table continued on page 2 with its header repeated | 1.00 | 1.00 | 1.00 | 0.60 | -- | 1.00 | -- | 0.013 |
| g11 | headings at four levels; h3 and h4 have the same size and differ only by bold versus italic | 1.00 | 1.00 | 0.75 | -- | -- | -- | -- | 0.010 |
| g12 | a pull quote in larger italic type floated to the right of the body text | 1.00 | 1.00 | 1.00 | -- | -- | -- | -- | 0.007 |
| g13 | a sentence set in small caps (font-variant: small-caps) and a letter-spaced heading | 1.00 | 1.00 | 0.50 | -- | -- | -- | -- | 0.005 |
| g14 | a code listing with line numbers in a separate gutter column, and a shell transcript | 1.00 | 1.00 | 1.00 | -- | -- | -- | 0.50 | 0.011 |
| g15 | French text: ligatures œ and æ, guillemets « », non-breaking spaces before : ; ? ! and inside guillemets | 1.00 | 1.00 | 1.00 | -- | -- | -- | -- | 0.009 |
| g16 | mixed layout: centred title, a two-column section, a full-width table, then a second two-column section | 0.80 | 1.00 | 1.00 | 1.00 | -- | -- | -- | 0.009 |
| **macro** | | 0.97 | 1.00 | 0.92 | 0.70 | 0.73 | 1.00 | 0.50 | |
