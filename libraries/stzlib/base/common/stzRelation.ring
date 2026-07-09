#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZRELATION                 #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Weighted binary relations class backed by   #
#                  the Softanza Engine (stz_relations module).  #
#                  Subject-Relation-Object triples with weight. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzRelationQ()
	return new stzRelation()

func IsStzRelation(pObj)
	if isObject(pObj) and classname(pObj) = "stzrelation"
		return 1
	else
		return 0
	ok

	func @IsStzRelation(pObj)
		return IsStzRelation(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzRelation from stzObject

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Engine manages global relation store

	  #-------------------------------#
	 #     ADD RELATIONS             #
	#-------------------------------#

	def Add(cSubject, cRelationType, cObject, nWeight)
		if CheckingParams()
			if NOT isString(cSubject) or NOT isString(cRelationType) or NOT isString(cObject)
				StzRaise("Incorrect params! cSubject, cRelationType, and cObject must be strings.")
			ok
			if NOT isNumber(nWeight)
				StzRaise("Incorrect param! nWeight must be a number.")
			ok
		ok

		_nHandle_ = StzEngineRelAdd(cSubject, cRelationType, cObject, nWeight)
		if _nHandle_ < 0
			StzRaise("Can't add relation! Slots full.")
		ok
		return _nHandle_

		def AddQ(cSubject, cRelationType, cObject, nWeight)
			This.Add(cSubject, cRelationType, cObject, nWeight)
			return This

	def AddSimple(cSubject, cRelationType, cObject)
		return This.Add(cSubject, cRelationType, cObject, 1.0)

	  #-------------------------------#
	 #     QUERY RELATIONS           #
	#-------------------------------#

	def Subject(nIndex)
		return StzEngineRelSubject(nIndex)

	def Object(nIndex)
		return StzEngineRelObject(nIndex)

	def RelationType(nIndex)
		return StzEngineRelType(nIndex)

		def Type(nIndex)
			return This.RelationType(nIndex)

	def Weight(nIndex)
		return StzEngineRelWeight(nIndex)

	  #-------------------------------#
	 #     COUNTING AND CLEANUP      #
	#-------------------------------#

	def Count()
		return StzEngineRelCount()

		def NumberOfRelations()
			return This.Count()

	def Remove(nIndex)
		StzEngineRelRemove(nIndex)

	def Clear()
		StzEngineRelClear()
