#======================================#
#  STZFOLDER CLASS - SOFTANZA LIBRARY  #
#======================================#

# DESIGN NOTE: stzFolder Implementation Strategy
#
# This class maintains a "visible files only" abstraction by design:
#
# 1. HIDDEN FILES: Excluded by default to match user expectations
#    - Most users work with visible files/folders only
#    - System/temp files are typically irrelevant to folder operations
#
# 2. IMPLEMENTATION:
#    - Pure Ring path helpers for navigation and path manipulation
#    - Engine bridge for file/folder operations (create, delete, copy)
#    - Ring dir() for file/folder enumeration
#
# 3. CONSISTENCY RULE:
#    Count() = CountFiles() + CountFolders()
#    This ensures Count() matches len(Files()) + len(Folders())
#
# 4. ABSTRACTION LEVEL: High-level, intuitive behavior
#    - Users expect empty folder to show Count()=0, IsEmpty()=true
#    - Technical details (system files) handled internally
#

_nMaxTreeDisplayLevel = 5 #TODO //Move it to stzTree.ring and use it there

func DefaultMaxTreeDisplayLevel()
	return _nMaxTreeDisplayLevel

func SetDefaultMaxTreeDisplayLevel(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok
	_nMaxTreeDisplayLevel = n

#== Global Helper Functions ==#

func CurrentFolder()
	return currentDir()

	func @CurrentFolder()
		return currentDir()

func ParentFolder()
	_oFolder_ = new stzFolder(currentDir())
	_oFolder_.GoUp()
	return _oFolder_.Path()

	func @ParentFolder()
		return ParentFolder()

func ParentParentFolder()
	_oFolder_ = new stzFolder(currentDir())
	_oFolder_.GoUp()
	_oFolder_.GoUp()
	return _oFolder_.Path()

	func @ParentPArentFolder()
		return ParentPArentFolder()

func @ExeFolder()
	return exefolder()

	func ExeDir()
		return exeFolder()

func IsFolder(_cPath_)
	return dirExists(_cPath_)

	#< @FunctionAlternativeForms

	func IsDir(_cPath_)
		return dirExists(_cPath_)

	func @IsFolder(_cPath_)
		return dirExists(_cPath_)

	func @IsDir(_cPath_)
		return dirExists(_cPath_)

	#--

	func IsValidFolder(_cPath_)
		return dirExists(_cPath_)

	func IsValidDir(_cPath_)
		return dirExists(_cPath_)

	func @IsValidFolder(_cPath_)
		return dirExists(_cPath_)

	func @IsValidDir(_cPath_)
		return dirExists(_cPath_)

	#==

	func dirPathExists(_cPath_)
		return dirExists(_cPath_)

	func IsDirPath(_cPath_)
		return dirExists(_cPath_)

	func @IsFolderPath(_cPath_)
		return dirExists(_cPath_)

	func @IsDirPath(_cPath_)
		return dirExists(_cPath_)

	#--

	func IsValidFolderPath(_cPath_)
		return dirExists(_cPath_)

	func IsValidDirPath(_cPath_)
		return dirExists(_cPath_)

	func @IsValidFolderPath(_cPath_)
		return dirExists(_cPath_)

	func @IsValidDirPath(_cPath_)
		return dirExists(_cPath_)

	#>

func StzFolderQ(_cPath_)
	return new stzFolder(_cPath_)

func IsAbsolutePath(_cPath_)
	return cDir = StzFolderQ(_cPath_).AbsolutePath()

func @dir(_cPath_) # Same as Ring dir() but in lowercase
	if CheckParams()
		if NOT ( isString(_cPath_) and _cPath_ != "" )
			StzRaise("Incorrect param type! cPath must be non-empty string.")
		ok
	ok

	#TODO // Add security checks

	# ENGINE-BACKED, and it has to be.
	#
	# Ring's dir() goes through the ANSI code page on Windows, so every byte
	# it cannot map becomes '?'. A folder holding an Arabic and a CJK file
	# listed BOTH of them as "??.txt" -- not merely lossy but ambiguous, and
	# a name taken from that listing no longer joins back onto a path that
	# opens anything. (A delete driven from such a listing then hands the
	# engine a path full of '?' wildcards.)
	#
	# The counts were always right because counting never carries the name
	# back out; only enumeration did. The engine iterates via the wide API
	# and yields UTF-8, which is what the rest of the library speaks.
	#
	# An inaccessible path (permission denied, reparse point, vanished
	# mid-walk) yields an empty list rather than raising -- a deep traversal
	# over a real filesystem WILL hit one, and it must not abort the walk.
	# The engine returns an empty list on open failure, so no guard is
	# needed here; the try/catch that wrapped Ring's raising dir() is gone.

	_aResult_ = []

	# Softanza listing convention: child names are presented in lowercase.
	# Only the ENUMERATED children are folded; the folder's own path keeps
	# its real case. Windows' case-insensitive FS means the folded names
	# still resolve when fed back during a deep walk.
	#
	# Kind codes match Ring's dir(): 0 = file, 1 = folder.

	_aDirFiles_ = StzEngineDirListFiles(_cPath_)
	_nDfLen_ = len(_aDirFiles_)
	for i = 1 to _nDfLen_
		_aResult_ + [ StzLower(_aDirFiles_[i]), 0 ]
	next

	_aDirFolders_ = StzEngineDirListDirs(_cPath_)
	_nDdLen_ = len(_aDirFolders_)
	for i = 1 to _nDdLen_
		_aResult_ + [ StzLower(_aDirFolders_[i]), 1 ]
	next

	return _aResult_

func CreateIfInexistant(_cPath_)
    # Check if it has an extension (likely a file)
    if StzFindFirst(".", _cPath_)
        CreateFileIfInexistant(_cPath_)
    else
        CreateFolderIfInexistant(_cPath_)
    ok

	func CreateFolder(_cPath_)
		CreateIfInexistant(_cPath_)

	func @CreateFolder(_cPath_)
		CreateIfInexistant(_cPath_)

	func @CreateIfInexistant(_cPath_)
		CreateIfInexistant(_cPath_)

func FolderCreateIfInexistant(_cFolderPath_)
    if NOT isdir(_cFolderPath_)
        if isWindows()
            StzSystemSilentXT("cmd.exe", ["/c", "mkdir", _cFolderPath_])
        else
            StzSystemSilentXT("mkdir", ["-p", _cFolderPath_])
        ok
    ok

	func CreateFolderIfInexistant(_cFolderPath_)
		FolderCreateIfInexistant(_cFolderPath_)

	func @FolderCreateIfInexistant(_cFolderPath_)
		 FolderCreateIfInexistant(_cFolderPath_)

	func @CreateFolderIfInexistant(_cFolderPath_)
		FolderCreateIfInexistant(_cFolderPath_)

func RemoveFolderRecursive(_cPath_)
	_aItems_ = dir(_cPath_)
	_nLen_ = len(_aItems_)
	for i = 1 to _nLen_
		_cName_ = _aItems_[i][1]
		if _cName_ = "." or _cName_ = ".." loop ok
		_cFull_ = _cPath_ + "/" + _cName_
		if _aItems_[i][2] = 0
			StzEngineFileDelete(_cFull_)
		else
			RemoveFolderRecursive(_cFull_)
		ok
	next
	return StzEngineDirDelete(_cPath_)

	RemoveFolderXT(_cPath_)
		return This.RemoveFolderRecursive()

# Create a directory path (all missing intermediates) via the Softanza Zig
# engine. The old name QMkdir carried the Qt lineage (Qt's QDir::mkdir);
# Softanza has no Qt dependency, so the Q is gone. (Plain MakeDir is already a
# Ring stdlib name, so the Stz-prefixed StzMakeDir is the Softanza form.)
func StzMakeDir(_cPath_)
	return StzEngineDirCreatePath(_cPath_)

	func mkdir(_cPath_)
		return StzMakeDir(_cPath_)

func NormalizePath(_cPath_)
	if CheckParams()
		if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
			StzRaise("Incorrect param type! cPath must be a non-empty string.")
		ok
	ok
	
	if StzFindFirst(".", _cPath_) > 0
		return NormalizeFilePath(_cPath_)
	else
		return NormalizeFolderPath(_cPath_)
	ok

	func NormalisePath(_cPath_)
		return NormalizePath(_cPath_)

func NormalizePathXT(_cPath_)
	if CheckParams()
		if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
			StzRaise("Incorrect param type! cPath must be a non-empty string.")
		ok
	ok

	# Check if it's a file (has extension) or folder
	if StzFindFirst(".", _cPath_) > 0
		return NormalizeFilePathXT(_cPath_)
	else
		return NormalizeFolderPathXT(_cPath_)
	ok

	func NormalisePathXR(_cPath_)
		return NormalizePathXT(_cPath_)

func NormalizeFolderPath(_cName_)
	_cName_ = NormalizeFilePath(_cName_)
	
	if StzLeft(_cName_, 1) != "/"
		_cName_ = "/" + _cName_
	ok

	if StzRight(_cName_, 1) != "/"
		_cName_ += "/"
	ok

	return StzReplace(_cName_, "//", "/")

	func NormaliseFolderPath(_cName_)
		return NormalizeFolderPath(_cName_)

func NormalizeFolderPathXT(_cName_)
	_cName_ = NormalizeFilePathXT(_cName_)

	if StzRight(_cName_, 1) != "/"
		_cName_ += "/"
	ok

	return StzReplace(_cName_, "//", "/")

	func NormaliseFolderPathXT(_cName_)
		return NormalizeFolderPathXT(_cName_)

#--------------------------#
#  PURE RING PATH HELPERS  #
#--------------------------#

func _CleanPath(_cPath_)
	_cPath_ = StzReplace(_cPath_, "\", "/")
	while StzFindFirst("//", _cPath_) > 0
		_cPath_ = StzReplace(_cPath_, "//", "/")
	end
	if StzLen(_cPath_) > 1 and StzRight(_cPath_, 1) = "/"
		_cPath_ = StzLeft(_cPath_, StzLen(_cPath_) - 1)
	ok
	return _cPath_

func _AbsolutePath(_cPath_)
	_cPath_ = _CleanPath(_cPath_)
	if _IsAbsolutePath(_cPath_)
		return _cPath_
	ok
	return _CleanPath(currentDir() + "/" + _cPath_)

func _IsAbsolutePath(_cPath_)
	if StzLen(_cPath_) = 0 return FALSE ok
	if StzLeft(_cPath_, 1) = "/" return TRUE ok
	if StzLen(_cPath_) >= 2 and isalpha(StzLeft(_cPath_, 1)) and StzMid(_cPath_, 2, 1) = ":"
		return TRUE
	ok
	return FALSE

func _IsRootPath(_cPath_)
	_cPath_ = _CleanPath(_cPath_)
	if _cPath_ = "/" return TRUE ok
	if StzLen(_cPath_) = 2 and isalpha(StzLeft(_cPath_, 1)) and StzRight(_cPath_, 1) = ":"
		return TRUE
	ok
	if StzLen(_cPath_) = 3 and isalpha(StzLeft(_cPath_, 1)) and StzMid(_cPath_, 2, 1) = ":" and StzRight(_cPath_, 1) = "/"
		return TRUE
	ok
	return FALSE

func _DirName(_cPath_)
	_cPath_ = _CleanPath(_cPath_)
	_nPos_ = 0
	for i = StzLen(_cPath_) to 1 step -1
		if _cPath_[i] = "/"
			_nPos_ = i
			exit
		ok
	next
	if _nPos_ > 0
		return StzMid(_cPath_, _nPos_ + 1, StzLen(_cPath_) - _nPos_)
	ok
	return _cPath_

func _ParentPath(_cPath_)
	_cPath_ = _CleanPath(_cPath_)
	_nPos_ = 0
	for i = StzLen(_cPath_) to 1 step -1
		if _cPath_[i] = "/"
			_nPos_ = i
			exit
		ok
	next
	if _nPos_ > 1
		return StzLeft(_cPath_, _nPos_ - 1)
	ok
	if _nPos_ = 1
		return "/"
	ok
	return _cPath_

#-------------#
#  THE CLASS  #
#-------------#

class stzFolder from stzObject

	@cOriginalPath
	@cCurrentPath
	@acPathHistory = []

	@nMaxDisplayLevel = DefaultMaxTreeDisplayLevel()

	@acStatKeywords = [	# must be in lowercase
		"@count",
		"@countfiles", "@countfolders",
		"@deepcountfiles", "@deepcountfolders"
	]

	@cDisplayStatPattern = "@count"

	@cDisplayOrder = :FileFirstAscending

	@bExpand = 0
	@bDeepExpandAll = 0
	@acDeepExpandFolders = []
	@acExpandFolders = []

	@bCollapseAll = 0
	@acCollapseFolders = []

	@acDisplayChars = [
		# Tree glyphs built from raw UTF-8 bytes via char() so the source
		# stays pure-ASCII and cannot be double-encoded by an editor.
		:VerticlalChar = char(226)+char(148)+char(130),
		:VerticalCharTick = char(226)+char(148)+char(156),
		:ClosingChar = char(226)+char(149)+char(176),
		:File = " " + char(240)+char(159)+char(151)+char(139),
		:FileFound = char(240)+char(159)+char(147)+char(132),
		:FolderRoot = char(240)+char(159)+char(151)+char(128),   # U+1F5C0 folder (Show root)
		:FolderRootXT = char(240)+char(159)+char(147)+char(129), # U+1F4C1 folder (ShowXT root)
		:FolderOpened = char(240)+char(159)+char(151)+char(129),
		:FolderOpenedFound = char(240)+char(159)+char(147)+char(130), # U+1F4C2 open folder (may contain matches)
		:FolderClosedEmpty = char(240)+char(159)+char(151)+char(128),
		:FolderClosedFull = char(240)+char(159)+char(150)+char(191),
		:FolderRootSearchSymbol = char(240)+char(159)+char(142)+char(175), # U+1F3AF target
		:FileFoundSymbol = char(240)+char(159)+char(145)+char(137)
	]

	@bBacthMode = FALSE

	#== Initialization ==#

	def init(pcDirPath)

		if CheckParams() and NOT isString(pcDirPath)
			StzRaise("Incorrect param type! pcDirPath must be a string.")
		ok

		@acPathHistory = []

		_cPath_ = ""
		if pcDirPath = "" or pcDirPath = NULL
			_cPath_ = currentDir()
		else
			_cPath_ = _CleanPath(pcDirPath)
		ok

		# A drive/filesystem root (C:, C:/, /) always exists -- _CleanPath
		# strips its trailing slash to "C:", which dirExists() does not
		# recognise, so guard against trying to mkdir the drive itself.
		if NOT dirExists(_cPath_) and NOT _IsRootPath(_cPath_)
			if NOT StzEngineDirCreatePath(_cPath_)
				StzRaise("Cannot create directory: " + _cPath_)
			ok
		ok

		@cOriginalPath = _AbsolutePath(_cPath_)
		@cCurrentPath = @cOriginalPath

	#===============================#
	#  FILE AND FOLDER VALIDATION   #
	#===============================#
	
	def Separator()
		return "/"
	
		#-- @Misspelled

		def Seperator()
			# Was `This.Seprator()` (typo, missing 'a') -- R14 every
			# call. Misspelled alias forwarded to a non-existent
			# misspelling of the canonical Separator.
			return This.Separator()

	def SystemSeparator()
		if isWindows() return "\" ok
		return "/"
	
		def PathSeparator()
			return This.Separator()
	
		#-- @Misspelled

		def SystemSeperator()
			return This.SystemSeparator()

		def PathSeperator()
			return This.Separator()

	def IsInside(_cPath_)
	
	    if NOT ( isString(_cPath_) and _cPath_ != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok
	
		_cMainPath_ = _CleanPath(@cCurrentPath)
		_cAbsolutePath_ = _CleanPath(_AbsolutePath(_cPath_))

		if StzRight(_cMainPath_, 1) != "/"
			_cMainPath_ += "/"
		ok
		if StzRight(_cAbsolutePath_, 1) != "/"
			_cAbsolutePath_ += "/"
		ok

		# Case-insensitive boundary check (Windows/NTFS is case-insensitive,
		# and we no longer lowercase the stored paths).
		_cMainLow_ = StzLower(_cMainPath_)
		_cAbsLow_ = StzLower(_cAbsolutePath_)
		_nMainPathLen_ = Len(_cMainLow_)

		if Len(_cAbsLow_) >= _nMainPathLen_
			if Left(_cAbsLow_, _nMainPathLen_) = _cMainLow_
				if _cAbsLow_ != _cMainLow_
					return True
				ok
			ok
		ok

		return False
	
		def IsPathInside(_cPath_)
			return This.IsInside(_cPath_)
	
		def PathIsInside(_cPath_)
			return This.IsInside(_cPath_)
	
	def IsOutside(_cPath_)
		return NOT This.IsInside(_cPath_)
	
		def IsPathOutside(_cPath_)
			return This.IsOutside(_cPath_)
	
		def PathIsOutside(_cPath_)
			return This.IsOutside(_cPath_)
	
	
	# TRUE if cName (any slash form: "name", "/name", "/name/", or a full
	# path) names a surface entry of aList. Listing entries are "/name" for
	# files and "/name/" for folders, all lowercased; the query may be any
	# case/slash form. Compares the bare basename, case-insensitively, so
	# membership is robust to the slash convention and the lowercase listing.
	def _NameInListCI(_cName_, _aList_)
		_cTarget_ = StzLower(_DirName(_CleanPath(_cName_)))
		_nLen_ = len(_aList_)
		for i = 1 to _nLen_
			if StzLower(_DirName(_CleanPath(_aList_[i]))) = _cTarget_
				return 1
			ok
		next
		return 0

	def IsFile(_cPath_)
	    # Checks if cPath represents a valid existing file within the folder scope
	
	    if NOT ( isString(_cPath_) and _cPath_ != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok
	
	    _cNormalizedPath_ = This.NormalizePathXT(_cPath_)
	
		if This._NameInListCI(_cPath_, This.Files())
			return 1
		else
			return 0
		ok
	
	    def IsValidFile(_cPath_)
	        return This.IsFile(_cPath_)
	
	    def IsExistingFile(_cPath_)
	        return This.IsFile(_cPath_)
	
	def IsFolder(_cPath_)
	    # Checks if cPath represents a valid existing folder within the folder scope
	
	    if NOT ( isString(_cPath_) and _cPath_ != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok
	
		_cPath_ = This.NormalizeFolderPath(_cPath_)
	
		if This._NameInListCI(_cPath_, This.Folders())
			return 1
		else
			return 0
		ok
	
	    def IsValidFolder(_cPath_)
	        return This.IsFolder(_cPath_)
	
	    def IsExistingFolder(_cPath_)
	        return This.IsFolder(_cPath_)
	
	    def IsDirectory(_cPath_)
	        return This.IsFolder(_cPath_)
	
	    def IsValidDirectory(_cPath_)
	        return This.IsFolder(_cPath_)
	
	    def IsExistingDirectory(_cPath_)
	        return This.IsFolder(_cPath_)
	
	def IsPath(_cPath_)
		return This.IsFilePath() or This.IsFolderPath()
	
	def IsFilePath(_cPath_)
		if CHeckParams()
			if NOT (isString(_cPath_) and _cPath_ != "")
				raise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	
		# Check for path injection attempts
		if NOT IsSecurePath(_cPath_)
			raise("Insecure path with potential injection risks!")
		ok
		
		_cPath_ = This.NormaliseFolderPath(_cPath_)
	
		if This._NameInListCI(_cPath_, This.Files())
			return 1
		else
			return 0
		ok

	def IsFolderPath(_cPath_)
		if CHeckParams()
			if NOT (isString(_cPath_) and _cPath_ != "")
				raise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	
		_cPath_ = This.NormaliseFolderPath(_cPath_)
	
		# Check for path injection attempts
		if NOT IsSecurePath(_cPath_)
			raise("Insecure path with potential injection risks!")
		ok
		
		if This._NameInListCI(_cPath_, This.Folders())
			return 1
		else
			return 0
		ok

	def IsDeep(_cPath_)
		if This.IsDeepFile(_cPath_) or This.IsDeepFolder(_cPath_)
			return 1
		else
			return 0
		ok
	
		def IsDeepPath(_cPath_)
			IsDeep(_cPath_)
	
	def IsDeepFile(_cPath_)
		_cPath_ = This.NormalizePath(_cPath_)
		_cSep_ = This.Separator()
	
		if StzRight(_cPath_, 1) = _cSep_ # It's a folder not a file!
			return 0
		ok
	
		if StringNumberOfOccurrence(_cPath_, _cSep_) > 1
			return 1
		else
			return 0
		ok
	
		def IsDeepFilePath(_cPath_)
			return This.IsDeepFile(_cPath_)
	
	def IsDeepFolder(_cPath_)
		_cPath_ = This.NormalizePath(_cPath_)
		_cSep_ = This.Separator()
	
		if StzRight(_cPath_, 1) != _cSep_ # It's a file not a folder!
			return 0
		ok
	
		if StringNumberOfOccurrence(_cPath_, _cSep_) > 2
			return 1
		else
			return 0
		ok
	
		def IsDeepFolderPath(_cPath_)
			return This.IsDeepFolder(_cPath_)

	#--

	def IsFolderEmpty(_cFolderPath_)

		_cFolderName_ = This.NormalizeFolderPath(_cFolderPath_)
		_oTempFolder_ = new stzFolder(_cFolderPath_)
		_bHasFiles_ = _oTempFolder_.CountFiles() > 0
		_bHasFolders_ = _oTempFolder_.CountFolders() > 0

		return (not _bHasFiles_ and not _bHasFolders_)

		def IsEmptyFolder(_cFolderPath_)
			return This.IsFolderEmpty(_cFolderPath_)

	def IsSubfolderOf(cChildPath, cParentFolder)
		# Normalize paths for comparison
		_cNormalizedChild_ = This.NormalizePathXT(cChildPath)
		_cNormalizedParent_ = This.NormalizePathXT(This.Path() + This.Separator() + cParentFolder)
		
		# Check if child path starts with parent path
		return StzLeft(_cNormalizedChild_, StzLen(_cNormalizedParent_)) = _cNormalizedParent_
	
	#---
	
	def Exists(_cPath_)
	    # Checks if cPath exists (file or folder) within the folder scope
	    return This.IsFile(_cPath_) OR This.IsFolder(_cPath_)
	
	    def PathExists(_cPath_)
	        return This.Exists(_cPath_)
	
	    def IsValidPath(_cPath_)
	        return This.Exists(_cPath_)
	
		def ContainsPath(_cPath_)
			return This.Exists(_cPath_)
	
	def FileExists(cFileName)
	    # Alias for IsFile - checks if file exists
	    return This.IsFile(cFileName)
	
	def FolderExists(_cFolderName_)
	    # Alias for IsFolder - checks if folder exists  
	    return This.IsFolder(_cFolderName_)
	
	#--

	def DeepExists(_cPath_)
		return This.IsDeepFile(_cPath_) OR This.IsDeepFolder(_cPath_)

	    def PathDeepExists(_cPath_)
	        return This.DeepExists(_cPath_)
	
	    def IsValidDeepPath(_cPath_)
	        return This.DeepExists(_cPath_)
	
		def ContainsDeepPath(_cPath_)
			return This.DeepExists(_cPath_)

	def DeepFileExists(cFileName)
	    # Alias for IsFile - checks if file exists
	    return This.IsDeepFile(cFileName)
	
	def DeepFolderExists(_cFolderName_)
	    # Alias for IsFolder - checks if folder exists  
	    return This.IsDeepFolder(_cFolderName_)

	#=====================#
	#  NORMALIZING PATHS  #
	#=====================#
	
	def NormalizePath(_cPath_)
	
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		if This.IsFilePath(_cPath_)
			return This.NormalizeFilePath(_cPath_)
		else
			return This.NormalizeFolderPath(_cPath_)
		ok


		def NormalisePath(_cPath_)
			return THis.NormalizePath(_cPath_)
	
	def NormalizePathXT(_cPath_)
	
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	   
		if This.IsFilePath(_cPath_)
			return This.NormalizeFilePathXT(_cPath_)
		else
			return This.NormalizeFolderPathXT(_cPath_)
		ok


		def NormalisePathXT(_cPath_)
			return This.NormalizeXT(_cPath_)
	
	def NormalizeFilePath(_cName_)
		if CheckParams()
			if NOT ( isString(_cName_) and trim(_cName_) != "" )
				StzRaise("Incorrect param type! cName must be a non-empty string.")
			ok
		ok
	    
	    # Preserve the real filesystem case AND drive letter -- only
	    # normalise separators. (The old code did "/" + StzLower(...), which
	    # lowercased names like "Docs"->"docs" and turned "D:/x" into
	    # "/d:/x", breaking IsInside boundary checks and the tree display.
	    # Case-insensitive matching is done at the comparison sites.)
	    _cResult_ = _CleanPath(trim(_cName_))
		_cResult_ = StzReplace(_cResult_, "//", "/")
		return _cResult_

		def NormaliseFilePath(_cName_)
			return This.NormalizeFilePath(_cName_)
	
	def NormalizeFilePathXT(_cName_)
		if CheckParams()
			if NOT ( isString(_cName_) and trim(_cName_) != "" )
				StzRaise("Incorrect param type! cName must be a non-empty string.")
			ok
		ok
	    
	    _cBasePath_ = @cCurrentPath
	    _cCleanName_ = _CleanPath(trim(_cName_))
	    
	    # If not absolute, make it relative to base path
	    if NOT _IsAbsolutePath(_cCleanName_)
	        _cCleanName_ = _CleanPath(_cBasePath_ + "/" + _cCleanName_)
	    ok
	    
	    # A FILE path must NOT end with a separator -- appending one here (the
	    # old behaviour) produced ".../test.txt/", so @FileCreate/@FileDelete/
	    # read/write/size/copy all operated on a malformed path and silently
	    # did nothing. The folder variant (NormalizeFolderPathXT) adds its own
	    # trailing separator on top of this, so it is unaffected.
	    _cResult_ = _CleanPath(_cCleanName_)   # preserve case (was StzLower)
		_cResult_ = StzReplace(_cResult_, "//", "/")
		return _cResult_

		def NormaliseFilePathXT(_cName_)
			return This.NormalizeFilePathXT(_cName_)
	
	def NormalizeFolderPath(_cName_)

	    _cName_ = This.NormalizeFilePath(_cName_)
	    _cSeparator_ = This.Separator()

		# (Removed a forced leading separator here -- it turned Windows
		# drive paths "D:/x" into "/D:/x". Only the trailing separator
		# matters for folder semantics.)
	    if StzRight(_cName_, 1) != _cSeparator_
	        _cName_ += _cSeparator_
	    ok

		_cName_ = StzReplace(_cName_, "//", "/")
	    return _cName_
	
		def NormaliseFolderPath(_cName_)
			return This.NormalizeFolderPath(_cName_)
	
	def NormalizeFolderPathXT(_cName_)
	    _cName_ = This.NormalizeFilePathXT(_cName_)
	    _cSeparator_ = This.Separator()

	    if StzRight(_cName_, 1) != _cSeparator_
	        _cName_ += _cSeparator_
	    ok

		_cName_ = StzReplace(_cName_, "//", "/")
	    return _cName_

		def NormaliseFolderPathXT(_cName_)
			return This.NormalizeFolderPathXT(_cName_)

	# Listing-form normalisers: produce the exact shape the Files()/Folders()
	# listings use -- "/name" for a file, "/name/" for a folder -- with the
	# child name lowercased (the listing convention). Handy for building a
	# value to match against those listings.
	def NormalizeFileName(_cName_)
		if NOT ( isString(_cName_) and trim(_cName_) != "" )
			StzRaise("Incorrect param type! cName must be a non-empty string.")
		ok
		return "/" + StzLower(_DirName(_CleanPath(trim(_cName_))))

		def NormaliseFileName(_cName_)
			return This.NormalizeFileName(_cName_)

	def NormalizeFolderName(_cName_)
		if NOT ( isString(_cName_) and trim(_cName_) != "" )
			StzRaise("Incorrect param type! cName must be a non-empty string.")
		ok
		return "/" + StzLower(_DirName(_CleanPath(trim(_cName_)))) + "/"

		def NormaliseFolderName(_cName_)
			return This.NormalizeFolderName(_cName_)

	#==========================#
	#  DETAILED PATH ANALYSIS  #
	#==========================#
	
	def PathType(_cPath_)
	
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	
	    # Returns the type of path: "file", "folder", or "none"
	
	    if This.IsFile(_cPath_)
	        return "file"
	
	    but This.IsFolder(_cPath_)
	        return "folder"
	
	    else
	        return "none"
	    ok
	
	
	def PathInfo(_cPath_)
	
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	    
	    _cNormalizedPath_ = This.NormalizePath(_cPath_)
	
		# Ensire the provided path exists in the folder
	
		if NOT This.Exists(_cNormalizedPath_)
			raise("Incorrect path!")
		ok
	
		# Doing the job
	
	    _cType_ = This.PathType(_cNormalizedPath_)
	    _bExists_ = (_cType_ != "none")
	    
	    _aInfo_ = [
	        :path, _cPath_,
	        :normalized_path, _cNormalizedPath_,
	        :exists, _bExists_,
	        :type, _cType_,
	        :is_file, (_cType_ = "file"),
	        :is_folder, (_cType_ = "folder"),
	        :is_relative, (StzLeft(_cPath_, 1) != This.Separator() AND StzFindFirst(":/", _cPath_) = 0 AND StzFindFirst(":\\", _cPath_) = 0),
	        :parent_folder, This.ParentFolder(_cPath_)
	    ]
	    
	    return _aInfo_
	
	def ParentFolder(_cPath_)
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	
	    _cNormalizedPath_ = This.NormalizePath(_cPath_)
	
		# Ensire the provided path exists in the folder
	
		if NOT This.Exists(_cNormalizedPath_)
			raise("Incorrect path!")
		ok
	
	    # Find last separator
	
	    _nLastSep_ = 0
	    for i = StzLen(_cNormalizedPath_) to 1 step -1
	        if _cNormalizedPath_[i] = This.Separator()
	            _nLastSep_ = i
	            exit
	        ok
	    next

	    if _nLastSep_ > 0
	        return StzLeft(_cNormalizedPath_, _nLastSep_ - 1)
	    else
	        return @cCurrentPath
	    ok
	

	    def ParentDir()
		return This.PArentFolder()

	#============================#
	#  BATCH VALIDATION METHODS  #
	#============================#
	
	def AreFiles(acPaths)
	
	    # Checks if all paths in the list are valid files
	
		if CheckParams()
			if NOT ( isList(acPaths) and IsListOfstrings(acPaths) )
				StzRaise("Incorrect param type! cFolderName must be a list of strings.")
			ok
		ok
	    
		_nLen_ = len(acPaths)

		for i = 1 to _nLen_
	        if NOT This.IsFile(acPaths[i])
	            return FALSE
	        ok
	    next
	    
	    return TRUE
	
	def AreFolders(acPaths)
	
	    # Checks if all paths in the list are valid folders
	
		if CheckParams()
			if NOT ( isList(acPaths) and IsListOfstrings(acPaths) )
				StzRaise("Incorrect param type! cFolderName must be a list of strings.")
			ok
		ok
	    
		_nLen_ = len(acPaths)

		for i = 1 to _nLen_
	        if NOT This.IsFolder(acPaths[i])
	            return FALSE
	        ok
	    next
	    
	    return TRUE
	
	def AllExist(acPaths)
	
	    # Checks if all paths in the list exist (files or folders)
	
		if CheckParams()
			if NOT ( isList(acPaths) and IsListOfstrings(acPaths) )
				StzRaise("Incorrect param type! cFolderName must be a list of strings.")
			ok
		ok
	    
		_nLen_ = len(acPaths)

		for i = 1 to _nLen_
	        if NOT This.Exists(acPaths[i])
	            return FALSE
	        ok
	    next
	    
	    return TRUE
	
	def ExistingPathsAmong(acPaths)
	
	    # Returns only the paths that exist from the given list
	
		if CheckParams()
			if NOT ( isList(acPaths) and IsListOfstrings(acPaths) )
				StzRaise("Incorrect param type! cFolderName must be a list of strings.")
			ok
		ok
	    
	    _acResult_ = []
	
		_nLen_ = len(acPaths)

		for i = 1 to _nLen_
	        if This.Exists(acPaths[i])
	            _acResult_ + _cPath_
	        ok
	    next
	    
	    return _acResult_
	
	
	def MissingPathsAmong(acPaths)
	
	    # Returns only the paths that don't exist from the given list
	
		if CheckParams()
			if NOT ( isList(acPaths) and IsListOfstrings(acPaths) )
				StzRaise("Incorrect param type! cFolderName must be a list of strings.")
			ok
		ok
	    
	    _acMissing_ = []
		_nLen_ = len(acPaths)

		for i = 1 to _nLen_
	        if NOT This.Exists(acPaths[i])
	            _acMissing_ + _cPath_
	        ok
	    next
	    
	    return _acMissing_

	#======================#
	#  Folder Information  #
	#======================#

	def Name()
		return _DirName(@cCurrentPath)

	def Path()
		return @cCurrentPath

	def AbsolutePath()
		return @cCurrentPath

		def FullPath()
			return This.AbsolutePath()

	def IsReadable()
		return dirExists(@cCurrentPath)

	def IsRoot()
		return _IsRootPath(@cCurrentPath)

	def IsAbsolute()
		return _IsAbsolutePath(@cCurrentPath)

	def Root()
		return @cOriginalPath

		def RootPath()
			return @cOriginalPath

		def Home()
			return @cOriginalPath

		def HomePath()
			return @cOriginalPath

		def Folder()
			return @cOriginalPath

	def RootXT()
		return This.AbsolutePath()

		def RootPathXT()
			return This.AbsolutePath()

		def HomeXT()
			return This.AbsolutePath()

		def HomePathXT()
			return This.AbsolutePath()

		def FolderXT()
			return This.AbsolutePath()

	def Info()

		_aInfo_ = [
			:Name = This.Name(),
			:Path = This.Path(),
			:AbsolutePath = This.AbsolutePath(),
			:Count = This.Count(),
			:Files = This.CountFiles(),
			:Folders = This.CountFolders(),
			:IsEmpty = This.IsEmpty(),
			:IsReadable = This.IsReadable(),
			:IsRoot = This.IsRoot()
		]

		return _aInfo_

	#=====================#
	#  Content Management #
	#=====================#

	def Count()
		return This.CountFiles() + This.CountFolders()

		def Size()
			return This.Count()

	def IsEmpty()
		return This.Count() = 0

		def Empty()
			return This.IsEmpty()

	#--

	def FilesXT()

		_aList_ = @dir(@cCurrentPath)
		_aResult_ = []

		_nLen_ = len(_aList_)

		for i = 1 to _nLen_
			if _aList_[i][2] = 0
				_aResult_ + (@cCurrentPath + This.Separator() + _aList_[i][1])
			end
		next

		return _aResult_

	def FoldersXT()

		_aList_ = @dir(@cCurrentPath)
		_aResult_ = []

		_nLen_ = len(_aList_)

		for i = 1 to _nLen_
			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				_aResult_ + (@cCurrentPath + This.Separator() + _aList_[i][1] + This.Separator())
			end
		next

		return _aResult_

	def Files()

		_aList_ = @dir(@cCurrentPath)
		_aResult_ = []

		_nLen_ = len(_aList_)

		for i = 1 to _nLen_
			if _aList_[i][2] = 0
				_aResult_ + (This.Separator() + _aList_[i][1])
			end
		next

		return _aResult_

	def Folders()

		_aList_ = @dir(@cCurrentPath)
		_aResult_ = []

		_nLen_ = len(_aList_)

		for i = 1 to _nLen_
			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _alist_[i][1] != ".."
				_aResult_ + (This.Separator() + _aList_[i][1] + This.Separator())
			end
		next

		return _aResult_

		def Dirs()
			return This.Folders()

	def CountFiles()
		return len(This.Files())

		def NumberOfFiles()
			return len(This.Files())

		def HowManyFiles()
			return len(This.Files())

	def CountFile(cFileName)
		return len(This.FindFile(cFileName))

	def CountFolders()
		return len(This.Folders())

		def CountDirs()
			return This.CountFolders()

	def CountFolder(_cFolderName_)
		return len(This.FindFolder(_cFolderName_))

	#---

	def Contains(_cName_)
		if CheckParams()
			if NOT ( isString(_cName_) and trim(_cName_) != "" )
				StzRaise("Incorrect param type! cName must be a non-empty string.")
			ok
		ok

		_aFiles_ = This.Files()
		_aFolders_ = This.Folders()

		return This._NameInListCI(_cName_, _aFiles_) or This._NameInListCI(_cName_, _aFolders_)


		def Has(_cName_)
			return This.Contains(_cName_)

		def ContainsFileOrFolder(_cName_)
			return This.Contains(_cName_)

		def ContainsFolderOrFile(_cName_)
			return This.Contains(_cName_)


	def ContainsFile(cFileName)
		if CheckParams()
			if NOT ( isString(cFileName) and trim(cFileName) != "" )
				StzRaise("Incorrect param type! cFileName must be a non-empty string.")
			ok
		ok

		return This._NameInListCI(cFileName, This.Files())

	def ContainsFolder(_cFolderName_)
		if CheckParams()
			if NOT ( isString(_cFolderName_) and trim(_cFolderName_) != "" )
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok
		ok

		return This._NameInListCI(_cFolderName_, This.Folders())

		def ContainsDir(_cFolderName_)
			return This.ContainsFolder(_cFolderName_)

	def ContainsFiles()
		return This.CountFiles() > 0

		def HasFiles()
			return This.ContainsFiles()

	def ContainsFolders()
		return This.CountFolders() > 0

		def HasFolders()
			return This.ContainsFolders()

		def HasDirs()
			return This.ContainsFolders()

		def ContainsDirs()
			return This.ContainsFolders()

	#--

	def FilesIn(_cPath_)

		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		if NOT This.Exists(_cPath_)
			StzRaise("Incorrect path!")
		ok

		_acList_ = @dir(_cPath_)
		_nLen_ = len(_acList_)

		_acResult_ = []

		for i = 1 to _nLen_
			if This.IsFile(_acList_[i])
				_acResult_ + _acList_[i]
			ok
		next

		return _acResult_


	def FoldersIn(_cPath_)

		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		if NOT This.Exists(_cPath_)
			StzRaise("Incorrect path!")
		ok

		_acList_ = @dir(_cPath_)
		_nLen_ = len(_acList_)

		_acResult_ = []

		for i = 1 to _nLen_
			if This.IsFolder(_acList_[i])
				_acResult_ + _acList_[i]
			ok
		next

		return _acResult_

	#===========================#
	#  Deep Content Management  #
	#===========================#

	def DeepCountFiles()
		return len(This.DeepFiles())

		def NumberOfDeepFiles()
			return len(This.DeepFiles())

		def HowManyDeepFiles()
			return len(This.DeepFiles())

	def DeepCountFile(cFileName)
		return len(This.DeepFindFile(cFileName))

	def DeepCountFolders()
		return len(This.DeepFolders())

		def DeepCountDirs()
			return This.DeepCountFolders()

	def DeepCountFolder(_cFolderName_)
		return len(This.DeepFindFolder(_cFolderName_))

	def DeepFiles() # With simplified paths

		_aResult_ = []
		_aToProcess_ = [@cCurrentPath]
		_cBasePath_ = @cCurrentPath
		
		while len(_aToProcess_) > 0

			_cCurrentPath_ = _aToProcess_[1]
			del(_aToProcess_, 1)
			
			_aList_ = @dir(_cCurrentPath_)

			_nLen_ = len(_aList_)
	
			for i = 1 to _nLen_

				if _aList_[i][2] = 0  # It's a file

					_cFullPath_ = _cCurrentPath_ + This.Separator() + _aList_[i][1]
					_cRelativePath_ = StzMid(_cFullPath_, StzLen(_cBasePath_) + 1, StzLen(_cFullPath_) - StzLen(_cBasePath_))

					if StzLeft(_cRelativePath_, 1) != This.Separator()
						_cRelativePath_ = This.Separator() + _cRelativePath_
					end

					_aResult_ + _cRelativePath_

				but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # It's a directory
					_aToProcess_ + (_cCurrentPath_ + This.Separator() + _aList_[i][1])
				end

			next

		end
		
		return _aResult_
	
	def DeepFolders() # With simplified paths

		_aResult_ = []
		_aToProcess_ = [@cCurrentPath]
		_cBasePath_ = @cCurrentPath
		
		while len(_aToProcess_) > 0

			_cCurrentPath_ = _aToProcess_[1]
			del(_aToProcess_, 1)
			
			_aList_ = @dir(_cCurrentPath_)

			_nLen_ = len(_aList_)
	
			for i = 1 to _nLen_

				if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # It's a directory

					_cFullPath_ = _cCurrentPath_ + This.Separator() + _aList_[i][1]
					_cRelativePath_ = StzMid(_cFullPath_, StzLen(_cBasePath_) + 1, StzLen(_cFullPath_) - StzLen(_cBasePath_))

					if StzLeft(_cRelativePath_, 1) != This.Separator()
						_cRelativePath_ = This.Separator() + _cRelativePath_
					end

					_aResult_ + (_cRelativePath_ + This.Separator())
					_aToProcess_ + (_cCurrentPath_ + This.Separator() + _aList_[i][1])
				end

			next
		end
		
		return _aResult_

	def DeepFilesXT() # With complete long paths

		_aResult_ = []
		_aToProcess_ = [@cCurrentPath]
		
		while len(_aToProcess_) > 0

			_cCurrentPath_ = _aToProcess_[1]
			del(_aToProcess_, 1)
			
			_aList_ = @dir(_cCurrentPath_)

			_nLen_ = len(_aList_)
	
			for i = 1 to _nLen_

				if _aList_[i][2] = 0  # It's a file
					_aResult_ + (_cCurrentPath_ + This.Separator() + _aList_[i][1])

				but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # It's a directory
					_aToProcess_ + (_cCurrentPath_ + This.Separator() + _aList_[i][1])
				end

			next

		end

		return _aResult_


	def DeepFoldersXT() # With complete long paths

		_aResult_ = []
		_aToProcess_ = [@cCurrentPath]
		
		while len(_aToProcess_) > 0

			_cCurrentPath_ = _aToProcess_[1]
			del(_aToProcess_, 1)
			
			_aList_ = @dir(_cCurrentPath_)

			_nLen_ = len(_aList_)
	
			for i = 1 to _nLen_

				if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # It's a directory

					_cFullPath_ = _cCurrentPath_ + This.Separator() + _aList_[i][1] + This.Separator()
					_aResult_ + _cFullPath_
					_aToProcess_ + (_cCurrentPath_ + This.Separator() + _aList_[i][1])

				end

			next
		end
		
		return _aResult_

	def DeepCount()
		return This.DeepCountFiles() + This.DeepCountFolders()

		def DeepCountFilesAndFolders()
			return This.DeepCount()

		def DeepCountFoldersAndFiles()
			return This.DeepCount()

	def DeepCountFileIn(cFileName, _cPath_)
		return len(This.FindFileIn(cFileName, _cPath_))

	def DeepCountTheseFiles(acFilesNames)
		return len(This.DeepCountTheseFilesIn(acFilesNames, _cPath_))

	def DeepCountTheseFilesIn(acFilesNames, _cPath_)
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok

			if NOT ( isList(acFilesNames) and @IsListOfStrings(acFilesNames) )
				StzRaise("Incorrect param type! acFilesNames must be a list of strings.")
			ok
		ok

		return len(This.SearchTheseFilesIn(acFilesNames, _cPath_))

	def DeepCountFilesIn(_cPath_)
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		_nCount_ = 0
		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)

		for i = 1 to _nLen_

			if _aList_[i][2] = 0
				_nCount_++
			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				_nCount_ += This.DeepCountFilesIn(_cPath_ + This.Separator() + _aList_[i][1])
			end

		next

		return _nCount_


	def DeepCountFilesWithProgress(_cPath_, nCurrentLevel, nMaxLevel)
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		if nCurrentLevel > nMaxLevel
			return 0
		ok

		_nCount_ = 0
		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)

		for i = 1 to _nLen_

			if _aList_[i][2] = 0
				_nCount_++

			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				_nCount_ += This.DeepCountFilesWithProgress(_cPath_ + This.Separator() + _aList_[i][1], nCurrentLevel + 1, nMaxLevel)
			ok

		next

		return _nCount_


	def DeepCountFolderIn(_cFolderName_, _cPath_)
		if CheckParams()
			if NOT ( isString(_cFolderName_) and trim(_cFolderName_) != "" )
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok

			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		return len(This.FindFolderIn(_cFolderName_, _cPath_))

	def DeepCountTheseFoldersIn(acFoldersNames, _cPath_)
		return len(This.SearchTheseFoldersIn(acFoldersNames, _cPath_))

	def DeepCountFoldersIn(_cPath_)
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		_nCount_ = 0
		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)

		for i = 1 to _nLen_

			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				_nCount_++
				_nCount_ += This.DeepCountFoldersIn(_cPath_ + This.Separator() + _aList_[i][1])
			end

		next

		return _nCount_


	def DeepContains(_cName_)

		if This.DeepContainsFileIn(_cName_, This.Path()) or This.DeepContainsFolderIn(_cName_, This.Path())
			return TRUE
		else
			return FALSE
		ok

		def DeepContainsFileOrFolder(_cName_)
			return This.DeepContains(_cName_)

		def DeepContainsFolderOrFile(_cName_)
			return This.DeepContains(_cName_)

	def DeepContainsIn(_cName_, _cPath_)

		if This.DeepContainsFileIn(_cName_, _cPath_) or This.DeepContainsFolderIn(_cName_,_cPath_)
			return TRUE
		else
			return FALSE
		ok

		def DeepContainsFileOrFolderIn(_cName_, _cPath_)
			return This.DeepContainsIn(_cName_, _cPath_)

		def DeepContainsFolderOrFileIn(_cName_, _cPath_)
			return This.DeepContainsIn(_cName_, _cPath_)

	def DeepContainsFile(cFileName)
		return This.DeepContainsFileIn(cFileName, This.Path())

	def DeepContainsFileIn(cFileName, _cPath_)

		if CheckParams()
			if NOT ( isString(cFileName) and trim(cFileName) != "" )
				StzRaise("Incorrect param type! cFileName must be a non-empty string.")
			ok

			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)

		for i = 1 to _nLen_

			if _aList_[i][2] = 0 and _aList_[i][1] = cFileName
				return TRUE

			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."

				if This.DeepContainsFileIn(cFileName, _cPath_ + This.Separator() + _aList_[i][1])
					return TRUE
				end

			end

		next

		return FALSE

	def DeepContainsTheseFiles(acFilesNames)
		return This.DeepContainsTheseFilesIn(acFilesNames, This.Path())

	def DeepContainsTheseFilesIn(acFilesNames, _cPath_)

		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok

			if NOT ( isList(acFilesNames) and @IsListOfStrings(acFilesNames) )
				StzRaise("Incorrect param type! acFilesNames must be a list of strings.")
			ok
		ok

		_nLen_ = len(acFilesNames)
		_bResult_ = TRUE

		for i = 1 to _nLen_

			if NOT This.DeepContainsFileIn(acFilesNames[i], _cPath_)
				_bResult_ = FALSE
				exit
			ok

		next

		return _bResult_

	def DeepContainsOneOfTheseFiles(acFilesNames)
		return This.DeepContainsTheseFilesIn(acFilesNames, This.Path())


	def DeepContainsOneOfTheseFilesIn(acFilesNames, _cPath_)

		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok

			if NOT ( isList(acFilesNames) and @IsListOfStrings(acFilesNames) )
				StzRaise("Incorrect param type! acFilesNames must be a list of strings.")
			ok
		ok

		_nLen_ = len(acFilesNames)
		_bResult_ = FALSE

		for i = 1 to _nLen_

			if This.DeepContainsFileIn(acFilesNames[i], _cPath_)
				_bResult_ = TRUE
				exit
			ok

		next

		return _bResult_

	def DeepContainsFolder(_cFolderName_)
		return This.DeepContainsFolderIn(_cFolderName_, This.Path())


	def DeepContainsFolderIn(_cFolderName_, _cPath_)

		if CheckParams()
			if NOT ( isString(_cFolderName_) and trim(_cFolderName_) != "" )
				StzRaise("Incorrect param type! cFolderNAme must be a non-empty string.")
			ok

			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)

		for i = 1 to _nLen_

			if _aList_[i][2] = 1 and _aList_[i][1] = _cFolderName_
				return TRUE

			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."

				if This.DeepContainsFolderIn(_cFolderName_, _cPath_ + This.Separator() + _aList_[i][1])
					return TRUE
				end

			end

		next

		return FALSE

	def DeepContainsTheseFolders(acFoldersNames)
		return This.DeepContainsTheseFoldersIn(acFoldersNames, This.Path())

	def DeepContainsTheseFoldersIn(acFoldersNames, _cPath_)

		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok

			if NOT ( isList(acFoldersNames) and @IsListOfStrings(acFoldersNames) )
				StzRaise("Incorrect param type! acFoldersNames must be a list of strings.")
			ok
		ok

		_nLen_ = len(acFoldersNames)
		_bResult_ = TRUE

		for i = 1 to _nLen_

			if NOT This.DeepContainsFolderIn(acFoldersNames[i], _cPath_)
				_bResult_ = FALSE
				exit
			ok

		next

		return _bResult_

	def DeepContainsOneOfTheseFolders(acFoldersNames)
		return This.DeepContainsTheseFoldersIn(acFoldersNames, This.Path())

	def DeepContainsOneOfTheseFoldersIn(acFoldersNames, _cPath_)

		if CheckParams()
			if NOT ( isList(acFoldersNames) and @IsListOfStrings(acFoldersNames) )
				StzRaise("Incorrect param type! acFoldersNames must be a list of strings.")
			ok
		ok

		_nLen_ = len(acFoldersNames)
		_bResult_ = FALSE

		for i = 1 to _nLen_

			if This.DeepContainsFolderIn(acFoldersNames[i], _cPath_)
				_bResult_ = TRUE
				exit
			ok

		next

		return _bResult_

	#==============#
	#  Navigation  #
	#==============#

	def IsBatchMode()
		return @bBacthMode

	def SetBatchMode(b)

		if CheckParams()
			if NOt (isNumber(b) and (b=1 or b=0))
				StzRaise("Incorrect param type! b must be a boolean.")
			ok
		ok

		@bBacthMode = b

	def CurrentPath()
		# Presented WITH a trailing separator, per the navigation design
		# ("/my-project/"). This also makes relative joins like
		# CurrentPath() + "docs" produce a correct ".../docs".
		if @cCurrentPath != "" and StzRight(@cCurrentPath, 1) != "/"
			return @cCurrentPath + "/"
		ok
		return @cCurrentPath

		def WorkingDirectory()
			return This.CurrentPath()

		def pwd()  # Unix-style "print working directory"
			return This.CurrentPath()

	def GoTo(_cPath_)
		if CheckParams()
			if NOT (isString(_cPath_) and _cPath_ != "")
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		_cFullPath_ = This.NormalizeFolderPathXT(_cPath_)
		if This.IsOutside(_cFullPath_)
			StzRaise("Can't navigate outside the folder!")
		ok

		# Save current path to history before changing
		@acPathHistory + @cCurrentPath
		
		@cCurrentPath = _cFullPath_
		
		return TRUE

		def MoveTo(cDir)
			return This.GoTo(cDir)

		def cd(cDir)
			return This.GoTo(cDir)

	def GoUp()
		if This.IsRoot()
			raise("Already at root - cannot go up further.")
		end

		# Save current path before going up
		@acPathHistory + @cCurrentPath
		
		@cCurrentPath = _ParentPath(@cCurrentPath)
	
		return TRUE

		def Up()
			return This.GoUp()

		def cdUp()
			return This.GoUp()

	def GoHome()
		# Save current path before going home
		@acPathHistory + @cCurrentPath
		
		@cCurrentPath = @cOriginalPath
		
		return TRUE

		def GoToHome()
			return This.GoHome()

		def GoToRoot()
			return This.GoHome()

		def GoRoot()
			return This.GoHome()

	def GoBack()
		if len(@acPathHistory) = 0
			raise("No previous location in history!")
		end
		
		_cPreviousPath_ = @acPathHistory[len(@acPathHistory)]
		del(@acPathHistory, len(@acPathHistory))  # Remove last item
		
		@cCurrentPath = _cPreviousPath_
		
		return TRUE

		def Back()
			return This.GoBack()

		def Previous()
			return This.GoBack()

	def PathHistory()
		return @acPathHistory

		def NavigationHistory()
			return This.PathHistory()

	def ClearHistory()
		@acPathHistory = []

	def IsAtHome()
		return @cCurrentPath = @cOriginalPath

		def IsAtRoot()
			return This.IsAtHome()

	def RelativePathFromHome()
		if This.IsAtHome()
			return "."
		end
		
		# Calculate relative path from home to current
		return This.GetRelativePath(@cOriginalPath, @cCurrentPath)

	def DistanceFromHome()
		# Return number of directory levels from home
		_cRelPath_ = This.RelativePathFromHome()
		if _cRelPath_ = "."
			return 0
		end
		
		return len(split(_cRelPath_, This.Separator()))

	def NavigationInfo()
		return [
			:Home = @cOriginalPath,
			:Current = @cCurrentPath,
			:RelativeFromHome = This.RelativePathFromHome(),
			:DistanceFromHome = This.DistanceFromHome(),
			:History = @acPathHistory
		]

	#=====================#
	#  Folder Operations  #
	#=====================#

	# Q-convention: CreateFolderQ() returns the new stzFolder OBJECT (keep
	# working with it / block form); the bare CreateFolder() performs the
	# action and returns TRUE/FALSE. Both navigate into the new folder
	# (location-follows-action) unless batch mode is on.
	def CreateFolderQ(pcPath)

	    if CheckParams()
	        if NOT (isString(pcPath) and pcPath != "")
	            raise("Incorrect param type! pcPath must be a non-empty string.")
	        ok
	    end

	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(pcPath)
	        pcPath = This.CurrentPath() + pcPath
	    ok

	    _cPath_ = This.NormalizeFolderPath(pcPath)

	    if NOT This.IsInside(_cPath_)
	        raise("Can't navigate outside the folder!")
	    ok

	    # Create the folder first
	    StzEngineDirCreatePath(_cPath_)

	    # Then navigate there (intelligent navigation)
	    if not this.IsBatchMode()
	        This.GoTo(_cPath_)
	    ok

	    return new stzFolder(_cPath_)

	def CreateFolder(pcPath)
	    This.CreateFolderQ(pcPath)
	    return TRUE

		def FolderCreate(pcPath)
			return This.CreateFolder(pcPath)

		def MakeFolder(pcPath)
			return This.CreateFolder(pcPath)

	# Create several sub-folders under this folder in one call. CreateFoldersQ()
	# returns the LIST of stzFolder handles (so callers can chain .Name() etc.);
	# the bare CreateFolders() returns TRUE/FALSE. Creates siblings directly
	# (no GoTo side effect that CreateFolder has).
	def CreateFoldersQ(paNames)
		if NOT isList(paNames)
			raise("Incorrect param type! paNames must be a list of folder names.")
		ok
		_aResult_ = []
		_cBase_ = This.Path()
		_nLen_ = len(paNames)
		for i = 1 to _nLen_
			_cName_ = "" + paNames[i]
			# Pass the RAW joined path to the constructor (its _CleanPath
			# handles separators correctly). Do NOT pre-run it through
			# NormalizeFolderPath -- that helper lowercases and strips the
			# last char, yielding an invalid path like "/d:/.../doc/".
			_aResult_ + new stzFolder(_cBase_ + "/" + _cName_)
		next
		return _aResult_

	def CreateFolders(paNames)
		This.CreateFoldersQ(paNames)
		return TRUE

		def MakeFolders(paNames)
			return This.CreateFolders(paNames)

		def CreateSubFolders(paNames)
			return This.CreateFolders(paNames)

	# Create a deep folder path in one call -- every missing intermediate
	# folder along the way is created. CreatePathQ() returns the DEEPEST folder
	# as a stzFolder handle; the bare CreatePath() returns TRUE/FALSE. A
	# relative path resolves against the current position.
	def CreatePathQ(pcPath)
		if CheckParams()
			if NOT (isString(pcPath) and trim(pcPath) != "")
				StzRaise("Incorrect param type! pcPath must be a non-empty string.")
			ok
		ok

		_cPath_ = pcPath
		if not _IsAbsolutePath(_cPath_)
			_cPath_ = This.Path() + "/" + _cPath_
		ok
		_cPath_ = _CleanPath(_cPath_)

		if NOT This.IsInside(_cPath_)
			raise("Can't navigate outside the folder!")
		ok

		StzEngineDirCreatePath(_cPath_)
		return new stzFolder(_cPath_)

		def MkPathQ(pcPath)
			return This.CreatePathQ(pcPath)

		def CreateDeepPathQ(pcPath)
			return This.CreatePathQ(pcPath)

	def CreatePath(pcPath)
		This.CreatePathQ(pcPath)
		return TRUE

		def MkPath(pcPath)
			return This.CreatePath(pcPath)

		def CreateDeepPath(pcPath)
			return This.CreatePath(pcPath)


	def DeleteFolder(_cFolder_)

	    if CheckParams()
	        if NOT (isString(_cFolder_) and _cFolder_ != "")
	            StzRaise("Incorrect param type! cFolder must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(_cFolder_)
	        _cFolder_ = This.CurrentPath() + _cFolder_
	    ok
	
	    _cFolder_ = This.NormalizeFolderPathXT(_cFolder_)
	
	    if This.IsPathOutside(_cFolder_)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(_cFolder_)
	        raise("Folder does not exist.")
	    ok
	
	    # Delete the folder first
	    _bResult_ = RemoveFolderRecursive(_cFolder_)
	    
	    # Then navigate to parent folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cParentDir_ = This.GetDirectoryPath(_cFolder_)
	        This.GoTo(_cParentDir_)
	    ok
	
	    return _bResult_

		def FolderDelete(_cFolder_)
			return This.DeleteFolder(_cFolder_)

		def RemoveFolder(_cFolder_)
			return This.DeleteFolder(_cFolder_)

		def FolderRemove(_cFolder_)
			return This.DeleteFolder(_cFolder_)

	def DeleteAll()

	    try

	        # Delete all files

	        _acFiles_ = This.FilesXT()
			_nLen_ = len(_acFiles_)

	        for i = 1 to _nLen_
	            if NOT StzEngineFileDelete(_acFiles_[i])
	                raise("Could not remove file '" + _acFiles_[i] + "'")
	            ok
	        next

	        _acFolders_ = This.FoldersXT()
			_nLen_ = len(_acFolders_)

	        for i = 1 to _nLen_
	            if NOT RemoveFolderRecursive(_acFolders_[i])
	                raise("Could not remove subfolder '" + _acFolders_[i] + "'")
	            ok
	        next
	
			# After clearing everything, go home (natural mental position)
			This.GoHome()

	    catch
	        raise("Could not empty folder '" + This.Path() + "': " + CatchError())
	    end

		#< @FunctionAlternativeForms

		def DeleteAllFiles()
			return This.DeleteAll()

		def DeepDeleteFiles()
			return This.DeleteAll()

		def FilesDeepDelete()
			return This.DeleteAll()

		def AllFilesDeepDelete()
			return This.DeleteAll()

		#--

		def RemoveAll()
			This.DeleteAll()

		def RemoveAllFiles()
			return This.DeleteAll()

		def DeepRemoveFiles()
			return This.DeleteAll()

		def FilesDeepRemove()
			return This.DeleteAll()

		def AllFilesDeepRemove()
			return This.DeleteAll()

		#>

	# Remove this folder ENTIRELY -- its contents AND the folder itself,
	# recursively (RemoveAll/DeleteAll only empties the contents). Returns
	# TRUE on success.
	def DeepRemoveAll()
		return RemoveFolderRecursive(This.Path())

		def DeepRemove()
			return This.DeepRemoveAll()

		def RemoveTree()
			return This.DeepRemoveAll()

	def Erase()
	    _nDeleted_ = 0
	    _acFiles_ = This.FilesXT()
		_nLen_ = len(_acFiles_)

	    for i = 1 to _nLen_
	        if StzEngineFileDelete(_acFiles_[i])
	            _nDeleted_++
	        ok
	    next

	    # Stay in current folder - just cleaned it up
	    return _nDeleted_
	
		def RemoveFiles()
			return This.Erase()


	def DeepErase()
	    _nDeleted_ = 0
	    _acFiles_ = This.DeepFilesXT()
	    _nLen_ = len(_acFiles_)

	    for i = 1 to _nLen_
	        if StzEngineFileDelete(_acFiles_[i])
	            _nDeleted_++
	        ok
	    next
	    
	    # Stay in current folder - performed deep operation from here
	    return _nDeleted_
	
	def DeepDeleteFile(cFileName)
	    if CheckParams()
	        if NOT (isString(cFileName) and cFileName != "")
	            raise("Incorrect param type! cFileName must be a non-empty string.")
	        ok
	    end
	
	    if NOT This.IsInside(cFileName)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    _acFilePaths_ = This.DeepFindFile(cFileName)
		_nLen_ = len(_acFilePaths_)
	    _nDeleted_ = 0
	
	    for i = 1 to _nLen_
	        if StzEngineFileDelete(_acFilePaths_[i])
	            _nDeleted_++
	        ok
	    next
	
		# Stay in current folder - deep operations initiated from here
	    return _nDeleted_ > 0
	

		def FileDeepDelete(cFileName)
			return This.DeepDeleteFile(cFileName)

		def DeepRemoveFile(cFileName)
			return This.DeepDeleteFile(cFileName)

		def FileDeepRemove(cFileName)
			return This.DeepDeleteFile(cFileName)


	def DeepDeleteFolder(_cFolderName_)

		if CheckParams()
			if NOT ( isString(_cFolderName_) and trim(_cFolderName_) != "" )  # Fixed: cFolderNAme typo
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok
		ok

	    _acFolderPaths_ = This.DeepFindFolder(_cFolderName_)
		_nLen_ = len(_acFolderPaths_)

	    # Sort by depth (deepest first) using Ring's sort
	    _aSortedPaths_ = []
	    for i = 1 to _nLen_
	        _nDepth_ = len(@split(_acFolderPaths_[i], This.Separator()))
	        _aSortedPaths_ + [_nDepth_, _acFolderPaths_[i]]
	    next

	    # Sort by depth descending (deepest first)
	    _aSortedPaths_ = @sorton(_aSortedPaths_, 1)
	    _aSortedPaths_ = reverse(_aSortedPaths_)
		_nLen_ = len(_aSortedPaths_)

	    # Delete folders
		_bResult_ = TRUE

		for i = 1 to _nLen_
	        _cFolderPath_ = _aSortedPaths_[i][2]

	        if dirExists(_cFolderPath_)
	            if NOT RemoveFolderRecursive(_cFolderPath_)
	                _bResult_ = FALSE
					exit
	            ok
	        ok
	    next
		
		# Stay in current folder - deep operation initiated from here
	    return _bResult_

		def DeepRemoveFolder(_cFolderName_)
			return This.DeepDeleteFolder(_cFolderName_)
	
		def FolderDeepDelete(_cFolderName_)
			return This.DeepDeleteFile(_cFolderName_)

		def FolderDeepRemove(_cFolderName_)
			return This.DeepRemoveFile(_cFolderName_)

	#===================#
	#  File Operations  #
	#===================#

	def FileRead(_cFile_)

	    if CheckParams()
	        if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
	            StzRaise("Incorrect param type! cFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(_cFile_)
	        _cFile_ = This.CurrentPath() + _cFile_
	    ok
	
	    _cFile_ = This.NormaliseFilePathXT(_cFile_)
	
	    if This.IsPathOutside(_cFile_)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(_cFile_)
	        raise("cFile does not exist in the folder.")
	    ok
	
	    # Read the file first
	    _cResult_ = @FileRead(_cFile_)
	    
	    # Then navigate to its folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cFileDir_ = This.GetDirectoryPath(_cFile_)
	        This.GoTo(_cFileDir_)
	    ok
	
	    return _cResult_


		def ReadFile(_cFile_)
			return This.FileRead(_cFile_)

		# Q form -> the reader OBJECT for the folder-relative file.
		def FileReadQ(_cFile_)
			if CheckParams()
				if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok
			if not _IsAbsolutePath(_cFile_)
				_cFile_ = This.CurrentPath() + _cFile_
			ok
			_cFile_ = This.NormaliseFilePathXT(_cFile_)
			if This.IsPathOutside(_cFile_)
				raise("Can't navigate outside the folder!")
			ok
			return @FileReadQ(_cFile_)

			def ReadFileQ(_cFile_)
				return This.FileReadQ(_cFile_)

	#--

	# OBJECT-ONLY intent (unified Q convention): both FileAppend(file) and
	# FileAppendQ(file) return the appender OBJECT for the folder-relative
	# file (append-or-create -- the file is created if missing).
	def FileAppend(_cFile_)
		return This.FileAppendQ(_cFile_)

		def AppendFile(_cFile_)
			return This.FileAppendQ(_cFile_)

		def FileAppendQ(_cFile_)

			if CheckParams()
				if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok

			if not _IsAbsolutePath(_cFile_)
				_cFile_ = This.CurrentPath() + _cFile_
			ok
			_cFile_ = This.NormaliseFilePathXT(_cFile_)

			if NOT This.IsInside(_cFile_)
				raise("Can't navigate outside the folder!")
			ok

			# Navigate to file's folder (intelligent navigation)
			if not this.IsBatchMode()
				_cFileDir_ = This.GetDirectoryPath(_cFile_)
				This.GoTo(_cFileDir_)
			ok

			return @FileAppendQ(_cFile_)   # global -> appender object (append-or-create)

			def AppendFileQ(_cFile_)
				return This.FileAppendQ(_cFile_)

	#--

	def FileCreate(_cFile_) #TODO // Provide also the content FileCreate(cFile, cContent)

	    if CheckParams()
	        if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
	            StzRaise("Incorrect param type! cFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position

	    if not _IsAbsolutePath(_cFile_)
	        _cFile_ = This.CurrentPath() + _cFile_
	    ok
	
	    _cFile_ = This.NormaliseFilePathXT(_cFile_)
	
	    if This.IsPathOutside(_cFile_)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if This.Exists(_cFile_)
	        raise("Can't create this file! cFile already exists in the folder.")
	    ok
	
	    # Create the file first
	    _bResult_ = @FileCreate(_cFile_)
	    
	    # Then navigate to its folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cFileDir_ = This.GetDirectoryPath(_cFile_)
	        This.GoTo(_cFileDir_)
	    ok
	
	    return _bResult_

		def CreateFile(_cFile_)
			return This.FileCreate(_cFile_)


		def FileCreateQ(_cFile_)
	
		    if CheckParams()
		        if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
		            StzRaise("Incorrect param type! cFile must be a non-empty string.")
		        ok
		    ok
		
		    # Resolve relative paths against current position
	
		    if not _IsAbsolutePath(_cFile_)
		        _cFile_ = This.CurrentPath() + _cFile_
		    ok
		
		    _cFile_ = This.NormaliseFilePathXT(_cFile_)
		
		    if This.IsPathOutside(_cFile_)
		        raise("Can't navigate outside the folder!")
		    ok
		
		    if This.Exists(_cFile_)
		        raise("Can't create this file! cFile already exists in the folder.")
		    ok
		
		    # Create the file first
		    _oResult_ = @FileCreateQ(_cFile_)
		    
		    # Then navigate to its folder (intelligent navigation)
		    if not this.IsBatchMode()
		        _cFileDir_ = This.GetDirectoryPath(_cFile_)
		        This.GoTo(_cFileDir_)
		    ok
		
		    return _oResult_

			def CreateFileQ(_cFile_)
				return This.FileCreateQ(_cFile_)

	
	def FilesCreate(acFileNames) #TODO // [ [ cFileName1, cFileContent1 ], [ ]... ]

		if CheckParams()
			if NOT (isList(acFileNames) and @IsListOfStrings(acFileNames))
				StzRaise("Incorrect param type! acFileNames must be a list of strings.")
			ok
		ok

		_nLen_ = len(acFileNames)
		_acCreated_ = []
		_acFailed_ = []
		_cLastSuccessfulDir_ = ""

		for i = 1 to _nLen_
			try
				This.CreateFile(acFileNames[i])
				_acCreated_ + cFileName
				# Track last successful creation for intelligent navigation
				_cLastSuccessfulDir_ = This.GetDirectoryPath(acFileNames[i])
			catch
				_acFailed_ + [acFileNames[i], CatchError()]
			end
		next

		# Navigate to last successful creation folder (intelligent navigation)
		if not this.IsBatchMode() and _cLastSuccessfulDir_ != ""
			This.GoTo(_cLastSuccessfulDir_)
		ok

		return [
			:Created = _acCreated_,
			:Failed = _acFailed_
		]


		def CreateFiles(acFileNames)
			return This.FilesCreate(acFileNames)


	def FileOverwrite(_cFile_, cNewContent)

		if CheckParams()
			if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		_cFile_ = This.NormaliseFilePathXT(_cFile_)

		if NOT This.IsInside(_cFile_)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(_cFile_)
			raise("Can't overwrite this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This.GoTo(_cFileDir_)
		ok

		return @FileOverwrite(_cFile_, cNewContent)

	
		def OverwriteFile(_cFile_, cNewContent)
			return This.FileOverwrite(_cFile_, cNewContent)

		# Q form -> the overwriter OBJECT (read OriginalContent then replace).
		def FileOverwriteQ(_cFile_)

			if CheckParams()
				if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok

			if not _IsAbsolutePath(_cFile_)
				_cFile_ = This.CurrentPath() + _cFile_
			ok
			_cFile_ = This.NormaliseFilePathXT(_cFile_)

			if NOT This.IsInside(_cFile_)
				raise("Can't navigate outside the folder!")
			ok

			if NOT This.Exists(_cFile_)
				raise("Can't overwrite this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder (intelligent navigation)
			if not this.IsBatchMode()
				_cFileDir_ = This.GetDirectoryPath(_cFile_)
				This.GoTo(_cFileDir_)
			ok

			return @FileOverwriteQ(_cFile_)

			def OverwriteFileQ(_cFile_)
				return This.FileOverwriteQ(_cFile_)
	
	
	def FileErase(_cFile_)

		if CheckParams()
			if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		_cFile_ = This.NormaliseFilePathXT(_cFile_)

		if NOT This.IsInside(_cFile_)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(_cFile_)
			raise("Can't erase this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder before erasing (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This.GoTo(_cFileDir_)
		ok

		return @FileErase(_cFile_)

		def EraseFile(_cFile_)
			return This.FileErase(_cFile_)


		def FileEraseQ(_cFile_)

			if CheckParams()
				if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok

			_cFile_ = This.NormaliseFilePathXT(_cFile_)
	
			if NOT This.IsInside(_cFile_)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.Exists(_cFile_)
				raise("Can't erase this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder before erasing (intelligent navigation)
			if not this.IsBatchMode()
				_cFileDir_ = This.GetDirectoryPath(_cFile_)
				This.GoTo(_cFileDir_)
			ok

			return @FileEraseQ(_cFile_)  # Fixed: was This.cFile


			def EraseFileQ(_cFile_)
				return This.FileEraseQ(_cFile_)


	def FileSafeErase(_cFile_)

		if CheckParams()
			if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		_cFile_ = This.NormaliseFilePathXT(_cFile_)

		if NOT This.IsInside(_cFile_)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(_cFile_)
			raise("Can't safe-erase this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder before safe-erasing (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This.GoTo(_cFileDir_)
		ok

		return @FileSafeErase(_cFile_)


		def FileSafeEraseQ(_cFile_)

			if CheckParams()
				if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok

			_cFile_ = This.NormaliseFilePathXT(_cFile_)
	
			if NOT This.IsInside(_cFile_)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.Exists(_cFile_)
				raise("Can't safe-erase this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder before safe-erasing (intelligent navigation)
			if not this.IsBatchMode()
				_cFileDir_ = This.GetDirectoryPath(_cFile_)
				This.GoTo(_cFileDir_)
			ok

			return @FileSafeEraseQ(_cFile_)
	
		def SafeEraseFile(_cFile_)
			return This.FileSafeErase(_cFile_)

		def SafeEraseFileQ(_cFile_)
			return This.FileSafeEraseQ(_cFile_)


	def FileRemove(_cFile_)

	    if CheckParams()
	        if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
	            StzRaise("Incorrect param type! cFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(_cFile_)
	        _cFile_ = This.CurrentPath() + _cFile_
	    ok
	
	    _cFile_ = This.NormaliseFilePathXT(_cFile_)
	
	    if This.IsPathOutside(_cFile_)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(_cFile_)
	        raise("cFile does not exist in the folder.")
	    ok
	
	    # Delete the file first
	    _bResult_ = @FileRemove(_cFile_)
	    
	    # Then navigate to file's containing folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cFileDir_ = This.GetDirectoryPath(_cFile_)
	        This.GoTo(_cFileDir_)
	    ok
	
	    return _bResult_

		def FileDelete(_cFile_)
			return This.FileRemove(_cFile_)

		def RemoveFile(_cFile_)
			return This.FileRemove(_cFile_)

		def DeleteFile(_cFile_)
			return This.FileRemove(_cFile_)


	def FileBackup(_cFile_)

	    if CheckParams()
	        if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
	            StzRaise("Incorrect param type! cFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(_cFile_)
	        _cFile_ = This.CurrentPath() + _cFile_
	    ok
	
	    _cFile_ = This.NormaliseFilePathXT(_cFile_)
	
	    if This.IsPathOutside(_cFile_)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(_cFile_)
	        raise("cFile does not exist in the folder.")
	    ok
	
	    # Create backup first
	    _cBackupFile_ = _cFile_ + ".bak"
	    _bResult_ = @FileBackup(_cFile_, _cBackupFile_)
	    
	    # Then navigate to file's folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cFileDir_ = This.GetDirectoryPath(_cFile_)
	        This.GoTo(_cFileDir_)
	    ok
	
	    return _bResult_


		def BackupFile(_cFile_)
			return This.FileBackup(_cFile_)


	def FileSafeOverwrite(_cFile_, cNewContent)

		if CheckParams()
			if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		_cFile_ = This.NormaliseFilePathXT(_cFile_)

		if NOT This.IsInside(_cFile_)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(_cFile_)
			raise("Can't safe-overwirte this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This.GoTo(_cFileDir_)
		ok

		return @FileSafeOverwrite(_cFile_, cNewContent)

		def SafeOverwriteFile(_cFile_, cNewContent)
			return This.FileSafeOverwrite(_cFile_, cNewContent)


	def FileModify(_cFile_, cOldContent, cNewContent)

		if CheckParams()
			if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		_cFile_ = This.NormaliseFilePathXT(_cFile_)

		if NOT This.IsInside(_cFile_)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(_cFile_)
			raise("Can't modify this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This.GoTo(_cFileDir_)
		ok

		return @FileModify(_cFile_, cOldContent, cNewContent)

		def ModifyFile(_cFile_, cOldContent, cNewContent)
			return This.FileModify(_cFile_, cOldContent, cNewContent)

	# OBJECT-ONLY intent: both FileUpdate(file) and FileUpdateQ(file) return
	# the modifier OBJECT for the folder-relative file (Replace/Insert/Remove
	# before Close). The one-shot value form is FileModify(file, old, new).
	def FileUpdate(_cFile_)
		return This.FileUpdateQ(_cFile_)

		def FileUpdateQ(_cFile_)
			if CheckParams()
				if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok
			if not _IsAbsolutePath(_cFile_)
				_cFile_ = This.CurrentPath() + _cFile_
			ok
			_cFile_ = This.NormaliseFilePathXT(_cFile_)
			if NOT This.IsInside(_cFile_)
				raise("Can't navigate outside the folder!")
			ok
			if NOT This.Exists(_cFile_)
				raise("Can't update this file! cFile does not exist in the folder.")
			ok
			return @FileUpdate(_cFile_)

	def FileCopy(_cSourceFile_, _cDestFile_)
	    if CheckParams()
	        if NOT ( isString(_cSourceFile_) and trim(_cSourceFile_) != "" )
	            StzRaise("Incorrect param type! cSourceFile must be a non-empty string.")
	        ok
	        if NOT ( isString(_cDestFile_) and trim(_cDestFile_) != "" )
	            StzRaise("Incorrect param type! cDestFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(_cSourceFile_)
	        _cSourceFile_ = This.CurrentPath() + _cSourceFile_
	    ok
	    if not _IsAbsolutePath(_cDestFile_)
	        _cDestFile_ = This.CurrentPath() + _cDestFile_
	    ok
	
	    _cSourceFile_ = This.NormaliseFilePathXT(_cSourceFile_)
	    _cDestFile_ = This.NormaliseFilePathXT(_cDestFile_)
	
	    if This.IsPathOutside(_cSourceFile_) or This.IsPathOutside(_cDestFile_)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(_cSourceFile_)
	        raise("Source file does not exist in the folder.")
	    ok
	
	    # Copy the file first
	    _bResult_ = @FileCopy(_cSourceFile_, _cDestFile_)
	    
	    # Then navigate to destination folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cDestDir_ = This.GetDirectoryPath(_cDestFile_)
	        This.GoTo(_cDestDir_)
	    ok
	
	    return _bResult_


		def CopyFile(cSource, cDest)
			return this.FileCopy(cSource, cDest)


	def FileMove(_cSourceFile_, _cDestFile_)
	    if CheckParams()
	        if NOT ( isString(_cSourceFile_) and trim(_cSourceFile_) != "" )
	            StzRaise("Incorrect param type! cSourceFile must be a non-empty string.")
	        ok
	        if NOT ( isString(_cDestFile_) and trim(_cDestFile_) != "" )
	            StzRaise("Incorrect param type! cDestFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(_cSourceFile_)
	        _cSourceFile_ = This.CurrentPath() + _cSourceFile_
	    ok
	    if not _IsAbsolutePath(_cDestFile_)
	        _cDestFile_ = This.CurrentPath() + _cDestFile_
	    ok
	
	    _cSourceFile_ = This.NormaliseFilePathXT(_cSourceFile_)
	    _cDestFile_ = This.NormaliseFilePathXT(_cDestFile_)
	
	    if This.IsPathOutside(_cSourceFile_) or This.IsPathOutside(_cDestFile_)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(_cSourceFile_)
	        raise("Source file does not exist in the folder.")
	    ok
	
	    # Move the file first
	    _bResult_ = @FileMove(_cSourceFile_, _cDestFile_)
	    
	    # Then navigate to destination folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cDestDir_ = This.GetDirectoryPath(_cDestFile_)
	        This.GoTo(_cDestDir_)
	    ok
	
	    return _bResult_


		def MoveFile(cSource, cDestination)
			return this.FileMove(cSource, cDestination)

	#--

	def FileSize(_cFile_)
		if CheckParams()
			if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		_cFile_ = This.NormaliseFilePathXT(_cFile_)

		if NOT This.IsInside(_cFile_)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(_cFile_)
			raise("Can't get size of this file! cFile does not exist in the folder.")  # Fixed: was "modify"
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This.GoTo(_cFileDir_)
		ok

		# No @FileSize global exists; the byte size is the length of the file
		# content (the codebase's established pattern). ring_len() -- not bare
		# len() -- because a bare len() inside a class method resolves to a
		# method and raises R20.
		return ring_len(read(_cFile_))

		def FileSizeInBytes(_cFile_)
			return this.FileSize(_cFile_)

	def FileInfo(_cFile_)

		if CheckParams()
			if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		_cFile_ = This.NormaliseFilePathXT(_cFile_)

		if NOT This.IsInside(_cFile_)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(_cFile_)
			raise("Can't read this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This.GoTo(_cFileDir_)
		ok

		return @FileInfo(_cFile_)

		def FileInfoQ(_cFile_)
			_cFile_ = This.NormaliseFilePathXT(_cFile_)
	
			if NOT This.IsInside(_cFile_)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.Exists(_cFile_)
				raise("Can't read this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder (intelligent navigation)
			if not this.IsBatchMode()
				_cFileDir_ = This.GetDirectoryPath(_cFile_)
				This.GoTo(_cFileDir_)
			ok

			return @FileInfoQ(_cFile_)

	def FileInfoXT(_cFile_)

		if CheckParams()
			if NOT ( isString(_cFile_) and trim(_cFile_) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		_cFile_ = This.NormaliseFilePathXT(_cFile_)

		if NOT This.IsInside(_cFile_)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(_cFile_)
			raise("Can't read this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This.GoTo(_cFileDir_)
		ok

		return @FileInfoXT(_cFile_)

	#======================#
	#  Finding Operations  #
	#======================#

	def FindFiles(pPattern)

		# Polymorphic: a string pattern (with optional "*" wildcard) OR a
		# list of explicit file names to look for. A list returns the names
		# (from the list) that actually exist in this folder.
		_acNames_ = []
		if isList(pPattern)
			_nN_ = len(pPattern)
			for k = 1 to _nN_
				_acNames_ + ("" + pPattern[k])
			next
		but isString(pPattern) and trim(pPattern) != ""
			_acNames_ + pPattern
		else
			if CheckParams()
				StzRaise("Incorrect param type! pPattern must be a non-empty string or a list of names.")
			ok
			return []
		ok

		_acFiles_ = This.Files()
		_nLen_ = len(_acFiles_)
		_acResult_ = []

		_nNames_ = len(_acNames_)
		for j = 1 to _nNames_
			_cPattern_ = This.NormalizeFilePath(_acNames_[j])

			if StzFindFirst("*", _cPattern_) > 0
				_cPattern_ = StzReplace(_cPattern_, "*", "")
				for i = 1 to _nLen_
					if StzFindFirst(StzLower(_cPattern_), StzLower(_acFiles_[i])) > 0
						_acResult_ + _acFiles_[i]
					ok
				next
			else
				# Files() yields "/name.ext"; compare on the basename so an
				# exact name (or a list entry like "test.txt") still matches.
				for i = 1 to _nLen_
					if StzLower(_DirName(_acFiles_[i])) = StzLower(_DirName(_cPattern_))
						_acResult_ + _acFiles_[i]
					ok
				next
			ok
		next

		return _acResult_

		def FindFile(cFileName)
			return This.FindFiles(cFileName)

		def FindThisFile(cFileName)
			return This.FindFiles(cFileName)

	def FindFolders(_cPattern_)

		if CheckParams()
			if NOT ( isString(_cPattern_) and trim(_cPattern_) != "" )
				StzRaise("Incorrect param type! cPattern must be a non-empty string.")
			ok
		ok

		_cPattern_ = This.NormalizeFilePath(_cPattern_)
		_acFolders_ = This.Folders()
		_nLen_ = len(_acFolders_)

		_acResult_ = []

		if StzFindFirst("*", _cPattern_) > 0

			_cPattern_ = StzReplace(_cPattern_, "*", "")

			for i = 1 to _nLen_
				if StzFindFirst(StzLower(_cPattern_), StzLower(_acFolders_[i])) > 0
					_acResult_ + _acFolders_[i]
				ok
			next

		else

			for i = 1 to _nLen_
				if StzLower(_acFolders_[i]) = StzLower(_cPattern_)
					_acResult_ + _acFolders_[i]
				ok
			next
		ok

		return _acResult_

		def FindFolder(_cFolderName_)
			return This.FindFolders(_cFolderName_)

		def FindThisFolder(_cFolderName_)
			return This.FindFolders(_cFolderName_)


	def FindFilesByExtension(_cExt_)
		if CheckParams()
			if NOT ( isString(_cExt_) and trim(_cExt_) != "" )
				StzRaise("Incorrect param type! cExt must be a non-empty string.")
			ok
		ok

		if StzLeft(_cExt_, 1) != "."
			_cExt_ = "." + _cExt_
		ok
		_acFound_ = []
		_acAllFiles_ = This.Files()
		_nLen_ = len(_acAllFiles_)

		for i = 1 to _nLen_
			if StzRight(StzLower(_acAllFiles_[i]), StzLen(_cExt_)) = StzLower(_cExt_)
				_acFound_ + _acAllFiles_[i]
			ok
		next
		return _acFound_

		def FilesByExtension(_cExt_)
			return This.FindFilesByExtension(_cExt_)

	def FindTheseFiles(acFilesNames)
		if NOT isList(acFilesNames)
			StzRaise("Incorrect param type! acFilesNames must be a list.")
		ok
		_acFound_ = []
		_nLen_ = len(acFilesNames)

		for i = 1 to _nLen_
			_acFileResults_ = This.FindFiles(acFilesNames[i])
			_nLenR_ = len(acFileResult)

			for j = 1 to _nLenR_
				if find(_acFound_, _acFileResults_[j]) = 0
					_acFound_ + _acFileResults_[j]
				ok
			next
		next

		return _acFound_

	def FindTheseFolders(acFoldersNames)
		if NOT isList(acFoldersNames)
			StzRaise("Incorrect param type! acFoldersNames must be a list.")
		ok
		_acFound_ = []
		_nLen_ = len(acFoldersNames)

		for i = 1 to _nLen_

			_acFolderResults_ = This.FindFolders(acFoldersNames[i])
			_nLenR_ = len(_acFolderResults_)

			for j = 1 to _nLenR_
				if find(_acFound_, _acFolderResults_[j]) = 0
					_acFound_ + _acFolderResults_[j]
				ok
			next

		next

		return _acFound_


	def Find(_cPattern_)
		_acFiles_ = This.FindFiles(_cPattern_)
		_acFolders_ = This.FindFolders(_cPattern_)
		return _acFiles_ + _acFolders_

	def DeepFindFiles(_cPattern_)
		if NOT isString(_cPattern_)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok

		# Filter the (already-correct) recursive file listing. The previous
		# hand-rolled walk was doubly broken: it read an undefined var
		# (_aEntry_[2]) so it never matched, and it fed DeepFolders()'s
		# simplified relative paths to @dir() (which needs absolute paths)
		# while skipping the root folder's own files.
		_acAll_ = This.DeepFiles()
		_nLen_ = len(_acAll_)
		_acFound_ = []

		_bWildcard_ = (StzFindFirst("*", _cPattern_) > 0)
		if _bWildcard_
			_cPattern_ = StzReplace(_cPattern_, "*", "")
		ok

		for i = 1 to _nLen_
			if _bWildcard_
				if StzFindFirst(StzLower(_cPattern_), StzLower(_acAll_[i])) > 0
					_acFound_ + _acAll_[i]
				ok
			else
				if StzLower(_DirName(_acAll_[i])) = StzLower(_cPattern_)
					_acFound_ + _acAll_[i]
				ok
			ok
		next

		return _acFound_

		def DeepFindFile(cFileName)
			return This.DeepFindFiles(cFileName)

		def DeepFindThisFile(cFileName)
			return This.DeepFindFiles(cFileName)

	def DeepFindFolders(_cPattern_)

		if NOT isString(_cPattern_)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok

		# Filter the (already-correct) recursive folder listing. The previous
		# version fed DeepFolders()'s simplified relative paths to @dir()
		# (which needs absolute paths) -> empty result. DeepFolders() already
		# returns every folder in the subtree as "/a/b/".
		_acAll_ = This.DeepFolders()
		_nLen_ = len(_acAll_)
		_acFound_ = []

		_bWildcard_ = (StzFindFirst("*", _cPattern_) > 0)
		if _bWildcard_
			_cPattern_ = StzReplace(_cPattern_, "*", "")
		ok

		for i = 1 to _nLen_
			if _bWildcard_
				if StzFindFirst(StzLower(_cPattern_), StzLower(_acAll_[i])) > 0
					_acFound_ + _acAll_[i]
				ok
			else
				if StzLower(_DirName(_CleanPath(_acAll_[i]))) = StzLower(_cPattern_)
					_acFound_ + _acAll_[i]
				ok
			ok
		next

		return _acFound_

		def DeepFindFolder(_cFolderName_)
			return This.DeepFindFolders(_cFolderName_)

		def DeepFindThisFolder(_cFolderName_)
			return This.DeepFindFolders(_cFolderName_)

	def DeepFindTheseFiles(acFilesNames)
		if NOT isList(acFilesNames)
			StzRaise("Incorrect param type! acFilesNames must be a list.")
		ok
		_acFound_ = []
		_nLen_ = len(acFilesNames)

		for i = 1 to _nLen_

			_acFileResults_ = This.DeepFindFiles(acFilesNames[i])
			_nLenR_ = len(_acFileResults_)

			for j = 1 to _nLenR_
				if StzFindFirst(_acFound_, _acFileResults_[j]) = 0
					_acFound_ + _acFileResults_[j]
				ok
			next
		next

		return _acFound_

	def DeepFindTheseFolders(acFoldersNames)
		if NOT isList(acFoldersNames)
			StzRaise("Incorrect param type! acFoldersNames must be a list.")
		ok
		_acFound_ = []
		_nLen_ = len(acFoldersNames)

		for i = 1 to _nLen_

			_acFolderResults_ = This.DeepFindFolders(acFoldersNames[i])
			_nLenR_ = len(_acFolderResults_)

			for j = 1 to _nLenR_
				if StzFindFirst(_acFound_, _acFolderResults_[j]) = 0
					_acFound_ + _acFolderResults_[j]
				ok
			next

		next

		return _acFound_


	def DeepFind(_cPattern_)
		_acFiles_ = This.DeepFindFiles(_cPattern_)
		_acFolders_ = This.DeepFindFolders(_cPattern_)
		return _acFiles_ + _acFolders_

		def DeepFindFileOrFolder(_cPattern_)
			return This.DeepFind(_cPattern_)

		def DeepFindThisFileOrFolder(_cPattern_)
			return This.DeepFind(_cPattern_)

	#=====================#
	#  Search Operations  #
	#=====================#

	def SearchInFiles(cContent)
		if NOT isString(cContent)
			StzRaise("Incorrect param type! cContent must be a string.")
		ok
		return This.SearchInTheseFiles(This.Files(), cContent)


	def SearchInFile(_cFile_, cContent)
		if NOT isString(_cFile_) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok
		_acLineNumbers_ = []
		_cFullPath_ = @cCurrentPath + This.Separator() + _cFile_
		if fexists(_cFullPath_)
			_cFileContent_ = read(_cFullPath_)
			_acLines_ = @split(_cFileContent_, NL)

			_nLen_ = len(_acLines_)
			for i = 1 to _nLen_
				if StzFindFirst(StzLower(cContent), StzLower(_acLines_[i])) > 0
					_acLineNumbers_ + i
				ok
			next

		ok
		return _acLineNumbers_

		def SearchInThisFile(_cFile_, cContent)
			return This.SearchInFile(_cFile_, cContent)

	def SearchInTheseFiles(_acFiles_, cContent)
		if NOT isList(_acFiles_) or NOT isString(cContent)
			StzRaise("Incorrect param types! acFiles must be a list and cContent must be a string.")
		ok
		_acResults_ = []
		_nLen_ = len(_acFiles_)

		for i = 1 to _nLen_
			_acLineNumbers_ = This.SearchInFile(_acFiles_[i], cContent)
			if len(_acLineNumbers_) > 0
				_acResults_ + [_acFiles_[i], _acLineNumbers_]
			ok
		next

		return _acResults_

	def SearchInFolders(cContent)
		if NOT isString(cContent)
			StzRaise("Incorrect param type! cContent must be a string.")
		ok
		return This.SearchInTheseFolders(This.Folders(), cContent)

	def SearchInFolder(_cFolder_, cContent)

		if NOT isString(_cFolder_) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		_acResults_ = []
		_cFolderPath_ = @cCurrentPath + This.Separator() + _cFolder_

		if isdir(_cFolderPath_)

			_aEntries_ = @dir(_cFolderPath_)
			_nLen_ = len(_aEntries_)

			for i = 1 to _nLen_

				if _aEntries_[i][2] = 0

					_cFilePath_ = _cFolderPath_ + This.Separator() + _aEntries_[i][1]

					if fexists(_cFilePath_)

						_cFileContent_ = read(_cFilePath_)
						_acLines_ = @split(_cFileContent_, NL)
						_nLenL_ = len(_acLines_)
						_acLineNumbers_ = []

						for i = 1 to _nLenL_
							if StzFindFirst(StzLower(cContent), StzLower(_acLines_[i])) > 0
								_acLineNumbers_ + i
							ok
						next

						if len(_acLineNumbers_) > 0
							_acResults_ + [_aEntries_[i][1], _acLineNumbers_]
						ok
					ok
				ok
			next
		ok
		return _acResults_

		def SearchInThisFolder(_cFolder_, cContent)
			return This.SearchInFolder(_cFolder_, cContent)

	def SearchInTheseFolders(_acFolders_, cContent)

		if NOT isList(_acFolders_) or NOT isString(cContent)
			StzRaise("Incorrect param types! acFolders must be a list and cContent must be a string.")
		ok

		_acResults_ = []
		_nLen_ = len(_acFolders_)

		for i = 1 to _nLen_

			_acFolderResults_ = This.SearchInFolder(_acFolders_[i], cContent)
			_nLenR_ = len(_acFolderResults_)

			for j = 1 to _nLenR_
				_acResults_ + _acFolderResults_[j]
			next

		next

		return _acResults_


	def DeepSearchInFiles(cContent)
		if NOT isString(cContent)
			StzRaise("Incorrect param type! cContent must be a string.")
		ok

		# Scan every file in the whole subtree (absolute paths from
		# DeepFilesXT) and collect the 1-based line numbers where the content
		# appears. The previous walk reused the OUTER loop counter `i` for the
		# inner line scan (clobbering iteration -> [] result) and iterated its
		# dir list with an off-by-one. Distinct counters (f / k) fix both.
		_acAll_ = This.DeepFilesXT()
		_nFiles_ = len(_acAll_)
		_acResult_ = []

		for f = 1 to _nFiles_
			_cFilePath_ = _acAll_[f]
			if fexists(_cFilePath_)
				_cFileContent_ = read(_cFilePath_)
				_acLines_ = @split(_cFileContent_, NL)
				_nLines_ = len(_acLines_)
				_acLineNumbers_ = []

				for k = 1 to _nLines_
					if StzFindFirst(StzLower(cContent), StzLower(_acLines_[k])) > 0
						_acLineNumbers_ + k
					ok
				next

				if len(_acLineNumbers_) > 0
					_acResult_ + [_cFilePath_, _acLineNumbers_]
				ok
			ok
		next

		return _acResult_


	def DeepSearchInFile(_cFile_, cContent)

		if NOT isString(_cFile_) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		# Match files by name across the subtree, then collect line numbers.
		# Uses DeepFilesXT (absolute paths) so read()/fexists() work -- the
		# old version fed DeepFindFiles' relative paths to fexists (never
		# found) and reused the outer counter `i` for the inner line scan.
		_acResults_ = []
		_acAll_ = This.DeepFilesXT()
		_nFiles_ = len(_acAll_)

		for f = 1 to _nFiles_

			if StzLower(_DirName(_acAll_[f])) = StzLower(_DirName(_cFile_)) and fexists(_acAll_[f])

				_cFileContent_ = read(_acAll_[f])
				_acLines_ = @split(_cFileContent_, NL)
				_nLines_ = len(_acLines_)
				_acLineNumbers_ = []

				for k = 1 to _nLines_
					if StzFindFirst(StzLower(cContent), StzLower(_acLines_[k])) > 0
						_acLineNumbers_ + k
					ok
				next

				if len(_acLineNumbers_) > 0
					_acResults_ + [_acAll_[f], _acLineNumbers_]
				ok

			ok

		next

		return _acResults_


	def DeepSearchInTheseFiles(_acFiles_, cContent)

		if NOT isList(_acFiles_) or NOT isString(cContent)
			StzRaise("Incorrect param types! acFiles must be a list and cContent must be string.")
		ok

		_acResults_ = []

		_nLen_ = len(_acFiles_)
		for i = 1 to _nLen_

			_acFileResults_ = This.DeepSearchInFile(_acFiles_[i], cContent)
			_nLenR_ = len(_acFileResults_)

			for j = 1 to _nLenR_
				_acResults_ + _acFileResults_[j]
			next

		next

		return _acResults_


	def DeepSearchInFolder(_cFolder_, cContent)
		if NOT isString(_cFolder_) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		_acResults_ = []
		_acFolderPaths_ = This.DeepFindFolders(_cFolder_)
		_nLen_ = len(_acFolderPaths_)

		for i = 1 to _nLen_

			if isdir(_acFolderPaths_[i])
				_aEntries_ = @dir(_acFolderPaths_[i])
				_nLenE_ = len(_aEntries_)

				for j = 1 to _nLenE_

					if _aEntries_[j][2] = 0

						_cFilePath_ = _acFolderPaths_[i] + This.Separator() + _aEntries_[j][1]

						if fexists(_acFolderPaths_[i])
							_cFileContent_ = read(_acFolderPaths_[i])
							_acLines_ = @split(_cFileContent_, NL)
							_nLenL_ = len(_acLines_)
							_acLineNumbers_ = []

							for i = 1 to _nLenL_
								if StzFindFirst(StzLower(cContent), StzLower(_acLines_[i])) > 0
									_acLineNumbers_ + i
								ok
							next

							if len(_acLineNumbers_) > 0
								_acResults_ + [_acFolderPaths_[i], _acLineNumbers_]
							ok
						ok
					ok

				next
			ok

		next

		return _acResults_


	def DeepSearchInFolders(_acFolders_, cContent)
		if NOT isList(_acFolders_) or NOT isString(cContent)
			StzRaise("Incorrect param types! acFolders must be a list and cContent must be string.")
		ok
		_acResults_ = []
		_nLen_ = len(_acFolders_)

		for i = 1 to _nLen_

			_acFolderResults_ = This.DeepSearchInFolder(_acFolders_[i], cContent)
			_nLenR_ = len(_acFolderResults_)

			for j = 1 to _nLenR_
				_acResults_ + _acFolderResults_[j]
			next

		next

		return _acResults_

	#-------------#
	#  MATCHINGS  #
	#-------------#

	def Matches(_cPattern_, _cName_)

		if _cPattern_ = "*"
			return 1
		ok

		_cRegexPattern_ = _cPattern_
		_cRegexPattern_ = StzReplace(_cRegexPattern_, "*", ".*")
		_cRegexPattern_ = StzReplace(_cRegexPattern_, "?", ".")

		if StzLeft(_cPattern_, 1) = "*" and StzRight(_cPattern_, 1) = "*"
			_cMiddle_ = StzMid(_cPattern_, 2, StzLen(_cPattern_) - 2)
			return StzFindFirst(_cMiddle_, _cName_) > 0

		but StzLeft(_cPattern_, 1) = "*"
			_cSuffix_ = StzMid(_cPattern_, 2, StzLen(_cPattern_) - 1)
			return StzRight(_cName_, StzLen(_cSuffix_)) = _cSuffix_

		but StzRight(_cPattern_, 1) = "*"
			_cPrefix_ = StzLeft(_cPattern_, StzLen(_cPattern_) - 1)
			return StzLeft(_cName_, StzLen(_cPrefix_)) = _cPrefix_

		else
			return _cName_ = _cPattern_
		ok


	def GetFoldersContainingFileMatches(_cPath_, _cPattern_)

		_aAllPaths_ = This.CollectFoldersWithFileMatches(_cPath_, _cPattern_, _aAllPaths_)
		_nLen_ = len(_aAllPaths_)

		_aFolderNames_ = []

		for i = 1 to _nLen_

			_acPathParts_ = This.GetPathHierarchy(_aAllPaths_[i])
			_nLenP_ = len(_acPathParts_)

			for j = 1 to _nLenP_
				if StzFindFirst(_aFolderNames_, _acPathParts_[j]) = 0
					_aFolderNames_ + _acPathParts_[j]
				end
			next

		next

		return _aFolderNames_


	def CountFileMatches(_cPath_, _cPattern_)
		_nCount_ = 0
		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)

		for i = 1 to _nLen_
			if _aList_[i][2] = 0
				if This.Matches(_cPattern_, _aList_[i][1])
					_nCount_++
				end
			end
		next

		return _nCount_

	def CountFolderMatches(_cPath_, _cPattern_)
		_nCount_ = 0
		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)
		for i = 1 to _nLen_
			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				if This.Matches(_cPattern_, _aList_[i][1])
					_nCount_++
				end
			end
		next
		return _nCount_

	#======================#
	# Content Modification #
	#======================#

	def ModifyInFile(_cFile_, cContent, cNewContent)
		if NOT isString(_cFile_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok
		_cFullPath_ = @cCurrentPath + This.Separator() + _cFile_
		if fexists(_cFullPath_)
			_cFileContent_ = read(_cFullPath_)
			_cModifiedContent_ = StzReplace(_cFileContent_, cContent, cNewContent)
			write(_cFullPath_, _cModifiedContent_)
			return TRUE
		ok
		return FALSE

	def ModifyInFiles(_acFiles_, cContent, cNewContent)

		if NOT isList(_acFiles_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFiles must be a list, cContent and cNewContent must be strings.")
		ok

		_nModified_ = 0

		_nLen_ = len(_acFiles_)
		for i = 1 to _nLen_
			if This.ModifyInFile(_acFiles_[i], cContent, cNewContent)
				_nModified_++
			ok
		next

		return _nModified_


	def ModifyInFolder(_cFolder_, cContent, cNewContent)

		if NOT isString(_cFolder_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok

		_nModified_ = 0
		_cFolderPath_ = @cCurrentPath + This.Separator() + _cFolder_

		if isdir(_cFolderPath_)
			_aEntries_ = @dir(_cFolderPath_)
			_nLen_ = len(_aEntries_)

			for i = 1 to _nLen_
	
				if _aEntries_[i][2] = 0
					_cFilePath_ = _cFolderPath_ + This.Separator() + _aEntries_[i][1]

					if fexists(_cFilePath_)
						_cFileContent_ = read(_cFilePath_)
						_cModifiedContent_ = StzReplace(_cFileContent_, cContent, cNewContent)
						write(_cFilePath_, _cModifiedContent_)
						_nModified_++
					ok

				ok

			next
		ok

		return _nModified_


	def ModifyInFolders(_acFolders_, cContent, cNewContent)

		if NOT isList(_acFolders_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFolders must be a list, cContent and cNewContent must be strings.")
		ok

		_nModified_ = 0
		_nLen_ = len(_acFolders_)

		for i = 1 to _nLen_
			_nModified_ += This.ModifyInFolder(_acFolders_[i], cContent, cNewContent)
		next

		return _nModified_


	def ModifyInRoot(cContent, cNewContent)

		if NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		_nModified_ = 0
		_acFiles_ = This.Files()
		_nLen_ = len(_acFiles_)

		for i = 1 to _nLen_
			if This.ModifyInFile(_acFiles_[i], cContent, cNewContent)
				_nModified_++
			ok
		next
		return _nModified_


	def DeepModifyInFile(_cFile_, cContent, cNewContent)

		if NOT isString(_cFile_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok

		_nModified_ = 0
		_acFilePaths_ = This.DeepFindFile(_cFile_)
		_nLen_ = len(_acFilePaths_)

		for i = 1 to _nLen_
	
			if fexists(_acFilePaths_[i])

				_cFileContent_ = read(_acFilePaths_[i])
				_cModifiedContent_ = StzReplace(_cFileContent_, cContent, cNewContent)

				write(_acFilePaths_[i], _cModifiedContent_)
				_nModified_++

			ok

		next

		return _nModified_


	def DeepModifyInFiles(_acFiles_, cContent, cNewContent)

		if NOT isList(_acFiles_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFiles must be a list, cContent and cNewContent must be strings.")
		ok

		_nModified_ = 0
		_nLen_ = len(_acFiles_)

		for i = 1 to _nLen_
			_nModified_ += This.DeepModifyInFile(_acFiles_[i], cContent, cNewContent)
		next

		return _nModified_


	def DeepModifyInFolder(_cFolder_, cContent, cNewContent)

		if NOT isString(_cFolder_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok

		_nModified_ = 0
		_acFolderPaths_ = This.DeepFindFolder(_cFolder_)
		_nLen_ = len(_acFolderPaths_)

		for i = 1 to _nLen_

			if isdir(_acFolderPaths_[i])

				_aEntries_ = @dir(_cFolderPath_)
				_nLenE_ = len(_aEntries_)

				for j = 1 to _nLenE_
					if _aEntries_[j][2] = 0
						_cFilePath_ = _cFolderPath_ + This.Separator() + _aEntries_[j][1]

						if fexists(_cFilePath_)

							_cFileContent_ = read(_cFilePath_)
							_cModifiedContent_ = StzReplace(_cFileContent_, cContent, cNewContent)

							write(_cFilePath_, _cModifiedContent_)
							_nModified_++

						ok
					ok

				next

			ok

		next

		return _nModified_


	def DeepModifyInFolders(_acFolders_, cContent, cNewContent)

		if NOT isList(_acFolders_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFolders must be a list, cContent and cNewContent must be strings.")
		ok

		_nModified_ = 0
		_nLen_ = len(_acFolders_)

		for i = 1 to _nLen_
			_nModified_ += This.DeepModifyInFolder(_acFolders_[i], cContent, cNewContent)
		next

		return _nModified_

	def DeepModifyInRoot(cContent, cNewContent)

		if NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		_nModified_ = 0
		_acAllDirs_ = This.DeepFolders()
		_nLen_ = len(_acAllDirs_)

		for i = 1 to _nLen_
			_aEntries_ = @dir(_acAllDirs_[i])
			_nLenE_ = len(_aEntries_)

			for j = 1 to _nLenE_

				if _aEntries_[j][2] = 0

					_cFilePath_ = _acAllDirs_[i] + This.Separator() + _aEntries_[j][1]

					if fexists(_cFilePath_)

						_cFileContent_ = read(_cFilePath_)
						_cModifiedContent_ = StzReplace(_cFileContent_, cContent, cNewContent)

						write(_cFilePath_, _cModifiedContent_)
						_nModified_++

					ok
				ok
			next

		next

		return _nModified_

	#=================#
	#  Visualization  #
	#=================#

	def VizSearch(_cPattern_)
		_nFileMatches_ = This.CountFileMatches(This.Path(), _cPattern_)
		_nFolderMatches_ = This.CountFolderMatches(This.Path(), _cPattern_)
		_nTotalMatches_ = _nFileMatches_ + _nFolderMatches_
		_cFolderName_ = This.Name()
		if _cFolderName_ = ""
			_cFolderName_ = This.Path()
		end
		_cResult_ = @acDisplayChars[:FolderRoot] + " " + _cFolderName_ + " (" + @acDisplayChars[:FolderRootSearchSymbol] + " " + _nTotalMatches_ + " matches for '" + _cPattern_ + "')" + nl
		_cResult_ += This.GenerateVizTreeString(This.Path(), '', 1, _cPattern_, "both", 0, 1)
		return _cResult_

		def VizSearchFiles(_cPattern_)
			return This.VizFindFiles(_cPattern_)

	def VizFindFiles(_cPattern_)
		_nTotalMatches_ = This.CountFileMatches(This.Path(), _cPattern_)
		_cFolderName_ = This.Name()
		if _cFolderName_ = ""
			_cFolderName_ = This.Path()
		end
		_cResult_ = @acDisplayChars[:FolderRoot] + " " + _cFolderName_ + " (" + @acDisplayChars[:FolderRootSearchSymbol] + " " + _nTotalMatches_ + " file matches for '" + _cPattern_ + "')" + nl
		_cResult_ += This.GenerateVizTreeString(This.Path(), "", 1, _cPattern_, "files", 0, 1)
		return _cResult_

		def VizSearchFolders(_cPattern_)
			return This.VizFindFolders(_cPattern_)

	def VizFindFolders(_cPattern_)
		_nTotalMatches_ = This.CountFolderMatches(This.Path(), _cPattern_)
		_cFolderName_ = This.Name()
		if _cFolderName_ = ""
			_cFolderName_ = This.Path()
		end
		_cResult_ = @acDisplayChars[:FolderRootXT] + " " + _cFolderName_ + " (" + @acDisplayChars[:FolderRootSearchSymbol] + " " + _nTotalMatches_ + " folder matches for '" + _cPattern_ + "')" + nl
		_cResult_ += This.GenerateVizTreeString(This.Path(), "", 1, _cPattern_, "folders", 0, 1)
		return _cResult_

		def VizSearchDirs(_cPattern_)
			return This.VizFindFolders(_cPattern_)

	def VizDeepSearch(_cPattern_)
		_nTotalFileMatches_ = This.CountFileMatchesRecursive(This.Path(), _cPattern_)
		_nTotalFolderMatches_ = This.CountFolderMatchesRecursive(This.Path(), _cPattern_)
		_nTotalMatches_ = _nTotalFileMatches_ + _nTotalFolderMatches_
		_cFolderName_ = This.Name()
		if _cFolderName_ = ""
			_cFolderName_ = This.Path()
		end
		_cResult_ = @acDisplayChars[:FolderRoot] + " " + _cFolderName_ + " (" + @acDisplayChars[:FolderRootSearchSymbol] + "" + _nTotalMatches_ + " matches for '" + _cPattern_ + "')" + nl
		_cResult_ += This.GenerateVizTreeString(This.Path(), '', 1, _cPattern_, "both", 0, This.MaxDisplayLevel())
		return _cResult_

		def VizDeepFindFilesAndFolders(_cPattern_)
			return This.VizDeepSearch(_cPattern_)

	def VizDeepFindFiles(_cPattern_)
		_nTotalMatches_ = This.CountFileMatchesRecursive(This.Path(), _cPattern_)
		_cFolderName_ = This.Name()
		if _cFolderName_ = ""
			_cFolderName_ = This.Path()
		end
		_cResult_ = @acDisplayChars[:FolderRoot] + " " + _cFolderName_ + " (" + @acDisplayChars[:FolderRootSearchSymbol] + "" + _nTotalMatches_ + " file matches for '" + _cPattern_ + "')" + nl
		This.CollapseAll()
		_acFoldersWithMatches_ = This.GetFoldersContainingFileMatches(This.Path(), _cPattern_)
		if len(_acFoldersWithMatches_) > 0
			This.ExpandFolders(_acFoldersWithMatches_)
		end
		_cResult_ += This.GenerateVizTreeString(This.Path(), "", 1, _cPattern_, "files", 0, This.MaxDisplayLevel())
		return _cResult_

	def VizDeepFindFolders(_cPattern_)
		_nTotalMatches_ = This.CountFolderMatchesRecursive(This.Path(), _cPattern_)
		_cFolderName_ = This.Name()
		if _cFolderName_ = ""
			_cFolderName_ = This.Path()
		end
		_cResult_ = @acDisplayChars[:FolderRootXT] + " " + _cFolderName_ + " (" + @acDisplayChars[:FolderRootSearchSymbol] + + "  " + _nTotalMatches_ + " folder matches for '" + _cPattern_ + "')" + nl
		_cResult_ += This.GenerateVizTreeString(This.Path(), "", 1, _cPattern_, "folders", 0, This.MaxDisplayLevel())
		return _cResult_

		def VizDeepSearchDirs(_cPattern_)
			return This.VizDeepFindFolders(_cPattern_)

	def ToString()
		_cFolderName_ = This.Name()
		_cResult_ = @acDisplayChars[:FolderRoot] + " " + _cFolderName_ + NL

		_cResult_ += This.GenerateVizTreeString(
			This.Path(), '', 1,
			'', "", 0, This.MaxDisplayLevel()
		)

		return _cResult_

	def Show()
		? This.ToString()

	def ToStringXT()
		_cStatPattern_ = This.DisplayStatPattern()
		if _cStatPattern_ = ""
			_cStatPattern_ = _cStatPattern_ = "@count"
		ok

		_cFolderName_ = This.Name()
		_cStats_ = trim(This.FormatStats(This, _cStatPattern_))

		_cResult_ = @acDisplayChars[:FolderRootXT] + " " + _cFolderName_ + " " + _cStats_ + NL

		_cResult_ += This.GenerateVizTreeString(
			This.Path(), '', 1, _cStatPattern_,
			"showxt", 0, This.MaxDisplayLevel()
		)

		return _cResult_

	def ShowXT()
		? This.ToStringXT()

	#-------------------------#
	#  Display Configuration  #
	#-------------------------#

	def Expand()
		@bExpand = 1
		@bDeepExpandAll = 0
		@acDeepExpandFolders = []

		@bCollapseAll = 0
		@acCollapseFolders = []

		def ExpandAll()
			This.Expand()

	def ExpandFolder(_cFolder_)
		This.ExpandFolders([_cFolder_])

		def ExpandThisFolder(_cFolder_)
			This.ExpandFolders([_cFolder_])

		def ExpandThis(_cFolder_)
			This.ExpandFolders([cFolders])

	def ExpandFolders(_acFolders_)
	    if CheckParams()
	        if Not (isList(_acFolders_) and IsListOfStrings(_acFolders_))
	            StzRaise("Incorrect param type! acFolders must be a list of strings.")
	        ok
	    ok
	
		_nLen_ = len(_acFolders_)

		for i = 1 to _nLen_
			_cPath_ = This.NormalizeFolderPath(_acFolders_[i])
			if This.IsDeepFolder(_cPath_)
				@acDeepExpandFolders + _cPath_
			else
				@acExpandFolders + _cPath_
			ok
		next

	    @bCollapseAll = 0
	
		def ExpandTheseFolders(_acFolders_)
			This.ExpandFolders(_acFolders_)

		def ExpandThese(_acFolders_)
			This.ExpandTheseFolders(_acFolders_)

	#--

	def DeepExpandAll()
		@bExpand = 0
		@bDeepExpandAll = 1
		@acDeepExpandFolders = []

		@bCollapseAll = 0
		@acCollapseFolders = []

		def DeepExpand()
			This.DeepExpandAll()

	def DeepExpandFolder(_cFolder_)
		This.DeepExpandFolders([_cFolder_])
	
		def DeepExpandThisFolder(_cFolder_)
			This.DeepExpandFolders([_cFolder_])
	
		def DeepExpandThis(_cFolder_)
			This.DeepExpandFolders([_cFolder_])
	
	def DeepExpandFolders(_acFolders_)
		if isString(_acFolders_)
			@acDeepExpandFolders = [_acFolders_]
		else
			@acDeepExpandFolders = _acFolders_
		end
		@bCollapseAll = 0
		@bDeepExpandAll = 0

		def DeepExpandTheseFolders(_acFolders_)
			This.DeepExpandFolders(_acFolders_)
	
		def DeepExpandThese(_acFolders_)
			This.DeepExpandTheseFolders(_acFolders_)

	#--

	def CollapseAll()
		@bCollapseAll = 1
		@bExpand = 0
		@bDeepExpandAll = 0

		@acExpandFolders = []
		@acDeepExpandFolders = []

		def Collapse()
			This.CollapseAll()

	def CollapseFolders(_acFolders_)
		if isString(_acFolders_)
			@acCollapseFolders = [_acFolders_]
		else
			@acCollapseFolders = _acFolders_
		end
		@bExpand = 0
		@bDeepExpandAll = 0

		def CollapseTheseFolders(_acFolders_)
			This.CollapseFolders(_acFolders_)

		def CollapseThese(_acFolders_)
			This.CollapseFolders(_acFolders_)

	#---

	def MaxDisplayLevel()
		return @nMaxDisplayLevel

	def SetMaxDisplayLevel(n)
		if not isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
		@nMaxDisplayLevel = n

	def DisplayStatPattern()
		return @cDisplayStatPattern

		def DisplayStat()
			return @cDisplayStatPattern

	def SetDisplayStat(_cPattern_)
		if NOT isString(_cPattern_)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok

		if NOT This.IsStatPattern(_cPattern_)
			StzRaise("Incorrect start pattern!")
		ok

		@cDisplayStatPattern = _cPattern_

		def SetDisplayStartPattern(_cPattern_)
			This.SetDisplayStat(_cPattern_)

	def StatKeywords()
		return @acStatKeywords

	def IsStatPattern(_cPattern_)
		if Not isString(_cPattern_)
			return 0
		ok

		_cPattern_ = StzLower(_cPattern_)
		_acKeywords_ = This.StatKeywords()
		_nLen_ = len(_acKeywords_)
		_bResult_ = 0

		for i = 1 to _nLen_
			if StzFindFirst(_cPattern_, _acKeywords_[i]) > 0
				_bResult_ = 1
				exit
			ok
		next
		return _bResult_

	def DisplayOrder()
		return @cDisplayOrder

	def SetDisplayOrder(cOrder)
		if NOT isString(cOrder)
			StzRaise("Incorrect param type! cOrder must be a string.")
		ok
		_acValidOrders_ = ["systemorder", "filefirstascending", "filefirstdescending", "folderfirstascending", "folderfirstdescending"]
		if NOT StzFindFirst(StzLower(cOrder), _acValidOrders_)
			StzRaise("Invalid display order! Must be one of: " + @@(_acValidOrders_))
		ok
		@cDisplayOrder = StzLower(cOrder)

	#==========================#
	#  Checking Path Security  #
	#==========================#
	#TODO // Enhance this section

	def IsSecurePath(_cPath_)
		# Check for null bytes (path injection attempt)
		if StzFindFirst(StzChar(0), _cPath_) > 0
			return true
		ok

		# Check for other control characters that could be used for injection
		for i = 1 to 31
			if StzFindFirst(StzChar(i), _cPath_) > 0
				return false
			ok
		next
		
		return true

	def HasNoPathInjection(_cPath_)
		return This.IsSecurePath(_cPath_)

	#===================#
	#  Utility Methods  #
	#===================#

	def Copy()
		return new stzFolder(This.Path())

		def Clone()
			return This.Copy()

	def Refresh()
		# no-op: directory listing is always fresh via @dir()
		return This

	def GetParentDirectory(_cPath_)
		_nPos_ = 0
		_nLen_ = StzLen(_cPath_)
		for i = _nLen_ to 1 step -1
			if _cPath_[i] = This.Separator()
				_nPos_ = i
				exit
			ok
		next
		if _nPos_ > 1
			return StzLeft(_cPath_, _nPos_ - 1)
		else
			return This.Path()
		ok

	def GetPathHierarchy(_cPath_)
		_acParts_ = []
		_cRelativePath_ = StzReplace(_cPath_, This.Path() + This.Separator(), "")
		if _cRelativePath_ = _cPath_
			return []
		end
		_acSegments_ = @split(_cRelativePath_, This.Separator())
		_nLen_ = len(_acSegments_)

		for i = 1 to _nLen_
			if _acSegments_[i] != ""
				_acParts_ + _acSegments_[i]
			end
		next

		return _acParts_

	def CollectFoldersWithFileMatches(_cPath_, _cPattern_, aFoldersWithMatches)

		_aList_ = @dir(_cPath_)
		_bHasFileMatches_ = 0
		_nLen_ = len(_aList_)

		for i = 1 to _nLen_
			if _aList_[i][2] = 0
				if This.Matches(_cPattern_, _aList_[i][1])
					_bHasFileMatches_ = 1
					exit
				end
			end
		next

		if _bHasFileMatches_
			aFoldersWithMatches + _cPath_
		end

		for i = 1 to _nLen_
			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				This.CollectFoldersWithFileMatches(_cPath_ + This.Separator() + _aList_[i][1], _cPattern_, aFoldersWithMatches)
			end
		next


		def GetFolderNameFromPath(_cPath_)
			if _cPath_ = This.Path()
				return ""
			end
			_nPos_ = max([StzFindFirst(This.Separator(), _cPath_), StzFindFirst("\", _cPath_)])
			if _nPos_ > 0
				return StzRight(_cPath_, StzLen(_cPath_) - _nPos_)
			end
			return _cPath_


	#================================#
	#  PRIVATE KITCHEN OF THE CLASS  #
	#================================#

	PRIVATE

	def SortItemsByDisplayOrder(_acFiles_, _acFolders_, _cPath_)

		_aItems_ = []

		switch @cDisplayOrder

			case "systemorder"

				_aRingEntries_ = dir(_cPath_)
				_nLen_ = len(_aRingEntries_)
				for i = 1 to _nLen_
					_cEntryName_ = _aRingEntries_[i][1]
					if _cEntryName_ != "." and _cEntryName_ != ".."
						_cFullPath_ = _cPath_ + This.Separator() + _cEntryName_
						if isdir(_cFullPath_)
							_aItems_ + [_cEntryName_, "folder"]
						else
							_aItems_ + [_cEntryName_, "file"]
						end
					end
				next

			case "filefirstascending"

				_acFilesSorted_ = sort(_acFiles_)
				_acFoldersSorted_ = sort(_acFolders_)
				_nLen_ = len(_acFilesSorted_)

				for i = 1 to _nLen_
					_aItems_ + [_acFilesSorted_[i], "file"]
				next

				_nLen_ = len(_acFoldersSorted_)
				for i = 1 to _nLen_
					_aItems_ + [_acFoldersSorted_[i], "folder"]
				next

			case "filefirstdescending"

				_acFilesSorted_ = reverse(sort(_acFiles_))
				_acFoldersSorted_ = reverse(sort(_acFolders_))

				_nLen_ = len(_acFilesSorted_)
				for i = 1 to _nLen_
					_aItems_ + [_acFilesSorted_[i], "file"]
				next

				_nLen_ = len(_acFoldersSorted_)
				for i = 1 to _nLen_
					_aItems_ + [_acFoldersSorted_[i], "folder"]
				next

			case "folderfirstascending"

				_acFilesSorted_ = sort(_acFiles_)
				_acFoldersSorted_ = sort(_acFolders_)

				_nLen_ = len(_acFoldersSorted_)
				for i = 1 to _nLen_
					_aItems_ + [_acFoldersSorted_[i], "folder"]
				next

				_nLen_ = len(_acFilesSorted_)
				for i = 1 to _nLen_
					_aItems_ + [_acFilesSorted_[i], "file"]
				next

			case "folderfirstdescending"

				_acFilesSorted_ = reverse(sort(_acFiles_))
				_acFoldersSorted_ = reverse(sort(_acFolders_))

				_nLen_ = len(_acFoldersSorted_)
				for i = 1 to _nLen_
					_aItems_ + [_acFoldersSorted_[i], "folder"]
				next

				_nLen_ = len(_acFilesSorted_)
				for  i = 1 to _nLen_
					_aItems_ + [_acFilesSorted_[i], "file"]
				next

		end

		return _aItems_

	def OrderFilesFirst(_acFiles_, _acFolders_)

		_aResult_ = []

		_nLen_ = len(_acFiles_)
		for i = 1 to _nLen_
			_aResult_ + [:name = _acFiles_[i], :type = "file"]
		next

		_nLen_ = len(_acFolders_)
		for i = 1 to _nLen_
			_aResult_ + [:name = _acFolders_[i], :type = "folder"]
		next

		return _aResult_


	def OrderFoldersFirst(_acFiles_, _acFolders_)

		_aResult_ = []

		_nLen_ = len(_acFolders_)
		for i = 1 to _nLen_
			_aResult_ + [:name = _acFolders_[i], :type = "folder"]
		next

		_nLen_ = len(_acFiles_)
		for i = 1 to _nLen_
			_aResult_ + [:name = _acFiles_[i], :type = "file"]
		next

		return _aResult_


	def GetPhysicalOrder(_cPath_)

		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)

		_aResult_ = []

		for i = 1 to _nLen_

			if _aList_[i][2] = 0
				_aResult_ + [:name = _aEntry_[1], :type = "file"]

			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				_aResult_ + [:name = _aList_[i][1], :type = "folder"]

			end

		next

		return _aResult_


	def FormatStats(oFolder, _cStatPattern_)
		# Handle @count pattern specifically

		if _cStatPattern_ = "@count"

			_nTotal_ = oFolder.CountFiles() + oFolder.CountFolders()

			if _nTotal_ > 0
				return "(" + _nTotal_ + ")"
			else
				return ""
			end

		ok
		
		# Handle custom patterns by replacing tokens

		_cResult_ = StzLower(_cStatPattern_)
		
		# Replace pattern tokens with actual values

		_nThisLevelFiles_ = oFolder.CountFiles()
		_nThisLevelFolders_ = oFolder.CountFolders()
		_nAllSubLevelFiles_ = oFolder.DeepCountFiles()
		_nAllSubLevelFolders_ = oFolder.DeepCountFolders()
	
		if StzFindFirst("@countfiles", _cResult_)
			_cResult_ = StzReplace(_cResult_, "@countfiles", "" + _nThisLevelFiles_)
		ok

		if StzFindFirst("@deepcountfiles", _cResult_)
			_cResult_ = StzReplace(_cResult_, "@deepcountfiles", "" + _nAllSubLevelFiles_)
		ok

		if StzFindFirst("@countfolders", _cResult_)
			_cResult_ = StzReplace(_cResult_, "@countfolders", "" + _nThisLevelFolders_)
		ok

		if StzFindFirst("@deepcountfolders", _cResult_)
			_cResult_ = StzReplace(_cResult_, "@deepcountfolders", "" + _nAllSubLevelFolders_)
		ok

		# If tokens were replaced (custom pattern), handle zero filtering

		if _cResult_ != _cStatPattern_

			# Split by comma and filter out zero values

			_aTokens_ = @split(_cResult_, ",")
			_nLen_ = len(_aTokens_)
			_acFiltered_ = []

			for i = 1 to _nLen_

				_cToken_ = trim(_aTokens_[i])

				# Check if this token contains "0 files" or "0 folders"

				if not (StzFindFirst("0 files", _cToken_) or StzFindFirst("0 folders", _cToken_))
					_acFiltered_ + _cToken_
				ok
			next
			
			# Rebuild the result

			_cResult_ = "("
			_nLenF_ = len(_acFiltered_)

			for i = 1 to _nLenF_
				_cResult_ += _acFiltered_[i]
				if i < _nLenF_
					_cResult_ += ", "
				ok
			next

			_cResult_ += ")"

		else

			# If no tokens were replaced, fall back to original logic
			# Get direct counts for this folder level

			_nThisLevelFiles_ = oFolder.CountFiles()
			_nThisLevelFolders_ = oFolder.CountFolders()
			
			# Get recursive counts for all sublevels

			_nAllSubLevelFiles_ = oFolder.DeepCountFiles()
			_nAllSubLevelFolders_ = oFolder.DeepCountFolders()
	
			_cResult_ = "("
			
			# Files display logic

			if _nThisLevelFiles_ > 0

				if _nAllSubLevelFiles_ > _nThisLevelFiles_
					_cResult_ += ''+ _nThisLevelFiles_ + ":" + _nAllSubLevelFiles_ + " files"
				else
					_cResult_ += ''+ _nThisLevelFiles_ + " files"
				end
				
				# Add comma if we also have folders

				if _nThisLevelFolders_ > 0 or _nAllSubLevelFolders_ > _nThisLevelFolders_
					_cResult_ += ", "
				end
			end
			
			# Folders display logic

			if _nThisLevelFolders_ > 0
				if _nAllSubLevelFolders_ > _nThisLevelFolders_
					_cResult_ += ''+ _nThisLevelFolders_ + ":" + _nAllSubLevelFolders_ + " folders"
				else
					_cResult_ += ''+ _nThisLevelFolders_ + " folders"
				end
			end
			
			_cResult_ += ")"
			
			# If no files or folders, return empty string to avoid showing "()"

			if _nThisLevelFiles_ = 0 and _nThisLevelFolders_ = 0 and _nAllSubLevelFiles_ = 0 and _nAllSubLevelFolders_ = 0
				return ""
			end
		end
		
		return _cResult_


	def GetFolderStats(_cFolderName_)

		# Get stats for a specific subfolder

		_cFolderPath_ = @cCurrentPath + This.Separator() + _cFolderName_
		
		if @cDisplayStatPattern = "@count"

			# Simple count for default pattern

			try
				_aList_ = @dir(_cFolderPath_)
			catch
				return ""
			end
			
			_nCount_ = 0
			_nLen_ = len(_aList_)

			for i = 1 to _nLen_
				if _aList_[i][1] != "." and _aList_[i][1] != ".."
					_nCount_++
				end
			next
			
			if _nCount_ > 0
				return "" + _nCount_
			else
				return ""
			ok

		else
			# Use pattern for custom display

			return This.FormatStatsForFolder(_cFolderName_, @cDisplayStatPattern)
		ok


	def FormatStatsForFolder(_cFolderName_, _cPattern_)

		# Format stats for a specific folder

		_cResult_ = _cPattern_
		_cFolderPath_ = @cCurrentPath + This.Separator() + _cFolderName_
		
		# Get actual counts for this folder

		_nFiles_ = This.CountFilesIn(_cFolderPath_)
		_nFolders_ = This.CountFoldersIn(_cFolderPath_)
		_nDeepFiles_ = This.DeepCountFilesIn(_cFolderPath_)
		_nDeepFolders_ = This.DeepCountFoldersIn(_cFolderPath_)
		
		# Replace patterns

		if StzFindFirst("@countfiles", _cResult_) or StzFindFirst("@countfiles", _cResult_)
			_cResult_ = StzReplace(_cResult_, "@countfiles", "" + _nFiles_)
			_cResult_ = StzReplace(_cResult_, "@countfiles", "" + _nFiles_)
		ok

		if StzFindFirst("@deepcountfiles", _cResult_)
			_cResult_ = StzReplace(_cResult_, "@deepcountfiles", "" + _nDeepFiles_)
		ok

		if StzFindFirst("@countfolders", _cResult_) or StzFindFirst("@countfolders", _cResult_)
			_cResult_ = StzReplace(_cResult_, "@countfolders", "" + _nFolders_)
			_cResult_ = StzReplace(_cResult_, "@countfolders", "" + _nFolders_)
		ok

		if StzFindFirst("@deepcountfolders", _cResult_)
			_cResult_ = StzReplace(_cResult_, "@deepcountfolders", "" + _nDeepFolders_)
		ok
		
		return _cResult_

	def CountFileMatchesRecursive(_cPath_, _cPattern_)

		_nCount_ = 0
		try
			_aList_ = @dir(_cPath_)
		catch
			return 0
		end

		_nLen_ = len(_aList_)

		for i = 1 to _nLen_

			if _aList_[i][2] = 0
				if This.Matches(_cPattern_, _aList_[i][1])
					_nCount_++
				end

			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				_nCount_ += This.CountFileMatchesRecursive(_cPath_ + This.Separator() + _aList_[i][1], _cPattern_)
			end

		next

		return _nCount_

	def CountFolderMatchesRecursive(_cPath_, _cPattern_)
		_nCount_ = 0

		try
			_aList_ = @dir(_cPath_)
		catch
			return 0
		end

		_nLen_ = len(_aList_)

		for i = 1 to _nLen_

			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."

				if This.Matches(_cPattern_, _aList_[i][1])
					_nCount_++
				end

				_nCount_ += This.CountFolderMatchesRecursive(_cPath_ + This.Separator() + _aList_[i][1], _cPattern_)
			end

		next

		return _nCount_

	def ShouldExpandFolder(_cFolderName_)

		if @bCollapseAll
			return 0
		end

		_cFolderName_ = This.NormalizeFolderPath(_cFolderName_)

		# If DeepExpandAll is enabled, expand all non-empty folders

		if @bDeepExpandAll

			if This.IsFolderEmpty(_cFolderName_)
				return 0
			else
				return 1
			end

		end

		if @bExpand

			_nLen_ = len(@acCollapseFolders)
			for i = 1 to _nLen_
				if This.Matches(@acCollapseFolders[i], _cFolderName_)
					return 0
				end
			next

			if This.IsFolderEmpty(_cFolderName_)
				return 0
			else
				return 1
			end

		end

		_nLen_ = len(@acExpandFolders)
		for i = 1 to _nLen_ 
			if This.Matches(@acExpandFolders[i], _cFolderName_)
				return 1
			end
		next

		return 0


	def GetFolderIconForExpanded(_bSubfolderHasMatches_, _bIsEmpty_)

		if _bSubfolderHasMatches_
			return @acDisplayChars[:FolderOpenedFound]
		else
			return @acDisplayChars[:FolderOpened]
		end

	def GetFolderIconForCollapsed(_bIsEmpty_)
		if _bIsEmpty_
			return @acDisplayChars[:FolderClosedEmpty]
		else
			return @acDisplayChars[:FolderClosedFull]
		end

	def ChooseFolderIcon(_bShouldExpand_, _bSubfolderHasMatches_, _bIsEmpty_)
		if _bShouldExpand_
			return This.GetFolderIconForExpanded(_bSubfolderHasMatches_, _bIsEmpty_)
		else
			return This.GetFolderIconForCollapsed(_bIsEmpty_)
		end

	def GenerateVizTreeString(_cPath_, _cPrefix_, bIsRoot, _cPattern_, cSearchType, nCurrentLevel, nMaxLevels)
	    if nCurrentLevel >= nMaxLevels
	        return ""
	    end
	    
	    _cResult_ = ""
	    _aList_ = @dir(_cPath_)

	    
	    # Separate files and folders
	    _aFiles_ = []
	    _aFolders_ = []
	    _nLen_ = len(_aList_)

		for i = 1 to _nLen_

	        if _aList_[i][2] = 0  # File
	            _aFiles_ + _aList_[i][1]

	        but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # Folder
	            _aFolders_ + _aList_[i][1]
	        end

	    next
	    
	    # Apply sorting based on display order
	    _aItems_ = This.SortItemsByDisplayOrder(_aFiles_, _aFolders_, _cPath_)
	    _nTotalItems_ = len(_aItems_)
	    
	    # Display items in sorted order
	    for i = 1 to _nTotalItems_
	        _aItem_ = _aItems_[i]
	        _cItemName_ = _aItem_[1]
	        _cItemType_ = _aItem_[2]  # "file" or "folder"
	        _bIsLastItem_ = (i = _nTotalItems_)
	        
	        if _cItemType_ = "file"
	            # Check if file matches the search pattern
	            _bFileMatches_ = 0
	            if cSearchType = "files" or cSearchType = "both"
	                _bFileMatches_ = This.Matches(_cPattern_, _cItemName_)
	            end
	            
	            # Show ALL files in expanded folders
	            _cIcon_ = @acDisplayChars[:File]  # Default file icon
	            
	            # Add found indicator if file matches
	            if _bFileMatches_
	                _cIcon_ += @acDisplayChars[:FileFoundSymbol]  # Found file gets the found-file marker
	            end
	            
	            # Use correct connector based on position
	            if _bIsLastItem_
	                _cResult_ += _cPrefix_ + @acDisplayChars[:ClosingChar] + (char(226)+char(148)+char(128)) + _cIcon_ + " " + _cItemName_ + nl
	            else
	                _cResult_ += _cPrefix_ + @acDisplayChars[:VerticalCharTick] + (char(226)+char(148)+char(128)) + _cIcon_ + " " + _cItemName_ + nl
	            end
	            
	        else  # folder
	            _cItemPath_ = _cPath_ + This.Separator() + _cItemName_
	            _oSubFolder_ = new stzFolder(_cItemPath_)
	            
	            # Check if folder matches the search pattern
	            _bFolderMatches_ = 0
	            if cSearchType = "folders" or cSearchType = "both"
	                _bFolderMatches_ = This.Matches(_cPattern_, _cItemName_)
	            end
	            
	            # Check if subfolder contains matches
	            _nSubfolderFileMatches_ = 0
	            _nSubfolderFolderMatches_ = 0
	            _bSubfolderHasMatches_ = 0
	            
	            if cSearchType = "files" or cSearchType = "both"
	                _nSubfolderFileMatches_ = This.CountFileMatchesRecursive(_cItemPath_, _cPattern_)
	                if _nSubfolderFileMatches_ > 0
	                    _bSubfolderHasMatches_ = 1
	                end
	            end
	            
	            if cSearchType = "folders" or cSearchType = "both"
	                _nSubfolderFolderMatches_ = This.CountFolderMatchesRecursive(_cItemPath_, _cPattern_)
	                if _nSubfolderFolderMatches_ > 0
	                    _bSubfolderHasMatches_ = 1
	                end
	            end
	            
	            # Use ShouldExpandFolder for normal display, OR expand if has search matches
	            _bShouldExpand_ = This.ShouldExpandFolder(_cItemName_) or _bSubfolderHasMatches_ or This.ShouldDeepExpandFolder(_cItemPath_)
	            
	            _bHasFiles_ = _oSubFolder_.CountFiles() > 0
	            _bHasFolders_ = _oSubFolder_.CountFolders() > 0
	            _bIsEmpty_ = (not _bHasFiles_ and not _bHasFolders_)
	            
	            # Choose correct folder icon using dedicated method
	            _cIcon_ = This.ChooseFolderIcon(_bShouldExpand_, _bSubfolderHasMatches_, _bIsEmpty_)
	            
	            # Add found indicator if folder itself matches
	            if _bFolderMatches_
	                _cIcon_ += @acDisplayChars[:FileFoundSymbol]
	            end
	            
	            # Build match count display (only for folders with matches)
	            _cMatchCount_ = ""
	            _nTotalMatches_ = _nSubfolderFileMatches_ + _nSubfolderFolderMatches_
	            if _nTotalMatches_ > 0
	                _cMatchCount_ = " (" + _nTotalMatches_ + ")"
	            end
	            
	            # Add stats for ShowXT mode for non-empty folders
	            _cFolderStats_ = ""
	            if cSearchType = "showxt" and not _bIsEmpty_
	                _cStats_ = trim(This.FormatStats(_oSubFolder_, _cPattern_))
	                if _cStats_ != ""
	                    _cFolderStats_ = " " + _cStats_
	                end
	            end
	            
	            # Build the line - use correct connector based on position
	            if _bIsLastItem_
	                _cResult_ += _cPrefix_ + @acDisplayChars[:ClosingChar] + (char(226)+char(148)+char(128)) + _cIcon_ + " " + _cItemName_ + _cMatchCount_ + _cFolderStats_ + nl
	                _cNewPrefix_ = _cPrefix_ + "  "  # No vertical line continuation for last item
	            else
	                _cResult_ += _cPrefix_ + @acDisplayChars[:VerticalCharTick] + (char(226)+char(148)+char(128)) + _cIcon_ + " " + _cItemName_ + _cMatchCount_ + _cFolderStats_ + nl
	                _cNewPrefix_ = _cPrefix_ + @acDisplayChars[:VerticlalChar] + " "  # Continue vertical line
	            end
	            
	            # Recurse into subfolder if should be expanded
	            if _bShouldExpand_ and nCurrentLevel + 1 < nMaxLevels
	                _cResult_ += This.GenerateVizTreeString(_cItemPath_, _cNewPrefix_, 0, _cPattern_, cSearchType, nCurrentLevel + 1, nMaxLevels)
	            end
	        end
	    next
	    
	    return _cResult_


	def ShouldDeepExpandFolder(_cFolderPath_)

		# If DeepExpandAll is enabled, expand all folders
		if @bDeepExpandAll
			return 1
		end
		
		if @acDeepExpandFolders = NULL
			return 0
		end
		
		_nLen_ = len(@acDeepExpandFolders)

		for i = 1 to _nLen_
			# Check if current folder is under a deep expand folder
			if This.IsSubfolderOf(_cFolderPath_, @acDeepExpandFolders[i])
				return 1
			end
		next
		
		return 0
