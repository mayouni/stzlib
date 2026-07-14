
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

		while TRUE
			@iterations++
			if @iterations > 2000
				@status = "iteration_limit"
				exit
			ok
			_nPc_ = 0
			_nMost_ = -0.0000001
			for j = 1 to _nCols_ - 1
				if _aZ_[j] < _nMost_
					_nMost_ = _aZ_[j]
					_nPc_ = j
				ok
			next
			if _nPc_ = 0
				exit
			ok
			_nPr_ = 0
			_nBestR_ = 0
			for i = 1 to _nM_
				if _aT_[i][_nPc_] > 0.0000001
					_nRatio_ = _aT_[i][_nCols_] / _aT_[i][_nPc_]
					if _nPr_ = 0 or _nRatio_ < _nBestR_
						_nBestR_ = _nRatio_
						_nPr_ = i
					ok
				ok
			next
			if _nPr_ = 0
				@status = "unbounded"
				exit
			ok
			_nPv_ = _aT_[_nPr_][_nPc_]
			for j = 1 to _nCols_
				_aT_[_nPr_][j] /= _nPv_
			next
			for i = 1 to _nM_
				if i != _nPr_ and fabs(_aT_[i][_nPc_]) > 0.000000001
					_nF_ = _aT_[i][_nPc_]
					for j = 1 to _nCols_
						_aT_[i][j] -= _nF_ * _aT_[_nPr_][j]
					next
				ok
			next
			_nF_ = _aZ_[_nPc_]
			if fabs(_nF_) > 0.000000001
				for j = 1 to _nCols_
					_aZ_[j] -= _nF_ * _aT_[_nPr_][j]
				next
			ok
			_aBasis_[_nPr_] = _nPc_
		end

		for i = 1 to _nM_
			if _aBasis_[i] > _nArtAt_ and _aT_[i][_nCols_] > 0.000001
				@status = "infeasible"
			ok
		next

		# extract x' and shift back to x = lo + x'
		_aSolution_ = []
		for j = 1 to _nV_
			_nVal_ = 0 + @variables[j][:lowerBound]
			for i = 1 to _nM_
				if _aBasis_[i] = j
					_nVal_ += _aT_[i][_nCols_]
					exit
				ok
			next
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
				if random(100)/100 < _nMutationRate_
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

	def extractCoefficient(_cExpression_, _cVarName_)
		# REAL linear-term parser (R4 step 5, 2026-07-14). The old
		# byte-peek LOST MULTIPLIERS -- '0.6*marketing' read as 1, so
		# every solver optimized the wrong objective. This one splits
		# on +/- terms and understands 'k*var', 'var*k' and bare 'var',
		# with EXACT token matching ('rd' never matches inside 'yard').
		_cE_ = StzLower(StzReplace(" " + _cExpression_, "-", "+-"))
		_acTerms_ = StzSplit(_cE_, "+")
		_cV_ = StzLower(ring_trim(_cVarName_))
		_nTotal_ = 0
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
			if _cT_ = _cV_
				_nTotal_ += _nSg_
			but len(StzFind("*", _cT_)) > 0
				_acF_ = StzSplit(_cT_, "*")
				if len(_acF_) = 2
					if ring_trim(_acF_[2]) = _cV_
						_nTotal_ += _nSg_ * ring_number(_acF_[1])
					but ring_trim(_acF_[1]) = _cV_
						_nTotal_ += _nSg_ * ring_number(_acF_[2])
					ok
				ok
			ok
		next
		return _nTotal_

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
		return FALSE  # Simplified

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
				return FALSE
			ok
		next
		return TRUE

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
					return FALSE
				ok
			on ">="
				if _nLeftSide_ < _nRightSide_ - 0.001
					return FALSE
				ok
			on "="
				if abs(_nLeftSide_ - _nRightSide_) > 0.001
					return FALSE
				ok
			off
		next
		return TRUE

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
				_nValue_ = _nLower_ + random(_nUpper_ - _nLower_)
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
		_nIndex1_ = random(_nSize_) + 1
		_nIndex2_ = random(_nSize_) + 1
		
		_nIndex1_ = random(_nSize_)
		if _nIndex1_ = 0
			_nIndex1_ = 1
		ok

		_nIndex2_ = random(_nSize_)
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
			if random(2) = 1
				_aChild_ + _aParent1_[i]
			else
				_aChild_ + _aParent2_[i] 
			ok
		next
		return _aChild_


	def Mutate(_aIndividual_)
		_nIndex_ = random(len(_aIndividual_))
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
				_nNewValue_ = _nLower_ + random(_nUpper_ - _nLower_)
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
				return TRUE
			ok
		next
		return FALSE

	def validateProblem()
		# Validate problem definition
		if len(@variables) = 0
			return FALSE
		ok

		if @objective = ""
			return FALSE
		ok

		return TRUE
