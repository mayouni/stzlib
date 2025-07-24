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

_nMaxTreeDisplayLevel = 5 #TODO //Move it to stzTree.ring and use it there

func DefaultMaxTreeDisplayLevel()
	return _nMaxTreeDisplayLevel

func SetDefaultMaxTreeDisplayLevel(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	_nMaxTreeDisplayLevel = n

# Enhanced Functions - Global scope helpers
func IsFolder(cDir)
	return dirExists(cDir) # A native Ring function

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
	
	@acDisplayChars = [

		# The folder tree lines use these chars
		:VerticlalChar = "│",
		:VerticalCharTick = "├",
		:ClosingChar = "╰",

		# File uses one of these two icons
		:File = " 🗋",		# file icon by default
		:FileFound = "📄",	# file icon when a file is found

		# Root folder uses one of these two icons
		:FolderRoot = "🗀",		# folder icon by default (when Show() is used)
		:FolderRootXT = "📁",	# folder icon when ShowXT() is used and an info
								# is added between parenthesis to the right

		# An expanded folder uses one of these two icons
		:FolderOpened = "🗁",		# when no found files exists inside it
		:FolderOpenedFound = "📂",	# when files are found inside it

		# A closed folder uses one of these two icons
		:FolderClosedEmpty = "🗀", 	# when the folder is empty
		:FolderClosedFull = "🖿",	# when the folder contains files

		# After a VizSearch use this icon in the root stat label
		:FolderRootSearchSymbol = "",

		# Each found file is proceeded by this icon
		:FileFoundSymbol = "👉"

	]

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

	def ContainsPath(cPath)
		if cPath = NULL or cPath = ""
			return @oQDir.exists_2()
		else
			return @oQDir.exists(cPath)
		end

		def Exists(cPath)
			return This.ContainsPath(cPath)

	  #-------------------#
	 #  FILE OPERATIONS  #
	#-------------------#

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

	  #------------------------------#
	 #  COUNTING FILES AND FOLDERS  #
	#------------------------------#

	def CountFiles()
		return len(This.Files())

		def NumberOfFiles()
			return len(This.Files())

		def HowManyFiles()
			return len(This.Files())

	def CountFile(cFileName)
		return len(This.FindFile(cFileName))

	#--- DEEP COUNT IN THE DEEP STRUCTURE OF THE FOLDER

	def DeepCount()
		 return This.DeepCountFiles() + This.DeepCountFolders()

		def DeepCountFilesAndFolders()
			return This.DeepCount()

		def DeepCountFoldersAndFiles()
			return This.DeepCount()

	def DeepCountFile(cFileName)
		return len(This.SearchFile(cFileName))

	def DeepCountFileIn(cFileName, cPath)
		return len(This.SearchFileIn(cFileName, cPath))

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
		     return 0  # Skip inaccessible directories
		 end

		 nLen = len(aList)

		for i = 1 to nLen

		     if aList[i][2] = 0  # File
		         nCount++

		     but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."  # Subfolder
		         nCount += This.DeepCountFilesIn(cPath + "/" + aList[i][1])
		     end

		 next
		 
		 return nCount

	#=== FOLDERS

	def CountFolders()
		return len(This.Folders())

		def CountDirs()
			return This.CountFolders()

	def CountFolder(cFolderName)
		return len(This.FindFolder(cFolderName))

	def DeepCountFolder(cFolderName)
		return len(This.SearchFolder(cFolderName))

	def DeepCountFolderIn(cFolderName, cPath)
		return len(This.SearchFolderIn(cFolderName, cPath))

	def DeepCountTheseFoldersIn(acFoldersNames, cPath)
		return len(This.SearchTheseFoldersIn(acFoldersNames, cPath))

	def DeepCountFolders() 
		 return This.DeepCountFoldersIn(This.Path())

	def DeepCountFoldersIn(cPath)
		 nCount = 0

		 try
		     aList = ring_dir(cPath)
		 catch
		     return 0  # Skip inaccessible directories
		 end

		 nLen = len(aList)

		for i = 1 to nLen

		     if aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."  # Subfolder
		         nCount++
		         nCount += This.DeepCountFoldersIn(cPath + "/" + aList[i][1])
		     end

		 next
		 
		 return nCount

	  #---------------------------------------------#
	 #  CHECKING CONTAINMENT OF FILES AND FOLDERS  #
	#---------------------------------------------#

	def Contains(cName)
		# Check both files and folders
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
		aFiles = This.Files()
		return ring_find(aFiles, cFileName) > 0

	def ContainsFolder(cFolderName)
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

	  #--------------------------------------------------#
	 #  CHECKING DEEP-CONTAINMENT OF FILES AND FOLDERS  #
	#--------------------------------------------------#

	def DeepContains(cName)
		if This.DeepContainsFileIn(cName, This.Path()) or
		   This.DeepContainsFolderIn(cName, This.Path())

			return TRUE
		else
			return FALSE
		ok

		def DeepContainsFileOrFolder(cName)
			return This.DeepContains(cName)

		def DeepContainsFolderOrFile(cName)
			return This.DeepContains(cName)

	def DeepContainsIn(cName, cPath)
		if This.DeepContainsFileIn(cName, cPath) or
		   This.DeepContainsFolderIn(cName,cPath)

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
	
		    if aList[i][2] = 0 and
				aList[i][1] = cFileName  # File found

		        return TRUE

		    but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1][1] != ".."  # Subfolder
		        if This.DeepContainsFileIn(cFileName, cPath + "/" + aList[i][1])
		            return TRUE
		        end
		    end
	
		next
		
		return FALSE

	#--

	def DeepContainsTheseFiles(acFilesNames)
		return This.DeepContainsTheseFilesIn(acFilesnames, This.Path())

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

	#---

	def DeepContainsOneOfTheseFiles(acFilesNames)
		return This.DeepContainsTheseFilesIn(acFilesnames, This.Path())

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

	#==

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
	
		    if aList[i][2] = 1 and aList[i][1] = cFolderName  # Folder found
		        return TRUE
	
		    but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."  # Subfolder
		        if This.DeepContainsFolderIn(cFolderName, cPath + "/" + aList[i][1])
		            return TRUE
		        end
		    end
		next
		
		return FALSE

	#--

	def DeepContainsTheseFolders(acFoldersNames)
		return This.DeepContainsTheseFoldersIn(acFoldersnames, This.Path())

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

	#---

	def DeepContainsOneOfTheseFolders(acFoldersNames)
		return This.DeepContainsTheseFoldersIn(acFoldersnames, This.Path())

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

	  #--------------#
	 #  NAVIGATION  #
	#--------------#

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
		@oQDir.setPath(@oQDir.homePath())

		def GoToHome()
			@oQDir.setPath(@oQDir.homePath())

		def GoToRoot()
			@oQDir.setPath(@oQDir.homePath())

		def GoRoot()
			@oQDir.setPath(@oQDir.homePath())

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

	def ResolvePath(cPath)
		 if cPath = NULL or cPath = ""
		     raise("Path cannot be empty")
		 end
		 
		 # If already absolute, return as-is
		 if IsAbsolutePath(cPath)
		     return cPath
		 end
		 
		 # If relative, combine with current folder path
		 cCurrentPath = This.AbsolutePath()
		 
		 # Handle path separators
		 if right(cCurrentPath, 1) != "/" and right(cCurrentPath, 1) != "\"
		     cCurrentPath += "/"
		 end
		 
		 return cCurrentPath + cPath

	  #------------------#
	 #  MANAGING FILES  #
	#------------------#

	def FileExists(cFile)
		return @FileExists(This.ResolvePath(cFile))

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

	def FileCreate(cFile)
		return @FileCreate(This.ResolvePath(cFile))

		def FileCreateQ(cFile)
			return @FileCreateQ(This.ResolvePath(cFile))
	
		def CreateFile(cFile)
			return This.FileCreate(cFile)

			def CreateFileQ(cFile)
				return This.FileCreateQ(cFile)

	def FileOverwrite(cFile, cNewContent)
		return @FileOverwrite(This.ResolvePath(cFile), cNewContent)

		def FileOverwiteQ(cFile, cNewContent)
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
			return @FileSafeEraseQ(This.ResolvePath(cFile))
	
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

	  #---------------------------#
	 #  REMOVING A GIVEN FOLDER  #
	#---------------------------#

	def DeleteFolder(cFolderName)
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
			return This.DeleteFolder(cFolderName)

		def RemoveFolder(cFolderName)
			return This.deleteFolder(cFolderName)

	  #-----------------------------#
	 #  ERASING FOLDER COMPLETELY  #
	#-----------------------------#

	def Erase()
		 # Remove all files and folders inside, but keep the folder itself
		 # Dangerous operation! Use it responsibely.

		 try
		     # Remove all files
		     aFiles = This.Files()
			nLen = len(aFiles)

			for i = 1 to nLen
		         bSuccess = @oQDir.remove(aFiles[i])
		         if not bSuccess
		             raise("Could not remove file '" + aFiles[i] + "'")
		         end
		     next
		     
		     # Remove all subfolders recursively
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

		def DeepRemoveAll()
			This.Erase()

	  #------------------------------#
	 #  FINDING FILES AND FOLDERS   #
	#------------------------------#

	def Find(cName)
		/* ... */

	def FindFile(cFileName)
		/* ... */

	def FindFiles(acFilesNames)
		/* ... */

	def FindFolder(cFolderName)
		/* ... */

	def FindFolders(cPattern)
		/* ... */

	def FindFilesByExtension(cExt)
		/* ... */

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

	#---

	def DeepFind(cFileOrFolderName)
		/* ... */

		def DeepFindFileOrFolder(cFileOrFolderName)
			return This.DeepFind(cFileOrFolderName)

	def DeepFindFile(cFileName)
		/* ... */

		def DeepFindThisFile(cFileName)
			return This.DeepFindFile(cFileName)

	def DeepFindFolder(cFolderName)
		/* ... */

		def DeepFindThisFolder(cFolderName)
			return This.DeepFindFolder(cFolderName)

	def DeepFindFiles(acFilesNames)
		/* ... */

		def DeepFindTheseFiles(acFilesNames)
			return This.DeepFindFiles(acFilesNames)

	def DeepFindFolders(acFoldersNames)
		/* ... */

		def DeepFindTheseFolders(acFoldersNames)
			return this.DeepFindFolders(acFoldersNames)

	#---

	def Search(cPattern)
		return This.SearchIn(cPattern, This.Path())

		def SearchFilesOrFolders(cPattern)
			return This.Search(cPattern)

		def SearchFoldersOrFiles(cPattern)
			return This.Search(cPattern)

	def SearchFiles(cPattern)
		return This.SearchFilesIn(cPattern, This.Path())

	def SearchFilesIn(cPath)

		 acResult = []

		 try
		     aList = ring_dir(cPath)
		 catch
		     return []  # Skip inaccessible directories
		 end

		 nLen = len(aList)

		for i = 1 to nLen

		     if aList[i][2] = 0  # File
		         nCount++

		     but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."  # Subfolder
		        acTemp = This.SearchFilesIn(cPath + "/" + aList[i][1])
				nLenTemp = len(acTemp)
				for j = 1 to nLenTemp
					acResult + acTemp[j]
				next
		     end

		 next

		 return acResult

	#--

	def SearchFolders(cPattern)
		return This.SearchFoldersIn(cPattern, This.Path())

	def SearchFoldersIn(cPath)

		 acResult = []

		 try
		     aList = ring_dir(cPath)
		 catch
		     return []  # Skip inaccessible directories
		 end

		 nLen = len(aList)

		for i = 1 to nLen

		     if aList[i][2] = 0  # File
		         nCount++

		     but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."  # Subfolder
		        acTemp = This.SearchFoldersIn(cPath + "/" + aList[i][1])
				nLenTemp = len(acTemp)
				for j = 1 to nLenTemp
					acResult + acTemp[j]
				next
		     end

		 next

		 return acResult

	  #-----------------#
	 #  VISUAL SEARCH  #
	#-----------------#

	def VizSearch(cPattern)
		# Search both files and folders and visualize results
		nTotalFileMatches = This.CountFileMatchesRecursive(This.Path(), cPattern)
		nTotalFolderMatches = This.CountFolderMatchesRecursive(This.Path(), cPattern)
		nTotalMatches = nTotalFileMatches + nTotalFolderMatches
		
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + " (" +
			@acDisplayChars[:FolderRootSearchSymbol] + "" +
			 nTotalMatches + " matches for '" +
			cPattern + "')" + nl
		
		cResult += This.GenerateVizTreeString(
			This.Path(), "", _TRUE_, cPattern, "both", 0,
			This.MaxDisplayLevel())
			
		return cResult

		def VizSearchFilesAndFolders(cPattern)
			return This.VizSearch(cPattern)

	def VizSearchFiles(cPattern)
		# Search files only and visualize results with focused display
		nTotalMatches = This.CountFileMatchesRecursive(This.Path(), cPattern)
		
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		
		cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName +
			" (" + @acDisplayChars[:FolderRootSearchSymbol] + "" + nTotalMatches +
			" file matches for '" +
			cPattern + "')" + nl
		
		# Force focused display - collapse all then expand only folders with matches
		This.CollapseAll()
		acFoldersWithMatches = This.GetFoldersContainingFileMatches(This.Path(), cPattern)
		if len(acFoldersWithMatches) > 0
			This.ExpandFolders(acFoldersWithMatches)
		end
		
		cResult += This.GenerateVizTreeString(
			This.Path(), "",
			_TRUE_, cPattern, "files", 0,
			This.MaxDisplayLevel())

		return cResult

	def VizSearchFolders(cPattern)
		# Search folders only and visualize results
		nTotalMatches = This.CountFolderMatchesRecursive(This.Path(), cPattern)
		
		cFolderName = This.Name()
		if cFolderName = ""
			cFolderName = This.Path()
		end
		
		cResult = "📁 " + cFolderName + " (" + @acDisplayChars[:FolderRootSearchSymbol] + 
			+ "  " + nTotalMatches + " folder matches for '" +
			cPattern + "')" + nl
		
		cResult += This.GenerateVizTreeString(
			This.Path(), "", _TRUE_, cPattern, "folders", 0,
			This.MaxDisplayLevel())
			
		return cResult

		def VizSearchDirs(cPattern)
			return This.VizSearchFolders(cPattern)

	  #--------------#
	 #  FOLDER NFO  #
	#--------------#

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

	  #-----------------------#
	 #  FOLDER TREE DISPLAY  #
	#-----------------------#

	def ExpandAll()
		@bExpandAll = _TRUE_
		@bCollapseAll = _FALSE_
		@acCollapseFolders = []
	
		def Expand()
			This.ExpandAll()

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

	def CollapseAll()
		@bCollapseAll = _TRUE_
		@bExpandAll = _FALSE_
		@acExpandFolders = []

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
			StzRaise("Incorrect stat pattern! cPattern must contain at least" +
					 " one of these keywords: " + @@(This.StatKeywords()) )
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
		
		acValidOrders = [
			"systemorder",
			"filefirstascending", 
			"filefirstdescending",
			"folderfirstascending",
			"folderfirstdescending"
		]
		
		if NOT ring_find(acValidOrders, lower(cOrder))
			StzRaise("Invalid display order! Must be one of: " + @@(acValidOrders))
		ok
		
		@cDisplayOrder = lower(cOrder)

	def Show()
	    cFolderName = This.Name()
	    if cFolderName = ""
	        cFolderName = This.Path()
	    end
	    
	    # FIX 1: Use FolderRoot (🗀) for Show() method
	    cResult = @acDisplayChars[:FolderRoot] + " " + cFolderName + nl

	    cResult += This.GenerateVizTreeString(
			This.Path(), "", _TRUE_, '',
			"", 0,
			This.MaxDisplayLevel())

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
	    # FIX 1: Use FolderRootXT (📁) for ShowXT() method
	    cResult = @acDisplayChars[:FolderRootXT] + " " + cFolderName + " " + cStats + nl

	    # FIX 2: Pass the stat pattern to GenerateVizTreeString for inner folder stats
	    cResult += This.GenerateVizTreeString(
			This.Path(), "", _TRUE_, cStatPattern,
			"showxt", 0,
			This.MaxDisplayLevel() )

	    return cResult

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

	def Matches(cFilter, cFileName)
		return QDir_match(@oQDir.ObjectPointer(), cFilter, cFileName)

def GetFoldersContainingFileMatches(cPath, cPattern)
	aAllPaths = []
	This.CollectFoldersWithFileMatches(cPath, cPattern, aAllPaths)
	
	# Extract all unique folder names from paths
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
	if cRelativePath = cPath  # No substitution occurred
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
   	mylist = ring_dir(cPath)
   catch
   	return
   end
   
   bHasFileMatches = _FALSE_
   
   # Check files in current folder
   for entry in mylist
   	if entry[2] = 0  # File
   		if This.Matches(cPattern, entry[1])
   			bHasFileMatches = _TRUE_
   			exit
   		end
   	end
   next
   
   # If current folder has matches, add its full path
   if bHasFileMatches
   	aFoldersWithMatches + cPath
   end
   
   # Recurse into subfolders
   for entry in mylist
   	if entry[2] = 1 and entry[1] != "." and entry[1] != ".."
   		This.CollectFoldersWithFileMatches(cPath + "/" + entry[1], cPattern, aFoldersWithMatches)
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

	  #-----------------------------#
	 #  Private recursive helpers  #
	#-----------------------------#

	PRIVATE
	
	#--- Private methods for folder display


	def SortItemsByDisplayOrder(aFiles, aFolders, cPath)
	    aItems = []
	    
	    switch @cDisplayOrder
	        case "systemorder"

	            # Use Qt's system order

				# By "systemorder" we mean the natural filesystem
				# order, not Windows Explorer's (or equivalent in
				# other OSs) current display order.

				oQDirTemp = new QDir()
	            oQDirTemp.setPath(cPath)
	            oQDirTemp.setSorting(0)  # QDir::Unsorted for natural system order
	            aQtEntries = oQDirTemp.entryList_2(3, 0) #   # QDir::Files | QDir::Dirs, QDir::Unsorted
	            
	            for i = 0 to aQtEntries.size() - 1
	                cEntryName = aQtEntries.at(i)
	                if cEntryName != "." and cEntryName != ".."
	                    cFullPath = cPath + "/" + cEntryName
	                    if isdir(cFullPath)
	                        aItems + [cEntryName, "folder"]
	                    else
	                        aItems + [cEntryName, "file"]
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
	    mylist = ring_dir(cPath)
	    aResult = []
	    for entry in mylist
	        if entry[2] = 0
	            aResult + [:name = entry[1], :type = "file"]
	        elseif entry[2] = 1 and entry[1] != "." and entry[1] != ".."
	            aResult + [:name = entry[1], :type = "folder"]
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

		
		# Handle special cases
		if cStats = "..."
		    return " (...)"
		end
		
		return " (" + cStats + ")"


	#--- Private method for visual search tree generation

	def CountFileMatchesRecursive(cPath, cPattern)
		nCount = 0
		
		try
			aList = ring_dir(cPath)
		catch
			return 0
		end
		
		nLen = len(aList)
		
		for i = 1 to nLen
			if aList[i][2] = 0  # File
				if This.Matches(cPattern, aList[i][1])
					nCount++
				end
			but aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."  # Subfolder
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
			if aList[i][2] = 1 and aList[i][1] != "." and aList[i][1] != ".."  # Subfolder
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
			# Check if specifically collapsed
			for cPattern in @acCollapseFolders
				if This.Matches(cPattern, cFolderName)
					return _FALSE_
				end
			next
			
			# FIXED: Only expand folders that actually have content
			if This.IsFolderEmpty(cFolderName)
				return _FALSE_  # Don't expand empty folders
			else
				return _TRUE_   # Expand non-empty folders
			end
		end
		
		# Check if specifically expanded
		for cPattern in @acExpandFolders
			if This.Matches(cPattern, cFolderName)
				return _TRUE_
			end
		next
		
		return _FALSE_  # Default behavior

	def IsFolderEmpty(cFolderName)
		cFolderPath = This.Path() + "/" + cFolderName
		oTempFolder = new stzFolder(cFolderPath)
		bHasFiles = oTempFolder.CountFiles() > 0
		bHasFolders = oTempFolder.CountFolders() > 0
		return (not bHasFiles and not bHasFolders)

	def GetFolderIconForExpanded(cFolderName, bSubfolderHasMatches, bIsEmpty)
		if bSubfolderHasMatches
			return @acDisplayChars[:FolderOpenedFound]  # 📂 - Expanded folder with search matches
		else
			return @acDisplayChars[:FolderOpened]       # 🗁 - Regular expanded folder
		end

	def GetFolderIconForCollapsed(bIsEmpty)
		if bIsEmpty
			return @acDisplayChars[:FolderClosedEmpty]  # 🗀 - Empty folder (collapsed)
		else
			return @acDisplayChars[:FolderClosedFull]   # 🖿 - Non-empty folder (collapsed)
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
	            bShouldExpand = This.ShouldExpandFolder(cItemName) or bSubfolderHasMatches
	            
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
