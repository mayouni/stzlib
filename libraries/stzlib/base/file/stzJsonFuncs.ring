# JSON Utility Functions for stzJson Class 
#------------------------------------------

func IsJson(cStrOrList)
	if not (isString(cStrOrList) or isList(cStrOrList))
		StzRaise("Incorrect param type! cStrOrList must be a list or string.")
	ok

	if isString(cStrOrList)
		return IsJsonString(cStrOrList)
	else
		return IsJsonList(cStrOrList)
	ok

	func @IsJson(cStrOrList)
		return IsJson(cStrOrList)

# Check if a string is valid JSON
func IsJsonString(cStr)
    if not isString(cStr)
        return FALSE
    ok
    
    cStr = _TrimJson(cStr)
    
    if len(cStr) = 0
        return FALSE
    ok
    
    # Use a simpler validation approach
    return _IsValidJsonStructure(cStr)

	func @IsJsonString(cStr)
		return  IsJsonString(cStr)

# Check if a list represents a valid DeepHashList structure
func IsJsonList(aList)
    if not isList(aList)
        return FALSE
    ok
    
    # Empty list is valid
    if len(aList) = 0
        return TRUE
    ok
    
    return IsHashList(aList) or _IsValidDeepHashList(aList)

	func IsDeepHashList(aList)
		return IsJsonList(aList)

	func @IsJsonList(aList)
		return IsJsonList(aList)

	func @IsDeepHashList(aList)
		return IsJsonList(aList)

# Convert Ring list to JSON string
func ListToJson(aList)
    if not (isList(aList) and IsJsonList(aList))
        StzRaise("Incorrect param type! aList must be a well-formatted JSON list.")
    ok
    
    nLen = len(aList)
    if nLen = 0
        return "[]"
    ok
    
    # Check if it's a HashList (Ring's normal format) or DeepHashList
    if IsHashList(aList) or _IsValidDeepHashList(aList)
        return _HashListToJsonString(aList)
    else
        return _ListToJsonArray(aList)
    ok

	func ListToJsonString(aList)
		return ListToJson(aList)

	func @ListToJson(aList)
		return ListToJson(aList)

	func @ListToJsonString(aList)
		return ListToJson(aList)

# Convert Ring list to JSON string with indentation
func ListToJsonXT(aList)
    if not (isList(aList) and IsJsonList(aList))
        StzRaise("Incorrect param type! aList must be a well-formatted JSON list.")
    ok
    
    nLen = len(aList)
    if nLen = 0
        return "[]"
    ok
    
    # Check if it's a HashList (Ring's normal format) or DeepHashList
    if IsHashList(aList) or _IsValidDeepHashList(aList)
        return _HashListToJsonStringXT(aList, 0)
    else
        return _ListToJsonArrayXT(aList, 0)
    ok

	func @ListToJsonXT(aList)
		return ListToJsonXT(aList)

# Convert JSON string to Ring list
func JsonToList(cJson)
    if not isString(cJson)
        return []
    ok
    
    # Remove whitespace
    cJson = _TrimJson(cJson)
    
    if len(cJson) = 0
        return []
    ok
    
    # Determine if it's hash or array
    if left(cJson, 1) = "{"
        return _JsonHashToList(cJson)
    but left(cJson, 1) = "["
        return _JsonArrayToList(cJson)
    else
        # Single value
        return [ _ParseJsonValue(cJson) ]
    ok

	func JsonStringToList(cJson)
		return JsonToList(cJson)

	func @JsonToList(cJson)
		return JsonToList(cJson)

#--- helper functions

# Better JSON structure validation
func _IsValidJsonStructure(cJson)
    cJson = _TrimJson(cJson)
    nLen = len(cJson)
    
    if nLen = 0
        return FALSE
    ok
    
    cFirst = left(cJson, 1)
    cLast = right(cJson, 1)
    
    # Check basic structure
    if cFirst = "{" and cLast = "}"
        return _ValidateJsonObject(cJson)
    but cFirst = "[" and cLast = "]"
        return _ValidateJsonArray(cJson)
    but cFirst = char(34) and cLast = char(34)
        return _ValidateJsonString(cJson)
    but cJson = "null" or cJson = "true" or cJson = "false"
        return TRUE
    but _IsValidJsonNumber(cJson)
        return TRUE
    else
        return FALSE
    ok

func _ValidateJsonObject(cJson)
    nLen = len(cJson)
    if nLen < 2
        return FALSE
    ok
    
    # Basic bracket matching
    nBraces = 0
    bInString = FALSE
    bEscaped = FALSE
    
    for i = 1 to nLen
        cChar = cJson[i]
        
        if bEscaped
            bEscaped = FALSE
            loop
        ok
        
        if cChar = "\"
            bEscaped = TRUE
            loop
        ok
        
        if cChar = char(34)  # Quote
            bInString = not bInString
            loop
        ok
        
        if not bInString
            if cChar = "{"
                nBraces++
            but cChar = "}"
                nBraces--
                if nBraces < 0
                    return FALSE
                ok
            ok
        ok
    next
    
    return nBraces = 0

func _ValidateJsonArray(cJson)
    nLen = len(cJson)
    if nLen < 2
        return FALSE
    ok
    
    # Basic bracket matching
    nBrackets = 0
    bInString = FALSE
    bEscaped = FALSE
    
    for i = 1 to nLen
        cChar = cJson[i]
        
        if bEscaped
            bEscaped = FALSE
            loop
        ok
        
        if cChar = "\"
            bEscaped = TRUE
            loop
        ok
        
        if cChar = char(34)  # Quote
            bInString = not bInString
            loop
        ok
        
        if not bInString
            if cChar = "["
                nBrackets++
            but cChar = "]"
                nBrackets--
                if nBrackets < 0
                    return FALSE
                ok
            ok
        ok
    next
    
    return nBrackets = 0

func _ValidateJsonString(cJson)
    nLen = len(cJson)
    if nLen < 2
        return FALSE
    ok
    
    # Check if properly quoted
    if left(cJson, 1) != char(34) or right(cJson, 1) != char(34)
        return FALSE
    ok
    
    # Check for proper escaping
    bEscaped = FALSE
    for i = 2 to nLen - 1
        cChar = cJson[i]
        
        if bEscaped
            bEscaped = FALSE
            loop
        ok
        
        if cChar = "\"
            bEscaped = TRUE
        ok
    next
    
    return TRUE

func _IsValidJsonNumber(cJson)
    if not isString(cJson)
        return FALSE
    ok
    
    cJson = _TrimJson(cJson)
    
    # Check for valid number format
    if cJson = ""
        return FALSE
    ok
    
    # Simple number validation
    try
        nValue = 0 + cJson
        return TRUE
    catch
        return FALSE
    done

func _IsValidDeepHashList(aList)
    nLen = len(aList)
    
    # Must have even number of elements for key-value pairs
    if nLen % 2 != 0
        return FALSE
    ok
    
    # Empty list is not a deep hash list
    if nLen = 0
        return FALSE
    ok
    
    # Check if it follows [key1, value1, key2, value2, ...] pattern
    # AND ensure it's not just a simple array of strings
    bHasNonStringValue = FALSE
    for i = 1 to nLen step 2
        if not isString(aList[i])
            return FALSE
        ok
        if not _IsValidJsonValue(aList[i+1])
            return FALSE
        ok
        # Check if we have at least one non-string value or complex structure
        if not isString(aList[i+1]) or isList(aList[i+1])
            bHasNonStringValue = TRUE
        ok
    next
    
    # If all values are strings, it's likely a simple array, not a hash
    if not bHasNonStringValue
        return FALSE
    ok
    
    return TRUE

# Check if a value is valid for JSON
func _IsValidJsonValue(vValue)
    if isString(vValue) or isNumber(vValue) or isNULL(vValue)
        return TRUE
    ok
    
    if vValue = TRUE or vValue = FALSE
        return TRUE
    ok
    
    if isList(vValue)
        return _IsValidDeepHashList(vValue) or _IsValidJsonArray(vValue)
    ok
    
    return FALSE

func _IsValidJsonArray(aList)
    for i = 1 to len(aList)
        if not _IsValidJsonValue(aList[i])
            return FALSE
        ok
    next
    return TRUE

func _HashListToJsonString(aList)
    cResult = "{"
    nLen = len(aList)
    
    # Handle both HashList and DeepHashList formats
    if IsHashList(aList)
        # Standard Ring HashList format: [["key1", "value1"], ["key2", "value2"]]
        for i = 1 to nLen
            if i > 1
                cResult += ","
            ok
            
            cKey = aList[i][1]
            vValue = aList[i][2]
            
            cResult += char(34) + cKey + char(34) + ":"
            cResult += _ValueToJsonString(vValue)
        next
    else
        # DeepHashList format: ["key1", "value1", "key2", "value2"]
        for i = 1 to nLen step 2
            if i > 1
                cResult += ","
            ok
            
            cResult += char(34) + aList[i] + char(34) + ":"
            cResult += _ValueToJsonString(aList[i+1])
        next
    ok
    
    cResult += "}"
    return cResult

func _ListToJsonHash(aList)
    cResult = "{"
    nLen = len(aList)
    
    for i = 1 to nLen step 2
        if i > 1
            cResult += ","
        ok
        
        cResult += char(34) + aList[i] + char(34) + ":"
        cResult += _ValueToJsonString(aList[i+1])
    next
    
    cResult += "}"
    return cResult

func _ListToJsonArray(aList)
    cResult = "["
    nLen = len(aList)
    
    for i = 1 to nLen
        if i > 1
            cResult += ","
        ok
        cResult += _ValueToJsonString(aList[i])
    next
    
    cResult += "]"
    return cResult

func _ValueToJsonString(vValue)
    if isString(vValue)
        return char(34) + _EscapeJsonString(vValue) + char(34)
    but isNumber(vValue)
        return "" + vValue
    but isNULL(vValue)
        return "null"
    but vValue = TRUE
        return "true"
    but vValue = FALSE
        return "false"
    but isList(vValue)
        if IsHashList(vValue) or _IsValidDeepHashList(vValue)
            return _HashListToJsonString(vValue)
        else
            return _ListToJsonArray(vValue)
        ok
    else
        return "null"
    ok

func _ValueToJsonStringXT(vValue, nIndent)
    if isString(vValue)
        return char(34) + _EscapeJsonString(vValue) + char(34)
    but isNumber(vValue)
        return "" + vValue
    but isNULL(vValue)
        return "null"
    but vValue = TRUE
        return "true"
    but vValue = FALSE
        return "false"
    but isList(vValue)
        if IsHashList(vValue) or _IsValidDeepHashList(vValue)
            return _HashListToJsonStringXT(vValue, nIndent)
        else
            return _ListToJsonArrayXT(vValue, nIndent)
        ok
    else
        return "null"
    ok

func _HashListToJsonStringXT(aList, nIndent)
    cResult = "{" + char(10)
    nLen = len(aList)
    
    # Handle both HashList and DeepHashList formats
    if IsHashList(aList)
        # Standard Ring HashList format: [["key1", "value1"], ["key2", "value2"]]
        for i = 1 to nLen
            if i > 1
                cResult += "," + char(10)
            ok
            
            cKey = aList[i][1]
            vValue = aList[i][2]
            
            cResult += _GetIndent(nIndent + 1)
            cResult += char(34) + cKey + char(34) + ": "
            cResult += _ValueToJsonStringXT(vValue, nIndent + 1)
        next
    else
        # DeepHashList format: ["key1", "value1", "key2", "value2"]
        for i = 1 to nLen step 2
            if i > 1
                cResult += "," + char(10)
            ok
            
            cResult += _GetIndent(nIndent + 1)
            cResult += char(34) + aList[i] + char(34) + ": "
            cResult += _ValueToJsonStringXT(aList[i+1], nIndent + 1)
        next
    ok
    
    cResult += char(10) + _GetIndent(nIndent) + "}"
    return cResult

func _ListToJsonArrayXT(aList, nIndent)
    cResult = "[" + char(10)
    nLen = len(aList)
    
    for i = 1 to nLen
        if i > 1
            cResult += "," + char(10)
        ok
        cResult += _GetIndent(nIndent + 1)
        cResult += _ValueToJsonStringXT(aList[i], nIndent + 1)
    next
    
    cResult += char(10) + _GetIndent(nIndent) + "]"
    return cResult

func _GetIndent(nLevel)
    cResult = ""
    for i = 1 to nLevel
        cResult += char(9)  # TAB character
    next
    return cResult

func _EscapeJsonString(cStr)
    cResult = ""
    nLen = len(cStr)
    
    for i = 1 to nLen
        cChar = cStr[i]
        
        switch cChar
            on char(34)  # Quote
                cResult += "\" + char(34)
            on char(92)  # Backslash
                cResult += "\\"
            on char(8)   # Backspace
                cResult += "\b"
            on char(12)  # Form feed
                cResult += "\f"
            on char(10)  # Newline
                cResult += "\n"
            on char(13)  # Carriage return
                cResult += "\r"
            on char(9)   # Tab
                cResult += "\t"
            other
                cResult += cChar
        off
    next
    
    return cResult

func _TrimJson(cJson)
    nStart = 1
    nEnd = len(cJson)
    
    # Trim leading whitespace
    while nStart <= nEnd and _IsWhitespace(cJson[nStart])
        nStart++
    end
    
    # Trim trailing whitespace
    while nEnd >= nStart and _IsWhitespace(cJson[nEnd])
        nEnd--
    end
    
    if nStart > nEnd
        return ""
    ok
    
    return substr(cJson, nStart, nEnd - nStart + 1)

func _JsonHashToList(cJson)
    aResult = []
    nLen = len(cJson)
    nPos = 2  # Skip opening {
    
    while nPos < nLen
        # Skip whitespace
        while nPos <= nLen and _IsWhitespace(cJson[nPos])
            nPos++
        end
        
        if nPos >= nLen or cJson[nPos] = "}"
            exit
        ok
        
        # Parse key
        if cJson[nPos] != char(34)
            return []  # Invalid JSON
        ok
        
        nPos++  # Skip opening quote
        cKey = ""
        
        while nPos <= nLen and cJson[nPos] != char(34)
            if cJson[nPos] = "\" and nPos < nLen
                nPos++
                if nPos <= nLen
                    cKey += cJson[nPos]
                ok
            else
                cKey += cJson[nPos]
            ok
            nPos++
        end
        
        nPos++  # Skip closing quote
        
        # Skip whitespace and colon
        while nPos <= nLen and (_IsWhitespace(cJson[nPos]) or cJson[nPos] = ":")
            nPos++
        end
        
        # Parse value
        aValueResult = _ParseJsonValueAt(cJson, nPos)
        vValue = aValueResult[1]
        nPos = aValueResult[2]
        
        aResult + [ cKey, vValue ]
        
        # Skip whitespace and comma
        while nPos <= nLen and (_IsWhitespace(cJson[nPos]) or cJson[nPos] = ",")
            nPos++
        end
    end
    
    return aResult

func _JsonArrayToList(cJson)
    aResult = []
    nLen = len(cJson)
    nPos = 2  # Skip opening [
    
    while nPos < nLen
        # Skip whitespace
        while nPos <= nLen and _IsWhitespace(cJson[nPos])
            nPos++
        end
        
        if nPos >= nLen or cJson[nPos] = "]"
            exit
        ok
        
        # Parse value
        aValueResult = _ParseJsonValueAt(cJson, nPos)
        vValue = aValueResult[1]
        nPos = aValueResult[2]
        
        aResult + vValue
        
        # Skip whitespace and comma
        while nPos <= nLen and (_IsWhitespace(cJson[nPos]) or cJson[nPos] = ",")
            nPos++
        end
    end
    
    return aResult

func _ParseJsonValueAt(cJson, nStartPos)
    nPos = nStartPos
    nLen = len(cJson)
    
    # Skip whitespace
    while nPos <= nLen and _IsWhitespace(cJson[nPos])
        nPos++
    end
    
    if nPos > nLen
        return [NULL, nPos]
    ok
    
    cChar = cJson[nPos]
    
    if cChar = char(34)  # String
        nPos++
        cValue = ""
        
        while nPos <= nLen and cJson[nPos] != char(34)
            if cJson[nPos] = "\" and nPos < nLen
                nPos++
                if nPos <= nLen
                    # Handle escape sequences
                    cEscChar = cJson[nPos]
                    switch cEscChar
                        on "n"
                            cValue += char(10)
                        on "r"
                            cValue += char(13)
                        on "t"
                            cValue += char(9)
                        on "b"
                            cValue += char(8)
                        on "f"
                            cValue += char(12)
                        on "\"
                            cValue += "\"
                        on char(34)
                            cValue += char(34)
                        other
                            cValue += cEscChar
                    off
                ok
            else
                cValue += cJson[nPos]
            ok
            nPos++
        end
        
        nPos++  # Skip closing quote
        return [cValue, nPos]
        
    but cChar = "{"  # Hash
        nBraces = 1
        nStartHash = nPos
        nPos++
        bInString = FALSE
        bEscaped = FALSE
        
        while nPos <= nLen and nBraces > 0
            cCurrentChar = cJson[nPos]
            
            if bEscaped
                bEscaped = FALSE
                nPos++
                loop
            ok
            
            if cCurrentChar = "\"
                bEscaped = TRUE
                nPos++
                loop
            ok
            
            if not bInString
                if cCurrentChar = char(34)  # Quote
                    bInString = TRUE
                but cCurrentChar = "{"
                    nBraces++
                but cCurrentChar = "}"
                    nBraces--
                ok
            else
                if cCurrentChar = char(34)  # Quote
                    bInString = FALSE
                ok
            ok
            nPos++
        end
        
        cHashJson = substr(cJson, nStartHash, nPos - nStartHash)
        return [_JsonHashToList(cHashJson), nPos]
        
    but cChar = "["  # Array
        nBrackets = 1
        nStartArr = nPos
        nPos++
        bInString = FALSE
        bEscaped = FALSE
        
        while nPos <= nLen and nBrackets > 0
            cCurrentChar = cJson[nPos]
            
            if bEscaped
                bEscaped = FALSE
                nPos++
                loop
            ok
            
            if cCurrentChar = "\"
                bEscaped = TRUE
                nPos++
                loop
            ok
            
            if not bInString
                if cCurrentChar = char(34)  # Quote
                    bInString = TRUE
                but cCurrentChar = "["
                    nBrackets++
                but cCurrentChar = "]"
                    nBrackets--
                ok
            else
                if cCurrentChar = char(34)  # Quote
                    bInString = FALSE
                ok
            ok
            nPos++
        end
        
        cArrJson = substr(cJson, nStartArr, nPos - nStartArr)
        return [_JsonArrayToList(cArrJson), nPos]
        
    else  # Number, boolean, or null
        cValue = ""
        
        while nPos <= nLen and not _IsJsonDelimiter(cJson[nPos])
            cValue += cJson[nPos]
            nPos++
        end
        
        return [_ParseJsonValue(cValue), nPos]
    ok

func _ParseJsonValue(cValue)
    cValue = _TrimJson(cValue)
    
    if cValue = "null"
        return NULL
    but cValue = "true"
        return TRUE
    but cValue = "false"
        return FALSE
    but _IsValidJsonNumber(cValue)
        return 0 + cValue
    else
        return cValue
    ok

func _IsWhitespace(cChar)
    return cChar = " " or cChar = char(9) or cChar = char(10) or cChar = char(13)

func _IsJsonDelimiter(cChar)
    return cChar = "," or cChar = "}" or cChar = "]" or _IsWhitespace(cChar)
