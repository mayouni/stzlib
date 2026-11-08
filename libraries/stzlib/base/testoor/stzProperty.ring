# Testoor -- PROPERTIES. Step V2 of the evidence ladder (TESTOOR_PROTOCOL_3.md section 4).
#
# A property is ONE claim checked over many inputs drawn from a declared domain, in ONE walk. The core
# (engine/src/testoor_domain.zig, testoor_property.zig) generates the inputs from the domain and a seed,
# and orders the candidates that shrink a failure; this file only calls the check, so a failure shrinks
# to the same answer here as in any other language.
#
#   TestoorProperty(cId, cDomain, cCheck, aOptions)
#       cId       the property's name, no spaces
#       cDomain   dimensions separated by ";":  "n int 0..100"   "rate dec 0..0.25 step 0.01"
#                 "algo one quick|merge|heap"   "s text 0..12 of mixed"   (alphabets: ascii latin greek
#                 hebrew arabic cjk emoji mixed, or the letters themselves: of "abc")
#                 "xs list 0..10 of int -5..5"   "ls list 0..4 of list 0..3 of int 0..9"  (a list of any kind;
#                 it reaches the check as a Ring list -- compare lists with IsStrictlyEqualTo when ORDER
#                 matters: IsEqualTo ignores it)
#       cCheck    the NAME of a function that takes one input -- a hash list, one key per dimension
#                 (an int is a number; a dec, a choice and a text are text) -- and answers TRUE or FALSE
#       aOptions  :tries   how many inputs (100); a finite domain no larger is tried WHOLE (exhaustive)
#                 :seed    the seed (the runner's when it passed one, else a drawn one)
#                 :nodes   the graph nodes the property is about (they rise on the evidence ladder)
#                 :print   TRUE (default) prints the [testoor property ...] line the judge reads
#   answers [ :held, :tried, :of, :exhaustive, :seed, :counterexample (JSON text, "" when it held),
#             :shrinks, :first (the generated input that failed first, before any shrink),
#             :path (each input the shrink took after it, JSON texts in order), :line ]
#
#   A self-describing tour prints the line and the line is its claim. A tour judged from its record
#   wraps it in one:  Then("the rate keeps the total", TestoorProperty(...)[:held], TRUE)
#
# The shrink stops after 1,000 evaluations of the check. Locals are _underscored_ (Rule A clean).

func TestoorProperty(pcId, pcDomain, pcCheck, paOpt)
	_nTries_ = _PropOpt(paOpt, :tries, 100)
	_xSeed_ = _PropOpt(paOpt, :seed, "")
	if not isNumber(_xSeed_)
		_cArg_ = _TestoorArgSeedText()
		if _cArg_ != ""
			_xSeed_ = 0 + _cArg_
		else
			_xSeed_ = TestoorDrawSeed()
		ok
	ok
	_aNodes_ = _PropOpt(paOpt, :nodes, [])
	_bPrint_ = _PropOpt(paOpt, :print, 1)

	_aGen_ = StzJsonToList(StzEngineTestoorProperty('{"op":"inputs","domain":' + _TourJsonStr(pcDomain) +
	         ',"seed":' + _xSeed_ + ',"tries":' + _nTries_ + '}'))
	_aIns_ = _aGen_[:inputs]
	_acTexts_ = _aGen_[:texts]
	_nIns_ = len(_aIns_)
	_bHeld_ = 1
	_nTried_ = _nIns_
	_cFail_ = ""
	_aFail_ = []
	for _i_ = 1 to _nIns_
		if not _PropCheck(pcCheck, _aIns_[_i_])
			_bHeld_ = 0
			_nTried_ = _i_
			_cFail_ = _acTexts_[_i_]
			_aFail_ = _aIns_[_i_]
			exit
		ok
	next

	# the shrink: the core orders the candidates, simplest first; the first that still fails is taken
	_cFirst_ = _cFail_
	_nShrinks_ = 0
	_acPath_ = []
	if _bHeld_ = 0
		_nEvals_ = 0
		_bMore_ = 1
		while _bMore_ = 1 and _nEvals_ < 1000
			_aC_ = StzJsonToList(StzEngineTestoorProperty('{"op":"shrink","domain":' + _TourJsonStr(pcDomain) +
			       ',"input":' + _cFail_ + '}'))
			_aCands_ = _aC_[:candidates]
			_acCands_ = _aC_[:texts]
			_bMore_ = 0
			_nC_ = len(_aCands_)
			for _k_ = 1 to _nC_
				_nEvals_++
				if not _PropCheck(pcCheck, _aCands_[_k_])
					_cFail_ = _acCands_[_k_]
					_nShrinks_++
					_acPath_ + _cFail_
					_bMore_ = 1
					exit
				ok
				if _nEvals_ >= 1000  exit  ok
			next
		end
	ok

	_cRec_ = '{"id":' + _TourJsonStr(pcId)
	if len(_aNodes_) > 0
		_cRec_ += ',"nodes":['
		for _i_ = 1 to len(_aNodes_)
			if _i_ > 1  _cRec_ += ","  ok
			_cRec_ += _TourJsonStr("" + _aNodes_[_i_])
		next
		_cRec_ += "]"
	ok
	_cRec_ += ',"domain":' + _TourJsonStr(pcDomain) + ',"seed":' + _xSeed_ + ',"tried":' + _nTried_
	if isNumber(_aGen_[:of])  _cRec_ += ',"of":' + _aGen_[:of]  ok
	_bExh_ = 0
	if _aGen_[:exhaustive] = 1 and _bHeld_ = 1  _bExh_ = 1  ok
	_cRec_ += ',"exhaustive":' + _PropBool(_bExh_) + ',"held":' + _PropBool(_bHeld_)
	if _bHeld_ = 0
		_cRec_ += ',"counterexample":' + _cFail_ + ',"shrinks":' + _nShrinks_
	ok
	_cRec_ += "}"
	_cLine_ = StzEngineTestoorProperty('{"op":"line","record":' + _cRec_ + '}')
	if _bPrint_ = 1  ? _cLine_  ok

	_xOf_ = ""
	if isNumber(_aGen_[:of])  _xOf_ = _aGen_[:of]  ok
	return [ :held = _bHeld_, :tried = _nTried_, :of = _xOf_, :exhaustive = _bExh_, :seed = _xSeed_,
	         :counterexample = _cFail_, :shrinks = _nShrinks_, :first = _cFirst_, :path = _acPath_, :line = _cLine_ ]

# the check, called by its name: TRUE only when it answers exactly 1
func _PropCheck(pcCheck, paIn)
	_x_ = call pcCheck(paIn)
	if isNumber(_x_) and _x_ = 1  return 1  ok
	return 0

func _PropBool(pn)
	if pn = 1  return "true"  ok
	return "false"

func _PropOpt(paOpt, pcKey, pxDefault)
	_n_ = len(paOpt)
	for _i_ = 1 to _n_
		if lower("" + paOpt[_i_][1]) = lower("" + pcKey)
			return paOpt[_i_][2]
		ok
	next
	return pxDefault
