
/*
This class is a numrical solution to splitting things.

A splitter recieves a number of N positions.

Then the splitter initializes an internal list of numbers from 1 to N.

Then the several splitting features are provided (see the class methods).

Each of these methods returns a list pof sections (as pairs of numbers).

In practice, stzSplitter is called from inside a stzString or stzList. In this
case, the returned sections are passed to stzString.Sections() or stzList.Sections()
to provide us with the splitted parts of the string or the list.
	
*/

func StzSplitterQ(p)
	return new stzSplitter(p)

class stzSplitter from stzListOfNumbers

	@nNumberOfPositions
	@nLenPart = 1

	  #--------------------------------#
	 #    INITIALIZING THE SPLITTER   #
	#--------------------------------#

	def init(p)

		if NOT (isNumber(p) or @IsPairOfNumbers(p))
			StzRaise("Incorrect param type! p must be a number or a pair of numbers.")
		ok

		if isNumber(p)

			if p < 0
				StzRaise("p must be positive!") #--> TODO: stzListError
			ok

			@nNumberOfPositions = p

		but isList(p)
			@nNumberOfPositions = p[1]
			@nLenPart = p[2]

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
		return new stzSplitter( This.NumberOfPositions() )

	  #========================================#
	 #    SPLITTING : THE GENERIC FUNCTION    #
	#========================================#

	def SplitXT(p)
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok

		# Case of number or lit of numbers param

		if isNumber(p)
			return This.SplitAtPosition(p)

		but @IsListOfNumbers(p)
			return This.SplitAtPositions(p)
		ok

		# Cases of named params

		oParam = Q(p)

		#-- :At

		if oParam.IsAtNamedParam()
			return This.SplitAtPosition(p[2])

		but oParam.IsAtIBNamedParam()
			return This.SplitAtPositionIB(p[2])

		#-- :AtPosition

		but oParam.IsOneOfTheseNamedParams([
			:AtPosition, :AtThisPosition ])

			return This.SplitAtPositionIB(p[2])

		but oParam.IsOneOfTheseNamedParams([
			:AtPositionIB, :AtThisPositionIB ])

			return This.SplitAtPositionIB(p[2])

		#-- :AtPositions

		but oParam.IsOneOfTheseNamedParams([
			:AtPositions, :AtThesePositions, :AtManyPositions ])

			return This.SplitAtPositions(p[2])

		but oParam.IsOneOfTheseNamedParams([
			:AtPositionsIB, :AtThesePositionsIB, :AtManyPositionsIB ])

			return This.SplitAtPositionsIB(p[2])

		#-- :BeforePosition

		but oParam.IsOneOfTheseNamedParams([
			:Before, :BeforePosition, :BeforeThisPosition ])

			return This.SplitAtPosition(p[2])

		but oParam.IsOneOfTheseNamedParams([
			:BeforeIB, :BeforePositionIB, :BeforeThisPositionIB ])

			return This.SplitAtPositionIB(p[2])

		#-- :BeforePositions

		but oParam.IsOneOfTheseNamedParams([
			:BeforePositions, :BeforeThesePositions, :BeforeManyPositions ])

			return This.SplitBeforePositions(p[2])

		but oParam.IsOneOfTheseNamedParams([
			:BeforePositionsIB, :BeforeThesePositionsIB, :BeforeManyPositionsIB ])

			return This.SplitBeforePositionsIB(p[2])

		#-- :AfterPosition

		but oParam.IsOneOfTheseNamedParams([
			:After, :AfterPosition, :AfterThisPosition ])

			return This.SplitAfterPosition(p[2])

		but oParam.IsOneOfTheseNamedParams([
			:AfterIB, :AfterPositionIB, :AfterThisPositionIB ])

			return This.SplitAfterPositionIB(p[2])

		# :AfterPositions

		but oParam.IsOneOfTheseNamedParams([
			:AfterPositions, :AfterThesePositions, :AfterManyPositions ])

			return This.SplitAfterPositions(p[2])

		but oParam.IsOneOfTheseNamedParams([
			:AfterPositionsIB, :AfterThesePositionsIB, :AfterManyPositionsIB ])

			return This.SplitAfterPositionsIB(p[2])

		#-- :AtSection

		but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ])
			return This.SplitAtSection(p[2][1], p[2][2])

		but oParam.IsOneOfTheseNamedParams([ :AtSectionIB, :AtThisSectionIB ])
			return This.SplitAtSectionIB(p[2][1], p[2][2])

		#-- :AtSections

		but oParam.IsOneOfTheseNamedParams([
			:AtSections, :AtTheseSections, :AtManySections ])

			return This.SplitAtSections(p[2])

		but oParam.IsOneOfTheseNamedParams([
			:AtSectionsIB, :AtTheseSectionsIB, :AtManySectionsIB ])

			return This.SplitAtSectionsIB(p[2])

		#-- :BeforeSection

		but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ])
			return This.SplitBeforeSection(p[2][1], p[2][2])

		but oParam.IsOneOfTheseNamedParams([ :BeforeSectionIB, :BeforeThisSectionIB ])
			return This.SplitBeforeSectionIB(p[2][1], p[2][2])

		#-- :BeforeSections

		but oParam.IsOneOfTheseNamedParams([
			:BeforeSections, :BeforeTheseSections, :BeforeManySections ])

			return This.SplitBeforeSections(p[2])

		but oParam.IsOneOfTheseNamedParams([
			:BeforeSectionsIB, :BeforeTheseSectionsIB, :BeforeManySectionsIB ])

			return This.SplitBeforeSectionsIB(p[2])

		#-- :AfterSection

		but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ])
			return This.SplitAfterSection(p[2][1], p[2][2])

		but oParam.IsOneOfTheseNamedParams([ :AfterSectionIB, :AfterThisSectionIB ])
			return This.SplitAfterSectionIB(p[2][1], p[2][2])

		#-- :AfterSections

		but oParam.IsOneOfTheseNamedParams([
			:AfterSections, :AfterTheseSections, :AfterManySections ])

			return This.SplitAfterSections(p[2])

		but oParam.IsOneOfTheseNamedParams([
			:AfterSectionsIB, :AfterTheseSectionsIB, :AfterManySectionsIB ])

			return This.SplitAfterSectionsIB(p[2])

		#== Misc.

		but oParam.IsToPartsOfNItemsNamedParam()
			return This.SplitToPartsOfNItemsXT(p[2])

		but oParam.IsToPartsOfExactlyNItemsNamedParam()
			return This.SplitToPartsOfNItems(p[2])

		but oParam.IsToNPartsNamedParam()
			return This.SplitToNParts(p[2])

		else
			StzRaise("Unsupported syntax!")
		ok

		#< @FunctionAlternativeForms

		def SplitsXT(p)
			return This.SplitXT(p)

		def SplitXTZZ(p)
			return This.SplitXT(p)

		def SplitsXTZZ(p)
			return This.SplitXT(p)

		#>

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

			#--

			but oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ])
				return This.SplitAtPosition(p[2])

			but oParam.IsOneOfTheseNamedParams([ :PositionsIB, :ThesePositionsIB ])
				return This.SplitAtPositionsIB(p[2])

			#--

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ])
				return This.SplitAtSection(p[2][1], p[2][2])

			but oParam.IsOneOfTheseNamedParams([ :SectionIB, :ThisSectionIB ])
				return This.SplitAtSectionIB(p[2][1], p[2][2])

			#--

			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ])
				return This.SplitAtSections(p[2])

			but oParam.IsOneOfTheseNamedParams([ :SectionsIB, :TheseSectionsIB ])
				return This.SplitAtSectionsIB(p[2])

			#==

			but oParam.IsToPartsOfNItemsNamedParam() or
			    oParam.IsToPartsOfExactlyNItemsNamedParam()

				return This.SplitToPartsOfNItems(p[2])

			but oParam.IsToPartsOfNItemsXTNamedParam()

				return This.SplitToPartsOfNItemsXT(p[2])

			but oParam.IsToNPartsNamedParam() or
			    oParam.IsToExactlyNPartsNamedParam()

				return This.SplitToNParts(p[2])

			but oParam.IsToNPartsXTNamedParam()
				return This.SplitToNParts(p[2])

			else
				StzRaise("Unsupported syntax of Split( :... = ... ).")
			ok
		else
			StzRaise("Incorrect param! p must be a number, list of numbers, section, or list of sections.")
		ok

		#< @FunctionAlternativeForms

		def SplitsAt(p)
			return This.SplitAt(p)

		def Split(p)
			return This.SplitAt(p)

		def Splits(p)
			return This.SplitAt(p)

		#--

		def SplitAtZZ(p)
			return This.SplitAt(p)

		def SplitsAtZZ(p)
			return This.SplitAt(p)

		def SplitZZ(p)
			return This.SplitAt(p)

		def SplitsZZ(p)
			return This.SplitAt(p)

		#>

	  #-----------------------------------#
	 #   SPLITTING AT A GIVEN POSITION   #
	#-----------------------------------#

	def SplitAtPosition(n)

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = @nNumberOfPositions

		if n > 1 and n < nLen
			aResult = [ [ 1, n-1], [n+1, nLen ] ]

		but n = 1 and nLen > 1
			aResult = [ [ 2, nLen ] ]

		but n = nLen and nLen > 1 
			aResult = [ [ 1, nLen-1] ]

		else
			aResult = [ 1 , nLen ]
		ok

		return aResult

		#< @FunctionAlternativeForm

		def SplitsAtPosition(n)
			return This.SplitAtPosition(n)

		#--

		def SplitAtPositionZZ(n)
			return This.SplitAtPosition(n)

		def SplitsAtPositionZZ(n)
			return This.SplitAtPosition(n)

		#>

	  #---------------------------------#
	 #   SPLITTING AT MANY POSITIONS   #
	#---------------------------------#

	def SplitAtPositions(panPos)

		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		nLenPos = len(panPos)
		if nLenPos = 0
			return This.Content()

		but nLenPos = 1
			return This.SplitAtPosition(panPos[1])
		ok

		panPos = ring_sort(panPos)
		aPairs = This.GetPairsFromPositions(panPos)

		nFirstPos = panPos[1]
		nLastPos = panPos[nLenPos]

		nLenPairs = len(aPairs)

		if aPairs[nLenPairs][2] = nLastPos
			aPairs[nLenPairs][2]--
		ok

		if aPairs[1][1] = nFirstPos
			aPairs[1][1]++
		ok

		for i = 1 to nLenPairs - 1
			aPairs[i][2]--
			aPairs[i+1][1]++
		next

		return aPairs

		#< @FunctionAlternativeForms

		def SplitAtThesePositions(panPos)
			return This.SplitAtPositions(panPos)

		def SplitAtManyPositions(panPos)
			return This.SplitAtPositions(panPos)

		#--

		def SplitsAtPositions(panPos)
			return This.SplitAtPositions(panPos)

		def SplitsAtThesePositions(panPos)
			return This.SplitAtPositions(panPos)

		def SplitsAtManyPositions(panPos)
			return This.SplitAtPositions(panPos)

		#==

		def SplitAtPositionsZZ(panPos)
			return This.SplitAtPositions(panPos)

		def SplitAtThesePositionsZZ(panPos)
			return This.SplitAtPositions(panPos)

		def SplitAtManyPositionsZZ(panPos)
			return This.SplitAtPositions(panPos)

		#--

		def SplitsAtThesePositionsZZ(panPos)
			return This.SplitAtPositions(panPos)

		def SplitsAtManyPositionsZZ(panPos)
			return This.SplitAtPositions(panPos)

		#>

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

			#--

			but oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ])
				return This.SplitBeforePosition(p[2])

			but oParam.IsOneOfTheseNamedParams([ :PositionIB, :ThisPositionIB ])
				return This.SplitBeforePositionIB(p[2])

			#--

			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ])
				return This.SplitBeforePositions(p[2])

			but oParam.IsOneOfTheseNamedParams([ :PositionsIB, :ThesePositionsIB ])
				return This.SplitBeforePositionsIB(p[2])

			#--

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ])
				return This.SplitBeforeSection(p[2][1], p[2][2])

			but oParam.IsOneOfTheseNamedParams([ :SectionIB, :ThisSectionIB ])
				return This.SplitBeforeSectionIB(p[2][1], p[2][2])

			#--

			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ])
				return This.SplitBeforeSections(p[2])

			but oParam.IsOneOfTheseNamedParams([ :SectionsIB, :TheseSectionsIB ])
				return This.SplitBeforeSectionsIB(p[2])

			ok
		else
			StzRaise("Incorrect param! p must be a number, list of numbers, section, or list of sections.")
		ok

		def SplitsBefore(p)
			return This.SplitBefore(p)

	  #---------------------------------#
	 #   SPLITTING BEFORE A POSITION   #
	#---------------------------------#

	def SplitBeforePosition(n)
		return This.SplitBeforePositions([n])

		def SplitsBeforePosition(n)
			return This.SplitBeforePosition(n)

	  #-------------------------------------#
	 #   SPLITTING BEFORE MANY POSITIONS   #
	#-------------------------------------#

	def SplitBeforePositions(panPos)

		if CheckingParams()
			if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		# Resolving the positions correctness

		nLen = This.NumberOfItems()

		anPos = U( ring_sort(panPos) )
		nLenPos = len(anPos)

		for i = 1 to nLenPos
			if NOT (anPos[i] >= 1 and anPos[i] <= nLen)
				StzRaise("Incorrect param type! panPos must contain unique numbers between 1 and " + nLen + ".")
			ok
		next

		# Doing the job

   		aResult = []
   		nStart = 1

		for i = 1 to nLenPos
			nPos = anPos[i]
	       		aResult + [ nStart, nPos-1 ]
	        	nStart = nPos
		next

		if aResult[1][1] = 1 and aResult[1][2] = 0
			del(aResult, 1)
		ok

		aResult + [nStart, nLen]

    		return aResult


		#< @FunctionAlternativeForms

		def SplitBeforeThesePositions(panPos)
			return This.SplitBeforePositions(panPos)

		def SplitBeforeManyPositions(panPos)
			return This.SplitBeforePositions(panPos)

		#--

		def SplitsBeforeThesePositions(panPos)
			return This.SplitBeforePositions(panPos)

		def SplitsBeforeManyPositions(panPos)
			return This.SplitBeforePositions(panPos)

		#>

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

			#--

			but oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ])
				return This.SplitAfterPosition(p[2])

			but oParam.IsOneOfTheseNamedParams([ :PositionIB, :ThisPositionIB ])
				return This.SplitAfterPositionIB(p[2])

			#--

			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ])
				return This.SplitAfterPositions(p[2])

			but oParam.IsOneOfTheseNamedParams([ :PositionsIB, :ThesePositionsIB ])
				return This.SplitAfterPositionsIB(p[2])

			#--

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ])
				return This.SplitAfterSection(p[2][1], p[2][2])

			but oParam.IsOneOfTheseNamedParams([ :SectionIB, :ThisSectionIB ])
				return This.SplitAfterSectionIB(p[2][1], p[2][2])

			#--

			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ])
				return This.SplitAfterSections(p[2])

			but oParam.IsOneOfTheseNamedParams([ :SectionsIB, :TheseSectionsIB ])
				return This.SplitAfterSectionsIB(p[2])

			ok
		else
			StzRaise("Incorrect param! p must be a number, list of numbers, section, or list of sections.")
		ok


		def SplitsAfter(p)
			return This.SplitAfter(p)

	  #--------------------------------------#
	 #   SPLITTING AFTER A GIVEN POSITION   #
	#--------------------------------------#

	def SplitAfterPosition(n)
		return This.SplitAfterPositions([n])

		def SplitsAfterPosition(n)
			return This.SplitAfterPosition(n)

	  #------------------------------------#
	 #   SPLITTING AFTER MANY POSITIONS   #
	#------------------------------------#

	def SplitAfterPositions(panPos)
		if CheckingParams()
			if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		# Resolving the positions correctness

		nLen = This.NumberOfItems()

		anPos = U( ring_sort(panPos) )
		nLenPos = len(anPos)

		for i = 1 to nLenPos
			if NOT (anPos[i] >= 1 and anPos[i] <= nLen)
				StzRaise("Incorrect param type! panPos must contain unique numbers between 1 and " + nLen + ".")
			ok
		next

		# Doing the job

   		aResult = []
   		nStart = 1

		for i = 1 to nLenPos
			nPos = anPos[i]
	       		aResult + [ nStart, nPos ]
	        	nStart = nPos + 1
		next

		if nStart <= nLen
			aResult + [nStart, nLen]
		ok

    		return aResult

		#< @FunctionAlternativeForms

		def SplitAfterThesePositions(panPos)
			return This.SplitAfterPositions(panPos)

		def SplitAfterManyPositions(panPos)
			return This.SplitAfterPositions(panPos)

		#--

		def SplitsAfterPositions(panPos)
			return This.SplitAfterPositions(panPos)

		def SplitsAfterThesePositions(panPos)
			return This.SplitAfterPositions(panPos)

		def SplitsAfterManyPositions(panPos)
			return This.SplitAfterPositions(panPos)

		#>

	def SplitAfterPositionsIB(panPos)
		aSections = This.SplitAfterPositions(panPos)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def SplitAfterThesePositionsIB(panPos)
			return This.SplitAfterPositionsIB(panPos)

		def SplitAfterManyPositionsIB(panPos)
			return This.SplitAfterPositionsIB(panPos)

		#--

		def SplitsAfterPositionsIB(panPos)
			return This.SplitAfterPositionsIB(panPos)

		def SplitsAfterThesePositionsIB(panPos)
			return This.SplitAfterPositionsIB(panPos)

		def SplitsAfterManyPositionsIB(panPos)
			return This.SplitAfterPositionsIB(panPos)

		#>

	  #=================================#
	 #  SPLITTING AT A GIVEN SECTION   #
	#=================================#

	def SplitAtSection(n1, n2)
		/* EXAMPLE

		o1 = new stzSplitter(8)
		? o1.SplitAtSection([3,5])

		# 1..2..3..4..5..8
		#       ^-----^

		#--> [ [1,2], [6,8] ]

		# If you want to include the bounds of the sections
		# in the result, use the ...IB() extension like this:

		? o1.SplitAtSectionIB([3,5])
		#--> [ [1,3], [5,8] ]

		*/

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		nLen = This.NumberOfPositions()

		if NOT ( (n1 >= 1 and n1 <= nLen) and (n1 >= 1 and n1 <= nLen) )

			StzRaise("Can't split! Indices provided in panSection must be between 1 and " +
				  nLen + "." )
		ok

		aResult = []

		if n1-1 >= 1 and n1-1 <= nLen
			aResult + [ 1, n1 - 1 ]
		ok

		if n2+1 >= 1 and n2+1 <= nLen
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

		#--

		def SplitsAtSection(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsAtThisSection(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsBetween(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsBetweenPositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsBetweenThesePositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsBetweenManyPositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		#>

	def SplitAtSectionIB(n1, n2)

		aSections = This.SplitAtSection(n1, n2)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

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

		#--

		def SplitsAtSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsAtThisSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsBetweenIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsBetweenPositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsBetweenThesePositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsBetweenManyPositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#>

	  #------------------------------#
	 #  SPLITTING AT MANY SECTIONS  #
	#------------------------------#

	def SplitAtSections(paSections)
		/* EXAMPLE

		o1 = new stzSplitter(10)
		? o1.SplitAtSections([ [3,5], [8,9] ])

		# 1..2..3..4..5..6..7..8..9..10
		#       ^-----^        ^--^

		#--> [ [1,2], [6,7], [10,10] ]

		# If you want to include the bounds of the sections
		# in the result, use the ...IB() extension like this:

		? o1.SplitAtSectionsIB([ [3,5], [8,9] ])
		#--> [ [1,3], [5,8], [9,10] ]

		*/

		# Checking params

		if NOT ( isList(paSections) and len(paSections) > 0 and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a non empty list of pairs of numbers.")
		ok

		# Preparing the data

		nLenSections = len(paSections)
		aSections = QRT(paSections, :stzListOfPairs).Sorted()
		
		nLenMain = This.NumberOfItems()
		oMain = StzListQ(1:nLenMain)

		# Managing the first and last splits

		aFirstSplit = []
		n1 = paSections[1][1]
		if n1 > 1
			aFirstSplit = [ 1, n1 - 1 ]
		ok

		aLastSplit = []
		n2 = paSections[nLenSections][2]
		if n2 < nLenMain
			aLastSplit = [ n2 + 1, nLenMain ]
		ok

		# Getting other splits

		aResult = []

		if len(aFirstSplit) > 0
			aResult + aFirstSplit
		ok

		for i = 1 to nLenSections - 1
			n1 = paSections[i][2] + 1
			n2 = paSections[i+1][1] - 1
			aResult + [ n1, n2 ]
		next

		if len(aLastSplit) > 0
			aResult + aLastSplit
		ok

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

		#--

		def SplitsAtSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsAtTheseSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsBetweenSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsBetweenTheseSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsAtManySections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsBetweenManySections(paSections)
			return This.SplitAtSections(paSections)

		#>

	def SplitAtSectionsIB(paSections)
		aSections = This.SplitAtSections(paSections)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult
			
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

		#--

		def SplitsAtSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsAtTheseSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsBetweenSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsBetweenTheseSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsAtManySectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsBetweenManySectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		#>

	  #=====================================#
	 #  SPLITTING BEFORE A GIVEN SECTION   #
	#=====================================#

	def SplitBeforeSection(n1, n2)

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect pram type! panSection must be a pair of numbers.")
		ok

		return This.SplitBeforePosition(n1)

		#< @FunnctionAlternativeForm

		def SplitBeforeThisSection(n1, n2)
			return This.SplitBeforeSection(n1, n2)

		#--

		def SplitsBeforeSection(n1, n2)
			return This.SplitBeforeSection(n1, n2)

		def SplitsBeforeThisSection(n1, n2)
			return This.SplitBeforeSection(n1, n2)

		#>

	def SplitBeforeSectionIB(n1, n2)
		aSections = This.SplitBeforeSection(n1, n2)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

		#< @FunnctionAlternativeForm

		def SplitBeforeThisSectionIB(n1, n2)
			return This.SplitBeforeSectionIB(n1, n2)

		#--

		def SplitsBeforeSectionIB(n1, n2)
			return This.SplitBeforeSectionIB(n1, n2)

		def SplitsBeforeThisSectionIB(n1, n2)
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

		#--

		def SplitsBeforeSections(paSections)
			return This.SplitBeforeSections(paSections)

		def SplitsBeforeTheseSections(paSections)
			return This.SplitBeforeSections(paSections)

		def SplitsBeforeManySections(paSections)
			return This.SplitBeforeSections(paSections)

		#>

	def SplitBeforeSectionsIB(paSections)
		aSections = This.SplitBeforeSections(paSections)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def SplitBeforeTheseSectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		def SplitBeforeManySectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		#--

		def SplitsBeforeSectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		def SplitsBeforeTheseSectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		def SplitsBeforeManySectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)
	
		#>

	  #====================================#
	 #  SPLITTING AFTER A GIVEN SECTION   #
	#====================================#

	def SplitAfterSection(n1, n2)

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect pram type! n1 and n2 must be both numbers.")
		ok

		return This.SplitAfterPosition(n2)

		#< @FunctionAlternativeForms

		def SplitAfterThisSection(n1, n2)
			return This.SplitAfterSection(n1, n2)

		#--

		def SplitsAfterSection(n1, n2)
			return This.SplitAfterSection(n1, n2)

		def SplitsAfterThisSection(n1, n2)
			return This.SplitAfterSection(n1, n2)

		#>

	def SplitAfterSectionIB(n1, n2)
		aSections = This.SplitAfterSection(n1, n2)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def SplitAfterThisSectionIB(n1, n2)
			return This.SplitAfterSectionIB(n1, n2)

		#--

		def SplitsAfterSectionIB(n1, n2)
			return This.SplitAfterSectionIB(n1, n2)

		def SplitsAfterThisSectionIB(n1, n2)
			return This.SplitAfterSectionIB(n1, n2)

		#>

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

		#--

		def SplitsAfterSections(paSections)
			return This.SplitAfterSections(paSections)

		def SplitsAfterTheseSections(paSections)
			return This.SplitAfterSections(paSections)

		def SplitsAfterManySections(paSections)
			return This.SplitAfterSections(paSections)

		#>

	def SplitAfterSectionsIB(paSections)
		aSections = This.SplitAfterSections(paSections)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def SplitAfterTheseSectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		def SplitAfterManySectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		#--

		def SplitsAfterSectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		def SplitsAfterTheseSectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		def SplitsAfterManySectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		#>

	  #===================================#
	 #   SPLITTING TO PARTS OF N ITEMS   #
	#===================================#

	def SplitToPartsOfNItemsXT(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nLen = This.NumberOfPositions()

		aResult = []

		for i = 1 to nLen step n
			nTemp = i + n-1

			if nTemp > nLen
				nTemp = nLen
			ok

			aResult + [ i, nTemp ]
		next

			return aResult

		#< @FunctionAlternativeForm

		def SplitToPartsOfNXT(n)
			return This.SplitToPartsOfNItemsXT(n)

		def SplitToPartsOfXT(n)
			return This.SplitToPartsOfNItemsXT(n)

		def SplitToPartsOfNPositionsXT(n)
			return This.SplitToPartsOfNItemsXT(n)

		#--

		def SplitsToPartsOfNItemsXT(n)
			return This.SplitToPartsOfNItemsXT(n)

		def SplitsToPartsOfNXT(n)
			return This.SplitToPartsOfNItemsXT(n)

		def SplitsToPartsOfXT(n)
			return This.SplitToPartsOfNItemsXT(n)

		def SplitsToPartsOfNPositionsXT(n)
			return This.SplitToPartsOfNItemsXT(n)

		#==

		def SplitToSectionsOfNItemsXT(n)
			return This.SplitToPartsOfNItemsXT(n)

		def SplitToSectionsOfNXT(n)
			return This.SplitToSectionsOfNItemsXT(n)

		def SplitToSectionsOfXT(n)
			return This.SplitToSectionsOfNItemsXT(n)

		def SplitToSectionsOfNPositionsXT(n)
			return This.SplitToSectionsOfNItemsXT(n)

		#--

		def SplitsToSectionsOfNItemsXT(n)
			return This.SplitToSectionsOfNItemsXT(n)

		def SplitsToSectionsOfNXT(n)
			return This.SplitToSectionsOfNItemsXT(n)

		def SplitsToSectionsOfXT(n)
			return This.SplitToSectionsOfNItemsXT(n)

		def SplitsToSectionsOfNPositionsXT(n)
			return This.SplitToSectionsOfNItemsXT(n)

		#>

	  #---------------------------------------------#
	 #    SPLITTING TO PARTS OF EXACTLY N ITEMS    #
	#---------------------------------------------#

	def SplitToPartsOfNItems(n)

		aSections = This.SplitToPartsOfNItemsXT(n)
		
		nLen = len(aSections)
		aLastPair = aSections[ nLen ]

		if (aLastPair[2] - aLastPair[1] + 1) != n
			del( aSections, nLen )
		ok

		return aSections

		#< @FunctionAlternativeForms

		def SplitToPartsOfN(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToPartsOf(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToPartsOfNPositions(n)
			return This.SplitToPartsOfNItems(n)

		#--

		def SplitsToPartsOfNItems(n)
			return This.SplitToPartsOfNItems(n)

		def SplitsToPartsOfN(n)
			return This.SplitToPartsOfNItems(n)

		def SplitsToPartsOf(n)
			return This.SplitToPartsOfNItems(n)

		def SplitsToPartsOfNPositions(n)
			return This.SplitToPartsOfNItems(n)

		#--

		def SplitToPartsOfExactlyNItems(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToPartsOfExactlyN(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToPartsOfExactly(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToPartsOfExactlyNPositions(n)
			return This.SplitToPartsOfNItems(n)

		#==

		def SplittoSectionsOfNItems(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToSectionsOfN(n)
			return This.SplitToSectionsOfNItems(n)

		def SplitToSectionsOf(n)
			return This.SplitToSectionsOfNItems(n)

		def SplitToSectionsOfNPositions(n)
			return This.SplitToSectionsOfNItems(n)

		#--

		def SplitsToSectionsOfNItems(n)
			return This.SplitToSectionsOfNItems(n)

		def SplitsToSectionsOfN(n)
			return This.SplitToSectionsOfNItems(n)

		def SplitsToSectionsOf(n)
			return This.SplitToSectionsOfNItems(n)

		def SplitsToSectionsOfNPositions(n)
			return This.SplitToSectionsOfNItems(n)

		#--

		def SplitToSectionsOfExactlyNItems(n)
			return This.SplitToSectionsOfNItems(n)

		def SplitToSectionsOfExactlyN(n)
			return This.SplitToSectionsOfNItems(n)

		def SplitToSectionsOfExactly(n)
			return This.SplitToSectionsOfNItems(n)

		def SplitToSectionsOfExactlyNPositions(n)
			return This.SplitToSectionsOfNItems(n)

		#>

	  #----------------------------#
	 #    SPLITTING TO N PARTS    #
	#----------------------------#

	def SplitToNParts(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		nLen = This.NumberOfItems()
		if nLen = 0
			return []
		ok

		if NOT (n >= 0 and n <= nLen)
			StzRaise("Incorrect value! n must be between 0 and " + nLen + " (the size of the list).")
		ok
		
		aResult = []
	
		# Early checks
	
		if n = 0
			return []
	
		but n = 1
			return [ [ 1, nLen ] ]
		ok
	
		# Case where the list is even (simpler)
		# ~> each part takes nLen / n items
	
		if nLen % n = 0
			nSize = nLen / n
	
			aResult + [ 1, nSize ]
			for i = 2 to n
				n1 = aResult[i-1][2] + 1
				n2 = n1 + nSize - 1
				aResult + [n1, n2]
			next
	
		else # Case where the list is odd (more complex)
		     # We want the larger sections to be returned first

			# if the number of splits is under the half of list

			if n <= nLen / 2

				# We calculate the number of main parts and
				# how many items are remaining

				nRest = nLen % n

				nMain = nLen - nRest
				nSize = nMain / n

				# We split the list to get the main parts

				aResult = [ [ 1, nSize ] ]
				for i = 2 to n
					n1 = aResult[i-1][2] + 1
					n2 = n1 + nSize - 1
					aResult + [ n1, n2 ]
				next

				# We start adding the remaining items to
				# the main parts (starting with first)

				aResult[1][2]++
				for i = 2 to len(aResult)
					aResult[i][1]++
					aResult[i][2]++
				next

				# We do the same to add the remaining items
				# to the main parts (other then the first)

				if nRest > 1
					for i = 2 to nRest
						nDiff = aResult[i][2] - aResult[i][1]
						n1 = aResult[i-1][2] + 1
						n2 = n1 + nDiff + 1
						aResult[i][1] = n1
						aResult[i][2] = n2
					next

				ok

				for i = nRest + 1 to n
					nDiff = aResult[i][2] - aResult[i][1]
					n1 = aResult[i-1][2] + 1
					n2 = n1 + nDiff
					aResult[i][1] = n1
					aResult[i][2] = n2
				next
				//aResult[n][2] = nLen

			else # The number of splits is higher than the half of the list

				# We calculate the half of the list and
				# the difference between the half and n

				nHalf = 0+ Q(nLen / 2).IntegerPart()
				nDiff = n - nHalf

				# We split the list on nHalf parts and we include
				# just the (nHalf - ndiff) sections in the result

				aSplits = This.SplitToNParts(nHalf)
				aResult = []
				for i = 1 to nHalf - nDiff
					aResult + aSplits[i]
				next

				# We take the remaining (last nDiff) sections
				# of the splits on half and we decompose them
				# each section into two separate sections

				nStart = len(aResult) + 1
				nEnd = nStart + nDiff - 1

				for i = nStart to nEnd
					aSection = aSplits[i]
					n1 = aSection[1]
					n2 = aSection[2]
					aResult + [ n1, n1 ] + [ n2, n2 ]
				next

			ok
		ok
	
		# Finally, we return the result
		return aResult
	
		#< @FunctionAlternativeForms

		def SplitsToNParts(n)
			return This.SplitToNParts(n)

		#--

		def SplitToNSections(n)
			return This.SplitToNParts(n)

		def SplitsToNSections(n)
			return This.SplitToNParts(n)

		#>

	  #===============================================#
	 #  SPLITTING AROUND POSITION(S) OR SECTION(s)  #
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
				return This.SplitAroundSections(p)
			ok
		else
			StzRaise("Incorrect param type! p must be a number or pair of numbers or list of numbers.")

		ok

		def SplitsAround(p)
			return This.SplitAround(p)

	def SplitAroundIB(p)
		aSections = This.SplitAround(p)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

		def SplitsAroundIB(p)
			return This.SplitAroundIB(p)

	  #-------------------------------#
	 #  SPLITTING AROUND A POSITION  #
	#===============================#

	def SplitAroundPosition(n)

		# Checking the param

		if CheckingParams()
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

		aSection1 = [1, (n-1) ]
		aSection2 = [ (n+1), nLen ]

		aResult = [ aSection1, aSection2 ]
		return aResult

		def SplitsAroundPosition(n)
			return This.SplitAroundPosition(n)

	def SplitAroundPositionIB(n)
		aSections = This.SplitAroundPosition(n)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

		def SplitsAroundPositionIB(n)
			return This.SplitAroundPositionIB(n)

	  #------------------------------#
	 #  SPLITTING AROUND POSITIONS  #
	#------------------------------#

	def SplitAroundPositions(panPos)
		aResult = This.AntiPositionsZZ(panPos)
		return aResult

		def SplitsAroundPositions(panPos)
			return This.SplitAroundPositions(panPos)

	def SplitAroundPositionsIB(panPos)
		aSections = This.SplitAroundPositions(panPos)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

		def SplitsAroundPositionsIB(panPos)
			return This.SplitAroundPositionsIB(panPos)

	  #------------------------------#
	 #  SPLITTING AROUND A SECTION  #
	#------------------------------#

	def SplitAroundSection(n1, n2)
		aResult = This.AntiSectionZZ(n1, n2)
		return aResult

		def SplitsAroundSection(n1, n2)
			return This.SplitAroundSection(n1, n2)

	def SplitAroundSectionIB(n1, n2)
		aSections = This.SplitAroundSection(n1, n2)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult
		
		def SplitsAroundSectionIB(n1, n2)
			return This.SplitAroundSectionIB(n1, n2)

	  #-----------------------------#
	 #  SPLITTING AROUND SECTIONS  #
	#-----------------------------#

	def SplitAroundSections(paSections)
		aResult = This.FindAntiSectionsZZ(paSections)
		return aResult

		def SplitsAroundSections(paSections)
			return This.SplitAroundSections(paSections)

	def SplitAroundSectionsIB(paSections)
		aSections = This.SplitAroundSections(paSections)
		aResult = This.pvtSectionsToSectionsIB(aSections)
		return aResult

		def SplitsAroundSectionsIB(paSections)
			return This.SplitAroundSectionsIB(paSections)

	  #=======================================================#
	 #   Utility functions used by the other methods above   #
	#=======================================================#

	#TODO // A general function, can move to stzListOfNumbers

	def GetPairsFromPositions(panPos)
		/*
		Main list 	--> 1:10
		panPos		--> [ 3, 6, 8 ]
		List of pairs	--> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]
		*/

		nLen = This.NumberOfPositions()
		panPos + nLen

		# Eliminating doubble positions
		aPos = StzListQ(panPos).ToSet()

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

		nLenPairs = len(aPairs)
		aLastPair = aPairs[nLenPairs]
		aBeforeLastPair = aPairs[nLenPairs-1]

		if aLastPair[1] = nLen and
		   aLastPair[2] = nLen and
		   aBeforeLastPair[2] = nLen

			del(aPairs, nLenPairs)
		ok

		return aPairs

	def ToStzList()
		return StzListQ(This.Content())

	PRIVATE

	def pvtSectionsToSectionsIB(aSections)

		nLen = len(aSections)

		if nLen = 1
			if aSections[1][1] > 1
				aSections[1][1] -= @nLenPart
			ok

			if aSections[1][2] < This.NumberOfItems()
				aSections[1][2] += @nLenPart
			ok

			return aSections
		ok

		# Adding the first section

		aResult = [] + [ aSections[1][1], aSections[1][2] + @nLenPart ]

		# Adding the sections between the first and last sections

		nLenBetween = nLen - 2

		for i = 1 to nLenBetween
			aResult + [ aSections[i+1][1] - @nLenPart, aSections[i+1][2] + @nLenPart ]
		next

		# adding the last section

		aResult + [ aSections[nLen][1] - @nLenPart, aSections[nLen][2] ]
		return aResult
