
#ERR Error (E9) : Can't open file ../../string/test/test_stubs.ring

load "../../string/test/test_stubs.ring"

# Load stz_regex.dll
? "Loading stz_regex.dll..."
cRegexLib = _stzFindDll("stz_regex.dll")
if cRegexLib != ""
	pRegexHandle = LoadLib(cRegexLib)
	? "  stz_regex.dll: loaded"
else
	? "ERROR: stz_regex.dll not found!"
	return
ok

? ""
? "=== stz_regex Engine Tests ==="

# Test 1: Simple match
? ""
? "--- Test 1: Simple match ---"
pH = StzEngineRegexNew("[0-9]+", 0)
if pH != NULL
	nResult = StzEngineRegexMatch(pH, "abc123def", 1)
	? "  Match '[0-9]+' in 'abc123def': " + nResult
	? "  HasMatch: " + StzEngineRegexHasMatch(pH)
	? "  CaptureCount: " + StzEngineRegexCaptureCount(pH)
	? "  CaptureStart(1): " + StzEngineRegexCaptureStart(pH, 1)
	? "  CaptureEnd(1): " + StzEngineRegexCaptureEnd(pH, 1)
	? "  CaptureText(1): " + StzEngineRegexCaptureText(pH, 1)
	StzEngineRegexFree(pH)
else
	? "  ERROR: regex new returned NULL"
ok

# Test 2: No match
? ""
? "--- Test 2: No match ---"
pH2 = StzEngineRegexNew("[0-9]+", 0)
if pH2 != NULL
	nResult = StzEngineRegexMatch(pH2, "abcdef", 1)
	? "  Match '[0-9]+' in 'abcdef': " + nResult
	? "  HasMatch: " + StzEngineRegexHasMatch(pH2)
	StzEngineRegexFree(pH2)
ok

# Test 3: Capture groups
? ""
? "--- Test 3: Capture groups ---"
pH3 = StzEngineRegexNew("([a-z]+)@([a-z]+)[.]([a-z]+)", 0)
if pH3 != NULL
	nResult = StzEngineRegexMatch(pH3, "user@example.com", 1)
	? "  Match email pattern: " + nResult
	? "  CaptureCount: " + StzEngineRegexCaptureCount(pH3)
	? "  Full match: " + StzEngineRegexCaptureText(pH3, 1)
	? "  Group 1: " + StzEngineRegexCaptureText(pH3, 2)
	? "  Group 2: " + StzEngineRegexCaptureText(pH3, 3)
	? "  Group 3: " + StzEngineRegexCaptureText(pH3, 4)
	StzEngineRegexFree(pH3)
ok

# Test 4: Replace
? ""
? "--- Test 4: Replace ---"
pH4 = StzEngineRegexNew("[0-9]+", 0)
if pH4 != NULL
	nResult = StzEngineRegexMatch(pH4, "abc123def456", 1)
	cReplaced = StzEngineRegexReplace(pH4, "abc123def456", "#")
	? "  Replace digits with '#': " + cReplaced
	StzEngineRegexFree(pH4)
ok

# Test 5: MatchAll
? ""
? "--- Test 5: MatchAll ---"
pH5 = StzEngineRegexNew("[a-z]+", 0)
if pH5 != NULL
	nCount = StzEngineRegexMatchAll(pH5, "abc 123 def 456 ghi")
	? "  MatchAll '[a-z]+': count=" + nCount
	StzEngineRegexFree(pH5)
ok

# Test: MatchAll via low-level API
? ""
? "--- Test: MatchAll ---"
pH = StzEngineRegexNew("[0-9]+", 0)
nCount = StzEngineRegexMatchAll(pH, "abc 123 def 456 ghi 789")
? "  Match count: " + nCount
if nCount = 3
	cFirst = StzEngineRegexCaptureText(pH, 1)
	cSecond = StzEngineRegexCaptureText(pH, 2)
	cThird = StzEngineRegexCaptureText(pH, 3)
	? "  Matches: '" + cFirst + "', '" + cSecond + "', '" + cThird + "'"
	if cFirst = "123" and cSecond = "456" and cThird = "789"
		? "  PASS"
	else
		? "  FAIL (wrong match text)"
	ok
else
	? "  FAIL (expected 3)"
ok
StzEngineRegexFree(pH)

# Test: StzRegexMatchAll high-level wrapper
? ""
? "--- Test: StzRegexMatchAll wrapper ---"

# Need to set $cEngineDir for the bridge file
cTemp = cRegexLib
nLen2 = len(cTemp)
cNorm2 = ""
for i = 1 to nLen2
	if cTemp[i] = "\"
		cNorm2 += "/"
	else
		cNorm2 += cTemp[i]
	ok
next
nCut2 = len(cNorm2) - len("/zig-out/bin/stz_regex.dll")
$cEngineDir = left(cNorm2, nCut2)
load "../../../engine/stz_regex.ring"

pr()

aMatches = StzRegexMatchAll("[a-z]+", "Hello World Test")
? "  Found " + len(aMatches) + " matches"
if len(aMatches) = 3
	? "  PASS"
else
	? "  FAIL"
ok

? ""
? "=== All stz_regex engine tests completed ==="

pf()
