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
	if StzLen(_cPath_) = 0 return 0 ok
	if StzLeft(_cPath_, 1) = "/" return 1 ok
	if StzLen(_cPath_) >= 2 and isalpha(StzLeft(_cPath_, 1)) and StzMid(_cPath_, 2, 1) = ":"
		return 1
	ok
	return 0

func _IsRootPath(_cPath_)
	_cPath_ = _CleanPath(_cPath_)
	if _cPath_ = "/" return 1 ok
	if StzLen(_cPath_) = 2 and isalpha(StzLeft(_cPath_, 1)) and StzRight(_cPath_, 1) = ":"
		return 1
	ok
	if StzLen(_cPath_) = 3 and isalpha(StzLeft(_cPath_, 1)) and StzMid(_cPath_, 2, 1) = ":" and StzRight(_cPath_, 1) = "/"
		return 1
	ok
	return 0

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

# Folds the . and .. segments of a path, so that a fence tested on text cannot
# be walked round with sub1/../../x. A drive such as D: and a leading slash
# are never popped. A .. that has nothing left to pop is dropped on an
# absolute path and kept on a relative one.
func _CollapseDots(_cPath_)
	_cPath_ = _CleanPath(_cPath_)
	_nLen_ = StzLen(_cPath_)
	_bLeading_ = 0
	if _nLen_ > 0 and _cPath_[1] = "/"
		_bLeading_ = 1
	ok
	_acStack_ = []
	_cSeg_ = ""
	for i = 1 to _nLen_ + 1
		if i > _nLen_ or _cPath_[i] = "/"
			if _cSeg_ = ".."
				_nStack_ = len(_acStack_)
				_bDrive_ = (_nStack_ = 1 and StzLen(_acStack_[1]) = 2 and StzRight(_acStack_[1], 1) = ":")
				if _nStack_ > 0 and _acStack_[_nStack_] != ".." and NOT _bDrive_
					del(_acStack_, _nStack_)
				but _nStack_ = 0 and NOT _bLeading_
					_acStack_ + ".."
				ok
			but _cSeg_ != "" and _cSeg_ != "."
				_acStack_ + _cSeg_
			ok
			_cSeg_ = ""
		else
			_cSeg_ += _cPath_[i]
		ok
	next
	_cResult_ = ""
	_nStack_ = len(_acStack_)
	for i = 1 to _nStack_
		if i > 1
			_cResult_ += "/"
		ok
		_cResult_ += _acStack_[i]
	next
	if _bLeading_
		_cResult_ = "/" + _cResult_
	ok
	return _cResult_

# Returns the non-empty segments of a path, without its drive slash.
func _PathSegments(_cPath_)
	_cPath_ = _CleanPath(_cPath_)
	_acSeg_ = []
	_cSeg_ = ""
	_nLen_ = StzLen(_cPath_)
	for i = 1 to _nLen_ + 1
		if i > _nLen_ or _cPath_[i] = "/"
			if _cSeg_ != ""
				_acSeg_ + _cSeg_
			ok
			_cSeg_ = ""
		else
			_cSeg_ += _cPath_[i]
		ok
	next
	return _acSeg_

# Says what an absolute path is on disk: "file", "folder" or "" (nothing there).
# The last name is looked up in the listing of its parent, which is lowercased
# whatever the file system, so the answer ignores case everywhere. A drive or
# filesystem root is a folder.
func _KindOfPath(_cAbs_)
	_cAbs_ = _CleanPath(_cAbs_)
	if _cAbs_ = ""
		return ""
	ok
	if _IsRootPath(_cAbs_)
		return "folder"
	ok
	_cParent_ = _ParentPath(_cAbs_)
	if _cParent_ = _cAbs_
		return ""
	ok
	if StzLen(_cParent_) = 2 and StzRight(_cParent_, 1) = ":"
		_cParent_ += "/"
	ok
	if NOT StzEngineDirExists(_cParent_)
		return ""
	ok
	_cName_ = StzLower(_DirName(_cAbs_))
	_aList_ = @dir(_cParent_)
	_nLen_ = len(_aList_)
	for i = 1 to _nLen_
		if _aList_[i][1] = _cName_
			if _aList_[i][2] = 1
				return "folder"
			ok
			return "file"
		ok
	next
	return ""

#-------------#
#  THE CLASS  #
#-------------#

# Holds a folder as a position you can walk, and lists, finds, searches, edits, creates, copies and deletes the files and folders under it.
#
# A stzFolder is built on a path, created when it is missing, and keeps a current position, a home
# to return to (GoHome) and a history (GoBack). Listings are of the position, in lowercase: Files
# and Folders give the direct children as /name and /name/, DeepFiles and DeepFolders walk the whole
# tree. Find, Search and Modify come in three reaches: this folder (FindFiles, SearchInFiles,
# ModifyInRoot), one named child folder, and the Deep forms below. A path given to a method is
# read from the current position, never from the process folder, so sub1/d.txt, /sub1/d.txt and the
# absolute path name the same file; only the constructor, the In methods that take a folder path to
# search (DeepCountFilesIn and the like) and the file functions outside the class read the process
# folder. Whether a path is held here is decided on disk, at any depth below the position, and the .
# and .. segments are folded first, so a path cannot step out of the position. Many file methods
# finish by moving the position into the folder of the file when it is below the position;
# SetBatchMode(1) turns that off. The delete methods are real: DeleteFolder, DeleteAll, Erase,
# DeepRemoveAll, DeepErase, DeepDeleteFile and DeepDeleteFolder remove what they name, and GoUp can
# lift the position above the home, so point an object at a folder you can afford to lose. GoTo does
# not check that the folder exists, and CollapseFolders has no visible effect, each carried as a
# warning on its method.
#
#   receiver   o1 = new stzFolder(currentDir())
#   example    ? o1.IsReadable()
#              #--> 1
#   see        stzFile, stzString, stzObject
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

	@bBacthMode = 0

	#== Initialization ==#

	# Holds a folder as its current position and its home, creating the folder when it is missing; an empty text means the process folder.
	#
	#   pcDirPath   The folder to hold, as a path; a missing folder is created, and an empty text
	#               means the current process folder.
	#   returns     nothing; the object is built
	#   note        A relative path is resolved against the process folder, and a missing one is
	#               created there, so pass an absolute path; the engine creates every missing level
	#   warning     A file path, or an argument that is not text, raises an error
	#   see         Path, GoHome, Root
	def init(pcDirPath)

		if CheckParams() and NOT isString(pcDirPath)
			StzRaise("Incorrect param type! pcDirPath must be a string.")
		ok

		@acPathHistory = []

		_cPath_ = ""
		if pcDirPath = "" or pcDirPath = ""
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
	
	# Returns the separator used in the paths this class builds, always a forward slash.
	#
	#   returns    text, "/"
	#   see        SystemSeparator
	def Separator()
		return "/"
	
		#-- @Misspelled

		def Seperator()
			# Was `This.Seprator()` (typo, missing 'a') -- R14 every
			# call. Misspelled alias forwarded to a non-existent
			# misspelling of the canonical Separator.
			return This.Separator()

	# Returns the separator of the operating system, a backslash on Windows and a forward slash elsewhere.
	#
	#   returns    text
	#   see        Separator
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

	# TRUE if a path lies strictly below the current position, the position itself excluded, ignoring case.
	#
	#   _cPath_    an absolute path, or a name or path relative to the current position
	#   returns    TRUE or FALSE
	#   note       The path need not exist; GoTo and the create methods use it as their fence. A
	#              relative name such as sub1 is read from the current position, and the . and ..
	#              segments are folded first, so sub1/../../x is outside
	#   warning    Raises an error for an empty text
	#   see        IsOutside, GoTo
	def IsInside(_cPath_)
	
	    if NOT ( isString(_cPath_) and _cPath_ != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok
	
		_cMainPath_ = _CleanPath(@cCurrentPath)
		_cAbsolutePath_ = This._ResolveInHere(_cPath_)

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
					return 1
				ok
			ok
		ok

		return 0
	
		def IsPathInside(_cPath_)
			return This.IsInside(_cPath_)
	
		def PathIsInside(_cPath_)
			return This.IsInside(_cPath_)
	
	# TRUE if a path does not lie strictly below the current position, the opposite of the inside test.
	#
	#   _cPath_    an absolute path
	#   returns    TRUE or FALSE
	#   note       The position itself counts as outside
	#   see        IsInside
	def IsOutside(_cPath_)
		return NOT This.IsInside(_cPath_)
	
		def IsPathOutside(_cPath_)
			return This.IsOutside(_cPath_)
	
		def PathIsOutside(_cPath_)
			return This.IsOutside(_cPath_)
	
	
	# Turns a path into the absolute, dot-free path it names HERE: a drive path
	# or a path that already starts with this position is kept, and anything
	# else, a bare name (sub1/d.txt) or the listing form (/sub1/), is joined to
	# the current position. The process folder plays no part.
	def _ResolveInHere(_cPath_)
		_cPath_ = _CleanPath(_cPath_)
		_cPos_ = _CleanPath(@cCurrentPath)
		_bAbsolute_ = 0
		if StzLen(_cPath_) >= 2 and isalpha(StzLeft(_cPath_, 1)) and StzMid(_cPath_, 2, 1) = ":"
			_bAbsolute_ = 1
		but StzLeft(_cPath_, 1) = "/"
			_cPosLow_ = StzLower(_cPos_)
			_cPathLow_ = StzLower(_cPath_)
			if _cPathLow_ = _cPosLow_ or StzLeft(_cPathLow_, StzLen(_cPosLow_) + 1) = (_cPosLow_ + "/")
				_bAbsolute_ = 1
			ok
		ok
		if NOT _bAbsolute_
			_cPath_ = _CleanPath(_cPos_ + "/" + _cPath_)
		ok
		return _CollapseDots(_cPath_)

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

	# TRUE if a path names a file held here, at any depth below the current position, ignoring case.
	#
	#   _cPath_    a file name, a sub-path such as sub1/d.txt, the listing form /a.txt, or an absolute path
	#   returns    TRUE or FALSE
	#   note       The path is read from the current position and looked up on disk, so a file two
	#              levels down is found and a file that is not there is not, whatever its last name
	#   warning    Raises an error for an empty text
	#   see        Exists, IsFolder, ContainsFile
	def IsFile(_cPath_)

	    if NOT ( isString(_cPath_) and _cPath_ != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok

	    return This._IsKindHere(_cPath_, "file")

	    def IsValidFile(_cPath_)
	        return This.IsFile(_cPath_)

	    def IsExistingFile(_cPath_)
	        return This.IsFile(_cPath_)

	# TRUE if a path names a folder held here, at any depth below the current position, ignoring case.
	#
	#   _cPath_    a folder name, a sub-path such as sub1/deep1, the listing form /sub1/, or an absolute path
	#   returns    TRUE or FALSE
	#   note       The path is read from the current position and looked up on disk; a trailing
	#              slash is ignored, and the position itself is not held here
	#   warning    Raises an error for an empty text
	#   see        Exists, IsFile, ContainsFolder
	def IsFolder(_cPath_)

	    if NOT ( isString(_cPath_) and _cPath_ != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok

	    return This._IsKindHere(_cPath_, "folder")

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

	# Says whether a path, resolved here, is a file or a folder held below the position.
	#
	#   _cPath_    the path to look up
	#   _cKind_    "file" or "folder"
	#   returns    1 or 0
	#   note       The one place that decides what held here means: inside the position and present on disk
	def _IsKindHere(_cPath_, _cKind_)
	    _cAbs_ = This._ResolveInHere(_cPath_)
	    if NOT This.IsInside(_cAbs_)
	        return 0
	    ok
	    if _KindOfPath(_cAbs_) = _cKind_
	        return 1
	    ok
	    return 0

	# TRUE if a path names a file or a folder held here, at any depth below the current position.
	#
	#   _cPath_    a path, as text
	#   returns    TRUE or FALSE
	#   note       Exists answers the same; the path is looked up on disk after a check that it holds
	#              no control character
	#   warning    Raises an error for an empty text or a path with a control character
	#   see        Exists, IsFile, IsFolder
	def IsPath(_cPath_)
		return This.IsFilePath(_cPath_) or This.IsFolderPath(_cPath_)

	# TRUE if a path names a file held here, after a check that the path holds no control character.
	#
	#   _cPath_    a file name or a path below the current position
	#   returns    TRUE or FALSE
	#   note       Behaves like IsFile apart from the security check
	#   warning    Raises an error for an empty text or a path with a control character
	#   see        IsFile, IsFolderPath
	def IsFilePath(_cPath_)
		if CHeckParams()
			if NOT (isString(_cPath_) and _cPath_ != "")
				raise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		# Check for path injection attempts
		if NOT This.IsSecurePath(_cPath_)
			raise("Insecure path with potential injection risks!")
		ok

		return This._IsKindHere(_cPath_, "file")

	# TRUE if a path names a folder held here, after a check that the path holds no control character.
	#
	#   _cPath_    a folder name or a path below the current position
	#   returns    TRUE or FALSE
	#   note       Behaves like IsFolder apart from the security check
	#   warning    Raises an error for an empty text or a path with a control character
	#   see        IsFolder, IsFilePath
	def IsFolderPath(_cPath_)
		if CHeckParams()
			if NOT (isString(_cPath_) and _cPath_ != "")
				raise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		# Check for path injection attempts
		if NOT This.IsSecurePath(_cPath_)
			raise("Insecure path with potential injection risks!")
		ok

		return This._IsKindHere(_cPath_, "folder")

	# TRUE if a path names a file or a folder at least two levels below the current position.
	#
	#   _cPath_    a path written as a name below the position, such as sub1/d.txt or /sub1/d.txt
	#   returns    TRUE or FALSE
	#   note       The path is looked up on disk: /sub1/d.txt answers TRUE when that file exists,
	#              /a.txt answers FALSE because it is only one level down, and /nothing/zz.txt FALSE
	#   see        IsDeepFile, IsDeepFolder, DeepExists
	def IsDeep(_cPath_)
		if This.IsDeepFile(_cPath_) or This.IsDeepFolder(_cPath_)
			return 1
		else
			return 0
		ok

		# Tells whether a path is at least two levels deep and exists, the same verdict as IsDeep.
		#
		#   _cPath_    a path below the position
		#   returns    TRUE or FALSE
		#   see        IsDeep
		def IsDeepPath(_cPath_)
			return This.IsDeep(_cPath_)

	# TRUE if a path names a file that exists at least two levels below the current position.
	#
	#   _cPath_    a path below the position, such as /sub1/d.txt
	#   returns    TRUE or FALSE
	#   note       A file directly in the position, such as /a.txt, is one level down and answers FALSE
	#   see        IsDeep, IsDeepFolder
	def IsDeepFile(_cPath_)
		if NOT This._IsKindHere(_cPath_, "file")
			return 0
		ok
		if This._LevelsBelowHere(_cPath_) >= 2
			return 1
		ok
		return 0

		def IsDeepFilePath(_cPath_)
			return This.IsDeepFile(_cPath_)

	# TRUE if a path names a folder that exists at least two levels below the current position.
	#
	#   _cPath_    a path below the position, with or without the trailing slash
	#   returns    TRUE or FALSE
	#   note       /sub1/deep1 answers TRUE when it exists and /sub1/ answers FALSE; a folder that is
	#              not on disk answers FALSE
	#   see        IsDeep, IsDeepFile
	def IsDeepFolder(_cPath_)
		if NOT This._IsKindHere(_cPath_, "folder")
			return 0
		ok
		if This._LevelsBelowHere(_cPath_) >= 2
			return 1
		ok
		return 0

		def IsDeepFolderPath(_cPath_)
			return This.IsDeepFolder(_cPath_)

	# Counts the levels between the position and a path below it, a direct child being one level.
	#
	#   _cPath_    a path below the position
	#   returns    a number, 0 when the path is not below the position
	def _LevelsBelowHere(_cPath_)
		_cAbs_ = This._ResolveInHere(_cPath_)
		if NOT This.IsInside(_cAbs_)
			return 0
		ok
		_nStart_ = StzLen(_CleanPath(@cCurrentPath)) + 2
		_cRel_ = StzMid(_cAbs_, _nStart_, StzLen(_cAbs_) - _nStart_ + 1)
		if _cRel_ = ""
			return 0
		ok
		_nLevels_ = 1
		_nLen_ = StzLen(_cRel_)
		for i = 1 to _nLen_
			if _cRel_[i] = "/"
				_nLevels_++
			ok
		next
		return _nLevels_

	# Tells whether a path, once made a folder path, is written with at least three separators, as /sub1/deep1/.
	#
	#   _cPath_    a path
	#   returns    1 or 0
	#   note       Pure shape, nothing is read from disk: the expand lists take names that may not exist yet
	def _IsDeepFolderShape(_cPath_)
		_cPath_ = This.NormalizeFolderPath(_cPath_)
		if StringNumberOfOccurrence(_cPath_, This.Separator()) > 2
			return 1
		ok
		return 0

	# TRUE if a folder holds no file and no folder; a folder that is not there answers FALSE and is not created.
	#
	#   _cFolderPath_   a folder name or path below the position, or an absolute path
	#   returns         TRUE or FALSE
	#   note            A relative name is read from the current position, not from the process folder
	#   see             IsEmpty, Count
	#@ aka  --
	def IsFolderEmpty(_cFolderPath_)

		_cAbs_ = This._ResolveInHere(_cFolderPath_)
		if _KindOfPath(_cAbs_) != "folder"
			return 0
		ok
		if len(@dir(_cAbs_)) = 0
			return 1
		ok
		return 0

		def IsEmptyFolder(_cFolderPath_)
			return This.IsFolderEmpty(_cFolderPath_)

	# TRUE if a path begins with this folder's path followed by a given folder name; the test is on text and nothing is read from disk.
	#
	#   cChildPath      The path to test.
	#   cParentFolder   The candidate parent folder, as a name relative to this folder's path.
	#   returns         TRUE or FALSE
	#   note            a path inside sub1 is a subfolder of sub1, and nothing is tested for
	#                   existence
	#   see             IsInside
	def IsSubfolderOf(cChildPath, cParentFolder)
		# Normalize paths for comparison
		_cNormalizedChild_ = This.NormalizePathXT(cChildPath)
		_cNormalizedParent_ = This.NormalizePathXT(This.Path() + This.Separator() + cParentFolder)
		
		# Check if child path starts with parent path
		return StzLeft(_cNormalizedChild_, StzLen(_cNormalizedParent_)) = _cNormalizedParent_
	
	# TRUE if a path names a file or a folder held here, at any depth below the current position, ignoring case.
	#
	#   _cPath_    a name, a sub-path such as sub1/d.txt, or an absolute path
	#   returns    TRUE or FALSE
	#   note       PathExists, IsValidPath and ContainsPath are the same method; the path is looked
	#              up on disk from the current position, so sub1/d.txt answers TRUE when it exists
	#              and /nowhere/a.txt answers FALSE
	#   see        IsFile, IsFolder, DeepExists
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
	
	# TRUE if a path names a file or a folder that exists at least two levels below the current position.
	#
	#   _cPath_    a path below the position, such as /sub1/d.txt
	#   returns    TRUE or FALSE
	#   note       Use DeepContainsFile or DeepContainsFolder to look in the tree; /nothing/zz.txt
	#              answers FALSE because it is not on disk
	#   see        IsDeep, Exists
	#@ aka  --
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
	
	# Returns the path with unified slashes and a trailing slash when it is a folder; a name held here as a file stays a file path.
	#
	#   _cPath_    the path to normalise
	#   returns    text, such as "sub1/" for sub1 and "a.txt" for a.txt
	#   note       Backslashes become slashes, so sub1\x gives sub1/x/
	#   warning    Raises an error for a blank text
	#   see        NormalizeFilePath, NormalizeFolderPath
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
			return This.NormalizePathXT(_cPath_)
	
	# Returns the path trimmed, with backslashes turned into slashes and no trailing slash, keeping its case.
	#
	#   _cName_    the path to normalise
	#   returns    text
	#   note       A doubled slash is reduced to one
	#   warning    Raises an error for a blank text
	#   see        NormalizeFolderPath, NormalizePath
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
	    
	    # A name that is not absolute, or that is only written with a leading
	    # slash (the listing form /a.txt), is joined to the current position,
	    # and the . and .. segments are folded so the fence tests cannot be
	    # walked round.
	    _cCleanName_ = This._ResolveInHere(trim(_cName_))

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
	
	# Returns the path as a folder path: trimmed, with unified slashes and exactly one trailing slash, keeping its case.
	#
	#   _cName_    the path to normalise
	#   returns    text, such as "sub1/"
	#   warning    Raises an error for a blank text
	#   see        NormalizeFilePath, NormalizePath
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

	# Returns the last name of the path in the form that Files uses: a leading slash and lowercase, such as /a.txt.
	#
	#   _cName_    a file name or a path
	#   returns    text
	#   note       Use it to build a value to compare with the listings
	#   warning    Raises an error for a blank text
	#   see        NormalizeFolderName, Files
	#@ aka  Listing-form normalisers: produce the exact shape the Files()/Folders() listings use -- "/name" for a file, "/name/" for a folder -- with the child name lowercased (the listing convention). Handy for building a value to match against those listings.
	def NormalizeFileName(_cName_)
		if NOT ( isString(_cName_) and trim(_cName_) != "" )
			StzRaise("Incorrect param type! cName must be a non-empty string.")
		ok
		return "/" + StzLower(_DirName(_CleanPath(trim(_cName_))))

		def NormaliseFileName(_cName_)
			return This.NormalizeFileName(_cName_)

	# Returns the last name of the path in the form that Folders uses: a leading and a trailing slash and lowercase, such as /sub1/.
	#
	#   _cName_    a folder name or a path
	#   returns    text
	#   note       Use it to build a value to compare with the listings
	#   warning    Raises an error for a blank text
	#   see        NormalizeFileName, Folders
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
	
	# Returns "file", "folder" or "none" for a path, among the files and folders held here at any depth.
	#
	#   _cPath_    a name or a path below the current position
	#   returns    text: file, folder or none
	#   warning    Raises an error for a blank text
	#   see        IsFile, IsFolder, PathInfo
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
	
	
	# Returns pairs describing a path: path, normalized_path, exists, type, is_file, is_folder, is_relative and parent_folder.
	#
	#   _cPath_    a name or a path whose last name is looked up
	#   returns    a list of [ key, value ] pairs
	#   note       The keys are in lowercase; parent_folder is the folder that holds the path
	#   warning    Raises an error (Incorrect path!) when nothing is held here at that path
	#   see        PathType, ParentFolder
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
	
	# Returns the absolute path of the folder that holds a file or a folder held here.
	#
	#   _cPath_    a name or a path below the current position
	#   returns    text; the current position for a direct child, sub1 below it for sub1/d.txt
	#   note       ParentDir is the same method; GetParentDirectory is the one that cuts a full path
	#   warning    Raises an error (Incorrect path!) when nothing is held here at that path
	#   see        PathInfo, GetParentDirectory
	def ParentFolder(_cPath_)
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	
		# The path must be held here; the parent is read from its resolved form,
		# so a folder name answers its parent and not itself.

		if NOT This.Exists(_cPath_)
			raise("Incorrect path!")
		ok

		return _ParentPath(This._ResolveInHere(_cPath_))
	

	    def ParentDir()
		return This.PArentFolder()

	#============================#
	#  BATCH VALIDATION METHODS  #
	#============================#
	
	# TRUE if every path of the list is a file held directly here.
	#
	#   acPaths    the list of paths to test
	#   returns    TRUE or FALSE
	#   warning    Raises an error when the argument is not a list of text
	#   see        IsFile, AreFolders
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
	            return 0
	        ok
	    next
	    
	    return 1
	
	# TRUE if every path of the list is a folder held directly here.
	#
	#   acPaths    the list of paths to test
	#   returns    TRUE or FALSE
	#   warning    Raises an error when the argument is not a list of text
	#   see        IsFolder, AreFiles
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
	            return 0
	        ok
	    next
	    
	    return 1
	
	# TRUE if every path of the list is a file or a folder held directly here.
	#
	#   acPaths    the list of paths to test
	#   returns    TRUE or FALSE
	#   warning    Raises an error when the argument is not a list of text
	#   see        Exists, AreFiles
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
	            return 0
	        ok
	    next
	    
	    return 1
	
	# Returns the paths of a list that are held here, in the order given and as given.
	#
	#   acPaths    the list of paths to filter
	#   returns    a list of text; [ ] when none is held here
	#   warning    Raises an error when the argument is not a list of text
	#   see        MissingPathsAmong, AllExist
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
	            _acResult_ + acPaths[i]
	        ok
	    next
	    
	    return _acResult_
	
	
	# Returns the paths of a list that are not held here, in the order given and as given.
	#
	#   acPaths    the list of paths to filter
	#   returns    a list of text; [ ] when all are held here
	#   warning    Raises an error when the argument is not a list of text
	#   see        ExistingPathsAmong, AllExist
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
	            _acMissing_ + acPaths[i]
	        ok
	    next
	    
	    return _acMissing_

	#======================#
	#  Folder Information  #
	#======================#

	# Returns the last segment of the current position, such as sub1.
	#
	#   returns    text
	#   see        Path, Root
	def Name()
		return _DirName(@cCurrentPath)

	# Returns the current position as text with forward slashes, without a trailing slash at home and with one after GoTo or CreateFolder.
	#
	#   returns    text
	#   note       AbsolutePath and FullPath are the same method
	#   see        CurrentPath, Root, Name
	def Path()
		return @cCurrentPath

	# Returns the current position as an absolute path with forward slashes.
	#
	#   returns    text
	#   note       FullPath is the same method; the stored position is always absolute
	#   see        Path, Root
	def AbsolutePath()
		return @cCurrentPath

		def FullPath()
			return This.AbsolutePath()

	# TRUE if the current position exists as a folder.
	#
	#   returns    TRUE or FALSE
	#   see        IsRoot, Path
	def IsReadable()
		return dirExists(@cCurrentPath)

	# TRUE if the current position is a drive or filesystem root such as C:.
	#
	#   returns    TRUE or FALSE
	#   note       GoUp raises an error there
	#   see        GoUp, IsAbsolute
	def IsRoot()
		return _IsRootPath(@cCurrentPath)

	# TRUE if the current position starts with a drive letter and a colon, or with a slash.
	#
	#   returns    TRUE or FALSE
	#   note       Always TRUE for an object built here, as the position is made absolute at
	#              creation
	#   see        Path
	def IsAbsolute()
		return _IsAbsolutePath(@cCurrentPath)

	# Returns the folder the object was created with, its home, which GoHome comes back to.
	#
	#   returns    text
	#   note       RootPath, Home, HomePath and Folder do the same
	#   see        Home, GoHome, Path
	def Root()
		return @cOriginalPath

		# Returns the folder the object was created with, its home.
		#
		#   returns    text
		#   see        Root, GoHome
		def RootPath()
			return @cOriginalPath

		# Returns the folder the object was created with, its home.
		#
		#   returns    text
		#   see        Root, GoHome
		def Home()
			return @cOriginalPath

		# Returns the folder the object was created with, its home.
		#
		#   returns    text
		#   see        Root, GoHome
		def HomePath()
			return @cOriginalPath

		# Returns the folder the object was created with, its home.
		#
		#   returns    text
		#   see        Root, GoHome
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

	# Returns the folder's facts as pairs: name, path, absolutepath, count, files, folders, isempty, isreadable and isroot.
	#
	#   returns    a list of [ key, value ] pairs, the keys in lowercase
	#   see        Count, IsEmpty
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

	# Returns how many files and folders are held directly here.
	#
	#   returns    a number
	#   note       Size is the same method
	#   see        CountFiles, CountFolders, DeepCount
	def Count()
		return This.CountFiles() + This.CountFolders()

		def Size()
			return This.Count()

	# TRUE if no file and no folder is held directly here.
	#
	#   returns    TRUE or FALSE
	#   note       Empty is the same method
	#   see        Count, IsFolderEmpty
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

	# Returns the files held directly here as "/name" entries, in lowercase.
	#
	#   returns    a list of text, such as [ "/a.txt", "/b.txt" ]
	#   note       A file named B.TXT is listed as /b.txt; the folders are left out
	#   see        Folders, DeepFiles, FindFiles
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

	# Returns the folders held directly here as "/name/" entries, in lowercase.
	#
	#   returns    a list of text, such as [ "/sub1/", "/sub2/" ]
	#   note       Dirs is the same method
	#   see        Files, DeepFolders, FindFolders
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

	# Returns how many files are held directly here.
	#
	#   returns    a number
	#   see        Files, Count, DeepCountFiles
	def CountFiles()
		return len(This.Files())

		# Returns how many files are held directly here.
		#
		#   returns    a number
		#   see        CountFiles
		def NumberOfFiles()
			return len(This.Files())

		# Returns how many files are held directly here.
		#
		#   returns    a number
		#   see        CountFiles
		def HowManyFiles()
			return len(This.Files())

	# Returns how many files held directly here have the given name, 0 or 1, ignoring case.
	#
	#   cFileName   the file name to count
	#   returns     a number
	#   see         CountFiles, ContainsFile
	def CountFile(cFileName)
		return len(This.FindFile(cFileName))

	# Returns how many folders are held directly here.
	#
	#   returns    a number
	#   note       CountDirs is the same method
	#   see        Folders, Count
	def CountFolders()
		return len(This.Folders())

		def CountDirs()
			return This.CountFolders()

	# Returns how many folders held directly here match a name or a pattern with *, ignoring case.
	#
	#   _cFolderName_   the folder name to count, with or without slashes, or a pattern with *
	#   returns         a number; 1 for a plain name that is held here
	#   note            ContainsFolder answers the same question as TRUE or FALSE
	#   see             CountFolders, ContainsFolder
	def CountFolder(_cFolderName_)
		return len(This.FindFolder(_cFolderName_))

	# TRUE if a file or a folder held directly here has the given name, ignoring case and any leading or trailing slash.
	#
	#   _cName_    the file or folder name to look for
	#   returns    TRUE or FALSE
	#   note       Has, ContainsFileOrFolder and ContainsFolderOrFile are the same method; a name
	#              that is deeper answers FALSE
	#   warning    Raises an error for an empty text
	#   see        ContainsFile, ContainsFolder, DeepContains
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


	# TRUE if a file held directly here has the given name, ignoring case.
	#
	#   cFileName   the file name to look for
	#   returns     TRUE or FALSE
	#   warning     Raises an error for an empty text
	#   see         Contains, DeepContainsFile
	def ContainsFile(cFileName)
		if CheckParams()
			if NOT ( isString(cFileName) and trim(cFileName) != "" )
				StzRaise("Incorrect param type! cFileName must be a non-empty string.")
			ok
		ok

		return This._NameInListCI(cFileName, This.Files())

	# TRUE if a folder held directly here has the given name, ignoring case and a trailing slash.
	#
	#   _cFolderName_   the folder name to look for
	#   returns         TRUE or FALSE
	#   note            ContainsDir is the same method
	#   warning         Raises an error for an empty text
	#   see             Contains, DeepContainsFolder
	def ContainsFolder(_cFolderName_)
		if CheckParams()
			if NOT ( isString(_cFolderName_) and trim(_cFolderName_) != "" )
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok
		ok

		return This._NameInListCI(_cFolderName_, This.Folders())

		def ContainsDir(_cFolderName_)
			return This.ContainsFolder(_cFolderName_)

	# TRUE if at least one file is held directly here.
	#
	#   returns    TRUE or FALSE
	#   note       HasFiles is the same method
	#   see        CountFiles, ContainsFolders
	def ContainsFiles()
		return This.CountFiles() > 0

		def HasFiles()
			return This.ContainsFiles()

	# TRUE if at least one folder is held directly here.
	#
	#   returns    TRUE or FALSE
	#   note       HasFolders, HasDirs and ContainsDirs are the same method
	#   see        CountFolders, ContainsFiles
	def ContainsFolders()
		return This.CountFolders() > 0

		def HasFolders()
			return This.ContainsFolders()

		def HasDirs()
			return This.ContainsFolders()

		def ContainsDirs()
			return This.ContainsFolders()

	# Returns the files held directly in a folder of the tree below, as "/name" entries in lowercase.
	#
	#   _cPath_    a folder held here, by name, sub-path or absolute path; the position itself is allowed
	#   returns    a list of text, such as [ "/d.txt" ]; [ ] for an empty folder
	#   note       A relative name is read from the current position, and the entries are in the
	#              same form as Files gives
	#   warning    Raises an error (Incorrect path!) when the folder is not held here
	#   see        Files, FoldersIn
	#@ aka  --
	def FilesIn(_cPath_)

		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		_cAbs_ = This._ResolveInHere(_cPath_)
		if NOT ( StzLower(_cAbs_) = StzLower(_CleanPath(@cCurrentPath)) or This.IsFolder(_cAbs_) )
			StzRaise("Incorrect path!")
		ok

		_acList_ = @dir(_cAbs_)
		_nLen_ = len(_acList_)

		_acResult_ = []

		for i = 1 to _nLen_
			if _acList_[i][2] = 0
				_acResult_ + (This.Separator() + _acList_[i][1])
			ok
		next

		return _acResult_


	# Returns the folders held directly in a folder of the tree below, as "/name/" entries in lowercase.
	#
	#   _cPath_    a folder held here, by name, sub-path or absolute path; the position itself is allowed
	#   returns    a list of text, such as [ "/deep1/" ]; [ ] when it holds no folder
	#   note       A relative name is read from the current position, and the entries are in the
	#              same form as Folders gives
	#   warning    Raises an error (Incorrect path!) when the folder is not held here
	#   see        Folders, FilesIn
	def FoldersIn(_cPath_)

		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		_cAbs_ = This._ResolveInHere(_cPath_)
		if NOT ( StzLower(_cAbs_) = StzLower(_CleanPath(@cCurrentPath)) or This.IsFolder(_cAbs_) )
			StzRaise("Incorrect path!")
		ok

		_acList_ = @dir(_cAbs_)
		_nLen_ = len(_acList_)

		_acResult_ = []

		for i = 1 to _nLen_
			if _acList_[i][2] = 1
				_acResult_ + (This.Separator() + _acList_[i][1] + This.Separator())
			ok
		next

		return _acResult_

	#===========================#
	#  Deep Content Management  #
	#===========================#

	# Returns how many files the whole tree below holds, at every depth.
	#
	#   returns    a number
	#   see        DeepFiles, CountFiles, DeepCount
	def DeepCountFiles()
		return len(This.DeepFiles())

		# Returns how many files the whole tree below holds, at every depth.
		#
		#   returns    a number
		#   see        DeepCountFiles
		def NumberOfDeepFiles()
			return len(This.DeepFiles())

		# Returns how many files the whole tree below holds, at every depth.
		#
		#   returns    a number
		#   see        DeepCountFiles
		def HowManyDeepFiles()
			return len(This.DeepFiles())

	# Returns how many files of the whole tree below have the given name, ignoring case.
	#
	#   cFileName   the file name to count
	#   returns     a number
	#   warning     A name with a path, such as /sub1/d.txt, finds none
	#   see         DeepCountFiles, DeepFindFiles
	def DeepCountFile(cFileName)
		return len(This.DeepFindFile(cFileName))

	# Returns how many folders the whole tree below holds, at every depth.
	#
	#   returns    a number
	#   note       DeepCountDirs is the same method
	#   see        DeepFolders, CountFolders
	def DeepCountFolders()
		return len(This.DeepFolders())

		def DeepCountDirs()
			return This.DeepCountFolders()

	# Returns how many folders of the whole tree below have the given name, ignoring case.
	#
	#   _cFolderName_   the folder name to count
	#   returns         a number
	#   warning         A name with a path, such as /sub1/deep1/, finds none
	#   see             DeepCountFolders, DeepFindFolders
	def DeepCountFolder(_cFolderName_)
		return len(This.DeepFindFolder(_cFolderName_))

	# Returns every file of the tree below as a "/folder/name" entry relative to the current position, in lowercase.
	#
	#   returns    a list of text, such as [ "/a.txt", "/sub1/d.txt" ]
	#   note       Files of a folder come before those of its subfolders, folder by folder, breadth
	#              first
	#   see        DeepFilesXT, Files, DeepFolders
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
	
	# Returns every folder of the tree below as a "/folder/" entry relative to the current position, in lowercase.
	#
	#   returns    a list of text, such as [ "/sub1/", "/sub2/", "/sub1/deep1/" ]
	#   note       Breadth first: the folders of one level come before those of the next
	#   see        DeepFoldersXT, Folders, DeepFiles
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

	# Returns how many files and folders the whole tree below holds.
	#
	#   returns    a number
	#   note       DeepCountFilesAndFolders and DeepCountFoldersAndFiles are the same method
	#   see        DeepCountFiles, DeepCountFolders, Count
	def DeepCount()
		return This.DeepCountFiles() + This.DeepCountFolders()

		def DeepCountFilesAndFolders()
			return This.DeepCount()

		def DeepCountFoldersAndFiles()
			return This.DeepCount()

	# Returns how many files of that name are in the tree below a given folder, ignoring case.
	#
	#   cFileName   the file name to count
	#   _cPath_     the folder to search, as an absolute path
	#   returns     a number
	#   note        DeepCountFile counts over the whole tree below the position
	#   see         DeepCountFile, DeepContainsFileIn
	def DeepCountFileIn(cFileName, _cPath_)
		return This._DeepCountNamedIn(cFileName, _cPath_, 0)

	# Counts the entries of one kind, 0 for files and 1 for folders, that bear a name in the tree below a folder.
	#
	#   _cName_    the name, with or without slashes, in any case
	#   _cPath_    the folder to search, as an absolute path
	#   _nKind_    0 for files, 1 for folders
	#   returns    a number
	def _DeepCountNamedIn(_cName_, _cPath_, _nKind_)
		_cLow_ = StzLower(_DirName(_CleanPath(_cName_)))
		_nCount_ = 0
		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)
		for i = 1 to _nLen_
			if _aList_[i][2] = _nKind_ and _aList_[i][1] = _cLow_
				_nCount_++
			ok
			if _aList_[i][2] = 1
				_nCount_ += This._DeepCountNamedIn(_cName_, _cPath_ + This.Separator() + _aList_[i][1], _nKind_)
			ok
		next
		return _nCount_

	# Returns how many files of the tree below bear one of the listed names, ignoring case.
	#
	#   acFilesNames   the list of file names to count
	#   returns        a number, the counts of the names added up
	#   note           A file is counted once for the name it bears
	#   see            DeepCountTheseFilesIn, DeepCountFile
	def DeepCountTheseFiles(acFilesNames)
		return This.DeepCountTheseFilesIn(acFilesNames, This.Path())

	# Returns how many files of the tree below a given folder bear one of the listed names, ignoring case.
	#
	#   acFilesNames   the list of file names to count
	#   _cPath_        the folder to search, as an absolute path
	#   returns        a number, the counts of the names added up
	#   see            DeepCountTheseFiles
	def DeepCountTheseFilesIn(acFilesNames, _cPath_)
		if CheckParams()
			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok

			if NOT ( isList(acFilesNames) and @IsListOfStrings(acFilesNames) )
				StzRaise("Incorrect param type! acFilesNames must be a list of strings.")
			ok
		ok

		_nCount_ = 0
		_nLen_ = len(acFilesNames)
		for i = 1 to _nLen_
			_nCount_ += This.DeepCountFileIn(acFilesNames[i], _cPath_)
		next
		return _nCount_

	# Returns how many files a given folder holds, at every depth; the folder must be an absolute path.
	#
	#   _cPath_    an absolute folder path
	#   returns    a number
	#   note       It does not need to be a folder of this object
	#   warning    Raises an error for an empty text
	#   see        DeepCountFiles, DeepCountFoldersIn
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


	# Returns how many files a given folder holds down to a depth limit; levels past the limit add nothing.
	#
	#   _cPath_         an absolute folder path
	#   nCurrentLevel   the level of that folder, normally 1
	#   nMaxLevel       the deepest level to count
	#   returns         a number
	#   note            On a tree of three levels, a limit of 1 counts only the top files and a
	#                   limit of 5 counts all
	#   see             DeepCountFilesIn
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


	# Returns how many folders of that name are in the tree below a given folder, ignoring case.
	#
	#   _cFolderName_   the folder name to count
	#   _cPath_         the folder to search, as an absolute path
	#   returns         a number
	#   note            DeepCountFolder counts over the whole tree below the position
	#   see             DeepCountFolder
	def DeepCountFolderIn(_cFolderName_, _cPath_)
		if CheckParams()
			if NOT ( isString(_cFolderName_) and trim(_cFolderName_) != "" )
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok

			if NOT ( isString(_cPath_) and trim(_cPath_) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		return This._DeepCountNamedIn(_cFolderName_, _cPath_, 1)

	# Returns how many folders of the tree below a given folder bear one of the listed names, ignoring case.
	#
	#   acFoldersNames   the list of folder names to count
	#   _cPath_          the folder to search, as an absolute path
	#   returns          a number, the counts of the names added up
	#   see              DeepCountFolder
	def DeepCountTheseFoldersIn(acFoldersNames, _cPath_)
		_nCount_ = 0
		_nLen_ = len(acFoldersNames)
		for i = 1 to _nLen_
			_nCount_ += This.DeepCountFolderIn(acFoldersNames[i], _cPath_)
		next
		return _nCount_

	# Returns how many folders a given folder holds, at every depth; the folder must be an absolute path.
	#
	#   _cPath_    an absolute folder path
	#   returns    a number
	#   warning    Raises an error for an empty text
	#   see        DeepCountFolders, DeepCountFilesIn
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


	# TRUE if a file or a folder of that name is anywhere in the tree below, ignoring case.
	#
	#   _cName_    the name to look for
	#   returns    TRUE or FALSE
	#   note       DeepContainsFileOrFolder and DeepContainsFolderOrFile are the same method
	#   see        DeepContainsFile, DeepContainsFolder, Contains
	def DeepContains(_cName_)

		if This.DeepContainsFileIn(_cName_, This.Path()) or This.DeepContainsFolderIn(_cName_, This.Path())
			return 1
		else
			return 0
		ok

		def DeepContainsFileOrFolder(_cName_)
			return This.DeepContains(_cName_)

		def DeepContainsFolderOrFile(_cName_)
			return This.DeepContains(_cName_)

	# TRUE if a file or a folder of that name is anywhere below a given folder, ignoring case.
	#
	#   _cName_    the name to look for
	#   _cPath_    an absolute folder path to search
	#   returns    TRUE or FALSE
	#   note       DeepContainsFileOrFolderIn and DeepContainsFolderOrFileIn are the same method
	#   see        DeepContains
	def DeepContainsIn(_cName_, _cPath_)

		if This.DeepContainsFileIn(_cName_, _cPath_) or This.DeepContainsFolderIn(_cName_,_cPath_)
			return 1
		else
			return 0
		ok

		def DeepContainsFileOrFolderIn(_cName_, _cPath_)
			return This.DeepContainsIn(_cName_, _cPath_)

		def DeepContainsFolderOrFileIn(_cName_, _cPath_)
			return This.DeepContainsIn(_cName_, _cPath_)

	# TRUE if a file of that name is anywhere in the tree below, ignoring case.
	#
	#   cFileName   the file name to look for
	#   returns     TRUE or FALSE
	#   see         DeepContainsFileIn, ContainsFile
	def DeepContainsFile(cFileName)
		return This.DeepContainsFileIn(cFileName, This.Path())

	# TRUE if a file of that name is anywhere below a given folder, ignoring case.
	#
	#   cFileName   the file name to look for
	#   _cPath_     an absolute folder path to search
	#   returns     TRUE or FALSE
	#   note        Raises an error for an empty name
	#   see         DeepContainsFile
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

			if _aList_[i][2] = 0 and _aList_[i][1] = StzLower(cFileName)
				return 1

			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."

				if This.DeepContainsFileIn(cFileName, _cPath_ + This.Separator() + _aList_[i][1])
					return 1
				end

			end

		next

		return 0

	# TRUE if every file of the list is somewhere in the tree below, ignoring case.
	#
	#   acFilesNames   the list of file names to look for
	#   returns        TRUE or FALSE
	#   warning        Raises an error when the argument is not a list of text
	#   see            DeepContainsOneOfTheseFiles, DeepContainsFile
	def DeepContainsTheseFiles(acFilesNames)
		return This.DeepContainsTheseFilesIn(acFilesNames, This.Path())

	# TRUE if every file of the list is somewhere below a given folder, ignoring case.
	#
	#   acFilesNames   the list of file names to look for
	#   _cPath_        an absolute folder path to search
	#   returns        TRUE or FALSE
	#   warning        Raises an error when the argument is not a list of text
	#   see            DeepContainsTheseFiles
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
		_bResult_ = 1

		for i = 1 to _nLen_

			if NOT This.DeepContainsFileIn(acFilesNames[i], _cPath_)
				_bResult_ = 0
				exit
			ok

		next

		return _bResult_

	# TRUE if at least one file of the list is somewhere in the tree below, ignoring case.
	#
	#   acFilesNames   the list of file names to look for
	#   returns        TRUE or FALSE
	#   note           DeepContainsOneOfTheseFilesIn does the same below a given folder
	#   see            DeepContainsTheseFiles, DeepContainsOneOfTheseFilesIn
	def DeepContainsOneOfTheseFiles(acFilesNames)
		return This.DeepContainsOneOfTheseFilesIn(acFilesNames, This.Path())


	# TRUE if at least one file of the list is somewhere below a given folder, ignoring case.
	#
	#   acFilesNames   the list of file names to look for
	#   _cPath_        an absolute folder path to search
	#   returns        TRUE or FALSE
	#   see            DeepContainsOneOfTheseFiles
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
		_bResult_ = 0

		for i = 1 to _nLen_

			if This.DeepContainsFileIn(acFilesNames[i], _cPath_)
				_bResult_ = 1
				exit
			ok

		next

		return _bResult_

	# TRUE if a folder of that name is anywhere in the tree below, ignoring case.
	#
	#   _cFolderName_   the folder name to look for
	#   returns         TRUE or FALSE
	#   see             DeepContainsFolderIn, ContainsFolder
	def DeepContainsFolder(_cFolderName_)
		return This.DeepContainsFolderIn(_cFolderName_, This.Path())


	# TRUE if a folder of that name is anywhere below a given folder, ignoring case.
	#
	#   _cFolderName_   the folder name to look for
	#   _cPath_         an absolute folder path to search
	#   returns         TRUE or FALSE
	#   see             DeepContainsFolder
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

			if _aList_[i][2] = 1 and _aList_[i][1] = StzLower(_cFolderName_)
				return 1

			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."

				if This.DeepContainsFolderIn(_cFolderName_, _cPath_ + This.Separator() + _aList_[i][1])
					return 1
				end

			end

		next

		return 0

	# TRUE if every folder of the list is somewhere in the tree below, ignoring case.
	#
	#   acFoldersNames   the list of folder names to look for
	#   returns          TRUE or FALSE
	#   warning          Raises an error when the argument is not a list of text
	#   see              DeepContainsOneOfTheseFolders, DeepContainsFolder
	def DeepContainsTheseFolders(acFoldersNames)
		return This.DeepContainsTheseFoldersIn(acFoldersNames, This.Path())

	# TRUE if every folder of the list is somewhere below a given folder, ignoring case.
	#
	#   acFoldersNames   the list of folder names to look for
	#   _cPath_          an absolute folder path to search
	#   returns          TRUE or FALSE
	#   warning          Raises an error when the argument is not a list of text
	#   see              DeepContainsTheseFolders
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
		_bResult_ = 1

		for i = 1 to _nLen_

			if NOT This.DeepContainsFolderIn(acFoldersNames[i], _cPath_)
				_bResult_ = 0
				exit
			ok

		next

		return _bResult_

	# TRUE if at least one folder of the list is somewhere in the tree below, ignoring case.
	#
	#   acFoldersNames   the list of folder names to look for
	#   returns          TRUE or FALSE
	#   note             DeepContainsOneOfTheseFoldersIn does the same below a given folder
	#   see              DeepContainsTheseFolders, DeepContainsOneOfTheseFoldersIn
	def DeepContainsOneOfTheseFolders(acFoldersNames)
		return This.DeepContainsOneOfTheseFoldersIn(acFoldersNames, This.Path())

	# TRUE if at least one folder of the list is somewhere below a given folder, ignoring case.
	#
	#   acFoldersNames   the list of folder names to look for
	#   _cPath_          an absolute folder path to search
	#   returns          TRUE or FALSE
	#   warning          Raises an error when the argument is not a list of text
	#   see              DeepContainsOneOfTheseFolders
	def DeepContainsOneOfTheseFoldersIn(acFoldersNames, _cPath_)

		if CheckParams()
			if NOT ( isList(acFoldersNames) and @IsListOfStrings(acFoldersNames) )
				StzRaise("Incorrect param type! acFoldersNames must be a list of strings.")
			ok
		ok

		_nLen_ = len(acFoldersNames)
		_bResult_ = 0

		for i = 1 to _nLen_

			if This.DeepContainsFolderIn(acFoldersNames[i], _cPath_)
				_bResult_ = 1
				exit
			ok

		next

		return _bResult_

	#==============#
	#  Navigation  #
	#==============#

	# TRUE if batch mode is on, so file and folder operations leave the current position alone.
	#
	#   returns    TRUE or FALSE; FALSE by default
	#   see        SetBatchMode, CurrentPath
	def IsBatchMode()
		return @bBacthMode

	# Turns batch mode on or off; on, the create, delete, read and write methods no longer try to move into the folder they touched.
	#
	#   b          1 to turn batch mode on, 0 to turn it off
	#   returns    nothing; the object is changed in place
	#   note       With it off (the default) the file methods end by moving the position into the
	#              folder of the file they touched, when that folder is below the position
	#   warning    Raises an error for any value but 1 or 0
	#   see        IsBatchMode, FileRead
	def SetBatchMode(b)

		if CheckParams()
			if NOt (isNumber(b) and (b=1 or b=0))
				StzRaise("Incorrect param type! b must be a boolean.")
			ok
		ok

		@bBacthMode = b

	# Returns the absolute path of the folder that holds a path, read from the current position.
	#
	#   _cPath_    a file or folder name or path, relative to the position or absolute
	#   returns    text, without a trailing slash
	#   note       Pure text work; the path need not exist
	#   see        ParentFolder, GetParentDirectory
	def GetDirectoryPath(_cPath_)
		return _ParentPath(This._ResolveInHere(_cPath_))

	# Moves the position into a folder, but only when it is a folder below the position; otherwise stays where it is.
	#
	#   _cDir_     the folder to move into, as an absolute path
	#   returns    1 when the position moved, 0 when it stayed
	#   note       The file methods call it after their work is done, so it never raises
	def _FollowTo(_cDir_)
		_cDir_ = _CleanPath(_cDir_)
		if StzLower(_cDir_) = StzLower(_CleanPath(@cCurrentPath))
			return 0
		ok
		if This.IsInside(_cDir_) and StzEngineDirExists(_cDir_)
			This.GoTo(_cDir_)
			return 1
		ok
		return 0

	# Returns the current position as text with a trailing slash, so a relative name can be joined to it directly.
	#
	#   returns    text, such as "FX/sub1/"
	#   note       WorkingDirectory and pwd are the same method
	#   see        Path, GoTo
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

	# Moves the current position to a folder below it, writing the old position to the history; the folder is not checked to exist.
	#
	#   _cPath_    a name or a path strictly below the current position
	#   returns    1 (TRUE)
	#   note       MoveTo and cd are the same method; GoTo('..') is accepted as text and leaves a
	#              path with .. in it
	#   warning    Raises an error for an empty text or for a path that is not strictly below the
	#              position, an absolute path included when it is the position itself or above
	#   see        GoUp, GoHome, GoBack, CurrentPath
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
		
		return 1

		def MoveTo(cDir)
			return This.GoTo(cDir)

		def cd(cDir)
			return This.GoTo(cDir)

	# Moves the current position to its parent folder, writing the old one to the history; it may leave the home folder.
	#
	#   returns    1 (TRUE)
	#   note       Nothing stops it going above the folder the object was created with, and the
	#              delete methods then act on that parent; Up and cdUp are the same method
	#   warning    Raises an error at a drive or filesystem root
	#   see        GoTo, GoBack, IsRoot
	def GoUp()
		if This.IsRoot()
			raise("Already at root - cannot go up further.")
		end

		# Save current path before going up
		@acPathHistory + @cCurrentPath
		
		@cCurrentPath = _ParentPath(@cCurrentPath)
	
		return 1

		def Up()
			return This.GoUp()

		def cdUp()
			return This.GoUp()

	# Moves the current position back to the folder the object was created with, writing the old one to the history.
	#
	#   returns    1 (TRUE)
	#   note       GoToHome, GoToRoot and GoRoot are the same method
	#   see        GoTo, Root, IsAtHome
	def GoHome()
		# Save current path before going home
		@acPathHistory + @cCurrentPath
		
		@cCurrentPath = @cOriginalPath
		
		return 1

		def GoToHome()
			return This.GoHome()

		def GoToRoot()
			return This.GoHome()

		def GoRoot()
			return This.GoHome()

	# Moves the current position back to the last one in the history and removes that entry.
	#
	#   returns    1 (TRUE)
	#   note       Back and Previous are the same method
	#   warning    Raises an error when the history is empty
	#   see        PathHistory, GoTo
	def GoBack()
		if len(@acPathHistory) = 0
			raise("No previous location in history!")
		end
		
		_cPreviousPath_ = @acPathHistory[len(@acPathHistory)]
		del(@acPathHistory, len(@acPathHistory))  # Remove last item
		
		@cCurrentPath = _cPreviousPath_
		
		return 1

		def Back()
			return This.GoBack()

		def Previous()
			return This.GoBack()

	# Returns the positions the object has left, oldest first.
	#
	#   returns    a list of text
	#   note       NavigationHistory is the same method; every GoTo, GoUp, GoHome adds one
	#   see        GoBack, ClearHistory
	def PathHistory()
		return @acPathHistory

		def NavigationHistory()
			return This.PathHistory()

	# Empties the history of positions.
	#
	#   returns    nothing; the object is changed in place
	#   see        PathHistory, GoBack
	def ClearHistory()
		@acPathHistory = []

	# TRUE if the current position is the folder the object was created with.
	#
	#   returns    TRUE or FALSE
	#   note       IsAtRoot is the same method
	#   see        GoHome, Root
	def IsAtHome()
		if StzLower(_CleanPath(@cCurrentPath)) = StzLower(_CleanPath(@cOriginalPath))
			return 1
		ok
		return 0

		def IsAtRoot()
			return This.IsAtHome()

	# Returns the path that leads from the home folder to the current position, "." at home.
	#
	#   returns    text, such as sub1/deep1; one .. per level when GoUp has left the home folder
	#   see        DistanceFromHome, Path
	def RelativePathFromHome()
		if This.IsAtHome()
			return "."
		end

		_acHome_ = _PathSegments(@cOriginalPath)
		_acCur_ = _PathSegments(@cCurrentPath)
		_nHome_ = len(_acHome_)
		_nCur_ = len(_acCur_)

		_nCommon_ = 0
		for i = 1 to min([_nHome_, _nCur_])
			if StzLower(_acHome_[i]) = StzLower(_acCur_[i])
				_nCommon_ = i
			else
				exit
			ok
		next

		_cResult_ = ""
		for i = 1 to _nHome_ - _nCommon_
			if _cResult_ != ""
				_cResult_ += This.Separator()
			ok
			_cResult_ += ".."
		next
		for i = _nCommon_ + 1 to _nCur_
			if _cResult_ != ""
				_cResult_ += This.Separator()
			ok
			_cResult_ += _acCur_[i]
		next

		if _cResult_ = ""
			return "."
		ok
		return _cResult_

	# Returns how many folder levels lie between the home folder and the current position, 0 at home.
	#
	#   returns    a number; a level above home counts as one, like a level below
	#   see        RelativePathFromHome
	def DistanceFromHome()
		# Return number of directory levels from home
		_cRelPath_ = This.RelativePathFromHome()
		if _cRelPath_ = "."
			return 0
		end
		
		return len(_PathSegments(_cRelPath_))

	# Returns pairs describing the position: home, current, relativefromhome, distancefromhome and history.
	#
	#   returns    a list of [ key, value ] pairs
	#   see        RelativePathFromHome, PathHistory
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

	# Creates a folder below the current position, with every missing level, and moves into it unless batch mode is on.
	#
	#   pcPath     a folder name or path below the current position
	#   returns    1 (TRUE); also 1 when the folder already exists
	#   note       FolderCreate and MakeFolder are the same method; a relative path is joined to the
	#              position the object is at, which is inside the previous folder after a first
	#              CreateFolder
	#   warning    Raises an error for an empty text or for a path outside the current position
	#   see        CreatePath, CreateFolders, GoHome
	def CreateFolder(pcPath)
	    This.CreateFolderQ(pcPath)
	    return 1

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

	# Creates several folders below the current position, each with its missing levels, without moving.
	#
	#   paNames    a list of folder names or paths below the current position
	#   returns    1 (TRUE)
	#   note       MakeFolders and CreateSubFolders are the same method
	#   warning    Raises an error when the argument is not a list
	#   see        CreateFolder, CreatePath
	def CreateFolders(paNames)
		This.CreateFoldersQ(paNames)
		return 1

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

	# Creates a deep folder path below the current position, every missing level included, without moving.
	#
	#   pcPath     a path below the current position
	#   returns    1 (TRUE); also 1 when the path already exists
	#   note       MkPath and CreateDeepPath are the same method
	#   warning    Raises an error for an empty text or for a path outside the current position
	#   see        CreateFolder, CreateFolders
	def CreatePath(pcPath)
		This.CreatePathQ(pcPath)
		return 1

		def MkPath(pcPath)
			return This.CreatePath(pcPath)

		def CreateDeepPath(pcPath)
			return This.CreatePath(pcPath)


	# Deletes a folder held here with everything inside it, then moves to its parent when that is below the position.
	#
	#   _cFolder_   the folder to delete, by name, sub-path or absolute path below the position
	#   returns     the engine's answer, 1 on success
	#   note        FolderDelete, RemoveFolder and FolderRemove are the same method
	#   warning     Raises an error (Folder does not exist.) for a name not held here, and an error
	#               (Can't navigate outside the folder!) for the position itself or a path above it
	#   see         DeleteAll, DeepRemoveAll, SetBatchMode
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
	
	    if not This.IsFolder(_cFolder_)
	        raise("Folder does not exist.")
	    ok
	
	    # Delete the folder first
	    _bResult_ = RemoveFolderRecursive(_cFolder_)
	    
	    # Then navigate to parent folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cParentDir_ = This.GetDirectoryPath(_cFolder_)
	        This._FollowTo(_cParentDir_)
	    ok
	
	    return _bResult_

		def FolderDelete(_cFolder_)
			return This.DeleteFolder(_cFolder_)

		def RemoveFolder(_cFolder_)
			return This.DeleteFolder(_cFolder_)

		def FolderRemove(_cFolder_)
			return This.DeleteFolder(_cFolder_)

	# Deletes every file and every subfolder held directly here, subfolders with their contents, keeps this folder, and goes home.
	#
	#   returns    nothing
	#   note       DeleteAllFiles, DeepDeleteFiles, FilesDeepDelete and AllFilesDeepDelete are the
	#              same method; despite those names it removes subfolders too
	#   warning    Raises an error when something cannot be removed
	#   see        RemoveAll, Erase, DeepRemoveAll
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

		# Deletes every file and every subfolder held directly here, keeps this folder, and goes home.
		#
		#   returns    nothing
		#   note       RemoveAllFiles, DeepRemoveFiles, FilesDeepRemove and AllFilesDeepRemove call
		#              DeleteAll
		#   warning    Raises an error when something cannot be removed
		#   see        DeleteAll, DeepRemoveAll
		#@ aka  --
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

	# Removes this folder itself with everything in it; the object then points to a folder that no longer exists.
	#
	#   returns    1 (TRUE)
	#   note       DeepRemove and RemoveTree are the same method
	#   see        DeleteAll, RemoveAll
		#>
	#@ aka  Remove this folder ENTIRELY -- its contents AND the folder itself, recursively (RemoveAll/DeleteAll only empties the contents). Returns TRUE on success.
	def DeepRemoveAll()
		return RemoveFolderRecursive(This.Path())

		def DeepRemove()
			return This.DeepRemoveAll()

		def RemoveTree()
			return This.DeepRemoveAll()

	# Deletes the files held directly here and keeps the folders.
	#
	#   returns    the number of files deleted
	#   note       RemoveFiles is the same method; the position does not change
	#   see        DeepErase, DeleteAll
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


	# Deletes every file of the whole tree below and keeps all the folders.
	#
	#   returns    the number of files deleted
	#   see        Erase, DeleteAll
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
	
	# Returns the absolute paths of the files (kind 0) or folders (kind 1) of the tree below that bear a name, ignoring case.
	#
	#   _cName_    a name, with or without slashes
	#   _nKind_    0 for files, 1 for folders
	#   returns    a list of absolute paths; folders without a trailing slash
	def _DeepPathsNamed(_cName_, _nKind_)
		_cLow_ = StzLower(_DirName(_CleanPath(_cName_)))
		_acAll_ = []
		if _nKind_ = 0
			_acAll_ = This.DeepFilesXT()
		else
			_acAll_ = This.DeepFoldersXT()
		ok
		_acFound_ = []
		_nLen_ = len(_acAll_)
		for i = 1 to _nLen_
			if StzLower(_DirName(_CleanPath(_acAll_[i]))) = _cLow_
				_acFound_ + _CleanPath(_acAll_[i])
			ok
		next
		return _acFound_

	# Deletes every file of that name anywhere in the tree below, ignoring case, and tells whether one was deleted.
	#
	#   cFileName   the file name to delete, with or without a leading slash
	#   returns     TRUE when at least one file was deleted, FALSE when none bears that name
	#   note        FileDeepDelete, DeepRemoveFile and FileDeepRemove call it; only files below the
	#               current position are touched
	#   warning     Raises an error when the argument is not a non-empty text
	#   see         DeepErase, FileRemove
	def DeepDeleteFile(cFileName)
	    if CheckParams()
	        if NOT (isString(cFileName) and cFileName != "")
	            raise("Incorrect param type! cFileName must be a non-empty string.")
	        ok
	    end
	
	    # The candidates come from the listing of the tree below the position,
	    # so each one is inside by construction; the bare name is only compared.
	    _acFilePaths_ = This._DeepPathsNamed(cFileName, 0)
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


	# Deletes every folder of that name anywhere in the tree below, with its contents, and answers 1 unless a deletion failed.
	#
	#   _cFolderName_   the folder name to delete, with or without slashes, ignoring case
	#   returns         1, also when no folder bears that name; 0 when a deletion failed
	#   note            DeepRemoveFolder, FolderDeepDelete and FolderDeepRemove are the same method;
	#                   only folders below the current position are touched
	#   warning         Raises an error when the argument is not a non-empty text
	#   see             DeleteFolder, DeepRemoveAll
	def DeepDeleteFolder(_cFolderName_)

		if CheckParams()
			if NOT ( isString(_cFolderName_) and trim(_cFolderName_) != "" )
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok
		ok

		# Absolute paths from the listing of the tree below the position, the
		# deepest first so that a folder is emptied before its parent goes.
		_acFolderPaths_ = This._DeepPathsNamed(_cFolderName_, 1)
		_nLen_ = len(_acFolderPaths_)
		_anDepth_ = []
		_nMaxDepth_ = 0
		for i = 1 to _nLen_
			_anDepth_ + len(_PathSegments(_acFolderPaths_[i]))
			if _anDepth_[i] > _nMaxDepth_
				_nMaxDepth_ = _anDepth_[i]
			ok
		next

		_bResult_ = 1

		for d = _nMaxDepth_ to 1 step -1
			for i = 1 to _nLen_
				if _anDepth_[i] = d
					_cFolderPath_ = _acFolderPaths_[i]

					# a folder inside one already deleted is gone with it
					if StzEngineDirExists(_cFolderPath_)
						if NOT RemoveFolderRecursive(_cFolderPath_)
							_bResult_ = 0
						ok
					ok
				ok
			next
		next

		# Stay in current folder - deep operation initiated from here
		return _bResult_

		def DeepRemoveFolder(_cFolderName_)
			return This.DeepDeleteFolder(_cFolderName_)
	
		def FolderDeepDelete(_cFolderName_)
			return This.DeepDeleteFolder(_cFolderName_)

		def FolderDeepRemove(_cFolderName_)
			return This.DeepRemoveFolder(_cFolderName_)

	#===================#
	#  File Operations  #
	#===================#

	# Returns the text of a file held here, at any depth below the current position.
	#
	#   _cFile_    a file name, a sub-path such as sub1/d.txt, or an absolute path
	#   returns    text
	#   note       ReadFile is the same method; FileReadQ gives the reader object; with batch mode
	#              off the position then moves into the folder of the file
	#   warning    Raises an error for a path that is not a file held here, a folder name included
	#   see        FileSize, FileInfo, SetBatchMode
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
	
	    if not This.IsFile(_cFile_)
	        raise("cFile does not exist in the folder.")
	    ok
	
	    # Read the file first
	    _cResult_ = @FileRead(_cFile_)
	    
	    # Then navigate to its folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cFileDir_ = This.GetDirectoryPath(_cFile_)
	        This._FollowTo(_cFileDir_)
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
				This._FollowTo(_cFileDir_)
			ok

			return @FileAppendQ(_cFile_)   # global -> appender object (append-or-create)

			def AppendFileQ(_cFile_)
				return This.FileAppendQ(_cFile_)

	# Creates an empty file below the current position and answers 1; it raises an error when the name is taken.
	#
	#   _cFile_    the file name or path to create, in a folder that exists
	#   returns    1 (TRUE)
	#   note       CreateFile is the same method; with batch mode off the position then moves into
	#              the folder of the file
	#   warning    Raises an error when the name is taken or when its folder does not exist
	#              (nodir/n.txt); CreatePath makes the folder first
	#   see        FilesCreate, FileRemove, SetBatchMode
	#@ aka  --
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
	
	    if NOT StzEngineDirExists(_ParentPath(_cFile_))
	        raise("Can't create this file! Its folder does not exist.")
	    ok

	    # Create the file first
	    _bResult_ = @FileCreate(_cFile_)
	    
	    # Then navigate to its folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cFileDir_ = This.GetDirectoryPath(_cFile_)
	        This._FollowTo(_cFileDir_)
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
		
		    if NOT StzEngineDirExists(_ParentPath(_cFile_))
		        raise("Can't create this file! Its folder does not exist.")
		    ok

		    # Create the file first
		    _oResult_ = @FileCreateQ(_cFile_)
		    
		    # Then navigate to its folder (intelligent navigation)
		    if not this.IsBatchMode()
		        _cFileDir_ = This.GetDirectoryPath(_cFile_)
		        This._FollowTo(_cFileDir_)
		    ok
		
		    return _oResult_

			def CreateFileQ(_cFile_)
				return This.FileCreateQ(_cFile_)

	
	# Creates the listed files and reports which were created and which failed, with the error of each.
	#
	#   acFileNames   the list of file names to create
	#   returns       a list of two pairs, [ "created", [ names ] ] and [ "failed", [ [ name, error ] ... ] ]
	#   note          CreateFiles is the same method; a name that already exists, or whose folder is
	#                 missing, is reported as failed with its own error
	#   see           FileCreate
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
				_cDirOfThis_ = This.GetDirectoryPath(acFileNames[i])
				This.CreateFile(acFileNames[i])
				_acCreated_ + acFileNames[i]
				# Track last successful creation for intelligent navigation
				_cLastSuccessfulDir_ = _cDirOfThis_
			catch
				_acFailed_ + [acFileNames[i], CatchError()]
			end
		next

		# Navigate to last successful creation folder (intelligent navigation)
		if not this.IsBatchMode() and _cLastSuccessfulDir_ != ""
			This._FollowTo(_cLastSuccessfulDir_)
		ok

		return [
			:Created = _acCreated_,
			:Failed = _acFailed_
		]


		def CreateFiles(acFileNames)
			return This.FilesCreate(acFileNames)


	# Replaces the whole content of a file held here by a text and answers 1.
	#
	#   _cFile_       an existing file held here
	#   cNewContent   the text that replaces the content
	#   returns       1 (TRUE)
	#   note          OverwriteFile is the same method; FileOverwriteQ gives the overwriter object
	#   warning       Raises an error when the file is not held here
	#   see           FileModify, FileSafeOverwrite
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

		if NOT This.IsFile(_cFile_)
			raise("Can't overwrite this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This._FollowTo(_cFileDir_)
		ok

		StzEngineFileWrite(_cFile_, cNewContent)
		return 1

	
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

			if NOT This.IsFile(_cFile_)
				raise("Can't overwrite this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder (intelligent navigation)
			if not this.IsBatchMode()
				_cFileDir_ = This.GetDirectoryPath(_cFile_)
				This._FollowTo(_cFileDir_)
			ok

			return @FileOverwriteQ(_cFile_)

			def OverwriteFileQ(_cFile_)
				return This.FileOverwriteQ(_cFile_)
	
	
	# Empties a file held here, keeping the file, and answers 1.
	#
	#   _cFile_    an existing file held here
	#   returns    1 (TRUE)
	#   note       EraseFile is the same method; FileRemove deletes the file itself
	#   warning    Raises an error when the file is not held here
	#   see        FileRemove, FileSafeErase
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

		if NOT This.IsFile(_cFile_)
			raise("Can't erase this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder before erasing (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This._FollowTo(_cFileDir_)
		ok

		StzEngineFileWrite(_cFile_, "")
		return 1

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
	
			if NOT This.IsFile(_cFile_)
				raise("Can't erase this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder before erasing (intelligent navigation)
			if not this.IsBatchMode()
				_cFileDir_ = This.GetDirectoryPath(_cFile_)
				This._FollowTo(_cFileDir_)
			ok

			# stzFileEaraser (the class carries that spelling) empties the file as it is built
			return new stzFileEaraser(_cFile_)


			def EraseFileQ(_cFile_)
				return This.FileEraseQ(_cFile_)


	# Copies a file held here to a .bak file beside it, then empties the file, and answers 1.
	#
	#   _cFile_    an existing file held here
	#   returns    1 (TRUE)
	#   note       SafeEraseFile is the same method; an older .bak of the same file is replaced
	#   warning    Raises an error when the file is not held here
	#   see        FileRemove, FileErase
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

		if NOT This.IsFile(_cFile_)
			raise("Can't safe-erase this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder before safe-erasing (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This._FollowTo(_cFileDir_)
		ok

		StzEngineFileCopy(_cFile_, _cFile_ + ".bak")
		StzEngineFileWrite(_cFile_, "")
		return 1


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
	
			if NOT This.IsFile(_cFile_)
				raise("Can't safe-erase this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder before safe-erasing (intelligent navigation)
			if not this.IsBatchMode()
				_cFileDir_ = This.GetDirectoryPath(_cFile_)
				This._FollowTo(_cFileDir_)
			ok

			StzEngineFileCopy(_cFile_, _cFile_ + ".bak")
			return new stzFileEaraser(_cFile_)
	
		def SafeEraseFile(_cFile_)
			return This.FileSafeErase(_cFile_)

		def SafeEraseFileQ(_cFile_)
			return This.FileSafeEraseQ(_cFile_)


	# Deletes a file held here, at any depth below the current position, and answers 1.
	#
	#   _cFile_    a file name, a sub-path such as sub1/d.txt, or an absolute path
	#   returns    1 (TRUE)
	#   note       FileDelete, RemoveFile and DeleteFile are the same method; with batch mode off
	#              the position then moves into the folder the file was in
	#   warning    Raises an error for a path that is not a file held here
	#   see        FileErase, DeepErase, SetBatchMode
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
	
	    if not This.IsFile(_cFile_)
	        raise("cFile does not exist in the folder.")
	    ok
	
	    # Delete the file first
	    _bResult_ = @FileRemove(_cFile_)
	    
	    # Then navigate to file's containing folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cFileDir_ = This.GetDirectoryPath(_cFile_)
	        This._FollowTo(_cFileDir_)
	    ok
	
	    return _bResult_

		def FileDelete(_cFile_)
			return This.FileRemove(_cFile_)

		def RemoveFile(_cFile_)
			return This.FileRemove(_cFile_)

		def DeleteFile(_cFile_)
			return This.FileRemove(_cFile_)


	# Copies a file held here to a .bak file beside it, replacing an older copy, and answers 1.
	#
	#   _cFile_    an existing file held here
	#   returns    1 (TRUE)
	#   note       BackupFile is the same method; FileCopy writes a copy under another name
	#   warning    Raises an error when the file is not held here
	#   see        FileCopy
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
	
	    if not This.IsFile(_cFile_)
	        raise("cFile does not exist in the folder.")
	    ok
	
	    # Create backup first
	    _cBackupFile_ = _cFile_ + ".bak"
	    _bResult_ = StzEngineFileCopy(_cFile_, _cBackupFile_)
	    
	    # Then navigate to file's folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cFileDir_ = This.GetDirectoryPath(_cFile_)
	        This._FollowTo(_cFileDir_)
	    ok
	
	    return _bResult_


		def BackupFile(_cFile_)
			return This.FileBackup(_cFile_)


	# Copies a file held here to a .bak file beside it, then replaces its content by a text, and answers 1.
	#
	#   _cFile_       an existing file held here
	#   cNewContent   the text that replaces the content
	#   returns       1 (TRUE)
	#   note          SafeOverwriteFile is the same method; an older .bak of the same file is replaced
	#   warning       Raises an error when the file is not held here
	#   see           FileOverwrite, FileModify
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

		if NOT This.IsFile(_cFile_)
			raise("Can't safe-overwirte this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This._FollowTo(_cFileDir_)
		ok

		StzEngineFileCopy(_cFile_, _cFile_ + ".bak")
		StzEngineFileWrite(_cFile_, cNewContent)
		return 1

		def SafeOverwriteFile(_cFile_, cNewContent)
			return This.FileSafeOverwrite(_cFile_, cNewContent)


	# Replaces every occurrence of a text in a file held here, case-sensitively, and answers 1 even when none was found.
	#
	#   _cFile_       an existing file held here
	#   cOldContent   the text to replace
	#   cNewContent   the text to put in its place
	#   returns       1 (TRUE)
	#   note          ModifyFile is the same method
	#   warning       Raises an error when the file is not held here
	#   see           ModifyInFile, FileOverwrite
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

		if NOT This.IsFile(_cFile_)
			raise("Can't modify this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This._FollowTo(_cFileDir_)
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
			if NOT This.IsFile(_cFile_)
				raise("Can't update this file! cFile does not exist in the folder.")
			ok
			return @FileUpdate(_cFile_)

	# Copies a file held here to a new name, replacing a file that is already there, and answers 1.
	#
	#   _cSourceFile_   the file to copy
	#   _cDestFile_     the name or path of the copy, below the current position
	#   returns         1 (TRUE); 0 when the destination folder is missing
	#   note            CopyFile is the same method; an existing destination is overwritten without
	#                   warning
	#   warning         Raises an error when the source is not held here or the destination is outside
	#   see             FileMove, FileBackup
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
	
	    if not This.IsFile(_cSourceFile_)
	        raise("Source file does not exist in the folder.")
	    ok
	
	    # Copy the file first
	    _bResult_ = @FileCopy(_cSourceFile_, _cDestFile_)
	    
	    # Then navigate to destination folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cDestDir_ = This.GetDirectoryPath(_cDestFile_)
	        This._FollowTo(_cDestDir_)
	    ok
	
	    return _bResult_


		def CopyFile(cSource, cDest)
			return this.FileCopy(cSource, cDest)


	# Moves a file held here to a new name or into another folder below the position and answers 1.
	#
	#   _cSourceFile_   the file to move
	#   _cDestFile_     the new name or path, below the current position
	#   returns         1 (TRUE); 0 when the destination folder is missing
	#   note            MoveFile is the same method; a move into a missing folder answers 0 and
	#                   moves nothing
	#   warning         Raises an error when the source is not held here or the destination is outside
	#   see             FileCopy, FileRemove
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
	
	    if not This.IsFile(_cSourceFile_)
	        raise("Source file does not exist in the folder.")
	    ok
	
	    # Move the file first
	    _bResult_ = @FileMove(_cSourceFile_, _cDestFile_)
	    
	    # Then navigate to destination folder (intelligent navigation)
	    if not this.IsBatchMode()
	        _cDestDir_ = This.GetDirectoryPath(_cDestFile_)
	        This._FollowTo(_cDestDir_)
	    ok
	
	    return _bResult_


		def MoveFile(cSource, cDestination)
			return this.FileMove(cSource, cDestination)

	# Returns the size of a file held here, in bytes.
	#
	#   _cFile_    a file name, a sub-path, or an absolute path below the position
	#   returns    a number
	#   note       FileSizeInBytes is the same method; an empty file answers 0
	#   warning    Raises an error for a path that is not a file held here
	#   see        FileInfo, FileRead
	#@ aka  --
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

		if NOT This.IsFile(_cFile_)
			raise("Can't get size of this file! cFile does not exist in the folder.")  # Fixed: was "modify"
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This._FollowTo(_cFileDir_)
		ok

		# No @FileSize global exists; the byte size is the length of the file
		# content (the codebase's established pattern). ring_len() -- not bare
		# len() -- because a bare len() inside a class method resolves to a
		# method and raises R20.
		return ring_len(read(_cFile_))

		def FileSizeInBytes(_cFile_)
			return this.FileSize(_cFile_)

	# Returns pairs describing a file held here, such as its size, suffix and last modification time.
	#
	#   _cFile_    a file name, a sub-path, or an absolute path below the position
	#   returns    a list of [ key, value ] pairs, the keys in lowercase: name (without suffix),
	#              size, suffix, path, exists, iswritable, isreadable and lastmodified
	#   warning    Raises an error for a path that is not a file held here
	#   see        FileSize, PathInfo
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

		if NOT This.IsFile(_cFile_)
			raise("Can't read this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This._FollowTo(_cFileDir_)
		ok

		return @FileInfo(_cFile_)

		def FileInfoQ(_cFile_)
			_cFile_ = This.NormaliseFilePathXT(_cFile_)
	
			if NOT This.IsInside(_cFile_)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.IsFile(_cFile_)
				raise("Can't read this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder (intelligent navigation)
			if not this.IsBatchMode()
				_cFileDir_ = This.GetDirectoryPath(_cFile_)
				This._FollowTo(_cFileDir_)
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

		if NOT This.IsFile(_cFile_)
			raise("Can't read this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			_cFileDir_ = This.GetDirectoryPath(_cFile_)
			This._FollowTo(_cFileDir_)
		ok

		return @FileInfoXT(_cFile_)

	#======================#
	#  Finding Operations  #
	#======================#

	# Returns the files held directly here that match a name, a pattern with * or a list of names, ignoring case.
	#
	#   pPattern   a file name, a pattern with * as a wildcard, or a list of file names
	#   returns    a list of "/name" entries; [ ] when none match
	#   note       FindFile and FindThisFile are the same method; a.txt finds /a.txt and *.txt finds
	#              every .txt file
	#   warning    Raises an error for an empty text or a number; a lone * finds nothing
	#   see        FindFilesByExtension, DeepFindFiles, Files
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

	# Returns the folders held directly here that match a name or a pattern with *, ignoring case.
	#
	#   _cPattern_   a folder name with or without slashes, or a pattern with * as a wildcard, such as sub*
	#   returns      a list of "/name/" entries; [ ] when none match
	#   note         FindFolder and FindThisFolder are the same method; raises an error for an empty
	#                text
	#   see          DeepFindFolders, Folders, FindFiles
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
				if StzLower(_DirName(_CleanPath(_acFolders_[i]))) = StzLower(_DirName(_CleanPath(_cPattern_)))
					_acResult_ + _acFolders_[i]
				ok
			next
		ok

		return _acResult_

		def FindFolder(_cFolderName_)
			return This.FindFolders(_cFolderName_)

		def FindThisFolder(_cFolderName_)
			return This.FindFolders(_cFolderName_)


	# Returns the files held directly here that end with an extension, ignoring case.
	#
	#   _cExt_     a file extension, with or without the leading dot
	#   returns    a list of "/name" entries
	#   note       FilesByExtension is the same method
	#   warning    Raises an error for an empty text
	#   see        FindFiles, DeepFindFiles
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

	# Returns the files held directly here that match any of a list of names or patterns, each file once.
	#
	#   acFilesNames   a list of file names or * patterns
	#   returns        a list of "/name" entries
	#   warning        Raises an error when the argument is not a list
	#   see            FindFiles, DeepFindTheseFiles
	def FindTheseFiles(acFilesNames)
		if NOT isList(acFilesNames)
			StzRaise("Incorrect param type! acFilesNames must be a list.")
		ok
		_acFound_ = []
		_nLen_ = len(acFilesNames)

		for i = 1 to _nLen_
			_acFileResults_ = This.FindFiles(acFilesNames[i])

			# `len(acFileResult)` -- a name that exists nowhere. The method
			# raised R24 "Using uninitialized variable: acfileresult" on its
			# first result, so FindTheseFiles never worked at all.
			#
			# It also HID the bug below it: with the loop bound coming from a
			# variable that does not exist, the body was unreachable, so the
			# shadowed find() was never called.
			_nLenR_ = len(_acFileResults_)

			for j = 1 to _nLenR_
				# StzFindFirst, not find(). This class defines its own
				# Find(_cPattern_), which takes ONE argument, and inside the
				# class that name beats Ring's two-argument builtin -- so this
				# was an R20 waiting for the first file that matched.
				#
				# Note the ORDER changes with the call: Ring's find is
				# (list, item); StzFindFirst is NEEDLE-FIRST.
				if StzFindFirst(_acFileResults_[j], _acFound_) = 0
					_acFound_ + _acFileResults_[j]
				ok
			next
		next

		return _acFound_

	# Returns the folders held directly here that match any of a list of * patterns, each folder once; plain names match nothing.
	#
	#   acFoldersNames   a list of * patterns, such as sub*
	#   returns          a list of "/name/" entries
	#   warning          Raises an error when the argument is not a list; a plain name answers
	#                    nothing for the reason given at FindFolders
	#   see              FindFolders, DeepFindTheseFolders
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
				# Same shadowed find() as in FindTheseFiles above -- but this
				# one's loop bound is correct, so it was reachable: the first
				# folder that matched would have raised R20.
				if StzFindFirst(_acFolderResults_[j], _acFound_) = 0
					_acFound_ + _acFolderResults_[j]
				ok
			next

		next

		return _acFound_


	# Returns the files and then the folders held directly here that match a name or a pattern with *, as one flat list.
	#
	#   _cPattern_   a name or a pattern with * as a wildcard
	#   returns      a list of text: the file entries "/name", then the folder entries "/name/"
	#   note         FindFiles and FindFolders give the two halves apart
	#   see          FindFiles, FindFolders, DeepFind
	def Find(_cPattern_)
		_acResult_ = This.FindFiles(_cPattern_)
		_acFolders_ = This.FindFolders(_cPattern_)
		_nLen_ = len(_acFolders_)
		for i = 1 to _nLen_
			_acResult_ + _acFolders_[i]
		next
		return _acResult_

	# Returns the files of the whole tree below that match a name or a pattern with *, ignoring case.
	#
	#   _cPattern_   a file name, or a pattern with * as a wildcard
	#   returns      a list of "/folder/name" entries; [ ] when none match
	#   note         DeepFindFile and DeepFindThisFile are the same method; a name is matched on its
	#                last segment, a * pattern on the whole entry
	#   warning      Raises an error when the argument is not text
	#   see          FindFiles, DeepFiles, DeepFindFolders
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

	# Returns the folders of the whole tree below that match a name or a pattern with *, ignoring case.
	#
	#   _cPattern_   a folder name, or a pattern with * as a wildcard
	#   returns      a list of "/folder/name/" entries; [ ] when none match
	#   note         DeepFindFolder and DeepFindThisFolder are the same method; unlike the top-level
	#                search, a plain name matches here
	#   warning      Raises an error when the argument is not text
	#   see          FindFolders, DeepFolders, DeepFindFiles
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

	# Returns the files of the whole tree below that match any of a list of names or patterns, each file once.
	#
	#   acFilesNames   a list of file names or * patterns
	#   returns        a list of "/folder/name" entries
	#   warning        Raises an error when the argument is not a list
	#   see            DeepFindFiles, FindTheseFiles
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
				if StzFindFirst(_acFileResults_[j], _acFound_) = 0
					_acFound_ + _acFileResults_[j]
				ok
			next
		next

		return _acFound_

	# Returns the folders of the whole tree below that match any of a list of names or patterns, each folder once.
	#
	#   acFoldersNames   a list of folder names or * patterns
	#   returns          a list of "/folder/name/" entries
	#   warning          Raises an error when the argument is not a list
	#   see              DeepFindFolders, FindTheseFolders
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
				if StzFindFirst(_acFolderResults_[j], _acFound_) = 0
					_acFound_ + _acFolderResults_[j]
				ok
			next

		next

		return _acFound_


	# Returns the files and then the folders of the whole tree that match a name or a pattern with *, as one flat list.
	#
	#   _cPattern_   a name or a pattern with * as a wildcard
	#   returns      a list of text: the file entries "/folder/name", then the folder entries "/folder/name/"
	#   note         DeepFindFileOrFolder and DeepFindThisFileOrFolder are the same method; the two
	#                finders give the halves apart
	#   see          DeepFindFiles, DeepFindFolders, Find
	def DeepFind(_cPattern_)
		_acResult_ = This.DeepFindFiles(_cPattern_)
		_acFolders_ = This.DeepFindFolders(_cPattern_)
		_nLen_ = len(_acFolders_)
		for i = 1 to _nLen_
			_acResult_ + _acFolders_[i]
		next
		return _acResult_

		def DeepFindFileOrFolder(_cPattern_)
			return This.DeepFind(_cPattern_)

		def DeepFindThisFileOrFolder(_cPattern_)
			return This.DeepFind(_cPattern_)

	#=====================#
	#  Search Operations  #
	#=====================#

	# Returns the numbers of the lines of a file, given by its absolute path, that hold a text, ignoring case.
	#
	#   _cFilePath_   the absolute path of a file
	#   cContent      the text to look for
	#   returns       a list of line numbers, 1 for the first; [ ] when nothing matches
	def _LinesHolding(_cFilePath_, cContent)
		_acLineNumbers_ = []
		if NOT fexists(_cFilePath_)
			return _acLineNumbers_
		ok
		_acLines_ = @split(read(_cFilePath_), char(10))
		_nLines_ = len(_acLines_)
		_cLow_ = StzLower(cContent)
		for k = 1 to _nLines_
			if StzFindFirst(_cLow_, StzLower(_acLines_[k])) > 0
				_acLineNumbers_ + k
			ok
		next
		return _acLineNumbers_

	# Returns, for each file held directly here, the numbers of the lines that hold a text, ignoring case; files with no match are left out.
	#
	#   cContent   the text to look for
	#   returns    a list of [ "/name", [ line numbers ] ] pairs
	#   note       A line matches when it holds the text anywhere in it
	#   warning    Raises an error when the argument is not text
	#   see        SearchInFile, DeepSearchInFiles
	def SearchInFiles(cContent)
		if NOT isString(cContent)
			StzRaise("Incorrect param type! cContent must be a string.")
		ok
		return This.SearchInTheseFiles(This.Files(), cContent)


	# Returns the numbers of the lines of one file that hold a text, ignoring case.
	#
	#   _cFile_    a file name, or a path below the current position
	#   cContent   the text to look for
	#   returns    a list of line numbers, 1 for the first; [ ] when the file is missing or nothing
	#              matches
	#   note       SearchInThisFile is the same method; a sub-path such as sub1/d.txt is read from
	#              the current position
	#   warning    Raises an error when an argument is not text
	#   see        SearchInFiles, DeepSearchInFile
	def SearchInFile(_cFile_, cContent)
		if NOT isString(_cFile_) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok
		_acLineNumbers_ = []
		_cFullPath_ = @cCurrentPath + This.Separator() + _cFile_
		if fexists(_cFullPath_)
			_cFileContent_ = read(_cFullPath_)
			_acLines_ = @split(_cFileContent_, char(10))

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

	# Returns, for each listed file, the numbers of the lines that hold a text; files with no match are left out.
	#
	#   _acFiles_   a list of file names
	#   cContent    the text to look for
	#   returns     a list of [ name as given, [ line numbers ] ] pairs
	#   warning     Raises an error when the files are not a list or the text is not text
	#   see         SearchInFile, SearchInFiles
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

	# Returns, for each file of the folders held directly here, the numbers of the lines that hold a text, ignoring case.
	#
	#   cContent   the text to look for
	#   returns    a list of [ file name, [ line numbers ] ] pairs; files with no match are left out
	#   note       The folders inside those folders are not entered; DeepSearchInFiles goes all the way down
	#   warning    Raises an error when the argument is not text
	#   see        SearchInFolder, DeepSearchInFiles
	def SearchInFolders(cContent)
		if NOT isString(cContent)
			StzRaise("Incorrect param type! cContent must be a string.")
		ok
		return This.SearchInTheseFolders(This.Folders(), cContent)

	# Returns, for each file of a child folder, the numbers of the lines that hold a text, ignoring case.
	#
	#   _cFolder_   a child folder, as a name
	#   cContent    the text to look for
	#   returns     a list of [ file name, [ line numbers ] ] pairs; files with no match are left out
	#   note        SearchInThisFolder is the same method; the folders inside it are not entered
	#   warning     Raises an error when an argument is not text
	#   see         SearchInFile, DeepSearchInFiles
	def SearchInFolder(_cFolder_, cContent)

		if NOT isString(_cFolder_) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		_acResults_ = []
		_cFolderPath_ = This._ResolveInHere(_cFolder_)

		if StzEngineDirExists(_cFolderPath_)

			_aEntries_ = @dir(_cFolderPath_)
			_nLen_ = len(_aEntries_)

			for i = 1 to _nLen_

				if _aEntries_[i][2] = 0

					_acLineNumbers_ = This._LinesHolding(_cFolderPath_ + This.Separator() + _aEntries_[i][1], cContent)

					if len(_acLineNumbers_) > 0
						_acResults_ + [_aEntries_[i][1], _acLineNumbers_]
					ok
				ok
			next
		ok
		return _acResults_

		def SearchInThisFolder(_cFolder_, cContent)
			return This.SearchInFolder(_cFolder_, cContent)

	# Returns, for each file of the listed child folders, the numbers of the lines that hold a text, ignoring case.
	#
	#   _acFolders_   a list of child folder names
	#   cContent      the text to look for
	#   returns       a list of [ file name, [ line numbers ] ] pairs; files with no match are left out
	#   warning       Raises an error when the folders are not a list or the text is not text
	#   see           SearchInFolder
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


	# Returns, for each file of the whole tree below, the numbers of the lines that hold a text, ignoring case; files with no match are left out.
	#
	#   cContent   the text to look for
	#   returns    a list of [ absolute path, [ line numbers ] ] pairs
	#   warning    Raises an error when the argument is not text
	#   see        SearchInFiles, DeepSearchInFile
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
				_acLines_ = @split(_cFileContent_, char(10))
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


	# Returns the line numbers that hold a text in every file of that name found anywhere below, ignoring case.
	#
	#   _cFile_    the file name to look for
	#   cContent   the text to look for
	#   returns    a list of [ absolute path, [ line numbers ] ] pairs
	#   note       The file name is matched ignoring case
	#   warning    Raises an error when an argument is not text
	#   see        DeepSearchInFiles, SearchInFile
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
				_acLines_ = @split(_cFileContent_, char(10))
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


	# Returns the line numbers that hold a text in every file below that has one of the listed names.
	#
	#   _acFiles_   a list of file names
	#   cContent    the text to look for
	#   returns     a list of [ absolute path, [ line numbers ] ] pairs
	#   warning     Raises an error when the files are not a list or the text is not text
	#   see         DeepSearchInFile
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


	# Returns the lines that hold a text in the files of every folder of that name found anywhere below, ignoring case.
	#
	#   _cFolder_   a folder name, with or without slashes
	#   cContent    the text to look for
	#   returns     a list of [ absolute path, [ line numbers ] ] pairs, one per file with a match
	#   note        Only the files directly in those folders are read; DeepSearchInFiles reads every file below
	#   warning     Raises an error when an argument is not text
	#   see         DeepSearchInFiles
	def DeepSearchInFolder(_cFolder_, cContent)
		if NOT isString(_cFolder_) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		_acResults_ = []
		_acFolderPaths_ = This._DeepPathsNamed(_cFolder_, 1)
		_nLen_ = len(_acFolderPaths_)

		for i = 1 to _nLen_

			_aEntries_ = @dir(_acFolderPaths_[i])
			_nLenE_ = len(_aEntries_)

			for j = 1 to _nLenE_

				if _aEntries_[j][2] = 0

					_cFilePath_ = _acFolderPaths_[i] + This.Separator() + _aEntries_[j][1]
					_acLineNumbers_ = This._LinesHolding(_cFilePath_, cContent)

					if len(_acLineNumbers_) > 0
						_acResults_ + [_cFilePath_, _acLineNumbers_]
					ok
				ok

			next

		next

		return _acResults_


	# Returns the lines that hold a text in the files of every folder bearing one of the listed names below, ignoring case.
	#
	#   _acFolders_   a list of folder names
	#   cContent      the text to look for
	#   returns       a list of [ absolute path, [ line numbers ] ] pairs, one per file with a match
	#   warning       Raises an error when the folders are not a list or the text is not text
	#   see           DeepSearchInFolder, DeepSearchInFiles
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

	# TRUE if a name fits a pattern whose star is at the start, the end or both ends; a lone star fits everything, anything else must be equal.
	#
	#   _cPattern_   a pattern such as *.txt, a*, *b* or a plain name
	#   _cName_      the name to test
	#   returns      TRUE or FALSE
	#   note         A star in the middle, as in a*c, is not supported and only matches an equal
	#                name, read from the body
	#   warning      The test is case-sensitive, and a question mark is not a wildcard although it
	#                is converted
	#   see          CountFileMatches, FindFiles
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


	# Returns the names of the folders on the way from the current position to the files that match a pattern.
	#
	#   _cPath_      the folder to search, as an absolute path
	#   _cPattern_   the file pattern
	#   returns      a list of folder names, each once, such as [ "sub1", "deep1" ]
	#   note         VizDeepFindFiles opens exactly those folders in its drawing
	#   see          CollectFoldersWithFileMatches, VizDeepFindFiles
	def GetFoldersContainingFileMatches(_cPath_, _cPattern_)

		_aAllPaths_ = This.CollectFoldersWithFileMatches(_cPath_, _cPattern_, [])
		_nLen_ = len(_aAllPaths_)

		_aFolderNames_ = []

		for i = 1 to _nLen_

			_acPathParts_ = This.GetPathHierarchy(_aAllPaths_[i])
			_nLenP_ = len(_acPathParts_)

			for j = 1 to _nLenP_
				if StzFindFirst(_acPathParts_[j], _aFolderNames_) = 0
					_aFolderNames_ + _acPathParts_[j]
				end
			next

		next

		return _aFolderNames_


	# Returns how many files held directly in a folder match a pattern; the match is case-sensitive against lowercase names.
	#
	#   _cPath_      the folder to count in, as an absolute path
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      a number
	#   warning      A pattern with capitals such as *.TXT counts 0, because the names are listed in
	#                lowercase
	#   see          CountFolderMatches, Matches
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

	# Returns how many folders held directly in a folder match a pattern; the match is case-sensitive against lowercase names.
	#
	#   _cPath_      the folder to count in, as an absolute path
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      a number
	#   see          CountFileMatches, Matches
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

	# Replaces every occurrence of a text in a file held under the current position, and answers 1 if the file exists, 0 if not.
	#
	#   _cFile_       a file name or a sub-path below the current position
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       1 or 0; 1 even when the text was not found
	#   note          The replacement is case-sensitive and covers every occurrence; the file is
	#                 rewritten
	#   warning       Raises an error when an argument is not text
	#   see           FileModify, ModifyInFiles
	def ModifyInFile(_cFile_, cContent, cNewContent)
		if NOT isString(_cFile_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok
		_cFullPath_ = @cCurrentPath + This.Separator() + _cFile_
		if fexists(_cFullPath_)
			_cFileContent_ = read(_cFullPath_)
			_cModifiedContent_ = StzReplace(_cFileContent_, cContent, cNewContent)
			write(_cFullPath_, _cModifiedContent_)
			return 1
		ok
		return 0

	# Replaces a text in each listed file and returns how many of them exist.
	#
	#   _acFiles_     a list of file names
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       a number
	#   note          Missing names are skipped
	#   warning       Raises an error when the files are not a list or a text argument is not text
	#   see           ModifyInFile
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


	# Replaces a text in every file held directly in a child folder and returns how many files were rewritten.
	#
	#   _cFolder_     a child folder name
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       a number, counting the files rewritten even where nothing changed
	#   note          A missing folder gives 0; folders inside it are not entered
	#   warning       Raises an error when an argument is not text
	#   see           ModifyInFolders, ModifyInRoot
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


	# Replaces a text in every file held directly in each listed child folder and returns the total rewritten.
	#
	#   _acFolders_   a list of child folder names
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       a number
	#   warning       Raises an error when the folders are not a list or a text argument is not text
	#   see           ModifyInFolder
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


	# Replaces a text in every file held directly here and returns how many files were rewritten.
	#
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       a number, counting every file, even those where nothing changed
	#   note          Subfolders are not entered
	#   warning       Raises an error when an argument is not text
	#   see           ModifyInFolder, DeepModifyInRoot
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


	# Replaces a text in every file of that name found anywhere below and returns how many files were rewritten.
	#
	#   _cFile_       the file name to change, ignoring case
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       a number, counting every file of that name, even those where nothing changed
	#   note          ModifyInFile with a sub-path changes one file
	#   warning       Raises an error when an argument is not text
	#   see           ModifyInFile
	def DeepModifyInFile(_cFile_, cContent, cNewContent)

		if NOT isString(_cFile_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok

		_nModified_ = 0
		_acFilePaths_ = This._DeepPathsNamed(_cFile_, 0)
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


	# Replaces a text in every file bearing one of the listed names found anywhere below, and returns how many were rewritten.
	#
	#   _acFiles_     a list of file names
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       a number
	#   warning       Raises an error when the files are not a list or a text argument is not text
	#   see           DeepModifyInFile
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


	# Replaces a text in the files held directly in every folder of that name found anywhere below, and returns how many were rewritten.
	#
	#   _cFolder_     the folder name, ignoring case
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       a number, counting every file, even those where nothing changed
	#   note          ModifyInFolder does the same for one child folder; the folders inside are entered only if they bear the name too
	#   warning       Raises an error when an argument is not text
	#   see           ModifyInFolder
	def DeepModifyInFolder(_cFolder_, cContent, cNewContent)

		if NOT isString(_cFolder_) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok

		_nModified_ = 0
		_acFolderPaths_ = This._DeepPathsNamed(_cFolder_, 1)
		_nLen_ = len(_acFolderPaths_)

		for i = 1 to _nLen_

			if StzEngineDirExists(_acFolderPaths_[i])

				_cFolderPath_ = _acFolderPaths_[i]
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


	# Replaces a text in the files held directly in every folder bearing one of the listed names below, and returns how many were rewritten.
	#
	#   _acFolders_   a list of folder names
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       a number
	#   warning       Raises an error when the folders are not a list or a text argument is not text
	#   see           DeepModifyInFolder
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

	# Replaces a text in every file of the whole tree below and returns how many files were rewritten.
	#
	#   cContent      the text to replace
	#   cNewContent   the text to put in its place
	#   returns       a number, counting every file, even those where nothing changed
	#   note          ModifyInRoot does the top level only
	#   warning       Raises an error when an argument is not text
	#   see           ModifyInRoot, DeepModifyInFile
	def DeepModifyInRoot(cContent, cNewContent)

		if NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		_nModified_ = 0
		_acAllFiles_ = This.DeepFilesXT()
		_nLen_ = len(_acAllFiles_)

		for i = 1 to _nLen_

			_cFilePath_ = _acAllFiles_[i]

			if fexists(_cFilePath_)

				_cFileContent_ = read(_cFilePath_)
				_cModifiedContent_ = StzReplace(_cFileContent_, cContent, cNewContent)

				write(_cFilePath_, _cModifiedContent_)
				_nModified_++

			ok

		next

		return _nModified_

	#=================#
	#  Visualization  #
	#=================#

	# Returns the folder drawn as a tree, with the files and folders that match a pattern marked and counted.
	#
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      text, a tree whose first line gives the number of matches
	#   note         VizSearchFiles is the same method as VizFindFiles; folders with a match inside
	#                are drawn open with their count
	#   see          VizFindFiles, VizDeepSearch, ToString
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

	# Returns the folder drawn as a tree, with the matching files marked and counted.
	#
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      text, a tree whose first line gives the number of file matches
	#   note         VizSearchFiles is the same method
	#   see          VizSearch, VizDeepFindFiles
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

	# Returns the folder drawn as a tree, with the matching folders marked and counted.
	#
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      text, a tree whose first line gives the number of folder matches
	#   note         VizSearchFolders and VizSearchDirs are the same method
	#   see          VizSearch, VizDeepFindFolders
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

	# Returns the whole tree drawn down to the display depth, with every matching file and folder marked and counted.
	#
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      text, a tree whose first line gives the number of matches
	#   note         VizDeepFindFilesAndFolders is the same method
	#   see          VizSearch, SetMaxDisplayLevel
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

	# Returns the whole tree drawn down to the display depth, with the matching files marked and only their folders opened.
	#
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      text, a tree whose first line gives the number of file matches
	#   note         VizDeepSearch draws a similar tree with the folder matches as well
	#   see          VizDeepSearch, GetFoldersContainingFileMatches
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

	# Returns the whole tree drawn down to the display depth, with the matching folders marked and counted.
	#
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      text, a tree whose first line gives the number of folder matches
	#   note         VizDeepSearchDirs is the same method
	#   see          VizFindFolders, VizDeepSearch
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

	# Returns the folder drawn as a tree with icons, folders closed unless an expand mode opens them, in the chosen display order.
	#
	#   returns    text of several lines, the folder first
	#   note       Needs a console that shows the icons; the default order lists the files first, in
	#              ascending order
	#   see        Show, ToStringXT, SetDisplayOrder, DeepExpandAll
	def ToString()
		_cFolderName_ = This.Name()
		_cResult_ = @acDisplayChars[:FolderRoot] + " " + _cFolderName_ + char(10)

		_cResult_ += This.GenerateVizTreeString(
			This.Path(), '', 1,
			'', "", 0, This.MaxDisplayLevel()
		)

		return _cResult_

	# Prints the folder drawn as a tree, as the text form gives it.
	#
	#   returns    nothing; the tree is printed
	#   see        ToString, ShowXT
	def Show()
		? This.ToString()

	def ToStringXT()
		_cStatPattern_ = This.DisplayStatPattern()
		if _cStatPattern_ = ""
			_cStatPattern_ = _cStatPattern_ = "@count"
		ok

		_cFolderName_ = This.Name()
		_cStats_ = trim(This.FormatStats(This, _cStatPattern_))

		_cResult_ = @acDisplayChars[:FolderRootXT] + " " + _cFolderName_ + " " + _cStats_ + char(10)

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

	# Marks every non-empty folder to be drawn open and clears the other expand and collapse choices.
	#
	#   returns    nothing; the object is changed in place
	#   note       ExpandAll is the same method; the folders are tested for emptiness where they
	#              are, so every level opens and nothing is created
	#   see        DeepExpandAll, ExpandFolders, CollapseAll, ToString
	def Expand()
		@bExpand = 1
		@bDeepExpandAll = 0
		@acDeepExpandFolders = []

		@bCollapseAll = 0
		@acCollapseFolders = []

		# Marks every non-empty folder to be drawn open and clears the other expand and collapse choices.
		#
		#   returns    nothing; the object is changed in place
		#   see        Expand, DeepExpandAll
		def ExpandAll()
			This.Expand()

	# Marks one folder to be drawn open.
	#
	#   _cFolder_   the folder name to open
	#   returns     nothing; the object is changed in place
	#   note        A path with more than one level goes to the deep list
	#   see         ExpandFolders, DeepExpandFolder
	def ExpandFolder(_cFolder_)
		This.ExpandFolders([_cFolder_])

		# Marks one folder to be drawn open.
		#
		#   _cFolder_   the folder name to open
		#   returns     nothing; the object is changed in place
		#   see         ExpandFolder, ExpandFolders
		def ExpandThisFolder(_cFolder_)
			This.ExpandFolders([_cFolder_])

		# Marks one folder to be drawn open.
		#
		#   _cFolder_   the folder name to open
		#   returns     nothing; the object is changed in place
		#   see         ExpandFolder
		def ExpandThis(_cFolder_)
			This.ExpandFolders([_cFolder_])

	# Marks several folders to be drawn open and switches off the collapse-all choice.
	#
	#   _acFolders_   a list of folder names to open
	#   returns       nothing; the object is changed in place
	#   note          A name with more than one level goes to the deep list
	#   warning       Raises an error when the argument is not a list of text
	#   see           ExpandFolder, Expand, DeepExpandFolders
	def ExpandFolders(_acFolders_)
	    if CheckParams()
	        if Not (isList(_acFolders_) and IsListOfStrings(_acFolders_))
	            StzRaise("Incorrect param type! acFolders must be a list of strings.")
	        ok
	    ok
	
		_nLen_ = len(_acFolders_)

		for i = 1 to _nLen_
			_cPath_ = This.NormalizeFolderPath(_acFolders_[i])
			if This._IsDeepFolderShape(_cPath_)
				@acDeepExpandFolders + _cPath_
			else
				@acExpandFolders + _cPath_
			ok
		next

	    @bCollapseAll = 0
	
		# Marks several folders to be drawn open.
		#
		#   _acFolders_   a list of folder names to open
		#   returns       nothing; the object is changed in place
		#   see           ExpandFolders
		def ExpandTheseFolders(_acFolders_)
			This.ExpandFolders(_acFolders_)

		# Marks several folders to be drawn open.
		#
		#   _acFolders_   a list of folder names to open
		#   returns       nothing; the object is changed in place
		#   see           ExpandFolders
		def ExpandThese(_acFolders_)
			This.ExpandTheseFolders(_acFolders_)

	# Marks every folder at every depth to be drawn open, the empty ones included.
	#
	#   returns    nothing; the object is changed in place
	#   note       DeepExpand is the same method
	#   see        Expand, DeepExpandFolders, CollapseAll
	#@ aka  --
	def DeepExpandAll()
		@bExpand = 0
		@bDeepExpandAll = 1
		@acDeepExpandFolders = []

		@bCollapseAll = 0
		@acCollapseFolders = []

		# Marks every folder at every depth to be drawn open.
		#
		#   returns    nothing; the object is changed in place
		#   see        DeepExpandAll
		def DeepExpand()
			This.DeepExpandAll()

	# Marks one folder to be drawn open together with everything below it.
	#
	#   _cFolder_   the folder name to open
	#   returns     nothing; the object is changed in place
	#   see         DeepExpandFolders, ExpandFolder
	def DeepExpandFolder(_cFolder_)
		This.DeepExpandFolders([_cFolder_])
	
		# Marks one folder to be drawn open together with everything below it.
		#
		#   _cFolder_   the folder name to open
		#   returns     nothing; the object is changed in place
		#   see         DeepExpandFolder
		def DeepExpandThisFolder(_cFolder_)
			This.DeepExpandFolders([_cFolder_])
	
		# Marks one folder to be drawn open together with everything below it.
		#
		#   _cFolder_   the folder name to open
		#   returns     nothing; the object is changed in place
		#   see         DeepExpandFolder
		def DeepExpandThis(_cFolder_)
			This.DeepExpandFolders([_cFolder_])
	
	# Marks several folders to be drawn open together with everything below them; a single text is accepted too.
	#
	#   _acFolders_   a list of folder names, or one name
	#   returns       nothing; the object is changed in place
	#   note          The other choices are cleared
	#   see           DeepExpandFolder, DeepExpandAll
	def DeepExpandFolders(_acFolders_)
		if isString(_acFolders_)
			@acDeepExpandFolders = [_acFolders_]
		else
			@acDeepExpandFolders = _acFolders_
		end
		@bCollapseAll = 0
		@bDeepExpandAll = 0

		# Marks several folders to be drawn open together with everything below them.
		#
		#   _acFolders_   a list of folder names
		#   returns       nothing; the object is changed in place
		#   see           DeepExpandFolders
		def DeepExpandTheseFolders(_acFolders_)
			This.DeepExpandFolders(_acFolders_)
	
		# Marks several folders to be drawn open together with everything below them.
		#
		#   _acFolders_   a list of folder names
		#   returns       nothing; the object is changed in place
		#   see           DeepExpandFolders
		def DeepExpandThese(_acFolders_)
			This.DeepExpandTheseFolders(_acFolders_)

	# Marks every folder to be drawn closed and clears the expand choices.
	#
	#   returns    nothing; the object is changed in place
	#   note       Collapse is the same method; it is the starting state of ToString
	#   see        Collapse, Expand, DeepExpandAll
	#@ aka  --
	def CollapseAll()
		@bCollapseAll = 1
		@bExpand = 0
		@bDeepExpandAll = 0

		@acExpandFolders = []
		@acDeepExpandFolders = []

		# Marks every folder to be drawn closed and clears the expand choices.
		#
		#   returns    nothing; the object is changed in place
		#   see        CollapseAll
		def Collapse()
			This.CollapseAll()

	# Stores folders to be drawn closed but has no visible effect today; it only switches the expand mode off.
	#
	#   _acFolders_   a list of folder names, or one name
	#   returns       nothing; the object is changed in place
	#   note          Use CollapseAll then ExpandFolders to show only some folders open
	#   warning       The collapse list is read only while the expand mode is on, and it also
	#                 switches that mode off and is cleared by Expand, so it is never used
	#   see           CollapseAll, ExpandFolders
	def CollapseFolders(_acFolders_)
		if isString(_acFolders_)
			@acCollapseFolders = [_acFolders_]
		else
			@acCollapseFolders = _acFolders_
		end
		@bExpand = 0
		@bDeepExpandAll = 0

		# Stores folders to be drawn closed but has no visible effect today.
		#
		#   _acFolders_   a list of folder names
		#   returns       nothing; the object is changed in place
		#   warning       The same fault as CollapseFolders
		#   see           CollapseFolders
		def CollapseTheseFolders(_acFolders_)
			This.CollapseFolders(_acFolders_)

		# Stores folders to be drawn closed but has no visible effect today.
		#
		#   _acFolders_   a list of folder names
		#   returns       nothing; the object is changed in place
		#   warning       The same fault as CollapseFolders
		#   see           CollapseFolders
		def CollapseThese(_acFolders_)
			This.CollapseFolders(_acFolders_)

	# Returns the number of levels the tree drawings go down to.
	#
	#   returns    a number; 5 by default
	#   see        SetMaxDisplayLevel, ToString
	#---
	def MaxDisplayLevel()
		return @nMaxDisplayLevel

	# Sets how many levels the tree drawings go down to.
	#
	#   n          the number of levels
	#   returns    nothing; the object is changed in place
	#   warning    Raises an error when the argument is not a number
	#   see        MaxDisplayLevel
	def SetMaxDisplayLevel(n)
		if not isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
		@nMaxDisplayLevel = n

	# Returns the statistics pattern written after each folder name in the counted view.
	#
	#   returns    text; @count by default
	#   note       DisplayStat is the same method
	#   see        SetDisplayStat, StatKeywords
	def DisplayStatPattern()
		return @cDisplayStatPattern

		# Returns the statistics pattern written after each folder name in the counted view.
		#
		#   returns    text; @count by default
		#   see        SetDisplayStat
		def DisplayStat()
			return @cDisplayStatPattern

	# Sets the statistics pattern of the counted view; it must hold at least one of the stat keywords.
	#
	#   _cPattern_   a pattern such as @countfiles files, @countfolders folders
	#   returns      nothing; the object is changed in place
	#   note         SetDisplayStartPattern is the same method; a count of 0 is dropped from the
	#                result
	#   warning      Raises an error (Incorrect start pattern!) for text that holds no keyword
	#   see          DisplayStatPattern, StatKeywords
	def SetDisplayStat(_cPattern_)
		if NOT isString(_cPattern_)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok

		if NOT This.IsStatPattern(_cPattern_)
			StzRaise("Incorrect start pattern!")
		ok

		@cDisplayStatPattern = _cPattern_

		# Sets the statistics pattern of the counted view; it must hold at least one of the stat keywords.
		#
		#   _cPattern_   a pattern such as @countfiles files, @countfolders folders
		#   returns      nothing; the object is changed in place
		#   warning      Raises an error (Incorrect start pattern!) for text that holds no keyword
		#   see          SetDisplayStat
		def SetDisplayStartPattern(_cPattern_)
			This.SetDisplayStat(_cPattern_)

	# Returns the keywords a statistics pattern may use, in lowercase.
	#
	#   returns    a list of 5 text values: @count, @countfiles, @countfolders, @deepcountfiles,
	#              @deepcountfolders
	#   see        IsStatPattern, SetDisplayStat
	def StatKeywords()
		return @acStatKeywords

	# TRUE if a text holds at least one of the stat keywords, ignoring case.
	#
	#   _cPattern_   the pattern to test
	#   returns      TRUE or FALSE; FALSE when it is not text
	#   see          StatKeywords, SetDisplayStat
	def IsStatPattern(_cPattern_)
		if Not isString(_cPattern_)
			return 0
		ok

		_cPattern_ = StzLower(_cPattern_)
		_acKeywords_ = This.StatKeywords()
		_nLen_ = len(_acKeywords_)
		_bResult_ = 0

		# NEEDLE FIRST. This read StzFindFirst(_cPattern_, _acKeywords_[i]),
		# which asks whether the whole display pattern occurs inside a short
		# keyword -- backwards, and 0 for anything real. SetDisplayStat()
		# then refused every pattern it was given with "Incorrect start
		# pattern!".
		#
		# It hid because the DEFAULT pattern is "@count", which IS a keyword:
		# inverted or not, a string is found in itself. Only a pattern longer
		# than a keyword -- i.e. any pattern worth setting -- exposed it.
		for i = 1 to _nLen_
			if StzFindFirst(_acKeywords_[i], _cPattern_) > 0
				_bResult_ = 1
				exit
			ok
		next
		return _bResult_

	# Returns the order the tree drawings list the entries in.
	#
	#   returns    text; filefirstascending by default
	#   see        SetDisplayOrder
	def DisplayOrder()
		return @cDisplayOrder

	# Sets the order of the tree drawings; the name is kept in lowercase.
	#
	#   cOrder     one of the five orders
	#   returns    nothing; the object is changed in place
	#   note       systemorder keeps the operating system's order and the original case of names
	#   warning    Raises an error, listing the valid orders, for any other text
	#   see        DisplayOrder
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
	# TRUE if the path holds no control character, those with codes 0 to 31.
	#
	#   _cPath_    the path to test
	#   returns    TRUE or FALSE
	#   note       HasNoPathInjection is the same method; a null byte makes it FALSE
	#   see        IsFilePath, IsFolderPath
	#TODO // Enhance this section
	def IsSecurePath(_cPath_)
		# Check for null bytes (path injection attempt)
		if StzFindFirst(StzChar(0), _cPath_) > 0
			return 0
		ok

		# Check for other control characters that could be used for injection
		for i = 1 to 31
			if StzFindFirst(StzChar(i), _cPath_) > 0
				return 0
			ok
		next
		
		return 1

	def HasNoPathInjection(_cPath_)
		return This.IsSecurePath(_cPath_)

	#===================#
	#  Utility Methods  #
	#===================#

	# Returns a new folder object at the current position, which becomes its home, with an empty history.
	#
	#   returns    a new stzFolder
	#   note       Clone is the same method; the display and batch settings are not carried over
	#   see        Path, GoHome
	def Copy()
		return new stzFolder(This.Path())

		def Clone()
			return This.Copy()

	# Does nothing, since listings are read fresh on every call, and hands the object back.
	#
	#   returns    the object itself
	#   see        Files, Folders
	def Refresh()
		# no-op: directory listing is always fresh via @dir()
		return This

	# Returns the text of a path before its last separator, or the current position when there is no separator after the first character.
	#
	#   _cPath_    a path
	#   returns    text
	#   note       Pure text work; nothing is read from disk
	#   see        ParentFolder, GetPathHierarchy
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

	# Returns the folder names that lead from the current position down to a path.
	#
	#   _cPath_    an absolute path below the current position, written with / or 	#   returns    a list of text; [ ] when the path is not below the current position
	#   note       A path two levels down, such as sub1/deep1 under the position, gives [ "sub1",
	#              "deep1" ]
	#   see        GetParentDirectory
	def GetPathHierarchy(_cPath_)
		_acParts_ = []
		_cClean_ = _CleanPath(_cPath_)
		_cBase_ = _CleanPath(This.Path()) + This.Separator()
		if StzLower(StzLeft(_cClean_, StzLen(_cBase_))) != StzLower(_cBase_)
			return []
		end
		_cRelativePath_ = StzMid(_cClean_, StzLen(_cBase_) + 1, StzLen(_cClean_) - StzLen(_cBase_))
		_acSegments_ = @split(_cRelativePath_, This.Separator())
		_nLen_ = len(_acSegments_)

		for i = 1 to _nLen_
			if _acSegments_[i] != ""
				_acParts_ + _acSegments_[i]
			end
		next

		return _acParts_

	# Returns the folders, a given one and those below it, that hold a file matching a pattern, added to a list passed in.
	#
	#   _cPath_               the folder to search, as an absolute path
	#   _cPattern_            the file pattern
	#   aFoldersWithMatches   the list the folders are added to, [ ] to start
	#   returns               a list of absolute folder paths; the list passed in is not changed
	#   see                   GetFoldersContainingFileMatches
	def CollectFoldersWithFileMatches(_cPath_, _cPattern_, aFoldersWithMatches)

		_aList_ = @dir(_cPath_)
		_aResult_ = aFoldersWithMatches
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
			_aResult_ + _cPath_
		end

		for i = 1 to _nLen_
			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				_aResult_ = This.CollectFoldersWithFileMatches(_cPath_ + This.Separator() + _aList_[i][1], _cPattern_, _aResult_)
			end
		next

		return _aResult_


		# Returns the last name of a path, the folder name for a folder path.
		#
		#   _cPath_    a path
		#   returns    text, such as c for a/b/c; an empty text for the current position itself
		#   see        GetParentDirectory
		def GetFolderNameFromPath(_cPath_)
			if _CleanPath(_cPath_) = _CleanPath(This.Path())
				return ""
			end
			return _DirName(_CleanPath(_cPath_))


	#================================#
	#  PRIVATE KITCHEN OF THE CLASS  #
	#================================#

	PRIVATE

	# Returns the entries of a folder as [ name, "file" or "folder" ] pairs ordered by the chosen display order.
	#
	#   _acFiles_     the file names
	#   _acFolders_   the folder names
	#   _cPath_       the folder, read only in the systemorder case
	#   returns       a list of [ name, kind ] pairs
	#   note          Private: calling it from outside the class raises error R26
	#   see           OrderFilesFirst, SetDisplayOrder
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

	# Returns the file names and then the folder names as [ [ "name", n ], [ "type", kind ] ] records.
	#
	#   _acFiles_     the file names
	#   _acFolders_   the folder names
	#   returns       a list of records, files first
	#   note          Private: calling it from outside the class raises error R26
	#   see           OrderFoldersFirst
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


	# Returns the folder names and then the file names as [ [ "name", n ], [ "type", kind ] ] records.
	#
	#   _acFiles_     the file names
	#   _acFolders_   the folder names
	#   returns       a list of records, folders first
	#   note          Private: calling it from outside the class raises error R26
	#   see           OrderFilesFirst
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


	# Returns a folder's entries as name and type records, in the order the listing gives them.
	#
	#   _cPath_    the folder to list
	#   returns    a list of [ [ "name", n ], [ "type", "file" or "folder" ] ] records
	#   note       Private: calling it from outside the class raises error R26
	#   see        SortItemsByDisplayOrder
	def GetPhysicalOrder(_cPath_)

		_aList_ = @dir(_cPath_)
		_nLen_ = len(_aList_)

		_aResult_ = []

		for i = 1 to _nLen_

			if _aList_[i][2] = 0
				_aResult_ + [:name = _aList_[i][1], :type = "file"]

			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				_aResult_ + [:name = _aList_[i][1], :type = "folder"]

			end

		next

		return _aResult_


	# Returns the statistics text shown after a folder in the counted view, from the stat pattern.
	#
	#   oFolder          the stzFolder whose counts are written
	#   _cStatPattern_   the pattern
	#   returns          text such as (5) for @count, or an empty text for an empty folder
	#   note             Without a keyword it writes (files:all files, folders:all folders), such as
	#                    (3:6 files, 2:3 folders). Private: calling it from outside the class raises
	#                    error R26
	#   see              SetDisplayStat
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


	# Returns the number of entries of a child folder as text, or an empty text when it is empty or missing.
	#
	#   _cFolderName_   a child folder name
	#   returns         text
	#   note            Private: calling it from outside the class raises error R26
	#   see             FormatStats
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


	# Returns the statistics pattern of a child folder with its keywords replaced by the counts.
	#
	#   _cFolderName_   a child folder name
	#   _cPattern_      the statistics pattern
	#   returns         text, the pattern with @countfiles, @countfolders and the deep forms replaced
	#   note            Private: calling it from outside the class raises error R26
	#   see             FormatStats
	def FormatStatsForFolder(_cFolderName_, _cPattern_)

		# Format stats for a specific folder

		_cResult_ = _cPattern_
		_cFolderPath_ = @cCurrentPath + This.Separator() + _cFolderName_
		
		# Get actual counts for this folder

		_nFiles_ = 0
		_nFolders_ = 0
		_aKids_ = @dir(_cFolderPath_)
		_nKids_ = len(_aKids_)
		for i = 1 to _nKids_
			if _aKids_[i][2] = 0
				_nFiles_++
			else
				_nFolders_++
			ok
		next
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

	# Returns how many files below a folder match a pattern, at every depth, case-sensitively.
	#
	#   _cPath_      the folder to search, as an absolute path
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      a number
	#   note         Private: calling it from outside the class raises error R26
	#   see          CountFileMatches, CountFolderMatchesRecursive
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

	# Returns how many folders below a folder match a pattern, at every depth, case-sensitively.
	#
	#   _cPath_      the folder to search, as an absolute path
	#   _cPattern_   a pattern with * as a wildcard
	#   returns      a number
	#   note         Private: calling it from outside the class raises error R26
	#   see          CountFolderMatches, CountFileMatchesRecursive
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

	# TRUE if the expand settings say a folder is drawn open, and 1 only for non-empty folders in the plain expand mode.
	#
	#   _cFolderName_   a folder name
	#   _cParentPath_   the absolute path of the folder that holds it, where its emptiness is read
	#   returns         TRUE or FALSE
	#   note            Private: calling it from outside the class raises error R26; nothing is created
	#   see             ShouldDeepExpandFolder, Expand
	def ShouldExpandFolder(_cFolderName_, _cParentPath_)

		if @bCollapseAll
			return 0
		end

		_cFolderName_ = This.NormalizeFolderPath(_cFolderName_)
		_cWhere_ = _CleanPath(_cParentPath_ + This.Separator() + _cFolderName_)

		# a folder that is not on disk is never drawn open
		if _KindOfPath(_cWhere_) != "folder"
			return 0
		end

		# If DeepExpandAll is enabled, expand all non-empty folders

		if @bDeepExpandAll

			if This.IsFolderEmpty(_cWhere_)
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

			if This.IsFolderEmpty(_cWhere_)
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


	# Returns the icon for a folder drawn open: the open-folder icon, or the one that marks a match when the folder holds matches.
	#
	#   _bSubfolderHasMatches_   1 if the folder holds a match
	#   _bIsEmpty_               1 if the folder is empty, which is ignored
	#   returns                  text, an icon
	#   note                     Private: calling it from outside the class raises error R26
	#   see                      ChooseFolderIcon
	def GetFolderIconForExpanded(_bSubfolderHasMatches_, _bIsEmpty_)

		if _bSubfolderHasMatches_
			return @acDisplayChars[:FolderOpenedFound]
		else
			return @acDisplayChars[:FolderOpened]
		end

	# Returns the icon for a folder drawn closed: one for an empty folder and another for a full one.
	#
	#   _bIsEmpty_   1 if the folder is empty
	#   returns      text, an icon
	#   note         Private: calling it from outside the class raises error R26
	#   see          ChooseFolderIcon
	def GetFolderIconForCollapsed(_bIsEmpty_)
		if _bIsEmpty_
			return @acDisplayChars[:FolderClosedEmpty]
		else
			return @acDisplayChars[:FolderClosedFull]
		end

	# Returns the icon of a folder: the open or the closed one, depending on whether it is drawn open.
	#
	#   _bShouldExpand_          1 if the folder is drawn open
	#   _bSubfolderHasMatches_   1 if it holds a match
	#   _bIsEmpty_               1 if it is empty
	#   returns                  text, an icon
	#   note                     Private: calling it from outside the class raises error R26
	#   see                      GetFolderIconForExpanded, GetFolderIconForCollapsed
	def ChooseFolderIcon(_bShouldExpand_, _bSubfolderHasMatches_, _bIsEmpty_)
		if _bShouldExpand_
			return This.GetFolderIconForExpanded(_bSubfolderHasMatches_, _bIsEmpty_)
		else
			return This.GetFolderIconForCollapsed(_bIsEmpty_)
		end

	# Returns the lines of the tree below a folder, indented by a prefix, with matches marked, down to a level limit.
	#
	#   _cPath_         the folder to draw
	#   _cPrefix_       the indent put before each line
	#   bIsRoot         1 for the top folder
	#   _cPattern_      the pattern whose matches are marked
	#   cSearchType     files, folders, both or showxt
	#   nCurrentLevel   the level of this call, 0 at the top
	#   nMaxLevels      the level at which drawing stops
	#   returns         text of one line per entry
	#   note            Private: calling it from outside the class raises error R26. It returns an
	#                   empty text once the current level reaches the limit
	#   see             ToString, VizSearch
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
	            _bShouldExpand_ = This.ShouldExpandFolder(_cItemName_, _cPath_) or _bSubfolderHasMatches_ or This.ShouldDeepExpandFolder(_cItemPath_)
	            
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


	# TRUE if every folder is deep-expanded, or if the folder path is below one of the deep-expanded folders.
	#
	#   _cFolderPath_   the folder path to test
	#   returns         TRUE or FALSE
	#   note            Private: calling it from outside the class raises error R26
	#   see             ShouldExpandFolder, DeepExpandFolders
	def ShouldDeepExpandFolder(_cFolderPath_)

		# If DeepExpandAll is enabled, expand all folders
		if @bDeepExpandAll
			return 1
		end
		
		if @acDeepExpandFolders = ""
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
