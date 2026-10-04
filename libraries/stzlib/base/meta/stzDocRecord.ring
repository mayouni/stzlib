#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZDOCRECORD                   #
#   An accelerative library for Ring applications, and more!    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzDocRecord -- the library's REFERENCE      #
#                  RECORD. It reads the doc-block above every    #
#                  `def` and every `class` (DOCREFORM, see       #
#                  base/doc/design/DOCREFORM_PROPOSAL.md), derives #
#                  what the code and the grammar of names can     #
#                  say, scores it, and exports the whole library  #
#                  as ONE versioned, deterministic JSON file.     #
#                  No model: a method's text is what its author   #
#                  wrote, or what the code derives, and the       #
#                  record says WHICH, field by field.             #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)        #
#                                                              #
#--------------------------------------------------------------#

# THE BLOCK -- a comment run immediately above `def` (or `class`):
#
#     # Returns the positions of every occurrence of pcSubStr, as a list.   <- BRIEF
#     #                                                                      <- bare # = end of brief
#     # Optional detail paragraph.
#     #
#     #   pcSubStr   the text to look for        <- a field: '#', 2+ spaces, KEY, 2+ spaces, text
#     #   returns    a list of numbers; [ ] when pcSubStr is absent
#     #   note       case-sensitive; FindCS takes the flag
#     #   see        FindFirst, FindNth, Contains
#     #   example    ? Q("banana").Find("an")
#     #              #--> [ 2, 4 ]
#     def Find(pcSubStr)
#
# KEY is a parameter name of that very def, or one of: returns note warning
# see example since status detour forms (a class block also takes receiver).
# A line indented to the value column or deeper continues the field above.
# Nothing else is syntax: an old one-line comment is a valid brief.

# The export's working state. Ring only lets a function assign a `$` global
# that already exists at file level, so they are born here.
$aStzDocCls = []         # [ name, file, parent, firstLine, lastLine ] per class
$aStzDocClsLow = []      # the lowercase class names
$aStzDocOwnLow = []      # per class: the lowercase names of its own defs
$aStzDocExt = []         # the extension table
$aStzDocGlossName = []   # the parameter glossary: names ...
$aStzDocGlossRole = []   # ... and roles
$aStzDocRecCache = []    # [ classLower, records ] -- StzDocRecordOf

# --- the closed list of keys ---------------------------------------------
func _StzDocKeys()
	return [ "returns", "note", "warning", "see", "example", "since",
	         "status", "detour", "forms", "receiver" ]

# The extensions of a method name, library-owned data (the grammar of names:
# base/doc/narrations/stz-functions-as-linguistic-expressions.md). Longest
# first, so QRT is read before Q. [ code, spelling as written, what it adds ].
func _StzDocExtensions()
	return [
		[ "QQQ",    "QQQ",    "chains on the most specific type of object (the Q ladder)" ],
		[ "QRT",    "QRT",    "returns the result as an object of the requested type" ],
		[ "XTT",    "XTT",    "a further extended form, after XT" ],
		[ "EXCEPT", "Except", "takes exceptions, what to leave out" ],
		[ "MANY",   "Many",   "works on a collection of items instead of one" ],
		[ "QQ",     "QQ",     "chains on the next, more specific type of object (the Q ladder)" ],
		[ "QC",     "QC",     "chains on a copy, so the original object stays unchanged" ],
		[ "CS",     "CS",     "takes a case-sensitivity flag" ],
		[ "ST",     "ST",     "takes the position to start from" ],
		[ "IB",     "IB",     "takes bounds that are included" ],
		[ "XT",     "XT",     "the extended form: more parameters than the base method" ],
		[ "ZZ",     "ZZ",     "returns positions as sections, [start, end]" ],
		[ "WF",     "WF",     "selects by a condition, with the expressive keywords (@NextItem, @PreviousItem)" ],
		[ "Q",      "Q",      "does what the method does, then returns the object, so the call can be chained" ],
		[ "Z",      "Z",      "includes the position in what it returns" ],
		[ "W",      "W",      "selects by a condition" ],
		[ "D",      "D",      "takes a direction, forward or backward" ],
		[ "F",      "F",      "takes a function (the condition or the update is given as a function)" ],
		[ "U",      "U",      "returns the result without duplication" ]
	]

# --- small text helpers --------------------------------------------------
# Number of leading blanks of a comment text (a tab counts as 4).
func _StzDocIndent(pcText)
	_n_ = 0
	_nL_ = len(pcText)
	for _i_ = 1 to _nL_
		if pcText[_i_] = " "
			_n_++
		but pcText[_i_] = char(9)
			_n_ += 4
		else
			exit
		ok
	next
	return _n_

# Cut a text at column pnCol (the first pnCol blanks of width), keeping the rest.
func _StzDocFromCol(pcText, pnCol)
	_n_ = 0
	_nL_ = len(pcText)
	for _i_ = 1 to _nL_
		if _n_ >= pnCol
			return right(pcText, _nL_ - _i_ + 1)
		ok
		if pcText[_i_] = " "
			_n_++
		but pcText[_i_] = char(9)
			_n_ += 4
		else
			exit
		ok
	next
	return ring_trim(pcText)

# [ key, valueText, valueColumn ] when pcText (a comment text, '#' removed)
# opens a field, else [ ].
func _StzDocFieldStart(pcText, pacParams)
	_nInd_ = _StzDocIndent(pcText)
	if _nInd_ < 2
		return []
	ok
	_cB_ = ring_trim(pcText)
	if _cB_ = ""
		return []
	ok
	_nL_ = len(_cB_)
	_cTok_ = ""
	for _i_ = 1 to _nL_
		if _cB_[_i_] = " " or _cB_[_i_] = char(9)
			exit
		ok
		_cTok_ += _cB_[_i_]
	next
	_cKey_ = lower(_cTok_)
	_bOk_ = (ring_find(_StzDocKeys(), _cKey_) > 0)
	if NOT _bOk_
		_nP_ = len(pacParams)
		for _i_ = 1 to _nP_
			if lower(pacParams[_i_]) = _cKey_
				_bOk_ = 1
				exit
			ok
		next
	ok
	if NOT _bOk_
		return []
	ok
	# the separator after the key: end of line, or 2+ blanks / a tab
	_nT_ = len(_cTok_)
	if _nT_ = _nL_
		return [ _cTok_, "", _nInd_ + _nT_ + 2 ]
	ok
	_nGap_ = 0
	for _i_ = _nT_ + 1 to _nL_
		if _cB_[_i_] = " "
			_nGap_++
		but _cB_[_i_] = char(9)
			_nGap_ += 4
		else
			exit
		ok
	next
	if _nGap_ < 2
		return []
	ok
	return [ _cTok_, ring_trim(right(_cB_, _nL_ - _nT_)), _nInd_ + _nT_ + _nGap_ ]

# Parse a comment run (list of comment texts, '#' removed, blank comments kept
# as "") into [ brief, paragraph, fields, legacy ], where fields is
# [ [ kind, name, text ], ... ] and kind is "param" or the key.
func _StzDocParseRun(pacRun, pacParams)
	_cBrief_ = ""
	_cPara_ = ""
	_aFields_ = []
	_cMode_ = "brief"
	_nValCol_ = 0
	_bLegacy_ = 1
	_nR_ = len(pacRun)
	for _i_ = 1 to _nR_
		_cT_ = pacRun[_i_]
		_cB_ = ring_trim(_cT_)
		if _cMode_ = "fields"
			if _cB_ = ""
				loop
			ok
			_aFs_ = []
			if _StzDocIndent(_cT_) < _nValCol_
				_aFs_ = _StzDocFieldStart(_cT_, pacParams)
			ok
			if len(_aFs_) > 0
				_StzDocAddField(_aFields_, _aFs_, pacParams)
				_nValCol_ = _aFs_[3]
			else
				_nF_ = len(_aFields_)
				if _nF_ > 0
					_cCont_ = _cB_
					if _aFields_[_nF_][1] = "example"
						_cCont_ = _StzDocFromCol(_cT_, _nValCol_)
					ok
					if _aFields_[_nF_][3] != ""
						if _aFields_[_nF_][1] = "example"
							_aFields_[_nF_][3] += char(10) + _cCont_
						else
							_aFields_[_nF_][3] += " " + _cCont_
						ok
					else
						_aFields_[_nF_][3] = _cCont_
					ok
				ok
			ok
		else
			_aFs_ = _StzDocFieldStart(_cT_, pacParams)
			if len(_aFs_) > 0
				_cMode_ = "fields"
				_bLegacy_ = 0
				_StzDocAddField(_aFields_, _aFs_, pacParams)
				_nValCol_ = _aFs_[3]
			but _cB_ = ""
				if _cMode_ = "brief" and _cBrief_ != ""
					_cMode_ = "para"
					_bLegacy_ = 0
				ok
			but _cMode_ = "brief"
				if _cBrief_ != ""
					_cBrief_ += " "
				ok
				_cBrief_ += _cB_
			else
				if _cPara_ != ""
					_cPara_ += " "
				ok
				_cPara_ += _cB_
			ok
		ok
	next
	# A legacy run (no separator, no field) that is longer than a brief may be:
	# its first sentence is the brief, the rest the detail.
	if _bLegacy_ and StzLen(_cBrief_) > 140
		_nEnd_ = _StzDocSentenceEnd(_cBrief_)
		if _nEnd_ > 0 and _nEnd_ < len(_cBrief_)
			_cPara_ = ring_trim(right(_cBrief_, len(_cBrief_) - _nEnd_))
			_cBrief_ = ring_trim(left(_cBrief_, _nEnd_))
		ok
	ok
	return [ _StzDocCleanBrief(_cBrief_), _cPara_, _aFields_, _bLegacy_ ]

func _StzDocAddField(paFields, paStart, pacParams)
	_cKey_ = lower(paStart[1])
	_cKind_ = _cKey_
	_cName_ = ""
	if ring_find(_StzDocKeys(), _cKey_) = 0
		_cKind_ = "param"
		_cName_ = paStart[1]
	ok
	paFields + [ _cKind_, _cName_, paStart[2] ]

# The position of the end of the first sentence ('.' followed by a blank and an
# uppercase letter, or the last '.'), 0 if none.
func _StzDocSentenceEnd(pcText)
	_nL_ = len(pcText)
	for _i_ = 1 to _nL_ - 2
		if pcText[_i_] = "." and pcText[_i_ + 1] = " "
			_c_ = pcText[_i_ + 2]
			if _c_ != lower(_c_)
				return _i_
			ok
		ok
	next
	return 0

# The brief as shown: the polish the harvest already applies (dash artefacts,
# maintainer chatter), nothing else.
func _StzDocCleanBrief(pcText)
	return _StzPolishDesc(ring_trim(pcText))

# What a parsed run adds to a method's RETRIEVAL text (never to its description):
# the detail paragraph, the parameter roles, the returns, the notes, the see-also.
func _StzDocRetrievalExtra(paRun)
	_c_ = paRun[2]
	_aF_ = paRun[3]
	_n_ = len(_aF_)
	for _i_ = 1 to _n_
		if _aF_[_i_][1] != "example" and _aF_[_i_][3] != ""
			_c_ += " " + _aF_[_i_][3]
		ok
	next
	return ring_trim(_c_)

# --- reading a source file -----------------------------------------------
func _StzDocLines(pcFile)
	_cSrc_ = read(pcFile)
	_cSrc_ = StzReplace(_cSrc_, char(13), "")
	return str2list(_cSrc_)

# TRUE for `class X` / `Class X` (not a comment, not inside a block comment)
func _StzDocIsClassLine(pcTrim)
	return len(pcTrim) > 6 and lower(left(pcTrim, 6)) = "class " and
	       substr(pcTrim, "{") = 0

func _StzDocIsPackageLine(pcTrim)
	return len(pcTrim) > 8 and lower(left(pcTrim, 8)) = "package "

# TRUE for a method-opening line: `def Name` or `func Name` (a function literal
# `func c {` is not one).
func _StzDocIsDefLine(pcTrim)
	if substr(pcTrim, "{") > 0
		return 0
	ok
	if len(pcTrim) > 4 and lower(left(pcTrim, 4)) = "def "
		return 1
	ok
	if len(pcTrim) > 5 and lower(left(pcTrim, 5)) = "func "
		return 1
	ok
	return 0

# The parameter names of a def line, as written.
func _StzDocParamsOf(pcTrim)
	_aOut_ = []
	_nO_ = substr(pcTrim, "(")
	if _nO_ = 0
		return _aOut_
	ok
	_nC_ = 0
	_nL_ = len(pcTrim)
	for _i_ = _nL_ to _nO_ + 1 step -1
		if pcTrim[_i_] = ")"
			_nC_ = _i_
			exit
		ok
	next
	if _nC_ <= _nO_ + 1
		return _aOut_
	ok
	_cIn_ = substr(pcTrim, _nO_ + 1, _nC_ - _nO_ - 1)
	_cCur_ = ""
	_nI_ = len(_cIn_)
	for _i_ = 1 to _nI_
		if _cIn_[_i_] = ","
			_cCur_ = ring_trim(_cCur_)
			if _cCur_ != ""
				_aOut_ + _cCur_
			ok
			_cCur_ = ""
		else
			_cCur_ += _cIn_[_i_]
		ok
	next
	_cCur_ = ring_trim(_cCur_)
	if _cCur_ != ""
		_aOut_ + _cCur_
	ok
	return _aOut_

# `return This.Name(args)` -> [ Name, [ args ] ], else [ ]. Any argument text is
# accepted; the caller decides whether the call is a PURE forward.
func _StzDocFwdParse(pcTrim)
	_cL_ = lower(pcTrim)
	if left(_cL_, 12) != "return this."
		return []
	ok
	_cRest_ = right(pcTrim, len(pcTrim) - 12)
	_nO_ = substr(_cRest_, "(")
	if _nO_ < 2
		return []
	ok
	_cNm_ = ring_trim(left(_cRest_, _nO_ - 1))
	_nN_ = len(_cNm_)
	if _nN_ = 0
		return []
	ok
	for _i_ = 1 to _nN_
		if NOT (isalnum(_cNm_[_i_]) or _cNm_[_i_] = "_")
			return []
		ok
	next
	_nR_ = len(_cRest_)
	_nC_ = 0
	for _i_ = _nR_ to _nO_ + 1 step -1
		if _cRest_[_i_] = ")"
			_nC_ = _i_
			exit
		ok
	next
	if _nC_ = 0
		return []
	ok
	if ring_trim(right(_cRest_, _nR_ - _nC_)) != ""
		return []
	ok
	_aArgs_ = []
	if _nC_ > _nO_ + 1
		_cIn_ = substr(_cRest_, _nO_ + 1, _nC_ - _nO_ - 1)
		_cCur_ = ""
		_nI_ = len(_cIn_)
		for _i_ = 1 to _nI_
			if _cIn_[_i_] = ","
				_aArgs_ + ring_trim(_cCur_)
				_cCur_ = ""
			else
				_cCur_ += _cIn_[_i_]
			ok
		next
		_aArgs_ + ring_trim(_cCur_)
	ok
	return [ _cNm_, _aArgs_ ]

# One method record. Hashlist, every key present.
func _StzDocNewMethod(pcName, pnLine)
	return [ :name = pcName, :line = pnLine, :params = [], :section = "",
	         :brief = "", :para = "", :fields = [], :aka = "", :legacy = 1,
	         :adjacent = 1, :fwd = "", :fwdpure = 0, :hasreturn = 0 ]

# Scan lines [pnStart, pnEnd] of a class body into method records (public AND
# private: the private names are needed to judge a forward). The doc run is the
# comment lines above a def (blank lines do not break it, code does -- the same
# tolerance the harvest has always had; `adjacent` records whether a blank
# line separated them, the gate asks for none).
func _StzDocScanRange(pacLines, pnStart, pnEnd)
	_aOut_ = []
	_acRun_ = []
	_cAka_ = ""
	_cSection_ = ""
	_bBlock_ = 0
	_bGap_ = 0
	# the body of the method being read, gathered line by line (one pass)
	_nCur_ = 0
	_nCode_ = 0
	_cFirst_ = ""
	_bRet_ = 0
	_nLen_ = len(pacLines)
	if pnEnd > _nLen_
		pnEnd = _nLen_
	ok
	for _i_ = pnStart to pnEnd
		_cT_ = ring_trim(pacLines[_i_])
		if _bBlock_
			if substr(_cT_, "*/") > 0
				_bBlock_ = 0
			ok
			loop
		ok
		if left(_cT_, 2) = "/*"
			if substr(_cT_, "*/") = 0
				_bBlock_ = 1
			ok
			_acRun_ = []
			_cAka_ = ""
			loop
		ok
		if _cT_ = ""
			if len(_acRun_) > 0
				_bGap_ = 1
			ok
			loop
		ok
		if left(_cT_, 1) = "#"
			_cL8_ = lower(left(_cT_, 8))
			if left(_cL8_, 5) = "#todo" or left(_cL8_, 8) = "#warning" or
			   left(_cT_, 2) = "#<" or left(_cT_, 2) = "#>"
				loop
			ok
			if left(_cT_, 2) = "#@"
				_cAka_ += _StzInfoTagText(_cT_)
				loop
			ok
			# a boxed line (a border or a section title) is at least two marks long;
			# a lone # is an empty comment line, the separator inside a doc block
			if len(_cT_) >= 2 and right(_cT_, 1) = "#"
				_cIn_ = ""
				if len(_cT_) >= 3
					_cIn_ = ring_trim(substr(_cT_, 2, len(_cT_) - 2))
				ok
				_cTitle_ = _StzSectionTitle(_cIn_)
				if _cTitle_ != ""
					_cSection_ = _cTitle_
				ok
				_acRun_ = []
				_bGap_ = 0
				loop
			ok
			if left(ring_trim(right(_cT_, len(_cT_) - 1)), 3) = "---"
				loop
			ok
			# the raw line keeps its blanks (indentation carries the field syntax)
			_cRaw_ = pacLines[_i_]
			_nHash_ = substr(_cRaw_, "#")
			_acRun_ + right(_cRaw_, len(_cRaw_) - _nHash_)
			_bGap_ = 0
			loop
		ok
		_bDef_ = _StzDocIsDefLine(_cT_)
		if _bDef_ or _StzDocIsClassLine(_cT_)
			# the method being read ends here
			if _nCur_ > 0
				_aOut_[_nCur_] = _StzDocFinishBody(_aOut_[_nCur_], _nCode_, _cFirst_, _bRet_)
				_nCur_ = 0
			ok
		ok
		if _bDef_
			_cDefLine_ = _cT_
			_bFunc_ = (lower(left(_cT_, 5)) = "func ")
			if _bFunc_
				_cDefLine_ = "def " + right(_cT_, len(_cT_) - 5)
			ok
			_cName_ = _StzDefName(_cDefLine_)
			# a `func StzXxx` after a class is a global that landed in the class
			# body by position, not a method
			_bKeep_ = (_cName_ != "")
			if _bFunc_ and left(_cName_, 3) = "Stz"
				_bKeep_ = 0
			ok
			if _bKeep_
				_aRec_ = _StzDocNewMethod(_cName_, _i_)
				_aPar_ = _StzDocParamsOf(_cT_)
				_aRec_[:params] = _aPar_
				_aRec_[:section] = _cSection_
				_aRec_[:aka] = ring_trim(_cAka_)
				_aRec_[:adjacent] = (NOT _bGap_)
				_aP_ = _StzDocParseRun(_acRun_, _aPar_)
				_aRec_[:brief] = _aP_[1]
				_aRec_[:para] = _aP_[2]
				_aRec_[:fields] = _aP_[3]
				_aRec_[:legacy] = _aP_[4]
				if len(_acRun_) = 0
					_aRec_[:legacy] = 0
				ok
				_aOut_ + _aRec_
				_nCur_ = len(_aOut_)
				_nCode_ = 0
				_cFirst_ = ""
				_bRet_ = 0
			ok
			_acRun_ = []
			_cAka_ = ""
			_bGap_ = 0
			loop
		ok
		# a code line of the method body
		if _nCur_ > 0
			_nCode_++
			if _nCode_ = 1
				_cFirst_ = _cT_
			ok
			if len(_cT_) > 7 and lower(left(_cT_, 7)) = "return "
				_bRet_ = 1
			ok
		ok
		# any code line breaks the comment run
		_acRun_ = []
		_cAka_ = ""
		_bGap_ = 0
	next
	if _nCur_ > 0
		_aOut_[_nCur_] = _StzDocFinishBody(_aOut_[_nCur_], _nCode_, _cFirst_, _bRet_)
	ok
	return _aOut_

# What the body of a method says: whether it returns a value, and whether it is
# one forwarding statement (`return This.X(...)`), pure when the arguments are
# its own parameters, unchanged and in order.
func _StzDocFinishBody(paRec, pnCode, pcFirst, pbRet)
	paRec[:hasreturn] = pbRet
	if pnCode = 1
		_aF_ = _StzDocFwdParse(pcFirst)
		if len(_aF_) = 2 and lower(_aF_[1]) != lower(paRec[:name])
			paRec[:fwd] = _aF_[1]
			_aPar_ = paRec[:params]
			_bPure_ = (len(_aF_[2]) = len(_aPar_))
			if _bPure_
				_nQ_ = len(_aPar_)
				for _q_ = 1 to _nQ_
					if lower(_aF_[2][_q_]) != lower(_aPar_[_q_])
						_bPure_ = 0
						exit
					ok
				next
			ok
			paRec[:fwdpure] = _bPure_
		ok
	ok
	return paRec

# --- the library: classes, parents, extents ------------------------------
# [ [ name, file (relative to base), parent, firstLine, lastLine ], ... ].
# A class runs from its `class` line to the next `class` or `package` line:
# a `func` inside it is a METHOD, not a boundary (Ring's own rule -- and the
# reason stzTable and stzObject lost 6,000 methods to the old harvest).
func _StzDocScanLibrary(pcBase)
	_aOut_ = []
	_acFiles_ = []
	_StzDocListRing(pcBase, "", _acFiles_)
	_nF_ = len(_acFiles_)
	for _f_ = 1 to _nF_
		_aLines_ = _StzDocLines(pcBase + "/" + _acFiles_[_f_])
		_nL_ = len(_aLines_)
		_bBlock_ = 0
		_nOpen_ = 0
		_aCur_ = []
		for _i_ = 1 to _nL_
			_cT_ = ring_trim(_aLines_[_i_])
			if _bBlock_
				if substr(_cT_, "*/") > 0
					_bBlock_ = 0
				ok
				loop
			ok
			if left(_cT_, 2) = "/*"
				if substr(_cT_, "*/") = 0
					_bBlock_ = 1
				ok
				loop
			ok
			if left(_cT_, 1) = "#"
				loop
			ok
			_bCls_ = _StzDocIsClassLine(_cT_)
			if _bCls_ or _StzDocIsPackageLine(_cT_)
				if len(_aCur_) > 0
					_aCur_[5] = _i_ - 1
					_aOut_ + _aCur_
					_aCur_ = []
				ok
				if _bCls_
					_aW_ = _StzWords(_cT_)
					_cNm_ = _aW_[2]
					_cPar_ = ""
					if len(_aW_) >= 4 and lower(_aW_[3]) = "from"
						_cPar_ = _aW_[4]
					ok
					_aCur_ = [ _cNm_, _acFiles_[_f_], _cPar_, _i_, _nL_ ]
				ok
			ok
		next
		if len(_aCur_) > 0
			_aOut_ + _aCur_
		ok
	next
	return _aOut_

# Every .ring file under pcBase (relative paths), skipping archive/, test/,
# doc/ and the temporary folders: the live library, not its history.
func _StzDocListRing(pcBase, pcRel, pacOut)
	_cDir_ = pcBase
	if pcRel != ""
		_cDir_ = pcBase + "/" + pcRel
	ok
	_aE_ = dir(_cDir_)
	_n_ = len(_aE_)
	for _i_ = 1 to _n_
		_cN_ = _aE_[_i_][1]
		if _cN_ = "." or _cN_ = ".."
			loop
		ok
		_cRel_ = _cN_
		if pcRel != ""
			_cRel_ = pcRel + "/" + _cN_
		ok
		if _aE_[_i_][2] = 1
			_cLow_ = lower(_cN_)
			if _cLow_ = "archive" or _cLow_ = "test" or _cLow_ = "doc" or
			   _cLow_ = "_tmp" or _cLow_ = "recovered" or _cLow_ = "plugin"
				loop
			ok
			_StzDocListRing(pcBase, _cRel_, pacOut)
		else
			if right(lower(_cN_), 5) = ".ring"
				pacOut + _cRel_
			ok
		ok
	next

# The doc run directly above a `class` line (no blank line, stops at a boxed
# banner): [ brief, paragraph, fields, legacy ].
func _StzDocClassBlock(pacLines, pnClassLine)
	_acRun_ = []
	_i_ = pnClassLine - 1
	while _i_ >= 1
		_cT_ = ring_trim(pacLines[_i_])
		if left(_cT_, 1) != "#" or (len(_cT_) >= 2 and right(_cT_, 1) = "#") or left(_cT_, 2) = "#@"
			exit
		ok
		_cRaw_ = pacLines[_i_]
		_nH_ = substr(_cRaw_, "#")
		_acRun_ + right(_cRaw_, len(_cRaw_) - _nH_)
		_i_--
	end
	_acRev_ = []
	_nR_ = len(_acRun_)
	for _k_ = _nR_ to 1 step -1
		_acRev_ + _acRun_[_k_]
	next
	return _StzDocParseRun(_acRev_, [])

# --- one method's written record, for Explain ----------------------------
# StzDocRecordOf(cClass, cMethod) -> a hashlist of what the author WROTE
# above the def (brief, params, returns, notes, see, example, since, status),
# or [ ] when the method or its source is unknown. Cached per class.
func StzDocRecordOf(pcClass, pcMethod)
	return StzDocRecordOfIn(pcClass, pcMethod, "")

# The same, reading the class from pcSource (a file path) instead of resolving
# its name, for a class opened by path.
func StzDocRecordOfIn(pcClass, pcMethod, pcSource)
	_cKey_ = lower(pcClass)
	_aRecs_ = []
	_nC_ = len($aStzDocRecCache)
	_bFound_ = 0
	for _i_ = 1 to _nC_
		if $aStzDocRecCache[_i_][1] = _cKey_
			_aRecs_ = $aStzDocRecCache[_i_][2]
			_bFound_ = 1
			exit
		ok
	next
	if NOT _bFound_
		_cSrc_ = pcSource
		if _cSrc_ = ""
			_cSrc_ = _StzResolveSource(pcClass)
		ok
		if _cSrc_ != "" and fexists(_cSrc_)
			_aLines_ = _StzDocLines(_cSrc_)
			_nL_ = len(_aLines_)
			for _i_ = 1 to _nL_
				if _StzIsClassLineNamed(ring_trim(_aLines_[_i_]), _cKey_)
					_nEnd_ = _nL_
					for _j_ = _i_ + 1 to _nL_
						_cT_ = ring_trim(_aLines_[_j_])
						if _StzDocIsClassLine(_cT_) or _StzDocIsPackageLine(_cT_)
							_nEnd_ = _j_ - 1
							exit
						ok
					next
					_aRecs_ = _StzDocScanRange(_aLines_, _i_ + 1, _nEnd_)
					exit
				ok
			next
		ok
		$aStzDocRecCache + [ _cKey_, _aRecs_ ]
	ok
	_cM_ = lower(pcMethod)
	_nR_ = len(_aRecs_)
	for _i_ = 1 to _nR_
		if lower(_aRecs_[_i_][:name]) = _cM_
			_aF_ = _aRecs_[_i_][:fields]
			return [ :name = _aRecs_[_i_][:name], :brief = _aRecs_[_i_][:brief],
			         :params = _aRecs_[_i_][:params], :fields = _aF_,
			         :returns = _StzDocFieldText(_aF_, "returns"),
			         :notes = _StzDocFieldList(_aF_, "note"),
			         :see = _StzDocFieldText(_aF_, "see"),
			         :example = _StzDocFieldText2(_aF_, "example"),
			         :since = _StzDocFieldText(_aF_, "since"),
			         :status = _StzDocFieldText(_aF_, "status") ]
		ok
	next
	return []

# the role of a parameter as WRITTEN above the def, "" if none
func _StzDocWrittenRole(paRec, pcParam)
	_aF_ = paRec[:fields]
	_n_ = len(_aF_)
	for _i_ = 1 to _n_
		if _aF_[_i_][1] = "param" and lower(_aF_[_i_][2]) = lower(pcParam)
			return _aF_[_i_][3]
		ok
	next
	return ""
