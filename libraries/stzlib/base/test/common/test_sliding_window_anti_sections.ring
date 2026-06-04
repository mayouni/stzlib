

load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== SlidingWindow & AntiSections Tests (Engine-Backed) ==="

# --- SlidingWindow ---
? ""
? "--- SlidingWindow ---"

o = new stzList([1, 2, 3, 4, 5])
aResult = o.SlidingWindow(3)
nTtl++
if StzLen(aResult) = 3
	aPart1 = aResult[1]
	aPart3 = aResult[3]
	if StzLen(aPart1) = 3 and aPart1[1] = 1 and aPart1[3] = 3 and
	   StzLen(aPart3) = 3 and aPart3[1] = 3 and aPart3[3] = 5
		? "  PASS: SlidingWindow(3) on [1,2,3,4,5] => 3 windows"
		nPsd++
	else
		? "  FAIL: SlidingWindow(3) window content wrong"
		nFld++
	ok
else
	? "  FAIL: SlidingWindow(3) got " + StzLen(aResult) + " windows, expected 3"
	nFld++
ok

# --- SlidingWindow size = list ---
? ""
? "--- SlidingWindow size=list ---"

o = new stzList([10, 20, 30])
aResult = o.SlidingWindow(3)
nTtl++
if StzLen(aResult) = 1
	aPart = aResult[1]
	if StzLen(aPart) = 3 and aPart[1] = 10 and aPart[3] = 30
		? "  PASS: SlidingWindow(3) on 3-item list => 1 window"
		nPsd++
	else
		? "  FAIL: SlidingWindow(3) window content wrong"
		nFld++
	ok
else
	? "  FAIL: SlidingWindow(3) got " + StzLen(aResult) + " windows, expected 1"
	nFld++
ok

# --- SlidingWindow size 2 ---
? ""
? "--- SlidingWindow size=2 ---"

o = new stzList(["a", "b", "c", "d"])
aResult = o.SlidingWindow(2)
nTtl++
if StzLen(aResult) = 3
	aPart1 = aResult[1]
	aPart3 = aResult[3]
	if aPart1[1] = "a" and aPart1[2] = "b" and aPart3[1] = "c" and aPart3[2] = "d"
		? "  PASS: SlidingWindow(2) on [a,b,c,d] => 3 windows"
		nPsd++
	else
		? "  FAIL: SlidingWindow(2) window content wrong"
		nFld++
	ok
else
	? "  FAIL: SlidingWindow(2) got " + StzLen(aResult) + " windows, expected 3"
	nFld++
ok

# --- FindAntiSections ---
? ""
? "--- FindAntiSections ---"

o = new stzList("A":"J")
aResult = o.FindAntiSections(:Of = [ [3, 5], [7, 8] ])
nTtl++
# Expected: [ [1,2], [6,6], [9,10] ]
if StzLen(aResult) = 3
	aPair1 = aResult[1]
	aPair2 = aResult[2]
	aPair3 = aResult[3]
	if aPair1[1] = 1 and aPair1[2] = 2 and
	   aPair2[1] = 6 and aPair2[2] = 6 and
	   aPair3[1] = 9 and aPair3[2] = 10
		? "  PASS: FindAntiSections([3,5],[7,8]) => [[1,2],[6,6],[9,10]]"
		nPsd++
	else
		? "  FAIL: FindAntiSections values wrong"
		for i = 1 to StzLen(aResult)
			? "    [" + i + "] = [" + aResult[i][1] + "," + aResult[i][2] + "]"
		next
		nFld++
	ok
else
	? "  FAIL: FindAntiSections got " + StzLen(aResult) + " pairs, expected 3"
	if StzLen(aResult) > 0
		for i = 1 to StzLen(aResult)
			? "    [" + i + "] = [" + aResult[i][1] + "," + aResult[i][2] + "]"
		next
	ok
	nFld++
ok

# --- AntiSections (content) ---
? ""
? "--- AntiSections ---"

o = new stzList("A":"J")
aResult = o.AntiSections(:Of = [ [3, 5], [7, 8] ])
nTtl++
# Expected: [ ["A","B"], ["F"], ["I","J"] ]
if StzLen(aResult) = 3
	aPart1 = aResult[1]
	aPart2 = aResult[2]
	aPart3 = aResult[3]
	if aPart1[1] = "A" and aPart1[2] = "B" and
	   StzLen(aPart2) = 1 and aPart2[1] = "F" and
	   aPart3[1] = "I" and aPart3[2] = "J"
		? "  PASS: AntiSections([3,5],[7,8]) => [['A','B'],['F'],['I','J']]"
		nPsd++
	else
		? "  FAIL: AntiSections content wrong"
		nFld++
	ok
else
	? "  FAIL: AntiSections got " + StzLen(aResult) + " parts, expected 3"
	nFld++
ok

# --- FindAntiSectionsIB ---
? ""
? "--- FindAntiSectionsIB ---"

o = new stzList("A":"J")
aResult = o.FindAntiSectionsIB(:Of = [ [3, 5], [7, 8] ])
nTtl++
# Expected: [ [1,3], [5,7], [8,10] ]
if StzLen(aResult) = 3
	aPair1 = aResult[1]
	aPair2 = aResult[2]
	aPair3 = aResult[3]
	if aPair1[1] = 1 and aPair1[2] = 3 and
	   aPair2[1] = 5 and aPair2[2] = 7 and
	   aPair3[1] = 8 and aPair3[2] = 10
		? "  PASS: FindAntiSectionsIB([3,5],[7,8]) => [[1,3],[5,7],[8,10]]"
		nPsd++
	else
		? "  FAIL: FindAntiSectionsIB values wrong"
		for i = 1 to StzLen(aResult)
			? "    [" + i + "] = [" + aResult[i][1] + "," + aResult[i][2] + "]"
		next
		nFld++
	ok
else
	? "  FAIL: FindAntiSectionsIB got " + StzLen(aResult) + " pairs, expected 3"
	if StzLen(aResult) > 0
		for i = 1 to StzLen(aResult)
			? "    [" + i + "] = [" + aResult[i][1] + "," + aResult[i][2] + "]"
		next
	ok
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
