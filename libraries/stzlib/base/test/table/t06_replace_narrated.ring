load "../../stzBase.ring"
load "../_narrated.ring"
load "_tblfix.ring"

# stzTable defect family: replacing. A parameter named differently from the body (R24), spellings that
# called ReplaceCell with the arguments of ReplaceAll (R19), spellings that handed a list of values to the
# method that takes one value (every cell received the whole list), and a whole group of methods that only
# raised "not yet implemented": several values by one value, several by several, a text inside cells, a
# text inside a section, several columns by several lists, and SectionToRange and Range. Each scenario runs
# on a SQUARE 3 x 3 table, on a 4 x 2 table and on the people table.
#
#   3 x 3 :  1 2 3 / 4 5 6 / 7 8 9
#   4 x 2 :  x y / z w / x q / r y
#   ow    :  name = Andy Ali Alia   job = Maestro Abraham Ali

Scenario("Replacing the cells that equal a value")
	Given("the spellings whose parameter was not the one the body used")
	Tn("ReplaceOccurrencesOfCellByValue on the square table", After("o.ReplaceOccurrencesOfCellByValue(5, 50)", "o.Rows()"),
		"[ [ 1, 2, 3 ], [ 4, 50, 6 ], [ 7, 8, 9 ] ]")
	Tn("on the 4 x 2 table, both x are replaced", After("o4.ReplaceOccurrencesOfCellByValue('x', 'X')", "o4.Col(:a)"), '[ "X", "z", "X", "r" ]')
	Tn("ReplaceByValueOccurrencesOfCellBy", After("o4.ReplaceByValueOccurrencesOfCellBy('y', 'Y')", "o4.Col(:b)"), '[ "Y", "w", "q", "Y" ]')
	Tn("the CS form without case", After("o4.ReplaceOccurrencesOfCellByValueCS('X', 'k', 0)", "o4.Col(:a)"), '[ "k", "z", "k", "r" ]')
	Tn("the CS form with case leaves other cases alone", After("o4.ReplaceOccurrencesOfCellByValueCS('X', 'k', 1)", "o4.Col(:a)"), '[ "x", "z", "x", "r" ]')
	Tn("ReplaceByValueOccurrencesOfCellByCS", After("o4.ReplaceByValueOccurrencesOfCellByCS('Y', 'k', 0)", "o4.Col(:b)"), '[ "k", "w", "q", "k" ]')
EndScenario()

Scenario("Several values by one value, and several by several")
	Given("the methods that raised Function not yet implemented")
	Tn("ReplaceManyCellsByValue on the 4 x 2 table", After("o4.ReplaceManyCellsByValue([ 'x', 'y' ], '*')", "o4.Rows()"),
		"[ [ '*', '*' ], [ 'z', 'w' ], [ '*', 'q' ], [ 'r', '*' ] ]")
	Tn("on the square table, with numbers", After("o.ReplaceManyCellsByValue([ 2, 8 ], 0)", "o.Rows()"), "[ [ 1, 0, 3 ], [ 4, 5, 6 ], [ 7, 0, 9 ] ]")
	Tn("the CS form without case", After("o4.ReplaceManyCellsByValueCS([ 'X' ], '*', 0)", "o4.Col(:a)"), '[ "*", "z", "*", "r" ]')
	aMany = [ "ReplaceCellsByValue", "ReplaceByValueManyCells", "ReplaceByValueCells" ]
	nOk = 0
	for i = 1 to len(aMany)
		if After("o4." + aMany[i] + "([ 'x' ], '*')", "o4.Col(:a)") = '[ "*", "z", "*", "r" ]'
			nOk++
		ok
	next
	Then("the three other spellings do the same", nOk, 3)

	Tn("ReplaceManyCellsByValueByMany pairs the values", After("o4.ReplaceManyCellsByValueByMany([ 'x', 'y' ], [ 'A', 'B' ])", "o4.Rows()"),
		"[ [ 'A', 'B' ], [ 'z', 'w' ], [ 'A', 'q' ], [ 'r', 'B' ] ]")
	Tn("a swap does not cascade: the new z is not replaced again",
		After("o4.ReplaceManyCellsByValueByMany([ 'x', 'z' ], [ 'z', 'x' ])", "o4.Col(:a)"), '[ "z", "x", "z", "r" ]')
	Tn("on the square table", After("o.ReplaceManyCellsByValueByMany([ 1, 9 ], [ 9, 1 ])", "o.Rows()"), "[ [ 9, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 1 ] ]")
	aBy = [ "ReplaceCellsByValueByMany", "ReplaceByValueManyCellsByMany", "ReplaceByValueCellsByMany" ]
	nOk = 0
	for i = 1 to len(aBy)
		if After("o4." + aBy[i] + "([ 'x', 'r' ], [ 'A', 'B' ])", "o4.Col(:a)") = '[ "A", "z", "A", "B" ]'
			nOk++
		ok
	next
	Then("the three other spellings do the same", nOk, 3)
	Tn("the XT form uses the new values again from the first", After("o4.ReplaceManyCellsByValueByManyXT([ 'x', 'z', 'r' ], [ '1', '2' ])", "o4.Col(:a)"),
		'[ "1", "2", "1", "1" ]')
	Tn("ReplaceCellsByValueByManyXT", After("o4.ReplaceCellsByValueByManyXT([ 'x', 'z', 'r' ], [ '1', '2' ])", "o4.Col(:a)"), '[ "1", "2", "1", "1" ]')
EndScenario()

Scenario("Replacing by positions, one value each")
	Given("the spellings that gave every cell the whole list")
	Tn("ReplaceEachCellOfTheseByPositionsByMany", After("o4.ReplaceEachCellOfTheseByPositionsByMany([ [ 1, 1 ], [ 2, 1 ] ], [ 'A', 'B' ])", "o4.Row(1)"), '[ "A", "B" ]')
	Tn("ReplaceByPositionsEachCellOfTheseByMany", After("o.ReplaceByPositionsEachCellOfTheseByMany([ [ 1, 1 ], [ 3, 3 ] ], [ 0, 99 ])", "o.Rows()"),
		"[ [ 0, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 99 ] ]")
	Tn("the XT spelling, with as many values as cells",
		After("o4.ReplaceEachCellOfTheseByPositionsByManyXT([ [ 1, 1 ], [ 2, 1 ] ], [ 'A', 'B' ])", "o4.Row(1)"), '[ "A", "B" ]')
	Tn("the other XT spelling", After("o.ReplaceByPositionsEachCellOfTheseByManyXT([ [ 1, 1 ], [ 3, 3 ] ], [ 0, 99 ])", "o.Row(3)"), "[ 7, 8, 99 ]")
EndScenario()

Scenario("A text inside cells")
	Given("the people table, whose names are Andy Ali Alia")
	Tn("ReplaceInCell changes the text inside one cell", After("ow.ReplaceInCell(1, 3, 'li', 'LI')", "ow.Col(:name)"), '[ "Andy", "Ali", "ALIa" ]')
	Tn("the CS form without case", After("ow.ReplaceInCellCS(1, 3, 'LI', 'x', 0)", "ow.Col(:name)"), '[ "Andy", "Ali", "Axa" ]')
	Tn("with case, a text of another case is not found", After("ow.ReplaceInCellCS(1, 3, 'LI', 'x', 1)", "ow.Col(:name)"), '[ "Andy", "Ali", "Alia" ]')
	Tn("a cell that is a number is left as it is", After("o.ReplaceInCell(1, 1, '1', '9')", "o.Cell(1, 1)"), "1")
	Tn("ReplaceInCells works on the cells it is given", After("ow.ReplaceInCells([ [ 1, 2 ], [ 2, 3 ] ], 'Ali', 'Zed')", "ow.Content()"),
		'[ [ "name", [ "Andy", "Zed", "Alia" ] ], [ "job", [ "Maestro", "Abraham", "Zed" ] ] ]')
	Tn("ReplaceInCellsByMany applies each text in turn", After("ow.ReplaceInCellsByMany([ [ 1, 2 ], [ 1, 3 ] ], [ 'A', 'l' ], '_')", "ow.Col(:name)"),
		'[ "Andy", "__i", "__ia" ]')
	Tn("ReplaceInSection works on the block between two corners", After("ow.ReplaceInSection([ 1, 1 ], [ 1, 3 ], 'A', 'a')", "ow.Col(:name)"),
		'[ "andy", "ali", "alia" ]')
	Tn("and leaves the other column alone", After("ow.ReplaceInSection([ 1, 1 ], [ 1, 3 ], 'A', 'a')", "ow.Col(:job)"), '[ "Maestro", "Abraham", "Ali" ]')
	Tn("ReplaceInSectionByMany", After("ow.ReplaceInSectionByMany([ 1, 1 ], [ 1, 3 ], [ 'A', 'n' ], '.')", "ow.Col(:name)"), '[ "..dy", ".li", ".lia" ]')
	Tn("ReplaceInSections works on several sections",
		After("ow.ReplaceInSections([ [ [ 1, 2 ], [ 1, 2 ] ], [ [ 2, 3 ], [ 2, 3 ] ] ], 'Ali', 'X', 1)", "ow.Content()"),
		'RAISES')
	Tn("ReplaceInSectionsCS, a section being a pair of corners",
		After("ow.ReplaceInSectionsCS([ [ [ 1, 2 ], [ 1, 2 ] ], [ [ 2, 3 ], [ 2, 3 ] ] ], 'Ali', 'X', 1)", "ow.Content()"),
		'[ [ "name", [ "Andy", "X", "Alia" ] ], [ "job", [ "Maestro", "Abraham", "X" ] ] ]')
	Tn("ReplaceInSections, without the case flag",
		After("ow.ReplaceInSections([ [ [ 1, 2 ], [ 1, 2 ] ], [ [ 2, 3 ], [ 2, 3 ] ] ], 'Ali', 'X')", "ow.Col(:job)"), '[ "Maestro", "Abraham", "X" ]')
	Tn("ReplaceInSectionsByMany", After("ow.ReplaceInSectionsByMany([ [ [ 1, 2 ], [ 1, 2 ] ], [ [ 2, 3 ], [ 2, 3 ] ] ], [ 'A', 'l' ], '-')", "ow.Col(:job)"),
		'[ "Maestro", "Abraham", "--i" ]')
EndScenario()

Scenario("Several columns replaced by several lists")
	Given("the six spellings that raised Unsupported feature in this release")
	Tn("ReplaceTheseColsByMany on the square table", After("o.ReplaceTheseColsByMany([ :a, :c ], [ [ 10, 11, 12 ], [ 20, 21, 22 ] ])", "o.Cols()"),
		"[ [ 10, 11, 12 ], [ 2, 5, 8 ], [ 20, 21, 22 ] ]")
	Tn("by position on the 4 x 2 table", After("o4.ReplaceTheseColsByMany([ 2 ], [ [ '1', '2', '3', '4' ] ])", "o4.Col(:b)"), '[ "1", "2", "3", "4" ]')
	aCols = [ "ReplaceAllColsByMany", "ReplaceAllColumsByMany", "ReplaceTheseColumnsByMany", "ReplaceColsByMany", "ReplaceColumnsByMany" ]
	nOk = 0
	for i = 1 to len(aCols)
		if After("o." + aCols[i] + "([ 1, :b ], [ [ 0, 0, 0 ], [ 9, 9, 9 ] ])", "o.Cols()") = "[ [ 0, 0, 0 ], [ 9, 9, 9 ], [ 3, 6, 9 ] ]"
			nOk++
		ok
	next
	Then("the five other spellings do the same", nOk, 5)
	Tn("an unknown column raises", After("o.ReplaceTheseColsByMany([ :zz ], [ [ 0, 0, 0 ] ])", "o.Cols()"), "RAISES")
	Tn("the new name is given by :With", After("o.ReplaceTheseColsByMany([ 2 ], [ :With, [ [ 7, 7, 7 ] ] ])", "o.Col(:b)"), "[ 7, 7, 7 ]")
EndScenario()

Scenario("Cells of rows, ReplaceAll's spellings, the nth, first and last")
	Given("the methods that called ReplaceCell with two arguments")
	Tn("ReplaceCellsInTheseRows on the square table", After("o.ReplaceCellsInTheseRows([ 1, 3 ], 0)", "o.Rows()"), "[ [ 0, 0, 0 ], [ 4, 5, 6 ], [ 0, 0, 0 ] ]")
	Tn("on 4 x 2", After("o4.ReplaceCellsInTheseRows([ 2, 4 ], '-')", "o4.Rows()"), "[ [ 'x', 'y' ], [ '-', '-' ], [ 'x', 'q' ], [ '-', '-' ] ]")
	Tn("the value can be given with :With", After("o.ReplaceCellsInTheseRows([ 2 ], [ :With, 9 ])", "o.Row(2)"), "[ 9, 9, 9 ]")
	aAll = [ "ReplaceAllOccurrencesOfCell", "ReplaceEachOccurrenceOfCell", "ReplaceEveryOccurrenceOfCell",
		"ReplaceAllOccurrences", "ReplaceEachOccurrence", "ReplaceEveryOccurrence" ]
	nOk = 0
	nOkCS = 0
	for i = 1 to len(aAll)
		if After("o4." + aAll[i] + "('x', 'X')", "o4.Col(:a)") = '[ "X", "z", "X", "r" ]'
			nOk++
		ok
		if After("o4." + aAll[i] + "CS('X', 'k', 0)", "o4.Col(:a)") = '[ "k", "z", "k", "r" ]'
			nOkCS++
		ok
	next
	Then("the six spellings of ReplaceAll replace every occurrence", nOk, 6)
	Then("and their CS forms too", nOkCS, 6)
	Tn("ReplaceAll with a number on the square table", After("o.ReplaceAllOccurrences(5, 0)", "o.Row(2)"), "[ 4, 0, 6 ]")
	Tn("ReplaceNth replaces the second x", After("o4.ReplaceNth(2, 'x', 'X')", "o4.Col(:a)"), '[ "x", "z", "X", "r" ]')
	Tn("ReplaceFirst", After("o4.ReplaceFirst('x', 'X')", "o4.Col(:a)"), '[ "X", "z", "x", "r" ]')
	Tn("ReplaceLast", After("o4.ReplaceLast('x', 'X')", "o4.Col(:a)"), '[ "x", "z", "X", "r" ]')
	Tn("an occurrence that does not exist replaces nothing", After("o4.ReplaceNth(5, 'x', 'X')", "o4.Col(:a)"), '[ "x", "z", "x", "r" ]')
	Tn("ReplaceFirstCS without case", After("o4.ReplaceFirstCS('X', 'k', 0)", "o4.Col(:a)"), '[ "k", "z", "x", "r" ]')
	Tn("ReplaceNth on the square table, with numbers", After("o.ReplaceFirst(5, 0)", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 0, 6 ], [ 7, 8, 9 ] ]")
EndScenario()

Scenario("A range of the table")
	Given("SectionToRange and Range, which always raised")
	Tn("SectionToRange gives the start and the count", Does("o.SectionToRange(2, 5)"), "[ 2, 4 ]")
	Tn("Range reads a block from a corner and a size (4 x 2)", Does("o4.Range([ 1, 2 ], [ 2, 2 ])"), '[ "z", "w", "x", "q" ]')
	Tn("on the square table", Does("o.Range([ 2, 1 ], [ 2, 2 ])"), "[ 2, 3, 5, 6 ]")
	Tn("a size of 0 columns gives [ ]", Does("o.Range([ 1, 1 ], [ 0, 2 ])"), "[ ]")
	Tn("a size that is not a pair raises", Does("o.Range([ 1, 1 ], 2)"), "RAISES")
EndScenario()

Summary()
