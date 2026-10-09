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

# Write pcContent to pcPath so that ONLY ITS OWNER can read it -- for a key or a
# token that has to exist as a file for a call that wants a path (a TLS client
# key). StzFileManager's MakeReadOnly stops an overwrite and says nothing about
# who may read; this is the other half. The file is created with the narrow
# access from the first byte (a protected DACL on Windows, 0600 elsewhere), an
# existing file is replaced, and the caller deletes it as soon as the call that
# needed it returns. Returns 1 when written; raises when it could not be.
func StzWritePrivateFile(pcPath, pcContent)
	if NOT isString(pcPath) or ring_trim(pcPath) = ""
		stzraise("StzWritePrivateFile: a path is required.")
	ok
	if StzEngineFileWritePrivate(pcPath, "" + pcContent) != 1
		stzraise("StzWritePrivateFile: could not write '" + pcPath + "'.")
	ok
	return 1

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

# Recursively delete a directory and EVERYTHING under it -- files, subdirs, and
# dotfiles (.stzsite, .git-style). StzEngineDirDelete only removes an EMPTY dir
# (it silently no-ops on a non-empty one), so this empties the tree bottom-up
# first. The engine's dir listings include dotfiles (verified), so nothing is
# left behind. Returns TRUE when the path is gone (or never existed), FALSE if
# the directory still stands afterwards.
func StzDirDeleteAll(pcPath)
	_cP_ = "" + pcPath
	if StzEngineDirExists(_cP_) = 0
		return 1
	ok
	_aFiles_ = StzEngineDirListFiles(_cP_)
	_nf_ = len(_aFiles_)
	for _i_ = 1 to _nf_
		StzEngineFileDelete(_cP_ + "/" + _aFiles_[_i_])
	next
	_aDirs_ = StzEngineDirListDirs(_cP_)
	_nd_ = len(_aDirs_)
	for _i_ = 1 to _nd_
		_cSub_ = _aDirs_[_i_]
		if _cSub_ = "." or _cSub_ = ".."
			loop
		ok
		StzDirDeleteAll(_cP_ + "/" + _cSub_)
	next
	StzEngineDirDelete(_cP_)
	return StzEngineDirExists(_cP_) = 0

	func StzDirRemoveAll(pcPath)
		return StzDirDeleteAll(pcPath)

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
    return ""

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
		return _oFile_

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
		return _oFile_
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

# Is meant to build the file object of an intent from its name, but returns an empty object today.
#
# The constructor tries to return the object of the chosen intent (info, read, append, create,
# overwrite, erase, modify, manage), but Ring ignores a value returned by a constructor, so the
# result is an empty stzFileXT. Build the class of the intent yourself: stzFileInfo, stzFileReader,
# stzFileAppender, stzFileCreator, stzFileOverwriter, stzFileModifier or stzFileManager.
#
#   receiver   write("demo_note.txt", "alpha" + char(10) + "beta gamma" + char(10) + "end") o1 = new
#              stzFileXT("demo_note.txt", "info")
#   example    ? isObject(o1)
#              #--> 1
#   see        stzFileInfo, stzFileReader, stzFileManager
class stzFileXT from stzObject

	# Returns an empty stzFileXT object today, instead of the file object of the chosen intent.
	#
	#   pcFileName   the path of the file
	#   pcIntent     info, read, append, create, overwrite, erase, modify or manage
	#   returns      an empty stzFileXT object
	#   note         build stzFileReader, stzFileAppender and the others directly
	#   warning      defect: the constructor returns the object of the chosen class, and Ring
	#                ignores the value a constructor returns, so new stzFileXT(path, "info") has no
	#                FileName and "read" answers NULL to Content; the intent erase names a class
	#                stzFileEraser that does not exist (it is stzFileEaraser) and raises Error in
	#                class name, class not found; an unknown intent raises Can't proceed! The intent
	#                you provided is not support in Softanza file API.
	#   see          stzFileInfo, stzFileReader
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

# Gives information about a file path (name, size, suffix, times, flags) without opening the file for reading.
#
# Reach for it to ask what a file is: Info gives a summary hash list, and the single readers (Size,
# Suffix, BaseName, DirPath, Exists) give one fact each. The path is kept as given and nothing is
# resolved. Two traps today: IsWritable opens the path for appending, so asking about a missing file
# creates it empty (and Info does so too), and IsExecutable answers 0 for every file. CreationTime
# and LastReadingTime raise an error on purpose.
#
#   receiver   write("demo_note.txt", "alpha" + char(10) + "beta gamma" + char(10) + "end") o1 = new
#              stzFileInfo("demo_note.txt")
#   example    ? o1.Exists()
#              #--> 1
#              ? o1.Size()
#              #--> 20
#              ? o1.Suffix()
#              #--> .txt
#              ? o1.BaseName()
#              #--> demo_note
#   see        stzFileReader, stzFileManager, stzFolder
class stzFileInfo from stzObject
    @cFileName

    # Builds an information object for a file path; the file is not opened and need not exist.
    #
    #   cFileName   the path of the file
    #   returns     nothing; the object is built
    #   note        the path is kept as given and never made absolute
    #   see         Info, Exists
    def init(cFileName)
        @cFileName = cFileName


	# Returns the hash list of conditions this intent expects of the file.
	#
	#   returns    a hash list, [ :FilesExists = 1 ]
	#   note       the key is spelt FilesExists here and FileExists in the other file classes
	#   see        Capabilities
	#@ aka  CONDTITIONS AND CAPABILITIES
	def Conditions()
		return [
			:FilesExists = 1
		]

	# Returns what this intent allows: every right is 0, because it only gives information.
	#
	#   returns    a hash list of :Read, :Append, :Create, :Overwrite, :Modify, all 0
	#   note       even :Read is 0, since the file is never opened; Skills is the same call
	#   see        Conditions
	def Capabilities()
		return [
			:Read = 0,
			:Append = 0,
			:Create = 0,
			:Overwrite = 0,
			:Modify = 0
		]

		def Skills()
			return This.Capabilities()

   # Returns a summary of the file as a hash list: name, size, suffix, path, exists, isWritable, isReadable, lastModified.
   #
   #   returns    a hash list
   #   note       the name stops at the first dot, so a.tar.gz gives a; for a missing file size is
   #              -1 and, because IsWritable creates the file, the call leaves an empty file behind
   #   see        Exists, Size, BaseName
   #@ aka  SUMMARISED INFO
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

    # Returns TRUE if a file exists at the path.
    #
    #   returns    TRUE or FALSE
    #   see        Size, Info
    #@ aka  DETAILED INFO METHODS
    def Exists()
        return StzEngineFileExists(@cFileName) = 1

    # Returns the size of the file in bytes; -1 when the file does not exist.
    #
    #   returns    a number
    #   see        Exists, Info
    def Size()
        return StzEngineFileSize(@cFileName)

        def SizeInBytes()
            # Must be defined here: without it, the call resolves to an
            # inherited stzObject method that returns the OBJECT's repr size
            # (e.g. 553), not the file's byte size.
            return This.Size()

    # Returns the path the object was built with.
    #
    #   returns    a text
    #   see        FilePath, BaseName
    def FileName()
        return @cFileName

    # Returns 1 if the file can be opened for appending, but creates an empty file when the path does not exist.
    #
    #   returns    1 or 0
    #   note       check Exists first
    #   warning    warning: the test opens the file in append mode, so asking about a missing path
    #              creates it empty (checked twice, with ghost1.txt and nope2.txt); a read-only file
    #              answers 0
    #   see        IsReadable, Exists
    def IsWritable()
        try
            pFile = fopen(@cFileName, "a")
            if pFile != ""
                fclose(pFile)
                return 1
            ok
        catch
        done
        return 0

    # Returns 1 if the file can be opened for reading, else 0.
    #
    #   returns    1 or 0
    #   see        IsWritable, Exists
    def IsReadable()
        try
            pFile = fopen(@cFileName, "r")
            if pFile != ""
                fclose(pFile)
                return 1
            ok
        catch
        done
        return 0

    # Returns 0 for every file today, because the extension it compares carries a leading dot.
    #
    #   returns    0
    #   note       read Suffix and compare it yourself until this is repaired
    #   warning    defect: the extension is read as .exe or .BAT and compared with exe, bat, cmd and
    #              com, so a file named prog.exe and one named run.BAT both answer 0; the sibling
    #              stzFileManager.IsExecutable fails differently (see there)
    #   see        Suffix, IsHidden
    def IsExecutable()
        _cExt_ = StzLower(StzEnginePathExtension(@cFileName))
        return _cExt_ = "exe" or _cExt_ = "bat" or _cExt_ = "cmd" or _cExt_ = "com"

    # Returns 1 if the file name starts with a dot, else 0.
    #
    #   returns    1 or 0
    #   note       only the dot-name convention is tested, not the hidden attribute of Windows
    #   see        BaseName, FileName
    def IsHidden()
        _cBase_ = StzEnginePathBasename(@cFileName)
        if StzLen(_cBase_) > 0 and StzLeft(_cBase_, 1) = "."
            return 1
        ok
        return 0

    # Raises an error with the text Unsupported feature! instead of giving the creation time.
    #
    #   returns    nothing; it raises an error
    #   note       always raises, whatever the file
    #   see        LastModificationTime, LastReadingTime
    def CreationTime()
        StzRaise("Unsupported feature!")

    # Returns the time of the last change as epoch seconds; 0 when it cannot be read.
    #
    #   returns    a number
    #   note       a missing file gives 0 only if it is not created by an earlier IsWritable
    #   see        LastModified, Exists
    def LastModificationTime()
        # Unix epoch SECONDS of the last modification (via the Softanza Zig
        # engine's stat()). Returns 0 if the file is missing.
        _nSecs_ = StzEngineFileMTime(@cFileName)
        if _nSecs_ < 0 return 0 ok
        return _nSecs_

        def LastModifiedSeconds()
            return This.LastModificationTime()

        # Returns the time of the last change as text such as 2026-10-09 04:34:06; the empty text when it cannot be read.
        #
        #   returns    a text
        #   note       the time zone is that of the engine conversion, not stated by the call
        #   see        LastModificationTime, Info
        def LastModified()
            # Human-readable form, formatted from the epoch via stzDateTime.
            _nSecs_ = This.LastModificationTime()
            if _nSecs_ = 0 return "" ok
            _oDT_ = new stzDateTime([ :FromEpochSeconds = _nSecs_ ])
            return _oDT_.ToString()

    # Raises an error with the text Unsupported feature! Use OS-level tools for file timestamps.
    #
    #   returns    nothing; it raises an error
    #   note       always raises, and so does InfoXT, which calls it
    #   see        LastModificationTime, CreationTime
    def LastReadingTime()
        StzRaise("Unsupported feature! Use OS-level tools for file timestamps.")

        def LastRead()
            return This.LastReadingTime()

    # Returns the path the object was built with.
    #
    #   returns    a text
    #   note       AbsoluteFilePath and CanonicalFilePath return the same text, not a resolved path
    #   see        FileName, DirPath
    def FilePath()
        return @cFileName

    # Returns the path as given, not resolved against the current folder.
    #
    #   returns    a text
    #   note       a relative path stays relative
    #   see        FilePath, CanonicalFilePath
    def AbsoluteFilePath()
        return @cFileName

    # Returns the path as given, not resolved.
    #
    #   returns    a text
    #   note       symbolic links and .. are not followed
    #   see        FilePath, AbsoluteFilePath
    def CanonicalFilePath()
        return @cFileName

    # Returns the folder part of the path, without the file name.
    #
    #   returns    a text
    #   see        FilePath, BaseName
    def DirPath()
        return StzEnginePathDirname(@cFileName)

    # Returns the file name up to its first dot; a name that starts with a dot gives the empty text.
    #
    #   returns    a text
    #   note       a.tar.gz gives a and .hid gives ""
    #   see        CompleteBaseName, Suffix
    def BaseName()
        _cBase_ = StzEnginePathBasename(@cFileName)
        _nDot_ = StzFindFirst(".", _cBase_)
        if _nDot_ > 0
            return StzLeft(_cBase_, _nDot_ - 1)
        ok
        return _cBase_

    # Returns the whole file name, extension included.
    #
    #   returns    a text
    #   note       it is not the name without the last extension: a.tar.gz gives a.tar.gz
    #   see        BaseName, Suffix
    def CompleteBaseName()
        return StzEnginePathBasename(@cFileName)

    # Returns the extension of the file with its dot, such as .txt; the empty text when there is none.
    #
    #   returns    a text
    #   note       a.tar.gz gives .gz
    #   see        CompleteSuffix, BaseName
    def Suffix()
        return StzEnginePathExtension(@cFileName)

    # Returns the extension with its dot, only the last one.
    #
    #   returns    a text
    #   note       it answers what Suffix answers: a.tar.gz gives .gz, not .tar.gz
    #   see        Suffix
    def CompleteSuffix()
        return StzEnginePathExtension(@cFileName)

    # Returns 0 for every file; links are not detected.
    #
    #   returns    0
    #   see        SymLinkTarget
    def IsSymLink()
        return 0

    # Returns the empty text for every file; links are not followed.
    #
    #   returns    a text
    #   see        IsSymLink
    def SymLinkTarget()
        return ""

    # Does nothing; the information is read afresh at each call.
    #
    #   returns    nothing
    #   see        Info
    def Refresh()
        return


#====================================#
# BASE READING CAPABILITIES (MIXIN)  #
#====================================#

# Purpose: This mixin provides universal reading
# capabilities to all file handler classes

# Gives every file class its reading methods: the text, the lines, a search in the text and its size.
#
# This is the shared reading half of stzFileReader, stzFileAppender, stzFileCreator,
# stzFileOverwriter and stzFileModifier; the examples below run through a stzFileReader. The file is
# read again at every call, so the answers follow the disk. An empty file counts one empty line. The
# stzFileModifier class redefines LinesContaining to answer texts only.
#
#   receiver   write("demo_note.txt", "alpha" + char(10) + "beta gamma" + char(10) + "end") o1 = new
#              stzFileReader("demo_note.txt")
#   example    ? @@( o1.Lines() )
#              #--> [ "alpha", "beta gamma", "end" ]
#              ? o1.FindText("beta")
#              #--> 7
#              ? @@( o1.LinesContaining("a") )
#              #--> [ [ 1, "alpha" ], [ 2, "beta gamma" ] ]
#              ? o1.Size()
#              #--> 20
#   see        stzFileReader, stzString
class stzFileReadingMixin from stzObject

    # Returns the whole text of the file as it is on disk now.
    #
    #   returns    a text
    #   note       it reads the file at each call, so it follows changes made by other objects
    #   see        Lines, Size
    def Content()
        return read(@cFileName)
        
        def AllContent()
            return This.Content()
    
    # Returns the lines of the file as a list of texts, without the line breaks.
    #
    #   returns    a list of texts
    #   note       an empty file gives one empty line: [ "" ]
    #   see        Line, NumberOfLines
    def Lines()
        return @Lines(This.Content())
        
        def AllLines()
            return This.Lines()
    
    # Returns the line at position n.
    #
    #   n          the line number, counted from 1
    #   returns    a text
    #   note       a number past the last line raises the error Array Access (Index out of range)
    #   see        FirstLine, LastLine, LineNumber
    def Line(n)
        return This.Lines()[n]
    
		def lineN(n)
			return This.Line(n)

		def NthLine(n)
			return This.Line(n)

    # Returns the first line of the file.
    #
    #   returns    a text
    #   see        LastLine, Line
    def FirstLine()
        return This.Line(1)
    
    # Returns the last line of the file.
    #
    #   returns    a text
    #   note       an empty file gives the empty text
    #   see        FirstLine, Line
    def LastLine()
        _aLines_ = This.Lines()
        return _aLines_[StzLen(_aLines_)]
    
    # Returns how many lines the file has.
    #
    #   returns    a number
    #   note       an empty file counts 1 line; CountLines and HowManyLine are the same call
    #   see        Lines, Size
    def NumberOfLines()
        return len(This.Lines())
    
		# Returns how many lines the file has.
		#
		#   returns    a number
		#   note       an empty file counts 1 line
		#   see        NumberOfLines, CountLines
		def HowManyLine()
			return len(This.Lines())

		# Returns how many lines the file has.
		#
		#   returns    a number
		#   note       an empty file counts 1 line
		#   see        NumberOfLines, HowManyLine
		def CountLines()
			return len(This.Lines())

    # Returns the text of the file as a list-of-bytes object.
    #
    #   returns    a list-of-bytes object
    #   see        Content, Size
    def ContentAsBytes()
        return StzListOfBytesQ(This.Content())
    
    # Returns the size of the file in bytes.
    #
    #   returns    a number
    #   note       -1 when the file has since been deleted
    #   see        IsEmpty, Content
    def Size()
        return StzEngineFileSize(@cFileName)
    
		def SizeInBytes()
			return This.Size()

    # Returns TRUE if the file holds no byte.
    #
    #   returns    TRUE or FALSE
    #   see        Size
    def IsEmpty()
        return This.Size() = 0
    
    # Returns the path the object was built with.
    #
    #   returns    a text
    #   see        Size
    def FileName()
        return @cFileName
    
    # Returns the position of the first occurrence of a text in the file, counted in characters from 1; 0 when absent.
    #
    #   cSearchText   the text to look for
    #   returns       a number
    #   note          the line breaks count as characters: in alpha, beta gamma on three lines beta
    #                 is at 7
    #   see           ContainsText, LineNumber
    def FindText(cSearchText)
        # Returns position of text in file, or 0 if not found
        _cContent_ = This.Content()
        return StzFindFirst(cSearchText, _cContent_)
    
    # Returns TRUE if the text occurs anywhere in the file.
    #
    #   cSearchText   the text to look for
    #   returns       TRUE or FALSE
    #   see           FindText, LinesContaining
    def ContainsText(cSearchText)
        return This.FindText(cSearchText) > 0
    
    # Returns how many times a text occurs in the file.
    #
    #   cSearchText   the text to count
    #   returns       a number
    #   note          NumberOfOccurrences is the same call
    #   see           ContainsText, LinesContaining
    def CountOccurrences(cSearchText)
        return StringNumberOfOccurrence(This.Content(), cSearchText)
    
		def NumberOfOccurrences(cSearchText)
			return This.CountOccurrences(cSearchText)

		def NumberOfOccurrence(cSearchText)
			return This.CountOccurrences(cSearchText)

    # Returns the lines that contain a text, each with its line number.
    #
    #   cSearchText   the text to look for
    #   returns       a list of [ number, text ] pairs
    #   note          the class stzFileModifier has a method of the same name that answers only the
    #                 texts
    #   see           LineNumber, ContainsText
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
    
    # Returns the number of the first line that contains a text; 0 when none does.
    #
    #   cSearchText   the text to look for
    #   returns       a number
    #   see           LinesContaining, FindText
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

# Opens an existing file for reading only and answers questions about its text and lines.
#
# Reach for it when you must not change the file: every writing class is built on the same reading
# methods (Lines, Line, FindText, LinesContaining...), which live in stzFileReadingMixin and are
# documented there. Building a reader on a path with no file raises an error and creates nothing.
#
#   receiver   write("demo_note.txt", "alpha" + char(10) + "beta gamma" + char(10) + "end") o1 = new
#              stzFileReader("demo_note.txt")
#   example    ? o1.NumberOfLines()
#              #--> 3
#              ? o1.FirstLine()
#              #--> alpha
#              ? o1.LineNumber("gamma")
#              #--> 2
#   see        stzFileReadingMixin, stzFileAppender, stzFileInfo
class stzFileReader from stzFileReadingMixin
    @cFileName
    
    # Opens a file for reading only; a path with no file raises an error.
    #
    #   cFileName   the path of an existing file
    #   returns     nothing; the object is built
    #   note        the error text is Cannot read non-existent file: followed by the path; nothing
    #               is created
    #   see         Content, Capabilities
    def init(cFileName)
        if not StzFileExists(cFileName)
            StzRaise("Cannot read non-existent file: " + cFileName)
        ok
        @cFileName = cFileName

    # Returns the whole text of the file.
    #
    #   returns    a text
    #   see        Lines, Size
    def Content()
        return read(@cFileName)

    # Does nothing; reading holds no resource.
    #
    #   returns    nothing
    #   see        Content
    def Close()
        return

	# Returns the hash list of conditions this intent expects of the file.
	#
	#   returns    a hash list, [ :FileExists = 1 ]
	#   see        Capabilities
	def Conditions()
		return [
			:FileExists = 1
		]

	# Returns what this intent allows: only :Read is 1.
	#
	#   returns    a hash list of :Read, :Append, :Create, :Overwrite, :Modify
	#   note       Skills is the same call
	#   see        Conditions
	def Capabilities()
		return [
			:Read = 1,
			:Append = 0,
			:Create = 0,
			:Overwrite = 0,
			:Modify = 0
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

# Opens a file to add text at its end, creating it when missing, and keeps everything already there.
#
# Reach for it for logs and any file that only grows: Write, WriteLine, WriteLines and WriteLogEntry
# add at the end, and the reading methods of stzFileReadingMixin are available too. The folder must
# exist. The text must be a text: a number given to Write ends the whole Ring process silently
# today. The class stzFile is another name for it.
#
#   receiver   write("demo_note.txt", "alpha" + char(10) + "beta gamma" + char(10) + "end") o1 = new
#              stzFileAppender("demo_note.txt")
#   example    o1.WriteLine("!")
#              ? o1.NumberOfLines()
#              #--> 4
#              ? o1.Line(3)
#              #--> end!
#   see        stzFileReader, stzFileCreator, stzFileOverwriter
class stzFileAppender from stzFileReadingMixin
    @cFileName

    # Opens a file for appending and creates it empty when it does not exist; existing content is kept.
    #
    #   cFileName   the path of the file to append to
    #   returns     nothing; the object is built
    #   note        the folder must already exist
    #   see         Write, Capabilities
    def init(cFileName)
        # Append-or-create: appending to a not-yet-existing file (e.g. a fresh
        # log) creates it empty rather than failing -- this is the universal,
        # logging-friendly semantics the design intends.
        if not StzFileExists(cFileName)
            StzEngineFileWrite(cFileName, "")
        ok
        @cFileName = cFileName

	# Returns the hash list of conditions this intent expects of the file.
	#
	#   returns    a hash list, [ :FileExists = 1 ]
	#   note       the file is created if missing, so the condition is met by init
	#   see        Capabilities
	def Conditions()
		return [
			:FileExists = 1
		]

	# Returns what this intent allows: :Read and :Append are 1, the rest 0.
	#
	#   returns    a hash list of :Read, :Append, :Create, :Overwrite, :Modify
	#   note       Skills is the same call
	#   see        Conditions
	def Capabilities()
		return [
			:Read = 1,
			:Append = 1,
			:Create = 0,
			:Overwrite = 0,
			:Modify = 0
		]

		def Skills()
			return This.Capabilities()

    # Adds a text at the end of the file, with no line break.
    #
    #   cText      the text to add
    #   returns    1
    #   note       pass a text; use "" + n for a number
    #   warning    warning: a number as argument ends the whole Ring process silently with exit code
    #              1, checked with 5 and 1.5; a list or the empty text does not
    #   see        WriteLine, WriteLines
    #@ aka  WRITE METHODS (intent-specific)
    def Write(cText)
        StzEngineFileAppend(@cFileName, cText)
		return 1

		# Adds a text at the end of the file and returns the appender, so calls can be chained.
		#
		#   cText      the text to add
		#   returns    the appender itself
		#   note       the name is misspelt in the source and there is no WriteQ on this class; it
		#              ends the process for a number as Write does
		#   see        Write, WriteLineQ
		def WrtiteQ(cText)
			This.Write(cText)
			return This
    
    # Adds a text and a line break at the end of the file.
    #
    #   cText      the text to add
    #   returns    1
    #   note       the same number problem as Write
    #   see        Write, WriteLines
    def WriteLine(cText)
        This.Write(cText + char(10))
    	return 1

		def WriteLineQ(cText)
			This.WriteLine(cText)
			return This

    # Adds each text of a list as its own line at the end of the file.
    #
    #   _aLines_   the list of texts, one per line
    #   returns    1
    #   note       an empty list adds nothing
    #   see        WriteLine, Write
    def WriteLines(_aLines_)
	   _nLen_ = len(_aLines_)
        for i = 1 to _nLen_
            This.WriteLine(_aLines_[i])
        next
        return 1

	   # Adds each text of a list as its own line and returns the appender, so calls can be chained.
	   #
	   #   _aLines_   the list of texts, one per line
	   #   returns    the appender itself
	   #   note       the name is misspelt in the source
	   #   see        WriteLines
	   def WrtiteLinesQ(_aLines_)
			This.WriteLines(_aLines_)
			return This
    
    # Adds the current date and time, then a colon and a space, with no line break.
    #
    #   returns    1
    #   note       the stamp has the form 09/10/2026 11:37:52 (day, month, year)
    #   see        WriteLogEntry
    def WriteTimestamp()
        _cTimeStamp_ = StzTimeStamp()
        This.Write(_cTimeStamp_ + ": ")
    	return 1

	   def WriteTimeStampQ()
		This.WriteStzTimeStamp()
		return This

    # Adds one line made of the current date and time, a dash and the message.
    #
    #   cMessage   the text of the entry
    #   returns    1
    #   note       the line reads 09/10/2026 11:37:52 - started
    #   see        WriteTimestamp, WriteLine
    def WriteLogEntry(cMessage)
        _cTimeStamp_ = StzTimeStamp()
        This.WriteLine(_cTimeStamp_ + " - " + cMessage)
    	return 1

	   def WriteLogEntryQ(cMessage)
		This.WriteLogEntryQ(cMessage)
		return This

    # Adds a line of 50 identical characters; the empty text means a dash.
    #
    #   _cChar_    the character to repeat, or "" for -
    #   returns    1
    #   note       only the first character counts; WriteSeperator is the misspelt twin and returns
    #              nothing
    #   see        WriteBlankLine, WriteLine
    def WriteSeparator(_cChar_)
        if _cChar_ = ""
            _cChar_ = "-"
        ok
        This.WriteLine(RepeatChar(_cChar_, 50))
    	return 1

	   def WriteSeparatorQ(_cChar_)
		This.WriteSeparator(_cChar_)
		return This

	   # Adds a line of 50 identical characters, as WriteSeparator does, but returns nothing.
	   #
	   #   _cChar_    the character to repeat, or "" for -
	   #   returns    nothing
	   #   note       the name is misspelt in the source
	   #   see        WriteSeparator
	   #@ aka  -- @Misspelled
	   def WriteSeperator(_cChar_)
		This.WriteSeparator(_cChar_)

		def WriteSeperatorQ(_cChar_)
			return This.WriteSeparatorQ(_cChar_)

    # Adds an empty line at the end of the file.
    #
    #   returns    1
    #   see        WriteLine, WriteSeparator
    def WriteBlankLine()
        This.WriteLine("")
    	return 1

	   def WriteBlankLineQ()
		This.WriteBlankLine()
		return This

    # Adds a text at the end of the file only if the file does not contain it yet.
    #
    #   cText      the text to add
    #   returns    nothing
    #   note       called twice with the same text it writes it once; no line break is added
    #   see        Write, ContainsText
    def AppendIfNotExistant(cText)
        # Only append if the text doesn't already exist in file
        if not This.ContainsText(cText)
            This.Write(cText)
        ok

	   def AppendIfNotExistantQ(cText)
		This.AppendIfNotExistant(ctext)
		return This
    
    # Does nothing; appending holds no resource.
    #
    #   returns    nothing
    #   see        Write
    def Close()
        return
		return 1

#=======================================#
# CREATOR CLASS - READ + CREATE INTENT  #
#=======================================#

# Purpose: Creates a new file with write methods and
# read access, ensuring it doesn't already exists

# Intent: "I want to create a new file"

# Creates a brand new file and writes into it; it refuses a path that already holds a file.
#
# Reach for it when overwriting an existing file would be a mistake: the constructor raises an error
# if the file exists. Write, WriteLine, WriteLines, WriteHeader and WriteTemplate add to the new
# file, and the reading methods of stzFileReadingMixin read it back. The folder must exist.
#
#   receiver   o1 = new stzFileCreator("demo_created.txt")
#   example    o1.WriteLine("first")
#              o1.WriteLine("second")
#              ? o1.NumberOfLines()
#              #--> 3
#              ? o1.Line(2)
#              #--> second
#   see        stzFileAppender, stzFileOverwriter, stzFileReader
class stzFileCreator from stzFileReadingMixin
    @cFileName

    # Creates a new empty file; a path that already has a file raises an error.
    #
    #   cFileName   the path of the file to create
    #   returns     nothing; the file is created
    #   note        the error text is Cannot create file - already exists: followed by the path; the
    #               folder must already exist
    #   see         Write, Capabilities
    def init(cFileName)
        if StzFileExists(cFileName)
            StzRaise("Cannot create file - already exists: " + cFileName)
        ok

        @cFileName = cFileName
        StzEngineFileWrite(cFileName, "")
    
	# Returns the hash list of conditions this intent expects of the file.
	#
	#   returns    a hash list, [ :FileExists = 0 ]
	#   note       the file must not exist
	#   see        Capabilities
	#@ aka  CONDTITIONS AND CAPABILITIES
	def Conditions()
		return [
			:FileExists = 0
		]

	# Returns what this intent allows: :Read and :Create are 1, the rest 0.
	#
	#   returns    a hash list of :Read, :Append, :Create, :Overwrite, :Modify
	#   note       Skills is the same call
	#   see        Conditions
	def Capabilities()
		return [
			:Read = 1,
			:Append = 0,
			:Create = 1,
			:Overwrite = 0,
			:Modify = 0
		]

		def Skills()
			return This.Capabilities()

    # Adds a text at the end of the new file, with no line break.
    #
    #   cText      the text to add
    #   returns    1
    #   see        WriteLine, WriteLines
    #@ aka  WRITE METHODS (intent-specific)
    def Write(cText)
        StzEngineFileAppend(@cFileName, cText)
		return 1

	   def WriteQ(cText)
		This.Write(cText)
		return This
    
    # Adds a text and a line break at the end of the file.
    #
    #   cText      the text to add
    #   returns    1
    #   see        Write, WriteLines
    def WriteLine(cText)
        This.Write(cText + char(10))
    	return 1

	   def WriteLineQ(cText)
		This.WriteLine(cText)
		return This

    # Adds each text of a list as its own line.
    #
    #   _aLines_   the list of texts, one per line
    #   returns    1
    #   see        WriteLine, Write
    def WriteLines(_aLines_)
	   	_nLen_ = len(_aLines_)
        for i = 1 to _nLen_
            This.WriteLine(_aLines_[i])
        next
		return 1

	  def WriteLinesQ(_aLines_)
		This.WriteLines(_aLines_)
		return This
    
    # Writes a title block: a line # title, a line # Created: with the date and time, an underline of equals signs, and a blank line.
    #
    #   cTitle     the title of the file
    #   returns    1
    #   note       the underline is two characters longer than the title
    #   see        WriteTemplate, WriteBlankLine
    def WriteHeader(cTitle)
        This.WriteLine("# " + cTitle)
        This.WriteLine("# Created: " + StzTimeStamp())
        This.WriteLine("#" + RepeatChar("=", StzLen(cTitle) + 2))
        This.WriteBlankLine()
    	return 1

	  def WriteHeaderQ(cTitle)
		This.WriteHeader(cTitle)
		return This

    # Adds an empty line at the end of the file.
    #
    #   returns    1
    #   see        WriteLine
    def WriteBlankLine()
        This.WriteLine("")
    	return 1

	   def WriteBlankLineQ()
		This.WriteBlankLine()
		return This

    # Writes a ready-made header: log, config or data; any other name writes a header naming the file.
    #
    #   cTemplateType   log, config or data
    #   returns         1 for log, config and data; nothing for another name
    #   note            for another name the header reads # File: followed by the path; the three
    #                   templates add a comment line and a blank line
    #   see             WriteHeader
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
    
    # Does nothing; creating holds no resource.
    #
    #   returns    nothing
    #   see        Write
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

# Replaces the whole text of a file: it keeps the old text in memory and empties the file when it is built.
#
# Reach for it to rewrite a file from nothing while still being able to read what was there
# (OriginalContent, OriginalLines). Building the object is itself the destructive step: the file is
# emptied at once, even if you never write. Write and its kin then add to the emptied file and raise
# an error for an empty text. PreserveAndModify raises an error today.
#
#   receiver   write("demo_note.txt", "alpha" + char(10) + "beta gamma" + char(10) + "end") o1 = new
#              stzFileOverwriter("demo_note.txt")
#   example    ? o1.OriginalLineCount()
#              #--> 3
#              o1.Write("new text")
#              ? o1.Content()
#              #--> new text
#   see        stzFileModifier, stzFileEaraser, stzFileAppender
class stzFileOverwriter from stzFileReadingMixin

    @cFileName
    @cOriginalContent

    # Takes a file for overwriting: keeps its old text in memory, then empties the file at once; a missing file is created.
    #
    #   cFileName   the path of the file to overwrite
    #   returns     nothing; the file is emptied
    #   note        the emptying happens in the constructor, before any write, so building the
    #               object is itself destructive
    #   see         OriginalContent, Write
    def init(cFileName)
        @cFileName = cFileName

        if StzFileExists(cFileName)
            @cOriginalContent = read(cFileName)
        else
            @cOriginalContent = ""
        ok

        StzEngineFileWrite(cFileName, "")

	# Returns the hash list of conditions this intent expects of the file.
	#
	#   returns    a hash list, [ :FileExists = 1 ]
	#   see        Capabilities
	#@ aka  CONDTITIONS AND CAPABILITIES
	def Conditions()
		return [
			:FileExists = 1
		]

	# Returns what this intent allows: :Read and :Overwrite are 1, the rest 0.
	#
	#   returns    a hash list of :Read, :Append, :Create, :Overwrite, :Modify
	#   note       Skills is the same call
	#   see        Conditions
	def Capabilities()
		return [
			:Read = 1,
			:Append = 0,
			:Create = 0,
			:Overwrite = 1,
			:Modify = 0
		]

		def Skills()
			return This.Capabilities()

    # Returns the text the file held before it was emptied.
    #
    #   returns    a text
    #   note       the empty text for a file that did not exist
    #   see        OriginalLines, OriginalSize
    #@ aka  READING METHODS (access to original content)
    def OriginalContent()
        return @cOriginalContent

    # Returns the lines the file held before it was emptied.
    #
    #   returns    a list of texts
    #   see        OriginalContent, OriginalLineCount
    def OriginalLines()
        return @Lines(@cOriginalContent)

    # Returns the length of the old text in bytes.
    #
    #   returns    a number
    #   note       OriginalSizeInBytes is the same call; a line break counts as one byte
    #   see        OriginalContent
    def OriginalSize()
        return len(@cOriginalContent)

		def OriginalSizeInBytes()
			return This.OriginalSize()

    # Returns how many lines the old text had.
    #
    #   returns    a number
    #   note       OriginalNumberOfLines is the same call
    #   see        OriginalLines
    def OriginalLineCount()
        return len(This.OriginalLines())

		def OriginalNumberOfLines()
			return This.OriginalLineCount()

    # Adds a text to the emptied file, with no line break; an empty text or a non-text raises an error.
    #
    #   cText      the non-empty text to write
    #   returns    1
    #   note       the error text is Can't write to the file! You must provide a non empty string.;
    #              successive writes accumulate, they do not replace each other
    #   see        WriteLine, WriteLines
    #@ aka  WRITE METHODS (intent-specific)
    def Write(cText)
		if NOT (isString(cText) and cText != "")
			StzRaise("Can't write to the file! You must provide a non empty string.")
		ok

        StzEngineFileAppend(@cFileName, cText)
		return 1

		def WriteQ(cText)
			This.Write(cText)
			return This
    
    # Adds a text and a line break to the file.
    #
    #   cText      the non-empty text to write
    #   returns    1
    #   note       an empty text writes just a line break
    #   see        Write, WriteLines
    def WriteLine(cText)
        This.Write(cText + char(10))
    	return 1

		def WriteLineQ(cText)
			This.WriteLine(cText)
			return This

    # Adds each text of a list as its own line.
    #
    #   _aLines_   the list of texts, one per line
    #   returns    1
    #   see        WriteLine
    def WriteLines(_aLines_)
		_nLen_ = len(_aLines_)
        for i = 1 to _nLen_
            This.WriteLine(_aLines_[i])
        next
		return 1

		def WriteLinesQ(_aLines_)
			This.WriteLines(_aLines_)
			return This
    
    # Writes a title block: a line # title, a line # Updated: with the date and time, an underline, and a blank line.
    #
    #   cTitle     the title
    #   returns    1
    #   note       the underline is two characters longer than the title
    #   see        WriteBlankLine
    def WriteHeader(cTitle)
        This.WriteLine("# " + cTitle)
        This.WriteLine("# Updated: " + StzTimeStamp())
        This.WriteLine("#" + RepeatChar("=", len(cTitle) + 2))
        This.WriteBlankLine()
    	return 1

		def WriteHeaderQ(cTitle)
			This.WriteHeader(cTitle)
			return This

    # Adds an empty line to the file.
    #
    #   returns    1
    #   see        WriteLine
    def WriteBlankLine()
        This.WriteLine("")
    	return 1

		def WriteBlankLineQ()
			This.WriteBlankLine()
			return This

    # Raises error R12 today instead of writing the old text back and adding a change after it.
    #
    #   cModification   the text to add after the old text
    #   returns         nothing; it raises an error
    #   note            write OriginalContent() then the change yourself
    #   warning         defect: the body reads This.cOriginalContent where the attribute is
    #                   @cOriginalContent, so every call raises Error in property name, property not
    #                   found: coriginalcontent (checked on two files)
    #   see             OriginalContent, Write
    def PreserveAndModify(cModification)
        # Write original content back, then add modification
        This.Write(This.cOriginalContent)
        This.Write(cModification)
		return 1

		def PreserveAndModifyQ(cModification)
			This.PreserveAndModify(cModification)
			return This
    
    # Does nothing; overwriting holds no resource.
    #
    #   returns    nothing
    #   see        Write
    def Close()
        return

# SPECIAL CASE OF THE OVERWRITE INTENT

# Empties a file, keeping its old text in memory; the file stays on the disk with no content.
#
# Reach for it to blank a file on purpose. Building the object empties the file at once; Erase
# empties it again. The old text stays readable through OriginalContent. The class name is spelt
# Earaser in the source. It does not delete the file: use stzFileManager.Delete for that.
#
#   receiver   write("demo_note.txt", "alpha" + char(10) + "beta gamma" + char(10) + "end") o1 = new
#              stzFileEaraser("demo_note.txt")
#   example    ? o1.OriginalLineCount()
#              #--> 3
#              ? o1.OriginalSize()
#              #--> 20
#   see        stzFileOverwriter, stzFileManager
class stzFileEaraser from stzObject
    @cFileName
    @cOriginalContent

    # Takes a file for erasing: keeps its old text in memory, then empties the file at once; a missing file is created.
    #
    #   cFileName   the path of the file to erase
    #   returns     nothing; the file is emptied
    #   note        the emptying happens in the constructor, so building the object is itself
    #               destructive; the class name is spelt Earaser in the source
    #   see         OriginalContent, Erase
    def init(cFileName)
        @cFileName = cFileName

        if StzFileExists(cFileName)
            @cOriginalContent = read(cFileName)
        else
            @cOriginalContent = ""
        ok

        StzEngineFileWrite(cFileName, "")

	# Returns the hash list of conditions this intent expects of the file.
	#
	#   returns    a hash list, [ :FileExists = 1 ]
	#   see        Capabilities
	#@ aka  CONDTITIONS AND CAPABILITIES
	def Conditions()
		return [
			:FileExists = 1
		]

	# Returns what this intent allows: :Read, :Append and :Overwrite are 1, the rest 0.
	#
	#   returns    a hash list of :Read, :Append, :Create, :Overwrite, :Modify
	#   note       Skills is the same call
	#   see        Conditions
	def Capabilities()
		return [
			:Read = 1,
			:Append = 1,
			:Create = 0,
			:Overwrite = 1,
			:Modify = 0
		]

		def Skills()
			return This.Capabilities()

    # Returns the text the file held before it was emptied.
    #
    #   returns    a text
    #   see        OriginalLines, OriginalSize
    #@ aka  READING METHODS (access to original content)
    def OriginalContent()
        return @cOriginalContent

    # Returns the lines the file held before it was emptied.
    #
    #   returns    a list of texts
    #   see        OriginalContent, OriginalLineCount
    def OriginalLines()
        return @Lines(@cOriginalContent)

    # Returns the length of the old text in bytes.
    #
    #   returns    a number
    #   note       OriginalSizeInBytes is the same call
    #   see        OriginalContent
    def OriginalSize()
        return len(@cOriginalContent)

		def OriginalSizeInBytes()
			return This.OriginalSize()

    # Returns how many lines the old text had.
    #
    #   returns    a number
    #   note       OriginalNumberOfLines is the same call
    #   see        OriginalLines
    def OriginalLineCount()
        return len(This.OriginalLines())

		def OriginalNumberOfLines()
			return This.OriginalLineCount()

    # Empties the file again.
    #
    #   returns    1
    #   note       the file keeps existing with zero bytes; it is not deleted
    #   see        OriginalContent
    #@ aka  WRITE METHODS (intent-specific)
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

# Changes parts of an existing file line by line, or by text, and rewrites the file after each change.
#
# Reach for it to edit a file in place: ModifyLine, InsertLineAt, RemoveLine, Modify (every
# occurrence of a text) and ReplaceLineContaining each rewrite the file at once. The object keeps
# its own copy of the text and lines, kept in step with its changes (OriginalContent shows the
# latest text, not the text at open time), so use one modifier per edit session. Lines are joined
# with a line feed and no final one is added. InsertLine and the :With form of Modify raise errors
# today.
#
#   receiver   write("demo_note.txt", "alpha" + char(10) + "beta gamma" + char(10) + "end") o1 = new
#              stzFileModifier("demo_note.txt")
#   example    o1.ModifyLine(2, "BETA")
#              ? o1.OriginalContent() = "alpha" + char(10) + "BETA" + char(10) + "end"
#              #--> 1
#              o1.InsertLineAtEnd("fin")
#              ? o1.OriginalLineCount()
#              #--> 4
#              ? o1.RemoveLine(9)
#              #--> 0
#   see        stzFileOverwriter, stzFileReader, stzString
class stzFileModifier from stzFileReadingMixin

    @cFileName
    @cOriginalContent
    @aOriginalLines

    # Opens an existing file for changing parts of it and keeps its text and lines in memory; a missing file raises an error.
    #
    #   cFileName   the path of an existing file
    #   returns     nothing; the object is built
    #   note        the error text is Cannot update non-existent file: followed by the path; the
    #               file is not changed until a Modify... or Insert... call
    #   see         OriginalContent, Capabilities
    def init(cFileName)
        if not StzFileExists(cFileName)
            StzRaise("Cannot update non-existent file: " + cFileName)
        ok

        @cFileName = cFileName
        @cOriginalContent = read(cFileName)

        if @cOriginalContent = "" or len(@cOriginalContent) = 0
            @cOriginalContent = ""
            @aOriginalLines = []
        else
            @aOriginalLines = @Lines(@cOriginalContent)
        ok

	# Returns the hash list of conditions this intent expects of the file.
	#
	#   returns    a hash list, [ :FileExists = 1 ]
	#   see        Capabilities
	#@ aka  CONDTITIONS AND CAPABILITIES
	def Conditions()
		return [
			:FileExists = 1
		]

	# Returns what this intent allows: :Read and :Modify are 1, the rest 0.
	#
	#   returns    a hash list of :Read, :Append, :Create, :Overwrite, :Modify
	#   note       Skills is the same call
	#   see        Conditions
	def Capabilities()
		return [
			:Read = 1,
			:Append = 0,
			:Create = 0,
			:Overwrite = 0,
			:Modify = 1
		]

		def Skills()
			return This.Capabilities()

    # Returns the text the object holds for the file, kept in step with every change made through it.
    #
    #   returns    a text
    #   note       despite its name it shows the latest text written by this object, not the text at
    #              open time
    #   see        OriginalLines, Content
    #@ aka  ACCESS TO ORIGINAL STATE
    def OriginalContent()
        return @cOriginalContent
    
    # Returns the lines the object holds for the file, kept in step with every change made through it.
    #
    #   returns    a list of texts
    #   note       it follows the changes of this object, not the text at open time
    #   see        OriginalContent, OriginalLineCount
    def OriginalLines()
        return @aOriginalLines
    
    # Returns the length of the held text in bytes.
    #
    #   returns    a number
    #   note       OriginalSizeInBytes is the same call
    #   see        OriginalContent
    def OriginalSize()
        return len(@cOriginalContent)
    
    def OriginalSizeInBytes()
        return This.OriginalSize()

    # Returns how many lines the held text has.
    #
    #   returns    a number
    #   note       NumberOfOriginalLines is the same call
    #   see        OriginalLines
    def OriginalLineCount()
        return len(@aOriginalLines)
    
    def NumberOfOriginalLines()
        return This.OriginalLineCount()

    # Writes a new text over the whole file.
    #
    #   _cNewContent_   the new text of the file
    #   returns         1
    #   note            ReplaceAllContent is the same call
    #   see             ModifyLine, Modify
    #@ aka  SOPHISTICATED UPDATE METHODS
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

    # Writes a new text over the whole file.
    #
    #   _cNewContent_   the new text of the file
    #   returns         nothing
    #   note            it does what ModifyAllContent does but returns nothing
    #   see             ModifyAllContent
    def ModifyAllContentWith(_cNewContent_)
        This.ModifyAllContent(_cNewContent_)

	    def ModifyAllContentWithQ(_cNewContent_)
	        return This.ModifyAllContentQ(_cNewContent_)

    # Replaces the line at a number with a new text and rewrites the file.
    #
    #   nLineNumber   the line to replace, counted from 1
    #   cNewLine      the new text of that line
    #   returns       1
    #   note          a number past the last line raises the error Array Access (Index out of
    #                 range); lines are joined with a line feed and no final one is added
    #   see           InsertLineAt, ReplaceInLine
    def ModifyLine(nLineNumber, cNewLine)
        _aLines_ = This.OriginalLines()
        _aLines_[nLineNumber] = cNewLine
        _cNewContent_ = JoinXT(_aLines_, char(10))
        This.ModifyAllContent(_cNewContent_)
    	return 1

	    def ModifyLineQ(nLineNumber, cNewLine)
	        This.ModifyLine(nLineNumber, cNewLine)
	        return This

	# Inserts a new line so that it takes the given position, and rewrites the file.
	#
	#   _nPos_     the position of the new line, counted from 1
	#   cNewLine   the text of the line
	#   returns    1
	#   note       a position below 1 means 1 and a position past the end adds at the end; an empty
	#              file raises the error Cannot insert line in empty file - use ReplaceAllContent()
	#              instead
	#   see        InsertLineAtStart, InsertLineAtEnd, InsertAfterLine
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
	    
	    _cNewContent_ = JoinXT(_aLines_, char(10))  # Add newline separator
	    This.ModifyAllContent(_cNewContent_)
		return 1

	    def InsertLineAtQ(_nPos_, cNewLine)
	        This.InsertLineAt(_nPos_, cNewLine)
	        return This

		# Raises error R24 today instead of inserting a line at a position.
		#
		#   _nPos_     the position of the new line
		#   cNewLine   the text of the line
		#   returns    nothing; it raises an error
		#   note       use InsertLineAt, which does the same
		#   warning    defect: the body passes nNewLine, a name that does not exist (the parameter
		#              is cNewLine), so every call raises Using uninitialized variable: nnewline
		#   see        InsertLineAt
		def InsertLine(_nPos_, cNewLine)
			This.InsertLineAt(_nPos_, nNewLine)

			def InertLineQ(_nPos_, cNewLine)
				return This.InsertLineAtQ(_nPos_, cNewLine)


    # Inserts a new line before the first line.
    #
    #   cNewLine   the text of the line
    #   returns    1
    #   note       an empty file raises the error of InsertLineAt
    #   see        InsertLineAt, InsertLineAtEnd
    def InsertLineAtStart(cNewLine)
        This.InsertLineAt(1, cNewLine)
    	return 1

	    def InsertLineAtStartQ(cNewLine)
	        This.InsertLineAtStart(cNewLine)
	        return This
	 
	# Adds a new line after the last line.
	#
	#   cNewLine   the text of the line
	#   returns    1
	#   note       an empty file raises the error Cannot insert line in empty file - use
	#              ReplaceAllContent() instead
	#   see        InsertLineAt, InsertLineAtStart
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
		# Adds a new line after the last line.
		#
		#   cNewLine   the text of the line
		#   returns    1
		#   note       it does what InsertLineAtEnd does
		#   see        InsertLineAtEnd
		#>
		#< @FunctionAlternativeForms
		def AppendWithLine(cNewLine)
			This.InsertLineAtEnd(cNewLine)
			return 1

			def AppendWithLineQ(cNewLine)
				return This.InsertLineAtEndQ(cNewLine)
    # Inserts a new line right after the given line.
    #
    #   nLineNumber   the line to insert after, counted from 1
    #   cNewLine      the text of the line
    #   returns       1
    #   see           InsertBeforeLine, InsertLineAt
		#>
    def InsertAfterLine(nLineNumber, cNewLine)
        This.InsertLineAt(nLineNumber + 1, cNewLine)
    	return 1

	    def InsertAfterLineQ(nLineNumber, cNewLine)
	        This.InsertAfterLine(nLineNumber, cNewLine)
	        return This

    # Inserts a new line right before the given line.
    #
    #   nLineNumber   the line to insert before, counted from 1
    #   cNewLine      the text of the line
    #   returns       1
    #   see           InsertAfterLine, InsertLineAt
    def InsertBeforeLine(nLineNumber, cNewLine)
        This.InsertLineAt(nLineNumber, cNewLine)
    	return 1

	    def InsertBeforeLineQ(nLineNumber, cNewLine)
	        This.InsertBeforeLine(nLineNumber, cNewLine)
	        return This

    # Removes the line at a number and rewrites the file.
    #
    #   nLineNumber   the line to remove, counted from 1
    #   returns       1 if removed, 0 if the number is outside the file
    #   see           RemoveFirstLine, RemoveLastLine, RemoveLinesContaining
    def RemoveLine(nLineNumber)
        _aLines_ = @aOriginalLines
        if nLineNumber >= 1 and nLineNumber <= len(_aLines_)
            del(_aLines_, nLineNumber)
            _cNewContent_ = JoinXT(_aLines_, char(10))
            This.ModifyAllContent(_cNewContent_)
			return 1
        ok
    	return 0

	    def RemoveLineQ(nLineNumber)
	        This.RemoveLine(nLineNumber)
	        return This

		# Removes the line at a number and rewrites the file.
		#
		#   nLineNumber   the line to remove, counted from 1
		#   returns       nothing
		#   note          it does what RemoveLine does but returns nothing
		#   see           RemoveLine
		def DeleteLine(nLineNumber)
			This.RemoveLine(nLineNumber)

			def DeleteLineQ(nLineNumber)
				return This.RemoveLineQ(nLineNumber)

    # Removes the first line of the file.
    #
    #   returns    1
    #   see        RemoveLastLine, RemoveLine
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

    # Removes the last line of the file.
    #
    #   returns    1
    #   see        RemoveFirstLine, RemoveLine
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

	# Returns the numbers of the lines that contain a text.
	#
	#   cSearchText   the text to look for
	#   returns       a list of numbers
	#   note          the lines are those held now, so it follows earlier changes of this object
	#   see           LinesContaining, RemoveLinesContaining
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

	# Returns the lines that contain a text, as texts.
	#
	#   cSearchText   the text to look for
	#   returns       a list of texts
	#   note          the reading classes have a method of the same name that answers [ number, text
	#                 ] pairs instead
	#   see           FindLinesContaining
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


    # Removes every line that contains a text and rewrites the file.
    #
    #   cSearchText   the text to look for
    #   returns       1
    #   note          when no line matches the file is rewritten unchanged
    #   see           RemoveLine, FindLinesContaining
    def RemoveLinesContaining(cSearchText)
        _aLines_ = @aOriginalLines
        _nLen_ = len(_aLines_)

        _aNewLines_ = []
        for i = 1 to _nLen_
            if StzFindFirst(cSearchText, _aLines_[i]) = 0
                _aNewLines_ + _aLines_[i]
            ok
        next

        _cNewContent_ = JoinXT(_aNewLines_, char(10))
        This.ModifyAllContent(_cNewContent_)
    	return 1

	    def RemoveLinesContainingQ(cSearchText)
	        This.RemoveLinesContaining(cSearchText)
	        return This

		def DeleteLinesContaining(cSearchText)
			return This.RemoveLinesContaining(cSearchText)

		def DeleteLinesContainingQ(cSearchText)
			return This.RemoveLinesContainingQ(cSearchText)

    # Swaps every occurrence of a text for another in the whole file and rewrites it.
    #
    #   cOldText   the text to look for
    #   cNewText   the text put in its place
    #   returns    1
    #   note       pass the new text directly
    #   warning    warning: the form Modify(old, :With = new) raises Incorrect param type! cNewText
    #              must be a string., because the unwrapped value is stored in a misspelt variable
    #              (_cNexText_) and the original list is tested
    #   see        ReplaceInLine, ModifyLine
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

		# Swaps every occurrence of a text for another in the whole file and rewrites it.
		#
		#   cOldText   the text to look for
		#   cNewText   the text put in its place
		#   returns    1
		#   note       it does what Modify does
		#   see        Modify
		def ModifyText(cOldText, cNewText)
			This.Modify(cOldText, cNewText)
			return 1


    # Swaps every occurrence of a text for another inside one line only, and rewrites the file.
    #
    #   nLineNumber   the line to change, counted from 1
    #   cOldText      the text to look for
    #   cNewText      the text put in its place
    #   returns       nothing
    #   note          a number past the last line raises the error Array Access (Index out of range)
    #   see           Modify, ModifyLine
    def ReplaceInLine(nLineNumber, cOldText, cNewText)
        _aLines_ = This.OriginalLines()
        _aLines_[nLineNumber] = StzReplace(_aLines_[nLineNumber], cOldText, cNewText)
        _cNewContent_ = JoinXT(_aLines_, char(10))
        This.ReplaceAllContent(_cNewContent_)

	    def ReplaceInLineQ(nLineNumber, cOldText, cNewText)
	        This.ReplaceInLine(nLineNumber, cOldText, cNewText)
	        return This

	# Replaces the first line that contains a text by a new line and rewrites the file.
	#
	#   cSubstr    the text that picks the line
	#   cNewLine   the new text of that line
	#   returns    nothing
	#   note       when no line matches the file is rewritten unchanged
	#   see        ReplaceInLine, ModifyLine
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

	    _cNewContent_ = JoinXT(_aLines_, char(10))  # Add newline separator
	    This.ReplaceAllContent(_cNewContent_)
    
	    def ReplaceLineContainingQ(cSubStr, cNewLine)
	        This.ReplaceLineContaining(cSubStr, cNewLine)
	        return This

    # Does nothing; modifying holds no resource.
    #
    #   returns    nothing
    #   see        Modify
    def Close()
        return
    

#=========================================#
# MANAGER CLASS - DISK OPERATIONS INTENT  #
#=========================================#
# NOTE: the FileManage()/FileManageQ()/StzFileManage() functions live in the
# functions region above (before the first class) -- a Ring func placed
# BETWEEN two classes is attached to the preceding class instead of being
# registered as a global, which left FileManage() dead (R3).

# Does disk operations on one existing file: copy, move, split, zip, delete and change its permission flags.
#
# Reach for it to act on the file as an object on the disk rather than on its text. Working today:
# CopyToAs, MoveToAs, the Zip... methods, Delete, Remove, MakeReadOnly, MakeWritable and the small
# readers (Size, Exists, IsWritable). Broken today: CopyTo, CopyAs, MoveTo, MoveAs, RenameAs,
# CreateBackup, CreateBackupAs, SafeDelete, SafeRemove, ZipBackup and IsExecutable raise error R3
# (helpers placed between classes are not global functions), the three Split methods raise error
# R13, and Backup returns 1 but writes nothing. The destination folder of a copy or move must
# already exist.
#
#   receiver   write("demo_note.txt", "alpha" + char(10) + "beta gamma" + char(10) + "end") o1 = new
#              stzFileManager("demo_note.txt")
#   example    ? o1.Size()
#              #--> 20
#              ? o1.Exists()
#              #--> 1
#              o1.MakeReadOnly()
#              ? o1.IsWritable()
#              #--> 0
#              o1.MakeWritable()
#              ? o1.IsClosed()
#              #--> 0
#   see        stzFileInfo, stzFolder, stzFileModifier
class stzFileManager from stzObject
    @cFileName
    @bClosed = 0

    # Opens an existing file for disk operations: copy, move, rename, split, zip, back up, delete; a missing file raises an error.
    #
    #   cFileName   the path of an existing file
    #   returns     nothing; the object is built
    #   note        the error text is Cannot manage non-existent file: followed by the path
    #   see         Capabilities, Delete
    def init(cFileName)
        if not StzFileExists(cFileName)
            StzRaise("Cannot manage non-existent file: " + cFileName)
        ok

        @cFileName = cFileName
    
	# Returns the hash list of conditions this intent expects of the file.
	#
	#   returns    a hash list, [ :FileExists = 1 ]
	#   see        Capabilities
	#@ aka  CONDTITIONS AND CAPABILITIES
	def Conditions()
		return [
			:FileExists = 1
		]

	# Returns what this intent allows: a hash list with every operation of the class set to 1.
	#
	#   returns    a hash list of :Copy, :Move, :Rename, :Delete, :Backup, :Split, :Zip,
	#              :MakeReadOnly, :MakeWritable, :MakeExecutable, :EncryptDecrypt
	#   note       the list is a statement of intent: it does not test the disk, and several of the
	#              listed operations raise today
	#   see        Conditions
	def Capabilities()
		return [
			:Copy = 1,
			:Move = 1,
			:Rename = 1,
			:Delete = 1,
			:Backup = 1,
			:Split = 1,
			:Zip = 1,
			:MakeReadOnly = 1,
			:MakeWritable = 1,
			:MakeExecutable = 1,
			:EncryptDecrypt = 1
		]

		def Skills()
			return This.Capabilities()

    # Raises error R3 today instead of copying the file into a folder under its own name.
    #
    #   _cDestinationPath_   the folder to copy into
    #   returns              nothing; it raises an error
    #   note                 use CopyToAs, which does not call a helper
    #   warning              defect: the body calls the helper _FileName, which is not a global
    #                        function (a function placed between two classes belongs to the class
    #                        before it), so every call raises Calling Function without definition:
    #                        _filename; same cause as MoveTo, MoveAs, RenameAs, CopyAs,
    #                        CreateBackup, CreateBackupAs, SafeDelete, SafeRemove, ZipBackup and
    #                        IsExecutable
    #   see                  CopyToAs, CopyAs
    #@ aka  COPY OPERATIONS
    def CopyTo(_cDestinationPath_)
        if not StzRight(_cDestinationPath_, 1) = "/"
            _cDestinationPath_ = _cDestinationPath_ + "/"
        ok

        _cDestFile_ = _cDestinationPath_ + _FileName(@cFileName)
        return StzEngineFileCopy(@cFileName, _cDestFile_)

        def CopyToQ(_cDestinationPath_)
            This.CopyTo(_cDestinationPath_)
            return This

    # Raises error R3 today instead of copying the file under a new name in the same folder.
    #
    #   _cNewFileName_   the name of the copy
    #   returns          nothing; it raises an error
    #   note             use CopyToAs with the folder of the file
    #   warning          defect: the body calls the helper _FileDirPath, which is not a global
    #                    function, so every call raises Calling Function without definition:
    #                    _filedirpath
    #   see              CopyToAs
    def CopyAs(_cNewFileName_)
        _cDestFile_ = _FileDirPath(@cFileName) + "/" + _cNewFileName_
        return StzEngineFileCopy(@cFileName, _cDestFile_)

        def CopyAsQ(_cNewFileName_)
            This.CopyAs(_cNewFileName_)
            return This

    # Copies the file into a folder under a new name; the original stays.
    #
    #   _cDestinationPath_   the folder to copy into, which must already exist
    #   _cNewFileName_       the name of the copy
    #   returns              1 if copied, 0 if not
    #   note                 a folder that does not exist gives 0 and nothing is created
    #   see                  CopyTo, MoveToAs
    def CopyToAs(_cDestinationPath_, _cNewFileName_)
        if not StzRight(_cDestinationPath_, 1) = "/"
            _cDestinationPath_ = _cDestinationPath_ + "/"
        ok

        _cDestFile_ = _cDestinationPath_ + _cNewFileName_
        return StzEngineFileCopy(@cFileName, _cDestFile_)
    
        def CopyToAsQ(_cDestinationPath_, _cNewFileName_)
            This.CopyToAs(_cDestinationPath_, _cNewFileName_)
            return This
    
    # Raises error R3 today instead of moving the file into a folder under its own name.
    #
    #   _cDestinationPath_   the folder to move into
    #   returns              nothing; it raises an error
    #   note                 use MoveToAs
    #   warning              defect: calls the missing helper _FileName (see CopyTo)
    #   see                  MoveToAs, CopyTo
    #@ aka  MOVE OPERATIONS
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

    # Raises error R3 today instead of renaming the file inside its own folder.
    #
    #   _cNewFileName_   the new name
    #   returns          nothing; it raises an error
    #   note             use MoveToAs
    #   warning          defect: calls the missing helper _FileDirPath (see CopyTo)
    #   see              MoveToAs, RenameAs
    def MoveAs(_cNewFileName_)
        _cDestFile_ = _FileDirPath(@cFileName) + "/" + _cNewFileName_
        _bResult_ = StzEngineFileCopy(@cFileName, _cDestFile_)
        if _bResult_ StzEngineFileDelete(@cFileName) @cFileName = _cDestFile_ ok
        return _bResult_

        def MoveAsQ(_cNewFileName_)
            This.MoveAs(_cNewFileName_)
            return This

    # Moves the file into a folder under a new name: it copies, deletes the original and follows the new path.
    #
    #   _cDestinationPath_   the folder to move into, which must already exist
    #   _cNewFileName_       the new name
    #   returns              1 if moved, 0 if not
    #   note                 afterwards FileName answers the new path; when the copy fails the
    #                        original is kept
    #   see                  MoveTo, RenameAs
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
    
    # Raises error R3 today instead of renaming the file inside its own folder.
    #
    #   _cNewFileName_   the new name
    #   returns          nothing; it raises an error
    #   note             use MoveToAs
    #   warning          defect: calls the missing helper _FileDirPath (see CopyTo)
    #   see              MoveToAs
    #@ aka  RENAME OPERATIONS
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
    
	# Returns 1 but writes no backup today, because the name it builds contains the characters / and :.
	#
	#   returns    1
	#   note       copy with CopyToAs and a name you choose
	#   warning    defect: the copy is named file.backup. followed by StzTimeStamp(), which has the
	#              form 09/10/2026 11:37:52, so the target path holds folders that do not exist and
	#              the copy fails without notice; checked twice, no file appears and the 1 is
	#              returned anyway
	#   see        CreateBackup, CopyToAs
	#@ aka  BACKUP OPERATION
	def Backup()
        _cBackup_ = @cFileName + ".backup." + StzTimeStamp()
        StzFileCopy(@cFileName, _cBackup_) #TODO // use internal methods to the object
		return 1

    # Raises error R13 today instead of splitting the file into parts of a fixed number of lines.
    #
    #   nLinesPerFile   how many lines go to each part
    #   returns         nothing; it raises an error
    #   note            split the lines yourself with stzFileReader and stzFileCreator
    #   warning         defect: the body treats the text returned by StzFileRead as a reader object
    #                   and calls Lines() on it, so every call raises Object is required; the helper
    #                   names it uses (_FileCompleteBaseName and others) are missing too
    #   see             SplitBySize, SplitByPattern
    #@ aka  SPLIT OPERATIONS
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
    
    # Raises error R13 today instead of splitting the file into parts of a fixed number of bytes.
    #
    #   nBytesPerFile   how many bytes go to each part
    #   returns         nothing; it raises an error
    #   note            split the text yourself
    #   warning         defect: same cause as SplitByLines, calling a method on the text returned by
    #                   StzFileRead
    #   see             SplitByLines
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
    
    # Raises error R13 today instead of splitting the file at every line that contains a pattern.
    #
    #   cPattern   the text that opens a new part
    #   returns    nothing; it raises an error
    #   note       split the lines yourself
    #   warning    defect: same cause as SplitByLines
    #   see        SplitByLines
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
    
    # Puts the file in a new zip archive and gives the path of the archive.
    #
    #   _cZipFileName_   the path of the zip to create
    #   returns          a text, the path of the zip
    #   note             the archive was created in the scratch folder; its contents were not opened
    #   see              ZipWith, AddToZip
    #@ aka  ZIP OPERATIONS (Delegated to stzZipFile)
    def ZipAs(_cZipFileName_)
        # Create zip containing this file
        _oZip_ = new stzZipFile(_cZipFileName_)
        return _oZip_.CreateFromSingleFile(@cFileName)
    
        def ZipAsQ(_cZipFileName_)
            This.ZipAs(_cZipFileName_)
            return This
    
    # Puts the file and other files in a new zip archive.
    #
    #   _aFiles_         the list of paths of the other files
    #   _cZipFileName_   the path of the zip to create
    #   returns          a text, the path of the zip
    #   note             the archive was created; its contents were not opened
    #   see              ZipAs, AddToZip
    def ZipWith(_aFiles_, _cZipFileName_)
        # Create zip with this file + additional files
        _oZip_ = new stzZipFile(_cZipFileName_)
        _aAllFiles_ = [@cFileName] + _aFiles_
        return _oZip_.CreateFrom(_aAllFiles_)
    
        def ZipWithQ(_aFiles_, _cZipFileName_)
            This.ZipWith(_aFiles_, _cZipFileName_)
            return This
    
    # Puts the file in a new zip archive of a given name inside a given folder.
    #
    #   _cZipFileName_   the name of the zip
    #   _cTargetDir_     the folder to create it in, which must exist
    #   returns          a text, the path of the zip
    #   note             the archive was created; its contents were not opened
    #   see              ZipAs
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
    
    # Adds the file to a zip archive, naming the archive.
    #
    #   _cZipFileName_   the path of the zip
    #   returns          a text, the path of the zip
    #   note             run on an archive made by ZipAs; the result was the path of the zip
    #   see              ZipAs, ZipWith
    def AddToZip(_cZipFileName_)
        # Add this file to existing zip
        _oZip_ = new stzZipFile(_cZipFileName_)
        return _oZip_.AddFile(@cFileName)
    
        def AddToZipQ(_cZipFileName_)
            This.AddToZip(_cZipFileName_)
            return This
    
    # Puts the file and a list of other files, such as its split parts, in a new zip archive.
    #
    #   _aFiles_         the list of paths of the other files
    #   _cZipFileName_   the path of the zip to create
    #   returns          a text, the path of the zip
    #   note             it does the same as ZipWith; the archive was created, contents not opened
    #   see              ZipWith
    def ZipSplitFiles(_aFiles_, _cZipFileName_)
        # Create zip containing this file and its split files
        _oZip_ = new stzZipFile(_cZipFileName_)
        _aAllFiles_ = [@cFileName] + _aFiles_
        return _oZip_.CreateFrom(_aAllFiles_)
    
        def ZipSplitFilesQ(_aFiles_, _cZipFileName_)
            This.ZipSplitFiles(_aFiles_, _cZipFileName_)
            return This
    
    # Raises error R3 today instead of zipping the file into a backup archive in its own folder.
    #
    #   _cZipFileName_   the name of the archive, or the empty text for a timestamped name
    #   returns          nothing; it raises an error
    #   note             use ZipAs
    #   warning          defect: calls the missing helpers _FileDirPath, or _FileCompleteBaseName
    #                    for the empty text (see CopyTo)
    #   see              ZipAs
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
    
    # Raises error R3 today instead of copying the file to a timestamped backup name and giving its path.
    #
    #   returns    nothing; it raises an error
    #   note       use CopyToAs
    #   warning    defect: calls the missing helper _FileCompleteBaseName (see CopyTo)
    #   see        CreateBackupAs, Backup
    #@ aka  BACKUP OPERATIONS
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

    # Raises error R3 today instead of copying the file to a named backup in its folder and giving its path.
    #
    #   _cBackupName_   the file name of the backup
    #   returns         nothing; it raises an error
    #   note            use CopyToAs
    #   warning         defect: calls the missing helper _FileDirPath (see CopyTo)
    #   see             CreateBackup, CopyToAs
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
    
    # Deletes the file from the disk and closes the manager.
    #
    #   returns    1 if deleted
    #   note       Exists then answers 0, Size -1, IsClosed 1; Remove is the same without a return
    #              value
    #   see        SafeDelete, Close
    #@ aka  DELETE OPERATIONS
    def Delete()
        # Deleting the file ends the management session: there is nothing left
        # to manage, so the manager is auto-closed. A following Close() is then
        # a harmless no-op (Close() automatic after Delete()).
        _bResult_ = StzEngineFileDelete(@cFileName)
        @bClosed = 1
        return _bResult_

        def DeleteQ()
            This.Delete()
            return This
 
			# Deletes the file from the disk and closes the manager.
			#
			#   returns    nothing
			#   note       it does what Delete does
			#   see        Delete
			def Remove()
				This.Delete()

			def RemoveQ()
				return This.DeleteQ()

    # Raises error R3 today instead of backing the file up and then deleting it.
    #
    #   returns    nothing; it raises an error
    #   note       use Delete after a CopyToAs
    #   warning    defect: it calls CreateBackup, which calls the missing helper
    #              _FileCompleteBaseName (see CopyTo); the file is left in place
    #   see        Delete, CreateBackup
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
    
		# Raises error R3 today instead of backing the file up and then deleting it.
		#
		#   returns    nothing; it raises an error
		#   note       use Remove after a CopyToAs
		#   warning    defect: same cause as SafeDelete
		#   see        SafeDelete, Remove
		def SafeRemove()
			This.SafeDelete()

			def SafeRemoveQ()
				return This.SafeDeleteQ()

    # Sets the read-only attribute through the engine, so later writes fail.
    #
    #   returns    1 if done
    #   note       after it IsWritable answers 0 and IsReadOnly 1
    #   see        MakeWritable, IsReadOnly
    #@ aka  PERMISSION OPERATIONS
    def MakeReadOnly()
        return StzEngineFileSetReadOnly(@cFileName, 1)

        def MakeReadOnlyQ()
            This.MakeReadOnly()
            return This

    # Clears the read-only attribute through the engine.
    #
    #   returns    1 if done
    #   note       after it IsWritable answers 1 again
    #   see        MakeReadOnly
    def MakeWritable()
        return StzEngineFileSetReadOnly(@cFileName, 0)

        def MakeWritableQ()
            This.MakeWritable()
            return This

    # Asks the engine to mark the file executable.
    #
    #   returns    1 if done
    #   note       it answered 1 on Windows, where no visible change was checked
    #   see        MakeReadOnly
    def MakeExecutable()
        return StzEngineFileSetExecutable(@cFileName)

        def MakeExecutableQ()
            This.MakeExecutable()
            return This
    
	# ENCRYPT/DECRYPT OPERATIONS (from stzCrypto) #TODO

	/* ... */

    # Returns the path of the managed file, which MoveToAs changes.
    #
    #   returns    a text
    #   see        Exists, Size
    #@ aka  UTILITY METHODS
    def FileName()
        return @cFileName
    
    # Returns the size of the file in bytes; -1 once the file is gone.
    #
    #   returns    a number
    #   see        Exists
    def Size()
        return StzEngineFileSize(@cFileName)

    # Returns TRUE if the file is still on the disk.
    #
    #   returns    TRUE or FALSE
    #   see        Size, IsClosed
    def Exists()
        return fexists(@cFileName)

    # Returns TRUE if the file cannot be opened for appending.
    #
    #   returns    TRUE or FALSE
    #   see        IsWritable, MakeReadOnly
    def IsReadOnly()
        return not This.IsWritable()

    # Returns 1 if the file can be opened for appending, but creates an empty file when the path does not exist.
    #
    #   returns    1 or 0
    #   note       it opens the path in append mode, as stzFileInfo.IsWritable does, so by the code
    #              a missing path would be created
    #   see        IsReadOnly, MakeWritable
    def IsWritable()
        try
            _fp_ = fopen(@cFileName, "a")
            if _fp_ != ""
                fclose(_fp_)
                return 1
            ok
        catch
        done
        return 0

    # Raises error R3 today instead of telling whether the extension marks an executable.
    #
    #   returns    nothing; it raises an error
    #   note       read the extension with StzFileExtension
    #   warning    defect: calls the missing helper _FileExtension (see CopyTo)
    #   see        MakeExecutable
    def IsExecutable()
        _cExt_ = StzLower(_FileExtension(@cFileName))
        if isWindows()
            return _cExt_ = "exe" or _cExt_ = "bat" or _cExt_ = "cmd" or _cExt_ = "com"
        ok
        return 0

    # Returns the empty text for every file; the modification time is not read.
    #
    #   returns    a text
    #   note       stzFileInfo.LastModified does read it
    #   see        Size
    def LastModified()
        return ""

    # Marks the manager closed; nothing is released.
    #
    #   returns    1
    #   see        IsClosed, Delete
    def Close()
        @bClosed = 1
        return 1

    # Returns 1 if Close or Delete has been called, else 0.
    #
    #   returns    1 or 0
    #   note       no operation checks it: a closed manager still answers
    #   see        Close
    def IsClosed()
        return @bClosed
