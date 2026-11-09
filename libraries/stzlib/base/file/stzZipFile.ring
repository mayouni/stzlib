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
	if _nPos_ = 1
		return "/"
	ok
	if _nPos_ > 1
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

# Tells why a text cannot be the name of an archive entry, or gives "" when it can.
#
# The rules keep an archive from holding a path that leaves the folder it is extracted into (zip slip):
# a name is a text of 1 to 255 bytes, relative (no leading slash, no drive letter), without a
# backslash, a colon, NUL or any control character, and with no segment made only of dots and spaces
# that reads as .. (as .., ... or ". .").
func _ZipEntryNameProblem(_cZName_)
	if not isString(_cZName_)
		return "the name is not a text"
	ok
	_nZLen_ = ring_len(_cZName_)
	if _nZLen_ = 0
		return "the name is empty"
	ok
	if _nZLen_ > 255
		return "the name is longer than 255 bytes"
	ok
	if _cZName_[1] = "/"
		return "the name is absolute (it starts with a slash)"
	ok
	_nZSeg_ = 0
	_nZDots_ = 0
	_nZSpaces_ = 0
	for _nZi_ = 1 to _nZLen_
		_nZCode_ = ascii(_cZName_[_nZi_])
		if _nZCode_ < 32 or _nZCode_ = 127
			return "the name holds NUL or a control character"
		ok
		if _nZCode_ = 92
			return "the name holds a backslash"
		ok
		if _nZCode_ = 58
			return "the name holds a colon (a drive letter or a stream)"
		ok
		if _nZCode_ = 47
			if _nZSeg_ > 0 and (_nZDots_ + _nZSpaces_) = _nZSeg_ and _nZDots_ >= 2
				return "the name holds a .. segment"
			ok
			_nZSeg_ = 0
			_nZDots_ = 0
			_nZSpaces_ = 0
		else
			_nZSeg_ = _nZSeg_ + 1
			if _nZCode_ = 46
				_nZDots_ = _nZDots_ + 1
			ok
			if _nZCode_ = 32
				_nZSpaces_ = _nZSpaces_ + 1
			ok
		ok
	next
	if _nZSeg_ > 0 and (_nZDots_ + _nZSpaces_) = _nZSeg_ and _nZDots_ >= 2
		return "the name holds a .. segment"
	ok
	return ""

# Gives a name made fit to print: at most 60 bytes, each byte that is not plain ASCII shown as ?.
func _ZipShowName(_cZName_)
	if not isString(_cZName_)
		return "(not a text)"
	ok
	_nZMax_ = ring_len(_cZName_)
	if _nZMax_ > 60
		_nZMax_ = 60
	ok
	_cZOut_ = ""
	for _nZi_ = 1 to _nZMax_
		_nZCode_ = ascii(_cZName_[_nZi_])
		if _nZCode_ < 32 or _nZCode_ > 126
			_cZOut_ = _cZOut_ + "?"
		else
			_cZOut_ = _cZOut_ + _cZName_[_nZi_]
		ok
	next
	return _cZOut_

# Says why an archive cannot be written at this path, or "" when it can: its folder is missing, or
# (to add to it) the file there is not a zip. Asked BEFORE zip_openfile, because that answer is the
# runtime's: Ring's zip refused both and answered NULL, Ring++'s answers a handle, treats a file that
# is not a zip as an empty archive and rewrites it at close (2026-11-07: a text file lost its bytes).
#
#   _cZPath_   the archive's path
#   _cZMode_   "w" to create it, "a" to add to it
#   returns    a text; "" when the archive can be written
func _ZipArchiveProblem(_cZPath_, _cZMode_)
	_cZP_ = StzReplace("" + _cZPath_, char(92), "/")
	_nZCut_ = 0
	_nZLen_ = ring_len(_cZP_)
	for _nZi_ = _nZLen_ to 1 step -1
		if _cZP_[_nZi_] = "/"
			_nZCut_ = _nZi_
			exit
		ok
	next
	if _nZCut_ > 1 and NOT direxists(left(_cZP_, _nZCut_ - 1))
		return "its folder does not exist"
	ok
	if _cZMode_ = "a" and fexists(_cZPath_)
		_hZ_ = fopen(_cZPath_, "rb")
		_cZSig_ = fread(_hZ_, 4)
		fclose(_hZ_)
		if NOT (_cZSig_ = "PK" + char(3) + char(4) or _cZSig_ = "PK" + char(5) + char(6))
			return "the file there is not a zip archive"
		ok
	ok
	return ""

# Gives an absolute path written with forward slashes, with . and .. segments resolved and folded to
# lower case on Windows, so two paths of the same file compare equal.
func _ZipCleanPath(_cZPath_)
	_cZPath_ = StzReplace(_cZPath_, "\", "/")
	_bZAbs_ = 0
	if ring_len(_cZPath_) > 0 and _cZPath_[1] = "/"
		_bZAbs_ = 1
	ok
	if ring_len(_cZPath_) > 1 and _cZPath_[2] = ":"
		_bZAbs_ = 1
	ok
	if _bZAbs_ = 0
		_cZPath_ = StzReplace(currentdir(), "\", "/") + "/" + _cZPath_
	ok
	_aZParts_ = StzSplit(_cZPath_, "/")
	_aZKept_ = []
	_nZParts_ = ring_len(_aZParts_)
	for _nZi_ = 1 to _nZParts_
		_cZPart_ = _aZParts_[_nZi_]
		if _cZPart_ = "" or _cZPart_ = "."
			loop
		ok
		if _cZPart_ = ".."
			if ring_len(_aZKept_) > 0
				del(_aZKept_, ring_len(_aZKept_))
			ok
			loop
		ok
		_aZKept_ + _cZPart_
	next
	_cZOut_ = ""
	_nZKept_ = ring_len(_aZKept_)
	for _nZi_ = 1 to _nZKept_
		if _nZi_ > 1
			_cZOut_ = _cZOut_ + "/"
		ok
		_cZOut_ = _cZOut_ + _aZKept_[_nZi_]
	next
	if ring_len(_cZPath_) > 0 and _cZPath_[1] = "/"
		_cZOut_ = "/" + _cZOut_
	ok
	if isWindows()
		_cZOut_ = lower(_cZOut_)
	ok
	return _cZOut_

# Lists the files under a folder, as names relative to it written with forward slashes and sorted in
# byte order; it raises past the given depth of folders, number of files or number of folders
# (CreateFromDirectory gives 64, 100000 and 100000).
func _ZipWalkFolder(_cZRoot_, _nZMaxDepth_, _nZMaxFiles_, _nZMaxFolders_)
	_aZTodo_ = [ "" ]
	_aZLevel_ = [ 0 ]
	_aZFound_ = []
	_nZFiles_ = 0
	_nZFolders_ = 0
	while ring_len(_aZTodo_) > 0
		_nZTop_ = ring_len(_aZTodo_)
		_cZRel_ = _aZTodo_[_nZTop_]
		_nZDeep_ = _aZLevel_[_nZTop_]
		del(_aZTodo_, _nZTop_)
		del(_aZLevel_, _nZTop_)
		_nZFolders_ = _nZFolders_ + 1
		if _nZFolders_ > _nZMaxFolders_
			StzRaise("The folder tree holds more than " + _nZMaxFolders_ + " folders (a link loop?), nothing archived: " + _cZRoot_)
		ok
		_cZHere_ = _cZRoot_
		_cZPrefix_ = ""
		if _cZRel_ != ""
			_cZHere_ = _cZRoot_ + "/" + _cZRel_
			_cZPrefix_ = _cZRel_ + "/"
		ok
		_aZNames_ = StzEngineDirListFiles(_cZHere_)
		if not isList(_aZNames_)
			StzRaise("Cannot list the folder: " + _cZHere_)
		ok
		_nZNames_ = ring_len(_aZNames_)
		for _nZi_ = 1 to _nZNames_
			if _aZNames_[_nZi_] = "." or _aZNames_[_nZi_] = ".."
				loop
			ok
			_nZFiles_ = _nZFiles_ + 1
			if _nZFiles_ > _nZMaxFiles_
				StzRaise("The folder holds more than " + _nZMaxFiles_ + " files, nothing archived: " + _cZRoot_)
			ok
			_aZFound_ + (_cZPrefix_ + _aZNames_[_nZi_])
		next
		_aZNames_ = StzEngineDirListDirs(_cZHere_)
		if not isList(_aZNames_)
			StzRaise("Cannot list the folder: " + _cZHere_)
		ok
		_nZNames_ = ring_len(_aZNames_)
		for _nZi_ = 1 to _nZNames_
			if _aZNames_[_nZi_] = "." or _aZNames_[_nZi_] = ".."
				loop
			ok
			if (_nZDeep_ + 1) > _nZMaxDepth_
				StzRaise("The folder tree is deeper than " + _nZMaxDepth_ + " levels (a link loop?), nothing archived: " + _cZRoot_)
			ok
			_aZTodo_ + (_cZPrefix_ + _aZNames_[_nZi_])
			_aZLevel_ + (_nZDeep_ + 1)
		next
	end
	return sort(_aZFound_)

# Writes the archive cArchive from entry names and their bytes, through the engine's ZIP
# writer (stz_compress). With pbAppend, the entries already there are kept and a new entry
# replaces an old one of the same name. Raises with the engine's reason when it cannot.
func _ZipWriteEntries(cArchive, paNames, paDatas, pbAppend)
	_nE_ = len(paNames)
	_cNames_ = ""
	_cSizes_ = ""
	_cBlob_ = ""
	for _i_ = 1 to _nE_
		if _i_ > 1
			_cNames_ += char(10)
			_cSizes_ += ","
		ok
		_cNames_ += paNames[_i_]
		_cSizes_ += ("" + len(paDatas[_i_]))
		_cBlob_ += paDatas[_i_]
	next
	_nAppend_ = 0
	if pbAppend
		_nAppend_ = 1
	ok
	if StzEngineZipWrite(cArchive, _cNames_, _cSizes_, _cBlob_, _nAppend_) != 1
		StzRaise("Cannot write the zip file (" + StzEngineZipLastError() + "): " + cArchive)
	ok

# The entries of the files of a list that exist, under the paths as given: [ names, datas ].
func _ZipEntriesOfFiles(paFiles)
	_aN_ = []
	_aD_ = []
	_nF_ = len(paFiles)
	for _i_ = 1 to _nF_
		if StzFileExists(paFiles[_i_])
			_aN_ + paFiles[_i_]
			_aD_ + read(paFiles[_i_])
		ok
	next
	return [ _aN_, _aD_ ]

func ZipFile(cZipFileName)
    return new stzZipFile(cZipFileName)

# Creates, extends, lists and unpacks a zip archive named by a path.
#
# CreateFrom builds an archive from a list of files and AddFile and AddFiles extend an existing one;
# each file is stored under the path as given, so give relative paths. ListContents, FileCount and
# Contains read the entry names, and ExtractTo, ExtractHere and ExtractToNewFolder unpack them.
# CopyTo, MoveTo and Delete act on the archive file itself. CreateFromDirectory zips a whole folder
# and AddString stores a text as an entry. The names of entries are checked: AddString refuses a name
# that could leave the folder it is extracted into, and the extraction methods refuse an archive that
# holds one, writing nothing.
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
    #              is stored as absolute, and ExtractTo refuses such an archive as an unsafe name
    #   see        AddFiles, ExtractTo
    #@ aka  CREATION OPERATIONS
    def CreateFrom(_aFiles_)
        # Create zip from list of files
        if not islist(_aFiles_)
            StzRaise("Files parameter must be a list")
        ok
        
        _cZWhy_ = _ZipArchiveProblem(@cZipFileName, "w")
        if _cZWhy_ != ""
            StzRaise("Cannot write the zip file (" + _cZWhy_ + "): " + @cZipFileName)
        ok
        _aE_ = _ZipEntriesOfFiles(_aFiles_)
        _ZipWriteEntries(@cZipFileName, _aE_[1], _aE_[2], 0)
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
    
    # Creates the archive, replacing any existing one, from every file under a folder and its subfolders.
    #
    # Each file is stored under its path relative to the folder, written with forward slashes and
    # without the folder's own name, so the archive unpacks to the same layout wherever it goes.
    # The entries are sorted in byte order of their names, hidden files are included, and a folder
    # without any file gives an archive without any entry. The archive file itself is left out when
    # it lies inside the folder. Folders are not stored as entries, so an empty subfolder is lost.
    #
    #   _cDirPath_   the folder to zip, which must exist
    #   returns      the archive path
    #   warning      raises Directory does not exist for a missing folder; it raises, before creating
    #                anything, for a file whose name could not be a safe entry name (see AddString:
    #                a backslash, a colon, a control character, over 255 bytes), for a tree deeper
    #                than 64 levels and for more than 100000 folders or 100000 files; the engine lists
    #                a Windows junction or a symbolic link as an ordinary folder, so a link is
    #                followed and a loop through one ends at those limits
    #   see          CreateFrom, AddString
    def CreateFromDirectory(_cDirPath_)
        # Create zip from all files under a directory, with names relative to it
        if not isString(_cDirPath_) or ring_len(ring_trim(_cDirPath_)) = 0
            StzRaise("Directory path must be a non-empty text")
        ok
        if not StzDirExists(_cDirPath_)
            StzRaise("Directory does not exist: " + _cDirPath_)
        ok

        _cRoot_ = StzReplace(_cDirPath_, "\", "/")
        _nRoot_ = ring_len(_cRoot_)
        while _nRoot_ > 1 and _cRoot_[_nRoot_] = "/" and not (_nRoot_ = 3 and _cRoot_[2] = ":")
            _cRoot_ = left(_cRoot_, _nRoot_ - 1)
            _nRoot_ = _nRoot_ - 1
        end

        _aNames_ = _ZipWalkFolder(_cRoot_, 64, 100000, 100000)

        # leave out the archive itself when it lies inside the folder
        _cSelf_ = _ZipCleanPath(@cZipFileName)
        _cUnder_ = _ZipCleanPath(_cRoot_) + "/"
        _cSelfRel_ = ""
        if ring_len(_cSelf_) > ring_len(_cUnder_) and strcmp(left(_cSelf_, ring_len(_cUnder_)), _cUnder_) = 0
            _cSelfRel_ = right(_cSelf_, ring_len(_cSelf_) - ring_len(_cUnder_))
        ok
        _aKept_ = []
        _nNames_ = ring_len(_aNames_)
        for i = 1 to _nNames_
            _cNameLow_ = _aNames_[i]
            if isWindows()
                _cNameLow_ = lower(_cNameLow_)
            ok
            if _cSelfRel_ != "" and strcmp(_cNameLow_, _cSelfRel_) = 0
                loop
            ok
            _cWhy_ = _ZipEntryNameProblem(_aNames_[i])
            if _cWhy_ != ""
                StzRaise("A file cannot be stored under a safe entry name (" + _cWhy_ + "), nothing archived: " + _ZipShowName(_aNames_[i]))
            ok
            _aKept_ + _aNames_[i]
        next

        _cZWhy_ = _ZipArchiveProblem(@cZipFileName, "w")
        if _cZWhy_ != ""
            StzRaise("Cannot write the zip file (" + _cZWhy_ + "): " + @cZipFileName)
        ok
        _aDatas_ = []
        _nKept_ = ring_len(_aKept_)
        for i = 1 to _nKept_
            if not StzFileExists(_cRoot_ + "/" + _aKept_[i])
                StzRaise("Cannot read the file to add: " + _ZipShowName(_aKept_[i]))
            ok
            _aDatas_ + read(_cRoot_ + "/" + _aKept_[i])
        next
        _ZipWriteEntries(@cZipFileName, _aKept_, _aDatas_, 0)
        if not fexists(@cZipFileName)
            StzRaise("Cannot create zip file: " + @cZipFileName)
        ok
        return @cZipFileName

        def CreateFromDirectoryQ(_cDirPath_)
            This.CreateFromDirectory(_cDirPath_)
            return This
    
    # Adds an existing file to the archive; the same file added again replaces its entry.
    #
    #   cFileName   the file to add, stored under the path as given
    #   returns     the archive path
    #   note        use CreateFrom to start an archive
    #   warning     raises File does not exist for a missing file; on an archive that does not exist
    #               yet it creates the archive with this one entry
    #   see         AddFiles, CreateFrom
    #@ aka  MODIFICATION OPERATIONS
    def AddFile(cFileName)
        # Add file to existing zip
        if not StzFileExists(cFileName)
            StzRaise("File does not exist: " + cFileName)
        ok
        
        _cZWhy_ = _ZipArchiveProblem(@cZipFileName, "a")
        if _cZWhy_ != ""
            StzRaise("Cannot write the zip file (" + _cZWhy_ + "): " + @cZipFileName)
        ok
        _ZipWriteEntries(@cZipFileName, [ cFileName ], [ read(cFileName) ], 1)
        return @cZipFileName
    
        def AddFileQ(cFileName)
            This.AddFile(cFileName)
            return This
    
    # Adds the files of a list to the archive, skipping those that do not exist; a file already inside replaces its entry.
    #
    #   _aFiles_   the list of file paths, each stored as given
    #   returns    the archive path
    #   warning    raises Files parameter must be a list for anything else; like AddFile, it creates
    #              the archive when it does not exist yet
    #   see        AddFile, CreateFrom
    def AddFiles(_aFiles_)
        # Add multiple files to existing zip
        if not islist(_aFiles_)
            StzRaise("Files parameter must be a list")
        ok
        
        _cZWhy_ = _ZipArchiveProblem(@cZipFileName, "a")
        if _cZWhy_ != ""
            StzRaise("Cannot write the zip file (" + _cZWhy_ + "): " + @cZipFileName)
        ok
        _aE_ = _ZipEntriesOfFiles(_aFiles_)
        _ZipWriteEntries(@cZipFileName, _aE_[1], _aE_[2], 1)
        return @cZipFileName

        def AddFilesQ(_aFiles_)
            This.AddFiles(_aFiles_)
            return This
    
    # Stores a text as one entry of the archive, byte for byte, creating the archive when it is missing.
    #
    # The text may hold any bytes (UTF-8, NUL, line ends, binary); it is written with its length,
    # never through a file. The entry name is client data and is checked before anything is written:
    # a name that could leave the folder it is extracted into is refused and the archive is untouched.
    # A name is relative and has 1 to 255 bytes. It has no leading slash or drive letter, no
    # backslash, no colon, no NUL or control character, no segment of dots and spaces such as .. or
    # ..., no . segment, no empty segment as in a//b and no trailing slash. Forward slashes make
    # folders: docs/a.txt.
    #
    #   cEntryName   the entry name, a relative path of forward slashes
    #   cContent     the text to store; a number is stored as its text
    #   returns      the archive path
    #   warning      raises Invalid entry name, naming the rule, for a name that breaks one; raises
    #                Content must be a text for a list or an object; a name already in the archive
    #                is replaced, as AddFile does
    #   see          AddFile, CreateFrom, ListContents
    def AddString(cEntryName, cContent)
        # Add string content as file entry
        _cWhy_ = _ZipEntryNameProblem(cEntryName)
        if _cWhy_ = ""
            _nName_ = ring_len(cEntryName)
            if cEntryName[_nName_] = "/"
                _cWhy_ = "the name ends with a slash, which names a folder"
            ok
            _aParts_ = StzSplit(cEntryName, "/")
            _nParts_ = ring_len(_aParts_)
            for i = 1 to _nParts_
                if _cWhy_ = "" and _aParts_[i] = ""
                    _cWhy_ = "the name holds an empty segment"
                ok
                if _cWhy_ = "" and _aParts_[i] = "."
                    _cWhy_ = "the name holds a . segment"
                ok
            next
        ok
        if _cWhy_ != ""
            StzRaise("Invalid entry name (" + _cWhy_ + "): " + _ZipShowName(cEntryName))
        ok
        _cText_ = cContent
        if isNumber(_cText_)
            _cText_ = "" + _cText_
        ok
        if not isString(_cText_)
            StzRaise("Content must be a text")
        ok

        _cMode_ = 'w'
        if fexists(@cZipFileName)
            _cMode_ = 'a'
        ok
        _cZWhy_ = _ZipArchiveProblem(@cZipFileName, _cMode_)
        if _cZWhy_ != ""
            StzRaise("Cannot write the zip file (" + _cZWhy_ + "): " + @cZipFileName)
        ok
        if StzEngineZipWrite(@cZipFileName, cEntryName, "" + ring_len(_cText_), _cText_, 1) != 1
            StzRaise("Cannot store the entry in the zip file (" + StzEngineZipLastError() + "): " + @cZipFileName)
        ok
        return @cZipFileName

        def AddStringQ(cEntryName, cContent)
            This.AddString(cEntryName, cContent)
            return This
    
    # Extracts every entry under a folder, keeping each entry's own relative path, and returns the folder.
    #
    # Every entry name is checked before the first byte is written, with the rules of AddString for a
    # name (an entry ending in a slash is a folder and may). One name that could write outside the
    # folder, such as ../x, /x, C:/x or a name with a backslash, refuses the whole archive: the
    # extraction stops with a message and nothing is written. Once the library has unpacked, each
    # file entry is looked for under the folder, so an entry it could not write is reported.
    #
    #   _cTargetDir_   the folder to extract into, created when missing
    #   returns        the target folder path
    #   note           create the archive with relative paths, as CreateFrom explains
    #   warning        raises Zip file does not exist for a missing archive; raises Unsafe entry name
    #                  in the archive, extracting nothing, for an entry name that breaks a rule (an
    #                  archive made by CreateFrom with absolute paths is refused this way, where it
    #                  once ended the Ring process with exit 127); raises Entry was not extracted,
    #                  with the engine's reason, for an entry it cannot write, such as one whose
    #                  folder name is already taken by a file
    #   see            ExtractHere, ExtractToNewFolder, ListContents
    #@ aka  EXTRACTION OPERATIONS
    def ExtractTo(_cTargetDir_)
        # Extract all files to target directory, after checking every entry name
        if not isString(_cTargetDir_) or ring_len(ring_trim(_cTargetDir_)) = 0
            StzRaise("Target folder must be a non-empty text")
        ok
        if not This.Exists()
            StzRaise("Zip file does not exist: " + @cZipFileName)
        ok

        _aNames_ = This.ListContents()
        _nNames_ = ring_len(_aNames_)
        for i = 1 to _nNames_
            _cWhy_ = _ZipEntryNameProblem(_aNames_[i])
            if _cWhy_ != ""
                StzRaise("Unsafe entry name in the archive (" + _cWhy_ + "), nothing extracted: " + _ZipShowName(_aNames_[i]))
            ok
        next

        if StzEngineZipExtractAll(@cZipFileName, _cTargetDir_) < 0
            StzRaise("Entry was not extracted (" + StzEngineZipLastError() + "): " + @cZipFileName)
        ok

        _cBase_ = StzReplace(_cTargetDir_, "\", "/")
        for i = 1 to _nNames_
            if _aNames_[i][ring_len(_aNames_[i])] != "/"
                if not StzFileExists(_cBase_ + "/" + _aNames_[i])
                    StzRaise("Entry was not extracted: " + _ZipShowName(_aNames_[i]))
                ok
            ok
        next
        return _cTargetDir_

        def ExtractToQ(_cTargetDir_)
            This.ExtractTo(_cTargetDir_)
            return This
    
    # Extracts the archive into the folder that holds it.
    #
    #   returns    the folder path, . when the archive path has none
    #   warning    raises Zip file does not exist for a missing archive; an unsafe entry name refuses
    #              the extraction, as ExtractTo explains
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
    #   warning    raises Zip file does not exist for a missing archive; an unsafe entry name refuses
    #              the extraction, as ExtractTo explains
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
    #   note       a name appears once: adding it again replaces the entry
    #   warning    raises Zip file does not exist for a missing archive
    #   see        FileCount, Contains
    #@ aka  INSPECTION OPERATIONS
    def ListContents()
        # List all files in zip
        if not This.Exists()
            StzRaise("Zip file does not exist: " + @cZipFileName)
        ok
        
        _cNames_ = StzEngineZipNames(@cZipFileName)
        if _cNames_ = "" and StzEngineZipLastError() != ""
            StzRaise("Cannot open zip file (" + StzEngineZipLastError() + "): " + @cZipFileName)
        ok
        if _cNames_ = ""
            return []
        ok
        return str2list(_cNames_)
    
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
        
        _cNames_ = StzEngineZipNames(@cZipFileName)
        if _cNames_ = ""
            return 0
        ok
        return len(str2list(_cNames_))
    
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
    
    # Returns the size of the archive file in bytes, 0 when the archive does not exist.
    #
    #   returns    a number; the byte count of the file, which is what len(read(path)) gives
    #   note       0 also means the archive does not exist
    #   see        FileName, Exists
    def Size()
        if not This.Exists()
            return 0
        ok
        return StzFileSize(@cZipFileName)
    
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
