# CSV STRESS -- parsing, round trips, and the two ways a CSV parser gets
# DANGEROUS.
#
# A CSV parser has three failure sites, and this goes at all three:
#
#   1. THE SEPARATOR INSIDE A FIELD. "a,b" as a single quoted field must not
#      split into two. A naive split() has no idea quotes exist, so a comma
#      in an address or a semicolon in a note silently shreds the row.
#   2. TREATING DATA AS CODE. This parser used to eval() any cell that looked
#      like a list -- so a cell "[1+1]" EXECUTED as Ring code and became [2].
#      A data file could run anything. A value is never code.
#   3. LOSSY TYPE COERCION. "007" is a zip code, not the number 7; "" is an
#      empty field, not 0. Coercing must never lose what the cell said.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder.
#
# Ring traps avoided: main code before the first func; no local oR / nL / Try
# / Show; double-quote built via char(34).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cQ    = char(34)                                        # double quote
cAr   = MkW([ 0x0639, 0x0631, 0x0628, 0x064A ])         # Arabic
cCJK  = MkW([ 0x6771, 0x4EAC ])                         # CJK
cHeb  = MkW([ 0x05E9, 0x05DC ])                         # Hebrew

? "-- Scene 1: a separator INSIDE a quoted field must not split the row --"
cQuoted = "name;note" + nl +
          "Alice;" + cQ + "hello; world" + cQ + nl +
          "Bob;plain"
oA = CSVToListXT(cQuoted, ";")
chk("two columns, not three", len(oA) = 2)
chk("the quoted 'hello; world' stays ONE field", oA[2][2][1] = "hello; world")
chk("...and the plain field is untouched", oA[2][2][2] = "plain")

# An escaped double-quote inside a quoted field unescapes: the field
# "he said ""hi""" (outer quotes delimit, inner "" -> ") becomes  he said "hi"
cInner = cQ + "he said " + cQ + cQ + "hi" + cQ + cQ + cQ    # the quoted field
cEsc = "a;b" + nl + "x;" + cInner
oE = CSVToListXT(cEsc, ";")
chk("a doubled quote inside a quoted field becomes one quote",
	oE[2][2][1] = "he said " + cQ + "hi" + cQ)

? ""
? "-- Scene 2: a cell that looks like code is DATA, never executed --"
# The old parser ran eval('_item_ = ' + cell). "[1+1]" became [2]; anything
# could run.
cInj = "a;b" + nl + "[1+1];x"
oI = CSVToListXT(cInj, ";")
chk("cell '[1+1]' is the literal string, NOT the evaluated [2]", oI[1][2][1] = "[1+1]")
cInj2 = "a;b" + nl + "[1,2,3];y"
oI2 = CSVToListXT(cInj2, ";")
chk("cell '[1,2,3]' is a string too, not a parsed list", oI2[1][2][1] = "[1,2,3]")

? ""
? "-- Scene 3: coercion is lossless -- it keeps what the cell said --"
cCoerce = "id;label" + nl + "007;a" + nl + "042;b" + nl + "9;c"
oC = CSVToListXT(cCoerce, ";")
chk("'007' keeps its leading zeros (was corrupted to 7)", oC[1][2][1] = "007")
chk("'042' keeps its leading zero", oC[1][2][2] = "042")
chk("a clean '9' still coerces to the number 9", oC[1][2][3] = 9 and isNumber(oC[1][2][3]))

# An empty field is empty text, not the number zero.
cEmpty = "a;b;c" + nl + "1;;3"
oM = CSVToListXT(cEmpty, ";")
chk("an empty field stays the empty string, not 0", oM[2][2][1] = "")
chk("...and its neighbours are intact", oM[1][2][1] = 1 and oM[3][2][1] = 3)

# The documented, tested contract: a clean integer coerces to a number.
cNum = "name,age" + nl + "Ali,35" + nl + "Dania,28"
oN = CSVToListXT(cNum, ",")
chk("a clean integer coerces to a NUMBER (the pinned contract)",
	oN[2][2][1] = 35 and isNumber(oN[2][2][1]))

? ""
? "-- Scene 4: the round trip, column data <-> CSV --"
aData = [ [ "name", [ "Alice", "Bob", "Carol" ] ],
	  [ "age",  [ 30, 25, 41 ] ] ]
cEmit = ListToCSV(aData)
aBack = CSVToList(cEmit)
chk("column data survives emit-then-parse byte for byte", @@(aBack) = @@(aData))

# Headerless input gets synthetic COLn names.
cNoHdr = "1;2;3" + nl + "4;5;6"
oH = CSVToListXT(cNoHdr, ";")
chk("a numeric first row is treated as DATA, columns named COL1..", oH[1][1] = "COL1")
chk("...and the first row's values are kept", oH[1][2][1] = 1 and oH[1][2][2] = 4)

? ""
? "-- Scene 5: multibyte, in content and in the separator --"
cML = "who;what" + nl + cAr + ";" + cCJK + nl + cHeb + ";plain"
oML = CSVToListXT(cML, ";")
chk("an Arabic cell reads back byte-identical", oML[1][2][1] = cAr)
chk("a CJK cell reads back byte-identical", oML[2][2][1] = cCJK)
chk("a Hebrew cell reads back byte-identical", oML[1][2][2] = cHeb)

# A multi-byte separator uses the codepoint-aware fallback.
cSepMB = "a::b" + nl + "1::2" + nl + "3::4"
oSMB = CSVToListXT(cSepMB, "::")
chk("a multibyte separator '::' still splits into 2 columns", len(oSMB) = 2)
chk("...with the right values", oSMB[1][2][1] = 1 and oSMB[2][2][2] = 4)

? ""
? "-- Scene 6: custom single-byte separators --"
cPipe = "X|Y" + nl + "10|20" + nl + "30|40"
oP = CSVToListXT(cPipe, "|")
chk("pipe separator, first value 10", oP[1][2][1] = 10)
cTab = "a" + char(9) + "b" + nl + "1" + char(9) + "2"
oT = CSVToListXT(cTab, char(9))
chk("tab separator splits into 2 columns", len(oT) = 2)

? ""
? "-- Scene 7: IsCSV, and malformed input rejected --"
chk("well-formed CSV is recognised", IsCSVXT("a,b" + nl + "1,2", ","))
chk("a plain sentence is not CSV", IsCSVXT("just a sentence", ",") = 0)
# Ragged rows are not valid CSV -- rectangular is the contract.
chk("a ragged row is rejected as invalid", IsCSVXT("a;b;c" + nl + "1;2", ";") = 0)

? ""
? "-- Scene 8: scale --"
cBig = "id;name;score"
for i = 1 to 5000
	cBig += nl + i + ";user " + i + " " + cAr + ";" + (i * 3)
next
t0 = clock()
oBig = CSVToListXT(cBig, ";")
tParse = (clock() - t0) / clockspersecond()
? "  5000 rows parsed in " + tParse + " s"
chk("parsing 5000 rows is fast and LINEAR (< 2s)", tParse < 2)
chk("all three columns are present", len(oBig) = 3)
chk("every row landed (5000 values per column)", len(oBig[1][2]) = 5000)
chk("the last row is intact", oBig[1][2][5000] = 5000 and oBig[3][2][5000] = 15000)
chk("a multibyte cell deep in the file is intact",
	oBig[2][2][1000] = "user 1000 " + cAr)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

# codepoint -> UTF-8 bytes, by arithmetic (no literals -> no mojibake risk)
func EncCp c
	if c < 128
		return char(c)
	but c < 2048
		return char(192 + floor(c/64)) + char(128 + (c % 64))
	but c < 65536
		return char(224 + floor(c/4096)) + char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	else
		return char(240 + floor(c/262144)) + char(128 + floor((c%262144)/4096)) +
		       char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	ok

func MkW aCp
	cW = ""
	_nCount_ = len(aCp)
	for _k_ = 1 to _nCount_
		cW += EncCp(aCp[_k_])
	next
	return cW
