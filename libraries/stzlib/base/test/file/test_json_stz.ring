
#ERR Error (E9) : Can't open file ../../string/test/test_stubs.ring

load "../../string/test/test_stubs.ring"

# Load stz_json.dll
cJsonLib = _stzFindDll("stz_json.dll")
if cJsonLib != ""
	pJsonHandle = LoadLib(cJsonLib)
else
	? "ERROR: stz_json.dll not found!"
	return
ok

load "../stzJson.ring"

pr()

? "=== StzJson Wrapper Function Tests ==="

# Test 1: StzJsonIsValid
? ""
? "--- Test 1: StzJsonIsValid ---"
? "  Valid: " + StzJsonIsValid('{"name":"Zin","version":1}')
? "  Invalid: " + StzJsonIsValid('{invalid}')
? "  Array: " + StzJsonIsValid('[1,2,3]')

# Test 2: StzJsonPretty / StzJsonCompact
? ""
? "--- Test 2: Pretty/Compact ---"
cJson = '{"name":"Mansour","age":45,"active":true}'
? "  Pretty:"
? StzJsonPretty(cJson)
? "  Compact: " + StzJsonCompact(cJson)

# Test 3: StzJsonGet / StzJsonGetInt
? ""
? "--- Test 3: Get values ---"
? "  Get('name'): " + StzJsonGet(cJson, "name")
? "  GetInt('age'): " + StzJsonGetInt(cJson, "age")

# Test 4: StzJsonHasKey
? ""
? "--- Test 4: HasKey ---"
? "  HasKey('name'): " + StzJsonHasKey(cJson, "name")
? "  HasKey('missing'): " + StzJsonHasKey(cJson, "missing")

# Test 5: StzJsonKeys
? ""
? "--- Test 5: Keys ---"
aKeys = StzJsonKeys(cJson)
? "  Keys count: " + len(aKeys)
for k in aKeys
	? "    - " + k
next

# Test 6: StzJsonSize / StzJsonIsArray
? ""
? "--- Test 6: Size/IsArray ---"
? "  Object size: " + StzJsonSize(cJson)
? "  Object isArray: " + StzJsonIsArray(cJson)
? "  Array size: " + StzJsonSize('[10,20,30]')
? "  Array isArray: " + StzJsonIsArray('[10,20,30]')

# Test 7: StzJsonQ (class constructor)
? ""
? "--- Test 7: StzJsonQ ---"
oJson = StzJsonQ('{"x":1,"y":2}')
? "  Size: " + oJson.Size()
? "  HasKey('x'): " + oJson.HasKey("x")

? ""
? "=== All StzJson wrapper tests completed ==="

pf()
