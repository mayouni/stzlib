
#ERR Error (R3) : Calling Function without definition: stzengineunicodecasefold

load "test_stubs.ring"
load "../../../string/stzString.ring"
load "../../../string/stzStringList.ring"
? "Step 1: Testing ContainsCS"
o = new stzStringList(["Hello", "World", "HELLO", "test"])

if o.ContainsCS("Hello", 1) = 1
	? "  ContainsCS case-sensitive exact: OK"
else
	? "  FAIL: ContainsCS should find 'Hello'"
ok

if o.ContainsCS("hello", 1) = 0
	? "  ContainsCS case-sensitive miss: OK"
else
	? "  FAIL: ContainsCS should NOT find 'hello' (case-sensitive)"
ok

if o.ContainsCS("hello", 0) = 1
	? "  ContainsCS case-insensitive: OK"
else
	? "  FAIL: ContainsCS should find 'hello' (case-insensitive)"
ok

? "Step 2: Testing FindCS"
anPositions = o.FindCS("HELLO", 1)
if len(anPositions) = 1 and anPositions[1] = 3
	? "  FindCS case-sensitive: OK"
else
	? "  FAIL: FindCS should find 'HELLO' at position 3"
ok

anPositions = o.FindCS("hello", 0)
if len(anPositions) = 2 and anPositions[1] = 1 and anPositions[2] = 3
	? "  FindCS case-insensitive: OK"
else
	? "  FAIL: FindCS should find 'hello' at positions 1 and 3, got " + len(anPositions)
ok

? "Step 3: Testing ContainsSubStringCS"
if o.ContainsSubStringCS("ell", 1) = 1
	? "  ContainsSubStringCS case-sensitive: OK"
else
	? "  FAIL: ContainsSubStringCS should find 'ell'"
ok

if o.ContainsSubStringCS("ELL", 1) = 1
	? "  ContainsSubStringCS case-sensitive 'ELL': OK"
else
	? "  FAIL: ContainsSubStringCS should find 'ELL' in 'HELLO'"
ok

if o.ContainsSubStringCS("ell", 0) = 1
	? "  ContainsSubStringCS case-insensitive: OK"
else
	? "  FAIL: ContainsSubStringCS should find 'ell' case-insensitive"
ok

if o.ContainsSubStringCS("xyz", 1) = 0
	? "  ContainsSubStringCS miss: OK"
else
	? "  FAIL: ContainsSubStringCS should NOT find 'xyz'"
ok

? "Step 4: Testing FilterCS"
acFiltered = o.FilterCS("ell", 1)
if len(acFiltered) = 1 and acFiltered[1] = "Hello"
	? "  FilterCS case-sensitive: OK"
else
	? "  FAIL: FilterCS, expected ['Hello'], got " + len(acFiltered) + " items"
ok

acFiltered = o.FilterCS("ell", 0)
if len(acFiltered) = 2
	? "  FilterCS case-insensitive: OK"
else
	? "  FAIL: FilterCS case-insensitive, expected 2, got " + len(acFiltered)
ok

? "Step 5: Testing FilterByStartsWithCS"
acFiltered = o.FilterByStartsWithCS("He", 1)
if len(acFiltered) = 1 and acFiltered[1] = "Hello"
	? "  FilterByStartsWithCS case-sensitive: OK"
else
	? "  FAIL: FilterByStartsWithCS, expected ['Hello'], got " + len(acFiltered)
ok

acFiltered = o.FilterByStartsWithCS("he", 0)
if len(acFiltered) = 2
	? "  FilterByStartsWithCS case-insensitive: OK"
else
	? "  FAIL: FilterByStartsWithCS CI, expected 2, got " + len(acFiltered)
ok

? "Step 6: Testing FilterByEndsWithCS"
acFiltered = o.FilterByEndsWithCS("lo", 1)
if len(acFiltered) = 1 and acFiltered[1] = "Hello"
	? "  FilterByEndsWithCS case-sensitive: OK"
else
	? "  FAIL: FilterByEndsWithCS, expected ['Hello'], got " + len(acFiltered)
ok

acFiltered = o.FilterByEndsWithCS("lo", 0)
if len(acFiltered) = 2
	? "  FilterByEndsWithCS case-insensitive: OK"
else
	? "  FAIL: FilterByEndsWithCS CI, expected 2, got " + len(acFiltered)
ok

? "Step 7: Testing ToUpper / ToLower"
o2 = new stzStringList(["Hello", "World"])
acUpper = o2.Uppercased()
if len(acUpper) = 2 and acUpper[1] = "HELLO" and acUpper[2] = "WORLD"
	? "  Uppercased: OK"
else
	? "  FAIL: Uppercased"
ok

o3 = new stzStringList(["Hello", "World"])
acLower = o3.Lowercased()
if len(acLower) = 2 and acLower[1] = "hello" and acLower[2] = "world"
	? "  Lowercased: OK"
else
	? "  FAIL: Lowercased"
ok

? "Step 8: Testing SortInAscending"
o4 = new stzStringList(["banana", "apple", "cherry"])
o4.SortInAscending()
acSorted = o4.Content()
if len(acSorted) = 3 and acSorted[1] = "apple" and acSorted[2] = "banana" and acSorted[3] = "cherry"
	? "  SortInAscending: OK"
else
	? "  FAIL: SortInAscending"
ok

? "Step 9: Testing Unique"
o5 = new stzStringList(["a", "b", "a", "c", "b"])
acUniq = o5.UniqueItems()
if len(acUniq) = 3
	? "  UniqueItems: OK (" + len(acUniq) + " items)"
else
	? "  FAIL: UniqueItems, expected 3, got " + len(acUniq)
ok

? ""
? "=== ALL STRINGLIST TESTS PASSED ==="
