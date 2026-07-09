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
			"thank", "you", "please", "nice"
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

func NaturallyInXT(cLang, aContext, cCode)
	# Handle: NaturallyInXT(aContext, "code")
	if isList(cLang) and isString(aContext)
		return new stzNaturalEngine("en", "", cLang, aContext)
	ok
	
	# Handle: NaturallyInXT("lang", aContext, "code")
	if isString(cLang) and isList(aContext) and isString(cCode)
		return new stzNaturalEngine(cLang, "", aContext, cCode)
	ok
	
	# Fallback
	return new stzNaturalEngine("en", "", [], "")

func NaturallyXT(aContext, cCode)
	# Handle: NaturallyXT(aContext, "code")
	if isList(aContext) and isString(cCode)
		return new stzNaturalEngine("en", "", aContext, cCode)
	ok
	
	# Fallback
	return new stzNaturalEngine("en", "", [], "")

func NaturallyIn(cLang, cCode)
	return NaturallyInXT(cLang, [], cCode)

func Naturally(cCode)
	return NaturallyXT([], cCode)

#-- NATURAL ENGINE CLASS WITH CONTEXT

class stzNaturalEngine from stzObject
	@cLanguage = "en"
	@aIgnoredWords = []
	@aMappings = []
	@aValues = []
	@aTokenIsWord = []	# provenance: TRUE = bare word, FALSE = quoted string
				# or list literal (those must NEVER be fallback-resolved)
	@aSemanticTokens = []
	@cCurrentObject = ""
	@cCurrentVariable = ""
	@aDefineRecallState = []
	@bDebugMode = 0
	@aDebugLog = []
	@result
	@cNaturalCode = ""
	@cOriginalCode = ""
	@aContext = []

	def init(cLang, cCode, aContext, cContextCode)
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

			cInterpolated = This.InterpolateContext(cContextCode, aContext)
			@cNaturalCode = cInterpolated
			This.Execute(cInterpolated)
			return
		ok
		
		# Handle original patterns
		if cCode != ""
			@cLanguage = StzLower(cLang)
			@cNaturalCode = cCode
			@cOriginalCode = cCode
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
	
	def InterpolateContext(cCode, aContext)
		if len(aContext) = 0
			return cCode
		ok
		
		cResult = cCode
		
		# Extract all {key} or {key.nested.path} patterns

		aMatches = StzStringQ(cCode).SubstringsBoundedBy([ "{", "}" ])

		_nMatchesLen_ = len(aMatches)
		for i = 1 to _nMatchesLen_
			cKey = aMatches[i]
			cValue = @@(This.GetContextValue(cKey, aContext))

			if cValue != :NOT_FOUND
				cResult = StzReplace(cResult, "{" + cKey + "}", cValue)
			ok
		next
		
		return cResult
	
	def FindContextPlaceholders(cCode)
		aResult = []
		nLen = stzlen(cCode)
		i = 1
		
		while i <= nLen
			if @StzMid(cCode, i, i) = "{"
				# Find closing }
				nEnd = i + 1
				nDepth = 1
				
				while nEnd <= nLen and nDepth > 0
					cChar = @StzMid(cCode, nEnd, nEnd)
					if cChar = "{"
						nDepth++
					but cChar = "}"
						nDepth--
					ok
					nEnd++
				end
				
				if nDepth = 0
					cPlaceholder = @StzMid(cCode, i, nEnd - i)
					aResult + cPlaceholder
					i = nEnd
				else
					i++
				ok
			else
				i++
			ok
		end
		
		return aResult
	
	def GetContextValue(cKey, aContext)
		# Handle nested keys like "user.profile.name"
		if StzFindFirst(cKey, ".") > 0
			aParts = @split(cKey, ".")
			xCurrent = aContext
			
			_nPartsLen_ = len(aParts)
			for i = 1 to _nPartsLen_
				cPart = trim(aParts[i])
				
				# Normalize key (case-insensitive, capitalize first letter)
				cNormalized = This.NormalizeKey(cPart)
				
				if isList(xCurrent)
					xCurrent = This.FindInList(xCurrent, cNormalized)
					if xCurrent = :NOT_FOUND
						return :NOT_FOUND
					ok
				else
					return :NOT_FOUND
				ok
			next
			
			return xCurrent
		else
			# Simple key lookup
			cNormalized = This.NormalizeKey(cKey)
			return This.FindInList(aContext, cNormalized)
		ok
	
	def NormalizeKey(cKey)
		cKey = trim(cKey)
		if StzLen(cKey) = 0
			return cKey
		ok
		
		# Capitalize first letter, lowercase rest
		return StzUpper(@StzMid(cKey, 1, 1)) + StzLower(StzMid(cKey, 2, stzlen(cKey) - 1))
	
	def FindInList(aList, cKey) #TODO// Review it
		nLen = len(aList)
		for i = 1 to nLen
			if isList(aList[i]) and len(aList[i]) = 2
				if isString(aList[i][1])
					cNormalized = This.NormalizeKey(aList[i][1])
					if cNormalized = cKey
						return aList[i][2]
					ok
				ok
			ok
		next
		return :NOT_FOUND

	
	def Execute(cCode)
		if NOT isString(cCode) or trim(cCode) = ""
			return
		ok
		
		@cNaturalCode = cCode
		This.AddToDebugLog("Executing natural code")
		This.AddToDebugLog("Code length: " + stzlen(cCode) + " chars")
		
		This.TokenizeCode(cCode)
	
		This.AddToDebugLog("Raw values: " + len(@aValues) + " items")
		
		This.Process()
	
	def TokenizeCode(cCode)
		@aValues = []
		@aTokenIsWord = []
		cCode = trim(cCode)
		aTokens = This.SmartSplit(cCode)
		@aValues = aTokens
	
	def SmartSplit(cCode)
	    aResult = []
	    _oStr_ = new stzString(cCode)
	    
	    # Find all protected sections (lists AND standalone strings)
	    aListSections = _oStr_.FindSubStringsBoundedByIBZZ([ "[", "]" ])
	    
	    # For strings, only find those OUTSIDE of lists.
	    # NOTE: BoundedByIBZZ with identical single-char bounds OVERLAPS by
	    # design (each closer is reused as the next opener) -- right for
	    # substring analytics, wrong for quote pairing: with six quotes it
	    # would protect the gaps BETWEEN values too. Pair quotes manually
	    # (1st-2nd, 3rd-4th, ...) instead.
	    aAllQuoteSections = Merge([
	        This.PairedQuoteSections(cCode, '"'),
	        This.PairedQuoteSections(cCode, "'")
	    ])
	    
	    # Filter out quote sections that are inside list sections
	    aStringSections = []
	    _nAllQuoteSections1Len_ = len(aAllQuoteSections)
	    for _iLoopAllQuoteSections1_ = 1 to _nAllQuoteSections1Len_
	    	aQuoteSection = aAllQuoteSections[_iLoopAllQuoteSections1_]
	        bInsideList = FALSE
	        _nListSections1Len_ = len(aListSections)
	        for _iLoopListSections1_ = 1 to _nListSections1Len_
	        	aListSection = aListSections[_iLoopListSections1_]
	            if aQuoteSection[1] >= aListSection[1] and aQuoteSection[2] <= aListSection[2]
	                bInsideList = TRUE
	                exit
	            ok
	        next
	        if NOT bInsideList
	            aStringSections + aQuoteSection
	        ok
	    next
	    
	    aProtectedSections = Merge([aListSections, aStringSections])
	    
	    # Get splittable sections (the gaps around the protected ones).
	    # NOTE: FindAntiSectionsZZ() is the find-form and takes a SUBSTRING
	    # since the finder refactor -- the section-form is AntiSectionsZZ().
	    aSplittableSections = _oStr_.AntiSectionsZZ(aProtectedSections)
	    
	    # Merge and sort by position
	    aAllSections = []

	    nLen = len(aSplittableSections)
	    for i = 1 to nLen
		aPair = aSplittableSections[i]
	        aAllSections + [:pos = aPair[1], :type = "splittable", :pair = aPair]
	    next

	    nLen = len(aListSections)
	    for i = 1 to nLen
		aPair = aListSections[i]
	        aAllSections + [:pos = aPair[1], :type = "list", :pair = aPair]
	    next

	    nLen = len(aStringSections)
	    for i = 1 to nLen
		aPair = aStringSections[i]
	        aAllSections + [:pos = aPair[1], :type = "string", :pair = aPair]
	    next
	    
	    aAllSections = SortListsOn(aAllSections, 1)
	    nLen = len(aAllSections)

	    # Process in order

	    for i = 1 to nLen
		aSection = aAllSections[i]
	        aPair = aSection[:pair]
	        cSection = _oStr_.Section(aPair[1], aPair[2])
	        
	        if aSection[:type] = "splittable"
	            acWords = @split(cSection, " ")
		    nLenWords = len(acWords)

		    for j = 1 to nLenWords
	                if trim(acWords[j]) != ""
	                    aResult + acWords[j]
	                    @aTokenIsWord + TRUE
	                ok
	            next

	        but aSection[:type] = "list"
	            # nested brackets can mis-pair the section -- degrade to a
	            # literal string token instead of dying in eval
	            try
	                cCode = 'aResult + ' + cSection
	                eval(cCode)
	            catch
	                aResult + cSection
	            done
	            @aTokenIsWord + FALSE

	        else  # string
	            # Remove quotes -- StzMid is (start, COUNT): keep len-2 chars
	            aResult + @StzMid(cSection, 2, stzlen(cSection) - 2)
	            @aTokenIsWord + FALSE
	        ok
	    next
	    
	    return aResult
	
	# Only these SHAPES may be eval'd as list literals: a bracketed
	# [ ... ] form, or a pure numeric range like 1:5. Prose that
	# isListInString() mistakes for a range ("note:") is rejected.

	def LooksEvalSafeList(cVal)
		cVal = trim(cVal)
		if StzLeft(cVal, 1) = "[" and StzRight(cVal, 1) = "]"
			return 1
		ok
		nPos = StzFindFirst(cVal, ":")
		if nPos > 1 and nPos < StzLen(cVal)
			cL = StzLeft(cVal, nPos - 1)
			cR = StzRight(cVal, StzLen(cVal) - nPos)
			if isdigit(cL) and isdigit(cR)
				return 1
			ok
		ok
		return 0

	# Non-overlapping quote pairing: positions 1-2, 3-4, ... form the
	# quoted sections. An unmatched trailing quote is simply ignored.

	def PairedQuoteSections(cCode, cQuote)
		aPos = StzFind(cQuote, cCode)
		aOut = []
		nLen = len(aPos)
		k = 1
		while k + 1 <= nLen
			aOut + [ aPos[k], aPos[k+1] ]
			k += 2
		end
		return aOut

	def LoadLanguageData()
		aLangDef = This.FindLanguageDefinition(@cLanguage)
		if len(aLangDef) > 0
			@aIgnoredWords = aLangDef[:ignored_words]
			@aMappings = aLangDef[:semantic_mappings]
		ok
	
	def FindLanguageDefinition(cCode)
		nLen = len($aLanguageDefinitions)
		for i = 1 to nLen
			aLang = $aLanguageDefinitions[i]
			if aLang[:code] = cCode or aLang[:name] = cCode
				return aLang
			ok
		next
		return []
	
	def Process()
		@aSemanticTokens = This.ConvertToSemanticTokens()
		This.AddToDebugLog("Tokens: " + len(@aSemanticTokens))
		
		cCode = This.GenerateCodeFromSemantics()

		This.AddToDebugLog("Generated code:")
		This.AddToDebugLog(cCode)
		
		if trim(cCode) != ""
			eval(cCode)
		ok
	
	def ConvertToSemanticTokens()
		aTokens = []

		nLen = len(@aValues)
		This.AddToDebugLog("Converting to semantic tokens")
		
		for i = 1 to nLen
			cValue = @aValues[i]
		
			if isString(cValue) and isListInString(cValue) and
			   This.LooksEvalSafeList(cValue)
				# isListInString() can false-positive on plain prose
				# ("note:" reads as range syntax) -- LooksEvalSafeList()
				# filters those, and if the eval still fails we fall
				# through to normal word handling instead of dying.
				bParsed = FALSE
				try
					cCode = 'aListValue = ' + cValue
					eval(cCode)
					bParsed = TRUE
				catch
				done
				if bParsed
					aTokens + [:type = "literal", :value = aListValue]
					This.AddToDebugLog("List literal parsed: " + stzlen(aListValue) + " items")
					loop
				ok
			ok
			

			if NOT isString(cValue)
				cValue = @@(cValue)
			ok
			
			This.AddToDebugLog("Processing: '" + cValue + "'")

			# Provenance: quoted strings and list literals are VALUES --
			# they are never ignored-word-filtered and never interpreted
			# ('Create a string with "this"' must keep "this" even though
			# the bare word this is an ignored word; 'with "show"' must
			# not become OUTPUT_DISPLAY).
			bWord = TRUE
			if len(@aTokenIsWord) >= i
				bWord = @aTokenIsWord[i]
			ok

			if NOT bWord
				aTokens + [:type = "literal", :value = cValue]
				This.AddToDebugLog("Literal (quoted value)")
				loop
			ok

			if This.IsIgnoredWord(cValue)
				This.AddToDebugLog("Ignored")
				loop
			ok

			cSemantic = This.ToSemantic(cValue)

			# Unified-lexicon fallback (natural <-> reflect unification):
			# a bare WORD the dictionary doesn't know (quoted values never
			# reach here -- see the provenance branch above -- and value
			# positions are excluded by FallbackEligible) is resolved
			# against the shared semantic lexicon built from the dictionary
			# seed + the _ActionsXT form glossary + the #@ aka tags.
			if cSemantic = "" and @cLanguage = "en" and
			   This.FallbackEligible(aTokens)
				cSemantic = StzResolveSemantic(cValue)
				if cSemantic != ""
					This.AddToDebugLog("Unified lexicon: '" + cValue + "' -> " + cSemantic)
				ok
			ok

			if cSemantic != ""
				bLiteral = This.ShouldTreatAsLiteral(aTokens, cSemantic, cValue)
				
				if bLiteral
					aTokens + [:type = "literal", :value = cValue]
					This.AddToDebugLog("Literal (context)")
				else
					aTokens + [:type = "semantic", :value = cSemantic, :original = cValue]
					This.AddToDebugLog("Semantic: " + cSemantic)
				ok
			else
				aTokens + [:type = "literal", :value = cValue]
				This.AddToDebugLog("Literal")
			ok
		next
		
		return aTokens
	
	def ShouldTreatAsLiteral(aTokens, cSemantic, cValue)
		nLen = len(aTokens)
		if nLen = 0
			return 0
		ok
		
		aLast = aTokens[nLen]
		
		if aLast[:type] = "semantic" and aLast[:value] = "VALUE_INDICATOR"
			return 1
		ok

		if aLast[:type] = "literal" and nLen >= 2
			aBeforeLast = aTokens[nLen-1]
			if aBeforeLast[:type] = "semantic" and StzLeft(aBeforeLast[:value], 7) = "METHOD_"
				aOp = This.GetSemanticOperation(aBeforeLast[:value])
				if len(aOp) > 0 and HasKey(aOp, :requires_params) and aOp[:requires_params] > 0
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

	def FallbackEligible(aTokens)
		nLen = len(aTokens)
		if nLen = 0
			return 1	# first token of a block: action position
		ok

		aLast = aTokens[nLen]
		if aLast[:type] = "semantic"
			cVal = aLast[:value]

			if StzLeft(cVal, 7) = "OBJECT_" or cVal = "VALUE_INDICATOR"
				return 0
			ok

			if StzLeft(cVal, 7) = "METHOD_"
				aOp = This.GetSemanticOperation(cVal)
				if len(aOp) > 0 and HasKey(aOp, :requires_params) and
				   aOp[:requires_params] > 0
					return 0
				ok
			ok
		ok

		return 1

	def IsIgnoredWord(cWord)
		return StzFindFirst(@aIgnoredWords, StzLower(cWord)) > 0
	
	def ToSemantic(cWord)
		cLower = StzLower(cWord)

		bDefine = StzLeft(cLower, 1) = "@"
		bRecall = StzRight(cLower, 1) = "@"
		
		if bDefine
			cLower = @StzMid(cLower, 2, stzlen(cLower) - 1)
		but bRecall
			cLower = StzLeft(cLower, stzlen(cLower) - 1)
		ok
		
		nLen = len(@aMappings)
		for i = 1 to nLen
			aMap = @aMappings[i]
			if aMap[:natural] = cLower
				cSemantic = aMap[:semantic]
				if bDefine
					return "@" + cSemantic
				but bRecall
					return cSemantic + "@"
				ok
				return cSemantic
			ok
		next
		return ""
	
	def GenerateCodeFromSemantics()
		aCodeLines = []
		nLen = len(@aSemanticTokens)

		i = 1

		while i <= nLen
			aToken = @aSemanticTokens[i]
			
			if aToken[:type] = "semantic"
				cSemantic = aToken[:value]
				nLenSem = stzLen(cSemantic)

				if StzLeft(cSemantic, 1) = "@"
					cClean = @StzMid(cSemantic, 2, nLenSem - 1)
					@aDefineRecallState + [:semantic = cClean, :index = i]
					i++
					loop
				ok
				
				if StzRight(cSemantic, 1) = "@"
					cClean = StzLeft(cSemantic, nLenSem - 1)
					aResult = This.ProcessMethodWithModifiers(i, cClean)
					if stzlen(aResult[:code]) > 0
						aCodeLines + aResult[:code]
					ok
					i = aResult[:next_index]
					loop
				ok
				
				if cSemantic = "CREATE_OBJECT"
					aResult = This.ProcessObjectCreation(i)
					if stzlen(aResult[:code]) > 0
						aCodeLines + aResult[:code]
					ok
					i = aResult[:next_index]
					
				but StzLeft(cSemantic, 7) = "METHOD_"
					aResult = This.ProcessMethod(i, cSemantic)
					if stzlen(aResult[:code]) > 0
						aCodeLines + aResult[:code]
					ok
					i = aResult[:next_index]
					
				but cSemantic = "OUTPUT_DISPLAY"
					aOp = This.GetSemanticOperation(cSemantic)
					if len(aOp) > 0
						cCode = StzReplace(aOp[:stz_signature], "@var", @cCurrentVariable)
						aCodeLines + cCode
					ok
					i++
				else
					i++
				ok
			else
				i++
			ok
		end

		if trim(@cCurrentVariable) = ""
			raise("Unsupported object type!")
		ok

		cCode = JoinXT(aCodeLines, StzChar(10)) + StzChar(10) + "@result = " + @cCurrentVariable + ".Content()"
		return cCode
	
	def FindDefineIndex(cSemantic)
		nLen = len(@aDefineRecallState)
		for i = 1 to nLen
			if @aDefineRecallState[i][:semantic] = cSemantic
				return @aDefineRecallState[i][:index]
			ok
		next
		return 0
	
	def ProcessObjectCreation(nIndex)

		nLen = len(@aSemanticTokens)
		cObjectType = ""
		cValue = ""
		nNextIndex = nIndex + 1
		
		for i = nIndex+1 to nLen
			aToken = @aSemanticTokens[i]
			if aToken[:type] = "semantic" and StzLeft(aToken[:value], 7) = "OBJECT_"
				cObjectType = aToken[:value]
				
				for j = i+1 to nLen
					aNextToken = @aSemanticTokens[j]
					if aNextToken[:type] = "literal"
						cValue = aNextToken[:value]
						nNextIndex = j + 1
						exit 2
					ok
				next
			ok
		next

		if cObjectType != ""
			aOp = This.GetSemanticOperation(cObjectType)

			if len(aOp) > 0
				@cCurrentObject = aOp[:object_type]
				@cCurrentVariable = aOp[:variable]
				cConstructor = aOp[:constructor]
				
				if isListInString(cValue)
					cConstructor = StzReplace(cConstructor, "@", cValue)
				else

					cConstructor = StzReplace(cConstructor, "@", '"' + cValue + '"')
				ok
				
				cCode = @cCurrentVariable + " = " + cConstructor
				return [:code = cCode, :next_index = nNextIndex]
			ok
		ok
		
		aResult = [:code = "", :next_index = nIndex+1]
		return aResult

	def ProcessMethod(nIndex, cSemantic)
		This.AddToDebugLog("Processing method: " + cSemantic)

		aOp = This.GetSemanticOperation(cSemantic)
		if len(aOp) = 0
			return [:code = "", :next_index = nIndex+1]
		ok

		# GROWN operations carry the class they were harvested from --
		# applying a stzList verb to a stzString object would R14, so
		# enforce :applies_to for them (hand-authored ops keep their
		# historical advisory behavior).
		if HasKey(aOp, :grown) and HasKey(aOp, :applies_to)
			bApplies = FALSE
			aTo = aOp[:applies_to]
			nTo = len(aTo)
			for i = 1 to nTo
				if lower(aTo[i]) = lower(@cCurrentObject)
					bApplies = TRUE
					exit
				ok
			next
			if NOT bApplies
				This.AddToDebugLog("Skipped " + cSemantic + " -- not applicable to " + @cCurrentObject)
				return [:code = "", :next_index = nIndex+1]
			ok
		ok

		cCode = StzReplace(aOp[:stz_signature], "@var", @cCurrentVariable)

		if HasKey(aOp, :requires_params) and aOp[:requires_params] > 0
			aResult = This.ExtractMethodParameters(nIndex, aOp[:requires_params])
			aParams = aResult[:params]
			nNextIndex = aResult[:next_index]
			nLen = len(aParams)

			for i = 1 to nLen
				cPlaceholder = "@param" + i
				if isString(aParams[i])
					cParamValue = '"' + aParams[i] + '"'
				but isList(aParams[i])
					cParamValue = @@(aParams[i])
				else
					cParamValue = "" + aParams[i]
				ok
				cCode = StzReplace(cCode, cPlaceholder, cParamValue)
			next

			# a parameter the natural code never supplied: emit NOTHING
			# rather than broken Ring code (matters for grown operations
			# whose verbs can appear in prose without arguments)
			if StzFindFirst(cCode, "@param") > 0
				This.AddToDebugLog("Skipped " + cSemantic + " -- missing parameter(s)")
				return [:code = "", :next_index = nNextIndex]
			ok

			return [:code = cCode, :next_index = nNextIndex]
		ok
		
		return [:code = cCode, :next_index = nIndex+1]
	
	def ExtractMethodParameters(nIndex, nParamCount)
		aParams = []
		nLen = len(@aSemanticTokens)
		nLastIndex = nIndex
		
		for i = nIndex+1 to nLen
			aToken = @aSemanticTokens[i]
			nLastIndex = i
			
			if aToken[:type] = "semantic" and aToken[:value] = "VALUE_INDICATOR"
				loop
			ok
			
			if aToken[:type] = "literal"
				aParams + aToken[:value]
				if len(aParams) = nParamCount
					exit
				ok
			ok
			
			if aToken[:type] = "semantic" and 
			   (StzLeft(aToken[:value], 7) = "METHOD_" or aToken[:value] = "OUTPUT_DISPLAY")
				nLastIndex = i - 1
				exit
			ok
		next
		
		return [:params = aParams, :next_index = nLastIndex + 1]
	
	def ProcessMethodWithModifiers(nIndex, cSemantic)
		aOp = This.GetSemanticOperation(cSemantic)
		if len(aOp) = 0
			return [:code = "", :next_index = nIndex+1]
		ok
		
		cCode = StzReplace(aOp[:stz_signature], "@var", @cCurrentVariable)

		if HasKey(aOp, :supports_modifiers) and aOp[:supports_modifiers] = 1
			nLen = len(@aSemanticTokens)
			for i = nIndex+1 to nLen
				aToken = @aSemanticTokens[i]
				if aToken[:type] = "semantic"
					nModLen = len(aOp[:modifiers])
					for j = 1 to nModLen
						aMod = aOp[:modifiers][j]
						if aMod[:semantic_id] = aToken[:value]
							cCode = StzReplace(cCode, aOp[:stz_method], aMod[:stz_method])
							cCode = StzReplace(cCode, "()", "([" + aMod[:stz_param] + "])")
							exit 2
						ok
					next
				ok
			next
		ok
		
		return [:code = cCode, :next_index = nIndex+1]
	
	def GetSemanticOperation(cSemanticId)
		nLen = len($aSemanticOperations)
		for i = 1 to nLen
			aOp = $aSemanticOperations[i]
			if aOp[:semantic_id] = cSemanticId
				return aOp
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
