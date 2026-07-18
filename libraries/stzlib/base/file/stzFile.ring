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


  ///////////////////////////////////////////////
 ///   ENGINE-BACKED FILE/DIR/PATH FUNCTIONS ///
///////////////////////////////////////////////

# Standalone Softanza wrappers around the Zig engine DLL.
# These provide a simple functional API for file I/O,
# directory management, and path parsing.

  ///   FILE FUNCTIONS    ///

func StzFileExists(pcPath)
	return StzEngineFileExists(pcPath)

func StzFileSize(pcPath)
	return StzEngineFileSize(pcPath)

func StzFileRead(pcPath)
	return StzEngineFileRead(pcPath)

func StzFileWrite(pcPath, pcContent)
	return StzEngineFileWrite(pcPath, pcContent)

func StzFileAppend(pcPath, pcContent)
	return StzEngineFileAppend(pcPath, pcContent)

func StzFileDelete(pcPath)
	return StzEngineFileDelete(pcPath)

func StzFileCopy(pcSrc, pcDst)
	return StzEngineFileCopy(pcSrc, pcDst)

  ///   DIR FUNCTIONS      ///

func StzDirExists(pcPath)
	return StzEngineDirExists(pcPath)

func StzDirCreate(pcPath)
	return StzEngineDirCreate(pcPath)

func StzDirCreatePath(pcPath)
	return StzEngineDirCreatePath(pcPath)

	func StzDirCreateAll(pcPath)
		return StzDirCreatePath(pcPath)

func StzDirDelete(pcPath)
	return StzEngineDirDelete(pcPath)

func StzDirCountFiles(pcPath)
	return StzEngineDirCountFiles(pcPath)

func StzDirCountDirs(pcPath)
	return StzEngineDirCountDirs(pcPath)

  ///   PATH FUNCTIONS      ///

func StzPathExtension(pcPath)
	return StzEnginePathExtension(pcPath)

	func StzFileExtension(pcPath)
		return StzPathExtension(pcPath)

func StzPathBasename(pcPath)
	return StzEnginePathBasename(pcPath)

	func StzFileName(pcPath)
		return StzPathBasename(pcPath)

func StzPathDirname(pcPath)
	return StzEnginePathDirname(pcPath)

	func StzFileDir(pcPath)
		return StzPathDirname(pcPath)


func FileExists(_cFullPath_)
    return StzFileExists(_cFullPath_)

	func @FileExists(_cFullPath_)
		return StzFileExists(_cFullPath_)

	func IsFile(_cFullPath_)
		return StzFileExists(_cFullPath_)

	func @IsFile(_cFullPath_)
		return StzFileExists(_cFullPath_)

	func IsValidFile(_cFullPath_)
		return StzFileExists(_cFullPath_)

	func @IsValidFile(_cFullPath_)
		return StzFileExists(_cFullPath_)

	#--

	func FilePathExists(_cFullPath_)
		return StzFileExists(_cFullPath_)

	func @FilePathExists(_cFullPath_)
		return StzFileExists(_cFullPath_)

	func IsFilePath(_cFullPath_)
		return StzFileExists(_cFullPath_)

	func @IsFilePath(_cFullPath_)
		return StzFileExists(_cFullPath_)

	func IsValidFilePath(_cFullPath_)
		return StzFileExists(_cFullPath_)

	func @IsValidFilePath(_cFullPath_)
		return StzFileExists(_cFullPath_)

	#>

func StzFileReadQ(cFile)
    # Pure reading intent - read-only access
    return new stzFileReader(cFile)

	func FileReadQ(cFile)
		return StzFileReadQ(cFile)

	func @FileReadQ(cFile)
		return StzFileReadQ(cFile)

func FileRead(cFile)
	return StzFileRead(cFile)

	func @FileRead(cFile)
		return StzFileRead(cFile)

func StzFileInfoQ(cFile)
	# Intent to get information without opening file
	return new stzFileInfo(cFile)

	func FileInfoQ(cFile)
		return StzFileInfoQ(cFile)

	func @FileInfoQ(cFile)
		return StzFileInfoQ(cFile)

func StzFileInfo(cFile)
	return StzFileInfoQ(cFile).Info()

	func FileInfo(cFile)
		return StzFileInfo(cFile)

	func @FileInfo(cFile)
		return StzFileInfo(cFile)

func StzFileInfoXT(cFile)
	return StzFileInfoQ(cFile).InfoXT()

	func FileInfoXT(cFile)
		return StzFileInfoXT(cFile)

	func @FileInfoXT(cFile)
		return StzFileInfoXT(cFile)

func StzCopyFileContent(cSource, cDest)
	if NOT fexists(cSource)
		stzraise("Source file does not exist: " + cSource)
	ok

	# Extract and create destination directory if needed
	_cDestDir_ = ""
	for i = StzLen(cDest) to 1 step -1
		if cDest[i] = "/" or cDest[i] = "\"
			_cDestDir_ = StzLeft(cDest, i - 1)
			exit
		ok
	next

	if _cDestDir_ != "" and NOT isdir(_cDestDir_)
		if StzEngineDirCreatePath(_cDestDir_) = 0
			stzraise("Cannot create destination directory: " + _cDestDir_)
		ok
	ok

	_cContent_ = read(cSource)
	write(cDest, _cContent_)

	func CopyFileContent(cSource, cDest)
		return StzCopyFileContent(cSource, cDest)

func StzListFiles(cDir)
	_aFiles_ = []
	_aList_ = @dir(cDir)
	_nLen_ = len(_aList_)

	for i = 1 to _nLen_
		if _aList_[i][2] = 0  # Files only
			_aFiles_ + _aList_[i][1]
		ok
	next

	return _aFiles_

	func ListFiles(cDir)
		return StzListFiles(cDir)

func StzFileModifTime(cFile)
	if NOT fexists(cFile)
		return 0
	ok
	return 0

	func FileModifTime(cFile)
		return StzFileModifTime(cFile)

	func FileModificationTime(cFile)
		return StzFileModifTime(cFile)

	func filemtime(cFile)
		return StzFileModifTime(cFile)

# Appending to a file -- OBJECT-ONLY intent (per the unified Q convention):
# you need the returned appender to be usable, so the bare FileAppend() and
# FileAppendQ() do the SAME thing -- both return the appender object. The file
# is created if it does not exist (append-or-create). For a one-shot raw
# append use the low-level StzFileAppend(file, text) further below.

func FileAppend(cFileName)
	return StzFileAppendQ(cFileName)

	#< @FunctionFluentForm

	func StzFileAppendQ(cFileName)
		# Append-or-create (the constructor creates the file if missing).
		return new stzFileAppender(cFileName)

	func FileAppendQ(cFileName)
		return StzFileAppendQ(cFileName)

	#>

	#< @FunctionAlternativeForms

	func AppendFile(cFileName)
		return StzFileAppendQ(cFileName)

	func AppendFileQ(cFileName)
		return StzFileAppendQ(cFileName)

	#--

	func @FileAppend(cFileName)
		return StzFileAppendQ(cFileName)

		func @FileAppendQ(cFileName)
			return StzFileAppendQ(cFileName)

	func @AppendFile(cFileName)
		return StzFileAppendQ(cFileName)

		func @AppendFileQ(cFileName)
			return StzFileAppendQ(cFileName)

	#>

func StzFileCreate(cFileName)
	if StzFileExists(cFileName)
		StzRaise("Can't proceed! The file already exists: " + cFileName)
	ok

	_oFile_ = new stzFileCreator(cFileName)
	_oFile_.Close()
	return 1

	#< @FunctionFluentForm

	func StzFileCreateQ(cFileName)
		if StzFileExists(cFileName)
			StzRaise("Can't proceed! The file already exists: " + cFileName)
		ok
		_oFile_ = new stzFileCreator(cFileName)
		return _oFile_
	#>

	#< @FunctionAlternativeForms

	func FileCreate(cFileName)
		return StzFileCreate(cFileName)

		func FileCreateQ(cFileName)
			return StzFileCreateQ(cFileName)

	func CreateFile(cFileName)
		return StzFileCreate(cFileName)

		func CreateFileQ(cFileName)
			return StzFileCreateQ(cFileName)

	func @FileCreate(cFileName)
		return StzFileCreate(cFileName)

		func @FileCreateQ(cFileName)
			return StzFileCreateQ(cFileName)

	func @CreateFile(cFileName)
		return StzFileCreate(cFileName)

		func @CreateFileQ(cFileName)
			return StzFileCreate(cFileName)
	#>

func StzFileOverwrite(cFileName, _cNewContent_)
    _oFile_ = StzFileOverwiteQ(cFileName, _cNewContent_)
	_oFile_.Close()
	return 1

	#< @FunctionAlternativeForms

	func FileOverwrite(cFileName, _cNewContent_)
		return StzFileOverwrite(cFileName, _cNewContent_)

	func FileOverrite(cFileName, _cNewContent_)
		return StzFileOverwrite(cFileName, _cNewContent_)

	func OverwriteFile(cFileName, _cNewContent_)
		return StzFileOverwrite(cFileName, _cNewContent_)

	#--

	func @FileOverwrite(cFileName, _cNewContent_)
		return StzFileOverwrite(cFileName, _cNewContent_)

	func @FileOverrite(cFileName, _cNewContent_)
		return StzFileOverwrite(cFileName, _cNewContent_)

	func @OverwriteFile(cFileName, _cNewContent_)
		return StzFileOverwrite(cFileName, _cNewContent_)

	#>


func StzFileOverwiteQ(cFileName, _cNewContent_)
    # Immediate operation - replaces entire file content
    if not StzFileExists(cFileName)
        StzRaise("Cannot overwrite content of non-existent file: " + cFileName)
    ok

    StzEngineFileWrite(cFileName, _cNewContent_)
    return NULL

	# NOTE: the old 2-arg "Q returns a value" overwrite aliases were removed.
	# Under the unified convention Q ALWAYS returns the object, so the only
	# Q form is FileOverwriteQ(file) -> stzFileOverwriter (defined below). The
	# one-shot value form stays as the bare FileOverwrite(file, content)->bool.
	# (StzFileOverwiteQ above is internal -- used by StzFileOverwrite.)

# Pure-intent overwriter: returns a stzFileOverwriter object so the
# caller can inspect OriginalContent() / OriginalLines() before
# committing. Test-facing 1-arg form -- companion to the 2-arg
# StzFileOverwrite(file, content) one-shot above.
# FileOverwrite is a VALUE intent: the bare FileOverwrite(file, content) does
# the one-shot overwrite and returns TRUE/FALSE (above). The OBJECT lives
# behind the Q form, FileOverwriteQ(file), for read-original-then-replace.
func FileOverwriteQ(cFileName)
	return new stzFileOverwriter(cFileName)

	func FileOverwriter(cFileName)   # alias of FileOverwriteQ
		return new stzFileOverwriter(cFileName)

	func @FileOverwriteQ(cFileName)  # @-form for in-class delegation
		return new stzFileOverwriter(cFileName)

# FileUpdate is an OBJECT-ONLY intent (per the unified Q convention): you need
# the modifier to be usable (Replace/Insert/Remove before Close), so the bare
# FileUpdate() and FileUpdateQ() do the SAME thing -- both return the object.
# For a one-shot raw replacement use StzFileModify(file, old, new).
func FileUpdate(cFileName)
	return new stzFileModifier(cFileName)

	func FileUpdateQ(cFileName)
		return new stzFileModifier(cFileName)

	func FileModifier(cFileName)   # alias of FileUpdate
		return new stzFileModifier(cFileName)

	func FileUpdater(cFileName)
		return new stzFileModifier(cFileName)

	func @FileUpdate(cFileName)   # @-forms for in-class delegation
		return new stzFileModifier(cFileName)

	func @FileUpdateQ(cFileName)
		return new stzFileModifier(cFileName)

# FileManage is an OBJECT-ONLY intent: bare FileManage() and FileManageQ() both
# return the manager object (no useful scalar value for disk management). Kept
# HERE in the functions region -- a func defined between two classes attaches
# to the preceding class instead of registering as a global.
func StzFileManage(cFileName)
	return new stzFileManager(cFileName)

	func FileManage(cFileName)
		return StzFileManage(cFileName)

	func FileManageQ(cFileName)
		return StzFileManage(cFileName)

	func @FileManage(cFileName)
		return StzFileManage(cFileName)

	func @FileManageQ(cFileName)
		return StzFileManage(cFileName)

func StzFileErase(cFileName)
    if not StzFileExists(cFileName)
        StzRaise("Cannot erase non-existent file: " + cFileName)
    ok
	_oFile_ = new stzFileEraser(cFileName)
	_oFile_.Erase()
	return 1

	#< @FunctionFluentForm

	func StzFileEraseQ(cFileName)
	    if not StzFileExists(cFileName)
	        StzRaise("Cannot erase non-existent file: " + cFileName)
	    ok
		_oFile_ = new stzFileEraser(cFileName)
		_oFile_.Erase()
		return StzFileAppend(cFileName)

	#>

	#< @FunctionAlternativeForms

	func FileErase(cFileName)
		return StzFileErase(cFileName)

		func FileEraseQ(cFileName)
			return StzFileEraseQ(cFileName)

	func EraseFile(cFileName)
		return StzFileErase(cFileName)

		func EraseFileQ(cFileName)
			return StzFileEraseQ(cFileName)

	#--

	func @FileErase(cFileName)
		return StzFileErase(cFileName)

		func @FileEraseQ(cFileName)
			return StzFileEraseQ(cFileName)

	func @EraseFile(cFileName)
		return StzFileErase(cFileName)

		func @EraseFileQ(cFileName)
			return StzFileEraseQ(cFileName)

	#>

func StzFileSafeErase(cFileName)

    if not StzFileExists(cFileName)
        StzRaise("Cannot erase non-existent file: " + cFileName)
    ok

	StzFileBackup(cFileName)

	_oFile_ = new stzFileEraser(cFileName)
	_oFile_.Erase()
	return 1

	#< @FunctionFluentForm

	func StzFileSafeEraseQ(cFileName)

	    if not StzFileExists(cFileName)
	        StzRaise("Cannot erase non-existent file: " + cFileName)
	    ok

		StzFileBackup(cFileName)

		_oFile_ = new stzFileEraser(cFileName)
		_oFile_.Erase()
		return StzFileAppend(cFileName)
	#>

	#< @FunctionAlternativeForms

	func FileSafeErase(cFileName)
		return StzFileSafeErase(cFileName)

		func FileSafeEraseQ(cFileName)
			return StzFileSafeEraseQ(cFileName)

	func SafEraseFile(cFileName)
		return StzFileSafeErase(cFileName)

		func SafeEraseFileQ(cFileName)
			return StzFileSafeEraseQ(cFileName)

	#--

	func @FileSafeErase(cFileName)
		return StzFileSafeErase(cFileName)

		func @FileSafeEraseQ(cFileName)
			return StzFileSafeEraseQ(cFileName)

	func @SafEraseFile(cFileName)
		return StzFileSafeErase(cFileName)

		func @SafeEraseFileQ(cFileName)
			return StzFileSafeEraseQ(cFileName)

	#>

func StzFileBackup(cFileName)
    if NOT StzFileExists(cFileName)
		StzRaise("Cannot backup a non-existent file: " + cFileName)
	ok

    _ofileManager_ = new stz FileManager(cFileName)
	_ofileManager_.Backup()
	return 1

	func FileBackup(cFileName)
		return StzFileBackup(cFileName)

	func BackupFile(cFileName)
		return StzFileBackup(cFileName)

	func @FileBackup(cFileName)
		return StzFileBackup(cFileName)

	func @BackupFile(cFileName)
		return StzFileBackup(cFileName)

func StzFileSafeOverwrite(cFileName, _cNewContent_)
    # Creates timestamped backup before overwriting
	StzFileBackup(cFileName)
    StzFileOverwrite(cFileName, _cNewContent_)
	return 1

	#< @FunctionAlternativeForms

	func FileSafeOverwrite(cFileName, _cNewContent_)
		return StzFileSafeOverwrite(cFileName, _cNewContent_)

	func SafeOverwriteFile(cFileName, _cNewContent_)
		return StzFileSafeOverwrite(cFileName, _cNewContent_)

	func FileSafeOverrite(cFileName, _cNewContent_)
		return StzFileSafeOverwrite(cFileName, _cNewContent_)

	func SafeOverriteFile(cFileName, _cNewContent_)
		return StzFileSafeOverwrite(cFileName, _cNewContent_)

	#--

	func @FileSafeOverwrite(cFileName, _cNewContent_)
		return StzFileSafeOverwrite(cFileName, _cNewContent_)

	func @SafeOverwriteFile(cFileName, _cNewContent_)
		return StzFileSafeOverwrite(cFileName, _cNewContent_)

	func @FileSafeOverrite(cFileName, _cNewContent_)
		return StzFileSafeOverwrite(cFileName, _cNewContent_)

	func @SafeOverriteFile(cFileName, _cNewContent_)
		return StzFileSafeOverwrite(cFileName, _cNewContent_)

	#>

func StzFileModify(cFileName, cOldContent, _cNewContent_)
    if NOT StzFileExists(cFileName)
		StzRaise("Cannot modify a non-existent file: " + cFileName)
	ok

	_oFileModifier_ = new stzFileModifier(cFileName)
	_oFileModifier_.Modify(cOldContent, _cNewContent_)
	return 1

	func FileModify(cFileName, cOldContent, _cNewContent_)
		return StzFileModify(cFileName, cOldContent, _cNewContent_)

	func ModifyFile(cFileName, cOldContent, _cNewContent_)
		return StzFileModify(cFileName, cOldContent, _cNewContent_)

	func @FileModify(cFileName, cOldContent, _cNewContent_)
		return StzFileModify(cFileName, cOldContent, _cNewContent_)

	func @ModifyFile(cFileName, cOldContent, _cNewContent_)
		return StzFileModify(cFileName, cOldContent, _cNewContent_)


func FileCopy(cSource, cDestination)
    if not StzFileExists(cSource)
        StzRaise("Cannot copy non-existent file: " + cSource)
    ok
    return StzFileCopy(cSource, cDestination)

	func CopyFile(cSource, cDestination)
		return FileCopy(cSource, cDestination)

	func @FileCopy(cSource, cDestination)
		return FileCopy(cSource, cDestination)

	func @CopyFile(cSource, cDestination)
		return FileCopy(cSource, cDestination)


func StzFileMove(cSource, cDestination)
    if not StzFileExists(cSource)
        StzRaise("Cannot move non-existent file: " + cSource)
    ok
    if StzEngineFileCopy(cSource, cDestination) = 1
        StzEngineFileDelete(cSource)
        return 1
    ok
    return 0

	func FileMove(cSource, cDestination)
		return StzFileMove(cSource, cDestination)

	func MoveFile(cSource, cDestination)
		return StzFileMove(cSource, cDestination)

	func @FileMove(cSource, cDestination)
		return StzFileMove(cSource, cDestination)

	func @MoveFile(cSource, cDestination)
		return StzFileMove(cSource, cDestination)

func FileDelete(cFileName)
    if not StzFileExists(cFileName)
        StzRaise("Cannot Remove non-existent file: " + cFileName)
    ok
    return StzFileDelete(cFileName)

	#< @FunctionAlternativeForms

	func DeleteFile(cFileName)
		return FileDelete(cFileName)

	func @FileDelete(cFileName)
		return FileDelete(cFileName)

	func @DeleteFile(cFileName)
		return FileDelete(cFileName)

	#--

	func FileRemove(cFileName)
		return FileDelete(cFileName)

	func RemoveFile(cFileName)
		return FileDelete(cFileName)

	func @FileRemove(cFileName)
		return FileDelete(cFileName)

	func @RemoveFile(cFileName)
		return FileDelete(cFileName)

	#>

func FileSize(cFileName)
    if not StzFileExists(cFileName)
        StzRaise("Cannot get size of non-existent file: " + cFileName)
    ok
    return StzFileSize(cFileName)

	func FileSizeInBytes(cFileName)
		return FileSize(cFileName)


func StzFileCreateIfInexistant(cFilePath)
    if NOT fexists(cFilePath)
        _fp_ = fopen(cFilePath, "w")
        fclose(_fp_)
    ok

	func FileCreateIfInexistant(cFilePath)
		StzFileCreateIfInexistant(cFilePath)

	func CreateFileIfInexistant(cFilePath)
		StzFileCreateIfInexistant(cFilePath)

	func @FileCreateIfInexistant(cFilePath)
		StzFileCreateIfInexistant(cFilePath)

	func @CreateFileIfInexistant(cFilePath)
		StzFileCreateIfInexistant(cFilePath)


#---

# Short form - relative/normalized paths
func StzNormalizeFilePath(_cName_)
	if CheckParams()
		if NOT ( isString(_cName_) and trim(_cName_) != "" )
			StzRaise("Incorrect param type! cName must be a non-empty string.")
		ok
	ok

	_cResult_ = StzLower(trim(_cName_))
	_cResult_ = StzReplace(_cResult_, "\", "/")
	_cResult_ = StzReplace(_cResult_, "//", "/")
	return _cResult_

	func NormalizeFilePath(_cName_)
		return StzNormalizeFilePath(_cName_)

	func NormaliseFilePath(_cName_)
		return StzNormalizeFilePath(_cName_)

func StzNormalizeFilePathXT(_cName_)
	if CheckParams()
		if NOT ( isString(_cName_) and trim(_cName_) != "" )
			StzRaise("Incorrect param type! cName must be a non-empty string.")
		ok
	ok

	_cName_ = trim(_cName_)

	if StzLeft(_cName_, 1) != "/" and StzFindFirst(":/", _cName_) = 0
		_cName_ = currentdir() + "/" + _cName_
	ok

	_cResult_ = StzLower(_cName_)
	_cResult_ = StzReplace(_cResult_, "\", "/")
	_cResult_ = StzReplace(_cResult_, "//", "/")
	return _cResult_

	func NormalizeFilePathXT(_cName_)
		return StzNormalizeFilePathXT(_cName_)

	func NormaliseFilePathXT(_cName_)
		return StzNormalizeFilePathXT(_cName_)

class stzFileXT from stzObject

	def init(pcFileName, pcIntent)
		pcIntent = StzLower(pcIntent)

		if pcIntent = "info"
			# Was `new stzFileInfo(cFileName)` -- cFileName is
			# undefined (the param is pcFileName). R24 every call.
			return new stzFileInfo(pcFileName)

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
	_nPos_ = 0
	for i = StzLen(cPath) to 1 step -1
		if cPath[i] = "/" or cPath[i] = "\"
			_nPos_ = i
			exit
		ok
	next
	if _nPos_ > 0
		return StzRight(cPath, StzLen(cPath) - _nPos_)
	ok
	return cPath

func _FileDirPath(cPath)
	_nPos_ = 0
	for i = StzLen(cPath) to 1 step -1
		if cPath[i] = "/" or cPath[i] = "\"
			_nPos_ = i
			exit
		ok
	next
	if _nPos_ > 0
		return StzLeft(cPath, _nPos_ - 1)
	ok
	return "."

func _FileExtension(cPath)
	_cName_ = _FileName(cPath)
	_nDot_ = 0
	for i = StzLen(_cName_) to 1 step -1
		if _cName_[i] = "."
			_nDot_ = i
			exit
		ok
	next
	if _nDot_ > 0
		return StzRight(_cName_, StzLen(_cName_) - _nDot_)
	ok
	return ""

func _FileCompleteBaseName(cPath)
	_cName_ = _FileName(cPath)
	_nDot_ = 0
	for i = StzLen(_cName_) to 1 step -1
		if _cName_[i] = "."
			_nDot_ = i
			exit
		ok
	next
	if _nDot_ > 1
		return StzLeft(_cName_, _nDot_ - 1)
	ok
	return _cName_

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

        def SizeInBytes()
            # Must be defined here: without it, the call resolves to an
            # inherited stzObject method that returns the OBJECT's repr size
            # (e.g. 553), not the file's byte size.
            return This.Size()

    def FileName()
        return @cFileName

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
        _cExt_ = StzLower(StzEnginePathExtension(@cFileName))
        return _cExt_ = "exe" or _cExt_ = "bat" or _cExt_ = "cmd" or _cExt_ = "com"

    def IsHidden()
        _cBase_ = StzEnginePathBasename(@cFileName)
        if len(_cBase_) > 0 and StzLeft(_cBase_, 1) = "."
            return 1
        ok
        return 0

    def CreationTime()
        StzRaise("Unsupported feature!")

    def LastModificationTime()
        # Unix epoch SECONDS of the last modification (via the Softanza Zig
        # engine's stat()). Returns 0 if the file is missing.
        _nSecs_ = StzEngineFileMTime(@cFileName)
        if _nSecs_ < 0 return 0 ok
        return _nSecs_

        def LastModifiedSeconds()
            return This.LastModificationTime()

        def LastModified()
            # Human-readable form, formatted from the epoch via stzDateTime.
            _nSecs_ = This.LastModificationTime()
            if _nSecs_ = 0 return "" ok
            _oDT_ = new stzDateTime([ :FromEpochSeconds = _nSecs_ ])
            return _oDT_.ToString()

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
        _cBase_ = StzEnginePathBasename(@cFileName)
        _nDot_ = StzFindFirst(".", _cBase_)
        if _nDot_ > 0
            return StzLeft(_cBase_, _nDot_ - 1)
        ok
        return _cBase_

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
        _aLines_ = This.Lines()
        return _aLines_[StzLen(_aLines_)]
    
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
        _cContent_ = This.Content()
        return StzFindFirst(cSearchText, _cContent_)
    
    def ContainsText(cSearchText)
        return This.FindText(cSearchText) > 0
    
    def CountOccurrences(cSearchText)
        return StringNumberOfOccurrence(This.Content(), cSearchText)
    
		def NumberOfOccurrences(cSearchText)
			return This.CountOccurrences(cSearchText)

		def NumberOfOccurrence(cSearchText)
			return This.CountOccurrences(cSearchText)

    def LinesContaining(cSearchText)
        _aLines_ = This.Lines()
        _aResult_ = []
	   _nLen_ = len(_aLines_)
        for i = 1 to _nLen_
            if StzFindFirst(cSearchText, _aLines_[i]) > 0
                _aResult_ + [i, _aLines_[i]]
            ok
        next
        return _aResult_
    
    def LineNumber(cSearchText)
        # Returns line number containing the text
        _aLines_ = This.Lines()
	   _nLen_ = len(_aLines_)
        for i = 1 to _nLen_
            if StzFindFirst(cSearchText, _aLines_[i]) > 0
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
        if not StzFileExists(cFileName)
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
        # Append-or-create: appending to a not-yet-existing file (e.g. a fresh
        # log) creates it empty rather than failing -- this is the universal,
        # logging-friendly semantics the design intends.
        if not StzFileExists(cFileName)
            StzEngineFileWrite(cFileName, "")
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

    def WriteLines(_aLines_)
	   _nLen_ = len(_aLines_)
        for i = 1 to _nLen_
            This.WriteLine(_aLines_[i])
        next
        return 1

	   def WrtiteLinesQ(_aLines_)
			This.WriteLines(_aLines_)
			return This
    
    def WriteTimestamp()
        _cTimeStamp_ = StzTimeStamp()
        This.Write(_cTimeStamp_ + ": ")
    	return 1

	   def WriteTimeStampQ()
		This.WriteStzTimeStamp()
		return This

    def WriteLogEntry(cMessage)
        _cTimeStamp_ = StzTimeStamp()
        This.WriteLine(_cTimeStamp_ + " - " + cMessage)
    	return 1

	   def WriteLogEntryQ(cMessage)
		This.WriteLogEntryQ(cMessage)
		return This

    def WriteSeparator(_cChar_)
        if _cChar_ = NULL
            _cChar_ = "-"
        ok
        This.WriteLine(RepeatChar(_cChar_, 50))
    	return 1

	   def WriteSeparatorQ(_cChar_)
		This.WriteSeparator(_cChar_)
		return This

	   #-- @Misspelled

	   def WriteSeperator(_cChar_)
		This.WriteSeparator(_cChar_)

		def WriteSeperatorQ(_cChar_)
			return This.WriteSeparatorQ(_cChar_)

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
# read access, ensuring it doesn't already exists

# Intent: "I want to create a new file"

class stzFileCreator from stzFileReadingMixin
    @cFileName

    def init(cFileName)
        if StzFileExists(cFileName)
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

    def WriteLines(_aLines_)
	   	_nLen_ = len(_aLines_)
        for i = 1 to _nLen_
            This.WriteLine(_aLines_[i])
        next
		return 1

	  def WriteLinesQ(_aLines_)
		This.WriteLines(_aLines_)
		return This
    
    def WriteHeader(cTitle)
        This.WriteLine("# " + cTitle)
        This.WriteLine("# Created: " + StzTimeStamp())
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

        if StzFileExists(cFileName)
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

    def WriteLines(_aLines_)
		_nLen_ = len(_aLines_)
        for i = 1 to _nLen_
            This.WriteLine(_aLines_[i])
        next
		return 1

		def WriteLinesQ(_aLines_)
			This.WriteLines(_aLines_)
			return This
    
    def WriteHeader(cTitle)
        This.WriteLine("# " + cTitle)
        This.WriteLine("# Updated: " + StzTimeStamp())
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

        if StzFileExists(cFileName)
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
			return StzFileAppend(@cFileName)

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
        if not StzFileExists(cFileName)
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
    def ModifyAllContent(_cNewContent_)
        StzEngineFileWrite(@cFileName, _cNewContent_)
		# Re-read so subsequent OriginalContent()/OriginalLines()
		# reflect the new on-disk state. Modifier methods chain on
		# the in-memory snapshot, so keeping it in sync is required
		# for ReplaceLineContaining + InsertLineAtEnd + Remove* etc.
		@cOriginalContent = _cNewContent_
		@aOriginalLines = @Lines(_cNewContent_)
		return 1

	    def ModifyAllContentQ(_cNewContent_)
	        This.ModifyAllContent(_cNewContent_)
	        return This

	    # Word-order alias used by sophisticated-update narratives.
	    def ReplaceAllContent(_cNewContent_)
	        return This.ModifyAllContent(_cNewContent_)

		    def ReplaceAllContentQ(_cNewContent_)
		        This.ModifyAllContent(_cNewContent_)
		        return This

    def ModifyAllContentWith(_cNewContent_)
        This.ModifyAllContent(_cNewContent_)

	    def ModifyAllContentWithQ(_cNewContent_)
	        return This.ModifyAllContentQ(_cNewContent_)

    def ModifyLine(nLineNumber, cNewLine)
        _aLines_ = This.OriginalLines()
        _aLines_[nLineNumber] = cNewLine
        _cNewContent_ = JoinXT(_aLines_, NL)
        This.ModifyAllContent(_cNewContent_)
    	return 1

	    def ModifyLineQ(nLineNumber, cNewLine)
	        This.ModifyLine(nLineNumber, cNewLine)
	        return This

	def InsertLineAt(_nPos_, cNewLine)
	    _aLines_ = @aOriginalLines
	    _nLen_ = len(_aLines_)

	    # Handle empty file case
	    if _nLen_ = 0
	        StzRaise("Cannot insert line in empty file - use ReplaceAllContent() instead")
	    ok
	    
	    # Ensure position is valid for non-empty files
	    if _nPos_ < 1
	        _nPos_ = 1
	    ok

	    if _nPos_ > _nLen_
	        _aLines_ + cNewLine
		else
		   ring_insert(_aLines_, _nPos_, cNewLine)

		ok
	    
	    _cNewContent_ = JoinXT(_aLines_, NL)  # Add newline separator
	    This.ModifyAllContent(_cNewContent_)
		return 1

	    def InsertLineAtQ(_nPos_, cNewLine)
	        This.InsertLineAt(_nPos_, cNewLine)
	        return This

		def InsertLine(_nPos_, cNewLine)
			This.InsertLineAt(_nPos_, nNewLine)

			def InertLineQ(_nPos_, cNewLine)
				return This.InsertLineAtQ(_nPos_, cNewLine)


    def InsertLineAtStart(cNewLine)
        This.InsertLineAt(1, cNewLine)
    	return 1

	    def InsertLineAtStartQ(cNewLine)
	        This.InsertLineAtStart(cNewLine)
	        return This
	 
	def InsertLineAtEnd(cNewLine)
	    _aLines_ = @aOriginalLines
  
	    # Handle empty file case
	    if len(_aLines_) = 0
	        StzRaise("Cannot insert line in empty file - use ReplaceAllContent() instead")
	    ok
	    
	    This.InsertLineAt(len(_aLines_) + 1, cNewLine)
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
        _aLines_ = @aOriginalLines
        if nLineNumber >= 1 and nLineNumber <= len(_aLines_)
            del(_aLines_, nLineNumber)
            _cNewContent_ = JoinXT(_aLines_, NL)
            This.ModifyAllContent(_cNewContent_)
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
        _aLines_ = @aOriginalLines
        _nLen_ = len(_aLines_)

        _anResult_ = []
        for i = 1 to _nLen_
            if StzFindFirst(cSearchText, _aLines_[i]) > 0
                _anResult_ + i
            ok
        next

		return _anResult_

	def LinesContaining(cSearchText)
        _acLines_ = @aOriginalLines
        _nLen_ = len(_acLines_)

        _acResult_ = []
        for i = 1 to _nLen_
            if StzFindFirst(cSearchText, _acLines_[i]) > 0
                _acResult_ + _acLines_[i]
            ok
        next

		return _acResult_


    def RemoveLinesContaining(cSearchText)
        _aLines_ = @aOriginalLines
        _nLen_ = len(_aLines_)

        _aNewLines_ = []
        for i = 1 to _nLen_
            if StzFindFirst(cSearchText, _aLines_[i]) = 0
                _aNewLines_ + _aLines_[i]
            ok
        next

        _cNewContent_ = JoinXT(_aNewLines_, NL)
        This.ModifyAllContent(_cNewContent_)
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
				_cNexText_ = cNewText[2]
			ok

			if NoT isString(cNewText)
				StzRaise("Incorrect param type! cNewText must be a string.")
			ok
		ok

        _cNewContent_ = StzReplace(@cOriginalContent, cOldText, cNewText)
        This.ModifyAllContent(_cNewContent_)
		return 1

	    def ModifyQ(cOldText, cNewText)
	        This.Modify(cOldText, cNewText)
	        return This

		def ModifyText(cOldText, cNewText)
			This.Modify(cOldText, cNewText)
			return 1


    def ReplaceInLine(nLineNumber, cOldText, cNewText)
        _aLines_ = This.OriginalLines()
        _aLines_[nLineNumber] = StzReplace(_aLines_[nLineNumber], cOldText, cNewText)
        _cNewContent_ = JoinXT(_aLines_, NL)
        This.ReplaceAllContent(_cNewContent_)

	    def ReplaceInLineQ(nLineNumber, cOldText, cNewText)
	        This.ReplaceInLine(nLineNumber, cOldText, cNewText)
	        return This

	def ReplaceLineContaining(cSubstr, cNewLine)
	    # Update first line that contains the substring
	    _aLines_ = @aOriginalLines
	    _nLen_ = len(_aLines_)

	    for i = 1 to _nLen_
	        if StzFindFirst(cSubstr, _aLines_[i]) > 0
	            _aLines_[i] = cNewLine
	            exit
	        ok
	    next

	    _cNewContent_ = JoinXT(_aLines_, NL)  # Add newline separator
	    This.ReplaceAllContent(_cNewContent_)
    
	    def ReplaceLineContainingQ(cSubStr, cNewLine)
	        This.ReplaceLineContaining(cSubStr, cNewLine)
	        return This

    def Close()
        return
    

#=========================================#
# MANAGER CLASS - DISK OPERATIONS INTENT  #
#=========================================#
# NOTE: the FileManage()/FileManageQ()/StzFileManage() functions live in the
# functions region above (before the first class) -- a Ring func placed
# BETWEEN two classes is attached to the preceding class instead of being
# registered as a global, which left FileManage() dead (R3).

class stzFileManager from stzObject
    @cFileName
    @bClosed = FALSE

    def init(cFileName)
        if not StzFileExists(cFileName)
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

    def CopyTo(_cDestinationPath_)
        if not StzRight(_cDestinationPath_, 1) = "/"
            _cDestinationPath_ = _cDestinationPath_ + "/"
        ok

        _cDestFile_ = _cDestinationPath_ + _FileName(@cFileName)
        return StzEngineFileCopy(@cFileName, _cDestFile_)

        def CopyToQ(_cDestinationPath_)
            This.CopyTo(_cDestinationPath_)
            return This

    def CopyAs(_cNewFileName_)
        _cDestFile_ = _FileDirPath(@cFileName) + "/" + _cNewFileName_
        return StzEngineFileCopy(@cFileName, _cDestFile_)

        def CopyAsQ(_cNewFileName_)
            This.CopyAs(_cNewFileName_)
            return This

    def CopyToAs(_cDestinationPath_, _cNewFileName_)
        if not StzRight(_cDestinationPath_, 1) = "/"
            _cDestinationPath_ = _cDestinationPath_ + "/"
        ok

        _cDestFile_ = _cDestinationPath_ + _cNewFileName_
        return StzEngineFileCopy(@cFileName, _cDestFile_)
    
        def CopyToAsQ(_cDestinationPath_, _cNewFileName_)
            This.CopyToAs(_cDestinationPath_, _cNewFileName_)
            return This
    
    # MOVE OPERATIONS

    def MoveTo(_cDestinationPath_)
        if not StzRight(_cDestinationPath_, 1) = "/"
            _cDestinationPath_ = _cDestinationPath_ + "/"
        ok

        _cDestFile_ = _cDestinationPath_ + _FileName(@cFileName)
        _bResult_ = StzEngineFileCopy(@cFileName, _cDestFile_)
        if _bResult_ StzEngineFileDelete(@cFileName) @cFileName = _cDestFile_ ok
        return _bResult_

        def MoveToQ(_cDestinationPath_)
            This.MoveTo(_cDestinationPath_)
            return This

    def MoveAs(_cNewFileName_)
        _cDestFile_ = _FileDirPath(@cFileName) + "/" + _cNewFileName_
        _bResult_ = StzEngineFileCopy(@cFileName, _cDestFile_)
        if _bResult_ StzEngineFileDelete(@cFileName) @cFileName = _cDestFile_ ok
        return _bResult_

        def MoveAsQ(_cNewFileName_)
            This.MoveAs(_cNewFileName_)
            return This

    def MoveToAs(_cDestinationPath_, _cNewFileName_)
        if not StzRight(_cDestinationPath_, 1) = "/"
            _cDestinationPath_ = _cDestinationPath_ + "/"
        ok

        _cDestFile_ = _cDestinationPath_ + _cNewFileName_
        _bResult_ = StzEngineFileCopy(@cFileName, _cDestFile_)
        if _bResult_ StzEngineFileDelete(@cFileName) @cFileName = _cDestFile_ ok
        return _bResult_
    
        def MoveToAsQ(_cDestinationPath_, _cNewFileName_)
            This.MoveToAs(_cDestinationPath_, _cNewFileName_)
            return This
    
    # RENAME OPERATIONS

    def RenameAs(_cNewFileName_)
        _cDestFile_ = _FileDirPath(@cFileName) + "/" + _cNewFileName_
        _bResult_ = StzEngineFileCopy(@cFileName, _cDestFile_)
        if _bResult_
            StzEngineFileDelete(@cFileName)
            @cFileName = _cDestFile_
        ok
        return _bResult_
    
        def RenameAsQ(_cNewFileName_)
            This.RenameAs(_cNewFileName_)
            return This
    
	# BACKUP OPERATION

	def Backup()
        _cBackup_ = @cFileName + ".backup." + StzTimeStamp()
        StzFileCopy(@cFileName, _cBackup_) #TODO // use internal methods to the object
		return 1

    # SPLIT OPERATIONS

    def SplitByLines(nLinesPerFile)
        _oReader_ = StzFileRead(@cFileName)
        _aLines_ = _oReader_.Lines()
        _oReader_.Close()
        
        _nTotalLines_ = len(_aLines_)
        _nFileCount_ = ceil(_nTotalLines_ / nLinesPerFile)
        
        _cBaseName_ = _FileCompleteBaseName(@cFileName)
        _cSuffix_ = _FileExtension(@cFileName)
        _cDirPath_ = _FileDirPath(@cFileName)
        
        _aCreatedFiles_ = []
        
        for nFile = 1 to _nFileCount_
            _nStartLine_ = ((nFile - 1) * nLinesPerFile) + 1
            _nEndLine_ = min(nFile * nLinesPerFile, _nTotalLines_)
            
            _cNewFileName_ = _cBaseName_ + "_" + nFile + "." + _cSuffix_
            _cFullPath_ = _cDirPath_ + "/" + _cNewFileName_
            
            _oCreator_ = StzFileCreate(_cFullPath_)
            for nLine = _nStartLine_ to _nEndLine_
                _oCreator_.WriteLine(_aLines_[nLine])
            next
            _oCreator_.Close()
            
            _aCreatedFiles_ + _cFullPath_
        next
        
        return _aCreatedFiles_
    
        def SplitByLinesQ(nLinesPerFile)
            This.SplitByLines(nLinesPerFile)
            return This
    
    def SplitBySize(nBytesPerFile)
        _oReader_ = StzFileRead(@cFileName)
        _cContent_ = _oReader_.Content()
        _oReader_.Close()

        _nTotalSize_ = len(_cContent_)
        _nFileCount_ = ceil(_nTotalSize_ / nBytesPerFile)

        _cBaseName_ = _FileCompleteBaseName(@cFileName)
        _cSuffix_ = _FileExtension(@cFileName)
        _cDirPath_ = _FileDirPath(@cFileName)

        _aCreatedFiles_ = []

        for nFile = 1 to _nFileCount_
            _nStartPos_ = ((nFile - 1) * nBytesPerFile) + 1
            _nEndPos_ = min(nFile * nBytesPerFile, _nTotalSize_)

            _cChunk_ = StzMid(_cContent_, _nStartPos_, _nEndPos_ - _nStartPos_ + 1)
            
            _cNewFileName_ = _cBaseName_ + "_" + nFile + "." + _cSuffix_
            _cFullPath_ = _cDirPath_ + "/" + _cNewFileName_
            
            _oCreator_ = StzFileCreate(_cFullPath_)
            _oCreator_.Write(_cChunk_)
            _oCreator_.Close()
            
            _aCreatedFiles_ + _cFullPath_
        next
        
        return _aCreatedFiles_
    
        def SplitBySizeQ(nBytesPerFile)
            This.SplitBySize(nBytesPerFile)
            return This
    
    def SplitByPattern(cPattern)
        _oReader_ = StzFileRead(@cFileName)
        _aLines_ = _oReader_.Lines()
        _oReader_.Close()

        _cBaseName_ = _FileCompleteBaseName(@cFileName)
        _cSuffix_ = _FileExtension(@cFileName)
        _cDirPath_ = _FileDirPath(@cFileName)

        _aCreatedFiles_ = []
        _aCurrentChunk_ = []
        _nFileNum_ = 1

        _nLen_ = len(_aLines_)
        for i = 1 to _nLen_
            if StzFindFirst(cPattern, _aLines_[i]) > 0 and len(_aCurrentChunk_) > 0
                _cNewFileName_ = _cBaseName_ + "_" + _nFileNum_ + "." + _cSuffix_
                _cFullPath_ = _cDirPath_ + "/" + _cNewFileName_
                
                _oCreator_ = StzFileCreate(_cFullPath_)
                _nChunkLen_ = len(_aCurrentChunk_)
                for j = 1 to _nChunkLen_
                    _oCreator_.WriteLine(_aCurrentChunk_[j])
                next
                _oCreator_.Close()
                
                _aCreatedFiles_ + _cFullPath_
                _nFileNum_ = _nFileNum_ + 1
                _aCurrentChunk_ = []
            ok
            
            _aCurrentChunk_ + _aLines_[i]
        next
        
        if len(_aCurrentChunk_) > 0
            _cNewFileName_ = _cBaseName_ + "_" + _nFileNum_ + "." + _cSuffix_
            _cFullPath_ = _cDirPath_ + "/" + _cNewFileName_
            
            _oCreator_ = StzFileCreate(_cFullPath_)
            _nChunkLen_ = len(_aCurrentChunk_)
            for j = 1 to _nChunkLen_
                _oCreator_.WriteLine(_aCurrentChunk_[j])
            next
            _oCreator_.Close()
            
            _aCreatedFiles_ + _cFullPath_
        ok
        
        return _aCreatedFiles_
    
        def SplitByPatternQ(cPattern)
            This.SplitByPattern(cPattern)
            return This
    
    # ZIP OPERATIONS (Delegated to stzZipFile)

    def ZipAs(_cZipFileName_)
        # Create zip containing this file
        _oZip_ = new stzZipFile(_cZipFileName_)
        return _oZip_.CreateFromSingleFile(@cFileName)
    
        def ZipAsQ(_cZipFileName_)
            This.ZipAs(_cZipFileName_)
            return This
    
    def ZipWith(_aFiles_, _cZipFileName_)
        # Create zip with this file + additional files
        _oZip_ = new stzZipFile(_cZipFileName_)
        _aAllFiles_ = [@cFileName] + _aFiles_
        return _oZip_.CreateFrom(_aAllFiles_)
    
        def ZipWithQ(_aFiles_, _cZipFileName_)
            This.ZipWith(_aFiles_, _cZipFileName_)
            return This
    
    def ZipToDirectory(_cZipFileName_, _cTargetDir_)
        # Create zip in specified directory
        if not StzRight(_cTargetDir_, 1) = "/"
            _cTargetDir_ = _cTargetDir_ + "/"
        ok

        _cFullZipPath_ = _cTargetDir_ + _cZipFileName_
        return This.ZipAs(_cFullZipPath_)
    
        def ZipToDirectoryQ(_cZipFileName_, _cTargetDir_)
            This.ZipToDirectory(_cZipFileName_, _cTargetDir_)
            return This
    
    def AddToZip(_cZipFileName_)
        # Add this file to existing zip
        _oZip_ = new stzZipFile(_cZipFileName_)
        return _oZip_.AddFile(@cFileName)
    
        def AddToZipQ(_cZipFileName_)
            This.AddToZip(_cZipFileName_)
            return This
    
    def ZipSplitFiles(_aFiles_, _cZipFileName_)
        # Create zip containing this file and its split files
        _oZip_ = new stzZipFile(_cZipFileName_)
        _aAllFiles_ = [@cFileName] + _aFiles_
        return _oZip_.CreateFrom(_aAllFiles_)
    
        def ZipSplitFilesQ(_aFiles_, _cZipFileName_)
            This.ZipSplitFiles(_aFiles_, _cZipFileName_)
            return This
    
    def ZipBackup(_cZipFileName_)
        # Create zip backup with timestamp
        if _cZipFileName_ = ""
            _cBaseName_ = _FileCompleteBaseName(@cFileName)
            _cTimeStamp_ = StzTimeStamp()
            _cZipFileName_ = _cBaseName_ + "_backup_" + _cTimeStamp_ + ".zip"
        ok
        
        _cDirPath_ = _FileDirPath(@cFileName)
        _cFullZipPath_ = _cDirPath_ + "/" + _cZipFileName_
        
        return This.ZipAs(_cFullZipPath_)
    
        def ZipBackupQ(_cZipFileName_)
            This.ZipBackup(_cZipFileName_)
            return This
    
    # BACKUP OPERATIONS

    def CreateBackup()
        _cBaseName_ = _FileCompleteBaseName(@cFileName)
        _cSuffix_ = _FileExtension(@cFileName)
        _cDirPath_ = _FileDirPath(@cFileName)
        
        _cTimeStamp_ = StzTimeStamp()
        _cBackupName_ = _cBaseName_ + "_backup_" + _cTimeStamp_ + "." + _cSuffix_
        _cBackupPath_ = _cDirPath_ + "/" + _cBackupName_
        
        _bResult_ = StzEngineFileCopy(@cFileName, _cBackupPath_)
        if _bResult_
            return _cBackupPath_
        else
            return ""
        ok

        def CreateBackupQ()
            This.CreateBackup()
            return This

    def CreateBackupAs(_cBackupName_)
        _cDirPath_ = _FileDirPath(@cFileName)
        _cBackupPath_ = _cDirPath_ + "/" + _cBackupName_

        _bResult_ = StzEngineFileCopy(@cFileName, _cBackupPath_)
        if _bResult_
            return _cBackupPath_
        else
            return ""
        ok
    
        def CreateBackupAsQ(_cBackupName_)
            This.CreateBackupAs(_cBackupName_)
            return This
    
    # DELETE OPERATIONS

    def Delete()
        # Deleting the file ends the management session: there is nothing left
        # to manage, so the manager is auto-closed. A following Close() is then
        # a harmless no-op (Close() automatic after Delete()).
        _bResult_ = StzEngineFileDelete(@cFileName)
        @bClosed = TRUE
        return _bResult_

        def DeleteQ()
            This.Delete()
            return This
 
			def Remove()
				This.Delete()

			def RemoveQ()
				return This.DeleteQ()

    def SafeDelete()
        _cBackupPath_ = This.CreateBackup()
        if _cBackupPath_ != ""
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
            _fp_ = fopen(@cFileName, "a")
            if _fp_ != NULL
                fclose(_fp_)
                return TRUE
            ok
        catch
        done
        return FALSE

    def IsExecutable()
        _cExt_ = StzLower(_FileExtension(@cFileName))
        if isWindows()
            return _cExt_ = "exe" or _cExt_ = "bat" or _cExt_ = "cmd" or _cExt_ = "com"
        ok
        return FALSE

    def LastModified()
        return ""

    def Close()
        @bClosed = TRUE
        return 1

    def IsClosed()
        return @bClosed
