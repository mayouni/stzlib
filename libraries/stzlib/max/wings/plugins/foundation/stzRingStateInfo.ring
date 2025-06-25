#------------------------#
#  RING STATE INFO       #
#------------------------#

class stzRingStateInfo
    @cName
    @pState
    @nCreatedTime
    @nLastUsedTime
    @nUsageCount
    @bDestroyed
    
    def init(cName, pState)
        @cName = cName
        @pState = pState
        @nCreatedTime = clock()
        @nLastUsedTime = @nCreatedTime
        @nUsageCount = 0
        @bDestroyed = false
    
    def Name()
        return @cName
    
    def State()
        return @pState
    
    def Use()
        if not @bDestroyed
            @nLastUsedTime = clock()
            @nUsageCount++
        ok
    
    def UsageCount()
        return @nUsageCount
    
    def LastUsedTime()
        return @nLastUsedTime
    
    def CreatedTime()
        return @nCreatedTime
    
    def IsDestroyed()
        return @bDestroyed
    
    def Destroy()
        if not @bDestroyed and @pState != NULL
            ring_state_delete(@pState)
            @pState = NULL
            @bDestroyed = true
        ok
