
/*
	stzLinear - Linear Programming Component for Softanza
	stzLinearSolver - Linear Programming Component for Softanza
	Provides simple yet practical linear optimization capabilities
	Author: Softanza Team
	Version: 1.0
*/

class stzLinear from stzObject
class stzLinearSolver from stzObject

	@variables = []
	@constraints = []
	@objective = ""
	@objectiveType = "maximize"  # "maximize" or "minimize"
	@aSolution = new stzHashList([])
	@status = ""
	@iterations = 0
	@solveTime = 0
	@aCoeffCache = []   # expression text -> parsed [ [name, coeff], ... ]

	def init()
		# Initialize with empty problem
		this.clear()

	def clear()
		@variables = []
		@constraints = []
		@objective = ""
		@objectiveType = "maximize"
		@aSolution = new stzHashList([])
		@status = ""
		@iterations = 0
		@solveTime = 0

	  #------------------------#
	 #  VARIABLES MANAGEMENT  #
	#------------------------#

	def addVariable(varName, _lowerBound_, _upperBound_)
		if NOT isString(varName)
			stzRaise("Variable name must be a string!")
		ok

		if isString(_lowerBound_) and _lowerBound_ = ""
			_lowerBound_ = _upperBound_
		ok

		if isString(_upperBound_) and _upperBound_ = ""
			_upperBound_ = _lowerBound_
		ok

		if isString(_lowerBound_) and _lowerBound_ = "" and
		    isString(_upperBound_) and _upperBound_ = ""

				_lowerBound_ = 0
				_upperBound_ = 0
		ok

		if NOT (isNumber(_lowerBound_) and isNumber(_upperBound_))
			stzRaise("Bounds must be numbers!")
		ok

		if _upperBound_ < _lowerBound_
			stzRaise("Upper bound must be >= lower bound!")
		ok

		_aVar_ = [
			:name = varName,
			:lowerBound = _lowerBound_,
			:upperBound = _upperBound_,
			:type = "continuous"  # "continuous", "integer", "binary"
		]

		@variables + _aVar_
		return this

	def addIntegerVariable(varName, _lowerBound_, _upperBound_)
		# Was `@variables + [:type, "integer"]` -- appends a malformed
		# pair to the variables list instead of modifying the just-
		# added variable's :type field. The added variable kept its
		# default "continuous" type.
		this.addVariable(varName, _lowerBound_, _upperBound_)
		@variables[ len(@variables) ][:type] = "integer"
		return this

	def addBinaryVariable(varName)
		# Same bug as addIntegerVariable.
		this.addVariable(varName, 0, 1)
		@variables[ len(@variables) ][:type] = "binary"
		return this

	def variables()
		return @variables

	def variableNames()
		_aNames_ = []
		_nVariablesLen_ = len(@variables)
		for i = 1 to _nVariablesLen_
			_aNames_ + @variables[i][:name]
		next
		return _aNames_

	  #--------------------------#
	 #  CONSTRAINTS MANAGEMENT  #
	#--------------------------#

	def addConstraint(expression, operator, _value_)
		# expression: string like "2*x + 3*y"
		# operator: "<=", ">=", "="
		# value: number

		if NOT isString(expression)
			# Was duplicated -- second raise was dead code after first.
			stzRaise("Expression must be a string!")
		ok

		if NOT isString(operator)
			StzRaise("Operator must be a string!")
		ok

		if NOT (operator = "<=" or operator = ">=" or operator = "=")
			stzRaise("Operator must be '<=', '>=', or '='!")
		ok

		if isString(_value_)
			_value_ = @variables[_value_]
			if @trim(_value_) = ""
				_value_ = 0
			ok
		ok

		if NOT isNumber(_value_)
			stzRaise("Value must be a number!")
		ok

		_oConstraint_ = new stzHashList([
			:expression = expression,
			:operator = operator,
			:value = _value_
		])

		@constraints + _oConstraint_
		return this

	def constraints()
		return @constraints

	  #----------------------#
	 #  OBJECTIVE FUNCTION  #
	#----------------------#

	def maximize(expression)
		@objective = expression
		@objectiveType = "maximize"
		return this

	def minimize(expression)
		@objective = expression
		@objectiveType = "minimize"
		return this

	def objective()
		return @objective

	def objectiveType()
		return @objectiveType

	  #-----------#
	 #  SOLVING  #
	#-----------#

	def solve(_cSolver_)
		if isNull(_cSolver_) or _cSolver_ = ""
			_cSolver_ = "greedy"  # Default solver
		ok

		_nStartTime_ = clock()

		# Validate problem
		if len(@variables) = 0
			stzRaise("No variables defined!")
		ok

		if @objective = ""
			stzRaise("No objective function defined!")
		ok

		# Choose solver based on problem characteristics and user preference
		switch _cSolver_
		on "greedy"
			_aSolution_ = this.solveWithGreedy()
		on "simplex"
			_aSolution_ = this.solveWithSimplex()
		on "branch_bound"
			_aSolution_ = this.solveWithBranchAndBound()
		on "genetic"
			_aSolution_ = this.solveWithGenetic()
		other
			stzRaise("Unknown solver: " + _cSolver_)
		off

		@solveTime = (clock() - _nStartTime_) / clockspersecond()
		@aSolution = _aSolution_

		return this

	  #--------------------#
	 #  BUILT-IN SOLVERS  #
	#--------------------#

	def solveWithGreedy()
		# Greedy solver: maximize efficiency ratio for each variable
		@status = "optimal"
		@iterations = len(@variables)
		
		# Parse objective coefficients
		_aCoeffs_ = this.parseObjectiveCoefficients()
		_aVarNames_ = this.variableNames()
		_aSolution_ = []
		
		# Initialize solution with lower bounds
		_nLen_ = len(_aVarNames_)
		for i = 1 to _nLen_
			_aSolution_ + [_aVarNames_[i], @variables[i][:lowerBound]]
		next
		
		# Calculate efficiency ratios and sort variables
		_aEfficiency_ = []
		_nLen_ = len(_aVarNames_)
		for i = 1 to _nLen_
			_nCoeff_ = _aCoeffs_[i]
			_nResourceCost_ = this.calculateResourceCost(_aVarNames_[i])
			_nEfficiency_ = 0
			if _nResourceCost_ > 0
				_nEfficiency_ = _nCoeff_ / _nResourceCost_
			ok
			_aEfficiency_ + [_aVarNames_[i], _nEfficiency_, i]
		next
		
		# Sort by efficiency (descending for maximize, ascending for minimize)
		if @objectiveType = "maximize"
			_aEfficiency_ = sorton(_aEfficiency_, 2)  # Sort by efficiency desc
			_aEfficiency_ = reverse(_aEfficiency_)
		else
			_aEfficiency_ = sorton(_aEfficiency_, 2)  # Sort by efficiency asc
		ok
		
		# Greedily allocate resources
		_nLenEff_ = len(_aEfficiency_)
		for i = 1 to _nLenEff_
			_cVarName_ = _aEfficiency_[i][1]
			_nVarIndex_ = _aEfficiency_[i][3]
			_nMaxPossible_ = this.calculateMaxPossibleValue(_cVarName_, _aSolution_)
			_nUpperBound_ = @variables[_nVarIndex_][:upperBound]
			_nValue_ = min([_nMaxPossible_, 0+_nUpperBound_])
			
			# Update solution
			_nLenSol_ = len(_aSolution_)
			for j = 1 to _nLenSol_
				if _aSolution_[j][1] = _cVarName_
					_aSolution_[j][2] = _nValue_
					exit
				ok
			next
		next
		
		return _aSolution_

	def solveWithSimplex()
		# REAL SIMPLEX (R4 step 5 floor, 2026-07-14) -- the S0 honesty
		# raise replaced WITH the capability: Big-M dense tableau.
		# Bounded variables via the shift x = lo + x' (plus explicit
		# x' <= hi-lo rows); <= gets a slack, >= a surplus+artificial,
		# = an artificial. Floor scale (dense, small/mid models);
		# the engine/HiGHS tiers are the R4 ladder's next rungs.
		@status = "optimal"
		@iterations = 0
		_aVarNames_ = this.variableNames()
		_nV_ = len(_aVarNames_)
		_aObjC_ = this.parseObjectiveCoefficients()

		_nSign_ = 1
		if @objectiveType != "maximize"
			_nSign_ = -1
		ok

		# rows: [ coeffs(nV), rhs, type ] with rhs shifted by lower bounds
		_aRows_ = []
		_nC_ = len(@constraints)
		for i = 1 to _nC_
			_aCf_ = []
			_nRhs_ = 0 + @constraints[i][:value]
			for j = 1 to _nV_
				_nCo_ = this.extractCoefficient(@constraints[i][:expression], _aVarNames_[j])
				_aCf_ + _nCo_
				_nRhs_ -= _nCo_ * (0 + @variables[j][:lowerBound])
			next
			_cOp_ = @constraints[i][:operator]
			_cTy_ = "le"
			if _cOp_ = ">="
				_cTy_ = "ge"
			ok
			if _cOp_ = "="
				_cTy_ = "eq"
			ok
			if _nRhs_ < 0
				for j = 1 to _nV_
					_aCf_[j] = -_aCf_[j]
				next
				_nRhs_ = -_nRhs_
				if _cTy_ = "le"
					_cTy_ = "ge"
				but _cTy_ = "ge"
					_cTy_ = "le"
				ok
			ok
			_aRows_ + [ _aCf_, _nRhs_, _cTy_ ]
		next

		# bound rows x' <= hi - lo (skip effectively-unbounded)
		for j = 1 to _nV_
			_nHi_ = 0 + @variables[j][:upperBound]
			_nLo_ = 0 + @variables[j][:lowerBound]
			if (_nHi_ - _nLo_) < 1000000000
				_aCf_ = []
				for k = 1 to _nV_
					if k = j
						_aCf_ + 1
					else
						_aCf_ + 0
					ok
				next
				_aRows_ + [ _aCf_, _nHi_ - _nLo_, "le" ]
			ok
		next

		_nM_ = len(_aRows_)
		_nSlackCount_ = 0
		_nArtCount_ = 0
		for i = 1 to _nM_
			if _aRows_[i][3] = "le"
				_nSlackCount_++
			but _aRows_[i][3] = "ge"
				_nSlackCount_++
				_nArtCount_++
			else
				_nArtCount_++
			ok
		next
		_nCols_ = _nV_ + _nSlackCount_ + _nArtCount_ + 1
		_nBigM_ = 1000000
		_nSlackAt_ = _nV_
		_nArtAt_ = _nV_ + _nSlackCount_

		_aT_ = []
		_aBasis_ = []
		_nSl_ = 0
		_nAr_ = 0
		for i = 1 to _nM_
			_aRow_ = []
			for j = 1 to _nCols_
				_aRow_ + 0
			next
			for j = 1 to _nV_
				_aRow_[j] = _aRows_[i][1][j]
			next
			_aRow_[_nCols_] = _aRows_[i][2]
			if _aRows_[i][3] = "le"
				_nSl_++
				_aRow_[_nSlackAt_ + _nSl_] = 1
				_aBasis_ + (_nSlackAt_ + _nSl_)
			but _aRows_[i][3] = "ge"
				_nSl_++
				_aRow_[_nSlackAt_ + _nSl_] = -1
				_nAr_++
				_aRow_[_nArtAt_ + _nAr_] = 1
				_aBasis_ + (_nArtAt_ + _nAr_)
			else
				_nAr_++
				_aRow_[_nArtAt_ + _nAr_] = 1
				_aBasis_ + (_nArtAt_ + _nAr_)
			ok
			_aT_ + _aRow_
		next

		# reduced-cost row (maximization): -c for structurals, +M for
		# artificials, then eliminate the artificial basics
		_aZ_ = []
		for j = 1 to _nCols_
			_aZ_ + 0
		next
		for j = 1 to _nV_
			_aZ_[j] = -(_nSign_ * _aObjC_[j])
		next
		for j = 1 to _nArtCount_
			_aZ_[_nArtAt_ + j] = _nBigM_
		next
		for i = 1 to _nM_
			if _aBasis_[i] > _nArtAt_
				for j = 1 to _nCols_
					_aZ_[j] -= _nBigM_ * _aT_[i][j]
				next
			ok
		next

		# THE PIVOT LOOP RUNS IN THE ENGINE (phase 5 slice 2 of the numeric
		# foundation). Everything above this point -- parsing the constraint
		# strings, extracting coefficients, shifting by the lower bounds, laying
		# out slack and artificial columns, building the Big-M objective row --
		# stays in Ring, because it MEASURED at 0.005s and flat. Only the pivoting
		# was slow:
		#
		#     vars x cons     build      solve (before)
		#     10 x 8          0.001s     0.051s
		#     20 x 15         0.002s     0.353s
		#     40 x 30         0.005s     2.620s
		#
		# Per iteration the loop below did O(rows x cols) reads and writes into a
		# NESTED LIST OF BOXED VALUES -- roughly a million of them for a
		# 40-variable model. That is the cost; the arithmetic is trivial.
		#
		# The engine reproduces this loop EXACTLY: same most-negative entering
		# rule with the first index winning ties, same minimum-ratio leaving rule
		# with the first row winning ties, same tolerances. A different but equally
		# valid pivot rule would settle on a different vertex of the same optimal
		# face when the problem is degenerate -- still optimal, but a different
		# reported solution, which would silently change every existing answer.

		_aFlatT_ = []
		for i = 1 to _nM_
			for j = 1 to _nCols_
				_aFlatT_ + _aT_[i][j]
			next
		next

		_aRunRes_ = StzEngineSimplexRun(_aFlatT_, _aZ_, _aBasis_,
		                                _nM_, _nCols_, _nArtAt_, _nV_)

		if NOT isList(_aRunRes_) or len(_aRunRes_) < 2 + _nV_
			StzRaise("stzLinearSolver: the engine simplex returned an unusable result.")
		ok

		_nStatusCode_ = _aRunRes_[1]
		@iterations = _aRunRes_[2]

		if _nStatusCode_ = 1
			@status = "unbounded"
		but _nStatusCode_ = 2
			@status = "infeasible"
		but _nStatusCode_ = 3
			@status = "iteration_limit"
		ok

		# x' comes back already extracted from the final tableau; the shift back to
		# x = lo + x' still happens below, where it always did.
		_aEngineX_ = []
		for j = 1 to _nV_
			_aEngineX_ + _aRunRes_[2 + j]
		next

		# shift back to x = lo + x'. The engine already read x' out of the final
		# tableau, so the search through the basis that used to live here is gone
		# with the loop it belonged to.
		_aSolution_ = []
		for j = 1 to _nV_
			_nVal_ = (0 + @variables[j][:lowerBound]) + _aEngineX_[j]
			_aSolution_ + [ _aVarNames_[j], _nVal_ ]
		next
		return _aSolution_

	def solveWithBranchAndBound()
		# HONESTY GUARD (S0, 2026-07-14): branch-and-bound rides the
		# simplex relaxation, which is not implemented yet (see
		# solveWithSimplex). Refuse loudly until R4.
		@status = "unimplemented"
		raise("Branch-and-bound needs the simplex relaxation, which is not implemented yet. Use Solve('greedy') or Solve('genetic') until the real simplex lands (R4).")

		# -- unreachable legacy scaffolding kept for the R4 rebuild --
		@status = "optimal"
		@iterations = 0
		
		# First solve LP relaxation
		_oRelaxed_ = this.createRelaxedProblem()
		_aSolution_ = _oRelaxed_.solveWithSimplex()
		
		# Check if solution is already integer
		if this.isIntegerSolution(_aSolution_)
			return _aSolution_
		ok
		
		# Branch and bound search
		_aBestSolution_ = _aSolution_
		_nBestValue_ = this.evaluateSolution(_aSolution_)
		
		_aBranches_ = [_aSolution_]
		
		while len(_aBranches_) > 0 and @iterations < 100
			@iterations++
			
			# Get next branch
			_aCurrentSolution_ = _aBranches_[1]
			del(_aBranches_, 1)
			
			# Find fractional variable
			_cFracVar_ = this.findFractionalVariable(_aCurrentSolution_)
			if _cFracVar_ = ""
				loop
			ok
			
			_nFracValue_ = this.getSolutionValue(_aCurrentSolution_, _cFracVar_)
			
			# Create two branches
			_aBranch1_ = this.addBranchConstraint(_aCurrentSolution_, _cFracVar_, "<=", floor(_nFracValue_))
			_aBranch2_ = this.addBranchConstraint(_aCurrentSolution_, _cFracVar_, ">=", ceil(_nFracValue_))
			
			# Evaluate branches
			_aABranch1aBranch21_ = [_aBranch1_, _aBranch2_]
			_nABranch1aBranch21Len_ = len(_aABranch1aBranch21_)
			for _iLoopABranch1aBranch21_ = 1 to _nABranch1aBranch21Len_
				_aBranch_ = _aABranch1aBranch21_[_iLoopABranch1aBranch21_]
				if this.isFeasible(_aBranch_)
					_nValue_ = this.evaluateSolution(_aBranch_)
					
					if this.isBetter(_nValue_, _nBestValue_)
						if this.isIntegerSolution(_aBranch_)
							_aBestSolution_ = _aBranch_
							_nBestValue_ = _nValue_
						else
							_aBranches_ + _aBranch_
						ok
					ok
				ok
			next
		end
		
		return _aBestSolution_

	def solveWithGenetic()
		# Genetic algorithm for complex problems
		@status = "optimal"
		@iterations = 0
		
		_nPopSize_ = 50
		_nGenerations_ = 100
		_nMutationRate_ = 0.1
		
		# Initialize population
		_aPopulation_ = this.initializePopulation(_nPopSize_)
		_aBestSolution_ = _aPopulation_[1]
		_nBestFitness_ = this.calculateFitness(_aBestSolution_)
		
		for nGen = 1 to _nGenerations_
			@iterations++
			
			# Evaluate fitness for all individuals
			_aFitness_ = []
			_nLen_ = len(_aPopulation_)
			for i = 1 to _nLen_
				_nFit_ = this.calculateFitness(_aPopulation_[i])
				_aFitness_ + _nFit_
				
				# Track best solution
				if this.isBetter(_nFit_, _nBestFitness_)
					_aBestSolution_ = _aPopulation_[i]
					_nBestFitness_ = _nFit_
				ok
			next
			
			# Create next generation
			_aNewPopulation_ = []
			
			for i = 1 to _nPopSize_
				# Selection (tournament)
				_aParent1_ = this.tournamentSelection(_aPopulation_, _aFitness_)
				_aParent2_ = this.tournamentSelection(_aPopulation_, _aFitness_)
				
				# Crossover
				_aChild_ = this.crossover(_aParent1_, _aParent2_)
				
				# Mutation
				if StzEngineRandomInt(0, 100)/100 < _nMutationRate_
					_aChild_ = this.mutate(_aChild_)
				ok
				
				_aNewPopulation_ + _aChild_
			next
			
			_aPopulation_ = _aNewPopulation_
		next
		
		return _aBestSolution_

	  #-------------------------#
	 #  SOLVER HELPER METHODS  #
	#-------------------------#

	def parseObjectiveCoefficients()
		# Extract coefficients from objective function
		_aCoeffs_ = []
		_aVarNames_ = this.variableNames()
		_nLen_ = len(_aVarNames_)

		for i = 1 to _nLen_
			_cVar_ = _aVarNames_[i]
			_nCoeff_ = this.extractCoefficient(@objective, _cVar_)
			_aCoeffs_ + _nCoeff_
		next
		
		return _aCoeffs_

	# PARSE EACH EXPRESSION ONCE, not once per variable.
	#
	# MEASURED (phase 5 slice 2 of the numeric foundation). On a 40-variable,
	# 30-constraint model, Solve("simplex") took 2.59s -- and 2.47s of it, 95%,
	# was this function. It is called once per (constraint, variable) pair, and
	# each call re-parsed the ENTIRE constraint string from scratch: lower it,
	# rewrite the minus signs, split on "+", then walk every term. Parsing a
	# 40-term expression once per variable does forty times the necessary work,
	# so the cost grew as constraints x variables x terms -- CUBIC in the model
	# size, for a parse that is linear.
	#
	# The plan said to move the SIMPLEX to the engine. The pivot loop turned out
	# to be about 0.1s of that 2.59s: moving it changed the total from 2.620s to
	# 2.603s, which is nothing. The cost was never the arithmetic -- it was
	# re-reading the same strings. Same shape as the CSV module, where 3.1s per
	# 2000 rows was a regex being recompiled per cell.
	#
	# So the expression is parsed once into [ [name, coefficient], ... ] and
	# cached by its own text. Every one of the seven call sites keeps its exact
	# signature and semantics -- nothing above this line had to change.

	# Is this token a number rather than a variable name? One pass over its bytes.
	def _LooksNumeric(_cTok_)
		if _cTok_ = ""
			return 0
		ok
		_nLenT_ = len(_cTok_)
		_bDigit_ = 0
		for _iLn_ = 1 to _nLenT_
			_nA_ = ascii(_cTok_[_iLn_])
			if _nA_ >= 48 and _nA_ <= 57
				_bDigit_ = 1
			but _nA_ != 46 and _nA_ != 43 and _nA_ != 45
				return 0
			ok
		next
		return _bDigit_

	def _ParsedTermsOf(_cExpression_)
		_nCacheLen_ = len(@aCoeffCache)
		for _iPc_ = 1 to _nCacheLen_
			if @aCoeffCache[_iPc_][1] = _cExpression_
				return @aCoeffCache[_iPc_][2]
			ok
		next

		# The parse itself, term for term as it always was: split on +/- , then
		# read 'k*var', 'var*k' or a bare 'var', with EXACT token matching so
		# 'rd' never matches inside 'yard'.
		_cE_ = StzLower(StzReplace(" " + _cExpression_, "-", "+-"))
		_acTerms_ = StzSplit(_cE_, "+")
		_aPairs_ = []
		_nT_ = len(_acTerms_)
		for _i_ = 1 to _nT_
			_cT_ = StzReplace(ring_trim(_acTerms_[_i_]), " ", "")
			if _cT_ = ""
				loop
			ok
			_nSg_ = 1
			if StzLeft(_cT_, 1) = "-"
				_nSg_ = -1
				_cT_ = StzRight(_cT_, StzLen(_cT_) - 1)
			ok

			_cName_ = ""
			_nCoef_ = 0
			if len(StzFind("*", _cT_)) > 0
				_acF_ = StzSplit(_cT_, "*")
				if len(_acF_) = 2
					_cF1_ = ring_trim(_acF_[1])
					_cF2_ = ring_trim(_acF_[2])
					# 'k*var' or 'var*k' -- whichever side is not the number
					if _cF1_ != "" and _cF2_ != ""
						# which side is the number? A CHARACTER SCAN, not a regex
						# -- @IsNumberInString recompiles one per call, which is
						# the very cost this change exists to remove (the CSV
						# module lost 3.1s per 2000 rows to exactly that).
						if This._LooksNumeric(_cF1_)
							_cName_ = _cF2_
							_nCoef_ = _nSg_ * ring_number(_cF1_)
						but This._LooksNumeric(_cF2_)
							_cName_ = _cF1_
							_nCoef_ = _nSg_ * ring_number(_cF2_)
						ok
					ok
				ok
			else
				_cName_ = _cT_
				_nCoef_ = _nSg_
			ok

			if _cName_ != ""
				# a variable may appear more than once in one expression, so the
				# terms ACCUMULATE, exactly as the per-variable version did
				_bFound_ = 0
				_nPl_ = len(_aPairs_)
				for _k_ = 1 to _nPl_
					if _aPairs_[_k_][1] = _cName_
						_aPairs_[_k_][2] += _nCoef_
						_bFound_ = 1
						exit
					ok
				next
				if NOT _bFound_
					_aPairs_ + [ _cName_, _nCoef_ ]
				ok
			ok
		next

		@aCoeffCache + [ _cExpression_, _aPairs_ ]
		return _aPairs_

	def extractCoefficient(_cExpression_, _cVarName_)
		_cV_ = StzLower(ring_trim(_cVarName_))
		_aPairs_ = This._ParsedTermsOf(_cExpression_)
		_nLenP_ = len(_aPairs_)
		for _iEc_ = 1 to _nLenP_
			if _aPairs_[_iEc_][1] = _cV_
				return _aPairs_[_iEc_][2]
			ok
		next
		return 0

	def calculateResourceCost(_cVarName_)
		# Calculate total resource cost for one unit of variable
		_nTotalCost_ = 0
		_nLen_ = len(@constraints)
		for i = 1 to _nLen_
			_aConst_ = @constraints[i]
			_nCoeff_ = this.extractCoefficient(_aConst_[:expression], _cVarName_)
			_nTotalCost_ += abs(_nCoeff_)
		next
		
		return _nTotalCost_

	def CalculateMaxPossibleValue(_cVarName_, _aSolution_)
		# Calculate maximum possible value considering constraints
		_nMinLimit_ = 999999
		_nLen_ = len(@constraints)
		for i = 1 to _nLen_
			_aConst_ = @constraints[i]
			_nCoeff_ = this.extractCoefficient(_aConst_[:expression], _cVarName_)
			
			if _nCoeff_ != 0
				# Calculate used resources by other variables
				_nUsedResources_ = 0
				_aVarNames_ = this.variableNames()
				_nLenVar_ = len(_aVarNames_)
				for j = 1 to _nLenVar_
					if _aVarNames_[j] != _cVarName_
						_nVarCoeff_ = this.extractCoefficient(_aConst_[:expression], _aVarNames_[j])
						_nVarValue_ = this.getSolutionValue(_aSolution_, _aVarNames_[j])
						_nUsedResources_ += _nVarCoeff_ * _nVarValue_
					ok
				next
				
				# Calculate remaining capacity
				_nRemainingCapacity_ = _aConst_[:value] - _nUsedResources_
				
				if _nCoeff_ > 0
					_nLimit_ = _nRemainingCapacity_ / _nCoeff_
					if _nLimit_ < _nMinLimit_
						_nMinLimit_ = _nLimit_
					ok
				ok
			ok
		next
		
		return max([ 0, floor(_nMinLimit_) ])

	def GetSolutionValue(_aSolution_, _cVarName_)
		_nLen_ = len(_aSolution_)
		for i = 1 to _nLen_
			if _aSolution_[i][1] = _cVarName_
				return _aSolution_[i][2]
			ok
		next
		return 0

	def EvaluateSolution(_aSolution_)
		# Evaluate objective function value
		_nValue_ = 0
		_aCoeffs_ = this.parseObjectiveCoefficients()
		_aVarNames_ = this.variableNames()
		_nLen_ = len(_aVarNames_)

		for i = 1 to _nLen_
			_nVarValue_ = this.getSolutionValue(_aSolution_, _aVarNames_[i])
			_nValue_ += _aCoeffs_[i] * _nVarValue_
		next
		
		return _nValue_

	def isBetter(nValue1, nValue2)
		if @objectiveType = "maximize"
			return nValue1 > nValue2
		else
			return nValue1 < nValue2
		ok

	def BuildSimplexTableau() #TODO // Impplement a full solution
		# Build initial simplex tableau (simplified)
		# This is a basic implementation for educational purposes
		return [[1, 2, 3], [4, 5, 6]]  # Placeholder

	def HasNegativeCoefficient(_aTableau_)
		return 0  # Simplified

	def FindPivotColumn(_aTableau_)
		return 1  # Simplified

	def FindPivotRow(_aTableau_, nCol)
		return 1  # Simplified

	def PivotTableau(_aTableau_, nRow, nCol)
		return _aTableau_  # Simplified

	def ExtractSimplexSolution(_aTableau_)
		# Extract solution from final tableau
		_aSolution_ = []
		_aVarNames_ = this.variableNames()
		_nLen_ = len(_aVarNames_)

		for i = 1 to _nLen_
			_aSolution_ + [_aVarNames_[i], 0]
		next
		
		return _aSolution_

	def CreateRelaxedProblem()
		# Create LP relaxation for integer problem
		_oRelaxed_ = new stzLinearSolver()
		
		# Copy variables as continuous
		_nLen_ = len(@variables)

		for i = 1 to _nLen_
			_aVar_ = @variables[i]

			
			_oRelaxed_.addVariable(
				_aVar_[:name], 
				_aVar_[:lowerBound], 
				_aVar_[:upperBound]
			)
		next
		
		# Copy constraints
		_nLen_ = len(@constraints)
		for i = 1 to _nLen_
			_aConst_ = @constraints[i]
			_oRelaxed_.addConstraint(
				_aConst_[:expression],
				_aConst_[:operator],
				_aConst_[:value]
			)
		next
		
		# Copy objective
		if @objectiveType = "maximize"
			_oRelaxed_.maximize(@objective)
		else
			_oRelaxed_.minimize(@objective)
		ok
		
		return _oRelaxed_

	def isIntegerSolution(_aSolution_)
		_nLen_ = len(_aSolution_)
		for i = 1 to _nLen_
			_nValue_ = _aSolution_[i][2]
			if abs(_nValue_ - round(_nValue_)) > 0.001
				return 0
			ok
		next
		return 1

	def IsFeasible(_aSolution_)
		# Check if solution satisfies all constraints
		_nLen_ = len(@constraints)

		for i = 1 to _nLen_
			_aConst_ = @constraints[i]
			_nLeftSide_ = this.evaluateConstraintLeft(_aConst_[:expression], _aSolution_)
			_nRightSide_ = _aConst_[:value]
			_cOperator_ = _aConst_[:operator]
			
			switch _cOperator_
			on "<="
				if _nLeftSide_ > _nRightSide_ + 0.001
					return 0
				ok
			on ">="
				if _nLeftSide_ < _nRightSide_ - 0.001
					return 0
				ok
			on "="
				if abs(_nLeftSide_ - _nRightSide_) > 0.001
					return 0
				ok
			off
		next
		return 1

	def EvaluateConstraintLeft(_cExpression_, _aSolution_)
		# Evaluate left side of constraint
		_nValue_ = 0
		_aVarNames_ = this.variableNames()
		_nLen_ = len(_aVarNames_)

		for i = 1 to _nLen_
			_nCoeff_ = this.extractCoefficient(_cExpression_, _aVarNames_[i])
			_nVarValue_ = this.getSolutionValue(_aSolution_, _aVarNames_[i])
			_nValue_ += _nCoeff_ * _nVarValue_
		next
		
		return _nValue_

	def FindFractionalVariable(_aSolution_)
		_nLen_ = len(_aSolution_)
		for i = 1 to _nLen_
			_nValue_ = _aSolution_[i][2]
			if abs(_nValue_ - round(_nValue_)) > 0.001
				return _aSolution_[i][1]
			ok
		next
		return ""

	def AddBranchConstraint(_aSolution_, _cVarName_, _cOperator_, _nValue_)
		# This would create a new subproblem with additional constraint
		# Simplified implementation returns modified solution
		_aNewSolution_ = []
		_nLen_ = len(_aSolution_)

		for i = 1 to _nLen_
			if _aSolution_[i][1] = _cVarName_
				if _cOperator_ = "<="
					_aNewSolution_ + [_aSolution_[i][1], min([0+_aSolution_[i][2], _nValue_])]
				else
					_aNewSolution_ + [_aSolution_[i][1], max([0+_aSolution_[i][2], _nValue_])]
				ok
			else
				_aNewSolution_ + _aSolution_[i]
			ok
		next
		return _aNewSolution_

	def InitializePopulation(_nSize_)
		_aPopulation_ = []
		_aVarNames_ = this.variableNames()
		
		for i = 1 to _nSize_
			_aIndividual_ = []
			_nLen_ = len(_aVarNames_)
			for j = 1 to _nLen_
				_nLower_ = @variables[j][:lowerBound]  
				_nUpper_ = @variables[j][:upperBound]
				_nValue_ = _nLower_ + StzEngineRandomInt(0, _nUpper_ - _nLower_)
				_aIndividual_ + [_aVarNames_[j], _nValue_]
			next
			_aPopulation_ + _aIndividual_
		next
		
		return _aPopulation_

	def CalculateFitness(_aIndividual_)
		# Fitness = objective value - penalty for constraint violations
		_nObjectiveValue_ = this.evaluateSolution(_aIndividual_)
		_nPenalty_ = this.calculatePenalty(_aIndividual_)
		
		if @objectiveType = "maximize"
			return _nObjectiveValue_ - _nPenalty_
		else
			return -_nObjectiveValue_ - _nPenalty_
		ok

	def CalculatePenalty(_aIndividual_)
		_nPenalty_ = 0
		_nLen_ = len(@constraints)

		for i = 1 to _nLen_
			_aConst_ = @constraints[i]
			_nLeftSide_ = this.evaluateConstraintLeft(oConst[:expression], _aIndividual_)
			_nLeftSide_ = this.evaluateConstraintLeft(_aConst_[:expression], _aIndividual_)
			_nRightSide_ = _aConst_[:value]
			_cOperator_ = _aConst_[:operator]
			
			switch _cOperator_
			on "<="
				if _nLeftSide_ > _nRightSide_
					_nPenalty_ += (_nLeftSide_ - _nRightSide_) * 1000
				ok
			on ">="
				if _nLeftSide_ < _nRightSide_
					_nPenalty_ += (_nRightSide_ - _nLeftSide_) * 1000
				ok
			on "="
				_nPenalty_ += abs(_nLeftSide_ - _nRightSide_) * 1000
			off
		next
		
		return _nPenalty_

	def TournamentSelection(_aPopulation_, _aFitness_)

		_nSize_ = len(_aPopulation_)
		_nIndex1_ = StzEngineRandomInt(0, _nSize_) + 1
		_nIndex2_ = StzEngineRandomInt(0, _nSize_) + 1
		
		_nIndex1_ = StzEngineRandomInt(0, _nSize_)
		if _nIndex1_ = 0
			_nIndex1_ = 1
		ok

		_nIndex2_ = StzEngineRandomInt(0, _nSize_)
		if _nIndex2_ = 0
			_nIndex2_ = 1
		ok

		if _aFitness_[_nIndex1_] > _aFitness_[_nIndex2_]
			return _aPopulation_[_nIndex1_]
		else
			return _aPopulation_[_nIndex2_]
		ok

	def Crossover(_aParent1_, _aParent2_)
		_aChild_ = []
		_nLen_ = len(_aParent1_)
		for i = 1 to _nLen_
			if StzEngineRandomInt(0, 2) = 1
				_aChild_ + _aParent1_[i]
			else
				_aChild_ + _aParent2_[i] 
			ok
		next
		return _aChild_


	def Mutate(_aIndividual_)
		_nIndex_ = StzEngineRandomInt(0, len(_aIndividual_))
		if _nIndex_ = 0
			_nIndex_ = 1
		ok

		_cVarName_ = _aIndividual_[_nIndex_][1]
		
		# Mutate the selected variable
		_nLen_ = len(@variables)
		for i = 1 to _nLen_
			if @variables[i][:name] = _cVarName_
				_nLower_ = @variables[i][:lowerBound]
				_nUpper_ = @variables[i][:upperBound]
				_nNewValue_ = _nLower_ + StzEngineRandomInt(0, _nUpper_ - _nLower_)
				_aIndividual_[_nIndex_][2] = _nNewValue_
				exit
			ok
		next
		
		return _aIndividual_

	  #-----------------#
	 # SOLUTION ACCESS #
	#-----------------#

	def Solution()
		return @aSolution

	def solutionValue(varName)
		return @aSolution[varName]

	def objectiveValue()

		# Calculate objective value from current solution
		_cExpression_ = @objective
		

		# Substitute variable values
		_nLen_ = len(@variables)
		for i = 1 to _nLen_
			_cVarName_ = @variables[i][:name]
			_nValue_ = @aSolution[_cVarName_]
			_cExpression_ = StzReplace(_cExpression_, _cVarName_, "" + _nValue_)
		next

		# Evaluate expression (simplified)
		return this.evaluateExpression(_cExpression_)

	def evaluateExpression(_cExpression_)
		# Simple expression evaluator
		# In practice, would use a proper math parser
		try
			_nResult_ = eval(_cExpression_)
			_cCode_ = '_nResult_ = (' + _cExpression_ + ')'
			eval(_cCode_)
			return _nResult_
		catch
			return 0
		done

	def status()
		return @status

	def iterations()
		return @iterations

	def solveTime()
		return @solveTime

	  #-------------------------#
	 #  DISPLAY AND REPORTING  #
	#-------------------------#

	def show()
		? BoxRound("Linear Programming Problem")
		? "Variables:"
		? BoxRound("Problem")
		? "• Variables:"
		_nLen_ = len(@variables)

		for i = 1 to _nLen_
			_aVar_ = @variables[i]
			? "  " + _aVar_[:name] + " ∈ [" + 
			  _aVar_[:lowerBound] + ", " + 
			  _aVar_[:upperBound] + "] (" + 
			  _aVar_[:type] + ")"
			if @trim(_aVar_[:name]) != ""
				? " ─ " + _aVar_[:name] + " ∈ [" + 
				  _aVar_[:lowerBound] + ", " + 
				  _aVar_[:upperBound] + "] (" + 
				  _aVar_[:type] + ")"
			ok
		next

		? ""
		? "Constraints:"
		? "• Constraints:"
		_nLen_ = len(@constraints)
		for i = 1 to _nLen_
			_aConst_ = @constraints[i]
			? "  " + _aConst_[:expression] + " " 
			? " ─ " + _aConst_[:expression] + " " + 
			  _aConst_[:operator] + " " + 
			  _aConst_[:value]
		next

		? ""
		? "Objective:"
		? "• Objective:"
		? "  " + StzUpper(@objectiveType) + " " + @objective

		if @status != ""
			? ""
			? "========== Solution =========="
			? "Status: " + @status
			? "Solved in " + @solveTime + " seconds"
			? "Iterations: " + @iterations
			? BoxRound("Solution")
			? "• Status: " + @status
			? "• Solved in " + @solveTime + " second(s)"
			? "• Iterations: " + @iterations
			? ""
			? "Variable Values:"
			? "• Variable Values:"
			_nLen_ = len(@aSolution)
			for i = 1 to _nLen_
				? "  " + @aSolution[i][1] + " = " + @aSolution[i][2]
				if @trim(@aSolution[i][1]) != ""
					? " ─ " + @aSolution[i][1] + " = " + @aSolution[i][2]
				ok
			next
			? ""
			? "Objective Value: " + this.objectiveValue()
			? "• Objective Value: " + this.objectiveValue()
		ok

	def exportToCSV(cFileName)
		# Export solution to CSV file
		_oFile_ = new stzFile(cFileName)
		_cContent_ = "Variable,Value" + nl
		_nLen_ = len(@aSolution)
		for i = 1 to _nLen_
			_cContent_ += @aSolution[i][1] + "," + @aSolution[i][2] + nl
		next

		_oFile_.write(_cContent_)

	def exportReport(cFileName)
		# Export full report
		_oFile_ = new stzFile(cFileName)
		_cContent_ = "Linear Programming Problem Report" + nl
		_cContent_ += "=================================" + nl + nl
		
		_cContent_ += "Problem Definition:" + nl
		_cContent_ += "Variables: " + len(@variables) + nl
		_cContent_ += "Constraints: " + len(@constraints) + nl
		_cContent_ += "Objective: " + StzUpper(@objectiveType) + " " + @objective + nl + nl
		
		if @status != ""
			_cContent_ += "Solution:" + nl
			_cContent_ += "Status: " + @status + nl
			_cContent_ += "Solve Time: " + @solveTime + " seconds" + nl
			_cContent_ += "Iterations: " + @iterations + nl
			_cContent_ += "Objective Value: " + this.objectiveValue() + nl + nl
			
			_cContent_ += "Variable Values:" + nl
			_nLen_ = len(@aSolution)
			for i = 1 to _nLen_
				_cContent_ += @aSolution[i][1] + " = " + @aSolution[i][2] + nl
			next
		ok

		_oFile_.write(_cContent_)

	  #----------------#
	 # HELPER METHODS #
	#----------------#

	def isValidVariableName(cName)
		# Check if variable name is valid
		_nLen_ = len(@variables)
		for i = 1 to _nLen_
			if @variables[i][:name] = cName
				return 1
			ok
		next
		return 0

	def validateProblem()
		# Validate problem definition
		if len(@variables) = 0
			return 0
		ok

		if @objective = ""
			return 0
		ok

		return 1
