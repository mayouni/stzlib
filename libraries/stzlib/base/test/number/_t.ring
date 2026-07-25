load "../../stzBase.ring"
? "=== the buffer works ==="
b = StzEngineNumBufNew(5)
StzEngineNumBufRange(b, 1, 1)
? "  range 1..5   len=" + StzEngineNumBufLen(b) + " sum=" + StzEngineNumBufSum(b) + " mean=" + StzEngineNumBufMean(b)
StzEngineNumBufScale(b, 2)
StzEngineNumBufAddScalar(b, 1)
? "  after x2 +1  sum=" + StzEngineNumBufSum(b) + " min=" + StzEngineNumBufMin(b) + " max=" + StzEngineNumBufMax(b)
? "  as a list    = " + @@(StzEngineNumBufToList(b))
StzEngineNumBufFree(b)

? ""
? "=== variance asks the one authority ==="
c = StzEngineNumBufFromList([2,4,4,4,5,5,7,9])
? "  population = " + StzEngineNumBufVariance(c, 0) + "   sample = " + StzEngineNumBufVariance(c, 1)
StzEngineNumBufFree(c)

? ""
? "=== the compensated sum ==="
d = StzEngineNumBufNew(1001)
StzEngineNumBufFill(d, 1)
StzEngineNumBufSet(d, 1, number("1e16"))
? "  1e16 + 1000 ones = " + StzEngineNumBufSum(d) + "   (a naive sum gives 1e16)"
StzEngineNumBufFree(d)
