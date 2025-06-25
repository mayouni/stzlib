# ============================================================================
# SOFTANZA OBJECT INTEGRATION MIXIN
# ============================================================================
# This provides plugin capabilities to any Softanza object

class stzPluginMixin
    # Plugin call history for this object instance
    aXCalls = []
    
    # Execute plugin and return result (doesn't modify object)
    def Xf(cPluginName, aParams)
        if isString(cPluginName) and left(cPluginName, 1) = ":"
            cPluginName = substr(cPluginName, 2)
        ok
        
        # Handle special syntax: :plugin = [params]
        if isList(cPluginName) and len(cPluginName) = 2
            aParams = cPluginName[2]
            cPluginName = cPluginName[1]
        ok
        
        # Record the call
        nStartTime = clock()
        
        try
            mResult = _oGlobalPluginManager.GetRunner().Run(cPluginName, aParams)
            nExecutionTime = (clock() - nStartTime) / 1000.0
            
            # Log successful call
            aXCalls + [cPluginName, aParams, 1, mResult, nExecutionTime]
            
            return mResult
            
        catch cError
            nExecutionTime = (clock() - nStartTime) / 1000.0
            
            # Log failed call
            aXCalls + [cPluginName, aParams, 0, cError, nExecutionTime]
            
            raise(cError)
        done
    
    # Fault-tolerant version
    def Xff(cPluginName, aParams)
        try
            return This.Xf(cPluginName, aParams)
        catch cError
            return "Error: " + cError
        done
    
    # Execute plugin and update object content
    def XfU(cPluginName, aParams)
        try
            mResult = This.Xf(cPluginName, aParams)
            This.UpdateContent(mResult)
            return true
        catch cError
            return false
        done
    
    # Get plugin call history
    def XCalls()
        return aXCalls
    
    # Get list of called plugin functions
    def XFuncts()
        aResult = []
        for aCall in aXCalls
            if find(aResult, aCall[1]) = 0
                aResult + aCall[1]
            ok
        next
        return aResult
    
    # Alternative names for XFuncts
    def XFunctions()
        return This.XFuncts()
    
    def Xfs()
        return This.XFuncts()
    
    # Get functions with call counts
    def XfsZ()
        aResult = []
        aFunctions = This.XFuncts()
        
        for cFunc in aFunctions
            aCallNumbers = []
            for i = 1 to len(aXCalls)
                if aXCalls[i][1] = cFunc
                    aCallNumbers + i
                ok
            next
            aResult + [cFunc, aCallNumbers]
        next
        
        return aResult
    
    # Get error count
    def HowManyXErrors()
        nCount = 0
        for aCall in aXCalls
            if aCall[3] = 0  # Error flag
                nCount++
            ok
        next
        return nCount
    
    # Alternative name
    def HowManyXFailedCalls()
        return This.HowManyXErrors()
    
    # Get error details
    def XErrors()
        aResult = []
        for aCall in aXCalls
            if aCall[3] = 0  # Error flag
                aResult + [aCall[1], aCall[2], aCall[4]]  # name, params, error
            ok
        next
        return aResult
    
    # Alternative name
    def XErroneousCalls()
        return This.XErrors()
    
    # Get success count
    def NumberOfXSuccesses()
        return len(aXCalls) - This.HowManyXErrors()
    
    # Get successful calls
    def XSuccesses()
        aResult = []
        for aCall in aXCalls
            if aCall[3] = 1  # Success flag
                aResult + [aCall[1], aCall[2], aCall[4]]  # name, params, result
            ok
        next
        return aResult
    
    # Alternative name
    def XSucceededCalls()
        return This.XSuccesses()
    
    # Get execution time for a specific plugin
    def XTime(cPluginName)
        for aCall in aXCalls
            if aCall[1] = cPluginName
                return aCall[5]  # execution time
            ok
        next
        return 0
    
    # Abstract method - must be implemented by inheriting classes
    def UpdateContent(mValue)
        # This should be overridden in actual Softanza classes
        # to update their internal content appropriately
        pass
