#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZPROVENANCE               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Data provenance tracking class backed by    #
#                  the Softanza Engine (stz_provenance module). #
#                  Track entity origin, author, version.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzProvenanceQ()
	return new stzProvenance()

func IsStzProvenance(pObj)
	if isObject(pObj) and classname(pObj) = "stzprovenance"
		return 1
	else
		return 0
	ok

	func @IsStzProvenance(pObj)
		return IsStzProvenance(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzProvenance

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Engine manages global provenance store

	  #-------------------------------#
	 #     ADD RECORDS               #
	#-------------------------------#

	def Add(cEntity, cOrigin, cAuthor, nTimestamp)
		if CheckingParams()
			if NOT isString(cEntity) or cEntity = ""
				StzRaise("Incorrect param! cEntity must be a non-empty string.")
			ok
			if NOT isString(cOrigin)
				StzRaise("Incorrect param! cOrigin must be a string.")
			ok
			if NOT isString(cAuthor)
				StzRaise("Incorrect param! cAuthor must be a string.")
			ok
			if NOT isNumber(nTimestamp)
				StzRaise("Incorrect param! nTimestamp must be a number.")
			ok
		ok

		nHandle = StzEngineProvAdd(cEntity, cOrigin, cAuthor, nTimestamp)
		if nHandle < 0
			StzRaise("Can't add provenance record! Slots full.")
		ok

		return nHandle

		def AddQ(cEntity, cOrigin, cAuthor, nTimestamp)
			This.Add(cEntity, cOrigin, cAuthor, nTimestamp)
			return This

	def Record(cEntity, cOrigin, cAuthor)
		return This.Add(cEntity, cOrigin, cAuthor, 0)

		def RecordQ(cEntity, cOrigin, cAuthor)
			This.Record(cEntity, cOrigin, cAuthor)
			return This

	  #-------------------------------#
	 #     QUERY RECORDS             #
	#-------------------------------#

	def Entity(nIndex)
		return StzEngineProvEntity(nIndex)

	def Origin(nIndex)
		return StzEngineProvOrigin(nIndex)

	def Author(nIndex)
		return StzEngineProvAuthor(nIndex)

	def Timestamp(nIndex)
		return StzEngineProvTime(nIndex)

		def Time(nIndex)
			return This.Timestamp(nIndex)

	def Version(nIndex)
		return StzEngineProvVersion(nIndex)

	  #-------------------------------#
	 #     VERSION MANAGEMENT        #
	#-------------------------------#

	def BumpVersion(nIndex)
		nResult = StzEngineProvBumpVersion(nIndex)
		if nResult < 0
			StzRaise("Can't bump version! Record not found.")
		ok
		return nResult

		def BumpVersionQ(nIndex)
			This.BumpVersion(nIndex)
			return This

	  #-------------------------------#
	 #     COUNTING AND CLEANUP      #
	#-------------------------------#

	def Count()
		return StzEngineProvCount()

		def NumberOfRecords()
			return This.Count()

	def Remove(nIndex)
		StzEngineProvRemove(nIndex)

	def Clear()
		StzEngineProvClear()
