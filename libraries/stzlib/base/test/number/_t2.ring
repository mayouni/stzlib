load "../../stzBase.ring"
nN = 200000
? "=== the measurement phase 3 exists for (" + nN + " numbers) ==="

# the pattern residency replaces: marshal per call
an = []
for i = 1 to nN
	an + (i % 1000)
next

t0 = clock()
n1 = 0
for k = 1 to 5
	p = StzEngineStatsCreate(an)
	n1 = StzEngineStatsMean(p)
next
t1 = clock()
? "  5 reductions, MARSHALLING each time : " + ((t1-t0)/clockspersecond()) + "s"

# residency: one crossing, then five reductions on resident memory
t2 = clock()
b = StzEngineNumBufFromList(an)
t3 = clock()
n2 = 0
for k = 1 to 5
	n2 = StzEngineNumBufMean(b)
next
t4 = clock()
? "  one crossing to make it resident   : " + ((t3-t2)/clockspersecond()) + "s"
? "  then 5 reductions on the buffer    : " + ((t4-t3)/clockspersecond()) + "s"
? "  total                              : " + ((t4-t2)/clockspersecond()) + "s"
? "  same answer: " + (Rnd2(n1) = Rnd2(n2))

? ""
? "=== a CHAIN of elementwise ops, where the difference is starkest ==="
t5 = clock()
for k = 1 to 10
	StzEngineNumBufScale(b, 1.0)
	StzEngineNumBufAddScalar(b, 0)
next
t6 = clock()
? "  20 full passes over 200k, resident : " + ((t6-t5)/clockspersecond()) + "s"
? "  (each pass would otherwise cost a marshal of the whole list)"
StzEngineNumBufFree(b)

func Rnd2(n)
	return ceil(n * 100 - 0.5) / 100
