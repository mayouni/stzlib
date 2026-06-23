load "../../stzBase.ring"

# Self-checking harness for the engine-residency cache
# (StzEngineListCacheRegister / CacheGet / CacheInvalidate) that backs
# stzList's @pEngineGen. The cache OWNS a registered handle: never free it
# separately; Invalidate frees it (and releases its handle-table slot).
#
# Prints "N pass, M fail" so the test sweep flags any regression.

nPass = 0
nFail = 0
aFail = []

# 1) roundtrip: register -> get -> invalidate -> miss
pId = StzEngineMarshalList([ 10, 20, 30 ])
if pId > 0 nPass++ else nFail++ aFail + "marshal id > 0" ok

nGen = StzEngineListCacheRegister(pId)
if nGen > 0 nPass++ else nFail++ aFail + "register gen > 0" ok
if StzEngineListCacheGet(nGen) = pId nPass++ else nFail++ aFail + "get(gen) = id" ok
if StzEngineListLen(StzEngineListCacheGet(nGen)) = 3 nPass++ else nFail++ aFail + "len via cached handle = 3" ok

StzEngineListCacheInvalidate(nGen)
if StzEngineListCacheGet(nGen) = 0 nPass++ else nFail++ aFail + "get after invalidate = miss" ok

# 2) distinct registrations -> distinct gens, independent lifetimes
p1 = StzEngineMarshalList([ 1 ])
p2 = StzEngineMarshalList([ 2 ])
g1 = StzEngineListCacheRegister(p1)
g2 = StzEngineListCacheRegister(p2)
if g1 != g2 nPass++ else nFail++ aFail + "distinct gens" ok
if StzEngineListCacheGet(g1) = p1 and StzEngineListCacheGet(g2) = p2 nPass++ else nFail++ aFail + "each gen -> own handle" ok
StzEngineListCacheInvalidate(g1)
if StzEngineListCacheGet(g2) = p2 and StzEngineListCacheGet(g1) = 0 nPass++ else nFail++ aFail + "invalidate g1 keeps g2" ok
StzEngineListCacheInvalidate(g2)

# 3) eviction stress: many registrations must not crash, must release handle
#    slots (else the 8192-slot table overflows), and the newest stays live
nLastGen = 0
for i = 1 to 5000
    pX = StzEngineMarshalList([ i, i+1, i+2 ])
    nLastGen = StzEngineListCacheRegister(pX)
next
if StzEngineListCacheGet(nLastGen) != 0 nPass++ else nFail++ aFail + "last gen live after 5000 regs" ok
if StzEngineListLen(StzEngineListCacheGet(nLastGen)) = 3 nPass++ else nFail++ aFail + "last cached handle usable" ok

# 4) residency through the stzList API: repeated reads on ONE object stay
#    correct (cache reused), and a write invalidates so reads see the change
o = Q([ 5, 1, 5, 3, 5 ])
if o.Sum() = 19 nPass++ else nFail++ aFail + "Sum reused-cache correct" ok
if o.NumberOfOccurrences(5) = 3 nPass++ else nFail++ aFail + "Count reused-cache correct" ok
o.Add(5)
if o.NumberOfOccurrences(5) = 4 nPass++ else nFail++ aFail + "write invalidates cache (count updates)" ok
if o.Sum() = 24 nPass++ else nFail++ aFail + "Sum after write correct" ok
o.RemoveDuplicates()
if o.NumberOfItems() = 3 nPass++ else nFail++ aFail + "dedup via adopt correct" ok

nLen = len(aFail)
for i = 1 to nLen
    ? "  [FAIL] " + aFail[i]
next
? "================================================"
? "RESIDENCY CACHE: " + nPass + " pass, " + nFail + " fail"
if nFail = 0 ? "STATUS: OK" else ? "STATUS: FAIL" ok
? "================================================"
