

load "../string/test_stubs.ring"
# Load stz_url.dll
? "Loading stz_url.dll..."
cUrlLib = _stzFindDll("stz_url.dll")
if cUrlLib != ""
	pUrlHandle = LoadLib(cUrlLib)
	? "  stz_url.dll: loaded"
else
	? "ERROR: stz_url.dll not found!"
	return
ok

? ""
? "=== stz_url Engine Tests ==="

# Test 1: Parse a full URL
? ""
? "--- Test 1: Full URL ---"
cUrl = "https://user:pass@example.com:8080/path/to/page?q=zin&lang=en#section"
pH = StzEngineUrlParse(cUrl)
if pH != NULL
	? "  IsValid: " + StzEngineUrlIsValid(pH)
	? "  Scheme: " + StzEngineUrlScheme(pH)
	? "  Host: " + StzEngineUrlHost(pH)
	? "  Port: " + StzEngineUrlPort(pH)
	? "  Path: " + StzEngineUrlPath(pH)
	? "  Query: " + StzEngineUrlQuery(pH)
	? "  Fragment: " + StzEngineUrlFragment(pH)
	? "  User: " + StzEngineUrlUser(pH)
	? "  Password: " + StzEngineUrlPassword(pH)
	StzEngineUrlFree(pH)
else
	? "  ERROR: parse returned NULL"
ok

# Test 2: Simple URL
? ""
? "--- Test 2: Simple URL ---"
pH2 = StzEngineUrlParse("http://zin.dev/docs")
if pH2 != NULL
	? "  Scheme: " + StzEngineUrlScheme(pH2)
	? "  Host: " + StzEngineUrlHost(pH2)
	? "  Path: " + StzEngineUrlPath(pH2)
	? "  Port: " + StzEngineUrlPort(pH2)
	? "  Reconstruct: " + StzEngineUrlReconstruct(pH2)
	StzEngineUrlFree(pH2)
else
	? "  ERROR: parse returned NULL"
ok

# Test 3: URL with query only
? ""
? "--- Test 3: Query URL ---"
pH3 = StzEngineUrlParse("https://api.example.com/search?term=softanza&limit=10")
if pH3 != NULL
	? "  Host: " + StzEngineUrlHost(pH3)
	? "  Path: " + StzEngineUrlPath(pH3)
	? "  Query: " + StzEngineUrlQuery(pH3)
	? "  Fragment: " + StzEngineUrlFragment(pH3)
	StzEngineUrlFree(pH3)
else
	? "  ERROR: parse returned NULL"
ok

# Test 4: File URL
? ""
? "--- Test 4: File URL ---"
pH4 = StzEngineUrlParse("file:///home/user/document.txt")
if pH4 != NULL
	? "  Scheme: " + StzEngineUrlScheme(pH4)
	? "  Path: " + StzEngineUrlPath(pH4)
	StzEngineUrlFree(pH4)
else
	? "  ERROR: parse returned NULL"
ok

? ""
? "=== All stz_url engine tests completed ==="
