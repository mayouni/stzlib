# ============================================================================
# CONVENIENCE FUNCTIONS FOR EASY SYNTAX
# ============================================================================

# Direct string processing with plugins
func XProcess(cString, cPluginName, aParams)
    oStr = XString(cString)
    return oStr.Xf(cPluginName, aParams)

# Chain multiple plugin operations
func XChain(cString, aPluginCalls)
    oStr = XString(cString)
    cResult = cString
    
    for aCall in aPluginCalls
        cPluginName = aCall[1]
        aParams = []
        if len(aCall) > 1
            aParams = aCall[2]
        ok
        cResult = oStr.Xf(cPluginName, aParams)
        oStr = XString(cResult)  # Update for next operation
    next
    
    return cResult

# ============================================================================
# INTEGRATION HELPERS
# ============================================================================

# Auto-discovery of plugins at startup
func XAutoDiscover()
    return XPlugins()

# Plugin validation
func XValidate(cPluginName)
    try
        return XExists(cPluginName)
    catch
        return false
    done

# Get plugin metadata (if available)
func XInfo(cPluginName)
    oRunner = _oGlobalPluginManager.GetRunner()
    oPlugin = oRunner.oExecutor.oCore.GetPlugin(cPluginName)
    
    if oPlugin != NULL
        return [
            :name = oPlugin.Name(),
            :path = oPlugin.FilePath(),
            :valid = oPlugin.IsValid()
        ]
    else
        return NULL
    ok
