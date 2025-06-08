# Configuration class used by stzNumber objects
class stzNumberFormatConfig
    # All configuration properties
    bRestrictFractionalPart = _FALSE_
    nFractionalDigits = 2
    bApplyRound = _FALSE_
    nRoundTo = 0
    bApplyAlignment = _FALSE_
    nWidth = 0
    cFillBlanksWith = " "
    cAlignTo = :Left
    bShowSign = _FALSE_
    bPutNegativeBetweenParentheses = _FALSE_
    cPrefix = ""
    cThousandsSeparator = ","
    cFractionalSeparator = "."
    cSuffix = ""
    bUseCompactForm = _FALSE_
    nCompactPrecision = 1
    bForceK = _FALSE_
    bForceM = _FALSE_
    bForceB = _FALSE_
    bForceT = _FALSE_
    
	def init()
		# does nothing

    def SetDefaults()
        # Already set above
        
    def SetValue(cKey, uValue)
        switch cKey
            on :RestrictFractionalPart
                bRestrictFractionalPart = uValue
            on :NumberOfDigitsInFractionalPart
                nFractionalDigits = uValue
            on :ApplyRound
                bApplyRound = uValue
            on :RoundTo
                nRoundTo = uValue
            on :ApplyAlignment
                bApplyAlignment = uValue
            on :Width
                nWidth = uValue
            on :FillBlanksWith
                cFillBlanksWith = uValue
            on :AlignTo
                cAlignTo = uValue
            on :ShowSign
                bShowSign = uValue
            on :PutNegativeBetweenParentheses
                bPutNegativeBetweenParentheses = uValue
            on :Prefix
                cPrefix = uValue
            on :ThousandsSeparator
                cThousandsSeparator = uValue
            on :FractionalSeparator
                cFractionalSeparator = uValue
            on :Suffix
                cSuffix = uValue
            on :UseCompactForm
                bUseCompactForm = uValue
            on :CompactPrecision
                nCompactPrecision = uValue
            on :ForceK
                bForceK = uValue
            on :ForceM
                bForceM = uValue
            on :ForceB
                bForceB = uValue
            on :ForceT
                bForceT = uValue
        off
        
    def Validate()
        # Add validation logic here
        if nWidth < 0
            nWidth = 0
        ok
