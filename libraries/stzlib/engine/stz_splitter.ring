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

if fexists($cStzSplitterLib)
    $pStzSplitterHandle = LoadLib($cStzSplitterLib)
else
    ? "WARNING: stz_splitter not found at: " + $cStzSplitterLib
    $pStzSplitterHandle = NULL
ok
