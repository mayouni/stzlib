
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
		_aResult_ = 1:This.NumberOfPositions()
		return _aResult_

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

		_oParam_ = Q(p)

		#-- :At

		if _oParam_.IsAtNamedParam()
			return This.SplitAtPosition(p[2])

		but _oParam_.IsAtIBNamedParam()
			return This.SplitAtPositionIB(p[2])

		#-- :AtPosition

		but IsOneOfTheseNamedParamsList(p,[
			:AtPosition, :AtThisPosition ])

			return This.SplitAtPositionIB(p[2])

		but IsOneOfTheseNamedParamsList(p,[
			:AtPositionIB, :AtThisPositionIB ])

			return This.SplitAtPositionIB(p[2])

		#-- :AtPositions

		but IsOneOfTheseNamedParamsList(p,[
			:AtPositions, :AtThesePositions, :AtManyPositions ])

			return This.SplitAtPositions(p[2])

		but IsOneOfTheseNamedParamsList(p,[
			:AtPositionsIB, :AtThesePositionsIB, :AtManyPositionsIB ])

			return This.SplitAtPositionsIB(p[2])

		#-- :BeforePosition

		but IsOneOfTheseNamedParamsList(p,[
			:Before, :BeforePosition, :BeforeThisPosition ])

			return This.SplitAtPosition(p[2])

		but IsOneOfTheseNamedParamsList(p,[
			:BeforeIB, :BeforePositionIB, :BeforeThisPositionIB ])

			return This.SplitAtPositionIB(p[2])

		#-- :BeforePositions

		but IsOneOfTheseNamedParamsList(p,[
			:BeforePositions, :BeforeThesePositions, :BeforeManyPositions ])

			return This.SplitBeforePositions(p[2])

		but IsOneOfTheseNamedParamsList(p,[
			:BeforePositionsIB, :BeforeThesePositionsIB, :BeforeManyPositionsIB ])

			return This.SplitBeforePositionsIB(p[2])

		#-- :AfterPosition

		but IsOneOfTheseNamedParamsList(p,[
			:After, :AfterPosition, :AfterThisPosition ])

			return This.SplitAfterPosition(p[2])

		but IsOneOfTheseNamedParamsList(p,[
			:AfterIB, :AfterPositionIB, :AfterThisPositionIB ])

			return This.SplitAfterPositionIB(p[2])

		# :AfterPositions

		but IsOneOfTheseNamedParamsList(p,[
			:AfterPositions, :AfterThesePositions, :AfterManyPositions ])

			return This.SplitAfterPositions(p[2])

		but IsOneOfTheseNamedParamsList(p,[
			:AfterPositionsIB, :AfterThesePositionsIB, :AfterManyPositionsIB ])

			return This.SplitAfterPositionsIB(p[2])

		#-- :AtSection

		but IsOneOfTheseNamedParamsList(p,[ :AtSection, :AtThisSection ])
			return This.SplitAtSection(p[2][1], p[2][2])

		but IsOneOfTheseNamedParamsList(p,[ :AtSectionIB, :AtThisSectionIB ])
			return This.SplitAtSectionIB(p[2][1], p[2][2])

		#-- :AtSections

		but IsOneOfTheseNamedParamsList(p,[
			:AtSections, :AtTheseSections, :AtManySections ])

			return This.SplitAtSections(p[2])

		but IsOneOfTheseNamedParamsList(p,[
			:AtSectionsIB, :AtTheseSectionsIB, :AtManySectionsIB ])

			return This.SplitAtSectionsIB(p[2])

		#-- :BeforeSection

		but IsOneOfTheseNamedParamsList(p,[ :BeforeSection, :BeforeThisSection ])
			return This.SplitBeforeSection(p[2][1], p[2][2])

		but IsOneOfTheseNamedParamsList(p,[ :BeforeSectionIB, :BeforeThisSectionIB ])
			return This.SplitBeforeSectionIB(p[2][1], p[2][2])

		#-- :BeforeSections

		but IsOneOfTheseNamedParamsList(p,[
			:BeforeSections, :BeforeTheseSections, :BeforeManySections ])

			return This.SplitBeforeSections(p[2])

		but IsOneOfTheseNamedParamsList(p,[
			:BeforeSectionsIB, :BeforeTheseSectionsIB, :BeforeManySectionsIB ])

			return This.SplitBeforeSectionsIB(p[2])

		#-- :AfterSection

		but IsOneOfTheseNamedParamsList(p,[ :AfterSection, :AfterThisSection ])
			return This.SplitAfterSection(p[2][1], p[2][2])

		but IsOneOfTheseNamedParamsList(p,[ :AfterSectionIB, :AfterThisSectionIB ])
			return This.SplitAfterSectionIB(p[2][1], p[2][2])

		#-- :AfterSections

		but IsOneOfTheseNamedParamsList(p,[
			:AfterSections, :AfterTheseSections, :AfterManySections ])

			return This.SplitAfterSections(p[2])

		but IsOneOfTheseNamedParamsList(p,[
			:AfterSectionsIB, :AfterTheseSectionsIB, :AfterManySectionsIB ])

			return This.SplitAfterSectionsIB(p[2])

		#== Misc.

		but _oParam_.IsToPartsOfNItemsNamedParam()
			return This.SplitToPartsOfNItemsXT(p[2])

		but _oParam_.IsToPartsOfExactlyNItemsNamedParam()
			return This.SplitToPartsOfNItems(p[2])

		but _oParam_.IsToNPartsNamedParam()
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
			_oParam_ = Q(p)

			if _oParam_.IsListOfNumbers()
				return This.SplitAtPositions(p)

			but _oParam_.IsListOfPairsOfNumbers()
				return This.SplitAtSections(p)

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Position, :ThisPosition ])
				return This.SplitAtPosition(p[2])

			but IsOneOfTheseNamedParamsList(p,[ :PositionsIB, :ThesePositionsIB ])
				return This.SplitAtPositionsIB(p[2])

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Section, :ThisSection ])
				return This.SplitAtSection(p[2][1], p[2][2])

			but IsOneOfTheseNamedParamsList(p,[ :SectionIB, :ThisSectionIB ])
				return This.SplitAtSectionIB(p[2][1], p[2][2])

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Sections, :TheseSections ])
				return This.SplitAtSections(p[2])

			but IsOneOfTheseNamedParamsList(p,[ :SectionsIB, :TheseSectionsIB ])
				return This.SplitAtSectionsIB(p[2])

			#==

			but _oParam_.IsToPartsOfNItemsNamedParam() or
			    _oParam_.IsToPartsOfExactlyNItemsNamedParam()

				return This.SplitToPartsOfNItems(p[2])

			but _oParam_.IsToPartsOfNItemsXTNamedParam()

				return This.SplitToPartsOfNItemsXT(p[2])

			but _oParam_.IsToNPartsNamedParam() or
			    _oParam_.IsToExactlyNPartsNamedParam()

				return This.SplitToNParts(p[2])

			but _oParam_.IsToNPartsXTNamedParam()
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

		_nLen_ = @nNumberOfPositions

		if n > 1 and n < _nLen_
			_aResult_ = [ [ 1, n-1], [n+1, _nLen_ ] ]

		but n = 1 and _nLen_ > 1
			_aResult_ = [ [ 2, _nLen_ ] ]

		but n = _nLen_ and _nLen_ > 1 
			_aResult_ = [ [ 1, _nLen_-1] ]

		else
			_aResult_ = [ 1 , _nLen_ ]
		ok

		return _aResult_

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

		_nLenPos_ = len(panPos)
		if _nLenPos_ = 0
			return This.Content()

		but _nLenPos_ = 1
			return This.SplitAtPosition(panPos[1])
		ok

		_oChain_ = new stzList(panPos)

		panPos = _oChain_.Sorted()
		_aPairs_ = This.GetPairsFromPositions(panPos)

		_nFirstPos_ = panPos[1]
		_nLastPos_ = panPos[_nLenPos_]

		_nLenPairs_ = len(_aPairs_)

		if _aPairs_[_nLenPairs_][2] = _nLastPos_
			_aPairs_[_nLenPairs_][2]--
		ok

		if _aPairs_[1][1] = _nFirstPos_
			_aPairs_[1][1]++
		ok

		for i = 1 to _nLenPairs_ - 1
			_aPairs_[i][2]--
			_aPairs_[i+1][1]++
		next

		return _aPairs_

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
			_oParam_ = Q(p)
			if _oParam_.IsListOfNumbers()
				return This.SplitBeforePositions(p)

			but _oParam_.IsListOfPairsOfNumbers()
				return This.SplitBeforeSections(p)

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Position, :ThisPosition ])
				return This.SplitBeforePosition(p[2])

			but IsOneOfTheseNamedParamsList(p,[ :PositionIB, :ThisPositionIB ])
				return This.SplitBeforePositionIB(p[2])

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Positions, :ThesePositions ])
				return This.SplitBeforePositions(p[2])

			but IsOneOfTheseNamedParamsList(p,[ :PositionsIB, :ThesePositionsIB ])
				return This.SplitBeforePositionsIB(p[2])

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Section, :ThisSection ])
				return This.SplitBeforeSection(p[2][1], p[2][2])

			but IsOneOfTheseNamedParamsList(p,[ :SectionIB, :ThisSectionIB ])
				return This.SplitBeforeSectionIB(p[2][1], p[2][2])

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Sections, :TheseSections ])
				return This.SplitBeforeSections(p[2])

			but IsOneOfTheseNamedParamsList(p,[ :SectionsIB, :TheseSectionsIB ])
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

		_nLen_ = This.NumberOfItems()

		_oTmpSpSort_ = new stzList(panPos)
		_anPos_ = U( _oTmpSpSort_.Sorted() )
		_nLenPos_ = len(_anPos_)

		for i = 1 to _nLenPos_
			if NOT (_anPos_[i] >= 1 and _anPos_[i] <= _nLen_)
				StzRaise("Incorrect param type! panPos must contain unique numbers between 1 and " + _nLen_ + ".")
			ok
		next

		# Doing the job

   		_aResult_ = []
   		_nStart_ = 1

		for i = 1 to _nLenPos_
			_nPos_ = _anPos_[i]
	       		_aResult_ + [ _nStart_, _nPos_-1 ]
	        	_nStart_ = _nPos_
		next

		if _aResult_[1][1] = 1 and _aResult_[1][2] = 0
			del(_aResult_, 1)
		ok

		_aResult_ + [_nStart_, _nLen_]

    		return _aResult_


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
			_oParam_ = Q(p)
			if _oParam_.IsListOfNumbers()
				return This.SplitAfterPositions(p)

			but _oParam_.IsListOfPairsOfNumbers()
				return This.SplitAfterSections(p)

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Position, :ThisPosition ])
				return This.SplitAfterPosition(p[2])

			but IsOneOfTheseNamedParamsList(p,[ :PositionIB, :ThisPositionIB ])
				return This.SplitAfterPositionIB(p[2])

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Positions, :ThesePositions ])
				return This.SplitAfterPositions(p[2])

			but IsOneOfTheseNamedParamsList(p,[ :PositionsIB, :ThesePositionsIB ])
				return This.SplitAfterPositionsIB(p[2])

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Section, :ThisSection ])
				return This.SplitAfterSection(p[2][1], p[2][2])

			but IsOneOfTheseNamedParamsList(p,[ :SectionIB, :ThisSectionIB ])
				return This.SplitAfterSectionIB(p[2][1], p[2][2])

			#--

			but IsOneOfTheseNamedParamsList(p,[ :Sections, :TheseSections ])
				return This.SplitAfterSections(p[2])

			but IsOneOfTheseNamedParamsList(p,[ :SectionsIB, :TheseSectionsIB ])
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

		_nLen_ = This.NumberOfItems()

		_oTmpSpSort_ = new stzList(panPos)
		_anPos_ = U( _oTmpSpSort_.Sorted() )
		_nLenPos_ = len(_anPos_)

		for i = 1 to _nLenPos_
			if NOT (_anPos_[i] >= 1 and _anPos_[i] <= _nLen_)
				StzRaise("Incorrect param type! panPos must contain unique numbers between 1 and " + _nLen_ + ".")
			ok
		next

		# Doing the job

   		_aResult_ = []
   		_nStart_ = 1

		for i = 1 to _nLenPos_
			_nPos_ = _anPos_[i]
	       		_aResult_ + [ _nStart_, _nPos_ ]
	        	_nStart_ = _nPos_ + 1
		next

		if _nStart_ <= _nLen_
			_aResult_ + [_nStart_, _nLen_]
		ok

    		return _aResult_

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
		_aSections_ = This.SplitAfterPositions(panPos)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

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

	def SplitAtSection(_n1_, _n2_)
		/* EXAMPLE

		_o1_ = new stzSplitter(8)
		? _o1_.SplitAtSection([3,5])

		# 1..2..3..4..5..8
		#       ^-----^

		#--> [ [1,2], [6,8] ]

		# If you want to include the bounds of the sections
		# in the result, use the ...IB() extension like this:

		? _o1_.SplitAtSectionIB([3,5])
		#--> [ [1,3], [5,8] ]

		*/

		if NOT (isNumber(_n1_) and isNumber(_n2_))
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		_nLen_ = This.NumberOfPositions()

		if NOT ( (_n1_ >= 1 and _n1_ <= _nLen_) and (_n1_ >= 1 and _n1_ <= _nLen_) )

			StzRaise("Can't split! Indices provided in panSection must be between 1 and " +
				  _nLen_ + "." )
		ok

		_aResult_ = []

		if _n1_-1 >= 1 and _n1_-1 <= _nLen_
			_aResult_ + [ 1, _n1_ - 1 ]
		ok

		if _n2_+1 >= 1 and _n2_+1 <= _nLen_
			_aResult_ + [ _n2_ + 1, _nLen_ ]
		ok

		return _aResult_

		#< @FunnctionAlternativeForms

		def SplitAtThisSection(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		def SplitBetween(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		def SplitBetweenPositions(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		def SplitBetweenThesePositions(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		def SplitBetweenManyPositions(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		#--

		def SplitsAtSection(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		def SplitsAtThisSection(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		def SplitsBetween(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		def SplitsBetweenPositions(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		def SplitsBetweenThesePositions(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		def SplitsBetweenManyPositions(_n1_, _n2_)
			return This.SplitAtSection(_n1_, _n2_)

		#>

	def SplitAtSectionIB(_n1_, _n2_)

		_aSections_ = This.SplitAtSection(_n1_, _n2_)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

		#< @FunnctionAlternativeForms

		def SplitAtThisSectionIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		def SplitBetweenIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		def SplitBetweenPositionsIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		def SplitBetweenThesePositionsIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		def SplitBetweenManyPositionsIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		#--

		def SplitsAtSectionIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		def SplitsAtThisSectionIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		def SplitsBetweenIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		def SplitsBetweenPositionsIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		def SplitsBetweenThesePositionsIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		def SplitsBetweenManyPositionsIB(_n1_, _n2_)
			return This.SplitAtSectionIB(_n1_, _n2_)

		#>

	  #------------------------------#
	 #  SPLITTING AT MANY SECTIONS  #
	#------------------------------#

	def SplitAtSections(paSections)
		/* EXAMPLE

		_o1_ = new stzSplitter(10)
		? _o1_.SplitAtSections([ [3,5], [8,9] ])

		# 1..2..3..4..5..6..7..8..9..10
		#       ^-----^        ^--^

		#--> [ [1,2], [6,7], [10,10] ]

		# If you want to include the bounds of the sections
		# in the result, use the ...IB() extension like this:

		? _o1_.SplitAtSectionsIB([ [3,5], [8,9] ])
		#--> [ [1,3], [5,8], [9,10] ]

		*/

		# Checking params

		if NOT ( isList(paSections) and len(paSections) > 0 and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a non empty list of pairs of numbers.")
		ok

		# Preparing the data

		_nLenSections_ = len(paSections)
		_aSections_ = QRT(paSections, :stzListOfPairs).Sorted()
		
		_nLenMain_ = This.NumberOfItems()
		_oMain_ = StzListQ(1:nLenMain)

		# Managing the first and last splits

		_aFirstSplit_ = []
		_n1_ = paSections[1][1]
		if _n1_ > 1
			_aFirstSplit_ = [ 1, _n1_ - 1 ]
		ok

		_aLastSplit_ = []
		_n2_ = paSections[_nLenSections_][2]
		if _n2_ < _nLenMain_
			_aLastSplit_ = [ _n2_ + 1, _nLenMain_ ]
		ok

		# Getting other splits

		_aResult_ = []

		if len(_aFirstSplit_) > 0
			_aResult_ + _aFirstSplit_
		ok

		for i = 1 to _nLenSections_ - 1
			_n1_ = paSections[i][2] + 1
			_n2_ = paSections[i+1][1] - 1
			_aResult_ + [ _n1_, _n2_ ]
		next

		if len(_aLastSplit_) > 0
			_aResult_ + _aLastSplit_
		ok

		return _aResult_


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
		_aSections_ = This.SplitAtSections(paSections)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_
			
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

	def SplitBeforeSection(_n1_, _n2_)

		if NOT (isNumber(_n1_) and isNumber(_n2_))
			StzRaise("Incorrect pram type! panSection must be a pair of numbers.")
		ok

		return This.SplitBeforePosition(_n1_)

		#< @FunnctionAlternativeForm

		def SplitBeforeThisSection(_n1_, _n2_)
			return This.SplitBeforeSection(_n1_, _n2_)

		#--

		def SplitsBeforeSection(_n1_, _n2_)
			return This.SplitBeforeSection(_n1_, _n2_)

		def SplitsBeforeThisSection(_n1_, _n2_)
			return This.SplitBeforeSection(_n1_, _n2_)

		#>

	def SplitBeforeSectionIB(_n1_, _n2_)
		_aSections_ = This.SplitBeforeSection(_n1_, _n2_)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

		#< @FunnctionAlternativeForm

		def SplitBeforeThisSectionIB(_n1_, _n2_)
			return This.SplitBeforeSectionIB(_n1_, _n2_)

		#--

		def SplitsBeforeSectionIB(_n1_, _n2_)
			return This.SplitBeforeSectionIB(_n1_, _n2_)

		def SplitsBeforeThisSectionIB(_n1_, _n2_)
			return This.SplitBeforeSectionIB(_n1_, _n2_)

		#>

	  #----------------------------------#
	 #  SPLITTING BEFORE MANY SECTIONS  #
	#----------------------------------#

	def SplitBeforeSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		_anPos_ = StzListOfPairsQ(paSections).FirstItems()
		return This.SplitBeforePositions(_anPos_)

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
		_aSections_ = This.SplitBeforeSections(paSections)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

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

	def SplitAfterSection(_n1_, _n2_)

		if NOT (isNumber(_n1_) and isNumber(_n2_))
			StzRaise("Incorrect pram type! n1 and n2 must be both numbers.")
		ok

		return This.SplitAfterPosition(_n2_)

		#< @FunctionAlternativeForms

		def SplitAfterThisSection(_n1_, _n2_)
			return This.SplitAfterSection(_n1_, _n2_)

		#--

		def SplitsAfterSection(_n1_, _n2_)
			return This.SplitAfterSection(_n1_, _n2_)

		def SplitsAfterThisSection(_n1_, _n2_)
			return This.SplitAfterSection(_n1_, _n2_)

		#>

	def SplitAfterSectionIB(_n1_, _n2_)
		_aSections_ = This.SplitAfterSection(_n1_, _n2_)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

		#< @FunctionAlternativeForms

		def SplitAfterThisSectionIB(_n1_, _n2_)
			return This.SplitAfterSectionIB(_n1_, _n2_)

		#--

		def SplitsAfterSectionIB(_n1_, _n2_)
			return This.SplitAfterSectionIB(_n1_, _n2_)

		def SplitsAfterThisSectionIB(_n1_, _n2_)
			return This.SplitAfterSectionIB(_n1_, _n2_)

		#>

	  #---------------------------------#
	 #  SPLITTING AFTER MANY SECTIONS  #
	#---------------------------------#

	def SplitAfterSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		_anPos_ = StzListOfPairsQ(paSections).SecondItems()
		return This.SplitAfterPositions(_anPos_)

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
		_aSections_ = This.SplitAfterSections(paSections)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

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

		_nLen_ = This.NumberOfPositions()

		_aResult_ = []

		for i = 1 to _nLen_ step n
			_nTemp_ = i + n-1

			if _nTemp_ > _nLen_
				_nTemp_ = _nLen_
			ok

			_aResult_ + [ i, _nTemp_ ]
		next

			return _aResult_

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

		_aSections_ = This.SplitToPartsOfNItemsXT(n)
		
		_nLen_ = len(_aSections_)
		_aLastPair_ = _aSections_[ _nLen_ ]

		if (_aLastPair_[2] - _aLastPair_[1] + 1) != n
			del( _aSections_, _nLen_ )
		ok

		return _aSections_

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

		_nLen_ = This.NumberOfItems()
		if _nLen_ = 0
			return []
		ok

		if NOT (n >= 0 and n <= _nLen_)
			StzRaise("Incorrect value! n must be between 0 and " + _nLen_ + " (the size of the list).")
		ok
		
		_aResult_ = []
	
		# Early checks
	
		if n = 0
			return []
	
		but n = 1
			return [ [ 1, _nLen_ ] ]
		ok
	
		# Case where the list is even (simpler)
		# ~> each part takes nLen / n items
	
		if _nLen_ % n = 0
			_nSize_ = _nLen_ / n
	
			_aResult_ + [ 1, _nSize_ ]
			for i = 2 to n
				_n1_ = _aResult_[i-1][2] + 1
				_n2_ = _n1_ + _nSize_ - 1
				_aResult_ + [_n1_, _n2_]
			next
	
		else # Case where the list is odd (more complex)
		     # We want the larger sections to be returned first

			# if the number of splits is under the half of list

			if n <= _nLen_ / 2

				# We calculate the number of main parts and
				# how many items are remaining

				_nRest_ = _nLen_ % n

				_nMain_ = _nLen_ - _nRest_
				_nSize_ = _nMain_ / n

				# We split the list to get the main parts

				_aResult_ = [ [ 1, _nSize_ ] ]
				for i = 2 to n
					_n1_ = _aResult_[i-1][2] + 1
					_n2_ = _n1_ + _nSize_ - 1
					_aResult_ + [ _n1_, _n2_ ]
				next

				# We start adding the remaining items to
				# the main parts (starting with first)

				_aResult_[1][2]++
				_nResultLen_ = len(_aResult_)
				for i = 2 to _nResultLen_
					_aResult_[i][1]++
					_aResult_[i][2]++
				next

				# We do the same to add the remaining items
				# to the main parts (other then the first)

				if _nRest_ > 1
					for i = 2 to _nRest_
						_nDiff_ = _aResult_[i][2] - _aResult_[i][1]
						_n1_ = _aResult_[i-1][2] + 1
						_n2_ = _n1_ + _nDiff_ + 1
						_aResult_[i][1] = _n1_
						_aResult_[i][2] = _n2_
					next

				ok

				for i = _nRest_ + 1 to n
					_nDiff_ = _aResult_[i][2] - _aResult_[i][1]
					_n1_ = _aResult_[i-1][2] + 1
					_n2_ = _n1_ + _nDiff_
					_aResult_[i][1] = _n1_
					_aResult_[i][2] = _n2_
				next
				//aResult[n][2] = nLen

			else # The number of splits is higher than the half of the list

				# We calculate the half of the list and
				# the difference between the half and n

				_nHalf_ = 0+ Q(_nLen_ / 2).IntegerPart()
				_nDiff_ = n - _nHalf_

				# We split the list on nHalf parts and we include
				# just the (nHalf - ndiff) sections in the result

				_aSplits_ = This.SplitToNParts(_nHalf_)
				_aResult_ = []
				for i = 1 to _nHalf_ - _nDiff_
					_aResult_ + _aSplits_[i]
				next

				# We take the remaining (last nDiff) sections
				# of the splits on half and we decompose them
				# each section into two separate sections

				_nStart_ = len(_aResult_) + 1
				_nEnd_ = _nStart_ + _nDiff_ - 1

				for i = _nStart_ to _nEnd_
					_aSection_ = _aSplits_[i]
					_n1_ = _aSection_[1]
					_n2_ = _aSection_[2]
					_aResult_ + [ _n1_, _n1_ ] + [ _n2_, _n2_ ]
				next

			ok
		ok
	
		# Finally, we return the result
		return _aResult_
	
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
			_oParam_ = Q(p)
			if _oParam_.IsPairOfNumbers()
				return This.SplitAroundSection(p)

			but _oParam_.IsListOfNumbers()
				return This.SplitAroundPositions(p)

			but _oParam_.IsListOfPairsOfNumbers()
				return This.SplitAroundSections(p)
			ok
		else
			StzRaise("Incorrect param type! p must be a number or pair of numbers or list of numbers.")

		ok

		def SplitsAround(p)
			return This.SplitAround(p)

	def SplitAroundIB(p)
		_aSections_ = This.SplitAround(p)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

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

		_nLen_ = This.Size()

		# Managing extreme cases

		if _nLen_ = 0 or (_nLen_ = 1 and n = 1)
			return []

		but NOT ( 1 <= n and n <= This.Size() )
			return This.Content()

		but n = 1 and _nLen_ > 1
			return 2 : _nLen_

		but n = _nLen_
			return 1 : _nLen_-1
		ok

		# Managing the normal case

		_aSection1_ = [1, (n-1) ]
		_aSection2_ = [ (n+1), _nLen_ ]

		_aResult_ = [ _aSection1_, _aSection2_ ]
		return _aResult_

		def SplitsAroundPosition(n)
			return This.SplitAroundPosition(n)

	def SplitAroundPositionIB(n)
		_aSections_ = This.SplitAroundPosition(n)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

		def SplitsAroundPositionIB(n)
			return This.SplitAroundPositionIB(n)

	  #------------------------------#
	 #  SPLITTING AROUND POSITIONS  #
	#------------------------------#

	def SplitAroundPositions(panPos)
		_aResult_ = This.AntiPositionsZZ(panPos)
		return _aResult_

		def SplitsAroundPositions(panPos)
			return This.SplitAroundPositions(panPos)

	def SplitAroundPositionsIB(panPos)
		_aSections_ = This.SplitAroundPositions(panPos)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

		def SplitsAroundPositionsIB(panPos)
			return This.SplitAroundPositionsIB(panPos)

	  #------------------------------#
	 #  SPLITTING AROUND A SECTION  #
	#------------------------------#

	def SplitAroundSection(_n1_, _n2_)
		_aResult_ = This.AntiSectionZZ(_n1_, _n2_)
		return _aResult_

		def SplitsAroundSection(_n1_, _n2_)
			return This.SplitAroundSection(_n1_, _n2_)

	def SplitAroundSectionIB(_n1_, _n2_)
		_aSections_ = This.SplitAroundSection(_n1_, _n2_)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_
		
		def SplitsAroundSectionIB(_n1_, _n2_)
			return This.SplitAroundSectionIB(_n1_, _n2_)

	  #-----------------------------#
	 #  SPLITTING AROUND SECTIONS  #
	#-----------------------------#

	def SplitAroundSections(paSections)
		_aResult_ = This.FindAntiSectionsZZ_local(paSections)
		return _aResult_

	def FindAntiSectionsZZ_local(paSections)
		if NOT isList(paSections) return [] ok
		_aSorted_ = _ListCopy(paSections)
		_nL_ = len(_aSorted_)
		for _i_ = 2 to _nL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and isList(_aSorted_[_j_]) and isList(_v_) and _aSorted_[_j_][1] > _v_[1]
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		_aRes_ = []
		_nPrev_ = 0
		_nTotal_ = @nNumberOfPositions
		if NOT isNumber(_nTotal_) _nTotal_ = 0 ok
		for _i_ = 1 to _nL_
			_s_ = _aSorted_[_i_]
			if isList(_s_) and len(_s_) >= 2
				if _s_[1] > _nPrev_ + 1
					_aRes_ + [ _nPrev_ + 1, _s_[1] - 1 ]
				ok
				_nPrev_ = _s_[2]
			ok
		next
		if _nTotal_ > _nPrev_
			_aRes_ + [ _nPrev_ + 1, _nTotal_ ]
		ok
		return _aRes_

		def SplitsAroundSections(paSections)
			return This.SplitAroundSections(paSections)

	def SplitAroundSectionsIB(paSections)
		_aSections_ = This.SplitAroundSections(paSections)
		_aResult_ = This.pvtSectionsToSectionsIB(_aSections_)
		return _aResult_

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

		_nLen_ = This.NumberOfPositions()
		panPos + _nLen_

		# Eliminating doubble positions
		_aPos_ = UCS(panPos, 1)

		# Doing the job

		if len(_aPos_) = 0
			return [ [] ]
		ok
		
		# Adding 1 and (NumberOfItems()) if inexistant
		if _aPos_[1] != 1 { _aPos_ + 1 }
		if _aPos_[len(_aPos_)] != 10 { _aPos_ + _nLen_ }
		
		# Sorting the list
		_oChain_ = new stzList(_aPos_)
		_aPos_ = _oChain_.Sorted()
		
		# Getting the pairs of that list

		_aPairs_ = []
		_nPosLen_ = len(_aPos_)
		for i = 1 to _nPosLen_ - 1
			_aPairs_ + [ _aPos_[i], _aPos_[i+1] ]
		next

		_nLenPairs_ = len(_aPairs_)
		_aLastPair_ = _aPairs_[_nLenPairs_]
		_aBeforeLastPair_ = _aPairs_[_nLenPairs_-1]

		if _aLastPair_[1] = _nLen_ and
		   _aLastPair_[2] = _nLen_ and
		   _aBeforeLastPair_[2] = _nLen_

			del(_aPairs_, _nLenPairs_)
		ok

		return _aPairs_

	def ToStzList()
		return StzListQ(This.Content())

	PRIVATE

	def pvtSectionsToSectionsIB(_aSections_)

		_nLen_ = len(_aSections_)

		if _nLen_ = 1
			if _aSections_[1][1] > 1
				_aSections_[1][1] -= @nLenPart
			ok

			if _aSections_[1][2] < This.NumberOfItems()
				_aSections_[1][2] += @nLenPart
			ok

			return _aSections_
		ok

		# Adding the first section

		_aResult_ = [] + [ _aSections_[1][1], _aSections_[1][2] + @nLenPart ]

		# Adding the sections between the first and last sections

		_nLenBetween_ = _nLen_ - 2

		for i = 1 to _nLenBetween_
			_aResult_ + [ _aSections_[i+1][1] - @nLenPart, _aSections_[i+1][2] + @nLenPart ]
		next

		# adding the last section

		_aResult_ + [ _aSections_[_nLen_][1] - @nLenPart, _aSections_[_nLen_][2] ]
		return _aResult_
