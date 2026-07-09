# Softanza Number Regex Engine

func StzNumberRegexQ(_cPattern_)
	return new stzNumberex(_cPattern_)

func StzNumberexQ(_cPattern_)
	return StzNumberRegexQ(_cPattern_)

func Nx(_cPattern_)
	return StzNumberRegexQ(_cPattern_)

class stzNumberex from stzObject

	@cPattern		# Original pattern string
	@aTokens		# Parsed token definitions
	@bDebugMode = false

	# Token type patterns
	@cIntPattern = '^@I'		# Integer
	@cRealPattern = '^@R'		# Real
	@cPosPattern = '^@P'		# Positive
	@cNegPattern = '^@N'		# Negative
	@cEvenPattern = '^@E'		# Even
	@cOddPattern = '^@O'		# Odd
	@cPrimePattern = '^@PR'		# Prime
	@cSectionPattern = '^@S'	# Section
	@cAnyPattern = '^@\$'		# Any number
	@cDigitPattern = '^@D'		# Digit count
	@cDivisiblePattern = '^@DIV'	# Divisible by

	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#

	def init(_cPattern_)
		if NOT isString(_cPattern_)
			stzraise("Error: Pattern must be a string")
		ok

		@cPattern = This.NormalizePattern(_cPattern_)
		@aTokens = This.ParsePattern(@cPattern)
		This.OptimizeTokens()

	def NormalizePattern(_cPattern_)
		_cPattern_ = @trim(_cPattern_)
		
		# Ensure pattern is enclosed in brackets
		if NOT (StartsWith(_cPattern_, "[") and EndsWith(_cPattern_, "]"))
			_cPattern_ = "[" + _cPattern_ + "]"
		ok
		
		return _cPattern_

	def ParsePattern(_cPattern_)
		# Remove outer brackets
		_cPattern_ = @trim(_cPattern_)
		_cInner_ = @StzMid(_cPattern_, 2, len(_cPattern_) - 1)
		_cInner_ = @trim(_cInner_)

		# Split at commas
		_aParts_ = This.SplitAtCommas(_cInner_)

		# Parse each token
		_aTokens_ = []
		_nLen_ = len(_aParts_)
		for i = 1 to _nLen_
			_aTokens_ + This.ParseToken(@trim(_aParts_[i]))
		next

		return _aTokens_

	def SplitAtCommas(cStr)
		_aParts_ = []
		_cCurrent_ = ""
		_acChars_ = Chars(cStr)
		_nLen_ = len(_acChars_)
		
		for i = 1 to _nLen_
			_cChar_ = _acChars_[i]
			
			if _cChar_ = ","
				_aParts_ + @trim(_cCurrent_)
				_cCurrent_ = ""
			else
				_cCurrent_ += _cChar_
			ok
		next
		
		if len(_cCurrent_) > 0
			_aParts_ + @trim(_cCurrent_)
		ok
		
		return _aParts_

	def ParseToken(_cTokenStr_)
		# Default values
		_bNegated_ = false
		_nMin_ = 1
		_nMax_ = 1
		_nQuantifier_ = 1
		_aConstraints_ = []
	
		# Check for negation
		if StartsWith(_cTokenStr_, "@!")
			_bNegated_ = true
			_cTokenStr_ = @StzMid(_cTokenStr_, 3, len(_cTokenStr_))
		ok
	
		# Ensure token starts with @
		if NOT StartsWith(_cTokenStr_, "@")
			_cTokenStr_ = "@" + _cTokenStr_
		ok
	
		# Extract keyword (2-3 chars)
		_cKeyword_ = ""
		_cRemainder_ = ""
		
		if @StzMid(_cTokenStr_, 1, 4) = "@DIV"
			_cKeyword_ = "@DIV"
			_cRemainder_ = @StzMid(_cTokenStr_, 5, len(_cTokenStr_))
		but @StzMid(_cTokenStr_, 1, 3) = "@PR"
			_cKeyword_ = "@PR"
			_cRemainder_ = @StzMid(_cTokenStr_, 4, len(_cTokenStr_))
		else
			_cKeyword_ = @StzMid(_cTokenStr_, 1, 2)
			_cRemainder_ = @StzMid(_cTokenStr_, 3, len(_cTokenStr_))
		ok
	
		# Check if remainder has constraints (starts with parenthesis or brace)
		_bHasConstraints_ = false
		if len(_cRemainder_) > 0
			if _cRemainder_[1] = "(" or _cRemainder_[1] = "{"
				_bHasConstraints_ = true
			ok
		ok
	
		if _bHasConstraints_
			# Parse constraints AND quantifier after them
			_aResult_ = This.ParseConstraintsAndQuantifier(_cRemainder_, _cKeyword_)
			_aConstraints_ = _aResult_[1]
			_nMin_ = _aResult_[2]
			_nMax_ = _aResult_[3]
			_nQuantifier_ = _aResult_[4]
		else
			# Parse quantifier directly (no constraints)
			if len(_cRemainder_) > 0
				_aQuantInfo_ = This.ParseQuantifier(_cRemainder_)
				_nMin_ = _aQuantInfo_[1]
				_nMax_ = _aQuantInfo_[2]
				_nQuantifier_ = _aQuantInfo_[3]
			ok
		ok
	
		# Build token
		_aToken_ = This.BuildToken(_cKeyword_, _nMin_, _nMax_, _nQuantifier_, _aConstraints_, _bNegated_)
		
		return _aToken_
	

	def ParseQuantifier(cStr)
		_nMin_ = 1
		_nMax_ = 1
		_nQuantifier_ = 1
		_cRemainder_ = cStr
	
		# Check for +, *, ? FIRST
		if len(cStr) > 0
			if cStr[1] = "+"
				_nMin_ = 1
				_nMax_ = 999999999
				_cRemainder_ = @StzMid(cStr, 2, len(cStr))
				return [_nMin_, _nMax_, _nQuantifier_, _cRemainder_]
	
			but cStr[1] = "*"
				_nMin_ = 0
				_nMax_ = 999999999
				_cRemainder_ = @StzMid(cStr, 2, len(cStr))
				return [_nMin_, _nMax_, _nQuantifier_, _cRemainder_]
	
			but cStr[1] = "?"
				_nMin_ = 0
				_nMax_ = 1
				_cRemainder_ = @StzMid(cStr, 2, len(cStr))
				return [_nMin_, _nMax_, _nQuantifier_, _cRemainder_]
			ok
		ok
	
		# Check for section pattern WITHOUT parentheses (e.g., "2-5")
		_oSectionMatch_ = rx('^(\d+)-(\d+)')
		if _oSectionMatch_.Match(cStr)
			_aMatches_ = @split(_oSectionMatch_.Matches()[1], "-")
			_nMin_ = 0+ _aMatches_[1]
			_nMax_ = 0+ _aMatches_[2]
			
			if _nMin_ > _nMax_
				stzraise("Error: Invalid section - min > max")
			ok
			
			_nMatchLen_ = len(_aMatches_[1]) + 1 + len(_aMatches_[2])
			_cRemainder_ = @StzMid(cStr, _nMatchLen_ + 1, len(cStr))
			return [_nMin_, _nMax_, _nQuantifier_, _cRemainder_]
		ok
	
		# Check for single number (not in parentheses)
		_oNumberMatch_ = rx('^\d+')
		if _oNumberMatch_.Match(cStr)
			_aMatches_ = _oNumberMatch_.Matches()
			_nQuantifier_ = 0+ _aMatches_[1]
			_nMin_ = _nQuantifier_
			_nMax_ = _nQuantifier_
			_cRemainder_ = @StzMid(cStr, len(_aMatches_[1]) + 1, len(cStr))
		ok
	
		return [_nMin_, _nMax_, _nQuantifier_, _cRemainder_]


	def ParseConstraints(cStr, _cKeyword_)
		_aConstraints_ = []
	
		# Parse section constraints: (min..max)
		_oSectionMatch_ = rx('\((-?\d+(?:\.\d+)?)\.\.(-?\d+(?:\.\d+)?)\)')
		if _oSectionMatch_.Match(cStr)
			_aMatches_ = _oSectionMatch_.Matches()
			# Extract the content without parentheses and split on ".."
			_cSectionStr_ = _aMatches_[1]
			_cSectionContent_ = @StzMid(_cSectionStr_, 2, len(_cSectionStr_) - 1)  # Remove ( and )
			_aParts_ = @split(_cSectionContent_, "..")
			_aConstraints_ + ["section", [0+ _aParts_[1], 0+ _aParts_[2]]]
		ok
	
		# Parse set constraints: {val1;val2;val3}
		_oSetMatch_ = rx('\{([^}]+)\}')
		if _oSetMatch_.Match(cStr)
			_aMatches_ = _oSetMatch_.Matches()
			# Extract content without braces
			_cSetStr_ = _aMatches_[1]
			_cSetContent_ = StzMid(_cSetStr_, 2, len(_cSetStr_) - 2)  # Remove { and }
			_aParts_ = @split(_cSetContent_, ";")
			
			_aValues_ = []
			_nLen_ = len(_aParts_)
			for i = 1 to _nLen_
				_cVal_ = @trim(_aParts_[i])
				if len(_cVal_) > 0
					_aValues_ + (0+ _cVal_)
				ok
			next
			
			_aConstraints_ + ["set", _aValues_]
		ok
	
		# Parse divisible constraint: @DIV(n)
		if _cKeyword_ = "@DIV"
			_oDivMatch_ = rx('\((\d+)\)')
			if _oDivMatch_.Match(cStr)
				_aMatches_ = _oDivMatch_.Matches()
				_cDivStr_ = _aMatches_[1]
				_cDivNum_ = StzMid(_cDivStr_, 2, len(_cDivStr_) - 2)  # Remove ( and )
				_aConstraints_ + ["divisor", 0+ _cDivNum_]
			ok
		ok
	
		# Parse digit count: @D(n)
		if _cKeyword_ = "@D"
			_oDigitMatch_ = rx('\((\d+)\)')
			if _oDigitMatch_.Match(cStr)
				_aMatches_ = _oDigitMatch_.Matches()
				_cDigitStr_ = _aMatches_[1]
				_cDigitNum_ = StzMid(_cDigitStr_, 2, len(_cDigitStr_) - 2)  # Remove ( and )
				_aConstraints_ + ["digits", 0+ _cDigitNum_]
			ok
		ok
	
		return _aConstraints_


	def ParseConstraintsAndQuantifier(cStr, _cKeyword_)
		_aConstraints_ = []
		_nMin_ = 1
		_nMax_ = 1
		_nQuantifier_ = 1
		_cRemainder_ = cStr
	
		# Parse constraints first
		_aConstraints_ = This.ParseConstraints(cStr, _cKeyword_)
		
		# Remove constraints from string in order
		# 1. Remove @DIV(n) or @D(n) - simple single number in parens
		if _cKeyword_ = "@D" or _cKeyword_ = "@DIV"
			_oSimpleMatch_ = rx('^\(\d+\)')
			if _oSimpleMatch_.Match(_cRemainder_)
				_aMatches_ = _oSimpleMatch_.Matches()
				_cRemainder_ = @StzMid(_cRemainder_, len(_aMatches_[1]) + 1, len(_cRemainder_))
			ok
		ok
		
		# 2. Remove section constraints: (min..max) 
		_oSectionMatch_ = rx('^\((-?\d+(?:\.\d+)?)\.\.(-?\d+(?:\.\d+)?)\)')
		if _oSectionMatch_.Match(_cRemainder_)
			_aMatches_ = _oSectionMatch_.Matches()
			_cRemainder_ = @StzMid(_cRemainder_, len(_aMatches_[1]) + 1, len(_cRemainder_))
		ok
		
		# 3. Remove set constraints: {val1;val2;val3}
		_oSetMatch_ = rx('^\{([^}]+)\}')
		if _oSetMatch_.Match(_cRemainder_)
			_aMatches_ = _oSetMatch_.Matches()
			_cRemainder_ = @StzMid(_cRemainder_, len(_aMatches_[1]) + 1, len(_cRemainder_))
		ok
		
		# Now parse quantifier from remainder
		if len(_cRemainder_) > 0
			_aQuantInfo_ = This.ParseQuantifier(_cRemainder_)
			_nMin_ = _aQuantInfo_[1]
			_nMax_ = _aQuantInfo_[2]
			_nQuantifier_ = _aQuantInfo_[3]
		ok
	
		return [_aConstraints_, _nMin_, _nMax_, _nQuantifier_]
	


	def BuildToken(_cKeyword_, _nMin_, _nMax_, _nQuantifier_, _aConstraints_, _bNegated_)
		_aToken_ = [
			["keyword", _cKeyword_],
			["min", _nMin_],
			["max", _nMax_],
			["quantifier", _nQuantifier_],
			["constraints", _aConstraints_],
			["negated", _bNegated_]
		]

		# Add type-specific info
		switch _cKeyword_
		on "@I"
			_aToken_ + ["type", "integer"]
		on "@R"
			_aToken_ + ["type", "real"]
		on "@P"
			_aToken_ + ["type", "positive"]
		on "@N"
			_aToken_ + ["type", "negative"]
		on "@E"
			_aToken_ + ["type", "even"]
		on "@O"
			_aToken_ + ["type", "odd"]
		on "@PR"
			_aToken_ + ["type", "prime"]
		on "@S"
			_aToken_ + ["type", "section"]
		on "@$"
			_aToken_ + ["type", "any"]
		on "@D"
			_aToken_ + ["type", "digits"]
		on "@DIV"
			_aToken_ + ["type", "divisible"]
		off

		return _aToken_


	def OptimizeTokens()
		# Merge adjacent compatible tokens
		_nLen_ = len(@aTokens)
		
		if _nLen_ <= 1
			return
		ok
		
		for i = _nLen_ to 2 step -1
			_aToken1_ = @aTokens[i-1]
			_aToken2_ = @aTokens[i]
			
			# Can merge if same type and no constraints
			if _aToken1_[:keyword] = _aToken2_[:keyword] and
			   len(_aToken1_[:constraints]) = 0 and
			   len(_aToken2_[:constraints]) = 0
				
				_nNewMin_ = @Min([_aToken1_[:min], _aToken2_[:min]])
				_nNewMax_ = _aToken1_[:max] + _aToken2_[:max]
				
				@aTokens[i-1][:min] = _nNewMin_
				@aTokens[i-1][:max] = _nNewMax_
				del(@aTokens, i)
			ok
		next

	  #--------------------#
	 #   MATCHING LOGIC   #
	#--------------------#

	def Match(paNumbers)
		if NOT isList(paNumbers)
			return false
		ok

		# Ensure all elements are numbers
		_nLen_ = len(paNumbers)
		for i = 1 to _nLen_
			if NOT isNumber(paNumbers[i])
				return false
			ok
		next

		try
			return This.BacktrackMatch(@aTokens, paNumbers, 1, 1)
		catch
			if @bDebugMode
				? "Error during matching"
			ok
			return false
		done

/*
def BacktrackMatch(_aTokens_, aNumbers, nTokenIndex, nNumberIndex)

	# DEBUG
	? "BacktrackMatch: token " + nTokenIndex + ", number " + nNumberIndex

	_nLenTokens_ = len(_aTokens_)
	_nLenNumbers_ = len(aNumbers)

	# Base case: processed all tokens
	if nTokenIndex > _nLenTokens_
		return nNumberIndex > _nLenNumbers_
	ok

	_aToken_ = _aTokens_[nTokenIndex]

	# Try different match counts
	_nMax_ = @Min([_aToken_[:max], _nLenNumbers_ - nNumberIndex + 1])
	
	# DEBUG
	? "  Token min: " + _aToken_[:min] + ", max: " + _aToken_[:max]
	? "  Trying matches from " + _aToken_[:min] + " to " + _nMax_

	for nMatchCount = _aToken_[:min] to _nMax_
		_bSuccess_ = true
		_nNumIdx_ = nNumberIndex

		# Try to match nMatchCount numbers
		for i = 1 to nMatchCount
			if _nNumIdx_ > _nLenNumbers_
				_bSuccess_ = false
				exit
			ok

			_nNumber_ = aNumbers[_nNumIdx_]
			
			if NOT This.MatchNumber(_nNumber_, _aToken_)
				_bSuccess_ = false
				exit
			ok

			_nNumIdx_++
		next

		if _bSuccess_
			# Last token - ensure complete match
			if nTokenIndex = _nLenTokens_
				if _nNumIdx_ = _nLenNumbers_ + 1
					return true
				ok
			else
				# Recurse for remaining tokens
				if This.BacktrackMatch(_aTokens_, aNumbers, nTokenIndex + 1, _nNumIdx_)
					return true
				ok
			ok
		ok
	next

	# Handle optional tokens
	if _aToken_[:min] = 0
		if This.BacktrackMatch(_aTokens_, aNumbers, nTokenIndex + 1, nNumberIndex)
			return true
		ok
	ok

	return false
*/
def BacktrackMatch(_aTokens_, aNumbers, nTokenIndex, nNumberIndex)
	_nLenTokens_ = len(_aTokens_)
	_nLenNumbers_ = len(aNumbers)

	# Base case: processed all tokens
	if nTokenIndex > _nLenTokens_
		return nNumberIndex > _nLenNumbers_
	ok

	_aToken_ = _aTokens_[nTokenIndex]

	# Try different match counts
	_nMax_ = @Min([_aToken_[:max], _nLenNumbers_ - nNumberIndex + 1])

	if @bDebugMode
		? "BacktrackMatch: token " + nTokenIndex + "/" + _nLenTokens_ + ", number " + nNumberIndex + "/" + _nLenNumbers_
		? "  Token: " + _aToken_[:keyword] + " (min: " + _aToken_[:min] + ", max: " + _aToken_[:max] + ")"
		? "  Trying matches from " + _aToken_[:min] + " to " + _nMax_
	ok

	for nMatchCount = _aToken_[:min] to _nMax_
		_bSuccess_ = true
		_nNumIdx_ = nNumberIndex

		# Try to match nMatchCount numbers
		for i = 1 to nMatchCount
			if _nNumIdx_ > _nLenNumbers_
				_bSuccess_ = false
				exit
			ok

			_nNumber_ = aNumbers[_nNumIdx_]
			
			if NOT This.MatchNumber(_nNumber_, _aToken_)
				if @bDebugMode
					? "  Number " + _nNumber_ + " failed to match"
				ok
				_bSuccess_ = false
				exit
			ok

			_nNumIdx_++
		next

		if _bSuccess_
			if @bDebugMode
				? "  Matched " + nMatchCount + " number(s)"
			ok
			
			# Last token - ensure complete match
			if nTokenIndex = _nLenTokens_
				if _nNumIdx_ = _nLenNumbers_ + 1
					return true
				ok
			else
				# Recurse for remaining tokens
				if This.BacktrackMatch(_aTokens_, aNumbers, nTokenIndex + 1, _nNumIdx_)
					return true
				ok
			ok
		ok
	next

	# Handle optional tokens
	if _aToken_[:min] = 0
		if This.BacktrackMatch(_aTokens_, aNumbers, nTokenIndex + 1, nNumberIndex)
			return true
		ok
	ok

	return false

	def MatchNumber(_nNumber_, _aToken_)
		_bMatch_ = false
	
		# Type checking
		switch _aToken_[:keyword]
		on "@I"
			_bMatch_ = This.IsInteger(_nNumber_)
		on "@R"
			_bMatch_ = This.IsReal(_nNumber_)
		on "@P"
			_bMatch_ = _nNumber_ > 0
		on "@N"
			_bMatch_ = _nNumber_ < 0
		on "@E"
			_bMatch_ = This.IsEven(_nNumber_)
		on "@O"
			_bMatch_ = This.IsOdd(_nNumber_)
		on "@PR"
			_bMatch_ = This.IsPrime(_nNumber_)
		on "@$"
			_bMatch_ = true
		on "@D"
			_bMatch_ = true
		on "@DIV"
			_bMatch_ = true
		off
	
		# If base type already failed and not negated, no need to check constraints
		if NOT _bMatch_ and NOT _aToken_[:negated]
			return false
		ok
	
		# Check constraints - any failure means no match
		_nLen_ = len(_aToken_[:constraints])
		_bConstraintsMet_ = true
		
		for i = 1 to _nLen_
			_aConstraint_ = _aToken_[:constraints][i]
			_cType_ = _aConstraint_[1]
	
			switch _cType_
			on "section"
				_aSection_ = _aConstraint_[2]
				if _nNumber_ < _aSection_[1] or _nNumber_ > _aSection_[2]
					_bConstraintsMet_ = false
					exit
				ok
	
			on "set"
				_aSet_ = _aConstraint_[2]
				_bInSet_ = false
				_nSetLen_ = len(_aSet_)
				for j = 1 to _nSetLen_
					if _nNumber_ = _aSet_[j]
						_bInSet_ = true
						exit
					ok
				next
				if NOT _bInSet_
					_bConstraintsMet_ = false
					exit
				ok
	
			on "divisor"
				_nDivisor_ = _aConstraint_[2]
				if (_nNumber_ % _nDivisor_) != 0
					_bConstraintsMet_ = false
					exit
				ok
	
			on "digits"
				_nDigits_ = _aConstraint_[2]
				if This.CountDigits(_nNumber_) != _nDigits_
					_bConstraintsMet_ = false
					exit
				ok
			off
		next
	
		# Combine base match with constraints
		_bMatch_ = _bMatch_ and _bConstraintsMet_
	
		# Apply negation AFTER all checks
		if _aToken_[:negated]
			_bMatch_ = NOT _bMatch_
		ok
	
		return _bMatch_

	  #--------------------#
	 #   HELPER METHODS   #
	#--------------------#

	def IsInteger(_n_)
		return _n_ = floor(_n_)

	def IsReal(_n_)
		return _n_ != floor(_n_)

	def IsEven(_n_)
		if NOT This.IsInteger(_n_)
			return false
		ok
		return (_n_ % 2) = 0

	def IsOdd(_n_)
		if NOT This.IsInteger(_n_)
			return false
		ok
		return (_n_ % 2) != 0

	def IsPrime(_n_)
		if NOT This.IsInteger(_n_) or _n_ < 2
			return false
		ok

		if _n_ = 2
			return true
		ok

		if (_n_ % 2) = 0
			return false
		ok

		for i = 3 to sqrt(_n_) step 2
			if (_n_ % i) = 0
				return false
			ok
		next

		return true

	def CountDigits(_n_)
		_n_ = fabs(_n_)
		if _n_ = 0
			return 1
		ok
		return floor(log10(_n_)) + 1

	  #---------------------------#
	 #     DEBUG METHODS         #
	#---------------------------#

	def EnableDebug()
		@bDebugMode = true

	def DisableDebug()
		@bDebugMode = false

	def TokensXT()
		return @aTokens

	def Tokens()
		_acResult_ = []
		_nLen_ = len(@aTokens)

		for i = 1 to _nLen_
			_acResult_ + @aTokens[i][:keyword]
		next

		return _acResult_

	def TokensU()
		return U(This.Tokens())

		def UniqueTokens()
			return This.TokensU()

	def TokensInfo()
		_aInfo_ = []
		
		_nTokensLen_ = len(@aTokens)
		for i = 1 to _nTokensLen_
			_aToken_ = @aTokens[i]
			_cInfo_ = "Token #" + i + ": " + _aToken_[:keyword]
			
			if _aToken_[:min] != _aToken_[:max]
				_cInfo_ += " (" + _aToken_[:min] + "-" + _aToken_[:max] + ")"
			but _aToken_[:min] > 1
				_cInfo_ += _aToken_[:min]
			ok

			if len(_aToken_[:constraints]) > 0
				_cInfo_ += " [constraints: " + len(_aToken_[:constraints]) + "]"
			ok

			if _aToken_[:negated]
				_cInfo_ += " [negated]"
			ok
			
			_aInfo_ + _cInfo_
		next
		
		return _aInfo_

	def Pattern()
		return @cPattern
