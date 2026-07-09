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
func IsJsonString(_cStr_)
    if not isString(_cStr_)
        return FALSE
    ok
    
    _cStr_ = _TrimJson(_cStr_)
    
    if len(_cStr_) = 0
        return FALSE
    ok
    
    # Use a simpler validation approach
    return _IsValidJsonStructure(_cStr_)

	func @IsJsonString(_cStr_)
		return  IsJsonString(_cStr_)

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
	    
	_nLen_ = len(aList)
	if _nLen_ = 0
	    return "[]"
	ok

	# Check if it is a HashList (Ring's normal format) or DeepHashList
	if IsHashList(aList) or _IsValidDeepHashList(aList)
	     return _HashListToJsonString(aList)
	else
	     return _ListToJsonArray(aList)
	ok

	func ListToJsonString(aList)
		return ListToJson(aList)

	func ToJson(aList)
		return ListToJson(aList)

	func Json(aList)
		return ListToJson(aList)

	func @ListToJson(aList)
		return ListToJson(aList)

	func @ListToJsonString(aList)
		return ListToJson(aList)

	func @ToJson(aList)
		return ListToJson(aList)

	func @Json(aList)
		return ListToJson(aList)
	
# Convert Ring list to JSON string with indentation
func ListToJsonXT(aList)
	if not (isList(aList) and IsJsonList(aList))
	    StzRaise("Incorrect param type! aList must be a well-formatted JSON list.")
	ok
  
	_nLen_ = len(aList)
	if _nLen_ = 0
	    return "[]"
	ok
    
	# Check if it is a HashList (Ring's normal format) or DeepHashList
	if IsHashList(aList) or _IsValidDeepHashList(aList)
	   return _HashListToJsonStringXT(aList, 0)
	else
	   return _ListToJsonArrayXT(aList, 0)
	ok

	func @ListToJsonXT(aList)
		return ListToJsonXT(aList)

	func ListToJsonStringXT(aList)
		return ListToJsonXT(aList)

	func ToJsonXT(aList)
		return ListToJsonXT(aList)

	func JsonXT(aList)
		return ListToJsonXT(aList)


	func @ListToJsonStringXT(aList)
		return ListToJsonXT(aList)

	func @ToJsonXT(aList)
		return ListToJsonXT(aList)

	func @JsonXT(aList)
		return ListToJsonXT(aList)

# Convert JSON string to Ring list
func JsonToList(_cJson_)
    if not isString(_cJson_)
        return []
    ok
    
    # Remove whitespace
    _cJson_ = _TrimJson(_cJson_)
    
    if len(_cJson_) = 0
        return []
    ok
    
    # Determine if it's hash or array
    if left(_cJson_, 1) = "{"
        return _JsonHashToList(_cJson_)
    but left(_cJson_, 1) = "["
        return _JsonArrayToList(_cJson_)
    else
        # Single value
        return [ _ParseJsonValue(_cJson_) ]
    ok

	func JsonStringToList(_cJson_)
		return JsonToList(_cJson_)

	func @JsonToList(_cJson_)
		return JsonToList(_cJson_)

#--- helper functions

# Better JSON structure validation
func _IsValidJsonStructure(_cJson_)
    _cJson_ = _TrimJson(_cJson_)
    _nLen_ = len(_cJson_)
    
    if _nLen_ = 0
        return FALSE
    ok
    
    _cFirst_ = left(_cJson_, 1)
    _cLast_ = right(_cJson_, 1)
    
    # Check basic structure
    if _cFirst_ = "{" and _cLast_ = "}"
        return _ValidateJsonObject(_cJson_)
    but _cFirst_ = "[" and _cLast_ = "]"
        return _ValidateJsonArray(_cJson_)
    but _cFirst_ = char(34) and _cLast_ = char(34)
        return _ValidateJsonString(_cJson_)
    but _cJson_ = "null" or _cJson_ = "true" or _cJson_ = "false"
        return TRUE
    but _IsValidJsonNumber(_cJson_)
        return TRUE
    else
        return FALSE
    ok

func _ValidateJsonObject(_cJson_)
    _nLen_ = len(_cJson_)
    if _nLen_ < 2
        return FALSE
    ok
    
    # Basic bracket matching
    _nBraces_ = 0
    _bInString_ = FALSE
    _bEscaped_ = FALSE
    
    for i = 1 to _nLen_
        _cChar_ = _cJson_[i]
        
        if _bEscaped_
            _bEscaped_ = FALSE
            loop
        ok
        
        if _cChar_ = "\"
            _bEscaped_ = TRUE
            loop
        ok
        
        if _cChar_ = char(34)  # Quote
            _bInString_ = not _bInString_
            loop
        ok
        
        if not _bInString_
            if _cChar_ = "{"
                _nBraces_++
            but _cChar_ = "}"
                _nBraces_--
                if _nBraces_ < 0
                    return FALSE
                ok
            ok
        ok
    next
    
    return _nBraces_ = 0

func _ValidateJsonArray(_cJson_)
    _nLen_ = len(_cJson_)
    if _nLen_ < 2
        return FALSE
    ok
    
    # Basic bracket matching
    _nBrackets_ = 0
    _bInString_ = FALSE
    _bEscaped_ = FALSE
    
    for i = 1 to _nLen_
        _cChar_ = _cJson_[i]
        
        if _bEscaped_
            _bEscaped_ = FALSE
            loop
        ok
        
        if _cChar_ = "\"
            _bEscaped_ = TRUE
            loop
        ok
        
        if _cChar_ = char(34)  # Quote
            _bInString_ = not _bInString_
            loop
        ok
        
        if not _bInString_
            if _cChar_ = "["
                _nBrackets_++
            but _cChar_ = "]"
                _nBrackets_--
                if _nBrackets_ < 0
                    return FALSE
                ok
            ok
        ok
    next
    
    return _nBrackets_ = 0

func _ValidateJsonString(_cJson_)
    _nLen_ = len(_cJson_)
    if _nLen_ < 2
        return FALSE
    ok
    
    # Check if properly quoted
    if left(_cJson_, 1) != char(34) or right(_cJson_, 1) != char(34)
        return FALSE
    ok
    
    # Check for proper escaping
    _bEscaped_ = FALSE
    for i = 2 to _nLen_ - 1
        _cChar_ = _cJson_[i]
        
        if _bEscaped_
            _bEscaped_ = FALSE
            loop
        ok
        
        if _cChar_ = "\"
            _bEscaped_ = TRUE
        ok
    next
    
    return TRUE

func _IsValidJsonNumber(_cJson_)
    if not isString(_cJson_)
        return FALSE
    ok
    
    _cJson_ = _TrimJson(_cJson_)
    
    # Check for valid number format
    if _cJson_ = ""
        return FALSE
    ok
    
    # Simple number validation
    try
        _nValue_ = 0 + _cJson_
        return TRUE
    catch
        return FALSE
    done

func _IsValidDeepHashList(aList)
    _nLen_ = len(aList)
    
    # Must have even number of elements for key-value pairs
    if _nLen_ % 2 != 0
        return FALSE
    ok
    
    # Empty list is not a deep hash list
    if _nLen_ = 0
        return FALSE
    ok
    
    # Check if it follows [key1, value1, key2, value2, ...] pattern
    # AND ensure it's not just a simple array of strings
    _bHasNonStringValue_ = FALSE
    for i = 1 to _nLen_ step 2
        if not isString(aList[i])
            return FALSE
        ok
        if not _IsValidJsonValue(aList[i+1])
            return FALSE
        ok
        # Check if we have at least one non-string value or complex structure
        if not isString(aList[i+1]) or isList(aList[i+1])
            _bHasNonStringValue_ = TRUE
        ok
    next
    
    # If all values are strings, it's likely a simple array, not a hash
    if not _bHasNonStringValue_
        return FALSE
    ok
    
    return TRUE

# Check if a value is valid for JSON
func _IsValidJsonValue(_vValue_)
    if isString(_vValue_) or isNumber(_vValue_) or isNULL(_vValue_)
        return TRUE
    ok
    
    if _vValue_ = TRUE or _vValue_ = FALSE
        return TRUE
    ok
    
    if isList(_vValue_)
        return _IsValidDeepHashList(_vValue_) or _IsValidJsonArray(_vValue_)
    ok
    
    return FALSE

func _IsValidJsonArray(aList)
    _nListLen_ = len(aList)
    for i = 1 to _nListLen_
        if not _IsValidJsonValue(aList[i])
            return FALSE
        ok
    next
    return TRUE

func _HashListToJsonString(aList)
    _cResult_ = "{"
    _nLen_ = len(aList)
    
    # Handle both HashList and DeepHashList formats
    if IsHashList(aList)
        # Standard Ring HashList format: [["key1", "value1"], ["key2", "value2"]]
        for i = 1 to _nLen_
            if i > 1
                _cResult_ += ","
            ok
            
            _cKey_ = aList[i][1]
            _vValue_ = aList[i][2]
            
            _cResult_ += char(34) + _cKey_ + char(34) + ":"
            _cResult_ += _ValueToJsonString(_vValue_)
        next
    else
        # DeepHashList format: ["key1", "value1", "key2", "value2"]
        for i = 1 to _nLen_ step 2
            if i > 1
                _cResult_ += ","
            ok
            
            _cResult_ += char(34) + aList[i] + char(34) + ":"
            _cResult_ += _ValueToJsonString(aList[i+1])
        next
    ok
    
    _cResult_ += "}"
    return _cResult_

func _ListToJsonHash(aList)
    _cResult_ = "{"
    _nLen_ = len(aList)
    
    for i = 1 to _nLen_ step 2
        if i > 1
            _cResult_ += ","
        ok
        
        _cResult_ += char(34) + aList[i] + char(34) + ":"
        _cResult_ += _ValueToJsonString(aList[i+1])
    next
    
    _cResult_ += "}"
    return _cResult_

func _ListToJsonArray(aList)
    _cResult_ = "["
    _nLen_ = len(aList)
    
    for i = 1 to _nLen_
        if i > 1
            _cResult_ += ","
        ok
        _cResult_ += _ValueToJsonString(aList[i])
    next
    
    _cResult_ += "]"
    return _cResult_

func _ValueToJsonString(_vValue_)
    if isString(_vValue_)
        return char(34) + _EscapeJsonString(_vValue_) + char(34)
    but isNumber(_vValue_)
        return "" + _vValue_
    but isNULL(_vValue_)
        return "null"
    but _vValue_ = TRUE
        return "true"
    but _vValue_ = FALSE
        return "false"
    but isList(_vValue_)
        if IsHashList(_vValue_) or _IsValidDeepHashList(_vValue_)
            return _HashListToJsonString(_vValue_)
        else
            return _ListToJsonArray(_vValue_)
        ok
    else
        return "null"
    ok

func _ValueToJsonStringXT(_vValue_, nIndent)
    if isString(_vValue_)
        return char(34) + _EscapeJsonString(_vValue_) + char(34)
    but isNumber(_vValue_)
        return "" + _vValue_
    but isNULL(_vValue_)
        return "null"
    but _vValue_ = TRUE
        return "true"
    but _vValue_ = FALSE
        return "false"
    but isList(_vValue_)
        if IsHashList(_vValue_) or _IsValidDeepHashList(_vValue_)
            return _HashListToJsonStringXT(_vValue_, nIndent)
        else
            return _ListToJsonArrayXT(_vValue_, nIndent)
        ok
    else
        return "null"
    ok

func _HashListToJsonStringXT(aList, nIndent)
    _cResult_ = "{" + char(10)
    _nLen_ = len(aList)
    
    # Handle both HashList and DeepHashList formats
    if IsHashList(aList)
        # Standard Ring HashList format: [["key1", "value1"], ["key2", "value2"]]
        for i = 1 to _nLen_
            if i > 1
                _cResult_ += "," + char(10)
            ok
            
            _cKey_ = aList[i][1]
            _vValue_ = aList[i][2]
            
            _cResult_ += _GetIndent(nIndent + 1)
            _cResult_ += char(34) + _cKey_ + char(34) + ": "
            _cResult_ += _ValueToJsonStringXT(_vValue_, nIndent + 1)
        next
    else
        # DeepHashList format: ["key1", "value1", "key2", "value2"]
        for i = 1 to _nLen_ step 2
            if i > 1
                _cResult_ += "," + char(10)
            ok
            
            _cResult_ += _GetIndent(nIndent + 1)
            _cResult_ += char(34) + aList[i] + char(34) + ": "
            _cResult_ += _ValueToJsonStringXT(aList[i+1], nIndent + 1)
        next
    ok
    
    _cResult_ += char(10) + _GetIndent(nIndent) + "}"
    return _cResult_

func _ListToJsonArrayXT(aList, nIndent)
    _cResult_ = "[" + char(10)
    _nLen_ = len(aList)
    
    for i = 1 to _nLen_
        if i > 1
            _cResult_ += "," + char(10)
        ok
        _cResult_ += _GetIndent(nIndent + 1)
        _cResult_ += _ValueToJsonStringXT(aList[i], nIndent + 1)
    next
    
    _cResult_ += char(10) + _GetIndent(nIndent) + "]"
    return _cResult_

func _GetIndent(nLevel)
    _cResult_ = ""
    for i = 1 to nLevel
        _cResult_ += char(9)  # TAB character
    next
    return _cResult_

func _EscapeJsonString(_cStr_)
    _cResult_ = ""
    _nLen_ = len(_cStr_)
    
    for i = 1 to _nLen_
        _cChar_ = _cStr_[i]
        
        switch _cChar_
            on char(34)  # Quote
                _cResult_ += "\" + char(34)
            on char(92)  # Backslash
                _cResult_ += "\\"
            on char(8)   # Backspace
                _cResult_ += "\b"
            on char(12)  # Form feed
                _cResult_ += "\f"
            on char(10)  # Newline
                _cResult_ += "\n"
            on char(13)  # Carriage return
                _cResult_ += "\r"
            on char(9)   # Tab
                _cResult_ += "\t"
            other
                _cResult_ += _cChar_
        off
    next
    
    return _cResult_

func _TrimJson(_cJson_)
    _nStart_ = 1
    _nEnd_ = len(_cJson_)
    
    # Trim leading whitespace
    while _nStart_ <= _nEnd_ and _IsWhitespace(_cJson_[_nStart_])
        _nStart_++
    end
    
    # Trim trailing whitespace
    while _nEnd_ >= _nStart_ and _IsWhitespace(_cJson_[_nEnd_])
        _nEnd_--
    end
    
    if _nStart_ > _nEnd_
        return ""
    ok
    
    return StzMid(_cJson_, _nStart_, _nEnd_ - _nStart_ + 1)

func _JsonHashToList(_cJson_)
    _aResult_ = []
    _nLen_ = len(_cJson_)
    _nPos_ = 2  # Skip opening {
    
    while _nPos_ < _nLen_
        # Skip whitespace
        while _nPos_ <= _nLen_ and _IsWhitespace(_cJson_[_nPos_])
            _nPos_++
        end
        
        if _nPos_ >= _nLen_ or _cJson_[_nPos_] = "}"
            exit
        ok
        
        # Parse key
        if _cJson_[_nPos_] != char(34)
            return []  # Invalid JSON
        ok
        
        _nPos_++  # Skip opening quote
        _cKey_ = ""
        
        while _nPos_ <= _nLen_ and _cJson_[_nPos_] != char(34)
            if _cJson_[_nPos_] = "\" and _nPos_ < _nLen_
                _nPos_++
                if _nPos_ <= _nLen_
                    _cKey_ += _cJson_[_nPos_]
                ok
            else
                _cKey_ += _cJson_[_nPos_]
            ok
            _nPos_++
        end
        
        _nPos_++  # Skip closing quote
        
        # Skip whitespace and colon
        while _nPos_ <= _nLen_ and (_IsWhitespace(_cJson_[_nPos_]) or _cJson_[_nPos_] = ":")
            _nPos_++
        end
        
        # Parse value
        _aValueResult_ = _ParseJsonValueAt(_cJson_, _nPos_)
        _vValue_ = _aValueResult_[1]
        _nPos_ = _aValueResult_[2]
        
        _aResult_ + [ _cKey_, _vValue_ ]
        
        # Skip whitespace and comma
        while _nPos_ <= _nLen_ and (_IsWhitespace(_cJson_[_nPos_]) or _cJson_[_nPos_] = ",")
            _nPos_++
        end
    end
    
    return _aResult_

func _JsonArrayToList(_cJson_)
    _aResult_ = []
    _nLen_ = len(_cJson_)
    _nPos_ = 2  # Skip opening [
    
    while _nPos_ < _nLen_
        # Skip whitespace
        while _nPos_ <= _nLen_ and _IsWhitespace(_cJson_[_nPos_])
            _nPos_++
        end
        
        if _nPos_ >= _nLen_ or _cJson_[_nPos_] = "]"
            exit
        ok
        
        # Parse value
        _aValueResult_ = _ParseJsonValueAt(_cJson_, _nPos_)
        _vValue_ = _aValueResult_[1]
        _nPos_ = _aValueResult_[2]
        
        _aResult_ + _vValue_
        
        # Skip whitespace and comma
        while _nPos_ <= _nLen_ and (_IsWhitespace(_cJson_[_nPos_]) or _cJson_[_nPos_] = ",")
            _nPos_++
        end
    end
    
    return _aResult_

func _ParseJsonValueAt(_cJson_, nStartPos)
    _nPos_ = nStartPos
    _nLen_ = len(_cJson_)
    
    # Skip whitespace
    while _nPos_ <= _nLen_ and _IsWhitespace(_cJson_[_nPos_])
        _nPos_++
    end
    
    if _nPos_ > _nLen_
        return [NULL, _nPos_]
    ok
    
    _cChar_ = _cJson_[_nPos_]
    
    if _cChar_ = char(34)  # String
        _nPos_++
        _cValue_ = ""
        
        while _nPos_ <= _nLen_ and _cJson_[_nPos_] != char(34)
            if _cJson_[_nPos_] = "\" and _nPos_ < _nLen_
                _nPos_++
                if _nPos_ <= _nLen_
                    # Handle escape sequences
                    _cEscChar_ = _cJson_[_nPos_]
                    switch _cEscChar_
                        on "n"
                            _cValue_ += char(10)
                        on "r"
                            _cValue_ += char(13)
                        on "t"
                            _cValue_ += char(9)
                        on "b"
                            _cValue_ += char(8)
                        on "f"
                            _cValue_ += char(12)
                        on "\"
                            _cValue_ += "\"
                        on char(34)
                            _cValue_ += char(34)
                        other
                            _cValue_ += _cEscChar_
                    off
                ok
            else
                _cValue_ += _cJson_[_nPos_]
            ok
            _nPos_++
        end
        
        _nPos_++  # Skip closing quote
        return [_cValue_, _nPos_]
        
    but _cChar_ = "{"  # Hash
        _nBraces_ = 1
        _nStartHash_ = _nPos_
        _nPos_++
        _bInString_ = FALSE
        _bEscaped_ = FALSE
        
        while _nPos_ <= _nLen_ and _nBraces_ > 0
            _cCurrentChar_ = _cJson_[_nPos_]
            
            if _bEscaped_
                _bEscaped_ = FALSE
                _nPos_++
                loop
            ok
            
            if _cCurrentChar_ = "\"
                _bEscaped_ = TRUE
                _nPos_++
                loop
            ok
            
            if not _bInString_
                if _cCurrentChar_ = char(34)  # Quote
                    _bInString_ = TRUE
                but _cCurrentChar_ = "{"
                    _nBraces_++
                but _cCurrentChar_ = "}"
                    _nBraces_--
                ok
            else
                if _cCurrentChar_ = char(34)  # Quote
                    _bInString_ = FALSE
                ok
            ok
            _nPos_++
        end
        
        _cHashJson_ = StzMid(_cJson_, _nStartHash_, _nPos_ - _nStartHash_)
        return [_JsonHashToList(_cHashJson_), _nPos_]
        
    but _cChar_ = "["  # Array
        _nBrackets_ = 1
        _nStartArr_ = _nPos_
        _nPos_++
        _bInString_ = FALSE
        _bEscaped_ = FALSE
        
        while _nPos_ <= _nLen_ and _nBrackets_ > 0
            _cCurrentChar_ = _cJson_[_nPos_]
            
            if _bEscaped_
                _bEscaped_ = FALSE
                _nPos_++
                loop
            ok
            
            if _cCurrentChar_ = "\"
                _bEscaped_ = TRUE
                _nPos_++
                loop
            ok
            
            if not _bInString_
                if _cCurrentChar_ = char(34)  # Quote
                    _bInString_ = TRUE
                but _cCurrentChar_ = "["
                    _nBrackets_++
                but _cCurrentChar_ = "]"
                    _nBrackets_--
                ok
            else
                if _cCurrentChar_ = char(34)  # Quote
                    _bInString_ = FALSE
                ok
            ok
            _nPos_++
        end
        
        _cArrJson_ = StzMid(_cJson_, _nStartArr_, _nPos_ - _nStartArr_)
        return [_JsonArrayToList(_cArrJson_), _nPos_]
        
    else  # Number, boolean, or null
        _cValue_ = ""
        
        while _nPos_ <= _nLen_ and not _IsJsonDelimiter(_cJson_[_nPos_])
            _cValue_ += _cJson_[_nPos_]
            _nPos_++
        end
        
        return [_ParseJsonValue(_cValue_), _nPos_]
    ok

func _ParseJsonValue(_cValue_)
    _cValue_ = _TrimJson(_cValue_)
    
    if _cValue_ = "null"
        return NULL
    but _cValue_ = "true"
        return TRUE
    but _cValue_ = "false"
        return FALSE
    but _IsValidJsonNumber(_cValue_)
        return 0 + _cValue_
    else
        return _cValue_
    ok

func _IsWhitespace(_cChar_)
    return _cChar_ = " " or _cChar_ = char(9) or _cChar_ = char(10) or _cChar_ = char(13)

func _IsJsonDelimiter(_cChar_)
    return _cChar_ = "," or _cChar_ = "}" or _cChar_ = "]" or _IsWhitespace(_cChar_)
