	// This part of Softanza is dedicated to Teeba, my daughter, who challenged me, and inspired me!

/*
	QuestionEnging on lists and alike
	oList = new stzList([ ... ])
	oList.Q("items that are strings alligned to the right")
*/
	  #----------------------------------------------#
	 #     Related to the root level of the list    #
	#---------------------------------------------#

	def ItemsThatAre_Duplicated()
		oQuery.SelectWhere( :CurrentItem, :IsDuplicated, TRUE )

		def AllItemsAre_Duplicated()		def ContainsOnly_ItemsThatAre_Duplicated()
		def SomeItemsAre_Duplicated()		def ContainsSome_ItemsThatAre_Duplicated()
		def NoItemsAre_Duplicated()		def ContainsNo_ItemsThatAre_Duplicated()
	def Exclude_ItemsThatAre_Duplicated()

	def ItemsThatAre_OfTheSameType() 
		aResult = []
		/* [ :Number = [ item2, item5],
		     :String = [ :item1, item3],
		     :Object = [ :item4] ]
		*/

		aTypes = This.Types()
		for t in aTypes
			aItems = []
			for i=1 to NumberOfItems()
				if type( This.Item(i) ) = t
					aItems + t
				ok
			next i
			aResult + [ t , aItems ]
		next
		return aResult

		def AllItemsAre_OfTheSameType()
			aTemp = oQuery.SelectWhere( :CurrentItem, :HasSameTypeAs, :FirstItem )
			if len(aTemp) = This.NumberOfItems()
				return TRUE
			else
				return FALSE
			ok

							def ContainsOnlyItems_OfTheSameType()	# IsPureList()
		def SomeItemsAre_OfTheSameType()	def ContainsSomeItems_OfTheSameType()
		def NoItemsAre_OfTheSameType()		def ContainsNoItems_OfTheSameType()
	def ExcludeItemsThatAre_OfTheSameType()

	def ItemsThatAre_Equal() 
		def AllItemsAre_Equal()			def ContainsOnly_ItemsThatAre_Equal()	
		def SomeItemsAree_Equal()		def ContainsSome_ItemsThatAre_Equal()
		def NoItemsAre_Equal()			def ContainsNo_ItemsThatAre_Equal()
	def ExcludeItemsThatAre_Equal()	

	def ItemsThatAre_EqualStrings() 
		def AllItemsAre_EqualStrings()		def ContainsOnly_ItemsThatAre_EqualStrings()	
		def SomeItemsAree_EqualStrings()	def ContainsSome_ItemsThatAre_EqualStrings()
		def NoItemsAre_EqualStrings()		def ContainsNo_ItemsThatAre_EqualStrings()
	def ExcludeItemsThatAre_EqualStrings()	

	def ItemsThatAre_EqualStzStrings() 
		def AllItemsAre_EqualStzStrings()	def ContainsOnly_ItemsThatAre_EqualstzStrings()	
		def SomeItemsAree_EqualStzStrings()	def ContainsSome_ItemsThatAre_EqualstzStrings()
		def NoItemsAre_EqualStzStrings()	def ContainsNo_ItemsThatAre_EqualstzStrings()
	def ExcludeItemsThatAre_EqualStzStrings()

	def ItemsThatAre_AlmostEqualStrings() 
		def AllItemsAre_AlmostEqualStrings()	def ContainsOnly_ItemsThatAre_AlmostEqualStrings()	
		def SomeItemsAree_AlmostEqualStrings()	def ContainsSome_ItemsThatAre_AlmostEqualStrings()
		def NoItemsAre_AlmostEqualStrings()	def ContainsNo_ItemsThatAre_AlmostEqualStrings()
	def ExcludeItemsThatAre_AlmostEqualStrings()

	def ItemsThatAre_AlmostEqualRingStrings() 
		def AllItemsAre_AlmostEqualRingStrings()	def ContainsOnly_ItemsThatAre_AlmostEqualRingStrings()	
		def SomeItemsAree_AlmostEqualRingStrings()	def ContainsSome_ItemsThatAre_AlmostEqualRingStrings()
		def NoItemsAre_AlmostEqualRingStrings()		def ContainsNo_ItemsThatAre_AlmostEqualRingStrings()
	def ExcludeItemsThatAre_AlmostEqualRingStrings()

	def ItemsThatAre_AlmostEqualStzStrings() 
		def AllItemsAre_AlmostEqualStzStrings()		def ContainsOnly_ItemsThatAre_AlmostEqualstzStrings()	
		def SomeItemsAree_AlmostEqualStzStrings()	def ContainsSome_ItemsThatAre_AlmostEqualstzStrings()
		def NoItemsAre_AlmostEqualStzStrings()		def ContainsNo_ItemsThatAre_AlmostEqualstzStrings()
	def ExcludeItemsThatAre_AlmostEqualStzStrings()

	def ItemsThatAre_EqualNumbers() 
		def AllItemsAre_EqualNumbers()		def ContainsOnly_ItemsThatAre_EqualNumbers()	
		def SomeItemsAree_EqualNumbers()	def ContainsSome_ItemsThatAre_EqualNumbers()
		def NoItemsAre_EqualNumbers()		def ContainsNo_ItemsThatAre_EqualNumbers()
	def ExcludeItemsThatAre_EqualNumbers()	

	def ItemsThatAre_EqualRingNumbers() 
		def AllItemsAre_EqualRingNumbers()	def ContainsOnly_ItemsThatAre_EqualRingNumbers()	
		def SomeItemsAree_EqualRingNumbers()	def ContainsSome_ItemsThatAre_EqualRingNumbers()
		def NoItemsAre_EqualRingNumbers()	def ContainsNo_ItemsThatAre_EqualRingNumbers()
	def ExcludeItemsThatAre_EqualRingNumbers()

	def ItemsThatAre_EqualStzNumbers() 
		def AllItemsAre_EqualstzNumbers()	def ContainsOnly_ItemsThatAre_EqualStzNumbers()	
		def SomeItemsAree_EqualStzNumbers()	def ContainsSome_ItemsThatAre_EqualStzNumbers()
		def NoItemsAre_EqualStzgNumbers()	def ContainsNo_ItemsThatAre_EqualStzNumbers()
	def ExcludeItemsThatAre_EqualStzNumbers()

	def ItemsThatAre_EqualLists()
		def AllItemsAre_EqualLists()	def ContainsOnly_ItemsThatAre_EqualLists()
		def SomeItemsAre_EqualLists()	def ContainsSome_ItemsThatAre_EqualLists()
		def NoItemsAre_EqualLists()	def ContainsNo_ItemsThatAre_EqualLists()
	def ExcludeItemsThatAre_EqualLists()

	def ItemsThatAre_EqualRingLists()
		def AllItemsAre_EqualRingLists()	def ContainsOnly_ItemsThatAre_EqualRingLists()
		def SomeItemsAre_EqualRingLists()	def ContainsSome_ItemsThatAre_EqualRingLists()
		def NoItemsAre_EqualRingLists()		def ContainsNo_ItemsThatAre_EqualRingLists()
	def ExcludeItemsThatAre_EqualRingLists()

	def ItemsThatAre_EqualStzLists()
		def AllItemsAre_EqualStzLists()		def ContainsOnly_ItemsThatAre_EqualStzLists()
		def SomeItemsAre_EqualStzLists()	def ContainsSome_ItemsThatAre_EqualStzLists()
		def NoItemsAre_EquaStzlLists()		def ContainsNo_ItemsThatAre_EqualStzLists()
	def ExcludeItemsThatAre_EqualStzLists()

	def ItemsThatAre_EqualObjects()
		def AllItemsAre_EqualObjects()	def ContainsOnly_ItemsThatAre_EqualObjects()
		def SomeItemsAre_EqualObjects()	def ContainsSome_ItemsThatAre_EqualObjects()
		def NoItemsAre_EqualObjects()	def ContainsNo_ItemsThatAre_EqualObjects()
	def ExcludeItemsThatAre_EqualObjects()

	def ItemsThatAre_EqualRingObjects()
		def AllItemsAre_EqualRingObjects()	def ContainsOnly_ItemsThatAre_EqualRingObjects()
		def SomeItemsAre_EqualRingObjects()	def ContainsSome_ItemsThatAre_EqualRingObjects()
		def NoItemsAre_EqualRingObjects()	def ContainsNo_ItemsThatAre_EqualRingObjects()
	def ExcludeItemsThatAre_EqualRingObjects()

	def ItemsThatAre_EqualStzObjects()
		def AllItemsAre_EqualStzObjects()	def ContainsOnly_ItemsThatAre_EqualStzObjects()
		def SomeItemsAre_EqualStzObjects()	def ContainsSome_ItemsThatAre_EqualStzObjects()
		def NoItemsAre_EqualStzObjects()	def ContainsNo_ItemsThatAre_EqualStzObjects()
	def ExcludeItemsThatAre_EqualStzObjects()

	def ItemsThatAre_NumbersIncluding_ThoseHostedInStrings()
		def AllItemsAre_NumbersIncluding_ThoseHostedInStrings()		def ContainsOnly_NumbersIncluding_ThoseHostedInStrings()
		def SomeItemsAre_NumbersIncluding_ThoseHostedInStrings()	def ContainsSome_NumbersIncluding_ThoseHostedInStrings()
		def NoItemsAre_NumbersIncluding_ThoseHostedInStrings()		def ContainsNo_NumbersIncluding_ThoseHostedInStrings()
	def ExcludeNumbersIncluding_ThoseHostedInStrings()

	def ItemsThatAre_NumbersIncluding_ThoseHostedInRingStrings()
		def AllItemsAre_NumbersIncluding_ThoseHostedInRingStrings()	def ContainsOnly_NumbersIncluding_ThoseHostedInRingStrings()
		def SomeItemsAre_NumbersIncluding_ThoseHostedInRingStrings()	def ContainsSome_NumbersIncluding_ThoseHostedInRingStrings()
		def NoItemsAre_NumbersIncluding_ThoseHostedInRingStrings()	def ContainsNo_NumbersIncluding_ThoseHostedInRingStrings()
	def ExcludeNumbersIncluding_ThoseHostedInRingStrings()

	def ItemsThatAre_NumbersIncluding_ThoseHostedInStzStrings()
		def AllItemsAre_NumbersIncluding_ThoseHostedInStzStrings()	def ContainsOnly_NumbersIncluding_ThoseHostedInStzStrings()
		def SomeItemsAre_NumbersIncluding_ThoseHostedInStzStrings()	def ContainsSome_NumbersIncluding_ThoseHostedInStzStrings()
		def NoItemsAre_NumbersIncluding_ThoseHostedInStzStrings()	def ContainsNo_NumbersIncluding_ThoseHostedInStzStrings()
	def ExcludeNumbersIncluding_ThoseHostedInStzStrings()

	  #------------------------------------------#
	 #     Related to items that are NUMBERS    #
	#------------------------------------------#

	// ItemsThatAre

	def ItemsThatAre_Numbers()
		def AllItemsAre_Numbers()		def ContainsOnly_Numbers()
		def SomeItemsAre_Numbers()		def ContainsSome_Numbers()
		def NoItemsAre_Numbers()		def ContainsNo_Numbers()
	def ExcludeItemsThatAre_Numbers()

	def ItemsThatAre_RingNumbers()
		def AllItemsAre_RingNumbers()		def ContainsOnly_RingNumbers()
		def SomeItemsAre_RingNumbers()		def ContainsSome_RingNumbers()
		def NoItemsAre_RingNumbers()		def ContainsNo_RingNumbers()
	def ExcludeItemsThatAre_RingNumbers()

	def ItemsThatAre_StzNumbers()
		def AllItemsAre_StzNumbers()		def ContainsOnly_StzNumbers()
		def SomeItemsAre_StzNumbers()		def ContainsSome_StzNumbers()
		def NoItemsAre_StzNumbers()		def ContainsNo_StzNumbers()
	def ExcludeItemsThatAre_StzNumbers()

	def ItemsThatAre_Numbers_MultipleOf(n)
		def AllItemsAre_Numbers_MultipleOf(n)	def ContainsOnly_Numbers_MultipleOf(n)
		def SomeItemsAre_Numbers_MultipleOf(n)	def ContainsSome_Numbers_MultipleOf(n)
		def NoItemsAre_Numbers_MultipleOf(n)	def ContainsNo_Numbers_MultipleOf(n)
	def ExcludeItemsThatAre_Numbers_MultipleOf(n)

	def ItemsThatAre_Numbers_DoubleOf(n)
		def AllItemsAre_Numbers_DoubleOf(n)	def ContainsOnly_Numbers_DoubleOf(n)
		def SomeItemsAre_Numbers_DoubleOf(n)	def ContainsSome_Numbers_DoubleOf(n)
		def NoItemsAre_Numbers_DoubleOf(n)	def ContainsNo_Numbers_DoubleOf(n)
	def ExcludeItemsThatAre_Numbers_DoubleOf(n)

	def ItemsThatAre_Numbers_TripleOf(n)
		def AllItemsAre_Numbers_TripleOf(n)	def ContainsOnly_Numbers_TripleOf(n)
		def SomeItemsAre_Numbers_TripleOf(n)	def ContainsSome_Numbers_TripleOf(n)
		def NoItemsAre_Numbers_TripleOf(n)	def ContainsNo_Numbers_TripleOf(n)
	def ExcludeItemsThatAre_Numbers_TripleOf(n)

	def ItemsThatAre_Numbers_QuadrupleOf(n)
		def AllItemsAre_Numbers_QuadrupleOf(n)	def ContainsOnly_Numbers_QuadrupleOf(n)
		def SomeItemsAre_Numbers_QuadrupleOf(n)	def ContainsSome_Numbers_QuadrupleOf(n)
		def NoItemsAre_Numbers_QuadrupleOf(n)	def ContainsNo_Numbers_QuadrupleOf(n)
	def ExcludeItemsThatAre_Numbers_QuadrupleOf(n)

	def ItemsThatAre_Numbers_QuintupleOf(n)
		def AllItemsAre_Numbers_QuintupleOf(n)	def ContainsOnly_Numbers_QuintupleOf(n)
		def SomeItemsAre_Numbers_QuintupleOf(n)	def ContainsSome_Numbers_QuintupleOf(n)
		def NoItemsAre_Numbers_QuintupleOf(n)	def ContainsNo_Numbers_QuintupleOf(n)
	def ExcludeItemsThatAre_Numbers_QuintupleOf(n)
	
	def ItemsThatAre_Numbers_SextupleOf(n)
		def AllItemsAre_Numbers_SextupleOf(n)	def ContainsOnly_Numbers_SextupleOf(n)
		def SomeItemsAre_Numbers_SextupleOf(n)	def ContainsSome_Numbers_SextupleOf(n)
		def NoItemsAre_Numbers_QuintupleOf(n)	def ContainsNo_Numbers_QuintupleOf(n)
	def ExcludeItemsThatAre_Numbers_QuintupleOf(n)

	def ItemsThatAre_Numbers_OctupleOf(n)
		def AllItemsAre_Numbers_OctupleOf(n)	def ContainsOnly_Numbers_OctupleOf(n)
		def SomeItemsAre_Numbers_OctupleOf(n)	def ContainsSome_Numbers_OctupleOf(n)
		def NoItemsAre_Numbers_OctupleOf(n)	def ContainsNo_Numbers_OctupleOf(n)
	def ExcludeItemsThatAre_Numbers_OctupleOf(n)

	def ItemsThatAre_Numbers_NonupleOf(n)
		def AllItemsAre_Numbers_NonupleOf(n)	def ContainsOnly_Numbers_NonupleOf(n)
		def SomeItemsAre_Numbers_NonupleOf(n)	def ContainsSome_Numbers_NonupleOf(n)
		def NoItemsAre_Numbers_NonupleOf(n)	def ContainsNo_Numbers_NonupleOf(n)
	def ExcludeItemsThatAre_Numbers_NonupleOf(n)

	def ItemsThatAre_Numbers_DecupleOf(n)
		def AllItemsAre_Numbers_DecupleOf(n)	def ContainsOnly_Numbers_DecupleOf(n)
		def SomeItemsAre_Numbers_DecupleOf(n)	def ContainsSome_Numbers_DecupleOf(n)
		def NoItemsAre_Numbers_DecupleOf(n)	def ContainsNo_Numbers_NonupleOf(n)
	def ExcludeItemsThatAre_Numbers_DecupleOf(n)

	def ItemsThatAre_NaturalNumbers()
		def AllItemsAre_NaturalNumbers()	def ContainsOnly_NaturalNumbers()
		def SomeItemsAre_NaturalNumbers()	def ContainsSome_NaturalNumbers()
		def NoItemsAre_NaturalNumbers(n)	def ContainsNo_NaturalNumbers(n)
	def ExcludeItemsThatAre_NaturalNumbers(n)

	def ItemsThatAre_Integers()
		def AllItemsAre_Integers()		def ContainsOnly_Integers()
		def SomeItems_Integers()		def ContainsSome_Integers()
		def NoItemsAre_Integers()		def ContainsNo_Integers()
	def ExcludeItemsThatAre_Integers()

	def ItemsThatAre_RealNumbers()
		def AllItemsAre_RealNumbers()		def ContainsOnly_RealNumbers()
		def SomeItems_RealNumbers()		def ContainsSome_RealNumbers()
		def NoItemsAre_RealNumbers()		def ContainsNo_RealNumbers()
	def ExcludeItemsThatAre_RealNumbers()

	def ItemsThatAre_BigNumbers()
		def AllItemsAre_BigNumbers()		def ContainsOnly_BigNumbers()
		def SomeItemsAre_BigNumbers()		def ContainsSome_BigNumbers()
		def NoItemsAre_BigNumbers()		def ContainsNo_BigNumbers()
	def ExcludeItemsThatAre_BigNumbers()

	def ItemsThatAre_OddNumbers()
		def AllItemsAre_OddNumbers()		def ContainsOnly_OddNumbers()
		def SomeItemsAre_OddNumbers()		def ContainsSome_OddNumbers()
		def NoItemsAre_OddNumbers()		def ContainsNo_OddNumbers()
	def ExcludeItemsThatAre_OddNumbers()

	def ItemsThatAre_EvenNumbers()
		def AllItemsAre_EvenNumbers()		def ContainsOnly_EvenNumbers()
		def SomeItemsAre_EvenNumbers()		def ContainsSome_EvenNumbers()
		def NoItemsAre_EvenNumbers()		def ContainsNo_EvenNumbers()
	def ExcludeItemsThatAre_EvenNumbers()

	def ItemsThatAre_PrimeNumbers()
		def AllItemsAre_PrimeNumbers()		def ContainsOnly_PrimeNumbers()
		def SomeItemsAre_PrimeNumbers()		def Containssome_PrimeNumbers()
		def NoItemsAre_PrimeNumbers()		def ContainsNo_PrimeNumbers()
	def ExcludeItemsThatAre_PrimeNumbers()

	def ItemsThatAre_Zeros()
		def AllItemsAre_Zeros()			def ContainsOnly_Zeros()
		def SomeItemsAre_Zeros()		def ContainsSome_Zeros()
		def NoItemsAre_Zeros()			def ContainsNo_Zeros()
	def ExcludeItemsThatAre_Zeros()

	def ItemsThatAre_PositiveNumbers()
		def AllItemsAre_PositiveNumbers()	def ContainsOnly_PositiveNumbers()
		def SomeItemsAre_PositiveNumbers()	def ContainsSome_PositiveNumbers()
		def NoItemsAre_PositiveNumbers()	def ContainsNo_PositiveNumbers()
	def ExcludeItemsThatAre_positiveNumbers()

	def ItemsThatAre_NegativeNumbers()
		def AllItemsAre_NegativeNumbers()	def ContainsOnly_NegativeNumbers()
		def SomeItemsAre_NegativeNumbers()	def ContainsSome_NegativeNumbers()
		def NoItemsAre_NegativeNumbers()	def ContainsNo_NegativeNumbers()
	def ExcludeItemsThatAre_NegativeNumbers()

	def ItemsThatAre_SignedNumbers()
		def AllItemsAre_SignedNumbers()		def ContainsOnly_SignedNumbers()
		def SomeItemsAre_SignedNumbers()	def ContainsSome_SignedNumbers()
		def NoItemsAre_SignedNumbers()		def ContainsNo_SignedNumbers()
	def ExcludeItemsThatAre_SignedNumbers()

	def ItemsThatAre_UnsignedNumbers()
		def AllItemsAre_UnsignedNumbers()	def ContainsOnly_UnsignedNumbers()
		def SomeItemsAre_UnsignedNumbers()	def ContainsSome_UnsignedNumbers()
		def NoItemsAre_UnsignedNumbers()	def ContainsNo_UnsignedNumbers()
	def ExcludeItemsThatAre_UnsignedNumbers()

	def ItemsThatAre_Numbers_EqualTo(pcOtherNumber)
		def AllItemsAre_Numbers_EqualTo(pcOtherNumber)		def ContainsOnly_Numbers_EqualTo(pcOtherNumber)
		def SomeItemsAre_Numbers_EqualTo(pcOtherNumber)		def ContainsSome_Numbers_EqualTo(pcOtherNumber)
		def NoItemsAre_Numbers_EqualTo(pcOtherNumber)		def ContainsNo_Numbers_EqualTo(pcOtherNumber)
	def ExcludeItemsThatAre_Numbers_EqualTo(pcOtherNumber)

	def ItemsThatAre_Numbers_DifferentFrom(pcOtherNumber)
		def AllItemsAre_Numbers_DifferentFrom(pcOtherNumber)	def ContainsOnly_Numbers_DifferentFrom(pcOtherNumber)
		def SomeItemsAre_Numbers_DifferentFrom(pcOtherNumber)	def ContainsSome_Numbers_DifferentFrom(pcOtherNumber)
		def NoItemsAre_Numbers_DifferentFrom(pcOtherNumber)	def ContainsNo_Numbers_DifferentFrom(pcOtherNumber)
	def ExcludeItemsThatAre_Numbers_DifferentFrom(pcOtherNumber)

	def ItemsThatAre_Numbers_StriclyLessThan(pcOtherNumber)
		def AllItemsAre_Numbers_StriclyLessThan(pcOtherNumber)	def ContainsOnly_Numbers_StriclyLessThan(pcOtherNumber)
		def SomeItemsAre_Numbers_StriclyLessThan(pcOtherNumber)	def ContainsSome_Numbers_StriclyLessThan(pcOtherNumber)
		def NoItemsAre_Numbers_StriclyLessThan(pcOtherNumber)	def ContainsNo_SNumbers_StriclyLessThan(pcOtherNumber)
	def ExcludeItemsThatAre_Numbers_StriclyLessThan(pcOtherNumber)

	def ItemsThatAre_Numbers_LessThan(pcOtherNumber)
		def AllItemsAre_Numbers_LessThan(pcOtherNumber)		def ContainsOnly_Numbers_LessThan(pcOtherNumber)
		def SomeItemsAre_Numbers_LessThan(pcOtherNumber)	def ContainsSome_Numbers_LessThan(pcOtherNumber)
		def NoItemsAre_Numbers_LessThan(pcOtherNumber)		def ContainsNo_Numbers_StriclyLessThan(pcOtherNumber)
	def ExcludeItemsThatAre_Numbers_LessThan(pcOtherNumber)

	def ItemsThatAre_Numbers_LessThanOrEqualTo(pcOtherNumber)
		def AllItemsAre_Numbers_LessThanOrEqualTo(pcOtherNumber)	def ContainsOnly_Numbers_LessThanOrEqualTo(pcOtherNumber)
		def SomeItemsAre_Numbers_LessThanOrEqualTo(pcOtherNumber)	def ContainsSome_Numbers_LessThanOrEqualTo(pcOtherNumber)
		def NoItemsAre_Numbers_LessThanOrEqualTo(pcOtherNumber)		def ContainsNo_Numbers_StriclyLessOrEqualTo(pcOtherNumber)
	def ExcludeItemsThatAre_Numbers_LessThanOrEqualTo(pcOtherNumber)

	def ItemsThatAre_Numbers_StriclyGreaterThan(pcOtherNumber)
		def AllItemsAre_Numbers_StriclyGreaterThan(pcOtherNumber)	def ContainsOnly_Numbers_StriclyGreaterThan(pcOtherNumber)
		def SomeItemsAre_Numbers_StriclyGreaterThan(pcOtherNumber)	def ContainsSome_Numbers_StriclyGreaterThan(pcOtherNumber)
		def NoItemsAre_Numbers_StriclyGreaterThan(pcOtherNumber)	def ContainsNo_Numbers_StriclyGreaterThan(pcOtherNumber)
	def ExcludeItemsThatAre_Numbers_StriclyGreaterThan(pcOtherNumber)

	def ItemsThatAre_Numbers_GreaterThan(pcOtherNumber)
		def AllItemsAre_Numbers_GreaterThan(pcOtherNumber)		def ContainsOnly_Numbers_GreaterThan(pcOtherNumber)
		def SomeItemsAre_Numbers_GreaterThan(pcOtherNumber)		def ContainsSome_Numbers_GreaterThan(pcOtherNumber)
		def NoItemsAre_Numbers_GreaterThan(pcOtherNumber)		def ContainsNo_Numbers_GreaterThan(pcOtherNumber)
	def ExcludeItemsThatAre_Numbers_GreaterThan(pcOtherNumber)

	def ItemsThatAre_Numbers_GreaterThanOrEqualTo(pcOtherNumber)
		def AllItemsAre_Numbers_GreaterThanOrEqualTo(pcOtherNumber)	def ContainsOnly_Numbers_GreaterThanOrEqualTo(pcOtherNumber)
		def SomeItemsAre_Numbers_GreaterThanOrEqualTo(pcOtherNumber)	def ContainsSome_Numbers_GreaterThanOrEqualTo(pcOtherNumber)
		def NoItemsAre_Numbers_GreaterThanOrEqualTo(pcOtherNumber)	def ContainsNo_Numbers_GreaterThanOrEqualTo(pcOtherNumber)
	def ExcludeItemsThatAre_Numbers_GreaterThanOrEqualTo(pcOtherNumber)

	def ItemsThatAre_Numbers_FactorsOf(n)
		def AllItemsAre_Numbers_FactorsOf(n)	def ContainsOnly_Numbers_FactorsOf(n)
		def SomeItemsAre_Numbers_FactorsOf(n)	def ContainsSome_Numbers_FactorsOf(n)
		def NoItemsAre_Numbers_FactorsOf(n)	def ContainsNo_Numbers_FactorsOf(n)
	def ExcludeItemsThatAre_Numbers_FactorsOf(n)

	// ItemsHaving

	def ItemsThatAre_NumbersHaving_RoundLessThan_RoundOf(pcOtherNumber)
		def AllItemsAre_NumbersHaving_RoundLessThan_RoundOf(pcOtherNumber)	def ContainsOnly_NumbersHaving_RoundLessThan_RoundOf(pcOtherNumber)
		def SomeItemsAre_NumbersHaving_RoundLessThan_RoundOf(pcOtherNumber)	def ContainsSome_NumbersHaving_RoundLessThan_RoundOf(pcOtherNumber)
		def NoItemsAre_NumbersHaving_RoundLessThan_RoundOf(pcOtherNumber)	def ContainsNo_NumbersHaving_RoundLessThan_RoundOf(pcOtherNumber)
	def ExcludeItemsThatAre_NumbersHaving_RoundLessThan_RoundOf(pcOtherNumber)

	def ItemsThatAre_NumbersHaving_RoundGreaterThan_RoundOf(pcOtherNumber)
		def AllItemsAre_NumbersHaving_RoundGreaterThan_RoundOf(pcOtherNumber)	def ContainsOnly_NumbersHaving_RoundGreaterThan_RoundOf(pcOtherNumber)
		def SomeItemsAre_NumbersHaving_RoundGreaterThan_RoundOf(pcOtherNumber)	def ContainsSome_NumbersHaving_RoundGreaterThan_RoundOf(pcOtherNumber)
		def NoItemsAre_NumbersHaving_RoundGreaterThan_RoundOf(pcOtherNumber)	def ContainsNo_NumbersHaving_RoundGreaterThan_RoundOf(pcOtherNumber)
	def ExcludeItemsThatAre_NumbersHaving_RoundGreaterThan_RoundOf(pcOtherNumber)

	def ItemsThatAre_NumbersHaving_RoundEqualTo_RoundOf(pcOtherNumber)
		def AllItemsAre_NumbersHaving_RoundEqualTo_RoundOf(pcOtherNumber)	def ContainsOnly_NumbersHaving_RoundEqualTo_RoundOf(pcOtherNumber)
		def SomeItemsAre_NumbersHaving_RoundEqualTo_RoundOf(pcOtherNumber)	def ContainsSome_NumbersHaving_RoundEqualTo_RoundOf(pcOtherNumber)
		def NoItemsAre_NumbersHaving_RoundEqualTo_RoundOf(pcOtherNumber)		def ContainsNo_NumbersHaving_RoundEqualTo_RoundOf(pcOtherNumber)
	def ExcludeItemsThatAre_NumbersHaving_RoundEqualTo_RoundOf(pcOtherNumber)

	def ItemsThatAre_NumbersHaving_SameRoundAs(pcOtherNumber)
		def AllItemsAre_NumbersHaving_SameRoundAs(pcOtherNumber)	def ContainsOnly_NumbersHaving_SameRoundAs(pcOtherNumber)
		def SomeItemsAre_NumbersHaving_SameRoundAs(pcOtherNumber)	def ContainsSome_NumbersHaving_SameRoundAs(pcOtherNumber)
		def NoItemsAre_NumbersHaving_SameRoundAs(pcOtherNumber)		def ContainsNo_NumbersHaving_SameRoundAs(pcOtherNumber)
	def ExcludeItemsThatAre_NumbersHaving_SameRoundAs(pcOtherNumber)

	def ItemsThatAre_NumbersHaving_Hundreds()
		def AllItemsAre_NumbersHaving_Hundreds()	def ContainsOnly_NumbersHaving_Hundreds()
		def SomeItemsAre_NumbersHaving_Hundreds()	def ContainsSome_NumbersHaving_Hundreds()
		def NoItemsAre_NumbersHaving_Hundreds()		def ContainsNo_NumbersHaving_Hundreds()
	def ExcludeItemsThatAre_NumbersHaving_Hundreds()

	def ItemsThatAre_NumbersHaving_Thousands()
		def AllItemsAre_NumbersHaving_Thousands()	def ContainsOnly_NumbersHaving_Thousands()
		def SomeItemsAre_NumbersHaving_Thousands()	def ContainsSome_NumbersHaving_Thousands()
		def NoItemsAre_NumbersHaving_Thousands()	def ContainsNo_NumbersHaving_Thousands()
	def ExcludeItemsThatAre_NumbersHaving_Thousands()

	def ItemsThatAre_NumbersHaving_Millions()
		def AllItemsAre_NumbersHaving_Millions()	def ContainsOnly_NumbersHaving_Millions()
		def SomeItemsAre_NumbersHaving_Millions()	def ContainsSome_NumbersHaving_Millions()
		def NoItemsAre_NumbersHaving_Millions()		def ContainsNo_NumbersHaving_Millions()
	def ExcludeItemsThatAre_NumbersHaving_Millions()

	def ItemsThatAre_NumbersHaving_Billions()
		def AllItemsAre_NumbersHaving_Billions()	def ContainsOnly_NumbersHaving_Billions()
		def SomeItemsAre_NumbersHaving_Billions()	def ContainsSome_NumbersHaving_Billions()
		def NoItemsAre_NumbersHaving_Billions()		def ContainsNo_NumbersHaving_Billions()
	def ExcludeItemsThatAre_NumbersHaving_Billions()

	def ItemsThatAre_NumbersHaving_Trillions()
		def AllItemsAre_NumbersHaving_Trillions()	def ContainsOnly_NumbersHaving_Trillions()
		def SomeItemsAre_NumbersHavinge_Trillions()	def ContainsSome_NumbersHaving_Trillions()
		def NoItemsAre_NumbersHaving_Trillions()	def ContainsNo_NumbersHaving_Trillions()
	def ExcludeItemsThatAre_NumbersHaving_Trillions()

	// ItemsHaveSame, ItemsIncludeNumbersHaving...

	def ItemsThatAre_NumbersHaving_SameSign()
		def AllItemsAre_NumbersHaving_SameSign()	def ContainsOnly_NumbersHaving_SameSign()
		def SomeItemsAre_NumbersHaving_SameSign()	def ContainsSome_NumbersHaving_SameSign()
		def NoItemsAre_NumbersHaving_SameSign()		def ContainsNo_NumbersHaving_SameSign()
	def ExcludeItemsThatAre_NumbersHaving_SameSign()

	def ItemsThatAre_NumbersHaving_SameNumberOfDigits()
		def AllItemsAre_NumbersHaving_SameNumberOfDigits()	def ContainsOnly_NumbersHaving_SameNumberOfDigits()
		def SomeItemsAre_NumbersHaving_SameNumberOfDigits()	def ContainsSome_NumbersHaving_SameNumberOfDigits()
		def NoItemsAre_NumbersHaving_SameNumberOfDigits()	def ContainsNo_NumbersHaving_SameNumberOfDigits()
	def ExcludeItemsThatAre_NumbersHaving_SameNumberOfDigits()

	def ItemsThatAre_NumbersHaving_SameIntegerPart()
		def AllItemsAre_NumbersHaving_SameIntegerPart()		def ContainsOnly_NumbersHaving_SameIntegerPart()
		def SomeItemsAre_NumbersHaving_SameIntegerPart()	def ContainsSome_NumbersHaving_SameIntegerPart()
		def NoItemsAre_NumbersHaving_SameIntegerPart()		def ContainsNo_NumbersHaving_SameIntegerPart()
	def ExcludeItemsThatAre_NumbersHaving_SameIntegerPart()

	def ItemsThatAre_NumbersHaving_SameNumberOfIntegers()
		def AllItemsAre_NumbersHaving_SameNumberOfIntegers()	def ContainsOnly_NumbersHaving_SameNumberOfIntegers()
		def SomeItemsAre_NumbersHaving_SameNumberOfIntegers()	def ContainsSome_NumbersHaving_SameNumberOfIntegers()
		def NoItemsAre_NumbersHaving_SameNumberOfIntegers()	def ContainsNo_NumbersHaving_SameNumberOfIntegers()
	def ExcludeItemsThatAre_NumbersHaving_SameNumberOfIntegers()

	def ItemsThatAre_NumbersHaving_SameFractionalPart()
		def AllItemsAre_NumbersHaving_SameFractionalPart()	def ContainsOnly_NumbersHaving_SameFractionalPart()
		def SomeItemsAre_NumbersHaving_SameFractionalPart()	def ContainsSome_NumbersHaving_SameFractionalPart()
		def NoItemsAre_NumbersHaving_SameFractionalPart()	def ContainsNo_NumbersHaving_SameFractionalPart()
	def ExcludeItemsThatAre_NumbersHaving_SameFractionalPart()

	def ItemsThatAre_NumbersHaving_SameNumberOfFractions_InFractionalPart()
		def AllItemsAre_NumbersHaving_SameNumberOfFractions_InFractionalPart()	def ContainsOnly_NumbersHaving_SameNumberOfFractions_InFractionalPart()
		def SomeItemsAre_NumbersHaving_SameNumberOfFractions_InFractionalPart()	def ContainsSome_NumbersHaving_SameNumberOfFractions_InFractionalPart()
		def NoItemsAre_NumbersHaving_SameNumberOfFractions_InFractionalPart()	def ContainsNo_NumbersHaving_SameNumberOfFractions_InFractionalPart()
	def ExcludeItemsThatAre_NumbersHaving_SameNumberOfFractions_InFractionalPart()

	def ItemsThatAre_NumbersHaving_SameMaxNumberOfIntegers_InIntegerPart()
		def AllItemsAre_NumbersHaving_SameMaxNumberOfIntegers_InIntegerPart()	def ContainsOnly_NumbersHaving_SameMaxNumberOfDigits()
		def SomeItemsAre_NumbersHaving_SameMaxNumberOfIntegers_InIntegerPart()	def ContainsSome_NumbersHaving_SameMaxNumberOfDigits()
		def NoItemsAre_NumbersHaving_SameMaxNumberOfIntegers_InIntegerPart()	def ContainsNo_NumbersHaving_SameMaxNumberOfDigits()
	def ExcludeItemsThatAre_NumbersHaving_SameMaxNumberOfIntegers_InIntegerPart()

	def ItemsThatAre_NumbersHaving_SameRound()
		def AllItemsAre_NumbersHaving_SameRound()	def ContainsOnly_NumbersHaving_SameRound()
		def SomeItemsAre_NumbersHaving_SameRound()	def ContainsSome_NumbersHaving_SameRound()
		def NoItemsAre_NumbersHaving_SameRound()	def ContainsNo_NumbersHaving_SameRound()
	def ExcludeItemsThatAre_NumbersHaving_SameRound()

	def ItemsThatAre_NumbersHaving_SameSigmoid()
		def AllItemsAre_NumbersHaving_SameSigmoid()	def ContainsOnly_NumbersHaving_SameSigmoid()
		def SomeItemsAre_NumbersHaving_SameSigmoid()	def ContainsSome_NumbersHaving_SameSigmoid()
		def NoItemsAre_NumbersHaving_SameSigmoid()	def ContainsNo_NumbersHaving_SameSigmoid()
	def ExcludeItemsThatAre_NumbersHaving_SameSigmoid()

	def ItemsThatAre_NumbersHaving_SameDerivativeOf(pcFunc)
		def AllItemsAre_NumbersHaving_SameDerivativeOf(pcFunc)	def ContainsOnly_NumbersHaving_SameDerivativeOf(pcFunc)
		def SomeItemsAre_NumbersHaving_SameDerivativeOf(pcFunc)	def ContainsSome_NumbersHaving_SameDerivativeOf(pcFunc)
		def NoItemsAre_NumbersHaving_SameDerivativeOf(pcFunc)	def ContainsNo_NumbersHaving_SameDerivativeOf(pcFunc)
	def ExcludeItemsThatAre_NumbersHaving_SameDerivativeOf(pcFunc)

	def ItemsThatAre_NumbersHaving_SameDerivativeSigmoid()
		def AllItemsAre_NumbersHaving_SameDerivativeSigmoid()	def ContainsOnly_NumbersHaving_SameDerivativeSigmoid()
		def SomeItemsAre_NumbersHaving_SameDerivativeSigmoid()	def ContainsSome_NumbersHaving_SameDerivativeSigmoid()
		def NoItemsAre_NumbersHaving_SameDerivativeSigmoid()	def ContainsNo_NumbersHaving_SameDerivativeSigmoid()
	def ExcludeItemsThatAre_NumbersHaving_SameDerivativeSigmoid()

	def ItemsThatAre_NumbersHaving_SameLeastCommonMultipleWith(n)
		def AllItemsAre_NumbersHaving_SameLeastCommonMultipleWith(n)	def ContainsOnly_NumbersHaving_SameLeastCommonMultipleWith(n)
		def SomeItemsAre_NumbersHaving_SameLeastCommonMultipleWith(n)	def ContainsSome_NumbersHaving_SameLeastCommonMultipleWith(n)
		def NoItemsAre_NumbersHaving_SameLeastCommonMultipleWith(n)	def ContainsNo_NumbersHaving_SameLeastCommonMultipleWith(n)
	def ExcludeItemsThatAre_NumbersHaving_SameLeastCommonMultipleWith(n)

	def ItemsThatAre_NumbersHaving_SameGreatestCommonDividorWith(n)
		def AllItemsAre_NumbersHaving_SameGreatestCommonDividorWith(n)	def ContainsOnly_NumbersHaving_SameGreatestCommonDividorWith(n)
		def SomeItemsAre_NumbersHaving_SameGreatestCommonDividorWith(n)	def ContainsSome_NumbersHaving_SameGreatestCommonDividorWith(n)
		def NoItemsAre_NumbersHaving_SameGreatestCommonDividorWith(n)	def ContainsNo_NumbersHaving_SameGreatestCommonDividorWith(n)
	def ExcludeItemsThatAre_NumbersHaving_SameGreatestCommonDividorWith(n)

	def ItemsThatAre_NumbersHaving_SameHundreds()
		def AllItemsAre_NumbersHaving_SameHundreds()	def ContainsOnly_NumbersHaving_SameHundreds()
		def SomeItemsAre_NumbersHaving_SameHundreds()	def ContainsSome_NumbersHaving_SameHundreds()
		def NoItemsAre_NumbersHaving_SameHundreds()	def ContainsNo_NumbersHaving_SameHundreds()
	def ExcludeItemsThatAre_NumbersHaving_SameHundreds()

	def ItemsThatAre_NumbersHaving_SameUnitsInHundreds()
		def AllItemsAre_NumbersHaving_SameUnitsInHundreds()	def ContainsOnly_NumbersHaving_SameUnitsInHundreds()
		def SomeItemsAre_NumbersHaving_SameUnitsInHundreds()	def ContainsSome_NumbersHaving_SameUnitsInHundreds()
		def NoItemsAre_NumbersHaving_SameUnitsInHundreds()	def ContainsNo_NumbersHaving_SameUnitsInHundreds()
	def ExcludeItemsThatAre_NumbersHaving_SameUnitsInHundreds()

	def ItemsThatAre_NumbersHaving_SameDozensInHundreds()
		def AllItemsAre_NumbersHaving_SameDozensInHundreds()	def ContainsOnly_NumbersHaving_SameDozensInHundreds()
		def SomeItemsAre_NumbersHaving_SameDozenssInHundreds()	def ContainsSome_NumbersHaving_SameDozensInHundreds()
		def NoItemsAre_NumbersHaving_SameDozensInHundreds()	def ContainsNo_NumbersHaving_SameDozensInHundreds()
	def ExcludeItemsThatAre_NumbersHaving_SameDozensInHundreds()

	def ItemsThatAre_NumbersHaving_SameHundredsInHundreds()
		def AllItemsAre_NumbersHaving_SameHundredsInHundreds()	def ContainsOnly_NumbersHaving_SameHundredsInHundreds()
		def SomeItemsAre_NumbersHaving_SameHundredsInHundreds()	def ContainsSome_NumbersHaving_SameHundredsInHundreds()
		def NoItemsAre_NumbersHaving_SameHundredsInHundreds()	def ContainsNo_NumbersHaving_SameHundredsInHundreds()
	def ExcludeItemsThatAre_NumbersHaving_SameHundredsInHundreds()

	def ItemsThatAre_NumbersHaving_SameThousands()
		def AllItemsAre_NumbersHaving_SameThousands()	def ContainsOnly_NumbersHaving_SameThousands()
		def SomeItemsAre_NumbersHaving_SameThousands()	def ContainsSome_NumbersHaving_SameThousands()
		def NoItemsAre_NumbersHaving_SameThousands()	def ContainsNo_NumbersHaving_SameThousands()
	def ExcludeItemsThatAre_NumbersHaving_SameThousands()

	def ItemsThatAre_NumbersHaving_SameUnitsInThousands()
		def AllItemsAre_NumbersHaving_SameUnitsInThousands()	def ContainsOnly_NumbersHaving_SameUnitsInThousands()
		def SomeItemsAre_NumbersHaving_SameUnitsInThousands()	def ContainsSome_NumbersHaving_SameUnitsInThousands()
		def NoItemsAre_NumbersHaving_SameUnitsInThousands()	def ContainsNo_NumbersHaving_SameUnitsInThousands()
	def ExcludeItemsThatAre_NumbersHaving_SameUnitsInThousands()

	def ItemsThatAre_NumbersHaving_SameDozensInThousands()
		def AllItemsAre_NumbersHaving_SameDozensInThousands()	def ContainsOnly_NumbersHaving_SameDozensInThousands()
		def SomeItemsAre_NumbersHaving_SameDozenssInThousands()	def ContainsSome_NumbersHaving_SameDozensInThousands()
		def NoItemsAre_NumbersHaving_SameDozensInThousands()	def ContainsNo_NumbersHaving_SameDozensInThousands()
	def ExcludeItemsThatAre_NumbersHaving_SameDozensInThousands()

	def ItemsThatAre_NumbersHaving_SameHundredsInThousands()
		def AllItemsAre_NumbersHaving_SameHundredsInThousands()		def ContainsOnly_NumbersHaving_SameHundredsInThousands()
		def SomeItemsAre_NumbersHaving_SameHundredsInThousands()	def ContainsSome_NumbersHaving_SameHundredsInThousands()
		def NoItemsAre_NumbersHaving_SameHundredsInThousands()		def ContainsNo_NumbersHaving_SameHundredsInThousands()
	def ExcludeItemsThatAre_NumbersHaving_SameHundredsInThousands()

	def ItemsThatAre_NumbersHaving_SameMillions()
		def AllItemsAre_NumbersHaving_SameMillions()	def ContainsOnly_NumbersHaving_SameMillions()
		def SomeItemsAre_NumbersHaving_SameMillions()	def ContainsSome_NumbersHaving_SameMillions()
		def NoItemsAre_NumbersHaving_SameMillions()	def ContainsNo_NumbersHaving_SameMillions()
	def ExcludeItemsThatAre_NumbersHaving_SameMillions()

	def ItemsThatAre_NumbersHaving_SameUnitsInMillions()
		def AllItemsAre_NumbersHaving_SameUnitsInMillions()	def ContainsOnly_NumbersHaving_SameUnitsInMillions()
		def SomeItemsAre_NumbersHaving_SameUnitsInMillions()	def ContainsSome_NumbersHaving_SameUnitsInMillions()
		def NoItemsAre_NumbersHaving_SameUnitsInMillions()	def ContainsNo_NumbersHaving_SameUnitsInMillions()
	def ExcludeItemsThatAre_NumbersHaving_SameUnitsInMillions()

	def ItemsThatAre_NumbersHaving_SameDozensInMillions()
		def AllItemsAre_NumbersHaving_SameDozensInMillions()	def ContainsOnly_NumbersHaving_SameDozensInMillions()
		def SomeItemsAre_NumbersHaving_SameDozenssInMillions()	def ContainsSome_NumbersHaving_SameDozensInMillions()
		def NoItemsAre_NumbersHaving_SameDozensInMillions()	def ContainsNo_NumbersHaving_SameDozensInMillions()
	def ExcludeItemsThatAre_NumbersHaving_SameDozensInMillions()

	def ItemsThatAre_NumbersHaving_SameHundredsInMillions()
		def AllItemsAre_NumbersHaving_SameHundredsInMillions()	def ContainsOnly_NumbersHaving_SameHundredsInMillionss()
		def SomeItemsAre_NumbersHaving_SameHundredsInMillions()	def ContainsSome_NumbersHaving_SameHundredsInMillions()
		def NoItemsAre_NumbersHaving_SameHundredsInMillions()	def ContainsNo_NumbersHaving_SameHundredsInMillions()
	def ExcludeItemsThatAre_NumbersHaving_SameHundredsInMillions()

	def ItemsThatAre_NumbersHaving_SameBillions()
		def AllItemsAre_NumbersHaving_SameBillions()	def ContainsOnly_NumbersHaving_SameBillions()
		def SomeItemsAre_NumbersHaving_SameBillions()	def ContainsSome_NumbersHaving_SameBillions()
		def NoItemsAre_NumbersHaving_SameBillions()	def ContainsNo_NumbersHaving_SameBillions()
	def ExcludeItemsThatAre_NumbersHaving_SameBillions()

	def ItemsThatAre_NumbersHaving_ameUnitsInBillions()
		def AllItemsAre_NumbersHaving_SameUnitsInBillions()	def ContainsOnly_NumbersHaving_SameUnitsInBillions()
		def SomeItemsAre_NumbersHaving_SameUnitsInBillions()	def ContainsSome_NumbersHaving_SameUnitsInBillions()
		def NoItemsAre_NumbersHaving_SameUnitsInBillions()	def ContainsNo_NumbersHaving_SameUnitsInBillions()
	def ExcludeItemsThatAre_NumbersHaving_SameUnitsInBillions()

	def ItemsThatAre_NumbersHaving_SameDozensInBillions()
		def AllItemsAre_NumbersHaving_SameDozensInBillions()		def ContainsOnly_NumbersHaving_SameDozensInBillions()
		def SomeItemsAre_NumbersHaving_SameDozenssInBMillions()	def ContainsSome_NumbersHaving_SameDozensInBillions()
		def NoItemsAre_NumbersHaving_SameDozensInBillions()	def ContainsNo_NumbersHaving_SameDozensInBillions()
	def ExcludeItemsThatAre_NumbersHaving_SameDozensInBillions()

	def ItemsThatAre_NumbersHaving_SameHundredsInBillions()
		def AllItemsAre_NumbersHaving_SameHundredsInBillions()	def ContainsOnly_NumbersHaving_SameHundredsInBillionss()
		def SomeItemsAre_NumbersHaving_SameHundredsInBillions()	def ContainsSome_NumbersHaving_SameHundredsInBillions()
		def NoItemsAre_NumbersHaving_SameHundredsInBillions()	def ContainsNo_NumbersHaving_SameHundredsInBillions()
	def ExcludeItemsThatAre_NumbersHaving_SameHundredsInBillions()

	def ItemsThatAre_NumbersHaving_SameTillions()
		def AllItemsAre_NumbersHaving_SameTillions()	def ContainsOnly_NumbersHaving_SameTillions()
		def SomeItemsAre_NumbersHaving_SameTillions()	def ContainsSome_NumbersHaving_SameTillions()	
		def NoItemsAre_NumbersHaving_SameTillions()	def ContainsNo_NumbersHaving_SameTillions()
	def ExcludeItemsThatAre_NumbersHaving_SameTillions()

	def ItemsThatAre_NumbersHaving_SameUnitsInTrillions()
		def AllItemsAre_NumbersHaving_SameUnitsInTrillions()	def ContainsOnly_NumbersHaving_SameUnitsInTrillions()
		def SomeItemsAre_NumbersHaving_SameUnitsInTrillions()	def ContainsSome_NumbersHaving_SameUnitsInTrillions()
		def NoItemsAre_NumbersHaving_SameUnitsInTrillions()	def ContainsNo_NumbersHaving_SameUnitsInTrillions()
	def ExcludeItemsThatAre_NumbersHaving_SameUnitsInTrillions()

	def ItemsThatAre_NumbersHaving_SameDozensInInTrillions()
		def AllItemsAre_NumbersHaving_SameDozensInTrillions()	def ContainsOnly_NumbersHaving_SameDozensInTrillions()
		def SomeItemsAre_NumbersHaving_SameDozenssInTrillions()	def ContainsSome_NumbersHaving_SameDozensInTrillions()
		def NoItemsAre_NumbersHaving_SameDozensInInTrillions()	def ContainsNo_NumbersHaving_SameDozensInInTrillions()
	def ExcludeItemsThatAre_NumbersHaving_SameDozensInInTrillions()

	def ItemsThatAre_NumbersHaving_SameHundredsInTrillions()
		def AllItemsAre_NumbersHaving_SameHundredsInTrillions()		def ContainsOnly_NumbersHaving_SameHundredsInTrillions())
		def SomeItemsAre_NumbersHaving_SameHundredsInTrillions()	def ContainsSome_NumbersHaving_SameHundredsInTrillions()
		def NoItemsAre_NumbersHaving_SameHundredsInTrillions()		def ContainsNo_NumbersHaving_SameHundredsInTrillions()
	def ExcludeItemsThatAre_NumbersHaving_SameHundredsInTrillions()

	  #------------------------------------------#
	 #     Related to items that are STRINGS    #
	#------------------------------------------#

	// ItemsAre_Strings

	def ItemsThatAre_Strings()
		def AllItemsAre_Strings()	def ContainsOnly_Strings()
		def SomeItemsAre_Strings()	def ContainsSome_Strings()
		def NoItemsAre_Strings()	def ContainsNo_Strings()
	def ExcludeItemsThatAre_Strings()

	def ItemsThatAre_RingStrings()
		def AllItemsAre_RingStrings()	def ContainsOnly_RingStrings()
		def SomeItemsAre_RingStrings()	def ContainsSome_RingStrings()
		def NoItemsAre_RingStrings()	def ContainsNo_RingStrings()
	def ExcludeItemsThatAre_RingStrings()

	def ItemsThatAre_StzStrings()
		def AllItemsAre_StzStrings()	def ContainsOnly_StzStrings()
		def SomeItemsAre_StzStrings()	def ContainsSome_stzStrings()
		def NoItemsAre_StzStrings()	def ContainsNo_StzStrings()
	def ExcludeItemsThatAre_StzStrings()

	def ItemsThatAre_StringsHosting_Numbers()
		def AllItemsAre_StringsHosting_Numbers()	def ContainsOnly_StringsHosting_Numbers()
		def SomeItemsAre_StringsHosting_Numbers()	def ContainsSome_StringsHosting_Numbers()
		def NoItemsAre_StringsHosting_Numbers()		def ContainsNo_StringsHostings_Numbers()
	def ExcludeItemsThatAre_StringsHosting_Numbers()

	def ItemsThatAre_StringsHosting_BinaryData()
		def AllItemsAre_StringsHosting_BinaryData()	def ContainsOnly_StringsHosting_BinaryData()
		def SomeItemsAre_StringsHosting_BinaryData()	def ContainsSome_StringsHosting_BinaryData()
		def NoItemsAre_StringsHosting_BinaryDate()	def ContainsNo_StringsHosting_BinaryData()
	def ExcludeItemsThatAre_StringsHosting_BinaryData()	

	def ItemsThatAre_StringsHaving_HybridOrientation()
		def AllItemsAre_StringsHaving_HybridOrientation()	def ContainsOnly_StringsHaving_HybridOrientation()
		def SomeItemsAre_StringsHaving_HybridOrientation()	def ContainsSome_StringsHaving_HybridOrientation()
		def NoItemsAre_StringsHaving_HybridOrientation()	def ContainsNo_StringsHaving_HybridOrientation()
	def ExcludeItemsThatAre_StringsHaving_HybridOrientation()	

	def ItemsThatAre_StringsHaving_SameNumberOfLettersletters()
		def AllItemsAre_StringsHaving_SameNumberOfLetters()	def ContainsOnly_StringsHaving_SameNumberOfLetters()
		def SomeItemsAre_StringsHaving_SameNumberOfLetters()	def ContainsSome_StringsHaving_SameNumberOfLetters()
		def NoItemsAre_StringsHaving_SameNumberOfLetters()	def ContainsNo_StringsHaving_SameNumberOfLetters()
	def ExcludeItemsThatAre_StringsHaving_SameNumberOfLetters()
	
	def ItemsThatAre_StringsHaving_SameNumberOfChars()
		def AllItemsAre_StringsHaving_SameNumberOfChars()	def ContainsOnly_StringsHaving_SameNumberOfChars()
		def SomeItemsAre_StringsHaving_SameNumberOfChars()	def ContainsSome_StringsHaving_SameNumberOfChars()
		def NoItemsAre_StringsHaving_SameNumberOfChars()	def ContainsNo_StringsHaving_SameNumberOfChars()
	def ExcludeItemsThatAre_StringsHaving_SameNumberOfChars()

	def ItemsThatAre_StringsHaving_SameNumberOfSpaces()
		def AllItemsAre_StringsHaving_SameNumberOfSpaces()	def ContainsOnly_StringsHaving_SameNumberOfSpaces()
		def SomeItemsAre_StringsHaving_SameNumberOfSpaces()	def ContainsSome_StringsHaving_SameNumberOfSpaces()
		def NoItemsAre_StringsHaving_SameNumberOfSpaces()	def ContainsNo_StringsHaving_SameNumberOfSpaces()
	def ExcludeItemsThatAre_StringsHaving_SameNumberOfSpaces()

	def ItemsThatAre_StringsHaving_SameNthItem(n)
		def AllItemsAre_StringsHaving_SameNthItem(n)	def ContainsOnly_StringsHaving_SameNthItem(n)
		def SomeItemsAre_StringsHaving_SameNthItem(n)	def ContainsSome_StringsHaving_SameNthItem(n)
		def NoItemsAre_StringsHaving_SameNthItem(n)	def ContainsNo_StringsHaving_SameNthItem(n)
	def ExcludeItemsThatAre_StringsHaving_SameNthItem(n)

	def ItemsThatAre_StringsHaving_SameNItems_FromTheRight(n)
		def AllItemsAre_StringsHaving_SameNItems_FromTheRight(n)	def ContainsOnly_StringsHaving_SameNItems_FromTheRight(n)
		def SomeItemsAre_StringsHaving_SameNItems_FromTheRight(n)	def ContainsSome_StringsHaving_SameNItems_FromTheRight(n)
		def NoItemsAre_StringsHaving_SameNItems_FromTheRight(n)		def ContainsNo_StringsHaving_SameNItems_FromTheRight(n)
	def ExcludeItemsThatAre_StringsHaving_SameNItems_FromTheRight(n)

	def ItemsThatAre_StringsHaving_SameNItems_FromTheLeft(n)
		def AllItemsAre_StringsHaving_SameNItems_FromTheLeft(n)		def ContainsOnly_StringsHaving_SameNItems_FromTheLeft(n)
		def SomeItemsAre_StringsHaving_SameNItems_FromTheLeft(n)	def ContainsSome_StringsHaving_SameNItems_FromTheLeft(n)
		def NoItemsAre_StringsHaving_SameNItems_FromTheLeft(n)		def ContainsNo_StringsHaving_SameNItems_FromTheLeft(n)
	def ExcludeItemsThatAre_StringsHaving_SameNItems_FromTheLeft(n)

	def ItemsThatAre_StringsOriented_FromRightToLeft()
		def AllItemsAre_StringsOriented_FromRightToLeft()	def ContainsOnly_StringsOriented_FromRightToLeft()
		def SomeItemsAre_StringsOriented_FromRightToLeft()	def ContainsSome_SgringsOriented_FromRightToLeft()
		def NoItemsAre_StringsOriented_FromRightToLeft()	def ContainsNo_StringsOriented_FromRightToLeft()
	def ExcludeItemsThatAre_StringsOriented_FromRightToLeft()

	def ItemsThatAre_StringsOriented_FromLeftToRight()
		def AllItemsAre_StringsOriented_FromLeftToRight()	def ContainsOnly_StringsOriented_FromLeftToRight()
		def SomeItemsAre_StringsOriented_FromLeftToRight()	def ContainsSome_SgringsOriented_FromLeftToRight()
		def NoItemsAre_StringsOriented_FromLeftToRight()	def ContainsNo_StringsOriented_FromLeftToRight()
	def ExcludeItemsThatAre_StringsOriented_FromLeftToRight()
	
	def ItemsThatAre_EmptyStrings()
		def AllItemsAre_EmptyStrings()	def ContainsOnly_EmptyStrings()
		def SomeItemsAre_EmptyStrings()	def ContainsSome_EmptyStrings()
		def NoItemsAre_EmptyStrings()	def ContainsNo_EmptyStrings()
	def ExcludeItemsThatAre_EmptyStrings()

	def ItemsThatAre_NullStrings()
		def AllItemsAre_NullStrings()	def ContainsOnly_NullStrings()
		def SomeItemsAre_NullStrings()	def ContainsSome_NullStrings()
		def NoItemsAre_NullStrings()	def ContainsNo_NullStrings()
	def ExcludeItemsThatAre_NullStrings()

	def ItemsThatAre_StringsMadeOf_WhiteSpaces()
		def AllItemsAre_StringsMadeOf_WhiteSpaces()	def ContainsOnly_StringsMadeOf_WhiteSpaces()
		def SomeItemsAre_StringsMadeOf_WhiteSpaces()	def ContainsSome_StringsMadeOf_WhiteSpaces()
		def NoItemsAre_StringsMadeOf_WhiteSpaces()	def ContainsNo_StringsMadeOf_WhiteSpaces()
	def ExcludeItemsThatAre_StringsMadeOf_WhiteSpaces()
	
	def ItemsThatAre_StringsStartingWith(pcSubStr)
		def AllItemsAre_StringsStartingWith(pcSubStr)	def ContainsOnly_StringsStartingWith(pcSubStr)
		def SomeItemsAre_StringsStartingWith(pcSubStr)	def ContainsSome_StringsStartingWith(pcSubStr)
		def NoItemsAre_StringsStartingWith(pcSubStr)	def ContainsNo_StringsStartingWith(pcSubStr)
	def ExcludeItemsThatAre_StringsStartingWith(pcSubStr)

	def ItemsThatAre_StringsEndingWith(pcSubStr)
		def AllItemsAre_StringsEndingWith(pcSubStr)	def ContainsOnly_StringsEndingWith(pcSubStr)
		def SomeItemsAre_StringsEndingWith(pcSubStr)	def ContainsSome_StringsEndingWith(pcSubStr)
		def NoItemsAre_StringsEndingWith(pcSubStr)	def ContainsNo_StringsEndingWith(pcSubStr)
	def ExcludeItemsThatAre_StringsEndingWith(pcSubStr)

	def ItemsThatAre_StringsContaining(pSubStr)
		def AllItemsAre_StringsContaining(pSubStr)	def ContainsOnly_StringsContaining(pSubStr)
		def SomeItemsAre_StringsContaining(pSubStr)	def ContainsSome_StringsContaining(pSubstr)
		def NoOtemsAre_stringsContaining(pSubStr)	def ContainsNo_StringsContaining(pSubStr)
	def ExcludeItemsThatAre_StringsContaining(pSubstr)

	def ItemsThatAre_StringsMadeOf(paSubStr)
		def AllItemsAre_StringsMadOf(paSubStr)		def ContainsOnly_StringsMadeOf(paSubStr)
		def SomeItemsAre_StringsMadeOf(paSubStr)	def ContainsSome_StringsMadeOf(paSubStr)
		def NoItemsAre_StringsMadeOf(paSubStr)		def ContainsNo_StringsMadeOf(paSubStr)
	def ExcludeItemsThatAre_StringsMadeOf(paSubStr)

	def ItemsThatAre_StringsMadeOf_Numbers()
		def ItemsAre_StringsMadeOf_Numbers()		def ContainsOnly_StringsMadeOf_Numbers()
		def SomeItemsAre_StringsMadeOf_Numbers()	def ContainsSome_StringsMadeOf_Numbers()
		def NoItemsAre_StringsMadeOf_Numbers()		def ContainsNo_StringsMadeOf_Numbers()
	def ExcludeItemsThatAre_StringsMadeOf_Numbers()

	def ItemsThatAre_StringsMadeOf_Letters()
		def ItemsAre_StringsMadeOf_Letters()		def ContainsOnly_StringsMadeOf_Letters()
		def SomeItemsAre_StringsMadeOf_Letters()	def ContainsSome_StringsMadeOf_Letters()
		def NoItemsAre_StringsMadeOf_Letters()		def ContainsNo_StringsMadeOf_Letters()
	def ExcludeItemsThatAre_StringsMadeOf_Letters()

	def ItemsThatAre_StringsMadeOf_Punctuations()
		def ItemsAre_StringsMadeOf_Punctuations()	def ContainsOnly_StringsMadeOf_Punctuations()
		def SomeItemsAre_StringsMadeOf_Punctuations()	def ContainsSome_StringsMadeOf_Punctuations()
		def NoItemsAre_StringsMadeOf_Punctuations()	def ContainsNo_StringsMadeOf_Punctuations()
	def ExcludeItemsThatAre_StringsMadeOf_Punctuations()

	def ItemsThatAre_StringsMadeOf_SpecialChars()
		def ItemsAre_StringsMadeOf_SpecialChars()	def ContainsOnly_StringsMadeOf_SpecialChars()
		def SomeItemsAre_StringsMadeOf_SpecialChars()	def ContainsSome_StringsMadeOf_SpecialChars()
		def NoItemsAre_StringsMadeOf_SpecialChars()	def ContainsNo_StringsMadeOf_SpecialChars()
	def ExcludeItemsThatAre_StringsMadeOf_SpecialChars()

	// s = "fr..." -> s isAllignedToTheLeft in a span of 5 characters 
	def ItemsThatAre_StringsAlligned_ToTheLeft_InASpanOfNChars(n)
		def ItemsAre_StringsAlligned_ToTheLeft_InASpanOfNChars(n)	def ContainsOnly_StringsAlligned_ToTheLeft_InASpanOfNChars(n)
		def SomeItemsAre_StringsAlligned_ToTheLeft_InASpanOfNChars(n)	def ContainsSome_StringsAlligned_ToTheLeft_InASpanOfNChars(n)
		def NoItemsThatAre_StringsAlligned_ToTheLeft_InASpanOfNChars(n)	def ContainsNo_StringsAlligned_ToTheLeft_InASpanOfNChars(n)
	def ExcludeItemsThatAre_StringsAlligned_ToTheLeft_InASpanOfNChars(n)

	// s = "...fr" -> s isAllignedToTheRight in a span of 5 characters 
	def ItemsThatAre_StringsAlligned_ToTheRight_InASpanOfNChars(n)
		def ItemsAre_StringsAlligned_ToTheRight_InASpanOfNChars(n)		def ContainsOnly_StringsAlligned_ToTheRight_InASpanOfNChars(n)
		def SomeItemsAre_StringsAlligned_ToTheRight_InASpanOfNChars(n)		def ContainsSome_StringsAlligned_ToTheRight_InASpanOfNChars(n)
		def NoItemsThatAre_StringsAlligned_ToTheRight_InASpanOfNChars(n)	def ContainsNo_StringsAlligned_ToTheRight_InASpanOfNChars(n)
	def ExcludeItemsThatAre_StringsAlligned_ToTheRight_InASpanOfNChars(n)

	// s = "...fr..." -> s isAllignedToTheCenter in a span of 5 characters 
	def ItemsThatAre_StringsAlligned_ToTheCenter_InASpanOfNChars(n)
		def ItemsAre_StringsAlligned_ToTheCenter_InASpanOfNChars(n)	def ContainsOnly_StringsAlligned_ToTheCenter_InASpanOfNChars(n)
		def SomeItemsAre_StringsAlligned_ToTheCenter_InASpanOfNChars(n)	def ContainsSome_StringsAlligned_ToTheCenter_InASpanOfNChars(n)
		def NoItemsAre_StringsAlligned_ToTheCenter_InASpanOfNChars(n)	def ContainsNo_StringsAlligned_ToTheCenter_InASpanOfNChars(n)
	def ExcludeItemsThatAre_StringsAlligned_ToTheCenter_InASpanOfNChars(n)

	  #------------------------------------------#
	 #     Related to items that are LISTS      #
	#------------------------------------------#

	// ItemsAre_Strings, ItemsInclude_, ItemsThatAre_

	def ItemsThatAre_Lists()
		def AllItemsAre_Lists()		def ContainsOnly_Lists()
		def SomeItemsAre_Lists()	def ContainsSome_Lists()
		def NoItemsAre_Lists()		def ContainsNo_Lists()
	def ExcludeItemsThatAre_Lists()

	def ItemsThatAre_RingLists()
		def AllItemsAre_RingLists()	def ContainsOnly_RingLists()
		def SomeItemsAre_RingLists()	def ContainsSome_RingLists()
		def NoItemsAre_RingLists()	def ContainsNo_RingLists()
	def ExcludeItemsThatAre_RingLists()

	def ItemsThatAre_StzLists()
		def AllItemsAre_StzLists()	def ContainsOnly_StzLists()
		def SomeItemsAre_StzLists()	def ContainsSome_StzLists()
		def NoItemsAre_StzLists()	def ContainsNo_StzLists()
	def ExcludeItemsThatAre_StzLists()

	def ItemsThatAre_UnaryLists()
		def AllItemsAre_UnaryLists()	def ContainsOnly_UnaryLists()
		def SomeItemsAre_UnaryLists()	def ContainsSome_UnaryLists()
		def NoItemsAre_UnaryLists()	def ContainsNo_UnaryLists()
	def ExcludeItemsThatAre_UnaryLists()

	def ItemsThatAre_EmptyLists()
		def AllItemsAre_EmptyLists()	def ContainsOnly_EmptyLists()
		def SomeItemsAre_EmptyLists()	def ContainsSome_EmptyLists()
		def NoItemsAre_EmptyLists()	def ContainsNo_EmptyLists()
	def ExcludeItemsThatAre_EmptyLists()

	def ItemsThatAre_DeepLists()
		def AllItemsAre_DeepLists()	def ContainsOnly_DeepLists()
		def SomeItemsAre_DeepLists()	def ContainsSome_DeepLists()
		def NoItemsAre_DeepLists()	def ContainsNo_DeepLists()
	def ExcludeItemsThatAre_DeepLists()

	def ItemsThatAre_HybridLists()
		def AllItemsAre_HybridLists()	def ContainsOnly_HybridLists()
		def SomeItemsAre_HybridLists()	def ContainsSome_HybridLists()
		def NoItemsAre_HybridLists()	def ContainsNo_HybridLists()
	def ExcludeItemsThatAre_HybridLists()

	def ItemsThatAre_PureLists()
		def AllItemsAre_PureLists()	def ContainsOnly_PureLists()
		def SomeItemsAre_PureLists()	def ContainsSome_PureLists()
		def NoItemsAre_PureLists()	def ContainsNo_PureLists()
	def ExcludeItemsThatAre_PureLists()

	def ItemsThatAre_OddLists()
		def AllItemsAre_OddLists()	def ContainsOnly_OddLists()
		def SomeItemsAre_OddLists()	def ContainsSome_OddLists()
		def NoItemsAre_OddLists()	def ContainsNo_OddLists()
	def ExcludeItemsThatAre_OddLists()

	def ItemsThatAre_EvenLists()
		def AllItemsAre_EvenLists()	def ContainsOnly_EvenLists()
		def SomeItemsAre_EvenLists()	def ContainsSome_EvenLists()
		def NoItemsAre_EvenLists()	def ContainsNo_EvenLists()
	def ExcludeItemsThatAre_EvenLists()

	def ItemsThatAre_StzSets()
		def AllItemsAre_StzSets()	def ContainsOnly_StzSets()
		def SomeItemsAre_StzSets()	def ContainsSome_StzSets()
		def NoItemsAre_StzSets()	def ContainsNo_StzSets()
	def ExcludeItemsThatAre_StzSets()

	def ItemsThatAre_StzTrees()
		def AllItemsAre_StzTrees()	def ContainsOnly_StzTrees()
		def SomeItemsAre_StzTrees()	def ContainsSome_StzTrees()
		def NoItemsAre_StzTrees()	def ContainsNo_StzTrees()
	def ExcludeItemsThatAre_StzTrees()

	def ItemsThatAre_StzTables()
		def AllItemsAre_StzTables()	def ContainsOnly_StzTables()
		def SomeItemsAre_StzTables()	def ContainsSome_StzTables()
		def NoItemsAre_StzTables()	def ContainsNo_StzTables()
	def ExcludeItemsThatAre_StzTables()

	def ItemsThatAre_StzPivotTables()
		def AllItemsAre_StzPivotTables()	def ContainsOnly_StzPivotTables()
		def SomeItemsAre_StzPivotTables()	def ContainsSome_StzPivotTables()
		def NoItemsAre_StzPivotTables()		def ContainsNo_StzPivotTables()
	def ExcludeItemsThatAre_StzPivotTables()

	def ItemsThatAre_StzGraphs()
		def AllItemsAre_StzGraphs()	def ContainsOnly_StzGraphs()
		def SomeItemsAre_StzGraphs()	def ContainsSome_StzGraphs()
		def NoItemsAre_StzGraphs()	def ContainsNo_StzGraphs()
	def ExcludeItemsThatAre_StzGraphs()

	def ItemsThatAre_SortedLists()
		def AllItemsAre_SortedLists()	def ContainsOnly_SortedLists()
		def SomeItemsAre_SortedLists()	def ContainsSome_SortedLists()
		def NoItemsAre_SortedLists()	def ContainsNo_SortedLists()
	def ExcludeItemsThatAre_SortedLists()

	def ItemsThatAre_SortedInAscendingLists()
		def AllItemsAre_SortedInAscendingLists()	def ContainsOnly_SortedInAscendingLists()
		def SomeItemsAre_SortedInAscendingLists()	def ContainsSome_SortedInAscendingLists()
		def NoItemsAre_SortedInAscendingLists()		def ContainsNo_SortedInAscendingLists()
	def ExcludeItemsThatAre_SortedInAscendingLists()

	def ItemsThatAre_SortedInDescendingLists()
		def AllItemsAre_SortedInDescendingLists()	def ContainsOnly_SortedInDescendingLists()
		def SomeItemsAre_SortedInDescendingLists()	def ContainsSome_SortedInDescendingLists()
		def NoItemsAre_SortedInDescendingLists()	def ContainsNo_SortedInDescendingLists()
	def ExcludeItemsThatAre_SortedInDescendingLists()

	def ItemsThatAre_ListsHaving_SameNumberOfItems()
		def AllItemsAre_ListsHaving_SameNumberOfItems()		def ContainsOnly_ListsHaving_SameNumberOfItems()
		def SomeItemsAre_ListsHaving_SameNumberOfItems()	def ContainsSome_ListsHaving_SameNumberOfItems()
		def NoItemsAre_ListsHaving_SameNumberOfItems()		def ContainsNo_ListsHaving_SameNumberOfItems()
	def ExcludeItemsThatAre_ListsHaving_SameNumberOfItems()

	def ItemsThatAre_StzListsHaving_SameNumberOfItems()
		def AllItemsAre_StzListsHaving_SameNumberOfItems()	def ContainsOnly_StzListsHaving_SameNumberOfItems()
		def SomeItemsAre_StzListsHaving_SameNumberOfItems()	def ContainsSome_StzListsHaving_SameNumberOfItems()
		def NoItemsAre_StzListsHaving_SameNumberOfItems()	def ContainsNo_StzListsHaving_SameNumberOfItems()
	def ExcludeItemsThatAre_StzListsHaving_SameNumberOfItems()

	def ItemsThatAre_ListsOf_NItems(n)
		def AllItemsAre_ListsOf_NItems(n)	def ContainsOnly_ListsOf_NItems(n)
		def SomeItemsAre_ListsOf_NItems(n)	def ContainsSome_ListsOf_NItems(n)
		def NoItemsAre_ListsOf_NItems(n)	def ContainsNo_ListsOf_NItems(n)
	def ExcludeItemsThatAre_ListsOf_NItems(n)

	  #------------------------------------------#
	 #     Related to items that are GRIDS      #
	#------------------------------------------#
(...) 
	def ItemsThatAre_StzGrids()
		def AllItemsAre_StzGrids()	def ContainsOnly_StzGrids()
		def SomeItemsAre_StzGrids()	def ContainsSome_StzGrids()
		def NoItemsAre_StzGrids()	def ContainsNo_StzGrids()
	def ExcludeItemsThatAre_StzGrids()

	def ItemsThatAre_StzGridsHaving_SameNumberOfItems()
		def AllItemsAre_StzGridsHaving_SameNumberOfItems()	def ContainsOnly_StzGridsHaving_SameNumberOfItems()
		def SomeItemsAre_StzGridsHaving_SameNumberOfItems()	def ContainsSome_StzGridsHaving_SameNumberOfItems()
		def NoItemsAre_StzGridsHaving_SameNumberOfItems()	def ContainsNo_StzGridsHaving_SameNumberOfItems()
	def ExcludeItemsThatAre_StzGridsHaving_SameNumberOfItems()

	def ItemsThatAre_StzGridsHaving_SameSize()
		def AllItemsAre_StzGridsHaving_SameSize()	def ContainsOnly_StzGridsHaving_SameSize()
		def SomeItemsAre_StzGridsHaving_SameSize()	def ContainsSome_StzGridsHaving_SameSize()
		def NoItemsAre_StzGridsHaving_SameSize()	def ContainsNo_StzGridsHaving_SameSize()
	def ExcludeItemsThatAre_StzGridsHaving_SameSize()

	def ItemsThatAre_StzGridsHaving_SameNumberOfVLines()
		def AllItemsAre_StzGridsHaving_SameNumberOfVLines()	def ContainsOnly_StzGridsHaving_SameNumberOfVLines()
		def SomeItemsAre_StzGridsHaving_SameNumberOfVLines()	def ContainsSome_StzGridsHaving_SameNumberOfVLines()
		def NoItemsAre_StzGridsHaving_SameNumberOfVLines()	def ContainsNo_StzGridsHaving_SameNumberOfVLines()
	def ExcludeItemsThatAre_StzGridsHaving_SameNumberOfVLines()

	def ItemsThatAre_StzGridsHaving_SameNumberOfHLines()
		def AllItemsAre_StzGridsHaving_SameNumberOfHLines()	def ContainsOnly_StzGridsHaving_SameNumberOfHLines()
		def SomeItemsAre_StzGridsHaving_SameNumberOfHLines()	def ContainsSome_StzGridsHaving_SameNumberOfHLines()
		def NoItemsAre_StzGridsHaving_SameNumberOfHLines()	def ContainsNo_StzGridsHaving_SameNumberOfHLines()
	def ExcludeItemsThatAre_StzGridsHaving_SameNumberOfHLines()

	def ItemsThatAre_StzGridsHaving_SameNumberOfNodesPerVLine()
		def AllItemsAre_StzGridsHaving_SameNumberOfNodesPerVLine()	def ContainsOnly_StzGridsHaving_SameNumberOfNodesPerVLine()
		def SomeItemsAre_StzGridsHaving_SameNumberOfNodesPerVLine()	def ContainsSome_StzGridsHaving_SameNumberOfNodesPerVLine()
		def NoItemsAre_StzGridsHaving_SameNumberOfNodesPerVLine()	def ContainsNo_StzGridsHaving_SameNumberOfNodesPerVLine()
	def ExcludeItemsThatAre_StzGridsHaving_SameNumberOfNodesPerVLine()

	def ItemsThatAre_StzGridsHaving_SameNumberOfNodesPerHLine()
		def AllItemsAre_StzGridsHaving_SameNumberOfNodesPerHLine()	def ContainsOnly_StzGridsHaving_SameNumberOfNodesPerHLine()
		def SomeItemsAre_StzGridsHaving_SameNumberOfNodesPerHLine()	def ContainsSome_StzGridsHaving_SameNumberOfNodesPerHLine()
		def NoItemsAre_StzGridsHaving_SameNumberOfNodesPerHLine()	def ContainsNo_StzGridsHaving_SameNumberOfNodesPerHLine()
	def ExcludeItemsThatAre_StzGridsHaving_SameNumberOfNodesPerHLine()

	def ItemsThatAre_StzGridsHaving_SameNthVLine(n)
		def AllItemsAre_StzGridsHaving_SameNthVLine(n)	def ContainsOnly_StzGridsHaving_SameNthVLine(n)
		def SomeItemsAre_StzGridsHaving_SameNthVLine(n)	def ContainsSome_StzGridsHaving_SameNthVLine(n)
		def NoItemsAre_StzGridsHaving_SameNthVLine(n)	def ContainsNo_StzGridsHaving_SameNthVLine(n)
	def ExcludeItemsThatAre_StzGridsHaving_SameNthVLine(n)

	def ItemsThatAre_StzGridsHaving_SameFirstVLine()
		def AllItemsAre_StzGridsHaving_SameFirstVLine()	def ContainsOnly_StzGridsHaving_SameFirstVLine()
		def SomeItemsAre_StzGridsHaving_SameFirstVLine()	def ContainsSome_StzGridsHaving_SameFirstVLine()
		def NoItemsAre_StzGridsHaving_SameFirstVLine()	def ContainsNo_StzGridsHaving_SameFirstVLine()
	def ExcludeItemsThatAre_StzGridsHaving_SameFirstVLine()

	def ItemsThatAre_StzGridsHaving_SameLastVLine(n)
		def AllItemsAre_StzGridsHaving_SameLastVLine(n)		def ContainsOnly_StzGridsHaving_SameLastVLine(n)
		def SomeItemsAre_StzGridsHaving_SameLastVLine(n)	def ContainsSome_StzGridsHaving_SameLastVLine(n)
		def NoItemsAre_StzGridsHaving_SameLastVLine(n)		def ContainsNo_StzGridsHaving_SameLastVLine(n)
	def ExcludeItemsThatAre_StzGridsHaving_SameLastVLine(n)

	def ItemsThatAre_StzGridsHaving_SameNthHLine(n)
		def AllItemsAre_StzGridsHaving_SameNthHLine(n)	def ContainsOnly_StzGridsHaving_SameNthHLine(n)
		def SomeItemsAre_StzGridsHaving_SameNthHLine(n)	def ContainsSome_StzGridsHaving_SameNthHLine(n)
		def NoItemsAre_StzGridsHaving_SameNthHLine(n)	def ContainsNo_StzGridsHaving_SameNthHLine(n)
	def ExcludeItemsThatAre_StzGridsHaving_SameNthHLine(n)

	def ItemsThatAre_StzGridsHaving_SameFirstHVLine()
		def AllItemsAre_StzGridsHaving_SameFirstHLine()	def ContainsOnly_StzGridsHaving_SameFirstHLine()
		def SomeItemsAre_StzGridsHaving_SameFirstHLine()	def ContainsSome_StzGridsHaving_SameFirstHLine()
		def NoItemsAre_StzGridsHaving_SameFirstHLine()	def ContainsNo_StzGridsHaving_SameFirstHLine()
	def ExcludeItemsThatAre_StzGridsHaving_SameFirstHLine()

	def ItemsThatAre_StzGridsHaving_SameLastHLine(n)
		def AllItemsAre_StzGridsHaving_SameLastHLine(n)		def ContainsOnly_StzGridsHaving_SameLastHLine(n)
		def SomeItemsAre_StzGridsHaving_SameLastHLine(n)	def ContainsSome_StzGridsHaving_SameLastHLine(n)
		def NoItemsAre_StzGridsHaving_SameLastHLine(n)		def ContainsNo_StzGridsHaving_SameLastHLine(n)
	def ExcludeItemsThatAre_StzGridsHaving_SameLastHLine(n)

	def ItemsThatAre_StzGridsHaving_SameContent()
		def AllItemsAre_StzGridsHaving_SameContent()	def ContainsOnly_StzGridsHaving_SameContent()
		def SomeItemsAre_StzGridsHaving_SameContent()	def ContainsSome_StzGridsHaving_SameContent()
		def NoItemsAre_StzGridsHaving_SameContent()	def ContainsNo_StzGridsHaving_SameContent()
	def ExcludeItemsThatAre_StzGridsHaving_Samecontent()

	def ItemsThatAre_StzGridsHaving_SameCenter()
		def AllItemsAre_StzGridsHaving_SameCenter()	def ContainsOnly_StzGridsHaving_SameCenter()
		def SomeItemsAre_StzGridsHaving_SameCenter()	def ContainsSome_StzGridsHaving_SameCenter()
		def NoItemsAre_StzGridsHaving_SameCenter()	def ContainsNo_StzGridsHaving_SameCenter()
	def ExcludeItemsThatAre_StzGridsHaving_SameCenter()

	def ItemsThatAre_StzGridsHaving_SameNthNode(nRank)
		def AllItemsAre_StzGridsHaving_SameNthNode(nRank)	def ContainsOnly_StzGridsHaving_SameNthNode(nRank)
		def SomeItemsAre_StzGridsHaving_SameNthNode(nRank)	def ContainsSome_StzGridsHaving_SameNthNode(nRank)
		def NoItemsAre_StzGridsHaving_SameNthNode(nRank)	def ContainsNo_StzGridsHaving_SameNthNode(nRank)
	def ExcludeItemsThatAre_StzGridsHaving_SameNthNode(nRank)

	def ItemsThatAre_StzGridsHaving_SameNodeAtPosition(nH, nV)
		def AllItemsAre_StzGridsHaving_SameNodeAtPosition(nH, nV)	def ContainsOnly_StzGridsHaving_SameNodeAtPosition(nH, nV)
		def SomeItemsAre_StzGridsHaving_SameNodeAtPosition(nH, nV)	def ContainsSome_StzGridsHaving_SameNodeAtPosition(nH, nV)
		def NoItemsAre_StzGridsHaving_SameNodeAtPosition(nH, nV)	def ContainsNo_StzGridsHaving_SameNodeAtPosition(nH, nV)
	def ExcludeItemsThatAre_StzGridsHaving_SameNodeAtPosition(nH, nV)

	def ItemsThatAre_StzGridsHaving_CentralVLine()
		def AllItemsAre_StzGridsHaving_CentralVLine()	def ContainsOnly_StzGridsHaving_CentralVLine()
		def SomeItemsAre_StzGridsHaving_CentralVLine()	def ContainsSome_StzGridsHaving_CentralVLine()
		def NoItemsAre_StzGridsHaving_CentralVLine()	def ContainsNo_StzGridsHaving_CentralVLine()
	def ExcludeItemsThatAre_StzGridsHaving_CentralVLine()

	def ItemsThatAre_StzGridsHaving_CentralHLine()
		def AllItemsAre_StzGridsHaving_CentralHLine()	def ContainsOnly_StzGridsHaving_CentralHLine()
		def SomeItemsAre_StzGridsHaving_CentralHLine()	def ContainsSome_StzGridsHaving_CentralHLine()
		def NoItemsAre_StzGridsHaving_CentralHLine()	def ContainsNo_StzGridsHaving_CentralHLine()
	def ExcludeItemsThatAre_StzGridsHaving_CentralHLine()

	def ItemsThatAre_StzGridsHaving_CentralNode()
		def AllItemsAre_StzGridsHaving_CentralNode()	def ContainsOnly_StzGridsHaving_CentralNode()
		def SomeItemsAre_StzGridsHaving_CentralNode()	def ContainsSome_StzGridsHaving_CentralNode()
		def NoItemsAre_StzGridsHaving_CentralNode()	def ContainsNo_StzGridsHaving_CentralNode()
	def ExcludeItemsThatAre_StzGridsHaving_CentralNode()

	def ItemsThatAre_StzGridsHaving_CentralRegion()
		def AllItemsAre_StzGridsHaving_CentralRegion()	def ContainsOnly_StzGridsHaving_CentralRegion()
		def SomeItemsAre_StzGridsHaving_CentralRegion()	def ContainsSome_StzGridsHaving_CentralRegion()
		def NoItemsAre_StzGridsHaving_CentralRegion()	def ContainsNo_StzGridsHaving_CentralRegion()
	def ExcludeItemsThatAre_StzGridsHaving_CentralRegion()

	def ItemsThatAre_StzGridsHaving_SameCentralNode()
		def AllItemsAre_StzGridsHaving_SameCentralNode()	def ContainsOnly_StzGridsHaving_SameCentralNode()
		def SomeItemsAre_StzGridsHaving_SameCentralNode()	def ContainsSome_StzGridsHaving_SameCentralNode()
		def NoItemsAre_StzGridsHaving_SameCentralNode()	def ContainsNo_StzGridsHaving_SameCentralNode()
	def ExcludeItemsThatAre_StzGridsHaving_SameCentralNode()

	def ItemsThatAre_StzGridsHaving_SameCentralRegion()
		def AllItemsAre_StzGridsHaving_SameCentralRegion()	def ContainsOnly_StzGridsHaving_SameCentralRegion()
		def SomeItemsAre_StzGridsHaving_SameCentralRegion()	def ContainsSome_StzGridsHaving_SameCentralRegion()
		def NoItemsAre_StzGridsHaving_SameCentralRegion()	def ContainsNo_StzGridsHaving_SameCentralRegion()
	def ExcludeItemsThatAre_StzGridsHaving_SameCentralRegion()

	def ItemsThatAre_StzGridsHaving_SameCenter()
		def AllItemsAre_StzGridsHaving_SameCenter()	def ContainsOnly_StzGridsHaving_SameCenter()
		def SomeItemsAre_StzGridsHaving_SameCenter()	def ContainsSome_StzGridsHaving_SameCenter()
		def NoItemsAre_StzGridsHaving_SameCenter()	def ContainsNo_StzGridsHaving_SameCenter()
	def ExcludeItemsThatAre_StzGridsHaving_SameCenter()

	def ItemsThatAre_StzGridsHaving_SamePositionOfCentralNode()
		def AllItemsAre_StzGridsHaving_SamePositionOfCentralNode()	def ContainsOnly_StzGridsHaving_SamePositionOfCentralNode()
		def SomeItemsAre_StzGridsHaving_SamePositionOfCentralNode()	def ContainsSome_StzGridsHaving_SamePositionOfCentralNode()
		def NoItemsAre_StzGridsHaving_SamePositionOfCentralNode()	def ContainsNo_StzGridsHaving_SamePositionOfCentralNode()
	def ExcludeItemsThatAre_StzGridsHaving_SamePositionOfCentralNode()

	def ItemsThatAre_StzGridsHaving_SamePositionOfCentralRegion()
		def AllItemsAre_StzGridsHaving_SamePositionOfCentralRegion()	def ContainsOnly_StzGridsHaving_SamePositionOfCentralRegion()
		def SomeItemsAre_StzGridsHaving_SamePositionOfCentralRegion()	def ContainsSome_StzGridsHaving_SamePositionOfCentralRegion()
		def NoItemsAre_StzGridsHaving_SamePositionOfCentralRegion()	def ContainsNo_StzGridsHaving_SamePositionOfCentralRegion()
	def ExcludeItemsThatAre_StzGridsHaving_SamePositionOfCentralRegion()

	def ItemsThatAre_StzGridsHaving_SameCenterPosition()
		def AllItemsAre_StzGridsHaving_SameCenterPosition()	def ContainsOnly_StzGridsHaving_SameCenterPosition()
		def SomeItemsAre_StzGridsHaving_SameCenterPosition()	def ContainsSome_StzGridsHaving_SameCenterPosition()
		def NoItemsAre_StzGridsHaving_SameCenterPosition()	def ContainsNo_StzGridsHaving_SameCenterPosition()
	def ExcludeItemsThatAre_StzGridsHaving_SameCenterPosition()

	def ItemsThatAre_StzGridsHaving_SameNodesOfSection(paNode1, paNode2)
		def AllItemsAre_StzGridsHaving_SameNodesOfSection(paNode1, paNode2)	def ContainsOnly_StzGridsHaving_SameNodesOfSection(paNode1, paNode2)
		def SomeItemsAre_StzGridsHaving_SameNodesOfSection(paNode1, paNode2)	def ContainsSome_StzGridsHaving_SameNodesOfSection(paNode1, paNode2)
		def NoItemsAre_StzGridsHaving_SameNodesOfSection(paNode1, paNode2)	def ContainsNo_StzGridsHaving_SameNodesOfSection(paNode1, paNode2)
	def ExcludeItemsThatAre_StzGridsHaving_SameNodesOfSection(paNode1, paNode2)

	def ItemsThatAre_StzGridsHaving_SameNodesOfRegion(paNode1, paNode2)
		def AllItemsAre_StzGridsHaving_SameNodesOfRegion(paNode1, paNode2)	def ContainsOnly_StzGridsHaving_SameNodesOfRegion(paNode1, paNode2)
		def SomeItemsAre_StzGridsHaving_SameNodesOfRegion(paNode1, paNode2)	def ContainsSome_StzGridsHaving_SameNodesOfRegion(paNode1, paNode2)
		def NoItemsAre_StzGridsHaving_SameNodesOfRegion(paNode1, paNode2)	def ContainsNo_StzGridsHaving_SameNodesOfRegion(paNode1, paNode2)
	def ExcludeItemsThatAre_StzGridsHaving_SameNodesOfRegion(paNode1, paNode2)

	  #------------------------------------------#
	 #     Related to items that are TABLES      #
	#------------------------------------------#
	// TODO

	  #-------------------------------------------------#
	 #     Related to items that are PIVOT TABLES      #
	#------------------------------------------------#
	// TODO

	  #------------------------------------------#
	 #     Related to items that are TREES      #
	#------------------------------------------#
	// TODO

	  #------------------------------------------#
	 #     Related to items that are OBJECTS    #
	#------------------------------------------#

	def ItemsThatAre_Objects()
		def AllItemsAre_Objects()	def ContainsOnly_Objects()
		def SomeItemsAre_Objects()	def ContainsSome_Objects()
		def NoItemsAre_Objects()	def ContainsNo_Objects()
	def ExcludeItemThatAre_Objects()

	def ItemsThatAre_RingObjects()
		def AllItemsAre_RingObjects()	def ContainsOnly_RingObjects()
		def SomeItemsAre_RingObjects()	def ContainsSome_RingObjects()
		def NoItemsAre_RingObjects()	def ContainsNo_RingObjects()
	def ExcludeItemThatAre_RingObjects()

	def ItemsThatAre_StzObjects()
		def AllItemsAre_StzObjects()	def ContainsOnly_StzObjects()
		def SomeItemsAre_StzObjects()	def ContainsSome_StzObjects()
		def NoItemsAre_StzObjects()	def ContainsNo_StzObjects()
	def ExcludeItemThatAre_StzObjects()

