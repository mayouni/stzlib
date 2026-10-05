# DOCREFORM step 5 -- the doc gate: what is written stays written, and nothing new lands unwritten.
#
#   ? StzDocGateFindings("libraries/stzlib/base", "libraries/stzlib/base/doc/doc_baseline.txt")
#   ? StzDocGateBaselineUpdate("libraries/stzlib/base", "libraries/stzlib/base/doc/doc_baseline.txt")
#
# The extractor (stzDocRecord / stzDocExport) scores every ROOT method with five checks; a root PASSES when
# checks 1-4 hold (brief in the house voice, brief not restating the name, every parameter described, returns
# stated). The library is migrated in waves, so most roots still fail: that debt is the BASELINE, a file with
# one `class.method` (lowercase) per line.
#
# A ratchet, in the same unified finding shape as the other house rules
# [ :rule, :subject, :where, :severity, :message ] -> stzRuleReport.Ingest():
#
#   doc-floor          ERROR    a root that is NOT in the baseline fails check 1 or 2: a new or renamed method
#                               must at least say, in a third-person verb, what it does, and not repeat its name
#   doc-complete       WARNING  a root NOT in the baseline fails check 3 or 4: a parameter without a role, or no
#                               'returns' (cheap to add while the method is fresh)
#   doc-baseline-stale WARNING  a root IN the baseline now passes: take it out (StzDocGateBaselineUpdate) so the
#                               debt can only shrink
#
# StzDocGateBaselineUpdate never ADDS a key: it keeps the baseline roots that still fail, so a regression of a
# written method shows as a doc-floor error (it is no longer in the baseline) and cannot be hidden by running
# the update. The first call, with no baseline file, seeds it with every failing root.
#
# The cost is one export of the whole library, about a minute in one process: a pre-commit / CI gate, not an
# edit-time check. For one class use StzReferenceExportOnly(base, out, "x", "x", [ "stzX" ]) and StzDocFailures().

# the failing roots of the library as [ key, c1, c2, c3, c4 ]
func StzDocGateFailing(pcBase)
	_cTmp_ = "" + pcBase
	if StzRight(_cTmp_, 1) != "/" and StzRight(_cTmp_, 1) != "\\"
		_cTmp_ += "/"
	ok
	_cTmp_ += ".doc_gate_export.tmp.json"
	StzReferenceExportOnly(pcBase, _cTmp_, "gate", "gate", [])
	remove(_cTmp_)
	return StzDocFailures()

# the baseline keys, sorted, as a list of strings ([] when the file is absent)
func StzDocGateBaseline(pcBaselinePath)
	_aOut_ = []
	if NOT fexists(pcBaselinePath)
		return _aOut_
	ok
	_aLines_ = str2list(read(pcBaselinePath))
	_n_ = len(_aLines_)
	for _i_ = 1 to _n_
		_c_ = trim(_aLines_[_i_])
		if _c_ != "" and left(_c_, 1) != "#"
			_aOut_ + lower(_c_)
		ok
	next
	return sort(_aOut_)

# binary search in a SORTED list of strings: the position, 0 when absent
func _StzDocGateFind(paSorted, pcKey)
	_lo_ = 1
	_hi_ = len(paSorted)
	while _lo_ <= _hi_
		_mid_ = floor((_lo_ + _hi_) / 2)
		_nCmp_ = strcmp(paSorted[_mid_], pcKey)
		if _nCmp_ = 0
			return _mid_
		ok
		if _nCmp_ < 0
			_lo_ = _mid_ + 1
		else
			_hi_ = _mid_ - 1
		ok
	end
	return 0

# THE gate: findings (unified shape) over a failing list and a baseline. Pure: no export, so it is testable
# on a fixture. paFailing = [ [ key, c1, c2, c3, c4 ], ... ], paBaseline = sorted keys.
func StzDocGateJudge(paFailing, paBaseline)
	_aOut_ = []
	_nF_ = len(paFailing)
	_aFailKeys_ = []
	for _i_ = 1 to _nF_
		_aFailKeys_ + paFailing[_i_][1]
	next
	_aFailKeys_ = sort(_aFailKeys_)
	for _i_ = 1 to _nF_
		_aF_ = paFailing[_i_]
		_cKey_ = _aF_[1]
		if _StzDocGateFind(paBaseline, _cKey_) > 0
			loop
		ok
		if _aF_[2] = 0 or _aF_[3] = 0
			_cWhy_ = ""
			if _aF_[2] = 0
				_cWhy_ = "its brief is missing or does not begin with a third-person verb, Returns or TRUE if"
			else
				_cWhy_ = "its brief only restates its name"
			ok
			_aOut_ + [ :rule = "doc-floor", :subject = _cKey_, :where = _cKey_, :severity = :error,
			           :message = "a method that is not in the doc baseline must be documented: " + _cWhy_ ]
		but _aF_[4] = 0 or _aF_[5] = 0
			_cWhy2_ = ""
			if _aF_[4] = 0
				_cWhy2_ = "a parameter has no role (write it, or name it in doc/params.txt)"
			else
				_cWhy2_ = "it does not say what it returns"
			ok
			_aOut_ + [ :rule = "doc-complete", :subject = _cKey_, :where = _cKey_, :severity = :warning,
			           :message = _cWhy2_ ]
		ok
	next
	_nB_ = len(paBaseline)
	for _i_ = 1 to _nB_
		if _StzDocGateFind(_aFailKeys_, paBaseline[_i_]) = 0
			_aOut_ + [ :rule = "doc-baseline-stale", :subject = paBaseline[_i_], :where = paBaseline[_i_],
			           :severity = :warning,
			           :message = "this method now passes (or is gone): remove it from the baseline with StzDocGateBaselineUpdate" ]
		ok
	next
	return _aOut_

func StzDocGateFindings(pcBase, pcBaselinePath)
	return StzDocGateJudge( StzDocGateFailing(pcBase), StzDocGateBaseline(pcBaselinePath) )

# Writes the baseline: the keys of the old baseline that still fail (so it only shrinks), or, with no baseline
# yet or pbSeed = 1, every failing root. Returns [ :kept = n, :removed = n, :written = n ].
func StzDocGateBaselineUpdate(pcBase, pcBaselinePath, pbSeed)
	_aFailing_ = StzDocGateFailing(pcBase)
	return StzDocGateBaselineWrite(_aFailing_, pcBaselinePath, pbSeed)

func StzDocGateBaselineWrite(paFailing, pcBaselinePath, pbSeed)
	_aKeys_ = []
	_nF_ = len(paFailing)
	for _i_ = 1 to _nF_
		_aKeys_ + paFailing[_i_][1]
	next
	_aKeys_ = sort(_aKeys_)
	_aOld_ = StzDocGateBaseline(pcBaselinePath)
	_aNew_ = []
	if len(_aOld_) = 0 or pbSeed = 1
		_aNew_ = _aKeys_
	else
		_nO_ = len(_aOld_)
		for _i_ = 1 to _nO_
			if _StzDocGateFind(_aKeys_, _aOld_[_i_]) > 0
				_aNew_ + _aOld_[_i_]
			ok
		next
	ok
	_cOut_ = "# DOCREFORM doc baseline: the roots that do not yet pass checks 1-4. One class.method per line, sorted." + char(10) +
	         "# It only shrinks: `StzDocGateBaselineUpdate` keeps the keys that still fail and never adds one." + char(10)
	_nN_ = len(_aNew_)
	_cBody_ = ""
	for _i_ = 1 to _nN_
		_cBody_ += _aNew_[_i_] + char(10)
	next
	_fp_ = fopen(pcBaselinePath, "wb")
	fwrite(_fp_, _cOut_ + _cBody_)
	fclose(_fp_)
	return [ :kept = _nN_, :removed = len(_aOld_) - _nN_, :written = _nN_ ]
