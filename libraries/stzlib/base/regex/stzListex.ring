# Softanza List Regex Engine - Enhanced Version

func StzListRegexQ(_cPattern_)
	return new stzListex(_cPattern_)

func StzListexQ(_cPattern_)
	return StzListRegexQ(_cPattern_)

func Lx(_cPattern_)
	return StzListRegexQ(_cPattern_)

class stzListex from stzObject

	@cPattern		# The original pattern string
	@aTokens		# List of parsed token definitions
	@bDebugMode = false	# Debug mode flag

	# Cache system attributes
	@aMatchCache = []
	@nMaxCacheSize = 100

	# Regular expression patterns for various token types
	@cNumberPattern = '(?:-?\d+(?:\.\d+)?)'
	@cStringPattern = "(?:" + StzChar(34) + "[^" + StzChar(34) + "]*" + StzChar(34) + "|\'[^\']*\')"
	@cSimpleListPattern = '\[\s*[^\[\]]*\s*\]'
	@cRecursiveListPattern = '\[\s*(?:[^\[\]]|\[(?:[^\[\]]|(?R))*\])*\s*\]'
	@cListPattern = @cSimpleListPattern
	@cAnyPattern = ""

	@cQuantifierPattern = '^([+*?])'
	@cSingleNumberPattern = '^(\d+)'
	@cRangePattern = '^(\d+)-(\d+)'
	@cSetPattern = '^(\{(.*?)\})'
	@cUniqueSetPattern = '^(\{(.*?)\})U'

	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#

	def init(_cPattern_)
		if NOT isString(_cPattern_)
			raise("Error: Pattern must be a string")
		ok

		@cAnyPattern = @cNumberPattern + "|" + @cStringPattern + "|" + @cListPattern
		@cPattern = This.NormalizePattern(_cPattern_)
		@aTokens = This.ParsePattern(@cPattern)
		This.OptimizeTokens()

	def NormalizePattern(_cPattern_)
		_cPattern_ = @trim(_cPattern_)
		
		if NOT (StartsWith(_cPattern_, "[") and EndsWith(_cPattern_, "]"))
			_cPattern_ = "[" + _cPattern_ + "]"
		ok
		
		return _cPattern_

	def ParsePattern(_cPattern_)
		This.DebugLog("ParsePattern", "Input: " + _cPattern_)
		
		_cInner_ = @trim( @StzMid(@trim(_cPattern_), 2, len(_cPattern_)-1) )
		_aParts_ = SplitAtTopLevelCommas(_cInner_)

		_aTokens_ = []
		_nPartsLen_3 = len(_aParts_)
		for i = 1 to _nPartsLen_3
			_aTokens_ + This.ParseToken(@trim(_aParts_[i]))
		next

		This.DebugLog("ParsePattern", "Tokens created: " + len(_aTokens_))
		return _aTokens_

	def ParseNestedPattern(cNestedPattern, _bNegated_, _bCaseSensitive_)
		_cInner_ = @StzMid(cNestedPattern, 2, len(cNestedPattern)-1)
		_aNestedTokens_ = []
		_aParts_ = SplitAtTopLevelCommas(_cInner_)

		_nPartsLen_2 = len(_aParts_)
		for i = 1 to _nPartsLen_2
			_aToken_ = This.ParseToken(@trim(_aParts_[i]))
			# Inherit case sensitivity if not specified
			if NOT HasKey(_aToken_, "casesensitive")
				_aToken_ + ["casesensitive", _bCaseSensitive_]
			ok
			_aNestedTokens_ + _aToken_
		next

		_nMin_ = 1
		_nMax_ = 1
		_nQuantifier_ = 1
    
		_nLenNestPat_ = len(cNestedPattern)
		if _nLenNestPat_ > 2
			_cRest_ = Right(cNestedPattern, 1)
			_oQMatch_ = rx(@cQuantifierPattern)
			if _oQMatch_.MatchFirst(_cRest_)
				_aMatches_ = _oQMatch_.Matches()
				_cQuantifier_ = _aMatches_[1]

				switch _cQuantifier_
				on "+"
					_nMin_ = 1
					_nMax_ = 999999999
				on "*"
					_nMin_ = 0
					_nMax_ = 999999999
				on "?"
					_nMin_ = 0
					_nMax_ = 1
				off
			else
				_oNumberMatch_ = rx(@cSingleNumberPattern).MatchFirst(_cRest_)
				if _oNumberMatch_
					_aMatches_ = _oNumberMatch_.Matches()
					_nQuantifier_ = number(_aMatches_[1])
					_nMin_ = _nQuantifier_
					_nMax_ = _nQuantifier_
				ok
			ok
		ok
    
		_aToken_ = [
			[ "keyword", "@NESTED" ],
			[ "type", "nested" ],
			[ "pattern", @cRecursiveListPattern ],
			[ "nestedTokens", _aNestedTokens_ ],
			[ "min", _nMin_ ],
			[ "max", _nMax_ ],
			[ "quantifier", _nQuantifier_ ],
			[ "hasset", false ],
			[ "setvalues", [] ],
			[ "requireunique", false ],
			[ "negated", _bNegated_ ],
			[ "casesensitive", _bCaseSensitive_ ]
		]
    
		return _aToken_

	def ParseAlternationToken(_cTokenStr_, _bNegated_, _bCaseSensitive_)
		_aParts_ = @split(_cTokenStr_, "|")
		_nLen_ = len(_aParts_)
		_aAlternatives_ = []

		for i = 1 to _nLen_
			_cPart_ = @trim(_aParts_[i])

			if _bNegated_ and i = 1
				_cPart_ = "@!" + _cPart_
			ok

			_aToken_ = This.ParseToken(_cPart_)
			# Inherit case sensitivity if not specified
			if NOT HasKey(_aToken_, "casesensitive")
				_aToken_ + ["casesensitive", _bCaseSensitive_]
			ok
			_aAlternatives_ + _aToken_
		next
		
		_aToken_ = [
			[ "keyword", "@ALT" ],
			[ "type", "alternation" ],
			[ "alternatives", _aAlternatives_ ],
			[ "min", 1 ],
			[ "max", 1 ],
			[ "quantifier", 1 ],
			[ "hasset", false ],
			[ "setvalues", [] ],
			[ "requireunique", false ],
			[ "negated", _bNegated_ ],
			[ "casesensitive", _bCaseSensitive_ ]
		]
		
		return _aToken_

	def ParseToken(_cTokenStr_)
		This.DebugLog("ParseToken", "Input: " + _cTokenStr_)
		
		_bNegated_ = FALSE
		_bCaseSensitive_ = FALSE

		# Check for case-sensitive prefix @cs:
		if StartsWith(StzLower(_cTokenStr_), "@cs:")
			_bCaseSensitive_ = TRUE
			_cTokenStr_ = @StzMid(_cTokenStr_, 5, len(_cTokenStr_))
		ok

		# Extract set values BEFORE case conversion to preserve original values
		_cPreservedSet_ = ""
		_nSetStart_ = StzFindFirst("{", _cTokenStr_)
		if _nSetStart_ > 0
			_nSetEnd_ = StzFindFirst("}", _cTokenStr_)
			if _nSetEnd_ > _nSetStart_
				_cPreservedSet_ = @StzMid(_cTokenStr_, _nSetStart_, _nSetEnd_ - _nSetStart_ + 1)
			ok
		ok

		# Check for negation prefix
		if StartsWith(_cTokenStr_, "@!")
			_bNegated_ = true
			_cTokenStr_ = @subStr(_cTokenStr_, 3, len(_cTokenStr_))
		ok

		# Handle nested list patterns
		if StartsWith(_cTokenStr_, "[") and EndsWith(_cTokenStr_, "]")
			return This.ParseNestedPattern(_cTokenStr_, _bNegated_, _bCaseSensitive_)
		ok

		# Alternation handling
		if @Contains(_cTokenStr_, "|")
			return This.ParseAlternationToken(_cTokenStr_, _bNegated_, _bCaseSensitive_)
		ok

		# Ensure token starts with @
		if NOT StartsWith(_cTokenStr_, "@")
			_cTokenStr_ = "@" + _cTokenStr_
		ok
    
		# Extract keyword (first two characters)
		_cKeyword_ = @StzMid(_cTokenStr_, 1, 2)
		
		_nMin_ = 1
		_nMax_ = 1
		_nQuantifier_ = 1
		_aSetValues_ = []
		_bRequireUnique_ = false

		_cRemainder_ = ""
		_nLenToken_ = stzlen(_cTokenStr_)

		if _nLenToken_ > 2
			_cRemainder_ = @StzMid(_cTokenStr_, 3, _nLenToken_)
		ok

		# Range and quantifier processing
		if len(_cRemainder_) > 0
			_oRangeMatch_ = rx(@cRangePattern)

			if _oRangeMatch_.MatchFirst(_cRemainder_)
				_acNumbers_ = @split(_oRangeMatch_.Matches()[1], "-")
				_nMin_ = 0+ _acNumbers_[1]
				_nMax_ = 0+ _acNumbers_[2]
			
				if _nMin_ > _nMax_
					raise("Error: Invalid range - min value greater than max: " + _cTokenStr_)
				ok
        
				_nRangeLen_ = len(_acNumbers_[1]) + 1 + len(_acNumbers_[2])
				_cRemainder_ = StzRight(_cRemainder_, len(_cRemainder_) - _nRangeLen_)

			else
				_oQMatch_ = rx(@cQuantifierPattern)

				if _oQMatch_.MatchFirst(_cRemainder_)
					_aMatches_ = _oQMatch_.Matches()
					_cQuantifier_ = _aMatches_[1]

					switch _cQuantifier_
					on "+"
						_nMin_ = 1
						_nMax_ = 999999999
					on "*"
						_nMin_ = 0
						_nMax_ = 999999999
					on "?"
						_nMin_ = 0
						_nMax_ = 1
					off

					_cRemainder_ = StzRight(_cRemainder_, len(_cRemainder_) - 1)

				else
					_oNumberMatch_ = rx(@cSingleNumberPattern)

					if _oNumberMatch_.MatchFirst(_cRemainder_)
						_aMatches_ = _oNumberMatch_.Matches()
						_nQuantifier_ = number(_aMatches_[1])
						_nMin_ = _nQuantifier_
						_nMax_ = _nQuantifier_
                
						_cRemainder_ = StzRight(_cRemainder_, len(_cRemainder_) - len(_aMatches_[1]))
					ok
				ok
			ok
		ok

		# Set constraints processing using preserved values
		if len(_cPreservedSet_) > 0
			# Check for {values}U format
			if EndsWith(_cRemainder_, "U") and StzFindFirst("{", _cRemainder_) > 0
				_bRequireUnique_ = TRUE
				_cPreservedSet_ = StzReplace(_cPreservedSet_, "U", "")
			ok
			
			# Determine type for set parsing
			_cType_ = "any"
			switch _cKeyword_
			on "@N"
				_cType_ = "number"
			on "@S"
				_cType_ = "string"
			on "@L"
				_cType_ = "list"
			off
			
			_aSetValues_ = This.ParseSetValues(_cPreservedSet_, _cType_, _bRequireUnique_)
		ok

		# Set token type based on keyword (ordered longest to shortest for future extensions)
		_aToken_ = []

		switch _cKeyword_
		on "@N"
			_aToken_ = [
				[ "keyword", "@N" ],
				[ "type", "number" ],
				[ "pattern", @cNumberPattern ]
			]
		on "@S"
			_aToken_ = [
				[ "keyword", "@S" ],
				[ "type", "string" ],
				[ "pattern", @cStringPattern ]
			]
		on "@L"
			_aToken_ = [
				[ "keyword", "@L" ],
				[ "type", "list" ],
				[ "pattern", @cListPattern ]
			]
		on "@$"
			_aToken_ = [
				[ "keyword", "@$" ],
				[ "type", "any" ],
				[ "pattern", @cAnyPattern ]
			]
		off

		_aToken_ + [ "min", _nMin_ ]
		_aToken_ + [ "max", _nMax_ ]
		_aToken_ + [ "quantifier", _nQuantifier_ ]

		if len(_aSetValues_) > 0
			_aToken_ + [ "hasset", true ]
			_aToken_ + [ "setvalues", _aSetValues_ ]
			_aToken_ + [ "requireunique", _bRequireUnique_ ]
		else
			_aToken_ + [ "hasset", false ]
			_aToken_ + [ "setvalues", [] ]
			_aToken_ + [ "requireunique", false ]
		ok

		_aToken_ + [ "negated", _bNegated_ ]
		_aToken_ + [ "casesensitive", _bCaseSensitive_ ]

		This.DebugLog("ParseToken", "Type: " + _cKeyword_ + " CaseSens: " + _bCaseSensitive_)
		return _aToken_

	def SplitAtTopLevelCommas(cStr)
		_acParts_ = []
		_cCurrent_ = ""
		_nDepth_ = 0
		_acChars_ = Chars(cStr)
		_nLen_ = len(_acChars_)

		for i = 1 to _nLen_
			_cChar_ = _acChars_[i]

			if _cChar_ = "["
				_nDepth_++
				_cCurrent_ += _cChar_
			but _cChar_ = "]"
				_nDepth_--
				_cCurrent_ += _cChar_
			but _cChar_ = "," and _nDepth_ = 0
				_acParts_ + @trim(_cCurrent_)
				_cCurrent_ = ""
			else
				_cCurrent_ += _cChar_
			ok
		next

		if len(_cCurrent_) > 0
			_acParts_ + @trim(_cCurrent_)
		ok

		return _acParts_

	  #--------------------#
	 #  PATTERN HANDLING  #
	#--------------------#

	def ParseSetValues(_cSetContent_, _cType_, bCheckUnique)
		_cSetContent_ = StzReplace(_cSetContent_, "{", "")
		_cSetContent_ = StzReplace(_cSetContent_, "}", "")

		_aValues_ = []
		_aParts_ = @split(_cSetContent_, ";")
		
		_nPartsLen_ = len(_aParts_)
		for i = 1 to _nPartsLen_
			_cValue_ = @trim(_aParts_[i])
			
			if _cValue_ = ""
				loop
			ok
			
			switch _cType_
			on "number"
				if rx("^(-?\d+(?:\.\d+)?)$").Match(_cValue_)
					_nValue_ = @number(_cValue_)
					
					if bCheckUnique and @Contains(_aValues_, _nValue_)
						raise("Error: Duplicate value in unique set: " + _cValue_)
					ok
					
					_aValues_ + _nValue_
				else
					raise("Error: Invalid number in set: " + _cValue_)
				ok

			on "string"
				# Don't call RemoveQuotes - just normalize quotes
				if (StartsWith(_cValue_, "'") and EndsWith(_cValue_, "'"))
					# Single quotes - convert to double
					_cUnquoted_ = @StzMid(_cValue_, 2, len(_cValue_) - 1)
					_cNormalizedValue_ = '"' + _cUnquoted_ + '"'
				but (StartsWith(_cValue_, '"') and EndsWith(_cValue_, '"'))
					# Already double quoted
					_cNormalizedValue_ = _cValue_
				else
					# No quotes - add double quotes
					_cNormalizedValue_ = '"' + _cValue_ + '"'
				ok

				if bCheckUnique
					# For uniqueness check, compare unquoted values
					_cCheck1_ = @StzMid(_cNormalizedValue_, 2, len(_cNormalizedValue_) - 1)
					_nValuesLen_2 = len(_aValues_)
					for j = 1 to _nValuesLen_2
						_cCheck2_ = @StzMid(_aValues_[j], 2, len(_aValues_[j]) - 1)
						if _cCheck1_ = _cCheck2_
							raise("Error: Duplicate value in unique set: " + _cValue_)
						ok
					next
				ok
				
				_aValues_ + _cNormalizedValue_
				
			on "list"
				# Normalize list format - ensure spaces after commas
				_cNormalized_ = This.NormalizeListString(_cValue_)
				
				if NOT (StartsWith(_cValue_, "[") and EndsWith(_cValue_, "]"))
					raise("Error: Invalid list format in set: " + _cValue_)
				ok
				
				if bCheckUnique and @Contains(_aValues_, _cNormalized_)
					raise("Error: Duplicate value in unique set: " + _cValue_)
				ok
				
				_aValues_ + _cNormalized_
				
			on "any"
				if bCheckUnique and @Contains(_aValues_, _cValue_)
					raise("Error: Duplicate value in unique set: " + _cValue_)
				ok
				
				_aValues_ + _cValue_
			off
		next
		
		return _aValues_

	def RemoveQuotes(cStr)
		if (StartsWith(cStr, "'") and EndsWith(cStr, "'")) or
		   (StartsWith(cStr, '"') and EndsWith(cStr, '"'))
			_cResult_ = @StzMid(cStr, 2, len(cStr)-1)
			return _cResult_
		ok
		return cStr

	def OptimizeTokens()
		_nLen_ = len(@aTokens)
		
		if _nLen_ <= 1
			return
		ok
		
		for i = _nLen_ to 2 step -1
			_aToken1_ = @aTokens[i-1]
			_aToken2_ = @aTokens[i]
			
			if _aToken1_[:keyword] = _aToken2_[:keyword] and
			   NOT _aToken1_[:hasset] and NOT _aToken2_[:hasset]
				
				if _aToken1_[:min] != _aToken1_[:max] and _aToken2_[:min] != _aToken2_[:max]
					_nNewMin_ = @Min([ _aToken1_[:min], _aToken2_[:min] ])
					_nNewMax_ = _aToken1_[:max] + _aToken2_[:max]
					
					@aTokens[i-1][:min] = _nNewMin_
					@aTokens[i-1][:max] = _nNewMax_
					del(@aTokens, i)
				ok
			ok
		next

	  #--------------------#
	 #   MATCHING LOGIC   #
	#--------------------#

	def Match(paList)
		if NOT isList(paList)
			return FALSE
		ok

		# Generate cache key BEFORE any modifications
		_cListSig_ = This.ListSignature(paList)
		_cCacheKey_ = @cPattern + "|" + _cListSig_
		
		# Check cache
		_nMatchCacheLen_ = len(@aMatchCache)
		for i = 1 to _nMatchCacheLen_
			if @aMatchCache[i][1] = _cCacheKey_
				This.DebugLog("Match", "Cache hit!")
				return @aMatchCache[i][2]
			ok
		next

		# Convert list elements (don't modify original)
		_aElements_ = []
		_nLen_ = len(paList)

		for i = 1 to _nLen_
			_aElements_ + paList[i]
		next

		# Perform matching
		_bResult_ = false
		try
			_bResult_ = This.MatchTokensToElements(@aTokens, _aElements_)

		catch
			if @bDebugMode
				? "Error during matching: " + cCatchError
			ok
			_bResult_ = false
		done
		
		# Store in cache AFTER computing result
		@aMatchCache + [_cCacheKey_, _bResult_]
		if len(@aMatchCache) > @nMaxCacheSize
			del(@aMatchCache, 1)
		ok
		
		return _bResult_

	def MatchTokensToElements(_aTokens_, _aElements_)
		_nLenTokens_ = len(_aTokens_)
		_nLenElements_ = len(_aElements_)
    
		return This.BacktrackMatch(_aTokens_, _aElements_, 1, 1, [])

	def BacktrackMatch(_aTokens_, _aElements_, nTokenIndex, nElementIndex, aUsedValues)
		_nLenTokens_ = len(_aTokens_)
		_nLenElements_ = len(_aElements_)

		if @bDebugMode
			? ">>> Backtrack: token#" + nTokenIndex + "/" + _nLenTokens_ + 
			  " elem#" + nElementIndex + "/" + _nLenElements_
		ok

		# Base case: all tokens processed
		if nTokenIndex > _nLenTokens_
			_bResult_ = (nElementIndex > _nLenElements_)
			if @bDebugMode
				? ">>> All tokens done. Elements consumed: " + _bResult_
			ok
			return _bResult_
		ok

		_aToken_ = _aTokens_[nTokenIndex]
		
		if @bDebugMode
			? ">>> Token: " + _aToken_[:keyword] + " Type: " + _aToken_[:type] + 
			  " Min: " + _aToken_[:min] + " Max: " + _aToken_[:max]
		ok

		_aLocalUsedValues_ = []
		_nUsedValuesLen_ = len(aUsedValues)
		for i = 1 to _nUsedValuesLen_
			_aLocalUsedValues_ + aUsedValues[i]
		next

		# Alternation token handling
		if _aToken_[:keyword] = "@ALT"
			if @bDebugMode
				? ">>> Alternation token with " + len(_aToken_[:alternatives]) + " alternatives"
			ok
			
			_nTokenalternativesLen_ = len(_aToken_[:alternatives])
			for i = 1 to _nTokenalternativesLen_
				_aAltTokens_ = _aToken_[:alternatives]
				_aNewTokens_ = []

				for j = 1 to nTokenIndex - 1
					_aNewTokens_ + _aTokens_[j]
				next

				_aNewTokens_ + _aAltTokens_[i]

				for j = nTokenIndex + 1 to _nLenTokens_
					_aNewTokens_ + _aTokens_[j]
				next

				if @bDebugMode
					? ">>> Trying alternative #" + i
				ok

				if This.BacktrackMatch(_aNewTokens_, _aElements_, nTokenIndex, nElementIndex, _aLocalUsedValues_)
					if @bDebugMode
						? ">>> Alternative #" + i + " MATCHED!"
					ok
					return true
				ok
			next

			if @bDebugMode
				? ">>> All alternatives FAILED"
			ok
			return false
		ok

		# Nested pattern handling
		if _aToken_[:keyword] = "@NESTED"
			_nMin_ = @Min([_aToken_[:max], _nLenElements_ - nElementIndex + 1])

			for nMatchCount = _aToken_[:min] to _nMin_
				_bSuccess_ = TRUE
				_nElemIdx_ = nElementIndex
				_aLocalUsedValuesCopy_ = _aLocalUsedValues_

				for i = 1 to nMatchCount
					if _nElemIdx_ > _nLenElements_
						_bSuccess_ = false
 						exit
					ok

					_xElement_ = _aElements_[_nElemIdx_]

					if NOT isList(_xElement_)
						_bSuccess_ = false
						exit
					ok

					if _aToken_[:negated]
						_bSuccess_ = false
						exit
					ok
                
					if NOT This.MatchTokensToElements(_aToken_[:nestedTokens], _xElement_)
						_bSuccess_ = false
						exit
					ok

					_nElemIdx_++
				next

				if _bSuccess_
					if nTokenIndex = _nLenTokens_
						if _nElemIdx_ = _nLenElements_ + 1
							return true
						ok
					else
						if This.BacktrackMatch(_aTokens_, _aElements_, nTokenIndex + 1, _nElemIdx_, _aLocalUsedValuesCopy_)
							return TRUE
						ok
					ok
				ok
			next
        
			if _aToken_[:min] = 0
				if This.BacktrackMatch(_aTokens_, _aElements_, nTokenIndex + 1, nElementIndex, _aLocalUsedValues_)
					return TRUE
				ok
			ok
        
			return FALSE
		ok

		# Standard token handling
		# Calculate maximum matches possible
		_nMaxPossible_ = _nLenElements_ - nElementIndex + 1
		_nMin_ = @Min([_aToken_[:max], _nMaxPossible_])

		if @bDebugMode
			? ">>> Will try match counts from " + _aToken_[:min] + " to " + _nMin_
		ok

		# Try different match counts from min to max
		for nMatchCount = _aToken_[:min] to _nMin_
			if @bDebugMode
				? ">>> Trying to match " + nMatchCount + " element(s)"
			ok
			
			_bSuccess_ = true
			_nElemIdx_ = nElementIndex
			_aMatchedElements_ = []
			_aLocalUsedValuesCopy_ = []
			
			# Copy used values
			_nLocalUsedValuesLen_ = len(_aLocalUsedValues_)
			for i = 1 to _nLocalUsedValuesLen_
				_aLocalUsedValuesCopy_ + _aLocalUsedValues_[i]
			next

			# Try to match exactly nMatchCount elements
			for i = 1 to nMatchCount
				if _nElemIdx_ > _nLenElements_
					if @bDebugMode
						? ">>> Ran out of elements"
					ok
					_bSuccess_ = false
					exit
				ok

				_xElement_ = _aElements_[_nElemIdx_]
				_bMatched_ = false
            
				_cElement_ = @@(_xElement_)

				if @bDebugMode
					? ">>> Checking element #" + _nElemIdx_ + ": " + _cElement_
				ok

				# Pattern matching
				if _aToken_[:type] = "list"
					_bMatched_ = rx(@cRecursiveListPattern).MatchRecursive(_cElement_)
				else
					_bMatched_ = rx("^" + _aToken_[:pattern] + "$").Match(_cElement_)
				ok
				
				if @bDebugMode
					? ">>> Pattern match: " + _bMatched_
				ok
        
				# Apply negation
				if _aToken_[:negated]
					_bMatched_ = NOT _bMatched_
					if @bDebugMode
						? ">>> After negation: " + _bMatched_
					ok
				ok
        
				if _bMatched_
					# Set constraint checking
					if _aToken_[:hasset]
						_xElemValue_ = This.ConvertToType(_cElement_, _aToken_[:type])
						_bInSet_ = false
						
						if @bDebugMode
							? ">>> Checking set constraint..."
							? ">>> Element value: " + _xElemValue_
							? ">>> Set values: " + @@(_aToken_[:setvalues])
						ok
						
						# Get case sensitivity setting
						_bCaseSensitive_ = TRUE
						if HasKey(_aToken_, "casesensitive")
							_bCaseSensitive_ = _aToken_[:casesensitive]
						ok

						_nTokensetvaluesLen_ = len(_aToken_[:setvalues])
						for j = 1 to _nTokensetvaluesLen_
							_xSetValue_ = _aToken_[:setvalues][j]

							if This.CompareValues(_xElemValue_, _xSetValue_, _aToken_[:type], _bCaseSensitive_)
								_bInSet_ = true
								if @bDebugMode
									? ">>> Found in set at position " + j
								ok
								exit
							ok
						next

						# Modify set check for negation
						if _aToken_[:negated]
							_bInSet_ = NOT _bInSet_
						ok

						if @bDebugMode
							? ">>> In set: " + _bInSet_
						ok

						if NOT _bInSet_
							if @bDebugMode
								? ">>> FAILED: not in set"
							ok
							_bSuccess_ = false
							exit
						ok
	                
						# Unique constraint for non-negated tokens
						if _aToken_[:requireunique] and NOT _aToken_[:negated]
							_bDuplicate_ = FALSE
							
							if @bDebugMode
								? ">>> Checking uniqueness..."
								? ">>> Already used: " + @@(_aLocalUsedValuesCopy_)
							ok
							
							_nLocalUsedValuesCopyLen_ = len(_aLocalUsedValuesCopy_)
							for j = 1 to _nLocalUsedValuesCopyLen_
								if This.CompareValues(_xElemValue_, _aLocalUsedValuesCopy_[j], _aToken_[:type], _bCaseSensitive_)
									_bDuplicate_ = TRUE
									if @bDebugMode
										? ">>> DUPLICATE found!"
									ok
									exit
								ok
							next
                        
							if _bDuplicate_
								_bSuccess_ = false
								exit
							else
								_aLocalUsedValuesCopy_ + _xElemValue_
								if @bDebugMode
									? ">>> Added to used values"
								ok
							ok
						ok
					ok

					_aMatchedElements_ + _xElement_
					_nElemIdx_++
					
					if @bDebugMode
						? ">>> Element matched, moving to next"
					ok

				else
					# Match failed - this match count doesn't work
					if @bDebugMode
						? ">>> Element FAILED to match"
					ok
					_bSuccess_ = false
					exit
				ok
			next

			# If we successfully matched nMatchCount elements
			if _bSuccess_
				if @bDebugMode
					? ">>> Successfully matched " + nMatchCount + " element(s)"
					? ">>> Now at element index: " + _nElemIdx_
				ok
				
				if nTokenIndex = _nLenTokens_
					# Last token - must consume all elements
					if _nElemIdx_ = _nLenElements_ + 1
						if @bDebugMode
							? ">>> FINAL MATCH - all elements consumed!"
						ok
						return true
					ok
					if @bDebugMode
						? ">>> Failed: " + (_nLenElements_ - _nElemIdx_ + 1) + " element(s) remaining"
					ok
					# else: didn't consume all elements, try next match count
				else
					# Not last token - try matching rest
					if @bDebugMode
						? ">>> Recursing to next token..."
					ok
					if This.BacktrackMatch(_aTokens_, _aElements_, nTokenIndex + 1, _nElemIdx_, _aLocalUsedValuesCopy_)
						if @bDebugMode
							? ">>> Recursion SUCCESS!"
						ok
						return true
                	ok
					if @bDebugMode
						? ">>> Recursion failed, trying next match count"
					ok
					# else: rest didn't match, try next match count
				ok
			ok
		next

		# All match counts failed
		# Only skip this token if it's optional (min=0)
		if _aToken_[:min] = 0
			if @bDebugMode
				? ">>> Token is optional, trying to skip..."
			ok
			if This.BacktrackMatch(_aTokens_, _aElements_, nTokenIndex + 1, nElementIndex, _aLocalUsedValues_)
				if @bDebugMode
					? ">>> Skip SUCCESS!"
				ok
				return true
			ok
		ok

		if @bDebugMode
			? ">>> Token COMPLETELY FAILED"
		ok
		return false

	def CompareValues(xValue1, xValue2, _cType_, _bCaseSensitive_)
		switch _cType_
		on "number"
			return xValue1 = xValue2

		on "string"
			_cVal1_ = This.RemoveQuotes("" + xValue1)
			_cVal2_ = This.RemoveQuotes("" + xValue2)
			
			if _bCaseSensitive_
				return _cVal1_ = _cVal2_
			else
				return StzLower(_cVal1_) = StzLower(_cVal2_)
			ok

		on "list"
			_cVal1_ = This.NormalizeListString("" + xValue1)
			_cVal2_ = This.NormalizeListString("" + xValue2)
			return _cVal1_ = _cVal2_

		on "any"
			if isNumber(xValue1) and isNumber(xValue2)
				return xValue1 = xValue2
			ok
        
			_cVal1_ = "" + xValue1
			_cVal2_ = "" + xValue2
			
			# Check if both are lists
			if ( StartsWith(_cVal1_, "[") and EndsWith(_cVal1_, "]") ) and
			   ( StartsWith(_cVal2_, "[") and EndsWith(_cVal2_, "]") )
				_cVal1_ = This.NormalizeListString(_cVal1_)
				_cVal2_ = This.NormalizeListString(_cVal2_)
				return _cVal1_ = _cVal2_
			ok
			
			# String comparison
			_cVal1_ = This.RemoveQuotes(_cVal1_)
			_cVal2_ = This.RemoveQuotes(_cVal2_)
			
			if _bCaseSensitive_
				return _cVal1_ = _cVal2_
			else
				return StzLower(_cVal1_) = StzLower(_cVal2_)
			ok
		off

	def NormalizeListString(xList)
		_cList_ = "" + xList
		_cList_ = @StzReplace(_cList_, " ", "")
		_cList_ = StzReplace(_cList_, Char(9), "")
		_cList_ = StzReplace(_cList_, Char(10), "")
		_cList_ = StzReplace(_cList_, Char(13), "")
		return _cList_

	def ConvertToType(_cValue_, _cType_)
		switch _cType_
		on "number"
			return @number(_cValue_)
		on "string"
			return _cValue_
		on "list"
			return _cValue_
		on "any"
			return _cValue_
		off

	  #---------------------------#
	 #     CACHE METHODS         #
	#---------------------------#

	def ListSignature(aList)
		_cContent_ = @@(aList)
		_nChecksum_ = 0
		_nLen_ = len(_cContent_)
		
		for i = 1 to _nLen_
			_nChecksum_ += ascii(_cContent_[i])
		next
		
		return "" + len(aList) + ":" + _nChecksum_

	def ClearCache()
		@aMatchCache = []
		return self

	def SetCacheSize(nSize)
		@nMaxCacheSize = nSize
		return self

	def CacheInfo()
		return [
			["entries", len(@aMatchCache)],
			["maxsize", @nMaxCacheSize]
		]

	  #---------------------------#
	 #     DEBUG METHODS         #
	#---------------------------#

	def DebugLog(cMethod, cMessage)
		if @bDebugMode
			? "=== " + cMethod + " ==="
			? cMessage
		ok

	def EnableDebug()
		@bDebugMode = true
		return self

	def DisableDebug()
		@bDebugMode = false
		return self

	def Tokens()
		return @aTokens

	def TokensInfo()
		_aInfo_ = []
		
		_nTokensLen_2 = len(@aTokens)
		for i = 1 to _nTokensLen_2
			_aToken_ = @aTokens[i]
			_cInfo_ = "Token #" + i + ": " + _aToken_[:keyword]
			
			if _aToken_[:min] = _aToken_[:max]
				if _aToken_[:min] = 1
					# Default - no display
				else
					_cInfo_ += _aToken_[:min]
				ok
			else
				_cInfo_ += _aToken_[:min] + "-" + _aToken_[:max]
			ok
			
			if _aToken_[:hasset]
				_cInfo_ += " {" + This.JoinSetValues(_aToken_[:setvalues]) + "}"
				
				if _aToken_[:requireunique]
					_cInfo_ += "U"
				ok
			ok
			
			if HasKey(_aToken_, "casesensitive") and _aToken_[:casesensitive]
				_cInfo_ += " [CS]"
			ok
			
			_aInfo_ + _cInfo_
		next
		
		return _aInfo_

	def JoinSetValues(_aValues_)
		_cResult_ = ""
		
		_nValuesLen_ = len(_aValues_)
		for i = 1 to _nValuesLen_
			if i > 1
				_cResult_ += "; "
			ok
			_cResult_ += "" + _aValues_[i]
		next
		
		return _cResult_

	def Pattern()
		return @cPattern

	def Explain()
		_aInfo_ = [
			["Pattern", @cPattern],
			["TokenCount", len(@aTokens)],
			["CacheEntries", len(@aMatchCache)]
		]
		
		_aTokenDetails_ = []
		_nTokensLen_ = len(@aTokens)
		for i = 1 to _nTokensLen_
			_aToken_ = @aTokens[i]
			_aTokenDetails_ + [
				["Index", i],
				["Keyword", _aToken_[:keyword]],
				["Type", _aToken_[:type]],
				["Min", _aToken_[:min]],
				["Max", _aToken_[:max]],
				["HasSet", _aToken_[:hasset]],
				["SetValues", _aToken_[:setvalues]],
				["Unique", _aToken_[:requireunique]],
				["Negated", _aToken_[:negated]],
				["CaseSensitive", iff(HasKey(_aToken_, "casesensitive"), _aToken_[:casesensitive], TRUE)]
			]
		next
		
		_aInfo_ + ["Tokens", _aTokenDetails_]
		return _aInfo_

	  #---------------------------#
	 #     ALIAS METHODS         #
	#---------------------------#

	def Macth(pList)
		return This.Match(pList)

	def DomainPattern()
		return This.Pattern()

	def MatchInfo()
		return This.TokensInfo()

	def TokensXT()
		return This.Tokens()

	def ExplainXT()
		return This.Explain()
