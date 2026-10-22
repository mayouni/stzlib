# Golden set v6: twenty realistic documents

This folder holds 20 complete documents of the kinds real organisations produce: quotations, purchase orders, payslips, statements, bills,
report cards, clinical and lab documents, tenders, minutes, policies, guides, catalogues, programmes, itineraries, certificates,
stock sheets and public notices. Each one has a known expected structure, and the set is used to score document readers.
Every document `kNN` comes as three files:

| file | what it is |
|---|---|
| `kNN.html` | the source, self-contained (inline CSS, Windows system fonts, no images, no scripts) |
| `kNN.pdf` | the rendered PDF |
| `kNN.expected.json` | the expected structure: `id, difficulty, pages, title, headings, key_sentences, tables, list_items, furniture, languages, code, notes` |

## How it was made

- Every document was written by one Python generator, which keeps its scripts and the Chrome profile outside this repository. Each call
  that emits a visible element (heading, key sentence, table, list item, furniture line, code block) also records that element in the
  expectation. So `expected.json` is derived from what was put into the source, not read back from any output.
- The PDFs were rendered by headless Chrome 155 (`--headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf`, separate
  `--user-data-dir`), with no browser header or footer.
- Eighteen documents are drawn as **explicit pages**: fixed-size page boxes (A4, A4 landscape or A5) with `@page { margin: 0 }`, and
  running headers, footers and page numbers placed in the body. The author therefore knows which text sits on which page. Two
  documents, k12 and k19, use normal flow with `@page` margins: Chrome chooses the page break, and k19's table header repeats
  through `thead`.
- Checks run, none of which is an extractor:
  - the page count from the raw PDF bytes (`/Type /Page` objects and `/Count`), compared with the planned count, for all 20 documents;
  - for explicit-page documents, a DOM measurement in headless Chrome showing that no page box overflows and that no body content
    reaches the footer;
  - a handful of screenshots of the HTML sources (not of the PDFs).
- Totals, balances, averages and variances in the tables are computed by the generator, so the arithmetic in each document is
  consistent.

**The author of this set never ran, imported or opened any PDF-to-text or document-conversion tool, any PDF rasterizer, any reader's
code or any reader's output.** The author did not look at `golden_v1` to `golden_v5`, the scoring or prediction scripts, or the
document-intelligence memo. All names of people, companies, institutions, products, accounts and identifiers are invented. Real
place names are used only as addresses. Masked or fictitious bank identifiers appear only as printed document content.

## Conventions in expected.json

- Text is the visible text, with whitespace runs collapsed to one space; non-breaking spaces (French and Portuguese digit grouping) are
  given as plain spaces. A word containing a soft hyphen (k13) is given whole. Right-to-left text (k06, k20) is given in logical order.
- `key_sentences` are full body sentences in reading order. A sentence that carries a footnote marker (k07) is left out.
- `tables`: the header row comes first (k06 has a two-row header). Merged cells repeat their text in every grid cell they cover. A
  table continued across pages is one table with its header row given once, even where the header is printed again on the next page.
  Section rows and totals rows belong to the same table. A cell drawn on two lines is joined with one space. Key/value grids with no
  header row are tables too.
- `list_items` carry the marker when it is typed in the text (`1.`, `a)`, `1.1`, `(a)`, `–`, `□`) and no marker when CSS draws it.
  The notes of each document say which kind it uses.
- `furniture` lists each distinct letterhead, running-header, footer and page-number line once, even when it repeats on every page.
  Page numbers are listed per page, in the form that is printed.
- `notes` say what a scorer needs to know: reading order, merges, what is deliberately left out of every field.

## The documents

| id | kind | language | pages | main difficulties |
|---|---|---|---|---|
| k01 | Quotation (devis) for building materials | fr | 1 | letterhead with logo letters and a 3-line address; key/value meta table; line items with lot section rows (span 6) and 5 totals rows (label spans 5); non-breaking digit grouping; amount in words |
| k02 | Purchase order | en | 2 | line-item table continued across pages with the header repeated; 4 section rows; totals; 3x4 key/value grid; address boxes with labels; running header; "Page n of 2"; CSS-numbered list |
| k03 | Payslip (Entgeltabrechnung) | de | 1 | 5 tables, two of them **side by side**; key/value grid with 3 pairs per row; sender line above an address window; German number format; legal footer |
| k04 | Bank statement (extrato) | pt | 2 | zebra striping, no vertical borders; opening, totals and closing balance rows; table continued on page 2; summary and account tables; "Página n/2" on the same line as the legal text |
| k05 | Electricity bill (factura) | es | 1 | two-column top area (reading order left, then right); big total box; history table with caption; detail table with section rows and a 2-span total |
| k06 | School report card (كشف النقاط) | ar | 1 | **right-to-left**; marks table with a **two-row header**, rowspan and colspan; totals row with empty cells; seal; Western digits inside Arabic text |
| k07 | Hospital discharge summary | en | 2 | a sentence with a **footnote marker** and a footnote above the footer; lab table with section rows; medication table; CSS ordered and bulleted lists; confidentiality footer |
| k08 | Laboratory results (compte rendu) | fr | 1 | partial borders only; section rows in capitals; out-of-range values marked **only by bold**; grey column of earlier results |
| k09 | Prescription (maagizo ya dawa) | sw, en | 1 | **A5 page**; typed nested list (numbers, then en dashes); a large "Rx" label; bilingual title |
| k10 | Project status report | en | 3 | heading levels 1-3 with numbers in the text; RAG table with coloured cells **and** words; milestones and budget tables; nested bullets; "– n –" page numbers |
| k11 | Call for tenders (avis d'appel d'offres) | fr | 2 | official two-block letterhead over a double rule; numbered articles; fully bordered lots table with a 2-span Total; typed list a) to f) with hanging indent |
| k12 | Board meeting minutes (acta) | es | 2 | **natural flow**, no page furniture; three heading levels; CSS bulleted and numbered lists; action table |
| k13 | Records-retention policy | en | 2 | **two-column body**; a table spanning both columns in the middle of the column flow; typed clause numbering (1.1, (a)); justified text with **soft hyphens** |
| k14 | User guide for a network storage device | de | 2 | dark full-width letterhead band; two-column spec table with section rows; 3 **code blocks**, one with space-aligned columns; a real hyphen ("ein- oder ausbauen"); warning box with a bold label |
| k15 | Product catalogue | tr | 2 | **2x3 card grid** read row by row; a heading in each card; **wide 9-column** zebra table with two-line header cells; ₺ prices |
| k16 | Conference programme | pt, en | 2 | every cell **bilingual on two lines**; **rowspan** time cells for parallel sessions; day rows; table continued across pages; side-by-side pt/en blocks |
| k17 | Travel itinerary | en | 1 | key/value header grid; flights and hotels tables with horizontal rules only; typed checkbox list (□) |
| k18 | Certificate of completion | ha, en | 1 | **landscape**; decorative double frame; Hausa hooked letters (ƙ, ɓ); bilingual title and text; seal; signature blocks; verification sentences at the very bottom |
| k19 | Physical stock count sheet | en | 2 | **landscape**; 11-column table in natural flow, broken by Chrome with a repeated thead; 4 section rows; signed variances; instructions beside the meta table |
| k20 | Public notice: planned water cut | fr, ha, ar, en | 1 | **four languages** stacked, one of them RTL; table whose header cells hold all four languages; rotated logo |

Languages used besides English: French, German, Portuguese, Spanish, Arabic, Swahili, Turkish and Hausa. Eleven documents have 2 or 3
pages (k10 has 3).
