# Softanza List Regex Engine - Enhanced Version

func StzListRegexQ(_cPattern_)
	return new stzListex(_cPattern_)

func StzListexQ(_cPattern_)
	return StzListRegexQ(_cPattern_)

func Lx(_cPattern_)
	return StzListRegexQ(_cPattern_)

# Matches a list against a regex-like pattern of typed items, such as [@N, @S] for a number then a text.
#
# A pattern is a list of tokens: @N a number, @S a text, @L a list, @$ any item, each with an
# optional quantifier (+, *, ?, a count or a range such as 2-3), a set of allowed values written {a;
# b} with a trailing U for unique values, a negation @! and a case flag @cs:. Match answers 1 or 0
# for the whole list, and Tokens, TokensInfo and Explain show how the pattern was read. Build one
# with StzListexQ, StzListRegexQ or Lx. Found today: the cache key of Match is the same for any
# reordering of a list, so on one matcher a reordered list gets the stale answer of the first (use
# ClearCache between them); the first alternative of a group never matches; sets written in single
# quotes never match, since their closing quote is kept; the unique flag U does not enforce
# uniqueness; a nested list with a quantifier fails for two sublists; and TokensInfo raises R41 for
# any token with a variable count. The cause of the quote, alternation and nested defects is the
# same as stzTimex: calls to @StzMid pass an end position where it now wants a length.
#
#   receiver   o1 = StzListexQ("[@N, @S]")
#   example    ? o1.Match([ 1, "a" ])
#              #--> 1
#              o2 = StzListexQ("[@N, @S]")
#              ? o2.Match([ "a", 1 ])
#              #--> 0
#              ? o2.Pattern()
#              #--> [@N, @S]
#   see        stzList, stzTimex, stzRegex
class stzListex from stzObject

	@cPattern		# The original pattern string
	@aTokens		# List of parsed token definitions
	@bDebugMode = 0	# Debug mode flag

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

	# Builds a list matcher from a pattern text such as [@N, @S], wrapping it in square brackets if needed.
	#
	#   _cPattern_   the pattern as text
	#   returns      nothing; the object is built
	#   note         the pattern language: @N a number, @S a text, @L a list, @$ any item; + * ? 2
	#                and 2-3 as quantifiers; {a; b} a set of allowed values and a trailing U for
	#                unique ones; @!N a negation; @cs:S case-sensitive; a bracketed group of tokens
	#                joined by a vertical bar for alternatives; [@N, @S] a nested list; build with
	#                StzListexQ, StzListRegexQ or Lx
	#   see          Match, Pattern, Tokens
	def init(_cPattern_)
		if NOT isString(_cPattern_)
			raise("Error: Pattern must be a string")
		ok

		@cAnyPattern = @cNumberPattern + "|" + @cStringPattern + "|" + @cListPattern
		@cPattern = This.NormalizePattern(_cPattern_)
		@aTokens = This.ParsePattern(@cPattern)
		This.OptimizeTokens()

	# Returns the pattern text trimmed and wrapped in square brackets when it is not yet.
	#
	#   _cPattern_   the pattern as text
	#   returns      a text
	#   note         @N, @S gives [@N, @S], and [@N] stays [@N]
	#   see          ParsePattern, Pattern
	def NormalizePattern(_cPattern_)
		_cPattern_ = @trim(_cPattern_)
		
		if NOT (StartsWith(_cPattern_, "[") and EndsWith(_cPattern_, "]"))
			_cPattern_ = "[" + _cPattern_ + "]"
		ok
		
		return _cPattern_

	# Splits a bracketed pattern at its top-level commas and parses each piece into a token.
	#
	#   _cPattern_   the bracketed pattern
	#   returns      a list of tokens, each a list of [ name, value ] pairs
	#   note         [@N, @S, @L] gives 3 tokens; [@N2-3, @S?] gives a number token of 2 to 3 and a
	#                text token of 0 to 1
	#   see          ParseToken, SplitAtTopLevelCommas, Tokens
	def ParsePattern(_cPattern_)
		This.DebugLog("ParsePattern", "Input: " + _cPattern_)
		
		_cInner_ = @trim( @StzMid(@trim(_cPattern_), 2, StzLen(_cPattern_)-1) )
		_aParts_ = SplitAtTopLevelCommas(_cInner_)

		_aTokens_ = []
		_nPartsLen_3 = len(_aParts_)
		for i = 1 to _nPartsLen_3
			_aTokens_ + This.ParseToken(@trim(_aParts_[i]))
		next

		This.DebugLog("ParsePattern", "Tokens created: " + len(_aTokens_))
		return _aTokens_

	# Reads a nested list pattern such as [@N, @S]+ into one nested token holding the tokens of its inside.
	#
	#   cNestedPattern     the nested pattern with its quantifier, such as [@N, @S]+
	#   _bNegated_         1 if the token is negated
	#   _bCaseSensitive_   the case flag the inner tokens inherit
	#   returns            a token with the keyword @NESTED and its nestedTokens
	#   note               the token has the type nested
	#   warning            a nested token with a quantifier of + or * did not match two sublists in
	#                      checks (the pattern [[@N]+] answered FALSE for [[1],[2]] and TRUE for
	#                      [[1]])
	#   see                ParseToken, ParsePattern
	def ParseNestedPattern(cNestedPattern, _bNegated_, _bCaseSensitive_)
		_cInner_ = @StzMid(cNestedPattern, 2, StzLen(cNestedPattern)-1)
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
			[ "hasset", 0 ],
			[ "setvalues", [] ],
			[ "requireunique", 0 ],
			[ "negated", _bNegated_ ],
			[ "casesensitive", _bCaseSensitive_ ]
		]
    
		return _aToken_

	# Reads a bracketed group of alternatives, such as a number or a text, into one alternation token.
	#
	#   _cTokenStr_        the text of the group, its alternatives between round brackets and joined
	#                      by vertical bars
	#   _bNegated_         1 if the token is negated
	#   _bCaseSensitive_   the case flag the alternatives inherit
	#   returns            a token with the keyword @ALT and its alternatives
	#   note               the later alternatives are read correctly
	#   warning            the first alternative loses its keyword, type and pattern (in a group of
	#                      @N and @S the @N becomes an empty token), so a matching list for the
	#                      first alternative answers FALSE: a pattern with @N or @S in one group
	#                      matches a but not 1
	#   see                ParseToken, Match
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
			[ "hasset", 0 ],
			[ "setvalues", [] ],
			[ "requireunique", 0 ],
			[ "negated", _bNegated_ ],
			[ "casesensitive", _bCaseSensitive_ ]
		]
		
		return _aToken_

	# Reads one piece of a pattern, such as @N2-3, @S{"a"; "b"}, @!N or @cs:S, into a token.
	#
	#   _cTokenStr_   the text of one piece
	#   returns       a token as a list of [ name, value ] pairs: keyword, type, pattern, min, max,
	#                 quantifier, hasset, setvalues, requireunique, negated, casesensitive
	#   note          @N+ gives min 1 and a huge max, @N2-4 gives 2 and 4, @!N sets negated, @cs:S
	#                 sets casesensitive
	#   warning       an unknown keyword such as @A returns a token with no keyword, type or
	#                 pattern; set values written between single quotes keep their closing quote
	#                 (the set of a and b read as a' and b'), so such sets never match
	#   see           ParsePattern, ParseSetValues
	def ParseToken(_cTokenStr_)
		This.DebugLog("ParseToken", "Input: " + _cTokenStr_)
		
		_bNegated_ = 0
		_bCaseSensitive_ = 0

		# Check for case-sensitive prefix @cs:
		if StartsWith(StzLower(_cTokenStr_), "@cs:")
			_bCaseSensitive_ = 1
			_cTokenStr_ = @StzMid(_cTokenStr_, 5, StzLen(_cTokenStr_))
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
			_bNegated_ = 1
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
		_bRequireUnique_ = 0

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
				_cRemainder_ = StzRight(_cRemainder_, StzLen(_cRemainder_) - _nRangeLen_)

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

					_cRemainder_ = StzRight(_cRemainder_, StzLen(_cRemainder_) - 1)

				else
					_oNumberMatch_ = rx(@cSingleNumberPattern)

					if _oNumberMatch_.MatchFirst(_cRemainder_)
						_aMatches_ = _oNumberMatch_.Matches()
						_nQuantifier_ = number(_aMatches_[1])
						_nMin_ = _nQuantifier_
						_nMax_ = _nQuantifier_
                
						_cRemainder_ = StzRight(_cRemainder_, StzLen(_cRemainder_) - StzLen(_aMatches_[1]))
					ok
				ok
			ok
		ok

		# Set constraints processing using preserved values
		if len(_cPreservedSet_) > 0
			# Check for {values}U format
			if EndsWith(_cRemainder_, "U") and StzFindFirst("{", _cRemainder_) > 0
				_bRequireUnique_ = 1
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
			_aToken_ + [ "hasset", 1 ]
			_aToken_ + [ "setvalues", _aSetValues_ ]
			_aToken_ + [ "requireunique", _bRequireUnique_ ]
		else
			_aToken_ + [ "hasset", 0 ]
			_aToken_ + [ "setvalues", [] ]
			_aToken_ + [ "requireunique", 0 ]
		ok

		_aToken_ + [ "negated", _bNegated_ ]
		_aToken_ + [ "casesensitive", _bCaseSensitive_ ]

		This.DebugLog("ParseToken", "Type: " + _cKeyword_ + " CaseSens: " + _bCaseSensitive_)
		return _aToken_

	# Cuts a text at the commas that are outside square brackets.
	#
	#   cStr       the text to cut
	#   returns    a list of text, each piece trimmed
	#   note       @N, [@S, @N], @L gives @N, [@S, @N] and @L
	#   see        ParsePattern, ParseNestedPattern
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

	# Reads the inside of a set such as {1; 2; 3} into a list of values of the given type.
	#
	#   _cSetContent_   the set text, with or without its braces, values separated by semicolons
	#   _cType_         number, string, list or any
	#   bCheckUnique    1 to refuse repeated values
	#   returns         a list of values: numbers for number, double-quoted texts for string
	#   note            {1; 2; 3} gives 1, 2 and 3
	#   warning         raises Error: Duplicate value in unique set when bCheckUnique is 1 and a
	#                   value repeats, and Error: Invalid number in set for a non-number; a value
	#                   written between single quotes keeps its closing quote ('a' gives "a'")
	#   see             ParseToken, JoinSetValues
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
					_cUnquoted_ = @StzMid(_cValue_, 2, StzLen(_cValue_) - 1)
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
					_cCheck1_ = @StzMid(_cNormalizedValue_, 2, StzLen(_cNormalizedValue_) - 1)
					_nValuesLen_2 = len(_aValues_)
					for j = 1 to _nValuesLen_2
						_cCheck2_ = @StzMid(_aValues_[j], 2, StzLen(_aValues_[j]) - 1)
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

	# Strips the quotes around a text, but keeps the closing one.
	#
	#   cStr       the text, possibly between single or double quotes
	#   returns    a text
	#   note       a text without quotes comes back as it is
	#   warning    the closing quote stays: 'abc' gives abc' and "abc" gives abc"
	#   see        CompareValues, ParseSetValues
	def RemoveQuotes(cStr)
		if (StartsWith(cStr, "'") and EndsWith(cStr, "'")) or
		   (StartsWith(cStr, '"') and EndsWith(cStr, '"'))
			_cResult_ = @StzMid(cStr, 2, StzLen(cStr)-1)
			return _cResult_
		ok
		return cStr

	# Merges, in place, neighbouring tokens that have the same keyword, no set and a variable quantifier.
	#
	#   returns    nothing; the tokens change
	#   note       it runs once when the matcher is built
	#   warning    [@N+, @N*] becomes one token whose minimum is 0, which is looser than the pattern
	#              says
	#   see        Tokens, ParsePattern
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

	# TRUE if the whole list matches the pattern, element by element.
	#
	#   paList     the list to test
	#   returns    TRUE or FALSE, as 1 or 0; FALSE for a value that is not a list
	#   note       with a fresh matcher or after ClearCache the answers are right for [@N, @S]: [1,
	#              a] is TRUE, [a, 1] is FALSE; @S{"Hello"} accepts hello and @cs:S{"Hello"} does
	#              not
	#   warning    a repeated question returns a cached answer, and the cache key (the length and
	#              the sum of the characters) is the same for any reordering of a list: after [1, 2,
	#              a] matches [@N+, @S], the list [a, 2, 1] answers TRUE too on the same matcher,
	#              though a new matcher answers FALSE; a set U does not enforce uniqueness (the
	#              pattern [@N2{1; 2}U] accepts [2, 2]); a nested quantifier fails for two sublists;
	#              sets written in single quotes never match; the first of several alternatives
	#              never matches; Macth is a misspelled alias that works
	#   see        MatchTokensToElements, Explain, Tokens
	def Match(paList)
		if NOT isList(paList)
			return 0
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
		_bResult_ = 0
		try
			_bResult_ = This.MatchTokensToElements(@aTokens, _aElements_)

		catch
			if @bDebugMode
				? "Error during matching: " + cCatchError
			ok
			_bResult_ = 0
		done
		
		# Store in cache AFTER computing result
		@aMatchCache + [_cCacheKey_, _bResult_]
		if len(@aMatchCache) > @nMaxCacheSize
			del(@aMatchCache, 1)
		ok
		
		return _bResult_

	# TRUE if the tokens match the elements from the start to the end.
	#
	#   _aTokens_     the list of tokens, from Tokens
	#   _aElements_   the list of elements to test
	#   returns       TRUE or FALSE, as 1 or 0
	#   note          the tokens of [@N, @S] match [1, a]
	#   see           Match, BacktrackMatch
	def MatchTokensToElements(_aTokens_, _aElements_)
		_nLenTokens_ = len(_aTokens_)
		_nLenElements_ = len(_aElements_)
    
		return This.BacktrackMatch(_aTokens_, _aElements_, 1, 1, [])

	# TRUE if the tokens from one token on match the elements from one element on, trying alternatives by backtracking.
	#
	#   _aTokens_       the list of tokens
	#   _aElements_     the list of elements
	#   nTokenIndex     the 1-based index of the first token
	#   nElementIndex   the 1-based index of the first element
	#   aUsedValues     the values already used by unique sets, [ ] to start
	#   returns         TRUE or FALSE, as 1 or 0
	#   note            the tokens of [@N, @S] against [1, a] from 1 and 1 give TRUE, and against
	#                   [a, 1] give FALSE
	#   see             MatchTokensToElements, Match
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
					return 1
				ok
			next

			if @bDebugMode
				? ">>> All alternatives FAILED"
			ok
			return 0
		ok

		# Nested pattern handling
		if _aToken_[:keyword] = "@NESTED"
			_nMin_ = @Min([_aToken_[:max], _nLenElements_ - nElementIndex + 1])

			for nMatchCount = _aToken_[:min] to _nMin_
				_bSuccess_ = 1
				_nElemIdx_ = nElementIndex
				_aLocalUsedValuesCopy_ = _aLocalUsedValues_

				for i = 1 to nMatchCount
					if _nElemIdx_ > _nLenElements_
						_bSuccess_ = 0
 						exit
					ok

					_xElement_ = _aElements_[_nElemIdx_]

					if NOT isList(_xElement_)
						_bSuccess_ = 0
						exit
					ok

					if _aToken_[:negated]
						_bSuccess_ = 0
						exit
					ok
                
					if NOT This.MatchTokensToElements(_aToken_[:nestedTokens], _xElement_)
						_bSuccess_ = 0
						exit
					ok

					_nElemIdx_++
				next

				if _bSuccess_
					if nTokenIndex = _nLenTokens_
						if _nElemIdx_ = _nLenElements_ + 1
							return 1
						ok
					else
						if This.BacktrackMatch(_aTokens_, _aElements_, nTokenIndex + 1, _nElemIdx_, _aLocalUsedValuesCopy_)
							return 1
						ok
					ok
				ok
			next
        
			if _aToken_[:min] = 0
				if This.BacktrackMatch(_aTokens_, _aElements_, nTokenIndex + 1, nElementIndex, _aLocalUsedValues_)
					return 1
				ok
			ok
        
			return 0
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
			
			_bSuccess_ = 1
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
					_bSuccess_ = 0
					exit
				ok

				_xElement_ = _aElements_[_nElemIdx_]
				_bMatched_ = 0
            
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
						_bInSet_ = 0
						
						if @bDebugMode
							? ">>> Checking set constraint..."
							? ">>> Element value: " + _xElemValue_
							? ">>> Set values: " + @@(_aToken_[:setvalues])
						ok
						
						# Get case sensitivity setting
						_bCaseSensitive_ = 1
						if HasKey(_aToken_, "casesensitive")
							_bCaseSensitive_ = _aToken_[:casesensitive]
						ok

						_nTokensetvaluesLen_ = len(_aToken_[:setvalues])
						for j = 1 to _nTokensetvaluesLen_
							_xSetValue_ = _aToken_[:setvalues][j]

							if This.CompareValues(_xElemValue_, _xSetValue_, _aToken_[:type], _bCaseSensitive_)
								_bInSet_ = 1
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
							_bSuccess_ = 0
							exit
						ok
	                
						# Unique constraint for non-negated tokens
						if _aToken_[:requireunique] and NOT _aToken_[:negated]
							_bDuplicate_ = 0
							
							if @bDebugMode
								? ">>> Checking uniqueness..."
								? ">>> Already used: " + @@(_aLocalUsedValuesCopy_)
							ok
							
							_nLocalUsedValuesCopyLen_ = len(_aLocalUsedValuesCopy_)
							for j = 1 to _nLocalUsedValuesCopyLen_
								if This.CompareValues(_xElemValue_, _aLocalUsedValuesCopy_[j], _aToken_[:type], _bCaseSensitive_)
									_bDuplicate_ = 1
									if @bDebugMode
										? ">>> DUPLICATE found!"
									ok
									exit
								ok
							next
                        
							if _bDuplicate_
								_bSuccess_ = 0
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
					_bSuccess_ = 0
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
						return 1
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
						return 1
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
				return 1
			ok
		ok

		if @bDebugMode
			? ">>> Token COMPLETELY FAILED"
		ok
		return 0

	# TRUE if two values are equal under a type: numbers by value, texts with or without case, any by its kind.
	#
	#   xValue1            the first value
	#   xValue2            the second value
	#   _cType_            number, string, list or any
	#   _bCaseSensitive_   1 to compare with case, 0 to ignore it
	#   returns            TRUE or FALSE, as 1 or 0
	#   note               A against a is FALSE with 1 and TRUE with 0
	#   warning            the types list, and any when both values are lists, raise Calling
	#                      Function without definition: @stzreplace (R3) through NormalizeListString
	#   see                RemoveQuotes, Match
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

	# Raises error R3 today instead of removing the spaces from the text of a list.
	#
	#   xList      the list, or its text
	#   returns    nothing
	#   note       strip the spaces yourself
	#   warning    raises Calling Function without definition: @stzreplace (R3), because it calls a
	#              function that does not exist
	#   see        CompareValues, Match
	def NormalizeListString(xList)
		_cList_ = "" + xList
		_cList_ = @StzReplace(_cList_, " ", "")
		_cList_ = StzReplace(_cList_, Char(9), "")
		_cList_ = StzReplace(_cList_, Char(10), "")
		_cList_ = StzReplace(_cList_, Char(13), "")
		return _cList_

	# Returns a value read as the given type: a number for number, otherwise the text as it is.
	#
	#   _cValue_   the value as text
	#   _cType_    number, string, list or any
	#   returns    a number or a text
	#   note       12 with number gives the number 12
	#   see        ParseSetValues
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

	# Returns a short key made of a list's length and the sum of the characters of its text, used as the cache key.
	#
	#   aList      the list to describe
	#   returns    a text such as 3:550
	#   note       an empty list gives 0:216
	#   warning    two lists with the same elements in another order get the same key ([1, 2, 3] and
	#              [3, 2, 1] both give 3:550), which is how Match returns a stale answer
	#   see        Match, CacheInfo
	def ListSignature(aList)
		_cContent_ = @@(aList)
		_nChecksum_ = 0
		_nLen_ = len(_cContent_)
		
		for i = 1 to _nLen_
			_nChecksum_ += ascii(_cContent_[i])
		next
		
		return "" + len(aList) + ":" + _nChecksum_

	# Empties the cache of past match answers.
	#
	#   returns    the matcher itself, so calls chain
	#   note       call it before testing a list that is a reordering of one already tested
	#   see        CacheInfo, SetCacheSize, Match
	def ClearCache()
		@aMatchCache = []
		return self

	# Sets how many answers the cache may hold.
	#
	#   nSize      the largest number of cached answers
	#   returns    the matcher itself, so calls chain
	#   note       CacheInfo reads it back as maxsize, 100 on a new matcher
	#   see        CacheInfo, ClearCache
	def SetCacheSize(nSize)
		@nMaxCacheSize = nSize
		return self

	# Returns how many answers the cache holds and its limit.
	#
	#   returns    a list of [ entries, n ] and [ maxsize, n ] pairs
	#   see        ClearCache, SetCacheSize
	def CacheInfo()
		return [
			["entries", len(@aMatchCache)],
			["maxsize", @nMaxCacheSize]
		]

	  #---------------------------#
	 #     DEBUG METHODS         #
	#---------------------------#

	# Prints a titled debug message when the debug flag is on, and does nothing otherwise.
	#
	#   cMethod    the title
	#   cMessage   the message
	#   returns    nothing
	#   see        EnableDebug, DisableDebug
	def DebugLog(cMethod, cMessage)
		if @bDebugMode
			? "=== " + cMethod + " ==="
			? cMessage
		ok

	# Turns on the debug printing of the parser and the matcher.
	#
	#   returns    the matcher itself, so calls chain
	#   see        DisableDebug, DebugLog
	def EnableDebug()
		@bDebugMode = 1
		return self

	# Turns off the debug printing.
	#
	#   returns    the matcher itself, so calls chain
	#   see        EnableDebug, DebugLog
	def DisableDebug()
		@bDebugMode = 0
		return self

	# Returns the tokens parsed from the pattern, after merging.
	#
	#   returns    a list of tokens, each a list of [ name, value ] pairs
	#   note       TokensXT is the same call
	#   see        TokensInfo, Explain, ParsePattern
	def Tokens()
		return @aTokens

	# Returns one line of text per token: its number, keyword, quantifier and set.
	#
	#   returns    a list of text such as Token #1: @N
	#   note       MatchInfo is the same call; @N{1;2} gives Token #1: @N {1; 2}
	#   warning    raises Invalid numeric string (R41) for every token whose minimum differs from
	#              its maximum (@N+, @N2-3 and @S? all raise), because it adds a number to a text;
	#              only tokens with a fixed count work
	#   see        Tokens, Explain
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

	# Returns the set values joined as one text, separated by semicolons and a space.
	#
	#   _aValues_   the list of values
	#   returns     a text
	#   note        1, b and 3 give 1; b; 3
	#   see         ParseSetValues, TokensInfo
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

	# Returns the pattern text as stored, wrapped in square brackets.
	#
	#   returns    a text
	#   note       DomainPattern is the same call
	#   see        NormalizePattern, Tokens
	def Pattern()
		return @cPattern

	# Returns a summary of the pattern: its text, token count, cache entries and one record per token.
	#
	#   returns    a list of [ name, value ] pairs
	#   note       each token record holds Index, Keyword, Type, Min, Max, HasSet, SetValues,
	#              Unique, Negated and CaseSensitive; ExplainXT is the same call
	#   see        Tokens, TokensInfo
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
				["CaseSensitive", iff(HasKey(_aToken_, "casesensitive"), _aToken_[:casesensitive], 1)]
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
