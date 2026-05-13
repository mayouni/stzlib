# Softanza Engine -- Core File FFI Bridge
#
# Loads stk_file.dll -- exists, read, write, delete, dir_exists.
# Used by: core/file/stkFile.ring
# Function prefix: StkEngine* (distinct from Base StzEngine*)

if isWindows()
    $cStkFileLib = currentdir() + "/zig-out/bin/stk_file.dll"
but isLinux()
    $cStkFileLib = currentdir() + "/zig-out/lib/libstk_file.so"
but isMacOS()
    $cStkFileLib = currentdir() + "/zig-out/lib/libstk_file.dylib"
ok

if fexists($cStkFileLib)
    $pStkFileHandle = LoadLib($cStkFileLib)
else
    ? "WARNING: stk_file not found at: " + $cStkFileLib
    $pStkFileHandle = NULL
ok

func StkEngineFileExists(cPath)
    if $pStkFileHandle = NULL return 0 ok
    return CallCFunc($pStkFileHandle, "stz_file_exists", "i", "pi",
                     cPath, len(cPath))

func StkEngineFileRead(cPath)
    if $pStkFileHandle = NULL return "" ok
    nLen = 0
    pData = CallCFunc($pStkFileHandle, "stz_file_read", "p", "pip",
                      cPath, len(cPath), :nLen)
    if pData = NULL return "" ok
    cResult = copy(pData, nLen)
    CallCFunc($pStkFileHandle, "stz_file_read_free", "v", "pi", pData, nLen)
    return cResult

func StkEngineFileWrite(cPath, cData)
    if $pStkFileHandle = NULL return 0 ok
    return CallCFunc($pStkFileHandle, "stz_file_write", "i", "pipi",
                     cPath, len(cPath), cData, len(cData))

func StkEngineFileDelete(cPath)
    if $pStkFileHandle = NULL return 0 ok
    return CallCFunc($pStkFileHandle, "stz_file_delete", "i", "pi",
                     cPath, len(cPath))

func StkEngineDirExists(cPath)
    if $pStkFileHandle = NULL return 0 ok
    return CallCFunc($pStkFileHandle, "stz_dir_exists", "i", "pi",
                     cPath, len(cPath))
