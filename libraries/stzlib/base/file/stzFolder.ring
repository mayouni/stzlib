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
#    - Ring (@dir): Used for file/folder enumeration  
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

func IsFolder(cPath)
	return dirExists(cPath)

	func IsDir(cPath)
		return dirExists(cPath)

	func @IsFolder(cPath)
		return dirExists(cPath)

	func @IsDir(cPath)
		return dirExists(cPath)

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
		aResult + [ lower(aRingResult[i][1]), aRingResult[i][2] ]
	next

	return aResult

class stzFolder from stzObject

	@oQDir
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

	@bExpand = _FALSE_
	@bDeepExpandAll = _FALSE_
	@acDeepExpandFolders = []
	@acExpandFolders = []

	@bCollapseAll = _FALSE_
	@acCollapseFolders = []

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

	@bBacthMode = FALSE

	#== Initialization ==#

	def init(pcDirPath)
	
		if CheckParams() and NOT isString(pcDirPath)
			StzRaise("Incorrect param type! pcDirPath must be a string.")
		ok
	
		# Initialize core attributes
		@acPathHistory = []
		@oQDir = new QDir()
		
		# Determine target path - let Qt handle the heavy lifting
		cPath = ""
		if pcDirPath = NULL or pcDirPath = ""
			cPath = QDir_currentPath()  # Get actual current directory path
		else
			cPath = QDir_cleanPath(NULL, pcDirPath)
		ok
		
		# Create directory if it doesn't exist
		if NOT dirExists(cPath)
			if NOT QDir_mkpath(cPath)  # Qt's static method - more reliable
				StzRaise("Cannot create directory: " + cPath)
			ok
		ok
		
		# Set up all paths - let Qt resolve to absolute canonical path
		@oQDir.setPath(cPath)
		@cOriginalPath = @oQDir.absolutePath()  # Qt gives us the canonical absolute path
		@cCurrentPath = @cOriginalPath
		
		# Final accessibility check
		if NOT @oQDir.isReadable()
			StzRaise("Directory is not accessible: " + @cCurrentPath)
		ok

	#===============================#
	#  FILE AND FOLDER VALIDATION   #
	#===============================#
	
	def Separator()
		return "/"
	
	def SystemSeparator()
		return Char(@oQDir.separator().unicode())
	
		def PathSeparator()
			return This.Separator()
	
	def IsInside(cPath)
	
	    if NOT ( isString(cPath) and cPath != "" )
	        raise("Incorrect param type! cPath must be non-empty a string.")
	    ok
	
		# Get the absolute path of the main folder
		cMainPath = @oQDir.absolutePath()
		
		# Create a temporary QDir object for the provided path
		oTempDir = new QDir
		oTempDir.setPath(cPath)
		
		# Get the absolute path of the provided path
		cAbsolutePath = oTempDir.absolutePath()
		
		# Clean both paths to normalize separators and remove redundant elements
		cMainPath = @oQDir.cleanPath(cMainPath)
		cAbsolutePath = @oQDir.cleanPath(cAbsolutePath)
		
		# Ensure paths end with separator for proper comparison
		cSeparator = Char(@oQDir.separator().unicode())
	
		if right(cMainPath, 1) != cSeparator
			cMainPath += cSeparator
		ok
		if right(cAbsolutePath, 1) != cSeparator
			cAbsolutePath += cSeparator
		ok
		
		# Check if the absolute path starts with the main path
	
		nMainPathLen = Len(cMainPath)
	
		if Len(cAbsolutePath) >= nMainPathLen
	
			if Left(cAbsolutePath, nMainPathLen) = cMainPath
	
				# Additional check: ensure it's not the same path
				if cAbsolutePath != cMainPath
					return True
				ok
	
			ok
		ok
		
		# Clean up temporary object
		oTempDir.delete()
		
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
	
		cPath = This.NormalizeFolderPath(cPath)
	
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
	
		cPath = This.NormaliseFolderPath(cPath)
	
		# Check for path injection attempts
		if NOT IsSecurePath(cPath)
			raise("Insecure path with potential injection risks!")
		ok
		
		if ring_find( This.Folders(), cPath ) > 0
			return _TRUE_
		else
			return _FALSE_
		ok

	def IsDeep(cPath)
		if This.IsDeepFile(cPath) or This.IsDeepFolder(cPath)
			return _TRUE_
		else
			return _FALSE_
		ok
	
		def IsDeepPath(cPath)
			IsDeep(cPath)
	
	def IsDeepFile(cPath)
		cPath = This.NormalizePath(cPath)
		cSep = This.Separator()
	
		if right(cPath, 1) = cSep # It's a folder not a file!
			return _FALSE_
		ok
	
		if StzStringQ(cpath).NumberOfOccurrence(cSep) > 1
			return _true_
		else
			return _false_
		ok
	
		def IsDeepFilePath(cPath)
			return This.IsDeepFile(cPath)
	
	def IsDeepFolder(cPath)
		cPath = This.NormalizePath(cPath)
		cSep = This.Separator()
	
		if right(cPath, 1) != cSep # It's a file not a folder!
			return _FALSE_
		ok
	
		if StzStringQ(cpath).NumberOfOccurrence(cSep) > 2
			return _true_
		else
			return _false_
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
		return left(cNormalizedChild, len(cNormalizedParent)) = cNormalizedParent
	
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
	    
	    cResult = "/" + lower(@oQDir.cleanPath(trim(cName)))
		cResult = substr(cResult, "//", "/")
		return cResult

		def NormaliseFilePath(cName)
			return This.NormalizeFilePath(cName)
	
	def NormalizeFilePathXT(cName)
		if CheckParams()
			if NOT ( isString(cName) and trim(cName) != "" )
				StzRaise("Incorrect param type! cName must be a non-empty string.")
			ok
		ok
	    
	    cBasePath = @oQDir.absolutePath()
	    cCleanName = @oQDir.cleanPath(trim(cName))
	    
	    # If not absolute, make it relative to base path
	    if NOT @oQDir.isAbsolutePath(cCleanName)
	        oTempDir = new QDir
	        oTempDir.setPath(cBasePath)
	        cCleanName = oTempDir.absoluteFilePath(cCleanName)
	        oTempDir.delete()
	    ok
	    
	    cResult = lower(@oQDir.cleanPath(cCleanName))
		cSeparator = This.Separator()
		if right(cResult, 1) != cSeparator
			cResult += cSeparator
		ok

		cResult = substr(cResult, "//", "/")
		return cResult

		def NormaliseFilePathXT(cName)
			return This.NormalizeFilePathXT(cName)
	
	def NormalizeFolderPath(cName)

	    cName = This.NormalizeFilePath(cName)
	    cSeparator = This.Separator()

		if cName[1] != cSeparator
			cName = cSeparator + cName
		ok

	    if right(cName, 1) != cSeparator
	        cName += cSeparator
	    ok

		cName = substr(cName, "//", "/")
	    return cName
	
		def NormaliseFolderPath(cName)
			return This.NormalizeFolderPath(cName)
	
	def NormalizeFolderPathXT(cName)
	    cName = This.NormalizeFilePathXT(cName)
	    cSeparator = This.Separator()

	    if right(cName, 1) != cSeparator
	        cName += cSeparator
	    ok

		cName = substr(cName, "//", "/")
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
	        :is_relative, (left(cPath, 1) != This.Separator() AND substr(cPath, ":/") = 0 AND substr(cPath, ":\\") = 0),
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
	    for i = len(cNormalizedPath) to 1 step -1
	        if cNormalizedPath[i] = This.Separator()
	            nLastSep = i
	            exit
	        ok
	    next
	    
	    if nLastSep > 0
	        return left(cNormalizedPath, nLastSep - 1)
	    else
	        return @oQDir.path()
	    ok
	
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
	    
	    for cPath in acPaths
	        if NOT This.IsFile(cPath)
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
	    
	    for cPath in acPaths
	        if NOT This.IsFolder(cPath)
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
	    
	    for cPath in acPaths
	        if NOT This.Exists(cPath)
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
	
	    for cPath in acPaths
	        if This.Exists(cPath)
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
	    for cPath in acPaths
	        if NOT This.Exists(cPath)
	            acMissing + cPath
	        ok
	    next
	    
	    return acMissing

	#======================#
	#  Folder Information  #
	#======================#

	def Name()
		return lower(@oQDir.dirName())

	def Path()
		return lower(@oQDir.path())

	def AbsolutePath()
		return lower(@oQDir.absolutePath())

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

		_aList_ = @dir(@oQDir.path())
		aResult = []

		for _aEntry_ in _aList_
			if _aEntry_[2] = 0
				aResult + (@oQDir.path() + This.Separator() + lower(_aEntry_[1]))
			end
		next

		return aResult
	
	def FoldersXT()

		_aList_ = @dir(@oQDir.path())
		aResult = []

		for _aEntry_ in _aList_
			if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."
				aResult + (@oQDir.path() + This.Separator() + lower(_aEntry_[1]) + This.Separator())
			end
		next

		return aResult

	def Files()

		_aList_ = @dir(@oQDir.path())
		aResult = []

		for _aEntry_ in _aList_
			if _aEntry_[2] = 0
				aResult + (This.Separator() + lower(_aEntry_[1]))
			end
		next

		return aResult

	def Folders()

		_aList_ = @dir(@oQDir.path())
		aResult = []

		for _aEntry_ in _aList_
			if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."
				aResult + (This.Separator() + lower(_aEntry_[1]) + This.Separator())
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

		return (ring_find(aFiles, cName) > 0) or (ring_find(aFolders, cName) > 0)


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

		return ring_find(aFiles, cFileName) > 0

	def ContainsFolder(cFolderName)
		if CheckParams()
			if NOT ( isString(cFolderName) and trim(cFolderName) != "" )
				StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
			ok
		ok

		cFolderName = NormalizeFolderPath(cFolderName)
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
		aToProcess = [@oQDir.path()]
		cBasePath = @oQDir.path()
		
		while len(aToProcess) > 0

			cCurrentPath = aToProcess[1]
			del(aToProcess, 1)
			
			_aList_ = @dir(cCurrentPath)

			for _aEntry_ in _aList_

				if _aEntry_[2] = 0  # It's a file

					cFullPath = cCurrentPath + This.Separator() + lower(_aEntry_[1])
					cRelativePath = substr(cFullPath, len(cBasePath) + 1)

					if left(cRelativePath, 1) != This.Separator()
						cRelativePath = This.Separator() + cRelativePath
					end

					aResult + cRelativePath
					
				but _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."  # It's a directory
					aToProcess + (cCurrentPath + This.Separator() + _aEntry_[1])
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
			
			_aList_ = @dir(cCurrentPath)

			for _aEntry_ in _aList_

				if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."  # It's a directory

					cFullPath = cCurrentPath + This.Separator() + lower(_aEntry_[1])
					cRelativePath = substr(cFullPath, len(cBasePath) + 1)

					if left(cRelativePath, 1) != This.Separator()
						cRelativePath = This.Separator() + cRelativePath
					end

					aResult + (cRelativePath + This.Separator())
					aToProcess + (cCurrentPath + This.Separator() + _aEntry_[1])
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
			
			_aList_ = @dir(cCurrentPath)

			for _aEntry_ in _aList_

				if _aEntry_[2] = 0  # It's a file
					aResult + (cCurrentPath + This.Separator() + lower(_aEntry_[1]))
					
				but _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."  # It's a directory
					aToProcess + (cCurrentPath + This.Separator() + _aEntry_[1])
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
			
			_aList_ = @dir(cCurrentPath)

			for _aEntry_ in _aList_

				if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."  # It's a directory

					cFullPath = cCurrentPath + This.Separator() + lower(_aEntry_[1]) + This.Separator()
					aResult + cFullPath
					aToProcess + (cCurrentPath + This.Separator() + _aEntry_[1])

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
		
		@oQDir.setPath(cFullPath)
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
		
		@oQDir.cdUp()
		@cCurrentPath = @oQDir.absolutePath()  # Update current path
	
		return TRUE

		def Up()
			return This.GoUp()

		def cdUp()
			return This.GoUp()

		def ParentDir()
			return This.GoUp()

	def GoHome()
		# Save current path before going home
		@acPathHistory + @cCurrentPath
		
		@oQDir.setPath(@cOriginalPath)
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
		
		@oQDir.setPath(cPreviousPath)
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
	
		cPath = This.NormalizeFolderPath(pcPath)

	    if NOT This.IsInside(cPath)
	        raise("Can't navigate outside the folder!")
	    ok
	
		if not this.IsBatchMode()
			This.GoTo(pcPath)
		ok

	    return @oQDir.mkpath(pcFolderName)
	
	def DeleteFolder(cFolderName)
	    if CheckParams()
	        if NOT (isString(cFolderName) and cFolderName != "")
	            raise("Incorrect param type! cFolderName must be a non-empty string.")
	        ok
	    end
	
	    if NOT This.IsInside(cFolderName)
	        raise("Can't navigate outside the folder!")
	    ok
	
	    oTempDir = new QDir()
	    oTempDir.setPath(@oQDir.absoluteFilePath(cFolderName))
	    bSuccess = oTempDir.removeRecursively()
	    oTempDir.delete()
	    
	    return bSuccess
	
	def DeleteAll()
	    try
	        # Delete all files
	        acFiles = This.FilesXT()
	        for cFile in acFiles
	            if NOT @oQDir.remove(cFile)
	                raise("Could not remove file '" + cFile + "'")
	            ok
	        next
	
	        # Delete all folders
	        acFolders = This.FoldersXT()
	        for cFolder in acFolders
	            oSubDir = new QDir()
	            oSubDir.setPath(cFolder)
	            if NOT oSubDir.removeRecursively()
	                raise("Could not remove subfolder '" + cFolder + "'")
	            ok
	            oSubDir.delete()
	        next
	
	    catch
	        raise("Could not empty folder '" + This.Path() + "': " + CatchError())
	    end
	
	def Erase()
	    nDeleted = 0
	    acFiles = This.FilesXT()
	    
	    for cFile in acFiles
	        if @oQDir.remove(cFile)
	            nDeleted++
	        ok
	    next
	    
	    return nDeleted
	
	def DeepErase()
	    nDeleted = 0
	    acFiles = This.DeepFilesXT()
	    
	    for cFile in acFiles
	        if @oQDir.remove(cFile)
	            nDeleted++
	        ok
	    next
	    
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
	    nDeleted = 0
	
	    for cFilePath in acFilePaths
	        if @oQDir.remove(cFilePath)
	            nDeleted++
	        ok
	    next
	
	    return nDeleted > 0
	
		def DeepDeleteFolder(cFolderName)
	
			if CheckParams()
				if NOT ( isString(cFolderName) and trim(cFolderNAme) != "" )
					StzRaise("Incorrect param type! cFolderName must be a non-empty string.")
				ok
			ok

		    acFolderPaths = This.DeepFindFolder(cFolderName)
	
		    # Sort by depth (deepest first) using Ring's sort
		    acSortedPaths = []
		    for cPath in acFolderPaths
		        nDepth = len(@split(cPath, This.Separator()))
		        acSortedPaths + [nDepth, cPath]
		    next
	
		    # Sort by depth descending (deepest first)
		    acSortedPaths = @sorton(acSortedPaths, 1)
		    acSortedPaths = reverse(acSortedPaths)
	
		    # Delete folders using Qt
	
			bResult = TRUE
	
		    for aPathInfo in acSortedPaths
		        cFolderPath = aPathInfo[2]
	
		        oTempDir = new QDir()
		        oTempDir.setPath(cFolderPath)
	
		        if oTempDir.exists_2()  # Check if directory exists
		            if NOT oTempDir.removeRecursively()  # Qt's safe recursive removal
		                bResult = FALSE
						exit
		            ok
		        ok
	
		        oTempDir.delete()
		    next
		
		    return bResult
	
			def DeepRemoveFolder(cFolderName)
				return This.DeepDeleteFolder(cFolderName)
	

	#===================#
	#  File Operations  #
	#===================#

	def FileRead(cFile)

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

		return @FileRead(cFile)

		def ReadFile(cFile)
			return This.FileRead(cFile)

	def FileReadQ(cFile)

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

		return @FileReadQ(cFile)

		def ReadFileQ(cFile)

			if CheckParams()
				if NOT ( isString(cFile) and trim(cFile) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok

			return This.FileReadQ(cFile)

	#--

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

		return @FileInfo(cFile)

		def FileInfoQ(cFile)
			cFile = This.NormaliseFilePathXT(cFile)
	
			if NOT This.Inside(cFile)
				raise("Can't navigate outside the folder!")
			ok
	
			if NOT This.Exists(cFile)
				raise("Can't read this file! cFile does not exist in the folder.")
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

		return @FileInfoXT(cFile)

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

		return @FileAppend(cFile, cAdditionalText)



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

			return @FileAppendQ(cFile, cAdditionalText)

		def AppendFile(cFile, cAdditionalText)
			return FileAppend(cFile, cAdditionalText)

			def AppendFileQ(cFile, cAdditionalText)
				return FileAppendQ(cFile, cAdditionalText)

	#--

	def FileCreate(cFile)

		if CheckParams()
			if NOT ( isString(cFile) and trim(cFile) != "" )
				StzRaise("Incorrect param type! cFile must be a non-empty string.")
			ok
		ok

		cFile = This.NormaliseFilePathXT(cFile)

		if This.IsPathOutside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if This.Exists(cFile)
			raise("Can't create this file! cFile already exists in the folder.")
		ok

		return @FileCreate(cFile)

		def FileCreateQ(cFile)
	
			if CheckParams()
				if NOT ( isString(cFile) and trim(cFile) != "" )
					StzRaise("Incorrect param type! cFile must be a non-empty string.")
				ok
			ok

			cFile = This.NormaliseFilePathXT(cFile)
	
			if This.IsPathOutside(cFile)
				raise("Can't navigate outside the folder!")
			ok
	
			if This.Exists(cFile)
				raise("Can't create this file! cFile already exists in the folder.")
			ok

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

		return @FileOverwrite(cFile, cNewContent)


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

			return @FileOverwriteQ(cFile, cNewContent)

		def OverwriteFile(cFile, cNewContent)
			return This.FileOverwrite(cFile, cNewContent)

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

		return @FileErase(cFile)


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

			return @FileEraseQ(This.cFile)

		def EraseFile(cFile)
			return This.FileErase(cFile)

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

		return @FileSafeErase(This.cFile)



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

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't delete this file! cFile does not exist in the folder.")
		ok

		bSuccess = @oQDir.remove(cFile)
		return bSuccess

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

		cFile = This.NormaliseFilePathXT(cFile)

		if NOT This.Inside(cFile)
			raise("Can't navigate outside the folder!")
		ok

		if NOT This.Exists(cFile)
			raise("Can't backup this file! cFile does not exist in the folder.")
		ok

		return @FileBackup(cFile)

		def BackupFile(cFile)
			return This.FileBackup(cfile)

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

		return @FileModify(cFile, cOldContent, cNewContent)

		def ModifyFile(cFile, cOldContent, cNewContent)
			return This.FileModify(cFile, cOldContent, cNewContent)

	def FileCopy(cSource, cDest)

		cSource = This.NormaliseFilePathXT(cSource)
		cDest = This.NormaliseFilePathXT(cDest)

		if NOT ( This.Inside(cSource) and This.Inside(cDest) )
			raise("Can't navigate outside the folder! Check that cSource and cDest are both inside.")
		ok

		if NOT This.Exists(cSource)
			raise("Can't copy the file! cSource does not exist in the folder.")
		ok

		if NOT This.Exists(cDest)
			raise("Can't copy the file! cDest does not exist in the folder.")
		ok

		return @FileCopy(cSource, cDest)

		def CopyFile(cSource, cDest)
			return this.FileCopy(cSource, cDest)

	def FileMove(cSource, cDest)

		cFile = This.NormaliseFilePathXT(csource)
		cDest = This.NormaliseFilePathXT(cDest)

		if NOT ( This.Inside(cSource) and This.Inside(cDest) )
			raise("Can't navigate outside the folder! Check that cSource and cDest are both inside.")
		ok

		if NOT This.Exists(cSource)
			raise("Can't move the file! cSource does not exist in the folder.")
		ok

		if NOT This.Exists(cDest)
			raise("Can't move the file! cDest does not exist in the folder.")
		ok

		return @FileMove(cSource, cDest)

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
			raise("Can't modify this file! cFile does not exist in the folder.")
		ok

		return @FileSize(cFile)

		def FileSizeInBytes(cFile)
			return this.FileSize(cFile)

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
				if lower(cFile) = lower(cPattern)
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

		if CheckParams()
			if NOT ( isString(cPattern) and trim(cPattern) != "" )
				StzRaise("Incorrect param type! cPattern must be a non-empty string.")
			ok
		ok

		cPattern = This.NormalizeFilePath(cPattern)
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
		if CheckParams()
			if NOT ( isString(cExt) and trim(cExt) != "" )
				StzRaise("Incorrect param type! cExt must be a non-empty string.")
			ok
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
			aEntries = @dir(cDir)
			for _aEntry_ in aEntries
				if _aEntry_[2] = 0
					if bWildcard
						if substr(lower(_aEntry_[1]), lower(cPattern)) > 0
							acFound + (cDir + This.Separator() + _aEntry_[1])
						ok
					else
						if lower(_aEntry_[1]) = lower(cPattern)
							acFound + (cDir + This.Separator() + _aEntry_[1])
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
			aEntries = @dir(cDir)
			for _aEntry_ in aEntries
				if _aEntry_[2] = 1 and _aEntry_[1] != "." and _aEntry_[1] != ".."
					if bWildcard
						if substr(lower(_aEntry_[1]), lower(cPattern)) > 0
							acFound + (cDir + This.Separator() + _aEntry_[1])
						ok
					else
						if lower(_aEntry_[1]) = lower(cPattern)
							acFound + (cDir + This.Separator() + _aEntry_[1])
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
		cFullPath = @oQDir.path() + This.Separator() + cFile
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
		cFolderPath = @oQDir.path() + This.Separator() + cFolder
		if isdir(cFolderPath)
			aEntries = @dir(cFolderPath)
			for _aEntry_ in aEntries
				if _aEntry_[2] = 0
					cFilePath = cFolderPath + This.Separator() + _aEntry_[1]
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
							acResults + [_aEntry_[1], acLineNumbers]
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

		acAllDirs = [ This.RootXT() ]
		acDeepFolders = This.DeepFoldersXT()
		nLen = len(acDeepFolders)

		for i = 1 to nLen
			acAllDirs + acDeepFolders[i]
		next

		acResult = []

		for cDir in acAllDirs
			aEntries = @dir(cDir)
			for _aEntry_ in aEntries
				if _aEntry_[2] = 0
					cFilePath = substr( cDir + This.Separator() + _aEntry_[1], "//", "/")
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
				aEntries = @dir(cFolderPath)
				for _aEntry_ in aEntries
					if _aEntry_[2] = 0
						cFilePath = cFolderPath + This.Separator() + _aEntry_[1]
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

	#-------------#
	#  MATCHINGS  #
	#-------------#

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
		cFullPath = @oQDir.path() + This.Separator() + cFile
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
		cFolderPath = @oQDir.path() + This.Separator() + cFolder
		if isdir(cFolderPath)
			aEntries = @dir(cFolderPath)
			for _aEntry_ in aEntries
				if _aEntry_[2] = 0
					cFilePath = cFolderPath + This.Separator() + _aEntry_[1]
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
				aEntries = @dir(cFolderPath)
				for _aEntry_ in aEntries
					if _aEntry_[2] = 0
						cFilePath = cFolderPath + This.Separator() + _aEntry_[1]
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
			aEntries = @dir(cDir)
			for _aEntry_ in aEntries
				if _aEntry_[2] = 0
					cFilePath = cDir + This.Separator() + _aEntry_[1]
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

	def ToString()
		cFolderName = This.Name()
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + NL

		cResult += This.GenerateVizTreeString(
			This.Path(), '', _TRUE_,
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
			This.Path(), '', _TRUE_, cStatPattern,
			"showxt", 0, This.MaxDisplayLevel()
		)

		return cResult

	def ShowXT()
		? This.ToStringXT()

	#-------------------------#
	#  Display Configuration  #
	#-------------------------#

	def Expand()
		@bExpand = _TRUE_
		@bDeepExpandAll = _FALSE_
		@acDeepExpandFolders = []

		@bCollapseAll = _FALSE_
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

	    @bCollapseAll = _FALSE_
	
		def ExpandTheseFolders(acFolders)
			This.ExpandFolders(acFolders)

		def ExpandThese(acFolders)
			This.ExpandTheseFolders(acFolders)

	#--

	def DeepExpandAll()
		@bExpand = _FALSE_
		@bDeepExpandAll = _TRUE_
		@acDeepExpandFolders = []

		@bCollapseAll = _FALSE_
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
		@bCollapseAll = _FALSE_
		@bDeepExpandAll = _FALSE_

		def DeepExpandTheseFolders(acFolders)
			This.DeepExpandFolders(acFolders)
	
		def DeepExpandThese(acFolders)
			This.DeepExpandTheseFolders(acFolders)

	#--

	def CollapseAll()
		@bCollapseAll = _TRUE_
		@bExpand = _FALSE_
		@bDeepExpandAll = _FALSE_

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
		@bExpand = _FALSE_
		@bDeepExpandAll = _FALSE_

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

	#==========================#
	#  Checking Path Security  #
	#==========================#
	#TODO // Enhance this section

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

	#===================#
	#  Utility Methods  #
	#===================#

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
			if cPath[i] = This.Separator()
				nPos = i
				exit
			ok
		next
		if nPos > 1
			return left(cPath, nPos - 1)
		else
			return This.Path()
		ok

	def GetPathHierarchy(cPath)
		acParts = []
		cRelativePath = substr(cPath, This.Path() + This.Separator(), "")
		if cRelativePath = cPath
			return []
		end
		acSegments = @split(cRelativePath, This.Separator())
		for cSegment in acSegments
			if cSegment != ""
				acParts + cSegment
			end
		next
		return acParts

	def CollectFoldersWithFileMatches(cPath, cPattern, aFoldersWithMatches)
		try
			_aList_ = @dir(cPath)
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
				This.CollectFoldersWithFileMatches(cPath + This.Separator() + _aEntry_[1], cPattern, aFoldersWithMatches)
			end
		next

		def GetFolderNameFromPath(cPath)
			if cPath = This.Path()
				return ""
			end
			nPos = max([substr(cPath, This.Separator()), substr(cPath, "\")])
			if nPos > 0
				return right(cPath, len(cPath) - nPos)
			end
			return cPath


	#================================#
	#  PRIVATE KITCHEN OF THE CLASS  #
	#================================#

	PRIVATE

	def SortItemsByDisplayOrder(aFiles, aFolders, cPath)

		aItems = []

		switch @cDisplayOrder

			case "systemorder"

				oQDirTemp = new QDir()
				oQDirTemp.setPath(cPath)
				oQDirTemp.setSorting(0)
				aQtEntries = oQDirTemp.entryList_2(3, 0)

				for i = 0 to aQtEntries.size() - 1
					c_aEntry_Name = aQtEntries.at(i)
					if c_aEntry_Name != "." and c_aEntry_Name != ".."
						cFullPath = cPath + This.Separator() + c_aEntry_Name
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

		_aList_ = @dir(cPath)
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

		cResult = lower(cStatPattern)
		
		# Replace pattern tokens with actual values

		nThisLevelFiles = oFolder.CountFiles()
		nThisLevelFolders = oFolder.CountFolders()
		nAllSubLevelFiles = oFolder.DeepCountFiles()
		nAllSubLevelFolders = oFolder.DeepCountFolders()
	
		if substr(cResult, "@countfiles")
			cResult = substr(cResult, "@countfiles", "" + nThisLevelFiles)
		ok
		
		if substr(cResult, "@deepcountfiles")
			cResult = substr(cResult, "@deepcountfiles", "" + nAllSubLevelFiles)
		ok
		
		if substr(cResult, "@countfolders")
			cResult = substr(cResult, "@countfolders", "" + nThisLevelFolders)
		ok
		
		if substr(cResult, "@deepcountfolders")
			cResult = substr(cResult, "@deepcountfolders", "" + nAllSubLevelFolders)
		ok
		
		# If tokens were replaced (custom pattern), handle zero filtering

		if cResult != cStatPattern

			# Split by comma and filter out zero values

			aTokens = @split(cResult, ",")
			acFiltered = []
			
			for cToken in aTokens
				cToken = trim(cToken)

				# Check if this token contains "0 files" or "0 folders"

				if not (substr(cToken, "0 files") or substr(cToken, "0 folders"))
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

		cFolderPath = @oQDir.absolutePath() + This.Separator() + cFolderName
		
		if @cDisplayStatPattern = "@count"

			# Simple count for default pattern

			try
				_aList_ = @dir(cFolderPath)
			catch
				return ""
			end
			
			nCount = 0
			for aEntry in _aList_
				if aEntry[1] != "." and aEntry[1] != ".."
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
		cFolderPath = @oQDir.absolutePath() + This.Separator() + cFolderName
		
		# Get actual counts for this folder

		nFiles = This.CountFilesIn(cFolderPath)
		nFolders = This.CountFoldersIn(cFolderPath)
		nDeepFiles = This.DeepCountFilesIn(cFolderPath)
		nDeepFolders = This.DeepCountFoldersIn(cFolderPath)
		
		# Replace patterns

		if substr(cResult, "@countfiles") or substr(cResult, "@countfiles")
			cResult = substr(cResult, "@countfiles", "" + nFiles)
			cResult = substr(cResult, "@countfiles", "" + nFiles)
		ok
		
		if substr(cResult, "@deepcountfiles")
			cResult = substr(cResult, "@deepcountfiles", "" + nDeepFiles)
		ok
		
		if substr(cResult, "@countfolders") or substr(cResult, "@countfolders")
			cResult = substr(cResult, "@countfolders", "" + nFolders)
			cResult = substr(cResult, "@countfolders", "" + nFolders)
		ok
		
		if substr(cResult, "@deepcountfolders")
			cResult = substr(cResult, "@deepcountfolders", "" + nDeepFolders)
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
			return _FALSE_
		end

		cFolderName = This.NormalizeFolderPath(cFolderName)

		# If DeepExpandAll is enabled, expand all non-empty folders

		if @bDeepExpandAll

			if This.IsFolderEmpty(cFolderName)
				return _FALSE_
			else
				return _TRUE_
			end

		end

		if @bExpand

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
	    
	    for aEntry in _aList_
	        if aEntry[2] = 0  # File
	            aFiles + aEntry[1]
	        but aEntry[2] = 1 and aEntry[1] != "." and aEntry[1] != ".."  # Folder
	            aFolders + aEntry[1]
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
	            cItemPath = cPath + This.Separator() + cItemName
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

		# If DeepExpandAll is enabled, expand all folders
		if @bDeepExpandAll
			return _TRUE_
		end
		
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
