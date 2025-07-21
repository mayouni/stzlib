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

	func StzDirQ(cDir)
		return new stzFolder(cDir)

class stzDir from stzFolder

class stzFolder from stzObject
	@oQDir

	def init(pcDirPath)
		@oQDir = new QDir()
		if pcDirPath != NULL and pcDirPath != ""
			@oQDir.setPath(pcDirPath)
		end
	
	  #-----------#
	 #  CONTENT  #
	#-----------#

	def Name()
		return @oQDir.dirName()

		def DirName()
			return @oQDir.dirName()


	def Path()
		return @oQDir.path()

		def DirPath()
			return @oQDir.path()


	def AbsolutePath()
		return @oQDir.absolutePath()

		def FullPath()
			return @oQDir.absolutePath()

	def CanonicalPath()
		return @oQDir.canonicalPath()

	def RelativePath(cFile)
		return @oQDir.relativeFilePath(cFile)

		def RelativeFilePath(cFile)
			return @oQDir.relativeFilePath(cFile)

	def AbsoluteFilePath(cFile)
		return @oQDir.absoluteFilePath(cFile)

		def FullFilePath(cFile)
			return @oQDir.absoluteFilePath(cFile)

	def FilePath(cFile)
		return @oQDir.filePath(cFile)

	  #---------------------#
	 #  NAVIGATION METHODS #
	#---------------------#

	def cd(cDir)
		@oQDir.cd(cDir)
		return _TRUE_

		def ChangeDir(cDir)
			return This.cd(cDir)

		def ChangeTo(cDir)
			return This.cd(cDir)

		def GoTo(cDir)
			return This.cd(cDir)

		def MoveTo(cDir)
			return This.cd(cDir)

	def cdUp()
		@oQDir.cdUp()
		return _TRUE_

		def GoUp()
			return This.cdUp()

		def MoveUp()
			return This.cdUp()

		def Up()
			return This.cdUp()

	def SetPath(cPath)
		@oQDir.setPath(cPath)
		return _TRUE_

		def ChangePath(cPath)
			return This.SetPath(cPath)
	

	  #------------------#
	 #  CREATION METHODS #
	#------------------#

	def mkdir(pcDirName)
		@oQDir.mkdir(pcDirName)
		return _TRUE_

		def CreateDir(pcDirName)
			return This.mkdir(pcDirName)

		def CreateFolder(pcDirName)
			return This.mkdir(pcDirName)

		def Make(pcDirName)
			return This.mkdir(pcDirName)

		def Create(pcDirName)
			return This.mkdir(pcDirName)

	def mkpath(pcDirPath)
		@oQDir.mkpath(pcDirPath)
		return _TRUE_

		def CreatePath(pcDirPath)
			return This.mkpath(pcDirPath)

		def MakePath(pcDirPath)
			return This.mkpath(pcDirPath)

		def CreateFullPath(pcDirPath)
			return This.mkpath(pcDirPath)

	  #------------------#
	 #  REMOVAL METHODS #
	#------------------#

	def rmdir(cDirName)
		if cDirName = NULL or cDirName = ""
			@oQDir.rmdir(".")
		else
			@oQDir.rmdir(cDirName)
		end
		return _TRUE_

		def RemoveDir(cDirName)
			return This.rmdir(cDirName)

		def DeleteDir(cDirName)
			return This.rmdir(cDirName)

		def Remove(cDirName)
			return This.rmdir(cDirName)

		def Delete(cDirName)
			return This.rmdir(cDirName)

	def rmpath(cPath)
		@oQDir.rmpath(cPath)
		return _TRUE_

		def RemovePath(cPath)
			return This.rmpath(cPath)

		def DeletePath(cPath)
			return This.rmpath(cPath)

	def RemoveRecursively()
		@oQDir.removeRecursively()
		return _TRUE_

		def DeleteRecursively()
			return This.RemoveRecursively()

		def RemoveAll()
			return This.RemoveRecursively()

		def DeleteAll()
			return This.RemoveRecursively()

	def DeleteFile(cFile)
		@oQDir.remove(cFile)
		return _TRUE_

		def RemoveFile(cFile)
			return This.DeleteFile(cFile)

	def Rename(cOldName, cNewName)
		@oQDir.rename(cOldName, cNewName)
		return _TRUE_

		def RenameFile(cOldName, cNewName)
			return This.Rename(cOldName, cNewName)

	  #-----------------#
	 #  LISTING METHODS #
	#-----------------#

	def Count()
		return @oQDir.count()

		def CountFoldersAndFiles()
			return @oQDir.count()

		def CountFilesAndFolders()
			return @oQDir.count()

		def HowManyFoldersAndFiles()
			return @oQDir.count()

		def HowManyFilesAndFolders()
			return return @oQDir.count()

		#--

		def CountDirsAndFiles()
			return @oQDir.count()

		def CountFilesAndDirs()
			return @oQDir.count()

		def HowManyDirsAndFiles()
			return @oQDir.count()

		def HowManyFilesAndDirs()
			return return @oQDir.count()

		#--

		def CountDirectoriesAndFiles()
			return @oQDir.count()

		def CountFilesAndDirectories()
			return @oQDir.count()

		def HowManyDirectoriesAndFiles()
			return @oQDir.count()

		def HowManyFilesAndDirectories()
			return return @oQDir.count()


	def Files()
		mylist = ring_dir(@oQDir.path())
		aResult = []
		
		for entry in mylist
			if entry[2] = 0  # File
				aResult + entry[1]
			end
		next
		
		return aResult

	def CountFiles()
		return len(This.Files())

		def HowManyFiles()
			return This.CountFiles()

		def NumberOfFiles()
			return This.CountFiles()

	def Folders()
		mylist = ring_dir(@oQDir.path())
		aResult = []
		
		for entry in mylist
			if entry[2] = 1  # Directory
				aResult + entry[1]
			end
		next
		
		return aResult

		def Dirs()
			return This.Folders()

		def Directories()
			return This.Folders()

	def CountFolders()
		return len(This.Folders())

		def HowManyFolders()
			return This.CountFiles()

		def NumberOfFolders()
			return This.CountFiles()

		def CountDirs()
			return This.CountFiles()

		def NumberOfDirs()
			return This.CountFiles()

		def HowManyDirs()
			return This.CountFiles()

		def CountDirectories()
			return This.CountFiles()

		def NumberOfDirectories()
			return This.CountFiles()

		def HowManyDirectories()
			return This.CountFiles()

	def FilesByExtension(cExt)
		if left(cExt, 1) != "."
			cExt = "." + cExt
		end
		
		# Use Ring's ring_dir() function
		mylist = ring_dir(@oQDir.path())
		aResult = []
		
		for entry in mylist
			cFileName = entry[1]
			nType = entry[2]
			
			# Check if it's a file (type 0) and has correct extension
			if nType = 0 and right(cFileName, len(cExt)) = cExt
				aResult + cFileName
			end
		next
		
		return aResult

		def FilesByXT(cExt)
			return FilesByExtension(cExt)

	  #--------------------#
	 #  FILTERING METHODS #
	#--------------------#

	def SetFilter(nFilter)
		@oQDir.setFilter(nFilter)
		return _TRUE_

	def Filter()
		@oQDir.filter()
		return _TRUE_

	def SetNameFilters(aFilters)
		oStringList = new QStringList()
		for cFilter in aFilters
			oStringList.append(cFilter)
		next
		@oQDir.setNameFilters(oStringList)
		return _TRUE_

		def SetFilters(aFilters)
			return This.SetNameFilters(aFilters)

	def NameFilters()
		oStringList = @oQDir.nameFilters()
		aResult = []
		for i = 0 to oStringList.size() - 1
			aResult + oStringList.at(i)
		next
		return aResult

		def Filters()
			return NameFilters()

	  #------------------#
	 #  SORTING METHODS #
	#------------------#

	def SetSorting(nSort)
		@oQDir.setSorting(nSort)
		return _TRUE_

	def Sorting()
		return @oQDir.sorting()

	  #-----------------#
	 #  STATUS METHODS #
	#-----------------#

	def Exists(cPath)
		if cPath = NULL or cPath = ""
			return @oQDir.exists_2()
		else
			return @oQDir.exists(cPath)
		end

		def PathExists(cPath)
			return Exists(cPath)

		def DirExists(cPath)
			return Exists(cPath)

		def FolderExists(cPath)
			return Exists(cPath)

	def IsAbsolute()
		return @oQDir.isAbsolute()

		def IsAbsolutePath()
			return @oQDir.isAbsolute()

	def IsRelative()
		return @oQDir.isRelative()

		def IsRelativePath()
			return @oQDir.isRelative()

	def IsReadable()
		return @oQDir.isReadable()

		def CanRead()
			return @oQDir.isReadable()

	def IsRoot()
		return @oQDir.isRoot()

		def IsRootDir()
			return @oQDir.isRoot()

	def MakeAbsolute()
		return @oQDir.makeAbsolute()

		def ToAbsolute()
			return @oQDir.makeAbsolute()

	def Refresh()
		@oQDir.refresh()
		return _TRUE_
	

	  #-----------------#
	 #  STATIC METHODS #
	#-----------------#

	def CurrentPath()
		return QDir_currentPath(@oQDir.ObjectPointer())

		def CurrentDir()
			return QDir_currentPath(@oQDir.ObjectPointer())

	def HomePath()
		return QDir_homePath(@oQDir.ObjectPointer())

		def HomeDir()
			return QDir_homePath(@oQDir.ObjectPointer())

	def TempPath()
		return QDir_tempPath(@oQDir.ObjectPointer())

		def TempDir()
			return QDir_tempPath(@oQDir.ObjectPointer())

		def TemporaryPath()
			return QDir_tempPath(@oQDir.ObjectPointer())

	def RootPath()
		return QDir_rootPath(@oQDir.ObjectPointer())

		def RootDir()
			return QDir_rootPath(@oQDir.ObjectPointer())

	def SetCurrentPath(cPath)
		QDir_setCurrent(@oQDir.ObjectPointer(), cPath)
		return _TRUE_

		def SetCurrentDir(cPath)
			return QDir_setCurrent(@oQDir.ObjectPointer(), cPath)

	def CleanPath(cPath)
		QDir_cleanPath(@oQDir.ObjectPointer(), cPath)
		return _TRUE_

		def NormalizePath(cPath)
			return QDir_cleanPath(@oQDir.ObjectPointer(), cPath)

	def FromNativeSeparators(cPath)
		return QDir_fromNativeSeparators(@oQDir.ObjectPointer(), cPath)

	def ToNativeSeparators(cPath)
		return QDir_toNativeSeparators(@oQDir.ObjectPointer(), cPath)

	def Separator()
		oChar = QDir_separator(@oQDir.ObjectPointer())
		return oChar.unicode()

		def PathSeparator()
			oChar = QDir_separator(@oQDir.ObjectPointer())
			return oChar.unicode()

	def IsAbsolutePathXT(cPath)
		return QDir_isAbsolutePath(@oQDir.ObjectPointer(), cPath)

	def IsRelativePathXT(cPath)
		return QDir_isRelativePath(@oQDir.ObjectPointer(), cPath)

	def Match(cFilter, cFileName)
		return QDir_match(@oQDir.ObjectPointer(), cFilter, cFileName)

		def Matches(cFilter, cFileName)
			return QDir_match(@oQDir.ObjectPointer(), cFilter, cFileName)

		def FileMatches(cFilter, cFileName)
			return QDir_match(@oQDir.ObjectPointer(), cFilter, cFileName)

	  #------------------------#
	 #  SOFTANZA ENHANCEMENTS #
	#------------------------#

	def Show()
		? "Folder: " + This.Name()
		? "Path: " + This.Path()
		? "Absolute path: " + This.AbsolutePath()
		? "Entries count: " + This.Count()


		def Display()
			return Show()

		def Print()
			return Show()

	def Info()
		aInfo = [
			:Name = This.Name(),
			:Path = This.Path(),
			:AbsolutePath = This.AbsolutePath(),
			:CanonicalPath = This.CanonicalPath(),
			:Count = This.Count(),
			:IsAbsolute = This.IsAbsolute(),
			:IsReadable = This.IsReadable(),
			:IsRoot = This.IsRoot(),
			:Exists = This.Exists("")
		]
		return aInfo

		def DirInfo()
			return Info()

	def IsEmpty()
		return This.Count() = 0

		def Empty()
			return This.Count() = 0

	def IsNotEmpty()
		return This.Count() > 0

		def NotEmpty()
			return This.Count() > 0

		def HasContent()
			return This.Count() > 0

	def HasFiles()
		aFiles = This.FilesOnly()
		return len(aFiles) > 0

		def ContainsFiles()
			return HasFiles()

	def HasFolders()
		aFolders = This.FoldersOnly()
		return len(aFolders) > 0

		def HasSubDirs()
			return HasFolders()

		def ContainsFolders()
			return HasFolders()

		def ContainsSubDirs()
			return HasFolders()

	def FindFiles(cPattern)
		return EntryList([cPattern], 1, 0)

		def Search(cPattern)
			return FindFiles(cPattern)

		def Find(cPattern)
			return FindFiles(cPattern)

	def FindFolders(cPattern)
		return EntryList([cPattern], 2, 0)

		def FindDirs(cPattern)
			return FindFolders(cPattern)

	def Copy()
		return new stzFolder(This.Path())

		def Clone()
			return Copy()

	def SizeInBytes()
		# This would require recursive calculation
		# For now, return number of entries
		return This.Count()

	def TreeView(nLevel)
		if nLevel = NULL
			nLevel = 0
		end
		
		cIndent = copy("  ", nLevel)
		? cIndent + "📁 " + This.Name()
		
		# Show files
		aFiles = This.FilesOnly()
		for cFile in aFiles
			? cIndent + "  📄 " + cFile
		next
		
		# Show subdirectories
		aFolders = This.FoldersOnly()
		for cFolder in aFolders
			if cFolder != "." and cFolder != ".."
				oSubFolder = new stzFolder(This.Path() + "/" + cFolder)
				oSubFolder.TreeView(nLevel + 1)
			end
		next
		

		def Tree(nLevel)
			return TreeView(nLevel)

	#---------------------#
	# Qt internal method  #
	#---------------------#

	PRIVATE

	def EntryList(aNameFilters, nFilters, nSort)
		if aNameFilters = NULL
			aNameFilters = []
		end
		if nFilters = NULL
			nFilters = 0
		end
		if nSort = NULL
			nSort = 0
		end
	
		# Convert Ring array to QStringList for entryList(P1,P2,P3)
		oStringListFilters = new QStringList()
		for cFilter in aNameFilters
			oStringListFilters.append(cFilter)
		next
	
		# Use entryList(P1,P2,P3) method - requires QStringList, int, int
		oStringList = @oQDir.entryList(oStringListFilters, nFilters, nSort)
		aResult = []
		for i = 0 to oStringList.size() - 1
			aResult + oStringList.at(i)
		next
		return aResult


		def Entries(aNameFilters, nFilters, nSort)
			return EntryList(aNameFilters, nFilters, nSort)
