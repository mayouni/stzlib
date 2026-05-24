# Softanza Engine -- Embed (Version, Build Info, Feature Flags)
#
# Loads stz_embed.dll for engine introspection and feature registry.
#
# Function prefix: StzEngineEmbed*

if isWindows()
    $cStzEmbedLib = $cEngineDir + "/zig-out/bin/stz_embed.dll"
but isLinux()
    $cStzEmbedLib = $cEngineDir + "/zig-out/lib/libstz_embed.so"
but isMacOS()
    $cStzEmbedLib = $cEngineDir + "/zig-out/lib/libstz_embed.dylib"
ok

if fexists($cStzEmbedLib)
    $pStzEmbedHandle = LoadLib($cStzEmbedLib)
else
    ? "WARNING: stz_embed not found at: " + $cStzEmbedLib
    $pStzEmbedHandle = NULL
ok
