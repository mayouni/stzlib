
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
		# HONESTY GUARD (S0, 2026-07-14): the old body was a stub that
		# returned all-zeros silently (hardcoded tableau; the pivot loop
		# never iterated). Until the REAL simplex lands (roadmap R4 --
		# engine-side optim), refuse loudly rather than lie.
		# Working backends today: "greedy", "genetic" (and NSGA-II in
		# stzMultiObjectiveSolver).
		@status = "unimplemented"
		raise("Simplex is not implemented yet (the old stub returned all-zeros silently). Use Solve('greedy') or Solve('genetic') until the real simplex lands (R4).")

		# -- unreachable legacy scaffolding kept for the R4 rebuild --
		@status = "optimal"
		@iterations = 0
		
		# Convert to standard form
		_aTableau_ = this.buildSimplexTableau()
		
		# Simplex iterations
		while this.hasNegativeCoefficient(_aTableau_)
			@iterations++
			
			# Find pivot column (most negative coefficient)
			_nPivotCol_ = this.findPivotColumn(_aTableau_)
			
			# Find pivot row (minimum ratio test)
			_nPivotRow_ = this.findPivotRow(_aTableau_, _nPivotCol_)
			
			if _nPivotRow_ = -1
				@status = "unbounded"
				exit
			ok
			
			# Perform pivot operation
			_aTableau_ = this.pivotTableau(_aTableau_, _nPivotRow_, _nPivotCol_)
			
			# Prevent infinite loops
			if @iterations > 1000
				@status = "iteration_limit"
				exit
			ok
		end
		
		# Extract solution from tableau
		return this.extractSimplexSolution(_aTableau_)

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
		# Simple coefficient extraction
		# Look for patterns like "5*x" or "-3*y" or just "x"
		#TODO // Use stzRegex instead for full solution

		_cPattern_ = _cVarName_
		_nPos_ = ring_substr1(_cExpression_, _cPattern_)
		
		if _nPos_ = 0
			return 0  # Variable not in expression
		ok
		
		# Check for coefficient before variable
		if _nPos_ > 1
			_oExpr_ = new stzString(_cExpression_)
			_cBefore_ = _oExpr_.Section(_nPos_-1, 1)
			if _cBefore_ = "*"
				# Find the coefficient
				_nStart_ = _nPos_ - 2
				_c_ = _oExpr_.Section(_nStart_, 1)
				while _nStart_ > 0 and (isdigit(_c_) or _c_ = ".")
					_nStart_--
				end
				if _nStart_ < _nPos_ - 2
					_cCoeffStr_ = _oExpr_.Section(_nStart_+1, _nPos_-_nStart_-2)
					return 0 + _cCoeffStr_  # Convert to number
				ok
			ok
		ok
		
		return 1  # Default coefficient if just variable name

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
