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

# Keeps weighted subject-relation-object triples in the engine, such as alice knows bob with weight 0.5, and reads them back by position.
#
# The store is held by the engine and shared by every stzRelation object of the process, so call
# Clear() first for a fresh one. Positions count from 0 in the order of adding, and Remove leaves a
# hole instead of shifting the others. There is no lookup by subject: read the triples by position.
#
#   receiver   o1 = new stzRelation() o1.Clear() o1.Add("alice", "knows", "bob", 0.5)
#              o1.AddSimple("bob", "knows", "carol")
#   example    ? o1.Count()
#              #--> 2
#              ? o1.Subject(0) + " " + o1.RelationType(0) + " " + o1.Object(0)
#              #--> alice knows bob
#              ? o1.Weight(0)
#              #--> 0.50
#              ? o1.Weight(1)
#              #--> 1
#              o1.Clear()
#   see        stzEngineTimeline, stzGraph
class stzRelation from stzObject

	  #--------------#
	 #     INIT     #
	#--------------#

	# Opens the engine's relation store, one list of weighted subject-relation-object triples that every stzRelation object shares.
	#
	#   returns    nothing; the object is built
	#   warning    the store is global to the process: relations added through one object are seen
	#              by every other
	#   see        Clear
	def init()
		# Engine manages global relation store

	  #-------------------------------#
	 #     ADD RELATIONS             #
	#-------------------------------#

	# Appends a weighted relation such as alice knows bob to the store.
	#
	#   cSubject        the subject, a text
	#   cRelationType   the kind of relation, a text
	#   cObject         the object, a text
	#   nWeight         the strength of the relation, a number
	#   returns         nothing
	#   note            positions are counted from 0, in the order of adding
	#   warning         a non-text subject, type or object and a non-number weight raise an error
	#   see             AddSimple, Count
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

	# Appends a relation with the weight 1.
	#
	#   cSubject        the subject, a text
	#   cRelationType   the kind of relation, a text
	#   cObject         the object, a text
	#   returns         nothing
	#   see             Add
	def AddSimple(cSubject, cRelationType, cObject)
		return This.Add(cSubject, cRelationType, cObject, 1.0)

	  #-------------------------------#
	 #     QUERY RELATIONS           #
	#-------------------------------#

	# Returns the subject of the relation at a position, counted from 0.
	#
	#   nIndex     the position of the relation, starting at 0
	#   returns    a text; empty when nothing is stored there
	#   see        Object, RelationType, Weight
	def Subject(nIndex)
		return StzEngineRelSubject(nIndex)

	# Returns the object of the relation at a position, counted from 0.
	#
	#   nIndex     the position of the relation, starting at 0
	#   returns    a text; empty when nothing is stored there
	#   see        Subject, RelationType
	def Object(nIndex)
		return StzEngineRelObject(nIndex)

	# Returns the kind of the relation at a position, counted from 0.
	#
	#   nIndex     the position of the relation, starting at 0
	#   returns    a text; empty when nothing is stored there
	#   see        Subject, Object
	def RelationType(nIndex)
		return StzEngineRelType(nIndex)

		def Type(nIndex)
			return This.RelationType(nIndex)

	# Returns the weight of the relation at a position, counted from 0.
	#
	#   nIndex     the position of the relation, starting at 0
	#   returns    a number; 0 when nothing is stored there
	#   see        Add, Subject
	def Weight(nIndex)
		return StzEngineRelWeight(nIndex)

	  #-------------------------------#
	 #     COUNTING AND CLEANUP      #
	#-------------------------------#

	# Returns how many relations are stored.
	#
	#   returns    a number
	#   see        Add, Remove
	def Count()
		return StzEngineRelCount()

		def NumberOfRelations()
			return This.Count()

	# Removes the relation at a position; the others keep their positions and the removed one reads empty.
	#
	#   nIndex     the position of the relation to remove, starting at 0
	#   returns    nothing
	#   warning    Count drops by one but no position shifts, so after Remove(1) of three relations,
	#              positions 0 and 2 still answer and position 1 is empty; a position with nothing
	#              stored is ignored
	#   see        Clear, Count
	def Remove(nIndex)
		StzEngineRelRemove(nIndex)

	# Empties the store for every object that shares it.
	#
	#   returns    nothing
	#   see        Remove, Count
	def Clear()
		StzEngineRelClear()
