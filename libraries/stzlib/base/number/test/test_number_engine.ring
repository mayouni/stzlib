# Test engine-backed number operations
# Run from base/number/test/: D:\Ring126\bin\ring.exe test_number_engine.ring

cDll = _stzFindDll("stz_number.dll")

if cDll = ""
    ? "FAIL: stz_number.dll not found"
    return
ok
pHandle = LoadLib(cDll)

nPass = 0
nFail = 0

# --- IsPrime ---
? "=== IsPrime ==="

n = StzEngineNumberIsPrime(7)
? "  IsPrime(7): " + n
if n = 1
    nPass++
else
    nFail++
    ? "  FAIL: expected 1"
ok

n = StzEngineNumberIsPrime(10)
? "  IsPrime(10): " + n
if n = 0
    nPass++
else
    nFail++
    ? "  FAIL: expected 0"
ok

n = StzEngineNumberIsPrime(97)
? "  IsPrime(97): " + n
if n = 1
    nPass++
else
    nFail++
    ? "  FAIL: expected 1"
ok

# --- GCD ---
? ""
? "=== GCD ==="

n = StzEngineNumberGcd(12, 8)
? "  GCD(12,8): " + n
if n = 4
    nPass++
else
    nFail++
    ? "  FAIL: expected 4"
ok

n = StzEngineNumberGcd(100, 75)
? "  GCD(100,75): " + n
if n = 25
    nPass++
else
    nFail++
    ? "  FAIL: expected 25"
ok

# --- LCM ---
? ""
? "=== LCM ==="

n = StzEngineNumberLcm(4, 6)
? "  LCM(4,6): " + n
if n = 12
    nPass++
else
    nFail++
    ? "  FAIL: expected 12"
ok

n = StzEngineNumberLcm(3, 7)
? "  LCM(3,7): " + n
if n = 21
    nPass++
else
    nFail++
    ? "  FAIL: expected 21"
ok

# --- Factorial ---
? ""
? "=== Factorial ==="

pBigInt = StzEngineNumberFactorial(5)
cResult = StzEngineBigIntToString(pBigInt)
StzEngineBigIntFree(pBigInt)
? "  5! = " + cResult
if cResult = "120"
    nPass++
else
    nFail++
    ? "  FAIL: expected 120"
ok

pBigInt = StzEngineNumberFactorial(10)
cResult = StzEngineBigIntToString(pBigInt)
StzEngineBigIntFree(pBigInt)
? "  10! = " + cResult
if cResult = "3628800"
    nPass++
else
    nFail++
    ? "  FAIL: expected 3628800"
ok

# --- Fibonacci ---
? ""
? "=== Fibonacci ==="

pBigInt = StzEngineNumberFibonacci(10)
cResult = StzEngineBigIntToString(pBigInt)
StzEngineBigIntFree(pBigInt)
? "  Fib(10) = " + cResult
if cResult = "55"
    nPass++
else
    nFail++
    ? "  FAIL: expected 55"
ok

pBigInt = StzEngineNumberFibonacci(20)
cResult = StzEngineBigIntToString(pBigInt)
StzEngineBigIntFree(pBigInt)
? "  Fib(20) = " + cResult
if cResult = "6765"
    nPass++
else
    nFail++
    ? "  FAIL: expected 6765"
ok

# --- IsPerfect ---
? ""
? "=== IsPerfect ==="

n = StzEngineNumberIsPerfect(6)
? "  IsPerfect(6): " + n
if n = 1
    nPass++
else
    nFail++
    ? "  FAIL: expected 1"
ok

n = StzEngineNumberIsPerfect(28)
? "  IsPerfect(28): " + n
if n = 1
    nPass++
else
    nFail++
    ? "  FAIL: expected 1"
ok

n = StzEngineNumberIsPerfect(12)
? "  IsPerfect(12): " + n
if n = 0
    nPass++
else
    nFail++
    ? "  FAIL: expected 0"
ok

# --- DigitCount ---
? ""
? "=== DigitCount ==="

n = StzEngineNumberDigitCount(12345)
? "  DigitCount(12345): " + n
if n = 5
    nPass++
else
    nFail++
    ? "  FAIL: expected 5"
ok

n = StzEngineNumberDigitCount(0)
? "  DigitCount(0): " + n
if n = 1
    nPass++
else
    nFail++
    ? "  FAIL: expected 1"
ok

# --- DigitSum ---
? ""
? "=== DigitSum ==="

n = StzEngineNumberDigitSum(12345)
? "  DigitSum(12345): " + n
if n = 15
    nPass++
else
    nFail++
    ? "  FAIL: expected 15"
ok

n = StzEngineNumberDigitSum(999)
? "  DigitSum(999): " + n
if n = 27
    nPass++
else
    nFail++
    ? "  FAIL: expected 27"
ok

# --- ReverseDigits ---
? ""
? "=== ReverseDigits ==="

n = StzEngineNumberReverseDigits(12345)
? "  ReverseDigits(12345): " + n
if n = 54321
    nPass++
else
    nFail++
    ? "  FAIL: expected 54321"
ok

# --- IsPalindrome ---
? ""
? "=== IsPalindrome ==="

n = StzEngineNumberIsPalindrome(12321)
? "  IsPalindrome(12321): " + n
if n = 1
    nPass++
else
    nFail++
    ? "  FAIL: expected 1"
ok

n = StzEngineNumberIsPalindrome(12345)
? "  IsPalindrome(12345): " + n
if n = 0
    nPass++
else
    nFail++
    ? "  FAIL: expected 0"
ok

# --- BigInt Arithmetic ---
? ""
? "=== BigInt ==="

pA = StzEngineBigIntFromInt(100)
pB = StzEngineBigIntFromInt(200)
pC = StzEngineBigIntAdd(pA, pB)
cResult = StzEngineBigIntToString(pC)
? "  100 + 200 = " + cResult
if cResult = "300"
    nPass++
else
    nFail++
    ? "  FAIL: expected 300"
ok

pD = StzEngineBigIntMul(pA, pB)
cResult = StzEngineBigIntToString(pD)
? "  100 * 200 = " + cResult
if cResult = "20000"
    nPass++
else
    nFail++
    ? "  FAIL: expected 20000"
ok

StzEngineBigIntFree(pA)
StzEngineBigIntFree(pB)
StzEngineBigIntFree(pC)
StzEngineBigIntFree(pD)

# --- BigInt from String ---
pBig = StzEngineBigIntFromString("999999999999999999")
cResult = StzEngineBigIntToString(pBig)
? "  BigInt('999999999999999999') = " + cResult
if cResult = "999999999999999999"
    nPass++
else
    nFail++
    ? "  FAIL: expected 999999999999999999"
ok
StzEngineBigIntFree(pBig)

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="

# ---- Helper ----

func _stzFindDll(cDllName)

	cDir = currentdir()
	nLen = len(cDir)
	cNorm = ""

	for i = 1 to nLen
		if cDir[i] = "\"
			cNorm += "/"
		else
			cNorm += cDir[i]
		ok
	next

	cDir = cNorm

	for depth = 1 to 10

		cTry = cDir + "/zig-out/bin/" + cDllName
		if fexists(cTry)
			return cTry
		ok

		cTry = cDir + "/engine/zig-out/bin/" + cDllName
		if fexists(cTry)
			return cTry
		ok

		nLast = 0
		for j = len(cDir) to 1 step -1
			if cDir[j] = "/"
				nLast = j
				exit
			ok
		next

		if nLast < 2
			exit
		ok

		cDir = left(cDir, nLast - 1)
	next

	return ""
