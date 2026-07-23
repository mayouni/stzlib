# stzTablex - Declarative Pattern Matching for Tables in Softanza
# A regex-like pattern language for stzTable structures

# Quick constructor functions
func StzTablexQ(_cPattern_)
	return new stzTablex(_cPattern_)

func Tablex(_cPattern_)
	return new stzTablex(_cPattern_)

func Tbx(_cPattern_)
	return new stzTablex(_cPattern_)

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

	def NormalizePattern(_cPattern_)
		_cPattern_ = trim(_cPattern_)
		if NOT (startsWith(_cPattern_, "{") and endsWith(_cPattern_, "}"))
			_cPattern_ = "{" + _cPattern_ + "}"
		ok
		return _cPattern_

	  #--------------------#
	 #  PATTERN PARSING   #
	#--------------------#

	def ParsePattern(_cPattern_)
		# Remove outer braces
		_cInner_ = @StzMid(_cPattern_, 2, StzLen(_cPattern_) - 1)
		_cInner_ = trim(_cInner_)

		if @bDebugMode
			? "Parsing inner pattern: " + _cInner_
		ok

		# Split by logical operators -> (sequence), & (and), | (or)
		_aParts_ = This.SplitByOperator(_cInner_, "->")
		_aTokens_ = []
		_nLen_ = len(_aParts_)

		for _i_ = 1 to _nLen_
			_cPart_ = trim(_aParts_[_i_])

			if _cPart_ = ""
				loop
			ok

			if StzFindFirst("|", _cPart_) > 0
				_aToken_ = This.ParseAlternation(_cPart_)

			but StzFindFirst("&", _cPart_) > 0
				_aToken_ = This.ParseConjunction(_cPart_)

			else
				_aToken_ = This.ParseSingleToken(_cPart_)
			ok

			_aTokens_ + _aToken_
		next

		return _aTokens_

	def SplitByOperator(cStr, cOperator)
		_aParts_ = []
		_cCurrent_ = ""
		_nDepth_ = 0
		_nLen_ = len(cStr)
		_nOpLen_ = len(cOperator)

		for _i_ = 1 to _nLen_
			_cChar_ = @StzMid(cStr, _i_, _i_)
	
			if _cChar_ = "(" or _cChar_ = "{"
				_nDepth_++
				_cCurrent_ += _cChar_
			but _cChar_ = ")" or _cChar_ = "}"
				_nDepth_--
				_cCurrent_ += _cChar_
			but _nDepth_ = 0 and @StzMid(cStr, _i_, _i_ + _nOpLen_ - 1) = cOperator
				_aParts_ + trim(_cCurrent_)
				_cCurrent_ = ""
				_i_ += _nOpLen_ - 1
			else
				_cCurrent_ += _cChar_
			ok
		next

		if len(_cCurrent_) > 0
			_aParts_ + trim(_cCurrent_)
		ok

		return _aParts_

	def ParseAlternation(_cTokenStr_)
		if startsWith(_cTokenStr_, "(") and endsWith(_cTokenStr_, ")")
			_cTokenStr_ = @StzMid(_cTokenStr_, 2, StzLen(_cTokenStr_) - 1)
		ok

		_aParts_ = This.SplitByOperator(_cTokenStr_, "|")
		_aAlternatives_ = []
		_nLen_ = len(_aParts_)

		for _i_ = 1 to _nLen_
			_cPart_ = trim(_aParts_[_i_])
			if _cPart_ != ""
				_aToken_ = This.ParseSingleToken(_cPart_)
				if len(_aToken_) > 0
					_aAlternatives_ + _aToken_
				ok
			ok
		next

		return [
			["type", "alternation"],
			["alternatives", _aAlternatives_],
			["negated", FALSE]
		]

	def ParseConjunction(_cTokenStr_)
		if startsWith(_cTokenStr_, "(") and endsWith(_cTokenStr_, ")")
			_cTokenStr_ = @StzMid(_cTokenStr_, 2, StzLen(_cTokenStr_) - 1)
		ok

		_aParts_ = This.SplitByOperator(_cTokenStr_, "&")
		_nLen_ = len(_aParts_)
		_aConditions_ = []

		for _i_ = 1 to _nLen_
			_cPart_ = trim(_aParts_[_i_])
			if _cPart_ != ""
				_aToken_ = This.ParseSingleToken(_cPart_)
				_aConditions_ + _aToken_
			ok
		next

		return [
			["type", "conjunction"],
			["conditions", _aConditions_],
			["negated", FALSE]
		]

	def ParseSingleToken(_cTokenStr_)
		_cTokenStr_ = trim(_cTokenStr_)
		if _cTokenStr_ = ""
			return []
		ok

		if @bDebugMode
			? "=== ParseSingleToken ==="
			? "Input: " + _cTokenStr_
		ok

		_bNegated_ = FALSE
		_bCaseSensitive_ = FALSE

		# Check for negation
		if startsWith(StzLower(_cTokenStr_), "@!")
			_bNegated_ = TRUE
			_cTokenStr_ = @StzMid(_cTokenStr_, 3, StzLen(_cTokenStr_))
		ok

		# Check for case sensitivity flag
		if startsWith(StzLower(_cTokenStr_), "@cs:")
			_bCaseSensitive_ = TRUE
			_cTokenStr_ = @StzMid(_cTokenStr_, 5, StzLen(_cTokenStr_))
		ok

		_cType_ = ""
		_cValue_ = ""
		_aConstraints_ = []
		_nMin_ = 1
		_nMax_ = 1

		# Extract and preserve content in parentheses BEFORE lowercasing
		_cPreservedValue_ = ""
		_nOpenParen_ = StzFindFirst("(", _cTokenStr_)
		if _nOpenParen_ > 0
			_nCloseParen_ = StzFindFirst(")", _cTokenStr_)
			if _nCloseParen_ > _nOpenParen_
				_cPreservedValue_ = @StzMid(_cTokenStr_, _nOpenParen_ + 1, _nCloseParen_ - 1)
				if @bDebugMode
					? "Preserved value: " + _cPreservedValue_
				ok
			ok
		ok

		# NOW lowercase the token string for type detection
		_cTokenStr_ = StzLower(_cTokenStr_)
		
		if @bDebugMode
			? "After lowercase: " + _cTokenStr_
		ok

		# Parse token types (same as before...)
		#WARNING// The order is imprtant, for example:
		# all col* variants mustappear before the generic col check.

		if startsWith(_cTokenStr_, "@cols") or startsWith(_cTokenStr_, "cols")
			_cType_ = "cols"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@cols", "cols"])
	
		but startsWith(_cTokenStr_, "@rows") or startsWith(_cTokenStr_, "rows")
			_cType_ = "rows"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@rows", "rows"])
	
		but startsWith(_cTokenStr_, "@hascol") or startsWith(_cTokenStr_, "hascol")
			_cType_ = "hascol"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@hascol", "hascol"])

		but startsWith(_cTokenStr_, "@coltype") or startsWith(_cTokenStr_, "coltype")
			_cType_ = "coltype"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@coltype", "coltype"])

		but startsWith(_cTokenStr_, "@colpattern") or startsWith(_cTokenStr_, "colpattern")
			_cType_ = "colpattern"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@colpattern", "colpattern"])

		but startsWith(_cTokenStr_, "@colname") or startsWith(_cTokenStr_, "colname")
			_cType_ = "colname"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@colname", "colname"])

		but startsWith(_cTokenStr_, "@sumcol") or startsWith(_cTokenStr_, "sumcol")
			_cType_ = "sumcol"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@sumcol", "sumcol"])
	
		but startsWith(_cTokenStr_, "@avgcol") or startsWith(_cTokenStr_, "avgcol")
			_cType_ = "avgcol"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@avgcol", "avgcol"])
	
		but startsWith(_cTokenStr_, "@mincol") or startsWith(_cTokenStr_, "mincol")
			_cType_ = "mincol"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@mincol", "mincol"])
	
		but startsWith(_cTokenStr_, "@maxcol") or startsWith(_cTokenStr_, "maxcol")
			_cType_ = "maxcol"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@maxcol", "maxcol"])
	
		but startsWith(_cTokenStr_, "@col") or startsWith(_cTokenStr_, "col")
			_cType_ = "col"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@col", "col"])
	
		but startsWith(_cTokenStr_, "@row") or startsWith(_cTokenStr_, "row")
			_cType_ = "row"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@row", "row"])
	
		but startsWith(_cTokenStr_, "@cell") or startsWith(_cTokenStr_, "cell")
			_cType_ = "cell"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@cell", "cell"])
			
		but startsWith(_cTokenStr_, "@property") or startsWith(_cTokenStr_, "property")
			_cType_ = "property"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@property", "property"])
	
		but startsWith(_cTokenStr_, "@contains") or startsWith(_cTokenStr_, "contains")
			_cType_ = "contains"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@contains", "contains"])
	
		but startsWith(_cTokenStr_, "@sorted") or startsWith(_cTokenStr_, "sorted")
			_cType_ = "sorted"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@sorted", "sorted"])
	
		but startsWith(_cTokenStr_, "@unique") or startsWith(_cTokenStr_, "unique")
			_cType_ = "unique"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@unique", "unique"])
	
		but startsWith(_cTokenStr_, "@duplicates") or startsWith(_cTokenStr_, "duplicates")
			_cType_ = "duplicates"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@duplicates", "duplicates"])
	
		but startsWith(_cTokenStr_, "@grouped") or startsWith(_cTokenStr_, "grouped")
			_cType_ = "grouped"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@grouped", "grouped"])
	
		but startsWith(_cTokenStr_, "@filtered") or startsWith(_cTokenStr_, "filtered")
			_cType_ = "filtered"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@filtered", "filtered"])

		but startsWith(_cTokenStr_, "@aggregated") or startsWith(_cTokenStr_, "aggregated")
			_cType_ = "aggregated"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@aggregated", "aggregated"])
	
		but startsWith(_cTokenStr_, "@transposed") or startsWith(_cTokenStr_, "transposed")
			_cType_ = "transposed"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@transposed", "transposed"])

		but startsWith(_cTokenStr_, "@calculated") or startsWith(_cTokenStr_, "calculated")
			_cType_ = "calculated"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@calculated", "calculated"])

		but startsWith(_cTokenStr_, "@nulls") or startsWith(_cTokenStr_, "nulls")
			_cType_ = "nulls"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@nulls", "nulls"])

		but startsWith(_cTokenStr_, "@completeness") or startsWith(_cTokenStr_, "completeness")
			_cType_ = "completeness"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@completeness", "completeness"])

		but startsWith(_cTokenStr_, "@numeric") or startsWith(_cTokenStr_, "numeric")
			_cType_ = "numeric"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@numeric", "numeric"])

		but startsWith(_cTokenStr_, "@alphabetic") or startsWith(_cTokenStr_, "alphabetic")
			_cType_ = "alphabetic"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@alphabetic", "alphabetic"])

		but startsWith(_cTokenStr_, "@format") or startsWith(_cTokenStr_, "format")
			_cType_ = "format"
			_cTokenStr_ = This.RemovePrefix(_cTokenStr_, ["@format", "format"])

		else
			return [
				["type", "ERROR"],
				["value", _cTokenStr_],
				["message", "Unrecognized token type"]
			]
		ok

		if @bDebugMode
			? "Detected type: " + _cType_
		ok

		# Parse parentheses content - use preserved value
		_nOpenParen_ = StzFindFirst("(", _cTokenStr_)
		if _nOpenParen_ > 0
			_nCloseParen_ = StzFindFirst(")", _cTokenStr_)
			if _nCloseParen_ > _nOpenParen_
				_cContent_ = _cPreservedValue_

				if _cType_ = "property" or _cType_ = "colname" or 
				   _cType_ = "contains" or _cType_ = "sorted" or 
				   _cType_ = "unique" or _cType_ = "duplicates" or _cType_ = "hascol" or 
				   _cType_ = "grouped" or _cType_ = "filtered" or _cType_ = "calculated" or
				   _cType_ = "nulls" or _cType_ = "numeric" or _cType_ = "alphabetic" or
				   _cType_ = "coltype" or _cType_ = "colpattern" or 
				   _cType_ = "sumcol" or _cType_ = "avgcol" or _cType_ = "mincol" or _cType_ = "maxcol" or
				   _cType_ = "completeness" or _cType_ = "format"
					_cValue_ = _cContent_

					if @bDebugMode
						? "Assigned cValue: " + _cValue_
					ok
				else
					_aConstraints_ = This.ParseConstraints(_cContent_, _cType_)
					if @bDebugMode
						? "Parsed constraints: " + @@(_aConstraints_)
					ok
				ok
			ok
		ok

		# Parse quantifiers (same as before...)
		_cQuantPart_ = ""
		if _nCloseParen_ > 0 and _nCloseParen_ < len(_cTokenStr_)
			_cQuantPart_ = @StzMid(_cTokenStr_, _nCloseParen_ + 1, StzLen(_cTokenStr_))
		ok

		_cQuantPart_ = trim(_cQuantPart_)

		if len(_cQuantPart_) > 0
			if StzFindFirst("-", _cQuantPart_) > 0
				_aSection_ = @split(_cQuantPart_, "-")
				if len(_aSection_) = 2
					_nMin_ = 0 + trim(_aSection_[1])
					_nMax_ = 0 + trim(_aSection_[2])
				ok
			else
				_cLastChar_ = StzRight(_cQuantPart_, 1)
				if _cLastChar_ = "+"
					_nMin_ = 1
					_nMax_ = 999999
				but _cLastChar_ = "*"
					_nMin_ = 0
					_nMax_ = 999999
				but _cLastChar_ = "?"
					_nMin_ = 0
					_nMax_ = 1
				but This.IsNumeric(_cQuantPart_)
					_nMin_ = 0 + _cQuantPart_
					_nMax_ = _nMin_
				ok
			ok
		ok

		_aResult_ = [
			["type", _cType_],
			["value", _cValue_],
			["constraints", _aConstraints_],
			["min", _nMin_],
			["max", _nMax_],
			["negated", _bNegated_],
			["casesensitive", _bCaseSensitive_]
		]

		if @bDebugMode
			? "Result token: " + @@(_aResult_)
		ok

		return _aResult_

	def RemovePrefix(cStr, aPrefixes)
		_nLen_ = len(aPrefixes)
		for _i_ = 1 to _nLen_
			if startsWith(cStr, aPrefixes[_i_])
				return @StzMid(cStr, StzLen(aPrefixes[_i_]) + 1, StzLen(cStr))
			ok
		next
		return cStr

	def ParseConstraints(cConstraintStr, _cType_)
		_aConstraints_ = []

		if cConstraintStr = ""
			return _aConstraints_
		ok

		# Parse based on type
		switch _cType_
		on "cols"
			if This.IsNumeric(cConstraintStr)
				_aConstraints_ + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
			but startsWith(cConstraintStr, ">")
				_aConstraints_ + [
					["type", "greater"],
					["value", 0 + @StzMid(cConstraintStr, 2, StzLen(cConstraintStr))]
				]
			but startsWith(cConstraintStr, "<")
				_aConstraints_ + [
					["type", "less"],
					["value", 0 + @StzMid(cConstraintStr, 2, StzLen(cConstraintStr))]
				]
			ok

		on "rows"
			if This.IsNumeric(cConstraintStr)
				_aConstraints_ + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
			but startsWith(cConstraintStr, ">")
				_aConstraints_ + [
					["type", "greater"],
					["value", 0 + @StzMid(cConstraintStr, 2, StzLen(cConstraintStr))]
				]
			but startsWith(cConstraintStr, "<")
				_aConstraints_ + [
					["type", "less"],
					["value", 0 + @StzMid(cConstraintStr, 2, StzLen(cConstraintStr))]
				]
			ok

		on "cell"
			if StzFindFirst("..", cConstraintStr) > 0
				_aParts_ = @split(cConstraintStr, "..")
				if len(_aParts_) = 2
					_aConstraints_ + [
						["type", "range"],
						["start", trim(_aParts_[1])],
						["end", trim(_aParts_[2])]
					]
				ok
			but StzFindFirst("{", cConstraintStr) > 0
				_nStart_ = StzFindFirst("{", cConstraintStr)
				_nEnd_ = StzFindFirst("}", cConstraintStr)
				_cSet_ = @StzMid(cConstraintStr, _nStart_ + 1, _nEnd_ - 1)
				_aValues_ = @split(_cSet_, ";")
				_aConstraints_ + [
					["type", "set"],
					["values", _aValues_]
				]
			ok
		off

		return _aConstraints_

	  #--------------------#
	 #  MATCHING LOGIC    #
	#--------------------#

	def Match(poTable)
		if NOT IsStzTable(poTable)
			StzRaise("Incorrect param type! poTable must be a stzTable object.")
		ok

		# Check cache
		_cTableSig_ = This.TableSignature(poTable)
		_cCacheKey_ = @cPattern + "|" + _cTableSig_
		_nLen_ = len(@aMatchCache)

		for _i_ = 1 to _nLen_
			if @aMatchCache[_i_][1] = _cCacheKey_
				if @bDebugMode
					? "Cache hit!"
				ok
				return @aMatchCache[_i_][2]
			ok
		next

		# Not cached - compute
		@oTable = poTable
		_bResult_ = This.MatchTokens(@aTokens, @oTable)

		if _bResult_
			This.ExtractParts(@oTable)
		ok

		# Store in cache
		@aMatchCache + [_cCacheKey_, _bResult_]
		if len(@aMatchCache) > @nMaxCacheSize
			del(@aMatchCache, 1)  # Remove oldest
		ok

		return _bResult_

	def MatchTokens(_aTokens_, oTable)
		_nLen_ = len(_aTokens_)
		for _i_ = 1 to _nLen_
			_aToken_ = _aTokens_[_i_]

			if HasKey(_aToken_, "type") and _aToken_["type"] = "alternation"
				_bMatched_ = FALSE
				if HasKey(_aToken_, "alternatives")
					_aAlternatives_ = _aToken_["alternatives"]
					_nLenAlt_ = len(_aAlternatives_)

					for j = 1 to _nLenAlt_
						if This.MatchSingleToken(_aAlternatives_[j], oTable)
							_bMatched_ = TRUE
							exit
						ok
					next
				ok
				if not _bMatched_
					return FALSE
				ok

			but HasKey(_aToken_, "type") and _aToken_["type"] = "conjunction"
				if HasKey(_aToken_, "conditions")
					_aConditions_ = _aToken_["conditions"]
					_nLenCond_ = len(_aConditions_)

					for j = 1 to _nLenCond_
						if not This.MatchSingleToken(_aConditions_[j], oTable)
							return FALSE
						ok
					next
				ok

			else
				if not This.MatchSingleToken(_aToken_, oTable)
					return FALSE
				ok
			ok
		next

		return TRUE

	def MatchSingleToken(_aToken_, oTable)
		_bResult_ = FALSE

		if HasKey(_aToken_, "type")
			_cType_ = _aToken_["type"]

			if _cType_ = "cols"
				_bResult_ = This.CheckCols(_aToken_, oTable)

			but _cType_ = "rows"
				_bResult_ = This.CheckRows(_aToken_, oTable)

			but _cType_ = "col"
				_bResult_ = This.CheckCol(_aToken_, oTable)

			but _cType_ = "row"
				_bResult_ = This.CheckRow(_aToken_, oTable)

			but _cType_ = "cell"
				_bResult_ = This.CheckCell(_aToken_, oTable)

			but _cType_ = "colname"
				_bResult_ = This.CheckColName(_aToken_, oTable)

			but _cType_ = "property"
				_bResult_ = This.CheckProperty(_aToken_, oTable)

			but _cType_ = "contains"
				_bResult_ = This.CheckContains(_aToken_, oTable)

			but _cType_ = "sorted"
				_bResult_ = This.CheckSorted(_aToken_, oTable)

			but _cType_ = "unique"
				_bResult_ = This.CheckUnique(_aToken_, oTable)

			but _cType_ = "duplicates"
				_bResult_ = This.CheckDuplicates(_aToken_, oTable)

			but _cType_ = "grouped"
				_bResult_ = This.CheckGrouped(_aToken_, oTable)

			but _cType_ = "filtered"
				_bResult_ = This.CheckFiltered(_aToken_, oTable)

			but _cType_ = "aggregated"
				_bResult_ = This.CheckAggregated(_aToken_, oTable)

			but _cType_ = "transposed"
				_bResult_ = This.CheckTransposed(_aToken_, oTable)

			but _cType_ = "calculated"
				_bResult_ = This.CheckCalculated(_aToken_, oTable)

			but _cType_ = "hascol"
				_bResult_ = This.CheckHasCol(_aToken_, oTable)

			but _cType_ = "coltype"
				_bResult_ = This.CheckColType(_aToken_, oTable)

			but _cType_ = "colpattern"
				_bResult_ = This.CheckColPattern(_aToken_, oTable)

			but _cType_ = "sumcol"
				_bResult_ = This.CheckSumCol(_aToken_, oTable)

			but _cType_ = "avgcol"
				_bResult_ = This.CheckAvgCol(_aToken_, oTable)

			but _cType_ = "mincol"
				_bResult_ = This.CheckMinCol(_aToken_, oTable)

			but _cType_ = "maxcol"
				_bResult_ = This.CheckMaxCol(_aToken_, oTable)

			but _cType_ = "nulls"
				_bResult_ = This.CheckNulls(_aToken_, oTable)

			but _cType_ = "completeness"
				_bResult_ = This.CheckCompleteness(_aToken_, oTable)

			but _cType_ = "numeric"
				_bResult_ = This.CheckNumeric(_aToken_, oTable)

			but _cType_ = "alphabetic"
				_bResult_ = This.CheckAlphabetic(_aToken_, oTable)

			but _cType_ = "format"
				_bResult_ = This.CheckFormat(_aToken_, oTable)
			ok
		ok

		# Apply negation
		if HasKey(_aToken_, "negated") and _aToken_["negated"] = TRUE
			_bResult_ = not _bResult_
		ok

		return _bResult_

	  #------------------------#
	 #  CHECKING METHODS      #
	#------------------------#

	def CheckCols(_aToken_, oTable)
		_nCols_ = oTable.NumberOfColumns()

		if HasKey(_aToken_, "constraints")
			_aConstraints_ = _aToken_["constraints"]
			_nLen_ = len(_aConstraints_)

			for _i_ = 1 to _nLen_
				_aConstraint_ = _aConstraints_[_i_]

				if HasKey(_aConstraint_, "type")
					switch _aConstraint_["type"]
					on "exact"
						if _nCols_ = _aConstraint_["value"]
							return TRUE
						ok
					on "greater"
						if _nCols_ >= _aConstraint_["value"]
							return TRUE
						ok
					on "less"
						if _nCols_ <= _aConstraint_["value"]
							return TRUE
						ok
					off
				ok
			next
		ok

		return FALSE

	def CheckRows(_aToken_, oTable)
		_nRows_ = oTable.NumberOfRows()
		_aConstraints_ = _aToken_["constraints"]
		_nLen_ = len(_aConstraints_)

		if HasKey(_aToken_, "constraints")
			for _i_ = 1 to _nLen_
				_aConstraint_ = _aConstraints_[_i_]

				if HasKey(_aConstraint_, "type")
					switch _aConstraint_["type"]
					on "exact"
						if _nRows_ = _aConstraint_["value"]
							return TRUE
						ok
					on "greater"
						if _nRows_ >= _aConstraint_["value"]
							return TRUE
						ok
					on "less"
						if _nRows_ <= _aConstraint_["value"]
							return TRUE
						ok
					off
				ok
			next
		ok

		return FALSE

	def CheckCol(_aToken_, oTable)
		# Check specific column properties
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			return oTable.HasColumn(_cColName_)
		ok
		return FALSE

	def CheckRow(_aToken_, oTable)
		# Check specific column properties
		if HasKey(_aToken_, "value")
			_aRow_ = _aToken_["value"]
			return oTable.HasRow(_aRow_)
		ok
		return FALSE

	def CheckCell(_aToken_, oTable)
		# Check cell value constraints across table
		if HasKey(_aToken_, "constraints")
			_aConstraints_ = _aToken_["constraints"]
			_nLen_ = len(_aConstraints_)

			for _i_ = 1 to _nLen_
				_aConstraint_ = _aConstraints_[_i_]

				if HasKey(_aConstraint_, "type")
					if _aConstraint_["type"] = "range"
						_aRange_ = _aToken_["range"]
						if HasKey(_aToken_, "casesensitive")
							return oTable.ContainsInSectionCS(_aRange_[1], _aRange_[2], _aToken_["value"], TRUE)
						else
							return oTable.ContainsInSectionCS(_aRange_[1], _aRange_[2], _aToken_["value"], FALSE)
						ok
					ok
				ok
			next
		ok
		return FALSE

	def CheckColName(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			return oTable.HasColName(_cColName_)
		ok
		return FALSE

	def CheckProperty(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cProperty_ = StzLower(trim(_aToken_["value"]))

			switch _cProperty_
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

	def CheckContains(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cValue_ = _aToken_["value"]
			_value_ = _cValue_

			_bCaseSensitive_ = FALSE
			if HasKey(_aToken_, "casesensitive")
				_bCaseSensitive_ = _aToken_["casesensitive"]
			ok

			if IsNumberInString(_cValue_)
				_value_ = 0+ _cValue_

			but IsListInString(_cValue_)
				_cCode_ = "_value_ = " + _cValue_
				eval(_cCode_)
			ok

			# WARNING: The pattern does not understand values
			# of type OBJECT, only NUMBER, STRING and LIST.
			# TODO: Clarify this in the documentation

			# Check with case sensitivity
			if _bCaseSensitive_
				_bResult_ = oTable.ContainsCellCS(_value_, TRUE)
			else
				_bResult_ = oTable.ContainsCellCS(_value_, FALSE)
			ok

			return _bResult_
		ok

		return FALSE

	def CheckSorted(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_bCaseSensitive_ = TRUE  # Default to case-sensitive
				if HasKey(_aToken_, "casesensitive")
					_bCaseSensitive_ = _aToken_["casesensitive"]
				ok

				_aCol_ = oTable.Col(_cColName_)
				_nLen_ = len(_aCol_)

				# Check if sorted ascending
				for _i_ = 1 to _nLen_ - 1
					_xCurrent_ = _aCol_[_i_]
					_xNext_ = _aCol_[_i_+1]

					if isString(_xCurrent_) and isString(_xNext_)
						if _bCaseSensitive_
							if strcmp(_xCurrent_, _xNext_) > 0
								return FALSE
							ok
						else
							if strcmp(StzLower(_xCurrent_), StzLower(_xNext_)) > 0
								return FALSE
							ok
						ok
	
					but isNumber(_xCurrent_) and isNumber(_xNext_)
						if _xCurrent_ > _xNext_
							return FALSE
						ok
					ok
				next
				return TRUE
			ok
		ok
		return TRUE

	def CheckUnique(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_bCaseSensitive_ = TRUE  # Default to case-sensitive for unique
				if HasKey(_aToken_, "casesensitive")
					_bCaseSensitive_ = _aToken_["casesensitive"]
				ok

				_aCol_ = oTable.Col(_cColName_)

				if _bCaseSensitive_
					return len(_aCol_) = len(U(_aCol_))
				else
					# Case-insensitive: lowercase all values first
					_aLower_ = []
					_nLen_ = len(_aCol_)
					for _i_ = 1 to _nLen_
						if isString(_aCol_[_i_])
							_aLower_ + StzLower(_aCol_[_i_])
						else
							_aLower_ + _aCol_[_i_]
						ok
					next
					return len(_aLower_) = len(U(_aLower_))
				ok
			ok
		ok
		return TRUE

	def CheckDuplicates(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_bCaseSensitive_ = FALSE
				if HasKey(_aToken_, "casesensitive")
					_bCaseSensitive_ = _aToken_["casesensitive"]
				ok

				_aCol_ = oTable.Col(_cColName_)
				if _bCaseSensitive_
					return len(_aCol_) > len(U(_aCol_))
				else
					# Case-insensitive duplicates check
					_aLower_ = []
					_nLen_ = len(_aCol_)
					for _i_ = 1 to _nLen_
						if isString(_aCol_[_i_])
							_aLower_ + StzLower(_aCol_[_i_])
						else
							_aLower_ + _aCol_[_i_]
						ok
					next
					return len(_aLower_) > len(U(_aLower_))
				ok
			ok
		ok
		return FALSE

	def CheckGrouped(_aToken_, oTable)
		if @bDebugMode
			? "=== CheckGrouped ==="
			? "Token: " + @@(_aToken_)
		ok

		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]

			if @bDebugMode
				? "Column name: " + _cColName_
				? "Has column: " + oTable.HasColumn(_cColName_)
			ok

			if oTable.HasColumn(_cColName_)
				_bCaseSensitive_ = FALSE
				if HasKey(_aToken_, "casesensitive")
					_bCaseSensitive_ = _aToken_["casesensitive"]
				ok

				if @bDebugMode
					? "Case sensitive: " + _bCaseSensitive_
				ok

				_aCol_ = oTable.Col(_cColName_)
				_nConsecutiveDups_ = 0
				_nLen_ = len(_aCol_)

				if @bDebugMode
					? "Column data: " + @@(_aCol_)
				ok

				for _i_ = 1 to _nLen_ - 1
					_xCurrent_ = _aCol_[_i_]
					_xNext_ = _aCol_[_i_+1]

					_bMatch_ = FALSE
					if isString(_xCurrent_) and isString(_xNext_)
						if _bCaseSensitive_
							_bMatch_ = (_xCurrent_ = _xNext_)
						else
							_bMatch_ = (StzLower(_xCurrent_) = StzLower(_xNext_))
						ok
					else
						_bMatch_ = (_xCurrent_ = _xNext_)
					ok
					
					if @bDebugMode
						? "Comparing [" + _i_ + "] '" + _xCurrent_ + "' vs [" + (_i_+1) + "] '" + _xNext_ + "': " + _bMatch_
					ok
					
					if _bMatch_
						_nConsecutiveDups_++
					ok
				next

				if @bDebugMode
					? "Consecutive duplicates found: " + _nConsecutiveDups_
				ok

				return _nConsecutiveDups_ > 0
			ok
		ok
		return FALSE

	def CheckFiltered(_aToken_, oTable)
		# Check if table shows signs of filtering (non-sequential IDs, gaps in data)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_aCol_ = oTable.Col(_cColName_)
				_nLen_ = len(_aCol_)

				# Check for gaps in numeric sequence
				if _nLen_ > 1
					for _i_ = 1 to _nLen_
						if NOT isNumber(_aCol_[_i_])
							return FALSE
						ok
					next
					# Check for non-sequential numbers
					for _i_ = 1 to _nLen_ - 1
						if _aCol_[_i_+1] - _aCol_[_i_] > 1
							return TRUE
						ok
					next
				ok
			ok
		ok
		return FALSE

	def CheckAggregated(_aToken_, oTable)
		# Check if table contains aggregated data (calculated rows/cols)
		return len(oTable.FindCalculatedRows()) > 0 or 
		       len(oTable.FindCalculatedCols()) > 0

	def CheckTransposed(_aToken_, oTable)
		# Check if table structure suggests it's transposed (more cols than rows)
		return oTable.NumberOfColumns() > oTable.NumberOfRows()

	def CheckCalculated(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_anCalcCols_ = oTable.FindCalculatedCols()
				_nColPos_ = oTable.FindCol(_cColName_)
				return StzFindFirst(_nColPos_, _anCalcCols_) > 0
			ok
		else
			# Check if any calculated columns exist
			return len(oTable.FindCalculatedCols()) > 0
		ok
		return FALSE

	def CheckHasCol(_aToken_, poTable)

		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			return poTable.HasColumn(_cColName_)
		ok
		return FALSE

	def CheckColType(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			# Format: colname:type (e.g., "salary:number")
			_cValue_ = _aToken_["value"]
			if StzFindFirst(":", _cValue_) > 0
				_aParts_ = @split(_cValue_, ":")
				if len(_aParts_) = 2
					_cColName_ = trim(_aParts_[1])
					_cType_ = StzLower(trim(_aParts_[2]))
					
					if oTable.HasColumn(_cColName_)
						_aCol_ = oTable.Col(_cColName_)
						_nLen_ = len(_aCol_)

						switch _cType_
						on "number"
							for _i_ = 1 to _nLen_
								if NOT isNumber(_aCol_[_i_])
									return FALSE
								ok
							next
							return TRUE

						on "string"
							for _i_ = 1 to _nLen_
								if NOT isString(_aCol_[_i_])
									return FALSE
								ok
							next
							return TRUE
							
						on "list"
							for _i_ = 1 to _nLen_
								if NOT isList(_aCol_[_i_])
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

	def CheckColPattern(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			# Format: colname:pattern (e.g., "email:@EMAIL")
			_cValue_ = _aToken_["value"]
			if StzFindFirst(":", _cValue_) > 0
				_aParts_ = @split(_cValue_, ":")
				if len(_aParts_) = 2
					_cColName_ = trim(_aParts_[1])
					_cPattern_ = trim(_aParts_[2])
					
					if oTable.HasColumn(_cColName_)
						_aCol_ = oTable.Col(_cColName_)
						_nLen_ = len(_aCol_)

						# Check if all values match the pattern
						for _i_ = 1 to _nLen_
							if isString(_aCol_[_i_])
								if NOT Q(_aCol_[_i_]).MatchesRX(_cPattern_)
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

	def CheckSumCol(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			# Format: colname:value or colname:>value or colname:<value
			_cValue_ = _aToken_["value"]
			if StzFindFirst(":", _cValue_) > 0
				_aParts_ = @split(_cValue_, ":")
				if len(_aParts_) = 2
					_cColName_ = trim(_aParts_[1])
					_cConstraint_ = trim(_aParts_[2])
					
					if oTable.HasColumn(_cColName_)
						_aCol_ = oTable.Col(_cColName_)
						_nSum_ = 0
						_nLen_ = len(_aCol_)

						for _i_ = 1 to _nLen_
							if isNumber(_aCol_[_i_])
								_nSum_ += _aCol_[_i_]
							ok
						next

						if startsWith(_cConstraint_, ">")
							return _nSum_ > (0 + @StzMid(_cConstraint_, 2, StzLen(_cConstraint_)))
						but startsWith(_cConstraint_, "<")
							return _nSum_ < (0 + @StzMid(_cConstraint_, 2, StzLen(_cConstraint_)))
						but This.IsNumeric(_cConstraint_)
							return _nSum_ = (0 + _cConstraint_)
						ok
					ok
				ok
			ok
		ok
		return FALSE

	def CheckAvgCol(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cValue_ = _aToken_["value"]
			if StzFindFirst(":", _cValue_) > 0
				_aParts_ = @split(_cValue_, ":")
				if len(_aParts_) = 2
					_cColName_ = trim(_aParts_[1])
					_cConstraint_ = trim(_aParts_[2])

					if oTable.HasColumn(_cColName_)
						_aCol_ = oTable.Col(_cColName_)
						_nSum_ = 0
						_nCount_ = 0
						_nLen_ = len(_aCol_)
						for _i_ = 1 to _nLen_
							if isNumber(_aCol_[_i_])
								_nSum_ += _aCol_[_i_]
								_nCount_++
							ok
						next

						if _nCount_ > 0
							_nAvg_ = _nSum_ / _nCount_
							
							if startsWith(_cConstraint_, ">")
								return _nAvg_ > (0 + @StzMid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but startsWith(_cConstraint_, "<")
								return _nAvg_ < (0 + @StzMid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but This.IsNumeric(_cConstraint_)
								return _nAvg_ = (0 + _cConstraint_)
							ok
						ok
					ok
				ok
			ok
		ok
		return FALSE

	def CheckMinCol(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			if StzFindFirst(":", _aToken_["value"]) > 0
				_aParts_ = @split(_aToken_["value"], ":")
				if len(_aParts_) = 2
					_cColName_ = trim(_aParts_[1])
					_cConstraint_ = trim(_aParts_[2])

					if oTable.HasColumn(_cColName_)
						_aCol_ = oTable.Col(_cColName_)
						_nMin_ = NULL
						_nLen_ = len(_aCol_)
						for _i_ = 1 to _nLen_
							if isNumber(_aCol_[_i_])
								if _nMin_ = NULL
									_nMin_ = _aCol_[_i_]
								but _aCol_[_i_] < _nMin_
									_nMin_ = _aCol_[_i_]
								ok
							ok
						next

						if _nMin_ != NULL
							if startsWith(_cConstraint_, ">")
								return _nMin_ > (0 + @StzMid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but startsWith(_cConstraint_, "<")
								return _nMin_ < (0 + @StzMid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but This.IsNumeric(_cConstraint_)
								return _nMin_ = (0 + _cConstraint_)
							ok
						ok
					ok
				ok
			ok
		ok
		return FALSE

	def CheckMaxCol(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cValue_ = _aToken_["value"]
			if StzFindFirst(":", _cValue_) > 0
				_aParts_ = @split(_cValue_, ":")
				if len(_aParts_) = 2
					_cColName_ = trim(_aParts_[1])
					_cConstraint_ = trim(_aParts_[2])

					if oTable.HasColumn(_cColName_)
						_aCol_ = oTable.Col(_cColName_)
						_nMax_ = NULL
						_nLen_ = len(_aCol_)
						for _i_ = 1 to _nLen_
							if isNumber(_aCol_[_i_])
								if _nMax_ = NULL
									_nMax_ = _aCol_[_i_]
								but _aCol_[_i_] > _nMax_
									_nMax_ = _aCol_[_i_]
								ok
							ok
						next

						if _nMax_ != NULL
							if startsWith(_cConstraint_, ">")
								return _nMax_ > (0 + @StzMid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but startsWith(_cConstraint_, "<")
								return _nMax_ < (0 + @StzMid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but This.IsNumeric(_cConstraint_)
								return _nMax_ = (0 + _cConstraint_)
							ok
						ok
					ok
				ok
			ok
		ok
		return FALSE

	def CheckNulls(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_aCol_ = oTable.Col(_cColName_)
				_nLen_ = len(_aCol_)
				for _i_ = 1 to _nLen_
					if _aCol_[_i_] = NULL or _aCol_[_i_] = "" or _aCol_[_i_] = 0
						return TRUE
					ok
				next
			ok
		ok
		return FALSE

	def CheckCompleteness(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			# Format: colname:percentage (e.g., "email:90" means 90% complete)
			_cValue_ = _aToken_["value"]
			if StzFindFirst(":", _cValue_) > 0
				_aParts_ = @split(_cValue_, ":")
				if len(_aParts_) = 2
					_cColName_ = trim(_aParts_[1])
					_cPercent_ = trim(_aParts_[2])

					if oTable.HasColumn(_cColName_) and This.IsNumeric(_cPercent_)
						_aCol_ = oTable.Col(_cColName_)
						_nNonEmpty_ = 0
						_nLenCol_ = len(_aCol_)
						for _i_ = 1 to _nLenCol_
							if _aCol_[_i_] != NULL and _aCol_[_i_] != "" and _aCol_[_i_] != 0
								_nNonEmpty_++
							ok
						next
						_nCompleteness_ = (_nNonEmpty_ * 100.0) / _nLenCol_
						return _nCompleteness_ >= (0 + _cPercent_)
					ok
				ok
			ok
		ok
		return FALSE

	def CheckNumeric(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_aCol_ = oTable.Col(_cColName_)
				_nLen_ = len(_aCol_)
				for _i_ = 1 to _nLen_
					if NOT isNumber(_aCol_[_i_])
						return FALSE
					ok
				next
				return TRUE
			ok
		ok
		return FALSE

	def CheckAlphabetic(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_aCol_ = oTable.Col(_cColName_)
				_nLen_ = len(_aCol_)
				for _i_ = 1 to _nLen_
					if isString(_aCol_[_i_])
						if NOT Q(_aCol_[_i_]).IsAlphabetic()
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

	def CheckFormat(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			# Format: colname:format (e.g., "date:YYYY-MM-DD")
			_cValue_ = _aToken_["value"]
			if StzFindFirst(":", _cValue_) > 0
				_aParts_ = @split(_cValue_, ":")
				if len(_aParts_) = 2
					_cColName_ = trim(_aParts_[1])
					_cFormat_ = trim(_aParts_[2])

					if oTable.HasColumn(_cColName_)
						_aCol_ = oTable.Col(_cColName_)
						_nLen_ = len(_aCol_)
						# Check if values match the format pattern
						for _i_ = 1 to _nLen_
							if isString(_aCol_[_i_])
								# Simple format check - could be enhanced
								if NOT This.MatchesFormat(_aCol_[_i_], _cFormat_)
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

	def MatchesFormat(_cValue_, _cFormat_)

		_oRegex_ = new stzRegex(_cFormat_)
		if _oRegex_.Match(pat(_cValue_)) or _oRegex_.Match(_cValue_)
			return TRUE
		else
			return FALSE
		ok

	  #----------------------#
	 #  PART EXTRACTION     #
	#----------------------#

	def ExtractParts(oTable)
		@aMatchedParts = []

		@aMatchedParts + ["cols", oTable.NumberOfColumns()]
		@aMatchedParts + ["rows", oTable.NumberOfRows()]
		@aMatchedParts + ["colnames", oTable.Columns()]

		_aProps_ = []
		if oTable.IsEmpty()
			_aProps_ + "empty"
		else
			_aProps_ + "nonempty"
		ok

		if len(oTable.FindCalculatedCols()) > 0
			_aProps_ + "hasclculated"
		ok

		@aMatchedParts + ["properties", _aProps_]

	  #----------------------#
	 #  QUERY METHODS       #
	#----------------------#

	def MatchedParts()
		return @aMatchedParts

	def NumberOfMatchedParts()
		return len(@aMatchedParts)

		def CountMatchedParts()
			return len(@MatchedParts)

		def HowManyMatchedParts()
			return len(@MatchedParts)

	def Tokens()
		return @aTokens

	def NumberOfTokens()
		return len(@aTokens)

		def CountTokens()
			return len(@aTokens)

		def HowManyTokens()
			return len(@aTokens)

	def Pattern()
		return @cPattern

	def Explain()
		return [
			["pattern", @cPattern],
			["tokencount", len(@aTokens)],
			["tokens", @aTokens],
			["matchedparts", @aMatchedParts]
		]

	  #---------------------------#
	 #  ADVANCED QUERY METHODS   #
	#---------------------------#
	
	def MatchingTables(paTables)
		if CheckParams() and isList(paTables) and IsInNamedParamList(paTables)
			paTables = paTables[2]
		ok

		_aMatching_ = []
		_nLen_ = len(paTables)
		for _i_ = 1 to _nLen_
			if This.Match(paTables[_i_])
				_aMatching_ + paTables[_i_]
			ok
		next
		return _aMatching_

		def MatchingTablesIn(paTables)
			return This.MatchingTables(paTables)

	def CountMatchingTables(paTables)
		if CheckParams() and isList(paTables) and IsInNamedParamList(paTables)
			paTables = paTables[2]
		ok

		_nCount_ = 0
		_nLen_ = len(paTables)
		for _i_ = 1 to _nLen_
			if This.Match(paTables[_i_])
				_nCount_++
			ok
		next
		return _nCount_

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

		_nLen_ = len(cStr)
		for _i_ = 1 to _nLen_
			_cChar_ = @StzMid(cStr, _i_, _i_)
			if not isDigit(_cChar_) and _cChar_ != "-" and _cChar_ != "."
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

		_cCombined_ = "{" + 
		            @StzMid(@cPattern, 2, StzLen(@cPattern) - 1) + 
		            " & " + 
		            @StzMid(oOtherTablex.Pattern(), 2, StzLen(oOtherTablex.Pattern()) - 1) +
		            "}"
		
		return new stzTablex(_cCombined_)

	def Or_(oOtherTablex)
		if NOT IsStzTablex(oOtherTablex)
			StzRaise("Incorrect param! oOtherTablex must be a stzTablex object.")
		ok

		_cCombined_ = "{" + 
		            @StzMid(@cPattern, 2, StzLen(@cPattern) - 1) + 
		            " | " + 
		            @StzMid(oOtherTablex.Pattern(), 2, StzLen(oOtherTablex.Pattern()) - 1) +
		            "}"
		
		return new stzTablex(_cCombined_)

	def Not_()
		_cInner_ = @StzMid(@cPattern, 2, StzLen(@cPattern) - 1)
		_cNegated_ = "{@!" + _cInner_ + "}"
		return new stzTablex(_cNegated_)

	  #-----------------#
	 #  CACHE UTILITY  #
	#-----------------#

	def TableSignature(poTable)
		# Use content checksum for efficiency
		_cContent_ = @@(poTable.Content())
		_nChecksum_ = 0
		_nLen_ = len(_cContent_)

		for _i_ = 1 to _nLen_
			_nChecksum_ += ascii(_cContent_[_i_])
		next

		_cResult_ = '' + poTable.NumberOfColumns() + ":" + 
		       poTable.NumberOfRows() + ":" + 
		       @@(poTable.ColNames()) + ":" +
		       _nChecksum_

		return _cResult_

	def ClearCache()
		@aMatchCache = []

	def SetCacheSize(nSize)
		if CheckParams()
			if NOT isNumber(nSize)
				StzRaise("Incorrect param type! nSize must be a number.")
			ok
		ok

		@nMaxCacheSize = nSize
