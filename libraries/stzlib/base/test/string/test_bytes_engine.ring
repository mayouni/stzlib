
#ERR Error (R3) : Calling Function without definition: pr

load "test_stubs.ring"

pr()

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

? ""
? "=== stz_bytes Engine Tests ==="

# Test 1: Create and basic ops
? ""
? "--- Test 1: Create empty ---"
pH = StzEngineBytesNew()
if pH != NULL
	? "  IsEmpty: " + StzEngineBytesIsEmpty(pH)
	? "  Size: " + StzEngineBytesSize(pH)

	# Append data
	StzEngineBytesAppend(pH, "Hello")
	? "  After append 'Hello': Size=" + StzEngineBytesSize(pH)
	? "  Data: " + StzEngineBytesData(pH)

	StzEngineBytesAppend(pH, " World")
	? "  After append ' World': Size=" + StzEngineBytesSize(pH)
	? "  Data: " + StzEngineBytesData(pH)

	StzEngineBytesFree(pH)
else
	? "  ERROR: new returned NULL"
ok

# Test 2: From string
? ""
? "--- Test 2: From string ---"
pH2 = StzEngineBytesFrom("Softanza")
if pH2 != NULL
	? "  Size: " + StzEngineBytesSize(pH2)
	? "  Data: " + StzEngineBytesData(pH2)
	? "  At(0): " + StzEngineBytesAt(pH2, 0)
	? "  At(1): " + StzEngineBytesAt(pH2, 1)
	? "  Left(4): " + StzEngineBytesLeft(pH2, 4)
	? "  Right(4): " + StzEngineBytesRight(pH2, 4)
	? "  Mid(4,3): " + StzEngineBytesMid(pH2, 4, 3)
	StzEngineBytesFree(pH2)
ok

# Test 3: Case conversion
? ""
? "--- Test 3: Case conversion ---"
pH3 = StzEngineBytesFrom("Hello World")
if pH3 != NULL
	? "  ToLower: " + StzEngineBytesToLower(pH3)
	? "  ToUpper: " + StzEngineBytesToUpper(pH3)
	StzEngineBytesFree(pH3)
ok

# Test 4: Base64 encode/decode
? ""
? "--- Test 4: Base64 ---"
pH4 = StzEngineBytesFrom("Hello Zin!")
if pH4 != NULL
	cBase64 = StzEngineBytesToBase64(pH4)
	? "  Base64 of 'Hello Zin!': " + cBase64

	# Decode back
	pH5 = StzEngineBytesNew()
	StzEngineBytesFromBase64(pH5, cBase64)
	? "  Decoded back: " + StzEngineBytesData(pH5)
	? "  Size: " + StzEngineBytesSize(pH5)
	StzEngineBytesFree(pH5)

	StzEngineBytesFree(pH4)
ok

# Test 5: Hex encode/decode
? ""
? "--- Test 5: Hex ---"
pH6 = StzEngineBytesFrom("ABC")
if pH6 != NULL
	cHex = StzEngineBytesToHex(pH6)
	? "  Hex of 'ABC': " + cHex

	pH7 = StzEngineBytesNew()
	StzEngineBytesFromHex(pH7, cHex)
	? "  Decoded back: " + StzEngineBytesData(pH7)
	StzEngineBytesFree(pH7)

	StzEngineBytesFree(pH6)
ok

# Test 6: Percent encode/decode
? ""
? "--- Test 6: Percent encoding ---"
pH8 = StzEngineBytesFrom("Hello World!")
if pH8 != NULL
	cPct = StzEngineBytesToPercent(pH8)
	? "  Percent of 'Hello World!': " + cPct

	pH9 = StzEngineBytesNew()
	StzEngineBytesFromPercent(pH9, cPct)
	? "  Decoded back: " + StzEngineBytesData(pH9)
	StzEngineBytesFree(pH9)

	StzEngineBytesFree(pH8)
ok

# Test 7: Clear and resize
? ""
? "--- Test 7: Clear/Resize ---"
pH10 = StzEngineBytesFrom("test data")
if pH10 != NULL
	? "  Before clear: Size=" + StzEngineBytesSize(pH10) + " IsEmpty=" + StzEngineBytesIsEmpty(pH10)
	StzEngineBytesClear(pH10)
	? "  After clear: Size=" + StzEngineBytesSize(pH10) + " IsEmpty=" + StzEngineBytesIsEmpty(pH10)
	StzEngineBytesFree(pH10)
ok

? ""
? "=== All stz_bytes engine tests completed ==="

pf()
