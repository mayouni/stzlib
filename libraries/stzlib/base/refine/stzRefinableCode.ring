# R6 -- stzRefinableCode: REFINEMENT PROGRAMMING (stzPolyCode home)
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.8 + the DLM-era ruling.)
# Code carries typed REFINEMENT POINTS -- named "adjustment knobs" --
# and a change is a TYPED PROPOSAL, not a diff: the cascade is previewed,
# the four-stage gate validates, the audit chain records, and one call
# reverts (reversibility as a data-model primitive).
#
#   cSrc = 'rate = <R:PARAM name="vat" value="0.20" min="0" max="0.25">' + nl +
#          'engine = <R:ALGO name="sort" value="quick" options="quick|merge|heap">'
#   o = new stzRefinableCode(cSrc)
#   ? o.RefinementPoints()            # the declared change surface
#   ? o.Cascade("vat")                # what a change to 'vat' touches
#   o.Refine("vat").To("0.22")        # a typed proposal through the gate
#   ? o.Rendered()                    # the refined source
#   o.Revert()                        # the typed inverse
#
# THE GATE (4 stages, floor): STRUCTURAL (the point exists + the value
# parses) -> CONSTRAINT (bounds / allowed options) -> DERIVATION
# (reserved: cross-point rules) -> GOVERNANCE (reserved: stzGovernance).
# A rejected proposal NEVER mutates the source (LAW 3). FORMAT: *.zrfn.

class stzRefinableCode from stzObject

	@cSource = ""
	@aPoints = []       # [ name, kind, value, meta, spanStart, spanLen ]
	@aHistory = []      # reversibility: [ name, oldValue, newValue ]
	@cWhy = ""
	@cPending = ""      # the point Refine() targets

	def init(pcSource)
		@cSource = "" + pcSource
		This._Parse()

	def Source()
		return @cSource

	def Why()
		return @cWhy

	#-- the declared change surface -----------------------------------------

	def RefinementPoints()
		_aOut_ = []
		_n_ = len(@aPoints)
		for _i_ = 1 to _n_
			_aOut_ + [ @aPoints[_i_][1], @aPoints[_i_][2], @aPoints[_i_][3] ]
		next
		return _aOut_

	def NumberOfPoints()
		return len(@aPoints)

	def ValueOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			return ""
		ok
		return @aPoints[_i_][3]

	def KindOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			return ""
		ok
		return @aPoints[_i_][2]

	#-- CASCADE: the pre-commit blast radius (the review artifact) -----------

	# which source LINES the point sits on, plus any point that shares a
	# line (the floor's cross-point impact). "What you read instead of
	# the diff" (5.8).
	def Cascade(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			return [ :point = "" + pcName, :exists = 0, :lines = [], :alsoTouches = [] ]
		ok
		_nLine_ = This._LineOfSpan(@aPoints[_i_][5])
		_acAlso_ = []
		_n_ = len(@aPoints)
		for _j_ = 1 to _n_
			if _j_ != _i_ and This._LineOfSpan(@aPoints[_j_][5]) = _nLine_
				_acAlso_ + @aPoints[_j_][1]
			ok
		next
		return [ :point = @aPoints[_i_][1], :exists = 1,
			:lines = [ _nLine_ ], :alsoTouches = _acAlso_ ]

	#-- the typed proposal + the gate ----------------------------------------

	def Refine(pcName)
		@cPending = "" + pcName
		return This

	# apply a value to the pending point THROUGH the gate. Returns
	# [ :admitted, :why ]; on rejection the source is unchanged.
	def To(pValue)
		if @cPending = ""
			stzraise("Refine(pointName) first, then To(value).")
		ok
		_cName_ = @cPending
		@cPending = ""
		_cVal_ = "" + pValue
		_i_ = This._IndexOf(_cName_)

		# STAGE 1 -- STRUCTURAL: the point must exist
		if _i_ = 0
			@cWhy = "structural: no refinement point '" + _cName_ + "'"
			return [ :admitted = 0, :why = @cWhy ]
		ok

		# STAGE 2 -- CONSTRAINT: bounds (PARAM) / options (ALGO/LIB)
		_aGate_ = This._ConstraintCheck(_i_, _cVal_)
		if _aGate_[1] = 0
			@cWhy = "constraint: " + _aGate_[2]
			return [ :admitted = 0, :why = @cWhy ]
		ok

		# STAGE 3 (derivation) + STAGE 4 (governance): reserved floor
		# -- pass-through until the R6 deepening wires stzGraphRule +
		# stzGovernance. Admitted: capture prior state (reversibility)
		# and rewrite ONLY this point's value span.
		_cOld_ = @aPoints[_i_][3]
		This._SetValueAt(_i_, _cVal_)
		@aHistory + [ _cName_, _cOld_, _cVal_ ]
		@cWhy = "admitted: '" + _cName_ + "' " + _cOld_ + " -> " + _cVal_ +
			" (structural + constraint passed; derivation/governance reserved)"
		return [ :admitted = 1, :why = @cWhy ]

	#-- reversibility (a data-model primitive) -------------------------------

	def CanRevert()
		return len(@aHistory) > 0

	# undo the last admitted refinement -- a TYPED inverse, recorded
	def Revert()
		if len(@aHistory) = 0
			stzraise("Nothing to revert.")
		ok
		_aLast_ = @aHistory[len(@aHistory)]
		del(@aHistory, len(@aHistory))
		_i_ = This._IndexOf(_aLast_[1])
		if _i_ > 0
			This._SetValueAt(_i_, _aLast_[2])
		ok
		@cWhy = "reverted: '" + _aLast_[1] + "' " + _aLast_[3] + " -> " + _aLast_[2]
		return This

	def History()
		return @aHistory

	#-- rendering ------------------------------------------------------------

	# the source with every point's CURRENT value in place (the R-tags
	# stay -- the point is a living knob, not a one-shot substitution)
	def Rendered()
		return @cSource

	#-- persistence (*.zrfn) ------------------------------------------------------

	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zrfn"
			pcFile += ".zrfn"
		ok
		write(pcFile, @cSource)
		return pcFile

	#-- internals -------------------------------------------------------------

	# tag grammar: <R:KIND name="x" value="v" [min= max= | options=]>
	def _Parse()
		@aPoints = []
		_cS_ = @cSource
		_nFrom_ = 1
		while TRUE
			_aOpen_ = This._FirstAtOrAfter(_cS_, "<R:", _nFrom_)
			if _aOpen_ = 0
				exit
			ok
			_aClose_ = This._FirstAtOrAfter(_cS_, ">", _aOpen_)
			if _aClose_ = 0
				exit
			ok
			_cTag_ = This._Slice(_cS_, _aOpen_, _aClose_)
			_cKind_ = StzLower(This._Attr(_cTag_, ""))   # after "<R:"
			_cName_ = This._Attr(_cTag_, "name")
			_cVal_ = This._Attr(_cTag_, "value")
			_aMeta_ = [
				:min = This._Attr(_cTag_, "min"),
				:max = This._Attr(_cTag_, "max"),
				:options = This._Attr(_cTag_, "options")
			]
			# value span: inside value="..."
			_nVS_ = This._ValueSpanStart(_cS_, _aOpen_, _aClose_)
			_nVL_ = StzLen(_cVal_)
			if _cName_ != ""
				@aPoints + [ _cName_, _cKind_, _cVal_, _aMeta_, _nVS_, _nVL_ ]
			ok
			_nFrom_ = _aClose_ + 1
		end

	def _ConstraintCheck(nIdx, pcVal)
		_cKind_ = @aPoints[nIdx][2]
		_aMeta_ = @aPoints[nIdx][4]
		if _cKind_ = "param"
			# numeric bounds when min/max present
			if _aMeta_[:min] != "" and ring_number(pcVal) < ring_number(_aMeta_[:min])
				return [ 0, pcVal + " below min " + _aMeta_[:min] ]
			ok
			if _aMeta_[:max] != "" and ring_number(pcVal) > ring_number(_aMeta_[:max])
				return [ 0, pcVal + " above max " + _aMeta_[:max] ]
			ok
			return [ 1, "" ]
		but _cKind_ = "algo" or _cKind_ = "lib"
			if _aMeta_[:options] != ""
				_acO_ = StzSplit(_aMeta_[:options], "|")
				if ring_find(_acO_, pcVal) = 0
					return [ 0, "'" + pcVal + "' not in options " + _aMeta_[:options] ]
				ok
			ok
			return [ 1, "" ]
		ok
		return [ 1, "" ]

	# rewrite the value span in the source and re-parse spans
	def _SetValueAt(nIdx, pcVal)
		_nS_ = @aPoints[nIdx][5]
		_nL_ = @aPoints[nIdx][6]
		_cBefore_ = This._SliceLen(@cSource, 1, _nS_ - 1)
		_cAfter_ = This._SliceFrom(@cSource, _nS_ + _nL_)
		@cSource = _cBefore_ + pcVal + _cAfter_
		This._Parse()

	def _IndexOf(pcName)
		_cN_ = "" + pcName
		_n_ = len(@aPoints)
		for _i_ = 1 to _n_
			if @aPoints[_i_][1] = _cN_
				return _i_
			ok
		next
		return 0

	def _Attr(pcTag, pcAttr)
		# named attr: pcAttr="x" -> value inside x="..."
		if pcAttr = ""
			# KIND: the token right after "<R:" up to a space
			_cRest_ = This._SliceFrom(pcTag, 4)
			_acP_ = StzSplit(_cRest_, " ")
			return _acP_[1]
		ok
		_cKey_ = pcAttr + '="'
		_aP_ = StzFindCS(_cKey_, pcTag, 1)
		if len(_aP_) = 0
			return ""
		ok
		_nStart_ = _aP_[1] + StzLen(_cKey_)
		_cTail_ = This._SliceFrom(pcTag, _nStart_)
		_aQ_ = StzFindCS('"', _cTail_, 1)
		if len(_aQ_) = 0
			return ""
		ok
		return This._SliceLen(_cTail_, 1, _aQ_[1] - 1)

	def _ValueSpanStart(pcS, nOpen, nClose)
		_cTag_ = This._Slice(pcS, nOpen, nClose)
		_aP_ = StzFindCS('value="', _cTag_, 1)
		if len(_aP_) = 0
			return nOpen
		ok
		return nOpen + (_aP_[1] - 1) + StzLen('value="')

	def _FirstAtOrAfter(pcS, pcNeedle, nFrom)
		_aAll_ = StzFindCS(pcNeedle, pcS, 1)
		_n_ = len(_aAll_)
		for _i_ = 1 to _n_
			if _aAll_[_i_] >= nFrom
				return _aAll_[_i_]
			ok
		next
		return 0

	def _Slice(pcS, nA, nB)
		return This._SliceLen(pcS, nA, nB - nA + 1)

	def _SliceLen(pcS, nStart, nLen)
		if nLen <= 0
			return ""
		ok
		return StzMid(pcS, nStart, nLen)

	def _SliceFrom(pcS, nStart)
		if nStart > StzLen(pcS)
			return ""
		ok
		return StzMidToEnd(pcS, nStart)

	def _LineOfSpan(nPos)
		_cHead_ = This._SliceLen(@cSource, 1, nPos)
		return len(StzFindCS(char(10), _cHead_, 1)) + 1
