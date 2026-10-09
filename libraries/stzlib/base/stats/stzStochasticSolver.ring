
/*
    stzStochasticSolver - Enhanced Stochastic Programming Component for Softanza
    Author: Softanza Team
    Version: 1.1
    Features: _scenario_-based optimization, robust optimization, uncertainty modeling, string constraint values
*/

# Describes one optimisation problem under several scenarios, each with a probability, and checks and scores a plan against all of them.
#
# Declare variables, constraints and an objective as for stzLinearSolver, then add scenarios: each
# has a name, a description, parameters such as [ "d", 4 ] that are replaced as text inside the
# expressions and the constraint values, and a probability. The probabilities must add up to 1 when
# the problem is solved. setSolverType chooses expected, robust, chance or montecarlo. WHAT WORKS
# TODAY: the description of the problem, the scenario parameters, evaluateConstraintValue,
# checkScenarioFeasibility, calculateScenarioObjectiveValue, analyzeScenarios and
# expectedObjectiveValue for a plan you supply. WHAT DOES NOT: solve gives wrong answers. The
# expected, robust and chance solvers leave every variable at its lower bound, because they update a
# copy of each solution pair, and calculateScenarioMaxValue answers 999999 (no limit) for every
# constraint, because its switch label on "=" or "<=" matches no operator, so the Monte Carlo solver
# returns upper bounds that break the constraints. The status is optimal in every case. See the
# defect list of wave 10.
#
#   receiver   o1 = new stzStochasticSolver()
#   example    o1.addVariable("x", 0, 10).addVariable("y", 0, 10)
#              o1.addScenario("low", "Low demand", [ [ "d", 4 ] ], 0.4).addScenario("high", "High demand", [ [ "d", 8 ] ], 0.6)
#              o1.addConstraint("x + y", "<=", "d").maximize("3*x + 2*y")
#              ? o1.checkScenarioFeasibility([ [ "x", 3 ], [ "y", 1 ] ], o1.scenarios()[1])
#              #--> 1
#              ? o1.checkScenarioFeasibility([ [ "x", 3 ], [ "y", 3 ] ], o1.scenarios()[1])
#              #--> 0
#              ? o1.calculateScenarioObjectiveValue([ [ "x", 3 ], [ "y", 1 ] ], o1.scenarios()[2])
#              #--> 11
#   see        stzLinearSolver, stzMultiObjectiveSolver
class stzStochasticSolver from stzObject

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

    # Builds an empty stochastic problem, with no variable, constraint, objective or scenario.
    #
    #   returns    nothing; the object is built
    #   see        clear, addVariable, addScenario, solve
    def init()
        This.clear()
		@oCoeffExtractor = new stzCoeffExtractor(This.variableNames())

    # Empties the problem and restores the defaults: solver type expected, robustness factor 0.1 and confidence level 0.95.
    #
    #   returns    nothing; the problem is empty again
    #   see        init, setSolverType
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

    # Adds a continuous variable with a lower and an upper bound, in declaration order.
    #
    #   _varName_    the variable's name, as text
    #   lowerBound   the smallest value the variable may take
    #   upperBound   the largest value it may take, never below the lower bound
    #   returns      the solver itself, so calls chain
    #   warning      all three arguments must be given (R19 otherwise) and the bounds must be
    #                numbers; a name that is not text and an upper bound below the lower bound raise
    #                an error
    #   see          addIntegerVariable, addBinaryVariable, variableNames
    #@ aka  Variables Management
    def addVariable(_varName_, lowerBound, upperBound)
        if NOT isString(_varName_) stzRaise("Variable name must be a string!") ok
        if NOT (isNumber(lowerBound) and isNumber(upperBound)) stzRaise("Bounds must be numbers!") ok
        if upperBound < lowerBound stzRaise("Upper bound must be >= lower bound!") ok

        @aVariables + [ :name = _varName_, :lowerBound = lowerBound, :upperBound = upperBound, :type = "continuous" ]
        return this

    # Adds a variable marked integer, with the same arguments and checks as a continuous one.
    #
    #   _varName_    the variable's name, as text
    #   lowerBound   the smallest value the variable may take
    #   upperBound   the largest value it may take
    #   returns      the solver itself, so calls chain
    #   warning      the mark is only recorded in the variable list, no solver enforces it
    #   see          addVariable, addBinaryVariable
    def addIntegerVariable(_varName_, lowerBound, upperBound)
        This.addVariable(_varName_, lowerBound, upperBound)
        @aVariables[len(@aVariables)][:type] = "integer"
        return this

    # Adds a variable bounded between 0 and 1 and marked binary.
    #
    #   _varName_   the variable's name, as text
    #   returns     the solver itself, so calls chain
    #   warning     the mark is only recorded, no solver enforces it
    #   see         addVariable, addIntegerVariable
    def addBinaryVariable(_varName_)
        This.addVariable(_varName_, 0, 1)
        @aVariables[len(@aVariables)][:type] = "binary"
        return this

    # Returns the declared variables in order, each as a list of name, lowerbound, upperbound and type pairs.
    #
    #   returns    a list with one list of [ key, value ] pairs per variable; [ ] when none is
    #              declared
    #   note       the keys are lower case
    #   see        variableNames, addVariable
    def variables()
        return @aVariables

    # Returns the names of the declared variables, in declaration order.
    #
    #   returns    a list of text
    #   see        variables, addVariable
    def variableNames()
        _aNames_ = []
        _nVariables3Len_ = len(@aVariables)
        for _iLoopVariables3_ = 1 to _nVariables3Len_
        	_var_ = @aVariables[_iLoopVariables3_]
            _aNames_ + _var_[:name]
        next
        return _aNames_

		def VarNames()
			return This.VariableNames()

	# Replaces the whole variable list with the list given, without reshaping it.
	#
	#   pacNames   the new variable records, each a list holding a name pair such as [ "name", "q" ]
	#   returns    nothing
	#   warning    despite its name it replaces the variable records, not only their names:
	#              SetVariableNames([ "a", "b" ]) makes variables() answer [ "a", "b" ] and
	#              variableNames() then raises R5, and any bounds are lost; the code carries a TODO
	#              for more checks
	#   see        variables, variableNames, addVariable
	def SetVariableNames(pacNames)
		#TODO // Add more checks here
		@aVariables = pacNames

    # Adds one future state of the world, with the parameter values that define it and its probability.
    #
    #   name          the scenario's name, as text
    #   description   a sentence describing it, as text
    #   parameters    a list of [ name, value ] pairs, such as [ [ "d", 4 ] ], replaced as text
    #                 inside expressions and constraint values
    #   probability   a number from 0 to 1
    #   returns       the solver itself, so calls chain
    #   warning       a name or description that is not text, parameters that are not a list, and a
    #                 probability that is not a number between 0 and 1 each raise an error;
    #                 probabilities are only checked together when the problem is solved
    #   see           scenarios, validateScenarios, applyScenarioParameters
    #@ aka  Scenario Management
    def addScenario(name, description, parameters, probability)
        if NOT isString(name) stzRaise("Scenario name must be a string!") ok
        if NOT isString(description) stzRaise("Description must be a string!") ok
        if NOT isList(parameters) stzRaise("Parameters must be a list of [name, value] pairs!") ok
        if NOT isNumber(probability) stzRaise("Probability must be a number!") ok
        if probability < 0 or probability > 1 stzRaise("Probability must be between 0 and 1!") ok

        @aScenarios + [ :name = name, :description = description, :parameters = parameters, :probability = probability ]
        return this

    # Returns the declared scenarios in order, each as a list of name, description, parameters and probability pairs.
    #
    #   returns    a list of lists of [ key, value ] pairs; [ ] when none is declared
    #   see        addScenario
    def scenarios()
        return @aScenarios

    # Raises an error unless the probabilities of the scenarios add up to 1, within 0.001.
    #
    #   returns    nothing; it raises when the check fails
    #   note       with no scenario the total is 0 and it raises as well
    #   see        addScenario, solve
    def validateScenarios()
        _nTotalProb_ = 0
        _nScenarios14Len_ = len(@aScenarios)
        for _iLoopScenarios14_ = 1 to _nScenarios14Len_
        	_scenario_ = @aScenarios[_iLoopScenarios14_]
            _nTotalProb_ += _scenario_[:probability]
        next
        if abs(_nTotalProb_ - 1.0) > 0.001 stzRaise("Scenario probabilities must sum to 1.0!") ok

    # Adds a constraint that holds in every scenario: an expression, a comparison and a number or a text to evaluate per scenario.
    #
    #   expression   the left side, as text
    #   operator     the comparison: "<=", ">=" or "="
    #   value        a number, or a text such as "d * 2" in which scenario parameters are replaced
    #                and one arithmetic operation is evaluated
    #   returns      the solver itself, so calls chain
    #   note         the stored constraint has scenario all and chance 1
    #   warning      an expression that is not text, another operator, or a value that is neither a
    #                number nor text raise an error
    #   see          addScenarioConstraint, addChanceConstraint, constraints
    #@ aka  Constraints Management - Enhanced to support string values
    def addConstraint(expression, operator, value)
        if NOT isString(expression) stzRaise("Expression must be a string!") ok
        if NOT (operator = "<=" or operator = ">=" or operator = "=") stzRaise("Operator must be '<=', '>=', or '='!") ok
        if NOT (isNumber(value) or isString(value)) stzRaise("Value must be a number or string expression!") ok

        @aConstraints + [ :expression = expression, :operator = operator, :value = value, :scenario = "all", :chance = 1.0 ]
        return this

    # Adds a constraint that applies in one named scenario only.
    #
    #   expression     the left side, as text
    #   operator       the comparison: "<=", ">=" or "="
    #   value          a number or a text to evaluate
    #   scenarioName   the name of the scenario it applies to, as text
    #   returns        the solver itself, so calls chain
    #   warning        the expression and the operator are not checked, unlike addConstraint
    #   see            addConstraint, addScenario
    def addScenarioConstraint(expression, operator, value, scenarioName)
        if NOT isString(scenarioName) stzRaise("Scenario name must be a string!") ok
        if NOT (isNumber(value) or isString(value)) stzRaise("Value must be a number or string expression!") ok
        
        @aConstraints + [ :expression = expression, :operator = operator, :value = value, :scenario = scenarioName, :chance = 1.0 ]
        return this

    # Adds a constraint that must hold with a given probability, to be read when the solver type is chance.
    #
    #   expression        the left side, as text
    #   operator          the comparison: "<=", ">=" or "="
    #   value             a number or a text to evaluate
    #   confidenceLevel   the probability, from 0 to 1, with which it must hold
    #   returns           the solver itself, so calls chain
    #   warning           a confidence level outside 0 to 1, or not a number, raises an error; the
    #                     expression and the operator are not checked
    #   see               addConstraint, setConfidenceLevel
    def addChanceConstraint(expression, operator, value, confidenceLevel)
        if NOT isNumber(confidenceLevel) stzRaise("Confidence level must be a number!") ok
        if confidenceLevel < 0 or confidenceLevel > 1 stzRaise("Confidence level must be between 0 and 1!") ok
        if NOT (isNumber(value) or isString(value)) stzRaise("Value must be a number or string expression!") ok

        @aConstraints + [ :expression = expression, :operator = operator, :value = value, :scenario = "all", :chance = confidenceLevel ]
        return this

    # Returns the declared constraints in order, each as a list of expression, operator, value, scenario and chance pairs.
    #
    #   returns    a list of lists of [ key, value ] pairs; [ ] when none is declared
    #   see        addConstraint
    def constraints()
        return @aConstraints

    # Sets the objective to an expression to make as large as possible, replacing any earlier objective.
    #
    #   expression   the objective, as text, which may name scenario parameters
    #   returns      the solver itself, so calls chain
    #   see          minimize, objective, solve
    #@ aka  Objective Function
    def maximize(expression)
        @cObjective = expression
        @cObjectiveType = "maximize"
        return this

    # Sets the objective to an expression to make as small as possible, replacing any earlier objective.
    #
    #   expression   the objective, as text, which may name scenario parameters
    #   returns      the solver itself, so calls chain
    #   see          maximize, objective, solve
    def minimize(expression)
        @cObjective = expression
        @cObjectiveType = "minimize"
        return this

    # Returns the objective expression as text.
    #
    #   returns    a text; "" before an objective is set
    #   see        maximize, minimize, objectiveType
    def objective()
        return @cObjective

    # Returns whether the objective is to be made larger or smaller.
    #
    #   returns    the text "maximize" or "minimize"; "maximize" before any objective is set
    #   see        maximize, minimize
    def objectiveType()
        return @cObjectiveType

    # Chooses how solve treats the uncertainty: expected, robust, chance or montecarlo.
    #
    #   cType      one of "expected", "robust", "chance" or "montecarlo", in lower case
    #   returns    the solver itself, so calls chain
    #   warning    any other name raises an error
    #   see        solverType, solve
    #@ aka  Solver Configuration
    def setSolverType(cType)
        if NOT (cType = "expected" or cType = "robust" or cType = "chance" or cType = "montecarlo")
            stzRaise("Solver type must be 'expected', 'robust', 'chance', or 'montecarlo'!")
        ok
        @cSolverType = cType
        return this

    # Sets the fraction, from 0 to 1, by which the robust solver shrinks every scenario limit; 0.1 by default.
    #
    #   nFactor    a number from 0 to 1
    #   returns    the solver itself, so calls chain
    #   warning    a value outside 0 to 1, or not a number, raises an error
    #   see        setSolverType, calculateRobustMaxValue
    def setRobustnessFactor(nFactor)
        if NOT isNumber(nFactor) stzRaise("Robustness factor must be a number!") ok
        if nFactor < 0 or nFactor > 1 stzRaise("Robustness factor must be between 0 and 1!") ok
        @nRobustnessFactor = nFactor
        return this

    # Sets the probability, from 0 to 1, that the chance solver aims to cover; 0.95 by default.
    #
    #   nLevel     a number from 0 to 1
    #   returns    the solver itself, so calls chain
    #   warning    a value outside 0 to 1, or not a number, raises an error
    #   see        addChanceConstraint, calculateChanceMaxValue
    def setConfidenceLevel(nLevel)
        if NOT isNumber(nLevel) stzRaise("Confidence level must be a number!") ok
        if nLevel < 0 or nLevel > 1 stzRaise("Confidence level must be between 0 and 1!") ok
        @nConfidenceLevel = nLevel
        return this

    # Returns a constraint's right side for one scenario: a number as it is, a text after its parameters are replaced and evaluated.
    #
    #   value        a number or a text such as "d * 2"
    #   _scenario_   a scenario, as returned by scenarios
    #   returns      a number
    #   note         with d = 4 the text "d * 2" gives 8 and "d + 3" gives 7
    #   see          applyScenarioParameters, evaluateExpression
    #@ aka  Enhanced Value Evaluation - New method to handle string constraint values
    def evaluateConstraintValue(value, _scenario_)
        if isNumber(value)
            return value
        else
            # Apply scenario parameters to string expression
            _cEvaluated_ = This.applyScenarioParameters(string(value), _scenario_[:parameters])
            # Simple expression evaluator for basic math operations
            return This.evaluateExpression(_cEvaluated_)
        ok

    # Returns the value of a text holding a single number or one operation between two numbers: *, /, + or -.
    #
    #   cExpression   the text, such as "6 / 3"
    #   returns       a number
    #   note          6 / 3 gives 2, 7 - 2 gives 5, 2 + 3 gives 5
    #   warning       a text with two operations, such as "2 * 3 + 1", raises R41 Invalid numeric
    #                 string, and a division by zero raises an error
    #   see           evaluateConstraintValue
    def evaluateExpression(cExpression)
        # Simple expression evaluator for basic arithmetic
        # Handles: number, number * number, number + number, number - number, number / number
        _cExpr_ = trim(cExpression)
        
        # Handle multiplication
        if ring_substr1(_cExpr_, "*")
            _acParts_ = split(_cExpr_, "*")
            if len(_acParts_) = 2
                _nLeft_ = 0+ trim(_acParts_[1])
                _nRight_ = 0+ trim(_acParts_[2])
                return _nLeft_ * _nRight_
            ok
        ok
        
        # Handle division
        if ring_substr1(_cExpr_, "/")
            _acParts_ = split(_cExpr_, "/")
            if len(_acParts_) = 2
                _nLeft_ = 0+ trim(_acParts_[1])
                _nRight_ = 0+ trim(_acParts_[2])
                if _nRight_ != 0
                    return _nLeft_ / _nRight_
                else
                    stzRaise("Division by zero in constraint value!")
                ok
            ok
        ok
        
        # Handle addition
        if ring_substr1(_cExpr_, "+")
            _acParts_ = split(_cExpr_, "+")
            if len(_acParts_) = 2
                _nLeft_ = 0+ trim(_acParts_[1])
                _nRight_ = 0+ trim(_acParts_[2])
                return _nLeft_ + _nRight_
            ok
        ok
        
        # Handle subtraction
        if ring_substr1(_cExpr_, "-")
            _acParts_ = split(_cExpr_, "-")
            if len(_acParts_) = 2
                _nLeft_ = 0+ trim(_acParts_[1])
                _nRight_ = 0+ trim(_acParts_[2])
                return _nLeft_ - _nRight_
            ok
        ok
        
        # If no operators, try to convert to number
        return 0+ _cExpr_

    # Validates the problem and runs the solver chosen with setSolverType, then stores its solution.
    #
    #   returns    the solver itself, so calls chain
    #   warning    no variable, no objective, no scenario, or probabilities that do not add up to 1
    #              raise an error; the solvers expected, robust and chance leave every variable at
    #              its lower bound today, and no solver respects the constraints (see
    #              solveExpectedValue and calculateScenarioMaxValue); the status is set to optimal
    #              in every case
    #   see        setSolverType, solution, status, expectedObjectiveValue
    #@ aka  Main Solving Methods
    def solve()
        _nStartTime_ = clock()
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

        @nSolveTime = (clock() - _nStartTime_) / clockspersecond()
        @cStatus = "optimal"
        return this

    # Returns a solution from the probability-weighted objective, giving each variable in turn the largest value its limits allow.
    #
    #   returns    a list of [ name, value ] pairs, one per variable
    #   warning    it answers every variable at its lower bound: the update writes to a copy of the
    #              pair (_sol_ is a copy of the list item), so the solution never changes; with one
    #              variable x in 0..3, x <= 2 and maximize x it answers 0, and in a two-variable
    #              problem it answers 0 and 0; its limits are also broken, see
    #              calculateScenarioMaxValue
    #   see        solve, solveRobust, calculateExpectedMaxValue
    #@ aka  Expected Value Method
    def solveExpectedValue()
        @nIterations = len(@aVariables)
        _aVarNames_ = This.variableNames()
        _aSolution_ = []

        # Initialize solution
        _nVariablesLen_4 = len(@aVariables)
        for i = 1 to _nVariablesLen_4
            _aSolution_ + [_aVarNames_[i], @aVariables[i][:lowerBound]]
        next

        # Calculate expected objective coefficients
        _aExpectedCoeffs_ = []
        _nVarNames2Len_ = len(_aVarNames_)
        for _iLoopVarNames2_ = 1 to _nVarNames2Len_
        	_varName_ = _aVarNames_[_iLoopVarNames2_]
            _nExpectedCoeff_ = 0
            _nScenarios13Len_ = len(@aScenarios)
            for _iLoopScenarios13_ = 1 to _nScenarios13Len_
            	_scenario_ = @aScenarios[_iLoopScenarios13_]
                _cModifiedObjective_ = This.applyScenarioParameters(@cObjective, _scenario_[:parameters])
                _nCoeff_ = This.extractCoefficient(_cModifiedObjective_, _varName_)
                if @cObjectiveType = "minimize" _nCoeff_ = -_nCoeff_ ok
                _nExpectedCoeff_ += _nCoeff_ * _scenario_[:probability]
            next
            _aExpectedCoeffs_ + _nExpectedCoeff_
        next

        # Calculate efficiency for each variable
        _aEfficiency_ = []
        _nVarNamesLen_4 = len(_aVarNames_)
        for i = 1 to _nVarNamesLen_4
            _nCoeff_ = _aExpectedCoeffs_[i]
            _nResourceCost_ = This.calculateExpectedResourceCost(_aVarNames_[i])
			if _nResourceCost_ = 0
				_nEfficiency_ = 1
			else
            	_nEfficiency_ = iff(_nResourceCost_ > 0, _nCoeff_ / _nResourceCost_, 0)
			ok
            _aEfficiency_ + [_aVarNames_[i], _nEfficiency_, i]
        next

        # Sort by efficiency (descending)
        _aEfficiency_ = sorton(_aEfficiency_, 2)
        _aEfficiency_ = reverse(_aEfficiency_)

        # Assign maximum feasible values
        _nEfficiency3Len_ = len(_aEfficiency_)
        for _iLoopEfficiency3_ = 1 to _nEfficiency3Len_
        	_eff_ = _aEfficiency_[_iLoopEfficiency3_]
            _cVarName_ = _eff_[1]
            _nVarIndex_ = _eff_[3]
            _nMaxPossible_ = This.calculateExpectedMaxValue(_cVarName_, _aSolution_)
            _nUpperBound_ = @aVariables[_nVarIndex_][:upperBound]
            _nValue_ = min([_nMaxPossible_, _nUpperBound_])
            _nSolution6Len_ = len(_aSolution_)
            for _iLoopSolution6_ = 1 to _nSolution6Len_
            	_sol_ = _aSolution_[_iLoopSolution6_]
                if _sol_[1] = _cVarName_
                    _sol_[2] = _nValue_
                    exit
                ok
            next
        next

        return _aSolution_

    # Returns a solution built from the first scenario's objective, with each limit shrunk by the robustness factor.
    #
    #   returns    a list of [ name, value ] pairs, one per variable
    #   warning    it answers every variable at its lower bound, for the same reason as
    #              solveExpectedValue (a copy of the pair is updated), on two problems
    #   see        solve, setRobustnessFactor, getWorstCaseObjective
    #@ aka  Robust Optimization
    def solveRobust()
        _aVarNames_ = This.variableNames()
        _aSolution_ = []

        # Initialize solution
        _nVariablesLen_3 = len(@aVariables)
        for i = 1 to _nVariablesLen_3
            _aSolution_ + [_aVarNames_[i], @aVariables[i][:lowerBound]]
        next

        # Use worst-case scenario for objective
        _cWorstObjective_ = This.getWorstCaseObjective()
        _aCoeffs_ = This.parseObjectiveCoefficients(_cWorstObjective_)

        # Calculate efficiency using worst-case
        _aEfficiency_ = []
        _nVarNamesLen_3 = len(_aVarNames_)
        for i = 1 to _nVarNamesLen_3
            _nCoeff_ = _aCoeffs_[i]
            _nResourceCost_ = This.calculateWorstCaseResourceCost(_aVarNames_[i])
            _nEfficiency_ = iff(_nResourceCost_ > 0, _nCoeff_ / _nResourceCost_, 0)
            _aEfficiency_ + [_aVarNames_[i], _nEfficiency_, i]
        next

        _aEfficiency_ = sorton(_aEfficiency_, 2)
        _aEfficiency_ = reverse(_aEfficiency_)

        # Assign values using robust constraints
        _nEfficiency2Len_ = len(_aEfficiency_)
        for _iLoopEfficiency2_ = 1 to _nEfficiency2Len_
        	_eff_ = _aEfficiency_[_iLoopEfficiency2_]
            _cVarName_ = _eff_[1]
            _nVarIndex_ = _eff_[3]
            _nMaxPossible_ = This.calculateRobustMaxValue(_cVarName_, _aSolution_)
            _nUpperBound_ = @aVariables[_nVarIndex_][:upperBound]
            _nValue_ = min([_nMaxPossible_, _nUpperBound_])
            _nSolution5Len_ = len(_aSolution_)
            for _iLoopSolution5_ = 1 to _nSolution5Len_
            	_sol_ = _aSolution_[_iLoopSolution5_]
                if _sol_[1] = _cVarName_
                    _sol_[2] = _nValue_
                    exit
                ok
            next
        next

        return _aSolution_

    # Returns a solution built from the expected objective, with limits read at the confidence level.
    #
    #   returns    a list of [ name, value ] pairs, one per variable
    #   warning    it answers every variable at its lower bound, for the same reason as
    #              solveExpectedValue (a copy of the pair is updated), on two problems
    #   see        solve, setConfidenceLevel, calculateChanceMaxValue
    #@ aka  Chance-Constrained Programming
    def solveChanceConstrained()
        # Simplified chance-constrained approach
        # Uses confidence level to adjust constraints
        _aVarNames_ = This.variableNames()
        _aSolution_ = []

        # Initialize solution
        _nVariablesLen_2 = len(@aVariables)
        for i = 1 to _nVariablesLen_2
            _aSolution_ + [_aVarNames_[i], @aVariables[i][:lowerBound]]
        next

        # Use expected objective but confidence-adjusted constraints
        _aExpectedCoeffs_ = []
        _nVarNames1Len_ = len(_aVarNames_)
        for _iLoopVarNames1_ = 1 to _nVarNames1Len_
        	_varName_ = _aVarNames_[_iLoopVarNames1_]
            _nExpectedCoeff_ = 0
            _nScenarios12Len_ = len(@aScenarios)
            for _iLoopScenarios12_ = 1 to _nScenarios12Len_
            	_scenario_ = @aScenarios[_iLoopScenarios12_]
                _cModifiedObjective_ = This.applyScenarioParameters(@cObjective, _scenario_[:parameters])
               _nCoeff_ = This.extractCoefficient(_cModifiedObjective_, _varName_)
                if @cObjectiveType = "minimize" _nCoeff_ = -_nCoeff_ ok
                _nExpectedCoeff_ += _nCoeff_ * _scenario_[:probability]
            next
            _aExpectedCoeffs_ + _nExpectedCoeff_
        next

        # Calculate efficiency with chance constraints
        _aEfficiency_ = []
        _nVarNamesLen_2 = len(_aVarNames_)
        for i = 1 to _nVarNamesLen_2
            _nCoeff_ = _aExpectedCoeffs_[i]
            _nResourceCost_ = This.calculateChanceResourceCost(_aVarNames_[i])
            _nEfficiency_ = iff(_nResourceCost_ > 0, _nCoeff_ / _nResourceCost_, 0)
            _aEfficiency_ + [_aVarNames_[i], _nEfficiency_, i]
        next

        _aEfficiency_ = sorton(_aEfficiency_, 2)
        _aEfficiency_ = reverse(_aEfficiency_)

        # Assign values respecting chance constraints
        _nEfficiency1Len_ = len(_aEfficiency_)
        for _iLoopEfficiency1_ = 1 to _nEfficiency1Len_
        	_eff_ = _aEfficiency_[_iLoopEfficiency1_]
            _cVarName_ = _eff_[1]
            _nVarIndex_ = _eff_[3]
            _nMaxPossible_ = This.calculateChanceMaxValue(_cVarName_, _aSolution_)
            _nUpperBound_ = @aVariables[_nVarIndex_][:upperBound]
            _nValue_ = min([_nMaxPossible_, _nUpperBound_])
            _nSolution4Len_ = len(_aSolution_)
            for _iLoopSolution4_ = 1 to _nSolution4Len_
            	_sol_ = _aSolution_[_iLoopSolution4_]
                if _sol_[1] = _cVarName_
                    _sol_[2] = _nValue_
                    exit
                ok
            next
        next

        return _aSolution_

    # Returns the best of 100 per-scenario solutions, each for a scenario drawn at random by probability.
    #
    #   returns    a list of [ name, value ] pairs, one per variable
    #   warning    the draws are random; the constraints do not limit anything today, so every
    #              variable comes back at its upper bound (with x in 0..3 and x <= 2 it answered 3;
    #              with x + y <= d it answered 10 and 10)
    #   see        solve, solveForScenario
    #@ aka  Monte Carlo Simulation
    def solveMonteCarlo()
        _nSimulations_ = 100
        _aBestSolution_ = []
        _nBestValue_ = iff(@cObjectiveType = "maximize",-999999, 999999)

        for sim = 1 to _nSimulations_
            # Sample scenario based on probabilities
            _nRand_ = StzEngineRandomInt(0, 100) / 100.0
            _nCumProb_ = 0
            _selectedScenario_ = @aScenarios[1]
            _nScenarios11Len_ = len(@aScenarios)
            for _iLoopScenarios11_ = 1 to _nScenarios11Len_
            	_scenario_ = @aScenarios[_iLoopScenarios11_]
                _nCumProb_ += _scenario_[:probability]
                if _nRand_ <= _nCumProb_
                    _selectedScenario_ = _scenario_
                    exit
                ok
            next

            # Solve for this scenario
            _aSampleSolution_ = This.solveForScenario(_selectedScenario_)
            _nSampleValue_ = This.calculateScenarioObjectiveValue(_aSampleSolution_, _selectedScenario_)

            # Update best solution
            if (@cObjectiveType = "maximize" and _nSampleValue_ > _nBestValue_) or 
               (@cObjectiveType = "minimize" and _nSampleValue_ < _nBestValue_)
                _nBestValue_ = _nSampleValue_
                _aBestSolution_ = _aSampleSolution_
            ok
        next

        return _aBestSolution_

    # Returns the expression with every parameter name replaced by its value, as text.
    #
    #   cExpression   the expression, as text
    #   aParameters   a list of [ name, value ] pairs
    #   returns       a text
    #   note          the replacement is plain text: 2*d + x with d = 4 gives 2*4 + x, and dd + 2*d
    #                 gives 44 + 2*4
    #   see           evaluateConstraintValue, addScenario
    #@ aka  Helper Methods
    def applyScenarioParameters(cExpression, aParameters)
        _cResult_ = cExpression
        _nParameters1Len_ = len(aParameters)
        for _iLoopParameters1_ = 1 to _nParameters1Len_
        	param = aParameters[_iLoopParameters1_]
            _cResult_ = StzStringQ(_cResult_).ReplaceAllQ(param[1], string(param[2])).Content()
        next
        return _cResult_

    # Returns the coefficient of one variable in an expression.
    #
    #   cExpression   the expression, as text
    #   _cVarName_    the variable's name
    #   returns       a number; 0 when the variable does not appear
    #   note          in 3*x + 2*y the coefficient of y is 2
    #   see           parseObjectiveCoefficients
    def extractCoefficient(cExpression, _cVarName_)
        return @oCoeffExtractor.extractCoefficient(cExpression, _cVarName_)
	

    # Returns the coefficient of each declared variable in an expression, in declaration order.
    #
    #   cExpression   the expression, as text
    #   returns       a list of numbers
    #   note          3*x + 2*y gives [ 3, 2 ]
    #   see           extractCoefficient, variableNames
    def parseObjectiveCoefficients(cExpression)
		@oCoeffExtractor.SetVariableNames(This.VariableNames())
        return @oCoeffExtractor.extractAllCoefficients(cExpression)

    # Returns the probability-weighted sum, over the scenarios, of the absolute coefficients of a variable in the constraints that apply.
    #
    #   _cVarName_   the variable's name
    #   returns      a number
    #   see          calculateWorstCaseResourceCost, calculateChanceResourceCost
    def calculateExpectedResourceCost(_cVarName_)
        _nExpectedCost_ = 0
        _nScenarios10Len_ = len(@aScenarios)
        for _iLoopScenarios10_ = 1 to _nScenarios10Len_
        	_scenario_ = @aScenarios[_iLoopScenarios10_]
            _nScenarioCost_ = 0
            _nConstraints6Len_ = len(@aConstraints)
            for _iLoopConstraints6_ = 1 to _nConstraints6Len_
            	_const_ = @aConstraints[_iLoopConstraints6_]
                if _const_[:scenario] = "all" or _const_[:scenario] = _scenario_[:name]
                    _cModifiedExpression_ = This.applyScenarioParameters(_const_[:expression], _scenario_[:parameters])
                    _nCoeff_ = This.extractCoefficient(_cModifiedExpression_, _cVarName_)
                    _nScenarioCost_ += abs(_nCoeff_)
                ok
            next
            _nExpectedCost_ += _nScenarioCost_ * _scenario_[:probability]
        next
        return _nExpectedCost_

    # Returns the largest, over the scenarios, of the summed absolute coefficients of a variable in the constraints that apply.
    #
    #   _cVarName_   the variable's name
    #   returns      a number
    #   see          calculateExpectedResourceCost, solveRobust
    def calculateWorstCaseResourceCost(_cVarName_)
        _nWorstCost_ = 0
        _nScenarios9Len_ = len(@aScenarios)
        for _iLoopScenarios9_ = 1 to _nScenarios9Len_
        	_scenario_ = @aScenarios[_iLoopScenarios9_]
            _nScenarioCost_ = 0
            _nConstraints5Len_ = len(@aConstraints)
            for _iLoopConstraints5_ = 1 to _nConstraints5Len_
            	_const_ = @aConstraints[_iLoopConstraints5_]
                if _const_[:scenario] = "all" or _const_[:scenario] = _scenario_[:name]
                    _cModifiedExpression_ = This.applyScenarioParameters(_const_[:expression], _scenario_[:parameters])
                    _nCoeff_ = This.extractCoefficient(_cModifiedExpression_, _cVarName_)
                    _nScenarioCost_ += abs(_nCoeff_)
                ok
            next
            if _nScenarioCost_ > _nWorstCost_ _nWorstCost_ = _nScenarioCost_ ok
        next
        return _nWorstCost_

    # Returns the probability-weighted resource cost of a variable, each constraint weighted by its chance against the confidence level.
    #
    #   _cVarName_   the variable's name
    #   returns      a number
    #   see          calculateExpectedResourceCost, setConfidenceLevel
    def calculateChanceResourceCost(_cVarName_)
        # Use confidence level to weight resource costs
        _nWeightedCost_ = 0
        _nScenarios8Len_ = len(@aScenarios)
        for _iLoopScenarios8_ = 1 to _nScenarios8Len_
        	_scenario_ = @aScenarios[_iLoopScenarios8_]
            _nScenarioCost_ = 0
            _nConstraints4Len_ = len(@aConstraints)
            for _iLoopConstraints4_ = 1 to _nConstraints4Len_
            	_const_ = @aConstraints[_iLoopConstraints4_]
                if _const_[:scenario] = "all" or _const_[:scenario] = _scenario_[:name]
                    _cModifiedExpression_ = This.applyScenarioParameters(_const_[:expression], _scenario_[:parameters])
                    _nCoeff_ = This.extractCoefficient(_cModifiedExpression_, _cVarName_)
                    _nWeight_ = iff(_const_[:chance] >= @nConfidenceLevel, 1, _const_[:chance]/@nConfidenceLevel)
                    _nScenarioCost_ += abs(_nCoeff_) * _nWeight_
                ok
            next
            _nWeightedCost_ += _nScenarioCost_ * _scenario_[:probability]
        next
        return _nWeightedCost_

    # Returns the smallest probability-weighted scenario limit on a variable, never below 0.
    #
    #   _cVarName_    the variable's name
    #   _aSolution_   a list of [ name, value ] pairs for the other variables
    #   returns       a number
    #   note          the weighting by probability makes the limit smaller than any single scenario
    #                 allows
    #   warning       built on calculateScenarioMaxValue, so it answers 399999.6 for a variable
    #                 whose scenario limit is really 4 and 6: the weighting multiplies the 999999
    #                 that means no limit
    #   see           calculateScenarioMaxValue, solveExpectedValue
    def calculateExpectedMaxValue(_cVarName_, _aSolution_)
        _nMinLimit_ = 999999
        _nScenarios7Len_ = len(@aScenarios)
        for _iLoopScenarios7_ = 1 to _nScenarios7Len_
        	_scenario_ = @aScenarios[_iLoopScenarios7_]
            _nScenarioLimit_ = This.calculateScenarioMaxValue(_cVarName_, _aSolution_, _scenario_)
            _nWeightedLimit_ = _nScenarioLimit_ * _scenario_[:probability]
            if _nWeightedLimit_ < _nMinLimit_ _nMinLimit_ = _nWeightedLimit_ ok
        next
        return max([0, _nMinLimit_])

    # Returns the smallest scenario limit on a variable, reduced by the robustness factor, never below 0.
    #
    #   _cVarName_    the variable's name
    #   _aSolution_   a list of [ name, value ] pairs for the other variables
    #   returns       a number
    #   warning       built on calculateScenarioMaxValue, so it answers 899999.1 where the limit is
    #                 really 4 and 6
    #   see           calculateScenarioMaxValue, setRobustnessFactor
    def calculateRobustMaxValue(_cVarName_, _aSolution_)
        _nMinLimit_ = 999999
        _nScenarios6Len_ = len(@aScenarios)
        for _iLoopScenarios6_ = 1 to _nScenarios6Len_
        	_scenario_ = @aScenarios[_iLoopScenarios6_]
            _nScenarioLimit_ = This.calculateScenarioMaxValue(_cVarName_, _aSolution_, _scenario_)
            _nRobustLimit_ = _nScenarioLimit_ * (1 - @nRobustnessFactor)
            if _nRobustLimit_ < _nMinLimit_ _nMinLimit_ = _nRobustLimit_ ok
        next
        return max([0, _nMinLimit_])

    # Returns the scenario limit on a variable at which the cumulated probability, from the smallest limit up, reaches the confidence level.
    #
    #   _cVarName_    the variable's name
    #   _aSolution_   a list of [ name, value ] pairs for the other variables
    #   returns       a number, never below 0
    #   warning       built on calculateScenarioMaxValue, so it answers 999999 where the limit is
    #                 really 4 and 6
    #   see           calculateScenarioMaxValue, setConfidenceLevel
    def calculateChanceMaxValue(_cVarName_, _aSolution_)
        _aLimits_ = []
        _nScenarios5Len_ = len(@aScenarios)
        for _iLoopScenarios5_ = 1 to _nScenarios5Len_
        	_scenario_ = @aScenarios[_iLoopScenarios5_]
            _nScenarioLimit_ = This.calculateScenarioMaxValue(_cVarName_, _aSolution_, _scenario_)
            _aLimits_ + [_nScenarioLimit_, _scenario_[:probability]]
        next
        
        # Sort limits and find confidence level cutoff
        _aLimits_ = sorton(_aLimits_, 1)
        _nCumProb_ = 0
        _nLimits1Len_ = len(_aLimits_)
        for _iLoopLimits1_ = 1 to _nLimits1Len_
        	_limit_ = _aLimits_[_iLoopLimits1_]
            _nCumProb_ += _limit_[2]
            if _nCumProb_ >= @nConfidenceLevel
                return max([0, _limit_[1]])
            ok
        next
        return max([0, _aLimits_[len(_aLimits_)][1]])

    # Returns the largest value a variable can take in one scenario, given the values of the others, from the constraints that apply.
    #
    #   _cVarName_    the variable's name
    #   _aSolution_   a list of [ name, value ] pairs for the other variables
    #   _scenario_    a scenario, as returned by scenarios
    #   returns       a number
    #   warning       it answers 999999, meaning no limit, for every constraint with "<=", ">=" or
    #                 "=": the switch labelled on "=" or "<=" matches none of the operators; one
    #                 variable x with x <= 6, x >= 6 or x = 6 gives 999999 each time
    #   see           calculateExpectedMaxValue, solveForScenario
    def calculateScenarioMaxValue(_cVarName_, _aSolution_, _scenario_)
        _nMinLimit_ = 999999
        _nConstraints3Len_ = len(@aConstraints)
        for _iLoopConstraints3_ = 1 to _nConstraints3Len_
        	_const_ = @aConstraints[_iLoopConstraints3_]
            if _const_[:scenario] = "all" or _const_[:scenario] = _scenario_[:name]
                _cModifiedExpression_ = This.applyScenarioParameters(_const_[:expression], _scenario_[:parameters])
                _nModifiedValue_ = This.evaluateConstraintValue(_const_[:value], _scenario_)  # Enhanced to handle string values
                _nCoeff_ = This.extractCoefficient(_cModifiedExpression_, _cVarName_)
                if _nCoeff_ != 0
                    _nUsedResources_ = 0
                    _aThisvariableNames2_ = This.variableNames()
                    _nThisvariableNames2Len_ = len(_aThisvariableNames2_)
                    for _iLoopThisvariableNames2_ = 1 to _nThisvariableNames2Len_
                    	_var_ = _aThisvariableNames2_[_iLoopThisvariableNames2_]
                        if _var_ != _cVarName_
                            _nVarCoeff_ = This.extractCoefficient(_cModifiedExpression_, _var_)
                            _nVarValue_ = This.getSolutionValue(_aSolution_, _var_)
                            _nUsedResources_ += _nVarCoeff_ * _nVarValue_
                        ok
                    next
                    _nRemainingCapacity_ = _nModifiedValue_ - _nUsedResources_
                    switch _const_[:operator]
                    on "=" or "<="
                        if _nCoeff_ > 0
                            _nLimit_ = _nRemainingCapacity_ / _nCoeff_
                            if _nLimit_ < _nMinLimit_ _nMinLimit_ = _nLimit_ ok
                        ok
                    off
                ok
            ok
        next
        return _nMinLimit_

    # Returns the objective expression of the first scenario, with its parameters replaced.
    #
    #   returns    a text
    #   warning    it does not look for a worst case: it keeps the first scenario's objective, as
    #              its comment says
    #   see        solveRobust, applyScenarioParameters
    def getWorstCaseObjective()
        _cWorstObjective_ = @cObjective
        _nWorstValue_ = iff(@cObjectiveType = "maximize", -999999, 999999)
        
        _nScenarios4Len_ = len(@aScenarios)
        for _iLoopScenarios4_ = 1 to _nScenarios4Len_
        	_scenario_ = @aScenarios[_iLoopScenarios4_]
            _cScenarioObjective_ = This.applyScenarioParameters(@cObjective, _scenario_[:parameters])
            # For simplicity, return the first scenario's objective
            # In practice, would need more sophisticated worst-case analysis
            if _scenario_ = @aScenarios[1]
                _cWorstObjective_ = _cScenarioObjective_
            ok
        next
        return _cWorstObjective_

    # Returns a solution for one scenario, filling the variables in declaration order with the largest value the limits and the upper bound allow.
    #
    #   _scenario_   a scenario, as returned by scenarios
    #   returns      a list of [ name, value ] pairs, one per variable
    #   warning      the constraints do not limit anything today (calculateScenarioMaxValue), so
    #                every variable comes back at its upper bound: with x + y <= d it answered 10
    #                and 10
    #   see          solveMonteCarlo, calculateScenarioMaxValue
    def solveForScenario(_scenario_)
        _aVarNames_ = This.variableNames()
        _aSolution_ = []
        
        # Initialize solution
        _nVariablesLen_ = len(@aVariables)
        for i = 1 to _nVariablesLen_
            _aSolution_ + [_aVarNames_[i], @aVariables[i][:lowerBound]]
        next
        
        # Solve using this scenario's parameters
        _cScenarioObjective_ = This.applyScenarioParameters(@cObjective, _scenario_[:parameters])
        _aCoeffs_ = This.parseObjectiveCoefficients(_cScenarioObjective_)
        
        # Simple greedy assignment
        _nVarNamesLen_ = len(_aVarNames_)
        for i = 1 to _nVarNamesLen_
            _cVarName_ = _aVarNames_[i]
            _nMaxPossible_ = This.calculateScenarioMaxValue(_cVarName_, _aSolution_, _scenario_)
            _nUpperBound_ = @aVariables[i][:upperBound]
            _nValue_ = min([_nMaxPossible_, _nUpperBound_])
            _aSolution_[i][2] = _nValue_
        next
        
        return _aSolution_

    # Returns the objective's value for a solution under one scenario's parameters.
    #
    #   _aSolution_   a list of [ name, value ] pairs
    #   _scenario_    a scenario, as returned by scenarios
    #   returns       a number
    #   note          3*x + 2*y with x = 1 and y = 2 gives 7
    #   see           expectedObjectiveValue, analyzeScenarios
    def calculateScenarioObjectiveValue(_aSolution_, _scenario_)
        _cScenarioObjective_ = This.applyScenarioParameters(@cObjective, _scenario_[:parameters])
        _nResult_ = 0
        _nVariables2Len_ = len(@aVariables)
        for _iLoopVariables2_ = 1 to _nVariables2Len_
        	_var_ = @aVariables[_iLoopVariables2_]
            _nValue_ = This.getSolutionValue(_aSolution_, _var_[:name])
            _nCoeff_ = This.extractCoefficient(_cScenarioObjective_, _var_[:name])
            _nResult_ += _nCoeff_ * _nValue_
        next
        return _nResult_

    # Returns the value of one variable in a list of [ name, value ] pairs.
    #
    #   _aSolution_   a list of [ name, value ] pairs
    #   _cVarName_    the variable's name
    #   returns       a number; 0 when the name is not in the list
    #   see           calculateScenarioObjectiveValue
    def getSolutionValue(_aSolution_, _cVarName_)
        _nSolution3Len_ = len(_aSolution_)
        for _iLoopSolution3_ = 1 to _nSolution3Len_
        	_sol_ = _aSolution_[_iLoopSolution3_]
            if _sol_[1] = _cVarName_ return _sol_[2] ok
        next
        return 0

    # Returns, for each scenario, the objective value and the feasibility of the stored solution.
    #
    #   returns    a list of lists of scenario, probability, objectivevalue and feasible pairs
    #   warning    raises an error when no solution is stored, so call solve first
    #   see        checkScenarioFeasibility, expectedObjectiveValue, exportScenarioAnalysis
    #@ aka  Analysis Methods
    def analyzeScenarios()
        if len(@aSolution) = 0 stzRaise("No solution available! Call solve() first.") ok
        
        _aScenarioResults_ = []
        _nScenarios3Len_ = len(@aScenarios)
        for _iLoopScenarios3_ = 1 to _nScenarios3Len_
        	_scenario_ = @aScenarios[_iLoopScenarios3_]
            _nObjectiveValue_ = This.calculateScenarioObjectiveValue(@aSolution, _scenario_)
            _bFeasible_ = This.checkScenarioFeasibility(@aSolution, _scenario_)
            _aScenarioResults_ + [ :scenario = _scenario_[:name], :probability = _scenario_[:probability], 
                               :objectiveValue = _nObjectiveValue_, :feasible = _bFeasible_ ]
        next
        return _aScenarioResults_

    # TRUE if a solution satisfies every constraint that applies in one scenario, within 0.001.
    #
    #   _aSolution_   a list of [ name, value ] pairs
    #   _scenario_    a scenario, as returned by scenarios
    #   returns       TRUE or FALSE
    #   note          with 2*x + y <= d, d = 4, x = 1 and y = 2 it is TRUE and with x = 2 and y = 2
    #                 it is FALSE
    #   see           analyzeScenarios, addScenarioConstraint
    def checkScenarioFeasibility(_aSolution_, _scenario_)
        _nConstraints2Len_ = len(@aConstraints)
        for _iLoopConstraints2_ = 1 to _nConstraints2Len_
        	_const_ = @aConstraints[_iLoopConstraints2_]
            if _const_[:scenario] = "all" or _const_[:scenario] = _scenario_[:name]
                _cModifiedExpression_ = This.applyScenarioParameters(_const_[:expression], _scenario_[:parameters])
                _nModifiedValue_ = This.evaluateConstraintValue(_const_[:value], _scenario_)  # Enhanced to handle string values
                
                _nLHS_ = 0
                _aThisvariableNames1_ = This.variableNames()
                _nThisvariableNames1Len_ = len(_aThisvariableNames1_)
                for _iLoopThisvariableNames1_ = 1 to _nThisvariableNames1Len_
                	_var_ = _aThisvariableNames1_[_iLoopThisvariableNames1_]
                    _nCoeff_ = This.extractCoefficient(_cModifiedExpression_, _var_)
                    _nVarValue_ = This.getSolutionValue(_aSolution_, _var_)
                    _nLHS_ += _nCoeff_ * _nVarValue_
                next
                
                _nRHS_ = _nModifiedValue_
                switch _const_[:operator]
                on "<="
                    if _nLHS_ > _nRHS_ + 0.001 return 0 ok
                on ">="  
                    if _nLHS_ < _nRHS_ - 0.001 return 0 ok
                on "="
                    if abs(_nLHS_ - _nRHS_) > 0.001 return 0 ok
                off
            ok
        next
        return 1

    # Returns the probability-weighted objective value of the stored solution over all scenarios.
    #
    #   returns    a number; 0 before any solve
    #   see        analyzeScenarios, calculateScenarioObjectiveValue
    def expectedObjectiveValue()
        if len(@aSolution) = 0 return 0 ok
        
        _nExpectedValue_ = 0
        _nScenarios2Len_ = len(@aScenarios)
        for _iLoopScenarios2_ = 1 to _nScenarios2Len_
        	_scenario_ = @aScenarios[_iLoopScenarios2_]
            _nScenarioValue_ = This.calculateScenarioObjectiveValue(@aSolution, _scenario_)
            _nExpectedValue_ += _nScenarioValue_ * _scenario_[:probability]
        next
        return _nExpectedValue_

    # Returns the solution stored by the last solve.
    #
    #   returns    a list of [ name, value ] pairs; [ ] before any solve
    #   see        solve, getSolutionValue
    #@ aka  Solution Access
    def solution()
        return @aSolution

    # Returns how the last solve ended.
    #
    #   returns    the text optimal after a solve; "" before
    #   see        solve
    def status()
        return @cStatus

    # Returns the work counted by the last solve: the number of variables, set by the expected solver only.
    #
    #   returns    a number; 0 before any solve or for the other solver types
    #   see        solve
    def iterations()
        return @nIterations

    # Returns the time the last solve took, in seconds.
    #
    #   returns    a number; 0 before any solve
    #   see        solve
    def solveTime()
        return @nSolveTime

    # Returns the solver type in force.
    #
    #   returns    the text expected, robust, chance or montecarlo; expected by default
    #   see        setSolverType
    def solverType()
        return @cSolverType

    # Prints the problem, its scenarios and, once solved, the solution, the expected objective and the analysis of every scenario.
    #
    #   returns    nothing; it prints to the console
    #   see        exportToCSV, exportScenarioAnalysis, analyzeScenarios
    #@ aka  Display and Reporting
    def show()

        ? BoxRound("Stochastic Programming Problem")
        ? "• Variables:"
        _nVariables1Len_ = len(@aVariables)
        for _iLoopVariables1_ = 1 to _nVariables1Len_
        	_var_ = @aVariables[_iLoopVariables1_]
            ? " ─ " + _var_[:name] + " ∈ [" + _var_[:lowerBound] + ", " + _var_[:upperBound] + "] (" + _var_[:type] + ")"
        next

		? ""
        ? "• Objective:"  
        ? "╰─> " + upper(@cObjectiveType) + " " + @cObjective

		? ""
        ? "• Scenarios:"
        _nScenarios1Len_ = len(@aScenarios)
        for _iLoopScenarios1_ = 1 to _nScenarios1Len_
        	_scenario_ = @aScenarios[_iLoopScenarios1_]
            ? " ─ " + _scenario_[:name] + ": " + _scenario_[:description] + " (p=" + _scenario_[:probability] + ")"
            _aScenarioparameters1_ = _scenario_[:parameters]
            _nScenarioparameters1Len_ = len(_aScenarioparameters1_)
            for _iLoopScenarioparameters1_ = 1 to _nScenarioparameters1Len_
            	param = _aScenarioparameters1_[_iLoopScenarioparameters1_]
                ? " ╰─> " + param[1] + " = " + param[2]
            next
			? ""
        next

        ? "• Constraints:"
        _nConstraints1Len_ = len(@aConstraints)
        for _iLoopConstraints1_ = 1 to _nConstraints1Len_
        	_const_ = @aConstraints[_iLoopConstraints1_]
            _cScenarioInfo_ = iff(_const_[:scenario] != "all", " [" + _const_[:scenario] + "]", "")
            _cChanceInfo_ = iff(_const_[:chance] < 1.0, " (chance=" + _const_[:chance] + ")", "")
            ? " ─ " + _const_[:expression] + " " + _const_[:operator] + " " + _const_[:value] + _cScenarioInfo_ + _cChanceInfo_
        next

		? ""
        if @cStatus != ""
            ? BoxRound("Solution")
            ? "• Status: " + @cStatus
            ? "• Solver: " + @cSolverType
            ? "• Solved in " + @nSolveTime + " second(s)"

			? ""
            ? "• Variable Values:"
            _nSolution2Len_ = len(@aSolution)
            for _iLoopSolution2_ = 1 to _nSolution2Len_
            	_sol_ = @aSolution[_iLoopSolution2_]
                ? " ─ " + _sol_[1] + " = " + _sol_[2]
            next

			? ""
            ? "• Expected Objective Value: " + This.expectedObjectiveValue()

			? ""
            ? "• Scenario Analysis:"
            _aResults_ = This.analyzeScenarios()
            _nResults2Len_ = len(_aResults_)
            for _iLoopResults2_ = 1 to _nResults2Len_
            	_result_ = _aResults_[_iLoopResults2_]
                _cFeasible_ = iff(_result_[:feasible], "✓", "✗")
                ? " ─ " + _result_[:scenario] + " (p=" + _result_[:probability] + "): " + _result_[:objectiveValue] + " " + _cFeasible_
            next
        ok

    # Writes the stored solution to a file, one Variable,Value line per variable.
    #
    #   cFileName   the path of the file to write
    #   returns     nothing; the file is written
    #   see         exportScenarioAnalysis, solution
    def exportToCSV(cFileName)
        _oFile_ = new stzFile(cFileName)
        _cContent_ = "Variable,Value" + nl
        _nSolution1Len_ = len(@aSolution)
        for _iLoopSolution1_ = 1 to _nSolution1Len_
        	_sol_ = @aSolution[_iLoopSolution1_]
            _cContent_ += _sol_[1] + "," + _sol_[2] + nl
        next
        _oFile_.write(_cContent_)

    # Writes the objective value and feasibility of the stored solution for each scenario to a file.
    #
    #   cFileName   the path of the file to write
    #   returns     nothing; the file is written
    #   note        the first line is Scenario,Probability,ObjectiveValue,Feasible; it raises when
    #               nothing is solved
    #   see         exportToCSV, analyzeScenarios
    def exportScenarioAnalysis(cFileName)
        _oFile_ = new stzFile(cFileName)
        _cContent_ = "Scenario,Probability,ObjectiveValue,Feasible" + nl
        
        _aResults_ = This.analyzeScenarios()
        _nResults1Len_ = len(_aResults_)
        for _iLoopResults1_ = 1 to _nResults1Len_
        	_result_ = _aResults_[_iLoopResults1_]
            _cFeasible_ = iff(_result_[:feasible], "Yes", "No")
            _cContent_ += _result_[:scenario] + "," + _result_[:probability] + "," + _result_[:objectiveValue] + "," + _cFeasible_ + nl
        next
        
        _oFile_.write(_cContent_)
