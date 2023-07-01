#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - StzListOfNumbers		    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing lists of numbers      #
#	Version		: V1.0 (2020-2022)				    #
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

  ////////////////
 ///  CLASS   ///
////////////////

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

	def Copy()
		oCopy = new stzListOfNumbers( This.Content() )
		return oCopy

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

	  #-------------------------#
	 #     MINIMUM NUMBER(S)   #
	#-------------------------#

	def Min()

		if len(This.Content()) = 0
			StzRaise("Can't proceed! Because the list is empty.")
		ok

		aSorted = This.Sorted()
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
				return new stzNumber( This.Min(n) )

			on :stzString
				return new stzString( This.Min(n) )

			other
				StzRaise("Unsupported return type!")
			off

		def MinNumber()
			return This.Min()

			def MinNumberQ(n)
				return This.MinNumberQR(n, :stzNumber)
	
			def MinNumberQR(n, pcReturnType)
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

		def FindMinNumber()
			return This.FindMin()

		def PositionOfMin()
			return This.FindMin()

		def PositionOfMinNumber()
			return This.FindMin()

		def MinPosition()
			return This.FindMin()

		def MinNumberPosition()
			return This.FindMin()

	def MinNumbers(n)
		aResult = This.ToStzList().SortInAscendingQ().Section(1, n)

		return aResult

		#< @FunctionfluentForm

		def MinNumbersQ(n)
			return MinNumbersQR(n, :stzList)

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
				return StzListOfNumbersQ(This.MinNumbers()).ToStzListOfStrings()

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def NMinNumbers(n)
			return This.MinNumbers(n)

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
					return StzListOfNumbersQ(This.NMinNumbers()).ToStzListOfStrings()

				other
					StzRaise("Unsupported return type!")
				off
		#>

	def FindMinNumbers(n)
		anNumbers = This.MinNumbers(n)
		nLen = len(anNumbers)

		aResult = []

		for i = 1 to nLen
			aResult + This.FindAll(anNumbers[i])
		next

		aResult = StzListQ(aResult).FlattenQ().SortInAscendingQ().Content()

		return aResult

		#< @FunctionFluentForm

		def FindMinNumbersQ(n)
			return This.FindMinNumbersQR(n, :stzList)

		def FindMinNumbersQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.FindMinNumbers(n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindMinNumbers(n) )

			on :stzListOfStrings
				return StzListOfNumbersQ(This.FindMinNumbers()).ToStzListOfStrings()

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def FindNMinNumbers(n)
			return This.FindMinNumbers(n)

			def FindNMinNumbersQ(n)
				return This.FindNMinNumbersQR(n, :stzList)
	
			def FindNMinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.FindNMinNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindNMinNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.FindNMinNumbers()).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def PositionsOfMinNumbers(n)
			return This.FindMinNumbers(n)

			def PositionsOfMinNumbersQ(n)
				return This.PositionsOfMinNumbersQR(n, :stzList)
	
			def PositionsOfMinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.PositionsOfMinNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.PositionsOfMinNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.PositionsOfMinNumbers()).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def MinNumbersPositions(n)
			return This.FindMinNumbers(n)

			def MinNumbersPositionsQ(n)
				return This.MinNumbersPositionsQR(n, :stzList)
	
			def MinNumbersPositionsQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.MinNumbersPositions(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.MinNumbersPositions(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.MinNumbersPositions()).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def PositionsOfNMinNumbers(n)
			return This.FindMinNumbers(n)

			def PositionsOfNMinNumbersQ(n)
				return This.PositionsOfNMinNumbersQR(n, :stzList)
	
			def PositionsOfNMinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.PositionsOfNMinNumbers(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.PositionsOfNMinNumbers(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.PositionsOfNMinNumbers()).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		def NMinNumbersPositions(n)
			return This.FindMinNumbers(n)

			def NMinNumbersPositionsQ(n)
				return This.NMinNumbersPositionsQR(n, :stzList)
	
			def NMinNumbersPositionsQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.NMinNumbersPositions(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.NMinNumbersPositions(n) )
	
				on :stzListOfStrings
					return StzListOfNumbersQ(This.NMinNumbersPositions()).ToStzListOfStrings()
	
				other
					StzRaise("Unsupported return type!")
				off

		#>

	def MinNumbersAndTheirPositions(n)

		anNumbers = This.MinNumbers(n)
		nLen = len(anNumbers)

		aResult = []

		for i = 1 to nLen

			cNumber     = ""+ anNumbers[i]
			anPositions = This.ToStzList().FindAll(anNumbers[i])

			aResult + [ cNumber, anPositions ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def MinNNumbersAndTheirPositions(n)
			return This.MinNumbersAndTheirPositions(n)

		#--

		def MinNumbersZ(n)
			return This.MinNumbersAndTheirPositions(n)

		#>

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

		def FindMaxNumber()
			return This.FindMax()

		def MaxPosition()
			return This.FindMAx()

		def PositionOfMaxNumber()
			return This.FindMax()

		def MaxNumberPosition()
			return This.FindMax()

	def Top(n)
		aResult = This.ToStzList().RemoveDuplicatesQ().SortInDescendingQ().Section(1, n)

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

		aResult = stzListQ(aResult).FlattenQ().SortedInAscending()

		return aResult

		#< @FunctionAlternativeForms

		def FindMaxNumbers(n)
			return This.FindTop(n)

		def FindTopNumbers(n)
			return This.FindTop(n)

		def FindTopNNumbers(n)
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

		#> @EndOfFunctionAlternativeForms


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

			  ])
			)

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

			  ])
			)

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

		#< @FunctionAlternativeForm

		def NearestTo(n)
			return This.Nearest(n)

		#>

		#< @FunctionMisspelledForm

		def Nearst(n)
			return This.Nearest(n)

		def NearstTo(n)
			return This.Nearest(n)

		#--

		def NearestNumber(n)
			return This.Nearest(n)

		def NearstNumber(n)
			return This.Nearest(n)

		def NearstNumberTo(n)
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

		def NearestNeighbors(n)
			return This.Neighbors(n)

		def NearestNeighborsOf(n)
			return This.Neighbors(n)

		def NearestNeighborsTo(n)
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

		def NearestNeighboringNumbers(n)
			return This.Neighbors(n)

		def NearestNeighboringNumbersOf(n)
			return This.Neighbors(n)

		def NearestNeighboringNumbersTo(n)
			return This.Neighbors(n)

		def NNeighboringNumbers(n)
			return This.Neighbors(n)

		def NNeighboringNumbersOf(n)
			return This.Neighbors(n)

		def NNeighboringNumbersTo(n)
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

	  #-----------------#
	 #     UNICODE     #
	#-----------------#

	# Gets the unicode numbers contained in the list

	# Don't be confused with StzListOfChars().Unicodes() that
	# returns the unicodes of all the chars in the list.

	#--> If you need to get the unicodes of all the numbers here
	# in the list of numbers, then you should cast it to a
	# stzListOfChars object and then use Unicodes() on it:

	#     This.ToStzListOfChars(...).Unicodes()

	# to avoid sutch confusion, it is better to use the aternative
	# name OnlyUnicodes()

	def Unicodes()
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

		def UnicodesQ()
			return This.UnicodesQR(:stzList)

		def UnicodesQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Unicodes() )

			on :stzListOfNumbers
				return new stzList( This.Unicodes() )

			other
				StzRaise("Unsupported return type!")
			off

		def OnlyUnicodes()
			return This.OnlyUnicodes()

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
	 #     SUBSTRACTING A NUMBER FROM EACH NUMBER     #
	#------------------------------------------------#

	def SubstractFromEach(n)
		anContent = This.Content()
		nLen = len(anContent)

		anResult = []

		for i = 1 to nLen
			anResult + (anContent[i] - n)
		next

		This.Update(anResult)

		def SubstractFromEachQ(n)
			This.SubstractFromEach(n)
			return This

	def SubstractedFromEach(n)
		anResult = This.Copy().SubstractFromEachQ(n).Content()
		return anResult

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
	 #   SUBSTRACTING MANY NUMBERS ONE BY ONE   #
	#------------------------------------------#

	def SubstractManyOneByOne(paNumbers)

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

		def SubstractManyOneByOneQ(paNumbers)
			This.SubstractManyOneByOne(paNumbers)
			return This

	def ManySubstractedOneByOne(paNumbers)
		aResult = This.Copy().SubstractManyOneByOneQ(n).Content()
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
	 #   SUBSTRACT NUMBER FROM EACH UNDER A GIVEN CONDITION   #
	#--------------------------------------------------------#

	def SubstractFromEachW(n, pcCondition)
		This.AddToEachW(-n, pcCondition)

		def SubstractFromEachWQ(n)
			This.SubstractFromEachW(n)
			return This

	def SubstractedFromEachW(n)
		aResult = This.Copy().SubstractFromEachWQ(n).Content()
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

	  #------------------------------#
	 #     OPERATORS OVERLOADING    # 
	#------------------------------#

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
		

		but pcOp = "/" and ring_type(pValue) = "NUMBER"
			// Divides the list on pValue sublists (a list of lists)
			return This.ToStzList().SplitToNParts(pValue)

		but pcOp = "-"
			if isNumber(pValue)
				anTemp = This.ToStzList().RemoveNthQ( ring_find(This.ListOfStrings(), pValue) ).Content()
				This.Update( anTemp )

			but isList(pValue) and Q(pValue).IsListofNumbers()
				if len(pValue) > 0
					oStzList = This.ToStzList()
					anPositions = oStzList.FindMany(pValue)
					oStzList.RemoveItemsAtPositions(anPositions)
					anTemp = oStzList.Content()
					This.Update( anTemp )
				ok
			ok

		but pcOp = "*"
			anTemp = This.ToStzList().MultiplyByQ(pValue).Content()
			This.Update( anTemp )

		but pcOp = "+"
			anTemp = This.ToStzList().AddItemQ(pValue).Content()
			This.Update( anTemp )
		ok
