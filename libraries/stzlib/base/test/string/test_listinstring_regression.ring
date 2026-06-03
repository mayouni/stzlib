# Integration regression suite for stzListInString.
# Parses a string-form list ("[ 1, 2, 3 ]") via eval; exposes List(),
# Content(), Items(), ItemsXT(), Copy(). Test covers parse correctness,
# accessors, ListQ + ListQRT, and edges.
#
# Run from base/list/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListInString integration regression ==="

# ------------------------------------------------------------
# Construction + parse
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oLis = new stzListInString('[ 1, 2, 3 ]')
chk("ListInString preserved",       oLis.ListInString() = '[ 1, 2, 3 ]')

aL = oLis.List()
chk("List() is list",               isList(aL))
chk("List() len = 3",               len(aL) = 3)
chk("List()[1] = 1",                aL[1] = 1)
chk("List()[3] = 3",                aL[3] = 3)

# Content alias
chk("Content alias",                len(oLis.Content()) = 3)

# Value alias
chk("Value alias",                  len(oLis.Value()) = 3)

# ------------------------------------------------------------
# ListQ / ListQRT
# ------------------------------------------------------------
? ""
? "--- ListQ / ListQRT ---"

oStzL = oLis.ListQ()
chk("ListQ returns stzList",        ring_classname(oStzL) = "stzlist")
chk("ListQ NumberOfItems = 3",      oStzL.NumberOfItems() = 3)

# ListQRT with type name (potential bug -- uses pcReturnType internally
# but param is pcType)
bRaised = 0
oStzL2 = NULL
try
	oStzL2 = oLis.ListQRT("stzList")
catch
	bRaised = 1
done
chk("ListQRT('stzList') doesn't crash", bRaised = 0)
if bRaised = 0
	chk("ListQRT returns valid object", isObject(oStzL2))
ok

# ------------------------------------------------------------
# Copy
# ------------------------------------------------------------
? ""
? "--- Copy ---"

oC = oLis.Copy()
chk("Copy is stzListInString",      ring_classname(oC) = "stzlistinstring")
chk("Copy has same content",        len(oC.List()) = 3)

# ------------------------------------------------------------
# ToStzList
# ------------------------------------------------------------
? ""
? "--- ToStzList ---"

oTL = oLis.ToStzList()
chk("ToStzList returns stzList",    ring_classname(oTL) = "stzlist")
chk("ToStzList content correct",    oTL.NumberOfItems() = 3)

# ------------------------------------------------------------
# String values
# ------------------------------------------------------------
? ""
? "--- String values ---"

oLs = new stzListInString('[ "alpha", "beta", "gamma" ]')
aLs = oLs.List()
chk("String list len = 3",          len(aLs) = 3)
chk("String list [1] = alpha",      aLs[1] = "alpha")
chk("String list [3] = gamma",      aLs[3] = "gamma")

# ------------------------------------------------------------
# Mixed (numbers + strings)
# ------------------------------------------------------------
? ""
? "--- Mixed types ---"

oMx = new stzListInString('[ 1, "two", 3 ]')
aMx = oMx.List()
chk("Mixed len = 3",                len(aMx) = 3)
chk("Mixed [1] = 1 (number)",       aMx[1] = 1)
chk("Mixed [2] = 'two' (string)",   aMx[2] = "two")
chk("Mixed [3] = 3 (number)",       aMx[3] = 3)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Empty list
oEm = new stzListInString('[]')
chk("Empty list len = 0",           len(oEm.List()) = 0)

# Single item
oOne = new stzListInString('[ 42 ]')
chk("Single item len = 1",          len(oOne.List()) = 1)
chk("Single item value",            oOne.List()[1] = 42)

# Malformed should raise
bRaised = 0
try
	oBad = new stzListInString('not a list')
catch
	bRaised = 1
done
chk("Malformed input raises",       bRaised = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzListInString CHECKS PASSED!"
else
	? "SOME stzListInString CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
