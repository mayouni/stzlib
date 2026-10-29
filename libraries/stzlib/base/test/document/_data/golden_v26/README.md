# golden_v26 -- independent golden set for document readers

Twenty-four realistic documents (k01 to k24), each given as `kNN.html` (the source), `kNN.pdf` (the rendering) and `kNN.expected.json` (the expected structure). The set scores document readers such as Docling and Softanza's native PDF reader.

## How it was made

- Every document was written by hand in one authoring session on 2026-10-29: HTML and CSS, with Python used only to assemble pages, compute totals and write the JSON. The organisations, people, addresses, account and phone numbers are invented; web and mail addresses use `.example` domains.
- Each HTML file was rendered to PDF with headless Chrome: `chrome.exe --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir=<separate scratch profile> --print-to-pdf=kNN.pdf file:///.../kNN.html`.
- Page furniture (letterheads, running headers, footers, page numbers) is placed in the page body, so the pages are explicit A4 boxes with `@page { size: A4; margin: 0 }`. k10 has no furniture and uses `@page { size: A4; margin: 2cm }`. k16 is A4 landscape.
- `expected.json` was derived from the author's own HTML source (headings from h1-h6, tables from the marked table elements with row and column spans expanded, list items, furniture lines, code blocks), plus a hand-written title, key sentences, languages and notes. Each key sentence was checked to occur, in order, in the source text.
- Checks run on the author's own files, never on a reader: (1) a layout probe of the HTML in headless Chrome (`--dump-dom` of a scratch copy carrying a measuring script) confirmed that no text falls outside its page box or overlaps furniture; (2) every character was checked against the cmap of the exact installed font face Chrome resolved for it (no variable fonts); (3) from the raw PDF bytes, the page count (`/Type /Page` and `/Count`) and the embedded `/BaseFont` names were read and compared with the fonts each document names. All 24 PDFs embed exactly the intended fonts with no fallback face. Disc, circle and square list markers are painted as shapes by Chrome.
- The author never ran any PDF-to-text extractor, document converter or rasterizer, never looked at any reader's code or output, and never saw golden_v1 to golden_v25.
- Not yet perceived: no person has looked at the rendered PDFs. That visual check is still owed.

## Conventions in expected.json

- `headings`: the title first at level 1; level = HTML heading level. Letterhead names, box titles, form labels and table header cells are never headings.
- `tables`: header row(s) first (a two-level header gives two rows); merged cells repeat their text in every grid cell they cover; empty cells are `""`; a table continued across pages is one table with its header once; right-to-left tables list cells in reading order, rightmost column first; a cell of several lines is joined with one space.
- `list_items`: a marker typed in the text is kept (`"1) ..."`, `"(ii) ..."`, `"• ..."`); a marker drawn by CSS is omitted. In the Japanese and Chinese typed lists the marker is followed directly by the text, without a space. Each document's notes say which markers are typed and which CSS draws.
- `furniture`: one entry per visible line; a repeated running header or footer is listed once; page-number lines are listed once per page.
- Whitespace runs (including non-breaking and ideographic spaces) collapse to one ASCII space, except in `code`. All text is NFC. Right-to-left text is in logical order. Chinese and Japanese lines wrapped inside a sentence join with no space.

## Documents

| id | kind | language | pages | difficulty | main difficulties |
|---|---|---|---|---|---|
| k01 | Supplier invoice (joinery workshop) | en | 1 | medium | letterhead; two address boxes side by side; boxed key/value panel; line items with section rows and spanning totals; typed "1." list; nested CSS bullets |
| k02 | Association annual activity report | fr | 2 | hard | two-column body; typed "1)" and "a)" lists with CSS dash sub-items; boxed key/value figures; zebra budget table with two-level header, section and total rows; running header; "Page N sur 2" |
| k03 | Municipal administrative decision (Bescheid) | de | 2 | hard | DIN letter layout; return-address line; key/value block beside the address; typed "1." / "a)" conditions; fee table ruled between rows with an empty cell; three-column footer; boxed note |
| k04 | University registration and fee statement | ar (RTL) | 2 | very hard | RTL; full-grid course table continued across pages with two-line cells and section rows; fee table; typed Arabic-letter list "أ-" with nested "1-"; CSS bullets; Arabic-Indic page numbers |
| k05 | Safety committee minutes | ja | 2 | hard | no-space wrapping; full-width markers "１．" "（１）" and katakana "ア"; ruled key/value table; two-level header table; typed "・" list; CSS decimal list; empty stamp-box table |
| k06 | Bank current-account statement | es | 2 | hard | zebra movements table across pages with two-line cells and empty cells; summary panel beside text; key/value table beside the bank name; typed dash list; Spanish number format |
| k07 | Software release notes | en | 2 | medium | two code blocks (shell, YAML) in Consolas; inline code; nested CSS bullets; typed "1." / "2.1" steps; table ruled under header only; zebra table; two boxes side by side |
| k08 | School circular to parents with tear-off slip | he (RTL) | 1 | hard | RTL; Hebrew-letter typed list "א." with nested "1."; schedule table; CSS bullet list beside a contact box; form fields drawn by CSS; geresh/gershayim |
| k09 | Public tender notice | zh | 2 | hard | no-space wrapping; "一、" / "（一）" headings; full-grid key/value with spanning value; row-spanning package cells; typed "1." / "（1）" list; CSS cjk-decimal list; two boxes side by side |
| k10 | Certificate of completed works (akt) | ru | 1 | medium | @page 2 cm, no furniture; approval block; full grid with two-level header and spanning total rows; typed "1." / "2.1." clauses as first-line-indent paragraphs; signature blocks side by side |
| k11 | Filled-in patient registration form | en | 1 | hard | form boxes and checkboxes drawn by CSS; handwritten-style values in Segoe Print; typed "•" bullets; medicines table with an empty row; office-use box beside consent text |
| k12 | Apartment management-fee bill | ko | 1 | medium | boxed key/value panel; fee table with section, subtotal and total rows and negative values; typed "가." / "1)" list; CSS bullets beside a captioned key/value table |
| k13 | Community newsletter | en | 2 | very hard | masthead; two-column article with pull quote; shaded sidebar; paragraph beside zebra table; three-column page with column rule; CSS numbered list; two boxes side by side; bare page numbers at outer corners |
| k14 | Municipal public-consultation notice | el | 1 | medium | authority block; key/value block; typed Greek-letter list "α)" and CSS lower-greek list; full grid with vertically centred two-line cells |
| k15 | Village-council water-supply notice | hi | 1 | hard | Devanagari; two-level header table; typed "क." list with nested "1."; key/value fee table beside a box; rupee sign; Devanagari page digits |
| k16 | Concrete cube test report (landscape) | en | 1 | very hard | landscape; three label/value panels side by side; 11-column table with two-level header and nested row spans, vertically centred; footnote marker; signature captions |
| k17 | Supplier price quotation | tr | 1 | medium | letter-spaced light title; key/value table beside the addressee; line items with five spanning total rows; Turkish number format; typed "1)" list; two boxes side by side |
| k18 | Training-course programme | fa (RTL) | 2 | very hard | RTL; Persian digits and letters; rounded key/value panel; sessions table continued across pages; typed "۱." list and "الف)" list with nested items; CSS bullets |
| k19 | Housing co-operative board minutes | en | 3 | hard | three pages; borderless attendance table; finance table with section rows and double-ruled total; typed roman "(i)" and letter "(a)" lists, nested; zebra action log continued across pages |
| k20 | Home-insurance policy schedule | pl | 2 | hard | two label/value boxes side by side; coverage table with section rows and spanning totals; typed "1." / "a)" list; CSS list with "»" marker; boxed key/value table |
| k21 | Rice-cooker user guide and warranty card | vi | 1 | medium | Vietnamese stacked diacritics (NFC); two-column block with warning box; typed "1." / "a." steps; key/value table with two pairs per row; warranty form with dotted fields |
| k22 | Construction monthly progress report | en | 2 | hard | floated captioned key/value table with text wrapping beside it; table with vertical rules only; full-grid risk table with coloured cells; figure boxes; CSS-counter "1" / "1.1" list |
| k23 | Condominium meeting minutes | it | 2 | medium | typed "1)" and "a)" lists; table ruled under header and above total; votes table with two-level header; CSS lower-roman list; Italian number format |
| k24 | Industrial pump datasheet | en | 2 | hard | INI code block in Courier New; inline code; CSS bullets in two columns; two captioned key/value tables side by side; row-header performance table; row spans; table with no lines; typed "•" and "–" lists; "1 (2)" page numbers |

## Fonts embedded (PostScript names read from /BaseFont in the PDF bytes)

| id | fonts named in the CSS | embedded faces |
|---|---|---|
| k01 | Georgia, Gill Sans MT | Georgia, Georgia-Bold, GillSansMT, GillSansMT-Bold, GillSansMT-Italic |
| k02 | Garamond | Garamond, Garamond-Bold, Garamond-Italic |
| k03 | Franklin Gothic Book (bold is synthesised by Chrome) | FranklinGothic-Book |
| k04 | Sakkal Majalla | SakkalMajalla, SakkalMajalla-Bold |
| k05 | Yu Gothic | YuGothic-Bold, YuGothic-Regular |
| k06 | Verdana | Verdana, Verdana-Bold |
| k07 | Segoe UI, Consolas | Consolas, SegoeUI, SegoeUI-Semibold |
| k08 | Arial | Arial-BoldMT, ArialMT |
| k09 | SimSun, Microsoft YaHei | MicrosoftYaHei, MicrosoftYaHei-Bold, SimSun |
| k10 | Times New Roman | TimesNewRomanPS-BoldMT, TimesNewRomanPSMT |
| k11 | Calibri, Segoe Print | Calibri, Calibri-Bold, SegoePrint |
| k12 | Malgun Gothic | MalgunGothic, MalgunGothicBold |
| k13 | Cambria, Candara | Cambria, Cambria-Bold, Cambria-Italic, Candara, Candara-Bold |
| k14 | Palatino Linotype | PalatinoLinotype-Bold, PalatinoLinotype-BoldItalic, PalatinoLinotype-Italic, PalatinoLinotype-Roman |
| k15 | Nirmala UI | NirmalaUI, NirmalaUI-Bold |
| k16 | Roboto, Roboto Condensed | Roboto-Regular, RobotoCondensed-Bold, RobotoCondensed-Regular |
| k17 | Open Sans, Open Sans Light | OpenSans, OpenSans-Bold, OpenSans-Light |
| k18 | Tahoma | Tahoma, Tahoma-Bold |
| k19 | Century Schoolbook | CenturySchoolbook, CenturySchoolbook-Bold, CenturySchoolbook-Italic |
| k20 | Constantia, Corbel | Constantia, Constantia-Bold, Constantia-Italic, Corbel, Corbel-Bold |
| k21 | Droid Sans | DroidSans, DroidSans-Bold |
| k22 | Book Antiqua, Century Gothic | BookAntiqua, BookAntiqua-Bold, CenturyGothic, CenturyGothic-Bold |
| k23 | Goudy Old Style | GoudyOldStyleT-Bold, GoudyOldStyleT-Italic, GoudyOldStyleT-Regular |
| k24 | Lucida Sans, Courier New | CourierNewPSMT, LucidaSans, LucidaSans-Demi |

Languages: English (k01, k07, k11, k13, k16, k19, k22, k24), French, German, Arabic, Japanese, Spanish, Hebrew, Chinese, Russian, Korean, Greek, Hindi, Turkish, Persian, Polish, Vietnamese and Italian. Right-to-left documents with lists and tables: k04 (Arabic), k08 (Hebrew), k18 (Persian). Multi-page documents: 14 (k02 to k07, k09, k13, k18, k19 with 3 pages, k20, k22, k23, k24).
