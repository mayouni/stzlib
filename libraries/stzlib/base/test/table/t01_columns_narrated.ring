load "../../stzBase.ring"
load "../_narrated.ring"

# stzTable defect family: helper calls to functions that were defined nowhere, names that did not match
# the parameter (R24), and column methods that raised or did nothing. Every scenario runs on a SQUARE
# 3 x 3 table and on a 4 x 2 table, because square data hid the faults that depend on rows <> columns.
#
#   3 x 3 :  a = 1 4 7    b = 2 5 8    c = 3 6 9
#   4 x 2 :  a = x z x r  b = y w q y

Scenario("The helper that checks a list of positions and names exists")
	Given("a 3 x 3 table")
	Then("a list mixing a position and a name is accepted", Does("o.AreColNamesOrNumbers([ 1, :b ])"), "1")
	Then("an unknown name in the mix is refused, not raised", Does("o.AreColNamesOrNumbers([ 1, :zz ])"), "0")
	Then("a position past the last column is refused", Does("o.AreColNamesOrNumbers([ 1, 9 ])"), "0")
	Then("the same on the 4 x 2 table", Does("o4.AreColNamesOrNumbers([ :a, 2 ])"), "1")
	Then("the position and name lists convert to names", Does("o.TheseColsToColNames([ 1, :c ])"), '[ "a", "c" ]')
	Then("and to positions", Does("o.TheseColsToColNumbers([ 1, :c ])"), "[ 1, 3 ]")
	Then("on the 4 x 2 table the positions too", Does("o4.TheseColsToColNumbers([ :b, 1 ])"), "[ 2, 1 ]")
	Then("CellsInCols reads columns given as a position and a name",
		Does("o.CellsInCols([ 1, :c ])"), "[ 1, 4, 7, 3, 6, 9 ]")
	Then("CellsInCols on 4 x 2", Does("o4.CellsInCols([ :b, 1 ])"), '[ "y", "w", "q", "y", "x", "z", "x", "r" ]')
EndScenario()

Scenario("Keeping only the given columns, by name or by position")
	Given("RemoveAllColsOtherThan and its three spellings, and the positional family")
	Then("the 3 x 3 table keeps b and c", After("o.RemoveAllColsOtherThan([ :b, :c ])", "o.ColNames()"), '[ "b", "c" ]')
	Then("RemoveColsOtherThan keeps a", After("o.RemoveColsOtherThan([ 1 ])", "o.ColNames()"), '[ "a" ]')
	Then("RemoveAllColumnsOtherThan keeps by position and name mixed",
		After("o.RemoveAllColumnsOtherThan([ 3, :a ])", "o.ColNames()"), '[ "a", "c" ]')
	Then("RemoveColumnsOtherThan on 4 x 2 keeps b with its four cells",
		After("o4.RemoveColumnsOtherThan([ :b ])", "o4.Content()"), '[ [ "b", [ "y", "w", "q", "y" ] ] ]')

	aNames = [ "RemoveAllColsExceptAt", "RemoveColsExceptPositions", "RemoveColumnsExceptPositions",
		"RemoveAllColsExceptPositions", "RemoveAllColumnsExceptPositions", "RemoveColsExceptAt",
		"RemoveAllColsOtherThanPositions", "RemoveColsOtherThanPositions", "RemoveAllColumnsExceptAt",
		"RemoveColumnsExceptAt", "RemoveAllColumnsOtherThanPositions", "RemoveColumnsOtherThanPositions" ]
	nOk3 = 0
	nOk4 = 0
	for i = 1 to len(aNames)
		if After("o." + aNames[i] + "([ 2 ])", "o.ColNames()") = '[ "b" ]'
			nOk3++
		ok
		if After("o4." + aNames[i] + "([ 1 ])", "o4.Col(:a)") = '[ "x", "z", "x", "r" ]'
			nOk4++
		ok
	next
	Then("the twelve positional spellings keep column 2 of the 3 x 3 table", nOk3, 12)
	Then("and column 1 of the 4 x 2 table", nOk4, 12)
EndScenario()

Scenario("Removing the columns at the given positions")
	Given("RemoveColumnsAt and its three spellings")
	Then("positions 1 and 3 leave b", After("o.RemoveColumnsAt([ 1, 3 ])", "o.ColNames()"), '[ "b" ]')
	Then("the order and duplicates of the positions do not matter",
		After("o.RemoveColsAt([ 3, 1, 3 ])", "o.ColNames()"), '[ "b" ]')
	Then("RemoveNthCols works", After("o.RemoveNthCols([ 2 ])", "o.ColNames()"), '[ "a", "c" ]')
	Then("RemoveNthColumns on 4 x 2 keeps the second column whole",
		After("o4.RemoveNthColumns([ 1 ])", "o4.Content()"), '[ [ "b", [ "y", "w", "q", "y" ] ] ]')
	Then("a position past the last column is ignored", After("o.RemoveColumnsAt([ 2, 9 ])", "o.ColNames()"), '[ "a", "c" ]')
	Then("the engine copy follows the removal (RemoveNthCol marks it stale)",
		After("h0 = o.EngineHandle()" + nl + "o.RemoveNthCol(1)" + nl + "h = o.EngineHandle()", "@@(StzEngineTableContent(h)) = @@(o.Content())"), "1")
EndScenario()

Scenario("Renaming columns")
	Given("RenameCol, which RenameCols called and which did not exist")
	Then("a column is renamed by name", After("o.RenameCol(:b, 'beta')", "o.ColNames()"), '[ "a", "beta", "c" ]')
	Then("by position", After("o.RenameCol(3, 'gamma')", "o.ColNames()"), '[ "a", "b", "gamma" ]')
	Then("the keyword :Last names the last column", After("o4.RenameCol(:Last, 'omega')", "o4.ColNames()"), '[ "a", "omega" ]')
	Then("the keyword :First names the first column", After("o4.RenameCol(:First, 'alpha')", "o4.ColNames()"), '[ "alpha", "b" ]')
	Then("the misspelt name still works", After("o.RenanmeCol(:a, 'z')", "o.ColNames()"), '[ "z", "b", "c" ]')
	Then("RenameCols takes name = new name pairs", After("o.RenameCols([ :a = 'x', :c = 'z' ])", "o.ColNames()"), '[ "x", "b", "z" ]')
	Then("the cells go with the renamed column", After("o4.RenameCols([ :b = 'q' ])", "o4.Col(:q)"), '[ "y", "w", "q", "y" ]')
	Then("RenameLastCol", After("o.RenameLastCol('last')", "o.ColNames()"), '[ "a", "b", "last" ]')
	Then("RenameNthCol accepts :Last", After("o4.RenameNthCol(:Last, 'l')", "o4.ColNames()"), '[ "a", "l" ]')
	Then("RenameNthCol past the last column raises", After("o4.RenameNthCol(3, 'l')", "o4.ColNames()"), "RAISES")
	Then("RenameNthCols names several columns by position",
		After("o.RenameNthCols([ 1, 3 ], [ 'p', 'q' ])", "o.ColNames()"), '[ "p", "b", "q" ]')
	Then("RemnameNthCols is the same", After("o.RemnameNthCols([ 2 ], [ 'm' ])", "o.ColNames()"), '[ "a", "m", "c" ]')
	Then("a different count of positions and names raises", After("o.RenameNthCols([ 1, 2 ], [ 'p' ])", "o.ColNames()"), "RAISES")
	Then("the engine copy follows the rename",
		After("h0 = o.EngineHandle()" + nl + "o.RenameCol(1, 'q')" + nl + "h = o.EngineHandle()", "@@(StzEngineTableContent(h)) = @@(o.Content())"), "1")
EndScenario()

Scenario("Cells, positions and names")
	Given("a 3 x 3 and a 4 x 2 table")
	Then("CellAndPosition pairs a cell with its [ column, row ]", Does("o4.CellAndPosition(2, 3)"), '[ "q", [ 2, 3 ] ]')
	Then("CellAndItsPosition too", Does("o.CellAndItsPosition(3, 2)"), "[ 6, [ 3, 2 ] ]")
	Then("Cells lists every cell row by row (3 x 3)", Does("o.Cells()"), "[ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]")
	Then("Cells lists every cell row by row (4 x 2)", Does("o4.Cells()"), '[ "x", "y", "z", "w", "x", "q", "r", "y" ]')
	Then("PositionsAndTheseCells pairs each given position with its own cell",
		Does("o4.PositionsAndTheseCells([ [ 1, 1 ], [ 2, 3 ] ])"), '[ [ [ 1, 1 ], "x" ], [ [ 2, 3 ], "q" ] ]')
	Then("CellsInRowNAndTheirPositions", Does("o4.CellsInRowNAndTheirPositions(3)"), '[ [ "x", [ 1, 3 ] ], [ "q", [ 2, 3 ] ] ]')
	Then("CellsAndPositionsInNthRow", Does("o4.CellsAndPositionsInNthRow(4)"), '[ [ "r", [ 1, 4 ] ], [ "y", [ 2, 4 ] ] ]')
	Then("CellsInNthRowAndTheirPositions on the square table", Does("o.CellsInNthRowAndTheirPositions(2)"),
		"[ [ 4, [ 1, 2 ] ], [ 5, [ 2, 2 ] ], [ 6, [ 3, 2 ] ] ]")
	Then("ContainsColumns accepts [ name, cells ] pairs", Does("o.ContainsColumns([ [ 'a', [ 1, 4, 7 ] ], [ 'c', [ 3, 6, 9 ] ] ])"), "1")
	Then("and refuses a column with other cells", Does("o.ContainsTheseColumns([ [ 'a', [ 1, 4, 8 ] ] ])"), "0")
	Then("TheseColNames gives the names in ascending position", Does("o.TheseColNames([ 3, 1 ])"), '[ "a", "c" ]')
	Then("TheseColNames on 4 x 2", Does("o4.TheseColNames([ 2 ])"), '[ "b" ]')
	Then("ColNamesToNumbers answers 0 for an unknown name", Does("o.ColNamesToNumbers([ :c, :a, :zz ])"), "[ 3, 1, 0 ]")
	Then("its misspelt name still answers", Does("o.cColNamesToNumbers([ :b ])"), "[ 2 ]")
	Then("and a plural spelling", Does("o4.ColumnNamesToNumbers([ :b, :a ])"), "[ 2, 1 ]")
EndScenario()

Scenario("Finding columns")
	Given("the finders that excluded the wrong things")
	Then("FindColsExceptAt takes a list of positions", Does("o.FindColsExceptAt([ 1 ])"), "[ 2, 3 ]")
	Then("FindColsExcept takes positions", Does("o.FindColsExcept([ 1, 3 ])"), "[ 2 ]")
	Then("FindColsExcept takes names", Does("o4.FindColsExcept([ :a ])"), "[ 2 ]")
	Then("FindColsByValue finds the columns equal to any of the given lists",
		Does("o.FindColsByValue([ [ 2, 5, 8 ], [ 3, 6, 9 ] ])"), "[ 2, 3 ]")
	Then("on the 4 x 2 table", Does("o4.FindColsByValue([ [ 'y', 'w', 'q', 'y' ] ])"), "[ 2 ]")
EndScenario()

Summary()

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
