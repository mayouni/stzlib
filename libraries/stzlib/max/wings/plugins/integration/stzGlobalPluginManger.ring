# ============================================================================
# SOFTANZA PLUGIN SYSTEM - INTEGRATION LAYER
# ============================================================================
# This layer provides seamless integration between the plugin system and:
# 1. Softanza objects (stzString, stzList, etc.)
# 2. Ring programs via global functions
# 3. Simple API for end users

// load "stzPluginRunner.ring"  # From the foundation/execution layers

# ============================================================================
# GLOBAL FUNCTIONS - Direct access for Ring programs
# ============================================================================

# Simple plugin execution
func Xf(cPluginName, aParams)
    return _oGlobalPluginManager.GetRunner().Run(cPluginName, aParams)

# Fault-tolerant version
func Xff(cPluginName, aParams)
    try
        return _oGlobalPluginManager.GetRunner().Run(cPluginName, aParams)
    catch cError
        return "Error: " + cError
    done

# Check if plugin exists
func XExists(cPluginName)
    oRunner = _oGlobalPluginManager.GetRunner()
    return oRunner.oExecutor.oCore.GetPlugin(cPluginName) != NULL

# Set plugins directory
func XSetPluginsPath(cPath)
    _oGlobalPluginManager.SetPluginsPath(cPath)

# Get list of available plugins
func XPlugins()
    oRunner = _oGlobalPluginManager.GetRunner()
    aResult = []
    for oPlugin in oRunner.oExecutor.oCore.aPlugins
        aResult + oPlugin.Name()
    next
    return aResult


# ============================================================================
# GLOBAL PLUGIN MANAGER - Singleton for system-wide plugin access
# ============================================================================

class stzGlobalPluginManager
    oRunner = NULL
    cDefaultPluginsPath = "plugins"
    bInitialized = false
    
    def init()
        if not bInitialized
            oRunner = new stzPluginRunner(cDefaultPluginsPath)
            bInitialized = true
        ok
    
    def SetPluginsPath(cPath)
        cDefaultPluginsPath = cPath
        oRunner = new stzPluginRunner(cPath)
        bInitialized = true
    
    def GetRunner()
        if not bInitialized
            This.init()
        ok
        return oRunner

# Global instance
_oGlobalPluginManager = new stzGlobalPluginManager()
