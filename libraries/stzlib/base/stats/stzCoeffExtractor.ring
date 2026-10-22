
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
# (a slash, pow, sqrt, abs, min or max) is handled by nudging the variable around the point where
# every variable is 10: x/8 + y/4 gives 0.125 and 0.25, pow(x, 2) gives 20. That path evaluates the
# text, but only after judging it: numbers, the declared variables, + - * / ( ) , and pow, sqrt, abs,
# min, max are accepted, anything else is refused with a plain error and nothing is run. The plain
# path matches names as substrings, so give variables names that are not parts of one another.
# Building it sets Ring's display precision to 4 decimals until a brace ends or BraceEnd is called.
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
	#   warning       an expression with /, pow, sqrt, max, min or abs is differentiated numerically
	#                 at the test point 10 and raises a plain error text, with nothing run, when it
	#                 is outside the accepted grammar (see judgeExpression); the plain path reads
	#                 variable names as substrings, so for 5*xx + 2*x it answers 5 for x, and a
	#                 repeated variable gives only its first term
	#   see           extractAllCoefficients, trySimpleExtraction, numericalDerivative, judgeExpression
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
		_cExpr_ = StzReplace(_cExpr_, ring_char(9), "") # Remove tabs
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
	

	# Returns the slope of an expression along one variable at the test point, by a central difference.
	#
	# Every variable is set to 10, the named one is moved up and down by the perturbation step
	# (0.001 unless setPerturbationDelta changed it), the expression is evaluated at both points
	# and the slope is (up - down) / (2 * step), rounded as roundCoefficient does. The central form
	# is exact for a straight line and for a square, and it reads the same slope on both sides of
	# a kink such as abs(x - 10). The expression is judged before it is evaluated.
	#
	#   cExpression   the expression text, in the grammar described at judgeExpression
	#   _cVarName_    the variable to nudge; it must be one of the names the extractor knows
	#   returns       a number; 0 when the expression does not use the variable
	#   note          x/8 + y/4 gives 0.125 for x and 0.25 for y, pow(x, 2) gives 20 for x
	#   warning       raises a plain error text, and runs nothing, when the expression is refused by
	#                 the judge, when the variable is not known, when the step is not a positive
	#                 number, or when the expression cannot be evaluated at the test point
	#   see           extract, setPerturbationDelta, evaluateExpression, judgeExpression
	#@ aka  Numerical differentiation for complex expressions
	def numericalDerivative(cExpression, _cVarName_)
		_nStep_ = @nPerturbationDelta
		if NOT isNumber(_nStep_)
			raise("stzCoeffExtractor: the perturbation step is not a number")
		ok
		if _nStep_ <= 0
			raise("stzCoeffExtractor: the perturbation step must be positive")
		ok

		# Which known variable is it?
		_nPos_ = 0
		_nVarsLen_ = ring_len(@aVars)
		for _iVar_ = 1 to _nVarsLen_
			if isString(@aVars[_iVar_]) and isString(_cVarName_)
				if strcmp(@aVars[_iVar_], _cVarName_) = 0
					_nPos_ = _iVar_
					exit
				ok
			ok
		next
		if _nPos_ = 0
			raise("stzCoeffExtractor: the variable is not one of the names of this extractor")
		ok

		# Two points, one step above and one step below the test point
		_aUp_ = This.createTestValues()
		_aDown_ = This.createTestValues()
		_aUp_[_nPos_][2] = _aUp_[_nPos_][2] + _nStep_
		_aDown_[_nPos_][2] = _aDown_[_nPos_][2] - _nStep_

		_nUpValue_ = This.evaluateExpression(cExpression, _aUp_)
		_nDownValue_ = This.evaluateExpression(cExpression, _aDown_)

		_nCoeff_ = (_nUpValue_ - _nDownValue_) / (2 * _nStep_)

		# Round to handle floating point precision issues
		return This.roundCoefficient(_nCoeff_)


	# Returns the point where non-linear expressions are tested: every variable at 10.
	#
	#   returns    a list of [ name, 10 ] pairs, one per known variable, in the order of the names
	#   note       the pairs are a plain list, so two names that differ only by case stay two entries
	#   see        numericalDerivative, evaluateExpression
	def createTestValues()
		_aValues_ = []
		_nVars2Len_ = ring_len(@aVars)
		for _iLoopVars2_ = 1 to _nVars2Len_
			_aValues_ + [ @aVars[_iLoopVars2_], 10.0 ]  # Use 10.0 to avoid min() saturation
		next
		return _aValues_


	# Returns the refusal text when an expression is outside the accepted grammar, and an empty text when it is accepted.
	#
	# It reads the expression once, without running any of it, and accepts only: numbers (7, 2.5,
	# .5, 1e3, 2.5E-2), the names of the known variables written exactly, the operators + - * /,
	# parentheses, commas, and the functions pow(a, b), sqrt(a), abs(a), min and max. min and max
	# take the bracketed list max([0, x - 10]) or plain arguments max(0, x - 10). A sign may stand
	# once before an operand. Anything else is refused: any other name, a function not listed, a
	# name that only contains a listed one, a quote, a semicolon, a brace, a backtick, = < > ! % ^
	# & | ~ @ # $ ? : or a point used as anything but a decimal point, a newline, a character above
	# 127, an operand with no operator between, an unbalanced parenthesis, an empty or oversized text.
	#
	#   cExpression   the expression text
	#   returns       a text; empty when accepted, otherwise a sentence beginning with refused
	#   note          a name used in the expression must be declared, so the judge also refuses an
	#                 undeclared variable; whether a value exists for it is asked at evaluation
	#   see           validateExpression, evaluateExpression, translateExpression
	def judgeExpression(cExpression)
		_aTranslated_ = This.translateExpression(cExpression)
		return _aTranslated_[1]


	# Returns an expression rewritten as a formula Ring can run, with its refusal text and the variables it uses.
	#
	# The formula is rebuilt from tokens, never copied: a number is rewritten in plain digits, a
	# known variable becomes a reference into a list of its value, a listed function keeps its name
	# in lower case, and every other piece of the text is refused. Nothing the caller wrote besides
	# those tokens can reach the formula. The grammar is the one described at judgeExpression.
	#
	#   cExpression   the expression text
	#   returns       a list [ cRefusal, cFormula, abUsed ]: the refusal text (empty when accepted),
	#                 the formula text (empty when refused), and one 0 or 1 per known variable that
	#                 says whether the expression uses it
	#   note          the formula is not evaluated here
	#   see           judgeExpression, evaluateExpression
	def translateExpression(cExpression)
		_cAlpha_ = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
		_cDigits_ = "0123456789"
		_nVarsLen_ = 0
		if isList(@aVars)
			_nVarsLen_ = ring_len(@aVars)
		ok
		_abUsed_ = []
		for _iVar_ = 1 to _nVarsLen_
			_abUsed_ + 0
		next

		if NOT isString(cExpression)
			return [ "refused: the expression is not a text", "", _abUsed_ ]
		ok
		_nLen_ = ring_len(cExpression)
		if _nLen_ = 0
			return [ "refused: the expression is empty", "", _abUsed_ ]
		ok
		if _nLen_ > 2000
			return [ "refused: the expression is longer than 2000 characters", "", _abUsed_ ]
		ok

		# Every character must be a printable ASCII one, a space or a tab: a control character, a
		# NUL or a byte above 126 (the pieces Unicode look-alikes are made of) is refused here, so
		# the scan below never classifies a character it could misread
		for _nI_ = 1 to _nLen_
			_nCode_ = ascii(cExpression[_nI_])
			if _nCode_ != 9 and ( _nCode_ < 32 or _nCode_ > 126 )
				return [ "refused: the character with code " + _nCode_ + " is not part of the arithmetic grammar (position " + _nI_ + ")", "", _abUsed_ ]
			ok
		next

		# Two marks at the end let a look-ahead read past the last character
		_cE_ = cExpression + "~~"
		_cOut_ = ""
		_aStack_ = []     # one frame per open parenthesis: [ name, commas, bracketed, closed, outLen ]
		_nTop_ = 0
		_bOperand_ = 0    # 1 just after an operand, where an operator, a comma or a closer must follow
		_bSign_ = 0       # 1 just after a sign standing before an operand
		_nI_ = 1

		while _nI_ <= _nLen_
			_c_ = _cE_[_nI_]

			# After a closing bracket only the closing parenthesis may come
			if _nTop_ > 0
				if _aStack_[_nTop_][4] = 1 and _c_ != ")" and _c_ != " " and _c_ != ring_char(9)
					return [ "refused: only ) may follow ] (position " + _nI_ + ")", "", _abUsed_ ]
				ok
			ok

			if _c_ = " " or _c_ = ring_char(9)
				_nI_++

			but ring_substr1(_cDigits_, _c_) > 0 or ( _c_ = "." and ring_substr1(_cDigits_, _cE_[_nI_ + 1]) > 0 )
				if _bOperand_
					return [ "refused: a number follows an operand with no operator between (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				_cInt_ = ""
				_cFrac_ = ""
				_cExp_ = ""
				_cExpSign_ = ""
				while ring_substr1(_cDigits_, _cE_[_nI_]) > 0
					_cInt_ += _cE_[_nI_]
					_nI_++
				end
				if _cE_[_nI_] = "."
					_nI_++
					while ring_substr1(_cDigits_, _cE_[_nI_]) > 0
						_cFrac_ += _cE_[_nI_]
						_nI_++
					end
				ok
				if ring_lower(_cE_[_nI_]) = "e"
					_nJ_ = _nI_ + 1
					if _cE_[_nJ_] = "+" or _cE_[_nJ_] = "-"
						_cExpSign_ = _cE_[_nJ_]
						_nJ_++
					ok
					if ring_substr1(_cDigits_, _cE_[_nJ_]) = 0
						return [ "refused: a number has a malformed exponent (position " + _nI_ + ")", "", _abUsed_ ]
					ok
					while ring_substr1(_cDigits_, _cE_[_nJ_]) > 0
						_cExp_ += _cE_[_nJ_]
						_nJ_++
					end
					_nI_ = _nJ_
				ok
				# A number may not run into a name, a second point or another number
				if ring_substr1(_cAlpha_, _cE_[_nI_]) > 0 or _cE_[_nI_] = "." or ring_substr1(_cDigits_, _cE_[_nI_]) > 0
					return [ "refused: a number is glued to a name or to a second point (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				if ring_len(_cInt_) + ring_len(_cFrac_) > 18 or ring_len(_cExp_) > 3
					return [ "refused: a number is too long (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				# Plain digits: no leading zeros, a point only when there are decimals
				while ring_len(_cInt_) > 1 and _cInt_[1] = "0"
					_cInt_ = ring_right(_cInt_, ring_len(_cInt_) - 1)
				end
				if _cInt_ = ""
					_cInt_ = "0"
				ok
				_cNumber_ = _cInt_
				if _cFrac_ != ""
					_cNumber_ += "." + _cFrac_
				ok
				if _cExp_ != ""
					if _cExpSign_ = "-"
						_cNumber_ = "(" + _cNumber_ + " * pow(10, -" + _cExp_ + "))"
					else
						_cNumber_ = "(" + _cNumber_ + " * pow(10, " + _cExp_ + "))"
					ok
				ok
				_cOut_ += _cNumber_ + " "
				_bOperand_ = 1
				_bSign_ = 0

			but ring_substr1(_cAlpha_, _c_) > 0
				_cName_ = ""
				while ring_substr1(_cAlpha_, _cE_[_nI_]) > 0 or ring_substr1(_cDigits_, _cE_[_nI_]) > 0
					_cName_ += _cE_[_nI_]
					_nI_++
				end
				# A name followed by a parenthesis is a call
				_nK_ = _nI_
				while _cE_[_nK_] = " " or _cE_[_nK_] = ring_char(9)
					_nK_++
				end
				if _cE_[_nK_] = "("
					_cFn_ = ring_lower(_cName_)
					if ring_substr1(" pow sqrt abs min max ", " " + _cFn_ + " ") = 0
						return [ "refused: the function " + _cName_ + " is not one of pow, sqrt, abs, min, max", "", _abUsed_ ]
					ok
					if _bOperand_
						return [ "refused: a function call follows an operand with no operator between (position " + _nI_ + ")", "", _abUsed_ ]
					ok
					if _nTop_ >= 50
						return [ "refused: parentheses are nested more than 50 deep", "", _abUsed_ ]
					ok
					_nTop_++
					_aFrame_ = [ _cFn_, 0, 0, 0, 0 ]
					if _nTop_ > ring_len(_aStack_)
						_aStack_ + _aFrame_
					else
						_aStack_[_nTop_] = _aFrame_
					ok
					if _cFn_ = "min" or _cFn_ = "max"
						_cOut_ += _cFn_ + "([ "
					else
						_cOut_ += _cFn_ + "( "
					ok
					_aStack_[_nTop_][5] = ring_len(_cOut_)
					_nI_ = _nK_ + 1
					_bOperand_ = 0
					_bSign_ = 0
				else
					_nFound_ = 0
					for _iVar_ = 1 to _nVarsLen_
						if isString(@aVars[_iVar_])
							if strcmp(@aVars[_iVar_], _cName_) = 0
								_nFound_ = _iVar_
								exit
							ok
						ok
					next
					if _nFound_ = 0
						return [ "refused: " + _cName_ + " is neither a known variable nor one of pow, sqrt, abs, min, max", "", _abUsed_ ]
					ok
					if _bOperand_
						return [ "refused: a name follows an operand with no operator between (position " + _nI_ + ")", "", _abUsed_ ]
					ok
					_cOut_ += "_aEv_[" + _nFound_ + "] "
					_abUsed_[_nFound_] = 1
					_bOperand_ = 1
					_bSign_ = 0
				ok

			but _c_ = "+" or _c_ = "-"
				if _bOperand_
					_cOut_ += _c_ + " "
					_bOperand_ = 0
					_bSign_ = 0
				else
					if _bSign_
						return [ "refused: two signs in a row (position " + _nI_ + ")", "", _abUsed_ ]
					ok
					_bSign_ = 1
					if _c_ = "-"
						_cOut_ += "- "
					ok
				ok
				_nI_++

			but _c_ = "*" or _c_ = "/"
				if NOT _bOperand_
					return [ "refused: the operator " + _c_ + " has no operand before it (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				_cOut_ += _c_ + " "
				_bOperand_ = 0
				_bSign_ = 0
				_nI_++

			but _c_ = "("
				if _bOperand_
					return [ "refused: a parenthesis follows an operand with no operator between (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				if _nTop_ >= 50
					return [ "refused: parentheses are nested more than 50 deep", "", _abUsed_ ]
				ok
				_nTop_++
				_aFrame_ = [ "", 0, 0, 0, 0 ]
				if _nTop_ > ring_len(_aStack_)
					_aStack_ + _aFrame_
				else
					_aStack_[_nTop_] = _aFrame_
				ok
				_cOut_ += "( "
				_bSign_ = 0
				_nI_++

			but _c_ = "["
				# only straight after the opening parenthesis of min or max
				_bOk_ = 0
				if _nTop_ > 0
					_cTopName_ = _aStack_[_nTop_][1]
					if (_cTopName_ = "min" or _cTopName_ = "max") and _aStack_[_nTop_][3] = 0 and _aStack_[_nTop_][2] = 0 and ring_len(_cOut_) = _aStack_[_nTop_][5] and NOT _bOperand_ and NOT _bSign_
						_bOk_ = 1
					ok
				ok
				if NOT _bOk_
					return [ "refused: [ is allowed only straight after min( or max( (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				_aStack_[_nTop_][3] = 1
				_nI_++

			but _c_ = "]"
				if _nTop_ = 0 or NOT _bOperand_
					return [ "refused: ] with nothing to close (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				if _aStack_[_nTop_][3] = 0 or _aStack_[_nTop_][4] = 1
					return [ "refused: ] with no [ open in min or max (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				_aStack_[_nTop_][4] = 1
				_nI_++

			but _c_ = ")"
				if _nTop_ = 0
					return [ "refused: ) with no ( open (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				if NOT _bOperand_
					return [ "refused: ) after an operator or an empty argument list (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				_cTopName_ = _aStack_[_nTop_][1]
				_nCommas_ = _aStack_[_nTop_][2]
				if _cTopName_ = "pow" and _nCommas_ != 1
					return [ "refused: pow takes exactly two arguments", "", _abUsed_ ]
				ok
				if (_cTopName_ = "sqrt" or _cTopName_ = "abs") and _nCommas_ != 0
					return [ "refused: " + _cTopName_ + " takes exactly one argument", "", _abUsed_ ]
				ok
				if (_cTopName_ = "min" or _cTopName_ = "max")
					if _aStack_[_nTop_][3] = 1 and _aStack_[_nTop_][4] = 0
						return [ "refused: [ is never closed in " + _cTopName_ + " (position " + _nI_ + ")", "", _abUsed_ ]
					ok
					_cOut_ += "]) "
				else
					_cOut_ += ") "
				ok
				_nTop_--
				_bOperand_ = 1
				_bSign_ = 0
				_nI_++

			but _c_ = ","
				if _nTop_ = 0
					return [ "refused: a comma outside a function call (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				_cTopName_ = _aStack_[_nTop_][1]
				if _cTopName_ = ""
					return [ "refused: a comma outside a function call (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				if NOT _bOperand_
					return [ "refused: a comma with no argument before it (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				if _cTopName_ = "sqrt" or _cTopName_ = "abs" or ( _cTopName_ = "pow" and _aStack_[_nTop_][2] >= 1 )
					return [ "refused: too many arguments for " + _cTopName_ + " (position " + _nI_ + ")", "", _abUsed_ ]
				ok
				_aStack_[_nTop_][2] = _aStack_[_nTop_][2] + 1
				_cOut_ += ", "
				_bOperand_ = 0
				_bSign_ = 0
				_nI_++

			else
				return [ "refused: the character " + _c_ + " is not part of the arithmetic grammar (position " + _nI_ + ")", "", _abUsed_ ]
			ok
		end

		if _nTop_ > 0
			return [ "refused: a parenthesis is never closed", "", _abUsed_ ]
		ok
		if NOT _bOperand_
			return [ "refused: the expression ends before it is complete", "", _abUsed_ ]
		ok
		return [ "", ring_trim(_cOut_), _abUsed_ ]


	# Returns the value of an expression at a point, after judging it and without running anything but its arithmetic.
	#
	# The text is first rebuilt by translateExpression, so that only numbers, known variables, the
	# operators + - * /, parentheses, commas and the functions pow, sqrt, abs, min and max can
	# reach Ring's evaluator (the grammar is spelled out at judgeExpression). The variables are
	# not printed into the formula: it reads their values, exact, from a list, so a value is never
	# rounded to the display precision.
	#
	#   cExpression   the expression text, such as x/8 + y/4 or pow(x, 2)
	#   aVarValues    a list of [ name, value ] pairs, such as the one createTestValues returns; a value
	#                 is needed only for the variables the expression uses
	#   returns       a number; x/8 + y/4 at x = 10, y = 4 gives 2.25 and pow(x, 2) at x = 3 gives 9
	#   warning       raises a plain error text, with nothing run, when the expression is refused,
	#                 when it uses a variable that has no value or a value that is not a number,
	#                 when it divides by zero, or when the result is not a finite number
	#   see           judgeExpression, numericalDerivative, validateExpression, createTestValues
	def evaluateExpression(cExpression, aVarValues)
		_aTranslated_ = This.translateExpression(cExpression)
		if _aTranslated_[1] != ""
			raise("stzCoeffExtractor: " + _aTranslated_[1])
		ok
		if NOT isList(aVarValues)
			raise("stzCoeffExtractor: the values must be a list of [ name, value ] pairs")
		ok

		# One value per known variable, in the order of the names
		_aEv_ = []
		_nVarsLen_ = ring_len(@aVars)
		_nPairsLen_ = ring_len(aVarValues)
		for _iVar_ = 1 to _nVarsLen_
			_xValue_ = 0
			_bFound_ = 0
			for _iPair_ = 1 to _nPairsLen_
				if isList(aVarValues[_iPair_]) and isString(@aVars[_iVar_])
					if ring_len(aVarValues[_iPair_]) >= 2
						if isString(aVarValues[_iPair_][1])
							if strcmp(aVarValues[_iPair_][1], @aVars[_iVar_]) = 0
								_xValue_ = aVarValues[_iPair_][2]
								_bFound_ = 1
								exit
							ok
						ok
					ok
				ok
			next
			if _aTranslated_[3][_iVar_] = 1
				if NOT _bFound_
					raise("stzCoeffExtractor: no value was given for the variable " + @aVars[_iVar_])
				ok
				if NOT isNumber(_xValue_)
					raise("stzCoeffExtractor: the value of the variable " + @aVars[_iVar_] + " is not a number")
				ok
			ok
			_aEv_ + _xValue_
		next

		# The formula holds only what the translation put there
		_nResult_ = ""
		_cFailure_ = ""
		try
			eval("_nResult_ = " + _aTranslated_[2])
		catch
			_cFailure_ = cCatchError
		done

		if _cFailure_ != ""
			if ring_substr1(ring_lower(_cFailure_), "divide by zero") > 0
				raise("stzCoeffExtractor: the expression divides by zero at this point")
			ok
			raise("stzCoeffExtractor: the expression could not be evaluated at this point")
		ok
		if NOT isNumber(_nResult_)
			raise("stzCoeffExtractor: the expression did not give a number")
		ok
		# not a number (nan) and infinities are not answers
		_nBig_ = ring_pow(10, 300)
		if NOT ( _nResult_ = _nResult_ ) or _nResult_ > _nBig_ or _nResult_ < -_nBig_
			raise("stzCoeffExtractor: the expression did not give a finite number at this point")
		ok
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
	#   warning       the same limits as extract: a non-linear expression is differentiated at the
	#                 test point 10, and one outside the accepted grammar raises a plain error text
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
	
	# Tells whether an expression is both inside the accepted grammar and computable at the test point.
	#
	# It judges the text first (see judgeExpression) and then evaluates it with every variable at 10,
	# so it answers 1 only for an expression that is safe and gives a finite number there. It never
	# raises: a refused text, an undeclared name, a division by zero at the test point, such as
	# 1/(x - 10), or a square root of a negative number all answer 0.
	#
	#   cExpression   the expression text
	#   returns       1 when the expression is safe and evaluable, 0 otherwise
	#   note          x + 1 and x + y give 1 when x and y are known; x + z gives 0 when z is not known
	#   see           judgeExpression, evaluateExpression, createTestValues
	#@ aka  Utility method to validate expression
	def validateExpression(cExpression)
		_bValid_ = 0
		try
			if This.judgeExpression(cExpression) = ""
				This.evaluateExpression(cExpression, This.createTestValues())
				_bValid_ = 1
			ok
		catch
			_bValid_ = 0
		done
		return _bValid_
