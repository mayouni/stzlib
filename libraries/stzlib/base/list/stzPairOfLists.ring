
// TODO: Generalise this class in stzListOfLists
// --> See work done in stzListOfListsOfNumbers and complete it

func StzPairOfListsQ(paList1, paList2)
	return new stzPairOfLists(paList1, paList2)

# Holds two lists side by side and pairs their items by position.
#
# Build one with new stzPairOfLists(aList1, aList2) or StzPairOfListsQ(aList1, aList2). Associate
# zips the lists into [ first, second ] pairs and stops at the shorter one;
# AssociateQRT(:stzHashList) answers the pairs as a hash list. Alternate is meant to interleave the
# two lists and raises error R24 today for any non-empty pair. The file marks the class as a
# candidate for generalisation into stzListOfLists.
#
#   receiver   o1 = new stzPairOfLists([ "a", "b", "c" ], [ 1, 2, 3 ])
#   example    ? @@( o1.Associate() )
#              #--> [ [ "a", 1 ], [ "b", 2 ], [ "c", 3 ] ]
#              ? @@( o1.FirstList() )
#              #--> [ "a", "b", "c" ]
#              ? @@( o1.SecondList() )
#              #--> [ 1, 2, 3 ]
#   see        stzListOfLists, stzPair, stzHashList
class stzPairOfLists from stzListOfLists

	@aList1
	@aList2

	# Builds a pair of lists from two lists, refusing anything that is not a list.
	#
	#   paList1    the first list
	#   paList2    the second list
	#   returns    nothing; the object is built
	#   warning    a value that is not a list raises "Can not create object!"
	#   see        FirstList, SecondList
	def init(paList1, paList2)
		if NOT @BothAreLists(paList1, paList2)
			StzRaise("Can not create object!")
		ok

		@aList1 = paList1
		@aList2 = paList2

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	# Returns the two lists as one list of two lists.
	#
	#   returns    a list of two lists
	#   see        FirstList, SecondList, Value
	def Content()
		return [ @aList1, @aList2 ]

		def PairOfLists()
			return This.Content()

		# Returns the two lists as one list of two lists, the same answer as Content.
		#
		#   returns    a list of two lists
		#   see        Content
		def Value()
			return Content()

	# Returns the first of the two lists.
	#
	#   returns    a list
	#   see        SecondList
	def FirstList()
		return @aList1

	# Returns the second of the two lists.
	#
	#   returns    a list
	#   see        FirstList
	def SecondList()
		return @aList2

	# Returns the items of the two lists taken in turn: one of the longer list, one of the other.
	#
	#   returns    a list; when one list is longer, its extra items come last
	#   note       with lists of equal length the first list leads: [1,2] and ["a","b"] give
	#              [ 1, "a", 2, "b" ]
	#   see        Associate
	def Alternate()
		aFirst = @aList1
		aSecond = @aList2
		if len(aSecond) > len(aFirst)
			aFirst = @aList2
			aSecond = @aList1
		ok
		nFirst = len(aFirst)
		nSecond = len(aSecond)
		aResult = []
		for i = 1 to nFirst
			aResult + aFirst[i]
			if i <= nSecond
				aResult + aSecond[i]
			ok
		next
		return aResult

		def AlternateQ()
			return new stzList( This.Alternate() )

	# Returns the items of the two lists paired by position, as a list of [ first, second ] pairs.
	#
	#   returns    a list of pairs, as many as the shorter list
	#   note       the extra items of the longer list are dropped; AssociateQ answers a stzList and
	#              AssociateQRT(:stzHashList) a stzHashList
	#   see        Alternate, AssociateQ
	def Associate()
		_aResult_ = []
		_nLen1_ = len( This.FirstList() )
		_nlen2_ = len( This.SecondList() )

		for i = 1 to _nLen1_
			if i <= _nlen2_
				_aResult_ + [ This.FirstList()[i], This.SecondList()[i] ]
			ok
		next

		return _aResult_

		def AssociateQ()
			return This.AssociateQRT(:stzList)

		def AssociateQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Associate() )

			on :stzHashList
				return new stzHashList( This.Associate() )

			other
				StzRaise("Unsupported return type!")
			off
