

load "../../../stzBase.ring"

pr()

? "=== stzString Method Audit ==="
? ""

_nPassed_ = 0
_nFailed_ = 0

# --- Core ---
? "--- Core Methods ---"
o = new stzString("Hello World")
if o.Content() = "Hello World" ? "  PASS: Content()" _nPassed_++ else ? "  FAIL: Content()" _nFailed_++ ok
if o.NumberOfChars() = 11 ? "  PASS: NumberOfChars()" _nPassed_++ else ? "  FAIL: NumberOfChars()" _nFailed_++ ok
if o.NthChar(1) = "H" ? "  PASS: NthChar(1)" _nPassed_++ else ? "  FAIL: NthChar(1)" _nFailed_++ ok
if o.IsEmpty() = false ? "  PASS: IsEmpty() false" _nPassed_++ else ? "  FAIL: IsEmpty()" _nFailed_++ ok
? ""

# --- Case ---
? "--- Case Methods ---"
o2 = new stzString("hello world")
if o2.Uppercased() = "HELLO WORLD" ? "  PASS: Uppercased()" _nPassed_++ else ? "  FAIL: Uppercased()" _nFailed_++ ok
o3 = new stzString("HELLO WORLD")
if o3.Lowercased() = "hello world" ? "  PASS: Lowercased()" _nPassed_++ else ? "  FAIL: Lowercased()" _nFailed_++ ok
? ""

# --- Find ---
? "--- Find Methods ---"
o4 = new stzString("hello world hello")
aPos = o4.Find("hello")
if isList(aPos) and len(aPos) = 2 ? "  PASS: Find()" _nPassed_++ else ? "  FAIL: Find()" _nFailed_++ ok
if o4.FindFirst("hello") = 1 ? "  PASS: FindFirst()" _nPassed_++ else ? "  FAIL: FindFirst()" _nFailed_++ ok
if o4.FindLast("hello") = 13 ? "  PASS: FindLast()" _nPassed_++ else ? "  FAIL: FindLast()" _nFailed_++ ok
if o4.FindNth(2, "hello") = 13 ? "  PASS: FindNth(2)" _nPassed_++ else ? "  FAIL: FindNth(2)" _nFailed_++ ok
? ""

# --- Contains ---
? "--- Contains ---"
o5 = new stzString("Hello World")
if o5.Contains("World") ? "  PASS: Contains() true" _nPassed_++ else ? "  FAIL: Contains()" _nFailed_++ ok
if NOT o5.Contains("xyz") ? "  PASS: Contains() false" _nPassed_++ else ? "  FAIL: Contains()" _nFailed_++ ok
? ""

# --- StartsWith / EndsWith ---
? "--- StartsWith/EndsWith ---"
o6 = new stzString("Hello World")
if o6.StartsWith("Hello") ? "  PASS: StartsWith()" _nPassed_++ else ? "  FAIL: StartsWith()" _nFailed_++ ok
if o6.EndsWith("World") ? "  PASS: EndsWith()" _nPassed_++ else ? "  FAIL: EndsWith()" _nFailed_++ ok
? ""

# --- Replace ---
? "--- Replace Methods ---"
o7 = new stzString("aaa bbb aaa")
o7.Replace("aaa", "ccc")
if o7.Content() = "ccc bbb ccc" ? "  PASS: Replace() all" _nPassed_++ else ? "  FAIL: Replace(): " + o7.Content() _nFailed_++ ok

o8 = new stzString("aaa bbb aaa")
o8.ReplaceFirst("aaa", "ccc")
if o8.Content() = "ccc bbb aaa" ? "  PASS: ReplaceFirst()" _nPassed_++ else ? "  FAIL: ReplaceFirst(): " + o8.Content() _nFailed_++ ok

o9 = new stzString("aaa bbb aaa")
o9.ReplaceLast("aaa", "ccc")
if o9.Content() = "aaa bbb ccc" ? "  PASS: ReplaceLast()" _nPassed_++ else ? "  FAIL: ReplaceLast(): " + o9.Content() _nFailed_++ ok
? ""

# --- Remove ---
? "--- Remove Methods ---"
o10 = new stzString("xxHelloxxWorldxx")
o10.Remove("xx")
if o10.Content() = "HelloWorld" ? "  PASS: Remove() all" _nPassed_++ else ? "  FAIL: Remove(): " + o10.Content() _nFailed_++ ok

o11 = new stzString("xxHelloxxWorld")
o11.RemoveFirst("xx")
if o11.Content() = "HelloxxWorld" ? "  PASS: RemoveFirst()" _nPassed_++ else ? "  FAIL: RemoveFirst(): " + o11.Content() _nFailed_++ ok

o12 = new stzString("HelloxxWorldxx")
o12.RemoveLast("xx")
if o12.Content() = "HelloxxWorld" ? "  PASS: RemoveLast()" _nPassed_++ else ? "  FAIL: RemoveLast(): " + o12.Content() _nFailed_++ ok
? ""

# --- Insert ---
? "--- Insert Methods ---"
o13 = new stzString("HelloWorld")
o13.InsertBefore(6, " ")
if o13.Content() = "Hello World" ? "  PASS: InsertBefore()" _nPassed_++ else ? "  FAIL: InsertBefore(): " + o13.Content() _nFailed_++ ok

o14 = new stzString("HelloWorld")
o14.InsertAfter(5, " ")
if o14.Content() = "Hello World" ? "  PASS: InsertAfter()" _nPassed_++ else ? "  FAIL: InsertAfter(): " + o14.Content() _nFailed_++ ok
? ""

# --- Reverse ---
? "--- Reverse ---"
o15 = new stzString("Hello")
if o15.Reversed() = "olleH" ? "  PASS: Reversed()" _nPassed_++ else ? "  FAIL: Reversed()" _nFailed_++ ok
? ""

# --- Trimmed ---
? "--- Trimmed ---"
o16 = new stzString("  Hello  ")
if o16.Trimmed() = "Hello" ? "  PASS: Trimmed()" _nPassed_++ else ? "  FAIL: Trimmed()" _nFailed_++ ok
? ""

# --- Words ---
? "--- Words ---"
o17 = new stzString("Hello beautiful World")
if o17.NumberOfWords() = 3 ? "  PASS: NumberOfWords()" _nPassed_++ else ? "  FAIL: NumberOfWords()" _nFailed_++ ok
? ""

# --- Split ---
? "--- Split ---"
o18 = new stzString("a,b,c")
aS = o18.Split(",")
if isList(aS) and len(aS) = 3 ? "  PASS: Split() count" _nPassed_++ else ? "  FAIL: Split()" _nFailed_++ ok
if aS[1] = "a" and aS[3] = "c" ? "  PASS: Split() values" _nPassed_++ else ? "  FAIL: Split() values" _nFailed_++ ok
? ""

# --- Section ---
? "--- Section ---"
o19 = new stzString("Hello World")
if o19.Section(1, 5) = "Hello" ? "  PASS: Section(1,5)" _nPassed_++ else ? "  FAIL: Section(1,5)" _nFailed_++ ok
if o19.Section(7, 11) = "World" ? "  PASS: Section(7,11)" _nPassed_++ else ? "  FAIL: Section(7,11)" _nFailed_++ ok
? ""

# --- NumberOfOccurrence ---
? "--- NumberOfOccurrence ---"
o20 = new stzString("abcabcabc")
if o20.NumberOfOccurrence("abc") = 3 ? "  PASS: NumberOfOccurrence()" _nPassed_++ else ? "  FAIL: NumberOfOccurrence()" _nFailed_++ ok
? ""

# --- Copy ---
? "--- Copy ---"
o21 = new stzString("Hello")
oCopy = o21.Copy()
if oCopy.Content() = "Hello" ? "  PASS: Copy()" _nPassed_++ else ? "  FAIL: Copy()" _nFailed_++ ok
? ""

# --- Lines ---
? "--- Lines ---"
o22 = new stzString("Line1" + nl + "Line2" + nl + "Line3")
aL = o22.Lines()
if isList(aL) and len(aL) = 3 ? "  PASS: Lines() count" _nPassed_++ else ? "  FAIL: Lines()" _nFailed_++ ok
if o22.NumberOfLines() = 3 ? "  PASS: NumberOfLines()" _nPassed_++ else ? "  FAIL: NumberOfLines()" _nFailed_++ ok
? ""

# --- Chars ---
? "--- Chars ---"
o26 = new stzString("ABC")
aChars = o26.Chars()
if isList(aChars) and len(aChars) = 3 ? "  PASS: Chars() count" _nPassed_++ else ? "  FAIL: Chars()" _nFailed_++ ok
if aChars[1] = "A" and aChars[3] = "C" ? "  PASS: Chars() values" _nPassed_++ else ? "  FAIL: Chars() values" _nFailed_++ ok
? ""

# --- Repeated ---
? "--- Repeated ---"
o23 = new stzString("ab")
_cRep_ = o23.Repeated(3)
if _cRep_ = "ababab" ? "  PASS: Repeated(3)" _nPassed_++ else ? "  FAIL: Repeated(3): " + _cRep_ _nFailed_++ ok
? ""

# --- Concatenate ---
? "--- Concatenate ---"
o24 = new stzString("Hello")
o24.Concatenate(" World")
if o24.Content() = "Hello World" ? "  PASS: Concatenate()" _nPassed_++ else ? "  FAIL: Concatenate()" _nFailed_++ ok
? ""

# --- IsEqualTo ---
? "--- Equality ---"
o25 = new stzString("Hello")
if o25.IsEqualTo("Hello") ? "  PASS: IsEqualTo() true" _nPassed_++ else ? "  FAIL: IsEqualTo() true" _nFailed_++ ok
? ""

# ==================
? "=========================="
? "Total: " + (_nPassed_ + _nFailed_)
? "Passed: " + _nPassed_
? "Failed: " + _nFailed_
if _nFailed_ = 0
	? "ALL TESTS PASSED!"
ok

pf()
