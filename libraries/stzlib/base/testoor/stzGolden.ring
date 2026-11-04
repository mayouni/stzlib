# Testoor -- GOLDEN LOGBOOKS. Phase P2b of SOFTANZA_TESTOOR_ROADMAP.md.
#
# The Zig core (roadmap P3) is built against these files, and they are written to
# be read by any language: every input is JSON or plain text, every expected
# output is JSON or plain text, and nothing here depends on a process, a clock or
# a file system. The Ring code below is the REFERENCE: it reads the committed
# inputs, runs the reference judge, and produces the expected files. The guard
# regenerates them and compares byte for byte, so the goldens cannot drift from
# the reference, and the Zig core is held to the same bytes.
#
# TWO LEVELS.
#   golden/judge/<case>/     ONE tour. Inputs: record.json (what a face read),
#                            output.txt (what the child printed, each line preceded
#                            by its arrival in milliseconds and a TAB), meta.json
#                            (exit, hung, stderr, wall_ms, seed, the face's ending
#                            rules as DATA). Expected: expected.json (the tour as
#                            the logbook writes it), expected.txt (the prose line).
#   golden/logbook/<case>/   ONE RUN. Input: run.json (which judge cases make the
#                            run and its scope). Expected: expected.json (the whole
#                            logbook), expected.txt (the summary), expected.exit
#                            (the runner's exit code).
#
# THE CONVENTIONS A PORT MUST KNOW, because they are where two languages part:
#   - arrival times in the committed outputs are multiples of 125 ms, so that the
#     stop times are exact in binary floating point and agree to the millisecond;
#     the port computes in integer milliseconds and floors the exact difference
#   - a number in the prose is the shortest decimal (1.25, 0.5, 2)
#   - files are compared with carriage returns removed, and the directory carries
#     a .gitattributes marking its files -text so a checkout cannot change a byte
#
# Locals are _underscored_; nothing here touches a top-level name.

func TestoorGoldenRead(pcPath)
	return substr(read("" + pcPath), char(13), "")

# the names of the case folders under pcDir, in order
func _GoldenCases(pcDir)
	_acOut_ = []
	_aE_ = []
	try
		_aE_ = dir("" + pcDir)
	catch
		return []
	done
	_n_ = len(_aE_)
	for _i_ = 1 to _n_
		if _aE_[_i_][2] and left(_aE_[_i_][1], 1) != "." and left(_aE_[_i_][1], 1) != "_"
			_acOut_ + _aE_[_i_][1]
		ok
	next
	return sort(_acOut_)

# the face profile in meta.json, as the judge wants it
func _GoldenFace(paJ)
	_aE_ = []
	_n_ = len(paJ[:endings])
	for _i_ = 1 to _n_
		_aE_ + [ paJ[:endings][_i_][1], paJ[:endings][_i_][2] ]
	next
	return [ :name = paJ[:name], :ext = "", :reader = "", :program = "", :launch = [],
	         :ignore = paJ[:ignore], :endings = _aE_ ]

# the tour record in record.json, with every field the judge may read
func _GoldenRecord(paJ)
	_aStops_ = []
	_nS_ = len(paJ[:stops])
	for _s_ = 1 to _nS_
		_aCl_ = []
		_nC_ = len(paJ[:stops][_s_][:claims])
		for _c_ = 1 to _nC_
			_k_ = paJ[:stops][_s_][:claims][_c_]
			_aCl_ + [ :line = _k_[:line], :kind = _k_[:kind], :claim = _k_[:claim], :want = _k_[:want] ]
		next
		_aStops_ + [ :title = paJ[:stops][_s_][:title], :line = paJ[:stops][_s_][:line], :claims = _aCl_ ]
	next
	_aRoutes_ = []
	_nR_ = len(paJ[:routes])
	for _r_ = 1 to _nR_
		_aRoutes_ + [ :item = paJ[:routes][_r_][:item], :stop = paJ[:routes][_r_][:stop], :line = paJ[:routes][_r_][:line] ]
	next
	return [ :file = paJ[:file], :readable = paJ[:readable], :why = paJ[:why], :dialect = paJ[:dialect],
	         :helpers = [], :lines = paJ[:lines], :ending = "plain", :asserts = paJ[:asserts],
	         :promises = 0, :markers = 0, :stops = _aStops_, :routes = _aRoutes_ ]

# output.txt: "<ms><TAB><text>" per line -> [ [ text, seconds ] ... ]
func _GoldenLines(pcText)
	_acL_ = str2list(pcText)
	_aOut_ = []
	_n_ = len(_acL_)
	for _i_ = 1 to _n_
		_t_ = _acL_[_i_]
		_nTab_ = substr(_t_, char(9))
		if _nTab_ = 0  loop  ok
		_ms_ = 0 + substr(_t_, 1, _nTab_ - 1)
		_aOut_ + [ substr(_t_, _nTab_ + 1, len(_t_) - _nTab_), _ms_ / 1000 ]
	next
	return _aOut_

# ONE tour, judged from its committed inputs: the record, with :run filled in
func TestoorGoldenVerdict(pcDir)
	_aRecJ_ = StzJsonToList(TestoorGoldenRead(pcDir + "/record.json"))
	_aMeta_ = StzJsonToList(TestoorGoldenRead(pcDir + "/meta.json"))
	_aRec_ = _GoldenRecord(_aRecJ_)
	if _aMeta_[:unreadable] = 1
		_aRec_[:flaky] = 0
		_aRec_[:flaky_why] = ""
		_aRec_[:weather] = []
		_aRec_[:run] = _TravJudge(_aRec_, [], "unreadable", -1, 0)
		_aRec_[:run][:end] = "unreadable"
		return _aRec_
	ok
	_aFace_ = _GoldenFace(_aMeta_[:face])
	_aLines_ = _GoldenLines(TestoorGoldenRead(pcDir + "/output.txt"))
	return TestoorVerdict(_aRec_, _aLines_, _aMeta_[:stderr], _aMeta_[:exit], _aMeta_[:hung],
	                      _aFace_, _aMeta_[:wall_ms], _aMeta_[:seed])

# ONE run, built from the judge cases its run.json names; [ json, prose, exit ]
func TestoorGoldenLogbook(pcDir, pcJudgeRoot)
	_aJ_ = StzJsonToList(TestoorGoldenRead(pcDir + "/run.json"))
	_oTr_ = TravellerQ().Silent().By(_aJ_[:by]).Timeout(_aJ_[:timeout_ms]).Seed(_aJ_[:seed]).Repeat(_aJ_[:repeat])
	if _aJ_[:subject] != ""  _oTr_.Subject(_aJ_[:subject])  ok
	if _aJ_[:refuse_root] != ""
		# the runner is pointed at a root that is not there: nothing is walked
		_oTr_.WalkTopic(_aJ_[:refuse_root], _aJ_[:topic])
	else
		_oTr_.Scope(_aJ_[:root], _aJ_[:topic])
		_acFlaky_ = []
		_nF_ = len(_aJ_[:flaky])
		for _i_ = 1 to _nF_
			_acFlaky_ + _aJ_[:flaky][_i_]
		next
		_nC_ = len(_aJ_[:cases])
		for _i_ = 1 to _nC_
			_aRec_ = TestoorGoldenVerdict(pcJudgeRoot + "/" + _aJ_[:cases][_i_])
			if ring_find(_acFlaky_, _aJ_[:cases][_i_]) > 0
				_aRec_[:flaky] = 1
				_aRec_[:flaky_why] = "walk 1 read " + _aRec_[:run][:state] + " and walk 2 read something else, both with seed " + _aJ_[:seed]
			ok
			_oTr_.AdoptRecord(_aRec_)
		next
		_acSk_ = []
		_n_ = len(_aJ_[:skipped])
		for _i_ = 1 to _n_
			_acSk_ + _aJ_[:skipped][_i_]
		next
		_oTr_.SkippedBy(_acSk_)
		_acTs_ = []
		_n_ = len(_aJ_[:topics_skipped])
		for _i_ = 1 to _n_
			_acTs_ + _aJ_[:topics_skipped][_i_]
		next
		_oTr_.TopicsSkippedBy(_acTs_)
	ok
	return [ _oTr_.Json(), _oTr_.Prose(), _oTr_.ExitCode() ]

# every expected file the committed inputs produce: [ [ relative path, content ] ... ]
func TestoorGoldenAll(pcRoot)
	_aOut_ = []
	_acJ_ = _GoldenCases(pcRoot + "/judge")
	_n_ = len(_acJ_)
	for _i_ = 1 to _n_
		_aRec_ = TestoorGoldenVerdict(pcRoot + "/judge/" + _acJ_[_i_])
		_aOut_ + [ "judge/" + _acJ_[_i_] + "/expected.json", _TravRunJson(_aRec_) + char(10) ]
		_aOut_ + [ "judge/" + _acJ_[_i_] + "/expected.txt", _TravRunProse(_aRec_) + char(10) ]
	next
	_acL_ = _GoldenCases(pcRoot + "/logbook")
	_n_ = len(_acL_)
	for _i_ = 1 to _n_
		_aLb_ = TestoorGoldenLogbook(pcRoot + "/logbook/" + _acL_[_i_], pcRoot + "/judge")
		_aOut_ + [ "logbook/" + _acL_[_i_] + "/expected.json", _aLb_[1] + char(10) ]
		_aOut_ + [ "logbook/" + _acL_[_i_] + "/expected.txt", _aLb_[2] + char(10) ]
		_aOut_ + [ "logbook/" + _acL_[_i_] + "/expected.exit", "" + _aLb_[3] + char(10) ]
	next
	return _aOut_

# (re)write every expected file from the inputs: the human reviews the diff in git
func TestoorGoldenUpdate(pcRoot)
	_aAll_ = TestoorGoldenAll(pcRoot)
	_n_ = len(_aAll_)
	for _i_ = 1 to _n_
		write(pcRoot + "/" + _aAll_[_i_][1], _aAll_[_i_][2])
	next
	return _n_

# the expected files whose committed bytes differ from what the reference produces
# now, or that are missing: [] when the goldens are true
func TestoorGoldenDiff(pcRoot)
	_acBad_ = []
	_aAll_ = TestoorGoldenAll(pcRoot)
	_n_ = len(_aAll_)
	for _i_ = 1 to _n_
		_cPath_ = pcRoot + "/" + _aAll_[_i_][1]
		if NOT fexists(_cPath_)
			_acBad_ + (_aAll_[_i_][1] + " (missing)")
		but TestoorGoldenRead(_cPath_) != _aAll_[_i_][2]
			_acBad_ + _aAll_[_i_][1]
		ok
	next
	return _acBad_
