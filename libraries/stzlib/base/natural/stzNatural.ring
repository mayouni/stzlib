# Enhanced Multilingual Softanza Natural Programming System
# Refactored to use string-based natural code input

#------------------------------#
#  GLOBAL LANGUAGE REGISTRY
#------------------------------#

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
			# Object creation
			[:natural = "create", :semantic = "CREATE_OBJECT"],
			[:natural = "make", :semantic = "CREATE_OBJECT"],
			[:natural = "new", :semantic = "CREATE_OBJECT"],
			
			# Object types
			[:natural = "string", :semantic = "OBJECT_STRING"],
			[:natural = "text", :semantic = "OBJECT_STRING"],
			[:natural = "stzstring", :semantic = "OBJECT_STRING"],

			[:natural = "list", :semantic = "OBJECT_LIST"],
			[:natural = "stzlist", :semantic = "OBJECT_LIST"],

			[:natural = "number", :semantic = "OBJECT_NUMBER"],
			[:natural = "stznumber", :semantic = "OBJECT_NUMBER"],

			# Value indicators
			[:natural = "with", :semantic = "VALUE_INDICATOR"],
			
			# Common methods (work on multiple objects)
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

			# String-specific methods
			[:natural = "spacify", :semantic = "METHOD_SPACIFY"],
			[:natural = "addspaces", :semantic = "METHOD_SPACIFY"],
			[:natural = "box", :semantic = "METHOD_BOX"],
			[:natural = "frame", :semantic = "METHOD_BOX"],
			[:natural = "rounded", :semantic = "MODIFIER_ROUNDED"],

			# Number-specific methods
			[:natural = "increment", :semantic = "METHOD_INCREMENT"],
			[:natural = "decrement", :semantic = "METHOD_DECREMENT"],
			[:natural = "multiply", :semantic = "METHOD_MULTIPLY"],
			[:natural = "divide", :semantic = "METHOD_DIVIDE"],
			
			# Output
			[:natural = "show", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "display", :semantic = "OUTPUT_DISPLAY"],
			[:natural = "print", :semantic = "OUTPUT_DISPLAY"],
			
			# Context words
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
#  SEMANTIC REGISTRY - Organized by Object Type
#------------------------------#

$aSemanticOperations = [

	#--- OBJECTS ---

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

	#--- COMMON METHODS (work on multiple object types) ---

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

	#--- STRING-SPECIFIC METHODS ---

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

	#--- NUMBER-SPECIFIC METHODS ---

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

	#--- OUTPUT ---

	[
		:semantic_id = "OUTPUT_DISPLAY",
		:stz_signature = "? @var.Content()"
	]
]

#------------------------------#
#  GLOBAL INTERFACE
#------------------------------#

func NaturallyIn(cLanguageOrCode, cCode)
	if cCode = NULL or cCode = ""
		return new stzNaturalEngine(cLanguageOrCode, NULL)
	else
		return new stzNaturalEngine(cLanguageOrCode, cCode)
	ok

func Naturally(cCode)
	if cCode = NULL or cCode = ""
		return new stzNaturalEngine("en", NULL)
	else
		return new stzNaturalEngine("en", cCode)
	ok

#------------------------------#
#  NATURAL ENGINE
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
	@cNaturalCode = ""

	def init(cLangOrCode, cCode)
		# Handle different initialization patterns
		if cCode != NULL and cCode != ""
			# Case: Naturally("en", "code here")
			@cLanguage = lower(cLangOrCode)
			@cNaturalCode = cCode
		else
			# Detect if first param is language code or natural code
			if This.IsLanguageCode(cLangOrCode)
				# Case: NaturallyIn("hausa")
				@cLanguage = lower(cLangOrCode)
			else
				# Case: Naturally("code here")
				@cLanguage = "en"
				if cLangOrCode != NULL
					@cNaturalCode = cLangOrCode
				ok
			ok
		ok
		
		This.LoadLanguageData()
		
		# Auto-execute if code provided
		if @cNaturalCode != "" and @cNaturalCode != NULL
			This.Execute(@cNaturalCode)
		ok
	
	def IsLanguageCode(cStr)
		if cStr = NULL or NOT isString(cStr)
			return 0
		ok
		
		cLower = lower(cStr)
		
		# Check against known language codes
		nLen = len($aLanguageDefinitions)
		for i = 1 to nLen
			aLang = $aLanguageDefinitions[i]
			if aLang[:code] = cLower or aLang[:name] = cLower
				return 1
			ok
		next
		
		return 0
	
	def Execute(cCode)
		if cCode = NULL or NOT isString(cCode)
			return
		ok
		
		@cNaturalCode = cCode
		This.AddToDebugLog("Executing natural code")
		This.AddToDebugLog("Code length: " + len(cCode) + " chars")
		
		# Tokenize the code
		This.TokenizeCode(cCode)
		
		This.AddToDebugLog("Raw values: " + len(@aValues) + " items")
		for i = 1 to len(@aValues)
			val = @aValues[i]
			This.AddToDebugLog("Value[" + i + "]: type=" + type(val) + ", content=" + @@(val))
		next
		
		This.Process()
	
	def TokenizeCode(cCode)
		@aValues = []
		
		# Clean the code
		cCode = trim(cCode)
		
		# Split by whitespace while preserving quoted strings
		aTokens = This.SmartSplit(cCode)
		
		@aValues = aTokens
	
	def SmartSplit(cCode)
		aResult = []
		cCurrent = ""
		bInQuote = 0
		cQuoteChar = ""

		acChars = Chars(cCode)
		nLen = len(acChars)
		
		for i = 1 to nLen
			cChar = acChars[i]
			
			# Handle quotes
			if (cChar = "'" or cChar = '"' or cChar = "`") and NOT bInQuote
				bInQuote = 1
				cQuoteChar = cChar
				loop
			ok
			
			if bInQuote and cChar = cQuoteChar
				# End of quoted string
				if cCurrent != ""
					aResult + cCurrent
					cCurrent = ""
				ok
				bInQuote = 0
				cQuoteChar = ""
				loop
			ok
			
			# Inside quotes, collect everything
			if bInQuote
				cCurrent += cChar
				loop
			ok
			
			# Outside quotes, split on whitespace
			if cChar = " " or cChar = TAB or cChar = NL or cChar = CR
				if cCurrent != ""
					aResult + cCurrent
					cCurrent = ""
				ok
			else
				cCurrent += cChar
			ok
		next
		
		# Add final token
		if cCurrent != ""
			aResult + cCurrent
		ok
		
		return aResult
	
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
		
		if cCode != ""
			eval(cCode)
		ok
	
	def ConvertToSemanticTokens()
		aTokens = []
		nLen = len(@aValues)
		
		This.AddToDebugLog("Converting to semantic tokens")
		
		for i = 1 to nLen
			cValue = @aValues[i]
			
			# Handle lists
			if isList(cValue)
				aTokens + [:type = "literal", :value = cValue]
				This.AddToDebugLog("List literal: " + len(cValue) + " items")
				loop
			ok
			
			# Convert to string
			if NOT isString(cValue)
				cValue = "" + cValue
			ok
			
			This.AddToDebugLog("Processing: '" + cValue + "'")
			
			# Skip ignored
			if This.IsIgnoredWord(cValue)
				This.AddToDebugLog("  Ignored")
				loop
			ok
			
			# Get semantic
			cSemantic = This.ToSemantic(cValue)
			
			if cSemantic != ""
				bLiteral = This.ShouldTreatAsLiteral(aTokens, cSemantic, cValue)
				
				if bLiteral
					aTokens + [:type = "literal", :value = cValue]
					This.AddToDebugLog("  Literal (context)")
				else
					aTokens + [:type = "semantic", :value = cSemantic, :original = cValue]
					This.AddToDebugLog("  Semantic: " + cSemantic)
				ok
			else
				aTokens + [:type = "literal", :value = cValue]
				This.AddToDebugLog("  Literal")
			ok
		next
		
		return aTokens
	
	def ShouldTreatAsLiteral(aTokens, cSemantic, cValue)
		nLen = len(aTokens)
		if nLen = 0
			return 0
		ok
		
		aLast = aTokens[nLen]
		
		# After VALUE_INDICATOR
		if aLast[:type] = "semantic" and aLast[:value] = "VALUE_INDICATOR"
			return 1
		ok
		
		# In parameter collection
		if aLast[:type] = "literal" and nLen >= 2
			aBeforeLast = aTokens[nLen-1]
			if aBeforeLast[:type] = "semantic" and left(aBeforeLast[:value], 7) = "METHOD_"
				aOp = This.GetSemanticOperation(aBeforeLast[:value])
				if len(aOp) > 0 and HasKey(aOp, :requires_params) and aOp[:requires_params] > 0
					return 1
				ok
			ok
		ok
		
		return 0
	
	def IsIgnoredWord(cWord)
		return ring_find(@aIgnoredWords, lower(cWord)) > 0
	
	def ToSemantic(cWord)
		cLower = lower(cWord)
		
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
				
				# Define pattern
				if left(cSemantic, 1) = "@"
					cClean = substr(cSemantic, 2)
					@aDefineRecallState + [:semantic = cClean, :index = i]
					i++
					loop
				ok
				
				# Recall pattern
				if right(cSemantic, 1) = "@"
					cClean = left(cSemantic, len(cSemantic)-1)
					aResult = This.ProcessMethodWithModifiers(i, cClean)
					if len(aResult[:code]) > 0
						aCodeLines + aResult[:code]
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
						cCode = substr(aOp[:stz_signature], "@var", @cCurrentVariable)
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
		
		if @cCurrentVariable = trim("")
			StzRaise('Unsupported object type while processing "CREATE_OBJECT"!')
		ok

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
				
				# Handle lists
				if isList(cValue)
					cListStr = "["
					for k = 1 to len(cValue)
						if k > 1
							cListStr += ", "
						ok
						cListStr += @@(cValue[k])
					next
					cListStr += "]"
					cConstructor = substr(cConstructor, "@", cListStr)
				else
					cConstructor = substr(cConstructor, "@", @@(cValue))
				ok
				
				cCode = @cCurrentVariable + " = " + cConstructor
				return [:code = cCode, :next_index = nNextIndex]
			ok
		ok
		
		return [:code = "", :next_index = nIndex+1]
	
	def ProcessMethod(nIndex, cSemantic)
		This.AddToDebugLog("Processing method: " + cSemantic)
		
		aOp = This.GetSemanticOperation(cSemantic)
		if len(aOp) = 0
			return [:code = "", :next_index = nIndex+1]
		ok
		
		cCode = substr(aOp[:stz_signature], "@var", @cCurrentVariable)
		
		if HasKey(aOp, :requires_params) and aOp[:requires_params] > 0
			aResult = This.ExtractMethodParameters(nIndex, aOp[:requires_params])
			aParams = aResult[:params]
			nNextIndex = aResult[:next_index]
			
			for i = 1 to len(aParams)
				cPlaceholder = "@param" + i
				cParamValue = @@(aParams[i])
				cCode = substr(cCode, cPlaceholder, cParamValue)
			next
			
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
			   (left(aToken[:value], 7) = "METHOD_" or aToken[:value] = "OUTPUT_DISPLAY")
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
		
		cCode = substr(aOp[:stz_signature], "@var", @cCurrentVariable)
		
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
	
	def NaturalCode()
		return @cNaturalCode
