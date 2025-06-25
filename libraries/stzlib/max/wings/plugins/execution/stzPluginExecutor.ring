#=================================================================#
#  SOFTANZA PLUGIN SYSTEM - EXECUTION LAYER                      #
#  Core plugin execution engine with caching and error handling  #
#=================================================================#

//load "plugin_foundation.ring"

#--------------------------#
#  UTILITY FUNCTIONS       #
#--------------------------#

func CreatePluginRunner(cPluginsPath)
    return new stzPluginRunner(cPluginsPath)

func RunPlugin(cPluginName, aParams, cPluginsPath)
    oRunner = CreatePluginRunner(cPluginsPath)
    return oRunner.Run(cPluginName, aParams)

func TryRunPlugin(cPluginName, aParams, cPluginsPath)
    oRunner = CreatePluginRunner(cPluginsPath)
    return oRunner.TryRun(cPluginName, aParams)

#------------------------#
#  PLUGIN EXECUTOR       #
#------------------------#

class stzPluginExecutor
    @oCore
    @oStateManager
    @oCacheManager
    @aCallHistory = []
    @nMaxHistory = 100
    
    def init(oPluginCore)
        @oCore = oPluginCore
        @oStateManager = new stzRingStateManager(5)
        @oCacheManager = new stzPluginCacheManager()
    
    def Execute(cPluginName, aParams)
        return This.ExecuteWithOptions(cPluginName, aParams, [
            :FaultTolerant = false,
            :UpdateCache = true,
            :TrackHistory = true
        ])
    
    def ExecuteFaultTolerant(cPluginName, aParams)
        return This.ExecuteWithOptions(cPluginName, aParams, [
            :FaultTolerant = true,
            :UpdateCache = true,
            :TrackHistory = true
        ])
    
    def ExecuteWithOptions(cPluginName, aParams, aOptions)
        nStartTime = clock()
        bFaultTolerant = This.GetOption(aOptions, :FaultTolerant, false)
        bUpdateCache = This.GetOption(aOptions, :UpdateCache, true)
        bTrackHistory = This.GetOption(aOptions, :TrackHistory, true)
        
        try
            # Get plugin object
            oPlugin = @oCore.GetPlugin(cPluginName)
            if oPlugin = NULL
                if bFaultTolerant
                    return This.CreateErrorResult("Plugin not found: " + cPluginName, nStartTime)
                else
                    raise("Plugin not found: " + cPluginName)
                ok
            ok
            
            # Check cache first
            if bUpdateCache
                mCached = @oCacheManager.Gett(oPlugin, aParams)
                if mCached != NULL
                    if bTrackHistory
                        This.RecordCall(cPluginName, aParams, true, mCached, 0, "CACHED")
                    ok
                    return This.CreateSuccessResult(mCached, 0, "CACHED")
                ok
            ok
            
            # Execute plugin
            mResult = This.ExecutePlugin(oPlugin, aParams)
            nElapsed = clock() - nStartTime
            
            # Update cache
            if bUpdateCache
                @oCacheManager.Set(oPlugin, aParams, mResult)
            ok
            
            # Record call
            if bTrackHistory
                This.RecordCall(cPluginName, aParams, true, mResult, nElapsed, "EXECUTED")
            ok
            
            return This.CreateSuccessResult(mResult, nElapsed, "EXECUTED")
            
        catch cError
            nElapsed = clock() - nStartTime
            
            if bTrackHistory
                This.RecordCall(cPluginName, aParams, false, cError, nElapsed, "ERROR")
            ok
            
            if bFaultTolerant
                return This.CreateErrorResult(cError, nElapsed)
            else
                raise(cError)
            ok
        done
    
    def ExecutePlugin(oPlugin, aParams)
        # Get or create Ring state for this plugin
        oStateInfo = @oStateManager.FindState(oPlugin.Name())
        if oStateInfo = NULL
            oStateInfo = @oStateManager.CreateState(oPlugin.Name())
            This.InitializePluginState(oStateInfo, oPlugin)
        ok
        
        # Check if plugin file has changed
        if oPlugin.HasChanged()
            oPlugin.ParseMetadata()
            This.InitializePluginState(oStateInfo, oPlugin)
        ok
        
        # Execute in the plugin's Ring state
        oStateInfo.Use()
        return This.RunPluginFunction(oStateInfo.State(), oPlugin, aParams)
    
    def InitializePluginState(oStateInfo, oPlugin)
        try
            cPluginCode = read(oPlugin.FilePath())
            ring_state_runstring(oStateInfo.State(), cPluginCode)
        catch cError
            raise("Failed to initialize plugin state: " + cError)
        done
    
    def RunPluginFunction(pState, oPlugin, aParams)
        try
            # Prepare parameters in the plugin state
            cParamCode = "aPluginParams = " + This.ParamsToRingCode(aParams)
            ring_state_runstring(pState, cParamCode)
            
            # Execute the plugin function
            cExecuteCode = "@plugin_result = pluginFunc(aPluginParams)"
            ring_state_runstring(pState, cExecuteCode)
            
            # Get the result
            cGetResult = "return @plugin_result"
            return ring_state_runstring(pState, cGetResult)
            
        catch cError
            raise("Plugin execution failed: " + cError)
        done
    
    def ParamsToRingCode(aParams)
        if len(aParams) = 0
            return "[]"
        ok
        
        cCode = "[ "
        nLen = len(aParams)
        
        for i = 1 to nLen
            if isString(aParams[i])
                cCode += '"' + aParams[i] + '"'
            but isNumber(aParams[i])
                cCode += "" + aParams[i]
            but isList(aParams[i])
                cCode += This.ListToRingCode(aParams[i])
            else
                cCode += '""'  # Default to empty string
            ok
            
            if i < nLen
                cCode += ", "
            ok
        next
        
        cCode += " ]"
        return cCode
    
    def ListToRingCode(aList)
        cCode = "[ "
        nLen = len(aList)
        
        for i = 1 to nLen
            if isString(aList[i])
                cCode += '"' + aList[i] + '"'
            but isNumber(aList[i])
                cCode += "" + aList[i]
            else
                cCode += '""'
            ok
            
            if i < nLen
                cCode += ", "
            ok
        next
        
        cCode += " ]"
        return cCode
    
    def GetOption(aOptions, cKey, mDefault)
        nLen = len(aOptions)
        for i = 1 to nLen step 2
            if i < nLen and aOptions[i] = cKey
                return aOptions[i + 1]
            ok
        next
        return mDefault
    
    def CreateSuccessResult(mResult, nElapsed, cSource)
        return [
            :Success = true,
            :Result = mResult,
            :Error = "",
            :ElapsedTime = nElapsed,
            :Source = cSource
        ]
    
    def CreateErrorResult(cError, nElapsed)
        return [
            :Success = false,
            :Result = NULL,
            :Error = cError,
            :ElapsedTime = nElapsed,
            :Source = "ERROR"
        ]
    
    def RecordCall(cPlugin, aParams, bSuccess, mResult, nElapsed, cSource)
        if len(@aCallHistory) >= @nMaxHistory
            del(@aCallHistory, 1)
        ok
        
        @aCallHistory + [
            :Plugin = cPlugin,
            :Params = aParams,
            :Success = bSuccess,
            :Result = mResult,
            :ElapsedTime = nElapsed,
            :Source = cSource,
            :Timestamp = clock()
        ]
    
    # Public query interface
    def CallHistory()
        return @aCallHistory
    
    def LastCall()
        nLen = len(@aCallHistory)
        if nLen > 0
            return @aCallHistory[nLen]
        ok
        return NULL
    
    def CallsFor(cPluginName)
        aCalls = []
        nLen = len(@aCallHistory)
        
        for i = 1 to nLen
            if @aCallHistory[i][:Plugin] = cPluginName
                aCalls + @aCallHistory[i]
            ok
        next
        
        return aCalls
    
    def SuccessfulCalls()
        aCalls = []
        nLen = len(@aCallHistory)
        
        for i = 1 to nLen
            if @aCallHistory[i][:Success]
                aCalls + @aCallHistory[i]
            ok
        next
        
        return aCalls
    
    def FailedCalls()
        aCalls = []
        nLen = len(@aCallHistory)
        
        for i = 1 to nLen
            if not @aCallHistory[i][:Success]
                aCalls + @aCallHistory[i]
            ok
        next
        
        return aCalls
    
    def ClearHistory()
        @aCallHistory = []
    
    def StateManager()
        return @oStateManager
    
    def CacheManager()
        return @oCacheManager


#--------------------------#
#  PLUGIN RUNNER (Helper)  #
#--------------------------#

class stzPluginRunner
    @oExecutor
    
    def init(cPluginsPath)
        oCore = new stzPluginCore(cPluginsPath)
        @oExecutor = new stzPluginExecutor(oCore)
    
    def Run(cPluginName, aParams)
        oResult = @oExecutor.Execute(cPluginName, aParams)
        if oResult[:Success]
            return oResult[:Result]
        else
            raise(oResult[:Error])
        ok
    
    def TryRun(cPluginName, aParams)
        oResult = @oExecutor.ExecuteFaultTolerant(cPluginName, aParams)
        return oResult
    
    def Executor()
        return @oExecutor
