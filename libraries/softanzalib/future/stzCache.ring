func StzCache(cFile)
	return new stzCache(cFile)

func StzCacheQ(cFile)
	return new stzCache(cFile)

// Creates cache file, depending on its type, only if it is inexistant
// Otherwise, the cache file is open, and a handler of that file is returned
func CacheCreateIfInexistant(pcCacheName,pcStorageType)
	cCompleteCacheFileName = CacheCompleteFileName(pcCacheName)

	switch pcStorageType
	on :InFile
		if NOT TextFileExists(cCompleteCacheFileName)
			hCacheFileHandler = new stzCache(cCompleteCacheFileName, pcStorageType)
		else
			hFileHandler = TextFileOpen(cCompleteCacheFileName)	
		ok

		return hCacheFileHandler		

	on :InMemory
		// TODO

	on :InDatabase
		// TODO
	off

func CacheActivate(pcCacheName)
	cCompleteCacheFileName = CacheCompleteFileName(pcCacheName)

	oTempHashList = new stzHashList(_aStzCaches)
	n = oTempHashList.FindInKeys(cCompleteCacheFileName)
	_aStzCaches[n][2] = TRUE
	return TRUE

func CacheDeactivate(pcFileName)
	cCompleteCacheFileName = CacheCompleteFileName(pcCacheName)
	oTempHashList = new stzHashList(_aStzCaches)
	n = oTempHashList.FindInKeys(cCompleteCacheFileName)
	_aStzCaches[n][2] = FALSE
	return TRUE

func IsCacheActivated(pcFileName)
	cCompleteCacheFileName = CacheCompleteFileName(pcCacheName)
	oTempHashList = new stzHashList(_aStzCaches)
	n = oTempHashList.FindInKeys(cCompleteCacheFileName)
	return _aSteCaches[n][2]

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
	cCompleteCacheFileName = CacheCompleteFileName(pcCacheName)
	n = find(_aStzCaches,cCompleteCacheFileName)
	return aStzCaches[cCompleteCacheFileName][1]

class stzCache from stzObject
	cCacheName
	cCacheContent

	oCacheStorage

	bActivated = FALSE

	def Content()
		return cCacheContent

		def Value()
			return This.Content()

	func init(pcCacheName, pcStorageType)
		cCacheName = pcCacheName
		oCacheStorage = new stzCacheStorage("cache", pcCacheName, pcStorageType)

	def StorageType()
		return oCacheStorage.StorageType()

	def Activate()
		bActivated = TRUE

	def Deactivate()
		bactivated = FALSE

	def IsActivated()
		return bActivated

	func CacheOpen()
		switch StorageType()
		on :InFile
			return TextFileOpen(_cCacheFileName)
		on :InDatabase
			return DatabaseConnect(_cCacheDbName)
		off
		
	
	def CacheFileHandler()
		return oCacheStorage.FileHandler()

	func CacheFileColse()
		return TextFileColse(_CacheFileHandler)
	
	
	func CacheFindEntry(pcFunc, pcParamValues)
		n = 0
		aTemp = CacheFileLines()
	
		for aLine in aTemp
			n++
			oStzStr = new stzString(aLine)
	
			if oStzStr.Contains(pcFunc + "|" + pcParamValues)
				return n
			ok
		next
		return FALSE
	
	func CacheGetCachedResult( pcFunc, pcParamValues)
		n = CacheFindEntry(pcFunc, pcParamValues)
		if n > 0
			return CacheGetResultInLineNumber(n)
		else
			stzError(:CacheEntryInexistant)
		ok
		
	func CacheGetResultInLineNumber(pnLineNumber)
		cLineStr = CacheFileLines()[ pnLineNumber ]
		cCode = "aTempList = " + cLineStr
		eval(cCode)
		return aTempList[4]
	
	func CacheFileLines()
		cCache = read(oCacheStorage.CompleteFileName())
		oStr = new stzString(cCache)
		nLen = oStr.NumberOfChars()

		aResult = []
		cLine = ""
		i = 0
		for c in cCache
			i++
			if c != "|"
				cLine += c
			but c = NL or i = nLen
				aResult + cLine
				cLine = ""
			ok
		next
	
		return aResult
	
	func CacheFileLineNumber(n)
		return CacheFileLines()[n]
	
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
	oStorage
	

	def init(pcCacheName, pcStoragePath, pcStorageType)
		oStorage = new stzStorage(pcStoragePath, pcCacheName, pcStorageType)

	def FileHandler()
		return oStorage.FileHandler()

	def FileName()
		return oStorage.FileName()

	def CompleteFileName()
		return oStorage.CompleteFileName()

	def StorageType()
		return oStorage.StorageType()
