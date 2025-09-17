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
    the = "↑"
    this_ = "↑"
    that = "↑"
    these = "↑" 
    those = "↑"
    it = "↑"
    
    # Enhanced connectors
    and_ = "↑"
    then = "↑"
    also = "↑"
    plus = "↑"
    with = "↑"
    using = "↑"
    to_ = "↑"
    by = "↑"
    containing = "↑"

    @aValues = []
    @aUndefined = []

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
                if @aValues[i-1] = "↑" and
                   @aValues[i] = @aValues[i-2]
                    loop
                ok
            ok

            if @aValues[i] != "↑"
                aResult + @aValues[i]
            ok
        next

        return aResult

    def Undefined()
        return @aUndefined

    def braceEnd()
        Run()

    def Code()
        aValues = This.Values()
        if len(aValues) = 0
            return ""
        ok
        
        # Handle "Create a stzString with value" pattern
        if len(aValues) >= 3 and ring_find(["create", "make"], lower(aValues[1])) > 0 and 
           lower(aValues[2]) = "a" and
           lower(aValues[3]) = "stzstring"
            
            cCode = "oStr = StzStringQ("
            if len(aValues) >= 4
                cValue = aValues[4]
                if cValue = nothing
                    cValue = "_NULL_"
                else
                    cValue = @@(cValue)
                ok
                cCode += cValue + ")"
            else
                cCode += "_NULL_)"
            ok
            cCode += NL
            
            # Process remaining operations starting from index 5
            i = 5
            while i <= len(aValues)
                cOperation = lower(aValues[i])
                
                if ring_find(["show", "display", "print"], cOperation) > 0
                    cCode += "? oStr.Content()" + NL
                    
                but cOperation = "uppercase"
                    cCode += "oStr.Uppercase()" + NL
                    
                but cOperation = "lowercase"
                    cCode += "oStr.Lowercase()" + NL
                    
                but cOperation = "spacify"
                    cCode += "oStr.Spacify()" + NL
                    
                but cOperation = "reverse"
                    cCode += "oStr.Reverse()" + NL
                    
                but cOperation = "trim"
                    cCode += "oStr.Trim()" + NL
                    
                but ring_find(["append", "add"], cOperation) > 0
                    i++
                    if i <= len(aValues)
                        cParam = @@(aValues[i])
                        cCode += "oStr.Append(" + cParam + ")" + NL
                    ok
                    
                but cOperation = "prepend"
                    i++
                    if i <= len(aValues)
                        cParam = @@(aValues[i])
                        cCode += "oStr.Prepend(" + cParam + ")" + NL
                    ok
                    
                but cOperation = "insert"
                    i++
                    if i <= len(aValues)
                        cValue = @@(aValues[i])
                        i++
                        if i <= len(aValues) and lower(aValues[i]) = "at"
                            i++
                            if i <= len(aValues)
                                cPosition = @@(aValues[i])
                                cCode += "oStr.InsertAt(" + cPosition + ", " + cValue + ")" + NL
                            ok
                        ok
                    ok
                    
                but ring_find(["replace", "substitute", "change"], cOperation) > 0
                    i++
                    if i <= len(aValues)
                        cNext = aValues[i]
                        if isString(cNext) and (IsNumberInString(cNext) or cNext = "-1")
                            cPosition = cNext
                            i++
                            cOld = @@(aValues[i])
                            i++
                            cNew = @@(aValues[i])
                            cCode += "oStr.ReplaceNth(" + cPosition + ", " + cOld + ", " + cNew + ")" + NL
                        else
                            cOld = @@(cNext)
                            i++
                            cNew = @@(aValues[i])
                            cCode += "oStr.Replace(" + cOld + ", " + cNew + ")" + NL
                        ok
                    ok
                    
                but ring_find(["box", "frame"], cOperation) > 0
                    cCode += "oStr.Box()" + NL
                    
                but ring_find(["box@", "frame@"], cOperation) > 0
                    bRounded = FALSE
		    nLen = len(aValues)

                    for j = i+1 to nLen
                        if lower(aValues[j]) = "rounded"
                            bRounded = TRUE
                        ok
                    next
                    if bRounded
                        cCode += "oStr.BoxXT([ :Rounded = TRUE ])" + NL
                    else
                        cCode += "oStr.BoxXT()" + NL
                    ok
                ok
                
                i++
            end
            
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
