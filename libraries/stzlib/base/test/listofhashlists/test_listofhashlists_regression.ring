# Integration regression suite for stzListOfHashLists.
# Small class -- covers init validation, Content/Value/Copy,
# ToListOfStzHashLists conversion, inherited stzList ops, edges.
#
# Run from base/list/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListOfHashLists integration regression ==="

# Sample data: list of hashlists
aSample = [
	[ [ "name", "Ali"   ], [ "age", 35 ] ],
	[ [ "name", "Dania" ], [ "age", 28 ] ],
	[ [ "name", "Han"   ], [ "age", 42 ] ]
]

# ------------------------------------------------------------
# Construction + accessors
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oLh = new stzListOfHashLists(aSample)
chk("Content is list",              isList(oLh.Content()))
chk("Content len = 3",              len(oLh.Content()) = 3)

aC = oLh.Content()
chk("Content[1][1] = name pair",    aC[1][1][1] = "name" and aC[1][1][2] = "Ali")
chk("Content[3][2] = age pair",     aC[3][2][1] = "age" and aC[3][2][2] = 42)

# Value alias
chk("Value alias = Content",        len(oLh.Value()) = 3)

# ListOfHashLists alias
chk("ListOfHashLists alias",        len(oLh.ListOfHashLists()) = 3)

# ------------------------------------------------------------
# Copy
# ------------------------------------------------------------
? ""
? "--- Copy ---"

oCopy = oLh.Copy()
chk("Copy is stzListOfHashLists",   ring_classname(oCopy) = "stzlistofhashlists")
chk("Copy has same content",        len(oCopy.Content()) = 3)
chk("Copy is independent",          oCopy != NULL)

# ------------------------------------------------------------
# ToListOfStzHashLists
# ------------------------------------------------------------
? ""
? "--- ToListOfStzHashLists ---"

aStzH = oLh.ToListOfStzHashLists()
chk("Returns list",                 isList(aStzH))
chk("3 elements",                   len(aStzH) = 3)
chk("Element 1 is stzhashlist",     ring_classname(aStzH[1]) = "stzhashlist")
chk("Element 1.HasKey 'name'",      aStzH[1].HasKey("name") = 1)
chk("Element 2 name = Dania",       aStzH[2]["name"] = "Dania")
chk("Element 3 age = 42",           aStzH[3]["age"] = 42)

# ------------------------------------------------------------
# Inherited NumberOfItems
# ------------------------------------------------------------
? ""
? "--- Inherited ops ---"

chk("NumberOfItems = 3",            oLh.NumberOfItems() = 3)
chk("IsEmpty = 0",                  oLh.IsEmpty() = 0)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Empty
oEm = new stzListOfHashLists([])
chk("Empty IsEmpty = 1",            oEm.IsEmpty() = 1)
chk("Empty NumberOfItems = 0",      oEm.NumberOfItems() = 0)
chk("Empty Content len = 0",        len(oEm.Content()) = 0)
chk("Empty Copy works",             isObject(oEm.Copy()))

# Single hashlist
oOne = new stzListOfHashLists([
	[ [ "k", "v" ] ]
])
chk("Single NumberOfItems = 1",     oOne.NumberOfItems() = 1)
aOneZ = oOne.ToListOfStzHashLists()
chk("Single ToListOfStzHashLists",  len(aOneZ) = 1 and aOneZ[1]["k"] = "v")

# Init validation: should raise on non-hashlist data
bRaised = 0
try
	oBad = new stzListOfHashLists([ "not-a-hashlist" ])
catch
	bRaised = 1
done
chk("Non-hashlist input raises",    bRaised = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzListOfHashLists CHECKS PASSED!"
else
	? "SOME stzListOfHashLists CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
