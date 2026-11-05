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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("unicode")
    $pStzUnicodeHandle = NULL
but fexists($cStzUnicodeLib)
    $pStzUnicodeHandle = LoadLib($cStzUnicodeLib)
else
    ? "WARNING: stz_unicode not found at: " + $cStzUnicodeLib
    $pStzUnicodeHandle = NULL
ok
