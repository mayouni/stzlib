
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
   "pow(x, 2)"            	   # x² → result changes with x (at x=10, rate = 20)  
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
	def extract(cExpression, cVarName)

		nResult = 0

		if not ring_substr1(cExpression, cVarName)
			return 0
			return nResult
		ok
		
		# Try simple pattern matching first (for performance)
		nSimpleCoeff = This.trySimpleExtraction(cExpression, cVarName)
		if nSimpleCoeff != NULL
			return nSimpleCoeff
			nResult = nSimpleCoeff
		ok
		
		# Fall back to numerical differentiation
		return This.numericalDerivative(cExpression, cVarName)
	
		nResult = This.numericalDerivative(cExpression, cVarName)
		return nResult
	
		def ExtractCoefficient(cExpression, cVarName)
			return This.Extract(cExpression, cVarName)

		def ExtractCoeff(cExpression, cVarName)
			return This.Extract(cExpression, cVarName)


	# Fast path for simple linear expressions
	def trySimpleExtraction(cExpression, cVarName)
		cExpr = This.normalizeExpression(cExpression)
		
		# Check if it's a simple linear form
		if This.isSimpleLinearExpression(cExpr)
			return This.extractLinearCoefficient(cExpr, cVarName)
		ok
		
		return NULL  # Indicates need for numerical method
	
	def normalizeExpression(cExpression)
		cExpr = @trim(cExpression)
		cExpr = ring_substr2(cExpr, " ", "")  # Remove spaces
		cExpr = ring_substr2(cExpr, "\t", "") # Remove tabs
		return cExpr
	
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
	
	def extractLinearCoefficient(cExpression, cVarName)
		cExpr = ring_substr2(cExpression, "-", "+-")  # Handle negative terms
		acTerms = @split(cExpr, "+")
		nLen = len(acTerms)

		for i = 1 to nLen
			cTerm = @trim(acTerms[i])
			if cTerm = "" loop ok
			
			if ring_substr1(cTerm, cVarName)
				if ring_substr1(cTerm, "*")
					# Extract coefficient before *
					nPos = ring_substr1(cTerm, "*")

					cCoeff = trim(@substr(cTerm, 1, nPos-1))
					if cCoeff = "" or cCoeff = "+"
						return 1
					ok
					if cCoeff = "-"
						return -1
					ok
					return 0 + cCoeff
				else
					# Variable without explicit coefficient
					if left(cTerm, 1) = "-"
						return -1
					ok
					return 1
				ok
			ok
		next
		
		return 0
	

	# Numerical differentiation for complex expressions

	def numericalDerivative(cExpression, cVarName)
		# Create test values for all variables
		aTestValues = This.createTestValues()
		
		# Evaluate at base point
		nBaseValue = This.evaluateExpression(cExpression, aTestValues)
		
		# Perturb the target variable and evaluate again
		aTestValues[cVarName] = aTestValues[cVarName] + @nPerturbationDelta
		nPerturbedValue = This.evaluateExpression(cExpression, aTestValues)
		
		# Calculate numerical derivative (coefficient)
		nCoeff = (nPerturbedValue - nBaseValue) / @nPerturbationDelta
		
		# Round to handle floating point precision issues
		return This.roundCoefficient(nCoeff)
	

	def createTestValues()
		aValues = []
		for cVarName in @aVars
			aValues[cVarName] = 10.0  # Use 10.0 to avoid min() saturation
		next
		return aValues


	def evaluateExpression(cExpression, aVarValues)
	    # Prepare replacement pairs
	    acSubStr = []
		acNewSubStr = []

	    for cVarName in @aVars
	        if ring_substr1(cExpression, cVarName)
	            acSubStr + cVarName
				acNewSubStr + @@(aVarValues[cVarName])
	        ok
	    next
	    
	    # Use StzStringQ for safe replacement
	    cEvalExpr = "nResult = (" +
			StzStringQ(cExpression).ManyReplaced(acSubStr, acNewSubStr) + " )"
		cEvalExpr = "nResult = " +
    	StzStringQ(cExpression).ManyReplaced(acSubStr, acNewSubStr)

	    eval(cEvalExpr)
		eval(cEvalExpr)
	    return nResult

	
	def roundCoefficient(nCoeff)
		# Round to reasonable precision to avoid floating point artifacts
		nRounded = floor(nCoeff * 1000000 + 0.5) / 1000000
		
		# If very close to integer, return integer
		if abs(nRounded - floor(nRounded + 0.5)) < 0.000001
			return floor(nRounded + 0.5)
		ok
		
		return nRounded
	

	def VarNames()
		nLen = len(@aVars)
		acResult = []

		for i = 1 to nLen
			acResult + @aVars[i]
		next

		return acResult

		def VariableNames()
			return This.VarNames()

	# Batch extraction for all variables
	def extractAllCoefficients(cExpression)
		aCoeffs = []
		acVarNames = This.VarNames()

		for cVarName in acVarNames
			aCoeffs + This.extractCoefficient(cExpression, cVarName)
		next
		return aCoeffs
	
	# Utility method to validate expression
	def validateExpression(cExpression)
		try
			aTestValues = This.createTestValues(cExpression)
			This.evaluateExpression(cExpression, aTestValues)
			return TRUE
		catch
			return FALSE
		done
