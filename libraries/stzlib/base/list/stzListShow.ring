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

    _nCsfxLen_ = GetLength(pValue)

    if _nCsfxLen_ < $nMinValueForShortForm
        return ComputableForm(pValue)
    ok

    # Accept either a single number (N first + N last) or a
    # two-element list [nHead, nTail] for asymmetric short forms.

    _nHead_ = 0
    _nTail_ = 0
    if isNumber(nItems)
        _nHead_ = nItems
        _nTail_ = nItems
    but isList(nItems) and len(nItems) = 2 and
        isNumber(nItems[1]) and isNumber(nItems[2])
        _nHead_ = nItems[1]
        _nTail_ = nItems[2]
    else
        raise("Number of items must be a number or a 2-element list [nHead, nTail]")
    ok

    if (_nHead_ + _nTail_) >= _nCsfxLen_
        return ComputableForm(pValue)
    ok

    if isList(pValue)
        return FormatShortList(pValue, [ _nHead_, _nTail_ ])
    else
        return FormatShortString(pValue, _nHead_)
    ok

#--- Short Form Functions ---

func ComputableShortFormNL(pValue)
    return ComputableShortFormXTNL(pValue, $nDefaultShortFormItems)

func ComputableShortFormXTNL(pValue, nItems)
    if NOT (isList(pValue) or isString(pValue))
        raise("Short form only works with lists or strings")
    ok

    _nCsfxnlLen_ = GetLength(pValue)

    if _nCsfxnlLen_ < $nMinValueForShortForm
        return ComputableFormNL(pValue)
    ok

    if NOT isNumber(nItems)
        raise("Number of items must be a number")
    ok

    if nItems * 2 >= _nCsfxnlLen_
        return ComputableFormNL(pValue)
    ok

    if isList(pValue)
        return FormatShortListNL(pValue, nItems)
    else
        return FormatShortString(pValue, nItems)
    ok


    func ComputableShortFormNLXT(pValue, nItems)
	return ComputableShortFormXTNL(pValue, nItems)

#--- Display Functions (with output) ---

func Show(pValue)
    ? ComputableForm(pValue)

func ShowNL(pValue)
    ? ComputableFormNL(pValue)

func ShowShort(pValue)
    ? ComputableShortForm(pValue)

func ShowShortNL(pValue)
    ? ComputableShortFormNL(pValue)

func ShowShortXT(pValue, nItems)
    ? ComputableShortFormXT(pValue, nItems)

func ShowShortXTNL(pValue, nItems)
    ? ComputableShortFormXTNL(pValue, nItems)

    func ShowShortNLXT(pValue, nItems)
	return ShowShortXTNL(pValue, nItems)

#--- Helper Functions ---

func GetLength(pValue)
    if isList(pValue)
        return len(pValue)
    else
        # Count Unicode codepoints (not bytes) in a UTF-8 string
        _nGlCount_ = 0
        _nGlBytes_ = len(pValue)
        _iGl_ = 1
        while _iGl_ <= _nGlBytes_
            _cGl_ = ascii(pValue[_iGl_])
            if (_cGl_ & 0x80) = 0        # 1-byte (ASCII)
                _iGl_++
            but (_cGl_ & 0xE0) = 0xC0    # 2-byte
                _iGl_ += 2
            but (_cGl_ & 0xF0) = 0xE0    # 3-byte
                _iGl_ += 3
            but (_cGl_ & 0xF8) = 0xF0    # 4-byte
                _iGl_ += 4
            else
                _iGl_++                   # invalid byte, skip
            ok
            _nGlCount_++
        end
        return _nGlCount_
    ok

# Smart expansion logic - only expand when it truly improves readability
func ShouldExpandListSmart(aList)
    if NOT isList(aList)
        return false
    ok

    # Always expand if the inline version would be too long
    _nSelsEstWidth_ = EstimateInlineWidth(aList)
    if _nSelsEstWidth_ > $nMaxInlineWidth
        return true
    ok

    # Don't expand very small lists
    if len(aList) <= 2
        return false
    ok

    # Calculate the "complexity score" of the list
    _nSelsCpx_ = CalculateComplexity(aList)

    # Expand if genuinely complex OR if it would be too wide
    return _nSelsCpx_ > $nMaxComplexityThreshold or _nSelsEstWidth_ > ($nMaxInlineWidth * 0.8)

func CalculateComplexity(aList)
    _nCcScore_ = 0

    # Base score for list length
    _nCcScore_ += len(aList) * 5

    # Penalty for deep nesting (more than 2 levels)
    _nCcMaxDepth_ = GetMaxDepth(aList)
    if _nCcMaxDepth_ > 2
        _nCcScore_ += (_nCcMaxDepth_ - 2) * 20
    ok

    # Score for long strings
    _nList8Len_ = len(aList)
    for _iLoopList8_ = 1 to _nList8Len_
    	_itemCcStr_ = aList[_iLoopList8_]
        if isString(_itemCcStr_) and len(_itemCcStr_) > 30
            _nCcScore_ += len(_itemCcStr_)
        ok
    next

    # Score for wide nested lists (lists with many items)
    _nList7Len_ = len(aList)
    for _iLoopList7_ = 1 to _nList7Len_
    	_itemCcLst_ = aList[_iLoopList7_]
        if isList(_itemCcLst_) and len(_itemCcLst_) > 5
            _nCcScore_ += len(_itemCcLst_) * 3
        ok
    next

    return _nCcScore_

func GetMaxDepth(aList)
    _nGmdMaxDepth_ = 1

    _nList6Len_ = len(aList)
    for _iLoopList6_ = 1 to _nList6Len_
    	_itemGmd_ = aList[_iLoopList6_]
        if isList(_itemGmd_)
            _nGmdDepth_ = 1 + GetMaxDepth(_itemGmd_)
            if _nGmdDepth_ > _nGmdMaxDepth_
                _nGmdMaxDepth_ = _nGmdDepth_
            ok
        ok
    next

    return _nGmdMaxDepth_


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
    _cFlsResult_ = "[" + cSep
    _nFlsLen_ = len(aList)
    for _iFls_ = 1 to _nFlsLen_
        _cFlsResult_ += cIndent + $cIndentChar + FormatValueSmart(aList[_iFls_], cSep, cIndent + $cIndentChar)

        if _iFls_ < _nFlsLen_
            _cFlsResult_ += ","
        ok
        _cFlsResult_ += cSep
    next

    _cFlsResult_ += cIndent + "]"
    return _cFlsResult_


# Smart list formatting specifically for NL mode
func FormatListSmartNL(aList, cSep, cIndent)
    if len(aList) = 0
        return "[ ]"
    ok

    # In NL mode, check if the top-level list should be expanded
    _nFlsnlInline_ = EstimateInlineWidth(aList)

    # More aggressive expansion for readability
    _bFlsnlExpand_ = false

    # Expand if too wide
    if _nFlsnlInline_ > $nMaxInlineWidth
        _bFlsnlExpand_ = true
    ok

    # Expand if contains nested lists (visual complexity)
    if NOT _bFlsnlExpand_
        _nList5Len_ = len(aList)
        for _iLoopList5_ = 1 to _nList5Len_
        	_itemFlsnlNest_ = aList[_iLoopList5_]
            if isList(_itemFlsnlNest_) and len(_itemFlsnlNest_) > 0
                _bFlsnlExpand_ = true
                exit
            ok
        next
    ok

    # Expand if more than 3 items
    if NOT _bFlsnlExpand_ and len(aList) > 3
        _bFlsnlExpand_ = true
    ok

    if _bFlsnlExpand_
        _cFlsnlResult_ = "[" + cSep
        _cFlsnlNextIndent_ = cIndent + $cIndentChar
        _nFlsnlLen_ = len(aList)

        for _iFlsnl_ = 1 to _nFlsnlLen_
            # For each item, decide whether to keep it compact or not
            _cFlsnlItem_ = FormatItemForNL(aList[_iFlsnl_], _cFlsnlNextIndent_)
            _cFlsnlResult_ += _cFlsnlNextIndent_ + _cFlsnlItem_

            if _iFlsnl_ < _nFlsnlLen_
                _cFlsnlResult_ += ","
            ok
            _cFlsnlResult_ += cSep
        next

        _cFlsnlResult_ += cIndent + "]"
        return _cFlsnlResult_
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
        _nFifnlWidth_ = EstimateInlineWidth(pValue)

        # Only keep simple, short lists inline
        if len(pValue) <= 3 and _nFifnlWidth_ <= $nMaxCompactWidth and NOT ContainsNestedLists(pValue)
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
    _nList4Len_ = len(aList)
    for _iLoopList4_ = 1 to _nList4Len_
    	_itemCnl_ = aList[_iLoopList4_]
        if isList(_itemCnl_)
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
    _nCclTotal_ = EstimateInlineWidth(aList)

    # Compact only if it would fit comfortably and isn't too complex
    if _nCclTotal_ > $nMaxCompactWidth
        return false
    ok

    # Don't compact if it contains nested lists (adds visual complexity)
    _nList3Len_ = len(aList)
    for _iLoopList3_ = 1 to _nList3Len_
    	_itemCcl_ = aList[_iLoopList3_]
        if isList(_itemCcl_) and len(_itemCcl_) > 0
            return false
        ok
    next

    return true

func EstimateInlineWidth(aList)
    _nEiwWidth_ = 4  # [ and ]
    _nEiwLen_ = len(aList)

    for _iEiw_ = 1 to _nEiwLen_
        if _iEiw_ > 1
            _nEiwWidth_ += 2  # ", "
        ok

        _nEiwWidth_ += EstimateItemWidth(aList[_iEiw_])
    next

    return _nEiwWidth_

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
    _cFclResult_ = "[ "
    _nFclLen_ = len(aList)

    for _iFcl_ = 1 to _nFclLen_
        _cFclResult_ += FormatValueCompact(aList[_iFcl_])

        if _iFcl_ < _nFclLen_
            _cFclResult_ += ", "
        ok
    next

    _cFclResult_ += " ]"
    return _cFclResult_

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
    _nList2Len_ = len(aList)
    for _iLoopList2_ = 1 to _nList2Len_
    	_itemSelNest_ = aList[_iLoopList2_]
        if isList(_itemSelNest_)
            return true
        ok
    next

    # Expand if contains long strings
    _nList1Len_ = len(aList)
    for _iLoopList1_ = 1 to _nList1Len_
    	_itemSelStr_ = aList[_iLoopList1_]
        if isString(_itemSelStr_) and len(_itemSelStr_) > 20
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
    if StzFindFirst('"', cStr) > 0 and StzFindFirst("'", cStr) = 0
        return "'" + cStr + "'"
    else
        return '"' + cStr + '"'
    ok

func FormatList(aList, cSep, cIndent)
    if len(aList) = 0
        return "[ ]"
    ok

    _cFlResult_ = "[" + cSep
    _nFlLen_ = len(aList)

    for _iFl_ = 1 to _nFlLen_
        _cFlResult_ += FormatValue(aList[_iFl_], cSep + cIndent, cIndent)

        if _iFl_ < _nFlLen_
            _cFlResult_ += "," + cSep
        ok
    next

    _cFlResult_ += cSep + "]"

    return _cFlResult_

func FormatListNL(aList, cSep, cIndent)
    if len(aList) = 0
        return "[ ]"
    ok

    _cFlnlResult_ = "[" + NL + cIndent
    _nFlnlLen_ = len(aList)

    for _iFlnl_ = 1 to _nFlnlLen_
        _cFlnlResult_ += TAB + FormatValue(aList[_iFlnl_], cSep, cIndent)

        if _iFlnl_ < _nFlnlLen_
            _cFlnlResult_ += "," + cSep + NL
        ok
    next

    _cFlnlResult_ += NL + "]"
    return _cFlnlResult_

func FormatShortList(aList, nItems)
    _aFslShort_ = []
    _nFslLen_ = len(aList)

    # Accept symmetric (number) or asymmetric ([nHead, nTail]) request.
    _nFslHead_ = 0
    _nFslTail_ = 0
    if isNumber(nItems)
        _nFslHead_ = nItems
        _nFslTail_ = nItems
    but isList(nItems) and len(nItems) = 2
        _nFslHead_ = nItems[1]
        _nFslTail_ = nItems[2]
    ok

    # Add first nHead items
    for _iFslHead_ = 1 to _nFslHead_
        add(_aFslShort_, aList[_iFslHead_])
    next

    # Add ellipsis
    add(_aFslShort_, "...")

    # Add last nTail items
    for _iFslTail_ = (_nFslLen_ - _nFslTail_ + 1) to _nFslLen_
        add(_aFslShort_, aList[_iFslTail_])
    next

    return FormatList(_aFslShort_, " ", "")


func FormatShortListNL(aList, nItems)
    _aFslnlShort_ = []
    _nFslnlLen_ = len(aList)

    # Add first nItems
    for _iFslnlHead_ = 1 to nItems
        add(_aFslnlShort_, aList[_iFslnlHead_])
    next

    # Add ellipsis
    add(_aFslnlShort_, "...")

    # Add last nItems
    for _iFslnlTail_ = (_nFslnlLen_ - nItems + 1) to _nFslnlLen_
        add(_aFslnlShort_, aList[_iFslnlTail_])
    next

    return FormatListNL(_aFslnlShort_, " ", "")

func FormatShortString(cStr, nItems)
    # Build a list of Unicode character byte-offsets and lengths
    _aFssChars_ = []
    _nFssBytes_ = len(cStr)
    _iFssScan_ = 1
    while _iFssScan_ <= _nFssBytes_
        _cFssByte_ = ascii(cStr[_iFssScan_])
        if (_cFssByte_ & 0x80) = 0
            _nFssCharLen_ = 1
        but (_cFssByte_ & 0xE0) = 0xC0
            _nFssCharLen_ = 2
        but (_cFssByte_ & 0xF0) = 0xE0
            _nFssCharLen_ = 3
        but (_cFssByte_ & 0xF8) = 0xF0
            _nFssCharLen_ = 4
        else
            _nFssCharLen_ = 1
        ok
        add(_aFssChars_, [_iFssScan_, _nFssCharLen_])
        _iFssScan_ += _nFssCharLen_
    end

    _nFssLen_ = len(_aFssChars_)
    _cFssResult_ = ""

    # Add first nItems characters
    for _iFssHead_ = 1 to nItems
        if _iFssHead_ <= _nFssLen_
            _cFssResult_ += StzMid(cStr, _aFssChars_[_iFssHead_][1], _aFssChars_[_iFssHead_][2])
        ok
    next

    _cFssResult_ += "..."

    # Add last nItems characters
    for _iFssTail_ = (_nFssLen_ - nItems + 1) to _nFssLen_
        if _iFssTail_ >= 1 and _iFssTail_ <= _nFssLen_
            _cFssResult_ += StzMid(cStr, _aFssChars_[_iFssTail_][1], _aFssChars_[_iFssTail_][2])
        ok
    next

    return _cFssResult_

#--- Convenient Aliases ---

func @@(pValue)
    return ComputableForm(pValue)

func @@NL(pValue)
    return ComputableFormNL(pValue)

# Spacified-newline form -- same as @@NL plus a leading blank line
# so the printed block visually detaches from prior output.
# Used by 386_classify, 387_classify and similar narrative blocks.
func @@SP(pValue)
    return NL + ComputableFormNL(pValue)

func @@NL1(pValue)
	_cAanl1Result_ = "[" + NL
	_nAanl1Len_ = len(pValue)
	for _iAanl1_ = 1 to _nAanl1Len_
		_cAanl1Result_ += TAB + @@(pValue[_iAanl1_])
		if _iAanl1_ < _nAanl1Len_
			_cAanl1Result_ += "," + NL
		else
			_cAanl1Result_ += NL
		ok
	next
	_cAanl1Result_ += "]"
	return _cAanl1Result_

#-- @@XT: the EXTENDED computable form -- like @@NL but with a caller-chosen
#-- line separator and per-element prefix. @@XT(list, NL, TAB) == @@NL(list);
#-- pass a custom prefix (e.g. "#" + TAB) to indent/annotate each row.
func @@XT(pValue, pcSep, pcPrefix)
	if NOT isList(pValue)
		return @@(pValue)
	ok
	_cAaxtRes_ = "[" + pcSep
	_nAaxtLen_ = len(pValue)
	for _iAaxt_ = 1 to _nAaxtLen_
		_cAaxtRes_ += pcPrefix + @@(pValue[_iAaxt_])
		if _iAaxt_ < _nAaxtLen_
			_cAaxtRes_ += "," + pcSep
		else
			_cAaxtRes_ += pcSep
		ok
	next
	_cAaxtRes_ += pcPrefix + "]"
	return _cAaxtRes_

func @@S(pValue)
    return ComputableShortForm(pValue)

func @@SXT(pValue, nItems)
    return ComputableShortFormXT(pValue, nItems)
