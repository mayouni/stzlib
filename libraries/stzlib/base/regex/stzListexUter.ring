# Example implementation of stzListexuter

func StzLxuter()
    return new stzListexuter

    func lxuter()
        return StzLxuter()

    func StzLxu()
        return StzLxuter()

    func lxu()
        return StzLxuter()

class stzListexuter from stzObject

    # Core data structures
    aTriggers = []      # Pairs of [cTriggerName, cListPattern]
    aCodesPerTrigger = [] # Pairs of [cTriggerName, cCodeToExecute]
    
    # State management
    aState = []         # List of state entries as hashlists
    aActiveComputations = [] # Track active computations
    
    # Results tracking
    aLastTriggers = []
    aLastMatches = []
    aLastResults = []

	# Performance tracking attributes to add
	nProcessStartTime = 0
	nLastProcessDuration = 0

    def init()
        # Do nothing
        
    #------------------#
    # Trigger Methods  #
    #------------------#
    
    def AddTrigger(aTrigger)
        if isString(aTrigger)
            # Handle string case - convert to pattern
            if TriggerNameExists(aTrigger)
                StzRaise("Trigger name already exists: " + aTrigger)
            ok
            aTriggers + [ aTrigger, lpat(aTrigger) ]
            return
        ok
        
        if NOT (isList(aTrigger) and len(aTrigger) = 2 and 
                isString(aTrigger[1]) and isString(aTrigger[2]))
            StzRaise("Incorrect parameter format! Expected [name, pattern]")
        ok
        
        if TriggerNameExists(aTrigger[1])
            StzRaise("Trigger name already exists: " + aTrigger[1])
        ok
        
        aTriggers + aTrigger
        
    def TriggerNameExists(cName)
        _nTriggers2Len_ = len(aTriggers)
        for _iLoopTriggers2_ = 1 to _nTriggers2Len_
        	trigger = aTriggers[_iLoopTriggers2_]
            if trigger[1] = cName
                return TRUE
            ok
        next
        return FALSE
        
    #---------------#
    # Code Methods  #
    #---------------#
    
    def AddCode(cTriggerName, cCode)
        if NOT TriggerNameExists(cTriggerName)
            StzRaise("Trigger does not exist: " + cTriggerName)
        ok
        
        if NOT isString(cCode)
            StzRaise("Invalid code type! Expected string.")
        ok
        
        # Verify code contains @value or @list reference
        if NOT (StringContains(cCode, "@value") or StringContains(cCode, "@list"))
            StzRaise("Code must contain @value or @list reference.")
        ok
        
        # Clean code
        cCode = trim(cCode)
        if StzLeft(cCode, 1) = "{" and StzRight(cCode, 1) = "}"
            cCode = StzMid(cCode, 2, len(cCode)-2)
        ok
        
        aCodesPerTrigger + [cTriggerName, cCode]
        
    #------------------#
    # Process Methods  #
    #------------------#
    
    def Process(aList)
        if NOT isList(aList)
            StzRaise("Invalid input! Expected list to analyze.")
        ok
        
        if len(aList) = 0
            ResetState()
            return
        ok
        
        # Reset tracking for this process run
        aLastMatches = []
        aLastResults = []
        aLastTriggers = []
        aActiveComputations = []
        
        _nTriggers1Len_ = len(aTriggers)
        for _iLoopTriggers1_ = 1 to _nTriggers1Len_
        	trigger = aTriggers[_iLoopTriggers1_]
            cTriggerName = trigger[1]
            cPattern = trigger[2]
            
            # Create listex pattern matcher
            oListex = new stzListex(cPattern)
            
            # Find all sublists that match the pattern
            aMatches = FindAllMatches(aList, oListex)
            
            if len(aMatches) > 0
                aActiveComputations + cTriggerName
                
                _nMatchesLen_ = len(aMatches)
                for i = 1 to _nMatchesLen_
                    match = aMatches[i]
                    
                    aLastMatches + match
                    aLastTriggers + cTriggerName
                    
                    # Execute computation and track result
                    computedValue = executeComputation(match, cTriggerName)
                    aLastResults + computedValue
                    
                    # Record state change
                    if NOT ListEquals(computedValue, match)
                        AddStateEntry(cTriggerName, cPattern, match, computedValue)
                    ok
                next
                
                del(aActiveComputations, len(aActiveComputations))
            ok
        next
        
    #------------------#
    # Helper Methods   #
    #------------------#
    
    def FindAllMatches(aList, oListex)
        # Find all sublists that match the pattern
        aResult = []
        
        # Check if the whole list matches
        if oListex.Match(aList)
            aResult + aList
        ok
        
        # Check parts of the list recursively
        if len(aList) > 0
            _nListLen_3 = len(aList)
            for i = 1 to _nListLen_3
                if isList(aList[i])
                    # Recursively check nested list
                    aSubMatches = FindAllMatches(aList[i], oListex)
                    _nSubMatches1Len_ = len(aSubMatches)
                    for _iLoopSubMatches1_ = 1 to _nSubMatches1Len_
                    	match = aSubMatches[_iLoopSubMatches1_]
                        aResult + match
                    next
                ok
            next
            
            # Check for matching sublists at this level
            _nListLen_2 = len(aList)
            for i = 1 to _nListLen_2
                _nListLen_ = len(aList)
                for j = i to _nListLen_
                    aSubList = []
                    for _k = i to j
                        aSubList + aList[_k]
                    next
                    if oListex.Match(aSubList) and len(aSubList) > 0
                        aResult + aSubList
                    ok
                next
            next
        ok
        
        return aResult
        
    #-----------------#
    # State Methods   #
    #-----------------#
    
    def ResetState()
        aState = []
        aActiveComputations = []
        
    def AddStateEntry(cTriggerName, cPattern, aMatchedValue, aComputedValue)
        # Create state entry
        entry = [
            :timeStamp = date() + " " + time(),
            :computationOrder = len(aState) + 1,
            
            :triggerName = cTriggerName,
            :pattern = cPattern,
            :matchedValue = aMatchedValue,
            :computedValue = aComputedValue,
            
            :dependsOn = aActiveComputations,
            :affects = getAffectedTriggers(cTriggerName)
        ]
        
        aState + entry
        

	#-------------------------#
	#  MISC. REORGANIZE THEM  #
	#-------------------------#
	
	# Alternative method names
	def Trigger(aTrigger)
	    This.AddTrigger(aTrigger)
	
	def AddComputation(cTriggerName, cCode)
	    This.AddCode(cTriggerName, cCode)
	
	def @C(cTriggerName, cCode)
	    This.AddCode(cTriggerName, cCode)
	
	def Compute(aList)
	    This.Process(aList)
	
	# Result access methods
	def State()
	    return aState
	
	def Triggers()
	    return aLastTriggers
	
	def Matches() 
	    return aLastMatches
	
	def Results()
	    return aLastResults
	
	def ResultsXT()
	    return Association([ This.Results(), This.Matches() ])
	
	    def ResultXT()
	        return This.ResultsXT()
	
	    def ResultsAndMatches()
	        return This.ResultsXT()
	
	    def ResultsAndTheirMatches()
	        return This.ResultsXT()
	
	def MatchesXT()
	    return Association([ This.Matches(), This.Results() ])
	
	    def MatchedValuesXT()
	        return This.MatchesXT()
	
	    def MatchesAndResults()
	        return This.MatchesXT()
	
	    def MatchesAndTheirResults()
	        return This.MatchesXT()
	
	# Dependency chain method
	def getAffectedTriggers(cTriggerName)
	    aAffected = []
	    
	    # Look through state history for triggers affected by this one
	    _nState2Len_ = len(aState)
	    for _iLoopState2_ = 1 to _nState2Len_
	    	entry = aState[_iLoopState2_]
	        if find(entry[:dependsOn], cTriggerName) > 0
	            aAffected + entry[:triggerName] 
	        ok
	    next
	
	    return unique(aAffected)
	
	def GetDependencyChain(cTriggerName)
	    aChain = []
	    
	    _nState1Len_ = len(aState)
	    for _iLoopState1_ = 1 to _nState1Len_
	    	entry = aState[_iLoopState1_]
	        if entry[:triggerName] = cTriggerName
	            aChain + entry[:dependsOn]
	            
	            _aEntrydependsOn1_ = entry[:dependsOn]
	            _nEntrydependsOn1Len_ = len(_aEntrydependsOn1_)
	            for _iLoopEntrydependsOn1_ = 1 to _nEntrydependsOn1Len_
	            	depTrigger = _aEntrydependsOn1_[_iLoopEntrydependsOn1_]
	                aChain + This.GetDependencyChain(depTrigger)
	            next
	        ok
	    next
	
	    return unique(aChain)
	
	# Additional state management methods
	def StateByPosition()
	    # Return state entries sorted by position
	    #TODO
	    return []
	
	def StateByComputationOrder() 
	    # Return state entries sorted by computation order
	    # TODO
	    return []

    #------------------#
    # Private Methods  #
    #------------------#
    
    private
    
    def executeComputation(aMatchedValue, cTriggerName)
        # Find computation code for this trigger
        cCode = ""
        _nCodesPerTrigger1Len_ = len(aCodesPerTrigger)
        for _iLoopCodesPerTrigger1_ = 1 to _nCodesPerTrigger1Len_
        	pair = aCodesPerTrigger[_iLoopCodesPerTrigger1_]
            if pair[1] = cTriggerName
                cCode = pair[2]
                exit
            ok
        next
        
        if trim(cCode) = ""
            return aMatchedValue
        ok
        
        try
            @list = aMatchedValue
            @value = aMatchedValue  # For compatibility 
            eval(cCode)
            
            # Return either @list or @value based on which was modified
            if @list != aMatchedValue
                return @list
            else
                return @value
            ok
        catch
            return aMatchedValue
        done
