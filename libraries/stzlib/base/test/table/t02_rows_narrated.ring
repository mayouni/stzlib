load "../../stzBase.ring"
load "../_narrated.ring"

# stzTable defect family: rows. FindRow compared two lists with = (never true), so no row was ever
# found by its content; ContainsRow tested the row against NumberOfRows instead of NumberOfCols and
# answered right only on a table with as many rows as columns; the Remove*/Insert* families sorted
# their positions through a chain Ring cannot run; EraseSection called SectionAsPositions with no
# corners, and SectionAsPositions read a different block than Section. Each scenario runs on a SQUARE
# 3 x 3 table and on a 4 x 2 table.
#
#   3 x 3 :  1 2 3 / 4 5 6 / 7 8 9
#   4 x 2 :  x y / z w / x q / r y

Scenario("Finding a row by its content")
	Given("a 4 x 2 table, a square table and a table with a repeated row")
	Tn("FindRow gives the position of a row", Does("o4.FindRow([ 'x', 'q' ])"), "[ 3 ]")
	Tn("on the square table too", Does("o.FindRow([ 4, 5, 6 ])"), "[ 2 ]")
	Tn("a row that is not there gives [ ]", Does("o4.FindRow([ 'x', 'zz' ])"), "[ ]")
	Tn("a row of the wrong length gives [ ]", Does("o4.FindRow([ 'x' ])"), "[ ]")
	Tn("the default is case-sensitive", Does("o4.FindRow([ 'Z', 'W' ])"), "[ ]")
	Tn("FindRowCS with the flag off ignores case", Does("o4.FindRowCS([ 'Z', 'W' ], 0)"), "[ 2 ]")
	Tn("FindRows gives the positions of several rows", Does("o4.FindRows([ [ 'x', 'y' ], [ 'r', 'y' ] ])"), "[ 1, 4 ]")
	Tn("FindTheseRows is the same question", Does("o4.FindTheseRows([ [ 'x', 'y' ], [ 'r', 'y' ] ])"), "[ 1, 4 ]")
	Tn("FindNthRow takes the occurrence first",
		Does("FindNthOfRepeated(2)"), "3")
	Tn("the first occurrence", Does("FindNthOfRepeated(1)"), "1")
	Tn("an occurrence that does not exist gives 0", Does("o4.FindNthRow(2, [ 'x', 'q' ])"), "0")
	Tn("TheseRowsToRowsNumbers looks rows up, 0 for a row that is not there",
		Does("o4.TheseRowsToRowsNumbers([ [ 'r', 'y' ], [ 'x', 'y' ], [ 'no', 'no' ] ])"), "[ 4, 1, 0 ]")
	Tn("RowsToRowNumbers is the same", Does("o.RowsToRowNumbers([ [ 7, 8, 9 ] ])"), "[ 3 ]")
EndScenario()

Scenario("Containing a row: the length test is the number of columns")
	Given("tables whose number of rows differs from their number of columns")
	Tn("a 4 x 2 table contains its second row", Does("o4.ContainsRow([ 'z', 'w' ])"), "1")
	Tn("a 4 x 2 table does not contain a row of three cells", Does("o4.ContainsRow([ 'z', 'w', 'q' ])"), "0")
	Tn("nor a row of one cell", Does("o4.ContainsRow([ 'z' ])"), "0")
	Tn("nor a row with another content", Does("o4.ContainsRow([ 'z', 'q' ])"), "0")
	Tn("the square table still contains its row", Does("o.ContainsRow([ 4, 5, 6 ])"), "1")
	Tn("the case flag is honoured", Does("o4.ContainsRowCS([ 'Z', 'W' ], 0)"), "1")
	Tn("and by default case counts", Does("o4.ContainsRow([ 'Z', 'W' ])"), "0")
	Tn("ContainsRows needs every row", Does("o4.ContainsRows([ [ 'x', 'y' ], [ 'r', 'y' ] ])"), "1")
	Tn("one missing row makes it FALSE", Does("o4.ContainsRows([ [ 'x', 'y' ], [ 'r', 'zz' ] ])"), "0")
	Tn("ContainsTheseRows on the square table", Does("o.ContainsTheseRows([ [ 1, 2, 3 ], [ 7, 8, 9 ] ])"), "1")
EndScenario()

Scenario("Removing rows by position")
	Given("RemoveNthRows and the names that forward to it")
	Tn("RemoveNthRows on the square table", After("o.RemoveNthRows([ 1, 3 ])", "o.Rows()"), "[ [ 4, 5, 6 ] ]")
	Tn("RemoveNthRows on 4 x 2", After("o4.RemoveNthRows([ 2, 4 ])", "o4.Rows()"), "[ [ 'x', 'y' ], [ 'x', 'q' ] ]")
	Tn("the order and duplicates of the positions do not matter",
		After("o4.RemoveRowsAt([ 4, 1, 4 ])", "o4.Rows()"), "[ [ 'z', 'w' ], [ 'x', 'q' ] ]")
	Tn("a position outside the table is ignored", After("o4.RemoveRowsAt([ 2, 9 ])", "o4.Rows()"),
		"[ [ 'x', 'y' ], [ 'x', 'q' ], [ 'r', 'y' ] ]")
	Tn("every column loses the same rows", After("o4.RemoveNthRows([ 1, 2 ])", "o4.NumberOfRows() = len(o4.Col(1)) and len(o4.Col(2)) = 2"), "1")
	Tn("RemoveRows with positions", After("o4.RemoveRows([ 1, 4 ])", "o4.Rows()"), "[ [ 'z', 'w' ], [ 'x', 'q' ] ]")
	Tn("RemoveRows with the rows themselves",
		After("o4.RemoveRows([ [ 'x', 'y' ], [ 'r', 'y' ] ])", "o4.Rows()"), "[ [ 'z', 'w' ], [ 'x', 'q' ] ]")
	Tn("RemoveRows with rows on the square table", After("o.RemoveRows([ [ 4, 5, 6 ] ])", "o.Rows()"), "[ [ 1, 2, 3 ], [ 7, 8, 9 ] ]")
	Tn("RemoveRow with the cells of a row", After("o4.RemoveRow([ 'x', 'q' ])", "o4.Rows()"),
		"[ [ 'x', 'y' ], [ 'z', 'w' ], [ 'r', 'y' ] ]")
	Tn("RemoveRow with a row that is not there raises", After("o4.RemoveRow([ 'no', 'no' ])", "o4.Rows()"), "RAISES")
	Tn("RemoveRow with a position still works", After("o4.RemoveRow(2)", "o4.NumberOfRows()"), "3")
EndScenario()

Scenario("Keeping only some rows")
	Given("RemoveAllRowsExceptAt, RemoveAllRowsExcept and their spellings")
	Tn("by position on the square table", After("o.RemoveAllRowsExceptAt([ 2 ])", "o.Rows()"), "[ [ 4, 5, 6 ] ]")
	Tn("by position on 4 x 2", After("o4.RemoveAllRowsExceptAt([ 1, 4 ])", "o4.Rows()"), "[ [ 'x', 'y' ], [ 'r', 'y' ] ]")
	Tn("RemoveRowsExceptAt", After("o4.RemoveRowsExceptAt([ 3 ])", "o4.Rows()"), "[ [ 'x', 'q' ] ]")
	Tn("RemoveAllRowsOtherThanPositions", After("o4.RemoveAllRowsOtherThanPositions([ 2, 3 ])", "o4.Rows()"), "[ [ 'z', 'w' ], [ 'x', 'q' ] ]")
	Tn("RemoveRowsOtherThanPositions", After("o.RemoveRowsOtherThanPositions([ 1, 3 ])", "o.Rows()"), "[ [ 1, 2, 3 ], [ 7, 8, 9 ] ]")
	Tn("RemoveAllRowsExcept with positions keeps those rows", After("o4.RemoveAllRowsExcept([ 2 ])", "o4.Rows()"), "[ [ 'z', 'w' ] ]")
	Tn("RemoveAllRowsExcept with rows keeps those rows", After("o4.RemoveAllRowsExcept([ [ 'z', 'w' ] ])", "o4.Rows()"), "[ [ 'z', 'w' ] ]")
	Tn("RemoveRowsExcept", After("o.RemoveRowsExcept([ 3 ])", "o.Rows()"), "[ [ 7, 8, 9 ] ]")
	Tn("RemoveAllRowsOtherThan", After("o4.RemoveAllRowsOtherThan([ [ 'r', 'y' ], [ 'x', 'y' ] ])", "o4.Rows()"), "[ [ 'x', 'y' ], [ 'r', 'y' ] ]")
	Tn("RemoveRowsOtherThan", After("o4.RemoveRowsOtherThan([ 1 ])", "o4.Rows()"), "[ [ 'x', 'y' ] ]")
EndScenario()

Scenario("Inserting a row at several positions")
	Given("InsertRowAtPositions and its two spellings")
	Tn("one row at each position of a 4 x 2 table",
		After("o4.InsertRowAtPositions([ 1, 3 ], [ 'n', 'n' ])", "o4.Rows()"),
		"[ [ 'n', 'n' ], [ 'x', 'y' ], [ 'z', 'w' ], [ 'n', 'n' ], [ 'x', 'q' ], [ 'r', 'y' ] ]")
	Tn("InsertRows on the square table", After("o.InsertRows([ 2 ], [ 0, 0, 0 ])", "o.Rows()"),
		"[ [ 1, 2, 3 ], [ 0, 0, 0 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("InsertRowsAt with the positions out of order", After("o.InsertRowsAt([ 3, 1 ], [ 0, 0, 0 ])", "o.NumberOfRows()"), "5")
	Tn("the new rows are rows 1 and 4 of the result, as the positions were given",
		After("o.InsertRowsAt([ 3, 1 ], [ 0, 0, 0 ])", "@@(o.Row(1)) = '[ 0, 0, 0 ]' and @@(o.Row(4)) = '[ 0, 0, 0 ]'"), "1")
EndScenario()

Scenario("Sections: the block between two corners")
	Given("SectionAsPositions, which read another block than Section")
	Tn("on 4 x 2, rows 2 to 4 of both columns, row by row", Does("o4.SectionAsPositions([ 1, 2 ], [ 2, 4 ])"),
		"[ [ 1, 2 ], [ 2, 2 ], [ 1, 3 ], [ 2, 3 ], [ 1, 4 ], [ 2, 4 ] ]")
	Tn("on the square table, the lower right block", Does("o.SectionAsPositions([ 2, 1 ], [ 3, 3 ])"),
		"[ [ 2, 1 ], [ 3, 1 ], [ 2, 2 ], [ 3, 2 ], [ 2, 3 ], [ 3, 3 ] ]")
	Tn("one column", Does("o.SectionAsPositions([ 2, 1 ], [ 2, 3 ])"), "[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ] ]")
	Tn("SectionZ pairs each position with the cell Section gives", Does("o4.SectionZ([ 2, 2 ], [ 2, 3 ])"),
		'[ [ [ 2, 2 ], "w" ], [ [ 2, 3 ], "q" ] ]')
	Tn("the positions match the cells of Section, one for one",
		Does("len(o.SectionAsPositions([ 2, 1 ], [ 3, 3 ])) = len(o.Section([ 2, 1 ], [ 3, 3 ]))"), "1")
	Tn("EraseSection empties the block (square table)", After("o.EraseSection([ 1, 2 ], [ 2, 3 ])", "o.Rows()"),
		'[ [ 1, 2, 3 ], [ "", "", 6 ], [ "", "", 9 ] ]')
	Tn("EraseSection on 4 x 2", After("o4.EraseSection([ 2, 2 ], [ 2, 3 ])", "o4.Rows()"),
		'[ [ "x", "y" ], [ "z", "" ], [ "x", "" ], [ "r", "y" ] ]')
EndScenario()

Summary()

func Tn(cText, xActual, xExpected)
	Then(cText, xActual, substr(xExpected, "'", char(34)))

func FindNthOfRepeated(n)
	oRep = new stzTable([ [ :a, :b ], [ 1, 2 ], [ 3, 4 ], [ 1, 2 ] ])
	return oRep.FindNthRow(n, [ 1, 2 ])

func M3()
	return new stzTable([ [ :A, :B, :C ], [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ])

func M4()
	return new stzTable([ [ :A, :B ], [ "x", "y" ], [ "z", "w" ], [ "x", "q" ], [ "r", "y" ] ])

func Does(cCode)
	# the result of the expression, written; or "RAISES" when it raises
	cOut = ""
	try
		eval("o = M3()" + nl + "o4 = M4()" + nl + "xr = " + cCode + nl + "cOut = @@(xr)")
	catch
		cOut = "RAISES"
	done
	return cOut

func After(cCode, cShow)
	# run a mutator on a fresh 3 x 3 table (o) and a fresh 4 x 2 table (o4), then write what cShow gives
	cOut = ""
	try
		eval("o = M3()" + nl + "o4 = M4()" + nl + cCode + nl + "cOut = @@(" + cShow + ")")
	catch
		cOut = "RAISES"
	done
	return cOut
