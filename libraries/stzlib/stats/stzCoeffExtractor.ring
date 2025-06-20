# A utility class used by the various class solvers
# to extract the coefficient of a given variable in an expression

# - Simple linear: Basic a*x + b*y forms
# - Negative coefficients: Handling minus signs
# - Implicit coefficients: Variables without explicit multipliers
# - Complex functions: min/max, division, powers, abs, sqrt
# - Edge cases: Zero coefficients, substring variables, formatting
# - Batch operations: All coefficients at once
# - Validation: Expression correctness checking

#NOTE The numerical differentiation approach handles the complex
# cases that pattern matching can't, while the fast path efficiently
# processes simple linear expressions.

# See stzCoeffExtractorTest.ring file for samples.

class StzCoefficientExtractor from stzCoeffExtractor

class stzCoeffExtractor from stzObject
	aVariableNames = []
	nPerturbationDelta = 0.001
	
	def init(paVariableNames)
		aVariableNames = paVariableNames
	
	def setVariableNames(paVariableNames)
		aVariableNames = paVariableNames
			
	def setPerturbationDelta(pnDelta)
		nPerturbationDelta = pnDelta
	
	# Main method: Extract coefficient
	def extract(cExpression, cVarName)
		if not ring_substr1(cExpression, cVarName)
			return 0
		ok
		
		# Try simple pattern matching first (for performance)
		nSimpleCoeff = This.trySimpleExtraction(cExpression, cVarName)
		if nSimpleCoeff != NULL
			return nSimpleCoeff
		ok
		
		# Fall back to numerical differentiation
		return This.numericalDerivative(cExpression, cVarName)
	
	
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
		aTestValues[cVarName] = aTestValues[cVarName] + nPerturbationDelta
		nPerturbedValue = This.evaluateExpression(cExpression, aTestValues)
		
		# Calculate numerical derivative (coefficient)
		nCoeff = (nPerturbedValue - nBaseValue) / nPerturbationDelta
		
		# Round to handle floating point precision issues
		return This.roundCoefficient(nCoeff)
	

	def createTestValues()
		aValues = []
		for cVarName in aVariableNames
			aValues[cVarName] = 10.0  # Use 10.0 to avoid min() saturation
		next
		return aValues


	def evaluateExpression(cExpression, aVarValues)
	    # Prepare replacement pairs
	    acSubStr = []
		acNewSubStr = []

	    for cVarName in aVariableNames
	        if ring_substr1(cExpression, cVarName)
	            acSubStr + cVarName
				acNewSubStr + @@(aVarValues[cVarName])
	        ok
	    next
	    
	    # Use StzStringQ for safe replacement
	    cEvalExpr = "nResult = (" +
			StzStringQ(cExpression).ManyReplaced(acSubStr, acNewSubStr) + " )"

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
	
	# Batch extraction for all variables
	def extractAllCoefficients(cExpression)
		aCoeffs = []
		for cVarName in aVariableNames
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
