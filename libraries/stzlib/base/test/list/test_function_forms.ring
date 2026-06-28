# Function-form sweep: for recently-touched submodules verify the
# four canonical forms behave per contract:
#   Active  : mutates self, no return
#   Q       : mutates self, returns This (chainable)
#   Passive : leaves self untouched, returns new value
#   CS / non-CS : both code paths reachable
#
# Targets:
#   stzListRemover, stzListReplacer, stzListExtractor,
#   stzListTrimmer, stzListStringify, stzHashList

load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== Function-form sweep ==="

# ----------------------------------------------------------------
# stzListRemover
# ----------------------------------------------------------------
? ""
? "--- Remover forms ---"

# Active
oRm = new stzListRemover(["a", "b", "a", "c"])
oRm.RemoveAll("a")
chk("Remover.RemoveAll mutates self", len(oRm.Content()) = 2 and oRm.Content()[1] = "b")

# Q (fluent)
oRmQ = new stzListRemover(["a", "b", "a", "c"])
ret = oRmQ.RemoveAllQ("a")
chk("Remover.RemoveAllQ mutates self",    len(oRmQ.Content()) = 2)
chk("Remover.RemoveAllQ returns This",    isObject(ret))
# Chain test
oRmCh = new stzListRemover(["a", "a", "b", "b", "c"])
oRmCh.RemoveAllQ("a").RemoveAllQ("b")
chk("Remover Q chain works",              len(oRmCh.Content()) = 1 and oRmCh.Content()[1] = "c")

# Passive
oRmP = new stzListRemover(["a", "b", "a", "c"])
aPas = oRmP.AllOccurrencesRemoved("a")
chk("Remover passive returns new",        len(aPas) = 2 and aPas[1] = "b")
chk("Remover passive leaves self",        len(oRmP.Content()) = 4 and oRmP.Content()[1] = "a")

# CS / non-CS reachability
oRmCs = new stzListRemover(["Foo", "foo", "FOO"])
oRmCs.RemoveAllCS("foo", 1)  # CS
chk("Remover RemoveAllCS CS=1",           len(oRmCs.Content()) = 2)

oRmCi = new stzListRemover(["Foo", "foo", "FOO"])
oRmCi.RemoveAllCS("foo", 0)  # CI
chk("Remover RemoveAllCS CS=0",           len(oRmCi.Content()) = 0)

# ----------------------------------------------------------------
# stzListReplacer
# ----------------------------------------------------------------
? ""
? "--- Replacer forms ---"

# Active
oRp = new stzListReplacer(["a", "b", "a"])
oRp.ReplaceAllOccurrencesCS("a", "X", 1)
chk("Replacer Active mutates",            oRp.Content()[1] = "X" and oRp.Content()[3] = "X")

# Passive
oRpP = new stzListReplacer(["a", "b", "a"])
aRet = oRpP.AllOccurrencesReplacedCS("a", "X", 1)
chk("Replacer passive returns new",       aRet[1] = "X" and aRet[3] = "X")
chk("Replacer passive leaves self",       oRpP.Content()[1] = "a")

# CS / non-CS reachability
oRpCs = new stzListReplacer(["Foo", "foo"])
oRpCs.ReplaceAllOccurrencesCS("foo", "X", 1)
chk("Replacer CS=1 only lowercase",       oRpCs.Content()[1] = "Foo" and oRpCs.Content()[2] = "X")

oRpCi = new stzListReplacer(["Foo", "foo"])
oRpCi.ReplaceAllOccurrencesCS("foo", "X", 0)
chk("Replacer CS=0 both hit",             oRpCi.Content()[1] = "X" and oRpCi.Content()[2] = "X")

# ReplaceAt (single-position engine path)
oRpAt = new stzListReplacer(["a", "b", "c"])
oRpAt.ReplaceAt(2, "X")
chk("Replacer ReplaceAt mutates",         oRpAt.Content()[2] = "X")

# ----------------------------------------------------------------
# stzListExtractor (fixed session-recent bugs)
# ----------------------------------------------------------------
? ""
? "--- Extractor forms ---"

oEx = new stzListExtractor([1, "a", 2, "b", 3])
aStrs = oEx.ExtractStrings()
chk("Extractor.ExtractStrings result",    isList(aStrs) and len(aStrs) = 2 and aStrs[1] = "a" and aStrs[2] = "b")
# After extract, those positions should be gone from self
chk("Extractor ExtractStrings mutates",   len(oEx.Content()) = 3)

oEx2 = new stzListExtractor([1, "a", 2, "b", 3])
aNbrs = oEx2.ExtractNumbers()
chk("Extractor.ExtractNumbers result",    len(aNbrs) = 3 and aNbrs[1] = 1)
chk("Extractor ExtractNumbers mutates",   len(oEx2.Content()) = 2)

# Extract nth
oEx3 = new stzListExtractor(["a", "b", "c"])
v = oEx3.ExtractNth(2)
chk("Extractor.ExtractNth returns item",  v = "b")
chk("Extractor.ExtractNth mutates",       len(oEx3.Content()) = 2 and oEx3.Content()[2] = "c")

# ----------------------------------------------------------------
# stzListTrimmer (fixed Copy().Q pattern)
# ----------------------------------------------------------------
? ""
? "--- Trimmer forms ---"

# Active TrimmedCS-like
oTr = new stzListTrimmer(["", "a", "", "b", ""])
oTr.Compact()
chk("Trimmer Compact removes empties",    len(oTr.Content()) = 2 and oTr.Content()[1] = "a")

# Passive (verifies Copy().Q fix)
oTrP = new stzListTrimmer(["", "a", "", "b"])
aCp = oTrP.Compacted()
chk("Trimmer Compacted returns new",      isList(aCp) and len(aCp) = 2)
chk("Trimmer Compacted leaves self",      len(oTrP.Content()) = 4)

# ----------------------------------------------------------------
# stzHashList (cached engine path)
# ----------------------------------------------------------------
? ""
? "--- HashList forms ---"

oH = new stzHashList([ ["a", 1], ["b", 2], ["c", 3] ])
chk("HashList NumberOfPairs",             oH.NumberOfPairs() = 3)
chk("HashList HasKey hit",                oH.HasKey("b") = 1)
chk("HashList HasKey miss",               oH.HasKey("zz") = 0)
chk("HashList FindKey",                   oH.FindKey("c") = 3)
chk("HashList ValueIntByKey",             oH.ValueIntByKey("b") = 2)

# Mutation invalidates cache
oH.AddPair(["d", 4])
chk("HashList post-mutation NumberOfPairs", oH.NumberOfPairs() = 4)
chk("HashList post-mutation HasKey('d')",   oH.HasKey("d") = 1)
chk("HashList post-mutation ValueIntByKey", oH.ValueIntByKey("d") = 4)

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL FORM-CONTRACT CHECKS PASSED!"
else
	? "SOME FORM-CONTRACT CHECKS FAILED!"
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
