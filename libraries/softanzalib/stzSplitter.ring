
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

	def Copy()
		return new stzSplitter( 1: This.NumberOfPositions() )

	  #========================================#
	 #    SPLITTING : THE GENERIC FUNCTION    #
	#========================================#

	def Split(p)
	
		if isList(p)

			if len(p) = 2 and
			   isString(p[1]) and
			   Q(p[1]).IsOneOfTheseCS([

				:At, :AtPosition, :AtThisPosition,
				:AtPositions, :AtThesePositions, :AtManyPositions,

				:Before, :BeforePosition, :BeforeThisPosition,
				:BeforePositions, :BeforeThesePositions, :BeforeManyPositions,

				:After, :AfterPosition, :AfterThisPosition,
				:AfterPositions, :AfterThesePositions, :AfterManyPositions,

				:ToPartsOfNItems, :ToPartsOfExactlyNItems,
				:ToNParts,

				:AtSection, :AtThisSection,
				:BeforeSection, :BeforeThisSection,
				:AfterSection, :AfterThisSection,

				:AtSections, :BeforeSections, :AfterSections,
				:AtTheseSections, :BeforeTheseSections, :AfterTheseSections,
				:AtManySections, :BeforeManySections, :AfterManySections

			   ], :CS = FALSE)
	
				cTemp = Q(p[1]).Lowercased()

				#--

				if cTemp = :At
					return This.SplitAt(p[2])
				
				but cTemp = :AtPosition or cTemp = :AtThisPosition
					return This.SplitAtPosition(p[2])

				but Q(cTemp).IsOneOfThese([ :AtPositions, :AtThesePositions, :AtManyPositions ])
					return This.SplitAtPositions(p[2])

				#--

				but cTemp = :Before
					return This.SplitBefore(p[2])
				
				but cTemp = :BeforePosition or cTemp = :BeforeThisPosition
					return This.SplitBeforePosition(p[2])

				but Q(cTemp).IsOneOfThese([ :BeforePositions, :BeforeThesePositions, :BeforeManyPositions ])
					return This.SplitBeforePositions(p[2])

				#--

				but cTemp = :After
					return This.SplitAfter(p[2])
				
				but cTemp = :BeforePosition or cTemp = :BeforeThisPosition
					return This.SplitAfterPosition(p[2])

				but Q(cTemp).IsOneOfThese([ :BeforePositions, :BeforeThesePositions, :BeforeManyPositions ])
					return This.SplitAfterPositions(p[2])

				#--

				but cTemp = :ToPartsOfNItems
					return This.SplitToPartsOfNItems(p[2])

				but cTemp = :ToPartsOfExactlyNItems
					return This.SplitToPartsOfExactlyNItems(p[2])
	
				but cTemp = :ToNParts
					return This.SplitToNParts(p[2])

				#--

				but cTemp = :AtSection or cTemp = :AtThisSection
					return This.SplitAtSection(p[2])

				but cTemp = :BeforeSection or cTemp = :BeforeThisSection
					return This.SplitBeforeSection(p[2])

				but cTemp = :AfterSection or cTemp = :AfterThisSection
					return This.SplitAfterSection(p[2])

				#--

				but Q(cTemp).IsOneOfThese([ :AtSections, :AtTheseSections, :AtManySections ])
					return This.SplitAtSections(p[2])

				but Q(cTemp).IsOneOfThese([ :BeforeSections, :BeforeTheseSections, :BeforeManySections ])
					return This.SplitBeforeSections(p[2])

				but Q(cTemp).IsOneOfThese([ :AfterSections, :AfterTheseSections, :AfterManySections ])
					return This.SplitAfterSections(p[2])

				ok
			else

				if Q(p).IsListOfNumbers()
					return This.SplitAtPositions(p)
				else
					StzRaise("Incorrect param type! p must be a number or list of numbers.")
				ok
			ok
			
		else

			return This.SplitAt(p)
		ok

	  #====================#
	 #    SPLITTING AT    #
	#====================#

	def SplitAt(p)

		if isNumber(p)
			return This.SplitAtPosition(p)

		but isList(p)
			if Q(p).IsListOfNumbers()
				return This.SplitAtPositions(p)

			but Q(p).IsListOfPairsOfNumbers()
				return This.SplitAtSections(p)

			but Q(p).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])
				return This.SplitAtPosition(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ])
				return This.SplitAtPositions(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Section, :ThisSection ])
				return This.SplitAtSection(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Sections, :TheseSections ])
				return This.SplitAtSections(p[2])
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
			if Q(p).IsListOfNumbers()
				return This.SplitBeforePositions(p)

			but Q(p).IsListOfPairsOfNumbers()
				return This.SplitBeforeSections(p)

			but Q(p).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])
				return This.SplitBeforePosition(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ])
				return This.SplitBeforePositions(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Section, :ThisSection ])
				return This.SplitBeforeSection(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Sections, :TheseSections ])
				return This.SplitBeforeSections(p[2])
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
			if Q(p).IsListOfNumbers()
				return This.SplitAfterPositions(p)

			but Q(p).IsListOfPairsOfNumbers()
				return This.SplitAfterSections(p)

			but Q(p).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])
				return This.SplitAfterPosition(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ])
				return This.SplitAfterPositions(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Section, :ThisSection ])
				return This.SplitAfterSection(p[2])

			but Q(p).IsOneOfTheseNamedParams([ :Sections, :TheseSections ])
				return This.SplitAfterSections(p[2])
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

	def SplitAtSection(panSection)
		if NOT ( isList(panSection) and Q(panSection).IsPairOfNumbers() )
			StzRaise("Incorrect param type! panSection must be a pair of numbers.")
		ok

		n1 = panSection[1]
		n2 = panSection[2]

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

	  #------------------------------#
	 #  SPLITTING AT MANY SECTIONS  #
	#------------------------------#

	def SplitAtSections(paSections)
		/* EXAMPLE

		o1 = new stzSplitter(1:10)
		o1.Split( :AtSections = [ [3,5], [8,9] ] )

		# 1..2..3..4..5..6..7..8..9..10
		#       ^-----^        ^--^

		#--> [ [1,2], [6,7], [10,10] ]

		*/

		if NOT ( isList(paSections) and len(paSections) > 0 and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a non empty list of pairs of numbers.")
		ok

		if isList(paSections) and len(paSections) = 1 and
		   isList(paSections[1]) and Q(paSections[1]).IsPairOfNumbers()

			return This.SplitAtSection(paSections[1])
		ok


		aSections = QR(paSections, :stzListOfPairs).Sorted()

		aResult = []
		aSectionToBeSplitted = 1 : This.NumberOfPositions()

		for i = len(aSections) to 1 step -1
			aSplits = StzSplitterQ(aSectionToBeSplitted).SplitAtSection( aSections[i] )

			aSectionToBeSplitted = aSplits[1][1] : aSplits[1][2]
			
			for aSection in aSplits
				aResult + aSection
			next

		next

		del(aResult, 1)

		aResult = QR(aResult, :stzListOfPairs).SortedInAscending()

		return aResult

		def SplitAtTheseSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitAtManySections(paSections)
			return This.SplitAtSections(paSections)

	  #=====================================#
	 #  SPLITTING BEFORE A GIVEN SECTION   #
	#=====================================#

	def SplitBeforeSection(panSection)

		if NOT ( isList(panSection) and Q(panSection).IsPairOfNumbers() )
			StzRaie("Incorrect pram type! panSection must be a pair of numbers.")
		ok

		return This.SplitBeforePosition(panSection[1])

	  #----------------------------------#
	 #  SPLITTING BEFORE MANY SECTIONS  #
	#----------------------------------#

	def SplitBeforeSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		anPos = StzListOfPairsQ(paSections).FirstItems()
		return This.SplitBeforePositions(anPos)

		def SplitBeforeTheseSections(paSections)
			return This.SplitBeforeSections(paSections)

		def SplitBeforeManySections(paSections)
			return This.SplitBeforeSections(paSections)

	  #=====================================#
	 #  SPLITTING AFTER A GIVEN SECTION   #
	#=====================================#

	def SplitAfterSection(panSection)

		if NOT ( isList(panSection) and Q(panSection).IsPairOfNumbers() )
			StzRaie("Incorrect pram type! panSection must be a pair of numbers.")
		ok

		return This.SplitAfterPosition(panSection[2])

	  #---------------------------------#
	 #  SPLITTING AFTER MANY SECTIONS  #
	#---------------------------------#

	def SplitAfterSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		anPos = StzListOfPairsQ(paSections).SecondItems()
		return This.SplitAfterPositions(anPos)

		def SplitAfterTheseSections(paSections)
			return This.SplitAfterSections(paSections)

		def SplitAfterManySections(paSections)
			return This.SplitAfterSections(paSections)

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
