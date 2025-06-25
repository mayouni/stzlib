#--------------------------#
#  PLUGIN CACHE MANAGER    #
#--------------------------#

class stzPluginCacheManager
    @aCache = []
    @nMaxEntries = 50
    @nHits = 0
    @nMisses = 0
    
    def init(nMaxEntries)
        if isNumber(nMaxEntries) and nMaxEntries > 0
            @nMaxEntries = nMaxEntries
        ok
    
    def Gett(oPlugin, aParams)
        cKey = This.CreateCacheKey(oPlugin, aParams)
        nLen = len(@aCache)
        
        for i = 1 to nLen
            if @aCache[i][:Key] = cKey
                # Check if plugin file has changed
                if @aCache[i][:FileTime] = oPlugin.FileTime()
                    @nHits++
                    @aCache[i][:LastAccessed] = clock()
                    @aCache[i][:AccessCount]++
                    return @aCache[i][:Result]
                else
                    # File has changed, remove stale entry
                    del(@aCache, i)
                    exit
                ok
            ok
        next
        
        @nMisses++
        return NULL
    
    def Set(oPlugin, aParams, mResult)
        # Check cache size limit
        if len(@aCache) >= @nMaxEntries
            This.RemoveOldestEntry()
        ok
        
        cKey = This.CreateCacheKey(oPlugin, aParams)
        nNow = clock()
        
        oCacheEntry = [
            :Key = cKey,
            :Plugin = oPlugin.Name(),
            :Params = aParams,
            :Result = mResult,
            :FileTime = oPlugin.FileTime(),
            :CreatedTime = nNow,
            :LastAccessed = nNow,
            :AccessCount = 0
        ]
        
        @aCache + oCacheEntry
    
    def CreateCacheKey(oPlugin, aParams)
        cKey = oPlugin.Name() + "|" + oPlugin.Version() + "|"
        nLen = len(aParams)
        
        for i = 1 to nLen
            if isString(aParams[i])
                cKey += aParams[i]
            but isNumber(aParams[i])
                cKey += "" + aParams[i]
            but isList(aParams[i])
                cKey += This.ListToString(aParams[i])
            ok
            
            if i < nLen
                cKey += ","
            ok
        next
        
        return cKey
    
    def ListToString(aList)
        cStr = "["
        nLen = len(aList)
        
        for i = 1 to nLen
            if isString(aList[i])
                cStr += aList[i]
            but isNumber(aList[i])
                cStr += "" + aList[i]
            ok
            
            if i < nLen
                cStr += ","
            ok
        next
        
        cStr += "]"
        return cStr
    
    def RemoveOldestEntry()
        if len(@aCache) = 0
            return
        ok
        
        nOldestIndex = 1
        nOldestTime = @aCache[1][:LastAccessed]
        nLen = len(@aCache)
        
        for i = 2 to nLen
            if @aCache[i][:LastAccessed] < nOldestTime
                nOldestTime = @aCache[i][:LastAccessed]
                nOldestIndex = i
            ok
        next
        
        del(@aCache, nOldestIndex)
    
    def Clear()
        @aCache = []
        @nHits = 0
        @nMisses = 0
    
    def ClearPlugin(cPluginName)
        nLen = len(@aCache)
        for i = nLen to 1 step -1
            if @aCache[i][:Plugin] = cPluginName
                del(@aCache, i)
            ok
        next
    
    def Stats()
        nTotal = @nHits + @nMisses
        nHitRate = 0
        
        if nTotal > 0
            nHitRate = (@nHits * 100) / nTotal
        ok
        
        return [
            :Entries = len(@aCache),
            :Hits = @nHits,
            :Misses = @nMisses,
            :HitRate = nHitRate
        ]
    
    def Entries()
        return @aCache
