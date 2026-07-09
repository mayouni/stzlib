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

class stzCache from stzObject
	_cCacheName_
	cCacheContent

	_oCacheStorage_

	_bActivated_ = 0

	def Content()
		return cCacheContent

		def Value()
			return This.Content()

	func init(pcCacheName, pcStorageType)
		_cCacheName_ = pcCacheName
		_oCacheStorage_ = new stzCacheStorage("cache", pcCacheName, pcStorageType)

	def StorageType()
		return _oCacheStorage_.StorageType()

	def Activate()
		_bActivated_ = 1

	def Deactivate()
		_bActivated_ = 0

	def IsActivated()
		return _bActivated_

	func CacheOpen()
		switch StorageType()
		on :InFile
			return TextFileOpen(_cCacheFileName)
		on :InDatabase
			return DatabaseConnect(_cCacheDbName)
		off
		
	
	def CacheFileHandler()
		return _oCacheStorage_.FileHandler()

	func CacheFileColse()
		return TextFileColse(_CacheFileHandler)
	
	
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
	
	func CacheGetCachedResult( pcFunc, pcParamValues)
		_n_ = CacheFindEntry(pcFunc, pcParamValues)
		if _n_ > 0
			return CacheGetResultInLineNumber(_n_)
		else
			stzError(:CacheEntryInexistant)
		ok
		
	func CacheGetResultInLineNumber(pnLineNumber)
		_cLineStr_ = CacheFileLines()[ pnLineNumber ]
		_cCode_ = "_aTempList_ = " + _cLineStr_
		eval(_cCode_)
		return _aTempList_[4]
	
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
			but _c_ = NL or _i_ = _nLen_
				_aResult_ + _cLine_
				_cLine_ = ""
			ok
		next
	
		return _aResult_
	
	func CacheFileLineNumber(_n_)
		return CacheFileLines()[_n_]
	
	func CacheFileNumberOfLines()
		return len(CacheFileLines())

	def ComposeLine(paParts)
		return TransformListToString(paParts, ["|",","])
	
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
	
class stzCacheStorage from stzObject
	_oStorage_
	

	def init(pcCacheName, pcStoragePath, pcStorageType)
		_oStorage_ = new stzStorage(pcStoragePath, pcCacheName, pcStorageType)

	def FileHandler()
		return _oStorage_.FileHandler()

	def FileName()
		return _oStorage_.FileName()

	def CompleteFileName()
		return _oStorage_.CompleteFileName()

	def StorageType()
		return _oStorage_.StorageType()
