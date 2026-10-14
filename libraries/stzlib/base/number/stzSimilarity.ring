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

# Measures how alike two vectors are: cosine similarity, Euclidean and Manhattan distance, dot product, and the length and unit form of one vector.
#
# Build one with new stzSimilarity() or StzSimilarityQ(); it holds nothing, so it is a bundle of
# calculations done in the Zig engine. The methods ending in 3 take six numbers, for two 3-component
# vectors; the ones ending in FromLists, and their short names Cosine, Euclidean, Manhattan and Dot,
# take two lists of any length, 1,536 for a sentence embedding included, and refuse lists of
# different lengths. The global functions CosineSimilarity3, EuclideanDistance3, ManhattanDistance3
# and DotProduct3 do the 3-component case without an object. Cosine is 1 for the same direction, 0
# for perpendicular, -1 for opposite.
#
#   receiver   o1 = new stzSimilarity()
#   example    ? o1.CosineFromLists([ 1, 0 ], [ 0, 1 ])
#              #--> 0
#              ? o1.EuclideanFromLists([ 0, 0 ], [ 3, 4 ])
#              #--> 5
#              ? o1.DotProductFromLists([ 1, 2 ], [ 3, 4 ])
#              #--> 11
#              ? o1.MagnitudeOf([ 3, 4 ])
#              #--> 5
#   see        stzVectorIndex, stzMatrix
class stzSimilarity from stzObject

	  #--------------#
	 #     INIT     #
	#--------------#

	# Builds the stateless similarity helper; it takes no argument and holds no data.
	#
	#   returns    nothing; the object is built
	#   see        Cosine3, CosineFromLists
	def init()
		# Stateless utility class

	  #-------------------------------#
	 #     3D VECTOR OPERATIONS      #
	#-------------------------------#

	# Returns the cosine of the angle between two 3-component vectors given as six numbers, from -1 for opposite to 1 for the same direction.
	#
	#   a1         the first component of the first vector
	#   a2         its second
	#   a3         its third
	#   b1         the first component of the second vector
	#   b2         its second
	#   b3         its third
	#   returns    a number from -1 to 1; 0 when a vector is all zeros
	#   note       CosineSimilarity is the same method; a component that is not a number is read as
	#              0 without a message
	#   see        CosineFromLists, Euclidean3
	def Cosine3(a1, a2, a3, b1, b2, b3)
		return StzEngineSimCosine3(a1, a2, a3, b1, b2, b3)

		def CosineSimilarity(a1, a2, a3, b1, b2, b3)
			return This.Cosine3(a1, a2, a3, b1, b2, b3)

	# Returns the straight-line distance between two points of 3 components given as six numbers.
	#
	#   a1         the first component of the first point
	#   a2         its second
	#   a3         its third
	#   b1         the first component of the second point
	#   b2         its second
	#   b3         its third
	#   returns    a number, 0 or more
	#   note       EuclideanDistance is the same method; (0,0,0) to (3,4,0) is 5
	#   see        EuclideanFromLists, Manhattan3
	def Euclidean3(a1, a2, a3, b1, b2, b3)
		return StzEngineSimEuclidean3(a1, a2, a3, b1, b2, b3)

		def EuclideanDistance(a1, a2, a3, b1, b2, b3)
			return This.Euclidean3(a1, a2, a3, b1, b2, b3)

	# Returns the distance between two points of 3 components counted along the axes, the sum of the absolute differences.
	#
	#   a1         the first component of the first point
	#   a2         its second
	#   a3         its third
	#   b1         the first component of the second point
	#   b2         its second
	#   b3         its third
	#   returns    a number, 0 or more
	#   note       ManhattanDistance is the same method; (0,0,0) to (3,4,0) is 7
	#   see        ManhattanFromLists, Euclidean3
	def Manhattan3(a1, a2, a3, b1, b2, b3)
		return StzEngineSimManhattan3(a1, a2, a3, b1, b2, b3)

		def ManhattanDistance(a1, a2, a3, b1, b2, b3)
			return This.Manhattan3(a1, a2, a3, b1, b2, b3)

	# Returns the dot product of two 3-component vectors given as six numbers, the sum of the products of matching components.
	#
	#   a1         the first component of the first vector
	#   a2         its second
	#   a3         its third
	#   b1         the first component of the second vector
	#   b2         its second
	#   b3         its third
	#   returns    a number
	#   note       (1,2,3) with (4,5,6) is 32
	#   see        DotProductFromLists, Cosine3
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

	# Returns the cosine of the angle between two vectors of any dimension, such as two sentence embeddings.
	#
	#   paA        the first vector, a non-empty list of numbers
	#   paB        the second vector, a list of the same length
	#   returns    a number from -1 to 1; 0 when a vector is all zeros
	#   note       Cosine is the same method; vectors of different lengths, empty vectors or non-
	#              lists raise an error that says which; works for 1,536 components
	#   see        Cosine3, EuclideanFromLists
	def CosineFromLists(paA, paB)
		This._CheckPair(paA, paB, "Cosine")
		return StzEngineSimCosine(paA, paB)

		def Cosine(paA, paB)
			return This.CosineFromLists(paA, paB)

	# Returns the straight-line distance between two points of any dimension.
	#
	#   paA        the first point, a non-empty list of numbers
	#   paB        the second point, a list of the same length
	#   returns    a number, 0 or more
	#   note       Euclidean is the same method; the lists must have the same length
	#   see        Euclidean3, ManhattanFromLists
	def EuclideanFromLists(paA, paB)
		This._CheckPair(paA, paB, "Euclidean")
		return StzEngineSimEuclidean(paA, paB)

		def Euclidean(paA, paB)
			return This.EuclideanFromLists(paA, paB)

	# Returns the sum of the absolute differences of two vectors of any dimension.
	#
	#   paA        the first vector, a non-empty list of numbers
	#   paB        the second vector, a list of the same length
	#   returns    a number, 0 or more
	#   note       Manhattan is the same method; the lists must have the same length
	#   see        Manhattan3, EuclideanFromLists
	def ManhattanFromLists(paA, paB)
		This._CheckPair(paA, paB, "Manhattan")
		return StzEngineSimManhattan(paA, paB)

		def Manhattan(paA, paB)
			return This.ManhattanFromLists(paA, paB)

	# Returns the dot product of two vectors of any dimension, the sum of the products of matching components.
	#
	#   paA        the first vector, a non-empty list of numbers
	#   paB        the second vector, a list of the same length
	#   returns    a number
	#   note       Dot is the same method; the lists must have the same length
	#   see        DotProduct3, CosineFromLists
	def DotProductFromLists(paA, paB)
		This._CheckPair(paA, paB, "DotProduct")
		return StzEngineSimDotProduct(paA, paB)

		def Dot(paA, paB)
			return This.DotProductFromLists(paA, paB)

	# Returns the length of a vector, the square root of the sum of its squares.
	#
	#   paA        the vector, a non-empty list of numbers
	#   returns    a number, 0 or more
	#   note       an empty list raises an error; [ 3, 4 ] has magnitude 5
	#   see        NormalizedList
	#@ aka  The length of a vector, which is what normalising divides by.
	def MagnitudeOf(paA)
		if NOT isList(paA) or len(paA) = 0
			StzRaise("stzSimilarity.MagnitudeOf: give me a non-empty list of numbers.")
		ok
		return StzEngineSimMagnitude(paA)

	# Returns the vector scaled to length 1, the unit vector in the same direction.
	#
	#   paA        the vector, a non-empty list of numbers
	#   returns    a list of numbers; the zero vector unchanged
	#   note       a zero vector is returned as it is, since it has no direction, not filled with
	#              NaN
	#   see        MagnitudeOf
	#@ aka  The unit vector in the same direction. A zero vector has no direction, so it is returned unchanged rather than filled with NaN.
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
