#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSIMILARITY               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Vector similarity class backed by the       #
#                  Softanza Engine (stz_similarity module).     #
#                  Cosine, Euclidean, Manhattan, dot product.   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzSimilarityQ()
	return new stzSimilarity()

func IsStzSimilarity(pObj)
	if isObject(pObj) and classname(pObj) = "stzsimilarity"
		return 1
	else
		return 0
	ok

	func @IsStzSimilarity(pObj)
		return IsStzSimilarity(pObj)

# Convenience global functions for 3D vectors

func CosineSimilarity3(a1, a2, a3, b1, b2, b3)
	return StzEngineSimCosine3(a1, a2, a3, b1, b2, b3)

func EuclideanDistance3(a1, a2, a3, b1, b2, b3)
	return StzEngineSimEuclidean3(a1, a2, a3, b1, b2, b3)

func ManhattanDistance3(a1, a2, a3, b1, b2, b3)
	return StzEngineSimManhattan3(a1, a2, a3, b1, b2, b3)

func DotProduct3(a1, a2, a3, b1, b2, b3)
	return StzEngineSimDotProduct3(a1, a2, a3, b1, b2, b3)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzSimilarity from stzObject

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Stateless utility class

	  #-------------------------------#
	 #     3D VECTOR OPERATIONS      #
	#-------------------------------#

	def Cosine3(a1, a2, a3, b1, b2, b3)
		return StzEngineSimCosine3(a1, a2, a3, b1, b2, b3)

		def CosineSimilarity(a1, a2, a3, b1, b2, b3)
			return This.Cosine3(a1, a2, a3, b1, b2, b3)

	def Euclidean3(a1, a2, a3, b1, b2, b3)
		return StzEngineSimEuclidean3(a1, a2, a3, b1, b2, b3)

		def EuclideanDistance(a1, a2, a3, b1, b2, b3)
			return This.Euclidean3(a1, a2, a3, b1, b2, b3)

	def Manhattan3(a1, a2, a3, b1, b2, b3)
		return StzEngineSimManhattan3(a1, a2, a3, b1, b2, b3)

		def ManhattanDistance(a1, a2, a3, b1, b2, b3)
			return This.Manhattan3(a1, a2, a3, b1, b2, b3)

	def DotProduct3(a1, a2, a3, b1, b2, b3)
		return StzEngineSimDotProduct3(a1, a2, a3, b1, b2, b3)

	  #-------------------------------#
	 #     LIST-BASED OPERATIONS     #
	#-------------------------------#

	# ANY DIMENSION, since phase 4 slice 6 of the numeric foundation.
	#
	# These four took lists and then insisted on exactly THREE elements, unpacking
	# them into the fixed-arity forms above. Three components is a geometry demo; a
	# sentence embedding is 384, 768, 1024 or 1536. The engine functions were always
	# written against a length -- what stopped them being used was the bridge, which
	# exposed only the 3-argument variants, plus a `dim > 1024 -> return 0.0` guard
	# inside similarity.zig that would have SILENTLY SCORED ZERO for a real
	# embedding. Both are gone; these are now general.
	#
	# The lengths must still MATCH each other -- comparing vectors of different
	# dimension is meaningless, and the engine refuses rather than reading the
	# shorter one's memory.

	def _CheckPair(paA, paB, cWho)
		if NOT isList(paA) or NOT isList(paB)
			StzRaise("stzSimilarity." + cWho + ": both arguments must be lists of numbers.")
		ok
		if len(paA) = 0
			StzRaise("stzSimilarity." + cWho + ": an empty vector has no " + cWho + ".")
		ok
		if len(paA) != len(paB)
			StzRaise("stzSimilarity." + cWho + ": the vectors must have the same " +
			         "dimension -- got " + len(paA) + " and " + len(paB) + ".")
		ok

	def CosineFromLists(paA, paB)
		This._CheckPair(paA, paB, "Cosine")
		return StzEngineSimCosine(paA, paB)

		def Cosine(paA, paB)
			return This.CosineFromLists(paA, paB)

	def EuclideanFromLists(paA, paB)
		This._CheckPair(paA, paB, "Euclidean")
		return StzEngineSimEuclidean(paA, paB)

		def Euclidean(paA, paB)
			return This.EuclideanFromLists(paA, paB)

	def ManhattanFromLists(paA, paB)
		This._CheckPair(paA, paB, "Manhattan")
		return StzEngineSimManhattan(paA, paB)

		def Manhattan(paA, paB)
			return This.ManhattanFromLists(paA, paB)

	def DotProductFromLists(paA, paB)
		This._CheckPair(paA, paB, "DotProduct")
		return StzEngineSimDotProduct(paA, paB)

		def Dot(paA, paB)
			return This.DotProductFromLists(paA, paB)

	# The length of a vector, which is what normalising divides by.
	def MagnitudeOf(paA)
		if NOT isList(paA) or len(paA) = 0
			StzRaise("stzSimilarity.MagnitudeOf: give me a non-empty list of numbers.")
		ok
		return StzEngineSimMagnitude(paA)

	# The unit vector in the same direction. A zero vector has no direction, so it
	# is returned unchanged rather than filled with NaN.
	def NormalizedList(paA)
		_nMag_ = This.MagnitudeOf(paA)
		if _nMag_ = 0
			return paA
		ok
		_aOut_ = []
		_nLen_ = len(paA)
		for _iNl_ = 1 to _nLen_
			_aOut_ + (paA[_iNl_] / _nMag_)
		next
		return _aOut_
