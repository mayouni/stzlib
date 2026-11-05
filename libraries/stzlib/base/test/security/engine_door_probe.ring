# SECURITY-R18b -- the engine door WITHOUT the library and WITHOUT stz_seclog
# loaded first: a model-shaped call in stz_testsrv must load stz_seclog from
# beside itself and write its record there. Runs on rnxc today.
#
#   rnxc:  set STZ_ENGINE_BIN to the folder of the Ring++ builds of stz_testsrv
#          and stz_seclog (engine_copy.py ... stz_seclog stz_testsrv)
#   Ring:  leave it unset; this tree's own build is used
# Exits with its fail count.

cBin = sysget("STZ_ENGINE_BIN")
if cBin = ""  cBin = "../../../engine/zig-out/bin"  ok
nFail = 0  nRun = 0
LoadLib(cBin + "/stz_testsrv.dll")             # stz_seclog is NOT loaded
nRun++ if StzEngineTestSrvDoorProbe("llama", "first") != 1  nFail++ ? "FAIL the door did not write" ok
for i = 1 to 20  StzEngineTestSrvDoorProbe("llama", "call " + i)  next
nRun++ if StzEngineTestSrvDoorMissed() != 0  nFail++ ? "FAIL missed " + StzEngineTestSrvDoorMissed() ok
LoadLib(cBin + "/stz_seclog.dll")              # the SAME module the door loaded
nRun++ if StzEngineSecLogHasCurrent() != 1  nFail++ ? "FAIL no process ledger" ok
h = StzEngineSecLogCurrent()
nRun++ if StzEngineSecLogCount(h) != 21  nFail++ ? "FAIL count " + StzEngineSecLogCount(h) ok
nRun++ if StzEngineSecLogVerify(h) != 0  nFail++ ? "FAIL chain broken at " + StzEngineSecLogVerify(h) ok   # 0 = intact
? "engine door probe: " + nRun + " checks, " + nFail + " failed; " + StzEngineSecLogCount(h) + " records for 21 calls, seclog loaded by the door"
shutdown(nFail)
