# Test engine-backed SQLite Unicode data store (pre-built DB, auto-init)
# Run from engine/test/: D:\Ring126\bin\ring.exe test_engine_unidata.ring
#
# The DLL auto-opens unicode.db on load. Ring never sees handles or paths.
# Functions take only the query parameters (codepoint, pattern, etc).

# Find and load the stz_unidata DLL
cDll = _stzFindDll("stz_unidata.dll")
if cDll = ""
    ? "FAIL: stz_unidata.dll not found"
    return
ok
pHandle = LoadLib(cDll)

? "=== Unicode Data: Count (should be 34939) ==="
nTotal = StzEngineUnidataCount()
? "  Total characters: " + nTotal

? ""
? "=== Unicode Data: Char name lookup ==="
cName = StzEngineUnidataCharName(65)
? "  U+0041 name: " + cName

cName2 = StzEngineUnidataCharName(97)
? "  U+0061 name: " + cName2

cName3 = StzEngineUnidataCharName(8364)
? "  U+20AC name: " + cName3

? ""
? "=== Unicode Data: Char category lookup ==="
cCat = StzEngineUnidataCharCategory(65)
? "  U+0041 category: " + cCat

cCat2 = StzEngineUnidataCharCategory(48)
? "  U+0030 category: " + cCat2

? ""
? "=== Unicode Data: Search by name ==="
cResults = StzEngineUnidataFindByName("EURO")
? "  Search 'EURO' (first 200 chars): " + left(cResults, 200)

? ""
? "=== Unicode Data: Chars in range ==="
cRange = StzEngineUnidataCharsInRange(65, 70)
? "  Range U+0041..U+0046: " + cRange

? ""
? "=== Unicode Data: Full char info ==="
cInfo = StzEngineUnidataCharInfo(65)
? "  U+0041 full info: " + cInfo

? ""
? "All unicode data engine tests completed."

# ── Helper: find DLL ────────────────────────────────────────────────

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
