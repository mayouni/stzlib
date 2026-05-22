# Test engine-backed SQLite Unicode data store (pre-built DB)
# Run from engine/test/: D:\Ring126\bin\ring.exe test_engine_unidata.ring

# Find and load the stz_unidata DLL
cDll = _stzFindDll("stz_unidata.dll")
if cDll = ""
    ? "FAIL: stz_unidata.dll not found"
    return
ok
pHandle = LoadLib(cDll)

# Find the pre-built unicode.db
cDbPath = _stzFindDb("unicode.db")
if cDbPath = ""
    ? "FAIL: unicode.db not found"
    return
ok

? "=== Unicode Data: Open pre-built database ==="
pDb = StzEngineUnidataOpen(cDbPath)
if pDb = NULL
    ? "FAIL: could not open database at: " + cDbPath
    return
ok
? "  Opened database: OK"

? ""
? "=== Unicode Data: Count (should be 34939) ==="
nTotal = StzEngineUnidataCount(pDb)
? "  Total characters: " + nTotal

? ""
? "=== Unicode Data: Char name lookup ==="
cName = StzEngineUnidataCharName(pDb, 65)
? "  U+0041 name: " + cName

cName2 = StzEngineUnidataCharName(pDb, 97)
? "  U+0061 name: " + cName2

cName3 = StzEngineUnidataCharName(pDb, 8364)
? "  U+20AC name: " + cName3

? ""
? "=== Unicode Data: Char category lookup ==="
cCat = StzEngineUnidataCharCategory(pDb, 65)
? "  U+0041 category: " + cCat

cCat2 = StzEngineUnidataCharCategory(pDb, 48)
? "  U+0030 category: " + cCat2

? ""
? "=== Unicode Data: Search by name ==="
cResults = StzEngineUnidataFindByName(pDb, "EURO")
? "  Search 'EURO' (first 200 chars): " + left(cResults, 200)

? ""
? "=== Unicode Data: Chars in range ==="
cRange = StzEngineUnidataCharsInRange(pDb, 65, 70)
? "  Range U+0041..U+0046: " + cRange

? ""
? "=== Unicode Data: Full char info ==="
cInfo = StzEngineUnidataCharInfo(pDb, 65)
? "  U+0041 full info: " + cInfo

? ""
? "=== Unicode Data: Close ==="
StzEngineUnidataClose(pDb)
? "  Closed database: OK"

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

# ── Helper: find unicode.db ────────────────────────────────────────

func _stzFindDb(cDbName)
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
        cTry = cDir + "/data/" + cDbName
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
