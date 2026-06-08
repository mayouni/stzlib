

load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzString Delegation Tests ==="

# --- Checker: Palindrome ---
? ""
? "--- Palindrome ---"

o = new stzString("racecar")
nTtl++
if o.IsPalindrome()
	? "  PASS: IsPalindrome racecar"
	nPsd++
else
	? "  FAIL: IsPalindrome racecar"
	nFld++
ok

o = new stzString("hello")
nTtl++
if NOT o.IsPalindrome()
	? "  PASS: IsPalindrome hello (false)"
	nPsd++
else
	? "  FAIL: IsPalindrome hello (should be false)"
	nFld++
ok

# --- Checker: Case checks ---
? ""
? "--- Case Checks ---"

o = new stzString("HELLO")
nTtl++
if o.IsUppercase()
	? "  PASS: IsUppercase HELLO"
	nPsd++
else
	? "  FAIL: IsUppercase HELLO"
	nFld++
ok

o = new stzString("hello")
nTtl++
if o.IsLowercase()
	? "  PASS: IsLowercase hello"
	nPsd++
else
	? "  FAIL: IsLowercase hello"
	nFld++
ok

o = new stzString("Hello")
nTtl++
if o.IsCapitalcase()
	? "  PASS: IsCapitalcase Hello"
	nPsd++
else
	? "  FAIL: IsCapitalcase Hello"
	nFld++
ok

# --- Checker: Number representation ---
? ""
? "--- Number Representation ---"

o = new stzString("12345")
nTtl++
if o.RepresentsInteger()
	? "  PASS: RepresentsInteger 12345"
	nPsd++
else
	? "  FAIL: RepresentsInteger 12345"
	nFld++
ok

o = new stzString("hello")
nTtl++
if NOT o.RepresentsInteger()
	? "  PASS: RepresentsInteger hello (false)"
	nPsd++
else
	? "  FAIL: RepresentsInteger hello (should be false)"
	nFld++
ok

# --- Checker: Structural ---
? ""
? "--- Structural Checks ---"

o = new stzString("   ")
nTtl++
if o.ContainsOnlySpaces()
	? "  PASS: ContainsOnlySpaces"
	nPsd++
else
	? "  FAIL: ContainsOnlySpaces"
	nFld++
ok

o = new stzString("abcdef")
nTtl++
if o.ContainsOnlyLetters()
	? "  PASS: ContainsOnlyLetters abcdef"
	nPsd++
else
	? "  FAIL: ContainsOnlyLetters abcdef"
	nFld++
ok

# --- Checker: Balanced ---
o = new stzString("(a[b]c)")
nTtl++
if o.IsBalanced()
	? "  PASS: IsBalanced (a[b]c)"
	nPsd++
else
	? "  FAIL: IsBalanced (a[b]c)"
	nFld++
ok

o = new stzString("(a[b)c]")
nTtl++
if NOT o.IsBalanced()
	? "  PASS: IsBalanced (a[b)c] (false)"
	nPsd++
else
	? "  FAIL: IsBalanced (a[b)c] (should be false)"
	nFld++
ok

# --- Checker: Regex match ---
? ""
? "--- Regex Match ---"

o = new stzString("hello123")
nTtl++
if o.MatchesRegex("^[a-z]+[0-9]+$")
	? "  PASS: MatchesRegex hello123"
	nPsd++
else
	? "  FAIL: MatchesRegex hello123"
	nFld++
ok

# --- Finder: SubStrings ---
? ""
? "--- Finder Delegations ---"

o = new stzString("abc")
aSubs = o.SubStrings()
nTtl++
if len(aSubs) > 0
	? "  PASS: SubStrings abc count=" + len(aSubs)
	nPsd++
else
	? "  FAIL: SubStrings abc returned empty"
	nFld++
ok

# --- Finder: FindAllChar ---
o = new stzString("abacada")
aPos = o.FindAllChar("a")
nTtl++
if len(aPos) = 4
	? "  PASS: FindAllChar a in abacada count=4"
	nPsd++
else
	? "  FAIL: FindAllChar a in abacada got=" + len(aPos)
	nFld++
ok

# --- Finder: FindAsSections ---
o = new stzString("hello world hello")
aSecs = o.FindAsSections("hello")
nTtl++
if len(aSecs) = 2
	? "  PASS: FindAsSections hello count=2"
	nPsd++
else
	? "  FAIL: FindAsSections hello got=" + len(aSecs)
	nFld++
ok

# --- Finder: FindBoundedByAsSections ---
o = new stzString("[hello] and [world]")
aSecs = o.FindBoundedByAsSections(["[", "]"])
nTtl++
if len(aSecs) = 2
	? "  PASS: FindBoundedByAsSections count=2"
	nPsd++
else
	? "  FAIL: FindBoundedByAsSections got=" + len(aSecs)
	nFld++
ok

# --- Finder: Regex find ---
o = new stzString("abc 123 def 456")
nPos = o.FindFirstRegex("[0-9]+")
nTtl++
if nPos > 0
	? "  PASS: FindFirstRegex [0-9]+ pos=" + nPos
	nPsd++
else
	? "  FAIL: FindFirstRegex [0-9]+"
	nFld++
ok

aAllPos = o.FindAllRegex("[0-9]+")
nTtl++
if len(aAllPos) = 2
	? "  PASS: FindAllRegex [0-9]+ count=2"
	nPsd++
else
	? "  FAIL: FindAllRegex [0-9]+ got=" + len(aAllPos)
	nFld++
ok

# --- Counter delegations ---
? ""
? "--- Counter Delegations ---"

o = new stzString("abcabcabc")
nTtl++
nCnt = o.Count("abc")
if nCnt = 3
	? "  PASS: Count abc=3"
	nPsd++
else
	? "  FAIL: Count abc got=" + nCnt
	nFld++
ok

# --- Splitter delegations ---
? ""
? "--- Splitter Delegations ---"

o = new stzString("hello world foo")
aParts = o.Partition("world")
nTtl++
if isList(aParts) and len(aParts) = 3
	? "  PASS: Partition world parts=3"
	nPsd++
else
	? "  FAIL: Partition world"
	nFld++
ok

# --- Remover delegations ---
? ""
? "--- Remover Delegations ---"

o = new stzString("hello world")
o.RemoveSpaces()
nTtl++
if o.Content() = "helloworld"
	? "  PASS: RemoveSpaces"
	nPsd++
else
	? "  FAIL: RemoveSpaces got=" + o.Content()
	nFld++
ok

o = new stzString("abcdef")
o.RemoveCharAt(3)
nTtl++
if o.Content() = "abdef"
	? "  PASS: RemoveCharAt(3)"
	nPsd++
else
	? "  FAIL: RemoveCharAt(3) got=" + o.Content()
	nFld++
ok

o = new stzString("abcdef")
o.RemoveRange(2, 3)
nTtl++
if o.Content() = "aef"
	? "  PASS: RemoveRange(2,3)"
	nPsd++
else
	? "  FAIL: RemoveRange(2,3) got=" + o.Content()
	nFld++
ok

# --- FindFirstST ---
? ""
? "--- FindFirstST ---"

o = new stzString("abc abc abc")
nPos = o.FindFirstST("abc", 5)
nTtl++
if nPos = 5
	? "  PASS: FindFirstST abc from 5 = " + nPos
	nPsd++
else
	? "  FAIL: FindFirstST abc from 5 got=" + nPos
	nFld++
ok

# --- Comparator delegations ---
? ""
? "--- Comparator Delegations ---"

o = new stzString("hello")
nDist = o.LevenshteinDistanceWith("hallo")
nTtl++
if isNumber(nDist) and nDist > 0
	? "  PASS: LevenshteinDistanceWith dist=" + nDist
	nPsd++
else
	? "  FAIL: LevenshteinDistanceWith"
	nFld++
ok

o = new stzString("hello")
nJaro = o.JaroSimilarityWith("hallo")
nTtl++
if isNumber(nJaro) and nJaro > 0
	? "  PASS: JaroSimilarityWith val=" + nJaro
	nPsd++
else
	? "  FAIL: JaroSimilarityWith"
	nFld++
ok

o = new stzString("hello world")
cSoundex = o.Soundex()
nTtl++
if isString(cSoundex) and cSoundex != ""
	? "  PASS: Soundex = " + cSoundex
	nPsd++
else
	? "  FAIL: Soundex"
	nFld++
ok

o = new stzString("hello")
nTtl++
if o.IsLessThan("world")
	? "  PASS: IsLessThan hello < world"
	nPsd++
else
	? "  FAIL: IsLessThan hello < world"
	nFld++
ok

o = new stzString("programming")
cPrefix = o.CommonPrefixWith("program")
nTtl++
if cPrefix = "program"
	? "  PASS: CommonPrefixWith = program"
	nPsd++
else
	? "  FAIL: CommonPrefixWith got=" + cPrefix
	nFld++
ok

# --- Text delegations ---
? ""
? "--- Text Delegations ---"

o = new stzString("Hello World Ring")
cFirst = o.FirstWord()
nTtl++
if cFirst = "Hello"
	? "  PASS: FirstWord = Hello"
	nPsd++
else
	? "  FAIL: FirstWord got=" + cFirst
	nFld++
ok

cLast = o.LastWord()
nTtl++
if cLast = "Ring"
	? "  PASS: LastWord = Ring"
	nPsd++
else
	? "  FAIL: LastWord got=" + cLast
	nFld++
ok

nTtl++
if o.ContainsWord("World")
	? "  PASS: ContainsWord World"
	nPsd++
else
	? "  FAIL: ContainsWord World"
	nFld++
ok

# --- Encoder delegations ---
? ""
? "--- Encoder Delegations ---"

o = new stzString("Hello World")
cUrl = o.UrlEncoded()
nTtl++
if isString(cUrl) and cUrl != ""
	? "  PASS: UrlEncoded = " + cUrl
	nPsd++
else
	? "  FAIL: UrlEncoded"
	nFld++
ok

o = new stzString("<b>test</b>")
cHtml = o.HtmlEncoded()
nTtl++
if isString(cHtml) and cHtml != ""
	? "  PASS: HtmlEncoded = " + cHtml
	nPsd++
else
	? "  FAIL: HtmlEncoded"
	nFld++
ok

# --- Formatter delegations ---
? ""
? "--- Formatter Delegations ---"

o = new stzString("hello")
cPadded = o.PaddedLeft(10, ".")
nTtl++
if cPadded = ".....hello"
	? "  PASS: PaddedLeft = " + cPadded
	nPsd++
else
	? "  FAIL: PaddedLeft got=" + cPadded
	nFld++
ok

o = new stzString("hello")
cPadded = o.PaddedRight(10, ".")
nTtl++
if cPadded = "hello....."
	? "  PASS: PaddedRight = " + cPadded
	nPsd++
else
	? "  FAIL: PaddedRight got=" + cPadded
	nFld++
ok

# --- LeadTrail delegations ---
? ""
? "--- LeadTrail Delegations ---"

o = new stzString("http://example.com")
o.EnsurePrefix("http://")
nTtl++
if o.Content() = "http://example.com"
	? "  PASS: EnsurePrefix already present"
	nPsd++
else
	? "  FAIL: EnsurePrefix got=" + o.Content()
	nFld++
ok

o = new stzString("example.com")
o.EnsurePrefix("http://")
nTtl++
if o.Content() = "http://example.com"
	? "  PASS: EnsurePrefix added"
	nPsd++
else
	? "  FAIL: EnsurePrefix got=" + o.Content()
	nFld++
ok

o = new stzString("file.txt")
o.EnsureSuffix(".txt")
nTtl++
if o.Content() = "file.txt"
	? "  PASS: EnsureSuffix already present"
	nPsd++
else
	? "  FAIL: EnsureSuffix got=" + o.Content()
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
