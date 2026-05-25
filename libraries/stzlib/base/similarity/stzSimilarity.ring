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

class stzSimilarity

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

	def CosineFromLists(paA, paB)
		if CheckingParams()
			if NOT isList(paA) or NOT isList(paB) or len(paA) != 3 or len(paB) != 3
				StzRaise("Incorrect params! Both lists must contain exactly 3 numbers.")
			ok
		ok
		return This.Cosine3(paA[1], paA[2], paA[3], paB[1], paB[2], paB[3])

	def EuclideanFromLists(paA, paB)
		if CheckingParams()
			if NOT isList(paA) or NOT isList(paB) or len(paA) != 3 or len(paB) != 3
				StzRaise("Incorrect params! Both lists must contain exactly 3 numbers.")
			ok
		ok
		return This.Euclidean3(paA[1], paA[2], paA[3], paB[1], paB[2], paB[3])

	def ManhattanFromLists(paA, paB)
		if CheckingParams()
			if NOT isList(paA) or NOT isList(paB) or len(paA) != 3 or len(paB) != 3
				StzRaise("Incorrect params! Both lists must contain exactly 3 numbers.")
			ok
		ok
		return This.Manhattan3(paA[1], paA[2], paA[3], paB[1], paB[2], paB[3])

	def DotProductFromLists(paA, paB)
		if CheckingParams()
			if NOT isList(paA) or NOT isList(paB) or len(paA) != 3 or len(paB) != 3
				StzRaise("Incorrect params! Both lists must contain exactly 3 numbers.")
			ok
		ok
		return This.DotProduct3(paA[1], paA[2], paA[3], paB[1], paB[2], paB[3])
