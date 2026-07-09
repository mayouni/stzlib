# Test stzUrl engine-backed implementation
# Must run from this directory (base/network/)

# Load stubs and DLLs via the standard infrastructure
load "../string/test/test_stubs.ring"

# Also load stz_url.dll
? "Loading stz_url.dll..."
_cUrlLib_ = _stzFindDll("stz_url.dll")
if _cUrlLib_ != ""
	pUrlHandle = LoadLib(_cUrlLib_)
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
_oUrl_ = new stzUrl("https://example.com:8080/path/to/page?key=val&a=b#section")
? "Scheme: " + _oUrl_.Scheme()
? "Host: " + _oUrl_.Host()
? "Port: " + _oUrl_.Port()
? "Path: " + _oUrl_.Path()
? "Query: " + _oUrl_.Query()
? "Fragment: " + _oUrl_.Fragment()
? "IsValid: " + _oUrl_.IsValid()

# Test 2: URL with user info
? ""
? "--- Test 2: URL with user info ---"
_oUrl2_ = new stzUrl("ftp://admin:secret@files.example.com/uploads")
? "Scheme: " + _oUrl2_.Scheme()
? "UserName: " + _oUrl2_.UserName()
? "Password: " + _oUrl2_.Password()
? "Host: " + _oUrl2_.Host()
? "Path: " + _oUrl2_.Path()

# Test 3: Simple URL
? ""
? "--- Test 3: Simple URL ---"
_oUrl3_ = new stzUrl("http://www.google.com")
? "Scheme: " + _oUrl3_.Scheme()
? "Host: " + _oUrl3_.Host()
? "IsHttp: " + _oUrl3_.IsHttp()
? "IsHttps: " + _oUrl3_.IsHttps()

# Test 4: Type checks
? ""
? "--- Test 4: Type checks ---"
_oUrl4_ = new stzUrl("file:///home/user/doc.txt")
? "IsFileScheme: " + _oUrl4_.IsFileScheme()
? "IsLocalFile: " + _oUrl4_.IsLocalFile()

# Test 5: FileName extraction
? ""
? "--- Test 5: FileName ---"
_oUrl5_ = new stzUrl("https://cdn.example.com/assets/images/logo.png")
? "FileName: " + _oUrl5_.FileName()

# Test 6: Reconstruction
? ""
? "--- Test 6: Reconstruction after SetPath ---"
_oUrl6_ = new stzUrl("https://api.example.com/v1/users")
_oUrl6_.SetPath("/v2/accounts")
? "Updated URL: " + _oUrl6_.Content()

# Test 7: Empty/invalid
? ""
? "--- Test 7: Edge cases ---"
_oUrl7_ = new stzUrl("")
? "Empty IsValid: " + _oUrl7_.IsValid()
? "Empty IsEmpty: " + _oUrl7_.IsEmpty()

? ""
? "=== All stzUrl engine tests completed ==="
