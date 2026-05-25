#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZEXPLAIN                 #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Explanation store class backed by the       #
#                  Softanza Engine (stz_explain module).        #
#                  Named explanations with categories.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzExplainQ()
	return new stzExplain()

func IsStzExplain(pObj)
	if isObject(pObj) and classname(pObj) = "stzexplain"
		return 1
	else
		return 0
	ok

	func @IsStzExplain(pObj)
		return IsStzExplain(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzExplain

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Engine manages global explanation store

	  #-------------------------------#
	 #     ADD AND QUERY             #
	#-------------------------------#

	def AddExplanation(cName, cText, cCategory)
		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Incorrect param! cName must be a non-empty string.")
			ok
			if NOT isString(cText)
				StzRaise("Incorrect param! cText must be a string.")
			ok
			if NOT isString(cCategory)
				StzRaise("Incorrect param! cCategory must be a string.")
			ok
		ok

		nResult = StzEngineExplAdd(cName, cText, cCategory)
		if nResult < 0
			StzRaise("Can't add explanation! Slots full.")
		ok

		def AddExplanationQ(cName, cText, cCategory)
			This.AddExplanation(cName, cText, cCategory)
			return This

	def TextOf(cName)
		return StzEngineExplGet(cName)

		def ExplanationOf(cName)
			return This.TextOf(cName)

	def CategoryOf(cName)
		return StzEngineExplCategory(cName)

	def Has(cName)
		nResult = StzEngineExplHas(cName)
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
		return StzEngineExplCount()

		def NumberOfExplanations()
			return This.Count()

	def CountByCategory(cCategory)
		return StzEngineExplCountByCategory(cCategory)

	def Remove(cName)
		nResult = StzEngineExplRemove(cName)
		if nResult < 0
			StzRaise("Explanation '" + cName + "' not found!")
		ok

	def Clear()
		StzEngineExplClear()
