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
# 2. DUAL API STRATEGY:
#    - Qt (QDir): Used for navigation, permissions, path operations, folder creation
#      * Robust cross-platform path handling
#      * Reliable folder operations (mkdir, rmdir, exists)
#      * Navigation methods (cdUp, isRoot, absolutePath)
#    
#    - Ring (ring_dir): Used for file/folder enumeration  
#      * Overcomes Qt entries bug
#      * Consistent hidden file filtering
#      * Direct file system access
#
# 3. CONSISTENCY RULE: 
#    Count() = CountFiles() + CountFolders() 
#    This ensures Count() matches len(Files()) + len(Folders())
#    Avoids Qt's raw _aEntry_ count that includes "." + ".." + hidden files
#
# 4. ABSTRACTION LEVEL: High-level, intuitive behavior
#    - Users expect empty folder to show Count()=0, IsEmpty()=true
#    - Technical details (Qt entries, system files) handled internally
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

func IsFolder(cDir)
	return dirExists(cDir)

	func IsDir(cDir)
		return dirExists(cDir)

	func @IsFolder(cDir)
		return dirExists(cDir)

	func @IsDir(cDir)
		return dirExists(cDir)

func StzFolderQ(cDir)
	return new stzFolder(cDir)

func IsAbsolutePath(cDir)
	return cDir = StzFolderQ(cDir).AbsolutePath()

class stzFolder from stzObject
	@oQDir
	@cOriginalPath
	@nMaxDisplayLevel = DefaultMaxTreeDisplayLevel()
	@acStatKeywords = [ "@count", "@countfiles", "@countfolders" ]
	@cDisplayStatPattern = "@count"
	@cDisplayOrder = :FileFirstAscending

	@bExpandAll = _FALSE_
	@acExpandFolders = []
	@bCollapseAll = _FALSE_
	@acCollapseFolders = []
	
	@acDeepExpandFolders = []

	@acDisplayChars = [
		:VerticlalChar = "│",
		:VerticalCharTick = "├",
		:ClosingChar = "╰",
		:File = " 🗋",
		:FileFound = "📄",
		:FolderRoot = "🗀",
		:FolderRootXT = "📁",
		:FolderOpened = "🗁",
		:FolderOpenedFound = "📂",
		:FolderClosedEmpty = "🗀",
		:FolderClosedFull = "🖿",
		:FolderRootSearchSymbol = "🎯",
		:FileFoundSymbol = "👉"
	]

	#== Initialization ==#
	def init(pcDirPath)
		if CheckParams()
			if NoT isString(pcDirPath)
				StzRaise("Incorrect param type! pcDirPath must be a string.")
			ok
		ok
		pcDirPath = substr(pcDirPath, "\", "/")
		@oQDir = new QDir()
		@cOriginalPath = pcDirPath
		
		if pcDirPath = NULL or pcDirPath = ""
			@oQDir.setPath(".")
			@cOriginalPath = "."
			return
		end
		
		cCleanPath = QDir_cleanPath(NULL, pcDirPath)
		
		if dirExists(cCleanPath)
			@oQDir.setPath(cCleanPath)
			return
		end
		
		try
			oTempDir = new QDir()
			bCreated = oTempDir.mkpath(cCleanPath)
			if bCreated
				@oQDir.setPath(cCleanPath)
			else
				cParentPath = QDir_cleanPath(NULL, cCleanPath + "/..")
				if not dirExists(cParentPath)
					raise("Cannot create folder '" + cCleanPath + "' - parent folder '" + cParentPath + "' doesn't exist.")
				else
					raise("Cannot create folder '" + cCleanPath + "' - insufficient permissions or invalid path.")
				end
			end
		catch
			raise("Failed to create folder '" + cCleanPath + "': " + CatchError())
		end

		if not dirExists(cCleanPath)
			raise("Folder creation failed - '" + cCleanPath + "' doesn't exist after creation attempt.")
		end



#==================================================================================


#===============================#
#  FILE AND FOLDER VALIDATION   #
#===============================#

def IsFile(cPath)
    # Checks if cPath represents a valid existing file within the folder scope
    # Checks if cPath represents a valid existing folder within the folder scope
    if NOT ( isString(cPath) and cPath != "" )
        raise("Incorrect param type! cPath must be non-empty a string.")
    ok

    cNormalizedPath = This.NormalizePathXT(cPath)

	if ring_find(This.FilesXT(), cNormalizedPath) > 0
		return _TRUE_
	else
		return _FALSE_
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

   
   if left(cPath, 1) != "/"
		cPath = "/" + cPath
   ok


	if ring_find(This.Folders(), cPath) > 0
		return _TRUE_
	else
		return _FALSE_
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

#=====================#
#  NORMALIZING PATHS  #
#=====================#

def NormalizePath(cPath)
    # Normalizes the path to work within the StzFolder context
    if NOT isString(cPath)
        return ""
    ok
    cPath = lower(cPath)
    cBasePath = lower(@oQDir.path())
    
    # Handle different path formats
    if left(cPath, 1) = "/"
        # Absolute path starting with /
        cNormalizedPath = cBasePath + cPath
    but substr(cPath, ":/") > 0 OR substr(cPath, ":\\") > 0
        # Full absolute path (Windows or Unix)
        # Check if it's within our folder scope
        if left(cPath, len(cBasePath)) = cBasePath
            cNormalizedPath = cPath
        else
            # Path is outside our scope, make it relative
            cNormalizedPath = cBasePath + "/" + cPath
        ok
    else
        # Relative path
        cNormalizedPath = cBasePath + "/" + cPath
    ok
    
    # Clean up path separators
    cNormalizedPath = substr(cNormalizedPath, "//", "/")
    cNormalizedPath = substr(cNormalizedPath, "\\", "/")
    
    return cNormalizedPath

def NormalizePathXT(cPath)
    # Always returns the full real path including the original path
    if NOT isString(cPath)
        return ""
    ok
    cPath = lower(cPath)
    cBasePath = lower(@oQDir.path())
    
    # Handle different path formats
    if left(cPath, 1) = "/"
        # Absolute path starting with / - always prepend base path
        cNormalizedPath = cBasePath + cPath
    but substr(cPath, ":/") > 0 OR substr(cPath, ":\\") > 0
        # Full absolute path (Windows or Unix) - return as is
        cNormalizedPath = cPath
    else
        # Relative path - always prepend base path
        cNormalizedPath = cBasePath + "/" + cPath
    ok
    
    # Clean up path separators
    cNormalizedPath = substr(cNormalizedPath, "//", "/")
    cNormalizedPath = substr(cNormalizedPath, "\\", "/")
    
    return cNormalizedPath

def NormalizeFileName(cName)
	if NOT isString(cName)
		StzRaise("Incorrect param type! cName must be a string.")
	ok
	cName = trim(cName)
	if len(cName) > 0 and cName[1] != "/"
		cName = "/" + cName
	ok
	cName = substr(cName, "\", "/")
	while substr(cName, "//") > 0
		cName = substr(cName, "//", "/")
	end
	return cName

	def NormaliseFileName(cName)
		return This.NormalizeFileName(cName)

def NormalizeFileNameXT(cName)
	if NOT isString(cName)
		StzRaise("Incorrect param type! cName must be a string.")
	ok
	cName = trim(cName)
	cBasePath = @oQDir.path()
	
	# Handle different name formats
	if len(cName) > 0 and cName[1] != "/"
		cName = "/" + cName
	ok
	
	# Clean up separators
	cName = substr(cName, "\", "/")
	while substr(cName, "//") > 0
		cName = substr(cName, "//", "/")
	end
	
	# Always return full path
	return cBasePath + cName

	def NormaliseFileNameXT(cName)
		return This.NormalizeFileNameXT(cName)

def NormalizeFolderName(cName)
	cName = This.NormalizeFileName(cName)
	if len(cName) > 0 and right(cName, 1) != "/"
		cName += "/"
	ok
	return cName

	def NormaliseFolderName(cName)
		return This.NormalizeFolderName(cName)

def NormalizeFolderNameXT(cName)
	cName = This.NormalizeFileNameXT(cName)  # Get full path first
	if len(cName) > 0 and right(cName, 1) != "/"
		cName += "/"
	ok
	return cName

	def NormaliseFolderNameXT(cName)
		return This.NormalizeFolderNameXT(cName)

#===============================#
#  DETAILED PATH ANALYSIS      #
#===============================#

def PathType(cPath)
    # Returns the type of path: "file", "folder", or "none"
    if This.IsFile(cPath)
        return "file"
    but This.IsFolder(cPath)
        return "folder"
    else
        return "none"
    ok


def PathInfo(cPath)
    # Returns detailed information about the path
    if NOT isString(cPath)
        StzRaise("Incorrect param type! cPath must be a string.")
    ok
    
    cNormalizedPath = This.NormalizePath(cPath)
	if not This.Exists(cNormalizedPath)
		stzraise("Incorrect path!")
	ok

    cType = This.PathType(cNormalizedPath)
    bExists = (cType != "none")
    
    aInfo = [
        :path, cPath,
        :normalized_path, cNormalizedPath,
        :exists, bExists,
        :type, cType,
        :is_file, (cType = "file"),
        :is_folder, (cType = "folder"),
        :is_relative, (left(cPath, 1) != "/" AND substr(cPath, ":/") = 0 AND substr(cPath, ":\\") = 0),
        :parent_folder, This.ParentFolder(cPath)
    ]
    
    return aInfo

def ParentFolder(cPath)
    # Returns the parent folder of the given path
    if NOT isString(cPath)
        return ""
    ok
    
    cNormalizedPath = This.NormalizePath(cPath)
	if NOT This.Exists(cNormalizedPath)
		raise("Incorrect path!")
	ok

    # Find last separator
    nLastSep = 0
    for i = len(cNormalizedPath) to 1 step -1
        if cNormalizedPath[i] = "/"
            nLastSep = i
            exit
        ok
    next
    
    if nLastSep > 0
        return left(cNormalizedPath, nLastSep - 1)
    else
        return @oQDir.path()
    ok

#===============================#
#  BATCH VALIDATION METHODS    #
#===============================#

def AreFiles(acPaths)
    # Checks if all paths in the list are valid files
    if NOT isList(acPaths)
        StzRaise("Incorrect param type! acPaths must be a list.")
    ok
    
    for cPath in acPaths
        if NOT This.IsFile(cPath)
            return FALSE
        ok
    next
    
    return TRUE

def AreFolders(acPaths)
    # Checks if all paths in the list are valid folders
    if NOT isList(acPaths)
        StzRaise("Incorrect param type! acPaths must be a list.")
    ok
    
    for cPath in acPaths
        if NOT This.IsFolder(cPath)
            return FALSE
        ok
    next
    
    return TRUE

def AllExist(acPaths)
    # Checks if all paths in the list exist (files or folders)
    if NOT isList(acPaths)
        StzRaise("Incorrect param type! acPaths must be a list.")
    ok
    
    for cPath in acPaths
        if NOT This.Exists(cPath)
            return FALSE
        ok
    next
    
    return TRUE

def ExistingPathsAmong(acPaths)
    # Returns only the paths that exist from the given list
    if NOT isList(acPaths)
        StzRaise("Incorrect param type! acPaths must be a list.")
    ok
    
    acResult = []
    for cPath in acPaths
        if This.Exists(cPath)
            acResult + cPath
        ok
    next
    
    return acResult


def MissingPathsAmong(acPaths)
    # Returns only the paths that don't exist from the given list
    if NOT isList(acPaths)
        StzRaise("Incorrect param type! acPaths must be a list.")
    ok
    
    acMissing = []
    for cPath in acPaths
        if NOT This.Exists(cPath)
            acMissing + cPath
        ok
    next
    
    return acMissing

#==================================================================================

	#== Folder Information ==#

	def Name()
		return @oQDir.dirName()

	def Path()
		return @oQDir.path()

	def AbsolutePath()
		return @oQDir.absolutePath()

		def FullPath()
			return This.AbsolutePath()

	def IsReadable()
		return @oQDir.isReadable()

	def IsRoot()
		return @oQDir.isRoot()

	def IsAbsolute()
		return @oQDir.isAbsolute()

	def Root()
		return @cOriginalPath

		def RootPath()
			return @cOriginalPath

		def Home()
			return @cOriginalPath

		def HomePath()
			return @cOriginalPath

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
			:IsRoot = This.IsRoot(),
			:Exists = This.Exists("")
		]
		return aInfo

	#== Content Management ==#

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
		_aList_ = ring_dir(@oQDir.path())
		aResult = []
		for _aEntry_ in _aList_
			if _aEntry_[2] = 0
				aResult + (@oQDir.path() + "/" + lower(_aEntry_[1]))
			end
		next
		return aResult
	
	def FoldersXT()
		_aList_ = ring_dir(@oQDir.path())
		aResult = []
		for _aEntry_ in _aList_
			if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."
				aResult + (@oQDir.path() + "/" + lower(_aEntry_[1]) + "/")
			end
		next
		return aResult

	def Files()
		_aList_ = ring_dir(@oQDir.path())
		aResult = []
		for _aEntry_ in _aList_
			if _aEntry_[2] = 0
				aResult + ("/" + lower(_aEntry_[1]))
			end
		next
		return aResult

	def Folders()
		_aList_ = ring_dir(@oQDir.path())
		aResult = []
		for _aEntry_ in _aList_
			if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."
				aResult + ("/" + lower(_aEntry_[1]) + "/")
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

	def Contains(cName)
		aFiles = This.Files()
		aFolders = This.Folders()
		return (ring_find(aFiles, cName) > 0) or (ring_find(aFolders, cName) > 0)

		def Has(cName)
			return This.Contains(cName)

		def ContainsFileOrFolder(cName)
			return This.Contains(cName)

		def ContainsFolderOrFile(cName)
			return This.Contains(cName)

	def ContainsFile(cFileName)
		cFile = This.NormalizeFileName(cFileName)
		aFiles = This.Files()
		return ring_find(aFiles, cFileName) > 0

	def ContainsFolder(cFolderName)
		cFolderName = NormalizeFolderName(cFolderName)
		aFolders = This.Folders()
		return ring_find(aFolders, cFolderName) > 0

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
		if NOT This.Exists(cPath)
			StzRaise("Incorrect path!")
		ok

		acList = ring_dir(cPath)
		nLen = len(acList)

		acResult = []

		for i = 1 to nLen
			if This.IsFile(acList[i])
				acResult + acList[i]
			ok
		next

		return acResult

	def FoldersIn(cPath)
		if NOT This.Exists(cPath)
			StzRaise("Incorrect path!")
		ok

		acList = ring_dir(cPath)
		nLen = len(acList)

		acResult = []

		for i = 1 to nLen
			if This.IsFolder(acList[i])
				acResult + acList[i]
			ok
		next

		return acResult

	#== Deep Content Management ==#

def DeepFiles() # With simplified paths
	aResult = []
	aToProcess = [@oQDir.path()]
	cBasePath = @oQDir.path()
	
	while len(aToProcess) > 0
		cCurrentPath = aToProcess[1]
		del(aToProcess, 1)
		
		_aList_ = ring_dir(cCurrentPath)
		for _aEntry_ in _aList_
			if _aEntry_[2] = 0  # It's a file
				cFullPath = cCurrentPath + "/" + lower(_aEntry_[1])
				cRelativePath = substr(cFullPath, len(cBasePath) + 1)
				if left(cRelativePath, 1) != "/"
					cRelativePath = "/" + cRelativePath
				end
				aResult + cRelativePath
				
			but _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."  # It's a directory
				aToProcess + (cCurrentPath + "/" + _aEntry_[1])
			end
		next
	end
	
	return aResult

def DeepFolders() # With simplified paths
	aResult = []
	aToProcess = [@oQDir.path()]
	cBasePath = @oQDir.path()
	
	while len(aToProcess) > 0
		cCurrentPath = aToProcess[1]
		del(aToProcess, 1)
		
		_aList_ = ring_dir(cCurrentPath)
		for _aEntry_ in _aList_
			if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."  # It's a directory
				cFullPath = cCurrentPath + "/" + lower(_aEntry_[1])
				cRelativePath = substr(cFullPath, len(cBasePath) + 1)
				if left(cRelativePath, 1) != "/"
					cRelativePath = "/" + cRelativePath
				end
				aResult + (cRelativePath + "/")
				aToProcess + (cCurrentPath + "/" + _aEntry_[1])
			end
		next
	end
	
	return aResult

	def DeepFilesXT() # With complete long paths
		aResult = []
		aToProcess = [@oQDir.path()]
		
		while len(aToProcess) > 0
			cCurrentPath = aToProcess[1]
			del(aToProcess, 1)
			
			_aList_ = ring_dir(cCurrentPath)
			for _aEntry_ in _aList_
				if _aEntry_[2] = 0  # It's a file
					aResult + (cCurrentPath + "/" + lower(_aEntry_[1]))
					
				but _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."  # It's a directory
					aToProcess + (cCurrentPath + "/" + _aEntry_[1])
				end
			next
		end
		
		return aResult


	def DeepFoldersXT() # With complete long paths
		aResult = []
		aToProcess = [@oQDir.path()]
		
		while len(aToProcess) > 0
			cCurrentPath = aToProcess[1]
			del(aToProcess, 1)
			
			_aList_ = ring_dir(cCurrentPath)
			for _aEntry_ in _aList_
				if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."  # It's a directory
					cFullPath = cCurrentPath + "/" + lower(_aEntry_[1]) + "/"
					aResult + cFullPath
					aToProcess + (cCurrentPath + "/" + _aEntry_[1])
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

	def DeepCountFile(cFileName)
		return len(This.FindFile(cFileName))

	def DeepCountFileIn(cFileName, cPath)
		return len(This.FindFileIn(cFileName, cPath))

	def DeepCountTheseFiles(acFilesNames)
		return len(This.DeepCountTheseFilesIn(acFilesNames, cPath))

	def DeepCountTheseFilesIn(acFilesNames, cPath)
		return len(This.SearchTheseFilesIn(acFilesNames, cPath))

	def DeepCountFiles()
		return This.DeepCountFilesIn(This.Path())

	def DeepCountFilesIn(cPath)
		nCount = 0
		try
			aList = ring_dir(cPath)
		catch
			return 0
		end
		nLen = len(aList)
		for i = 1 to nLen
			if aList[i][2] = 0
				nCount++
			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				nCount += This.DeepCountFilesIn(cPath + "/" + aList[i][1])
			end
		next
		return nCount

	def DeepCountFilesWithProgress(cPath, nCurrentLevel, nMaxLevel)
		if nCurrentLevel > nMaxLevel
			return 0
		ok
		nCount = 0
		try
			aList = ring_dir(cPath)
		catch
			return 0
		end
		nLen = len(aList)
		for i = 1 to nLen
			if aList[i][2] = 0
				nCount++
			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				nCount += This.DeepCountFilesWithProgress(cPath + "/" + aList[i][1], nCurrentLevel + 1, nMaxLevel)
			ok
		next
		return nCount

	def DeepCountFolder(cFolderName)
		return len(This.FindFolder(cFolderName))

	def DeepCountFolderIn(cFolderName, cPath)
		return len(This.FindFolderIn(cFolderName, cPath))

	def DeepCountTheseFoldersIn(acFoldersNames, cPath)
		return len(This.SearchTheseFoldersIn(acFoldersNames, cPath))

	def DeepCountFolders()
		return This.DeepCountFoldersIn(This.Path())

	def DeepCountFoldersIn(cPath)
		nCount = 0
		try
			aList = ring_dir(cPath)
		catch
			return 0
		end
		nLen = len(aList)
		for i = 1 to nLen
			if aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				nCount++
				nCount += This.DeepCountFoldersIn(cPath + "/" + aList[i][1])
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
		try
			aList = ring_dir(cPath)
		catch
			return FALSE
		end
		nLen = len(aList)
		for i = 1 to nLen
			if aList[i][2] = 0 and aList[i][1] = cFileName
				return TRUE
			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				if This.DeepContainsFileIn(cFileName, cPath + "/" + aList[i][1])
					return TRUE
				end
			end
		next
		return FALSE

	def DeepContainsTheseFiles(acFilesNames)
		return This.DeepContainsTheseFilesIn(acFilesNames, This.Path())

	def DeepContainsTheseFilesIn(acFilesNames, cPath)
		if CheckParams()
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
		try
			aList = ring_dir(cPath)
		catch
			return FALSE
		end
		nLen = len(aList)
		for i = 1 to nLen
			if aList[i][2] = 1 and aList[i][1] = cFolderName
				return TRUE
			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				if This.DeepContainsFolderIn(cFolderName, cPath + "/" + aList[i][1])
					return TRUE
				end
			end
		next
		return FALSE

	def DeepContainsTheseFolders(acFoldersNames)
		return This.DeepContainsTheseFoldersIn(acFoldersNames, This.Path())

	def DeepContainsTheseFoldersIn(acFoldersNames, cPath)
		if CheckParams()
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

	#== Navigation ==#
	def GoTo(cDir)
		if cDir = ".."
			return This.GoUp()
		end
		if not IsAbsolutePath(cDir)
			cFullPath = This.Path() + "/" + cDir
		else
			cFullPath = cDir
		end
		if not This.Exists(cFullPath)
			raise("Incorrect path!")
		end

		@oQDir.setPath(cFullPath)
		return This

		def MoveTo(cDir)
			return This.GoTo(cDir)

		def cd(cDir)
			return This.GoTo(cDir)

	def GoUp()
		if This.IsRoot()
			raise("Already at root - cannot go up further.")
		end
		@oQDir.cdUp()
		return This

		def Up()
			return This.GoUp()

		def cdUp()
			return This.GoUp()

	def GoHome()
		@oQDir.setPath(@cOriginalPath)

		def GoToHome()
			@oQDir.setPath(@cOriginalPath)

		def GoToRoot()
			@oQDir.setPath(@cOriginalPath)

		def GoRoot()
			@oQDir.setPath(@cOriginalPath)

	#== Folder Operations ==#
	def CreateFolder(pcDirName)
		if pcDirName = NULL or pcDirName = ""
			raise("Folder name cannot be empty.")
		end

		cFullPath = This.Path() + "/" + pcDirName

		if NOT This.Exists(cFullPath)
			raise("Incorrect path!")
		ok

		if dirExists(cFullPath)
			return new stzFolder(cFullPath)
		end

		bSuccess = @oQDir.mkdir(pcDirName)

		if not bSuccess
			raise("Could not create folder '" + pcDirName + "'")
		end
		return new stzFolder(cFullPath)


		def mkdir(pcDirName)
			return This.CreateFolder(pcDirName)

		def MakeFolder(pcDirName)
			return This.CreateFolder(pcDirName)

	def CreateFolders(acDirNames)
		aCreated = []
		for cName in acDirNames
			try
				oNewFolder = This.CreateFolder(cName)
				aCreated + oNewFolder
			catch cError
				raise("Failed creating folder '" + cName + "': " + cError)
			end
		next
		return aCreated

	def DeleteFolder(cFolderName)
		if cFolderName = NULL or cFolderName = ""
			raise("Please specify folder name to remove.")
		end
		if not This.ContainsFolder(cFolderName)
			raise("Folder '" + cFolderName + "' doesn't exist here.")
		end
		oTargetFolder = new stzFolder(This.Path() + "/" + cFolderName)
		if not oTargetFolder.IsEmpty()
			raise("Cannot remove '" + cFolderName + "' - folder not empty.")
		end
		bSuccess = @oQDir.rmdir(cFolderName)
		if not bSuccess
			raise("Could not remove folder '" + cFolderName + "'")
		end
		return This

		def rmdir(cFolderName)
			return This.DeleteFolder(cFolderName)

		def RemoveFolder(cFolderName)
			return This.deleteFolder(cFolderName)

	def DeleteAll()
		try
			aFiles = This.Files()
			nLen = len(aFiles)
			for i = 1 to nLen
				bSuccess = @oQDir.remove(aFiles[i])
				if not bSuccess
					raise("Could not remove file '" + aFiles[i] + "'")
				end
			next
			aFolders = This.Folders()
			nLen = len(aFolders)
			for i = 1 to nLen
				oSubFolder = new stzFolder(This.Path() + "/" + aFolders[i])
				bSuccess = oSubFolder.@oQDir.removeRecursively()
				if not bSuccess
					raise("Could not remove subfolder '" + aFolders[i] + "'")
				end
			next
		catch
			raise("Could not empty folder '" + This.Path() + "': " + CatchError())
		end

		def RemoveAll()
			return This.DeleteAll()

	def Erase()
		nDeleted = 0
		acFiles = This.Files()
		for cFile in acFiles
			cFullPath = @oQDir.path() + "/" + cFile
			if fexists(cFullPath)
				remove(cFullPath)
				nDeleted++
			ok
		next
		return nDeleted

		def EraseFoldersInRoot()
			return This.Erase()

	def DeepErase()
		nDeleted = 0
		acAllDirs = This.DeepFolders()
		for cDir in acAllDirs
			aEntries = dir(cDir)
			for a_aEntry_ in aEntries
				if a_aEntry_[2] = 0
					cFilePath = cDir + "/" + a_aEntry_[1]
					if fexists(cFilePath)
						remove(cFilePath)
						nDeleted++
					ok
				ok
			next
		next
		return nDeleted

	def DeepDeleteFile(cFileName)
		if NOT isString(cFileName)
			StzRaise("Incorrect param type! cFileName must be a string.")
		ok
		nDeleted = 0
		acFilePaths = This.DeepFindFile(cFileName)
		for cFilePath in acFilePaths
			if fexists(cFilePath)
				remove(cFilePath)
				nDeleted++
			ok
		next
		return nDeleted

		def DeepRemoveFile(cFileName)
			return This.DeepDeleteFile(cFileName)

	def DeepDeleteTheseFiles(acFilesNames)
		if NOT isList(acFilesNames)
			StzRaise("Incorrect param type! acFilesNames must be a list.")
		ok
		nDeleted = 0
		for cFileName in acFilesNames
			nDeleted += This.DeepDeleteFile(cFileName)
		next
		return nDeleted

		def DeepRemoveTheseFiles(acFilesNames)
			return This.DeepDeleteTheseFiles(acFilesNames)

	def DeepDeleteFolder(cFolderName)
		if NOT isString(cFolderName)
			StzRaise("Incorrect param type! cFolderName must be a string.")
		ok
		nDeleted = 0
		acFolderPaths = This.DeepFindFolder(cFolderName)
		acSortedPaths = []
		for cPath in acFolderPaths
			nDepth = len(str2list(cPath, "/"))
			acSortedPaths + [nDepth, cPath]
		next
		for i = 1 to len(acSortedPaths) - 1
			for j = i + 1 to len(acSortedPaths)
				if acSortedPaths[i][1] < acSortedPaths[j][1]
					aTmp = acSortedPaths[i]
					acSortedPaths[i] = acSortedPaths[j]
					acSortedPaths[j] = aTmp
				ok
			next
		next
		for aPathInfo in acSortedPaths
			cFolderPath = aPathInfo[2]
			if isdir(cFolderPath)
				system("rmdir " + '"' + cFolderPath + '"')
				nDeleted++
			ok
		next
		return nDeleted

		def DeepRemoveFolder(cFolderName)
			return This.DeepDeleteFolder(cFolderName)

	def DeepDeleteTheseFolders(acFoldersNames)
		if NOT isList(acFoldersNames)
			StzRaise("Incorrect param type! acFoldersNames must be a list.")
		ok
		nDeleted = 0
		for cFolderName in acFoldersNames
			nDeleted += This.DeepDeleteFolder(cFolderName)
		next
		return nDeleted

		def DeepRemoveTheseFolders(acFoldersNames)
			return This.DeepDeleteTheseFolders(acFoldersNames)

	#== File Operations ==#
	def ResolvePath(cPath)
		if cPath = NULL or cPath = ""
			raise("Path cannot be empty")
		end
		if NOT This.Exists(cPath)
			raise("incorrect path!")
		ok
		if IsAbsolutePath(cPath)
			return cPath
		end
		cCurrentPath = This.AbsolutePath()
		if right(cCurrentPath, 1) != "/" and right(cCurrentPath, 1) != "\"
			cCurrentPath += "/"
		end
		return cCurrentPath + cPath


	def FileRead(cFile)
		return @FileRead(This.ResolvePath(cFile))

		def ReadFile(cFile)
			return This.FileRead(cFile)

	def FileReadQ(cFile)
		return @FileReadQ(This.ResolvePath(cFile))

		def ReadFileQ(cFile)
			return This.FileReadQ(cFile)

	def FileInfo(cFile)
		return @FileInfo(This.ResolvePath(cFile))

		def FileInfoQ(cFile)
			return @FileInfoQ(This.ResolvePath(cFile))

	def FileInfoXT(cFile)
		return @FileInfoXT(This.ResolvePath(cFile))

	def FileAppend(cFile, cAdditionalText)
		return @FileAppend(This.ResolvePath(cFile), cAdditionalText)

		def FileAppendQ(cFile, cAdditionalText)
			return @FileAppendQ(This.ResolvePath(cFile), cAdditionalText)

		def AppendFile(cFile, cAdditionalText)
			return FileAppend(cFile, cAdditionalText)

			def AppendFileQ(cFile, cAdditionalText)
				return FileAppendQ(cFile, cAdditionalText)

	def FileCreate(cFileName)
		if cFileName = NULL or cFileName = ""
			StzRaise("File name cannot be empty.")
		ok
		cResolvedPath = This.ResolvePath(cFileName)
		if This.FileExists(cFileName)
			StzRaise("File '" + cFileName + "' already exists.")
		ok
		cParentDir = This.GetParentDirectory(cResolvedPath)
		if not dirExists(cParentDir)
			StzRaise("Parent directory does not exist: " + cParentDir)
		ok
		return @FileCreate(cResolvedPath)

		def FileCreateQ(cFile)
			return @FileCreateQ(This.ResolvePath(cFile))
	
		def CreateFile(cFile)
			return This.FileCreate(cFile)

			def CreateFileQ(cFile)
				return This.FileCreateQ(cFile)

	def FilesCreate(acFileNames)
		if CheckParams()
			if NOT (isList(acFileNames) and @IsListOfStrings(acFileNames))
				StzRaise("Incorrect param type! acFileNames must be a list of strings.")
			ok
		ok
		acCreated = []
		acFailed = []
		for cFileName in acFileNames
			try
				This.CreateFile(cFileName)
				acCreated + cFileName
			catch
				acFailed + [cFileName, CatchError()]
			end
		next
		return [
			:Created = acCreated,
			:Failed = acFailed
		]

		def CreateFiles(acFileNames)
			return This.FilesCreate(acFileNames)

	def FileOverwrite(cFile, cNewContent)
		return @FileOverwrite(This.ResolvePath(cFile), cNewContent)

		def FileOverwriteQ(cFile, cNewContent)
			return @FileOverwriteQ(This.ResolvePath(cFile), cNewContent)

		def OverwriteFile(cFile, cNewContent)
			return This.FileOverwrite(cFile, cNewContent)

		def OverwriteFileQ(cFile, cNewContent)
			return This.FileOverwriteQ(cFile, cNewContent)

	def FileErase(cFile)
		return @FileErase(This.ResolvePath(cFile))

		def FileEraseQ(cFile)
			return @FileEraseQ(This.ResolvePath(cFile))

		def EraseFile(cFile)
			return This.FileErase(cFile)

		def EraseFileQ(cFile)
			return This.FileEraseQ(cFile)

	def FileSafeErase(cFile)
		return @FileSafeErase(This.ResolvePath(cFile))

		def FileSafeEraseQ(cFile)
			return @FileSafeEraseQ(This.ResolvePath(cFile))
	
		def SafeEraseFile(cFile)
			return This.FileSafeErase(cFile)

		def SafeEraseFileQ(cFile)
			return This.FileSafeEraseQ(cFile)

	def FileRemove(cFile)
		if cFile = ""
			StzRaise("Please specify file name to remove.")
		end
		cFile = This.ResolvePath(cFile)
		if not This.ContainsFile(cFile)
			StzRaise("File '" + cFile + "' doesn't exist here.")
		end
		bSuccess = @oQDir.remove(cFile)
		if not bSuccess
			raise("Could not remove file '" + cFile + "'")
		end
		return _TRUE_

		def FileDelete(cFile)
			return This.FileRemove(cFile)

		def RemoveFile(cFile)
			return This.FileRemove(cFile)

		def DeleteFile(cFile)
			return This.FileRemove(cFile)

	def FileBackup(cFile)
		return @FileBackup(This.ResolvePath(cFile))

		def BackupFile(cFile)
			return This.FileBackup(cfile)

	def FileSafeOverwrite(cFile, cNewContent)
		return @FileSafeOverwrite(This.ResolvePath(cFile), cNewContent)

		def SafeOverwriteFile(cFile, cNewContent)
			return This.FileSafeOverwrite(cFile, cNewContent)

	def FileModify(cFile, cOldContent, cNewContent)
		return @FileModify(This.ResolvePath(cFile), cOldContent, cNewContent)

		def ModifyFile(cFile, cOldContent, cNewContent)
			return This.FileModify(cFile, cOldContent, cNewContent)

	def FileCopy(cSource, cDestination)
		return @FileCopy(This.ResolvePath(cSource), This.ResolvePath(cDestination))

		def CopyFile(cSource, cDestination)
			return this.FileCopy(cSource, cDestination)

	def FileMove(cSource, cDestination)
		return @FileMove(This.ResolvePath(cSource), This.ResolvePath(cDestination))

		def MoveFile(cSource, cDestination)
			return this.FileMove(cSource, cDestination)

	def FileSize(cFile)
		return @FileSize(This.ResolvePath(cFile))

		def FileSizeInBytes(cFile)
			return this.FileSize(cFile)

	#== Finding Operations ==#

	def FindFiles(cPattern)
		if NOT isString(cPattern)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok
		cNormalized = This.NormalizeFileName(cPattern)
		aFiles = This.Files()
		acResult = []
		if substr(cPattern, "*") > 0
			cPattern = substr(cPattern, "*", "")
			for cFile in aFiles
				if substr(lower(cFile), lower(cPattern)) > 0
					acResult + cFile
				ok
			next
		else
			for cFile in aFiles
				if lower(cFile) = lower(cNormalized)
					acResult + cFile
				ok
			next
		ok
		return acResult

		def FindFile(cFileName)
			return This.FindFiles(cFileName)

		def FindThisFile(cFileName)
			return This.FindFiles(cFileName)

	def FindFolders(cPattern)
		if NOT isString(cPattern)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok
		acFolders = This.Folders()
		acResult = []
		if substr(cPattern, "*") > 0
			cPattern = substr(cPattern, "*", "")
			for cFolder in acFolders
				if substr(lower(cFolder), lower(cPattern)) > 0
					acResult + cFolder
				ok
			next
		else
			for cFolder in acFolders
				if lower(cFolder) = lower(cPattern)
					acResult + cFolder
				ok
			next
		ok
		return acResult

		def FindFolder(cFolderName)
			return This.FindFolders(cFolderName)

		def FindThisFolder(cFolderName)
			return This.FindFolders(cFolderName)

	def FindFilesByExtension(cExt)
		if NOT isString(cExt)
			StzRaise("Incorrect param type! cExt must be a string.")
		ok
		if left(cExt, 1) != "."
			cExt = "." + cExt
		ok
		acFound = []
		acAllFiles = This.Files()
		for cFile in acAllFiles
			if right(lower(cFile), len(cExt)) = lower(cExt)
				acFound + cFile
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
		for cFileName in acFilesNames
			acFileResults = This.FindFiles(cFileName)
			for cFile in acFileResults
				if find(acFound, cFile) = 0
					acFound + cFile
				ok
			next
		next
		return acFound

	def FindTheseFolders(acFoldersNames)
		if NOT isList(acFoldersNames)
			StzRaise("Incorrect param type! acFoldersNames must be a list.")
		ok
		acFound = []
		for cFolderName in acFoldersNames
			acFolderResults = This.FindFolders(cFolderName)
			for cFolder in acFolderResults
				if find(acFound, cFolder) = 0
					acFound + cFolder
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
		bWildcard = (substr(cPattern, "*") > 0)
		if bWildcard
			cPattern = substr(cPattern, "*", "")
		ok
		for cDir in acAllDirs
			aEntries = dir(cDir)
			for a_aEntry_ in aEntries
				if a_aEntry_[2] = 0
					if bWildcard
						if substr(lower(a_aEntry_[1]), lower(cPattern)) > 0
							acFound + (cDir + "/" + a_aEntry_[1])
						ok
					else
						if lower(a_aEntry_[1]) = lower(cPattern)
							acFound + (cDir + "/" + a_aEntry_[1])
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
		bWildcard = (substr(cPattern, "*") > 0)
		if bWildcard
			cPattern = substr(cPattern, "*", "")
		ok
		for cDir in acAllDirs
			aEntries = dir(cDir)
			for a_aEntry_ in aEntries
				if a_aEntry_[2] = 1 and a_aEntry_[1] != "." and a_aEntry_[1] != ".."
					if bWildcard
						if substr(lower(a_aEntry_[1]), lower(cPattern)) > 0
							acFound + (cDir + "/" + a_aEntry_[1])
						ok
					else
						if lower(a_aEntry_[1]) = lower(cPattern)
							acFound + (cDir + "/" + a_aEntry_[1])
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
		for cFileName in acFilesNames
			acFileResults = This.DeepFindFiles(cFileName)
			for cPath in acFileResults
				if find(acFound, cPath) = 0
					acFound + cPath
				ok
			next
		next
		return acFound

	def DeepFindTheseFolders(acFoldersNames)
		if NOT isList(acFoldersNames)
			StzRaise("Incorrect param type! acFoldersNames must be a list.")
		ok
		acFound = []
		for cFolderName in acFoldersNames
			acFolderResults = This.DeepFindFolders(cFolderName)
			for cPath in acFolderResults
				if find(acFound, cPath) = 0
					acFound + cPath
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


	#== Search Operations ==#

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
		cFullPath = @oQDir.path() + "/" + cFile
		if fexists(cFullPath)
			cFileContent = read(cFullPath)
			acLines = str2list(cFileContent)
			for i = 1 to len(acLines)
				if substr(lower(acLines[i]), lower(cContent)) > 0
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
		for cFile in acFiles
			acLineNumbers = This.SearchInFile(cFile, cContent)
			if len(acLineNumbers) > 0
				acResults + [cFile, acLineNumbers]
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
		cFolderPath = @oQDir.path() + "/" + cFolder
		if isdir(cFolderPath)
			aEntries = dir(cFolderPath)
			for a_aEntry_ in aEntries
				if a_aEntry_[2] = 0
					cFilePath = cFolderPath + "/" + a_aEntry_[1]
					if fexists(cFilePath)
						cFileContent = read(cFilePath)
						acLines = str2list(cFileContent)
						acLineNumbers = []
						for i = 1 to len(acLines)
							if substr(lower(acLines[i]), lower(cContent)) > 0
								acLineNumbers + i
							ok
						next
						if len(acLineNumbers) > 0
							acResults + [a_aEntry_[1], acLineNumbers]
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
		for cFolder in acFolders
			acFolderResults = This.SearchInFolder(cFolder, cContent)
			for aResult in acFolderResults
				acResults + aResult
			next
		next
		return acResults

	def DeepSearchInFiles(cContent)
		if NOT isString(cContent)
			StzRaise("Incorrect param type! cContent must be a string.")
		ok
		acResults = []
		acAllDirs = This.DeepFolders()
		for cDir in acAllDirs
			aEntries = dir(cDir)
			for a_aEntry_ in aEntries
				if a_aEntry_[2] = 0
					cFilePath = cDir + "/" + a_aEntry_[1]
					if fexists(cFilePath)
						cFileContent = read(cFilePath)
						acLines = str2list(cFileContent)
						acLineNumbers = []
						for i = 1 to len(acLines)
							if substr(lower(acLines[i]), lower(cContent)) > 0
								acLineNumbers + i
							ok
						next
						if len(acLineNumbers) > 0
							acResults + [cFilePath, acLineNumbers]
						ok
					ok
				ok
			next
		next
		return acResults

	def DeepSearchInFile(cFile, cContent)
		if NOT isString(cFile) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok
		acResults = []
		acFilePaths = This.DeepFindFiles(cFile)
		for cFilePath in acFilePaths
			if fexists(cFilePath)
				cFileContent = read(cFilePath)
				acLines = str2list(cFileContent)
				acLineNumbers = []
				for i = 1 to len(acLines)
					if substr(lower(acLines[i]), lower(cContent)) > 0
						acLineNumbers + i
					ok
				next
				if len(acLineNumbers) > 0
					acResults + [cFilePath, acLineNumbers]
				ok
			ok
		next
		return acResults

	def DeepSearchInTheseFiles(acFiles, cContent)
		if NOT isList(acFiles) or NOT isString(cContent)
			StzRaise("Incorrect param types! acFiles must be a list and cContent must be string.")
		ok
		acResults = []
		for cFile in acFiles
			acFileResults = This.DeepSearchInFile(cFile, cContent)
			for aResult in acFileResults
				acResults + aResult
			next
		next
		return acResults

	def DeepSearchInFolder(cFolder, cContent)
		if NOT isString(cFolder) or NOT isString(cContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok
		acResults = []
		acFolderPaths = This.DeepFindFolders(cFolder)
		for cFolderPath in acFolderPaths
			if isdir(cFolderPath)
				aEntries = dir(cFolderPath)
				for a_aEntry_ in aEntries
					if a_aEntry_[2] = 0
						cFilePath = cFolderPath + "/" + a_aEntry_[1]
						if fexists(cFilePath)
							cFileContent = read(cFilePath)
							acLines = str2list(cFileContent)
							acLineNumbers = []
							for i = 1 to len(acLines)
								if substr(lower(acLines[i]), lower(cContent)) > 0
									acLineNumbers + i
								ok
							next
							if len(acLineNumbers) > 0
								acResults + [cFilePath, acLineNumbers]
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
		for cFolder in acFolders
			acFolderResults = This.DeepSearchInFolder(cFolder, cContent)
			for aResult in acFolderResults
				acResults + aResult
			next
		next
		return acResults

	#== Content Modification ==#
	def ModifyInFile(cFile, cContent, cNewContent)
		if NOT isString(cFile) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok
		cFullPath = @oQDir.path() + "/" + cFile
		if fexists(cFullPath)
			cFileContent = read(cFullPath)
			cModifiedContent = substr(cFileContent, cContent, cNewContent)
			write(cFullPath, cModifiedContent)
			return TRUE
		ok
		return FALSE

	def ModifyInFiles(acFiles, cContent, cNewContent)
		if NOT isList(acFiles) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFiles must be a list, cContent and cNewContent must be strings.")
		ok
		nModified = 0
		for cFile in acFiles
			if This.ModifyInFile(cFile, cContent, cNewContent)
				nModified++
			ok
		next
		return nModified

	def ModifyInFolder(cFolder, cContent, cNewContent)
		if NOT isString(cFolder) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok
		nModified = 0
		cFolderPath = @oQDir.path() + "/" + cFolder
		if isdir(cFolderPath)
			aEntries = dir(cFolderPath)
			for a_aEntry_ in aEntries
				if a_aEntry_[2] = 0
					cFilePath = cFolderPath + "/" + a_aEntry_[1]
					if fexists(cFilePath)
						cFileContent = read(cFilePath)
						cModifiedContent = substr(cFileContent, cContent, cNewContent)
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
		for cFolder in acFolders
			nModified += This.ModifyInFolder(cFolder, cContent, cNewContent)
		next
		return nModified

	def ModifyInRoot(cContent, cNewContent)
		if NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok
		nModified = 0
		acFiles = This.Files()
		for cFile in acFiles
			if This.ModifyInFile(cFile, cContent, cNewContent)
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
		for cFilePath in acFilePaths
			if fexists(cFilePath)
				cFileContent = read(cFilePath)
				cModifiedContent = substr(cFileContent, cContent, cNewContent)
				write(cFilePath, cModifiedContent)
				nModified++
			ok
		next
		return nModified

	def DeepModifyInFiles(acFiles, cContent, cNewContent)
		if NOT isList(acFiles) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! acFiles must be a list, cContent and cNewContent must be strings.")
		ok
		nModified = 0
		for cFile in acFiles
			nModified += This.DeepModifyInFile(cFile, cContent, cNewContent)
		next
		return nModified

	def DeepModifyInFolder(cFolder, cContent, cNewContent)
		if NOT isString(cFolder) or NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! All parameters must be strings.")
		ok
		nModified = 0
		acFolderPaths = This.DeepFindFolder(cFolder)
		for cFolderPath in acFolderPaths
			if isdir(cFolderPath)
				aEntries = dir(cFolderPath)
				for a_aEntry_ in aEntries
					if a_aEntry_[2] = 0
						cFilePath = cFolderPath + "/" + a_aEntry_[1]
						if fexists(cFilePath)
							cFileContent = read(cFilePath)
							cModifiedContent = substr(cFileContent, cContent, cNewContent)
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
		for cFolder in acFolders
			nModified += This.DeepModifyInFolder(cFolder, cContent, cNewContent)
		next
		return nModified

	def DeepModifyInRoot(cContent, cNewContent)
		if NOT isString(cContent) or NOT isString(cNewContent)
			StzRaise("Incorrect param types! Both parameters must be strings.")
		ok
		nModified = 0
		acAllDirs = This.DeepFolders()
		for cDir in acAllDirs
			aEntries = dir(cDir)
			for a_aEntry_ in aEntries
				if a_aEntry_[2] = 0
					cFilePath = cDir + "/" + a_aEntry_[1]
					if fexists(cFilePath)
						cFileContent = read(cFilePath)
						cModifiedContent = substr(cFileContent, cContent, cNewContent)
						write(cFilePath, cModifiedContent)
						nModified++
					ok
				ok
			next
		next
		return nModified

	#== Visualization ==#
	def VizSearch(cPattern)
		nFileMatches = This.CountFileMatches(This.Path(), cPattern)
		nFolderMatches = This.CountFolderMatches(This.Path(), cPattern)
		nTotalMatches = nFileMatches + nFolderMatches
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + " " + nTotalMatches + " matches for '" + cPattern + "')" + nl
		cResult += This.GenerateVizTreeString(This.Path(), '', _TRUE_, cPattern, "both", 0, 1)
		return cResult

	def VizFindFiles(cPattern)
		nTotalMatches = This.CountFileMatches(This.Path(), cPattern)
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + " " + nTotalMatches + " file matches for '" + cPattern + "')" + nl
		cResult += This.GenerateVizTreeString(This.Path(), "", _TRUE_, cPattern, "files", 0, 1)
		return cResult

	def VizFindFolders(cPattern)
		nTotalMatches = This.CountFolderMatches(This.Path(), cPattern)
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRootXT] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + " " + nTotalMatches + " folder matches for '" + cPattern + "')" + nl
		cResult += This.GenerateVizTreeString(This.Path(), "", _TRUE_, cPattern, "folders", 0, 1)
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
		cResult += This.GenerateVizTreeString(This.Path(), '', _TRUE_, cPattern, "both", 0, This.MaxDisplayLevel())
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
		cResult += This.GenerateVizTreeString(This.Path(), "", _TRUE_, cPattern, "files", 0, This.MaxDisplayLevel())
		return cResult

	def VizDeepFindFolders(cPattern)
		nTotalMatches = This.CountFolderMatchesRecursive(This.Path(), cPattern)
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRootXT] + " " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + + "  " + nTotalMatches + " folder matches for '" + cPattern + "')" + nl
		cResult += This.GenerateVizTreeString(This.Path(), "", _TRUE_, cPattern, "folders", 0, This.MaxDisplayLevel())
		return cResult

		def VizDeepSearchDirs(cPattern)
			return This.VizDeepFindFolders(cPattern)

	def Show()
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + nl
		cResult += This.GenerateVizTreeString(This.Path(), "", _TRUE_, '', "", 0, This.MaxDisplayLevel())
		return cResult

	def ShowXT()
		cStatPattern = This.DisplayStatPattern()
		if cStatPattern = ""
			cStatPattern = This.DisplayStatPattern()
		ok
		if cStatPattern = NULL
			cStatPattern = ""
		end
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		cStats = trim(This.FormatStats(This, cStatPattern))
		cResult = @acDisplayChars[:FolderRootXT] + " " + cFolderName + " " + cStats + nl
		cResult += This.GenerateVizTreeString(This.Path(), "", _TRUE_, cStatPattern, "showxt", 0, This.MaxDisplayLevel() )
		return cResult

	#== Display Configuration ==#

	def Expand()
		@bExpandAll = _TRUE_
		@bCollapseAll = _FALSE_
		@acCollapseFolders = []
		@acDeepExpandFolders = []

	def ExpandFolder(cFolder)
		This.ExpandFolders([cFolder])

		def ExpandThisFolder(cFolder)
			This.ExpandFolders([cFolder])

		def ExpandThis(cFolder)
			This.ExpandFolders([cFolders])

	def ExpandFolders(acFolders)
		if isString(acFolders)
			@acExpandFolders = [acFolders]
		else
			@acExpandFolders = acFolders
		end
		@bCollapseAll = _FALSE_
	
		def ExpandTheseFolders(acFolders)
			This.ExpandFolders(acFolders)

		def ExpandThese(acFolders)
			This.ExpandTheseFolders(acFolders)

	#--

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
	@bCollapseAll = _FALSE_

	def DeepExpandTheseFolders(acFolders)
		This.DeepExpandFolders(acFolders)

	def DeepExpandThese(acFolders)
		This.DeepExpandTheseFolders(acFolders)

	#--

	def CollapseAll()
		@bCollapseAll = _TRUE_
		@bExpandAll = _FALSE_
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
		@bExpandAll = _FALSE_

		def CollapseTheseFolders(acFolders)
			This.CollapseFolders(acFolders)

		def CollapseThese(acFolders)
			This.CollapseFolders(acFolders)


	def MaxDisplayLevel()
		return @nMaxDisplayLevel

	def SetMaxDisplayLevel(n)
		if not isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
		@nMaxDisplayLevel = n

	def DisplayStatPattern()
		return @cDisplayStatPattern

	def SetDisplayStat(cPattern)
		if NOT isString(cPattern)
			StzRaise("Incorrect param type! cPattern must be a string.")
		ok
		if NOT This.IsStatPattern(cPattern)
			StzRaise("Incorrect stat pattern! cPattern must contain at least one of these keywords: " + @@(This.StatKeywords()) )
		ok
		@cDisplayStatPattern = cPattern

		def SetDisplayStartPattern(cPattern)
			This.SetDisplayStat(cPattern)

	def StatKeywords()
		return @acStatKeywords

	def IsStatPattern(cPattern)
		if Not isstring(cPattern)
			return _FALSE_
		ok
		cPattern = lower(cpattern)
		acKeywords = This.StatKeywords()
		nLen = len(acKeywords)
		bResult = _FALSE_
		for i = 1 to nLen
			if substr(cPattern, acKeywords[i]) > 0
				bResult = _TRUE_
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
		if NOT ring_find(acValidOrders, lower(cOrder))
			StzRaise("Invalid display order! Must be one of: " + @@(acValidOrders))
		ok
		@cDisplayOrder = lower(cOrder)

	#== Utility Methods ==#
	def Copy()
		return new stzFolder(This.Path())

		def Clone()
			return This.Copy()

	def Refresh()
		@oQDir.refresh()
		return This

	def GetParentDirectory(cPath)
		nPos = 0
		nLen = len(cPath)
		for i = nLen to 1 step -1
			if cPath[i] = "/"
				nPos = i
				exit
			ok
		next
		if nPos > 1
			return left(cPath, nPos - 1)
		else
			return This.Path()
		ok

	def Matches(cPattern, cName)
		if cPattern = "*"
			return _TRUE_
		ok
		cRegexPattern = cPattern
		cRegexPattern = substr(cRegexPattern, "*", ".*")
		cRegexPattern = substr(cRegexPattern, "?", ".")
		if left(cPattern, 1) = "*" and right(cPattern, 1) = "*"
			cMiddle = substr(cPattern, 2, len(cPattern) - 2)
			return substr(cName, cMiddle) > 0
		but left(cPattern, 1) = "*"
			cSuffix = substr(cPattern, 2)
			return right(cName, len(cSuffix)) = cSuffix
		but right(cPattern, 1) = "*"
			cPrefix = left(cPattern, len(cPattern) - 1)
			return left(cName, len(cPrefix)) = cPrefix
		else
			return cName = cPattern
		ok

	def GetFoldersContainingFileMatches(cPath, cPattern)
		aAllPaths = []
		This.CollectFoldersWithFileMatches(cPath, cPattern, aAllPaths)
		aFolderNames = []
		for cFullPath in aAllPaths
			acPathParts = This.GetPathHierarchy(cFullPath)
			for cFolderName in acPathParts
				if ring_find(aFolderNames, cFolderName) = 0
					aFolderNames + cFolderName
				end
			next
		next
		return aFolderNames

	def GetPathHierarchy(cPath)
		acParts = []
		cRelativePath = substr(cPath, This.Path() + "/", "")
		if cRelativePath = cPath
			return []
		end
		acSegments = @split(cRelativePath, "/")
		for cSegment in acSegments
			if cSegment != ""
				acParts + cSegment
			end
		next
		return acParts

	def CollectFoldersWithFileMatches(cPath, cPattern, aFoldersWithMatches)
		try
			_aList_ = ring_dir(cPath)
		catch
			return
		end
		bHasFileMatches = _FALSE_
		for _aEntry_ in _aList_
			if _aEntry_[2] = 0
				if This.Matches(cPattern, _aEntry_[1])
					bHasFileMatches = _TRUE_
					exit
				end
			end
		next
		if bHasFileMatches
			aFoldersWithMatches + cPath
		end
		for _aEntry_ in _aList_
			if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."
				This.CollectFoldersWithFileMatches(cPath + "/" + _aEntry_[1], cPattern, aFoldersWithMatches)
			end
		next

		def GetFolderNameFromPath(cPath)
			if cPath = This.Path()
				return ""
			end
			nPos = max([substr(cPath, "/"), substr(cPath, "\")])
			if nPos > 0
				return right(cPath, len(cPath) - nPos)
			end
			return cPath

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
	

	cPath = This.NormaliseFolderName(cPath)

	# Check if the path tries to go outside the root folder
	if NOT This.Exists(cPath)
		raise("Incorrect path!")
	ok

	if ring_find( This.Files(), cPath ) > 0
		return _TRUE_
	else
		return _FALSE_
	ok

def IsFolderPath(cPath)
	if CHeckParams()
		if NOT (isString(cPath) and cPath != "")
			raise("Incorrect param type! cPath must be a non-empty string.")
		ok
	ok

	cPath = This.NormaliseFolderName(cPath)

	# Check for path injection attempts
	if NOT IsSecurePath(cPath)
		raise("Insecure path with potential injection risks!")
	ok
	
	if ring_find( This.Folders(), cPath ) > 0
		return _TRUE_
	else
		return _FALSE_
	ok

def IsSecurePath(cPath)
	# Check for null bytes (path injection attempt)
	if substr(cPath, char(0)) > 0
		return true
	ok
	
	# Check for other control characters that could be used for injection
	for i = 1 to 31
		if substr(cPath, char(i)) > 0
			return false
		ok
	next
	
	return true

	def HasNoPathInjection(cPath)
		return This.IsSecurePath(cPath)


	def CountFolderMatches(cPath, cPattern)
		nCount = 0
		try
			aList = ring_dir(cPath)
		catch
			return 0
		end
		nLen = len(aList)
		for i = 1 to nLen
			if aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				if This.Matches(cPattern, aList[i][1])
					nCount++
				end
			end
		next
		return nCount

	#== Private Methods ==#
	PRIVATE

	def SortItemsByDisplayOrder(aFiles, aFolders, cPath)
		aItems = []
		switch @cDisplayOrder
			case "systemorder"
				oQDirTemp = new QDir()
				oQDirTemp.setPath(cPath)
				oQDirTemp.setSorting(0)
				aQtEntries = oQDirTemp._aEntry_List_2(3, 0)
				for i = 0 to aQtEntries.size() - 1
					c_aEntry_Name = aQtEntries.at(i)
					if c_aEntry_Name != "." and c_aEntry_Name != ".."
						cFullPath = cPath + "/" + c_aEntry_Name
						if isdir(cFullPath)
							aItems + [c_aEntry_Name, "folder"]
						else
							aItems + [c_aEntry_Name, "file"]
						end
					end
				next
			case "filefirstascending"
				aFilesSorted = sort(aFiles)
				aFoldersSorted = sort(aFolders)
				for cFile in aFilesSorted
					aItems + [cFile, "file"]
				next
				for cFolder in aFoldersSorted
					aItems + [cFolder, "folder"]
				next
			case "filefirstdescending"
				aFilesSorted = reverse(sort(aFiles))
				aFoldersSorted = reverse(sort(aFolders))
				for cFile in aFilesSorted
					aItems + [cFile, "file"]
				next
				for cFolder in aFoldersSorted
					aItems + [cFolder, "folder"]
				next
			case "folderfirstascending"
				aFilesSorted = sort(aFiles)
				aFoldersSorted = sort(aFolders)
				for cFolder in aFoldersSorted
					aItems + [cFolder, "folder"]
				next
				for cFile in aFilesSorted
					aItems + [cFile, "file"]
				next
			case "folderfirstdescending"
				aFilesSorted = reverse(sort(aFiles))
				aFoldersSorted = reverse(sort(aFolders))
				for cFolder in aFoldersSorted
					aItems + [cFolder, "folder"]
				next
				for cFile in aFilesSorted
					aItems + [cFile, "file"]
				next
		end
		return aItems

	def OrderFilesFirst(aFiles, aFolders)
		aResult = []
		for cFile in aFiles
			aResult + [:name = cFile, :type = "file"]
		next
		for cFolder in aFolders
			aResult + [:name = cFolder, :type = "folder"]
		next
		return aResult

	def OrderFoldersFirst(aFiles, aFolders)
		aResult = []
		for cFolder in aFolders
			aResult + [:name = cFolder, :type = "folder"]
		next
		for cFile in aFiles
			aResult + [:name = cFile, :type = "file"]
		next
		return aResult

	def GetPhysicalOrder(cPath)
		_aList_ = ring_dir(cPath)
		aResult = []
		for _aEntry_ in _aList_
			if _aEntry_[2] = 0
				aResult + [:name = _aEntry_[1], :type = "file"]
			but _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."
				aResult + [:name = _aEntry_[1], :type = "folder"]
			end
		next
		return aResult

	def FormatStats(oFolder, cStatPattern)
		if cStatPattern = ""
			return ""
		end
		cStats = cStatPattern
		acKeys = reverse( sort(This.StatKeywords()) )
		nLen = len(ackeys)
		for i = 1 to nLen
			cCode = 'nStatValue = oFolder.' + acKeys[i] + '()'
			cCode = substr(cCode, "@", "")
			eval(cCode)
			if substr(lower(cStats), acKeys[i])
				cStats = substr(lower(cStats), acKeys[i], ("" + nStatValue) )
			end
		next
		if cStats = "..."
			return " (...)"
		end
		return " (" + cStats + ")"

	def CountFileMatchesRecursive(cPath, cPattern)
		nCount = 0
		try
			aList = ring_dir(cPath)
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
				nCount += This.CountFileMatchesRecursive(cPath + "/" + aList[i][1], cPattern)
			end
		next
		return nCount

	def CountFolderMatchesRecursive(cPath, cPattern)
		nCount = 0
		try
			aList = ring_dir(cPath)
		catch
			return 0
		end
		nLen = len(aList)
		for i = 1 to nLen
			if aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."
				if This.Matches(cPattern, aList[i][1])
					nCount++
				end
				nCount += This.CountFolderMatchesRecursive(cPath + "/" + aList[i][1], cPattern)
			end
		next
		return nCount

	def ShouldExpandFolder(cFolderName)
		if @bCollapseAll
			return _FALSE_
		end
		if @bExpandAll
			for cPattern in @acCollapseFolders
				if This.Matches(cPattern, cFolderName)
					return _FALSE_
				end
			next
			if This.IsFolderEmpty(cFolderName)
				return _FALSE_
			else
				return _TRUE_
			end
		end
		for cPattern in @acExpandFolders
			if This.Matches(cPattern, cFolderName)
				return _TRUE_
			end
		next
		return _FALSE_

	def IsFolderEmpty(cFolderName)
		cFolderPath = This.Path() + "/" + cFolderName
		oTempFolder = new stzFolder(cFolderPath)
		bHasFiles = oTempFolder.CountFiles() > 0
		bHasFolders = oTempFolder.CountFolders() > 0
		return (not bHasFiles and not bHasFolders)

	def GetFolderIconForExpanded(cFolderName, bSubfolderHasMatches, bIsEmpty)
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

	def ChooseFolderIcon(cFolderName, bShouldExpand, bSubfolderHasMatches, bIsEmpty)
		if bShouldExpand
			return This.GetFolderIconForExpanded(cFolderName, bSubfolderHasMatches, bIsEmpty)
		else
			return This.GetFolderIconForCollapsed(bIsEmpty)
		end

	def GenerateVizTreeString(cPath, cPrefix, bIsRoot, cPattern, cSearchType, nCurrentLevel, nMaxLevels)
	    if nCurrentLevel >= nMaxLevels
	        return ""
	    end
	    
	    cResult = ""
	    
	    try
	        mylist = ring_dir(cPath)
	    catch
	        return ""
	    end
	    
	    # Separate files and folders
	    aFiles = []
	    aFolders = []
	    
	    for entry in mylist
	        if entry[2] = 0  # File
	            aFiles + entry[1]
	        elseif entry[2] = 1 and entry[1] != "." and entry[1] != ".."  # Folder
	            aFolders + entry[1]
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
	            bFileMatches = _FALSE_
	            if cSearchType = "files" or cSearchType = "both"
	                bFileMatches = This.Matches(cPattern, cItemName)
	            end
	            
	            # Show ALL files in expanded folders
	            cIcon = @acDisplayChars[:File]  # Default file icon
	            
	            # Add found indicator if file matches
	            if bFileMatches
	                cIcon += @acDisplayChars[:FileFoundSymbol]  # Found file gets 👉📄
	            end
	            
	            # Use correct connector based on position
	            if bIsLastItem
	                cResult += cPrefix + @acDisplayChars[:ClosingChar] + "─" + cIcon + " " + cItemName + nl
	            else
	                cResult += cPrefix + @acDisplayChars[:VerticalCharTick] + "─" + cIcon + " " + cItemName + nl
	            end
	            
	        else  # folder
	            cItemPath = cPath + "/" + cItemName
	            oSubFolder = new stzFolder(cItemPath)
	            
	            # Check if folder matches the search pattern
	            bFolderMatches = _FALSE_
	            if cSearchType = "folders" or cSearchType = "both"
	                bFolderMatches = This.Matches(cPattern, cItemName)
	            end
	            
	            # Check if subfolder contains matches
	            nSubfolderFileMatches = 0
	            nSubfolderFolderMatches = 0
	            bSubfolderHasMatches = _FALSE_
	            
	            if cSearchType = "files" or cSearchType = "both"
	                nSubfolderFileMatches = This.CountFileMatchesRecursive(cItemPath, cPattern)
	                if nSubfolderFileMatches > 0
	                    bSubfolderHasMatches = _TRUE_
	                end
	            end
	            
	            if cSearchType = "folders" or cSearchType = "both"
	                nSubfolderFolderMatches = This.CountFolderMatchesRecursive(cItemPath, cPattern)
	                if nSubfolderFolderMatches > 0
	                    bSubfolderHasMatches = _TRUE_
	                end
	            end
	            
	            # Use ShouldExpandFolder for normal display, OR expand if has search matches
	            bShouldExpand = This.ShouldExpandFolder(cItemName) or bSubfolderHasMatches or This.ShouldDeepExpandFolder(cItemPath)
	            
	            bHasFiles = oSubFolder.CountFiles() > 0
	            bHasFolders = oSubFolder.CountFolders() > 0
	            bIsEmpty = (not bHasFiles and not bHasFolders)
	            
	            # Choose correct folder icon using dedicated method
	            cIcon = This.ChooseFolderIcon(cItemName, bShouldExpand, bSubfolderHasMatches, bIsEmpty)
	            
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
	            
	            # FIX 2: Add stats for ShowXT mode for non-empty folders
	            cFolderStats = ""
	            if cSearchType = "showxt" and not bIsEmpty
	                cFolderStats = trim(This.FormatStats(oSubFolder, cPattern))
	            end
	            
	            # Build the line - use correct connector based on position
	            if bIsLastItem
	                cResult += cPrefix + @acDisplayChars[:ClosingChar] + "─" + cIcon + " " + cItemName + cMatchCount + cFolderStats + nl
	                cNewPrefix = cPrefix + "  "  # No vertical line continuation for last item
	            else
	                cResult += cPrefix + @acDisplayChars[:VerticalCharTick] + "─" + cIcon + " " + cItemName + cMatchCount + cFolderStats + nl
	                cNewPrefix = cPrefix + @acDisplayChars[:VerticlalChar] + " "  # Continue vertical line
	            end
	            
	            # Recurse into subfolder if should be expanded
	            if bShouldExpand and nCurrentLevel + 1 < nMaxLevels
	                cResult += This.GenerateVizTreeString(cItemPath, cNewPrefix, _FALSE_, cPattern, cSearchType, nCurrentLevel + 1, nMaxLevels)
	            end
	        end
	    next
	    
	    return cResult


def ShouldDeepExpandFolder(cFolderPath)
	if @acDeepExpandFolders = NULL
		return _FALSE_
	end
	
	for cDeepExpandFolder in @acDeepExpandFolders
		# Check if current folder is under a deep expand folder
		if This.IsSubfolderOf(cFolderPath, cDeepExpandFolder)
			return _TRUE_
		end
	next
	
	return _FALSE_

# Helper method to check if a path is a subfolder of another path:
def IsSubfolderOf(cChildPath, cParentFolder)
	# Normalize paths for comparison
	cNormalizedChild = This.NormalizePathXT(cChildPath)
	cNormalizedParent = This.NormalizePathXT(This.Path() + "/" + cParentFolder)
	
	# Check if child path starts with parent path
	return left(cNormalizedChild, len(cNormalizedParent)) = cNormalizedParent
