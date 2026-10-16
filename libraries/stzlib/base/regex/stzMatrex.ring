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

# Tests whether a matrix of numbers fits a pattern written in a small regex-like language, such as {size(3x3) & property(symmetric)}.
#
# A pattern is text in braces made of terms: size, shape, element, property, row, col, diagonal,
# pattern, determinant and sum, written like size(3x3) or element(0..10). Terms are joined by & (all
# must hold), | (one must hold) and -> (a sequence, all must hold), @! negates a term or a whole
# parenthesised group such as @!(size(2x2) & property(symmetric)), and parentheses group. A size is
# rows x cols, each a number or m or n for any count (3xn, mxn), or >n or <n for both dimensions.
# Match tests one matrix and, on success, records its size, properties and matrix as the matched
# parts; MatchingMatrices, CountMatchingMatrices and the other list methods test a whole list.
# SimilarityScore, MostSimilarMatrix and CommonProperties compare matrices, and ToJSON writes the
# pattern and its tokens as JSON. Known gaps, each carried as a warning on its method: the terms row,
# col, pattern, determinant and sum accept every matrix and diagonal every square one, because no
# text or test says what they should check and nothing is invented for them, quantifiers are parsed
# but never applied, and MatchesNone answers TRUE when at least one matrix matches, which the test
# 27_check_if_matches_any expects.
#
#   receiver   o1 = new stzMatrex("{size(2x2) & property(symmetric)}")
#   example    ? o1.Match([ [1,2], [2,1] ])
#              #--> 1
#   see        stzMatrix, stzRegex, stzTablex
class stzMatrex from stzObject
	
	@cPattern           # Pattern string
	@aTokens            # Parsed token definitions
	@aMatrix = []       # Target matrix to match
	@bDebugMode = 0 # Debug flag
	@aMatchedParts = [] # Extracted parts
	
	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#
	
	# Builds a matrix pattern from text such as {size(3x3) & property(symmetric)} and parses it into tokens; a non-text value raises an error.
	#
	#   returns    nothing; the object is built
	#   note       the braces are added when missing and an empty pattern is allowed; a word it does
	#              not know becomes an ERROR token instead of raising
	#   see        Match, Pattern, Tokens
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

	# Trims the pattern text and wraps it in braces when it has none.
	#
	#   _cPattern_   the pattern text, with or without braces
	#   returns      the pattern text, with braces
	#   see          Pattern, ParsePattern
	def NormalizePattern(_cPattern_)
		_cPattern_ = trim(_cPattern_)
		if NOT (startsWith(_cPattern_, "{") and endsWith(_cPattern_, "}"))
			_cPattern_ = "{" + _cPattern_ + "}"
		ok
		return _cPattern_
	
	  #--------------------#
	 #  PATTERN PARSING   #
	#--------------------#
	
# Splits a braced pattern at its top-level -> into parts and parses each part into a token.
#
#   _cPattern_   the pattern text, with its braces
#   returns      a list of tokens, each a list of [ key, value ] pairs
#   note         init calls it; a part holding a vertical bar becomes an alternation, one holding &
#                a conjunction
#   see          Tokens, ParseSingleToken, ParseAlternation, ParseConjunction
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
		
		if StzFindFirst("|", _cPart_) > 0
			if @bDebugMode
				? ">>> Detected alternation"
			ok
			_aToken_ = This.ParseAlternation(_cPart_)
		but StzFindFirst("&", _cPart_) > 0
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
	
	# Splits text at an operator and trims each part, ignoring any operator inside parentheses or braces.
	#
	#   cStr        the text to split
	#   cOperator   the operator, such as "->"
	#   returns     a list of text
	#   note        "a->b->(c->d)" gives "a", "b" and "(c->d)"
	#   see         ParsePattern
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
	
	# Parses a part whose terms are joined by a vertical bar into an alternation token that lists the alternatives.
	#
	#   _cTokenStr_   the text of the part, with or without outer parentheses
	#   returns       a token: [ type, alternation ], [ alternatives, a list of tokens ] and [
	#                 negated, 0 ]
	#   see           ParseConjunction, ParseSingleToken
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
	
# Parses a part whose terms are joined by & into a conjunction token that lists the conditions.
#
#   _cTokenStr_   the text of the part, with or without outer parentheses
#   returns       a token: [ type, conjunction ], [ conditions, a list of tokens ] and [ negated, 0
#                 ]
#   see           ParseAlternation, ParseSingleToken
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
	
	# Parses one term such as size(3x3), shape(square)* or @!property(zero) into a token with its type, value, constraints, min, max and negated.
	#
	#   _cTokenStr_   the text of one term
	#   returns       a token as a list of [ key, value ] pairs; [ ] for empty text; an ERROR token
	#                 for a term it does not know
	#   note          the quantifiers + * ? and n-m fill min and max, but Match never reads them; @!
	#                 sets negated, and the type is checked after it, so @!zero is an ERROR token; a
	#                 whole parenthesised group, such as @!(size(2x2) | shape(tall)), gives a group
	#                 token: [ type, group ], [ tokens, the parsed inner pattern ] and [ negated, 0 or 1 ]
	#   see           ParseConstraints, ParsePattern
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
		
		# A whole parenthesised group, negated or not, becomes one group token
		_cTokenStr_ = trim(_cTokenStr_)
		if This._IsWholeGroup(_cTokenStr_)
			_cInnerGroup_ = trim(This._Mid(_cTokenStr_, 2, ring_len(_cTokenStr_) - 1))
			return [
				["type", "group"],
				["tokens", This.ParsePattern("{" + _cInnerGroup_ + "}")],
				["negated", _bNegated_]
			]
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
			if StzFindFirst(":", _cQuantPart_) > 0
				_nColon_ = StzFindFirst(":", _cQuantPart_)
				_cBeforeColon_ = This._Mid(_cQuantPart_, 1, _nColon_ - 1)
				_cAfterColon_ = This._Mid(_cQuantPart_, _nColon_ + 1, len(_cQuantPart_))
				
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
	
	# TRUE if the whole text is one parenthesised group, so the first ( closes at the last ).
	#
	#   cStr       the text to test, already trimmed
	#   returns    TRUE or FALSE (1 or 0)
	#   note       (a) | (b) is not one group and (a | (b)) is
	#   see        ParseSingleToken
	def _IsWholeGroup(cStr)
		_nLen_ = ring_len(cStr)
		if _nLen_ < 2
			return 0
		ok
		if cStr[1] != "("
			return 0
		ok
		if cStr[_nLen_] != ")"
			return 0
		ok
		_nDepth_ = 0
		for _i_ = 1 to _nLen_
			if cStr[_i_] = "("
				_nDepth_++
			but cStr[_i_] = ")"
				_nDepth_--
				if _nDepth_ = 0 and _i_ < _nLen_
					return 0
				ok
			ok
		next
		if _nDepth_ = 0
			return 1
		ok
		return 0

	# Reads the text inside a term's parentheses into constraints: a range 1..5, a set {1;2} or one value for element; 3x3, >4 or <4 for size.
	#
	#   cConstraintStr   the text to read
	#   _cType_          the term type, element or size
	#   returns          a list of constraints; [ ] for empty text or any other type
	#   see              ParseSingleToken
	def ParseConstraints(cConstraintStr, _cType_)
		_aConstraints_ = []
		
		if cConstraintStr = ""
			return _aConstraints_
		ok
		
		if _cType_ = "element"
			if StzFindFirst("..", cConstraintStr) > 0
				_aParts_ = @split(cConstraintStr, "..")
				if len(_aParts_) = 2
					_aConstraints_ + [
						["type", "range"],
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
			but This.IsNumeric(cConstraintStr)
				_aConstraints_ + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
			ok
		
		but _cType_ = "size"
			# Handle size constraints like "3x3", "mxn", ">4"
			if StzFindFirst("x", cConstraintStr) > 0
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
	
	# TRUE if the matrix satisfies every term of the pattern; a success also records its size, properties and matrix as the matched parts.
	#
	#   paMatrix   the matrix to test, a list of rows of numbers, all of the same length
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a non-matrix or an empty list raises an error; a failed match leaves the earlier
	#              matched parts as they were
	#   warning    the terms row, col, pattern, determinant and sum accept every matrix and diagonal
	#              every square one, because nothing says what they should check; quantifiers are
	#              parsed and never applied; and a part that mixes | and & with a group inside, such as
	#              (size(2x2) | size(3x3)) & property(diagonal), is cut at its first operator, so a
	#              term can be dropped without any message
	#   see        MatchedParts, MatchingMatrices, Explain
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
	
	# TRUE if the matrix satisfies every token of the list, an alternation needing one alternative and a conjunction all of its conditions.
	#
	#   _aTokens_   the parsed tokens
	#   aMatrix     the matrix to test
	#   returns     TRUE or FALSE (1 or 0)
	#   see         Match, MatchSingleToken
	def MatchTokens(_aTokens_, aMatrix)
		_nLenTokens_ = len(_aTokens_)
		for _i_ = 1 to _nLenTokens_
			_aToken_ = _aTokens_[_i_]
			
			if HasKey(_aToken_, "type") and _aToken_["type"] = "alternation"
				_bMatched_ = 0
				if HasKey(_aToken_, "alternatives")
					_nLenAlt_ = len(_aToken_["alternatives"])
					for j = 1 to _nLenAlt_
						if This.MatchSingleToken(_aToken_["alternatives"][j], aMatrix)
							_bMatched_ = 1
							exit
						ok
					next
				ok
				if not _bMatched_
					return 0
				ok
			
			but HasKey(_aToken_, "type") and _aToken_["type"] = "conjunction"
				if HasKey(_aToken_, "conditions")
					_nLenCond_ = len(_aToken_["conditions"])
					for j = 1 to _nLenCond_
						if not This.MatchSingleToken(_aToken_["conditions"][j], aMatrix)
							return 0
						ok
					next
				ok
			
			else
				if not This.MatchSingleToken(_aToken_, aMatrix)
					return 0
				ok
			ok
		next
		
		return 1
	
	# TRUE if the matrix satisfies one token, after applying the token's negation.
	#
	#   _aToken_   one parsed token
	#   aMatrix    the matrix to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a group token is tested through MatchTokens on its inner tokens
	#   see        MatchTokens, CheckSize, CheckProperty
	def MatchSingleToken(_aToken_, aMatrix)
		_bResult_ = 0
		
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

			but _cType_ = "group"
				if HasKey(_aToken_, "tokens")
					_bResult_ = This.MatchTokens(_aToken_["tokens"], aMatrix)
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
	
	  #------------------------#
	 #  CHECKING METHODS      #
	#------------------------#
	
	# TRUE if the matrix has the size a token states: rows x cols with a number or m or n for any count, or >n or <n for both.
	#
	#   _aToken_   a size token
	#   aMatrix    the matrix to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       3x3 needs 3 rows and 3 columns, 3xn needs 3 rows and any columns, mxn accepts every
	#              matrix; >n needs both dimensions strictly above n and <n both strictly below n
	#   warning    m and n are two independent wildcards, so nxn does not need a square; a size text of
	#              any other form, such as 3 or abc, is not satisfied, and an empty size() is
	#   see        CheckShape, Match
	def CheckSize(_aToken_, aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])

		if HasKey(_aToken_, "value")
			_cValue_ = StzLower(trim(_aToken_["value"]))
			if _cValue_ != ""
				if NOT This._SizeTextHolds(_cValue_, _nRows_, _nCols_)
					return 0
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
								return 0
							ok
						ok

					but _cConstrType_ = "greater"
						_nMin_ = _nRows_
						if _nCols_ < _nMin_
							_nMin_ = _nCols_
						ok
						if _nMin_ <= _aConstraint_["value"]
							return 0
						ok

					but _cConstrType_ = "less"
						_nMax_ = _nRows_
						if _nCols_ > _nMax_
							_nMax_ = _nCols_
						ok
						if _nMax_ >= _aConstraint_["value"]
							return 0
						ok
					ok
				ok
			next
		ok

		return 1

	# TRUE if a size text such as 3x3, 3xn, mxn, >2 or <4 holds for a matrix of the given dimensions.
	#
	#   cValue     the size text, lowercase and trimmed
	#   nRows      the number of rows of the matrix
	#   nCols      the number of columns of the matrix
	#   returns    TRUE or FALSE (1 or 0); FALSE for a text of any other form
	#   note       > needs both dimensions strictly above the number and < both strictly below it
	#   see        CheckSize, _SizeDimensionHolds
	def _SizeTextHolds(cValue, nRows, nCols)
		_cFirst_ = cValue[1]
		if _cFirst_ = ">" or _cFirst_ = "<"
			_cNumber_ = trim(This._Mid(cValue, 2, ring_len(cValue)))
			if NOT This.IsNumeric(_cNumber_)
				return 0
			ok
			_nLimit_ = 0 + _cNumber_
			_nLow_ = nRows
			_nHigh_ = nRows
			if nCols < _nLow_
				_nLow_ = nCols
			ok
			if nCols > _nHigh_
				_nHigh_ = nCols
			ok
			if _cFirst_ = ">"
				return _nLow_ > _nLimit_
			ok
			return _nHigh_ < _nLimit_
		ok

		if StzFindFirst("x", cValue) > 0
			_aParts_ = @split(cValue, "x")
			if ring_len(_aParts_) != 2
				return 0
			ok
			if NOT This._SizeDimensionHolds(trim(_aParts_[1]), nRows)
				return 0
			ok
			return This._SizeDimensionHolds(trim(_aParts_[2]), nCols)
		ok

		return 0

	# TRUE if one side of a size, a number or m or n, holds for a count of rows or columns.
	#
	#   cSpec      the side of the size, such as 3, m or n
	#   nCount     the number of rows or of columns
	#   returns    TRUE or FALSE (1 or 0); m and n accept any count, a number must equal it
	#   see        _SizeTextHolds
	def _SizeDimensionHolds(cSpec, nCount)
		if cSpec = "m" or cSpec = "n"
			return 1
		ok
		if This.IsNumeric(cSpec)
			if nCount = (0 + cSpec)
				return 1
			ok
		ok
		return 0

	# TRUE if the matrix has the named shape: square, rectangular (not square), tall, wide, row or column; any other name gives FALSE.
	#
	#   _cShape_   the shape name
	#   aMatrix    the matrix to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       rowvector and colvector are accepted for row and column
	#   see        CheckSize, CheckProperty
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
		
		return 0
	
	# TRUE if every element of the matrix satisfies the element constraints of the token: a range, a set or one exact value.
	#
	#   _aToken_   an element token
	#   aMatrix    the matrix to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckProperty, Match
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
									return 0
								ok
							next
						next
					
					but _cConstrType_ = "set"
						_aValues_ = _aConstraint_["values"]
						for r = 1 to _nRows_
							for c = 1 to _nCols_
								_bFound_ = 0
								_nVal_ = aMatrix[r][c]
								_nLenValues_ = len(_aValues_)
								for k = 1 to _nLenValues_
									if _nVal_ = (0 + trim(_aValues_[k]))
										_bFound_ = 1
										exit
									ok
								next
								if not _bFound_
									return 0
								ok
							next
						next
					
					but _cConstrType_ = "exact"
						_nTarget_ = _aConstraint_["value"]
						for r = 1 to _nRows_
							for c = 1 to _nCols_
								if aMatrix[r][c] != _nTarget_
									return 0
								ok
							next
						next
					ok
				ok
			next
		ok
		
		return 1
	
	# Accepts every matrix, because no text states what a row term should check.
	#
	#   _aToken_   a row token
	#   aMatrix    the matrix to test
	#   returns    TRUE, always
	#   warning    stub kept on purpose: the body is return 1, so a row term never rejects a matrix;
	#              the syntax and the meaning of a row term are missing from the header, the
	#              blocks and the tests, and nothing was invented for them
	#   see        CheckCols
	def CheckRows(_aToken_, aMatrix)
		# Check row-specific patterns
		return 1
	
	# Accepts every matrix, because no text states what a col term should check.
	#
	#   _aToken_   a token of type col
	#   aMatrix    the matrix to test
	#   returns    TRUE, always
	#   warning    stub kept on purpose: the body is return 1, so a col term never rejects a matrix;
	#              the syntax and the meaning of a col term are missing from the header, the
	#              blocks and the tests, and nothing was invented for them
	#   see        CheckRows
	def CheckCols(_aToken_, aMatrix)
		# Check column-specific patterns
		return 1
	
	# TRUE if the matrix is square; the values that a diagonal term states are not tested.
	#
	#   _aToken_   a diagonal token
	#   aMatrix    the matrix to test
	#   returns    TRUE or FALSE (1 or 0)
	#   warning    stub kept on purpose: it only tests squareness, so diagonal(1) accepts any square
	#              matrix; the syntax and the meaning of a diagonal term are missing from the
	#              header, the blocks and the tests, and the parser keeps no value for it
	#   see        CheckProperty
	def CheckDiagonal(_aToken_, aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		if _nRows_ != _nCols_
			return 0  # Only square matrices have proper diagonals
		ok
		
		# Check main diagonal
		_nMin_ = _nRows_
		if _nCols_ < _nMin_
			_nMin_ = _nCols_
		ok
		
		return 1
	
	# TRUE if the matrix has the named property: square, symmetric, diagonal, identity, zero, upper or lower.
	#
	#   _cProperty_   the property name, upper and lower also as uppertriangular and lowertriangular
	#   aMatrix       the matrix to test
	#   returns       TRUE or FALSE (1 or 0); FALSE for any other name
	#   see           CheckShape, IsSymmetric, IsDiagonal, IsIdentity
	def CheckProperty(_cProperty_, aMatrix)
		_cProperty_ = StzLower(trim(_cProperty_))
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		if _cProperty_ = "square"
			return _nRows_ = _nCols_

		but _cProperty_ = "symmetric"
			if _nRows_ != _nCols_
				return 0
			ok
			for _i_ = 1 to _nRows_
				for j = 1 to _nCols_
					if aMatrix[_i_][j] != aMatrix[j][_i_]
						return 0
					ok
				next
			next
			return 1
		
		but _cProperty_ = "diagonal"
			if _nRows_ != _nCols_
				return 0
			ok
			for _i_ = 1 to _nRows_
				for j = 1 to _nCols_
					if _i_ != j and aMatrix[_i_][j] != 0
						return 0
					ok
				next
			next
			return 1
		
		but _cProperty_ = "identity"
			if _nRows_ != _nCols_
				return 0
			ok
			for _i_ = 1 to _nRows_
				for j = 1 to _nCols_
					if _i_ = j
						if aMatrix[_i_][j] != 1
							return 0
						ok
					else
						if aMatrix[_i_][j] != 0
							return 0
						ok
					ok
				next
			next
			return 1
		
		but _cProperty_ = "zero"
			for _i_ = 1 to _nRows_
				for j = 1 to _nCols_
					if aMatrix[_i_][j] != 0
						return 0
					ok
				next
			next
			return 1
		
		but _cProperty_ = "upper" or _cProperty_ = "uppertriangular"
			if _nRows_ != _nCols_
				return 0
			ok
			for _i_ = 1 to _nRows_
				for j = 1 to _i_-1
					if aMatrix[_i_][j] != 0
						return 0
					ok
				next
			next
			return 1
		
		but _cProperty_ = "lower" or _cProperty_ = "lowertriangular"
			if _nRows_ != _nCols_
				return 0
			ok
			for _i_ = 1 to _nRows_
				for j = _i_+1 to _nCols_
					if aMatrix[_i_][j] != 0
						return 0
					ok
				next
			next
			return 1
		ok
		
		return 0
	
	# Accepts every matrix, because no text names the patterns a pattern term could check.
	#
	#   _cPattern_   the pattern name
	#   aMatrix      the matrix to test
	#   returns      TRUE, always
	#   warning      stub kept on purpose: the body is return 1; the names of the patterns and their
	#                meaning are missing from the header, the blocks and the tests
	#   see          Match
	def CheckPattern(_cPattern_, aMatrix)
		# Check for visual/structural patterns
		return 1
	
	# TRUE if the matrix is square; the determinant value that a term states is not tested.
	#
	#   _aToken_   a determinant token
	#   aMatrix    the matrix to test
	#   returns    TRUE or FALSE (1 or 0)
	#   warning    stub kept on purpose: it only tests squareness, so determinant(5) accepts a square
	#              matrix whose determinant is -3; whether determinant(5) means equal to 5 and which
	#              comparisons exist is not stated anywhere, and the parser keeps no value for it
	#   see        Match
	def CheckDeterminant(_aToken_, aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		
		if _nRows_ != _nCols_
			return 0
		ok
		
		# Would call stzMatrix determinant method
		return 1
	
	# Accepts every matrix: the sum of its elements is added up and then ignored.
	#
	#   _aToken_   a sum token
	#   aMatrix    the matrix to test
	#   returns    TRUE, always
	#   warning    stub kept on purpose: the body is return 1 after the sum is computed; whether
	#              sum(45) means equal to 45 and which comparisons exist is not stated anywhere, and
	#              the parser keeps no value for it
	#   see        Match
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
		
		return 1
	
	  #----------------------#
	 #  PART EXTRACTION     #
	#----------------------#
	
	# Records the size, the matrix and the properties of a matrix as the matched parts of this object.
	#
	#   aMatrix    the matrix to describe
	#   returns    nothing; the matched parts change
	#   note       the properties are Square, with Symmetric, Diagonal and Identity when they hold,
	#              or Rectangular
	#   see        MatchedParts, Size, Properties
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
	
	# TRUE if the matrix is square and equal to its transpose.
	#
	#   aMatrix    the matrix to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       an empty list raises error R2
	#   see        IsDiagonal, IsIdentity, CheckProperty
	def IsSymmetric(aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		if _nRows_ != _nCols_
			return 0
		ok
		for _i_ = 1 to _nRows_
			for j = 1 to _nCols_
				if aMatrix[_i_][j] != aMatrix[j][_i_]
					return 0
				ok
			next
		next
		return 1
	
	# TRUE if the matrix is square and every element off the main diagonal is 0.
	#
	#   aMatrix    the matrix to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        IsSymmetric, IsIdentity, CheckProperty
	def IsDiagonal(aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		if _nRows_ != _nCols_
			return 0
		ok
		for _i_ = 1 to _nRows_
			for j = 1 to _nCols_
				if _i_ != j and aMatrix[_i_][j] != 0
					return 0
				ok
			next
		next
		return 1
	
	# TRUE if the matrix is square with 1 on the main diagonal and 0 everywhere else.
	#
	#   aMatrix    the matrix to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        IsDiagonal, IsSymmetric, CheckProperty
	def IsIdentity(aMatrix)
		_nRows_ = len(aMatrix)
		_nCols_ = len(aMatrix[1])
		if _nRows_ != _nCols_
			return 0
		ok
		for _i_ = 1 to _nRows_
			for j = 1 to _nCols_
				if _i_ = j
					if aMatrix[_i_][j] != 1
						return 0
					ok
				else
					if aMatrix[_i_][j] != 0
						return 0
					ok
				ok
			next
		next
		return 1
	
	  #----------------------#
	 #  QUERY METHODS       #
	#----------------------#
	
	# Returns what the last successful match recorded: the pairs Size, Matrix and Properties.
	#
	#   returns    a list of [ name, value ] pairs; [ ] before any success
	#   see        Size, Matrix, Properties, Explain
	def MatchedParts()
		return @aMatchedParts
	
	# Returns the size of the last matched matrix as [ rows, columns ]; [ 0, 0 ] before a successful match.
	#
	#   returns    a list of two numbers
	#   see        Matrix, Properties
	def Size()
		if HasKey(@aMatchedParts, "Size")
			return @aMatchedParts["Size"]
		ok
		return [0, 0]
	
	# Returns the properties of the last matched matrix: Square, Symmetric, Diagonal, Identity, or Rectangular.
	#
	#   returns    a list of text; [ ] before a successful match
	#   see        Size, IsSymmetric
	def Properties()
		if HasKey(@aMatchedParts, "Properties")
			return @aMatchedParts["Properties"]
		ok
		return []
	
	# Returns the last matrix that matched; [ ] before a successful match.
	#
	#   returns    a list of rows; [ ] before any success
	#   note       SetTarget does not change this answer
	#   see        Size, SetTarget
	def Matrix()
		if HasKey(@aMatchedParts, "Matrix")
			return @aMatchedParts["Matrix"]
		ok
		return []
	
	# Returns the parsed tokens of the pattern, one per part joined by ->.
	#
	#   returns    a list of tokens, each a list of [ key, value ] pairs
	#   see        Pattern, ParsePattern
	def Tokens()
		return @aTokens
	
	# Returns the pattern text with its braces.
	#
	#   returns    text
	#   see        Tokens, NormalizePattern
	def Pattern()
		return @cPattern
	
	# Stores a matrix as the target to show in Explain, without matching it.
	#
	#   paMatrix   the matrix to keep as target
	#   returns    nothing; the object changes
	#   note       Matrix and Size are not changed by it
	#   warning    the value is not checked: a non-matrix is stored, and Explain then raises "Bad
	#              parameter type!"
	#   see        Match, Explain
	def SetTarget(paMatrix)
		@aMatrix = paMatrix
	
	# Returns the pattern, its token count and tokens, plus the target and the matched parts when there are some.
	#
	#   returns    a list of [ name, value ] pairs
	#   see        Tokens, MatchedParts
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
	
	# Returns the matrices of a list that match the pattern, in their order.
	#
	#   paMatrices   a list of matrices, or [ "in", list ]
	#   returns      a list of matrices; [ ] when none match
	#   note         each tested matrix becomes the target, so the last matching one stays in the
	#                matched parts
	#   see          FindMatchingMatrices, CountMatchingMatrices, Match
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

	# Returns the positions in a list of the matrices that match the pattern.
	#
	#   paMatrices   a list of matrices, or [ "in", list ]
	#   returns      a list of numbers; [ ] when none match
	#   see          MatchingMatrices, FindFirstMatchingMatrix
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

	# Returns how many matrices of a list match the pattern.
	#
	#   paMatrices   a list of matrices, or [ "in", list ]
	#   returns      a number
	#   see          MatchingMatrices, MatchesAll
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

	# Returns the first matrix of a list that matches the pattern; raises an error when none does.
	#
	#   paMatrices   a list of matrices, or [ "in", list ]
	#   returns      a matrix
	#   see          FindFirstMatchingMatrix, MatchingMatrices
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

	# Returns the position of the first matrix of a list that matches the pattern; raises an error when none does.
	#
	#   paMatrices   a list of matrices, or [ "in", list ]
	#   returns      a number
	#   see          FirstMatchingMatrix, FindMatchingMatrices
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

	# TRUE when at least one matrix of the list matches the pattern, whatever its name suggests; FALSE when none does.
	#
	#   paMatrices   a list of matrices, or [ "in", list ]
	#   returns      TRUE if any matrix matches, FALSE if none does
	#   note         kept as it is, because test/matrex/27_check_if_matches_any expects FALSE for a list
	#                where nothing matches; to ask whether none matches, test CountMatchingMatrices = 0
	#   warning      the name reads as the reverse of the answer; whether to rename it, to add a
	#                method for the other question or to turn it round with that test is for the author
	#   see          MatchesAll, CountMatchingMatrices
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
				return 1
			ok
		next
		
		return 0
	
		def MatchesNoneIn(paMatrices)
			return This.MatchesNone(paMatrices)

	# TRUE if every matrix of the list matches the pattern; an empty list gives TRUE.
	#
	#   paMatrices   a list of matrices, or [ "in", list ]
	#   returns      TRUE or FALSE (1 or 0)
	#   see          MatchesNone, CountMatchingMatrices
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
				return 0
			ok
		next
		
		return 1
	
		def MatchesAllIn(paMatrices)
			return This.MatchesAll(paMatrices)
	
	  #---------------------------#
	 #  PATTERN CONSTRAINT       #
	#---------------------------#
	
	# Appends a term to the pattern after a -> and parses the pattern again.
	#
	#   cConstraint   the term to add, such as property(symmetric)
	#   returns       nothing; the pattern and tokens change
	#   see           RemoveConstraint, Pattern
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
	
	# Removes the term at a position from the pattern, so that Match stops testing it, and parses the pattern again.
	#
	#   nIndex     the position of the term, 1 is the first; a position out of range changes nothing
	#   returns    nothing; the pattern text and the tokens change
	#   note       a term is one part of the pattern between ->, so a part that holds & or | goes as a
	#              whole; the pattern text is rewritten with " -> " between the parts that remain
	#   warning    a value that is not a number raises an error
	#   see        AddConstraint, Tokens
	def RemoveConstraint(nIndex)
		if NOT isNumber(nIndex)
			StzRaise("Incorrect param type! nIndex must be a number.")
		ok

		_cInner_ = trim(This._Mid(@cPattern, 2, len(@cPattern) - 1))
		_aParts_ = This.SplitByOperator(_cInner_, "->")
		_aKept_ = []
		_nLenParts_ = ring_len(_aParts_)
		for _i_ = 1 to _nLenParts_
			if trim(_aParts_[_i_]) != ""
				_aKept_ + trim(_aParts_[_i_])
			ok
		next

		if nIndex < 1 or nIndex > ring_len(_aKept_)
			return
		ok

		del(_aKept_, nIndex)

		_cNew_ = ""
		_nLenKept_ = ring_len(_aKept_)
		for _i_ = 1 to _nLenKept_
			if _i_ > 1
				_cNew_ += " -> "
			ok
			_cNew_ += _aKept_[_i_]
		next

		@cPattern = "{" + _cNew_ + "}"
		@aTokens = This.ParsePattern(@cPattern)

	  #-------------------------------#
	 #  MATRIX COMPARISON METHODS    #
	#-------------------------------#
	
	# Returns the share of cells that are equal in two matrices of the same size, from 0 to 1; matrices of different sizes score 0.
	#
	#   aMatrix1   the first matrix, or [ "between", m ]
	#   aMatrix2   the second matrix, or [ "and", m ]
	#   returns    a number from 0 to 1
	#   note       the wrapped forms are what SimilarityScore(:Between = m1, :And = m2) passes
	#   see        MostSimilarMatrix, FindMostSimilarMatrix
	def SimilarityScore(aMatrix1, aMatrix2)

		if CheckParams()
			if isList(aMatrix1) and len(aMatrix1) = 2 and isString(aMatrix1[1]) and (StzLower(aMatrix1[1]) = "between" or StzLower(aMatrix1[1]) = "and")
				aMatrix1 = aMatrix1[2]
			ok
			if isList(aMatrix2) and len(aMatrix2) = 2 and isString(aMatrix2[1]) and (StzLower(aMatrix2[1]) = "and" or StzLower(aMatrix2[1]) = "between")
				aMatrix2 = aMatrix2[2]
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

	# Returns the matrix of a list with the highest similarity score to a target; the first wins a tie, and an empty list raises an error.
	#
	#   _aTargetMatrix_   the target matrix, or [ "to", m ]
	#   paMatrices        a list of matrices, or [ "in", list ]
	#   returns           a matrix
	#   see               FindMostSimilarMatrix, SimilarityScore
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
	
	# Returns the position in a list of the matrix most similar to a target matrix; the first one wins a tie.
	#
	#   _aTargetMatrix_   the target matrix, or [ "to", m ]
	#   paMatrices        a list of matrices, or [ "in", list ]
	#   returns           a number; 0 for an empty list
	#   see               MostSimilarMatrix, SimilarityScore
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
	
	# Returns how a list splits under the pattern: the counts, the match rate and the matching and non matching matrices.
	#
	#   paMatrices   a list of matrices
	#   returns      a list of [ name, value ] pairs: pattern, totalmatrices, matchingcount,
	#                nonmatchingcount, matchrate, matching, nonmatching
	#   warning      an empty list raises error R1, a division by zero
	#   see          MatchingMatrices, CountMatchingMatrices
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
	
	# Returns the names among square, symmetric, diagonal, identity, zero, upper and lower that every matching matrix of the list has.
	#
	#   paMatrices   a list of matrices
	#   returns      a list of text; [ ] when no matrix of the list matches the pattern
	#   note         the matrices that do not match the pattern are left out of the comparison; for
	#                the matrices [ [[1,0],[0,1]] ] the answer is square, symmetric, diagonal,
	#                identity, upper, lower
	#   see          AnalyzeMatches, CheckProperty
	def CommonProperties(paMatrices)
		# Find properties common to all matching matrices

		_aMatching_ = []
		_nLen_ = len(paMatrices)
		for _i_ = 1 to _nLen_
			if This.Match(paMatrices[_i_])
				_aMatching_ + paMatrices[_i_]
			ok
		next

		_nLenMatching_ = ring_len(_aMatching_)
		if _nLenMatching_ = 0
			return []
		ok

		_aCommon_ = []
		_aAllProps_ = ["square", "symmetric", "diagonal", "identity",
		             "zero", "upper", "lower"]

		_nLenProps_ = len(_aAllProps_)

		for _i_ = 1 to _nLenProps_
			_cProp_ = _aAllProps_[_i_]
			_bAll_ = 1

			for j = 1 to _nLenMatching_
				if not This.CheckProperty(_cProp_, _aMatching_[j])
					_bAll_ = 0
					exit
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
	
	# Turns debug printing on and parses the pattern again, printing each step of the parsing.
	#
	#   returns    nothing; the object changes
	#   see        DisableDebug, SetDebug
	def EnableDebug()
		@bDebugMode = 1
		@aTokens = This.ParsePattern(@cPattern)

	# Turns debug printing off.
	#
	#   returns    nothing; the object changes
	#   see        EnableDebug, SetDebug
	def DisableDebug()
		@bDebugMode = 0
	
	# Turns debug printing on or off.
	#
	#   bFlag      1 to print the steps of parsing and matching, 0 for none
	#   returns    nothing; the object changes
	#   note       unlike EnableDebug it does not parse again
	#   see        EnableDebug, DisableDebug
	def SetDebug(bFlag)
		@bDebugMode = bFlag
	
	  #----------------------#
	 #  HELPER METHODS      #
	#----------------------#
	
	# TRUE if the text is made only of digits, minus signs and dots, so 1-2 and 1.5 both count.
	#
	#   cStr       the text to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        ParseSingleToken
	def IsNumeric(cStr)
		if cStr = ""
			return 0
		ok
		
		_nLen_ = len(cStr)
		for _i_ = 1 to _nLen_
			_cChar_ = This._Mid(cStr, _i_, _i_)
			if not isDigit(_cChar_) and _cChar_ != "-" and _cChar_ != "."
				return 0
			ok
		next
		
		return 1
	
	  #-----------------------#
	 #  PATTERN COMBINATION  #
	#-----------------------#
	
	# Returns a new matrex whose pattern holds this pattern and the other one joined by &, so a matrix must satisfy both.
	#
	#   oOtherMatrex   the matrex to combine with
	#   returns        a stzMatrex; neither original changes
	#   warning        raises an error when the argument is not a stzMatrex
	#   see            Or_, Not_
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
	
		# Returns a new matrex whose pattern holds this pattern and the other one joined by &, as And_ does.
		#
		#   oOtherMatrex   the matrex to combine with
		#   returns        a stzMatrex; neither original changes
		#   warning        raises an error when the argument is not a stzMatrex
		#   see            And_
		def Andd(oOtherMatrex)
			return This.And_(oOtherMatrex)

	# Returns a new matrex whose pattern holds this pattern and the other one joined by a vertical bar, so a matrix may satisfy either.
	#
	#   oOtherMatrex   the matrex to combine with
	#   returns        a stzMatrex; neither original changes
	#   warning        raises an error when the argument is not a stzMatrex
	#   see            And_, Not_
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
	
	# Returns a new matrex whose pattern negates this whole pattern; this object does not change.
	#
	#   returns    a stzMatrex whose pattern is {@!( ... )} around the terms of this one
	#   note       a matrix matches the result exactly when it does not match this pattern, whatever
	#              the terms and -> parts it has; Not_ of an empty pattern matches no matrix
	#   see        And_, Or_
	def Not_()
		# Negate the entire pattern: @! on one group that holds every term
		_cInner_ = This._Mid(@cPattern, 2, len(@cPattern) - 1)
		_cNegated_ = "{@!(" + _cInner_ + ")}"
		return new stzMatrex(_cNegated_)


	  #-------------------------------#
	 #  SERIALIZATION                #
	#-------------------------------#
	
	# Returns the pattern and its parsed tokens as JSON text: an object with the keys pattern and tokens.
	#
	#   returns    JSON text; {"pattern":"{}","tokens":[]} for the empty pattern
	#   note       texts are escaped by the library JSON writer, so a quote or a backslash in the
	#              pattern stays valid JSON
	#   see        TokensToJSON, TokenToJSON
	def ToJSON()
		# Convert pattern to JSON representation, text escaped by the library JSON writer
		_cJSON_ = '{'
		_cJSON_ += '"pattern":' + _ValueToJsonString(@cPattern) + ','
		_cJSON_ += '"tokens":' + This.TokensToJSON()
		_cJSON_ += '}'
		return _cJSON_

	# Returns the parsed tokens as a JSON array of objects, one per token; an empty pattern gives [].
	#
	#   returns    JSON text
	#   see        ToJSON, TokenToJSON
	def TokensToJSON()
		# Convert tokens to JSON array
		_cJSON_ = '['
		_nLen_ = ring_len(@aTokens)
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cJSON_ += ','
			ok
			_cJSON_ += This.TokenToJSON(@aTokens[_i_])
		next
		_cJSON_ += ']'
		return _cJSON_

	# Returns one parsed token as a JSON object; its constraints, alternatives, conditions and tokens become arrays of objects.
	#
	#   _aToken_   one parsed token, a list of [ key, value ] pairs
	#   returns    JSON text
	#   note       numbers stay numbers and an empty list becomes []
	#   see        TokensToJSON, ToJSON
	def TokenToJSON(_aToken_)
		# Convert single token, a list of [ key, value ] pairs, to a JSON object
		_cJSON_ = '{'
		_nLen_ = ring_len(_aToken_)
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cJSON_ += ','
			ok
			_cKey_ = _aToken_[_i_][1]
			_cJSON_ += '"' + _EscapeJsonString(_cKey_) + '":' + This._JsonOfTokenValue(_cKey_, _aToken_[_i_][2])
		next
		_cJSON_ += '}'
		return _cJSON_

	# Writes the value of one token key as JSON: tokens and constraints become arrays of objects, values an array.
	#
	#   cKey       the key of the pair
	#   vValue     the value of the pair, text, number or list
	#   returns    JSON text
	#   see        TokenToJSON
	def _JsonOfTokenValue(cKey, vValue)
		if NOT isList(vValue)
			return _ValueToJsonString(vValue)
		ok

		_cKey_ = StzLower(cKey)
		_nLen_ = ring_len(vValue)
		_cJSON_ = '['
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cJSON_ += ','
			ok
			if _cKey_ = "alternatives" or _cKey_ = "conditions" or _cKey_ = "tokens" or _cKey_ = "constraints"
				_cJSON_ += This.TokenToJSON(vValue[_i_])
			else
				_cJSON_ += _ValueToJsonString(vValue[_i_])
			ok
		next
		_cJSON_ += ']'
		return _cJSON_
