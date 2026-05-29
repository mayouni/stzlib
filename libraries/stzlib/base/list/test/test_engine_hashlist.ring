# Test engine delegation for stzHashList
# Run from base/list/test/: D:\Ring126\bin\ring.exe test_engine_hashlist.ring

load "../../stzBase.ring"

nPass = 0
nFail = 0

? "=== Engine Delegation: stzHashList.HasKey ==="

o1 = new stzHashList([ :name = "mansour", :age = 44, :job = "programmer" ])

if o1.HasKey(:name) = 1
	nPass++
else
	nFail++
	? "  FAIL: HasKey(:name) should return 1"
ok

if o1.HasKey(:xyz) = 0
	nPass++
else
	nFail++
	? "  FAIL: HasKey(:xyz) should return 0"
ok

? "  HasKey(:name) = " + o1.HasKey(:name)
? "  HasKey(:xyz)  = " + o1.HasKey(:xyz)

? ""
? "=== Engine Delegation: stzHashList.FindKey ==="

nPos = o1.FindKey(:age)
? "  FindKey(:age) = " + nPos
if nPos = 2
	nPass++
else
	nFail++
	? "  FAIL: FindKey(:age) should return 2, got " + nPos
ok

nPos2 = o1.FindKey(:job)
? "  FindKey(:job) = " + nPos2
if nPos2 = 3
	nPass++
else
	nFail++
	? "  FAIL: FindKey(:job) should return 3, got " + nPos2
ok

nPos3 = o1.FindKey(:notfound)
? "  FindKey(:notfound) = " + nPos3
if nPos3 = 0
	nPass++
else
	nFail++
	? "  FAIL: FindKey(:notfound) should return 0, got " + nPos3
ok

? ""
? "=== Engine Delegation: stzHashList.Keys ==="

aKeys = o1.Keys()
? "  Keys(): " + @@(aKeys)
if len(aKeys) = 3 and aKeys[1] = "name" and aKeys[2] = "age" and aKeys[3] = "job"
	nPass++
else
	nFail++
	? "  FAIL: expected [name, age, job]"
ok

? ""
? "=== Engine: Mutations Invalidate Cache ==="

o2 = new stzHashList([ :a = 1, :b = 2 ])

# First lookup builds engine map
if o2.HasKey(:a) = 1
	nPass++
else
	nFail++
	? "  FAIL: HasKey(:a) should return 1"
ok

# Add a pair -- invalidates engine map
o2.AddPair([ :c, 3 ])

# Lookup after mutation
if o2.HasKey(:c) = 1
	nPass++
else
	nFail++
	? "  FAIL: HasKey(:c) should return 1 after AddPair"
ok

if o2.FindKey(:c) = 3
	nPass++
else
	nFail++
	? "  FAIL: FindKey(:c) should return 3 after AddPair"
ok

? "  After AddPair(:c, 3): HasKey(:c) = " + o2.HasKey(:c) + ", FindKey(:c) = " + o2.FindKey(:c)

? ""
? "=== Engine: ValueByKey still works ==="

cVal = o1.ValueByKey(:name)
? "  ValueByKey(:name) = " + cVal
if cVal = "mansour"
	nPass++
else
	nFail++
	? "  FAIL: expected 'mansour'"
ok

? ""
? "=== Engine Delegation: NumberOfPairs ==="

nCount = o1.NumberOfPairs()
? "  NumberOfPairs() = " + nCount
if nCount = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3, got " + nCount
ok

? ""
? "=== Engine Delegation: ValueIntByKey ==="

nAge = o1.ValueIntByKey(:age)
? "  ValueIntByKey(:age) = " + nAge
if nAge = 44
	nPass++
else
	nFail++
	? "  FAIL: expected 44, got " + nAge
ok

? ""
? "=== Engine Delegation: ValueStringByKey ==="

cName = o1.ValueStringByKey(:name)
? "  ValueStringByKey(:name) = " + cName
if cName = "mansour"
	nPass++
else
	nFail++
	? "  FAIL: expected 'mansour', got " + cName
ok

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="
