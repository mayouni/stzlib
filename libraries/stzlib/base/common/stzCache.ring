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

# Sketches a cache of function results kept in a file, but cannot be built today because its storage class is not loaded.
#
# The class is unfinished. Its init builds a stzCacheStorage, which builds a stzStorage, a class
# that sits in the future folder and is not loaded, so every construction raises error R11; with
# that class loaded the next call, TextFileCreateIfInexistant, is not defined either. Of the whole
# file, only Activate, Deactivate, IsActivated and Content run, and only on an object made without
# parentheses, which skips init. Every other method raises today, each for the same cause or for an
# undefined function; each says which in its warning.
#
#   receiver   o1 = new stzCache
#   example    ? o1.IsActivated()
#              #--> 0
#              o1.Activate()
#              ? o1.IsActivated()
#              #--> 1
#              o1.Deactivate()
#              ? o1.IsActivated()
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
	#   warning    the class is an unfinished sketch: its init raises error R11 today (see init), so
	#              this answers only on an object made without parentheses, new stzCache
	#   see        Activate, IsActivated
	def Content()
		return cCacheContent

		def Value()
			return This.Content()

	# Raises error R11 today instead of building a cache that stores its entries in a file.
	#
	#   pcCacheName     the cache's name
	#   pcStorageType   where entries are kept, such as :InFile
	#   returns         nothing; it always raises
	#   note            new stzCache with no parentheses skips init and gives an object whose
	#                   Activate, Deactivate, IsActivated and Content work
	#   warning         it builds a stzCacheStorage, which builds a stzStorage; that class sits in
	#                   the future folder and is not loaded, so the error names class stzstorage not
	#                   found; with the class loaded the next error is the call to the undefined
	#                   TextFileCreateIfInexistant; no cache can be built today
	#   see             StzCache
	func init(pcCacheName, pcStorageType)
		_cCacheName_ = pcCacheName
		_oCacheStorage_ = new stzCacheStorage("cache", pcCacheName, pcStorageType)

	# Raises error R13 today instead of returning where the cache keeps its entries.
	#
	#   returns    nothing; it raises Object is required
	#   warning    the storage object it asks is never built, because init raises
	#   see        init, CacheFileHandler
	def StorageType()
		return _oCacheStorage_.StorageType()

	# Marks the cache as activated.
	#
	#   returns    nothing
	#   warning    works only on an object made with new stzCache and no parentheses, since init
	#              raises
	#   see        Deactivate, IsActivated
	def Activate()
		bActivated = 1

	# Marks the cache as not activated.
	#
	#   returns    nothing
	#   warning    works only on an object made with new stzCache and no parentheses, since init
	#              raises
	#   see        Activate, IsActivated
	def Deactivate()
		bActivated = 0

	# TRUE if the cache was marked as activated and not deactivated since.
	#
	#   returns    TRUE or FALSE; FALSE on a new object
	#   warning    works only on an object made with new stzCache and no parentheses, since init
	#              raises
	#   see        Activate, Deactivate
	def IsActivated()
		return bActivated

	# Raises error R13 today instead of opening the cache's file or database.
	#
	#   returns    nothing; it raises Object is required
	#   warning    it starts by asking StorageType, which raises; the file and database calls it
	#              would make (TextFileOpen, DatabaseConnect) are not defined anywhere
	#   see        CacheFileHandler, StorageType
	func CacheOpen()
		switch StorageType()
		on :InFile
			return TextFileOpen(_cCacheFileName)
		on :InDatabase
			return DatabaseConnect(_cCacheDbName)
		off
		
	
	# Raises error R13 today instead of returning the handle of the cache's file.
	#
	#   returns    nothing; it raises Object is required
	#   warning    the storage object it asks is never built, because init raises
	#   see        CacheOpen, StorageType
	def CacheFileHandler()
		return _oCacheStorage_.FileHandler()

	# Raises error R3 today instead of closing the cache's file.
	#
	#   returns    nothing; it raises a call to the undefined function TextFileColse
	#   warning    the name is misspelled (Colse for Close) and no such function exists under either
	#              spelling
	#   see        CacheOpen
	func CacheFileColse()
		return TextFileColse(_CacheFileHandler)
	
	
	# Raises error R13 today instead of returning the line number of the entry for a function call.
	#
	#   pcFunc          the name of the function whose result is cached
	#   pcParamValues   the argument values of the call, as text
	#   returns         nothing; it raises Object is required
	#   warning         it reads the cache file through the storage object that init never builds
	#   see             CacheGetCachedResult, CacheFileLines
	func CacheFindEntry(pcFunc, pcParamValues)
		_n_ = 0
		_aTemp_ = CacheFileLines()
	
		_nTemp1Len_ = len(_aTemp_)
		for _iLoopTemp1_ = 1 to _nTemp1Len_
			_aLine_ = _aTemp_[_iLoopTemp1_]
			_n_++
			_oStzStr_ = new stzString(_aLine_)
	
			if _oStzStr_.Contains(pcFunc + "|" + pcParamValues)
				return _n_
			ok
		next
		return 0
	
	# Raises error R13 today instead of returning the cached result of a function call.
	#
	#   pcFunc          the name of the function whose result is cached
	#   pcParamValues   the argument values of the call, as text
	#   returns         nothing; it raises Object is required
	#   warning         it starts with CacheFindEntry, which raises
	#   see             CacheFindEntry, CacheGetResultInLineNumber
	func CacheGetCachedResult( pcFunc, pcParamValues)
		_n_ = CacheFindEntry(pcFunc, pcParamValues)
		if _n_ > 0
			return CacheGetResultInLineNumber(_n_)
		else
			stzError(:CacheEntryInexistant)
		ok
		
	# Raises error R13 today instead of returning the result stored on one line of the cache file.
	#
	#   pnLineNumber   the number of the line to read, from 1
	#   returns        nothing; it raises Object is required
	#   warning        it reads the cache file through the storage object that init never builds
	#   see            CacheFileLines, CacheGetCachedResult
	func CacheGetResultInLineNumber(pnLineNumber)
		_cLineStr_ = CacheFileLines()[ pnLineNumber ]
		_cCode_ = "_aTempList_ = " + _cLineStr_
		eval(_cCode_)
		return _aTempList_[4]
	
	# Raises error R13 today instead of returning the lines of the cache file.
	#
	#   returns    nothing; it raises Object is required
	#   warning    it needs the file name from the storage object that init never builds
	#   see        CacheFileLineNumber, CacheFileNumberOfLines
	func CacheFileLines()
		_cCache_ = read(_oCacheStorage_.CompleteFileName())
		_oStr_ = new stzString(_cCache_)
		_nLen_ = _oStr_.NumberOfChars()

		_aResult_ = []
		_cLine_ = ""
		_i_ = 0
		_nCache1Len_ = len(_cCache_)
		for _iLoopCache1_ = 1 to _nCache1Len_
			_c_ = _cCache_[_iLoopCache1_]
			_i_++
			if _c_ != "|"
				_cLine_ += _c_
			but _c_ = char(10) or _i_ = _nLen_
				_aResult_ + _cLine_
				_cLine_ = ""
			ok
		next
	
		return _aResult_
	
	# Raises error R13 today instead of returning one line of the cache file.
	#
	#   _n_        the number of the line to read, from 1
	#   returns    nothing; it raises Object is required
	#   warning    it starts with CacheFileLines, which raises
	#   see        CacheFileLines, CacheFileNumberOfLines
	func CacheFileLineNumber(_n_)
		return CacheFileLines()[_n_]
	
	# Raises error R13 today instead of returning how many lines the cache file holds.
	#
	#   returns    nothing; it raises Object is required
	#   warning    it starts with CacheFileLines, which raises
	#   see        CacheFileLines, CacheFileLineNumber
	func CacheFileNumberOfLines()
		return len(CacheFileLines())

	# Raises error R3 today instead of joining the parts of an entry into one line with a bar between them.
	#
	#   paParts    the parts of the entry, as a list
	#   returns    nothing; it raises a call to the undefined function TransformListToString
	#   warning    the function it calls is not defined anywhere in the library
	#   see        AddLine
	def ComposeLine(paParts)
		return TransformListToString(paParts, ["|",","])
	
	# Raises error R13 today instead of appending an entry to the cache file.
	#
	#   pcEntry    the entry to append, as text
	#   returns    nothing; it raises Object is required
	#   warning    it starts by asking StorageType; the file call it would make (TextFileAddLine) is
	#              not defined, and the :InMemomry and :InDatabase branches are empty TODOs, the
	#              first misspelled
	#   see        ComposeLine, StorageType
	def AddLine(pcEntry)
		switch StorageType()
		on :InFile
			TextFileAddLine(This.CacheFileHandler(), pcEntry)
		on :InMemomry
			//TODO
		on :InDatabase
			//TODO
		other
			stzError(:UnsupportedCacheStorage)
		off
	
# Sketches the file behind a stzCache, but cannot be built today because the storage class it forwards to is not loaded.
#
# The class holds a stzStorage and forwards four questions to it. Its init raises error R11, because
# stzStorage sits in the future folder and is not loaded, so no usable object exists: made without
# parentheses, which skips init, each of its methods raises Object is required.
#
#   receiver   o1 = new stzCacheStorage
#   example    ? classname(o1)
#              #--> stzcachestorage
#   see        stzCache
class stzCacheStorage from stzObject
	_oStorage_
	

	# Raises error R11 today instead of building the storage behind a cache.
	#
	#   pcCacheName     the cache's name, used as the storage file's name
	#   pcStoragePath   the folder that holds the storage file
	#   pcStorageType   where entries are kept, such as :InFile
	#   returns         nothing; it always raises
	#   note            new stzCacheStorage with no parentheses skips init, and then each method
	#                   below raises Object is required
	#   warning         it builds a stzStorage, which sits in the future folder and is not loaded,
	#                   so the error names class stzstorage not found; with that class loaded the
	#                   next error is the call to the undefined TextFileCreateIfInexistant; a
	#                   stzCacheStorage cannot be built today
	#   see             stzCache
	def init(pcCacheName, pcStoragePath, pcStorageType)
		_oStorage_ = new stzStorage(pcStoragePath, pcCacheName, pcStorageType)

	# Raises error R13 today instead of returning the handle of the storage file.
	#
	#   returns    nothing; it raises Object is required
	#   warning    it forwards to a stzStorage that init never builds
	#   see        CompleteFileName, FileName
	def FileHandler()
		return _oStorage_.FileHandler()

	# Raises error R13 today instead of returning the storage file's name.
	#
	#   returns    nothing; it raises Object is required
	#   warning    it forwards to a stzStorage that init never builds
	#   see        CompleteFileName, FileHandler
	def FileName()
		return _oStorage_.FileName()

	# Raises error R13 today instead of returning the storage file's name with its folder.
	#
	#   returns    nothing; it raises Object is required
	#   warning    it forwards to a stzStorage that init never builds
	#   see        FileName, FileHandler
	def CompleteFileName()
		return _oStorage_.CompleteFileName()

	# Raises error R13 today instead of returning where the storage keeps its entries.
	#
	#   returns    nothing; it raises Object is required
	#   warning    it forwards to a stzStorage that init never builds
	#   see        FileHandler
	def StorageType()
		return _oStorage_.StorageType()
