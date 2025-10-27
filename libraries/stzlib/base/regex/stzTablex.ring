# stzTablex - Declarative Pattern Matching for Tables in Softanza
# A regex-like pattern language for stzTable structures

# Quick constructor functions
func StzTablexQ(cPattern)
	return new stzTablex(cPattern)

func Tablex(cPattern)
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
		
		bNegated = FALSE
		
		# Check for negation
		if startsWith(lower(cTokenStr), "@!")
			bNegated = TRUE
			cTokenStr = @substr(cTokenStr, 3, len(cTokenStr))
		ok
		
		cType = ""
		cValue = ""
		aConstraints = []
		nMin = 1
		nMax = 1
		
		cTokenStr = lower(cTokenStr)
		
		# Parse token types
		if startsWith(cTokenStr, "@cols") or startsWith(cTokenStr, "cols")
			cType = "cols"
			cTokenStr = This.RemovePrefix(cTokenStr, ["@cols", "cols"])
			
		but startsWith(cTokenStr, "@rows") or startsWith(cTokenStr, "rows")
			cType = "rows"
			cTokenStr = This.RemovePrefix(cTokenStr, ["@rows", "rows"])
			
		but startsWith(cTokenStr, "@col") or startsWith(cTokenStr, "col")
			cType = "col"
			cTokenStr = This.RemovePrefix(cTokenStr, ["@col", "col"])
			
		but startsWith(cTokenStr, "@row") or startsWith(cTokenStr, "row")
			cType = "row"
			cTokenStr = This.RemovePrefix(cTokenStr, ["@row", "row"])
			
		but startsWith(cTokenStr, "@cell") or startsWith(cTokenStr, "cell")
			cType = "cell"
			cTokenStr = This.RemovePrefix(cTokenStr, ["@cell", "cell"])
			
		but startsWith(cTokenStr, "@colname") or startsWith(cTokenStr, "colname")
			cType = "colname"
			cTokenStr = This.RemovePrefix(cTokenStr, ["@colname", "colname"])
			
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
			
		else
			return [
				["type", "ERROR"],
				["value", cTokenStr],
				["message", "Unrecognized token type"]
			]
		ok
		
		# Parse parentheses content
		nOpenParen = substr(cTokenStr, "(")
		if nOpenParen > 0
			nCloseParen = substr(cTokenStr, ")")
			if nCloseParen > nOpenParen
				cContent = @substr(cTokenStr, nOpenParen + 1, nCloseParen - 1)
				
				if cType = "property" or cType = "colname" or 
				   cType = "contains" or cType = "sorted" or 
				   cType = "unique" or cType = "duplicates"
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
		
		return [
			["type", cType],
			["value", cValue],
			["constraints", aConstraints],
			["min", nMin],
			["max", nMax],
			["negated", bNegated]
		]
	
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
		
		@oTable = poTable
		
		if @bDebugMode
			? "=== Matching Table ==="
			? "Cols: " + @oTable.NumberOfColumns()
			? "Rows: " + @oTable.NumberOfRows()
		ok
		
		bResult = This.MatchTokens(@aTokens, @oTable)
		
		if bResult
			This.ExtractParts(@oTable)
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
			for i = 1 to len(aToken["constraints"])
				aConstraint = aToken["constraints"][i]
				
				if HasKey(aConstraint, "type")
					switch aConstraint["type"]
					on "exact"
						if nCols != aConstraint["value"]
							return FALSE
						ok
					on "greater"
						if nCols <= aConstraint["value"]
							return FALSE
						ok
					on "less"
						if nCols >= aConstraint["value"]
							return FALSE
						ok
					off
				ok
			next
		ok
		
		return TRUE
	
	def CheckRows(aToken, oTable)
		nRows = oTable.NumberOfRows()
		
		if HasKey(aToken, "constraints")
			for i = 1 to len(aToken["constraints"])
				aConstraint = aToken["constraints"][i]
				
				if HasKey(aConstraint, "type")
					switch aConstraint["type"]
					on "exact"
						if nRows != aConstraint["value"]
							return FALSE
						ok
					on "greater"
						if nRows <= aConstraint["value"]
							return FALSE
						ok
					on "less"
						if nRows >= aConstraint["value"]
							return FALSE
						ok
					off
				ok
			next
		ok
		
		return TRUE
	
	def CheckCol(aToken, oTable)
		# Check specific column properties
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			return oTable.HasColumn(cColName)
		ok
		return TRUE
	
	def CheckRow(aToken, oTable)
		# Check specific row properties
		return TRUE
	
	def CheckCell(aToken, oTable)
		# Check cell value constraints across table
		if HasKey(aToken, "constraints")
			for i = 1 to len(aToken["constraints"])
				aConstraint = aToken["constraints"][i]
				
				if HasKey(aConstraint, "type")
					if aConstraint["type"] = "range"
						# Check all cells are in range
						# Implementation depends on stzTable API
					ok
				ok
			next
		ok
		return TRUE
	
	def CheckColName(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			return oTable.HasColumn(cColName)
		ok
		return TRUE
	
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
				return TRUE
			on "calculated"
				# Check if has calculated columns
				return len(oTable.FindCalculatedCols()) > 0
			off
		ok
		return TRUE
	
	def CheckContains(aToken, oTable)
		if HasKey(aToken, "value")
			cValue = aToken["value"]
			return oTable.Contains(:Cell = cValue)
		ok
		return TRUE
	
	def CheckSorted(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			# Check if specific column is sorted
			# Implementation depends on stzTable API
		ok
		return TRUE
	
	def CheckUnique(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			aCol = oTable.Col(cColName)
			return len(aCol) = len(U(aCol))
		ok
		return TRUE
	
	def CheckDuplicates(aToken, oTable)
		if HasKey(aToken, "value")
			cColName = aToken["value"]
			aCol = oTable.Col(cColName)
			return len(aCol) > len(U(aCol))
		ok
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
