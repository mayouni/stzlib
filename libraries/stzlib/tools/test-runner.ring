# Softanza Test Runner
# Discovers and runs all test files, reports results
#
# Usage: ring test-runner.ring [options]
#   --layer core|base|max|all    Run tests for a specific layer (default: all)
#   --file <pattern>             Run only tests matching pattern
#   --report                     Generate coverage report
#   --list                       List all test files without running
#   --verbose                    Show detailed output

load "stdlibcore.ring"

# Configuration
cBaseDir = currentdir() + "/../"
aLayers = [
    [:name = "core",  :path = cBaseDir + "core/test/",  :loader = "../core/stzCore.ring"],
    [:name = "base",  :path = cBaseDir + "base/test/",  :loader = "../base/stzBase.ring"],
    [:name = "max",   :path = cBaseDir + "max/test/",   :loader = "../max/stzMax.ring"]
]

# Parse command line
cLayer = "all"
cFilePattern = ""
bReport = false
bListOnly = false
bVerbose = false

for i = 1 to len(sysargv)
    if sysargv[i] = "--layer" and i < len(sysargv)
        cLayer = sysargv[i + 1]
    ok
    if sysargv[i] = "--file" and i < len(sysargv)
        cFilePattern = sysargv[i + 1]
    ok
    if sysargv[i] = "--report"
        bReport = true
    ok
    if sysargv[i] = "--list"
        bListOnly = true
    ok
    if sysargv[i] = "--verbose"
        bVerbose = true
    ok
next

# Discover test files
aTestFiles = []
nTotalTests = 0
nPassed = 0
nFailed = 0
nSkipped = 0

? "============================================"
? "  SOFTANZA TEST RUNNER"
? "============================================"
? ""

for aLayer in aLayers
    if cLayer != "all" and aLayer[:name] != cLayer
        loop
    ok

    cTestDir = aLayer[:path]

    if not fexists(cTestDir)
        ? "  [SKIP] " + aLayer[:name] + " layer: test directory not found"
        loop
    ok

    aFiles = dir(cTestDir)
    nLayerTests = 0

    for aFile in aFiles
        cFile = aFile[1]

        if not (right(lower(cFile), 5) = ".ring")
            loop
        ok

        if not (substr(lower(cFile), "test") > 0)
            loop
        ok

        if cFilePattern != "" and not (substr(lower(cFile), lower(cFilePattern)) > 0)
            loop
        ok

        nLayerTests++
        add(aTestFiles, [
            :layer = aLayer[:name],
            :file = cFile,
            :path = cTestDir + cFile,
            :status = "pending"
        ])
    next

    ? "  [" + upper(aLayer[:name]) + "] Found " + nLayerTests + " test files"
next

nTotalTests = len(aTestFiles)
? ""
? "  Total: " + nTotalTests + " test files discovered"
? "--------------------------------------------"
? ""

if bListOnly
    for aTest in aTestFiles
        ? "  [" + aTest[:layer] + "] " + aTest[:file]
    next
    ? ""
    ? "  Listed " + nTotalTests + " test files."
    return
ok

if bReport
    ? "============================================"
    ? "  COVERAGE REPORT"
    ? "============================================"
    ? ""

    # Map production files to test files
    aProduction = []

    # Core production files
    aCoreFiles = dir(cBaseDir + "core/string/")
    for aFile in aCoreFiles
        if right(lower(aFile[1]), 5) = ".ring" and substr(lower(aFile[1]), "test") = 0
            aProduction + [:layer = "core", :module = "string", :file = aFile[1]]
        ok
    next

    aCoreFiles = dir(cBaseDir + "core/number/")
    for aFile in aCoreFiles
        if right(lower(aFile[1]), 5) = ".ring" and substr(lower(aFile[1]), "test") = 0
            aProduction + [:layer = "core", :module = "number", :file = aFile[1]]
        ok
    next

    aCoreFiles = dir(cBaseDir + "core/list/")
    for aFile in aCoreFiles
        if right(lower(aFile[1]), 5) = ".ring" and substr(lower(aFile[1]), "test") = 0
            aProduction + [:layer = "core", :module = "list", :file = aFile[1]]
        ok
    next

    nCovered = 0
    nUncovered = 0

    for aProd in aProduction
        cBaseName = left(aProd[:file], len(aProd[:file]) - 5)
        cTestName = cBaseName + "test.ring"
        bFound = false

        for aTest in aTestFiles
            if lower(aTest[:file]) = lower(cTestName)
                bFound = true
                exit
            ok
        next

        if bFound
            nCovered++
            ? "  [OK] " + aProd[:layer] + "/" + aProd[:module] + "/" + aProd[:file]
        else
            nUncovered++
            ? "  [--] " + aProd[:layer] + "/" + aProd[:module] + "/" + aProd[:file] + " (NO TEST)"
        ok
    next

    ? ""
    ? "  Covered: " + nCovered + " | Uncovered: " + nUncovered
    ? "  Coverage: " + (nCovered * 100 / max(nCovered + nUncovered, 1)) + "%"
    ? ""
    return
ok

? ""
? "  Note: To run tests, use Ring directly:"
? "    ring <test-file>.ring"
? ""
? "  This runner currently operates in discovery/report mode."
? "  Full execution mode requires Ring process spawning."
? ""
