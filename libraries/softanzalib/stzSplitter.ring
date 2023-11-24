
/*
This class is a numrical solution to splitting things.

A splitter recieves a number of N positions. If it is a list then its
number of items is considered as N.

Then the splitter initializes an internal list of numbers from 1 to N.

Then the several splitting features are provided (see class methods).

Each of these methods returns a list pof sections (as pairs of numbers).

In practice, stzSplitter is called from inside a stzString or stzList. In this
case, the returned sections are passed to stzString.Sections() or stzList.Sections()
to provide us with the splitted parts of the string or the list.
	
*/

func StzSplitterQ(p)
	return new stzSplitter(p)

class stzSplitter from stzListOfNumbers

	@nNumberOfPositions

	  #--------------------------------#
	 #    INITIALIZING THE SPLITTER   #
	#--------------------------------#

	def init(n)

		if isNumber(n)

			if n < 0
				StzRaise("p must be positive!") #--> TODO: stzListError
			ok

			@nNumberOfPositions = n

		but isString(n)
			@nNumberOfPositions = Q(n).NumberOfChars()

		but isList(n)
			@nNumberOfPositions = Q(n).NumberOfItems()

		else
			StzRaise("Incorrect param type! n must be a number or string or list.")
		ok

	def NumberOfPositions()
		return @nNumberOfPositions

		def NumberOfItems()
			return This.NumberOfPositions()

	def Content()
		aResult = 1:This.NumberOfPositions()
		return aResult

		def Value()
			return Content()

	def Copy()
		return new stzSplitter( 1: This.NumberOfPositions() )

	  #========================================#
	 #    SPLITTING : THE GENERIC FUNCTION    #
	#========================================#

	def SplitXT(p)
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok

		oParam = Q(p)

		if oParam.IsListOfNumbers()
			return This.SplitAtPositions(p)
		
		#== AtPosition(s)

		but oParam.IsAtNamedParam()
			return This.SplitAtPosition(p)

		but oParam.IsAtOrAtThisPositionNamedParam()
			return This.SplitAtPosition(p)

		but oParam.IsOneOfTheseNamedParams([
			:AtPositions, :AtThesePositions, :AtManyPositions ])

			return This.SplitAtPositions(p)

		#-- BeforePosition(s)

		but oParam.IsOneOfTheseNamedParams([
			:Before, :BeforePosition, :BeforeThisPosition ])

			return This.SplitAtPosition(p)

		but oParam.IsOneOfTheseNamedParams([
			:BeforePositions, :BeforeThesePositions, :BeforeManyPositions ])

			return This.SplitBeforePositions(p)

		#-- AfterPosition(s)

		but oParam.IsOneOfTheseNamedParams([
			:After, :AfterPosition, :AfterThisPosition ])

			return This.SplitAfterPosition(p)

		but oParam.IsOneOfTheseNamedParams([
			:AfterPositions, :AfterThesePositions, :AfterManyPositions ])

			return This.SplitAfterPositions(p)

		#== AtSection(s)

		but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ])
			return This.SplitAtSection(p)

		but oParam.IsOneOfTheseNamedParams([
			:AtSections, :AtTheseSections, :AtManySections ])

			return This.SplitAtSections(p)

		#-- BeforeSection(s)

		but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ])
			return This.SplitBeforeSection(p)

		but oParam.IsOneOfTheseNamedParams([
			:BeforeSections, :BeforeTheseSections, :BeforeManySections ])

			return This.SplitBeforeSections(p)

		#-- AfterSection(s)

		but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ])
			return This.SplitAfterSection(p)

		but oParam.IsOneOfTheseNamedParams([
			:AfterSections, :AfterTheseSections, :AfterManySections ])

			return This.SplitAfterSections(p)

		#== AtSection(s)IB

		but oParam.IsOneOfTheseNamedParams([ :AtSectionIB, :AtThisSectionIB ])
			return This.SplitAtSectionIB(p)

		but oParam.IsOneOfTheseNamedParams([
			:AtSectionsIB, :AtTheseSectionsIB, :AtManySectionsIB ])

			return This.SplitAtSectionsIB(p)

		#-- BeforeSection(s)IB

		but oParam.IsOneOfTheseNamedParams([ :BeforeSectionIB, :BeforeThisSectionIB ])
			return This.SplitBeforeSectionIB(p)

		but oParam.IsOneOfTheseNamedParams([
			:BeforeSectionsIB, :BeforeTheseSectionsIB, :BeforeManySectionsIB ])

			return This.SplitBeforeSectionsIB(p)

		#-- AfterSection(s)IB

		but oParam.IsOneOfTheseNamedParams([ :AfterSectionIB, :AfterThisSectionIB ])

			return This.SplitAfterSectionIB(p)

		but oParam.IsOneOfTheseNamedParams([
			:AfterSectionsIB, :AfterTheseSectionsIB, :AfterManySectionsIB ])

			return This.SplitAfterSectionsIB(p)

		#== Misc.

		but oParam.IsThisNamedParam(:ToPartsOfNItems)
			return This.SplitToPartsOfNItems(p)

		but oParam.IsthisNamedParam(:ToPartsOfExactlyNItems)
			return This.SplitToPartsOfExactlyNItems(p)

		but oParam.IsThisNamedParam(:ToNParts)
			return This.SplitToNParts(p)

		else
			StzRaise("Unsupported syntax!")
		ok

	  #====================#
	 #    SPLITTING AT    #
	#====================#

	def SplitAt(p)

		if isNumber(p)
			return This.SplitAtPosition(p)

		but isList(p)
			oParam = Q(p)
			if oParam.IsListOfNumbers()
				return This.SplitAtPositions(p)

			but oParam.IsListOfPairsOfNumbers()
				return This.SplitAtSections(p)

			but oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ])
				return This.SplitAtPosition(p[2])

			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ])
				return This.SplitAtPositions(p[2])

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ])
				return This.SplitAtSection(p[2][1], p[2][2])

			but oParam.IsOneOfTheseNamedParams([ :SectionIB, :ThisSectionIB ])
				return This.SplitAtSectionIB(p[2][1], p[2][2])

			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ])
				return This.SplitAtSections(p[2])

			but oParam.IsOneOfTheseNamedParams([ :SectionsIB, :TheseSectionsIB ])
				return This.SplitAtSectionsIB(p[2])

			ok
		else
			StzRaise("Incorrect param! p must be a number, list of numbers, section, or list of sections.")
		ok

	  #-----------------------------------#
	 #   SPLITTING AT A GIVEN POSITION   #
	#-----------------------------------#

	def SplitAtPosition(n)

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = This.NumberOfPositions()

		if n > 1 and n < nLen
			aResult = [ [ 1, n-1], [n+1, nLen ] ]
		else
			aResult = [ 1 , This.NumberOfPositions() ]
		ok

		return aResult

	  #---------------------------------#
	 #   SPLITTING AT MANY POSITIONS   #
	#---------------------------------#

	def SplitAtPositions(panPositions)

		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )
			StzRaise("Incorrect param type! panPositions must be a list of numbers.")
		ok

		aPairs = This.GetPairsFromPositions(panPositions)

		for i = 1 to len(aPairs) - 1
			aPairs[i][2]--
			aPairs[i+1][1]++
		next

		return aPairs

		def SplitAtThesePositions(panPositions)
			return This.SplitAtPositions(panPositions)

		def SplitAtManyPositions(panPositions)
			return This.SplitAtPositions(panPositions)

	  #========================#
	 #    SPLITTING BEFORE    #
	#========================#

	def SplitBefore(p)
	
		if isNumber(p)
			return This.SplitBeforePosition(p)

		but isList(p)
			oParam = Q(p)
			if oParam.IsListOfNumbers()
				return This.SplitBeforePositions(p)

			but oParam.IsListOfPairsOfNumbers()
				return This.SplitBeforeSections(p)

			but oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ])
				return This.SplitBeforePosition(p[2])

			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ])
				return This.SplitBeforePositions(p[2])

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ])
				return This.SplitBeforeSection(p[2])

			but oParam.IsOneOfTheseNamedParams([ :SectionIB, :ThisSectionIB ])
				return This.SplitBeforeSectionIB(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Sections, :TheseSections ])
				return This.SplitBeforeSections(p[2])

			but oParam.IsOneOfTheseNamedParams([ :SectionsIB, :TheseSectionsIB ])
				return This.SplitBeforeSectionsIB(p[2])

			ok
		else
			StzRaise("Incorrect param! p must be a number, list of numbers, section, or list of sections.")
		ok

	  #---------------------------------#
	 #   SPLITTING BEFORE A POSITION   #
	#---------------------------------#

	def SplitBeforePosition(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = This.NumberOfPositions()

		if n > 1 and n <= nLen
			aResult = [ [ 1, n-1], [n, nLen ] ]
		else
			aResult = [ [ 1 , nLen ] ]
		ok

		return aResult

	  #-------------------------------------#
	 #   SPLITTING BEFORE MANY POSITIONS   #
	#-------------------------------------#

	def SplitBeforePositions(panPositions)
		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )
			StzRaise("Incorrect param type! panPositions must be a list of numbers.")
		ok

		aPairs = This.GetPairsFromPositions(panPositions)
		/*
		Main list 	 --> 1:10
		panPositions	 --> [ 3, 6, 8 ]
		List of pairs	 --> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]
		Eexpected result --> [ [ 1, 2 ], [ 3, 5 ], [ 6, 7 ], [ 8, 10 ] ]

		- We should leave the last pair as is
		- For all the others, just retrived 1 from aPair[2]
		*/

		nLen = len(aPairs)
		aResult = []

		for i = 1 to nLen - 1
			n1 = aPairs[i][1]
			n2 = aPairs[i][2] - 1

			aResult + [ n1, n2 ]
		next

		aLastPair = aPairs[nLen]
		aResult + [ aLastPair[1], aLastPair[2] ]

		return aResult

		def SplitBeforeThesePositions(panPositions)
			return This.SplitBeforePositions(panPositions)

		def SplitBeforeManyPositions(panPositions)
			return This.SplitBeforePositions(panPositions)

	  #=======================#
	 #    SPLITTING AFTER    #
	#=======================#

	def SplitAfter(p)

		if isNumber(p)
			return This.SplitAfterPosition(p)

		but isList(p)
			oParam = Q(p)
			if oParam.IsListOfNumbers()
				return This.SplitAfterPositions(p)

			but oParam.IsListOfPairsOfNumbers()
				return This.SplitAfterSections(p)

			but oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ])
				return This.SplitAfterPosition(p[2])

			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ])
				return This.SplitAfterPositions(p[2])

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ])
				return This.SplitAfterSection(p[2])

			but oParam.IsOneOfTheseNamedParams([ :SectionIB, :ThisSectionIB ])
				return This.SplitAfterSectionIB(p[2])

			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ])
				return This.SplitAfterSections(p[2])

			but oParam.IsOneOfTheseNamedParams([ :SectionsIB, :TheseSectionsIB ])
				return This.SplitAfterSectionsIB(p[2])

			ok
		else
			StzRaise("Incorrect param! p must be a number, list of numbers, section, or list of sections.")
		ok

	  #--------------------------------------#
	 #   SPLITTING AFTER A GIVEN POSITION   #
	#--------------------------------------#

	def SplitAfterPosition(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		return This.SplitBeforePosition(n+1)

	  #------------------------------------#
	 #   SPLITTING AFTER MANY POSITIONS   #
	#------------------------------------#

	def SplitAfterPositions(panPositions)
		if NOT ( isList(panPositions) and Q(panPositions).IsListOfNumbers() )
			StzRaise("Incorrect param type! panPositions must be a list of numbers.")
		ok

		aResult = []

		if len(panPositions) > 0
			anPos = StzListOfNumbersQ(panPositions).AddedToEach(1)
			aResult = This.SplitBeforePositions(anPos)
		ok

		return aResult

		def SplitAfterThesePositions(panPositions)
			return This.SplitAfterPositions(panPositions)

		def SplitAfterManyPositions(panPositions)
			return This.SplitAfterPositions(panPositions)

	  #=================================#
	 #  SPLITTING AT A GIVEN SECTION   #
	#=================================#

	def SplitAtSection(n1, n2)
		/* EXAMPLE

		o1 = new stzSplitter(1:8)
		? o1.SplitAtSection([3,5])

		# 1..2..3..4..5..8
		#       ^-----^

		#--> [ [1,2], [6,8] ]

		# If you want to include the bounds of the sections
		# in the result, use the ...IB() extension like this:

		? o1.SplitAtSection([3,5])
		#--> [ [1,3], [5,8] ]

		*/

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		nLen = This.NumberOfPositions()
		if NOT ( Q(n1).IsBetween(1, nLen) and Q(n2).IsBetween(1, nLen) )
			StzRaise("Can't split! Indices provided in panSection must be between 1 and " +
				  This.NumberOfPositions() + "." )
		ok
		
		aResult = []

		if Q(n1 - 1).IsBetween(1, nLen)
			aResult + [ 1, n1 - 1 ]
		ok

		if Q(n2 + 1).IsBetween(1, nLen)
			aResult + [ n2 + 1, nLen ]
		ok

		return aResult

		#< @FunnctionAlternativeForms

		def SplitAtThisSection(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitBetween(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitBetweenPositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitBetweenThesePositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitBetweenManyPositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		#>

	def SplitAtSectionIB(n1, n2)
		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		return This.SplitAtSection(n1++, n2--)

		#< @FunnctionAlternativeForms

		def SplitAtThisSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitBetweenIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitBetweenPositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitBetweenThesePositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitBetweenManyPositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#>

	  #------------------------------#
	 #  SPLITTING AT MANY SECTIONS  #
	#------------------------------#

	def SplitAtSections(paSections)
		/* EXAMPLE

		o1 = new stzSplitter(1:10)
		? o1.SplitAtSections([ [3,5], [8,9] ])

		# 1..2..3..4..5..6..7..8..9..10
		#       ^-----^        ^--^

		#--> [ [1,2], [6,7], [10,10] ]

		# If you want to include the bounds of the sections
		# in the result, use the ...IB() extension like this:

		? o1.SplitAtSectionsIB([ [3,5], [8,9] ])
		#--> [ [1,3], [5,8], [9,10] ]

		*/

		if NOT ( isList(paSections) and len(paSections) > 0 and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a non empty list of pairs of numbers.")
		ok

		if isList(paSections) and len(paSections) = 1 and
		   isList(paSections[1]) and Q(paSections[1]).IsPairOfNumbers()

			return This.SplitAtSection(paSections[1][1], paSections[1][2])
		ok


		aSections = QR(paSections, :stzListOfPairs).Sorted()

		aResult = []
		aSectionToBeSplitted = 1 : This.NumberOfPositions()

		for i = len(aSections) to 1 step -1
			aSplits = StzSplitterQ(aSectionToBeSplitted).SplitAtSection( aSections[i] )
			nLenSplits = len(aSplits)

			aSectionToBeSplitted = aSplits[1][1] : aSplits[1][2]

			for j = 1 to nLenSplits
				aResult + aSplits[j]
			next

		next

		ring_del(aResult, 1)

		aResult = QR(aResult, :stzListOfPairs).SortedInAscending()

		return aResult

		#< @FunnctionAlternativeForms

		def SplitAtTheseSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitBetweenSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitBetweenTheseSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitAtManySections(paSections)
			return This.SplitAtSections(paSections)

		def SplitBetweenManySections(paSections)
			return This.SplitAtSections(paSections)

		#>

	def SplitAtSectionsIB(paSections)
		if NOT ( isList(paSections) and len(paSections) > 0 and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a non empty list of pairs of numbers.")
		ok

		nLen = len(paSections)
		aTempSections = []

		for i = 1 to nLen
			n1 = paSections[i][1] + 1
			n2 = paSections[i][2] - 1
			aTempSections + [ n1, n2 ]
		next

		return This.SplitAtSections(aTempSections)
			
		#< @FunnctionAlternativeForms

		def SplitAtTheseSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitBetweenSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitBetweenTheseSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitAtManySectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitBetweenManySectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		#>

	  #=====================================#
	 #  SPLITTING BEFORE A GIVEN SECTION   #
	#=====================================#

	def SplitBeforeSection(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect pram type! panSection must be a pair of numbers.")
		ok

		return This.SplitBeforePosition(n1)

		#< @FunnctionAlternativeForm

		def SplitBeforeThisSection(n1, n2)
			return This.SplitBeforeSection(n1, n2)

		#>

	def SplitBeforeSectionIB(n1, n2)
		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect pram type! panSection must be a pair of numbers.")
		ok

		return This.SplitBeforeSection(n1++)

		#< @FunnctionAlternativeForm

		def SplitBeforeThisSectionIB(n1, n2)
			return This.SplitBeforeSectionIB(n1, n2)

		#>

	  #----------------------------------#
	 #  SPLITTING BEFORE MANY SECTIONS  #
	#----------------------------------#

	def SplitBeforeSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		anPos = StzListOfPairsQ(paSections).FirstItems()
		return This.SplitBeforePositions(anPos)

		#< @FunctionAlternativeForms

		def SplitBeforeTheseSections(paSections)
			return This.SplitBeforeSections(paSections)

		def SplitBeforeManySections(paSections)
			return This.SplitBeforeSections(paSections)

		#>

	def SplitBeforeSectionsIB(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		anPos = StzListOfPairsQ(paSections).FirstItems()
		nLen = len(anPos)

		anTempPos = []
		for i = 1 to nLen
			anTempPos + (anPos[i] + 1)
		next

		return This.SplitBeforePositions(anTempPos)

		#< @FunctionAlternativeForms

		def SplitBeforeTheseSectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		def SplitBeforeManySectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		#>

	  #====================================#
	 #  SPLITTING AFTER A GIVEN SECTION   #
	#====================================#

	def SplitAfterSection(n1, n2)

		if NOT BothArNumbers(n1, n2)
			StzRaise("Incorrect pram type! n1 and n2 must be both numbers.")
		ok

		return This.SplitAfterPosition(n2)

		def SplitAfterThisSection(n1, n2)
			return This.SplitAfterSection(n1, n2)

	def SplitAfterSectionIB(n1, n2)
		if NOT BothArNumbers(n1, n2)
			StzRaise("Incorrect pram type! n1 and n2 must be both numbers.")
		ok

		return This.SplitAfterPosition(n2--)

		def SplitAfterThisSectionIB(n1, n2)
			return This.SplitAfterSectionIB(n1, n2)

	  #---------------------------------#
	 #  SPLITTING AFTER MANY SECTIONS  #
	#---------------------------------#

	def SplitAfterSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		anPos = StzListOfPairsQ(paSections).SecondItems()
		return This.SplitAfterPositions(anPos)

		#< @FunctionAlternativeForms

		def SplitAfterTheseSections(paSections)
			return This.SplitAfterSections(paSections)

		def SplitAfterManySections(paSections)
			return This.SplitAfterSections(paSections)

		#>

	def SplitAfterSectionsIB(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		anPos = StzListOfPairsQ(paSections).SecondItems()
		nLen = len(anPos)

		anTempPos = []
		for i = 1 to nLen
			anTempPos + (anPos[i] - 1)
		next

		return This.SplitAfterPositions(anTempPos)

		#< @FunctionAlternativeForms

		def SplitAfterTheseSectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		def SplitAfterManySectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		#>

	  #===================================#
	 #   SPLITTING TO PARTS OF N ITEMS   #
	#===================================#

	def SplitToPartsOfNItems(n)

		nLen = This.NumberOfPositions()

		if NOT ( ( isNumber(n) ) and Q(n).IsBetween(1, nLen ) )
			return [ [] ]

		else
			aResult = []

			for i = 1 to nLen step n
				nTemp = i + n-1

				if nTemp > nLen
					nTemp = nLen
				ok

				aResult + [ i, nTemp ]
			next
	
			return aResult
		ok

		#< @FunctionAlternativeForm

		def SplitToPartsOfN(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToPartsOf(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToPartsOfNPositions(n)
			return This.SplitToPartsOfNItems(n)

		#>

	  #---------------------------------------------#
	 #    SPLITTING TO PARTS OF EXACTLY N ITEMS    #
	#---------------------------------------------#

	def SplitToPartsOfExactlyNItems(n)
		aSections = This.SplitToPartsOfNItems(n)
		
		nLen = len(aSections)
		aLastPair = aSections[ nLen ]

		if (aLastPair[2] - aLastPair[1] + 1) != n
			del( aSections, nLen )
		ok

		return aSections

		def SplitToPartsOfExactlyNPositions(n)
			return This.SplitToPartsOfExactlyNItems(n)

	  #----------------------------#
	 #    SPLITTING TO N PARTS    #
	#----------------------------#

	def SplitToNParts(n)

		nNumberOfPositions = This.NumberOfPositions()

		if NOT Q(n).IsBetween(1, nNumberOfPositions )
			return [ [] ]
		ok

		nLen =  ( nNumberOfPositions - ( nNumberOfPositions % n ) ) / n
		# Replace with the following when ready:
		# nLen = 0+ Q( This.NumberOfItems() / n ).IntegerPart()

		aResult = []

		for i = 1 to n*nLen step nLen
			aResult + [ i, i + nLen-1 ]
		next

		if aResult[ len(aResult) ][2] != nNumberOfPositions
			aResult[ len(aResult) ][2] = nNumberOfPositions
		ok

		return aResult

	  #===============================================#
	 #  SPLITTING AROUND POSITION(S) OR SECTTION(s)  #
	#===============================================#

	def SplitAround(p)
		if isNumber(p)
			return This.SplitAroundPosition(p)
		ok

		if isList(p)
			oParam = Q(p)
			if oParam.IsPairOfNumbers()
				return This.SplitAroundSection(p)

			but oParam.IsListOfNumbers()
				return This.SplitAroundPositions(p)

			but oParam.IsListOfPairsOfNumbers()
				return This.SplitOverSections(p)
			ok
		else
			StzRaise("Incorrect param type! p must be a number or pair of numbers or list of numbers.")

		ok

	def SplitAroundIB(n)
		if isNumber(p)
			return This.SplitAroundPositionIB(p)
		ok

		if isList(p)
			oParam = Q(p)
			if oParam.IsPairOfNumbers()
				return This.SplitAroundSectionIB(p)

			but oParam.IsListOfNumbers()
				return This.SplitAroundPositionsIB(p)

			but oParam.IsListOfPairsOfNumbers()
				return This.SplitOverSectionsIB(p)
			ok
		else
			StzRaise("Incorrect param type! p must be a number or pair of numbers or list of numbers.")

		ok

	  #-------------------------------#
	 #  SPLITTING AROUND A POSITION  #
	#===============================#

	def SplitAroundPosition(n)

		# Checking the param

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		# Doing the job

		nLen = This.Size()

		# Managing extreme cases

		if nLen = 0 or (nLen = 1 and n = 1)
			return []

		but NOT ( 1 <= n and n <= This.Size() )
			return This.Content()

		but n = 1 and nLen > 1
			return 2 : nLen

		but n = nLen
			return 1 : nLen-1
		ok

		# Managing the normal case

		aSection1 = 1 : (n-1)
		aSection2 = (n+1) : nLen

		aResult = [ aSection1, aSection2 ]
		return aResult

	def SplitAroundPositionIB(n)
		aResult = This.SplitAroundPosition(n)
		aResult[1][2]++
		aResult[2][1]--
		return aResult

	  #------------------------------#
	 #  SPLITTING AROUND POSITIONS  #
	#------------------------------#

	def SplitAroundPositions(panPos)
		# TODO
		StzRaise("Not yet implemented!")

	def SplitAroundPositionsIB(panPos)
		aResult = This.SplitAroundPositions(panPos)

		nLen = len(aResult)
		for i = 1 to nLen
			aResult[i][2]++
			aResult[i][1]--
		next

		return aResult

	  #------------------------------#
	 #  SPLITTING AROUND A SECTION  #
	#------------------------------#

	def SplitAroundSection(n1, n2)
		# TODO
		StzRaise("Not yet implemented!")

	def SplitAroundSectionIB(n1, n2)
		aResult = This.SplitAroundSection(n1, n2)

		nLen = len(aResult)
		for i = 1 to nLen
			aResult[i][2]++
			aResult[i][1]--
		next

		return aResult
		
	  #-----------------------------#
	 #  SPLITTING AROUND SECTIONS  #
	#-----------------------------#

	def SplitAroundSections(panSections)
		# TODO
		StzRaise("Not yet implemented!")

	def SplitAroundSectionsIB(panSections)
		aResult = This.SplitAroundSections(panSections)

		nLen = len(aResult)
		for i = 1 to nLen
			aResult[i][2]++
			aResult[i][1]--
		next

		return aResult

	  #=======================================================#
	 #   Utility functions used by the other methods above   #
	#=======================================================#

	def GetPairsFromPositions(panPositions) # TODO: A general function, can move to stzListOfNumbers
		/*
		Main list 	--> 1:10
		panPositions	--> [ 3, 6, 8 ]
		List of pairs	--> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]
		*/

		nLen = This.NumberOfPositions()
		panPositions + nLen

		# Eliminating doubble positions
		aPos = StzListQ(panPositions).ToSet()

		# Doing the job

		if StzListQ(aPos).IsEmpty()
			return [ [] ]
		ok
		
		# Adding 1 and (NumberOfItems()) if inexistant
		if aPos[1] != 1 { aPos + 1 }
		if aPos[len(aPos)] != 10 { aPos + nLen }
		
		# Sorting the list
		aPos = ring_sort(aPos)
		
		# Getting the pairs of that list
		aPairs = []
		for i = 1 to len(aPos) - 1
			aPairs + [ aPos[i], aPos[i+1] ]
		next

		del(aPairs, len(aPairs))

		return aPairs

	def ToStzList()
		return StzListQ(This.Content())
