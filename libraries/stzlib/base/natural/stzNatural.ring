# Enhanced Multilingual Softanza Natural Programming System
# Complete separation of language data from processing logic

# ═══════════════════════════════════════════════════════
#  GLOBAL LANGUAGE REGISTRY - Pure Data Configuration
# ═══════════════════════════════════════════════════════

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
			
			# Method: Box
			[:natural = "box", :semantic = "METHOD_BOX"],
			[:natural = "frame", :semantic = "METHOD_BOX"],
			
			# Modifier: Rounded
			[:natural = "rounded", :semantic = "MODIFIER_ROUNDED"],
			
			# Output
			[:natural = "show", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "display", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "print", :semantic = "OUTPUT_DISPLAY"],
			
			# Context words (kept for natural flow but ignored)
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
			[:natural = "ɗauke", :semantic = "VALUE_INDICATOR"],
			[:natural = "raba", :semantic = "METHOD_SPACIFY"],
			[:natural = "maida", :semantic = "METHOD_UPPERCASE"],
			[:natural = "maiɗa", :semantic = "METHOD_UPPERCASE"],
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
			[:natural = "اَكْوَتِ", :semantic = "METHOD_BOX"],
			[:natural = "اَكْوَتِن", :semantic = "METHOD_BOX"],
			[:natural = "زَغَيِ", :semantic = "MODIFIER_ROUNDED"],
			[:natural = "نُوْنَ", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "اَلّو", :semantic = "CONTEXT_IGNORED"]
		]
	]

]

# ═══════════════════════════════════════════════════════
#  SEMANTIC REGISTRY - Language-Independent Operations
# ═══════════════════════════════════════════════════════

$aSemanticOperations = [
	[
		:semantic_id = "OBJECT_STRING",
		:object_type = "stzString",
		:constructor = "StzStringQ(@)",
		:variable = "oStr"
	],
	
	[
		:semantic_id = "METHOD_SPACIFY",
		:ring_method = "Spacify",
		:ring_signature = "@var.Spacify()"
	],
	
	[
		:semantic_id = "METHOD_UPPERCASE",
		:ring_method = "Uppercase",
		:ring_signature = "@var.Uppercase()"
	],
	
	[
		:semantic_id = "METHOD_BOX",
		:ring_method = "Box",
		:ring_signature = "@var.Box()",
		:supports_modifiers = 1,
		:modifiers = [
			[
				:semantic_id = "MODIFIER_ROUNDED",
				:ring_method = "BoxXT",
				:ring_param = ":Rounded = 1"
			]
		]
	],
	
	[
		:semantic_id = "OUTPUT_DISPLAY",
		:ring_signature = "? @var.Content()"
	]
]

# ═══════════════════════════════════════════════════════
#  GLOBAL INTERFACE
# ═══════════════════════════════════════════════════════

func NaturallyIn(cLanguage)
	return new stzNaturalEngine(cLanguage)

func Naturally()
	return new stzNaturalEngine("en")

# ═══════════════════════════════════════════════════════
#  ENHANCED NATURAL ENGINE
# ═══════════════════════════════════════════════════════

class stzNaturalEngine
	@cLanguage = "en"
	@aIgnoredWords = []
	@aMappings = []
	@aValues = []
	@aSemanticTokens = []
	@cCurrentObject = ""
	@cCurrentVariable = ""
	@aDefineRecallState = []
	
	def init(cLang)
		if cLang != "" and cLang != ""
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
		This.Process()
	
	def Process()
		@aSemanticTokens = This.ConvertToSemanticTokens()
		cCode = This.GenerateCodeFromSemantics()
		if cCode != ""
			eval(cCode)
		ok
	
	def ConvertToSemanticTokens()
		aTokens = []
		nLen = len(@aValues)
		
		for i = 1 to nLen
			cValue = @aValues[i]
			if NOT isString(cValue)
				cValue = "" + cValue
			ok
			
			# Skip ignored words
			if This.IsIgnoredWord(cValue)
				loop
			ok
			
			# Convert to semantic token
			cSemantic = This.ToSemantic(cValue)
			
			if cSemantic != ""
				aTokens + [:type = "semantic", :value = cSemantic, :original = cValue]
			else
				aTokens + [:type = "literal", :value = cValue]
			ok
		next
		
		return aTokens
	
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
						cCode = aOp[:ring_signature]
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
		
		return JoinXT(aCodeLines, NL)
	
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
		aOp = This.GetSemanticOperation(cSemantic)
		if len(aOp) = 0
			return [:code = "", :next_index = nIndex+1]
		ok
		
		cCode = aOp[:ring_signature]
		cCode = substr(cCode, "@var", @cCurrentVariable)
		
		return [:code = cCode, :next_index = nIndex+1]
	
	def ProcessMethodWithModifiers(nIndex, cSemantic)
		aOp = This.GetSemanticOperation(cSemantic)
		if len(aOp) = 0
			return [:code = "", :next_index = nIndex+1]
		ok
		
		cCode = aOp[:ring_signature]
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
							cCode = substr(cCode, aOp[:ring_method], aMod[:ring_method])
							cCode = substr(cCode, "()", "([" + aMod[:ring_param] + "])")
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
