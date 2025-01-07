
func StzRegExpQ(pcPattern)
	return new stzRegExp(pcPattern)

# File: stzRegExp.ring
# Description: Regular Expression Pattern Builder for Ring

load "stdlibcore.ring"

class stzRegExpMaker

    aSteps = []
    aPatternRules = []
    
    def init()
        aSteps = []
        aPatternRules = []
    
    def addRange(cType, cRange, cQuant, nTimes1, nTimes2)

	cPattern = "[" + cRange + "]"      
        cQuantifier = ""

        switch cQuant
            case :exactly
                cQuantifier = "{" + nTimes1 + "}"

            case :atLeast
                cQuantifier = "{" + nTimes1 + ",}"

            case :atMost
                cQuantifier = "{0," + nTimes1 + "}"

            case :between
                cQuantifier = "{" + nTimes1 + "," + nTimes2 + "}"

            case :several
                cQuantifier = "*"

        off
        
        add(aSteps, cPattern + cQuantifier)
        add(aPatternRules, cType)
        add(aPatternRules, cRange)
        add(aPatternRules, cQuant)
        add(aPatternRules, nTimes1)
	add(aPatternRules, nTimes2)
  
    
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
    
    func textGraph()
        cResult = ""

        for i = 1 to len(aPatternRules) step 5
            cType = aPatternRules[i]
            cRange = aPatternRules[i+1]
            cQuant = aPatternRules[i+2]
            nTimes1 = aPatternRules[i+3]
	    nTimes2 = aPatternRules[i+4]

            # Top border

            cResult += "     +-------------+" + nl
            
            # Content
            if cType = :chars
                cResult += "     |    [" + cRange + "]    |" + nl
            else
                cResult += "     |    [" + cRange + "]    |" + nl
            ok
            
            # Bottom border
	    
            cResult += "     +-------------+" + nl
            
            # Quantifier description
            switch cQuant
                case :exactly
                    cResult += "  exactly " + nTimes1 + " times" + nl
                case :atLeast
                    cResult += "  at least " + nTimes1 + " times" + nl
                case :atMost
                    cResult += "  at most " + nTimes1 + " times" + nl
                case :between
                    cResult += "  between " + nTimes1 + " and " + nTimes2 + " times" + nl
                case :several
                    cResult += "  zero or more times (*)" + nl
            off
            
            # Connector (if not last step)

            if i < len(aPatternRules) - 3
                cResult += "          |" + nl
                cResult += "          v" + nl
            ok


        next
        
	# Bottom info: the regexp pattern

	cResult += "    " + This.getPattern()

        
        return cResult




/*
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
