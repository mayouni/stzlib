#=====================================================================#
#  STZOPTIMMODEL -- the ZIMPL-class modelling object (R4 step 5)      #
#=====================================================================#
/*
	SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.5. The design's own example,
	whole:

		oM = new stzOptimModel()
		oM.Vars([ :x = [0, 40], :y = [0, :integer] ])
		oM.Maximize("3*x + 2*y")
		oM.SubjectTo([ "x + y <= 50", "2*x + y <= 80" ])
		oM.SolveWith(:auto)
		? oM.Solution()   ? oM.Why()

	THE GAP THIS CLOSES was never the solving. `engine/src/simplex.zig`
	has run a real pivot loop since the numeric foundation's phase 5, and
	`stzLinearSolver` reaches it. What was missing is the MODELLING
	layer: today a caller hand-builds coefficient arrays, and the design's
	whole point is that they should write the model and let Softanza
	compile it.

	THREE SURFACES, ONE AST. This object is surface 1. `.zopt`
	(stzOptimFile) is surface 3 and `Naturally(...)` (stzOptimSentence)
	is surface 2, and BOTH BUILD THIS CLASS rather than a parallel one --
	they call Vars/Maximize/SubjectTo exactly as a caller would. That is
	what makes "one AST" checkable instead of asserted: AST() returns a
	plain comparable list, and the guard compares the ASTs of two
	surfaces rather than their answers, because two wrong models can
	agree on an answer.

	TWO TIERS, AND TODAY ONE OF THEM IS ABSENT. SolveWith(:auto) picks
	the engine and Why() NAMES THE ONE THAT RAN. The floor is
	engine/src/optim.zig (simplex + branch-and-bound, zero dependency);
	the upgrade tier is a vendored HiGHS and it is deliberately not built
	yet. So :highs is REFUSED rather than silently downgraded -- a
	caller who asks for a tier that does not exist is told, because a
	quiet fallback is how a two-tier claim becomes untrue.
*/

func StzOptimModelQ()
	return new stzOptimModel()

# status codes, as the engine returns them
func StzOptimStatusWord(pnStatus)
	if pnStatus = 0
		return "optimal"
	but pnStatus = 1
		return "unbounded"
	but pnStatus = 2
		return "infeasible"
	but pnStatus = 3
		return "iteration limit"
	but pnStatus = 4
		return "node limit"
	but pnStatus = 5
		return "a variable has no lower bound"
	ok
	return "not solved"

class stzOptimModel from stzObject

	@acVars = []          # names, in declaration order
	@aLb = []
	@aUb = []
	@aHasUb = []
	@aInt = []
	@cSense = ""          # "max" | "min"
	@aObj = []            # coefficients, one per variable
	@nObjConst = 0
	@cObjText = ""
	@aCons = []           # [ [ cName, aCoeffs, nOp, nRhs, cText ], ... ]
	@nAutoCon = 0

	@bSolved = 0
	@nStatus = -1
	@nObjective = 0
	@aX = []
	@nNodes = 0
	@nIterations = 0
	@bBranched = 0
	@cEngine = ""
	@cWhy = "nothing has been solved yet"

	def init()

	#-- 1. THE VARIABLES ------------------------------------------------
	#
	# [ :x = [0, 40], :y = [0, :integer] ] -- a spec is [lb], [lb, ub],
	# [lb, :integer] or [lb, ub, :integer]. An omitted upper bound means
	# UNBOUNDED ABOVE, which the engine models exactly rather than by a
	# large number standing in for infinity.

	def Vars(paSpec)
		if NOT isList(paSpec)
			stzraise("stzOptimModel.Vars: a variable block is a list of " +
				"name = spec pairs.")
		ok
		_n_ = len(paSpec)
		for _i_ = 1 to _n_
			_aE_ = paSpec[_i_]
			if NOT isList(_aE_) or len(_aE_) < 2
				stzraise("stzOptimModel.Vars: entry " + _i_ +
					" is not a 'name = spec' pair.")
			ok
			This.AddVar("" + _aE_[1], _aE_[2])
		next
		return This

		def VarsQ(paSpec)
			return This.Vars(paSpec)

	def AddVar(pcName, pSpec)
		_cN_ = StzLower(ring_trim("" + pcName))
		if _cN_ = ""
			stzraise("stzOptimModel.AddVar: a variable needs a name.")
		ok
		if This.HasVar(_cN_)
			stzraise("stzOptimModel.AddVar: '" + _cN_ + "' is declared twice.")
		ok

		_nLb_ = 0
		_nUb_ = 0
		_bHasUb_ = 0
		_bInt_ = 0

		if isNumber(pSpec)
			_nLb_ = pSpec
		but isList(pSpec)
			_m_ = len(pSpec)
			for _j_ = 1 to _m_
				_v_ = pSpec[_j_]
				if isNumber(_v_)
					if _j_ = 1
						_nLb_ = _v_
					else
						_nUb_ = _v_
						_bHasUb_ = 1
					ok
				else
					_cW_ = StzLower(ring_trim("" + _v_))
					if _cW_ = "integer" or _cW_ = "int"
						_bInt_ = 1
					but _cW_ = "binary" or _cW_ = "bool"
						_bInt_ = 1
						_nUb_ = 1
						_bHasUb_ = 1
					else
						stzraise("stzOptimModel: '" + _cW_ + "' is not a " +
							"variable qualifier -- the whole of it is " +
							":integer and :binary.")
					ok
				ok
			next
		ok

		@acVars + _cN_
		@aLb + _nLb_
		@aUb + _nUb_
		@aHasUb + _bHasUb_
		@aInt + _bInt_
		# a variable declared after a constraint would leave every earlier
		# coefficient vector one column short, so they are widened here
		This._WidenRows()
		return This

	def _WidenRows()
		_n_ = len(@acVars)
		if len(@aObj) > 0 and len(@aObj) < _n_
			while len(@aObj) < _n_
				@aObj + 0
			end
		ok
		_m_ = len(@aCons)
		for _i_ = 1 to _m_
			while len(@aCons[_i_][2]) < _n_
				@aCons[_i_][2] + 0
			end
		next

	def HasVar(pcName)
		return ring_find(@acVars, StzLower(ring_trim("" + pcName))) > 0

	def NumberOfVars()
		return len(@acVars)

	def VarNames()
		return @acVars

	def BoundsOf(pcName)
		_i_ = ring_find(@acVars, StzLower(ring_trim("" + pcName)))
		if _i_ = 0
			return []
		ok
		return [ :lb = @aLb[_i_], :ub = @aUb[_i_],
			 :bounded = @aHasUb[_i_], :integer = @aInt[_i_] ]

	#-- 2. THE OBJECTIVE ------------------------------------------------

	def Maximize(pcExpr)
		return This._SetObjective("max", pcExpr)

		def MaximizeQ(pcExpr)
			return This.Maximize(pcExpr)

	def Minimize(pcExpr)
		return This._SetObjective("min", pcExpr)

		def MinimizeQ(pcExpr)
			return This.Minimize(pcExpr)

	def _SetObjective(pcSense, pcExpr)
		if len(@acVars) = 0
			stzraise("stzOptimModel: declare the variables before the " +
				"objective -- an expression over nothing has no coefficients.")
		ok
		_a_ = StzLinearFormOf(pcExpr, @acVars)
		if _a_[:ok] = 0
			stzraise("stzOptimModel." + pcSense + ": " + _a_[:why])
		ok
		@cSense = pcSense
		@aObj = _a_[:coeffs]
		@nObjConst = _a_[:const]
		@cObjText = ring_trim("" + pcExpr)
		return This

	def Sense()
		return @cSense

	def ObjectiveCoefficients()
		return @aObj

	#-- 3. THE CONSTRAINTS ----------------------------------------------

	def SubjectTo(paList)
		if isString(paList)
			return This.AddConstraint(paList)
		ok
		if NOT isList(paList)
			stzraise("stzOptimModel.SubjectTo: a constraint block is a " +
				"list of relation strings.")
		ok
		_n_ = len(paList)
		for _i_ = 1 to _n_
			This.AddConstraint(paList[_i_])
		next
		return This

		def SubjectToQ(paList)
			return This.SubjectTo(paList)

	def AddConstraint(pcText)
		@nAutoCon++
		return This.AddNamedConstraint("c" + @nAutoCon, pcText)

	def AddNamedConstraint(pcName, pcText)
		if len(@acVars) = 0
			stzraise("stzOptimModel: declare the variables before the " +
				"constraints.")
		ok
		_a_ = StzLinearConstraintOf(pcText, @acVars)
		if _a_[:ok] = 0
			stzraise("stzOptimModel.SubjectTo: " + _a_[:why])
		ok
		@aCons + [ StzLower(ring_trim("" + pcName)), _a_[:coeffs],
			   _a_[:op], _a_[:rhs], ring_trim("" + pcText) ]
		return This

	def NumberOfConstraints()
		return len(@aCons)

	def ConstraintAt(pnIndex)
		return @aCons[pnIndex]

	#-- THE AST ---------------------------------------------------------
	#
	# The comparable form. Two surfaces agree when THIS is equal --
	# never when their answers are, because two different wrong models
	# can produce the same number and one guard would pass both.

	def AST()
		_aV_ = []
		_n_ = len(@acVars)
		for _i_ = 1 to _n_
			_aV_ + [ @acVars[_i_], @aLb[_i_], @aUb[_i_],
				 @aHasUb[_i_], @aInt[_i_] ]
		next
		_aC_ = []
		_m_ = len(@aCons)
		for _i_ = 1 to _m_
			_aC_ + [ @aCons[_i_][1], @aCons[_i_][2],
				 @aCons[_i_][3], @aCons[_i_][4] ]
		next
		return [ :sense = @cSense, :vars = _aV_, :obj = @aObj,
			 :objconst = @nObjConst, :cons = _aC_ ]

	# the same, with the constraint NAMES dropped -- for comparing two
	# surfaces that agree on the mathematics and label it differently
	def ASTCore()
		_a_ = This.AST()
		_aC_ = []
		_m_ = len(_a_[:cons])
		for _i_ = 1 to _m_
			_aC_ + [ _a_[:cons][_i_][2], _a_[:cons][_i_][3],
				 _a_[:cons][_i_][4] ]
		next
		return [ :sense = _a_[:sense], :vars = _a_[:vars],
			 :obj = _a_[:obj], :objconst = _a_[:objconst], :cons = _aC_ ]

	# THE AST AS ONE CANONICAL STRING, and it exists because Ring's `=`
	# does not compare two nested lists structurally -- two ASTs whose
	# every field printed identically still answered "not equal", so a
	# guard written the obvious way would have failed while the surfaces
	# agreed. A signature compares exactly, and when it differs it can be
	# PRINTED side by side, which a list comparison never could.
	def ASTSignature()
		_a_ = This.ASTCore()
		_c_ = "sense=" + _a_[:sense] + ";const=" + _a_[:objconst] + ";obj="
		_n_ = len(_a_[:obj])
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += ","
			ok
			_c_ += "" + _a_[:obj][_i_]
		next
		_c_ += ";vars="
		_n_ = len(_a_[:vars])
		for _i_ = 1 to _n_
			_v_ = _a_[:vars][_i_]
			_c_ += _v_[1] + "[" + _v_[2] + "," + _v_[3] + "," +
				_v_[4] + "," + _v_[5] + "]"
		next
		_c_ += ";cons="
		_n_ = len(_a_[:cons])
		for _i_ = 1 to _n_
			_r_ = _a_[:cons][_i_]
			_c_ += "("
			_m_ = len(_r_[1])
			for _j_ = 1 to _m_
				if _j_ > 1
					_c_ += ","
				ok
				_c_ += "" + _r_[1][_j_]
			next
			_c_ += StzOptimOpWord(_r_[2]) + _r_[3] + ")"
		next
		return _c_

	# the model as it reads, for a human and for a narration
	def Describe()
		_c_ = @cSense + " " + @cObjText + char(10)
		_c_ += "subject to:" + char(10)
		_n_ = len(@aCons)
		for _i_ = 1 to _n_
			_c_ += "  " + @aCons[_i_][1] + ": " + @aCons[_i_][5] + char(10)
		next
		_c_ += "where:" + char(10)
		_m_ = len(@acVars)
		for _i_ = 1 to _m_
			_c_ += "  " + @acVars[_i_] + " >= " + @aLb[_i_]
			if @aHasUb[_i_] = 1
				_c_ += ", <= " + @aUb[_i_]
			ok
			if @aInt[_i_] = 1
				_c_ += ", integer"
			ok
			_c_ += char(10)
		next
		return _c_

	def Show()
		? This.Describe()

	#-- 4. SOLVING ------------------------------------------------------

	# :auto picks the tier; :floor forces the Zig simplex+B&B; :highs is
	# the upgrade tier and is REFUSED while it is not vendored, because
	# answering with the floor would make the two-tier claim untrue.
	def SolveWith(pcTier)
		_cT_ = StzLower(ring_trim("" + pcTier))
		if _cT_ = ""
			_cT_ = "auto"
		ok
		if _cT_ = "highs"
			stzraise("stzOptimModel.SolveWith(:highs): the HiGHS upgrade " +
				"tier is not vendored in this build. Use :auto -- it picks " +
				"the engine floor and Why() says so. A silent downgrade is " +
				"how a two-tier claim stops being true.")
		ok
		if _cT_ != "auto" and _cT_ != "floor"
			stzraise("stzOptimModel.SolveWith: the tiers are :auto, :floor " +
				"and :highs (not yet vendored).")
		ok
		return This._SolveFloor(_cT_)

		def SolveWithQ(pcTier)
			return This.SolveWith(pcTier)

	def Solve()
		return This.SolveWith(:auto)

	def _SolveFloor(pcAsked)
		if @cSense = ""
			stzraise("stzOptimModel.Solve: no objective -- Maximize() or " +
				"Minimize() first.")
		ok
		_n_ = len(@acVars)
		_m_ = len(@aCons)

		_aMat_ = []
		_aSense_ = []
		_aRhs_ = []
		for _i_ = 1 to _m_
			for _j_ = 1 to _n_
				_aMat_ + @aCons[_i_][2][_j_]
			next
			_aSense_ + @aCons[_i_][3]
			_aRhs_ + @aCons[_i_][4]
		next
		# a model with no constraints still solves -- the bounds ARE the
		# feasible region, and the engine reads them as rows
		if _m_ = 0
			_aMat_ = []
			_aSense_ = []
			_aRhs_ = []
		ok

		_nMax_ = 0
		if @cSense = "max"
			_nMax_ = 1
		ok

		_aR_ = StzEngineOptimSolve(@aObj, _nMax_, @aLb, @aUb, @aHasUb,
			@aInt, _aMat_, _aSense_, _aRhs_, _n_, _m_, 0)

		if NOT isList(_aR_)
			@bSolved = 0
			@cWhy = "the engine refused the model -- check that every " +
				"coefficient row has one entry per variable"
			stzraise("stzOptimModel.Solve: " + @cWhy)
		ok

		@nStatus = _aR_[1]
		@nObjective = _aR_[2] + @nObjConst
		@nNodes = _aR_[3]
		@nIterations = _aR_[4]
		@bBranched = _aR_[5]
		@aX = []
		for _j_ = 1 to _n_
			@aX + _aR_[5 + _j_]
		next
		@bSolved = 1
		@cEngine = "engine floor (Zig simplex"
		if @bBranched = 1
			@cEngine += " + branch-and-bound"
		ok
		@cEngine += ")"
		This._Narrate(pcAsked)
		return This

	def _Narrate(pcAsked)
		_c_ = ""
		if pcAsked = "auto"
			_c_ = "SolveWith(:auto) chose the " + @cEngine +
				" -- it is the only tier built in this build; the HiGHS " +
				"upgrade tier is not vendored yet"
		else
			_c_ = "SolveWith(:floor) ran the " + @cEngine
		ok
		_c_ += ". Result: " + StzOptimStatusWord(@nStatus) + "."
		if @nStatus = 0
			_c_ += " Objective " + @nObjective + " at "
			_n_ = len(@acVars)
			for _i_ = 1 to _n_
				if _i_ > 1
					_c_ += ", "
				ok
				_c_ += @acVars[_i_] + " = " + @aX[_i_]
			next
			_c_ += "."
		but @nStatus = 4
			_c_ += " A feasible point was found and the search ran out of " +
				"nodes before proving it optimal -- the answer is usable " +
				"and unproven, and those are different claims."
		ok
		_c_ += " (" + @nNodes + " node(s), " + @nIterations + " simplex " +
			"iteration(s).)"
		@cWhy = _c_

	#-- 5. READING THE ANSWER -------------------------------------------

	def IsSolved()
		return @bSolved

	def Status()
		return @nStatus

	def StatusWord()
		return StzOptimStatusWord(@nStatus)

	def IsOptimal()
		if @bSolved = 1 and @nStatus = 0
			return 1
		ok
		return 0

	def Objective()
		return @nObjective

	def Solution()
		_a_ = []
		_n_ = len(@acVars)
		for _i_ = 1 to _n_
			_a_ + [ @acVars[_i_], @aX[_i_] ]
		next
		return _a_

	def ValueOf(pcName)
		_i_ = ring_find(@acVars, StzLower(ring_trim("" + pcName)))
		if _i_ = 0
			stzraise("stzOptimModel.ValueOf: no variable '" + pcName + "'.")
		ok
		if @bSolved = 0
			stzraise("stzOptimModel.ValueOf: nothing is solved yet.")
		ok
		return @aX[_i_]

	def Nodes()
		return @nNodes

	def Iterations()
		return @nIterations

	def Branched()
		return @bBranched

	def Engine()
		return @cEngine

	# LAW 3: the verdict explains itself, and NAMES THE TIER THAT RAN
	def Why()
		return @cWhy

	def ShowWhy()
		? This.Why()

	#-- the honesty check any caller can run -----------------------------
	#
	# Does the reported point actually satisfy the model? A solver that
	# returns a confident wrong answer is the failure this catches, and
	# it costs one pass over the rows.
	def Violations()
		_a_ = []
		if @bSolved = 0 or @nStatus != 0
			return _a_
		ok
		_n_ = len(@acVars)
		_m_ = len(@aCons)
		for _i_ = 1 to _m_
			_nL_ = 0
			for _j_ = 1 to _n_
				_nL_ += @aCons[_i_][2][_j_] * @aX[_j_]
			next
			_nR_ = @aCons[_i_][4]
			_nOp_ = @aCons[_i_][3]
			_bBad_ = 0
			if _nOp_ = -1 and _nL_ > _nR_ + 0.000001
				_bBad_ = 1
			but _nOp_ = 1 and _nL_ < _nR_ - 0.000001
				_bBad_ = 1
			but _nOp_ = 0 and fabs(_nL_ - _nR_) > 0.000001
				_bBad_ = 1
			ok
			if _bBad_ = 1
				_a_ + [ @aCons[_i_][1], _nL_, StzOptimOpWord(_nOp_), _nR_ ]
			ok
		next
		# the bounds are constraints too, and an integer variable that
		# came back fractional is the same kind of lie
		for _j_ = 1 to _n_
			if @aX[_j_] < @aLb[_j_] - 0.000001
				_a_ + [ "bound:" + @acVars[_j_], @aX[_j_], ">=", @aLb[_j_] ]
			ok
			if @aHasUb[_j_] = 1 and @aX[_j_] > @aUb[_j_] + 0.000001
				_a_ + [ "bound:" + @acVars[_j_], @aX[_j_], "<=", @aUb[_j_] ]
			ok
			if @aInt[_j_] = 1
				if fabs(@aX[_j_] - floor(@aX[_j_] + 0.5)) > 0.000001
					_a_ + [ "integer:" + @acVars[_j_], @aX[_j_], "=", "whole" ]
				ok
			ok
		next
		return _a_

	def IsFeasibleAnswer()
		return len(This.Violations()) = 0
