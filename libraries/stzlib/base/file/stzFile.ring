load "ziplib.ring" # A ring library, Required by stzZipFile

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

#NOTE #SMANTIC-PRECISION-GOAL

# Sotanza file semantics does not include "Update" and "Repalce" at all,
# because those are dedicated to the string semantics. Instead, the file
# API uses two clear terms: "Overwrite" for chaning all the content
# of a file, and "Modify" to change only parts of that file.

# Also, Softanza uses "Delete" a file run then "Remove". The term "Remove"
# is dedicated to string and list domain and is not used here for file.
# In fact, "removing" a file would be ambiguous and mean many thing:
# deleting, moving it elsewhere, or removing a reference of that file
# from  (e.g., from a list, array, index).

# "RemoveLine" however can be used in Softanza File API, since it's
# actually a string removal operation happening inside a file!

# Of course, Softanza "FLEXIBILITY" goal let it be permissive to keep
# the other alternatives too for whom feels confortable with them.

*/

# TODO
# All the methofs of the class must be wrapped here in global functions
# because those functions makes it easy to mange files inside a stzFolder object

func FileExists(cFullPath)
    oInfo = new stzFileInfo(cFullPath)
    return oInfo.Exists()

	func @FileExists(cFullPath)
		return FileExists(cFullPath)

	func IsFile(cFullPath)
		return FileExists(cFullPath)

	func @IsFile(cFullPath)
		return FileExists(cFullPath)

	func IsValidFile(cFullPath)
		return FileExists(cFullPath)

	func @IsValidFile(cFullPath)
		return FileExists(cFullPath)

	#--

	func FilePathExists(cFullPath)
		return FileExists(cFullPath)

	func @FilePathExists(cFullPath)
		return FileExists(cFullPath)

	func IsFilePath(cFullPath)
		return FileExists(cFullPath)

	func @IsFilePath(cFullPath)
		return FileExists(cFullPath)

	func IsValidFilePath(cFullPath)
		return FileExists(cFullPath)

	func @IsValidFilePath(cFullPath)
		return FileExists(cFullPath)

	#>

func FileReadQ(cFile)
    # Pure reading intent - read-only access
    return new stzFileReader(cFile)

	func @FileReadQ(cFile)
		return FileReadQ(cFile)

func FileRead(cFile)
	return FileReadQ(cFile).Content()

	func @FileRead(cFile)
		return FileRead(cFile)

func FileInfoQ(cFile)
	# Intent to get information without opening file
	return new stzFileInfo(cFile)

	func @FileInfoQ(cFile)
		return FileInfoQ(cFile)

func FileInfo(cFile)
	return FileInfoQ(cFile).Info()

	func @FileInfo(cFile)
		return FileInfo(cFile)

func FileInfoXT(cFile)
	return FileInfoQ(cFile).InfoXT()

	func @FileInfoXT(cFile)
		return FileInfoQ(cFile)

func CopyFileContent(cSource, cDest)
	if NOT fexists(cSource)
		stzraise("Source file does not exist: " + cSource)
	ok

	# Extract and create destination directory if needed
	cDestDir = ""
	for i = StzLen(cDest) to 1 step -1
		if cDest[i] = "/" or cDest[i] = "\"
			cDestDir = StzLeft(cDest, i - 1)
			exit
		ok
	next
	
	if cDestDir != "" and NOT isdir(cDestDir)
		if StzEngineDirCreatePath(cDestDir) = 0
			stzraise("Cannot create destination directory: " + cDestDir)
		ok
	ok
	
	cContent = read(cSource)
	write(cDest, cContent)

func ListFiles(cDir)
	aFiles = []
	_aList_ = @dir(cDir)
	nLen = len(_aList_)
	
	for i = 1 to nLen
		if _aList_[i][2] = 0  # Files only
			aFiles + _aList_[i][1]
		ok
	next
	
	return aFiles

func FileModifTime(cFile)
	if NOT fexists(cFile)
		return 0
	ok
	return 0

	func FileModificationTime(cFile)
		return FileModifTime(cFile)

	func filemtime(cFile)
		return FileModifTime(cFile)

# Appending an exsistant file
# Intent to create new - can read + write (fails if file does not exist)

func FileAppend(cFileName, cAdditionalText)

	if NOT FileExists(cFileName)
		StzRaise("Can't append a non-existing file: " + cFileName)
	ok

	if CheckParams()
		if isList(cAdditionalText) and IsWithNamedParamList(cAdditionalText)
			cAdditionalText = cAdditionalText[2]
		ok
	ok

	oFileAppender = new stzFileAppender(cFileName)
	oFileAppender.Append(cAdditionalText)
	return 1

	#< @FunctionFluentForm

	func FileAppendQ(cFileName, cAdditionalText)
		if NOT FileExists(cFileName)
			StzRaise("Can't append a non-existing file: " + cFileName)
		ok
	
		oFile = new stzFileAppender(cFileName)
		oFile.Append(cAdditionalText)
		return oFile

	#>

	#< @FunctionAlternativeForms

	func AppendFile(cFileName)
		return FileAppend(cFileName)

	func AppendFileQ(cFileName)
		return FileAppendQ(cFileName)

	#--

	func @FileAppend(cFileName, cAdditionalText)
		return FileAppend(cFileName, cAdditionalText)

		func @FileAppendQ(cFileName, cAdditionalText)
			return FileAppendQ(cFileName, cAdditionalText)

	func @AppendFile(cFileName)
		return FileAppend(cFileName)

		func @AppendFileQ(cFileName)
			return FileAppendQ(cFileName)

	#>

func FileCreate(cFileName)
	if FileExists(cFileName)
		StzRaise("Can't proceed! The file already exists: " + cFileName)
	ok

	oFile = new stzFileCreator(cFileName)
	oFile.Close()
	return 1

	#< @FunctionFluentForm

	func FileCreateQ(cFileName)
		if FileExists(cFileName)
			StzRaise("Can't proceed! The file already exists: " + cFileName)
		ok
		oFile = new stzFileCreator(cFileName)
		return oFile
	#>

	#< @FunctionAlternativeForms

	func CreateFile(cFileName)
		return FileCreate(cFileName)

		func CreateFileQ(cFileName)
			return FileCreateQ(cFileName)

	func @FileCreate(cFileName)
		return FileCreate(cFileName)

		func @FileCreateQ(cFileName)
			return FileCreateQ(cFileName)

	func @CreateFile(cFileName)
		return FileCreate(cFileName)

		func @CreateFileQ(cFileName)
			return FileCreate(cFileName)
	#>

func FileOverwrite(cFileName, cNewContent)
    oFile = FileOverwite(cFileName, cNewContent)
	oFile.Close()
	return 1

	#< @FunctionAlternativeForms

	func FileOverrite(cFileName, cNewContent)
		return FileOverwrite(cFileName, cNewContent)

	func OverwriteFile(cFileName, cNewContent)
		return FileOverwrite(cFileName, cNewContent)

	#--

	func @FileOverwrite(cFileName, cNewContent)
		return FileOverwrite(cFileName, cNewContent)

	func @FileOverrite(cFileName, cNewContent)
		return FileOverwrite(cFileName, cNewContent)

	func @OverwriteFile(cFileName, cNewContent)
		return FileOverwrite(cFileName, cNewContent)

	#>

	
func FileOverwiteQ(cFileName, cNewContent)
    # Immediate operation - replaces entire file content
    if not FileExists(cFileName)
        StzRaise("Cannot overwrite content of non-existent file: " + cFileName)
    ok
    
    StzEngineFileWrite(cFileName, cNewContent)
    return NULL

	#< #< @FunctionAlternativeForms

	func FileOverriteQ(cFileName, cNewContent)
		return FileOverwriteQ(cFileName, cNewContent)

	func OverwriteFileQ(cFileName, cNewContent)
		return FileOverwrite(cFileName, cNewContent)

	func OverriteFileQ(cFileName, cNewContent)
		return FileOverwrite(cFileName, cNewContent)

	#--

	func @FileOverwriteQ(cFileName, cNewContent)
		return FileOverwriteQ(cFileName, cNewContent)

	func @FileOverriteQ(cFileName, cNewContent)
		return FileOverwriteQ(cFileName, cNewContent)

	func @OverwriteFileQ(cFileName, cNewContent)
		return FileOverwrite(cFileName, cNewContent)

	func @OverriteFileQ(cFileName, cNewContent)
		return FileOverwrite(cFileName, cNewContent)

	#>

func FileErase(cFileName)
    if not FileExists(cSource)
        StzRaise("Cannot erase non-existent file: " + cSource)
    ok
	oFile = new stzFileEraser(cFileName)
	oFile.Erase()
	return 1

	#< @FunctionFluentForm

	func FileEraseQ(cFileName)
	    if not FileExists(cSource)
	        StzRaise("Cannot erase non-existent file: " + cSource)
	    ok
		oFile = new stzFileEraser(cFileName)
		oFile.Erase()
		return FileAppend(cFileName)

	#>

	#< @FunctionAlternativeForms

	func EraseFile(cFileName)
		return FileErase(cFileName)

		func EraseFileQ(cFileName)
			return FileEraseQ(cFileName)

	#--

	func @FileErase(cFileName)
		return FileErase(cFileName)

		func @FileEraseQ(cFileName)
			return FileEraseQ(cFileName)

	func @EraseFile(cFileName)
		return FileErase(cFileName)

		func @EraseFileQ(cFileName)
			return FileEraseQ(cFileName)

	#>

func FileSafeErase(cFileName)

    if not FileExists(cSource)
        StzRaise("Cannot erase non-existent file: " + cSource)
    ok

	FileBackup(cFileName)

	oFile = new stzFileEraser(cFileName)
	oFile.Erase()
	return 1

	#< @FunctionFluentForm

	func FileSafeEraseQ(cFileName)

	    if not FileExists(cSource)
	        StzRaise("Cannot erase non-existent file: " + cSource)
	    ok

		FileBackup(cFileName)

		oFile = new stzFileEraser(cFileName)
		oFile.Erase()
		return FileAppend(cFileName)
	#>

	#< @FunctionAlternativeForms

	func SafEraseFile(cFileName)
		return FileSafeErase(cFileName)

		func SafeEraseFileQ(cFileName)
			return FileSafeEraseQ(cFileName)

	#--

	func @FileSafeErase(cFileName)
		return FileSafeErase(cFileName)

		func @FileSafeEraseQ(cFileName)
			return FileSafeEraseQ(cFileName)

	func @SafEraseFile(cFileName)
		return FileSafeErase(cFileName)

		func @SafeEraseFileQ(cFileName)
			return FileSafeEraseQ(cFileName)

	#>

func FileBackup(cFileName)
    if NOT FileExists(cFileName)
		StzRaise("Cannot backup a non-existent file: " + cFileName)
	ok

    ofileManager = new stz FileManager(cFileName)
	oFileManager.Backup()
	return 1

	func BackupFile(cFileName)
		return FileBackup(cFileName)

	func @FileBackup(cFileName)
		return FileBackup(cFileName)

	func @BackupFile(cFileName)
		return FileBackup(cFileName)

func FileSafeOverwrite(cFileName, cNewContent)
    # Creates timestamped backup before overwriting
	FileBackup(cFileName)
    FileOverwrite(cFileName, cNewContent)
	return 1

	#< @FunctionAlternativeForms

	func SafeOverwriteFile(cFileName, cNewContent)
		return FileSafeOverwrite(cFileName, cNewContent)

	func FileSafeOverrite(cFileName, cNewContent)
		return FileSafeOverwrite(cFileName, cNewContent)

	func SafeOverriteFile(cFileName, cNewContent)
		return FileSafeOverwrite(cFileName, cNewContent)

	#--

	func @FileSafeOverwrite(cFileName, cNewContent)
		return FileSafeOverwrite(cFileName, cNewContent)

	func @SafeOverwriteFile(cFileName, cNewContent)
		return FileSafeOverwrite(cFileName, cNewContent)

	func @FileSafeOverrite(cFileName, cNewContent)
		return FileSafeOverwrite(cFileName, cNewContent)

	func @SafeOverriteFile(cFileName, cNewContent)
		return FileSafeOverwrite(cFileName, cNewContent)

	#>

func FileModify(cFileName, cOldContent, cNewContent)
    if NOT FileExists(cFileName)
		StzRaise("Cannot modify a non-existent file: " + cSource)
	ok

	oFileModifier = new stzFileModifier(cFileName)
	oFileModifier.Modify(cOldContent, cNewContent)
	return 1

	func ModifyFile(cFileName, cOldContent, cNewContent)
		return FileModify(cFileName, cOldContent, cNewContent)

	func @FileModify(cFileName, cOldContent, cNewcontent)
		return FileModify(cFileName, cOldContent, cNewContent)

	func @ModifyFile(cFileName, cOldContent, cNewContent)
		return FileModify(cFileName, cOldContent, cNewContent)


func FileCopy(cSource, cDestination)
    if not FileExists(cSource)
        StzRaise("Cannot copy non-existent file: " + cSource)
    ok
    return StzEngineFileCopy(cSource, cDestination) = 1

	func CopyFile(cSource, cDestination)
		return FileCopy(cSource, cDestination)

	func @FileCopy(cSource, cDestination)
		return FileCopy(cSource, cDestination)

	func @CopyFile(cSource, cDestination)
		return FileCopy(cSource, cDestination)


func FileMove(cSource, cDestination)
    if not FileExists(cSource)
        StzRaise("Cannot move non-existent file: " + cSource)
    ok
    if StzEngineFileCopy(cSource, cDestination) = 1
        StzEngineFileDelete(cSource)
        return 1
    ok
    return 0

	func MoveFile(cSource, cDestination)
		return FileMove(cSource, cDestination)

	func @FileMove(cSource, cDestination)
		return FileMove(cSource, cDestination)

	func @MoveFile(cSource, cDestination)
		return FileMove(cSource, cDestination)

func FileDelete(cFileName)
    if not FileExists(cFileName)
        StzRaise("Cannot Remove non-existent file: " + cFileName)
    ok
    return StzEngineFileDelete(cFileName) = 1

	#< @FunctionAlternativeForms

	func DeleteFile(cFileName)
		return FileRemove(cFileName)

	func @FileDelete(cFileName)
		return FileDelete(cFileName)

	func @DeleteFile(cFileName)
		return FileDelete(cFileName)

	#--

	def FileRemove(cFileName)
		This.FileDelete(cFileName)

	func RemoveFile(cFileName)
		return FileRemove(cFileName)

	func @FileRemove(cFileName)
		return FileDelete(cFileName)

	func @RemoveFile(cFileName)
		return FileDelete(cFileName)

	#>

func FileSize(cFileName)
    if not FileExists(cFileName)
        StzRaise("Cannot get size of non-existent file: " + cFileName)
    ok
    return StzEngineFileSize(cFileName)

	func FileSizeInBytes(cFileName)
		return FileSize(cFileName)


func FileCreateIfInexistant(cFilePath)
    if NOT fexists(cFilePath)
        fp = fopen(cFilePath, "w")
        fclose(fp)
    ok

	func CreateFileIfInexistant(cFilePath)
		FileCreateIfInexistant(cFilePath)

	func @FileCreateIfInexistant(cFilePath)
		FileCreateIfInexistant(cFilePath)

	func @CreateFileIfInexistant(cFilePath)
		FileCreateIfInexistant(cFilePath)


#---

# Short form - relative/normalized paths
func NormalizeFilePath(cName)
	if CheckParams()
		if NOT ( isString(cName) and trim(cName) != "" )
			StzRaise("Incorrect param type! cName must be a non-empty string.")
		ok
	ok
	
	cResult = lower(trim(cName))
	cResult = ring_substr2(cResult, "\", "/")
	cResult = ring_substr2(cResult, "//", "/")
	return cResult

	func NormaliseFilePath(cName)
		return NormalizeFilePath(cName)

func NormalizeFilePathXT(cName)
	if CheckParams()
		if NOT ( isString(cName) and trim(cName) != "" )
			StzRaise("Incorrect param type! cName must be a non-empty string.")
		ok
	ok

	cName = trim(cName)

	if StzLeft(cName, 1) != "/" and ring_find(cName, ":/") = 0
		cName = currentdir() + "/" + cName
	ok

	cResult = lower(cName)
	cResult = ring_substr2(cResult, "\", "/")
	cResult = ring_substr2(cResult, "//", "/")
	return cResult

	func NormaliseFilePathXT(cName)
		return NormalizeFilePathXT(cName)

class stzFileXT from stzObject

	def init(pcFileName, pcIntent)
		pcIntent = lower(pcIntent)

		if pcIntent = "info"
			return new stzFileInfo(cFileName)

		but pcIntent = "read" or pcIntent = "reader" or pcIntent = "readonly"
			return new stzFileReader(pcFileName)

		but pcIntent = "append" or pcIntent = "appender"
			return new stzFileAppender(pcFileName)

		but pcIntent = "create" or pcIntent = "creator"
			return new stzFileCreator(pcFileName)

		but pcIntent = "overwrite" or pcIntent = "overwiriter"
			return new stzFileOverwriter(pcFileName)

		but pcIntent = "erase" or pcIntent = "eraser"
			return new stzFileEraser(pcFileName)

		but pcIntent = "modify" or pcIntent = "modifier"
			return new stzFileModifier(pcFileName)

		but pcIntent = "mange" or pcIntent = "manager"
			return new stzFileManager(pcFileName)

		else
			StzRaise("Can't proceed! The intent you provided is not support in Softanza file API.")
		ok
		

#==============================#
# PURE RING PATH HELPERS       #
#==============================#

func _FileName(cPath)
	nPos = 0
	for i = StzLen(cPath) to 1 step -1
		if cPath[i] = "/" or cPath[i] = "\"
			nPos = i
			exit
		ok
	next
	if nPos > 0
		return StzRight(cPath, StzLen(cPath) - nPos)
	ok
	return cPath

func _FileDirPath(cPath)
	nPos = 0
	for i = StzLen(cPath) to 1 step -1
		if cPath[i] = "/" or cPath[i] = "\"
			nPos = i
			exit
		ok
	next
	if nPos > 0
		return StzLeft(cPath, nPos - 1)
	ok
	return "."

func _FileExtension(cPath)
	cName = _FileName(cPath)
	nDot = 0
	for i = StzLen(cName) to 1 step -1
		if cName[i] = "."
			nDot = i
			exit
		ok
	next
	if nDot > 0
		return StzRight(cName, StzLen(cName) - nDot)
	ok
	return ""

func _FileCompleteBaseName(cPath)
	cName = _FileName(cPath)
	nDot = 0
	for i = StzLen(cName) to 1 step -1
		if cName[i] = "."
			nDot = i
			exit
		ok
	next
	if nDot > 1
		return StzLeft(cName, nDot - 1)
	ok
	return cName

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

    def init(cFileName)
        @cFileName = cFileName


	# CONDTITIONS AND CAPABILITIES

	def Conditions()
		return [
			:FilesExists = TRUE
		]

	def Capabilities()
		return [
			:Read = FALSE,
			:Append = FALSE,
			:Create = FALSE,
			:Overwrite = FALSE,
			:Modify = FALSE
		]

		def Skills()
			return This.Capabilities()

	# SUMMARISED INFO

   def Info()
        return [
            :name = This.BaseName(),
            :size = This.Size(),
            :suffix = This.Suffix(),
            :path = This.FilePath(),
            :exists = This.Exists(),
            :isWritable = This.IsWritable(),
            :isReadable = This.IsReadable(),
            :lastModified = This.LastModified()
        ]

    def InfoXT()
        return [
            :name = This.BaseName(),
            :completeName = This.CompleteBaseName(),
            :size = This.Size(),
            :suffix = This.Suffix(),
            :completeSuffix = This.CompleteSuffix(),
            :path = This.FilePath(),
            :absolutePath = This.AbsoluteFilePath(),
            :canonicalPath = This.CanonicalFilePath(),
            :directory = This.DirPath(),
            :exists = This.Exists(),
            :isWritable = This.IsWritable(),
            :isReadable = This.IsReadable(),
            :isExecutable = This.IsExecutable(),
            :isHidden = This.IsHidden(),
            :isSymLink = This.IsSymLink(),
            :symLinkTarget = This.SymLinkTarget(),
            :lastModified = This.LastModified(),
            :lastRead = This.LastRead()
            # CreationTime omitted due to unsupported feature
        ]

	# DETAILED INFO METHODS

    def Exists()
        return StzEngineFileExists(@cFileName) = 1

    def Size()
        return StzEngineFileSize(@cFileName)

    def IsWritable()
        try
            pFile = fopen(@cFileName, "a")
            if pFile != NULL
                fclose(pFile)
                return 1
            ok
        catch
        done
        return 0

    def IsReadable()
        try
            pFile = fopen(@cFileName, "r")
            if pFile != NULL
                fclose(pFile)
                return 1
            ok
        catch
        done
        return 0

    def IsExecutable()
        cExt = lower(StzEnginePathExtension(@cFileName))
        return cExt = "exe" or cExt = "bat" or cExt = "cmd" or cExt = "com"

    def IsHidden()
        cBase = StzEnginePathBasename(@cFileName)
        if len(cBase) > 0 and StzLeft(cBase, 1) = "."
            return 1
        ok
        return 0

    def CreationTime()
        StzRaise("Unsupported feature!")

    def LastModificationTime()
        StzRaise("Unsupported feature! Use OS-level tools for file timestamps.")

        def LastModified()
            return This.LastModificationTime()

    def LastReadingTime()
        StzRaise("Unsupported feature! Use OS-level tools for file timestamps.")

        def LastRead()
            return This.LastReadingTime()

    def FilePath()
        return @cFileName

    def AbsoluteFilePath()
        return @cFileName

    def CanonicalFilePath()
        return @cFileName

    def DirPath()
        return StzEnginePathDirname(@cFileName)

    def BaseName()
        cBase = StzEnginePathBasename(@cFileName)
        nDot = ring_find(cBase, ".")
        if nDot > 0
            return StzLeft(cBase, nDot - 1)
        ok
        return cBase

    def CompleteBaseName()
        return StzEnginePathBasename(@cFileName)

    def Suffix()
        return StzEnginePathExtension(@cFileName)

    def CompleteSuffix()
        return StzEnginePathExtension(@cFileName)

    def IsSymLink()
        return 0

    def SymLinkTarget()
        return ""

    def Refresh()
        return


#====================================#
# BASE READING CAPABILITIES (MIXIN)  #
#====================================#

# Purpose: This mixin provides universal reading
# capabilities to all file handler classes

class stzFileReadingMixin from stzObject

    def Content()
        return read(@cFileName)
        
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
        return aLines[StzLen(aLines)]
    
    def NumberOfLines()
        return len(This.Lines())
    
		def HowManyLine()
			return len(This.Lines())

		def CountLines()
			return len(This.Lines())

    def ContentAsBytes()
        return StzListOfBytesQ(This.Content())
    
    def Size()
        return StzEngineFileSize(@cFileName)
    
		def SizeInBytes()
			return This.Size()

    def IsEmpty()
        return This.Size() = 0
    
    def FileName()
        return @cFileName
    
    def FindText(cSearchText)
        # Returns position of text in file, or 0 if not found
        cContent = This.Content()
        return ring_find(cContent, cSearchText)
    
    def ContainsText(cSearchText)
        return This.FindText(cSearchText) > 0
    
    def CountOccurrences(cSearchText)
        return StringNumberOfOccurrence(This.Content(), cSearchText)
    
		def NumberOfOccurrences(cSearchText)
			return This.CountOccurrences(cSearchText)

		def NumberOfOccurrence(cSearchText)
			return This.CountOccurrences(cSearchText)

    def LinesContaining(cSearchText)
        aLines = This.Lines()
        aResult = []
	   nLen = len(aLines)
        for i = 1 to nLen
            if ring_find(aLines[i], cSearchText) > 0
                aResult + [i, aLines[i]]
            ok
        next
        return aResult
    
    def LineNumber(cSearchText)
        # Returns line number containing the text
        aLines = This.Lines()
	   nLen = len(aLines)
        for i = 1 to nLen
            if ring_find(aLines[i], cSearchText) > 0
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
    
    def init(cFileName)
        if not FileExists(cFileName)
            StzRaise("Cannot read non-existent file: " + cFileName)
        ok
        @cFileName = cFileName

    def Content()
        return read(@cFileName)

    def Close()
        return

	def Conditions()
		return [
			:FileExists = TRUE
		]

	def Capabilities()
		return [
			:Read = TRUE,
			:Append = FALSE,
			:Create = FALSE,
			:Overwrite = FALSE,
			:Modify = FALSE
		]

		def Skills()
			return This.Capabilities()

#========================================#
# APPENDER CLASS - READ + APPEND INTENT  #
#========================================#

# Intent: "I want to add to the end of this file"

# Purpose: Supports adding content (e.g., logs) with
# methods like WriteLogEntry() and read access for
# context-aware operations.

class stzFile from stzFileAppender

class stzFileAppender from stzFileReadingMixin
    @cFileName

    def init(cFileName)
        if not FileExists(cFileName)
            StzRaise("Cannot append non-existent file: " + cFileName)
        ok
        @cFileName = cFileName
    
	def Conditions()
		return [
			:FileExists = TRUE
		]

	def Capabilities()
		return [
			:Read = TRUE,
			:Append = TRUE,
			:Create = FALSE,
			:Overwrite = FALSE,
			:Modify = FALSE
		]

		def Skills()
			return This.Capabilities()

    # WRITE METHODS (intent-specific)
    def Write(cText)
        StzEngineFileAppend(@cFileName, cText)
		return 1

		def WrtiteQ(cText)
			This.Write(cText)
			return This
    
    def WriteLine(cText)
        This.Write(cText + NL)
    	return 1

		def WriteLineQ(cText)
			This.WriteLine(cText)
			return This

    def WriteLines(aLines)
	   nLen = len(aLines)
        for i = 1 to nLen
            This.WriteLine(aLines[i])
        next
        return 1

	   def WrtiteLinesQ(aLines)
			This.WriteLines(aLines)
			return This
    
    def WriteTimestamp()
        cTimeStamp = TimeStamp()
        This.Write(cTimeStamp + ": ")
    	return 1

	   def WriteTimeStampQ()
		This.WriteTimeStamp()
		return This

    def WriteLogEntry(cMessage)
        cTimeStamp = TimeStamp()
        This.WriteLine(cTimeStamp + " - " + cMessage)
    	return 1

	   def WriteLogEntryQ(cMessage)
		This.WriteLogEntryQ(cMessage)
		return This

    def WriteSeparator(cChar)
        if cChar = NULL
            cChar = "-"
        ok
        This.WriteLine(RepeatChar(cChar, 50))
    	return 1

	   def WriteSeparatorQ(cChar)
		This.WriteSeparator(cChar)
		return This

	   #-- @Misspelled

	   def WriteSeperator(cChar)
		This.WriteSeparator(cChar)

		def WriteSeperatorQ(cChar)
			return This.WriteSeparatorQ(cChar)

    def WriteBlankLine()
        This.WriteLine("")
    	return 1

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
        return
		return 1

#=======================================#
# CREATOR CLASS - READ + CREATE INTENT  #
#=======================================#

# Purpose: Creates a new file with write methods and
# read access, ensuring it doesnâ€™t already exists

# Intent: "I want to create a new file"

class stzFileCreator from stzFileReadingMixin
    @cFileName

    def init(cFileName)
        if FileExists(cFileName)
            StzRaise("Cannot create file - already exists: " + cFileName)
        ok

        @cFileName = cFileName
        StzEngineFileWrite(cFileName, "")
    
	# CONDTITIONS AND CAPABILITIES

	def Conditions()
		return [
			:FileExists = FALSE
		]

	def Capabilities()
		return [
			:Read = TRUE,
			:Append = FALSE,
			:Create = TRUE,
			:Overwrite = FALSE,
			:Modify = FALSE
		]

		def Skills()
			return This.Capabilities()

    # WRITE METHODS (intent-specific)
    def Write(cText)
        StzEngineFileAppend(@cFileName, cText)
		return 1

	   def WriteQ(cText)
		This.Write(cText)
		return This
    
    def WriteLine(cText)
        This.Write(cText + NL)
    	return 1

	   def WriteLineQ(cText)
		This.WriteLine(cText)
		return This

    def WriteLines(aLines)
	   	nLen = len(aLines)
        for i = 1 to nLen
            This.WriteLine(aLines[i])
        next
		return 1

	  def WriteLinesQ(aLines)
		This.WriteLines(aLines)
		return This
    
    def WriteHeader(cTitle)
        This.WriteLine("# " + cTitle)
        This.WriteLine("# Created: " + TimeStamp())
        This.WriteLine("#" + RepeatChar("=", StzLen(cTitle) + 2))
        This.WriteBlankLine()
    	return 1

	  def WriteHeaderQ(cTitle)
		This.WriteHeader(cTitle)
		return This

    def WriteBlankLine()
        This.WriteLine("")
    	return 1

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
			return 1

        on "config"
            This.WriteHeader("Configuration File")
            This.WriteLine("# Add your configuration settings below")
            This.WriteBlankLine()
			return 1

        on "data"
            This.WriteHeader("Data File")
            This.WriteLine("# Data entries will appear below")
            This.WriteBlankLine()
			return 1

        other
            This.WriteHeader("File: " + This.@cFileName)
        off

	   def WriteTemplateQ(cTemplateType)
			This.WriteTemplate(cTemplateType)
			return This
    
    def Close()
        return

#=============================================#
# OVERWRITER CLASS - READ + OVERWRITE INTENT  #
#=============================================#

# Intent: "I want to replace this file's contents"

# Purpose: Replaces all content while allowing access
# to the original content before overwriting

# NOTE: Can't erase the file (overwriding it with an
# empty conte). To do so, use FileErase().

class stzFileOverwriter from stzFileReadingMixin

    @cFileName
    @cOriginalContent

    def init(cFileName)
        @cFileName = cFileName

        if FileExists(cFileName)
            @cOriginalContent = read(cFileName)
        else
            @cOriginalContent = ""
        ok

        StzEngineFileWrite(cFileName, "")

	# CONDTITIONS AND CAPABILITIES

	def Conditions()
		return [
			:FileExists = TRUE
		]

	def Capabilities()
		return [
			:Read = TRUE,
			:Append = FALSE,
			:Create = FALSE,
			:Overwrite = TRUE,
			:Modify = FALSE
		]

		def Skills()
			return This.Capabilities()

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
		if NOT (isString(cText) and cText != "")
			StzRaise("Can't write to the file! You must provide a non empty string.")
		ok

        StzEngineFileAppend(@cFileName, cText)
		return 1

		def WriteQ(cText)
			This.Write(cText)
			return This
    
    def WriteLine(cText)
        This.Write(cText + NL)
    	return 1

		def WriteLineQ(cText)
			This.WriteLine(cText)
			return This

    def WriteLines(aLines)
		nLen = len(aLines)
        for i = 1 to nLen
            This.WriteLine(aLines[i])
        next
		return 1

		def WriteLinesQ(aLines)
			This.WriteLines(aLines)
			return This
    
    def WriteHeader(cTitle)
        This.WriteLine("# " + cTitle)
        This.WriteLine("# Updated: " + TimeStamp())
        This.WriteLine("#" + RepeatChar("=", len(cTitle) + 2))
        This.WriteBlankLine()
    	return 1

		def WriteHeaderQ(cTitle)
			This.WriteHeader(cTitle)
			return This

    def WriteBlankLine()
        This.WriteLine("")
    	return 1

		def WriteBlankLineQ()
			This.WriteBlankLine()
			return This

    def PreserveAndModify(cModification)
        # Write original content back, then add modification
        This.Write(This.cOriginalContent)
        This.Write(cModification)
		return 1

		def PreserveAndModifyQ(cModification)
			This.PreserveAndModify(cModification)
			return This
    
    def Close()
        return

# SPECIAL CASE OF THE OVERWRITE INTENT

class stzFileEaraser from stzObject
    @cFileName
    @cOriginalContent

    def init(cFileName)
        @cFileName = cFileName

        if FileExists(cFileName)
            @cOriginalContent = read(cFileName)
        else
            @cOriginalContent = ""
        ok

        StzEngineFileWrite(cFileName, "")

	# CONDTITIONS AND CAPABILITIES

	def Conditions()
		return [
			:FileExists = TRUE
		]

	def Capabilities()
		return [
			:Read = TRUE,
			:Append = TRUE,
			:Create = FALSE,
			:Overwrite = TRUE,
			:Modify = FALSE
		]

		def Skills()
			return This.Capabilities()

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

    def Erase()
        StzEngineFileWrite(@cFileName, "")
		return 1

		def EraseQ(cText)
			This.Erase()
			return FileAppend(@cFileName)

#======================================================#
# MODIFIER CLASS - READ + SOPHISTICATED UPDATE INTENT  #
#======================================================#

# Purpose: Modifies specific parts of a file (e.g., updating lines)
# with read access to the original state

# Intent: "I want to modify parts of this existing file"

class stzFileModifier from stzFileReadingMixin

    @cFileName
    @cOriginalContent
    @aOriginalLines

    def init(cFileName)
        if not FileExists(cFileName)
            StzRaise("Cannot update non-existent file: " + cFileName)
        ok

        @cFileName = cFileName
        @cOriginalContent = read(cFileName)

        if @cOriginalContent = NULL or len(@cOriginalContent) = 0
            @cOriginalContent = ""
            @aOriginalLines = []
        else
            @aOriginalLines = @Lines(@cOriginalContent)
        ok

	# CONDTITIONS AND CAPABILITIES

	def Conditions()
		return [
			:FileExists = TRUE
		]

	def Capabilities()
		return [
			:Read = TRUE,
			:Append = FALSE,
			:Create = FALSE,
			:Overwrite = FALSE,
			:Modify = TRUE
		]

		def Skills()
			return This.Capabilities()

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
    def ModifyAllContent(cNewContent)
        StzEngineFileWrite(@cFileName, cNewContent)
		return 1

	    def ModifyAllContentQ(cNewContent)
	        This.ModifyAllContent(cNewContent)
	        return This

    def ModifyAllContentWith(cNewContent)
        This.ModifyAllContent(cNewContent)

	    def ModifyAllContentWithQ(cNewContent)
	        return This.ModifyAllContentQ(cNewContent)

    def ModifyLine(nLineNumber, cNewLine)
        aLines = This.OriginalLines()
        aLines[nLineNumber] = cNewLine
        cNewContent = JoinXT(aLines, NL)
        This.ModifyAllContent(cNewContent)
    	return 1

	    def ModifyLineQ(nLineNumber, cNewLine)
	        This.ModifyLine(nLineNumber, cNewLine)
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
	    This.ModifyAllContent(cNewContent)
		return 1

	    def InsertLineAtQ(nPos, cNewLine)
	        This.InsertLineAt(nPos, cNewLine)
	        return This

		def InsertLine(nPos, cNewLine)
			This.InsertLineAt(nPos, nNewLine)

			def InertLineQ(nPos, cNewLine)
				return This.InsertLineAtQ(nPos, cNewLine)


    def InsertLineAtStart(cNewLine)
        This.InsertLineAt(1, cNewLine)
    	return 1

	    def InsertLineAtStartQ(cNewLine)
	        This.InsertLineAtStart(cNewLine)
	        return This
	 
	def InsertLineAtEnd(cNewLine)
	    aLines = @aOriginalLines
  
	    # Handle empty file case
	    if len(aLines) = 0
	        StzRaise("Cannot insert line in empty file - use ReplaceAllContent() instead")
	    ok
	    
	    This.InsertLineAt(len(aLines) + 1, cNewLine)
		return 1

		#< @FunctionFluentForm

	    def InsertLineAtEndQ(cNewLine)
	        This.InsertLineAtEnd(cNewLine)
	        return This
		#>

		#< @FunctionAlternativeForms

		def AppendWithLine(cNewLine)
			This.InsertLineAtEnd(cNewLine)
			return 1

			def AppendWithLineQ(cNewLine)
				return This.InsertLineAtEndQ(cNewLine)
		#>


    def InsertAfterLine(nLineNumber, cNewLine)
        This.InsertLineAt(nLineNumber + 1, cNewLine)
    	return 1

	    def InsertAfterLineQ(nLineNumber, cNewLine)
	        This.InsertAfterLine(nLineNumber, cNewLine)
	        return This

    def InsertBeforeLine(nLineNumber, cNewLine)
        This.InsertLineAt(nLineNumber, cNewLine)
    	return 1

	    def InsertBeforeLineQ(nLineNumber, cNewLine)
	        This.InsertBeforeLine(nLineNumber, cNewLine)
	        return This

    def RemoveLine(nLineNumber)
        aLines = @aOriginalLines
        if nLineNumber >= 1 and nLineNumber <= len(aLines)
            del(aLines, nLineNumber)
            cNewContent = JoinXT(aLines, NL)
            This.ModifyAllContent(cNewContent)
			return 1
        ok
    	return 0

	    def RemoveLineQ(nLineNumber)
	        This.RemoveLine(nLineNumber)
	        return This

		def DeleteLine(nLineNumber)
			This.RemoveLine(nLineNumber)

			def DeleteLineQ(nLineNumber)
				return This.RemoveLineQ(nLineNumber)

    def RemoveFirstLine()
        This.RemoveLine(1)
	    return 1

	    def RemoveFirstLineQ()
	        This.RemoveFirstLine()
	        return This

		def DeleteFirstLine()
			return This.RemoveFirstLine()

		def DeleteFirstLineQ()
			return This.RemoveFirstLineQ()

    def RemoveLastLine()
        This.RemoveLine(len(@aOriginalLines))
    	return 1

	    def RemoveLastLineQ()
	        This.RemoveLastLine()
	        return This

		def DeleteLastLine()
			return This.RemoveLastLine()

		def DeleteLastLineQ()
			return This.RemoveLastLineQ()

	def FindLinesContaining(cSearchText)
        aLines = @aOriginalLines
        nLen = len(aLines)

        anResult = []
        for i = 1 to nLen
            if ring_find(aLines[i], cSearchText) > 0
                anResult + i
            ok
        next

		return anResult

	def LinesContaining(cSearchText)
        acLines = @aOriginalLines
        nLen = len(acLines)

        acResult = []
        for i = 1 to nLen
            if ring_find(acLines[i], cSearchText) > 0
                acResult + acLines[i]
            ok
        next

		return acResult


    def RemoveLinesContaining(cSearchText)
        aLines = @aOriginalLines
        nLen = len(aLines)

        aNewLines = []
        for i = 1 to nLen
            if ring_find(aLines[i], cSearchText) = 0
                aNewLines + aLines[i]
            ok
        next

        cNewContent = JoinLines(aNewLines)
        This.ModifyAllContent(cNewContent)
    	return 1

	    def RemoveLinesContainingQ(cSearchText)
	        This.RemoveLinesContaining(cSearchText)
	        return This

		def DeleteLinesContaining(cSearchText)
			return This.RemoveLinesContaining(cSearchText)

		def DeleteLinesContainingQ(cSearchText)
			return This.RemoveLinesContainingQ(cSearchText)

    def Modify(cOldText, cNewText)
		if CheckParams()
			if NoT isString(cOldText)
				StzRaise("Incorrect param type! cOldText must be a string.")
			ok

			if isList(cNewText) and IsWithNamedParamList(cNewText)
				cNexText = cNewText[2]
			ok

			if NoT isString(cNewText)
				StzRaise("Incorrect param type! cNewText must be a string.")
			ok
		ok

        cNewContent = ring_substr2(@cOriginalContent, cOldText, cNewText)
        This.ModifyAllContent(cNewContent)
		return 1

	    def ModifyQ(cOldText, cNewText)
	        This.Modify(cOldText, cNewText)
	        return This

		def ModifyText(cOldText, cNewText)
			This.Modify(cOldText, cNewText)
			return 1


    def ReplaceInLine(nLineNumber, cOldText, cNewText)
        aLines = This.OriginalLines()
        aLines[nLineNumber] = ring_substr2(aLines[nLineNumber], cOldText, cNewText)
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
	        if ring_find(aLines[i], cSubstr) > 0
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
        return
    

#=========================================#
# MANAGER CLASS - DISK OPERATIONS INTENT  #
#=========================================#

func FileManage(cFileName)
    return new stzFileManager(cFileName)

class stzFileManager from stzObject
    @cFileName

    def init(cFileName)
        if not FileExists(cFileName)
            StzRaise("Cannot manage non-existent file: " + cFileName)
        ok

        @cFileName = cFileName
    
	# CONDTITIONS AND CAPABILITIES

	def Conditions()
		return [
			:FileExists = TRUE
		]

	def Capabilities()
		return [
			:Copy = TRUE,
			:Move = TRUE,
			:Rename = TRUE,
			:Delete = TRUE,
			:Backup = TRUE,
			:Split = TRUE,
			:Zip = TRUE,
			:MakeReadOnly = TRUE,
			:MakeWritable = TRUE,
			:MakeExecutable = TRUE,
			:EncryptDecrypt = TRUE
		]

		def Skills()
			return This.Capabilities()

    # COPY OPERATIONS

    def CopyTo(cDestinationPath)
        if not StzRight(cDestinationPath, 1) = "/"
            cDestinationPath = cDestinationPath + "/"
        ok

        cDestFile = cDestinationPath + _FileName(@cFileName)
        return StzEngineFileCopy(@cFileName, cDestFile)

        def CopyToQ(cDestinationPath)
            This.CopyTo(cDestinationPath)
            return This

    def CopyAs(cNewFileName)
        cDestFile = _FileDirPath(@cFileName) + "/" + cNewFileName
        return StzEngineFileCopy(@cFileName, cDestFile)

        def CopyAsQ(cNewFileName)
            This.CopyAs(cNewFileName)
            return This

    def CopyToAs(cDestinationPath, cNewFileName)
        if not StzRight(cDestinationPath, 1) = "/"
            cDestinationPath = cDestinationPath + "/"
        ok

        cDestFile = cDestinationPath + cNewFileName
        return StzEngineFileCopy(@cFileName, cDestFile)
    
        def CopyToAsQ(cDestinationPath, cNewFileName)
            This.CopyToAs(cDestinationPath, cNewFileName)
            return This
    
    # MOVE OPERATIONS

    def MoveTo(cDestinationPath)
        if not StzRight(cDestinationPath, 1) = "/"
            cDestinationPath = cDestinationPath + "/"
        ok

        cDestFile = cDestinationPath + _FileName(@cFileName)
        bResult = StzEngineFileCopy(@cFileName, cDestFile)
        if bResult StzEngineFileDelete(@cFileName) @cFileName = cDestFile ok
        return bResult

        def MoveToQ(cDestinationPath)
            This.MoveTo(cDestinationPath)
            return This

    def MoveAs(cNewFileName)
        cDestFile = _FileDirPath(@cFileName) + "/" + cNewFileName
        bResult = StzEngineFileCopy(@cFileName, cDestFile)
        if bResult StzEngineFileDelete(@cFileName) @cFileName = cDestFile ok
        return bResult

        def MoveAsQ(cNewFileName)
            This.MoveAs(cNewFileName)
            return This

    def MoveToAs(cDestinationPath, cNewFileName)
        if not StzRight(cDestinationPath, 1) = "/"
            cDestinationPath = cDestinationPath + "/"
        ok

        cDestFile = cDestinationPath + cNewFileName
        bResult = StzEngineFileCopy(@cFileName, cDestFile)
        if bResult StzEngineFileDelete(@cFileName) @cFileName = cDestFile ok
        return bResult
    
        def MoveToAsQ(cDestinationPath, cNewFileName)
            This.MoveToAs(cDestinationPath, cNewFileName)
            return This
    
    # RENAME OPERATIONS

    def RenameAs(cNewFileName)
        cDestFile = _FileDirPath(@cFileName) + "/" + cNewFileName
        bResult = StzEngineFileCopy(@cFileName, cDestFile)
        if bResult
            StzEngineFileDelete(@cFileName)
            @cFileName = cDestFile
        ok
        return bResult
    
        def RenameAsQ(cNewFileName)
            This.RenameAs(cNewFileName)
            return This
    
	# BACKUP OPERATION

	def Backup()
        cBackup = @cFileName + ".backup." + TimeStamp()
        FileCopy(@cFileName, cBackup) #TODO // use internal methods to the object
		return 1

    # SPLIT OPERATIONS

    def SplitByLines(nLinesPerFile)
        oReader = FileRead(@cFileName)
        aLines = oReader.Lines()
        oReader.Close()
        
        nTotalLines = len(aLines)
        nFileCount = ceil(nTotalLines / nLinesPerFile)
        
        cBaseName = _FileCompleteBaseName(@cFileName)
        cSuffix = _FileExtension(@cFileName)
        cDirPath = _FileDirPath(@cFileName)
        
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

        cBaseName = _FileCompleteBaseName(@cFileName)
        cSuffix = _FileExtension(@cFileName)
        cDirPath = _FileDirPath(@cFileName)

        aCreatedFiles = []

        for nFile = 1 to nFileCount
            nStartPos = ((nFile - 1) * nBytesPerFile) + 1
            nEndPos = min(nFile * nBytesPerFile, nTotalSize)

            cChunk = StzMid(cContent, nStartPos, nEndPos - nStartPos + 1)
            
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

        cBaseName = _FileCompleteBaseName(@cFileName)
        cSuffix = _FileExtension(@cFileName)
        cDirPath = _FileDirPath(@cFileName)

        aCreatedFiles = []
        aCurrentChunk = []
        nFileNum = 1

        nLen = len(aLines)
        for i = 1 to nLen
            if ring_find(aLines[i], cPattern) > 0 and len(aCurrentChunk) > 0
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
        if not StzRight(cTargetDir, 1) = "/"
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
            cBaseName = _FileCompleteBaseName(@cFileName)
            cTimeStamp = TimeStamp()
            cZipFileName = cBaseName + "_backup_" + cTimeStamp + ".zip"
        ok
        
        cDirPath = _FileDirPath(@cFileName)
        cFullZipPath = cDirPath + "/" + cZipFileName
        
        return This.ZipAs(cFullZipPath)
    
        def ZipBackupQ(cZipFileName)
            This.ZipBackup(cZipFileName)
            return This
    
    # BACKUP OPERATIONS

    def CreateBackup()
        cBaseName = _FileCompleteBaseName(@cFileName)
        cSuffix = _FileExtension(@cFileName)
        cDirPath = _FileDirPath(@cFileName)
        
        cTimeStamp = TimeStamp()
        cBackupName = cBaseName + "_backup_" + cTimeStamp + "." + cSuffix
        cBackupPath = cDirPath + "/" + cBackupName
        
        bResult = StzEngineFileCopy(@cFileName, cBackupPath)
        if bResult
            return cBackupPath
        else
            return ""
        ok

        def CreateBackupQ()
            This.CreateBackup()
            return This

    def CreateBackupAs(cBackupName)
        cDirPath = _FileDirPath(@cFileName)
        cBackupPath = cDirPath + "/" + cBackupName

        bResult = StzEngineFileCopy(@cFileName, cBackupPath)
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
        return StzEngineFileDelete(@cFileName)
    
        def DeleteQ()
            This.Delete()
            return This
 
			def Remove()
				This.Delete()

			def RemoveQ()
				return This.DeleteQ()

    def SafeDelete()
        cBackupPath = This.CreateBackup()
        if cBackupPath != ""
            return StzEngineFileDelete(@cFileName)
        else
            StzRaise("Cannot create backup before deletion")
        ok
    
        def SafeDeleteQ()
            This.SafeDelete()
            return This
    
		def SafeRemove()
			This.SafeDelete()

			def SafeRemoveQ()
				return This.SafeDeleteQ()

    # PERMISSION OPERATIONS

    def MakeReadOnly()
        if isWindows()
            system("attrib +R " + '"' + @cFileName + '"')
        else
            system("chmod a-w " + '"' + @cFileName + '"')
        ok
        return 1

        def MakeReadOnlyQ()
            This.MakeReadOnly()
            return This

    def MakeWritable()
        if isWindows()
            system("attrib -R " + '"' + @cFileName + '"')
        else
            system("chmod u+w " + '"' + @cFileName + '"')
        ok
        return 1

        def MakeWritableQ()
            This.MakeWritable()
            return This

    def MakeExecutable()
        if isWindows()
            return 1
        else
            system("chmod u+x " + '"' + @cFileName + '"')
        ok
        return 1

        def MakeExecutableQ()
            This.MakeExecutable()
            return This
    
	# ENCRYPT/DECRYPT OPERATIONS (from stzCrypto) #TODO

	/* ... */

    # UTILITY METHODS

    def FileName()
        return @cFileName
    
    def Size()
        return StzEngineFileSize(@cFileName)

    def Exists()
        return fexists(@cFileName)

    def IsReadOnly()
        return not This.IsWritable()

    def IsWritable()
        try
            fp = fopen(@cFileName, "a")
            if fp != NULL
                fclose(fp)
                return TRUE
            ok
        catch
        done
        return FALSE

    def IsExecutable()
        cExt = lower(_FileExtension(@cFileName))
        if isWindows()
            return cExt = "exe" or cExt = "bat" or cExt = "cmd" or cExt = "com"
        ok
        return FALSE

    def LastModified()
        return ""

    def Close()
        return 1
