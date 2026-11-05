# Softanza Engine -- Text Operations
#
# Loads stz_text.dll for paragraph/sentence segmentation,
# word/char/line counting, readability metrics, and truncation.
#
# Function prefix: StzEngineText*

if isWindows()
    $cStzTextLib = $cEngineDir + "/zig-out/bin/stz_text.dll"
but isLinux()
    $cStzTextLib = $cEngineDir + "/zig-out/lib/libstz_text.so"
but isMacOS()
    $cStzTextLib = $cEngineDir + "/zig-out/lib/libstz_text.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("text")
    $pStzTextHandle = NULL
but fexists($cStzTextLib)
    $pStzTextHandle = LoadLib($cStzTextLib)
else
    ? "WARNING: stz_text not found at: " + $cStzTextLib
    $pStzTextHandle = NULL
ok
