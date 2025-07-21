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
#    Avoids Qt's raw entry count that includes "." + ".." + hidden files
#
# 4. ABSTRACTION LEVEL: High-level, intuitive behavior
#    - Users expect empty folder to show Count()=0, IsEmpty()=true
#    - Technical details (Qt entries, system files) handled internally
#

# Enhanced Functions - Global scope helpers
func IsFolder(cDir)
	return dirExists(cDir)

func StzFolderQ(cDir)
	return new stzFolder(cDir)

class stzFolder from stzObject
	@oQDir
	@cOriginalPath

	def init(pcDirPath)
		@oQDir = new QDir()
		@cOriginalPath = pcDirPath
		
		if pcDirPath = NULL or pcDirPath = ""
			@oQDir.setPath(".")
			@cOriginalPath = "."
			return
		end
		
		cCleanPath = QDir_cleanPath(NULL, pcDirPath)
		
		# If exists, just use it
		if dirExists(cCleanPath)
			@oQDir.setPath(cCleanPath)
			return
		end
		
		# Create if doesn't exist
		try
			oTempDir = new QDir()
			bCreated = oTempDir.mkpath(cCleanPath)
			
			if bCreated
				@oQDir.setPath(cCleanPath)
			else
				cParentPath = QDir_cleanPath(NULL, cCleanPath + "/..")
				if not dirExists(cParentPath)
					raise("Cannot create folder '" + cCleanPath + "' - parent folder '" + 
					      cParentPath + "' doesn't exist.")
				else
					raise("Cannot create folder '" + cCleanPath + 
					      "' - insufficient permissions or invalid path.")
				end
			end
			
		catch
			raise("Failed to create folder '" + cCleanPath + "': " + CatchError())
		end

		if not dirExists(cCleanPath)
			raise("Folder creation failed - '" + cCleanPath + "' doesn't exist after creation attempt.")
		end

	  #--------------------#
	 #  CONTENT & STATUS  #
	#--------------------#

	def Name()
		return @oQDir.dirName()

	def Path()
		return @oQDir.path()

	def AbsolutePath()
		return @oQDir.absolutePath()

		def FullPath()
			return This.AbsolutePath()

	def Count()
		return This.CountFiles() + This.CountFolders()

		def Size()
			return This.Count()

	def IsEmpty()
		return This.Count() = 0

		def Empty()
			return This.IsEmpty()

	def IsReadable()
		return @oQDir.isReadable()

	def IsRoot()
		return @oQDir.isRoot()

	def IsAbsolute()
		return @oQDir.isAbsolute()

	def Exists(cPath)
		if cPath = NULL or cPath = ""
			return @oQDir.exists_2()
		else
			return @oQDir.exists(cPath)
		end

	  #------------------#
	 #  FILE OPERATIONS #
	#------------------#

	def Files()
		mylist = ring_dir(@oQDir.path())
		aResult = []
		
		for entry in mylist
			if entry[2] = 0  # File
				aResult + entry[1]
			end
		next
		
		return aResult

	def Folders()
		mylist = ring_dir(@oQDir.path())
		aResult = []
		
		for entry in mylist
			if entry[2] = 1 and entry[1] != "." and entry[1] != ".."
				aResult + entry[1]
			end
		next
		
		return aResult

		def Dirs()
			return This.Folders()

		def SubFolders()
			return This.Folders()

	def CountFiles()
		return len(This.Files())

	def CountFolders()
		return len(This.Folders())

		def CountDirs()
			return This.CountFolders()

	def HasFiles()
		return This.CountFiles() > 0

		def ContainsFiles()
			return This.HasFiles()

	def HasFolders()
		return This.CountFolders() > 0

		def ContainsFolders()
			return This.HasFolders()

		def HasDirs()
			return This.HasFolders()

		def ContainsDirs()
			return This.HasFolders()

	def Contains(cName)
		# Check both files and folders
		aFiles = This.Files()
		aFolders = This.Folders()
		return (find(aFiles, cName) > 0) or (find(aFolders, cName) > 0)

		def Has(cName)
			return This.Contains(cName)

	def ContainsFile(cFileName)
		aFiles = This.Files()
		return find(aFiles, cFileName) > 0

	def ContainsFolder(cFolderName)
		aFolders = This.Folders()
		return find(aFolders, cFolderName) > 0

		def ContainsDir(cFolderName)
			return This.ContainsFolder(cFolderName)

	  #--------------------#
	 #  NAVIGATION        #
	#--------------------#

	def GoTo(cDir)
		if cDir = ".."
			return This.GoUp()
		end
		
		if not IsAbsolutePath(cDir)
			cFullPath = This.Path() + "/" + cDir
		else
			cFullPath = cDir
		end
		
		if not dirExists(cFullPath)
			raise("Cannot go to '" + cDir + "' - folder doesn't exist.")
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
		@oQDir.setPath(QDir_homePath())
		return This

	  #--------------------#
	 #  FOLDER CREATION   #
	#--------------------#

	def CreateFolder(pcDirName)
		if pcDirName = NULL or pcDirName = ""
			raise("Folder name cannot be empty.")
		end
		
		cFullPath = This.Path() + "/" + pcDirName
		
		if dirExists(cFullPath)
			return new stzFolder(cFullPath)  # Return existing folder
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

	def CreatePath(pcFullPath)
		if pcFullPath = NULL or pcFullPath = ""
			raise("Path cannot be empty.")
		end
		
		bSuccess = @oQDir.mkpath(pcFullPath)
		if not bSuccess
			raise("Could not create path: " + pcFullPath)
		end
		
		return new stzFolder(pcFullPath)

		def mkpath(pcFullPath)
			return This.CreatePath(pcFullPath)

	  #--------------------#
	 #  FOLDER REMOVAL    #
	#--------------------#

	def RemoveFolder(cFolderName)
		if cFolderName = NULL or cFolderName = ""
			raise("Please specify folder name to remove.")
		end
		
		if not This.ContainsFolder(cFolderName)
			raise("Folder '" + cFolderName + "' doesn't exist here.")
		end
		
		# Check if target folder is empty
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
			return This.RemoveFolder(cFolderName)

		def DeleteFolder(cFolderName)
			return This.RemoveFolder(cFolderName)

	def RemoveFile(cFileName)
		if cFileName = NULL or cFileName = ""
			raise("Please specify file name to remove.")
		end
		
		if not This.ContainsFile(cFileName)
			raise("File '" + cFileName + "' doesn't exist here.")
		end
		
		bSuccess = @oQDir.remove(cFileName)
		if not bSuccess
			raise("Could not remove file '" + cFileName + "'")
		end
		
		return This

		def DeleteFile(cFileName)
			return This.RemoveFile(cFileName)

	def RemoveRecursively()
		# Dangerous operation - keep serious name
		cMyPath = This.Path()
		
		bSuccess = @oQDir.removeRecursively()
		if not bSuccess
			raise("Could not remove folder and contents at '" + cMyPath + "'")
		end
		
		@oQDir = NULL  # Object invalid after removal
		return _TRUE_

		def DeleteRecursively()
			return This.RemoveRecursively()

	  #--------------------#
	 #  SEARCH & FILTER   #
	#--------------------#

	def Find(cPattern)
		# Search both files and folders
		aFiles = This.FindFiles(cPattern)
		aFolders = This.FindFolders(cPattern) 
		return [:Files = aFiles, :Folders = aFolders]

	def FindFiles(cPattern)
		if cPattern = NULL or cPattern = ""
			return This.Files()
		end
		
		aAllFiles = This.Files()
		aMatches = []
		
		for cFile in aAllFiles
			if This.Matches(cPattern, cFile)
				aMatches + cFile
			end
		next
		
		return aMatches

	def FindFolders(cPattern)
		if cPattern = NULL or cPattern = ""
			return This.Folders()
		end
		
		aAllFolders = This.Folders()
		aMatches = []
		
		for cFolder in aAllFolders
			if This.Matches(cPattern, cFolder)
				aMatches + cFolder
			end
		next
		
		return aMatches

	def FilesByExtension(cExt)
		if left(cExt, 1) != "."
			cExt = "." + cExt
		end
		
		mylist = ring_dir(@oQDir.path())
		aResult = []
		
		for entry in mylist
			cFileName = entry[1]
			nType = entry[2]
			
			if nType = 0 and right(cFileName, len(cExt)) = cExt
				aResult + cFileName
			end
		next
		
		return aResult

	  #--------------------#
	 #  DISPLAY & INFO    #
	#--------------------#

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

	def Show(nLevel)
		if nLevel = NULL
			nLevel = 0
		end
		
		cIndent = copy("  ", nLevel)
		? cIndent + "📁 " + This.Name()
		
		# Show files
		aFiles = This.Files()
		for cFile in aFiles
			? cIndent + "  📄 " + cFile
		next
		
		# Show subfolders
		aFolders = This.Folders()
		for cFolder in aFolders
			oSubFolder = new stzFolder(This.Path() + "/" + cFolder)
			oSubFolder.Show(nLevel + 1)
		next

	  #--------------------#
	 #  UTILITY METHODS   #
	#--------------------#

	def Copy()
		return new stzFolder(This.Path())

		def Clone()
			return This.Copy()

	def Refresh()
		@oQDir.refresh()
		return This

	# Internal helper
	def Matches(cFilter, cFileName)
		return QDir_match(@oQDir.ObjectPointer(), cFilter, cFileName)
