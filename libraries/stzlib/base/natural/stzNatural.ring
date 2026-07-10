# Enhanced Multilingual Softanza Natural Programming System
# Extended with Context Interpolation Support

#-- [Previous global definitions remain the same]
$aLanguageDefinitions = [
	[
		:code = "en",
		:name = "english",
		:script = "latin",
		
		:ignored_words = [
			"is", "are", "should", "must", "can", "will", "the",
			"this", "that", "these", "those", "and", "then", "also",
			"plus", "with", "using", "to", "by", "containing", "be",
			"being", "decorated", "final", "result", "object", "at",
			"position", "a", "it", "on", "inside", "very", "much",
			"thank", "you", "please", "nice",
			"its", "it's", "of", "me", "as", "in"
		],
		
		:semantic_mappings = [
			[:natural = "create", :semantic = "CREATE_OBJECT"],
			[:natural = "make", :semantic = "CREATE_OBJECT"],
			[:natural = "new", :semantic = "CREATE_OBJECT"],
			
			[:natural = "string", :semantic = "OBJECT_STRING"],
			[:natural = "text", :semantic = "OBJECT_STRING"],
			[:natural = "stzstring", :semantic = "OBJECT_STRING"],

			[:natural = "list", :semantic = "OBJECT_LIST"],
			[:natural = "stzlist", :semantic = "OBJECT_LIST"],

			[:natural = "number", :semantic = "OBJECT_NUMBER"],
			[:natural = "stznumber", :semantic = "OBJECT_NUMBER"],

			[:natural = "with", :semantic = "VALUE_INDICATOR"],

			# multi-object naming: 'Create a list with [...] called basket'
			# then 'Use basket' to switch the live object
			[:natural = "called", :semantic = "NAME_INDICATOR"],
			[:natural = "named",  :semantic = "NAME_INDICATOR"],
			[:natural = "use",    :semantic = "SWITCH_OBJECT"],

			# VALUE binding: 'Keep it as sep' captures the current result
			# (a query's answer, else the live content) under a name that
			# later RECALLS as a variable in value/parameter positions
			[:natural = "keep",     :semantic = "KEEP_INDICATOR"],
			[:natural = "store",    :semantic = "KEEP_INDICATOR"],
			[:natural = "remember", :semantic = "KEEP_INDICATOR"],
			
			[:natural = "uppercase", :semantic = "METHOD_UPPERCASE"],
			[:natural = "lowercase", :semantic = "METHOD_LOWERCASE"],
			[:natural = "capitalize", :semantic = "METHOD_CAPITALIZE"],
			[:natural = "capitalise", :semantic = "METHOD_CAPITALIZE"],
			[:natural = "reverse", :semantic = "METHOD_REVERSE"],
			[:natural = "sort", :semantic = "METHOD_SORT"],
			[:natural = "trim", :semantic = "METHOD_TRIM"],
			[:natural = "replace", :semantic = "METHOD_REPLACE"],
			[:natural = "substitute", :semantic = "METHOD_REPLACE"],
			[:natural = "change", :semantic = "METHOD_REPLACE"],

			[:natural = "spacify", :semantic = "METHOD_SPACIFY"],
			[:natural = "addspaces", :semantic = "METHOD_SPACIFY"],
			[:natural = "box", :semantic = "METHOD_BOX"],
			[:natural = "frame", :semantic = "METHOD_BOX"],
			[:natural = "rounded", :semantic = "MODIFIER_ROUNDED"],

			[:natural = "increment", :semantic = "METHOD_INCREMENT"],
			[:natural = "decrement", :semantic = "METHOD_DECREMENT"],
			[:natural = "multiply", :semantic = "METHOD_MULTIPLY"],
			[:natural = "divide", :semantic = "METHOD_DIVIDE"],
			
			[:natural = "show", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "display", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "print", :semantic = "OUTPUT_DISPLAY"],
			
			[:natural = "screen", :semantic = "CONTEXT_IGNORED"]
		]
	],
	
	[
		:code = "ha",
		:name = "hausa",
		:script = "latin",
		
		:ignored_words = [
			"da", "dole", "kuma", "a", "ciki", "shi", "wannan",
			"kan", "na", "gode", "sosai", "susai"
		],
		
		:semantic_mappings = [
			[:natural = "yi", :semantic = "CREATE_OBJECT"],
			[:natural = "rubutu", :semantic = "OBJECT_STRING"],
			[:natural = "rubuti", :semantic = "OBJECT_STRING"],
			[:natural = "dauke", :semantic = "VALUE_INDICATOR"],
			[:natural = "É—auke", :semantic = "VALUE_INDICATOR"],
			[:natural = "raba", :semantic = "METHOD_SPACIFY"],
			[:natural = "maida", :semantic = "METHOD_UPPERCASE"],
			[:natural = "maiÉ—a", :semantic = "METHOD_UPPERCASE"],
			[:natural = "datsa", :semantic = "METHOD_TRIM"],
			[:natural = "akwati", :semantic = "METHOD_BOX"],
			[:natural = "zagaye", :semantic = "MODIFIER_ROUNDED"],
			[:natural = "nuna", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "allo", :semantic = "CONTEXT_IGNORED"]
		]
	]
]

$aSemanticOperations = [
	[
		:semantic_id = "OBJECT_STRING",
		:object_type = "stzString",
		:constructor = "StzStringQ(@)",
		:variable = "oStr"
	],

	[
		:semantic_id = "OBJECT_LIST",
		:object_type = "stzList",
		:constructor = "StzListQ(@)",
		:variable = "oList"
	],

	[
		:semantic_id = "OBJECT_NUMBER",
		:object_type = "stzNumber",
		:constructor = "StzNumberQ(@)",
		:variable = "oNum"
	],

	[
		:semantic_id = "METHOD_UPPERCASE",
		:stz_method = "Uppercase",
		:stz_signature = "@var.Uppercase()",
		:applies_to = ["stzString", "stzList"]
	],

	[
		:semantic_id = "METHOD_LOWERCASE",
		:stz_method = "Lowercase",
		:stz_signature = "@var.Lowercase()",
		:applies_to = ["stzString", "stzList"]
	],

	[
		:semantic_id = "METHOD_CAPITALIZE",
		:stz_method = "Capitalize",
		:stz_signature = "@var.Capitalize()",
		:applies_to = ["stzString", "stzList"]
	],

	[
		:semantic_id = "METHOD_REVERSE",
		:stz_method = "Reverse",
		:stz_signature = "@var.Reverse()",
		:applies_to = ["stzString", "stzList"]
	],

	[
		:semantic_id = "METHOD_SORT",
		:stz_method = "Sort",
		:stz_signature = "@var.Sort()",
		:applies_to = ["stzString", "stzList"]
	],

	[
		:semantic_id = "METHOD_TRIM",
		:stz_method = "Trim",
		:stz_signature = "@var.Trim()",
		:applies_to = ["stzString", "stzList"]
	],

	[
		:semantic_id = "METHOD_SPACIFY",
		:stz_method = "Spacify",
		:stz_signature = "@var.Spacify()",
		:applies_to = ["stzString"]
	],

	[
		:semantic_id = "METHOD_REPLACE",
		:stz_method = "Replace",
		:stz_signature = "@var.Replace(@param1, @param2)",
		:requires_params = 2,
		:applies_to = ["stzString"]
	],

	[
		:semantic_id = "METHOD_BOX",
		:stz_method = "Box",
		:stz_signature = "@var.Box()",
		:supports_modifiers = 1,
		:applies_to = ["stzString"],
		:modifiers = [
			[
				:semantic_id = "MODIFIER_ROUNDED",
				:stz_method = "BoxXT",
				:stz_param = ":Rounded = 1"
			]
		]
	],

	[
		:semantic_id = "METHOD_INCREMENT",
		:stz_method = "Increment",
		:stz_signature = "@var.Increment()",
		:applies_to = ["stzNumber"]
	],

	[
		:semantic_id = "METHOD_DECREMENT",
		:stz_method = "Decrement",
		:stz_signature = "@var.Decrement()",
		:applies_to = ["stzNumber"]
	],

	[
		:semantic_id = "METHOD_MULTIPLY",
		:stz_method = "MultiplyBy",
		:stz_signature = "@var.MultiplyBy(@param1)",
		:requires_params = 1,
		:applies_to = ["stzNumber"]
	],

	[
		:semantic_id = "METHOD_DIVIDE",
		:stz_method = "DivideBy",
		:stz_signature = "@var.DivideBy(@param1)",
		:requires_params = 1,
		:applies_to = ["stzNumber"]
	],

	[
		:semantic_id = "OUTPUT_DISPLAY",
		:stz_signature = "? @var.Content()"
	]
]

#-- GLOBAL FUNCTIONS WITH CONTEXT SUPPORT

func NaturallyInXT(cLang, aContext, _cCode_)
	# Handle: NaturallyInXT(aContext, "code")
	if isList(cLang) and isString(aContext)
		return new stzNaturalEngine("en", "", cLang, aContext)
	ok
	
	# Handle: NaturallyInXT("lang", aContext, "code")
	if isString(cLang) and isList(aContext) and isString(_cCode_)
		return new stzNaturalEngine(cLang, "", aContext, _cCode_)
	ok
	
	# Fallback
	return new stzNaturalEngine("en", "", [], "")

func NaturallyXT(aContext, _cCode_)
	# Handle: NaturallyXT(aContext, "code")
	if isList(aContext) and isString(_cCode_)
		return new stzNaturalEngine("en", "", aContext, _cCode_)
	ok
	
	# Fallback
	return new stzNaturalEngine("en", "", [], "")

func NaturallyIn(cLang, _cCode_)
	return NaturallyInXT(cLang, [], _cCode_)

func Naturally(_cCode_)
	return NaturallyXT([], _cCode_)

# LINT a natural narration WITHOUT running it: which words would not be
# understood, and what the writer probably meant. Returns
# [ :understood = TRUE/FALSE, :unresolved = [ [word, suggestion], ... ] ].

func StzNaturalLintIn(cLang, _cCode_)
	_oEngine_ = new stzNaturalEngine(cLang, "", [], "")
	return _oEngine_.Analyze(_cCode_)

	func @StzNaturalLintIn(cLang, _cCode_)
		return StzNaturalLintIn(cLang, _cCode_)

func StzNaturalLint(_cCode_)
	return StzNaturalLintIn("en", _cCode_)

# STRICT natural execution (the agent posture): any word the language does
# not understand RAISES with suggestions instead of degrading -- and an
# optional operation allow-list makes everything off the list impossible.

func NaturallyStrictIn(cLang, _cCode_, pacAllowedOps)
	oEngine = new stzNaturalEngine(cLang, "", [], "")
	oEngine.SetStrict(1)
	if isList(pacAllowedOps) and len(pacAllowedOps) > 0
		oEngine.SetAllowedOperations(pacAllowedOps)
	ok
	oEngine.Execute(_cCode_)
	return oEngine

	func @NaturallyStrictIn(cLang, _cCode_, pacAllowedOps)
		return NaturallyStrictIn(cLang, _cCode_, pacAllowedOps)

func NaturallyStrict(_cCode_)
	return NaturallyStrictIn("en", _cCode_, [])

# PREDICTIVE SUGGEST: what can be said next after a partial narration.

func StzNaturalSuggestIn(cLang, _cPartial_)
	oEngine = new stzNaturalEngine(cLang, "", [], "")
	return oEngine.SuggestNext(_cPartial_)

	func @StzNaturalSuggestIn(cLang, _cPartial_)
		return StzNaturalSuggestIn(cLang, _cPartial_)

func StzNaturalSuggest(_cPartial_)
	return StzNaturalSuggestIn("en", _cPartial_)

	func @StzNaturalSuggest(_cPartial_)
		return StzNaturalSuggest(_cPartial_)

	func @NaturallyStrict(_cCode_)
		return NaturallyStrict(_cCode_)

	func @StzNaturalLint(_cCode_)
		return StzNaturalLint(_cCode_)

#-- NATURAL ENGINE CLASS WITH CONTEXT

class stzNaturalEngine from stzObject
	@cLanguage = "en"
	@cLangCode = "en"	# normalized code ("fr" even when created as "french")
	@aIgnoredWords = []
	@aMappings = []
	@aValues = []
	@aTokenIsWord = []	# provenance: TRUE = bare word, FALSE = quoted string
				# or list literal (those must NEVER be fallback-resolved)
	@aUnresolved = []	# [ [word, suggestion], ... ] -- action-position words
				# the language could not understand (see Unresolved())
	@aNamedObjects = []	# [ [name, var, type], ... ] -- the multi-object
				# registry ('called basket' ... 'Use basket')
	@aNamedValues = []	# [ [name, var], ... ] -- VALUE bindings ('Keep it
				# as sep'); recalled as variables where values go
	@aSemanticTokens = []
	@aConsumedTokens = []	# token indexes already used as values/params
				# (needed once params may sit BEFORE their verb)
	@bStrict = 0		# strict mode: unresolved words RAISE (for agents)
	@aAllowedOps = []	# operation allow-list ([] = everything permitted):
				# a capability sandbox -- forbidden actions are
				# grammatically impossible, not just discouraged
	@aDigitMap = []		# per-language digit/punctuation normalization
	# ROLE-BASED GRAMMAR flags, declared per language pack: SOV-family
	# languages put the object/value before the creation verb and the
	# parameters before their action verb
	@bObjectBeforeCreate = 0
	@bParamsBeforeVerb = 0
	@cCurrentObject = ""
	@cCurrentVariable = ""
	@aDefineRecallState = []
	@bDebugMode = 0
	@aDebugLog = []
	@result
	@cNaturalCode = ""
	@cOriginalCode = ""
	@aContext = []

	def init(cLang, _cCode_, aContext, cContextCode)
		# Handle context-enabled calls
		if isList(aContext) and isString(cContextCode)
			@aContext = aContext
			@cOriginalCode = cContextCode
			@cLanguage = StzLower(cLang)
			# Accept any DEFINED language (code "ha" or name "hausa") --
			# IsLanguageAbbreviation() alone rejected full names.
			if @cLanguage = "" or
			   len(This.FindLanguageDefinition(@cLanguage)) = 0
				@cLanguage = "en"
			ok
			This.LoadLanguageData()

			_cInterpolated_ = This.InterpolateContext(cContextCode, aContext)
			@cNaturalCode = _cInterpolated_
			This.Execute(_cInterpolated_)
			return
		ok
		
		# Handle original patterns
		if _cCode_ != ""
			@cLanguage = StzLower(cLang)
			@cNaturalCode = _cCode_
			@cOriginalCode = _cCode_
		else
			if IsLanguageAbbreviation(cLang)
				@cLanguage = StzLower(cLang)
			else
				@cLanguage = "en"
				if cLang != ""
					@cNaturalCode = cLang
					@cOriginalCode = cLang
				ok
			ok
		ok
		
		This.LoadLanguageData()
		
		if @cNaturalCode != ""
			This.Execute(@cNaturalCode)
		ok
	
	def InterpolateContext(_cCode_, aContext)
		if len(aContext) = 0
			return _cCode_
		ok
		
		_cResult_ = _cCode_
		
		# Extract all {key} or {key.nested.path} patterns

		_aMatches_ = StzStringQ(_cCode_).SubstringsBoundedBy([ "{", "}" ])

		_nMatchesLen_ = len(_aMatches_)
		for _i_ = 1 to _nMatchesLen_
			_cKey_ = _aMatches_[_i_]
			_cValue_ = @@(This.GetContextValue(_cKey_, aContext))

			if _cValue_ != :NOT_FOUND
				_cResult_ = StzReplace(_cResult_, "{" + _cKey_ + "}", _cValue_)
			ok
		next
		
		return _cResult_
	
	def FindContextPlaceholders(_cCode_)
		_aResult_ = []
		_nLen_ = stzlen(_cCode_)
		_i_ = 1
		
		while _i_ <= _nLen_
			if @StzMid(_cCode_, _i_, _i_) = "{"
				# Find closing }
				_nEnd_ = _i_ + 1
				_nDepth_ = 1
				
				while _nEnd_ <= _nLen_ and _nDepth_ > 0
					_cChar_ = @StzMid(_cCode_, _nEnd_, _nEnd_)
					if _cChar_ = "{"
						_nDepth_++
					but _cChar_ = "}"
						_nDepth_--
					ok
					_nEnd_++
				end
				
				if _nDepth_ = 0
					_cPlaceholder_ = @StzMid(_cCode_, _i_, _nEnd_ - _i_)
					_aResult_ + _cPlaceholder_
					_i_ = _nEnd_
				else
					_i_++
				ok
			else
				_i_++
			ok
		end
		
		return _aResult_
	
	def GetContextValue(_cKey_, aContext)
		# Handle nested keys like "user.profile.name"
		if StzFindFirst(_cKey_, ".") > 0
			_aParts_ = @split(_cKey_, ".")
			_xCurrent_ = aContext
			
			_nPartsLen_ = len(_aParts_)
			for _i_ = 1 to _nPartsLen_
				_cPart_ = trim(_aParts_[_i_])
				
				# Normalize key (case-insensitive, capitalize first letter)
				_cNormalized_ = This.NormalizeKey(_cPart_)
				
				if isList(_xCurrent_)
					_xCurrent_ = This.FindInList(_xCurrent_, _cNormalized_)
					if _xCurrent_ = :NOT_FOUND
						return :NOT_FOUND
					ok
				else
					return :NOT_FOUND
				ok
			next
			
			return _xCurrent_
		else
			# Simple key lookup
			_cNormalized_ = This.NormalizeKey(_cKey_)
			return This.FindInList(aContext, _cNormalized_)
		ok
	
	def NormalizeKey(_cKey_)
		_cKey_ = trim(_cKey_)
		if StzLen(_cKey_) = 0
			return _cKey_
		ok
		
		# Capitalize first letter, lowercase rest
		return StzUpper(@StzMid(_cKey_, 1, 1)) + StzLower(StzMid(_cKey_, 2, stzlen(_cKey_) - 1))
	
	def FindInList(aList, _cKey_) #TODO// Review it
		_nLen_ = len(aList)
		for _i_ = 1 to _nLen_
			if isList(aList[_i_]) and len(aList[_i_]) = 2
				if isString(aList[_i_][1])
					_cNormalized_ = This.NormalizeKey(aList[_i_][1])
					if _cNormalized_ = _cKey_
						return aList[_i_][2]
					ok
				ok
			ok
		next
		return :NOT_FOUND

	
	def Execute(_cCode_)
		if NOT isString(_cCode_) or trim(_cCode_) = ""
			return
		ok
		
		@cNaturalCode = _cCode_
		This.AddToDebugLog("Executing natural code")
		This.AddToDebugLog("Code length: " + stzlen(_cCode_) + " chars")
		
		This.TokenizeCode(_cCode_)
	
		This.AddToDebugLog("Raw values: " + len(@aValues) + " items")
		
		This.Process()
	
	def TokenizeCode(_cCode_)
		@aValues = []
		@aTokenIsWord = []
		@aUnresolved = []
		@aNamedObjects = []
		@aNamedValues = []
		@aConsumedTokens = []
		_cCode_ = This.NormalizeForeignDigits(trim(_cCode_))
		_aTokens_ = This.SmartSplit(_cCode_)
		@aValues = _aTokens_
	
	def SmartSplit(_cCode_)
	    _aResult_ = []
	    _oStr_ = new stzString(_cCode_)
	    
	    # Find all protected sections (lists AND standalone strings)
	    _aListSections_ = _oStr_.FindSubStringsBoundedByIBZZ([ "[", "]" ])
	    
	    # For strings, only find those OUTSIDE of lists.
	    # NOTE: BoundedByIBZZ with identical single-char bounds OVERLAPS by
	    # design (each closer is reused as the next opener) -- right for
	    # substring analytics, wrong for quote pairing: with six quotes it
	    # would protect the gaps BETWEEN values too. Pair quotes manually
	    # (1st-2nd, 3rd-4th, ...) instead.
	    _aAllQuoteSections_ = Merge([
	        This.PairedQuoteSections(_cCode_, '"'),
	        This.PairedQuoteSections(_cCode_, "'")
	    ])
	    
	    # Filter out quote sections that are inside list sections
	    _aStringSections_ = []
	    _nAllQuoteSections1Len_ = len(_aAllQuoteSections_)
	    for _iLoopAllQuoteSections1_ = 1 to _nAllQuoteSections1Len_
	    	_aQuoteSection_ = _aAllQuoteSections_[_iLoopAllQuoteSections1_]
	        _bInsideList_ = FALSE
	        _nListSections1Len_ = len(_aListSections_)
	        for _iLoopListSections1_ = 1 to _nListSections1Len_
	        	_aListSection_ = _aListSections_[_iLoopListSections1_]
	            if _aQuoteSection_[1] >= _aListSection_[1] and _aQuoteSection_[2] <= _aListSection_[2]
	                _bInsideList_ = TRUE
	                exit
	            ok
	        next
	        if NOT _bInsideList_
	            _aStringSections_ + _aQuoteSection_
	        ok
	    next
	    
	    _aProtectedSections_ = Merge([_aListSections_, _aStringSections_])
	    
	    # Get splittable sections (the gaps around the protected ones).
	    # NOTE: FindAntiSectionsZZ() is the find-form and takes a SUBSTRING
	    # since the finder refactor -- the section-form is AntiSectionsZZ().
	    _aSplittableSections_ = _oStr_.AntiSectionsZZ(_aProtectedSections_)
	    
	    # Merge and sort by position
	    _aAllSections_ = []

	    _nLen_ = len(_aSplittableSections_)
	    for _i_ = 1 to _nLen_
		_aPair_ = _aSplittableSections_[_i_]
	        _aAllSections_ + [:pos = _aPair_[1], :type = "splittable", :pair = _aPair_]
	    next

	    _nLen_ = len(_aListSections_)
	    for _i_ = 1 to _nLen_
		_aPair_ = _aListSections_[_i_]
	        _aAllSections_ + [:pos = _aPair_[1], :type = "list", :pair = _aPair_]
	    next

	    _nLen_ = len(_aStringSections_)
	    for _i_ = 1 to _nLen_
		_aPair_ = _aStringSections_[_i_]
	        _aAllSections_ + [:pos = _aPair_[1], :type = "string", :pair = _aPair_]
	    next
	    
	    _aAllSections_ = SortListsOn(_aAllSections_, 1)
	    _nLen_ = len(_aAllSections_)

	    # Process in order

	    for _i_ = 1 to _nLen_
		_aSection_ = _aAllSections_[_i_]
	        _aPair_ = _aSection_[:pair]
	        _cSection_ = _oStr_.Section(_aPair_[1], _aPair_[2])
	        
	        if _aSection_[:type] = "splittable"
	            # ALL whitespace separates words (multiline narrations:
	            # newlines/tabs must not glue "it\nreverse" into one token)
	            _cSection_ = StzReplace(_cSection_, char(13), " ")
	            _cSection_ = StzReplace(_cSection_, char(10), " ")
	            _cSection_ = StzReplace(_cSection_, char(9), " ")
	            _acWords_ = @split(_cSection_, " ")
		    _nLenWords_ = len(_acWords_)

		    for _j_ = 1 to _nLenWords_
	                if trim(_acWords_[_j_]) != ""
	                    _aResult_ + _acWords_[_j_]
	                    @aTokenIsWord + TRUE
	                ok
	            next

	        but _aSection_[:type] = "list"
	            # nested brackets can mis-pair the section -- degrade to a
	            # literal string token instead of dying in eval
	            try
	                _cCode_ = '_aResult_ + ' + _cSection_
	                eval(_cCode_)
	            catch
	                _aResult_ + _cSection_
	            done
	            @aTokenIsWord + FALSE

	        else  # string
	            # Remove quotes -- StzMid is (start, COUNT): keep len-2 chars
	            _aResult_ + @StzMid(_cSection_, 2, stzlen(_cSection_) - 2)
	            @aTokenIsWord + FALSE
	        ok
	    next
	    
	    return _aResult_
	
	# Only these SHAPES may be eval'd as list literals: a bracketed
	# [ ... ] form, or a pure numeric range like 1:5. Prose that
	# isListInString() mistakes for a range ("note:") is rejected.

	def LooksEvalSafeList(_cVal_)
		_cVal_ = trim(_cVal_)
		if StzLeft(_cVal_, 1) = "[" and StzRight(_cVal_, 1) = "]"
			return 1
		ok
		_nPos_ = StzFindFirst(_cVal_, ":")
		if _nPos_ > 1 and _nPos_ < StzLen(_cVal_)
			_cL_ = StzLeft(_cVal_, _nPos_ - 1)
			_cR_ = StzRight(_cVal_, StzLen(_cVal_) - _nPos_)
			if isdigit(_cL_) and isdigit(_cR_)
				return 1
			ok
		ok
		return 0

	# Non-overlapping quote pairing: positions 1-2, 3-4, ... form the
	# quoted sections. An unmatched trailing quote is simply ignored.
	# An apostrophe with a LETTER on both sides is part of a word
	# ("it's", "don't"), not a string delimiter.

	def PairedQuoteSections(_cCode_, cQuote)
		_aRaw_ = StzFind(cQuote, _cCode_)
		_aPos_ = []
		_nRaw_ = len(_aRaw_)
		_nStrLen_ = StzLen(_cCode_)
		for _k_ = 1 to _nRaw_
			p = _aRaw_[_k_]
			if p > 1 and p < _nStrLen_
				if isalpha(StzMid(_cCode_, p - 1, 1)) and
				   isalpha(StzMid(_cCode_, p + 1, 1))
					loop	# contraction, keep it inside the word
				ok
			ok
			_aPos_ + p
		next
		_aOut_ = []
		_nLen_ = len(_aPos_)
		_k_ = 1
		while _k_ + 1 <= _nLen_
			_aOut_ + [ _aPos_[_k_], _aPos_[_k_+1] ]
			_k_ += 2
		end
		return _aOut_

	# Normalize the language's digits and list punctuation OUTSIDE quoted
	# strings (Arabic-Indic numerals in a value list must become ASCII for
	# the list eval; a quoted string keeps its script untouched).

	def NormalizeForeignDigits(_cCode_)
		if len(@aDigitMap) = 0
			return _cCode_
		ok
		_cOut_ = ""
		_cChunk_ = ""
		_n_ = len(_cCode_)
		_i_ = 1
		while _i_ <= _n_
			_c_ = _cCode_[_i_]
			if _c_ = "'" or _c_ = char(34)
				# contraction guard: a letter-flanked apostrophe is
				# part of a word, not a string delimiter
				_bDelim_ = TRUE
				if _c_ = "'" and _i_ > 1 and _i_ < _n_
					if isalpha(_cCode_[_i_-1]) and isalpha(_cCode_[_i_+1])
						_bDelim_ = FALSE
					ok
				ok
				if _bDelim_
					_cOut_ += This.MapDigits(_cChunk_)
					_cChunk_ = ""
					_q_ = _c_
					_cOut_ += _c_
					_i_++
					while _i_ <= _n_
						_cOut_ += _cCode_[_i_]
						if _cCode_[_i_] = _q_
							exit
						ok
						_i_++
					end
					_i_++
					loop
				ok
			ok
			_cChunk_ += _c_
			_i_++
		end
		_cOut_ += This.MapDigits(_cChunk_)
		return _cOut_

	def MapDigits(_cChunk_)
		if _cChunk_ = ""
			return _cChunk_
		ok
		_n_ = len(@aDigitMap)
		for _k_ = 1 to _n_
			_cChunk_ = StzReplace(_cChunk_, @aDigitMap[_k_][1], @aDigitMap[_k_][2])
		next
		return _cChunk_

	# A word without clinging trailing punctuation ("empty?" -> "empty").
	# BYTE-based whole-mark matching (StzLeft/StzRight take byte counts
	# while StzLen counts codepoints -- mixing them mangles multibyte
	# words; exact byte-suffix comparison is UTF-8-safe).

	def StripEdgePunct(cWord)
		if NOT isString(cWord)
			return cWord
		ok
		_cW_ = trim(cWord)
		_aPunct_ = [ "?", "!", ".", ",", ";", ":",
		           StzChar(1567), StzChar(1548) ]	# + Arabic ? and ,
		_nP_ = len(_aPunct_)
		_bAgain_ = TRUE
		while _bAgain_ and len(_cW_) > 0
			_bAgain_ = FALSE
			for p = 1 to _nP_
				_cM_ = _aPunct_[p]
				_nM_ = len(_cM_)
				if len(_cW_) >= _nM_ and right(_cW_, _nM_) = _cM_
					_cW_ = left(_cW_, len(_cW_) - _nM_)
					_bAgain_ = TRUE
					exit
				ok
			next
		end
		return _cW_

	# MULTI-WORD PHRASE resolution: head word + up to two following
	# content words (ignored words skipped), longest EXACT method-name
	# join wins -- "remove [its] duplicates" -> removeduplicates,
	# "is [it] empty" -> isempty. Returns [ semanticId, nextIndex,
	# matchedPhrase ] or [ "", 0, "" ]. Only consulted when at least one
	# word is dictionary-unknown, so pure-dictionary programs never pay
	# the lazy lexicon growth.

	def PhraseResolve(nStart)
		# tokens are CANONICALIZED per language (attached articles and
		# pronoun suffixes stripped), so the inflected Arabic
		# "remove its-duplicates" joins to the same form as the pack's
		# "remove the-duplicates". Identity for English.
		_cHeadRaw_ = StzLower(This.StripEdgePunct(@aValues[nStart]))
		_bHeadUnknown_ = ( This.ToSemantic(_cHeadRaw_) = "" )
		_aWords_ = [ StzSemLangCanonToken(@cLangCode, _cHeadRaw_) ]
		_aEnds_ = [ nStart ]
		_nLen_ = len(@aValues)
		_j_ = nStart + 1
		while _j_ <= _nLen_ and len(_aWords_) < 3 and (_j_ - nStart) <= 4
			if NOT ( len(@aTokenIsWord) >= _j_ and @aTokenIsWord[_j_] = TRUE )
				exit
			ok
			if NOT isString(@aValues[_j_])
				exit
			ok
			_cW_ = StzSemLangNormToken(@cLangCode,
				StzLower(This.StripEdgePunct(@aValues[_j_])))
			if This.IsIgnoredWord(_cW_)
				_j_++
				loop
			ok
			_aWords_ + StzSemLangCanonToken(@cLangCode, _cW_)
			_aEnds_ + _j_
			_j_++
		end

		_nW_ = len(_aWords_)
		if _nW_ < 2
			return [ "", 0, "" ]
		ok

		_bUnknown_ = FALSE
		for _k_ = 1 to _nW_
			if This.ToSemantic(_aWords_[_k_]) = ""
				_bUnknown_ = TRUE
				exit
			ok
		next
		if NOT _bUnknown_
			return [ "", 0, "" ]
		ok

		for n = _nW_ to 2 step -1
			_cJoin_ = ""
			_cShown_ = ""
			for _k_ = 1 to n
				_cJoin_ += _aWords_[_k_]
				_cShown_ += _aWords_[_k_]
				if _k_ < n
					_cShown_ += " "
				ok
			next
			_cId_ = StzSemanticExactIdInLang(@cLangCode, _cJoin_)
			if _cId_ != ""
				return [ _cId_, _aEnds_[n] + 1, _cShown_ ]
			ok
		next

		# no exact join: for PACK languages, let the shared IDF ranker
		# decide from the rare content words ("vire les doublons" -- the
		# unlisted verb contributes nothing, the rare word carries it).
		# Only when the HEAD is dictionary-unknown: a known head (a
		# CREATE verb, say) must never be swallowed into a scored phrase.
		if @cLangCode != "en" and _bHeadUnknown_
			_cId_ = StzResolveSemanticPhraseInLang(@cLangCode, _aWords_)
			if _cId_ != ""
				_cShown_ = ""
				for _k_ = 1 to _nW_
					_cShown_ += _aWords_[_k_]
					if _k_ < _nW_
						_cShown_ += " "
					ok
				next
				return [ _cId_, _aEnds_[_nW_] + 1, _cShown_ ]
			ok
		ok
		return [ "", 0, "" ]

	def LoadLanguageData()
		_aLangDef_ = This.FindLanguageDefinition(@cLanguage)
		if len(_aLangDef_) > 0
			@cLangCode = StzLower(_aLangDef_[:code])
			if HasKey(_aLangDef_, :ignored_words)
				@aIgnoredWords = _aLangDef_[:ignored_words]
			ok
			if HasKey(_aLangDef_, :semantic_mappings)
				@aMappings = _aLangDef_[:semantic_mappings]
			ok
			# word-order grammar (SOV-family packs declare these)
			@bObjectBeforeCreate = 0
			@bParamsBeforeVerb = 0
			if HasKey(_aLangDef_, :object_before_create)
				@bObjectBeforeCreate = _aLangDef_[:object_before_create]
			ok
			if HasKey(_aLangDef_, :params_before_verb)
				@bParamsBeforeVerb = _aLangDef_[:params_before_verb]
			ok
			@aDigitMap = []
			if HasKey(_aLangDef_, :digit_map)
				@aDigitMap = _aLangDef_[:digit_map]
			ok
		ok

	# May unknown words of the active language be resolved at all?
	# English always (the unified lexicon); others when a pack exists.

	def LangResolvable()
		if @cLangCode = "en"
			return 1
		ok
		return StzHasLanguagePack(@cLangCode)

	def SetStrict(pbOn)
		@bStrict = pbOn

	def SetAllowedOperations(pacIds)
		@aAllowedOps = pacIds
	
	def FindLanguageDefinition(_cCode_)
		_nLen_ = len($aLanguageDefinitions)
		for _i_ = 1 to _nLen_
			_aLang_ = $aLanguageDefinitions[_i_]
			if _aLang_[:code] = _cCode_ or _aLang_[:name] = _cCode_
				return _aLang_
			ok
		next
		return []
	
	def Process()
		@aSemanticTokens = This.ConvertToSemanticTokens()

		# STRICT mode (the agent posture): a narration with ANY word the
		# language could not understand must not run half-blind -- raise
		# with machine-readable diagnostics so the caller self-corrects
		if @bStrict and len(@aUnresolved) > 0
			_cMsg_ = "Strict natural mode: not understood:"
			_nU_ = len(@aUnresolved)
			for _i_ = 1 to _nU_
				_cMsg_ += " '" + @aUnresolved[_i_][1] + "'"
				if @aUnresolved[_i_][2] != ""
					_cMsg_ += " (did you mean '" + @aUnresolved[_i_][2] + "'?)"
				ok
			next
			StzRaise(_cMsg_)
		ok
		This.AddToDebugLog("Tokens: " + len(@aSemanticTokens))
		
		_cCode_ = This.GenerateCodeFromSemantics()

		This.AddToDebugLog("Generated code:")
		This.AddToDebugLog(_cCode_)
		
		if trim(_cCode_) != ""
			eval(_cCode_)
		ok
	
	def ConvertToSemanticTokens()
		_aTokens_ = []

		_nLen_ = len(@aValues)
		This.AddToDebugLog("Converting to semantic tokens")

		_i_ = 1
		while _i_ <= _nLen_
			_cValue_ = @aValues[_i_]

			if isString(_cValue_) and isListInString(_cValue_) and
			   This.LooksEvalSafeList(_cValue_)
				# isListInString() can false-positive on plain prose
				# ("note:" reads as range syntax) -- LooksEvalSafeList()
				# filters those, and if the eval still fails we fall
				# through to normal word handling instead of dying.
				_bParsed_ = FALSE
				try
					_cCode_ = '_aListValue_ = ' + _cValue_
					eval(_cCode_)
					_bParsed_ = TRUE
				catch
				done
				if _bParsed_
					_aTokens_ + [:type = "literal", :value = _aListValue_, :word = 0]
					This.AddToDebugLog("List literal parsed: " + stzlen(_aListValue_) + " items")
					_i_++
					loop
				ok
			ok

			if NOT isString(_cValue_)
				_cValue_ = @@(_cValue_)
			ok

			This.AddToDebugLog("Processing: '" + _cValue_ + "'")

			# Provenance: quoted strings and list literals are VALUES --
			# they are never ignored-word-filtered and never interpreted
			# ('Create a string with "this"' must keep "this" even though
			# the bare word this is an ignored word; 'with "show"' must
			# not become OUTPUT_DISPLAY).
			_bWord_ = TRUE
			if len(@aTokenIsWord) >= _i_
				_bWord_ = @aTokenIsWord[_i_]
			ok

			if NOT _bWord_
				_aTokens_ + [:type = "literal", :value = _cValue_, :word = 0]
				This.AddToDebugLog("Literal (quoted value)")
				_i_++
				loop
			ok

			# interpretation looks at the word without clinging
			# punctuation ("empty?" reads as "empty") and without the
			# language's marks (Arabic tanween/shadda/tatweel: the
			# writer's diacritized word must match the plain dictionary)
			_cCheck_ = StzSemLangNormToken(@cLangCode,
				This.StripEdgePunct(_cValue_))

			# MULTI-WORD PHRASE resolution (longest exact match first):
			# "Remove its duplicates" -> removeduplicates, "Uppercase the
			# substring" -> uppercasesubstring, "Is it empty" -> isempty --
			# and in any REGISTERED language: "enleve les doublons" (fr) /
			# Arabic equivalents match their pack's phrase map the same
			# way. Deterministic (exact joins only), and value positions
			# are excluded by the same FallbackEligible guard.
			if This.LangResolvable() and This.FallbackEligible(_aTokens_)
				_aPh_ = This.PhraseResolve(_i_)
				if _aPh_[1] != ""
					_aTokens_ + [:type = "semantic", :value = _aPh_[1], :original = _aPh_[3]]
					This.AddToDebugLog("Phrase: '" + _aPh_[3] + "' -> " + _aPh_[1])
					_i_ = _aPh_[2]
					loop
				ok
			ok

			if This.IsIgnoredWord(_cCheck_)
				This.AddToDebugLog("Ignored")
				_i_++
				loop
			ok

			_cSemantic_ = This.ToSemantic(_cCheck_)

			# Unified-lexicon fallback (natural <-> reflect unification):
			# a bare WORD the dictionary doesn't know (quoted values never
			# reach here -- see the provenance branch above -- and value
			# positions are excluded by FallbackEligible) is resolved
			# against the shared semantic lexicon (en) or the language's
			# registered pack (fr, ar, ...).
			_bEligible_ = This.FallbackEligible(_aTokens_)
			if _cSemantic_ = "" and This.LangResolvable() and _bEligible_
				_cSemantic_ = StzResolveSemanticInLang(@cLangCode, _cCheck_)
				if _cSemantic_ != ""
					This.AddToDebugLog("Unified lexicon: '" + _cCheck_ + "' -> " + _cSemantic_)
				ok
			ok

			if _cSemantic_ != ""
				_bLiteral_ = This.ShouldTreatAsLiteral(_aTokens_, _cSemantic_, _cValue_)

				if _bLiteral_
					_aTokens_ + [:type = "literal", :value = _cValue_, :word = 1]
					This.AddToDebugLog("Literal (context)")
				else
					_aTokens_ + [:type = "semantic", :value = _cSemantic_, :original = _cValue_]
					This.AddToDebugLog("Semantic: " + _cSemantic_)
				ok
			else
				_aTokens_ + [:type = "literal", :value = _cValue_, :word = 1]
				This.AddToDebugLog("Literal")
				# UNDERSTANDABILITY: an action-position word nobody
				# understood -- report it, with the nearest known
				# word as a suggestion (never blocks execution).
				# _bEligible_ was captured BEFORE this literal joined
				# _aTokens_, so it judges the word's own position.
				if This.LangResolvable() and _bEligible_ and
				   StzLen(_cCheck_) >= 3
					_cSug_ = StzSuggestWord(@cLangCode, _cCheck_)
					@aUnresolved + [ _cCheck_, _cSug_ ]
				ok
			ok
			_i_++
		end

		return _aTokens_
	
	def ShouldTreatAsLiteral(_aTokens_, _cSemantic_, _cValue_)
		_nLen_ = len(_aTokens_)
		if _nLen_ = 0
			return 0
		ok
		
		_aLast_ = _aTokens_[_nLen_]
		
		if _aLast_[:type] = "semantic"
			# a VALUE or a NAME: even a dictionary word ('called box')
			# stays literal here. NB: in postpositional grammars the
			# VALUE precedes its indicator ("[...] ile"), so the word
			# AFTER the indicator is ordinary -- no forcing there.
			if ( _aLast_[:value] = "VALUE_INDICATOR" and @bObjectBeforeCreate = 0 ) or
			   _aLast_[:value] = "NAME_INDICATOR" or
			   _aLast_[:value] = "SWITCH_OBJECT" or
			   _aLast_[:value] = "KEEP_INDICATOR"
				return 1
			ok
		ok

		if _aLast_[:type] = "literal" and _nLen_ >= 2
			_aBeforeLast_ = _aTokens_[_nLen_-1]
			if _aBeforeLast_[:type] = "semantic" and StzLeft(_aBeforeLast_[:value], 7) = "METHOD_"
				_aOp_ = This.GetSemanticOperation(_aBeforeLast_[:value])
				if len(_aOp_) > 0 and HasKey(_aOp_, :requires_params) and _aOp_[:requires_params] > 0
					return 1
				ok
			ok
		ok
		
		return 0
	
	# May an unknown word at the current position be fallback-resolved to an
	# action? NO whenever the word sits in a VALUE position: right after an
	# OBJECT_* (it is the creation value: Create a string with capitals),
	# right after a VALUE_INDICATOR, or right after a METHOD_* that still
	# expects parameters (Replace dot with underscore). In all those spots
	# the word must stay a literal -- resolution would corrupt the program.

	def FallbackEligible(_aTokens_)
		_nLen_ = len(_aTokens_)
		if _nLen_ = 0
			return 1	# first token of a block: action position
		ok

		_aLast_ = _aTokens_[_nLen_]
		if _aLast_[:type] = "semantic"
			_cVal_ = _aLast_[:value]

			if StzLeft(_cVal_, 7) = "OBJECT_" or
			   ( _cVal_ = "VALUE_INDICATOR" and @bObjectBeforeCreate = 0 ) or
			   _cVal_ = "NAME_INDICATOR" or _cVal_ = "SWITCH_OBJECT" or
			   _cVal_ = "KEEP_INDICATOR"
				return 0
			ok

			if StzLeft(_cVal_, 7) = "METHOD_"
				_aOp_ = This.GetSemanticOperation(_cVal_)
				if len(_aOp_) > 0 and HasKey(_aOp_, :requires_params) and
				   _aOp_[:requires_params] > 0
					return 0
				ok
			ok
		ok

		return 1

	def IsIgnoredWord(cWord)
		return StzFindFirst(@aIgnoredWords, StzLower(cWord)) > 0
	
	def ToSemantic(cWord)
		_cLower_ = StzLower(cWord)

		_bDefine_ = StzLeft(_cLower_, 1) = "@"
		_bRecall_ = StzRight(_cLower_, 1) = "@"
		
		if _bDefine_
			_cLower_ = @StzMid(_cLower_, 2, stzlen(_cLower_) - 1)
		but _bRecall_
			_cLower_ = StzLeft(_cLower_, stzlen(_cLower_) - 1)
		ok
		
		_nLen_ = len(@aMappings)
		for _i_ = 1 to _nLen_
			_aMap_ = @aMappings[_i_]
			if _aMap_[:natural] = _cLower_
				_cSemantic_ = _aMap_[:semantic]
				if _bDefine_
					return "@" + _cSemantic_
				but _bRecall_
					return _cSemantic_ + "@"
				ok
				return _cSemantic_
			ok
		next
		return ""
	
	def GenerateCodeFromSemantics()
		_aCodeLines_ = []
		_nLen_ = len(@aSemanticTokens)
		# consumption tracking is per-GENERATION (Code() regenerates)
		@aConsumedTokens = []
		@aNamedObjects = []
		@aNamedValues = []

		_i_ = 1

		while _i_ <= _nLen_
			_aToken_ = @aSemanticTokens[_i_]
			
			if _aToken_[:type] = "semantic"
				_cSemantic_ = _aToken_[:value]
				_nLenSem_ = stzLen(_cSemantic_)

				if StzLeft(_cSemantic_, 1) = "@"
					_cClean_ = @StzMid(_cSemantic_, 2, _nLenSem_ - 1)
					@aDefineRecallState + [:semantic = _cClean_, :index = _i_]
					_i_++
					loop
				ok
				
				if StzRight(_cSemantic_, 1) = "@"
					_cClean_ = StzLeft(_cSemantic_, _nLenSem_ - 1)
					_aResult_ = This.ProcessMethodWithModifiers(_i_, _cClean_)
					if stzlen(_aResult_[:code]) > 0
						_aCodeLines_ + _aResult_[:code]
					ok
					_i_ = _aResult_[:next_index]
					loop
				ok
				
				if _cSemantic_ = "CREATE_OBJECT"
					_aResult_ = This.ProcessObjectCreation(_i_)
					if stzlen(_aResult_[:code]) > 0
						_aCodeLines_ + _aResult_[:code]
					ok
					_i_ = _aResult_[:next_index]

				but _cSemantic_ = "NAME_INDICATOR"
					# '... called basket': alias the live object under
					# o_<name> (Ring objects assign by REFERENCE, so the
					# alias survives the default var being rebound by a
					# later creation) and register it
					_aResult_ = This.ProcessObjectNaming(_i_)
					if stzlen(_aResult_[:code]) > 0
						_aCodeLines_ + _aResult_[:code]
					ok
					_i_ = _aResult_[:next_index]

				but _cSemantic_ = "SWITCH_OBJECT"
					# 'Use basket': the named object becomes the live one
					_i_ = This.ProcessObjectSwitch(_i_)

				but _cSemantic_ = "KEEP_INDICATOR"
					# 'Keep it as sep': bind the current result -- the
					# last query's answer if one just ran, else the live
					# object's content -- to a named VALUE variable
					_bQ_ = FALSE
					_nCL2_ = len(_aCodeLines_)
					if _nCL2_ > 0 and StzLeft(_aCodeLines_[_nCL2_], 10) = "@result = "
						_bQ_ = TRUE
					ok
					_aResult_ = This.ProcessValueKeep(_i_, _bQ_)
					if stzlen(_aResult_[:code]) > 0
						_aCodeLines_ + _aResult_[:code]
					ok
					_i_ = _aResult_[:next_index]

				but StzLeft(_cSemantic_, 7) = "METHOD_"
					_aResult_ = This.ProcessMethod(_i_, _cSemantic_)
					if stzlen(_aResult_[:code]) > 0
						_aCodeLines_ + _aResult_[:code]
					ok
					_i_ = _aResult_[:next_index]
					
				but _cSemantic_ = "OUTPUT_DISPLAY"
					_aOp_ = This.GetSemanticOperation(_cSemantic_)
					if len(_aOp_) > 0
						_cCode_ = StzReplace(_aOp_[:stz_signature], "@var", @cCurrentVariable)
						_aCodeLines_ + _cCode_
					ok
					_i_++
				else
					_i_++
				ok
			else
				_i_++
			ok
		end

		if trim(@cCurrentVariable) = ""
			raise("Unsupported object type!")
		ok

		# the natural contract for @result: the last thing produced. A
		# trailing QUERY line already set it; otherwise it is the live
		# object's final content.
		_cCode_ = JoinXT(_aCodeLines_, StzChar(10))
		_nCL_ = len(_aCodeLines_)
		if NOT ( _nCL_ > 0 and StzLeft(_aCodeLines_[_nCL_], 10) = "@result = " )
			_cCode_ += StzChar(10) + "@result = " + @cCurrentVariable + ".Content()"
		ok
		return _cCode_
	
	def FindDefineIndex(_cSemantic_)
		_nLen_ = len(@aDefineRecallState)
		for _i_ = 1 to _nLen_
			if @aDefineRecallState[_i_][:semantic] = _cSemantic_
				return @aDefineRecallState[_i_][:index]
			ok
		next
		return 0
	
	def ProcessObjectCreation(nIndex)

		_nLen_ = len(@aSemanticTokens)
		_cObjectType_ = ""
		_cValue_ = ""
		_cValRef_ = ""
		_nNextIndex_ = nIndex + 1

		if @bObjectBeforeCreate = 1
			# VERB-FINAL grammar (SOV family): "[ 3, 1, 3 ] with a list
			# create" -- the object word and its value sit BEFORE the
			# creation verb: scan backward for the nearest OBJECT_, then
			# the nearest unconsumed literal before the verb
			for _i_ = nIndex - 1 to 1 step -1
				_aToken_ = @aSemanticTokens[_i_]
				if _aToken_[:type] = "semantic" and StzLeft(_aToken_[:value], 7) = "OBJECT_"
					_cObjectType_ = _aToken_[:value]
					exit
				ok
			next
			for _j_ = nIndex - 1 to 1 step -1
				_aNextToken_ = @aSemanticTokens[_j_]
				if _aNextToken_[:type] = "literal" and
				   ring_find(@aConsumedTokens, _j_) = 0
					_cValue_ = _aNextToken_[:value]
					_cValRef_ = This.ValueRefOf(_aNextToken_)
					@aConsumedTokens + _j_
					exit
				ok
			next
			_nNextIndex_ = nIndex + 1
		else
			for _i_ = nIndex+1 to _nLen_
				_aToken_ = @aSemanticTokens[_i_]
				if _aToken_[:type] = "semantic" and StzLeft(_aToken_[:value], 7) = "OBJECT_"
					_cObjectType_ = _aToken_[:value]

					for _j_ = _i_+1 to _nLen_
						_aNextToken_ = @aSemanticTokens[_j_]
						if _aNextToken_[:type] = "literal"
							_cValue_ = _aNextToken_[:value]
							_cValRef_ = This.ValueRefOf(_aNextToken_)
							@aConsumedTokens + _j_
							_nNextIndex_ = _j_ + 1
							exit 2
						ok
					next
				ok
			next
		ok

		if _cObjectType_ != ""
			_aOp_ = This.GetSemanticOperation(_cObjectType_)

			if len(_aOp_) > 0
				@cCurrentObject = _aOp_[:object_type]
				@cCurrentVariable = _aOp_[:variable]
				_cConstructor_ = _aOp_[:constructor]
				
				if _cValRef_ != ""
					# a RECALLED value: construct from the bound variable
					_cConstructor_ = StzReplace(_cConstructor_, "@", _cValRef_)
				but isListInString(_cValue_)
					_cConstructor_ = StzReplace(_cConstructor_, "@", _cValue_)
				else

					_cConstructor_ = StzReplace(_cConstructor_, "@", '"' + _cValue_ + '"')
				ok
				
				_cCode_ = @cCurrentVariable + " = " + _cConstructor_
				return [:code = _cCode_, :next_index = _nNextIndex_]
			ok
		ok
		
		_aResult_ = [:code = "", :next_index = nIndex+1]
		return _aResult_

	# '... called <name>': alias the CURRENT object as o_<name>. The next
	# literal token after NAME_INDICATOR is the name (guards make sure it
	# stayed literal even if it collides with a dictionary word).

	def ProcessObjectNaming(nIndex)
		_nLen_ = len(@aSemanticTokens)
		for _k_ = nIndex + 1 to _nLen_
			_aToken_ = @aSemanticTokens[_k_]
			if _aToken_[:type] = "literal" and isString(_aToken_[:value])
				# the registry KEY keeps the name as written (any
				# script); the Ring VARIABLE must stay ASCII, so
				# non-Latin names get a generated one
				_cName_ = StzLower(trim(_aToken_[:value]))
				if _cName_ = "" or trim(@cCurrentVariable) = ""
					exit
				ok
				_cVar_ = This.SanitizedName(_cName_)
				if _cVar_ != ""
					_cVar_ = "o_" + _cVar_
				else
					_cVar_ = "o_named" + (len(@aNamedObjects) + 1)
				ok
				@aNamedObjects + [ _cName_, _cVar_, @cCurrentObject ]
				_cAlias_ = _cVar_ + " = " + @cCurrentVariable
				@cCurrentVariable = _cVar_
				This.AddToDebugLog("Named object: " + _cName_ + " -> " + _cVar_)
				return [:code = _cAlias_, :next_index = _k_ + 1]
			ok
			exit
		next
		return [:code = "", :next_index = nIndex + 1]

	# 'Use <name>': switch the live object to a previously named one.
	# Unknown names are skipped with a debug note (permissive execution).

	def ProcessObjectSwitch(nIndex)
		_nLen_ = len(@aSemanticTokens)
		for _k_ = nIndex + 1 to _nLen_
			_aToken_ = @aSemanticTokens[_k_]
			if _aToken_[:type] = "literal" and isString(_aToken_[:value])
				_cName_ = StzLower(trim(_aToken_[:value]))
				_nReg_ = len(@aNamedObjects)
				for _r_ = 1 to _nReg_
					if @aNamedObjects[_r_][1] = _cName_
						@cCurrentVariable = @aNamedObjects[_r_][2]
						@cCurrentObject = @aNamedObjects[_r_][3]
						This.AddToDebugLog("Switched to: " + _cName_)
						return _k_ + 1
					ok
				next
				This.AddToDebugLog("Unknown object name: " + _cName_)
				return _k_ + 1
			ok
			exit
		next
		return nIndex + 1

	# 'Keep it as <name>': bind the current result to a VALUE variable.
	# pbFromQuery says whether a query line just set @result.

	def ProcessValueKeep(nIndex, pbFromQuery)
		_nLen_ = len(@aSemanticTokens)
		for _k_ = nIndex + 1 to _nLen_
			_aToken_ = @aSemanticTokens[_k_]
			if _aToken_[:type] = "literal" and isString(_aToken_[:value])
				_cName_ = StzLower(trim(_aToken_[:value]))
				if _cName_ = "" or trim(@cCurrentVariable) = ""
					exit
				ok
				_cVar_ = This.SanitizedName(_cName_)
				if _cVar_ != ""
					_cVar_ = "v_" + _cVar_
				else
					_cVar_ = "v_value" + (len(@aNamedValues) + 1)
				ok
				@aNamedValues + [ _cName_, _cVar_ ]
				if pbFromQuery
					_cBind_ = _cVar_ + " = @result"
				else
					_cBind_ = _cVar_ + " = " + @cCurrentVariable + ".Content()"
				ok
				This.AddToDebugLog("Kept value: " + _cName_ + " -> " + _cVar_)
				return [:code = _cBind_, :next_index = _k_ + 1]
			ok
			exit
		next
		return [:code = "", :next_index = nIndex + 1]

	# RECALL: the bound variable for a literal token, or "" -- only bare
	# WORDS recall (a quoted 'sep' is data, never a reference).

	def ValueRefOf(paToken)
		if paToken[:type] != "literal" or NOT isString(paToken[:value])
			return ""
		ok
		if NOT ( HasKey(paToken, :word) and paToken[:word] = 1 )
			return ""
		ok
		_cName_ = StzLower(trim(paToken[:value]))
		_nReg_ = len(@aNamedValues)
		for _r_ = 1 to _nReg_
			if @aNamedValues[_r_][1] = _cName_
				return @aNamedValues[_r_][2]
			ok
		next
		return ""

	def SanitizedName(_cValue_)
		_cOut_ = ""
		_cLow_ = StzLower(trim(_cValue_))
		_nL_ = len(_cLow_)
		for _k_ = 1 to _nL_
			_cCh_ = _cLow_[_k_]
			_nA_ = ascii(_cCh_)
			if (_nA_ >= 97 and _nA_ <= 122) or (_nA_ >= 48 and _nA_ <= 57) or _nA_ = 95
				_cOut_ += _cCh_
			ok
		next
		return _cOut_

	def NamedObjects()
		return @aNamedObjects

	def ProcessMethod(nIndex, _cSemantic_)
		This.AddToDebugLog("Processing method: " + _cSemantic_)

		_aOp_ = This.GetSemanticOperation(_cSemantic_)
		if len(_aOp_) = 0
			return [:code = "", :next_index = nIndex+1]
		ok

		# CAPABILITY SANDBOX: with an allow-list set, an operation off
		# the list is grammatically impossible -- strict mode raises,
		# permissive mode skips with a note
		if len(@aAllowedOps) > 0 and ring_find(@aAllowedOps, _cSemantic_) = 0
			if @bStrict
				StzRaise("Operation not permitted in this world: " + _cSemantic_)
			ok
			This.AddToDebugLog("Blocked by allow-list: " + _cSemantic_)
			return [:code = "", :next_index = nIndex+1]
		ok

		# GROWN operations carry the class they were harvested from --
		# applying a stzList verb to a stzString object would R14, so
		# enforce :applies_to for them (hand-authored ops keep their
		# historical advisory behavior).
		if HasKey(_aOp_, :grown) and HasKey(_aOp_, :applies_to)
			_bApplies_ = FALSE
			_aTo_ = _aOp_[:applies_to]
			_nTo_ = len(_aTo_)
			for _i_ = 1 to _nTo_
				if lower(_aTo_[_i_]) = lower(@cCurrentObject)
					_bApplies_ = TRUE
					exit
				ok
			next
			if NOT _bApplies_
				This.AddToDebugLog("Skipped " + _cSemantic_ + " -- not applicable to " + @cCurrentObject)
				return [:code = "", :next_index = nIndex+1]
			ok
		ok

		_cCode_ = StzReplace(_aOp_[:stz_signature], "@var", @cCurrentVariable)

		# QUERY operations (passive / predicate forms) RETURN a value
		# instead of mutating: their call becomes the current @result
		# ("Is it empty", "its Reversed copy"). If a query is the LAST
		# step, @result keeps its value (see GenerateCodeFromSemantics).
		if HasKey(_aOp_, :kind) and _aOp_[:kind] = "query"
			_cCode_ = "@result = " + _cCode_
		ok

		if HasKey(_aOp_, :requires_params) and _aOp_[:requires_params] > 0
			_aResult_ = This.ExtractMethodParameters(nIndex, _aOp_[:requires_params])
			_aParams_ = _aResult_[:params]
			_nNextIndex_ = _aResult_[:next_index]
			_nLen_ = len(_aParams_)

			for _i_ = 1 to _nLen_
				_cPlaceholder_ = "@param" + _i_
				if isList(_aParams_[_i_]) and len(_aParams_[_i_]) = 2 and
				   _aParams_[_i_][1] = char(2)
					# a RECALLED value: emit the bound variable itself
					_cParamValue_ = _aParams_[_i_][2]
				but isString(_aParams_[_i_])
					_cParamValue_ = '"' + _aParams_[_i_] + '"'
				but isList(_aParams_[_i_])
					_cParamValue_ = @@(_aParams_[_i_])
				else
					_cParamValue_ = "" + _aParams_[_i_]
				ok
				_cCode_ = StzReplace(_cCode_, _cPlaceholder_, _cParamValue_)
			next

			# a parameter the natural code never supplied: emit NOTHING
			# rather than broken Ring code (matters for grown operations
			# whose verbs can appear in prose without arguments)
			if StzFindFirst(_cCode_, "@param") > 0
				This.AddToDebugLog("Skipped " + _cSemantic_ + " -- missing parameter(s)")
				return [:code = "", :next_index = _nNextIndex_]
			ok

			return [:code = _cCode_, :next_index = _nNextIndex_]
		ok
		
		return [:code = _cCode_, :next_index = nIndex+1]
	
	def ExtractMethodParameters(nIndex, nParamCount)
		if @bParamsBeforeVerb = 1
			return This.ExtractParamsBackward(nIndex, nParamCount)
		ok
		_aParams_ = []
		_nLen_ = len(@aSemanticTokens)
		_nLastIndex_ = nIndex

		for _i_ = nIndex+1 to _nLen_
			_aToken_ = @aSemanticTokens[_i_]
			_nLastIndex_ = _i_

			if _aToken_[:type] = "semantic" and _aToken_[:value] = "VALUE_INDICATOR"
				loop
			ok

			if _aToken_[:type] = "literal"
				_cRef_ = This.ValueRefOf(_aToken_)
				if _cRef_ != ""
					_aParams_ + [ char(2), _cRef_ ]
				else
					_aParams_ + _aToken_[:value]
				ok
				@aConsumedTokens + _i_
				if len(_aParams_) = nParamCount
					exit
				ok
			ok

			if _aToken_[:type] = "semantic" and
			   (StzLeft(_aToken_[:value], 7) = "METHOD_" or _aToken_[:value] = "OUTPUT_DISPLAY")
				_nLastIndex_ = _i_ - 1
				exit
			ok
		next

		return [:params = _aParams_, :next_index = _nLastIndex_ + 1]

	# VERB-FINAL grammar: the parameters precede their verb ("'.'" instead-
	# of "'_'" put). Walk backward to the previous action/creation boundary
	# collecting unconsumed literals, keep the LAST nParamCount in textual
	# order, and mark them consumed so no later verb re-grabs them.

	def ExtractParamsBackward(nIndex, nParamCount)
		_aFound_ = []    # [ [tokenIndex, value], ... ] in textual order
		for _i_ = nIndex - 1 to 1 step -1
			_aToken_ = @aSemanticTokens[_i_]
			if _aToken_[:type] = "semantic"
				_cV_ = _aToken_[:value]
				if StzLeft(_cV_, 7) = "METHOD_" or _cV_ = "CREATE_OBJECT" or
				   _cV_ = "OUTPUT_DISPLAY"
					exit	# previous clause boundary
				ok
				loop		# indicators/objects pass through
			ok
			if _aToken_[:type] = "literal" and
			   ring_find(@aConsumedTokens, _i_) = 0
				_cRef_ = This.ValueRefOf(_aToken_)
				if _cRef_ != ""
					_aFound_ + [ _i_, [ char(2), _cRef_ ] ]
				else
					_aFound_ + [ _i_, _aToken_[:value] ]
				ok
			ok
		next
		# _aFound_ is reverse-textual: keep the FIRST nParamCount found
		# (= the literals nearest the verb), restored to textual order
		_aParams_ = []
		_nTake_ = nParamCount
		if _nTake_ > len(_aFound_)
			_nTake_ = len(_aFound_)
		ok
		for _i_ = _nTake_ to 1 step -1
			_aParams_ + _aFound_[_i_][2]
			@aConsumedTokens + _aFound_[_i_][1]
		next
		return [:params = _aParams_, :next_index = nIndex + 1]
	
	def ProcessMethodWithModifiers(nIndex, _cSemantic_)
		_aOp_ = This.GetSemanticOperation(_cSemantic_)
		if len(_aOp_) = 0
			return [:code = "", :next_index = nIndex+1]
		ok
		
		_cCode_ = StzReplace(_aOp_[:stz_signature], "@var", @cCurrentVariable)

		if HasKey(_aOp_, :supports_modifiers) and _aOp_[:supports_modifiers] = 1
			_nLen_ = len(@aSemanticTokens)
			for _i_ = nIndex+1 to _nLen_
				_aToken_ = @aSemanticTokens[_i_]
				if _aToken_[:type] = "semantic"
					_nModLen_ = len(_aOp_[:modifiers])
					for _j_ = 1 to _nModLen_
						_aMod_ = _aOp_[:modifiers][_j_]
						if _aMod_[:semantic_id] = _aToken_[:value]
							_cCode_ = StzReplace(_cCode_, _aOp_[:stz_method], _aMod_[:stz_method])
							_cCode_ = StzReplace(_cCode_, "()", "([" + _aMod_[:stz_param] + "])")
							exit 2
						ok
					next
				ok
			next
		ok
		
		return [:code = _cCode_, :next_index = nIndex+1]
	
	def GetSemanticOperation(cSemanticId)
		_nLen_ = len($aSemanticOperations)
		for _i_ = 1 to _nLen_
			_aOp_ = $aSemanticOperations[_i_]
			if _aOp_[:semantic_id] = cSemanticId
				return _aOp_
			ok
		next
		return []
	
	def Code()
		return This.GenerateCodeFromSemantics()
	
	def Result()
		return @result

	def OriginalCode()
		return @cOriginalCode

	def NaturalCode()
		return @cNaturalCode

	# PARAPHRASE-BACK (the Boeing-CPL trust loop): say what was UNDERSTOOD,
	# in plain words derived from the interpreted tokens -- so the writer of
	# a loosely-phrased (or vocalized Arabic) narration sees the canonical
	# reading before trusting the result.

	def Understood()
		_bEn_ = ( @cLangCode = "en" )
		_aSteps_ = []
		_nLen_ = len(@aSemanticTokens)
		_i_ = 1
		while _i_ <= _nLen_
			_aTok_ = @aSemanticTokens[_i_]
			if _aTok_[:type] != "semantic"
				_i_++
				loop
			ok
			_cSem_ = _aTok_[:value]
			if _cSem_ = "CREATE_OBJECT"
				_cT_ = ""
				_cTid_ = ""
				_cV_ = ""
				if @bObjectBeforeCreate = 1
					# SOV: the object word and value came BEFORE the verb
					for _j_ = _i_ - 1 to 1 step -1
						_aT2_ = @aSemanticTokens[_j_]
						if _cTid_ = "" and _aT2_[:type] = "semantic" and
						   StzLeft(_aT2_[:value], 7) = "OBJECT_"
							_cTid_ = _aT2_[:value]
						but _cV_ = "" and _aT2_[:type] = "literal"
							if isString(_aT2_[:value])
								_cV_ = _aT2_[:value]
							else
								_cV_ = @@(_aT2_[:value])
							ok
						ok
					next
				else
					for _j_ = _i_ + 1 to _nLen_
						_aT2_ = @aSemanticTokens[_j_]
						if _aT2_[:type] = "semantic" and StzLeft(_aT2_[:value], 7) = "OBJECT_"
							_cTid_ = _aT2_[:value]
						but _aT2_[:type] = "literal" and _cV_ = ""
							if isString(_aT2_[:value])
								_cV_ = _aT2_[:value]
							else
								_cV_ = @@(_aT2_[:value])
							ok
							exit
						ok
					next
				ok
				if _bEn_
					if _cTid_ != ""
						_cT_ = lower(StzRight(_cTid_, len(_cTid_) - 7))
					ok
					_cStep_ = "create a " + _cT_
					if _cV_ != ""
						_cStep_ += " with " + _cV_
					ok
				else
					# linearize with the pack's OWN words, in the pack's
					# OWN word order (SOV packs put the value first)
					_cCr_ = StzLinearizeId(@cLangCode, "CREATE_OBJECT")
					_cOb_ = ""
					if _cTid_ != ""
						_cOb_ = StzLinearizeId(@cLangCode, _cTid_)
					ok
					_cWi_ = StzLinearizeId(@cLangCode, "VALUE_INDICATOR")
					if @bObjectBeforeCreate = 1
						_cStep_ = _cV_ + " " + _cWi_ + " " + _cOb_ + " " + _cCr_
					else
						_cStep_ = _cCr_ + " " + _cOb_
						if _cV_ != ""
							_cStep_ += " " + _cWi_ + " " + _cV_
						ok
					ok
				ok
				_aSteps_ + _cStep_
			but StzLeft(_cSem_, 7) = "METHOD_"
				_aOp2_ = This.GetSemanticOperation(_cSem_)
				if len(_aOp2_) > 0 and HasKey(_aOp2_, :stz_method)
					_bQ2_ = ( HasKey(_aOp2_, :kind) and _aOp2_[:kind] = "query" )
					if _bEn_
						_cVerb_ = lower(_StzSplitCamel(_aOp2_[:stz_method]))
						if _bQ2_
							_aSteps_ + ("ask: " + _cVerb_)
						else
							_aSteps_ + _cVerb_
						ok
					else
						_cVerb_ = StzLinearizeId(@cLangCode, _cSem_)
						if _bQ2_
							_aSteps_ + (_cVerb_ + " ?")
						else
							_aSteps_ + _cVerb_
						ok
					ok
				ok
			but _cSem_ = "OUTPUT_DISPLAY"
				if _bEn_
					_aSteps_ + "show it"
				else
					_aSteps_ + StzLinearizeId(@cLangCode, "OUTPUT_DISPLAY")
				ok
			but _cSem_ = "NAME_INDICATOR"
				if _i_ < _nLen_ and @aSemanticTokens[_i_+1][:type] = "literal"
					if _bEn_
						_aSteps_ + ("call it " + @aSemanticTokens[_i_+1][:value])
					else
						_aSteps_ + (StzLinearizeId(@cLangCode, "NAME_INDICATOR") + " " + @aSemanticTokens[_i_+1][:value])
					ok
					_i_++
				ok
			but _cSem_ = "SWITCH_OBJECT"
				if _i_ < _nLen_ and @aSemanticTokens[_i_+1][:type] = "literal"
					if _bEn_
						_aSteps_ + ("switch to " + @aSemanticTokens[_i_+1][:value])
					else
						_aSteps_ + (StzLinearizeId(@cLangCode, "SWITCH_OBJECT") + " " + @aSemanticTokens[_i_+1][:value])
					ok
					_i_++
				ok
			but _cSem_ = "KEEP_INDICATOR"
				if _i_ < _nLen_ and @aSemanticTokens[_i_+1][:type] = "literal"
					if _bEn_
						_aSteps_ + ("keep it as " + @aSemanticTokens[_i_+1][:value])
					else
						_aSteps_ + (StzLinearizeId(@cLangCode, "KEEP_INDICATOR") + " " + @aSemanticTokens[_i_+1][:value])
					ok
					_i_++
				ok
			ok
			_i_++
		end
		_cOut_ = ""
		_nS_ = len(_aSteps_)
		for _i_ = 1 to _nS_
			_cOut_ += _aSteps_[_i_]
			if _i_ < _nS_
				_cOut_ += " -> "
			ok
		next
		return _cOut_

	def SuggestNext(_cPartial_)
		if NOT isString(_cPartial_)
			return []
		ok
		# mid-word? extract the trailing prefix (never inside a quote
		# or a value literal)
		_cPrefix_ = ""
		_cBase_ = _cPartial_
		_n_ = len(_cPartial_)
		if _n_ > 0 and ring_find([ " ", char(9), char(10), char(13) ], right(_cPartial_, 1)) = 0
			_k_ = _n_
			while _k_ > 0 and ring_find([ " ", char(9), char(10), char(13) ], _cPartial_[_k_]) = 0
				_k_--
			end
			_cW_ = right(_cPartial_, _n_ - _k_)
			if StzFindFirst(_cW_, "'") = 0 and StzFindFirst(_cW_, char(34)) = 0 and
			   StzFindFirst(_cW_, "[") = 0
				_cPrefix_ = StzLower(_cW_)
				_cBase_ = left(_cPartial_, _k_)
			ok
		ok

		This.Analyze(_cBase_)

		# state = the last SEMANTIC token... but a LITERAL after it means
		# the slot it opened is already FILLED (value given, name given):
		# the narration is ready for its next action
		_cState_ = ""
		_nT_ = len(@aSemanticTokens)
		_nLastSem_ = 0
		for _i_ = _nT_ to 1 step -1
			if @aSemanticTokens[_i_][:type] = "semantic"
				_cState_ = @aSemanticTokens[_i_][:value]
				_nLastSem_ = _i_
				exit
			ok
		next
		if _nLastSem_ > 0 and _nLastSem_ < _nT_
			for _i_ = _nLastSem_ + 1 to _nT_
				if @aSemanticTokens[_i_][:type] = "literal"
					if StzLeft(_cState_, 7) = "OBJECT_" or
					   _cState_ = "VALUE_INDICATOR" or
					   _cState_ = "NAME_INDICATOR" or
					   _cState_ = "KEEP_INDICATOR" or
					   _cState_ = "SWITCH_OBJECT"
						_cState_ = "READY"
					ok
					exit
				ok
			next
		ok
		_bHasObject_ = FALSE
		for _i_ = 1 to _nT_
			if @aSemanticTokens[_i_][:type] = "semantic" and
			   @aSemanticTokens[_i_][:value] = "CREATE_OBJECT"
				_bHasObject_ = TRUE
				exit
			ok
		next

		_aSug_ = []
		if _cState_ = "" and NOT _bHasObject_
			_aSug_ = StzMappingWordsOf(@cLangCode, "CREATE_OBJECT", 4)
		but _cState_ = "CREATE_OBJECT"
			_aSug_ = StzMappingWordsOf(@cLangCode, "OBJECT_STRING", 2)
			_aT2_ = StzMappingWordsOf(@cLangCode, "OBJECT_LIST", 2)
			_aT3_ = StzMappingWordsOf(@cLangCode, "OBJECT_NUMBER", 2)
			_nX_ = len(_aT2_)
			for _i_ = 1 to _nX_ _aSug_ + _aT2_[_i_] next
			_nX_ = len(_aT3_)
			for _i_ = 1 to _nX_ _aSug_ + _aT3_[_i_] next
		but StzLeft(_cState_, 7) = "OBJECT_"
			# the value indicator may be an ignored word (en 'with'), so
			# offer the indicator AND the value shapes together
			_aSug_ = StzMappingWordsOf(@cLangCode, "VALUE_INDICATOR", 2)
			_aSug_ + "'a value'"
			_aSug_ + "[ 1, 2, 3 ]"
			_aSug_ + "42"
		but _cState_ = "VALUE_INDICATOR"
			_aSug_ = [ "'a value'", "[ 1, 2, 3 ]", "42" ]
		but _cState_ = "NAME_INDICATOR" or _cState_ = "KEEP_INDICATOR"
			_aSug_ = [ "<a name>" ]
		but _cState_ = "SWITCH_OBJECT"
			# names live in the TOKEN stream (Analyze does not run the
			# codegen that fills the registry): every literal right
			# after a NAME_INDICATOR is a named object
			for _i_ = 1 to _nT_ - 1
				if @aSemanticTokens[_i_][:type] = "semantic" and
				   @aSemanticTokens[_i_][:value] = "NAME_INDICATOR" and
				   @aSemanticTokens[_i_+1][:type] = "literal"
					_aSug_ + StzLower(trim(@aSemanticTokens[_i_+1][:value]))
				ok
			next
			if len(_aSug_) = 0
				_aSug_ = [ "<a named object>" ]
			ok
		else
			# an object lives (or a step just completed): action verbs,
			# plus the closing moves. Phrases span words, so ALSO try the
			# base's last word + the typed prefix ("remove d" beats "d")
			_cPrefix2_ = ""
			if _cPrefix_ != ""
				_aBW_ = @split(trim(_cBase_), " ")
				_nBW_ = len(_aBW_)
				if _nBW_ > 0 and isalpha(_aBW_[_nBW_])
					_cPrefix2_ = StzLower(_aBW_[_nBW_]) + " " + _cPrefix_
				ok
			ok
			_aSug_ = []
			if _cPrefix_ = ""
				# no prefix: the CURATED dictionary verbs read best
				# (grown names are for completion, not browsing)
				_aSug_ = StzPackPhrases(@cLangCode, "", 9)
			else
				if _cPrefix2_ != ""
					if @cLangCode = "en"
						_aSug_ = StzSuggestVerbPhrases(_cPrefix2_, 9)
					else
						_aSug_ = StzPackPhrases(@cLangCode, _cPrefix2_, 9)
					ok
				ok
				if len(_aSug_) = 0
					if @cLangCode = "en"
						_aSug_ = StzSuggestVerbPhrases(_cPrefix_, 9)
					else
						_aSug_ = StzPackPhrases(@cLangCode, _cPrefix_, 9)
					ok
				ok
			ok
			if _cPrefix_ = ""
				_aTail_ = StzMappingWordsOf(@cLangCode, "OUTPUT_DISPLAY", 1)
				_nX_ = len(_aTail_)
				for _i_ = 1 to _nX_ _aSug_ + _aTail_[_i_] next
				if @cLangCode = "en"
					_aSug_ + "called <name>"
					_aSug_ + "keep it as <name>"
				ok
			ok
			return _aSug_
		ok

		# prefix filter for the category modes
		if _cPrefix_ != ""
			_aF_ = []
			_nX_ = len(_aSug_)
			for _i_ = 1 to _nX_
				if left(StzLower(_aSug_[_i_]), len(_cPrefix_)) = _cPrefix_
					_aF_ + _aSug_[_i_]
				ok
			next
			return _aF_
		ok
		return _aSug_

	# UNDERSTANDABILITY: the action-position words this run could not
	# interpret, each with the nearest known word as a suggestion --
	# [ [word, suggestion], ... ]. Execution is permissive (unknown
	# words degrade to literals); this is the honest report of it.

	def Unresolved()
		return @aUnresolved

	def UnderstoodAll()
		return len(@aUnresolved) = 0

	# Dry run: tokenize + interpret WITHOUT generating or executing any
	# code. Returns the lint report.

	def Analyze(_cCode_)
		if NOT isString(_cCode_) or trim(_cCode_) = ""
			return [ :understood = TRUE, :unresolved = [] ]
		ok
		@cNaturalCode = _cCode_
		This.TokenizeCode(_cCode_)
		@aSemanticTokens = This.ConvertToSemanticTokens()
		return [ :understood = This.UnderstoodAll(), :unresolved = @aUnresolved ]
	
	def Context()
		return @aContext

	#--- DEBUG ---
	
	def EnableDebug()
		@bDebugMode = 1
		@aDebugLog = []
	
	def DisableDebug()
		@bDebugMode = 0
	
	def AddToDebugLog(cMessage)
		if @bDebugMode
			@aDebugLog + [:timestamp = clock(), :message = cMessage]
		ok
	
	def DebugLog()
		return @aDebugLog
	
	def ClearDebugLog()
		@aDebugLog = []

	def ClearDebug()
		@aDebugLog = []

	#--- ACCESSORS ---

	def Language()
		return @cLanguage

	def IgnoredWords()
		return @aIgnoredWords

	def Mappings()
		return @aMappings

	def Values()
		return @aValues

	def Tokens()
		return @aSemanticTokens

	def Object()
		return @cCurrentObject
