# stzMatrex - Matrix Pattern Matching for Softanza
# A regex-like pattern language for matrix structures
# Companion to stzNumbrex for 2D numerical data

# Quick constructor functions
func StzMatrexQ(cPattern)
	return new stzMatrex(cPattern)

func Matrex(cPattern)
	return new stzMatrex(cPattern)

func Mx(cPattern)
	return new stzMatrex(cPattern)

func IsStzMatrex(pObj)
	if isObject(pObj) and classname(pObj) = "stzmatrex"
		return 1
	else
		return 0
	ok

class stzMatrex from stzObject
	
	@cPattern           # Pattern string
	@aTokens            # Parsed token definitions
	@aMatrix = []       # Target matrix to match
	@bDebugMode = FALSE # Debug flag
	@aMatchedParts = [] # Extracted parts
	
	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#
	
	def init(pcPattern)
		if NOT isString(pcPattern)
			StzRaise("Error: Pattern must be a string")
		ok
		
		@cPattern = This.NormalizePattern(pcPattern)
		@aTokens = This.ParsePattern(@cPattern)
		
		if @bDebugMode
			? "=== stzMatrex Init ==="
			? "Pattern: " + @cPattern
			? "Tokens parsed: " + len(@aTokens)
		ok
	
	def NormalizePattern(cPattern)
		cPattern = trim(cPattern)
		if NOT (startsWith(cPattern, "{") and endsWith(cPattern, "}"))
			cPattern = "{" + cPattern + "}"
		ok
		return cPattern
	
	  #--------------------#
	 #  PATTERN PARSING   #
	#--------------------#
	
def ParsePattern(cPattern)
	cInner = @substr(cPattern, 2, len(cPattern) - 1)
	cInner = trim(cInner)
	
	if @bDebugMode
		? "Parsing inner pattern: " + cInner
	ok
	
	aParts = This.SplitByOperator(cInner, "->")
	aTokens = []
	nLenParts = len(aParts)
	
	for i = 1 to nLenParts
		cPart = trim(aParts[i])
		
		if @bDebugMode
			? ">>> Processing part " + i + ": [" + cPart + "]"
		ok
		
		if cPart = ""
			loop
		ok
		
		if substr(cPart, "|") > 0
			if @bDebugMode
				? ">>> Detected alternation"
			ok
			aToken = This.ParseAlternation(cPart)
		but substr(cPart, "&") > 0
			if @bDebugMode
				? ">>> Detected conjunction"
			ok
			aToken = This.ParseConjunction(cPart)
		else
			if @bDebugMode
				? ">>> Parsing as single token"
			ok
			aToken = This.ParseSingleToken(cPart)
		ok
		
		if @bDebugMode
			? ">>> Token result: " + @@(aToken)
			? ">>> Token length: " + len(aToken)
		ok
		
		# Remove this condition - ALWAYS add tokens
		aTokens + aToken
	next
	
	if @bDebugMode
		? ">>> Final token count: " + len(aTokens)
	ok
	
	return aTokens
	
	def SplitByOperator(cStr, cOperator)
		aParts = []
		cCurrent = ""
		nDepth = 0
		nLen = len(cStr)
		nOpLen = len(cOperator)
		
		for i = 1 to nLen
			cChar = @substr(cStr, i, i)
			
			if cChar = "(" or cChar = "{"
				nDepth++
				cCurrent += cChar
			but cChar = ")" or cChar = "}"
				nDepth--
				cCurrent += cChar
			but nDepth = 0 and @substr(cStr, i, i + nOpLen - 1) = cOperator
				aParts + trim(cCurrent)
				cCurrent = ""
				i += nOpLen - 1
			else
				cCurrent += cChar
			ok
		next
		
		if len(cCurrent) > 0
			aParts + trim(cCurrent)
		ok
		
		return aParts
	
	def ParseAlternation(cTokenStr)
		if startsWith(cTokenStr, "(") and endsWith(cTokenStr, ")")
			cTokenStr = @substr(cTokenStr, 2, len(cTokenStr) - 1)
		ok
		
		aParts = This.SplitByOperatOr(cTokenStr, "|")
		aAlternatives = []
		nLenParts = len(aParts)
		
		for i = 1 to nLenParts
			cPart = trim(aParts[i])
			if cPart != ""
				aToken = This.ParseSingleToken(cPart)
				if len(aToken) > 0
					aAlternatives + aToken
				ok
			ok
		next
		
		return [
			["type", "alternation"],
			["alternatives", aAlternatives],
			["negated", 0]
		]
	
def ParseConjunction(cTokenStr)
	if startsWith(cTokenStr, "(") and endsWith(cTokenStr, ")")
		cTokenStr = @substr(cTokenStr, 2, len(cTokenStr) - 1)
	ok
	
	aParts = This.SplitByOperatOr(cTokenStr, "&")
	aConditions = []
	nLenParts = len(aParts)
	
	if @bDebugMode
		? ">>>> ParseConjunction: " + nLenParts + " parts"
	ok
	
	for i = 1 to nLenParts
		cPart = trim(aParts[i])
		
		if @bDebugMode
			? ">>>> Conjunction part " + i + ": [" + cPart + "]"
		ok
		
		if cPart != ""
			aToken = This.ParseSingleToken(cPart)
			
			if @bDebugMode
				? ">>>> Parsed token: " + @@(aToken)
			ok
			
			# ALWAYS add - don't skip errors
			aConditions + aToken
		ok
	next
	
	return [
		["type", "conjunction"],
		["conditions", aConditions],
		["negated", 0]
	]
	
	def ParseSingleToken(cTokenStr)
		cTokenStr = trim(cTokenStr)
		if cTokenStr = ""
			return []
		ok
		
		cOriginal = cTokenStr
		bNegated = 0
		
		if startsWith(lower(cTokenStr), "@!")
			bNegated = 1
			cTokenStr = @substr(cTokenStr, 3, len(cTokenStr))
			
			if @bDebugMode
				? "Negation detected! Remaining: " + cTokenStr
			ok
		ok
		
		cType = ""
		cValue = ""
		aConstraints = []
		nMin = 1
		nMax = 1
		
		cTokenStr = lower(cTokenStr)
		
		# Parse token types
		if startsWith(cTokenStr, "@size")
			cType = "size"
			cTokenStr = @substr(cTokenStr, 6, len(cTokenStr))
		but startsWith(cTokenStr, "size")
			cType = "size"
			cTokenStr = @substr(cTokenStr, 5, len(cTokenStr))
			
		but startsWith(cTokenStr, "@shape")
			cType = "shape"
			cTokenStr = @substr(cTokenStr, 7, len(cTokenStr))
		but startsWith(cTokenStr, "shape")
			cType = "shape"
			cTokenStr = @substr(cTokenStr, 6, len(cTokenStr))
			
		but startsWith(cTokenStr, "@element")
			cType = "element"
			cTokenStr = @substr(cTokenStr, 9, len(cTokenStr))
		but startsWith(cTokenStr, "element")
			cType = "element"
			cTokenStr = @substr(cTokenStr, 8, len(cTokenStr))
			
		but startsWith(cTokenStr, "@row")
			cType = "row"
			cTokenStr = @substr(cTokenStr, 5, len(cTokenStr))
		but startsWith(cTokenStr, "row")
			cType = "row"
			cTokenStr = @substr(cTokenStr, 4, len(cTokenStr))
			
		but startsWith(cTokenStr, "@col")
			cType = "col"
			cTokenStr = @substr(cTokenStr, 5, len(cTokenStr))
		but startsWith(cTokenStr, "col")
			cType = "col"
			cTokenStr = @substr(cTokenStr, 4, len(cTokenStr))
			
		but startsWith(cTokenStr, "@diagonal")
			cType = "diagonal"
			cTokenStr = @substr(cTokenStr, 10, len(cTokenStr))
		but startsWith(cTokenStr, "diagonal")
			cType = "diagonal"
			cTokenStr = @substr(cTokenStr, 9, len(cTokenStr))
			
		but startsWith(cTokenStr, "@property")
			cType = "property"
			cTokenStr = @substr(cTokenStr, 10, len(cTokenStr))
		but startsWith(cTokenStr, "property")
			cType = "property"
			cTokenStr = @substr(cTokenStr, 9, len(cTokenStr))
			
		but startsWith(cTokenStr, "@pattern")
			cType = "pattern"
			cTokenStr = @substr(cTokenStr, 9, len(cTokenStr))
		but startsWith(cTokenStr, "pattern")
			cType = "pattern"
			cTokenStr = @substr(cTokenStr, 8, len(cTokenStr))
			
		but startsWith(cTokenStr, "@determinant")
			cType = "determinant"
			cTokenStr = @substr(cTokenStr, 13, len(cTokenStr))
		but startsWith(cTokenStr, "determinant")
			cType = "determinant"
			cTokenStr = @substr(cTokenStr, 12, len(cTokenStr))
			
		but startsWith(cTokenStr, "@sum")
			cType = "sum"
			cTokenStr = @substr(cTokenStr, 5, len(cTokenStr))
		but startsWith(cTokenStr, "sum")
			cType = "sum"
			cTokenStr = @substr(cTokenStr, 4, len(cTokenStr))
			
		else
			# UNKNOWN TOKEN - return error marker
			if @bDebugMode
				? "Unknown token type: " + cTokenStr
			ok
			return [
				["type", "ERROR"],
				["value", cOriginal],
				["message", "Unrecognized token type"]
			]
		ok
		
		# Parse parentheses content
		nOpenParen = substr(cTokenStr, "(")
		nCloseParen = 0
		
		if nOpenParen > 0
			nCloseParen = substr(cTokenStr, ")")
			if nCloseParen > nOpenParen
				cContent = @substr(cTokenStr, nOpenParen + 1, nCloseParen - 1)
				
				if @bDebugMode
					? ">> cContent: " + cContent
					? ">> cType: " + cType
				ok
				
				if cType = "property" or cType = "shape" or 
				   cType = "pattern" or cType = "size"
					cValue = cContent
				else
					aConstraints = This.ParseConstraints(cContent, cType)
				ok
			ok
		ok
		
		# Parse quantifiers
		cQuantPart = ""
		if nCloseParen > 0 and nCloseParen < len(cTokenStr)
			cQuantPart = @substr(cTokenStr, nCloseParen + 1, len(cTokenStr))
		ok
		
		cQuantPart = trim(cQuantPart)
		
		if len(cQuantPart) > 0
			if substr(cQuantPart, ":") > 0
				nColon = substr(cQuantPart, ":")
				cBeforeColon = @substr(cQuantPart, 1, nColon - 1)
				cAfterColon = @substr(cQuantPart, nColon + 1, len(cQuantPart))
				
				cBeforeColon = trim(cBeforeColon)
				if len(cBeforeColon) > 0 and This.IsNumeric(cBeforeColon)
					if substr(cBeforeColon, "-") > 0
						aSection = @split(cBeforeColon, "-")
						if len(aSection) = 2
							nMin = 0 + trim(aSection[1])
							nMax = 0 + trim(aSection[2])
						ok
					else
						nMin = 0 + cBeforeColon
						nMax = nMin
					ok
				ok
				
				aMoreConstraints = This.ParseConstraints(":" + cAfterColon, cType)
				nLenMore = len(aMoreConstraints)
				for i = 1 to nLenMore
					aConstraints + aMoreConstraints[i]
				next
			else
				cLastChar = right(cQuantPart, 1)
				if cLastChar = "+"
					nMin = 1
					nMax = 999999
				but cLastChar = "*"
					nMin = 0
					nMax = 999999
				but cLastChar = "?"
					nMin = 0
					nMax = 1
				but This.IsNumeric(cQuantPart)
					if substr(cQuantPart, "-") > 0
						aSection = @split(cQuantPart, "-")
						if len(aSection) = 2
							nMin = 0 + trim(aSection[1])
							nMax = 0 + trim(aSection[2])
						ok
					else
						nMin = 0 + cQuantPart
						nMax = nMin
					ok
				ok
			ok
		ok
		
		return [
			["type", cType],
			["value", cValue],
			["constraints", aConstraints],
			["min", nMin],
			["max", nMax],
			["negated", bNegated]
		]
	
	def ParseConstraints(cConstraintStr, cType)
		aConstraints = []
		
		if cConstraintStr = ""
			return aConstraints
		ok
		
		if cType = "element"
			if substr(cConstraintStr, "..") > 0
				aParts = @split(cConstraintStr, "..")
				if len(aParts) = 2
					aConstraints + [
						["type", "range"],
						["start", 0 + trim(aParts[1])],
						["end", 0 + trim(aParts[2])]
					]
				ok
			but substr(cConstraintStr, "{") > 0
				nStart = substr(cConstraintStr, "{")
				nEnd = substr(cConstraintStr, "}")
				cSet = @substr(cConstraintStr, nStart + 1, nEnd - 1)
				aValues = @split(cSet, ";")
				aConstraints + [
					["type", "set"],
					["values", aValues]
				]
			but This.IsNumeric(cConstraintStr)
				aConstraints + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
			ok
		
		but cType = "size"
			# Handle size constraints like "3x3", "mxn", ">4"
			if substr(cConstraintStr, "x") > 0
				aParts = @split(cConstraintStr, "x")
				if len(aParts) = 2
					aConstraints + [
						["type", "dimensions"],
						["rows", trim(aParts[1])],
						["cols", trim(aParts[2])]
					]
				ok
			but startsWith(cConstraintStr, ">")
				aConstraints + [
					["type", "greater"],
					["value", 0 + @substr(cConstraintStr, 2, len(cConstraintStr))]
				]
			but startsWith(cConstraintStr, "<")
				aConstraints + [
					["type", "less"],
					["value", 0 + @substr(cConstraintStr, 2, len(cConstraintStr))]
				]
			ok
		ok
		
		return aConstraints
	
	  #--------------------#
	 #  MATCHING LOGIC    #
	#--------------------#
	
	def Match(paMatrix)
		if NOT (isList(paMatrix) and @IsMatrix(paMatrix))
			StzRaise("Incorrect param type! paMatrix must be a valid matrix.")
		ok
		
		@aMatrix = paMatrix
		
		if @bDebugMode
			? "=== Matching Matrix ==="
			? "Size: " + len(paMatrix) + "x" + len(paMatrix[1])
		ok
		
		bResult = This.MatchTokens(@aTokens, @aMatrix)
		
		if bResult
			This.ExtractParts(@aMatrix)
		ok
		
		if @bDebugMode
			? "Result: " + bResult
		ok
		
		return bResult
	
	def MatchTokens(aTokens, aMatrix)
		nLenTokens = len(aTokens)
		for i = 1 to nLenTokens
			aToken = aTokens[i]
			
			if HasKey(aToken, "type") and aToken["type"] = "alternation"
				bMatched = FALSE
				if HasKey(aToken, "alternatives")
					nLenAlt = len(aToken["alternatives"])
					for j = 1 to nLenAlt
						if This.MatchSingleToken(aToken["alternatives"][j], aMatrix)
							bMatched = TRUE
							exit
						ok
					next
				ok
				if not bMatched
					return FALSE
				ok
			
			but HasKey(aToken, "type") and aToken["type"] = "conjunction"
				if HasKey(aToken, "conditions")
					nLenCond = len(aToken["conditions"])
					for j = 1 to nLenCond
						if not This.MatchSingleToken(aToken["conditions"][j], aMatrix)
							return FALSE
						ok
					next
				ok
			
			else
				if not This.MatchSingleToken(aToken, aMatrix)
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	def MatchSingleToken(aToken, aMatrix)
		bResult = FALSE
		
		if @bDebugMode
			? "Checking token type: " + aToken["type"]
			if HasKey(aToken, "negated")
				? "Negated value: " + aToken["negated"]
			ok
		ok
		
		if HasKey(aToken, "type")
			cType = aToken["type"]
			
			if cType = "size"
				bResult = This.CheckSize(aToken, aMatrix)
			
			but cType = "shape"
				if HasKey(aToken, "value")
					bResult = This.CheckShape(aToken["value"], aMatrix)
				ok
			
			but cType = "element"
				bResult = This.CheckElements(aToken, aMatrix)
			
			but cType = "row"
				bResult = This.CheckRows(aToken, aMatrix)
			
			but cType = "col"
				bResult = This.CheckCols(aToken, aMatrix)
			
			but cType = "diagonal"
				bResult = This.CheckDiagonal(aToken, aMatrix)
			
			but cType = "property"
				if HasKey(aToken, "value")
					bResult = This.CheckProperty(aToken["value"], aMatrix)
				ok
			
			but cType = "pattern"
				if HasKey(aToken, "value")
					bResult = This.CheckPattern(aToken["value"], aMatrix)
				ok
			
			but cType = "determinant"
				bResult = This.CheckDeterminant(aToken, aMatrix)
			
			but cType = "sum"
				bResult = This.CheckSum(aToken, aMatrix)
			ok
		ok
		
		if @bDebugMode
			? "Result before negation: " + bResult
		ok
		
		if HasKey(aToken, "negated") and aToken["negated"] = 1
			if @bDebugMode
				? "Applying negation"
			ok
			bResult = not bResult
		ok
		
		if @bDebugMode
			? "Final result: " + bResult
		ok
		
		return bResult
	
	  #------------------------#
	 #  CHECKING METHODS      #
	#------------------------#
	
	def CheckSize(aToken, aMatrix)
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		
		if HasKey(aToken, "value")
			cValue = aToken["value"]
			
			if substr(cValue, "x") > 0
				aParts = @split(cValue, "x")
				if len(aParts) = 2
					cRowSpec = trim(aParts[1])
					cColSpec = trim(aParts[2])
					
					if This.IsNumeric(cRowSpec) and This.IsNumeric(cColSpec)
						return nRows = (0 + cRowSpec) and nCols = (0 + cColSpec)
					but cRowSpec = "m" or cRowSpec = "n"
						return TRUE  # Any size accepted
					ok
				ok
			ok
		ok
		
		if HasKey(aToken, "constraints")
			nLenConstr = len(aToken["constraints"])
			for i = 1 to nLenConstr
				aConstraint = aToken["constraints"][i]
				
				if HasKey(aConstraint, "type")
					cConstrType = aConstraint["type"]
					
					if cConstrType = "dimensions"
						cRowSpec = aConstraint["rows"]
						cColSpec = aConstraint["cols"]
						
						if This.IsNumeric(cRowSpec) and This.IsNumeric(cColSpec)
							if nRows != (0 + cRowSpec) or nCols != (0 + cColSpec)
								return FALSE
							ok
						ok
					
					but cConstrType = "greater"
						nMin = nRows
						if nCols < nMin
							nMin = nCols
						ok
						if nMin <= aConstraint["value"]
							return FALSE
						ok
					
					but cConstrType = "less"
						nMax = nRows
						if nCols > nMax
							nMax = nCols
						ok
						if nMax >= aConstraint["value"]
							return FALSE
						ok
					ok
				ok
			next
		ok
		
		return TRUE
	
	def CheckShape(cShape, aMatrix)
		cShape = lower(trim(cShape))
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		
		if cShape = "square"
			return nRows = nCols
		but cShape = "rectangular" or cShape = "rectangle"
			return nRows != nCols
		but cShape = "tall"
			return nRows > nCols
		but cShape = "wide"
			return nCols > nRows
		but cShape = "row" or cShape = "rowvector"
			return nRows = 1
		but cShape = "column" or cShape = "colvector"
			return nCols = 1
		ok
		
		return FALSE
	
	def CheckElements(aToken, aMatrix)
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		
		if HasKey(aToken, "constraints")
			nLenConstr = len(aToken["constraints"])
			for i = 1 to nLenConstr
				aConstraint = aToken["constraints"][i]
				
				if HasKey(aConstraint, "type")
					cConstrType = aConstraint["type"]
					
					if cConstrType = "range"
						nStart = aConstraint["start"]
						nEnd = aConstraint["end"]
						
						for r = 1 to nRows
							for c = 1 to nCols
								nVal = aMatrix[r][c]
								if nVal < nStart or nVal > nEnd
									return FALSE
								ok
							next
						next
					
					but cConstrType = "set"
						aValues = aConstraint["values"]
						for r = 1 to nRows
							for c = 1 to nCols
								bFound = FALSE
								nVal = aMatrix[r][c]
								nLenValues = len(aValues)
								for k = 1 to nLenValues
									if nVal = (0 + trim(aValues[k]))
										bFound = TRUE
										exit
									ok
								next
								if not bFound
									return FALSE
								ok
							next
						next
					
					but cConstrType = "exact"
						nTarget = aConstraint["value"]
						for r = 1 to nRows
							for c = 1 to nCols
								if aMatrix[r][c] != nTarget
									return FALSE
								ok
							next
						next
					ok
				ok
			next
		ok
		
		return TRUE
	
	def CheckRows(aToken, aMatrix)
		# Check row-specific patterns
		return TRUE
	
	def CheckCols(aToken, aMatrix)
		# Check column-specific patterns
		return TRUE
	
	def CheckDiagonal(aToken, aMatrix)
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		
		if nRows != nCols
			return FALSE  # Only square matrices have proper diagonals
		ok
		
		# Check main diagonal
		nMin = nRows
		if nCols < nMin
			nMin = nCols
		ok
		
		return TRUE
	
	def CheckProperty(cProperty, aMatrix)
		cProperty = lower(trim(cProperty))
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		
		if cProperty = "symmetric"
			if nRows != nCols
				return FALSE
			ok
			for i = 1 to nRows
				for j = 1 to nCols
					if aMatrix[i][j] != aMatrix[j][i]
						return FALSE
					ok
				next
			next
			return TRUE
		
		but cProperty = "diagonal"
			if nRows != nCols
				return FALSE
			ok
			for i = 1 to nRows
				for j = 1 to nCols
					if i != j and aMatrix[i][j] != 0
						return FALSE
					ok
				next
			next
			return TRUE
		
		but cProperty = "identity"
			if nRows != nCols
				return FALSE
			ok
			for i = 1 to nRows
				for j = 1 to nCols
					if i = j
						if aMatrix[i][j] != 1
							return FALSE
						ok
					else
						if aMatrix[i][j] != 0
							return FALSE
						ok
					ok
				next
			next
			return TRUE
		
		but cProperty = "zero"
			for i = 1 to nRows
				for j = 1 to nCols
					if aMatrix[i][j] != 0
						return FALSE
					ok
				next
			next
			return TRUE
		
		but cProperty = "upper" or cProperty = "uppertriangular"
			if nRows != nCols
				return FALSE
			ok
			for i = 1 to nRows
				for j = 1 to i-1
					if aMatrix[i][j] != 0
						return FALSE
					ok
				next
			next
			return TRUE
		
		but cProperty = "lower" or cProperty = "lowertriangular"
			if nRows != nCols
				return FALSE
			ok
			for i = 1 to nRows
				for j = i+1 to nCols
					if aMatrix[i][j] != 0
						return FALSE
					ok
				next
			next
			return TRUE
		ok
		
		return FALSE
	
	def CheckPattern(cPattern, aMatrix)
		# Check for visual/structural patterns
		return TRUE
	
	def CheckDeterminant(aToken, aMatrix)
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		
		if nRows != nCols
			return FALSE
		ok
		
		# Would call stzMatrix determinant method
		return TRUE
	
	def CheckSum(aToken, aMatrix)
		nSum = 0
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		
		for i = 1 to nRows
			for j = 1 to nCols
				nSum += aMatrix[i][j]
			next
		next
		
		if HasKey(aToken, "constraints")
			# Check sum constraints
		ok
		
		return TRUE
	
	  #----------------------#
	 #  PART EXTRACTION     #
	#----------------------#
	
	def ExtractParts(aMatrix)
		@aMatchedParts = []
		
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		
		@aMatchedParts + ["Size", [nRows, nCols]]
		@aMatchedParts + ["Matrix", aMatrix]
		
		aProps = []
		if nRows = nCols
			aProps + "Square"
			
			if This.IsSymmetric(aMatrix)
				aProps + "Symmetric"
			ok
			if This.IsDiagonal(aMatrix)
				aProps + "Diagonal"
			ok
			if This.IsIdentity(aMatrix)
				aProps + "Identity"
			ok
		else
			aProps + "Rectangular"
		ok
		
		@aMatchedParts + ["Properties", aProps]
	
	def IsSymmetric(aMatrix)
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		if nRows != nCols
			return FALSE
		ok
		for i = 1 to nRows
			for j = 1 to nCols
				if aMatrix[i][j] != aMatrix[j][i]
					return FALSE
				ok
			next
		next
		return TRUE
	
	def IsDiagonal(aMatrix)
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		if nRows != nCols
			return FALSE
		ok
		for i = 1 to nRows
			for j = 1 to nCols
				if i != j and aMatrix[i][j] != 0
					return FALSE
				ok
			next
		next
		return TRUE
	
	def IsIdentity(aMatrix)
		nRows = len(aMatrix)
		nCols = len(aMatrix[1])
		if nRows != nCols
			return FALSE
		ok
		for i = 1 to nRows
			for j = 1 to nCols
				if i = j
					if aMatrix[i][j] != 1
						return FALSE
					ok
				else
					if aMatrix[i][j] != 0
						return FALSE
					ok
				ok
			next
		next
		return TRUE
	
	  #----------------------#
	 #  QUERY METHODS       #
	#----------------------#
	
	def MatchedParts()
		return @aMatchedParts
	
	def Size()
		if HasKey(@aMatchedParts, "Size")
			return @aMatchedParts["Size"]
		ok
		return [0, 0]
	
	def Properties()
		if HasKey(@aMatchedParts, "Properties")
			return @aMatchedParts["Properties"]
		ok
		return []
	
	def Matrix()
		if HasKey(@aMatchedParts, "Matrix")
			return @aMatchedParts["Matrix"]
		ok
		return []
	
	def Tokens()
		return @aTokens
	
	def Pattern()
		return @cPattern
	
	def SetTarget(paMatrix)
		@aMatrix = paMatrix
	
	def Explain()
		aExplanation = [
			["Pattern", @cPattern],
			["TokenCount", len(@aTokens)],
			["Tokens", @aTokens]
		]
		
		if len(@aMatrix) > 0
			aExplanation + ["Target", @aMatrix]
		ok
		
		if len(@aMatchedParts) > 0
			aExplanation + ["MatchedParts", @aMatchedParts]
		ok
		
		return aExplanation
	
	  #---------------------------#
	 #  ADVANCED QUERY METHODS   #
	#---------------------------#
	
	def MatchingMatrices(paMatrices)
		if CheckParams() and isList(paMatrices) and StzListQ(paMatrices).IsInNamedPAram()
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of lists of numbers.")
		ok

		# Find all matrices in a list that match the pattern
		aMatching = []
		nLen = len(paMatrices)
		
		for i = 1 to nLen
			if This.Match(paMatrices[i])
				aMatching + paMatrices[i]
			ok
		next
		
		return aMatching
	
		def MatchingMatricesIn(paMatrices)
			return THis.MatchingMatrices(paMatrices)

	def FindMatchingMatrices(paMatrices)
		# Find all matrices in a list that match the pattern
		# and retyurning their positions in paMatrices

		if CheckParams() and isList(paMatrices) and StzListQ(paMatrices).IsInNamedPAram()
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of lists of numbers.")
		ok

		anMatching = []
		nLen = len(paMatrices)
		
		for i = 1 to nLen
			if This.Match(paMatrices[i])
				anMatching + i
			ok
		next
		
		return anMatching

		def FindMatchingMatricesIn(paMatrices)
			return This.FindMatchingMatrices(paMatrices)

	def CountMatchingMatrices(paMatrices)

		if CheckParams() and isList(paMatrices) and StzListQ(paMatrices).IsInNamedPAram()
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of matrices.")
		ok

		nCount = 0
		nLen = len(paMatrices)
		
		for i = 1 to nLen
			if This.Match(paMatrices[i])
				nCount++
			ok
		next
		
		return nCount
	
		def CountMatchingMatricesIn(paMatrices)
			return This.CountMatchingMatrices(paMatrices)

	def FirstMatchingMatrix(paMatrices)

		if CheckParams() and isList(paMatrices) and StzListQ(paMatrices).IsInNamedPAram()
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of matrices.")
		ok

		nLen = len(paMatrices)
		
		for i = 1 to nLen
			if This.Match(paMatrices[i])
				return paMatrices[i]
			ok
		next
		
		StzRaise("Can't proceed! paMatrices contains no matching matrices.")

		def FirstMatchingMatrixIn(paMatrices)
			return This.FirstMatchingMatrix(paMatrices)

	def FindFirstMatchingMatrix(paMatrices)

		if CheckParams() and isList(paMatrices) and StzListQ(paMatrices).IsInNamedPAram()
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of matrices.")
		ok

		nLen = len(paMatrices)
		
		for i = 1 to nLen
			if This.Match(paMatrices[i])
				return i
			ok
		next
		
		StzRaise("Can't proceed! paMatrices contains no matching matrices.")

		def FindFirstMatchingMatrixIn(paMatrices)
			return This.FindFirstMatchingMatrix(paMatrices)

	def MatchesNone(paMatrices)

		if CheckParams() and isList(paMatrices) and StzListQ(paMatrices).IsInNamedPAram()
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of matrices.")
		ok

		nLen = len(paMatrices)
		
		for i = 1 to nLen
			if This.Match(paMatrices[i])
				return TRUE
			ok
		next
		
		return FALSE
	
		def MatchesNoneIn(paMatrices)
			return This.MatchesNone(paMatrices)

	def MatchesAll(paMatrices)

		if CheckParams() and isList(paMatrices) and StzListQ(paMatrices).IsInNamedPAram()
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of lists of numbers.")
		ok

		nLen = len(paMatrices)
		
		for i = 1 to nLen
			if not This.Match(paMatrices[i])
				return FALSE
			ok
		next
		
		return TRUE
	
		def MatchesAllIn(paMatrices)
			return This.MatchesAll(paMatrices)
	
	  #---------------------------#
	 #  PATTERN CONSTRAINT       #
	#---------------------------#
	
	def AddConstraint(cConstraint)
		# Add a new constraint to existing pattern
		cInner = @substr(@cPattern, 2, len(@cPattern) - 1)
		if len(cInner) > 0
			cInner += " -> " + cConstraint
		else
			cInner = cConstraint
		ok
		@cPattern = "{" + cInner + "}"
		@aTokens = This.ParsePattern(@cPattern)
	
	def RemoveConstraint(nIndex)
		# Remove a constraint by index
		if nIndex > 0 and nIndex <= len(@aTokens)
			del(@aTokens, nIndex)
		ok
	
	  #-------------------------------#
	 #  MATRIX COMPARISON METHODS    #
	#-------------------------------#
	
	def SimilarityScore(aMatrix1, aMatrix2)

		if CheckParams()
			if isList(aMatrix1) and StzListQ(aMatrix1).IsBetweenNamedPAram()
				aMatix1 = aMatrix1[2]
			ok
			if isList(aMatrix1) and StzListQ(aMatrix1).IsAndNamedPAram()
				aMatix1 = aMatrix1[2]
			ok
		ok

		if NOT (IsMatrix(aMatrix1) and IsMatrix(aMatrix2))
			StzRaise("Incorrect param types! aMatrix1 and aMatrix2 must be both matrices.")
		ok

		# Calculate similarity between two matrices (0-1 scale)
		
		nRows1 = len(aMatrix1)
		nCols1 = len(aMatrix1[1])
		nRows2 = len(aMatrix2)
		nCols2 = len(aMatrix2[1])
		
		# Different sizes = low similarity
		if nRows1 != nRows2 or nCols1 != nCols2
			return 0.0
		ok
		
		# Calculate element-wise similarity
		nMatches = 0
		nTotal = nRows1 * nCols1
		
		for i = 1 to nRows1
			for j = 1 to nCols1
				if aMatrix1[i][j] = aMatrix2[i][j]
					nMatches++
				ok
			next
		next
		
		return (nMatches * 1.0) / nTotal
	
		def SimilarityScoreBetween(aMatrix1, aMatrix2)
			return This.SimilarityScore(aMatrix1, aMatrix2)

	def MostSimilarMatrix(aTargetMatrix, paMatrices)
		# Get the matrix in the list most similar to target
		
		if CheckParams()
			if isList(aTargetMatrix) and StzListQ(aTargetMatrix).IsToNamedPAram()
				aTargetMatrix = aTargetMatrix[2]
			ok
			if isList(paMatrices) and StzListQ(paMatrices).IsInNamedPAram()
				paMatrices = paMatrices[2]
			ok
		ok

		if NOT IsMatrix(aTargetMatrix)
			StzRaise("Incorrect param type! aTargetMatrix must be a mtrix.")
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a listy of matrices.")
		ok

		nBestScore = -1
		aBestMatrix = []
		nLen = len(paMatrices)
		
		for i = 1 to nLen
			nScore = This.SimilarityScore(aTargetMatrix, paMatrices[i])
			if nScore > nBestScore
				nBestScore = nScore
				aBestMatrix = paMatrices[i]
			ok
		next
		
		if len(aBestMAtrix) = 0
			StzRaise("No simular matrix found!")
		ok

		return aBestMatrix
	
	def FindMostSimilarMatrix(aTargetMatrix, paMatrices)
		# Find the matrix in the list most similar to target
		# and return its position in paMatrices
		
		if CheckParams()
			if isList(aTargetMatrix) and StzListQ(aTargetMatrix).IsToNamedPAram()
				aTargetMatrix = aTargetMatrix[2]
			ok
			if isList(paMatrices) and StzListQ(paMatrices).IsInNamedPAram()
				paMatrices = paMatrices[2]
			ok
		ok

		if NOT IsMatrix(aTargetMatrix)
			StzRaise("Incorrect param type! aTargetMatrix must be a mtrix.")
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a listy of matrices.")
		ok

		nBestScore = -1
		nBestMatrix = 0
		nLen = len(paMatrices)
		
		for i = 1 to nLen
			nScore = This.SimilarityScore(aTargetMatrix, paMatrices[i])
			if nScore > nBestScore
				nBestScore = nScore
				nBestMatrix = i
			ok
		next
		
		return nBestMatrix

	  #-------------------------------#
	 #  FILTERING OPERATION          #
	#-------------------------------#
	
	def FilterMatrices(paMatrices)
		# Filter list to only matching matrices
		return This.FindMatchingMatrices(paMatrices)
	
	  #-------------------------------#
	 #  STATISTICAL ANALYSIS         #
	#-------------------------------#
	
	def AnalyzeMatches(paMatrices)
		# Provide detailed analysis of matching matrices
		
		aAnalysis = []
		aMatching = []
		aNonMatching = []
		
		nLen = len(paMatrices)
		
		for i = 1 to nLen
			if This.Match(paMatrices[i])
				aMatching + paMatrices[i]
			else
				aNonMatching + paMatrices[i]
			ok
		next
		
		aAnalysis + ["pattern", @cPattern]
		aAnalysis + ["totalmatrices", nLen]
		aAnalysis + ["matchingcount", len(aMatching)]
		aAnalysis + ["nonmatchingcount", len(aNonMatching)]
		aAnalysis + ["matchrate", (len(aMatching) * 1.0) / nLen]
		aAnalysis + ["matching", aMatching]
		aAnalysis + ["nonmatching", aNonMatching]
		
		return aAnalysis
	
	def CommonProperties(paMatrices)
		# Find properties common to all matching matrices
		
		aCommon = []
		aAllProps = ["square", "symmetric", "diagonal", "identity", 
		             "zero", "upper", "lower"]
		
		nLenProps = len(aAllProps)
		
		for i = 1 to nLenProps
			cProp = aAllProps[i]
			bAll = TRUE
			
			nLen = len(paMatrices)
			for j = 1 to nLen
				if This.Match(paMatrices[j])
					if not This.CheckProperty(cProp, paMatrices[j])
						bAll = FALSE
						exit
					ok
				ok
			next
			
			if bAll
				aCommon + cProp
			ok
		next
		
		return aCommon
	
	  #----------------------#
	 #  DEBUG METHODS       #
	#----------------------#
	
	def EnableDebug()
		@bDebugMode = TRUE
		@aTokens = This.ParsePattern(@cPattern)

	def DisableDebug()
		@bDebugMode = FALSE
	
	def SetDebug(bFlag)
		@bDebugMode = bFlag
	
	  #----------------------#
	 #  HELPER METHODS      #
	#----------------------#
	
	def IsNumeric(cStr)
		if cStr = ""
			return FALSE
		ok
		
		nLen = len(cStr)
		for i = 1 to nLen
			cChar = @substr(cStr, i, i)
			if not isDigit(cChar) and cChar != "-" and cChar != "."
				return FALSE
			ok
		next
		
		return TRUE
	
	  #-----------------------#
	 #  PATTERN COMBINATION  #
	#-----------------------#
	
	def And_(oOtherMatrex)
		if CheckParams() and NOT IsStzMatrex(oOtherMatrex)
			StzRaise("Incorrect param! oOtherMatrex must be a stzMatrex object (matrEx not matrIx).")
		ok

		# Combine two patterns with AND logic
		cCombined = "{" + 
		            @substr(@cPattern, 2, len(@cPattern) - 1) + 
		            " & " + 
		            @substr(oOtherMatrex.Pattern(), 2, len(oOtherMatrex.Pattern()) - 1) +
		            "}"

		return new stzMatrex(cCombined)
	
		def Andd(oOtherMatrex)
			return THis.And_(oOtherMatriex)

	def Or_(oOtherMatrex)
		if CheckParams() and NOT IsStzMatrex(oOtherMatrex)
			StzRaise("Incorrect param! oOtherMatrex must be a stzMatrex object (matrEx not matrIx).")
		ok

		# Combine two patterns with OR logic
		cCombined = "{" + 
		            @substr(@cPattern, 2, len(@cPattern) - 1) + 
		            " | " + 
		            @substr(oOtherMatrex.Pattern(), 2, len(oOtherMatrex.Pattern()) - 1) +
		            "}"

		return new stzMatrex(cCombined)
	
	def Not_()
		# Negate the entire pattern
		cInner = @substr(@cPattern, 2, len(@cPattern) - 1)
		cNegated = "{@!" + cInner + "}"
		return new stzMatrex(cNegated)
	
	
	  #-------------------------------#
	 #  SERIALIZATION                #
	#-------------------------------#
	
	def ToJSON()
		# Convert pattern to JSON representation
		cJSON = '{'
		cJSON += '"pattern":"' + @cPattern + '",'
		cJSON += '"tokens":' + This.TokensToJSON()
		cJSON += '}'
		return cJSON
	
	def TokensToJSON()
		# Convert tokens to JSON array
		cJSON = '['
		nLen = len(@aTokens)
		for i = 1 to nLen
			if i > 1
				cJSON += ','
			ok
			cJSON += This.TokenToJSON(@aTokens[i])
		next
		cJSON += ']'
		return cJSON
	
	def TokenToJSON(aToken)
		# Convert single token to JSON
		cJSON = '{'
		nLen = len(aToken)
		for i = 1 to nLen step 2
			if i > 1
				cJSON += ','
			ok
			cJSON += '"' + aToken[i] + '":"' + aToken[i+1] + '"'
		next
		cJSON += '}'
		return cJSON
