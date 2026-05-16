? "Engine CI (Case-Insensitive) Wiring Test"
? "========================================="
? ""

# Load Engine DLL directly
$cEngineDir = "D:\GitHub\stzlib\libraries\stzlib\engine"
cDll = $cEngineDir + "/zig-out/bin/stz_string.dll"

if NOT fexists(cDll)
	? "ERROR: stz_string.dll not found at: " + cDll
	return
ok

pLib = LoadLib(cDll)
? "Engine DLL loaded."
? ""

nPass = 0
nFail = 0

# ---- Test 1: CountOfCI ----
? "Test 1: CountOfCI"
pStr = StzEngineStringFrom("Hello hello HELLO hElLo world")
nCount = StzEngineStringCountOfCI(pStr, "hello")
if nCount = 4
	? "  PASSED: 'hello' CI count = 4"
	nPass++
else
	? "  FAILED: expected 4, got " + nCount
	nFail++
ok

nCount = StzEngineStringCountOfCI(pStr, "WORLD")
if nCount = 1
	? "  PASSED: 'WORLD' CI count = 1"
	nPass++
else
	? "  FAILED: expected 1, got " + nCount
	nFail++
ok

nCount = StzEngineStringCountOfCI(pStr, "xyz")
if nCount = 0
	? "  PASSED: 'xyz' CI count = 0"
	nPass++
else
	? "  FAILED: expected 0, got " + nCount
	nFail++
ok

# ---- Test 2: LastIndexOfCI ----
? "Test 2: LastIndexOfCI"
pStr2 = StzEngineStringFrom("abc-ABC-Abc")
nIdx = StzEngineStringLastIndexOfCI(pStr2, "abc")
if nIdx = 8
	? "  PASSED: last 'abc' CI at byte 8"
	nPass++
else
	? "  FAILED: expected 8, got " + nIdx
	nFail++
ok

nIdx = StzEngineStringLastIndexOfCI(pStr2, "xyz")
if nIdx < 0
	? "  PASSED: 'xyz' not found CI (returned " + nIdx + ")"
	nPass++
else
	? "  FAILED: expected negative, got " + nIdx
	nFail++
ok

# ---- Test 3: ContainsCI ----
? "Test 3: ContainsCI"
pStr3 = StzEngineStringFrom("Hello World")
nHas = StzEngineStringContainsCI(pStr3, "HELLO")
if nHas = 1
	? "  PASSED: contains 'HELLO' CI"
	nPass++
else
	? "  FAILED: expected 1, got " + nHas
	nFail++
ok

nHas = StzEngineStringContainsCI(pStr3, "world")
if nHas = 1
	? "  PASSED: contains 'world' CI"
	nPass++
else
	? "  FAILED: expected 1, got " + nHas
	nFail++
ok

nHas = StzEngineStringContainsCI(pStr3, "xyz")
if nHas = 0
	? "  PASSED: does NOT contain 'xyz' CI"
	nPass++
else
	? "  FAILED: expected 0, got " + nHas
	nFail++
ok

# ---- Test 4: StartsWithCI ----
? "Test 4: StartsWithCI"
nStarts = StzEngineStringStartsWithCI(pStr3, "hello")
if nStarts = 1
	? "  PASSED: starts with 'hello' CI"
	nPass++
else
	? "  FAILED: expected 1, got " + nStarts
	nFail++
ok

nStarts = StzEngineStringStartsWithCI(pStr3, "HELLO")
if nStarts = 1
	? "  PASSED: starts with 'HELLO' CI"
	nPass++
else
	? "  FAILED: expected 1, got " + nStarts
	nFail++
ok

nStarts = StzEngineStringStartsWithCI(pStr3, "world")
if nStarts = 0
	? "  PASSED: does NOT start with 'world' CI"
	nPass++
else
	? "  FAILED: expected 0, got " + nStarts
	nFail++
ok

# ---- Test 5: EndsWithCI ----
? "Test 5: EndsWithCI"
nEnds = StzEngineStringEndsWithCI(pStr3, "world")
if nEnds = 1
	? "  PASSED: ends with 'world' CI"
	nPass++
else
	? "  FAILED: expected 1, got " + nEnds
	nFail++
ok

nEnds = StzEngineStringEndsWithCI(pStr3, "WORLD")
if nEnds = 1
	? "  PASSED: ends with 'WORLD' CI"
	nPass++
else
	? "  FAILED: expected 1, got " + nEnds
	nFail++
ok

nEnds = StzEngineStringEndsWithCI(pStr3, "hello")
if nEnds = 0
	? "  PASSED: does NOT end with 'hello' CI"
	nPass++
else
	? "  FAILED: expected 0, got " + nEnds
	nFail++
ok

# ---- Test 6: ReplaceCI ----
? "Test 6: ReplaceCI (in-place)"
pStr4 = StzEngineStringFrom("Hello hello HELLO world")
StzEngineStringReplaceCI(pStr4, "hello", "HI")
cResult = StzEngineStringData(pStr4)
if cResult = "HI HI HI world"
	? "  PASSED: replaced all 'hello' CI -> 'HI'"
	nPass++
else
	? "  FAILED: expected 'HI HI HI world', got '" + cResult + "'"
	nFail++
ok

# Cleanup
StzEngineStringFree(pStr)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr3)
StzEngineStringFree(pStr4)

? ""
? "========================================="
? "Results: " + nPass + " passed, " + nFail + " failed"
if nFail = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok
