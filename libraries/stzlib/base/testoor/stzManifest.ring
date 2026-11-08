# Testoor -- THE MANIFEST. Phase P3.5 of SOFTANZA_TESTOOR_ROADMAP.md.
#
# The native Testoor runner (engine/src/testoor_main.zig, the `testoor` program) has no Ring virtual
# machine, so it cannot read a tour's source. READING a tour is the FACE's work (TESTOOR_ZIG_CORE.md
# section 1), and this is the Ring face handing over what it read: a manifest, one JSON document
# naming each tour, the record the reader made of it, the argv that launches it, the folder to launch
# it from and the face's ending rules as data. The native runner walks, judges and logs; it is what a
# program that is not Ring (the `stz` command line, a Haro program, a CI step) calls as a child.
#
#   TestoorManifestJson(acFiles, aOptions)
#       acFiles    the tour files, as Walk() would take them
#       aOptions   any of  :by :root :topic :subject :seed :repeat :timeout_ms :skipped :topics_skipped
#                  :evidence_json  a gate's FLOOR OF EVIDENCE as JSON text, e.g.
#                  '{"posture":"llm","tier":"critical","floor":{"min_kept":3,"min_routes":1}}' (protocol 2 section 6):
#                  the run then exits 1 when the walk does not meet it, whatever its tours said
#                  :ladder  TRUE to write the EVIDENCE LADDER (protocol 3 section 2): each graph node's
#                  highest grade -- named, observed, exemplified -- and the tours that gave it
#                  (a hash-list; every key is optional)
#   TestoorNativeExe()
#       the native runner's path: the TESTOOR_EXE variable, else engine/zig-out/bin/testoor beside the
#       library; "" when there is none (build it: cd engine && zig build testoor-exe -j2)
#
# It uses the reader, the face table and the launch template the Ring runner uses, so a tour that the
# Ring runner would not run (no face, a face that cannot launch) is marked unreadable here too, and the
# native runner names it and does not run it.
#
# Locals are _underscored_; nothing here touches a top-level name (Rule A clean).

func _ManifestOpt(paOpt, pcKey, pxDefault)
	_n_ = len(paOpt)
	for _i_ = 1 to _n_
		if lower("" + paOpt[_i_][1]) = lower("" + pcKey)
			return paOpt[_i_][2]
		ok
	next
	return pxDefault

func _ManifestStrings(pacList)
	_c_ = "["
	_n_ = len(pacList)
	for _i_ = 1 to _n_
		if _i_ > 1  _c_ += ","  ok
		_c_ += _TourJsonStr("" + pacList[_i_])
	next
	return _c_ + "]"

# the floor a gate demands, written into the run when there is one
func _ManifestEvidence(pcJson)
	if pcJson = ""  return ""  ok
	return ',"evidence":' + pcJson

# the evidence ladder, written into the run only when asked, so a run that does not ask keeps protocol 2's bytes
func _ManifestLadder(pxOn)
	if isNumber(pxOn) and pxOn = 1  return ',"ladder":true'  ok
	return ""

func TestoorNativeExe()
	_c_ = sysget("TESTOOR_EXE")
	if _c_ != "" and fexists(_c_)  return _c_  ok
	_cDefault_ = currentdir() + "/../../../engine/zig-out/bin/testoor.exe"
	if fexists(_cDefault_)  return _cDefault_  ok
	return ""

func TestoorManifestJson(pacFiles, paOpt)
	_c_ = '{"run":{"by":' + _TourJsonStr("" + _ManifestOpt(paOpt, :by, "testoor")) +
	      ',"root":' + _TourJsonStr("" + _ManifestOpt(paOpt, :root, "")) +
	      ',"topic":' + _TourJsonStr("" + _ManifestOpt(paOpt, :topic, "")) +
	      ',"subject":' + _TourJsonStr("" + _ManifestOpt(paOpt, :subject, "")) +
	      ',"seed":' + _ManifestOpt(paOpt, :seed, -1) +
	      ',"repeat":' + _ManifestOpt(paOpt, :repeat, 1) +
	      ',"timeout_ms":' + _ManifestOpt(paOpt, :timeout_ms, 120000) + _ManifestEvidence(_ManifestOpt(paOpt, :evidence_json, "")) +
	      _ManifestLadder(_ManifestOpt(paOpt, :ladder, 0)) + "}" +
	      ',"skipped":' + _ManifestStrings(_ManifestOpt(paOpt, :skipped, [])) +
	      ',"topics_skipped":' + _ManifestStrings(_ManifestOpt(paOpt, :topics_skipped, [])) + ',"tours":['
	_nF_ = len(pacFiles)
	for _i_ = 1 to _nF_
		if _i_ > 1  _c_ += ","  ok
		_c_ += _ManifestTour("" + pacFiles[_i_])
	next
	return _c_ + "]}"

# ONE tour: read as the Ring runner reads it, launched as the Ring runner launches it
func _ManifestTour(pcPath)
	_aRec_ = _TourRead(pcPath)
	_aFace_ = TestoorFaceFor(pcPath)
	_bReadable_ = (_aRec_[:readable] = 1)
	# readable text but no face: named, not guessed, and not run; and a face that cannot launch
	if _bReadable_ and len(_aFace_) = 0  _bReadable_ = 0  ok
	if _bReadable_
		if len(_aFace_[:launch]) = 0  _bReadable_ = 0  ok
	ok
	_aFD_ = _TravSplitPath(pcPath)
	_cArgv_ = "[]"
	_cIgnore_ = ""
	_cEnd_ = ""
	if len(_aFace_) > 0
		_cIgnore_ = _aFace_[:ignore]
		_nE_ = len(_aFace_[:endings])
		for _k_ = 1 to _nE_
			if _k_ > 1  _cEnd_ += ","  ok
			_cEnd_ += "[" + _TourJsonStr(_aFace_[:endings][_k_][1]) + "," + _TourJsonStr(_aFace_[:endings][_k_][2]) + "]"
		next
		if _bReadable_
			# {seed} stays in the argv: the native runner puts the run's seed there
			_cArgv_ = _ManifestStrings(_TravLaunchArgv(_aFace_, _aFD_[2], "{seed}"))
		ok
	ok
	_nRead_ = 0
	if _bReadable_  _nRead_ = 1  ok
	return '{"file":' + _TourJsonStr(pcPath) + ',"cwd":' + _TourJsonStr(_TravHostPath(_aFD_[1])) +
	       ',"argv":' + _cArgv_ + ',"readable":' + _nRead_ + ',"record":' + _CoreRecordJson(_aRec_) +
	       ',"face":{"ignore":' + _TourJsonStr(_cIgnore_) + ',"endings":[' + _cEnd_ + "]}}"
