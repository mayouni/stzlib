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

func IsFolder(cPath)
	return dirExists(cPath)

	#< @FunctionAlternativeForms

	func IsDir(cPath)
		return dirExists(cPath)

	func @IsFolder(cPath)
		return dirExists(cPath)

	func @IsDir(cPath)
		return dirExists(cPath)

	#--

	func IsValidFolder(cPath)
		return dirExists(cPath)

	func IsValidDir(cPath)
		return dirExists(cPath)

	func @IsValidFolder(cPath)
		return dirExists(cPath)

	func @IsValidDir(cPath)
		return dirExists(cPath)

	#==

	func dirPathExists(cPath)
		return dirExists(cPath)

	func IsDirPath(cPath)
		return dirExists(cPath)

	func @IsFolderPath(cPath)
		return dirExists(cPath)

	func @IsDirPath(cPath)
		return dirExists(cPath)

	#--

	func IsValidFolderPath(cPath)
		return dirExists(cPath)

	func IsValidDirPath(cPath)
		return dirExists(cPath)

	func @IsValidFolderPath(cPath)
		return dirExists(cPath)

	func @IsValidDirPath(cPath)
		return dirExists(cPath)

	#>

func StzFolderQ(cPath)
	return new stzFolder(cPath)

func IsAbsolutePath(cPath)
	return cDir = StzFolderQ(cPath).AbsolutePath()

func @dir(cPath) # Same as Ring dir() but in lowercase
	if CheckParams()
		if NOT ( isString(cPath) and cPath != "" )
			StzRaise("Incorrect param type! cPath must be non-empty string.")
		ok
	ok

	#TODO // Add security checks

	aRingResult = dir(cPath)
	nLen = len(aRingResult)

	aResult = []
	for i = 1 to nLen
		aResult + [ aRingResult[i][1], aRingResult[i][2] ]
	next

	return aResult

func CreateIfInexistant(cPath)
    # Check if it has an extension (likely a file)
    if StzFind(cPath, ".")
        CreateFileIfInexistant(cPath)
    else
        CreateFolderIfInexistant(cPath)
    ok

	func CreateFolder(cPath)
		CreateIfInexistant(cPath)

	func @CreateFolder(cPath)
		CreateIfInexistant(cPath)

	func @CreateIfInexistant(cPath)
		CreateIfInexistant(cPath)

func FolderCreateIfInexistant(cFolderPath)
    if NOT isdir(cFolderPath)
        if isWindows()
            StzSystemSilentXT("cmd.exe", ["/c", "mkdir", cFolderPath])
        else
            StzSystemSilentXT("mkdir", ["-p", cFolderPath])
        ok
    ok

	func CreateFolderIfInexistant(cFolderPath)
		FolderCreateIfInexistant(cFolderPath)

	func @FolderCreateIfInexistant(cFolderPath)
		 FolderCreateIfInexistant(cFolderPath)

	func @CreateFolderIfInexistant(cFolderPath)
		FolderCreateIfInexistant(cFolderPath)

func RemoveFolderRecursive(cPath)
	aItems = dir(cPath)
	nLen = len(aItems)
	for i = 1 to nLen
		cName = aItems[i][1]
		if cName = "." or cName = ".." loop ok
		cFull = cPath + "/" + cName
		if aItems[i][2] = 0
			StzEngineFileDelete(cFull)
		else
			RemoveFolderRecursive(cFull)
		ok
	next
	return StzEngineDirDelete(cPath)

	RemoveFolderXT(cPath)
		return This.RemoveFolderRecursive()

func QMkdir(cPath) #TODO //Hormonize with CreateFolder!!!
	return StzEngineDirCreatePath(cPath)

	func mkdir(cPath)
		return QMkdir(cPath)

func NormalizePath(cPath)
	if CheckParams()
		if NOT ( isString(cPath) and trim(cPath) != "" )
			StzRaise("Incorrect param type! cPath must be a non-empty string.")
		ok
	ok
	
	if StzFind(cPath, ".") > 0
		return NormalizeFilePath(cPath)
	else
		return NormalizeFolderPath(cPath)
	ok

	func NormalisePath(cPath)
		return NormalizePath(cPath)

func NormalizePathXT(cPath)
	if CheckParams()
		if NOT ( isString(cPath) and trim(cPath) != "" )
			StzRaise("Incorrect param type! cPath must be a non-empty string.")
		ok
	ok

	# Check if it's a file (has extension) or folder
	if StzFind(cPath, ".") > 0
		return NormalizeFilePathXT(cPath)
	else
		return NormalizeFolderPathXT(cPath)
	ok

	func NormalisePathXR(cPath)
		return NormalizePathXT(cPath)

func NormalizeFolderPath(cName)
	cName = NormalizeFilePath(cName)
	
	if StzLeft(cName, 1) != "/"
		cName = "/" + cName
	ok

	if StzRight(cName, 1) != "/"
		cName += "/"
	ok

	return StzReplace(cName, "//", "/")

	func NormaliseFolderPath(cName)
		return NormalizeFolderPath(cName)

func NormalizeFolderPathXT(cName)
	cName = NormalizeFilePathXT(cName)

	if StzRight(cName, 1) != "/"
		cName += "/"
	ok

	return StzReplace(cName, "//", "/")

	func NormaliseFolderPathXT(cName)
		return NormalizeFolderPathXT(cName)

#--------------------------#
#  PURE RING PATH HELPERS  #
#--------------------------#

func _CleanPath(cPath)
	cPath = StzReplace(cPath, "\", "/")
	while StzFind(cPath, "//") > 0
		cPath = StzReplace(cPath, "//", "/")
	end
	if StzLen(cPath) > 1 and StzRight(cPath, 1) = "/"
		cPath = StzLeft(cPath, StzLen(cPath) - 1)
	ok
	return cPath

func _AbsolutePath(cPath)
	cPath = _CleanPath(cPath)
	if _IsAbsolutePath(cPath)
		return cPath
	ok
	return _CleanPath(currentDir() + "/" + cPath)

func _IsAbsolutePath(cPath)
	if StzLen(cPath) = 0 return FALSE ok
	if StzLeft(cPath, 1) = "/" return TRUE ok
	if StzLen(cPath) >= 2 and isalpha(StzLeft(cPath, 1)) and StzMid(cPath, 2, 1) = ":"
		return TRUE
	ok
	return FALSE

func _IsRootPath(cPath)
	cPath = _CleanPath(cPath)
	if cPath = "/" return TRUE ok
	if StzLen(cPath) = 2 and isalpha(StzLeft(cPath, 1)) and StzRight(cPath, 1) = ":"
		return TRUE
	ok
	if StzLen(cPath) = 3 and isalpha(StzLeft(cPath, 1)) and StzMid(cPath, 2, 1) = ":" and StzRight(cPath, 1) = "/"
		return TRUE
	ok
	return FALSE

func _DirName(cPath)
	cPath = _CleanPath(cPath)
	nPos = 0
	for i = StzLen(cPath) to 1 step -1
		if cPath[i] = "/"
			nPos = i
			exit
		ok
	next
	if nPos > 0
		return StzMid(cPath, nPos + 1, StzLen(cPath) - nPos)
	ok
	return cPath

func _ParentPath(cPath)
	cPath = _CleanPath(cPath)
	nPos = 0
	for i = StzLen(cPath) to 1 step -1
		if cPath[i] = "/"
			nPos = i
			exit
		ok
	next
	if nPos > 1
		return StzLeft(cPath, nPos - 1)
	ok
	if nPos = 1
		return "/"
	ok
	return cPath

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
		:FolderRoot = char(240)+char(159)+char(147)+char(129),
		:FolderRootXT = char(240)+char(159)+char(147)+char(130),
		:FolderOpened = char(240)+char(159)+char(151)+char(129),
		:FolderOpenedFound = char(240)+char(159)+char(151)+char(130),
		:FolderClosedEmpty = char(240)+char(159)+char(151)+char(128),
		:FolderClosedFull = char(240)+char(159)+char(150)+char(191),
		:FolderRootSearchSymbol = char(240)+char(159)+char(148)+char(141),
		:FileFoundSymbol = char(240)+char(159)+char(145)+char(137)
	]

	@bBacthMode = FALSE

	#== Initialization ==#

	def init(pcDirPath)

		if CheckParams() and NOT isString(pcDirPath)
			StzRaise("Incorrect param type! pcDirPath must be a string.")
		ok

		@acPathHistory = []

		cPath = ""
		if pcDirPath = "" or pcDirPath = NULL
			cPath = currentDir()
		else
			cPath = _CleanPath(pcDirPath)
		ok

		if NOT dirExists(cPath)
			if NOT StzEngineDirCreatePath(cPath)
				StzRaise("Cannot create directory: " + cPath)
			ok
		ok

		@cOriginalPath = _AbsolutePath(cPath)
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

	def IsInside(cPath)
	
	    if NOT ( isString(cPath) and cPath != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok
	
		cMainPath = _CleanPath(@cCurrentPath)
		cAbsolutePath = _CleanPath(_AbsolutePath(cPath))

		if StzRight(cMainPath, 1) != "/"
			cMainPath += "/"
		ok
		if StzRight(cAbsolutePath, 1) != "/"
			cAbsolutePath += "/"
		ok

		# Case-insensitive boundary check (Windows/NTFS is case-insensitive,
		# and we no longer lowercase the stored paths).
		cMainLow = StzLower(cMainPath)
		cAbsLow = StzLower(cAbsolutePath)
		nMainPathLen = Len(cMainLow)

		if Len(cAbsLow) >= nMainPathLen
			if Left(cAbsLow, nMainPathLen) = cMainLow
				if cAbsLow != cMainLow
					return True
				ok
			ok
		ok

		return False
	
		def IsPathInside(cPath)
			return This.IsInside(cPath)
	
		def PathIsInside(cPath)
			return This.IsInside(cPath)
	
	def IsOutside(cPath)
		return NOT This.IsInside(cPath)
	
		def IsPathOutside(cPath)
			return This.IsOutside(cPath)
	
		def PathIsOutside(cPath)
			return This.IsOutside(cPath)
	
	
	def IsFile(cPath)
	    # Checks if cPath represents a valid existing file within the folder scope
	
	    if NOT ( isString(cPath) and cPath != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok
	
	    cNormalizedPath = This.NormalizePathXT(cPath)
	
		if StzFind(This.FilesXT(), cNormalizedPath) > 0
			return 1
		else
			return 0
		ok
	
	    def IsValidFile(cPath)
	        return This.IsFile(cPath)
	
	    def IsExistingFile(cPath)
	        return This.IsFile(cPath)
	
	def IsFolder(cPath)
	    # Checks if cPath represents a valid existing folder within the folder scope
	
	    if NOT ( isString(cPath) and cPath != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok
	
		cPath = This.NormalizeFolderPath(cPath)
	
		if StzFind(This.Folders(), cPath) > 0
			return 1
		else
			return 0
		ok
	
	    def IsValidFolder(cPath)
	        return This.IsFolder(cPath)
	
	    def IsExistingFolder(cPath)
	        return This.IsFolder(cPath)
	
	    def IsDirectory(cPath)
	        return This.IsFolder(cPath)
	
	    def IsValidDirectory(cPath)
	        return This.IsFolder(cPath)
	
	    def IsExistingDirectory(cPath)
	        return This.IsFolder(cPath)
	
	def IsPath(cPath)
		return This.IsFilePath() or This.IsFolderPath()
	
	def IsFilePath(cPath)
		if CHeckParams()
			if NOT (isString(cPath) and cPath != "")
				raise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	
		# Check for path injection attempts
		if NOT IsSecurePath(cPath)
			raise("Insecure path with potential injection risks!")
		ok
		
		cPath = This.NormaliseFolderPath(cPath)
	
		if StzFind( This.Files(), cPath ) > 0
			return 1
		else
			return 0
		ok

	def IsFolderPath(cPath)
		if CHeckParams()
			if NOT (isString(cPath) and cPath != "")
				raise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	
		cPath = This.NormaliseFolderPath(cPath)
	
		# Check for path injection attempts
		if NOT IsSecurePath(cPath)
			raise("Insecure path with potential injection risks!")
		ok
		
		if StzFind( This.Folders(), cPath ) > 0
			return 1
		else
			return 0
		ok

	def IsDeep(cPath)
		if This.IsDeepFile(cPath) or This.IsDeepFolder(cPath)
			return 1
		else
			return 0
		ok
	
		def IsDeepPath(cPath)
			IsDeep(cPath)
	
	def IsDeepFile(cPath)
		cPath = This.NormalizePath(cPath)
		cSep = This.Separator()
	
		if StzRight(cPath, 1) = cSep # It's a folder not a file!
			return 0
		ok
	
		if StringNumberOfOccurrence(cpath, cSep) > 1
			return 1
		else
			return 0
		ok
	
		def IsDeepFilePath(cPath)
			return This.IsDeepFile(cPath)
	
	def IsDeepFolder(cPath)
		cPath = This.NormalizePath(cPath)
		cSep = This.Separator()
	
		if StzRight(cPath, 1) != cSep # It's a file not a folder!
			return 0
		ok
	
		if StringNumberOfOccurrence(cpath, cSep) > 2
			return 1
		else
			return 0
		ok
	
		def IsDeepFolderPath(cPath)
			return This.IsDeepFolder(cPath)

	#--

	def IsFolderEmpty(cFolderPath)

		cFolderName = This.NormalizeFolderPath(cFolderPath)
		oTempFolder = new stzFolder(cFolderPath)
		bHasFiles = oTempFolder.CountFiles() > 0
		bHasFolders = oTempFolder.CountFolders() > 0

		return (not bHasFiles and not bHasFolders)

		def IsEmptyFolder(cFolderPath)
			return This.IsFolderEmpty(cFolderPath)

	def IsSubfolderOf(cChildPath, cParentFolder)
		# Normalize paths for comparison
		cNormalizedChild = This.NormalizePathXT(cChildPath)
		cNormalizedParent = This.NormalizePathXT(This.Path() + This.Separator() + cParentFolder)
		
		# Check if child path starts with parent path
		return StzLeft(cNormalizedChild, StzLen(cNormalizedParent)) = cNormalizedParent
	
	#---
	
	def Exists(cPath)
	    # Checks if cPath exists (file or folder) within the folder scope
	    return This.IsFile(cPath) OR This.IsFolder(cPath)
	
	    def PathExists(cPath)
	        return This.Exists(cPath)
	
	    def IsValidPath(cPath)
	        return This.Exists(cPath)
	
		def ContainsPath(cPath)
			return This.Exists(cPath)
	
	def FileExists(cFileName)
	    # Alias for IsFile - checks if file exists
	    return This.IsFile(cFileName)
	
	def FolderExists(cFolderName)
	    # Alias for IsFolder - checks if folder exists  
	    return This.IsFolder(cFolderName)
	
	#--

	def DeepExists(cPath)
		return This.IsDeepFile(cPath) OR This.IsDeepFolder(cPath)

	    def PathDeepExists(cPath)
	        return This.DeepExists(cPath)
	
	    def IsValidDeepPath(cPath)
	        return This.DeepExists(cPath)
	
		def ContainsDeepPath(cPath)
			return This.DeepExists(cPath)

	def DeepFileExists(cFileName)
	    # Alias for IsFile - checks if file exists
	    return This.IsDeepFile(cFileName)
	
	def DeepFolderExists(cFolderName)
	    # Alias for IsFolder - checks if folder exists  
	    return This.IsDeepFolder(cFolderName)

	#=====================#
	#  NORMALIZING PATHS  #
	#=====================#
	
	def NormalizePath(cPath)
	
		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		if This.IsFilePath(cPath)
			return This.NormalizeFilePath(cPath)
		else
			return This.NormalizeFolderPath(cPath)
		ok


		def NormalisePath(cPath)
			return THis.NormalizePath(cPath)
	
	def NormalizePathXT(cPath)
	
		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	   
		if This.IsFilePath(cPath)
			return This.NormalizeFilePathXT(cPath)
		else
			return This.NormalizeFolderPathXT(cPath)
		ok


		def NormalisePathXT(cPath)
			return This.NormalizeXT(cPAth)
	
	def NormalizeFilePath(cName)
		if CheckParams()
			if NOT ( isString(cName) and trim(cName) != "" )
				StzRaise("Incorrect param type! cName must be a non-empty string.")
			ok
		ok
	    
	    # Preserve the real filesystem case AND drive letter -- only
	    # normalise separators. (The old code did "/" + StzLower(...), which
	    # lowercased names like "Docs"->"docs" and turned "D:/x" into
	    # "/d:/x", breaking IsInside boundary checks and the tree display.
	    # Case-insensitive matching is done at the comparison sites.)
	    cResult = _CleanPath(trim(cName))
		cResult = StzReplace(cResult, "//", "/")
		return cResult

		def NormaliseFilePath(cName)
			return This.NormalizeFilePath(cName)
	
	def NormalizeFilePathXT(cName)
		if CheckParams()
			if NOT ( isString(cName) and trim(cName) != "" )
				StzRaise("Incorrect param type! cName must be a non-empty string.")
			ok
		ok
	    
	    cBasePath = @cCurrentPath
	    cCleanName = _CleanPath(trim(cName))
	    
	    # If not absolute, make it relative to base path
	    if NOT _IsAbsolutePath(cCleanName)
	        cCleanName = _CleanPath(cBasePath + "/" + cCleanName)
	    ok
	    
	    cResult = _CleanPath(cCleanName)   # preserve case (was StzLower)
		cSeparator = This.Separator()
		if StzRight(cResult, 1) != cSeparator
			cResult += cSeparator
		ok

		cResult = StzReplace(cResult, "//", "/")
		return cResult

		def NormaliseFilePathXT(cName)
			return This.NormalizeFilePathXT(cName)
	
	def NormalizeFolderPath(cName)

	    cName = This.NormalizeFilePath(cName)
	    cSeparator = This.Separator()

		# (Removed a forced leading separator here -- it turned Windows
		# drive paths "D:/x" into "/D:/x". Only the trailing separator
		# matters for folder semantics.)
	    if StzRight(cName, 1) != cSeparator
	        cName += cSeparator
	    ok

		cName = StzReplace(cName, "//", "/")
	    return cName
	
		def NormaliseFolderPath(cName)
			return This.NormalizeFolderPath(cName)
	
	def NormalizeFolderPathXT(cName)
	    cName = This.NormalizeFilePathXT(cName)
	    cSeparator = This.Separator()

	    if StzRight(cName, 1) != cSeparator
	        cName += cSeparator
	    ok

		cName = StzReplace(cName, "//", "/")
	    return cName

		def NormaliseFolderPathXT(cName)
			return This.NormalizeFolderPathXT(cName)
	
	#==========================#
	#  DETAILED PATH ANALYSIS  #
	#==========================#
	
	def PathType(cPath)
	
		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	
	    # Returns the type of path: "file", "folder", or "none"
	
	    if This.IsFile(cPath)
	        return "file"
	
	    but This.IsFolder(cPath)
	        return "folder"
	
	    else
	        return "none"
	    ok
	
	
	def PathInfo(cPath)
	
		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	    
	    cNormalizedPath = This.NormalizePath(cPath)
	
		# Ensire the provided path exists in the folder
	
		if NOT This.Exists(cNormalizedPath)
			raise("Incorrect path!")
		ok
	
		# Doing the job
	
	    cType = This.PathType(cNormalizedPath)
	    bExists = (cType != "none")
	    
	    aInfo = [
	        :path, cPath,
	        :normalized_path, cNormalizedPath,
	        :exists, bExists,
	        :type, cType,
	        :is_file, (cType = "file"),
	        :is_folder, (cType = "folder"),
	        :is_relative, (StzLeft(cPath, 1) != This.Separator() AND StzFind(cPath, ":/") = 0 AND StzFind(cPath, ":\\") = 0),
	        :parent_folder, This.ParentFolder(cPath)
	    ]
	    
	    return aInfo
	
	def ParentFolder(cPath)
		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok
	
	    cNormalizedPath = This.NormalizePath(cPath)
	
		# Ensire the provided path exists in the folder
	
		if NOT This.Exists(cNormalizedPath)
			raise("Incorrect path!")
		ok
	
	    # Find last separator
	
	    nLastSep = 0
	    for i = StzLen(cNormalizedPath) to 1 step -1
	        if cNormalizedPath[i] = This.Separator()
	            nLastSep = i
	            exit
	        ok
	    next

	    if nLastSep > 0
	        return StzLeft(cNormalizedPath, nLastSep - 1)
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
	    
		nLen = len(acPaths)

		for i = 1 to nLen
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
	    
		nLen = len(acPaths)

		for i = 1 to nLen
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
	    
		nLen = len(acPaths)

		for i = 1 to nLen
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
	    
	    acResult = []
	
		nLen = len(acPaths)

		for i = 1 to nLen
	        if This.Exists(acPaths[i])
	            acResult + cPath
	        ok
	    next
	    
	    return acResult
	
	
	def MissingPathsAmong(acPaths)
	
	    # Returns only the paths that don't exist from the given list
	
		if CheckParams()
			if NOT ( isList(acPaths) and IsListOfstrings(acPaths) )
				StzRaise("Incorrect param type! cFolderName must be a list of strings.")
			ok
		ok
	    
	    acMissing = []
		nLen = len(acPaths)

		for i = 1 to nLen
	        if NOT This.Exists(acPaths[i])
	            acMissing + cPath
	        ok
	    next
	    
	    return acMissing

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

		aInfo = [
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

		return aInfo

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
		aResult = []

		nLen = len(_aList_)

		for i = 1 to nLen
			if _aList_[i][2] = 0
				aResult + (@cCurrentPath + This.Separator() + _aList_[i][1])
			end
		next

		return aResult

	def FoldersXT()

		_aList_ = @dir(@cCurrentPath)
		aResult = []

		nLen = len(_aList_)

		for i = 1 to nLen
			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				aResult + (@cCurrentPath + This.Separator() + _aList_[i][1] + This.Separator())
			end
		next

		return aResult

	def Files()

		_aList_ = @dir(@cCurrentPath)
		aResult = []

		nLen = len(_aList_)

		for i = 1 to nLen
			if _aList_[i][2] = 0
				aResult + (This.Separator() + _aList_[i][1])
			end
		next

		return aResult

	def Folders()

		_aList_ = @dir(@cCurrentPath)
		aResult = []

		nLen = len(_aList_)

		for i = 1 to nLen
			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _alist_[i][1] != ".."
				aResult + (This.Separator() + _aList_[i][1] + This.Separator())
			end
		next

		return aResult

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

	def CountFolder(cFolderName)
		return len(This.FindFolder(cFolderName))

	#---

	def Contains(cName)
		if CheckParams()
			if NOT ( isString(cName) and trim(cName) != "" )
				StzRaise("Incorrect param type! cName must be a non-empty string.")
			ok
		ok

		aFiles = This.Files()
		aFolders = This.Folders()

		return (StzFind(aFiles, cName) > 0) or (StzFind(aFolders, cName) > 0)


		def Has(cName)
			return This.Contains(cName)

		def ContainsFileOrFolder(cName)
			return This.Contains(cName)

		def ContainsFolderOrFile(cName)
			return This.Contains(cName)


	def ContainsFile(cFileName)
		if CheckParams()
			if NOT ( isString(cFileName) and trim(cFileName) != "" )
				StzRaise("Incorrect param type! cFileName must be a non-empty string.")
			ok
		ok

		cFile = This.NormalizeFilePath(cFileName)
		aFiles = This.Files()

		return StzFind(aFiles, cFileName) > 0

	def ContainsFolder(cFolderName)
		if CheckParams()
			if NOT ( isString(cFolderName) and trim(cFolderName) != "" )
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok
		ok

		cFolderName = NormalizeFolderPath(cFolderName)
		aFolders = This.Folders()

		return StzFind(aFolders, cFolderName) > 0

		def ContainsDir(cFolderName)
			return This.ContainsFolder(cFolderName)

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

	def FilesIn(cPath)

		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		if NOT This.Exists(cPath)
			StzRaise("Incorrect path!")
		ok

		acList = @dir(cPath)
		nLen = len(acList)

		acResult = []

		for i = 1 to nLen
			if This.IsFile(acList[i])
				acResult + acList[i]
			ok
		next

		return acResult


	def FoldersIn(cPath)

		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		if NOT This.Exists(cPath)
			StzRaise("Incorrect path!")
		ok

		acList = @dir(cPath)
		nLen = len(acList)

		acResult = []

		for i = 1 to nLen
			if This.IsFolder(acList[i])
				acResult + acList[i]
			ok
		next

		return acResult

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

	def DeepCountFolder(cFolderName)
		return len(This.DeepFindFolder(cFolderName))

	def DeepFiles() # With simplified paths

		aResult = []
		aToProcess = [@cCurrentPath]
		cBasePath = @cCurrentPath
		
		while len(aToProcess) > 0

			cCurrentPath = aToProcess[1]
			del(aToProcess, 1)
			
			_aList_ = @dir(cCurrentPath)

			nLen = len(_aList_)
	
			for i = 1 to nLen

				if _aList_[i][2] = 0  # It's a file

					cFullPath = cCurrentPath + This.Separator() + _aList_[i][1]
					cRelativePath = StzMid(cFullPath, StzLen(cBasePath) + 1, StzLen(cFullPath) - StzLen(cBasePath))

					if StzLeft(cRelativePath, 1) != This.Separator()
						cRelativePath = This.Separator() + cRelativePath
					end

					aResult + cRelativePath

				but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # It's a directory
					aToProcess + (cCurrentPath + This.Separator() + _aList_[i][1])
				end

			next

		end
		
		return aResult
	
	def DeepFolders() # With simplified paths

		aResult = []
		aToProcess = [@cCurrentPath]
		cBasePath = @cCurrentPath
		
		while len(aToProcess) > 0

			cCurrentPath = aToProcess[1]
			del(aToProcess, 1)
			
			_aList_ = @dir(cCurrentPath)

			nLen = len(_aList_)
	
			for i = 1 to nLen

				if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # It's a directory

					cFullPath = cCurrentPath + This.Separator() + _aList_[i][1]
					cRelativePath = StzMid(cFullPath, StzLen(cBasePath) + 1, StzLen(cFullPath) - StzLen(cBasePath))

					if StzLeft(cRelativePath, 1) != This.Separator()
						cRelativePath = This.Separator() + cRelativePath
					end

					aResult + (cRelativePath + This.Separator())
					aToProcess + (cCurrentPath + This.Separator() + _aList_[i][1])
				end

			next
		end
		
		return aResult

	def DeepFilesXT() # With complete long paths

		aResult = []
		aToProcess = [@cCurrentPath]
		
		while len(aToProcess) > 0

			cCurrentPath = aToProcess[1]
			del(aToProcess, 1)
			
			_aList_ = @dir(cCurrentPath)

			nLen = len(_aList_)
	
			for i = 1 to nLen

				if _aList_[i][2] = 0  # It's a file
					aResult + (cCurrentPath + This.Separator() + _aList_[i][1])

				but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # It's a directory
					aToProcess + (cCurrentPath + This.Separator() + _aList_[i][1])
				end

			next

		end

		return aResult


	def DeepFoldersXT() # With complete long paths

		aResult = []
		aToProcess = [@cCurrentPath]
		
		while len(aToProcess) > 0

			cCurrentPath = aToProcess[1]
			del(aToProcess, 1)
			
			_aList_ = @dir(cCurrentPath)

			nLen = len(_aList_)
	
			for i = 1 to nLen

				if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # It's a directory

					cFullPath = cCurrentPath + This.Separator() + _aList_[i][1] + This.Separator()
					aResult + cFullPath
					aToProcess + (cCurrentPath + This.Separator() + _aList_[i][1])

				end

			next
		end
		
		return aResult

	def DeepCount()
		return This.DeepCountFiles() + This.DeepCountFolders()

		def DeepCountFilesAndFolders()
			return This.DeepCount()

		def DeepCountFoldersAndFiles()
			return This.DeepCount()

	def DeepCountFileIn(cFileName, cPath)
		return len(This.FindFileIn(cFileName, cPath))

	def DeepCountTheseFiles(acFilesNames)
		return len(This.DeepCountTheseFilesIn(acFilesNames, cPath))

	def DeepCountTheseFilesIn(acFilesNames, cPath)
		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok

			if NOT ( isList(acFilesNames) and @IsListOfStrings(acFilesNames) )
				StzRaise("Incorrect param type! acFilesNames must be a list of strings.")
			ok
		ok

		return len(This.SearchTheseFilesIn(acFilesNames, cPath))

	def DeepCountFilesIn(cPath)
		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		nCount = 0
		aList = @dir(cPath)
		nLen = len(aList)

		for i = 1 to nLen

			if aList[i][2] = 0
				nCount++
			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				nCount += This.DeepCountFilesIn(cPath + This.Separator() + aList[i][1])
			end

		next

		return nCount


	def DeepCountFilesWithProgress(cPath, nCurrentLevel, nMaxLevel)
		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		if nCurrentLevel > nMaxLevel
			return 0
		ok

		nCount = 0
		aList = @dir(cPath)
		nLen = len(aList)

		for i = 1 to nLen

			if aList[i][2] = 0
				nCount++

			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				nCount += This.DeepCountFilesWithProgress(cPath + This.Separator() + aList[i][1], nCurrentLevel + 1, nMaxLevel)
			ok

		next

		return nCount


	def DeepCountFolderIn(cFolderName, cPath)
		if CheckParams()
			if NOT ( isString(cFolderName) and trim(cFolderName) != "" )
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok

			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		return len(This.FindFolderIn(cFolderName, cPath))

	def DeepCountTheseFoldersIn(acFoldersNames, cPath)
		return len(This.SearchTheseFoldersIn(acFoldersNames, cPath))

	def DeepCountFoldersIn(cPath)
		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		nCount = 0
		aList = @dir(cPath)
		nLen = len(aList)

		for i = 1 to nLen

			if aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				nCount++
				nCount += This.DeepCountFoldersIn(cPath + This.Separator() + aList[i][1])
			end

		next

		return nCount


	def DeepContains(cName)

		if This.DeepContainsFileIn(cName, This.Path()) or This.DeepContainsFolderIn(cName, This.Path())
			return TRUE
		else
			return FALSE
		ok

		def DeepContainsFileOrFolder(cName)
			return This.DeepContains(cName)

		def DeepContainsFolderOrFile(cName)
			return This.DeepContains(cName)

	def DeepContainsIn(cName, cPath)

		if This.DeepContainsFileIn(cName, cPath) or This.DeepContainsFolderIn(cName,cPath)
			return TRUE
		else
			return FALSE
		ok

		def DeepContainsFileOrFolderIn(cName, cPath)
			return This.DeepContainsIn(cName, cPath)

		def DeepContainsFolderOrFileIn(cName, cPath)
			return This.DeepContainsIn(cName, cPath)

	def DeepContainsFile(cFileName)
		return This.DeepContainsFileIn(cFileName, This.Path())

	def DeepContainsFileIn(cFileName, cPath)

		if CheckParams()
			if NOT ( isString(cFileName) and trim(cFileName) != "" )
				StzRaise("Incorrect param type! cFileName must be a non-empty string.")
			ok

			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		aList = @dir(cPath)
		nLen = len(aList)

		for i = 1 to nLen

			if aList[i][2] = 0 and aList[i][1] = cFileName
				return TRUE

			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."

				if This.DeepContainsFileIn(cFileName, cPath + This.Separator() + aList[i][1])
					return TRUE
				end

			end

		next

		return FALSE

	def DeepContainsTheseFiles(acFilesNames)
		return This.DeepContainsTheseFilesIn(acFilesNames, This.Path())

	def DeepContainsTheseFilesIn(acFilesNames, cPath)

		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok

			if NOT ( isList(acFilesNames) and @IsListOfStrings(acFilesNames) )
				StzRaise("Incorrect param type! acFilesNames must be a list of strings.")
			ok
		ok

		nLen = len(acFilesNames)
		bResult = TRUE

		for i = 1 to nLen

			if NOT This.DeepContainsFileIn(acFilesNames[i], cPath)
				bResult = FALSE
				exit
			ok

		next

		return bResult

	def DeepContainsOneOfTheseFiles(acFilesNames)
		return This.DeepContainsTheseFilesIn(acFilesNames, This.Path())


	def DeepContainsOneOfTheseFilesIn(acFilesNames, cPath)

		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok

			if NOT ( isList(acFilesNames) and @IsListOfStrings(acFilesNames) )
				StzRaise("Incorrect param type! acFilesNames must be a list of strings.")
			ok
		ok

		nLen = len(acFilesNames)
		bResult = FALSE

		for i = 1 to nLen

			if This.DeepContainsFileIn(acFilesNames[i], cPath)
				bResult = TRUE
				exit
			ok

		next

		return bResult

	def DeepContainsFolder(cFolderName)
		return This.DeepContainsFolderIn(cFolderName, This.Path())


	def DeepContainsFolderIn(cFolderName, cPath)

		if CheckParams()
			if NOT ( isString(cFolderName) and trim(cFolderName) != "" )
				StzRaise("Incorrect param type! cFolderNAme must be a non-empty string.")
			ok

			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		aList = @dir(cPath)
		nLen = len(aList)

		for i = 1 to nLen

			if aList[i][2] = 1 and aList[i][1] = cFolderName
				return TRUE

			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."

				if This.DeepContainsFolderIn(cFolderName, cPath + This.Separator() + aList[i][1])
					return TRUE
				end

			end

		next

		return FALSE

	def DeepContainsTheseFolders(acFoldersNames)
		return This.DeepContainsTheseFoldersIn(acFoldersNames, This.Path())

	def DeepContainsTheseFoldersIn(acFoldersNames, cPath)

		if CheckParams()
			if NOT ( isString(cPath) and trim(cPath) != "" )
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok

			if NOT ( isList(acFoldersNames) and @IsListOfStrings(acFoldersNames) )
				StzRaise("Incorrect param type! acFoldersNames must be a list of strings.")
			ok
		ok

		nLen = len(acFoldersNames)
		bResult = TRUE

		for i = 1 to nLen

			if NOT This.DeepContainsFolderIn(acFoldersNames[i], cPath)
				bResult = FALSE
				exit
			ok

		next

		return bResult

	def DeepContainsOneOfTheseFolders(acFoldersNames)
		return This.DeepContainsTheseFoldersIn(acFoldersNames, This.Path())

	def DeepContainsOneOfTheseFoldersIn(acFoldersNames, cPath)

		if CheckParams()
			if NOT ( isList(acFoldersNames) and @IsListOfStrings(acFoldersNames) )
				StzRaise("Incorrect param type! acFoldersNames must be a list of strings.")
			ok
		ok

		nLen = len(acFoldersNames)
		bResult = FALSE

		for i = 1 to nLen

			if This.DeepContainsFolderIn(acFoldersNames[i], cPath)
				bResult = TRUE
				exit
			ok

		next

		return bResult

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

	def GoTo(cPath)
		if CheckParams()
			if NOT (isString(cPath) and cPath != "")
				StzRaise("Incorrect param type! cPath must be a non-empty string.")
			ok
		ok

		cFullPath = This.NormalizeFolderPathXT(cPath)
		if This.IsOutside(cFullPath)
			StzRaise("Can't navigate outside the folder!")
		ok

		# Save current path to history before changing
		@acPathHistory + @cCurrentPath
		
		@cCurrentPath = cFullPath
		
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
		
		cPreviousPath = @acPathHistory[len(@acPathHistory)]
		del(@acPathHistory, len(@acPathHistory))  # Remove last item
		
		@cCurrentPath = cPreviousPath
		
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
		cRelPath = This.RelativePathFromHome()
		if cRelPath = "."
			return 0
		end
		
		return len(split(cRelPath, This.Separator()))

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

	def CreateFolder(pcPath)

	    if CheckParams()
	        if NOT (isString(pcPath) and pcPath != "")
	            raise("Incorrect param type! pcPath must be a non-empty string.")
	        ok
	    end
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(pcPath)
	        pcPath = This.CurrentPath() + pcPath
	    ok
	
	    cPath = This.NormalizeFolderPath(pcPath)
	
	    if NOT This.IsInside(cPath)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    # Create the folder first
	    StzEngineDirCreatePath(cPath)
	
	    # Then navigate there (intelligent navigation)
	    if not this.IsBatchMode()
	        This.GoTo(cPath)
	    ok
	
	    return new stzFolder(cPath)

		def FolderCreate()
			return This.CreateFolder()

	# Create several sub-folders under this folder in one call; returns a
	# list of stzFolder handles (so callers can chain .Name() etc.).
	# Creates siblings directly (no GoTo side effect that CreateFolder has).
	def CreateFolders(paNames)
		if NOT isList(paNames)
			raise("Incorrect param type! paNames must be a list of folder names.")
		ok
		aResult = []
		cBase = This.Path()
		nLen = len(paNames)
		for i = 1 to nLen
			cName = "" + paNames[i]
			# Pass the RAW joined path to the constructor (its _CleanPath
			# handles separators correctly). Do NOT pre-run it through
			# NormalizeFolderPath -- that helper lowercases and strips the
			# last char, yielding an invalid path like "/d:/.../doc/".
			aResult + new stzFolder(cBase + "/" + cName)
		next
		return aResult

		def MakeFolders(paNames)
			return This.CreateFolders(paNames)

		def CreateSubFolders(paNames)
			return This.CreateFolders(paNames)


	def DeleteFolder(cFolder)

	    if CheckParams()
	        if NOT (isString(cFolder) and cFolder != "")
	            StzRaise("Incorrect param type! cFolder must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(cFolder)
	        cFolder = This.CurrentPath() + cFolder
	    ok
	
	    cFolder = This.NormalizeFolderPathXT(cFolder)
	
	    if This.IsPathOutside(cFolder)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(cFolder)
	        raise("Folder does not exist.")
	    ok
	
	    # Delete the folder first
	    bResult = RemoveFolderRecursive(cFolder)
	    
	    # Then navigate to parent folder (intelligent navigation)
	    if not this.IsBatchMode()
	        cParentDir = This.GetDirectoryPath(cFolder)
	        This.GoTo(cParentDir)
	    ok
	
	    return bResult

		def FolderDelete(cFolder)
			return This.DeleteFolder(cFolder)

		def RemoveFolder(cFolder)
			return This.DeleteFolder(cFolder)

		def FolderRemove(cFolder)
			return This.DeleteFolder(cFolder)

	def DeleteAll()

	    try

	        # Delete all files

	        acFiles = This.FilesXT()
			nLen = len(acFiles)

	        for i = 1 to nLen
	            if NOT StzEngineFileDelete(acFiles[i])
	                raise("Could not remove file '" + acFiles[i] + "'")
	            ok
	        next

	        acFolders = This.FoldersXT()
			nLen = len(acFolders)

	        for i = 1 to nLen
	            if NOT RemoveFolderRecursive(acFolders[i])
	                raise("Could not remove subfolder '" + acFolders[i] + "'")
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
	    nDeleted = 0
	    acFiles = This.FilesXT()
		nLen = len(acFiles)

	    for i = 1 to nLen
	        if StzEngineFileDelete(acFiles[i])
	            nDeleted++
	        ok
	    next

	    # Stay in current folder - just cleaned it up
	    return nDeleted
	
		def RemoveFiles()
			return This.Erase()


	def DeepErase()
	    nDeleted = 0
	    acFiles = This.DeepFilesXT()
	    nLen = len(acFiles)

	    for i = 1 to nLen
	        if StzEngineFileDelete(acFiles[i])
	            nDeleted++
	        ok
	    next
	    
	    # Stay in current folder - performed deep operation from here
	    return nDeleted
	
	def DeepDeleteFile(cFileName)
	    if CheckParams()
	        if NOT (isString(cFileName) and cFileName != "")
	            raise("Incorrect param type! cFileName must be a non-empty string.")
	        ok
	    end
	
	    if NOT This.IsInside(cFileName)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    acFilePaths = This.DeepFindFile(cFileName)
		nLen = len(acFilePaths)
	    nDeleted = 0
	
	    for i = 1 to nLen
	        if StzEngineFileDelete(acFilePaths[i])
	            nDeleted++
	        ok
	    next
	
		# Stay in current folder - deep operations initiated from here
	    return nDeleted > 0
	

		def FileDeepDelete(cFileName)
			return This.DeepDeleteFile(cFileName)

		def DeepRemoveFile(cFileName)
			return This.DeepDeleteFile(cFileName)

		def FileDeepRemove(cFileName)
			return This.DeepDeleteFile(cFileName)


	def DeepDeleteFolder(cFolderName)

		if CheckParams()
			if NOT ( isString(cFolderName) and trim(cFolderName) != "" )  # Fixed: cFolderNAme typo
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok
		ok

	    acFolderPaths = This.DeepFindFolder(cFolderName)
		nLen = len(acFolderPaths)

	    # Sort by depth (deepest first) using Ring's sort
	    aSortedPaths = []
	    for i = 1 to nLen
	        nDepth = len(@split(acFolderPaths[i], This.Separator()))
	        aSortedPaths + [nDepth, acFolderPaths[i]]
	    next

	    # Sort by depth descending (deepest first)
	    aSortedPaths = @sorton(aSortedPaths, 1)
	    aSortedPaths = reverse(aSortedPaths)
		nLen = len(aSortedPaths)

	    # Delete folders
		bResult = TRUE

		for i = 1 to nLen
	        cFolderPath = aSortedPaths[i][2]

	        if dirExists(cFolderPath)
	            if NOT RemoveFolderRecursive(cFolderPath)
	                bResult = FALSE
					exit
	            ok
	        ok
	    next
		
		# Stay in current folder - deep operation initiated from here
	    return bResult

		def DeepRemoveFolder(cFolderName)
			return This.DeepDeleteFolder(cFolderName)
	
		def FolderDeepDelete(cFolderName)
			return This.DeepDeleteFile(cFolderName)

		def FolderDeepRemove(cFolderName)
			return This.DeepRemoveFile(cFolderName)

	#===================#
	#  File Operations  #
	#===================#

	def FileRead(cFile)

	    if CheckParams()
	        if NOT ( isString(cFile) and trim(cFile) != "" )
	            StzRaise("Incorrect param type! cFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(cFile)
	        cFile = This.CurrentPath() + cFile
	    ok
	
	    cFile = This.NormaliseFilePathXT(cFile)
	
	    if This.IsPathOutside(cFile)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(cFile)
	        raise("cFile does not exist in the folder.")
	    ok
	
	    # Read the file first
	    cResult = @FileRead(cFile)
	    
	    # Then navigate to its folder (intelligent navigation)
	    if not this.IsBatchMode()
	        cFileDir = This.GetDirectoryPath(cFile)
	        This.GoTo(cFileDir)
	    ok
	
	    return cResult


		def ReadFile(cFile)
			return This.FileRead(cFile)

	#--

	def FileAppend(cFile, cAdditionalText)

		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't append this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			cFileDir = This.GetDirectoryPath(cFile)
			This.GoTo(cFileDir)
		ok

		return @FileAppend(cFile, cAdditionalText)

		def AppendFile(cFile, cAdditionalText)
			return FileAppend(cFile, cAdditionalText)


		def FileAppendQ(cFile, cAdditionalText)

			if CheckParams()
				if NOT ( isString(cFile) and trim(cFile) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok

			cFile = This.NormaliseFilePathXT(cFile)
	
			if NOT This.Inside(cFile)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.Exists(cFile)
				raise("Can't append this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder (intelligent navigation)
			if not this.IsBatchMode()
				cFileDir = This.GetDirectoryPath(cFile)
				This.GoTo(cFileDir)
			ok

			return @FileAppendQ(cFile, cAdditionalText)


			def AppendFileQ(cFile, cAdditionalText)
				return FileAppendQ(cFile, cAdditionalText)

	#--

	def FileCreate(cFile) #TODO // Provide also the content FileCreate(cFile, cContent)

	    if CheckParams()
	        if NOT ( isString(cFile) and trim(cFile) != "" )
	            StzRaise("Incorrect param type! cFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position

	    if not _IsAbsolutePath(cFile)
	        cFile = This.CurrentPath() + cFile
	    ok
	
	    cFile = This.NormaliseFilePathXT(cFile)
	
	    if This.IsPathOutside(cFile)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if This.Exists(cFile)
	        raise("Can't create this file! cFile already exists in the folder.")
	    ok
	
	    # Create the file first
	    bResult = @FileCreate(cFile)
	    
	    # Then navigate to its folder (intelligent navigation)
	    if not this.IsBatchMode()
	        cFileDir = This.GetDirectoryPath(cFile)
	        This.GoTo(cFileDir)
	    ok
	
	    return bResult

		def CreateFile(cFile)
			return This.FileCreate(cFile)


		def FileCreateQ(cFile)
	
		    if CheckParams()
		        if NOT ( isString(cFile) and trim(cFile) != "" )
		            StzRaise("Incorrect param type! cFile must be a non-empty string.")
		        ok
		    ok
		
		    # Resolve relative paths against current position
	
		    if not _IsAbsolutePath(cFile)
		        cFile = This.CurrentPath() + cFile
		    ok
		
		    cFile = This.NormaliseFilePathXT(cFile)
		
		    if This.IsPathOutside(cFile)
		        raise("Can't navigate outside the folder!")
		    ok
		
		    if This.Exists(cFile)
		        raise("Can't create this file! cFile already exists in the folder.")
		    ok
		
		    # Create the file first
		    oResult = @FileCreateQ(cFile)
		    
		    # Then navigate to its folder (intelligent navigation)
		    if not this.IsBatchMode()
		        cFileDir = This.GetDirectoryPath(cFile)
		        This.GoTo(cFileDir)
		    ok
		
		    return oResult

			def CreateFileQ(cFile)
				return This.FileCreateQ(cFile)

	
	def FilesCreate(acFileNames) #TODO // [ [ cFileName1, cFileContent1 ], [ ]... ]

		if CheckParams()
			if NOT (isList(acFileNames) and @IsListOfStrings(acFileNames))
				StzRaise("Incorrect param type! acFileNames must be a list of strings.")
			ok
		ok

		nLen = len(acFileNames)
		acCreated = []
		acFailed = []
		cLastSuccessfulDir = ""

		for i = 1 to nLen
			try
				This.CreateFile(acFileNames[i])
				acCreated + cFileName
				# Track last successful creation for intelligent navigation
				cLastSuccessfulDir = This.GetDirectoryPath(acFileNames[i])
			catch
				acFailed + [acFileNames[i], CatchError()]
			end
		next

		# Navigate to last successful creation folder (intelligent navigation)
		if not this.IsBatchMode() and cLastSuccessfulDir != ""
			This.GoTo(cLastSuccessfulDir)
		ok

		return [
			:Created = acCreated,
			:Failed = acFailed
		]


		def CreateFiles(acFileNames)
			return This.FilesCreate(acFileNames)


	def FileOverwrite(cFile, cNewContent)

		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't overwrite this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			cFileDir = This.GetDirectoryPath(cFile)
			This.GoTo(cFileDir)
		ok

		return @FileOverwrite(cFile, cNewContent)

	
		def OverwriteFile(cFile, cNewContent)
			return This.FileOverwrite(cFile, cNewContent)

		def FileOverwriteQ(cFile, cNewContent)

			if CheckParams()
				if NOT ( isString(cFile) and trim(cFile) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok
	
			cFile = This.NormaliseFilePathXT(cFile)
	
			if NOT This.Inside(cFile)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.Exists(cFile)
				raise("Can't overwrite this file! cFile does not exist in the folder.")
			ok
	
			# Navigate to file's folder (intelligent navigation)
			if not this.IsBatchMode()
				cFileDir = This.GetDirectoryPath(cFile)
				This.GoTo(cFileDir)
			ok
	
			return @FileOverwriteQ(cFile, cNewContent)

			def OverwriteFileQ(cFile, cNewContent)
				return This.FileOverwriteQ(cFile, cNewContent)
	
	
	def FileErase(cFile)

		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't erase this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder before erasing (intelligent navigation)
		if not this.IsBatchMode()
			cFileDir = This.GetDirectoryPath(cFile)
			This.GoTo(cFileDir)
		ok

		return @FileErase(cFile)

		def EraseFile(cFile)
			return This.FileErase(cFile)


		def FileEraseQ(cFile)

			if CheckParams()
				if NOT ( isString(cFile) and trim(cFile) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok

			cFile = This.NormaliseFilePathXT(cFile)
	
			if NOT This.Inside(cFile)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.Exists(cFile)
				raise("Can't erase this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder before erasing (intelligent navigation)
			if not this.IsBatchMode()
				cFileDir = This.GetDirectoryPath(cFile)
				This.GoTo(cFileDir)
			ok

			return @FileEraseQ(cFile)  # Fixed: was This.cFile


			def EraseFileQ(cFile)
				return This.FileEraseQ(cFile)


	def FileSafeErase(cFile)

		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't safe-erase this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder before safe-erasing (intelligent navigation)
		if not this.IsBatchMode()
			cFileDir = This.GetDirectoryPath(cFile)
			This.GoTo(cFileDir)
		ok

		return @FileSafeErase(cFile)


		def FileSafeEraseQ(cFile)

			if CheckParams()
				if NOT ( isString(cFile) and trim(cFile) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok

			cFile = This.NormaliseFilePathXT(cFile)
	
			if NOT This.Inside(cFile)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.Exists(cFile)
				raise("Can't safe-erase this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder before safe-erasing (intelligent navigation)
			if not this.IsBatchMode()
				cFileDir = This.GetDirectoryPath(cFile)
				This.GoTo(cFileDir)
			ok

			return @FileSafeEraseQ(cFile)
	
		def SafeEraseFile(cFile)
			return This.FileSafeErase(cFile)

		def SafeEraseFileQ(cFile)
			return This.FileSafeEraseQ(cFile)


	def FileRemove(cFile)

	    if CheckParams()
	        if NOT ( isString(cFile) and trim(cFile) != "" )
	            StzRaise("Incorrect param type! cFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(cFile)
	        cFile = This.CurrentPath() + cFile
	    ok
	
	    cFile = This.NormaliseFilePathXT(cFile)
	
	    if This.IsPathOutside(cFile)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(cFile)
	        raise("cFile does not exist in the folder.")
	    ok
	
	    # Delete the file first
	    bResult = @FileRemove(cFile)
	    
	    # Then navigate to file's containing folder (intelligent navigation)
	    if not this.IsBatchMode()
	        cFileDir = This.GetDirectoryPath(cFile)
	        This.GoTo(cFileDir)
	    ok
	
	    return bResult

		def FileDelete(cFile)
			return This.FileRemove(cFile)

		def RemoveFile(cFile)
			return This.FileRemove(cFile)

		def DeleteFile(cFile)
			return This.FileRemove(cFile)


	def FileBackup(cFile)

	    if CheckParams()
	        if NOT ( isString(cFile) and trim(cFile) != "" )
	            StzRaise("Incorrect param type! cFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(cFile)
	        cFile = This.CurrentPath() + cFile
	    ok
	
	    cFile = This.NormaliseFilePathXT(cFile)
	
	    if This.IsPathOutside(cFile)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(cFile)
	        raise("cFile does not exist in the folder.")
	    ok
	
	    # Create backup first
	    cBackupFile = cFile + ".bak"
	    bResult = @FileBackup(cFile, cBackupFile)
	    
	    # Then navigate to file's folder (intelligent navigation)
	    if not this.IsBatchMode()
	        cFileDir = This.GetDirectoryPath(cFile)
	        This.GoTo(cFileDir)
	    ok
	
	    return bResult


		def BackupFile(cFile)
			return This.FileBackup(cFile)


	def FileSafeOverwrite(cFile, cNewContent)

		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't safe-overwirte this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			cFileDir = This.GetDirectoryPath(cFile)
			This.GoTo(cFileDir)
		ok

		return @FileSafeOverwrite(cFile, cNewContent)

		def SafeOverwriteFile(cFile, cNewContent)
			return This.FileSafeOverwrite(cFile, cNewContent)


	def FileModify(cFile, cOldContent, cNewContent)

		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't modify this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			cFileDir = This.GetDirectoryPath(cFile)
			This.GoTo(cFileDir)
		ok

		return @FileModify(cFile, cOldContent, cNewContent)

		def ModifyFile(cFile, cOldContent, cNewContent)
			return This.FileModify(cFile, cOldContent, cNewContent)


	def FileCopy(cSourceFile, cDestFile)
	    if CheckParams()
	        if NOT ( isString(cSourceFile) and trim(cSourceFile) != "" )
	            StzRaise("Incorrect param type! cSourceFile must be a non-empty string.")
	        ok
	        if NOT ( isString(cDestFile) and trim(cDestFile) != "" )
	            StzRaise("Incorrect param type! cDestFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(cSourceFile)
	        cSourceFile = This.CurrentPath() + cSourceFile
	    ok
	    if not _IsAbsolutePath(cDestFile)
	        cDestFile = This.CurrentPath() + cDestFile
	    ok
	
	    cSourceFile = This.NormaliseFilePathXT(cSourceFile)
	    cDestFile = This.NormaliseFilePathXT(cDestFile)
	
	    if This.IsPathOutside(cSourceFile) or This.IsPathOutside(cDestFile)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(cSourceFile)
	        raise("Source file does not exist in the folder.")
	    ok
	
	    # Copy the file first
	    bResult = @FileCopy(cSourceFile, cDestFile)
	    
	    # Then navigate to destination folder (intelligent navigation)
	    if not this.IsBatchMode()
	        cDestDir = This.GetDirectoryPath(cDestFile)
	        This.GoTo(cDestDir)
	    ok
	
	    return bResult


		def CopyFile(cSource, cDest)
			return this.FileCopy(cSource, cDest)


	def FileMove(cSourceFile, cDestFile)
	    if CheckParams()
	        if NOT ( isString(cSourceFile) and trim(cSourceFile) != "" )
	            StzRaise("Incorrect param type! cSourceFile must be a non-empty string.")
	        ok
	        if NOT ( isString(cDestFile) and trim(cDestFile) != "" )
	            StzRaise("Incorrect param type! cDestFile must be a non-empty string.")
	        ok
	    ok
	
	    # Resolve relative paths against current position
	    if not _IsAbsolutePath(cSourceFile)
	        cSourceFile = This.CurrentPath() + cSourceFile
	    ok
	    if not _IsAbsolutePath(cDestFile)
	        cDestFile = This.CurrentPath() + cDestFile
	    ok
	
	    cSourceFile = This.NormaliseFilePathXT(cSourceFile)
	    cDestFile = This.NormaliseFilePathXT(cDestFile)
	
	    if This.IsPathOutside(cSourceFile) or This.IsPathOutside(cDestFile)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    if not This.Exists(cSourceFile)
	        raise("Source file does not exist in the folder.")
	    ok
	
	    # Move the file first
	    bResult = @FileMove(cSourceFile, cDestFile)
	    
	    # Then navigate to destination folder (intelligent navigation)
	    if not this.IsBatchMode()
	        cDestDir = This.GetDirectoryPath(cDestFile)
	        This.GoTo(cDestDir)
	    ok
	
	    return bResult


		def MoveFile(cSource, cDestination)
			return this.FileMove(cSource, cDestination)

	#--

	def FileSize(cFile)
		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't get size of this file! cFile does not exist in the folder.")  # Fixed: was "modify"
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			cFileDir = This.GetDirectoryPath(cFile)
			This.GoTo(cFileDir)
		ok

		return @FileSize(cFile)

		def FileSizeInBytes(cFile)
			return this.FileSize(cFile)

	def FileInfo(cFile)

		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't read this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			cFileDir = This.GetDirectoryPath(cFile)
			This.GoTo(cFileDir)
		ok

		return @FileInfo(cFile)

		def FileInfoQ(cFile)
			cFile = This.NormaliseFilePathXT(cFile)
	
			if NOT This.Inside(cFile)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.Exists(cFile)
				raise("Can't read this file! cFile does not exist in the folder.")
			ok

			# Navigate to file's folder (intelligent navigation)
			if not this.IsBatchMode()
				cFileDir = This.GetDirectoryPath(cFile)
				This.GoTo(cFileDir)
			ok

			return @FileInfoQ(cFile)

	def FileInfoXT(cFile)

		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't read this file! cFile does not exist in the folder.")
		ok

		# Navigate to file's folder (intelligent navigation)
		if not this.IsBatchMode()
			cFileDir = This.GetDirectoryPath(cFile)
			This.GoTo(cFileDir)
		ok

		return @FileInfoXT(cFile)

	#======================#
	#  Finding Operations  #
	#======================#

	def FindFiles(cPattern)

		if CheckParams()
			if NOT ( isString(cPattern) and trim(cPattern) != "" )
				StzRaise("Incorrect param type! cPattern must be a non-empty string.")
			ok
		ok

		cPattern = This.NormalizeFilePath(cPattern)
		acFiles = This.Files()
		nLen = len(acFiles)

		acResult = []

		if StzFind(cPattern, "*") > 0
			cPattern = StzReplace(cPattern, "*", "")

			for i = 1 to nLen
				if StzFind(StzLower(acFiles[i]), StzLower(cPattern)) > 0
					acResult + acFiles[i]
				ok
			next

		else

			for i = 1 to nLen
				if StzLower(acFiles[i]) = StzLower(cPattern)
					acResult + acFiles[i]
				ok
			next

		ok

		return acResult

		def FindFile(cFileName)
			return This.FindFiles(cFileName)

		def FindThisFile(cFileName)
			return This.FindFiles(cFileName)

	def FindFolders(cPattern)

		if CheckParams()
			if NOT ( isString(cPattern) and trim(cPattern) != "" )
				StzRaise("Incorrect param type! cPattern must be a non-empty string.")
			ok
		ok

		cPattern = This.NormalizeFilePath(cPattern)
		acFolders = This.Folders()
		nLen = len(acFolders)

		acResult = []

		if StzFind(cPattern, "*") > 0

			cPattern = StzReplace(cPattern, "*", "")

			for i = 1 to nLen
				if StzFind(StzLower(acFolders[i]), StzLower(cPattern)) > 0
					acResult + acFolders[i]
				ok
			next

		else

			for i = 1 to nLen
				if StzLower(acFolders[i]) = StzLower(cPattern)
					acResult + acFolders[i]
				ok
			next
		ok

		return acResult

		def FindFolder(cFolderName)
			return This.FindFolders(cFolderName)

		def FindThisFolder(cFolderName)
			return This.FindFolders(cFolderName)


	def FindFilesByExtension(cExt)
		if CheckParams()
			if NOT ( isString(cExt) and trim(cExt) != "" )
				StzRaise("Incorrect param type! cExt must be a non-empty string.")
			ok
		ok

		if StzLeft(cExt, 1) != "."
			cExt = "." + cExt
		ok
		acFound = []
		acAllFiles = This.Files()
		nLen = len(acAllFiles)

		for i = 1 to nLen
			if StzRight(StzLower(acAllFiles[i]), StzLen(cExt)) = StzLower(cExt)
				acFound + acAllFiles[i]
			ok
		next
		return acFound

		def FilesByExtension(cExt)
			return This.FindFilesByExtension(cExt)

	def FindTheseFiles(acFilesNames)
		if NOT isList(acFilesNames)
			StzRaise("Incorrect param type! acFilesNames must be a list.")
		ok
		acFound = []
		nLen = len(acFilesNames)

		for i = 1 to nLen
			acFileResults = This.FindFiles(acFilesNames[i])
			nLenR = len(acFileResult)

			for j = 1 to nLenR
				if find(acFound, acFileResults[j]) = 0
					acFound + acFileResults[j]
				ok
			next
		next

		return acFound

	def FindTheseFolders(acFoldersNames)
		if NOT isList(acFoldersNames)
			StzRaise("Incorrect param type! acFoldersNames must be a list.")
		ok
		acFound = []
		nLen = len(acFoldersNames)

		for i = 1 to nLen

			acFolderResults = This.FindFolders(acFoldersNames[i])
			nLenR = len(acFolderResults)

			for j = 1 to nLenR
				if find(acFound, acFolderResults[j]) = 0
					acFound + acFolderResults[j]
				ok
			next

		next

		return acFound


	def Find(cPattern)
		acFiles = This.FindFiles(cPattern)
		acFolders = This.FindFolders(cPattern)
		return acFiles + acFolders

	def DeepFindFiles(cPattern)
		if NOT isString(cPattern)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok
		acFound = []
		acAllDirs = This.DeepFolders()
		bWildcard = (StzFind(cPattern, "*") > 0)

		if bWildcard
			cPattern = StzReplace(cPattern, "*", "")
		ok

		nLen = len(acAllDirs)

		for i = 1 to nLen

			aEntries = @dir(acAllDirs[i])
			nLenE = len(aEntries)

			for j = 1 to nLenE

				if _aEntry_[2] = 0

					if bWildcard
						if StzFind(StzLower(aEntries[j][1]), StzLower(cPattern)) > 0
							acFound + (acAllDirs[i] + This.Separator() + aEntries[j][1])
						ok

					else
						if StzLower(aEntries[j][1]) = StzLower(cPattern)
							acFound + (acAllDirs[i] + This.Separator() + aEntries[j][1])
						ok

					ok
				ok

			next
		next

		return acFound

		def DeepFindFile(cFileName)
			return This.DeepFindFiles(cFileName)

		def DeepFindThisFile(cFileName)
			return This.DeepFindFiles(cFileName)

	def DeepFindFolders(cPattern)

		if NOT isString(cPattern)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok

		acFound = []
		acAllDirs = This.DeepFolders()
		bWildcard = (StzFind(cPattern, "*") > 0)

		if bWildcard
			cPattern = StzReplace(cPattern, "*", "")
		ok

		nLen = len(acAllDirs)

		for i = 1 to nLen

			aEntries = @dir(acAllDirs[i])
			nLenE = len(aEntries)

			for j = 1 to nLenE

				if aEntries[j][2] = 1 and aEntries[j][1] != "." and aEntries[j][1] != ".."

					if bWildcard
						if StzFind(StzLower(aEntries[j][1]), StzLower(cPattern)) > 0
							acFound + (acAllDirs[i] + This.Separator() + aEntries[j][1])
						ok

					else
						if StzLower(aEntries[j][1]) = StzLower(cPattern)
							acFound + (acAllDirs[i] + This.Separator() + aEntries[j][1])
						ok

					ok
				ok

			next
		next

		return acFound

		def DeepFindFolder(cFolderName)
			return This.DeepFindFolders(cFolderName)

		def DeepFindThisFolder(cFolderName)
			return This.DeepFindFolders(cFolderName)

	def DeepFindTheseFiles(acFilesNames)
		if NOT isList(acFilesNames)
			StzRaise("Incorrect param type! acFilesNames must be a list.")
		ok
		acFound = []
		nLen = len(acFilesNames)

		for i = 1 to nLen

			acFileResults = This.DeepFindFiles(acFilesNames[i])
			nLenR = len(acFileResults)

			for j = 1 to nLenR
				if StzFind(acFound, acFileResults[j]) = 0
					acFound + acFileResults[j]
				ok
			next
		next

		return acFound

	def DeepFindTheseFolders(acFoldersNames)
		if NOT isList(acFoldersNames)
			StzRaise("Incorrect param type! acFoldersNames must be a list.")
		ok
		acFound = []
		nLen = len(acFoldersNames)

		for i = 1 to nLen

			acFolderResults = This.DeepFindFolders(acFoldersNames[i])
			nLenR = len(acFolderResults)

			for j = 1 to nLenR
				if StzFind(acFound, acFolderResults[j]) = 0
					acFound + acFolderResults[j]
				ok
			next

		next

		return acFound


	def DeepFind(cPattern)
		acFiles = This.DeepFindFiles(cPattern)
		acFolders = This.DeepFindFolders(cPattern)
		return acFiles + acFolders

		def DeepFindFileOrFolder(cPattern)
			return This.DeepFind(cPattern)

		def DeepFindThisFileOrFolder(cPattern)
			return This.DeepFind(cPattern)

	#=====================#
	#  Search Operations  #
	#=====================#

	def SearchInFiles(cContent)
		if NOT isString(cContent)
			StzRaise("Incorrect param type! cContent must be a string.")
		ok
		return This.SearchInTheseFiles(This.Files(), cContent)


	def SearchInFile(cFile, cContent)
		if NOT isString(cFile) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok
		acLineNumbers = []
		cFullPath = @cCurrentPath + This.Separator() + cFile
		if fexists(cFullPath)
			cFileContent = read(cFullPath)
			acLines = @split(cFileContent, NL)

			nLen = len(acLines)
			for i = 1 to nLen
				if StzFind(StzLower(acLines[i]), StzLower(cContent)) > 0
					acLineNumbers + i
				ok
			next

		ok
		return acLineNumbers

		def SearchInThisFile(cFile, cContent)
			return This.SearchInFile(cFile, cContent)

	def SearchInTheseFiles(acFiles, cContent)
		if NOT isList(acFiles) or NOT isString(cContent)
			StzRaise("Incorrect param types! acFiles must be a list and cContent must be a string.")
		ok
		acResults = []
		nLen = len(acFiles)

		for i = 1 to nLen
			acLineNumbers = This.SearchInFile(acFiles[i], cContent)
			if len(acLineNumbers) > 0
				acResults + [acFiles[i], acLineNumbers]
			ok
		next

		return acResults

	def SearchInFolders(cContent)
		if NOT isString(cContent)
			StzRaise("Incorrect param type! cContent must be a string.")
		ok
		return This.SearchInTheseFolders(This.Folders(), cContent)

	def SearchInFolder(cFolder, cContent)

		if NOT isString(cFolder) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		acResults = []
		cFolderPath = @cCurrentPath + This.Separator() + cFolder

		if isdir(cFolderPath)

			aEntries = @dir(cFolderPath)
			nLen = len(aEntries)

			for i = 1 to nLen

				if aEntries[i][2] = 0

					cFilePath = cFolderPath + This.Separator() + aEntries[i][1]

					if fexists(cFilePath)

						cFileContent = read(cFilePath)
						acLines = @split(cFileContent, NL)
						nLenL = len(acLines)
						acLineNumbers = []

						for i = 1 to nLenL
							if StzFind(StzLower(acLines[i]), StzLower(cContent)) > 0
								acLineNumbers + i
							ok
						next

						if len(acLineNumbers) > 0
							acResults + [aEntries[i][1], acLineNumbers]
						ok
					ok
				ok
			next
		ok
		return acResults

		def SearchInThisFolder(cFolder, cContent)
			return This.SearchInFolder(cFolder, cContent)

	def SearchInTheseFolders(acFolders, cContent)

		if NOT isList(acFolders) or NOT isString(cContent)
			StzRaise("Incorrect param types! acFolders must be a list and cContent must be a string.")
		ok

		acResults = []
		nLen = len(acFolders)

		for i = 1 to nLen

			acFolderResults = This.SearchInFolder(acFolders[i], cContent)
			nLenR = len(acFoldersResults)

			for j = 1 to nLenR
				acResults + acFolderResults[j]
			next

		next

		return acResults


	def DeepSearchInFiles(cContent)
		if NOT isString(cContent)
			StzRaise("Incorrect param type! cContent must be a string.")
		ok

		acAllDirs = [ This.RootXT() ]
		acDeepFolders = This.DeepFoldersXT()
		nLen = len(acDeepFolders)

		for i = 1 to nLen
			acAllDirs + acDeepFolders[i]
		next

		acResult = []

		for i = 1 to nLen

			aEntries = @dir(acAllDirs[i])
			nLenE = len(aEntries)

			for j = 1 to nLenE

				if aEntries[j][2] = 0

					cFilePath = StzReplace( acAllDirs[i] + This.Separator() + aEntries[j][1], "//", "/")

					if fexists(cFilePath)

						cFileContent = read(cFilePath)
						acLines = @split(cFileContent, NL)
						nLenL = len(acLines)
						acLineNumbers = []

						for i = 1 to nLenL
							if StzFind(StzLower(acLines[i]), StzLower(cContent)) > 0
								acLineNumbers + i
							ok
						next

						if len(acLineNumbers) > 0
							acResult + [cFilePath, acLineNumbers]
						ok
					ok
				ok
			next
		next

		return acResult


	def DeepSearchInFile(cFile, cContent)

		if NOT isString(cFile) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		acResults = []
		acFilePaths = This.DeepFindFiles(cFile)
		nLen = len(acFilePaths)

		for i = 1 to nLen

			if fexists(acFilePaths[i])

				cFileContent = read(acFilePaths[i])
				acLines = @split(cFileContent, NL)
				nLenL = len(acLines)
				acLineNumbers = []
				
				for i = 1 to nLenL
					if StzFind(StzLower(acLines[i]), StzLower(cContent)) > 0
						acLineNumbers + i
					ok
				next

				if len(acLineNumbers) > 0
					acResults + [acFilePaths[i], acLineNumbers]
				ok

			ok

		next

		return acResults


	def DeepSearchInTheseFiles(acFiles, cContent)

		if NOT isList(acFiles) or NOT isString(cContent)
			StzRaise("Incorrect param types! acFiles must be a list and cContent must be string.")
		ok

		acResults = []

		nLen = len(acFiles)
		for i = 1 to nLen

			acFileResults = This.DeepSearchInFile(acFiles[i], cContent)
			nLenR = len(acFileResuls)

			for j = 1 to nLenR
				acResults + acFileResults[j]
			next

		next

		return acResults


	def DeepSearchInFolder(cFolder, cContent)
		if NOT isString(cFolder) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		acResults = []
		acFolderPaths = This.DeepFindFolders(cFolder)
		nLen = len(acFolderPaths)

		for i = 1 to nLen

			if isdir(acFolderPaths[i])
				aEntries = @dir(acFolderPaths[i])
				nLenE = len(aEntries)

				for j = 1 to nLenE

					if aEntries[j][2] = 0

						cFilePath = acFolderPaths[i] + This.Separator() + aEntries[j][1]

						if fexists(acFolderPaths[i])
							cFileContent = read(acFolderPaths[i])
							acLines = @split(cFileContent, NL)
							nLenL = len(acLines)
							acLineNumbers = []

							for i = 1 to nLenL
								if StzFind(StzLower(acLines[i]), StzLower(cContent)) > 0
									acLineNumbers + i
								ok
							next

							if len(acLineNumbers) > 0
								acResults + [acFolderPaths[i], acLineNumbers]
							ok
						ok
					ok

				next
			ok

		next

		return acResults


	def DeepSearchInFolders(acFolders, cContent)
		if NOT isList(acFolders) or NOT isString(cContent)
			StzRaise("Incorrect param types! acFolders must be a list and cContent must be string.")
		ok
		acResults = []
		nLen = len(acFolders)

		for i = 1 to nLen

			acFolderResults = This.DeepSearchInFolder(acFolders[i], cContent)
			nLenR = len(acFolderResults)

			for j = 1 to nLenR
				acResults + acFolderResults[j]
			next

		next

		return acResults

	#-------------#
	#  MATCHINGS  #
	#-------------#

	def Matches(cPattern, cName)

		if cPattern = "*"
			return 1
		ok

		cRegexPattern = cPattern
		cRegexPattern = StzReplace(cRegexPattern, "*", ".*")
		cRegexPattern = StzReplace(cRegexPattern, "?", ".")

		if StzLeft(cPattern, 1) = "*" and StzRight(cPattern, 1) = "*"
			cMiddle = StzMid(cPattern, 2, StzLen(cPattern) - 2)
			return StzFind(cName, cMiddle) > 0

		but StzLeft(cPattern, 1) = "*"
			cSuffix = StzMid(cPattern, 2, StzLen(cPattern) - 1)
			return StzRight(cName, StzLen(cSuffix)) = cSuffix

		but StzRight(cPattern, 1) = "*"
			cPrefix = StzLeft(cPattern, StzLen(cPattern) - 1)
			return StzLeft(cName, StzLen(cPrefix)) = cPrefix

		else
			return cName = cPattern
		ok


	def GetFoldersContainingFileMatches(cPath, cPattern)

		aAllPaths = This.CollectFoldersWithFileMatches(cPath, cPattern, aAllPaths)
		nLen = len(aAllPaths)

		aFolderNames = []

		for i = 1 to nLen

			acPathParts = This.GetPathHierarchy(aAllPaths[i])
			nLenP = len(acPathParts)

			for j = 1 to nLenP
				if StzFind(aFolderNames, acPathParts[j]) = 0
					aFolderNames + acPathParts[j]
				end
			next

		next

		return aFolderNames


	def CountFileMatches(cPath, cPattern)
		nCount = 0
		aList = @dir(cPath)
		nLen = len(aList)

		for i = 1 to nLen
			if aList[i][2] = 0
				if This.Matches(cPattern, aList[i][1])
					nCount++
				end
			end
		next

		return nCount

	def CountFolderMatches(cPath, cPattern)
		nCount = 0
		aList = @dir(cPath)
		nLen = len(aList)
		for i = 1 to nLen
			if aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				if This.Matches(cPattern, aList[i][1])
					nCount++
				end
			end
		next
		return nCount

	#======================#
	# Content Modification #
	#======================#

	def ModifyInFile(cFile, cContent, cNewContent)
		if NOT isString(cFile) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok
		cFullPath = @cCurrentPath + This.Separator() + cFile
		if fexists(cFullPath)
			cFileContent = read(cFullPath)
			cModifiedContent = StzReplace(cFileContent, cContent, cNewContent)
			write(cFullPath, cModifiedContent)
			return TRUE
		ok
		return FALSE

	def ModifyInFiles(acFiles, cContent, cNewContent)

		if NOT isList(acFiles) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFiles must be a list, cContent and cNewContent must be strings.")
		ok

		nModified = 0

		nLen = len(acFiles)
		for i = 1 to nLen
			if This.ModifyInFile(acFiles[i], cContent, cNewContent)
				nModified++
			ok
		next

		return nModified


	def ModifyInFolder(cFolder, cContent, cNewContent)

		if NOT isString(cFolder) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok

		nModified = 0
		cFolderPath = @cCurrentPath + This.Separator() + cFolder

		if isdir(cFolderPath)
			aEntries = @dir(cFolderPath)
			nLen = len(aEntries)

			for i = 1 to nLen
	
				if aEntries[i][2] = 0
					cFilePath = cFolderPath + This.Separator() + aEntries[i][1]

					if fexists(cFilePath)
						cFileContent = read(cFilePath)
						cModifiedContent = StzReplace(cFileContent, cContent, cNewContent)
						write(cFilePath, cModifiedContent)
						nModified++
					ok

				ok

			next
		ok

		return nModified


	def ModifyInFolders(acFolders, cContent, cNewContent)

		if NOT isList(acFolders) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFolders must be a list, cContent and cNewContent must be strings.")
		ok

		nModified = 0
		nLen = len(acFolders)

		for i = 1 to nLen
			nModified += This.ModifyInFolder(acFolders[i], cContent, cNewContent)
		next

		return nModified


	def ModifyInRoot(cContent, cNewContent)

		if NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		nModified = 0
		acFiles = This.Files()
		nLen = len(acFiles)

		for i = 1 to nLen
			if This.ModifyInFile(acFiles[i], cContent, cNewContent)
				nModified++
			ok
		next
		return nModified


	def DeepModifyInFile(cFile, cContent, cNewContent)

		if NOT isString(cFile) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok

		nModified = 0
		acFilePaths = This.DeepFindFile(cFile)
		nLen = len(acFilePaths)

		for i = 1 to nLen
	
			if fexists(acFilePaths[i])

				cFileContent = read(acFilePaths[i])
				cModifiedContent = StzReplace(cFileContent, cContent, cNewContent)

				write(acFilePaths[i], cModifiedContent)
				nModified++

			ok

		next

		return nModified


	def DeepModifyInFiles(acFiles, cContent, cNewContent)

		if NOT isList(acFiles) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFiles must be a list, cContent and cNewContent must be strings.")
		ok

		nModified = 0
		nLen = len(acFiles)

		for i = 1 to nLen
			nModified += This.DeepModifyInFile(acFiles[i], cContent, cNewContent)
		next

		return nModified


	def DeepModifyInFolder(cFolder, cContent, cNewContent)

		if NOT isString(cFolder) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok

		nModified = 0
		acFolderPaths = This.DeepFindFolder(cFolder)
		nLen = len(acFolderPaths)

		for i = 1 to nLen

			if isdir(acFolderPaths[i])

				aEntries = @dir(cFolderPath)
				nLenE = len(aEntries)

				for j = 1 to nLenE
					if aEntries[j][2] = 0
						cFilePath = cFolderPath + This.Separator() + aEntries[j][1]

						if fexists(cFilePath)

							cFileContent = read(cFilePath)
							cModifiedContent = StzReplace(cFileContent, cContent, cNewContent)

							write(cFilePath, cModifiedContent)
							nModified++

						ok
					ok

				next

			ok

		next

		return nModified


	def DeepModifyInFolders(acFolders, cContent, cNewContent)

		if NOT isList(acFolders) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFolders must be a list, cContent and cNewContent must be strings.")
		ok

		nModified = 0
		nLen = len(acFolders)

		for i = 1 to nlen
			nModified += This.DeepModifyInFolder(acFolders[i], cContent, cNewContent)
		next

		return nModified

	def DeepModifyInRoot(cContent, cNewContent)

		if NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok

		nModified = 0
		acAllDirs = This.DeepFolders()
		nLen = len(acAllDirs)

		for i = 1 to nLen
			aEntries = @dir(acAllDirs[i])
			nLenE = len(aEntries)

			for j = 1 to nLenE

				if aEntries[j][2] = 0

					cFilePath = acAllDirs[i] + This.Separator() + aEntries[j][1]

					if fexists(cFilePath)

						cFileContent = read(cFilePath)
						cModifiedContent = StzReplace(cFileContent, cContent, cNewContent)

						write(cFilePath, cModifiedContent)
						nModified++

					ok
				ok
			next

		next

		return nModified

	#=================#
	#  Visualization  #
	#=================#

	def VizSearch(cPattern)
		nFileMatches = This.CountFileMatches(This.Path(), cPattern)
		nFolderMatches = This.CountFolderMatches(This.Path(), cPattern)
		nTotalMatches = nFileMatches + nFolderMatches
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + " " + nTotalMatches + " matches for '" + cPattern + "')" + nl
		cResult += This.GenerateVizTreeString(This.Path(), '', 1, cPattern, "both", 0, 1)
		return cResult

		def VizSearchFiles(cPattern)
			return This.VizFindFiles(cPattern)

	def VizFindFiles(cPattern)
		nTotalMatches = This.CountFileMatches(This.Path(), cPattern)
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + " " + nTotalMatches + " file matches for '" + cPattern + "')" + nl
		cResult += This.GenerateVizTreeString(This.Path(), "", 1, cPattern, "files", 0, 1)
		return cResult

		def VizSearchFolders(cPattern)
			return This.VizFindFolders(cPattern)

	def VizFindFolders(cPattern)
		nTotalMatches = This.CountFolderMatches(This.Path(), cPattern)
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRootXT] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + " " + nTotalMatches + " folder matches for '" + cPattern + "')" + nl
		cResult += This.GenerateVizTreeString(This.Path(), "", 1, cPattern, "folders", 0, 1)
		return cResult

		def VizSearchDirs(cPattern)
			return This.VizFindFolders(cPattern)

	def VizDeepSearch(cPattern)
		nTotalFileMatches = This.CountFileMatchesRecursive(This.Path(), cPattern)
		nTotalFolderMatches = This.CountFolderMatchesRecursive(This.Path(), cPattern)
		nTotalMatches = nTotalFileMatches + nTotalFolderMatches
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + "" + nTotalMatches + " matches for '" + cPattern + "')" + nl
		cResult += This.GenerateVizTreeString(This.Path(), '', 1, cPattern, "both", 0, This.MaxDisplayLevel())
		return cResult

		def VizDeepFindFilesAndFolders(cPattern)
			return This.VizDeepSearch(cPattern)

	def VizDeepFindFiles(cPattern)
		nTotalMatches = This.CountFileMatchesRecursive(This.Path(), cPattern)
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + "" + nTotalMatches + " file matches for '" + cPattern + "')" + nl
		This.CollapseAll()
		acFoldersWithMatches = This.GetFoldersContainingFileMatches(This.Path(), cPattern)
		if len(acFoldersWithMatches) > 0
			This.ExpandFolders(acFoldersWithMatches)
		end
		cResult += This.GenerateVizTreeString(This.Path(), "", 1, cPattern, "files", 0, This.MaxDisplayLevel())
		return cResult

	def VizDeepFindFolders(cPattern)
		nTotalMatches = This.CountFolderMatchesRecursive(This.Path(), cPattern)
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRootXT] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + + "  " + nTotalMatches + " folder matches for '" + cPattern + "')" + nl
		cResult += This.GenerateVizTreeString(This.Path(), "", 1, cPattern, "folders", 0, This.MaxDisplayLevel())
		return cResult

		def VizDeepSearchDirs(cPattern)
			return This.VizDeepFindFolders(cPattern)

	def ToString()
		cFolderName = This.Name()
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + NL

		cResult += This.GenerateVizTreeString(
			This.Path(), '', 1,
			'', "", 0, This.MaxDisplayLevel()
		)

		return cResult

	def Show()
		? This.ToString()

	def ToStringXT()
		cStatPattern = This.DisplayStatPattern()
		if cStatPattern = ""
			cStatPattern = cStatPattern = "@count"
		ok

		cFolderName = This.Name()
		cStats = trim(This.FormatStats(This, cStatPattern))

		cResult = @acDisplayChars[:FolderRootXT] + " " + cFolderName + " " + cStats + NL

		cResult += This.GenerateVizTreeString(
			This.Path(), '', 1, cStatPattern,
			"showxt", 0, This.MaxDisplayLevel()
		)

		return cResult

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

	def ExpandFolder(cFolder)
		This.ExpandFolders([cFolder])

		def ExpandThisFolder(cFolder)
			This.ExpandFolders([cFolder])

		def ExpandThis(cFolder)
			This.ExpandFolders([cFolders])

	def ExpandFolders(acFolders)
	    if CheckParams()
	        if Not (isList(acFolders) and IsListOfStrings(acFolders))
	            StzRaise("Incorrect param type! acFolders must be a list of strings.")
	        ok
	    ok
	
		nLen = len(acFolders)

		for i = 1 to nLen
			cPath = This.NormalizeFolderPath(acFolders[i])
			if This.IsDeepFolder(cPath)
				@acDeepExpandFolders + cPath
			else
				@acExpandFolders + cPath
			ok
		next

	    @bCollapseAll = 0
	
		def ExpandTheseFolders(acFolders)
			This.ExpandFolders(acFolders)

		def ExpandThese(acFolders)
			This.ExpandTheseFolders(acFolders)

	#--

	def DeepExpandAll()
		@bExpand = 0
		@bDeepExpandAll = 1
		@acDeepExpandFolders = []

		@bCollapseAll = 0
		@acCollapseFolders = []

		def DeepExpand()
			This.DeepExpandAll()

	def DeepExpandFolder(cFolder)
		This.DeepExpandFolders([cFolder])
	
		def DeepExpandThisFolder(cFolder)
			This.DeepExpandFolders([cFolder])
	
		def DeepExpandThis(cFolder)
			This.DeepExpandFolders([cFolder])
	
	def DeepExpandFolders(acFolders)
		if isString(acFolders)
			@acDeepExpandFolders = [acFolders]
		else
			@acDeepExpandFolders = acFolders
		end
		@bCollapseAll = 0
		@bDeepExpandAll = 0

		def DeepExpandTheseFolders(acFolders)
			This.DeepExpandFolders(acFolders)
	
		def DeepExpandThese(acFolders)
			This.DeepExpandTheseFolders(acFolders)

	#--

	def CollapseAll()
		@bCollapseAll = 1
		@bExpand = 0
		@bDeepExpandAll = 0

		@acExpandFolders = []
		@acDeepExpandFolders = []

		def Collapse()
			This.CollapseAll()

	def CollapseFolders(acFolders)
		if isString(acFolders)
			@acCollapseFolders = [acFolders]
		else
			@acCollapseFolders = acFolders
		end
		@bExpand = 0
		@bDeepExpandAll = 0

		def CollapseTheseFolders(acFolders)
			This.CollapseFolders(acFolders)

		def CollapseThese(acFolders)
			This.CollapseFolders(acFolders)

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

	def SetDisplayStat(cPattern)
		if NOT isString(cPattern)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok

		if NOT This.IsStatPattern(cPattern)
			StzRaise("Incorrect start pattern!")
		ok

		@cDisplayStatPattern = cPattern

		def SetDisplayStartPattern(cPattern)
			This.SetDisplayStat(cPattern)

	def StatKeywords()
		return @acStatKeywords

	def IsStatPattern(cPattern)
		if Not isString(cPattern)
			return 0
		ok

		cPattern = StzLower(cpattern)
		acKeywords = This.StatKeywords()
		nLen = len(acKeywords)
		bResult = 0

		for i = 1 to nLen
			if StzFind(cPattern, acKeywords[i]) > 0
				bResult = 1
				exit
			ok
		next
		return bResult

	def DisplayOrder()
		return @cDisplayOrder

	def SetDisplayOrder(cOrder)
		if NOT isString(cOrder)
			StzRaise("Incorrect param type! cOrder must be a string.")
		ok
		acValidOrders = ["systemorder", "filefirstascending", "filefirstdescending", "folderfirstascending", "folderfirstdescending"]
		if NOT StzFind(acValidOrders, StzLower(cOrder))
			StzRaise("Invalid display order! Must be one of: " + @@(acValidOrders))
		ok
		@cDisplayOrder = StzLower(cOrder)

	#==========================#
	#  Checking Path Security  #
	#==========================#
	#TODO // Enhance this section

	def IsSecurePath(cPath)
		# Check for null bytes (path injection attempt)
		if StzFind(cPath, StzChar(0)) > 0
			return true
		ok

		# Check for other control characters that could be used for injection
		for i = 1 to 31
			if StzFind(cPath, StzChar(i)) > 0
				return false
			ok
		next
		
		return true

	def HasNoPathInjection(cPath)
		return This.IsSecurePath(cPath)

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

	def GetParentDirectory(cPath)
		nPos = 0
		nLen = StzLen(cPath)
		for i = nLen to 1 step -1
			if cPath[i] = This.Separator()
				nPos = i
				exit
			ok
		next
		if nPos > 1
			return StzLeft(cPath, nPos - 1)
		else
			return This.Path()
		ok

	def GetPathHierarchy(cPath)
		acParts = []
		cRelativePath = StzReplace(cPath, This.Path() + This.Separator(), "")
		if cRelativePath = cPath
			return []
		end
		acSegments = @split(cRelativePath, This.Separator())
		nLen = len(acSegments)

		for i = 1 to nLen
			if acSegments[i] != ""
				acParts + acSegments[i]
			end
		next

		return acParts

	def CollectFoldersWithFileMatches(cPath, cPattern, aFoldersWithMatches)

		_aList_ = @dir(cPath)
		bHasFileMatches = 0
		nLen = len(_aList_)

		for i = 1 to nLen
			if _aList_[i][2] = 0
				if This.Matches(cPattern, _aList_[i][1])
					bHasFileMatches = 1
					exit
				end
			end
		next

		if bHasFileMatches
			aFoldersWithMatches + cPath
		end

		for i = 1 to nLen
			if _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				This.CollectFoldersWithFileMatches(cPath + This.Separator() + _aList_[i][1], cPattern, aFoldersWithMatches)
			end
		next


		def GetFolderNameFromPath(cPath)
			if cPath = This.Path()
				return ""
			end
			nPos = max([StzFind(cPath, This.Separator()), StzFind(cPath, "\")])
			if nPos > 0
				return StzRight(cPath, StzLen(cPath) - nPos)
			end
			return cPath


	#================================#
	#  PRIVATE KITCHEN OF THE CLASS  #
	#================================#

	PRIVATE

	def SortItemsByDisplayOrder(acFiles, acFolders, cPath)

		aItems = []

		switch @cDisplayOrder

			case "systemorder"

				aRingEntries = dir(cPath)
				nLen = len(aRingEntries)
				for i = 1 to nLen
					cEntryName = aRingEntries[i][1]
					if cEntryName != "." and cEntryName != ".."
						cFullPath = cPath + This.Separator() + cEntryName
						if isdir(cFullPath)
							aItems + [cEntryName, "folder"]
						else
							aItems + [cEntryName, "file"]
						end
					end
				next

			case "filefirstascending"

				acFilesSorted = sort(acFiles)
				acFoldersSorted = sort(acFolders)
				nLen = len(acFilesSorted)

				for i = 1 to nLen
					aItems + [acFilesSorted[i], "file"]
				next

				nLen = len(acFoldersSorted)
				for i = 1 to nLen
					aItems + [acFoldersSorted[i], "folder"]
				next

			case "filefirstdescending"

				acFilesSorted = reverse(sort(acFiles))
				acFoldersSorted = reverse(sort(acFolders))

				nLen = len(acFilesSorted)
				for i = 1 to nLen
					aItems + [acFilesSorted[i], "file"]
				next

				nLen = len(acFoldersSorted)
				for i = 1 to nLen
					aItems + [acFoldersSorted[i], "folder"]
				next

			case "folderfirstascending"

				acFilesSorted = sort(acFiles)
				acFoldersSorted = sort(acFolders)

				nLen = len(acFoldersSorted)
				for i = 1 to nLen
					aItems + [acFoldersSorted[i], "folder"]
				next

				nLen = len(acFilesSorted)
				for i = 1 to nLen
					aItems + [acFilesSorted[i], "file"]
				next

			case "folderfirstdescending"

				acFilesSorted = reverse(sort(acFiles))
				acFoldersSorted = reverse(sort(acFolders))

				nLen = len(acFoldersSorted)
				for i = 1 to nLen
					aItems + [acFoldersSorted[i], "folder"]
				next

				nLen = len(acFilesSorted)
				for  i = 1 to nLen
					aItems + [acFilesSorted[i], "file"]
				next

		end

		return aItems

	def OrderFilesFirst(acFiles, acFolders)

		aResult = []

		nLen = len(acFiles)
		for i = 1 to nLen
			aResult + [:name = acFiles[i], :type = "file"]
		next

		nLen = len(acFolders)
		for i = 1 to nLen
			aResult + [:name = acFolders[i], :type = "folder"]
		next

		return aResult


	def OrderFoldersFirst(acFiles, acFolders)

		aResult = []

		nLen = len(acFolders)
		for i = 1 to nLen
			aResult + [:name = acFolders[i], :type = "folder"]
		next

		nLen = len(acFiles)
		for i = 1 to nLen
			aResult + [:name = acFiles[i], :type = "file"]
		next

		return aResult


	def GetPhysicalOrder(cPath)

		_aList_ = @dir(cPath)
		nLen = len(_aList_)

		aResult = []

		for i = 1 to nLen

			if _aList_[i][2] = 0
				aResult + [:name = _aEntry_[1], :type = "file"]

			but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."
				aResult + [:name = _aList_[i][1], :type = "folder"]

			end

		next

		return aResult


	def FormatStats(oFolder, cStatPattern)
		# Handle @count pattern specifically

		if cStatPattern = "@count"

			nTotal = oFolder.CountFiles() + oFolder.CountFolders()

			if nTotal > 0
				return "(" + nTotal + ")"
			else
				return ""
			end

		ok
		
		# Handle custom patterns by replacing tokens

		cResult = StzLower(cStatPattern)
		
		# Replace pattern tokens with actual values

		nThisLevelFiles = oFolder.CountFiles()
		nThisLevelFolders = oFolder.CountFolders()
		nAllSubLevelFiles = oFolder.DeepCountFiles()
		nAllSubLevelFolders = oFolder.DeepCountFolders()
	
		if StzFind(cResult, "@countfiles")
			cResult = StzReplace(cResult, "@countfiles", "" + nThisLevelFiles)
		ok

		if StzFind(cResult, "@deepcountfiles")
			cResult = StzReplace(cResult, "@deepcountfiles", "" + nAllSubLevelFiles)
		ok

		if StzFind(cResult, "@countfolders")
			cResult = StzReplace(cResult, "@countfolders", "" + nThisLevelFolders)
		ok

		if StzFind(cResult, "@deepcountfolders")
			cResult = StzReplace(cResult, "@deepcountfolders", "" + nAllSubLevelFolders)
		ok

		# If tokens were replaced (custom pattern), handle zero filtering

		if cResult != cStatPattern

			# Split by comma and filter out zero values

			aTokens = @split(cResult, ",")
			nLen = len(aTokens)
			acFiltered = []

			for i = 1 to nLen

				cToken = trim(aTokens[i])

				# Check if this token contains "0 files" or "0 folders"

				if not (StzFind(cToken, "0 files") or StzFind(cToken, "0 folders"))
					acFiltered + cToken
				ok
			next
			
			# Rebuild the result

			cResult = "("
			nLenF = len(acFiltered)

			for i = 1 to nLenF
				cResult += acFiltered[i]
				if i < nLenF
					cResult += ", "
				ok
			next

			cResult += ")"

		else

			# If no tokens were replaced, fall back to original logic
			# Get direct counts for this folder level

			nThisLevelFiles = oFolder.CountFiles()
			nThisLevelFolders = oFolder.CountFolders()
			
			# Get recursive counts for all sublevels

			nAllSubLevelFiles = oFolder.DeepCountFiles()
			nAllSubLevelFolders = oFolder.DeepCountFolders()
	
			cResult = "("
			
			# Files display logic

			if nThisLevelFiles > 0

				if nAllSubLevelFiles > nThisLevelFiles
					cResult += ''+ nThisLevelFiles + ":" + nAllSubLevelFiles + " files"
				else
					cResult += ''+ nThisLevelFiles + " files"
				end
				
				# Add comma if we also have folders

				if nThisLevelFolders > 0 or nAllSubLevelFolders > nThisLevelFolders
					cResult += ", "
				end
			end
			
			# Folders display logic

			if nThisLevelFolders > 0
				if nAllSubLevelFolders > nThisLevelFolders
					cResult += ''+ nThisLevelFolders + ":" + nAllSubLevelFolders + " folders"
				else
					cResult += ''+ nThisLevelFolders + " folders"
				end
			end
			
			cResult += ")"
			
			# If no files or folders, return empty string to avoid showing "()"

			if nThisLevelFiles = 0 and nThisLevelFolders = 0 and nAllSubLevelFiles = 0 and nAllSubLevelFolders = 0
				return ""
			end
		end
		
		return cResult


	def GetFolderStats(cFolderName)

		# Get stats for a specific subfolder

		cFolderPath = @cCurrentPath + This.Separator() + cFolderName
		
		if @cDisplayStatPattern = "@count"

			# Simple count for default pattern

			try
				_aList_ = @dir(cFolderPath)
			catch
				return ""
			end
			
			nCount = 0
			nLen = len(_aList_)

			for i = 1 to nLen
				if _aList_[i][1] != "." and _aList_[i][1] != ".."
					nCount++
				end
			next
			
			if nCount > 0
				return "" + nCount
			else
				return ""
			ok

		else
			# Use pattern for custom display

			return This.FormatStatsForFolder(cFolderName, @cDisplayStatPattern)
		ok


	def FormatStatsForFolder(cFolderName, cPattern)

		# Format stats for a specific folder

		cResult = cPattern
		cFolderPath = @cCurrentPath + This.Separator() + cFolderName
		
		# Get actual counts for this folder

		nFiles = This.CountFilesIn(cFolderPath)
		nFolders = This.CountFoldersIn(cFolderPath)
		nDeepFiles = This.DeepCountFilesIn(cFolderPath)
		nDeepFolders = This.DeepCountFoldersIn(cFolderPath)
		
		# Replace patterns

		if StzFind(cResult, "@countfiles") or StzFind(cResult, "@countfiles")
			cResult = StzReplace(cResult, "@countfiles", "" + nFiles)
			cResult = StzReplace(cResult, "@countfiles", "" + nFiles)
		ok

		if StzFind(cResult, "@deepcountfiles")
			cResult = StzReplace(cResult, "@deepcountfiles", "" + nDeepFiles)
		ok

		if StzFind(cResult, "@countfolders") or StzFind(cResult, "@countfolders")
			cResult = StzReplace(cResult, "@countfolders", "" + nFolders)
			cResult = StzReplace(cResult, "@countfolders", "" + nFolders)
		ok

		if StzFind(cResult, "@deepcountfolders")
			cResult = StzReplace(cResult, "@deepcountfolders", "" + nDeepFolders)
		ok
		
		return cResult

	def CountFileMatchesRecursive(cPath, cPattern)

		nCount = 0
		try
			aList = @dir(cPath)
		catch
			return 0
		end

		nLen = len(aList)

		for i = 1 to nLen

			if aList[i][2] = 0
				if This.Matches(cPattern, aList[i][1])
					nCount++
				end

			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				nCount += This.CountFileMatchesRecursive(cPath + This.Separator() + aList[i][1], cPattern)
			end

		next

		return nCount

	def CountFolderMatchesRecursive(cPath, cPattern)
		nCount = 0

		try
			aList = @dir(cPath)
		catch
			return 0
		end

		nLen = len(aList)

		for i = 1 to nLen

			if aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."

				if This.Matches(cPattern, aList[i][1])
					nCount++
				end

				nCount += This.CountFolderMatchesRecursive(cPath + This.Separator() + aList[i][1], cPattern)
			end

		next

		return nCount

	def ShouldExpandFolder(cFolderName)

		if @bCollapseAll
			return 0
		end

		cFolderName = This.NormalizeFolderPath(cFolderName)

		# If DeepExpandAll is enabled, expand all non-empty folders

		if @bDeepExpandAll

			if This.IsFolderEmpty(cFolderName)
				return 0
			else
				return 1
			end

		end

		if @bExpand

			nLen = len(@acCollapseFolders)
			for i = 1 to nLen
				if This.Matches(@acCollapseFolders[i], cFolderName)
					return 0
				end
			next

			if This.IsFolderEmpty(cFolderName)
				return 0
			else
				return 1
			end

		end

		nLen = len(@acExpandFolders)
		for i = 1 to nLen 
			if This.Matches(@acExpandFolders[i], cFolderName)
				return 1
			end
		next

		return 0


	def GetFolderIconForExpanded(bSubfolderHasMatches, bIsEmpty)

		if bSubfolderHasMatches
			return @acDisplayChars[:FolderOpenedFound]
		else
			return @acDisplayChars[:FolderOpened]
		end

	def GetFolderIconForCollapsed(bIsEmpty)
		if bIsEmpty
			return @acDisplayChars[:FolderClosedEmpty]
		else
			return @acDisplayChars[:FolderClosedFull]
		end

	def ChooseFolderIcon(bShouldExpand, bSubfolderHasMatches, bIsEmpty)
		if bShouldExpand
			return This.GetFolderIconForExpanded(bSubfolderHasMatches, bIsEmpty)
		else
			return This.GetFolderIconForCollapsed(bIsEmpty)
		end

	def GenerateVizTreeString(cPath, cPrefix, bIsRoot, cPattern, cSearchType, nCurrentLevel, nMaxLevels)
	    if nCurrentLevel >= nMaxLevels
	        return ""
	    end
	    
	    cResult = ""
	    _aList_ = @dir(cPath)

	    
	    # Separate files and folders
	    aFiles = []
	    aFolders = []
	    nLen = len(_aList_)

		for i = 1 to nLen

	        if _aList_[i][2] = 0  # File
	            aFiles + _aList_[i][1]

	        but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # Folder
	            aFolders + _aList_[i][1]
	        end

	    next
	    
	    # Apply sorting based on display order
	    aItems = This.SortItemsByDisplayOrder(aFiles, aFolders, cPath)
	    nTotalItems = len(aItems)
	    
	    # Display items in sorted order
	    for i = 1 to nTotalItems
	        aItem = aItems[i]
	        cItemName = aItem[1]
	        cItemType = aItem[2]  # "file" or "folder"
	        bIsLastItem = (i = nTotalItems)
	        
	        if cItemType = "file"
	            # Check if file matches the search pattern
	            bFileMatches = 0
	            if cSearchType = "files" or cSearchType = "both"
	                bFileMatches = This.Matches(cPattern, cItemName)
	            end
	            
	            # Show ALL files in expanded folders
	            cIcon = @acDisplayChars[:File]  # Default file icon
	            
	            # Add found indicator if file matches
	            if bFileMatches
	                cIcon += @acDisplayChars[:FileFoundSymbol]  # Found file gets the found-file marker
	            end
	            
	            # Use correct connector based on position
	            if bIsLastItem
	                cResult += cPrefix + @acDisplayChars[:ClosingChar] + (char(226)+char(148)+char(128)) + cIcon + " " + cItemName + nl
	            else
	                cResult += cPrefix + @acDisplayChars[:VerticalCharTick] + (char(226)+char(148)+char(128)) + cIcon + " " + cItemName + nl
	            end
	            
	        else  # folder
	            cItemPath = cPath + This.Separator() + cItemName
	            oSubFolder = new stzFolder(cItemPath)
	            
	            # Check if folder matches the search pattern
	            bFolderMatches = 0
	            if cSearchType = "folders" or cSearchType = "both"
	                bFolderMatches = This.Matches(cPattern, cItemName)
	            end
	            
	            # Check if subfolder contains matches
	            nSubfolderFileMatches = 0
	            nSubfolderFolderMatches = 0
	            bSubfolderHasMatches = 0
	            
	            if cSearchType = "files" or cSearchType = "both"
	                nSubfolderFileMatches = This.CountFileMatchesRecursive(cItemPath, cPattern)
	                if nSubfolderFileMatches > 0
	                    bSubfolderHasMatches = 1
	                end
	            end
	            
	            if cSearchType = "folders" or cSearchType = "both"
	                nSubfolderFolderMatches = This.CountFolderMatchesRecursive(cItemPath, cPattern)
	                if nSubfolderFolderMatches > 0
	                    bSubfolderHasMatches = 1
	                end
	            end
	            
	            # Use ShouldExpandFolder for normal display, OR expand if has search matches
	            bShouldExpand = This.ShouldExpandFolder(cItemName) or bSubfolderHasMatches or This.ShouldDeepExpandFolder(cItemPath)
	            
	            bHasFiles = oSubFolder.CountFiles() > 0
	            bHasFolders = oSubFolder.CountFolders() > 0
	            bIsEmpty = (not bHasFiles and not bHasFolders)
	            
	            # Choose correct folder icon using dedicated method
	            cIcon = This.ChooseFolderIcon(bShouldExpand, bSubfolderHasMatches, bIsEmpty)
	            
	            # Add found indicator if folder itself matches
	            if bFolderMatches
	                cIcon += @acDisplayChars[:FileFoundSymbol]
	            end
	            
	            # Build match count display (only for folders with matches)
	            cMatchCount = ""
	            nTotalMatches = nSubfolderFileMatches + nSubfolderFolderMatches
	            if nTotalMatches > 0
	                cMatchCount = " (" + nTotalMatches + ")"
	            end
	            
	            # Add stats for ShowXT mode for non-empty folders
	            cFolderStats = ""
	            if cSearchType = "showxt" and not bIsEmpty
	                cStats = trim(This.FormatStats(oSubFolder, cPattern))
	                if cStats != ""
	                    cFolderStats = " " + cStats
	                end
	            end
	            
	            # Build the line - use correct connector based on position
	            if bIsLastItem
	                cResult += cPrefix + @acDisplayChars[:ClosingChar] + (char(226)+char(148)+char(128)) + cIcon + " " + cItemName + cMatchCount + cFolderStats + nl
	                cNewPrefix = cPrefix + "  "  # No vertical line continuation for last item
	            else
	                cResult += cPrefix + @acDisplayChars[:VerticalCharTick] + (char(226)+char(148)+char(128)) + cIcon + " " + cItemName + cMatchCount + cFolderStats + nl
	                cNewPrefix = cPrefix + @acDisplayChars[:VerticlalChar] + " "  # Continue vertical line
	            end
	            
	            # Recurse into subfolder if should be expanded
	            if bShouldExpand and nCurrentLevel + 1 < nMaxLevels
	                cResult += This.GenerateVizTreeString(cItemPath, cNewPrefix, 0, cPattern, cSearchType, nCurrentLevel + 1, nMaxLevels)
	            end
	        end
	    next
	    
	    return cResult


	def ShouldDeepExpandFolder(cFolderPath)

		# If DeepExpandAll is enabled, expand all folders
		if @bDeepExpandAll
			return 1
		end
		
		if @acDeepExpandFolders = NULL
			return 0
		end
		
		nLen = len(@acDeepExpandFolders)

		for i = 1 to nLen
			# Check if current folder is under a deep expand folder
			if This.IsSubfolderOf(cFolderPath, @acDeepExpandFolders[i])
				return 1
			end
		next
		
		return 0
