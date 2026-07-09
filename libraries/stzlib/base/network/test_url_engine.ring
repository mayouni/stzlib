# Test stzUrl engine-backed implementation
# Must run from this directory (base/network/)

# Load stubs and DLLs via the standard infrastructure
load "../string/test/test_stubs.ring"

# Also load stz_url.dll
? "Loading stz_url.dll..."
cUrlLib = _stzFindDll("stz_url.dll")
if cUrlLib != ""
	pUrlHandle = LoadLib(cUrlLib)
	? "  stz_url.dll: loaded"
else
	? "ERROR: stz_url.dll not found!"
	return
ok

# Load string dependencies
load "../string/stzString.ring"
load "../string/stzStringFinder.ring"
load "../string/stzStringReplacer.ring"

# Load stzUrl
load "stzUrl.ring"

? ""
? "=== stzUrl Engine-Backed Tests ==="

# Test 1: Basic URL parsing
? ""
? "--- Test 1: Basic URL parsing ---"
oUrl = new stzUrl("https://example.com:8080/path/to/page?key=val&a=b#section")
? "Scheme: " + oUrl.Scheme()
? "Host: " + oUrl.Host()
? "Port: " + oUrl.Port()
? "Path: " + oUrl.Path()
? "Query: " + oUrl.Query()
? "Fragment: " + oUrl.Fragment()
? "IsValid: " + oUrl.IsValid()

# Test 2: URL with user info
? ""
? "--- Test 2: URL with user info ---"
oUrl2 = new stzUrl("ftp://admin:secret@files.example.com/uploads")
? "Scheme: " + oUrl2.Scheme()
? "UserName: " + oUrl2.UserName()
? "Password: " + oUrl2.Password()
? "Host: " + oUrl2.Host()
? "Path: " + oUrl2.Path()

# Test 3: Simple URL
? ""
? "--- Test 3: Simple URL ---"
oUrl3 = new stzUrl("http://www.google.com")
? "Scheme: " + oUrl3.Scheme()
? "Host: " + oUrl3.Host()
? "IsHttp: " + oUrl3.IsHttp()
? "IsHttps: " + oUrl3.IsHttps()

# Test 4: Type checks
? ""
? "--- Test 4: Type checks ---"
oUrl4 = new stzUrl("file:///home/user/doc.txt")
? "IsFileScheme: " + oUrl4.IsFileScheme()
? "IsLocalFile: " + oUrl4.IsLocalFile()

# Test 5: FileName extraction
? ""
? "--- Test 5: FileName ---"
oUrl5 = new stzUrl("https://cdn.example.com/assets/images/logo.png")
? "FileName: " + oUrl5.FileName()

# Test 6: Reconstruction
? ""
? "--- Test 6: Reconstruction after SetPath ---"
oUrl6 = new stzUrl("https://api.example.com/v1/users")
oUrl6.SetPath("/v2/accounts")
? "Updated URL: " + oUrl6.Content()

# Test 7: Empty/invalid
? ""
? "--- Test 7: Edge cases ---"
oUrl7 = new stzUrl("")
? "Empty IsValid: " + oUrl7.IsValid()
? "Empty IsEmpty: " + oUrl7.IsEmpty()

? ""
? "=== All stzUrl engine tests completed ==="
