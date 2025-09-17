func StzNaturalQ()
    return new stzNatural

func Naturally()
    return new stzNatural

class stzNatural
    
    nothing = "_NULL_"

    # Position indicators
    first = "1"
    second = "2" 
    third = "3"
    fourth = "4"
    fifth = "5"
    sixth = "6"
    seventh = "7"
    eighth = "8"
    ninth = "9"
    tenth = "10"
    last = "-1"

    # Reference words  
    the = "→"
    this_ = "→"
    that = "→"
    these = "→" 
    those = "→"
    it = "→"
    
    # Enhanced connectors
    and_ = "→"
    then = "→"
    also = "→"
    plus = "→"
    with = "→"
    using = "→"
    to_ = "→"
    by = "→"
    containing = "→"

    @aValues = []
    @aUndefined = []
    @aSemanticActions = []  # Store semantic actions for preprocessing

def getIs
	addattribute(this, "is")
	is = "_NULL_"

def getDecorated
	addAttribute(this, "decorated")
	decorated = "_NULL_"

def getWith_
	addAttribute(this, "with_")
	with_ = "_NULL_"

    def braceExprEval(value)
        if NOT( isString(value) and (value = _NULL_ or value = "__@Ignore__") )
            @aValues + value
        ok

    def braceError()
        if left(CatchError(), 11) = "Error (R24)"
            cUndefined = trim(@split(CatchError(), ":")[3])
            @aValues + cUndefined
        ok

    def Values()
        aResult = []
        nLen = len(@aValues)
        for i = 1 to nLen

            if i > 3
                if @aValues[i-1] = "→" and
                   @aValues[i] = @aValues[i-2]
                    loop
                ok
            ok

            if @aValues[i] != "→"
                aResult + @aValues[i]
            ok
        next

        return aResult

    def Undefined()
        return @aUndefined

    def braceEnd()
        Run()

    # New method to analyze semantic patterns
    def AnalyzeSemanticPatterns(aValues)
        @aSemanticActions = []
        aOriginalActions = []
        
        # Extract all replace operations with their original positions
        i = 1
        cStringValue = ""
        
        # Find the initial string value
        nLen = len(aValues)
        for j = 1 to nLen
            if ring_find(["create", "make"], lower(aValues[j])) > 0 and 
               j+1 <= nLen and lower(aValues[j+1]) = "a" and
               j+2 <= nLen and lower(aValues[j+2]) = "stzstring"
                
                # Flexible value extraction
                k = j+3
                cStringValue = nothing
                
                if k <= nLen and isString(aValues[k]) and lower(aValues[k]) = "object"
                    k++
                ok
                
                if k <= nLen and isString(aValues[k]) and ring_find(["with", "containing"], lower(aValues[k])) > 0
                    k++
                    if k <= nLen
                        cStringValue = aValues[k]
                        if lower(cStringValue) = "nothing" and k+1 <= nLen and lower(aValues[k+1]) = "inside"
                            # Skip "inside", keep "nothing"
                            # Value remains "nothing"
                        ok
                    ok
                else
                    if k <= nLen
                        cStringValue = aValues[k]
                    ok
                ok
                
                exit
            ok
        next
        
        # Collect all replace operations
        i = 1
        while i <= nLen
            cOperation = lower(aValues[i])
            
            if ring_find(["replace", "substitute", "change"], cOperation) > 0
                i++
                if i <= nLen
                    cNext = aValues[i]
                    if NOT isString(cNext)
                        cNext = "" + cNext
                    ok
                    
                    if isString(cNext) and (IsNumberInString(cNext) or cNext = "-1" or ring_find(This.PositionIndicators(), lower(cNext)) > 0)
                        # Positional replace: "replace the second 'hello' with 'Hi'"
                        cPosition = cNext
                        i++
                        if i <= nLen
                            cOld = aValues[i]
                            i++
                            if i <= nLen
                                cNew = aValues[i]
                                
                                # Store semantic action
                                aAction = [:type = "positional_replace", 
                                          :original_position = cPosition,
                                          :old_value = cOld, 
                                          :new_value = cNew,
                                          :original_string = cStringValue]
                                aOriginalActions + aAction
                            ok
                        ok
                    else
                        # Global replace: "replace 'hello' with 'Hi'"
                        cOld = cNext
                        i++
                        if i <= nLen
                            cNew = aValues[i]
                            aAction = [:type = "global_replace", 
                                      :old_value = cOld, 
                                      :new_value = cNew,
                                      :original_string = cStringValue]
                            aOriginalActions + aAction
                        ok
                    ok
                ok
            ok
            i++
        end
        
        # Now compute the correct execution sequence
        @aSemanticActions = ComputeExecutionSequence(aOriginalActions, cStringValue)
        
        return [ @aSemanticActions, cStringValue ]

    def PositionIndicators()
        return ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth", "last"]

    # Compute correct execution sequence based on semantic intent
    def ComputeExecutionSequence(aOriginalActions, cOriginalString)
        aExecutionActions = []
        cCurrentString = cOriginalString
        
        # Group positional replaces by target string
        aPositionalGroups = []
        for action in aOriginalActions
            if action[:type] = "positional_replace"
                cTarget = action[:old_value]
                nFound = 0
                for group in aPositionalGroups
                    if group[:target] = cTarget
                        group[:actions] + action
                        nFound = 1
                        exit
                    ok
                next
                if nFound = 0
                    aNewGroup = [:target = cTarget, :actions = [action]]
                    aPositionalGroups + aNewGroup
                ok
            else
                aExecutionActions + action
            ok
        next
        
        # For each group of positional replaces, compute correct positions
        for group in aPositionalGroups
            cTarget = group[:target]
            aActions = group[:actions]
            
            # Count occurrences of target in original string
            oStr = new stzString(cOriginalString)
            nOccurrences = oStr.NumberOfOccurrence(cTarget)
            
            # Create position mapping
            aPositionMap = []
            for action in aActions
                cPos = action[:original_position]
                nOriginalPos = 0
                
                if cPos = "1" or lower(cPos) = "first"
                    nOriginalPos = 1
                but cPos = "2" or lower(cPos) = "second"  
                    nOriginalPos = 2
                but cPos = "3" or lower(cPos) = "third"
                    nOriginalPos = 3
                but cPos = "4" or lower(cPos) = "fourth"
                    nOriginalPos = 4
                but cPos = "5" or lower(cPos) = "fifth"
                    nOriginalPos = 5
                but cPos = "-1" or lower(cPos) = "last"
                    nOriginalPos = nOccurrences
                but isNumber(0+cPos)
                    nOriginalPos = 0+cPos
                ok
                
                if nOriginalPos > nOccurrences or nOriginalPos < 1
                    # Ignore invalid positions
                    loop
                ok
                
                aPositionMap + [:original_pos = nOriginalPos, :action = action]
            next
            
            # Sort by original position (descending to handle from end)
            aPositionMap = SortByOriginalPosition(aPositionMap)
            
            # Add to execution actions in correct order
            for item in aPositionMap
                action = item[:action]
                nPos = item[:original_pos]
                
                # Create execution action with correct position
                aExecAction = [:type = "positional_replace",
                              :position = nPos,
                              :old_value = action[:old_value],
                              :new_value = action[:new_value]]
                aExecutionActions + aExecAction
            next
        next
        
        return aExecutionActions

    # Helper to sort position map by original position (descending)
    def SortByOriginalPosition(aPositionMap)
        nLen = len(aPositionMap)
        for i = 1 to nLen-1
            for j = i+1 to nLen
                if aPositionMap[i][:original_pos] < aPositionMap[j][:original_pos]
                    temp = aPositionMap[i]
                    aPositionMap[i] = aPositionMap[j] 
                    aPositionMap[j] = temp
                ok
            next
        next
        return aPositionMap

    def Code()
        aValues = This.Values()
        if len(aValues) = 0
            return ""
        ok
        
        # Analyze semantic patterns first
        aResult = AnalyzeSemanticPatterns(aValues)
        aSemanticActions = aResult[1]
        cStringValue = aResult[2]
        
        # Handle "Create a stzString with value" pattern
        if len(aValues) >= 3 and ring_find(["create", "make"], lower(aValues[1])) > 0 and 
           lower(aValues[2]) = "a" and
           lower(aValues[3]) = "stzstring"
            
            aTransformLines = []
            aOutputLines = []
            
            cValue = '""'
            if isString(cStringValue) and lower(cStringValue) != "nothing" and cStringValue != nothing
                cValue = @@(cStringValue)
            ok  # else empty string
            
            aTransformLines + ("oStr = StzStringQ(" + cValue + ")")
            
            # Apply semantic actions first (these are preprocessed)
            for action in aSemanticActions
                if action[:type] = "positional_replace"
                    cOld = @@(action[:old_value])
                    cNew = @@(action[:new_value])
                    cPos = ""+ action[:position]
                    aTransformLines + ("oStr.ReplaceNth(" + cPos + ", " + cOld + ", " + cNew + ")")
                but action[:type] = "global_replace"
                    cOld = @@(action[:old_value])
                    cNew = @@(action[:new_value])
                    aTransformLines + ("oStr.Replace(" + cOld + ", " + cNew + ")")
                ok
            next
            
            # Initialize flags for named operations
            bBoxPending = FALSE
            bRounded = FALSE
            
            # Process remaining non-replace operations starting from index 5
            i = 5
            while i <= len(aValues)
                cOperation = lower(aValues[i])
                
                # Skip replace operations (already handled by semantic preprocessing)
                if ring_find(["replace", "substitute", "change"], cOperation) > 0
                    # Skip this operation and its parameters
                    i++
                    if i <= len(aValues)
                        cNext = aValues[i]
                        if NOT isString(cNext)
                            cNext = "" + cNext
                        ok
                        if isString(cNext) and (IsNumberInString(cNext) or cNext = "-1" or ring_find(This.PositionIndicators(), lower(cNext)) > 0)
                            i += 3  # Skip position, old, new
                        else
                            i += 2  # Skip old, new
                        ok
                    ok
                    loop
                ok
                
                if left(cOperation, 1) = "@"  # Prefix for defining/naming, defer application
                    cName = substr(cOperation, 2, len(cOperation) - 1)
                    if ring_find(["box", "frame"], cName) > 0
                        bBoxPending = TRUE
                        i++
                        loop  # Defer, don't add code yet
                    ok
                    
                but right(cOperation, 1) = "@"  # Suffix for recalling and applying with mods
                    cName = left(cOperation, len(cOperation) - 1)
                    if ring_find(["box", "frame"], cName) > 0
                        bRounded = FALSE
                        j = i + 1
                        while j <= len(aValues)
                            cNext = lower(aValues[j])
                            if cNext = "is"
                                j++
                                loop
                            but cNext = "should" and j+1 <= len(aValues) and lower(aValues[j+1]) = "be"
                                j += 2
                                loop
                            but cNext = "must" and j+1 <= len(aValues) and lower(aValues[j+1]) = "be"
                                j += 2
                                loop
                            but cNext = "with"
                                j++
                                if j <= len(aValues) and lower(aValues[j]) = "rounded"
                                    if j+1 <= len(aValues) and lower(aValues[j+1]) = "corners"
                                        bRounded = TRUE
                                        j += 2
                                    else
                                        bRounded = TRUE
                                        j++
                                    ok
                                ok
                                loop
                            but cNext = "rounded"
                                if j+1 <= len(aValues) and lower(aValues[j+1]) = "corners"
                                    bRounded = TRUE
                                    j += 2
                                else
                                    bRounded = TRUE
                                    j++
                                ok
                            else
                                exit
                            ok
                        end
                        # Apply the box with options
                        if bRounded
                            aTransformLines + "oStr.BoxXT([ :Rounded = TRUE ])"
                        else
                            aTransformLines + "oStr.BoxXT()"
                        ok
                        bBoxPending = FALSE
                        i = j - 1
                        # No loop here to avoid infinite if no advance; let outer i++ handle
                    ok
                    
                but ring_find(["box", "frame"], cOperation) > 0  # Plain box, immediate apply without mods
                    aTransformLines + "oStr.Box()"
                    i++
                    loop
                    
                but ring_find(["show", "display", "print"], cOperation) > 0
                    aOutputLines + "? oStr.Content()"
                    
                but cOperation = "uppercase"
                    aTransformLines + "oStr.Uppercase()"
                    
                but cOperation = "lowercase"
                    aTransformLines + "oStr.Lowercase()"
                    
                but cOperation = "spacify"
                    aTransformLines + "oStr.Spacify()"
                    
                but cOperation = "reverse"
                    aTransformLines + "oStr.Reverse()"
                    
                but cOperation = "trim"
                    aTransformLines + "oStr.Trim()"
                    
                but ring_find(["append", "add"], cOperation) > 0
                    i++
                    if i <= len(aValues)
                        if isString(aValues[i]) and lower(aValues[i]) = "substring"
                            i++
                        ok
                        if i <= len(aValues)
                            cParam = @@(aValues[i])
                            aTransformLines + ("oStr.Append(" + cParam + ")")
                        ok
                    ok
                    
                but cOperation = "prepend"
                    i++
                    if i <= len(aValues)
                        cParam = @@(aValues[i])
                        aTransformLines + ("oStr.Prepend(" + cParam + ")")
                    ok
                    
                but cOperation = "insert"
                    i++
                    if i <= len(aValues)
                        cValue = @@(aValues[i])
                        i++
                        if i <= len(aValues) and lower(aValues[i]) = "at"
                            i++
                            if i <= len(aValues)
                                if isString(aValues[i]) and lower(aValues[i]) = "position"
                                    i++
                                ok
                                if i <= len(aValues)
                                    cPosition = aValues[i]
                                    if isNumber(cPosition)
                                        cPosition = "" + cPosition
                                    else
                                        cPosition = @@(cPosition)
                                    ok
                                    aTransformLines + ("oStr.InsertAt(" + cPosition + ", " + cValue + ")")
                                ok
                            ok
                        ok
                    ok
                    
                ok
                
                i++
            end
            
            # At the end, apply any pending named operations with default
            if bBoxPending
                aTransformLines + "oStr.Box()"
            ok
            
            cCode = JoinXT(aTransformLines, NL) + NL + JoinXT(aOutputLines, NL)
            return cCode
        else
            # Fallback to original logic for other patterns
            aValues[1] += "{"
            cCode = ""
            nLenValues = len(aValues)

            for i = 1 to nLenValues
                
                oValue = new stzString(aValues[i])

                if NOT oValue.Contains("@")
                    # Adding the line to the code
                    cCode += oValue.Content()
                else
                    # Composing the params
                    nLen@ = oValue.NumberOfOccurrence("@")
                    c@ = ""

                    cParams = ""
                    for j = 1 to nLen@

                        if aValues[i+j] = "_NULL_"
                            cParam = "_NULL_"
                        else
                            cParam = @@(aValues[i+j])
                        ok

                        cParams += cParam + ","
                        c@ += "@"
                    next
                    cParams = StzStringQ(cParams).LastCharRemoved()
                
                    # Replacing the params inside the line
                    oValue.Replace(c@, cParams)

                    # Adding the line to the code
                    cCode += oValue.Content()
                    i += j-1
                ok
            next

            cCode += "}"
            return cCode
        ok

    def Run()
        eval(This.Code())

    # Debug method to show semantic actions
    def SemanticActions()
        return @aSemanticActions
