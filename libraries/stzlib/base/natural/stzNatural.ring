# Enhanced Multilingual Softanza Natural Programming System
# Complete separation of language data from processing logic

#------------------------------#
#  GLOBAL LANGUAGE REGISTRY - Pure Data Configuration
#------------------------------#

$aLanguageDefinitions = [
	[
		:code = "en",
		:name = "english",
		:script = "latin",
		
		:ignored_words = [
			"is", "are", "should", "must", "can", "will", "the",
			"this_", "that", "these", "those", "and_", "then", "also",
			"plus", "with", "using", "to_", "by", "containing", "be",
			"being", "decorated", "final", "result", "object", "at",
			"position", "a", "it", "on_", "inside", "very", "much",
			"thank", "you", "please", "nice"
		],
		
		:semantic_mappings = [

			# Object creation triggers
			[:natural = "create", :semantic = "CREATE_OBJECT"],
			[:natural = "make", :semantic = "CREATE_OBJECT"],
			[:natural = "new", :semantic = "CREATE_OBJECT"],
			
			# Object types
			[:natural = "string", :semantic = "OBJECT_STRING"],
			[:natural = "stzstring", :semantic = "OBJECT_STRING"],
			
			# Value indicators
			[:natural = "with", :semantic = "VALUE_INDICATOR"],
			
			# Method: Spacify
			[:natural = "spacify", :semantic = "METHOD_SPACIFY"],
			[:natural = "addspaces", :semantic = "METHOD_SPACIFY"],
			
			# Method: Uppercase
			[:natural = "uppercase", :semantic = "METHOD_UPPERCASE"],
			[:natural = "caps", :semantic = "METHOD_UPPERCASE"],
			
			# Method: Lowercase
			[:natural = "lowercase", :semantic = "METHOD_LOWERCASE"],

			# Method: Capitalize
			[:natural = "capitalize", :semantic = "METHOD_CAPITALIZE"],
			[:natural = "capitalise", :semantic = "METHOD_CAPITALIZE"],

			# Method: Trim
			[:natural = "trim", :semantic = "METHOD_TRIM"],

			# Method: Reverse
			[:natural = "reverse", :semantic = "METHOD_REVERSE"],

			#--

			# Method: Box
			[:natural = "box", :semantic = "METHOD_BOX"],
			[:natural = "frame", :semantic = "METHOD_BOX"],
			
			# Modifier: Rounded
			[:natural = "rounded", :semantic = "MODIFIER_ROUNDED"],
			
			#--

			# Method: Replace
			[:natural = "replace", :semantic = "METHOD_REPLACE"],
			[:natural = "substitute", :semantic = "METHOD_REPLACE"],
			[:natural = "change", :semantic = "METHOD_REPLACE"],
			[:natural = "swap", :semantic = "METHOD_REPLACE"],

			#--

			# Output
			[:natural = "show", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "display", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "print", :semantic = "OUTPUT_DISPLAY"],
			
			#--

			# Context words (kept for natural flow but ignored)
			[:natural = "screen", :semantic = "CONTEXT_IGNORED"],

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
			[:natural = "ɗauke", :semantic = "VALUE_INDICATOR"],
			[:natural = "raba", :semantic = "METHOD_SPACIFY"],
			[:natural = "maida", :semantic = "METHOD_UPPERCASE"],
			[:natural = "maiɗa", :semantic = "METHOD_UPPERCASE"],
			[:natural = "datsa", :semantic = "METHOD_TRIM"],
			[:natural = "akwati", :semantic = "METHOD_BOX"],
			[:natural = "zagaye", :semantic = "MODIFIER_ROUNDED"],
			[:natural = "nuna", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "allo", :semantic = "CONTEXT_IGNORED"]
		]
	],
	
	[
		:code = "ha-ajami",
		:name = "hausa-ajami",
		:script = "ajami",
		
		:ignored_words = [
			"دا", "دُولِ", "كوما", "ا", "چِكِ", "شي", "وَنَّن",
			"كَنْ", "نَ", "گودِ", "سوساي"
		],
		
		:semantic_mappings = [
			[:natural = "يي", :semantic = "CREATE_OBJECT"],
			[:natural = "روْبُتُ", :semantic = "OBJECT_STRING"],
			[:natural = "ɗوكي", :semantic = "VALUE_INDICATOR"],
			[:natural = "رب", :semantic = "METHOD_SPACIFY"],
			[:natural = "ميّرد", :semantic = "METHOD_UPPERCASE"],
			[:natural = "دَتْسِ", :semantic = "METHOD_TRIM"],
			[:natural = "اَكْوَتِ", :semantic = "METHOD_BOX"],
			[:natural = "اَكْوَتِن", :semantic = "METHOD_BOX"],
			[:natural = "زَغَيِ", :semantic = "MODIFIER_ROUNDED"],
			[:natural = "نُوْنَ", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "اَلّو", :semantic = "CONTEXT_IGNORED"]
		]
	]
]

#------------------------------#
#  SEMANTIC REGISTRY - Language-Independent Operations
#------------------------------#

$aSemanticOperations = [
	[
		:semantic_id = "OBJECT_STRING",
		:object_type = "stzString",
		:constructor = "StzStringQ(@)",
		:variable = "oStr"
	],

	[
		:semantic_id = "METHOD_REPLACE",
		:stz_method = "Replace",
		:stz_signature = "@var.Replace(@param1, @param2)",
		:requires_params = 2,
		:param_pattern = "value_with_value"  # old_value with new_value
	],

	[
		:semantic_id = "METHOD_SPACIFY",
		:stz_method = "Spacify",
		:stz_signature = "@var.Spacify()"
	],
	
	[
		:semantic_id = "METHOD_UPPERCASE",
		:stz_method = "Uppercase",
		:stz_signature = "@var.Uppercase()"
	],
	
	[
		:semantic_id = "METHOD_LOWERCASE",
		:stz_method = "Lowercase",
		:stz_signature = "@var.Lowercase()"
	],

	[
		:semantic_id = "METHOD_CAPITALIZE",
		:stz_method = "Capitalize",
		:stz_signature = "@var.Capitalize()"
	],

	[
		:semantic_id = "METHOD_TRIM",
		:stz_method = "Trim",
		:stz_signature = "@var.Trim()"
	],

	[
		:semantic_id = "METHOD_REVERSE",
		:stz_method = "Reverse",
		:stz_signature = "@var.Reverse()"
	],

	[
		:semantic_id = "METHOD_BOX",
		:stz_method = "Box",
		:stz_signature = "@var.Box()",
		:supports_modifiers = 1,
		:modifiers = [
			[
				:semantic_id = "MODIFIER_ROUNDED",
				:stz_method = "BoxXT",
				:stz_param = ":Rounded = 1"
			]
		]
	],
	
	[
		:semantic_id = "OUTPUT_DISPLAY",
		:stz_signature = "? @var.Content()"
	]

]

#------------------------------#
#  GLOBAL INTERFACE
#------------------------------#

func NaturallyIn(cLanguage)
	return new stzNaturalEngine(cLanguage)

func Naturally()
	return new stzNaturalEngine("en")

#------------------------------#
#  ENHANCED NATURAL ENGINE
#------------------------------#

class stzNaturalEngine
	@cLanguage = "en"
	@aIgnoredWords = []
	@aMappings = []
	@aValues = []
	@aSemanticTokens = []
	@cCurrentObject = ""
	@cCurrentVariable = ""
	@aDefineRecallState = []
	@bDebugMode = 0
	@aDebugLog = []
	
	@result

	def init(cLang)
		if cLang != "" and cLang != nothing
			if isString(cLang)
				@cLanguage = lower(cLang)
			else
				@cLanguage = lower("" + cLang)
			ok
		ok
		This.LoadLanguageData()
		This.CreateIgnoreWordAttributes()
	
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
	
	def CreateIgnoreWordAttributes()
		nLen = len(@aIgnoredWords)
		for i = 1 to nLen
			cWord = @aIgnoredWords[i]
			addAttribute(this, cWord)
			eval("this." + cWord + ' = ""')
		next
	
	def braceExprEval(value)
		if NOT( isString(value) and value = "" )
			@aValues + value
		ok
	
	def braceError()
		if left(CatchError(), 11) = "Error (R24)"
			cUndefined = trim(split(CatchError(), ":")[3])
			@aValues + cUndefined
		ok
	
	def braceEnd()
		This.AddToDebugLog("Method: BraceEnd()")
		This.AddToDebugLog("Starting processing")
		This.AddToDebugLog("Raw values received: " + len(@aValues) + " items")

		This.Process()
	
	def Process()

		@aSemanticTokens = This.ConvertToSemanticTokens()

		This.AddToDebugLog("Method: Process()")
		This.AddToDebugLog("Semantic tokens created: " + len(@aSemanticTokens) + " tokens")
		
		cCode = This.GenerateCodeFromSemantics()

		This.AddToDebugLog("Generated Ring code:")
		This.AddToDebugLog(cCode)
		
		if cCode != ""
			eval(cCode)
		ok
	
	def ConvertToSemanticTokens()
		aTokens = []
		nLen = len(@aValues)
		
		This.AddToDebugLog("Method: ConvertToSemanticTokens()")
		This.AddToDebugLog("Converting to semantic tokens")
		
		for i = 1 to nLen
			cValue = @aValues[i]
			if NOT isString(cValue)
				cValue = "" + cValue
			ok
			
			# Skip ignored words
			if This.IsIgnoredWord(cValue)
				This.AddToDebugLog("Ignoring: '" + cValue + "'")
				loop
			ok
			
			# Convert to semantic token
			cSemantic = This.ToSemantic(cValue)
			
			if cSemantic != ""
				# Check if previous token suggests this should be a literal
				# (e.g., after VALUE_INDICATOR or after a method expecting params)
				bTreatAsLiteral = This.ShouldTreatAsLiteral(aTokens, cSemantic, cValue)
				
				if bTreatAsLiteral
					aTokens + [:type = "literal", :value = cValue]
					This.AddToDebugLog("Literal (context): '" + cValue + "' (was " + cSemantic + ")")
				else
					aTokens + [:type = "semantic", :value = cSemantic, :original = cValue]
					This.AddToDebugLog("Semantic: '" + cValue + "' -> " + cSemantic)
				ok
			else
				aTokens + [:type = "literal", :value = cValue]
				This.AddToDebugLog("Literal: '" + cValue + "'")
			ok
		next
		
		return aTokens
	
	def ShouldTreatAsLiteral(aTokens, cSemantic, cValue)
		# Check if we should treat this semantic word as a literal based on context
		nLen = len(aTokens)
		if nLen = 0
			return 0  # No context, use semantic
		ok
		
		# Get last token
		aLastToken = aTokens[nLen]
		
		# If last token was VALUE_INDICATOR, this should be literal
		if aLastToken[:type] = "semantic" and aLastToken[:value] = "VALUE_INDICATOR"
			return 1
		ok
		
		# If last token was a literal and before that was a method with params
		# then we're collecting parameters, treat as literal
		if aLastToken[:type] = "literal" and nLen >= 2
			aBeforeLast = aTokens[nLen-1]
			if aBeforeLast[:type] = "semantic" and left(aBeforeLast[:value], 7) = "METHOD_"
				# Check if that method needs parameters
				aOp = This.GetSemanticOperation(aBeforeLast[:value])
				if len(aOp) > 0 and HasKey(aOp, :requires_params) and aOp[:requires_params] > 0
					return 1  # We're in parameter collection mode
				ok
			ok
		ok
		
		return 0  # Use semantic meaning
	
	def IsIgnoredWord(cWord)
		cLower = lower(cWord)
		return ring_find(@aIgnoredWords, cLower) > 0
	
	def ToSemantic(cWord)
		cLower = lower(cWord)
		
		# Handle @method@ patterns
		bDefine = left(cLower, 1) = "@"
		bRecall = right(cLower, 1) = "@"
		
		if bDefine
			cLower = substr(cLower, 2)
		but bRecall
			cLower = left(cLower, len(cLower)-1)
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
				
				# Handle define pattern
				if left(cSemantic, 1) = "@"
					cCleanSemantic = substr(cSemantic, 2)
					@aDefineRecallState + [:semantic = cCleanSemantic, :index = i]
					i++
					loop
				ok
				
				# Handle recall pattern
				if right(cSemantic, 1) = "@"
					cCleanSemantic = left(cSemantic, len(cSemantic)-1)
					aResult = This.ProcessMethodWithModifiers(i, cCleanSemantic)
					if len(aResult[:code]) > 0
						# Insert at defined position
						nDefineIdx = This.FindDefineIndex(cCleanSemantic)
						if nDefineIdx > 0
							# Insert code at the defined position in output
							aCodeLines + aResult[:code]
						ok
					ok
					i = aResult[:next_index]
					loop
				ok
				
				if cSemantic = "CREATE_OBJECT"
					aResult = This.ProcessObjectCreation(i)
					if len(aResult[:code]) > 0
						aCodeLines + aResult[:code]
					ok
					i = aResult[:next_index]
					
				but left(cSemantic, 7) = "METHOD_"
					aResult = This.ProcessMethod(i, cSemantic)
					if len(aResult[:code]) > 0
						aCodeLines + aResult[:code]
					ok
					i = aResult[:next_index]
					
				but cSemantic = "OUTPUT_DISPLAY"
					aOp = This.GetSemanticOperation(cSemantic)
					if len(aOp) > 0
						cCode = aOp[:stz_signature]
						cCode = substr(cCode, "@var", @cCurrentVariable)
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
		

		cCode = JoinXT(aCodeLines, NL) + NL + "@result = " + @cCurrentVariable + ".Content()"
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
			if aToken[:type] = "semantic" and left(aToken[:value], 7) = "OBJECT_"
				cObjectType = aToken[:value]
				
				# Find value
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
				cConstructor = substr(cConstructor, "@", @@(cValue))
				cCode = @cCurrentVariable + " = " + cConstructor
				return [:code = cCode, :next_index = nNextIndex]
			ok
		ok
		
		return [:code = "", :next_index = nIndex+1]
	
	def ProcessMethod(nIndex, cSemantic)
		This.AddToDebugLog("Method: ProcessMethod(nIndex, cSemantic)")
		This.AddToDebugLog("Processing Method: " + cSemantic + " at index " + nIndex)
		
		aOp = This.GetSemanticOperation(cSemantic)
		if len(aOp) = 0
			This.AddToDebugLog("ERROR: No operation found for " + cSemantic)
			return [:code = "", :next_index = nIndex+1]
		ok
		
		This.AddToDebugLog("Operation found: " + aOp[:stz_method])
		
		cCode = aOp[:stz_signature]
		cCode = substr(cCode, "@var", @cCurrentVariable)
		
		# Check if method requires parameters
		if HasKey(aOp, :requires_params) and aOp[:requires_params] > 0
			This.AddToDebugLog("Method requires " + aOp[:requires_params] + " parameters")
			
			# Extract parameters after method
			aResult = This.ExtractMethodParameters(nIndex, aOp[:requires_params])
			aParams = aResult[:params]
			nNextIndex = aResult[:next_index]
			
			This.AddToDebugLog("Extracted " + len(aParams) + " parameters")
			for i = 1 to len(aParams)
				This.AddToDebugLog("  Param" + i + " = '" + aParams[i] + "'")
			next
			This.AddToDebugLog("Next index will be: " + nNextIndex)
			
			# Replace parameter placeholders
			for i = 1 to len(aParams)
				cPlaceholder = "@param" + i
				cParamValue = @@(aParams[i])
				This.AddToDebugLog("Replacing " + cPlaceholder + " with " + cParamValue)
				cCode = substr(cCode, cPlaceholder, cParamValue)
			next
			
			This.AddToDebugLog("Final code: " + cCode)
			return [:code = cCode, :next_index = nNextIndex]
		ok
		
		This.AddToDebugLog("Method has no parameters, final code: " + cCode)
		return [:code = cCode, :next_index = nIndex+1]
	
	def ExtractMethodParameters(nIndex, nParamCount)
		# Extract literal values following the method
		# Pattern: METHOD literal1 [VALUE_INDICATOR] literal2
		This.AddToDebugLog("Method: ExtractMethodParameters(nIndex, nParamCount)")
		This.AddToDebugLog("Extracting " + nParamCount + " parameters from index " + nIndex)
		
		aParams = []
		nLen = len(@aSemanticTokens)
		nLastIndex = nIndex
		
		This.AddToDebugLog("Total tokens available: " + nLen)
		
		for i = nIndex+1 to nLen
			aToken = @aSemanticTokens[i]
			
			This.AddToDebugLog("Token[" + i + "]: type=" + aToken[:type] + ", value=" + aToken[:value])
			
			# Track last processed index
			nLastIndex = i
			
			# Skip VALUE_INDICATOR tokens (like "with")
			if aToken[:type] = "semantic" and aToken[:value] = "VALUE_INDICATOR"
				This.AddToDebugLog("  Skipping VALUE_INDICATOR at index " + i)
				loop
			ok
			
			# Collect literal values
			if aToken[:type] = "literal"
				aParams + aToken[:value]
				This.AddToDebugLog("Collected literal: '" + aToken[:value] + "' (total params: " + len(aParams) + ")")
				if len(aParams) = nParamCount
					This.AddToDebugLog("Reached required param count, stopping at index " + i)
					exit
				ok
			ok
			
			# Stop if we hit another method or output
			if aToken[:type] = "semantic" and 
			   (left(aToken[:value], 7) = "METHOD_" or aToken[:value] = "OUTPUT_DISPLAY")
				nLastIndex = i - 1  # Don't consume the next method token
				This.AddToDebugLog("Hit next semantic at index " + i + ", backing up to " + nLastIndex)
				exit
			ok
		next
		
		This.AddToDebugLog("Extraction complete. Params: " + len(aParams) + ", Next index: " + (nLastIndex + 1))
		
		return [:params = aParams, :next_index = nLastIndex + 1]
	
	def ProcessMethodWithModifiers(nIndex, cSemantic)
		aOp = This.GetSemanticOperation(cSemantic)
		if len(aOp) = 0
			return [:code = "", :next_index = nIndex+1]
		ok
		
		cCode = aOp[:stz_signature]
		cCode = substr(cCode, "@var", @cCurrentVariable)
		
		# Look for modifiers
		if HasKey(aOp, :supports_modifiers) and aOp[:supports_modifiers] = 1
			nLen = len(@aSemanticTokens)
			for i = nIndex+1 to nLen
				aToken = @aSemanticTokens[i]
				if aToken[:type] = "semantic"
					nModLen = len(aOp[:modifiers])
					for j = 1 to nModLen
						aMod = aOp[:modifiers][j]
						if aMod[:semantic_id] = aToken[:value]
							cCode = substr(cCode, aOp[:stz_method], aMod[:stz_method])
							cCode = substr(cCode, "()", "([" + aMod[:stz_param] + "])")
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

	#------------------------------#
	#  DEBUG METHODS
	#------------------------------#
	
	def EnableDebug()
		@bDebugMode = 1
		@aDebugLog = []
	
	def DisableDebug()
		@bDebugMode = 0
	
	def AddToDebugLog(cMessage)
		if @bDebugMode
			@aDebugLog + [
				:timestamp = clock(),
				:message = cMessage
			]
		ok
	
	def DebugLog()
		return @aDebugLog
	
	def ClearDebugLog()
		@aDebugLog = []

		def ClearDebug()
			@aDebugLog = []

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
