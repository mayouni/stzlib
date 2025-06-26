# Configuration
$nMinValueForShortForm = 10
$nDefaultShortFormItems = 3

# Display width configuration
$nMaxInlineWidth = 50          # Maximum width for keeping lists inline
$nMaxCompactWidth = 35         # Maximum width for compact nested lists
$nMaxComplexityThreshold = 30  # Complexity threshold for expansion

$cIndentChar = TAB

#--- Core Configuration Functions ---

func MinShortForm()
    return $nMinValueForShortForm

func SetMinShortForm(n)
    if NOT isNumber(n)
        raise("MinShortForm value must be a number")
    ok
    $nMinValueForShortForm = n

func MaxInlineWidth()
    return $nMaxInlineWidth

func SetMaxInlineWidth(n)
    if NOT isNumber(n)
        raise("MaxInlineWidth value must be a number")
    ok
    $nMaxInlineWidth = n

func MaxCompactWidth()
    return $nMaxCompactWidth

func SetMaxCompactWidth(n)
    if NOT isNumber(n)
        raise("MaxCompactWidth value must be a number")
    ok
    $nMaxCompactWidth = n

func MaxComplexityThreshold()
    return $nMaxComplexityThreshold

func SetMaxComplexityThreshold(n)
    if NOT isNumber(n)
        raise("MaxComplexityThreshold value must be a number")
    ok
    $nMaxComplexityThreshold = n

#--- Main Display Functions ---

func ComputableForm(pValue)
    return FormatValue(pValue, " ", "")

func ComputableFormNL(pValue)
    if isList(pValue)
        # Always use smart formatting for lists in NL mode
        # The smart formatter will decide internally whether to expand or compact
        return FormatValueSmartNL(pValue, NL, "")
    else
        return ComputableForm(pValue)
    ok

func ComputableFormXT(pValue, cSep, cIndent)
    return FormatValue(pValue, cSep, cIndent)

#--- Short Form Functions ---

func ComputableShortForm(pValue)
    return ComputableShortFormXT(pValue, $nDefaultShortFormItems)

func ComputableShortFormXT(pValue, nItems)
    if NOT (isList(pValue) or isString(pValue))
        raise("Short form only works with lists or strings")
    ok
    
    nLen = GetLength(pValue)
    
    if nLen < $nMinValueForShortForm
        return ComputableForm(pValue)
    ok
    
    if NOT isNumber(nItems)
        raise("Number of items must be a number")
    ok
    
    if nItems * 2 >= nLen
        return ComputableForm(pValue)
    ok
    
    if isList(pValue)
        return FormatShortList(pValue, nItems)
    else
        return FormatShortString(pValue, nItems)
    ok

#--- Display Functions (with output) ---

func Show(pValue)
    ? ComputableForm(pValue)

func ShowNL(pValue)
    ? ComputableFormNL(pValue)

func ShowShort(pValue)
    ? ComputableShortForm(pValue)

func ShowShortXT(pValue, nItems)
    ? ComputableShortFormXT(pValue, nItems)

#--- Helper Functions ---

func GetLength(pValue)
    if isList(pValue)
        return len(pValue)
    else
        oStr = new QString2()
        oStr.append(pValue)
        return oStr.size()
    ok

# Smart expansion logic - only expand when it truly improves readability
func ShouldExpandListSmart(aList)
    if NOT isList(aList)
        return false
    ok
    
    # Always expand if the inline version would be too long
    nEstimatedWidth = EstimateInlineWidth(aList)
    if nEstimatedWidth > $nMaxInlineWidth
        return true
    ok
    
    # Don't expand very small lists
    if len(aList) <= 2
        return false
    ok
    
    # Calculate the "complexity score" of the list
    nComplexity = CalculateComplexity(aList)
    
    # Expand if genuinely complex OR if it would be too wide
    return nComplexity > $nMaxComplexityThreshold or nEstimatedWidth > ($nMaxInlineWidth * 0.8)

func CalculateComplexity(aList)
    nScore = 0
    
    # Base score for list length
    nScore += len(aList) * 5
    
    # Penalty for deep nesting (more than 2 levels)
    nMaxDepth = GetMaxDepth(aList)
    if nMaxDepth > 2
        nScore += (nMaxDepth - 2) * 20
    ok
    
    # Score for long strings
    for item in aList
        if isString(item) and len(item) > 30
            nScore += len(item)
        ok
    next
    
    # Score for wide nested lists (lists with many items)
    for item in aList
        if isList(item) and len(item) > 5
            nScore += len(item) * 3
        ok
    next
    
    return nScore

func GetMaxDepth(aList)
    nMaxDepth = 1
    
    for item in aList
        if isList(item)
            nDepth = 1 + GetMaxDepth(item)
            if nDepth > nMaxDepth
                nMaxDepth = nDepth
            ok
        ok
    next
    
    return nMaxDepth


# Smart formatting specifically for NL mode - always considers expansion
func FormatValueSmartNL(pValue, cSep, cIndent)
    if isNumber(pValue)
        return "" + pValue
        
    but isString(pValue)
        return FormatString(pValue)
        
    but isList(pValue)
        return FormatListSmartNL(pValue, cSep, cIndent)
        
    but isObject(pValue)
        return ObjectVarName(pValue)
        
    else
        raise("Unsupported value type")
    ok


func FormatListSmart(aList, cSep, cIndent)
    if len(aList) = 0
        return "[ ]"
    ok
    
    # Check if this list can be compacted
    if CanCompactList(aList)
        return FormatCompactList(aList)
    ok
    
    # Otherwise, use regular expanded formatting
    cResult = "[" + cSep
    
    for i = 1 to len(aList)
        cResult += cIndent + $cIndentChar + FormatValueSmart(aList[i], cSep, cIndent + $cIndentChar)
        
        if i < len(aList)
            cResult += ","
        ok
        cResult += cSep
    next
    
    cResult += cIndent + "]"
    return cResult


# Smart list formatting specifically for NL mode
func FormatListSmartNL(aList, cSep, cIndent)
    if len(aList) = 0
        return "[ ]"
    ok
    
    # In NL mode, check if the top-level list should be expanded
    nInlineWidth = EstimateInlineWidth(aList)
    
    # More aggressive expansion for readability
    bShouldExpand = false
    
    # Expand if too wide
    if nInlineWidth > $nMaxInlineWidth
        bShouldExpand = true
    ok
    
    # Expand if contains nested lists (visual complexity)
    if NOT bShouldExpand
        for item in aList
            if isList(item) and len(item) > 0
                bShouldExpand = true
                exit
            ok
        next
    ok
    
    # Expand if more than 3 items
    if NOT bShouldExpand and len(aList) > 3
        bShouldExpand = true
    ok
    
    if bShouldExpand
        cResult = "[" + cSep
        cNextIndent = cIndent + $cIndentChar
        
        for i = 1 to len(aList)
            # For each item, decide whether to keep it compact or not
            cFormattedItem = FormatItemForNL(aList[i], cNextIndent)
            cResult += cNextIndent + cFormattedItem
            
            if i < len(aList)
                cResult += ","
            ok
            cResult += cSep
        next
        
        cResult += cIndent + "]"
        return cResult
    ok
    
    # If it's simple enough, keep it compact
    return FormatCompactList(aList)


# Format individual items in NL mode
func FormatItemForNL(pValue, cBaseIndent)
    if isNumber(pValue)
        return "" + pValue
        
    but isString(pValue)
        return FormatString(pValue)
        
    but isList(pValue)
        # For nested lists, be more conservative about keeping them inline
        nWidth = EstimateInlineWidth(pValue)
        
        # Only keep simple, short lists inline
        if len(pValue) <= 3 and nWidth <= $nMaxCompactWidth and NOT ContainsNestedLists(pValue)
            return FormatCompactList(pValue)
        else
            # If nested list is complex, expand it too
            return FormatListSmartNL(pValue, NL, cBaseIndent)
        ok
        
    but isObject(pValue)
        return ObjectVarName(pValue)
        
    else
        raise("Unsupported value type")
    ok


# Check if a list contains nested lists
func ContainsNestedLists(aList)
    for item in aList
        if isList(item)
            return true
        ok
    next
    return false

# Determine if a list can be compacted (kept on fewer lines)
func CanCompactList(aList)
    # Don't compact very long lists
    if len(aList) > 6
        return false
    ok
    
    # Check the total "width" if we were to format inline
    nTotalWidth = EstimateInlineWidth(aList)
    
    # Compact only if it would fit comfortably and isn't too complex
    if nTotalWidth > $nMaxCompactWidth
        return false
    ok
    
    # Don't compact if it contains nested lists (adds visual complexity)
    for item in aList
        if isList(item) and len(item) > 0
            return false
        ok
    next
    
    return true

func EstimateInlineWidth(aList)
    nWidth = 4  # [ and ]
    
    for i = 1 to len(aList)
        if i > 1
            nWidth += 2  # ", "
        ok
        
        nWidth += EstimateItemWidth(aList[i])
    next
    
    return nWidth

func EstimateItemWidth(pValue)
    if isNumber(pValue)
        return len("" + pValue)
        
    but isString(pValue)
        return len(pValue) + 2  # quotes
        
    but isList(pValue)
        if len(pValue) = 0
            return 3  # [ ]
        else
            # For nested lists, calculate their actual inline width
            return EstimateInlineWidth(pValue)
        ok
        
    else
        return 10  # Default estimate
    ok

func FormatCompactList(aList)
    cResult = "[ "
    
    for i = 1 to len(aList)
        cResult += FormatValueCompact(aList[i])
        
        if i < len(aList)
            cResult += ", "
        ok
    next
    
    cResult += " ]"
    return cResult

func FormatValueCompact(pValue)
    if isNumber(pValue)
        return "" + pValue
        
    but isString(pValue)
        return FormatString(pValue)
        
    but isList(pValue)
        # For nested lists in compact mode, try to keep them inline if small
        if len(pValue) <= 5 and EstimateInlineWidth(pValue) <= 30
            return FormatCompactList(pValue)
        else
            # If too complex, fall back to minimal formatting
            return FormatList(pValue, " ", "")
        ok
        
    but isObject(pValue)
        return ObjectVarName(pValue)
        
    else
        raise("Unsupported value type")
    ok

# Original helper functions (unchanged)
func ShouldExpandList(aList)
    if NOT isList(aList)
        return false
    ok
    
    # Expand if list is long
    if len(aList) > 7
        return true
    ok
    
    # Expand if contains nested lists
    for item in aList
        if isList(item)
            return true
        ok
    next
    
    # Expand if contains long strings
    for item in aList
        if isString(item) and len(item) > 20
            return true
        ok
    next
    
    return false

func FormatValue(pValue, cSep, cIndent)
    if isNumber(pValue)
        return "" + pValue
        
    but isString(pValue)
        return FormatString(pValue)
        
    but isList(pValue)
        return FormatList(pValue, cSep, cIndent)
        
    but isObject(pValue)
        return ObjectVarName(pValue)
        
    else
        raise("Unsupported value type")
    ok

func FormatString(cStr)
    if cStr = ""
        return '""'
    ok
    
    # Choose quote character based on content
    if substr(cStr, '"') > 0 and substr(cStr, "'") = 0
        return "'" + cStr + "'"
    else
        return '"' + cStr + '"'
    ok

func FormatList(aList, cSep, cIndent)
    if len(aList) = 0
        return "[ ]"
    ok
    
    cResult = "[" + cSep
    
    for i = 1 to len(aList)
        cResult += FormatValue(aList[i], cSep + cIndent, cIndent)
        
        if i < len(aList)
            cResult += "," + cSep
        ok
    next
    
    cResult += cSep + "]"
    return cResult

func FormatShortList(aList, nItems)
    aShort = []
    nLen = len(aList)
    
    # Add first nItems
    for i = 1 to nItems
        aShort + aList[i]
    next
    
    # Add ellipsis
    aShort + "..."
    
    # Add last nItems
    for i = (nLen - nItems + 1) to nLen
        aShort + aList[i]
    next
    
    return FormatList(aShort, " ", "")

func FormatShortString(cStr, nItems)
    oStr = new QString2()
    oStr.append(cStr)
    nLen = oStr.size()
    
    cResult = ""
    
    # Add first nItems characters
    for i = 0 to nItems - 1
        cResult += oStr.mid(i, 1)
    next
    
    cResult += "..."
    
    # Add last nItems characters
    for i = (nLen - nItems) to nLen - 1
        cResult += oStr.mid(i, 1)
    next
    
    return cResult

#--- Convenient Aliases ---

func @@(pValue)
    return ComputableForm(pValue)

func @@NL(pValue)
    return ComputableFormNL(pValue)

func @@NL1(pValue)
	cResult = "[" + NL
	nLen = len(pValue)
	for i = 1 to nLen
		cResult += TAB + @@(pValue[i])
		if i < nLen
			cResult += "," + NL
		else
			cResult += NL
		ok
	next
	cResult += "]"
	return cResult

func @@S(pValue)
    return ComputableShortForm(pValue)

func @@SXT(pValue, nItems)
    return ComputableShortFormXT(pValue, nItems)
