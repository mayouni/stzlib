? "Ring Bridge Smoke Test"
? "======================"

# Set engine dir (normally done by stkringlibs.ring)
$cEngineDir = exefolder() + "/../libraries/stzlib/engine"
? "Engine dir: " + $cEngineDir

# Load the DLL as a Ring extension
cDll = $cEngineDir + "/zig-out/bin/stz_string.dll"
? "Loading: " + cDll
if not fexists(cDll)
    ? "ERROR: DLL not found!"
    return
ok

pLib = LoadLib(cDll)
? "LoadLib OK, type: " + type(pLib)

# Test 1: Create string from Ring string
? ""
? "Test 1: StzEngineStringFrom"
pStr = StzEngineStringFrom("Hello, Softanza!")
? "  handle type: " + type(pStr)

# Test 2: Get string data back
? "Test 2: StzEngineStringData"
cData = StzEngineStringData(pStr)
? "  data: " + cData

# Test 3: Get size
? "Test 3: StzEngineStringSize"
nSize = StzEngineStringSize(pStr)
? "  size: " + nSize

# Test 4: Get codepoint count
? "Test 4: StzEngineStringCount"
nCount = StzEngineStringCount(pStr)
? "  count: " + nCount

# Test 5: Contains
? "Test 5: StzEngineStringContains"
nHas = StzEngineStringContains(pStr, "Softanza")
? "  contains 'Softanza': " + nHas

# Test 6: IndexOf
? "Test 6: StzEngineStringIndexOf"
nIdx = StzEngineStringIndexOf(pStr, "Softanza")
? "  indexOf 'Softanza': " + nIdx

# Test 7: ToUpper
? "Test 7: StzEngineStringToUpper"
pUpper = StzEngineStringToUpper(pStr)
cUpper = StzEngineStringData(pUpper)
? "  upper: " + cUpper
StzEngineStringFree(pUpper)

# Test 8: ToLower
? "Test 8: StzEngineStringToLower"
pLower = StzEngineStringToLower(pStr)
cLower = StzEngineStringData(pLower)
? "  lower: " + cLower
StzEngineStringFree(pLower)

# Test 9: StartsWith
? "Test 9: StzEngineStringStartsWith"
nStarts = StzEngineStringStartsWith(pStr, "Hello")
? "  starts with 'Hello': " + nStarts

# Test 10: EndsWith
? "Test 10: StzEngineStringEndsWith"
nEnds = StzEngineStringEndsWith(pStr, "!")
? "  ends with '!': " + nEnds

# Test 11: CharIsLetter (codepoint for 'A' = 65)
? "Test 11: StzEngineCharIsLetter"
nIsLetter = StzEngineCharIsLetter(65)
? "  'A' is letter: " + nIsLetter

# Test 12: CharIsDigit (codepoint for '5' = 53)
? "Test 12: StzEngineCharIsDigit"
nIsDigit = StzEngineCharIsDigit(53)
? "  '5' is digit: " + nIsDigit

# Cleanup
StzEngineStringFree(pStr)

? ""
? "All tests passed!"
