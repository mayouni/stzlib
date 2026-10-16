func StzCache(cFile)
	return new stzCache(cFile)

func StzCacheQ(cFile)
	return new stzCache(cFile)

// Creates cache file, depending on its type, only if it is inexistant
// Otherwise, the cache file is open, and a handler of that file is returned
func CacheCreateIfInexistant(pcCacheName,pcStorageType)
	_cCompleteCacheFileName_ = CacheCompleteFileName(pcCacheName)

	switch pcStorageType
	on :InFile
		if NOT TextFileExists(_cCompleteCacheFileName_)
			_hCacheFileHandler_ = new stzCache(_cCompleteCacheFileName_, pcStorageType)
		else
			_hFileHandler_ = TextFileOpen(_cCompleteCacheFileName_)	
		ok

		return _hCacheFileHandler_		

	on :InMemory
		// TODO

	on :InDatabase
		// TODO
	off

func CacheActivate(pcCacheName)
	_cCompleteCacheFileName_ = CacheCompleteFileName(pcCacheName)

	_oTempHashList_ = new stzHashList(_aStzCaches)
	_n_ = _oTempHashList_.FindInKeys(_cCompleteCacheFileName_)
	_aStzCaches[_n_][2] = 1
	return 1

func CacheDeactivate(pcFileName)
	_cCompleteCacheFileName_ = CacheCompleteFileName(pcCacheName)
	_oTempHashList_ = new stzHashList(_aStzCaches)
	_n_ = _oTempHashList_.FindInKeys(_cCompleteCacheFileName_)
	_aStzCaches[_n_][2] = 0
	return 1

func IsCacheActivated(pcFileName)
	_cCompleteCacheFileName_ = CacheCompleteFileName(pcCacheName)
	_oTempHashList_ = new stzHashList(_aStzCaches)
	_n_ = _oTempHashList_.FindInKeys(_cCompleteCacheFileName_)
	return _aSteCaches[_n_][2]

	func @IsCacheActivated(pcFileName)
		return IsCacheActivated(pcFileName)

func CacheCompleteFileName(pcCacheName)
	return "cache/" + pcCacheName + ".txt"

func CacheComposeLine(paPieces)
	return TransformListToString(paPieces, ["|",","])
	#--> This function is undefined

func CacheAddLine(pcCacheName,pcEntry,pcStorageType)
	switch pcStorageType
	on :InFile	TextFileAddLine(CacheFileHandler(pcCacheName), cCacheLine)
	on :InMemomry	_cMemCache + cCacheLine
	on :InDatabase	DatabaseAddLine(_cCacheDatabase, _cCacheTable, cCacheLine)
	other
		stzError(:UnsupportedCacheStorage)
	off

func CacheFileHandler(pcCacheName)
	// A global variable that maintains the list of caches and their related file handlers
	// needs to be addedd
	_cCompleteCacheFileName_ = CacheCompleteFileName(pcCacheName)
	_n_ = find(_aStzCaches,_cCompleteCacheFileName_)
	return aStzCaches[_cCompleteCacheFileName_][1]

# Remembers the result of a function call, keyed by the function's name and its arguments, in a text file.
#
# A cache entry is one line of the cache file: the function name, the argument values as text and
# the result, joined by a bar (build it with ComposeLine, store it with AddLine). A lookup answers
# from the first line whose name and arguments both match exactly, upper and lower case
# included, so the same call after storing is a hit and any other argument is a miss. The
# file is "cache/<name>.txt" under the current folder, created when the cache is built, and it
# outlives the object: a new cache of the same name reads what an earlier one stored. A cache
# starts NOT activated and an inactive cache answers no lookup: call Activate first. Only the
# :InFile storage is implemented; :InMemory and :InDatabase are accepted by the constructor but
# keep nothing, and AddLine and CacheOpen raise for them.
#
#   receiver   o1 = new stzCache("sums", :InFile)
#   example    o1.Activate()
#              o1.AddLine( o1.ComposeLine([ "Add", "2,3", "5" ]) )
#              ? o1.CacheGetCachedResult("Add", "2,3")
#              #--> 5
#              ? o1.CacheFindEntry("Add", "2,4")
#              #--> 0
#   see        stzCacheStorage
class stzCache from stzObject
	_cCacheName_
	cCacheContent

	_oCacheStorage_

	bActivated = 0

	# Returns the cached content, which nothing in the class ever sets.
	#
	#   returns    the text NULL, always
	#   see        Activate, IsActivated
	def Content()
		return cCacheContent

		def Value()
			return This.Content()

	# Builds a cache whose entries are kept in the file "cache/<name>.txt", creating the folder and the file when missing.
	#
	#   pcCacheName     the cache's name, used as the file's name; it may not be empty, hold a
	#                   slash, a backslash or a colon, or contain two dots in a row
	#   pcStorageType   where entries are kept: :InFile is the only one implemented
	#   returns         the new cache, which is NOT activated
	#   note            the file is relative to the current folder; an existing file is kept as it is
	#   warning         :InMemory and :InDatabase build an object that keeps nothing, and a name
	#                   or type that is not text raises; any other type raises
	#   see             StzCache, Activate
	func init(pcCacheName, pcStorageType)
		_cCacheName_ = pcCacheName
		_oCacheStorage_ = new stzCacheStorage(pcCacheName, "cache", pcStorageType)

	# Returns where the cache keeps its entries, as the constructor was given it.
	#
	#   returns    the storage type as lower-case text, such as infile for :InFile
	#   see        init, CacheFileHandler
	def StorageType()
		return _oCacheStorage_.StorageType()

	# Marks the cache as activated, so that lookups answer.
	#
	#   returns    nothing
	#   see        Deactivate, IsActivated
	def Activate()
		bActivated = 1

	# Marks the cache as not activated, so that lookups answer nothing.
	#
	#   returns    nothing
	#   see        Activate, IsActivated
	def Deactivate()
		bActivated = 0

	# TRUE if the cache was marked as activated and not deactivated since.
	#
	#   returns    TRUE or FALSE; FALSE on a new cache
	#   see        Activate, Deactivate
	def IsActivated()
		return bActivated

	# Makes sure the cache's file exists and returns its handle.
	#
	#   returns    the handle of the cache file, which is its path
	#   warning    raises an error for :InMemory and :InDatabase, which have no file and no database
	#              layer behind them
	#   see        CacheFileHandler, StorageType
	func CacheOpen()
		switch This.StorageType()
		on :InFile
			if StzFileExists(This.CacheFileHandler()) = 0
				StzFileWrite(This.CacheFileHandler(), "")
			ok
			return This.CacheFileHandler()
		other
			StzRaise("stzCache.CacheOpen: the storage type '" + This.StorageType() + "' is not implemented, only :InFile is.")
		off

	# Returns the handle of the cache's file, which is the path of that file.
	#
	#   returns    the path "cache/<name>.txt", or the empty text for a storage that has no file
	#   note       the library's file functions work on paths, so the path is the handle
	#   see        CacheOpen, CacheFileClose
	func CacheFileHandler()
		return _oCacheStorage_.FileHandler()

	# Releases the cache's file, which here holds nothing open between calls.
	#
	#   returns    1
	#   note       every call opens and closes the file by itself, so the file survives closing and
	#              can be read at once; CacheFileColse is the same call under the old misspelling
	#   see        CacheOpen, CacheFileHandler
	func CacheFileClose()
		return 1

	# Releases the cache's file under the old misspelling of its name.
	#
	#   returns    1
	#   see        CacheFileClose
	func CacheFileColse()
		return This.CacheFileClose()

	# Returns the number of the first line stored for a function called with given arguments, or 0 when there is none.
	#
	#   pcFunc          the name of the function whose result is cached
	#   pcParamValues   the argument values of the call, as text
	#   returns         the line number from 1, or 0 on a miss
	#   warning         answers 0 on a cache that is not activated, whatever the file holds; both
	#                   parts must match exactly, upper and lower case included
	#   see             CacheGetCachedResult, CacheFileLines
	func CacheFindEntry(pcFunc, pcParamValues)
		if bActivated != 1
			return 0
		ok

		_aLines_ = This.CacheFileLines()
		_nLines_ = ring_len(_aLines_)
		for _iLine_ = 1 to _nLines_
			_aFields_ = This._SplitCacheLine(_aLines_[_iLine_])
			if ring_len(_aFields_) >= 3
				if strcmp(_aFields_[1], "" + pcFunc) = 0 and strcmp(_aFields_[2], "" + pcParamValues) = 0
					return _iLine_
				ok
			ok
		next
		return 0

	# Returns the result stored for a function called with given arguments.
	#
	#   pcFunc          the name of the function whose result is cached
	#   pcParamValues   the argument values of the call, as text
	#   returns         the stored result, as text, or the empty text when the cache is not activated
	#   warning         raises an error when the cache is activated and holds no entry for that call;
	#                   a stored number comes back as its text
	#   see             CacheFindEntry, CacheGetResultInLineNumber
	func CacheGetCachedResult( pcFunc, pcParamValues)
		if bActivated != 1
			return ""
		ok

		_n_ = This.CacheFindEntry(pcFunc, pcParamValues)
		if _n_ > 0
			return This.CacheGetResultInLineNumber(_n_)
		ok
		StzRaise("stzCache.CacheGetCachedResult: no cached entry for " + pcFunc + " with " + pcParamValues + ".")

	# Returns the result held on one line of the cache file, whether or not the cache is activated.
	#
	#   pnLineNumber   the number of the line to read, from 1
	#   returns        the third part of that line, as text, with its escapes undone
	#   warning        raises an error when the line does not exist or has fewer than three parts
	#   see            CacheFileLines, CacheGetCachedResult
	func CacheGetResultInLineNumber(pnLineNumber)
		_aFields_ = This._SplitCacheLine( This.CacheFileLineNumber(pnLineNumber) )
		if ring_len(_aFields_) < 3
			StzRaise("stzCache.CacheGetResultInLineNumber: line " + pnLineNumber + " is not a cache entry of three parts.")
		ok
		return _aFields_[3]

	# Returns the lines of the cache file, as they are written, one text per line.
	#
	#   returns    a list of texts; empty when the file is missing or empty
	#   note       a line keeps its bars and escapes; a carriage return before the end of a line is
	#              dropped, and so is the empty text after the last end of line
	#   see        CacheFileLineNumber, CacheFileNumberOfLines
	func CacheFileLines()
		_cData_ = StzFileRead(_oCacheStorage_.CompleteFileName())
		if NOT isString(_cData_)
			_cData_ = ""
		ok

		_aResult_ = []
		_cLine_ = ""
		_nData_ = ring_len(_cData_)
		for _iByte_ = 1 to _nData_
			_c_ = _cData_[_iByte_]
			if _c_ = char(10)
				_aResult_ + _cLine_
				_cLine_ = ""
			else
				_cLine_ += _c_
			ok
		next
		if _cLine_ != ""
			_aResult_ + _cLine_
		ok

		_nResult_ = ring_len(_aResult_)
		for _iLine_ = 1 to _nResult_
			_cOne_ = _aResult_[_iLine_]
			_nOne_ = ring_len(_cOne_)
			if _nOne_ > 0 and _cOne_[_nOne_] = char(13)
				_aResult_[_iLine_] = left(_cOne_, _nOne_ - 1)
			ok
		next
		return _aResult_

	# Returns one line of the cache file, as it is written.
	#
	#   _n_        the number of the line to read, from 1
	#   returns    the text of that line
	#   warning    raises an error when the file has no such line
	#   see        CacheFileLines, CacheFileNumberOfLines
	func CacheFileLineNumber(_n_)
		_aLines_ = This.CacheFileLines()
		if NOT isNumber(_n_) or _n_ < 1 or _n_ > ring_len(_aLines_)
			StzRaise("stzCache.CacheFileLineNumber: the cache file has no line " + _n_ + ".")
		ok
		return _aLines_[_n_]

	# Returns how many lines the cache file holds.
	#
	#   returns    a number, 0 for a missing or empty file
	#   see        CacheFileLines, CacheFileLineNumber
	func CacheFileNumberOfLines()
		return ring_len(This.CacheFileLines())

	# Joins the parts of an entry into one line, with a bar between the parts.
	#
	#   paParts    the parts of the entry, as a list of texts or numbers; a part that is a list is
	#              first joined with commas
	#   returns    the line, in which each backslash, bar, line feed and carriage return of a part
	#              is escaped so that it reads back unchanged; a number is written as Ring writes
	#              it as text, so 3.5 becomes 3.50
	#   warning    raises an error when paParts is not a list or a part is an object
	#   see        AddLine, CacheGetResultInLineNumber
	def ComposeLine(paParts)
		if NOT isList(paParts)
			StzRaise("stzCache.ComposeLine: the parts must be a list.")
		ok

		_cLine_ = ""
		_nParts_ = ring_len(paParts)
		for _iPart_ = 1 to _nParts_
			_part_ = paParts[_iPart_]
			if isList(_part_)
				_cText_ = ""
				_nItems_ = ring_len(_part_)
				for _iItem_ = 1 to _nItems_
					if isList(_part_[_iItem_]) or isObject(_part_[_iItem_])
						StzRaise("stzCache.ComposeLine: a part cannot hold a list or an object inside a list.")
					ok
					if _iItem_ > 1
						_cText_ += ","
					ok
					_cText_ += _part_[_iItem_]
				next
				_part_ = _cText_
			but isObject(_part_)
				StzRaise("stzCache.ComposeLine: a part cannot be an object.")
			ok

			if _iPart_ > 1
				_cLine_ += "|"
			ok
			_cLine_ += This._EscapeCacheField("" + _part_)
		next
		return _cLine_

	# Appends one entry to the end of the cache file.
	#
	#   pcEntry    the entry to append, as one line of text, such as the answer of ComposeLine
	#   returns    1
	#   warning    raises an error for a line that holds a line feed or a carriage return, for a
	#              text that is not a string, and for :InMemory and :InDatabase, which keep nothing
	#   see        ComposeLine, CacheFileLines
	def AddLine(pcEntry)
		if NOT isString(pcEntry) or StzFindFirst(char(10), pcEntry) > 0 or StzFindFirst(char(13), pcEntry) > 0
			StzRaise("stzCache.AddLine: the entry must be one line of text, build it with ComposeLine.")
		ok

		switch This.StorageType()
		on :InFile
			StzFileAppend(This.CacheFileHandler(), pcEntry + char(10))
			return 1
		other
			StzRaise("stzCache.AddLine: the storage type '" + This.StorageType() + "' is not implemented, only :InFile is.")
		off

	# Returns a text with each backslash, bar, line feed and carriage return replaced by a two-character escape.
	#
	#   pcText    the text to escape
	#   returns   the escaped text, which holds no bar and no end of line
	#   see       ComposeLine, _UnescapeCacheField
	def _EscapeCacheField(pcText)
		_cOut_ = ""
		_nText_ = ring_len(pcText)
		for _i_ = 1 to _nText_
			_c_ = pcText[_i_]
			if _c_ = "\"
				_cOut_ += "\\"
			but _c_ = "|"
				_cOut_ += "\p"
			but _c_ = char(10)
				_cOut_ += "\n"
			but _c_ = char(13)
				_cOut_ += "\r"
			else
				_cOut_ += _c_
			ok
		next
		return _cOut_

	# Returns a text with the two-character escapes of an entry part turned back into the characters they stand for.
	#
	#   pcText    the escaped text
	#   returns   the original text
	#   see       _EscapeCacheField, _SplitCacheLine
	def _UnescapeCacheField(pcText)
		_cOut_ = ""
		_nText_ = ring_len(pcText)
		_i_ = 1
		while _i_ <= _nText_
			_c_ = pcText[_i_]
			if _c_ = "\" and _i_ < _nText_
				_d_ = pcText[_i_ + 1]
				if _d_ = "\"
					_cOut_ += "\"
					_i_ += 2
				but _d_ = "p"
					_cOut_ += "|"
					_i_ += 2
				but _d_ = "n"
					_cOut_ += char(10)
					_i_ += 2
				but _d_ = "r"
					_cOut_ += char(13)
					_i_ += 2
				else
					_cOut_ += _c_
					_i_++
				ok
			else
				_cOut_ += _c_
				_i_++
			ok
		end
		return _cOut_

	# Returns the parts of one cache line, split at its bars and unescaped.
	#
	#   pcLine    one line of the cache file
	#   returns   a list of texts, one per part
	#   see       ComposeLine, _UnescapeCacheField
	def _SplitCacheLine(pcLine)
		_aParts_ = []
		_cPart_ = ""
		_nLine_ = ring_len(pcLine)
		for _i_ = 1 to _nLine_
			_c_ = pcLine[_i_]
			if _c_ = "|"
				_aParts_ + This._UnescapeCacheField(_cPart_)
				_cPart_ = ""
			else
				_cPart_ += _c_
			ok
		next
		_aParts_ + This._UnescapeCacheField(_cPart_)
		return _aParts_

# Holds where a stzCache keeps its entries: the storage type, the folder, the file name and the file's handle.
#
# It replaces the stzStorage class of the future folder, which is not loaded. For :InFile it builds
# the folder and an empty file when they are missing and leaves an existing file untouched; the
# handle of the file is its path, since the library's file functions work on paths. For :InMemory
# and :InDatabase it builds nothing and the handle is the empty text.
#
#   receiver   o1 = new stzCacheStorage("sums", "cache", :InFile)
#   example    ? o1.CompleteFileName()
#              #--> cache/sums.txt
#   see        stzCache
class stzCacheStorage from stzObject
	_cStorageType_
	_cStoragePath_
	_cFileName_
	_cCompleteFileName_
	_cFileHandler_

	# Builds the storage behind a cache, creating its folder and file for :InFile when they are missing.
	#
	#   pcCacheName     the cache's name, used as the storage file's name with ".txt" added; it may not
	#                   be empty, hold a slash, a backslash or a colon, or contain two dots in a row
	#   pcStoragePath   the folder that holds the storage file, relative to the current folder or absolute
	#   pcStorageType   where entries are kept: :InFile, :InMemory or :InDatabase
	#   returns         the new storage
	#   warning         only :InFile has a file; a name or path that is not usable text, or a type
	#                   other than the three, raises an error
	#   see             stzCache
	def init(pcCacheName, pcStoragePath, pcStorageType)
		if NOT isString(pcCacheName) or ring_trim(pcCacheName) = "" or
		   StzFindFirst("/", pcCacheName) > 0 or StzFindFirst("\", pcCacheName) > 0 or
		   StzFindFirst(":", pcCacheName) > 0 or StzFindFirst("..", pcCacheName) > 0
			StzRaise("stzCacheStorage: the cache name must be a non-empty text without a slash, a backslash, a colon or two dots.")
		ok
		if NOT isString(pcStoragePath) or ring_trim(pcStoragePath) = "" or StzFindFirst("..", pcStoragePath) > 0
			StzRaise("stzCacheStorage: the storage path must be a non-empty text without two dots.")
		ok
		if NOT isString(pcStorageType)
			StzRaise("stzCacheStorage: the storage type must be a text.")
		ok

		_cFileName_ = pcCacheName + ".txt"
		_cStoragePath_ = pcStoragePath
		_cCompleteFileName_ = pcStoragePath + "/" + _cFileName_
		_cStorageType_ = StzLower(pcStorageType)
		_cFileHandler_ = ""

		switch _cStorageType_
		on :InFile
			if StzDirExists(pcStoragePath) = 0
				StzDirCreatePath(pcStoragePath)
			ok
			if StzFileExists(_cCompleteFileName_) = 0
				StzFileWrite(_cCompleteFileName_, "")
			ok
			_cFileHandler_ = _cCompleteFileName_
		on :InMemory
			# nothing is kept
		on :InDatabase
			# nothing is kept
		other
			StzRaise("stzCacheStorage: unsupported storage type '" + pcStorageType + "'.")
		off

	# Returns the handle of the storage file, which is its path.
	#
	#   returns    the path of the file for :InFile, the empty text for the other types
	#   see        CompleteFileName, FileName
	def FileHandler()
		return _cFileHandler_

	# Returns the storage file's name, without its folder.
	#
	#   returns    the cache's name with ".txt" added
	#   see        CompleteFileName, FileHandler
	def FileName()
		return _cFileName_

	# Returns the storage file's name with its folder.
	#
	#   returns    the folder, a slash and the file name, as it was built
	#   see        FileName, FileHandler
	def CompleteFileName()
		return _cCompleteFileName_

	# Returns where the storage keeps its entries, as it was given.
	#
	#   returns    the storage type as lower-case text, such as infile for :InFile
	#   see        FileHandler
	def StorageType()
		return _cStorageType_
