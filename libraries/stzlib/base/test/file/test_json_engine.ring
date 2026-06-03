load "../../string/test/test_stubs.ring"

pr()

# Load stz_json.dll
? "Loading stz_json.dll..."
cJsonLib = _stzFindDll("stz_json.dll")
if cJsonLib != ""
	pJsonHandle = LoadLib(cJsonLib)
	? "  stz_json.dll: loaded"
else
	? "ERROR: stz_json.dll not found!"
	return
ok

? ""
? "=== stz_json Engine Tests ==="

# Test 1: Parse a JSON object
? ""
? "--- Test 1: Parse JSON object ---"
cJson = '{"name":"Mansour","age":45,"active":true}'
pH = StzEngineJsonParse(cJson)
if pH != NULL
	? "  Parsed OK"
	? "  IsValid: " + StzEngineJsonIsValid(pH)
	? "  IsArray: " + StzEngineJsonIsArray(pH)
	? "  Size: " + StzEngineJsonSize(pH)
else
	? "  ERROR: parse returned NULL"
ok

# Test 2: HasKey
? ""
? "--- Test 2: HasKey ---"
? "  HasKey('name'): " + StzEngineJsonHasKey(pH, "name")
? "  HasKey('age'): " + StzEngineJsonHasKey(pH, "age")
? "  HasKey('missing'): " + StzEngineJsonHasKey(pH, "missing")

# Test 3: GetString, GetInt, GetBool
? ""
? "--- Test 3: Get values ---"
? "  GetString('name'): " + StzEngineJsonGetString(pH, "name")
? "  GetInt('age'): " + StzEngineJsonGetInt(pH, "age")
? "  GetBool('active'): " + StzEngineJsonGetBool(pH, "active")

# Test 4: Keys
? ""
? "--- Test 4: Keys ---"
? "  Keys: " + StzEngineJsonKeys(pH)

# Test 5: ToString / ToStringPretty
? ""
? "--- Test 5: Serialization ---"
cCompact = StzEngineJsonToString(pH)
? "  Compact: " + cCompact
cPretty = StzEngineJsonToStringPretty(pH)
? "  Pretty:"
? cPretty

StzEngineJsonFree(pH)

# Test 6: Parse a JSON array
? ""
? "--- Test 6: Parse JSON array ---"
cArr = '[10, 20, 30, 40]'
pH2 = StzEngineJsonParse(cArr)
if pH2 != NULL
	? "  Parsed OK"
	? "  IsArray: " + StzEngineJsonIsArray(pH2)
	? "  Size: " + StzEngineJsonSize(pH2)
	? "  ArrayAt(0): " + StzEngineJsonArrayAtInt(pH2, 0)
	? "  ArrayAt(1): " + StzEngineJsonArrayAtInt(pH2, 1)
	? "  ArrayAt(3): " + StzEngineJsonArrayAtInt(pH2, 3)
	StzEngineJsonFree(pH2)
else
	? "  ERROR: parse returned NULL"
ok

# Test 7: Parse string array
? ""
? "--- Test 7: String array ---"
cStrArr = '["hello", "world", "zin"]'
pH3 = StzEngineJsonParse(cStrArr)
if pH3 != NULL
	? "  Size: " + StzEngineJsonSize(pH3)
	? "  ArrayAt(0): " + StzEngineJsonArrayAtString(pH3, 0)
	? "  ArrayAt(1): " + StzEngineJsonArrayAtString(pH3, 1)
	? "  ArrayAt(2): " + StzEngineJsonArrayAtString(pH3, 2)
	StzEngineJsonFree(pH3)
else
	? "  ERROR: parse returned NULL"
ok

# Test 8: Invalid JSON
? ""
? "--- Test 8: Invalid JSON ---"
cBad = '{invalid json}'
pH4 = StzEngineJsonParse(cBad)
if pH4 != NULL
	? "  IsValid: " + StzEngineJsonIsValid(pH4)
	? "  Error: " + StzEngineJsonError(pH4)
	StzEngineJsonFree(pH4)
else
	? "  Parse returned NULL (expected for invalid JSON)"
ok

# Test 9: Nested object
? ""
? "--- Test 9: Nested JSON ---"
cNested = '{"user":{"name":"Zin","level":5},"tags":["zig","ring"]}'
pH5 = StzEngineJsonParse(cNested)
if pH5 != NULL
	? "  Parsed OK, Size: " + StzEngineJsonSize(pH5)
	? "  HasKey('user'): " + StzEngineJsonHasKey(pH5, "user")
	? "  HasKey('tags'): " + StzEngineJsonHasKey(pH5, "tags")
	cStr = StzEngineJsonToStringPretty(pH5)
	? "  Pretty:"
	? cStr
	StzEngineJsonFree(pH5)
else
	? "  ERROR: parse returned NULL"
ok

? ""
? "=== All stz_json engine tests completed ==="

pf()
