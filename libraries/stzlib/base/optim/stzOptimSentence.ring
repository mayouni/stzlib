#=====================================================================#
#  STZOPTIMSENTENCE -- the sentence surface (R4 step 5, surface 2)    #
#=====================================================================#
/*
	SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.5, surface 2: the model said
	as a sentence, reaching THE SAME MODEL AST as the entry object.

		oM = StzOptimNaturally("
		        maximize 3*x + 2*y
		        where x is between 0 and 40
		        and y is a whole number at least 0
		        keeping x + y under 50
		        and keeping 2*x + y under 80
		     ")

	AND THE POINT IS NOT THE ENGLISH. It is that this builds
	stzOptimModel by calling Vars / Maximize / SubjectTo exactly as a
	caller would, so there is ONE model class, ONE expression compiler
	and ONE AST. A sentence surface that parsed straight to coefficients
	would be a second modelling engine wearing a friendly face, and the
	day the two disagreed the disagreement would be silent. The guard
	compares the two surfaces' ASTs rather than their answers, because
	two different wrong models can agree on a number.

	WHAT IT UNDERSTANDS, and the vocabulary is deliberately small and
	closed -- an ambiguity is REFUSED rather than guessed (LAW 3):

	  maximize <expr>            /  minimize <expr>
	  <v> is between <a> and <b>
	  <v> is at least <a>        /  <v> is at most <b>
	  <v> is a whole number ...  (anywhere in a `where` clause: integer)
	  <v> is binary
	  keeping <expr> under <n>   ->  <expr> <= n
	  keeping <expr> over  <n>   ->  <expr> >= n
	  keeping <expr> at    <n>   ->  <expr>  = n
	  <relation>                 (a bare "x + y <= 50" is always allowed)

	`and` opens a new clause of whichever kind is in force, so the
	sentence reads as a sentence and still parses as a list.
*/

func StzOptimNaturally(pcText)
	return StzOptimSentenceQ(pcText).ToModel()

func StzOptimSentenceQ(pcText)
	return new stzOptimSentence(pcText)

class stzOptimSentence from stzObject

	@cText = ""
	@cSense = ""
	@cObjExpr = ""
	@aVarSpec = []      # [ [ name, lb, ub, hasUb, int ] ]
	@acCons = []
	@aFindings = []

	def init(pcText)
		@cText = "" + pcText
		This._Parse()

	def Findings()
		return @aFindings

	def IsValid()
		return len(@aFindings) = 0

	def CiteFindings()
		_c_ = ""
		_n_ = len(@aFindings)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += char(10)
			ok
			_c_ += "  - " + @aFindings[_i_]
		next
		return _c_

	#-- the parse -------------------------------------------------------

	def _Parse()
		@aFindings = []
		@aVarSpec = []
		@acCons = []
		@cSense = ""
		@cObjExpr = ""

		_ac_ = This._Clauses()
		_cMode_ = ""
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_cL_ = ring_trim(_ac_[_i_])
			if _cL_ = ""
				loop
			ok

			_cLow_ = StzLower(_cL_)
			if StzLeft(_cLow_, 9) = "maximize "
				@cSense = "max"
				@cObjExpr = ring_trim(StzMid(_cL_, 10, StzLen(_cL_) - 9))
				_cMode_ = "obj"
				loop
			ok
			if StzLeft(_cLow_, 9) = "minimize "
				@cSense = "min"
				@cObjExpr = ring_trim(StzMid(_cL_, 10, StzLen(_cL_) - 9))
				_cMode_ = "obj"
				loop
			ok
			if StzLeft(_cLow_, 6) = "where "
				_cMode_ = "where"
				This._ReadWhere(ring_trim(StzMid(_cL_, 7, StzLen(_cL_) - 6)))
				loop
			ok
			if StzLeft(_cLow_, 8) = "keeping "
				_cMode_ = "keeping"
				This._ReadKeeping(ring_trim(StzMid(_cL_, 9, StzLen(_cL_) - 8)))
				loop
			ok

			# `and ...` continues whichever clause kind is in force -- the
			# one piece of state in this parser, and it is why the text
			# reads as prose instead of as a list of commands
			if _cMode_ = "where"
				This._ReadWhere(_cL_)
			but _cMode_ = "keeping"
				This._ReadKeeping(_cL_)
			but StzOptimRelationAt(_cL_)[:at] > 0
				@acCons + _cL_
			else
				@aFindings + ("'" + _cL_ + "' is not a clause this surface " +
					"knows -- it understands maximize/minimize, where, " +
					"keeping, and a plain relation")
			ok
		next

		if @cSense = ""
			@aFindings + "no objective -- a model opens with maximize or minimize"
		ok
		if len(@aVarSpec) = 0
			@aFindings + "no variables -- say what each one ranges over in a where clause"
		ok

	# Split on newlines and on a leading `and `, so both layouts read the
	# same: one clause per line, or one long sentence joined by `and`.
	def _Clauses()
		_c_ = StzReplace("" + @cText, char(13), "")
		_ac_ = StzSplit(_c_, char(10))
		_aOut_ = []
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_cL_ = ring_trim(_ac_[_i_])
			if _cL_ = ""
				loop
			ok
			# a comma or a leading `and` opens the next clause
			_aP_ = This._SplitOnAnd(_cL_)
			_m_ = len(_aP_)
			for _j_ = 1 to _m_
				if ring_trim(_aP_[_j_]) != ""
					_aOut_ + ring_trim(_aP_[_j_])
				ok
			next
		next
		return _aOut_

	def _SplitOnAnd(pcLine)
		_c_ = ring_trim("" + pcLine)
		if StzLower(StzLeft(_c_, 4)) = "and "
			_c_ = ring_trim(StzMid(_c_, 5, StzLen(_c_) - 4))
		ok
		# an interior " and " separates clauses ONLY when what follows it
		# opens one -- "x is between 0 and 40" must not split
		_aOut_ = []
		_aF_ = StzFindCS(" and ", StzLower(_c_), 0)
		_nPrev_ = 1
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			_nAt_ = _aF_[_i_]
			_cTail_ = StzLower(ring_trim(StzMid(_c_, _nAt_ + 5,
				StzLen(_c_) - _nAt_ - 4)))
			if StzLeft(_cTail_, 8) = "keeping " or StzLeft(_cTail_, 6) = "where "
				_aOut_ + StzMid(_c_, _nPrev_, _nAt_ - _nPrev_)
				_nPrev_ = _nAt_ + 5
			ok
		next
		_aOut_ + StzMid(_c_, _nPrev_, StzLen(_c_) - _nPrev_ + 1)
		return _aOut_

	# "x is between 0 and 40" / "y is a whole number at least 0"
	def _ReadWhere(pcText)
		_c_ = ring_trim("" + pcText)
		_ac_ = This._Words(_c_)
		if len(_ac_) < 2
			@aFindings + ("'" + _c_ + "' does not say what a variable ranges over")
			return
		ok
		_cVar_ = StzLower(_ac_[1])
		_cLow_ = StzLower(_c_)

		_bInt_ = 0
		if len(StzFind("whole number", _cLow_)) > 0 or
		   len(StzFind("integer", _cLow_)) > 0
			_bInt_ = 1
		ok
		_bBin_ = 0
		if len(StzFind("binary", _cLow_)) > 0
			_bInt_ = 1
			_bBin_ = 1
		ok

		_nLb_ = 0
		_nUb_ = 0
		_bHasUb_ = 0

		if _bBin_ = 1
			_nUb_ = 1
			_bHasUb_ = 1
		ok

		_aB_ = StzFindCS("between ", _cLow_, 0)
		if len(_aB_) > 0
			_cRest_ = StzMid(_c_, _aB_[1] + 8, StzLen(_c_) - _aB_[1] - 7)
			_aW_ = This._Words(StzReplace(StzLower(_cRest_), " and ", " "))
			if len(_aW_) >= 2
				_nLb_ = 0 + _aW_[1]
				_nUb_ = 0 + _aW_[2]
				_bHasUb_ = 1
			else
				@aFindings + ("'between' needs two numbers in '" + _c_ + "'")
			ok
		ok

		_aL_ = StzFindCS("at least ", _cLow_, 0)
		if len(_aL_) > 0
			_cRest_ = StzMid(_c_, _aL_[1] + 9, StzLen(_c_) - _aL_[1] - 8)
			_aW_ = This._Words(_cRest_)
			if len(_aW_) >= 1
				_nLb_ = 0 + _aW_[1]
			ok
		ok

		_aU_ = StzFindCS("at most ", _cLow_, 0)
		if len(_aU_) > 0
			_cRest_ = StzMid(_c_, _aU_[1] + 8, StzLen(_c_) - _aU_[1] - 7)
			_aW_ = This._Words(_cRest_)
			if len(_aW_) >= 1
				_nUb_ = 0 + _aW_[1]
				_bHasUb_ = 1
			ok
		ok

		@aVarSpec + [ _cVar_, _nLb_, _nUb_, _bHasUb_, _bInt_ ]

	# "keeping x + y under 50"
	def _ReadKeeping(pcText)
		_c_ = ring_trim("" + pcText)
		if StzLower(StzLeft(_c_, 8)) = "keeping "
			_c_ = ring_trim(StzMid(_c_, 9, StzLen(_c_) - 8))
		ok

		# an explicit relation inside a keeping clause wins -- it is not
		# ambiguous and refusing it would be pedantry
		if StzOptimRelationAt(_c_)[:at] > 0
			@acCons + _c_
			return
		ok

		_cLow_ = StzLower(_c_)
		_aW_ = [ [ " under ", "<=" ], [ " below ", "<=" ],
			 [ " over ", ">=" ], [ " above ", ">=" ],
			 [ " at least ", ">=" ], [ " at most ", "<=" ],
			 [ " at ", "=" ], [ " exactly ", "=" ] ]
		_n_ = len(_aW_)
		for _i_ = 1 to _n_
			_aF_ = StzFindCS(_aW_[_i_][1], _cLow_, 0)
			if len(_aF_) = 0
				loop
			ok
			_nAt_ = _aF_[1]
			_cL_ = ring_trim(StzLeft(_c_, _nAt_ - 1))
			_cR_ = ring_trim(StzMid(_c_, _nAt_ + StzLen(_aW_[_i_][1]),
				StzLen(_c_) - _nAt_ - StzLen(_aW_[_i_][1]) + 1))
			@acCons + (_cL_ + " " + _aW_[_i_][2] + " " + _cR_)
			return
		next

		@aFindings + ("'" + _c_ + "' does not say how much -- a keeping " +
			"clause ends in under, over or at, followed by a number")

	def _Words(pcText)
		_ac_ = StzSplit(ring_trim("" + pcText), " ")
		_aOut_ = []
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_w_ = ring_trim(_ac_[_i_])
			if _w_ != ""
				_aOut_ + _w_
			ok
		next
		return _aOut_

	#-- the same door the entry object uses ------------------------------

	def ToModel()
		if NOT This.IsValid()
			stzraise("stzOptimSentence: this sentence was REFUSED." +
				char(10) + This.CiteFindings())
		ok
		_oM_ = new stzOptimModel()
		_n_ = len(@aVarSpec)
		for _i_ = 1 to _n_
			_aV_ = @aVarSpec[_i_]
			_aSpec_ = [ _aV_[2] ]
			if _aV_[4] = 1
				_aSpec_ + _aV_[3]
			ok
			if _aV_[5] = 1
				_aSpec_ + :integer
			ok
			_oM_.AddVar(_aV_[1], _aSpec_)
		next
		if @cSense = "max"
			_oM_.Maximize(@cObjExpr)
		else
			_oM_.Minimize(@cObjExpr)
		ok
		_m_ = len(@acCons)
		for _i_ = 1 to _m_
			_oM_.AddConstraint(@acCons[_i_])
		next
		return _oM_
