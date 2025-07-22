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

func IsAbsolutePath(cDir)
	return cDir = StzFolderQ(cDir).AbsolutePath()

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

	  #-------------------#
	 #  RECURSIVE COUNT  #
	#-------------------#

	def CountFilesXT()
	    return This.CountFilesRecursive(This.Path())
	
		def DeepCountFiles()
			return This.CountFilesXT()

	def CountFoldersXT() 
	    return This.CountFoldersRecursive(This.Path())
	
		def DeepCountFolders()
			return This.CountFoldersXT()

	def CountXT()
	    return This.CountFilesXT() + This.CountFoldersXT()
	
		def DeepCount()
			return This.CountXT()

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

	#---

	def Contains(cName)
		# Check both files and folders
		aFiles = This.Files()
		aFolders = This.Folders()
		return (ring_find(aFiles, cName) > 0) or (ring_find(aFolders, cName) > 0)

		def Has(cName)
			return This.Contains(cName)

	def ContainsFile(cFileName)
		aFiles = This.Files()
		return ring_find(aFiles, cFileName) > 0

	def ContainsFolder(cFolderName)
		aFolders = This.Folders()
		return ring_find(aFolders, cFolderName) > 0

		def ContainsDir(cFolderName)
			return This.ContainsFolder(cFolderName)

	#---

	def ContainsXT(cName)
	   return This.ContainsFileXT(cName) or This.ContainsFolderXT(cName)
	
	   def HasXT(cName)
	       return This.ContainsXT(cName)
	
		def DeepContains(cName)
			return This.ContainsXT(cName)

	def ContainsFileXT(cFileName)
	   return This.ContainsFileRecursive(This.Path(), cFileName)
	
		def DeepContainsFile(cName)
			return This.ContainsFileXT(cName)

	def ContainsFolderXT(cFolderName)
	   return This.ContainsFolderRecursive(This.Path(), cFolderName)
	
	   def ContainsDirXT(cFolderName)
	       return This.ContainsFolderXT(cFolderName)
	
		def DeepContainsFolder(cName)
			return This.ContainsXT(cName)

		def DeepContainsDir(cName)
			return This.ContainsXT(cName)

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


	def RemoveRecursivelyAll()
	    # Remove all files and folders inside, but keep the folder itself
	    
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

		#< @FunctionAlterativeForms

		def DeleteRecursivelyAll()
			return This.RemoveRecursivelyAll()

		def DeepRemoveAll()
			return This.RemoveRecursivelyAll()

		def DeepDeleteAll()
			return This.RemoveRecursivelyAll()

		def RemoveAllContent()
			return This.RemoveRecursivelyAll()

		def DeepRemoveContent()
			return This.RemoveRecursivelyAll()

		def DeleteAllContent()
			return This.RemoveRecursivelyAll()

		def DeepDeleteContent()
			return This.RemoveRecursivelyAll()

		#>

	  #--------------------#
	 #  SEARCH & FILTER   #
	#--------------------#

	def Find(cPattern)
		# Search both files and folders
		aFiles = This.FindFiles(cPattern)
		aFolders = This.FindFolders(cPattern) 
		return [:Files = aFiles, :Folders = aFolders]

		def FindFilesAndFolders(cPattern)
			return This.Find(cPattern)

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

	def Show()
		This.ShowXT(3)

	def ShowXT(nLevel)
		if nLevel = NULL
			nLevel = 0
		end
		
		cIndent = @copy("  ", nLevel)
		? cIndent + "╰─📁 " + This.Name()
		
		# Show files
		aFiles = This.Files()
		for cFile in aFiles
			? cIndent + "   ╰─📄 " + cFile
		next
		
		# Show subfolders
		aFolders = This.Folders()
		for cFolder in aFolders
			oSubFolder = new stzFolder(This.Path() + "/" + cFolder)
			oSubFolder.ShowXT(nLevel + 1)
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


	  #-----------------------------#
	 #  Private recursive helpers  #
	#-----------------------------#

	PRIVATE
	
	def CountFilesRecursive(cPath)

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
	            nCount += This.CountFilesRecursive(cPath + "/" + aList[i][1])
	        end

	    next
	    
	    return nCount
	
	def CountFoldersRecursive(cPath)
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
	            nCount += This.CountFoldersRecursive(cPath + "/" + aList[i][1])
	        end

	    next
	    
	    return nCount


	def ContainsFileRecursive(cPath, cFileName)
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
	           if This.ContainsFileRecursive(cPath + "/" + aList[i][1], cFileName)
	               return TRUE
	           end
	       end
	
	   next
	   
	   return FALSE


	def ContainsFolderRecursive(cPath, cFolderName)
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
	           if This.ContainsFolderRecursive(cPath + "/" + aList[i][1], cFolderName)
	               return TRUE
	           end
	       end
	   next
	   
	   return FALSE
