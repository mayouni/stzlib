
/*
    stzStochasticSolver - Enhanced Stochastic Programming Component for Softanza
    Author: Softanza Team
    Version: 1.1
    Features: _scenario_-based optimization, robust optimization, uncertainty modeling, string constraint values
*/

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
    def addVariable(_varName_, lowerBound, upperBound)
        if NOT isString(_varName_) stzRaise("Variable name must be a string!") ok
        if NOT (isNumber(lowerBound) and isNumber(upperBound)) stzRaise("Bounds must be numbers!") ok
        if upperBound < lowerBound stzRaise("Upper bound must be >= lower bound!") ok

        @aVariables + [ :name = _varName_, :lowerBound = lowerBound, :upperBound = upperBound, :type = "continuous" ]
        return this

    def addIntegerVariable(_varName_, lowerBound, upperBound)
        This.addVariable(_varName_, lowerBound, upperBound)
        @aVariables[len(@aVariables)][:type] = "integer"
        return this

    def addBinaryVariable(_varName_)
        This.addVariable(_varName_, 0, 1)
        @aVariables[len(@aVariables)][:type] = "binary"
        return this

    def variables()
        return @aVariables

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
        _nTotalProb_ = 0
        _nScenarios14Len_ = len(@aScenarios)
        for _iLoopScenarios14_ = 1 to _nScenarios14Len_
        	_scenario_ = @aScenarios[_iLoopScenarios14_]
            _nTotalProb_ += _scenario_[:probability]
        next
        if abs(_nTotalProb_ - 1.0) > 0.001 stzRaise("Scenario probabilities must sum to 1.0!") ok

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
    def evaluateConstraintValue(value, _scenario_)
        if isNumber(value)
            return value
        else
            # Apply scenario parameters to string expression
            _cEvaluated_ = This.applyScenarioParameters(string(value), _scenario_[:parameters])
            # Simple expression evaluator for basic math operations
            return This.evaluateExpression(_cEvaluated_)
        ok

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

    # Main Solving Methods
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

    # Expected Value Method
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

    # Robust Optimization
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

    # Chance-Constrained Programming
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

    # Monte Carlo Simulation
    def solveMonteCarlo()
        _nSimulations_ = 100
        _aBestSolution_ = []
        _nBestValue_ = iff(@cObjectiveType = "maximize",-999999, 999999)

        for sim = 1 to _nSimulations_
            # Sample scenario based on probabilities
            _nRand_ = random(100) / 100.0
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

    # Helper Methods
    def applyScenarioParameters(cExpression, aParameters)
        _cResult_ = cExpression
        _nParameters1Len_ = len(aParameters)
        for _iLoopParameters1_ = 1 to _nParameters1Len_
        	param = aParameters[_iLoopParameters1_]
            _cResult_ = StzStringQ(_cResult_).ReplaceAllQ(param[1], string(param[2])).Content()
        next
        return _cResult_

    def extractCoefficient(cExpression, _cVarName_)
        return @oCoeffExtractor.extractCoefficient(cExpression, _cVarName_)
	

    def parseObjectiveCoefficients(cExpression)
		@oCoeffExtractor.SetVariableNames(This.VariableNames())
        return @oCoeffExtractor.extractAllCoefficients(cExpression)

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

    def getSolutionValue(_aSolution_, _cVarName_)
        _nSolution3Len_ = len(_aSolution_)
        for _iLoopSolution3_ = 1 to _nSolution3Len_
        	_sol_ = _aSolution_[_iLoopSolution3_]
            if _sol_[1] = _cVarName_ return _sol_[2] ok
        next
        return 0

    # Analysis Methods
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
                    if _nLHS_ > _nRHS_ + 0.001 return false ok
                on ">="  
                    if _nLHS_ < _nRHS_ - 0.001 return false ok
                on "="
                    if abs(_nLHS_ - _nRHS_) > 0.001 return false ok
                off
            ok
        next
        return true

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

    def exportToCSV(cFileName)
        _oFile_ = new stzFile(cFileName)
        _cContent_ = "Variable,Value" + nl
        _nSolution1Len_ = len(@aSolution)
        for _iLoopSolution1_ = 1 to _nSolution1Len_
        	_sol_ = @aSolution[_iLoopSolution1_]
            _cContent_ += _sol_[1] + "," + _sol_[2] + nl
        next
        _oFile_.write(_cContent_)

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
