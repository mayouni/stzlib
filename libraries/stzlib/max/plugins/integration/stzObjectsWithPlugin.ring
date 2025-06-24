# ============================================================================
# ENHANCED SOFTANZA CLASSES WITH PLUGIN INTEGRATION
# ============================================================================

# Enhanced String class with plugin support
class stzXString from stzString
    # Include plugin capabilities
    oPluginMixin = new stzPluginMixin()
    
    def init(cStr)
        stzString.init(cStr)
    
    # Delegate plugin methods to mixin
    def Xf(cPluginName, aParams)
        return oPluginMixin.Xf(cPluginName, aParams)
    
    def Xff(cPluginName, aParams)
        return oPluginMixin.Xff(cPluginName, aParams)
    
    def XfU(cPluginName, aParams)
        mResult = oPluginMixin.Xf(cPluginName, aParams)
        This.UpdateContent(mResult)
        return true
    
    def XCalls()
        return oPluginMixin.XCalls()
    
    def XFuncts()
        return oPluginMixin.XFuncts()
    
    def XFunctions()
        return oPluginMixin.XFunctions()
    
    def Xfs()
        return oPluginMixin.Xfs()
    
    def XfsZ()
        return oPluginMixin.XfsZ()
    
    def HowManyXErrors()
        return oPluginMixin.HowManyXErrors()
    
    def HowManyXFailedCalls()
        return oPluginMixin.HowManyXFailedCalls()
    
    def XErrors()
        return oPluginMixin.XErrors()
    
    def XErroneousCalls()
        return oPluginMixin.XErroneousCalls()
    
    def NumberOfXSuccesses()
        return oPluginMixin.NumberOfXSuccesses()
    
    def XSuccesses()
        return oPluginMixin.XSuccesses()
    
    def XSucceededCalls()
        return oPluginMixin.XSucceededCalls()
    
    def XTime(cPluginName)
        return oPluginMixin.XTime(cPluginName)
    
    # Update the string content
    def UpdateContent(mValue)
        if isString(mValue)
            This.UpdateStringWith(mValue)
        ok
    
    # Alias for backward compatibility
    def Content()
        return This.Content()

# Factory function to create plugin-enabled strings
func XString(cStr)
    return new stzXString(cStr)
