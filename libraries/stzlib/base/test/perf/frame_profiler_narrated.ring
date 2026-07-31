# The frame profiler -- perf system P10 (SOFTANZA_PERF_SYSTEM.md).
#
# WHERE the time goes: cooperative frames into an engine-side call
# tree (calls / total / SELF ms per path), plus a REAL sampler thread
# photographing the active path at a fixed cadence -- statistical
# flame-graph truth whose cost is constant no matter how hot the code.
# Folded() emits the folded-stacks format flamegraph.pl/speedscope
# ingest as-is. The stzProfiler NAME is the P0 fossil's, resurrected.
#
# A reactor is created up front: its timeBeginPeriod(1) gives the
# sampler honest 1-2ms intervals (without it Windows rounds sleeps to
# ~15.6ms -- fewer samples, same statistics).
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no keyword-bearing names.

load "../../stzBase.ring"

nPass = 0
nFail = 0

oTimerFix = new stzReactor()   # process-wide 1ms timer resolution

pr()

? "-- Scene 1: nested frames, self vs total --"
oP = StzProfiler(64)
oP.Enter("checkout")
_s_ = ""
nT0 = StzEngineWatchTimestampMs()
while StzEngineWatchTimestampMs() - nT0 < 20
	_s_ += "x"
end
oP.Enter("validate")
nT0 = StzEngineWatchTimestampMs()
while StzEngineWatchTimestampMs() - nT0 < 30
	_s_ += "x"
end
oP.Leave()
oP.Enter("charge")
nT0 = StzEngineWatchTimestampMs()
while StzEngineWatchTimestampMs() - nT0 < 10
	_s_ += "x"
end
oP.Leave()
oP.Leave()
aP = oP.Paths()
chk("three paths accumulated", oP.PathCount() = 3)
chk("paths spell the tree", aP[1][:path] = "checkout;validate" and aP[2][:path] = "checkout;charge" and aP[3][:path] = "checkout")
nTot = aP[3][:totalMs]
nSelf = aP[3][:selfMs]
? "  checkout: total " + nTot + " ms, self " + nSelf + " ms (children ~40)"
chk("the parent's total covers everything (>= 55ms)", nTot >= 55)
chk("the parent's SELF excludes the children (~20ms, < 30)", nSelf < 30 and nSelf >= 15)
chk("child totals are their own (validate ~30)", aP[1][:totalMs] >= 25 and aP[1][:totalMs] < 45)

? ""
? "-- Scene 2: repeated frames accumulate --"
for i = 1 to 50
	oP.Enter("checkout")
	oP.Enter("validate")
	oP.Leave()
	oP.Leave()
next
aP = oP.Paths()
chk("50 more calls counted on the same paths", aP[1][:calls] = 51 and aP[3][:calls] = 51)

? ""
? "-- Scene 3: a Ring COPY profiles into the SAME tree --"
oP2 = oP
oP2.Enter("refund")
oP2.Leave()
chk("the original face sees the copy's frame", oP.PathCount() = 4)

? ""
? "-- Scene 4: HotSpots ranks by SELF time --"
aHot = oP.HotSpots(2)
chk("the busiest self-time path tops the list", aHot[1][:path] = "checkout;validate")

? ""
? "-- Scene 5: the sampler thread photographs the active path --"
oS = StzProfiler(64)
oS.StartSampling(2)
chk("sampling reports live", oS.IsSampling())
oS.Enter("outer")
oS.Enter("hot")
_s_ = ""
nT0 = StzEngineWatchTimestampMs()
while StzEngineWatchTimestampMs() - nT0 < 150
	_s_ += "x"
end
oS.Leave()
oS.Leave()
oS.StopSampling()
chk("sampling stopped", NOT oS.IsSampling())
? "  sampler ticks: " + oS.Ticks()
chk("the sampler really ticked (>= 30 over 150ms at 2ms)", oS.Ticks() >= 30)
aP = oS.Paths()
nHotSamples = 0
for i = 1 to len(aP)
	if aP[i][:path] = "outer;hot"
		nHotSamples = aP[i][:samples]
	ok
next
? "  outer;hot collected " + nHotSamples + " sample(s)"
chk("the hot path collected the samples (>= 10)", nHotSamples >= 10)

? ""
? "-- Scene 6: Folded() -- flame-graph food --"
cF = oS.Folded()
see cF
chk("folded lines carry 'path weight'", StzFindFirst("outer;hot " + nHotSamples, cF) > 0)
chk("sampled weights win when sampling ran", len(StzFind("outer;hot ", cF)) = 1)
oS.WriteFoldedTo("_tmp_folded.txt")
chk("the folded file is flamegraph-ready on disk", fexists("_tmp_folded.txt"))
remove("_tmp_folded.txt")
oS.Destroy()

? ""
? "-- Scene 7: bounded paths fold into _overflow, visibly --"
oB = StzProfiler(2)
oB.Enter("one")
oB.Leave()
oB.Enter("two")
oB.Leave()
oB.Enter("three")
oB.Leave()
aP = oB.Paths()
chk("the third distinct path folded into _overflow", oB.PathCount() = 2 and aP[2][:path] = "_overflow")
oB.Destroy()

? ""
? "-- Scene 8: the depth cap unwinds safely --"
oD = StzProfiler(64)
for i = 1 to 40
	oD.Enter("f" + i)
next
chk("depth caps at 32 (deeper frames fold into the parent)", oD.Depth() = 32)
for i = 1 to 40
	oD.Leave()
next
chk("40 leaves unwind to exactly 0 (no underflow)", oD.Depth() = 0)
oD.Destroy()

? ""
? "-- Scene 9: the profiler prices itself --"
oC = StzProfiler(64)
nT0 = StzEngineWatchTimestampNs()
for i = 1 to 10000
	oC.Enter("cost")
	oC.Leave()
next
nPerPair = (StzEngineWatchTimestampNs() - nT0) / 10000 / 1000
? "  Enter+Leave costs " + nPerPair + " us per pair"
chk("a frame pair costs under 50us (generous; measured far less)", nPerPair < 50)
oC.Destroy()
oP.Destroy()

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func fabs n
	if n < 0 return -n ok
	return n
