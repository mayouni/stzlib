# Dynamic Softanza Natural Programming System
# Completely data-driven with zero hardcoded object/method knowledge

@aErrors = []
@bDebugMode = 0

# Global configuration - completely configurable
$aWordsToIgnore = [
    "is", "are", "should", "must", "can", "will", "the",
    "this_", "that", "these", "those", "and_", "then", "also", 
    "plus", "with", "using", "to_", "by", "containing", "be", "being",
    "decorated", "final", "result", "object", "substring", "at", "position",
    "a", "it"
]

$aTempWordsToIgnore = [ "it" ]

$aPositionIndicators = [
    "first", "second", "third", "fourth", "fifth", "sixth", 
    "seventh", "eighth", "ninth", "tenth", "last"
]

# Enhanced Softanza Objects Registry - Complete metadata-driven approach
$aSoftanzaObjects = [

    [
        :name = "stzstring",
        :constructor = "StzStringQ(@)",
        :variable = "oStr",

        :creation_patterns = [
            [:trigger_words = ["create", "make", "new"], :value_position = "after"]
        ],

        :methods = [

            [
                :name = "replace",
                :alternatives = ["substitute", "change", "swap"],
                :ring_method = "Replace",
                :type = "global_replacement",

                :patterns = [
                    [
                        :template = "{method} {old_value} with {new_value}",
                        :params = [
                            [:name = "old_value", :type = "string", :position = 1],
                            [:name = "new_value", :type = "string", :position = 2]
                        ],
                        :ring_signature = "@var.Replace(@old_value, @new_value)"
                    ]
                ],

                :semantic_triggers = ["replace", "substitute", "change", "swap"]
            ],

            [
                :name = "uppercase",
                :alternatives = ["toupper", "caps"],
                :ring_method = "Uppercase",
                :type = "simple_transformation",
                :patterns = [
                    [
                        :template = "{method} it",
                        :params = [],
                        :ring_signature = "@var.Uppercase()"
                    ]
                ],
                :semantic_triggers = ["uppercase", "toupper", "caps"]
            ],

            [
                :name = "capitalize",
                :alternatives = ["capitalise"],
                :ring_method = "Capitalize",
                :type = "simple_transformation",
                :patterns = [
                    [
                        :template = "{method} it",
                        :params = [],
                        :ring_signature = "@var.Capitalize()"
                    ]
                ],
                :semantic_triggers = ["capitalize", "capitalise"]
            ],

            [
                :name = "lowercase", 
                :alternatives = ["tolower", "downcase"],
                :ring_method = "Lowercase",
                :type = "simple_transformation", 
                :patterns = [
                    [
                        :template = "{method} it",
                        :params = [],
                        :ring_signature = "@var.Lowercase()"
                    ]
                ],
                :semantic_triggers = ["lowercase", "tolower", "downcase"]
            ],

            [
                :name = "spacify",
                :alternatives = ["addspaces", "space"],
                :ring_method = "Spacify",
                :type = "simple_transformation",
                :patterns = [
                    [
                        :template = "{method} it", 
                        :params = [],
                        :ring_signature = "@var.Spacify()"
                    ]
                ],
                :semantic_triggers = ["spacify", "addspaces", "space"]
            ],

            [
                :name = "trim",
                :alternatives = [],
                :ring_method = "Trim",
                :type = "simple_transformation",
                :patterns = [
                    [
                        :template = "{method} it", 
                        :params = [],
                        :ring_signature = "@var.Trim()"
                    ]
                ],
                :semantic_triggers = ["trim"]
            ],

            [
                :name = "reverse",
                :alternatives = ["flip", "backwards"],
                :ring_method = "Reverse", 
                :type = "simple_transformation",
                :patterns = [
                    [
                        :template = "{method} it",
                        :params = [],
                        :ring_signature = "@var.Reverse()"
                    ]
                ],
                :semantic_triggers = ["reverse", "flip", "backwards"]
            ],

            [
                :name = "box",
                :alternatives = ["frame", "border"], 
                :ring_method = "Box",
                :type = "special_formatting",
                :patterns = [
                    [
                        :template = "{method} it",
                        :params = [],
                        :ring_signature = "@var.Box()",
                        :modifiers = [
                            [:name = "rounded", :trigger = "rounded", :ring_param = ":Rounded = 1", :method = "BoxXT"]
                        ]
                    ]
                ],
                :semantic_triggers = ["box", "frame", "border"],
                :supports_define_recall = 1
            ],

            [
                :name = "show",
                :alternatives = ["display", "print", "output"],
                :ring_method = "Content", 
                :type = "output",
                :patterns = [
                    [
                        :template = "{method} it",
                        :params = [],
                        :ring_signature = "? @var.Content()"
                    ]
                ],
                :semantic_triggers = ["show", "display", "print", "output"]
            ],

            [
                :name = "prepend",
                :alternatives = ["prefix", "addfront"],
                :ring_method = "Prepend",
                :type = "insertion",
                :patterns = [
                    [
                        :template = "{method} {value}",
                        :params = [
                            [:name = "value", :type = "string", :position = 1]
                        ],
                        :ring_signature = "@var.Prepend(@value)"
                    ]
                ],
                :semantic_triggers = ["prepend", "prefix", "addfront"]
            ],

            [
                :name = "append", 
                :alternatives = ["suffix", "addend"],
                :ring_method = "Append",
                :type = "insertion",
                :patterns = [
                    [
                        :template = "{method} {value}",
                        :params = [
                            [:name = "value", :type = "string", :position = 1]
                        ],
                        :ring_signature = "@var.Append(@value)"
                    ]
                ],
                :semantic_triggers = ["append", "suffix", "addend"]
            ],

        ]
    ]
    # More Softanza objects would be added here following the same pattern
]

# Position conversion mapping - also data-driven
$aPositionMappings = [
    [:natural = "first", :numeric = "1"],
    [:natural = "second", :numeric = "2"], 
    [:natural = "third", :numeric = "3"],
    [:natural = "fourth", :numeric = "4"],
    [:natural = "fifth", :numeric = "5"],
    [:natural = "sixth", :numeric = "6"],
    [:natural = "seventh", :numeric = "7"],
    [:natural = "eighth", :numeric = "8"],
    [:natural = "ninth", :numeric = "9"],
    [:natural = "tenth", :numeric = "10"],
    [:natural = "last", :numeric = "-1"]
]

# Global interface functions
func StzNaturalQ()
    return new stzNaturalEngine

func Naturally()
    return new stzNaturalEngine

class stzNaturalEngine
    
    @aValues = []
    @aSemanticActions = []
    @cCurrentObject = ""
    @cCurrentVariable = ""
    @aDefineRecallState = []  # Track @method@ patterns
    nothing = ""

    def init()
        CreateIgnoreWordAttributes()
    
    def CreateIgnoreWordAttributes()
        # Dynamically create attributes for ignore words - completely data-driven
        for cWord in $aWordsToIgnore
            addAttribute(this, cWord)
            eval("this." + cWord + ' = ""')
            
            # Create getter method dynamically
            cMethodName = "get" + cWord
            cMethodCode = 'def ' + cMethodName + NL +
                         'addAttribute(this, "' + cWord + '")' + NL +
                         cWord + ' = ""'
            try
                eval(cMethodCode)
            catch
                # Ignore errors for duplicate methods
            done
        next

    def braceExprEval(value)
        if NOT( isString(value) and (value = "" or value = "__@Ignore__") )
            @aValues + value
        ok

    def braceError()
        if left(CatchError(), 11) = "Error (R24)"
            cUndefined = trim(split(CatchError(), ":")[3])
            @aValues + cUndefined
        ok

    def braceEnd()
        ProcessNaturalCode()
 
    def ProcessNaturalCode()
        aFilteredValues = FilterValues()
        if len(aFilteredValues) > 0
            @aSemanticActions = AnalyzeAndGenerateActions(aFilteredValues)
        else
            @aSemanticActions = []
        ok
        
        # Execute the generated code
        Run()
    
def FilterValues()
    aResult = []
    for i = 1 to len(@aValues)
        cValue = @aValues[i]
        
        if isString(cValue)
            cLowerValue = lower(cValue)
        else
            cLowerValue = lower("" + cValue)
        ok
        
        # Check if this is a parameter following "with"
        bIsParameterAfterWith = false
        if i > 1 and isString(@aValues[i-1]) and lower(@aValues[i-1]) = "with"
            bIsParameterAfterWith = true
        ok
        
        # Skip ignore words unless they're parameters after "with"
        bIgnore = false
        if not bIsParameterAfterWith
            for cIgnoreWord in $aWordsToIgnore
                if cLowerValue = cIgnoreWord
                    bIgnore = true
                    exit
                ok
            next
        ok
        
        if not bIgnore and cValue != "" and cValue != nothing
            aResult + cValue
        ok
    next
    return aResult

def ResolveMethodAlias(cMethodName)
    for aObj in $aSoftanzaObjects
        if aObj[:name] = @cCurrentObject
            for aMethod in aObj[:methods]
                # Check main name
                if aMethod[:name] = cMethodName
                    return aMethod[:name]
                ok
                # Check alternatives
                for cAlias in aMethod[:alternatives]
                    if cAlias = cMethodName
                        return aMethod[:name]
                    ok
                next
            next
            exit
        ok
    next
    return cMethodName
    
    def AnalyzeAndGenerateActions(aValues)
        aActions = []
        nLen = len(aValues)
        i = 1
        
        while i <= nLen
            cCurrent = lower("" + aValues[i])
            
            # Detect object creation - data-driven
            aCreationResult = HandleObjectCreation(aValues, i)
            if len(aCreationResult) > 0
                aActions + aCreationResult[:action]
                i = aCreationResult[:next_index]
            else
                # Detect method calls - completely data-driven
                aMethodResult = HandleMethodCall(aValues, i)
                if len(aMethodResult) > 0
                    if len(aMethodResult[:action]) > 0
                        aActions + aMethodResult[:action]
                    ok
                    i = aMethodResult[:next_index]
                else
                    i++
                ok
            ok
        end
        
        return aActions
    
def HandleObjectCreation(aValues, nStartIndex)
    nLen = len(aValues)
    
    # Search through all registered objects - data-driven
    for aObjInfo in $aSoftanzaObjects
        for aPattern in aObjInfo[:creation_patterns]
            for cTrigger in aPattern[:trigger_words]
                if lower("" + aValues[nStartIndex]) = cTrigger
                    
                    # Look for object type
                    for j = nStartIndex+1 to nLen
                        cValue = lower("" + aValues[j])
                        if cValue = aObjInfo[:name]
                            @cCurrentObject = aObjInfo[:name]
                            @cCurrentVariable = aObjInfo[:variable]
                            
                            # Extract value - look for next non-ignored word after object type
                            cObjectValue = ""
                            nValueIndex = j
                            
                            # Look for "with" keyword followed by the actual value
                            bFoundWith = false
                            for k = j+1 to nLen
                                cNextValue = lower("" + aValues[k])
                                if cNextValue = "with"
                                    bFoundWith = true
                                    # Get the value after "with"
                                    for m = k+1 to nLen
                                        cCheckValue = lower("" + aValues[m])
                                        if not ring_find($aWordsToIgnore, cCheckValue)
                                            # Check if this is a method name - if so, use empty string
                                            bIsMethod = false
                                            for aMethod in aObjInfo[:methods]
                                                for cTrigger in aMethod[:semantic_triggers]
                                                    if cCheckValue = cTrigger
                                                        bIsMethod = true
                                                        exit 2
                                                    ok
                                                next
                                                if bIsMethod
                                                    exit
                                                ok
                                            next
                                            
                                            if not bIsMethod
                                                cObjectValue = aValues[m]
                                                nValueIndex = m
                                            ok
                                            exit
                                        ok
                                    next
                                    exit
                                ok
                            next
                            
                            # If no "with" found or no value after "with", check if next non-ignored word is a method
                            if not bFoundWith or cObjectValue = ""
                                for k = j+1 to nLen
                                    cNextValue = lower("" + aValues[k])
                                    if not ring_find($aWordsToIgnore, cNextValue)
                                        # Check if this is a method name
                                        bIsMethod = false
                                        for aMethod in aObjInfo[:methods]
                                            for cTrigger in aMethod[:semantic_triggers]
                                                if cNextValue = cTrigger
                                                    bIsMethod = true
                                                    exit 2
                                                ok
                                            next
                                            if bIsMethod
                                                exit
                                            ok
                                        next
                                        
                                        if not bIsMethod
                                            cObjectValue = aValues[k]
                                            nValueIndex = k
                                        else
                                            # It's a method, so use empty string for object value
                                            cObjectValue = ""
                                            nValueIndex = k - 1
                                        ok
                                        exit
                                    ok
                                next
                            ok
                            
                            aAction = [
                                :type = "create_object",
                                :object_type = @cCurrentObject,
                                :variable = @cCurrentVariable,
                                :value = cObjectValue,
                                :constructor = aObjInfo[:constructor]
                            ]
                            
                            # Return next index after the value (or at the method if value was empty)
                            return [:action = aAction, :next_index = nValueIndex + 1]
                        ok
                    next
                ok
            next
        next
    next
    
    return []
    
def HandleMethodCall(aValues, nIndex)
    if @cCurrentObject = ""
        if @bDebugMode
            @aErrors + ("No current object for method call at index " + nIndex)
        ok
        return []
    ok
    
    cMethodName = lower("" + aValues[nIndex])
    
    # Resolve aliases first
    cResolvedMethod = ResolveMethodAlias(cMethodName)
    
    # Handle define/recall patterns (@method@)
    bDefine = left(cMethodName,1) = "@"
    bRecall = right(cMethodName,1) = "@"
    cCleanMethod = cMethodName
    if bDefine
        cCleanMethod = substr(cCleanMethod, 2)
    elseif bRecall
        cCleanMethod = left(cCleanMethod, len(cCleanMethod)-1)
    ok
    
    # Find method in current object - completely data-driven
    aObjectInfo = ObjectInfo(@cCurrentObject)
    aMethodInfo = FindMethodBySemanticTrigger(aObjectInfo, cCleanMethod)
    
    if len(aMethodInfo) = 0
        if @bDebugMode
            @aErrors + ("Method '" + cCleanMethod + "' not found for object '" + @cCurrentObject + "'")
        ok
        return [:action = [], :next_index = nIndex + 1]  # Skip this token and continue
    ok
    
    # Handle define/recall for methods that support it
    bSupportsDefineRecall = FALSE
    if len(aMethodInfo) > 0
        for key in keys(aMethodInfo)
            if key = "supports_define_recall" and aMethodInfo[:supports_define_recall] = TRUE
                bSupportsDefineRecall = TRUE
                exit
            ok
        next
    ok
    
    if bSupportsDefineRecall
        if bDefine
            @aDefineRecallState + [
                :method = aMethodInfo,
                :pending = TRUE,
                :define_index = nIndex
            ]
            return [:action = [], :next_index = nIndex + 1]
        elseif bRecall
            return ProcessRecallMethod(aValues, nIndex, aMethodInfo)
        ok
    ok

    # Process method based on its patterns - data-driven
    aResult = ProcessMethodByPattern(aValues, nIndex, aMethodInfo)
    return aResult


def ConvertValueByContext(cValue, cExpectedType)
    if cExpectedType = "string"
        return cValue
    elseif cExpectedType = "number"
        if IsNumberInString(cValue)
            return number(cValue)
        else
            return 0
        ok
    elseif cExpectedType = "position"
        return ConvertPositionToNumber(cValue)
    ok
    return cValue

def EnableDebug()
    @bDebugMode = TRUE
    
def Errors()
    return @aErrors
    
def ClearErrors()
    @aErrors = []


    
    def ProcessMethodByPattern(aValues, nIndex, aMethodInfo)
        # Try each pattern until one matches
        for aPattern in aMethodInfo[:patterns]
            aResult = TryMatchPattern(aValues, nIndex, aMethodInfo, aPattern)
            if len(aResult) > 0
                return aResult
            ok
        next
        
        # If no pattern matched, create a simple action for methods with no parameters
        aAction = [
            :type = "method_call",
            :method_info = aMethodInfo,
            :pattern = aMethodInfo[:patterns][1], # Use first pattern
            :params = [],
            :modifiers = []
        ]
        
        return [:action = aAction, :next_index = nIndex + 1]


def TryMatchPattern(aValues, nIndex, aMethodInfo, aPattern)
    nLen = len(aValues)
    aExtractedParams = []
    i = nIndex + 1
    nLastConsumedIndex = nIndex  # Track the last index we actually used

    # Extract parameters based on pattern definition
    for aParamDef in aPattern[:params]
        cParamValue = ExtractParameterValue(aValues, i, nLen, aParamDef)
        if cParamValue != ""
            aExtractedParams + cParamValue
            # Find where this parameter was actually found
            for j = i to nLen
                cValue = lower("" + aValues[j])
                if not ring_find($aWordsToIgnore, cValue)
                    nLastConsumedIndex = j
                    i = j + 1
                    exit
                ok
            next
        else
            exit
        ok
    next

    # Extract modifiers if any
    aModifiers = []
    if len(aPattern[:modifiers]) > 0
        aModifiers = ExtractModifiers(aValues, nLastConsumedIndex + 1, nLen, aPattern[:modifiers])
        # Update nLastConsumedIndex if modifiers were found
        for aMod in aModifiers
            for j = nLastConsumedIndex + 1 to nLen
                if lower("" + aValues[j]) = aMod[:trigger]
                    nLastConsumedIndex = j
                    exit
                ok
            next
        next
    ok

    aAction = [
        :type = "method_call",
        :method_info = aMethodInfo,
        :pattern = aPattern,
        :params = aExtractedParams,
        :modifiers = aModifiers
    ]
    
    return [:action = aAction, :next_index = nLastConsumedIndex + 1]
	    
	    # Extract modifiers if any
	    aModifiers = []
	    if len(aPattern[:modifiers]) > 0
	        aModifiers = ExtractModifiers(aValues, i, nLen, aPattern[:modifiers])
	    ok
	    
	    aAction = [
	        :type = "method_call",
	        :method_info = aMethodInfo,
	        :pattern = aPattern,
	        :params = aExtractedParams,
	        :modifiers = aModifiers
	    ]
	    
	    return [:action = aAction, :next_index = nIndex + 1]  # Change this line
	    

def ExtractParameterValue(aValues, nStartIndex, nLen, aParamDef)
    i = nStartIndex
    while i <= nLen
        cActualValue = aValues[i]
        cValue = lower("" + cActualValue)
        
        # For string parameters, check if this looks like a quoted value or actual content
        if aParamDef[:type] = "string"
            # If it's quoted, use it regardless of ignore list
            if (left(cActualValue, 1) = '"' and right(cActualValue, 1) = '"') or
               (left(cActualValue, 1) = "'" and right(cActualValue, 1) = "'")
                return cActualValue
            ok
            
            # For unquoted strings, check if it's in context of "with" keyword
            if i > 1 and lower("" + aValues[i-1]) = "with"
                return cActualValue  # Use it even if it's normally ignored
            ok
        ok
        
        # For other types or normal processing
        if not ring_find($aWordsToIgnore, cValue)
            if aParamDef[:type] = "position"
                return ConvertPositionToNumber(cActualValue)
            elseif aParamDef[:type] = "number"
                if IsNumberInString(cActualValue)
                    return cActualValue
                else
                    if @bDebugMode
                        @aErrors + "Expected number but got: " + cActualValue
                    ok
                    return "0"
                ok
            else
                return cActualValue
            ok
        ok
        i++
    end
    return ""


def DetectMethodChaining(aValues)
    # Simple heuristic: if we have more semantic triggers after processing one method
    aSemanticWords = []
    for aObj in $aSoftanzaObjects
        for aMethod in aObj[:methods]
            for cTrigger in aMethod[:semantic_triggers]
                if not ring_find(aSemanticWords, cTrigger)
                    aSemanticWords + cTrigger
                ok
            next
        next
    next
    
    nSemanticCount = 0
    for cValue in aValues
        cLower = lower("" + cValue)
        if ring_find(aSemanticWords, cLower)
            nSemanticCount++
        ok
    next
    
    return nSemanticCount > 1


def ExtractModifiers(aValues, nStartIndex, nLen, aModifierDefs)
    aResult = []
    nCurrentIndex = nStartIndex
    
    # Look ahead for modifiers
    while nCurrentIndex <= nLen
        cValue = lower("" + aValues[nCurrentIndex])
        
        # Skip ignored words
        if ring_find($aWordsToIgnore, cValue)
            nCurrentIndex++
            loop
        ok
        
        # Check if current word matches any modifier trigger
        bFoundModifier = 0
        for aModDef in aModifierDefs
            if cValue = aModDef[:trigger]
                aResult + aModDef
                bFoundModifier = 1
                exit
            ok
        next
        
        # If we found a modifier, continue looking for more
        # If not, we've consumed all relevant tokens for this method
        if bFoundModifier
            nCurrentIndex++
        else
            exit
        ok
    end
    
    return aResult


def ProcessRecallMethod(aValues, nIndex, aMethodInfo)
    for i = 1 to len(@aDefineRecallState)
        if @aDefineRecallState[i][:method][:name] = aMethodInfo[:name] and @aDefineRecallState[i][:pending]
            @aDefineRecallState[i][:pending] = 0
            # Process the recall with modifiers
            aResult = ProcessMethodByPattern(aValues, nIndex, aMethodInfo)
            # Clear the define/recall state after successful recall
            @aDefineRecallState = []
            return aResult
        ok
    next
    return []


    def ProcessDefineRecallState()
	    # Clear state without creating duplicate actions
	    @aDefineRecallState = []
	    return []
	    
	    def FindMethodBySemanticTrigger(aObjectInfo, cMethodName)
	        for aMethod in aObjectInfo[:methods]
	            for cTrigger in aMethod[:semantic_triggers]
	                if cTrigger = cMethodName
	                    return aMethod
	                ok
	            next
	        next
	        return []


    def ObjectInfo(cObjectName)
        for aObj in $aSoftanzaObjects
            if aObj[:name] = cObjectName
                return aObj
            ok
        next
        return []


    def ConvertPositionToNumber(cPosition)
        cPos = lower("" + cPosition)
        
        # Use data-driven position mapping
        for aMapping in $aPositionMappings
            if aMapping[:natural] = cPos
                return aMapping[:numeric]
            ok
        next
        
        # If it's already a number
        if IsNumberInString(cPos)
            return cPos
        ok
        
        return "1"  # Default fallback


    def GenerateCode()
	    if len(@aSemanticActions) = 0
	        return ""
	    ok
	    
	    aCodeLines = []
	    
	    for aAction in @aSemanticActions
	        cCodeLine = This.GenerateCodeLine(aAction)
	        if cCodeLine != ""
	            aCodeLines + cCodeLine
	        ok
	    next
	    
	    return JoinXT(aCodeLines, NL)


    def GenerateCodeLine(aAction)
	    # Check if aAction is valid
	    if NOT isList(aAction) or len(aAction) = 0
	        return ""
	    ok
	    
	    # Safely get the type
	    cActionType = ""
	    if len(aAction[:type]) > 0 and isString(aAction[:type])
	        cActionType = aAction[:type]
	    else
	        return ""
	    ok
	    
	    if cActionType = "create_object"
	        cValue = '""'
	        if len(aAction[:value]) > 0 and aAction[:value] != "" and aAction[:value] != nothing
	            if lower("" + aAction[:value]) != "nothing"
	                cValue = @@(aAction[:value])
	            ok
	        ok
	        
	        # Use constructor template from metadata
	        cConstructor = aAction[:constructor]
	        cConstructor = substr(cConstructor, "@", cValue)
	        return aAction[:variable] + " = " + cConstructor
	        
	    elseif cActionType = "method_call"
	        
	        # Safely extract method info
	        if NOT len(aAction[:method_info]) > 0
	            return ""
	        ok
	        
	        aMethodInfo = aAction[:method_info]
	        aPattern = aAction[:pattern]
	        aParams = aAction[:params]
	        aModifiers = aAction[:modifiers]
	        
	        # Generate Ring method call from signature template
	        cSignature = aPattern[:ring_signature]
	        cSignature = substr(cSignature, "@var", @cCurrentVariable)
	        
	        # Replace parameter placeholders
	        for i = 1 to len(aParams)
	            if i <= len(aPattern[:params])
	                cParamPlaceholder = "@" + aPattern[:params][i][:name]
	                cParamValue = @@(aParams[i])
	                cSignature = substr(cSignature, cParamPlaceholder, cParamValue)
	            ok
	        next
	        
	        # Handle modifiers if any
		if len(aModifiers) > 0
		    for aMod in aModifiers
		        if len(aMod[:method]) > 0 and aMod[:method] != ""
		            cSignature = substr(cSignature, aMethodInfo[:ring_method], aMod[:method])
		            if len(aMod[:ring_param]) > 0
		                cSignature = substr(cSignature, "()", "([" + aMod[:ring_param] + "])")
		            ok
		        ok
		    next
		ok
	        
	        return cSignature
	    ok
	    
	    return ""


    def SortActionsByType(aActions)
	    aCreation = []
	    aMethods = []
	    aOutput = []
	    
	    for aAction in aActions
	        if NOT isList(aAction) or len(aAction) = 0
	            loop
	        ok
	        
	        cActionType = aAction[:type]
	        
	        if cActionType = "create_object"
	            aCreation + aAction
	        elseif cActionType = "method_call"
	            aMethods + aAction
	        elseif cActionType = "output"
	            aOutput + aAction
	        ok
	    next
	    
	    return aCreation + aMethods + aOutput
	
 
    def SortPositionalReplacements(aMethods)
        aPositional = []
        aOther = []
        
        for aAction in aMethods
            if len(aAction[:method_info]) > 0 and aAction[:method_info][:type] = "positional_replacement"
                aPositional + aAction
            else
                aOther + aAction
            ok
        next
        
        # Sort positional by position number (descending)
        if len(aPositional) > 0
            aTemp = []
            for aAction in aPositional
                nPos = number(aAction[:params][1])
                if nPos < 0  # Handle "last" (-1)
                    nPos = 1000000 + nPos
                ok
                aTemp + [nPos, aAction]
            next
            aTemp = sort(aTemp, 1)
            aTemp = reverse(aTemp)  # Highest position first
            
            aPositional = []
            for item in aTemp
                aPositional + item[2]
            next
        ok
        
        return aPositional + aOther
    
    def FindNextNonIgnoreWord(aValues, nStartIndex, nLen)
        for i = nStartIndex to nLen
            cValue = lower("" + aValues[i])
            if not ring_find($aWordsToIgnore, cValue)
                return i
            ok
        next
        return nLen + 1
    
    def ExtractValueForPattern(aValues, nStartIndex, nLen, cPosition)
        if cPosition = "after"
            for i = nStartIndex to nLen
                cValue = lower("" + aValues[i])
                if not ring_find($aWordsToIgnore, cValue)
                    return aValues[i]
                ok
            next
        ok
        return ""
    
    # Public interface methods
    def Code()
        return GenerateCode()
    
    def Run()
        cCode = GenerateCode()
        if cCode != ""
            eval(cCode)
        ok
    
    def Values()
        aResult = []
        for cValue in @aValues
            cLowerValue = lower("" + cValue)
            if not ring_find($aWordsToIgnore, cLowerValue)
                aResult + cValue
            ok
        next
        return aResult
    
    def SemanticActions()
        return @aSemanticActions
