

class stzFile from stzObject
	cFile
	hFile

	cOpeningMode
	oFileOpeningMode

	oQFile
	oQFileInfo

	  #----------#
	 #   INIT   #
	#----------#

	def init(pcFile)
		cFile = pcFile

		hFile = fopen(pcFile, InMode(:ReadWrite))
		cOpeningMode = :ReadWrite
		
		oFileOpeningMode = new stzFileOpeningMode(This.OpeningMode())

		oQFile = new QFile()
		oQFile.setFileName(cFile)

		oQFileInfo = new QFileInfo()
		oQFileInfo.setFile(cFile)

	  #--------------------------#
	 #   CHANGE OPENING MODE    #
	#--------------------------#

	def ChangeOpeningModeTo(pcOpenMode)
		// Check if the provided open mode is supported
		oListOfOpenModes = new stzList(_aFileOpeningModes)
		if NOT oListOfOpenModes.Contains(pcOpenMode)
			StzRaise(stzFileError(:UnsupportedModeInOpeningFile))
		ok

		// Trying to change the opening mode
		try
			hFile = freopen(cFile, InMode(pcOpenMode), hFile)
			cOpeningMode = pcOpenMode
			return TRUE
		catch
			StzRaise(stzFileError(:CanNotChangeFileOpeneningMode2))
		done

	  #-----------#
	 #   ِCLOSE   #
	#-----------#

	def Close()
		try
			fclose(This.Handle())
			return TRUE
		catch
			return FALSE
		done

	  #---------------#
	 #   FILE INFO   #
	#---------------#

	def Exists()
		return fexists(cFile)

	def OpeningMode()
		return cOpeningMode

	def Refresh()
		oQFileInfo.refresh()

	def Handler()
		return hFile

	def File()
		return cFile

	def Size()
		return oQFileInfo.size()

	def IsTextFile()	# TODO: check if QMimeData() class could help
				# NB : QMimeType() is better but not supported in Ring 1.14
		if This.ContainsEndOfFile()
			return TRUE
		else
			return FALSE
		ok

	def IsBinaryFile()	# Idem
		if NOT This.ContainsEndOfFile()
			return TRUE
		else
			return FALSE
		ok

	  #------------------#
	 #   READ CONTENT   #
	#------------------#

	// Loading the content of the file :
	//	-> works independently from the opening mode
	//	-> works even if the file is closed!
	def Content()
		try
			return read(cFile)
		catch
			StzRaise( stzFileError(:CanNotLoadFileContent) )
		done

	def ReadLine()


	def ReadString()


	def ReadNBytes(n)
		if oFileOpeningMode.EnablesReading()
			if NOT This.IsEndOfFile()
				try
					return fread( This.Handler(), n )
				catch
					StzRaise( stzFileError(:CanNotReadFromFile) )
				done
			else
				StzRaise( stzError(:CanNotReadAfterEndOfFile) )
			ok
		else
			StzRaise( stzFileErrot(:CanNotReadFromFileInThisOpeningMode) )
		ok

	  #-------------------#
	 #   WRITE IN FILE   #
	#-------------------#

	// Changing the content of the file (ancient content is overwritten):
	//	-> works independently from the opening mode
	//	-> works even if the file is closed!
	def ChangeContent(pcContent)
		try
			write(cFile, pcContent)
			return TRUE
		catch
			StzRaise( stzFileError(:CanNotWriteContentToFile) )
		done

	def WriteLine(pcLine)


	def WriteString(pcString)


	  #--------------#
	 #   POSITION   #
	#--------------#

	def CurrentPosition()
		if NOT This.IsEndOfFile()
			return oQFile.pos()
		else
			StzRaise(stzFileError(:CanNotReadAfterEndOfFile))
		ok

	def SetPosition(n)
		if NOT This.IsEndOfFile()
			return oQFile.seek(n)
		else
			StzRaise(stzFileError(:CanNotWriteAfterEndOfFile))
		ok

	def IsEndOfFile()
		return oQFile.atEnd()


	  #----------------#
	 #   PERMISSION   #
	#----------------#

	def Permissions()
		return oQFileInfo.permissions()

	  #---------------------------#
	 #   RENAME, REMOVE & COPY   #
	#---------------------------#

	def ChangeName(pcNewName)

	def Remove()

	def CopyAs(pcNewName)
		if This.Exists()
			return oQFile.copy(pcNewName)
		else
			StzRaise( stzFileError(:CanNotCopyInexistantFile) )
		ok

	  #---------------#
	 #   SHORTCUTS   #
	#---------------#

	def SetShortcutToFile(pcTargetFileName)	
		if This.Exists() and FileExists(pcTargetFileName)
			return oQFile.symLinkTarget_2(pcTargetFileName)
		else
			StzRaise( stzFileError(:CanNotSetShorcutForInexistantFiles) )
		ok

	def SetAsShortcutOfFile(pcOtherFileName)
		if This.Exists() and FileExists(pcOtherFileName)
			return oQFile.link(pcOtherFileName)
		else
			StzRaise( stzFileError(:CanNotSetShortcutForInexistantFiles) )
		ok

	  #---------------------#
	 #   PRIVATE KITCHEN   #
	#---------------------#

	PRIVATE

	func InMode(pcOpenMode)
		switch pcOpenMode

		on :ReadOnly
			/*
			if the file exists
				Open it for reading only
			else
				return NULL
			ok
			*/
			return "r"

		on :WriteOnlyAtEnd
			/*
			if the file exists
				Open it for writing only at the end
			else
				Create a new empty file
			ok
			*/
			return "a"

		on :WriteOnlyOverwrite
			/*
			if the file exists
				Open it for writing only + overwrite its content
			else
				Create a new empty file (?)
			ok
			*/
			return "w"

		on :ReadWrite
			/*
			if the file exists
				Open it for reading and writing
			else
				return NULL
			ok
			*/
			return "r+"

		on :ReadWriteAtEnd
			/*
			if the file exists
				Open it for reading and writing at the end
			else
				Create a new empty file
			ok
			*/
			return "a+"

		on :ReadWriteOverwrite
			/*
			if the file exists
				Open it for reading and writing only + overwrite its content
			else
				Create a new empty file (?)
			ok
			*/
			return "w+"



		other
			StzRaise( stzFileError(:UnsupportedModeInOpeningTextFile) )
		
		off

