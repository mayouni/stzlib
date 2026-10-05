load "../../stzBase.ring"
load "../_narrated.ring"
load "_tblfix.ring"

# stzTable defect family: sorting and the sorted-order tests. SortInDescendingOn handed the call to the
# inherited list method (it reordered the COLUMNS and sorted no row); SortedDownOn called SortDownOnQ without
# its column; SortInDescendingOnBy, SortDownOnColBy and SortedDownOnColBy named a variable the body did not
# have (R24); IsSortedBy and its Up and Ascending spellings called a method with a typo or with an argument too
# many, and the IsSortedUp... family relied on SortUpOnBy, defined nowhere. Each scenario runs on a SQUARE
# 3 x 3 table and on a 4 x 2 table.
#
#   3 x 3 :  1 2 3 / 4 5 6 / 7 8 9
#   4 x 2 :  x y / z w / x q / r y

Scenario("Sorting the rows down on a column")
	Given("SortInDescendingOn, which reordered the columns")
	Tn("the rows of the square table come out in descending order of column b",
		After("o.SortInDescendingOn(:b)", "o.Rows()"), "[ [ 7, 8, 9 ], [ 4, 5, 6 ], [ 1, 2, 3 ] ]")
	Tn("the columns stay where they were", After("o.SortInDescendingOn(:b)", "o.ColNames()"), '[ "a", "b", "c" ]')
	Tn("a column given by position", After("o.SortInDescendingOn(1)", "o.Col(:c)"), "[ 9, 6, 3 ]")
	Tn("on 4 x 2, column a is in descending order", After("o4.SortInDescendingOn(:a)", "o4.Col(:a)"), '[ "z", "x", "x", "r" ]')
	Tn("the rows travel whole: the first row is z w", After("o4.SortInDescendingOn(:a)", "o4.Row(1)"), '[ "z", "w" ]')
	Tn("the last row is r y", After("o4.SortInDescendingOn(:a)", "o4.Row(4)"), '[ "r", "y" ]')
	Tn("SortDownOn is the same operation", After("o.SortDownOn(:b)", "o.Rows()"), "[ [ 7, 8, 9 ], [ 4, 5, 6 ], [ 1, 2, 3 ] ]")
EndScenario()

Scenario("The sorted copy, down")
	Given("SortedDownOn and its five spellings")
	Tn("SortedDownOn gives the content with column a in descending order (square)",
		Does("o.SortedDownOn(:b)"), '[ [ "a", [ 7, 4, 1 ] ], [ "b", [ 8, 5, 2 ] ], [ "c", [ 9, 6, 3 ] ] ]')
	Tn("on 4 x 2", Does("o4.SortedDownOn(:a)"), '[ [ "a", [ "z", "x", "x", "r" ] ], [ "b", [ "w", "y", "q", "y" ] ] ]')
	Tn("the table itself is untouched", After("r = o4.SortedDownOn(:a)", "o4.Col(:a)"), '[ "x", "z", "x", "r" ]')
	aNames = [ "SortedInDescendingOn", "SortedColDownOn", "SortedInDescendingOnCol", "SortedDownOnColumn", "SortedInDescendingOnColumn" ]
	nOk = 0
	for i = 1 to len(aNames)
		if Does("o." + aNames[i] + "(:b)") = '[ [ "a", [ 7, 4, 1 ] ], [ "b", [ 8, 5, 2 ] ], [ "c", [ 9, 6, 3 ] ] ]'
			nOk++
		ok
	next
	Then("the five spellings give the same answer", nOk, 5)
	Tn("SortedOn, the ascending twin, still works", Does("o.SortedOn(:b)"), '[ [ "a", [ 1, 4, 7 ] ], [ "b", [ 2, 5, 8 ] ], [ "c", [ 3, 6, 9 ] ] ]')
EndScenario()

Scenario("Sorting by an expression")
	Given("the expression @item % 4, whose order on column b (2 5 8 gives 2 1 0) is the reverse of the order of b")
	Tn("SortDownOnBy puts the largest key first, which keeps the order",
		After("o.SortDownOnBy(:b, '@item % 4')", "o.Col(:a)"), "[ 1, 4, 7 ]")
	Tn("SortOnBy puts the smallest key first, which reverses it",
		After("o.SortOnBy(:b, '@item % 4')", "o.Col(:a)"), "[ 7, 4, 1 ]")
	Tn("SortInDescendingOnBy is SortDownOnBy", After("o.SortInDescendingOnBy(:b, '@item % 4')", "o.Col(:a)"), "[ 1, 4, 7 ]")
	Tn("SortDownOnColBy takes the column", After("o.SortDownOnColBy(:b, '@item % 4')", "o.Col(:a)"), "[ 1, 4, 7 ]")
	Tn("SortDownOnColBy on the 4 x 2 table, by position", After("o4.SortDownOnColBy(1, 'upper(@item)')", "o4.Col(:a)"), '[ "z", "x", "x", "r" ]')
	Tn("SortedDownOnBy returns the content", Does("o.SortedDownOnBy(:b, '@item % 4')"), '[ [ "a", [ 1, 4, 7 ] ], [ "b", [ 2, 5, 8 ] ], [ "c", [ 3, 6, 9 ] ] ]')
	Tn("SortedDownOnColBy is the same", Does("o.SortedDownOnColBy(:b, '@item % 4')"), '[ [ "a", [ 1, 4, 7 ] ], [ "b", [ 2, 5, 8 ] ], [ "c", [ 3, 6, 9 ] ] ]')
	Tn("and leaves the table as it was", After("r = o.SortedDownOnColBy(:b, '@item % 4')", "o.Col(:a)"), "[ 1, 4, 7 ]")
EndScenario()

Scenario("Is the table sorted by an expression")
	Given("the square table, whose first column 1 4 7 rises")
	Tn("IsSortedBy on the first column", Does("o.IsSortedBy('@item')"), "1")
	Tn("IsSortedUpBy", Does("o.IsSortedUpBy('@item')"), "1")
	Tn("IsSortedInAscendingBy", Does("o.IsSortedInAscendingBy('@item')"), "1")
	Tn("IsSortedBy is FALSE when the expression reverses the order", Does("o.IsSortedBy('0 - @item')"), "0")
	Tn("IsSortedUpOnBy on a column", Does("o.IsSortedUpOnBy(:b, '@item')"), "1")
	Tn("is FALSE when the key falls (2 1 0)", Does("o.IsSortedUpOnBy(:b, '@item % 4')"), "0")
	Tn("IsSortedOnBy agrees", Does("o.IsSortedOnBy(:b, '@item % 4')"), "0")
	Tn("the spelling with the expression first", Does("o.IsSorteUpByOn('@item', :b)"), "1")
	Tn("IsSortedUpByOnCol", Does("o.IsSortedUpByOnCol('@item', :b)"), "1")
	Tn("IsSortedUpByOnColumn", Does("o.IsSortedUpByOnColumn('@item', :c)"), "1")
	Tn("IsSortedInAscendingByOnCol", Does("o.IsSortedInAscendingByOnCol('@item', 2)"), "1")
	Tn("IsSortedInAscendingByOnColumn", Does("o.IsSortedInAscendingByOnColumn('@item', :b)"), "1")
	Tn("IsSorteInAscendingByOn", Does("o.IsSorteInAscendingByOn('@item', :b)"), "1")
	Tn("IsSortedInAscendingOnColBy", Does("o.IsSortedInAscendingOnColBy(:b, '@item % 4')"), "0")
	Tn("on the 4 x 2 table, a text column that is not in order", Does("o4.IsSortedUpOnBy(:a, 'lower(@item)')"), "0")
	Tn("IsSortedUpBy on the 4 x 2 table", Does("o4.IsSortedUpBy('lower(@item)')"), "0")
EndScenario()

Summary()
