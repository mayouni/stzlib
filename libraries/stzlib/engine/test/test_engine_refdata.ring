# Test engine-backed reference data (SQLite, auto-init via stz_unidata DLL)
# Run from engine/test/: D:\Ring126\bin\ring.exe test_engine_refdata.ring

cDll = _stzFindDll("stz_unidata.dll")
if cDll = ""
    ? "FAIL: stz_unidata.dll not found"
    return
ok
pHandle = LoadLib(cDll)

nPass = 0
nFail = 0

# --- Scripts ---
? "=== Scripts ==="
n = StzEngineRefScriptCount()
? "  Count: " + n
if n >= 156
    nPass++
else
    nFail++
    ? "  FAIL: expected >= 156"
ok

cName = StzEngineRefScriptName(3)
? "  Script 3: " + cName
if cName = "Latin"
    nPass++
else
    nFail++
    ? "  FAIL: expected Latin"
ok

# --- Directions ---
? ""
? "=== Directions ==="
n = StzEngineRefDirectionCount()
? "  Count: " + n
if n = 19
    nPass++
else
    nFail++
    ? "  FAIL: expected 19"
ok

# --- Categories ---
? ""
? "=== Categories ==="
n = StzEngineRefCategoryCount()
? "  Count: " + n
if n = 30
    nPass++
else
    nFail++
    ? "  FAIL: expected 30"
ok

cCat = StzEngineRefCategoryName(1)
? "  Category 1: " + cCat
if cCat = "Letter_Uppercase"
    nPass++
else
    nFail++
    ? "  FAIL: expected Letter_Uppercase"
ok

# --- Regex Patterns ---
? ""
? "=== Regex Patterns ==="
n = StzEngineRefRegexCount()
? "  Count: " + n
if n >= 300
    nPass++
else
    nFail++
    ? "  FAIL: expected >= 300"
ok

cPat = StzEngineRefRegexPattern("email")
? "  email pattern: " + cPat
if len(cPat) > 5
    nPass++
else
    nFail++
    ? "  FAIL: email pattern empty"
ok

# --- Words ---
? ""
? "=== Words ==="
n = StzEngineRefWordCount()
? "  Count: " + n
if n >= 100
    nPass++
else
    nFail++
    ? "  FAIL: expected >= 100"
ok

cWord = StzEngineRefWordAt(1, 0)
? "  Word 1 (en): " + cWord
if cWord = "apple"
    nPass++
else
    nFail++
    ? "  FAIL: expected apple"
ok

# --- Box Draw Chars ---
? ""
? "=== Box Draw Chars ==="
n = StzEngineRefBoxDrawCharCount()
? "  Count: " + n
if n >= 80
    nPass++
else
    nFail++
    ? "  FAIL: expected >= 80"
ok

# --- Invertible Chars ---
? ""
? "=== Invertible Chars ==="
n = StzEngineRefInvertibleCharCount()
? "  Count: " + n
if n >= 50
    nPass++
else
    nFail++
    ? "  FAIL: expected >= 50"
ok

# --- Latin Diacritics ---
? ""
? "=== Latin Diacritics ==="
n = StzEngineRefLatinDiacriticCount()
? "  Count: " + n
if n >= 190
    nPass++
else
    nFail++
    ? "  FAIL: expected >= 190"
ok

# --- System Commands ---
? ""
? "=== System Commands ==="
n = StzEngineRefResCmdCount()
? "  Count: " + n
if n >= 10
    nPass++
else
    nFail++
    ? "  FAIL: expected >= 10"
ok

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
