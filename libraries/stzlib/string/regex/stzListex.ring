# Softanza List Regex Engine
# Version 1.0.0

func StzListRegexQ(cPattern)
	return new stzListRegex(cPattern)

	func StzListexQ(cPattern)
		return StzListRegexQ(cPattern)

	func Lx(cPattern)
		return StzListRegexQ(cPattern)

class stzListex from stzListRegex
class stzListRegex

	@cDomainPattern    # The original DSL pattern
	@aTokens           # List of token definitions

	# The number @N pattern

	@cNumberPattern = '(?:-?\d+(?:\.\d+)?)'

	# The string @S pattern

	@cStringPattern = "(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "|\'[^\']*\')"

	# The list @L pattern

	@cSimpleListPattern = '\[\s*[^\[\]]*\s*\]'
	@cRecursiveListPattern = '\[\s*(?:[^\[\]]|\[(?:[^\[\]]|(?R))*\])*\s*\]'
	@cListPattern = @cSimpleListPattern  # Default to simple pattern

	# The @$ wildcard pattern

	@cAnyPattern = @cNumberPattern + "|" + @cStringPattern + "|" + @cListPattern

	# Patterns for unique sets (double brackets)

	@cUniqueSetNumberPattern = '\{\{\s*-?\d+(?:\.\d+)?(?:\s*,\s*-?\d+(?:\.\d+)?)*\s*\}\}'
	@cUniqueSetStringPattern = '\{\{\s*(?:' + char(34) + '[^' + char(34) + ']*' + char(34) +
		"|\'[^\']*\')(?:\s*,\s*(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "|\'[^\']*\'))*\s*\}\}"

	@cUniqueSetListPattern = '\{\{\s*' + @cSimpleListPattern + '(?:\s*,\s*' + @cSimpleListPattern + ')*\s*\}\}'

	def init(cPattern)

		if NOT isString(cPattern)
			raise("Error: Pattern must be a string")
        	ok

		@cDomainPattern = @Trim(cPattern)

		if NOT (StartsWith(@cDomainPattern, "[") and EndsWith(@cDomainPattern, "]"))
			@cDomainPattern = "[" + @cDomainPattern + "]"
		ok

		@aTokens = This.ParsePattern(@cDomainPattern)

		# Dealing the specific cases like [ @N1-2, @N0-3 ] ~> [ @N0-5 ]

		nLen = len(@aTokens)

		if nLen > 1
			for i = nLen to 2 step -1

				if @aTokens[i][:keyword] = @aTokens[i-1][:keyword] and
				   @aTokens[i][:min] != @aTokens[i][:max] = 1 and
				   @aTokens[i-1][:min] != @aTokens[i-1][:max]

					nMin = @Min([ @aTokens[i][:min], @aTokens[i-1][:min] ])
					nMax = @aTokens[i][:max] + @aTokens[i-1][:max]

					del(@aTokens, nLen)
					@aTokens[i-1][:min] = nMin
					@aTokens[i-1][:max] = nMax

				ok
			next
		ok

	  #----------------------------#
	 #  PARSING THE LIST PATTERN  #
	#----------------------------#

	def ParsePattern(cPattern)

		# Remove outer brackets and trim

		oPattern = new stzString(cPattern)
		oPattern.TrimQ().RemoveFirstAndLastCharsQ().Trim()
		acChars = oPattern.chars()

		cInner = oPattern.Content()
        
		# Tokenization with error handling

		aTokens = []
		nStart = 1
		nLen = len(acChars)
		nDepth = 0
		cCurrentToken = ""

		for i = 1 to nLen
			cChar = acChars[i]
            
			switch cChar
			case "["
				nDepth++
				cCurrentToken += cChar
   
			case "]"
				nDepth--
				cCurrentToken += cChar
				if nDepth < 0
					raise("Error: Unmatched brackets in pattern")
				ok
                    
			case ","
				if nDepth = 0
					if len(cCurrentToken) > 0
						aTokens + This.ParseToken(@Trim(cCurrentToken))
						cCurrentToken = ""
					ok
				else
					cCurrentToken += cChar
				ok
                    
			other
				cCurrentToken += cChar
			off
		next
        
		# Add final token

		if len(cCurrentToken) > 0
			aTokens + This.ParseToken(@Trim(cCurrentToken))
		ok

		if nDepth != 0
			raise("Error: Unmatched brackets in pattern")
		ok
   
		return aTokens

	  #---------------------------------------#
	 #  PARSING A TOKEN IN THE LIST PATTERN  #
	#---------------------------------------#

def ParseToken(cTokenStr)

    aToken = []
    oTokenStr = new stzString(cTokenStr)

    if StartsWith(cTokenStr, "@")
        cKeyword = oTokenStr.Section(1, 2)

        # Set basic token properties based on keyword type
        switch cKeyword
        on "@N"
            aToken + [ "keyword", "@N" ]
            aToken + [ "type", "number" ]
            aToken + [ "pattern", @cNumberPattern ]

        on "@S"
            aToken + [ "keyword", "@S" ]
            aToken + [ "type", "string" ]
            aToken + [ "pattern", @cStringPattern ]

        on "@L"
            aToken + [ "keyword", "@L" ]
            aToken + [ "type", "list" ]
            aToken + [ "pattern", @cListPattern ]

        on "@$"
            aToken + [ "keyword", "@$" ]
            aToken + [ "type", "any" ]
            aToken + [ "pattern", @cAnyPattern ]

        other
            stzraise("Error: Unknown token type: " + cTokenStr)
        off

        # Get everything after the @X
        cRemainder = ""
        nLenToken = oTokenStr.NumberOfChars()

        if nLenToken > 2
            cRemainder = oTokenStr.Section(3, nLenToken)
        ok

        # Initialize default values
        nMin = 1
        nMax = 1
        aSetValues = []
        bRequireUnique = false

        # Process quantifier part first
        if len(cRemainder) > 0
            # Check for '+', '*', '?' quantifiers first
	    rx = rx('^([+*?])')
            if rx.Match(cRemainder)
                aMatches = rx.Matches()
                cQuantifier = aMatches[1]
                
                switch cQuantifier
                on "+"
                    nMin = 1
                    nMax = RingMaxNumber()
                on "*"
                    nMin = 0
                    nMax = RingMaxNumber()
                on "?"
                    nMin = 0
                    nMax = 1
                off
                
                nRemaining = len(cRemainder) - 1
                cRemainder = right(cRemainder, nRemaining)
                
            # Then check for range or single number

            else

                rx = rx('^(\d+)(?:-(\d+))?')
                if rx.Match(cRemainder)

                    aMatches = rx.Matches()

                    if len(aMatches) = 2 and aMatches[2] != ""
                        # Range: n-m
                        nMin = @number(aMatches[1])
                        nMax = @number(aMatches[2])
                        if nMin > nMax
                            stzraise("Error: Invalid range in quantifier: min > max")
                        ok
                        nRemaining = len(cRemainder) - len(aMatches[1]) - len(aMatches[2]) - 1

                    else
                        # Single number: n

                        nMin = @number(aMatches[1])
                        nMax = nMin
                        nRemaining = len(cRemainder) - len(aMatches[1])
                    ok

                    cRemainder = right(cRemainder, nRemaining)

                ok
            ok
        ok

        # Process set part and check for U suffix

        if rx('(\{.*\}U)').Match(cRemainder)

            # Set with U suffix - unique values required

            oSetMatch = rx('(\{(.*?)\})U')
            if oSetMatch.Match(cRemainder)
                aMatches = oSetMatch.Matches()
                cSetContent = aMatches[2]
        
                # Parse values and check uniqueness
                aTemp = @split(cSetContent, ";")

                aSetValues = []
                
                for i = 1 to len(aTemp)
                    cValue = @trim(aTemp[i])
                    
                    if aToken["type"] = "number"
                        if rx("^(-?\d+(?:\.\d+)?)$").Match(cValue)
                            nValue = @number(cValue)
                            if ring_find(aSetValues, nValue) > 0
                                stzraise("Error: Duplicate value in unique set: " + @@(cValue))
                            ok
                            aSetValues + nValue
                        else
                            stzraise("Error: Invalid number in set: " + cValue)
                        ok

                    else 
                        if aToken["type"] = "list"

                            # Keep brackets for list values
                            if ring_find(aSetValues, cValue) > 0
                                stzraise("Error: Duplicate value in unique set: " + cValue)
                            ok
                            aSetValues + @Listify(cValue)
                        else
                            # For strings, remove quotes
                            cValue = StzStringQ(cValue).FirstAndLastCharsRemoved()
                            if ring_find(aSetValues, cValue) > 0
                                stzraise("Error: Duplicate value in unique set: " + cValue)
                            ok
                            aSetValues + cValue
                        ok
                    ok
                next
                bRequireUnique = true
            ok

        else 

            if rx('(\{.*\})').Match(cRemainder)
                # Regular set without U suffix
                oSetMatch = rx('(\{(.*?)\})')
                if oSetMatch.Match(cRemainder)
                    aMatches = oSetMatch.Matches()
                    cSetContent = aMatches[2]
                    
                    # Parse values without uniqueness check
                    aTemp = @split(cSetContent, ";")
                    aSetValues = []
                    
                    for i = 1 to len(aTemp)
                        cValue = @trim(aTemp[i])
                        
                        if aToken["type"] = "number"
                            if rx("^(-?\d+(?:\.\d+)?)$").Match(cValue)
                                aSetValues + @number(cValue)
                            else
                                stzraise("Error: Invalid number in set: " + cValue)
                            ok
                        else
                            if aToken["type"] = "list"
                                # Keep brackets for list values
                                aSetValues + @Listifiy(cValue)
                            else
                                # For strings, remove quotes
                                cValue = StzStringQ(cValue).FirstAndLastCharsRemoved()
                                aSetValues + cValue
                            ok
                        ok
                    next
                ok
            ok
        ok

        # Add processed information to token
        aToken + [ "min", nMin ]
        aToken + [ "max", nMax ]
        
        if len(aSetValues) > 0
            aToken + [ "hasset", true ]
            aToken + [ "setvalues", aSetValues ]
            aToken + [ "requireunique", bRequireUnique ]
        else
            aToken + [ "hasset", false ]
            aToken + [ "requireunique", false ]
        ok
    ok

    return aToken

def ParseToken2(cTokenStr)
    aToken = []
    oTokenStr = new stzString(cTokenStr)

    if StartsWith(cTokenStr, "@")
        cKeyword = oTokenStr.Section(1, 2)

        # Set basic token properties based on keyword type
        switch cKeyword
        on "@N"
            aToken + [ "keyword", "@N" ]
            aToken + [ "type", "number" ]
            aToken + [ "pattern", @cNumberPattern ]

        on "@S"
            aToken + [ "keyword", "@S" ]
            aToken + [ "type", "string" ]
            aToken + [ "pattern", @cStringPattern ]

        on "@L"
            aToken + [ "keyword", "@L" ]
            aToken + [ "type", "list" ]
            aToken + [ "pattern", @cListPattern ]

        on "@$"
            aToken + [ "keyword", "@$" ]
            aToken + [ "type", "any" ]
            aToken + [ "pattern", @cAnyPattern ]

        other
            stzraise("Error: Unknown token type: " + @@(cTokenStr))
        off

        # Get everything after the @X
        cRemainder = ""
        nLenToken = oTokenStr.NumberOfChars()

        if nLenToken > 2
            cRemainder = oTokenStr.Section(3, nLenToken)
        ok

        # Initialize default values
        nMin = 1
        nMax = 1
        aSetValues = []
        bRequireUnique = false

        # Process quantifier part first
        cQuantifier = ""
        if len(cRemainder) > 0
            rx = rx("^(\d+)")
            if rx.Match(cRemainder)
                aMatches = rx.Matches()
                cQuantifier = aMatches[1]
                nMin = number(cQuantifier)
                nMax = nMin
                nRemaining = len(cRemainder) - len(cQuantifier)
                cRemainder = right(cRemainder, nRemaining)
            ok
        ok

        # Then process set part
        if rx('(\{\{.*\}\})').Match(cRemainder)
            # Double brackets - unique set
            oSetMatch = rx('(\{\{(.*?)\}\})')
            if oSetMatch.Match(cRemainder)
                aMatches = oSetMatch.Matches()
                cSetContent = aMatches[2]
                
                # Parse values and check uniqueness
                aTemp = @split(cSetContent, ";")
                aSetValues = []
                
                for i = 1 to len(aTemp)
                    cValue = @trim(aTemp[i])
                    
                    if aToken["type"] = "number"
                        if rx("^(-?\d+(?:\.\d+)?)$").Match(cValue)
                            nValue = @number(cValue)
                            if ring_find(aSetValues, nValue) > 0
                                stzraise("Error: Duplicate value in unique set: " + @@(cValue))
                            ok
                            aSetValues + nValue
                        else
                            stzraise("Error: Invalid number in set: " + @@(cValue))
                        ok
                    else
                        # For strings, remove quotes
                        cValue = StzStringQ(cValue).FirstAndLastCharsRemoved()
                        if cValue != "" and ring_find(aSetValues, cValue) > 0
                            stzraise("Error: Duplicate value in unique set: " + @@(cValue))
                        ok
                        aSetValues + cValue
                    ok
                next
                bRequireUnique = true
            ok
        else 
            if rx('(\{.*\})').Match(cRemainder)
                # Single brackets - regular set
                oSetMatch = rx('(\{(.*?)\})')
                if oSetMatch.Match(cRemainder)
                    aMatches = oSetMatch.Matches()
                    cSetContent = aMatches[2]
                    
                    # Parse values without uniqueness check
                    aTemp = @split(cSetContent, ";")
                    aSetValues = []
                    
                    for i = 1 to len(aTemp)
                        cValue = @trim(aTemp[i])
                        
                        if aToken["type"] = "number"
                            if rx("^(-?\d+(?:\.\d+)?)$").Match(cValue)
                                aSetValues + @number(cValue)
                            else
                                stzraise("Error: Invalid number in set: " + cValue)
                            ok
                        else
                            # For strings, remove quotes
                            cValue = StzStringQ(cValue).FirstAndLastCharsRemoved()
                            aSetValues + cValue
                        ok
                    next
                ok
            ok
        ok

        # Add processed information to token
        aToken + [ "min", nMin ]
        aToken + [ "max", nMax ]
        
        if len(aSetValues) > 0
            aToken + [ "hasset", true ]
            aToken + [ "setvalues", aSetValues ]
            aToken + [ "requireunique", bRequireUnique ]
        else
            aToken + [ "hasset", false ]
            aToken + [ "requireunique", false ]
        ok
    ok

    return aToken

def MatchTokensToElements(aTokens, aElements)
    nElementIndex = 1
    nLenElem = len(aElements)
    nLenTokens = len(aTokens)
    
    for i = 1 to nLenTokens
        aToken = aTokens[i]
        
        # Track elements matched by current token
        nCount = 0
        nStartIndex = nElementIndex
        aMatchedValues = []
        
        # Handle each token's min-max requirements
        while nElementIndex <= nLenElem and nCount < aToken["max"]
            cElement = aElements[nElementIndex]
            bMatch = false
            bFoundInSet = false
            
            # Check if element matches the token pattern
            if aToken["type"] = "list"
                if rx(@cSimpleListPattern).Match(cElement)
                    bMatch = true
                ok
                
                if bMatch = false
                    bMatch = rx(@cRecursiveListPattern).MatchRecursive(cElement)
                ok
            else
                bMatch = rx("^" + aToken["pattern"] + "$").Match(cElement)
            ok
            
            # If matched, check set constraints
            if bMatch
                if aToken["hasset"]
                    # Convert element to proper type for comparison
                    if aToken["type"] = "number"
                        xValue = @number(cElement)
                    else
                        xValue = cElement
                    ok
                    
                    # Check if value is in allowed set
                    if ring_find(aToken["setvalues"], xValue) > 0
                        bFoundInSet = true
                        
                        # For unique sets, check if we've seen this value before
                        if aToken["requireunique"]
                            if ring_find(aMatchedValues, xValue) > 0
                                return false  # Duplicate value in unique set match
                            ok
                        ok
                        
                        if bFoundInSet
                            aMatchedValues + xValue
                            nCount++
                            nElementIndex++
                        ok
                    else
                        if NOT aToken["requireunique"]
                            # For non-unique sets, keep looking for other matches
                            bFoundInSet = true
                            nCount++
                            nElementIndex++
                        else
                            exit
                        ok
                    ok
                else
                    nCount++
                    nElementIndex++
                ok
            else
                exit
            ok
        end
        
        # Check if we satisfied this token's min requirement
        if nCount < aToken["min"]
            return false
        ok
    next
    
    # Check if we consumed all elements
    return nElementIndex > nLenElem

/*

def ParseToken(cTokenStr)
    aToken = []
    oTokenStr = new stzString(cTokenStr)

    if StartsWith(cTokenStr, "@")
        cKeyword = oTokenStr.Section(1, 2)

        # Set basic token properties based on keyword type
        switch cKeyword
        on "@N"
            aToken + [ "keyword", "@N" ]
            aToken + [ "type", "number" ]
            aToken + [ "pattern", @cNumberPattern ]

        on "@S"
            aToken + [ "keyword", "@S" ]
            aToken + [ "type", "string" ]
            aToken + [ "pattern", @cStringPattern ]

        on "@L"
            aToken + [ "keyword", "@L" ]
            aToken + [ "type", "list" ]
            aToken + [ "pattern", @cListPattern ]

        on "@$"
            aToken + [ "keyword", "@$" ]
            aToken + [ "type", "any" ]
            aToken + [ "pattern", @cAnyPattern ]

        other
            stzraise("Error: Unknown token type: " + cTokenStr)
        off

        # Get everything after the @X
        cRemainder = ""
        nLenToken = oTokenStr.NumberOfChars()

        if nLenToken > 2
            cRemainder = oTokenStr.Section(3, nLenToken)
        ok

        # Initialize default values
        nMin = 1
        nMax = 1
        aSetValues = []
        bRequireUnique = false

        # Process quantifier part first
        cQuantifier = ""
        if len(cRemainder) > 0
	    rx = rx("^(\d+)")
            if rx.Match(cRemainder)
                aMatches = rx.Matches()
                cQuantifier = aMatches[1]
                nMin = number(cQuantifier)
                nMax = nMin
                nRemaining = len(cRemainder) - len(cQuantifier)
                cRemainder = right(cRemainder, nRemaining)
            ok
        ok

        # Then process set part
        if rx('(\{\{.*\}\})').Match(cRemainder)
            # Double brackets - unique set
            oSetMatch = rx('(\{\{(.*?)\}\})')
            if oSetMatch.Match(cRemainder)
                aMatches = oSetMatch.Matches()
                cSetContent = aMatches[2]
                
                # Parse values and check uniqueness
                aTemp = @split(cSetContent, ";")
		
                aSetValues = []
                
                for i = 1 to len(aTemp)
                    cValue = trim(aTemp[i])
                    
                    if aToken["type"] = "number"
                        if rx("^(-?\d+(?:\.\d+)?)$").Match(cValue)
                            nValue = @number(cValue)
                            if ring_find(aSetValues, nValue) > 0
                                stzraise("Error: Duplicate value in unique set: " + @@(cValue))
                            ok
                            aSetValues + nValue
                        else
                            stzraise("Error: Invalid number in set: " + cValue)
                        ok
                    else
                        # For strings, remove quotes
                        cValue = StzStringQ(cValue).firstAndLastCharsRemoved()
                        if ring_find(aSetValues, cValue) > 0
                            stzraise("Error: Duplicate value in unique set: " + cValue)
                        ok
                        aSetValues + cValue
                    ok
                next
                bRequireUnique = true
            ok
        else 
            if rx('(\{.*\})').Match(cRemainder)
                # Single brackets - regular set
                oSetMatch = rx('(\{(.*?)\})')
                if oSetMatch.Match(cRemainder)
                    aMatches = oSetMatch.Matches()
                    cSetContent = aMatches[2]
                    
                    # Parse values without uniqueness check
                    aTemp = @split(cSetContent, ";")
                    aSetValues = []
                    
                    for i = 1 to len(aTemp)
                        cValue = @trim(aTemp[i])
                        
                        if aToken["type"] = "number"
                            if rx("^(-?\d+(?:\.\d+)?)$").Match(cValue)
                                aSetValues + @number(cValue)
                            else
                                stzraise("Error: Invalid number in set: " + cValue)
                            ok
                        else
                            # For strings, remove quotes
                            cValue = StzStringQ(cValue).FirstAndLastCharsRemoved()
                            aSetValues + cValue
                        ok
                    next
                ok
            ok
        ok

        # Add processed information to token
        aToken + [ "min", nMin ]
        aToken + [ "max", nMax ]
        
        if len(aSetValues) > 0
            aToken + [ "hasset", true ]
            aToken + [ "setvalues", aSetValues ]
            aToken + [ "requireunique", bRequireUnique ]
        else
            aToken + [ "hasset", false ]
            aToken + [ "requireunique", false ]
        ok
    ok

    return aToken

def MatchTokensToElements(aTokens, aElements)
    nElementIndex = 1
    nLenElem = len(aElements)
    nLenTokens = len(aTokens)
    
    for i = 1 to nLenTokens
        aToken = aTokens[i]
        
        # Track elements matched by current token
        nCount = 0
        nStartIndex = nElementIndex
        aMatchedValues = []
        
        # Handle each token's min-max requirements
        while nElementIndex <= nLenElem and nCount < aToken["max"]
            cElement = aElements[nElementIndex]
            bMatch = false
            
            # Check if element matches the token pattern
            if aToken["type"] = "list"
                if rx(@cSimpleListPattern).Match(cElement)
                    bMatch = true
                ok
                
                if bMatch = false
                    bMatch = rx(@cRecursiveListPattern).MatchRecursive(cElement)
                ok
            else
                bMatch = rx("^" + aToken["pattern"] + "$").Match(cElement)
            ok
            
            # If matched, check set constraints
            if bMatch
                if aToken["hasset"]
                    # Convert element to proper type for comparison
                    if aToken["type"] = "number"
                        xValue = number(cElement)
                    else
                        xValue = cElement
                    ok
                    
                    # Check if value is in allowed set
                    if ring_find(aToken["setvalues"], xValue) > 0
                        # For unique sets, check if we've seen this value before
                        if aToken["requireunique"]
                            if ring_find(aMatchedValues, xValue) > 0
                                return false  # Duplicate value in unique set match
                            ok
                        ok
                        aMatchedValues + xValue
                        nCount++
                        nElementIndex++
                    else
                        exit
                    ok
                else
                    nCount++
                    nElementIndex++
                ok
            else
                exit
            ok
        end
        
        # Check if we satisfied this token's min requirement
        if nCount < aToken["min"]
            return false
        ok
    next
    
    # Check if we consumed all elements
    return nElementIndex > nLenElem
*/


	  #-------------------------------#
	 #  EXECUTING THE REGEX MATCHES  #
	#-------------------------------#

	def Match(pList)
		if NOT isList(pList)
			return false
		ok

		# Stringifiying the list

		aElements = @Stringify(pList)

		# Trying the macth

		try
			return This.MatchTokensToElements(@aTokens, aElements)
		catch
			raise("Error during list matching!")
		done

		#< @FunctionMisspelledForm

		def Macth(pList)
			return This.Match(pList)

		#>

/*	def MatchTokensToElements(aTokens, aElements)
		nElementIndex = 1
		nLenElem = len(aElements)
		nLenTokens = len(aTokens)
		
		for i = 1 to nLenTokens
			aToken = aTokens[i]
			
			# Track elements matched by current token
	
			nCount = 0
			nStartIndex = nElementIndex
			
			# Handle each token's min-max requirements
	
			while nElementIndex <= nLenElem and nCount < aToken["max"]
				cElement = aElements[nElementIndex]
				bMatch = false
				
				if aToken["type"] = "list"
	
					# Try simple pattern first
	
					if rx(@cSimpleListPattern).Match(cElement)
						bMatch = true
					ok
					
					if bMatch = false
						# If simple fails, try recursive
						bMatch = rx(@cRecursiveListPattern).MatchRecursive(cElement)
					ok
				else
					bMatch = rx("^" + aToken["pattern"] + "$").Match(cElement)
				ok
				
				if bMatch
					nCount++
					nElementIndex++
				else
					# No match, stop trying with this token
					exit
				ok
			end
			
			# Check if we satisfied this token's min requirement
	
			if nCount < aToken["min"]
				return false
			ok
		next
		
		# Check if we consumed all elements
		# if not, the pattern didn't match the whole list
	
		if nElementIndex <= nLenElem
			return false
		ok
		
		return true
*/

	def EscapeLiteral(cLiteral)
		aSpecials = [ "\", ".", "^", "$", "*", "+", "?", "(", ")", "[", "]", "{", "}", "|" ]
		nLenSpecials = len(aSpecials)
		cResult = cLiteral

		for i = 1 to nLenSpecials
			cResult = ring_substr2( cResult, aSpecials[i], ("\" + aSpecials[i]) )
		next

		return cResult

	def Tokens()
		return @aTokens

		def TokensXT()
			return @aTokens

		def MatchInfo()
			return @aTokens

	def Pattern()
		return @cDomainPattern

		def DomainPattern()
			return This.Pattern()
