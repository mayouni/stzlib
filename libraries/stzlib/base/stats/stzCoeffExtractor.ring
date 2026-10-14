
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
   "pow(x, 2)"            	   # x^2 -> result changes with x (at x=10, rate = 20)  
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

# Reads the coefficient of a variable in a linear expression, for the solvers that turn text into numbers.
#
# For a plain linear expression such as 5*x + 3*y - 2*z it reads each term and gives 5, 3 and -2; a
# variable written without a star has coefficient 1 or -1, an absent one 0. A non-linear expression
# is meant to be handled by nudging the variable around the point where every variable is 10, but
# that path raises today. The plain path matches names as substrings, so give variables names that
# are not parts of one another. Building it sets Ring's display precision to 4 decimals until a
# brace ends or BraceEnd is called.
#
#   receiver   o1 = new stzCoeffExtractor([ "x", "y", "z" ])
#   example    ? o1.extract("5*x + 3*y - 2*z", "z")
#              #--> -2
#              ? o1.extractAllCoefficients("5*x + 3*y - 2*z")[2]
#              #--> 3
#              ? o1.extract("3*y", "x")
#              #--> 0
#   see        stzOptimModel, stzLinearSolver, StzCoefficientExtractor
class stzCoeffExtractor from stzObject
	@aVars = []
	@nPerturbationDelta = 0.001
	

	@nInternalPrecision = 4
	@nOutsidePrecision = CurrentRound()

	# Builds an extractor for the named variables and sets Ring's display precision to 4 decimals until BraceEnd puts it back.
	#
	#   p@aVars    the list of variable names the expressions may use
	#   returns    nothing; the object is built
	#   warning    the precision is global to the program and stays at 4 unless the object is used
	#              in a brace or BraceEnd is called
	#   see        extract, BraceEnd
	def init(p@aVars)
		decimals(@nInternalPrecision)
		@aVars = p@aVars
	

	# Replaces the variable names the extractor knows.
	#
	#   p@aVars    the new list of variable names
	#   returns    nothing
	#   see        VarNames, init
	def setVariableNames(p@aVars)
		@aVars = p@aVars
			
	# Sets the small step by which the numerical method nudges a variable; the default is 0.001.
	#
	#   pnDelta    the step, a small positive number
	#   returns    nothing
	#   see        numericalDerivative
	def setPerturbationDelta(pnDelta)
		@nPerturbationDelta = pnDelta
	
	# Puts Ring's display precision back to what it was when the extractor was built, at the closing of a brace.
	#
	#   returns    nothing
	#   warning    called by hand it has the same effect
	#   see        init
	def BraceEnd()
		decimals(@nOutsidePrecision)

	# Returns the coefficient of one variable in an expression, read term by term when the expression is plain linear.
	#
	#   cExpression   the expression text, such as 5*x + 3*y - 2*z
	#   _cVarName_    the variable whose coefficient is wanted
	#   returns       a number; 0 when the name does not appear
	#   note          ExtractCoefficient and ExtractCoeff are the same call
	#   warning       an expression with /, pow, sqrt, max, min or abs raises R42 Error in eval()
	#                 function today, because evaluateExpression builds an empty formula (see it);
	#                 the plain path reads variable names as substrings, so for 5*xx + 2*x it
	#                 answers 5 for x, and a repeated variable gives only its first term
	#   see           extractAllCoefficients, trySimpleExtraction, numericalDerivative
	#@ aka  Main method: Extract coefficient
	def extract(cExpression, _cVarName_)

		_nResult_ = 0

		if not ring_substr1(cExpression, _cVarName_)
			return 0
			return _nResult_
		ok
		
		# Try simple pattern matching first (for performance)
		_nSimpleCoeff_ = This.trySimpleExtraction(cExpression, _cVarName_)
		if _nSimpleCoeff_ != ""
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


	# Returns the coefficient when the expression is plain linear, and an empty text when it is not, which tells extract to differentiate.
	#
	#   cExpression   the expression text
	#   _cVarName_    the variable
	#   returns       a number, or an empty text for a non-linear expression
	#   warning       the same substring reading of names as extract
	#   see           extract, isSimpleLinearExpression
	#@ aka  Fast path for simple linear expressions
	def trySimpleExtraction(cExpression, _cVarName_)
		_cExpr_ = This.normalizeExpression(cExpression)
		
		# Check if it's a simple linear form
		if This.isSimpleLinearExpression(_cExpr_)
			return This.extractLinearCoefficient(_cExpr_, _cVarName_)
		ok
		
		return ""  # Indicates need for numerical method
	
	# Returns the expression with its spaces and tabs removed.
	#
	#   cExpression   the expression text
	#   returns       a text such as 5*x+3
	#   see           trySimpleExtraction
	def normalizeExpression(cExpression)
		_cExpr_ = @trim(cExpression)
		_cExpr_ = StzReplace(_cExpr_, " ", "")  # Remove spaces
		_cExpr_ = StzReplace(_cExpr_, "\t", "") # Remove tabs
		return _cExpr_
	
	# TRUE if the expression has none of min(, max(, abs(, sqrt(, pow(, a slash or a caret, so it can be read term by term.
	#
	#   cExpression   the expression text, already without spaces
	#   returns       1 or 0, numbers
	#   see           trySimpleExtraction, normalizeExpression
	def isSimpleLinearExpression(cExpression)
		# Check if expression contains only +, -, *, numbers, and variables
		# No functions, parentheses (except simple grouping), or complex operations
		
		# Quick heuristic: if it contains function calls or complex operators, it's not simple
		if ring_substr1(cExpression, "min(") or ring_substr1(cExpression, "max(") or
		   ring_substr1(cExpression, "abs(") or ring_substr1(cExpression, "sqrt(") or
		   ring_substr1(cExpression, "/") or ring_substr1(cExpression, "pow(") or
		   ring_substr1(cExpression, "^")
			return 0
		ok
		
		return 1
	
	# Returns the number before the star in the first term that mentions the variable; 1 or -1 when none, 0 when no term.
	#
	#   cExpression   the expression text without spaces
	#   _cVarName_    the variable
	#   returns       a number
	#   warning       the first term containing the name as a substring wins, so xx is taken for x
	#   see           trySimpleExtraction
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
	

	# Raises error R42 today instead of returning the slope of the expression along one variable at the test point 10.
	#
	#   cExpression   the expression text
	#   _cVarName_    the variable to nudge
	#   returns       nothing; it raises
	#   note          the intended result rounded as roundCoefficient does
	#   warning       every call raises R42 Error in eval() function (checked on x/8 + y/4 and
	#                 pow(x, 2)), because evaluateExpression builds an empty formula
	#   see           extract, setPerturbationDelta, evaluateExpression
	#@ aka  Numerical differentiation for complex expressions
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
	

	# Returns the point where non-linear expressions are tested: every variable at 10.
	#
	#   returns    a list of [ name, 10 ] pairs
	#   see        numericalDerivative, evaluateExpression
	def createTestValues()
		_aValues_ = []
		_nVars2Len_ = len(@aVars)
		for _iLoopVars2_ = 1 to _nVars2Len_
			_cVarName_ = @aVars[_iLoopVars2_]
			_aValues_[_cVarName_] = 10.0  # Use 10.0 to avoid min() saturation
		next
		return _aValues_


	# Raises error R42 today instead of returning the value of an expression at a point.
	#
	#   cExpression   the expression text
	#   aVarValues    a list of [ name, value ] pairs
	#   returns       nothing; it raises
	#   warning       the variables are replaced by calling ManyReplaced with a list of new texts,
	#                 which takes ONE new text and returns an empty text, so the evaluated formula
	#                 is empty and eval fails with a syntax error (checked on x + y and x + 1)
	#   see           numericalDerivative, createTestValues
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

	
	# Returns a coefficient rounded to six decimals, as a whole number when it is within a millionth of one.
	#
	#   _nCoeff_   the raw number to tidy
	#   returns    a number
	#   note       2.0000001 gives 2
	#   see        numericalDerivative
	def roundCoefficient(_nCoeff_)
		# Round to reasonable precision to avoid floating point artifacts
		_nRounded_ = floor(_nCoeff_ * 1000000 + 0.5) / 1000000
		
		# If very close to integer, return integer
		if abs(_nRounded_ - floor(_nRounded_ + 0.5)) < 0.000001
			return floor(_nRounded_ + 0.5)
		ok
		
		return _nRounded_
	

	# Returns the variable names the extractor knows.
	#
	#   returns    a list of text
	#   note       VariableNames is the same call
	#   see        setVariableNames
	def VarNames()
		_nLen_ = len(@aVars)
		_acResult_ = []

		for i = 1 to _nLen_
			_acResult_ + @aVars[i]
		next

		return _acResult_

		def VariableNames()
			return This.VarNames()

	# Returns the coefficient of every known variable in the expression, in the order of the names.
	#
	#   cExpression   the expression text
	#   returns       a list of numbers
	#   warning       the same limits as extract for non-linear expressions
	#   see           extract, VarNames
	#@ aka  Batch extraction for all variables
	def extractAllCoefficients(cExpression)
		_aCoeffs_ = []
		_acVarNames_ = This.VarNames()

		_nAcVarNames1Len_ = len(_acVarNames_)
		for _iLoopAcVarNames1_ = 1 to _nAcVarNames1Len_
			_cVarName_ = _acVarNames_[_iLoopAcVarNames1_]
			_aCoeffs_ + This.extractCoefficient(cExpression, _cVarName_)
		next
		return _aCoeffs_
	
	# Returns 0 for every expression today instead of telling whether it can be evaluated.
	#
	#   cExpression   the expression text
	#   returns       0, a number
	#   warning       it calls createTestValues with an argument that method does not take, which
	#                 raises inside its try, so the answer is always 0 (checked on x + 1 and x + y)
	#   see           evaluateExpression
	#@ aka  Utility method to validate expression
	def validateExpression(cExpression)
		try
			_aTestValues_ = This.createTestValues(cExpression)
			This.evaluateExpression(cExpression, _aTestValues_)
			return 1
		catch
			return 0
		done
