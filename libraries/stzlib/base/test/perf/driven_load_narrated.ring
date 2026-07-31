# The driven-load harness -- perf system P11 (SOFTANZA_PERF_SYSTEM.md).
#
# The R-vs-X knee needs CONCURRENT ARRIVALS, and a serial in-process
# harness can never produce them (P7 ruled exactly that). This guard
# proves the ruling closed: stzLoadDriver spawns a real target server
# child and N real driver children; queueing forms at the listener;
# and the knee -- throughput saturating while response time grows --
# appears in the measured curve. REAL PROCESSES, so this suite is
# TIMED and heavier than its siblings (~15-30s); scale bounds are
# generous by design.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no keyword-bearing names.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nSuite0 = StzEngineWatchTimestampMs()

pr()

? "-- Scene 1: the harness spawns its own target, and it answers --"
oL = StzLoadDriver()
oL.SetBusyMs(3).SetRequestsPerDriver(25)
bUp = oL.SpawnTarget(0)
chk("the target child came up and passed its readiness probe", bUp)
? "  target on 127.0.0.1:" + oL.Port()

? ""
? "-- Scene 2: one driver -- the unloaded baseline --"
aLo = oL.DriveWith(1)
? "  X = " + aLo[:x] + " req/s ; R mean = " + aLo[:rMeanMs] + " ms ; p95 = " + aLo[:rP95Ms] + " ms"
chk("all requests came home", aLo[:requests] = 25)
chk("R covers at least the service demand (>= 3ms)", aLo[:rMeanMs] >= 3)
chk("X is a real rate", aLo[:x] > 0)

? ""
? "-- Scene 3: six drivers -- the knee appears --"
aHi = oL.DriveWith(6)
? "  X = " + aHi[:x] + " req/s ; R mean = " + aHi[:rMeanMs] + " ms ; p95 = " + aHi[:rP95Ms] + " ms"
chk("all 150 requests came home", aHi[:requests] = 150)
chk("more offered load bought MORE throughput", aHi[:x] > aLo[:x])
chk("...and MORE waiting: R grew visibly (>= 1.5x)", aHi[:rMeanMs] >= aLo[:rMeanMs] * 1.5)
chk("the p95 grew too (queueing is not just the mean)", aHi[:rP95Ms] > aLo[:rP95Ms])

? ""
? "-- Scene 4: the narrated knee --"
oL.Show()
aLines = oL.Explain()
chk("the story names the trade", StzFindFirst("past saturation", aLines[len(aLines)]) > 0)

? ""
? "-- Scene 5: Destroy() kills the target child --"
oL.Destroy()
StzEngineTimeSleepMs(300)
chk("the target no longer answers its probe", NOT oL.WaitReady(1200))

nSuiteMs = StzEngineWatchTimestampMs() - nSuite0
? ""
? "  (suite drove real processes for " + nSuiteMs + " ms)"
chk("the whole drive stayed inside its budget (< 45s)", nSuiteMs < 45000)

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
