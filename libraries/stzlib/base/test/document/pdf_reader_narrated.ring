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
