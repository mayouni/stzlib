#=================================================================#
#  SOFTANZA PLUGIN SYSTEM - FOUNDATION LAYER                      #
#  Core components for plugin discovery, validation, and loading  #
#=================================================================#

#-----------------#
#  PLUGIN CORE    #
#-----------------#

class stzPluginCore
    @aPlugins = []
    @cPluginsPath = "plugins"
    @cPluginPrefix = "plugin_"
    
    def init(cPath)
        if isString(cPath) and cPath != NULL
            @cPluginsPath = cPath
        ok
        This.ScanPlugins()
    
    def ScanPlugins()
        @aPlugins = []
        
        if not fexists(@cPluginsPath)
            return []
        ok
        
        aFiles = dir(@cPluginsPath)
        nLen = len(aFiles)
        
        for i = 1 to nLen
            cFile = aFiles[i][1]
            
            # Skip directories and non-ring files
            if aFiles[i][2] or not This.IsPluginFile(cFile)
                loop
            ok
            
            oPlugin = new stzPlugin(@cPluginsPath + "/" + cFile)
            if oPlugin.IsValid()
                @aPlugins + oPlugin
            ok
        next
        
        return @aPlugins
    
    def IsPluginFile(cFile)
        return (left(cFile, len(@cPluginPrefix)) = @cPluginPrefix and 
                right(cFile, 5) = ".ring")
    
    def Plugins()
        return @aPlugins
    
    def PluginNames()
        aNames = []
        nLen = len(@aPlugins)
        
        for i = 1 to nLen
            aNames + @aPlugins[i].Name()
        next
        
        return aNames
    
    def GetPlugin(cName)
        nLen = len(@aPlugins)
        
        for i = 1 to nLen
            if @aPlugins[i].Name() = cName
                return @aPlugins[i]
            ok
        next
        
        return NULL
    
    def HasPlugin(cName)
        return (This.GetPlugin(cName) != NULL)
    
    def RefreshPlugins()
        This.ScanPlugins()
