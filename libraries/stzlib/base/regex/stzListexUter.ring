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
    
    def AddCode(_cTriggerName_, _cCode_)
        if NOT TriggerNameExists(_cTriggerName_)
            StzRaise("Trigger does not exist: " + _cTriggerName_)
        ok
        
        if NOT isString(_cCode_)
            StzRaise("Invalid code type! Expected string.")
        ok
        
        # Verify code contains @value or @list reference
        if NOT (StringContains(_cCode_, "@value") or StringContains(_cCode_, "@list"))
            StzRaise("Code must contain @value or @list reference.")
        ok
        
        # Clean code
        _cCode_ = trim(_cCode_)
        if StzLeft(_cCode_, 1) = "{" and StzRight(_cCode_, 1) = "}"
            _cCode_ = StzMid(_cCode_, 2, len(_cCode_)-2)
        ok
        
        aCodesPerTrigger + [_cTriggerName_, _cCode_]
        
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
            _cTriggerName_ = trigger[1]
            _cPattern_ = trigger[2]
            
            # Create listex pattern matcher
            _oListex_ = new stzListex(_cPattern_)
            
            # Find all sublists that match the pattern
            _aMatches_ = FindAllMatches(aList, _oListex_)
            
            if len(_aMatches_) > 0
                aActiveComputations + _cTriggerName_
                
                _nMatchesLen_ = len(_aMatches_)
                for i = 1 to _nMatchesLen_
                    _match_ = _aMatches_[i]
                    
                    aLastMatches + _match_
                    aLastTriggers + _cTriggerName_
                    
                    # Execute computation and track result
                    _computedValue_ = executeComputation(_match_, _cTriggerName_)
                    aLastResults + _computedValue_
                    
                    # Record state change
                    if NOT ListEquals(_computedValue_, _match_)
                        AddStateEntry(_cTriggerName_, _cPattern_, _match_, _computedValue_)
                    ok
                next
                
                del(aActiveComputations, len(aActiveComputations))
            ok
        next
        
    #------------------#
    # Helper Methods   #
    #------------------#
    
    def FindAllMatches(aList, _oListex_)
        # Find all sublists that match the pattern
        _aResult_ = []
        
        # Check if the whole list matches
        if _oListex_.Match(aList)
            _aResult_ + aList
        ok
        
        # Check parts of the list recursively
        if len(aList) > 0
            _nListLen_3 = len(aList)
            for i = 1 to _nListLen_3
                if isList(aList[i])
                    # Recursively check nested list
                    _aSubMatches_ = FindAllMatches(aList[i], _oListex_)
                    _nSubMatches1Len_ = len(_aSubMatches_)
                    for _iLoopSubMatches1_ = 1 to _nSubMatches1Len_
                    	_match_ = _aSubMatches_[_iLoopSubMatches1_]
                        _aResult_ + _match_
                    next
                ok
            next
            
            # Check for matching sublists at this level
            _nListLen_2 = len(aList)
            for i = 1 to _nListLen_2
                _nListLen_ = len(aList)
                for j = i to _nListLen_
                    _aSubList_ = []
                    for _k = i to j
                        _aSubList_ + aList[_k]
                    next
                    if _oListex_.Match(_aSubList_) and len(_aSubList_) > 0
                        _aResult_ + _aSubList_
                    ok
                next
            next
        ok
        
        return _aResult_
        
    #-----------------#
    # State Methods   #
    #-----------------#
    
    def ResetState()
        aState = []
        aActiveComputations = []
        
    def AddStateEntry(_cTriggerName_, _cPattern_, aMatchedValue, aComputedValue)
        # Create state entry
        _entry_ = [
            :timeStamp = date() + " " + time(),
            :computationOrder = len(aState) + 1,
            
            :triggerName = _cTriggerName_,
            :pattern = _cPattern_,
            :matchedValue = aMatchedValue,
            :computedValue = aComputedValue,
            
            :dependsOn = aActiveComputations,
            :affects = getAffectedTriggers(_cTriggerName_)
        ]
        
        aState + _entry_
        

	#-------------------------#
	#  MISC. REORGANIZE THEM  #
	#-------------------------#
	
	# Alternative method names
	def Trigger(aTrigger)
	    This.AddTrigger(aTrigger)
	
	def AddComputation(_cTriggerName_, _cCode_)
	    This.AddCode(_cTriggerName_, _cCode_)
	
	def @C(_cTriggerName_, _cCode_)
	    This.AddCode(_cTriggerName_, _cCode_)
	
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
	def getAffectedTriggers(_cTriggerName_)
	    _aAffected_ = []
	    
	    # Look through state history for triggers affected by this one
	    _nState2Len_ = len(aState)
	    for _iLoopState2_ = 1 to _nState2Len_
	    	_entry_ = aState[_iLoopState2_]
	        if find(_entry_[:dependsOn], _cTriggerName_) > 0
	            _aAffected_ + _entry_[:triggerName] 
	        ok
	    next
	
	    return unique(_aAffected_)
	
	def GetDependencyChain(_cTriggerName_)
	    _aChain_ = []
	    
	    _nState1Len_ = len(aState)
	    for _iLoopState1_ = 1 to _nState1Len_
	    	_entry_ = aState[_iLoopState1_]
	        if _entry_[:triggerName] = _cTriggerName_
	            _aChain_ + _entry_[:dependsOn]
	            
	            _aEntrydependsOn1_ = _entry_[:dependsOn]
	            _nEntrydependsOn1Len_ = len(_aEntrydependsOn1_)
	            for _iLoopEntrydependsOn1_ = 1 to _nEntrydependsOn1Len_
	            	_depTrigger_ = _aEntrydependsOn1_[_iLoopEntrydependsOn1_]
	                _aChain_ + This.GetDependencyChain(_depTrigger_)
	            next
	        ok
	    next
	
	    return unique(_aChain_)
	
	# Additional state management methods
	def StateByPosition()
	    # State entries sorted by matched position (ascending)
	    _aSorted_ = []
	    _nLen_ = len(aState)

	    for _i_ = 1 to _nLen_
	        _aSorted_ + aState[_i_]
	    next

	    for _i_ = 2 to _nLen_
	        _e_ = _aSorted_[_i_]
	        _j_ = _i_ - 1

	        while _j_ >= 1
	            if _aSorted_[_j_][:position] > _e_[:position]
	                _aSorted_[_j_ + 1] = _aSorted_[_j_]
	                _j_ -= 1
	            else
	                exit
	            ok
	        end

	        _aSorted_[_j_ + 1] = _e_
	    next

	    return _aSorted_

	def StateByComputationOrder()
	    # Entries are recorded in computation order; return a copy
	    _aSorted_ = []
	    _nLen_ = len(aState)

	    for _i_ = 1 to _nLen_
	        _aSorted_ + aState[_i_]
	    next

	    return _aSorted_

    #------------------#
    # Private Methods  #
    #------------------#
    
    private
    
    def executeComputation(aMatchedValue, _cTriggerName_)
        # Find computation code for this trigger
        _cCode_ = ""
        _nCodesPerTrigger1Len_ = len(aCodesPerTrigger)
        for _iLoopCodesPerTrigger1_ = 1 to _nCodesPerTrigger1Len_
        	pair = aCodesPerTrigger[_iLoopCodesPerTrigger1_]
            if pair[1] = _cTriggerName_
                _cCode_ = pair[2]
                exit
            ok
        next
        
        if trim(_cCode_) = ""
            return aMatchedValue
        ok
        
        try
            @list = aMatchedValue
            @value = aMatchedValue  # For compatibility 
            eval(_cCode_)
            
            # Return either @list or @value based on which was modified
            if @list != aMatchedValue
                return @list
            else
                return @value
            ok
        catch
            return aMatchedValue
        done
