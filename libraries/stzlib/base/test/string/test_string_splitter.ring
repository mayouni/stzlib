load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzStringSplitter Tests ==="

# --- SplitBeforePosition ---
? ""
? "--- SplitBeforePosition ---"

o = new stzString("abcde")
aResult = o.SplitBefore(3)
nTtl++
if len(aResult) = 2 and aResult[1] = "ab" and aResult[2] = "cde"
	? "  PASS: SplitBefore(3) = ['ab','cde']"
	nPsd++
else
	? "  FAIL: SplitBefore(3)"
	if len(aResult) >= 1 ? "    [1] = '" + aResult[1] + "'" ok
	if len(aResult) >= 2 ? "    [2] = '" + aResult[2] + "'" ok
	nFld++
ok

# --- SplitAfterPosition ---
? ""
? "--- SplitAfterPosition ---"

o = new stzString("abcde")
aResult = o.SplitAfter(3)
nTtl++
if len(aResult) = 2 and aResult[1] = "abc" and aResult[2] = "de"
	? "  PASS: SplitAfter(3) = ['abc','de']"
	nPsd++
else
	? "  FAIL: SplitAfter(3)"
	if len(aResult) >= 1 ? "    [1] = '" + aResult[1] + "'" ok
	if len(aResult) >= 2 ? "    [2] = '" + aResult[2] + "'" ok
	nFld++
ok

# --- SplitAtPosition ---
? ""
? "--- SplitAtPosition ---"

o = new stzString("abcde")
aResult = o.SplitAtPosition(3)
nTtl++
if len(aResult) = 2 and aResult[1] = "ab" and aResult[2] = "de"
	? "  PASS: SplitAtPosition(3) = ['ab','de'] (c excluded)"
	nPsd++
else
	? "  FAIL: SplitAtPosition(3)"
	if len(aResult) >= 1 ? "    [1] = '" + aResult[1] + "'" ok
	if len(aResult) >= 2 ? "    [2] = '" + aResult[2] + "'" ok
	nFld++
ok

# --- SplitBeforePositions (via direct splitter) ---
? ""
? "--- SplitBeforePositions ---"

oSplitter = new stzStringSplitter("abcdefgh")
aResult = oSplitter.SplitBeforePositions([3, 6])
nTtl++
if len(aResult) = 3 and aResult[1] = "ab" and aResult[2] = "cde" and aResult[3] = "fgh"
	? "  PASS: SplitBeforePositions([3,6]) = ['ab','cde','fgh']"
	nPsd++
else
	? "  FAIL: SplitBeforePositions([3,6]) got " + len(aResult) + " parts"
	for i = 1 to len(aResult)
		? "    [" + i + "] = '" + aResult[i] + "'"
	next
	nFld++
ok

# --- SplitAfterPositions (via direct splitter) ---
? ""
? "--- SplitAfterPositions ---"

oSplitter = new stzStringSplitter("abcdefgh")
aResult = oSplitter.SplitAfterPositions([3, 6])
nTtl++
if len(aResult) = 3 and aResult[1] = "abc" and aResult[2] = "def" and aResult[3] = "gh"
	? "  PASS: SplitAfterPositions([3,6]) = ['abc','def','gh']"
	nPsd++
else
	? "  FAIL: SplitAfterPositions([3,6]) got " + len(aResult) + " parts"
	for i = 1 to len(aResult)
		? "    [" + i + "] = '" + aResult[i] + "'"
	next
	nFld++
ok

# --- SplitAtSubString ---
? ""
? "--- SplitAtSubString ---"

o = new stzString("hello-world-test")
aResult = o.Split("-")
nTtl++
if len(aResult) = 3 and aResult[1] = "hello" and aResult[2] = "world" and aResult[3] = "test"
	? "  PASS: Split('-') = ['hello','world','test']"
	nPsd++
else
	? "  FAIL: Split('-') got " + len(aResult) + " parts"
	nFld++
ok

# --- SUMMARY ---
? ""
? "=========================="
? "Total: " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok

pf()
