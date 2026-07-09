#=========================================#
# ZIP FILE CLASS - ARCHIVE OPERATIONS     #
#=========================================#

func _DirOfPath(_cPath_)
	_cPath_ = StzReplace(_cPath_, "\", "/")
	_nPos_ = 0
	for i = StzLen(_cPath_) to 1 step -1
		if _cPath_[i] = "/"
			_nPos_ = i
			exit
		ok
	next
	if _nPos_ > 0
		return StzLeft(_cPath_, _nPos_ - 1)
	ok
	return "."

func _BaseNameOfPath(_cPath_)
	_cPath_ = StzReplace(_cPath_, "\", "/")
	_nSlash_ = 0
	for i = StzLen(_cPath_) to 1 step -1
		if _cPath_[i] = "/"
			_nSlash_ = i
			exit
		ok
	next
	_cName_ = StzMid(_cPath_, _nSlash_ + 1, StzLen(_cPath_) - _nSlash_)
	_nDot_ = 0
	for i = StzLen(_cName_) to 1 step -1
		if _cName_[i] = "."
			_nDot_ = i
			exit
		ok
	next
	if _nDot_ > 1
		return StzLeft(_cName_, _nDot_ - 1)
	ok
	return _cName_

func ZipFile(cZipFileName)
    return new stzZipFile(cZipFileName)

class stzZipFile from stzObject
    @cZipFileName

    def init(cZipFileName)
        @cZipFileName = cZipFileName
    
    # CREATION OPERATIONS
    def CreateFrom(_aFiles_)
        # Create zip from list of files
        if not islist(_aFiles_)
            StzRaise("Files parameter must be a list")
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'w')
        if _oZip_ = NULL
            StzRaise("Cannot create zip file: " + @cZipFileName)
        ok
        
        _nLen_ = len(_aFiles_)
        for i = 1 to _nLen_
            if StzFileExists(_aFiles_[i])
                zip_addfile(_oZip_, _aFiles_[i])
            ok
        next

        zip_close(_oZip_)
        return @cZipFileName

        def CreateFromQ(_aFiles_)
            This.CreateFrom(_aFiles_)
            return This
    
    def CreateFromSingleFile(cFileName)
        # Create zip from single file
        return This.CreateFrom([cFileName])
    
        def CreateFromSingleFileQ(cFileName)
            This.CreateFromSingleFile(cFileName)
            return This
    
    def CreateFromDirectory(_cDirPath_)
        # Create zip from all files in directory
        if not DirExists(_cDirPath_)
            StzRaise("Directory does not exist: " + _cDirPath_)
        ok
        
        _aFiles_ = FilesInDir(_cDirPath_)
        _nLen_ = len(_aFiles_)
        for i = 1 to _nLen_
            _aFiles_[i] = _cDirPath_ + "/" + _aFiles_[i]
        next
        
        return This.CreateFrom(_aFiles_)
    
        def CreateFromDirectoryQ(_cDirPath_)
            This.CreateFromDirectory(_cDirPath_)
            return This
    
    # MODIFICATION OPERATIONS
    def AddFile(cFileName)
        # Add file to existing zip
        if not StzFileExists(cFileName)
            StzRaise("File does not exist: " + cFileName)
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'a')
        if _oZip_ = NULL
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        zip_addfile(_oZip_, cFileName)
        zip_close(_oZip_)
        return @cZipFileName
    
        def AddFileQ(cFileName)
            This.AddFile(cFileName)
            return This
    
    def AddFiles(_aFiles_)
        # Add multiple files to existing zip
        if not islist(_aFiles_)
            StzRaise("Files parameter must be a list")
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'a')
        if _oZip_ = NULL
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        _nLen_ = len(_aFiles_)
        for i = 1 to _nLen_
            if StzFileExists(_aFiles_[i])
                zip_addfile(_oZip_, _aFiles_[i])
            ok
        next

        zip_close(_oZip_)
        return @cZipFileName

        def AddFilesQ(_aFiles_)
            This.AddFiles(_aFiles_)
            return This
    
    def AddString(cEntryName, cContent)
        # Add string content as file entry
        _oZip_ = zip_openfile(@cZipFileName, 'a')
        if _oZip_ = NULL
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        _oEntry_ = zip_newentry(_oZip_)
        zip_entry_open(_oEntry_, cEntryName)
        zip_entry_writestring(_oEntry_, cContent)
        zip_entry_close(_oEntry_)
        
        zip_close(_oZip_)
        return @cZipFileName
    
        def AddStringQ(cEntryName, cContent)
            This.AddString(cEntryName, cContent)
            return This
    
    # EXTRACTION OPERATIONS
    def ExtractTo(_cTargetDir_)
        # Extract all files to target directory
        if not This.Exists()
            StzRaise("Zip file does not exist: " + @cZipFileName)
        ok
        
        zip_extract_allfiles(@cZipFileName, _cTargetDir_)
        return _cTargetDir_
    
        def ExtractToQ(_cTargetDir_)
            This.ExtractTo(_cTargetDir_)
            return This
    
    def ExtractHere()
        _cDirPath_ = _DirOfPath(@cZipFileName)
        return This.ExtractTo(_cDirPath_)
    
        def ExtractHereQ()
            This.ExtractHere()
            return This
    
    def ExtractToNewFolder()
        _cBaseName_ = _BaseNameOfPath(@cZipFileName)
        _cDirPath_ = _DirOfPath(@cZipFileName)
        _cTargetDir_ = _cDirPath_ + "/" + _cBaseName_
        
        return This.ExtractTo(_cTargetDir_)
    
        def ExtractToNewFolderQ()
            This.ExtractToNewFolder()
            return This
    
    # INSPECTION OPERATIONS
    def ListContents()
        # List all files in zip
        if not This.Exists()
            StzRaise("Zip file does not exist: " + @cZipFileName)
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'r')
        if _oZip_ = NULL
            StzRaise("Cannot open zip file: " + @cZipFileName)
        ok
        
        _aFiles_ = []
        _nCount_ = zip_filescount(_oZip_)
        for i = 1 to _nCount_
            _aFiles_ + zip_getfilenamebyindex(_oZip_, i)
        next
        
        zip_close(_oZip_)
        return _aFiles_
    
        def ListContentsQ()
            This.ListContents()
            return This
    
    def FileCount()
        # Return number of files in zip
        if not This.Exists()
            return 0
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'r')
        if _oZip_ = NULL
            return 0
        ok
        
        _nCount_ = zip_filescount(_oZip_)
        zip_close(_oZip_)
        return _nCount_
    
    def Contains(cFileName)
        # Check if zip contains specific file
        _aContents_ = This.ListContents()
        _nLen_ = len(_aContents_)
        for i = 1 to _nLen_
            if _aContents_[i] = cFileName
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
        _cData_ = read(@cZipFileName)
        write(cDestination, _cData_)
        return fexists(cDestination)
    
        def CopyToQ(cDestination)
            This.CopyTo(cDestination)
            return This
    
    def MoveTo(cDestination)
        _cData_ = read(@cZipFileName)
        write(cDestination, _cData_)
        if fexists(cDestination)
            remove(@cZipFileName)
            @cZipFileName = cDestination
            return TRUE
        ok
        return FALSE
    
        def MoveToQ(cDestination)
            This.MoveTo(cDestination)
            return This
