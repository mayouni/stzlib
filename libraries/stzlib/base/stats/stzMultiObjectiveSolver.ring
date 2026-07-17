
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

	@oCoeffExtractor

    def init()
        This.clear()
		@oCoeffExtractor = new stzCoeffExtractor(This.VariableNames())

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

    def Variables()
        return @aVariables

		def Vars()
			return @aVariables


    def VariableNames()
        _aNames_ = []
        _nVarLen_ = len(@aVariables)
        for i = 1 to _nVarLen_
            _aNames_ + @aVariables[i][:name]
        next
        return _aNames_

		def VarNames()
			return This.VariableNames()

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
        _nStartTime_ = clock()
        
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

        @nSolveTime = (clock() - _nStartTime_) / clockspersecond()
        @cStatus = "optimal"
        return this


	def solveWithNSGAII()
	    # REFUSE constraints rather than ignore them. This genetic path samples
	    # solutions across the full variable bounds and never tests feasibility
	    # -- so a constraint like x <= 5 was SILENTLY DROPPED and the front came
	    # back full of solutions that violate it. Constrained NSGA-II is real work
	    # and a real feature; until it exists, an honest raise beats a wrong answer.
	    # The epsilon-constraint method DOES handle bounds via stzLinearSolver.
	    if len(@aConstraints) > 0
	        stzRaise("NSGA-II here does not enforce constraints yet -- use solve(:epsilon_constraint) for constrained problems, or drop the constraints.")
	    ok

	    @nIterations = @nGenerations
	    _aPopulation_ = This.initializePopulation()
	    
	    # CRITICAL FIX: Evaluate initial population objectives
	    _nPopLen_ = len(_aPopulation_)
	    for i = 1 to _nPopLen_
	        if len(_aPopulation_[i][:solution]) > 0
	            _aPopulation_[i][:objectives] = This.evaluateObjectives(_aPopulation_[i][:solution])
	        else
	            # Generate new solution if invalid
	            _aPopulation_[i][:solution] = This.generateRandomSolution()
	            _aPopulation_[i][:objectives] = This.evaluateObjectives(_aPopulation_[i][:solution])
	        ok
	    next
	    
	    for gen = 1 to @nGenerations
	        # Evaluate objectives for all individuals (in case of new ones)
	        _nPopLen_ = len(_aPopulation_)
	        for i = 1 to _nPopLen_
	            if len(_aPopulation_[i][:solution]) > 0 and len(_aPopulation_[i][:objectives]) = 0
	                _aPopulation_[i][:objectives] = This.evaluateObjectives(_aPopulation_[i][:solution])
	            ok
	        next
	        
	        # Non-dominated sorting and crowding distance
	        _aFronts_ = This.nonDominatedSort(_aPopulation_)
	        _aPopulation_ = This.calculateCrowdingDistance(_aFronts_, _aPopulation_)
	        
	        # Create new population
	        _aNewPopulation_ = This.createNewPopulation(_aPopulation_)
	        _aPopulation_ = _aNewPopulation_
	    next

	    # RANK THE FINAL POPULATION before reading the front off it. The
	    # generation loop ends on createNewPopulation(), which builds every child
	    # with :rank = 0 and never re-ranks -- so the population handed to the
	    # extractor was ALWAYS all-rank-0, the `:rank = 1` filter matched nothing,
	    # and solve() returned an EMPTY front while reporting status "optimal": a
	    # wrong answer that never raised. Sort once more so rank 1 means what the
	    # filter expects (and evaluate any fresh child that carries no objectives).
	    _nPopLen_ = len(_aPopulation_)
	    for i = 1 to _nPopLen_
	        if len(_aPopulation_[i][:solution]) > 0 and len(_aPopulation_[i][:objectives]) = 0
	            _aPopulation_[i][:objectives] = This.evaluateObjectives(_aPopulation_[i][:solution])
	        ok
	    next
	    _aFinalFronts_ = This.nonDominatedSort(_aPopulation_)
	    _aPopulation_ = This.calculateCrowdingDistance(_aFinalFronts_, _aPopulation_)

	    # Extract Pareto front - only include valid solutions
	    _aParetoFront_ = []
	    _nPopLen_ = len(_aPopulation_)
	    for i = 1 to _nPopLen_
	        if len(_aPopulation_[i]) > 0 and len(_aPopulation_[i][:solution]) > 0 and 
	           len(_aPopulation_[i][:objectives]) > 0 and _aPopulation_[i][:rank] = 1
	            _aParetoFront_ + _aPopulation_[i]
	        ok
	    next
	    
	    return _aParetoFront_


    def solveWithEpsilonConstraint()
        @nIterations = len(@aObjectives) * 10
        _aParetoSolutions_ = []
        
        # Use first objective as primary, others as constraints
        _oPrimarySolver_ = new stzLinearSolver()
        
        # Copy variables and constraints
        _nVarLen_ = len(@aVariables)
        for i = 1 to _nVarLen_
            _var_ = @aVariables[i]
            _oPrimarySolver_.addVariable(_var_[:name], _var_[:lowerBound], _var_[:upperBound])
        next
        _nConstLen_ = len(@aConstraints)
        for i = 1 to _nConstLen_
            _const_ = @aConstraints[i]
            _oPrimarySolver_.addConstraint(_const_[:expression], _const_[:operator], _const_[:value])
        next
        
        # Set primary objective
        _oPrimaryObj_ = @aObjectives[1]
        if _oPrimaryObj_[:type] = "maximize"
            _oPrimarySolver_.maximize(_oPrimaryObj_[:expression])
        else
            _oPrimarySolver_.minimize(_oPrimaryObj_[:expression])
        ok
        
        # Generate epsilon values for other objectives
        _aEpsilonRanges_ = This.calculateEpsilonRanges()
        
        _nEpsilonLen_ = len(_aEpsilonRanges_)
        for i = 1 to _nEpsilonLen_
            _epsilonSet_ = _aEpsilonRanges_[i]
            _oTempSolver_ = new stzLinearSolver()
            
            # Copy variables and constraints
            for j = 1 to _nVarLen_
                _var_ = @aVariables[j]
                _oTempSolver_.addVariable(_var_[:name], _var_[:lowerBound], _var_[:upperBound])
            next
            for j = 1 to _nConstLen_
                _const_ = @aConstraints[j]
                _oTempSolver_.addConstraint(_const_[:expression], _const_[:operator], _const_[:value])
            next
            
            # Add epsilon constraints for secondary objectives
            _nObjLen_ = len(@aObjectives)
            for j = 2 to _nObjLen_
                _cOperator_ = iff(@aObjectives[j][:type] = "maximize", ">=", "<=")
                _oTempSolver_.addConstraint(@aObjectives[j][:expression], _cOperator_, _epsilonSet_[j-1])
            next
            
            # Set primary objective
            if _oPrimaryObj_[:type] = "maximize"
                _oTempSolver_.maximize(_oPrimaryObj_[:expression])
            else
                _oTempSolver_.minimize(_oPrimaryObj_[:expression])
            ok
            
            _oTempSolver_.solve("greedy") # Shoud it be greedy?
            if _oTempSolver_.status() = "optimal"
                _aSolution_ = _oTempSolver_.solution()
                _aObjectiveValues_ = This.evaluateObjectives(_aSolution_)
                _aParetoSolutions_ + [ :solution = _aSolution_, :objectives = _aObjectiveValues_, :rank = 1 ]
            ok
        next
        
        return _aParetoSolutions_

    # NSGA-II Helper Methods
    def initializePopulation()
        _aPopulation_ = []
        for i = 1 to @nPopulationSize
            _aSolution_ = This.generateRandomSolution()
            _aPopulation_ + [ :solution = _aSolution_, :objectives = [], :rank = 0, :crowdingDistance = 0 ]
        next
        return _aPopulation_

/*
    def generateRandomSolution()
        _aSolution_ = []
        _nVarLen_ = len(@aVariables)
        for i = 1 to _nVarLen_
            _var_ = @aVariables[i]
            _nValue_ = _var_[:lowerBound] + random(_var_[:upperBound] - _var_[:lowerBound] + 1)
            if _var_[:type] = "integer" or _var_[:type] = "binary"
                _nValue_ = floor(_nValue_)
            ok
            _aSolution_ + [_var_[:name], _nValue_]
        next
        return _aSolution_
*/

	def generateRandomSolution()
	    _aSolution_ = []
	    _nVarLen_ = len(@aVariables)
	    for i = 1 to _nVarLen_
	        _var_ = @aVariables[i]
	        
	        # FIXED: Correct random number generation
	        _nRange_ = _var_[:upperBound] - _var_[:lowerBound]
	        _nValue_ = _var_[:lowerBound] + random(_nRange_ * 100) / 100.0
	        
	        if _var_[:type] = "integer" or _var_[:type] = "binary"
	            _nValue_ = floor(_nValue_)
	        ok
	        
	        # Ensure within bounds
	        if _nValue_ < _var_[:lowerBound] _nValue_ = _var_[:lowerBound] ok
	        if _nValue_ > _var_[:upperBound] _nValue_ = _var_[:upperBound] ok
	        
	        _aSolution_ + [_var_[:name], _nValue_]
	    next
	    return _aSolution_
	

    def evaluateObjectives(_aSolution_)
        _aObjectiveValues_ = []
        _nObjLen_ = len(@aObjectives)
        for i = 1 to _nObjLen_
            _obj_ = @aObjectives[i]
            _nValue_ = This.calculateObjectiveValue(_obj_[:expression], _aSolution_)
            if _obj_[:type] = "maximize" _nValue_ = -_nValue_ ok  # Convert to minimization
            _aObjectiveValues_ + _nValue_
        next
        return _aObjectiveValues_

    def calculateObjectiveValue(cExpression, _aSolution_)
        _nResult_ = 0
        _nVarLen_ = len(@aVariables)
        for i = 1 to _nVarLen_
            _var_ = @aVariables[i]
            _nValue_ = This.getSolutionValue(_aSolution_, _var_[:name])
            _nCoeff_ = This.extractCoefficient(cExpression, _var_[:name])
            _nResult_ += _nCoeff_ * _nValue_
        next
        return _nResult_

    def nonDominatedSort(_aPopulation_)
        _aFronts_ = []
        _nPopLen_ = len(_aPopulation_)
        
        for i = 1 to _nPopLen_
            _aPopulation_[i][:dominatedSolutions] = []
            _aPopulation_[i][:dominationCount] = 0
        next
        
        _aFirstFront_ = []
        for i = 1 to _nPopLen_
            for j = 1 to _nPopLen_
                if i != j
                    if This.dominates(_aPopulation_[i], _aPopulation_[j])
                        _aPopulation_[i][:dominatedSolutions] + j
                    elseif This.dominates(_aPopulation_[j], _aPopulation_[i])
                        _aPopulation_[i][:dominationCount]++
                    ok
                ok
            next
            if _aPopulation_[i][:dominationCount] = 0
                _aPopulation_[i][:rank] = 1
                _aFirstFront_ + i
            ok
        next
        
        _aFronts_ + _aFirstFront_
        _nCurrentFront_ = 1
        
        while len(_aFronts_[_nCurrentFront_]) > 0
            _aNextFront_ = []
            _nCurrentFrontLen_ = len(_aFronts_[_nCurrentFront_])
            for i = 1 to _nCurrentFrontLen_
                p = _aFronts_[_nCurrentFront_][i]
                _nDominatedLen_ = len(_aPopulation_[p][:dominatedSolutions])
                for j = 1 to _nDominatedLen_
                    _q_ = _aPopulation_[p][:dominatedSolutions][j]
                    _aPopulation_[_q_][:dominationCount]--
                    if _aPopulation_[_q_][:dominationCount] = 0
                        _aPopulation_[_q_][:rank] = _nCurrentFront_ + 1
                        _aNextFront_ + _q_
                    ok
                next
            next
            _nCurrentFront_++
            _aFronts_ + _aNextFront_
        end
        
        return _aFronts_

    def dominates(_individual1_, _individual2_)
        _bAtLeastOneBetter_ = false
        _nObjLen_ = len(_individual1_[:objectives])
        for i = 1 to _nObjLen_
            if _individual1_[:objectives][i] > _individual2_[:objectives][i]
                return false
            elseif _individual1_[:objectives][i] < _individual2_[:objectives][i]
                _bAtLeastOneBetter_ = true
            ok
        next
        return _bAtLeastOneBetter_

    def calculateCrowdingDistance(_aFronts_, _aPopulation_)
        _nFrontsLen_ = len(_aFronts_)
        _nObjLen_ = len(@aObjectives)
        
        for i = 1 to _nFrontsLen_
            _front_ = _aFronts_[i]
            _nFrontLen_ = len(_front_)
            
            if _nFrontLen_ > 0
                # Initialize crowding distance to 0
                for j = 1 to _nFrontLen_
                    _nIndex_ = _front_[j]
                    if _nIndex_ > 0 and _nIndex_ <= len(_aPopulation_)
                        _aPopulation_[_nIndex_][:crowdingDistance] = 0
                    ok
                next
                
                # Calculate crowding distance for each objective
                for _obj_ = 1 to _nObjLen_
                    # Sort front by current objective
                    _front_ = This.sortFrontByObjective(_front_, _obj_, _aPopulation_)
                    
                    if _nFrontLen_ >= 2
                        # Set boundary solutions to infinite distance
                        _nFirstIndex_ = _front_[1]
                        _nLastIndex_ = _front_[_nFrontLen_]
                        if _nFirstIndex_ > 0 and _nFirstIndex_ <= len(_aPopulation_)
                            _aPopulation_[_nFirstIndex_][:crowdingDistance] = 999999
                        ok
                        if _nLastIndex_ > 0 and _nLastIndex_ <= len(_aPopulation_)
                            _aPopulation_[_nLastIndex_][:crowdingDistance] = 999999
                        ok
                        
                        # Calculate distance for intermediate solutions
                        for j = 2 to _nFrontLen_-1
                            _nCurrentIndex_ = _front_[j]
                            _nPrevIndex_ = _front_[j-1]
                            _nNextIndex_ = _front_[j+1]
                            
                            if _nCurrentIndex_ > 0 and _nCurrentIndex_ <= len(_aPopulation_) and
                               _nPrevIndex_ > 0 and _nPrevIndex_ <= len(_aPopulation_) and
                               _nNextIndex_ > 0 and _nNextIndex_ <= len(_aPopulation_)
                                
                                _nDistance_ = _aPopulation_[_nNextIndex_][:objectives][_obj_] - _aPopulation_[_nPrevIndex_][:objectives][_obj_]
                                _aPopulation_[_nCurrentIndex_][:crowdingDistance] += _nDistance_
                            ok
                        next
                    ok
                next
            ok
        next
        
        return _aPopulation_

    def sortFrontByObjective(_front_, objIndex, _aPopulation_)
        # Simple bubble sort by objective value
        _nFrontLen_ = len(_front_)
        for i = 1 to _nFrontLen_-1
            for j = 1 to _nFrontLen_-i
                _nIndex1_ = _front_[j]
                _nIndex2_ = _front_[j+1]
                if _nIndex1_ > 0 and _nIndex1_ <= len(_aPopulation_) and
                   _nIndex2_ > 0 and _nIndex2_ <= len(_aPopulation_)
                    if _aPopulation_[_nIndex1_][:objectives][objIndex] > _aPopulation_[_nIndex2_][:objectives][objIndex]
                        # Swap
                        _temp_ = _front_[j]
                        _front_[j] = _front_[j+1]
                        _front_[j+1] = _temp_
                    ok
                ok
            next
        next
        return _front_

/*
    def createNewPopulation(_aPopulation_)
        _aNewPopulation_ = []
        _nPopLen_ = len(_aPopulation_)
        
        if _nPopLen_ = 0
            # If population is empty, reinitialize
            return This.initializePopulation()
        ok
        
        for i = 1 to @nPopulationSize
            parent1 = This.tournamentSelection(_aPopulation_)
            parent2 = This.tournamentSelection(_aPopulation_)
            
            # Check if parents are valid
            if len(parent1) = 0 or len(parent2) = 0
                # Generate random individual if parents are invalid
                _aSolution_ = This.generateRandomSolution()
                _child_ = [ :solution = _aSolution_, :objectives = [], :rank = 0, :crowdingDistance = 0 ]
            else
                _child_ = This.crossover(parent1, parent2)
                _child_ = This.mutate(_child_)
            ok
            
            _aNewPopulation_ + _child_
        next
        return _aNewPopulation_
*/

	def createNewPopulation(_aPopulation_)
	    _aNewPopulation_ = []
	    _nPopLen_ = len(_aPopulation_)
	    
	    # Count valid individuals
	    _nValidIndividuals_ = 0
	    for i = 1 to _nPopLen_
	        if len(_aPopulation_[i]) > 0 and len(_aPopulation_[i][:solution]) > 0 and 
	           len(_aPopulation_[i][:objectives]) > 0
	            _nValidIndividuals_++
	        ok
	    next
	    
	    # If too few valid individuals, reinitialize
	    if _nValidIndividuals_ < 2
	        ? "Warning: Population has too few valid individuals, reinitializing..."
	        return This.initializePopulation()
	    ok
	    
	    # Generate new population
	    for i = 1 to @nPopulationSize
	        parent1 = This.tournamentSelection(_aPopulation_)
	        parent2 = This.tournamentSelection(_aPopulation_)
	        
	        # Check if parents are valid
	        if len(parent1) = 0 or len(parent2) = 0 or 
	           len(parent1[:solution]) = 0 or len(parent2[:solution]) = 0
	            # Generate random individual if parents are invalid
	            _aSolution_ = This.generateRandomSolution()
	            _child_ = [ :solution = _aSolution_, :objectives = [], :rank = 0, :crowdingDistance = 0 ]
	        else
	            _child_ = This.crossover(parent1, parent2)
	            _child_ = This.mutate(_child_)
	        ok
	        
	        # Ensure child has valid solution structure
	        if len(_child_[:solution]) = 0
	            _child_[:solution] = This.generateRandomSolution()
	        ok
	        
	        _aNewPopulation_ + _child_
	    next
	    
	    return _aNewPopulation_

/*
    def tournamentSelection(_aPopulation_)
        _nPopLen_ = len(_aPopulation_)
        if _nPopLen_ = 0 return [] ok
        
        _nIndex1_ = random(_nPopLen_-1) + 1
        _nIndex2_ = random(_nPopLen_-1) + 1
        
        # Ensure indices are within bounds
        if _nIndex1_ < 1 _nIndex1_ = 1 ok
        if _nIndex1_ > _nPopLen_ _nIndex1_ = _nPopLen_ ok
        if _nIndex2_ < 1 _nIndex2_ = 1 ok
        if _nIndex2_ > _nPopLen_ _nIndex2_ = _nPopLen_ ok
        
        _individual1_ = _aPopulation_[_nIndex1_]
        _individual2_ = _aPopulation_[_nIndex2_]
        
        if _individual1_[:rank] < _individual2_[:rank]
            return _individual1_
        elseif _individual1_[:rank] > _individual2_[:rank]
            return _individual2_
        else
            if _individual1_[:crowdingDistance] > _individual2_[:crowdingDistance]
                return _individual1_
            else
                return _individual2_
            ok
        ok
*/

	def tournamentSelection(_aPopulation_)
	    _nPopLen_ = len(_aPopulation_)
	    if _nPopLen_ = 0 return [] ok
	    
	    # Find valid individuals first
	    _aValidIndices_ = []
	    for i = 1 to _nPopLen_
	        if len(_aPopulation_[i]) > 0 and len(_aPopulation_[i][:solution]) > 0 and 
	           len(_aPopulation_[i][:objectives]) > 0
	            _aValidIndices_ + i
	        ok
	    next
	    
	    if len(_aValidIndices_) < 2
	        return []  # Not enough valid individuals
	    ok
	    
	    # Select two random valid individuals
	    _nIdx1_ = random(len(_aValidIndices_)-1) + 1
	    _nIdx2_ = random(len(_aValidIndices_)-1) + 1
	    
	    # Ensure different individuals
	    while _nIdx1_ = _nIdx2_ and len(_aValidIndices_) > 1
	        _nIdx2_ = random(len(_aValidIndices_)-1) + 1
	    end
	    
	    _individual1_ = _aPopulation_[_aValidIndices_[_nIdx1_]]
	    _individual2_ = _aPopulation_[_aValidIndices_[_nIdx2_]]
	    
	    # Tournament selection based on rank and crowding distance
	    if _individual1_[:rank] < _individual2_[:rank]
	        return _individual1_
	    elseif _individual1_[:rank] > _individual2_[:rank]
	        return _individual2_
	    else
	        # Same rank, choose based on crowding distance (higher is better)
	        if _individual1_[:crowdingDistance] > _individual2_[:crowdingDistance]
	            return _individual1_
	        else
	            return _individual2_
	        ok
	    ok

    def crossover(parent1, parent2)
        _aSolution_ = []
        
        # Check if parents have valid solutions
        if len(parent1[:solution]) = 0 or len(parent2[:solution]) = 0
            return [ :solution = This.generateRandomSolution(), :objectives = [], :rank = 0, :crowdingDistance = 0 ]
        ok
        
        _nSolLen_ = len(parent1[:solution])
        for i = 1 to _nSolLen_
            if random(100) < @nCrossoverRate * 100
                _aSolution_ + parent1[:solution][i]
            else
                _aSolution_ + parent2[:solution][i]
            ok
        next
        return [ :solution = _aSolution_, :objectives = [], :rank = 0, :crowdingDistance = 0 ]

    def mutate(individual)
        _nSolLen_ = len(individual[:solution])
        for i = 1 to _nSolLen_
            if random(100) < @nMutationRate * 100
                if i <= len(@aVariables)
                    _var_ = @aVariables[i]
                    _nNewValue_ = _var_[:lowerBound] + random(_var_[:upperBound] - _var_[:lowerBound])
                    if _var_[:type] = "integer" or _var_[:type] = "binary"
                        _nNewValue_ = floor(_nNewValue_)
                    ok
                    individual[:solution][i][2] = _nNewValue_
                ok
            ok
        next
        return individual

    # Epsilon Constraint Helper Methods
    def calculateEpsilonRanges()
        _aRanges_ = []
        _nSteps_ = 10
        _nObjLen_ = len(@aObjectives)
        
        for i = 2 to _nObjLen_
            # Calculate min and max for each secondary objective
            _nMin_ = This.calculateObjectiveBound(@aObjectives[i][:expression], "min")
            _nMax_ = This.calculateObjectiveBound(@aObjectives[i][:expression], "max")
            _nStep_ = (_nMax_ - _nMin_) / _nSteps_
            
            _aEpsilonValues_ = []
            for j = 0 to _nSteps_
                _aEpsilonValues_ + (_nMin_ + j * _nStep_)
            next
            _aRanges_ + _aEpsilonValues_
        next
        
        # Generate combinations
        _aEpsilonSets_ = []
        if len(_aRanges_) = 1
            _nRange1Len_ = len(_aRanges_[1])
            for i = 1 to _nRange1Len_
                _aEpsilonSets_ + [_aRanges_[1][i]]
            next
        else
            _nRange1Len_ = len(_aRanges_[1])
            _nRange2Len_ = len(_aRanges_[2])
            for i = 1 to _nRange1Len_
                for j = 1 to _nRange2Len_
                    _aEpsilonSets_ + [_aRanges_[1][i], _aRanges_[2][j]]
                next
            next
        ok
        
        return _aEpsilonSets_

    def calculateObjectiveBound(cExpression, cType)
        # Simple bound estimation based on variable bounds
        _nBound_ = 0
        _nVarLen_ = len(@aVariables)
        for i = 1 to _nVarLen_
            _var_ = @aVariables[i]
            _nCoeff_ = This.extractCoefficient(cExpression, _var_[:name])
            if cType = "min"
                _nBound_ += _nCoeff_ * iff(_nCoeff_ > 0, _var_[:lowerBound], _var_[:upperBound])
            else
                _nBound_ += _nCoeff_ * iff(_nCoeff_ > 0, _var_[:upperBound], _var_[:lowerBound])
            ok
        next
        return _nBound_

    # Utility Methods (inherited from stzLinearSolver)

    def extractCoefficient(cExpression, cVarName)
        return @oCoeffExtractor.extractCoefficient(cExpression, cVarName)
	
/*
    def parseObjectiveCoefficients(cExpression)
		@oCoeffExtractor.SetVariableNames(This.VariableNames())
        return @oCoeffExtractor.extractAllCoefficients(cExpression)
*/

    def getSolutionValue(_aSolution_, cVarName)
        _nSolLen_ = len(_aSolution_)
        for i = 1 to _nSolLen_
            if _aSolution_[i][1] = cVarName return _aSolution_[i][2] ok
        next
        return 0

    # Solution Access
    def paretoSolutions()
        return @aParetoSolutions

    def bestCompromiseSolution()
        if len(@aParetoSolutions) = 0 return [] ok
        
        # Find solution with minimum sum of normalized objectives
        _nBestScore_ = 999999
        _aBestSolution_ = []
        _nParetoLen_ = len(@aParetoSolutions)
        
        for i = 1 to _nParetoLen_
            _solution_ = @aParetoSolutions[i]
            _nScore_ = 0
            _nObjLen_ = len(_solution_[:objectives])
            for j = 1 to _nObjLen_
                _nScore_ += abs(_solution_[:objectives][j])
            next
            if _nScore_ < _nBestScore_
                _nBestScore_ = _nScore_
                _aBestSolution_ = _solution_
            ok
        next
        
        return _aBestSolution_

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
        _nVarLen_ = len(@aVariables)
        for i = 1 to _nVarLen_
            _var_ = @aVariables[i]
            ? " ─ " + _var_[:name] + " ∈ [" + _var_[:lowerBound] + ", " + _var_[:upperBound] + "] (" + _var_[:type] + ")"
        next

		? ""
        ? "• Constraints:"
        _nConstLen_ = len(@aConstraints)
        for i = 1 to _nConstLen_
            _const_ = @aConstraints[i]
            ? " ─ " + _const_[:expression] + " " + _const_[:operator] + " " + _const_[:value]
        next

		? ""
        ? "• Objectives:"
        _nObjLen_ = len(@aObjectives)
        for i = 1 to _nObjLen_
            _obj_ = @aObjectives[i]
            ? " ─ " + upper(_obj_[:type]) + " " + _obj_[:expression]
        next
        
        if @cStatus != ""
			? ""
            ? BoxRound("Solutions")
            ? "• Status: " + @cStatus
            ? "• Solved in " + @nSolveTime + " second(s)"
            ? "• Iterations: " + @nIterations
			? ""
            ? "• Pareto Solutions Found: " + len(@aParetoSolutions)
            
            _oBest_ = This.bestCompromiseSolution()
            if len(_oBest_) > 0
				 ? "• Best Compromise Solution:"
                _nSolLen_ = len(_oBest_[:solution])
                for i = 1 to _nSolLen_
                    _sol_ = _oBest_[:solution][i]
                    ? " ─ " + _sol_[1] + " = " + _sol_[2]
                next

				? ""
                ? "• Objective Values:"
                _nObjLen_ = len(_oBest_[:objectives])
                for i = 1 to _nObjLen_
                    _nValue_ = _oBest_[:objectives][i]
                    if @aObjectives[i][:type] = "maximize" _nValue_ = -_nValue_ ok
                    ? " ─ " + @aObjectives[i][:expression] + " = " + _nValue_
                next
            ok
        ok

    def exportParetoFrontCSV(cFileName)
        _oFile_ = new stzFile(cFileName)
        _cContent_ = "Solution,"
        
        # Headers for variables
        _nVarLen_ = len(@aVariables)
        for i = 1 to _nVarLen_
            _cContent_ += @aVariables[i][:name] + ","
        next
        
        # Headers for objectives
        _nObjLen_ = len(@aObjectives)
        for i = 1 to _nObjLen_
            _cContent_ += @aObjectives[i][:expression] + ","
        next
        _cContent_ += nl
        
        # Data rows
        _nParetoLen_ = len(@aParetoSolutions)
        for i = 1 to _nParetoLen_
            _cContent_ += "Sol" + i + ","
            
            # Variable values
            _nSolLen_ = len(@aParetoSolutions[i][:solution])
            for j = 1 to _nSolLen_
                _cContent_ += @aParetoSolutions[i][:solution][j][2] + ","
            next
            
            # Objective values
            _nObjLen_ = len(@aParetoSolutions[i][:objectives])
            for j = 1 to _nObjLen_
                _nValue_ = @aParetoSolutions[i][:objectives][j]
                if @aObjectives[j][:type] = "maximize" _nValue_ = -_nValue_ ok
                _cContent_ += _nValue_ + ","
            next
            _cContent_ += nl
        next
        
        _oFile_.write(_cContent_)
