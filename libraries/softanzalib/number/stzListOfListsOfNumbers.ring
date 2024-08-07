
func StzListOfListsOfNumbersQ(paListOfListsOfNumbers)
	return new stzListOfListsOfNumbers(paListOfListsOfNumbers)

func StzListOfNumbersListsQ(paListOfListsOfNumbers)
	return new stzListOfNumbersLists(paListOfListsOfNumbers)

class stzListOfNumbersLists from stzListOfListsOfNumbers

class stzListOfListsOfNumbers
	@aContent

	def init(paListOfListsOfNumbers)
		if isList(paListOfListsOfNumbers) and
		   StzListQ(paListOfListsOfNumbers).IsListOfListsOfNumbers()
			
			@aContent = paListOfListsOfNumbers

		else
			StzRaise("Can not create the stzListOfListsOfNumbers object!")
		ok

	def Content()
		return @aContent

		def ListOfListsOfNumbers()
			return This.Content()

		def Value()
			return Content()

	def Copy()
		return new stzListOfListsOfNumbers( This.Content() )

	def NumberOfLists()
		return len( This.ListOfListsOfNumbers() )

	def Complete()
		This.CompeteWith(0)

	def CompleteWith(n)
		/* Example
		o1 = new stzListOfListsOfNumbersQ([
			[ 3, 6, 2 ],
			[ 2, 4 ],
			[ 2, 1, 3, 5 ]
		])

		o1.Completewith(0)
		? o1.Content()

		#--> [
			[ 3, 6, 2, 0 ],
			[ 2, 4, 0, 0 ],
			[ 2, 1, 3, 5 ]
		      ]
		*/

	def SmallestLenOfList()
		return StzListOfNumbersQ(This.NumbersOfItemsInEachList()).Min()

	def SmallestList()
		nMin = This.SmallestLenOfList()
		aPos = StzListQ( This.NumbersOfItemsInEachList() ).FindAll(nMin)

		if len(aPos) = 1
			return This.Content()[aPos[1]]
		else
			aResult = []
			for n in aPos
				aResult + This.Content()[n]
			next

			return aResult
		ok

	def BiggestLenOfList()
		return StzListOfNumbersQ(This.NumbersOfItemsInEachList()).Max()

	def BiggestList()
		nMax = This.BiggestLenOfList()
		aPos = StzListQ( This.NumbersOfItemsInEachList() ).FindAll(nMax)

		if len(aPos) = 1
			return This.Content()[aPos[1]]
		else
			aResult = []
			for n in aPos
				aResult + This.Content()[n]
			next

			return aResult
		ok

	def NumbersOfItems()
		anResult = []
		for aList in This.ListOfLists()
			anResult + len(aList)
		next

		return anResult

		def NumbersOfItemsInEach()
			return This.NumberOfItems()

	def AddOneToOne()
		/* Example:

		o1 = stzListOfListsOfNumbersQ([
			[ 3, 6, 3 ],
			[ 2, 1, 3 ],
			[ 2, 0, 1 ]
		])

		o1.AddOneToOne()
		? o1.Content()

		#--> [ 7, 7, 7 ]

		*/

	def Associate() #TODO
	/* Example:

		o1 = new stzListOfListsOfNumbers([
			[ 3, 6, 3 ],
			[ 2, 1, 3 ],
			[ 2, 0, 1 ]
		])

		o1.Associate()
		? o1.Content()

		#--> [
			[ 3, 2, 1 ],
			[ 6, 1, 0 ],
			[ 3, 3, 1 ]
		      ]

		*/

	def Alternate() #TODO
	/* Example:

		o1 = stzListOfListsOfNumbersQ([
			[ 3, 6, 3 ],
			[ 2, 1, 3 ],
			[ 2, 0, 1 ]
		])

		o1.Associate()
		? o1.Content()

		#--> [ 3, 2, 2, 6, 1, 0, 3, 3, 1  ]

		*/
