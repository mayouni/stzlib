# Test stzListCounter + stzListFinder engine delegation for count/contains
# Run from base/list/test/: D:\Ring126\bin\ring.exe test_engine_list_counter_delegation.ring

load "../../stzBase.ring"

pr()

nPass = 0
nFail = 0

# --- CountCS for strings (engine fast path) ---

? "=== Engine Delegation: CountCS string items ==="

o1 = new stzListCounter(["apple", "banana", "cherry", "banana", "date", "banana"])

nCount = o1.CountCS("banana", 1)
? "  CountCS('banana', CS=1): " + nCount
if nCount = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3, got " + nCount
ok

nCount2 = o1.CountCS("mango", 1)
? "  CountCS('mango', CS=1): " + nCount2
if nCount2 = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0, got " + nCount2
ok

# --- CountCS case-insensitive ---

? ""
? "=== Engine Delegation: CountCS case-insensitive ==="

o2 = new stzListCounter(["Hello", "HELLO", "hello", "World", "hello"])

nCS = o2.CountCS("hello", 1)
? "  CountCS('hello', CS=1): " + nCS
if nCS = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2, got " + nCS
ok

nCI = o2.CountCS("hello", 0)
? "  CountCS('hello', CS=0): " + nCI
if nCI = 4
	nPass++
else
	nFail++
	? "  FAIL: expected 4, got " + nCI
ok

# --- Count (non-CS alias) ---

? ""
? "=== Engine Delegation: Count (alias) ==="

nAlias = o1.Count("banana")
? "  Count('banana'): " + nAlias
if nAlias = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3, got " + nAlias
ok

# --- Count numbers (fallback path) ---

? ""
? "=== Engine Delegation: Count numbers (fallback) ==="

o3 = new stzListCounter([1, 2, 1, 3, 1, 4, 1])

nNumCount = o3.Count(1)
? "  Count(1) in number list: " + nNumCount
if nNumCount = 4
	nPass++
else
	nFail++
	? "  FAIL: expected 4, got " + nNumCount
ok

# --- ContainsCS for strings (engine fast path) ---

? ""
? "=== Engine Delegation: ContainsCS ==="

o4 = new stzListFinder(["ring", "zig", "python"])

bHas = o4.ContainsCS("zig", 1)
? "  ContainsCS('zig', CS=1): " + bHas
if bHas = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1, got " + bHas
ok

bMissing = o4.ContainsCS("ZIG", 1)
? "  ContainsCS('ZIG', CS=1): " + bMissing
if bMissing = 0
	nPass++
else
	nFail++
	? "  FAIL: expected 0, got " + bMissing
ok

bCI = o4.ContainsCS("ZIG", 0)
? "  ContainsCS('ZIG', CS=0): " + bCI
if bCI = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1, got " + bCI
ok

# --- CountStrings / CountNumbers ---

? ""
? "=== Engine Delegation: CountStrings / CountNumbers ==="

o5 = new stzListCounter([1, "two", 3, "four", 5])

nStr = o5.CountStrings()
? "  CountStrings(): " + nStr
if nStr = 2
	nPass++
else
	nFail++
	? "  FAIL: expected 2, got " + nStr
ok

nNum = o5.CountNumbers()
? "  CountNumbers(): " + nNum
if nNum = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3, got " + nNum
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

pf()
