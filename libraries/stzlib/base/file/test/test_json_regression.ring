# Integration regression suite for stzJson.
# No domain-local test/ existed before. Covers the most-used surface:
# construction (string + list), object ops (HasKey/Keys/Value/SetValue/
# RemoveKey), array ops (At/First/Last/Add/Insert/RemoveAt), validation
# (IsValid/HasError/LastError), ToString round-trip, edges (empty
# object/array, nested).
#
# Run from base/file/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzJson integration regression ==="

# ------------------------------------------------------------
# Construction from JSON string
# ------------------------------------------------------------
? ""
? "--- Construction (string) ---"

oJobj = new stzJson('{"name":"Ali","age":35}')
chk("Object: IsArray = 0",          oJobj.IsArray() = 0)
chk("Object: not empty",            oJobj.IsEmpty() = 0)
chk("Object: HasKey('name')",       oJobj.HasKey("name") = 1)
chk("Object: HasKey('missing')",    oJobj.HasKey("missing") = 0)
chk("Object: Value('name')",        oJobj.Value("name") = "Ali")
chk("Object: Value('age')",         oJobj.Value("age") = 35)
chk("Object: Size = 2",             oJobj.Size() = 2)
chk("Object: IsValid",              oJobj.IsValid() = 1)

aKeys = oJobj.Keys()
chk("Keys() returns 2 keys",        isList(aKeys) and len(aKeys) = 2)

oJarr = new stzJson('[10, 20, 30, 40]')
chk("Array: IsArray = 1",           oJarr.IsArray() = 1)
chk("Array: Size = 4",              oJarr.Size() = 4)
chk("Array: At(1) = 10",            oJarr.At(1) = 10)
chk("Array: At(4) = 40",            oJarr.At(4) = 40)
chk("Array: First() = 10",          oJarr.First() = 10)
chk("Array: Last() = 40",           oJarr.Last() = 40)

# ------------------------------------------------------------
# Object mutations
# ------------------------------------------------------------
? ""
? "--- Object mutation ---"

oJm = new stzJson('{"a":1,"b":2}')
oJm.SetValue("c", 3)
chk("SetValue adds new key",        oJm.HasKey("c") = 1 and oJm.Value("c") = 3)
chk("SetValue: Size grew to 3",     oJm.Size() = 3)

oJm.SetValue("a", 99)
chk("SetValue overwrites existing", oJm.Value("a") = 99)
chk("SetValue: Size still 3",       oJm.Size() = 3)

oJm.RemoveKey("b")
chk("RemoveKey drops the key",      oJm.HasKey("b") = 0)
chk("RemoveKey: Size = 2",          oJm.Size() = 2)

# ------------------------------------------------------------
# Array mutations
# ------------------------------------------------------------
? ""
? "--- Array mutation ---"

oJa = new stzJson('[1, 2, 3]')
oJa.Add(4)
chk("Add appends to end",           oJa.At(4) = 4)
chk("Add: Size = 4",                oJa.Size() = 4)

oJa.Prepend(0)
chk("Prepend pushes to front",      oJa.At(1) = 0)
chk("Prepend: Size = 5",            oJa.Size() = 5)

oJa.Insert(3, 99)
chk("Insert at position 3",         oJa.At(3) = 99)

oJa.RemoveAt(1)
chk("RemoveAt(1) drops front",      oJa.At(1) != 0)

# Trace: [1,2,3] +Add(4)=[1,2,3,4] +Prepend(0)=[0,1,2,3,4]
# +Insert(3,99)=[0,1,99,2,3,4] +RemoveAt(1)=[1,99,2,3,4]
# +RemoveLast=[1,99,2,3] -> size 4.
oJa.RemoveLast()
chk("RemoveLast drops tail",        oJa.Size() = 4)

# ------------------------------------------------------------
# Validation / error path
# ------------------------------------------------------------
? ""
? "--- Validation ---"

# Use an unbalanced bracket -- stzJson's structural validator only
# catches gross structural errors (bracket balance). Subtle malformations
# like '{"key":}' or '[1,2,]' currently slip through; tightening the
# validator is a separate slice.
oJbad = new stzJson('{"k":1')
chk("Bad JSON: HasError = 1",       oJbad.HasError() = 1)
chk("Bad JSON: LastError non-empty", isString(oJbad.LastError()) and len(oJbad.LastError()) > 0)

oJgood = new stzJson('{"x":1}')
chk("Good JSON: HasError = 0",      oJgood.HasError() = 0)

oJbad.ClearError()
chk("ClearError empties error",     oJbad.LastError() = "")

# ------------------------------------------------------------
# Round-trip ToString
# ------------------------------------------------------------
? ""
? "--- ToString round-trip ---"

oJr = new stzJson('{"k":"v"}')
cStr = oJr.ToString()
chk("ToString returns string",      isString(cStr))
chk("ToString preserves key",       substr(cStr, "k") > 0)
chk("ToString preserves value",     substr(cStr, "v") > 0)

# Round-trip the string back into a new object
oJr2 = new stzJson(cStr)
chk("Round-trip preserves Value",   oJr2.Value("k") = "v")

# ------------------------------------------------------------
# Edges: empty object, empty array, nested
# ------------------------------------------------------------
? ""
? "--- Edges ---"

oJeo = new stzJson('{}')
chk("Empty object IsEmpty = 1",     oJeo.IsEmpty() = 1)
chk("Empty object Size = 0",        oJeo.Size() = 0)

oJea = new stzJson('[]')
chk("Empty array IsArray = 1",      oJea.IsArray() = 1)
chk("Empty array Size = 0",         oJea.Size() = 0)

oJnest = new stzJson('{"items":[1,2,3],"name":"foo"}')
chk("Nested: HasKey items",         oJnest.HasKey("items") = 1)
chk("Nested: items value is list",  isList(oJnest.Value("items")))
chk("Nested: items[2] = 2",         oJnest.Value("items")[2] = 2)

# ------------------------------------------------------------
# Construction from Ring list
# ------------------------------------------------------------
? ""
? "--- From Ring list ---"

aRaw = [10, 20, 30]
oJfl = new stzJson(aRaw)
chk("List ctor IsArray = 1",        oJfl.IsArray() = 1)
chk("List ctor Size = 3",           oJfl.Size() = 3)
chk("List ctor At(2) = 20",         oJfl.At(2) = 20)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzJson CHECKS PASSED!"
else
	? "SOME stzJson CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
