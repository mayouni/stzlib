# Enhanced Multilingual Softanza Natural Programming System
# Refactored to use string-based natural code input


#-- GLOBAL LANGUAGE REGISTRY  

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
	]
]

#--  SEMANTIC REGISTRY - Organized by Object Type

$aSemanticOperations = [

	#--- OBJECTS

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

	#--- COMMON METHODS (work on multiple object types)

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

	#--- STRING-SPECIFIC METHODS

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

	#--- NUMBER-SPECIFIC METHODS

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

	#--- OUTPUT

	[
		:semantic_id = "OUTPUT_DISPLAY",
		:stz_signature = "? @var.Content()"
	]
]

#-- GLOBAL FUNCTIONS

func NaturallyIn(cLanguageOrCode, _cCode_)
	if _cCode_ = ""
		return new stzNaturalEngine(cLanguageOrCode, "")
	else
		return new stzNaturalEngine(cLanguageOrCode, _cCode_)
	ok

func Naturally(_cCode_)
	if _cCode_ = ""
		return new stzNaturalEngine("en", "")
	else
		return new stzNaturalEngine("en", _cCode_)
	ok

#-- NATURAL ENGINE CLASS

class stzNaturalEngine from stzObject
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

	def init(cLangOrCode, _cCode_)
		# Handle different initialization patterns
		if _cCode_ != ""
			# Case: Naturally("en", "code here")
			@cLanguage = lower(cLangOrCode)
			@cNaturalCode = _cCode_
		else
			# Detect if first param is language code or natural code
			if This.IsLanguageCode(cLangOrCode)
				# Case: NaturallyIn("hausa")
				@cLanguage = lower(cLangOrCode)
			else
				# Case: Naturally("code here")
				@cLanguage = "en"
				if cLangOrCode != ""
					@cNaturalCode = cLangOrCode
				ok
			ok
		ok
		
		This.LoadLanguageData()
		
		# Auto-execute if code provided
		if @cNaturalCode != ""
			This.Execute(@cNaturalCode)
		ok
	
	def IsLanguageCode(cStr)
		if cStr = "" or NOT isString(cStr)
			return 0
		ok
		
		_cLower_ = lower(cStr)
		
		# Check against known language codes
		_nLen_ = len($aLanguageDefinitions)
		for _i_ = 1 to _nLen_
			_aLang_ = $aLanguageDefinitions[_i_]
			if _aLang_[:code] = _cLower_ or _aLang_[:name] = _cLower_
				return 1
			ok
		next
		
		return 0
	
	def Execute(_cCode_)
		if _cCode_ = "" or NOT isString(_cCode_)
			return
		ok
		
		@cNaturalCode = _cCode_
		This.AddToDebugLog("Executing natural code")
		This.AddToDebugLog("Code length: " + stzlen(_cCode_) + " chars")
		
		# Tokenize the code
		This.TokenizeCode(_cCode_)
	
		This.AddToDebugLog("Raw values: " + len(@aValues) + " items")
		_nLen_ = len(@aValues)
		for _i_ = 1 to _nLen_
			_val_ = @aValues[_i_]
			This.AddToDebugLog("Value[" + _i_ + "]: type=" + type(_val_) + ", content=" + @@(_val_))
		next
		
		This.Process()
	
	def TokenizeCode(_cCode_)
		@aValues = []
		
		# Clean the code
		_cCode_ = trim(_cCode_)
		
		# Split by whitespace while preserving quoted strings
		_aTokens_ = This.SmartSplit(_cCode_)
		
		@aValues = _aTokens_
	
	def SmartSplit(_cCode_)
	    _aResult_ = []
	    _cCurrent_ = ""
	    _bInQuote_ = 0
	    _cQuoteChar_ = ""
	
	    _acChars_ = Chars(_cCode_)
	    _nLen_ = len(_acChars_)
	    
	    for _i_ = 1 to _nLen_
	        _cChar_ = _acChars_[_i_]
	        
	        if (_cChar_ = "'" or _cChar_ = '"' or _cChar_ = "`") and NOT _bInQuote_
	            _bInQuote_ = 1
	            _cQuoteChar_ = _cChar_
	            loop
	        ok
	        
	        if _bInQuote_ and _cChar_ = _cQuoteChar_
	            if _cCurrent_ != ""
	                _aResult_ + _cCurrent_
	                _cCurrent_ = ""
	            ok
	            _bInQuote_ = 0
	            _cQuoteChar_ = ""
	            loop
	        ok
	        
	        if _bInQuote_
	            _cCurrent_ += _cChar_
	            loop
	        ok
	
	        if _cChar_ = " " or _cChar_ = TAB or _cChar_ = NL or _cChar_ = CR
	            if _cCurrent_ != ""
	                _aResult_ + _cCurrent_
	                _cCurrent_ = ""
	            ok
	        else
	            _cCurrent_ += _cChar_
	        ok
	    next
	    
	    if _cCurrent_ != ""
	        _aResult_ + _cCurrent_
	    ok

	    return _aResult_
	
	def LoadLanguageData()
		_aLangDef_ = This.FindLanguageDefinition(@cLanguage)
		if len(_aLangDef_) > 0
			@aIgnoredWords = _aLangDef_[:ignored_words]
			@aMappings = _aLangDef_[:semantic_mappings]
		ok
	
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
		This.AddToDebugLog("Tokens: " + len(@aSemanticTokens))
		
		_cCode_ = This.GenerateCodeFromSemantics()
		This.AddToDebugLog("Generated code:")
		This.AddToDebugLog(_cCode_)
		
		if _cCode_ != ""
			eval(_cCode_)
		ok
	
	def ConvertToSemanticTokens()
		_aTokens_ = []
		_nLen_ = len(@aValues)
		
		This.AddToDebugLog("Converting to semantic tokens")
		
		for _i_ = 1 to _nLen_
			_cValue_ = @aValues[_i_]
			
			# Handle lists
			if isList(_cValue_)
				_aTokens_ + [:type = "literal", :value = _cValue_]
				This.AddToDebugLog("List literal: " + stzlen(_cValue_) + " items")
				loop
			ok
			
			# Convert to string
			if NOT isString(_cValue_)
				_cValue_ = "" + _cValue_
			ok
			
			This.AddToDebugLog("Processing: '" + _cValue_ + "'")
			
			# Skip ignored
			if This.IsIgnoredWord(_cValue_)
				This.AddToDebugLog("  Ignored")
				loop
			ok
			
			# Get semantic
			_cSemantic_ = This.ToSemantic(_cValue_)
			
			if _cSemantic_ != ""
				_bLiteral_ = This.ShouldTreatAsLiteral(_aTokens_, _cSemantic_, _cValue_)
				
				if _bLiteral_
					_aTokens_ + [:type = "literal", :value = _cValue_]
					This.AddToDebugLog("  Literal (context)")
				else
					_aTokens_ + [:type = "semantic", :value = _cSemantic_, :original = _cValue_]
					This.AddToDebugLog("  Semantic: " + _cSemantic_)
				ok
			else
				_aTokens_ + [:type = "literal", :value = _cValue_]
				This.AddToDebugLog("  Literal")
			ok
		next
		
		return _aTokens_
	
	def ShouldTreatAsLiteral(_aTokens_, _cSemantic_, _cValue_)
		_nLen_ = len(_aTokens_)
		if _nLen_ = 0
			return 0
		ok
		
		_aLast_ = _aTokens_[_nLen_]
		
		# After VALUE_INDICATOR
		if _aLast_[:type] = "semantic" and _aLast_[:value] = "VALUE_INDICATOR"
			return 1
		ok
		
		# In parameter collection
		if _aLast_[:type] = "literal" and _nLen_ >= 2
			_aBeforeLast_ = _aTokens_[_nLen_-1]
			if _aBeforeLast_[:type] = "semantic" and left(_aBeforeLast_[:value], 7) = "METHOD_"
				_aOp_ = This.GetSemanticOperation(_aBeforeLast_[:value])
				if len(_aOp_) > 0 and HasKey(_aOp_, :requires_params) and _aOp_[:requires_params] > 0
					return 1
				ok
			ok
		ok
		
		return 0
	
	def IsIgnoredWord(cWord)
		return ring_find(@aIgnoredWords, lower(cWord)) > 0
	
	def ToSemantic(cWord)
		_cLower_ = lower(cWord)

		_bDefine_ = left(_cLower_, 1) = "@"
		_bRecall_ = right(_cLower_, 1) = "@"
		
		if _bDefine_
			_cLower_ = @StzMid(_cLower_, 2, stzlen(_cLower_))
		but _bRecall_
			_cLower_ = left(_cLower_, stzlen(_cLower_)-1)
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
		_i_ = 1

		while _i_ <= _nLen_
			_aToken_ = @aSemanticTokens[_i_]
			
			if _aToken_[:type] = "semantic"
				_cSemantic_ = _aToken_[:value]
				
				# Define pattern
				if left(_cSemantic_, 1) = "@"
					_cClean_ = @StzMid(_cSemantic_, 2, stzlen(_cSemantic_))
					@aDefineRecallState + [:semantic = _cClean_, :index = _i_]
					_i_++
					loop
				ok
				
				# Recall pattern
				if right(_cSemantic_, 1) = "@"
					_cClean_ = left(_cSemantic_, stzlen(_cSemantic_)-1)
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
					
				but left(_cSemantic_, 7) = "METHOD_"
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
			StzRaise('Unsupported object type while processing "CREATE_OBJECT"!')
		ok

		_cCode_ = JoinXT(_aCodeLines_, NL) + NL + "@result = " + @cCurrentVariable + ".Content()"
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
		_nNextIndex_ = nIndex + 1
		
		for _i_ = nIndex+1 to _nLen_
			_aToken_ = @aSemanticTokens[_i_]
			if _aToken_[:type] = "semantic" and left(_aToken_[:value], 7) = "OBJECT_"
				_cObjectType_ = _aToken_[:value]
				
				for j = _i_+1 to _nLen_
					_aNextToken_ = @aSemanticTokens[j]
					if _aNextToken_[:type] = "literal"
						_cValue_ = _aNextToken_[:value]
						_nNextIndex_ = j + 1
						exit 2
					ok
				next
			ok
		next
		
		if _cObjectType_ != ""
			_aOp_ = This.GetSemanticOperation(_cObjectType_)

			if len(_aOp_) > 0
				@cCurrentObject = _aOp_[:object_type]
				@cCurrentVariable = _aOp_[:variable]
				_cConstructor_ = _aOp_[:constructor]
				
				# Handle lists
				if isList(_cValue_)
					_cListStr_ = "["
					_nLen_ = stzlen(_cValue_)
					for k = 1 to _nLen_
						if k > 1
							_cListStr_ += ", "
						ok
						_cListStr_ += @@(_cValue_[k])
					next
					_cListStr_ += "]"
					_cConstructor_ = StzReplace(_cConstructor_, "@", _cListStr_)
				else
					_cConstructor_ = StzReplace(_cConstructor_, "@", @@(_cValue_))
				ok
				
				_cCode_ = @cCurrentVariable + " = " + _cConstructor_
				return [:code = _cCode_, :next_index = _nNextIndex_]
			ok
		ok
		
		return [:code = "", :next_index = nIndex+1]
	
	def ProcessMethod(nIndex, _cSemantic_)
		This.AddToDebugLog("Processing method: " + _cSemantic_)
		
		_aOp_ = This.GetSemanticOperation(_cSemantic_)
		if len(_aOp_) = 0
			return [:code = "", :next_index = nIndex+1]
		ok
		
		_cCode_ = StzReplace(_aOp_[:stz_signature], "@var", @cCurrentVariable)
		
		if HasKey(_aOp_, :requires_params) and _aOp_[:requires_params] > 0
			_aResult_ = This.ExtractMethodParameters(nIndex, _aOp_[:requires_params])
			_aParams_ = _aResult_[:params]
			_nNextIndex_ = _aResult_[:next_index]
			_nLen_ = len(_aParams_)

			for _i_ = 1 to _nLen_
				_cPlaceholder_ = "@param" + _i_
				_cParamValue_ = @@(_aParams_[_i_])
				_cCode_ = StzReplace(_cCode_, _cPlaceholder_, _cParamValue_)
			next
			
			return [:code = _cCode_, :next_index = _nNextIndex_]
		ok
		
		return [:code = _cCode_, :next_index = nIndex+1]
	
	def ExtractMethodParameters(nIndex, nParamCount)
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
				_aParams_ + _aToken_[:value]
				if len(_aParams_) = nParamCount
					exit
				ok
			ok
			
			if _aToken_[:type] = "semantic" and 
			   (left(_aToken_[:value], 7) = "METHOD_" or _aToken_[:value] = "OUTPUT_DISPLAY")
				_nLastIndex_ = _i_ - 1
				exit
			ok
		next
		
		return [:params = _aParams_, :next_index = _nLastIndex_ + 1]
	
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
					for j = 1 to _nModLen_
						_aMod_ = _aOp_[:modifiers][j]
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
