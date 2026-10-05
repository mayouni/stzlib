load "../../stzBase.ring"
load "../_narrated.ring"
load "_tblfix.ring"

# stzTable defect family: methods that did nothing. InsertCol and its thirteen spellings appended the
# column to the stored content and then restored the copy taken before; ReplaceColName and its two
# spellings did the same with the new name; ExtendTo had an empty body and Extend raised; Updated
# returned its argument. Each scenario runs on a SQUARE 3 x 3 table and on a 4 x 2 table.
#
#   3 x 3 :  a = 1 4 7    b = 2 5 8    c = 3 6 9
#   4 x 2 :  a = x z x r  b = y w q y

Scenario("Inserting a column")
	Given("InsertCol, which became column n of nothing")
	Tn("a column inserted at 2 becomes column 2", After("o.InsertCol(2, [ 'x', [ 10, 11, 12 ] ])", "o.ColNames()"), '[ "a", "x", "b", "c" ]')
	Tn("with its cells", After("o.InsertCol(2, [ 'x', [ 10, 11, 12 ] ])", "o.Col(:x)"), "[ 10, 11, 12 ]")
	Tn("the other columns keep their cells", After("o.InsertCol(2, [ 'x', [ 10, 11, 12 ] ])", "o.Col(:b)"), "[ 2, 5, 8 ]")
	Tn("a short column is padded with empty text (4 x 2)", After("o4.InsertCol(1, [ 'n', [ '1', '2' ] ])", "o4.Col(:n)"), '[ "1", "2", "", "" ]')
	Tn("and goes first", After("o4.InsertCol(1, [ 'n', [ '1', '2' ] ])", "o4.ColNames()"), '[ "n", "a", "b" ]')
	Tn("a long column is cut to the number of rows", After("o.InsertCol(4, [ 'z', [ 1, 2, 3, 4, 5 ] ])", "o.Col(:z)"), "[ 1, 2, 3 ]")
	Tn("one past the last column appends", After("o4.InsertCol(3, [ 'n', [ '1', '2', '3', '4' ] ])", "o4.ColNames()"), '[ "a", "b", "n" ]')
	Tn("the rows stay as long as the table is wide", After("o4.InsertCol(2, [ 'n', [ '1', '2', '3', '4' ] ])", "o4.Row(3)"), '[ "x", "3", "q" ]')
	Tn("a position past the end plus one raises", After("o.InsertCol(6, [ 'z', [ 1, 2, 3 ] ])", "o.ColNames()"), "RAISES")
	Tn("a name already in the table raises", After("o.InsertCol(1, [ 'b', [ 1, 2, 3 ] ])", "o.ColNames()"), "RAISES")
	Tn("the engine copy follows the insertion",
		After("h0 = o.EngineHandle()" + nl + "o.InsertCol(2, [ 'x', [ 10, 11, 12 ] ])" + nl + "h = o.EngineHandle()",
			"@@(StzEngineTableContent(h)) = @@(o.Content())"), "1")

	aBefore = [ "InsertColBefore", "InsertColBeforePosition", "insertColAt", "InsertColAtPosition", "InsertColumn",
		"InsertColumnBefore", "InsertColumnBeforePosition", "insertColumnAt", "InsertColumnAtPosition" ]
	aAfter = [ "InsertColAfter", "InsertColAfterPosition", "InsertColumnAfter", "InsertColumnAfterPosition" ]
	nOkB = 0
	for i = 1 to len(aBefore)
		if After("o4." + aBefore[i] + "(2, [ 'n', [ '1', '2', '3', '4' ] ])", "o4.ColNames()") = '[ "a", "n", "b" ]'
			nOkB++
		ok
	next
	nOkA = 0
	for i = 1 to len(aAfter)
		if After("o4." + aAfter[i] + "(1, [ 'n', [ '1', '2', '3', '4' ] ])", "o4.ColNames()") = '[ "a", "n", "b" ]'
			nOkA++
		ok
	next
	Then("the nine spellings that insert before or at a position all insert at it", nOkB, 9)
	Then("the four spellings that insert after a position put the column behind it", nOkA, 4)
EndScenario()

Scenario("Renaming a column with ReplaceColName")
	Given("the three spellings and the combined name-and-data forms")
	Tn("ReplaceColName by name", After("o.ReplaceColName(:b, 'beta')", "o.ColNames()"), '[ "a", "beta", "c" ]')
	Tn("the cells go with the new name", After("o4.ReplaceColName(:b, 'beta')", "o4.Col(:beta)"), '[ "y", "w", "q", "y" ]')
	Tn("ReplaceNthColName by position", After("o.ReplaceNthColName(3, 'z')", "o.ColNames()"), '[ "a", "b", "z" ]')
	Tn("ReplaceColumnName", After("o4.ReplaceColumnName(:a, 'q')", "o4.ColNames()"), '[ "q", "b" ]')
	Tn("the new name can come as [ :With, name ]", After("o.ReplaceColName(:b, [ :With, 'zz' ])", "o.ColNames()"), '[ "a", "zz", "c" ]')
	Tn("a name another column already has raises", After("o.ReplaceColName(:b, 'a')", "o.ColNames()"), "RAISES")
	Tn("an unknown column raises", After("o.ReplaceColName(:nope, 'a')", "o.ColNames()"), "RAISES")
	Tn("ReplaceColNameAndData changes the name (square)",
		After("o.ReplaceColNameAndData(:b, 'beta', [ 7, 8, 9 ])", "o.ColNames()"), '[ "a", "beta", "c" ]')
	Tn("and the cells", After("o.ReplaceColNameAndData(:b, 'beta', [ 7, 8, 9 ])", "o.Col(:beta)"), "[ 7, 8, 9 ]")
	Tn("on 4 x 2", After("o4.ReplaceColNameAndData(:b, 'bb', [ '1', '2', '3', '4' ])", "o4.Col(:bb)"), '[ "1", "2", "3", "4" ]')
	Tn("the older spelling ReplaceColumnNamedAndData", After("o4.ReplaceColumnNamedAndData(2, 'bb', [ '1', '2', '3', '4' ])", "o4.ColNames()"), '[ "a", "bb" ]')
EndScenario()

Scenario("Growing the table with Extend and ExtendTo")
	Given("a 4 x 2 table")
	Tn("Extend adds columns named col3.. and keeps the content", After("o4.Extend(4, 4)", "o4.ColNames()"), '[ "a", "b", "col3", "col4" ]')
	Tn("the cells that were there stay", After("o4.Extend(4, 6)", "o4.Cell(:a, 3) + o4.Cell(:b, 4)"), '"xy"')
	Tn("the new rows are made of empty text", After("o4.Extend(2, 6)", "o4.Row(6)"), '[ "", "" ]')
	Tn("and so are the new columns", After("o4.Extend(3, 4)", "o4.Col(:col3)"), '[ "", "", "", "" ]')
	Tn("the table has the size asked", After("o4.Extend(5, 6)", "[ o4.NumberOfCols(), o4.NumberOfRows() ]"), "[ 5, 6 ]")
	Tn("a smaller size changes nothing", After("o4.Extend(1, 1)", "[ o4.NumberOfCols(), o4.NumberOfRows() ]"), "[ 2, 4 ]")
	Tn("ExtendTo on the square table", After("o.ExtendTo(4, 5)", "[ o.NumberOfCols(), o.NumberOfRows(), o.Row(5) ]"), '[ 4, 5, [ "", "", "", "" ] ]')
	Tn("a new column name never collides with an existing one",
		After("o4.RenameCol(:b, 'col3')" + nl + "o4.Extend(3, 4)", "o4.ColNames()"), '[ "a", "col3", "col3_" ]')
EndScenario()

Scenario("Updated returns an updated copy")
	Given("a 3 x 3 table")
	Tn("the copy has the new content", After("o2 = o.Updated([ :x = [ 1, 2 ], :y = [ 3, 4 ] ])", "o2.Content()"), '[ [ "x", [ 1, 2 ] ], [ "y", [ 3, 4 ] ] ]')
	Tn("the original is untouched", After("o2 = o.Updated([ :x = [ 1, 2 ], :y = [ 3, 4 ] ])", "o.ColNames()"), '[ "a", "b", "c" ]')
	Tn("UpdatedWith is the same", After("o2 = o4.UpdatedWith([ :x = [ 1 ] ])", "o2.ColNames()"), '[ "x" ]')
EndScenario()

Summary()
