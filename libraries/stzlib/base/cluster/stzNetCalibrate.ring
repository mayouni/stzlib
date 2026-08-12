# base/cluster/stzNetCalibrate.ring
# -----------------------------------------------------------------------------
# CALIBRATE THIS MACHINE'S WIRE (distribution plan, dispatch discipline):
# measure the message plane's floor on THIS machine and write the
# net.stzm.* keys into stz_calibration.txt -- the ONE calibration file
# (OVERRIDE > FILE > DEFAULT, calib.zig).
#
#   aNums = StzNetCalibrate()   # [ rtt_us, msgs_per_sec, ser_ns_per_kb ]
#
# WHY THIS CALIBRATOR IS RING-DRIVEN while cpu.* uses the Zig tool
# (src/calibrate_tool.zig): the honest instrument for the wire needs
# what the Zig tool cannot be -- TWO real OS processes (the round trip
# includes real cross-process scheduling), and the Ring VALUE boundary
# (ser_ns_per_kb is dominated by rebuilding the Ring value at the
# bridge, which needs a Ring VM). Same instrument class as the D0 spike
# guard, which seeded the compiled defaults.
#
# The write is a MERGE, not an overwrite: every line of an existing
# stz_calibration.txt survives except the net.stzm.* keys being
# replaced -- the cpu.* and gpu.* namespaces belong to their own
# calibrators. (The file lands in the CURRENT WORKING DIRECTORY, which
# is where every engine DLL lazily loads it from.)
#
# Like every calibrator: RUN ON A QUIET MACHINE. Contention inflates
# the measured floor, which makes future admissions conservative --
# fails safe, but costs real speedups. Delete the file (or its net
# lines) to return to the compiled spike defaults.
# -----------------------------------------------------------------------------

$_nc_oRct = ""
$_nc_nChan = 0
$_nc_nConn = 0

# Measure the wire floor against a spawned echo peer and merge the
# three net.stzm.* keys into stz_calibration.txt. Returns
# [ rtt_us, msgs_per_sec, ser_ns_per_kb ] (all 0 on failure to link).
func StzNetCalibrate()
	_nc_nPort_ = 47400 + (StzEngineTimeNowMs() % 200)
	_nc_cEcho_ = _NcWriteEchoScript()
	_nc_oSpawn_ = new stzReactor()
	_nc_nJob_ = _nc_oSpawn_.SubmitSpawn([ _NcRingExe(), _nc_cEcho_, "" + _nc_nPort_ ])
	$_nc_oRct = new stzReactor()
	if NOT _NcLink(_nc_nPort_, 15000)
		_nc_oSpawn_.KillSpawn(_nc_nJob_, 9)
		$_nc_oRct.Destroy()
		_nc_oSpawn_.Destroy()
		remove(_nc_cEcho_)
		return [ 0, 0, 0 ]
	ok

	# -- round trip: the engine-await path (what a mailbox pays) --------
	_nc_cSmall_ = StzEngineStzmPack([ "set", "user:1234", "active", 1 ], 0, 1, 0)
	for _nc_i_ = 1 to 20
		_NcTrip(_nc_cSmall_, 2000)
	next
	_nc_aRtt_ = []
	for _nc_i_ = 1 to 200
		_nc_n0_ = StzEngineWatchTimestampNs()
		_NcTripAwait(_nc_cSmall_, 2000)
		_nc_aRtt_ + ((StzEngineWatchTimestampNs() - _nc_n0_) / 1000.0)
	next
	_nc_nRttUs_ = floor(_NcMedian(_nc_aRtt_))

	# -- sustained throughput: 64 frames in flight ----------------------
	_nc_nTotal_ = 3000
	_nc_nSent_ = 0
	_nc_nGot_ = 0
	_nc_n0_ = StzEngineWatchTimestampNs()
	while _nc_nSent_ < 64 and _nc_nSent_ < _nc_nTotal_
		$_nc_oRct.ServerWrite($_nc_nChan, $_nc_nConn, _nc_cSmall_, 0)
		_nc_nSent_++
	end
	_nc_nDl_ = StzEngineWatchTimestampMs() + 30000
	while _nc_nGot_ < _nc_nTotal_ and StzEngineWatchTimestampMs() < _nc_nDl_
		_nc_aEv_ = $_nc_oRct.ServerPoll($_nc_nChan)
		if len(_nc_aEv_) = 3 and _nc_aEv_[1] = :data
			_nc_nGot_++
			if _nc_nSent_ < _nc_nTotal_
				$_nc_oRct.ServerWrite($_nc_nChan, $_nc_nConn, _nc_cSmall_, 0)
				_nc_nSent_++
			ok
		ok
	end
	_nc_nSecs_ = (StzEngineWatchTimestampNs() - _nc_n0_) / 1000000000.0
	_nc_nMsgs_ = floor(_nc_nGot_ / _nc_nSecs_)

	# -- serialization: pack+unpack of the 384-f64 embedding shape ------
	_nc_aVec_ = []
	for _nc_i_ = 1 to 384
		_nc_aVec_ + ((_nc_i_ * 7 + 1) / 3.0)
	next
	_nc_cFrame_ = StzEngineStzmPack(_nc_aVec_, 0, 1, 0)
	_nc_nReps_ = 300
	_nc_n0_ = StzEngineWatchTimestampNs()
	for _nc_i_ = 1 to _nc_nReps_
		StzEngineStzmPack(_nc_aVec_, 0, 1, 0)
	next
	_nc_nPackNs_ = (StzEngineWatchTimestampNs() - _nc_n0_) / _nc_nReps_
	_nc_n0_ = StzEngineWatchTimestampNs()
	for _nc_i_ = 1 to _nc_nReps_
		StzEngineStzmUnpack(_nc_cFrame_)
	next
	_nc_nUnpackNs_ = (StzEngineWatchTimestampNs() - _nc_n0_) / _nc_nReps_
	_nc_nKb_ = (len(_nc_cFrame_) - 50) / 1024.0
	_nc_nSerNsKb_ = floor((_nc_nPackNs_ + _nc_nUnpackNs_) / _nc_nKb_)

	# -- teardown: hang up (the peer exits on the close) ----------------
	$_nc_oRct.ServerStop($_nc_nChan)
	_nc_oSpawn_.AwaitSpawn(_nc_nJob_, 8000)
	$_nc_oRct.Destroy()
	_nc_oSpawn_.Destroy()
	remove(_nc_cEcho_)

	_NcMergeFile(_nc_nRttUs_, _nc_nMsgs_, _nc_nSerNsKb_)
	return [ _nc_nRttUs_, _nc_nMsgs_, _nc_nSerNsKb_ ]

#-- internals (every local prefixed: helpers share the caller's frame) --

# Merge the three net.stzm.* keys into stz_calibration.txt in the CWD,
# preserving every other line (cpu.*, gpu.*, comments) verbatim.
func _NcMergeFile(nRttUs, nMsgs, nSerNsKb)
	_nc_cFile_ = "stz_calibration.txt"
	_nc_cNl_ = char(10)
	_nc_cKept_ = ""
	if fexists(_nc_cFile_)
		_nc_aLines_ = StzSplit(read(_nc_cFile_), _nc_cNl_)
		_nc_nL_ = len(_nc_aLines_)
		for _nc_i_ = 1 to _nc_nL_
			_nc_cLine_ = ring_trim(_nc_aLines_[_nc_i_])
			if StzFindFirst("net.stzm.", _nc_cLine_) = 1
				loop
			ok
			if len(_nc_cLine_) = 0 and _nc_i_ = _nc_nL_
				loop
			ok
			_nc_cKept_ += _nc_aLines_[_nc_i_] + _nc_cNl_
		next
	else
		_nc_cKept_ = "# stz_calibration.txt -- machine-measured engine thresholds." + _nc_cNl_ +
			"# Delete this file to return to the compiled spike defaults." + _nc_cNl_
	ok
	_nc_cKept_ += "# net.stzm.* written by StzNetCalibrate() (wire floor, this machine)" + _nc_cNl_ +
		"net.stzm.rtt_loopback_us = " + nRttUs + _nc_cNl_ +
		"net.stzm.msgs_per_sec_loopback = " + nMsgs + _nc_cNl_ +
		"net.stzm.ser_ns_per_kb = " + nSerNsKb + _nc_cNl_
	write(_nc_cFile_, _nc_cKept_)

func _NcWriteEchoScript()
	_nc_cF_ = ".stznet_calib_echo_gen.ring"
	_nc_cNl_ = char(10)
	_nc_cCode_ = 'load "' + _NcBaseRing() + '"' + _nc_cNl_ +
		'nPort = 0 + sysargv[len(sysargv)]' + _nc_cNl_ +
		'oRct = new stzReactor()' + _nc_cNl_ +
		'nSrv = oRct.ListenStzm("127.0.0.1", nPort)' + _nc_cNl_ +
		'nDeadline = StzEngineWatchTimestampMs() + 60000' + _nc_cNl_ +
		'bServed = FALSE' + _nc_cNl_ +
		'while StzEngineWatchTimestampMs() < nDeadline' + _nc_cNl_ +
		'	aEv = oRct.ServerAwait(nSrv, 250)' + _nc_cNl_ +
		'	if len(aEv) = 3' + _nc_cNl_ +
		'		if aEv[1] = :data' + _nc_cNl_ +
		'			oRct.ServerWrite(nSrv, aEv[2], aEv[3], FALSE)' + _nc_cNl_ +
		'			bServed = TRUE' + _nc_cNl_ +
		'		but aEv[1] = :closed' + _nc_cNl_ +
		'			if bServed' + _nc_cNl_ +
		'				exit' + _nc_cNl_ +
		'			ok' + _nc_cNl_ +
		'		ok' + _nc_cNl_ +
		'	ok' + _nc_cNl_ +
		'end' + _nc_cNl_ +
		'oRct.ServerStop(nSrv)' + _nc_cNl_ +
		'oRct.Destroy()' + _nc_cNl_
	write(_nc_cF_, _nc_cCode_)
	return _nc_cF_

func _NcLink(nPort, nTimeoutMs)
	_nc_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nc_nDl_
		$_nc_nChan = $_nc_oRct.ConnectStzm("127.0.0.1", nPort)
		$_nc_nConn = $_nc_oRct.WaitLinkUp($_nc_nChan, 1000)
		if $_nc_nConn > 0
			return 1
		ok
		$_nc_oRct.ServerStop($_nc_nChan)
		_nc_nT_ = $_nc_oRct.SubmitTimer(200)
		$_nc_oRct.AwaitTimer(_nc_nT_, 500)
	end
	return 0

func _NcTrip(cFrame, nTimeoutMs)
	$_nc_oRct.ServerWrite($_nc_nChan, $_nc_nConn, cFrame, 0)
	_nc_nDlT_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nc_nDlT_
		_nc_aEvT_ = $_nc_oRct.ServerPoll($_nc_nChan)
		if len(_nc_aEvT_) = 3 and _nc_aEvT_[1] = :data
			return _nc_aEvT_[3]
		ok
	end
	return ""

func _NcTripAwait(cFrame, nTimeoutMs)
	$_nc_oRct.ServerWrite($_nc_nChan, $_nc_nConn, cFrame, 0)
	_nc_aEvA_ = $_nc_oRct.ServerAwait($_nc_nChan, nTimeoutMs)
	if len(_nc_aEvA_) = 3 and _nc_aEvA_[1] = :data
		return _nc_aEvA_[3]
	ok
	return ""

func _NcMedian(aNums)
	_nc_aS_ = sort(aNums)
	return _nc_aS_[ceil(len(_nc_aS_) / 2)]

func _NcRingExe()
	_nc_aA_ = sysargv
	_nc_nLen_ = len(_nc_aA_)
	for _nc_iR_ = 1 to _nc_nLen_
		_nc_cR_ = StzLower("" + _nc_aA_[_nc_iR_])
		if StzFindFirst("ring.exe", _nc_cR_) > 0 or _nc_cR_ = "ring"
			return "" + _nc_aA_[_nc_iR_]
		ok
	next
	return "ring"

func _NcBaseRing()
	_nc_nSlash_ = 0
	_nc_nBl_ = StzLen($cEngineDir)
	for _nc_iB_ = 1 to _nc_nBl_
		if $cEngineDir[_nc_iB_] = "/"
			_nc_nSlash_ = _nc_iB_
		ok
	next
	return StzLeft($cEngineDir, _nc_nSlash_ - 1) + "/base/stzBase.ring"
