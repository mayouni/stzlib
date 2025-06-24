#-----------------------#
#  RING STATE MANAGER   #
#-----------------------#

class stzRingStateManager
    @aStates = []
    @nMaxStates = 10
    
    def init(nMaxStates)
        if isNumber(nMaxStates) and nMaxStates > 0
            @nMaxStates = nMaxStates
        ok
    
    def CreateState(cName)
        # Check if we have too many states
        if len(@aStates) >= @nMaxStates
            This.CleanupOldestState()
        ok
        
        try
            pState = ring_state_init()
            oStateInfo = new stzRingStateInfo(cName, pState)
            @aStates + oStateInfo
            return oStateInfo
        catch
            return NULL
        done
    
    def FindState(cName)
        nLen = len(@aStates)
        for i = 1 to nLen
            if @aStates[i].Name() = cName
                return @aStates[i]
            ok
        next
        return NULL
    
    def CleanupOldestState()
        if len(@aStates) > 0
            oOldest = @aStates[1]
            oOldest.Destroy()
            del(@aStates, 1)
        ok
    
    def CleanupAllStates()
        nLen = len(@aStates)
        for i = 1 to nLen
            @aStates[i].Destroy()
        next
        @aStates = []
    
    def States()
        return @aStates
    
    def StateNames()
        aNames = []
        nLen = len(@aStates)
        for i = 1 to nLen
            aNames + @aStates[i].Name()
        next
        return aNames
