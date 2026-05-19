#=========================================#
# ZIP FILE CLASS - ARCHIVE OPERATIONS     #
#=========================================#

func _DirOfPath(cPath)
	cPath = StzReplace(cPath, "\", "/")
	nPos = 0
	for i = StzLen(cPath) to 1 step -1
		if cPath[i] = "/"
			nPos = i
			exit
		ok
	next
	if nPos > 0
		return StzLeft(cPath, nPos - 1)
	ok
	return "."

func _BaseNameOfPath(cPath)
	cPath = StzReplace(cPath, "\", "/")
	nSlash = 0
	for i = StzLen(cPath) to 1 step -1
		if cPath[i] = "/"
			nSlash = i
			exit
		ok
	next
	cName = StzMid(cPath, nSlash + 1, StzLen(cPath) - nSlash)
	nDot = 0
	for i = StzLen(cName) to 1 step -1
		if cName[i] = "."
			nDot = i
			exit
		ok
	next
	if nDot > 1
		return StzLeft(cName, nDot - 1)
	ok
	return cName

func ZipFile(cZipFileName)
    return new stzZipFile(cZipFileName)

class stzZipFile from stzObject
    @cZipFileName

    def init(cZipFileName)
        @cZipFileName = cZipFileName
    
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
            if StzFileExists(aFiles[i])
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
        if not StzFileExists(cFileName)
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
            if StzFileExists(aFiles[i])
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
        cDirPath = _DirOfPath(@cZipFileName)
        return This.ExtractTo(cDirPath)
    
        def ExtractHereQ()
            This.ExtractHere()
            return This
    
    def ExtractToNewFolder()
        cBaseName = _BaseNameOfPath(@cZipFileName)
        cDirPath = _DirOfPath(@cZipFileName)
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
                return 1
            ok
        next
        return 0
    
    def IsEmpty()
        # Check if zip is empty
        return (This.FileCount() = 0)
    
    def Size()
        if not This.Exists()
            return 0
        ok
        return StzLen(read(@cZipFileName))
    
    # UTILITY OPERATIONS
    def FileName()
        return @cZipFileName
    
    def Exists()
        return fexists(@cZipFileName)
    
    def Delete()
        return remove(@cZipFileName)
    
        def DeleteQ()
            This.Delete()
            return This
    
    def CopyTo(cDestination)
        cData = read(@cZipFileName)
        write(cDestination, cData)
        return fexists(cDestination)
    
        def CopyToQ(cDestination)
            This.CopyTo(cDestination)
            return This
    
    def MoveTo(cDestination)
        cData = read(@cZipFileName)
        write(cDestination, cData)
        if fexists(cDestination)
            remove(@cZipFileName)
            @cZipFileName = cDestination
            return TRUE
        ok
        return FALSE
    
        def MoveToQ(cDestination)
            This.MoveTo(cDestination)
            return This
