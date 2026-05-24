# Softanza Engine -- HTML Utilities
#
# Loads stz_html.dll for HTML entity encoding/decoding, tag stripping.
#
# Function prefix: StzEngineHtml*

if isWindows()
    $cStzHtmlLib = $cEngineDir + "/zig-out/bin/stz_html.dll"
but isLinux()
    $cStzHtmlLib = $cEngineDir + "/zig-out/lib/libstz_html.so"
but isMacOS()
    $cStzHtmlLib = $cEngineDir + "/zig-out/lib/libstz_html.dylib"
ok

if fexists($cStzHtmlLib)
    $pStzHtmlHandle = LoadLib($cStzHtmlLib)
else
    ? "WARNING: stz_html not found at: " + $cStzHtmlLib
    $pStzHtmlHandle = NULL
ok
