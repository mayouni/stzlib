
class stzRegExpMaker
	aSteps = []
	aSequences = []
    
	def init()
        	aSteps = []
        	aSequences = []
    
	def AddRange(cType, cRange, cQuant, nTimes1, nTimes2)

		# Checking params

		if isString(nTimes2) and (nTimes2 = :Time or nTimes2 = :Times)
			nTimes = 0

		# case of named param like :And = [3, :Times]

		but isList(nTimes2) and stzListQ(nTimes2).IsAndNamedParam()
			if isNumber(nTimes2[2])
				nTimes2 = nTimes2[2]

			but isList(nTimes2[2])

				if isNumber(nTimes2[2][1]) and
				   isString(nTimes2[2][2]) and
				   (nTimes2[2][2] = :Time or nTimes2[2][2] = :Times)

					nTimes2 = nTimes2[2][1]
				else
					StzRaise("Incorrect param type!")
				ok
			ok
		ok

		# Constrcuting the main pattern string

		cPattern = ""
        
		if cType = :among and type(cRange) = "LIST"
			cPattern = "[" + join(cRange) + "]"

		but cType = :among
			cPattern = "[" + substr(cRange, "SPACE", " ") + "]"
		else
			cPattern = "[" + cRange + "]"
		ok

		# Constructing the quantifier part of the pattern

        	cQuantifier = ""

		if cQuant = :repeatedExactly
			cQuantifier = "{" + nTimes1 + "}"

		but cQuant = :repeatedAtLeast
			cQuantifier = "{" + nTimes1 + ",}"

		but cQuant = :repeatedAtMost
			cQuantifier = "?"

		but cQuant = :repeatedBetween
			cQuantifier = "{" + nTimes1 + "," + nTimes2 + "}"

		but cQuant =  :repeatedSeveral
			cQuantifier = "*"
		ok

		# Storing the complete pattern (main string + quantifier part)

        	add(aSteps, cPattern + cQuantifier)

		# String the elements of the sequence applied

        	add(aSequences, [cType, cRange, cQuant, nTimes1, nTimes2])
        

def parsePattern(cPattern)
    init()
    
    nPos = 1
    while nPos <= len(cPattern)
        if substr(cPattern, nPos, 1) = "["
            # Find closing bracket
            nStart = nPos + 1
            for i = nStart to len(cPattern)
                if substr(cPattern, i, 1) = "]"
                    nEndPos = i
                    exit
                ok
            next
            
            cClass = substr(cPattern, nStart, nEndPos - nStart)
            nPos = nEndPos + 1
            
            # Parse quantifier
            cQuant = ""
            nTimes1 = 0
            nTimes2 = 0
            
            if nPos <= len(cPattern)
                if substr(cPattern, nPos, 1) = "?"
                    cQuant = :repeatedAtMost
                    nTimes1 = 1
                    nPos++
                but substr(cPattern, nPos, 1) = "{"
                    nStart = nPos + 1
                    for i = nStart to len(cPattern)
                        if substr(cPattern, i, 1) = "}"
                            nEndQuant = i
                            exit
                        ok
                    next
                    
                    cQuantStr = substr(cPattern, nStart, nEndQuant - nStart)
                    if substr(cQuantStr, ",") > 0
                        aQuantParts = split(cQuantStr, ",")
                        if len(aQuantParts) = 2
                            cQuant = :repeatedBetween
                            nTimes1 = 0 + aQuantParts[1]
                            nTimes2 = 0 + aQuantParts[2]
                        else
                            cQuant = :repeatedAtLeast
                            nTimes1 = 0 + aQuantParts[1]
                        ok
                    else
                        cQuant = :repeatedExactly
                        nTimes1 = 0 + cQuantStr
                    ok
                    nPos = nEndQuant + 1
                ok
            ok
            
            # Determine type and range
            if cClass = "A-Z"
                addCharsRange(cClass, cQuant, nTimes1, nTimes2)
            but cClass = "0-9"
                addDigitsRange(cClass, cQuant, nTimes1, nTimes2)
            but cClass = "- "
                addAmongChars(["-", " "], cQuant, nTimes1, nTimes2)
            ok
        else
            nPos++
        ok
    end
    
    return self

func getNarration()
    nMaxLen = 0
    for cPattern in aSteps
        if len(cPattern) > nMaxLen
            nMaxLen = len(cPattern)
        ok
    next
    nMaxLen++ # Add 1 for spacing
    
    cResult = "START" + nl + "│" + nl
    
    for i = 1 to len(aSequences)
        oSeq = aSequences[i]
        cPattern = aSteps[i]
        cSpaces = copy(" ", nMaxLen - len(cPattern))
        
        # Calculate sequence number (0-9 repeating)
        nSeqNum = i % 10
        
        cBase = ""
        switch oSeq[1]
            case :chars
                cBase = "a char from " + left(oSeq[2], 1) + " to " + right(oSeq[2], 1)
            case :digits
                cBase = "a digit from " + left(oSeq[2], 1) + " to " + right(oSeq[2], 1)
            case :among
                if type(oSeq[2]) = "LIST"
                    # Now correctly showing the hyphen and space as separate characters
                    aChars = []
                    for char in oSeq[2]
                        add(aChars, char)
                    next
                    cBase = "a char among [ '" +
				join(aChars + "', '") + "' ]"
                else
                    # Handle the case where it's a string with "SPACE"
                    cChars = substr(oSeq[2], "SPACE", " ")
                    aChars = []
                    for i = 1 to len(cChars)
                        add(aChars, substr(cChars, i, 1))
                    next
                    cBase = "a char among [ '" +
			join(aChars + "', '") + "' ]"
                ok
        off
        
        cRepeat = ""
        switch oSeq[3]
            case :repeatedExactly
                cRepeat = "repeated exactly " + oSeq[4] + " times"
            case :repeatedAtLeast
                cRepeat = "repeated at least " + oSeq[4] + " times"
            case :repeatedAtMost
                cRepeat = "repeated at most " + oSeq[4] + " time"
            case :repeatedBetween
                cRepeat = "repeated between " + oSeq[4] + " and " + oSeq[5] + " times"
            case :repeatedSeveral
                cRepeat = "repeated zero or more times"
        off
        
        cResult += ''+ nSeqNum + "─▶ " + cPattern + cSpaces + ": Can contain " + cBase + "," + nl
        cResult += "│   " + copy(" ", nMaxLen+2) + cRepeat + "." + nl + "│" + nl
    next
    
    cResult += "END"
    return cResult
    
    cResult += "END"
    return cResult
  
    def addAmongChars(cChars, cQuant, nTimes1, nTimes2)
        if type(cChars) = "LIST"
            return addRange(:among, ["-", " "], cQuant, nTimes1, nTimes2)
        ok
        return addRange(:among, cChars, cQuant, nTimes1, nTimes2)
    
    def addCharsRange(cRange, cQuant, nTimes1, nTimes2)
        return addRange(:chars, cRange, cQuant, nTimes1, nTimes2)
    
    def addDigitsRange(cRange, cQuant, nTimes1, nTimes2)
        return addRange(:digits, cRange, cQuant, nTimes1, nTimes2)
    
    def getPattern()
        cResult = ""
        for cStep in aSteps
            cResult += cStep
        next
        return cResult
    
