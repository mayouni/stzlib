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

# Holds a linear or integer optimisation model that you write as variables, an objective and constraint texts, then solves it.
#
# Declare the variables with Vars or AddVar, set Maximize or Minimize, add constraints with
# SubjectTo, and Solve. A variable is bounded below (0 by default) and optionally above, and may be
# :integer or :binary. The built-in solver is a simplex with branch-and-bound; the :highs tier is
# refused because it is not vendored, so Why always names the engine that ran. Check IsOptimal
# before reading Solution: an infeasible or unbounded model leaves placeholder values. Violations
# re-checks the answer against the model. Known limit: a model with no constraint at all raises an
# error when solved, give it at least one constraint.
#
#   receiver   o1 = new stzOptimModel() o1.Vars([ :x = [0, 40], :y = [0, :integer] ])
#              o1.Maximize("3*x + 2*y") o1.SubjectTo([ "x + y <= 50", "2*x + y <= 80" ])
#   example    o1.Solve()
#              ? o1.IsOptimal()
#              #--> 1
#              ? o1.Objective()
#              #--> 130
#              ? @@( o1.Solution() )
#              #--> [ [ "x", 30 ], [ "y", 20 ] ]
#              ? o1.Branched()
#              #--> 1
#              ? o1.IsFeasibleAnswer()
#              #--> 1
#   see        stzLinearSolver, stzOptimFile, stzOptimSentence
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

	# Builds an empty model with no variable, no objective and no constraint.
	#
	#   returns    nothing; the object is built
	#   see        Vars, Maximize, SubjectTo
	def init()

	# Declares several variables at once from a list of name = spec pairs.
	#
	#   paSpec     pairs such as [ :x = [0, 40], :y = [0, :integer] ]
	#   returns    the model itself, so calls chain
	#   note       an omitted upper bound means unbounded above; names are kept in lower case
	#   warning    a non-list, an entry that is not a pair, a name declared twice and an unknown
	#              qualifier raise an error
	#   see        AddVar, BoundsOf
	#@ aka  -- 1. THE VARIABLES ------------------------------------------------
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

	# Declares one variable with its bounds and whether it is whole-valued.
	#
	#   pcName     the variable's name, lower-cased, never empty
	#   pSpec      a number (the lower bound) or a list as for Vars: bounds, then :integer or
	#              :binary
	#   returns    the model itself, so calls chain
	#   note       :binary means integer with bounds 0 and 1; a variable declared after the
	#              constraints widens the earlier rows with zeros
	#   warning    an empty name, a name declared twice and a qualifier other than :integer, :int,
	#              :binary or :bool raise an error
	#   see        Vars, BoundsOf, HasVar
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

	# TRUE if a variable of that name is declared.
	#
	#   pcName     the variable's name, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        VarNames, NumberOfVars
	def HasVar(pcName)
		return ring_find(@acVars, StzLower(ring_trim("" + pcName))) > 0

	# Returns how many variables are declared.
	#
	#   returns    a number
	#   see        VarNames, HasVar
	def NumberOfVars()
		return len(@acVars)

	# Returns the names of the variables, in lower case, in declaration order.
	#
	#   returns    a list of text
	#   see        NumberOfVars, BoundsOf
	def VarNames()
		return @acVars

	# Returns the declared bounds and kind of one variable.
	#
	#   pcName     the variable's name
	#   returns    a list [ :lb, :ub, :bounded, :integer ]; [ ] for an unknown name
	#   note       :ub is 0 and :bounded is 0 when the variable has no upper bound
	#   see        AddVar, VarNames
	def BoundsOf(pcName)
		_i_ = ring_find(@acVars, StzLower(ring_trim("" + pcName)))
		if _i_ = 0
			return []
		ok
		return [ :lb = @aLb[_i_], :ub = @aUb[_i_],
			 :bounded = @aHasUb[_i_], :integer = @aInt[_i_] ]

	# Sets the objective to maximize, from a linear expression over the declared variables.
	#
	#   pcExpr     a linear expression such as "3*x + 2*y + 1"
	#   returns    the model itself, so calls chain
	#   note       a second call replaces the objective
	#   warning    raises an error when no variable is declared yet or when the expression names
	#              something that is not a variable
	#   see        Minimize, ObjectiveCoefficients, SolveWith
	#@ aka  -- 2. THE OBJECTIVE ------------------------------------------------
	def Maximize(pcExpr)
		return This._SetObjective("max", pcExpr)

		def MaximizeQ(pcExpr)
			return This.Maximize(pcExpr)

	# Sets the objective to minimize, from a linear expression over the declared variables.
	#
	#   pcExpr     a linear expression such as "2*p + 3*q"
	#   returns    the model itself, so calls chain
	#   note       a second call replaces the objective
	#   warning    same errors as Maximize
	#   see        Maximize, SolveWith
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

	# Returns the direction of the objective.
	#
	#   returns    a text: max, min, or the empty text before an objective is set
	#   see        Maximize, Minimize
	def Sense()
		return @cSense

	# Returns the coefficient of each variable in the objective.
	#
	#   returns    a list of numbers, one per variable in declaration order; [ ] before an objective
	#              is set
	#   note       the constant of the expression is not in it; it is added to Objective after
	#              solving
	#   see        Maximize, VarNames
	def ObjectiveCoefficients()
		return @aObj

	# Adds constraints from a list of relation texts, or one constraint from a single text.
	#
	#   paList     a list of relations such as [ "x + y <= 50", "2*x + y <= 80" ], or one relation
	#              as text
	#   returns    the model itself, so calls chain
	#   note       the constraints are named c1, c2 and so on, in order added
	#   warning    raises an error for anything else, when no variable is declared, and for a text
	#              with no <=, >= or =
	#   see        AddConstraint, AddNamedConstraint
	#@ aka  -- 3. THE CONSTRAINTS ----------------------------------------------
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

	# Adds one constraint from a relation text, named automatically.
	#
	#   pcText     a relation such as "x + y <= 50", with <=, >= or =
	#   returns    the model itself, so calls chain
	#   note       the name is c followed by the count of constraints added without a name
	#   warning    the same errors as SubjectTo
	#   see        AddNamedConstraint, SubjectTo
	def AddConstraint(pcText)
		@nAutoCon++
		return This.AddNamedConstraint("c" + @nAutoCon, pcText)

	# Adds one constraint from a relation text under a name of your choice.
	#
	#   pcName     the constraint's name, kept in lower case
	#   pcText     a relation such as "n <= 5"
	#   returns    the model itself, so calls chain
	#   note       the variables are moved to the left side, so "2 >= x" is stored as the row -1
	#              against -2
	#   warning    the same errors as SubjectTo
	#   see        AddConstraint, ConstraintAt
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

	# Returns how many constraints the model holds.
	#
	#   returns    a number
	#   see        ConstraintAt
	def NumberOfConstraints()
		return len(@aCons)

	# Returns one stored constraint.
	#
	#   pnIndex    the position of the constraint, from 1
	#   returns    a list [ name, coefficients, operator, right side, text ]; the operator is -1 for
	#              <=, 1 for >= and 0 for =
	#   note       the coefficients are one per variable, in declaration order
	#   warning    an index outside 1 to NumberOfConstraints raises error R2, index out of range
	#   see        NumberOfConstraints
	def ConstraintAt(pnIndex)
		return @aCons[pnIndex]

	# Returns the model as a plain list that two descriptions can be compared by, rather than their answers.
	#
	#   returns    a list [ :sense, :vars, :obj, :objconst, :cons ]; each var row is [ name, lb, ub,
	#              bounded, integer ] and each constraint row [ name, coefficients, operator, right
	#              side ]
	#   note       two different wrong models can give the same answer, so a guard compares the ASTs
	#   see        ASTCore, ASTSignature
	#@ aka  -- THE AST ---------------------------------------------------------
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

	# Returns the same list as AST with the constraint names dropped.
	#
	#   returns    a list of the same shape; each constraint row is [ coefficients, operator, right
	#              side ]
	#   note       for comparing two descriptions that agree on the mathematics but label it
	#              differently
	#   see        AST, ASTSignature
	#@ aka  the same, with the constraint NAMES dropped -- for comparing two surfaces that agree on the mathematics and label it differently
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

	# Returns the model, without constraint names, as one canonical text.
	#
	#   returns    a text such as sense=max;const=1;obj=3,2;vars=x[0,3,1,0]...;cons=(1,1<=4)
	#   note       exists because Ring's = does not compare nested lists structurally; the texts can
	#              be printed side by side
	#   see        ASTCore
	#@ aka  THE AST AS ONE CANONICAL STRING, and it exists because Ring's `=` does not compare two nested lists structurally -- two ASTs whose every field printed identically still answered "not equal", so a guard written the obvious way would have failed while the surfaces agreed. A signature compares exactly, and when it differs it can be PRINTED side by side, which a list comparison never could.
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

	# Returns the model as it reads: the objective, the constraints and the bounds of the variables.
	#
	#   returns    a text of several lines
	#   see        Show
	#@ aka  the model as it reads, for a human and for a narration
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

	# Prints the model as Describe returns it.
	#
	#   returns    nothing; it prints
	#   see        Describe
	def Show()
		? This.Describe()

	# Solves the model with a named tier of the solver and keeps the answer.
	#
	#   pcTier     :auto, :floor or the empty text for the built-in simplex and branch-and-bound
	#   returns    the model itself, so calls chain
	#   note       whole-valued variables make the solver branch; Why names the engine that ran
	#   warning    raises an error for :highs (not vendored), for any other tier, when no objective
	#              is set, and for a model with no constraint at all, which the engine refuses today
	#              although the code says it solves
	#   see        Solve, Why, IsOptimal, Solution
	#@ aka  -- 4. SOLVING ------------------------------------------------------
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

	# Solves the model with the automatic tier.
	#
	#   returns    the model itself, so calls chain
	#   warning    the same errors as SolveWith, including a model with no constraint
	#   see        SolveWith, Why
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

	# TRUE if a solve has run, whatever it found.
	#
	#   returns    TRUE or FALSE
	#   see        IsOptimal, Status
	#@ aka  -- 5. READING THE ANSWER -------------------------------------------
	def IsSolved()
		return @bSolved

	# Returns the solver's status code.
	#
	#   returns    a number: 0 optimal, 1 unbounded, 2 infeasible, 3 iteration limit, 4 node limit;
	#              -1 before any solve
	#   see        StatusWord, IsOptimal
	def Status()
		return @nStatus

	# Returns the status in words.
	#
	#   returns    a text such as optimal, infeasible, unbounded or not solved
	#   see        Status, IsOptimal
	def StatusWord()
		return StzOptimStatusWord(@nStatus)

	# TRUE if a solve ran and found the optimum.
	#
	#   returns    TRUE or FALSE
	#   see        Status, Solution
	def IsOptimal()
		if @bSolved = 1 and @nStatus = 0
			return 1
		ok
		return 0

	# Returns the value of the objective at the answer, constant included.
	#
	#   returns    a number; 0 before a solve
	#   note       meaningful only when IsOptimal is TRUE: for an unbounded or infeasible model it
	#              is the engine's placeholder
	#   see        Solution, Status
	def Objective()
		return @nObjective

	# Returns each variable with its value at the answer.
	#
	#   returns    a list of [ name, value ] pairs in declaration order
	#   note       the values are placeholders when the model is infeasible or unbounded
	#   warning    before any solve it raises error R2, index out of range
	#   see        ValueOf, Objective, IsOptimal
	def Solution()
		_a_ = []
		_n_ = len(@acVars)
		for _i_ = 1 to _n_
			_a_ + [ @acVars[_i_], @aX[_i_] ]
		next
		return _a_

	# Returns the value of one variable at the answer.
	#
	#   pcName     the variable's name, matched without regard to case
	#   returns    a number
	#   warning    raises an error for an unknown name and before any solve
	#   see        Solution
	def ValueOf(pcName)
		_i_ = ring_find(@acVars, StzLower(ring_trim("" + pcName)))
		if _i_ = 0
			stzraise("stzOptimModel.ValueOf: no variable '" + pcName + "'.")
		ok
		if @bSolved = 0
			stzraise("stzOptimModel.ValueOf: nothing is solved yet.")
		ok
		return @aX[_i_]

	# Returns how many branch-and-bound nodes the last solve explored.
	#
	#   returns    a number; 0 before a solve
	#   see        Iterations, Branched
	def Nodes()
		return @nNodes

	# Returns how many simplex iterations the last solve took.
	#
	#   returns    a number; 0 before a solve
	#   see        Nodes
	def Iterations()
		return @nIterations

	# Returns 1 when the solve used branch-and-bound, which it does when a variable is whole-valued.
	#
	#   returns    1 or 0; 0 before a solve
	#   see        Nodes, Engine
	def Branched()
		return @bBranched

	# Returns the name of the engine that ran the last solve.
	#
	#   returns    a text such as "engine floor (Zig simplex + branch-and-bound)"; the empty text
	#              before a solve
	#   see        Why
	def Engine()
		return @cEngine

	# Returns the solver's account of itself: the tier chosen, the result, the objective and the point, and the work done.
	#
	#   returns    a text; "nothing has been solved yet" before a solve
	#   note       for an infeasible or unbounded model it states the result and gives no point
	#   see        ShowWhy, Engine
	#@ aka  LAW 3: the verdict explains itself, and NAMES THE TIER THAT RAN
	def Why()
		return @cWhy

	# Prints what Why returns.
	#
	#   returns    nothing; it prints
	#   see        Why
	def ShowWhy()
		? This.Why()

	# Checks the reported answer against every constraint, bound and whole-value requirement, to catch a confident wrong answer.
	#
	#   returns    a list of [ name, left side, operator, right side ] rows, one per breach; [ ]
	#              when none, and also [ ] unless the status is optimal
	#   note       a tolerance of 0.000001 is allowed
	#   see        IsFeasibleAnswer, Solution
	#@ aka  -- the honesty check any caller can run -----------------------------
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

	# TRUE if Violations finds no breach.
	#
	#   returns    TRUE or FALSE
	#   note       it is also TRUE when nothing has been solved or the model is infeasible, because
	#              Violations is empty then
	#   see        Violations
	def IsFeasibleAnswer()
		return len(This.Violations()) = 0
