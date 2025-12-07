load "../stzbase.ring"

/*====================================#
#   LISTEX - ENHANCED TEST SUITE      #
#=====================================#
*/

# Test the problematic patterns with debug enabled
? ""
? "#========================================#"
? "#  DEBUG: Investigating failing tests   #"
? "#========================================#"

? ""
? "DEBUG TEST 1: [@N, @S] with ['hello', 1]"
? "Expected: FALSE (should fail - wrong order)"
? ""
oLx1 = new stzListex("[@N, @S]")
oLx1.EnableDebug()
? "Result: " + oLx1.Match(["hello", 1])
oLx1.DisableDebug()

? ""
? "DEBUG TEST 2: [@S{'hello'; 'world'}] with ['world']"
? "Expected: TRUE (should match)"
? ""
oLx2 = new stzListex('[@S{"hello"; "world"}]')
oLx2.EnableDebug()
? "Result: " + oLx2.Match(["world"])
oLx2.DisableDebug()

? ""
? "DEBUG TEST 3: [@N2-3{1; 2; 3}U] with [1, 2]"
? "Expected: TRUE (unique values from set)"
? ""
oLx3 = new stzListex("[@N2-3{1; 2; 3}U]")
oLx3.EnableDebug()
? "Result: " + oLx3.Match([1, 2])
oLx3.DisableDebug()

? ""
? "#========================================#"
? ""

pr()

? "#----------------------------------------#"
? "#  TEST GROUP 1: Basic Pattern Matching  #"
? "#----------------------------------------#"

TestPattern("[@N]", [
	[1], "TRUE",
	[2.5], "TRUE",
	["hello"], "FALSE",
	[1, 2], "FALSE",
	[], "FALSE"
])

TestPattern("[@S]", [
	["hello"], "TRUE",
	[1], "FALSE",
	["hello", "world"], "FALSE",
	[], "FALSE"
])

TestPattern("[@L]", [
	[[1, 2]], "TRUE",
	[1], "FALSE",
	[[]], "TRUE",
	[], "FALSE"
])

TestPattern("[@$]", [
	[1], "TRUE",
	["hello"], "TRUE",
	[[1, 2]], "TRUE",
	[], "FALSE"
])

TestPattern("[@N, @S]", [
	[1, "hello"], "TRUE",
	["hello", 1], "FALSE",
	[1], "FALSE",
	[1, "hello", 2], "FALSE"
])

TestPattern("[@N, @N, @S]", [
	[1, 2, "hello"], "TRUE",
	[1, "hello"], "FALSE",
	[1, 2, 3], "FALSE"
])

#---

? ""
? "#-----------------------------------------#"
? "#  TEST GROUP 2: Pattern With Quantifier  #"
? "#-----------------------------------------#"

TestPattern("[@N2]", [
	[1, 2], "TRUE",
	[1], "FALSE",
	[1, 2, 3], "FALSE"
])

TestPattern("[@N1-3]", [
	[1], "TRUE",
	[1, 2], "TRUE",
	[1, 2, 3], "TRUE",
	[1, 2, 3, 4], "FALSE",
	[], "FALSE"
])

TestPattern("[@N+]", [
	[1], "TRUE",
	[1, 2, 3], "TRUE",
	[], "FALSE"
])

TestPattern("[@N*]", [
	[], "TRUE",
	[1], "TRUE",
	[1, 2, 3], "TRUE"
])

TestPattern("[@N?]", [
	[], "TRUE",
	[1], "TRUE",
	[1, 2], "FALSE"
])

TestPattern("[@N2, @S+]", [
	[1, 2, "hello"], "TRUE",
	[1, 2, "hello", "world"], "TRUE",
	[1, "hello"], "FALSE"
])

#---

? ""
? "#------------------------------------------------#"
? "#  TEST GROUP 3: Set Selection Pattern Matching  #"
? "#------------------------------------------------#"

TestPattern("[@N{1; 2; 3}]", [
	[1], "TRUE",
	[2], "TRUE",
	[4], "FALSE",
	[1, 2], "FALSE"
])

TestPattern('[ @S{"hello"; "world"} ]', [
	["hello"], "TRUE",
	["world"], "TRUE",
	["other"], "FALSE"
])

TestPattern("[@N2-3{1; 2; 3}U]", [
	[1, 2], "TRUE",
	[1, 2, 3], "TRUE",
	[1, 1], "FALSE",
	[1, 4], "FALSE"
])

TestPattern("[@N+{1; 2; 3}]", [
	[1], "TRUE",
	[1, 2], "TRUE",
	[1, 2, 3], "TRUE",
	[4], "FALSE",
	[1, 4], "FALSE"
])

#---

? ""
? "#----------------------------------------------#"
? "#  TEST GROUP 4: Complex Pattern Combinations  #"
? "#----------------------------------------------#"

TestPattern("[@L{[1,2]; [1,4]}]", [
	[[1, 2]], "TRUE",
	[[1, 4]], "TRUE",
	[[3, 4]], "FALSE"
])

TestPattern("[@N1-2, @N0-3]", [
	[1], "TRUE",
	[1, 2], "TRUE",
	[1, 2, 3], "TRUE",
	[1, 2, 3, 4, 5], "TRUE"
])

TestPattern('[ @N+{1; 2; 3}, @S{"hello"; "world"}, @L? ]', [
    [1, 2, "hello"], "TRUE",
    [3, "world"], "TRUE",
    [1, "hello", [1, 2]], "TRUE",
    [4, "hello"], "FALSE",
    [1, "other"], "FALSE",
    [1, "hello", [1], [2]], "FALSE"
])

#---

? ""
? "#-----------------------------------------------#"
? "#  TEST GROUP 5: Edge Cases and Error Handling  #"
? "#-----------------------------------------------#"

TestPattern("[]", [
	[], "TRUE",
	[1], "FALSE"
])

TestPattern("[@N]", [
	[3.14], "TRUE",
	[-2.5], "TRUE"
])

TestPattern("[@L]", [
	[[[1, 2], [3, 4]]], "TRUE"
])

TestPattern("[@N0-100]", [
	[], "TRUE",
	[1, 2, 3, 4, 5], "TRUE"
])

TestPattern("[@N, @S, @L, @$]", [
	[1, "hello", [1, 2], 42], "TRUE",
	[1, "hello", [1, 2]], "FALSE"
])

#---

? ""
? "#-------------------------------------------#"
? "#  TEST GROUP 6: Negation Pattern Matching  #"
? "#-------------------------------------------#"

TestPattern("[@!N]", [
	[10], "FALSE",
	["hello"], "TRUE"
])

TestPattern("[@!S]", [
	["hello"], "FALSE",
	[10], "TRUE",
	[[1, 2, 3]], "TRUE"
])

TestPattern('[@!L]', [
	[[1, 2, 3]], "FALSE",
	[10], "TRUE",
	["hello"], "TRUE"
])

TestPattern("[@N, @!N]", [
	[10, "hello"], "TRUE",
	[10, 20], "FALSE",
	["hello", 10], "FALSE"
])

#---

? ""
? "#----------------------------------------------#"
? "#  TEST GROUP 7: Alternation Pattern Matching  #"
? "#----------------------------------------------#"

TestPattern("[@N|@S]", [
	[10], "TRUE",
	["hello"], "TRUE",
	[[1, 2, 3]], "FALSE"
])

TestPattern("[ @N|@S, @L|@N ]", [
	[10, 20], "TRUE",
	["hello", [1, 2, 3]], "TRUE",
	[10, [1, 2, 3]], "TRUE",
	["hello", "world"], "FALSE"
])

TestPattern("[ @N{1;2;3} | @S ]", [
	[1], "TRUE",
	[2], "TRUE",
	["hello"], "TRUE",
	[4], "FALSE"
])

TestPattern("[ @N|@S, @!S ]", [
	[10, [1, 2, 3]], "TRUE",
	["hello", [1, 2, 3]], "TRUE",
	[10, "hello"], "FALSE",
	["hello", 10], "TRUE"
])

#---

? ""
? "#---------------------------------#"
? "#  TEST GROUP 8: NESTED PATTERNS  #"
? "#---------------------------------#"

TestPattern("[@N, [@N2], @N]", [
	[1, [2, 3], 4], "TRUE",
	[1, [2], 4], "FALSE",
	[1, [2, 3, 4], 4], "FALSE"
])

TestPattern("[@N, [@S, @N], @S]", [
	[1, ["hello", 42], "world"], "TRUE",
	[1, ["hello"], "world"], "FALSE"
])

TestPattern("[@N, [@N{10;20}], @N]", [
	[1, [10], 5], "TRUE",
	[1, [20], 5], "TRUE",
	[1, [15], 5], "FALSE",
	[1, [30], 5], "FALSE"
])

TestPattern("[@N, [@S, @N, [@N2]], @S]", [
	[1, ["hello", 42, [1, 2]], "world"], "TRUE",
	[1, ["hello", 42, [1]], "world"], "FALSE",
	[1, ["hello", 42, [1, 2, 3]], "world"], "FALSE"
])

TestPattern("[@N, [@N+], @N]", [
	[1, [10, 20, 30], 5], "TRUE",
	[1, [10], 5], "TRUE"
])

#---

? ""
? "#---------------------------------------#"
? "#  TEST GROUP 9: STEPPED RANGE PATTERN  #"
? "#---------------------------------------#"

TestPattern("[@N{1-10:3}]", [
    [1], "TRUE",
    [4], "TRUE",
    [7], "TRUE",
    [10], "TRUE",
    [2], "FALSE",
    [3], "FALSE",
    [8], "FALSE",
    [11], "FALSE",
    ["text"], "FALSE"
])

TestPattern("[@N+{5-20:5}U]", [
    [5, 10, 15, 20], "TRUE",
    [5, 10, 15], "TRUE",
    [5, 10, 10, 15], "FALSE",
    [5, 5], "FALSE",
    [5, 25], "FALSE"
])

TestPattern("[@N{1-5:1}, @N{10-20:5}]", [
    [3, 15], "TRUE",
    [5, 10], "TRUE",
    [1, 20], "TRUE",
    [6, 15], "FALSE",
    [3, 12], "FALSE"
])

TestPattern("[@N*{2-10:2}]", [
    [2, 4, 6, 8, 10], "TRUE",
    [2, 6, 10], "TRUE",
    [4, 8], "TRUE",
    [2], "TRUE",
    [], "TRUE",
    [1, 3], "FALSE",
    [2, 3], "FALSE"
])

TestPattern("[@N{1-9:2}|@S]", [
    [1], "TRUE",
    [3], "TRUE",
    [9], "TRUE",
    ["hello"], "TRUE",
    [2], "FALSE",
    [10], "FALSE"
])

TestPattern("[@N+{1-10:3}, @S, @N?{50-100:25}]", [
    [1, 4, "text"], "TRUE",
    [7, 10, 1, "hello"], "TRUE",
    [7, "word", 75], "TRUE",
    [7, "word"], "TRUE",
    [2, "text"], "FALSE",
    [7, 11, "word"], "FALSE",
    ["word", 7], "FALSE"
])

TestPattern("[[@N+{1-10:3}]]", [
    [[1, 4, 7]], "TRUE",
    [[10]], "TRUE",
    [[1, 4, 5]], "FALSE",
    [[2, 5, 8]], "FALSE",
    [1, 4, 7], "FALSE"
])

TestPattern("[@!N{2-12:3}]", [
    [2], "FALSE",
    [5], "FALSE",
    [8], "FALSE",
    [3], "TRUE",
    [6], "TRUE",
    [9], "TRUE"
])

#---

? ""
? "#--------------------------------------------#"
? "#  TEST GROUP 10: CASE SENSITIVITY (NEW!)    #"
? "#--------------------------------------------#"

# Default: case-insensitive
TestPattern("[@S{Ali}]", [
	["Ali"], "TRUE",
	["ali"], "TRUE",
	["ALI"], "TRUE",
	["aLi"], "TRUE"
])

# Case-sensitive with @cs: prefix
TestPattern("[@cs:@S{Ali}]", [
	["Ali"], "TRUE",
	["ali"], "FALSE",
	["ALI"], "FALSE",
	["aLi"], "FALSE"
])

# Multiple values case-insensitive
TestPattern('[@S{"Hello"; "World"}]', [
	["hello"], "TRUE",
	["HELLO"], "TRUE",
	["world"], "TRUE",
	["WORLD"], "TRUE",
	["other"], "FALSE"
])

# Multiple values case-sensitive
TestPattern('[@cs:@S{"Hello"; "World"}]', [
	["Hello"], "TRUE",
	["World"], "TRUE",
	["hello"], "FALSE",
	["HELLO"], "FALSE",
	["world"], "FALSE"
])

# Case-insensitive with quantifiers
TestPattern('[@S+{"red"; "green"; "blue"}]', [
	["Red", "GREEN", "Blue"], "TRUE",
	["red", "green"], "TRUE",
	["RED"], "TRUE"
])

# Case-sensitive with quantifiers
TestPattern('[@cs:@S+{"red"; "green"; "blue"}]', [
	["red", "green", "blue"], "TRUE",
	["Red", "GREEN", "Blue"], "FALSE",
	["red", "Green"], "FALSE"
])

# Case-insensitive unique set
TestPattern('[@S2-3{"apple"; "banana"}U]', [
	["apple", "BANANA"], "TRUE",
	["Apple", "banana"], "TRUE",
	["apple", "apple"], "FALSE",
	["APPLE", "apple"], "FALSE"
])

# Mixed case in alternation (default case-insensitive)
TestPattern('[@S{"Hi"}|@N]', [
	["hi"], "TRUE",
	["HI"], "TRUE",
	["Hi"], "TRUE",
	[42], "TRUE"
])

# Case-sensitive alternation
TestPattern('[@cs:@S{"Hi"}|@N]', [
	["Hi"], "TRUE",
	["hi"], "FALSE",
	["HI"], "FALSE",
	[42], "TRUE"
])

#---

? ""
? "#-------------------------------------------#"
? "#  TEST GROUP 11: CACHE PERFORMANCE (NEW!)  #"
? "#-------------------------------------------#"

? ""
? "Testing cache performance with large list..."

# Create large test list
aLarge = 1:1000
oLx = new stzListex("[@N+]")

# First match (no cache)
t1 = clock()
bResult1 = oLx.Match(aLarge)
t2 = clock()
nTime1 = t2 - t1

# Second match (from cache)
t3 = clock()
bResult2 = oLx.Match(aLarge)
t4 = clock()
nTime2 = t4 - t3

? "  First match:  " + nTime1 + "s (computed)"
? "  Second match: " + nTime2 + "s (cached)"
? "  Speedup: " + (nTime1 / nTime2) + "x"

# Cache info
aCacheInfo = oLx.CacheInfo()
? "  Cache entries: " + aCacheInfo[1][2]
? "  Cache max size: " + aCacheInfo[2][2]

# Test cache clearing
oLx.ClearCache()
aCacheInfo = oLx.CacheInfo()
? "  After clear: " + aCacheInfo[1][2] + " entries"

#---

? ""
? "#--------------------------------------#"
? "#  TEST GROUP 12: EXPLAIN METHOD (NEW!)#"
? "#--------------------------------------#"

? ""
? "Testing Explain() method..."
? ""

oLx = new stzListex("[@N+, @S{hello;world}U, @L?]")
aExplain = oLx.Explain()

? "Pattern: " + aExplain[1][2]
? "Token count: " + aExplain[2][2]
? "Cache entries: " + aExplain[3][2]
? ""
? "Token details:"

aTokens = aExplain[4][2]
for i = 1 to len(aTokens)
	aToken = aTokens[i]
	? "  Token #" + aToken[1][2] + ":"
	? "    Keyword: " + aToken[2][2]
	? "    Type: " + aToken[3][2]
	? "    Range: " + aToken[4][2] + "-" + aToken[5][2]
	? "    Has set: " + aToken[6][2]
	? "    Unique: " + aToken[8][2]
	? "    Case-sensitive: " + aToken[10][2]
next

#---

? ""
? "#----------------------------------------------#"
? "#  TEST GROUP 13: VALUE PRESERVATION (NEW!)    #"
? "#----------------------------------------------#"

# Mixed case values should be preserved
TestPattern('[@S{"Ali"; "MAHMOUD"; "sami"}]', [
	["ali"], "TRUE",
	["Ali"], "TRUE",
	["mahmoud"], "TRUE",
	["MAHMOUD"], "TRUE",
	["Sami"], "TRUE",
	["other"], "FALSE"
])

# Case-sensitive preservation
TestPattern('[@cs:@S{"Ali"; "MAHMOUD"; "sami"}]', [
	["Ali"], "TRUE",
	["MAHMOUD"], "TRUE",
	["sami"], "TRUE",
	["ali"], "FALSE",
	["mahmoud"], "FALSE",
	["Sami"], "FALSE"
])

# Preserve special characters
TestPattern('[@S{"hello-world"; "test_123"}]', [
	["hello-world"], "TRUE",
	["HELLO-WORLD"], "TRUE",
	["test_123"], "TRUE",
	["TEST_123"], "TRUE"
])

#---

? ""
? "#-------------------------------------------#"
? "#  TEST GROUP 14: DEBUG MODE (NEW!)         #"
? "#-------------------------------------------#"

? ""
? "Testing with debug mode enabled:"
? ""

oLx = new stzListex("[@N+, @S]")
oLx.EnableDebug()

? "--- Debug output will appear below ---"
bResult = oLx.Match([1, 2, 3, "hello"])
? "--- End debug output ---"
? ""
? "Match result: " + bResult

oLx.DisableDebug()

#---

? ""
? "#-------------------------------------------#"
? "#  TEST GROUP 15: TOKENSINFO ENHANCED       #"
? "#-------------------------------------------#"

? ""
? "Testing enhanced TokensInfo()..."
? ""

oLx = new stzListex('[@cs:@N+{1;2;3}, @S{"test"}U, @L?]')
aInfo = oLx.TokensInfo()

for i = 1 to len(aInfo)
	? aInfo[i]
next

pf()

/*=======================#
#  TEST HELPER FUNCTION  #
#------------------------#
*/
func TestPattern(cPattern, aTestCases)
    Lx = new stzListex(cPattern)
    
    ? ""
    ? "Testing pattern: " + cPattern
    nLen = len(aTestCases)

    for i = 1 to nLen step 2
        pInput = aTestCases[i]
        cExpected = aTestCases[i+1]
        
        cInputStr = @@(pInput)
        bResult = Lx.Match(pInput)

	cActual = "FALSE"
	if bResult
		cActual = "TRUE"
	ok
        
	cStatus = "✗"
	if cActual = cExpected
		cStatus = "✓"
	ok

        ? "  " + cStatus + " Match(" + cInputStr + ") --> " + cActual + 
          iif(cActual != cExpected, " (Expected: " + cExpected + ")", "")
    next
    
    return
