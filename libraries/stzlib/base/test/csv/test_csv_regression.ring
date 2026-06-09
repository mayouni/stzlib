# Integration regression suite for stzCSV.
# stzCSV is module-level funcs (no class): ListToCSV/XT,
# StringToCSVList/XT, IsCSV/XT, CSVSeparator/SetCSVSeparator, plus
# the List2DToCSVXT alias.
#
# Run from base/file/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzCSV integration regression ==="

# Sample 2D list: column-major shape used by ListToCSVXT.
#   [ [header1, [v1, v2, v3]],
#     [header2, [v1, v2, v3]], ... ]
aSample = [
	[ "NAME", [ "Ali", "Dania", "Han" ] ],
	[ "AGE",  [ 35,    28,      42    ] ]
]

# ------------------------------------------------------------
# Separator
# ------------------------------------------------------------
? ""
? "--- Separator ---"

cOriginal = CSVSeparator()
chk("Default separator is non-empty", isString(cOriginal) and len(cOriginal) > 0)

SetCSVSeparator(";")
chk("SetCSVSeparator(';') sticks",   CSVSeparator() = ";")

SetCSVSeparator(",")
chk("SetCSVSeparator(',') sticks",   CSVSeparator() = ",")

# Restore
SetCSVSeparator(cOriginal)

# ------------------------------------------------------------
# ListToCSV / ListToCSVXT
# ------------------------------------------------------------
? ""
? "--- ListToCSV / XT ---"

SetCSVSeparator(";")
cCsv = ListToCSV(aSample)
chk("ListToCSV returns string",       isString(cCsv) and len(cCsv) > 0)
chk("Header line present",            substr(cCsv, "NAME") > 0 and substr(cCsv, "AGE") > 0)
chk("Data 'Ali' present",             substr(cCsv, "Ali") > 0)
chk("Data '28' present",              substr(cCsv, "28") > 0)
chk("Uses ; separator",               substr(cCsv, ";") > 0)

# XT variant with custom separator
cCsvPipe = ListToCSVXT(aSample, "|")
chk("XT with '|' separator",          substr(cCsvPipe, "|") > 0)
chk("XT with '|' no ;",               substr(cCsvPipe, ";") = 0)

# List2DToCSVXT alias (latent-bug catcher: alias used wrong target)
cCsvAlias = List2DToCSVXT(aSample, ",")
chk("List2DToCSVXT alias works",      isString(cCsvAlias) and len(cCsvAlias) > 0)
chk("Alias uses , separator",         substr(cCsvAlias, ",") > 0)

# ------------------------------------------------------------
# StringToCSVList / XT
# ------------------------------------------------------------
? ""
? "--- StringToCSVList / XT ---"

SetCSVSeparator(";")
cIn = "NAME;AGE" + NL + "Ali;35" + NL + "Dania;28" + NL + "Han;42"
aBack = StringToCSVList(cIn)
chk("Parse returns 2D list",          isList(aBack) and len(aBack) = 2)
chk("Parsed col1 header = NAME",      aBack[1][1] = "NAME")
chk("Parsed col2 header = AGE",       aBack[2][1] = "AGE")
chk("Parsed col1 has 3 vals",         len(aBack[1][2]) = 3)
chk("Parsed val Ali",                 aBack[1][2][1] = "Ali")
chk("Parsed val 35 (number)",         aBack[2][2][1] = 35)

# XT with custom separator (latent-bug catcher: cSep param may be ignored)
cInPipe = "X|Y" + NL + "10|20" + NL + "30|40"
aBackPipe = StringToCSVListXT(cInPipe, "|")
chk("XT parse with | separator",      isList(aBackPipe) and len(aBackPipe) = 2)
chk("XT parse col1 header X",         aBackPipe[1][1] = "X")
chk("XT parse first val 10",          aBackPipe[1][2][1] = 10)

# ------------------------------------------------------------
# Round-trip (List -> CSV -> List)
# ------------------------------------------------------------
? ""
? "--- Round-trip ---"

SetCSVSeparator(";")
cMid = ListToCSV(aSample)
aRt = StringToCSVList(cMid)
chk("Round-trip preserves headers",   aRt[1][1] = "NAME" and aRt[2][1] = "AGE")
chk("Round-trip preserves row count", len(aRt[1][2]) = 3 and len(aRt[2][2]) = 3)
chk("Round-trip preserves Ali",       aRt[1][2][1] = "Ali")
chk("Round-trip preserves Han",       aRt[1][2][3] = "Han")
chk("Round-trip preserves age 35",    aRt[2][2][1] = 35)

# ------------------------------------------------------------
# IsCSV / IsCSVXT
# ------------------------------------------------------------
? ""
? "--- IsCSV ---"

cValid = "a;b;c" + NL + "1;2;3"
chk("IsCSV on valid string",          IsCSV(cValid) = 1)

# Non-CSV plain text
chk("IsCSV on plain text",            IsCSV("hello world") = 0)

# ------------------------------------------------------------
# Edge cases
# ------------------------------------------------------------
? ""
? "--- Edges ---"

SetCSVSeparator(";")

# Single column
aSingleCol = [ [ "ONLY", [ "a", "b", "c" ] ] ]
cSc = ListToCSV(aSingleCol)
chk("Single-col -> CSV",              isString(cSc) and substr(cSc, "ONLY") > 0)
aScBack = StringToCSVList(cSc)
chk("Single-col round-trip",          aScBack[1][1] = "ONLY" and len(aScBack[1][2]) = 3)

# Single row
aSingleRow = [
	[ "A", [ 1 ] ],
	[ "B", [ 2 ] ],
	[ "C", [ 3 ] ]
]
cSr = ListToCSV(aSingleRow)
chk("Single-row -> CSV",              substr(cSr, "A") > 0 and substr(cSr, "1") > 0)

# Restore
SetCSVSeparator(cOriginal)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzCSV CHECKS PASSED!"
else
	? "SOME stzCSV CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
