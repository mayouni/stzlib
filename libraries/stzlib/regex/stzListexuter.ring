# Simplified stzListexuter implementation
# A reactive pattern matching and data transformation engine for lists

func lxuter()
    return new stzListexuter
    
func lxu()
    return new stzListexuter

class stzListexuter

    #---------------------------#
    # Main Data Structures      #
    #---------------------------#
    
    @aTriggers = []         # HashList of triggers with format [name] = pattern
    aComputations = []      # List of computations [cTriggerName, cCode]
    aHarvested = []         # Collected data from pattern matching and transformations
    
    #---------------------------#
    # Processing State          #
    #---------------------------#
    
    aState = []             # State history tracking all transformations
    aProcessingChain = []   # Current processing chain for dependency tracking
    
    #---------------------------#
    # Results Tracking          #
    #---------------------------#
    
    aCurrentMatches = []    # Current matched patterns
    aMatchedTriggers = []   # Names of triggered patterns
    
    #---------------------------#
    # Performance Metrics       #
    #---------------------------#
    
    nStartTime = 0          # Process start timestamp
    nEndTime = 0            # Process end timestamp
    
    #---------------------------#
    # Initialization            #
    #---------------------------#
    
    def init()
        # Initialize the class

    #---------------------------#
    # Trigger Management        #
    #---------------------------#
    
    def Trigger(aTrigger)
    
	    cName = aTrigger[1]
	    cPattern = aTrigger[2]

	    # Add trigger as a pair to the list
	    @aTriggers + [cName, cPattern]
	
    
    def GetTriggerPattern(cName)   
        return @aTriggers[cName]
    
    #---------------------------#
    # Computation Management    #
    #---------------------------#
    
    def AddComputation(cTriggerName, cCode)
        return @C(cTriggerName, cCode)
    
    def @C(cTriggerName, cCode)
        if isList(cTriggerName)
		cTriggerName = cTriggerName[2]
	ok
        if isList(cCode)
		cCode = cCode[2]
	ok

        # Clean computation code
        cCode = trim(cCode)
        if left(cCode, 1) = "{" and right(cCode, 1) = "}"
            cCode = StzStringQ(cCode).Section(2, len(cCode)-2)
        ok
        
        # Store computation
        aComputations + [cTriggerName, cCode]
    
    #---------------------------#
    # Processing Methods        #
    #---------------------------#
    
    def Process(pData)
        # Main processing method that analyzes data and runs computations
        
        # Validate input
        if NOT (isList(pData) or isString(pData) or isNumber(pData))
            StzRaise("Invalid input! Expected list, string, or number.")
        ok
        
        # Reset state for new processing run
        ResetProcessingState()
        
        # Start performance timer
        nStartTime = clock()
        
        # If input is not a list, convert it to a single-item list
        aInputData = []
        if isList(pData)
            aInputData = pData
        else 
            aInputData = [pData]
        ok
        
        # Process each item in the list
        ProcessList(aInputData)
        
        # End performance timer
        nEndTime = clock()
    
    	def Compute(pData)
        	# Alias for Process
       		Process(pData)
    
    def ProcessList(aList)
        # Process a list by applying all triggers and their computations
        
 /*       # First check if entire list matches any pattern
        if isList(@aTriggers) and len(@aTriggers) > 0
            for cTriggerName in StzHashListQ(@aTriggers).Keys()
                cPattern = @aTriggers[cTriggerName]
                
                # Check if list matches this pattern
                if MatchesPattern(aList, cPattern)
                    # List matches, apply computation
                    aCurrentMatches + aList
                    aMatchedTriggers + cTriggerName
                    
                    # Execute computation for this match
                    ExecuteComputation(aList, cTriggerName)
                    
                    # Store in state history
                    AddToState(cTriggerName, aList, aHarvested)
                ok
            next
        ok
   */     
        # Then recursively process each item in the list
        for i = 1 to len(aList)
            # Process item based on its type
            if isList(aList[i])
                # Recursively process nested list
                ProcessList(aList[i])
            else
                # Process single item
                ProcessItem(aList[i])
            ok
        next
    
    def ProcessItem(pItem)
        # Process a single item by applying all triggers and their computations
        
        if isList(@aTriggers) and len(@aTriggers) > 0
            for cTriggerName in StzHashListQ(@aTriggers).Keys()
                cPattern = @aTriggers[cTriggerName]
                
                # Check if item matches this pattern
                if MatchesPattern(pItem, cPattern)
                    # Item matches, apply computation
                    aCurrentMatches + pItem
                    aMatchedTriggers + cTriggerName
                    
                    # Execute computation for this match
                    ExecuteComputation(pItem, cTriggerName)
                    
                    # Store in state history
                    AddToState(cTriggerName, pItem, aHarvested)
                ok
            next
        ok
    
    def MatchesPattern(pItem, cPattern)
        # Check if an item matches a pattern
        
        # Determine if it's a listex pattern or regex pattern
        if isString(cPattern) and 
           @StartsWith(cPattern, "[") and @EndsWith(cPattern, "]")

            # It's a listex pattern
            if isList(pItem)
                
                # Create listex pattern matcher
                oListex = new stzListex(cPattern)
                return oListex.Match(pItem)
            ok
        else
            # It's a regex pattern
            if isString(pItem)
                # Use regex for string matching
                oRegex = new stzRegex(cPattern)
                return oRegex.Match(pItem)
            but isNumber(pItem)
                # Convert number to string for regex matching
                oRegex = new stzRegex(cPattern)
                return oRegex.Match("" + pItem)
            ok
        ok
        
        return FALSE
    
    def ExecuteComputation(pMatchedItem, cTriggerName)
        # Execute computation code for a given trigger and matched item
        
        # Find computation code for this trigger
        cCode = GetComputationCode(cTriggerName)
        
/*        if @trim(cCode) = ""
            # No computation defined, add item as is
            aHarvested + pMatchedItem
            return
        ok
 */       
        try
            # Set up computation environment
            @item = pMatchedItem
            @value = pMatchedItem  # For compatibility
@string = pMatchedItem


            @list = []
            if isList(pMatchedItem)
                @list = pMatchedItem
            else
                @list = [pMatchedItem]
            ok

            @aResult = []  # Initialize result container
            @trigger = cTriggerName
            
            # Execute computation code
            eval(cCode)
            
            # Process results based on what was modified

            if len(@aResult) > 0
                # If @aResult was populated, add each item to harvested
                for item in @aResult
                    aHarvested + item
                next

            else
                aOriginalList = []

                if isList(pMatchedItem)
                    aOriginalList = pMatchedItem
                else
                    aOriginalList = [pMatchedItem]
                ok
                
                if @list != aOriginalList
                    # If @list was modified, add each item to harvested
                    for item in @list
                        aHarvested + item
                    next
                but @value != pMatchedItem
                    # If @value was modified, add to harvested
                    aHarvested + @value
                else
                    # Default: add original item
                    aHarvested + pMatchedItem
                ok
            ok
            
        catch
            ? "Error in computation for trigger " + cTriggerName
            # In case of error, add original item
            aHarvested + pMatchedItem
        done
    
    def GetComputationCode(cTriggerName)
        # Get computation code by trigger name
        for computation in aComputations
            if len(computation) >= 2 and computation[1] = cTriggerName
                return computation[2]
            ok
        next
        return ""  # No computation found
    
    #---------------------------#
    # State Management          #
    #---------------------------#
    
    def ResetState()
        # Reset all state variables
        aComputations = []
        aHarvested = []
        
        aState = []
        aProcessingChain = []
        
        aCurrentMatches = []
        aMatchedTriggers = []
        
        nStartTime = 0
        nEndTime = 0
    
    def ResetProcessingState()
        # Reset just the processing state for a new run
        aHarvested = []
        
        aCurrentMatches = []
        aMatchedTriggers = []
        
        aProcessingChain = []
        
        nStartTime = 0
        nEndTime = 0
    
    def AddToState(cTriggerName, pMatchedValue, pComputedValue)
        # Add entry to state history
        oEntry = [
            :timestamp = date() + " " + time(),
            :order = len(aState) + 1,
            :trigger = cTriggerName,
            :pattern = GetTriggerPattern(cTriggerName),
            :matchedValue = pMatchedValue,
            :computedValue = pComputedValue,
            :processingChain = aProcessingChain
        ]
        
        aState + oEntry
        
        # Update processing chain with this trigger
        if find(aProcessingChain, cTriggerName) = 0
            aProcessingChain + cTriggerName
        ok
    
    #---------------------------#
    # Results Access            #
    #---------------------------#
    
    def Harvest()
        # Return harvested data
        return aHarvested
    
    def Results()
        # Alias for Harvest()
        return Harvest()
    
    def Matches()
        # Return matched patterns
        return aCurrentMatches
    
    def Triggers()
        # Return triggered pattern names
        return aMatchedTriggers
    
    def State()
        # Return state history
        return aState
    
    def StateAt(n)
        # Return state at specific position
        if n > 0 and n <= len(aState)
            return aState[n]
        ok
        return NULL
    
    def ProcessingTime()
        # Return processing time in milliseconds
        return nEndTime - nStartTime
    
    #---------------------------#
    # Result Formatting         #
    #---------------------------#
    
    def ResultsXT()
        # Return results with their matching patterns
        return Association([This.Results(), This.Matches()])
    
        def ResultXT()
            return This.ResultsXT()
    
        def ResultsAndMatches()
            return This.ResultsXT()
    
        def ResultsAndTheirMatches()
            return This.ResultsXT()
    
    def MatchesXT()
        # Return matches with their computed results
        return Association([This.Matches(), This.Results()])
    
        def MatchedValuesXT()
            return This.MatchesXT()
    
        def MatchesAndResults()
            return This.MatchesXT()
    
        def MatchesAndTheirResults()
            return This.MatchesXT()
    
    #---------------------------#
    # Dependency Tracking       #
    #---------------------------#
    
    def GetDependencyChain()
        # Get full dependency chain
        return aProcessingChain
    
    #---------------------------#
    # Utility Methods           #
    #---------------------------#
    
    def Summary()
        # Return summary of processing
        oSummary = [
            :triggersCount = len(@aTriggers),
            :computationsCount = len(aComputations),
            :harvestedCount = len(aHarvested),
            :matchesCount = len(aCurrentMatches),
            :stateCount = len(aState),
            :processingTime = ProcessingTime()
        ]
        
        return oSummary
    
    def ToString()
        # Return string representation of listexuter
        cResult = "stzListexuter {" + nl
        cResult += "   Triggers: " + len(@aTriggers) + nl
        cResult += "   Computations: " + len(aComputations) + nl
        cResult += "   Harvested: " + len(aHarvested) + nl
        cResult += "   State Entries: " + len(aState) + nl
        cResult += "}"
        
        return cResult
