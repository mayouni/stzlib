
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
        @aVariables[ring_len(@aVariables)][:type] = "integer"
        return this

    def addBinaryVariable(varName)
        This.addVariable(varName, 0, 1)
        @aVariables[ring_len(@aVariables)][:type] = "binary"
        return this

    def variables()
        return @aVariables

    def variableNames()
        aNames = []
        _nVariables3Len_ = ring_len(@aVariables)
        for _iLoopVariables3_ = 1 to _nVariables3Len_
        	var = @aVariables[_iLoopVariables3_]
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
        _nScenarios14Len_ = ring_len(@aScenarios)
        for _iLoopScenarios14_ = 1 to _nScenarios14Len_
        	scenario = @aScenarios[_iLoopScenarios14_]
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
            if ring_len(acParts) = 2
                nLeft = 0+ trim(acParts[1])
                nRight = 0+ trim(acParts[2])
                return nLeft * nRight
            ok
        ok
        
        # Handle division
        if ring_substr1(cExpr, "/")
            acParts = split(cExpr, "/")
            if ring_len(acParts) = 2
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
            if ring_len(acParts) = 2
                nLeft = 0+ trim(acParts[1])
                nRight = 0+ trim(acParts[2])
                return nLeft + nRight
            ok
        ok
        
        # Handle subtraction
        if ring_substr1(cExpr, "-")
            acParts = split(cExpr, "-")
            if ring_len(acParts) = 2
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
        if ring_len(@aVariables) = 0 stzRaise("No variables defined!") ok
        if @cObjective = "" stzRaise("No objective function defined!") ok
        if ring_len(@aScenarios) = 0 stzRaise("No scenarios defined! Use addScenario() to model uncertainty.") ok

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
        @nIterations = ring_len(@aVariables)
        aVarNames = This.variableNames()
        aSolution = []

        # Initialize solution
        _nVariablesLen_4 = ring_len(@aVariables)
        for i = 1 to _nVariablesLen_4
            aSolution + [aVarNames[i], @aVariables[i][:lowerBound]]
        next

        # Calculate expected objective coefficients
        aExpectedCoeffs = []
        _nVarNames2Len_ = ring_len(aVarNames)
        for _iLoopVarNames2_ = 1 to _nVarNames2Len_
        	varName = aVarNames[_iLoopVarNames2_]
            nExpectedCoeff = 0
            _nScenarios13Len_ = ring_len(@aScenarios)
            for _iLoopScenarios13_ = 1 to _nScenarios13Len_
            	scenario = @aScenarios[_iLoopScenarios13_]
                cModifiedObjective = This.applyScenarioParameters(@cObjective, scenario[:parameters])
                nCoeff = This.extractCoefficient(cModifiedObjective, varName)
                if @cObjectiveType = "minimize" nCoeff = -nCoeff ok
                nExpectedCoeff += nCoeff * scenario[:probability]
            next
            aExpectedCoeffs + nExpectedCoeff
        next

        # Calculate efficiency for each variable
        aEfficiency = []
        _nVarNamesLen_4 = ring_len(aVarNames)
        for i = 1 to _nVarNamesLen_4
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
        _nEfficiency3Len_ = ring_len(aEfficiency)
        for _iLoopEfficiency3_ = 1 to _nEfficiency3Len_
        	eff = aEfficiency[_iLoopEfficiency3_]
            cVarName = eff[1]
            nVarIndex = eff[3]
            nMaxPossible = This.calculateExpectedMaxValue(cVarName, aSolution)
            nUpperBound = @aVariables[nVarIndex][:upperBound]
            nValue = min([nMaxPossible, nUpperBound])
            _nSolution6Len_ = ring_len(aSolution)
            for _iLoopSolution6_ = 1 to _nSolution6Len_
            	sol = aSolution[_iLoopSolution6_]
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
        _nVariablesLen_3 = ring_len(@aVariables)
        for i = 1 to _nVariablesLen_3
            aSolution + [aVarNames[i], @aVariables[i][:lowerBound]]
        next

        # Use worst-case scenario for objective
        cWorstObjective = This.getWorstCaseObjective()
        aCoeffs = This.parseObjectiveCoefficients(cWorstObjective)

        # Calculate efficiency using worst-case
        aEfficiency = []
        _nVarNamesLen_3 = ring_len(aVarNames)
        for i = 1 to _nVarNamesLen_3
            nCoeff = aCoeffs[i]
            nResourceCost = This.calculateWorstCaseResourceCost(aVarNames[i])
            nEfficiency = iff(nResourceCost > 0, nCoeff / nResourceCost, 0)
            aEfficiency + [aVarNames[i], nEfficiency, i]
        next

        aEfficiency = sorton(aEfficiency, 2)
        aEfficiency = reverse(aEfficiency)

        # Assign values using robust constraints
        _nEfficiency2Len_ = ring_len(aEfficiency)
        for _iLoopEfficiency2_ = 1 to _nEfficiency2Len_
        	eff = aEfficiency[_iLoopEfficiency2_]
            cVarName = eff[1]
            nVarIndex = eff[3]
            nMaxPossible = This.calculateRobustMaxValue(cVarName, aSolution)
            nUpperBound = @aVariables[nVarIndex][:upperBound]
            nValue = min([nMaxPossible, nUpperBound])
            _nSolution5Len_ = ring_len(aSolution)
            for _iLoopSolution5_ = 1 to _nSolution5Len_
            	sol = aSolution[_iLoopSolution5_]
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
        _nVariablesLen_2 = ring_len(@aVariables)
        for i = 1 to _nVariablesLen_2
            aSolution + [aVarNames[i], @aVariables[i][:lowerBound]]
        next

        # Use expected objective but confidence-adjusted constraints
        aExpectedCoeffs = []
        _nVarNames1Len_ = ring_len(aVarNames)
        for _iLoopVarNames1_ = 1 to _nVarNames1Len_
        	varName = aVarNames[_iLoopVarNames1_]
            nExpectedCoeff = 0
            _nScenarios12Len_ = ring_len(@aScenarios)
            for _iLoopScenarios12_ = 1 to _nScenarios12Len_
            	scenario = @aScenarios[_iLoopScenarios12_]
                cModifiedObjective = This.applyScenarioParameters(@cObjective, scenario[:parameters])
               nCoeff = This.extractCoefficient(cModifiedObjective, varName)
                if @cObjectiveType = "minimize" nCoeff = -nCoeff ok
                nExpectedCoeff += nCoeff * scenario[:probability]
            next
            aExpectedCoeffs + nExpectedCoeff
        next

        # Calculate efficiency with chance constraints
        aEfficiency = []
        _nVarNamesLen_2 = ring_len(aVarNames)
        for i = 1 to _nVarNamesLen_2
            nCoeff = aExpectedCoeffs[i]
            nResourceCost = This.calculateChanceResourceCost(aVarNames[i])
            nEfficiency = iff(nResourceCost > 0, nCoeff / nResourceCost, 0)
            aEfficiency + [aVarNames[i], nEfficiency, i]
        next

        aEfficiency = sorton(aEfficiency, 2)
        aEfficiency = reverse(aEfficiency)

        # Assign values respecting chance constraints
        _nEfficiency1Len_ = ring_len(aEfficiency)
        for _iLoopEfficiency1_ = 1 to _nEfficiency1Len_
        	eff = aEfficiency[_iLoopEfficiency1_]
            cVarName = eff[1]
            nVarIndex = eff[3]
            nMaxPossible = This.calculateChanceMaxValue(cVarName, aSolution)
            nUpperBound = @aVariables[nVarIndex][:upperBound]
            nValue = min([nMaxPossible, nUpperBound])
            _nSolution4Len_ = ring_len(aSolution)
            for _iLoopSolution4_ = 1 to _nSolution4Len_
            	sol = aSolution[_iLoopSolution4_]
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
            _nScenarios11Len_ = ring_len(@aScenarios)
            for _iLoopScenarios11_ = 1 to _nScenarios11Len_
            	scenario = @aScenarios[_iLoopScenarios11_]
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
        _nParameters1Len_ = ring_len(aParameters)
        for _iLoopParameters1_ = 1 to _nParameters1Len_
        	param = aParameters[_iLoopParameters1_]
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
        _nScenarios10Len_ = ring_len(@aScenarios)
        for _iLoopScenarios10_ = 1 to _nScenarios10Len_
        	scenario = @aScenarios[_iLoopScenarios10_]
            nScenarioCost = 0
            _nConstraints6Len_ = ring_len(@aConstraints)
            for _iLoopConstraints6_ = 1 to _nConstraints6Len_
            	const = @aConstraints[_iLoopConstraints6_]
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
        _nScenarios9Len_ = ring_len(@aScenarios)
        for _iLoopScenarios9_ = 1 to _nScenarios9Len_
        	scenario = @aScenarios[_iLoopScenarios9_]
            nScenarioCost = 0
            _nConstraints5Len_ = ring_len(@aConstraints)
            for _iLoopConstraints5_ = 1 to _nConstraints5Len_
            	const = @aConstraints[_iLoopConstraints5_]
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
        _nScenarios8Len_ = ring_len(@aScenarios)
        for _iLoopScenarios8_ = 1 to _nScenarios8Len_
        	scenario = @aScenarios[_iLoopScenarios8_]
            nScenarioCost = 0
            _nConstraints4Len_ = ring_len(@aConstraints)
            for _iLoopConstraints4_ = 1 to _nConstraints4Len_
            	const = @aConstraints[_iLoopConstraints4_]
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
        _nScenarios7Len_ = ring_len(@aScenarios)
        for _iLoopScenarios7_ = 1 to _nScenarios7Len_
        	scenario = @aScenarios[_iLoopScenarios7_]
            nScenarioLimit = This.calculateScenarioMaxValue(cVarName, aSolution, scenario)
            nWeightedLimit = nScenarioLimit * scenario[:probability]
            if nWeightedLimit < nMinLimit nMinLimit = nWeightedLimit ok
        next
        return max([0, nMinLimit])

    def calculateRobustMaxValue(cVarName, aSolution)
        nMinLimit = 999999
        _nScenarios6Len_ = ring_len(@aScenarios)
        for _iLoopScenarios6_ = 1 to _nScenarios6Len_
        	scenario = @aScenarios[_iLoopScenarios6_]
            nScenarioLimit = This.calculateScenarioMaxValue(cVarName, aSolution, scenario)
            nRobustLimit = nScenarioLimit * (1 - @nRobustnessFactor)
            if nRobustLimit < nMinLimit nMinLimit = nRobustLimit ok
        next
        return max([0, nMinLimit])

    def calculateChanceMaxValue(cVarName, aSolution)
        aLimits = []
        _nScenarios5Len_ = ring_len(@aScenarios)
        for _iLoopScenarios5_ = 1 to _nScenarios5Len_
        	scenario = @aScenarios[_iLoopScenarios5_]
            nScenarioLimit = This.calculateScenarioMaxValue(cVarName, aSolution, scenario)
            aLimits + [nScenarioLimit, scenario[:probability]]
        next
        
        # Sort limits and find confidence level cutoff
        aLimits = sorton(aLimits, 1)
        nCumProb = 0
        _nLimits1Len_ = ring_len(aLimits)
        for _iLoopLimits1_ = 1 to _nLimits1Len_
        	limit = aLimits[_iLoopLimits1_]
            nCumProb += limit[2]
            if nCumProb >= @nConfidenceLevel
                return max([0, limit[1]])
            ok
        next
        return max([0, aLimits[ring_len(aLimits)][1]])

    def calculateScenarioMaxValue(cVarName, aSolution, scenario)
        nMinLimit = 999999
        _nConstraints3Len_ = ring_len(@aConstraints)
        for _iLoopConstraints3_ = 1 to _nConstraints3Len_
        	const = @aConstraints[_iLoopConstraints3_]
            if const[:scenario] = "all" or const[:scenario] = scenario[:name]
                cModifiedExpression = This.applyScenarioParameters(const[:expression], scenario[:parameters])
                nModifiedValue = This.evaluateConstraintValue(const[:value], scenario)  # Enhanced to handle string values
                nCoeff = This.extractCoefficient(cModifiedExpression, cVarName)
                if nCoeff != 0
                    nUsedResources = 0
                    _aThisvariableNames2_ = This.variableNames()
                    _nThisvariableNames2Len_ = ring_len(_aThisvariableNames2_)
                    for _iLoopThisvariableNames2_ = 1 to _nThisvariableNames2Len_
                    	var = _aThisvariableNames2_[_iLoopThisvariableNames2_]
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
        
        _nScenarios4Len_ = ring_len(@aScenarios)
        for _iLoopScenarios4_ = 1 to _nScenarios4Len_
        	scenario = @aScenarios[_iLoopScenarios4_]
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
        _nVariablesLen_ = ring_len(@aVariables)
        for i = 1 to _nVariablesLen_
            aSolution + [aVarNames[i], @aVariables[i][:lowerBound]]
        next
        
        # Solve using this scenario's parameters
        cScenarioObjective = This.applyScenarioParameters(@cObjective, scenario[:parameters])
        aCoeffs = This.parseObjectiveCoefficients(cScenarioObjective)
        
        # Simple greedy assignment
        _nVarNamesLen_ = ring_len(aVarNames)
        for i = 1 to _nVarNamesLen_
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
        _nVariables2Len_ = ring_len(@aVariables)
        for _iLoopVariables2_ = 1 to _nVariables2Len_
        	var = @aVariables[_iLoopVariables2_]
            nValue = This.getSolutionValue(aSolution, var[:name])
            nCoeff = This.extractCoefficient(cScenarioObjective, var[:name])
            nResult += nCoeff * nValue
        next
        return nResult

    def getSolutionValue(aSolution, cVarName)
        _nSolution3Len_ = ring_len(aSolution)
        for _iLoopSolution3_ = 1 to _nSolution3Len_
        	sol = aSolution[_iLoopSolution3_]
            if sol[1] = cVarName return sol[2] ok
        next
        return 0

    # Analysis Methods
    def analyzeScenarios()
        if ring_len(@aSolution) = 0 stzRaise("No solution available! Call solve() first.") ok
        
        aScenarioResults = []
        _nScenarios3Len_ = ring_len(@aScenarios)
        for _iLoopScenarios3_ = 1 to _nScenarios3Len_
        	scenario = @aScenarios[_iLoopScenarios3_]
            nObjectiveValue = This.calculateScenarioObjectiveValue(@aSolution, scenario)
            bFeasible = This.checkScenarioFeasibility(@aSolution, scenario)
            aScenarioResults + [ :scenario = scenario[:name], :probability = scenario[:probability], 
                               :objectiveValue = nObjectiveValue, :feasible = bFeasible ]
        next
        return aScenarioResults

    def checkScenarioFeasibility(aSolution, scenario)
        _nConstraints2Len_ = ring_len(@aConstraints)
        for _iLoopConstraints2_ = 1 to _nConstraints2Len_
        	const = @aConstraints[_iLoopConstraints2_]
            if const[:scenario] = "all" or const[:scenario] = scenario[:name]
                cModifiedExpression = This.applyScenarioParameters(const[:expression], scenario[:parameters])
                nModifiedValue = This.evaluateConstraintValue(const[:value], scenario)  # Enhanced to handle string values
                
                nLHS = 0
                _aThisvariableNames1_ = This.variableNames()
                _nThisvariableNames1Len_ = ring_len(_aThisvariableNames1_)
                for _iLoopThisvariableNames1_ = 1 to _nThisvariableNames1Len_
                	var = _aThisvariableNames1_[_iLoopThisvariableNames1_]
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
        if ring_len(@aSolution) = 0 return 0 ok
        
        nExpectedValue = 0
        _nScenarios2Len_ = ring_len(@aScenarios)
        for _iLoopScenarios2_ = 1 to _nScenarios2Len_
        	scenario = @aScenarios[_iLoopScenarios2_]
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
        _nVariables1Len_ = ring_len(@aVariables)
        for _iLoopVariables1_ = 1 to _nVariables1Len_
        	var = @aVariables[_iLoopVariables1_]
            ? " ─ " + var[:name] + " ∈ [" + var[:lowerBound] + ", " + var[:upperBound] + "] (" + var[:type] + ")"
        next

		? ""
        ? "• Objective:"  
        ? "╰─> " + upper(@cObjectiveType) + " " + @cObjective

		? ""
        ? "• Scenarios:"
        _nScenarios1Len_ = ring_len(@aScenarios)
        for _iLoopScenarios1_ = 1 to _nScenarios1Len_
        	scenario = @aScenarios[_iLoopScenarios1_]
            ? " ─ " + scenario[:name] + ": " + scenario[:description] + " (p=" + scenario[:probability] + ")"
            _aScenarioparameters1_ = scenario[:parameters]
            _nScenarioparameters1Len_ = ring_len(_aScenarioparameters1_)
            for _iLoopScenarioparameters1_ = 1 to _nScenarioparameters1Len_
            	param = _aScenarioparameters1_[_iLoopScenarioparameters1_]
                ? " ╰─> " + param[1] + " = " + param[2]
            next
			? ""
        next

        ? "• Constraints:"
        _nConstraints1Len_ = ring_len(@aConstraints)
        for _iLoopConstraints1_ = 1 to _nConstraints1Len_
        	const = @aConstraints[_iLoopConstraints1_]
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
            _nSolution2Len_ = ring_len(@aSolution)
            for _iLoopSolution2_ = 1 to _nSolution2Len_
            	sol = @aSolution[_iLoopSolution2_]
                ? " ─ " + sol[1] + " = " + sol[2]
            next

			? ""
            ? "• Expected Objective Value: " + This.expectedObjectiveValue()

			? ""
            ? "• Scenario Analysis:"
            aResults = This.analyzeScenarios()
            _nResults2Len_ = ring_len(aResults)
            for _iLoopResults2_ = 1 to _nResults2Len_
            	result = aResults[_iLoopResults2_]
                cFeasible = iff(result[:feasible], "✓", "✗")
                ? " ─ " + result[:scenario] + " (p=" + result[:probability] + "): " + result[:objectiveValue] + " " + cFeasible
            next
        ok

    def exportToCSV(cFileName)
        oFile = new stzFile(cFileName)
        cContent = "Variable,Value" + nl
        _nSolution1Len_ = ring_len(@aSolution)
        for _iLoopSolution1_ = 1 to _nSolution1Len_
        	sol = @aSolution[_iLoopSolution1_]
            cContent += sol[1] + "," + sol[2] + nl
        next
        oFile.write(cContent)

    def exportScenarioAnalysis(cFileName)
        oFile = new stzFile(cFileName)
        cContent = "Scenario,Probability,ObjectiveValue,Feasible" + nl
        
        aResults = This.analyzeScenarios()
        _nResults1Len_ = ring_len(aResults)
        for _iLoopResults1_ = 1 to _nResults1Len_
        	result = aResults[_iLoopResults1_]
            cFeasible = iff(result[:feasible], "Yes", "No")
            cContent += result[:scenario] + "," + result[:probability] + "," + result[:objectiveValue] + "," + cFeasible + nl
        next
        
        oFile.write(cContent)
