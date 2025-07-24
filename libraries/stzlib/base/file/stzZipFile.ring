#=========================================#
# ZIP FILE CLASS - ARCHIVE OPERATIONS     #
#=========================================#

func ZipFile(cZipFileName)
    return new stzZipFile(cZipFileName)

class stzZipFile from stzObject
    @cZipFileName
    @oQFileInfo
    
    def init(cZipFileName)
        @cZipFileName = cZipFileName
        @oQFileInfo = new QFileInfo(cZipFileName)
    
    # CREATION OPERATIONS
    def CreateFrom(aFiles)
        # Create zip from list of files
        if not islist(aFiles)
            StzRaise("Files parameter must be a list")
        ok
        
        oZip = zip_openfile(@cZipFileName, 'w')
        if oZip = NULL
            StzRaise("Cannot create zip file: " + @cZipFileName)
        ok
        
        nLen = len(aFiles)
        for i = 1 to nLen
            if FileExists(aFiles[i])
                zip_addfile(oZip, aFiles[i])
            ok
        next
        
        zip_close(oZip)
        return @cZipFileName
    
        def CreateFromQ(aFiles)
            This.CreateFrom(aFiles)
            return This
    
    def CreateFromSingleFile(cFileName)
        # Create zip from single file
        return This.CreateFrom([cFileName])
    
        def CreateFromSingleFileQ(cFileName)
            This.CreateFromSingleFile(cFileName)
            return This
    
    def CreateFromDirectory(cDirPath)
        # Create zip from all files in directory
        if not DirExists(cDirPath)
            StzRaise("Directory does not exist: " + cDirPath)
        ok
        
        aFiles = FilesInDir(cDirPath)
        nLen = len(aFiles)
        for i = 1 to nLen
            aFiles[i] = cDirPath + "/" + aFiles[i]
        next
        
        return This.CreateFrom(aFiles)
    
        def CreateFromDirectoryQ(cDirPath)
            This.CreateFromDirectory(cDirPath)
            return This
    
    # MODIFICATION OPERATIONS
    def AddFile(cFileName)
        # Add file to existing zip
        if not FileExists(cFileName)
            StzRaise("File does not exist: " + cFileName)
        ok
        
        oZip = zip_openfile(@cZipFileName, 'a')
        if oZip = NULL
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        zip_addfile(oZip, cFileName)
        zip_close(oZip)
        return @cZipFileName
    
        def AddFileQ(cFileName)
            This.AddFile(cFileName)
            return This
    
    def AddFiles(aFiles)
        # Add multiple files to existing zip
        if not islist(aFiles)
            StzRaise("Files parameter must be a list")
        ok
        
        oZip = zip_openfile(@cZipFileName, 'a')
        if oZip = NULL
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        nLen = len(aFiles)
        for i = 1 to nLen
            if FileExists(aFiles[i])
                zip_addfile(oZip, aFiles[i])
            ok
        next
        
        zip_close(oZip)
        return @cZipFileName
    
        def AddFilesQ(aFiles)
            This.AddFiles(aFiles)
            return This
    
    def AddString(cEntryName, cContent)
        # Add string content as file entry
        oZip = zip_openfile(@cZipFileName, 'a')
        if oZip = NULL
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        oEntry = zip_newentry(oZip)
        zip_entry_open(oEntry, cEntryName)
        zip_entry_writestring(oEntry, cContent)
        zip_entry_close(oEntry)
        
        zip_close(oZip)
        return @cZipFileName
    
        def AddStringQ(cEntryName, cContent)
            This.AddString(cEntryName, cContent)
            return This
    
    # EXTRACTION OPERATIONS
    def ExtractTo(cTargetDir)
        # Extract all files to target directory
        if not This.Exists()
            StzRaise("Zip file does not exist: " + @cZipFileName)
        ok
        
        zip_extract_allfiles(@cZipFileName, cTargetDir)
        return cTargetDir
    
        def ExtractToQ(cTargetDir)
            This.ExtractTo(cTargetDir)
            return This
    
    def ExtractHere()
        # Extract to same directory as zip file
        cDirPath = @oQFileInfo.dir().path()
        return This.ExtractTo(cDirPath)
    
        def ExtractHereQ()
            This.ExtractHere()
            return This
    
    def ExtractToNewFolder()
        # Extract to new folder with zip file's base name
        cBaseName = @oQFileInfo.completeBaseName()
        cDirPath = @oQFileInfo.dir().path()
        cTargetDir = cDirPath + "/" + cBaseName
        
        return This.ExtractTo(cTargetDir)
    
        def ExtractToNewFolderQ()
            This.ExtractToNewFolder()
            return This
    
    # INSPECTION OPERATIONS
    def ListContents()
        # List all files in zip
        if not This.Exists()
            StzRaise("Zip file does not exist: " + @cZipFileName)
        ok
        
        oZip = zip_openfile(@cZipFileName, 'r')
        if oZip = NULL
            StzRaise("Cannot open zip file: " + @cZipFileName)
        ok
        
        aFiles = []
        nCount = zip_filescount(oZip)
        for i = 1 to nCount
            aFiles + zip_getfilenamebyindex(oZip, i)
        next
        
        zip_close(oZip)
        return aFiles
    
        def ListContentsQ()
            This.ListContents()
            return This
    
    def FileCount()
        # Return number of files in zip
        if not This.Exists()
            return 0
        ok
        
        oZip = zip_openfile(@cZipFileName, 'r')
        if oZip = NULL
            return 0
        ok
        
        nCount = zip_filescount(oZip)
        zip_close(oZip)
        return nCount
    
    def Contains(cFileName)
        # Check if zip contains specific file
        aContents = This.ListContents()
        nLen = len(aContents)
        for i = 1 to nLen
            if aContents[i] = cFileName
                return _TRUE_
            ok
        next
        return _FALSE_
    
    def IsEmpty()
        # Check if zip is empty
        return (This.FileCount() = 0)
    
    def Size()
        # Get zip file size
        if not This.Exists()
            return 0
        ok
        return @oQFileInfo.size()
    
    # UTILITY OPERATIONS
    def FileName()
        return @cZipFileName
    
    def Exists()
        return @oQFileInfo.exists()
    
    def Delete()
        # Delete zip file
        oQFile = new QFile(@cZipFileName)
        return oQFile.remove()
    
        def DeleteQ()
            This.Delete()
            return This
    
    def CopyTo(cDestination)
        # Copy zip file to destination
        oQFile = new QFile(@cZipFileName)
        return oQFile.copy(cDestination)
    
        def CopyToQ(cDestination)
            This.CopyTo(cDestination)
            return This
    
    def MoveTo(cDestination)
        # Move zip file to destination
        oQFile = new QFile(@cZipFileName)
        bResult = oQFile.rename(cDestination)
        if bResult
            @cZipFileName = cDestination
            @oQFileInfo = new QFileInfo(@cZipFileName)
        ok
        return bResult
    
        def MoveToQ(cDestination)
            This.MoveTo(cDestination)
            return This
