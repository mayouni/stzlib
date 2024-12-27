
func StzListOfListsOfNumbersQ(paListOfListsOfNumbers)
	return new stzListOfListsOfNumbers(paListOfListsOfNumbers)

func StzListOfNumbersListsQ(paListOfListsOfNumbers)
	return new stzListOfNumbersLists(paListOfListsOfNumbers)

class stzListOfNumbersLists from stzListOfListsOfNumbers

class stzListOfListsOfNumbers from stzListOfLists
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

	def UpdateWith(paList)

		if CheckParams()
			if NOT @IsListOfListsOfNumbers(paList)
				StzRaise("Incorrect param type! paList must be a lists of lists of numbers.")
			ok
		ok

		def Update(paList)
			This.UpdateWith(paList)

	  #------------------------------------------#
	 #  ADJUSTING THE LIST OF PAIRS OF NUMBERS  #
	#------------------------------------------#

	def Complete()
		This.CompeteWith(0)

		def Adjust()
			This.Complete()

	def CompleteWith(n) #TODO
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

		/* ... */

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_aContent_ = This.ToStzListOfLists().AdjustUsingQ(n).Content()
		This.UpdateWith(_aContent_)

		def AdjustWith(n)
			This.CompleteWith(n)

	  #----------------------------------#
	 #  SOME USEFUL CALCULATION 1 BY 1  #
	#----------------------------------#

	def AddOneToOne()
		/* Example:

		o1 = stzListOfListsOfNumbersQ([
			[ 3, 6, 3 ],
			[ 2, 1, 3 ],
			[ 2, 0, 1 ]
		])

		? o1.AddOneToOne()
		#--> [ 7, 7, 7 ]

		*/

		_aAdjusted_ = This.Copy().AdjustWithQ(0).Content()
		_nLen_ = len(_aAdjusted_)
		_nInnerSize_ = len(_aAdjusted_[1])

		_anResult_ = []

		for @j = 1 to _nInnerSize_

			_nSum_ = 0

			for @i = 1 to _nLen_
				_nSum_ += _aAdjusted_[@i][@j] 
			next

			_anResult_ + _nSum_
		next

		return _anResult_

		def Add1To1()
			return This.AddOneToOne()

		def Add11()
			return This.AddOneToOne()

		def SumOf1And1()
			return This.AddOneToOne()

		def Sum1And1()
			return This.AddOneToOne()

		def Sum11()
			return This.AddOneToOne()

	def Multiply1By1()

		def Multiply11()

	def AbsoluteProduct11()

		def AbsProd11()

	#----------------

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

		/* ... */

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
