# Test stzListFinder engine delegation for string finding
# Run from base/list/test/: D:\Ring126\bin\ring.exe test_engine_list_finder_delegation.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

# --- FindAll for strings (engine fast path) ---

? "=== Engine Delegation: FindAll string items ==="

o1 = new stzListFinder(["apple", "banana", "cherry", "banana", "date", "banana"])

aPos = o1.FindAll("banana")
? "  FindAll('banana'): " + @@(aPos)
if @@(aPos) = "[ 2, 4, 6 ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ 2, 4, 6 ], got " + @@(aPos)
ok

aPos2 = o1.FindAll("mango")
? "  FindAll('mango'): " + @@(aPos2)
if @@(aPos2) = "[ ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ ], got " + @@(aPos2)
ok

aPos3 = o1.FindAll("apple")
? "  FindAll('apple'): " + @@(aPos3)
if @@(aPos3) = "[ 1 ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ 1 ], got " + @@(aPos3)
ok

# --- Case-insensitive string finding ---

? ""
? "=== Engine Delegation: Case-insensitive string find ==="

o2 = new stzListFinder(["Hello", "HELLO", "hello", "World", "hello"])

aCS = o2.FindAllCS("hello", 1)
? "  FindAllCS('hello', CS=1): " + @@(aCS)
if @@(aCS) = "[ 3, 5 ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ 3, 5 ], got " + @@(aCS)
ok

aCI = o2.FindAllCS("hello", 0)
? "  FindAllCS('hello', CS=0): " + @@(aCI)
if @@(aCI) = "[ 1, 2, 3, 5 ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ 1, 2, 3, 5 ], got " + @@(aCI)
ok

# --- FindFirst / FindLast for strings ---

? ""
? "=== Engine Delegation: FindFirst/FindLast ==="

o3 = new stzListFinder(["x", "y", "z", "y", "x"])

nFirst = o3.FindFirst("y")
? "  FindFirst('y'): " + nFirst
if nFirst = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2, got " + nFirst
ok

nLast = o3.FindLast("y")
? "  FindLast('y'): " + nLast
if nLast = 4
	nPass++
else
	nFail++
	? "  FAIL: expected 4, got " + nLast
ok

# --- Contains for strings ---

? ""
? "=== Engine Delegation: Contains ==="

o4 = new stzListFinder(["ring", "zig", "python"])

bHas = o4.Contains("zig")
? "  Contains('zig'): " + bHas
if bHas = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1, got " + bHas
ok

bMissing = o4.Contains("rust")
? "  Contains('rust'): " + bMissing
if bMissing = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0, got " + bMissing
ok

# --- NumberOfOccurrence for strings ---

? ""
? "=== Engine Delegation: NumberOfOccurrence ==="

o5 = new stzListFinder(["a", "b", "a", "c", "a", "b"])

nCount = o5.NumberOfOccurrence("a")
? "  NumberOfOccurrence('a'): " + nCount
if nCount = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3, got " + nCount
ok

# --- FindMany for strings ---

? ""
? "=== Engine Delegation: FindMany ==="

o6 = new stzListFinder(["red", "green", "blue", "red", "green"])

aMany = o6.FindMany(["red", "blue"])
? "  FindMany(['red','blue']): " + @@(aMany)
if @@(aMany) = "[ 1, 3, 4 ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ 1, 3, 4 ], got " + @@(aMany)
ok

# --- Mixed list (numbers stay on fallback, strings use engine) ---

? ""
? "=== Engine Delegation: Mixed list (number fallback) ==="

o7 = new stzListFinder([1, "two", 3, "two", 5])

aPosNum = o7.FindAll(3)
? "  FindAll(3) in mixed list: " + @@(aPosNum)
if @@(aPosNum) = "[ 3 ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ 3 ], got " + @@(aPosNum)
ok

aPosStr = o7.FindAll("two")
? "  FindAll('two') in mixed list: " + @@(aPosStr)
if @@(aPosStr) = "[ 2, 4 ]"
	nPass++
else
	nFail++
	? "  FAIL: expected [ 2, 4 ], got " + @@(aPosStr)
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
