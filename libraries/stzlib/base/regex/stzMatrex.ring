# stzMatrex - Matrix Pattern Matching for Softanza
# A regex-like pattern language for matrix structures
# Companion to stzNumbrex for 2D numerical data

# Quick constructor functions
func StzMatrexQ(_cPattern_)
	return new stzMatrex(_cPattern_)

func Matrex(_cPattern_)
	return new stzMatrex(_cPattern_)

func Mx(_cPattern_)
	return new stzMatrex(_cPattern_)

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

	# End-based substring helper. The parser was written assuming
	# Mid(str, start, END) but the global @StzMid is COUNT-based -- so
	# pattern tokens never parsed and Match() answered FALSE for every
	# input. Route all calls through here, converting end -> count.
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
		
		if @bDebugMode
			? ">>> Processing part " + _i_ + ": [" + _cPart_ + "]"
		ok
		
		if _cPart_ = ""
			loop
		ok
		
		if StzFindFirst(_cPart_, "|") > 0
			if @bDebugMode
				? ">>> Detected alternation"
			ok
			_aToken_ = This.ParseAlternation(_cPart_)
		but StzFindFirst(_cPart_, "&") > 0
			if @bDebugMode
				? ">>> Detected conjunction"
			ok
			_aToken_ = This.ParseConjunction(_cPart_)
		else
			if @bDebugMode
				? ">>> Parsing as single token"
			ok
			_aToken_ = This.ParseSingleToken(_cPart_)
		ok
		
		if @bDebugMode
			? ">>> Token result: " + @@(_aToken_)
			? ">>> Token length: " + len(_aToken_)
		ok
		
		# Remove this condition - ALWAYS add tokens
		_aTokens_ + _aToken_
	next
	
	if @bDebugMode
		? ">>> Final token count: " + len(_aTokens_)
	ok
	
	return _aTokens_
	
	def SplitByOperator(cStr, cOperator)
		_aParts_ = []
		_cCurrent_ = ""
		_nDepth_ = 0
		_nLen_ = len(cStr)
		_nOpLen_ = len(cOperator)
		
		for _i_ = 1 to _nLen_
			_cChar_ = This._Mid(cStr, _i_, _i_)
			
			if _cChar_ = "(" or _cChar_ = "{"
				_nDepth_++
				_cCurrent_ += _cChar_
			but _cChar_ = ")" or _cChar_ = "}"
				_nDepth_--
				_cCurrent_ += _cChar_
			but _nDepth_ = 0 and This._Mid(cStr, _i_, _i_ + _nOpLen_ - 1) = cOperator
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
		
		_aParts_ = This.SplitByOperatOr(_cTokenStr_, "|")
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
	
	_aParts_ = This.SplitByOperatOr(_cTokenStr_, "&")
	_aConditions_ = []
	_nLenParts_ = len(_aParts_)
	
	if @bDebugMode
		? ">>>> ParseConjunction: " + _nLenParts_ + " parts"
	ok
	
	for _i_ = 1 to _nLenParts_
		_cPart_ = trim(_aParts_[_i_])
		
		if @bDebugMode
			? ">>>> Conjunction part " + _i_ + ": [" + _cPart_ + "]"
		ok
		
		if _cPart_ != ""
			_aToken_ = This.ParseSingleToken(_cPart_)
			
			if @bDebugMode
				? ">>>> Parsed token: " + @@(_aToken_)
			ok
			
			# ALWAYS add - don't skip errors
			_aConditions_ + _aToken_
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
		
		# Parse token types
		if startsWith(_cTokenStr_, "@size")
			_cType_ = "size"
			_cTokenStr_ = This._Mid(_cTokenStr_, 6, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "size")
			_cType_ = "size"
			_cTokenStr_ = This._Mid(_cTokenStr_, 5, len(_cTokenStr_))
			
		but startsWith(_cTokenStr_, "@shape")
			_cType_ = "shape"
			_cTokenStr_ = This._Mid(_cTokenStr_, 7, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "shape")
			_cType_ = "shape"
			_cTokenStr_ = This._Mid(_cTokenStr_, 6, len(_cTokenStr_))
			
		but startsWith(_cTokenStr_, "@element")
			_cType_ = "element"
			_cTokenStr_ = This._Mid(_cTokenStr_, 9, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "element")
			_cType_ = "element"
			_cTokenStr_ = This._Mid(_cTokenStr_, 8, len(_cTokenStr_))
			
		but startsWith(_cTokenStr_, "@row")
			_cType_ = "row"
			_cTokenStr_ = This._Mid(_cTokenStr_, 5, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "row")
			_cType_ = "row"
			_cTokenStr_ = This._Mid(_cTokenStr_, 4, len(_cTokenStr_))
			
		but startsWith(_cTokenStr_, "@col")
			_cType_ = "col"
			_cTokenStr_ = This._Mid(_cTokenStr_, 5, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "col")
			_cType_ = "col"
			_cTokenStr_ = This._Mid(_cTokenStr_, 4, len(_cTokenStr_))
			
		but startsWith(_cTokenStr_, "@diagonal")
			_cType_ = "diagonal"
			_cTokenStr_ = This._Mid(_cTokenStr_, 10, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "diagonal")
			_cType_ = "diagonal"
			_cTokenStr_ = This._Mid(_cTokenStr_, 9, len(_cTokenStr_))
			
		but startsWith(_cTokenStr_, "@property")
			_cType_ = "property"
			_cTokenStr_ = This._Mid(_cTokenStr_, 10, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "property")
			_cType_ = "property"
			_cTokenStr_ = This._Mid(_cTokenStr_, 9, len(_cTokenStr_))
			
		but startsWith(_cTokenStr_, "@pattern")
			_cType_ = "pattern"
			_cTokenStr_ = This._Mid(_cTokenStr_, 9, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "pattern")
			_cType_ = "pattern"
			_cTokenStr_ = This._Mid(_cTokenStr_, 8, len(_cTokenStr_))
			
		but startsWith(_cTokenStr_, "@determinant")
			_cType_ = "determinant"
			_cTokenStr_ = This._Mid(_cTokenStr_, 13, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "determinant")
			_cType_ = "determinant"
			_cTokenStr_ = This._Mid(_cTokenStr_, 12, len(_cTokenStr_))
			
		but startsWith(_cTokenStr_, "@sum")
			_cType_ = "sum"
			_cTokenStr_ = This._Mid(_cTokenStr_, 5, len(_cTokenStr_))
		but startsWith(_cTokenStr_, "sum")
			_cType_ = "sum"
			_cTokenStr_ = This._Mid(_cTokenStr_, 4, len(_cTokenStr_))
			
		else
			# UNKNOWN TOKEN - return error marker
			if @bDebugMode
				? "Unknown token type: " + _cTokenStr_
			ok
			return [
				["type", "ERROR"],
				["value", _cOriginal_],
				["message", "Unrecognized token type"]
			]
		ok
		
		# Parse parentheses content
		_nOpenParen_ = StzFindFirst(_cTokenStr_, "(")
		_nCloseParen_ = 0

		if _nOpenParen_ > 0
			_nCloseParen_ = StzFindFirst(_cTokenStr_, ")")
			if _nCloseParen_ > _nOpenParen_
				_cContent_ = This._Mid(_cTokenStr_, _nOpenParen_ + 1, _nCloseParen_ - 1)
				
				if @bDebugMode
					? ">> cContent: " + _cContent_
					? ">> cType: " + _cType_
				ok
				
				if _cType_ = "property" or _cType_ = "shape" or 
				   _cType_ = "pattern" or _cType_ = "size"
					_cValue_ = _cContent_
				else
					_aConstraints_ = This.ParseConstraints(_cContent_, _cType_)
				ok
			ok
		ok
		
		# Parse quantifiers
		_cQuantPart_ = ""
		if _nCloseParen_ > 0 and _nCloseParen_ < len(_cTokenStr_)
			_cQuantPart_ = This._Mid(_cTokenStr_, _nCloseParen_ + 1, len(_cTokenStr_))
		ok
		
		_cQuantPart_ = trim(_cQuantPart_)
		
		if len(_cQuantPart_) > 0
			if StzFindFirst(_cQuantPart_, ":") > 0
				_nColon_ = StzFindFirst(_cQuantPart_, ":")
				_cBeforeColon_ = This._Mid(_cQuantPart_, 1, _nColon_ - 1)
				_cAfterColon_ = This._Mid(_cQuantPart_, _nColon_ + 1, len(_cQuantPart_))
				
				_cBeforeColon_ = trim(_cBeforeColon_)
				if len(_cBeforeColon_) > 0 and This.IsNumeric(_cBeforeColon_)
					if StzFindFirst(_cBeforeColon_, "-") > 0
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
					if StzFindFirst(_cQuantPart_, "-") > 0
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
		
		if _cType_ = "element"
			if StzFindFirst(cConstraintStr, "..") > 0
				_aParts_ = @split(cConstraintStr, "..")
				if len(_aParts_) = 2
					_aConstraints_ + [
						["type", "range"],
						["start", 0 + trim(_aParts_[1])],
						["end", 0 + trim(_aParts_[2])]
					]
				ok
			but StzFindFirst(cConstraintStr, "{") > 0
				_nStart_ = StzFindFirst(cConstraintStr, "{")
				_nEnd_ = StzFindFirst(cConstraintStr, "}")
				_cSet_ = This._Mid(cConstraintStr, _nStart_ + 1, _nEnd_ - 1)
				_aValues_ = @split(_cSet_, ";")
				_aConstraints_ + [
					["type", "set"],
					["values", _aValues_]
				]
			but This.IsNumeric(cConstraintStr)
				_aConstraints_ + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
			ok
		
		but _cType_ = "size"
			# Handle size constraints like "3x3", "mxn", ">4"
			if StzFindFirst(cConstraintStr, "x") > 0
				_aParts_ = @split(cConstraintStr, "x")
				if len(_aParts_) = 2
					_aConstraints_ + [
						["type", "dimensions"],
						["rows", trim(_aParts_[1])],
						["cols", trim(_aParts_[2])]
					]
				ok
			but startsWith(cConstraintStr, ">")
				_aConstraints_ + [
					["type", "greater"],
					["value", 0 + This._Mid(cConstraintStr, 2, len(cConstraintStr))]
				]
			but startsWith(cConstraintStr, "<")
				_aConstraints_ + [
					["type", "less"],
					["value", 0 + This._Mid(cConstraintStr, 2, len(cConstraintStr))]
				]
			ok
		ok
		
		return _aConstraints_
	
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
		
		_bResult_ = This.MatchTokens(@aTokens, @aMatrix)
		
		if _bResult_
			This.ExtractParts(@aMatrix)
		ok
		
		if @bDebugMode
			? "Result: " + _bResult_
		ok
		
		return _bResult_
	
	def MatchTokens(_aTokens_, aMatrix)
		_nLenTokens_ = len(_aTokens_)
		for _i_ = 1 to _nLenTokens_
			_aToken_ = _aTokens_[_i_]
			
			if HasKey(_aToken_, "type") and _aToken_["type"] = "alternation"
				_bMatched_ = FALSE
				if HasKey(_aToken_, "alternatives")
					_nLenAlt_ = len(_aToken_["alternatives"])
					for j = 1 to _nLenAlt_
						if This.MatchSingleToken(_aToken_["alternatives"][j], aMatrix)
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
						if not This.MatchSingleToken(_aToken_["conditions"][j], aMatrix)
							return FALSE
						ok
					next
				ok
			
			else
				if not This.MatchSingleToken(_aToken_, aMatrix)
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	def MatchSingleToken(_aToken_, aMatrix)
		_bResult_ = FALSE
		
		if @bDebugMode
			? "Checking token type: " + _aToken_["type"]
			if HasKey(_aToken_, "negated")
				? "Negated value: " + _aToken_["negated"]
			ok
		ok
		
		if HasKey(_aToken_, "type")
			_cType_ = _aToken_["type"]
			
			if _cType_ = "size"
				_bResult_ = This.CheckSize(_aToken_, aMatrix)
			
			but _cType_ = "shape"
				if HasKey(_aToken_, "value")
					_bResult_ = This.CheckShape(_aToken_["value"], aMatrix)
				ok
			
			but _cType_ = "element"
				_bResult_ = This.CheckElements(_aToken_, aMatrix)
			
			but _cType_ = "row"
				_bResult_ = This.CheckRows(_aToken_, aMatrix)
			
			but _cType_ = "col"
				_bResult_ = This.CheckCols(_aToken_, aMatrix)
			
			but _cType_ = "diagonal"
				_bResult_ = This.CheckDiagonal(_aToken_, aMatrix)
			
			but _cType_ = "property"
				if HasKey(_aToken_, "value")
					_bResult_ = This.CheckProperty(_aToken_["value"], aMatrix)
				ok
			
			but _cType_ = "pattern"
				if HasKey(_aToken_, "value")
					_bResult_ = This.CheckPattern(_aToken_["value"], aMatrix)
				ok
			
			but _cType_ = "determinant"
				_bResult_ = This.CheckDeterminant(_aToken_, aMatrix)
			
			but _cType_ = "sum"
				_bResult_ = This.CheckSum(_aToken_, aMatrix)
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
	
	  #------------------------#
	 #  CHECKING METHODS      #
	#------------------------#
	
	def CheckSize(_aToken_, aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		if HasKey(_aToken_, "value")
			_cValue_ = _aToken_["value"]
			
			if StzFindFirst(_cValue_, "x") > 0
				_aParts_ = @split(_cValue_, "x")
				if len(_aParts_) = 2
					_cRowSpec_ = trim(_aParts_[1])
					_cColSpec_ = trim(_aParts_[2])
					
					if This.IsNumeric(_cRowSpec_) and This.IsNumeric(_cColSpec_)
						return _nRows_ = (0 + _cRowSpec_) and _nCols_ = (0 + _cColSpec_)
					but _cRowSpec_ = "m" or _cRowSpec_ = "n"
						return TRUE  # Any size accepted
					ok
				ok
			ok
		ok
		
		if HasKey(_aToken_, "constraints")
			_nLenConstr_ = len(_aToken_["constraints"])
			for _i_ = 1 to _nLenConstr_
				_aConstraint_ = _aToken_["constraints"][_i_]
				
				if HasKey(_aConstraint_, "type")
					_cConstrType_ = _aConstraint_["type"]
					
					if _cConstrType_ = "dimensions"
						_cRowSpec_ = _aConstraint_["rows"]
						_cColSpec_ = _aConstraint_["cols"]
						
						if This.IsNumeric(_cRowSpec_) and This.IsNumeric(_cColSpec_)
							if _nRows_ != (0 + _cRowSpec_) or _nCols_ != (0 + _cColSpec_)
								return FALSE
							ok
						ok
					
					but _cConstrType_ = "greater"
						_nMin_ = _nRows_
						if _nCols_ < _nMin_
							_nMin_ = _nCols_
						ok
						if _nMin_ <= _aConstraint_["value"]
							return FALSE
						ok
					
					but _cConstrType_ = "less"
						_nMax_ = _nRows_
						if _nCols_ > _nMax_
							_nMax_ = _nCols_
						ok
						if _nMax_ >= _aConstraint_["value"]
							return FALSE
						ok
					ok
				ok
			next
		ok
		
		return TRUE
	
	def CheckShape(_cShape_, aMatrix)
		_cShape_ = StzLower(trim(_cShape_))
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		if _cShape_ = "square"
			return _nRows_ = _nCols_
		but _cShape_ = "rectangular" or _cShape_ = "rectangle"
			return _nRows_ != _nCols_
		but _cShape_ = "tall"
			return _nRows_ > _nCols_
		but _cShape_ = "wide"
			return _nCols_ > _nRows_
		but _cShape_ = "row" or _cShape_ = "rowvector"
			return _nRows_ = 1
		but _cShape_ = "column" or _cShape_ = "colvector"
			return _nCols_ = 1
		ok
		
		return FALSE
	
	def CheckElements(_aToken_, aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		if HasKey(_aToken_, "constraints")
			_nLenConstr_ = len(_aToken_["constraints"])
			for _i_ = 1 to _nLenConstr_
				_aConstraint_ = _aToken_["constraints"][_i_]
				
				if HasKey(_aConstraint_, "type")
					_cConstrType_ = _aConstraint_["type"]
					
					if _cConstrType_ = "range"
						_nStart_ = _aConstraint_["start"]
						_nEnd_ = _aConstraint_["end"]
						
						for r = 1 to _nRows_
							for c = 1 to _nCols_
								_nVal_ = aMatrix[r][c]
								if _nVal_ < _nStart_ or _nVal_ > _nEnd_
									return FALSE
								ok
							next
						next
					
					but _cConstrType_ = "set"
						_aValues_ = _aConstraint_["values"]
						for r = 1 to _nRows_
							for c = 1 to _nCols_
								_bFound_ = FALSE
								_nVal_ = aMatrix[r][c]
								_nLenValues_ = len(_aValues_)
								for k = 1 to _nLenValues_
									if _nVal_ = (0 + trim(_aValues_[k]))
										_bFound_ = TRUE
										exit
									ok
								next
								if not _bFound_
									return FALSE
								ok
							next
						next
					
					but _cConstrType_ = "exact"
						_nTarget_ = _aConstraint_["value"]
						for r = 1 to _nRows_
							for c = 1 to _nCols_
								if aMatrix[r][c] != _nTarget_
									return FALSE
								ok
							next
						next
					ok
				ok
			next
		ok
		
		return TRUE
	
	def CheckRows(_aToken_, aMatrix)
		# Check row-specific patterns
		return TRUE
	
	def CheckCols(_aToken_, aMatrix)
		# Check column-specific patterns
		return TRUE
	
	def CheckDiagonal(_aToken_, aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		if _nRows_ != _nCols_
			return FALSE  # Only square matrices have proper diagonals
		ok
		
		# Check main diagonal
		_nMin_ = _nRows_
		if _nCols_ < _nMin_
			_nMin_ = _nCols_
		ok
		
		return TRUE
	
	def CheckProperty(_cProperty_, aMatrix)
		_cProperty_ = StzLower(trim(_cProperty_))
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		if _cProperty_ = "symmetric"
			if _nRows_ != _nCols_
				return FALSE
			ok
			for _i_ = 1 to _nRows_
				for j = 1 to _nCols_
					if aMatrix[_i_][j] != aMatrix[j][_i_]
						return FALSE
					ok
				next
			next
			return TRUE
		
		but _cProperty_ = "diagonal"
			if _nRows_ != _nCols_
				return FALSE
			ok
			for _i_ = 1 to _nRows_
				for j = 1 to _nCols_
					if _i_ != j and aMatrix[_i_][j] != 0
						return FALSE
					ok
				next
			next
			return TRUE
		
		but _cProperty_ = "identity"
			if _nRows_ != _nCols_
				return FALSE
			ok
			for _i_ = 1 to _nRows_
				for j = 1 to _nCols_
					if _i_ = j
						if aMatrix[_i_][j] != 1
							return FALSE
						ok
					else
						if aMatrix[_i_][j] != 0
							return FALSE
						ok
					ok
				next
			next
			return TRUE
		
		but _cProperty_ = "zero"
			for _i_ = 1 to _nRows_
				for j = 1 to _nCols_
					if aMatrix[_i_][j] != 0
						return FALSE
					ok
				next
			next
			return TRUE
		
		but _cProperty_ = "upper" or _cProperty_ = "uppertriangular"
			if _nRows_ != _nCols_
				return FALSE
			ok
			for _i_ = 1 to _nRows_
				for j = 1 to _i_-1
					if aMatrix[_i_][j] != 0
						return FALSE
					ok
				next
			next
			return TRUE
		
		but _cProperty_ = "lower" or _cProperty_ = "lowertriangular"
			if _nRows_ != _nCols_
				return FALSE
			ok
			for _i_ = 1 to _nRows_
				for j = _i_+1 to _nCols_
					if aMatrix[_i_][j] != 0
						return FALSE
					ok
				next
			next
			return TRUE
		ok
		
		return FALSE
	
	def CheckPattern(_cPattern_, aMatrix)
		# Check for visual/structural patterns
		return TRUE
	
	def CheckDeterminant(_aToken_, aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		if _nRows_ != _nCols_
			return FALSE
		ok
		
		# Would call stzMatrix determinant method
		return TRUE
	
	def CheckSum(_aToken_, aMatrix)
		_nSum_ = 0
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		for _i_ = 1 to _nRows_
			for j = 1 to _nCols_
				_nSum_ += aMatrix[_i_][j]
			next
		next
		
		if HasKey(_aToken_, "constraints")
			# Check sum constraints
		ok
		
		return TRUE
	
	  #----------------------#
	 #  PART EXTRACTION     #
	#----------------------#
	
	def ExtractParts(aMatrix)
		@aMatchedParts = []
		
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		@aMatchedParts + ["Size", [_nRows_, _nCols_]]
		@aMatchedParts + ["Matrix", aMatrix]
		
		_aProps_ = []
		if _nRows_ = _nCols_
			_aProps_ + "Square"
			
			if This.IsSymmetric(aMatrix)
				_aProps_ + "Symmetric"
			ok
			if This.IsDiagonal(aMatrix)
				_aProps_ + "Diagonal"
			ok
			if This.IsIdentity(aMatrix)
				_aProps_ + "Identity"
			ok
		else
			_aProps_ + "Rectangular"
		ok
		
		@aMatchedParts + ["Properties", _aProps_]
	
	def IsSymmetric(aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		if _nRows_ != _nCols_
			return FALSE
		ok
		for _i_ = 1 to _nRows_
			for j = 1 to _nCols_
				if aMatrix[_i_][j] != aMatrix[j][_i_]
					return FALSE
				ok
			next
		next
		return TRUE
	
	def IsDiagonal(aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		if _nRows_ != _nCols_
			return FALSE
		ok
		for _i_ = 1 to _nRows_
			for j = 1 to _nCols_
				if _i_ != j and aMatrix[_i_][j] != 0
					return FALSE
				ok
			next
		next
		return TRUE
	
	def IsIdentity(aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		if _nRows_ != _nCols_
			return FALSE
		ok
		for _i_ = 1 to _nRows_
			for j = 1 to _nCols_
				if _i_ = j
					if aMatrix[_i_][j] != 1
						return FALSE
					ok
				else
					if aMatrix[_i_][j] != 0
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
		_aExplanation_ = [
			["Pattern", @cPattern],
			["TokenCount", len(@aTokens)],
			["Tokens", @aTokens]
		]
		
		if len(@aMatrix) > 0
			_aExplanation_ + ["Target", @aMatrix]
		ok
		
		if len(@aMatchedParts) > 0
			_aExplanation_ + ["MatchedParts", @aMatchedParts]
		ok
		
		return _aExplanation_
	
	  #---------------------------#
	 #  ADVANCED QUERY METHODS   #
	#---------------------------#
	
	def MatchingMatrices(paMatrices)
		if CheckParams() and isList(paMatrices) and len(paMatrices) = 2 and isString(paMatrices[1]) and StzLower(paMatrices[1]) = "in"
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of lists of numbers.")
		ok

		# Find all matrices in a list that match the pattern
		_aMatching_ = []
		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			if This.Match(paMatrices[_i_])
				_aMatching_ + paMatrices[_i_]
			ok
		next
		
		return _aMatching_
	
		def MatchingMatricesIn(paMatrices)
			return THis.MatchingMatrices(paMatrices)

	def FindMatchingMatrices(paMatrices)
		# Find all matrices in a list that match the pattern
		# and retyurning their positions in paMatrices

		if CheckParams() and isList(paMatrices) and len(paMatrices) = 2 and isString(paMatrices[1]) and StzLower(paMatrices[1]) = "in"
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of lists of numbers.")
		ok

		_anMatching_ = []
		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			if This.Match(paMatrices[_i_])
				_anMatching_ + _i_
			ok
		next
		
		return _anMatching_

		def FindMatchingMatricesIn(paMatrices)
			return This.FindMatchingMatrices(paMatrices)

	def CountMatchingMatrices(paMatrices)

		if CheckParams() and isList(paMatrices) and len(paMatrices) = 2 and isString(paMatrices[1]) and StzLower(paMatrices[1]) = "in"
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of matrices.")
		ok

		_nCount_ = 0
		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			if This.Match(paMatrices[_i_])
				_nCount_++
			ok
		next
		
		return _nCount_
	
		def CountMatchingMatricesIn(paMatrices)
			return This.CountMatchingMatrices(paMatrices)

	def FirstMatchingMatrix(paMatrices)

		if CheckParams() and isList(paMatrices) and len(paMatrices) = 2 and isString(paMatrices[1]) and StzLower(paMatrices[1]) = "in"
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of matrices.")
		ok

		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			if This.Match(paMatrices[_i_])
				return paMatrices[_i_]
			ok
		next
		
		StzRaise("Can't proceed! paMatrices contains no matching matrices.")

		def FirstMatchingMatrixIn(paMatrices)
			return This.FirstMatchingMatrix(paMatrices)

	def FindFirstMatchingMatrix(paMatrices)

		if CheckParams() and isList(paMatrices) and len(paMatrices) = 2 and isString(paMatrices[1]) and StzLower(paMatrices[1]) = "in"
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of matrices.")
		ok

		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			if This.Match(paMatrices[_i_])
				return _i_
			ok
		next
		
		StzRaise("Can't proceed! paMatrices contains no matching matrices.")

		def FindFirstMatchingMatrixIn(paMatrices)
			return This.FindFirstMatchingMatrix(paMatrices)

	def MatchesNone(paMatrices)

		if CheckParams() and isList(paMatrices) and len(paMatrices) = 2 and isString(paMatrices[1]) and StzLower(paMatrices[1]) = "in"
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of matrices.")
		ok

		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			if This.Match(paMatrices[_i_])
				return TRUE
			ok
		next
		
		return FALSE
	
		def MatchesNoneIn(paMatrices)
			return This.MatchesNone(paMatrices)

	def MatchesAll(paMatrices)

		if CheckParams() and isList(paMatrices) and len(paMatrices) = 2 and isString(paMatrices[1]) and StzLower(paMatrices[1]) = "in"
			paMatrices = paMatrices[2]
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a list of lists of numbers.")
		ok

		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			if not This.Match(paMatrices[_i_])
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
		_cInner_ = This._Mid(@cPattern, 2, len(@cPattern) - 1)
		if len(_cInner_) > 0
			_cInner_ += " -> " + cConstraint
		else
			_cInner_ = cConstraint
		ok
		@cPattern = "{" + _cInner_ + "}"
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
			if isList(aMatrix1) and len(aMatrix1) = 2 and isString(aMatrix1[1]) and StzLower(aMatrix1[1]) = "between"
				_aMatix1_ = aMatrix1[2]
			ok
			if isList(aMatrix1) and len(aMatrix1) = 2 and isString(aMatrix1[1]) and StzLower(aMatrix1[1]) = "and"
				_aMatix1_ = aMatrix1[2]
			ok
		ok

		if NOT (IsMatrix(aMatrix1) and IsMatrix(aMatrix2))
			StzRaise("Incorrect param types! aMatrix1 and aMatrix2 must be both matrices.")
		ok

		# Calculate similarity between two matrices (0-1 scale)
		
		_nRows1_ = len(aMatrix1)
		_nCols1_ = len(aMatrix1[1])
		_nRows2_ = len(aMatrix2)
		_nCols2_ = len(aMatrix2[1])
		
		# Different sizes = low similarity
		if _nRows1_ != _nRows2_ or _nCols1_ != _nCols2_
			return 0.0
		ok
		
		# Calculate element-wise similarity
		_nMatches_ = 0
		_nTotal_ = _nRows1_ * _nCols1_
		
		for _i_ = 1 to _nRows1_
			for j = 1 to _nCols1_
				if aMatrix1[_i_][j] = aMatrix2[_i_][j]
					_nMatches_++
				ok
			next
		next
		
		return (_nMatches_ * 1.0) / _nTotal_
	
		def SimilarityScoreBetween(aMatrix1, aMatrix2)
			return This.SimilarityScore(aMatrix1, aMatrix2)

	def MostSimilarMatrix(_aTargetMatrix_, paMatrices)
		# Get the matrix in the list most similar to target
		
		if CheckParams()
			if isList(_aTargetMatrix_) and len(_aTargetMatrix_) = 2 and isString(_aTargetMatrix_[1]) and StzLower(_aTargetMatrix_[1]) = "to"
				_aTargetMatrix_ = _aTargetMatrix_[2]
			ok
			if isList(paMatrices) and len(paMatrices) = 2 and isString(paMatrices[1]) and StzLower(paMatrices[1]) = "in"
				paMatrices = paMatrices[2]
			ok
		ok

		if NOT IsMatrix(_aTargetMatrix_)
			StzRaise("Incorrect param type! aTargetMatrix must be a mtrix.")
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a listy of matrices.")
		ok

		_nBestScore_ = -1
		_aBestMatrix_ = []
		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			_nScore_ = This.SimilarityScore(_aTargetMatrix_, paMatrices[_i_])
			if _nScore_ > _nBestScore_
				_nBestScore_ = _nScore_
				_aBestMatrix_ = paMatrices[_i_]
			ok
		next
		
		if len(_aBestMatrix_) = 0
			StzRaise("No simular matrix found!")
		ok

		return _aBestMatrix_
	
	def FindMostSimilarMatrix(_aTargetMatrix_, paMatrices)
		# Find the matrix in the list most similar to target
		# and return its position in paMatrices
		
		if CheckParams()
			if isList(_aTargetMatrix_) and len(_aTargetMatrix_) = 2 and isString(_aTargetMatrix_[1]) and StzLower(_aTargetMatrix_[1]) = "to"
				_aTargetMatrix_ = _aTargetMatrix_[2]
			ok
			if isList(paMatrices) and len(paMatrices) = 2 and isString(paMatrices[1]) and StzLower(paMatrices[1]) = "in"
				paMatrices = paMatrices[2]
			ok
		ok

		if NOT IsMatrix(_aTargetMatrix_)
			StzRaise("Incorrect param type! aTargetMatrix must be a mtrix.")
		ok

		if NOT IsListOfMatrices(paMatrices)
			StzRaise("Incorrect param type! paMatrices must be a listy of matrices.")
		ok

		_nBestScore_ = -1
		_nBestMatrix_ = 0
		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			_nScore_ = This.SimilarityScore(_aTargetMatrix_, paMatrices[_i_])
			if _nScore_ > _nBestScore_
				_nBestScore_ = _nScore_
				_nBestMatrix_ = _i_
			ok
		next
		
		return _nBestMatrix_

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
		
		_aAnalysis_ = []
		_aMatching_ = []
		_aNonMatching_ = []
		
		_nLen_ = len(paMatrices)
		
		for _i_ = 1 to _nLen_
			if This.Match(paMatrices[_i_])
				_aMatching_ + paMatrices[_i_]
			else
				_aNonMatching_ + paMatrices[_i_]
			ok
		next
		
		_aAnalysis_ + ["pattern", @cPattern]
		_aAnalysis_ + ["totalmatrices", _nLen_]
		_aAnalysis_ + ["matchingcount", len(_aMatching_)]
		_aAnalysis_ + ["nonmatchingcount", len(_aNonMatching_)]
		_aAnalysis_ + ["matchrate", (len(_aMatching_) * 1.0) / _nLen_]
		_aAnalysis_ + ["matching", _aMatching_]
		_aAnalysis_ + ["nonmatching", _aNonMatching_]
		
		return _aAnalysis_
	
	def CommonProperties(paMatrices)
		# Find properties common to all matching matrices
		
		_aCommon_ = []
		_aAllProps_ = ["square", "symmetric", "diagonal", "identity", 
		             "zero", "upper", "lower"]
		
		_nLenProps_ = len(_aAllProps_)
		
		for _i_ = 1 to _nLenProps_
			_cProp_ = _aAllProps_[_i_]
			_bAll_ = TRUE
			
			_nLen_ = len(paMatrices)
			for j = 1 to _nLen_
				if This.Match(paMatrices[j])
					if not This.CheckProperty(_cProp_, paMatrices[j])
						_bAll_ = FALSE
						exit
					ok
				ok
			next
			
			if _bAll_
				_aCommon_ + _cProp_
			ok
		next
		
		return _aCommon_
	
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
		
		_nLen_ = len(cStr)
		for _i_ = 1 to _nLen_
			_cChar_ = This._Mid(cStr, _i_, _i_)
			if not isDigit(_cChar_) and _cChar_ != "-" and _cChar_ != "."
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
		_cCombined_ = "{" + 
		            This._Mid(@cPattern, 2, len(@cPattern) - 1) + 
		            " & " + 
		            This._Mid(oOtherMatrex.Pattern(), 2, len(oOtherMatrex.Pattern()) - 1) +
		            "}"

		return new stzMatrex(_cCombined_)
	
		def Andd(oOtherMatrex)
			return THis.And_(oOtherMatriex)

	def Or_(oOtherMatrex)
		if CheckParams() and NOT IsStzMatrex(oOtherMatrex)
			StzRaise("Incorrect param! oOtherMatrex must be a stzMatrex object (matrEx not matrIx).")
		ok

		# Combine two patterns with OR logic
		_cCombined_ = "{" + 
		            This._Mid(@cPattern, 2, len(@cPattern) - 1) + 
		            " | " + 
		            This._Mid(oOtherMatrex.Pattern(), 2, len(oOtherMatrex.Pattern()) - 1) +
		            "}"

		return new stzMatrex(_cCombined_)
	
	def Not_()
		# Negate the entire pattern
		_cInner_ = This._Mid(@cPattern, 2, len(@cPattern) - 1)
		_cNegated_ = "{@!" + _cInner_ + "}"
		return new stzMatrex(_cNegated_)
	
	
	  #-------------------------------#
	 #  SERIALIZATION                #
	#-------------------------------#
	
	def ToJSON()
		# Convert pattern to JSON representation
		_cJSON_ = '{'
		_cJSON_ += '"pattern":"' + @cPattern + '",'
		_cJSON_ += '"tokens":' + This.TokensToJSON()
		_cJSON_ += '}'
		return _cJSON_
	
	def TokensToJSON()
		# Convert tokens to JSON array
		_cJSON_ = '['
		_nLen_ = len(@aTokens)
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cJSON_ += ','
			ok
			_cJSON_ += This.TokenToJSON(@aTokens[_i_])
		next
		_cJSON_ += ']'
		return _cJSON_
	
	def TokenToJSON(_aToken_)
		# Convert single token to JSON
		_cJSON_ = '{'
		_nLen_ = len(_aToken_)
		for _i_ = 1 to _nLen_ step 2
			if _i_ > 1
				_cJSON_ += ','
			ok
			_cJSON_ += '"' + _aToken_[_i_] + '":"' + _aToken_[_i_+1] + '"'
		next
		_cJSON_ += '}'
		return _cJSON_
