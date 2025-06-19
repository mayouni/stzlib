/*
	stzLinearSolver - Linear Programming Component for Softanza
	Provides simple yet practical linear optimization capabilities
	Author: Softanza Team
	Version: 0.9
*/

class stzLinearSolver from stzObject

	@aVariables = []
	@aConstraints = []
	@cObjective = ""
	@cObjectiveType = "maximize"  # "maximize" or "minimize"
	@aSolution = []
	@cStatus = ""
	@nIterations = 0
	@nSolveTime = 0

	def init()
		# Initialize with empty problem
		This.clear()

	def clear()
		@aVariables = []
		@aConstraints = []
		@cObjective = ""
		@cObjectiveType = "maximize"
		@aSolution = []
		@cStatus = ""
		@nIterations = 0
		@nSolveTime = 0

	  #------------------------#
	 #  VARIABLES MANAGEMENT  #
	#------------------------#

	def addVariable(varName, lowerBound, upperBound)
		if NOT isString(varName)
			stzRaise("Variable name must be a string!")
		ok

		if isString(lowerBound) and lowerBound = ""
			lowerBound = upperBound
		ok

		if isString(upperBound) and upperBound = ""
			upperBound = lowerBound
		ok

		if isString(lowerBound) and lowerBound = "" and
		    isString(upperBound) and upperBound = ""

				lowerBound = 0
				upperBound = 0
		ok

		if NOT (isNumber(lowerBound) and isNumber(upperBound))
			stzRaise("Bounds must be numbers!")
		ok

		if upperBound < lowerBound
			stzRaise("Upper bound must be >= lower bound!")
		ok

		aVar = [
			:name = varName,
			:lowerBound = lowerBound,
			:upperBound = upperBound,
			:type = "continuous"  # "continuous", "integer", "binary"
		]

		@aVariables + aVar
		return this

	def addIntegerVariable(varName, lowerBound, upperBound)
		This.addVariable(varName, lowerBound, upperBound)

		@aVariables + [:type, "integer"]
		return this

	def addBinaryVariable(varName)
		This.addVariable(varName, 0, 1)
		@aVariables + [:type, "binary"]
		return this

	def variables()
		return @aVariables

	def variableNames()
		aNames = []
		for i = 1 to len(@aVariables)
			aNames + @aVariables[i][:name]
		next
		return aNames

	  #--------------------------#
	 #  CONSTRAINTS MANAGEMENT  #
	#--------------------------#

	def addConstraint(expression, operator, value)
		# expression: string like "2*x + 3*y"
		# operator: "<=", ">=", "="
		# value: number

		if NOT isString(expression)
			StzRaise("Expression must be a string!")
		ok

		if NOT isString(operator)
			StzRaise("Operator must be a string!")
		ok

		if NOT (operator = "<=" or operator = ">=" or operator = "=")
			stzRaise("Operator must be '<=', '>=', or '='!")
		ok

		if isString(value)
			value = @aVariables[value]
			if @trim(value) = ""
				value = 0
			ok
		ok

		if NOT isNumber(value)
			stzRaise("Value must be a number!")
		ok

		aConstraint = [
			:expression = expression,
			:operator = operator,
			:value = value
		]

		@aConstraints + aConstraint
		return this

	def constraints()
		return @aConstraints

	  #----------------------#
	 #  OBJECTIVE FUNCTION  #
	#----------------------#

	def maximize(expression)
		@cObjective = expression
		@cObjectiveType = "maximize"
		return this

	def minimize(expression)
		@cObjective = expression
		@cObjectiveType = "minimize"
		return this

	def objective()
		return @cObjective

	def objectiveType()
		return @cObjectiveType

	  #-----------#
	 #  SOLVING  #
	#-----------#

	def solve(cSolver)
	    if isNull(cSolver) or cSolver = ""
	        cSolver = "greedy"
	    ok
	    nStartTime = clock()
	    if len(@aVariables) = 0
	        StzRaise("No variables defined!")
	    ok
	    if @cObjective = ""
	        StzRaise("No objective function defined!")
	    ok
	    
	    # Add this check
	    if cSolver != "greedy"
	        cSolver = "greedy"  # Force to greedy for now
	    ok
	    
	    aSolution = This.solveWithGreedy()
	    
	    @nSolveTime = (clock() - nStartTime) / clockspersecond()
	    @aSolution = aSolution
	    return this

	  #--------------------#
	 #  BUILT-IN SOLVERS  #
	#--------------------#

	def SolveWithGreedy()

		@cStatus = "optimal"

		nLenVar = len(@aVariables)
		@nIterations = nLenVar

		aCoeffs = This.parseObjectiveCoefficients()
		aVarNames = This.variableNames()
		nLenVarNames = len(aVarNames)

		aSolution = []

		for i = 1 to nLenVar
			aSolution + [aVarNames[i], @aVariables[i][:lowerBound]]
		next

		nLenSol = len(aSolution)

		aEfficiency = []

		for i = 1 to nLenVarNames

			nCoeff = aCoeffs[i]
			nResourceCost = This.calculateResourceCost(aVarNames[i])
			nEfficiency = 0

			if nResourceCost > 0
				nEfficiency = nCoeff / nResourceCost
			ok

			aEfficiency + [aVarNames[i], nEfficiency, i]

		next

		if @cObjectiveType = "maximize"
			aEfficiency = sorton(aEfficiency, 2)  # Use This.sorton
			aEfficiency = reverse(aEfficiency)

		else
			aEfficiency = sorton(aEfficiency, 2)  # Use This.sorton
		ok

		nLenEff = len(aEfficiency)

		for i = 1 to nLenEff

			cVarName = aEfficiency[i][1]
			nVarIndex = aEfficiency[i][3]
			nMaxPossible = 0+ This.calculateMaxPossibleValue(cVarName, aSolution)  # Fixed case
			nUpperBound = 0+ @aVariables[nVarIndex][:upperBound]
			nValue = min([nMaxPossible, 0+nUpperBound])

			for j = 1 to nLenSol
				if aSolution[j][1] = cVarName
					aSolution[j][2] = nValue
					exit
				ok
			next

		next

		return aSolution

	def solveWithSimplex()
		# Simplified Simplex method for small problems
		@cStatus = "optimal"
		@nIterations = 0
		
		# Convert to standard form
		aTableau = This.buildSimplexTableau()
		
		# Simplex iterations
		while This.hasNegativeCoefficient(aTableau)
			@nIterations++
			
			# Find pivot column (most negative coefficient)
			nPivotCol = This.findPivotColumn(aTableau)
			
			# Find pivot row (minimum ratio test)
			nPivotRow = This.findPivotRow(aTableau, nPivotCol)
			
			if nPivotRow = -1
				@cStatus = "unbounded"
				exit
			ok
			
			# Perform pivot operation
			aTableau = This.pivotTableau(aTableau, nPivotRow, nPivotCol)
			
			# Prevent infinite loops
			if @nIterations > 1000
				@cStatus = "iteration_limit"
				exit
			ok
		end
		
		# Extract solution from tableau
		return This.extractSimplexSolution(aTableau)

	def solveWithBranchAndBound()
		# Branch and bound for integer problems
		@cStatus = "optimal"
		@nIterations = 0
		
		# First solve LP relaxation
		oRelaxed = This.createRelaxedProblem()
		aSolution = oRelaxed.solveWithSimplex()
		
		# Check if solution is already integer
		if This.isIntegerSolution(aSolution)
			return aSolution
		ok
		
		# Branch and bound search
		aBestSolution = aSolution
		nBestValue = This.evaluateSolution(aSolution)
		
		aBranches = [aSolution]
		
		while len(aBranches) > 0 and @nIterations < 100
			@nIterations++
			
			# Get next branch
			aCurrentSolution = aBranches[1]
			del(aBranches, 1)
			
			# Find fractional variable
			cFracVar = This.findFractionalVariable(aCurrentSolution)
			if cFracVar = ""
				loop
			ok
			
			nFracValue = This.getSolutionValue(aCurrentSolution, cFracVar)
			
			# Create two branches
			aBranch1 = This.addBranchConstraint(aCurrentSolution, cFracVar, "<=", floor(nFracValue))
			aBranch2 = This.addBranchConstraint(aCurrentSolution, cFracVar, ">=", ceil(nFracValue))
			
			# Evaluate branches
			for aBranch in [aBranch1, aBranch2]
				if This.isFeasible(aBranch)
					nValue = This.evaluateSolution(aBranch)
					
					if This.isBetter(nValue, nBestValue)
						if This.isIntegerSolution(aBranch)
							aBestSolution = aBranch
							nBestValue = nValue
						else
							aBranches + aBranch
						ok
					ok
				ok
			next
		end
		
		return aBestSolution

	def solveWithGenetic()
		# Genetic algorithm for complex problems
		@cStatus = "optimal"
		@nIterations = 0
		
		nPopSize = 50
		nGenerations = 100
		nMutationRate = 0.1
		
		# Initialize population
		aPopulation = This.initializePopulation(nPopSize)
		aBestSolution = aPopulation[1]
		nBestFitness = This.calculateFitness(aBestSolution)
		
		for nGen = 1 to nGenerations
			@nIterations++
			
			# Evaluate fitness for all individuals
			aFitness = []
			nLen = len(aPopulation)

			for i = 1 to nLen
				nFit = This.calculateFitness(aPopulation[i])
				aFitness + nFit
				
				# Track best solution
				if This.isBetter(nFit, nBestFitness)
					aBestSolution = aPopulation[i]
					nBestFitness = nFit
				ok
			next
			
			# Create next generation
			aNewPopulation = []
			
			for i = 1 to nPopSize
				# Selection (tournament)
				aParent1 = This.tournamentSelection(aPopulation, aFitness)
				aParent2 = This.tournamentSelection(aPopulation, aFitness)
				
				# Crossover
				aChild = This.crossover(aParent1, aParent2)
				
				# Mutation
				if random(100)/100 < nMutationRate
					aChild = This.mutate(aChild)
				ok
				
				aNewPopulation + aChild
			next
			
			aPopulation = aNewPopulation
		next
		
		return aBestSolution

	  #-------------------------#
	 #  SOLVER HELPER METHODS  #
	#-------------------------#

	def parseObjectiveCoefficients()
		# Extract coefficients from objective function
		aCoeffs = []
		aVarNames = This.variableNames()
		nLen = len(aVarNames)

		for i = 1 to nLen
			cVar = aVarNames[i]
			nCoeff = This.extractCoefficient(@cObjective, cVar)
			aCoeffs + nCoeff
		next
		
		return aCoeffs

	def extractCoefficient(cExpression, cVarName)
		if ring_substr1(cExpression, cVarName) = 0
			return 0
		ok

		cExpr = @trim(cExpression)
		acSplits = @split(cExpr, "+")

		nLen = len(acSplits)

		for i = 1 to nLen
			if ring_substr1(acSplits[i], "*") and ring_substr1(acSplits[i], cVarName)
				n = ring_substr1(acSplits[i], "*")
				cCoeff = StzStringQ(acSplits[i]).Section(1, n-1)
				return 0+ cCoeff
			ok
		next

		return 1

	def calculateResourceCost(cVarName)
		# Calculate total resource cost for one unit of variable
		nTotalCost = 0
		nLen = len(@aConstraints)
		for i = 1 to nLen
			aConst = @aConstraints[i]
			nCoeff = This.extractCoefficient(aConst[:expression], cVarName)
			nTotalCost += abs(nCoeff)
		next
		
		return nTotalCost


	def CalculateMaxPossibleValue(cVarName, aSolution)
		# Calculate maximum possible value considering constraints
		nMinLimit = 999999
		nLen = len(@aConstraints)
		
		for i = 1 to nLen
			aConst = @aConstraints[i]
			nCoeff = This.extractCoefficient(aConst[:expression], cVarName)
			
			if nCoeff != 0
				# Calculate used resources by other variables
				nUsedResources = 0
				aVarNames = This.variableNames()
				nLenVar = len(aVarNames)
				
				for j = 1 to nLenVar
					if aVarNames[j] != cVarName
						nVarCoeff = This.extractCoefficient(aConst[:expression], aVarNames[j])
						nVarValue = This.getSolutionValue(aSolution, aVarNames[j])
						nUsedResources += nVarCoeff * nVarValue
					ok
				next
				
				# Calculate remaining capacity
				nRemainingCapacity = aConst[:value] - nUsedResources
				
				# Handle different constraint operators
				switch aConst[:operator]
				on "="
					# For equality constraints, the remaining capacity divided by coefficient
					# gives the exact value this variable must take
					if nCoeff > 0
						nLimit = nRemainingCapacity / nCoeff
						if nLimit < nMinLimit
							nMinLimit = nLimit
						ok
					ok
				on "<="
					# For <= constraints, variable is limited by remaining capacity
					if nCoeff > 0
						nLimit = nRemainingCapacity / nCoeff
						if nLimit < nMinLimit
							nMinLimit = nLimit
						ok
					ok
				on ">="
					# For >= constraints, check if we can satisfy the minimum requirement
					if nCoeff > 0 and nRemainingCapacity < 0
						# If remaining capacity is negative, we need at least |remaining|/coeff
						nMinRequired = abs(nRemainingCapacity) / nCoeff
						# But this is handled by the lower bound, so we don't limit here
					ok
				off
			ok
		next
		
		# Ensure the result is within variable bounds and non-negative
		nVarIndex = 0
		aVarNames = This.variableNames()
		nLenVar = len(aVarNames)
		
		for j = 1 to nLenVar
			if aVarNames[j] = cVarName
				nVarIndex = j
				exit
			ok
		next
		
		if nVarIndex > 0
			nLowerBound = 0+ @aVariables[nVarIndex][:lowerBound]
			nUpperBound = 0+ @aVariables[nVarIndex][:upperBound]
			
			# Return the minimum of: calculated limit, upper bound
			# But at least the lower bound
			nResult = min([nMinLimit, nUpperBound])
			nResult = max([nResult, nLowerBound])
			
			return max([0, nResult])
		ok
		
		return max([0, nMinLimit])
	

	def GetSolutionValue(aSolution, cVarName)
		for i = 1 to len(aSolution)
			if aSolution[i][1] = cVarName
				return aSolution[i][2]
			ok
		next
		return 0

	def EvaluateSolution(aSolution)
		# Evaluate objective function value
		nValue = 0
		aCoeffs = This.parseObjectiveCoefficients()
		aVarNames = This.variableNames()
		nLen = len(aVarNames)

		for i = 1 to nLen
			nVarValue = This.getSolutionValue(aSolution, aVarNames[i])
			nValue += aCoeffs[i] * nVarValue
		next
		
		return nValue

	def isBetter(nValue1, nValue2)
		if @cObjectiveType = "maximize"
			return nValue1 > nValue2
		else
			return nValue1 < nValue2
		ok

	def BuildSimplexTableau() #TODO // Impplement a full solution
		# Build initial simplex tableau (simplified)
		# This is a basic implementation for educational purposes
		return [[1, 2, 3], [4, 5, 6]]  # Placeholder

	def HasNegativeCoefficient(aTableau)
		return FALSE  # Simplified

	def FindPivotColumn(aTableau)
		return 1  # Simplified

	def FindPivotRow(aTableau, nCol)
		return 1  # Simplified

	def PivotTableau(aTableau, nRow, nCol)
		return aTableau  # Simplified

	def ExtractSimplexSolution(aTableau)
		# Extract solution from final tableau
		aSolution = []
		aVarNames = This.variableNames()
		nLen = len(aVarNames)

		for i = 1 to nLen
			aSolution + [aVarNames[i], 0]
		next
		
		return aSolution

	def CreateRelaxedProblem()
		# Create LP relaxation for integer problem
		oRelaxed = new stzLinearSolver()
		
		# Copy variables as continuous
		nLen = len(@aVariables)

		for i = 1 to nLen
			aVar = @aVariables[i]
			
			oRelaxed.addVariable(
				aVar[:name], 
				aVar[:lowerBound], 
				aVar[:upperBound]
			)
		next
		
		# Copy constraints
		nLen = len(@aConstraints)
		for i = 1 to nLen
			aConst = @aConstraints[i]
			oRelaxed.addConstraint(
				aConst[:expression],
				aConst[:operator],
				aConst[:value]
			)
		next
		
		# Copy objective
		if @cObjectiveType = "maximize"
			oRelaxed.maximize(@cObjective)
		else
			oRelaxed.minimize(@cObjective)
		ok
		
		return oRelaxed

	def isIntegerSolution(aSolution)
		nLen = len(aSolution)
		for i = 1 to nLen
			nValue = aSolution[i][2]
			if abs(nValue - round(nValue)) > 0.001
				return FALSE
			ok
		next
		return TRUE

	def IsFeasible(aSolution)
		# Check if solution satisfies all constraints
		nLen = len(@aConstraints)

		for i = 1 to nLen
			aConst = @aConstraints[i]
			nLeftSide = This.evaluateConstraintLeft(aConst[:expression], aSolution)
			nRightSide = aConst[:value]
			cOperator = aConst[:operator]
			
			switch cOperator
			on "<="
				if nLeftSide > nRightSide + 0.001
					return FALSE
				ok
			on ">="
				if nLeftSide < nRightSide - 0.001
					return FALSE
				ok
			on "="
				if abs(nLeftSide - nRightSide) > 0.001
					return FALSE
				ok
			off
		next
		return TRUE

	def EvaluateConstraintLeft(cExpression, aSolution)
		# Evaluate left side of constraint
		nValue = 0
		aVarNames = This.variableNames()
		nLen = len(aVarNames)

		for i = 1 to nLen
			nCoeff = This.extractCoefficient(cExpression, aVarNames[i])
			nVarValue = This.getSolutionValue(aSolution, aVarNames[i])
			nValue += nCoeff * nVarValue
		next
		
		return nValue

	def FindFractionalVariable(aSolution)
		nLen = len(aSolution)
		for i = 1 to nLen
			nValue = aSolution[i][2]
			if abs(nValue - round(nValue)) > 0.001
				return aSolution[i][1]
			ok
		next
		return ""

	def AddBranchConstraint(aSolution, cVarName, cOperator, nValue)
		# This would create a new subproblem with additional constraint
		# Simplified implementation returns modified solution
		aNewSolution = []
		nLen = len(aSolution)

		for i = 1 to nLen
			if aSolution[i][1] = cVarName
				if cOperator = "<="
					aNewSolution + [aSolution[i][1], min([0+aSolution[i][2], nValue])]
				else
					aNewSolution + [aSolution[i][1], max([0+aSolution[i][2], nValue])]
				ok
			else
				aNewSolution + aSolution[i]
			ok
		next
		return aNewSolution

	def InitializePopulation(nSize)
		aPopulation = []
		aVarNames = This.variableNames()
		
		for i = 1 to nSize
			aIndividual = []
			nLen = len(aVarNames)
			for j = 1 to nLen
				nLower = @aVariables[j][:lowerBound]  
				nUpper = @aVariables[j][:upperBound]
				nValue = nLower + random(nUpper - nLower)
				aIndividual + [aVarNames[j], nValue]
			next
			aPopulation + aIndividual
		next
		
		return aPopulation

	def CalculateFitness(aIndividual)
		# Fitness = objective value - penalty for constraint violations
		nObjectiveValue = This.evaluateSolution(aIndividual)
		nPenalty = This.calculatePenalty(aIndividual)
		
		if @cObjectiveType = "maximize"
			return nObjectiveValue - nPenalty
		else
			return -nObjectiveValue - nPenalty
		ok

	def CalculatePenalty(aIndividual)
		nPenalty = 0
		nLen = len(@aConstraints)

		for i = 1 to nLen
			aConst = @aConstraints[i]
			nLeftSide = This.evaluateConstraintLeft(aConst[:expression], aIndividual)
			nRightSide = aConst[:value]
			cOperator = aConst[:operator]
			
			switch cOperator
			on "<="
				if nLeftSide > nRightSide
					nPenalty += (nLeftSide - nRightSide) * 1000
				ok
			on ">="
				if nLeftSide < nRightSide
					nPenalty += (nRightSide - nLeftSide) * 1000
				ok
			on "="
				nPenalty += abs(nLeftSide - nRightSide) * 1000
			off
		next
		
		return nPenalty

	def TournamentSelection(aPopulation, aFitness)

		nSize = len(aPopulation)
		nIndex1 = random(nSize)
		if nIndex1 = 0
			nIndex1 = 1
		ok

		nIndex2 = random(nSize)
		if nIndex2 = 0
			nIndex2 = 1
		ok

		if aFitness[nIndex1] > aFitness[nIndex2]
			return aPopulation[nIndex1]
		else
			return aPopulation[nIndex2]
		ok

	def Crossover(aParent1, aParent2)
		aChild = []
		nLen = len(aParent1)

		for i = 1 to nLen
			if random(2) = 1
				aChild + aParent1[i]
			else
				aChild + aParent2[i] 
			ok
		next

		return aChild

	def Mutate(aIndividual)
		nIndex = random(len(aIndividual))
		if nIndex = 0
			nIndex = 1
		ok

		cVarName = aIndividual[nIndex][1]
		
		# Mutate the selected variable
		nLen = len(@aVariables)

		for i = 1 to nLen

			if @aVariables[i][:name] = cVarName
				nLower = @aVariables[i][:lowerBound]
				nUpper = @aVariables[i][:upperBound]
				nNewValue = nLower + random(nUpper - nLower)
				aIndividual[nIndex][2] = nNewValue
				exit
			ok

		next
		
		return aIndividual

	  #-----------------#
	 # SOLUTION ACCESS #
	#-----------------#

	def Solution()
		return @aSolution

	def solutionValue(varName)
		return @aSolution[varName]

	def objectiveValue()
		nResult = 0

		for i = 1 to len(@aVariables)
			cVarName = @aVariables[i][:name]
			nValue = This.getSolutionValue(@aSolution, cVarName)
			nCoeff = This.extractCoefficient(@cObjective, cVarName)
			nResult += nCoeff * nValue
		next

		return nResult

		# Evaluate expression (simplified)
		return This.evaluateExpression(cExpression)

	def evaluateExpression(cExpression)
		# Simple expression evaluator
		# In practice, would use a proper math parser
		try
			cCode = 'nResult = (' + cExpression + ')'
			eval(cCode)
			return nResult

		catch
			return 0
		done

	def status()
		return @cStatus

	def iterations()
		return @nIterations

	def solveTime()
		return @solveTime

	  #-------------------------#
	 #  DISPLAY AND REPORTING  #
	#-------------------------#

	def show()

		? BoxRound("Problem")
		? "• Variables:"
		nLen = len(@aVariables)

		for i = 1 to nLen

			aVar = @aVariables[i]

			if @trim(aVar[:name]) != ""
				? " ─ " + aVar[:name] + " ∈ [" + 
				  aVar[:lowerBound] + ", " + 
				  aVar[:upperBound] + "] (" + 
				  aVar[:type] + ")"
			ok

		next

		? ""
		? "• Constraints:"
		nLen = len(@aConstraints)

		for i = 1 to nLen
			aConst = @aConstraints[i]
			? " ─ " + aConst[:expression] + " " + 
			  aConst[:operator] + " " + 
			  aConst[:value]
		next

		? ""
		? "• Objective:"
		? "  " + upper(@cObjectiveType) + " " + @cObjective

		if @cStatus != ""
			? ""
			? BoxRound("Solution")
			? "• Status: " + @cStatus
			? "• Solved in " + @nSolveTime + " second(s)"
			? "• Iterations: " + @nIterations
			? ""
			? "• Variable Values:"

			nLen = len(@aSolution)

			for i = 1 to nLen
				if @trim(@aSolution[i][1]) != ""
					? " ─ " + @aSolution[i][1] + " = " + @aSolution[i][2]
				ok
			next

			? ""
			? "• Objective Value: " + This.objectiveValue()

		ok

	def exportToCSV(cFileName)

		# Export solution to CSV file
		oFile = new stzFile(cFileName)

		cContent = "Variable,Value" + nl
		nLen = len(@aSolution)

		for i = 1 to nLen
			cContent += @aSolution[i][1] + "," + @aSolution[i][2] + nl
		next

		oFile.write(cContent)

	def exportReport(cFileName)
		# Export full report
		oFile = new stzFile(cFileName)
		cContent = BoxRound("Linear Programming Problem Report") + nl
		
		cContent += "• Problem Definition:" + nl
		cContent += " ─ Variables: " + len(@aVariables) + nl
		cContent += " ─ Constraints: " + len(@aConstraints) + nl
		cContent += " ─ Objective: " + upper(@cObjectiveType) + " " + @cObjective + nl + nl
		
		if @cStatus != ""
			cContent += "• Solution:" + nl
			cContent += " ─ Status: " + @cStatus + nl
			cContent += " ─ Solve Time: " + @nSolveTime + " seconds" + nl
			cContent += " ─ Iterations: " + @nIterations + nl
			cContent += " ─ Objective Value: " + This.objectiveValue() + nl + nl
			
			cContent += "• Variable Values:" + nl
			nLen = len(@aSolution)
			for i = 1 to nLen
				cContent += " ─ " + @aSolution[i][1] + " = " + @aSolution[i][2] + nl
			next
		ok

		oFile.write(cContent)

	  #----------------#
	 # HELPER METHODS #
	#----------------#

	def isValidVariableName(cName)
		# Check if variable name is valid
		nLen = len(@aVariables)

		for i = 1 to nLen
			if @aVariables[i][:name] = cName
				return TRUE
			ok
		next

		return FALSE

	def validateProblem()

		# Validate problem definition
		if len(@aVariables) = 0
			return FALSE
		ok

		if @cObjective = ""
			return FALSE
		ok

		return TRUE
