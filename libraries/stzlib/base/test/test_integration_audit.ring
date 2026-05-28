load "../stzBase.ring"

? "=== Integration Audit ==="
? ""

_nPassed_ = 0
_nFailed_ = 0

# --- Q() function chaining ---
? "--- Q() Chaining ---"

_cQResult_ = Q("Hello World").Uppercased()
if _cQResult_ = "HELLO WORLD" ? "  PASS: Q() string chain" _nPassed_++ else ? "  FAIL: Q() string: " + _cQResult_ _nFailed_++ ok

_cQFind_ = Q("hello world hello").Find("hello")
if isList(_cQFind_) and len(_cQFind_) = 2 ? "  PASS: Q() Find" _nPassed_++ else ? "  FAIL: Q() Find" _nFailed_++ ok
? ""

# --- stzString + stzStringFinder cross-module ---
? "--- String + Finder ---"
_oStr_ = new stzString("ABCDEFABCGHI")
aF = _oStr_.Find("ABC")
if isList(aF) and len(aF) = 2 ? "  PASS: Find returns 2 positions" _nPassed_++ else ? "  FAIL: Find()" _nFailed_++ ok
if aF[1] = 1 and aF[2] = 7 ? "  PASS: Find positions correct" _nPassed_++ else ? "  FAIL: Find positions" _nFailed_++ ok
? ""

# --- stzString + stzStringReplacer cross-module ---
? "--- String + Replacer ---"
_oRStr_ = new stzString("Hello World Hello")
_oReplacer_ = new stzStringReplacer(_oRStr_)
_oReplacer_.Replace("Hello", "Bye")
if _oRStr_.Content() = "Bye World Bye" ? "  PASS: Replacer cross-module" _nPassed_++ else ? "  FAIL: Replacer: " + _oRStr_.Content() _nFailed_++ ok
? ""

# --- stzString + stzStringBounder cross-module ---
? "--- String + Bounder ---"
_oBnd_ = new stzStringBounder("A(X)B(Y)C")
aBetween = _oBnd_.Between("(", ")")
if isList(aBetween) and len(aBetween) = 2 ? "  PASS: Between returns 2 matches" _nPassed_++ else ? "  FAIL: Between count" _nFailed_++ ok
if aBetween[1] = "X" ? "  PASS: Between first match" _nPassed_++ else ? "  FAIL: Between first" _nFailed_++ ok
if aBetween[2] = "Y" ? "  PASS: Between second match" _nPassed_++ else ? "  FAIL: Between second" _nFailed_++ ok
? ""

# --- stzString + stzStringComparator ---
? "--- String + Comparator ---"
_oCmp_ = new stzStringComparator("Hello")
nJaro = _oCmp_.JaroSimilarityWith("Hallo")
if isNumber(nJaro) and nJaro > 0 ? "  PASS: Jaro returns number > 0" _nPassed_++ else ? "  FAIL: Jaro" _nFailed_++ ok
? ""

# --- stzList + stzListFinder ---
? "--- List + Finder ---"
oL = new stzList(["a", "b", "c", "b", "d"])
aLF = oL.Find("b")
if isList(aLF) and len(aLF) = 2 ? "  PASS: List Find returns 2" _nPassed_++ else ? "  FAIL: List Find" _nFailed_++ ok
if aLF[1] = 2 and aLF[2] = 4 ? "  PASS: List Find positions" _nPassed_++ else ? "  FAIL: List Find positions" _nFailed_++ ok
? ""

# --- stzList sort + reverse ---
? "--- List Sort + Reverse ---"
oL2 = new stzList([5, 3, 1, 4, 2])
aSorted = oL2.Sorted()
if aSorted[1] = 1 and aSorted[5] = 5 ? "  PASS: Sorted" _nPassed_++ else ? "  FAIL: Sorted" _nFailed_++ ok

aRev = oL2.Reversed()
if aRev[1] = 2 and aRev[5] = 5 ? "  PASS: Reversed" _nPassed_++ else ? "  FAIL: Reversed" _nFailed_++ ok
? ""

# --- stzList unique ---
? "--- List Unique ---"
oL3 = new stzList(["a", "b", "a", "c", "b"])
aUniq = oL3.Unique()
if isList(aUniq) and len(aUniq) = 3 ? "  PASS: Unique count" _nPassed_++ else ? "  FAIL: Unique: " + len(aUniq) _nFailed_++ ok
? ""

# --- stzList NumberOfOccurrence ---
? "--- List Count ---"
oL4 = new stzList([1, 2, 3, 2, 1, 2])
_nCnt_ = oL4.NumberOfOccurrence(2)
if _nCnt_ = 3 ? "  PASS: NumberOfOccurrence" _nPassed_++ else ? "  FAIL: NumberOfOccurrence: " + _nCnt_ _nFailed_++ ok
? ""

# --- Unicode integration ---
? "--- Unicode ---"
_nCp_ = StzCharToUnicode("A")
if _nCp_ = 65 ? "  PASS: StzCharToUnicode A=65" _nPassed_++ else ? "  FAIL: unicode A = " + _nCp_ _nFailed_++ ok

_cChar_ = StzChar(65)
if _cChar_ = "A" ? "  PASS: StzChar 65=A" _nPassed_++ else ? "  FAIL: StzChar 65" _nFailed_++ ok
? ""

# --- Engine string wrappers ---
? "--- Engine Wrappers ---"
_cUp_ = StzUpper("hello")
if _cUp_ = "HELLO" ? "  PASS: StzUpper" _nPassed_++ else ? "  FAIL: StzUpper: " + _cUp_ _nFailed_++ ok

_cLow_ = StzLower("HELLO")
if _cLow_ = "hello" ? "  PASS: StzLower" _nPassed_++ else ? "  FAIL: StzLower: " + _cLow_ _nFailed_++ ok

_nLen_ = StzLen("Hello")
if _nLen_ = 5 ? "  PASS: StzLen" _nPassed_++ else ? "  FAIL: StzLen: " + _nLen_ _nFailed_++ ok

_cLeft_ = StzLeft("Hello World", 5)
if _cLeft_ = "Hello" ? "  PASS: StzLeft" _nPassed_++ else ? "  FAIL: StzLeft: " + _cLeft_ _nFailed_++ ok

_cRight_ = StzRight("Hello World", 5)
if _cRight_ = "World" ? "  PASS: StzRight" _nPassed_++ else ? "  FAIL: StzRight: " + _cRight_ _nFailed_++ ok
? ""

# --- Number engine ---
? "--- Number Engine ---"
_nMax_ = @Max([3, 1, 4, 1, 5, 9])
if _nMax_ = 9 ? "  PASS: @Max" _nPassed_++ else ? "  FAIL: @Max: " + _nMax_ _nFailed_++ ok

_nMin_ = @Min([3, 1, 4, 1, 5, 9])
if _nMin_ = 1 ? "  PASS: @Min" _nPassed_++ else ? "  FAIL: @Min: " + _nMin_ _nFailed_++ ok
? ""

# ==================
? "=========================="
? "Total: " + (_nPassed_ + _nFailed_)
? "Passed: " + _nPassed_
? "Failed: " + _nFailed_
if _nFailed_ = 0
	? "ALL TESTS PASSED!"
ok
