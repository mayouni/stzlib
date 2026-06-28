# Edge-case regression suite for recently-touched paths:
# - stzYielder pure-Ring fallback (Map/Filter/Reduce, 17+17+10 ops)
# - stzListReplacer / stzListRemover string-direct engine variants
# - stzHashList engine-backed lookups
# Covers: empty input, single-item, mixed types, Unicode boundaries.

load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== Edge-case regression suite ==="

# ------------------------------------------------------------
# stzYielder: empty input
# ------------------------------------------------------------
? ""
? "--- Yielder: empty input ---"
oYe = new stzYielder([])
chk("empty Map(:Abs) = []",       isList(oYe.Map(:Abs))      and len(oYe.Map(:Abs))      = 0)
chk("empty Filter(:IsPos) = []",  isList(oYe.Filter(:IsPositive)) and len(oYe.Filter(:IsPositive)) = 0)
chk("empty Reduce(:Sum) = 0",     oYe.Reduce(:Sum) = 0)
chk("empty Reduce(:Product) = 0", oYe.Reduce(:Product) = 0)
chk("empty Reduce(:Count) = 0",   oYe.Reduce(:Count) = 0)
chk("empty ReduceConcat = ''",    oYe.ReduceConcat("-") = "")
chk("empty CountWhere = 0",       oYe.CountWhere(:IsPositive) = 0)

# ------------------------------------------------------------
# stzYielder: single-item input
# ------------------------------------------------------------
? ""
? "--- Yielder: single item ---"
oYs = new stzYielder([-7])
aS1 = oYs.Map(:Abs)
chk("single Map(:Abs) = [7]",     isList(aS1) and len(aS1) = 1 and aS1[1] = 7)
chk("single Reduce(:Sum) = -7",   oYs.Reduce(:Sum) = -7)
chk("single Reduce(:Min) = -7",   oYs.Reduce(:Min) = -7)
chk("single Reduce(:Max) = -7",   oYs.Reduce(:Max) = -7)
chk("single ReduceConcat='-7'",   oYs.ReduceConcat("-") = "-7")

# ------------------------------------------------------------
# stzYielder: mixed types (strings + numbers + null)
# ------------------------------------------------------------
? ""
? "--- Yielder: mixed types ---"
oYm = new stzYielder([1, "a", -3, "b", 5])
aM1 = oYm.Filter(:IsNumber)
chk("mixed Filter(:IsNumber)=[1,-3,5]", isList(aM1) and len(aM1) = 3 and aM1[1] = 1 and aM1[2] = -3 and aM1[3] = 5)

aM2 = oYm.Filter(:IsString)
chk("mixed Filter(:IsString)=[a,b]",    isList(aM2) and len(aM2) = 2 and aM2[1] = "a" and aM2[2] = "b")

chk("mixed Reduce(:Sum) skips strings", oYm.Reduce(:Sum) = 3)
chk("mixed CountStrings = 2",           oYm.Reduce(:CountStrings) = 2)
chk("mixed CountNumbers = 3",           oYm.Reduce(:CountNumbers) = 3)

# ------------------------------------------------------------
# stzYielder: sign / iseven on edge values
# ------------------------------------------------------------
? ""
? "--- Yielder: edge numeric ---"
oYz = new stzYielder([0, -0, 1, -1])
aZ1 = oYz.Map(:Sign)
chk("Sign of [0,-0,1,-1] = [0,0,1,-1]", isList(aZ1) and len(aZ1) = 4 and aZ1[1] = 0 and aZ1[2] = 0 and aZ1[3] = 1 and aZ1[4] = -1)

# ------------------------------------------------------------
# stzListReplacer string-direct engine path: edges
# ------------------------------------------------------------
? ""
? "--- Replacer edges ---"

# empty list
oRpE = new stzListReplacer([])
oRpE.ReplaceAllOccurrencesCS("x", "y", 1)
chk("Replacer empty list stays empty", isList(oRpE.Content()) and len(oRpE.Content()) = 0)

# needle not present
oRpN = new stzListReplacer(["a", "b", "c"])
oRpN.ReplaceAllOccurrencesCS("z", "Q", 1)
chk("Replacer no-match preserves list", oRpN.Content()[1] = "a" and oRpN.Content()[2] = "b" and oRpN.Content()[3] = "c")

# single-item match
oRp1 = new stzListReplacer(["x"])
oRp1.ReplaceAllOccurrencesCS("x", "Y", 1)
chk("Replacer single-item match", len(oRp1.Content()) = 1 and oRp1.Content()[1] = "Y")

# CI vs CS distinction
oRpCs = new stzListReplacer(["Foo", "foo"])
oRpCs.ReplaceAllOccurrencesCS("foo", "X", 1)  # CS = 1, should only hit lowercase
chk("Replacer CS only lowercase hit", oRpCs.Content()[1] = "Foo" and oRpCs.Content()[2] = "X")

# Unicode boundary: ASCII vs accented
oRpU = new stzListReplacer(["cafe", "café"])
oRpU.ReplaceAllOccurrencesCS("café", "C", 1)
chk("Replacer Unicode exact match only", oRpU.Content()[1] = "cafe" and oRpU.Content()[2] = "C")

# ------------------------------------------------------------
# stzListRemover string-direct engine path: edges
# ------------------------------------------------------------
? ""
? "--- Remover edges ---"

oRmE = new stzListRemover([])
oRmE.RemoveAllCS("x", 1)
chk("Remover empty list stays empty", isList(oRmE.Content()) and len(oRmE.Content()) = 0)

oRmN = new stzListRemover(["a", "b"])
oRmN.RemoveAllCS("z", 1)
chk("Remover no-match preserves list", oRmN.Content()[1] = "a" and oRmN.Content()[2] = "b")

oRmAll = new stzListRemover(["x", "x", "x"])
oRmAll.RemoveAllCS("x", 1)
chk("Remover removes every item", isList(oRmAll.Content()) and len(oRmAll.Content()) = 0)

oRmU = new stzListRemover(["cafe", "café", "Cafe"])
oRmU.RemoveAllCS("café", 1)
chk("Remover Unicode exact match only", len(oRmU.Content()) = 2 and oRmU.Content()[1] = "cafe" and oRmU.Content()[2] = "Cafe")

# ------------------------------------------------------------
# stzHashList engine-backed lookups: edges
# ------------------------------------------------------------
? ""
? "--- HashList edges ---"

# empty hashlist
oHe = new stzHashList([])
chk("HashList empty NumberOfPairs = 0", oHe.NumberOfPairs() = 0)
chk("HashList empty HasKey('x') = 0",   oHe.HasKey("x") = 0)
chk("HashList empty FindKey('x') = 0",  oHe.FindKey("x") = 0)

# single pair
oH1 = new stzHashList([ ["only", 42] ])
chk("HashList 1-pair NumberOfPairs",   oH1.NumberOfPairs() = 1)
chk("HashList 1-pair HasKey true",     oH1.HasKey("only") = 1)
chk("HashList 1-pair HasKey miss",     oH1.HasKey("nope") = 0)
chk("HashList 1-pair ValueInt",        oH1.ValueIntByKey("only") = 42)

# mixed value types
oHm = new stzHashList([ ["n", 7], ["f", 3.14], ["s", "hello"] ])
chk("HashList mixed int",              oHm.ValueIntByKey("n") = 7)
chk("HashList mixed float",            oHm.ValueFloatByKey("f") > 3.13 and oHm.ValueFloatByKey("f") < 3.15)
chk("HashList mixed string",           oHm.ValueStringByKey("s") = "hello")

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL EDGE CASES PASSED!"
else
	? "SOME EDGE CASES FAILED!"
ok

pf()

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
