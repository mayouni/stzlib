#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTNAMEDPARAMS          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List named params subclass -- 1500+ methods #
#                  for checking if a list is a named param.     #
#                  Will be progressively migrated to use the    #
#                  engine-backed IsNamedParamList() functions.  #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListNamedParams

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListNamedParams! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oList.Content()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	def Item(n)
		return @oList.Item(n)

	def IsHashList()
		return @oList.IsHashList()

	def ToStzHashList()
		return @oList.ToStzHashList()

	  #=================================================================#
	  #  ENGINE-BACKED UNIVERSAL METHODS                                #
	  #  Use these instead of specific IsXxxNamedParam() when possible. #
	  #  Each call does an O(1) hash lookup in the Zig engine.          #
	  #=================================================================#

	def IsANamedParam()
		return IsNamedParamList(This.Content())

	def IsNamedParamWith(cKeyword)
		return IsThisNamedParam(This.Content(), cKeyword)

	# NOTE: IsOneOfTheseNamedParams is defined further below (line ~916)
	# with the full eval-based implementation. Removed duplicate here.

	  #=================================================================#
	  #  LEGACY NAMED PARAM METHODS (1500+)                             #
	  #  Extracted from stzList monolith. Each method checks if the     #
	  #  list is a [:keyword, value] pair with a specific keyword.      #
	  #  These will be progressively replaced by callers using the      #
	  #  engine-backed methods above.                                   #
	  #=================================================================#

	def IsOnPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnPosition)

			return 1
		else
			return 0
		ok

		def IsInPositionNamedParam()
			if This.NumberOfItems() = 2 and
			   ( isString(This.Item(1)) and This.Item(1) = :InPosition)
	
				return 1
			else
				return 0
			ok
	
		// def IsAtPositionNamedParam() --> Exists below in the file


	def IsOnPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnPositions)

			return 1
		else
			return 0
		ok

		def IsInPositionsNamedParam()
			if This.NumberOfItems() = 2 and
			   ( isString(This.Item(1)) and This.Item(1) = :InPositions)
	
				return 1
			else
				return 0
			ok

	def IsOnSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnSection)

			return 1
		else
			return 0
		ok

	def IsOnSectionIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnSectionIB)

			return 1
		else
			return 0
		ok

	def IsOnSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnSections)

			return 1
		else
			return 0
		ok

	def IsOnSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnSectionsIB)

			return 1
		else
			return 0
		ok

	def IsHarvestNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Harvest)

			return 1
		else
			return 0
		ok

	def IsAndHarvestNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndHarvest)

			return 1
		else
			return 0
		ok

	def IsAndThenHarvestNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndThenHarvest)

			return 1
		else
			return 0
		ok

	def IsThenHarvestNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ThenHarvest)

			return 1
		else
			return 0
		ok

	def IsYieldNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Yield)

			return 1
		else
			return 0
		ok

	def IsAndYieldNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndYield)

			return 1
		else
			return 0
		ok

	def IsAndThenYieldNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndThenYield)

			return 1
		else
			return 0
		ok

	def IsThenYieldNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ThenYield)

			return 1
		else
			return 0
		ok

	#--

	def IsHarvestSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :HarvestSection)

			return 1
		else
			return 0
		ok

	def IsAndHarvestSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndHarvestSection)

			return 1
		else
			return 0
		ok

	def IsAndThenHarvestSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndThenHarvestSection)

			return 1
		else
			return 0
		ok

	def IsThenHarvestSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ThenHarvestSection)

			return 1
		else
			return 0
		ok

	def IsYieldSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :YieldSection)

			return 1
		else
			return 0
		ok

	def IsAndYieldSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndYieldSection)

			return 1
		else
			return 0
		ok

	def IsAndThenYieldSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndThenYieldSection)

			return 1
		else
			return 0
		ok

	def IsThenYieldSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ThenYieldSection)

			return 1
		else
			return 0
		ok

	#--

	def IsHarvestSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :HarvestSections)

			return 1
		else
			return 0
		ok

	def IsAndHarvestSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndHarvestSections)

			return 1
		else
			return 0
		ok

	def IsAndThenHarvestSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndThenHarvestSections)

			return 1
		else
			return 0
		ok

	def IsThenHarvestSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ThenHarvestSections)

			return 1
		else
			return 0
		ok

	def IsYieldSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :YieldSections)

			return 1
		else
			return 0
		ok

	def IsAndYieldSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndYieldSections)

			return 1
		else
			return 0
		ok

	def IsAndThenYieldSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndThenYieldSections)

			return 1
		else
			return 0
		ok

	def IsThenYieldSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ThenYieldSections)

			return 1
		else
			return 0
		ok
	#--

	def IsNCharsBeforeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :NCharsBefore)

			return 1
		else
			return 0
		ok

	def IsNCharsAfterNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :NCharsAfter)

			return 1
		else
			return 0
		ok

	#--

	def IsToNPartsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToNParts)

			return 1
		else
			return 0
		ok

	def IsToPartsOfNCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfNChars)

			return 1
		else
			return 0
		ok

	def IsToPartsOfNItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfNItems)

			return 1
		else
			return 0
		ok

	def IsToPartsOfNItemsXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfNItemsXT)

			return 1
		else
			return 0
		ok

	def IsToPartsOfNStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfNStrings)

			return 1
		else
			return 0
		ok

	def IsToPartsOfNSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfNSubStringss)

			return 1
		else
			return 0
		ok

	#==

	def IsAtWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtWhere)

			return 1
		else
			return 0
		ok

	def IsWhereOrAtWhereNamedParam()
		if This.IsWhereNamedParam() or This.IsAtWhereNamedParam()
			return 1
		else
			return 0
		ok

	def IsAtWhereOrWhereNamedParam()
		if This.IsWhereNamedParam() or This.IsAtWhereNamedParam()
			return 1
		else
			return 0
		ok

	def IsWhereOrAtWhereNamedParams()
		if This.IsWhereNamedParam() or This.IsAtWhereNamedParam()
			return 1
		else
			return 0
		ok

	def IsAtWhereOrWhereNamedParams()
		if This.IsWhereNamedParam() or This.IsAtWhereNamedParam()
			return 1
		else
			return 0
		ok

	#--

	def IsAtWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtWhereXT)

			return 1
		else
			return 0
		ok

	def IsWhereXTOrAtWhereXTNamedParam()
		if This.IsWhereXTNamedParam() or This.IsAtWhereXTNamedParam()
			return 1
		else
			return 0
		ok

	def IsAtWhereXTOrWhereXTNamedParam()
		if This.IsWhereXTNamedParam() or This.IsAtWhereXTNamedParam()
			return 1
		else
			return 0
		ok

	def IsWhereXTOrAtWhereXTNamedParams()
		if This.IsWhereXTNamedParam() or This.IsAtWhereXTNamedParam()
			return 1
		else
			return 0
		ok

	def IsAtWhereXTOrWhereXTNamedParams()
		if This.IsWhereXTNamedParam() or This.IsAtWhereXTNamedParam()
			return 1
		else
			return 0
		ok

	#==

	def IsBeforeWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeWhere)

			return 1
		else
			return 0
		ok

	def IsBeforeOrBeforeWhereNamedParam()
		if This.IsBeforeNamedParam() or This.IsBeforeWhereNamedParam()
			return 1
		else
			return 0
		ok

		def IsBeforeWhereOrBeforeNamedParam()
			return This.IsBeforeOrBeforeWhereNamedParam()

		def IsBeforeOrBeforeWhereNamedParams()
			return This.IsBeforeOrBeforeWhereNamedParam()

		def IsBeforeWhereOrBeforeNamedParams()
			return This.IsBeforeOrBeforeWhereNamedParam()

	#--

	def IsBeforeWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeWhereXT)

			return 1
		else
			return 0
		ok

	def IsBeforeOrBeforeWhereXTNamedParam()
		if This.IsBeforeNamedParam() or This.IsBeforeWhereXTNamedParam()
			return 1
		else
			return 0
		ok

		def IsBeforeWhereXTOrBeforeNamedParam()
			return This.IsBeforeOrBeforeWhereXTNamedParam()

		def IsBeforeOrBeforeWhereXTNamedParams()
			return This.IsBeforeOrBeforeWhereXTNamedParam()

		def IsBeforeWhereXTOrBeforeNamedParams()
			return This.IsBeforeOrBeforeWhereXTNamedParam()

	#==

	#==

	def IsAfterWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterWhere)

			return 1
		else
			return 0
		ok

	def IsAfterOrAfterWhereNamedParam()
		if This.IsAfterNamedParam() or This.IsAfterWhereNamedParam()
			return 1
		else
			return 0
		ok

		def IsAfterWhereOrAfterNamedParam()
			return This.IsAfterOrAfterWhereNamedParam()

		def IsAfterOrAfterWhereNamedParams()
			return This.IsAfterOrAfterWhereNamedParam()

		def IsAfterWhereOrAfterNamedParams()
			return This.IsAfterOrAfterWhereNamedParam()

	#--

	def IsAfterWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterWhereXT)

			return 1
		else
			return 0
		ok

	def IsAfterOrAfterWhereXTNamedParam()
		if This.IsAfterNamedParam() or This.IsAfterWhereXTNamedParam()
			return 1
		else
			return 0
		ok

		def IsAfterWhereXTOrAfterNamedParam()
			return This.IsAfterOrAfterWhereXTNamedParam()

		def IsAfterOrAfterWhereXTNamedParams()
			return This.IsAfterOrAfterWhereXTNamedParam()

		def IsAfterWhereXTOrAfterNamedParams()
			return This.IsAfterOrAfterWhereXTNamedParam()

	#==

	def IsToPartsOfExactlyNItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfExactlyNItems)

			return 1
		else
			return 0
		ok

	def IsToPartsOfExactlyNCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfExactlyNChars)

			return 1
		else
			return 0
		ok

	def IsToPartsOfExactlyNStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfExactlyNStrings)

			return 1
		else
			return 0
		ok

	def IsToPartsOfExactlyNSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfExactlyNSubStrings)

			return 1
		else
			return 0
		ok

	#--

	def IsToPartsOfNItemsXT()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfNItemsXT)

			return 1
		else
			return 0
		ok

	def IsToPartsOfNCharsXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfNCharsXT)

			return 1
		else
			return 0
		ok

	def IsToPartsOfNStringsXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfNStringsXT)

			return 1
		else
			return 0
		ok

	def IsToPartsOfNSubStringsXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToPartsOfNSubStringsXT)

			return 1
		else
			return 0
		ok

	#==

	def IsToItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToItem)

			return 1
		else
			return 0
		ok

	def IsToItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToItems)

			return 1
		else
			return 0
		ok

	def IsUntilItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UntilItem)

			return 1
		else
			return 0
		ok

	def IsUpToItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UpToItem)

			return 1
		else
			return 0
		ok

	#--

	def IsDownToNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :DownTo)

			return 1
		else
			return 0
		ok

	def IsDownToItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :DownToItem)

			return 1
		else
			return 0
		ok

	def IsDownToItemAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :DownToItemAt)

			return 1
		else
			return 0
		ok

	def IsDownToItemAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :DownToItemAtPosition)

			return 1
		else
			return 0
		ok

	def IsDownToCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :DownToChar)

			return 1
		else
			return 0
		ok

	def IsDownToCharAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :DownToCharAt)

			return 1
		else
			return 0
		ok

	def IsDownToCharAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :DownToCharAtPosition)

			return 1
		else
			return 0
		ok

	#--

	#TODO // Move IsToCharNamedParam() here

	def IsUntilCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UntilChar)

			return 1
		else
			return 0
		ok

	def IsUpToCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UpToChar)

			return 1
		else
			return 0
		ok

	#--

	# Move IsToSubStringNamedParam() here

	def IsUntilSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UntilSubString)

			return 1
		else
			return 0
		ok

	def IsUpToSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UpToSubString)

			return 1
		else
			return 0
		ok

	#--

	#TODO : Move IsToStringNamedParam() here

	def IsUntilStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UntilString)

			return 1
		else
			return 0
		ok

	def IsUpToStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UpToString)

			return 1
		else
			return 0
		ok

	#--

	#TODO // Move IsToNumberNamedParam() here

	def IsUntilNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UntilNumber)

			return 1
		else
			return 0
		ok

	def IsUpToNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UpToNumber)

			return 1
		else
			return 0
		ok

	#--

	#TODO // Move IsToListNamedParam() here

	def IsUntilListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UntilList)

			return 1
		else
			return 0
		ok

	def IsUpToListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UpToList)

			return 1
		else
			return 0
		ok

	#--

	#TODO : Move IsToObjectNamedParam() here

	def IsUntilObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UntilObject)

			return 1
		else
			return 0
		ok

	def IsUpToObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UpToObject)

			return 1
		else
			return 0
		ok

	#--

	def IsOneOfTheseNamedParams(pacParamNames)
		if CheckingParams()
			if NOT ( isList(pacParamNames) and @IsListOfStrings(pacParamNames) )
				StzRaise("Incorrect param type! pacParamNames must be a list of strings.")
			ok
		ok

		nLen = len(pacParamNames)
		bResult = 0

		for i = 1 to nLen
			cCode = 'bFound = This.Is' + pacParamNames[i] + 'NamedParam()'
			eval(cCode)
			if bFound
				bResult = 1
				exit
			ok
		next

		return bResult

		#< @FunctionMisspelledForm

		def IsOneTheseNamedParams(pacParamNames)
			return This.IsOneOfTheseNamedParams(pacParamNames)

		#>

	def IsRemoveAtOptionsNamedParam()
		bResult = 0

		if This.IsHashList() and

		   This.ToStzHashList().KeysQ().IsMadeOfSome([
			:RemoveNCharsBefore, :RemoveNCharsAfter,
			:RemoveThisSubStringBefore,:RemoveThisSubStringAfter,
			:RemoveThisCharBefore,:RemoveThisCharBefore,
			:RemoveThisBound, :RemoveThisBoundingSubString,
			:CaseSensitive, :CS ])
			#NOTE: I've decided to keep CS as a suffix in the function
			# name and never use it as an internal option...
			#--> more simple mental model to keep things memprable

			if This.ToStzHashList().
				KeysQRT(:stzListOfStrings).
				ContainsBothCS(:CaseSensitive, :CS, 0)

				StzRaise("Incorrect format! :CaseSensitive and :CS can not be used both in the same time")
			ok

			if This.ToStzHashList().
				KeysQRT(:stzListOfStrings).
				ContainsBothCS(:RemoveThisBound, :RemoveThisBoundingSubString, 0)

				StzRaise("Incorrect format! :RemoveThisBound and :RemoveThisBoundingSubString can not be used both in the same time")
			ok

			bOk1 = 0
			nRemoveNCharsBefore = This.Content()[ :RemoveNCharsBefore ]
			cType = ring_type(nRemoveNCharsBefore)
		   	if cType = "NUMBER" or ( cType = "STRING" and nRemoveNCharsBefore = "" )
				bOk1 = 1
			ok

			bOk2 = 0
			nRemoveNCharsAfter = This.Content()[ :RemoveNCharsAfter ]
			cType = ring_type(nRemoveNCharsAfter)
		   	if cType = "NUMBER" or ( cType = "STRING" and nRemoveNCharsAfter = "" )
				bOk2 = 1
			ok

			bOk3 = 0
			cRemoveSubStringBefore = This.Content()[ :RemoveSubStringBefore ]
			cType = ring_type(cRemoveSubStringBefore)
		   	if cType = "STRING"
				bOk3 = 1
			ok

			bOk4 = 0
			cRemoveSubStringAfter = This.Content()[ :RemoveSubStringAfter ]
			cType = ring_type(cRemoveSubStringAfter)
		   	if cType = "STRING"
				bOk4 = 1
			ok

			bOk5 = 0
			cRemoveThisBound = This.Content()[ :cRemoveThisBound ]
			cType = ring_type(cRemoveThisBound)
		   	if cType = "STRING"
				bOk5 = 1
			ok

			if bOk1 and bOk2 and bOk3 and bOk4 and bOk5
				bResult = 1
			ok
		ok

		return bResult

	def IsTextBoxedOptionsNamedParam()
		/*
		Example:

		? StzStringQ("TEXT1").BoxedXT([
			:Line = :Solid,	# or :Dashed
		
			:AllCorners = :Round # can also be :Rectangualr
			# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
		
			:Width = 17,
			:TextAdjustedTo = :Center # or :Left or :Right or :Justified,
			
			:EachChar = 0 # 1,
			:Hilighted = [ 1, 3 ] # Hilight the 1st and 3rd chars,

			:Numbered = 1
		])
		*/

		if This.IsEmpty()
			return 1
		ok

		aListOfBoxOptions = [

			:Line, :Solid, :Dashed,

			:Rounded, :Round,
			:AllCorners, :Corners,
			:Width,
			:TextAdjustedTo,
			:EachChar,
			:EachWord,

			:Hilighted, :Hilight,
			:HilightPositions, :ShowPositions,

			:Numbered, :Numbers,
			:NumberedXT, :NumberXT,

			:PositionSign, :PositionChar,
			:HilightSign, :HilightChar,

			:Sectioned
		]

		nLen = This.NumberOfItems()

		if nLen >= 1 and nLen < len(aListOfBoxOptions)

			if This.IsHashList() and
			   StzHashListQ(This.Content()).KeysQ().IsMadeOfSome(aListOfBoxOptions)

				return 1
			ok

		ok

		return 0

	def IsBoxOptionsNamedParam()

		if This.IsEmpty()
			return 1
		ok

		aListOfBoxOptions = [
			:Line,
			:AllCorners,
			:Corners,
			:Width,
			:TextAdjustedTo,
			:EachChar,

			:Casesensitive,
			:CS,

			:Numbered,
			:Spacified,

			:Shadowed,
			:ShadowChar,
			:ShadowOrientation
			
		]

		nLen = This.NumberOfItems()
		   
		if nLen >= 1 and nLen <= len(aListOfBoxOptions) and
		   This.IsHashList() and
		   StzHashListQ(This.Content()).KeysQ().IsMadeOfSome(aListOfBoxOptions)
		
			return 1

		else
			return 0
		ok

	def IsConstraintsOptionsNamedParam()
		/* EXAMPLE
		[
			:OnStzString = [
				:MustBeUppercase 	= '{ Q(@str).IsUppercase() }',
				:MustNotExceed@n@Chars 	= '{ Q(@str).NumberOfChars() <= n }',
				:MustBeginWithLetter@c@	= '{ Q(@str).BeginsWithCS(c, 0) }'
			],
		
			:OnStzNumber = [
				:MustBeStrictlyPositive = '{ @number > 0 }'
			],
		
			:OnStzList = [
				:MustBeAHashList = '{ Q(@list).IsHashList() }'
			]
		]
		*/
		
		try
			VerifyConstraints([
				:MustBeAHashList,
				:KeysMustBeOnStzTypes,
				:ValuesMustBeRingCodeInStrings
			])

			return 1

		catch
			return 0
		done

	#--

	def IsCellNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Cell)

			return 1
		else
			return 0
		ok

	def IsOfCellNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfCell)

			return 1
		else
			return 0
		ok

	def IsCellsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Cells)

			return 1
		else
			return 0
		ok

	def IsOfCellsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfCells)

			return 1
		else
			return 0
		ok

	def IsInCellNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InCell)

			return 1
		else
			return 0
		ok

	def IsInCellsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InCells)

			return 1
		else
			return 0
		ok

	def IsCellValueNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :CellValue)

			return 1
		else
			return 0
		ok

	def IsOfCellValueNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfCellValue)

			return 1
		else
			return 0
		ok

	def IsCellPartNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :CellPart)

			return 1
		else
			return 0
		ok

	def IsPartNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Part)

			return 1
		else
			return 0
		ok

	def IsSubPartNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :SubPart)

			return 1
		else
			return 0
		ok
	#--

	def IsSubValueNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :SubValue)

			return 1
		else
			return 0
		ok

	def IsOfSubValueNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfSubValue)

			return 1
		else
			return 0
		ok

	def IsSubValuesNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :SubValues)

			return 1
		else
			return 0
		ok

	def IsOfSubValuesNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfSubValues)

			return 1
		else
			return 0
		ok

	#--

	def IsOfCellPartNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfCellPart)

			return 1
		else
			return 0
		ok

	def IsOfPartNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfPart)

			return 1
		else
			return 0
		ok

	def IsOfSubPartNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfSubPart)

			return 1
		else
			return 0
		ok

	#--

	def IsColNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :Col or This.Item(1) = :Column) )

			return 1
		else
			return 0
		ok

		def IsColumnNamedParam()
			return This.IsColNamedParam()

	def IsColNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :ColNumber or This.Item(1) = :ColumnNumber) )

			return 1
		else
			return 0
		ok

		def IsColumnNumberNamedParam()
			return This.IsColNumberNamedParam()

	def IsColOrColNumberNamedParam()
		if This.IsColNumberNamedParam() or This.IsColNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsColOrColNumberNamedParams()
			return This.IsColOrColNumberNamedParam()

		def IsColNumberOrColNamedParam()
			return This.IsColOrColNumberNamedParam()

		def IsColNumberOrColNamedParams()
			return This.IsColOrColNumberNamedParam()

	#--

	def IsOfColNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :OfCol or This.Item(1) = :OfColumn) )

			return 1
		else
			return 0
		ok

		def IsOfColumnNamedParam()
			return This.IsOfColNamedParam()

	def IsOfColOrColumnNamedParam()
		if This.IsOfColNamedParam() or This.IsOfColumnNamedParam()
			return 1

		else
			return 0
		ok

		def IsOfColumnOrColNamedParam()
			return This.IsOfColOrColumnNamedParam()

		def IsOfColOrOfColumnNamedParam()
			return This.IsOfColOrColumnNamedParam()

		def IsOfColumnOrOfColNamedParam()
			return This.IsOfColOrColumnNamedParam()

		#--

		def IsOfColOrColumnNamedParams()
			return This.IsOfColOrColumnNamedParam()

		def IsOfColumnOrColNamedParams()
			return This.IsOfColOrColumnNamedParam()

		def IsOfColOrOfColumnNamedParams()
			return This.IsOfColOrColumnNamedParam()

		def IsOfColumnOrOfColNamedParams()
			return This.IsOfColOrColumnNamedParam()

	#--

	def IsInColNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :InCol or This.Item(1) = :InColumn) )

			return 1
		else
			return 0
		ok

		def IsInColumnNamedParam()
			return This.IsInColNamedParam()

	def IsInColOrColumnNamedParam()
		if This.IsInColNamedParam() or This.IsInColumnNamedParam()
			return 1

		else
			return 0
		ok

		def IsInColumnOrColNamedParam()
			return This.IsInColOrColumnNamedParam()

		def IsInColOrInColumnNamedParam()
			return This.IsInColOrColumnNamedParam()

		def IsInColumnOrInColNamedParam()
			return This.IsInColOrColumnNamedParam()

		#--

		def IsInColOrColumnNamedParams()
			return This.IsInColOrColumnNamedParam()

		def IsInColumnOrColNamedParams()
			return This.IsInColOrColumnNamedParams()

		def IsInColOrInColumnNamedParams()
			return This.IsInColOrColumnNamedParams()

		def IsInColumnOrInColNamedParams()
			return This.IsInColOrColumnNamedParam()

	#--

	def IsColsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :Cols or This.Item(1) = :Columns) )

			return 1
		else
			return 0
		ok

		def IsColumnsNamedParam()
			return This.IsColsNamedParam()

	def IsColsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :ColsNumbers or This.Item(1) = :ColumnsNumbers) )

			return 1
		else
			return 0
		ok

		def IsColumnsNumbersNamedParam()
			return This.IsColsNumbersNamedParam()

	def IsColsOrColsNumberNamedParam()
		if This.IsColsNumbersNamedParam() or This.IsColsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsColsNumbersOrColsNamedParam()
			return This.IsColsOrColsNumberNamedParam()

		def IsColsOrColsNumberNamedParams()
			return This.IsColsOrColsNumberNamedParam()

		def IsColsNumbersOrColsNamedParams()
			return This.IsColsOrColsNumberNamedParam()

	#--

	def IsOfColsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :OfCols or This.Item(1) = :OfColumns) )

			return 1
		else
			return 0
		ok

		def IsOfColumnsNamedParam()
			return This.IsOfColsNamedParam()

	def IsOfColsOrColumnsNamedParam()
		if This.IsOfColsNamedParam() or This.IsOfColumnsNamedParam()
			return 1

		else
			return 0
		ok

		def IsOfColumnsOrColsNamedParam()
			return This.IsOfColsOrColumnsNamedParam()

		def IsOfColsOrOfColumnsNamedParam()
			return This.IsOfColsOrColumnsNamedParam()

		def IsOfColumnsOrOfColsNamedParam()
			return This.IsOfColsOrColumnsNamedParam()

		#--

		def IsOfColsOrColumnsNamedParams()
			return This.IsOfColsOrColumnsNamedParam()

		def IsOfColumnsOrColsNamedParams()
			return This.IsOfColsOrColumnsNamedParam()

		def IsOfColsOrOfColumnsNamedParams()
			return This.IsOfColsOrColumnsNamedParam()

		def IsOfColumnsOrOfColsNamedParams()
			return This.IsOfColsOrColumnsNamedParam()

	#--

	def IsInColsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :InCols or This.Item(1) = :InColumns) )

			return 1
		else
			return 0
		ok

		def IsInColumnsNamedParam()
			return This.IsInColsNamedParam()

	def IsInColsOrColumnsNamedParam()
		if This.IsInColsNamedParam() or This.IsInColumnsNamedParam()
			return 1

		else
			return 0
		ok

		def IsInColumnsOrColNamedParam()
			return This.IsInColsOrColumnsNamedParam()

		def IsInColsOrInColumnsNamedParam()
			return This.IsInColsOrColumnsNamedParam()

		def IsInColumnsOrInColNamedParam()
			return This.IsInColsOrColumnsNamedParam()

		#--

		def IsInColsOrColumnsNamedParams()
			return This.IsInColsOrColumnsNamedParam()

		def IsInColumnsOrColNamedParams()
			return This.IsInColsOrColumnsNamedParam()

		def IsInColsOrInColumnsNamedParams()
			return This.IsInColsOrColumnsNamedParam()

		def IsInColumnsOrInColNamedParams()
			return This.IsInColsOrColumnsNamedParam()

	#==

	def IsByColNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :ByColNumber or This.Item(1) = :ByColumnNumber) )

			return 1
		else
			return 0
		ok

		def IsByColumnNumberNamedParam()
			return This.IsByColNumberNamedParam()

	def IsByColOrByColNumberNamedParam()
		if This.IsByColNumberNamedParam() or This.IsByColNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsByColOrByColNumberNamedParams()
			return This.IsByColOrByColNumberNamedParam()

		def IsByColNumberOrByColNamedParam()
			return This.IsByColOrByColNumberNamedParam()

		def IsByColNumberOrColNamedParams()
			return This.IsByColOrByColNumberNamedParam()

	def IsByColsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :ByColsNumbers or This.Item(1) = :ByColumnsNumbers) )

			return 1
		else
			return 0
		ok

		def IsByColumnsNumbersNamedParam()
			return This.IsByColsNumbersNamedParam()

	def IsByColsOrByColsNumbersNamedParam()
		if This.IsByColsNumbersNamedParam() or This.IsByColsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsByColsOrByColsNumbersNamedParams()
			return This.IsByColsOrByColsNumbersNamedParam()

		def IsByColsNumbersOrByColsNamedParam()
			return This.IsByColsOrByColsNumbersNamedParam()

		def IsByColsNumbersOrColsNamedParams()
			return This.IsByColsOrColsNumberNamedParam()

	#--

	def IsInColNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :InColNumber or This.Item(1) = :InColumnNumber) )

			return 1
		else
			return 0
		ok

		def IsInColumnNumberNamedParam()
			return This.IsInColNumberNamedParam()

	def IsInColOrInColNumberNamedParam()
		if This.IsInColNumberNamedParam() or This.IsInColNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsInColOrInColNumberNamedParams()
			return This.IsInColOrInColNumberNamedParam()

		def IsInColNumberOrInColNamedParam()
			return This.IsInColOrInColNumberNamedParam()

		def IsInColInNumberOrColNamedParams()
			return This.IsInColOrInColNumberNamedParam()

	def IsInColsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :InColsNumbers or This.Item(1) = :InColumnsNumbers) )

			return 1
		else
			return 0
		ok

		def IsInColumnsNumbersNamedParam()
			return This.IsInColsNumbersNamedParam()

	def IsInColsOrInColsNumbersNamedParam()
		if This.IsInColsNumbersNamedParam() or This.IsInColsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsInColsOrInColsNumbersNamedParams()
			return This.IsInColsOrInColsNumbersNamedParam()

		def IsInColsNumbersOrInColsNamedParam()
			return This.IsInColsOrinColsNumbersNamedParam()

		def IsInColsNumbersOrInColsNamedParams()
			return This.IsInColsOrInColsNumberNamedParam()

	#--

	def IsOfColNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :OfColNumber or This.Item(1) = :OfColumnNumber) )

			return 1
		else
			return 0
		ok

		def IsOfColumnNumberNamedParam()
			return This.IsOfColNumberNamedParam()

	def IsOfColOrOfColNumberNamedParam()
		if This.IsOfColNumberNamedParam() or This.IsOfColNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfColOrOfColNumberNamedParams()
			return This.IsOfColOrOfColNumberNamedParam()

		def IsOfColNumberOrOfColNamedParam()
			return This.IsOfColOrOfColNumberNamedParam()

		def IsOfColNumberOrOfColNamedParams()
			return This.IsOfColOrOfColNumberNamedParam()

	def IsOfColsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :OfColsNumbers or This.Item(1) = :OfColumnsNumbers) )

			return 1
		else
			return 0
		ok

		def IsOfColumnsNumbersNamedParam()
			return This.IsOfColsNumbersNamedParam()

	def IsOfColsOrOfColsNumbersNamedParam()
		if This.IsOfColsNumbersNamedParam() or This.IsOfColsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfColsOrOfColsNumbersNamedParams()
			return This.IsOfColsOrOFColsNumbersNamedParam()

		def IsOfColsNumbersOrOfColsNamedParam()
			return This.IsOfColsOrOfColsNumbersNamedParam()

		def IsOfColsNumbersOrOfColsNamedParams()
			return This.IsOfColsOrOfColsNumberNamedParam()

	#--

	def IsToColNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :ToColNumber or This.Item(1) = :ToColumnNumber) )

			return 1
		else
			return 0
		ok

		def IsToColumnNumberNamedParam()
			return This.IsToColNumberNamedParam()

	def IsToColOrToColNumberNamedParam()
		if This.IsToColNumberNamedParam() or This.IsToColNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsToColOrToColNumberNamedParams()
			return This.IsToColOrToColNumberNamedParam()

		def IsToColNumberOrToColNamedParam()
			return This.IsToColOrToColNumberNamedParam()

		def IsToColNumberOrToColNamedParams()
			return This.IsToColOrToColNumberNamedParam()

	def IsToColsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :ToColsNumbers or This.Item(1) = :ToColumnsNumbers) )

			return 1
		else
			return 0
		ok

		def IsToColumnsNumbersNamedParam()
			return This.IsToColsNumbersNamedParam()

	def IsToColsOrToColsNumbersNamedParam()
		if This.IsToColsNumbersNamedParam() or This.IsToColsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsToColsOrToColsNumbersNamedParams()
			return This.IsToColsOrToColsNumbersNamedParam()

		def IsToColsNumbersOrToColsNamedParam()
			return This.IsToColsOrToColsNumbersNamedParam()

		def IsToColsNumbersOrtoColsNamedParams()
			return This.IsToColsOrToColsNumberNamedParam()

	#--

	def IsUsingColNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :UsingColNumber or This.Item(1) = :UsingColumnNumber) )

			return 1
		else
			return 0
		ok

		def IsUsingColumnNumberNamedParam()
			return This.IsUsingColNumberNamedParam()

	def IsUsingColOrUsingColNumberNamedParam()
		if This.IsUsingColNumberNamedParam() or This.IsUsingColNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsUsingColOrUsingColNumberNamedParams()
			return This.IsUsingColOrUsingColNumberNamedParam()

		def IsUsingColNumberOrUsingColNamedParam()
			return This.IsUsingColOrUsingColNumberNamedParam()

		def IsUsingColNumberOrUsingColNamedParams()
			return This.IsUsingColOrUsingColNumberNamedParam()

	def IsUsingColsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :UsingColsNumbers or This.Item(1) = :UsingColumnsNumbers) )

			return 1
		else
			return 0
		ok

		def IsUsingColumnsNumbersNamedParam()
			return This.IsUsingColsNumbersNamedParam()

	def IsUsingColsOrUsingColsNumbersNamedParam()
		if This.IsUsingColsNumbersNamedParam() or This.IsUsingColsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsUsingColsOrUsingColsNumbersNamedParams()
			return This.IsUsingColsOrUsingColsNumbersNamedParam()

		def IsUsingColsNumbersOrUsingColsNamedParam()
			return This.IsUsingColsOrUsingColsNumbersNamedParam()

		def IsUsingColsNumbersOrUsingColsNamedParams()
			return This.IsUsingColsOrUsingColsNumberNamedParam()

	#--

	def IsWithColNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :WithColNumber or This.Item(1) = :WithColumnNumber) )

			return 1
		else
			return 0
		ok

		def IsWithColumnNumberNamedParam()
			return This.IsWithColNumberNamedParam()

	def IsWithColOrWithColNumberNamedParam()
		if This.IsWithColNumberNamedParam() or This.IsWithColNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithColOrWithColNumberNamedParams()
			return This.IsWithColOrWithColNumberNamedParam()

		def IsWithColNumberOrWithColNamedParam()
			return This.IsWithColOrWithColNumberNamedParam()

		def IsWithColNumberOrWithColNamedParams()
			return This.IsWithColOrWithColNumberNamedParam()

	def IsWithColsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :WithColsNumbers or This.Item(1) = :WithColumnsNumbers) )

			return 1
		else
			return 0
		ok

		def IsWithColumnsNumbersNamedParam()
			return This.IsWithColsNumbersNamedParam()

	def IsWithColsOrWithColsNumbersNamedParam()
		if This.IsWithColsNumbersNamedParam() or This.IsWithColsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithColsOrWithColsNumbersNamedParams()
			return This.IsWithColsOrWithColsNumbersNamedParam()

		def IsWithColsNumbersOrWithColsNamedParam()
			return This.IsWithColsOrWithColsNumbersNamedParam()

		def IsWithColsNumbersOrWithColsNamedParams()
			return This.IsWithColsOrColsNumberNamedParam()

	#==

	def IsByRowNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ByRowNumber )

			return 1
		else
			return 0
		ok


	def IsByRowOrByRowNumberNamedParam()
		if This.IsByRowNumberNamedParam() or This.IsByRowNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsByRowOrByRowNumberNamedParams()
			return This.IsByRowOrByRowNumberNamedParam()

		def IsByRowNumberOrByRowNamedParam()
			return This.IsByRowOrByRowNumberNamedParam()

		def IsByRowNumberOrByRowNamedParams()
			return This.IsByRowOrByRowNumberNamedParam()

	def IsByRowsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ByRowsNumbers )

			return 1
		else
			return 0
		ok

	def IsByRowsOrByRowsNumbersNamedParam()
		if This.IsByRowsNumbersNamedParam() or This.IsByRowsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsByRowsOrByRowsNumbersNamedParams()
			return This.IsByRowsOrByRowsNumbersNamedParam()

		def IsByRowsNumbersOrByRowsNamedParam()
			return This.IsByRowsOrByRowsNumbersNamedParam()

		def IsByRowsNumbersOrByRowsNamedParams()
			return This.IsByRowsOrByRowsNumberNamedParam()

	#--

	def IsInRowNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InRowNumber )

			return 1
		else
			return 0
		ok

	def IsInRowOrInRowNumberNamedParam()
		if This.IsInRowNumberNamedParam() or This.IsInRowNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsInRowOrInRowNumberNamedParams()
			return This.IsInRowOrInRowNumberNamedParam()

		def IsInRowNumberOrInRowNamedParam()
			return This.IsInRowOrInRowNumberNamedParam()

		def IsInRowNumberOrInRowNamedParams()
			return This.IsInRowOrInRowNumberNamedParam()

	def IsInRowsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InRowsNumbers )

			return 1
		else
			return 0
		ok

	def IsInRowsOrInRowsNumbersNamedParam()
		if This.IsInRowsNumbersNamedParam() or This.IsInRowsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsInRowsOrInRowsNumbersNamedParams()
			return This.IsInRowsOrInRowsNumbersNamedParam()

		def IsInRowsNumbersOrInRowsNamedParam()
			return This.IsInRowsOrInRowsNumbersNamedParam()

		def IsInRowsNumbersOrInRowsNamedParams()
			return This.IsInRowsOrInRowsNumberNamedParam()

	#--

	def IsOfRowNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfRowNumber )

			return 1
		else
			return 0
		ok

	def IsOfRowOrOfRowNumberNamedParam()
		if This.IsOfRowNumberNamedParam() or This.IsOfRowNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfRowOrOfRowNumberNamedParams()
			return This.IsOfRowOrOfRowNumberNamedParam()

		def IsOfRowNumberOrOfRowNamedParam()
			return This.IsOfRowOrOfRowNumberNamedParam()

		def IsOfRowNumberOrOfRowNamedParams()
			return This.IsOfRowOrOfRowNumberNamedParam()

	def IsOfRowsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfRowsNumbers )

			return 1
		else
			return 0
		ok

	def IsOfRowsOrOfRowsNumbersNamedParam()
		if This.IsOfRowsNumbersNamedParam() or This.IsOfRowsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfRowsOrOfRowsNumbersNamedParams()
			return This.IsOfRowsOrOfRowsNumbersNamedParam()

		def IsOfRowsNumbersOrOfRowsNamedParam()
			return This.IsOfRowsOrOfRowsNumbersNamedParam()

		def IsOfRowsNumbersOrOfRowsNamedParams()
			return This.IsOfRowsOrOfRowsNumberNamedParam()

	#--

	def IsToRowNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToRowNumber )

			return 1
		else
			return 0
		ok

	def IsToRowOrToRowNumberNamedParam()
		if This.IsToRowNumberNamedParam() or This.IsToRowNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsToRowOrToRowNumberNamedParams()
			return This.IsToRowOrToRowNumberNamedParam()

		def IsToRowNumberOrToRowNamedParam()
			return This.IsToRowOrToRowNumberNamedParam()

		def IsToRowNumberOrToRowNamedParams()
			return This.IsToRowOrToRowNumberNamedParam()

	def IsToRowsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToRowsNumbers )

			return 1
		else
			return 0
		ok

	def IsToRowsOrToRowsNumbersNamedParam()
		if This.IsToRowsNumbersNamedParam() or This.IsToRowsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsToRowsOrToRowsNumbersNamedParams()
			return This.IsToRowsOrToRowsNumbersNamedParam()

		def IsToRowsNumbersOrToRowsNamedParam()
			return This.IsToRowsOrToRowsNumbersNamedParam()

		def IsToRowsNumbersOrToRowsNamedParams()
			return This.IsToRowsOrToRowsNumberNamedParam()

	#--

	def IsUsingRowNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingRowNumber )

			return 1
		else
			return 0
		ok

	def IsUsingRowOrUsingRowNumberNamedParam()
		if This.IsUsingRowNumberNamedParam() or This.IsUsingRowNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsUsingRowOrUsingRowNumberNamedParams()
			return This.IsUsingRowOrUsingRowNumberNamedParam()

		def IsUsingRowNumberOrUsingRowNamedParam()
			return This.IsUsingRowOrUsingRowNumberNamedParam()

		def IsUsingRowNumberOrUsingRowNamedParams()
			return This.IsUsingRowOrUsingRowNumberNamedParam()

	def IsUsingRowsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingRowsNumbers )

			return 1
		else
			return 0
		ok

	def IsUsingRowsOrUsingRowsNumbersNamedParam()
		if This.IsUsingRowsNumbersNamedParam() or This.IsUsingRowsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsUsingRowsOrUsingRowsNumbersNamedParams()
			return This.IsUsingRowsOrUsingRowsNumbersNamedParam()

		def IsUsingRowsNumbersOrUsingRowsNamedParam()
			return This.IsUsingRowsOrUsingRowsNumbersNamedParam()

		def IsUsingRowsNumbersOrUsingRowsNamedParams()
			return This.IsUsingRowsOrUsingRowsNumberNamedParam()

	#--

	def IsWithRowNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :WithRowNumber )

			return 1
		else
			return 0
		ok

	def IsWithRowOrWithRowNumberNamedParam()
		if This.IsWithRowNumberNamedParam() or This.IsWithRowNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithRowOrWithRowNumberNamedParams()
			return This.IsWithRowOrWithRowNumberNamedParam()

		def IsWithRowNumberOrWithRowNamedParam()
			return This.IsWithRowOrWithRowNumberNamedParam()

		def IsWithRowNumberOrWithRowNamedParams()
			return This.IsWithRowOrWithRowNumberNamedParam()

	def IsWithRowsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :WithRowsNumbers )

			return 1
		else
			return 0
		ok

	def IsWithRowsOrWithRowsNumbersNamedParam()
		if This.IsWithRowsNumbersNamedParam() or This.IsWithRowsNumbersNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithRowsOrWithRowsNumbersNamedParams()
			return This.IsWithRowsOrWithRowsNumbersNamedParam()

		def IsWithRowsNumbersOrWithRowsNamedParam()
			return This.IsWithRowsOrWithRowsNumbersNamedParam()

		def IsWithRowsNumbersOrWithRowsNamedParams()
			return This.IsWithRowsOrWithRowsNumberNamedParam()

	#==

	def IsRowNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Row)

			return 1
		else
			return 0
		ok

	def IsOfRowNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfRow)

			return 1
		else
			return 0
		ok

	def IsInRowNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InRow)

			return 1
		else
			return 0
		ok

	def IsRowsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Rows)

			return 1
		else
			return 0
		ok

	def IsOfRowsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfRows)

			return 1
		else
			return 0
		ok

	def IsInRowsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InRows)

			return 1
		else
			return 0
		ok

	#--

	def IsOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Occurrence)

			return 1
		else
			return 0
		ok

	def IsNthNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Nth)

			return 1
		else
			return 0
		ok

	def IsNthOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :NthOccurrence)

			return 1
		else
			return 0
		ok

	def IsNNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :N)

			return 1
		else
			return 0
		ok
	#--

	def IsCaseSensitiveNamedParam()
		aContent = This.Content()
		nLen = len(aContent)

		if NOT nLen = 2
			return 0
		ok

		if NOT isString(aContent[1])
			return 0
		ok

		if NOT isNumber(aContent[2])
			return 0
		ok

		if NOT ( aContent[1] = :CaseSensitive or aContent[1] = :CS )
			return 0
		ok

		if NOT ( aContent[2] = 0 or aContent[2] = 1 )
			return 0
		ok

		return 1

	def IsRangeNamedParam() #TODO// Review this, seems more complex then necessary!

		if This.IsEmpty()
			return 1
		ok

		if NOT (This.IsHashList() and This.NumberOfItems() <= 2)
			return 0
		ok

		if This.NumberOfItems() = 1

			if This.Item(1)[1] = :Start or This.Item(1)[1] = :Range
				return 1
			ok
		ok

		if This.NumberOfItems() = 2

			if StzHashListQ( This.List() ).KeysQ().IsEqualTo([ :Start, :Range ]) and
			   StzHashListQ( This.List() ).ValuesQ().BothAreNumbers()

				return 1

			else

				return 0
			ok
		ok

	def IsInRangeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InRange )

			return 1

		else
			return 0
		ok

	#--

	def IsStartingAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StartingAt )

			return 1

		else
			return 0
		ok

	def IsStartingAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StartingAtPosition )

			return 1

		else
			return 0
		ok

	def IsStartingAtOrStartingAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :StartingAtPosition or
			 This.Item(1) = :StartingAt) )

			return 1

		else
			return 0
		ok

		def IsStartingAtPositionOrStartingAtNamedParam()
			return This.IsStartingAtOrStartingAtPositionNamedParam()

	def IsStartingAtOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StartingAtOccurrence )

			return 1

		else
			return 0
		ok

	def IsStartAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StartAt )

			return 1

		else
			return 0
		ok

	def IsStartsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StartAts )

			return 1

		else
			return 0
		ok

	def IsStartAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StartAtPosition )

			return 1

		else
			return 0
		ok

	def IsStartsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StartsAtPosition )

			return 1

		else
			return 0
		ok

	def IsStartAtOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StartAtOccurrence )

			return 1

		else
			return 0
		ok

	def IsStartsAtOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StartsAtOccurrence )

			return 1

		else
			return 0
		ok

	#--

	def IsEndAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndAt )

			return 1

		else
			return 0
		ok

	def IsEndsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndsAt )

			return 1

		else
			return 0
		ok

	def IsEndingAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndingAt )

			return 1

		else
			return 0
		ok

	def IsEndAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndAtPosition )

			return 1

		else
			return 0
		ok



	def IsEndsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndsAtPosition )

			return 1

		else
			return 0
		ok

	def IsEndingAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndingAtPosition )

			return 1

		else
			return 0
		ok

	def IsEndingAtOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndingAtOccurrence )

			return 1

		else
			return 0
		ok

	def IsStopAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StopAt )

			return 1

		else
			return 0
		ok

	def IsStopsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StopsAt )

			return 1

		else
			return 0
		ok

	def IsStopAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StopAt )

			return 1

		else
			return 0
		ok

	def IsStopsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StopsAt )

			return 1

		else
			return 0
		ok

	def IsEndiingAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndingAt )

			return 1

		else
			return 0
		ok

	def IsStoppingAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StoppingAtPosition )

			return 1

		else
			return 0
		ok

	#--

	def IsStoppingAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StoppingAt )

			return 1

		else
			return 0
		ok

	def IsStoppingAtOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StoppingAtOccurrence )

			return 1

		else
			return 0
		ok

	def IsStopAtOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StopAtOccurrence )

			return 1

		else
			return 0
		ok

	def IsStopsAtOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StopsAtOccurrence )

			return 1

		else
			return 0
		ok

	def IsendAtOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndAtOccurrence )

			return 1

		else
			return 0
		ok

	def IsendsAtOccurrenceNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EndsAtOccurrence )

			return 1

		else
			return 0
		ok

	#--

	def IsInStringNNamedParam()
		if This.NumberOfItems() = 2 and

		   ( isString(This.Item(1)) and
		     StzFind([
			:InStringAt,
			:inStringAtPosition,
			:InStringN ], This.Item(1)) > 0 )

			return 1

		else
			return 0
		ok

		def IsInStringAtPositionNNamedParam()
			return This.IsInStringNNamedParam()

		def IsInStringAtPositionNamedParam()
			return This.IsInStringNNamedParam()

	def IsExceptNamedParam()
		# Used initially by ReplaceWordsWithMarquersExceptXT(pcByOption, paExcept)
		#TODO // generalize to all the functions we want to provide exceptions to it

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Except )

			return 1

		else
			return 0
		ok

	def IsAsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :As )

			return 1

		else
			return 0
		ok

	def IsThenNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  (This.Item(1) = :Then or This.Item(1) = :Then@) )

			return 1

		else
			return 0
		ok

	def IsAndThenNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  (This.Item(1) = :AndThen or This.Item(1) = :AndThen@) )

			return 1

		else
			return 0
		ok

	def IsFromNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  (This.Item(1) = :From or This.Item(1) = :FromPosition)  )

			return 1

		else
			return 0
		ok

	def IsFromOrOfNamedParam()
		if This.IsFromNamedParam() or This.IsOfNamedParam()
			return 1
		else
			return 0
		ok

		def IsFromOrOfNamedParams()
			return This.IsFromOrOfNamedParam()

		def IsOfOrFromNamedParam()
			return This.IsFromOrOfNamedParam()

		def IsOfOrFromNamedParams()
			return This.IsFromOrOfNamedParam()

	#--

	def IsFromCellNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCell )

			return 1

		else
			return 0
		ok

	def IsFromCellAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCellAt )

			return 1

		else
			return 0
		ok

	def IsFromCellAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCellAtPosition )

			return 1

		else
			return 0
		ok

	def IsFromCellsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCells )

			return 1

		else
			return 0
		ok

	def IsFromCellsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCellsAt )

			return 1

		else
			return 0
		ok

	def IsFromCellsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCellsAtPositions )

			return 1

		else
			return 0
		ok

	#--

	def IsToCellNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCell )

			return 1

		else
			return 0
		ok

	def IsToCellAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCellAt )

			return 1

		else
			return 0
		ok

	def IsToCellAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCellAtPosition )

			return 1

		else
			return 0
		ok

	def IsToCellsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCells )

			return 1

		else
			return 0
		ok

	def IsToCellsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCellsAt )

			return 1

		else
			return 0
		ok

	def IsToCellsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCellsAtPositions )

			return 1

		else
			return 0
		ok

	#--

	def IsValueNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Value )

			return 1

		else
			return 0
		ok

	def IsOfValueNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfValue )

			return 1

		else
			return 0
		ok

	def IsValuesNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Values )

			return 1

		else
			return 0
		ok

	def IsStringOrSubStringNamedParam()
		if This.IsStringNamedPAram() or This.IsSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsStringOrSubStringNamedParams()
			return This.IsStringOrSubStringNamedParam()

		def IsSubStringOrStringONamedParam()
			return This.IsStringOrSubStringNamedParam()

		def IsSubStringOrStringONamedParams()
			return This.IsStringOrSubStringNamedParam()

	#--

	def IsToOrOfNamedParam()
		if This.IsToNamedParam() or This.IsOfNamedParam()
			return 1

		else
			return 0
		ok

		def IsToOrOfNamedParams()
			return This.IsToOrOfNamedParam()

		def IsOfOrToNamedParam()
			return This.IsToOrOfNamedParam()

		def IsOfOrToNamedParams()
			return This.IsToOrOfNamedParam()

	#==

	def IsToNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToNumber )

			return 1

		else
			return 0
		ok

	def IsToNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToNumbers )

			return 1

		else
			return 0
		ok

	def IsToStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToString )

			return 1

		else
			return 0
		ok

	def IsToSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToSubString )

			return 1

		else
			return 0
		ok

	def IsToSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToSubStrings )

			return 1

		else
			return 0
		ok

	def IsToCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToChar )

			return 1

		else
			return 0
		ok

	def IsToListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToList )

			return 1

		else
			return 0
		ok

	def IsToListsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToLists )

			return 1

		else
			return 0
		ok

	def IsToPairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToPair )

			return 1

		else
			return 0
		ok

	def IsToHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToHashList )

			return 1

		else
			return 0
		ok

	def IsToSetNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToSet )

			return 1

		else
			return 0
		ok

	def IsToObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToObject )

			return 1

		else
			return 0
		ok

	def IsToObjectsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToObjects )

			return 1

		else
			return 0
		ok

	#--

	def IsToOrToNumberNamedParam()
		if This.IsToNamedParam() or This.IsToNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsToNumberOrToNamedParam()
			return This.IsToOrToNumberNamedParam()

		def IsToOrToNumberNamedParams()
			return This.IsToOrToNumberNamedParam()

		def IsToNumberOrToNamedParams()
			return This.IsToOrToNumberNamedParam()

	def IsToOrToCharNamedParam()
		if This.IsToNamedParam() or This.IsToCharNamedParam()
			return 1
		else
			return 0
		ok

		def IsToCharOrToNamedParam()
			return This.IsToOrToCharNamedParam()

		def IsToOrToCharNamedParams()
			return This.IsToOrToCharNamedParam()

		def IsToCharOrToNamedParams()
			return This.IsToOrToCharNamedParam()

	def IsToOrToStringNamedParam()
		if This.IsToNamedParam() or This.IsToStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsToStringOrToNamedParam()
			return This.IsToOrToStringNamedParam()

		def IsToOrToStringNamedParams()
			return This.IsToOrToStringNamedParam()

		def IsToStringOrToNamedParams()
			return This.IsToOrToStringNamedParam()

	def IsToOrToSubStringNamedParam()
		if This.IsToNamedParam() or This.IsToSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsToSubStringOrToNamedParam()
			return This.IsToOrToSubStringNamedParam()

		def IsToOrToSubStringNamedParams()
			return This.IsToOrToSubStringNamedParam()

		def IsToSubStringOrToNamedParams()
			return This.IsToOrToSubStringNamedParam()

	def IsToOrToListNamedParam()
		if This.IsToNamedParam() or This.IsToListNamedParam()
			return 1
		else
			return 0
		ok

		def IsToListOrToNamedParam()
			return This.IsToOrToListNamedParam()

		def IsToOrToListNamedParams()
			return This.IsToOrToListNamedParam()

		def IsToListOrToNamedParams()
			return This.IsToOrToListNamedParam()

	def IsToOrToHashListNamedParam()
		if This.IsToNamedParam() or This.IsToHashListNamedParam()
			return 1
		else
			return 0
		ok

		def IsToHashListOrToNamedParam()
			return This.IsToOrToHashListNamedParam()

		def IsToOrToHashListNamedParams()
			return This.IsToOrToHashListNamedParam()

		def IsToHashListOrToNamedParams()
			return This.IsToOrToHashListNamedParam()

	def IsToOrToPairNamedParam()
		if This.IsToNamedParam() or This.IsToPairNamedParam()
			return 1
		else
			return 0
		ok

		def IsToPairOrToNamedParam()
			return This.IsToOrToPairNamedParam()

		def IsToOrToPairNamedParams()
			return This.IsToOrToPairNamedParam()

		def IsToPairOrToNamedParams()
			return This.IsToOrToPairNamedParam()

	def IsToOrToSetNamedParam()
		if This.IsToNamedParam() or This.IsToSetNamedParam()
			return 1
		else
			return 0
		ok

		def IsToSetOrToNamedParam()
			return This.IsToOrToSetNamedParam()

		def IsToOrToSetNamedParams()
			return This.IsToOrToSetNamedParam()

		def IsToSetOrToNamedParams()
			return This.IsToOrToSetNamedParam()

	def IsToOrToObjectNamedParam()
		if This.IsToNamedParam() or This.IsToObjectNamedParam()
			return 1
		else
			return 0
		ok

		def IsToStringOrToObjectParam()
			return This.IsToOrToStringNamedParam()

		def IsToOrToObjectNamedParams()
			return This.IsToOrToObjectNamedParam()

		def IsToStringOrToObjectParams()
			return This.IsToOrToStringNamedParam()

	#==

	def IsOfNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfNumber )

			return 1

		else
			return 0
		ok

	def IsOfStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfString )

			return 1

		else
			return 0
		ok

	def IsOfSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfSubString )

			return 1

		else
			return 0
		ok

	def IsOfCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfChar )

			return 1

		else
			return 0
		ok

	def IsOfListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfList )

			return 1

		else
			return 0
		ok

	def IsOfPairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfPair )

			return 1

		else
			return 0
		ok

	def IsOfHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfHashList )

			return 1

		else
			return 0
		ok

	def IsOfSetNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfSet )

			return 1

		else
			return 0
		ok

	def IsOfObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfObject )

			return 1

		else
			return 0
		ok

	#--

	def IsOfOrOfNumberNamedParam()
		if This.IsOfNamedParam() or This.IsOfNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfNumberOrOfNamedParam()
			return This.IsOfOrOfNumberNamedParam()

		def IsOfOrOfNumberNamedParams()
			return This.IsOfOrOfNumberNamedParam()

		def IsOfNumberOrOfNamedParams()
			return This.IsOfOrOfNumberNamedParam()

	def IsOfOrOfCharNamedParam()
		if This.IsOfNamedParam() or This.IsOfCharNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfCharOrOfNamedParam()
			return This.IsOfOrOfCharNamedParam()

		def IsOfOrOfCharNamedParams()
			return This.IsOfOrOfCharNamedParam()

		def IsOfCharOrOfNamedParams()
			return This.IsOfOrOfCharNamedParam()

	def IsOfOrOfStringNamedParam()
		if This.IsOfNamedParam() or This.IsOfStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfStringOrOfNamedParam()
			return This.IsOfOrOfStringNamedParam()

		def IsOfOrOfStringNamedParams()
			return This.IsOfOrOfStringNamedParam()

		def IsOfStringOrOfNamedParams()
			return This.IsOfOrOfStringNamedParam()

	def IsOfOrOfSubStringNamedParam()
		if This.IsOfNamedParam() or This.IsOfSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfSubStringOrOfNamedParam()
			return This.IsOfOrOfSubStringNamedParam()

		def IsOfOrOfSubStringNamedParams()
			return This.IsOfOrOfSubStringNamedParam()

		def IsOfSubStringOrOfNamedParams()
			return This.IsOfOrOfSubStringNamedParam()

	def IsOfOrOfListNamedParam()
		if This.IsOfNamedParam() or This.IsOfListNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfListOrOfNamedParam()
			return This.IsOfOrOfListNamedParam()

		def IsOfOrOfListNamedParams()
			return This.IsOfOrOfListNamedParam()

		def IsOfListOrOfNamedParams()
			return This.IsOfOrOfListNamedParam()

	def IsOfOrOfHashListNamedParam()
		if This.IsOfNamedParam() or This.IsOfHashListNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfHashListOrOfNamedParam()
			return This.IsOfOrOfHashListNamedParam()

		def IsOfOrOfHashListNamedParams()
			return This.IsOfOrOfHashListNamedParam()

		def IsOfHashListOrOfNamedParams()
			return This.IsOfOrOfHashListNamedParam()

	def IsOfOrOfPairNamedParam()
		if This.IsOfNamedParam() or This.IsOfPairNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfPairOrOfNamedParam()
			return This.IsOfOrOfPairNamedParam()

		def IsOfOrOfPairNamedParams()
			return This.IsOfOrOfPairNamedParam()

		def IsOfPairOrOfNamedParams()
			return This.IsOfOrOfPairNamedParam()

	def IsOfOrOfSetNamedParam()
		if This.IsOfNamedParam() or This.IsOfSetNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfSetOrOfNamedParam()
			return This.IsOfOrOfSetNamedParam()

		def IsOfOrOfSetNamedParams()
			return This.IsOfOrOfSetNamedParam()

		def IsOfSetOrOfNamedParams()
			return This.IsOfOrOfSetNamedParam()

	def IsOfOrOfObjectNamedParam()
		if This.IsOfNamedParam() or This.IsOfObjectNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfStringOrOfObjectParam()
			return This.IsOfOrOfStringNamedParam()

		def IsOfOrOfObjectNamedParams()
			return This.IsOfOrOfObjectNamedParam()

		def IsOfStringOrOfObjectParams()
			return This.IsOfOrOfStringNamedParam()

	#==

	def IsByNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ByNumber )

			return 1

		else
			return 0
		ok

	def IsByStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ByString )

			return 1

		else
			return 0
		ok

	def IsBySubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BySubString )

			return 1

		else
			return 0
		ok

	def IsByCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ByChar )

			return 1

		else
			return 0
		ok

	def IsByListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ByList )

			return 1

		else
			return 0
		ok

	def IsByPairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ByPair )

			return 1

		else
			return 0
		ok

	def IsByHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ByHashList )

			return 1

		else
			return 0
		ok

	def IsBySetNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BySet )

			return 1

		else
			return 0
		ok

	def IsByObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ByObject )

			return 1

		else
			return 0
		ok

	#--

	def IsByOrByNumberNamedParam()
		if This.IsByNamedParam() or This.IsByNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsByNumberOrByNamedParam()
			return This.IsByOrByNumberNamedParam()

		def IsByOrByNumberNamedParams()
			return This.IsByOrByNumberNamedParam()

		def IsByNumberOrByNamedParams()
			return This.IsByOrByNumberNamedParam()

	def IsByOrByCharNamedParam()
		if This.IsByNamedParam() or This.IsByCharNamedParam()
			return 1
		else
			return 0
		ok

		def IsByCharOrByNamedParam()
			return This.IsByOrByCharNamedParam()

		def IsByOrByCharNamedParams()
			return This.IsByOrByCharNamedParam()

		def IsByCharOrByNamedParams()
			return This.IsByOrByCharNamedParam()

	def IsByOrByStringNamedParam()
		if This.IsByNamedParam() or This.IsByStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsByStringOrByNamedParam()
			return This.IsByOrByStringNamedParam()

		def IsByOrByStringNamedParams()
			return This.IsByOrByStringNamedParam()

		def IsByStringOrByNamedParams()
			return This.IsByOrByStringNamedParam()

	def IsByOrBySubStringNamedParam()
		if This.IsByNamedParam() or This.IsBySubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsBySubStringOrByNamedParam()
			return This.IsByOrBySubStringNamedParam()

		def IsByOrBySubStringNamedParams()
			return This.IsByOrBySubStringNamedParam()

		def IsBySubStringOrByNamedParams()
			return This.IsByOrBySubStringNamedParam()

	def IsByOrByListNamedParam()
		if This.IsByNamedParam() or This.IsByListNamedParam()
			return 1
		else
			return 0
		ok

		def IsByListOrByNamedParam()
			return This.IsByOrByListNamedParam()

		def IsByOrByListNamedParams()
			return This.IsByOrByListNamedParam()

		def IsByListOrByNamedParams()
			return This.IsByOrByListNamedParam()

	def IsByOrByHashListNamedParam()
		if This.IsByNamedParam() or This.IsByHashListNamedParam()
			return 1
		else
			return 0
		ok

		def IsByHashListOrByNamedParam()
			return This.IsByOrByHashListNamedParam()

		def IsByOrByHashListNamedParams()
			return This.IsByOrByHashListNamedParam()

		def IsByHashListOrByNamedParams()
			return This.IsByOrByHashListNamedParam()

	def IsByOrByPairNamedParam()
		if This.IsByNamedParam() or This.IsByPairNamedParam()
			return 1
		else
			return 0
		ok

		def IsByPairOrByNamedParam()
			return This.IsByOrByPairNamedParam()

		def IsByOrByPairNamedParams()
			return This.IsByOrByPairNamedParam()

		def IsByPairOrByNamedParams()
			return This.IsByOrByPairNamedParam()

	def IsByOrBySetNamedParam()
		if This.IsByNamedParam() or This.IsBySetNamedParam()
			return 1
		else
			return 0
		ok

		def IsBySetOrByNamedParam()
			return This.IsByOrBySetNamedParam()

		def IsByOrBySetNamedParams()
			return This.IsByOrBySetNamedParam()

		def IsBySetOrByNamedParams()
			return This.IsByOrBySetNamedParam()

	def IsByOrByObjectNamedParam()
		if This.IsByNamedParam() or This.IsByObjectNamedParam()
			return 1
		else
			return 0
		ok

		def IsByStringOrByObjectParam()
			return This.IsByOrByStringNamedParam()

		def IsByOrByObjectNamedParams()
			return This.IsByOrByObjectNamedParam()

		def IsByStringOrByObjectParams()
			return This.IsByOrByStringNamedParam()

	#==

	def IsListOfListsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ListOfLists )

			return 1

		else
			return 0
		ok

	def IsGridNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Grid )

			return 1

		else
			return 0
		ok

	def IsTableNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Table )

			return 1

		else
			return 0
		ok

	def IsHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :HashList )

			return 1

		else
			return 0
		ok

	def IsPairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Pair )

			return 1

		else
			return 0
		ok

	def IsListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :List )

			return 1

		else
			return 0
		ok

	def IsObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Object )

			return 1

		else
			return 0
		ok

	#==

	def IsInNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InNumber )

			return 1

		else
			return 0
		ok

	def IsInStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InString )

			return 1

		else
			return 0
		ok

	def IsInSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InSubString )

			return 1

		else
			return 0
		ok

	def IsInCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InChar )

			return 1

		else
			return 0
		ok

	def IsInListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InList )

			return 1

		else
			return 0
		ok

	def IsInPairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InPair )

			return 1

		else
			return 0
		ok

	def IsInHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InHashList )

			return 1

		else
			return 0
		ok

	def IsInSetNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InSet )

			return 1

		else
			return 0
		ok

	def IsInObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InObject )

			return 1

		else
			return 0
		ok

	#--

	def IsInOrInNumberNamedParam()
		if This.IsInNamedParam() or This.IsInNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsInNumberOrInNamedParam()
			return This.IsInOrInNumberNamedParam()

		def IsInOrInNumberNamedParams()
			return This.IsInOrInNumberNamedParam()

		def IsInNumberOrInNamedParams()
			return This.IsInOrInNumberNamedParam()

	def IsInOrInCharNamedParam()
		if This.IsInNamedParam() or This.IsInCharNamedParam()
			return 1
		else
			return 0
		ok

		def IsInCharOrInNamedParam()
			return This.IsInOrInCharNamedParam()

		def IsInOrInCharNamedParams()
			return This.IsInOrInCharNamedParam()

		def IsInCharOrInNamedParams()
			return This.IsInOrInCharNamedParam()

	def IsInOrInStringNamedParam()
		if This.IsInNamedParam() or This.IsInStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsInStringOrInNamedParam()
			return This.IsInOrInStringNamedParam()

		def IsInOrInStringNamedParams()
			return This.IsInOrInStringNamedParam()

		def IsInStringOrInNamedParams()
			return This.IsInOrInStringNamedParam()

	def IsInOrInSubStringNamedParam()
		if This.IsInNamedParam() or This.IsInSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsInSubStringOrInNamedParam()
			return This.IsInOrInSubStringNamedParam()

		def IsInOrInSubStringNamedParams()
			return This.IsInOrInSubStringNamedParam()

		def IsInSubStringOrInNamedParams()
			return This.IsInOrInSubStringNamedParam()

	def IsInOrInListNamedParam()
		if This.IsInNamedParam() or This.IsInListNamedParam()
			return 1
		else
			return 0
		ok

		def IsInListOrInNamedParam()
			return This.IsInOrInListNamedParam()

		def IsInOrInListNamedParams()
			return This.IsInOrInListNamedParam()

		def IsInListOrInNamedParams()
			return This.IsInOrInListNamedParam()

	def IsInOrInHashListNamedParam()
		if This.IsInNamedParam() or This.IsInHashListNamedParam()
			return 1
		else
			return 0
		ok

		def IsInHashListOrInNamedParam()
			return This.IsInOrInHashListNamedParam()

		def IsInOrInHashListNamedParams()
			return This.IsInOrInHashListNamedParam()

		def IsInHashListOrInNamedParams()
			return This.IsInOrInHashListNamedParam()

	def IsInOrInPairNamedParam()
		if This.IsInNamedParam() or This.IsInPairNamedParam()
			return 1
		else
			return 0
		ok

		def IsInPairOrInNamedParam()
			return This.IsInOrInPairNamedParam()

		def IsInOrInPairNamedParams()
			return This.IsInOrInPairNamedParam()

		def IsInPairOrInNamedParams()
			return This.IsInOrInPairNamedParam()

	def IsInOrInSetNamedParam()
		if This.IsInNamedParam() or This.IsInSetNamedParam()
			return 1
		else
			return 0
		ok

		def IsInSetOrInNamedParam()
			return This.IsInOrInSetNamedParam()

		def IsInOrInSetNamedParams()
			return This.IsInOrInSetNamedParam()

		def IsInSetOrInNamedParams()
			return This.IsInOrInSetNamedParam()

	def IsInOrInObjectNamedParam()
		if This.IsInNamedParam() or This.IsInObjectNamedParam()
			return 1
		else
			return 0
		ok

		def IsInObjectOrInNamedParam()
			return This.IsInOrInStringNamedParam()

		def IsInOrInObjectNamedParams()
			return This.IsInOrInObjectNamedParam()

		def IsInObjectOrInNamedParams()
			return This.IsInOrInObjectNamedParam()

	#==

	def IsWithNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithNumber )

			return 1

		else
			return 0
		ok

	def IsWithStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithString )

			return 1

		else
			return 0
		ok

	def IsWithSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithSubString )

			return 1

		else
			return 0
		ok

	def IsWithCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithChar )

			return 1

		else
			return 0
		ok

	def IsWithListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithList )

			return 1

		else
			return 0
		ok

	def IsWithPairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithPair )

			return 1

		else
			return 0
		ok

	def IsWithHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithHashList )

			return 1

		else
			return 0
		ok

	def IsWithSetNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithSet )

			return 1

		else
			return 0
		ok

	def IsWithObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithObject )

			return 1

		else
			return 0
		ok

	#--

	def IsWithOrToNamedParam()
		if This.IsWithNamedParam() or This.IsToNamedParam()
			return 1
		else
			return 0
		ok

		def IsToOrWithNamedParam()
			return This.IsWithOrToNamedParam()


	def IsWithOrWithNumberNamedParam()
		if This.IsWithNamedParam() or This.IsWithNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithNumberOrWithNamedParam()
			return This.IsWithOrWithNumberNamedParam()

		def IsWithOrWithNumberNamedParams()
			return This.IsWithOrWithNumberNamedParam()

		def IsWithNumberOrWithNamedParams()
			return This.IsWithOrWithNumberNamedParam()

	def IsWithOrWithCharNamedParam()
		if This.IsWithNamedParam() or This.IsWithCharNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithCharOrWithNamedParam()
			return This.IsWithOrWithCharNamedParam()

		def IsWithOrWithCharNamedParams()
			return This.IsWithOrWithCharNamedParam()

		def IsWithCharOrWithNamedParams()
			return This.IsWithOrWithCharNamedParam()

	def IsWithOrWithStringNamedParam()
		if This.IsWithNamedParam() or This.IsWithStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithStringOrWithNamedParam()
			return This.IsWithOrWithStringNamedParam()

		def IsWithOrWithStringNamedParams()
			return This.IsWithOrWithStringNamedParam()

		def IsWithStringOrWithNamedParams()
			return This.IsWithOrWithStringNamedParam()

	def IsWithOrWithSubStringNamedParam()
		if This.IsWithNamedParam() or This.IsWithSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithSubStringOrWithNamedParam()
			return This.IsWithOrWithSubStringNamedParam()

		def IsWithOrWithSubStringNamedParams()
			return This.IsWithOrWithSubStringNamedParam()

		def IsWithSubStringOrWithNamedParams()
			return This.IsWithOrWithSubStringNamedParam()

	def IsWithOrWithListNamedParam()
		if This.IsWithNamedParam() or This.IsWithListNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithListOrWithNamedParam()
			return This.IsWithOrWithListNamedParam()

		def IsWithOrWithListNamedParams()
			return This.IsWithOrWithListNamedParam()

		def IsWithListOrWithNamedParams()
			return This.IsWithOrWithListNamedParam()

	def IsWithOrWithHashListNamedParam()
		if This.IsWithNamedParam() or This.IsWithHashListNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithHashListOrWithNamedParam()
			return This.IsWithOrWithHashListNamedParam()

		def IsWithOrWithHashListNamedParams()
			return This.IsWithOrWithHashListNamedParam()

		def IsWithHashListOrWithNamedParams()
			return This.IsWithOrWithHashListNamedParam()

	def IsWithOrWithPairNamedParam()
		if This.IsWithNamedParam() or This.IsWithPairNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithPairOrWithNamedParam()
			return This.IsWithOrWithPairNamedParam()

		def IsWithOrWithPairNamedParams()
			return This.IsWithOrWithPairNamedParam()

		def IsWithPairOrWithNamedParams()
			return This.IsWithOrWithPairNamedParam()

	def IsWithOrWithSetNamedParam()
		if This.IsWithNamedParam() or This.IsWithSetNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithSetOrWithNamedParam()
			return This.IsWithOrWithSetNamedParam()

		def IsWithOrWithSetNamedParams()
			return This.IsWithOrWithSetNamedParam()

		def IsWithSetOrWithNamedParams()
			return This.IsWithOrWithSetNamedParam()

	def IsWithOrWithObjectNamedParam()
		if This.IsWithNamedParam() or This.IsWithObjectNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithObjectOrWithNamedParam()
			return This.IsWithOrWithObjectNamedParam()

		def IsWithOrWithObjectNamedParams()
			return This.IsWithOrWithObjectNamedParam()

		def IsWithObjectOrWithNamedParams()
			return This.IsWithOrWithObjectNamedParam()

	#==

	def IsInsideNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InsideNumber )

			return 1

		else
			return 0
		ok

	def IsInsideStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InsideString )

			return 1

		else
			return 0
		ok

	def IsInsideSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InsideSubString )

			return 1

		else
			return 0
		ok

	def IsInsideCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InsideChar )

			return 1

		else
			return 0
		ok

	def IsInsideListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InsideList )

			return 1

		else
			return 0
		ok

	def IsInsidePairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InsidePair )

			return 1

		else
			return 0
		ok

	def IsInsideHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InsideHashList )

			return 1

		else
			return 0
		ok

	def IsInsideSetNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InsideSet )

			return 1

		else
			return 0
		ok

	def IsInsideObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InsideObject )

			return 1

		else
			return 0
		ok

	#--

	def IsInsideOrInsideNumberNamedParam()
		if This.IsInsideNamedParam() or This.IsInsideNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsInsideNumberOrInsideNamedParam()
			return This.IsInsideOrInsideNumberNamedParam()

		def IsInsideOrInsideNumberNamedParams()
			return This.IsInsideOrInsideNumberNamedParam()

		def IsInsideNumberOrInsideNamedParams()
			return This.IsInsideOrInsideNumberNamedParam()

	def IsInsideOrInsideCharNamedParam()
		if This.IsInsideNamedParam() or This.IsInsideCharNamedParam()
			return 1
		else
			return 0
		ok

		def IsInsideCharOrInsideNamedParam()
			return This.IsInsideOrInsideCharNamedParam()

		def IsInsideOrInsideCharNamedParams()
			return This.IsInsideOrInsideCharNamedParam()

		def IsInsideCharOrInsideNamedParams()
			return This.IsInsideOrInsideCharNamedParam()

	def IsInsideOrInsideStringNamedParam()
		if This.IsInsideNamedParam() or This.IsInsideStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsInsideStringOrInsideNamedParam()
			return This.IsInsideOrInsideStringNamedParam()

		def IsInsideOrInsideStringNamedParams()
			return This.IsInsideOrInsideStringNamedParam()

		def IsInsideStringOrInsideNamedParams()
			return This.IsInsideOrInsideStringNamedParam()

	def IsInsideOrInsideSubStringNamedParam()
		if This.IsInsideNamedParam() or This.IsInsideSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsInsideSubStringOrInsideNamedParam()
			return This.IsInsideOrInsideSubStringNamedParam()

		def IsInsideOrInsideSubStringNamedParams()
			return This.IsInsideOrInsideSubStringNamedParam()

		def IsInsideSubStringOrInsideNamedParams()
			return This.IsInsideOrInsideSubStringNamedParam()

	def IsInsideOrInsideListNamedParam()
		if This.IsInsideNamedParam() or This.IsInsideListNamedParam()
			return 1
		else
			return 0
		ok

		def IsInsideListOrInsideNamedParam()
			return This.IsInsideOrInsideListNamedParam()

		def IsInsideOrInsideListNamedParams()
			return This.IsInsideOrInsideListNamedParam()

		def IsInsideListOrInsideNamedParams()
			return This.IsInsideOrInsideListNamedParam()

	def IsInsideOrInsideHashListNamedParam()
		if This.IsInsideNamedParam() or This.IsInsideHashListNamedParam()
			return 1
		else
			return 0
		ok

		def IsInsideHashListOrInsideNamedParam()
			return This.IsInsideOrInsideHashListNamedParam()

		def IsInsideOrInsideHashListNamedParams()
			return This.IsInsideOrInsideHashListNamedParam()

		def IsInsideHashListOrInsideNamedParams()
			return This.IsInsideOrInsideHashListNamedParam()

	def IsInsideOrInsidePairNamedParam()
		if This.IsInsideNamedParam() or This.IsInsidePairNamedParam()
			return 1
		else
			return 0
		ok

		def IsInsidePairOrInsideNamedParam()
			return This.IsInsideOrInsidePairNamedParam()

		def IsInsideOrInsidePairNamedParams()
			return This.IsInsideOrInsidePairNamedParam()

		def IsInsidePairOrInsideNamedParams()
			return This.IsInsideOrInsidePairNamedParam()

	def IsInsideOrInsideSetNamedParam()
		if This.IsInsideNamedParam() or This.IsInsideSetNamedParam()
			return 1
		else
			return 0
		ok

		def IsInsideSetOrInsideNamedParam()
			return This.IsInsideOrInsideSetNamedParam()

		def IsInsideOrInsideSetNamedParams()
			return This.IsInsideOrInsideSetNamedParam()

		def IsInsideSetOrInsideNamedParams()
			return This.IsInsideOrInsideSetNamedParam()

	def IsInsideOrInsideObjectNamedParam()
		if This.IsInsideNamedParam() or This.IsInsideObjectNamedParam()
			return 1
		else
			return 0
		ok

		def IsInsideObjectOrInsideNamedParam()
			return This.IsInsideOrInsideObjectNamedParam()

		def IsInsideOrInsideObjectNamedParams()
			return This.IsInsideOrInsideObjectNamedParam()

		def IsInsideObjectOrInsideNamedParams()
			return This.IsInsideOrInsideObjectNamedParam()

	#==

	def IsOnNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OnNumber )

			return 1

		else
			return 0
		ok

	def IsOnStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OnString )

			return 1

		else
			return 0
		ok

	def IsOnSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OnSubString )

			return 1

		else
			return 0
		ok

	def IsOnCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OnChar )

			return 1

		else
			return 0
		ok

	def IsOnListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OnList )

			return 1

		else
			return 0
		ok

	def IsOnPairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OnPair )

			return 1

		else
			return 0
		ok

	def IsOnHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OnHashList )

			return 1

		else
			return 0
		ok

	def IsOnSetNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OnSet )

			return 1

		else
			return 0
		ok

	def IsOnObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OnObject )

			return 1

		else
			return 0
		ok

	#--

	def IsOnOrOnNumberNamedParam()
		if This.IsOnNamedParam() or This.IsOnNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsOnNumberOrOnNamedParam()
			return This.IsOnOrOnNumberNamedParam()

		def IsOnOrOnNumberNamedParams()
			return This.IsOnOrOnNumberNamedParam()

		def IsOnNumberOrOnNamedParams()
			return This.IsOnOrOnNumberNamedParam()

	def IsOnOrOnCharNamedParam()
		if This.IsOnNamedParam() or This.IsOnCharNamedParam()
			return 1
		else
			return 0
		ok

		def IsOnCharOrOnNamedParam()
			return This.IsOnOrOnCharNamedParam()

		def IsOnOrOnCharNamedParams()
			return This.IsOnOrOnCharNamedParam()

		def IsOnCharOrOnNamedParams()
			return This.IsOnOrOnCharNamedParam()

	def IsOnOrOnStringNamedParam()
		if This.IsOnNamedParam() or This.IsOnStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsOnStringOrOnNamedParam()
			return This.IsOnOrOnStringNamedParam()

		def IsOnOrOnStringNamedParams()
			return This.IsOnOrOnStringNamedParam()

		def IsOnStringOrOnNamedParams()
			return This.IsOnOrOnStringNamedParam()

	def IsOnOrOnSubStringNamedParam()
		if This.IsOnNamedParam() or This.IsOnSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsOnSubStringOrOnNamedParam()
			return This.IsOnOrOnSubStringNamedParam()

		def IsOnOrOnSubStringNamedParams()
			return This.IsOnOrOnSubStringNamedParam()

		def IsOnSubStringOrOnNamedParams()
			return This.IsOnOrOnSubStringNamedParam()

	def IsOnOrOnListNamedParam()
		if This.IsOnNamedParam() or This.IsOnListNamedParam()
			return 1
		else
			return 0
		ok

		def IsOnListOrOnNamedParam()
			return This.IsOnOrOnListNamedParam()

		def IsOnOrOnListNamedParams()
			return This.IsOnOrOnListNamedParam()

		def IsOnListOrOnNamedParams()
			return This.IsOnOrOnListNamedParam()

	def IsOnOrOnHashListNamedParam()
		if This.IsOnNamedParam() or This.IsOnHashListNamedParam()
			return 1
		else
			return 0
		ok

		def IsOnHashListOrOnNamedParam()
			return This.IsOnOrOnHashListNamedParam()

		def IsOnOrOnHashListNamedParams()
			return This.IsOnOrOnHashListNamedParam()

		def IsOnHashListOrOnNamedParams()
			return This.IsOnOrOnHashListNamedParam()

	def IsOnOrOnPairNamedParam()
		if This.IsOnNamedParam() or This.IsOnPairNamedParam()
			return 1
		else
			return 0
		ok

		def IsOnPairOrOnNamedParam()
			return This.IsOnOrOnPairNamedParam()

		def IsOnOrOnPairNamedParams()
			return This.IsOnOrOnPairNamedParam()

		def IsOnPairOrOnNamedParams()
			return This.IsOnOrOnPairNamedParam()

	def IsOnOrOnSetNamedParam()
		if This.IsOnNamedParam() or This.IsOnSetNamedParam()
			return 1
		else
			return 0
		ok

		def IsOnSetOrOnNamedParam()
			return This.IsOnOrOnSetNamedParam()

		def IsOnOrOnSetNamedParams()
			return This.IsOnOrOnSetNamedParam()

		def IsOnSetOrOnNamedParams()
			return This.IsOnOrOnSetNamedParam()

	def IsOnOrOnObjectNamedParam()
		if This.IsOnNamedParam() or This.IsOnObjectNamedParam()
			return 1
		else
			return 0
		ok

		def IsOnObjectOrOnNamedParam()
			return This.IsOnOrOnObjectNamedParam()

		def IsOnOrOnObjectNamedParams()
			return This.IsOnOrOnObjectNamedParam()

		def IsOnObjectOrOnNamedParams()
			return This.IsOnOrOnObjectNamedParam()

	#==

	def IsOverNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverNumber )

			return 1

		else
			return 0
		ok

	def IsOverStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverString )

			return 1

		else
			return 0
		ok

	def IsOverSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverSubString )

			return 1

		else
			return 0
		ok

	def IsOverCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverChar )

			return 1

		else
			return 0
		ok

	def IsOverListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverList )

			return 1

		else
			return 0
		ok

	def IsOverPairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverPair )

			return 1

		else
			return 0
		ok

	def IsOverHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverHashList )

			return 1

		else
			return 0
		ok

	def IsOverSetNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverSet )

			return 1

		else
			return 0
		ok

	def IsOverObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverObject )

			return 1

		else
			return 0
		ok

	#--

	def IsOverOrOverNumberNamedParam()
		if This.IsOverNamedParam() or This.IsOverNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsOverNumberOrOverNamedParam()
			return This.IsOverOrOverNumberNamedParam()

		def IsOverOrOverNumberNamedParams()
			return This.IsOverOrOverNumberNamedParam()

		def IsOverNumberOrOverNamedParams()
			return This.IsOverOrOverNumberNamedParam()

	def IsOverOrOverCharNamedParam()
		if This.IsOverNamedParam() or This.IsOverCharNamedParam()
			return 1
		else
			return 0
		ok

		def IsOverCharOrOverNamedParam()
			return This.IsOverOrOverCharNamedParam()

		def IsOverOrOverCharNamedParams()
			return This.IsOverOrOverCharNamedParam()

		def IsOverCharOrOverNamedParams()
			return This.IsOverOrOverCharNamedParam()

	def IsOverOrOverStringNamedParam()
		if This.IsOverNamedParam() or This.IsOverStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsOverStringOrOverNamedParam()
			return This.IsOverOrOverStringNamedParam()

		def IsOverOrOverStringNamedParams()
			return This.IsOverOrOverStringNamedParam()

		def IsOverStringOrOverNamedParams()
			return This.IsOverOrOverStringNamedParam()

	def IsOverOrOverSubStringNamedParam()
		if This.IsOverNamedParam() or This.IsOverSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsOverSubStringOrOverNamedParam()
			return This.IsOverOrOverSubStringNamedParam()

		def IsOverOrOverSubStringNamedParams()
			return This.IsOverOrOverSubStringNamedParam()

		def IsOverSubStringOrOverNamedParams()
			return This.IsOverOrOverSubStringNamedParam()

	def IsOverOrOverListNamedParam()
		if This.IsOverNamedParam() or This.IsOverListNamedParam()
			return 1
		else
			return 0
		ok

		def IsOverListOrOverNamedParam()
			return This.IsOverOrOverListNamedParam()

		def IsOverOrOverListNamedParams()
			return This.IsOverOrOverListNamedParam()

		def IsOverListOrOverNamedParams()
			return This.IsOverOrOverListNamedParam()

	def IsOverOrOverHashListNamedParam()
		if This.IsOverNamedParam() or This.IsOverHashListNamedParam()
			return 1
		else
			return 0
		ok

		def IsOverHashListOrOverNamedParam()
			return This.IsOverOrOverHashListNamedParam()

		def IsOverOrOverHashListNamedParams()
			return This.IsOverOrOverHashListNamedParam()

		def IsOverHashListOrOverNamedParams()
			return This.IsOverOrOverHashListNamedParam()

	def IsOverOrOverPairNamedParam()
		if This.IsOverNamedParam() or This.IsOverPairNamedParam()
			return 1
		else
			return 0
		ok

		def IsOverPairOrOverNamedParam()
			return This.IsOverOrOverPairNamedParam()

		def IsOverOrOverPairNamedParams()
			return This.IsOverOrOverPairNamedParam()

		def IsOverPairOrOverNamedParams()
			return This.IsOverOrOverPairNamedParam()

	def IsOverOrOverSetNamedParam()
		if This.IsOverNamedParam() or This.IsOverSetNamedParam()
			return 1
		else
			return 0
		ok

		def IsOverSetOrOverNamedParam()
			return This.IsOverOrOverSetNamedParam()

		def IsOverOrOverSetNamedParams()
			return This.IsOverOrOverSetNamedParam()

		def IsOverSetOrOverNamedParams()
			return This.IsOverOrOverSetNamedParam()

	def IsOverOrOverObjectNamedParam()
		if This.IsOverNamedParam() or This.IsOverObjectNamedParam()
			return 1
		else
			return 0
		ok

		def IsOverObjectOrOverNamedParam()
			return This.IsOverOrOverObjectNamedParam()

		def IsOverOrOverObjectNamedParams()
			return This.IsOverOrOverObjectNamedParam()

		def IsOverObjectOrOverNamedParams()
			return This.IsOverOrOverObjectNamedParam()

	#==

	def IsAgainstNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverNumber )

			return 1

		else
			return 0
		ok

	def IsAgainstStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverString )

			return 1

		else
			return 0
		ok

	def IsAgainstSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverSubString )

			return 1

		else
			return 0
		ok

	def IsAgainstCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverChar )

			return 1

		else
			return 0
		ok

	def IsAgainstListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverList )

			return 1

		else
			return 0
		ok

	def IsAgainstPairNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverPair )

			return 1

		else
			return 0
		ok

	def IsAgainstHashListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverHashList )

			return 1

		else
			return 0
		ok

	def IsAgainstSetNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverSet )

			return 1

		else
			return 0
		ok

	def IsAgainstObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OverObject )

			return 1

		else
			return 0
		ok

	#--

	def IsAgainstOrAgainstNumberNamedParam()
		if This.IsAgainstNamedParam() or This.IsAgainstNumberNamedParam()
			return 1
		else
			return 0
		ok

		def IsAgainstNumberOrAgainstNamedParam()
			return This.IsAgainstOrAgainstNumberNamedParam()

		def IsAgainstOrAgainstNumberNamedParams()
			return This.IsAgainstOrAgainstNumberNamedParam()

		def IsAgainstNumberOrAgainstNamedParams()
			return This.IsAgainstOrAgainstNumberNamedParam()

	def IsAgainstOrAgainstCharNamedParam()
		if This.IsAgainstNamedParam() or This.IsAgainstCharNamedParam()
			return 1
		else
			return 0
		ok

		def IsAgainstCharOrAgainstNamedParam()
			return This.IsAgainstOrAgainstCharNamedParam()

		def IsAgainstOrAgainstCharNamedParams()
			return This.IsAgainstOrAgainstCharNamedParam()

		def IsAgainstCharOrAgainstNamedParams()
			return This.IsAgainstOrAgainstCharNamedParam()

	def IsAgainstOrAgainstStringNamedParam()
		if This.IsAgainstNamedParam() or This.IsAgainstStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsAgainstStringOrAgainstNamedParam()
			return This.IsAgainstOrAgainstStringNamedParam()

		def IsAgainstOrAgainstStringNamedParams()
			return This.IsAgainstOrAgainstStringNamedParam()

		def IsAgainstStringOrAgainstNamedParams()
			return This.IsAgainstOrAgainstStringNamedParam()

	def IsAgainstOrAgainstSubStringNamedParam()
		if This.IsAgainstNamedParam() or This.IsAgainstSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IsAgainstSubStringOrAgainstNamedParam()
			return This.IsAgainstOrAgainstSubStringNamedParam()

		def IsAgainstOrAgainstSubStringNamedParams()
			return This.IsAgainstOrAgainstSubStringNamedParam()

		def IsAgainstSubStringOrAgainstNamedParams()
			return This.IsAgainstOrAgainstSubStringNamedParam()

	def IsAgainstOrAgainstListNamedParam()
		if This.IsAgainstNamedParam() or This.IsAgainstListNamedParam()
			return 1
		else
			return 0
		ok

		def IsAgainstListOrAgainstNamedParam()
			return This.IsAgainstOrAgainstListNamedParam()

		def IsAgainstOrAgainstListNamedParams()
			return This.IsAgainstOrAgainstListNamedParam()

		def IsAgainstListOrAgainstNamedParams()
			return This.IsAgainstOrAgainstListNamedParam()

	def IsAgainstOrAgainstHashListNamedParam()
		if This.IsAgainstNamedParam() or This.IsAgainstHashListNamedParam()
			return 1
		else
			return 0
		ok

		def IsAgainstHashListOrAgainstNamedParam()
			return This.IsAgainstOrAgainstHashListNamedParam()

		def IsAgainstOrAgainstHashListNamedParams()
			return This.IsAgainstOrAgainstHashListNamedParam()

		def IsAgainstHashListOrAgainstNamedParams()
			return This.IsAgainstOrAgainstHashListNamedParam()

	def IsAgainstOrAgainstPairNamedParam()
		if This.IsAgainstNamedParam() or This.IsAgainstPairNamedParam()
			return 1
		else
			return 0
		ok

		def IsAgainstPairOrAgainstNamedParam()
			return This.IsAgainstOrAgainstPairNamedParam()

		def IsAgainstOrAgainstPairNamedParams()
			return This.IsAgainstOrAgainstPairNamedParam()

		def IsAgainstPairOrAgainstNamedParams()
			return This.IsAgainstOrAgainstPairNamedParam()

	def IsAgainstOrAgainstSetNamedParam()
		if This.IsAgainstNamedParam() or This.IsAgainstSetNamedParam()
			return 1
		else
			return 0
		ok

		def IsAgainstSetOrAgainstNamedParam()
			return This.IsAgainstOrAgainstSetNamedParam()

		def IsAgainstOrAgainstSetNamedParams()
			return This.IsAgainstOrAgainstSetNamedParam()

		def IsAgainstSetOrAgainstNamedParams()
			return This.IsAgainstOrAgainstSetNamedParam()

	def IsAgainstOrAgainstObjectNamedParam()
		if This.IsAgainstNamedParam() or This.IsAgainstObjectNamedParam()
			return 1
		else
			return 0
		ok

		def IsAgainstObjectOrAgainstNamedParam()
			return This.IsAgainstOrAgainstObjectNamedParam()

		def IsAgainstOrAgainstObjectNamedParams()
			return This.IsAgainstOrAgainstObjectNamedParam()

		def IsAgainstObjectOrAgainstNamedParams()
			return This.IsAgainstOrAgainstObjectNamedParam()

	#==

	def IsRespectivelyNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Respectively )

			return 1

		else
			return 0
		ok

	#==

	def IsSeedNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Seed )

			return 1

		else
			return 0
		ok
	
	#==

	def IsEqualToNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EqualTo )

			return 1

		else
			return 0
		ok

	def IsEqualsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Equals )

			return 1

		else
			return 0
		ok

	def IsEqualsOrIsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  StzFind([ "equals", "is" ], This.Item(1)) )

			return 1

		else
			return 0
		ok

		def IsIsOrEqualsNamedParam()
			return This.IsEqualsOrIsNamedParam()

	#==

	def IsGreaterThanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :GreaterThan )

			return 1

		else
			return 0
		ok

	def IsIsGreaterThanNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :IsGreaterThan )

			return 1

		else
			return 0
		ok

	def IsIsLessThanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :IsLessThan )

			return 1

		else
			return 0
		ok

	def IsLessThanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :LessThan )

			return 1

		else
			return 0
		ok

	#==

	def IsToNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :To )

			return 1

		else
			return 0
		ok

	def IsToNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToNode )

			return 1

		else
			return 0
		ok

	def IsToOrToNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  StzFind([ "to", "tonode" ], This.Item(1)) )

			return 1

		else
			return 0
		ok

		def IsToNodeOrToNamedParam()
			return This.IsToOrToNodeNamedParam()

	def IsToOrToNodeOrToNodesNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  StzFind([ "to", "tonode", "tonodes" ], This.Item(1)) )

			return 1

		else
			return 0
		ok

	def IsToOrToPositionOrToNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  StzFind([ "to", "tonode", "toposition" ], This.Item(1)) )

			return 1

		else
			return 0
		ok

		def IsToOrToNodeOrToPositionNamedParam()
			return This.IsToOrToPositionOrToNodeNamedParam()
	
	def IsToOrToNodeOrAndOrAndNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([ "to", "tonode", "and", "andnode" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

		def IsAndOrAndNodeOrToOrToNodeNamedParam()
			return This.IsToOrToNodeOrAndOrAndNodeNamedParam()


	def IsToOrToNodeOrUntilReachFNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([
			"to", "tonode", "untilreachf", "untilyoureachf",
			"untilyoureachf", "untilreachingf" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

	def IsToOrToNodeOrToNodesOrAndOrAndNodeOrAndNodesNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([
			"to", "tonode", "tonodes", "and",
			"andnode", "andnodes" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

	def IsOfOrOfPlanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([
			"of", "ofplan", "plan" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

	def IsInOrInPlanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([
			"in", "inplan", "plan" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

	def IsOforOfPlanOrInOrInPlanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([
			"of", "ofplan", "in", "inplan", "plan" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

	def IsPlanOrInPlanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([
			"plan", "inplan" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

		def IsInPlanOrPlanNamedParam()
			return This.IsPlanOrInPlanNamedParam()

	def IsPlanOrOfPlanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([
			"plan", "ofplan" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

		def IsOfPlanOrPlanNamedParam()
			return This.IsPlanOrOfPlanNamedParam()

	def IsFromNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromNode )

			return 1

		else
			return 0
		ok

	def IsInPlanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InPlan )

			return 1

		else
			return 0
		ok

	def IsOfPlanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfPlan )

			return 1

		else
			return 0
		ok

	def IsInPlanOrOfPlanNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  StzFind([ "inplan", "ofplan" ], This.Item(1)) )

			return 1

		else
			return 0
		ok

		def IsOfPlanOrInPlanNamedParam()
			return This.IsInPlanOrOfPlanNamedParam()

	def IsFromOrFromNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  StzFind([ "from", "fromnode" ], This.Item(1)) )

			return 1

		else
			return 0
		ok

		def IsFromNodeOrFromNamedParam()
			return This.IsFromOrFromNodeNamedParam()

	def IsNodeOrFromOrFromNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  StzFind([ "node", "from", "fromnode" ], This.Item(1)) )

			return 1

		else
			return 0
		ok

		def IsNodeOrFromNodeOrFromNamedParam()
			return This.IsNodeOrFromOrFromNodeNamedParam()

		def IsFromNodeOrNodeOrFromNamedParam()
			return This.IsNodeOrFromOrFromNodeNamedParam()

		def IsFromNodeOrFromOrNodeNamedParam()
			return This.IsNodeOrFromOrFromNodeNamedParam()

	def IsNodeOrNodesOrFromOrFromNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  StzFind([ "from", "fromnode", "node", "nodes" ], This.Item(1)) )

			return 1

		else
			return 0
		ok

		def IsFromOrFromNodeOrNodeOrNodesNamedParam()
			return This.IsNodeOrNodesOrFromOrFromNodeNamedParam()

	def IsToTheseNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToThis )

			return 1

		else
			return 0
		ok

	def IsToManyNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToMany )

			return 1

		else
			return 0
		ok

	def IsToPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToPosition )

			return 1

		else
			return 0
		ok

	def IsToPositionOfNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToPositionOf )

			return 1

		else
			return 0
		ok

	def IsToOrToPositionNamedParam()

		if This.IsToNamedParam() or This.IsToPositionNamedParam()
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def IsToOrToPositionNamedParams()
			return This.IsToOrToPositionNamedParam()

		def IsToPositionOrToNamedParam()
			return This.IsToOrToPositionNamedParam()

		def IsToPositionOrToNamedParams()
			return This.IsToOrToPositionNamedParam()

		#>

	def IsToPositionOfItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToPositionOfItem )

			return 1

		else
			return 0
		ok

	def IsToPositionOfStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToPositionOfString )

			return 1

		else
			return 0
		ok

	def IsToPositionOfCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToPositionOfChar )

			return 1

		else
			return 0
		ok

	#--

	def IsFromPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromPosition )

			return 1

		else
			return 0
		ok

	def IsFromOrFromPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  (This.Item(1) = :FromPosition or This.Item(1) = :From)  )

			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def IsFromOrFromPositionNamedParams()
			return This.IsFromOrFromPositionNamedParam()

		def IsFromPositionOrFromNamedParam()
			return This.IsFromOrFromPositionNamedParam()

		def IsFromPositionOrFromNamedParams()
			return This.IsFromOrFromPositionNamedParam()

		#>

	def IsFromPositionOfItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromPositionOfItem )

			return 1

		else
			return 0
		ok

	def IsFromPositionOfStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromPositionOfString )

			return 1

		else
			return 0
		ok

	def IsFromPositionOfCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromPositionOfChar )

			return 1

		else
			return 0
		ok

	#--

	def IsOfNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Of )

			return 1

		else
			return 0
		ok

	def IsOnNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :On )

			return 1

		else
			return 0
		ok

	def IsInNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :In )

			return 1

		else
			return 0
		ok

	def IsInANamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :InA )

			return 1

		else
			return 0
		ok

	#--

	def IsInSideNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :InSide or This.Item(1) = :Inside@) )

			return 1

		else
			return 0
		ok

	def IsInSideANamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and 
			(This.Item(1) = :InSideA or This.Item(1) = :InsideA@) )

			return 1

		else
			return 0
		ok

	def IsInOrInsideNamedParam()
		if This.IsInNamedParam() or This.IsInsideNamedParam()
			return 1

		else
			return 0
		ok

		def IsInOrInsideNamedParams()
			return This.IsInOrInsideNamedParam()

		def IsInsideOrInNamedParam()
			return This.IsInOrInsideNamedParam()

		def IsInsideOrInNamedParams()
			return This.IsInOrInsideNamedParam()

	def IsWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Where ) and
		   isString( This.Item(2) )

			return 1

		else
			return 0
		ok

	def IsWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WhereXT ) and
		   isString( This.Item(2) )

			return 1

		else
			return 0
		ok

	def IsThatNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :That ) and
		   isString( This.Item(2) )

			return 1

		else
			return 0
		ok

	def IsThatOrWhereNamedParam()
		if This.IsThatNamedParam() or This.IsWhereNamedParam()
			return 1
		else
			return 0
		ok

		def IsThatOrWhereNamedParams()
			return This.IsThatOrWhereNamedParam()

		def IsWhereOrThatNamedParam()
			return This.IsThatOrWhereNamedParam()

		def IsWhereOrThatNamedParams()
			return This.IsThatOrWhereNamedParam()

	def IsThatXTOrWhereXTNamedParam()
		if This.IsThatXTNamedParam() or This.IsWhereXTNamedParam()
			return 1
		else
			return 0
		ok

		def IsThatXTOrWhereXTNamedParams()
			return This.IsThatXTOrWhereXTNamedParam()

		def IsWhereXTOrThatXTNamedParam()
			return This.IsThatXTOrWhereXTNamedParam()

		def IsWherextOrThatxtNamedParams()
			return This.IsThatXTOrWhereXTNamedParam()

	def IsPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Position )

			return 1

		else
			return 0
		ok

	def IsPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :PositionIB )

			return 1

		else
			return 0
		ok

	def IsThisPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisPosition )

			return 1

		else
			return 0
		ok

	def IsThisPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisPositionIB )

			return 1

		else
			return 0
		ok

	def IsPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Positions )

			return 1

		else
			return 0
		ok

	def IsPositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :PositionsIB )

			return 1

		else
			return 0
		ok

	def IsThesePositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThesePositions )

			return 1

		else
			return 0
		ok

	def IsThesePositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThesePositionsIB )

			return 1

		else
			return 0
		ok

	def IsPositionOrPositionsNamedParam()
		if This.IsPositionNamedParam() or This.IsPositionsNamedParam()
			return 1
		else
			return 0
		ok

		def IsPositionOrPositionsNamedParams()
			return This.IsPositionOrPositionsNamedParam()

	def IsPositionIBOrPositionsibNamedParam()
		if This.IsPositionIBNamedParam() or This.IsPositionsIBNamedParam()
			return 1
		else
			return 0
		ok

		def IsPositionIBOrPositionsIBNamedParams()
			return This.IsPositionIBOrPositionsIBNamedParam()

	def IsAlongWithNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  (This.Item(1) = :AlongWith or This.Item(1) = :AlongWith@)  )

			return 1

		else
			return 0
		ok

	def IsAlongWithTheirNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  (This.Item(1) = :AlongWithTheir or This.Item(1) = :AlongWithTheir@)  )

			return 1

		else
			return 0
		ok

	def IsOrOrAndNamedParam()
		if This.IsOrNamedParam() or This.AndNamedParam()
			return 1
		else
			return 0
		ok

		def IsAndOrOrNamedParam()
			return This.IsOrOrAndNamedParam()

	def IsAndNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  (This.Item(1) = :And or This.Item(1) = :And@)  )

			return 1

		else
			return 0
		ok

	def IsAndTheirNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  (This.Item(1) = :AndTheir or This.Item(1) = :AndTheir@)  )

			return 1

		else
			return 0
		ok

	def IsAndItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndItem )

			return 1

		else
			return 0
		ok

	def IsAndStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndString )

			return 1

		else
			return 0
		ok

	def IsAndCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndChar )

			return 1

		else
			return 0
		ok

	def IsAndPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndPosition )

			return 1

		else
			return 0
		ok

	def IsAndPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndPositions )

			return 1

		else
			return 0
		ok

	def IsAndItemAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndItemAt )

			return 1

		else
			return 0
		ok

	def IsAndItemAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndItemAtPosition )

			return 1

		else
			return 0
		ok

	def IsAndStringAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndStringAt )

			return 1

		else
			return 0
		ok

	def IsAndStringAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndStringAtPosition )

			return 1

		else
			return 0
		ok

	#--

	def IsOrNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Or )

			return 1

		else
			return 0
		ok

	def IsOrANamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OrA )

			return 1

		else
			return 0
		ok

	def IsOrAnNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OrAn )

			return 1

		else
			return 0
		ok

	#--

	def IsNorNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Nor )

			return 1

		else
			return 0
		ok

	def IsWhileNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :While )

			return 1

		else
			return 0
		ok

	def IsNotNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Not )

			return 1

		else
			return 0
		ok

	def IsIfNamedParam()
		if This.NumberOfItems() = 2 and
		   This.Item(1) = :If and
		   isString(This.Item(2))

			return 1

		else
			return 0
		ok

	def IsIfOrWhereNamedParam()
		return This.IsIfNamedParam() or This.IsWhereNamedParam()

		def IsWhereOrIfNamedParam()
			return This.IsIfOrWhereNamedParam()

		def IsWhereOrIfNamedParams()
			return This.IsIfOrWhereNamedParam()

		def IsIfOrWhereNamedParams()
			return This.IsIfOrWhereNamedParam()

	def IsIfXTOrWhereXTNamedParam()
		return This.IsIfXTNamedParam() or This.IsWhereXTNamedParam()

		def IsWhereXTOrIfXTNamedParam()
			return This.IsIfXTOrWhereXTNamedParam()

		def IsWhereXTOrIfXTNamedParams()
			return This.IsIfXTOrWhereXTNamedParam()

		def IsIfXTOrWhereXTNamedParams()
			return This.IsIfXTOrWhereXTNamedParam()

	def IsWithNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :With or This.Item(1) = :With@ ) )

			return 1

		else
			return 0
		ok

	def IsWithManyNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :WithMany or This.Item(1) = :WithMany@ ) )
		  
			return 1

		else
			return 0
		ok

	def IsWithOrAndNamedParam()
		if This.IsWithNamedParam() or This.IsAndNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithOrAndNamedParams()
			return This.IsWithOrAndNamedParam()

		def IsAndOrWithNamedParam()
			return This.IsWithOrAndNamedParam()

		def IsAndOrWithNamedParams()
			return This.IsWithOrAndNamedParam()

	def IsWithItemsInNamedParam() 
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :By or This.Item(1) = :By@ ) )

			return 1

		else
			return 0
		ok

	def IsWithCharsInNamedParam() 
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :WithCharsIn or This.Item(1) = :WithCharsIn@ ) )

			return 1

		else
			return 0
		ok

	#==

	def IsUsingItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingItem)

			return 1
		else
			return 0
		ok

	def IsUsingThisItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingThisItem)

			return 1
		else
			return 0
		ok

	def IsUsingItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingItems)

			return 1
		else
			return 0
		ok

	def IsUsingTheseItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingTheseItems)

			return 1
		else
			return 0
		ok

	#--

	def IsUsingStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingString)

			return 1
		else
			return 0
		ok

	def IsUsingThisStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingThisString)

			return 1
		else
			return 0
		ok

	def IsUsingStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingStrings)

			return 1
		else
			return 0
		ok

	def IsUsingTheseStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingTheseStrings)

			return 1
		else
			return 0
		ok

	#--

	def IsUsingSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingSubString)

			return 1
		else
			return 0
		ok

	def IsUsingThisSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingThisSubString)

			return 1
		else
			return 0
		ok

	def IsUsingSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingSubStrings)

			return 1
		else
			return 0
		ok

	def IsUsingTheseSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :UsingTheseSubStrings)

			return 1
		else
			return 0
		ok

	#==

	def IsByItemsInNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :ByItemsIn or This.Item(1) = :ByItemsIn@ ) )

			return 1

		else
			return 0
		ok

	def IsUsingItemsInNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :UsingItemsIn or This.Item(1) = :UsingItemsIn@ ) )

			return 1

		else
			return 0
		ok

	def IsWithTheirNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :WithTheir or This.Item(1) = :WithTheir@ ) )

			return 1

		else
			return 0
		ok

	def IsByNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :By or This.Item(1) = :By@ ) )
		  
			return 1

		else
			return 0
		ok

	def IsByManyNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :ByMany or This.Item(1) = :ByMany@ ) )
		  
			return 1

		else
			return 0
		ok

	def IsByManyXTNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :ByManyXT or This.Item(1) = :ByManyXT@ ) )
		  
			return 1

		else
			return 0
		ok

	def IsUsingManyXTNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :UsingManyXT or This.Item(1) = :UsingManyXT@ ) )
		  
			return 1

		else
			return 0
		ok

	def IsWithManyXTNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :WithManyXT or This.Item(1) = :WithManyXT@ ) )
		  
			return 1

		else
			return 0
		ok

	#--

	def IsByOrUsingNamedParam()
		if This.IsByNamedParam() or This.IsUsingNamedParam()
			return 1
		else
			return 0
		ok

		def IsByOrUsingNamedParams()
			return This.IsByOrUsingNamedParam()

		def IsUsingOrByNamedParam()
			return This.IsByOrUsingNamedParam()

		def IsUsingOrByNamedParams()
			return This.IsByOrUsingNamedParam()

	#--

	def IsByManyOrWithManyOrUsingManyNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and

			( This.Item(1) = :ByMany or This.Item(1) = :UsingMany or
			This.Item(1) = :WithMany ) )
		  
			return 1

		else
			return 0
		ok


		#--

		def IsByManyOrUsingManyOrWithManyNamedParam()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()
	
		def IsWithManyOrByManyOrUsingManyNamedParam()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()
	
		def IsWithManyOrUsingManyOrByManyNamedParam()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()
	
		def IsUsingManyOrByManyOrWithManyNamedParam()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()
	
		def IsUsingManyOrWithManyOrByManyNamedParam()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()

		#-- ...Param(s) with s

		def IsByManyOrWithManyOrUsingManyNamedParams()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()

		def IsByManyOrUsingManyOrWithManyNamedParams()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()
	
		def IsWithManyOrByManyOrUsingManyNamedParams()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()
	
		def IsWithManyOrUsingManyOrByManyNamedParams()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()
	
		def IsUsingManyOrByManyOrWithManyNamedParams()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()
	
		def IsUsingManyOrWithManyOrByManyNamedParams()
			return This.IsByManyOrWithManyOrUsingManyNamedParam()

	#--

	def IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()
		if This.IsByManyXTNamedParam() or
		   This.IsWithXTNamedParam() or
		   This.IsUsingXTNamedParam()

			return 1
		else
			return 0
		ok

		#--

		def IsByManyXTOrUsingManyXTOrWithManyXTNamedParam()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()
	
		def IsWithManyXTOrByManyXTOrUsingManyXTNamedParam()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()
	
		def IsWithManyXTOrUsingManyXTOrByManyXTNamedParam()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()
	
		def IsUsingManyXTOrByManyXTOrWithManyXTNamedParam()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()
	
		def IsUsingManyXTOrWithManyXTOrByManyXTNamedParam()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()

		#-- ...Param(s) with s

		def IsByManyXTOrWithManyXTOrUsingManyXTNamedParams()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()

		def IsByManyXTOrUsingManyXTOrWithManyXTNamedParams()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()
	
		def IsWithManyXTOrByManyXTOrUsingManyXTNamedParams()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()
	
		def IsWithManyXTOrUsingManyXTOrByManyXTNamedParams()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()
	
		def IsUsingManyXTOrByManyXTOrWithManyXTNamedParams()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()
	
		def IsUsingManyXTOrWithManyXTOrByManyXTNamedParams()
			return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam()

	#==

	def IsByColNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		     StzFind([ :ByCol, :ByCol@ ], This.Item(1)) > 0 )
		  
			return 1

		else
			return 0
		ok

	def IsByColumnNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		     StzFind([ :ByColumn, :ByColumn@ ], This.Item(1)) > 0 )
		  
			return 1

		else
			return 0
		ok

	def IsUsingColNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		     StzFind([ :UsingCol, :UsingCol@ ], This.Item(1)) > 0 )

			return 1

		else
			return 0
		ok

	def IsUsingColumnNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		     StzFind([ :UsingColumn, :UsingColumn@ ], This.Item(1)) > 0 )
		  
			return 1

		else
			return 0
		ok

	def IsWithColNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		     StzFind([ :WithCol, :WithCol@ ], This.Item(1)) > 0 )
		  
			return 1

		else
			return 0
		ok

	def IsWithColumnNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		     StzFind([ :WithColumn, :WithColumn@ ], This.Item(1)) > 0 )
		  
			return 1

		else
			return 0
		ok

	def IsByRowNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ByRow )
		  
			return 1

		else
			return 0
		ok

	def IsWithRowNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithRow )
		  
			return 1

		else
			return 0
		ok

	def IsUsingRowNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UsingRow )
		  
			return 1

		else
			return 0
		ok

	def IsByCellNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ByCell )
		  
			return 1

		else
			return 0
		ok

	def IsWithCellNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :WithCell )
		  
			return 1

		else
			return 0
		ok

	def IsUsingCellNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UsingCell )
		  
			return 1

		else
			return 0
		ok

	def IsWithOrByNamedParam()
		return This.IsWithNamedParam() OR This.IsByNamedParam()

		def IsByOrWithNamedParam()
			return This.IsWithOrByNamedParam()

		def IsByOrWithNamedParams()
			return This.IsWithOrByNamedParam()

		def IsWithOrByNamedParams()
			return This.IsWithOrByNamedParam()

	def IsUsingNamedParam()
		if len(This.Content()) = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :Using or This.Item(1) = :Using@ ) )

			return 1

		else
			return 0
		ok

	def IsUsingManyNamedParam()
		if This.NumberOfItems() = 2 and ( isString(This.Item(1)) and
			( This.Item(1) = :UsingMany or This.Item(1) = :UsingMany@ ) )

			return 1

		else
			return 0
		ok

	def IsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :At
			return 1

		else
			return 0
		ok

	def IsAtIBNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :AtIB
			return 1

		else
			return 0
		ok

	def IsAtOrUsingNamedParam()
		if This.IsAtNamedParam() or This.IsUsingNamedParam()
			return 1
		else
			return 0
		ok

		def IsUsingOrAtNamedParam()
			return This.IsAtOrUsingNamedParam()

		def IsUsingOrAtNamedParams()
			return This.IsAtOrUsingNamedParam()

		def IsAtOrUsingNamedParams()
			return This.IsAtOrUsingNamedParam()

	#--

	def IsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtPosition )

			return 1

		else
			return 0
		ok

	def IsAtPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtPositionIB )

			return 1

		else
			return 0
		ok

	def IsAtThisPositionNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisPosition )

			return 1

		else
			return 0
		ok

	def IsAtThisPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisPositionIB )

			return 1

		else
			return 0
		ok

	def IsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtPositions )

			return 1

		else
			return 0
		ok

	def IsAtPositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtPositionsIB )

			return 1

		else
			return 0
		ok

	def IsAtThesePositionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThesePositions )

			return 1

		else
			return 0
		ok

	def IsAtThesePositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThesePositionsIB )

			return 1

		else
			return 0
		ok

	def IsAtManyPositionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyPositions )

			return 1

		else
			return 0
		ok

	def IsAtManyPositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyPositionsIB )

			return 1

		else
			return 0
		ok

	#--

	def IsAtOrAtPositionNamedParam()
		if This.IsAtNamedParam() or
		   This.IsAtPositionNamedParam()

			return 1

		else
			return 0
		ok

		def IsAtPositionOrAtNamedParam()
			return This.IsAtOrAtPositionNamedParam()

		def IsAtPositionOrAtNamedParams()
			return This.IsAtOrAtPositionNamedParam()

		def IsAtOrAtPositionNamedParams()
			return This.IsAtOrAtPositionNamedParam()

	def IsAtOrAtPositionsNamedParam()
		if This.IsAtNamedParam() or
		   This.IsAtPositionsNamedParam()

			return 1

		else
			return 0
		ok

		def IsAtPositionsOrAtNamedParam()
			return This.IsAtOrAtPositionsNamedParam()

		def IsAtPositionsOrAtNamedParams()
			return This.IsAtOrAtPositionsNamedParam()

		def IsAtOrAtPositionsNamedParams()
			return This.IsAtOrAtPositionsNamedParam()

	#==

	def IsAtItemNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtItem )

			return 1

		else
			return 0
		ok

	def IsAtThisItemNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisItem )

			return 1

		else
			return 0
		ok

	def IsAtItemsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtItems )

			return 1

		else
			return 0
		ok

	def IsAtTheseItemsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseItems )

			return 1

		else
			return 0
		ok

	def IsAtManyItemsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyItems )

			return 1

		else
			return 0
		ok

	#--

	def IsAtStringNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtString )

			return 1

		else
			return 0
		ok

	def IsAtThisStringNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisString )

			return 1

		else
			return 0
		ok

	def IsAtStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtStrings )

			return 1

		else
			return 0
		ok

	def IsAtTheseStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseStrings )

			return 1

		else
			return 0
		ok

	def IsAtManyStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyStrings )

			return 1

		else
			return 0
		ok

	#--

	def IsAtSubStringNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSubString )

			return 1

		else
			return 0
		ok

	def IsAtSubStringIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSubStringIB )

			return 1

		else
			return 0
		ok

	def IsAtOrAtSubStringNamedParam()
		if This.IsAtNamedParam() or This.IsAtSubStringNamedParam()
			return 1
		else
			return 0
		ok

		def IfAtSubStringOrAtNamedParam()
			return This.IsAtOrAtSubStringNamedParam()

		def IsAtOrAtSubStringNamedParams()
			return This.IsAtOrAtSubStringNamedParam()

		def IfAtSubStringOrAtNamedParams()
			return This.IsAtOrAtSubStringNamedParam()

	def IsAtThisSubStringNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisSubString )

			return 1

		else
			return 0
		ok

	def IsAtThisSubStringIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisSubStringIB )

			return 1

		else
			return 0
		ok

	def IsAtSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSubStrings )

			return 1

		else
			return 0
		ok

	def IsAtSubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSubStringsIB )

			return 1

		else
			return 0
		ok

	def IsAtTheseSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseSubStrings )

			return 1

		else
			return 0
		ok

	def IsAtTheseSubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseSubStringsIB )

			return 1

		else
			return 0
		ok

	def IsAtManySubStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManySubStrings )

			return 1

		else
			return 0
		ok

	def IsAtManySubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManySubStringsIB )

			return 1

		else
			return 0
		ok

	#--

	def IsAtCharNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtChar )

			return 1

		else
			return 0
		ok

	def IsBeforeIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeIB )

			return 1

		else
			return 0
		ok

	def IsAfterIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterIB )

			return 1

		else
			return 0
		ok

	def IsAroundIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundIB )

			return 1

		else
			return 0
		ok

	def IsAtThisCharNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisChar )

			return 1

		else
			return 0
		ok

	#--

	def IsAtItemIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtItemIB )

			return 1

		else
			return 0
		ok

	def IsAtItemsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtItemsIB )

			return 1

		else
			return 0
		ok

	#--

	def IsBeforePositionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforePositionIB )

			return 1

		else
			return 0
		ok

	def IsBeforeThisPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeThisPositionIB )

			return 1

		else
			return 0
		ok

	def IsBeforePositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforePositionsIB )

			return 1

		else
			return 0
		ok

	def IsBeforeManyPositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeManyPositionsIB )

			return 1

		else
			return 0
		ok

	def IsBeforeThesePositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeThesePositionsIB )

			return 1

		else
			return 0
		ok

	def IsBeforeSubStringIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeSubStringIB )

			return 1

		else
			return 0
		ok

	def IsBeforeThisSubStringIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeThisSubStringIB )

			return 1

		else
			return 0
		ok

	def IsBeforeSubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeSubStringsIB )

			return 1

		else
			return 0
		ok

	def IsBeforeTheseSubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeTheseSubStringsIB )

			return 1

		else
			return 0
		ok

	def IsBeforeItemIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeItemIB )

			return 1

		else
			return 0
		ok

	def IsBeforeThisItemIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeThisItemIB )

			return 1

		else
			return 0
		ok

	def IsBeforeItemsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeItemsIB )

			return 1

		else
			return 0
		ok

	def IsBeforeTheseItemsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeTheseItemsIB )

			return 1

		else
			return 0
		ok

#--

	def IsAfterPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterPositionIB )

			return 1

		else
			return 0
		ok

	def IsAfterThisPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterThisPositionIB )

			return 1

		else
			return 0
		ok

	def IsAfterPositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterPositionsIB )

			return 1

		else
			return 0
		ok

	def IsAfterThesePositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterThesePositionsIB )

			return 1

		else
			return 0
		ok

	def IsAfterSubStringIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterSubStringIB )

			return 1

		else
			return 0
		ok

	def IsAfterThisSubStringIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterThisSubStringIB )

			return 1

		else
			return 0
		ok

	def IsAfterSubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterSubStringsIB )

			return 1

		else
			return 0
		ok

	def IsAfterTheseSubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterTheseSubStringsIB )

			return 1

		else
			return 0
		ok

	def IsAfterItemIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterItemIB )

			return 1

		else
			return 0
		ok

	def IsAfterThisItemIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterThisItemIB )

			return 1

		else
			return 0
		ok

	def IsAfterItemsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterItemsIB )

			return 1

		else
			return 0
		ok

	def IsAfterTheseItemsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterTheseItemsIB )

			return 1

		else
			return 0
		ok

	def IsAroundPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundPositionIB )

			return 1

		else
			return 0
		ok

	def IsAroundThisPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundThisPositionIB )

			return 1

		else
			return 0
		ok

	def IsAroundPositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundPositionsIB )

			return 1

		else
			return 0
		ok

	def IsAroundThesePositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundThesePositionsIB )

			return 1

		else
			return 0
		ok

	def IsAroundSubStringIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundSubStringIB )

			return 1

		else
			return 0
		ok

	def IsAroundThisSubStringIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundThisSubStringIB )

			return 1

		else
			return 0
		ok

	def IsAroundSubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundSubStringsIB )

			return 1

		else
			return 0
		ok

	def IsAroundTheseSubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundTheseSubStringsIB )

			return 1

		else
			return 0
		ok

	def IsAroundItemIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundItemIB )

			return 1

		else
			return 0
		ok

	def IsAroundThisItemIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundThisItemIB )

			return 1

		else
			return 0
		ok

	def IsAroundItemsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundItemsIB )

			return 1

		else
			return 0
		ok

	def IsAroundTheseItemsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundtheseItemsIB )

			return 1

		else
			return 0
		ok

	#--

	def IsAtCharsNamedParam()
		if This.NumberOfItems() = 2 and
		    isString(This.Item(1)) and  This.Item(1) = :AtChars

			return 1

		else
			return 0
		ok

	def IsAtTheseCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :AtTheseChars

			return 1

		else
			return 0
		ok

	def IsAtManyCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :AtManyChars

			return 1

		else
			return 0
		ok

	#--

	def IsAtNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :AtNumber

			return 1

		else
			return 0
		ok

	def IsAtThisNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :AtThisNumber

			return 1

		else
			return 0
		ok

	def IsAtNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :AtNumbers

			return 1

		else
			return 0
		ok

	def IsAtTheseNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :AtTheseNumbers

			return 1

		else
			return 0
		ok

	def IsAtManyNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :AtManyNumbers

			return 1

		else
			return 0
		ok

	#--

	def IsAtListNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :AtList

			return 1

		else
			return 0
		ok

	def IsAtThisListNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :AtThisList

			return 1

		else
			return 0
		ok

	def IsAtListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtLists )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseLists )

			return 1

		else
			return 0
		ok

	def IsAtManyListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyLists )

			return 1

		else
			return 0
		ok

	#--

	def IsAtSubListNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSubList )

			return 1

		else
			return 0
		ok

	def IsAtThisSubListNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisSubList )

			return 1

		else
			return 0
		ok

	def IsAtSubListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSubLists )

			return 1

		else
			return 0
		ok

	def IsAtTheseSubListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseSubLists )

			return 1

		else
			return 0
		ok

	def IsAtManySubListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManySubLists )

			return 1

		else
			return 0
		ok

	#--

	def IsAtPairNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtPair )

			return 1

		else
			return 0
		ok

	def IsAtThisPairNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisPair )

			return 1

		else
			return 0
		ok

	def IsAtPairsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtPairs )

			return 1

		else
			return 0
		ok

	def IsAtThesePairsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThesePairs )

			return 1

		else
			return 0
		ok

	def IsAtManyPairsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyPairs )

			return 1

		else
			return 0
		ok

	#--

	def IsAtListOfNumbersNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfNumbers )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfNumbersNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfNumbers )

			return 1

		else
			return 0
		ok

	def IsAtListsOfNumbersNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfNumbers )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfNumbersNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfNumbers )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfNumbersNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfNumbers )

			return 1

		else
			return 0
		ok

	#--

	def IsAtListOfCharsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfChars )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfCharsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfChars )

			return 1

		else
			return 0
		ok

	def IsAtListsOfCharsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfChars )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfCharsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfChars )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfCharsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfChars )

			return 1

		else
			return 0
		ok

	#--

	def IsAtListOfStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfStrings )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfStrings )

			return 1

		else
			return 0
		ok

	def IsAtListsOfStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfStrings )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfStrings )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfStringsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfStrings )

			return 1

		else
			return 0
		ok

	#--

	def IsAtListOfListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfLists )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfLists )

			return 1

		else
			return 0
		ok

	def IsAtListsOfListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfLists )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfLists )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfLists )

			return 1

		else
			return 0
		ok

	#--

	def IsAtListOfSubListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfSubLists )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfSubListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfSubLists )

			return 1

		else
			return 0
		ok

	def IsAtListsOfSubListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfSubLists )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfSubListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfSubLists )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfSubListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfSubLists )

			return 1

		else
			return 0
		ok

	#--

	def IsAtListOfPairsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfPairs )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfPairsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfPairs )

			return 1

		else
			return 0
		ok
	def IsAtListsOfPairsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfPairs )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfPairsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfPairs )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfPairsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfPairs )

			return 1

		else
			return 0
		ok

	#--

	def IsAtListOfHashListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfHashLists )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfHashListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfHashLists )

			return 1

		else
			return 0
		ok

	def IsAtListsOfHashListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfHashLists )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfHashListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfHashLists )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfHashListsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfHashLists )

			return 1

		else
			return 0
		ok

	#--

	def IsAtObjectNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtObject )

			return 1

		else
			return 0
		ok

	def IsAtThisObjectNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisObject )

			return 1

		else
			return 0
		ok

	def IsAtObjectsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtObjects )

			return 1

		else
			return 0
		ok

	def IsAtTheseObjectsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseObjects )

			return 1

		else
			return 0
		ok

	def IsAtManyObjectsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyObjects )

			return 1

		else
			return 0
		ok

	#--

	def IsAtSectionNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSection )

			return 1

		else
			return 0
		ok

	def IsAtSectionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSectionIB )

			return 1

		else
			return 0
		ok

	def IsAtThisSectionNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisSection )

			return 1

		else
			return 0
		ok

	def IsAtThisSectionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisSectionIB )

			return 1

		else
			return 0
		ok

	def IsAtSectionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSections )

			return 1

		else
			return 0
		ok

	def IsAtSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtSectionsIB )

			return 1

		else
			return 0
		ok

	def IsAtTheseSectionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseSections )

			return 1

		else
			return 0
		ok

	def IsAtTheseSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseSectionsIB )

			return 1

		else
			return 0
		ok

	def IsAtManySectionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManySections )

			return 1

		else
			return 0
		ok

	def IsAtManySectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManySectionsIB )

			return 1

		else
			return 0
		ok

	#--

	def IsAtListOfSectionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfSections )

			return 1

		else
			return 0
		ok

	def IsAtListOfSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfSectionsIB )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfSectionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfSections )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfSectionsIB )

			return 1

		else
			return 0
		ok

	def IsAtListsOfSectionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfSections )

			return 1

		else
			return 0
		ok

	def IsAtListsOfSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfSectionsIB )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfSectionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfSections )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfSectionsIB )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfSectionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfSections )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfSectionsIB )

			return 1

		else
			return 0
		ok

	#--

	#TODO // Reorganise them near to IsBeforeSectionNamedParam()

	def IsBeforeSectionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeSectionIB )

			return 1

		else
			return 0
		ok

	def IsBeforeSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :BeforeSectionsIB )

			return 1

		else
			return 0
		ok

	#--

	#TODO // Reorganise them near to IsBeforeSectionNamedParam()

	def IsAfterSectionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterSectionIB )

			return 1

		else
			return 0
		ok

	def IsAfterSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AfterSectionsIB )

			return 1

		else
			return 0
		ok

	#--

	def IsAroundSectionNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundSection )

			return 1

		else
			return 0
		ok

	def IsAroundSectionIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundSectionIB )

			return 1

		else
			return 0
		ok

	def IsAroundSectionsNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundSections )

			return 1

		else
			return 0
		ok

	def IsAroundSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AroundSectionsIB )

			return 1

		else
			return 0
		ok

	#--

	def IsAtRangeNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtRange )

			return 1

		else
			return 0
		ok

	def IsAtThisRangeNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisRange )

			return 1

		else
			return 0
		ok

	def IsAtRangesNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtRanges )

			return 1

		else
			return 0
		ok

	def IsAtTheseRangesNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseRanges )

			return 1

		else
			return 0
		ok

	def IsAtManyRangesNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyRanges )

			return 1

		else
			return 0
		ok

	#--

	def IsAtListOfRangesNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListOfRanges )

			return 1

		else
			return 0
		ok

	def IsAtThisListOfRangesNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtThisListOfRanges )

			return 1

		else
			return 0
		ok

	def IsAtListsOfRangesNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtListsOfRanges )

			return 1

		else
			return 0
		ok

	def IsAtTheseListsOfRangesNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtTheseListsOfRanges )

			return 1

		else
			return 0
		ok

	def IsAtManyListsOfRangesNamedParam()
		if This.NumberOfItems() = 2 and
			( isString(This.Item(1)) and  This.Item(1) = :AtManyListsOfRanges )

			return 1

		else
			return 0
		ok


	#==

	def IsUsingOrAtOrWhereNamedParam()
		# Use IsOneOfTheseNamedParams([ ..., ..., ... ]) instead

		if This.IsUsingNamedParam() or
		   This.IsAtNamedParam() or
		   This.IsWhereNamedParam()

			return 1
		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def IsUsingOrWhereOrAtNamedParam()
			return This.IsUsingOrAtOrWhereNamedParam()
		
		def IsAtOrUsingOrWhereNamedParam()
			return This.IsUsingOrAtOrWhereNamedParam()
	
		def IsAtOrWhereOrUsingNamedParam()
			return This.IsUsingOrAtOrWhereNamedParam()

		def IsWhereOrAtOrUsingNamedParam()
			return This.IsUsingOrAtOrWhereNamedParam()
	
		def IsWhereOrUsingOrAtNamedParam()
			return This.IsUsingOrAtOrWhereNamedParam()

		#--

		def IsUsingOrWhereOrAtNamedParams()
			return This.IsUsingOrAtOrWhereNamedParam()
		
		def IsAtOrUsingOrWhereNamedParams()
			return This.IsUsingOrAtOrWhereNamedParam()
	
		def IsAtOrWhereOrUsingNamedParams()
			return This.IsUsingOrAtOrWhereNamedParam()

		def IsWhereOrAtOrUsingNamedParams()
			return This.IsUsingOrAtOrWhereNamedParam()
	
		def IsWhereOrUsingOrAtNamedParams()
			return This.IsUsingOrAtOrWhereNamedParam()

		def IsUsingOrAtOrWhereNamedParams()
			return This.IsUsingOrAtOrWhereNamedParam()

		#>

	def IsUsingOrAtOrWhereXTNamedParam()
		# Use IsOneOfTheseNamedParams([ ..., ..., ... ]) instead

		if This.IsUsingNamedParam() or
		   This.IsAtNamedParam() or
		   This.IsWhereXTNamedParam()

			return 1
		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def IsUsingOrWhereXTOrAtNamedParam()
			return This.IsUsingOrAtOrWhereXTNamedParam()
		
		def IsAtOrUsingOrWhereXTNamedParam()
			return This.IsUsingOrAtOrWhereXTNamedParam()
	
		def IsAtOrWhereXTOrUsingNamedParam()
			return This.IsUsingOrAtOrWhereXTNamedParam()

		def IsWhereXTOrAtOrUsingNamedParam()
			return This.IsUsingOrAtOrWhereXTNamedParam()
	
		def IsWhereXTOrUsingOrAtNamedParam()
			return This.IsUsingOrAtOrWhereXTNamedParam()

		#--

		def IsUsingOrWhereXTOrAtNamedParams()
			return This.IsUsingOrAtOrWhereXTNamedParam()
		
		def IsAtOrUsingOrWhereXTNamedParams()
			return This.IsUsingOrAtOrWhereXTNamedParam()
	
		def IsAtOrWhereXTOrUsingNamedParams()
			return This.IsUsingOrAtOrWhereXTNamedParam()

		def IsWhereXTOrAtOrUsingNamedParams()
			return This.IsUsingOrAtOrWhereXTNamedParam()
	
		def IsWhereXTOrUsingOrAtNamedParams()
			return This.IsUsingOrAtOrWhereXTNamedParam()

		def IsUsingOrAtOrWhereXTNamedParams()
			return This.IsUsingOrAtOrWhereXTNamedParam()

		#>
	#==

	def IsStepNamedParam()

		if This.NumberOfItems() = 2 and

		   isString(This.Item(1)) and
		   This.Item(1) = :Step
		  
			return 1

		else
			return 0
		ok

	def IsNameNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Name ) and
		   isString(This.Item(2))
		  
			return 1

		else
			return 0
		ok

	def IsNamedNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Named ) and
		   isString(This.Item(2))
		  
			return 1

		else
			return 0
		ok

	def IsNamedAsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :NamedAs ) and
		   isString(This.Item(2))
		  
			return 1

		else
			return 0
		ok

	def IsRaiseNamedParam()
		if This.NumberOfItems() <= 4 and
		   This.IsHashList() and
		   This.ToStzHashList().KeysQ().IsMadeOfSome([ :Where, :What, :Why, :Todo ]) and
		   This.ToStzHashList().ValuesQ().CheckWXT("isString(@item) and @item != ''")

			return 1

		else
			return 0
		ok

	def IsReturnedAsNamedParam()

		if This.NumberOfItems() = 2 and This.Item(1) = :ReturnedAs

			return 1

		else
			return 0
		ok

	def IsAndReturnedAsNamedParam()

		if This.NumberOfItems() = 2 and This.Item(1) = :AndReturnedAs

			return 1

		else
			return 0
		ok

	def IsReturnNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :Return

			return 1

		else
			return 0
		ok

	def IsReturnAsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :ReturnAs

			return 1

		else
			return 0
		ok

	def IsAndReturnAsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :AndReturnAs

			return 1

		else
			return 0
		ok

	def IsReturnItAsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :ReturnItAs

			return 1

		else
			return 0
		ok

	def IsAndReturnItAsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :AndReturnItAs

			return 1

		else
			return 0
		ok

	def IsReturnThemAsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :ReturnThemAs

			return 1

		else
			return 0
		ok

	def IsAndReturnThemAsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :AndReturnThemAs

			return 1

		else
			return 0
		ok

	def IsReturningNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and StzLower(This.Item(1)) = "returning"
			return 1
		else
			return 0
		ok

	def IsAndReturnNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and StzLower(This.Item(1)) = "andreturn"
			return 1
		else
			return 0
		ok

	def IsAndReturningNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and StzLower(This.Item(1)) = "andreturning"
			return 1
		else
			return 0
		ok

	def IsReturnNthNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and StzLower(This.Item(1)) = "returnnth"
			return 1
		else
			return 0
		ok

	def IsReturningNthNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and StzLower(This.Item(1)) = "returningnth"
			return 1
		else
			return 0
		ok

	def IsAndReturnNthNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and StzLower(This.Item(1)) = "andreturnnth"
			return 1
		else
			return 0
		ok

	def IsAndReturningNthNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and StzLower(This.Item(1)) = "andreturningnth"
			return 1
		else
			return 0
		ok

	def IsUpToNCharsNamedParam()
		if This.NumberOfItems() = 2 and
 		   isString(This.Item(1)) and  This.Item(1) = :UpToNChars
		  
			return 1

		else
			return 0
		ok

	def IsUpToNItemsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
 		   ( isString(This.Item(1)) and  This.Item(1) = :UpToNItems )
		  
			return 1

		else
			return 0
		ok

	def IsUpToOrUpToNItemsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
 		   ( isString(This.Item(1)) and
			(This.Item(1) = :UpToNItems or This.Item(1) = :UpTo) )
		  
			return 1

		else
			return 0
		ok

		def IsUpToOrUpToNItemsNamedParams()
			return This.IsUpToOrUoToNItemsNamedParam()

		def IsUpToNItemsOrUpToNamedParam()
			return This.IsUpToOrUoToNItemsNamedParam()

		def IsUpToNItemsOrUpToNamedParams()
			return This.IsUpToOrUoToNItemsNamedParam()

	def IsUpToOrUpToNPositionsNamedParam()
		if ( This.NumberOfPositions() = 2 ) and
 		   ( isString(This.Position(1)) and
			(This.Position(1) = :UpToNPositions or This.Position(1) = :UpTo) )
		  
			return 1

		else
			return 0
		ok

		def IsUpToOrUpToNPositionsNamedParams()
			return This.IsUpToOrUoToNPositionsNamedParam()

		def IsUpToNPositionsOrUpToNamedParam()
			return This.IsUpToOrUoToNPositionsNamedParam()

		def IsUpToNPositionsOrUpToNamedParams()
			return This.IsUpToOrUoToNPositionsNamedParam()

	def IsBeforeNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :Before )

			return 1
		else
			return 0
		ok

	def IsBeforeItemNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeItem )

			return 1
		else
			return 0
		ok

	def IsBeforeItemsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeItems )

			return 1
		else
			return 0
		ok

	def IsBeforeThisItemNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeThisItem )

			return 1
		else
			return 0
		ok

	def IsBeforeTheseItemsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeTheseItems )

			return 1
		else
			return 0
		ok

	#--

	def IsBeforePositionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforePosition )

			return 1
		else
			return 0
		ok

	def IsBeforeThisPositionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeThisPosition )

			return 1
		else
			return 0
		ok

	def IsBeforePositionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforePositions )

			return 1
		else
			return 0
		ok

	def IsBeforeManyPositionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeManyPositions )

			return 1
		else
			return 0
		ok

	def IsBeforeThesePositionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeThesePositions )

			return 1
		else
			return 0
		ok

	#--

	def IsBeforeSubStringNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSubString )

			return 1
		else
			return 0
		ok

	def IsBeforeThisSubStringNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeThisSubString )

			return 1
		else
			return 0
		ok

	def IsBeforeSubStringsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSubStrings )

			return 1
		else
			return 0
		ok

	def IsBeforeTheseSubStringsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeTheseSubStrings )

			return 1
		else
			return 0
		ok

	def IsBeforeSubStringPositionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSubStringPosition )

			return 1
		else
			return 0
		ok

	def IsBeforeThisSubStringPositionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeThisSubStringPosition )

			return 1
		else
			return 0
		ok

	def IsBeforeSubStringsPositionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSubStringsPositions )

			return 1
		else
			return 0
		ok

	def IsBeforeTheseSubStringsPositionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeTheseSubStringsPositions )

			return 1
		else
			return 0
		ok

	#--

	def IsAfterSubStringNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterSubString )

			return 1
		else
			return 0
		ok

	def IsAfterThisSubStringNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterThisSubString )

			return 1
		else
			return 0
		ok

	def IsAfterSubStringsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterSubStrings )

			return 1
		else
			return 0
		ok

	def IsAfterTheseSubStringsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterTheseSubStrings )

			return 1
		else
			return 0
		ok

	def IsAfterSubStringPositionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterSubStringPosition )

			return 1
		else
			return 0
		ok

	def IsAfterThisSubStringPositionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterThisSubStringPosition )

			return 1
		else
			return 0
		ok

	def IsAfterSubStringsPositionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterSubStringsPositions )

			return 1
		else
			return 0
		ok

	def IsAfterTheseSubStringsPositionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterTheseSubStringsPositions )

			return 1
		else
			return 0
		ok

	#--

	def IsBeforeSectionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSection )

			return 1
		else
			return 0
		ok

	def IsBeforeThisSectionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeThisSection )

			return 1
		else
			return 0
		ok

	def IsBeforeSectionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSections )

			return 1
		else
			return 0
		ok

	def IsBeforeTheseSectionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeTheseSections )

			return 1
		else
			return 0
		ok

	#--

	def IsAfterSectionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterSection )

			return 1
		else
			return 0
		ok

	def IsAfterThisSectionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterThisSection )

			return 1
		else
			return 0
		ok

	def IsAfterSectionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterSections )

			return 1
		else
			return 0
		ok

	def IsAfterTheseSectionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterTheseSections )

			return 1
		else
			return 0
		ok

	#--

	def IsBeforeOrAtNamedParam()
		if This.IsBeforeNamedParam() or This.IsAtNamedParam()
			return 1
		else
			return 0
		ok

		def IsAtOrBeforeNamedParam()
			return This.IsBeforeOrAtNamedParam()

	def IsAfterNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :After )

			return 1
		else
			return 0
		ok

	def IsAfterTheseNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterThese )

			return 1
		else
			return 0
		ok

	def IsAfterManyNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterMany )

			return 1
		else
			return 0
		ok

	def IsAfterItemNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterItem )

			return 1
		else
			return 0
		ok

	def IsAfterItemsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterItems )

			return 1
		else
			return 0
		ok

	def IsAfterThisItemNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterThisItem )

			return 1
		else
			return 0
		ok

	def IsAfterTheseItemsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterTheseItems )

			return 1
		else
			return 0
		ok

	def IsAfterPositionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterPosition )

			return 1
		else
			return 0
		ok

	def IsAfterThisPositionNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterThisPosition )

			return 1
		else
			return 0
		ok

	def IsAfterPositionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterPositions )

			return 1
		else
			return 0
		ok

	def IsAfterThesePositionsNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterThesePositions )

			return 1
		else
			return 0
		ok

	def IsAfterOrAtNamedParam()
		if This.IsAfterNamedParam() or This.IsAtNamedParam()
			return 1
		else
			return 0
		ok

		def IsAtOrAfterNamedParam()
			return This.IsAfterOrAtNamedParam()

	def IsBeforeOrAfterNamedParam()
		if This.IsBeforeNamedPAram() or This.IsAfterNamedParam()
			return 1
		else
			return 0
		ok

		def IsAfterOrBeforeNamedParam()
			return This.IsBeforeOrAfterNamedParam()

	def IsWidthNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Width )

			return 1

		else
			return 0
		ok

	def IsWithOrUsingNamedParam()
		if This.IsWithNamedParam() or This.IsUsingNamedParam()
			return 1
		else
			return 0
		ok

		def IsWithOrUsingNamedParams()
			return This.IsWithOrUsingNamedParam()

		def IsUsingOrWithNamedParam()
			return This.IsWithOrUsingNamedParam()

		def IsUsingOrWithNamedParams()
			return This.IsWithOrUsingNamedParam()

	def IsMadeOfNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :MadeOf )

			return 1

		else
			return 0
		ok

	def IsNthTofirstNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :NthToFirst )

			return 1

		else
			return 0
		ok

	def IsNthToFirstCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :NthToFirstChar )

			return 1

		else
			return 0
		ok

	def IsNthToFirstItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :NthToFirstItem )

			return 1

		else
			return 0
		ok

	def IsNthToLastNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :NthToLast )

			return 1

		else
			return 0
		ok

	def IsNthToLastCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :NthToLastChar )

			return 1

		else
			return 0
		ok

	def IsNthToLastItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :NthToLastItem )

			return 1

		else
			return 0
		ok

	def IsStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :String )

			return 1

		else
			return 0
		ok

	def IsThisStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisString )

			return 1

		else
			return 0
		ok

	#--

	def IsNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Number )

			return 1

		else
			return 0
		ok

	def IsThisNumberNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisNumber )

			return 1

		else
			return 0
		ok

	def IsNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Numbers )

			return 1

		else
			return 0
		ok

	def IsTheseNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseNumbers )

			return 1

		else
			return 0
		ok

	#--

	def IsCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Char )

			return 1

		else
			return 0
		ok

	def IsThisCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisChar )

			return 1

		else
			return 0
		ok

	def IsCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Chars )

			return 1

		else
			return 0
		ok

	def IsTheseCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseChars )

			return 1

		else
			return 0
		ok

	#--

	def IsThisItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisItem )

			return 1

		else
			return 0
		ok

	def IsTheseItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseItems )

			return 1

		else
			return 0
		ok

	def IsThisListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisList )

			return 1

		else
			return 0
		ok

	def IsTheseListsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseLists )

			return 1

		else
			return 0
		ok

	def IsThisObjectNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisObject )

			return 1

		else
			return 0
		ok

	def IsTheseObjectsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseObjects )

			return 1

		else
			return 0
		ok

	#--

	def IsItemNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Item )

			return 1

		else
			return 0
		ok

	def IsItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Items )

			return 1

		else
			return 0
		ok

	def IsItemAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ItemAt )

			return 1

		else
			return 0
		ok

	def IsItemsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Items )

			return 1

		else
			return 0
		ok

	def IsItemAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ItemAtPosition )

			return 1

		else
			return 0
		ok

	def IsItemsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ItemsAtPosition )

			return 1

		else
			return 0
		ok

	def IsStringsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Strings )

			return 1

		else
			return 0
		ok

	def IsTheseStringsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseStrings )

			return 1

		else
			return 0
		ok

	def IsStringAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StringAt )

			return 1

		else
			return 0
		ok

	def IsThisStringAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisStringAt )

			return 1

		else
			return 0
		ok

	def IsStringAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StringAtPosition )

			return 1

		else
			return 0
		ok

	def IsStringAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StringAtPositions )

			return 1

		else
			return 0
		ok

	def IsItemAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ItemAtPositions )

			return 1

		else
			return 0
		ok

	def IsItemsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ItemsAtPositions )

			return 1

		else
			return 0
		ok

	def IsCharAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :CharAtPositions )

			return 1

		else
			return 0
		ok

	def IsCharsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :CharsAtPositions )

			return 1

		else
			return 0
		ok

	def IsSubStringAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :SubStringAt )

			return 1

		else
			return 0
		ok

	def IsThisSubStringAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ThisSubStringAt )

			return 1

		else
			return 0
		ok

	def IsSubStringsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :SubStringsAt )

			return 1

		else
			return 0
		ok

	def IsTheseSubStringsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseSubStringsAt )

			return 1

		else
			return 0
		ok

	def IsSubStringAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :SubStringAtPosition )

			return 1

		else
			return 0
		ok

	def IsSubStringsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :SubStringsAtPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Between )

			return 1

		else
			return 0
		ok

	def IsBetweenXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenXT )

			return 1

		else
			return 0
		ok	

	def IsBetweenIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenIB )

			return 1

		else
			return 0
		ok

	def IsBetweenIBSNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenIBS )

			return 1

		else
			return 0
		ok

	def IsBetweenSNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenS )

			return 1

		else
			return 0
		ok

	def IsBetweenCSNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenCS )

			return 1

		else
			return 0
		ok

	def IsBetweenPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenPositionIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenPositionIB )

			return 1

		else
			return 0
		ok

	def IsBetweenPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenPositions )

			return 1

		else
			return 0
		ok

	def IsBetweenPositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenPositionsIB )

			return 1

		else
			return 0
		ok

	#--

	def IsBetweenRowNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenRow )

			return 1

		else
			return 0
		ok

	def IsBetweenRowAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenRowAt )

			return 1

		else
			return 0
		ok

	def IsBetweenRowAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenRowAtPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenRowsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenRowsAtPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenRowsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenRowsAtPositions )

			return 1

		else
			return 0
		ok

	def IsBetweenRowsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenRows )

			return 1

		else
			return 0
		ok

	def IsBetweenRowsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenRowsAt )

			return 1

		else
			return 0
		ok

	#--

	def IsBetweenColNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenCol )

			return 1

		else
			return 0
		ok

		def IsBetweenColumnNamedParam()
			if This.NumberOfItems() = 2 and
			   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColumn )
	
				return 1
	
			else
				return 0
			ok

	def IsBetweenColAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColAt )

			return 1

		else
			return 0
		ok

		def IsBetweenColumnAtNamedParam()
			if This.NumberOfItems() = 2 and
			   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColumnAt )
	
				return 1
	
			else
				return 0
			ok

	def IsBetweenColAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColAtPosition )

			return 1

		else
			return 0
		ok

		def IsBetweenColumnAtPositionNamedParam()
			if This.NumberOfItems() = 2 and
			   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColumnAtPosition )
	
				return 1
	
			else
				return 0
			ok
	
	def IsBetweenColsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColsAtPosition )

			return 1

		else
			return 0
		ok

		def IsBetweenColumnsAtPositionNamedParam()
			if This.NumberOfItems() = 2 and
			   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColumnsAtPosition )
	
				return 1
	
			else
				return 0
			ok

	def IsBetweenColsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColsAtPositions )

			return 1

		else
			return 0
		ok

		def IsBetweenColumnsAtPositionsNamedParam()
			if This.NumberOfItems() = 2 and
			   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColumnsAtPositions )
	
				return 1
	
			else
				return 0
			ok

	def IsBetweenColsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenCols )

			return 1

		else
			return 0
		ok

		def IsBetweenColumnsNamedParam()
			if This.NumberOfItems() = 2 and
			   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColumns )
	
				return 1
	
			else
				return 0
			ok

	def IsBetweenColsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColsAt )

			return 1

		else
			return 0
		ok

		def IsBetweenColumnsAtNamedParam()
			if This.NumberOfItems() = 2 and
			   ( isString(This.Item(1)) and  This.Item(1) = :BetweenColumnsAt )
	
				return 1
	
			else
				return 0
			ok

	#--

	def IsFromPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromPositions )

			return 1

		else
			return 0
		ok

	def IsToPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToPositions )

			return 1

		else
			return 0
		ok

	#--

	def IsItemFromPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ItemFromPosition )

			return 1

		else
			return 0
		ok

	def IsItemsFromPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ItemsFromPosition )

			return 1

		else
			return 0
		ok

	def IsItemFromNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ItemFrom )

			return 1

		else
			return 0
		ok

	def IsItemsFromNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ItemsFrom )

			return 1

		else
			return 0
		ok

	def IsBetweenItemAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenItemAt )

			return 1

		else
			return 0
		ok

	def IsFromItemAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromItemAt )

			return 1

		else
			return 0
		ok

	def IsToItemAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToItemAt )

			return 1

		else
			return 0
		ok

	def IsBetweenItemsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenItemsAt )

			return 1

		else
			return 0
		ok

	def IsFromItemsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromItemsAt )

			return 1

		else
			return 0
		ok

	def IsToItemsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToItemsAt )

			return 1

		else
			return 0
		ok

	def IsBetweenItemAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenItemAtPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenItemsAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenItemsAtPosition )

			return 1

		else
			return 0
		ok

	def IsFromItemAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromItemAtPosition )

			return 1

		else
			return 0
		ok

	def IsFromItemsAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromItemsAtPosition )

			return 1

		else
			return 0
		ok

	def IsToItemAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToItemAtPosition )

			return 1

		else
			return 0
		ok

	def IsToItemsAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToItemsAtPosition )

			return 1

		else
			return 0
		ok


	def IsBetweenItemNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenItem )

			return 1

		else
			return 0
		ok

	def IsBetweenItemsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenItems )

			return 1

		else
			return 0
		ok

	def IsBetweenItemAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenItemAtPositions )

			return 1

		else
			return 0
		ok

	def IsToItemAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToItemAtPositions )

			return 1

		else
			return 0
		ok

	def IsFromItemAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromItemAtPositions )

			return 1

		else
			return 0
		ok

	def IsFromItemPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromItemPosition )

			return 1

		else
			return 0
		ok

	#--

	def IsStringFromPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StringFromPosition )

			return 1

		else
			return 0
		ok

	def IsStringsFromPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StringsFromPosition )

			return 1

		else
			return 0
		ok

	def IsStringFromNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StringFrom )

			return 1

		else
			return 0
		ok

	def IsStringsFromNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StringsFrom )

			return 1

		else
			return 0
		ok

	def IsFromStringPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromStringPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenStringNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenString )

			return 1

		else
			return 0
		ok

	def IsBetweenStringsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenStrings )

			return 1

		else
			return 0
		ok

	def IsBetweenStringAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenStringAt )

			return 1

		else
			return 0
		ok

	def IsToStringAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToStringAt )

			return 1

		else
			return 0
		ok

	def IsFromStringAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromStringAt )

			return 1

		else
			return 0
		ok

	def IsBetweenStringAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenStringAtPosition )

			return 1

		else
			return 0
		ok

	def IsFromStringAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromStringAtPosition )

			return 1

		else
			return 0
		ok

	def IsToStringAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToStringAtPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenStringAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenStringAtPositions )

			return 1

		else
			return 0
		ok

	def IsFromStringAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromStringAtPositions )

			return 1

		else
			return 0
		ok

	def IsToStringAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToStringAtPositions )

			return 1

		else
			return 0
		ok

	#--

	def IsCharFromPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :CharFromPosition )

			return 1

		else
			return 0
		ok

	def IsCharsFromPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :CharsFromPosition )

			return 1

		else
			return 0
		ok

	def IsCharFromNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :CharFrom )

			return 1

		else
			return 0
		ok

	def IsCharsFromNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :CharsFrom )

			return 1

		else
			return 0
		ok

	def IsFromCharPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCharPosition )

			return 1

		else
			return 0
		ok

	def IsCharAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :CharAt )

			return 1

		else
			return 0
		ok

	def IsCharAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :CharAtPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenChar )

			return 1

		else
			return 0
		ok

	def IsBetweenCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenChars )

			return 1

		else
			return 0
		ok

	def IsBetweenCharAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenCharAt )

			return 1

		else
			return 0
		ok

	def IsFromCharAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCharAt )

			return 1

		else
			return 0
		ok

	def IsFirstPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FirstPosition )

			return 1

		else
			return 0
		ok

	def IsLastPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :LastPosition )

			return 1

		else
			return 0
		ok

	def IsToCharAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCharAt )

			return 1

		else
			return 0
		ok

	def IsBetweenCharsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenCharsAt )

			return 1

		else
			return 0
		ok

	def IsBetweenCharsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenCharsAtPosition )

			return 1

		else
			return 0
		ok

	def IsFromCharsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCharsAt )

			return 1

		else
			return 0
		ok

	def IsToCharsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCharsAt )

			return 1

		else
			return 0
		ok

	def IsBetweenCharAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenCharAtPosition )

			return 1

		else
			return 0
		ok

	def IsFromCharAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCharAtPosition )

			return 1

		else
			return 0
		ok

	def IsToCharAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCharAtPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenCharAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenCharAtPositions )

			return 1

		else
			return 0
		ok

	def IsToCharAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToCharAtPositions )

			return 1

		else
			return 0
		ok

	def IsFromCharAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromCharAtPositions )

			return 1

		else
			return 0
		ok

	#--

	def IsStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Strings )

			return 1

		else
			return 0
		ok

	def IsTheseStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseStrings )

			return 1

		else
			return 0
		ok

	def IsStringsAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StringsAtPosition )

			return 1

		else
			return 0
		ok

	def IsTheseStringsAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :theseStringsAtPosition )

			return 1

		else
			return 0
		ok

	def IsStringsAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :StringsAtPositions )

			return 1

		else
			return 0
		ok

	def IsTheseStringsAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseStringsAtPositions )

			return 1

		else
			return 0
		ok

	def IsFromStringsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromStrings )

			return 1

		else
			return 0
		ok

	def IsToStringsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToStrings )

			return 1

		else
			return 0
		ok

	def IsBetweenStringsAtNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenStringsAt )

			return 1

		else
			return 0
		ok

	def IsFromStringsAtNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromStringsAt )

			return 1

		else
			return 0
		ok

	def IsToStringsAtNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToStringsAt )

			return 1

		else
			return 0
		ok

	def IsBetweenStringsAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenStringsAtPosition )

			return 1

		else
			return 0
		ok

	def IsFromStringsAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromStringsAtPosition )

			return 1

		else
			return 0
		ok

	def IsToStringsAtPositionNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToStringsAtPosition )

			return 1

		else
			return 0
		ok

	def IsBetweenStringsAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :BetweenStringsAtPositions )

			return 1

		else
			return 0
		ok

	def IsFromStringsAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :FromStringsAtPositions )

			return 1

		else
			return 0
		ok

	def IsToStringsAtPositionsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToStringsAtPositions )

			return 1

		else
			return 0
		ok

	#--

	def IsAndColNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndCol )

			return 1

		else
			return 0
		ok

	def IsAndColumnNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndColumn )

			return 1

		else
			return 0
		ok

	def IsAndColAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndColat )

			return 1

		else
			return 0
		ok

	def IsAndColumnAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndColumnAt )

			return 1

		else
			return 0
		ok

	def IsAndColAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndColAtPosition )

			return 1

		else
			return 0
		ok

	def IsAndColumnAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndColumnAtPosition )

			return 1

		else
			return 0
		ok

	def IsAndColNamedNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndColNamed )

			return 1

		else
			return 0
		ok

	def IsAndColumnNamedNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndColumnNamed )

			return 1

		else
			return 0
		ok

	def IsColsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Cols )

			return 1

		else
			return 0
		ok

	def IsColumnsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Columns )

			return 1

		else
			return 0
		ok

	def IsColsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ColsAtPosition )

			return 1

		else
			return 0
		ok

	def IsColumnsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ColumnsAtPosition )

			return 1

		else
			return 0
		ok

	def IsColsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ColsAtPositions )

			return 1

		else
			return 0
		ok

	def IsColumnsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ColumnsAtPositions )

			return 1

		else
			return 0
		ok

	#--

	def IsAndRowNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndRow )

			return 1

		else
			return 0
		ok

	def IsAndRowAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndRowAt )

			return 1

		else
			return 0
		ok

	def IsAndRowAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndRowAtPosition )

			return 1

		else
			return 0
		ok

	def IsRowsAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :RowsAt )

			return 1

		else
			return 0
		ok

	def IsRowsAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :RowsAtPosition )

			return 1

		else
			return 0
		ok

	def IsRowsAtPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :RowsAtPositions )

			return 1

		else
			return 0
		ok

	#--

	def IsThisNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :This )

			return 1

		else
			return 0
		ok

	def IsAndThisNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndThis )

			return 1

		else
			return 0
		ok

	def IsAndThatNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :AndThat )

			return 1

		else
			return 0
		ok

	#--

	def IsEvalNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Eval )

			return 1

		else
			return 0
		ok

	def IsEvaluateNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Evaluate )

			return 1

		else
			return 0
		ok

	def IsEvalFromNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EvalFrom )

			return 1

		else
			return 0
		ok

	def IsEvaluateFromNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EvaluateFrom )

			return 1

		else
			return 0
		ok

	def IsEvalDirectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EvalDirection )

			return 1

		else
			return 0
		ok

	def IsEvaluationDirectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :EvaluationDirection )

			return 1

		else
			return 0
		ok

	def IsOrThisNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OrThis )

			return 1

		else
			return 0
		ok

	def IsOrThatNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OrThat )

			return 1

		else
			return 0
		ok

	#--

	def IsSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :SubString )

			return 1
		else
			return 0
		ok

	def IsSubstringOrSubstringsNamedParam()
		if This.IsSubStringNamedParam() or
		   This.IsSubStringsNamedParam()

			return 1
		else
			return 0
		ok

		def IsSubStringsOrSubStringNamedParam()
			return This.IsSubstringOrSubstringsNamedParam()

		#--

		def IsSubstringOrSubstringsNamedParams()
			return This.IsSubstringOrSubstringsNamedParam()

		def IsSubStringsOrSubStringNamedParams()
			return This.IsSubstringOrSubstringsNamedParam()


	def IsThisSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ThisSubString )

			return 1
		else
			return 0
		ok

	def IsAndSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndSubString )

			return 1
		else
			return 0
		ok

	def IsBetweenSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BetweenSubString )

			return 1
		else
			return 0
		ok

	def IsBoundedBySubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BoundedBySubString )

			return 1
		else
			return 0
		ok

	def IsSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :SubStrings )

			return 1
		else
			return 0
		ok

	def IsTheseSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :TheseSubStrings )

			return 1

		else
			return 0
		ok

	def IsAndSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndSubStrings )

			return 1
		else
			return 0
		ok

	def IsOfSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfSubStrings )

			return 1
		else
			return 0
		ok

	def IsInSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InSubStrings )

			return 1
		else
			return 0
		ok

	def IsBetweenSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BetweenSubStrings )

			return 1
		else
			return 0
		ok

	def IsBetweenSubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BetweenSubStringsIB )

			return 1
		else
			return 0
		ok

	def IsBoundedBySubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BoundedBySubStrings )

			return 1
		else
			return 0
		ok

	def IsBoundedBySubStringsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BoundedBySubStringsIB )

			return 1
		else
			return 0
		ok

	#--

	def IsBoundedByNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BoundedBy )

			return 1
		else
			return 0
		ok

	def IsBoundedByIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BoundedByIB )

			return 1
		else
			return 0
		ok


	def IsIsBoundedByNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :IsBoundedBy )

			return 1
		else
			return 0
		ok

	#--

	def IsBoundsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Bounds )

			return 1
		else
			return 0
		ok

	def IsBoundsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BoundsIB )

			return 1
		else
			return 0
		ok

	def IsBoundedByOrBoundsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Bounds or This.Item(1) = :BoundedBy) )

			return 1
		else
			return 0
		ok

		def IsBoundsOrBoundedByNamedParam()
			return This.IsBoundedByOrBoundsNamedParam()

	def IsBoundedByIBOrBoundsIBNamedParam()
		if This.IsBoundedByIBNamedParam() or This.IsBoundsIBNamedParam()
			return 1
		else
			return 0
		ok

		def IsBoundsIBOrBoundedByIBNamedParam()
			return This.IsBoundedByIBOrBoundsIBNamedParam()

	#==

	def IsSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Section )

			return 1
		else
			return 0
		ok

	def IsThisSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ThisSection )

			return 1
		else
			return 0
		ok

	def IsSectionIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :SectionIB )

			return 1
		else
			return 0
		ok

	def IsThisSectionIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ThisSectionIB )

			return 1
		else
			return 0
		ok

	def IsAndSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndSection )

			return 1
		else
			return 0
		ok

	def IsOfSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfSection )

			return 1
		else
			return 0
		ok

	def IsInSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InSection )

			return 1
		else
			return 0
		ok

	def IsInSectionOrBetweenNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind(["insection", "between"], This.Item(1)) )

			return 1
		else
			return 0
		ok

		def IsBetweenOrInSectionNamedParam()
			return This.IsInSectionOrBetweenNamedParam()

	def IsSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Sections )

			return 1
		else
			return 0
		ok

	def IsTheseSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :TheseSections )

			return 1
		else
			return 0
		ok

	def IsSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :SectionsIB )

			return 1
		else
			return 0
		ok

	def IsTheseSectionsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :TheseSectionsIB )

			return 1
		else
			return 0
		ok

	def IsAndSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AndSections )

			return 1
		else
			return 0
		ok

	def IsOfSubSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OfSections )

			return 1
		else
			return 0
		ok

	def IsInSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InSections )

			return 1
		else
			return 0
		ok

	def IsSectionOrInSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :Section or This.Item(1) = :InSection) )

			return 1
		else
			return 0
		ok

	def IsSectionsOrInSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :Sections or This.Item(1) = :InSections) )

			return 1
		else
			return 0
		ok

		def IsSectionsOrInSectionsNamedParams()
			return This.IsSectionsOrInSectionsNamedParam()

	def IsToSectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToSection )

			return 1
		else
			return 0
		ok

	def IsToSectionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToSections )

			return 1
		else
			return 0
		ok

	#==

	def IsListSizeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ListSize )

			return 1
		else
			return 0
		ok

	def IsStringSizeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StringSize )

			return 1
		else
			return 0
		ok

	def IsNumberOfItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :NumberOfItems )

			return 1
		else
			return 0
		ok

	def IsNumberOfCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :NumberOfChars )

			return 1
		else
			return 0
		ok

	def IsInAListOfNItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InAListOfNItems )

			return 1
		else
			return 0
		ok

	def IsInAListOfSizeNNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InAListOfSizeN )

			return 1
		else
			return 0
		ok

	def IsInAListOfSizeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InAListOfSize )

			return 1
		else
			return 0
		ok

	def IsInAListOfNNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InAListOfN )

			return 1
		else
			return 0
		ok

	def IsInAListOfNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InAListOf )

			return 1
		else
			return 0
		ok

	def IsInAStringOfNCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InAStringOfN )

			return 1
		else
			return 0
		ok

	def IsInAStringOfSizeNNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InAStringOfSizeN )

			return 1
		else
			return 0
		ok

	def IsInListOfNItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InListOfNItems )

			return 1
		else
			return 0
		ok

	def IsInListOfSizeNNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InListOfSizeN )

			return 1
		else
			return 0
		ok

	def IsInListOfSizeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InListOfSize )

			return 1
		else
			return 0
		ok

	def IsInListOfNNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InListOfN )

			return 1
		else
			return 0
		ok

	def IsInListOfNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InListOf )

			return 1
		else
			return 0
		ok

	def IsInStringOfNCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InStringOf )

			return 1
		else
			return 0
		ok

	def IsInStringOfSizeNNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InStringOfSizeN )

			return 1
		else
			return 0
		ok

	#==

	def IsStartOrFromNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Start or This.Item(1) = :From) )

			return 1
		else
			return 0
		ok

		def IsFromOrStartNamedParam()
			return This.IsStartOrFromNamedParam()

	def IsStartNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Start )

			return 1
		else
			return 0
		ok

	def IsStartOfStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartOfString )

			return 1
		else
			return 0
		ok

	def IsStartOfListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartOfList )

			return 1
		else
			return 0
		ok

	def IsStartFromNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartFrom )

			return 1
		else
			return 0
		ok

	def IsStartsFromNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartsFrom )

			return 1
		else
			return 0
		ok

	def IsStartingFromNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartingFrom )

			return 1
		else
			return 0
		ok

	def IsEndOrToNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :End or This.Item(1) = :To) )

			return 1
		else
			return 0
		ok

		def IsToOrEndNamedParam()
			return This.IsEndOrToNamedParam()

	def IsEndNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :End )

			return 1
		else
			return 0
		ok

	def IsStopNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Stop )

			return 1
		else
			return 0
		ok

	def IsEndOfListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :EndOfList )

			return 1
		else
			return 0
		ok

	def IsEndOfStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :EndOfString )

			return 1
		else
			return 0
		ok

	#--

	def IsFromStartNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromStart )

			return 1
		else
			return 0
		ok

	def IsFromStartOfStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromStartOfString )

			return 1
		else
			return 0
		ok

	def IsFromStartOfListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromStartOfList )

			return 1
		else
			return 0
		ok


	def IsFromEndNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromEnd )

			return 1
		else
			return 0
		ok

	def IsFromEndOfListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromEndOfList )

			return 1
		else
			return 0
		ok

	def IsFromEndOfStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromEndOfString )

			return 1
		else
			return 0
		ok

	#--

	def IsStartingAtCharNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartingAtChar )

			return 1
		else
			return 0
		ok

	def IsStartingAtCharAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartingAtCharAt )

			return 1
		else
			return 0
		ok

	def IsStartingAtCharAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartingAtCharAtPosition )

			return 1
		else
			return 0
		ok

	def IsStartingAtItemNamedPAram()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartingAtItem )

			return 1
		else
			return 0
		ok

	def IsStartingAtItemAtNamedPAram()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartingAtItemAt )

			return 1
		else
			return 0
		ok

	def IsStartingAtItemAtPositionNamedPAram()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :StartingAtItemAtPosition )

			return 1
		else
			return 0
		ok

	#--

	def IsToEndNamedPAram()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToEnd )

			return 1
		else
			return 0
		ok

	def IsToEndOfStringNamedPAram()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToEndOfString )

			return 1
		else
			return 0
		ok

	def IsToEndOfListNamedPAram()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToEndOfList )

			return 1
		else
			return 0
		ok

	def IsToStartNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToStart )

			return 1
		else
			return 0
		ok

	def IsToStartofListNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToStartOfList )

			return 1
		else
			return 0
		ok

	def IsToStartofStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ToStartOfString )

			return 1
		else
			return 0
		ok

	#==

	def IsOfSizeNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :OfSize )

			return 1

		else
			return 0
		ok

	def IsSizeNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Size )

			return 1

		else
			return 0
		ok

	def IsDoNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Do )

			return 1

		else
			return 0
		ok

	def IsUntilNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Until )

			return 1

		else
			return 0
		ok

	def IsUntilPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UntilPosition )

			return 1

		else
			return 0
		ok

	def IsUntilCharAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UntilCharAt )

			return 1

		else
			return 0
		ok

	def IsUntilCharAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UntilCharAtPosition )

			return 1

		else
			return 0
		ok

	def IsUntilItemAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UntilItemAt )

			return 1

		else
			return 0
		ok

	def IsUntilItemAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UntilItemAtPosition )

			return 1

		else
			return 0
		ok


	def IsUntilXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UntilXT )

			return 1

		else
			return 0
		ok

	def IsUptoNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UpTo )

			return 1

		else
			return 0
		ok

	def IsUptoPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UpToPosition )

			return 1

		else
			return 0
		ok

		# Misspelled form

		def IsUpToPosionNamedParam()
			return This.IsUptoPositionNamedParam()

	def IsUpToNNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :UpToN or This.Item(1) = :UpToN@ ) )

			return 1

		else
			return 0
		ok

	def IsUpToCharAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UpToCharAt )

			return 1

		else
			return 0
		ok

	def IsUpToCharAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UpToCharAtPosition )

			return 1

		else
			return 0
		ok

	def IsUpToItemAtNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UpToItemAt )

			return 1

		else
			return 0
		ok

	def IsUpToItemAtPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :UpToItemAtPosition )

			return 1

		else
			return 0
		ok

	def IsUnderNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Under )

			return 1

		else
			return 0
		ok

	def IsExpressionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :Expression )

			return 1

		else
			return 0
		ok

	def IsToNCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToNChars )

			return 1

		else
			return 0
		ok

	def IsToNItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToNItems )

			return 1

		else
			return 0
		ok

	def IsToNStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToNStrings )

			return 1

		else
			return 0
		ok

	def IsToNNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToNNumbers )

			return 1

		else
			return 0
		ok

	def IsToNListsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToNLists )

			return 1

		else
			return 0
		ok

	def IsToNObjectsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and  This.Item(1) = :ToNObjects )

			return 1

		else
			return 0
		ok

	def IsLastSepNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :LastSep or This.Item(1) = :LastSep@ ) )

			return 1

		else
			return 0
		ok

	def IsToEachNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :ToEach or This.Item(1) = :ToEach@ ) )

			return 1

		else
			return 0
		ok

	def IsBeforeEachNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :BeforeEach or This.Item(1) = :BeforeEach@ ) )

			return 1

		else
			return 0
		ok

	def IsAfterEachNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AfterEach or This.Item(1) = :AfterEach@ ) )

			return 1

		else
			return 0
		ok

	def IsToNthNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :ToNth or This.Item(1) = :ToNth@ ) )

			return 1

		else
			return 0
		ok

	def IsToFirstNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :ToFirst or This.Item(1) = :ToFirst@ ) )

			return 1

		else
			return 0
		ok

	def IsToLastNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :ToLast or This.Item(1) = :ToLast@ ) )

			return 1

		else
			return 0
		ok

	def IsAfterNthNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AfterNth or This.Item(1) = :AfterNth@ ) )

			return 1

		else
			return 0
		ok

	def IsAfterFirstNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AfterFirst or This.Item(1) = :AfterFirst@ ) )

			return 1

		else
			return 0
		ok

	def IsAfterLastNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AfterLast or This.Item(1) = :AfterLast@ ) )

			return 1

		else
			return 0
		ok

	def IsBeforeNthNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :BeforeNth or This.Item(1) = :BeforeNth@ ) )

			return 1

		else
			return 0
		ok

	def IsBeforeTheseNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeThese )

			return 1
		else
			return 0
		ok

	def IsBeforeManyNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeMany )

			return 1
		else
			return 0
		ok


	def IsBeforeFirstNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :BeforeFirst or This.Item(1) = :BeforeFirst@ ) )

			return 1

		else
			return 0
		ok

	def IsBeforeLastNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :BeforeLast or This.Item(1) = :BeforeLast@ ) )

			return 1

		else
			return 0
		ok

	def IsAroundNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Around or This.Item(1) = :Around@ ) )

			return 1

		else
			return 0
		ok

	def IsAroundPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AroundPosition or This.Item(1) = :AroundPosition@ ) )

			return 1

		else
			return 0
		ok

	def IsAroundPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AroundPositions or This.Item(1) = :AroundPositions@ ) )

			return 1

		else
			return 0
		ok

	def IsAroundSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AroundSubString or This.Item(1) = :AroundSubString@ ) )

			return 1

		else
			return 0
		ok

	def IsAroundSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AroundSubStrings or This.Item(1) = :AroundSubStrings@ ) )

			return 1

		else
			return 0
		ok

	def IsAroundTheseNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AroundThese )

			return 1
		else
			return 0
		ok

	def IsAroundManyNamedParam()
		if ( This.NumberOfItems() = 2 ) and
		   ( isString(This.Item(1)) and This.Item(1) = :AroundMany )

			return 1
		else
			return 0
		ok

	def IsAroundEachNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AroundEach or This.Item(1) = :AroundEach@ ) )

			return 1

		else
			return 0
		ok

	def IsAroundNthNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AroundNth or This.Item(1) = :AroundNth@ ) )

			return 1

		else
			return 0
		ok

	def IsAroundFirstNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AroundFirst or This.Item(1) = :AroundFirst@ ) )

			return 1

		else
			return 0
		ok

	def IsAroundLastNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :AroundLast or This.Item(1) = :AroundLast@ ) )

			return 1

		else
			return 0
		ok

	def IsEachNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Each or This.Item(1) = :Each@ ) )

			return 1

		else
			return 0
		ok

	def IsFirstNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :First or This.Item(1) = :First@ ) )

			return 1

		else
			return 0
		ok

	def IsLastNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Last or This.Item(1) = :Last@ ) )

			return 1

		else
			return 0
		ok

	def IsConcatenatedNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Concatenated or This.Item(1) = :Concatenated@ ) )

			return 1

		else
			return 0
		ok

	def IsConcatenatedUsingNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :ConcatenatedUsing or This.Item(1) = :ConcatenatedUsing@ ) )

			return 1

		else
			return 0
		ok

	def IsConcatenatedWithNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :ConcatenatedWith or This.Item(1) = :ConcatenatedWith@ ) )

			return 1

		else
			return 0
		ok

	def IsEachNCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :EachNChars or This.Item(1) = :EachNChars@ ) )

			return 1

		else
			return 0
		ok

	def IsEachNItemsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :EachNItems or This.Item(1) = :EachNItems@ ) )

			return 1

		else
			return 0
		ok

	def IsEachNStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :EachNStrings or This.Item(1) = :EachNStrings@ ) )

			return 1

		else
			return 0
		ok

	def IsEachNNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :EachNNumbers or This.Item(1) = :EachNNumbers@ ) )

			return 1

		else
			return 0
		ok

	def IsEachNListsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :EachNLists or This.Item(1) = :EachNLists@ ) )

			return 1

		else
			return 0
		ok

	def IsEachNPairsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :EachNPairs or This.Item(1) = :EachNPairs@ ) )

			return 1

		else
			return 0
		ok

	def IsEachNObjectsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :EachNObjects or This.Item(1) = :EachNObjects@ ) )

			return 1

		else
			return 0
		ok

	def IsDirectionNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Direction or This.Item(1) = :Direction@ ) )

			return 1

		else
			return 0
		ok

	def IsGoingNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Going or This.Item(1) = :Going@ ) )

			return 1

		else
			return 0
		ok

	def IsDirectionOrGoingNamedParam()
		if This.IsDirectionNamedParam() or This.IsGoingNamedParam()
			return 1
		else
			return 0
		ok

		def IsGoingOrDirectionNamedParam()
			return This.IsDirectionOrGoingNamedParam()

		#--

		def IsDirectionOrGoingNamedParams()
			return This.IsDirectionOrGoingNamedParam()

		def IsGoingOrDirectionNamedParams()
			return This.IsDirectionOrGoingNamedParam()

	def IsComingNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Coming or This.Item(1) = :Coming@ ) )

			return 1

		else
			return 0
		ok

	def IsSteppingNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Stepping or This.Item(1) = :Stepping@ ) )

			return 1

		else
			return 0
		ok

	
	def IsUsingOrWithOrByNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Using or This.Item(1) = :With or This.Item(1) = :By ) )

			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def IsUsingOrByOrWithNamedParam()
			return This.IsUsingOrWithOrByNamedParam()

		def IsByOrWithOrUsingNamedParam()
			return This.IsUsingOrWithOrByNamedParam()

		def IsByOrUsingOrWithNamedParam()
			return This.IsUsingOrWithOrByNamedParam()

		def IsWithOrByOrUsingNamedParam()
			return This.IsUsingOrWithOrByNamedParam()

		def IsWithOrUsingOrByNamedParam()
			return This.IsUsingOrWithOrByNamedParam()

		#--

		def IsUsingOrWithOrByNamedParams()
			return This.IsUsingOrWithOrByNamedParam()

		def IsUsingOrByOrWithNamedParams()
			return This.IsUsingOrWithOrByNamedParam()

		def IsByOrWithOrUsingNamedParams()
			return This.IsUsingOrWithOrByNamedParam()

		def IsByOrUsingOrWithNamedParams()
			return This.IsUsingOrWithOrByNamedParam()

		def IsWithOrByOrUsingNamedParams()
			return This.IsUsingOrWithOrByNamedParam()

		def IsWithOrUsingOrByNamedParams()
			return This.IsUsingOrWithOrByNamedParam()

		#>

	def IsUsingOrWithOrByOrWhereNamedParam()
		if This.IsUsingOrWithOrByNamedParam() or This.IsWhereNamedParam()
			return 1
		else
			return 0
		ok

		def IsUsingOrWithOrByOrWhereNamedParams()
			return This.IsUsingOrWithOrByOrWhereNamedParam()


	def IsWithOrUsingOrInNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Using or This.Item(1) = :With or This.Item(1) = :In ) )

			return 1

		else
			return 0
		ok

		def IsWithOrInOrUsingNamedParam()
			return This.IsWithOrUsingOrInNamedParam()

		def IsUsingOrWithOrInNamedParam()
			return This.IsWithOrUsingOrInNamedParam()

		def IsUsingOrInOrWithNamedParam()
			return This.IsWithOrUsingOrInNamedParam()

		def IsInOrWithOrUsingNamedParam()
			return This.IsWithOrUsingOrInNamedParam()

		def IsInOrUsingOrWithNamedParam()
			return This.IsWithOrUsingOrInNamedParam()

	def IsNextNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Next or This.Item(1) = :Next@ ) )

			return 1

		else
			return 0
		ok

	def IsNextNthNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :NextNth or This.Item(1) = :NextNth@  or 
			 This.Item(1) = :NthNext or This.Item(1) = :NthNext@) )

			return 1

		else
			return 0
		ok

		def IsNthNextNamedParam()
			return This.IsNextNthNamedParam()

	def IsPreviousNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Previous or This.Item(1) = :Previous@ ) )

			return 1

		else
			return 0
		ok

	def IsPreviousNthNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :PreviousNth or This.Item(1) = :PreviousNth@  or 
			 This.Item(1) = :NthPrevious or This.Item(1) = :NthPrevious@) )

			return 1

		else
			return 0
		ok

		def IsNthPreviousNamedParam()
			return This.IsPreviousNthNamedParam()

	#--

	def IsExactlyNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Exactly or This.Item(1) = :Exactly@ ) )

			return 1

		else
			return 0
		ok

	def IsMoreThenNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :MoreThen or This.Item(1) = :MoreThen@ ) )

			return 1

		else
			return 0
		ok

	def IsLessThenNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :LessThen or This.Item(1) = :LessThen@ ) )

			return 1

		else
			return 0
		ok

	def IsOfTheseNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :OfThese or This.Item(1) = :OfThese@ ) )

			return 1

		else
			return 0
		ok

	def IsOfTheseSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :OfTheseSubStrings or This.Item(1) = :OfTheseSubStrings@ ) )

			return 1

		else
			return 0
		ok

	def IsOfTheseNumbersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :OfTheseNumbers or This.Item(1) = :OfTheseNumbers@ ) )

			return 1

		else
			return 0
		ok

	def IsOfTheseListsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :OfTheseLists or This.Item(1) = :OfTheseLists@ ) )

			return 1

		else
			return 0
		ok

	def IsOfTheseObjectsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :OfTheseObjects or This.Item(1) = :OfTheseObjects@ ) )

			return 1

		else
			return 0
		ok

	def IsOfTheseCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :OfTheseChars or This.Item(1) = :OfTheseChars@ ) )

			return 1

		else
			return 0
		ok

	def IsOfTheseLettersNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :OfTheseLetters or This.Item(1) = :OfTheseLetters@ ) )

			return 1

		else
			return 0
		ok

	#--

	def IsAndOrAndPositionOrAndSubStringNamedParam()
		if This.IsAndNamedParam() or
		   This.IsAndPositionNamedParam() or
		   This.IsAndSubstringNamedParam()

			return 1
		else
			return 0
		ok

	def IsAndOrAndSubStringOrAndPositionNamedParam()
		return This.IsAndOrAndPositionOrAndSubStringNamedParam()

	#--

	def IsAndOrAndPositionOrAndSubStringNamedParams()
		return This.IsAndOrAndPositionOrAndSubStringNamedParam()

	def IsAndOrAndSubStringOrAndPositionNamedParams()
		return This.IsAndOrAndSubStringOrAndPositionNamedParam()

		#==

	def IsAtCharsWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtCharsWhere )

			return 1

		else
			return 0
		ok

	def IsAtCharsWNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtCharsW )

			return 1

		else
			return 0
		ok

	def IsAtCharsWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtCharsWhereXT )

			return 1

		else
			return 0
		ok

	def IsAtCharsWXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtCharsWXT )

			return 1

		else
			return 0
		ok

	def IsAtSubStringsWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtSubStringsWhere )

			return 1

		else
			return 0
		ok

	def IsAtSubStringsWNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtSubStringsW )

			return 1

		else
			return 0
		ok

	def IsAtSubStringsWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtSubStringsWherexT )

			return 1

		else
			return 0
		ok

	def IsAtSubStringsWXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AtSubStringsWXT )

			return 1

		else
			return 0
		ok

	#--
	
	def IsBeforeCharsWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeCharsWhere )

			return 1

		else
			return 0
		ok

	def IsBeforeCharsWNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeCharsW )

			return 1

		else
			return 0
		ok

	def IsBeforeCharsWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeCharsWhereXT )

			return 1

		else
			return 0
		ok

	def IsBeforeCharsWXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeCharsWXT )

			return 1

		else
			return 0
		ok

	def IsBeforeSubStringsWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSubStringsWhere )

			return 1

		else
			return 0
		ok

	def IsBeforeSubStringsWNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSubStringsW )

			return 1

		else
			return 0
		ok

	def IsBeforeSubStringsWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSubStringsWhereXT )

			return 1

		else
			return 0
		ok

	def IsBeforeSubStringsWXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :BeforeSubStringsWXT )

			return 1

		else
			return 0
		ok

	#--
	
	def IsAfterCharsWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterCharsWhere )

			return 1

		else
			return 0
		ok

	def IsAfterCharsWNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterCharsW )

			return 1

		else
			return 0
		ok

	def IsAfterCharsWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterCharsWhereXT )

			return 1

		else
			return 0
		ok

	def IsAfterCharsWXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AfterCharsWXT )

			return 1

		else
			return 0
		ok

	def IsAfterSubStringsWhereNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AftersubStringsWhere )

			return 1

		else
			return 0
		ok

	def IsAfterSubStringsWNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AftersubStringsW )

			return 1

		else
			return 0
		ok

	def IsAfterSubStringsWhereXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AftersubStringsWhereXT )

			return 1

		else
			return 0
		ok

	def IsAfterSubStringsWXTNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :AftersubStringsWXT )

			return 1

		else
			return 0
		ok



	def IsAtCharsWhereXTOrAtCharsWXTNamedParam()
		if This.IsAtCharsWhereXTNamedParam() or This.IsAtCharsWXTNamedParam()
			return 1
		else
			return 0
		ok

		def IsAtCharsWXTOrAtCharsWhereXTNamedParam()
			return This.IsAtCharsWXTOrAtCharsWhereXTNamedParam()

		#--

		def IsAtCharsWhereXTOrAtCharsWXTNamedParams()
			return This.IsAtCharsWhereXTOrAtCharsWXTNamedParam()

		def IsAtCharsWXTOrAtCharsWhereXTNamedParams()
			return This.IsAtCharsWXTOrAtCharsWhereXTNamedParam()


	def IsBeforeCharsWhereXTOrBeforeCharsWXTNamedParam()
		if This.IsBeforeCharsWhereXTNamedParam() or This.IsBeforeCharsWXTNamedParam()
			return 1
		else
			return 0
		ok

		def IsBeforeCharsWXTOrBeforeCharsWhereXTNamedParam()
			return This.IsBeforeCharsWXTOrBeforeCharsWhereXTNamedParam()

		#--

		def IsBeforeCharsWhereXTOrBeforeCharsWXTNamedParams()
			return This.IsBeforeCharsWhereXTOrBeforeCharsWXTNamedParam()

		def IsBeforeCharsWXTOrBeforeCharsWhereXTNamedParams()
			return This.IsBeforeCharsWXTOrBeforeCharsWhereXTNamedParam()

	def IsAfterCharsWhereXTOrAfterCharsWXTNamedParam()
		if This.IsAfterCharsWhereXTNamedParam() or This.IsAfterCharsWXTNamedParam()
			return 1
		else
			return 0
		ok

		def IsAfterCharsWXTOrAfterCharsWhereXTNamedParam()
			return This.IsAfterCharsWXTOrAfterCharsWhereXTNamedParam()

		#--

		def IsAfterCharsWhereXTOrAfterCharsWXTNamedParams()
			return This.IsAfterCharsWhereXTOrAfterCharsWXTNamedParam()

		def IsAfterCharsWXTOrAfterCharsWhereXTNamedParams()
			return This.IsAfterCharsWXTOrAfterCharsWhereXTNamedParam()

	def IsAtSubStringsWhereXTOrAtCharsWXTNamedParam()
		if This.IsAtSubstringsWhereXTNamedParam() or This.IsAtSubstringsWXTNamedParam()
			return 1
		else
			return 0
		ok

		def IsAtSubstringsWXTOrAtSubstringsWhereXTNamedParam()
			return This.IsAtSubstringsWXTOrAtSubstringsWhereXTNamedParam()

		#--

		def IsAtSubstringsWhereXTOrAtSubstringsWXTNamedParams()
			return This.IsAtSubstringsWhereXTOrAtSubstringsWXTNamedParam()

		def IsAtSubstringsWXTOrAtSubstringsWhereXTNamedParams()
			return This.IsAtSubstringsWXTOrAtSubstringsWhereXTNamedParam()

	def IsBeforeSubStringsWhereXTOrBeforSubStringsWXTNamedParam()
		if This.IsBeforeSubstringsWhereXTNamedParam() or This.IsBeforeSubstringsWXTNamedParam()
			return 1
		else
			return 0
		ok

		def IsBeforeSubstringsWXTOrBeforeSubstringsWhereXTNamedParam()
			return This.IsBeforeSubstringsWXTOrBeforeSubstringsWhereXTNamedParam()

		#--

		def IsBeforeSubstringsWhereXTOrBeforeSubstringsWXTNamedParams()
			return This.IsBeforeSubstringsWhereXTOrBeforeSubstringsWXTNamedParam()

		def IsBeforeSubstringsWXTOrBeforeSubstringsWhereXTNamedParams()
			return This.IsBeforeSubstringsWXTOrBeforeSubstringsWhereXTNamedParam()

	def IsAfterSubStringsWhereXTOrAfterSubstringsWXTNamedParam()
		if This.IsAfterSubstringsWhereXTNamedParam() or This.IsAfterSubstringsWXTNamedParam()
			return 1
		else
			return 0
		ok

		def IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParam()
			return This.IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParam()

		#--

		def IsAfterSubstringsWhereXTOrAfterSubstringsWXTNamedParams()
			return This.IsAfterSubstringsWhereXTOrAfterSubstringsWXTNamedParam()

		def IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParams()
			return This.IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParam()

	#--

	def IsForwardNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Forward )

			return 1

		else
			return 0
		ok

	def IsBackwardNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Backward )

			return 1

		else
			return 0
		ok

	def IsForwardOrBackwardNamedParam()
		if This.IsForwardNamedParam() or This.IsBackwardNamedParam()
			return 1
		else
			return FALE
		ok

		def IsForwardOrBackwardNamedParams()
			return This.IsForwardOrBAckwardNamedParam()

		def IsBackwardOrforwardNamedParam()
			return This.IsForwardOrBAckwardNamedParam()

		def IsBackwardOrforwardNamedParams()
			return This.IsForwardOrBAckwardNamedParam()

	def IsJumpNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Jump )

			return 1

		else
			return 0
		ok

	def IsInOrOfNamedParam()
		if This.IsInNamedParam() or This.IsOfNamedParam()
			return 1
		else
			return 0
		ok

		def IsOfOrInNamedParam()
			return IsInOrOfNamedParam()

		def IsInOrOfNamedParams()
			return IsInOrOfNamedParam()

		def IsOfOrInNamedParams()
			return IsInOrOfNamedParam()

	def IsNameOrNamedNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :Name or This.Item(1) = :Named ) )

			return 1

		else
			return 0
		ok

		def IsNameOrNamedNamedParams()
			return This.IsNameOrNamedNamedParam()

	def IsStartOrStartAtOrStaringAtNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Start or This.Item(1) = :StartAt or This.Item(1) = :StartingAt )
		    )

			return 1

		else
			return 0
		ok

		def IsStartOrStartAtOrStaringAtNamedParams()
			return This.IsStartOrStartAtOrStaringAtNamedParam()

	def IsEndOrEndAtOrEndingAtNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :End or This.Item(1) = :EndAt or This.Item(1) = :EndingAt )
		    )

			return 1

		else
			return 0
		ok

		def IsEndOrEndAtOrEndingAtNamedParams()
			return This.IsEndOrEndAtOrEndingAtNamedParam()

	def IsNStepNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :NStep )

			return 1

		else
			return 0
		ok

	def IsNStepsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :NStep )

			return 1

		else
			return 0
		ok


	def IsStepsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Steps )

			return 1

		else
			return 0
		ok

	def IsStepOrNSetpNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and

		   ( This.Item(1) = :End or This.Item(1) = :Step or This.Item(1) = :NStep )

			return 1

		else
			return 0
		ok

		def IsStepOrNSetpNamedParams()
			return This.IsStepOrNSetpNamedParam()

	def IsStepsOrNSetpsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1) and
		   ( This.Item(1) = :End or This.Item(1) = :Steps or This.Item(1) = :NSteps ) )

			return 1

		else
			return 0
		ok

		def IsStepsOrNSetpsNamedParams()
			return This.IsStepsOrNSetpsNamedParam()

	def IsStepOrStepsOrNStepOrNStepsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and

		   ( This.Item(1) = :Step or
		     This.Item(1) = :Steps or
		     This.Item(1) = :NStep or
		     This.Item(1) = :NSteps )

			return 1

		else
			return 0
		ok

		def IsStepOtNStepOrStepsOrNStepsNamedParam()
			return This.IsStepOrStepsOrNStepOrNStepsNamedParam()

		#--

		def IsStepOrStepsOrNStepOrNStepsNamedParams()
			return This.IsStepOrStepsOrNStepOrNStepsNamedParam()

		def IsStepOtNStepOrStepsOrNStepsNamedParams()
			return This.IsStepOrStepsOrNStepOrNStepsNamedParam()

	def IsThanNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :Than

			return 1

		else
			return 0
		ok

	def IsSeparatorNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and This.Item(1) = :Separator

			return 1

		else
			return 0
		ok

		def IsSeperatorNamedParam()
			return This.IsSeparatorNamedParam()

	#--

	def IsFirstCharsNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :FirstChars

			return 1

		else
			return 0
		ok

	def IsFirstNCharsNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :FirstNChars or This.Item(1) = :NFirstChars )

			return 1

		else
			return 0
		ok

		def IsNFirstCharsNamedParam()
			return This.IsFirstNCharsNamedParam()

	def IsFirstNItemsNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :FirstNChars or This.Item(1) = :NFirstItems )

			return 1

		else
			return 0
		ok

		def IsNFirstItemsNamedParam()
			return This.IsFirstNItemsNamedParam()

	#--

	def IsLastCharsNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :LastChars

			return 1

		else
			return 0
		ok

	def IsLastNCharsNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :LastNChars or This.Item(1) = :NLastChars )

			return 1

		else
			return 0
		ok

		def IsNLastCharsNamedParam()
			return This.IsLastNCharsNamedParam()

	def IsLastNItemsNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :LastNChars or This.Item(1) = :NLastItems )

			return 1

		else
			return 0
		ok

		def IsNLastItemsNamedParam()
			return This.IsLastNItemsNamedParam()

	def IsStartingAtOrAfterNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :StartingAt or This.Item(1) = :After )

			return 1

		else
			return 0
		ok

		def IsStartingAtOrAfterNamedParams()
			return IsStartingAtOrAfterNamedParam()

		def IsAfterOrStartingAtNamedParam()
			return IsStartingAtOrAfterNamedParam()

		def IsAfterOrStartingAtNamedParams()
			return IsStartingAtOrAfterNamedParam()

	def IsStartingAtOrBeforeNamedParam()

		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :StartingAt or This.Item(1) = :Before )

			return 1

		else
			return 0
		ok

		def IsStartingAtOrBeforeNamedParams()
			return IsStartingAtOrBeforeNamedParam()

		def IsBeforeOrStartingAtNamedParam()
			return IsStartingAtOrBeforeNamedParam()

		def IsBeforeOrStartingAtNamedParams()
			return IsStartingAtOrBeforeNamedParam()

	def IsAtOrAtThisPositionNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :At or This.Item(1) = :AthThisPosition )

			return 1

		else
			return 0
		ok

		def IsAtThisPositionOrAtNamedParam()
			return This.IsAtThisPositionOrAtNamedParam()

	def IsAfterManyPositionsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :AfterManyPositions

			return 1

		else
			return 0
		ok

	def IsAfterManyPositionsIBNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :AfterManyPositionsIB

			return 1

		else
			return 0
		ok

	#--

	def IsToEndOfWordNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ToEndOfWord

			return 1

		else
			return 0
		ok

	def IsEndOfWordNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :EndOfWord

			return 1

		else
			return 0
		ok

	def IsToEndOfLineNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ToEndOfLine

			return 1

		else
			return 0
		ok

	def IsEndOfLineNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :EndOfLine

			return 1

		else
			return 0
		ok

	def IsToEndOfSentenceNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ToEndOfSentence

			return 1

		else
			return 0
		ok

	def IsEndOfSentenceNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :EndOfSentence

			return 1

		else
			return 0
		ok

#~~~~~~~~

	def IsUpToNBoundsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :UpToNBounds

			return 1

		else
			return 0
		ok

	def IsIsBoundOfNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :IsBoundOf

			return 1

		else
			return 0
		ok

	def IsIsFirstBoundOfNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :IsFirstBoundOf

			return 1

		else
			return 0
		ok

	def IsIsLastBoundOfNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :IsLastBoundOf

			return 1

		else
			return 0
		ok

	def IsIsLeftBoundOfNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :IsLeftBoundOf

			return 1

		else
			return 0
		ok

	def IsIsRightBoundOfNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :IsRightBoundOf

			return 1

		else
			return 0
		ok

#--

	def IsBeforeCharNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :BeforeChar

			return 1

		else
			return 0
		ok

	def IsBeforeCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :BeforeChars

			return 1

		else
			return 0
		ok

	def IsAfterCharNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :AfterChar

			return 1

		else
			return 0
		ok

	def IsAfterCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :AfterChars

			return 1

		else
			return 0
		ok

	def IsAroundCharNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :AroundChar

			return 1

		else
			return 0
		ok

	def IsAroundCharsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :AroundChars

			return 1

		else
			return 0
		ok

#--

	def IsBeforePositonNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :BeforePosition

			return 1

		else
			return 0
		ok

#--

	def IsBeforSubStringsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :BeforeSubStrings

			return 1

		else
			return 0
		ok

#-

	def IsPositionOrSubStringNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   (This.Item(1) = :Position or This.Item(1) = :SubString)

			return 1

		else
			return 0
		ok	

		def IsSubStringOrPositionNamedParam()
			return This.IsPositionOrSubStringNamedParam()


#--

	def IsFromPathNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :FromPath

			return 1

		else
			return 0
		ok

	def IsToPathNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ToPath

			return 1

		else
			return 0
		ok

	def IsFromOrFromPathNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :FromPath or This.Item(1) = :From)

			return 1

		else
			return 0
		ok

	def IsToOrToPathNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :ToPath or This.Item(1) = :To)

			return 1

		else
			return 0
		ok

	def IsToOrAndNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :To or This.Item(1) = :And)

			return 1

		else
			return 0
		ok

		def IsAndOrToNamedParam()
			return This.IsToOrAndNamedParam()

	def IsAmongNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :Among

			return 1

		else
			return 0
		ok

	def IsBetweenOrFromNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   ( This.Item(1) = :Between or This.Item(1) = :From)

			return 1

		else
			return 0
		ok

		def IsFromOrBetweenNamedParam()
			return This.IsBetweenOrFromNamedParam()

	def IsLikeNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :Like

			return 1

		else
			return 0
		ok

	def IsPatternNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :Pattern

			return 1

		else
			return 0
		ok

	def IsGroupNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :Group

			return 1

		else
			return 0
		ok

	def IsWhenNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :When

			return 1

		else
			return 0
		ok

	def IsForNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :For

			return 1

		else
			return 0
		ok

	def IsForEachNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ForEach

			return 1

		else
			return 0
		ok

	def IsWhenOrIfNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   (This.Item(1) = :When or This.Item(1) = :If)

			return 1

		else
			return 0
		ok

		def IsIfOrWhenNamedParam()
			return This.IsWhenOrIfNamedParam()

	def IsWhenOrForNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   (This.Item(1) = :When or This.Item(1) = :For)

			return 1

		else
			return 0
		ok

		def IsForOrWhenNamedParam()
			return This.IsWhenOrForNamedParam()

	def IsIfOrForNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   (This.Item(1) = :If or This.Item(1) = :For)

			return 1

		else
			return 0
		ok

		def IsForOrIfNamedParam()
			return This.IsForOrIfNamedParam()

	def IsIfOrForOrWhenNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   (This.Item(1) = :If or This.Item(1) = :For or This.Item(1) = :When)

			return 1

		else
			return 0
		ok

		def IsIfOrWhenOrForNamedParam()
			return This.IsIfOrForOrWhenNamedParam()

		def IsWhenOrIfOrForNamedParam()
			return This.IsIfOrForOrWhenNamedParam()

		def IsWhenOrForOrIfNamedParam()
			return This.IsIfOrForOrWhenNamedParam()

		def IsForOrIfOrWhenNamedParam()
			return This.IsIfOrForOrWhenNamedParam()

		def IsForOrWhenOrIfNamedParam()
			return This.IsIfOrForOrWhenNamedParam()


	def IsToColNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ToCol

			return 1

		else
			return 0
		ok

	def IsToColsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ToCols

			return 1

		else
			return 0
		ok

	def IsToRowNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ToRow

			return 1

		else
			return 0
		ok

	def IsToRowsNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ToRows

			return 1

		else
			return 0
		ok

	def IsByOrInColNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   (This.Item(1) = :By or This.Item(1) = :InCol)

			return 1

		else
			return 0
		ok

		def IsInColOrByNamedParam()
			return This.IsByOrInColNamedParam()

	def IsByOrToColNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   (This.Item(1) = :By or This.Item(1) = :ToCol)

			return 1

		else
			return 0
		ok

		def IsToColOrByNamedParam()
			return This.IsByOrToColNamedParam()

	def IsByOrInRowNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   (This.Item(1) = :By or This.Item(1) = :InRow)

			return 1

		else
			return 0
		ok

		def IsInRowOrByNamedParam()
			return This.IsByOrInRowNamedParam()

	def IsByOrToRowNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   (This.Item(1) = :By or This.Item(1) = :ToRow)

			return 1

		else
			return 0
		ok

		def IsToRowOrByNamedParam()
			return This.IsByOrToRowNamedParam()

	def IsToOrToColOrToRowNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and

		   StzFind([ :To, :ToCol, :ToRow ], This.Item(1)) > 0

			return 1

		else
			return 0
		ok

		def IsToOrToRowOrToColNamedParam()
			return This.IsToOrToColOrToRowNamedParam()


	def IsByOrByColOrByRowNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and

		   StzFind([ :By, :ByCol, :ByRow ], This.Item(1)) > 0

			return 1

		else
			return 0
		ok

		def IsByOrByRowOrByColNamedParam()
			return This.IsByOrByColOrByRowNamedParam()

	def IsByXTNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and
		   This.Item(1) = :ByXT

			return 1

		else
			return 0
		ok

	def IsItNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :It )

			return 1
		else
			return 0
		ok

	def IsSayNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Say )

			return 1
		else
			return 0
		ok

	def IsSayOrReturnNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Say or This.Item(1) = :Return) )

			return 1
		else
			return 0
		ok

		def IsReturnOrSayNamedParam()
			return This.IsSayOrReturnNamedParam()

	def IsOtherwiseNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Otherwise )

			return 1
		else
			return 0
		ok

	def IsElseNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Else )

			return 1
		else
			return 0
		ok

	def IsElseOrOtherwiseNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
			(This.Item(1) = :Else or This.Item(1) = :Otherwise) )

			return 1
		else
			return 0
		ok

		def IsOtherwiseOrElseNamedParam()
			return This.IsElseOrOtherwiseNamedParam()

	def IsRingsNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Rings )

			return 1
		else
			return 0
		ok

	def IsInterTotalNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :InterTotal )

			return 1
		else
			return 0
		ok

	def IsSubTotalNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :SubTotal )

			return 1
		else
			return 0
		ok

	def IsGrandTotalNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :GrandTotal )

			return 1
		else
			return 0
		ok


	def IsFromFileNamedParam()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and  This.Item(1) = :FromFile

			return 1

		else
			return 0
		ok

	def IsFromCSVFileNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromCSVFile )

			return 1
		else
			return 0
		ok

	def IsFromHtmlFileNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromHtmlFile )

			return 1
		else
			return 0
		ok

	def IsFromJsonFileNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromJsonFile )

			return 1
		else
			return 0
		ok

	def IsFromCSVNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromCSV )

			return 1
		else
			return 0
		ok

	def IsFromHtmlNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromHtml )

			return 1
		else
			return 0
		ok

	def IsFromJsonNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromJson )

			return 1
		else
			return 0
		ok

	def IsFromCSVStringNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromCSVString )

			return 1
		else
			return 0
		ok

	def IsFromHtmlStringNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromHtmlString )

			return 1
		else
			return 0
		ok

	def IsFromJsonStringNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :FromJsonString )

			return 1
		else
			return 0
		ok

	def IsFromCSVOrCSVStringNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		   ( This.Item(1) = :FromCSV or This.Item(1) = :FromCSVString ) )

			return 1
		else
			return 0
		ok

		def FromCSVStringORCSVNamedParam()
			return This.IsFromCSVOrCSVStringNamedParam()

	def IsFromHtmlOrHtmlStringNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		   ( This.Item(1) = :FromHTML or This.Item(1) = :FromHTMLString ) )

			return 1
		else
			return 0
		ok

		def IsFromHtmlStringOrHtmlNamedParam()
			return This.IsFromHtmlOrHtmlStringNamedParam()

	def IsFromJsonOrJsonStringNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and
		   ( This.Item(1) = :FromJSON or This.Item(1) = :FromJSONString ) )

			return 1
		else
			return 0
		ok

		def IsFromJsonStringOrJsonNamedParam()
			return This.IsFromJsonOrJsonStringNamedParam()

	def IsOfItemNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :IsOfItem )

			return 1
		else
			return 0
		ok

	def IsOnSuccessNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnSuccess )

			return 1
		else
			return 0
		ok

	def IsOnCompleteNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnComplete )

			return 1
		else
			return 0
		ok

	def IsOnErrorNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnError )

			return 1
		else
			return 0
		ok

	def IsOnUpdateNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :OnUpdate )

			return 1
		else
			return 0
		ok

	def IsOnOrOfNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([:On, :Of], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

		def IsOfOrOnNamedParam()
			return This.IsOnOrOfNamedParam()

	#--

	def IsIDNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :ID )

			return 1
		else
			return 0
		ok

	def IsLabelNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Label )

			return 1
		else
			return 0
		ok

	def IsWithOrLabelNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and (This.Item(1) = :Label or This.Item(1) = :With) )

			return 1
		else
			return 0
		ok

		def IsLabelORWithNamedParam()
			return This.IsWithOrLabelNamedParam()

	def IsTypeNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Type )

			return 1
		else
			return 0
		ok

	def IsPersonNamedParam()

		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = :Person )

			return 1
		else
			return 0
		ok

	#--

	def IsNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = "node" )

			return 1
		else
			return 0
		ok

	def IsWithNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = "withnode" )

			return 1
		else
			return 0
		ok

	def IsEdgeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = "edge" )

			return 1
		else
			return 0
		ok

	def IsWithEdgeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = "withedge" )

			return 1
		else
			return 0
		ok

	def IsToEdgeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = "toedge" )

			return 1
		else
			return 0
		ok

	def IsOfNodeNamedPAram()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = "ofnode" )

			return 1
		else
			return 0
		ok

	def IsOfOrOfNodeNamedPAram()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([ "of", "ofnode" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

		def IsOfNodeOrOfNamedPAram()
			return This.IsOfOrOfNodeNamedPAram()

	def IsOfOrOfPositionNamedPAram()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([ "of", "ofposition" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

		def IsOfPositionOrOfNamedPAram()
			return This.IsOfOrOfPositionNamedPAram()

	def IsWithOrWithNodeNamedparam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([ "with", "withnode" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

		def IsWithNodeOrWithNamedPAram()
			return This.isWithOrWithNodeNamedParam()

	def IsWithOrwithPositionOrwithNodeNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([ "with", "withposition", "withnode" ], This.Item(1)) > 0 )

			return 1
		else
			return 0
		ok

		def IswithOrWithNodeOrWithPositionNamedParam()
			return This.IsWithOrwithPositionOrwithNodeNamedParam()
	
		def IsWithNodeOrWithOrWithPsoitionNamedPAram()
			return This.IsWithOrwithPositionOrwithNodeNamedParam()

	def IsInGroupNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = "ingroup" )

			return 1
		else
			return 0
		ok

	def IsInRuleGroupNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and This.Item(1) = "inrulegroup" )

			return 1
		else
			return 0
		ok

	def IsInGroupOrInRuleGroupNamedParam()
		if This.NumberOfItems() = 2 and
		   ( isString(This.Item(1)) and StzFind([ "ingroup", "inrulegroup" ], This.Item(1)) > 0 )


			return 1
		else
			return 0
		ok

		def IsInRuleGroupOrInGroupNamedParam()
			return This.IsInGroupOrInRuleGroupNamedParam()

#WARNING #TODO: All the Is...NamedParam() functions will be moved
# to the dedicated stzNamedParams.ring file.

#~> Once this migration is complete, stzList.ring will be
# cleaned up and these functions will be removed.  
