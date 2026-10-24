# pdf_reader_narrated.ring -- Softanza's native PDF reader (engine/src/pdf.zig, stz_file.dll), told as scenes.
#
# The reader is the deterministic FLOOR of the document faculty: the text layer of a born-digital PDF, laid
# out in reading order and typed (heading, paragraph, list item, code, table, caption, page furniture).
# These scenes pin its behaviour on golden_v1, which is its DEVELOPMENT set: the reader was built while
# reading these ten files, so they prove the behaviour holds, not how good the reader is. Its measured
# quality is on golden_v2, written by an author who never saw it (results/).
#
#   cd libraries/stzlib/base/test/document ; ring pdf_reader_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

cG = "_data/golden_v1/"

Scenario("A table drawn with ruling lines comes back as its grid")
	o = StzPdfQ(cG + "d03.pdf")
	Then("the document has one page", o.NumberOfPages(), 1)
	Then("it has a text layer", o.HasText(), 1)
	aT = o.Tables()
	Then("one table is found", len(aT), 1)
	Then("seven rows: the header and six items", len(aT[1]), 7)
	Then("the header row is read cell by cell", @@(aT[1][1]), @@([ "Item code", "Description", "Quantity in stock", "Unit price (EUR)" ]))
	Then("a body cell sits at its row and column", aT[1][2][1], "A-101")
	Then("the table's text is not repeated as paragraphs", StzFindFirst("Steel hinge", "" + @@(o.Paragraphs())), 0)
EndScenario()

Scenario("A merged cell repeats its text in every cell it covers; the line above the table is its caption")
	o = StzPdfQ(cG + "d04.pdf")
	aT = o.Tables()[1]
	Then("a cell spanning two columns fills both", @@([ aT[1][3], aT[1][4] ]), @@([ "Shipments", "Shipments" ]))
	Then("a cell spanning two rows fills both", @@([ aT[3][1], aT[4][1] ]), @@([ "North", "North" ]))
	Then("the caption is found", @@(o.Captions()), @@([ "Table 2. Shipments by region and product line (units)" ]))
	Then("and it is not taken for a heading", StzFindFirst("Table 2", "" + @@(o.Headings())), 0)
EndScenario()

Scenario("Headings come from the type: largest first, levels by size")
	o = StzPdfQ(cG + "d02.pdf")
	aH = o.Headings()
	Then("the title is level 1", @@(aH[1]), @@([ 1, "Annual Maintenance Report 2025" ]))
	Then("a section is level 2", @@(aH[2]), @@([ 2, "1 Summary" ]))
	Then("a subsection is level 3", @@(aH[3]), @@([ 3, "1.1 Scope" ]))
	Then("a body paragraph is never a heading", StzFindFirst("This report describes", "" + @@(aH)), 0)
	Then("two pages are read", o.NumberOfPages(), 2)
EndScenario()

Scenario("Two columns are read one after the other, not line by line across")
	o = StzPdfQ(cG + "d05.pdf")
	c = o.Text()
	n1 = StzFindFirst("Within a week", c)
	n2 = StzFindFirst("The farmers on the plain", c)
	Then("the left column's last paragraph is found", n1 > 0, 1)
	Then("the right column starts after the whole left column", n2 > n1, 1)
	Then("a line of the left column is not cut by the right one", StzFindFirst("Heavy rain in the hills sent a flood down the valley in just two days.", c) > 0, 1)
EndScenario()

Scenario("Bullets drawn as shapes, written numbers, and nesting")
	o = StzPdfQ(cG + "d06.pdf")
	aL = o.ListItems()
	Then("every item is found", len(aL), 12)
	Then("a disc bullet starts an item, the shape gives no character", @@(aL[1]), @@([ 0, "A flat floor area of at least one square metre" ]))
	Then("a nested item is one level deeper", @@(aL[3]), @@([ 1, "A 10 mm spanner" ]))
	Then("a numbered item keeps its number", @@(aL[7]), @@([ 0, "1. Unpack the motor unit and the filter bag." ]))
	Then("the sentence before a list is not an item", StzFindFirst("Before you begin", "" + @@(aL)), 0)
EndScenario()

Scenario("Page headers and footers are furniture, kept out of the text")
	o = StzPdfQ(cG + "d07.pdf")
	aF = o.Furniture()
	Then("a header and a footer on each of three pages", len(aF), 6)
	Then("the page number is furniture", StzFindFirst("Page 2 of 3", "" + @@(aF)) > 0, 1)
	Then("the text has no page number", StzFindFirst("Page 2 of 3", o.Text()), 0)
	Then("the text has no running header", StzFindFirst("User Manual, Revision 3", o.Text()), 0)
	Then("a page's own text is still there", StzFindFirst("Hold the power button", o.TextOfPage(2)) > 0, 1)
EndScenario()

Scenario("Right-to-left text comes back in logical order, as letters, not as glyph forms")
	o = StzPdfQ(cG + "d08.pdf")
	c = o.Text()
	Then("French accents survive", StzFindFirst("La bibliothèque a accueilli", c) > 0, 1)
	Then("the Arabic sentence reads in logical order", StzFindFirst("يقدم هذا التقرير ملخصا لنشاط المكتبة البلدية خلال السنة الماضية.", c) > 0, 1)
	Then("no presentation form is left (U+FE70 to U+FEFF)", StzFindFirst("ﻟ", c), 0)
	Then("the second sentence follows the first", StzFindFirst("ارتفع عدد الزوار", c) > StzFindFirst("يقدم هذا التقرير", c), 1)
EndScenario()

Scenario("Code keeps its lines, its blank lines and its indentation")
	o = StzPdfQ(cG + "d09.pdf")
	aC = o.CodeBlocks()
	Then("the program is one block", len(aC), 1)
	Then("an indented line keeps four spaces", StzFindFirst(char(10) + "    return mass_kg * C ** 2", aC[1]) > 0, 1)
	Then("the underscore is not split", StzFindFirst("mass _ kg", aC[1]), 0)
	Then("two spaces inside a line are kept", StzFindFirst("299792458  #", aC[1]) > 0, 1)
	Then("prose is not code", StzFindFirst("The program prints", "" + @@(aC)), 0)
EndScenario()

# ---- the second round, pinned on golden_v2 (a development set too since the reader was fixed on it) ----------
cH = "_data/golden_v2/"

Scenario("A table drawn without lines is found from its aligned columns of short cells")
	o = StzPdfQ(cH + "e01.pdf")
	aT = o.Tables()
	Then("one table", len(aT), 1)
	Then("its header row", @@(aT[1][1]), @@([ "Variety", "Yield (kg/ha)", "Days to maturity" ]))
	Then("a body row, cell by cell", @@(aT[1][2]), @@([ "Sahel Gold", "1,240", "84" ]))
	Then("the line above it is its caption", @@(o.Captions()), @@([ "Table 1. Average yield per hectare by variety" ]))
	Then("prose is not taken for a table", StzFindFirst("This summary reports", "" + @@(aT)), 0)
EndScenario()

Scenario("A table continued on the next page is one table, its repeated header dropped")
	o = StzPdfQ(cH + "e04.pdf")
	aT = o.Tables()
	Then("one table across two pages", len(aT), 1)
	Then("its header once, then every part number", len(aT[1]), 45)
	Then("the last row comes from page 2", aT[1][45][1], "SP-1044")
EndScenario()

Scenario("Columns, a sidebar, and a heading below two columns are read in order")
	o = StzPdfQ(cH + "e03.pdf")
	c = o.Text()
	Then("the sidebar is read after the main text", StzFindFirst("At a Glance", c) > StzFindFirst("The restoration group meets", c), 1)
	o = StzPdfQ(cH + "e10.pdf")
	c = o.Text()
	Then("a word broken across the column break is whole again", StzFindFirst("Trinkwasserversorgungssicherheitsverordnung", c) > 0, 1)
	Then("the heading under both columns comes after the second column", StzFindFirst("Kennzahlen", c) > StzFindFirst("Fachkräftemangel", c), 1)
EndScenario()

Scenario("A numbered heading is a heading; a one-page running header is furniture; a byline stays in place")
	o = StzPdfQ(cH + "e06.pdf")
	aH = o.Headings()
	Then("the numbered heading is found as a heading", StzFindFirst("1. Introduction", "" + @@(aH)) > 0, 1)
	Then("and not as a list item", StzFindFirst("Introduction", "" + @@(o.ListItems())), 0)
	Then("the journal line in the top margin is furniture", StzFindFirst("Sahel Water Studies", "" + @@(o.Furniture())) > 0, 1)
	Then("the byline comes before the first section", StzFindFirst("R. Okonjo", o.Text()) < StzFindFirst("Shallow alluvial", o.Text()), 1)
EndScenario()

Scenario("In a right-to-left line, the stop after a Latin name stays after it, and no space is invented")
	o = StzPdfQ(cH + "e05.pdf")
	Then("the Latin name and its full stop", StzFindFirst("Rivulet S3.", o.Text()) > 0, 1)
	Then("no stop moved before the name", StzFindFirst(".Rivulet", o.Text()), 0)
	Then("no space before the stop", StzFindFirst("Rivulet S3 .", o.Text()), 0)
EndScenario()

# ---- the third round, pinned on golden_v3 (a development set since the reader was fixed on it) ----------------
cJ = "_data/golden_v3/"

Scenario("A soft hyphen that does not break is invisible: the word is not cut into syllables")
	o = StzPdfQ(cJ + "f10.pdf")
	c = o.Text()
	Then("the word is whole", StzFindFirst("Joining a committee brings new responsibilities for every member.", c) > 0, 1)
	Then("no syllable is left apart", StzFindFirst("re spon si", c), 0)
EndScenario()

Scenario("Prose set in a monospaced font is prose, and a word broken across its columns is whole")
	o = StzPdfQ(cJ + "f09.pdf")
	Then("no code block", len(o.CodeBlocks()), 0)
	Then("the broken word is joined", StzFindFirst("could improve the interoperability of their records", StzReplace(o.Text(), char(10), " ")) > 0, 1)
EndScenario()

Scenario("In a right-to-left line, brackets around a Latin word are mirrored back")
	o = StzPdfQ(cJ + "f08.pdf")
	Then("the brackets open and close the right way", StzFindFirst("(KPI)", o.Text()) > 0, 1)
	Then("not reversed", StzFindFirst(")KPI(", o.Text()), 0)
EndScenario()

Scenario("A typed arrow starts a list item; a ligature reads as its letters")
	o = StzPdfQ(cJ + "f12.pdf")
	Then("the arrow items are list items", StzFindFirst("Stack the chairs", "" + @@(o.ListItems())) > 0, 1)
	o = StzPdfQ(cJ + "f14.pdf")
	Then("fi is two letters", StzFindFirst("a small file at start-up", o.Text()) > 0, 1)
	Then("no ligature code point is left", StzFindFirst("ﬁ", o.Text()), 0)
EndScenario()

# ---- the fourth round, pinned on golden_v4 (a development set since the reader was fixed on it) ---------------
cK = "_data/golden_v4/"

Scenario("Figures in a borderless table keep their own columns, even right-aligned and close together")
	o = StzPdfQ(cK + "g09.pdf")
	aT = o.Tables()[1]
	Then("five columns", len(aT[1]), 5)
	Then("a row of figures, cell by cell", @@(aT[2]), @@([ "Rent", "850.00", "850.00", "850.00", "2,550.00" ]))
EndScenario()

Scenario("A table split by a page footer and header is still one table")
	o = StzPdfQ(cK + "g10.pdf")
	Then("one table across the two pages", len(o.Tables()), 1)
	Then("the furniture between its halves is still furniture", len(o.Furniture()) >= 4, 1)
EndScenario()

Scenario("Headings marked by italics alone, or by letter-spacing, are found")
	o = StzPdfQ(cK + "g11.pdf")
	aH = o.Headings()
	Then("an italic heading", StzFindFirst("Isolating the Main Switch", "" + @@(aH)) > 0, 1)
	Then("is not glued to its paragraph", StzFindFirst("Isolating the Main Switch Turn", o.Text()), 0)
	o = StzPdfQ(cK + "g13.pdf")
	Then("a letter-spaced heading reads as words", StzFindFirst("HARBOUR COUNCIL MINUTES", "" + @@(o.Headings())) > 0, 1)
	Then("not as spaced letters", StzFindFirst("H A R B O U R", o.Text()), 0)
EndScenario()

Scenario("Line numbers in a gutter are not code; typed check marks and roman numerals start list items")
	o = StzPdfQ(cK + "g14.pdf")
	aC = o.CodeBlocks()
	Then("the listing is one block", StzFindFirst("import os" + char(10) + "import shutil", aC[1]) > 0, 1)
	Then("its line numbers are gone", StzFindFirst("1" + char(10) + "import", aC[1]), 0)
	Then("no table is made of it", len(o.Tables()), 0)
	o = StzPdfQ(cK + "g05.pdf")
	Then("a typed check mark starts an item", StzFindFirst("Head count matches the register", "" + @@(o.ListItems())) > 0, 1)
	o = StzPdfQ(cK + "g06.pdf")
	Then("a roman numeral starts an item", StzFindFirst("iii. large, twelve square metres.", "" + @@(o.ListItems())) > 0, 1)
EndScenario()

Scenario("Guillemets in Hebrew, an Arabic heading, and a sentence running on into the next column")
	o = StzPdfQ(cK + "g04.pdf")
	Then("the quotation opens with «", StzFindFirst("אמרה: «", o.Text()) > 0, 1)
	o = StzPdfQ(cK + "g03.pdf")
	Then("the Arabic heading reads with Arabic letters", StzFindFirst("التدريب والخدمات", "" + @@(o.Headings())) > 0, 1)
	o = StzPdfQ(cK + "g16.pdf")
	c = o.Text()
	Then("the sentence is whole across the columns", StzFindFirst("They should arrive before the first long ride of the season.", c) > 0, 1)
	Then("a compound keeps its own hyphen at a line break", StzFindFirst("two-hundred-kilometre", c) > 0, 1)
	Then("the heading under both columns comes after the second", StzFindFirst("Ride Calendar", c) > StzFindFirst("annual fee", c), 1)
EndScenario()

# ---- the fifth round, pinned on golden_v5 (realistic documents; a development set since the reader was fixed on it)
cL = "_data/golden_v5/"

Scenario("An invoice's table takes its header row above and its totals rows below")
	o = StzPdfQ(cL + "h03.pdf")
	aT = 0
	aAll = o.Tables()
	for i = 1 to len(aAll)
		if StzFindFirst("Subtotal", "" + @@(aAll[i])) > 0 aT = aAll[i] ok
	next
	Then("the line items and the totals are one table", isList(aT), 1)
	Then("its header row came from above the grid", @@(aT[1]), @@([ "No.", "Description", "Qty", "Unit price (£)", "Amount (£)" ]))
	Then("a long description stays a cell", aT[2][2], "A4 copier paper, 80 g/m², box of 5 reams")
	Then("a totals label fills the cells it spans", @@(aT[9]), @@([ "Subtotal", "Subtotal", "Subtotal", "Subtotal", "1,082.45" ]))
	Then("the last row is the total due", aT[len(aT)][5], "£1,234.00")
EndScenario()

Scenario("A table grows upward past a section row to its header")
	o = StzPdfQ(cL + "h18.pdf")
	aT = 0
	aAll = o.Tables()
	for i = 1 to len(aAll)
		if StzFindFirst("Hemogram", "" + @@(aAll[i])) > 0 aT = aAll[i] ok
	next
	Then("the results table is found with its section", isList(aT), 1)
	Then("its header row", aT[1][1], "Test")
	Then("then the section row, across the table", @@(aT[2]), @@([ "Hemogram", "Hemogram", "Hemogram", "Hemogram", "Hemogram" ]))
EndScenario()

Scenario("Synthetic bold keeps its spaces, and Arabic ligatures read as letters")
	o = StzPdfQ(cL + "h17.pdf")
	Then("a Type3 font's widths come from its own matrix", StzFindFirst("Total revenue", "" + @@(o.Tables())) > 0, 1)
	Then("no words run together", StzFindFirst("Totalrevenue", "" + @@(o.Tables())), 0)
	o = StzPdfQ(cL + "h11.pdf")
	Then("a ligature of the presentation forms is decomposed", StzFindFirst("مبرمج", o.Text()) > 0, 1)
EndScenario()

Scenario("A run-in heading, a typewriter heading, and prose beside a table")
	o = StzPdfQ(cL + "h09.pdf")
	# (round 11: a lead ending in a full stop is no longer a heading -- over golden_v1..v11 such headings were
	#  16 false and 1 true, this one; it stays at the head of its paragraph)
	Then("a bold lead-in ending in a full stop opens its paragraph", StzFindFirst("Abstract. Thirty-six", o.Text()) > 0, 1)
	Then("the paragraph after it keeps its text", StzFindFirst("Thirty-six low-cost data loggers", o.Text()) > 0, 1)
	Then("a prose line of the next column is not a table cell", StzFindFirst("central store", "" + @@(o.Tables())), 0)
	o = StzPdfQ(cL + "h04.pdf")
	Then("a large line in a typewriter face is a heading, not code", StzFindFirst("Farmácia Boa Esperança", "" + @@(o.Headings())) > 0, 1)
EndScenario()

# ---- the sixth round, pinned on golden_v6 (realistic documents; a development set since the reader was fixed on it)
cM = "_data/golden_v6/"

Scenario("A purchase order: a wrapped header cell, a section row, two pages, totals and a letterhead")
	o = StzPdfQ(cM + "k02.pdf")
	aT = 0
	aAll = o.Tables()
	for i = 1 to len(aAll)
		if StzFindFirst("Order total", "" + @@(aAll[i])) > 0 aT = aAll[i] ok
	next
	Then("the line items are one table across both pages", isList(aT), 1)
	Then("its header row, a wrapped cell joined", @@(aT[1]), @@([ "Line", "Item code", "Description", "Qty", "Unit", "Unit price (£)", "Net (£)" ]))
	Then("then the first section row across the table", aT[2][7], "Electrical")
	Then("the header repeated on page 2 is not repeated in the table", len(StzFindCS("Item code", "" + @@(aT), 1)), 1)
	Then("a totals label fills the cells it spans", @@(aT[len(aT)]), @@([ "Order total", "Order total", "Order total", "Order total", "Order total", "Order total", "7,291.81" ]))
	Then("the logo name of the letterhead is furniture", StzFindFirst("NORTHGATE", "" + @@(o.Furniture())) > 0, 1)
	Then("the document's title is not", StzFindFirst("Purchase Order", "" + @@(o.Headings())) > 0, 1)
EndScenario()

Scenario("A two-level header: a cell over two columns fills both")
	o = StzPdfQ("_data/golden_v5/h17.pdf")
	aT = o.Tables()[1]
	# (the "Note" cell spans both header rows in the source but is drawn once, in the lower row: a borderless
	#  header gives no sign of a row span, so the reader leaves the upper cell empty -- a known limit)
	Then("the upper header row", @@(aT[1]), @@([ "", "", "Quarter ended 30 September", "Quarter ended 30 September", "Nine months ended 30 September", "Nine months ended 30 September" ]))
	Then("the lower header row", aT[2][3], "2025")
EndScenario()

# ---- the eighth round, pinned on golden_v7 and golden_v8 (development sets since the reader was fixed on them)

Scenario("A blank band above a table is not its first row")
	o = StzPdfQ("_data/golden_v8/n03.pdf")
	aT = o.Tables()
	Then("the first table opens on its first labelled row", @@(aT[1][1]), @@([ "Patient", "Mrs Evelyn Marsh-Okafor", "Hospital no.", "7731 0428" ]))
	Then("the results table opens on its header", aT[2][1][1], "Test")
EndScenario()

Scenario("A form's blank rows lower in the table are kept")
	o = StzPdfQ("_data/golden_v7/m16.pdf")
	aT = o.Tables()[1]
	Then("the header row", @@(aT[1]), @@([ "low", "high", "mid", "items[mid]" ]))
	Then("the one filled row, then three rows left to fill", len(aT), 5)
	Then("the last of them blank", @@(aT[5]), @@([ "", "", "", "" ]))
EndScenario()

# ---- the ninth round, pinned on golden_v9 (a development set since the reader was fixed on it)

Scenario("Two boxes side by side, with a title and a footer crossing their gutter, are read box by box")
	o = StzPdfQ("_data/golden_v9/p15.pdf")
	cT = o.Text()
	Then("the English box ends before the Hausa box begins", StzFindFirst("marked with ink", cT) < StzFindFirst("Za a ba duk yara", cT), 1)
	Then("a drawn bullet's item keeps its second line", StzFindFirst("show it to the team.", "" + @@(o.ListItems())) > 0, 1)
EndScenario()

Scenario("A right-to-left page: its list is found and its table reads rightmost first")
	o = StzPdfQ("_data/golden_v9/p05.pdf")
	Then("four list items, their bullets drawn on the right", len(o.ListItems()), 4)
	aT = o.Tables()[1]
	Then("a row reads from its rightmost cell: the date third", aT[2][3], "2026/11/09")
	Then("and the leftmost cell last", aT[2][5], "16:00")
EndScenario()

Scenario("A long table with section and subtotal rows, across two pages, is one table")
	o = StzPdfQ("_data/golden_v9/p10.pdf")
	aT = o.Tables()[2]
	Then("59 rows, the header once", len(aT), 59)
	Then("eight columns: a subtotal label over two does not join them", @@(aT[1]), @@([ "Village", "Producer group", "Members", "Women", "Millet seed (kg)", "Cowpea seed (kg)", "NPK 15-15-15 (bags)", "Urea (bags)" ]))
	Then("the grand total closes it", aT[59][1], "Grand total")
EndScenario()

Scenario("A table over three pages is one table")
	o = StzPdfQ("_data/golden_v9/p18.pdf")
	aT = o.Tables()[2]
	Then("87 rows, the header once", len(aT), 87)
	Then("its last row is on page 3", aT[87][2], "Balance carried forward")
EndScenario()

Scenario("A code block opening with a brace keeps its indented lines")
	o = StzPdfQ("_data/golden_v9/p23.pdf")
	aC = o.CodeBlocks()
	Then("two code blocks", len(aC), 2)
	Then("the JSON one starts with its brace and holds its first key", StzFindFirst('"check": "tls-handshake"', aC[2]) > 0, 1)
EndScenario()

# ---- the tenth round, pinned on golden_v10 and golden_v8 (development sets since the reader was fixed on them)

Scenario("A Persian page: its digits read as a number, its hamza stays on its letter, its heh is heh")
	o = StzPdfQ("_data/golden_v10/q21.pdf")
	aT = o.Tables()[1]
	Then("a price in Persian digits, in order", aT[2][3], "۲۵۰٬۰۰۰")
	Then("the title keeps kitabkhaneh whole, hamza last", StzFindFirst("کتابخانهٔ عمومی", "" + @@(o.Headings())) > 0, 1)
	Then("no Urdu heh on a Persian page", StzFindFirst("ھ", o.Text()), 0)
EndScenario()

Scenario("A tanween over a word's last alef stays with it, before the full stop")
	o = StzPdfQ("_data/golden_v8/n17.pdf")
	Then("the mark follows its alef", StzFindFirst("ومقبولاً.", o.Text()) > 0, 1)
EndScenario()

Scenario("A space glyph mapped to a TAB is a space")
	o = StzPdfQ("_data/golden_v10/q16.pdf")
	Then("the title reads with spaces", StzFindFirst("Bulletin de notes du troisième trimestre", "" + @@(o.Headings())) > 0, 1)
	Then("no TAB anywhere in the text", StzFindFirst(char(9), o.Text()), 0)
EndScenario()

Scenario("Two boxes side by side read as one table under a row of titles become two tables, box by box")
	o = StzPdfQ("_data/golden_v10/q04.pdf")
	aT = o.Tables()
	Then("the patient box is a table of two columns", len(aT[1][1]), 2)
	Then("its first row", @@(aT[1][1]), @@([ "Paciente", "Rosario Méndez Ibarra" ]))
	Then("the sample box comes next", aT[2][1][1], "N.º de petición")
	Then("each title is a heading", StzFindFirst("Datos de la muestra", "" + @@(o.Headings())) > 0, 1)
EndScenario()

# ---- the eleventh round, pinned on golden_v5, v6 and v11 (development sets since the reader was fixed on them)

Scenario("A bold lead ending in a colon is not a heading: it opens its paragraph")
	o = StzPdfQ("_data/golden_v5/h14.pdf")
	Then("no heading ends with a colon", StzFindFirst(":" + char(34), "" + @@(o.Headings())), 0)
	Then("the lead stays with its sentence", StzFindFirst("Warning: Do not restore while the enrolment period is open.", o.Text()) > 0, 1)
EndScenario()

Scenario("A bold cell in a row of short cells is not a heading")
	o = StzPdfQ("_data/golden_v6/k05.pdf")
	Then("the header cell is not a heading", StzFindFirst("Concepto", "" + @@(o.Headings())), 0)
EndScenario()

Scenario("Greek mu drawn with the micro sign's glyph reads as mu")
	o = StzPdfQ("_data/golden_v11/r20.pdf")
	Then("the title with mu", StzFindFirst("Πρόγραμμα εκδηλώσεων", "" + @@(o.Headings())) > 0, 1)
	Then("no micro sign inside a Greek word", StzFindFirst("µµ", o.Text()), 0)
EndScenario()

# ---- the twelfth round, pinned on golden_v8, v10 and v11 (development sets)

Scenario("A header cell centred over right-aligned figures heads their column, not one of its own")
	o = StzPdfQ("_data/golden_v11/r12.pdf")
	aT = o.Tables()[1]
	Then("five columns", len(aT[3]), 5)
	Then("a row of figures under them", @@(aT[3]), @@([ "Bare fallow", "18.2", "17.5", "9.4", "8.8" ]))
EndScenario()

Scenario("A timetable ruled only in its header is one table with its body")
	o = StzPdfQ("_data/golden_v11/r15.pdf")
	aT = o.Tables()[1]
	Then("eleven rows: two header rows and nine stops", len(aT), 11)
	Then("the first stop follows the header", aT[3][1], "Purmerveld Station")
EndScenario()

Scenario("A key/value table whose values are phrases")
	o = StzPdfQ("_data/golden_v10/q07.pdf")
	aT = o.Tables()[1]
	Then("three rows of two", len(aT), 3)
	Then("a phrase for a value", @@(aT[3]), @@([ "Imeandaliwa na", "Idara ya Ufuatiliaji na Tathmini" ]))
EndScenario()

Scenario("A list numbered in Arabic-Indic digits")
	o = StzPdfQ("_data/golden_v8/n04.pdf")
	Then("its items are list items", StzFindFirst("٢. نسخة من بطاقة التعريف الوطنية للمستغل", "" + @@(o.ListItems())) > 0, 1)
EndScenario()

Scenario("A two-column article whose lines run a little into the gap is read column by column")
	o = StzPdfQ("_data/golden_v12/s13.pdf")
	Then("a sentence of the left column reads whole", StzFindFirst("The objectives of this study were to quantify the effect of two biochar rates", o.Text()) > 0, 1)
EndScenario()

Scenario("Bracketed markers open list items")
	o = StzPdfQ("_data/golden_v12/s17.pdf")
	cL = "" + @@(o.ListItems())
	Then("a letter in brackets", StzFindFirst("(a) loss or damage caused by:", cL) > 0, 1)
	Then("a roman numeral in brackets", StzFindFirst("(i) wear and tear, rot, fungus or vermin;", cL) > 0, 1)
EndScenario()

# ---- the thirteenth round, pinned on golden_v13 (a development set since round 12 was measured on it)

Scenario("Boxes side by side between full-width tables are read box by box")
	o = StzPdfQ("_data/golden_v13/u19.pdf")
	Then("a sentence of the left box reads whole", StzFindFirst("Quý khách vui lòng thanh toán trước ngày 24/09/2026 để tránh bị tạm ngừng cấp điện.", o.Text()) > 0, 1)
EndScenario()

Scenario("A letterhead's address read as one block of short lines is furniture")
	o = StzPdfQ("_data/golden_v13/u01.pdf")
	Then("the address is page furniture", StzFindFirst("Marlpit Trading Estate", "" + @@(o.Furniture())) > 0, 1)
	Then("the title is not", StzFindFirst("TAX INVOICE", "" + @@(o.Headings())) > 0, 1)
EndScenario()

Scenario("A kerned alef tucked into a ra's tail stays after it")
	o = StzPdfQ("_data/golden_v13/u04.pdf")
	Then("al-dirasiya reads in order", StzFindFirst("السنة الدراسية", o.Text()) > 0, 1)
	Then("and not swapped", StzFindFirst("الدارسية", o.Text()), 0)
EndScenario()

# ---- the fourteenth round, pinned on golden_v14 (a development set since round 13 was measured on it)

Scenario("A typed marker set apart by a hanging indent stays at the head of its item")
	cL = "" + @@(StzPdfQ("_data/golden_v14/w10.pdf").ListItems())
	Then("a typed bullet", StzFindFirst("• The station manager ensures", cL) > 0, 1)
	cL = "" + @@(StzPdfQ("_data/golden_v14/w18.pdf").ListItems())
	Then("a typed dash", StzFindFirst("– Hujan lebat pada", cL) > 0, 1)
	cL = "" + @@(StzPdfQ("_data/golden_v14/w11.pdf").ListItems())
	Then("a typed number", StzFindFirst("1. Kada ku shuka kafin", cL) > 0, 1)
EndScenario()

Scenario("A file that is not a readable PDF is refused with the reason")
	bRaised = 0
	cWhy = ""
	try
		o = StzPdfQ("_doc_score.py")
	catch
		bRaised = 1
		cWhy = cCatchError
	done
	Then("a Python file is refused", bRaised, 1)
	Then("and the reason is said", StzFindFirst("not a PDF", cWhy) > 0, 1)
	bRaised = 0
	try
		o = StzPdfQ("_data/no-such-file.pdf")
	catch
		bRaised = 1
		cWhy = cCatchError
	done
	Then("a missing file is refused", bRaised, 1)
	Then("and the reason is said", StzFindFirst("does not exist", cWhy) > 0, 1)
EndScenario()

Summary()
