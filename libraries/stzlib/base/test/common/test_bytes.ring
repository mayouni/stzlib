
#ERR Error (E9) : Can't open file test_stubs.ring

load "test_stubs.ring"

# Load stz_bytes.dll
? "Loading stz_bytes.dll..."
cBytesLib = _stzFindDll("stz_bytes.dll")
if cBytesLib != ""
	pBytesHandle = LoadLib(cBytesLib)
	? "  stz_bytes.dll: loaded"
else
	? "ERROR: stz_bytes.dll not found!"
	return
ok

load "../stzBytes.ring"

pr()

? ""
? "=== stzBytes Engine-Backed Tests ==="

# Test 1: Create from string
? ""
? "--- Test 1: Create and access ---"
oB = new stzBytes("Hello")
? "Content: " + oB.Content()
? "Size: " + oB.Size()
? "IsEmpty: " + oB.IsEmpty()
? "ByteAt(1): " + oB.ByteAt(0)
#--> 72 (H)

# Test 2: Empty buffer
? ""
? "--- Test 2: Empty buffer ---"
oEmpty = new stzBytes("")
? "Empty Size: " + oEmpty.Size()
? "Empty IsEmpty: " + oEmpty.IsEmpty()

# Test 3: Append
? ""
? "--- Test 3: Append ---"
oB2 = new stzBytes("Hi")
oB2.Append(" World")
? "After append: " + oB2.Content()
? "Size: " + oB2.Size()

# Test 4: Left/Right/Mid
? ""
? "--- Test 4: Slicing ---"
oB3 = new stzBytes("Hello World")
? "Left(5): " + oB3.Left(5)
? "Right(5): " + oB3.Right(5)
? "Mid(6,5): " + oB3.Mid(6, 5)

# Test 5: Base64 encoding
? ""
? "--- Test 5: Base64 ---"
oB4 = new stzBytes("Hello")
cB64 = oB4.ToBase64()
? "Base64: " + cB64

# Test 6: Hex encoding
? ""
? "--- Test 6: Hex ---"
oB5 = new stzBytes("AB")
? "Hex: " + oB5.ToHex()

# Test 7: Case conversion
? ""
? "--- Test 7: Case ---"
oB6 = new stzBytes("Hello")
? "ToLower: " + oB6.ToLower()
? "ToUpper: " + oB6.ToUpper()

# Test 8: Percent encoding
? ""
? "--- Test 8: Percent encoding ---"
oB7 = new stzBytes("hello world")
? "Percent: " + oB7.ToPercent()

? ""
? "=== All stzBytes tests completed ==="

pf()
