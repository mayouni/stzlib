/*
	stzLinearSolver - Linear Programming Component for Softanza
	Provides simple yet practical linear optimization capabilities
	Author: Softanza Team
	Version: 1.0
*/

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

		@variables + aVar
		return this

	def addIntegerVariable(varName, lowerBound, upperBound)
		this.addVariable(varName, lowerBound, upperBound)

		@variables + [ :type, "integer" ]
		return this

	def addBinaryVariable(varName)
		this.addVariable(varName, 0, 1)
		@variables+ [:type, "binary"]
		return this

	def variables()
		return @variables

	def variableNames()
		aNames = []
		for i = 1 to len(@variables)
			aNames + @variables[i][:name]
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
			value = @variables[value]
			if @trim(value) = ""
				value = 0
			ok
		ok

		if NOT isNumber(value)
			stzRaise("Value must be a number!")
		ok

		oConstraint = new stzHashList([
			:expression = expression,
			:operator = operator,
			:value = value
		])

		@constraints + oConstraint
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

	def solve(cSolver)
		if isNull(cSolver) or cSolver = ""
			cSolver = "greedy"  # Default solver
		ok

		nStartTime = clock()

		# Validate problem
		if len(@variables) = 0
			stzRaise("No variables defined!")
		ok

		if @objective = ""
			stzRaise("No objective function defined!")
		ok

		# Choose solver based on problem characteristics and user preference
		switch cSolver
		on "greedy"
			aSolution = this.solveWithGreedy()
		on "simplex"
			aSolution = this.solveWithSimplex()
		on "branch_bound"
			aSolution = this.solveWithBranchAndBound()
		on "genetic"
			aSolution = this.solveWithGenetic()
		other
			stzRaise("Unknown solver: " + cSolver)
		off

		@solveTime = (clock() - nStartTime) / clockspersecond()
		@aSolution = aSolution

		return this

	  #--------------------#
	 #  BUILT-IN SOLVERS  #
	#--------------------#

	def solveWithGreedy()
		# Greedy solver: maximize efficiency ratio for each variable
		@status = "optimal"
		@iterations = len(@variables)
		
		# Parse objective coefficients
		aCoeffs = this.parseObjectiveCoefficients()
		aVarNames = this.variableNames()
		aSolution = []
		
		# Initialize solution with lower bounds
		nLen = len(aVarNames)
		for i = 1 to nLen
			aSolution + [aVarNames[i], @variables[i][:lowerBound]]
		next
		
		# Calculate efficiency ratios and sort variables
		aEfficiency = []
		nLen = len(aVarNames)
		for i = 1 to nLen
			nCoeff = aCoeffs[i]
			nResourceCost = this.calculateResourceCost(aVarNames[i])
			nEfficiency = 0
			if nResourceCost > 0
				nEfficiency = nCoeff / nResourceCost
			ok
			aEfficiency + [aVarNames[i], nEfficiency, i]
		next
		
		# Sort by efficiency (descending for maximize, ascending for minimize)
		if @objectiveType = "maximize"
			aEfficiency = sorton(aEfficiency, 2)  # Sort by efficiency desc
			aEfficiency = reverse(aEfficiency)
		else
			aEfficiency = sorton(aEfficiency, 2)  # Sort by efficiency asc
		ok
		
		# Greedily allocate resources
		nLenEff = len(aEfficiency)
		for i = 1 to nLenEff
			cVarName = aEfficiency[i][1]
			nVarIndex = aEfficiency[i][3]
			nMaxPossible = this.calculateMaxPossibleValue(cVarName, aSolution)
			nUpperBound = @variables[nVarIndex][:upperBound]
			nValue = min([nMaxPossible, 0+nUpperBound])
			
			# Update solution
			nLenSol = len(aSolution)
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
		@status = "optimal"
		@iterations = 0
		
		# Convert to standard form
		aTableau = this.buildSimplexTableau()
		
		# Simplex iterations
		while this.hasNegativeCoefficient(aTableau)
			@iterations++
			
			# Find pivot column (most negative coefficient)
			nPivotCol = this.findPivotColumn(aTableau)
			
			# Find pivot row (minimum ratio test)
			nPivotRow = this.findPivotRow(aTableau, nPivotCol)
			
			if nPivotRow = -1
				@status = "unbounded"
				exit
			ok
			
			# Perform pivot operation
			aTableau = this.pivotTableau(aTableau, nPivotRow, nPivotCol)
			
			# Prevent infinite loops
			if @iterations > 1000
				@status = "iteration_limit"
				exit
			ok
		end
		
		# Extract solution from tableau
		return this.extractSimplexSolution(aTableau)

	def solveWithBranchAndBound()
		# Branch and bound for integer problems
		@status = "optimal"
		@iterations = 0
		
		# First solve LP relaxation
		oRelaxed = this.createRelaxedProblem()
		aSolution = oRelaxed.solveWithSimplex()
		
		# Check if solution is already integer
		if this.isIntegerSolution(aSolution)
			return aSolution
		ok
		
		# Branch and bound search
		aBestSolution = aSolution
		nBestValue = this.evaluateSolution(aSolution)
		
		aBranches = [aSolution]
		
		while len(aBranches) > 0 and @iterations < 100
			@iterations++
			
			# Get next branch
			aCurrentSolution = aBranches[1]
			del(aBranches, 1)
			
			# Find fractional variable
			cFracVar = this.findFractionalVariable(aCurrentSolution)
			if cFracVar = ""
				loop
			ok
			
			nFracValue = this.getSolutionValue(aCurrentSolution, cFracVar)
			
			# Create two branches
			aBranch1 = this.addBranchConstraint(aCurrentSolution, cFracVar, "<=", floor(nFracValue))
			aBranch2 = this.addBranchConstraint(aCurrentSolution, cFracVar, ">=", ceil(nFracValue))
			
			# Evaluate branches
			for aBranch in [aBranch1, aBranch2]
				if this.isFeasible(aBranch)
					nValue = this.evaluateSolution(aBranch)
					
					if this.isBetter(nValue, nBestValue)
						if this.isIntegerSolution(aBranch)
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
		@status = "optimal"
		@iterations = 0
		
		nPopSize = 50
		nGenerations = 100
		nMutationRate = 0.1
		
		# Initialize population
		aPopulation = this.initializePopulation(nPopSize)
		aBestSolution = aPopulation[1]
		nBestFitness = this.calculateFitness(aBestSolution)
		
		for nGen = 1 to nGenerations
			@iterations++
			
			# Evaluate fitness for all individuals
			aFitness = []
			nLen = len(aPopulation)
			for i = 1 to nLen
				nFit = this.calculateFitness(aPopulation[i])
				aFitness + nFit
				
				# Track best solution
				if this.isBetter(nFit, nBestFitness)
					aBestSolution = aPopulation[i]
					nBestFitness = nFit
				ok
			next
			
			# Create next generation
			aNewPopulation = []
			
			for i = 1 to nPopSize
				# Selection (tournament)
				aParent1 = this.tournamentSelection(aPopulation, aFitness)
				aParent2 = this.tournamentSelection(aPopulation, aFitness)
				
				# Crossover
				aChild = this.crossover(aParent1, aParent2)
				
				# Mutation
				if random(100)/100 < nMutationRate
					aChild = this.mutate(aChild)
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
		aVarNames = this.variableNames()
		nLen = len(aVarNames)

		for i = 1 to nLen
			cVar = aVarNames[i]
			nCoeff = this.extractCoefficient(@objective, cVar)
			aCoeffs + nCoeff
		next
		
		return aCoeffs

	def extractCoefficient(cExpression, cVarName)
		# Simple coefficient extraction
		# Look for patterns like "5*x" or "-3*y" or just "x"
		#TODO // Use stzRegex instead for full solution

		cPattern = cVarName
		nPos = ring_substr1(cExpression, cPattern)
		
		if nPos = 0
			return 0  # Variable not in expression
		ok
		
		# Check for coefficient before variable
		if nPos > 1
			oExpr = new stzString(cExpression)
			cBefore = oExpr.Section(nPos-1, 1)
			if cBefore = "*"
				# Find the coefficient
				nStart = nPos - 2
				c = oExpr.Section(nStart, 1)
				while nStart > 0 and (isdigit(c) or c = ".")
					nStart--
				end
				if nStart < nPos - 2
					cCoeffStr = oExpr.Section(nStart+1, nPos-nStart-2)
					return 0 + cCoeffStr  # Convert to number
				ok
			ok
		ok
		
		return 1  # Default coefficient if just variable name

	def calculateResourceCost(cVarName)
		# Calculate total resource cost for one unit of variable
		nTotalCost = 0
		nLen = len(@constraints)
		for i = 1 to nLen
			aConst = @constraints[i]
			nCoeff = this.extractCoefficient(aConst[:expression], cVarName)
			nTotalCost += abs(nCoeff)
		next
		
		return nTotalCost

	def CalculateMaxPossibleValue(cVarName, aSolution)
		# Calculate maximum possible value considering constraints
		nMinLimit = 999999
		nLen = len(@constraints)
		for i = 1 to nLen
			aConst = @constraints[i]
			nCoeff = this.extractCoefficient(aConst[:expression], cVarName)
			
			if nCoeff != 0
				# Calculate used resources by other variables
				nUsedResources = 0
				aVarNames = this.variableNames()
				nLenVar = len(aVarNames)
				for j = 1 to nLenVar
					if aVarNames[j] != cVarName
						nVarCoeff = this.extractCoefficient(aConst[:expression], aVarNames[j])
						nVarValue = this.getSolutionValue(aSolution, aVarNames[j])
						nUsedResources += nVarCoeff * nVarValue
					ok
				next
				
				# Calculate remaining capacity
				nRemainingCapacity = aConst[:value] - nUsedResources
				
				if nCoeff > 0
					nLimit = nRemainingCapacity / nCoeff
					if nLimit < nMinLimit
						nMinLimit = nLimit
					ok
				ok
			ok
		next
		
		return max([ 0, floor(nMinLimit) ])

	def GetSolutionValue(aSolution, cVarName)
		nLen = len(aSolution)
		for i = 1 to nLen
			if aSolution[i][1] = cVarName
				return aSolution[i][2]
			ok
		next
		return 0

	def EvaluateSolution(aSolution)
		# Evaluate objective function value
		nValue = 0
		aCoeffs = this.parseObjectiveCoefficients()
		aVarNames = this.variableNames()
		nLen = len(aVarNames)

		for i = 1 to nLen
			nVarValue = this.getSolutionValue(aSolution, aVarNames[i])
			nValue += aCoeffs[i] * nVarValue
		next
		
		return nValue

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
		aVarNames = this.variableNames()
		nLen = len(aVarNames)

		for i = 1 to nLen
			aSolution + [aVarNames[i], 0]
		next
		
		return aSolution

	def CreateRelaxedProblem()
		# Create LP relaxation for integer problem
		oRelaxed = new stzLinearSolver()
		
		# Copy variables as continuous
		nLen = len(@variables)

		for i = 1 to nLen
			aVar = @variables[i]
			
			oRelaxed.addVariable(
				aVar[:name], 
				aVar[:lowerBound], 
				aVar[:upperBound]
			)
		next
		
		# Copy constraints
		nLen = len(@constraints)
		for i = 1 to nLen
			aConst = @constraints[i]
			oRelaxed.addConstraint(
				aConst[:expression],
				aConst[:operator],
				aConst[:value]
			)
		next
		
		# Copy objective
		if @objectiveType = "maximize"
			oRelaxed.maximize(@objective)
		else
			oRelaxed.minimize(@objective)
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
		nLen = len(@constraints)

		for i = 1 to nLen
			aConst = @constraints[i]
			nLeftSide = this.evaluateConstraintLeft(aConst[:expression], aSolution)
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
		aVarNames = this.variableNames()
		nLen = len(aVarNames)

		for i = 1 to nLen
			nCoeff = this.extractCoefficient(cExpression, aVarNames[i])
			nVarValue = this.getSolutionValue(aSolution, aVarNames[i])
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
		aVarNames = this.variableNames()
		
		for i = 1 to nSize
			aIndividual = []
			nLen = len(aVarNames)
			for j = 1 to nLen
				nLower = @variables[j][:lowerBound]  
				nUpper = @variables[j][:upperBound]
				nValue = nLower + random(nUpper - nLower)
				aIndividual + [aVarNames[j], nValue]
			next
			aPopulation + aIndividual
		next
		
		return aPopulation

	def CalculateFitness(aIndividual)
		# Fitness = objective value - penalty for constraint violations
		nObjectiveValue = this.evaluateSolution(aIndividual)
		nPenalty = this.calculatePenalty(aIndividual)
		
		if @objectiveType = "maximize"
			return nObjectiveValue - nPenalty
		else
			return -nObjectiveValue - nPenalty
		ok

	def CalculatePenalty(aIndividual)
		nPenalty = 0
		nLen = len(@constraints)

		for i = 1 to nLen
			aConst = @constraints[i]
			nLeftSide = this.evaluateConstraintLeft(aConst[:expression], aIndividual)
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
		nLen = len(@variables)
		for i = 1 to nLen
			if @variables[i][:name] = cVarName
				nLower = @variables[i][:lowerBound]
				nUpper = @variables[i][:upperBound]
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

		# Calculate objective value from current solution
		cExpression = @objective

		# Substitute variable values
		nLen = len(@variables)
		for i = 1 to nLen
			cVarName = @variables[i][:name]
			nValue = @aSolution[cVarName]
			cExpression = ring_substr2(cExpression, cVarName, "" + nValue)
		next

		# Evaluate expression (simplified)
		return this.evaluateExpression(cExpression)

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
		return @status

	def iterations()
		return @iterations

	def solveTime()
		return @solveTime

	  #-------------------------#
	 #  DISPLAY AND REPORTING  #
	#-------------------------#

	def show()
		? BoxRound("Problem")
		? "• Variables:"
		nLen = len(@variables)

		for i = 1 to nLen
			aVar = @variables[i]
			if @trim(aVar[:name]) != ""
				? " ─ " + aVar[:name] + " ∈ [" + 
				  aVar[:lowerBound] + ", " + 
				  aVar[:upperBound] + "] (" + 
				  aVar[:type] + ")"
			ok
		next

		? ""
		? "• Constraints:"
		nLen = len(@constraints)
		for i = 1 to nLen
			aConst = @constraints[i]
			? " ─ " + aConst[:expression] + " " + 
			  aConst[:operator] + " " + 
			  aConst[:value]
		next

		? ""
		? "• Objective:"
		? "  " + upper(@objectiveType) + " " + @objective

		if @status != ""
			? ""
			? BoxRound("Solution")
			? "• Status: " + @status
			? "• Solved in " + @solveTime + " second(s)"
			? "• Iterations: " + @iterations
			? ""
			? "• Variable Values:"
			nLen = len(@aSolution)
			for i = 1 to nLen
				if @trim(@aSolution[i][1]) != ""
					? " ─ " + @aSolution[i][1] + " = " + @aSolution[i][2]
				ok
			next
			? ""
			? "• Objective Value: " + this.objectiveValue()
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
		cContent = "Linear Programming Problem Report" + nl
		cContent += "=================================" + nl + nl
		
		cContent += "Problem Definition:" + nl
		cContent += "Variables: " + len(@variables) + nl
		cContent += "Constraints: " + len(@constraints) + nl
		cContent += "Objective: " + upper(@objectiveType) + " " + @objective + nl + nl
		
		if @status != ""
			cContent += "Solution:" + nl
			cContent += "Status: " + @status + nl
			cContent += "Solve Time: " + @solveTime + " seconds" + nl
			cContent += "Iterations: " + @iterations + nl
			cContent += "Objective Value: " + this.objectiveValue() + nl + nl
			
			cContent += "Variable Values:" + nl
			nLen = len(@aSolution)
			for i = 1 to nLen
				cContent += @aSolution[i][1] + " = " + @aSolution[i][2] + nl
			next
		ok

		oFile.write(cContent)

	  #----------------#
	 # HELPER METHODS #
	#----------------#

	def isValidVariableName(cName)
		# Check if variable name is valid
		nLen = len(@variables)
		for i = 1 to nLen
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
