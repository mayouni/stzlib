load "../stzBase.ring"

$nPassed = 0
$nFailed = 0

? "=== Comprehensive Engine Delegation Tests ==="
? ""

# --- STRING PRIMITIVES ---
? "--- String Primitives ---"
$Assert("StzUpper", StzUpper("hello") = "HELLO")
$Assert("StzLower", StzLower("HELLO") = "hello")
$Assert("StzLen string", StzLen("hello") = 5)
$Assert("StzLen list", StzLen([1,2,3]) = 3)
$Assert("StzLeft", StzLeft("hello", 3) = "hel")
$Assert("StzRight", StzRight("hello", 3) = "llo")
$Assert("StzMid", StzMid("hello", 2, 3) = "ell")
$Assert("StzReverse", StzReverse("abc") = "cba")
$Assert("StzReplace", StzReplace("hello world", "world", "zig") = "hello zig")
$Assert("StzCapitalize", StzCapitalize("hello") = "Hello")

? ""

# --- LIST CORE ---
? "--- List Core ---"
o = new stzList([5, 3, 8, 1, 9])
$Assert("Min", o.Min() = 1)
$Assert("Max", o.Max() = 9)
$Assert("IsListOfNumbers", o.IsListOfNumbers() = 1)
$Assert("IsListOfStrings", o.IsListOfStrings() = 0)
$Assert("Sorted count", len(o.Sorted()) = 5)
$Assert("Contains 3", o.Contains(3) = 1)
$Assert("Contains 99", o.Contains(99) = 0)

o2 = new stzList(["a", "b", "c"])
$Assert("IsListOfStrings", o2.IsListOfStrings() = 1)

? ""

# --- LIST DUPLICATES ---
? "--- List Duplicates ---"
oDup = new stzListDuplicates(["x", "y", "z", "x", "y"])
$Assert("HasDuplicates", oDup.HasDuplicates() = 1)
oDup.RemoveDuplicates()
$Assert("RemoveDuplicates count", len(oDup.Content()) = 3)

? ""

# --- LIST SORTER ---
? "--- List Sorter ---"
oSort = new stzListSorter([10, 5, 20, 1])
$Assert("IsSorted false", oSort.IsSorted() = 0)
oSort.SortInAscending()
$Assert("IsSortedInAscending", oSort.IsSortedInAscending() = 1)
$Assert("Min", oSort.Min() = 1)
$Assert("Max", oSort.Max() = 20)

? ""

# --- SET OPERATIONS ---
? "--- Set Operations ---"
oSet = new stzSet(["a", "b", "c", "a"])
$Assert("Set dedup", len(oSet.Content()) = 3)
aUnion = oSet.UnionWith(["c", "d", "e"])
$Assert("Union", len(aUnion) = 5)

oSet2 = new stzSet(["a", "b", "c"])
aInter = oSet2.IntersectionWith(["b", "c", "d"])
$Assert("Intersection", len(aInter) = 2)

aDiff = oSet2.DifferenceWith(["b", "c", "d"])
$Assert("Difference", len(aDiff) = 1)

? ""

# --- LIST OF LISTS ---
? "--- ListOfLists ---"
oLists = new stzListOfLists([
	["a", "b", "c"],
	["b", "c", "d"],
	["c", "d", "e"]
])
aCommon = oLists.CommonItems()
$Assert("CommonItems", len(aCommon) = 1)

? ""

# --- GLOBAL FUNCTIONS ---
? "--- Global Functions ---"
$Assert("FindAllCS string", len(@FindAllCS(["a","b","c","b"], "b", 1)) = 2)
$Assert("ItemExists found", ItemExists("hello", ["hi", "hello", "hey"]) = 1)
$Assert("ItemExists not found", ItemExists("bye", ["hi", "hello", "hey"]) = 0)
$Assert("IsSet true", IsSet([1,2,3]) = 1)
$Assert("IsSet false", IsSet([1,2,2]) = 0)

? ""

# --- FUNCTIONAL OPERATIONS ---
? "--- Functional Operations ---"
oFunc = new stzList([1, 2, 3, 4, 5])
aFiltered = oFunc.Filter('{ @item > 3 }')
$Assert("Filter > 3", len(aFiltered) = 2)

aMapped = oFunc.Map('{ @item * 10 }')
$Assert("Map *10 count", len(aMapped) = 5)

nSum = oFunc.Reduce('{ @value + @item }', 0)
$Assert("Reduce sum", nSum = 15)

? ""

# --- SUMMARY ---
? "================================"
? "Total: " + ($nPassed + $nFailed)
? "Passed: " + $nPassed
? "Failed: " + $nFailed
if $nFailed = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok


func $Assert(cName, bResult)
	if bResult
		? "  PASS: " + cName
		$nPassed++
	else
		? "  FAIL: " + cName
		$nFailed++
	ok
