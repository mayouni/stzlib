	

/*
Intent-Based File API for Softanza v2.0
=======================================

FUNDAMENTAL PRINCIPLE: Every file interaction includes read capability.
Just like opening a physical notebook - regardless of your intent (reading, writing, 
updating), you can always read what's already there.

Philosophy:
- Every file handler provides full read access
- Write capabilities are intent-specific and clearly named
- Safety through explicit intent, not artificial restrictions
- Natural mental model: "I can always see what's in the file"
*/

_aFileOpeningModes = [
	:ReadOnly	= "QIODevice_ReadOnly", 		# Works only for existing files
	:WriteToEnd	= "QIODevice_Append",	# If file do not exist, creates it
	:EraseAndWrite	= "QIODevice_WriteOnly"	# If file do not exist, creates it
]

func IsDir(cDir)
	return dirExists(cDir)

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

#==================================#
# FACTORY FUNCTIONS (INTENT-BASED) #
#==================================#

func FileRead(cFileName)
    # Pure reading intent - read-only access
    return new stzFileReader(cFileName)

func FileAppend(cFileName) 
    # Intent to add to end - can read + append
    return new stzFileAppender(cFileName)

func FileCreate(cFileName)
    # Intent to create new - can read + write (fails if exists)
    return new stzFileCreator(cFileName)

func FileOverwrite(cFileName)
    # Intent to replace entirely - can read + overwrite
    return new stzFileOverwriter(cFileName)

func FileUpdate(cFileName)
    # Intent to modify existing - can read + sophisticated updates
    return new stzFileUpdater(cFileName)

#==================================#
# IMMEDIATE OPERATIONS (NO OBJECT) #
#==================================#

func FileReplace(cFileName, cNewContent)
    # Immediate operation - replaces entire file content
    if not FileExists(cFileName)
        StzRaise("Cannot replace content of non-existent file: " + cFileName)
    ok
    
    oFile = new QFile(cFileName)
    oFile.open_3(QIODevice_WriteOnly | QIODevice_Truncate | QIODevice_Text)
    oFile.write(cNewContent, len(cNewContent))
    oFile.close()
    return _TRUE_

func FileSafeOverwrite(cFileName, cNewContent)
    # Creates timestamped backup before overwriting
    if FileExists(cFileName)
        cBackup = cFileName + ".backup." + TimeStamp()
        FileCopy(cFileName, cBackup)
    ok
    return FileReplace(cFileName, cNewContent)

func FileCopy(cSource, cDestination)
    if not FileExists(cSource)
        StzRaise("Cannot copy non-existent file: " + cSource)
    ok
    oSource = new QFile(cSource)
    return oSource.copy(cDestination)

func FileMove(cSource, cDestination)
    if not FileExists(cSource)
        StzRaise("Cannot move non-existent file: " + cSource)
    ok
    oSource = new QFile(cSource)
    return oSource.rename(cDestination)

func FileRemove(cFileName)
    if not FileExists(cFileName)
        StzRaise("Cannot Remove non-existent file: " + cFileName)
    ok
    oFile = new QFile(cFileName)
    return oFile.remove()

func FileSize(cFileName)
    if not FileExists(cFileName)
        StzRaise("Cannot get size of non-existent file: " + cFileName)
    ok
    oFile = new QFile(cFileName)
    return oFile.size()

#====================================#
# BASE READING CAPABILITIES (MIXIN)  #
#====================================#

class stzFileReadingMixin from stzObject
    # This mixin provides universal reading capabilities
    # to all file handler classes
    
    def Content()
        # Get current content from file
        nCurrentPos = @oQFile.pos()
        @oQFile.seek(0)
        cContent = @oQFile.readAll().data()
        @oQFile.seek(nCurrentPos)
        return cContent
        
        def AllContent()
            return This.Content()
    
    def Lines()
        return @Lines(This.Content())
        
        def AllLines()
            return This.Lines()
    
    def Line(n)
        return This.Lines()[n]
    
		def lineN(n)
			return This.Line(n)

		def NthLine(n)
			return This.Line(n)

    def FirstLine()
        return This.Line(1)
    
    def LastLine()
        aLines = This.Lines()
        return aLines[len(aLines)]
    
    def NumberOfLines()
        return len(This.Lines())
    
		def HowManyLine()
			return len(This.Lines())

		def CountLines()
			return len(This.Lines())

    def ContentAsBytes()
        return StzListOfBytesQ(This.Content())
    
    def Size()
        return @oQFile.size()
    
		def SizeInBytes()
			return This.Size()

    def IsEmpty()
        return This.Size() = 0
    
    def FileName()
        return @cFileName
    
    def FindText(cSearchText)
        # Returns position of text in file, or 0 if not found
        cContent = This.Content()
        return substr(cContent, cSearchText)
    
    def ContainsText(cSearchText)
        return This.FindText(cSearchText) > 0
    
    def CountOccurrences(cSearchText)
        return StzStringQ(This.Content()).NumberOfOccurrences(cSearchText)
    
		def NumberOfOccurrences(cSearchText)
			return This.CountOccurrences(cSearchText)

		def NumberOfOccurrence(cSearchText)
			return This.CountOccurrences(cSearchText)

    def LinesContaining(cSearchText)
        aLines = This.Lines()
        aResult = []
	   nLen = len(aLines)
        for i = 1 to nLen
            if substr(aLines[i], cSearchText) > 0
                aResult + [i, aLines[i]]
            ok
        next
        return aResult
    
    def LineNumber(cSearchText)
        # Returns line number containing the text
        aLines = This.Lines()
	   nLen = len(aLines)
        for i = 1 to nLine
            if substr(aLines[i], cSearchText) > 0
                return i
            ok
        next
        return 0

#====================================#
# READER CLASS - PURE READING INTENT #
#====================================#

class stzFileReader from stzFileReadingMixin
    @cFileName
    @oQFile
    
    def init(cFileName)
        if not FileExists(cFileName)
            StzRaise("Cannot read non-existent file: " + cFileName)
        ok
        
        @cFileName = cFileName
        @oQFile = new QFile()
	   @oQfile.setFileName(cFileName)
        @oQFile.open_3(QIODevice_ReadOnly | QIODevice_Text)
    
    def Close()
        @oQFile.close()

#========================================#
# APPENDER CLASS - READ + APPEND INTENT  #
#========================================#

class stzFileAppender from stzFileReadingMixin
    @cFileName
    @oQFile
    
    def init(cFileName)
        @cFileName = cFileName
        @oQFile = new QFile()
	   @oQFile.setFileName(cFileName)
        @oQFile.open_3(QIODevice_ReadWrite | QIODevice_Append | QIODevice_Text)
    
    # WRITE METHODS (intent-specific)
    def Write(cText)
        @oQFile.write(cText, len(cText))

		def WrtiteQ(cText)
			This.Write(cText)
			return This
    
    def WriteLine(cText)
        This.Write(cText + NL)
    
		def WriteLineQ(cText)
		This.WriteLine(cText)
		return This

    def WriteLines(aLines)
	   nLen = len(aLines)
        for i = 1 to nlen
            This.WriteLine(aLines[i])
        next
        
	   def WrtiteLinesQ(aLines)
		This.WriteLines(aLines)
		return This
    
    def WriteTimestamp()
        cTimeStamp = TimeStamp()
        This.Write(cTimeStamp + ": ")
    
	   def WriteTimeStampQ()
		This.WriteTimeStamp()
		return This

    def WriteLogEntry(cMessage)
        cTimeStamp = TimeStamp()
        This.WriteLine(cTimeStamp + " - " + cMessage)
    
	   def WriteLogEntryQ(cMessage)
		This.WriteLogEntryQ(cMessage)
		return This

    def WriteSeparator(cChar)
        if cChar = NULL
            cChar = "-"
        ok
        This.WriteLine(@Copy(cChar, 50))
    
	   def WriteSeparatorQ(cChar)
		This.WriteSeparator(cChar)
		return This

    def WriteBlankLine()
        This.WriteLine("")
    
	   def WriteBlankLineQ()
		This.WriteBlankLine()
		return This

    def AppendIfNotExistant(cText)
        # Only append if the text doesn't already exist in file
        if not This.ContainsText(cText)
            This.Write(cText)
        ok

	   def AppendIfNotExistantQ(cText)
		This.AppendIfNotExistant(ctext)
		return This
    
    def Close()
        @oQFile.close()

#=======================================#
# CREATOR CLASS - READ + CREATE INTENT  #
#=======================================#

class stzFileCreator from stzFileReadingMixin
    @cFileName
    @oQFile
    
    def init(cFileName)
        if FileExists(cFileName)
            StzRaise("Cannot create file - already exists: " + cFileName)
        ok
        
        @cFileName = cFileName
        @oQFile = new QFile()
	   @oQFile.setFileName(cFileName)
        @oQFile.open_3(QIODevice_ReadWrite | QIODevice_Text)
    
    # WRITE METHODS (intent-specific)
    def Write(cText)
        @oQFile.write(cText, len(cText))

	   def WriteQ(cText)
		This.Write(cText)
		return This
    
    def WriteLine(cText)
        This.Write(cText + NL)
    
	   def WriteLineQ(cText)
		This.WriteLine(cText)
		return This

    def WriteLines(aLines)
	   nLen = len(aLines)
        for i = 1 to nLen
            This.WriteLine(aLines[i])
        next

	  def WriteLinesQ(aLines)
		This.WriteLines(aLines)
		return This
    
    def WriteHeader(cTitle)
        This.WriteLine("# " + cTitle)
        This.WriteLine("# Created: " + TimeStamp())
        This.WriteLine("#" + @Copy("=", len(cTitle) + 2))
        This.WriteBlankLine()
    
	  def WriteHeaderQ(cTitle)
		This.WriteHeader(cTitle)
		return This

    def WriteBlankLine()
        This.WriteLine("")
    
	   def WriteBlankLineQ()
		This.WriteBlankLine()
		return This

    def WriteTemplate(cTemplateType)
        # Example: built-in templates for common file types
        switch cTemplateType
        on "log"
            This.WriteHeader("Log File")
            This.WriteLine("# Log entries will appear below")
            This.WriteBlankLine()

        on "config"
            This.WriteHeader("Configuration File")
            This.WriteLine("# Add your configuration settings below")
            This.WriteBlankLine()

        on "data"
            This.WriteHeader("Data File")
            This.WriteLine("# Data entries will appear below")
            This.WriteBlankLine()

        other
            This.WriteHeader("File: " + This.cFileName)
        off

	   def WriteTemplateQ(cTemplateType)
		This.WriteTemplate(cTemplateType)
		return This
    
    def Close()
        @oQFile.close()

#=============================================#
# OVERWRITER CLASS - READ + OVERWRITE INTENT  #
#=============================================#

class stzFileOverwriter from stzFileReadingMixin
    @cFileName
    @oQFile
    @cOriginalContent  # Preserve original content for reading
    
    def init(cFileName)
        @cFileName = cFileName
        
        # First, preserve original content if file exists
        if FileExists(cFileName)
            oReader = new QFile()
		  oreader.setFileName(cFileName)
            oReader.open_3(QIODevice_ReadOnly | QIODevice_Text)
            @cOriginalContent = oReader.readAll().data()
            oReader.close()
        else
            @cOriginalContent = ""
        ok
        
        # Now open for read/write with truncation
        @oQFile = new QFile()
	   @oQFile.setFileName(cFileName)
        @oQFile.open_3(QIODevice_ReadWrite | QIODevice_Truncate | QIODevice_Text)
    
    # READING METHODS (access to original content)
    def OriginalContent()
        return @cOriginalContent
    
    def OriginalLines()
        return @Lines(@cOriginalContent)
    
    def OriginalSize()
        return len(@cOriginalContent)
 
		def OriginalSizeInBytes()
			return This.OriginalSize()

    def OriginalLineCount()
        return len(This.OriginalLines())
    
		def OriginalNumberOfLines()
			return This.OriginalLineCount()

    # WRITE METHODS (intent-specific)
    def Write(cText)
        @oQFile.write(cText, len(cText))

		def WriteQ(cText)
			This.Write(cText)
			return This
    
    def WriteLine(cText)
        This.Write(cText + NL)
    
		def WriteLineQ(cText)
			This.WriteLine(cText)
			return This

    def WriteLines(aLines)
		nLen = len(aLines)
        for i = 1 to nLen
            This.WriteLine(aLines[i])
        next

		def WriteLinesQ(aLines)
			This.WriteLines(aLines)
			return This
    
    def WriteHeader(cTitle)

        This.WriteLine("# " + cTitle)
        This.WriteLine("# Updated: " + TimeStamp())
        This.WriteLine("#" + @Copy("=", len(cTitle) + 2))
        This.WriteBlankLine()
    
		def WriteHeaderQ(cTile)
			This.WriteHeader(cTitle)
			return This

    def WriteBlankLine()
        This.WriteLine("")
    
		def WriteBlankLineQ()
			This.WriteBlankLine()
			return This

    def PreserveAndModify(cModification)
        # Write original content back, then add modification
        This.Write(This.cOriginalContent)
        This.Write(cModification)

		def PreserveAndModifyQ(cModification)
			This.PreserveAndModify(cModification)
			return This
    
    def Close()
        @oQFile.close()

#=====================================================#
# UPDATER CLASS - READ + SOPHISTICATED UPDATE INTENT  #
#=====================================================#

class stzFileUpdater from stzFileReadingMixin
    @cFileName
    @oQFile
    @cOriginalContent
    @aOriginalLines
    
    def init(cFileName)
        if not FileExists(cFileName)
            StzRaise("Cannot update non-existent file: " + cFileName)
        ok
        
        @cFileName = cFileName
        
        # First read the existing content
        oReader = new QFile()
	   oReader.setFileName(cFileName)
        oReader.open_3(QIODevice_ReadOnly | QIODevice_Text)
        @cOriginalContent = oReader.readAll().data()
        oReader.close()
        
        # Parse into lines for easy manipulation
        @aOriginalLines = @Lines(@cOriginalContent)
        
        # Now open for read/write
        @oQFile = new QFile()
	   @oQFile.setFileName(cFileName)
        @oQFile.open_3(QIODevice_ReadWrite | QIODevice_Text)
    
    # ACCESS TO ORIGINAL STATE
    def OriginalContent()
        return @cOriginalContent
    
    def OriginalLines()
        return @aOriginalLines
    
    def OriginalSize()
        return len(@cOriginalContent)
    
		def OriginalSizeInBytes()
			return This.OriginalSize()

    def OriginalLineCount()
        return len(This.aOriginalLines)
    
		def NumberOfOriginalLines()
			return This.OriginalLineCount()

    # SOPHISTICATED UPDATE METHODS
    def ReplaceAllContent(cNewContent)
        @oQFile.resize(0)  # Truncate to zero
        @oQFile.write(cNewContent, len(cNewContent))
        @oQFile.flush()

		def ReplaceAllContentQ(cNewContent)
			This.ReplaceAllContent()
			return This
    
		def RepaceAll(cNewContent)
			This.ReplaceAllContent(cNewContent)
	
			def RepalceAllQ(cNewContent)
				This.ReplaceAll(cNewContent)
				return this

		def Update(cNEwContent)
			This.ReplaceAllContent(cNewContent)

			def UpdateQ(cNewContent)
				return This.RepalceAllQ(cNewContent)

		def UpdateWith(cNewContent)
			This.ReplaceAllContent(cNewContent)

			def UpdateWithQ(cNewContent)
				return This.RepalceAllQ(cNewContent)

    def ReplaceLine(nLineNumber, cNewLine)

        aLines = This.aOriginalLines
        aLines[nLineNumber] = cNewLine
        cNewContent = Join(aLines)

        This.ReplaceAllContent(cNewContent)
    
		def ReplaceLineQ(nLineNumber, cNewLine)
			This.ReplaceLine(cLineNumber, cNewLine)
			return This

    def InsertLineAt(nPosition, cNewLine)
        aLines = This.aOriginalLines
        insert(aLines, nPosition, cNewLine)
        cNewContent = Join(aLines)
        This.ReplaceAllContent(cNewContent)
    
		def InsertLineAtQ(nposition, nNewLine)
			This.InsertLineAtQ(nPosition, nNewLine)
			return This

    def InsertLineAtBeginning(cNewLine)
        This.InsertLineAt(1, cNewLine)
    
		def InsertLineAtBeginningQ(cNewLine)
			This.InsertLineAtBeginning(cNewLine)
			return this

    def InsertLineAtEnd(cNewLine)
        This.InsertLineAt(len(This.aOriginalLines) + 1, cNewLine)
 
		def InsertLineAtEndQ(cNewLine)
			This.InsertLineAtEnd(cNewLine)
			return This

    def InsertAfterLine(nLineNumber, cNewLine)
        This.InsertLineAt(nLineNumber + 1, cNewLine)
    
		def InsertAfterLineQ(nLineNumber, cNewLine)
			This.InsertAfterLine(nLineNumber, cNewLine)
			return This

    def InsertBeforeLine(nLineNumber, cNewLine)
        return This.InsertLineAt(nLineNumber, cNewLine)
    
		def InsertBeforeLineQ(nLineNumber, cNewLine)
			This.InsertBeforeLine(nLineNumber, cNewLine)
			return This

    def RemoveLine(nLineNumber)
        aLines = This.aOriginalLines
        del(aLines, nLineNumber)
        cNewContent = Join(aLines)
        This.ReplaceAllContent(cNewContent)
    
		def RemoveLineQ(nLineNumber)
			This.RemoveLine(nLineNumber)
			return This

    def RemoveFirstLine()
         This.RemoveLine(1)
    
		def RemoveFirstLineQ()
			This.RemovefirstLine()
			return this

    def RemoveLastLine()
        This.RemoveLine(len(This.aOriginalLines))
    
		def RemoveLastLineQ()
			This.RemoveLine()
			return This

    def RemoveLinesContaining(cSearchText)
        aLines = @aOriginalLines
	   nLen = len(aLines)

        aNewLines = []
        for i = 1 to nLen
            if substr(alines[i], cSearchText) = 0
                aNewLines + aLines[i]
            ok
        next

        cNewContent = Join(aNewLines)
        This.ReplaceAllContent(cNewContent)
    
		def RemoveLinesContainingQ(cSearchText)
			This.RemoveLinesContaining(cSearchText)
			return This


    def Replace(cOldText, cNewText)
        cNewContent = substr(This.cOriginalContent, cOldText, cNewText)
        This.ReplaceAllContent(cNewContent)

		def ReplaceQ(cOldText, cNewText)
			This.Replace(cOldText, cNewText)
			return This

    def ReplaceInLine(nLineNumber, cOldText, cNewText)
        aLines = This.aOriginalLines
        aLines[nLineNumber] = substr(aLines[nLineNumber], cOldText, cNewText)
        cNewContent = Join(aLines)
        This.ReplaceAllContent(cNewContent)

		def ReplaceInLineQ(nLineNumber, cOldText, cNewText)
			This.ReplaceInLine(nLineNumber, cOldText, cNewText)
			return This

    def ReplaceLineContaining(cSubstr, cNewLine)
        # Update first line that contains the substring
        aLines = @aOriginalLines
	   nLen = len(aLines)

        for i = 1 to nLen
            if substr(aLines[i], csubStr) > 0
                aLines[i] = cNewLine
                exit
            ok
        next

        cNewContent = Join(aLines)
        This.ReplaceAllContent(cNewContent)
    
		def ReplaceLineContainingQ(cSubStr, cNewLine)
			This.ReplaceLineContaining(cSubStr, cNewLine)
			return This

    def Close()
        @oQFile.close()
    

#======================================================================================

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
from its support of UNICODE file names, universal End-Of-Line encodings,
# among other features):

UPDATE - Ring 1.16 supports UNICODE names for files!

	:ReadOnly		Reads file content	    		->	Works only for existing files
	:WriteToEnd	Writes to the end of file   	->	If file do not exist, creates it
	:EraseAndWrite	Erases the file and writes  	->	If file do not exist, creates it

*/

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
		return @Lines(This.Content())

	// Returns the nth line of the file content
	def ReadLine(n)
		return This.Lines()[n]

	  #-------------------#
	 #   WRITE IN FILE   #
	#-------------------#

	/* This method behaves differently depending on the opening mode
	   	- :ReadOnly		--> No effect
		- :WriteToEnd	 	--> Appends the file
		- :EraseAndWrite 	--> Erases the file content and writes in it
	*/

	def Write(pcText)
		if This.IsWritable()
			n = stzStringLen(pcText)
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

	def Size()
		return oQFile.size()

		def SizeInBytes()
			return This.Size()

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
