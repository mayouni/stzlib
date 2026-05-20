# Softanza Engine -- Base Regex Ring Bridge
#
# Loads stz_regex.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/regex/stzRegex.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzRegexLib = $cEngineDir + "/zig-out/bin/stz_regex.dll"
but isLinux()
    $cStzRegexLib = $cEngineDir + "/zig-out/lib/libstz_regex.so"
but isMacOS()
    $cStzRegexLib = $cEngineDir + "/zig-out/lib/libstz_regex.dylib"
ok

if fexists($cStzRegexLib)
    $pStzRegexHandle = LoadLib($cStzRegexLib)
else
    ? "WARNING: stz_regex not found at: " + $cStzRegexLib
    $pStzRegexHandle = NULL
ok

#------------------------------------------------------------#
#  HIGH-LEVEL REGEX WRAPPERS                                 #
#------------------------------------------------------------#

func StzRegexMatchAll(cPattern, cInput)
    pHandle = StzEngineRegexNew(cPattern, 0)
    nCount = StzEngineRegexMatchAll(pHandle, cInput)
    aResult = []
    for i = 0 to nCount - 1
        cText = StzEngineRegexCaptureText(pHandle, i)
        nStart = StzEngineRegexCaptureStart(pHandle, i)
        aResult + [ :text = cText, :position = nStart + 1 ]
    next
    StzEngineRegexFree(pHandle)
    return aResult

func StzRegexSetLimits(pHandle, nMaxSteps, nMaxMatches, nMaxCaptures)
    StzEngineRegexSetLimits(pHandle, nMaxSteps, nMaxMatches, nMaxCaptures)
