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

func StzListOfNumbers(paListOfNumbers)
	return new stzListOfNumbers(paListOfNumbers)

func StzListOfNumbersQ(paListOfNumbers)
	return new stzListOfNumbers(paListOfNumbers)

func ListOfNumbersSum(paListOfNumbers)
	oListOfNumbers = new stzListOfNumbers(paListOfNumbers)
	return oListOfNumbers.Sum()

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
	@aContent

	def init(paList)
		if isList(paList) and StzListQ(paList).IsListOfNumbers()
			@aContent = paList
		ok

	def Content()
		aResult = @aContent

		return aResult

	def ListOfNumbers()
		return Content()

	def Copy()
		oCopy = new stzListOfNumbers( This.Content() )
		return oCopy

	def ToStzList()
		return new stzList(This.Content())

	def ToStzListOfStrings()
		acResult = []

		for n in This.ListOfNumbers()
			acResult + ( ""+ n )
		next

		return new stzListOfStrings(acResult)

	def NumbersTurnedToStrings()
		aResult = This.ToStzListOfStrings().Content()

		return aResult

		def Stringified()
			return This.NumbersTurnedToStrings()

		def AllNumbersTurnedToStrings()
			return This.NumbersTurnedToStrings()

	  #-------------------------#
	 #     MINIMUM NUMBER(S)   #
	#-------------------------#

	def Min()
		return This.ToStzList().SortInAscendingQ().FirstItem()

		def MinQ(n)
			return This.MinQR(n, :stzNumber)

		def MinQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzNumber
				return new stzNumber( This.Min(n) )

			on :stzString
				return new stzString( This.Min(n) )

			other
				stzRaise("Unsupported return type!")
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
					stzRaise("Unsupported return type!")
				off

	def FindMin()
		aResult = This.ToStzList().FindAllW('{ @item = ' + This.Min() + ' }')

		return aResult

		def FindMinNumber()
			return This.FindMin()

		def PositionOfMin()
			return return This.FindMin()

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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def NMinNumbers(n)
			return This.MinNumbers(n)

			def NMinNumbersQ(n)
				return This.NMinNumbersQR(n, :stzList)

			def NMinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
				off
		#>

	def FindMinNumbers(n)
		aResult = []

		for number in This.MinNumbers(n)
			aResult + This.FindAll(number)
		next

		aResult = StzListQ(aResult).FlattenQ().SortInAscendingQ().Content()

		return aResult

		#< @FunctionFluentForm

		def FindMinNumbersQ(n)
			return This.FindMinNumbersQR(n, :stzList)

		def FindMinNumbersQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForms

		def FindNMinNumbers(n)
			return This.FindMinNumbers(n)

			def FindNMinNumbersQ(n)
				return This.FindNMinNumbersQR(n, :stzList)
	
			def FindNMinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
				off

		def PositionsOfMinNumbers(n)
			return This.FindMinNumbers(n)

			def PositionsOfMinNumbersQ(n)
				return This.PositionsOfMinNumbersQR(n, :stzList)
	
			def PositionsOfMinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
				off

		def PositionsOfNMinNumbers(n)
			return This.FindMinNumbers(n)

			def PositionsOfNMinNumbersQ(n)
				return This.PositionsOfNMinNumbersQR(n, :stzList)
	
			def PositionsOfNMinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
				off
		#>

	  #-------------------------#
	 #     MAXIMUM NUMBER(S)   #
	#-------------------------#

	def Max()
		return This.ToStzList().RemoveDuplicatesQ().SortInAscendingQ().LastItem()

		def MaxQ(n)
			return This.MaxQR(n, :stzNumber)

		def MaxQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzNumber
				return new stzNumber( This.Max(n) )

			on :stzString
				return new stzString( This.Max(n) )

			other
				stzRaise("Unsupported return type!")
			off

		def MaxNumber()
			return This.Max()

			def MaxNumberQ(n)
				return This.MaxNumberQR(n, :stzNumber)
	
			def MaxNumberQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzNumber
					return new stzNumber( This.MaxNumber(n) )
	
				on :stzString
					return new stzString( This.MaxNumber(n) )
	
				other
					stzRaise("Unsupported return type!")
				off

	def FindMax()
		aResult = This.ToStzList().FindAllW('{ @item = ' + This.Max() + ' }')

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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
				stzRaise("Unsupported return type!")
			off

		#>

		def TopNumbers(n)
			return This.Top(n)
	
			def TopNumbersQ(n)
				return This.TopNumbersQR(n, :stzList)
	
			def TopNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
				off
	
		def NTopNumbers(n)
			return This.Top(n)

			def NTopNumbersQ(n)
				return This.NTopNumbersQR(n, :stzList)
	
			def NTopNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
				off

		def TopNNumbers(n)
			return This.Top(n)

			def TopNNumbersQ(n)
				return This.TopNNumbersQR(n, :stzList)
	
			def TopNNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
				off

		def MaxNumbers(n)
			return This.Top(n)
	
			#< @FunctionFluentForm
	
			def MaxNumbersQ(n)
				return This.MaxNumbersQR(n, :stzList)
	
			def MaxNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
				off

		def MaxNNumbers(n)
			return This.Top(n)

			def MaxNNumbersQ(n)
				return This.MaxNNumbersQR(n, :stzList)
	
			def MaxNNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
				off

		def NMaxNumbers(n)
			return This.Top(n)

			def NMaxNumbersQ(n)
				return This.NMaxNumbersQR(n, :stzList)
	
			def NMaxNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
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
					stzRaise("Unsupported return type!")
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
		aResult = []

		for number in This.Top(n)
			aResult + This.FindAll(number)
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

		def PositionsOfTopNumbers(n)
			return This.FindTop(n)

		def PositionsOfTopNNumbers(n)
			return This.FindTop(n)

		#> @EndOfFunctionAlternativeForms


	def TopNumbersAndTheirPositions(n)

		anNumbers = This.Top(n)

		aResult = []

		for number in anNumbers

			cNumber     = ""+ number
			anPositions = This.ToStzList().FindAll(number)

			aResult + [ cNumber, anPositions ]
		next

		return aResult

		#< @FunctionAlternativeForms

		def TopNNumbersAndTheirPositions(n)
			return This.TopNumbersAndTheirPositions(n)

		def MaxNumbersAndTheirPositions(n)
			return This.TopNumbersAndTheirPositions(n)
		#>

	  #---------------------------#
	 #     BASIC CALCULATIONS    #
	#---------------------------#

	def Product()
		nResult = 1
		for n in This.ListOfNumbers()
			nResult *= n
		next

		return nResult

	def Sum()
		nResult = 0
		for n in This.ListOfNumbers()
			nResult += n
		next
		return nResult

	def Mean()
		return Sum() / (This.ToStzList().NumberOfItems())

	def MeanByCoefficient(paList)
		// [ 16, 18, 20, 17 ]
		// [  4,  2,  2,  1 ]
		i = 0

		aProduct = []
		for i=1 to This.ToStzList().NumberOfItems()
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
		aResult = []

		for number in This.ListOfNumbers()
			oNumber = new stzNumber(number)
			if oNumber.IsDividableBy(n)
				aResult + number
			ok
		next

		return aResult

	  #--------------------------------------#
	 #     CLIPPING THE LIST OF NUMBERS     #
	#--------------------------------------#

	// Limits the values of the list by adjusting the numbers outside
	// the provided range (nMin, nMax). Each item lesser then nMin
	// becomes equal to nMin. And each item greater then nMax becomes
	// equal to nMax. See example below...
	def Clip(nMin, nMax)
		/*
		o1 = new stzListOfNumbers([1, 2, 3, 4, 5, 6, 7, 8 ])
		? o1.Clip(3, 5)
		// --> Should return: [ 3, 3, 3, 4, 5, 5, 5, 5, 5 ])
		*/

		for n in This.ListOfNumbers()
			if n < nMin
				n = nMin
			but n > nMax
				n = nMax
			ok
		next

	def ClipQ(nMin, nMax)
		This.Clip(nMin, nMax)
		return This

	  #-----------------------------------------#
	 #     REPLACING A SECTION OF THE LIST     #
	#-----------------------------------------#

	def ReplaceSectionWith(n1, n2, n)
		for i = 1 to This.NumberOfItems()
			if i >= n1 and i <= n2
				This.Content()[i] = n
			ok
		next
		
	def ReplaceSectionWithQ(n1, n2, n)
		This.UpdateSectionWith(n1, n2, n)
		return This

	def ReplaceSectionWithFunction(n1, n2, pcFunc)
		// TODO

	  #----------------------------#
	 #     CUMULATING NUMBERS     #
	#----------------------------#

	def Cumulate()
		// TODO

	def Cumulated()
		// TODO

	  #-----------------#
	 #     UNICODE     #
	#-----------------#

	// Gets the unicode numbers contained in the list
	def Unicodes()
		aResult = []
		for n in This.ListOfNumbers()
			if IsUnicodeNumber(n)
				aResult + n
			ok
		next

		return aResult

		#< @FunctionFluentForm

		def UnicodesQ()
			return new stzListOfUnicodes( This.Unicodes() )

		#>

	  #----------------------------------------#
	 #     ADDING A NUMBEr TO EACH NUMBER     #
	#----------------------------------------#

	def AddToEveryItem(n)
		for item in This.ListOfNumbers()
			item += n
		next

		def AddToEveryItemQ(n)
			This.AddToEveryItem(n)
			return This

	def SubstractFromEveryItem(n)
		for item in This.ListOfNumbers()
			item -= n
		next

		def SubstractFromEveryItemQ(n)

			This.SubstractFromEveryItem(n)
			return This

		def RetrieveFromEveryItem(n)
			return This.SubstractFromEveryItem(n)

			def RetrieveFromEveryItemQ(n)
				This.RetrieveFromEveryItem(n)
				return This

	def AddToEach(n)
		for number in This.ListOfNumbers()
			number += n
		next

		def AddToEachQ(n)
			This.AddToEach(n)
			return This

		def AugmentEachNumberBy(n)
			This.AddToEach(n)

			def AugmentEachNumberByQ(n)
				This.AugmentEachNumberBy(n)
				return This

		def AddNToEach(n)
			This.AddToEach(n)

			def AddNToEachQ(n)
				This.AddNToEach(n)
				return This

	def AddedToEach(n)
		aResult = This.Copy().AddToEachQ(n).Content()
		return aResult

		def EachNumberAugmentedBy(n)
			return This.AddedToEach(n)

		def NAddedToEach(n)
			return This.AddedToEach(n)

	  #------------------------------------------------#
	 #     SUBSTRACTING A NUMBER FROM EACH NUMBER     #
	#------------------------------------------------#

	def SubstractFromEach(n)
		for number in This.ListOfNumbers()
			number -= n
		next

		def SubstractFromEachQ(n)
			This.SubstractFromEach(n)
			return This

		def SubstractEachNumberBy(n)
			This.SubstractFromEach(n)

			def SubstractEachNumberByQ(n)
				This.SubstractEachNumberBy(n)
				return This

		def SubstratcNFromEach(n)
			This.SubstractFromEach(n)

			def SubstratcNFromEachQ(n)
				This.SubstratcNFromEach(n)
				return This

	def EachNumberSubstractedBy(n)
		aResult = This.Copy().SubstratcEachNumberByQ(n).Content()

		return aResult

		def EachSubstractedBy(n)
			return This.EachNumberSubstractedBy(n)

		def NSubstractedFromEach(n)
			return This.EachNumberSubstractedBy(n)

	  #---------------------------------------------#
	 #     MULTIPLYING EACH NUMBER BY A NUMBER     #
	#---------------------------------------------#

	def MultiplyEachBy(n)
		for number in This.ListOfNumbers()
			number *= n
		next

		def MultiplyEachByQ(n)
			This.MultiplyEachBy(n)
			return This

		def MultiplyEachNumberBy(n)
			This.MultiplyEachBy(n)

			def MultiplyEachNumberByQ(n)
				This.MultiplyEachNumberBy(n)
				return This

	def EachNumberMultipliedBy(n)
		aResult = This.Copy().MultiplyEachNumberByQ(n).Content()

		return aResult

		def EachMultipliedBy(n)
			return This.EachNumberMultipliedBy(n)

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

	def Update(pnNewNumber)

		if isList(pnNewNumber) and StzListQ(pnNewNumber).IsWithParamList()
			pnNewNumber = pnNewNumber[2]
		ok

		@aContent = pnNewNumber

	  #------------------------------------------#
	 #     DIVIDING EACH NUMBER BY A NUMBER     # // TODO: complete it
	#------------------------------------------#

	def DivideEachBy(n)
		for number in This.ListOfNumbers()
			number = number / n
		next

		def DivideEachByQ(n)
			This.DivideEachBy(n)
			return This

	
