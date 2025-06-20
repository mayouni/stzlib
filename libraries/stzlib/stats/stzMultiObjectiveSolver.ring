/*
    stzMultiObjectiveSolver - Multi-Objective Optimization Component for Softanza
    Author: Softanza Team
    Version: 0.9
    Techniques: NSGA-II (Genetic Algorithm), ε-constraint method
*/

class stzMultiObjectiveSolver from stzObject

    @aVariables = []
    @aConstraints = []
    @aObjectives = []
    @aParetoSolutions = []
    @cStatus = ""
    @nIterations = 0
    @nSolveTime = 0
    @nPopulationSize = 50
    @nGenerations = 100
    @nMutationRate = 0.1
    @nCrossoverRate = 0.9

    def init()
        This.clear()

    def clear()
        @aVariables = []
        @aConstraints = []
        @aObjectives = []
        @aParetoSolutions = []
        @cStatus = ""
        @nIterations = 0
        @nSolveTime = 0

    # Variables Management (inherited from stzLinearSolver)
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
        nVarLen = len(@aVariables)
        for i = 1 to nVarLen
            aNames + @aVariables[i][:name]
        next
        return aNames

    # Constraints Management (inherited from stzLinearSolver)
    def addConstraint(expression, operator, value)
        if NOT isString(expression) stzRaise("Expression must be a string!") ok
        if NOT (operator = "<=" or operator = ">=" or operator = "=") stzRaise("Operator must be '<=', '>=', or '='!") ok
        if NOT isNumber(value) stzRaise("Value must be a number!") ok

        @aConstraints + [ :expression = expression, :operator = operator, :value = value ]
        return this

    def constraints()
        return @aConstraints

    # Multi-Objective Functions
    def addObjective(expression, type)
        if NOT isString(expression) stzRaise("Expression must be a string!") ok
        if NOT (type = "maximize" or type = "minimize") stzRaise("Type must be 'maximize' or 'minimize'!") ok

        @aObjectives + [ :expression = expression, :type = type ]
        return this

    def maximize(expression)
        This.addObjective(expression, "maximize")
        return this

    def minimize(expression)
        This.addObjective(expression, "minimize")
        return this

    def objectives()
        return @aObjectives

    # Algorithm Parameters
    def setNSGAParameters(populationSize, generations, mutationRate, crossoverRate)
        @nPopulationSize = populationSize
        @nGenerations = generations
        @nMutationRate = mutationRate
        @nCrossoverRate = crossoverRate
        return this

    # Solving Methods
    def solve(cMethod)
        if isNull(cMethod) or cMethod = "" cMethod = "nsga_ii" ok
        nStartTime = clock()
        
        if len(@aVariables) = 0 stzRaise("No variables defined!") ok
        if len(@aObjectives) = 0 stzRaise("No objectives defined!") ok
        if len(@aObjectives) = 1 stzRaise("Use stzLinearSolver for single objective problems!") ok

        switch cMethod
        on "nsga_ii"
            @aParetoSolutions = This.solveWithNSGAII()
        on "epsilon_constraint"
            @aParetoSolutions = This.solveWithEpsilonConstraint()
        other
            stzRaise("Unknown method: " + cMethod + ". Use 'nsga_ii' or 'epsilon_constraint'!")
        off

        @nSolveTime = (clock() - nStartTime) / clockspersecond()
        @cStatus = "optimal"
        return this

/*
    def solveWithNSGAII()
        @nIterations = @nGenerations
        aPopulation = This.initializePopulation()
        
        for gen = 1 to @nGenerations
            # Evaluate objectives for all individuals
            nPopLen = len(aPopulation)
            for i = 1 to nPopLen
                if len(aPopulation[i][:solution]) > 0
                    aPopulation[i][:objectives] = This.evaluateObjectives(aPopulation[i][:solution])
                ok
            next
            
            # Non-dominated sorting and crowding distance
            aFronts = This.nonDominatedSort(aPopulation)
            aPopulation = This.calculateCrowdingDistance(aFronts, aPopulation)
            
            # Create new population
            aNewPopulation = This.createNewPopulation(aPopulation)
            aPopulation = aNewPopulation
        next
        
        # Extract Pareto front
        aParetoFront = []
        nPopLen = len(aPopulation)
        for i = 1 to nPopLen
            if len(aPopulation[i]) > 0 and aPopulation[i][:rank] = 1
                aParetoFront + aPopulation[i]
            ok
        next
        
        return aParetoFront
*/

	def solveWithNSGAII()
	    @nIterations = @nGenerations
	    aPopulation = This.initializePopulation()
	    
	    # CRITICAL FIX: Evaluate initial population objectives
	    nPopLen = len(aPopulation)
	    for i = 1 to nPopLen
	        if len(aPopulation[i][:solution]) > 0
	            aPopulation[i][:objectives] = This.evaluateObjectives(aPopulation[i][:solution])
	        else
	            # Generate new solution if invalid
	            aPopulation[i][:solution] = This.generateRandomSolution()
	            aPopulation[i][:objectives] = This.evaluateObjectives(aPopulation[i][:solution])
	        ok
	    next
	    
	    for gen = 1 to @nGenerations
	        # Evaluate objectives for all individuals (in case of new ones)
	        nPopLen = len(aPopulation)
	        for i = 1 to nPopLen
	            if len(aPopulation[i][:solution]) > 0 and len(aPopulation[i][:objectives]) = 0
	                aPopulation[i][:objectives] = This.evaluateObjectives(aPopulation[i][:solution])
	            ok
	        next
	        
	        # Non-dominated sorting and crowding distance
	        aFronts = This.nonDominatedSort(aPopulation)
	        aPopulation = This.calculateCrowdingDistance(aFronts, aPopulation)
	        
	        # Create new population
	        aNewPopulation = This.createNewPopulation(aPopulation)
	        aPopulation = aNewPopulation
	    next
	    
	    # Extract Pareto front - only include valid solutions
	    aParetoFront = []
	    nPopLen = len(aPopulation)
	    for i = 1 to nPopLen
	        if len(aPopulation[i]) > 0 and len(aPopulation[i][:solution]) > 0 and 
	           len(aPopulation[i][:objectives]) > 0 and aPopulation[i][:rank] = 1
	            aParetoFront + aPopulation[i]
	        ok
	    next
	    
	    return aParetoFront


    def solveWithEpsilonConstraint()
        @nIterations = len(@aObjectives) * 10
        aParetoSolutions = []
        
        # Use first objective as primary, others as constraints
        oPrimarySolver = new stzLinearSolver()
        
        # Copy variables and constraints
        nVarLen = len(@aVariables)
        for i = 1 to nVarLen
            var = @aVariables[i]
            oPrimarySolver.addVariable(var[:name], var[:lowerBound], var[:upperBound])
        next
        nConstLen = len(@aConstraints)
        for i = 1 to nConstLen
            const = @aConstraints[i]
            oPrimarySolver.addConstraint(const[:expression], const[:operator], const[:value])
        next
        
        # Set primary objective
        oPrimaryObj = @aObjectives[1]
        if oPrimaryObj[:type] = "maximize"
            oPrimarySolver.maximize(oPrimaryObj[:expression])
        else
            oPrimarySolver.minimize(oPrimaryObj[:expression])
        ok
        
        # Generate epsilon values for other objectives
        aEpsilonRanges = This.calculateEpsilonRanges()
        
        nEpsilonLen = len(aEpsilonRanges)
        for i = 1 to nEpsilonLen
            epsilonSet = aEpsilonRanges[i]
            oTempSolver = new stzLinearSolver()
            
            # Copy variables and constraints
            for j = 1 to nVarLen
                var = @aVariables[j]
                oTempSolver.addVariable(var[:name], var[:lowerBound], var[:upperBound])
            next
            for j = 1 to nConstLen
                const = @aConstraints[j]
                oTempSolver.addConstraint(const[:expression], const[:operator], const[:value])
            next
            
            # Add epsilon constraints for secondary objectives
            nObjLen = len(@aObjectives)
            for j = 2 to nObjLen
                cOperator = iff(@aObjectives[j][:type] = "maximize", ">=", "<=")
                oTempSolver.addConstraint(@aObjectives[j][:expression], cOperator, epsilonSet[j-1])
            next
            
            # Set primary objective
            if oPrimaryObj[:type] = "maximize"
                oTempSolver.maximize(oPrimaryObj[:expression])
            else
                oTempSolver.minimize(oPrimaryObj[:expression])
            ok
            
            oTempSolver.solve("greedy") # Shoud it be greedy?
            if oTempSolver.status() = "optimal"
                aSolution = oTempSolver.solution()
                aObjectiveValues = This.evaluateObjectives(aSolution)
                aParetoSolutions + [ :solution = aSolution, :objectives = aObjectiveValues, :rank = 1 ]
            ok
        next
        
        return aParetoSolutions

    # NSGA-II Helper Methods
    def initializePopulation()
        aPopulation = []
        for i = 1 to @nPopulationSize
            aSolution = This.generateRandomSolution()
            aPopulation + [ :solution = aSolution, :objectives = [], :rank = 0, :crowdingDistance = 0 ]
        next
        return aPopulation

/*
    def generateRandomSolution()
        aSolution = []
        nVarLen = len(@aVariables)
        for i = 1 to nVarLen
            var = @aVariables[i]
            nValue = var[:lowerBound] + random(var[:upperBound] - var[:lowerBound] + 1)
            if var[:type] = "integer" or var[:type] = "binary"
                nValue = floor(nValue)
            ok
            aSolution + [var[:name], nValue]
        next
        return aSolution
*/

	def generateRandomSolution()
	    aSolution = []
	    nVarLen = len(@aVariables)
	    for i = 1 to nVarLen
	        var = @aVariables[i]
	        
	        # FIXED: Correct random number generation
	        nRange = var[:upperBound] - var[:lowerBound]
	        nValue = var[:lowerBound] + random(nRange * 100) / 100.0
	        
	        if var[:type] = "integer" or var[:type] = "binary"
	            nValue = floor(nValue)
	        ok
	        
	        # Ensure within bounds
	        if nValue < var[:lowerBound] nValue = var[:lowerBound] ok
	        if nValue > var[:upperBound] nValue = var[:upperBound] ok
	        
	        aSolution + [var[:name], nValue]
	    next
	    return aSolution
	

    def evaluateObjectives(aSolution)
        aObjectiveValues = []
        nObjLen = len(@aObjectives)
        for i = 1 to nObjLen
            obj = @aObjectives[i]
            nValue = This.calculateObjectiveValue(obj[:expression], aSolution)
            if obj[:type] = "maximize" nValue = -nValue ok  # Convert to minimization
            aObjectiveValues + nValue
        next
        return aObjectiveValues

    def calculateObjectiveValue(cExpression, aSolution)
        nResult = 0
        nVarLen = len(@aVariables)
        for i = 1 to nVarLen
            var = @aVariables[i]
            nValue = This.getSolutionValue(aSolution, var[:name])
            nCoeff = This.extractCoefficient(cExpression, var[:name])
            nResult += nCoeff * nValue
        next
        return nResult

    def nonDominatedSort(aPopulation)
        aFronts = []
        nPopLen = len(aPopulation)
        
        for i = 1 to nPopLen
            aPopulation[i][:dominatedSolutions] = []
            aPopulation[i][:dominationCount] = 0
        next
        
        aFirstFront = []
        for i = 1 to nPopLen
            for j = 1 to nPopLen
                if i != j
                    if This.dominates(aPopulation[i], aPopulation[j])
                        aPopulation[i][:dominatedSolutions] + j
                    elseif This.dominates(aPopulation[j], aPopulation[i])
                        aPopulation[i][:dominationCount]++
                    ok
                ok
            next
            if aPopulation[i][:dominationCount] = 0
                aPopulation[i][:rank] = 1
                aFirstFront + i
            ok
        next
        
        aFronts + aFirstFront
        nCurrentFront = 1
        
        while len(aFronts[nCurrentFront]) > 0
            aNextFront = []
            nCurrentFrontLen = len(aFronts[nCurrentFront])
            for i = 1 to nCurrentFrontLen
                p = aFronts[nCurrentFront][i]
                nDominatedLen = len(aPopulation[p][:dominatedSolutions])
                for j = 1 to nDominatedLen
                    q = aPopulation[p][:dominatedSolutions][j]
                    aPopulation[q][:dominationCount]--
                    if aPopulation[q][:dominationCount] = 0
                        aPopulation[q][:rank] = nCurrentFront + 1
                        aNextFront + q
                    ok
                next
            next
            nCurrentFront++
            aFronts + aNextFront
        end
        
        return aFronts

    def dominates(individual1, individual2)
        bAtLeastOneBetter = false
        nObjLen = len(individual1[:objectives])
        for i = 1 to nObjLen
            if individual1[:objectives][i] > individual2[:objectives][i]
                return false
            elseif individual1[:objectives][i] < individual2[:objectives][i]
                bAtLeastOneBetter = true
            ok
        next
        return bAtLeastOneBetter

    def calculateCrowdingDistance(aFronts, aPopulation)
        nFrontsLen = len(aFronts)
        nObjLen = len(@aObjectives)
        
        for i = 1 to nFrontsLen
            front = aFronts[i]
            nFrontLen = len(front)
            
            if nFrontLen > 0
                # Initialize crowding distance to 0
                for j = 1 to nFrontLen
                    nIndex = front[j]
                    if nIndex > 0 and nIndex <= len(aPopulation)
                        aPopulation[nIndex][:crowdingDistance] = 0
                    ok
                next
                
                # Calculate crowding distance for each objective
                for obj = 1 to nObjLen
                    # Sort front by current objective
                    front = This.sortFrontByObjective(front, obj, aPopulation)
                    
                    if nFrontLen >= 2
                        # Set boundary solutions to infinite distance
                        nFirstIndex = front[1]
                        nLastIndex = front[nFrontLen]
                        if nFirstIndex > 0 and nFirstIndex <= len(aPopulation)
                            aPopulation[nFirstIndex][:crowdingDistance] = 999999
                        ok
                        if nLastIndex > 0 and nLastIndex <= len(aPopulation)
                            aPopulation[nLastIndex][:crowdingDistance] = 999999
                        ok
                        
                        # Calculate distance for intermediate solutions
                        for j = 2 to nFrontLen-1
                            nCurrentIndex = front[j]
                            nPrevIndex = front[j-1]
                            nNextIndex = front[j+1]
                            
                            if nCurrentIndex > 0 and nCurrentIndex <= len(aPopulation) and
                               nPrevIndex > 0 and nPrevIndex <= len(aPopulation) and
                               nNextIndex > 0 and nNextIndex <= len(aPopulation)
                                
                                nDistance = aPopulation[nNextIndex][:objectives][obj] - aPopulation[nPrevIndex][:objectives][obj]
                                aPopulation[nCurrentIndex][:crowdingDistance] += nDistance
                            ok
                        next
                    ok
                next
            ok
        next
        
        return aPopulation

    def sortFrontByObjective(front, objIndex, aPopulation)
        # Simple bubble sort by objective value
        nFrontLen = len(front)
        for i = 1 to nFrontLen-1
            for j = 1 to nFrontLen-i
                nIndex1 = front[j]
                nIndex2 = front[j+1]
                if nIndex1 > 0 and nIndex1 <= len(aPopulation) and
                   nIndex2 > 0 and nIndex2 <= len(aPopulation)
                    if aPopulation[nIndex1][:objectives][objIndex] > aPopulation[nIndex2][:objectives][objIndex]
                        # Swap
                        temp = front[j]
                        front[j] = front[j+1]
                        front[j+1] = temp
                    ok
                ok
            next
        next
        return front

/*
    def createNewPopulation(aPopulation)
        aNewPopulation = []
        nPopLen = len(aPopulation)
        
        if nPopLen = 0
            # If population is empty, reinitialize
            return This.initializePopulation()
        ok
        
        for i = 1 to @nPopulationSize
            parent1 = This.tournamentSelection(aPopulation)
            parent2 = This.tournamentSelection(aPopulation)
            
            # Check if parents are valid
            if len(parent1) = 0 or len(parent2) = 0
                # Generate random individual if parents are invalid
                aSolution = This.generateRandomSolution()
                child = [ :solution = aSolution, :objectives = [], :rank = 0, :crowdingDistance = 0 ]
            else
                child = This.crossover(parent1, parent2)
                child = This.mutate(child)
            ok
            
            aNewPopulation + child
        next
        return aNewPopulation
*/

	def createNewPopulation(aPopulation)
	    aNewPopulation = []
	    nPopLen = len(aPopulation)
	    
	    # Count valid individuals
	    nValidIndividuals = 0
	    for i = 1 to nPopLen
	        if len(aPopulation[i]) > 0 and len(aPopulation[i][:solution]) > 0 and 
	           len(aPopulation[i][:objectives]) > 0
	            nValidIndividuals++
	        ok
	    next
	    
	    # If too few valid individuals, reinitialize
	    if nValidIndividuals < 2
	        ? "Warning: Population has too few valid individuals, reinitializing..."
	        return This.initializePopulation()
	    ok
	    
	    # Generate new population
	    for i = 1 to @nPopulationSize
	        parent1 = This.tournamentSelection(aPopulation)
	        parent2 = This.tournamentSelection(aPopulation)
	        
	        # Check if parents are valid
	        if len(parent1) = 0 or len(parent2) = 0 or 
	           len(parent1[:solution]) = 0 or len(parent2[:solution]) = 0
	            # Generate random individual if parents are invalid
	            aSolution = This.generateRandomSolution()
	            child = [ :solution = aSolution, :objectives = [], :rank = 0, :crowdingDistance = 0 ]
	        else
	            child = This.crossover(parent1, parent2)
	            child = This.mutate(child)
	        ok
	        
	        # Ensure child has valid solution structure
	        if len(child[:solution]) = 0
	            child[:solution] = This.generateRandomSolution()
	        ok
	        
	        aNewPopulation + child
	    next
	    
	    return aNewPopulation

/*
    def tournamentSelection(aPopulation)
        nPopLen = len(aPopulation)
        if nPopLen = 0 return [] ok
        
        nIndex1 = random(nPopLen-1) + 1
        nIndex2 = random(nPopLen-1) + 1
        
        # Ensure indices are within bounds
        if nIndex1 < 1 nIndex1 = 1 ok
        if nIndex1 > nPopLen nIndex1 = nPopLen ok
        if nIndex2 < 1 nIndex2 = 1 ok
        if nIndex2 > nPopLen nIndex2 = nPopLen ok
        
        individual1 = aPopulation[nIndex1]
        individual2 = aPopulation[nIndex2]
        
        if individual1[:rank] < individual2[:rank]
            return individual1
        elseif individual1[:rank] > individual2[:rank]
            return individual2
        else
            if individual1[:crowdingDistance] > individual2[:crowdingDistance]
                return individual1
            else
                return individual2
            ok
        ok
*/

	def tournamentSelection(aPopulation)
	    nPopLen = len(aPopulation)
	    if nPopLen = 0 return [] ok
	    
	    # Find valid individuals first
	    aValidIndices = []
	    for i = 1 to nPopLen
	        if len(aPopulation[i]) > 0 and len(aPopulation[i][:solution]) > 0 and 
	           len(aPopulation[i][:objectives]) > 0
	            aValidIndices + i
	        ok
	    next
	    
	    if len(aValidIndices) < 2
	        return []  # Not enough valid individuals
	    ok
	    
	    # Select two random valid individuals
	    nIdx1 = random(len(aValidIndices)-1) + 1
	    nIdx2 = random(len(aValidIndices)-1) + 1
	    
	    # Ensure different individuals
	    while nIdx1 = nIdx2 and len(aValidIndices) > 1
	        nIdx2 = random(len(aValidIndices)-1) + 1
	    end
	    
	    individual1 = aPopulation[aValidIndices[nIdx1]]
	    individual2 = aPopulation[aValidIndices[nIdx2]]
	    
	    # Tournament selection based on rank and crowding distance
	    if individual1[:rank] < individual2[:rank]
	        return individual1
	    elseif individual1[:rank] > individual2[:rank]
	        return individual2
	    else
	        # Same rank, choose based on crowding distance (higher is better)
	        if individual1[:crowdingDistance] > individual2[:crowdingDistance]
	            return individual1
	        else
	            return individual2
	        ok
	    ok

    def crossover(parent1, parent2)
        aSolution = []
        
        # Check if parents have valid solutions
        if len(parent1[:solution]) = 0 or len(parent2[:solution]) = 0
            return [ :solution = This.generateRandomSolution(), :objectives = [], :rank = 0, :crowdingDistance = 0 ]
        ok
        
        nSolLen = len(parent1[:solution])
        for i = 1 to nSolLen
            if random(100) < @nCrossoverRate * 100
                aSolution + parent1[:solution][i]
            else
                aSolution + parent2[:solution][i]
            ok
        next
        return [ :solution = aSolution, :objectives = [], :rank = 0, :crowdingDistance = 0 ]

    def mutate(individual)
        nSolLen = len(individual[:solution])
        for i = 1 to nSolLen
            if random(100) < @nMutationRate * 100
                if i <= len(@aVariables)
                    var = @aVariables[i]
                    nNewValue = var[:lowerBound] + random(var[:upperBound] - var[:lowerBound])
                    if var[:type] = "integer" or var[:type] = "binary"
                        nNewValue = floor(nNewValue)
                    ok
                    individual[:solution][i][2] = nNewValue
                ok
            ok
        next
        return individual

    # Epsilon Constraint Helper Methods
    def calculateEpsilonRanges()
        aRanges = []
        nSteps = 10
        nObjLen = len(@aObjectives)
        
        for i = 2 to nObjLen
            # Calculate min and max for each secondary objective
            nMin = This.calculateObjectiveBound(@aObjectives[i][:expression], "min")
            nMax = This.calculateObjectiveBound(@aObjectives[i][:expression], "max")
            nStep = (nMax - nMin) / nSteps
            
            aEpsilonValues = []
            for j = 0 to nSteps
                aEpsilonValues + (nMin + j * nStep)
            next
            aRanges + aEpsilonValues
        next
        
        # Generate combinations
        aEpsilonSets = []
        if len(aRanges) = 1
            nRange1Len = len(aRanges[1])
            for i = 1 to nRange1Len
                aEpsilonSets + [aRanges[1][i]]
            next
        else
            nRange1Len = len(aRanges[1])
            nRange2Len = len(aRanges[2])
            for i = 1 to nRange1Len
                for j = 1 to nRange2Len
                    aEpsilonSets + [aRanges[1][i], aRanges[2][j]]
                next
            next
        ok
        
        return aEpsilonSets

    def calculateObjectiveBound(cExpression, cType)
        # Simple bound estimation based on variable bounds
        nBound = 0
        nVarLen = len(@aVariables)
        for i = 1 to nVarLen
            var = @aVariables[i]
            nCoeff = This.extractCoefficient(cExpression, var[:name])
            if cType = "min"
                nBound += nCoeff * iff(nCoeff > 0, var[:lowerBound], var[:upperBound])
            else
                nBound += nCoeff * iff(nCoeff > 0, var[:upperBound], var[:lowerBound])
            ok
        next
        return nBound

    # Utility Methods (inherited from stzLinearSolver)

/*
    def extractCoefficient(cExpression, cVarName)
        if ring_substr1(cExpression, cVarName) = 0 return 0 ok
        cExpr = trim(cExpression)
        acSplits = split(cExpr, "+")
        nSplitsLen = len(acSplits)
        for i = 1 to nSplitsLen
            split = acSplits[i]
            if ring_substr1(split, "*") and ring_substr1(split, cVarName)
                n = ring_substr1(split, "*")
                cCoeff = StzStringQ(split).Section(1, n-1)
                return 0+ cCoeff
            ok
        next
        return 1
*/

	def extractCoefficient(cExpression, cVarName)
	    if ring_substr1(cExpression, cVarName) = 0 return 0 ok
	    
	    cExpr = trim(cExpression)
	    
	    # Handle simple cases first
	    if cExpr = cVarName return 1 ok
	    if cExpr = "-" + cVarName return -1 ok
	    
	    # Replace - with +- to split negative terms
	    cExpr = substr(cExpr, " ", "")  # Remove spaces
	    cExpr = substr(cExpr, "-", "+-")
	    acSplits = split(cExpr, "+")
	    
	    nSplitsLen = len(acSplits)
	    for i = 1 to nSplitsLen
	        split = trim(acSplits[i])
	        if split = "" loop ok
	        
	        if ring_substr1(split, cVarName)
	            if ring_substr1(split, "*")
	                # Extract coefficient before *
	                n = ring_substr1(split, "*")
	                cCoeff = trim(substr(split, 1, n-1))
	                if cCoeff = "" or cCoeff = "+" return 1 ok
	                if cCoeff = "-" return -1 ok
	                return 0 + cCoeff
	            else
	                # Variable appears without * (coefficient is 1 or -1)
	                if left(split, 1) = "-" return -1 ok
	                return 1
	            ok
	        ok
	    next
	    return 0

    def getSolutionValue(aSolution, cVarName)
        nSolLen = len(aSolution)
        for i = 1 to nSolLen
            if aSolution[i][1] = cVarName return aSolution[i][2] ok
        next
        return 0

    # Solution Access
    def paretoSolutions()
        return @aParetoSolutions

    def bestCompromiseSolution()
        if len(@aParetoSolutions) = 0 return [] ok
        
        # Find solution with minimum sum of normalized objectives
        nBestScore = 999999
        aBestSolution = []
        nParetoLen = len(@aParetoSolutions)
        
        for i = 1 to nParetoLen
            solution = @aParetoSolutions[i]
            nScore = 0
            nObjLen = len(solution[:objectives])
            for j = 1 to nObjLen
                nScore += abs(solution[:objectives][j])
            next
            if nScore < nBestScore
                nBestScore = nScore
                aBestSolution = solution
            ok
        next
        
        return aBestSolution

    def status()
        return @cStatus

    def iterations()
        return @nIterations

    def solveTime()
        return @nSolveTime

    # Display and Reporting
    def show()
        ? BoxRound("Multi-Objective Problem")

		? ""
        ? "• Variables:"
        nVarLen = len(@aVariables)
        for i = 1 to nVarLen
            var = @aVariables[i]
            ? " ─ " + var[:name] + " ∈ [" + var[:lowerBound] + ", " + var[:upperBound] + "] (" + var[:type] + ")"
        next

		? ""
        ? "• Constraints:"
        nConstLen = len(@aConstraints)
        for i = 1 to nConstLen
            const = @aConstraints[i]
            ? " ─ " + const[:expression] + " " + const[:operator] + " " + const[:value]
        next

		? ""
        ? "• Objectives:"
        nObjLen = len(@aObjectives)
        for i = 1 to nObjLen
            obj = @aObjectives[i]
            ? " ─ " + upper(obj[:type]) + " " + obj[:expression]
        next
        
        if @cStatus != ""
			? ""
            ? BoxRound("Solutions")
            ? "• Status: " + @cStatus
            ? "• Solved in " + @nSolveTime + " second(s)"
            ? "• Iterations: " + @nIterations
			? ""
            ? "• Pareto Solutions Found: " + len(@aParetoSolutions)
            
            oBest = This.bestCompromiseSolution()
            if len(oBest) > 0
				 ? "• Best Compromise Solution:"
                nSolLen = len(oBest[:solution])
                for i = 1 to nSolLen
                    sol = oBest[:solution][i]
                    ? " ─ " + sol[1] + " = " + sol[2]
                next

				? ""
                ? "• Objective Values:"
                nObjLen = len(oBest[:objectives])
                for i = 1 to nObjLen
                    nValue = oBest[:objectives][i]
                    if @aObjectives[i][:type] = "maximize" nValue = -nValue ok
                    ? " ─ " + @aObjectives[i][:expression] + " = " + nValue
                next
            ok
        ok

    def exportParetoFrontCSV(cFileName)
        oFile = new stzFile(cFileName)
        cContent = "Solution,"
        
        # Headers for variables
        nVarLen = len(@aVariables)
        for i = 1 to nVarLen
            cContent += @aVariables[i][:name] + ","
        next
        
        # Headers for objectives
        nObjLen = len(@aObjectives)
        for i = 1 to nObjLen
            cContent += @aObjectives[i][:expression] + ","
        next
        cContent += nl
        
        # Data rows
        nParetoLen = len(@aParetoSolutions)
        for i = 1 to nParetoLen
            cContent += "Sol" + i + ","
            
            # Variable values
            nSolLen = len(@aParetoSolutions[i][:solution])
            for j = 1 to nSolLen
                cContent += @aParetoSolutions[i][:solution][j][2] + ","
            next
            
            # Objective values
            nObjLen = len(@aParetoSolutions[i][:objectives])
            for j = 1 to nObjLen
                nValue = @aParetoSolutions[i][:objectives][j]
                if @aObjectives[j][:type] = "maximize" nValue = -nValue ok
                cContent += nValue + ","
            next
            cContent += nl
        next
        
        oFile.write(cContent)
