# COMPASS-KERN-07 -- the engine's secret cell, checked WITHOUT the library, so it
# runs on rnxc today (a guard that loads stzlib cannot yet: RING-RETIRED-01).
# secret_memory_narrated.ring is the full story through stzSecret; this is its
# engine floor: locked, wiped, compared in constant time, stale copy refused.
#
#   rnxc:  set STZ_CRYPTO_DLL to the Ring++ build of stz_crypto.dll
#          (engine_copy.py ... stz_crypto, then ONLY=stz_crypto zig build -j2)
#   Ring:  leave it unset; this tree's own build is used
# Exits with its fail count.

cDll = sysget("STZ_CRYPTO_DLL")
if cDll = ""  cDll = "../../../engine/zig-out/bin/stz_crypto.dll"  ok
LoadLib(cDll)
$nFail = 0  nRun = 0
h = StzEngineSecretHold("invented-probe-value")
nRun++ if StzEngineSecretIsLocked(h) != 1 $nFail++ ? "FAIL locked" ok
nRun++ if StzEngineSecretEquals(h, "invented-probe-value") != 1 $nFail++ ? "FAIL eq" ok
nRun++ if StzEngineSecretEquals(h, "invented-probe-valuE") != 0 $nFail++ ? "FAIL neq" ok
h2 = h
nRun++ if StzEngineSecretRelease(h) != 0 $nFail++ ? "FAIL residue" ok
nRun++ if StzEngineSecretLastResidueBefore() != 20 $nFail++ ? "FAIL before" ok
cErr = ""
try StzEngineSecretSize(h2) catch cErr = cCatchError done
nRun++ if cErr = "" $nFail++ ? "FAIL stale copy did not raise" ok
nLocked = 0
for i = 1 to 200  x = StzEngineSecretHold("v" + i)  if StzEngineSecretIsLocked(x) = 1 nLocked++ ok  next
nRun++ if nLocked != 200 $nFail++ ? "FAIL locked " + nLocked ok
hb = StzEngineSecretHold(copy("a", 65536))
r = StzEngineSecretCompareRatio(hb, "b" + copy("a", 65535), copy("a", 65535) + "b", 201, 8, 0)
nRun++ if r < 0.8 or r > 1.25 $nFail++ ? "FAIL ratio " + r ok
? "cell probe: " + nRun + " checks, " + $nFail + " failed; locked " + nLocked + "/200, ratio " + r
shutdown($nFail)
