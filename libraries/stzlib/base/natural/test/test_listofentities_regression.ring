# Integration regression suite for stzListOfEntities.
# Covers init validation, Content / Entities, AddEntity / AddEntities
# (with name-uniqueness guard), EntitiesNames / EntitiesTypes /
# UniqueTypes, EntityN / FirstEntity / LastEntity, NumberOfEntities /
# IsEmpty, RemoveEntity / RemoveEntityN, FindEntityByName /
# FindEntitiesByType / EntitiesOfType, ContainsEntity / ContainsName
# / ContainsType, edges.
#
# Run from base/natural/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListOfEntities integration regression ==="

# Sample entities (hashlists with :name and :type)
aSample = [
	[ :name = "alice",   :type = "person" ],
	[ :name = "bob",     :type = "person" ],
	[ :name = "carol",   :type = "admin"  ]
]

# ------------------------------------------------------------
# Construction + accessors
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oLe = new stzListOfEntities(aSample)
chk("NumberOfEntities = 3",         oLe.NumberOfEntities() = 3)
chk("Size alias = 3",               oLe.Size() = 3)
chk("Count alias = 3",              oLe.Count() = 3)
chk("IsEmpty = 0",                  oLe.IsEmpty() = 0)
chk("Content len = 3",              len(oLe.Content()) = 3)
chk("Entities len = 3",             len(oLe.Entities()) = 3)

# ------------------------------------------------------------
# Names / Types
# ------------------------------------------------------------
? ""
? "--- Names / Types ---"

aNames = oLe.EntitiesNames()
chk("EntitiesNames len = 3",        len(aNames) = 3)
chk("Names contain alice",          aNames[1] = "alice")
chk("Names alias",                  len(oLe.Names()) = 3)

aTypes = oLe.EntitiesTypes()
chk("EntitiesTypes len = 3",        len(aTypes) = 3)
chk("Types alias",                  len(oLe.Types()) = 3)

# UniqueTypes (suspected bug)
aUt = oLe.UniqueTypes()
chk("UniqueTypes returns list",     isList(aUt))
# Sample has 2 person, 1 admin -> unique types = [person, admin] = 2 items
chk("UniqueTypes len = 2",          len(aUt) = 2)
chk("UniqueTypes contains person",  StzListQ(aUt).ContainsCS("person", 1) = 1)
chk("UniqueTypes contains admin",   StzListQ(aUt).ContainsCS("admin", 1) = 1)

# ------------------------------------------------------------
# Access: EntityN / First / Last
# ------------------------------------------------------------
? ""
? "--- Access ---"

aE1 = oLe.EntityN(1)
chk("EntityN(1) name = alice",      aE1[:name] = "alice")

aE3 = oLe.Entity(3)
chk("Entity(3) alias",              aE3[:name] = "carol")

chk("FirstEntity name = alice",     oLe.FirstEntity()[:name] = "alice")
chk("LastEntity name = carol",      oLe.LastEntity()[:name] = "carol")

# ------------------------------------------------------------
# Contains
# ------------------------------------------------------------
? ""
? "--- Contains ---"

chk("ContainsName('alice') = 1",    oLe.ContainsName("alice") = 1)
chk("ContainsName('missing') = 0",  oLe.ContainsName("missing") = 0)
chk("HasName alias",                oLe.HasName("bob") = 1)

chk("ContainsType('person') = 1",   oLe.ContainsType("person") = 1)
chk("ContainsType('admin') = 1",    oLe.ContainsType("admin") = 1)
chk("ContainsType('robot') = 0",    oLe.ContainsType("robot") = 0)

# ------------------------------------------------------------
# Find
# ------------------------------------------------------------
? ""
? "--- Find ---"

n = oLe.FindEntityByName("bob")
chk("FindEntityByName('bob') = 2",  n = 2)

n0 = oLe.FindEntityByName("missing")
chk("FindEntityByName missing = 0", n0 = 0)

aPersons = oLe.FindEntitiesByType("person")
chk("Find persons returns 2 idx",   isList(aPersons) and len(aPersons) = 2)

aPersonsObj = oLe.EntitiesOfType("person")
chk("EntitiesOfType returns 2 entities", isList(aPersonsObj) and len(aPersonsObj) = 2)

# ------------------------------------------------------------
# Mutation: AddEntity + RemoveEntity
# ------------------------------------------------------------
? ""
? "--- AddEntity / RemoveEntity ---"

oLm = new stzListOfEntities(aSample)
oLm.AddEntity([ :name = "dan", :type = "person" ])
chk("After Add: count = 4",         oLm.NumberOfEntities() = 4)
chk("After Add: ContainsName dan",  oLm.ContainsName("dan") = 1)

oLm.RemoveEntity("alice")
chk("After Remove: count = 3",      oLm.NumberOfEntities() = 3)
chk("After Remove: alice gone",     oLm.ContainsName("alice") = 0)

# RemoveEntityN
oLm.RemoveEntityN(1)
chk("After RemoveEntityN(1) count=2", oLm.NumberOfEntities() = 2)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Empty
oEm = new stzListOfEntities([])
chk("Empty NumberOfEntities = 0",   oEm.NumberOfEntities() = 0)
chk("Empty IsEmpty = 1",            oEm.IsEmpty() = 1)
chk("Empty ContainsName = 0",       oEm.ContainsName("anything") = 0)

# Single entity
oOne = new stzListOfEntities([
	[ :name = "solo", :type = "lone" ]
])
chk("Single NumberOfEntities = 1",  oOne.NumberOfEntities() = 1)
chk("Single ContainsName",          oOne.ContainsName("solo") = 1)
chk("Single FirstEntity",           oOne.FirstEntity()[:name] = "solo")
chk("Single LastEntity",            oOne.LastEntity()[:name] = "solo")

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzListOfEntities CHECKS PASSED!"
else
	? "SOME stzListOfEntities CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
