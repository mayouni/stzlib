#=====================================================================#
#  STZOPTIMFILE -- the *.zopt format (R4 step 5, surface 3)           #
#=====================================================================#
/*
	SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.5, surface 3. LAW 1 -- every
	stateful domain earns its format; the precedent is .zknw, .zgov and
	.flow.

	A .zopt file, whole:

		zopt: 1
		model: production
		set Products: chairs, tables
		param profit[Products]: 30, 45
		param hours[Products]: 2, 5
		var make[Products]: 0 .. 100 integer
		maximize: sum profit[p] * make[p] for p in Products
		subject to:
		  capacity: sum hours[p] * make[p] for p in Products <= 250
		  forall p in Products: make[p] <= 60

	WHY THE FORMAT IS NOT DECORATION, and it is the one line worth
	reading twice: INDEXED FAMILIES. `var make[Products]` declares one
	variable per product, `sum ... for p in Products` expands to one term
	per product, and `forall p in Products` expands to one CONSTRAINT per
	product. Today's longhand solver cannot say any of that -- a caller
	with fifty products writes fifty lines and maintains them by hand.
	Adding a product here is editing ONE list.

	EXPANSION HAPPENS HERE, AND THE MODEL NEVER KNOWS. A family is
	expanded into ordinary variables (make[chairs], make[tables]) and
	ordinary constraint strings before stzOptimModel sees any of it, so
	the format is a FRONT END onto surface 1 rather than a second
	modelling engine. That is the same rule .pia follows onto stzPIAgent,
	and it is what keeps "one AST" true: a .zopt model and a hand-built
	model of the same problem produce the same AST because the second one
	IS what the first one becomes.
*/

func StzOptimFileQ(pcPath)
	return new stzOptimFile(pcPath)

func StzOptimModelFromFile(pcPath)
	return StzOptimFileQ(pcPath).ToModel()

func StzOptimModelFromZopt(pcText)
	_o_ = new stzOptimFile("")
	_o_.SetText(pcText)
	return _o_.ToModel()

# the format version this build writes and reads
func StzZoptVersion()
	return 1

class stzOptimFile from stzObject

	@cText = ""
	@cPath = ""
	@cName = ""
	@aSets = []        # [ [ name, [ members ] ] ]
	@aParams = []      # [ [ name, indexSet, [ values ] ] ]
	@aVarFam = []      # [ [ name, indexSet("" = scalar), lb, ub, hasUb, int ] ]
	@cObjSense = ""
	@cObjExpr = ""
	@aConsSrc = []     # [ [ name, text, forallVar, forallSet ] ]
	@aFindings = []

	def init(pcPath)
		@cPath = "" + pcPath
		if @cPath != ""
			if NOT StzFileExists(@cPath)
				stzraise("stzOptimFile: no file at '" + @cPath + "'.")
			ok
			@cText = StzFileRead(@cPath)
			This._Parse()
		ok

	def SetText(pcText)
		@cText = "" + pcText
		This._Parse()
		return This

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

	def Name_()
		return @cName

	def SetsDeclared()
		return @aSets

	def MembersOf(pcSet)
		_c_ = StzLower(ring_trim("" + pcSet))
		_n_ = len(@aSets)
		for _i_ = 1 to _n_
			if @aSets[_i_][1] = _c_
				return @aSets[_i_][2]
			ok
		next
		return []

	def ParamValue(pcParam, pcMember)
		_cP_ = StzLower(ring_trim("" + pcParam))
		_cM_ = StzLower(ring_trim("" + pcMember))
		_n_ = len(@aParams)
		for _i_ = 1 to _n_
			if @aParams[_i_][1] = _cP_
				_ac_ = This.MembersOf(@aParams[_i_][2])
				_j_ = ring_find(_ac_, _cM_)
				if _j_ = 0
					return 0
				ok
				if _j_ > len(@aParams[_i_][3])
					return 0
				ok
				return @aParams[_i_][3][_j_]
			ok
		next
		return 0

	#-- the parse -------------------------------------------------------

	def _Parse()
		@aFindings = []
		@aSets = []
		@aParams = []
		@aVarFam = []
		@aConsSrc = []
		@cObjSense = ""
		@cObjExpr = ""

		_cClean_ = StzReplace(@cText, char(13), "")
		_ac_ = StzSplit(_cClean_, char(10))
		_bInCons_ = 0
		_bVersion_ = 0
		_n_ = len(_ac_)

		for _i_ = 1 to _n_
			_cRaw_ = _ac_[_i_]
			_cL_ = ring_trim(_cRaw_)
			if _cL_ = "" or StzLeft(_cL_, 1) = "#"
				loop
			ok

			# a constraint line is INDENTED under `subject to:` -- the one
			# place layout carries meaning, and it is checked rather than
			# assumed, so a dedented line closes the block instead of
			# silently joining it
			_bIndented_ = 0
			if StzLeft(_cRaw_, 1) = " " or StzLeft(_cRaw_, 1) = char(9)
				_bIndented_ = 1
			ok

			if _bInCons_ = 1 and _bIndented_ = 1
				This._ReadConstraintLine(_cL_, _i_)
				loop
			ok
			_bInCons_ = 0

			if StzLower(StzLeft(_cL_, 5)) = "zopt:"
				_bVersion_ = 1
				_v_ = ring_trim(StzMid(_cL_, 6, StzLen(_cL_) - 5))
				if _v_ != ("" + StzZoptVersion())
					@aFindings + ("this build knows zopt version " +
						StzZoptVersion() + " and the file says '" + _v_ + "'")
				ok
				loop
			ok

			if StzLower(StzLeft(_cL_, 6)) = "model:"
				@cName = ring_trim(StzMid(_cL_, 7, StzLen(_cL_) - 6))
				loop
			ok

			if StzLower(StzLeft(_cL_, 4)) = "set "
				This._ReadSet(_cL_, _i_)
				loop
			ok

			if StzLower(StzLeft(_cL_, 6)) = "param "
				This._ReadParam(_cL_, _i_)
				loop
			ok

			if StzLower(StzLeft(_cL_, 4)) = "var "
				This._ReadVar(_cL_, _i_)
				loop
			ok

			if StzLower(StzLeft(_cL_, 9)) = "maximize:"
				@cObjSense = "max"
				@cObjExpr = ring_trim(StzMid(_cL_, 10, StzLen(_cL_) - 9))
				loop
			ok
			if StzLower(StzLeft(_cL_, 9)) = "minimize:"
				@cObjSense = "min"
				@cObjExpr = ring_trim(StzMid(_cL_, 10, StzLen(_cL_) - 9))
				loop
			ok

			if StzLower(StzReplace(_cL_, " ", "")) = "subjectto:"
				_bInCons_ = 1
				loop
			ok

			@aFindings + ("line " + _i_ + ": '" + _cL_ + "' is not " +
				"anything this format knows")
		next

		if _bVersion_ = 0
			@aFindings + ("a .zopt file must open with 'zopt: " +
				StzZoptVersion() + "' -- a file with no version cannot be " +
				"read safely by a later build")
		ok
		if @cObjSense = ""
			@aFindings + "no objective -- a model needs maximize: or minimize:"
		ok
		if len(@aVarFam) = 0
			@aFindings + "no variables declared"
		ok

	# set Products: chairs, tables
	def _ReadSet(pcLine, pnAt)
		_cRest_ = ring_trim(StzMid(pcLine, 5, StzLen(pcLine) - 4))
		_nAt_ = StzFindFirst(":", _cRest_)
		if _nAt_ = 0
			@aFindings + ("line " + pnAt + ": a set needs 'set Name: a, b, c'")
			return
		ok
		_cName_ = StzLower(ring_trim(StzLeft(_cRest_, _nAt_ - 1)))
		_cVals_ = StzMid(_cRest_, _nAt_ + 1, StzLen(_cRest_) - _nAt_)
		_ac_ = StzSplit(_cVals_, ",")
		_aOut_ = []
		_m_ = len(_ac_)
		for _j_ = 1 to _m_
			_w_ = StzLower(ring_trim(_ac_[_j_]))
			if _w_ != ""
				_aOut_ + _w_
			ok
		next
		if len(_aOut_) = 0
			@aFindings + ("line " + pnAt + ": set '" + _cName_ + "' is empty")
			return
		ok
		@aSets + [ _cName_, _aOut_ ]

	# param profit[Products]: 30, 45
	def _ReadParam(pcLine, pnAt)
		_cRest_ = ring_trim(StzMid(pcLine, 7, StzLen(pcLine) - 6))
		_nC_ = StzFindFirst(":", _cRest_)
		if _nC_ = 0
			@aFindings + ("line " + pnAt + ": a param needs " +
				"'param name[Set]: v1, v2'")
			return
		ok
		_cHead_ = ring_trim(StzLeft(_cRest_, _nC_ - 1))
		_cVals_ = StzMid(_cRest_, _nC_ + 1, StzLen(_cRest_) - _nC_)

		_aHd_ = This._SplitIndexed(_cHead_)
		_cName_ = _aHd_[:name]
		_cSet_ = _aHd_[:index]
		if _cSet_ = ""
			@aFindings + ("line " + pnAt + ": param '" + _cName_ +
				"' has no index set -- write param " + _cName_ + "[SetName]")
			return
		ok
		_acMem_ = This.MembersOf(_cSet_)
		if len(_acMem_) = 0
			@aFindings + ("line " + pnAt + ": param '" + _cName_ +
				"' indexes '" + _cSet_ + "', which is not a declared set")
			return
		ok

		_ac_ = StzSplit(_cVals_, ",")
		_aOut_ = []
		_m_ = len(_ac_)
		for _j_ = 1 to _m_
			_w_ = ring_trim(_ac_[_j_])
			if _w_ != ""
				_aOut_ + (0 + _w_)
			ok
		next
		if len(_aOut_) != len(_acMem_)
			@aFindings + ("line " + pnAt + ": param '" + _cName_ + "' gives " +
				len(_aOut_) + " value(s) for a set of " + len(_acMem_) +
				" member(s) -- an indexed parameter is one value per member")
			return
		ok
		@aParams + [ _cName_, _cSet_, _aOut_ ]

	# var make[Products]: 0 .. 100 integer      |      var z: 0 .. 50
	def _ReadVar(pcLine, pnAt)
		_cRest_ = ring_trim(StzMid(pcLine, 5, StzLen(pcLine) - 4))
		_nC_ = StzFindFirst(":", _cRest_)
		if _nC_ = 0
			@aFindings + ("line " + pnAt + ": a var needs 'var name: lo .. hi'")
			return
		ok
		_cHead_ = ring_trim(StzLeft(_cRest_, _nC_ - 1))
		_cSpec_ = ring_trim(StzMid(_cRest_, _nC_ + 1, StzLen(_cRest_) - _nC_))

		_aHd_ = This._SplitIndexed(_cHead_)
		_cName_ = _aHd_[:name]
		_cSet_ = _aHd_[:index]
		if _cSet_ != "" and len(This.MembersOf(_cSet_)) = 0
			@aFindings + ("line " + pnAt + ": var '" + _cName_ +
				"' indexes '" + _cSet_ + "', which is not a declared set")
			return
		ok

		_bInt_ = 0
		_cLow_ = _cSpec_
		if len(StzFind("integer", StzLower(_cSpec_))) > 0
			_bInt_ = 1
			_cLow_ = StzReplace(StzLower(_cSpec_), "integer", "")
		ok
		if len(StzFind("binary", StzLower(_cLow_))) > 0
			_bInt_ = 1
			_cLow_ = StzReplace(StzLower(_cLow_), "binary", "0 .. 1")
		ok

		_nLb_ = 0
		_nUb_ = 0
		_bHasUb_ = 0
		_acB_ = StzSplit(ring_trim(_cLow_), "..")
		_aClean_ = []
		_m_ = len(_acB_)
		for _j_ = 1 to _m_
			_w_ = ring_trim(_acB_[_j_])
			if _w_ != ""
				_aClean_ + _w_
			ok
		next
		if len(_aClean_) >= 1
			_nLb_ = 0 + _aClean_[1]
		ok
		if len(_aClean_) >= 2
			_nUb_ = 0 + _aClean_[2]
			_bHasUb_ = 1
		ok

		@aVarFam + [ _cName_, _cSet_, _nLb_, _nUb_, _bHasUb_, _bInt_ ]

	#   capacity: sum hours[p] * make[p] for p in Products <= 250
	#   forall p in Products: make[p] <= 60
	def _ReadConstraintLine(pcLine, pnAt)
		_cL_ = ring_trim(pcLine)
		if StzLower(StzLeft(_cL_, 7)) = "forall "
			_nC_ = StzFindFirst(":", _cL_)
			if _nC_ = 0
				@aFindings + ("line " + pnAt + ": forall needs " +
					"'forall v in Set: <relation>'")
				return
			ok
			_cHead_ = ring_trim(StzMid(_cL_, 8, _nC_ - 8))
			_cBody_ = ring_trim(StzMid(_cL_, _nC_ + 1, StzLen(_cL_) - _nC_))
			_ac_ = This._Words(_cHead_)
			if len(_ac_) != 3 or StzLower(_ac_[2]) != "in"
				@aFindings + ("line " + pnAt + ": '" + _cHead_ +
					"' is not 'v in Set'")
				return
			ok
			_cVar_ = StzLower(_ac_[1])
			_cSet_ = StzLower(_ac_[3])
			if len(This.MembersOf(_cSet_)) = 0
				@aFindings + ("line " + pnAt + ": forall over '" + _cSet_ +
					"', which is not a declared set")
				return
			ok
			@aConsSrc + [ "", _cBody_, _cVar_, _cSet_ ]
			return
		ok

		_nC_ = StzFindFirst(":", _cL_)
		_cName_ = ""
		_cBody_ = _cL_
		# a name is only a name when what follows it is a relation -- a
		# colon inside the body must not be mistaken for a label
		if _nC_ > 0
			_cCand_ = ring_trim(StzLeft(_cL_, _nC_ - 1))
			if StzOptimRelationAt(_cCand_)[:at] = 0
				_cName_ = StzLower(_cCand_)
				_cBody_ = ring_trim(StzMid(_cL_, _nC_ + 1, StzLen(_cL_) - _nC_))
			ok
		ok
		@aConsSrc + [ _cName_, _cBody_, "", "" ]

	def _SplitIndexed(pcText)
		_c_ = ring_trim("" + pcText)
		_nB_ = StzFindFirst("[", _c_)
		if _nB_ = 0
			return [ :name = StzLower(_c_), :index = "" ]
		ok
		_cName_ = StzLower(ring_trim(StzLeft(_c_, _nB_ - 1)))
		_nE_ = StzFindFirst("]", _c_)
		if _nE_ = 0 or _nE_ < _nB_
			return [ :name = _cName_, :index = "" ]
		ok
		_cIdx_ = StzLower(ring_trim(StzMid(_c_, _nB_ + 1, _nE_ - _nB_ - 1)))
		return [ :name = _cName_, :index = _cIdx_ ]

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

	#-- expansion: families become ordinary variables and strings --------
	#
	# THE WHOLE POINT OF THE FORMAT, and the reason it is a front end
	# rather than an engine: after this method there are no families
	# left, only the longhand a caller would otherwise have typed.

	def ToModel()
		if NOT This.IsValid()
			stzraise("stzOptimFile: this model was REFUSED." + char(10) +
				This.CiteFindings())
		ok
		_oM_ = new stzOptimModel()

		# variables: one per member for an indexed family
		_n_ = len(@aVarFam)
		for _i_ = 1 to _n_
			_aF_ = @aVarFam[_i_]
			_aSpec_ = [ _aF_[3] ]
			if _aF_[5] = 1
				_aSpec_ + _aF_[4]
			ok
			if _aF_[6] = 1
				_aSpec_ + :integer
			ok
			if _aF_[2] = ""
				_oM_.AddVar(_aF_[1], _aSpec_)
			else
				# `_acMem_` here too -- this method also holds `_aC_`, and
				# one method must never spell one variable two ways
				_acMem_ = This.MembersOf(_aF_[2])
				_m_ = len(_acMem_)
				for _j_ = 1 to _m_
					_oM_.AddVar(This._Cell(_aF_[1], _acMem_[_j_]), _aSpec_)
				next
			ok
		next

		# objective -- the expanded text goes through the SAME door a
		# caller uses, so a family and a hand-written model cannot drift
		_cObj_ = This._Expand(@cObjExpr, "", "")
		if @cObjSense = "max"
			_oM_.Maximize(_cObj_)
		else
			_oM_.Minimize(_cObj_)
		ok

		# constraints, including one per member for a forall
		_n_ = len(@aConsSrc)
		for _i_ = 1 to _n_
			_aC_ = @aConsSrc[_i_]
			if _aC_[3] = ""
				_cT_ = This._Expand(_aC_[2], "", "")
				if _aC_[1] = ""
					_oM_.AddConstraint(_cT_)
				else
					_oM_.AddNamedConstraint(_aC_[1], _cT_)
				ok
			else
				# `_acMem_` and NOT `_ac_`: RING FOLDS CASE, so `_ac_` and
				# `_aC_` are ONE variable -- reading the members into `_ac_`
				# overwrote the constraint row being read, and the next line
				# indexed a two-member list as if it were the row. The same
				# trap stzAgentDeclaration records at _NormalizeStructure,
				# met from the other side.
				_acMem_ = This.MembersOf(_aC_[4])
				_m_ = len(_acMem_)
				for _j_ = 1 to _m_
					_cT_ = This._Expand(_aC_[2], _aC_[3], _acMem_[_j_])
					_oM_.AddConstraint(_cT_)
				next
			ok
		next
		return _oM_

	# make[chairs] -- one flat name, because the solver has no idea what
	# an index is and does not need one
	def _Cell(pcName, pcMember)
		return StzLower("" + pcName) + "_" + StzLower("" + pcMember)

	# Expand one expression: first any `sum ... for v in Set`, then any
	# remaining [index] references under the binding in force.
	def _Expand(pcExpr, pcBindVar, pcBindMember)
		_c_ = This._ExpandSums("" + pcExpr)
		return This._Substitute(_c_, pcBindVar, pcBindMember)

	# sum <body> for <v> in <Set>  ->  body[v:=m1] + body[v:=m2] + ...
	def _ExpandSums(pcExpr)
		_c_ = "" + pcExpr
		_nGuard_ = 0
		while 1
			_nGuard_++
			if _nGuard_ > 50
				exit
			ok
			_aF_ = StzFindCS("sum ", StzLower(_c_), 0)
			if len(_aF_) = 0
				exit
			ok
			_nS_ = _aF_[1]
			_aFor_ = StzFindCS(" for ", StzLower(_c_), 0)
			_nF_ = 0
			_k_ = len(_aFor_)
			for _i_ = 1 to _k_
				if _aFor_[_i_] > _nS_
					_nF_ = _aFor_[_i_]
					exit
				ok
			next
			if _nF_ = 0
				exit
			ok

			_cBody_ = ring_trim(StzMid(_c_, _nS_ + 4, _nF_ - _nS_ - 4))
			_cTail_ = StzMid(_c_, _nF_ + 5, StzLen(_c_) - _nF_ - 4)

			# `for p in Products` -- the three words, then whatever the
			# surrounding relation still has to say
			_ac_ = This._Words(_cTail_)
			if len(_ac_) < 3 or StzLower(_ac_[2]) != "in"
				exit
			ok
			_cVar_ = StzLower(_ac_[1])
			_cSet_ = StzLower(_ac_[3])
			_acMem_ = This.MembersOf(_cSet_)
			if len(_acMem_) = 0
				exit
			ok

			# what follows `for v in Set` belongs to the enclosing
			# expression, not to the sum
			_nSkip_ = StzFindFirst(_ac_[3], _cTail_) + StzLen(_ac_[3])
			_cAfter_ = StzMid(_cTail_, _nSkip_, StzLen(_cTail_) - _nSkip_ + 1)

			_cSum_ = ""
			_m_ = len(_acMem_)
			for _j_ = 1 to _m_
				if _j_ > 1
					_cSum_ += " + "
				ok
				_cSum_ += "(" + This._Substitute(_cBody_, _cVar_, _acMem_[_j_]) + ")"
			next

			_c_ = StzLeft(_c_, _nS_ - 1) + _cSum_ + _cAfter_
		end
		return _c_

	# profit[p] with p := chairs  ->  the NUMBER 30 (a param) or the
	# variable name make_chairs. A param becomes its value because the
	# solver takes coefficients, not lookups.
	def _Substitute(pcExpr, pcVar, pcMember)
		_c_ = "" + pcExpr
		_nGuard_ = 0
		while 1
			_nGuard_++
			if _nGuard_ > 200
				exit
			ok
			_nB_ = StzFindFirst("[", _c_)
			if _nB_ = 0
				exit
			ok
			_nE_ = StzFindFirst("]", _c_)
			if _nE_ = 0 or _nE_ < _nB_
				exit
			ok
			# the bare name immediately before the bracket
			_nStart_ = _nB_ - 1
			while _nStart_ >= 1
				_ch_ = StzMid(_c_, _nStart_, 1)
				if This._IsNameChar(_ch_)
					_nStart_--
				else
					exit
				ok
			end
			_nStart_++
			_cName_ = StzLower(ring_trim(StzMid(_c_, _nStart_, _nB_ - _nStart_)))
			_cIdx_ = StzLower(ring_trim(StzMid(_c_, _nB_ + 1, _nE_ - _nB_ - 1)))

			_cMember_ = _cIdx_
			if pcVar != "" and _cIdx_ = pcVar
				_cMember_ = pcMember
			ok

			_cRep_ = ""
			if This._IsParam(_cName_)
				_cRep_ = "" + This.ParamValue(_cName_, _cMember_)
			else
				_cRep_ = This._Cell(_cName_, _cMember_)
			ok

			_c_ = StzLeft(_c_, _nStart_ - 1) + _cRep_ +
			      StzMid(_c_, _nE_ + 1, StzLen(_c_) - _nE_)
		end
		return _c_

	def _IsParam(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aParams)
		for _i_ = 1 to _n_
			if @aParams[_i_][1] = _c_
				return 1
			ok
		next
		return 0

	# A MEMBERSHIP TEST, NEVER A RANGE COMPARISON. Ring's >= and <=
	# coerce a string operand to a NUMBER, so `pcCh >= "a"` raises R41
	# ("invalid numeric string") on every letter -- the same trap
	# stzAgentRoster records for month keys, met here from the other side.
	# Digits happen to survive it, which is exactly what makes it a trap:
	# the obvious test passes on the case you try first.
	def _IsNameChar(pcCh)
		if pcCh = ""
			return 0
		ok
		_cSet_ = "abcdefghijklmnopqrstuvwxyz" +
			 "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
		return len(StzFind(pcCh, _cSet_)) > 0

	#-- the round trip ---------------------------------------------------
	#
	# Writing is not the mirror of reading and does not pretend to be:
	# what comes back is the EXPANDED model, because that is what the file
	# means. A round trip is checked by solving both and comparing the
	# AST, which is the claim that matters -- not by diffing the text,
	# which would only prove the writer echoes the reader.

	def ToZopt()
		_oM_ = This.ToModel()
		return StzModelToZopt(_oM_, @cName)

	def Save(pcPath)
		_cP_ = "" + pcPath
		if StzRight(_cP_, 5) != ".zopt"
			_cP_ += ".zopt"
		ok
		StzFileWrite(_cP_, This.ToZopt())
		return _cP_

# An expanded model as a flat .zopt -- no families, because expansion has
# already happened. Reading this back gives the same AST.
func StzModelToZopt(poModel, pcName)
	_c_ = "zopt: " + StzZoptVersion() + char(10)
	_cN_ = "" + pcName
	if _cN_ = ""
		_cN_ = "model"
	ok
	_c_ += "model: " + _cN_ + char(10)

	_acNames_ = poModel.VarNames()
	_n_ = len(_acNames_)
	for _i_ = 1 to _n_
		_aB_ = poModel.BoundsOf(_acNames_[_i_])
		_c_ += "var " + _acNames_[_i_] + ": " + _aB_[:lb]
		if _aB_[:bounded] = 1
			_c_ += " .. " + _aB_[:ub]
		ok
		if _aB_[:integer] = 1
			_c_ += " integer"
		ok
		_c_ += char(10)
	next

	_aObj_ = poModel.ObjectiveCoefficients()
	_cE_ = _StzZoptTerms(_aObj_, _acNames_)
	if poModel.Sense() = "max"
		_c_ += "maximize: " + _cE_ + char(10)
	else
		_c_ += "minimize: " + _cE_ + char(10)
	ok

	_c_ += "subject to:" + char(10)
	_m_ = poModel.NumberOfConstraints()
	for _i_ = 1 to _m_
		_aC_ = poModel.ConstraintAt(_i_)
		_c_ += "  " + _aC_[1] + ": " + _StzZoptTerms(_aC_[2], _acNames_) +
			" " + StzOptimOpWord(_aC_[3]) + " " + _aC_[4] + char(10)
	next
	return _c_

# coefficients as an expression. A zero coefficient is DROPPED, and a
# row of all zeros still has to say something the parser can read.
func _StzZoptTerms(paCoeffs, pacNames)
	_c_ = ""
	_n_ = len(pacNames)
	for _i_ = 1 to _n_
		_v_ = paCoeffs[_i_]
		if _v_ = 0
			loop
		ok
		if _c_ != ""
			if _v_ > 0
				_c_ += " + "
			else
				_c_ += " - "
				_v_ = -_v_
			ok
		else
			if _v_ < 0
				_c_ += "-"
				_v_ = -_v_
			ok
		ok
		_c_ += "" + _v_ + "*" + pacNames[_i_]
	next
	if _c_ = ""
		_c_ = "0*" + pacNames[1]
	ok
	return _c_
