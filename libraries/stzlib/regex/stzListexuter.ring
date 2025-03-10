# Example implementation of stzListexuter

func lxuter()
    return new stzListexuter
    
    func lxu()
        return new stzListexuter

class stzListexuter

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

    # Performance tracking attributes
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
        for trigger in aTriggers
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
        if left(cCode, 1) = "{" and right(cCode, 1) = "}"
            cCode = substr(cCode, 2, len(cCode)-2)
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
        
        for trigger in aTriggers
            cTriggerName = trigger[1]
            cPattern = trigger[2]
            
            # Create listex pattern matcher
            oListex = new stzListex(cPattern)
            
            # Find all sublists that match the pattern
            aMatches = FindAllMatches(aList, oListex)
            
            if len(aMatches) > 0
                aActiveComputations + cTriggerName
                
                for i = 1 to len(aMatches)
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
    #  Result methods  #
    #------------------#



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
            for i = 1 to len(aList)
                if isList(aList[i])
                    # Recursively check nested list
                    aSubMatches = FindAllMatches(aList[i], oListex)
                    for match in aSubMatches
                        aResult + match
                    next
                ok
            next
            
            # Check for matching sublists at this level
            for i = 1 to len(aList)
                for j = i to len(aList)
                    aSubList = StzListQ(aList).Section(i, j)
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
    for entry in aState
        if find(entry[:dependsOn], cTriggerName) > 0
            aAffected + entry[:triggerName] 
        ok
    next

    return unique(aAffected)

def GetDependencyChain(cTriggerName)
    aChain = []
    
    for entry in aState
        if entry[:triggerName] = cTriggerName
            aChain + entry[:dependsOn]
            
            for depTrigger in entry[:dependsOn]
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
    # Private Method  #
    #------------------#
    
    private
    
    def executeComputation(aMatchedValue, cTriggerName)
        # Find computation code for this trigger
        cCode = ""
        for pair in aCodesPerTrigger
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
