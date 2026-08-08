# NET CALIBRATION -- the dispatch discipline's follow-through for the
# fourth width: "D0's numbers seed net.* defaults; the calibrate tool
# learns to probe them."
#
# StzNetCalibrate() measures THIS machine's wire floor with the same
# instrument class as the D0 spike (two real OS processes, real frames,
# the real Ring-value boundary) and MERGES the net.stzm.* keys into
# stz_calibration.txt -- the one calibration file. This guard proves:
# - the measurement lands within the bands the D0 kill criteria drew
# - the write is a MERGE: foreign namespaces survive verbatim, stale
#   net lines are replaced (never duplicated)
# - the file actually STEERS a fresh process (OVERRIDE > FILE >
#   DEFAULT proven through a real process boundary, not assumed)
# - and the guard cleans its own machine file away, because a
#   calibration file left in a test directory would silently gate
#   every later run from here.

load "../../stzBase.ring"
load "../_narrated.ring"

$cCalibFile = "stz_calibration.txt"

# never inherit a leftover machine file into the assertions
if fexists($cCalibFile)
	remove($cCalibFile)
ok

Scenario("calibration measures this machine and lands inside the D0 bands")
	Given("a pre-existing calibration file holding a FOREIGN key and a STALE net line")
	write($cCalibFile, "# synthetic pre-existing file" + char(10) +
		"cpu.test.sentinel = 777" + char(10) +
		"net.stzm.rtt_loopback_us = 9999" + char(10))
	When("StzNetCalibrate() probes the wire (two processes, real frames)")
	aNums = StzNetCalibrate()
	? "  [measure] rtt_loopback_us       = " + aNums[1]
	? "  [measure] msgs_per_sec_loopback = " + aNums[2]
	? "  [measure] ser_ns_per_kb         = " + aNums[3]
	Then("three positive numbers came back",
		aNums[1] > 0 and aNums[2] > 0 and aNums[3] > 0, TRUE)
	Then("the round trip is under the 5 ms kill line", aNums[1] < 5000, TRUE)
	Then("throughput clears 1000 msg/s", aNums[2] > 1000, TRUE)
EndScenario()

Scenario("the write is a MERGE: foreign keys survive, stale net lines die")
	Given("the file the calibrator wrote")
	cText = read($cCalibFile)
	Then("the FOREIGN cpu key survived verbatim",
		StzFindFirst("cpu.test.sentinel = 777", cText) > 0, TRUE)
	Then("the measured rtt is in the file",
		StzFindFirst("net.stzm.rtt_loopback_us = " + aNums[1], cText) > 0, TRUE)
	Then("the STALE net line was replaced, not kept",
		StzFindFirst("9999", cText), 0)
	Then("no key is duplicated",
		len(StzFindCS("net.stzm.rtt_loopback_us", cText, TRUE)), 1)
	Then("all three keys are present",
		StzFindFirst("net.stzm.msgs_per_sec_loopback = " + aNums[2], cText) > 0 and
		StzFindFirst("net.stzm.ser_ns_per_kb = " + aNums[3], cText) > 0, TRUE)
EndScenario()

Scenario("the file STEERS a fresh process: FILE beats DEFAULT for real")
	Given("the rtt line rewritten to a sentinel value no measurement produces")
	cText = read($cCalibFile)
	cText = StzReplace(cText, "net.stzm.rtt_loopback_us = " + aNums[1],
		"net.stzm.rtt_loopback_us = 4242")
	write($cCalibFile, cText)
	When("a FRESH Ring process reads its net defaults from this directory")
	cProbe = ".stznet_calib_probe_gen.ring"
	write(cProbe, 'load "' + NcgBaseRing() + '"' + char(10) +
		'aN = StzEngineStzmNetDefaults()' + char(10) +
		'? "rtt-seen=" + aN[1]' + char(10))
	oSpawn = new stzReactor()
	nJob = oSpawn.SubmitSpawn([ NcgRingExe(), cProbe ])
	cOut = oSpawn.AwaitSpawn(nJob, 30000)
	oSpawn.Destroy()
	Then("the child saw the FILE value, not the compiled default",
		StzFindFirst("rtt-seen=4242", cOut) > 0, TRUE)
	remove(cProbe)
EndScenario()

Scenario("cleanup: no machine file may linger in a test directory")
	Given("the calibration file this guard created")
	remove($cCalibFile)
	Then("it is gone", fexists($cCalibFile), FALSE)
	Then("and the generated echo script is gone too",
		fexists(".stznet_calib_echo_gen.ring"), FALSE)
EndScenario()

Summary()

#--- helpers ---------------------------------------------------------

func NcgRingExe()
	_aA_ = sysargv
	_nLen_ = len(_aA_)
	for _i_ = 1 to _nLen_
		_c_ = StzLower("" + _aA_[_i_])
		if StzFindFirst("ring.exe", _c_) > 0 or _c_ = "ring"
			return "" + _aA_[_i_]
		ok
	next
	return "ring"

func NcgBaseRing()
	_nSlash_ = 0
	_nBl_ = StzLen($cEngineDir)
	for _iB_ = 1 to _nBl_
		if $cEngineDir[_iB_] = "/"
			_nSlash_ = _iB_
		ok
	next
	return StzLeft($cEngineDir, _nSlash_ - 1) + "/base/stzBase.ring"
