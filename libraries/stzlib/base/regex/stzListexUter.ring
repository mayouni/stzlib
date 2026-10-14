# Example implementation of stzListexuter

func StzLxuter()
    return new stzListexuter

    func lxuter()
        return StzLxuter()

    func StzLxu()
        return StzLxuter()

    func lxu()
        return StzLxuter()

# Matches list-pattern triggers in a list, runs a piece of code on each match and keeps a log of what changed.
#
# The list counterpart of stzRegexuter. Register triggers (a name and a list pattern such as [@N,
# @S]), attach code that edits the match held in @list, then Process a list: every trigger is tried
# against the whole list and against every contiguous run of its items. Matches, Triggers and
# Results describe the last run and State logs the matches whose computed list differs. Build one
# with StzLxuter(), lxuter(), StzLxu() or lxu(). Edit the list in place in the code (@list[1] =
# @list[1] * 10): assigning @value has no effect and a whole-list assignment that mentions @list
# reads the new empty list. Found today: a whole list that matches is reported twice;
# GetDependencyChain overflows the stack once the log holds an entry; StateByPosition sorts by a
# field the entries do not have; and a single text given to AddTrigger raises R3.
#
#   receiver   o1 = StzLxuter()
#   example    o1.AddTrigger([ "pair", "[@N, @S]" ])
#              o1.AddCode("pair", "@list[1] = @list[1] * 10")
#              o1.Process([ 1, "a", 2, "b" ])
#              ? @@( o1.Matches() )
#              #--> [ [ 1, "a" ], [ 2, "b" ] ]
#              ? @@( o1.Results() )
#              #--> [ [ 10, "a" ], [ 20, "b" ] ]
#              o2 = StzLxuter()
#              o2.AddTrigger([ "word", "[@S]" ])
#              o2.Process([ "שלום", 5 ])
#              ? @@( o2.Matches() )
#              #--> [ [ "שלום" ] ]
#   see        stzListex, stzRegexuter, stzList
class stzListexuter from stzObject

    # Core data structures
    @aTriggers = []      # Pairs of [cTriggerName, cListPattern]
    @aCodesPerTrigger = [] # Pairs of [cTriggerName, cCodeToExecute]
    
    # State management
    @aState = []         # List of state entries as hashlists
    @aActiveComputations = [] # Track active computations
    
    # Results tracking
    @aLastTriggers = []
    @aLastMatches = []
    @aLastResults = []

	# Performance tracking attributes to add
	@nProcessStartTime = 0
	@nLastProcessDuration = 0

    # Builds an empty reactive list computer with no trigger and no code.
    #
    #   returns    nothing; the object is built
    #   note       build one with StzLxuter(), lxuter(), StzLxu() or lxu()
    #   see        AddTrigger, Process
    def init()
        # Do nothing
        
    #------------------#
    # Trigger Methods  #
    #------------------#
    
    # Registers a trigger: a name paired with a list pattern such as [@N, @S].
    #
    #   aTrigger   a pair [ name, list pattern ]
    #   returns    nothing; the trigger is added
    #   note       [ "pair", "[@N, @S]" ] makes a trigger that matches a number followed by a text
    #   warning    a single text, which is meant to name a library pattern, raises R3 because the
    #              function lpat does not exist
    #   see        AddCode, Process
    def AddTrigger(aTrigger)
        if isString(aTrigger)
            # Handle string case - convert to pattern
            if TriggerNameExists(aTrigger)
                StzRaise("Trigger name already exists: " + aTrigger)
            ok
            @aTriggers + [ aTrigger, lpat(aTrigger) ]
            return
        ok
        
        if NOT (isList(aTrigger) and len(aTrigger) = 2 and 
                isString(aTrigger[1]) and isString(aTrigger[2]))
            StzRaise("Incorrect parameter format! Expected [name, pattern]")
        ok
        
        if TriggerNameExists(aTrigger[1])
            StzRaise("Trigger name already exists: " + aTrigger[1])
        ok
        
        @aTriggers + aTrigger
        
    # TRUE if a trigger of that name is registered.
    #
    #   cName      the trigger name
    #   returns    TRUE or FALSE, as 1 or 0
    #   note       the name is compared with case
    #   see        AddTrigger
    def TriggerNameExists(cName)
        _nTriggers2Len_ = len(@aTriggers)
        for _iLoopTriggers2_ = 1 to _nTriggers2Len_
        	trigger = @aTriggers[_iLoopTriggers2_]
            if trigger[1] = cName
                return 1
            ok
        next
        return 0
        
    #---------------#
    # Code Methods  #
    #---------------#
    
    # Attaches a piece of Ring code to a trigger, to compute a new list from each match held in @list.
    #
    #   _cTriggerName_   the name of a registered trigger
    #   _cCode_          the code as text, which must mention @value or @list and may be wrapped in
    #                    braces
    #   returns          nothing; the code is stored
    #   note             AddComputation and @C are the same call; @list[1] = @list[1] * 10 turns [1,
    #                    "a"] into [10, "a"]
    #   warning          only the FIRST code attached to a trigger runs; only a change made to @list
    #                    takes effect, and assigning @value changes nothing; edit the list in place:
    #                    @list[1] = @list[1] * 10 works, whereas @list = [ @list[1] * 10 ] reads the
    #                    new empty list and leaves the match as it was; a code that raises is silent
    #   see              AddTrigger, Process
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
            _cCode_ = StzMid(_cCode_, 2, StzLen(_cCode_)-2)
        ok
        
        @aCodesPerTrigger + [_cTriggerName_, _cCode_]
        
    #------------------#
    # Process Methods  #
    #------------------#
    
    # Matches every trigger against a list and its contiguous sublists, runs the attached code on each match and records what changed.
    #
    #   aList      the list to analyse
    #   returns    nothing; read the outcome with Matches, Results and State
    #   note       Compute is the same call; [1, "a", 2, "b"] with [@N, @S] gives the matches [1,
    #              "a"] and [2, "b"]
    #   warning    the whole list is tested and then every contiguous run of items, so a whole list
    #              that matches is reported twice ([3, "c"] gives two identical matches) and [@N+]
    #              on [7, 8, 9] gives seven; matches come trigger by trigger; an empty list clears
    #              the state log but not the last matches; the log keeps growing across calls until
    #              ResetState
    #   see        Matches, Results, State
    def Process(aList)
        if NOT isList(aList)
            StzRaise("Invalid input! Expected list to analyze.")
        ok
        
        if len(aList) = 0
            ResetState()
            return
        ok
        
        # Reset tracking for this process run
        @aLastMatches = []
        @aLastResults = []
        @aLastTriggers = []
        @aActiveComputations = []
        
        _nTriggers1Len_ = len(@aTriggers)
        for _iLoopTriggers1_ = 1 to _nTriggers1Len_
        	trigger = @aTriggers[_iLoopTriggers1_]
            _cTriggerName_ = trigger[1]
            _cPattern_ = trigger[2]
            
            # Create listex pattern matcher
            _oListex_ = new stzListex(_cPattern_)
            
            # Find all sublists that match the pattern
            _aMatches_ = FindAllMatches(aList, _oListex_)
            
            if len(_aMatches_) > 0
                @aActiveComputations + _cTriggerName_
                
                _nMatchesLen_ = len(_aMatches_)
                for i = 1 to _nMatchesLen_
                    _match_ = _aMatches_[i]
                    
                    @aLastMatches + _match_
                    @aLastTriggers + _cTriggerName_
                    
                    # Execute computation and track result
                    _computedValue_ = executeComputation(_match_, _cTriggerName_)
                    @aLastResults + _computedValue_
                    
                    # Record state change
                    if NOT ListEquals(_computedValue_, _match_)
                        AddStateEntry(_cTriggerName_, _cPattern_, _match_, _computedValue_)
                    ok
                next
                
                del(@aActiveComputations, len(@aActiveComputations))
            ok
        next
        
    #------------------#
    # Helper Methods   #
    #------------------#
    
    # Returns every sublist of a list that a list pattern matches: the whole list, items nested inside it, and every contiguous run.
    #
    #   aList       the list to search
    #   _oListex_   a stzListex built from the pattern
    #   returns     a list of matches
    #   note        [1, "a", 2, "b"] with [@N, @S] gives [1, "a"] and [2, "b"]; the empty list gives
    #               [ ]
    #   warning     a match found as the whole list is also found as a run, so it comes back twice,
    #               and a nested list is searched again as a run of its parent
    #   see         Process
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
    
    # Empties the log of state entries and the list of active computations.
    #
    #   returns    nothing
    #   warning    it does not clear Matches, Triggers or Results of the last run
    #   see        State, Process
    def ResetState()
        @aState = []
        @aActiveComputations = []
        
    # Appends one entry to the state log, recording that a match was turned into another list.
    #
    #   _cTriggerName_   the trigger that matched
    #   _cPattern_       its pattern
    #   aMatchedValue    the list matched
    #   aComputedValue   the list the code produced
    #   returns          nothing; the log grows by one
    #   note             Process calls it for every match whose computed list differs from the
    #                    match; the entry keeps timestamp, computationorder, triggername, pattern,
    #                    matchedvalue, computedvalue, dependson and affects, and no position
    #   see              State, StateByComputationOrder
    def AddStateEntry(_cTriggerName_, _cPattern_, aMatchedValue, aComputedValue)
        # Create state entry
        _entry_ = [
            :timeStamp = date() + " " + time(),
            :computationOrder = len(@aState) + 1,
            
            :triggerName = _cTriggerName_,
            :pattern = _cPattern_,
            :matchedValue = aMatchedValue,
            :computedValue = aComputedValue,
            
            :dependsOn = @aActiveComputations,
            :affects = getAffectedTriggers(_cTriggerName_)
        ]
        
        @aState + _entry_
        

	#-------------------------#
	#  MISC. REORGANIZE THEM  #
	#-------------------------#
	
	# Registers a trigger: a name paired with a list pattern.
	#
	#   aTrigger   a pair [ name, list pattern ]
	#   returns    nothing; the trigger is added
	#   note       the same call as AddTrigger
	#   warning    same limits as AddTrigger
	#   see        AddTrigger
	#@ aka  Alternative method names
	def Trigger(aTrigger)
	    This.AddTrigger(aTrigger)
	
	# Attaches a piece of Ring code to a trigger, to compute a new list from each match held in @list.
	#
	#   _cTriggerName_   the name of a registered trigger
	#   _cCode_          the code as text, which must mention @value or @list
	#   returns          nothing; the code is stored
	#   note             the same call as AddCode
	#   warning          same limits as AddCode
	#   see              AddCode
	def AddComputation(_cTriggerName_, _cCode_)
	    This.AddCode(_cTriggerName_, _cCode_)
	
	# Attaches a piece of Ring code to a trigger, to compute a new list from each match held in @list.
	#
	#   _cTriggerName_   the name of a registered trigger
	#   _cCode_          the code as text, which must mention @value or @list
	#   returns          nothing; the code is stored
	#   note             the same call as AddCode
	#   warning          same limits as AddCode
	#   see              AddCode
	def @C(_cTriggerName_, _cCode_)
	    This.AddCode(_cTriggerName_, _cCode_)
	
	# Matches every trigger against a list and its sublists, runs the attached code on each match and records what changed.
	#
	#   aList      the list to analyse
	#   returns    nothing; read the outcome with Matches and Results
	#   note       the same call as Process
	#   warning    same limits as Process
	#   see        Process
	def Compute(aList)
	    This.Process(aList)
	
	# Returns the state log: one entry per match whose computed list differs from the match.
	#
	#   returns    a list of entries, each a list of [ key, value ] pairs; [ ] after ResetState
	#   note       a match left unchanged by its code is not logged
	#   see        StateByComputationOrder, ResetState
	#@ aka  Result access methods
	def State()
	    return @aState
	
	# Returns the trigger name of each match of the last run.
	#
	#   returns    a list of texts, parallel to Matches
	#   note       pair, pair for [1, "a", 2, "b"]
	#   see        Matches, Results
	def Triggers()
	    return @aLastTriggers
	
	# Returns each matched sublist of the last run, trigger by trigger.
	#
	#   returns    a list of lists
	#   note       MatchedValuesXT, MatchesAndResults and MatchesAndTheirResults pair each match
	#              with its result
	#   see        Results, Triggers
	def Matches() 
	    return @aLastMatches
	
	# Returns the list computed for each match of the last run.
	#
	#   returns    a list of lists, parallel to Matches
	#   note       with no code, or with a code that changes nothing, the result is the match
	#              itself; ResultXT, ResultsAndMatches and ResultsAndTheirMatches pair each result
	#              with its match
	#   see        Matches
	def Results()
	    return @aLastResults
	
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
	
	# Returns the names of the triggers whose log entries depend on a given trigger.
	#
	#   _cTriggerName_   the trigger whose dependants are wanted
	#   returns          a list of trigger names, repeats removed
	#   note             an unknown name or an empty log gives [ ]
	#   warning          because an entry always depends on its own trigger, a trigger that has
	#                    logged an entry answers itself
	#   see              GetDependencyChain, State
	#@ aka  Dependency chain method
	def getAffectedTriggers(_cTriggerName_)
	    _aAffected_ = []
	    
	    # Look through state history for triggers affected by this one
	    _nState2Len_ = len(@aState)
	    for _iLoopState2_ = 1 to _nState2Len_
	    	_entry_ = @aState[_iLoopState2_]
	        if find(_entry_[:dependsOn], _cTriggerName_) > 0
	            _aAffected_ + _entry_[:triggerName] 
	        ok
	    next
	
	    return unique(_aAffected_)
	
	# Raises a stack overflow today instead of returning the triggers a trigger depends on.
	#
	#   _cTriggerName_   the trigger whose chain is wanted
	#   returns          nothing; the call raises R4 Stack Overflow
	#   note             an unknown trigger or an empty log gives [ ]
	#   warning          every log entry lists its own trigger in dependson, so the method calls
	#                    itself on that same trigger without end; confirmed with the triggers pair
	#                    and t1
	#   see              getAffectedTriggers
	def GetDependencyChain(_cTriggerName_)
	    _aChain_ = []
	    
	    _nState1Len_ = len(@aState)
	    for _iLoopState1_ = 1 to _nState1Len_
	    	_entry_ = @aState[_iLoopState1_]
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
	
	# Returns the state log with an empty position field added to each entry, in computation order.
	#
	#   returns    a list of entries, each a list of [ key, value ] pairs
	#   note       use StateByComputationOrder
	#   warning    the entries of a list computer store no position, so the sort reads an absent
	#              field, adds position = "" to every entry and orders nothing
	#   see        StateByComputationOrder, State
	#@ aka  Additional state management methods
	def StateByPosition()
	    # State entries sorted by matched position (ascending)
	    _aSorted_ = []
	    _nLen_ = len(@aState)

	    for _i_ = 1 to _nLen_
	        _aSorted_ + @aState[_i_]
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

	# Returns a copy of the state log in the order the computations ran.
	#
	#   returns    a list of entries, each a list of [ key, value ] pairs
	#   see        State, StateByPosition
	def StateByComputationOrder()
	    # Entries are recorded in computation order; return a copy
	    _aSorted_ = []
	    _nLen_ = len(@aState)

	    for _i_ = 1 to _nLen_
	        _aSorted_ + @aState[_i_]
	    next

	    return _aSorted_

    #------------------#
    # Private Methods  #
    #------------------#
    
    private
    
    # Runs the code attached to a trigger on one matched list and returns the list produced.
    #
    #   aMatchedValue    the matched list
    #   _cTriggerName_   the trigger whose code is run
    #   returns          the list after the code; the match itself when the trigger has no code or
    #                    the code raises
    #   note             it is called by Process for every match
    #   warning          private: calling it from outside raises R26
    #   see              Process, AddCode
    def executeComputation(aMatchedValue, _cTriggerName_)
        # Find computation code for this trigger
        _cCode_ = ""
        _nCodesPerTrigger1Len_ = len(@aCodesPerTrigger)
        for _iLoopCodesPerTrigger1_ = 1 to _nCodesPerTrigger1Len_
        	pair = @aCodesPerTrigger[_iLoopCodesPerTrigger1_]
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
