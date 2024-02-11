#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - StzListOfNumbers		    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing lists of numbers      #
#	Version		: V1.0 (2020-2023)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

/*
Short term objective:
	Max() Min() Mean() Sum()
	
	Correlation()
	Covariance()
	AverageDeviation()
	StandardDeviation()
	StandardDeviationP()
	StatError()
	Variance()
	VarianceP()

Long terme objective:
Support all the features of NumPy
	Array Creation:
	arange, array, copy, empty, empty_like, eye, fromfile, fromfunction, identity, linspace, logspace, mgrid, ogrid, ones, ones_like, r_, zeros, zeros_like
	
	Conversions:
	ndarray.astype, atleast_1d, atleast_2d, atleast_3d, mat
	
	Manipulations:
	array_split, column_stack, concatenate, diagonal, dsplit, dstack, hsplit, hstack, ndarray.item, newaxis, ravel, repeat, reshape, resize, squeeze, swapaxes, take, transpose, vsplit, vstack
	
	Questions:
	all, any, nonzero, where
	
	Ordering:
	argmax, argmin, argsort, max, min, ptp, searchsorted, sort
	
	Operations:
	choose, compress, cumprod, cumsum, inner, ndarray.fill, imag, prod, put, putmask, real, sum
	
	Basic Statistics:
	cov, mean, std, var
	
	Basic Linear Algebra:
	cross, dot, outer, linalg.svd, vdot
*/

  ///////////////////
 ///  FUNCTIONS  ///
///////////////////

func StzListOfNumbersQ(paListOfNumbers)
	return new stzListOfNumbers(paListOfNumbers)

	func StzNumbersQ(paList)
		return StzListOfNumbersQ(paListOfNumbers)

func IsListOfNumbers(paList)
	if CheckParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	bResult = TRUE
	nLen = len(paList)

	for i = 1 to nLen
		if NOT isNumber(paList[i])
			bResult = FALSE
			exit
		ok
	next i

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfNumbers(paList)
		return IsListOfNumbers(paList)

	func ListIsListOfNumbers(paList)
		return IsListOfNumbers(paList)

	#--

	func IsAListOfNumbers(paList)
		return IsListOfNumbers(paList)

	func @IsAListOfNumbers(paList)
		return IsListOfNumbers(paList)

	func ListIsAListOfNumbers(paList)
		return IsListOfNumbers(paList)

	#>

func LN(p)
	if isList(p)
		return StzListQ(p).OnlyNumbers()

	but isString(p) and Q(p).IsListInString()
		aResult = Q(p).ToListQ().OnlyNumbers()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + 0
		next
		return aResult

	ok

	func LNQ(p)
		return Q(LN(p))

		func QLN(p)
			return LNQ(p)

	func LoN(p)
		return LN(p)

		func LoNQ(p)
			return LNQ(p)

func NumbersUnicodes(anNumbers)
	return StzListOfNumbersQ(anNumbers).Unicodes()

func Min(panNumbers)

	if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
		StzRaise("Incorrect param! panNumbers must be a list of numbers!")
	ok

	nResult = StzListOfNumbersQ(panNumbers).Min()
	return nResult

func Max(panNumbers)

	if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
		StzRaise("Incorrect param! panNumbers must be a list of numbers!")
	ok

	nResult = StzListOfNumbersQ(panNumbers).Max()
	return nResult

func Sum(panNumbers)
	oListOfNumbers = new stzListOfNumbers(panNumbers)
	return oListOfNumbers.Sum()

func Product(panNumbers)
	oListOfNumbers = new stzListOfNumbers(panNumbers)
	return oListOfNumbers.Product()

func MultiplicationsYieldingN(n)
	aResult = []
			
	aFactors = reverse(factors(n))

	for i = 1 to len(aFactors)
		aResult + [ factors(n)[i] , aFactors[i] ]
	next i

	return aResult

func MultiplicationsYielding(n)
	return MultiplicationsYieldingN(n)

func MultiplicationsYieldingN_WithoutCommutation(n)
	aResult = []
			
	aFactors = reverse(factors(n))

	for i = 1 to len(aFactors)-1
		if i > 1
			if factors(n)[i] = aFactors[i-1]
				exit
			ok
		ok
		aResult + [ factors(n)[i] , aFactors[i] ]

	next i

	return aResult

func NumbersXT(n1, n2)
	if isList(n1) and Q(n1).IsOneOfTheseNamedParams([ :Between, :From ])
		n1 = n1[2]
	ok

	if isList(n2) and Q(n2).IsOneOfTheseNamedParams([ :And, :To ])
		n2 = n2[2]
	ok

	if NOT BothAreNumbers(n1, n2)
		StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
	ok

	anResult = n1 : n2
	return anResult

	func NumbersBetweenXT(n1, n2)
		return NumbersXT(n1, n2)
	
	func NumbersIB(n1, n2)
		returnNumbersXT(n1, n2)
	
	func NumbersBetweenIB(n1, n2)
		return NumbersXT(n1, n2)

func Numbers(n1, n2)
	if isList(n1) and Q(n1).IsOneOfTheseNamedParams([ :Between, :From ])
		n1 = n1[2]
	ok

	if isList(n2) and Q(n2).IsOneOfTheseNamedParams([ :And, :To ])
		n2 = n2[2]
	ok

	if NOT BothAreNumbers(n1, n2)
		StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
	ok

	anResult = []

	if n1 = n2
		anResult + n1

	but n1 < n2
		for i = 1 to n2
			aResult + i
		next

	else
		for i = 1 to n2 step -1
			aResult + i
		next
	ok

	return anResult

	func NumbersBetween(nMin, nMax)
		return Numbers(nMin, nMax)

func CommonNumbers(paListsOfNumbers)
	if NOT ( isList(paListsOfNumbers) and Q(paListsOfNumbers).IsListOfListsOfNumbers())
		StzRaise("Incorrect param type! paListsOfNumbers must be a list of lists of numbers.")
	ok

	return CommonItems(paListsOfNumbers)

	def CommunNumbers(paListsOfNumbers)
		return CommonNumbers(paListsOfNumbers)

  ////////////////
 ///  CLASS   ///
////////////////

class stzNumbers from stzListOfNumbers

class stzListOfNumbers from stzList
	@anContent

	// TODO: Add the possibility to add a list of numbers in strings
	// --> So we can manage numbers as stzNumbers (wich can be provided
	// in strings to conserve their round.
	def init(paList)
		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfNumbers() )

			@anContent = paList

		but isString(paList)
			try
				aList = Q(paList).ToList()
				if StzListQ(aList).IsListOfNumbers()
					@anContent = aList
				else
					StzRaise("The list in the string you provided is not a list of numbers!")
				ok

			catch
				StzRaise("Can't transform the string into a llist of numbers!")
			done
		else
			StzRaise("Can't create a stzListOfNumbers object!")
		ok

	def Content()
		aResult = @anContent

		return aResult

		def Value()
			return Content()

	def Copy()
		return new stzListOfNumbers(This.Content())

	def ListOfNumbers()
		return Content()

		def Numbers()
			return This.Content()

			def NumbersQ()
				return This.NumbersQR(:stzList)

			def NumbersQR(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Numbers() )

				on :stzListOfStrings
					return new stzListOfStrings( This.Numbers() )

				other
					StzRaise("Unsupported return type!")
				off

	def NumbersW(pcCondition)
		return This.YieldW('@number', pcCondition)

		def NumbersWQ(pcCondition)
			return NumbersWQR(pcCondition, :stzList)

		def NumbersWQR(pcCondition, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumbersW(pcCondition) )

			on :stzListOfNumbers
				return new stzListOfStrings( This.NumbersW(pcCondition) )

			other
				StzRaise("Unsupported return type!")
			off

	def ToStzList()
		return new stzList(This.Content())

	def ToStzListOfStrings()
		anContent = This.Content()
		nLen = len(anContent)

		acStrings = []

		for i = 1 to nLen
			acStrings + ( ""+ anContent[i] )
		next

		oResult = new stzListOfStrings(acResult)
		return oResult

	def NumbersTurnedToStrings()
		aResult = This.ToStzListOfStrings().Content()

		return aResult

		def Stringified()
			return This.NumbersTurnedToStrings()

		def AllNumbersTurnedToStrings()
			return This.NumbersTurnedToStrings()

	def NumberAt(n)
		return This.ItemAt(n)	# Inherited from stzList

		def NumberAtPosition(n)
			return This.NumberAt(n)

		def Number(n)
			return This.NumberAt(n)

	  #-------------------------#
	 #     MAXIMUM NUMBER(S)   #
	#-------------------------#

	def Max()
		if len(This.Content()) = 0
			StzRaise("Can't proceed! Because the list is empty.")
		ok

		aSorted = This.Sorted()
		nLen = len(aSorted)
		nResult = aSorted[nLen]
		return nResult

		def MaxQ(n)
			return This.MaxQR(n, :stzNumber)

		def MaxQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzNumber
				return new stzNumber( This.Max() )

			on :stzString
				return new stzString( This.Max() )

			other
				StzRaise("Unsupported return type!")
			off

		def MaxNumber()
			return This.Max()

			def MaxNumberQ(n)
				return This.MaxNumberQR(n, :stzNumber)
	
			def MaxNumberQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzNumber
					return new stzNumber( This.MaxNumber(n) )
	
				on :stzString
					return new stzString( This.MaxNumber(n) )
	
				other
					StzRaise("Unsupported return type!")
				off

	def FindMax()
		nMax = This.Max()
		anResult = This.FindAll(nMax)
		return anResult

		def FindAllMax()
			return This.FindMax()
		return aResult

		#< @FunctionAlternativeForms

		def FindMaxNumber()
			return This.FindMax()

		def MaxPosition()
			return This.FindMAx()

		def PositionOfMaxNumber()
			return This.FindMax()

		def MaxNumberPosition()
			return This.FindMax()

		def FindGreatestNumber()
			return This.FindMax()

		def FindLargestNumber()
			return This.FindMax()

		#>

	def Top(n)
		aResult = This.ToStzList().RemoveDuplicatesQ().SortInAscendingQ().Section(1, n)

		return aResult

		def TopQ(n)
			return This.TopQR(n, :stzList)
	
		def TopQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Top(n) )
	
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Top(n) )

			on :stzListOfStrings
				return StzListOfNumbersQ(This.Top(n)).ToStzListOfStrings()

			other
				StzRaise("Unsupported return type!")
			off

		#>

		def TopNumbers(n)
			return This.Top(n)
	
			def TopNumbersQ(n)
				return This.TopNumbersQR(n, :stzList)
	
			def TopNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.TopNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.TopNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.TopNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off
	
		def NTopNumbers(n)
			return This.Top(n)

			def NTopNumbersQ(n)
				return This.NTopNumbersQR(n, :stzList)
	
			def NTopNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.NTopNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NTopNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.NTopNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def TopNNumbers(n)
			return This.Top(n)

			def TopNNumbersQ(n)
				return This.TopNNumbersQR(n, :stzList)
	
			def TopNNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.TopNNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.TopNNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.TopNNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def MaxNumbers(n)
			return This.Top(n)
	
			#< @FunctionFluentForm
	
			def MaxNumbersQ(n)
				return This.MaxNumbersQR(n, :stzList)
	
			def MaxNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.MaxNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.MaxNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.MaxNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def MaxNNumbers(n)
			return This.Top(n)

			def MaxNNumbersQ(n)
				return This.MaxNNumbersQR(n, :stzList)
	
			def MaxNNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.MaxNNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.MaxNNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.MaxNNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def NMaxNumbers(n)
			return This.Top(n)

			def NMaxNumbersQ(n)
				return This.NMaxNumbersQR(n, :stzList)
	
			def NMaxNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.NMaxNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NMaxNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.NMaxNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off
		#>

	def TopTenNumbers()
		return This.Top(10)

		def Top10Numbers()
			return This.TopTenNumbers()

		def TopTen()
			return This.TopTenNumbers()

		def Top10()
			return This.TopTenNumbers()

	def TopFiveNumbers()
		return This.Top(5)
		
		def Top5Numbers()
			return This.TopFiveNumbers()

		def TopFive()
			return This.TopFiveNumbers()

		def Top5()
			return This.TopFiveNumbers()

	def TopThreeNumbers()
		return This.Top(3)

		def Top3Numbers()
			return This.TopThreeNumbers()

		def TopThree()
			return This.TopThreeNumbers()

		def Top3()
			return This.TopThreeNumbers()

	def FindTop(n)
		anNumbers = This.Top(n)
		nLen = len(anNumbers)

		aResult = []

		for i = 1 to nLen
			aResult + This.FindAll(anNumbers[i])
		next

		aResult = StzListQ(aResult).FlattenQ().SortedInAscending()

		return aResult

		#< @FunctionAlternativeForms

		def FindMaxNumbers(n)
			return This.FindTop(n)

		def FindTopNumbers(n)
			return This.FindTop(n)

		def FindTopNNumbers(n)
			return This.FindTop(n)

		#--

		def FindNGreatestNumbers(n)
			return This.FindTop(n)

		def FindGreatestNNumbers(n)
			return This.FindTop(n)

		def FindGreatestN(n)
			return This.FindTop(n)

		def FindNLargestNumbers(n)
			return This.FindTop(n)

		def FindLargestNNumbers(n)
			return This.FindTop(n)

		def FindLargestN(n)
			return This.FindTop(n)

		#--

		def FindNGreatest(n)
			return This.FindTop(n)

		def PositionsOfTop(n)
			return This.FindTop(n)

		def TopPositions(n)
			return This.FindTop(n)

		def PositionsOfTopNumbers(n)
			return This.FindTop(n)

		def TopNumbersPositions()
			return This.FindTop(n)

		def PositionsOfTopNNumbers(n)
			return This.FindTop(n)

		def TopNNumbersPositions(n)
			return This.FindTop(n)

		#>


	def TopNumbersAndTheirPositions(n)

		anNumbers = This.Top(n)
		nLen = len(anNumbers)

		aResult = []

		for i = 1 to nLen

			cNumber     = ""+ anNumbers[i]
			anPositions = This.ToStzList().FindAll(anNumbers[i])

			aResult + [ cNumber, anPositions ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def TopNNumbersAndTheirPositions(n)
			return This.TopNumbersAndTheirPositions(n)

		def MaxNumbersAndTheirPositions(n)
			return This.TopNumbersAndTheirPositions(n)

		#--

		def TopNumbersZ(n)
			return This.TopNumbersAndTheirPositions(n)

		def TopNNumbersZ(n)
			return This.TopNumbersAndTheirPositions(n)

		def MaxNumbersZ(n)
			return This.TopNumbersAndTheirPositions(n)

		def TopZ(n)
			return This.TopNumbersAndTheirPositions(n)

		def MaxZ(n)
			return This.TopNumbersAndTheirPositions(n)

		#>

	  #-------------------------#
	 #     MINIMUM NUMBER(S)   #
	#-------------------------#

	def Min()
		if len(This.Content()) = 0
			StzRaise("Can't proceed! Because the list is empty.")
		ok

		aSorted = This.Sorted()
		nLen = len(aSorted)
		nResult = aSorted[1]
		return nResult

		def MinQ(n)
			return This.MinQR(n, :stzNumber)

		def MinQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzNumber
				return new stzNumber( This.Min() )

			on :stzString
				return new stzString( This.Min() )

			other
				StzRaise("Unsupported return type!")
			off

		def MinNumber()
			return This.Min()

			def MinNumberQ(n)
				return This.MinNumberQR(n, :stzNumber)
	
			def MinNumberQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzNumber
					return new stzNumber( This.MinNumber(n) )
	
				on :stzString
					return new stzString( This.MinNumber(n) )
	
				other
					StzRaise("Unsupported return type!")
				off

	def FindMin()
		nMin = This.Min()
		anResult = This.FindAll(nMin)
		return anResult

		def FindAllMin()
			return This.FindMin()
		return aResult

		#< @FunctionAlternativeForms

		def FindMinNumber()
			return This.FindMin()

		def MinPosition()
			return This.FindMAx()

		def PositionOfMinNumber()
			return This.FindMin()

		def MinNumberPosition()
			return This.FindMin()

		def FindSmallestNumber()
			return This.FindMin()

		def FindLowestNumber()
			return This.FindMin()

		#>

	def Bottom(n)
		aResult = This.ToStzList().RemoveDuplicatesQ().SortInDescendingQ().Section(1, n)

		return aResult

		def BottomQ(n)
			return This.BottomQR(n, :stzList)
	
		def BottomQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Bottom(n) )
	
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Bottom(n) )

			on :stzListOfStrings
				return StzListOfNumbersQ(This.Bottom(n)).ToStzListOfStrings()

			other
				StzRaise("Unsupported return type!")
			off

		#>

		def BottomNumbers(n)
			return This.Bottom(n)
	
			def BottomNumbersQ(n)
				return This.BottomNumbersQR(n, :stzList)
	
			def BottomNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.BottomNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.BottomNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.BottomNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off
	
		def NBottomNumbers(n)
			return This.Bottom(n)

			def NBottomNumbersQ(n)
				return This.NBottomNumbersQR(n, :stzList)
	
			def NBottomNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.NBottomNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NBottomNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.NBottomNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def BottomNNumbers(n)
			return This.Bottom(n)

			def BottomNNumbersQ(n)
				return This.BottomNNumbersQR(n, :stzList)
	
			def BottomNNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.BottomNNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.BottomNNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.BottomNNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def MinNumbers(n)
			return This.Bottom(n)
	
			#< @FunctionFluentForm
	
			def MinNumbersQ(n)
				return This.MinNumbersQR(n, :stzList)
	
			def MinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.MinNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.MinNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.MinNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def MinNNumbers(n)
			return This.Bottom(n)

			def MinNNumbersQ(n)
				return This.MinNNumbersQR(n, :stzList)
	
			def MinNNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.MinNNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.MinNNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.MinNNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def NMinNumbers(n)
			return This.Bottom(n)

			def NMinNumbersQ(n)
				return This.NMinNumbersQR(n, :stzList)
	
			def NMinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.NMinNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NMinNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.NMinNumbers(n)).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off
		#>

	def BottomTenNumbers()
		return This.Bottom(10)

		def Bottom10Numbers()
			return This.BottomTenNumbers()

		def BottomTen()
			return This.BottomTenNumbers()

		def Bottom10()
			return This.BottomTenNumbers()

	def BottomFiveNumbers()
		return This.Bottom(5)
		
		def Bottom5Numbers()
			return This.BottomFiveNumbers()

		def BottomFive()
			return This.BottomFiveNumbers()

		def Bottom5()
			return This.BottomFiveNumbers()

	def BottomThreeNumbers()
		return This.Bottom(3)

		def Bottom3Numbers()
			return This.BottomThreeNumbers()

		def BottomThree()
			return This.BottomThreeNumbers()

		def Bottom3()
			return This.BottomThreeNumbers()

	def FindBottom(n)
		anNumbers = This.Bottom(n)
		nLen = len(anNumbers)

		aResult = []

		for i = 1 to nLen
			aResult + This.FindAll(anNumbers[i])
		next

		aResult = stzListQ(aResult).FlattenQ().SortedInAscending()

		return aResult

		#< @FunctionAlternativeForms

		def FindMinNumbers(n)
			return This.FindBottom(n)

		def FindBottomNumbers(n)
			return This.FindBottom(n)

		def FindBottomNNumbers(n)
			return This.FindBottom(n)

		#--

		def FindNSmallestNumbers(n)
			return This.FindBottom(n)

		def FindSmallestNNumbers(n)
			return This.FindBottom(n)

		def FindSmallestN(n)
			return This.FindBottom(n)

		def FindNLowestNumbers(n)
			return This.FindBottom(n)

		def FindLowestNNumbers(n)
			return This.FindBottom(n)

		def FindLowestN(n)
			return This.FindBottom(n)

		#--

		def FindNSmallest(n)
			return This.FindBottom(n)

		def PositionsOfBottom(n)
			return This.FindBottom(n)

		def BottomPositions(n)
			return This.FindBottom(n)

		def PositionsOfBottomNumbers(n)
			return This.FindBottom(n)

		def BottomNumbersPositions()
			return This.FindBottom(n)

		def PositionsOfBottomNNumbers(n)
			return This.FindBottom(n)

		def BottomNNumbersPositions(n)
			return This.FindBottom(n)

		#>


	def BottomNumbersAndTheirPositions(n)

		anNumbers = This.Bottom(n)
		nLen = len(anNumbers)

		aResult = []

		for i = 1 to nLen

			cNumber     = ""+ anNumbers[i]
			anPositions = This.ToStzList().FindAll(anNumbers[i])

			aResult + [ cNumber, anPositions ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def BottomNNumbersAndTheirPositions(n)
			return This.BottomNumbersAndTheirPositions(n)

		def MinNumbersAndTheirPositions(n)
			return This.BottomNumbersAndTheirPositions(n)

		#--

		def BottomNumbersZ(n)
			return This.BottomNumbersAndTheirPositions(n)

		def BottomNNumbersZ(n)
			return This.BottomNumbersAndTheirPositions(n)

		def MinNumbersZ(n)
			return This.BottomNumbersAndTheirPositions(n)

		def BottomZ(n)
			return This.BottomNumbersAndTheirPositions(n)

		def MinZ(n)
			return This.BottomNumbersAndTheirPositions(n)

		#>

	  #==========================================================================#
	 #  NEAREST NUMBER IN THE LIST TO A GIVEN NUMBER COMING BEFORE OR AFTER IT  #
	#==========================================================================#

	def NearestXT(n, pcBeforeOrAfter)

		# Checking the n param

		if isList(n) and Q(n).IsToNamedParam()
			n = n[2]
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Checking the pcBeforeOrAfter param

		if isList(pcBeforeOrAfter) and
		   Q(pcBeforeOrAfter).IsComingNamedParam()

			pcBeforeOrAfter = pcBeforeOrAfter[2]
		ok

		if NOT 	( isString(pcBeforeOrAfter) and
			  Q(pcBeforeOrAfter).IsOneOfThese([
				:Before, :After, :BeforeIt, :AfterIt,
				:BeforeOrAfter, :BeforeOrAfterIt,
				:AfterOrBefore, :AfterOrBeforeIt,

				:ComingBefore, :ComingAfter, :ComingBeforeIt, :ComingAfterIt,
				:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
				:ComingAfterOrBefore, :ComingAfterOrBeforeIt

			  ]) )

			StzRaise("Incorrect param type! pcComingBeforeOrAfter must be a string equal to :Before, :After, or :BeforeOrAfter.")

		ok

		# Doing the job

		if Q( pcBeforeOrAfter ).IsOneOfThese([
			:BeforeOrAfter, :BeforeOrAfterIt,
			:AfterOrBefore, :AfterOrBeforeIt,

			:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
			:ComingAfterOrBefore, :ComingAfterOrBeforeIt
			])

			nResult = This.NearestTo(n)

		but Q( pcBeforeOrAfter ).IsOneOfThese([
			:Before, :BeforeIt,
			:ComingBefore, :ComingBeforeIt
			])

			anPair = This.NeighborsOf(n)
			nResult = anPair[1]

		but Q( pcBeforeOrAfter ).IsOneOfThese([
			:After, :AfterIt,
			:ComingAfter, :ComingAfterIt
			])

			anPair = This.NeighborsOf(n)
			nResult = anPair[2]

		else # Impossible case, but let's deal with it
			StzRaise("Syntax error!")
		ok

		return nResult

		#< @FunctionAlternativeForm

		def NearestToXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		#--

		def NearestNumberXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		def NearestNumberToXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		#==

		def ClosestXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		def ClosestToXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		#--

		def ClosestNumberXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		def ClosestNumberToXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)


		#>

		#< @FunctionMisspelledForm

		def NearstXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		def NearstToXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		#--

		def NearstNumberXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		def NearstNumberToXT(n, pcBeforeOrAfter)
			return This.NearestXT(n, pcBeforeOrAfter)

		#>

	  #---------------------------------------------------------------------------#
	 #  FARTHEST NUMBER IN THE LIST TO A GIVEN NUMBER COMING BEFORE OR AFTER IT  #
	#---------------------------------------------------------------------------#

	def FarthestXT(n, pcBeforeOrAfter)

		# Checking the n param

		if isList(n) and Q(n).IsToNamedParam()
			n = n[2]
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Checking the pcBeforeOrAfter param

		if isList(pcBeforeOrAfter) and
		   Q(pcBeforeOrAfter).IsComingNamedParam()

			pcBeforeOrAfter = pcBeforeOrAfter[2]
		ok

		if NOT ( isString(pcBeforeOrAfter) and
			  Q(pcBeforeOrAfter).IsOneOfThese([
				:Before, :After, :BeforeIt, :AfterIt,
				:BeforeOrAfter, :BeforeOrAfterIt,
				:AfterOrBefore, :AfterOrBeforeIt,

				:ComingBefore, :ComingAfter, :ComingBeforeIt, :ComingAfterIt,
				:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
				:ComingAfterOrBefore, :ComingAfterOrBeforeIt

			  ]) )

			StzRaise("Incorrect param type! pcComingBeforeOrAfter must be a string equal to :Before, :After, or :BeforeOrAfter.")

		ok

		# Doing the job

		if Q( pcBeforeOrAfter ).IsOneOfThese([
			:BeforeOrAfter, :BeforeOrAfterIt,
			:AfterOrBefore, :AfterOrBeforeIt,

			:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
			:ComingAfterOrBefore, :ComingAfterOrBeforeIt
			])

			nResult = This.FarthestTo(n)

		but Q( pcBeforeOrAfter ).IsOneOfThese([
			:Before, :BeforeIt,
			:ComingBefore, :ComingBeforeIt
			])

			anSorted = This.ToSetQ().Sorted()
			nLen = len(anSorted)
			
			if nLen = 0
				return NULL

			but nLen = 1
				if anSorted[1] = n
					return NULL

				else
					return anSorted[1]
				ok

			else
				nPos = ring_find(anSorted, n)

				if nPos > 1
					nFirst = anSorted[1]
					nLast  = anSorted[nLen]

					nDif1 = abs(n - nFirst)
					nDif2 = abs(n - nLast)

					if nDif1 > nDif2
						return nLast
					else
						return nFirst
					ok

				else
					return NULL
				ok

			ok

		but Q( pcBeforeOrAfter ).IsOneOfThese([
			:After, :AfterIt,
			:ComingAfter, :ComingAfterIt
			])

			anSorted = This.ToSetQ().Sorted()
			nLen = len(anSorted)

			if nLen = 0
				return NULL

			but nLen = 1
				if anSorted[1] = n
					return NULL

				else
					return anSorted[1]
				ok

			else
				nPos = ring_find(anSorted, n)

				if nPos > 0 and nPos < nLen
					nFirst = anSorted[1]
					nLast  = anSorted[nLen]

					nDif1 = abs(n - nFirst)
					nDif2 = abs(n - nLast)

					if nDif1 > nDif2
						return nFirst
					else
						return nLast
					ok

				else
					return NULL
				ok

			ok		

		ok

		return nResult

		#< @FunctionAlternativeForm

		def FarthestToXT(n, pcBeforeOrAfter)
			return This.FarthestXT(n, pcBeforeOrAfter)

		#>

		#< @FunctionMisspelledForm

		def FarthstXT(n, pcBeforeOrAfter)
			return This.FarthestXT(n, pcBeforeOrAfter)

		def FarthstToXT(n, pcBeforeOrAfter)
			return This.FarthestXT(n, pcBeforeOrAfter)

		#--

		def FarthestNumberXT(n, pcBeforeOrAfter)
			return This.FarthestXT(n, pcBeforeOrAfter)

		def FarthstNumberXT(n, pcBeforeOrAfter)
			return This.FarthestXT(n, pcBeforeOrAfter)

		def FarthstNumberToXT(n, pcBeforeOrAfter)
			return This.FarthestXT(n, pcBeforeOrAfter)

		#>

	  #----------------------------------------------------#
	 #     NEAREST NUMBER IN THE LIST TO A GIVEN NUMBER   #
	#----------------------------------------------------#

	def Nearest(n)
		/* EXAMPLE

		? Q([ 2, 7, 18, 10, 25, 4 ]).NearestTo(12)
		#--> 10
		
		*/

		# Checking the n param

		if isList(n) and Q(n).IsToNamedParam()
			n = n[2]
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Doing the job

		anSorted = This.ToSetQ().Sorted()
		nLen = len(anSorted)

		# Case where the list contains only one number
		# (even if duplicated, like in [ 2, 2, 2 ])

		if nLen = 0
			return NULL

		but nLen = 1
			if anSorted[1] = n
				return NULL
			else
				return anSorted[1]
			ok
		ok

		# Case where n exists in the list

		nPos = ring_find(anSorted, n)

		if nPos > 0
			if nPos = 1
				return anSorted[2]

			but nPos = nLen
				return anSorted[nLen - 1]

			else
				nDif1 = abs( n - anSorted[nPos-1] )
				nDif2 = abs( n - anSorted[nPos+1] )

				if nDif1 < nDif2
					return anSorted[nPos-1]
				else
					return anSorted[nPos+1]
				ok
			ok

		# Case where n does not exist in the list

		else

			nNearest = anSorted[1]
			for i = 2 to nLen
	
				nDif2 = abs(n - anSorted[i])
				nDif1 = abs(n - anSorted[i-1])
	
				if nDif2 < nDif1
					nNearest = anSorted[i]
				ok
						
			next
		
			return nNearest
		ok

		#< @FunctionAlternativeForms

		def NearestTo(n)
			return This.Nearest(n)

		#--

		def NearestNumber(n)
			return This.Nearest(n)

		def NearstNumber(n)
			return This.Nearest(n)

		def NearstNumberTo(n)
			return This.Nearest(n)

		#==

		def Closest(n)
			return This.Nearest()

		#--

		def ClosestTo(n)
			return This.Nearest(n)

		#--

		def ClosestNumber(n)
			return This.Nearest(n)

		def ClosestNumberTo(n)
			return This.Nearest(n)

		#>

		#< @MisspelledForms

		def NearstTo(n)
			return This.Nearest(n)

		def Nearst(n)
			return This.Nearest(n)

		#>
	  #---------------------------------------------------#
	 #   FARTHEST NUMBER IN THE LIST TO A GIVEN NUMBER   #
	#---------------------------------------------------#

	def Farthest(n)

		# Checking the n param

		if isList(n) and Q(n).IsToNamedParam()
			n = n[2]
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Doing the job

		anSorted = This.ToSetQ().Sorted()
		nLen = len(anSorted)

		# Case where the list contains only one number
		# (even if duplicated, like in [ 2, 2, 2 ])

		if nLen = 0
			return NULL

		but nLen = 1
			if anSorted[1] = n
				return NULL
			else
				return anSorted[1]
			ok
		ok

		# Case where n exists in the list

		nPos = ring_find(anSorted, n)

		if nPos > 0
			nDif1 = abs( n - anSorted[1] )
			nDif2 = abs( n - anSorted[nLen] )

			if nDif1 > nDif2
				return anSorted[1]
			else
				return anSorted[nLen]
			ok
		
		# Case where n does not extist in the list
		else

			nFarthest = anSorted[1]
			for i = 2 to nLen
	
				nDif2 = abs(n - anSorted[1])
				nDif1 = abs(n - anSorted[nLen])
	
				if nDif2 < nDif1
					nFarthest = anSorted[nLen]
				ok
						
			next
		
			return nFarthest
		ok

		#< @FunctionAlternativeForm

		def FarthestTo(n)
			return This.Farthest(n)

		#--

		def FarthestNumber(n)
			return This.Farthest(n)

		#>

		#< @FunctionMisspelledForms

		def Fartehst(n)
			return This.Farthest(n)

		def FartehstTo(n)
			return This.Farthest(n)

		def Farthst(n)
			return This.Farthest(n)

		def FarthstTo(n)
			return This.Farthest(n)

		#--

		def FartehstNumber(n)
			return This.Farthest(n)

		def FartehstNumberTo(n)
			return This.Farthest(n)

		def FarthstNumber(n)
			return This.Farthest(n)

		def FarthstNumberTo(n)
			return This.Farthest(n)

		#>

	  #-------------------------------------------------------#
	 #  GETTING THE TWO NIGHBORS (IF ANY) OF A GIVEN NUMBER  #
	#-------------------------------------------------------#

	def Neighbors(n)
		/* EXAMPLE

		o1 = new stzListOfNumbers([ 1, 4, 6, 11, 18 ])
		? o1.NeighborsOf(5)
		#--> [4, 6]
		
		*/

		# Checking the n param

		if isList(n) and Q(n).IsToOrOfNamedParam()
			n = n[2]
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Doing the job
	
		anSorted = This.ToSetQ().Sorted()
		nLen = len(anSorted)

		if nLen = 0 or nLen = 1
			return [ NULL, NULL ]
		ok

		nFirst = anSorted[1]
		nLast  = anSorted[nLen]

		if n > nLast
			aResult = [ nLast, NULL ]
			return aResult
	
		but n < nFirst
			aResult = [ NULL, nFirst ]
			return aResult
	
		ok

		nPos = ring_find( anSorted, n )

		if nPos = 0
			return [ NULL, NULL ]
		ok

		if nPos = 1
			aResult = [ NULL, anSorted[2] ]

		but nPos = nLen
			aResult = [ anSorted[nLen-1], NULL ]

		else
			aResult = [ anSorted[nPos-1], anSorted[nPos+1] ]

		ok

		return aResult

		#< @functionAlternativeForm

		def NeighborsOf(n)
			return This.Neighbors(n)

		def NNeighbors(n)
			return This.Neighbors(n)

		def NNeighborsOf(n)
			return This.Neighbors(n)

		def NNeighborsTo(n)
			return This.Neighbors(n)

		#--

		def NeighboringNumbers(n)
			return This.Neighbors(n)

		def NeighboringNumbersOf(n)
			return This.Neighbors(n)

		def NNeighboringNumbers(n)
			return This.Neighbors(n)

		def NNeighboringNumbersOf(n)
			return This.Neighbors(n)

		def NNeighboringNumbersTo(n)
			return This.Neighbors(n)

		#==

		def NearestNeighbors(n)
			return This.Neighbors(n)

		def NearestNeighborsOf(n)
			return This.Neighbors(n)

		def NearestNeighborsTo(n)
			return This.Neighbors(n)

		def NearestNeighboringNumbers(n)
			return This.Neighbors(n)

		def NearestNeighboringNumbersOf(n)
			return This.Neighbors(n)

		def NearestNeighboringNumbersTo(n)
			return This.Neighbors(n)

		#--

		def ClosesestNeighbors(n)
			return This.Neighbors(n)

		def ClosestNeighborsOf(n)
			return This.Neighbors(n)

		def ClosestNeighborsTo(n)
			return This.Neighbors(n)

		def ClosestNeighboringNumbers(n)
			return This.Neighbors(n)

		def ClosestNeighboringNumbersOf(n)
			return This.Neighbors(n)

		def ClosestNeighboringNumbersTo(n)
			return This.Neighbors(n)

		#>

		#< @FunctionMisspelledForms

		def Nighbors(n)
			return NeighborsOf(n)

		def NearestNighbors(n)
			return NeighborsOf(n)

		def NighborsOf(n)
			return NeighborsOf(n)

		def NearestNighborsOf(n)
			return NeighborsOf(n)

		def NighborsTo(n)
			return NeighborsOf(n)

		def NearestNighborsTo(n)
			return NeighborsOf(n)

		#>

	def FarthestNeighbors(n)

		# Checking the n param

		if isList(n) and Q(n).IsToOrOfNamedParam()
			n = n[2]
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Doing the job
	
		anSorted = This.ToSetQ().Sorted()
		nLen = len(anSorted)
			
		if nLen = 0
			return [ NULL, NULL ]
		ok

		nPos = ring_find( anSorted, n )

		if nPos = 0
			return [ NULL, NULL ]
		ok

		n1 = anSorted[1]
		n2 = anSorted[nLen]

		if nPos = 1
			n1 = NULL

		but nPos = nLen
			n2 = NULL
		ok

		anResult = [ n1, n2 ]
		return anResult

		#< @FunctionAlternativeForms

		def FNeighbors(n)
			return This.FarthestNeighbors(n)

		def FarthestNeighborsOf(n)
			return This.FarthestNeighbors(n)

		def FNeighborsOf(n)
			return This.FarthestNeighbors(n)

		def FarthestNeighborsTo(n)
			return This.FarthestNeighbors(n)

		def FNeighborsTo(n)
			return This.FarthestNeighbors(n)


		#--

		def FarthestNeighboringNumbers(n)
			return This.FarthestNeighbors(n)

		def FNeighboringNumbers(n)
			return This.FarthestNeighbors(n)

		def FarthestNeighboringNumbersOf(n)
			return This.FarthestNeighbors(n)

		def FNeighboringNumbersOf(n)
			return This.FarthestNeighbors(n)

		def FarthestNeighboringNumbersTo(n)
			return This.FarthestNeighbors(n)

		def FNeighboringNumbersTo(n)
			return This.FarthestNeighbors(n)

		#>

		#< @FunctionMisspelledForms

		def FarthestNighbors(n)
			return This.FarthestNeighbors(n)

		def FNighbors(n)
			return This.FarthestNeighbors(n)

		def FarthstNeighbors(n)
			return This.FarthestNeighbors(n)

		def FarthstNighbors(n)
			return This.FarthestNeighbors(n)

		#>

	  #======================================================#
	 #  LEAST COMMON NUMBER WITH AN OTHER LIST OF NUMBERS   #
	#======================================================#

	def LeastCommonNumber(panOtherList)
		/* EXAMPLE

		? StzListOfNumbersQ([8, 12, 46, 102]).
			LeastCommonNumber( :With = [4, 6, 12, 89, 102, 122 ] )

		#--> 12
		*/

		if isList(panOtherList) and Q(panOtherList).IsWithNamedParam()
			panOtherList = panOtherList[2]
		ok

		if NOT Q(panOtherList).IsListOfNumbers()
			StzRaise("Incorrect pram type! panOtherList must be a list of numbers.")
		ok

		anThisSorted = This.SortedInAscending()
		anOtherSorted = Q(panOtherList).SortedInAscending()

		anMain = []
		if len(anThisSorted) <= len(anOtherSorted)
			anMain  = anThisSorted
			anOther = anOtherSorted
		else
			anMain  = anOtherSorted
			anOther = anThisSorted
		ok

		nLen = len(anMain)

		for i = 1 to nLen
			if Q(anOther).FindFirst(anMain[i]) > 0
				return anMain[i]
			ok
		next

		StzRaise("There is no Common Numbers at all between the two lists!")

		def LCN(pOtherNumber)
			return This.LeastCommonNumber(pOtherNumber)

		def SmallestCommunNumber(pOtherNumber)
			return This.LeastCommonNumber(pOtherNumber)


	  #------------------------------------------------------#
	 #  LEAST COMMON NUMBER WITH AN OTHER LIST OF NUMBERS   #
	#------------------------------------------------------#

	def GreatestCommonNumber(panOtherList)
		/* EXAMPLE

		? StzListOfNumbersQ([8, 12, 46, 102]).
			GreatestCommonNumber( :With = [4, 6, 12, 89, 102, 122 ] )

		#--> 102
		*/

		if isList(panOtherList) and Q(panOtherList).IsWithNamedParam()
			panOtherList = panOtherList[2]
		ok

		if NOT Q(panOtherList).IsListOfNumbers()
			StzRaise("Incorrect pram type! panOtherList must be a list of numbers.")
		ok

		anThisSorted = This.SortedInDescending()
		anOtherSorted = Q(panOtherList).SortedInDescending()

		anMain = []
		if len(anThisSorted) <= len(anOtherSorted)
			anMain  = anThisSorted
			anOther = anOtherSorted
		else
			anMain  = anOtherSorted
			anOther = anThisSorted
		ok
		nLen = len(anMain)

		for i = 1 to nLen
			if Q(anOther).FindFirst(anMain[i]) > 0
				return anMain[i]
			ok
		next

		StzRaise("There is no Common Numbers at all between the two lists!")

		def GCN(pOtherNumber)
			return This.GreatestCommonNumber(pOtherNumber)

	  #--------------------------------------------#
	 #  THE LEAST COMMON MULTIPLE OF THE NUMBERS  #
	#--------------------------------------------#

	def LeastCommonMultiple()
		if len( This.ListOfNumbers() ) < 2
			StzRaise("Incorrect value! The list must contain at least 2 numbers.")
		ok

		nResult = 0+ StzNumberQ( This.FirstItem() ).LCM( :With = This.Section(2, :LastItem) )

		return nResult

		def LCM()
			return This.LeastCommonMultiple()

	  #----------------------------------------#
	 #     "ABSOLUTING' THE LIST OF NUMBERS   #
	#----------------------------------------#

	def Absolute()
		anContent = This.Content()*
		nLen = len(anContent)

		for i = 1 to nLen
			if anContent[i] < 0
				anContent[i] = -anContent[i]
			ok
		next

		def AbsoluteQ()
			This.Absolute()
			return This

	def Absoluted()
		return This.Copy().AbsoluteQ().Content()

	  #----------------------------------------#
	 #     "NEGATING' THE LIST OF NUMBERS     #
	#----------------------------------------#

	def Negate()
		anContent = This.Content()
		nLen = len(anContent)

		for i = 1 to nLen
			if anContent[i] > 0
				anContent[i] = -anContent[i]
			ok
		next

		def NegateQ()
			This.Negate()
			return This

	def Negated()
		return This.Copy().NegateQ().Content()

	  #---------------------------#
	 #     BASIC CALCULATIONS    #
	#---------------------------#

	def Product()
		nResult = 1
		nLen = This.NumberOfItems()
		anContent = This.Content()

		for i = 1 to nLen
			nResult *= anContent[i]
		next

		return nResult

	def Sum()
		nResult = 0
		nLen = This.NumberOfItems()
		anContent = This.Content()

		for i = 1 to nLen
			nResult += anContent[i]
		next
		return nResult

	def Mean()
		return Sum() / (This.NumberOfNumbers())

	def MeanByCoefficient(paList)
		// [ 16, 18, 20, 17 ]
		// [  4,  2,  2,  1 ]
		i = 0

		aProduct = []
		for i=1 to This.NumberOfNumbers()
			aProduct + This.ListOfNumbers()[i] * paList[i]
		next

		oTempList = new steListOfNumbers(aProduct)
		oCoefList = new steListOfNumbers(paList)

		nResult = oTempList.Sum() / oCoefList.Sum()

		return nResult

	  #---------------------------------------#
	 #     CONTAINING DIVIDABLE NUMBER BY    #
	#---------------------------------------#

	def ContainsADividableNumberBy(n)
		oNumber = new stzNumber( This.Product() )

		if oNumber.IsDividableBy(n)
			return TRUE
		else
			return FALSE
		ok

	def DividableNumbersBy(n)
		anContent = This.Content()
		nLen = len(anContent)

		aResult = []

		for i = 1 to nLen
			n = anContent[i]
			oNumber = new stzNumber(n)
			if oNumber.IsDividableBy(n)
				aResult + n
			ok
		next

		return aResult

	  #--------------------------------------#
	 #     CLIPPING THE LIST OF NUMBERS     #
	#--------------------------------------#

	# Limits the values of the list by adjusting the numbers outside
	# the provided range (nMin, nMax). Each number lesser then nMin
	# becomes equal to nMin. And each number greater then nMax becomes
	# equal to nMax.

	def Clip(nMin, nMax)
		/*
		o1 = new stzListOfNumbers([1, 2, 3, 4, 5, 6, 7, 8 ])
		? o1.Clip(3, 5)
		// --> Should return: [ 3, 3, 3, 4, 5, 5, 5, 5, 5 ])
		*/

		anContent = This.Content()
		nLen = len(anContent)

		for i = 1 to nLen
			n = anContent[i]

			if n < nMin
				n = nMin
			but n > nMax
				n = nMax
			ok
		next

		def ClipQ(nMin, nMax)
			return This.ClipQR(nMin, nMax, pcReturnType)

		def ClipQR(nMin, nMax, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Clip(nMin, nMax) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Clip(nMin, nMax) )

			other
				StzRaise("Unsupported return type!")
			off

	  #-----------------------------------------#
	 #     REPLACING A SECTION OF THE LIST     #
	#-----------------------------------------#

	def ReplaceSectionWith(n1, n2, n)
		for i = 1 to This.NumberOfNumber()
			if i >= n1 and i <= n2
				This.Content()[i] = n
			ok
		next
		
		def ReplaceSectionWithQ(n1, n2, n)
			return This.ReplaceSectionWithQR(n1, n2, n)

		def ReplaceSectionWithQR(n1, n2, n)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ReplaceSectionWith(n1, n2, n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.ReplaceSectionWith(n1, n2, n) )

			other
				StzRaise("Unsupported return type!")
			off

	  #----------------------------#
	 #     CUMULATING NUMBERS     #
	#----------------------------#

	def Cumulate()
		aResult = []
		nLen = This.Content()
		for i = 3 to nLen
			@anContent[i] += @anContent[i-1]
		next
			
		def CumulateQ()
			return This.CumulateQR()

		def CumulateQR()
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Cumulate() )

			on :stzListOfNumbers
				return new stzList( This.Cumulate(n1) )

			other
				StzRaise("Unsupported return type!")
			off

	def Cumulated()
		anResult = This.Copy().CumulateQ().Content()
		return anResult

	  #-------------------------------------------------------------#
	 #  GETTING ONLY UNICODE NUMBERS AMONG THE NUMBER IN THE LIST  #
	#-------------------------------------------------------------#

	def OnlyUnicodes()
		anContent = This.Content()
		nLen = len(anContent)

		aResult = []

		for i = 1 to nLen
			n = anContent[i]

			if IsUnicodeNumber(n)
				aResult + n
			ok
		next

		return aResult

		#< @FunctionFluentForm

		def OnlyUnicodesQ()
			return This.CumulateQR(:stzList)

		def OnlyUnicodesQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.OnlyUnicodes() )
	
			on :stzListOfNumbers
				return new stzList( This.OnlyUnicodes() )
	
			other
				StzRaise("Unsupported return type!")
			off

		#>

	  #========================================#
	 #     ADDING A NUMBER TO EACH NUMBER     #
	#========================================#

	def AddToEach(n)
		
		anContent = This.Content()

		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			anResult + (anContent[i] + n)
		next

		This.Update(anResult)

		def AddToEachQ(n)
			This.AddToEach(n)
			return This

	def AddedToEach(n)
		anResult = This.Copy().AddToEachQ(n).Content()
		return anResult

	  #------------------------------------------------#
	 #     SubStructING A NUMBER FROM EACH NUMBER     #
	#------------------------------------------------#

	def SubStructFromEach(n)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			anResult + (anContent[i] - n)
		next

		This.Update(anResult)

		#< @FunctionFluentForm

		def SubStructFromEachQ(n)
			This.SubStructFromEach(n)
			return This

		#>

		#< @FunctionAlternativeForms

		def SubstractFromEach(n)
			This.SubStructFromEach(n)

		def SubtractFromEach(n)
			This.SubStructFromEach(n)

		def SubtructFromEach(n)
			This.SubStructFromEach(n)

		#>

	def SubStructedFromEach(n)
		anResult = This.Copy().SubStructFromEachQ(n).Content()
		return anResult

		#< @FunctionAlternativeForms

		def SubstractedFromEach(n)
			return This.SubStructFromEach(n)

		def SubtractedFromEach(n)
			return This.SubStructFromEach(n)

		def SubtructedFromEach(n)
			return This.SubStructFromEach(n)

		#>

	  #---------------------------------------------#
	 #     MULTIPLYING EACH NUMBER BY A NUMBER     #
	#---------------------------------------------#

	def MultiplyEachBy(n)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			anResult + (anContent[i] * n)
		next

		This.Update(anResult)

		def MultiplyEachByQ(n)
			This.MultiplyEachBy(n)
			return This

	def EachMultipliedBy(n)
		anResult = This.Copy().MultiplyEachByQ(n).Content()
		return anResult

	  #------------------------------------------#
	 #     DIVIDING EACH NUMBER BY A NUMBER     # 
	#------------------------------------------#

	def DivideEachBy(n)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			anResult + (anContent[i] / n)
		next

		This.Update(anResult)

		def DivideEachByQ(n)
			This.DivideEachBy(n)
			return This

	def EachDividedBy(n)
		anResult = This.Copy().DivideEachByQ(n).Content()
		return anResult

	  #====================================#
	 #   ADDING MANY NUMBERS ONE BY ONE   #
	#====================================#

	def AddManyOneByOne(paNumbers)

		if NOT ( isList(paNumbers) and Q(paNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		anContent = This.Content()
		nLen1 = This.NumberOfNumbers()
		nLen2 = len(paNumbers)

		nLen = nLen1
		if nLen2 < nLen1
			nLen = nLen2
		ok

		anResult = []

		for i = 1 to nLen
			nSum = anContent[i] + paNumbers[i]
			anResult + nSum
		next

		This.Update(anResult)

		def AddManyOneByOneQ(paNumbers)
			This.AddManyOneByOne(paNumbers)
			return This

	def ManyAddOneByOne(paNumbers)
		anResult = This.Copy().AddManyOneByOneQ(n).Content()
		return anResult

	  #------------------------------------------#
	 #   SubStructING MANY NUMBERS ONE BY ONE   #
	#------------------------------------------#

	def SubStructManyOneByOne(paNumbers)

		if NOT ( isList(paNumbers) and Q(paNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		if NOT ( isList(paNumbers) and Q(paNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		anContent = This.Content()
		nLen1 = This.NumberOfNumbers()
		nLen2 = len(paNumbers)

		nLen = nLen1
		if nLen2 < nLen1
			nLen = nLen2
		ok

		anResult = []

		for i = 1 to nLen
			nDif = anContent[i] - paNumbers[i]
			anResult + nDif
		next

		This.Update(anResult)

		def SubStructManyOneByOneQ(paNumbers)
			This.SubStructManyOneByOne(paNumbers)
			return This

	def ManySubStructedOneByOne(paNumbers)
		aResult = This.Copy().SubStructManyOneByOneQ(n).Content()
		return aResult

	  #----------------------------------------------------------------------#
	 #   MULTIPLYING THE NUMBERS OF THE LIST WITH MANY NUMBERS ONE BY ONE   #
	#----------------------------------------------------------------------#

	def MultiplyWithManyOneByOne(paNumbers)

		if NOT ( isList(paNumbers) and Q(paNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		anContent = This.Content()
		nLen1 = This.NumberOfNumbers()
		nLen2 = len(paNumbers)

		nLen = nLen1
		if nLen2 < nLen1
			nLen = nLen2
		ok

		anResult = []

		for i = 1 to nLen
			nProd = anContent[i] * paNumbers[i]
			anResult + nProd
		next

		This.Update(anResult)


		def MultiplyWithManyOneByOneQ(paNumbers)
			This.MultiplyWithManyOneByOne(paNumbers)
			return This

		def MultiplyByManyOneByOne(paNumbers)
			return This.MultiplyWithManyOneByOne(paNumbers)

	def MultipliedWithManyOneByOne(paNumbers)
		anResult = This.Copy().MultiplyWithManyOneByOneQ(n).Content()
		return anResult

		def MultipliedByManyOneByOne(paNumbers)
			return This.MultipliedWithManyOneByOne(paNumbers)

	  #-------------------------------------------------------------------#
	 #   DEVIDING THE NUMBERS OF THE LIST WITH MANY NUMBERS ONE BY ONE   #
	#-------------------------------------------------------------------#

	def DivideByManyOneByOne(paNumbers)

		if NOT ( isList(paNumbers) and Q(paNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		anContent = This.Content()
		nLen1 = This.NumberOfNumbers()
		nLen2 = len(paNumbers)

		nLen = nLen1
		if nLen2 < nLen1
			nLen = nLen2
		ok

		anResult = []

		for i = 1 to nLen
			nDiv = anContent[i] / paNumbers[i]
			anResult + nDiv
		next

		This.Update(anResult)

		def DivideByManyOneByOneQ(paNumbers)
			This.DivideByManyOneByOne(paNumbers)
			return This

	def DividedByManyOneByOne(paNumbers)
		anResult = This.Copy().DivideByManyOneByOneQ(n).Content()
		return anResult

	  #===================================================#
	 #   ADDING NUMBER TO EACH UNDER A GIVEN CONDITION   #
	#===================================================#

	def AddToEachW(n, pcCondition)

		# Checking params

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		# Doing the job

		anContent = This.Content()
		nLen = len(anContent)
		if nLen = 0
			return []
		ok

		oCCode = StzCCodeQ(pcCondition)
		aSection = oCCode.ExecutableSection()

		nStart = aSection[1]
		if nStart = :First
			nStart = 1
		ok

		nEnd = aSection[2]
		if nEnd = :Last
			nEnd = nLen
		ok

		cCode = oCCode.Transpiled()
		cCode = 'bOk + (' + cCode + ')'

		anResult = []

		for @i = nStart to nEnd
			eval(cCode)
			if bOk
				anResult + (anContent[@i] + n)
			ok
		next

		This.Update( anResult )

		def AddToEachWQ(n)
			This.AddToEachW(n)
			return This

	def AddedToEachW(n)
		aResult = This.Copy().AddToEachWQ(n).Content()
		return aResult

	  #--------------------------------------------------------#
	 #   SubStruct NUMBER FROM EACH UNDER A GIVEN CONDITION   #
	#--------------------------------------------------------#

	def SubStructFromEachW(n, pcCondition)
		This.AddToEachW(-n, pcCondition)

		def SubStructFromEachWQ(n)
			This.SubStructFromEachW(n)
			return This

	def SubStructedFromEachW(n)
		aResult = This.Copy().SubStructFromEachWQ(n).Content()
		return aResult
	
	  #--------------------------------------------------------------------#
	 #   MULTIPLYING NUMBERS BY AN OTHER NUMBER UNDER A GIVEN CONDITION   #
	#--------------------------------------------------------------------#

	def MultiplyEachWithW(n, pcCondition)

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok


		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		anContent = This.Content()
		nLen = len(anContent)

		cCondition = StzCCodeQ(cCondition).Transpiled()
		cCode = "bOk = (" + cCondition + ")"
		oCode = new stzString(cCode)

		for @i = 1 to nLen
			@number = anContent[i]
			bEval = TRUE

			if @i = nLen and
			   oCode.Copy().RemoveSpacesQ().ContainsCS( "This[i+1]", :CS = FALSE )

				bEval = FALSE

			ok

			if @i = 1 and
			   oCode.Copy().RemoveSpacesQ().ContainsCS( "This[i-1]", :CS = FALSE )

				bEval = TRUE
			ok

			if bEval
				eval(cCode)
				if bOk
					@number *= n
				ok
			ok
		next

		def MultiplyEachWithWQ(n)
			This.MultiplyEachWithW(n)
			return This

		def MultiplyEachByW()
			This.MultiplyEachWithW(n, pcCondition)

			def MultiplyEachByWQ()
				This.MultiplyEachByW()
				return This

	def EachMultipliedWithW(n)
		aResult = This.Copy().MultiplyEachWithWQ(n).Content()
		return aResult

		def EachMultipliedByW(n)
			return This.EachMultipliedWithW(n)

	  #-------------------------------------------------------------------#
	 #   DIVIDE EACH NUMBER BY AN OTHER NUMBER UNDER A GIVEN CONDITION   #
	#-------------------------------------------------------------------#

	def DivideEachWithW(n, pcCondition)
		This.MultiplyEachWithW( 1/n, pcCondition )

		def DivideEachWithWQ(n)
			This.DivideEachWithW(n)
			return This

		def DivideEachByW(n, pcCondition)
			This.DivideEachWithW(n, pcCondition)

	def EachDividedWithW(n)
		aResult = This.Copy().DivideEachWithWQ(n).Content()
		return aResult

		def EachDividedByW(n)
			return This.EachDividedWithW(n)
	
	  #=====================================================#
	 #     UPDATING THE LIST WITH A NEW LIST OF NUMBERS    #
	#=====================================================#

	def Update(panNewListOfNumbers)

		if isList(panNewListOfNumbers) and Q(panNewListOfNumbers).IsWithOrByOrUsingNamedParam()
			panNewListOfNumbers = panNewListOfNumbers[2]
		ok

		if NOT ( isList(panNewListOfNumbers) and
			 Q(panNewListOfNumbers).IsListOfNumbers()
		       )

			StzRaise("Incorrect param type!")
		ok

		@anContent = panNewListOfNumbers

		#< @FunctionFluentForm

		def UpdateQ(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)

			def UpdateWithQ(panNewListOfNumbers)
				return This.UpdateQ(panNewListOfNumbers)
	
		def UpdateBy(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)

			def UpdateByQ(panNewListOfNumbers)
				return This.UpdateQ(panNewListOfNumbers)

		def UpdateUsing(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)

			def UpdateUsingQ(panNewListOfNumbers)
				return This.UpdateQ(panNewListOfNumbers)

		#>

	def Updated(panNewListOfNumbers)
		return panNewListOfNumbers

		#< @FunctionAlternativeForms

		def UpdatedWith(panNewListOfNumbers)
			return This.Updated(panNewListOfNumbers)

		def UpdatedBy(panNewListOfNumbers)
			return This.Updated(panNewListOfNumbers)

		def UpdatedUsing(panNewListOfNumbers)
			return This.Updated(panNewListOfNumbers)

		#>

	  #-----------------------------------------------------------#
	 #     REPLACING A NUMBER AT A GIVEN POSITION IN THE LIST    #
	#-----------------------------------------------------------#

	def ReplaceNumberAtPosition(n, pnNewNumber)

		if NOT isNumber(n)
			StzRaise("Incorrect param! n must be a number.")
		ok

		if isList(pnNewNumber) and Q(pnNewNumber).IsWithOrByNamedParam()
			pnNewNumber = pnNewNumber[2]
		ok

		if NOT isNumber(pnNewNumber)
			StzRaise("Incorrect param! pnNewNumber must be a number.")
		ok

		@anContent[n] = pnNewNumber

	  #---------------------------------------#
	 #     REVERSING THE LIST OF NUMBERS     #
	#---------------------------------------#

	def Reverse()
		aResult = This.ToStzList().Reversed()
		This.UpdateWith( aResult )

		def ReverseQ()
			This.Reverse()
			return This

		def ReverseNumbers()
			This.Reverse()

			def ReverseNumbersQ()
				This.ReverseNumbers()
				return This

	def Reversed()
		aResult = This.Copy().ReverseQ().Content()

		return aResult

		def NumbersReversed()
			return This.Reversed()

	  #=========================================#
	 #   PERFORMING AN ACTION ON EACH NUMBER   #
	#=========================================#

	def Perform(pcCode)
		# Must begin with '@number ='

		This.PerformOnThesePositions(1:This.NumberOfNumbers(), pcCode)

		#--

		def PerformQ(pcCode)
			This.Perform(pcCode)
			return This

	  #------------------------------------------------------#
	 #   PERFORMING ACTIONS ON NUMBERS IN GIVEN POSITIONS   #
	#------------------------------------------------------#

	def PerformOn(panPositions, pcCode)

		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )
			StzRaise("Invalid param type! panPositions must be a list of numbers.")
		ok

		if NOT isString(pcCode)
			StzRaise("Invalid param type! pcCode must be a string.")
		ok

		oCode = new stzString( StzCCodeQ(pcCode).UnifiedFor(:stzListOfNumbers) )

		if NOT oCode.BeginsWithOneOfTheseCS(
			[ "@number =", "@number=",
			  "@number +=", "@number+=",
			  "@number -=", "@number-=",
			  "@number *=", "@number*=",
			  "@number /=", "@number/="
			],

			:CaseSensitive = FALSE )

			StzRaise("Syntax error! pcCode must begin with '@item ='.")
		ok

		cCode = oCode.Content()
		nLenPos = len(panPositions)
		nLen = this.NumberOfNumbers()

		for i = 1 to nLenPos
			@i = panPositions[i]
			@number = This[ @i ]
			bEval = TRUE

			if @i = nLen and
			   oCode.Copy().RemoveSpacesQ().ContainsCS( "This[@i+1]", :CS=FALSE )

				bEval = FALSE

			but @i = 1 and
			    oCode.Copy().RemoveSpacesQ().ContainsCS( "This[@i-1]", :CS=FALSE )

				bEval = FALSE
			
			ok

			if bEval

			eval(cCode)
				This.ReplaceNumberAtPosition(@i, @number)
			ok

		next

		#--

		def PerformOnQ(panPositions, pcCode)
			This.PerformOn(panPositions, pcCode)
			return This

		def PerformOnPositions(panPositions, pcCode)
			This.PerformOn(panPositions, pcCode)

			def PerformOnPositionsQ(panPositions, pcCode)
				This.PerformOnPositions(panPositions, pcCode)
				return This

		def PerformOnThesePositions(panPositions, pcCode)
			This.PerformOn(panPositions, pcCode)

			def PerformOnThesePositionsQ(panPositions, pcCode)
				This.PerformOnThesePositions(panPositions, pcCode)
				return This

	  #--------------------------------------------------------#
	 #   PERFORMING AN ACTION ON NUMBERS IN GIVEN SECTIONS    #
	#--------------------------------------------------------#

	def PerformOnSections(paSections, pcCode)

		anPositions = StzListOfPairsQ(paSections).
				ExpandedIfPairsOfNumbersQ().MergeQ().
				RemoveDuplicatesQ().SortedInAscending()

		This.PerformOnPositions(anPositions, pcCode)

		#--

		def PerformOnSectionsQ(paSections, pcCode)
			This.PerformOnSections(paSections, pcCode)
			return This

		def PerformOnTheseSections(paSections, pcCode)
			This.PerformOnSections(paSections, pcCode)

			def PerformOnTheseSectionsQ(paSections, pcCode)
				This.PerformOnTheseSections(paSections, pcCode)
				return This

	  #-----------------------------------------------------------------#
	 #   PERFORMING AN ACTION ON NUMBERS VERIFYING A GIVEN CONDITION   #
	#-----------------------------------------------------------------#

	def PerformW(pcAction, pcCondition)

		This.UpdateWith(
			This.NumbersQ().
			PerformWQ(pcAction, pcCondition).Content()
		)		

		#--

		def PerformWQ(paParams)
			This.PerformW(paParams)
			return This

	  #===========#
	 #   MISC.   #
	#===========#

	def IsStzListOfNumbers()
		return TRUE

	def stzType()
		return :stzListOfNumbers

		def ClassName()
			return This.stzType()

	#-----

	def ToStzListOfChars()
		return new stzListOfChars( This.Content() )

	def NumberOfNumbers()
		return len( This.Content() )

	def IsContiguous()
		nLen = This.NumberOfNumbers()

		if nLen = 0 or nLen = 1
			return FALSE
		ok

		aContent = This.Content()

		if nLen = 2
			if aContent[1] = aContent[2]
				return FALSE
			ok
		ok

		# Case nLen > 2 (3 and more)

		n1 = aContent[1]
		n2 = aContent[2]

		bResult = TRUE
		if n1 < n2
			for i = 3 to nLen
				if aContent[i] != aContent[i-1] + 1
					bResult = FALSE
					exit
				ok
			next
		else // n1 > n2
			for i = 3 to nLen
				if aContent[i] != aContent[i-1] - 1
					bResult = FALSE
					exit
				ok
			next

		ok

		return bResult

		def IsContinuous()
			return This.IsContiguous()

	  #=========================================#
	 #  GETTING A RANDOM NUMBER FROM THE LIST  #
	#=========================================#

	def ARandomNumber()
		nRandom  = ARandomNumberBetween(1, This.NumberOfNumbers())
		anResult = This.Content()[nRandom]

		return anResult

		def ANumber()
			return ARandomNumber()

		def AnyRandomNumber()
			return ARandomNumber()

		def AnyNumber()
			return ARandomNumber()

	#-- Z/EXTENDED FORM

	def ARandomNumberZ()
		nRandom  = ARandomNumberBetween(1, This.NumberOfNumbers())
		aResult = [ This.Content()[nRandom], nRandom ]

		return aResult

	  #------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LIST LESS THAN A GIVEN NUMBER  #
	#------------------------------------------------------------------#

	def ANumberLessThan(nNumber)
		nResult = This.NumbersLessThanQR(nNumber, :stzListOfNumbers).ARandomNumber()
		return nResult

		#< @FunctionAlternativeForms

		def AnyNumberLessThan(nNumber)
			return This.ANumberLessThan(nNumber)

		def NumberLessThan(nNumber)
			return This.ANumberLessThan(nNumber)

		#--

		def ARandomNumberLessThan(nNumber)
			return This.ANumberLessThan(nNumber)

		def RandomNumberLessThan(nNumber)
			return This.ANumberLessThan(nNumber)

		#==

		def ANumberSmallerThan(nNumber)
			return This.ANumberLessThan(nNumber)

		def AnyNumberSmallerThan(nNumber)
			return This.ANumberLessThan(nNumber)

		def NumberSmallerThan(nNumber)
			return This.ANumberLessThan(nNumber)

		#--

		def ARandomNumberSmallerThan(nNumber)
			return This.ANumberLessThan(nNumber)

		def RandomNumberSmallerThan(nNumber)
			return This.ANumberLessThan(nNumber)

		#>

	#-- Z/EXTENDED FORM

	def ANumberLessThanZ(nNumber)
		aResult = This.NumbersLessThanQR(nNumber, :stzListOfNumbers).ARandomNumberZ()

		return aResult

		#< @FunctionAlternativeForms

		def AnyNumberLessThanZ(nNumber)
			return This.ANumberLessThanZ(nNumber)

		def NumberLessThanZ(nNumber)
			return This.ANumberLessThanZ(nNumber)

		#--

		def ARandomNumberLessThanZ(nNumber)
			return This.ANumberLessThanZ(nNumber)

		def RandomNumberLessThanZ(nNumber)
			return This.ANumberLessThanZ(nNumber)

		#==

		def ANumberSmallerThanZ(nNumber)
			return This.ANumberLessThanZ(nNumber)

		def AnyNumberSmallerThanZ(nNumber)
			return This.ANumberLessThanZ(nNumber)

		def NumberSmallerThanZ(nNumber)
			return This.ANumberLessThanZ(nNumber)

		#--

		def ARandomNumberSmallerThanZ(nNumber)
			return This.ANumberLessThanZ(nNumber)

		def RandomNumberSmallerThanZ(nNumber)
			return This.ANumberLessThanZ(nNumber)

		#>

	  #---------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LIST GREATER THAN A GIVEN NUMBER  #
	#---------------------------------------------------------------------#

	def ANumberGreaterThan(nNumber)
		nResult = This.NumbersGreaterThanQR(nNumber, :stzListOfNumbers).ARandomNumber()
		return nResult

		#< @FunctionAlternativeForms

		def AnyNumberGreaterThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		def NumberGreaterThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		#--

		def ARandomNumberGreaterThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		def RandomNumberGreaterThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		#--

		def ANumberLargerThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		def AnyNumberLargerThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		def NumberLargerThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		def ARandomNumberLargerThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		def RandomNumberLargerThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		#--

		def AnyNumberMoreThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		def NumberMoreThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		def ARandomNumberMoreThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		def RandomNumberMoreThan(nNumber)
			return This.ANumberGreaterThan(nNumber)

		#>

	#-- Z/EXTENDED FORM

	def ANumberGreaterThanZ(nNumber)
		aResult = This.NumbersGreaterThanQR(nNumber, :stzListOfNumbers).ARandomNumberZ()
		return aResult

		#< @FunctionAlternativeForms

		def AnyNumberGreaterThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		def NumberGreaterThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		#--

		def ARandomNumberGreaterThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		def RandomNumberGreaterThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		#--

		def ANumberLargerThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		def AnyNumberLargerThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		def NumberLargerThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		def ARandomNumberLargerThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		def RandomNumberLargerThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		#--

		def AnyNumberMoreThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		def NumberMoreThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		def ARandomNumberMoreThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		def RandomNumberMoreThanZ(nNumber)
			return This.ANumberGreaterThanZ(nNumber)

		#>

	  #------------------------------------------------------------------#
	 #  GETTING ANY NUMBER BEFORE OR AFTER A GIVEN NUMBER (OTHER THAN)  #
	#==================================================================#

	def AnyNumberBeforeOrAfter(n) # Or AnyNumberOtherThan()
		if isList(n) and Q(n).IsPositionNamedParam()
			n = n[2]
		ok

		nPos = 0
		if random(1) = 0
			nPos = This.AnyNumberBefore(n)

		else
			nPos = This.AnyNumberAfter(n)
		ok

		nResult = This.Item(nPos)
		return nResult

		#< @FunctionAlternativeForms

		def AnyNumberAfterOrBefore(n)
			return This.AnyNumberBeforeOrAfter(n)

		def ANumberBeforeOrAfter(n)
			return This.AnyNumberBeforeOrAfter(n)

		def ANumberAfterOrBefore(n)
			return This.AnyNumberBeforeOrAfter(n)

		def NumberBeforeOrAfter(n)
			return This.AnyNumberBeforeOrAfter(n)

		def NumberAfterOrBefore(n)
			return This.AnyNumberBeforeOrAfter(n)

		#--

		def AnyNumberOtherThan(n)
			return This.AnyNumberBeforeOrAfter(n)

		def ANumberOtherThan(n)
			return This.AnyNumberBeforeOrAfter(n)

		def NumberOtherThan(n)
			return This.AnyNumberBeforeOrAfter(n)

		#--

		def ARandoomNumberAfterOrBefore(n)
			return This.AnyNumberBeforeOrAfter(n)

		def RandomNumberBeforeOrAfter(n)
			return This.AnyNumberBeforeOrAfter(n)

		def RandomNumberAfterOrBefore(n)
			return This.AnyNumberBeforeOrAfter(n)

		def ARandomNumberOtherThan(n)
			return This.AnyNumberBeforeOrAfter(n)

		def RandomNumberOtherThan(n)
			return This.AnyNumberBeforeOrAfter(n)

		#--
	
		def ANumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def ANumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		#--
	
		def NumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def NumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		#--
	
		def AnyNumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def AnyNumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		#--

		def ARandomNumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def ARandomNumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def RandomNumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def RandomNumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBeforeOrAfterZ(n) # Or AnyNumberOtherThan()
		if isList(n) and Q(n).IsPositionNamedParam()
			n = n[2]
		ok

		nPos = 0
		if random(1) = 0
			nPos = This.AnyNumberBefore(n)

		else
			nPos = This.AnyNumberAfter(n)
		ok

		aResult = [ This.Item(nPos), nPos ]
		return aResult

		#< @FunctionAlternativeForms

		def AnyNumberAfterOrBeforeZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def ANumberBeforeOrAfterZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def ANumberAfterOrBeforeZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def NumberBeforeOrAfterZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def NumberAfterOrBeforeZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		#--

		def AnyNumberOtherThanZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def ANumberOtherThanZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def NumberOtherThanZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		#--

		def ARandoomNumberAfterOrBeforeZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def RandomNumberBeforeOrAfterZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def RandomNumberAfterOrBeforeZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def ARandomNumberOtherThanZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		def RandomNumberOtherThanZ(n)
			return This.AnyNumberBeforeOrAfterZ(n)

		#--
	
		def ANumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def ANumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		#--
	
		def NumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def NumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		#--
	
		def AnyNumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def AnyNumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		#--

		def ARandomNumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def ARandomNumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def RandomNumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def RandomNumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)

		#>

	  #--------------------------------------------------------#
	 #  GETTING ANY NUMBER BEFORE A GIVEN NUMBER OR POSITION  #
	#--------------------------------------------------------#

	def AnyNumberBefore(n)
		if isList(n) and Q(n).IsPositionNamedParam(n)
			return This.AnyNumberBeforePosition(n)
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nPos = ring_find( This.Content(), n)
		nResult = This.AnyNumberBeforePosition(nPos)

		return nResult

		#< @FunctionAlternativeForms

		def ANumberBefore(n)
			return This.AnyNumberBefore(n)

		def NumberBefore(n)
			return This.AnyNumberBefore(n)

		def ARandomNumberBefore(n)
			return This.AnyNumberBefore(n)

		def RandomNumberBefore(n)
			return This.AnyNumberBefore(n)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBeforeZ(n)
		if isList(n) and Q(n).IsPositionNamedParam(n)
			return This.AnyNumberBeforePosition(n)
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nPos = ring_find( This.Content(), n)
		aResult = This.AnyNumberBeforePositionZ(nPos)

		return aResult

		#< @FunctionAlternativeForms

		def ANumberBeforeZ(n)
			return This.AnyNumberBeforeZ(n)

		def NumberBeforeZ(n)
			return This.AnyNumberBeforeZ(n)

		def ARandomNumberBeforeZ(n)
			return This.AnyNumberBeforeZ(n)

		def RandomNumberBeforeZ(n)
			return This.AnyNumberBeforeZ(n)

		#>

	  #----------------------------------------------#
	 #  GETTING ANY NUMBER BEFORE A GIVEN POSITION  #
	#----------------------------------------------#

	def AnyNumberBeforePosition(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = This.NumberOfNumbers()
		
		if n <= 1 or n > nLen
			StzRaise("Index out of range!")
		ok

		if n = 2
			return This.Number(1)
		ok

		nRandom = random(n - 1)
		if nRandom = 0
			nRandom = 1
		ok

		nResult = This.Number(nRandom)

		return nResult

		#< @FunctionAlternativeForms

		def ANumberBeforePosition(n)
			return This.AnyNumberBeforePosition(n)

		def NumberBeforePosition(n)
			return This.AnyNumberBeforePosition(n)

		def ARandomNumberBeforePosition(n)
			return This.AnyNumberBeforePosition(n)

		def RandomNumberBeforePosition(n)
			return This.AnyNumberBeforePosition(n)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBeforePositionZ(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = This.NumberOfNumbers()
		
		if n <= 1 or n > nLen
			StzRaise("Index out of range!")
		ok

		if n = 2
			return This.Number(1)
		ok

		nRandom = random(n - 1)
		if nRandom = 0
			nRandom = 1
		ok

		aResult = [ This.Number(nRandom), nRandom ]

		return aResult

		#< @FunctionAlternativeForms

		def ANumberBeforePositionZ(n)
			return This.AnyNumberBeforePositionZ(n)

		def NumberBeforePositionZ(n)
			return This.AnyNumberBeforePositionZ(n)

		def ARandomNumberBeforePositionZ(n)
			return This.AnyNumberBeforePositionZ(n)

		def RandomNumberBeforePositionZ(n)
			return This.AnyNumberBeforePositionZ(n)

		#>

	  #-------------------------------------------------------#
	 #  GETTING ANY NUMBER AFTER A GIVEN NUMBER OR POSITION  #
	#-------------------------------------------------------#

	def AnyNumberAfter(n)
		if isList(n) and Q(n).IsPositionNamedParam(n)
			return This.AnyNumberAfterPosition(n)
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nPos = ring_find( ring_reverse(This.Content()), n )
		nResult = This.AnyNumberAfterPosition(nPos)

		return nResult

		#< @FunctionAlternativeForms

		def ANumberAfter(n)
			return This.AnyNumberAfter(n)

		def NumberAfter(n)
			return This.AnyNumberAfter(n)

		def ARandomNumberAfter(n)
			return This.AnyNumberAfter(n)

		def RandomNumberAfter(n)
			return This.AnyNumberAfter(n)

		#>

	# Z/EXTENDED FORM

	def AnyNumberAfterZ(n)
		if isList(n) and Q(n).IsPositionNamedParam(n)
			return This.AnyNumberAfterPosition(n)
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nPos = ring_find( ring_reverse(This.Content()), n )
		aResult = This.AnyNumberAfterPositionZ(nPos)

		return aResult

		#< @FunctionAlternativeForms

		def ANumberAfterZ(n)
			return This.AnyNumberAfterZ(n)

		def NumberAfterZ(n)
			return This.AnyNumberAfterZ(n)

		def ARandomNumberAfterZ(n)
			return This.AnyNumberAfterZ(n)

		def RandomNumberAfterZ(n)
			return This.AnyNumberAfterZ(n)

		#>

	  #---------------------------------------------#
	 #  GETTING ANY NUMBER AFETR A GIVEN POSITION  #
	#---------------------------------------------#

	def AnyNumberAfterPosition(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = This.NumberOfNumbers()

		if n < 1 or n >= nLen
			StzRaise("Index out of range!")
		ok

		if n = nLen - 1
			return This.Number(nLen)
		ok

		n--
		nRandom = random(n)
		if nRandom = 0
			nRandom = 1
		ok

		nResult = This.Number(n + nRandom - 1)

		return nResult

		#< @FunctionAlternativeForms

		def ANumberAfterPosition(n)
			return This.AnyNumberAfterPosition(n)

		def NumberAfterPosition(n)
			return This.AnyNumberAfterPosition(n)

		def ARandomNumberAfterPosition(n)
			return This.AnyNumberAfterPosition(n)

		def RandomNumberAfterPosition(n)
			return This.AnyNumberAfterPosition(n)

		#>

	# Z/EXTENDED FORM

	def AnyNumberAfterPositionZ(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = This.NumberOfNumbers()

		if n < 1 or n >= nLen
			StzRaise("Index out of range!")
		ok

		if n = nLen - 1
			return This.Number(nLen)
		ok

		n--
		nRandom = random(n)
		if nRandom = 0
			nRandom = 1
		ok

		nPos = n + nRandom - 1
		aResult = [ This.Number(nPos), nPos ]

		return aResult

		#< @FunctionAlternativeForms

		def ANumberAfterPositionZ(n)
			return This.AnyNumberAfterPositionZ(n)

		def NumberAfterPositionZ(n)
			return This.AnyNumberAfterPositionZ(n)

		def ARandomNumberAfterPositionZ(n)
			return This.AnyNumberAfterPositionZ(n)

		def RandomNumberAfterPositionZ(n)
			return This.AnyNumberAfterPositionZ(n)

		#>

	  #--------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS BETWEEN TOW OTHER NUMBERS  #
	#--------------------------------------------------------------------#

	def AnyNumberBetween(n1, n2)
		if isList(n1) and Q(n1).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(n1[2], n2)
		ok

		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		aContent = This.Content()
		nLen = len(aContent)

		anNumbers = This.NumbersBetween(n1, n2)
		nResult = ARandomNumberIn(anNumbers) # TODO: Add ARandomItemIn() function to stzRandomFunctions.ring

		return nResult

		#< @FunctionAlternativeForms

		def ANumberBetween(n1, n2)
			return This.AnyNumberBetween(n1, n2)

		def NumberBetween(n1, n2)
			return This.AnyNumberBetween(n1, n2)

		#--

		def ARandomNumberBetween(n1, n2)
			return This.AnyNumberBetween(n1, n2)

		def RandomNumberBetween(n1, n2)
			return This.AnyNumberBetween(n1, n2)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBetweenZ(n1, n2)
		if isList(n1) and Q(n1).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(n1[2], n2)
		ok

		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		aContent = This.Content()
		nLen = len(aContent)

		anNumbers = This.NumbersBetween(n1, n2)
		aResult = ARandomNumberInZ(anNumbers)
		
		return aResult

		#< @FunctionAlternativeForms

		def ANumberBetweenZ(n1, n2)
			return This.AnyNumberBetweenZ(n1, n2)

		def NumberBetweenZ(n1, n2)
			return This.AnyNumberBetweenZ(n1, n2)

		#--

		def ARandomNumberBetweenZ(n1, n2)
			return This.AnyNumberBetweenZ(n1, n2)

		def RandomNumberBetweenZ(n1, n2)
			return This.AnyNumberBetweenZ(n1, n2)

		#>

	  #---------------------------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS BETWEEN TOW OTHER NUMBERS -- INCLUDING BOUNDS #
	#---------------------------------------------------------------------------------------#

	def AnyNumberBetweenIB(n1, n2)
		if isList(n1) and Q(n1).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(n1[2], n2)
		ok

		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		aContent = This.Content()
		nLen = len(aContent)

		anNumbers = This.NumbersBetweenIB(n1, n2)
		nResult = ARandomNumberIn(anNumbers)

		return nResult

		#< @FunctionAlternativeForms

		def ANumberBetweenIB(n1, n2)
			return This.AnyNumberBetweenIB(n1, n2)

		def NumberBetweenIB(n1, n2)
			return This.AnyNumberBetweenIB(n1, n2)

		#--

		def AnyNumberBetweenXT(n1, n2)
			return This.AnyNumberBetweenIB(n1, n2)

		def ANumberBetweenXT(n1, n2)
			return This.AnyNumberBetweenIB(n1, n2)

		def NumberBetweenXT(n1, n2)
			return This.AnyNumberBetweenIB(n1, n2)

		#--

		def ARandomNumberBetweenIB(n1, n2)
			return This.AnyNumberBetweenIB(n1, n2)

		def RandomNumberBetweenIB(n1, n2)
			return This.AnyNumberBetweenIB(n1, n2)

		def ARandomNumberBetweenXT(n1, n2)
			return This.AnyNumberBetweenIB(n1, n2)

		def RandomNumberBetweenXT(n1, n2)
			return This.AnyNumberBetweenIB(n1, n2)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBetweenIBZ(n1, n2)
		if isList(n1) and Q(n1).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(n1[2], n2)
		ok

		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		aContent = This.Content()
		nLen = len(aContent)

		anNumbers = This.NumbersBetweenIB(n1, n2)
		aResult = ARandomNumberInZ(anNumbers)

		return aResult

		#< @FunctionAlternativeForms

		def ANumberBetweenIBZ(n1, n2)
			return This.AnyNumberBetweenIBZ(n1, n2)

		def NumberBetweenIBZ(n1, n2)
			return This.AnyNumberBetweenIBZ(n1, n2)

		#--

		def AnyNumberBetweenXTZ(n1, n2)
			return This.AnyNumberBetweenIBZ(n1, n2)

		def ANumberBetweenXTZ(n1, n2)
			return This.AnyNumberBetweenIBZ(n1, n2)

		def NumberBetweenXTZ(n1, n2)
			return This.AnyNumberBetweenIBZ(n1, n2)

		#--

		def ARandomNumberBetweenIBZ(n1, n2)
			return This.AnyNumberBetweenIBZ(n1, n2)

		def RandomNumberBetweenIBZ(n1, n2)
			return This.AnyNumberBetweenIBZ(n1, n2)

		def ARandomNumberBetweenXTZ(n1, n2)
			return This.AnyNumberBetweenIBZ(n1, n2)

		def RandomNumberBetweenXTZ(n1, n2)
			return This.AnyNumberBetweenIBZ(n1, n2)

		#>

	  #------------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS NOT BETWEEN TWO OTHER NUMBERS  #
	#-----------------------------------------------------------------------#

	def AnyNumberNotBetween(n1, n2)
		if isList(n1) and Q(n1).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(n1[2], n2)
		ok

		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		aContent = This.Content()
		nLen = len(aContent)

		anNumbers = This.NumbersNotBetween(n1, n2) # TODO
		nResult = ARandomNumberIn(anNumbers)

		return nResult

		#< @FunctionAlternativeForms

		def ANumberNotBetween(n1, n2)
			return This.AnyNumberNotBetween(n1, n2)

		def NumberNotBetween(n1, n2)
			return This.AnyNumberNotBetween(n1, n2)

		#--

		def ARandomNumberNotBetween(n1, n2)
			return This.AnyNumberNotBetween(n1, n2)

		def RandomNumberNotBetween(n1, n2)
			return This.AnyNumberNotBetween(n1, n2)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberNotBetweenZ(n1, n2)
		if isList(n1) and Q(n1).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(n1[2], n2)
		ok

		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		aContent = This.Content()
		nLen = len(aContent)

		anNumbers = This.NumbersNotBetween(n1, n2)
		aResult = ARandomNumberInZ(anNumbers)

		return aResult

		#< @FunctionAlternativeForms

		def ANumberNotBetweenZ(n1, n2)
			return This.AnyNumberNotBetweenZ(n1, n2)

		def NumberNotBetweenZ(n1, n2)
			return This.AnyNumberNotBetweenZ(n1, n2)

		#--

		def ARandomNumberNotBetweenZ(n1, n2)
			return This.AnyNumberNotBetweenZ(n1, n2)

		def RandomNumberNotBetweenZ(n1, n2)
			return This.AnyNumberNotBetweenZ(n1, n2)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS NOT BETWEEN TWO OTHER NUMBERS -- INCLUDING BOUNDS #
	#-------------------------------------------------------------------------------------------#

	def AnyNumberNotBetweenIB(n1, n2)
		if isList(n1) and Q(n1).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(n1[2], n2)
		ok

		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		aContent = This.Content()
		nLen = len(aContent)

		anNumbers = This.NumbersNotBetweenIB(n1, n2) # TODO
		nResult = ARandomNumberIn(anNumbers) # TODO: Add ARandomItemIn() function to stzRandomFunctions.ring

		return nResult

		#< @FunctionAlternativeForms

		def ANumberNotBetweenIB(n1, n2)
			return This.AnyNumberNotBetweenIB(n1, n2)

		def NumberNotBetweenIB(n1, n2)
			return This.AnyNumberNotBetweenIB(n1, n2)

		#--

		def AnyNumberNotBetweenXT(n1, n2)
			return This.AnyNumberNotBetweenIB(n1, n2)

		def ANumberNotBetweenXT(n1, n2)
			return This.AnyNumberNotBetweenIB(n1, n2)

		def NumberNotBetweenXT(n1, n2)
			return This.AnyNumberNotBetweenIB(n1, n2)

		#==

		def ARandomNumberNotBetweenIB(n1, n2)
			return This.AnyNumberNotBetweenIB(n1, n2)

		def RandomNumberNotBetweenIB(n1, n2)
			return This.AnyNumberNotBetweenIB(n1, n2)

		#--

		def ARandomNumberNotBetweenXT(n1, n2)
			return This.AnyNumberNotBetweenIB(n1, n2)

		def RandomNumberNotBetweenXT(n1, n2)
			return This.AnyNumberNotBetweenIB(n1, n2)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberNotBetweenIBZ(n1, n2)
		if isList(n1) and Q(n1).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(n1[2], n2)
		ok

		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		aContent = This.Content()
		nLen = len(aContent)

		anNumbers = This.NumbersNotBetweenIB(n1, n2)
		aResult   = ARandomNumberInZ(anNumbers)

		return aResult

		#< @FunctionAlternativeForms

		def ANumberNotBetweenIBZ(n1, n2)
			return This.AnyNumberNotBetweenIBZ(n1, n2)

		def NumberNotBetweenIBZ(n1, n2)
			return This.AnyNumberNotBetweenIBZ(n1, n2)

		#--

		def AnyNumberNotBetweenXTZ(n1, n2)
			return This.AnyNumberNotBetweenIBZ(n1, n2)

		def ANumberNotBetweenXTZ(n1, n2)
			return This.AnyNumberNotBetweenIBZ(n1, n2)

		def NumberNotBetweenXTZ(n1, n2)
			return This.AnyNumberNotBetweenIBZ(n1, n2)

		#==

		def ARandomNumberNotBetweenIBZ(n1, n2)
			return This.AnyNumberNotBetweenIBZ(n1, n2)

		def RandomNumberNotBetweenIBZ(n1, n2)
			return This.AnyNumberNotBetweenIBZ(n1, n2)

		#--

		def ARandomNumberNotBetweenXTZ(n1, n2)
			return This.AnyNumberNotBetweenIBZ(n1, n2)

		def RandomNumberNotBetweenXTZ(n1, n2)
			return This.AnyNumberNotBetweenIBZ(n1, n2)

		#>

	  #----------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS BETWEEN TOW OTHER POSITIONS  #
	#----------------------------------------------------------------------#

	def AnyNumberBetweenPositions(n1, n2)
		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok

		nMin = Min([ n1, n2 ])
		nMax = Max([ n1, n2 ])

		anPos = nMin : nMax
		nRandom = AnyNumberIn(anPos)
		nResult = This.Number(nRandom)

		return nResult

		#< @FunctionAlternativeForms

		def RandomNumberBetweenPositions(n1, n2)
			return This.AnyNumberBetweenPositions(n1, n2)

		def ARandomNumberBetweenPositions(n1, n2)
			return This.AnyNumberBetweenPositions(n1, n2)

		def ANumberBetweenPositions(n1, n2)
			return This.AnyNumberBetweenPositions(n1, n2)

		def NumberBetweenPositions(n1, n2)
			return This.AnyNumberBetweenPositions(n1, n2)

		#--

		def RandomNumberInSection(n1, n2)
			return This.AnyNumberBetweenPositions(n1, n2)

		def ARandomNumberInSection(n1, n2)
			return This.AnyNumberInSection(n1, n2)

		def ANumberInSection(n1, n2)
			return This.AnyNumberBetweenPositions(n1, n2)

		def NumberInSection(n1, n2)
			return This.AnyNumberBetweenPositions(n1, n2)

		def AnyNumberInSection(n1, n2)
			return This.AnyNumberBetweenPositions(n1, n2)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBetweenPositionsZ(n1, n2)
		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok

		nMin = Min([ n1, n2 ])
		nMax = Max([ n1, n2 ])

		anPos = nMin : nMax
		nRandom = AnyNumberIn(anPos)
		aResult = [ This.Number(nRandom), nRandom ]

		return aResult

		#< @FunctionAlternativeForms

		def RandomNumberBetweenPositionsZ(n1, n2)
			return This.AnyNumberBetweenPositionsZ(n1, n2)

		def ARandomNumberBetweenPositionsZ(n1, n2)
			return This.AnyNumberBetweenPositionsZ(n1, n2)

		def ANumberBetweenPositionsZ(n1, n2)
			return This.AnyNumberBetweenPositionsZ(n1, n2)

		def NumberBetweenPositionsZ(n1, n2)
			return This.AnyNumberBetweenPositionsZ(n1, n2)

		#--

		def RandomNumberInSectionZ(n1, n2)
			return This.AnyNumberBetweenPositionsZ(n1, n2)

		def ARandomNumberInSectionZ(n1, n2)
			return This.AnyNumberInSectionZ(n1, n2)

		def ANumberInSectionZ(n1, n2)
			return This.AnyNumberBetweenPositionsZ(n1, n2)

		def NumberInSectionZ(n1, n2)
			return This.AnyNumberBetweenPositionsZ(n1, n2)

		def AnyNumberInSectionZ(n1, n2)
			return This.AnyNumberBetweenPositionsZ(n1, n2)

		#>

	  #--------------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS NOT BETWEEN TWO OTHER POSITIONS  #
	#--------------------------------------------------------------------------#

	def AnyNumberNotBetweenPositions(n1, n2)
		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok

		nMin = Min([ n1, n2 ])
		nMax = Max([ n1, n2 ])

		anPos = nMin : nMax
		nRandom = AnyNumberNotIn(anPos) # TODO
		nResult = This.Number(nRandom)

		return nResult

		#< @FunctionAlternativeForms

		def RandomNumberNotBetweenPositions(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		def ARandomNumberNotBetweenPositions(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		def ANumberNotBetweenPositions(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		def NumberNotBetweenPositions(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		#--

		def RandomNumberNotInSection(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		def ARandomNumberNotInSection(n1, n2)
			return This.AnyNumberNotInSection(n1, n2)

		def ANumberNotInSection(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		def NumberNotInSection(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		def AnyNumberNotInSection(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		#--

		def RandomNumberOutsideSection(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		def ARandomNumberOutsideSection(n1, n2)
			return This.AnyNumberNotInSection(n1, n2)

		def ANumberOutsideSection(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		def NumberOutsideSection(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		def AnyNumberOutsideSection(n1, n2)
			return This.AnyNumberNotBetweenPositions(n1, n2)

		#>

	#-- Z/EXTENDED FROM

	def AnyNumberNotBetweenPositionsZ(n1, n2)
		if isList(n2) and Q(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok

		nMin = Min([ n1, n2 ])
		nMax = Max([ n1, n2 ])

		anPos = nMin : nMax
		nRandom = AnyNumberNotIn(anPos)
		aResult = [ This.Number(nRandom), nRandom ]

		return aResult

		#< @FunctionAlternativeForms

		def RandomNumberNotBetweenPositionsZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		def ARandomNumberNotBetweenPositionsZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		def ANumberNotBetweenPositionsZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		def NumberNotBetweenPositionsZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		#--

		def RandomNumberNotInSectionZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		def ARandomNumberNotInSectionZ(n1, n2)
			return This.AnyNumberNotInSectionZ(n1, n2)

		def ANumberNotInSectionZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		def NumberNotInSectionZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		def AnyNumberNotInSectionZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		#--

		def RandomNumberOutsideSectionZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		def ARandomNumberOutsideSectionZ(n1, n2)
			return This.AnyNumberNotInSectionZ(n1, n2)

		def ANumberOutsideSectionZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		def NumberOutsideSectionZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		def AnyNumberOutsideSectionZ(n1, n2)
			return This.AnyNumberNotBetweenPositionsZ(n1, n2)

		#>

	  #---------------------------------------------------#
	 #  GETTING A RANDOM NUMBER OUSIDE A GIVEN POSITION  #
	#---------------------------------------------------#

	def AnyNumberOutsidePosition(n)
		anPositons = ( Q(1 : This.NumberOfItems()) - n ).Content()
		nRandom = AnyNumberIn(anPositions)
		nResult = This.Number(nRandom)

		return nResult

		#< @FunctionAlternativeForms

		def ANumberOutsidePosition(n)
			return This.AnyNumberOutsidePosition(n)

		def NumberOutsidePosition(n)
			return This.AnyNumberOutsidePosition(n)

		#--

		def AnyNumberBeforeOrAfterPosition(n)
			return This.AnyNumberOutsidePosition(n)

		def AnyNumberAfterOrBeforePosition(n)
			return This.AnyNumberOutsidePosition(n)

		def ANumberBeforeOrAfterPosition(n)
			return This.AnyNumberOutsidePosition(n)

		def ANumberAfterOrBeforePosition(n)
			return This.AnyNumberOutsidePosition(n)

		def NumberBeforeOrAfterPosition(n)
			return This.AnyNumberOutsidePosition(n)

		def NumberAfterOrBeforePosition(n)
			return This.AnyNumberOutsidePosition(n)

		#--

		def ARandomNumberOutsidePosition(n)
			return This.AnyNumberOutsidePosition(n)

		def RandomNumberOutsidePosition(n)
			return This.AnyNumberOutsidePosition(n)

		def ARandomNumberBeforeOrAfterPosition(n)
			return This.AnyNumberOutsidePosition(n)

		def ARandomNumberAfterOrBeforePosition(n)
			return This.AnyNumberOutsidePosition(n)

		def RandomNumberBeforeOrAfterPosition(n)
			return This.AnyNumberOutsidePosition(n)

		def RandomNumberAfterOrBeforePosition(n)
			return This.AnyNumberOutsidePosition(n)

		#--

		def ARandomNumberNotAtPosition(n)
			return This.AnyNumberOutsidePosition(n)

		def RandomNumberNotAtPosition(n)
			return This.AnyNumberOutsidePosition(n)

		#--

		def ARandomNumberNotAt(n)
			return This.AnyNumberOutsidePosition(n)

		def RandomNumberNotAt(n)
			return This.AnyNumberOutsidePosition(n)

		#>

	# Z/EXTENDED FORM

	def AnyNumberOutsidePositionZ(n)
		anPositons = ( Q(1 : This.NumberOfItems()) - n ).Content()
		nRandom = AnyNumberIn(anPositions)
		aResult = [ This.Number(nRandom), nRandom ]

		return aResult

		#< @FunctionAlternativeForms

		def ANumberOutsidePositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def NumberOutsidePositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		#--

		def AnyNumberBeforeOrAfterPositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def AnyNumberAfterOrBeforePositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def ANumberBeforeOrAfterPositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def ANumberAfterOrBeforePositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def NumberBeforeOrAfterPositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def NumberAfterOrBeforePositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		#--

		def ARandomNumberOutsidePositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def RandomNumberOutsidePositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def ARandomNumberBeforeOrAfterPositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def ARandomNumberAfterOrBeforePositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def RandomNumberBeforeOrAfterPositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def RandomNumberAfterOrBeforePositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		#--

		def ARandomNumberNotAtPositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def RandomNumberNotAtPositionZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		#--

		def ARandomNumberNotAtZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		def RandomNumberNotAtZ(n)
			return This.AnyNumberOutsidePositionZ(n)

		#>

	  #------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST  #
	#------------------------------------------#

	def NRandomNumbers(n)

		# Checking param n and the size of the list of numbers

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
		if n <= 0
			StzRaise("Can't proceed because n must be a positive number greater then 0!")
		ok

		nLen = This.NumberOfNumbers()
		if nLen = 0
			StzRaise("Can't get random numbers because the list is empty!")
		ok

		if n > nLen
			StzRaise("Can't proceed because n must be a number equal or less then the size of the list ("+ nLen +")!")
		ok

		# Doing the job

		anResult = []

		for i = 1 to n
			anResult + ARandomNumberBetween(1, nLen)
		next

		return anResult

		#< @FunctionAlternativeForms

		def RandomNNumbers(n)
			return This.NRandomNumbers(n)

		def NNumbers(n)
			return This.NRandomNumbers(n)

		#>

	# Z/EXTENDED FORM

	def NRandomNumbersZ(n)

		# Checking param n and the size of the list of numbers

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
		if n <= 0
			StzRaise("Can't proceed because n must be a positive number greater then 0!")
		ok

		nLen = This.NumberOfNumbers()
		if nLen = 0
			StzRaise("Can't get random numbers because the list is empty!")
		ok

		if n > nLen
			StzRaise("Can't proceed because n must be a number equal or less then the size of the list ("+ nLen +")!")
		ok

		# Doing the job

		aResult = []

		for i = 1 to n
			aResult + ARandomNumberBetweenZ(1, nLen)
		next

		return aResult

		#< @FunctionAlternativeForms

		def RandomNNumbersZ(n)
			return This.NRandomNumbersZ(n)

		def NNumbersZ(n)
			return This.NRandomNumbersZ(n)

		#>

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)


	  #------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OTHER THEN A GIVEN NUMBER  #
	#------------------------------------------------------#

	def NNumbersOtherThan(n, nNumber)
		if isList(n)
			if Q(n).IsPositionNamedParam()
				return This.NNumbersOutSidePosition(n[2], nNumber)

			but Q(n).IsPositionsNamedParam()
				return This.NNumbersOutsidePositions(n[2], nNumber)

			else
				return This.NNumbersOutsidePositions(n, nNumber)
			ok
		ok

		anPos = This.Find(n)
		anPos = ( Q( 1 : This.NumberOfNumbers() ) - anPos ).Content()
		anRandoms = NRandomNumbersIn(anPos)
		anResult = This.ItemsAtPositions(anRandoms)

		return anResult

	#-- Z/EXTENDED FORM

	def NNumbersOtherThanZ(n, nNumber)
		if isList(n)
			if Q(n).IsPositionNamedParam()
				return This.NNumbersOutSidePosition(n[2], nNumber)

			but Q(n).IsPositionsNamedParam()
				return This.NNumbersOutsidePositions(n[2], nNumber)

			else
				return This.NNumbersOutsidePositions(n, nNumber)
			ok
		ok

		anPos = This.Find(n)
		anPos = ( Q( 1 : This.NumberOfNumbers() ) - anPos ).Content()
		anRandoms = NRandomNumbersIn(anPos)
		nLen = len(anRandoms)

		aResult = []

		for i = 1 to nLen
			aResult + [ This.ItemAtPosition(anRandoms[i]), anRandoms[i] ]
		next

		return aResult

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #-----------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS LESS THEN A GIVEN NUMBER  #
	#-----------------------------------------------------#

	def NNumbersLessThan(n, nNumber)
		anResult = This.NumbersLessThanQ(nNumber).NRandomNumbers(n)
		return anResult

		#< @FunctionAlternativeForms

		def NRandomNumbersLessThan(n, nNumber)
			return This.NNumbersLessThan(n, nNumber)

		def NNumbersSmallerThan(n, nNumber)
			return This.NNumbersLessThan(n, nNumber)

		def NRandomNumbersSmallerThan(n, nNumber)
			return This.NNumbersLessThan(n, nNumber)

		#>

	#-- Z/EXTENDED FORM

	def NNumbersLessThanZ(n, nNumber)
		aResult = This.NumbersLessThanQ(nNumber).NRandomNumbersZ(n)
		return anResult

		#< @FunctionAlternativeForms

		def NRandomNumbersLessThanZ(n, nNumber)
			return This.NNumbersLessThanZ(n, nNumber)

		def NNumbersSmallerThanZ(n, nNumber)
			return This.NNumbersLessThanZ(n, nNumber)

		def NRandomNumbersSmallerThanZ(n, nNumber)
			return This.NNumbersLessThanZ(n, nNumber)

		#>

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #--------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS GREATER THEN A GIVEN NUMBER  #
	#--------------------------------------------------------#

	def NNumbersGreaterThan(n, nNumber)
		anResult = This.NumbersGreaterThanQ(nNumber).NRandomNumbers(n)
		return anResult

		#< @FunctionAlternativeForms

		def NRandomNumbersGreaterThan(n, nNumber)
			return This.NNumbersLessThan(n, nNumber)

		def NNumbersBiggerThan(n, nNumber)
			return This.NNumbersLessThan(n, nNumber)

		def NRandomNumbersBiggerThan(n, nNumber)
			return This.NNumbersLessThan(n, nNumber)

		def NNumbersMoreThan(n, nNumber)
			return This.NNumbersLessThan(n, nNumber)

		def NRandomNumbersMoreThan(n, nNumber)
			return This.NNumbersLessThan(n, nNumber)

		#>

	#-- Z/EXTENDED FORM

	def NNumbersGreaterThanZ(n, nNumber)
		aResult = This.NumbersGreaterThanQ(nNumber).NRandomNumbersZ(n)
		return aResult

		#< @FunctionAlternativeForms

		def NRandomNumbersGreaterThanZ(n, nNumber)
			return This.NNumbersLessThanZ(n, nNumber)

		def NNumbersBiggerThanZ(n, nNumber)
			return This.NNumbersLessThanZ(n, nNumber)

		def NRandomNumbersBiggerThanZ(n, nNumber)
			return This.NNumbersLessThanZ(n, nNumber)

		def NNumbersMoreThanZ(n, nNumber)
			return This.NNumbersLessThanZ(n, nNumber)

		def NRandomNumbersMoreThanZ(n, nNumber)
			return This.NNumbersLessThanZ(n, nNumber)

		#>

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #---------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OTHER THEN THE GIVEN NUMBERS  #
	#---------------------------------------------------------#
	
	# TODO: Add alternatives of (DifferentTo / Of / From / With) all over the library!

	def NNumbersOtherThanMany(n, anNumbers)
		anPos = ( Q( 1 : This.NumberOfItems() ) - This.Find(anNumbers) ).Content()
		anRandoms = NRandomNumbersIn(anPos)
		aResult = This.ItemsAtPositions(anRandoms)

		return anResult

		#< @FunctionAlternativeForms

		def NNumbersDifferentFromMany(n, anNumbers)
			return This.NNumbersOtherThanMany(n, anNumbers)

		def NNumbersDifferentToMany(n, anNumbers)
			return This.NNumbersOtherThanMany(n, anNumbers)

		def NNumbersDifferentWithMany(n, anNumbers)
			return This.NNumbersOtherThanMany(n, anNumbers)

		def NNumbersDifferentOfMany(n, anNumbers)
			return This.NNumbersOtherThanMany(n, anNumbers)

		#--

		def NRandomNumbersOtherThanMany(n, anNumbers)
			return This.NNumbersOtherThanMany(n, anNumbers)

		def NRandomNumbersDifferentFromMany(n, anNumbers)
			return This.NNumbersOtherThanMany(n, anNumbers)

		def NRandomNumbersDifferentToMany(n, anNumbers)
			return This.NNumbersOtherThanMany(n, anNumbers)

		def NRandomNumbersDifferentWithMany(n, anNumbers)
			return This.NNumbersOtherThanMany(n, anNumbers)

		def NRandomNumbersDifferentOfMany(n, anNumbers)
			return This.NNumbersOtherThanMany(n, anNumbers)

		#>

	#-- Z/EXTENDED FORM

	def NNumbersOtherThanManyZ(n, anNumbers)
		anPos = ( Q( 1 : This.NumberOfItems() ) - This.Find(anNumbers) ).Content()
		anRandoms = NRandomNumbersIn(anPos)
		nLen = len(aRandoms)
		
		aResult = []

		for i = 1 to nLen
			aResult + [ This.ItemAtPosition(anRandoms[i]), anRandoms[i] ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def NNumbersDifferentFromManyZ(n, anNumbers)
			return This.NNumbersOtherThanManyZ(n, anNumbers)

		def NNumbersDifferentToManyZ(n, anNumbers)
			return This.NNumbersOtherThanManyZ(n, anNumbers)

		def NNumbersDifferentWithManyZ(n, anNumbers)
			return This.NNumbersOtherThanManyZ(n, anNumbers)

		def NNumbersDifferentOfManyZ(n, anNumbers)
			return This.NNumbersOtherThanManyZ(n, anNumbers)

		#--

		def NRandomNumbersOtherThanManyZ(n, anNumbers)
			return This.NNumbersOtherThanManyZ(n, anNumbers)

		def NRandomNumbersDifferentFromManyZ(n, anNumbers)
			return This.NNumbersOtherThanManyZ(n, anNumbers)

		def NRandomNumbersDifferentToManyZ(n, anNumbers)
			return This.NNumbersOtherThanManyZ(n, anNumbers)

		def NRandomNumbersDifferentWithManyZ(n, anNumbers)
			return This.NNumbersOtherThanManyZ(n, anNumbers)

		def NRandomNumbersDifferentOfManyZ(n, anNumbers)
			return This.NNumbersOtherThanManyZ(n, anNumbers)

		#>

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)


	  #--------------------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST BETWEEN TWO GIVEN NUMBERS  #
	#--------------------------------------------------------------------#

	def NNumbersBetween(n, nMin, nMax)
		anNumbers = This.NumbersBetween(nMin, nMax)
		anResult = NRandomNumbersIn(n, anNumbers)

		return anResult

		def NRandomNumbersBetween(nMin, nMax)
			return This.NNumbersBetween(nMin, nMax)

	#-- Z/EXTENDED FORM

	def NNumbersBetweenZ(n, nMin, nMax)
		anNumbers = This.NumbersBetween(nMin, nMax)
		aResult = NRandomNumbersInZ(n, anNumbers)

		return aResult

		def NRandomNumbersBetweenZ(nMin, nMax)
			return This.NNumbersBetweenZ(nMin, nMax)

	#-- U/EXTENDED FORM (TODO)

	#-- UZ/EXTENDED FORM (TODO)


	  #-----------------------------------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#-----------------------------------------------------------------------------------#

	def NNumbersBetweenIB(n, nMin, nMax)
		anNumbers = This.NumbersBetweenIB(nMin, nMax)
		anResult = NRandomNumbersIn(n, anNumbers)

		return anResult

		def NRandomNumbersBetweenIB(nMin, nMax)
			return This.NNumbersBetweenIB(nMin, nMax)

	# Z/EXTENDED FORM

	def NNumbersBetweenIBZ(n, nMin, nMax)
		anNumbers = This.NumbersBetweenIB(nMin, nMax)
		aResult = NRandomNumbersInZ(n, anNumbers)

		return anResult

		def NRandomNumbersBetweenIBZ(nMin, nMax)
			return This.NNumbersBetweenIBZ(nMin, nMax)


	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)


	  #------------------------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST NOT BETWEEN TWO GIVEN NUMBERS  #
	#------------------------------------------------------------------------#

	def NNumbersNotBetween(n, nMin, nMax)
		anNumbers = This.NumbersNotBetween(nMin, nMax)
		anResult = NRandomNumbersIn(n, anNumbers)

		return anResult

		def NRandomNumbersNotBetween(nMin, nMax)
			return This.NNumbersNotBetween(nMin, nMax)

	# Z/EXTENDED FORM

	def NNumbersNotBetweenZ(n, nMin, nMax)
		anNumbers = This.NumbersNotBetween(nMin, nMax)
		aResult = NRandomNumbersInZ(n, anNumbers)

		return aResult

		def NRandomNumbersNotBetweenZ(nMin, nMax)
			return This.NNumbersNotBetweenZ(nMin, nMax)

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)


	  #---------------------------------------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST NOT BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#---------------------------------------------------------------------------------------#

	def NNumbersNotBetweenIB(n, nMin, nMax)
		anNumbers = This.NumbersNotBetweenIB(nMin, nMax)
		anResult = NRandomNumbersIn(n, anNumbers)

		return anResult

		def NRandomNumbersNotBetweenIB(nMin, nMax)
			return This.NNumbersNotBetweenIB(nMin, nMax)

	# Z/EXTENDED FORM

	def NNumbersNotBetweenIBZ(n, nMin, nMax)
		anNumbers = This.NumbersNotBetweenIB(nMin, nMax)
		aResult = NRandomNumbersInZ(n, anNumbers)

		return aResult

		def NRandomNumbersNotBetweenIBZ(nMin, nMax)
			return This.NNumbersNotBetweenIBZ(nMin, nMax)

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #-----------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OUTSIDE A GIVEN POSITION  #
	#=====================================================#

	def NNumbersOutsidePosition(nPos)
		return This.NItemsOutsidePosition(nPos)

	#-- 2/EXTENDED FORM

	def NNumbersOutsidePositionsZ(panPos)
		return This.NItemsOutsidePositionsZ(panPos)

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #--------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OUTSIDE THE GIVEN POSITIONS  #
	#--------------------------------------------------------#

	def NNumbersOutsidePositions(panPos)
		return This.NItemsOutsidePositions(panPos)

	# Z/EXTENDED FORM

	def NItemsOutsidePositionZ(anPos)
		return This.NItemsOutsidePositionZ(anPos)

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #---------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS FROM THE LIST  #
	#=============================================#

	def SomeRandomNumbers()
		anPos = SomeRandomNumbersIn(1 : This.NumberOfItems())
		anResult = This.ItemsAtPositions(anPos)

		return anResult

		def SomeNumbers()
			return This.SomeRandomNumbers()

	# Z/EXTENDED FORM

	def SomeRandomNumbersZ()
		anPos = SomeRandomNumbersIn(1 : This.NumberOfItems())
		nLen  = len(anPos)

		aResult = []

		for i = 1 to nLen
			aResult + [ This.Number(i), anPos[i] ]
		next

		return aResult

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #---------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS OTHER THEN A GIVEN NUMBER  #
	#---------------------------------------------------------#

	def SomeNumbersOtherThan(n, nNumber)
		if isList(n)
			if Q(n).IsPositionNamedParam()
				return This.SomeNumbersOutSidePosition(n[2], nNumber)

			but Q(n).IsPositionsNamedParam()
				return This.SomeNumbersOutsidePositions(n[2], nNumber)

			else
				return This.SomeNumbersOutsidePositions(n, nNumber)
			ok
		ok

		anPos = This.Find(n)
		anPos = ( Q( 1 : This.NumberOfNumbers() ) - anPos ).Content()
		anRandoms = SomeRandomNumbersIn(anPos)
		anResult = This.ItemsAtPositions(anRandoms)

		return anResult

	  #--------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS LESS THEN A GIVEN NUMBER  #
	#--------------------------------------------------------#

	def SomeNumbersLessThan(n, nNumber)
		anNumbers = This.NumbersLessThan(nNumber)
		anResult = StzListOfNumbers(anNumbers).SomeRandomNumbers()

		return anResult

	#-- Z/EXTENDED FORM

	def SomeNumbersLessThanZ(n, nNumber)
		anNumbers = This.NumbersLessThan(nNumber)
		aResult = StzListOfNumbers(anNumbers).SomeRandomNumbersZ()

		return aResult

	  #----------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS GRATER THEN A GIVEN NUMBER  #
	#----------------------------------------------------------#

	def SomeNumbersGreaterThan(n, nNumber)
		anNumbers = This.NumbersGreaterThan(nNumber)
		anResult = StzListOfNumbers(anNumbers).SomeRandomNumbers()

		return anResult

	#-- Z/EXTENDED FORM

	def SomeNumbersGreaterThanZ(n, nNumber)
		anNumbers = This.NumbersGreaterThan(nNumber)
		aResult = StzListOfNumbers(anNumbers).SomeRandomNumbersZ()

		return aResult

	  #------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS OTHER THEN THE GIVEN NUMBERS  #
	#------------------------------------------------------------#

	def SomeNumbersOtherThanMany(paNumbers)
		anNumbers = This.NumbersOtherThanMany(paNumbers)
		anResult  = StzListOfNumbers(anNumbers).SomeRandomNumbers()

		return anResult

	#-- Z/EXTENDED FORM

	def SomeNumbersOtherThanManyZ(paNumbers)
		anNumbers = This.NumbersOtherThanMany(nNumber)
		aResult   = StzListOfNumbers(anNumbers).SomeRandomNumbersZ()

		return aResult

	  #---------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS BETWEEN TWO GIVEN NUMBERS  #
	#---------------------------------------------------------#

	func SomeNumbersBetween(nMin, nMax)
		anNumbers = This.NumbersBetween(nMin, nMax)
		anResult  = StzListOfNumbers(anNumbers).SomeRandomNumbers()

		return anResult

	#-- Z/EXTENDED FORM

	def SomeNumbersBetweenZ(nMin, nMax)
		anNumbers = This.NumbersBetween(nMin, nMax)
		aResult   = StzListOfNumbers(anNumbers).SomeRandomNumbersZ()

		return aResult

	  #-------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS NOT BETWEEN TWO GIVEN NUMBERS  #
	#-------------------------------------------------------------#

	func SomeNumbersNotBetween(nMin, nMax)
		anNumbers = This.NumbersNotBetween(nMin, nMax)
		anResult  = StzListOfNumbers(anNumbers).SomeRandomNumbers()

		return anResult

	#-- Z/EXTENDED FORM

	def SomeNumbersNotBetweenZ(nMin, nMax)
		anNumbers = This.NumbersNotBetween(nMin, nMax)
		aResult   = StzListOfNumbers(anNumbers).SomeRandomNumbersZ()

		return aResult

	  #------------------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#------------------------------------------------------------------------#

	func SomeNumbersBetweenIB(nMin, nMax)
		anNumbers = This.NumbersBetweenIB(nMin, nMax)
		anResult  = StzListOfNumbers(anNumbers).SomeRandomNumbers()

		return anResult

	#-- Z/EXTENDED FORM

	def SomeNumbersBetweenIBZ(nMin, nMax)
		anNumbers = This.NumbersBetweenIB(nMin, nMax)
		aResult   = StzListOfNumbers(anNumbers).SomeRandomNumbersZ()

		return aResult

	  #----------------------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS NOT BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#----------------------------------------------------------------------------#

	func SomeNumbersNotBetweenIB(nMin, nMax)
		anNumbers = This.NumbersNotBetween(nMin, nMax)
		anResult  = StzListOfNumbers(anNumbers).SomeRandomNumbers()

		return anResult

	#-- Z/EXTENDED FORM

	def SomeNumbersNotBetweenIBZ(nMin, nMax)
		anNumbers = This.NumbersNotBetween(nMin, nMax)
		aResult   = StzListOfNumbers(anNumbers).SomeRandomNumbersZ()

		return aResult

	  #===================================================#
	 #  GETTING THE NUMBERS SMALLER THAN A GIVEN NUMBER  #
	#===================================================#

	def NumbersSmallerThan(n)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			if anContent[i] < n
				anResult + anContent[i]
			ok
		next

		return anResult

		#< @FunctionFluentForms

		def NumbersSmallerThanQ(n)
			return This.NumbersSmallerThanQR(n, :stzList)

		def NumbersSmallerThanQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.NumbersSmallerThan(n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumbersSmallerThan(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def NumbersLessThan(n)
			return This.NumbersSmallerThan(n)

			def NumbersLessThanQ(n)
				return This.NumbersSmallerThanQ(n)

			def NumbersLessThanQR(n, pcReturnType)
				return This.NumbersSmallerThanQR(n, pcReturnType)

		#>

	#-- Z/EXTENDED FORM

	def NumbersSmallerThanZ(n)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			if anContent[i] < n
				aResult + [ anContent[i], i ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForm

		def NumbersLessThanZ(n)
			return This.NumbersSmallerThanZ(n)

		#>

	  #---------------------------------------------------#
	 #  GETTING THE NUMBERS GREATER THAN A GIVEN NUMBER  #
	#---------------------------------------------------#

	def NumbersGreaterThan(n)
		if NOT This.Contains(n)
			return []
		ok
	
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			if anContent[i] > n
				anResult + anContent[i]
			ok
		next

		return anResult

		#< @FunctionFluentForms

		def NumbersGreaterThanQ(n)
			return This.NumbersGreaterThanQR(n, :stzList)

		def NumberGreaterThanQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.NumbersGreaterThan(n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumbersGreaterThan(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def NumbersLargerThan(n)
			return This.NumberSmallerThan(n)

			def NumbersLargerThanQ(n)
				return This.NumberSmallerThanQ(n)

			def NumbersLargerThanQR(n, pcReturnType)
				return This.NumberSmallerThanQ(n, pcReturnType)

		def NumbersBiggerThan(n)
			return This.NumberSmallerThan(n)

			def NumbersBiggerThanQ(n)
				return This.NumberSmallerThanQ(n)

			def NumbersBiggerThanQR(n, pcReturnType)
				return This.NumberSmallerThanQ(n, pcReturnType)

		def NumbersMoreThan(n)
			return This.NumberSmallerThan(n)

			def NumbersMoreThanQ(n)
				return This.NumberSmallerThanQ(n)

			def NumbersMoreThanQR(n, pcReturnType)
				return This.NumberSmallerThanQ(n, pcReturnType)

		#>

	#-- Z/EXTENDED FORM

	def NumbersGreaterThanZ(n)
		if NOT This.Contains(n)
			return []
		ok
	
		anContent = This.Content()
		nLen = len(anContent)

		aResult = []

		for i = 1 to nLen
			if anContent[i] > n
				aResult + [ aContent[i], i ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def NumbersLargerThanZ(n)
			return This.NumberSmallerThan(n)

		def NumbersBiggerThanZ(n)
			return This.NumberSmallerThan(n)

		def NumbersMoreThanZ(n)
			return This.NumberSmallerThan(n)

		#>

	  #-------------------------------------------------#
	 #  GETTING THE NUMBERS OTHER THAN A GIVEN NUMBER  #
	#-------------------------------------------------#

	def NumbersOtherThan(n)
		if isList(n)
			return This.NumbersOtherThanMany(n)
		ok

		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			if anContent[i] != n
				anResult + anContent[i]
			ok
		next

		return anResult

		#< @FunctionFluentForms

		def NumbersOtherThanQ(n)
			return new NumbersOtherThanQR(n, :stzList)

		def NumbersOtherThanQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.NumbersOtherThan(n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumbersOtherThan(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def NumbersDifferentFrom(n)
			return This.NumbersOtherThan(n)

			def NumbersDifferentFromQ(n)
				return This.NumbersOtherThanQ(n)

			def NumbersDifferentFromQR(n, pcReturnType)
				return This.NumbersOtherThanQR(n, pcReturnType)

		def NumbersDifferentOf(n)
			return This.NumbersOtherThan(n)

			def NumbersDifferentOfQ(n)
				return This.NumbersOtherThanQ(n)

			def NumbersDifferentOfQR(n, pcReturnType)
				return This.NumbersOtherThanQR(n, pcReturnType)

		def NumbersDifferentTo(n)
			return This.NumbersOtherThan(n)

			def NumbersDifferentToQ(n)
				return This.NumbersOtherThanQ(n)

			def NumbersDifferentToQR(n, pcReturnType)
				return This.NumbersOtherThanQR(n, pcReturnType)

		#>

	#-- Z/EXTENDED FORM

	def NumbersOtherThanZ(n)
		if isList(n)
			return This.NumbersOtherThanMany(n)
		ok

		anContent = This.Content()
		nLen = len(anContent)

		aResult = []

		for i = 1 to nLen
			if anContent[i] != n
				aResult + [ aContent[i], i ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def NumbersDifferentFromZ(n)
			return This.NumbersOtherThanZ(n)

		def NumbersDifferentOfZ(n)
			return This.NumbersOtherThanZ(n)

		def NumbersDifferentToZ(n)
			return This.NumbersOtherThanZ(n)

		#>

	  #-----------------------------------------------------#
	 #  GETTING THE NUMBERS OTHER THAN MANY GIVEN NUMBERS  #
	#-----------------------------------------------------#

	def NumbersOtherThanMany(anNumbers)
		if NOT (isList(anNumbers) and Q(anNumbers).IsListOfNumbers())
			StzRaise("Incorrect param type! anNumbers must be a list of numbers.")
		ok

		anContent = This.Content()
		nLen = len(aContent)

		anResult = []

		for i = 1 to nLen
			if NOT ring_find(anNumbers, anContent[i])
				anResult + aContent[i]
			ok
		next

		return anResult

		#< @FunctionAlternativeForms

		def NumbersDifferentFromMany(anNumbers)
			return This.NumbersOtherThanMany(anNumbers)

		def NumbersDifferentOfMany(anNumbers)
			return This.NumbersOtherThanMany(anNumbers)

		def NumbersDifferentToMany(anNumbers)
			return This.NumbersOtherThanMany(anNumbers)

		#--

		def NumbersOtherThanThese(anNumbers)
			return This.NumbersOtherThanMany(anNumbers)

		def NumbersDifferentFromThese(anNumbers)
			return This.NumbersOtherThanMany(anNumbers)

		def NumbersDifferentOfThese(anNumbers)
			return This.NumbersOtherThanMany(anNumbers)

		def NumbersDifferentThese(anNumbers)
			return This.NumbersOtherThanMany(anNumbers)

		#>

	#-- Z/EXTENDED FORM

	def NumbersOtherThanManyZ(anNumbers)
		if NOT (isList(anNumbers) and Q(anNumbers).IsListOfNumbers())
			StzRaise("Incorrect param type! anNumbers must be a list of numbers.")
		ok

		anContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			if NOT ring_find(anNumbers, anContent[i])
				aResult + [ aContent[i], i ]
			ok
		next

		return aResult

		#< @FunctionAlternativeForms

		def NumbersDifferentFromManyZ(anNumbers)
			return This.NumbersOtherThanManyZ(anNumbers)

		def NumbersDifferentOfManyZ(anNumbers)
			return This.NumbersOtherThanManyZ(anNumbers)

		def NumbersDifferentToManyZ(anNumbers)
			return This.NumbersOtherThanManyZ(anNumbers)

		#--

		def NumbersOtherThanTheseZ(anNumbers)
			return This.NumbersOtherThanManyZ(anNumbers)

		def NumbersDifferentFromTheseZ(anNumbers)
			return This.NumbersOtherThanManyZ(anNumbers)

		def NumbersDifferentOfTheseZ(anNumbers)
			return This.NumbersOtherThanManyZ(anNumbers)

		def NumbersDifferentTheseZ(anNumbers)
			return This.NumbersOtherThanManyZ(anNumbers)

		#>

	  #--------------------------------------------#
	 #  GETTING NUMBERS OUTSIDE A GIVEN POSITION  #
	#--------------------------------------------#

	def NumbersOutsidePosition(n)
		anPos = ( Q( 1 : This.NumberOfItems() ) - [n] ).Content()
		anResult = This.ItemsAtPositions(anPos)

		return anResult

		#< @FunctionAlternativeForms

		def NumbersBeforeAndAfterPosition(n)
			return This.NumbersOutsidePosition(n)

		def NumbersAfterAndBeforePosition(n)
			return This.NumbersOutsidePosition(n)

		def NumbersBeforeOrAfterPosition(n)
			return This.NumbersOutsidePosition(n)

		def NumbersAfterOrBeforePosition(n)
			return This.NumbersOutsidePosition(n)

		#>

	#-- Z/EXTENDED FORM

	def NumbersOutsidePositionZ(n)
		anPos = ( Q( 1 : This.NumberOfItems() ) - [n] ).Content()
		nLen = len(anPos)

		aResult = []

		for i = 1 to nLen
			aResult + [ This.Item(anPos[i]), anPos[i] ]
		next

		return nResult

		#< @FunctionAlternativeForms

		def NumbersBeforeAndAfterPositionZ(n)
			return This.NumbersOutsidePositionZ(n)

		def NumbersAfterAndBeforePositionZ(n)
			return This.NumbersOutsidePositionZ(n)

		def NumbersBeforeOrAfterPositionZ(n)
			return This.NumbersOutsidePositionZ(n)

		def NumbersAfterOrBeforePositionZ(n)
			return This.NumbersOutsidePositionZ(n)

		#>

	  #----------------------------------------------------------#
	 #  GETTING NUMNBERS IN THE LIST BETWEEN TWO GIVEN NUMBERS  #
	#==========================================================#

	def NumbersBetween(nMin, nMax)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			if anContent[i] > nMin and anContent[i] < nMax
				anResult + anContent[i]
			ok
		next

		return anResult

	#-- Z/EXTENDED FORM

	def NumbersBetweenZ(nMin, nMax)
		anContent = This.Content()
		nLen = len(anContent)

		aResult = []

		for i = 1 to nLen
			if anContent[i] > nMin and anContent[i] < nMax
				aResult + [ anContent[i], i ]
			ok
		next

		return aResult

	  #------------------------------------------------------------------------#
	 #  GETTING NUMNBERS IN THE LIST BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#------------------------------------------------------------------------#

	def NumbersBetweenIB(nMin, nMax)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			if anContent[i] >= nMin and anContent[i] <= nMax
				anResult + anContent[i]
			ok
		next

		return anResult

	#-- Z/EXTENDED FORM

	def NumbersBetweenIBZ(nMin, nMax)
		anContent = This.Content()
		nLen = len(anContent)

		aResult = []

		for i = 1 to nLen
			if anContent[i] >= nMin and anContent[i] <= nMax
				aResult + [ anContent[i], i ]
			ok
		next

		return aResult

	  #--------------------------------------------------------------#
	 #  GETTING NUMNBERS IN THE LIST NOT BETWEEN TWO GIVEN NUMBERS  #
	#===============================================================#

	def NumbersNotBetween(nMin, nMax)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			if NOT( anContent[i] > nMin and anContent[i] < nMax )
				anResult + anContent[i]
			ok
		next

		return anResult

	#-- Z/EXTENDED FORM

	def NumbersNotBetweenZ(nMin, nMax)
		anContent = This.Content()
		nLen = len(anContent)

		aResult = []

		for i = 1 to nLen
			if NOT ( anContent[i] > nMin and anContent[i] < nMax )
				aResult + [ anContent[i], i ]
			ok
		next

		return aResult

	  #-----------------------------------------------------------------------------#
	 #  GETTING NUMNBERS IN THE LIST NOT BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#-----------------------------------------------------------------------------#

	def NumbersNotBetweenIB(nMin, nMax)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			if NOT ( anContent[i] >= nMin and anContent[i] <= nMax )
				anResult + anContent[i]
			ok
		next

		return anResult

	#-- Z/EXTENDED FORM

	def NumbersNotBetweenIBZ(nMin, nMax)
		anContent = This.Content()
		nLen = len(anContent)

		aResult = []

		for i = 1 to nLen
			if NOT ( anContent[i] >= nMin and anContent[i] <= nMax )
				aResult + [ anContent[i], i ]
			ok
		next

		return aResult

	  #==============================#
	 #     OPERATORS OVERLOADING    # 
	#==============================#

	/*
		TODO: Operators should carry same semantics in all classes...
	*/

	def operator(pcOp, pValue)
		
		if pcOp = "[]"

			if isNumber(pValue)
				return This.NumberAt(pValue)

			ok

		but pcOp = "="
			return This.ToStzList().IsEqualTo(value)

		but pcOp = "=="
			return This.ToStzList().IsStrictlyEqualTo(value)
		

		but pcOp = "/"

			if ring_type(pValue) = "NUMBER"
				// Divides the list on pValue sublists (a list of lists)
				return This.ToStzList().SplitToNParts(pValue)

			but @IsStzNumber(pValue)
				return Q(This.ToStzList().SplitToNParts(pValue))
			ok

		but pcOp = "-"
			if isNumber(pValue)
				anResult = This.ToStzList().RemoveNthQ( ring_find(This.ListOfStrings(), pValue) ).Content()
				return anResult

			but @IsNumber(pValue)
				anResult = This.ToStzList().RemoveNthQ( ring_find(This.ListOfStrings(), pValue) ).Content()
				This.Update( anResult )
			
			but isList(pValue) and Q(pValue).IsListofNumbers()
				if len(pValue) > 0
					oStzList = This.ToStzList()
					anPositions = oStzList.FindMany(pValue)
					oStzList.RemoveItemsAtPositions(anPositions)
					anResult = oStzList.Content()
					return anResult
				ok

			but @IsStzList(pValue) and pValue.IsListOfNumbers()
				if len(pValue.Content()) > 0
					oStzList = This.ToStzList()
					anPositions = oStzList.FindMany(pValue.Content())
					oStzList.RemoveItemsAtPositions(anPositions)
					anResult = oStzList.Content()
					This.UpdateWith(anResult)
				ok
			ok

		but pcOp = "*"
			anTemp = This.ToStzList().MultiplyByQ(pValue).Content()
			This.Update( anTemp )

		but pcOp = "+"
			anTemp = This.ToStzList().AddItemQ(pValue).Content()
			This.Update( anTemp )
		ok
