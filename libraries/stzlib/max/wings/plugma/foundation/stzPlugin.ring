#-------------------#
#  INDIVIDUAL PLUGIN #
#-------------------#

class stzPlugin
    @cFilePath
    @cName
    @cVersion
    @cDescription
    @bActive
    @bValid
    @nFileTime
    @aMetadata = []
    
    def init(cFilePath)
        @cFilePath = cFilePath
        @bActive = This.IsActiveFile(cFilePath)
        This.ParseMetadata()
    
    def IsActiveFile(cFilePath)
        cFileName = This.FileNameOnly(cFilePath)
        return not (left(cFileName, 4) = "off_")
    
    def FileNameOnly(cFilePath)
        nPos = 0
        for i = len(cFilePath) to 1 step -1
            if cFilePath[i] = "/" or cFilePath[i] = "\"
                nPos = i
                exit
            ok
        next
        
        if nPos > 0
            return substr(cFilePath, nPos + 1)
        else
            return cFilePath
        ok
    
    def ParseMetadata()
        @bValid = false
        @cName = ""
        @cVersion = "V1"
        @cDescription = ""
        @aMetadata = []
        
        if not fexists(@cFilePath)
            return
        ok
        
        try
            cContent = read(@cFilePath)
            @nFileTime = fgettime(@cFilePath)
            
            # Extract plugin name from filename
            cFileName = This.FileNameOnly(@cFilePath)
            cBaseName = substr(cFileName, 1, len(cFileName) - 5) # Remove .ring
            
            # Remove prefixes
            if left(cBaseName, 4) = "off_"
                cBaseName = substr(cBaseName, 5)
            ok
            
            if left(cBaseName, 7) = "plugin_"
                cBaseName = substr(cBaseName, 8)
            ok
            
            # Extract version if present
            nUnderPos = 0
            for i = len(cBaseName) to 1 step -1
                if cBaseName[i] = "_" and i < len(cBaseName)
                    cAfter = substr(cBaseName, i + 1)
                    if left(cAfter, 1) = "V" and isdigit(substr(cAfter, 2, 1))
                        @cVersion = cAfter
                        @cName = left(cBaseName, i - 1)
                        nUnderPos = i
                        exit
                    ok
                ok
            next
            
            if nUnderPos = 0
                @cName = cBaseName
            ok
            
            # Parse metadata from file content
            This.ExtractMetadata(cContent)
            @bValid = (@cName != "")
            
        catch
            @bValid = false
        done
    
    def ExtractMetadata(cContent)
        # Extract @plugin_* variables
        aLines = split(cContent, nl)
        nLen = len(aLines)
        
        for i = 1 to nLen
            cLine = trim(aLines[i])
            
            if left(cLine, 17) = "@plugin_desc" and find(cLine, "=") > 0
                @cDescription = This.ExtractValue(cLine)
                
            but left(cLine, 12) = "@plugin_" and find(cLine, "=") > 0
                cKey = This.ExtractKey(cLine)
                cValue = This.ExtractValue(cLine)
                @aMetadata + [cKey, cValue]
            ok
        next
    
    def ExtractKey(cLine)
        nPos = find(cLine, "=")
        if nPos > 0
            return trim(substr(cLine, 1, nPos - 1))
        ok
        return ""
    
    def ExtractValue(cLine)
        nPos = find(cLine, "=")
        if nPos > 0
            cValue = trim(substr(cLine, nPos + 1))
            # Remove quotes if present
            if len(cValue) >= 2
                if (left(cValue, 1) = '"' and right(cValue, 1) = '"') or
                   (left(cValue, 1) = "'" and right(cValue, 1) = "'")
                    cValue = substr(cValue, 2, len(cValue) - 2)
                ok
            ok
            return cValue
        ok
        return ""
    
    # Public interface
    def FilePath()
        return @cFilePath
    
    def Name()
        return @cName
    
    def Version()
        return @cVersion
    
    def Description()
        return @cDescription
    
    def IsActive()
        return @bActive
    
    def IsValid()
        return @bValid
    
    def FileTime()
        return @nFileTime
    
    def HasChanged()
        if not fexists(@cFilePath)
            return true
        ok
        return (fgettime(@cFilePath) != @nFileTime)
    
    def Metadata()
        return @aMetadata
    
    def GetMetadata(cKey)
        nLen = len(@aMetadata)
        for i = 1 to nLen
            if @aMetadata[i][1] = cKey
                return @aMetadata[i][2]
            ok
        next
        return ""
