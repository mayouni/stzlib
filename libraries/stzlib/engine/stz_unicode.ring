# Softanza Engine -- Base Unicode Ring Bridge
#
# Loads stz_unicode.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/unicode/stzUnicode.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzUnicodeLib = $cEngineDir + "/zig-out/bin/stz_unicode.dll"
but isLinux()
    $cStzUnicodeLib = $cEngineDir + "/zig-out/lib/libstz_unicode.so"
but isMacOS()
    $cStzUnicodeLib = $cEngineDir + "/zig-out/lib/libstz_unicode.dylib"
ok

if fexists($cStzUnicodeLib)
    $pStzUnicodeHandle = LoadLib($cStzUnicodeLib)
else
    ? "WARNING: stz_unicode not found at: " + $cStzUnicodeLib
    $pStzUnicodeHandle = NULL
ok
