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

# Creates, extends, lists and unpacks a zip archive named by a path.
#
# CreateFrom builds an archive from a list of files and AddFile and AddFiles extend an existing one;
# each file is stored under the path as given, so give relative paths. ListContents, FileCount and
# Contains read the entry names, and ExtractTo, ExtractHere and ExtractToNewFolder unpack them.
# CopyTo, MoveTo and Delete act on the archive file itself. Three things do not work today and are
# warned on their methods: AddString, CreateFromDirectory and a correct Size. Extracting an archive
# whose entry names are absolute paths ends the Ring process.
#
#   receiver   o1 = new stzZipFile("demo_not_made.zip")
#   example    ? o1.Exists()
#              #--> 0
#              ? o1.FileCount()
#              #--> 0
#              ? o1.IsEmpty()
#              #--> 1
#   see        ZipFile, stzFile, stzFolder
class stzZipFile from stzObject
    @cZipFileName

    # Builds a handle on a zip archive path; nothing is read or created until a method is called.
    #
    #   cZipFileName   the path of the archive, existing or to be created
    #   returns        nothing; the object is built
    #   see            CreateFrom, Exists
    def init(cZipFileName)
        @cZipFileName = cZipFileName
    
    # Creates the archive, replacing any existing one, from the files of a list that exist; a missing file is skipped without a message.
    #
    #   _aFiles_   the list of file paths
    #   returns    the archive path
    #   note       give relative paths to get entries that extract anywhere
    #   warning    raises Files parameter must be a list for anything else; a path given as absolute
    #              is stored as absolute, and extracting such an archive ends the Ring process (see
    #              ExtractTo)
    #   see        AddFiles, ExtractTo
    #@ aka  CREATION OPERATIONS
    def CreateFrom(_aFiles_)
        # Create zip from list of files
        if not islist(_aFiles_)
            StzRaise("Files parameter must be a list")
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'w')
        if _oZip_ = ""
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
    
    # Creates the archive from one file, as CreateFrom does for a list of one.
    #
    #   cFileName   the file to store, under the path as given
    #   returns     the archive path
    #   see         CreateFrom, AddFile
    def CreateFromSingleFile(cFileName)
        # Create zip from single file
        return This.CreateFrom([cFileName])
    
        def CreateFromSingleFileQ(cFileName)
            This.CreateFromSingleFile(cFileName)
            return This
    
    # Raises error R3 today instead of creating the archive from every file of a folder.
    #
    #   _cDirPath_   the folder meant to be zipped
    #   returns      nothing; it raises
    #   note         build the file list yourself and call CreateFrom
    #   warning      the call FilesInDir does not exist anywhere in the library, so an existing
    #                folder raises R3 Calling Function without definition: filesindir; a missing
    #                folder raises Directory does not exist
    #   see          CreateFrom
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
    
    # Appends an existing file to an existing archive; the same file added twice is stored twice.
    #
    #   cFileName   the file to add, stored under the path as given
    #   returns     the archive path
    #   note        use CreateFrom to start an archive
    #   warning     raises File does not exist for a missing file; on an archive that does not exist
    #               yet it returns the path and creates nothing, so no entry is added and no error
    #               is raised
    #   see         AddFiles, CreateFrom
    #@ aka  MODIFICATION OPERATIONS
    def AddFile(cFileName)
        # Add file to existing zip
        if not StzFileExists(cFileName)
            StzRaise("File does not exist: " + cFileName)
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'a')
        if _oZip_ = ""
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        zip_addfile(_oZip_, cFileName)
        zip_close(_oZip_)
        return @cZipFileName
    
        def AddFileQ(cFileName)
            This.AddFile(cFileName)
            return This
    
    # Appends the files of a list to an existing archive, skipping those that do not exist; a file already inside is stored a second time.
    #
    #   _aFiles_   the list of file paths, each stored as given
    #   returns    the archive path
    #   warning    raises Files parameter must be a list for anything else; like AddFile, it creates
    #              nothing on an archive that does not exist yet
    #   see        AddFile, CreateFrom
    def AddFiles(_aFiles_)
        # Add multiple files to existing zip
        if not islist(_aFiles_)
            StzRaise("Files parameter must be a list")
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'a')
        if _oZip_ = ""
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
    
    # Raises error R3 today instead of storing a text as an entry of the archive.
    #
    #   cEntryName   the entry name meant for the text
    #   cContent     the text meant to be stored
    #   returns      nothing; it raises
    #   note         write the text to a file and use CreateFrom
    #   warning      the zip_newentry function it calls does not exist (checked by calling it
    #                directly), so every call raises R3 Calling Function without definition:
    #                zip_newentry
    #   see          AddFile
    def AddString(cEntryName, cContent)
        # Add string content as file entry
        _oZip_ = zip_openfile(@cZipFileName, 'a')
        if _oZip_ = ""
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
    
    # Extracts every entry under a folder, keeping each entry's own relative path, and returns the folder.
    #
    #   _cTargetDir_   the folder to extract into
    #   returns        the target folder path
    #   note           create the archive with relative paths, as CreateFrom explains
    #   warning        raises Zip file does not exist for a missing archive; an archive whose
    #                  entries have absolute paths ends the Ring process at once with exit 127 and
    #                  no message when the folder already exists, and extracts nothing when it does
    #                  not
    #   see            ExtractHere, ExtractToNewFolder, ListContents
    #@ aka  EXTRACTION OPERATIONS
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
    
    # Extracts the archive into the folder that holds it.
    #
    #   returns    the folder path, . when the archive path has none
    #   warning    raises Zip file does not exist for a missing archive; the same absolute-path risk
    #              as ExtractTo
    #   see        ExtractTo, ExtractToNewFolder
    def ExtractHere()
        _cDirPath_ = _DirOfPath(@cZipFileName)
        return This.ExtractTo(_cDirPath_)
    
        def ExtractHereQ()
            This.ExtractHere()
            return This
    
    # Extracts the archive into a new folder beside it, named like the archive without its extension.
    #
    #   returns    the folder path, such as here/nf for here/nf.zip
    #   warning    raises Zip file does not exist for a missing archive; the same absolute-path risk
    #              as ExtractTo
    #   see        ExtractTo, ExtractHere
    def ExtractToNewFolder()
        _cBaseName_ = _BaseNameOfPath(@cZipFileName)
        _cDirPath_ = _DirOfPath(@cZipFileName)
        _cTargetDir_ = _cDirPath_ + "/" + _cBaseName_
        
        return This.ExtractTo(_cTargetDir_)
    
        def ExtractToNewFolderQ()
            This.ExtractToNewFolder()
            return This
    
    # Returns the names of the entries, exactly as stored, in the order they were added.
    #
    #   returns    a list of text
    #   note       a file stored twice is listed twice
    #   warning    raises Zip file does not exist for a missing archive
    #   see        FileCount, Contains
    #@ aka  INSPECTION OPERATIONS
    def ListContents()
        # List all files in zip
        if not This.Exists()
            StzRaise("Zip file does not exist: " + @cZipFileName)
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'r')
        if _oZip_ = ""
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
    
    # Returns how many entries the archive holds, 0 for a missing or unreadable archive.
    #
    #   returns    a number
    #   see        ListContents, IsEmpty
    def FileCount()
        # Return number of files in zip
        if not This.Exists()
            return 0
        ok
        
        _oZip_ = zip_openfile(@cZipFileName, 'r')
        if _oZip_ = ""
            return 0
        ok
        
        _nCount_ = zip_filescount(_oZip_)
        zip_close(_oZip_)
        return _nCount_
    
    # TRUE if an entry has exactly this name, as stored: a file added by absolute path matches only by that path.
    #
    #   cFileName   the entry name
    #   returns     1 or 0, numbers
    #   warning     raises Zip file does not exist for a missing archive
    #   see         ListContents
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
    
    # TRUE if the archive holds no entry, which is also true when it does not exist.
    #
    #   returns    1 or 0, numbers
    #   see        FileCount, Exists
    def IsEmpty()
        # Check if zip is empty
        return (This.FileCount() = 0)
    
    # Returns the size of the archive file, but 0 for an archive that holds files.
    #
    #   returns    a number; 98 for an archive with no entry, 0 today for a non-empty one
    #   note       0 also means the archive does not exist
    #   warning    the size is counted as characters of the file read as text, which gives 0 for the
    #              compressed bytes of a non-empty archive (a 478-byte archive reads 0, an empty one
    #              reads 98); use len(read(path)) for the byte count
    #   see        FileName, Exists
    def Size()
        if not This.Exists()
            return 0
        ok
        return StzLen(read(@cZipFileName))
    
    # Returns the archive path given at birth, or the new path after a MoveTo.
    #
    #   returns    a text
    #   see        MoveTo, Exists
    #@ aka  UTILITY OPERATIONS
    def FileName()
        return @cZipFileName
    
    # TRUE if the archive file exists on disk.
    #
    #   returns    1 or 0, numbers
    #   see        FileName, Delete
    def Exists()
        return fexists(@cZipFileName)
    
    # Removes the archive file; an archive that is already gone is not an error.
    #
    #   returns    nothing
    #   see        Exists, MoveTo
    def Delete()
        return remove(@cZipFileName)
    
        def DeleteQ()
            This.Delete()
            return This
    
    # Copies the archive file to another path and tells whether the copy is there.
    #
    #   cDestination   the path of the copy
    #   returns        1 or 0, numbers
    #   warning        raises Can't create/open the file (R35) when the archive does not exist
    #   see            MoveTo
    def CopyTo(cDestination)
        _cData_ = read(@cZipFileName)
        write(cDestination, _cData_)
        return fexists(cDestination)
    
        def CopyToQ(cDestination)
            This.CopyTo(cDestination)
            return This
    
    # Copies the archive to another path, removes the original and makes the object point at the new path.
    #
    #   cDestination   the new path
    #   returns        1 if the copy exists, else 0
    #   warning        raises Can't create/open the file (R35) when the archive does not exist
    #   see            CopyTo, FileName
    def MoveTo(cDestination)
        _cData_ = read(@cZipFileName)
        write(cDestination, _cData_)
        if fexists(cDestination)
            remove(@cZipFileName)
            @cZipFileName = cDestination
            return 1
        ok
        return 0
    
        def MoveToQ(cDestination)
            This.MoveTo(cDestination)
            return This
