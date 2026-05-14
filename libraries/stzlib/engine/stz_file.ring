# Softanza Engine -- Base File FFI Bridge
#
# Loads stz_file.dll -- full features, superset of Core.
# Used by: base/file/stzFile.ring, base/file/stzDir.ring
# Function prefix: StzEngine* (distinct from Core StkEngine*)

if isWindows()
    $cStzFileLib = $cEngineDir + "/zig-out/bin/stz_file.dll"
but isLinux()
    $cStzFileLib = $cEngineDir + "/zig-out/lib/libstz_file.so"
but isMacOS()
    $cStzFileLib = $cEngineDir + "/zig-out/lib/libstz_file.dylib"
ok

if fexists($cStzFileLib)
    $pStzFileHandle = LoadLib($cStzFileLib)
else
    ? "WARNING: stz_file not found at: " + $cStzFileLib
    $pStzFileHandle = NULL
ok

# ── File Functions (Core: exists, read, write, delete / Base adds: size, append, copy) ──

func StzEngineFileExists(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_exists", "i", "pi",
                     cPath, len(cPath))

func StzEngineFileSize(cPath)
    if $pStzFileHandle = NULL return -1 ok
    return CallCFunc($pStzFileHandle, "stz_file_size", "i", "pi",
                     cPath, len(cPath))

func StzEngineFileRead(cPath)
    if $pStzFileHandle = NULL return "" ok
    nLen = 0
    pData = CallCFunc($pStzFileHandle, "stz_file_read", "p", "pip",
                      cPath, len(cPath), :nLen)
    if pData = NULL return "" ok
    cResult = copy(pData, nLen)
    CallCFunc($pStzFileHandle, "stz_file_read_free", "v", "pi", pData, nLen)
    return cResult

func StzEngineFileWrite(cPath, cData)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_write", "i", "pipi",
                     cPath, len(cPath), cData, len(cData))

func StzEngineFileAppend(cPath, cData)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_append", "i", "pipi",
                     cPath, len(cPath), cData, len(cData))

func StzEngineFileDelete(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_delete", "i", "pi",
                     cPath, len(cPath))

func StzEngineFileCopy(cSrc, cDst)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_file_copy", "i", "pipi",
                     cSrc, len(cSrc), cDst, len(cDst))

# ── Dir Functions (Core: exists / Base adds: create, delete, count) ──

func StzEngineDirExists(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_dir_exists", "i", "pi",
                     cPath, len(cPath))

func StzEngineDirCreate(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_dir_create", "i", "pi",
                     cPath, len(cPath))

func StzEngineDirCreatePath(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_dir_create_path", "i", "pi",
                     cPath, len(cPath))

func StzEngineDirDelete(cPath)
    if $pStzFileHandle = NULL return 0 ok
    return CallCFunc($pStzFileHandle, "stz_dir_delete", "i", "pi",
                     cPath, len(cPath))

func StzEngineDirCountFiles(cPath)
    if $pStzFileHandle = NULL return -1 ok
    return CallCFunc($pStzFileHandle, "stz_dir_count_files", "i", "pi",
                     cPath, len(cPath))

func StzEngineDirCountDirs(cPath)
    if $pStzFileHandle = NULL return -1 ok
    return CallCFunc($pStzFileHandle, "stz_dir_count_dirs", "i", "pi",
                     cPath, len(cPath))

# ── Path Functions (Base only) ──

func StzEnginePathExtension(cPath)
    if $pStzFileHandle = NULL return "" ok
    cBuf = space(32)
    nLen = CallCFunc($pStzFileHandle, "stz_path_extension", "i", "pipi",
                     cPath, len(cPath), cBuf, 32)
    return left(cBuf, nLen)

func StzEnginePathBasename(cPath)
    if $pStzFileHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pStzFileHandle, "stz_path_basename", "i", "pipi",
                     cPath, len(cPath), cBuf, 256)
    return left(cBuf, nLen)

func StzEnginePathDirname(cPath)
    if $pStzFileHandle = NULL return "" ok
    cBuf = space(256)
    nLen = CallCFunc($pStzFileHandle, "stz_path_dirname", "i", "pipi",
                     cPath, len(cPath), cBuf, 256)
    return left(cBuf, nLen)
