#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZCONFIDENCE               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Confidence scoring class backed by the      #
#                  Softanza Engine (stz_confidence module).     #
#                  Named scores (0.0-1.0) with weights.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzConfidenceQ()
	return new stzConfidence()

func IsStzConfidence(pObj)
	if isObject(pObj) and classname(pObj) = "stzconfidence"
		return 1
	else
		return 0
	ok

	func @IsStzConfidence(pObj)
		return IsStzConfidence(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzConfidence

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Engine manages global confidence store

	  #-------------------------------#
	 #     SET AND GET SCORES        #
	#-------------------------------#

	def Set(cName, nScore, nWeight)
		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Incorrect param! cName must be a non-empty string.")
			ok
			if NOT isNumber(nScore)
				StzRaise("Incorrect param! nScore must be a number (0.0-1.0).")
			ok
			if NOT isNumber(nWeight)
				StzRaise("Incorrect param! nWeight must be a number.")
			ok
		ok

		nResult = StzEngineConfSet(cName, nScore, nWeight)
		if nResult < 0
			StzRaise("Can't set confidence! Score slots full.")
		ok

		def SetQ(cName, nScore, nWeight)
			This.Set(cName, nScore, nWeight)
			return This

	def SetScore(cName, nScore)
		return This.Set(cName, nScore, 1.0)

		def SetScoreQ(cName, nScore)
			This.SetScore(cName, nScore)
			return This

	def Get(cName)
		return StzEngineConfGet(cName)

		def Score(cName)
			return This.Get(cName)

		def ConfidenceOf(cName)
			return This.Get(cName)

	  #-------------------------------#
	 #     AGGREGATION               #
	#-------------------------------#

	def WeightedAverage()
		return StzEngineConfWeightedAvg()

		def Average()
			return This.WeightedAverage()

	def Min()
		return StzEngineConfMin()

		def MinScore()
			return This.Min()

	def Max()
		return StzEngineConfMax()

		def MaxScore()
			return This.Max()

	  #-------------------------------#
	 #     COUNTING AND CLEANUP      #
	#-------------------------------#

	def Count()
		return StzEngineConfCount()

		def NumberOfScores()
			return This.Count()

	def Remove(cName)
		nResult = StzEngineConfRemove(cName)
		if nResult < 0
			StzRaise("Score '" + cName + "' not found!")
		ok

	def Clear()
		StzEngineConfClear()
