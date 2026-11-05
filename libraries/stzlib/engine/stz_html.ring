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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("html")
    $pStzHtmlHandle = NULL
but fexists($cStzHtmlLib)
    $pStzHtmlHandle = LoadLib($cStzHtmlLib)
else
    ? "WARNING: stz_html not found at: " + $cStzHtmlLib
    $pStzHtmlHandle = NULL
ok
