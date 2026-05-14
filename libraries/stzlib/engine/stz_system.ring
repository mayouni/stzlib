# Softanza Engine -- Base System FFI Bridge
#
# Loads stz_system.dll -- process execution.
# Used by: base/system/stzSystemCall.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzSystemLib = $cEngineDir + "/zig-out/bin/stz_system.dll"
but isLinux()
    $cStzSystemLib = $cEngineDir + "/zig-out/lib/libstz_system.so"
but isMacOS()
    $cStzSystemLib = $cEngineDir + "/zig-out/lib/libstz_system.dylib"
ok

if fexists($cStzSystemLib)
    $pStzSystemHandle = LoadLib($cStzSystemLib)
else
    ? "WARNING: stz_system not found at: " + $cStzSystemLib
    $pStzSystemHandle = NULL
ok

func StzEngineSystemRun(cCommand)
    if $pStzSystemHandle = NULL return [:output = "", :error = "", :exitcode = -1] ok
    nOutLen = 0
    nErrLen = 0
    nExitCode = -1
    pData = CallCFunc($pStzSystemHandle, "stz_system_run", "p", "pipppp",
                      cCommand, len(cCommand), :nOutLen, :nErrLen, :nExitCode)
    cOutput = ""
    if pData != NULL and nOutLen > 0
        cOutput = copy(pData, nOutLen)
        CallCFunc($pStzSystemHandle, "stz_system_run_free", "v", "pi", pData, nOutLen)
    ok
    return [:output = cOutput, :error = "", :exitcode = nExitCode]

func StzEngineSystemExec(cCommand)
    if $pStzSystemHandle = NULL return -1 ok
    return CallCFunc($pStzSystemHandle, "stz_system_exec", "i", "pi",
                     cCommand, len(cCommand))

func StzEngineSystemEnv(cName)
    if $pStzSystemHandle = NULL return "" ok
    cBuf = space(4096)
    nLen = CallCFunc($pStzSystemHandle, "stz_system_env", "i", "pipi",
                     cName, len(cName), cBuf, 4096)
    return left(cBuf, nLen)

func StzEngineSystemIsWindows()
    if $pStzSystemHandle = NULL return isWindows() ok
    return CallCFunc($pStzSystemHandle, "stz_system_is_windows", "i", "")

func StzEngineSystemIsLinux()
    if $pStzSystemHandle = NULL return isLinux() ok
    return CallCFunc($pStzSystemHandle, "stz_system_is_linux", "i", "")

func StzEngineSystemIsMacOS()
    if $pStzSystemHandle = NULL return isMacOS() ok
    return CallCFunc($pStzSystemHandle, "stz_system_is_macos", "i", "")
