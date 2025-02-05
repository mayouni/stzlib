# File: stzregexuter.ring
# Description: Enhanced Regex Computer System for Softanza Library

func rxuter
    return new stzRegexuter

    func rxu
	return new stzRegexuter

func Match(cInput, cPattern)
	rx(cPattern) { Match(cInput) return AllMatches() }

class stzRegexuter
    # Private attributes  
    aPatterns = []      # Pairs of [name, pattern]
    aComputations = []  # Pairs of [name, computation]
    
    def init()
        # Empty init - patterns and computations added dynamically

    def RegisterPattern(aPattern)
        if NOT ( isList(aPattern) and len(aPattern) = 2 and
           isString(aPattern[1]) and isString(aPattern[2]) )
            StzRaise("Incorrect param! aPattern must be a pair of strings.")
        ok

        # Store pattern with its name
        aPatterns + aPattern

    def AddTrigger(aPattern)
        This.RegisterPattern(aPattern)

    def TriggerPattern(aPattern)
        This.RegisterPattern(aPattern)

    def AddComputationalOp(cPatternName, cComputation)
        if isList(cPatternName) and StzListQ(cPatternName).IsWhenNamedParam()
            cPatternName = cPatternName[2]
        ok

        if isList(cComputation) and StzListQ(cComputation).IsDoNamedParam()
            cComputation = cComputation[2]
        ok

        # Validate computation contains @value
        oStzStr = new stzString(cComputation)
        if NOT oStzStr.ContainsCS("@value", :CaseSensitive = FALSE)
            StzRaise("Invalid computation! Must contain @value keyword.")
        ok

        # Clean computation string
        cComputation = oStzStr.TrimQ().TheseBoundsRemoved("{", "}")

        aComputations + [cPatternName, cComputation]

    def AddComputation(cPattern, cComputation)
        This.AddComputationalOp(cPattern, cComputation)


    def ProcessText(aPatternNameAndText)
        # More natural name than ComputeMatch
        if NOT ( isList(aPatternNameAndText) and len(aPatternNameAndText) = 2 and
            isString(aPatternNameAndText[1]) and isString(aPatternNameAndText[2]) )
            StzRaise("Invalid input! Expected [pattern_name, text_to_analyze]")
        ok

        cPatternName = aPatternNameAndText[1]
        cTextToAnalyze = aPatternNameAndText[2]

        if trim(cPatternName) = "" or trim(cTextToAnalyze) = ""
            return [ :matches = [], :computations = [] ]
        ok
        
        aResult = [
            :matches = [],
            :computations = [],
            :stateChanges = []
        ]

        # Get the pattern registered for this name
        cPattern = aPatterns[cPatternName]
  
        # Find ALL matches in the provided text
        aMatches = Match(cTextToAnalyze, cPattern)
        aResult[:matches] = aMatches
        
        # Apply computation to each match found
        for match in aMatches
            computation = executeComputation(match, cPatternName)
            aResult[:computations] + computation
        next
        
        return aResult

    def Process(aPatternNameAndText)
        return This.ProcessText(aPatternNameAndText)

    private

    def executeComputation(cMatchedValue, cPatternName)
        if NOT (isString(cMatchedValue) and isString(cPatternName))
            StzRaise("Invalid types! Expected string values.")
        ok

        cPattern = aPatterns[cPatternName]
        cComputation = aComputations[cPatternName]

        if trim(cPattern) = "" or trim(cComputation) = ""
            StzRaise("Empty pattern or computation!")
        ok

        result = [ :value = cMatchedValue, :modifiesState = FALSE ]
        
        try
            @value = cMatchedValue
            eval(cComputation)
            result[:value] = @value
            result[:modifiesState] = TRUE
        catch
            result[:error] = "Computation failed (" + cCatchError + ")"
        done
        
        return result
