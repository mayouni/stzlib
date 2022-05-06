#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - STZSTRING			    #
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
	@anContent

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
					stzRaise("The list in the string you provided is not a list of numbers!")
				ok

			catch
				stzRaise("Can't transform the string into a llist of numbers!")
			done
		else
			stzRaise("Can't create a stzListOfNumbers object!")
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
					stzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Numbers() )

				on :stzListOfStrings
					return new stzListOfStrings( This.Numbers() )

				other
					stzRaise("Unsupported return type!")
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
				stzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumbersW(pcCondition) )

			on :stzListOfNumbers
				return new stzListOfStrings( This.NumbersW(pcCondition) )

			other
				stzRaise("Unsupported return type!")
			off

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

	def NumberAt(n)
		return This.ItemAt(n)	# Inherited from stzList

		def NumberAtPosition(n)
			return This.NumberAt(n)

	  #-------------------------#
	 #     MINIMUM NUMBER(S)   #
	#-------------------------#

	def Min()
		return This.ToStzList().SortInAscendingQ().FirstItem()

		def MinQ(n)
			return This.MinQR(n, :stzNumber)

		def MinQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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

		def MinNumbersPositions(n)
			return This.FindMinNumbers(n)

			def MinNumbersPositionsQ(n)
				return This.MinNumbersPositionsQR(n, :stzList)
	
			def MinNumbersPositionsQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
					stzRaise("Unsupported return type!")
				off

		def PositionsOfNMinNumbers(n)
			return This.FindMinNumbers(n)

			def PositionsOfNMinNumbersQ(n)
				return This.PositionsOfNMinNumbersQR(n, :stzList)
	
			def PositionsOfNMinNumbersQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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

		def NMinNumbersPositions(n)
			return This.FindMinNumbers(n)

			def NMinNumbersPositionsQ(n)
				return This.NMinNumbersPositionsQR(n, :stzList)
	
			def NMinNumbersPositionsQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParamList()
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

	  #----------------------------------------------------#
	 #     NEAREST NUMBER IN THE LIST TO A GIVEN NUMBER   #
	#----------------------------------------------------#

	def NearestTo(n) 
		# Let n = 12
		# Let This = [ 2, 7, 18, 10, 25, 4 ]

		anDif = []
		for nbr in This.ListOfNumbers()
			nDif = n - nbr
			if nDif < 0 { nDif = -nDif }
			anDif + nDif
		next

		#--> anDif = [ -10, -5, 6, -2, 13, -8]
		#--> anDif = [  10,  5, 6,  2, 13, 8 ]

		anDifCopy = anDif

		anDifCopy = sort(anDifCopy)
		#--> anDif = [  2, 5, 6, 8, 10, 13]
		nMinDif = anDifCopy[1] #--> 2

		nMinPos = find( anDif, nMinDif)

		#--> anDif = [  10, 5, 6, 2, 13, 8 ]
		#             ------------^--------
		#                         4

		nResult = This.Content()[ nMinPos ]
		#--> [ 2, 7, 18, 10, 25, 4 ]
		#     -----------^---------

		return nResult
			
	  #---------------------------------------------------#
	 #   FARTHEST NUMBER IN THE LIST TO A GIVEN NUMBER   #
	#---------------------------------------------------#

	def FarthestTo(n) 
		# Let n = 12
		# Let This = [ 2, 7, 18, 10, 25, 4 ]

		anDif = []
		for nbr in This.ListOfNumbers()
			nDif = n - nbr
			if nDif < 0 { nDif = -nDif }
			anDif + nDif
		next

		#--> anDif = [ -10, -5, 6, -2, 13, -8]
		#--> anDif = [  10,  5, 6,  2, 13, 8 ]

		anDifCopy = anDif

		anDifCopy = sort(anDifCopy)
		#--> anDif = [  2, 5, 6, 8, 10, 13]
		nMinDif = anDifCopy[len(anDifCopy)] #--> 13

		nMinPos = find( anDif, nMinDif)

		#--> anDif = [  10, 5, 6, 2, 13, 8 ]
		#             ---------------^------
		#                            6

		nResult = This.Content()[ nMinPos ]
		#--> [ 2, 7, 18, 10, 25, 4 ]
		#     ---------------^------

		return nResult

	  #----------------------------------------#
	 #     "ABSOLUTING' THE LIST OF NUMBERS   #
	#----------------------------------------#

	def Absolute()
		for n in This.ListOfNumbers()
			if n < 0
				n = -n
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
		for n in This.ListOfNumbers()
			if n > 0
				n = -n
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

		for n in This.ListOfNumbers()
			if n < nMin
				n = nMin
			but n > nMax
				n = nMax
			ok
		next

		def ClipQ(nMin, nMax)
			return This.ClipQR(nMin, nMax, pcReturnType)

		def ClipQR(nMin, nMax, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Clip(nMin, nMax) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Clip(nMin, nMax) )

			other
				stzRaise("Unsupported return type!")
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
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ReplaceSectionWith(n1, n2, n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.ReplaceSectionWith(n1, n2, n) )

			other
				stzRaise("Unsupported return type!")
			off

	  #----------------------------#
	 #     CUMULATING NUMBERS     #
	#----------------------------#

	def Cumulate()
		aResult = []

		for i = 3 to This.NumberOfNumbers()
			@anContent[i] += @anContent[i-1]
		next
			
		def CumulateQ()
			return This.CumulateQR()

		def CumulateQR()
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Cumulate() )

			on :stzListOfNumbers
				return new stzList( This.Cumulate(n1) )

			other
				stzRaise("Unsupported return type!")
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
		aResult = []
		for n in This.ListOfNumbers()
			if IsUnicodeNumber(n)
				aResult + n
			ok
		next

		return aResult

		def UnicodesQ()
			return This.UnicodesQR(:stzList)

		def UnicodesQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Unicodes() )

			on :stzListOfNumbers
				return new stzList( This.Unicodes() )

			other
				stzRaise("Unsupported return type!")
			off

		def OnlyUnicodes()
			return This.OnlyUnicodes()

			def OnlyUnicodesQ()
				return This.CumulateQR(:stzList)

			def OnlyUnicodesQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsNamedParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.OnlyUnicodes() )
	
				on :stzListOfNumbers
					return new stzList( This.OnlyUnicodes() )
	
				other
					stzRaise("Unsupported return type!")
				off

	  #========================================#
	 #     ADDING A NUMBER TO EACH NUMBER     #
	#========================================#

	def AddToEach(n)
		
		for i = 1 to This.NumberOfNumbers()
			@anContent[i] += n
		next

		def AddToEachQ(n)
			This.AddToEach(n)
			return This

	def AddedToEach(n)
		aResult = This.Copy().AddToEachQ(n).Content()
		return aResult

	  #------------------------------------------------#
	 #     SUBSTRACTING A NUMBER FROM EACH NUMBER     #
	#------------------------------------------------#

	def SubstractFromEach(n)
		for number in @anContent
			number -= n
		next

		def SubstractFromEachQ(n)
			This.SubstractFromEach(n)
			return This

	def SubstractedFromEach(n)
		aResult = This.Copy().SubstractFromEachQ(n).Content()
		return aResult

	  #---------------------------------------------#
	 #     MULTIPLYING EACH NUMBER BY A NUMBER     #
	#---------------------------------------------#

	def MultiplyEachBy(n)
		for number in This.Content()
			number *= n
		next

		def MultiplyEachByQ(n)
			This.MultiplyEachBy(n)
			return This

	def EachMultipliedBy(n)
		aResult = This.Copy().MultiplyEachByQ(n).Content()
		return aResult

	  #------------------------------------------#
	 #     DIVIDING EACH NUMBER BY A NUMBER     # 
	#------------------------------------------#

	def DivideEachBy(n)
		for number in This.Content()
			number /= n
		next

		def DivideEachByQ(n)
			This.DivideEachBy(n)
			return This

	def EachDividedBy(n)
		aResult = This.Copy().DivideEachByQ(n).Content()
		return aResult

	  #====================================#
	 #   ADDING MANY NUMBERS ONE BY ONE   #
	#====================================#

	def AddManyOneByOne(paNumbers)

		if NOT ( isList(paNumbers) and Q(paNumbers).IsListOfNumbers() )
			stzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		nLen1 = This.NumberOfNumbers()
		nLen2 = len(paNumbers)

		i = 0
		for number in This.Content()
			i++

			if i <= nLen1 and i <= nLen2
				number += paNumbers[i]
			ok

		next

		def AddManyOneByOneQ(paNumbers)
			This.AddManyOneByOne(paNumbers)
			return This

	def ManyAddOneByOne(paNumbers)
		aResult = This.Copy().AddManyOneByOneQ(n).Content()
		return aResult

	  #------------------------------------------#
	 #   SUBSTRACTING MANY NUMBERS ONE BY ONE   #
	#------------------------------------------#

	def SubstractManyOneByOne(paNumbers)

		if NOT ( isList(paNumbers) and Q(paNumbers).IsListOfNumbers() )
			stzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		nLen1 = This.NumberOfNumbers()
		nLen2 = len(paNumbers)

		i = 0
		for number in This.Content()
			i++

			if i <= nLen1 and i <= nLen2
				number -= paNumbers[i]
			ok

		next

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
			stzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		nLen1 = This.NumberOfNumbers()
		nLen2 = len(paNumbers)

		i = 0
		for number in This.Content()
			i++

			if i <= nLen1 and i <= nLen2
				number *= paNumbers[i]
			ok

		next

		def MultiplyWithManyOneByOneQ(paNumbers)
			This.MultiplyWithManyOneByOne(paNumbers)
			return This

		def MultiplyByManyOneByOne(paNumbers)
			return This.MultiplyWithManyOneByOne(paNumbers)

	def MultipliedWithManyOneByOne(paNumbers)
		aResult = This.Copy().MultiplyWithManyOneByOneQ(n).Content()
		return aResult

		def MultipliedByManyOneByOne(paNumbers)
			return This.MultipliedWithManyOneByOne(paNumbers)

	  #-------------------------------------------------------------------#
	 #   DEVIDING THE NUMBERS OF THE LIST WITH MANY NUMBERS ONE BY ONE   #
	#-------------------------------------------------------------------#

	def DivideByManyOneByOne(paNumbers)

		if NOT ( isList(paNumbers) and Q(paNumbers).IsListOfNumbers() )
			stzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		nLen1 = This.NumberOfNumbers()
		nLen2 = len(paNumbers)

		i = 0
		for number in This.ListOfNumbers()
			i++

			if i <= nLen1 and i <= nLen2
				number /= paNumbers[i]
			ok

		next

		def DivideByManyOneByOneQ(paNumbers)
			This.DivideByManyOneByOne(paNumbers)
			return This

	def DividedByManyOneByOne(paNumbers)
		aResult = This.Copy().DivideByManyOneByOneQ(n).Content()
		return aResult

	  #===================================================#
	 #   ADDING NUMBER TO EACH UNDER A GIVEN CONDITION   #
	#===================================================#

	def AddToEachW(n, pcCondition)
		if NOT isNumber(n)
			stzRaise("Incorrect param type! n must be a number.")
		ok


		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParamList()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			stzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		cCondition = StzCCodeQ(cCondition).UnifiedFor(:stzListOfNumbers)

		cCode = "bOk = (" + cCondition + ")"
		oCode = new stzString(cCode)

		@i = 0
		for @number in This.ListOfNumbers()
			@i++
			bEval = TRUE

			if @i = This.NumberOfNumbers() and
			   oCode.Copy().RemoveSpacesQ().ContainsCS( "This[i+1]", :CS = FALSE )

				bEval = FALSE
			ok

			if @i = 1 and
			   oCode.Copy().RemoveSpacesQ().ContainsCS( "This[i-1]", :CS = FALSE )

				bEval = FALSE
			ok

			if bEval
				eval(cCode)
				if bOk
					@number += n
				ok
			ok
		next

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
			stzRaise("Incorrect param type! n must be a number.")
		ok


		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParamList()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			stzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		cCondition = StzCCodeQ(cCondition).UnifiedFor(:stzListOfNumbers)
		cCode = "bOk = (" + cCondition + ")"
		oCode = new stzString(cCode)

		@i = 0
		for @number in This.ListOfNumbers()
			@i++
			bEval = TRUE

			if @i = This.NumberOfNumbers() and
			   oCode.Copy().RemoveSpacesQ().ContainsCS( "This[i+1]", :CS = FALSE )

				bEval = FALSE

			ok

			if @ = 1 and
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

		if isList(panNewListOfNumbers) and StzListQ(panNewListOfNumbers).IsWithNamedParamList()
			pnNewListOfNumbers = pnNewListOfNumbers[2]
		ok

		if NOT ( isList(panNewListOfNumbers) and
			 Q(panNewListOfNumbers).IsListOfNumbers()
		       )

			stzRaise("Incorrect param type!")
		ok

		@anContent = panNewListOfNumbers

		def UpdateWith(panNewListOfNumbers)
			if NOT ( isList(panNewListOfNumbers) and
				 Q(panNewListOfNumbers).IsListOfNumbers()
			       )

				stzRaise("Incorrect param! You must provide a list of numbers.")
			ok

			@anContent = panNewListOfNumbers


	  #-----------------------------------------------------------#
	 #     REPLACING A NUMBER AT A GIVEN POSITION IN THE LIST    #
	#-----------------------------------------------------------#

	def ReplaceNumberAtPosition(n, pnNewNumber)

		if NOT isNumber(n)
			stzRaise("Incorrect param! n must be a number.")
		ok

		if isList(pnNewNumber) and Q(pnNewNumber).IsWithOrByNamedParamList()
			pnNewNumber = pnNewNumber[2]
		ok

		if NOT isNumber(pnNewNumber)
			stzRaise("Incorrect param! pnNewNumber must be a number.")
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
			stzRaise("Invalid param type! panPositions must be a list of numbers.")
		ok

		if NOT isString(pcCode)
			stzRaise("Invalid param type! pcCode must be a string.")
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

			stzRaise("Syntax error! pcCode must begin with '@item ='.")
		ok

		cCode = oCode.Content()
		
		for @i in panPositions

			@number = This[ @i ]
			bEval = TRUE

			if @i = This.NumberOfNumbers() and
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

	def ToStzListOfChars()
		return new stzListOfChars( This.Content() )

	def NumberOfNumbers()
		return len( This.Content() )

	def IsContiguous()
		if This.NumberOfNumbers() < 2
			return FALSE
		ok

		bResult = TRUE

		if This.ToStzList().SortingOrder() = :Ascending

			for i = 2 to This.NumberOfNumbers()
	
				if NOT ( This[i] = This[i-1] + 1 )
					bResult = FALSE
					exit
				ok
			next

		else # SortingOrder --> :Descending

			for i = 2 to This.NumberOfNumbers()

				if NOT ( This[i] = This[i-1] - 1 )
					bResult = FALSE
					exit
				ok
			next
		ok

		return bResult


		def IsContinuous()
			return This.IsContiguous()
