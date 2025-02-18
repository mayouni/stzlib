load "qtcore.ring"

_MinValueForComputableShortFormXT = 10

#---

func MinValueForComputableShortFormXT()
	return _MinValueForComputableShortFormXT

	func MinSF()
		return _MinValueForComputableShortFormXT

	func MinSFXT()
		return _MinValueForComputableShortFormXT

	func MinShortForm()
		return _MinValueForComputableShortFormXT

	func MinShortFormXT()
		return _MinValueForComputableShortFormXT

func SetValueForComputableShortFormXT(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	_MinValueForComputableShortFormXT = n

	func SetMinShortForm(n)
		SetValueForComputableShortFormXT(n)

	func SetMinShortFormXT(n)
		SetValueForComputableShortFormXT(n)

	func SetMinValueForComputableShortForm(n)
		SetValueForComputableShortFormXT(n)

	func SetMinValueForComputableShortFormXT(n)
		SetValueForComputableShortFormXT(n)

	func SetMinSF(n)
		SetValueForComputableShortFormXT(n)

func Show(pValue)
	? ComputableForm(pValue)

	func @Show(pValue)
		return Show(pValue)

func ComputableShortForm(paList)
	return ComputableShortFormXT(paList, 3)

	func @@SF(paList)
		return ComputableShortForm(paList)


	func @@S(paList)
		return ComputableShortForm(paList)

	func ShortForm(paList)
		return ComputableShortForm(paList)


func ShowShort(paList)
	? ComputableShortForm(paList)

	func ShowPart(paList)
		ShowShort(paList)

	#< @FunctionMisspelledForm

	func ShwoShort(paList)
		ShowShort(paList)

	#>

func @@SN(paList, n)
	if NOT isNumber(n)
		raise("Incorrect param type! n must be a number.")
	ok

	return @@SXT(paList, n)

func ShowShortN(paList, n)
	? @@SN(paList, n)

	#< @FunctionMisspelledForm

	func ShwoShortN(paList, n)
		ShowShortN(paList, n)

	#>

func ComputableShortFormXT(paListOrStr, p)

	if NOT ( isList(paListOrStr) or isString(paListOrStr) )
		raise("Incorrect param type! paListOrStr must be a list or string.")
	ok

	if isList(paListOrStr)
		nLen = len(paListOrStr)
		cThings = "items"
	else

		oQStr = new QString2()
		oQStr.append(paListOrStr)
		nLen = oQStr.size()
		cThings = "chars"
	ok

	if nLen < MinValueForComputableShortFormXT()
		return ComputableForm(paListOrStr)
	ok

	if NOT ( isNumber(p) or ( isList(p) and len(p) = 2 and isNumber(p[1]) and isNumber(p[2]) ) )
		raise("Incorrect param type! p must be a number or a pair of numbers.")
	ok

	n1 = 0
	n2 = 0

	if isNumber(p)
		n1 = p
		n2 = p

	else
		n1 = p[1]
		n2 = p[2]
	ok

	if n1 + n2 >= nLen
		raise("Incorrect value(s)! The number of" + cThings = " to show exceeds the size of the list.")
	ok


	if isList(paListOrStr)

		# Constructing the content of the "short" list

		aContent = []
		for i = 1 to n1
			aContent + paListOrStr[i]
		next
	
		aContent + "..."
		for i = nLen - n2 + 1 to nLen
			aContent + paListOrStr[i]
		next

		nLen = len(aContent)

		#-- Composing the computational form (string) to be showen

		if nLen = 0
			return "[ ]"
		ok
	
		cResult = "[ "
	
		for i = 1 to nLen
			if isNumber(aContent[i])
				cResult += "" +
					   aContent[i] + ", "
	
			but isString(aContent[i])
				cChar = '"'
			
				oQStr = new QString2()
				oQStr.append(aContent[i])
				c1 = oQStr.mid(0, 1)
				c2 = oQStr.mid(oQStr.size()-1, 1)
			
				if c1 = '"' or
				   c2 = '"'
					cChar = "'"
				ok
			
				cResult += (cChar + aContent[i] + cChar + ", ")
	
			but isList(aContent[i])
				cResult += ( ComputableForm(aContent[i]) + ", ")
	
			but isObject(aContent[i])
				cResult += ObjectVarName(aContent[i]) + ", "
		
			ok
	
		next

		oQStr = new QString2()
		oQStr.append(cResult)
		oQStr.replace( (oQStr.size() - 2), 2, "" )
		oQStr.append(" ]")
	
		cResult = oQStr.mid(0, oQStr.size())
		return cResult

	else # Case paListOrStr is string
		cResult = ""
		for i = 1 to n1
			cResult += oQStr.mid(i-1, 1)
		next

		cResult += "..."

		for i = nLen - n2 + 1 to nLen
			cResult += oQStr.mid(i-1, 1)
		next

		return cResult

	ok

	#< @FunctionAlternativeForms

	func ShortFormXT(paList, p)
		return ComputableShortFormXT(paList, p)

	func @@SFXT(paList, p)
		return ComputableShortFormXT(paList, p)

	func @@SXT(paList, p)
		return ComputableShortFormXT(paList, p)

	#>
	
func ShowShortXT(paList, p)
	? ComputableShortFormXT(paList, p)

	#< @FunctionMisspelledForm

	func ShwoShortFormXT(paList, p)
		ShowShortXT(paList, p)

	func @ShowShortXT(paList, p)
		ShowShortXT(paList, p)

	func @ShwoShortFormXT(paList, p)
		ShowShortXT(paList, p)

	#>

#------

func NL@@(pValue)
	return NL + @@(pValue)

func NL@@NL(pValue)
	if isString(pValue)
		return NL + pValue + NL
	else
		return NL + @@NL(pValue) + NL
	ok

func ComputableForm(pValue)
	return ComputableFormXT(pValue, " ", "")

	#< @FunctionAlternativeForms

	func 🕶(pValue)
		return ComputableForm(pValue)

	func 😎(pValue)
		return ComputableForm(pValue)

	func @@(pValue)
		return ComputableForm(pValue)

	func CF(pValue)
		return ComputableForm(pValue)

	func @ComputableForm(pValue)
		return ComputableForm(pValue)

	#>

func ComputableFormNL(pValue)
	return ComputableFormXT(pValue, NL, TAB)

	#< @FunctionAlternativeForms

	func @@NL(pValue)
		return ComputableFormNL(pValue)

	func CFNL(pValue)
		return ComputableFormNL(pValue)

	func @ComputableFormNL(pValue)
		return ComputableFormNL(pValue)

	#--

	func @@SP(pValue)
		return ComputableFormNL(pValue)

	func ComputableFormSP(pValue)
		return ComputableFormNL(pValue)

	func @ComputableFormSP(pValue)
		return ComputableFormNL(pValue)

	func ComputableFormSpacified(pValue)
		return ComputableFormNL(pValue)

	func @ComputableFormSpacified(pValue)
		return ComputableFormNL(pValue)

	func CFSP(pValue)
		return ComputableFormNL(pValue)

	func @CFSP(pValue)
		return ComputableFormNL(pValue)

	#>

#---

func ComputableFormXT(pValue, cSep1, cSep2)
    return ComputableFormXTInternal(pValue, cSep1, cSep2, 0)

# Internal implementation that handles the nLevel parameter
func ComputableFormXTInternal(pValue, cSep1, cSep2, nLevel)

    if isNumber(pValue)
        return ""+ pValue

    but isString(pValue)

        oQStr = new QString2()
        oQStr.append(pValue)

        if oQStr.size() = 1

            if pValue = '"'
                cBound = "'"
                cResult = cBound + pValue + cBound

            else
                cBound = '"'
                cResult = cBound + pValue + cBound
            ok

            return cResult

        else

            cChar = '"'

            oQStr = new QString2()
            oQStr.append(pValue)
            c1 = oQStr.mid(0, 1)
            c2 = oQStr.mid(oQStr.size()-1, 1)

            if c1 = '"' or
               c2 = '"'
                cChar = "'"
            ok

            n1 = oQStr.indexof('"', 1, 0) + 1
            n2 = oQStr.indexof("'", 1, 0) + 1

            if n1 = 0 and n2 = 0
                cChar = '"'

            but n1 = 0
                cChar = '"'

            but n2 = 0
                cChar = "'"

            but n1 < n2
                cChar = "'"
            else
                cChar = '"'
            ok

            cResult = cChar + pValue + cChar

            return cResult

        ok

    but isList(pValue)

        aContent = pValue
        nLen = len(aContent)

        if nLen = 0
            return "[ ]"
        ok
        
        # Determine if this list needs complex nesting format
        bComplexNesting = isListWithComplexNesting(aContent)
        
        if bComplexNesting
            # Create indentation for current level and content level
            cIndent = getIndentation(nLevel)
            cContentIndent = getIndentation(nLevel + 1)
            
            # Start with opening bracket at current indentation level
            cResult = "[" + NL + cContentIndent
            
            for i = 1 to nLen
                if isNumber(aContent[i])
                    cResult += aContent[i]
                    
                but isString(acontent[i])
                    oQStr = new QString2()
                    oQStr.append(acontent[i])

                    if oQStr.size() = 1
                        if aContent[i] = '"'
                            cBound = "'"
                            cResult += cBound + aContent[i] + cBound
                        else
                            cBound = '"'
                            cResult += cBound + aContent[i] + cBound
                        ok
                    else
                        cChar = determineStringQuote(aContent[i])
                        cResult += cChar + aContent[i] + cChar
                    ok
                    
                but isList(aContent[i])
                    if isListWithComplexNesting(aContent[i])
                        # Complex nested list - recursive call with increased indent level
                        cResult += ComputableFormXTInternal(aContent[i], cSep1, cSep2, nLevel + 1)
                    else 
                        # Simple list - use inline formatting
                        cResult += CompactListFormat(aContent[i])
                    ok
                    
                but isObject(aContent[i])
                    cResult += ObjectVarName(aContent[i])
                ok
                
                # Add comma and proper indentation for next item
                if i < nLen
                    cResult += "," + NL + cContentIndent
                ok
            next
            
            # Close with bracket at original indentation level
            cResult += NL + cIndent + "]"
            
            return cResult
        else
            # Simple list - use compact format
            return CompactListFormat(aContent)
        ok

    but isObject(pValue)

        cResult = ObjectVarName(pValue)
        return cResult

    else
        StzRaise("Can't proceed! The @@() function was unable to recognize the format of the data provided.")
    ok

# Helper function to determine if a list needs complex nesting
func isListWithComplexNesting(aList)
    if not isList(aList) return false ok
    
    if len(aList) = 0 return false ok
    
    # Count the number of nested lists
    nNestedListCount = 0
    
    # Check if any nested list itself contains another list
    bHasComplexNesting = false
    
    for i = 1 to len(aList)
        if isList(aList[i]) 
            nNestedListCount++
            
            # If a nested list has more than simple strings/numbers, 
            # it's complex nesting
            for j = 1 to len(aList[i])
                if isList(aList[i][j])
                    bHasComplexNesting = true
                    exit
                ok
            next
            
            if bHasComplexNesting exit ok
        ok
    next
    
    # Consider a list complex if it has nested lists with deeper nesting
    # or more than 1 nested lists and the overall list length is significant
    return bHasComplexNesting or (nNestedListCount > 1 and len(aList) >= 4)

# Helper function to format simple lists in a compact way
func CompactListFormat(aList)
    if not isList(aList) return "[]" ok
    
    if len(aList) = 0 return "[ ]" ok
    
    cResult = "[ "
    
    for i = 1 to len(aList)
        if isString(aList[i])
            cChar = determineStringQuote(aList[i])
            cResult += cChar + aList[i] + cChar
        but isNumber(aList[i])
            cResult += "" + aList[i]
        but isList(aList[i])
            cResult += CompactListFormat(aList[i])
        but isObject(aList[i])
            cResult += ObjectVarName(aList[i])
        ok
        
        if i < len(aList)
            cResult += ", "
        ok
    next
    
    cResult += " ]"
    return cResult

# Helper function to determine appropriate quote character for a string
func determineStringQuote(cStr)
    oQStr = new QString2()
    oQStr.append(cStr)
    
    if oQStr.size() = 1 and cStr = '"'
        return "'"
    ok
    
    c1 = oQStr.mid(0, 1)
    c2 = oQStr.mid(oQStr.size()-1, 1)
    
    if c1 = '"' or
       c2 = '"'
        return "'"
    ok
    
    n1 = oQStr.indexof('"', 1, 0) + 1
    n2 = oQStr.indexof("'", 1, 0) + 1
    
    if n1 = 0 and n2 = 0
        return '"'
    but n1 = 0
        return '"'
    but n2 = 0
        return "'"
    but n1 < n2
        return "'"
    else
        return '"'
    ok

# Helper function to create indentation based on nesting level
func getIndentation(nLevel)
    cIndent = ""
    for i = 1 to nLevel
        cIndent += TAB
    next
    return cIndent

//func ComputableFormXT(pValue, cSep1, cSep2)
//
//	if isNumber(pValue)
//		return ""+ pValue
//
//	but isString(pValue)
//
//		oQStr = new QString2()
//		oQStr.append(pValue)
//
//		if oQStr.size() = 1
//
//			if pValue = '"'
//				cBound = "'"
//				cResult = cBound + pValue + cBound
//	
//			else
//				cBound = '"'
//				cResult = cBound + pValue + cBound
//			ok
//
//			return cResult
//
//		else
//
//			cChar = '"'
//	
//			oQStr = new QString2()
//			oQStr.append(pValue)
//			c1 = oQStr.mid(0, 1)
//			c2 = oQStr.mid(oQStr.size()-1, 1)
//	
//			if c1 = '"' or
//			   c2 = '"'
//				cChar = "'"
//			ok
//	
//			n1 = oQStr.indexof('"', 1, 0) + 1
//			n2 = oQStr.indexof("'", 1, 0) + 1
//	
//			if n1 = 0 and n2 = 0
//				cChar = '"'
//	
//			but n1 = 0
//				cChar = '"'
//	
//			but n2 = 0
//				cChar = "'"
//	
//			but n1 < n2
//				cChar = "'"
//			else
//				cChar = '"'
//			ok
//	
//			cResult = cChar + pValue + cChar
//
//			return cResult
//
//		ok
//
//	but isList(pValue)
//
//		aContent = pValue
//		nLen = len(aContent)
//
//		if nLen = 0
//			return "[ ]"
//		ok
//
//		cResult = "[" + cSep1
//
//		for i = 1 to nLen
//			if isNumber(aContent[i])
//				cResult += "" +
//					   cSep2 + aContent[i] + "," + cSep1
//
//			but isString(acontent[i])
//
//				oQStr = new QString2()
//				oQStr.append(acontent[i])
//		
//				if oQStr.size() = 1
//			
//					if aContent[i] = '"'
//						cBound = "'"
//						cResult += (cSep2 + cBound + aContent[i]  + cBound + "," + cSep1)
//			
//					else
//						cBound = '"'
//						cResult += ( cSep2 + cBound + aContent[i]  + cBound + "," + cSep1 )
//		
//					ok
//
//				else
//
//					cChar = '"'
//		
//					oQStr = new QString2()
//					oQStr.append(aContent[i])
//					c1 = oQStr.mid(0, 1)
//					c2 = oQStr.mid(oQStr.size()-1, 1)
//		
//					if c1 = '"' or
//				  		c2 = '"'
//						cChar = "'"
//					ok
//		
//					n1 = oQStr.indexof('"', 1, 0) + 1
//					n2 = oQStr.indexof("'", 1, 0) + 1
//		
//					if n1 = 0 and n2 = 0
//						cChar = '"'
//		
//					but n1 = 0
//						cChar = '"'
//		
//					but n2 = 0
//						cChar = "'"
//		
//					but n1 < n2
//						cChar = "'"
//					else
//						cChar = '"'
//					ok
//		
//					cResult += (cSep2 + cChar + aContent[i] + cChar + "," + cSep1)
//		
//				ok
//
//			but isList(aContent[i])
//				cResult += ( cSep2 + ComputableForm(aContent[i]) + "," + cSep1)
//
//			but isObject(aContent[i])
//				cResult += ( cSep2 + ObjectVarName(aContent[i]) + "," + cSep1 )
//
//			ok
//
//		next
//
//		oQStr = new QString2()
//		oQStr.append(cResult)
//		oQStr.replace( (oQStr.size() - 2), 2, "" )
//		oQStr.append(cSep1 + "]")
//
//		cResult = oQStr.mid(0, oQStr.size())
//		return cResult
//
//	but isObject(pValue)
//
//		cResult = ObjectVarName(pValue)
//		return cResult
//
//	else
//		StzRaise("Can't proceed! The @@() function is enabled to recognize the format of the data provided.")
//	ok

	#< @FunctionAlternativeForms

	func @@XT(pValue, cSep1, cSep2)
		return ComputableFormXT(pValue, cSep1, cSep2)

	func CFXT(pValue, cSep1, cSep2)
		return ComputableFormXT(pValue, cSep1, cSep2)

	func @ComputableFormXT(pValue, cSep1, cSep2)
		return ComputableFormXT(pValue, cSep1, cSep2)

	#>
