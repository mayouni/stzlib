# stzNumbrex - Number Pattern Matching for Softanza
# A regex-like pattern language for number structures
# FINAL VERSION - All bugs fixed

# Quick constructor functions
func StzNumbrexQ(_cPattern_)
	return new stzNumbrex(_cPattern_)

func Numbrex(_cPattern_)
	return new stzNumbrex(_cPattern_)

func Nx(_cPattern_)
	return new stzNumbrex(_cPattern_)

class stzNumbrex from stzObject
	
	@cPattern           # Pattern string
	@aTokens            # Parsed token definitions
	@nNumber = 0        # Target number to match
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
			? "=== stzNumbrex Init ==="
			? "Pattern: " + @cPattern
			? "Tokens parsed: " + len(@aTokens)
		ok

	# End-based substring helper. The whole parser was written assuming
	# Mid(str, start, END) semantics, but the global @StzMid is COUNT-based
	# (start, count) -- so `@StzMid(s,i,i)` grabbed i chars instead of one
	# and the inner-pattern extraction kept the closing brace, garbling
	# every token so MatchTokens looped over nothing and always returned
	# TRUE. Route all calls through here, converting end -> count.
	def _Mid(s, n1, n2)
		return @StzMid(s, n1, n2 - n1 + 1)

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

		_cInner_ = This._Mid(_cPattern_, 2, len(_cPattern_) - 1)
		_cInner_ = trim(_cInner_)
		
		if @bDebugMode
			? "Parsing inner pattern: " + _cInner_
		ok
		
		_aParts_ = This.SplitByOperator(_cInner_, "->")

		_aTokens_ = []
		_nLenParts_ = len(_aParts_)
		
		for _i_ = 1 to _nLenParts_
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
			
			if len(_aToken_) > 0
				_aTokens_ + _aToken_
			ok
		next
		
		return _aTokens_
	
	def SplitByOperator(_cStr_, cOperator)
		_aParts_ = []
		_cCurrent_ = ""
		_nDepth_ = 0
		_nLen_ = len(_cStr_)
		_nOpLen_ = len(cOperator)
		
		for _i_ = 1 to _nLen_
			_cChar_ = This._Mid(_cStr_, _i_, _i_)
			
			if _cChar_ = "(" or _cChar_ = "{"
				_nDepth_++
				_cCurrent_ += _cChar_
			but _cChar_ = ")" or _cChar_ = "}"
				_nDepth_--
				_cCurrent_ += _cChar_
			but _nDepth_ = 0 and This._Mid(_cStr_, _i_, _i_ + _nOpLen_ - 1) = cOperator
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
			_cTokenStr_ = This._Mid(_cTokenStr_, 2, len(_cTokenStr_) - 1)
		ok
		
		_aParts_ = This.SplitByOperator(_cTokenStr_, "|")
		_aAlternatives_ = []
		_nLenParts_ = len(_aParts_)
		
		for _i_ = 1 to _nLenParts_
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
			["negated", 0]
		]
	
	def ParseConjunction(_cTokenStr_)
		if startsWith(_cTokenStr_, "(") and endsWith(_cTokenStr_, ")")
			_cTokenStr_ = This._Mid(_cTokenStr_, 2, len(_cTokenStr_) - 1)
		ok
		
		_aParts_ = This.SplitByOperator(_cTokenStr_, "&")
		_aConditions_ = []
		_nLenParts_ = len(_aParts_)
		
		for _i_ = 1 to _nLenParts_
			_cPart_ = trim(_aParts_[_i_])
			if _cPart_ != ""
				_aToken_ = This.ParseSingleToken(_cPart_)
				if len(_aToken_) > 0
					_aConditions_ + _aToken_
				ok
			ok
		next
		
		return [
			["type", "conjunction"],
			["conditions", _aConditions_],
			["negated", 0]
		]
	

def ParseSingleToken(_cTokenStr_)
	_cTokenStr_ = trim(_cTokenStr_)
	if _cTokenStr_ = ""
		return []
	ok
	
	_cOriginal_ = _cTokenStr_
	_bNegated_ = 0
	
	if startsWith(StzLower(_cTokenStr_), "@!")
		_bNegated_ = 1
		_cTokenStr_ = This._Mid(_cTokenStr_, 3, len(_cTokenStr_))

		if @bDebugMode
			? "Negation detected! Remaining: " + _cTokenStr_
		ok
	ok
	
	_cType_ = ""
	_cValue_ = ""
	_aConstraints_ = []
	_nMin_ = 1
	_nMax_ = 1
	
	_cTokenStr_ = StzLower(_cTokenStr_)

	if startsWith(_cTokenStr_, "@digit")
		_cType_ = "digit"
		_cTokenStr_ = This._Mid(_cTokenStr_, 7, len(_cTokenStr_))

	but startsWith(_cTokenStr_, "digit")
		_cType_ = "digit"
		_cTokenStr_ = This._Mid(_cTokenStr_, 6, len(_cTokenStr_))

	#--

	but startsWith(_cTokenStr_, "@factor")
		_cType_ = "factor"
		_cTokenStr_ = This._Mid(_cTokenStr_, 8, len(_cTokenStr_))

	but startsWith(_cTokenStr_, "factor")
		_cType_ = "factor"
		_cTokenStr_ = This._Mid(_cTokenStr_, 7, len(_cTokenStr_))

	#--

	but startsWith(_cTokenStr_, "@property")
		_cType_ = "property"
		_cTokenStr_ = This._Mid(_cTokenStr_, 10, len(_cTokenStr_))

	but StartsWith(_cTokenStr_, "property")
		_cType_ = "property"
		_cTokenStr_ = This._Mid(_cTokenStr_, 9, len(_cTokenStr_))

	#--

	but startsWith(_cTokenStr_, "@part")
		_cType_ = "part"
		_cTokenStr_ = This._Mid(_cTokenStr_, 6, len(_cTokenStr_))

	but startsWith(_cTokenStr_, "part")
		_cType_ = "part"
		_cTokenStr_ = This._Mid(_cTokenStr_, 5, len(_cTokenStr_))

	#--

	but startsWith(_cTokenStr_, "@relation")
		_cType_ = "relation"
		_cTokenStr_ = This._Mid(_cTokenStr_, 10, len(_cTokenStr_))

	but startsWith(_cTokenStr_, "relation")
		_cType_ = "relation"
		_cTokenStr_ = This._Mid(_cTokenStr_, 9, len(_cTokenStr_))

	#--

	but startsWith(_cTokenStr_, "@approx")
		_cType_ = "approx"
		_cTokenStr_ = This._Mid(_cTokenStr_, 8, len(_cTokenStr_))

	but startsWith(_cTokenStr_, "approx")
		_cType_ = "approx"
		_cTokenStr_ = This._Mid(_cTokenStr_, 7, len(_cTokenStr_))

	#--

	but startsWith(_cTokenStr_, "@divisor")
		_cType_ = "divisor"
		_cTokenStr_ = This._Mid(_cTokenStr_, 9, len(_cTokenStr_))

	but startsWith(_cTokenStr_, "divisor")
		_cType_ = "divisor"
		_cTokenStr_ = This._Mid(_cTokenStr_, 8, len(_cTokenStr_))

	#--

	but startsWith(_cTokenStr_, "@multiple")
		_cType_ = "multiple"
		_cTokenStr_ = This._Mid(_cTokenStr_, 10, len(_cTokenStr_))

	but startsWith(_cTokenStr_, "multiple")
		_cType_ = "multiple"
		_cTokenStr_ = This._Mid(_cTokenStr_, 9, len(_cTokenStr_))

	#--

	else
		if @bDebugMode
			? "Unknown token type: " + _cTokenStr_
		ok
		return []
	ok
	
	_nOpenParen_ = StzFindFirst("(", _cTokenStr_)

	_nCloseParen_ = 0
	if _nOpenParen_ > 0
		_nCloseParen_ = StzFindFirst(")", _cTokenStr_)
		if _nCloseParen_ > _nOpenParen_
			_cContent_ = This._Mid(_cTokenStr_, _nOpenParen_ + 1, _nCloseParen_ - 1)

			if @bDebugMode
				? ">> cContent: " + _cContent_
				? ">> cType: " + _cType_
			ok

			if _cType_ = "property" or _cType_ = "approx" or
			   _cType_ = "relation" or _cType_ = "part" or
			   _cType_ = "divisor" or _cType_ = "multiple"

				_cValue_ = _cContent_

			else
				_aConstraints_ = This.ParseConstraints(_cContent_, _cType_)
			ok
		ok
	ok
	
	# Parse quantifier
	_cQuantPart_ = ""
	if _nCloseParen_ > 0
		# Extract everything after closing parenthesis
		if _nCloseParen_ < len(_cTokenStr_)
			_cQuantPart_ = This._Mid(_cTokenStr_, _nCloseParen_ + 1, len(_cTokenStr_))
		ok
	else
		# No parentheses - extract after token type name from original string
		_nTypeLen_ = 0
		_cLowerOriginal_ = StzLower(_cOriginal_)
		
		if startsWith(_cLowerOriginal_, "@digit")
			_nTypeLen_ = 6
		but startsWith(_cLowerOriginal_, "digit")
			_nTypeLen_ = 5
		but startsWith(_cLowerOriginal_, "@factor")
			_nTypeLen_ = 7
		but startsWith(_cLowerOriginal_, "factor")
			_nTypeLen_ = 6
		but startsWith(_cLowerOriginal_, "@property")
			_nTypeLen_ = 9
		but startsWith(_cLowerOriginal_, "property")
			_nTypeLen_ = 8
		but startsWith(_cLowerOriginal_, "@part")
			_nTypeLen_ = 5
		but startsWith(_cLowerOriginal_, "part")
			_nTypeLen_ = 4
		but startsWith(_cLowerOriginal_, "@relation")
			_nTypeLen_ = 9
		but startsWith(_cLowerOriginal_, "relation")
			_nTypeLen_ = 8
		but startsWith(_cLowerOriginal_, "@approx")
			_nTypeLen_ = 7
		but startsWith(_cLowerOriginal_, "approx")
			_nTypeLen_ = 6
		but startsWith(_cLowerOriginal_, "@divisor")
			_nTypeLen_ = 8
		but startsWith(_cLowerOriginal_, "divisor")
			_nTypeLen_ = 7
		but startsWith(_cLowerOriginal_, "@multiple")
			_nTypeLen_ = 9
		but startsWith(_cLowerOriginal_, "multiple")
			_nTypeLen_ = 8
		ok
		
		# Account for negation prefix
		if _bNegated_ = 1
			_nTypeLen_ += 2
		ok
		
		if _nTypeLen_ > 0 and _nTypeLen_ < len(_cOriginal_)
			_cQuantPart_ = This._Mid(_cOriginal_, _nTypeLen_ + 1, len(_cOriginal_))
		ok
	ok
	
	_cQuantPart_ = trim(_cQuantPart_)
	
	if @bDebugMode
		? "Quantifier part: [" + _cQuantPart_ + "]"
	ok
	
	if len(_cQuantPart_) > 0
		# Check for colon (constraints like :unique)
		if StzFindFirst(":", _cQuantPart_) > 0
			_nColon_ = StzFindFirst(":", _cQuantPart_)
			_cBeforeColon_ = This._Mid(_cQuantPart_, 1, _nColon_ - 1)
			_cAfterColon_ = This._Mid(_cQuantPart_, _nColon_ + 1, len(_cQuantPart_))
			
			if @bDebugMode
				? "Before colon: [" + _cBeforeColon_ + "]"
				? "After colon: [" + _cAfterColon_ + "]"
			ok
			
			_cBeforeColon_ = trim(_cBeforeColon_)
			if len(_cBeforeColon_) > 0 and This.IsNumeric(_cBeforeColon_)
				if StzFindFirst("-", _cBeforeColon_) > 0
					_aSection_ = @split(_cBeforeColon_, "-")
					if len(_aSection_) = 2
						_nMin_ = 0 + trim(_aSection_[1])
						_nMax_ = 0 + trim(_aSection_[2])
					ok
				else
					_nMin_ = 0 + _cBeforeColon_
					_nMax_ = _nMin_
				ok
			ok
			
			_aMoreConstraints_ = This.ParseConstraints(":" + _cAfterColon_, _cType_)
			_nLenMore_ = len(_aMoreConstraints_)
			for _i_ = 1 to _nLenMore_
				_aConstraints_ + _aMoreConstraints_[_i_]
			next
		else
			# No colon - check for simple quantifiers
			_cLastChar_ = StzRight(_cQuantPart_, 1)
			if _cLastChar_ = "+"
				# Check if there's a number before the +
				_cBeforePlus_ = StzLeft(_cQuantPart_, len(_cQuantPart_) - 1)
				if len(_cBeforePlus_) > 0 and This.IsNumeric(_cBeforePlus_)
					_nMin_ = 0 + _cBeforePlus_
					_nMax_ = 999999
				else
					_nMin_ = 1
					_nMax_ = 999999
				ok
			but _cLastChar_ = "*"
				# Check if there's a number before the *
				_cBeforeStar_ = StzLeft(_cQuantPart_, len(_cQuantPart_) - 1)
				if len(_cBeforeStar_) > 0 and This.IsNumeric(_cBeforeStar_)
					_nMin_ = 0 + _cBeforeStar_
					_nMax_ = 999999
				else
					_nMin_ = 0
					_nMax_ = 999999
				ok
			but _cLastChar_ = "?"
				_nMin_ = 0
				_nMax_ = 1
			but This.IsNumeric(_cQuantPart_)
				if StzFindFirst("-", _cQuantPart_) > 0
					_aSection_ = @split(_cQuantPart_, "-")
					if len(_aSection_) = 2
						_nMin_ = 0 + trim(_aSection_[1])
						_nMax_ = 0 + trim(_aSection_[2])
					ok
				else
					_nMin_ = 0 + _cQuantPart_
					_nMax_ = _nMin_
				ok
			ok
		ok
	ok
	
	return [
		["type", _cType_],
		["value", _cValue_],
		["constraints", _aConstraints_],
		["min", _nMin_],
		["max", _nMax_],
		["negated", _bNegated_]
	]

	def ParseConstraints(cConstraintStr, _cType_)
		_aConstraints_ = []
		
		if cConstraintStr = ""
			return _aConstraints_
		ok
		
		if _cType_ = "digit"
			if StzFindFirst(":unique", StzLower(cConstraintStr)) > 0
				_aConstraints_ + [["type", "unique"]]
			but StzFindFirst("..", cConstraintStr) > 0
				_aParts_ = @split(cConstraintStr, "..")
				if len(_aParts_) = 2
					_aConstraints_ + [
						["type", "Section"],
						["start", 0 + trim(_aParts_[1])],
						["end", 0 + trim(_aParts_[2])]
					]
				ok
			but StzFindFirst("{", cConstraintStr) > 0
				_nStart_ = StzFindFirst("{", cConstraintStr)
				_nEnd_ = StzFindFirst("}", cConstraintStr)
				_cSet_ = This._Mid(cConstraintStr, _nStart_ + 1, _nEnd_ - 1)
				_aValues_ = @split(_cSet_, ";")
				_aConstraints_ + [
					["type", "set"],
					["values", _aValues_]
				]
			but StzFindFirst(":step", cConstraintStr) > 0
				_cStep_ = This._Mid(cConstraintStr, 6, len(cConstraintStr))
				_aConstraints_ + [
					["type", "step"],
					["value", 0 + _cStep_]
				]
			but isDigit(cConstraintStr)
				_aConstraints_ + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
			but StzFindFirst("-", cConstraintStr) > 0
				_aParts_ = @split(cConstraintStr, "-")
				if len(_aParts_) = 2
					_aConstraints_ + [
						["type", "Section"],
						["start", 0 + trim(_aParts_[1])],
						["end", 0 + trim(_aParts_[2])]
					]
				ok
			ok
		
		but _cType_ = "factor"
			if StzLower(cConstraintStr) = "prime"
				_aConstraints_ + [["type", "prime"]]
			but StzLower(cConstraintStr) = "unique"
				_aConstraints_ + [["type", "unique"]]
			but isDigit(cConstraintStr)
				_aConstraints_ + [
					["type", "count"],
					["value", 0 + cConstraintStr]
				]
			ok
		ok
		
		return _aConstraints_
	
	  #--------------------#
	 #  MATCHING LOGIC    #
	#--------------------#
	
	def Match(pnNumber)

		if NOT isNumber(pnNumber)
			StzRaise("Incorrect param type! pnNumber must be a number.")
		ok

		@nNumber = pnNumber
		
		if @bDebugMode
			? "=== Matching " + pnNumber + " ==="
		ok

		_bResult_ = This.MatchTokens(@aTokens, @nNumber)
		
		if _bResult_
			This.ExtractParts(@nNumber)
		ok
		
		if @bDebugMode
			? "Result: " + _bResult_
		ok
		
		return _bResult_
	
	def MatchTokens(_aTokens_, _nNum_)
		_nLenTokens_ = len(_aTokens_)
		for _i_ = 1 to _nLenTokens_
			_aToken_ = _aTokens_[_i_]
			
			if HasKey(_aToken_, "type") and _aToken_["type"] = "alternation"
				_bMatched_ = FALSE
				if HasKey(_aToken_, "alternatives")
					_nLenAlt_ = len(_aToken_["alternatives"])
					for j = 1 to _nLenAlt_
						if This.MatchSingleToken(_aToken_["alternatives"][j], _nNum_)
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
					_nLenCond_ = len(_aToken_["conditions"])
					for j = 1 to _nLenCond_
						if not This.MatchSingleToken(_aToken_["conditions"][j], _nNum_)
							return FALSE
						ok
					next
				ok
			
			else
				if not This.MatchSingleToken(_aToken_, _nNum_)
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	def MatchSingleToken(_aToken_, _nNum_)
		_bResult_ = FALSE
		
		if @bDebugMode
			? "Checking token type: " + _aToken_["type"]
			if HasKey(_aToken_, "negated")
				? "Negated value: " + _aToken_["negated"]
			ok
		ok
		
		if HasKey(_aToken_, "type")
			_cType_ = _aToken_["type"]
			
			if _cType_ = "property"
				if HasKey(_aToken_, "value")
					_bResult_ = This.CheckProperty(_aToken_["value"], _nNum_)
				ok
			
			but _cType_ = "digit"
				_bResult_ = This.CheckDigits(_aToken_, _nNum_)
			
			but _cType_ = "factor"
				_bResult_ = This.CheckFactors(_aToken_, _nNum_)
			
			but _cType_ = "relation"
				if HasKey(_aToken_, "value")
					_bResult_ = This.CheckRelation(_aToken_["value"], _nNum_)
				ok
			
			but _cType_ = "approx"
				if HasKey(_aToken_, "value")
					_bResult_ = This.CheckApprox(_aToken_["value"], _nNum_)
				ok
			
			but _cType_ = "part"
				if HasKey(_aToken_, "value")
					_bResult_ = This.CheckPart(_aToken_["value"], _nNum_)
				ok
			
			but _cType_ = "divisor"
				if HasKey(_aToken_, "value")
					_bResult_ = This.CheckDivisor(_aToken_["value"], _nNum_)
				ok
			
			but _cType_ = "multiple"
				if HasKey(_aToken_, "value")
					_bResult_ = This.CheckMultiple(_aToken_["value"], _nNum_)
				ok
			ok
		ok
		
		if @bDebugMode
			? "Result before negation: " + _bResult_
		ok
		
		if HasKey(_aToken_, "negated") and _aToken_["negated"] = 1
			if @bDebugMode
				? "Applying negation"
			ok
			_bResult_ = not _bResult_
		ok
		
		if @bDebugMode
			? "Final result: " + _bResult_
		ok
		
		return _bResult_
	
	  #-----------------------#
	 #  PROPERTY CHECKING    #
	#-----------------------#
	
	def CheckProperty(_cProperty_, _nNum_)
		_cProperty_ = StzLower(trim(_cProperty_))
		
		if _cProperty_ = "prime"
			return This.IsPrime(_nNum_)
		but _cProperty_ = "even"
			return (_nNum_ % 2) = 0
		but _cProperty_ = "odd"
			return (_nNum_ % 2) != 0
		but _cProperty_ = "perfect"
			return This.IsPerfect(_nNum_)
		but _cProperty_ = "fibonacci"
			return This.IsFibonacci(_nNum_)
		but _cProperty_ = "palindrome"
			return This.IsPalindrome(_nNum_)
		but _cProperty_ = "square"
			return This.IsSquare(_nNum_)
		but _cProperty_ = "positive"
			return _nNum_ > 0
		but _cProperty_ = "negative"
			return _nNum_ < 0
		but _cProperty_ = "zero"
			return _nNum_ = 0
		but _cProperty_ = "composite"
			return _nNum_ > 1 and not This.IsPrime(_nNum_)
		but _cProperty_ = "abundant"
			return This.IsAbundant(_nNum_)
		but _cProperty_ = "deficient"
			return This.IsDeficient(_nNum_)
		but _cProperty_ = "triangular"
			return This.IsTriangular(_nNum_)
		but _cProperty_ = "cube"
			return This.IsCube(_nNum_)
		ok
		
		return FALSE
	
	def IsPrime(_nNum_)
		if _nNum_ < 2
			return FALSE
		ok
		if _nNum_ = 2
			return TRUE
		ok
		if (_nNum_ % 2) = 0
			return FALSE
		ok
		
		_nSqrt_ = sqrt(_nNum_)
		for _i_ = 3 to _nSqrt_ step 2
			if (_nNum_ % _i_) = 0
				return FALSE
			ok
		next
		
		return TRUE
	
	def IsPerfect(_nNum_)
		if _nNum_ < 2
			return FALSE
		ok
		
		_nSum_ = 1
		_nSqrt_ = sqrt(_nNum_)
		for _i_ = 2 to _nSqrt_
			if (_nNum_ % _i_) = 0
				_nSum_ += _i_
				if _i_ != (_nNum_ / _i_)
					_nSum_ += (_nNum_ / _i_)
				ok
			ok
		next
		
		return _nSum_ = _nNum_
	
	def IsFibonacci(_nNum_)
		return This.IsSquare(5 * _nNum_ * _nNum_ + 4) or This.IsSquare(5 * _nNum_ * _nNum_ - 4)
	
	def IsSquare(_nNum_)
		if _nNum_ < 0
			return FALSE
		ok
		_nSqrt_ = sqrt(_nNum_)
		return _nSqrt_ = floor(_nSqrt_)
	
	def IsPalindrome(_nNum_)
		_cStr_ = "" + abs(_nNum_)
		_cReversed_ = ""
		_nLen_ = len(_cStr_)
		for _i_ = _nLen_ to 1 step -1
			_cReversed_ += This._Mid(_cStr_, _i_, _i_)
		next
		return _cStr_ = _cReversed_
	
	def IsAbundant(_nNum_)
		if _nNum_ < 1
			return FALSE
		ok
		_aFactors_ = This.GetProperDivisors(_nNum_)
		_nSum_ = 0
		_nLen_ = len(_aFactors_)
		for _i_ = 1 to _nLen_
			_nSum_ += _aFactors_[_i_]
		next
		return _nSum_ > _nNum_
	
	def IsDeficient(_nNum_)
		if _nNum_ < 1
			return FALSE
		ok
		_aFactors_ = This.GetProperDivisors(_nNum_)
		_nSum_ = 0
		_nLen_ = len(_aFactors_)
		for _i_ = 1 to _nLen_
			_nSum_ += _aFactors_[_i_]
		next
		return _nSum_ < _nNum_
	
	def IsTriangular(_nNum_)
		return This.IsSquare(8 * _nNum_ + 1)
	
	def IsCube(_nNum_)
		if _nNum_ < 0
			return FALSE
		ok
		if _nNum_ = 0 or _nNum_ = 1
			return TRUE
		ok
		# Robust cube root check with floating point tolerance
		_nCubeRoot_ = pow(_nNum_, 1.0/3.0)
		_nLower_ = floor(_nCubeRoot_)
		_nUpper_ = ceil(_nCubeRoot_)
		return (_nLower_ * _nLower_ * _nLower_ = _nNum_) or (_nUpper_ * _nUpper_ * _nUpper_ = _nNum_)
	
	def GetProperDivisors(_nNum_)
		_aFactors_ = This.GetFactors(_nNum_)
		_aResult_ = []
		_nLen_ = len(_aFactors_)
		for _i_ = 1 to _nLen_
			if _aFactors_[_i_] != _nNum_
				_aResult_ + _aFactors_[_i_]
			ok
		next
		return _aResult_
	
	  #--------------------#
	 #  DIGIT CHECKING    #
	#--------------------#
	
def CheckDigits(_aToken_, _nNum_)
	_aDigits_ = This.GetDigits(_nNum_)
	_nCount_ = len(_aDigits_)
	_nMin_ = 1
	_nMax_ = 1
	
	if HasKey(_aToken_, "min")
		_nMin_ = _aToken_["min"]
	ok
	if HasKey(_aToken_, "max")
		_nMax_ = _aToken_["max"]
	ok
	
	if @bDebugMode
		? "CheckDigits: count=" + _nCount_ + " min=" + _nMin_ + " max=" + _nMax_
	ok
	
	if _nCount_ < _nMin_ or _nCount_ > _nMax_
		return FALSE
	ok
	
	if HasKey(_aToken_, "constraints")
		_nLenConstr_ = len(_aToken_["constraints"])
		for _i_ = 1 to _nLenConstr_
			_aConstraint_ = _aToken_["constraints"][_i_]
			
			if HasKey(_aConstraint_, "type")
				_cConstrType_ = _aConstraint_["type"]
				
				if _cConstrType_ = "Section"
					_nLenDigits_ = len(_aDigits_)
					for j = 1 to _nLenDigits_
						_nDigit_ = _aDigits_[j]
						_nStart_ = 0
						_nEnd_ = 9
						
						if HasKey(_aConstraint_, "start")
							_nStart_ = _aConstraint_["start"]
						ok
						if HasKey(_aConstraint_, "end")
							_nEnd_ = _aConstraint_["end"]
						ok
						
						if _nDigit_ < _nStart_ or _nDigit_ > _nEnd_
							return FALSE
						ok
					next
				
				but _cConstrType_ = "set"
					if HasKey(_aConstraint_, "values")
						_nLenDigits_ = len(_aDigits_)
						for j = 1 to _nLenDigits_
							_bFound_ = FALSE
							_nLenValues_ = len(_aConstraint_["values"])
							for k = 1 to _nLenValues_
								if _aDigits_[j] = (0 + trim(_aConstraint_["values"][k]))
									_bFound_ = TRUE
									exit
								ok
							next
							if not _bFound_
								return FALSE
							ok
						next
					ok
				
				but _cConstrType_ = "unique"
					_nLenDigits_ = len(_aDigits_)
					for j = 1 to _nLenDigits_
						for k = j + 1 to _nLenDigits_
							if _aDigits_[j] = _aDigits_[k]
								return FALSE
							ok
						next
					next
				
				but _cConstrType_ = "exact"
					if HasKey(_aConstraint_, "value")
						if _nCount_ != _aConstraint_["value"]
							return FALSE
						ok
					ok
				ok
			ok
		next
	ok
	
	return TRUE
	
	def GetDigits(_nNum_)
		_cStr_ = "" + abs(_nNum_)
		_aDigits_ = []
		_nLen_ = len(_cStr_)
		for _i_ = 1 to _nLen_
			_cChar_ = This._Mid(_cStr_, _i_, _i_)
			if isDigit(_cChar_)
				_aDigits_ + (0 + _cChar_)
			ok
		next
		return _aDigits_
	
	  #---------------------#
	 #  FACTOR CHECKING    #
	#---------------------#
	
	def CheckFactors(_aToken_, _nNum_)
		_aFactors_ = This.GetFactors(_nNum_)
		_nCount_ = len(_aFactors_)
		_nMin_ = 1
		_nMax_ = 1
		
		if HasKey(_aToken_, "min")
			_nMin_ = _aToken_["min"]
		ok
		if HasKey(_aToken_, "max")
			_nMax_ = _aToken_["max"]
		ok
		
		if _nCount_ < _nMin_ or _nCount_ > _nMax_
			return FALSE
		ok
		
		if HasKey(_aToken_, "constraints")
			_nLenConstr_ = len(_aToken_["constraints"])
			for _i_ = 1 to _nLenConstr_
				_aConstraint_ = _aToken_["constraints"][_i_]
				
				if HasKey(_aConstraint_, "type")
					_cConstrType_ = _aConstraint_["type"]
					
					if _cConstrType_ = "prime"
						_nLenFactors_ = len(_aFactors_)
						for j = 1 to _nLenFactors_
							if not This.IsPrime(_aFactors_[j])
								return FALSE
							ok
						next
					
					but _cConstrType_ = "unique"
						_nLenFactors_ = len(_aFactors_)
						for j = 1 to _nLenFactors_
							for k = j + 1 to _nLenFactors_
								if _aFactors_[j] = _aFactors_[k]
									return FALSE
								ok
							next
						next
					
					but _cConstrType_ = "count"
						if HasKey(_aConstraint_, "value")
							if _nCount_ != _aConstraint_["value"]
								return FALSE
							ok
						ok
					ok
				ok
			next
		ok
		
		return TRUE
	
	def GetFactors(_nNum_)
		_nNum_ = abs(_nNum_)
		_aFactors_ = []
		
		if _nNum_ = 0
			return _aFactors_
		ok
		
		_nSqrt_ = sqrt(_nNum_)
		for _i_ = 1 to _nSqrt_
			if (_nNum_ % _i_) = 0
				_aFactors_ + _i_
				if _i_ != (_nNum_ / _i_)
					_aFactors_ + (_nNum_ / _i_)
				ok
			ok
		next
		
		# Sort factors
		_nLen_ = len(_aFactors_)
		for _i_ = 1 to _nLen_ - 1
			for j = _i_ + 1 to _nLen_
				if _aFactors_[_i_] > _aFactors_[j]
					_temp_ = _aFactors_[_i_]
					_aFactors_[_i_] = _aFactors_[j]
					_aFactors_[j] = _temp_
				ok
			next
		next
		
		return _aFactors_
	
	  #-----------------------#
	 #  RELATION CHECKING    #
	#-----------------------#
	
	def CheckRelation(cRelation, _nNum_)
		if StzFindFirst("mod:", StzLower(cRelation)) > 0
			_cRest_ = This._Mid(cRelation, 5, len(cRelation))
			_nEquals_ = StzFindFirst("=", _cRest_)
			if _nEquals_ > 0
				_cMod_ = This._Mid(_cRest_, 1, _nEquals_ - 1)
				_cExpected_ = This._Mid(_cRest_, _nEquals_ + 1, len(_cRest_))
				_nMod_ = 0 + _cMod_
				_nExpected_ = 0 + _cExpected_
				return (_nNum_ % _nMod_) = _nExpected_
			ok
		ok
		return FALSE
	
	def CheckApprox(cApprox, _nNum_)
		if startsWith(cApprox, "~")
			_cValue_ = This._Mid(cApprox, 2, len(cApprox))
			_nDecimals_ = 2
			
			if StzFindFirst(":", _cValue_) > 0
				_aParts_ = @split(_cValue_, ":")
				_cValue_ = _aParts_[1]
				if len(_aParts_) > 1 and StzFindFirst("decimal", StzLower(_aParts_[2])) > 0
					_nLenPart_ = len(_aParts_[2])
					for _i_ = 1 to _nLenPart_
						if isDigit(This._Mid(_aParts_[2], _i_, _i_))
							_nDecimals_ = 0 + This._Mid(_aParts_[2], _i_, _i_)
							exit
						ok
					next
				ok
			ok
			
			_nTarget_ = 0 + _cValue_
			_nFactor_ = pow(10, _nDecimals_)
			return floor(_nNum_ * _nFactor_) = floor(_nTarget_ * _nFactor_)
		ok
		return FALSE
	
	def CheckPart(_cPart_, _nNum_)
		_cPart_ = StzLower(trim(_cPart_))
		
		if _cPart_ = "integer"
			# Check if number has no fractional part (with floating point tolerance)
			_nFrac_ = _nNum_ - floor(_nNum_)
			return (_nFrac_ >= -0.0000001 and _nFrac_ <= 0.0000001)
		
		but _cPart_ = "fractional"
			# Check if number has a fractional part
			_nFrac_ = _nNum_ - floor(_nNum_)
			return not (_nFrac_ >= -0.0000001 and _nFrac_ <= 0.0000001)
		
		but startsWith(_cPart_, "integer:")
			_cPattern_ = This._Mid(_cPart_, 9, len(_cPart_))
			_nIntPart_ = floor(_nNum_)
			_oNx_ = new stzNumbrex("{" + _cPattern_ + "}")
			return _oNx_.Match(_nIntPart_)
		
		but startsWith(_cPart_, "fractional:")
			_cPattern_ = This._Mid(_cPart_, 12, len(_cPart_))
			_nFracPart_ = _nNum_ - floor(_nNum_)
			_nFracInt_ = floor(_nFracPart_ * 1000000)
			_oNx_ = new stzNumbrex("{" + _cPattern_ + "}")
			return _oNx_.Match(_nFracInt_)
		ok
		
		return TRUE
	
	def CheckDivisor(_cValue_, _nNum_)
		_cValue_ = trim(_cValue_)
		if This.IsNumeric(_cValue_)
			_nDivisor_ = 0 + _cValue_
			if _nDivisor_ = 0
				return FALSE
			ok
			return (_nNum_ % _nDivisor_) = 0
		ok
		return FALSE
	
	def CheckMultiple(_cValue_, _nNum_)
		_cValue_ = trim(_cValue_)
		if This.IsNumeric(_cValue_)
			_nBase_ = 0 + _cValue_
			if _nBase_ = 0
				return FALSE
			ok
			return (_nNum_ % _nBase_) = 0
		ok
		return FALSE
	
	  #----------------------#
	 #  PART EXTRACTION     #
	#----------------------#
	
	def ExtractParts(_nNum_)
		@aMatchedParts = []
		
		_aDigits_ = This.GetDigits(_nNum_)
		@aMatchedParts + ["Digits", _aDigits_]
		
		_aFactors_ = This.GetFactors(_nNum_)
		@aMatchedParts + ["Factors", _aFactors_]
		
		_aProps_ = []
		if This.IsPrime(_nNum_)
			_aProps_ + "Prime"
		ok
		if (_nNum_ % 2) = 0
			_aProps_ + "Even"
		else
			_aProps_ + "Odd"
		ok
		if This.IsPerfect(_nNum_)
			_aProps_ + "Perfect"
		ok
		if This.IsFibonacci(_nNum_)
			_aProps_ + "Fibonacci"
		ok
		if This.IsPalindrome(_nNum_)
			_aProps_ + "Palindrome"
		ok
		if This.IsSquare(_nNum_)
			_aProps_ + "Square"
		ok
		if This.IsTriangular(_nNum_)
			_aProps_ + "Triangular"
		ok
		if This.IsCube(_nNum_)
			_aProps_ + "Cube"
		ok
		if This.IsAbundant(_nNum_)
			_aProps_ + "Abundant"
		ok
		if This.IsDeficient(_nNum_)
			_aProps_ + "Deficient"
		ok
		if _nNum_ > 1 and not This.IsPrime(_nNum_)
			_aProps_ + "Composite"
		ok
		
		@aMatchedParts + ["Properties", _aProps_]
		@aMatchedParts + ["Value", _nNum_]
	
	  #----------------------#
	 #  QUERY METHODS       #
	#----------------------#
	
	def MatchedParts()
		return @aMatchedParts
	
	def Digits()
		if HasKey(@aMatchedParts, "Digits")
			return @aMatchedParts["Digits"]
		ok
		return []

	def Factors()
		if HasKey(@aMatchedParts, "Factors")
			return @aMatchedParts["Factors"]
		ok
		return []

	def Properties()
		if HasKey(@aMatchedParts, "Properties")
			return @aMatchedParts["Properties"]
		ok
		return []

	def Value()
		if HasKey(@aMatchedParts, "Value")
			return @aMatchedParts["Value"]
		ok
		return 0
	
	def Tokens()
		return @aTokens
	
	def Pattern()
		return @cPattern
	
	def SetTarget(pnNumber)
		@nNumber = pnNumber
	
	def Explain()
		_aExplanation_ = [
			["Pattern", @cPattern],
			["TokenCount", len(@aTokens)],
			["Tokens", @aTokens]
		]
		
		if @nNumber != NULL
			_aExplanation_ + ["Target", @nNumber]
		ok
		
		if len(@aMatchedParts) > 0
			_aExplanation_ + ["MatchedParts", @aMatchedParts]
		ok
		
		return _aExplanation_
	
	  #---------------------------#
	 #  ADVANCED QUERY METHODS   #
	#---------------------------#
	
	def MatchingNumberAfter(_nStart_)
		_nCurrent_ = _nStart_
		_nMaxAttempts_ = 100000
		
		for _i_ = 1 to _nMaxAttempts_
			if This.Match(_nCurrent_)
				return _nCurrent_
			ok
			_nCurrent_++
		next
		
		return NULL

		def MatchingNumberNextTo(_nStart_)
			return This.MatchingNumberAfter(_nStart_)

	def MatchingNumberBefore(_nStart_)
		_nCurrent_ = _nStart_
		_nMaxAttempts_ = 100000
		
		for _i_ = 1 to _nMaxAttempts_
			if This.Match(_nCurrent_)
				return _nCurrent_
			ok
			_nCurrent_--
		next
		
		return NULL
	
		def MatchingNumberPreviousTo(_nStart_)
			return This.MatchingNumberBefore(_nStart_)

	def MatchingNumbersBetween(_nStart_, _nEnd_)
		if CheckParams()
			if NOT isNumber(_nStart_)
				StzRaise("Incorrect param type! nStart mustr be a number.")
			ok

			if isList(_nEnd_) and len(_nEnd_) = 2 and isString(_nEnd_[1]) and StzLower(_nEnd_[1]) = "and"
				_nEnd_ = _nEnd_[2]
			ok

			if NOT isNumber(_nEnd_)
				StzRaise("Incorrect param type! nEnd mustr be a number.")
			ok
		ok

		_aResults_ = []
		
		for _nNum_ = _nStart_ to _nEnd_
			if This.Match(_nNum_)
				_aResults_ + _nNum_
			ok
		next
		
		return _aResults_
	
		def MatchingBetween(_nStart_, _nEnd_)
			return This. MatchingNumbersBetween(_nStart_, _nEnd_)

	def CountMatchingBetween(_nStart_, _nEnd_)
		if CheckParams()
			if NOT isNumber(_nStart_)
				StzRaise("Incorrect param type! nStart mustr be a number.")
			ok

			if isList(_nEnd_) and len(_nEnd_) = 2 and isString(_nEnd_[1]) and StzLower(_nEnd_[1]) = "and"
				_nEnd_ = _nEnd_[2]
			ok

			if NOT isNumber(_nEnd_)
				StzRaise("Incorrect param type! nEnd mustr be a number.")
			ok
		ok

		_nCount_ = 0
		
		for _nNum_ = _nStart_ to _nEnd_
			if This.Match(_nNum_)
				_nCount_++
			ok
		next
		
		return _nCount_

		def CountMatchingNumbersBetween(_nStart_, _nEnd_)
			return This.CountMatchingBetween(_nStart_, _nEnd_)

		def HowManyMatchingNumbersBetween(_nStart_, _nEnd_)
			return This.CountMatchingBetween(_nStart_, _nEnd_)

		def NumberOfMatchingNumbersBetween(_nStart_, _nEnd_)
			return This.CountMatchingBetween(_nStart_, _nEnd_)
	
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
	
	def IsNumeric(_cStr_)
		if _cStr_ = ""
			return FALSE
		ok
		
		_nLen_ = len(_cStr_)
		for _i_ = 1 to _nLen_
			_cChar_ = This._Mid(_cStr_, _i_, _i_)
			if not isDigit(_cChar_) and _cChar_ != "-"
				return FALSE
			ok
		next
		

		return TRUE
