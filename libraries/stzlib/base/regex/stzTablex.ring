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
		return 1
	else
		return 0
	ok

# Tests whether a stzTable fits a pattern written in a small regex-like language, such as {cols(3) & unique(name)}.
#
# A pattern is text in braces made of terms: cols, rows, col, row, cell, colname, hascol, property,
# contains, sorted, unique, duplicates, grouped, filtered, aggregated, transposed, calculated,
# coltype, colpattern, sumcol, avgcol, mincol, maxcol, nulls, completeness, numeric, alphabetic and
# format, written like cols(3) or sumcol(sales:>50000). Terms are joined by & (all must hold), a
# vertical bar (one must hold) and -> (a sequence), @! negates a term, @cs: makes it case-sensitive,
# and results are cached per pattern and table content. cols and rows take a number or a comparison:
# > and < are strict, >= and <= are at-least and at-most. A name the table does not have is simply
# not satisfied, it does not raise.
#
#   receiver   o1 = new stzTablex("{cols(3)}")
#   example    ? o1.Pattern()
#              #--> "{cols(3)}"
#   see        stzTable, stzMatrex, stzRegex
class stzTablex from stzObject
	
	@cPattern           # Pattern string
	@aTokens            # Parsed token definitions
	@oTable = ""      # Target table to match
	@bDebugMode = 0 # Debug flag
	@aMatchedParts = [] # Extracted parts

	@aMatchCache = []  # Store [pattern, tableHash, result]
	@nMaxCacheSize = 100

	  #-------------------#
	 #  INITIALIZATION   #
	#-------------------#

	# Builds a table pattern from text such as {cols(3) & unique(name)} and parses it into tokens; a non-text value raises an error.
	#
	#   pcPattern  the pattern text, with or without braces
	#   returns    nothing; the object is built
	#   note       the braces are added when missing; a term written without parentheses, such as {cols}, parses into a token with no constraint
	#   see        Match, Pattern, Tokens
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

	# The pattern text from position n1 to position n2, both included.
	#
	#   s            the text
	#   n1           the position to start at
	#   n2           the position to stop at, included
	#   returns      the slice, a string
	#
	# The global @StzMid takes a COUNT, not an end position (it was made codepoint-addressed in
	# commit 5976bb3de); every slice of this parser is written from a start and an end, so they
	# all go through here, as in stzMatrex.
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
	#   returns      a list of tokens, each a list of [ key, value ] pairs; one token per part, so {cols(2) -> rows(1)} gives two
	#   note         a part joined by & or a vertical bar is ONE token, a conjunction or an alternation, holding its conditions
	#   see          Tokens, ParseSingleToken
	def ParsePattern(_cPattern_)
		# Remove outer braces
		_cInner_ = This._Mid(_cPattern_, 2, StzLen(_cPattern_) - 1)
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

	# Returns the parts of a text split at an operator that stands outside brackets.
	#
	#   cStr        the text to split
	#   cOperator   the operator, such as "->"
	#   returns     a list of trimmed texts; "a->b->(c->d)" gives a, b and (c->d)
	#   note        an operator inside parentheses or braces does not split
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

	# Parses a part whose terms are joined by a vertical bar into an alternation token holding the alternatives.
	#
	#   _cTokenStr_   the text of the part, with or without outer parentheses
	#   returns       a token: [ type, alternation ], [ alternatives, a list of tokens ] and [ negated, 0 ]
	#   see           ParseConjunction, ParseSingleToken
	def ParseAlternation(_cTokenStr_)
		if startsWith(_cTokenStr_, "(") and endsWith(_cTokenStr_, ")")
			_cTokenStr_ = This._Mid(_cTokenStr_, 2, StzLen(_cTokenStr_) - 1)
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
			["negated", 0]
		]

	# Parses a part whose terms are joined by & into a conjunction token holding the conditions.
	#
	#   _cTokenStr_   the text of the part, with or without outer parentheses
	#   returns       a token: [ type, conjunction ], [ conditions, a list of tokens ] and [ negated, 0 ]
	#   see           ParseAlternation, ParseSingleToken
	def ParseConjunction(_cTokenStr_)
		if startsWith(_cTokenStr_, "(") and endsWith(_cTokenStr_, ")")
			_cTokenStr_ = This._Mid(_cTokenStr_, 2, StzLen(_cTokenStr_) - 1)
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
			["negated", 0]
		]

	# Parses one term such as unique(name) or @cs:contains(Ali) into a token: its type, value, constraints and flags.
	#
	#   _cTokenStr_   the text of one term
	#   returns       a token as a list of [ key, value ] pairs; [ ] for empty text; an ERROR token for a term it does not know
	#   note          @! sets negated, @cs: sets casesensitive, the quantifiers + * ? and n-m fill min and max, and Match never reads min and max; a term with no parentheses, such as cols, gets no constraint
	#   see           ParseConstraints, ParsePattern
	def ParseSingleToken(_cTokenStr_)
		_cTokenStr_ = trim(_cTokenStr_)
		if _cTokenStr_ = ""
			return []
		ok

		if @bDebugMode
			? "=== ParseSingleToken ==="
			? "Input: " + _cTokenStr_
		ok

		_bNegated_ = 0
		_bCaseSensitive_ = 0

		# Check for negation
		if startsWith(StzLower(_cTokenStr_), "@!")
			_bNegated_ = 1
			_cTokenStr_ = This._Mid(_cTokenStr_, 3, StzLen(_cTokenStr_))
		ok

		# Check for case sensitivity flag
		if startsWith(StzLower(_cTokenStr_), "@cs:")
			_bCaseSensitive_ = 1
			_cTokenStr_ = This._Mid(_cTokenStr_, 5, StzLen(_cTokenStr_))
		ok

		_cType_ = ""
		_cValue_ = ""
		_aConstraints_ = []
		_nMin_ = 1
		_nMax_ = 1
		_nCloseParen_ = 0

		# Extract and preserve content in parentheses BEFORE lowercasing
		_cPreservedValue_ = ""
		_nOpenParen_ = StzFindFirst("(", _cTokenStr_)
		if _nOpenParen_ > 0
			_nCloseParen_ = StzFindFirst(")", _cTokenStr_)
			if _nCloseParen_ > _nOpenParen_
				_cPreservedValue_ = This._Mid(_cTokenStr_, _nOpenParen_ + 1, _nCloseParen_ - 1)
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

				if _cType_ = "property" or _cType_ = "colname" or _cType_ = "row" or 
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
			_cQuantPart_ = This._Mid(_cTokenStr_, _nCloseParen_ + 1, StzLen(_cTokenStr_))
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

	# Removes the first of the given prefixes that the text starts with and returns the rest; the text is unchanged when none fits.
	#
	#   cStr        the text to shorten
	#   aPrefixes   the prefixes to try, in order, as a list of text
	#   returns     text
	#   note        "@cols(3)" with [ "@cols", "cols" ] gives "(3)"
	#   see         ParseSingleToken
	def RemovePrefix(cStr, aPrefixes)
		_nLen_ = len(aPrefixes)
		for _i_ = 1 to _nLen_
			if startsWith(cStr, aPrefixes[_i_])
				return This._Mid(cStr, StzLen(aPrefixes[_i_]) + 1, StzLen(cStr))
			ok
		next
		return cStr

	# Reads the text inside a term's parentheses into constraints: exact, greater, less, greaterequal and lessequal for cols and rows, a range or a set for cell.
	#
	#   cConstraintStr   the text to read
	#   _cType_          the term type, such as cols, rows or cell
	#   returns          a list of constraints; [ ] for empty text, any other type, or a text it does not read, such as 2-5 for rows
	#   note             the greater and less forms are strict: cols(>4) is false for exactly 4 columns; the at-least and at-most forms are written >= and <=
	#   see              ParseSingleToken
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
			but startsWith(cConstraintStr, ">=")
				_aConstraints_ + [
					["type", "greaterequal"],
					["value", 0 + This._Mid(cConstraintStr, 3, StzLen(cConstraintStr))]
				]
			but startsWith(cConstraintStr, "<=")
				_aConstraints_ + [
					["type", "lessequal"],
					["value", 0 + This._Mid(cConstraintStr, 3, StzLen(cConstraintStr))]
				]
			but startsWith(cConstraintStr, ">")
				_aConstraints_ + [
					["type", "greater"],
					["value", 0 + This._Mid(cConstraintStr, 2, StzLen(cConstraintStr))]
				]
			but startsWith(cConstraintStr, "<")
				_aConstraints_ + [
					["type", "less"],
					["value", 0 + This._Mid(cConstraintStr, 2, StzLen(cConstraintStr))]
				]
			ok

		on "rows"
			if This.IsNumeric(cConstraintStr)
				_aConstraints_ + [
					["type", "exact"],
					["value", 0 + cConstraintStr]
				]
			but startsWith(cConstraintStr, ">=")
				_aConstraints_ + [
					["type", "greaterequal"],
					["value", 0 + This._Mid(cConstraintStr, 3, StzLen(cConstraintStr))]
				]
			but startsWith(cConstraintStr, "<=")
				_aConstraints_ + [
					["type", "lessequal"],
					["value", 0 + This._Mid(cConstraintStr, 3, StzLen(cConstraintStr))]
				]
			but startsWith(cConstraintStr, ">")
				_aConstraints_ + [
					["type", "greater"],
					["value", 0 + This._Mid(cConstraintStr, 2, StzLen(cConstraintStr))]
				]
			but startsWith(cConstraintStr, "<")
				_aConstraints_ + [
					["type", "less"],
					["value", 0 + This._Mid(cConstraintStr, 2, StzLen(cConstraintStr))]
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
				_cSet_ = This._Mid(cConstraintStr, _nStart_ + 1, _nEnd_ - 1)
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

	# TRUE if the table satisfies every term of the pattern; the answer is cached per pattern and table content.
	#
	#   poTable    the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a non-table raises an error; a name that does not exist, such as sorted(zzz), is not satisfied, it does not raise
	#   see        MatchedParts, MatchingTables, ClearCache
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

	# TRUE if the table satisfies every token of the list, an alternation needing one alternative and a conjunction all of its conditions.
	#
	#   _aTokens_   the parsed tokens
	#   oTable      the stzTable to test
	#   returns     TRUE or FALSE (1 or 0)
	#   see         Match, MatchSingleToken
	def MatchTokens(_aTokens_, oTable)
		_nLen_ = len(_aTokens_)
		for _i_ = 1 to _nLen_
			_aToken_ = _aTokens_[_i_]

			if HasKey(_aToken_, "type") and _aToken_["type"] = "alternation"
				_bMatched_ = 0
				if HasKey(_aToken_, "alternatives")
					_aAlternatives_ = _aToken_["alternatives"]
					_nLenAlt_ = len(_aAlternatives_)

					for j = 1 to _nLenAlt_
						if This.MatchSingleToken(_aAlternatives_[j], oTable)
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
					_aConditions_ = _aToken_["conditions"]
					_nLenCond_ = len(_aConditions_)

					for j = 1 to _nLenCond_
						if not This.MatchSingleToken(_aConditions_[j], oTable)
							return 0
						ok
					next
				ok

			else
				if not This.MatchSingleToken(_aToken_, oTable)
					return 0
				ok
			ok
		next

		return 1

	# TRUE if the table satisfies one token, after applying the token's negation; a token of an unknown type is FALSE.
	#
	#   _aToken_   one parsed token
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        MatchTokens, CheckCols
	def MatchSingleToken(_aToken_, oTable)
		_bResult_ = 0

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
		if HasKey(_aToken_, "negated") and _aToken_["negated"] = 1
			_bResult_ = not _bResult_
		ok

		return _bResult_

	  #------------------------#
	 #  CHECKING METHODS      #
	#------------------------#

	# TRUE if the column count of the table meets the first exact, greater or less constraint of the token; no constraint gives FALSE.
	#
	#   _aToken_   a cols token
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       greater means at least and less means at most: 4 columns satisfy both greater 4
	#              and less 4
	#   see        CheckRows, Match
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
							return 1
						ok
					on "greater"
						if _nCols_ > _aConstraint_["value"]
							return 1
						ok
					on "less"
						if _nCols_ < _aConstraint_["value"]
							return 1
						ok
					on "greaterequal"
						if _nCols_ >= _aConstraint_["value"]
							return 1
						ok
					on "lessequal"
						if _nCols_ <= _aConstraint_["value"]
							return 1
						ok
					off
				ok
			next
		ok

		return 0

	# TRUE if the row count of the table meets the first exact, greater or less constraint of the token; no constraint gives FALSE.
	#
	#   _aToken_   a rows token
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       greater means at least and less means at most
	#   see        CheckCols, Match
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
							return 1
						ok
					on "greater"
						if _nRows_ > _aConstraint_["value"]
							return 1
						ok
					on "less"
						if _nRows_ < _aConstraint_["value"]
							return 1
						ok
					on "greaterequal"
						if _nRows_ >= _aConstraint_["value"]
							return 1
						ok
					on "lessequal"
						if _nRows_ <= _aConstraint_["value"]
							return 1
						ok
					off
				ok
			next
		ok

		return 0

	# TRUE if the table has a column of the name held in the token value.
	#
	#   _aToken_   a col token whose value is the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckColName, CheckHasCol
	def CheckCol(_aToken_, oTable)
		# Check specific column properties
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			return oTable.HasColumn(_cColName_)
		ok
		return 0

	# TRUE if the table holds a row whose cells equal the comma-separated values of the token, the case being ignored.
	#
	#   _aToken_   a row token whose value is the cells separated by commas, such as 2,Sara,32,Paris
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       the row must have exactly as many cells as the token lists
	#   see        CheckCol
	def CheckRow(_aToken_, oTable)
		# Check specific column properties
		if HasKey(_aToken_, "value")
			_aWanted_ = @split(_aToken_["value"], ",")
			_nWanted_ = len(_aWanted_)
			_nRows_ = oTable.NumberOfRows()
			for _i_ = 1 to _nRows_
				_aRow_ = oTable.Row(_i_)
				if len(_aRow_) = _nWanted_
					_bSame_ = 1
					for _j_ = 1 to _nWanted_
						if StzLower("" + _aRow_[_j_]) != StzLower(trim(_aWanted_[_j_]))
							_bSame_ = 0
							exit
						ok
					next
					if _bSame_
						return 1
					ok
				ok
			next
		ok
		return 0

	# TRUE if some cell of the table lies in the range of the token, or equals one of the values of its set.
	#
	#   _aToken_   a cell token with a range constraint such as 25..45, or a set such as {Ali;Zed}
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a range holds for number cells only; a set compares the written form of each cell, the case being ignored
	#   see        CheckContains
	def CheckCell(_aToken_, oTable)
		if NOT HasKey(_aToken_, "constraints")
			return 0
		ok
		_aConstraints_ = _aToken_["constraints"]
		_nLen_ = len(_aConstraints_)
		_nRows_ = oTable.NumberOfRows()

		for _i_ = 1 to _nLen_
			_aConstraint_ = _aConstraints_[_i_]
			if NOT HasKey(_aConstraint_, "type")
				loop
			ok

			if _aConstraint_["type"] = "range" and This.IsNumeric(_aConstraint_["start"]) and This.IsNumeric(_aConstraint_["end"])
				_nStart_ = 0 + _aConstraint_["start"]
				_nEnd_ = 0 + _aConstraint_["end"]
				for _r_ = 1 to _nRows_
					_aRow_ = oTable.Row(_r_)
					_nCells_ = len(_aRow_)
					for _c_ = 1 to _nCells_
						if isNumber(_aRow_[_c_]) and _aRow_[_c_] >= _nStart_ and _aRow_[_c_] <= _nEnd_
							return 1
						ok
					next
				next

			but _aConstraint_["type"] = "set"
				_aValues_ = _aConstraint_["values"]
				_nValues_ = len(_aValues_)
				for _r_ = 1 to _nRows_
					_aRow_ = oTable.Row(_r_)
					_nCells_ = len(_aRow_)
					for _c_ = 1 to _nCells_
						for _v_ = 1 to _nValues_
							if StzLower("" + _aRow_[_c_]) = StzLower(trim(_aValues_[_v_]))
								return 1
							ok
						next
					next
				next
			ok
		next
		return 0

	# TRUE if the table has a column of the name held in the token value, the case being ignored.
	#
	#   _aToken_   a colname token whose value is the name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckCol, CheckHasCol
	def CheckColName(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			return oTable.HasColName(_cColName_)
		ok
		return 0

	# TRUE if the table has the property named in the token: empty, nonempty, sorted or calculated; any other name gives FALSE.
	#
	#   _aToken_   a property token whose value is the property name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        Match
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
		return 0

	# TRUE if some cell of the table equals the value of the token, the case being ignored unless the token says otherwise.
	#
	#   _aToken_   a contains token whose value is the cell value
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a value that reads as a number is compared with the number cells by value; text and lists are compared by their written form
	#   see        CheckCell, Match
	def CheckContains(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cValue_ = _aToken_["value"]
			_value_ = _cValue_

			_bCaseSensitive_ = 0
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

			# scan the cells: numbers by value, text and lists by their written form
			_nRows_ = oTable.NumberOfRows()
			for _r_ = 1 to _nRows_
				_aRow_ = oTable.Row(_r_)
				_nCells_ = len(_aRow_)
				for _c_ = 1 to _nCells_
					_xCell_ = _aRow_[_c_]
					if isNumber(_value_)
						if isNumber(_xCell_) and _xCell_ = _value_
							return 1
						ok
					else
						_cCell_ = "" + _xCell_
						_cWanted_ = "" + _value_
						if isList(_xCell_)
							_cCell_ = @@(_xCell_)
						ok
						if isList(_value_)
							_cWanted_ = @@(_value_)
						ok
						if _bCaseSensitive_
							if strcmp(_cCell_, _cWanted_) = 0
								return 1
							ok
						else
							if StzLower(_cCell_) = StzLower(_cWanted_)
								return 1
							ok
						ok
					ok
				next
			next
			return 0
		ok

		return 0

	# TRUE if the named column is in ascending order, comparing numbers as numbers and text as text, the case being ignored unless the token says otherwise.
	#
	#   _aToken_   a sorted token whose value is the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0); FALSE for a column the table does not have
	#   note       only neighbours of the same type are compared; with @cs: a lower-case letter sorts after an upper-case one
	#   see        CheckUnique, Match
	def CheckSorted(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_bCaseSensitive_ = 1  # Default to case-sensitive
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
								return 0
							ok
						else
							if strcmp(StzLower(_xCurrent_), StzLower(_xNext_)) > 0
								return 0
							ok
						ok
	
					but isNumber(_xCurrent_) and isNumber(_xNext_)
						if _xCurrent_ > _xNext_
							return 0
						ok
					ok
				next
				return 1
			ok
		ok
		return 0

	# TRUE if no value repeats in the named column; the case is ignored unless the token says otherwise.
	#
	#   _aToken_   a unique token whose value is the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0); FALSE for a column the table does not have
	#   note       a and A repeat each other, but with @cs: they are two values
	#   see        CheckDuplicates, Match
	def CheckUnique(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_bCaseSensitive_ = 1  # Default to case-sensitive for unique
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
		return 0

	# TRUE if some value repeats in the named column; the case is ignored unless the token says otherwise.
	#
	#   _aToken_   a duplicates token whose value is the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckUnique, CheckGrouped
	def CheckDuplicates(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_bCaseSensitive_ = 0
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
		return 0

	# TRUE if two neighbouring values of the named column are equal, which is how grouped data looks.
	#
	#   _aToken_   a grouped token whose value is the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       it tests neighbours only, so equal values far apart do not count
	#   see        CheckDuplicates
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
				_bCaseSensitive_ = 0
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

					_bMatch_ = 0
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
		return 0

	# TRUE if the named column holds only numbers and two neighbours differ by more than 1, which suggests rows were filtered out.
	#
	#   _aToken_   a filtered token whose value is the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a column with one row or a non-number answers FALSE
	#   see        CheckAggregated
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
							return 0
						ok
					next
					# Check for non-sequential numbers
					for _i_ = 1 to _nLen_ - 1
						if _aCol_[_i_+1] - _aCol_[_i_] > 1
							return 1
						ok
					next
				ok
			ok
		ok
		return 0

	# TRUE if the table has calculated rows or calculated columns.
	#
	#   _aToken_   an aggregated token
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckCalculated
	def CheckAggregated(_aToken_, oTable)
		# Check if table contains aggregated data (calculated rows/cols)
		return len(oTable.FindCalculatedRows()) > 0 or 
		       len(oTable.FindCalculatedCols()) > 0

	# TRUE if the table has more columns than rows, which suggests it is transposed.
	#
	#   _aToken_   a transposed token
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckCols
	def CheckTransposed(_aToken_, oTable)
		# Check if table structure suggests it's transposed (more cols than rows)
		return oTable.NumberOfColumns() > oTable.NumberOfRows()

	# TRUE if the named column is a calculated column; with no name, TRUE if the table has any calculated column.
	#
	#   _aToken_   a calculated token, whose value may be the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckAggregated, CheckHasCol
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
		return 0

	# TRUE if the table has a column of the name held in the token value.
	#
	#   _aToken_   a hascol token whose value is the column name
	#   poTable    the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckCol, CheckColName
	def CheckHasCol(_aToken_, poTable)

		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			return poTable.HasColumn(_cColName_)
		ok
		return 0

	# TRUE if every value of a column has a type, the token value being column:type with number, string or list as the type.
	#
	#   _aToken_   a coltype token whose value reads name:type
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       any other type word, or a value without a colon, gives FALSE
	#   see        CheckNumeric, Match
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
									return 0
								ok
							next
							return 1

						on "string"
							for _i_ = 1 to _nLen_
								if NOT isString(_aCol_[_i_])
									return 0
								ok
							next
							return 1
							
						on "list"
							for _i_ = 1 to _nLen_
								if NOT isList(_aCol_[_i_])
									return 0
								ok
							next
							return 1
						off
					ok
				ok
			ok
		ok
		return 0

	# TRUE if every text of the named column matches a regex pattern.
	#
	#   _aToken_   a colpattern token whose value reads name:pattern
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckFormat
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
								if NOT Q(_aCol_[_i_]).MatchesRegex(_cPattern_)
									return 0
								ok
							ok
						next
						return 1
					ok
				ok
			ok
		ok
		return 0

	# TRUE if the sum of the numbers of a column meets a constraint, the token value being column:value, column:>value or column:<value.
	#
	#   _aToken_   a sumcol token whose value reads name:constraint
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       non-number cells are skipped; a value that is not a constraint gives FALSE
	#   see        CheckAvgCol, CheckMinCol, CheckMaxCol
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
							return _nSum_ > (0 + This._Mid(_cConstraint_, 2, StzLen(_cConstraint_)))
						but startsWith(_cConstraint_, "<")
							return _nSum_ < (0 + This._Mid(_cConstraint_, 2, StzLen(_cConstraint_)))
						but This.IsNumeric(_cConstraint_)
							return _nSum_ = (0 + _cConstraint_)
						ok
					ok
				ok
			ok
		ok
		return 0

	# TRUE if the average of the numbers of a column meets a constraint, the token value being column:value, column:>value or column:<value.
	#
	#   _aToken_   an avgcol token whose value reads name:constraint
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a column with no number gives FALSE
	#   see        CheckSumCol, CheckMinCol, CheckMaxCol
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
								return _nAvg_ > (0 + This._Mid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but startsWith(_cConstraint_, "<")
								return _nAvg_ < (0 + This._Mid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but This.IsNumeric(_cConstraint_)
								return _nAvg_ = (0 + _cConstraint_)
							ok
						ok
					ok
				ok
			ok
		ok
		return 0

	# TRUE if the smallest number of a column meets a constraint, the token value being column:value, column:>value or column:<value.
	#
	#   _aToken_   a mincol token whose value reads name:constraint
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a column with no number gives FALSE
	#   see        CheckMaxCol, CheckSumCol
	def CheckMinCol(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			if StzFindFirst(":", _aToken_["value"]) > 0
				_aParts_ = @split(_aToken_["value"], ":")
				if len(_aParts_) = 2
					_cColName_ = trim(_aParts_[1])
					_cConstraint_ = trim(_aParts_[2])

					if oTable.HasColumn(_cColName_)
						_aCol_ = oTable.Col(_cColName_)
						_nMin_ = ""
						_nLen_ = len(_aCol_)
						for _i_ = 1 to _nLen_
							if isNumber(_aCol_[_i_])
								if _nMin_ = ""
									_nMin_ = _aCol_[_i_]
								but _aCol_[_i_] < _nMin_
									_nMin_ = _aCol_[_i_]
								ok
							ok
						next

						if _nMin_ != ""
							if startsWith(_cConstraint_, ">")
								return _nMin_ > (0 + This._Mid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but startsWith(_cConstraint_, "<")
								return _nMin_ < (0 + This._Mid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but This.IsNumeric(_cConstraint_)
								return _nMin_ = (0 + _cConstraint_)
							ok
						ok
					ok
				ok
			ok
		ok
		return 0

	# TRUE if the largest number of a column meets a constraint, the token value being column:value, column:>value or column:<value.
	#
	#   _aToken_   a maxcol token whose value reads name:constraint
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a column with no number gives FALSE
	#   see        CheckMinCol, CheckSumCol
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
						_nMax_ = ""
						_nLen_ = len(_aCol_)
						for _i_ = 1 to _nLen_
							if isNumber(_aCol_[_i_])
								if _nMax_ = ""
									_nMax_ = _aCol_[_i_]
								but _aCol_[_i_] > _nMax_
									_nMax_ = _aCol_[_i_]
								ok
							ok
						next

						if _nMax_ != ""
							if startsWith(_cConstraint_, ">")
								return _nMax_ > (0 + This._Mid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but startsWith(_cConstraint_, "<")
								return _nMax_ < (0 + This._Mid(_cConstraint_, 2, StzLen(_cConstraint_)))
							but This.IsNumeric(_cConstraint_)
								return _nMax_ = (0 + _cConstraint_)
							ok
						ok
					ok
				ok
			ok
		ok
		return 0

	# TRUE if the named column holds an empty text or a 0, both counting as null.
	#
	#   _aToken_   a nulls token whose value is the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a real 0 is taken for a missing value
	#   see        CheckCompleteness
	def CheckNulls(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_aCol_ = oTable.Col(_cColName_)
				_nLen_ = len(_aCol_)
				for _i_ = 1 to _nLen_
					if _aCol_[_i_] = "" or _aCol_[_i_] = "" or _aCol_[_i_] = 0
						return 1
					ok
				next
			ok
		ok
		return 0

	# TRUE if the share of cells of a column that are neither empty nor 0 reaches a percentage, the token value being column:percent.
	#
	#   _aToken_   a completeness token whose value reads name:percent
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   note       a real 0 counts as missing, so a column of 3 with one 0 is 66.7 percent complete
	#   see        CheckNulls
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
							if _aCol_[_i_] != "" and _aCol_[_i_] != "" and _aCol_[_i_] != 0
								_nNonEmpty_++
							ok
						next
						_nCompleteness_ = (_nNonEmpty_ * 100.0) / _nLenCol_
						return _nCompleteness_ >= (0 + _cPercent_)
					ok
				ok
			ok
		ok
		return 0

	# TRUE if every value of the named column is a number.
	#
	#   _aToken_   a numeric token whose value is the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        CheckAlphabetic, CheckColType
	def CheckNumeric(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_aCol_ = oTable.Col(_cColName_)
				_nLen_ = len(_aCol_)
				for _i_ = 1 to _nLen_
					if NOT isNumber(_aCol_[_i_])
						return 0
					ok
				next
				return 1
			ok
		ok
		return 0

	# TRUE if every value of the named column is a text made of letters only.
	#
	#   _aToken_   an alphabetic token whose value is the column name
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0); FALSE for a column holding a non-text
	#   see        CheckNumeric
	def CheckAlphabetic(_aToken_, oTable)
		if HasKey(_aToken_, "value")
			_cColName_ = _aToken_["value"]
			if oTable.HasColumn(_cColName_)
				_aCol_ = oTable.Col(_cColName_)
				_nLen_ = len(_aCol_)
				for _i_ = 1 to _nLen_
					if isString(_aCol_[_i_])
						if NOT Q(_aCol_[_i_]).IsAlphaString()
							return 0
						ok
					else
						return 0
					ok
				next
				return 1
			ok
		ok
		return 0

	# TRUE if every text of the named column fits a regex format, the token value being column:format.
	#
	#   _aToken_   a format token whose value reads name:format
	#   oTable     the stzTable to test
	#   returns    TRUE or FALSE (1 or 0)
	#   see        MatchesFormat, CheckColPattern
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
									return 0
								ok
							ok
						next
						return 1
					ok
				ok
			ok
		ok
		return 0

	# TRUE if a text fits a regex format.
	#
	#   _cValue_    the text to test
	#   _cFormat_   the regex pattern to match it against
	#   returns     TRUE or FALSE (1 or 0)
	#   see         CheckFormat
	def MatchesFormat(_cValue_, _cFormat_)

		_oRegex_ = new stzRegex(_cFormat_)
		if _oRegex_.Match(_cValue_)
			return 1
		else
			return 0
		ok

	  #----------------------#
	 #  PART EXTRACTION     #
	#----------------------#

	# Records the column count, row count, column names and properties of a table as the matched parts of this object.
	#
	#   oTable     the stzTable to describe
	#   returns    nothing; the matched parts change
	#   note       the properties are empty or nonempty, with a word for calculated columns that is
	#              misspelled hasclculated
	#   see        MatchedParts, Match
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

	# Returns what was recorded by the last successful match: the pairs cols, rows, colnames and properties.
	#
	#   returns    a list of [ name, value ] pairs; [ ] before any success, and after a match that failed
	#   see        ExtractParts, Explain
	def MatchedParts()
		return @aMatchedParts

	# Returns how many parts the matched parts hold: 4 after ExtractParts, 0 before.
	#
	#   returns    a number
	#   see        MatchedParts
	def NumberOfMatchedParts()
		return len(@aMatchedParts)

		# Returns how many parts were recorded by the last successful match.
		#
		#   returns    a number; 4 after a success, 0 before one
		#   see        NumberOfMatchedParts
		def CountMatchedParts()
			return len(@aMatchedParts)

		# Returns how many parts were recorded by the last successful match.
		#
		#   returns    a number; 4 after a success, 0 before one
		#   see        NumberOfMatchedParts
		def HowManyMatchedParts()
			return len(@aMatchedParts)

	# Returns the parsed tokens of the pattern.
	#
	#   returns    a list of tokens, each a list of [ key, value ] pairs
	#   see        Pattern, ParsePattern
	def Tokens()
		return @aTokens

	# Returns how many tokens the pattern was parsed into.
	#
	#   returns    a number; terms joined by -> give one token each, while terms joined by & or a vertical bar are ONE token
	#   see        Tokens
	def NumberOfTokens()
		return len(@aTokens)

		# Returns how many tokens the pattern was parsed into.
		#
		#   returns    a number
		#   see        NumberOfTokens
		def CountTokens()
			return len(@aTokens)

		# Returns how many tokens the pattern was parsed into.
		#
		#   returns    a number
		#   see        NumberOfTokens
		def HowManyTokens()
			return len(@aTokens)

	# Returns the pattern text with its braces.
	#
	#   returns    text
	#   see        Tokens, NormalizePattern
	def Pattern()
		return @cPattern

	# Returns the pattern, its token count, its tokens and the matched parts as [ name, value ] pairs.
	#
	#   returns    a list of [ name, value ] pairs
	#   see        Tokens, MatchedParts
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
	
	# Returns the tables of a list that match the pattern, in their order.
	#
	#   paTables   a list of stzTable objects, or [ "in", list ]
	#   returns    a list of tables; [ ] when none match
	#   see        CountMatchingTables, Match
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

	# Returns how many tables of a list match the pattern.
	#
	#   paTables   a list of stzTable objects, or [ "in", list ]
	#   returns    a number
	#   see        MatchingTables, Match
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

	# Turns debug printing on; it does not parse the pattern again, so only later calls print.
	#
	#   returns    nothing; the object changes
	#   see        DisableDebug, SetDebug
	def EnableDebug()
		@bDebugMode = 1

	# Turns debug printing off.
	#
	#   returns    nothing; the object changes
	#   see        EnableDebug, SetDebug
	def DisableDebug()
		@bDebugMode = 0

	# Turns debug printing on or off.
	#
	#   bFlag      1 to print the steps of parsing and checking, 0 for none
	#   returns    nothing; the object changes
	#   see        EnableDebug, DisableDebug
	def SetDebug(bFlag)
		@bDebugMode = bFlag

	  #----------------------#
	 #  HELPER METHODS      #
	#----------------------#

	# TRUE if the text reads as a number: an optional minus sign, digits, and at most one dot.
	#
	#   cStr       the text to test
	#   returns    TRUE or FALSE (1 or 0); FALSE for empty text, for 1-2 and for 1.2.3
	#   see        ParseSingleToken
	def IsNumeric(cStr)
		if cStr = ""
			return 0
		ok

		_nLen_ = len(cStr)
		_nDigits_ = 0
		_nDots_ = 0
		for _i_ = 1 to _nLen_
			_cChar_ = This._Mid(cStr, _i_, _i_)
			if isDigit(_cChar_)
				_nDigits_++
			but _cChar_ = "-" and _i_ = 1
				# a leading minus sign
			but _cChar_ = "."
				_nDots_++
			else
				return 0
			ok
		next

		return (_nDigits_ > 0 and _nDots_ <= 1)

	  #-----------------------#
	 #  PATTERN COMBINATION  #
	#-----------------------#

	# Returns a new tablex whose pattern joins this pattern and the other one with &.
	#
	#   oOtherTablex   the tablex to combine with
	#   returns        a stzTablex; neither original changes; {cols(3)} and {rows(3)} give {cols(3) & rows(3)}
	#   note           raises an error when the argument is not a stzTablex
	#   see            Or_, Not_
	def And_(oOtherTablex)
		if NOT IsStzTablex(oOtherTablex)
			StzRaise("Incorrect param! oOtherTablex must be a stzTablex object.")
		ok

		_cCombined_ = "{" + 
		            This._Mid(@cPattern, 2, StzLen(@cPattern) - 1) + 
		            " & " + 
		            This._Mid(oOtherTablex.Pattern(), 2, StzLen(oOtherTablex.Pattern()) - 1) +
		            "}"
		
		return new stzTablex(_cCombined_)

	# Returns a new tablex whose pattern joins this pattern and the other one with a vertical bar.
	#
	#   oOtherTablex   the tablex to combine with
	#   returns        a stzTablex; neither original changes; {cols(3)} and {rows(9)} give {cols(3) | rows(9)}
	#   note           raises an error when the argument is not a stzTablex
	#   see            And_, Not_
	def Or_(oOtherTablex)
		if NOT IsStzTablex(oOtherTablex)
			StzRaise("Incorrect param! oOtherTablex must be a stzTablex object.")
		ok

		_cCombined_ = "{" + 
		            This._Mid(@cPattern, 2, StzLen(@cPattern) - 1) + 
		            " | " + 
		            This._Mid(oOtherTablex.Pattern(), 2, StzLen(oOtherTablex.Pattern()) - 1) +
		            "}"
		
		return new stzTablex(_cCombined_)

	# Returns a new tablex whose pattern has @! in front of the inner text.
	#
	#   returns    a stzTablex; {cols(3)} gives {@!cols(3)}
	#   note       the @! prefix is read as part of the first term only: for a pattern of two terms joined by & it negates the first term, not the whole
	#   see        And_, Or_
	def Not_()
		_cInner_ = This._Mid(@cPattern, 2, StzLen(@cPattern) - 1)
		_cNegated_ = "{@!" + _cInner_ + "}"
		return new stzTablex(_cNegated_)

	  #-----------------#
	 #  CACHE UTILITY  #
	#-----------------#

	# Returns a text identifying a table by its column count, row count, column names and a checksum of its content; the cache uses it.
	#
	#   poTable    the stzTable to sign
	#   returns    text such as 4:3:[ "name", "age" ]:9240
	#   see        Match, ClearCache
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

	# Empties the cache of match results kept by this object.
	#
	#   returns    nothing; the cache is emptied
	#   see        SetCacheSize, Match
	def ClearCache()
		@aMatchCache = []

	# Sets how many match results the cache keeps before it drops the oldest; a non-number raises an error.
	#
	#   nSize      the number of results to keep, 100 by default
	#   returns    nothing; the object changes
	#   see        ClearCache, Match
	def SetCacheSize(nSize)
		if CheckParams()
			if NOT isNumber(nSize)
				StzRaise("Incorrect param type! nSize must be a number.")
			ok
		ok

		@nMaxCacheSize = nSize
