? "Engine FindAll Bridge Test"
? "=========================="
? ""

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

# ---- Test 1: FindAll CS ----
? "Test 1: FindAll (case-sensitive)"
pStr = StzEngineStringFrom("ring is ring and ring")
pResult = StzEngineStringFindAll(pStr, "ring")
nCount = StzEngineFindResultCount(pResult)
if nCount = 3
	? "  PASSED: found 3 occurrences"
	nPass++
else
	? "  FAILED: expected 3, got " + nCount
	nFail++
ok

n0 = StzEngineFindResultGet(pResult, 0)
n1 = StzEngineFindResultGet(pResult, 1)
n2 = StzEngineFindResultGet(pResult, 2)
if n0 = 0 and n1 = 8 and n2 = 17
	? "  PASSED: positions = [0, 8, 17]"
	nPass++
else
	? "  FAILED: expected [0,8,17], got [" + n0 + "," + n1 + "," + n2 + "]"
	nFail++
ok
StzEngineFindResultFree(pResult)

# ---- Test 2: FindAll not found ----
? "Test 2: FindAll not found"
pResult2 = StzEngineStringFindAll(pStr, "xyz")
nCount2 = StzEngineFindResultCount(pResult2)
if nCount2 = 0
	? "  PASSED: 'xyz' not found (count = 0)"
	nPass++
else
	? "  FAILED: expected 0, got " + nCount2
	nFail++
ok
StzEngineFindResultFree(pResult2)

# ---- Test 3: FindAllCI ----
? "Test 3: FindAllCI (case-insensitive)"
pStr2 = StzEngineStringFrom("Ring RING ring RiNg")
pResult3 = StzEngineStringFindAllCI(pStr2, "ring")
nCount3 = StzEngineFindResultCount(pResult3)
if nCount3 = 4
	? "  PASSED: found 4 CI occurrences"
	nPass++
else
	? "  FAILED: expected 4, got " + nCount3
	nFail++
ok

n0 = StzEngineFindResultGet(pResult3, 0)
n1 = StzEngineFindResultGet(pResult3, 1)
n2 = StzEngineFindResultGet(pResult3, 2)
n3 = StzEngineFindResultGet(pResult3, 3)
if n0 = 0 and n1 = 5 and n2 = 10 and n3 = 15
	? "  PASSED: CI positions = [0, 5, 10, 15]"
	nPass++
else
	? "  FAILED: expected [0,5,10,15], got [" + n0 + "," + n1 + "," + n2 + "," + n3 + "]"
	nFail++
ok
StzEngineFindResultFree(pResult3)

# ---- Test 4: Single occurrence ----
? "Test 4: Single occurrence"
pStr3 = StzEngineStringFrom("hello world")
pResult4 = StzEngineStringFindAll(pStr3, "world")
nCount4 = StzEngineFindResultCount(pResult4)
if nCount4 = 1
	? "  PASSED: 'world' found once"
	nPass++
else
	? "  FAILED: expected 1, got " + nCount4
	nFail++
ok
n0 = StzEngineFindResultGet(pResult4, 0)
if n0 = 6
	? "  PASSED: at byte 6"
	nPass++
else
	? "  FAILED: expected 6, got " + n0
	nFail++
ok
StzEngineFindResultFree(pResult4)

# Cleanup
StzEngineStringFree(pStr)
StzEngineStringFree(pStr2)
StzEngineStringFree(pStr3)

? ""
? "=========================="
? "Results: " + nPass + " passed, " + nFail + " failed"
if nFail = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok
