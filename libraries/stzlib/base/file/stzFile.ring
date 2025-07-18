	
load "ziplib.ring" # Required by stzZipFile

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


#==================================#
# FACTORY FUNCTIONS (INTENT-BASED) #
#==================================#

func FileExists(cFileName)
    oInfo = new stzFileInfo(cFileName)
    return oInfo.Exists()

func FileRead(cFileName)
    # Pure reading intent - read-only access
    return new stzFileReader(cFileName)

func FileInfo(cFileName)
	# Intent to get information without opening file
	return new stzFileInfo(cFileName)

func FileAppend(cFileName) 
    # Intent to add to end - can read + append
    return new stzFileAppender(cFileName)

func FileCreate(cFileName)
    # Intent to create new - can read + write (fails if exists)
    return new stzFileCreator(cFileName)

func FileOverwrite(cFileName)
    # Intent to replace entirely - can read + overwrite
    return new stzFileOverwriter(cFileName)

func FileModify(cFileName)
    # Intent to modify existing - can read + sophisticated updates
    return new stzFileModify(cFileName)

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

#=================================================#
# META INFORMATION ABOUT FILE WITHOUT OPENING IT  #
#=================================================#

# The fellowing class uses QFileInfo exclusively, avoiding
# the overhead of opening files with QFile. This keeps it
# lightweight and focused on metadata retrieval

# Purpose: Provides metadata (e.g., existence, size, permissions)
# without opening the file

# Intent: "I want to get information about this file"

class stzFileInfo from stzObject
    @cFileName
    @oQFileInfo

    def init(cFileName)
        @cFileName = cFileName
        @oQFileInfo = new QFileInfo()
        @oQFileInfo.setFile(cFileName)

    def Exists()
        return @oQFileInfo.exists()

    def Size()
        return @oQFileInfo.size()

    def IsWritable()
        return @oQFileInfo.isWritable()

    def IsReadable()
        return @oQFileInfo.isReadable()

    def IsExecutable()
        return @oQFileInfo.isExecutable()

    def IsHidden()
        return @oQFileInfo.isHidden()

    def CreationTime() #TODO// Ask Mahmoud to add it to RingQt
        # return @oQFileInfo.created().toString("dd/MM/yyyy hh:mm:ss")
		StzRaise("Insupported feature!")

    def LastModificationTime()
        return @oQFileInfo.lastModified().toString("dd/MM/yyyy hh:mm:ss")

		def LastModified()
			return This.LastModificationTime()

    def LastReadingTime()
        return @oQFileInfo.lastRead().toString("dd/MM/yyyy hh:mm:ss")

		def LastRead()
			return This.LastReadingTime()

    def FilePath()
        return @oQFileInfo.filePath()

    def AbsoluteFilePath()
        return @oQFileInfo.absoluteFilePath()

    def CanonicalFilePath()
        return @oQFileInfo.canonicalFilePath()

    def DirPath()
        return @oQFileInfo.dir().path()

    def BaseName()
        return @oQFileInfo.baseName()

    def CompleteBaseName()
        return @oQFileInfo.completeBaseName()

    def Suffix()
        return @oQFileInfo.suffix()

    def CompleteSuffix()
        return @oQFileInfo.completeSuffix()

    def IsSymLink()
        return @oQFileInfo.isSymLink()

    def SymLinkTarget()
        return @oQFileInfo.symLinkTarget()

    def Refresh()
        @oQFileInfo.refresh()

#====================================#
# BASE READING CAPABILITIES (MIXIN)  #
#====================================#

# Purpose: This mixin provides universal reading
# capabilities to all file handler classes

class stzFileReadingMixin from stzObject

    
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

# Purpose: Enables reading file content with rich
# querying methods (e.g., Lines(), NumberOfLines())

# Intent: "I want to get information about this file"

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

# Intent: "I want to add to the end of this file"

# Purpose: Supports adding content (e.g., logs) with
# methods like WriteLogEntry() and read access for
# context-aware operations.

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

# Purpose: Creates a new file with write methods and
# read access, ensuring it doesn’t already exists

# Intent: "I want to create a new file"

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

# Intent: "I want to replace this file's contents"

# Purpose: Replaces all content while allowing access
# to the original content before overwriting

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

#=======================================================#
# MODIFYIER CLASS - READ + SOPHISTICATED UPDATE INTENT  #
#=======================================================#

# Purpose: Modifies specific parts of a file (e.g., updating lines)
# with read access to the original state

# Intent: "I want to modify parts of this existing file"

class stzFileModify from stzFileReadingMixin
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
        
        # Handle empty file case
        if @cOriginalContent = NULL or len(@cOriginalContent) = 0
            @cOriginalContent = ""
            @aOriginalLines = []
        else
            # Parse into lines for easy manipulation
            @aOriginalLines = @Lines(@cOriginalContent)
        ok

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
        return len(@aOriginalLines)
    
    def NumberOfOriginalLines()
        return This.OriginalLineCount()

    # SOPHISTICATED UPDATE METHODS
    def ReplaceAllContent(cNewContent)
        @oQFile.seek(0)  # Go to beginning
        @oQFile.resize(@cFileName, 0)  # Truncate to zero using filename
        @oQFile.write(cNewContent, len(cNewContent))
        # Remove the flush() call - it expects no parameters in RingQt

	    def ReplaceAllContentQ(cNewContent)
	        This.ReplaceAllContent(cNewContent)
	        return This
    
    def ReplaceAll(cNewContent)
        This.ReplaceAllContent(cNewContent)

	    def ReplaceAllQ(cNewContent)
	        This.ReplaceAll(cNewContent)
	        return This

    def Update(cNewContent)
        This.ReplaceAllContent(cNewContent)

	    def UpdateQ(cNewContent)
	        return This.ReplaceAllQ(cNewContent)

    def UpdateWith(cNewContent)
        This.ReplaceAllContent(cNewContent)

	    def UpdateWithQ(cNewContent)
	        return This.ReplaceAllQ(cNewContent)

    def ReplaceLine(nLineNumber, cNewLine)
        aLines = This.OriginalLines()
        aLines[nLineNumber] = cNewLine
        cNewContent = JoinXT(aLines, NL)
        This.ReplaceAllContent(cNewContent)
    
	    def ReplaceLineQ(nLineNumber, cNewLine)
	        This.ReplaceLine(nLineNumber, cNewLine)
	        return This


	def InsertLineAt(nPos, cNewLine)
	    aLines = @aOriginalLines
	    nLen = len(aLines)

	    # Handle empty file case
	    if nLen = 0
	        StzRaise("Cannot insert line in empty file - use ReplaceAllContent() instead")
	    ok
	    
	    # Ensure position is valid for non-empty files
	    if nPos < 1
	        nPos = 1
	    ok

	    if nPos > nLen
	        aLines + cNewLine
		else
		   ring_insert(aLines, nPos, cNewLine)

		ok
	    
	    cNewContent = JoinXT(aLines, NL)  # Add newline separator
	    This.ReplaceAllContent(cNewContent)


	    def InsertLineAtQ(nPos, cNewLine)
	        This.InsertLineAt(nPos, cNewLine)
	        return This

    def InsertLineAtBeginning(cNewLine)
        This.InsertLineAt(1, cNewLine)
    
	    def InsertLineAtBeginningQ(cNewLine)
	        This.InsertLineAtBeginning(cNewLine)
	        return This
	 
	def InsertLineAtEnd(cNewLine)
	    aLines = @aOriginalLines
  
	    # Handle empty file case
	    if len(aLines) = 0
	        StzRaise("Cannot insert line in empty file - use ReplaceAllContent() instead")
	    ok
	    
	    This.InsertLineAt(len(aLines) + 1, cNewLine)

		#< @FunctionFluentForm

	    def InsertLineAtEndQ(cNewLine)
	        This.InsertLineAtEnd(cNewLine)
	        return This
		#>

		#< @FunctionAlternativeForms

		def AppendWithLine(cNewLine)
			This.InsertLineAtEnd(cNewLine)
	
			def AppendWithLineQ(cNewLine)
				return This.InsertLineAtEndQ(cNewLine)
		#>


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
        aLines = @aOriginalLines
        if nLineNumber >= 1 and nLineNumber <= len(aLines)
            del(aLines, nLineNumber)
            cNewContent = JoinXT(aLines, NL)
            This.ReplaceAllContent(cNewContent)
        ok
    
	    def RemoveLineQ(nLineNumber)
	        This.RemoveLine(nLineNumber)
	        return This

    def RemoveFirstLine()
        This.RemoveLine(1)
	    
	    def RemoveFirstLineQ()
	        This.RemoveFirstLine()
	        return This

    def RemoveLastLine()
        This.RemoveLine(len(@aOriginalLines))
    
	    def RemoveLastLineQ()
	        This.RemoveLastLine()
	        return This

    def RemoveLinesContaining(cSearchText)
        aLines = @aOriginalLines
        nLen = len(aLines)

        aNewLines = []
        for i = 1 to nLen
            if substr(aLines[i], cSearchText) = 0
                aNewLines + aLines[i]
            ok
        next

        cNewContent = JoinLines(aNewLines)
        This.ReplaceAllContent(cNewContent)
    
	    def RemoveLinesContainingQ(cSearchText)
	        This.RemoveLinesContaining(cSearchText)
	        return This

    def Replace(cOldText, cNewText)
        cNewContent = substr(@cOriginalContent, cOldText, cNewText)
        This.ReplaceAllContent(cNewContent)

    def ReplaceQ(cOldText, cNewText)
        This.Replace(cOldText, cNewText)
        return This

    def ReplaceInLine(nLineNumber, cOldText, cNewText)
        aLines = This.OriginalLines()
        aLines[nLineNumber] = substr(aLines[nLineNumber], cOldText, cNewText)
        cNewContent = JoinLines(aLines)
        This.ReplaceAllContent(cNewContent)

	    def ReplaceInLineQ(nLineNumber, cOldText, cNewText)
	        This.ReplaceInLine(nLineNumber, cOldText, cNewText)
	        return This

	def ReplaceLineContaining(cSubstr, cNewLine)
	    # Update first line that contains the substring
	    aLines = @aOriginalLines
	    nLen = len(aLines)
	
	    for i = 1 to nLen
	        if substr(aLines[i], cSubstr) > 0
	            aLines[i] = cNewLine
	            exit
	        ok
	    next
	
	    cNewContent = JoinXT(aLines, NL)  # Add newline separator
	    This.ReplaceAllContent(cNewContent)
    
	    def ReplaceLineContainingQ(cSubStr, cNewLine)
	        This.ReplaceLineContaining(cSubStr, cNewLine)
	        return This

    def Close()
        @oQFile.close()
    

#=========================================#
# MANAGER CLASS - DISK OPERATIONS INTENT  #
#=========================================#

func FileManage(cFileName)
    return new stzFileManager(cFileName)

class stzFileManager from stzObject
    @cFileName
    @oQFile
    @oQFileInfo
    
    def init(cFileName)
        if not FileExists(cFileName)
            StzRaise("Cannot manage non-existent file: " + cFileName)
        ok
        
        @cFileName = cFileName
        @oQFile = new QFile(cFileName)
        @oQFileInfo = new QFileInfo(cFileName)
    
    # COPY OPERATIONS
    def CopyTo(cDestinationPath)
        if not substr(cDestinationPath, -1, 1) = "/"
            cDestinationPath = cDestinationPath + "/"
        ok
        
        cDestFile = cDestinationPath + @oQFileInfo.fileName()
        return @oQFile.copy(cDestFile)
    
        def CopyToQ(cDestinationPath)
            This.CopyTo(cDestinationPath)
            return This
    
    def CopyAs(cNewFileName)
        cDestFile = @oQFileInfo.dir().path() + "/" + cNewFileName
        return @oQFile.copy(cDestFile)
    
        def CopyAsQ(cNewFileName)
            This.CopyAs(cNewFileName)
            return This
    
    def CopyToAs(cDestinationPath, cNewFileName)
        if not substr(cDestinationPath, -1, 1) = "/"
            cDestinationPath = cDestinationPath + "/"
        ok
        
        cDestFile = cDestinationPath + cNewFileName
        return @oQFile.copy(cDestFile)
    
        def CopyToAsQ(cDestinationPath, cNewFileName)
            This.CopyToAs(cDestinationPath, cNewFileName)
            return This
    
    # MOVE OPERATIONS
    def MoveTo(cDestinationPath)
        if not substr(cDestinationPath, -1, 1) = "/"
            cDestinationPath = cDestinationPath + "/"
        ok
        
        cDestFile = cDestinationPath + @oQFileInfo.fileName()
        return @oQFile.rename(cDestFile)
    
        def MoveToQ(cDestinationPath)
            This.MoveTo(cDestinationPath)
            return This
    
    def MoveAs(cNewFileName)
        cDestFile = @oQFileInfo.dir().path() + "/" + cNewFileName
        return @oQFile.rename(cDestFile)
    
        def MoveAsQ(cNewFileName)
            This.MoveAs(cNewFileName)
            return This
    
    def MoveToAs(cDestinationPath, cNewFileName)
        if not substr(cDestinationPath, -1, 1) = "/"
            cDestinationPath = cDestinationPath + "/"
        ok
        
        cDestFile = cDestinationPath + cNewFileName
        return @oQFile.rename(cDestFile)
    
        def MoveToAsQ(cDestinationPath, cNewFileName)
            This.MoveToAs(cDestinationPath, cNewFileName)
            return This
    
    # RENAME OPERATIONS
    def RenameAs(cNewFileName)
        cDestFile = @oQFileInfo.dir().path() + "/" + cNewFileName
        bResult = @oQFile.rename(cDestFile)
        if bResult
            @cFileName = cDestFile
            @oQFile = new QFile(@cFileName)
            @oQFileInfo = new QFileInfo(@cFileName)
        ok
        return bResult
    
        def RenameAsQ(cNewFileName)
            This.RenameAs(cNewFileName)
            return This
    
    # SPLIT OPERATIONS
    def SplitByLines(nLinesPerFile)
        oReader = FileRead(@cFileName)
        aLines = oReader.Lines()
        oReader.Close()
        
        nTotalLines = len(aLines)
        nFileCount = ceil(nTotalLines / nLinesPerFile)
        
        cBaseName = @oQFileInfo.completeBaseName()
        cSuffix = @oQFileInfo.suffix()
        cDirPath = @oQFileInfo.dir().path()
        
        aCreatedFiles = []
        
        for nFile = 1 to nFileCount
            nStartLine = ((nFile - 1) * nLinesPerFile) + 1
            nEndLine = min(nFile * nLinesPerFile, nTotalLines)
            
            cNewFileName = cBaseName + "_" + nFile + "." + cSuffix
            cFullPath = cDirPath + "/" + cNewFileName
            
            oCreator = FileCreate(cFullPath)
            for nLine = nStartLine to nEndLine
                oCreator.WriteLine(aLines[nLine])
            next
            oCreator.Close()
            
            aCreatedFiles + cFullPath
        next
        
        return aCreatedFiles
    
        def SplitByLinesQ(nLinesPerFile)
            This.SplitByLines(nLinesPerFile)
            return This
    
    def SplitBySize(nBytesPerFile)
        oReader = FileRead(@cFileName)
        cContent = oReader.Content()
        oReader.Close()
        
        nTotalSize = len(cContent)
        nFileCount = ceil(nTotalSize / nBytesPerFile)
        
        cBaseName = @oQFileInfo.completeBaseName()
        cSuffix = @oQFileInfo.suffix()
        cDirPath = @oQFileInfo.dir().path()
        
        aCreatedFiles = []
        
        for nFile = 1 to nFileCount
            nStartPos = ((nFile - 1) * nBytesPerFile) + 1
            nEndPos = min(nFile * nBytesPerFile, nTotalSize)
            
            cChunk = substr(cContent, nStartPos, nEndPos - nStartPos + 1)
            
            cNewFileName = cBaseName + "_" + nFile + "." + cSuffix
            cFullPath = cDirPath + "/" + cNewFileName
            
            oCreator = FileCreate(cFullPath)
            oCreator.Write(cChunk)
            oCreator.Close()
            
            aCreatedFiles + cFullPath
        next
        
        return aCreatedFiles
    
        def SplitBySizeQ(nBytesPerFile)
            This.SplitBySize(nBytesPerFile)
            return This
    
    def SplitByPattern(cPattern)
        oReader = FileRead(@cFileName)
        aLines = oReader.Lines()
        oReader.Close()
        
        cBaseName = @oQFileInfo.completeBaseName()
        cSuffix = @oQFileInfo.suffix()
        cDirPath = @oQFileInfo.dir().path()
        
        aCreatedFiles = []
        aCurrentChunk = []
        nFileNum = 1
        
        nLen = len(aLines)
        for i = 1 to nLen
            if substr(aLines[i], cPattern) > 0 and len(aCurrentChunk) > 0
                cNewFileName = cBaseName + "_" + nFileNum + "." + cSuffix
                cFullPath = cDirPath + "/" + cNewFileName
                
                oCreator = FileCreate(cFullPath)
                nChunkLen = len(aCurrentChunk)
                for j = 1 to nChunkLen
                    oCreator.WriteLine(aCurrentChunk[j])
                next
                oCreator.Close()
                
                aCreatedFiles + cFullPath
                nFileNum = nFileNum + 1
                aCurrentChunk = []
            ok
            
            aCurrentChunk + aLines[i]
        next
        
        if len(aCurrentChunk) > 0
            cNewFileName = cBaseName + "_" + nFileNum + "." + cSuffix
            cFullPath = cDirPath + "/" + cNewFileName
            
            oCreator = FileCreate(cFullPath)
            nChunkLen = len(aCurrentChunk)
            for j = 1 to nChunkLen
                oCreator.WriteLine(aCurrentChunk[j])
            next
            oCreator.Close()
            
            aCreatedFiles + cFullPath
        ok
        
        return aCreatedFiles
    
        def SplitByPatternQ(cPattern)
            This.SplitByPattern(cPattern)
            return This
    
    # ZIP OPERATIONS (Delegated to stzZipFile)
    def ZipAs(cZipFileName)
        # Create zip containing this file
        oZip = new stzZipFile(cZipFileName)
        return oZip.CreateFromSingleFile(@cFileName)
    
        def ZipAsQ(cZipFileName)
            This.ZipAs(cZipFileName)
            return This
    
    def ZipWith(aFiles, cZipFileName)
        # Create zip with this file + additional files
        oZip = new stzZipFile(cZipFileName)
        aAllFiles = [@cFileName] + aFiles
        return oZip.CreateFrom(aAllFiles)
    
        def ZipWithQ(aFiles, cZipFileName)
            This.ZipWith(aFiles, cZipFileName)
            return This
    
    def ZipToDirectory(cZipFileName, cTargetDir)
        # Create zip in specified directory
        if not substr(cTargetDir, -1, 1) = "/"
            cTargetDir = cTargetDir + "/"
        ok
        
        cFullZipPath = cTargetDir + cZipFileName
        return This.ZipAs(cFullZipPath)
    
        def ZipToDirectoryQ(cZipFileName, cTargetDir)
            This.ZipToDirectory(cZipFileName, cTargetDir)
            return This
    
    def AddToZip(cZipFileName)
        # Add this file to existing zip
        oZip = new stzZipFile(cZipFileName)
        return oZip.AddFile(@cFileName)
    
        def AddToZipQ(cZipFileName)
            This.AddToZip(cZipFileName)
            return This
    
    def ZipSplitFiles(aFiles, cZipFileName)
        # Create zip containing this file and its split files
        oZip = new stzZipFile(cZipFileName)
        aAllFiles = [@cFileName] + aFiles
        return oZip.CreateFrom(aAllFiles)
    
        def ZipSplitFilesQ(aFiles, cZipFileName)
            This.ZipSplitFiles(aFiles, cZipFileName)
            return This
    
    def ZipBackup(cZipFileName)
        # Create zip backup with timestamp
        if cZipFileName = ""
            cBaseName = @oQFileInfo.completeBaseName()
            cTimeStamp = TimeStamp()
            cZipFileName = cBaseName + "_backup_" + cTimeStamp + ".zip"
        ok
        
        cDirPath = @oQFileInfo.dir().path()
        cFullZipPath = cDirPath + "/" + cZipFileName
        
        return This.ZipAs(cFullZipPath)
    
        def ZipBackupQ(cZipFileName)
            This.ZipBackup(cZipFileName)
            return This
    
    # BACKUP OPERATIONS
    def CreateBackup()
        cBaseName = @oQFileInfo.completeBaseName()
        cSuffix = @oQFileInfo.suffix()
        cDirPath = @oQFileInfo.dir().path()
        
        cTimeStamp = TimeStamp()
        cBackupName = cBaseName + "_backup_" + cTimeStamp + "." + cSuffix
        cBackupPath = cDirPath + "/" + cBackupName
        
        bResult = @oQFile.copy(cBackupPath)
        if bResult
            return cBackupPath
        else
            return ""
        ok
    
        def CreateBackupQ()
            This.CreateBackup()
            return This
    
    def CreateBackupAs(cBackupName)
        cDirPath = @oQFileInfo.dir().path()
        cBackupPath = cDirPath + "/" + cBackupName
        
        bResult = @oQFile.copy(cBackupPath)
        if bResult
            return cBackupPath
        else
            return ""
        ok
    
        def CreateBackupAsQ(cBackupName)
            This.CreateBackupAs(cBackupName)
            return This
    
    # DELETE OPERATIONS
    def Delete()
        return @oQFile.remove()
    
        def DeleteQ()
            This.Delete()
            return This
    
    def SafeDelete()
        cBackupPath = This.CreateBackup()
        if cBackupPath != ""
            return @oQFile.remove()
        else
            StzRaise("Cannot create backup before deletion")
        ok
    
        def SafeDeleteQ()
            This.SafeDelete()
            return This
    
    # PERMISSION OPERATIONS
    def MakeReadOnly()
        return @oQFile.setPermissions(QFile_ReadOwner | QFile_ReadGroup | QFile_ReadOther)
    
        def MakeReadOnlyQ()
            This.MakeReadOnly()
            return This
    
    def MakeWritable()
        return @oQFile.setPermissions(QFile_ReadOwner | QFile_WriteOwner | QFile_ReadGroup | QFile_ReadOther)
    
        def MakeWritableQ()
            This.MakeWritable()
            return This
    
    def MakeExecutable()
        return @oQFile.setPermissions(QFile_ReadOwner | QFile_WriteOwner | QFile_ExeOwner | QFile_ReadGroup | QFile_ReadOther)
    
        def MakeExecutableQ()
            This.MakeExecutable()
            return This
    
    # UTILITY METHODS
    def FileName()
        return @cFileName
    
    def FileSize()
        return @oQFileInfo.size()
    
    def FileExists()
        return @oQFileInfo.exists()
    
    def IsReadOnly()
        return not @oQFileInfo.isWritable()
    
    def IsWritable()
        return @oQFileInfo.isWritable()
    
    def IsExecutable()
        return @oQFileInfo.isExecutable()
    
    def LastModified()
        return @oQFileInfo.lastModified().toString("dd/MM/yyyy hh:mm:ss")
    
    def Close()
        return _TRUE_

#=========================================#
# ZIP FILE CLASS - ARCHIVE OPERATIONS     #
#=========================================#

func ZipFile(cZipFileName)
    return new stzZipFile(cZipFileName)

class stzZipFile from stzObject
    @cZipFileName
    @oQFileInfo
    
    def init(cZipFileName)
        @cZipFileName = cZipFileName
        @oQFileInfo = new QFileInfo(cZipFileName)
    
    # CREATION OPERATIONS
    def CreateFrom(aFiles)
        # Create zip from list of files
        if not islist(aFiles)
            StzRaise("Files parameter must be a list")
        ok
        
        oZip = zip_openfile(@cZipFileName, 'w')
        if oZip = NULL
            StzRaise("Cannot create zip file: " + @cZipFileName)
        ok
        
        nLen = len(aFiles)
        for i = 1 to nLen
            if FileExists(aFiles[i])
                zip_addfile(oZip, aFiles[i])
            ok
        next
        
        zip_close(oZip)
        return @cZipFileName
    
        def CreateFromQ(aFiles)
            This.CreateFrom(aFiles)
            return This
    
    def CreateFromSingleFile(cFileName)
        # Create zip from single file
        return This.CreateFrom([cFileName])
    
        def CreateFromSingleFileQ(cFileName)
            This.CreateFromSingleFile(cFileName)
            return This
    
    def CreateFromDirectory(cDirPath)
        # Create zip from all files in directory
        if not DirExists(cDirPath)
            StzRaise("Directory does not exist: " + cDirPath)
        ok
        
        aFiles = FilesInDir(cDirPath)
        nLen = len(aFiles)
        for i = 1 to nLen
            aFiles[i] = cDirPath + "/" + aFiles[i]
        next
        
        return This.CreateFrom(aFiles)
    
        def CreateFromDirectoryQ(cDirPath)
            This.CreateFromDirectory(cDirPath)
            return This
    
    # MODIFICATION OPERATIONS
    def AddFile(cFileName)
        # Add file to existing zip
        if not FileExists(cFileName)
            StzRaise("File does not exist: " + cFileName)
        ok
        
        oZip = zip_openfile(@cZipFileName, 'a')
        if oZip = NULL
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        zip_addfile(oZip, cFileName)
        zip_close(oZip)
        return @cZipFileName
    
        def AddFileQ(cFileName)
            This.AddFile(cFileName)
            return This
    
    def AddFiles(aFiles)
        # Add multiple files to existing zip
        if not islist(aFiles)
            StzRaise("Files parameter must be a list")
        ok
        
        oZip = zip_openfile(@cZipFileName, 'a')
        if oZip = NULL
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        nLen = len(aFiles)
        for i = 1 to nLen
            if FileExists(aFiles[i])
                zip_addfile(oZip, aFiles[i])
            ok
        next
        
        zip_close(oZip)
        return @cZipFileName
    
        def AddFilesQ(aFiles)
            This.AddFiles(aFiles)
            return This
    
    def AddString(cEntryName, cContent)
        # Add string content as file entry
        oZip = zip_openfile(@cZipFileName, 'a')
        if oZip = NULL
            StzRaise("Cannot open zip file for appending: " + @cZipFileName)
        ok
        
        oEntry = zip_newentry(oZip)
        zip_entry_open(oEntry, cEntryName)
        zip_entry_writestring(oEntry, cContent)
        zip_entry_close(oEntry)
        
        zip_close(oZip)
        return @cZipFileName
    
        def AddStringQ(cEntryName, cContent)
            This.AddString(cEntryName, cContent)
            return This
    
    # EXTRACTION OPERATIONS
    def ExtractTo(cTargetDir)
        # Extract all files to target directory
        if not This.Exists()
            StzRaise("Zip file does not exist: " + @cZipFileName)
        ok
        
        zip_extract_allfiles(@cZipFileName, cTargetDir)
        return cTargetDir
    
        def ExtractToQ(cTargetDir)
            This.ExtractTo(cTargetDir)
            return This
    
    def ExtractHere()
        # Extract to same directory as zip file
        cDirPath = @oQFileInfo.dir().path()
        return This.ExtractTo(cDirPath)
    
        def ExtractHereQ()
            This.ExtractHere()
            return This
    
    def ExtractToNewFolder()
        # Extract to new folder with zip file's base name
        cBaseName = @oQFileInfo.completeBaseName()
        cDirPath = @oQFileInfo.dir().path()
        cTargetDir = cDirPath + "/" + cBaseName
        
        return This.ExtractTo(cTargetDir)
    
        def ExtractToNewFolderQ()
            This.ExtractToNewFolder()
            return This
    
    # INSPECTION OPERATIONS
    def ListContents()
        # List all files in zip
        if not This.Exists()
            StzRaise("Zip file does not exist: " + @cZipFileName)
        ok
        
        oZip = zip_openfile(@cZipFileName, 'r')
        if oZip = NULL
            StzRaise("Cannot open zip file: " + @cZipFileName)
        ok
        
        aFiles = []
        nCount = zip_filescount(oZip)
        for i = 1 to nCount
            aFiles + zip_getfilenamebyindex(oZip, i)
        next
        
        zip_close(oZip)
        return aFiles
    
        def ListContentsQ()
            This.ListContents()
            return This
    
    def FileCount()
        # Return number of files in zip
        if not This.Exists()
            return 0
        ok
        
        oZip = zip_openfile(@cZipFileName, 'r')
        if oZip = NULL
            return 0
        ok
        
        nCount = zip_filescount(oZip)
        zip_close(oZip)
        return nCount
    
    def Contains(cFileName)
        # Check if zip contains specific file
        aContents = This.ListContents()
        nLen = len(aContents)
        for i = 1 to nLen
            if aContents[i] = cFileName
                return _TRUE_
            ok
        next
        return _FALSE_
    
    def IsEmpty()
        # Check if zip is empty
        return (This.FileCount() = 0)
    
    def Size()
        # Get zip file size
        if not This.Exists()
            return 0
        ok
        return @oQFileInfo.size()
    
    # UTILITY OPERATIONS
    def FileName()
        return @cZipFileName
    
    def Exists()
        return @oQFileInfo.exists()
    
    def Delete()
        # Delete zip file
        oQFile = new QFile(@cZipFileName)
        return oQFile.remove()
    
        def DeleteQ()
            This.Delete()
            return This
    
    def CopyTo(cDestination)
        # Copy zip file to destination
        oQFile = new QFile(@cZipFileName)
        return oQFile.copy(cDestination)
    
        def CopyToQ(cDestination)
            This.CopyTo(cDestination)
            return This
    
    def MoveTo(cDestination)
        # Move zip file to destination
        oQFile = new QFile(@cZipFileName)
        bResult = oQFile.rename(cDestination)
        if bResult
            @cZipFileName = cDestination
            @oQFileInfo = new QFileInfo(@cZipFileName)
        ok
        return bResult
    
        def MoveToQ(cDestination)
            This.MoveTo(cDestination)
            return This
