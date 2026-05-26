
/*
    stzStochasticSolver - Enhanced Stochastic Programming Component for Softanza
    Author: Softanza Team
    Version: 1.1
    Features: Scenario-based optimization, robust optimization, uncertainty modeling, string constraint values
*/

class stzStochasticSolver

    @aVariables = []
    @aConstraints = []
    @cObjective = ""
    @cObjectiveType = "maximize"
    @aScenarios = []
    @aSolution = []
    @cStatus = ""
    @nIterations = 0
    @nSolveTime = 0
    @cSolverType = "expected"
    @nRobustnessFactor = 0.1
    @nConfidenceLevel = 0.95

	@oCoeffExtractor

    def init()
        This.clear()
		@oCoeffExtractor = new stzCoeffExtractor(This.variableNames())

    def clear()
        @aVariables = []
        @aConstraints = []
        @cObjective = ""
        @cObjectiveType = "maximize"
        @aScenarios = []
        @aSolution = []
        @cStatus = ""
        @nIterations = 0
        @nSolveTime = 0
        @cSolverType = "expected"
        @nRobustnessFactor = 0.1
        @nConfidenceLevel = 0.95

    # Variables Management
    def addVariable(varName, lowerBound, upperBound)
        if NOT isString(varName) stzRaise("Variable name must be a string!") ok
        if NOT (isNumber(lowerBound) and isNumber(upperBound)) stzRaise("Bounds must be numbers!") ok
        if upperBound < lowerBound stzRaise("Upper bound must be >= lower bound!") ok

        @aVariables + [ :name = varName, :lowerBound = lowerBound, :upperBound = upperBound, :type = "continuous" ]
        return this

    def addIntegerVariable(varName, lowerBound, upperBound)
        This.addVariable(varName, lowerBound, upperBound)
        @aVariables[len(@aVariables)][:type] = "integer"
        return this

    def addBinaryVariable(varName)
        This.addVariable(varName, 0, 1)
        @aVariables[len(@aVariables)][:type] = "binary"
        return this

    def variables()
        return @aVariables

    def variableNames()
        aNames = []
        for var in @aVariables
            aNames + var[:name]
        next
        return aNames

		def VarNames()
			return This.VariableNames()

	def SetVariableNames(pacNames)
		#TODO // Add more checks here
		@aVariables = pacNames

    # Scenario Management
    def addScenario(name, description, parameters, probability)
        if NOT isString(name) stzRaise("Scenario name must be a string!") ok
        if NOT isString(description) stzRaise("Description must be a string!") ok
        if NOT isList(parameters) stzRaise("Parameters must be a list of [name, value] pairs!") ok
        if NOT isNumber(probability) stzRaise("Probability must be a number!") ok
        if probability < 0 or probability > 1 stzRaise("Probability must be between 0 and 1!") ok

        @aScenarios + [ :name = name, :description = description, :parameters = parameters, :probability = probability ]
        return this

    def scenarios()
        return @aScenarios

    def validateScenarios()
        nTotalProb = 0
        for scenario in @aScenarios
            nTotalProb += scenario[:probability]
        next
        if abs(nTotalProb - 1.0) > 0.001 stzRaise("Scenario probabilities must sum to 1.0!") ok

    # Constraints Management - Enhanced to support string values
    def addConstraint(expression, operator, value)
        if NOT isString(expression) stzRaise("Expression must be a string!") ok
        if NOT (operator = "<=" or operator = ">=" or operator = "=") stzRaise("Operator must be '<=', '>=', or '='!") ok
        if NOT (isNumber(value) or isString(value)) stzRaise("Value must be a number or string expression!") ok

        @aConstraints + [ :expression = expression, :operator = operator, :value = value, :scenario = "all", :chance = 1.0 ]
        return this

    def addScenarioConstraint(expression, operator, value, scenarioName)
        if NOT isString(scenarioName) stzRaise("Scenario name must be a string!") ok
        if NOT (isNumber(value) or isString(value)) stzRaise("Value must be a number or string expression!") ok
        
        @aConstraints + [ :expression = expression, :operator = operator, :value = value, :scenario = scenarioName, :chance = 1.0 ]
        return this

    def addChanceConstraint(expression, operator, value, confidenceLevel)
        if NOT isNumber(confidenceLevel) stzRaise("Confidence level must be a number!") ok
        if confidenceLevel < 0 or confidenceLevel > 1 stzRaise("Confidence level must be between 0 and 1!") ok
        if NOT (isNumber(value) or isString(value)) stzRaise("Value must be a number or string expression!") ok

        @aConstraints + [ :expression = expression, :operator = operator, :value = value, :scenario = "all", :chance = confidenceLevel ]
        return this

    def constraints()
        return @aConstraints

    # Objective Function
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

    # Solver Configuration
    def setSolverType(cType)
        if NOT (cType = "expected" or cType = "robust" or cType = "chance" or cType = "montecarlo")
            stzRaise("Solver type must be 'expected', 'robust', 'chance', or 'montecarlo'!")
        ok
        @cSolverType = cType
        return this

    def setRobustnessFactor(nFactor)
        if NOT isNumber(nFactor) stzRaise("Robustness factor must be a number!") ok
        if nFactor < 0 or nFactor > 1 stzRaise("Robustness factor must be between 0 and 1!") ok
        @nRobustnessFactor = nFactor
        return this

    def setConfidenceLevel(nLevel)
        if NOT isNumber(nLevel) stzRaise("Confidence level must be a number!") ok
        if nLevel < 0 or nLevel > 1 stzRaise("Confidence level must be between 0 and 1!") ok
        @nConfidenceLevel = nLevel
        return this

    # Enhanced Value Evaluation - New method to handle string constraint values
    def evaluateConstraintValue(value, scenario)
        if isNumber(value)
            return value
        else
            # Apply scenario parameters to string expression
            cEvaluated = This.applyScenarioParameters(string(value), scenario[:parameters])
            # Simple expression evaluator for basic math operations
            return This.evaluateExpression(cEvaluated)
        ok

    def evaluateExpression(cExpression)
        # Simple expression evaluator for basic arithmetic
        # Handles: number, number * number, number + number, number - number, number / number
        cExpr = trim(cExpression)
        
        # Handle multiplication
        if ring_substr1(cExpr, "*")
            acParts = split(cExpr, "*")
            if len(acParts) = 2
                nLeft = 0+ trim(acParts[1])
                nRight = 0+ trim(acParts[2])
                return nLeft * nRight
            ok
        ok
        
        # Handle division
        if ring_substr1(cExpr, "/")
            acParts = split(cExpr, "/")
            if len(acParts) = 2
                nLeft = 0+ trim(acParts[1])
                nRight = 0+ trim(acParts[2])
                if nRight != 0
                    return nLeft / nRight
                else
                    stzRaise("Division by zero in constraint value!")
                ok
            ok
        ok
        
        # Handle addition
        if ring_substr1(cExpr, "+")
            acParts = split(cExpr, "+")
            if len(acParts) = 2
                nLeft = 0+ trim(acParts[1])
                nRight = 0+ trim(acParts[2])
                return nLeft + nRight
            ok
        ok
        
        # Handle subtraction
        if ring_substr1(cExpr, "-")
            acParts = split(cExpr, "-")
            if len(acParts) = 2
                nLeft = 0+ trim(acParts[1])
                nRight = 0+ trim(acParts[2])
                return nLeft - nRight
            ok
        ok
        
        # If no operators, try to convert to number
        return 0+ cExpr

    # Main Solving Methods
    def solve()
        nStartTime = clock()
        if len(@aVariables) = 0 stzRaise("No variables defined!") ok
        if @cObjective = "" stzRaise("No objective function defined!") ok
        if len(@aScenarios) = 0 stzRaise("No scenarios defined! Use addScenario() to model uncertainty.") ok

        This.validateScenarios()

        switch @cSolverType
        on "expected"
            @aSolution = This.solveExpectedValue()
        on "robust"
            @aSolution = This.solveRobust()
        on "chance"
            @aSolution = This.solveChanceConstrained()
        on "montecarlo"
            @aSolution = This.solveMonteCarlo()
        off

        @nSolveTime = (clock() - nStartTime) / clockspersecond()
        @cStatus = "optimal"
        return this

    # Expected Value Method
    def solveExpectedValue()
        @nIterations = len(@aVariables)
        aVarNames = This.variableNames()
        aSolution = []

        # Initialize solution
        for i = 1 to len(@aVariables)
            aSolution + [aVarNames[i], @aVariables[i][:lowerBound]]
        next

        # Calculate expected objective coefficients
        aExpectedCoeffs = []
        for varName in aVarNames
            nExpectedCoeff = 0
            for scenario in @aScenarios
                cModifiedObjective = This.applyScenarioParameters(@cObjective, scenario[:parameters])
                nCoeff = This.extractCoefficient(cModifiedObjective, varName)
                if @cObjectiveType = "minimize" nCoeff = -nCoeff ok
                nExpectedCoeff += nCoeff * scenario[:probability]
            next
            aExpectedCoeffs + nExpectedCoeff
        next

        # Calculate efficiency for each variable
        aEfficiency = []
        for i = 1 to len(aVarNames)
            nCoeff = aExpectedCoeffs[i]
            nResourceCost = This.calculateExpectedResourceCost(aVarNames[i])
			if nResourceCost = 0
				nEfficiency = 1
			else
            	nEfficiency = iff(nResourceCost > 0, nCoeff / nResourceCost, 0)
			ok
            aEfficiency + [aVarNames[i], nEfficiency, i]
        next

        # Sort by efficiency (descending)
        aEfficiency = sorton(aEfficiency, 2)
        aEfficiency = reverse(aEfficiency)

        # Assign maximum feasible values
        for eff in aEfficiency
            cVarName = eff[1]
            nVarIndex = eff[3]
            nMaxPossible = This.calculateExpectedMaxValue(cVarName, aSolution)
            nUpperBound = @aVariables[nVarIndex][:upperBound]
            nValue = min([nMaxPossible, nUpperBound])
            for sol in aSolution
                if sol[1] = cVarName
                    sol[2] = nValue
                    exit
                ok
            next
        next

        return aSolution

    # Robust Optimization
    def solveRobust()
        aVarNames = This.variableNames()
        aSolution = []

        # Initialize solution
        for i = 1 to len(@aVariables)
            aSolution + [aVarNames[i], @aVariables[i][:lowerBound]]
        next

        # Use worst-case scenario for objective
        cWorstObjective = This.getWorstCaseObjective()
        aCoeffs = This.parseObjectiveCoefficients(cWorstObjective)

        # Calculate efficiency using worst-case
        aEfficiency = []
        for i = 1 to len(aVarNames)
            nCoeff = aCoeffs[i]
            nResourceCost = This.calculateWorstCaseResourceCost(aVarNames[i])
            nEfficiency = iff(nResourceCost > 0, nCoeff / nResourceCost, 0)
            aEfficiency + [aVarNames[i], nEfficiency, i]
        next

        aEfficiency = sorton(aEfficiency, 2)
        aEfficiency = reverse(aEfficiency)

        # Assign values using robust constraints
        for eff in aEfficiency
            cVarName = eff[1]
            nVarIndex = eff[3]
            nMaxPossible = This.calculateRobustMaxValue(cVarName, aSolution)
            nUpperBound = @aVariables[nVarIndex][:upperBound]
            nValue = min([nMaxPossible, nUpperBound])
            for sol in aSolution
                if sol[1] = cVarName
                    sol[2] = nValue
                    exit
                ok
            next
        next

        return aSolution

    # Chance-Constrained Programming
    def solveChanceConstrained()
        # Simplified chance-constrained approach
        # Uses confidence level to adjust constraints
        aVarNames = This.variableNames()
        aSolution = []

        # Initialize solution
        for i = 1 to len(@aVariables)
            aSolution + [aVarNames[i], @aVariables[i][:lowerBound]]
        next

        # Use expected objective but confidence-adjusted constraints
        aExpectedCoeffs = []
        for varName in aVarNames
            nExpectedCoeff = 0
            for scenario in @aScenarios
                cModifiedObjective = This.applyScenarioParameters(@cObjective, scenario[:parameters])
               nCoeff = This.extractCoefficient(cModifiedObjective, varName)
                if @cObjectiveType = "minimize" nCoeff = -nCoeff ok
                nExpectedCoeff += nCoeff * scenario[:probability]
            next
            aExpectedCoeffs + nExpectedCoeff
        next

        # Calculate efficiency with chance constraints
        aEfficiency = []
        for i = 1 to len(aVarNames)
            nCoeff = aExpectedCoeffs[i]
            nResourceCost = This.calculateChanceResourceCost(aVarNames[i])
            nEfficiency = iff(nResourceCost > 0, nCoeff / nResourceCost, 0)
            aEfficiency + [aVarNames[i], nEfficiency, i]
        next

        aEfficiency = sorton(aEfficiency, 2)
        aEfficiency = reverse(aEfficiency)

        # Assign values respecting chance constraints
        for eff in aEfficiency
            cVarName = eff[1]
            nVarIndex = eff[3]
            nMaxPossible = This.calculateChanceMaxValue(cVarName, aSolution)
            nUpperBound = @aVariables[nVarIndex][:upperBound]
            nValue = min([nMaxPossible, nUpperBound])
            for sol in aSolution
                if sol[1] = cVarName
                    sol[2] = nValue
                    exit
                ok
            next
        next

        return aSolution

    # Monte Carlo Simulation
    def solveMonteCarlo()
        nSimulations = 100
        aBestSolution = []
        nBestValue = iff(@cObjectiveType = "maximize",-999999, 999999)

        for sim = 1 to nSimulations
            # Sample scenario based on probabilities
            nRand = random(100) / 100.0
            nCumProb = 0
            selectedScenario = @aScenarios[1]
            for scenario in @aScenarios
                nCumProb += scenario[:probability]
                if nRand <= nCumProb
                    selectedScenario = scenario
                    exit
                ok
            next

            # Solve for this scenario
            aSampleSolution = This.solveForScenario(selectedScenario)
            nSampleValue = This.calculateScenarioObjectiveValue(aSampleSolution, selectedScenario)

            # Update best solution
            if (@cObjectiveType = "maximize" and nSampleValue > nBestValue) or 
               (@cObjectiveType = "minimize" and nSampleValue < nBestValue)
                nBestValue = nSampleValue
                aBestSolution = aSampleSolution
            ok
        next

        return aBestSolution

    # Helper Methods
    def applyScenarioParameters(cExpression, aParameters)
        cResult = cExpression
        for param in aParameters
            cResult = StzStringQ(cResult).ReplaceAllQ(param[1], string(param[2])).Content()
        next
        return cResult

    def extractCoefficient(cExpression, cVarName)
        return @oCoeffExtractor.extractCoefficient(cExpression, cVarName)
	

    def parseObjectiveCoefficients(cExpression)
		@oCoeffExtractor.SetVariableNames(This.VariableNames())
        return @oCoeffExtractor.extractAllCoefficients(cExpression)

    def calculateExpectedResourceCost(cVarName)
        nExpectedCost = 0
        for scenario in @aScenarios
            nScenarioCost = 0
            for const in @aConstraints
                if const[:scenario] = "all" or const[:scenario] = scenario[:name]
                    cModifiedExpression = This.applyScenarioParameters(const[:expression], scenario[:parameters])
                    nCoeff = This.extractCoefficient(cModifiedExpression, cVarName)
                    nScenarioCost += abs(nCoeff)
                ok
            next
            nExpectedCost += nScenarioCost * scenario[:probability]
        next
        return nExpectedCost

    def calculateWorstCaseResourceCost(cVarName)
        nWorstCost = 0
        for scenario in @aScenarios
            nScenarioCost = 0
            for const in @aConstraints
                if const[:scenario] = "all" or const[:scenario] = scenario[:name]
                    cModifiedExpression = This.applyScenarioParameters(const[:expression], scenario[:parameters])
                    nCoeff = This.extractCoefficient(cModifiedExpression, cVarName)
                    nScenarioCost += abs(nCoeff)
                ok
            next
            if nScenarioCost > nWorstCost nWorstCost = nScenarioCost ok
        next
        return nWorstCost

    def calculateChanceResourceCost(cVarName)
        # Use confidence level to weight resource costs
        nWeightedCost = 0
        for scenario in @aScenarios
            nScenarioCost = 0
            for const in @aConstraints
                if const[:scenario] = "all" or const[:scenario] = scenario[:name]
                    cModifiedExpression = This.applyScenarioParameters(const[:expression], scenario[:parameters])
                    nCoeff = This.extractCoefficient(cModifiedExpression, cVarName)
                    nWeight = iff(const[:chance] >= @nConfidenceLevel, 1, const[:chance]/@nConfidenceLevel)
                    nScenarioCost += abs(nCoeff) * nWeight
                ok
            next
            nWeightedCost += nScenarioCost * scenario[:probability]
        next
        return nWeightedCost

    def calculateExpectedMaxValue(cVarName, aSolution)
        nMinLimit = 999999
        for scenario in @aScenarios
            nScenarioLimit = This.calculateScenarioMaxValue(cVarName, aSolution, scenario)
            nWeightedLimit = nScenarioLimit * scenario[:probability]
            if nWeightedLimit < nMinLimit nMinLimit = nWeightedLimit ok
        next
        return max([0, nMinLimit])

    def calculateRobustMaxValue(cVarName, aSolution)
        nMinLimit = 999999
        for scenario in @aScenarios
            nScenarioLimit = This.calculateScenarioMaxValue(cVarName, aSolution, scenario)
            nRobustLimit = nScenarioLimit * (1 - @nRobustnessFactor)
            if nRobustLimit < nMinLimit nMinLimit = nRobustLimit ok
        next
        return max([0, nMinLimit])

    def calculateChanceMaxValue(cVarName, aSolution)
        aLimits = []
        for scenario in @aScenarios
            nScenarioLimit = This.calculateScenarioMaxValue(cVarName, aSolution, scenario)
            aLimits + [nScenarioLimit, scenario[:probability]]
        next
        
        # Sort limits and find confidence level cutoff
        aLimits = sorton(aLimits, 1)
        nCumProb = 0
        for limit in aLimits
            nCumProb += limit[2]
            if nCumProb >= @nConfidenceLevel
                return max([0, limit[1]])
            ok
        next
        return max([0, aLimits[len(aLimits)][1]])

    def calculateScenarioMaxValue(cVarName, aSolution, scenario)
        nMinLimit = 999999
        for const in @aConstraints
            if const[:scenario] = "all" or const[:scenario] = scenario[:name]
                cModifiedExpression = This.applyScenarioParameters(const[:expression], scenario[:parameters])
                nModifiedValue = This.evaluateConstraintValue(const[:value], scenario)  # Enhanced to handle string values
                nCoeff = This.extractCoefficient(cModifiedExpression, cVarName)
                if nCoeff != 0
                    nUsedResources = 0
                    for var in This.variableNames()
                        if var != cVarName
                            nVarCoeff = This.extractCoefficient(cModifiedExpression, var)
                            nVarValue = This.getSolutionValue(aSolution, var)
                            nUsedResources += nVarCoeff * nVarValue
                        ok
                    next
                    nRemainingCapacity = nModifiedValue - nUsedResources
                    switch const[:operator]
                    on "=" or "<="
                        if nCoeff > 0
                            nLimit = nRemainingCapacity / nCoeff
                            if nLimit < nMinLimit nMinLimit = nLimit ok
                        ok
                    off
                ok
            ok
        next
        return nMinLimit

    def getWorstCaseObjective()
        cWorstObjective = @cObjective
        nWorstValue = iff(@cObjectiveType = "maximize", -999999, 999999)
        
        for scenario in @aScenarios
            cScenarioObjective = This.applyScenarioParameters(@cObjective, scenario[:parameters])
            # For simplicity, return the first scenario's objective
            # In practice, would need more sophisticated worst-case analysis
            if scenario = @aScenarios[1]
                cWorstObjective = cScenarioObjective
            ok
        next
        return cWorstObjective

    def solveForScenario(scenario)
        aVarNames = This.variableNames()
        aSolution = []
        
        # Initialize solution
        for i = 1 to len(@aVariables)
            aSolution + [aVarNames[i], @aVariables[i][:lowerBound]]
        next
        
        # Solve using this scenario's parameters
        cScenarioObjective = This.applyScenarioParameters(@cObjective, scenario[:parameters])
        aCoeffs = This.parseObjectiveCoefficients(cScenarioObjective)
        
        # Simple greedy assignment
        for i = 1 to len(aVarNames)
            cVarName = aVarNames[i]
            nMaxPossible = This.calculateScenarioMaxValue(cVarName, aSolution, scenario)
            nUpperBound = @aVariables[i][:upperBound]
            nValue = min([nMaxPossible, nUpperBound])
            aSolution[i][2] = nValue
        next
        
        return aSolution

    def calculateScenarioObjectiveValue(aSolution, scenario)
        cScenarioObjective = This.applyScenarioParameters(@cObjective, scenario[:parameters])
        nResult = 0
        for var in @aVariables
            nValue = This.getSolutionValue(aSolution, var[:name])
            nCoeff = This.extractCoefficient(cScenarioObjective, var[:name])
            nResult += nCoeff * nValue
        next
        return nResult

    def getSolutionValue(aSolution, cVarName)
        for sol in aSolution
            if sol[1] = cVarName return sol[2] ok
        next
        return 0

    # Analysis Methods
    def analyzeScenarios()
        if len(@aSolution) = 0 stzRaise("No solution available! Call solve() first.") ok
        
        aScenarioResults = []
        for scenario in @aScenarios
            nObjectiveValue = This.calculateScenarioObjectiveValue(@aSolution, scenario)
            bFeasible = This.checkScenarioFeasibility(@aSolution, scenario)
            aScenarioResults + [ :scenario = scenario[:name], :probability = scenario[:probability], 
                               :objectiveValue = nObjectiveValue, :feasible = bFeasible ]
        next
        return aScenarioResults

    def checkScenarioFeasibility(aSolution, scenario)
        for const in @aConstraints
            if const[:scenario] = "all" or const[:scenario] = scenario[:name]
                cModifiedExpression = This.applyScenarioParameters(const[:expression], scenario[:parameters])
                nModifiedValue = This.evaluateConstraintValue(const[:value], scenario)  # Enhanced to handle string values
                
                nLHS = 0
                for var in This.variableNames()
                    nCoeff = This.extractCoefficient(cModifiedExpression, var)
                    nVarValue = This.getSolutionValue(aSolution, var)
                    nLHS += nCoeff * nVarValue
                next
                
                nRHS = nModifiedValue
                switch const[:operator]
                on "<="
                    if nLHS > nRHS + 0.001 return false ok
                on ">="  
                    if nLHS < nRHS - 0.001 return false ok
                on "="
                    if abs(nLHS - nRHS) > 0.001 return false ok
                off
            ok
        next
        return true

    def expectedObjectiveValue()
        if len(@aSolution) = 0 return 0 ok
        
        nExpectedValue = 0
        for scenario in @aScenarios
            nScenarioValue = This.calculateScenarioObjectiveValue(@aSolution, scenario)
            nExpectedValue += nScenarioValue * scenario[:probability]
        next
        return nExpectedValue

    # Solution Access
    def solution()
        return @aSolution

    def status()
        return @cStatus

    def iterations()
        return @nIterations

    def solveTime()
        return @nSolveTime

    def solverType()
        return @cSolverType

    # Display and Reporting
    def show()

        ? BoxRound("Stochastic Programming Problem")
        ? "• Variables:"
        for var in @aVariables
            ? " ─ " + var[:name] + " ∈ [" + var[:lowerBound] + ", " + var[:upperBound] + "] (" + var[:type] + ")"
        next

		? ""
        ? "• Objective:"  
        ? "╰─> " + upper(@cObjectiveType) + " " + @cObjective

		? ""
        ? "• Scenarios:"
        for scenario in @aScenarios
            ? " ─ " + scenario[:name] + ": " + scenario[:description] + " (p=" + scenario[:probability] + ")"
            for param in scenario[:parameters]
                ? " ╰─> " + param[1] + " = " + param[2]
            next
			? ""
        next

        ? "• Constraints:"
        for const in @aConstraints
            cScenarioInfo = iff(const[:scenario] != "all", " [" + const[:scenario] + "]", "")
            cChanceInfo = iff(const[:chance] < 1.0, " (chance=" + const[:chance] + ")", "")
            ? " ─ " + const[:expression] + " " + const[:operator] + " " + const[:value] + cScenarioInfo + cChanceInfo
        next

		? ""
        if @cStatus != ""
            ? BoxRound("Solution")
            ? "• Status: " + @cStatus
            ? "• Solver: " + @cSolverType
            ? "• Solved in " + @nSolveTime + " second(s)"

			? ""
            ? "• Variable Values:"
            for sol in @aSolution
                ? " ─ " + sol[1] + " = " + sol[2]
            next

			? ""
            ? "• Expected Objective Value: " + This.expectedObjectiveValue()

			? ""
            ? "• Scenario Analysis:"
            aResults = This.analyzeScenarios()
            for result in aResults
                cFeasible = iff(result[:feasible], "✓", "✗")
                ? " ─ " + result[:scenario] + " (p=" + result[:probability] + "): " + result[:objectiveValue] + " " + cFeasible
            next
        ok

    def exportToCSV(cFileName)
        oFile = new stzFile(cFileName)
        cContent = "Variable,Value" + nl
        for sol in @aSolution
            cContent += sol[1] + "," + sol[2] + nl
        next
        oFile.write(cContent)

    def exportScenarioAnalysis(cFileName)
        oFile = new stzFile(cFileName)
        cContent = "Scenario,Probability,ObjectiveValue,Feasible" + nl
        
        aResults = This.analyzeScenarios()
        for result in aResults
            cFeasible = iff(result[:feasible], "Yes", "No")
            cContent += result[:scenario] + "," + result[:probability] + "," + result[:objectiveValue] + "," + cFeasible + nl
        next
        
        oFile.write(cContent)
