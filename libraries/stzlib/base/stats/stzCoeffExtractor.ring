
# A utility class used by the various class solvers
# to extract the coefficient of a given variable in an expression

# - Simple linear: Basic a*x + b*y forms
# - Negative coefficients: Handling minus signs
# - Implicit coefficients: Variables without explicit multipliers
# - Complex functions: min/max, division, power, abs, sqrt
# - Edge cases: Zero coefficients, substring variables, formatting
# - Batch operations: All coefficients at once
# - Validation: Expression correctness checking

#NOTE The numerical differentiation approach handles the complex
# cases that pattern matching can't, while the fast path efficiently
# processes simple linear expressions.
# What works well:
#-----------------

# Use simple math formulas (called *linear expressions*).  
# They give clear and constant values for each variable.

# Examples:
   "5*x + 3*y - 2*z"       # x = 5, y = 3, z = -2  
   "x + 2.5*price"         # x = 1, price = 2.5  
   "staff/8 + overtime/4"  # staff = 0.125, overtime = 0.25  

# What can confuse you:
#----------------------

# Some formulas are *nonlinear* or *conditional*, so results change
# depending on the value of the variables.

# Examples:
   "pow(x, 2)"            	   # xÂ² â†’ result changes with x (at x=10, rate = 20)  
   "sqrt(area)"                # rate changes depending on area  
   "max([0, profit-1000])"     # rate is 0 if profit < 1000, 1 if profit > 1000

# Important to know:
#-------------------

# These advanced formulas are tested using the number 10 for each variable.  
# If you change the test number, the result changes too.

# Advice:
#--------

# Think of the result as showing 'how sensitive' the output is when
# you change each variable 'a little bit'.

# This is helpful for 'analysis', but not for 'pure linear optimization'.

# For safe use:
#--------------

# Stick to simple formulas if you're doing classic optimization.
# See stzCoeffExtractorTest.ring file for samples.


# A utility class used by the various class solvers
# to extract the coefficient of a given variable in an expression



class StzCoefficientExtractor from stzCoeffExtractor

class stzCoeffExtractor from stzObject
	@aVars = []
	@nPerturbationDelta = 0.001
	

	@nInternalPrecision = 4
	@nOutsidePrecision = CurrentRound()

	def init(p@aVars)
		decimals(@nInternalPrecision)
		@aVars = p@aVars
	

	def setVariableNames(p@aVars)
		@aVars = p@aVars
			
	def setPerturbationDelta(pnDelta)
		@nPerturbationDelta = pnDelta
	
	def BraceEnd()
		decimals(@nOutsidePrecision)

	# Main method: Extract coefficient
	def extract(cExpression, _cVarName_)

		_nResult_ = 0

		if not ring_substr1(cExpression, _cVarName_)
			return 0
			return _nResult_
		ok
		
		# Try simple pattern matching first (for performance)
		_nSimpleCoeff_ = This.trySimpleExtraction(cExpression, _cVarName_)
		if _nSimpleCoeff_ != NULL
			return _nSimpleCoeff_
			_nResult_ = _nSimpleCoeff_
		ok
		
		# Fall back to numerical differentiation
		return This.numericalDerivative(cExpression, _cVarName_)
	
		_nResult_ = This.numericalDerivative(cExpression, _cVarName_)
		return _nResult_
	
		def ExtractCoefficient(cExpression, _cVarName_)
			return This.Extract(cExpression, _cVarName_)

		def ExtractCoeff(cExpression, _cVarName_)
			return This.Extract(cExpression, _cVarName_)


	# Fast path for simple linear expressions
	def trySimpleExtraction(cExpression, _cVarName_)
		_cExpr_ = This.normalizeExpression(cExpression)
		
		# Check if it's a simple linear form
		if This.isSimpleLinearExpression(_cExpr_)
			return This.extractLinearCoefficient(_cExpr_, _cVarName_)
		ok
		
		return NULL  # Indicates need for numerical method
	
	def normalizeExpression(cExpression)
		_cExpr_ = @trim(cExpression)
		_cExpr_ = StzReplace(_cExpr_, " ", "")  # Remove spaces
		_cExpr_ = StzReplace(_cExpr_, "\t", "") # Remove tabs
		return _cExpr_
	
	def isSimpleLinearExpression(cExpression)
		# Check if expression contains only +, -, *, numbers, and variables
		# No functions, parentheses (except simple grouping), or complex operations
		
		# Quick heuristic: if it contains function calls or complex operators, it's not simple
		if ring_substr1(cExpression, "min(") or ring_substr1(cExpression, "max(") or
		   ring_substr1(cExpression, "abs(") or ring_substr1(cExpression, "sqrt(") or
		   ring_substr1(cExpression, "/") or ring_substr1(cExpression, "pow(") or
		   ring_substr1(cExpression, "^")
			return FALSE
		ok
		
		return TRUE
	
	def extractLinearCoefficient(cExpression, _cVarName_)
		_cExpr_ = StzReplace(cExpression, "-", "+-")  # Handle negative terms
		_acTerms_ = @split(_cExpr_, "+")
		_nLen_ = len(_acTerms_)

		for i = 1 to _nLen_
			_cTerm_ = @trim(_acTerms_[i])
			if _cTerm_ = "" loop ok
			
			if ring_substr1(_cTerm_, _cVarName_)
				if ring_substr1(_cTerm_, "*")
					# Extract coefficient before *
					_nPos_ = ring_substr1(_cTerm_, "*")

					_cCoeff_ = trim(@StzMid(_cTerm_, 1, _nPos_-1))
					if _cCoeff_ = "" or _cCoeff_ = "+"
						return 1
					ok
					if _cCoeff_ = "-"
						return -1
					ok
					return 0 + _cCoeff_
				else
					# Variable without explicit coefficient
					if StzLeft(_cTerm_, 1) = "-"
						return -1
					ok
					return 1
				ok
			ok
		next
		
		return 0
	

	# Numerical differentiation for complex expressions

	def numericalDerivative(cExpression, _cVarName_)
		# Create test values for all variables
		_aTestValues_ = This.createTestValues()
		
		# Evaluate at base point
		_nBaseValue_ = This.evaluateExpression(cExpression, _aTestValues_)
		
		# Perturb the target variable and evaluate again
		_aTestValues_[_cVarName_] = _aTestValues_[_cVarName_] + @nPerturbationDelta
		_nPerturbedValue_ = This.evaluateExpression(cExpression, _aTestValues_)
		
		# Calculate numerical derivative (coefficient)
		_nCoeff_ = (_nPerturbedValue_ - _nBaseValue_) / @nPerturbationDelta
		
		# Round to handle floating point precision issues
		return This.roundCoefficient(_nCoeff_)
	

	def createTestValues()
		_aValues_ = []
		_nVars2Len_ = len(@aVars)
		for _iLoopVars2_ = 1 to _nVars2Len_
			_cVarName_ = @aVars[_iLoopVars2_]
			_aValues_[_cVarName_] = 10.0  # Use 10.0 to avoid min() saturation
		next
		return _aValues_


	def evaluateExpression(cExpression, aVarValues)
	    # Prepare replacement pairs
	    _acSubStr_ = []
		_acNewSubStr_ = []

	    _nVars1Len_ = len(@aVars)
	    for _iLoopVars1_ = 1 to _nVars1Len_
	    	_cVarName_ = @aVars[_iLoopVars1_]
	        if ring_substr1(cExpression, _cVarName_)
	            _acSubStr_ + _cVarName_
				_acNewSubStr_ + @@(aVarValues[_cVarName_])
	        ok
	    next
	    
	    # Use StzStringQ for safe replacement
	    _cEvalExpr_ = "_nResult_ = (" +
			StzStringQ(cExpression).ManyReplaced(_acSubStr_, _acNewSubStr_) + " )"
		_cEvalExpr_ = "_nResult_ = " +
    	StzStringQ(cExpression).ManyReplaced(_acSubStr_, _acNewSubStr_)

	    eval(_cEvalExpr_)
		eval(_cEvalExpr_)
	    return _nResult_

	
	def roundCoefficient(_nCoeff_)
		# Round to reasonable precision to avoid floating point artifacts
		_nRounded_ = floor(_nCoeff_ * 1000000 + 0.5) / 1000000
		
		# If very close to integer, return integer
		if abs(_nRounded_ - floor(_nRounded_ + 0.5)) < 0.000001
			return floor(_nRounded_ + 0.5)
		ok
		
		return _nRounded_
	

	def VarNames()
		_nLen_ = len(@aVars)
		_acResult_ = []

		for i = 1 to _nLen_
			_acResult_ + @aVars[i]
		next

		return _acResult_

		def VariableNames()
			return This.VarNames()

	# Batch extraction for all variables
	def extractAllCoefficients(cExpression)
		_aCoeffs_ = []
		_acVarNames_ = This.VarNames()

		_nAcVarNames1Len_ = len(_acVarNames_)
		for _iLoopAcVarNames1_ = 1 to _nAcVarNames1Len_
			_cVarName_ = _acVarNames_[_iLoopAcVarNames1_]
			_aCoeffs_ + This.extractCoefficient(cExpression, _cVarName_)
		next
		return _aCoeffs_
	
	# Utility method to validate expression
	def validateExpression(cExpression)
		try
			_aTestValues_ = This.createTestValues(cExpression)
			This.evaluateExpression(cExpression, _aTestValues_)
			return TRUE
		catch
			return FALSE
		done
