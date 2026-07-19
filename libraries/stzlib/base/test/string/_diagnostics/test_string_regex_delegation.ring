

load "../../../stzBase.ring"

pr()

$nPassed = 0
$nFailed = 0

? "=== String-Level Regex Engine Delegation Tests ==="
? ""

# --- CHECKER: MatchesRegex ---
? "--- Checker: MatchesRegex ---"
oCheck = new stzStringChecker("hello world 123")
$Assert("MatchesRegex digits", oCheck.MatchesRegex("\d+") = 1)
$Assert("MatchesRegex no match", oCheck.MatchesRegex("^xyz$") = 0)

oCheck2 = new stzStringChecker("Hello World")
$Assert("MatchesRegexCS case-sensitive", oCheck2.MatchesRegexCS("hello", :CaseSensitive = 0) = 1)

? ""

# --- COUNTER: CountRegex ---
? "--- Counter: CountRegex ---"
oCount = new stzStringCounter("abc 123 def 456 ghi 789")
nRegexCount = oCount.CountRegex("\d+")
? "  CountRegex digits: " + nRegexCount
$Assert("CountRegex 3 digit groups", nRegexCount = 3)

nRegexCount2 = oCount.CountRegex("[a-z]+")
? "  CountRegex alpha: " + nRegexCount2
$Assert("CountRegex 3 alpha groups", nRegexCount2 = 3)

? ""

# --- FINDER: FindFirstRegex / FindAllRegex ---
? "--- Finder: FindFirstRegex / FindAllRegex ---"
oFind = new stzStringFinder("one two three four")
nFirst = oFind.FindFirstRegex("\b\w{4}\b")
? "  FindFirstRegex 4-letter word: " + nFirst
$Assert("FindFirstRegex returns pos", nFirst >= 1)

oFind2 = new stzStringFinder("abc 123 def 456")
aAll = oFind2.FindAllRegex("\d+")
? "  FindAllRegex digit groups: " + len(aAll)
$Assert("FindAllRegex finds 2 groups", len(aAll) = 2)

? ""

# --- REPLACER: ReplaceAllRegex ---
? "--- Replacer: ReplaceAllRegex ---"
oRepl = new stzStringReplacer("Hello 123 World 456")
cBefore = oRepl.Content()
cAfter = oRepl.AllRegexReplaced("\d+", "NUM")
? "  Before: " + cBefore
? "  After:  " + cAfter
$Assert("RegexReplaceAll digits", cAfter = "Hello NUM World NUM")

? ""

# --- SPLITTER: SplitByRegex ---
? "--- Splitter: SplitByRegex ---"
oSplit = new stzStringSplitter("one;two,three:four")
aParts = oSplit.SplitByRegex("[;,:]")
? "  SplitByRegex parts: " + len(aParts)
$Assert("SplitByRegex 4 parts", len(aParts) = 4)

if len(aParts) >= 4
	$Assert("SplitByRegex first", aParts[1] = "one")
	$Assert("SplitByRegex last", aParts[4] = "four")
ok

? ""

# --- SUMMARY ---
? "================================"
? "Total: " + ($nPassed + $nFailed)
? "Passed: " + $nPassed
? "Failed: " + $nFailed
if $nFailed = 0
	? "ALL TESTS PASSED!"
else
	? "SOME TESTS FAILED!"
ok


func $Assert(cName, bResult)
	if bResult
		? "  PASS: " + cName
		$nPassed++
	else
		? "  FAIL: " + cName
		$nFailed++
	ok

pf()
