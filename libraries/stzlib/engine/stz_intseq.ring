# Softanza Engine -- Integer Sequence (IntSeq)
#
# Loads stz_intseq.dll. Exposes a generic typed integer sequence
# handle: bulk-allocated []i64 backing store, fast O(1) accessors,
# O(N) bulk operations that stay in Zig (no per-item FFI). Designed
# to bypass the host language's per-item list-append cost.
#
# Function prefix: StzEngineIntSeq*
#
# Typical usage from Ring:
#   pSeq = StzEngineIntSeqCreateCycle(1, 1, 4, 1, 1000000, 1)
#   nLen = StzEngineIntSeqLen(pSeq)          # O(1)
#   nSum = StzEngineIntSeqSum(pSeq)          # O(N) in Zig, no FFI loop
#   nV   = StzEngineIntSeqAt(pSeq, 999999)   # O(1)
#   aR   = StzEngineIntSeqToRingList(pSeq)   # opt-in marshal (slow on Ring)
#   StzEngineIntSeqFree(pSeq)

if isWindows()
    $cStzIntSeqLib = $cEngineDir + "/zig-out/bin/stz_intseq.dll"
but isLinux()
    $cStzIntSeqLib = $cEngineDir + "/zig-out/lib/libstz_intseq.so"
but isMacOS()
    $cStzIntSeqLib = $cEngineDir + "/zig-out/lib/libstz_intseq.dylib"
ok
if fexists($cStzIntSeqLib)
    $pStzIntSeqHandle = LoadLib($cStzIntSeqLib)
else
    ? "WARNING: stz_intseq not found at: " + $cStzIntSeqLib
    $pStzIntSeqHandle = NULL
ok
