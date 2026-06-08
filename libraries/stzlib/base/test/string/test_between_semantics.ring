

load "../../stzBase.ring"

pr()

$nPassed = 0
$nFailed = 0

? "=== Between/BoundedBy Semantics Tests ==="
? ""

# --- Between() returns ALL matches (list) ---
? "--- Between() returns ALL matches ---"
oBounder = new stzStringBounder("[a][b][c]")
aResult = oBounder.Between("[", "]")
? "  Between multiple: " + len(aResult) + " matches"
$Assert("Between returns list of 3", len(aResult) = 3)
if len(aResult) >= 3
	$Assert("First match is a", aResult[1] = "a")
	$Assert("Second match is b", aResult[2] = "b")
	$Assert("Third match is c", aResult[3] = "c")
ok

# --- Between() single match still returns list ---
oBounder2 = new stzStringBounder("[hello]")
aResult2 = oBounder2.Between("[", "]")
$Assert("Single match returns list of 1", len(aResult2) = 1)
if len(aResult2) >= 1
	$Assert("Single match content", aResult2[1] = "hello")
ok

# --- Between() no match returns empty list ---
oBounder3 = new stzStringBounder("no brackets here")
aResult3 = oBounder3.Between("[", "]")
$Assert("No match returns empty list", len(aResult3) = 0)

? ""

# --- FirstBetween() returns single string ---
? "--- FirstBetween() returns single string ---"
oBounder4 = new stzStringBounder("[first][second][third]")
cFirst = oBounder4.FirstBetween("[", "]")
? "  FirstBetween: " + cFirst
$Assert("FirstBetween returns first match", cFirst = "first")

# FirstBetween no match
oBounder5 = new stzStringBounder("nothing")
cEmpty = oBounder5.FirstBetween("[", "]")
$Assert("FirstBetween no match returns empty", cEmpty = "")

? ""

# --- ReplaceBetween() replaces ALL ---
? "--- ReplaceBetween() replaces ALL ---"
oReplacer = new stzStringReplacer("a[x]b[y]c[z]d")
oReplacer.ReplaceBetween("[", "]", "!")
? "  ReplaceBetween all: " + oReplacer.Content()
$Assert("ReplaceBetween replaces ALL pairs", oReplacer.Content() = "a!b!c!d")

# --- ReplaceFirstBetween() replaces only first ---
? "--- ReplaceFirstBetween() replaces first only ---"
oReplacer2 = new stzStringReplacer("a[x]b[y]c[z]d")
oReplacer2.ReplaceFirstBetween("[", "]", "!")
? "  ReplaceFirstBetween: " + oReplacer2.Content()
$Assert("ReplaceFirstBetween replaces only first", oReplacer2.Content() = "a!b[y]c[z]d")

? ""

# --- RemoveBetween() removes ALL ---
? "--- RemoveBetween() removes ALL ---"
oRemover = new stzStringRemover("a[x]b[y]c")
oRemover.RemoveBetween("[", "]")
? "  RemoveBetween all: " + oRemover.Content()
$Assert("RemoveBetween removes ALL pairs", oRemover.Content() = "abc")

# --- RemoveFirstBetween() removes only first ---
? "--- RemoveFirstBetween() removes first only ---"
oRemover2 = new stzStringRemover("a[x]b[y]c")
oRemover2.RemoveFirstBetween("[", "]")
? "  RemoveFirstBetween: " + oRemover2.Content()
$Assert("RemoveFirstBetween removes only first", oRemover2.Content() = "ab[y]c")

? ""

# --- Multi-char delimiters ---
? "--- Multi-char delimiters ---"
oBounder6 = new stzStringBounder("<<hello>>world<<bye>>")
aResult6 = oBounder6.Between("<<", ">>")
$Assert("Multi-char delimiters: 2 matches", len(aResult6) = 2)
if len(aResult6) >= 2
	$Assert("Multi-char first", aResult6[1] = "hello")
	$Assert("Multi-char second", aResult6[2] = "bye")
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
