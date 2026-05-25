#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZEMBEDDING               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Vector embedding store class backed by the  #
#                  Softanza Engine (stz_embedding module).      #
#                  Named 3D vectors with cosine similarity.     #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzEmbeddingQ()
	return new stzEmbedding()

func IsStzEmbedding(pObj)
	if isObject(pObj) and classname(pObj) = "stzembedding"
		return 1
	else
		return 0
	ok

	func @IsStzEmbedding(pObj)
		return IsStzEmbedding(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzEmbedding

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Engine manages global embedding store

	  #-------------------------------#
	 #     STORE AND QUERY           #
	#-------------------------------#

	def Store(cName, nX, nY, nZ)
		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Incorrect param! cName must be a non-empty string.")
			ok
			if NOT isNumber(nX) or NOT isNumber(nY) or NOT isNumber(nZ)
				StzRaise("Incorrect params! nX, nY, nZ must be numbers.")
			ok
		ok

		nResult = StzEngineEmbStore3(cName, nX, nY, nZ)
		if nResult < 0
			StzRaise("Can't store embedding! Slots full.")
		ok

		def StoreQ(cName, nX, nY, nZ)
			This.Store(cName, nX, nY, nZ)
			return This

	def Dimensions(cName)
		return StzEngineEmbDim(cName)

		def DimensionCount(cName)
			return This.Dimensions(cName)

	def CosineSimilarity(cNameA, cNameB)
		return StzEngineEmbCosine(cNameA, cNameB)

		def Cosine(cNameA, cNameB)
			return This.CosineSimilarity(cNameA, cNameB)

	def Has(cName)
		nResult = StzEngineEmbHas(cName)
		if nResult = 1
			return 1
		else
			return 0
		ok

		def Contains(cName)
			return This.Has(cName)

	  #-------------------------------#
	 #     COUNTING AND CLEANUP      #
	#-------------------------------#

	def Count()
		return StzEngineEmbCount()

		def NumberOfEmbeddings()
			return This.Count()

	def Remove(cName)
		nResult = StzEngineEmbRemove(cName)
		if nResult < 0
			StzRaise("Embedding '" + cName + "' not found!")
		ok

	def Clear()
		StzEngineEmbClear()
