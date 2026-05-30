# Integration regression suite for stzStringList.
# Covers construction / Content, basic accessors (NthString /
# FirstString / LastString / NumberOfStrings), mutation
# (Add / Prepend / RemoveAt / ReplaceAt), find/contains, sort
# (active + passive), Reverse (session 46+++++++ fix), Unique
# (case-sensitive + case-insensitive), Concat / ConcatUsing,
# Filter, edges.
#
# Run from base/string/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzStringList integration regression ==="

# ------------------------------------------------------------
# Construction + accessors
# ------------------------------------------------------------
? ""
? "--- Construction / Accessors ---"

oSl = new stzStringList([ "alpha", "beta", "gamma", "delta" ])
chk("NumberOfStrings = 4",          oSl.NumberOfStrings() = 4)
chk("Size alias = 4",               oSl.Size() = 4)
chk("Content len = 4",              len(oSl.Content()) = 4)
chk("NthString(1) = alpha",         oSl.NthString(1) = "alpha")
chk("String(1) alias",              oSl.String(1) = "alpha")
chk("FirstString = alpha",          oSl.FirstString() = "alpha")
chk("LastString = delta",           oSl.LastString() = "delta")

# ------------------------------------------------------------
# Mutation: Add / Prepend / RemoveAt / ReplaceAt
# ------------------------------------------------------------
? ""
? "--- Mutation ---"

oSm = new stzStringList([ "b", "c" ])
oSm.Add("d")
chk("Add appends",                  oSm.NumberOfStrings() = 3 and oSm.LastString() = "d")

oSm.Prepend("a")
chk("Prepend pushes to front",      oSm.FirstString() = "a")
chk("After Prepend: 4 strings",     oSm.NumberOfStrings() = 4)

oSm.RemoveAt(2)
chk("RemoveAt(2) drops 'b'",        oSm.NumberOfStrings() = 3 and oSm.NthString(2) = "c")

oSm.ReplaceAt(1, "A")
chk("ReplaceAt(1, 'A')",            oSm.FirstString() = "A")

# ------------------------------------------------------------
# Find / Contains
# ------------------------------------------------------------
? ""
? "--- Find / Contains ---"

oSf = new stzStringList([ "foo", "Bar", "baz", "foo", "qux" ])
chk("Contains 'foo' = 1",           oSf.Contains("foo") = 1)
chk("Contains 'missing' = 0",       oSf.Contains("missing") = 0)
chk("ContainsCS 'foo' CS=1",        oSf.ContainsCS("foo", 1) = 1)
chk("ContainsCS 'BAR' CS=1 = 0",    oSf.ContainsCS("BAR", 1) = 0)
chk("ContainsCS 'BAR' CS=0 = 1",    oSf.ContainsCS("BAR", 0) = 1)

aF = oSf.FindCS("foo", 1)
chk("FindCS returns list of pos",   isList(aF) and len(aF) = 2)
chk("FindCS positions correct",     aF[1] = 1 and aF[2] = 4)

chk("FindFirst('foo') = 1",         oSf.FindFirst("foo") = 1)
chk("FindLast('foo') = 4",          oSf.FindLast("foo") = 4)

# ------------------------------------------------------------
# Sort (active + passive)
# ------------------------------------------------------------
? ""
? "--- Sort ---"

oSs = new stzStringList([ "c", "a", "b" ])
oSs.SortInAscending()
chk("Asc sort first = a",           oSs.FirstString() = "a")
chk("Asc sort last = c",            oSs.LastString() = "c")

oSsd = new stzStringList([ "c", "a", "b" ])
oSsd.SortInDescending()
chk("Desc sort first = c",          oSsd.FirstString() = "c")
chk("Desc sort last = a",           oSsd.LastString() = "a")

# Passive
oSsp = new stzStringList([ "c", "a", "b" ])
aSp = oSsp.SortedInAscending()
chk("Passive sort returns list",    isList(aSp) and aSp[1] = "a")
chk("Passive leaves self",          oSsp.FirstString() = "c")

# ------------------------------------------------------------
# Reverse (the bug fixed earlier this session)
# ------------------------------------------------------------
? ""
? "--- Reverse ---"

oSr = new stzStringList([ "a", "b", "c" ])
oSr.Reverse()
chk("Reverse: first = c",           oSr.FirstString() = "c")
chk("Reverse: last = a",            oSr.LastString() = "a")

oSrp = new stzStringList([ "x", "y", "z" ])
aRv = oSrp.Reversed()
chk("Reversed returns list",        isList(aRv) and aRv[1] = "z")
chk("Reversed leaves self",         oSrp.FirstString() = "x")

# ------------------------------------------------------------
# Unique (CS + CI)
# ------------------------------------------------------------
? ""
? "--- Unique ---"

oSu = new stzStringList([ "a", "b", "a", "c", "a", "b" ])
oSu.Unique()
chk("Unique drops dupes",           oSu.NumberOfStrings() = 3)
chk("Unique preserves first occ",   oSu.FirstString() = "a")

# Case-sensitive unique
oSuCs = new stzStringList([ "A", "a", "B", "b" ])
oSuCs.UniqueCS(1)
chk("UniqueCS=1 keeps all 4",       oSuCs.NumberOfStrings() = 4)

oSuCi = new stzStringList([ "A", "a", "B", "b" ])
oSuCi.UniqueCS(0)
chk("UniqueCS=0 keeps 2",           oSuCi.NumberOfStrings() = 2)

# ------------------------------------------------------------
# Concat / ConcatUsing
# ------------------------------------------------------------
? ""
? "--- Concat ---"

oSc = new stzStringList([ "a", "b", "c" ])
chk("Concat = 'abc'",               oSc.Concat() = "abc")
chk("ConcatUsing('-') = 'a-b-c'",   oSc.ConcatUsing("-") = "a-b-c")
chk("ConcatUsing(', ')",            oSc.ConcatUsing(", ") = "a, b, c")

# ------------------------------------------------------------
# Filter
# ------------------------------------------------------------
? ""
? "--- Filter ---"

oSfl = new stzStringList([ "apple", "banana", "apricot", "cherry", "avocado" ])
aFl = oSfl.FilterByStartsWith("a")
chk("FilterByStartsWith('a')",      isList(aFl) and len(aFl) = 3)
chk("Filter result has apple",      aFl[1] = "apple")

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Empty list
oSe = new stzStringList([])
chk("Empty NumberOfStrings = 0",    oSe.NumberOfStrings() = 0)
chk("Empty Concat = ''",            oSe.Concat() = "")

# Single item
oSi = new stzStringList([ "only" ])
chk("Single NumberOfStrings = 1",   oSi.NumberOfStrings() = 1)
chk("Single FirstString",           oSi.FirstString() = "only")
chk("Single LastString",            oSi.LastString() = "only")
chk("Single Concat = 'only'",       oSi.Concat() = "only")

# All-same
oSa = new stzStringList([ "x", "x", "x" ])
oSa.Unique()
chk("All-same Unique -> 1",         oSa.NumberOfStrings() = 1)

# Empty + Unicode
oSuStr = new stzStringList([ "café", "résumé", "naïve" ])
chk("Unicode preserved",            oSuStr.NumberOfStrings() = 3)
chk("Unicode FirstString",          oSuStr.FirstString() = "café")

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzStringList CHECKS PASSED!"
else
	? "SOME stzStringList CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
