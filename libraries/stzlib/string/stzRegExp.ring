
class stzRegExpMaker
    aSteps = []
    aSequences = []
    
    def init()
        aSteps = []
        aSequences = []
    
    def addRange(cType, cRange, cQuant, nTimes1, nTimes2)
        cPattern = ""
        
        if cType = :among and type(cRange) = "LIST"
            cPattern = "[" + join(cRange + "") + "]"
        but cType = :among
            cPattern = "[" + substr(cRange, "SPACE", " ") + "]"
        else
            cPattern = "[" + cRange + "]"
        ok

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
        
        add(aSteps, cPattern + cQuantifier)
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
            
            cBase = ""
            switch oSeq[1]
                case :chars
                    cBase = "a char from " + left(oSeq[2], 1) + " to " + right(oSeq[2], 1)
                case :digits
                    cBase = "a digit from " + left(oSeq[2], 1) + " to " + right(oSeq[2], 1)
                case :among
                    if type(oSeq[2]) = "LIST"
                        cBase = "a char among [ '" + join(oSeq[2] + "', '") + "' ]"
                    else
                        cBase = "a char among [ '" + substr(oSeq[2], "SPACE", " ") + "' ]"
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
            
            cResult += "├─▶ " + cPattern + cSpaces + ": Can contain " + cBase + "," + nl
            cResult += "│   " + copy(" ", nMaxLen+2) + cRepeat + "." + nl + "│" + nl
        next
        
        cResult += "END"
        return cResult

    
  
 
    
    func addAmongChars(cChars, cQuant, nTimes1, nTimes2)
        if type(cChars) = "LIST"
            return addRange(:among, ["-", " "], cQuant, nTimes1, nTimes2)
        ok
        return addRange(:among, cChars, cQuant, nTimes1, nTimes2)
    
    func addCharsRange(cRange, cQuant, nTimes1, nTimes2)
        return addRange(:chars, cRange, cQuant, nTimes1, nTimes2)
    
    func addDigitsRange(cRange, cQuant, nTimes1, nTimes2)
        return addRange(:digits, cRange, cQuant, nTimes1, nTimes2)
    
    def getPattern()
        cResult = ""
        for cStep in aSteps
            cResult += cStep
        next
        return cResult
    

class stzRegExp
	
	@oQRegExp
	@cPattern

	@cTempStr

	def init(pcPattern)
		if CheckParams()
			if NOT isString(pcPattern)
				StzRaise("Incorrect param type! pcPattern must be a string.")
			ok
		ok

		@oQRegExp = new QRegularExpression()
		@oQRegExp.setPattern(pcPattern)
		@cPattern = pcPattern

	def Content()
		return @cPattern

	def Pattern()
		return @cPattern

	def Copy()
		return new stzRegExp(This.Pattern())

	def QRegExpObject()
		return @oQRegExp

	def IsValid()
		return This.QRegExpObject().isValid()

	def Match(pcStr)
		if CheckParams()
			if NOT isString(pcStr)
				StzRaise("Incorrect param type! pcStr must be a string.")
			ok
		ok

		_bResult_ = QRegExpObject().match(pcStr, 0, 0, 0).hasmatch()
		@cTempStr = pcStr

		return _bResult_

	def CapturedValues()
		_acResult_ = []
		
		@i = 0
		while true
			@i++
			_cCapture_ = @oQRegExp.match(@cTempStr, 0, 0, 0).captured(@i)
			if _cCapture_ = ""
				exit
			ok

			_acResult_ + _cCapture_
		end

		return _acResult_

		def Capture()
			return This.CapturedValues()

		def Captured()
			return This.CapturedValues()
