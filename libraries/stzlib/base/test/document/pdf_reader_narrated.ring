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

# ---- the fifteenth round: marked content's ActualText (golden_v4, v14, v15)

Scenario("A marked span's ActualText is what its glyphs read as")
	o = StzPdfQ("_data/golden_v15/x18.pdf")
	Then("Greek accents drawn as separate glyphs come back", StzFindFirst("Για όγδοη χρονιά", o.Text()) > 0, 1)
	o = StzPdfQ("_data/golden_v14/w09.pdf")
	Then("a Persian word keeps its zero-width non-joiner", StzFindFirst("آیین" + char(226) + char(128) + char(140) + "نامه", o.Text()) > 0, 1)
	o = StzPdfQ("_data/golden_v15/x04.pdf")
	Then("an ActualText bracket is not mirrored again", StzFindFirst("(سهامی عام)", o.Text()) > 0, 1)
	o = StzPdfQ("_data/golden_v4/g07.pdf")
	Then("soft hyphens are dropped and a line-end hyphen joins its word", StzFindFirst("descendants continued the journal", o.Text()) > 0, 1)
	Then("no soft hyphen left in the text", StzFindFirst(char(194) + char(173), o.Text()), 0)
EndScenario()

# ---- the sixteenth round: page numbers in any language (golden_v5, v16)

Scenario("A page number in the document's own language marks its line as the footer")
	o = StzPdfQ("_data/golden_v16/y02.pdf")
	cF = "" + @@(o.Furniture())
	Then("a Greek page number is furniture", StzFindFirst("Σελίδα 1 από 1", cF) > 0, 1)
	Then("and so is the legal line on its baseline", StzFindFirst("Εκδόθηκε σύμφωνα με την απόφαση", cF) > 0, 1)
	o = StzPdfQ("_data/golden_v16/y09.pdf")
	Then("a Hungarian page number is furniture", StzFindFirst("1/1. oldal", "" + @@(o.Furniture())) > 0, 1)
	o = StzPdfQ("_data/golden_v5/h07.pdf")
	Then("a product name with a number, larger than the body, stays the title", StzFindFirst("AquaSense 300", "" + @@(o.Headings())) > 0, 1)
EndScenario()

# ---- the seventeenth round: scripts without spaces, Devanagari clusters (golden_v17)

Scenario("Japanese joins a wrapped line with no space; a Devanagari cluster keeps its place")
	o = StzPdfQ("_data/golden_v17/z23.pdf")
	Then("no space where a Japanese line wraps", StzFindFirst("条件を次のとおり定めます。", o.Text()) > 0, 1)
	o = StzPdfQ("_data/golden_v17/z11.pdf")
	Then("a conjunct whose glyphs have no text of their own is read from its ActualText", StzFindFirst("पते पर स्थित है।", o.Text()) > 0, 1)
	Then("a cluster of zero width does not cut its word", StzFindFirst("समय से पहुँचें", o.Text()) > 0, 1)
EndScenario()

# ---- the eighteenth round: tables (golden_v9, v15)

Scenario("Small tables set in two columns are split, one table per column")
	o = StzPdfQ("_data/golden_v15/x22.pdf")
	aT = o.Tables()
	Then("the first table has four columns", len(aT[1][1]), 4)
	Then("each opens on its own header", @@(aT[2][1]), @@([ "Plac", "Namn", "Förening", "Resultat" ]))
EndScenario()

Scenario("A centred row beside a two-line cell is one row")
	o = StzPdfQ("_data/golden_v9/p04.pdf")
	aT = o.Tables()[2]
	Then("the programme table is whole", len(aT), 15)
	Then("a two-line cell is joined in its row", aT[3][3], "Distribuciones de frecuencias y representación gráfica")
EndScenario()

# ---- the nineteenth round: tables (golden_v8, v19)

Scenario("A header row that is the same header twice is two tables side by side")
	o = StzPdfQ("_data/golden_v19/b14.pdf")
	aT = o.Tables()
	Then("five columns, not ten", len(aT[1][1]), 5)
	Then("the right-hand table is a table of its own", aT[2][2][2], "Beatriz Fontoura")
EndScenario()

Scenario("A top-aligned cell's second line joins its row")
	o = StzPdfQ("_data/golden_v8/n13.pdf")
	aT = o.Tables()[1]
	Then("the bids table has four rows", len(aT), 4)
	Then("a two-line company name is one cell", aT[2][1], "Impresa Edile Ventaglio S.r.l.")
EndScenario()

# ---- the twentieth round: list markers in many conventions (golden_v4, v20)

Scenario("List markers in the conventions of many languages")
	Then("a decimal pair", StzFindFirst("1.1 Dues are payable", "" + @@(StzPdfQ("_data/golden_v20/c01.pdf").ListItems())) > 0, 1)
	Then("a number and a dash, set apart, not a table", StzFindFirst("1- Ticari fatura (2 sayfa)", "" + @@(StzPdfQ("_data/golden_v20/c18.pdf").ListItems())) > 0, 1)
	Then("a full-width CJK marker, set apart from its text by a gap", StzFindFirst("（1） 平日朝7時台", "" + @@(StzPdfQ("_data/golden_v20/c06.pdf").ListItems())) > 0, 1)
	Then("a Devanagari letter in brackets", StzFindFirst("(क) फ़ोटोयुक्त पासपोर्ट", "" + @@(StzPdfQ("_data/golden_v20/c16.pdf").ListItems())) > 0, 1)
	aT = StzPdfQ("_data/golden_v4/g09.pdf").Tables()[1]
	Then("a figure like 850.00 is a table cell, never a list marker", @@(aT[2]), @@([ "Rent", "850.00", "850.00", "850.00", "2,550.00" ]))
EndScenario()

# ---- the twenty-first round: scripts, CJK markers, tables ruled between their rows (golden_v14, v17, v21)

Scenario("Thai headings, markers in any script's digits, CJK markers, and tables ruled between their rows")
	Then("a Thai title is a heading", StzFindFirst("ใบยืนยันการจองห้องพัก", "" + @@(StzPdfQ("_data/golden_v21/d21.pdf").Headings())) > 0, 1)
	Then("a Thai-digit marker opens a list item", StzFindFirst("๑. ยกเลิกก่อนวันเข้าพัก", "" + @@(StzPdfQ("_data/golden_v21/d21.pdf").ListItems())) > 0, 1)
	Then("a full-width marker set apart by a gap takes a space", StzFindFirst("１． 価格には配送料", "" + @@(StzPdfQ("_data/golden_v21/d05.pdf").ListItems())) > 0, 1)
	Then("and one set close stays as written", StzFindFirst("（1）網口の幅", "" + @@(StzPdfQ("_data/golden_v17/z23.pdf").ListItems())) > 0, 1)
	o = StzPdfQ("_data/golden_v21/d17.pdf")
	Then("a full-width bracketed marker standing apart joins its text", StzFindFirst("（１） 文書とは", "" + @@(o.ListItems())) > 0, 1)
	Then("a circled digit is a marker", StzFindFirst("① 紙の文書は", "" + @@(o.ListItems())) > 0, 1)
	aT = StzPdfQ("_data/golden_v21/d11.pdf").Tables()[1]
	Then("a table ruled only between its rows is found, a centred cell spanning two columns", @@(aT[2]), @@([ "08:30", "Registration and coffee", "Registration and coffee" ]))
	Then("a heading between two such tables stays a heading", StzFindFirst("18 ноября, среда", "" + @@(StzPdfQ("_data/golden_v14/w24.pdf").Headings())) > 0, 1)
	aT = StzPdfQ("_data/golden_v21/d22.pdf").Tables()[2]
	Then("a group label over two columns makes a two-row header", @@(aT[1]), @@([ "Lp.", "Parametr", "Jednostka", "Wynik ± U", "Wymagania", "Wymagania", "Metoda badawcza" ]))
EndScenario()

# ---- the twenty-second round: zebra tables, letterheads, markers in a document's own letters (golden_v15, v20, v22)

Scenario("Zebra tables, letterheads over a smaller title, and markers in a document's own letters")
	o = StzPdfQ("_data/golden_v22/e10.pdf")
	aT = o.Tables()
	Then("a zebra table, its rows bounded by the shaded bands", @@(aT[1][3]), @@([ "08:30–09:15", "Registration and coffee", "Atrium" ]))
	Then("and its last, unshaded row is kept", @@(aT[1][len(aT[1])]), @@([ "15:30–16:00", "Closing remarks and prize draw", "Lecture Theatre" ]))
	Then("the sidebar beside it is a table of its own", @@(aT[2][1]), @@([ "Registration desk", "ext. 210" ]))
	Then("a heading over each of several tables in a column stays a heading", StzFindFirst("100 m damer (vind −0,4)", "" + @@(StzPdfQ("_data/golden_v15/x22.pdf").Headings())) > 0, 1)
	o = StzPdfQ("_data/golden_v22/e08.pdf")
	Then("a letter-spaced CJK title is one heading", StzFindFirst("采购订单", "" + @@(o.Headings())) > 0, 1)
	Then("and the letterhead above it is furniture", StzFindFirst("瑞丰机电设备（苏州）有限公司", "" + @@(o.Furniture())) > 0, 1)
	Then("a letterhead's name set larger than the title is furniture", StzFindFirst("सरस्वती विद्या निकेतन", "" + @@(StzPdfQ("_data/golden_v22/e14.pdf").Furniture())) > 0, 1)
	Then("a Korean letter marker", StzFindFirst("가. 납품 기한", "" + @@(StzPdfQ("_data/golden_v22/e17.pdf").ListItems())) > 0, 1)
	Then("a Thai letter marker under a Thai-digit item", StzFindFirst("ก. ทางโทรศัพท์", "" + @@(StzPdfQ("_data/golden_v22/e24.pdf").ListItems())) > 0, 1)
	Then("a katakana marker standing apart", StzFindFirst("ア 私物のUSBメモリ", "" + @@(StzPdfQ("_data/golden_v22/e05.pdf").ListItems())) > 0, 1)
	Then("but a letter-spaced title opening on katakana keeps its spelling", StzFindFirst("ダイヤ改正のお知らせ", "" + @@(StzPdfQ("_data/golden_v20/c06.pdf").Headings())) > 0, 1)
EndScenario()

# ---- the twenty-third round: column rules, tall rows, ladders kept whole, letterheads beside the title (golden_v6, v23)

Scenario("Columns split by a rule, rows of tall cells, clean ladders, and letterheads beside or over the title")
	o = StzPdfQ("_data/golden_v23/f23.pdf")
	Then("a vertical rule between two columns keeps each column's list whole", StzFindFirst("The riverside path will be diverted over the Mill Road bridge.", "" + @@(o.ListItems())) > 0, 1)
	Then("a row of two-line cells beside cells centred between them is one row", @@(o.Tables()[1][2]), @@([ "1", "03/11–14/11/2026", "Removal of the old deck Dépose de l’ancien tablier", "Closed Fermée" ]))
	Then("a ladder that cannot take a table's place leaves it whole", @@(StzPdfQ("_data/golden_v6/k01.pdf").Tables()[2][1]), @@([ "Réf.", "Désignation", "Qté", "Unité", "P.U. HT (FCFA)", "Montant HT (FCFA)" ]))
	Then("a letterhead beside the title is furniture", StzFindFirst("บริษัท เรือนไม้ดีไซน์ จำกัด", "" + @@(StzPdfQ("_data/golden_v23/f22.pdf").Furniture())) > 0, 1)
	Then("a letterhead's name over an e-mail line is furniture", StzFindFirst("नवप्रभात विद्या निकेतन", "" + @@(StzPdfQ("_data/golden_v23/f12.pdf").Furniture())) > 0, 1)
	Then("the katakana middle dot is a bullet", StzFindFirst("・試験運用は第2ラインに限定して実施する。", "" + @@(StzPdfQ("_data/golden_v23/f05.pdf").ListItems())) > 0, 1)
EndScenario()

# ---- the twenty-fourth round: tables beside narrow paragraphs, spanning cells, wrapped cells (golden_v24)

Scenario("Floated tables beside narrow paragraphs, cells spanning two rows, and items over two lines")
	aT = StzPdfQ("_data/golden_v24/g21.pdf").Tables()
	Then("a key/value table floated beside a narrow paragraph", @@(aT[1][1]), @@([ "Wanachama waliohudhuria", "186" ]))
	Then("and a second one, its section row across it", @@(aT[2][6]), @@([ "Matumizi", "Matumizi" ]))
	Then("a label in another face is read before its value", @@(StzPdfQ("_data/golden_v24/g23.pdf").Tables()[1][1]), @@([ "Cliente", "Condomínio Residencial Jardim das Paineiras" ]))
	Then("a cell spanning two rows repeats in both", @@(StzPdfQ("_data/golden_v24/g14.pdf").Tables()[1][3]), @@([ "101동", "2호기", "11월 23일(월)", "12월 4일(금)" ]))
	Then("an invoice item with its description on a second line is one row", @@(StzPdfQ("_data/golden_v24/g01.pdf").Tables()[1][2]), @@([ "1", "Perfect-bound annual report 64 pp, 170 gsm silk cover", "750", "£4.12", "£3,090.00" ]))
EndScenario()

# ---- the twenty-fifth round: Arabic headings and markers, foot lines, Demi faces (golden_v19, v25)

Scenario("Arabic headings set smaller than the body, Arabic dash markers, a long foot line, a Demi face")
	o = StzPdfQ("_data/golden_v25/h04.pdf")
	Then("a bold Arabic line at 0.85 of the body is a heading", StzFindFirst("أولا: الإجازة السنوية", "" + @@(o.Headings())) > 0, 1)
	Then("a letter and a dash is an Arabic list marker", StzFindFirst("أ- يستحق الموظف", "" + @@(o.ListItems())) > 0, 1)
	Then("a table's caption numbered in Arabic-Indic digits is a caption, not a heading", StzFindFirst("جدول (١)", "" + @@(o.Headings())), 0)
	Then("but a Hebrew month label is no heading", StzFindFirst("ינואר", "" + @@(StzPdfQ("_data/golden_v19/b10.pdf").Headings())), 0)
	Then("one small line at the page foot is its footer however long", StzFindFirst("Programme subject to change", "" + @@(StzPdfQ("_data/golden_v25/h17.pdf").Furniture())) > 0, 1)
	Then("a Demi face is bold: a section title in it is a heading", StzFindFirst("Section 1 — Personal details", "" + @@(StzPdfQ("_data/golden_v25/h15.pdf").Headings())) > 0, 1)
EndScenario()

# ---- the twenty-sixth round: a browser's synthetic bold, letterhead names, columns from the header (golden_v10, v11, v22, v26)

Scenario("A browser's synthetic bold, short bold letterhead names, and columns read off a header")
	Then("a heading in a browser's synthetic bold is a heading", StzFindFirst("I. Erlaubnis", "" + @@(StzPdfQ("_data/golden_v26/k03.pdf").Headings())) > 0, 1)
	o = StzPdfQ("_data/golden_v11/r18.pdf")
	Then("a variable font drawn as Type3 keeps its weights: its bold heading stays apart", StzFindFirst("Sprawozdanie z meczu 11. kolejki", "" + @@(o.Headings())) > 0, 1)
	Then("and its regular body is no heading", StzFindFirst("Mecz rozegrano", "" + @@(o.Headings())), 0)
	Then("a short bold name above the title is letterhead", StzFindFirst("Sahel Learning Partnership", "" + @@(StzPdfQ("_data/golden_v10/q23.pdf").Furniture())) > 0, 1)
	Then("but a sidebar heading beside the title stays a heading", StzFindFirst("Practical information", "" + @@(StzPdfQ("_data/golden_v22/e10.pdf").Headings())) > 0, 1)
	Then("a statement whose debit and credit never share a row takes its columns from the header", @@(StzPdfQ("_data/golden_v26/k06.pdf").Tables()[1][2]), @@([ "01/09", "01/09", "RECIBO COMUNIDAD DE PROPIETARIOS C/ Almendros 12 · Septiembre", "85,00", "", "3.327,58" ]))
EndScenario()

# ---- the twenty-seventh round: grids that keep their own header, letter-spaced CJK titles (golden_v26, v27)

Scenario("A grid with a bold header takes nothing from above, and a letter-spaced CJK title is one word")
	Then("a letter-spaced CJK title is one word", StzFindFirst("御見積書", "" + @@(StzPdfQ("_data/golden_v27/m05.pdf").Headings())) > 0, 1)
	Then("but its spaced letters are no heading of their own", StzFindFirst("御 見", "" + @@(StzPdfQ("_data/golden_v27/m05.pdf").Headings())), 0)
	aT = StzPdfQ("_data/golden_v26/k16.pdf").Tables()
	Then("a grid whose first row is a bold header starts at that header", aT[len(aT)][1][1], "Sample ref.")
EndScenario()

# ---- the twenty-eighth round: grids ruled between columns only, section rows without a rule, letterheads (golden_v28)

Scenario("A grid ruled between its columns only, and a letterhead address under its name")
	o = StzPdfQ("_data/golden_v28/n17.pdf")
	aT = o.Tables()
	Then("a grid with no rules between its items holds a row per item", @@(aT[2][2]), @@([ "1", "กระดาษถ่ายเอกสาร A4 80 แกรม", "60", "รีม", "125.00", "7,500.00" ]))
	Then("and its last item is a row of its own", aT[2][6][1], "5")
	Then("a letterhead's address under its name, beside the title, is letterhead", StzFindFirst("88/14 ถนนมิตรภาพ", "" + @@(o.Furniture())) > 0, 1)
EndScenario()

# ---- the twenty-ninth round: row-group labels, grids without outer rules, section rows in two columns, markers (golden_v29)

Scenario("Row-group labels repeat down their rows, and a grid without outer rules keeps its end columns")
	aT = StzPdfQ("_data/golden_v29/p19.pdf").Tables()
	Then("a label standing beside its three rows repeats in each", @@(aT[2][4]), @@([ "Mlimani", "Kituo Na. 3", "Ujenzi unaendelea", "—" ]))
	Then("and the next group takes its own label from its first row", aT[2][5][1], "Bondeni")
	Then("a total whose label spans the cells between repeats it", @@(aT[2][len(aT[2])]), @@([ "Jumla", "Jumla", "Jumla", "962" ]))
	aT = StzPdfQ("_data/golden_v29/p09.pdf").Tables()
	Then("a grid ruled between its columns only keeps the column outside its last rule", @@(aT[2][2]), @@([ "1", "안전", "통학로 보행자 안전펜스 설치", "180", "교통행정과" ]))
	aT = StzPdfQ("_data/golden_v29/p24.pdf").Tables()
	Then("a bold label filling a shaded row spans the two columns", @@(aT[1][2]), @@([ "Algemeen", "Algemeen" ]))
	Then("and the table holds all its sections in one", len(aT[1]), 15)
	Then("a cell wrapped under its row at a leading above one and a third stays in its row", @@(StzPdfQ("_data/golden_v29/p04.pdf").Tables()[2][3]), @@([ "LV-204", "Lizenzdatei abgelaufen", "Neue Lizenz im Kundenportal anfordern und nach /etc/lv- server/ kopieren." ]))
EndScenario()

Scenario("Ethiopic and Chinese list markers, and a two-line bold title")
	Then("an Ethiopic numeral and a full stop is a list marker", StzFindFirst("፩. የልጁን የክትባት ካርድ፤", "" + @@(StzPdfQ("_data/golden_v29/p23.pdf").ListItems())) > 0, 1)
	Then("and an Ethiopic letter and a bracket too", StzFindFirst("ሀ) የሰላም በር ጤና ጣቢያ", "" + @@(StzPdfQ("_data/golden_v29/p23.pdf").ListItems())) > 0, 1)
	Then("a Chinese number set against its text with no space is a list marker", StzFindFirst("1.本报告仅对所检样品负责。", "" + @@(StzPdfQ("_data/golden_v29/p07.pdf").ListItems())) > 0, 1)
	Then("a bold title of two lines, larger than the body, is a heading", StzFindFirst("АКТ № 47", "" + @@(StzPdfQ("_data/golden_v29/p10.pdf").Headings())) > 0, 1)
EndScenario()

# ---- the thirtieth round: right-to-left markers, flush-wrapped items, a three-rule table, justified lines (golden_v30)

Scenario("Markers set apart at the right, items wrapped flush with their marker, and a table of two ruled rows")
	Then("a right-to-left item's digit and stop, set apart from its text, head the item", StzFindFirst("١. تعبئة نموذج طلب الإجازة", "" + @@(StzPdfQ("_data/golden_v30/r05.pdf").ListItems())) > 0, 1)
	Then("and a bracketed reference number in Persian digits is a marker", StzFindFirst("[۲] آمار توصیفی با نرم", "" + @@(StzPdfQ("_data/golden_v30/r14.pdf").ListItems())) > 0, 1)
	Then("a Latin number and a bracket on a Hebrew line is a nested marker", StzFindFirst("1) בדיקה חודשית", "" + @@(StzPdfQ("_data/golden_v30/r06.pdf").ListItems())) > 0, 1)
	Then("a Georgian letter and a stop is a list marker", StzFindFirst("ბ. მონაწილეობა უფასოა.", "" + @@(StzPdfQ("_data/golden_v30/r16.pdf").ListItems())) > 0, 1)
	Then("a line wrapped flush with its marker joins the item while the item goes on", StzFindFirst("а) запрашивать у подразделений информацию, необходимую для организации закупок;", "" + @@(StzPdfQ("_data/golden_v30/r10.pdf").ListItems())) > 0, 1)
	aT = StzPdfQ("_data/golden_v30/r04.pdf").Tables()
	Then("a table of a header and two ruled rows joins the rows of its next page", len(aT[1]), 5)
	Then("and keeps the header once", aT[1][1][1], "Concepto")
	o = StzPdfQ("_data/golden_v30/r10.pdf")
	o = StzPdfQ("_data/golden_v30/r10.pdf")
	Then("a justified line, its words far apart, stays one line of its paragraph: the last sentence is whole", StzFindFirst("За ненадлежащее исполнение обязанностей он отвечает в порядке, установленном трудовым законодательством.", "" + @@(o.Paragraphs())) > 0, 1)
	Then("a title repeated as a small running header is still the title", StzFindFirst("智能温控器 TH-200 使用说明书", "" + @@(StzPdfQ("_data/golden_v30/r08.pdf").Headings())) > 0, 1)
	Then("a title letter-spaced with uneven gaps is one word", StzFindFirst("御見積書", "" + @@(StzPdfQ("_data/golden_v30/r07.pdf").Headings())) > 0, 1)
EndScenario()

# ---- the thirty-first round: full-width markers kept with their text, a table beside a list, diamond bullets (golden_v31)

Scenario("Markers set apart by a hanging indent keep their text, and a table beside a numbered list is read alone")
	Then("a full-width stop after an ASCII digit, set apart from its text, heads the item", StzFindFirst("1． 完成三栋楼的楼道照明改造。", "" + @@(StzPdfQ("_data/golden_v31/s05.pdf").ListItems())) > 0, 1)
	Then("an ordinal sign after a number is a marker, and its text stays with it", StzFindFirst("1° Atelier 1 : sécheresse et agriculture", "" + @@(StzPdfQ("_data/golden_v31/s10.pdf").ListItems())) > 0, 1)
	Then("a Devanagari letter and a stop is a marker", StzFindFirst("ख. उच्च कक्षाओं के लिए", "" + @@(StzPdfQ("_data/golden_v31/s08.pdf").ListItems())) > 0, 1)
	Then("a line wrapped to the left of its marker (the text hangs outside) joins the item", StzFindFirst("(i) walk the mean high-water line from the north marker to the south marker;", "" + @@(StzPdfQ("_data/golden_v31/s17.pdf").ListItems())) > 0, 1)
	Then("bullets drawn as turned squares are bullets", StzFindFirst("A change scanner that is about three times faster on large folders.", "" + @@(StzPdfQ("_data/golden_v31/s18.pdf").ListItems())) > 0, 1)
	aT = StzPdfQ("_data/golden_v31/s23.pdf").Tables()
	Then("the ingredients beside a numbered recipe are a table of their own", @@(aT[1][2]), @@([ "Carne macinata di manzo", "500 g" ]))
	Then("and hold all their rows, the ones past the last step too", len(aT[1]) >= 8, 1)
	aT = StzPdfQ("_data/golden_v31/s12.pdf").Tables()
	Then("a header whose cells wrap onto a bracketed second line is one row", aT[2][1][3], "SGK işçi payı (%14)")
	aT = StzPdfQ("_data/golden_v31/s24.pdf").Tables()
	Then("a grid opening with a section row takes the header above it", @@(aT[2][1]), @@([ "Item", "Condition", "Notes" ]))
	Then("a letterhead address with an e-mail under the name is letterhead", StzFindFirst("info@calamar-reformas.example", "" + @@(StzPdfQ("_data/golden_v31/s11.pdf").Furniture())) > 0, 1)
EndScenario()

# ---- the thirty-second round: tables in the columns of a two-column page, a panel above a header (golden_v32)

Scenario("A table in each column of a two-column page is read in its own column")
	aT = StzPdfQ("_data/golden_v32/t15.pdf").Tables()
	Then("the table in the left column is its own", @@(aT[1][2]), @@([ "Humid temperate", "17", "212", "38.4" ]))
	Then("and the one in the right column is another, with three columns", len(aT[2][1]), 3)
	aT = StzPdfQ("_data/golden_v4/g16.pdf").Tables()
	Then("but a table across both columns of such a page stays whole", len(aT[1][1]), 4)
	aT = StzPdfQ("_data/golden_v32/t13.pdf").Tables()
	Then("a key/value panel is cut from the header row of the table under it", len(aT[1]), 5)
	Then("and that table opens with its own header", @@(aT[2][1]), @@([ "Test", "Sonuç", "Birim", "Referans aralığı", "Durum" ]))
	Then("a kana letter and a full-width stop, with a phrase after it, is a list marker and no table", StzFindFirst("ア． 7月1日から相談窓口の受付時間を午前8時30分に変更すること。", "" + @@(StzPdfQ("_data/golden_v32/t04.pdf").ListItems())) > 0, 1)
EndScenario()

# ---- the thirty-third round: PDFs from producers other than Chrome (golden_v34: ReportLab, PyMuPDF, matplotlib, GDI)

Scenario("Bullets, check boxes, ToUnicode ranges and Type 3 codes as other producers write them")
	Then("the byte 127 of a WinAnsi font, which ReportLab uses for its bullet, is a bullet", StzFindFirst("• Bank transfer to sort code 00-00-00, account 00000000.", "" + @@(StzPdfQ("_data/golden_v34/x01.pdf").ListItems())) > 0, 1)
	Then("a stroked square before a line, a form's check box, is a bullet and each line is an item of its own", StzFindFirst("Medium plot (8 m by 5 m)", "" + @@(StzPdfQ("_data/golden_v34/x12.pdf").ListItems())) > 0, 1)
	Then("a ToUnicode range that runs over a byte boundary counts up as a whole", StzFindFirst("1. 운영 개요", "" + @@(StzPdfQ("_data/golden_v34/x17.pdf").Headings())) > 0, 1)
	aT = StzPdfQ("_data/golden_v34/x20.pdf").Tables()
	Then("a Type 3 font's codes are one byte whatever its ToUnicode codespace says", aT[1][2][4], "Parque da Serra")
	Then("a fixed-width Japanese face is not code", len(StzPdfQ("_data/golden_v34/x11.pdf").CodeBlocks()), 0)
	Then("a heading set only a little larger than the text under it, in a plain face, is a heading", StzFindFirst("Summary of findings", "" + @@(StzPdfQ("_data/golden_v34/x22.pdf").Headings())) > 0, 1)
	aT = StzPdfQ("_data/golden_v34/x14.pdf").Tables()
	Then("the running header does not hide a two-column paper's gutter: its table is read in its column", @@(aT[1][2]), @@([ "Finnish", "71.2", "88.9", "96.1" ]))
	Then("a no-break space is a space, so the marker of a right-to-left item is seen", StzFindFirst("א. אישור פרוטוקול הישיבה הקודמת", "" + @@(StzPdfQ("_data/golden_v34/x16.pdf").ListItems())) > 0, 1)
EndScenario()

# ---- the thirty-fourth round: bullets drawn as strokes, ASCII check boxes, Arabic marks as shaped by MuPDF (golden_v35)

Scenario("A dash stroke or a box drawn with lines is a bullet, and MuPDF's Arabic marks keep their letters")
	Then("a short stroke before a line, a dash bullet, makes the line an item", StzFindFirst("Tipos de variables y escalas de medida", "" + @@(StzPdfQ("_data/golden_v35/y13.pdf").ListItems())) > 0, 1)
	Then("a check box GDI draws as three or four straight lines makes a right-to-left line an item", StzFindFirst("בדיקת לחץ המים", "" + @@(StzPdfQ("_data/golden_v35/y10.pdf").ListItems())) > 0, 1)
	Then("a check box typed as [x] is a marker", StzFindFirst("[x] Smoke alarms tested in the hall and the kitchen", "" + @@(StzPdfQ("_data/golden_v35/y12.pdf").ListItems())) > 0, 1)
	Then("a spacing diacritic ligature (U+FC60) is the marks alone, with no space before them", StzFindFirst("المؤمَّن له", "" + @@(StzPdfQ("_data/golden_v35/y11.pdf").Tables())) > 0, 1)
	Then("a mark stands on the letter whose left edge it is set on, so a damma stays on its taa", StzFindFirst("ما لم تُذكر في ملحق خاص", "" + @@(StzPdfQ("_data/golden_v35/y11.pdf").Paragraphs())) > 0, 1)
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
