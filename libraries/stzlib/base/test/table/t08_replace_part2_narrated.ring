load "../../stzBase.ring"
load "../_narrated.ring"
load "_tblfix.ring"

# stzTable defect family, part B: the replacers and five others. The register listed 35 methods as raising;
# the first batch (t06) had repaired most of the replacers, so for them only the doc block was stale. This guard
# classifies every one of the 35 by calling it, on a SQUARE 3 x 3 table, on a 4 x 2 table and on tables whose
# cells are texts, numbers and lists. What it fixed in the code: the formula column reader (@) called a test
# that is defined nowhere, buildGrandTotal read totals that are local to another method, TransposeWithColNames
# called a misspelt method, ToHtml read a variable named data that is never set, and FromHtml called a method
# that is defined nowhere (it now reads the table itself). Every positive is paired with a negative.
#
#   3 x 3 :  1 2 3 / 4 5 6 / 7 8 9              (o)
#   4 x 2 :  x y / z w / x q / r y              (o4)
#   ow    :  name = Andy Ali Alia   job = Maestro Abraham Ali
#   ox    :  A = x x z   B = y x x              (x in four places, to tell the order of the occurrences)
#   ol    :  name = a b c   l = [1,2] [3] [1,2] (a column of lists)
#   on    :  a = 1 2   b = 10 20   c = 100 200  (numbers to add up)

Scenario("Replacing every cell equal to a value")
	Given("ReplaceOccurrencesOfCellByValue, which read a parameter its body did not declare")
	Tn("on the square table, a number", T8After("o.ReplaceOccurrencesOfCellByValue(5, 50)", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 50, 6 ], [ 7, 8, 9 ] ]")
	Tn("on the 4 x 2 table, both x", T8After("o4.ReplaceOccurrencesOfCellByValue('x', 'X')", "o4.Col(:a)"), '[ "X", "z", "X", "r" ]')
	Tn("on the 4 x 2 table, the other column is left alone", T8After("o4.ReplaceOccurrencesOfCellByValue('x', 'X')", "o4.Col(:b)"), '[ "y", "w", "q", "y" ]')
	Tn("a list cell is found as a value", T8After("ol.ReplaceOccurrencesOfCellByValue([ 1, 2 ], 'L')", "ol.Col(:l)"), '[ "L", [ 3 ], "L" ]')
	Tn("a value that is not there changes nothing", T8After("o.ReplaceOccurrencesOfCellByValue(55, 0)", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("a list that is not there changes nothing", T8After("ol.ReplaceOccurrencesOfCellByValue([ 9 ], 'L')", "ol.Col(:l)"), "[ [ 1, 2 ], [ 3 ], [ 1, 2 ] ]")
	Tn("the case counts: X is not x", T8After("o4.ReplaceOccurrencesOfCellByValue('X', 'k')", "o4.Col(:a)"), '[ "x", "z", "x", "r" ]')
	Tn("a missing new value raises", T8After("o.ReplaceOccurrencesOfCellByValue(5)", "o.Rows()"), "RAISES")
EndScenario()

Scenario("Replacing the cells equal to any of several values by one value")
	Given("ReplaceManyCellsByValue and its three spellings")
	Tn("ReplaceManyCellsByValue on the 4 x 2 table", T8After("o4.ReplaceManyCellsByValue([ 'x', 'y' ], '*')", "o4.Rows()"),
		"[ [ '*', '*' ], [ 'z', 'w' ], [ '*', 'q' ], [ 'r', '*' ] ]")
	Tn("on the square table, with numbers", T8After("o.ReplaceManyCellsByValue([ 2, 8 ], 0)", "o.Rows()"), "[ [ 1, 0, 3 ], [ 4, 5, 6 ], [ 7, 0, 9 ] ]")
	Tn("with a list cell among the values", T8After("ol.ReplaceManyCellsByValue([ [ 1, 2 ], 'b' ], 'L')", "ol.Rows()"),
		"[ [ 'a', 'L' ], [ 'L', [ 3 ] ], [ 'c', 'L' ] ]")
	aMany = [ "ReplaceCellsByValue", "ReplaceByValueManyCells", "ReplaceByValueCells" ]
	nOk = 0
	nKept = 0
	for i = 1 to len(aMany)
		if T8After("o4." + aMany[i] + "([ 'x', 'r' ], '*')", "o4.Col(:a)") = '[ "*", "z", "*", "*" ]'
			nOk++
		ok
		if T8After("o4." + aMany[i] + "([ 'x', 'r' ], '*')", "o4.Col(:b)") = '[ "y", "w", "q", "y" ]'
			nKept++
		ok
	next
	Then("the three other spellings do the same", nOk, 3)
	Then("and leave the column without the values alone", nKept, 3)
	Tn("the new value may be one of the old: no cascade", T8After("o4.ReplaceManyCellsByValue([ 'x', 'y' ], 'y')", "o4.Rows()"),
		"[ [ 'y', 'y' ], [ 'z', 'w' ], [ 'y', 'q' ], [ 'r', 'y' ] ]")
	Tn("an empty list of values changes nothing", T8After("o.ReplaceManyCellsByValue([ ], 0)", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("values that are not there change nothing", T8After("o.ReplaceManyCellsByValue([ 50, 60 ], 0)", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("a value that is not a list raises", T8After("o.ReplaceManyCellsByValue(5, 0)", "o.Rows()"), "RAISES")
	Tn("the CS form with case leaves the other case alone", T8After("o4.ReplaceManyCellsByValueCS([ 'X' ], '*', 1)", "o4.Col(:a)"), '[ "x", "z", "x", "r" ]')
EndScenario()

Scenario("Replacing the cells equal to several values by several values")
	Given("ReplaceManyCellsByValueByMany and its three spellings")
	Tn("ReplaceManyCellsByValueByMany on the 4 x 2 table", T8After("o4.ReplaceManyCellsByValueByMany([ 'x', 'y' ], [ 'A', 'B' ])", "o4.Rows()"),
		"[ [ 'A', 'B' ], [ 'z', 'w' ], [ 'A', 'q' ], [ 'r', 'B' ] ]")
	Tn("a swap on the square table does not cascade", T8After("o.ReplaceManyCellsByValueByMany([ 1, 9 ], [ 9, 1 ])", "o.Rows()"),
		"[ [ 9, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 1 ] ]")
	Tn("a text and a list cell, replaced by a list and a text", T8After("ol.ReplaceManyCellsByValueByMany([ [ 1, 2 ], 'b' ], [ 'L', [ 9 ] ])", "ol.Rows()"),
		"[ [ 'a', 'L' ], [ [ 9 ], [ 3 ] ], [ 'c', 'L' ] ]")
	aBy = [ "ReplaceCellsByValueByMany", "ReplaceByValueManyCellsByMany", "ReplaceByValueCellsByMany" ]
	nOk = 0
	nKept = 0
	for i = 1 to len(aBy)
		if T8After("o4." + aBy[i] + "([ 'x', 'r' ], [ 'A', 'B' ])", "o4.Col(:a)") = '[ "A", "z", "A", "B" ]'
			nOk++
		ok
		if T8After("o4." + aBy[i] + "([ 'x', 'r' ], [ 'A', 'B' ])", "o4.Col(:b)") = '[ "y", "w", "q", "y" ]'
			nKept++
		ok
	next
	Then("the three other spellings do the same", nOk, 3)
	Then("and leave the column without the values alone", nKept, 3)
	Tn("more values than new values: the surplus values stay", T8After("o.ReplaceManyCellsByValueByMany([ 1, 5, 9 ], [ 0 ])", "o.Rows()"),
		"[ [ 0, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("more new values than values: the surplus new values are ignored", T8After("o.ReplaceManyCellsByValueByMany([ 1 ], [ 0, 77, 88 ])", "o.Rows()"),
		"[ [ 0, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("values that are not there change nothing", T8After("o.ReplaceManyCellsByValueByMany([ 50 ], [ 0 ])", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("new values that are not a list raise", T8After("o.ReplaceManyCellsByValueByMany([ 5 ], 0)", "o.Rows()"), "RAISES")
	Tn("the case counts with the CS form", T8After("o4.ReplaceManyCellsByValueByManyCS([ 'X' ], [ 'k' ], 1)", "o4.Col(:a)"), '[ "x", "z", "x", "r" ]')
EndScenario()

Scenario("Replacing several columns by several lists of cells")
	Given("the six spellings that raised Unsupported feature in this release")
	aCols = [ "ReplaceAllColsByMany", "ReplaceAllColumsByMany", "ReplaceTheseColsByMany", "ReplaceTheseColumnsByMany", "ReplaceColsByMany", "ReplaceColumnsByMany" ]
	nOk3 = 0
	nOk4 = 0
	nKept = 0
	nBad = 0
	for i = 1 to len(aCols)
		if T8After("o." + aCols[i] + "([ 1, :b ], [ [ 0, 0, 0 ], [ 9, 9, 9 ] ])", "o.Cols()") = "[ [ 0, 0, 0 ], [ 9, 9, 9 ], [ 3, 6, 9 ] ]"
			nOk3++
		ok
		if T8After("o4." + aCols[i] + "([ :a, 2 ], [ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ])", "o4.Rows()") = "[ [ 1, 5 ], [ 2, 6 ], [ 3, 7 ], [ 4, 8 ] ]"
			nOk4++
		ok
		if T8After("o4." + aCols[i] + "([ :a ], [ [ 1, 2, 3, 4 ] ])", "o4.Col(:b)") = '[ "y", "w", "q", "y" ]'
			nKept++
		ok
		if T8After("o." + aCols[i] + "([ :zz ], [ [ 0, 0, 0 ] ])", "o.Cols()") = "RAISES"
			nBad++
		ok
	next
	Then("on the square table, by position and by name, the six spellings agree", nOk3, 6)
	Then("on the 4 x 2 table, by name and by position, the six spellings agree", nOk4, 6)
	Then("the column that is not named is left alone", nKept, 6)
	Then("an unknown column raises, in the six spellings", nBad, 6)
	Tn("a column of lists", T8After("ol.ReplaceTheseColsByMany([ :l ], [ [ [ 0 ], [ 1 ], [ 2 ] ] ])", "ol.Col(:l)"), "[ [ 0 ], [ 1 ], [ 2 ] ]")
	Tn("a column of texts", T8After("ow.ReplaceTheseColsByMany([ :name ], [ [ 'p', 'q', 'r' ] ])", "ow.Col(:name)"), '[ "p", "q", "r" ]')
	Tn("the new lists may be given by :With", T8After("o.ReplaceTheseColsByMany([ 2 ], [ :With, [ [ 7, 7, 7 ] ] ])", "o.Col(:b)"), "[ 7, 7, 7 ]")
	Tn("the surplus of the columns is ignored", T8After("o.ReplaceTheseColsByMany([ 1, 2 ], [ [ 0, 0, 0 ] ])", "o.Cols()"), "[ [ 0, 0, 0 ], [ 2, 5, 8 ], [ 3, 6, 9 ] ]")
	Tn("the new lists that are not lists of lists raise", T8After("o.ReplaceTheseColsByMany([ :a ], 5)", "o.Cols()"), "RAISES")
	Tn("the columns that are not a list raise", T8After("o.ReplaceTheseColsByMany(1, [ [ 0, 0, 0 ] ])", "o.Cols()"), "RAISES")
EndScenario()

Scenario("Setting every cell of the given rows to one value")
	Given("ReplaceCellsInTheseRows, which checked a name that was not its parameter")
	Tn("on the square table", T8After("o.ReplaceCellsInTheseRows([ 1, 3 ], 0)", "o.Rows()"), "[ [ 0, 0, 0 ], [ 4, 5, 6 ], [ 0, 0, 0 ] ]")
	Tn("on the 4 x 2 table", T8After("o4.ReplaceCellsInTheseRows([ 2, 4 ], '-')", "o4.Rows()"), "[ [ 'x', 'y' ], [ '-', '-' ], [ 'x', 'q' ], [ '-', '-' ] ]")
	Tn("the value may be given by :With", T8After("o.ReplaceCellsInTheseRows([ 2 ], [ :With, 9 ])", "o.Row(2)"), "[ 9, 9, 9 ]")
	Tn("a list is stored in each cell as it stands", T8After("ol.ReplaceCellsInTheseRows([ 1 ], [ 7, 7 ])", "ol.Row(1)"), "[ [ 7, 7 ], [ 7, 7 ] ]")
	Tn("the rows not listed are left alone", T8After("o.ReplaceCellsInTheseRows([ 1, 3 ], 0)", "o.Row(2)"), "[ 4, 5, 6 ]")
	Tn("no row, nothing changes", T8After("o.ReplaceCellsInTheseRows([ ], 0)", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("a row that does not exist raises", T8After("o.ReplaceCellsInTheseRows([ 9 ], 0)", "o.Rows()"), "RAISES")
EndScenario()

Scenario("Replacing every occurrence of a cell, in its six spellings")
	Given("the spellings that forwarded to ReplaceCell with two arguments")
	aAll = [ "ReplaceAllOccurrencesOfCell", "ReplaceEachOccurrenceOfCell", "ReplaceEveryOccurrenceOfCell",
		"ReplaceAllOccurrences", "ReplaceEachOccurrence", "ReplaceEveryOccurrence" ]
	nText = 0
	nNum = 0
	nKept = 0
	nNone = 0
	nCase = 0
	nList = 0
	for i = 1 to len(aAll)
		if T8After("o4." + aAll[i] + "('x', 'X')", "o4.Col(:a)") = '[ "X", "z", "X", "r" ]'
			nText++
		ok
		if T8After("o." + aAll[i] + "(5, 0)", "o.Rows()") = "[ [ 1, 2, 3 ], [ 4, 0, 6 ], [ 7, 8, 9 ] ]"
			nNum++
		ok
		if T8After("o4." + aAll[i] + "('x', 'X')", "o4.Col(:b)") = '[ "y", "w", "q", "y" ]'
			nKept++
		ok
		if T8After("o4." + aAll[i] + "('nope', 'X')", "o4.Rows()") = '[ [ "x", "y" ], [ "z", "w" ], [ "x", "q" ], [ "r", "y" ] ]'
			nNone++
		ok
		if T8After("o4." + aAll[i] + "('X', 'k')", "o4.Col(:a)") = '[ "x", "z", "x", "r" ]'
			nCase++
		ok
		if T8After("ol." + aAll[i] + "([ :Cell, [ 1, 2 ] ], 'L')", "ol.Col(:l)") = '[ "L", [ 3 ], "L" ]'
			nList++
		ok
	next
	Then("a text on the 4 x 2 table, in the six spellings", nText, 6)
	Then("a number on the square table, in the six spellings", nNum, 6)
	Then("the other column is left alone", nKept, 6)
	Then("a value that is not there changes nothing", nNone, 6)
	Then("the case counts", nCase, 6)
	Then("a list cell is given as [ :Cell, list ]", nList, 6)
	nOkCS = 0
	for i = 1 to len(aAll)
		if T8After("o4." + aAll[i] + "CS('X', 'k', 0)", "o4.Col(:a)") = '[ "k", "z", "k", "r" ]'
			nOkCS++
		ok
	next
	Then("their CS forms ignore the case when asked", nOkCS, 6)
EndScenario()

Scenario("Replacing the nth, the first and the last occurrence")
	Given("ox, whose x are at [1,1] [1,2] [2,2] [2,3], read column by column")
	Tn("ReplaceFirst replaces the first", T8After("ox.ReplaceFirst('x', 'F')", "ox.Rows()"), "[ [ 'F', 'y' ], [ 'x', 'x' ], [ 'z', 'x' ] ]")
	Tn("ReplaceLast replaces the last", T8After("ox.ReplaceLast('x', 'L')", "ox.Rows()"), "[ [ 'x', 'y' ], [ 'x', 'x' ], [ 'z', 'L' ] ]")
	Tn("ReplaceNth(2) replaces the second", T8After("ox.ReplaceNth(2, 'x', 'N')", "ox.Rows()"), "[ [ 'x', 'y' ], [ 'N', 'x' ], [ 'z', 'x' ] ]")
	Tn("ReplaceNth(3) replaces the third, in the second column", T8After("ox.ReplaceNth(3, 'x', 'N')", "ox.Rows()"), "[ [ 'x', 'y' ], [ 'x', 'N' ], [ 'z', 'x' ] ]")
	Tn("ReplaceNth(4) replaces the fourth", T8After("ox.ReplaceNth(4, 'x', 'N')", "ox.Rows()"), "[ [ 'x', 'y' ], [ 'x', 'x' ], [ 'z', 'N' ] ]")
	Tn("ReplaceNth(5): there is no fifth, nothing changes", T8After("ox.ReplaceNth(5, 'x', 'N')", "ox.Rows()"), "[ [ 'x', 'y' ], [ 'x', 'x' ], [ 'z', 'x' ] ]")
	Tn("ReplaceNth(0) changes nothing", T8After("ox.ReplaceNth(0, 'x', 'N')", "ox.Rows()"), "[ [ 'x', 'y' ], [ 'x', 'x' ], [ 'z', 'x' ] ]")
	Tn("a position that is not a number raises", T8After("ox.ReplaceNth('a', 'x', 'N')", "ox.Rows()"), "RAISES")
	Tn("a value that is not there changes nothing, first", T8After("ox.ReplaceFirst('nope', 'F')", "ox.Rows()"), "[ [ 'x', 'y' ], [ 'x', 'x' ], [ 'z', 'x' ] ]")
	Tn("a value that is not there changes nothing, last", T8After("ox.ReplaceLast('nope', 'L')", "ox.Rows()"), "[ [ 'x', 'y' ], [ 'x', 'x' ], [ 'z', 'x' ] ]")
	Tn("the case counts", T8After("ox.ReplaceFirst('X', 'F')", "ox.Rows()"), "[ [ 'x', 'y' ], [ 'x', 'x' ], [ 'z', 'x' ] ]")
	Tn("ReplaceFirst on the square table, a number", T8After("o.ReplaceFirst(5, 0)", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 0, 6 ], [ 7, 8, 9 ] ]")
	Tn("ReplaceLast on the square table, a number", T8After("o.ReplaceLast(9, 0)", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 0 ] ]")
	Tn("ReplaceNth on the square table, a number", T8After("o.ReplaceNth(1, 5, 0)", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 0, 6 ], [ 7, 8, 9 ] ]")
	Tn("ReplaceFirst on the 4 x 2 table", T8After("o4.ReplaceFirst('x', 'X')", "o4.Col(:a)"), '[ "X", "z", "x", "r" ]')
	Tn("ReplaceLast on the 4 x 2 table", T8After("o4.ReplaceLast('x', 'X')", "o4.Col(:a)"), '[ "x", "z", "X", "r" ]')
	Tn("a list cell is given as [ :Cell, list ]: first", T8After("ol.ReplaceFirst([ :Cell, [ 1, 2 ] ], 'L')", "ol.Col(:l)"), '[ "L", [ 3 ], [ 1, 2 ] ]')
	Tn("a list cell is given as [ :Cell, list ]: the second", T8After("ol.ReplaceNth(2, [ :Cell, [ 1, 2 ] ], 'L')", "ol.Col(:l)"), '[ [ 1, 2 ], [ 3 ], "L" ]')
EndScenario()

Scenario("Replacing a text found inside cells")
	Given("ow, whose names are Andy Ali Alia and whose jobs are Maestro Abraham Ali")
	Tn("ReplaceInCell changes the text inside one cell", T8After("ow.ReplaceInCell(1, 3, 'li', 'LI')", "ow.Col(:name)"), '[ "Andy", "Ali", "ALIa" ]')
	Tn("and leaves the other cells alone", T8After("ow.ReplaceInCell(1, 3, 'li', 'LI')", "ow.Col(:job)"), '[ "Maestro", "Abraham", "Ali" ]')
	Tn("the case counts: LI is not li", T8After("ow.ReplaceInCell(1, 3, 'LI', 'x')", "ow.Col(:name)"), '[ "Andy", "Ali", "Alia" ]')
	Tn("a text that is not in the cell changes nothing", T8After("ow.ReplaceInCell(1, 3, 'zzz', 'x')", "ow.Col(:name)"), '[ "Andy", "Ali", "Alia" ]')
	Tn("a number cell is left as it is", T8After("o.ReplaceInCell(1, 1, '1', '9')", "o.Rows()"), "[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("a list cell is left as it is", T8After("ol.ReplaceInCell(2, 1, 'a', 'A')", "ol.Col(:l)"), "[ [ 1, 2 ], [ 3 ], [ 1, 2 ] ]")
	Tn("a text that is not a string raises", T8After("o.ReplaceInCell(1, 1, 5, 0)", "o.Rows()"), "RAISES")
	Tn("ReplaceInCells works on the cells it is given", T8After("ow.ReplaceInCells([ [ 1, 2 ], [ 2, 3 ] ], 'Ali', 'Zed')", "ow.Rows()"),
		"[ [ 'Andy', 'Maestro' ], [ 'Zed', 'Abraham' ], [ 'Alia', 'Zed' ] ]")
	Tn("a cell of a text that is not in it changes nothing", T8After("ow.ReplaceInCells([ [ 1, 1 ] ], 'ANDY', 'q')", "ow.Rows()"),
		"[ [ 'Andy', 'Maestro' ], [ 'Ali', 'Abraham' ], [ 'Alia', 'Ali' ] ]")
	Tn("ReplaceInCells on the 4 x 2 table", T8After("o4.ReplaceInCells([ [ 1, 1 ], [ 2, 4 ] ], 'y', 'Y')", "o4.Rows()"),
		"[ [ 'x', 'y' ], [ 'z', 'w' ], [ 'x', 'q' ], [ 'r', 'Y' ] ]")
	Tn("ReplaceInCells leaves the cells that are not texts", T8After("ol.ReplaceInCells([ [ 1, 1 ], [ 2, 2 ] ], 'a', 'A')", "ol.Rows()"),
		"[ [ 'A', [ 1, 2 ] ], [ 'b', [ 3 ] ], [ 'c', [ 1, 2 ] ] ]")
	Tn("the cells that are not a list of pairs raise", T8After("o.ReplaceInCells(5, 'a', 'b')", "o.Rows()"), "RAISES")
	Tn("ReplaceInCellsByMany applies each text in turn", T8After("ow.ReplaceInCellsByMany([ [ 1, 2 ], [ 1, 3 ] ], [ 'A', 'l' ], '_')", "ow.Col(:name)"),
		'[ "Andy", "__i", "__ia" ]')
	Tn("the texts that are not a list of strings raise", T8After("ow.ReplaceInCellsByMany([ [ 1, 2 ] ], 'A', '_')", "ow.Col(:name)"), "RAISES")
	Tn("ReplaceInSection works on the block between two corners", T8After("ow.ReplaceInSection([ 1, 1 ], [ 1, 3 ], 'A', 'a')", "ow.Col(:name)"),
		'[ "andy", "ali", "alia" ]')
	Tn("and leaves the other column alone", T8After("ow.ReplaceInSection([ 1, 1 ], [ 1, 3 ], 'A', 'a')", "ow.Col(:job)"), '[ "Maestro", "Abraham", "Ali" ]')
	Tn("a block of two columns reaches both", T8After("ow.ReplaceInSection([ 1, 2 ], [ 2, 3 ], 'Ali', '_')", "ow.Rows()"),
		"[ [ 'Andy', 'Maestro' ], [ '_', 'Abraham' ], [ '_a', '_' ] ]")
	Tn("a block of one row", T8After("ow.ReplaceInSection([ 1, 1 ], [ 2, 1 ], 'a', '4')", "ow.Rows()"),
		"[ [ 'Andy', 'M4estro' ], [ 'Ali', 'Abraham' ], [ 'Alia', 'Ali' ] ]")
	Tn("ReplaceInSectionByMany applies each text in turn", T8After("ow.ReplaceInSectionByMany([ 1, 1 ], [ 1, 3 ], [ 'A', 'n' ], '.')", "ow.Col(:name)"),
		'[ "..dy", ".li", ".lia" ]')
	Tn("on both columns", T8After("ow.ReplaceInSectionByMany([ 1, 1 ], [ 2, 3 ], [ 'A', 'a' ], 'ZZ')", "ow.Rows()"),
		"[ [ 'ZZndy', 'MZZestro' ], [ 'ZZli', 'ZZbrZZhZZm' ], [ 'ZZliZZ', 'ZZli' ] ]")
	Tn("and leaves the other column alone", T8After("ow.ReplaceInSectionByMany([ 1, 1 ], [ 1, 3 ], [ 'A', 'n' ], '.')", "ow.Col(:job)"), '[ "Maestro", "Abraham", "Ali" ]')
	Tn("texts that are not in the block change nothing", T8After("ow.ReplaceInSectionByMany([ 1, 1 ], [ 1, 3 ], [ 'zzz' ], '.')", "ow.Rows()"),
		"[ [ 'Andy', 'Maestro' ], [ 'Ali', 'Abraham' ], [ 'Alia', 'Ali' ] ]")
EndScenario()

Scenario("The formula column reader")
	Given("@, which called a list test that is defined nowhere")
	Tn("a column name gives the code that reads the cell of that column", T8Does("o.@('b')"), '"( This.Cell(2, j) )"')
	Tn("by a symbol too", T8Does("o4.@(:b)"), '"( This.Cell(2, j) )"')
	Tn("the first column", T8Does("o.@('a')"), '"( This.Cell(1, j) )"')
	Tn("a text that names no column is given back", T8Does("o.@('zz + 1')"), '"zz + 1"')
	Tn("a list of names sets the columns, each with one empty cell", T8After("o.@([ :id, :name ])", "o.Content()"), '[ [ "id", [ "" ] ], [ "name", [ "" ] ] ]')
	Tn("a list of pairs takes the names", T8After("o4.@([ :id = 'SMALLINT', :name = 'VARCHAR(30)' ])", "o4.Content()"), '[ [ "id", [ "" ] ], [ "name", [ "" ] ] ]')
	Tn("a table of any shape takes it", T8After("ol.@([ :x ])", "ol.Content()"), '[ [ "x", [ "" ] ] ]')
	Tn("a number raises", T8Does("o.@(5)"), "RAISES")
	Tn("a list that is neither names nor pairs raises", T8Does("o.@([ 1, 2 ])"), "RAISES")
	Tn("a formula that uses it still works", T8After("o.AddCalculatedCol(:S, '@(:A) + @(:B)')", "o.Col(:s)"), "[ 3, 9, 15 ]")
EndScenario()

Scenario("The grand-total line of the grid")
	Given("buildGrandTotal, which read totals that are local to buildDataRows")
	Tn("the square table: the line is built", T8Contains("o.buildGrandTotal([ 5, 5, 5 ], 0, 3)", "GRAND-TOTAL"), "1")
	Tn("the third column adds up to 18", T8Contains("o.buildGrandTotal([ 5, 5, 5 ], 0, 3)", "  18 "), "1")
	Tn("no other total is shown: the second column would be 15", T8Contains("o.buildGrandTotal([ 5, 5, 5 ], 0, 3)", "15"), "0")
	Tn("with a row-number column, the last column is the fourth", T8Contains("o.buildGrandTotal([ 5, 5, 5, 5 ], 1, 4)", "  18 "), "1")
	Tn("the numbers 100 and 200 add up to 300", T8Contains("on.buildGrandTotal([ 6, 6, 6 ], 0, 3)", " 300 "), "1")
	Tn("the second column, 30, is not shown", T8Contains("on.buildGrandTotal([ 6, 6, 6 ], 0, 3)", " 30 "), "0")
	Tn("a table of texts shows the label", T8Contains("o4.buildGrandTotal([ 14, 5 ], 0, 2)", "GRAND-TOTAL"), "1")
	Tn("and no digit", T8Contains("ow.buildGrandTotal([ 14, 14 ], 0, 2)", "0"), "0")
	Tn("the text is a separator line and a total line, two ends of line", T8Does("len(StzFindCS(char(10), o.buildGrandTotal([ 5, 5, 5 ], 0, 3), 1))"), "2")
EndScenario()

Scenario("Transposing with the column names")
	Given("TransposeWithColNames, which called a misspelt method")
	Tn("the square table", T8After("o.TransposeWithColNames()", "o.Content()"),
		"[ [ 'COL1', [ 'a', 'b', 'c' ] ], [ 'COL2', [ 1, 2, 3 ] ], [ 'COL3', [ 4, 5, 6 ] ], [ 'COL4', [ 7, 8, 9 ] ] ]")
	Tn("the 4 x 2 table", T8After("o4.TransposeWithColNames()", "o4.Col(1)"), '[ "a", "b" ]')
	Tn("the 4 x 2 table has five columns afterwards", T8After("o4.TransposeWithColNames()", "o4.NumberOfCols()"), "5")
	Tn("the first column holds the old column names, on a table of lists too", T8After("ol.TransposeWithColNames()", "ol.Col(1)"), '[ "name", "l" ]')
	Tn("the list cells survive", T8After("ol.TransposeWithColNames()", "ol.Col(2)"), '[ "a", [ 1, 2 ] ]')
	Tn("it does what TransposeXT does", T8After("o4.TransposeWithColNames(); ox2 = M4(); ox2.TransposeXT()", "@@(o4.Content()) = @@(ox2.Content())"), "1")
	Tn("TransposeBack restores the table", T8After("o4.TransposeWithColNames(); o4.TransposeBack()", "o4.Content()"),
		'[ [ "a", [ "x", "z", "x", "r" ] ], [ "b", [ "y", "w", "q", "y" ] ] ]')
	Tn("the plain Transpose drops the names, which is the difference", T8After("o.Transpose()", "o.Col(1)"), "[ 1, 2, 3 ]")
EndScenario()

Scenario("The table as HTML")
	Given("ToHtml, which read a variable named data that is never set")
	Tn("the compact form is on one line", T8Contains("o.ToHtml()", char(10)), "0")
	Tn("it holds the column names", T8Contains("o.ToHtml()", '<th scope="col">b</th>'), "1")
	Tn("a number cell is marked by its class", T8Contains("o.ToHtml()", '<td class="number">5</td>'), "1")
	Tn("a text cell has no class", T8Contains("o4.ToHtml()", '<td>w</td>'), "1")
	Tn("and none is marked as a number", T8Contains("o4.ToHtml()", 'class="number"'), "0")
	Tn("a list cell is marked by its class", T8Contains("ol.ToHtml()", '<td class="list">'), "1")
	Tn("the cells are in the order of the rows", T8Does("StzFindCS('>x<', o4.ToHtml(), 1)[1] < StzFindCS('>z<', o4.ToHtml(), 1)[1]"), "1")
	Tn("the table has four rows of body", T8Does("len(StzFindCS('<tr class=' + char(34) + 'row' + char(34) + '>', o4.ToHtml(), 1))"), "4")
	Tn("ToHtmlTable is ToHtml", T8Does("o4.ToHtmlTable() = o4.ToHtml()"), "1")
	Tn("the extended form is on several lines", T8Contains("o.ToHtmlXT()", char(10)), "1")
	Tn("it holds the same cells", T8Contains("o.ToHtmlXT()", '<td class="number">5</td>'), "1")
	Tn("ToHtmlTableXT is ToHtmlXT", T8Does("o4.ToHtmlTableXT() = o4.ToHtmlXT()"), "1")
EndScenario()

Scenario("The table back from HTML")
	Given("FromHtml, which called a method that is defined nowhere")
	Tn("the square table makes the round trip", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(o.ToHtml())", "@@(t.Content()) = @@(o.Content())"), "1")
	Tn("the 4 x 2 table makes the round trip", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(o4.ToHtml())", "@@(t.Content()) = @@(o4.Content())"), "1")
	Tn("the people table makes the round trip", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(ow.ToHtml())", "@@(t.Content()) = @@(ow.Content())"), "1")
	Tn("the table of lists makes the round trip", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(ol.ToHtml())", "@@(t.Content()) = @@(ol.Content())"), "1")
	Tn("the extended form makes the round trip too", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(o4.ToHtmlXT())", "@@(t.Content()) = @@(o4.Content())"), "1")
	Tn("a number comes back as a number", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(o.ToHtml())", "isNumber(t.Cell(2, 2))"), "1")
	Tn("a text of digits comes back as a text", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); ox.ReplaceCell(1, 1, '007'); t.FromHtml(ox.ToHtml())", "isString(t.Cell(1, 1))"), "1")
	Tn("and keeps its zeros", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); ox.ReplaceCell(1, 1, '007'); t.FromHtml(ox.ToHtml())", "t.Cell(1, 1)"), '"007"')
	Tn("a decimal comes back as the number Ring shows", T8After("o.ReplaceCell(1, 1, 2.5); t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(o.ToHtml())", "t.Cell(1, 1)"), "2.50")
	Tn("a list inside a list comes back", T8After("ol.ReplaceCell(2, 1, [ 1, [ 2, 'x' ] ]); t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(ol.ToHtml())", "t.Cell(2, 1)"), '[ 1, [ 2, "x" ] ]')
	Tn("an empty list comes back", T8After("ol.ReplaceCell(2, 1, [ ]); t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(ol.ToHtml())", "t.Cell(2, 1)"), "[ ]")
	Then("a text with markup comes back as it was", T8After("ow.ReplaceCell(1, 1, 'a<b & ' + char(34) + 'c' + char(34) + '>'); t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(ow.ToHtml())", "t.Cell(1, 1)"),
		"'a<b & " + char(34) + "c" + char(34) + ">'")
	Tn("the markup is written as entities in the HTML", T8Contains("ow.ReplaceCell(1, 1, 'a<b'); ow.ToHtml()", "a&lt;b"), "1")
	Tn("an empty text comes back", T8After("ow.ReplaceCell(1, 1, ''); t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(ow.ToHtml())", "t.Cell(1, 1)"), '""')
	Tn("a Hebrew text comes back", T8After("ow.ReplaceCell(1, 1, 'שלום'); t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(ow.ToHtml())", "t.Cell(1, 1)"), '"שלום"')
	Tn("reading the HTML of the table back writes the same HTML", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(ol.ToHtml())", "t.ToHtml() = ol.ToHtml()"), "1")
	Tn("the number of columns is kept", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(o4.ToHtml())", "t.NumberOfCols()"), "2")
	Tn("the number of rows is kept", T8After("t = new stzTable([ [ :X ], [ 1 ] ]); t.FromHtml(o4.ToHtml())", "t.NumberOfRows()"), "4")
EndScenario()

Scenario("Reading HTML that ToHtml did not write")
	Given("tables as other tools write them")
	cFree = "'<TABLE><TR><TH>Id</TH><TH>Name</TH></TR><TR><TD>1</TD><TD><b>Al</b> &amp; Bo</TD></TR></TABLE>'"
	Tn("tags in capitals, a tag inside a cell, an entity", T8After("t = M3(); t.FromHtml(" + cFree + ")", "t.Content()"), '[ [ "Id", [ "1" ] ], [ "Name", [ "Al & Bo" ] ] ]')
	Tn("a cell with no class is a text, even of digits", T8After("t = M3(); t.FromHtml(" + cFree + ")", "isString(t.Cell(1, 1))"), "1")
	Tn("without a row of th, the columns are named COL1, COL2", T8After("t = M3(); t.FromHtml('<table><tr><td>1</td><td>2</td></tr></table>')", "t.ColNames()"), '[ "COL1", "COL2" ]')
	Tn("and the first row is a row of data", T8After("t = M3(); t.FromHtml('<table><tr><td>1</td><td>2</td></tr></table>')", "t.NumberOfRows()"), "1")
	Tn("a short row is completed with empty texts", T8After("t = M3(); t.FromHtml('<table><tr><td>1</td><td>2</td></tr><tr><td>3</td></tr></table>')", "t.Rows()"),
		"[ [ '1', '2' ], [ '3', '' ] ]")
	Tn("a table with a header and no body has columns and no cells", T8After("t = M3(); t.FromHtml('<table><thead><tr><th>A</th></tr></thead><tbody></tbody></table>')", "t.Content()"),
		'[ [ "A", [ ] ] ]')
	Tn("the spaces around a cell are dropped", T8After("t = M3(); t.FromHtml('<table><tr><th>A</th></tr><tr><td>  x  </td></tr></table>')", "t.Cell(1, 1)"), '"x"')
	Tn("a text that holds no table raises", T8After("t = M3(); t.FromHtml('<p>nothing</p>')", "t.Rows()"), "RAISES")
	Tn("and leaves the table as it was", T8Kept("o.FromHtml('<p>nothing</p>')"), "[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]")
	Tn("a value that is not a string raises", T8After("t = M3(); t.FromHtml(5)", "t.Rows()"), "RAISES")
EndScenario()

Summary()

#-------------------------------------------------------------------------------------------------------#

func T8Rep()
	return new stzTable([ [ :A, :B ], [ "x", "y" ], [ "x", "x" ], [ "z", "x" ] ])

func T8List()
	return new stzTable([ [ :NAME, :L ], [ "a", [ 1, 2 ] ], [ "b", [ 3 ] ], [ "c", [ 1, 2 ] ] ])

func T8Num()
	return new stzTable([ [ :A, :B, :C ], [ 1, 10, 100 ], [ 2, 20, 200 ] ])

func T8Prelude()
	return "o = M3()" + char(10) + "o4 = M4()" + char(10) + "ow = MW()" + char(10) + "ox = T8Rep()" + char(10) + "ol = T8List()" + char(10) + "on = T8Num()" + char(10)

# Runs a mutator on fresh tables, then writes what cShow gives, or RAISES
func T8After(cCode, cShow)
	cOut = ""
	try
		eval(T8Prelude() + cCode + char(10) + "cOut = @@(" + cShow + ")")
	catch
		cOut = "RAISES"
	done
	return cOut

# The value of an expression on fresh tables, written, or RAISES
func T8Does(cCode)
	cOut = ""
	try
		eval(T8Prelude() + "xr = " + cCode + char(10) + "cOut = @@(xr)")
	catch
		cOut = "RAISES"
	done
	return cOut

# What the square table holds after cCode, the code being allowed to raise
func T8Kept(cCode)
	cOut = ""
	try
		eval(T8Prelude() + "try" + char(10) + cCode + char(10) + "catch" + char(10) + "done" + char(10) + "cOut = @@(o.Rows())")
	catch
		cOut = "RAISES"
	done
	return cOut

# 1 when the text that cCode gives holds cNeedle (cCode may be several statements, the last being the text), else 0
func T8Contains(cCode, cNeedle)
	cOut = ""
	try
		aParts = split(cCode, ";")
		cLast = aParts[len(aParts)]
		cHead = ""
		for i = 1 to len(aParts) - 1
			cHead += aParts[i] + char(10)
		next
		eval(T8Prelude() + cHead + "cText = " + cLast)
		if len(StzFindCS(cNeedle, cText, 1)) > 0
			cOut = "1"
		else
			cOut = "0"
		ok
	catch
		cOut = "RAISES"
	done
	return cOut
