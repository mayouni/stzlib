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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("embed")
    $pStzEmbedHandle = NULL
but fexists($cStzEmbedLib)
    $pStzEmbedHandle = LoadLib($cStzEmbedLib)
else
    ? "WARNING: stz_embed not found at: " + $cStzEmbedLib
    $pStzEmbedHandle = NULL
ok
