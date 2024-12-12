	
/*

While Ring provides the following C-standard modes:

	"r" : Reading (The file must exist)
	"w" : writing (create empty file / overwrite)
	"a" : Appends (create file if it doesn’t exist)
	"r+": update (reading/writing)
	"w+": Create empty file (reading/writing)
	"a+": Reading & appending

And RingQt provides these modes for QFile and other QIODevice-based classes (supports unicode
file names):

	QIODevice_NotOpen
	QIODevice_ReadOnly
	QIODevice_WriteOnly
	QIODevice_ReadWrite
	return QIODevice_Append
	return QIODevice_Truncate
	return QIODevice_Text
	return QIODevice_Unbuffered

Softanza provides just three easy-to-recognize modes of opening files,
based on a subset of what is possible with RingQt (so we take advantage
from its support of UNICODE file names among other features):
UPDATE - Ring 1.16 supports UNICODE names for files!

	:ReadOnly	Reads file content	    ->	Works only for existing files (TODO: why?!)
	:WriteToEnd	Writes to the end of file   ->	If file do not exist, creates it
	:EraseAndWrite	Erases the file and writes  ->	If file do not exist, creates it

*/

_aFileOpeningModes = [
	:ReadOnly	= "QIODevice_ReadOnly", // Works only for existing files
	:WriteToEnd	= "QIODevice_Append",	// If file do not exist, creates it
	:EraseAndWrite	= "QIODevice_WriteOnly" // If file do not exist, creates it
]

func StzFile(cFile)
	return new stzFile(cFile)

func StzFileQ(cFile)
	return new stzFile(cFile)

func FileExists(pcFileName)
	oQFile = new QFile()
	oQFile.setFileName(pcFileName)

	bResult = oQFile.exists()
	oQfile.close()

	return bResult

class stzFile from stzObject
	cFile
	cOpenMode
	fPointer

	oQFile
	oQFileInfo

	oQTextStream

	  #---------------#
	 #   FILE INIT   #
	#---------------#

	def init(pcFile, pcOpenMode) # :ReadOnly :WriteToEnd :EraseAndWrite
		// Create the QFile object
		oQFile = new QFile()
		oQFile.setFileName(pcFile)

		switch pcOpenMode
		on :ReadOnly
			// Works only for existing files
			oQFile.open_3(QIODevice_ReadOnly | QIODevice_Text)

		on :WriteToEnd
			// If file do not exist, creates it
			oQFile.open_3(QIODevice_Append | QIODevice_Text)

		on :EraseAndWrite
			// If file do not exist, creates it
			oQFile.open_3(QIODevice_WriteOnly | QIODevice_Text)
		other
			StzRaise(stzFileError(:CanNotProceedWithOpeningMode))
		off
	
		// In all cases (file exists and has been successfully opened,
		// or it does not exist and it has been successfully created),
		// update the file object attributes...

		cFile = pcFile
		cOpenMode = pcOpenMode
		fPointer = oQFile.pObject
	
		// Create a QFileInfo object (used in the INFO section of the class)
		oQFileInfo = new QFileInfo()
		oQFileInfo.setFile(pcFile)

	  #-----------------------#
	 #   READ FILE CONTENT   #
	#-----------------------#

	// Returns the entire file content as a string
	def ReadAll()
		if This.IsReadable()
			return oQFile.readAll().data()
		else
			StzRaise(stzFileError(:CanNotReadFileContent))
		ok

		def Content()
			return This.ReadAll()

		def Value()
			return Content()

	// Returns the entire file content as a list of bytes
	def ReadAllAsListOfBytes()
		return new stzListOfBytes(This.ReadAll())

	// Returns the lines of the file content in a list
	def Lines()
		oTempStr = new stzString(This.Content())
		return oTempStr.Lines()

	// Returns the nth line of the file content
	def ReadLine(n)
		return This.Lines()[n]

	  #-------------------#
	 #   WRITE IN FILE   #
	#-------------------#

	/* This method behaves differently depending on the opening mode
	   	- :ReadOnly	 --> No effect
		- :WriteToEnd	 --> Appends the file
		- :EraseAndWrite --> Erases the file content and writes in it
	*/

	def Write(pcText)
		if This.IsWritable()
			oStr = new stzString(pcText)
			n = oStr.NumberOfChars()

			oQFile.write(pcText,n)
		else
			StzRaise(stzFileError(:CanNotWriteToFile))
		ok

	def WriteLine(pcText)
		if This.IsWritable()
			pcText + NL
			This.Write(pcText)
		else
			StzRaise(stzFileError(:CanNotWriteToFile))
		ok
	/*
	INFO:
	Currently, reading and writing work on the file directly (on QFile and
	on QIODevice in the background). In the future, use QStream instead.
	*/

	  #---------------------------#
	 #   RENAME, REMOVE & COPY   #
	#---------------------------#

	// Thes functions Work regardless of the opening mode used

	def Rename(pcNewName)
		if This.Exists()
			return oQfile.rename(pcNewName)
		else
			StzRaise(stzFileError(:CanNotRenameInexistantFile))
		ok

	def Remove()
		if This.Exists()
			return oQFile.remove()
		else
			StzRaise(stzFileError(:CanNotRemoveInexistantFile))
		ok

	def CopyAs(pcNewName)
		if FileExists(pcNewName)
			StzRaise(stzFileError(:CanNotCopyFileToExistantName))
		ok
		if This.Exists()
			return oQFile.copy(pcNewName)
		else
			StzRaise(stzFileError(:CanNotCopyInexistantFile))
		ok

	  #----------#
	 #   ِCLOSE  #
	#----------#

	def Close()
		try
			oQFile.close()
			return _TRUE_
		catch
			return _FALSE_
		done

	  #---------------#
	 #   FILE INFO   #
	#---------------#

	def Exists()
		return oQFile.exists()

	def Refresh()
		oQFileInfo.refresh()

	def OpeningMode()
		return cOpenMode

	def Pointer()
		return fPointer

	def File()
		return cFile

	def Size()	// In bytes?
		return oQFile.size()

	def IsWritable()
		return oQFile.isWritable()

	def IsReadable()
		return oQFile.isReadable()

	def IsExecutable()
		return oQFileInfo.isExecutable()

	def IsHidden()
		return oQFileInfo.isHidden()

	def IsShortcut()
		# Shortcuts only exist on Windows and are typically .lnk files
		return oQFileInfo.isShortcut()

	def ShortcutTarget()
		return oQFileInfo.symLinkTarget()

	def IsSymLink()
		# Symbolic links exist on Unix (including macOS and iOS) and Windows
		return oQFileInfo.isSymLink()

	def SymLinkTarget()
		return oQFileInfo.symLinkTarget()

	  #--------------------------------------------#
	 #   CREATION, MODIFICATION, & READING TIME   #
	#--------------------------------------------#

	def CreationTime()
		return oQFileInfo.created().toString("dd/MM/yyyy hh:mm:ss")

	def LastModificationTime()
		return oQFileInfo.lastModified().toString("dd/MM/yyyy hh:mm:ss")

	def LastReadingTime()
		return oQFileInfo.lastRead().toString("dd/MM/yyyy hh:mm:ss")

	  #----------------#
	 #   PATH & DIR   #
	#----------------#

	def FilePath()
		return oQFileInfo.dir().filePath(cFile)

	def FileAbsolutePath()
		return oQFileInfo.absoluteFilePath()

	def FileCanonicalPath()
		return oQFileInfo.canonicalFilePath()

	def DirName()
		return oQFileInfo.dir().dirname()

	def DirPath()
		return oQFileInfo.dir().path()

	def DirAbsolutePath()
		return oQFileInfo.absolutedir().AbsolutePath()

	def DirCanonicalPath()
		return oQFileInfo.canonicalPath()

#######################
	def IsRelative()
		return oQFileInfo.isRelative()

	def IsAbsolute()
		return oQFileInfo.isAbsolute()

	def IsRoot()
		return oQFileInfo.isRoot()
######################

	  #-----------------------#
	 #   BASENAME & SUFFIX   #
	#-----------------------#

	def BaseName()
		# Example: "/tmp/archive.tar" --> "archive"
		return oQFileInfo.basename()

	def CompleteBaseName()
		# Example: "/tmp/archive.tar.gz" --> "archive.tar"
		return oQFileInfo.completeBaseName()

	def Suffix()
		# Example: "/tmp/archive.tar" --> "tar"
		return oQFileInfo.suffix()

	def CompleteSuffix()
		# Example: "/tmp/archive.tar.gz" --> "tar.gz"
		return oQFileInfo.completeSuffix()

	  #--------------------------#
	 #   ZIPPING & EXTRACTING   #TODO
	#--------------------------#

	// See : https://ring-lang.sourceforge.io/doc1.15/ringzip.html

