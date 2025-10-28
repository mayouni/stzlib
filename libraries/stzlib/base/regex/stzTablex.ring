# stzTablex - Declarative Pattern Matching for Tables in Softanza
# A regex-like pattern language for stzTable structures

# Quick constructor functions
func StzTablexQ(cPattern)
	return new stzTablex(cPattern)

func Tablex(cPattern)
	return new stzTablex(cPattern)

func Tbx(cPattern)
	return new stzTablex(cPattern)

func IsStzTablex(pObj)
	if isObject(pObj) and classname(pObj) = "stztablex"
		return TRUE
	else
		return FALSE
	ok

class stzTablex from stzObject
	
	@cPattern           # Pattern string
	@aTokens            # Parsed token definitions
	@oTable = NULL      # Target table to match
	@bDebugMode = FALSE # Debug flag
	@aMatchedParts = [] # Extracted parts
	
	@aMatchCache = []  # Store [pattern, tableHash, result]
	@nMaxCacheSize = 100
	
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
			? "=== stzTablex Init ==="
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
		# Remove outer braces
		cInner = @substr(cPattern, 2, len(cPattern) - 1)
		cInner = trim(cInner)
		
		if @bDebugMode
			? "Parsing inner pattern: " + cInner
		ok
		
		# Split by logical operators -> (sequence), & (and), | (or)
		aParts = This.SplitByOperator(cInner, "->")
		aTokens = []
		
		for i = 1 to len(aParts)
			cPart = trim(aParts[i])
			
			if cPart = ""
				loop
			ok
			
			if substr(cPart, "|") > 0
				aToken = This.ParseAlternation(cPart)

			but substr(cPart, "&") > 0
				aToken = This.ParseConjunction(cPart)

			else
				aToken = This.ParseSingleToken(cPart)
			ok
			
			aTokens + aToken
		next
		
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
		
		aParts = This.SplitByOperator(cTokenStr, "|")
		aAlternatives = []
		
		for i = 1 to len(aParts)
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
			["negated", FALSE]
		]
	
	def ParseConjunction(cTokenStr)
		if startsWith(cTokenStr, "(") and endsWith(cTokenStr, ")")
			cTokenStr = @substr(cTokenStr, 2, len(cTokenStr) - 1)
		ok
		
		aParts = This.SplitByOperator(cTokenStr, "&")

		aConditions = []
		
		for i = 1 to len(aParts)
			cPart = trim(aParts[i])
			if cPart != ""
				aToken = This.ParseSingleToken(cPart)
				aConditions + aToken
			ok
		next
		
		return [
			["type", "conjunction"],
			["conditions", aConditions],
			["negated", FALSE]
		]
	
def ParseSingleToken(cTokenStr)
	cTokenStr = trim(cTokenStr)
	if cTokenStr = ""
		return []
	ok
	
	if @bDebugMode
		? "=== ParseSingleToken ==="
		? "Input: " + cTokenStr
	ok
	
	bNegated = FALSE
	bCaseSensitive = FALSE
	
	# Check for negation
	if startsWith(lower(cTokenStr), "@!")
		bNegated = TRUE
		cTokenStr = @substr(cTokenStr, 3, len(cTokenStr))
	ok
	
	# Check for case sensitivity flag
	if startsWith(lower(cTokenStr), "@cs:")
		bCaseSensitive = TRUE
		cTokenStr = @substr(cTokenStr, 5, len(cTokenStr))
	ok
	
	cType = ""
	cValue = ""
	aConstraints = []
	nMin = 1
	nMax = 1
	
	# Extract and preserve content in parentheses BEFORE lowercasing
	cPreservedValue = ""
	nOpenParen = substr(cTokenStr, "(")
	if nOpenParen > 0
		nCloseParen = substr(cTokenStr, ")")
		if nCloseParen > nOpenParen
			cPreservedValue = @substr(cTokenStr, nOpenParen + 1, nCloseParen - 1)
			if @bDebugMode
				? "Preserved value: " + cPreservedValue
			ok
		ok
	ok
	
	# NOW lowercase the token string for type detection
	cTokenStr = lower(cTokenStr)
	
	if @bDebugMode
		? "After lowercase: " + cTokenStr
	ok
	
	# Parse token types (same as before...)
	#WARNING// The order is imprtant, for example:
	# all col* variants mustappear before the generic col check.

	if startsWith(cTokenStr, "@cols") or startsWith(cTokenStr, "cols")
		cType = "cols"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@cols", "cols"])
		
	but startsWith(cTokenStr, "@rows") or startsWith(cTokenStr, "rows")
		cType = "rows"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@rows", "rows"])
		
	but startsWith(cTokenStr, "@hascol") or startsWith(cTokenStr, "hascol")
		cType = "hascol"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@hascol", "hascol"])
		
	but startsWith(cTokenStr, "@coltype") or startsWith(cTokenStr, "coltype")
		cType = "coltype"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@coltype", "coltype"])

	but startsWith(cTokenStr, "@colpattern") or startsWith(cTokenStr, "colpattern")
		cType = "colpattern"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@colpattern", "colpattern"])

	but startsWith(cTokenStr, "@colname") or startsWith(cTokenStr, "colname")
		cType = "colname"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@colname", "colname"])

	but startsWith(cTokenStr, "@sumcol") or startsWith(cTokenStr, "sumcol")
		cType = "sumcol"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@sumcol", "sumcol"])
		
	but startsWith(cTokenStr, "@avgcol") or startsWith(cTokenStr, "avgcol")
		cType = "avgcol"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@avgcol", "avgcol"])
		
	but startsWith(cTokenStr, "@mincol") or startsWith(cTokenStr, "mincol")
		cType = "mincol"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@mincol", "mincol"])
		
	but startsWith(cTokenStr, "@maxcol") or startsWith(cTokenStr, "maxcol")
		cType = "maxcol"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@maxcol", "maxcol"])
		
	but startsWith(cTokenStr, "@col") or startsWith(cTokenStr, "col")
		cType = "col"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@col", "col"])
		
	but startsWith(cTokenStr, "@row") or startsWith(cTokenStr, "row")
		cType = "row"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@row", "row"])
		
	but startsWith(cTokenStr, "@cell") or startsWith(cTokenStr, "cell")
		cType = "cell"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@cell", "cell"])
				
	but startsWith(cTokenStr, "@property") or startsWith(cTokenStr, "property")
		cType = "property"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@property", "property"])
		
	but startsWith(cTokenStr, "@contains") or startsWith(cTokenStr, "contains")
		cType = "contains"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@contains", "contains"])
		
	but startsWith(cTokenStr, "@sorted") or startsWith(cTokenStr, "sorted")
		cType = "sorted"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@sorted", "sorted"])
		
	but startsWith(cTokenStr, "@unique") or startsWith(cTokenStr, "unique")
		cType = "unique"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@unique", "unique"])
		
	but startsWith(cTokenStr, "@duplicates") or startsWith(cTokenStr, "duplicates")
		cType = "duplicates"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@duplicates", "duplicates"])
		
	but startsWith(cTokenStr, "@grouped") or startsWith(cTokenStr, "grouped")
		cType = "grouped"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@grouped", "grouped"])
		
	but startsWith(cTokenStr, "@filtered") or startsWith(cTokenStr, "filtered")
		cType = "filtered"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@filtered", "filtered"])
		
	but startsWith(cTokenStr, "@aggregated") or startsWith(cTokenStr, "aggregated")
		cType = "aggregated"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@aggregated", "aggregated"])
		
	but startsWith(cTokenStr, "@transposed") or startsWith(cTokenStr, "transposed")
		cType = "transposed"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@transposed", "transposed"])
		
	but startsWith(cTokenStr, "@calculated") or startsWith(cTokenStr, "calculated")
		cType = "calculated"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@calculated", "calculated"])

	but startsWith(cTokenStr, "@nulls") or startsWith(cTokenStr, "nulls")
		cType = "nulls"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@nulls", "nulls"])
		
	but startsWith(cTokenStr, "@completeness") or startsWith(cTokenStr, "completeness")
		cType = "completeness"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@completeness", "completeness"])
		
	but startsWith(cTokenStr, "@numeric") or startsWith(cTokenStr, "numeric")
		cType = "numeric"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@numeric", "numeric"])
		
	but startsWith(cTokenStr, "@alphabetic") or startsWith(cTokenStr, "alphabetic")
		cType = "alphabetic"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@alphabetic", "alphabetic"])
		
	but startsWith(cTokenStr, "@format") or startsWith(cTokenStr, "format")
		cType = "format"
		cTokenStr = This.RemovePrefix(cTokenStr, ["@format", "format"])
		
	else
		return [
			["type", "ERROR"],
			["value", cTokenStr],
			["message", "Unrecognized token type"]
		]
	ok
	
	if @bDebugMode
		? "Detected type: " + cType
	ok
	
	# Parse parentheses content - use preserved value
	nOpenParen = substr(cTokenStr, "(")
	if nOpenParen > 0
		nCloseParen = substr(cTokenStr, ")")
		if nCloseParen > nOpenParen
			cContent = cPreservedValue
			
			if cType = "property" or cType = "colname" or 
			   cType = "contains" or cType = "sorted" or 
			   cType = "unique" or cType = "duplicates" or cType = "hascol" or 
			   cType = "grouped" or cType = "filtered" or cType = "calculated" or
			   cType = "nulls" or cType = "numeric" or cType = "alphabetic" or
			   cType = "coltype" or cType = "colpattern" or 
			   cType = "sumcol" or cType = "avgcol" or cType = "mincol" or cType = "maxcol" or
			   cType = "completeness" or cType = "format"
				cValue = cContent

				if @bDebugMode
					? "Assigned cValue: " + cValue
				ok
			else
				aConstraints = This.ParseConstraints(cContent, cType)
				if @bDebugMode
					? "Parsed constraints: " + @@(aConstraints)
				ok
			ok
		ok
	ok
	
	# Parse quantifiers (same as before...)
	cQuantPart = ""
	if nCloseParen > 0 and nCloseParen < len(cTokenStr)
		cQuantPart = @substr(cTokenStr, nCloseParen + 1, len(cTokenStr))
	ok
	
	cQuantPart = trim(cQuantPart)
	
	if len(cQuantPart) > 0
		if substr(cQuantPart, "-") > 0
			aSection = @split(cQuantPart, "-")
			if len(aSection) = 2
				nMin = 0 + trim(aSection[1])
				nMax = 0 + trim(aSection[2])
			ok
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
				nMin = 0 + cQuantPart
				nMax = nMin
			ok
		ok
	ok
	
	aResult = [
		["type", cType],
		["value", cValue],
		["constraints", aConstraints],
		["min", nMin],
		["max", nMax],
		["negated", bNegated],
		["casesensitive", bCaseSensitive]
	]
	
	if @bDebugMode
		? "Result token: " + @@(aResult)
	ok
	
	return aResult
	
	def RemovePrefix(cStr, aPrefixes)
		for i = 1 to len(aPrefixes)
			if startsWith(cStr, aPrefixes[i])
				return @substr(cStr, len(aPrefixes[i]) + 1, len(cStr))
			ok
		next
		return cStr
	
	def ParseConstraints(cConstraintStr, cType)
		aConstraints = []
		
		if cConstraintStr = ""
			return aConstraints
		ok
		
		# Parse based on type
		switch cType
		on "cols"
			if This.IsNumeric(cConstraintStr)
				aConstraints + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
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
			
		on "rows"
			if This.IsNumeric(cConstraintStr)
				aConstraints + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
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
			
		on "cell"
			if substr(cConstraintStr, "..") > 0
				aParts = @split(cConstraintStr, "..")
				if len(aParts) = 2
					aConstraints + [
						["type", "range"],
						["start", trim(aParts[1])],
						["end", trim(aParts[2])]
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
			ok
		off
		
		return aConstraints
	
	  #--------------------#
	 #  MATCHING LOGIC    #
	#--------------------#
	
	def Match(poTable)
		if NOT IsStzTable(poTable)
			StzRaise("Incorrect param type! poTable must be a stzTable object.")
		ok
		
		# Check cache
		cTableSig = This.TableSignature(poTable)
		cCacheKey = @cPattern + "|" + cTableSig
		
		for i = 1 to len(@aMatchCache)
			if @aMatchCache[i][1] = cCacheKey
				if @bDebugMode
					? "Cache hit!"
				ok
				return @aMatchCache[i][2]
			ok
		next
		
		# Not cached - compute
		@oTable = poTable
		bResult = This.MatchTokens(@aTokens, @oTable)
		
		if bResult
			This.ExtractParts(@oTable)
		ok
		
		# Store in cache
		@aMatchCache + [cCacheKey, bResult]
		if len(@aMatchCache) > @nMaxCacheSize
			del(@aMatchCache, 1)  # Remove oldest
		ok
		
		return bResult
	
	def MatchTokens(aTokens, oTable)
		for i = 1 to len(aTokens)
			aToken = aTokens[i]
			
			if HasKey(aToken, "type") and aToken["type"] = "alternation"
				bMatched = FALSE
				if HasKey(aToken, "alternatives")
					for j = 1 to len(aToken["alternatives"])
						if This.MatchSingleToken(aToken["alternatives"][j], oTable)
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
					for j = 1 to len(aToken["conditions"])
						if not This.MatchSingleToken(aToken["conditions"][j], oTable)
							return FALSE
						ok
					next
				ok
			
			else
				if not This.MatchSingleToken(aToken, oTable)
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	def MatchSingleToken(aToken, oTable)
		bResult = FALSE
		
		if HasKey(aToken, "type")
			cType = aToken["type"]
			
			if cType = "cols"
				bResult = This.CheckCols(aToken, oTable)
			
			but cType = "rows"
				bResult = This.CheckRows(aToken, oTable)
			
			but cType = "col"
				bResult = This.CheckCol(aToken, oTable)
			
			but cType = "row"
				bResult = This.CheckRow(aToken, oTable)
			
			but cType = "cell"
				bResult = This.CheckCell(aToken, oTable)
			
			but cType = "colname"
				bResult = This.CheckColName(aToken, oTable)
			
			but cType = "property"
				bResult = This.CheckProperty(aToken, oTable)
			
			but cType = "contains"
				bResult = This.CheckContains(aToken, oTable)
			
			but cType = "sorted"
				bResult = This.CheckSorted(aToken, oTable)
			
			but cType = "unique"
				bResult = This.CheckUnique(aToken, oTable)
			
			but cType = "duplicates"
				bResult = This.CheckDuplicates(aToken, oTable)
			
			but cType = "grouped"
				bResult = This.CheckGrouped(aToken, oTable)
			
			but cType = "filtered"
				bResult = This.CheckFiltered(aToken, oTable)
			
			but cType = "aggregated"
				bResult = This.CheckAggregated(aToken, oTable)
			
			but cType = "transposed"
				bResult = This.CheckTransposed(aToken, oTable)
			
			but cType = "calculated"
				bResult = This.CheckCalculated(aToken, oTable)
			
			but cType = "hascol"
				bResult = This.CheckHasCol(aToken, oTable)
			
			but cType = "coltype"
				bResult = This.CheckColType(aToken, oTable)
			
			but cType = "colpattern"
				bResult = This.CheckColPattern(aToken, oTable)
			
			but cType = "sumcol"
				bResult = This.CheckSumCol(aToken, oTable)
			
			but cType = "avgcol"
				bResult = This.CheckAvgCol(aToken, oTable)
			
			but cType = "mincol"
				bResult = This.CheckMinCol(aToken, oTable)
			
			but cType = "maxcol"
				bResult = This.CheckMaxCol(aToken, oTable)
			
			but cType = "nulls"
				bResult = This.CheckNulls(aToken, oTable)
			
			but cType = "completeness"
				bResult = This.CheckCompleteness(aToken, oTable)
			
			but cType = "numeric"
				bResult = This.CheckNumeric(aToken, oTable)
			
			but cType = "alphabetic"
				bResult = This.CheckAlphabetic(aToken, oTable)
			
			but cType = "format"
				bResult = This.CheckFormat(aToken, oTable)
			ok
		ok
		
		# Apply negation
		if HasKey(aToken, "negated") and aToken["negated"] = TRUE
			bResult = not bResult
		ok
		
		return bResult
	
	  #------------------------#
	 #  CHECKING METHODS      #
	#------------------------#
	
	def CheckCols(aToken, oTable)
		nCols = oTable.NumberOfColumns()
		
		if HasKey(aToken, "constraints")
			aConstraints = aToken["constraints"]
			nLen = len(aConstraints)

			for i = 1 to nLen
				aConstraint = aConstraints[i]
				
				if HasKey(aConstraint, "type")
					switch aConstraint["type"]
					on "exact"
						if nCols = aConstraint["value"]
							return TRUE
						ok
					on "greater"
						if nCols >= aConstraint["value"]
							return TRUE
						ok
					on "less"
						if nCols <= aConstraint["value"]
							return TRUE
						ok
					off
				ok
			next
		ok
		
		return FALSE
	
	def CheckRows(aToken, oTable)
		nRows = oTable.NumberOfRows()
		aConstraints = aToken["constraints"]
		nLen = len(aConstraints)

		if HasKey(aToken, "constraints")
			for i = 1 to nLen
				aConstraint = aConstraints[i]
				
				if HasKey(aConstraint, "type")
					switch aConstraint["type"]
					on "exact"
						if nRows = aConstraint["value"]
							return TRUE
						ok
					on "greater"
						if nRows >= aConstraint["value"]
							return TRUE
						ok
					on "less"
						if nRows <= aConstraint["value"]
							return TRUE
						ok
					off
				ok
			next
		ok
		
		return FALSE
	
	def CheckCol(aToken, oTable)
		# Check specific column properties
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			return oTable.HasColumn(cColName)
		ok
		return FALSE
	
	def CheckRow(aToken, oTable)
		# Check specific column properties
		if HasKey(aToken, "value")
			aRow = aToken["value"]
			return oTable.HasRow(aRow)
		ok
		return FALSE
	
	def CheckCell(aToken, oTable)
		# Check cell value constraints across table
		if HasKey(aToken, "constraints")
			aConstraints = aToken["constraints"]
			nLen = len(aConstraints)

			for i = 1 to nLen
				aConstraint = aConstraints[i]
				
				if HasKey(aConstraint, "type")
					if aConstraint["type"] = "range"
						aRange = aToken["range"]
						if HasKey(aToken, "casesensitive")
							return oTable.ContainsInSectionCS(aRange[1], aRange[2], aToken["value"], TRUE)
						else
							return oTable.ContainsInSectionCS(aRange[1], aRange[2], aToken["value"], FALSE)
						ok
					ok
				ok
			next
		ok
		return FALSE
	
	def CheckColName(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			return oTable.HasColName(cColName)
		ok
		return FALSE
	
	def CheckProperty(aToken, oTable)
		if HasKey(aToken, "value")
			cProperty = lower(trim(aToken["value"]))
			
			switch cProperty
			on "empty"
				return oTable.IsEmpty()
			on "nonempty"
				return not oTable.IsEmpty()
			on "sorted"
				# Check if table is sorted
				return oTable.IsSorted()

			on "calculated"
				# Check if has calculated columns
				return len(oTable.FindCalculatedCols()) > 0
			off
		ok
		return TRUE
	
	def CheckContains(aToken, oTable)
		if HasKey(aToken, "value")
			cValue = aToken["value"]
			_value_ = cValue
			
			bCaseSensitive = FALSE
			if HasKey(aToken, "casesensitive")
				bCaseSensitive = aToken["casesensitive"]
			ok

			if IsNumberInString(cValue)
				_value_ = 0+ cValue

			but IsListInString(cValue)
				cCode = "_value_ = " + cValue
				eval(cCode)
			ok

			# WARNING: The pattern does not understand values
			# of type OBJECT, only NUMBER, STRING and LIST.
			# TODO: Clarify this in the documentation

			# Check with case sensitivity
			if bCaseSensitive
				bResult = oTable.ContainsCellCS(_value_, TRUE)
			else
				bResult = oTable.ContainsCellCS(_value_, FALSE)
			ok
			
			return bResult
		ok

		return FALSE
	
	def CheckSorted(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			if oTable.HasColumn(cColName)
				bCaseSensitive = TRUE  # Default to case-sensitive
				if HasKey(aToken, "casesensitive")
					bCaseSensitive = aToken["casesensitive"]
				ok
				
				aCol = oTable.Col(cColName)
				nLen = len(aCol)
				
				# Check if sorted ascending
				for i = 1 to nLen - 1
					xCurrent = aCol[i]
					xNext = aCol[i+1]
					
					if isString(xCurrent) and isString(xNext)
						if bCaseSensitive
							if StzStringQ(xCurrent) > xNext
								return FALSE
							ok
						else
							if StzStringQ(lower(xCurrent)) > lower(xNext)
								return FALSE
							ok
						ok
	
					but isNumber(xCurrent) and isNumber(xNext)
						if xCurrent > xNext
							return FALSE
						ok
					ok
				next
				return TRUE
			ok
		ok
		return TRUE
	
	def CheckUnique(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			if oTable.HasColumn(cColName)
				bCaseSensitive = TRUE  # Default to case-sensitive for unique
				if HasKey(aToken, "casesensitive")
					bCaseSensitive = aToken["casesensitive"]
				ok
				
				aCol = oTable.Col(cColName)
				
				if bCaseSensitive
					return len(aCol) = len(U(aCol))
				else
					# Case-insensitive: lowercase all values first
					aLower = []
					for i = 1 to len(aCol)
						if isString(aCol[i])
							aLower + lower(aCol[i])
						else
							aLower + aCol[i]
						ok
					next
					return len(aLower) = len(U(aLower))
				ok
			ok
		ok
		return TRUE
	
	def CheckDuplicates(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			if oTable.HasColumn(cColName)
				bCaseSensitive = FALSE
				if HasKey(aToken, "casesensitive")
					bCaseSensitive = aToken["casesensitive"]
				ok
				
				aCol = oTable.Col(cColName)
				if bCaseSensitive
					return len(aCol) > len(U(aCol))
				else
					# Case-insensitive duplicates check
					aLower = []
					nLen = len(aCol)
					for i = 1 to nLen
						if isString(aCol[i])
							aLower + lower(aCol[i])
						else
							aLower + aCol[i]
						ok
					next
					return len(aLower) > len(U(aLower))
				ok
			ok
		ok
		return FALSE
	
	def CheckGrouped(aToken, oTable)
		if @bDebugMode
			? "=== CheckGrouped ==="
			? "Token: " + @@(aToken)
		ok
		
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			
			if @bDebugMode
				? "Column name: " + cColName
				? "Has column: " + oTable.HasColumn(cColName)
			ok
			
			if oTable.HasColumn(cColName)
				bCaseSensitive = FALSE
				if HasKey(aToken, "casesensitive")
					bCaseSensitive = aToken["casesensitive"]
				ok
				
				if @bDebugMode
					? "Case sensitive: " + bCaseSensitive
				ok
				
				aCol = oTable.Col(cColName)
				nConsecutiveDups = 0
				nLen = len(aCol)
				
				if @bDebugMode
					? "Column data: " + @@(aCol)
				ok
				
				for i = 1 to nLen - 1
					xCurrent = aCol[i]
					xNext = aCol[i+1]
					
					bMatch = FALSE
					if isString(xCurrent) and isString(xNext)
						if bCaseSensitive
							bMatch = (xCurrent = xNext)
						else
							bMatch = (lower(xCurrent) = lower(xNext))
						ok
					else
						bMatch = (xCurrent = xNext)
					ok
					
					if @bDebugMode
						? "Comparing [" + i + "] '" + xCurrent + "' vs [" + (i+1) + "] '" + xNext + "': " + bMatch
					ok
					
					if bMatch
						nConsecutiveDups++
					ok
				next
				
				if @bDebugMode
					? "Consecutive duplicates found: " + nConsecutiveDups
				ok
				
				return nConsecutiveDups > 0
			ok
		ok
		return FALSE
	
	def CheckFiltered(aToken, oTable)
		# Check if table shows signs of filtering (non-sequential IDs, gaps in data)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			if oTable.HasColumn(cColName)
				aCol = oTable.Col(cColName)
				nLen = len(aCol)
				
				# Check for gaps in numeric sequence
				if nLen > 1
					for i = 1 to nLen
						if NOT isNumber(aCol[i])
							return FALSE
						ok
					next
					# Check for non-sequential numbers
					for i = 1 to nLen - 1
						if aCol[i+1] - aCol[i] > 1
							return TRUE
						ok
					next
				ok
			ok
		ok
		return FALSE
	
	def CheckAggregated(aToken, oTable)
		# Check if table contains aggregated data (calculated rows/cols)
		return len(oTable.FindCalculatedRows()) > 0 or 
		       len(oTable.FindCalculatedCols()) > 0
	
	def CheckTransposed(aToken, oTable)
		# Check if table structure suggests it's transposed (more cols than rows)
		return oTable.NumberOfColumns() > oTable.NumberOfRows()
	
	def CheckCalculated(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			if oTable.HasColumn(cColName)
				anCalcCols = oTable.FindCalculatedCols()
				nColPos = oTable.FindCol(cColName)
				return ring_find(anCalcCols, nColPos) > 0
			ok
		else
			# Check if any calculated columns exist
			return len(oTable.FindCalculatedCols()) > 0
		ok
		return FALSE
	
	def CheckHasCol(aToken, poTable)

		if HasKey(aToken, "value")
			cColName = aToken["value"]
			return poTable.HasColumn(cColName)
		ok
		return FALSE
	
	def CheckColType(aToken, oTable)
		if HasKey(aToken, "value")
			# Format: colname:type (e.g., "salary:number")
			if substr(aToken["value"], ":") > 0
				aParts = @split(aToken["value"], ":")
				if len(aParts) = 2
					cColName = trim(aParts[1])
					cType = lower(trim(aParts[2]))
					
					if oTable.HasColumn(cColName)
						aCol = oTable.Col(cColName)
						nLen = len(aCol)
						
						switch cType
						on "number"
							for i = 1 to nLen
								if NOT isNumber(aCol[i])
									return FALSE
								ok
							next
							return TRUE
							
						on "string"
							for i = 1 to nLen
								if NOT isString(aCol[i])
									return FALSE
								ok
							next
							return TRUE
							
						on "list"
							for i = 1 to nLen
								if NOT isList(aCol[i])
									return FALSE
								ok
							next
							return TRUE
						off
					ok
				ok
			ok
		ok
		return FALSE
	
	def CheckColPattern(aToken, oTable)
		if HasKey(aToken, "value")
			# Format: colname:pattern (e.g., "email:@EMAIL")
			if substr(aToken["value"], ":") > 0
				aParts = @split(aToken["value"], ":")
				if len(aParts) = 2
					cColName = trim(aParts[1])
					cPattern = trim(aParts[2])
					
					if oTable.HasColumn(cColName)
						aCol = oTable.Col(cColName)
						nLen = len(aCol)
						
						# Check if all values match the pattern
						for i = 1 to nLen
							if isString(aCol[i])
								if NOT Q(aCol[i]).MatchesRX(cPattern)
									return FALSE
								ok
							ok
						next
						return TRUE
					ok
				ok
			ok
		ok
		return FALSE
	
	def CheckSumCol(aToken, oTable)
		if HasKey(aToken, "value")
			# Format: colname:value or colname:>value or colname:<value
			if substr(aToken["value"], ":") > 0
				aParts = @split(aToken["value"], ":")
				if len(aParts) = 2
					cColName = trim(aParts[1])
					cConstraint = trim(aParts[2])
					
					if oTable.HasColumn(cColName)
						aCol = oTable.Col(cColName)
						nSum = 0
						nLen = len(aCol)
						
						for i = 1 to nLen
							if isNumber(aCol[i])
								nSum += aCol[i]
							ok
						next
						
						if startsWith(cConstraint, ">")
							return nSum > (0 + @substr(cConstraint, 2, len(cConstraint)))
						but startsWith(cConstraint, "<")
							return nSum < (0 + @substr(cConstraint, 2, len(cConstraint)))
						but This.IsNumeric(cConstraint)
							return nSum = (0 + cConstraint)
						ok
					ok
				ok
			ok
		ok
		return FALSE
	
	def CheckAvgCol(aToken, oTable)
		if HasKey(aToken, "value")
			if substr(aToken["value"], ":") > 0
				aParts = @split(aToken["value"], ":")
				if len(aParts) = 2
					cColName = trim(aParts[1])
					cConstraint = trim(aParts[2])
					
					if oTable.HasColumn(cColName)
						aCol = oTable.Col(cColName)
						nSum = 0
						nCount = 0
						for i = 1 to len(aCol)
							if isNumber(aCol[i])
								nSum += aCol[i]
								nCount++
							ok
						next
						
						if nCount > 0
							nAvg = nSum / nCount
							
							if startsWith(cConstraint, ">")
								return nAvg > (0 + @substr(cConstraint, 2, len(cConstraint)))
							but startsWith(cConstraint, "<")
								return nAvg < (0 + @substr(cConstraint, 2, len(cConstraint)))
							but This.IsNumeric(cConstraint)
								return nAvg = (0 + cConstraint)
							ok
						ok
					ok
				ok
			ok
		ok
		return FALSE
	
	def CheckMinCol(aToken, oTable)
		if HasKey(aToken, "value")
			if substr(aToken["value"], ":") > 0
				aParts = @split(aToken["value"], ":")
				if len(aParts) = 2
					cColName = trim(aParts[1])
					cConstraint = trim(aParts[2])
					
					if oTable.HasColumn(cColName)
						aCol = oTable.Col(cColName)
						nMin = NULL
						for i = 1 to len(aCol)
							if isNumber(aCol[i])
								if nMin = NULL
									nMin = aCol[i]
								but aCol[i] < nMin
									nMin = aCol[i]
								ok
							ok
						next
						
						if nMin != NULL
							if startsWith(cConstraint, ">")
								return nMin > (0 + @substr(cConstraint, 2, len(cConstraint)))
							but startsWith(cConstraint, "<")
								return nMin < (0 + @substr(cConstraint, 2, len(cConstraint)))
							but This.IsNumeric(cConstraint)
								return nMin = (0 + cConstraint)
							ok
						ok
					ok
				ok
			ok
		ok
		return FALSE
	
	def CheckMaxCol(aToken, oTable)
		if HasKey(aToken, "value")
			if substr(aToken["value"], ":") > 0
				aParts = @split(aToken["value"], ":")
				if len(aParts) = 2
					cColName = trim(aParts[1])
					cConstraint = trim(aParts[2])
					
					if oTable.HasColumn(cColName)
						aCol = oTable.Col(cColName)
						nMax = NULL
						for i = 1 to len(aCol)
							if isNumber(aCol[i])
								if nMax = NULL
									nMax = aCol[i]
								but aCol[i] > nMax
									nMax = aCol[i]
								ok
							ok
						next
						
						if nMax != NULL
							if startsWith(cConstraint, ">")
								return nMax > (0 + @substr(cConstraint, 2, len(cConstraint)))
							but startsWith(cConstraint, "<")
								return nMax < (0 + @substr(cConstraint, 2, len(cConstraint)))
							but This.IsNumeric(cConstraint)
								return nMax = (0 + cConstraint)
							ok
						ok
					ok
				ok
			ok
		ok
		return FALSE
	
	def CheckNulls(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			if oTable.HasColumn(cColName)
				aCol = oTable.Col(cColName)
				for i = 1 to len(aCol)
					if aCol[i] = NULL or aCol[i] = "" or aCol[i] = 0
						return TRUE
					ok
				next
			ok
		ok
		return FALSE
	
	def CheckCompleteness(aToken, oTable)
		if HasKey(aToken, "value")
			# Format: colname:percentage (e.g., "email:90" means 90% complete)
			if substr(aToken["value"], ":") > 0
				aParts = @split(aToken["value"], ":")
				if len(aParts) = 2
					cColName = trim(aParts[1])
					cPercent = trim(aParts[2])
					
					if oTable.HasColumn(cColName) and This.IsNumeric(cPercent)
						aCol = oTable.Col(cColName)
						nNonEmpty = 0
						for i = 1 to len(aCol)
							if aCol[i] != NULL and aCol[i] != "" and aCol[i] != 0
								nNonEmpty++
							ok
						next
						nCompleteness = (nNonEmpty * 100.0) / len(aCol)
						return nCompleteness >= (0 + cPercent)
					ok
				ok
			ok
		ok
		return FALSE
	
	def CheckNumeric(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			if oTable.HasColumn(cColName)
				aCol = oTable.Col(cColName)
				for i = 1 to len(aCol)
					if NOT isNumber(aCol[i])
						return FALSE
					ok
				next
				return TRUE
			ok
		ok
		return FALSE
	
	def CheckAlphabetic(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			if oTable.HasColumn(cColName)
				aCol = oTable.Col(cColName)
				for i = 1 to len(aCol)
					if isString(aCol[i])
						if NOT Q(aCol[i]).IsAlphabetic()
							return FALSE
						ok
					else
						return FALSE
					ok
				next
				return TRUE
			ok
		ok
		return FALSE
	
	def CheckFormat(aToken, oTable)
		if HasKey(aToken, "value")
			# Format: colname:format (e.g., "date:YYYY-MM-DD")
			if substr(aToken["value"], ":") > 0
				aParts = @split(aToken["value"], ":")
				if len(aParts) = 2
					cColName = trim(aParts[1])
					cFormat = trim(aParts[2])
					
					if oTable.HasColumn(cColName)
						aCol = oTable.Col(cColName)
						# Check if values match the format pattern
						for i = 1 to len(aCol)
							if isString(aCol[i])
								# Simple format check - could be enhanced
								if NOT This.MatchesFormat(aCol[i], cFormat)
									return FALSE
								ok
							ok
						next
						return TRUE
					ok
				ok
			ok
		ok
		return FALSE
	
	def MatchesFormat(cValue, cFormat)
		# Simple format matching - can be enhanced with regex
		switch lower(cFormat)
		on "yyyy-mm-dd"
			return len(cValue) = 10 and 
			       substr(cValue, "-") = 5 and 
			       substr(cValue, "-", 6) = 8
		on "email"
			return substr(cValue, "@") > 0 and substr(cValue, ".") > 0
		on "phone"
			return This.IsNumeric(ring_substr2(cValue, "-", ""))
		off
		return TRUE
	
	  #----------------------#
	 #  PART EXTRACTION     #
	#----------------------#
	
	def ExtractParts(oTable)
		@aMatchedParts = []
		
		@aMatchedParts + ["Cols", oTable.NumberOfColumns()]
		@aMatchedParts + ["Rows", oTable.NumberOfRows()]
		@aMatchedParts + ["ColNames", oTable.Columns()]
		
		aProps = []
		if oTable.IsEmpty()
			aProps + "Empty"
		else
			aProps + "NonEmpty"
		ok
		
		if len(oTable.FindCalculatedCols()) > 0
			aProps + "HasCalculated"
		ok
		
		@aMatchedParts + ["Properties", aProps]
	
	  #----------------------#
	 #  QUERY METHODS       #
	#----------------------#
	
	def MatchedParts()
		return @aMatchedParts
	
	def Tokens()
		return @aTokens
	
	def Pattern()
		return @cPattern
	
	def Explain()
		return [
			["Pattern", @cPattern],
			["TokenCount", len(@aTokens)],
			["Tokens", @aTokens],
			["MatchedParts", @aMatchedParts]
		]
	
	  #---------------------------#
	 #  ADVANCED QUERY METHODS   #
	#---------------------------#
	
	def MatchingTables(paTables)
		if CheckParams() and isList(paTables) and StzListQ(paTables).IsInNamedParam()
			paTables = paTables[2]
		ok
		
		aMatching = []
		for i = 1 to len(paTables)
			if This.Match(paTables[i])
				aMatching + paTables[i]
			ok
		next
		return aMatching
	
		def MatchingTablesIn(paTables)
			return This.MatchingTables(paTables)
	
	def CountMatchingTables(paTables)
		if CheckParams() and isList(paTables) and StzListQ(paTables).IsInNamedParam()
			paTables = paTables[2]
		ok
		
		nCount = 0
		for i = 1 to len(paTables)
			if This.Match(paTables[i])
				nCount++
			ok
		next
		return nCount
	
		def CountMatchingTablesIn(paTables)
			return This.CountMatchingTables(paTables)
	
	  #----------------------#
	 #  DEBUG METHODS       #
	#----------------------#
	
	def EnableDebug()
		@bDebugMode = TRUE
	
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
		
		for i = 1 to len(cStr)
			cChar = @substr(cStr, i, i)
			if not isDigit(cChar) and cChar != "-" and cChar != "."
				return FALSE
			ok
		next
		
		return TRUE
	
	  #-----------------------#
	 #  PATTERN COMBINATION  #
	#-----------------------#
	
	def And_(oOtherTablex)
		if NOT IsStzTablex(oOtherTablex)
			StzRaise("Incorrect param! oOtherTablex must be a stzTablex object.")
		ok
		
		cCombined = "{" + 
		            @substr(@cPattern, 2, len(@cPattern) - 1) + 
		            " & " + 
		            @substr(oOtherTablex.Pattern(), 2, len(oOtherTablex.Pattern()) - 1) +
		            "}"
		
		return new stzTablex(cCombined)
	
	def Or_(oOtherTablex)
		if NOT IsStzTablex(oOtherTablex)
			StzRaise("Incorrect param! oOtherTablex must be a stzTablex object.")
		ok
		
		cCombined = "{" + 
		            @substr(@cPattern, 2, len(@cPattern) - 1) + 
		            " | " + 
		            @substr(oOtherTablex.Pattern(), 2, len(oOtherTablex.Pattern()) - 1) +
		            "}"
		
		return new stzTablex(cCombined)
	
	def Not_()
		cInner = @substr(@cPattern, 2, len(@cPattern) - 1)
		cNegated = "{@!" + cInner + "}"
		return new stzTablex(cNegated)

	  #-----------------#
	 #  CACHE UTILITY  #
	#-----------------#

	def TableSignature(oTable)
		# Use content checksum for efficiency
		cContent = @@(oTable.Content())
		nChecksum = 0
		for i = 1 to len(cContent)
			nChecksum += ascii(cContent[i])
		next
		
		return "" + oTable.NumberOfColumns() + ":" + 
		       oTable.NumberOfRows() + ":" + 
		       @@(oTable.ColNames()) + ":" +
		       nChecksum

	def ClearCache()
		@aMatchCache = []
	
	def SetCacheSize(nSize)
		@nMaxCacheSize = nSize
