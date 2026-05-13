# Softanza Engine -- File FFI Bridge
#
# Loads stz_file.dll/.so and wraps each C function.
# Used by: base/file/stzFile.ring, base/file/stzDir.ring

if isWindows()
    $cStzFileLib = currentdir() + "/zig-out/bin/stz_file.dll"
but isLinux()
    $cStzFileLib = currentdir() + "/zig-out/lib/libstz_file.so"
but isMacOS()
    $cStzFileLib = currentdir() + "/zig-out/lib/libstz_file.dylib"
ok

if fexists($cStzFileLib)
    $pStzFileHandle = LoadLib($cStzFileLib)
else
    ? "WARNING: stz_file not found at: " + $cStzFileLib
    $pStzFileHandle = NULL
ok

# ── File Functions ──

func EngineFileExists(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_exists", "i", "pi",
                     cPath, len(cPath))

func EngineFileSize(cPath)
    if $pStzFileHandle = NULL return -1 ok
    return CallCFunc($pStzFileHandle, "stz_file_size", "i", "pi",
                     cPath, len(cPath))

func EngineFileRead(cPath)
    if $pStzFileHandle = NULL return "" ok
    nLen = 0
    pData = CallCFunc($pStzFileHandle, "stz_file_read", "p", "pip",
                      cPath, len(cPath), :nLen)
    if pData = NULL return "" ok
    cResult = copy(pData, nLen)
    CallCFunc($pStzFileHandle, "stz_file_read_free", "v", "pi", pData, nLen)
    return cResult

func EngineFileWrite(cPath, cData)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_write", "i", "pipi",
                     cPath, len(cPath), cData, len(cData))

func EngineFileAppend(cPath, cData)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_append", "i", "pipi",
                     cPath, len(cPath), cData, len(cData))

func EngineFileDelete(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_delete", "i", "pi",
                     cPath, len(cPath))

func EngineFileCopy(cSrc, cDst)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_copy", "i", "pipi",
                     cSrc, len(cSrc), cDst, len(cDst))

# ── Dir Functions ──

func EngineDirExists(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_dir_exists", "i", "pi",
                     cPath, len(cPath))

func EngineDirCreate(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_dir_create", "i", "pi",
                     cPath, len(cPath))

func EngineDirCreatePath(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_dir_create_path", "i", "pi",
                     cPath, len(cPath))

func EngineDirDelete(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_dir_delete", "i", "pi",
                     cPath, len(cPath))

func EngineDirCountFiles(cPath)
    if $pStzFileHandle = NULL return -1 ok
    return CallCFunc($pStzFileHandle, "stz_dir_count_files", "i", "pi",
                     cPath, len(cPath))

func EngineDirCountDirs(cPath)
    if $pStzFileHandle = NULL return -1 ok
    return CallCFunc($pStzFileHandle, "stz_dir_count_dirs", "i", "pi",
                     cPath, len(cPath))

# ── Path Functions ──

func EnginePathExtension(cPath)
    if $pStzFileHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pStzFileHandle, "stz_path_extension", "i", "pipi",
                     cPath, len(cPath), cBuf, 32)
    return left(cBuf, nLen)

func EnginePathBasename(cPath)
    if $pStzFileHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pStzFileHandle, "stz_path_basename", "i", "pipi",
                     cPath, len(cPath), cBuf, 256)
    return left(cBuf, nLen)

func EnginePathDirname(cPath)
    if $pStzFileHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pStzFileHandle, "stz_path_dirname", "i", "pipi",
                     cPath, len(cPath), cBuf, 256)
    return left(cBuf, nLen)
