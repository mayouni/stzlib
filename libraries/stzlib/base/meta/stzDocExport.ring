#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZDOCEXPORT                   #
#   An accelerative library for Ring applications, and more!    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : derive, score and export the reference       #
#                  record (see stzDocRecord.ring for the block   #
#                  and base/doc/design/DOCREFORM_PROPOSAL.md).   #
#                                                              #
#     StzReferenceExport(cBase, cOut, cCommit, cDate)           #
#     StzReferenceExportOnly(cBase, cOut, cCommit, cDate, aCls) #
#     StzDocFindings(cBase)   dead forwards, typos, internals   #
#     StzDocScoreOf(cBrief, cName)  the brief checks            #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)        #
#                                                              #
#--------------------------------------------------------------#

# --- JSON writing (no dependency; deterministic) -------------------------
# JSON string escaping. The five bytes replaced are ASCII (backslash, quote, LF,
# TAB, CR) and so can never be part of a multi-byte UTF-8 sequence: Ring's
# builtin substr() is safe here, and 20x faster than StzReplace (68 us a call
# through the engine boundary, measured; 20,000 strings = 1.4 s against 70 ms).
func _StzDocJs(pcS)
	_c_ = "" + pcS
	if _c_ = ""
		return char(34) + char(34)
	ok
	_bs_ = char(92)
	_q_ = char(34)
	_c_ = substr(_c_, _bs_, _bs_ + _bs_)
	_c_ = substr(_c_, _q_, _bs_ + _q_)
	_c_ = substr(_c_, char(10), _bs_ + "n")
	_c_ = substr(_c_, char(9), _bs_ + "t")
	_c_ = substr(_c_, char(13), "")
	return _q_ + _c_ + _q_

func _StzDocJList(pacItems)
	_c_ = "["
	_n_ = len(pacItems)
	for _i_ = 1 to _n_
		if _i_ > 1
			_c_ += ","
		ok
		_c_ += _StzDocJs(pacItems[_i_])
	next
	return _c_ + "]"

# --- words ---------------------------------------------------------------
# the words of a CamelCase name, case kept (an all-uppercase run is an
# acronym or an extension code: CS, XT, QC, URL)
func _StzDocNameWordsRaw(pcName)
	_aOut_ = []
	_cCur_ = ""
	_nL_ = len(pcName)
	for _i_ = 1 to _nL_
		_c_ = pcName[_i_]
		_bUp_ = (_c_ != lower(_c_))
		if _c_ = "_"
			if _cCur_ != ""
				_aOut_ + _cCur_
				_cCur_ = ""
			ok
			loop
		ok
		if _bUp_ and _cCur_ != ""
			# a new word starts at an uppercase after a lowercase/digit, or at the
			# last uppercase of an acronym followed by a lowercase
			_cPrev_ = pcName[_i_ - 1]
			_bPrevUp_ = (_cPrev_ != lower(_cPrev_))
			_bNextLow_ = 0
			if _i_ < _nL_
				_cNx_ = pcName[_i_ + 1]
				_bNextLow_ = (_cNx_ = lower(_cNx_) and NOT isdigit(_cNx_))
			ok
			if (NOT _bPrevUp_) or _bNextLow_
				_aOut_ + _cCur_
				_cCur_ = ""
			ok
		ok
		_cCur_ += _c_
	next
	if _cCur_ != ""
		_aOut_ + _cCur_
	ok
	return _aOut_

# the lowercase words of a CamelCase name
func _StzDocNameWords(pcName)
	_aW_ = _StzDocNameWordsRaw(pcName)
	_n_ = len(_aW_)
	for _i_ = 1 to _n_
		_aW_[_i_] = lower(_aW_[_i_])
	next
	return _aW_

func _StzDocStem(pcW)
	_w_ = pcW
	_n_ = len(_w_)
	if _n_ > 4 and right(_w_, 3) = "ing"
		return left(_w_, _n_ - 3)
	ok
	if _n_ > 3 and right(_w_, 2) = "ed"
		return left(_w_, _n_ - 2)
	ok
	if _n_ > 3 and right(_w_, 2) = "es"
		return left(_w_, _n_ - 2)
	ok
	if _n_ > 3 and right(_w_, 1) = "s"
		return left(_w_, _n_ - 1)
	ok
	if _n_ > 3 and right(_w_, 1) = "d"
		return left(_w_, _n_ - 1)
	ok
	return _w_

func _StzDocStopwords()
	return [ "the", "a", "an", "of", "to", "in", "is", "if", "for", "and", "or",
	         "as", "by", "with", "it", "its", "this", "that", "on", "at", "from",
	         "returns", "true", "false", "object", "given", "whether", "each",
	         "all", "any", "are", "be", "into", "one", "than", "then", "when",
	         "which", "while", "being", "has", "have", "does", "do" ]

# the lowercase alphanumeric tokens of a text
func _StzDocTokens(pcText)
	_aOut_ = []
	_cCur_ = ""
	_n_ = len(pcText)
	for _i_ = 1 to _n_
		_c_ = pcText[_i_]
		if isalnum(_c_)
			_cCur_ += lower(_c_)
		else
			if _cCur_ != ""
				_aOut_ + _cCur_
				_cCur_ = ""
			ok
		ok
	next
	if _cCur_ != ""
		_aOut_ + _cCur_
	ok
	return _aOut_

# --- the brief checks ------------------------------------------------------
# CHECK 1 -- form: 20..140 characters, opens in uppercase, ends with a period,
# opens with a third-person verb, `Returns`, or `TRUE if` / `FALSE if`.
func _StzDocBriefForm(pcBrief)
	_b_ = ring_trim(pcBrief)
	_n_ = StzLen(_b_)
	if _n_ < 20 or _n_ > 140
		return 0
	ok
	_c1_ = StzLeft(_b_, 1)
	if StzLower(_c1_) = _c1_
		return 0
	ok
	if right(_b_, 1) != "."
		return 0
	ok
	_aW_ = _StzWords(_b_)
	_w_ = lower(_aW_[1])
	# "Returns, for each ..." opens with Returns: the comma is punctuation
	while len(_w_) > 1 and ring_find([ ",", ";", ":" ], right(_w_, 1)) > 0
		_w_ = left(_w_, len(_w_) - 1)
	end
	if _w_ = "true" or _w_ = "false"
		if len(_aW_) >= 2 and lower(_aW_[2]) = "if"
			return 1
		ok
		return 0
	ok
	if _w_ = "returns"
		return 1
	ok
	if len(_w_) >= 4 and right(_w_, 1) = "s"
		_acDeny_ = [ "this", "its", "always", "perhaps", "sometimes", "thus",
		             "plus", "various", "previous", "besides", "across", "unless",
		             "towards", "versus", "numbers", "items", "elements", "lists",
		             "strings", "values", "these", "those", "chars", "names" ]
		if ring_find(_acDeny_, _w_) = 0
			return 1
		ok
	ok
	return 0

# CHECK 2 -- not the name restated, not the signature repeated.
func _StzDocBriefRestates(pcBrief, pcName)
	_b_ = ring_trim(pcBrief)
	if substr(lower(_b_), lower(pcName) + "(") > 0
		return 1
	ok
	_aNw_ = _StzDocNameWords(pcName)
	_acNameStems_ = []
	_nN_ = len(_aNw_)
	for _i_ = 1 to _nN_
		_acNameStems_ + _StzDocStem(_aNw_[_i_])
	next
	_aTk_ = _StzDocTokens(_b_)
	_aStop_ = _StzDocStopwords()
	_nContent_ = 0
	_nT_ = len(_aTk_)
	for _i_ = 1 to _nT_
		if ring_find(_aStop_, _aTk_[_i_]) > 0
			loop
		ok
		_nContent_++
		if ring_find(_acNameStems_, _StzDocStem(_aTk_[_i_])) = 0
			return 0
		ok
	next
	return 1

# the checks 1 and 2 on a brief, as [ form, notRestated ] (1 / 0)
func StzDocScoreOf(pcBrief, pcName)
	_nF_ = _StzDocBriefForm(pcBrief)
	_nR_ = 0
	if ring_trim(pcBrief) != ""
		_nR_ = 1 - _StzDocBriefRestates(pcBrief, pcName)
	ok
	return [ _nF_, _nR_ ]

# --- parameters ----------------------------------------------------------
func _StzDocParamType(pcName)
	_n_ = len(pcName)
	_acPre_ = [ [ "pac", "list of text" ], [ "pan", "list of numbers" ],
	            [ "pao", "list of objects" ], [ "pc", "text" ],
	            [ "pn", "number" ], [ "pa", "list" ], [ "pb", "boolean" ],
	            [ "po", "object" ], [ "p", "any" ] ]
	_nP_ = len(_acPre_)
	for _i_ = 1 to _nP_
		_cP_ = _acPre_[_i_][1]
		_nK_ = len(_cP_)
		if _n_ >= _nK_ and left(pcName, _nK_) = _cP_
			if _n_ = _nK_
				return _acPre_[_i_][2]
			ok
			_c_ = pcName[_nK_ + 1]
			if _c_ != lower(_c_) or isdigit(_c_)
				return _acPre_[_i_][2]
			ok
		ok
	next
	return "any"

# The parameter glossary, written once: base/doc/params.txt, one
# `name<TAB>role` per line; '#' lines are comments. Loaded once.
func _StzDocLoadGlossary(pcBase)
	$aStzDocGlossName = []
	$aStzDocGlossRole = []
	_cF_ = pcBase + "/doc/params.txt"
	if NOT fexists(_cF_)
		return
	ok
	_aL_ = _StzDocLines(_cF_)
	_n_ = len(_aL_)
	for _i_ = 1 to _n_
		_c_ = ring_trim(_aL_[_i_])
		if _c_ = "" or left(_c_, 1) = "#"
			loop
		ok
		_nT_ = substr(_c_, char(9))
		if _nT_ > 1
			$aStzDocGlossName + lower(ring_trim(left(_c_, _nT_ - 1)))
			$aStzDocGlossRole + ring_trim(right(_c_, len(_c_) - _nT_))
		ok
	next

# --- fields of a parsed run ---------------------------------------------
func _StzDocFieldText(paFields, pcKind)
	_c_ = ""
	_n_ = len(paFields)
	for _i_ = 1 to _n_
		if paFields[_i_][1] = pcKind and paFields[_i_][3] != ""
			if _c_ != ""
				_c_ += " "
			ok
			_c_ += paFields[_i_][3]
		ok
	next
	return _c_

func _StzDocFieldList(paFields, pcKind)
	_a_ = []
	_n_ = len(paFields)
	for _i_ = 1 to _n_
		if paFields[_i_][1] = pcKind and paFields[_i_][3] != ""
			_a_ + paFields[_i_][3]
		ok
	next
	return _a_

# comma-separated -> trimmed items
func _StzDocSplitComma(pcText)
	_a_ = []
	_c_ = ""
	_n_ = len(pcText)
	for _i_ = 1 to _n_
		if pcText[_i_] = ","
			_c_ = ring_trim(_c_)
			if _c_ != ""
				_a_ + _c_
			ok
			_c_ = ""
		else
			_c_ += pcText[_i_]
		ok
	next
	_c_ = ring_trim(_c_)
	if _c_ != ""
		_a_ + _c_
	ok
	return _a_

# the expected outputs (`#-->` lines) of an example
func _StzDocPromises(pcExample)
	_a_ = []
	_aL_ = str2list(pcExample)
	_n_ = len(_aL_)
	for _i_ = 1 to _n_
		_c_ = ring_trim(_aL_[_i_])
		if left(_c_, 4) = "#-->"
			_a_ + ring_trim(right(_c_, len(_c_) - 4))
		ok
	next
	return _a_

# --- derivations from the NAME ---------------------------------------------
# [ lead, rest-words ] for a predicate name (Is/Are/Has/Can/Does/Contains...),
# else [ ].
func _StzDocPredicate(pcName)
	_acLead_ = [ [ "IsNot", "is not" ], [ "Is", "is" ], [ "AreNot", "are not" ],
	             [ "Are", "are" ], [ "Has", "has" ], [ "Can", "can" ],
	             [ "Does", "does" ], [ "Contains", "contains" ] ]
	_nL_ = len(_acLead_)
	_n_ = len(pcName)
	for _i_ = 1 to _nL_
		_cP_ = _acLead_[_i_][1]
		_nK_ = len(_cP_)
		if _n_ >= _nK_ and left(pcName, _nK_) = _cP_
			if _n_ = _nK_
				return []
			ok
			_c_ = pcName[_nK_ + 1]
			if _c_ != lower(_c_) or isdigit(_c_)
				_aW_ = _StzDocNameWords(right(pcName, _n_ - _nK_))
				_cW_ = ""
				_nW_ = len(_aW_)
				for _k_ = 1 to _nW_
					if _k_ > 1
						_cW_ += " "
					ok
					_cW_ += _aW_[_k_]
				next
				return [ _acLead_[_i_][2], _cW_ ]
			ok
		ok
	next
	return []

func _StzDocIsHostCollision(pcLower)
	_a_ = [ "isstring", "isnumber", "islist", "isobject", "isalpha", "isdigit",
	        "islower", "isupper", "isspace", "isalnum", "ispunct", "isnull",
	        "isfunction", "isunix", "iswindows", "ismacosx", "islinux",
	        "isglobal", "islocal", "isattribute", "ismethod", "ispackage",
	        "iscfunction", "isfreebsd", "isandroid", "iscntrl", "isgraph",
	        "isprint", "isxdigit", "isclass" ]
	return ring_find(_a_, pcLower) > 0

# --- the extension split ---------------------------------------------------
# does any class of the chain define the (lowercase) name?
func _StzDocInChain(pnaChain, pcLow)
	_n_ = len(pnaChain)
	for _k_ = 1 to _n_
		if ring_find($aStzDocOwnLow[ pnaChain[_k_] ], pcLow) > 0
			return pnaChain[_k_]
		ok
	next
	return 0

# pcName = root + extensions, the extensions SPELLED AS WRITTEN (FindCS, not
# Findcs: a trailing d or s is a word, not the D or S extension).
# Returns [ rootAsWritten, [ codes ] ] or [ ].
func _StzDocSplitExt(pcName, pnaChain)
	_nE_ = len($aStzDocExt)
	_nN_ = len(pcName)
	for _t_ = 1 to _nE_
		_cW_ = $aStzDocExt[_t_][2]
		_nW_ = len(_cW_)
		if _nN_ - _nW_ >= 2 and right(pcName, _nW_) = _cW_
			_cRem_ = left(pcName, _nN_ - _nW_)
			_aR_ = _StzDocSplitExt(_cRem_, pnaChain)
			if len(_aR_) > 0
				_aCodes_ = _aR_[2]
				_aCodes_ + $aStzDocExt[_t_][1]
				return [ _aR_[1], _aCodes_ ]
			ok
			if _StzDocInChain(pnaChain, lower(_cRem_)) > 0
				return [ _cRem_, [ $aStzDocExt[_t_][1] ] ]
			ok
		ok
	next
	return []

func _StzDocExtAdds(pcCode)
	_n_ = len($aStzDocExt)
	for _i_ = 1 to _n_
		if $aStzDocExt[_i_][1] = pcCode
			return $aStzDocExt[_i_][3]
		ok
	next
	return ""

# --- ancestors --------------------------------------------------------------
# indexes of the class itself and its ancestors (nearest first)
func _StzDocChainIdx(pnIdx)
	_a_ = [ pnIdx ]
	_nG_ = 0
	_i_ = pnIdx
	while _nG_ < 15
		_nG_++
		_cP_ = lower($aStzDocCls[_i_][3])
		if _cP_ = ""
			exit
		ok
		_j_ = ring_find($aStzDocClsLow, _cP_)
		if _j_ = 0 or ring_find(_a_, _j_) > 0
			exit
		ok
		_a_ + _j_
		_i_ = _j_
	end
	return _a_

# --- one root method, as JSON ----------------------------------------------
# paRoot is the method record; paExts = [ [ name, codes, params ], ... ];
# pacAliases = other names of the method. Returns
# [ json, briefOrigin, pass, passWritten, hasExample, hasReturns ].
func _StzDocRootJson(pcClass, paRoot, paExts, pacAliases, pcPassive)
	_cName_ = paRoot[:name]
	_aF_ = paRoot[:fields]
	_aPar_ = paRoot[:params]
	# brief
	_cBrief_ = paRoot[:brief]
	_cBo_ = "none"
	if _cBrief_ != ""
		_cBo_ = "written"
	else
		_aPr_ = _StzDocPredicate(_cName_)
		if len(_aPr_) = 2
			_cBrief_ = "TRUE if the object " + _aPr_[1] + " " + _aPr_[2] + "."
			_cBo_ = "derived"
		ok
	ok
	# usage: the root, the written forms, then each extension form
	_acUse_ = []
	_cSig_ = _cName_ + "("
	_nP_ = len(_aPar_)
	for _i_ = 1 to _nP_
		if _i_ > 1
			_cSig_ += ", "
		ok
		_cSig_ += _aPar_[_i_]
	next
	_acUse_ + (_cSig_ + ")")
	_acForms_ = _StzDocFieldList(_aF_, "forms")
	_nFo_ = len(_acForms_)
	for _i_ = 1 to _nFo_
		_acUse_ + _acForms_[_i_]
	next
	_nX_ = len(paExts)
	for _i_ = 1 to _nX_
		_cS2_ = paExts[_i_][1] + "("
		_aP2_ = paExts[_i_][3]
		_nP2_ = len(_aP2_)
		for _k_ = 1 to _nP2_
			if _k_ > 1
				_cS2_ += ", "
			ok
			_cS2_ += _aP2_[_k_]
		next
		_acUse_ + (_cS2_ + ")")
	next
	# parameters: written, else the glossary, else nothing
	_cParJ_ = "["
	_nCovered_ = 0
	for _i_ = 1 to _nP_
		_cPn_ = _aPar_[_i_]
		_cRole_ = ""
		_cOr_ = "none"
		_nFf_ = len(_aF_)
		for _k_ = 1 to _nFf_
			if _aF_[_k_][1] = "param" and lower(_aF_[_k_][2]) = lower(_cPn_) and _aF_[_k_][3] != ""
				_cRole_ = _aF_[_k_][3]
				_cOr_ = "written"
				exit
			ok
		next
		if _cRole_ = ""
			_nG_ = ring_find($aStzDocGlossName, lower(_cPn_))
			if _nG_ > 0
				_cRole_ = $aStzDocGlossRole[_nG_]
				_cOr_ = "derived"
			ok
		ok
		if _cRole_ != ""
			_nCovered_++
		ok
		if _i_ > 1
			_cParJ_ += ","
		ok
		_cParJ_ += "{" + char(34) + "name" + char(34) + ":" + _StzDocJs(_cPn_) + "," +
		           char(34) + "type" + char(34) + ":" + _StzDocJs(_StzDocParamType(_cPn_))
		if _cRole_ != ""
			_cParJ_ += "," + char(34) + "role" + char(34) + ":" + _StzDocJs(_cRole_) + "," +
			           char(34) + "origin" + char(34) + ":" + _StzDocJs(_cOr_)
		ok
		_cParJ_ += "}"
	next
	_cParJ_ += "]"
	# returns: written, else derived from the name or the body
	_cRet_ = _StzDocFieldText(_aF_, "returns")
	_cRo_ = "none"
	if _cRet_ != ""
		_cRo_ = "written"
	else
		if len(_StzDocPredicate(_cName_)) = 2
			_cRet_ = "TRUE or FALSE."
			_cRo_ = "derived"
		but NOT paRoot[:hasreturn]
			_cRet_ = "Nothing."
			_cRo_ = "derived"
		but _StzDocIsCountName(_cName_)
			# NumberOfX and HowManyX answer a count: true of every such method of the
			# four pilot classes, checked by running them
			_cRet_ = "a number."
			_cRo_ = "derived"
		ok
	ok
	# example, promises, notes, see
	_cEx_ = _StzDocFieldText2(_aF_, "example")
	_acNotes_ = _StzDocFieldList(_aF_, "note")
	_acWarn_ = _StzDocFieldList(_aF_, "warning")
	_acSee_ = _StzDocSplitComma(_StzDocFieldText(_aF_, "see"))
	_cSince_ = _StzDocFieldText(_aF_, "since")
	_cStat_ = _StzDocFieldText(_aF_, "status")
	_cSo_ = "written"
	if _cStat_ = ""
		_cSo_ = "derived"
		_cStat_ = "stable"
		_cLn_ = lower(_cName_)
		if left(_cLn_, 3) = "pvt" and len(_cLn_) > 3
			_cStat_ = "internal"
		ok
	ok
	_cDet_ = _StzDocFieldText(_aF_, "detour")
	_cDo_ = "written"
	if _cDet_ = "" and len(_cName_) > 3 and left(_cName_, 3) = "IsA"
		_cNat_ = ""
		if len(_cName_) > 4 and left(_cName_, 4) = "IsAn" and _cName_[5] != lower(_cName_[5])
			_cNat_ = "Is" + right(_cName_, len(_cName_) - 4)
		but _cName_[4] != lower(_cName_[4])
			_cNat_ = "Is" + right(_cName_, len(_cName_) - 3)
		ok
		if _cNat_ != "" and _StzDocIsHostCollision(lower(_cNat_))
			_cDet_ = _cNat_
			_cDo_ = "derived"
		ok
	ok
	# the checks
	_nC1_ = _StzDocBriefForm(_cBrief_)
	_nC2_ = 0
	if _cBrief_ != ""
		_nC2_ = 1 - _StzDocBriefRestates(_cBrief_, _cName_)
	ok
	_nC3_ = (_nCovered_ = _nP_)
	_nC4_ = (_cRet_ != "")
	_nC5_ = (_cEx_ != "")
	_nPass_ = (_nC1_ and _nC2_ and _nC3_ and _nC4_)
	_nPassW_ = (_nPass_ and _cBo_ = "written")
	# the JSON
	_q_ = char(34)
	_c_ = "{" + _q_ + "key" + _q_ + ":" + _StzDocJs(lower(pcClass) + "." + lower(_cName_)) +
	      "," + _q_ + "name" + _q_ + ":" + _StzDocJs(_cName_) +
	      "," + _q_ + "line" + _q_ + ":" + paRoot[:line]
	if paRoot[:section] != ""
		_c_ += "," + _q_ + "section" + _q_ + ":" + _StzDocJs(paRoot[:section])
	ok
	if _cBrief_ != ""
		_c_ += "," + _q_ + "brief" + _q_ + ":" + _StzDocJs(_cBrief_)
	ok
	if paRoot[:para] != ""
		_c_ += "," + _q_ + "detail" + _q_ + ":" + _StzDocJs(paRoot[:para])
	ok
	_c_ += "," + _q_ + "usage" + _q_ + ":" + _StzDocJList(_acUse_)
	_c_ += "," + _q_ + "parameters" + _q_ + ":" + _cParJ_
	if _cRet_ != ""
		_c_ += "," + _q_ + "returns" + _q_ + ":" + _StzDocJs(_cRet_)
	ok
	if len(_acNotes_) > 0
		_c_ += "," + _q_ + "notes" + _q_ + ":" + _StzDocJList(_acNotes_)
	ok
	if len(_acWarn_) > 0
		_c_ += "," + _q_ + "warnings" + _q_ + ":" + _StzDocJList(_acWarn_)
	ok
	if len(_acSee_) > 0
		_c_ += "," + _q_ + "see" + _q_ + ":" + _StzDocJList(_acSee_)
	ok
	if _cEx_ != ""
		_c_ += "," + _q_ + "example" + _q_ + ":" + _StzDocJs(_cEx_)
		_acPm_ = _StzDocPromises(_cEx_)
		if len(_acPm_) > 0
			_c_ += "," + _q_ + "promises" + _q_ + ":" + _StzDocJList(_acPm_)
		ok
	ok
	if _nX_ > 0
		_c_ += "," + _q_ + "extensions" + _q_ + ":["
		for _i_ = 1 to _nX_
			if _i_ > 1
				_c_ += ","
			ok
			_cCodes_ = ""
			_cAdds_ = ""
			_nCd_ = len(paExts[_i_][2])
			for _k_ = 1 to _nCd_
				_cCodes_ += paExts[_i_][2][_k_]
				if _k_ > 1
					_cAdds_ += "; "
				ok
				_cAdds_ += _StzDocExtAdds(paExts[_i_][2][_k_])
			next
			_c_ += "{" + _q_ + "name" + _q_ + ":" + _StzDocJs(paExts[_i_][1]) + "," +
			       _q_ + "code" + _q_ + ":" + _StzDocJs(_cCodes_) + "," +
			       _q_ + "adds" + _q_ + ":" + _StzDocJs(_cAdds_) + "}"
		next
		_c_ += "]"
	ok
	if len(pacAliases) > 0
		_c_ += "," + _q_ + "aliases" + _q_ + ":" + _StzDocJList(pacAliases)
	ok
	if len(_acForms_) > 0
		_c_ += "," + _q_ + "forms" + _q_ + ":" + _StzDocJList(_acForms_)
	ok
	if pcPassive != ""
		_c_ += "," + _q_ + "passive" + _q_ + ":" + _StzDocJs(pcPassive)
	ok
	if _cSince_ != ""
		_c_ += "," + _q_ + "since" + _q_ + ":" + _StzDocJs(_cSince_)
	ok
	_c_ += "," + _q_ + "status" + _q_ + ":" + _StzDocJs(_cStat_)
	if _cDet_ != ""
		_c_ += "," + _q_ + "detour" + _q_ + ":" + _StzDocJs(_cDet_)
	ok
	_c_ += "," + _q_ + "origin" + _q_ + ":{" + _q_ + "brief" + _q_ + ":" + _StzDocJs(_cBo_) +
	       "," + _q_ + "returns" + _q_ + ":" + _StzDocJs(_cRo_) +
	       "," + _q_ + "status" + _q_ + ":" + _StzDocJs(_cSo_)
	if _cDet_ != ""
		_c_ += "," + _q_ + "detour" + _q_ + ":" + _StzDocJs(_cDo_)
	ok
	_c_ += "}"
	_c_ += "," + _q_ + "checks" + _q_ + ":[" + _nC1_ + "," + _nC2_ + "," + _nC3_ + "," + _nC4_ + "," + _nC5_ + "]"
	_c_ += "," + _q_ + "pass" + _q_ + ":" + _nPass_ + "}"
	return [ _c_, _cBo_, _nPass_, _nPassW_, _nC5_, (_cRet_ != "") ]

# an example keeps its lines
func _StzDocFieldText2(paFields, pcKind)
	_c_ = ""
	_n_ = len(paFields)
	for _i_ = 1 to _n_
		if paFields[_i_][1] = pcKind and paFields[_i_][3] != ""
			if _c_ != ""
				_c_ += char(10)
			ok
			_c_ += paFields[_i_][3]
		ok
	next
	return _c_

# --- the export --------------------------------------------------------------
func StzReferenceExport(pcBase, pcOut, pcCommit, pcDate)
	return StzReferenceExportOnly(pcBase, pcOut, pcCommit, pcDate, [])

# paOnly = [] exports every class; else only the named ones (their ancestors
# are scanned too, for the chain, but not written).
# PASS 1 -- scan the library (or the wanted classes and their ancestors) into
# the working globals. Returns [ wanted indexes, need flags, records, class
# blocks, empty flags, scan ms ].
func _StzDocPass1(pcBase, pacOnly)
	_t0_ = clock()
	$aStzDocExt = _StzDocExtensions()
	_StzDocLoadGlossary(pcBase)
	$aStzDocCls = _StzDocScanLibrary(pcBase)
	_nC_ = len($aStzDocCls)
	$aStzDocClsLow = []
	for _i_ = 1 to _nC_
		$aStzDocClsLow + lower($aStzDocCls[_i_][1])
	next
	# which classes to scan: the wanted ones and all their ancestors
	_aNeed_ = _StzDocList(_nC_)
	for _i_ = 1 to _nC_
		_aNeed_[_i_] = 0
	next
	_aOut_ = []
	if len(pacOnly) = 0
		for _i_ = 1 to _nC_
			_aNeed_[_i_] = 1
			_aOut_ + _i_
		next
	else
		_nO_ = len(pacOnly)
		for _k_ = 1 to _nO_
			_j_ = ring_find($aStzDocClsLow, lower(pacOnly[_k_]))
			if _j_ > 0
				_aOut_ + _j_
				_aCh_ = _StzDocChainIdx(_j_)
				_nCh_ = len(_aCh_)
				for _m_ = 1 to _nCh_
					_aNeed_[_aCh_[_m_]] = 1
				next
			ok
		next
	ok
	# pass 1: the records of every needed class
	$aStzDocOwnLow = _StzDocList(_nC_)
	_aRecs_ = _StzDocList(_nC_)
	_aBlock_ = _StzDocList(_nC_)
	_aEmpty_ = _StzDocList(_nC_)
	_cLastFile_ = ""
	_aLines_ = []
	for _i_ = 1 to _nC_
		$aStzDocOwnLow[_i_] = []
		_aRecs_[_i_] = []
		_aBlock_[_i_] = []
		_aEmpty_[_i_] = 0
		if NOT _aNeed_[_i_]
			loop
		ok
		_cF_ = $aStzDocCls[_i_][2]
		if _cF_ != _cLastFile_
			_aLines_ = _StzDocLines(pcBase + "/" + _cF_)
			_cLastFile_ = _cF_
		ok
		_aRecs_[_i_] = _StzDocScanRange(_aLines_, $aStzDocCls[_i_][4] + 1, $aStzDocCls[_i_][5])
		_aBlock_[_i_] = _StzDocClassBlock(_aLines_, $aStzDocCls[_i_][4])
		_nR_ = len(_aRecs_[_i_])
		_aLow_ = []
		for _k_ = 1 to _nR_
			_aLow_ + lower(_aRecs_[_i_][_k_][:name])
		next
		$aStzDocOwnLow[_i_] = _aLow_
		_aEmpty_[_i_] = _StzDocClassEmpty(_aLines_, $aStzDocCls[_i_][4] + 1, $aStzDocCls[_i_][5])
	next
	_tScan_ = floor((clock() - _t0_) * 1000 / clockspersecond())
	return [ _aOut_, _aNeed_, _aRecs_, _aBlock_, _aEmpty_, _tScan_ ]

func StzReferenceExportOnly(pcBase, pcOut, pcCommit, pcDate, pacOnly)
	_t0_ = clock()
	_aP1_ = _StzDocPass1(pcBase, pacOnly)
	_aOut_ = _aP1_[1]
	_aNeed_ = _aP1_[2]
	_aRecs_ = _aP1_[3]
	_aBlock_ = _aP1_[4]
	_aEmpty_ = _aP1_[5]
	_tScan_ = _aP1_[6]
	_nC_ = len($aStzDocCls)
	# class aliases: an empty subclass is another name of its parent (to the end)
	_acAliasRoot_ = _StzDocList(_nC_)
	for _i_ = 1 to _nC_
		_acAliasRoot_[_i_] = ""
		if _aNeed_[_i_] and _aEmpty_[_i_] and $aStzDocCls[_i_][3] != ""
			_j_ = _i_
			_nG_ = 0
			while _nG_ < 8
				_nG_++
				_p_ = ring_find($aStzDocClsLow, lower($aStzDocCls[_j_][3]))
				if _p_ = 0
					exit
				ok
				_j_ = _p_
				if NOT (_aNeed_[_j_] and _aEmpty_[_j_] and $aStzDocCls[_j_][3] != "")
					exit
				ok
			end
			if _j_ != _i_
				_acAliasRoot_[_i_] = $aStzDocCls[_j_][1]
			ok
		ok
	next
	# sort the classes to write by lowercase name
	_aSort_ = []
	_nW_ = len(_aOut_)
	for _k_ = 1 to _nW_
		_aSort_ + [ $aStzDocClsLow[_aOut_[_k_]], _aOut_[_k_] ]
	next
	_aSort_ = sort(_aSort_, 1)
	# the file
	_q_ = char(34)
	_fp_ = fopen(pcOut, "wb")
	fwrite(_fp_, "{" + _q_ + "schema" + _q_ + ":1," + _q_ + "generator" + _q_ + ":" + _q_ + "stzDocRecord" + _q_ +
	             "," + _q_ + "commit" + _q_ + ":" + _StzDocJs(pcCommit) +
	             "," + _q_ + "date" + _q_ + ":" + _StzDocJs(pcDate) + "," + char(10))
	fwrite(_fp_, _q_ + "extensions" + _q_ + ":[")
	_nE_ = len($aStzDocExt)
	for _i_ = 1 to _nE_
		if _i_ > 1
			fwrite(_fp_, ",")
		ok
		fwrite(_fp_, "{" + _q_ + "code" + _q_ + ":" + _StzDocJs($aStzDocExt[_i_][2]) + "," +
		             _q_ + "adds" + _q_ + ":" + _StzDocJs($aStzDocExt[_i_][3]) + "}")
	next
	fwrite(_fp_, "]," + char(10) + _q_ + "classes" + _q_ + ":[" + char(10))
	_nTotRoots_ = 0
	_nTotWritten_ = 0
	_nTotDerived_ = 0
	_nTotPass_ = 0
	_nTotPassW_ = 0
	_nTotEx_ = 0
	_nTotNames_ = 0
	_nTotAliases_ = 0
	_nTotExt_ = 0
	for _s_ = 1 to _nW_
		_i_ = _aSort_[_s_][2]
		_aRes_ = _StzDocClassJson(_i_, _aRecs_, _aBlock_, _acAliasRoot_, _aNeed_, _fp_, _s_ = 1)
		_nTotRoots_ += _aRes_[1]
		_nTotWritten_ += _aRes_[2]
		_nTotDerived_ += _aRes_[3]
		_nTotPass_ += _aRes_[4]
		_nTotPassW_ += _aRes_[5]
		_nTotEx_ += _aRes_[6]
		_nTotNames_ += _aRes_[7]
		_nTotAliases_ += _aRes_[8]
		_nTotExt_ += _aRes_[9]
	next
	fwrite(_fp_, char(10) + "]," + char(10) + _q_ + "summary" + _q_ + ":{" +
	             _q_ + "classes" + _q_ + ":" + _nW_ + "," +
	             _q_ + "roots" + _q_ + ":" + _nTotRoots_ + "," +
	             _q_ + "names" + _q_ + ":" + _nTotNames_ + "," +
	             _q_ + "aliases" + _q_ + ":" + _nTotAliases_ + "," +
	             _q_ + "extension_forms" + _q_ + ":" + _nTotExt_ + "," +
	             _q_ + "brief_written" + _q_ + ":" + _nTotWritten_ + "," +
	             _q_ + "brief_derived" + _q_ + ":" + _nTotDerived_ + "," +
	             _q_ + "pass" + _q_ + ":" + _nTotPass_ + "," +
	             _q_ + "pass_written" + _q_ + ":" + _nTotPassW_ + "," +
	             _q_ + "with_example" + _q_ + ":" + _nTotEx_ + "}}" + char(10))
	fclose(_fp_)
	return [ :classes = _nW_, :roots = _nTotRoots_, :names = _nTotNames_,
	         :aliases = _nTotAliases_, :extension_forms = _nTotExt_,
	         :brief_written = _nTotWritten_, :brief_derived = _nTotDerived_,
	         :pass = _nTotPass_, :pass_written = _nTotPassW_,
	         :with_example = _nTotEx_, :scan_ms = _tScan_,
	         :total_ms = floor((clock() - _t0_) * 1000 / clockspersecond()) ]

# TRUE when a class body has no code and no def: only comments and blanks
func _StzDocClassEmpty(pacLines, pnStart, pnEnd)
	for _i_ = pnStart to pnEnd
		_c_ = ring_trim(pacLines[_i_])
		if _c_ != "" and left(_c_, 1) != "#"
			return 0
		ok
	next
	return 1

# One class as JSON, streamed to the open file. Returns
# [ roots, written, derived, pass, passWritten, withExample, names, aliases, extForms ].
func _StzDocClassJson(pnIdx, paRecs, paBlock, pacAliasRoot, paNeed, pfp, pbFirst)
	_q_ = char(34)
	_cName_ = $aStzDocCls[pnIdx][1]
	_aChain_ = _StzDocChainIdx(pnIdx)
	_nRec_ = len(paRecs[pnIdx])
	# classify every own PUBLIC name: 0 root, 1 extension, 2 alias
	_aKind_ = _StzDocList(_nRec_)
	_aRootOf_ = _StzDocList(_nRec_)
	_aCodes_ = _StzDocList(_nRec_)
	for _k_ = 1 to _nRec_
		_aKind_[_k_] = -1
		_aRootOf_[_k_] = ""
		_aCodes_[_k_] = []
		_cN_ = paRecs[pnIdx][_k_][:name]
		if left(_cN_, 1) = "_"
			loop
		ok
		_aKind_[_k_] = 0
		_aSp_ = _StzDocSplitExt(_cN_, _aChain_)
		if len(_aSp_) > 0
			_aKind_[_k_] = 1
			_aRootOf_[_k_] = lower(_aSp_[1])
			_aCodes_[_k_] = _aSp_[2]
		but paRecs[pnIdx][_k_][:fwdpure]
			_aKind_[_k_] = 2
			_aRootOf_[_k_] = lower(paRecs[pnIdx][_k_][:fwd])
		ok
	next
	_aLow_ = $aStzDocOwnLow[pnIdx]
	# resolve aliases and extension roots to a final own root (index), following alias hops
	_aFinal_ = _StzDocList(_nRec_)
	for _k_ = 1 to _nRec_
		_aFinal_[_k_] = 0
		if _aKind_[_k_] = 0
			_aFinal_[_k_] = _k_
		but _aKind_[_k_] > 0
			_cT_ = _aRootOf_[_k_]
			_nHop_ = 0
			_nHit_ = 0
			while _nHop_ < 8
				_nHop_++
				_nT_ = ring_find(_aLow_, _cT_)
				if _nT_ = 0
					exit
				ok
				if _aKind_[_nT_] = 0
					_nHit_ = _nT_
					exit
				but _aKind_[_nT_] = 2
					_cT_ = _aRootOf_[_nT_]
				else
					_cT_ = _aRootOf_[_nT_]
				ok
			end
			_aFinal_[_k_] = _nHit_
		ok
	next
	# group
	_aExts_ = _StzDocList(_nRec_)
	_aAls_ = _StzDocList(_nRec_)
	for _k_ = 1 to _nRec_
		_aExts_[_k_] = []
		_aAls_[_k_] = []
	next
	_aForeign_ = []
	_aInhExt_ = []
	_nExtForms_ = 0
	_nAliasNames_ = 0
	for _k_ = 1 to _nRec_
		if _aKind_[_k_] = 1
			if _aFinal_[_k_] > 0
				_aExts_[_aFinal_[_k_]] + [ paRecs[pnIdx][_k_][:name], _aCodes_[_k_], paRecs[pnIdx][_k_][:params] ]
				_nExtForms_++
			else
				_aInhExt_ + [ paRecs[pnIdx][_k_][:name], _aRootOf_[_k_] ]
			ok
		but _aKind_[_k_] = 2
			if _aFinal_[_k_] > 0
				_aAls_[_aFinal_[_k_]] + paRecs[pnIdx][_k_][:name]
				_nAliasNames_++
			else
				_aForeign_ + [ paRecs[pnIdx][_k_][:name], paRecs[pnIdx][_k_][:fwd] ]
			ok
		ok
	next
	# the roots, in source order
	_acRootJson_ = []
	_acSecT_ = []
	_aSecM_ = []
	_nRoots_ = 0
	_nWr_ = 0
	_nDr_ = 0
	_nPs_ = 0
	_nPw_ = 0
	_nEx_ = 0
	for _k_ = 1 to _nRec_
		if _aKind_[_k_] != 0
			loop
		ok
		_nRoots_++
		_cNm_ = paRecs[pnIdx][_k_][:name]
		_cPassive_ = ""
		_cLn_ = lower(_cNm_)
		if len(_StzDocPredicate(_cNm_)) = 0 and right(_cLn_, 2) != "ed"
			_nPa_ = ring_find(_aLow_, _cLn_ + "ed")
			if _nPa_ = 0 and right(_cLn_, 1) = "e"
				_nPa_ = ring_find(_aLow_, _cLn_ + "d")
			ok
			if _nPa_ > 0 and _aKind_[_nPa_] = 0
				_cPassive_ = paRecs[pnIdx][_nPa_][:name]
			ok
		ok
		_aRj_ = _StzDocRootJson(_cName_, paRecs[pnIdx][_k_], _aExts_[_k_], _aAls_[_k_], _cPassive_)
		_acRootJson_ + _aRj_[1]
		if _aRj_[2] = "written"
			_nWr_++
		but _aRj_[2] = "derived"
			_nDr_++
		ok
		_nPs_ += _aRj_[3]
		_nPw_ += _aRj_[4]
		_nEx_ += _aRj_[5]
		_cSec_ = paRecs[pnIdx][_k_][:section]
		_nS_ = ring_find(_acSecT_, _cSec_)
		if _nS_ = 0
			_acSecT_ + _cSec_
			_aSecM_ + [ _cNm_ ]
		else
			_aSecM_[_nS_] + _cNm_
		ok
	next
	# the class header
	_aB_ = paBlock[pnIdx]
	_aFb_ = _aB_[3]
	if NOT pbFirst
		fwrite(pfp, "," + char(10))
	ok
	_c_ = "{" + _q_ + "name" + _q_ + ":" + _StzDocJs(_cName_) +
	      "," + _q_ + "file" + _q_ + ":" + _StzDocJs($aStzDocCls[pnIdx][2]) +
	      "," + _q_ + "line" + _q_ + ":" + $aStzDocCls[pnIdx][4]
	if $aStzDocCls[pnIdx][3] != ""
		_c_ += "," + _q_ + "parent" + _q_ + ":" + _StzDocJs($aStzDocCls[pnIdx][3])
	ok
	_acAnc_ = []
	_nCh_ = len(_aChain_)
	for _m_ = 2 to _nCh_
		_acAnc_ + $aStzDocCls[_aChain_[_m_]][1]
	next
	if len(_acAnc_) > 0
		_c_ += "," + _q_ + "ancestors" + _q_ + ":" + _StzDocJList(_acAnc_)
	ok
	if pacAliasRoot[pnIdx] != ""
		_c_ += "," + _q_ + "alias_of" + _q_ + ":" + _StzDocJs(pacAliasRoot[pnIdx])
	ok
	if _aB_[1] != ""
		_c_ += "," + _q_ + "brief" + _q_ + ":" + _StzDocJs(_aB_[1])
	ok
	if _aB_[2] != ""
		_c_ += "," + _q_ + "description" + _q_ + ":" + _StzDocJs(_aB_[2])
	ok
	_cRc_ = _StzDocFieldText2(_aFb_, "receiver")
	if _cRc_ != ""
		_c_ += "," + _q_ + "receiver" + _q_ + ":" + _StzDocJs(_cRc_)
	ok
	_cEx_ = _StzDocFieldText2(_aFb_, "example")
	if _cEx_ != ""
		_c_ += "," + _q_ + "example" + _q_ + ":" + _StzDocJs(_cEx_)
	ok
	_acSee_ = _StzDocSplitComma(_StzDocFieldText(_aFb_, "see"))
	if len(_acSee_) > 0
		_c_ += "," + _q_ + "see" + _q_ + ":" + _StzDocJList(_acSee_)
	ok
	_cSn_ = _StzDocFieldText(_aFb_, "since")
	if _cSn_ != ""
		_c_ += "," + _q_ + "since" + _q_ + ":" + _StzDocJs(_cSn_)
	ok
	_cSt_ = _StzDocFieldText(_aFb_, "status")
	if _cSt_ != ""
		_c_ += "," + _q_ + "status" + _q_ + ":" + _StzDocJs(_cSt_)
	ok
	# sections
	_c_ += "," + _q_ + "sections" + _q_ + ":["
	_nSc_ = len(_acSecT_)
	for _m_ = 1 to _nSc_
		if _m_ > 1
			_c_ += ","
		ok
		_c_ += "{" + _q_ + "title" + _q_ + ":" + _StzDocJs(_acSecT_[_m_]) + "," +
		       _q_ + "members" + _q_ + ":" + _StzDocJList(_aSecM_[_m_]) + "}"
	next
	_c_ += "]"
	# the other names of the class (empty subclasses that point here) are written
	# on the ROOT class by the caller's index; here, the class's own foreign data
	if len(_aForeign_) > 0
		_c_ += "," + _q_ + "forwards" + _q_ + ":["
		_nFg_ = len(_aForeign_)
		for _m_ = 1 to _nFg_
			if _m_ > 1
				_c_ += ","
			ok
			_c_ += "{" + _q_ + "name" + _q_ + ":" + _StzDocJs(_aForeign_[_m_][1]) + "," +
			       _q_ + "to" + _q_ + ":" + _StzDocJs(_aForeign_[_m_][2]) + "}"
		next
		_c_ += "]"
	ok
	if len(_aInhExt_) > 0
		_c_ += "," + _q_ + "inherited_extensions" + _q_ + ":["
		_nIe_ = len(_aInhExt_)
		for _m_ = 1 to _nIe_
			if _m_ > 1
				_c_ += ","
			ok
			_c_ += "{" + _q_ + "name" + _q_ + ":" + _StzDocJs(_aInhExt_[_m_][1]) + "," +
			       _q_ + "root" + _q_ + ":" + _StzDocJs(_aInhExt_[_m_][2]) + "}"
		next
		_c_ += "]"
	ok
	_c_ += "," + _q_ + "summary" + _q_ + ":{" + _q_ + "roots" + _q_ + ":" + _nRoots_ + "," +
	       _q_ + "brief_written" + _q_ + ":" + _nWr_ + "," +
	       _q_ + "brief_derived" + _q_ + ":" + _nDr_ + "," +
	       _q_ + "pass" + _q_ + ":" + _nPs_ + "," +
	       _q_ + "pass_written" + _q_ + ":" + _nPw_ + "," +
	       _q_ + "with_example" + _q_ + ":" + _nEx_ + "," +
	       _q_ + "alias_names" + _q_ + ":" + _nAliasNames_ + "," +
	       _q_ + "extension_forms" + _q_ + ":" + _nExtForms_ + "}"
	_c_ += "," + _q_ + "methods" + _q_ + ":[" + char(10)
	fwrite(pfp, _c_)
	for _k_ = 1 to _nRoots_
		if _k_ > 1
			fwrite(pfp, "," + char(10))
		ok
		fwrite(pfp, _acRootJson_[_k_])
	next
	fwrite(pfp, char(10) + "]}")
	_nNames_ = _nRoots_ + _nExtForms_ + _nAliasNames_
	return [ _nRoots_, _nWr_, _nDr_, _nPs_, _nPw_, _nEx_, _nNames_, _nAliasNames_, _nExtForms_ ]

# --- the findings: what the extractor can see that a reader should not ----
# Unified rule shape [ :rule, :subject, :where, :severity, :message ]:
#   doc-dead-forward     a public name forwards to a method no class of its chain defines
#   doc-internal-shown   a pvt* name, public by position, not marked `status internal`
#   doc-typo-word        a CamelCase word used once or twice, one edit from a word used
#                        eight times or more (reviewed words: base/doc/typo-reviewed.txt)
func StzDocFindings(pcBase)
	_aP1_ = _StzDocPass1(pcBase, [])
	_aRecs_ = _aP1_[3]
	_nC_ = len($aStzDocCls)
	_aOut_ = []
	_aPairs_ = []     # "word<TAB>Class.Name" -- one per word per public name (flat strings: Ring's sort of pairs is quadratic)
	for _i_ = 1 to _nC_
		_aChain_ = _StzDocChainIdx(_i_)
		_nR_ = len(_aRecs_[_i_])
		for _k_ = 1 to _nR_
			_cN_ = _aRecs_[_i_][_k_][:name]
			if left(_cN_, 1) = "_"
				loop
			ok
			_cWhere_ = $aStzDocCls[_i_][2] + ":" + _aRecs_[_i_][_k_][:line]
			_cSubj_ = $aStzDocCls[_i_][1] + "." + _cN_
			_cF_ = _aRecs_[_i_][_k_][:fwd]
			if _cF_ != "" and _StzDocInChain(_aChain_, lower(_cF_)) = 0
				_aOut_ + [ :rule = "doc-dead-forward", :subject = _cSubj_, :where = _cWhere_,
				           :severity = "error",
				           :message = _cN_ + "() forwards to " + _cF_ + "(), which no class of its chain defines: calling it raises" ]
			ok
			_cLn_ = lower(_cN_)
			if len(_cLn_) > 3 and left(_cLn_, 3) = "pvt"
				if _StzDocFieldText(_aRecs_[_i_][_k_][:fields], "status") != "internal"
					_aOut_ + [ :rule = "doc-internal-shown", :subject = _cSubj_, :where = _cWhere_,
					           :severity = "warning",
					           :message = _cN_ + "() reads as an internal helper (pvt) but is public and not marked `status internal`" ]
				ok
			ok
			_aWd_ = _StzDocNameWordsRaw(_cN_)
			_nW_ = len(_aWd_)
			_acSeenW_ = []
			for _m_ = 1 to _nW_
				_cWd_ = _aWd_[_m_]
				# a real word: letters only, not an acronym or an extension code
				if len(_cWd_) < 3 or not _StzDocAllLetters(_cWd_) or (_cWd_ = upper(_cWd_) and len(_cWd_) > 1)
					loop
				ok
				_cWd_ = lower(_cWd_)
				if ring_find(_acSeenW_, _cWd_) = 0
					_acSeenW_ + _cWd_
					_aPairs_ + (_cWd_ + char(9) + _cSubj_)
				ok
			next
		next
	next
	_aT_ = _StzDocTypoFindings(_aPairs_, pcBase)
	_nT_ = len(_aT_)
	for _i_ = 1 to _nT_
		_aOut_ + _aT_[_i_]
	next
	return _aOut_

# one edit (substitution, insertion, deletion) or one transposition apart
func _StzDocDam1(pcA, pcB)
	if pcA = pcB
		return 0
	ok
	_la_ = len(pcA)
	_lb_ = len(pcB)
	if _la_ - _lb_ > 1 or _lb_ - _la_ > 1
		return 0
	ok
	if _la_ = _lb_
		_nDiff_ = 0
		_nF_ = 0
		_nS_ = 0
		for _i_ = 1 to _la_
			if pcA[_i_] != pcB[_i_]
				_nDiff_++
				if _nDiff_ = 1
					_nF_ = _i_
				but _nDiff_ = 2
					_nS_ = _i_
				else
					return 0
				ok
			ok
		next
		if _nDiff_ = 1
			return 1
		ok
		if _nDiff_ = 2 and _nS_ = _nF_ + 1 and pcA[_nF_] = pcB[_nS_] and pcA[_nS_] = pcB[_nF_]
			return 1
		ok
		return 0
	ok
	_cL_ = pcA
	_cS_ = pcB
	if _la_ < _lb_
		_cL_ = pcB
		_cS_ = pcA
	ok
	_nSl_ = len(_cS_)
	_i_ = 1
	while _i_ <= _nSl_ and _cL_[_i_] = _cS_[_i_]
		_i_++
	end
	for _k_ = _i_ to _nSl_
		if _cL_[_k_ + 1] != _cS_[_k_]
			return 0
		ok
	next
	return 1

# an inflection of the same word is not a typo (item/items, move/moved...)
func _StzDocInflection(pcA, pcB)
	_cL_ = pcA
	_cS_ = pcB
	if len(pcA) < len(pcB)
		_cL_ = pcB
		_cS_ = pcA
	ok
	if left(_cL_, len(_cS_)) != _cS_
		return 0
	ok
	_cTail_ = right(_cL_, len(_cL_) - len(_cS_))
	return ring_find([ "s", "es", "d", "ed", "ing", "er", "ers", "ly", "y", "al" ], _cTail_) > 0

func _StzDocTypoFindings(paPairs, pcBase)
	_aOut_ = []
	_aPairs_ = sort(paPairs)
	_nP_ = len(_aPairs_)
	_acReviewed_ = []
	_cRev_ = pcBase + "/doc/typo-reviewed.txt"
	if fexists(_cRev_)
		_aRl_ = _StzDocLines(_cRev_)
		_nRl_ = len(_aRl_)
		for _i_ = 1 to _nRl_
			_c_ = lower(ring_trim(_aRl_[_i_]))
			if _c_ != "" and left(_c_, 1) != "#"
				_acReviewed_ + _c_
			ok
		next
	ok
	# run-length: distinct words, counts, one owner each
	_acW_ = []
	_anC_ = []
	_acO_ = []
	_acWk_ = _StzDocList(_nP_)
	for _i_ = 1 to _nP_
		_nTab_ = substr(_aPairs_[_i_], char(9))
		_acWk_[_i_] = left(_aPairs_[_i_], _nTab_ - 1)
	next
	_i_ = 1
	while _i_ <= _nP_
		_cW_ = _acWk_[_i_]
		_j_ = _i_
		while _j_ < _nP_ and _acWk_[_j_ + 1] = _cW_
			_j_++
		end
		_acW_ + _cW_
		_anC_ + (_j_ - _i_ + 1)
		_nTab_ = substr(_aPairs_[_i_], char(9))
		_acO_ + right(_aPairs_[_i_], len(_aPairs_[_i_]) - _nTab_)
		_i_ = _j_ + 1
	end
	# the common words, bucketed by first letter
	_aBk_ = _StzDocList(27)
	for _i_ = 1 to 27
		_aBk_[_i_] = []
	next
	_nW_ = len(_acW_)
	for _i_ = 1 to _nW_
		if _anC_[_i_] >= 8 and len(_acW_[_i_]) >= 4
			_aBk_[_StzDocBucket(_acW_[_i_])] + _i_
		ok
	next
	for _i_ = 1 to _nW_
		_cW_ = _acW_[_i_]
		if _anC_[_i_] > 6 or len(_cW_) < 4
			loop
		ok
		if ring_find(_acReviewed_, _cW_) > 0
			loop
		ok
		_aB_ = _aBk_[_StzDocBucket(_cW_)]
		_nB_ = len(_aB_)
		for _k_ = 1 to _nB_
			_nI_ = _aB_[_k_]
			_cO_ = _acW_[_nI_]
			_nd_ = len(_cO_) - len(_cW_)
			if _nd_ > 1 or _nd_ < -1
				loop
			ok
			if _anC_[_nI_] < 30 * _anC_[_i_]
				loop
			ok
			if _StzDocDam1(_cW_, _cO_) and NOT _StzDocInflection(_cW_, _cO_)
				_aOut_ + [ :rule = "doc-typo-word", :subject = _cW_, :where = _acO_[_i_],
				           :severity = "warning",
				           :message = "the word '" + _cW_ + "' (" + _anC_[_i_] + " use" + "s" +
				           ") is one edit from '" + _cO_ + "' (" + _anC_[_nI_] + " uses): " + _acO_[_i_] + " may be misspelled" ]
				exit
			ok
		next
	next
	return _aOut_

func _StzDocAllLetters(pcWord)
	_n_ = len(pcWord)
	for _i_ = 1 to _n_
		if NOT isalpha(pcWord[_i_])
			return 0
		ok
	next
	return 1

func _StzDocBucket(pcWord)
	_n_ = ascii(pcWord[1]) - 96
	if _n_ < 1 or _n_ > 26
		return 27
	ok
	return _n_

# list(n) refuses n = 0 (an empty class has no records)
func _StzDocList(pn)
	if pn < 1
		return []
	ok
	return list(pn)

# NumberOfX / HowManyX: a count (the next letter opens a word)
func _StzDocIsCountName(pcName)
	_acLead_ = [ "NumberOf", "HowMany" ]
	for _i_ = 1 to 2
		_n_ = len(_acLead_[_i_])
		if len(pcName) > _n_ and left(pcName, _n_) = _acLead_[_i_]
			_c_ = pcName[_n_ + 1]
			if _c_ != lower(_c_) or isdigit(_c_)
				return 1
			ok
		ok
	next
	return 0
