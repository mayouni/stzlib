# twin-coverage -- the rule between the three projections of a .panel document
#
# A page has more than one reader. A stzUiDocument projects to HTML (for a
# browser), to text (for a person or an AI agent reading the source) and to the
# accessibility JSON (for a screen reader and for an agent operating the
# screen). This rule asks ONE question of every named box that holds a text:
# does each twin carry that text? Taken from Proa's coverage lint (RX2,
# 2026-10-22), with its discipline kept whole:
#
#   - a twin that drops a box is an ERROR
#   - an exception is taken only WITH A REASON: [ name, reason ]; a bare one is
#     refused (an error), and the exception is declared by the caller who
#     judges, never written into the document that is judged
#   - a STALE exception -- a box every twin carries, or a box that is not in the
#     document -- is a WARNING, so the list of exceptions cannot rot in silence
#   - the court NEVER WRITES an exception for the author
#   - the report PRINTS ITS LIMITS: a comparison proves sameness, never
#     rightness. This rule does not certify equivalent meaning, order,
#     cardinality, or accessibility; it checks that each named box's text is
#     carried by each twin, and nothing more.
#
# Findings are the unified shape [ :rule, :subject, :where, :severity, :message ]
# and go through stzRuleReport; one report, no second runner.
#
#   example    oD = new stzUiDocument("my.panel")
#              aF = StzTwinCoverage(oD, [])
#              StzTwinCoverageReportQ(oD, []).Report()
#
# How "carried" is read, twin by twin, by an oracle independent of the writer:
#   html           the engine parses the page; the element whose id is the box's
#                  name must exist and its decoded text must be the content
#   text           the DEFINE TEXT block of that name must appear, and the content
#                  after it
#   accessibility  the engine parses the JSON; the node whose id is the box's name
#                  must exist and its accessible name must be the content (a box
#                  with a LABEL names itself by the label: that is the exception
#                  this rule was built to take with a reason)

# Returns the twin-coverage findings of a document, producing the three projections itself.
#
#   poDoc          a clean stzUiDocument
#   paExceptions   a list of [ name, reason ] pairs, possibly empty
#   returns        a list of findings in the unified shape
#   see            StzTwinCoverageXT, StzTwinCoverageReportQ
func StzTwinCoverage(poDoc, paExceptions)
	_cJ_ = StzAccessibilityTreeQ(poDoc, NULL).ToJSON()
	return StzTwinCoverageXT(poDoc, poDoc.ToHtml(), poDoc.ToText(), _cJ_, paExceptions)

# Returns the twin-coverage findings of a document over three projections given explicitly.
#
#   poDoc          the stzUiDocument the projections came from
#   pcHtml         its HTML projection
#   pcText         its text projection
#   pcJson         its accessibility JSON
#   paExceptions   a list of [ name, reason ] pairs, possibly empty
#   returns        a list of findings; the exceptions list and the document are not changed
#   note           giving the projections is what lets a guard show a twin that drops a box
#   see            StzTwinCoverage
func StzTwinCoverageXT(poDoc, pcHtml, pcText, pcJson, paExceptions)
	_aOut_ = []
	_cRule_ = "twin-coverage"

	# 1. the exceptions, read before anything is judged: a bare one is refused
	_aEx_ = []            # [ name, reason, used ]
	if NOT isList(paExceptions)
		paExceptions = []
	ok
	_nE_ = len(paExceptions)
	for _i_ = 1 to _nE_
		_e_ = paExceptions[_i_]
		_cName_ = "?"
		if isList(_e_) and len(_e_) >= 1 and isString(_e_[1])
			_cName_ = _e_[1]
		ok
		if NOT isList(_e_) or len(_e_) < 2 or NOT isString(_e_[2]) or ring_trim("" + _e_[2]) = ""
			_aOut_ + [ :rule = _cRule_, :subject = _cName_, :where = "exceptions",
			           :severity = :error,
			           :message = "a bare exception is refused: an exception takes a written" +
			                      " reason, [ name, reason ], and this one has none." ]
			loop
		ok
		_aEx_ + [ _cName_, _e_[2], 0 ]
	next

	# 2. the named boxes that hold a text
	_aBoxes_ = []         # [ name, content ]
	_aNames_ = poDoc.Names()
	_nN_ = len(_aNames_)
	for _i_ = 1 to _nN_
		_d_ = poDoc.DeclOf(_aNames_[_i_])
		if len(_d_) = 0 or strcmp(_d_[:kind], "TEXT") != 0
			loop
		ok
		_cC_ = poDoc._StrField(poDoc._EffectiveFields(_d_), "CONTENT", "")
		if _cC_ = ""
			loop
		ok
		_aBoxes_ + [ _d_[:name], _cC_ ]
	next

	# 3. every box against every twin
	_pH_ = StzEngineHtmlParse("" + pcHtml)
	_aNodes_ = _StzTwinA11yNodes("" + pcJson)
	_nB_ = len(_aBoxes_)
	for _i_ = 1 to _nB_
		_cName_ = _aBoxes_[_i_][1]
		_cC_ = _aBoxes_[_i_][2]
		_aDropped_ = []
		if NOT _StzTwinHtmlCarries(_pH_, _cName_, _cC_)
			_aDropped_ + "html"
		ok
		if NOT _StzTwinTextCarries("" + pcText, _cName_, _cC_)
			_aDropped_ + "text"
		ok
		if NOT _StzTwinA11yCarries(_aNodes_, _cName_, _cC_)
			_aDropped_ + "accessibility"
		ok
		_nD_ = len(_aDropped_)
		if _nD_ = 0
			loop
		ok
		_nX_ = _StzTwinExceptionOf(_aEx_, _cName_)
		for _k_ = 1 to _nD_
			if _nX_ > 0
				_aEx_[_nX_][3] = 1
				_aOut_ + [ :rule = _cRule_, :subject = _cName_, :where = _aDropped_[_k_],
				           :severity = :info,
				           :message = "the box's text is not carried by the " + _aDropped_[_k_] +
				                      " twin, excepted with the reason: " + _aEx_[_nX_][2] ]
			else
				_aOut_ + [ :rule = _cRule_, :subject = _cName_, :where = _aDropped_[_k_],
				           :severity = :error,
				           :message = "the box's text is not carried by the " + _aDropped_[_k_] +
				                      " twin; a reader of that twin does not see what the" +
				                      " others show. Repair the twin, or except the box WITH" +
				                      " a reason." ]
			ok
		next
	next
	if _pH_ != ""
		StzEngineHtmlFree(_pH_)
	ok

	# 4. the stale exceptions: a box every twin carries, or no such box
	_nX_ = len(_aEx_)
	for _i_ = 1 to _nX_
		if _aEx_[_i_][3] = 1
			loop
		ok
		_cWhy_ = "every twin carries the box, so the exception is stale and should go"
		if _StzTwinBoxIndex(_aBoxes_, _aEx_[_i_][1]) = 0
			_cWhy_ = "no named box with a text has this name, so the exception names nothing"
		ok
		_aOut_ + [ :rule = _cRule_, :subject = _aEx_[_i_][1], :where = "exceptions",
		           :severity = :warning,
		           :message = "stale exception: " + _cWhy_ + " (its reason was: " +
		                      _aEx_[_i_][2] + ")" ]
	next

	# 5. the limits, printed every time: sameness is not rightness
	_aOut_ + [ :rule = _cRule_, :subject = "document", :where = "limits",
	           :severity = :info,
	           :message = "twin-coverage checked that " + _nB_ + " named box(es) with a text" +
	                      " are carried by the html, text and accessibility twins. It proves" +
	                      " sameness, never rightness: it does not certify equivalent meaning," +
	                      " order, cardinality, or accessibility." ]
	return _aOut_

# Returns a stzRuleReport named twin-coverage holding the findings of a document.
#
#   poDoc          a clean stzUiDocument
#   paExceptions   a list of [ name, reason ] pairs, possibly empty
#   returns        a stzRuleReport; Report() prints it, IsSound() answers
#   see            StzTwinCoverage
func StzTwinCoverageReportQ(poDoc, paExceptions)
	# built in two steps: a chained call on a fresh object is the Ring trap
	# that returns nothing from a method's return value
	_oR_ = StzRuleReportQ("twin-coverage")
	_oR_.Ingest(StzTwinCoverage(poDoc, paExceptions))
	return _oR_

# -- the three oracles --------------------------------------------------------

# 1 when the parsed page holds an element with the box's name as id whose decoded text is the content
func _StzTwinHtmlCarries(pH, pcName, pcContent)
	if pH = ""
		return 0
	ok
	_nIdx_ = StzEngineHtmlFindById(pH, pcName)
	if _nIdx_ <= 0
		return 0
	ok
	# the element's text is read by tag and occurrence: count the same tag up to the index
	_cTag_ = StzEngineHtmlTagOf(pH, _nIdx_)
	_nOcc_ = 0
	for _i_ = 1 to _nIdx_
		if StzLower(StzEngineHtmlTagOf(pH, _i_)) = StzLower(_cTag_)
			_nOcc_++
		ok
	next
	_cT_ = StzEngineHtmlDecode(StzEngineHtmlTextOfTag(pH, _cTag_, _nOcc_))
	if strcmp(_cT_, pcContent) = 0
		return 1
	ok
	return 0

# 1 when the text projection declares the box and carries the content after the declaration
func _StzTwinTextCarries(pcText, pcName, pcContent)
	_nP_ = StzFindFirst("DEFINE TEXT " + pcName + " (", pcText)
	if _nP_ = 0
		return 0
	ok
	if StzFindFirst(pcContent, StzMidToEnd(pcText, _nP_)) > 0
		return 1
	ok
	return 0

# the nodes of the accessibility JSON as Ring lists, [] when the JSON does not parse
func _StzTwinA11yNodes(pcJson)
	if NOT StzJsonIsValid(pcJson)
		return []
	ok
	_a_ = StzEngineJsonParseToList(pcJson)
	if NOT isList(_a_)
		return []
	ok
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if isList(_a_[_i_]) and len(_a_[_i_]) = 2 and isString(_a_[_i_][1]) and
		   strcmp(_a_[_i_][1], "nodes") = 0 and isList(_a_[_i_][2])
			return _a_[_i_][2]
		ok
	next
	return []

# 1 when a node with the box's name as id carries the content as its accessible name
func _StzTwinA11yCarries(paNodes, pcName, pcContent)
	_n_ = len(paNodes)
	for _i_ = 1 to _n_
		_d_ = paNodes[_i_]
		if NOT isList(_d_)
			loop
		ok
		_cId_ = _StzTwinPair(_d_, "id")
		if strcmp(_cId_, pcName) = 0
			if strcmp(_StzTwinPair(_d_, "name"), pcContent) = 0
				return 1
			ok
			return 0
		ok
	next
	return 0

# the text value under a key of a parsed JSON object, "" when absent
func _StzTwinPair(paObj, pcKey)
	_n_ = len(paObj)
	for _i_ = 1 to _n_
		if isList(paObj[_i_]) and len(paObj[_i_]) = 2 and isString(paObj[_i_][1]) and
		   strcmp(paObj[_i_][1], pcKey) = 0
			if isString(paObj[_i_][2])
				return paObj[_i_][2]
			ok
			return "" + paObj[_i_][2]
		ok
	next
	return ""

func _StzTwinExceptionOf(paEx, pcName)
	_n_ = len(paEx)
	for _i_ = 1 to _n_
		if strcmp(paEx[_i_][1], pcName) = 0
			return _i_
		ok
	next
	return 0

func _StzTwinBoxIndex(paBoxes, pcName)
	_n_ = len(paBoxes)
	for _i_ = 1 to _n_
		if strcmp(paBoxes[_i_][1], pcName) = 0
			return _i_
		ok
	next
	return 0
