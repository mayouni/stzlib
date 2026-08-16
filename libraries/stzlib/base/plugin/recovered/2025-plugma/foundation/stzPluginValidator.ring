#------------------------#
#  PLUGIN VALIDATOR      #
#------------------------#

class stzPluginValidator
    
    def ValidatePlugin(oPlugin)
        aErrors = []
        
        # Check if file exists
        if not fexists(oPlugin.FilePath())
            aErrors + "Plugin file does not exist"
            return [false, aErrors]
        ok
        
        # Check if file is readable
        try
            cContent = read(oPlugin.FilePath())
        catch
            aErrors + "Cannot read plugin file"
            return [false, aErrors]
        done
        
        # Check for required function
        if not This.HasPluginFunction(cContent)
            aErrors + "Plugin must contain a pluginFunc() function"
        ok
        
        # Check for required variables
        if not This.HasRequiredVariables(cContent)
            aErrors + "Plugin must define @plugin_result variable"
        ok
        
        return [len(aErrors) = 0, aErrors]
    
    def HasPluginFunction(cContent)
        return (find(cContent, "func pluginFunc(") > 0 or
                find(cContent, "func pluginFunc (") > 0)
    
    def HasRequiredVariables(cContent)
        return find(cContent, "@plugin_result") > 0
