# Smoke-test for the new direct yielder bridge variants
# (cross-DLL handle bypass landed in this session).

load "../stzBase.ring"

aIn = [1, -2, 3, -4, 5]
? "Input: " + list2str(aIn)

# Map direct (op 1 = abs)
aAbs = StzEngineYielderMapDirect(aIn, 1)
? "MapDirect(:abs)        = " + list2str(aAbs)

# Map direct (op 2 = negate)
aNeg = StzEngineYielderMapDirect(aIn, 2)
? "MapDirect(:negate)     = " + list2str(aNeg)

# Filter direct (op 7 = isPositive)
aPos = StzEngineYielderFilterDirect(aIn, 7)
? "FilterDirect(:isPos)   = " + list2str(aPos)

# Reduce direct (op 0 = sum)
nSum = StzEngineYielderReduceDirect(aIn, 0)
? "ReduceDirect(:sum)     = " + nSum

# Reduce direct (op 1 = product)
nProd = StzEngineYielderReduceDirect(aIn, 1)
? "ReduceDirect(:product) = " + nProd

# CountWhere direct (op 8 = isNegative)
nCnt = StzEngineYielderCountWhereDirect(aIn, 8)
? "CountWhereDirect(:neg) = " + nCnt

# ReduceConcat direct
aStr = ["a", "b", "c"]
cCat = StzEngineYielderReduceConcatDirect(aStr, "-")
? "ReduceConcatDirect('-')= " + cCat

# MapFiltered direct: keep positives, then square (filter=7, transform=4)
aMF = StzEngineYielderFilterMapDirect(aIn, 7, 4)
? "MapFilteredDirect      = " + list2str(aMF)
