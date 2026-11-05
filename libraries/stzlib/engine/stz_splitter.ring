# Softanza Engine -- Advanced Splitter
#
# Loads stz_splitter.dll for split-by-str/width/chars/lines/words.
#
# Function prefix: StzEngineSplitter*

if isWindows()
    $cStzSplitterLib = $cEngineDir + "/zig-out/bin/stz_splitter.dll"
but isLinux()
    $cStzSplitterLib = $cEngineDir + "/zig-out/lib/libstz_splitter.so"
but isMacOS()
    $cStzSplitterLib = $cEngineDir + "/zig-out/lib/libstz_splitter.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("splitter")
    $pStzSplitterHandle = NULL
but fexists($cStzSplitterLib)
    $pStzSplitterHandle = LoadLib($cStzSplitterLib)
else
    ? "WARNING: stz_splitter not found at: " + $cStzSplitterLib
    $pStzSplitterHandle = NULL
ok
