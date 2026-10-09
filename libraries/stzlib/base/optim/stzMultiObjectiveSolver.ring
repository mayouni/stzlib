
/*
    stzMultiObjectiveSolver - Multi-Objective Optimization Component for Softanza
    Author: Softanza Team
    Version: 0.9
    Techniques: NSGA-II (Genetic Algorithm), ε-constraint method
*/

# Looks for trade-offs between several objectives at once: a front of solutions none of which beats another on every objective.
#
# Declare variables and bounds, add two or more objectives with maximize and minimize (each call
# appends one), then call solve with nsga_ii, a seeded genetic search, or epsilon_constraint, which
# bounds the secondary objectives and solves for the first. The search is deterministic: the same
# seed gives the same front, and SetSeed changes it. NSGA-II refuses a problem that has constraints,
# and the epsilon-constraint method is only a rough tool today: its greedy sub-solver reads a lower
# bound as an upper bound, so the front repeats the same few points. exportParetoFrontCSV raises
# R41. Objective values of a maximize goal are stored negated, so smaller is always better inside
# the individuals.
#
#   receiver   o1 = new stzMultiObjectiveSolver()
#   example    o1.addVariable("x", 0, 10)
#              o1.maximize("x")
#              o1.maximize("-x")
#              o1.setNSGAParameters(8, 3, 0.1, 0.9)
#              o1.solve("nsga_ii")
#              ? len(o1.paretoSolutions())
#              #--> 8
#              ? o1.status()
#              #--> optimal
#              ? o1.dominates([ :objectives = [ -2, -2 ] ], [ :objectives = [ -1, -1 ] ])
#              #--> 1
#   see        stzLinearSolver, stzStochasticSolver
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
    @nSeed = 42        # LAW 3: two runs agree. SetSeed() to vary.

	@oCoeffExtractor

    # Builds an empty multi-objective problem, with no variable, constraint or objective and the generator seed set to 42.
    #
    #   returns    nothing; the object is built
    #   see        clear, addVariable, addObjective, solve
    def init()
        This.clear()
		@oCoeffExtractor = new stzCoeffExtractor(This.VariableNames())

    # Empties the problem: variables, constraints, objectives, the front found so far and the status are dropped, and the seed returns to 42.
    #
    #   returns    nothing; the problem is empty again
    #   note       the NSGA-II settings made with setNSGAParameters are kept
    #   see        init, SetSeed
    def clear()
        @aVariables = []
        @aConstraints = []
        @aObjectives = []
        @aParetoSolutions = []
        @nSeed = 42
        @cStatus = ""
        @nIterations = 0
        @nSolveTime = 0

    # Adds a continuous variable with a lower and an upper bound, in declaration order.
    #
    #   varName      the variable's name, as text
    #   lowerBound   the smallest value the variable may take
    #   upperBound   the largest value it may take, never below the lower bound
    #   returns      the solver itself, so calls chain
    #   warning      all three arguments must be given (R19 otherwise); a name that is not text,
    #                bounds that are not numbers and an upper bound below the lower bound each raise
    #                an error
    #   see          addIntegerVariable, addBinaryVariable, VariableNames
    #@ aka  Variables Management (inherited from stzLinearSolver)
    def addVariable(varName, lowerBound, upperBound)
        if NOT isString(varName) stzRaise("Variable name must be a string!") ok
        if NOT (isNumber(lowerBound) and isNumber(upperBound)) stzRaise("Bounds must be numbers!") ok
        if upperBound < lowerBound stzRaise("Upper bound must be >= lower bound!") ok

        @aVariables + [ :name = varName, :lowerBound = lowerBound, :upperBound = upperBound, :type = "continuous" ]
        return this

    # Adds a variable marked integer, with the same arguments and checks as a continuous one.
    #
    #   varName      the variable's name, as text
    #   lowerBound   the smallest value the variable may take
    #   upperBound   the largest value it may take
    #   returns      the solver itself, so calls chain
    #   warning      the genetic search floors the values it draws for such a variable, but the
    #                epsilon-constraint method does not enforce the mark
    #   see          addVariable, addBinaryVariable
    def addIntegerVariable(varName, lowerBound, upperBound)
        This.addVariable(varName, lowerBound, upperBound)
        @aVariables[len(@aVariables)][:type] = "integer"
        return this

    # Adds a variable bounded between 0 and 1 and marked binary.
    #
    #   varName    the variable's name, as text
    #   returns    the solver itself, so calls chain
    #   see        addVariable, addIntegerVariable
    def addBinaryVariable(varName)
        This.addVariable(varName, 0, 1)
        @aVariables[len(@aVariables)][:type] = "binary"
        return this

    # Returns the declared variables in order, each as a list of name, lowerbound, upperbound and type pairs.
    #
    #   returns    a list with one list of [ key, value ] pairs per variable; [ ] when none is
    #              declared
    #   note       the keys are lower case
    #   see        VariableNames, addVariable
    def Variables()
        return @aVariables

		# Returns the same list of declared variables as the longer accessor does.
		#
		#   returns    a list with one list of [ key, value ] pairs per variable
		#   see        Variables, VariableNames
		def Vars()
			return @aVariables


    # Returns the names of the declared variables, in declaration order.
    #
    #   returns    a list of text
    #   see        Variables, addVariable
    def VariableNames()
        _aNames_ = []
        _nVarLen_ = len(@aVariables)
        for i = 1 to _nVarLen_
            _aNames_ + @aVariables[i][:name]
        next
        return _aNames_

		def VarNames()
			return This.VariableNames()

    # Adds one linear constraint: an expression such as "x + y", a comparison and a number.
    #
    #   expression   the left side, as text
    #   operator     the comparison: "<=", ">=" or "="
    #   value        the number the expression is compared with
    #   returns      the solver itself, so calls chain
    #   warning      a value that is not a number, even the text "5", raises an error; the NSGA-II
    #                method refuses to run when any constraint exists
    #   see          constraints, solveWithEpsilonConstraint
    #@ aka  Constraints Management (inherited from stzLinearSolver)
    def addConstraint(expression, operator, value)
        if NOT isString(expression) stzRaise("Expression must be a string!") ok
        if NOT (operator = "<=" or operator = ">=" or operator = "=") stzRaise("Operator must be '<=', '>=', or '='!") ok
        if NOT isNumber(value) stzRaise("Value must be a number!") ok

        @aConstraints + [ :expression = expression, :operator = operator, :value = value ]
        return this

    # Returns the declared constraints in order, each as a list of expression, operator and value pairs.
    #
    #   returns    a list of lists of [ key, value ] pairs; [ ] when none is declared
    #   see        addConstraint
    def constraints()
        return @aConstraints

    # Appends one objective: an expression and the goal to maximize or minimize it.
    #
    #   expression   the objective, as text, such as "3*x + 2*y"
    #   type         the goal: "maximize" or "minimize"
    #   returns      the solver itself, so calls chain
    #   warning      an expression that is not text, or any other goal, raises an error
    #   see          maximize, minimize, objectives
    #@ aka  Multi-Objective Functions
    def addObjective(expression, type)
        if NOT isString(expression) stzRaise("Expression must be a string!") ok
        if NOT (type = "maximize" or type = "minimize") stzRaise("Type must be 'maximize' or 'minimize'!") ok

        @aObjectives + [ :expression = expression, :type = type ]
        return this

    # Appends an objective to make as large as possible; earlier objectives are kept.
    #
    #   expression   the objective, as text
    #   returns      the solver itself, so calls chain
    #   note         unlike the single-objective solver, calling it twice gives two objectives
    #   see          minimize, addObjective, objectives
    def maximize(expression)
        This.addObjective(expression, "maximize")
        return this

    # Appends an objective to make as small as possible; earlier objectives are kept.
    #
    #   expression   the objective, as text
    #   returns      the solver itself, so calls chain
    #   see          maximize, addObjective, objectives
    def minimize(expression)
        This.addObjective(expression, "minimize")
        return this

    # Returns the declared objectives in order, each as a list of expression and type pairs.
    #
    #   returns    a list of lists of [ key, value ] pairs; [ ] when none is declared
    #   see        addObjective
    def objectives()
        return @aObjectives

    # Sets the population size, the number of generations and the mutation and crossover rates of the genetic search.
    #
    #   populationSize   how many individuals each generation holds, 50 by default
    #   generations      how many generations to breed, 100 by default
    #   mutationRate     the chance, from 0 to 1, that a variable is redrawn, 0.1 by default
    #   crossoverRate    the chance, from 0 to 1, that a child takes a variable from the first
    #                    parent, 0.9 by default
    #   returns          the solver itself, so calls chain
    #   warning          nothing is checked: any value is stored
    #   see              solveWithNSGAII, solve
    #@ aka  Algorithm Parameters
    def setNSGAParameters(populationSize, generations, mutationRate, crossoverRate)
        @nPopulationSize = populationSize
        @nGenerations = generations
        @nMutationRate = mutationRate
        @nCrossoverRate = crossoverRate
        return this

    # Finds a set of trade-off solutions with the named method, "nsga_ii" (the default) or "epsilon_constraint", and keeps it.
    #
    #   cMethod    the method's name, an empty text selects nsga_ii
    #   returns    the solver itself, so calls chain
    #   note       maximize x and maximize -x on 0..10 with 8 individuals and 3 generations gives a
    #              front of 8, since no point beats another
    #   warning    the argument cannot be left out (R19), pass an empty text for the default; no
    #              variable, no objective, a single objective or an unknown method raise an error;
    #              the status becomes optimal in every case
    #   see        paretoSolutions, bestCompromiseSolution, status
    #@ aka  Solving Methods
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


	# Returns the non-dominated individuals of a genetic search that breeds a seeded population for the set number of generations.
	#
	#   returns    a list of individuals, each a list of solution, objectives, rank,
	#              crowdingdistance, dominatedsolutions and dominationcount pairs
	#   note       the same seed gives the same front (three runs agreed), and another seed gives
	#              another; the objectives of a maximize goal are stored negated
	#   warning    raises an error when the problem has any constraint, because the search does not
	#              enforce them; the front can hold several copies of one point; it is approximate
	#   see        solve, setNSGAParameters, SetSeed
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


    # Returns one solution per combination of bounds on the secondary objectives, each found by the greedy solver on the first objective.
    #
    #   returns    a list of individuals, each a list of solution, objectives and rank pairs
    #   note       the iteration count is set to 10 per objective
    #   warning    the front collapses: for maximize x and maximize y with x + y <= 10 all eleven
    #              solutions are x = 10 and y = 0 (the true trade-off is the line x + y = 10), and
    #              with minimize x + y and maximize x - y most solutions repeat, because the greedy
    #              solver reads ">=" bounds as "<=" and always raises a variable to its maximum;
    #              only the first two secondary objectives are used
    #   see        solve, calculateEpsilonRanges
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

    # Returns the starting population: one random solution per individual, with no objective values yet.
    #
    #   returns    a list of individuals, each a list of solution, objectives, rank and
    #              crowdingdistance pairs
    #   note       rank starts at 0 and objectives is empty
    #   see        solveWithNSGAII, generateRandomSolution
    #@ aka  NSGA-II Helper Methods
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

	# Sets the state of the pseudo-random generator that drives the genetic search.
	#
	#   n          the starting state, a positive whole number, zero or less is replaced by 42 when
	#              numbers are drawn
	#   returns    the solver itself, so calls chain
	#   see        Seed, solveWithNSGAII
	#@ aka  ── REPRODUCIBLE RANDOMNESS (LAW 3: two runs agree; SetSeed to vary) ──
	def SetSeed(n)
		@nSeed = n
		return This

	# Returns the state of the pseudo-random generator, 42 until it is set or numbers are drawn.
	#
	#   returns    a number
	#   note       the state moves each time a number is drawn, so it differs after a run
	#   see        SetSeed
	def Seed()
		return @nSeed

	# a uniform value in [0, 1)
	def _NextRand01()
		if @nSeed <= 0
			@nSeed = 42
		ok
		@nSeed = (@nSeed * 16807) % 2147483647
		return @nSeed / 2147483647

	# the shape Ring's random(n) has: an integer in 0..n inclusive. Every call site
	# below used `random(...)`, so matching its contract keeps them unchanged in
	# meaning as well as in form.
	def _NextRandom(n)
		if n <= 0
			return 0
		ok
		return floor(This._NextRand01() * (n + 1))

	# Returns one random solution within the bounds, whole numbers for integer and binary variables.
	#
	#   returns    a list of [ name, value ] pairs, one per variable
	#   note       continuous values come in steps of 0.01
	#   see        initializePopulation, mutate
	def generateRandomSolution()
	    _aSolution_ = []
	    _nVarLen_ = len(@aVariables)
	    for i = 1 to _nVarLen_
	        _var_ = @aVariables[i]
	        
	        # FIXED: Correct random number generation
	        _nRange_ = _var_[:upperBound] - _var_[:lowerBound]
	        _nValue_ = _var_[:lowerBound] + This._NextRandom(_nRange_ * 100) / 100.0
	        
	        if _var_[:type] = "integer" or _var_[:type] = "binary"
	            _nValue_ = floor(_nValue_)
	        ok
	        
	        # Ensure within bounds
	        if _nValue_ < _var_[:lowerBound] _nValue_ = _var_[:lowerBound] ok
	        if _nValue_ > _var_[:upperBound] _nValue_ = _var_[:upperBound] ok
	        
	        _aSolution_ + [_var_[:name], _nValue_]
	    next
	    return _aSolution_
	

    # Returns the value of every objective for a solution, with maximize goals negated so that smaller is always better.
    #
    #   _aSolution_   a list of [ name, value ] pairs
    #   returns       a list of numbers, one per objective
    #   note          x = 3 and y = 4 under maximize x, minimize x + y and maximize y gives -3, 7
    #                 and -4
    #   see           calculateObjectiveValue, dominates
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

    # Returns the value of an expression for a solution.
    #
    #   cExpression   the expression, as text
    #   _aSolution_   a list of [ name, value ] pairs
    #   returns       a number
    #   note          3*x + 2*y with x = 3 and y = 4 gives 17
    #   see           evaluateObjectives, extractCoefficient
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

    # Returns the fronts of a population as lists of positions, and writes each individual's rank and domination data into the population itself.
    #
    #   _aPopulation_   a list of individuals, each with an objectives list, it is changed in place
    #   returns         a list of fronts, each a list of positions in the population, the last one
    #                   empty
    #   note            three individuals with objectives (-1,-1), (-2,-2) and (-3,0) give the
    #                   fronts [ [ 2, 3 ], [ 1 ], [ ] ] and the ranks 2, 1 and 1
    #   see             dominates, calculateCrowdingDistance
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

    # TRUE if the first individual is no worse than the second on every objective and better on at least one.
    #
    #   _individual1_   an individual with an objectives list
    #   _individual2_   an individual with an objectives list
    #   returns         TRUE or FALSE
    #   note            objectives are compared as smaller is better; an individual never dominates
    #                   itself
    #   see             nonDominatedSort, evaluateObjectives
    def dominates(_individual1_, _individual2_)
        _bAtLeastOneBetter_ = 0
        _nObjLen_ = len(_individual1_[:objectives])
        for i = 1 to _nObjLen_
            if _individual1_[:objectives][i] > _individual2_[:objectives][i]
                return 0
            elseif _individual1_[:objectives][i] < _individual2_[:objectives][i]
                _bAtLeastOneBetter_ = 1
            ok
        next
        return _bAtLeastOneBetter_

    # Returns the population with a crowding distance set on each individual: 999999 at the ends of a front, the spread of its neighbours inside.
    #
    #   _aFronts_       the fronts returned by nonDominatedSort
    #   _aPopulation_   the population those fronts index
    #   returns         the population, a list of individuals
    #   see             nonDominatedSort, tournamentSelection
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

    # Returns the positions of a front ordered from the smallest to the largest value of one objective.
    #
    #   _front_         a list of positions in the population
    #   objIndex        the number of the objective to sort by
    #   _aPopulation_   the population the positions index
    #   returns         a list of positions
    #   note            the sort is a bubble sort
    #   see             calculateCrowdingDistance
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

	# Returns the next generation: one child per individual of the population size, made by tournament selection, crossover and mutation.
	#
	#   _aPopulation_   the current population, each individual with solution and objectives
	#   returns         a list of individuals with no objective values yet
	#   warning         with fewer than two usable individuals it prints a warning line and returns
	#                   a fresh random population
	#   see             tournamentSelection, crossover, mutate
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
        
        _nIndex1_ = This._NextRandom(_nPopLen_-1) + 1
        _nIndex2_ = This._NextRandom(_nPopLen_-1) + 1
        
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

	# Returns the better of two distinct usable individuals drawn at random: the lower rank, or on a tie the larger crowding distance.
	#
	#   _aPopulation_   a list of individuals
	#   returns         an individual; [ ] when fewer than two individuals have a solution and
	#                   objectives
	#   note            the draw uses the seeded generator
	#   see             createNewPopulation, calculateCrowdingDistance
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
	    _nIdx1_ = This._NextRandom(len(_aValidIndices_)-1) + 1
	    _nIdx2_ = This._NextRandom(len(_aValidIndices_)-1) + 1
	    
	    # Ensure different individuals
	    while _nIdx1_ = _nIdx2_ and len(_aValidIndices_) > 1
	        _nIdx2_ = This._NextRandom(len(_aValidIndices_)-1) + 1
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

    # Returns a child that takes each variable from the first parent with the crossover rate and from the second otherwise.
    #
    #   parent1    an individual with a solution
    #   parent2    an individual with a solution
    #   returns    an individual with a solution, no objectives and rank 0
    #   see        mutate, createNewPopulation, setNSGAParameters
    def crossover(parent1, parent2)
        _aSolution_ = []
        
        # Check if parents have valid solutions
        if len(parent1[:solution]) = 0 or len(parent2[:solution]) = 0
            return [ :solution = This.generateRandomSolution(), :objectives = [], :rank = 0, :crowdingDistance = 0 ]
        ok
        
        _nSolLen_ = len(parent1[:solution])
        for i = 1 to _nSolLen_
            if This._NextRandom(100) < @nCrossoverRate * 100
                _aSolution_ + parent1[:solution][i]
            else
                _aSolution_ + parent2[:solution][i]
            ok
        next
        return [ :solution = _aSolution_, :objectives = [], :rank = 0, :crowdingDistance = 0 ]

    # Returns the individual after redrawing each variable at random between its bounds, with the mutation rate as the chance for each.
    #
    #   individual   an individual with a solution
    #   returns      the same individual, changed
    #   see          crossover, setNSGAParameters
    def mutate(individual)
        _nSolLen_ = len(individual[:solution])
        for i = 1 to _nSolLen_
            if This._NextRandom(100) < @nMutationRate * 100
                if i <= len(@aVariables)
                    _var_ = @aVariables[i]
                    _nNewValue_ = _var_[:lowerBound] + This._NextRandom(_var_[:upperBound] - _var_[:lowerBound])
                    if _var_[:type] = "integer" or _var_[:type] = "binary"
                        _nNewValue_ = floor(_nNewValue_)
                    ok
                    individual[:solution][i][2] = _nNewValue_
                ok
            ok
        next
        return individual

    # Returns every combination of eleven evenly spaced bounds for the secondary objectives, for the epsilon-constraint method.
    #
    #   returns    a list of lists of numbers: 11 rows of one bound with two objectives, 121 rows of
    #              two bounds with three or more
    #   note       each range runs from the objective's lowest to its highest value over the
    #              variable bounds
    #   warning    only the first two secondary objectives are used: four objectives still give 121
    #              rows of two bounds
    #   see        solveWithEpsilonConstraint, calculateObjectiveBound
    #@ aka  Epsilon Constraint Helper Methods
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

    # Returns the lowest or the highest value an expression can reach over the variable bounds.
    #
    #   cExpression   the expression, as text
    #   cType         "min" for the lowest value, anything else for the highest
    #   returns       a number
    #   note          3*x - 2*y with x and y between 0 and 10 gives -20 and 30
    #   see           calculateEpsilonRanges
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

    # Returns the coefficient of one variable in an expression.
    #
    #   cExpression   the expression, as text
    #   cVarName      the variable's name
    #   returns       a number; 0 when the variable does not appear
    #   note          in 3*x + 2*y the coefficient of y is 2
    #   see           calculateObjectiveValue
    #@ aka  Utility Methods (inherited from stzLinearSolver)
    def extractCoefficient(cExpression, cVarName)
        return @oCoeffExtractor.extractCoefficient(cExpression, cVarName)
	
/*
    def parseObjectiveCoefficients(cExpression)
		@oCoeffExtractor.SetVariableNames(This.VariableNames())
        return @oCoeffExtractor.extractAllCoefficients(cExpression)
*/

    # Returns the value of one variable in a list of [ name, value ] pairs.
    #
    #   _aSolution_   a list of [ name, value ] pairs
    #   cVarName      the variable's name
    #   returns       a number; 0 when the name is not in the list
    #   see           calculateObjectiveValue
    def getSolutionValue(_aSolution_, cVarName)
        _nSolLen_ = len(_aSolution_)
        for i = 1 to _nSolLen_
            if _aSolution_[i][1] = cVarName return _aSolution_[i][2] ok
        next
        return 0

    # Returns the trade-off solutions kept by the last solve.
    #
    #   returns    a list of individuals; [ ] before any solve
    #   see        solve, bestCompromiseSolution
    #@ aka  Solution Access
    def paretoSolutions()
        return @aParetoSolutions

    # Returns the stored solution whose objective values have the smallest sum of absolute values.
    #
    #   returns    one individual; [ ] before any solve
    #   note       the values are not normalised, so an objective with large numbers dominates the
    #              choice
    #   see        paretoSolutions, solve
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

    # Returns how the last solve ended.
    #
    #   returns    the text optimal after a solve; "" before
    #   see        solve
    def status()
        return @cStatus

    # Returns the work counted by the last solve: the number of generations for nsga_ii, ten per objective for the epsilon method.
    #
    #   returns    a number; 0 before any solve
    #   see        solve, status
    def iterations()
        return @nIterations

    # Returns the time the last solve took, in seconds.
    #
    #   returns    a number; 0 before any solve
    #   see        solve
    def solveTime()
        return @nSolveTime

    # Prints the problem and, once solved, the status, the size of the front and the best compromise with its objective values.
    #
    #   returns    nothing; it prints to the console
    #   see        exportParetoFrontCSV, bestCompromiseSolution
    #@ aka  Display and Reporting
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

    # Raises error R41 today instead of writing the front to a file, one row per solution.
    #
    #   cFileName   the path of the file to write
    #   returns     nothing; raises R41 Invalid numeric string
    #   warning     a variable value, a number, is joined to a comma with + and Ring cannot add a
    #               number to a text; it raises for the front of every problem tried (two problems,
    #               epsilon-constraint method)
    #   see         paretoSolutions, show
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
