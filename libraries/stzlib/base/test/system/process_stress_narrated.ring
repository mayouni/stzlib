# Process introspection STRESS -- stz_process.dll (pid, uptime, arch, os,
# endian, pointer size).
#
# The one that mattered here was UPTIME. The three uptime functions returned
# std.time.nanoTimestamp() -- wall-clock time since the Unix EPOCH -- so
# UptimeS() answered ~1.75 BILLION (about 56 years), not "seconds since this
# process started". Now they count from a monotonic clock captured at DLL
# load. That is the headline check; the rest confirm the plain facts stay
# right and agree with the OS layer.
#
# Pure introspection: no files, no OS commands, no scratch state.
#
# Ring traps avoided: main code before the first func; no local oR / nL / Try
# / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: uptime is PROCESS uptime, not the Unix epoch --"
nUpS = StzEngineProcessUptimeS()
? "  UptimeS() = " + nUpS + " s"
chk("uptime is a small, sane number of seconds (< 3600)", nUpS >= 0 and nUpS < 3600)
chk("uptime is NOT epoch wall-clock (~1.7e9 = 56 years)", nUpS < 100000000)

? ""
? "-- Scene 2: uptime is MONOTONIC and advances --"
# Two reads with real work between them: the second must be >= the first, and
# a busy stretch must register some elapsed time.
nA = StzEngineProcessUptimeMs()
_s_ = ""
for i = 1 to 300000
	_s_ += "x"
next
nB = StzEngineProcessUptimeMs()
chk("a later read is not smaller than an earlier one", nB >= nA)
chk("...and a busy stretch registers elapsed time", (nB - nA) > 0)

# Never goes backwards across a run of reads.
bMono = TRUE
nPrev = StzEngineProcessUptimeNs()
for i = 1 to 50
	nNow = StzEngineProcessUptimeNs()
	if nNow < nPrev
		bMono = FALSE
	ok
	nPrev = nNow
next
chk("50 successive reads never decrease", bMono)

? ""
? "-- Scene 3: ns / ms / s are the same clock in different units --"
nNs = StzEngineProcessUptimeNs()
nMs = StzEngineProcessUptimeMs()
nSs = StzEngineProcessUptimeS()
# Read close together, so the units should line up within a small tolerance.
chk("ns / 1e6 is about ms (within 50 ms)", fabs(nNs/1000000 - nMs) < 50)
chk("ms / 1000 is about s (within 0.05 s)", fabs(nMs/1000 - nSs) < 0.05)

? ""
? "-- Scene 4: pid is a real, stable process id --"
nPid = StzEngineProcessPid()
chk("pid is positive", nPid > 0)
chk("pid is stable within one process", nPid = StzEngineProcessPid())
chk("...stable again on a third read", StzEngineProcessPid() = nPid)

? ""
? "-- Scene 5: architecture / os / endian / pointer size --"
cArch = StzEngineProcessArch()
cOs = StzEngineProcessOs()
nEnd = StzEngineProcessEndian()
nPtr = StzEngineProcessPtrSize()
? "  arch=[" + cArch + "] os=[" + cOs + "] endian=" + nEnd + " ptr=" + nPtr + " bytes"
chk("arch is a non-empty string", len(cArch) > 0)
chk("os is a non-empty string", len(cOs) > 0)
chk("endian is 0 (little) or 1 (big)", nEnd = 0 or nEnd = 1)
chk("pointer size is 4 or 8 bytes", nPtr = 4 or nPtr = 8)

? ""
? "-- Scene 6: pointer size AGREES with the OS layer's bit size --"
# stzOperatingSystem decides 32/64-bit independently (Ring's getArch), so the
# engine's pointer size must line up: 8 bytes == 64 bits.
oOS = new stzOperatingSystem()
nBits = oOS.BitSize()
? "  engine ptr " + nPtr + " bytes -> " + (nPtr * 8) + " bits ; OS layer BitSize = " + nBits
chk("engine pointer size * 8 equals the OS layer's bit size", nPtr * 8 = nBits)
chk("...and both say 64-bit on this build", nBits = 64 and nPtr = 8)

? ""
? "-- Scene 7: many rapid reads stay fast and consistent --"
t0 = clock()
nSame = 0
nBaseP = StzEngineProcessPid()
for i = 1 to 5000
	if StzEngineProcessPid() = nBaseP
		nSame++
	ok
next
tRead = (clock() - t0) / clockspersecond()
? "  5000 pid reads in " + tRead + " s"
chk("5000 introspection calls are fast (< 5s)", tRead < 5)
chk("...and every pid read matched", nSame = 5000)

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
