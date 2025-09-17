func StzNaturalQ()
    return new stzNatural

func Naturally()
    return new stzNatural

class stzNatural
    
    nothing = "_NULL_"

    # Basic mappings
    stzString = "StzStringQ(@)"
    append = "Append(@)"
    show = "Print()"
    
    # Transformations
    uppercase = "Uppercase()"
    lowercase = "Lowercase()"
    spacify = "Spacify()"
    reverse = "Reverse()"
    trim = "Trim()"
    
    # Display operations
    display = "Print()"
    print = "Print()"
    box = "Box()"
    frame = "Box()"
    
    # Text operations
    prepend = "Prepend(@)"
    insert = "InsertAt(@, @)"
    add = "Append(@)"
    
    # Replacement operations
    replace = "Replace(@, @)"
    substitute = "Replace(@, @)"
    change = "Replace(@, @)"
    
    # Box options
    box@ = "BoxXT(@)"
    frame@ = "BoxXT(@)"
    rounded = ["rounded", _TRUE_]
    
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

    @aValues = []
    @aUndefined = []

    def braceExprEval(value)
        if NOT( isString(value) and (value = _NULL_ or value = "__@Ignore__") )
            @aValues + value
        ok

    def braceError()
        if left(CatchError(), 11) = "Error (R24)"
            cUndefined = trim(split(CatchError(), ":")[3])
            @aUndefined + cUndefined
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
        if len(aValues) >= 4 and lower(aValues[1]) = "create" and 

           lower(aValues[2]) = "a" and
	   (lower(aValues[3]) = "stzstring") and 


           lower(aValues[4]) = "with"
            
            if len(aValues) >= 5
                cValue = aValues[5]
                if cValue = nothing
                    cValue = "_NULL_"
                else
                    cValue = @@(cValue)
                ok
                cCode = "oStr = StzStringQ(" + cValue + ")" + NL
            else
                cCode = "oStr = StzStringQ(_NULL_)" + NL
            ok
            
            # Process remaining operations starting from index 6
            i = 6
            while i <= len(aValues)
                cOperation = lower(aValues[i])
                
                if cOperation = "show" or cOperation = "display" or cOperation = "print"
                    cCode += "? oStr.Content()" + NL
                    
                but cOperation = "uppercase"
                    cCode += "oStr.Uppercase()" + NL
                    
                but cOperation = "lowercase"
                    cCode += "oStr.Lowercase()" + NL
                    
                but cOperation = "spacify"
                    cCode += "oStr.Spacify()" + NL
                    
                but cOperation = "box" or cOperation = "box@"
                    if cOperation = "box@"
                        # Look for rounded option in next values
                        bRounded = _FALSE_
                        for j = i+1 to len(aValues)
                            if lower(aValues[j]) = "rounded"
                                bRounded = _TRUE_
                                exit
                            ok
                        next
                        if bRounded
                            cCode += "oStr.BoxXT([ :Rounded = _TRUE_ ])" + NL
                        else
                            cCode += "oStr.BoxXT()" + NL
                        ok
                    else
                        cCode += "oStr.Box()" + NL
                    ok
                    
                but cOperation = "append" and i+1 <= len(aValues)
                    i++
                    cParam = @@(aValues[i])
                    cCode += "oStr.Append(" + cParam + ")" + NL
                    
                but cOperation = "prepend" and i+1 <= len(aValues)
                    i++
                    cParam = @@(aValues[i])
                    cCode += "oStr.Prepend(" + cParam + ")" + NL
                    
                but cOperation = "replace" and i+2 <= len(aValues)
                    i++
                    cParam1 = @@(aValues[i])
                    i++
                    cParam2 = @@(aValues[i])
                    cCode += "oStr.Replace(" + cParam1 + ", " + cParam2 + ")" + NL
                ok
                
                i++
            end
            
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
        ok
        
        return cCode

    def Run()
        eval(This.Code())
