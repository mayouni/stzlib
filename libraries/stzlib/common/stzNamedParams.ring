

#===========================================#
#   CHECKING IF THE LIST IS A NAMED PARAM   #
#===========================================#

#NOTE
# This file replaces all the methods in stzList initailly made
# to check named params. Hence, they are transformed to global
# functions, without the need of instanciating a stzList object
# at each use. Which also leads to better performance.

#TODO // Test this file, repalce all the occurrence where named
# params are used in the library with these global functions,
# and then remove all the relative methods from stzList class.

# Currently (V1) Softanza supports more then 1760 named params

#TODO // Add @ to all params, like this:
# (paList[1] = :ParamName or paList[1] = :ParamName@ ) )

#TODO // Add _acNamedParams = [] list and use it to check if
# a give string is a named param (to avoid the current solution
# implemented using eval, see IsNamedParam() function)

func IsOnPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OnPosition)

		return TRUE
	else
		return FALSE
	ok

	func IsInPositionNamedParam(paList)
		if isList(paList) and len(paList) = 2 and
		   ( isString(paList[1]) and paList[1] = :InPosition)

			return TRUE
		else
			return FALSE
		ok

	// func IsAtPositionNamedParam(paList) --> Exists below in the file


func IsOnPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OnPositions)

		return TRUE
	else
		return FALSE
	ok

	func IsInPositionsNamedParam(paList)
		if isList(paList) and len(paList) = 2 and
		   ( isString(paList[1]) and paList[1] = :InPositions)

			return TRUE
		else
			return FALSE
		ok

func IsOnSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OnSection)

		return TRUE
	else
		return FALSE
	ok

func IsOnSectionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OnSectionIB)

		return TRUE
	else
		return FALSE
	ok

func IsOnSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OnSections)

		return TRUE
	else
		return FALSE
	ok

func IsOnSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OnSectionsIB)

		return TRUE
	else
		return FALSE
	ok

func IsHarvestNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Harvest)

		return TRUE
	else
		return FALSE
	ok

func IsAndHarvestNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndHarvest)

		return TRUE
	else
		return FALSE
	ok

func IsAndThenHarvestNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndThenHarvest)

		return TRUE
	else
		return FALSE
	ok

func IsThenHarvestNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ThenHarvest)

		return TRUE
	else
		return FALSE
	ok

func IsYieldNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Yield)

		return TRUE
	else
		return FALSE
	ok

func IsAndYieldNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndYield)

		return TRUE
	else
		return FALSE
	ok

func IsAndThenYieldNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndThenYield)

		return TRUE
	else
		return FALSE
	ok

func IsThenYieldNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ThenYield)

		return TRUE
	else
		return FALSE
	ok

#--

func IsHarvestSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :HarvestSection)

		return TRUE
	else
		return FALSE
	ok

func IsAndHarvestSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndHarvestSection)

		return TRUE
	else
		return FALSE
	ok

func IsAndThenHarvestSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndThenHarvestSection)

		return TRUE
	else
		return FALSE
	ok

func IsThenHarvestSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ThenHarvestSection)

		return TRUE
	else
		return FALSE
	ok

func IsYieldSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :YieldSection)

		return TRUE
	else
		return FALSE
	ok

func IsAndYieldSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndYieldSection)

		return TRUE
	else
		return FALSE
	ok

func IsAndThenYieldSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndThenYieldSection)

		return TRUE
	else
		return FALSE
	ok

func IsThenYieldSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ThenYieldSection)

		return TRUE
	else
		return FALSE
	ok

#--

func IsHarvestSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :HarvestSections)

		return TRUE
	else
		return FALSE
	ok

func IsAndHarvestSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndHarvestSections)

		return TRUE
	else
		return FALSE
	ok

func IsAndThenHarvestSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndThenHarvestSections)

		return TRUE
	else
		return FALSE
	ok

func IsThenHarvestSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ThenHarvestSections)

		return TRUE
	else
		return FALSE
	ok

func IsYieldSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :YieldSections)

		return TRUE
	else
		return FALSE
	ok

func IsAndYieldSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndYieldSections)

		return TRUE
	else
		return FALSE
	ok

func IsAndThenYieldSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndThenYieldSections)

		return TRUE
	else
		return FALSE
	ok

func IsThenYieldSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ThenYieldSections)

		return TRUE
	else
		return FALSE
	ok
#--

func IsNCharsBeforeNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :NCharsBefore)

		return TRUE
	else
		return FALSE
	ok

func IsNCharsAfterNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :NCharsAfter)

		return TRUE
	else
		return FALSE
	ok

#--

func IsToNPartsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToNParts)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfNCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfNChars)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfNItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfNItems)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfNItemsXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfNItemsXT)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfNStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfNStrings)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfNSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfNSubStringss)

		return TRUE
	else
		return FALSE
	ok

#==

func IsAtWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtWhere)

		return TRUE
	else
		return FALSE
	ok

func IsWhereOrAtWhereNamedParam(paList)
	if This.IsWhereNamedParam(paList) or This.IsAtWhereNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

func IsAtWhereOrWhereNamedParam(paList)
	if This.IsWhereNamedParam(paList) or This.IsAtWhereNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

func IsWhereOrAtWhereNamedParams()
	if This.IsWhereNamedParam(paList) or This.IsAtWhereNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

func IsAtWhereOrWhereNamedParams()
	if This.IsWhereNamedParam(paList) or This.IsAtWhereNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

#--

func IsAtWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtWhereXT)

		return TRUE
	else
		return FALSE
	ok

func IsWhereXTOrAtWhereXTNamedParam(paList)
	if This.IsWhereXTNamedParam(paList) or This.IsAtWhereXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

func IsAtWhereXTOrWhereXTNamedParam(paList)
	if This.IsWhereXTNamedParam(paList) or This.IsAtWhereXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

func IsWhereXTOrAtWhereXTNamedParams()
	if This.IsWhereXTNamedParam(paList) or This.IsAtWhereXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

func IsAtWhereXTOrWhereXTNamedParams()
	if This.IsWhereXTNamedParam(paList) or This.IsAtWhereXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

#==

func IsBeforeWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeWhere)

		return TRUE
	else
		return FALSE
	ok

func IsBeforeOrBeforeWhereNamedParam(paList)
	if This.IsBeforeNamedParam(paList) or This.IsBeforeWhereNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsBeforeWhereOrBeforeNamedParam(paList)
		return This.IsBeforeOrBeforeWhereNamedParam(paList)

	func IsBeforeOrBeforeWhereNamedParams()
		return This.IsBeforeOrBeforeWhereNamedParam(paList)

	func IsBeforeWhereOrBeforeNamedParams()
		return This.IsBeforeOrBeforeWhereNamedParam(paList)

#--

func IsBeforeWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeWhereXT)

		return TRUE
	else
		return FALSE
	ok

func IsBeforeOrBeforeWhereXTNamedParam(paList)
	if This.IsBeforeNamedParam(paList) or This.IsBeforeWhereXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsBeforeWhereXTOrBeforeNamedParam(paList)
		return This.IsBeforeOrBeforeWhereXTNamedParam(paList)

	func IsBeforeOrBeforeWhereXTNamedParams()
		return This.IsBeforeOrBeforeWhereXTNamedParam(paList)

	func IsBeforeWhereXTOrBeforeNamedParams()
		return This.IsBeforeOrBeforeWhereXTNamedParam(paList)

#==

#==

func IsAfterWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AfterWhere)

		return TRUE
	else
		return FALSE
	ok

func IsAfterOrAfterWhereNamedParam(paList)
	if This.IsAfterNamedParam(paList) or This.IsAfterWhereNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAfterWhereOrAfterNamedParam(paList)
		return This.IsAfterOrAfterWhereNamedParam(paList)

	func IsAfterOrAfterWhereNamedParams()
		return This.IsAfterOrAfterWhereNamedParam(paList)

	func IsAfterWhereOrAfterNamedParams()
		return This.IsAfterOrAfterWhereNamedParam(paList)

#--

func IsAfterWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AfterWhereXT)

		return TRUE
	else
		return FALSE
	ok

func IsAfterOrAfterWhereXTNamedParam(paList)
	if This.IsAfterNamedParam(paList) or This.IsAfterWhereXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAfterWhereXTOrAfterNamedParam(paList)
		return This.IsAfterOrAfterWhereXTNamedParam(paList)

	func IsAfterOrAfterWhereXTNamedParams()
		return This.IsAfterOrAfterWhereXTNamedParam(paList)

	func IsAfterWhereXTOrAfterNamedParams()
		return This.IsAfterOrAfterWhereXTNamedParam(paList)

#==

func IsToPartsOfExactlyNItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfExactlyNItems)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfExactlyNCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfExactlyNChars)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfExactlyNStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfExactlyNStrings)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfExactlyNSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfExactlyNSubStrings)

		return TRUE
	else
		return FALSE
	ok

#--

func IsToPartsOfNItemsXT()
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfNItemsXT)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfNCharsXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfNCharsXT)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfNStringsXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfNStringsXT)

		return TRUE
	else
		return FALSE
	ok

func IsToPartsOfNSubStringsXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToPartsOfNSubStringsXT)

		return TRUE
	else
		return FALSE
	ok

#==

func IsToItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToItem)

		return TRUE
	else
		return FALSE
	ok

func IsToItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToItems)

		return TRUE
	else
		return FALSE
	ok

func IsUntilItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UntilItem)

		return TRUE
	else
		return FALSE
	ok

func IsUpToItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UpToItem)

		return TRUE
	else
		return FALSE
	ok

#--

func IsDownToNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :DownTo)

		return TRUE
	else
		return FALSE
	ok

func IsDownToItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :DownToItem)

		return TRUE
	else
		return FALSE
	ok

func IsDownToItemAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :DownToItemAt)

		return TRUE
	else
		return FALSE
	ok

func IsDownToItemAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :DownToItemAtPosition)

		return TRUE
	else
		return FALSE
	ok

func IsDownToCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :DownToChar)

		return TRUE
	else
		return FALSE
	ok

func IsDownToCharAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :DownToCharAt)

		return TRUE
	else
		return FALSE
	ok

func IsDownToCharAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :DownToCharAtPosition)

		return TRUE
	else
		return FALSE
	ok

#--

#TODO // Move IsToCharNamedParam(paList) here

func IsUntilCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UntilChar)

		return TRUE
	else
		return FALSE
	ok

func IsUpToCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UpToChar)

		return TRUE
	else
		return FALSE
	ok

#--

# Move IsToSubStringNamedParam(paList) here

func IsUntilSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UntilSubString)

		return TRUE
	else
		return FALSE
	ok

func IsUpToSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UpToSubString)

		return TRUE
	else
		return FALSE
	ok

#--

#TODO : Move IsToStringNamedParam(paList) here

func IsUntilStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UntilString)

		return TRUE
	else
		return FALSE
	ok

func IsUpToStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UpToString)

		return TRUE
	else
		return FALSE
	ok

#--

#TODO // Move IsToNumberNamedParam(paList) here

func IsUntilNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UntilNumber)

		return TRUE
	else
		return FALSE
	ok

func IsUpToNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UpToNumber)

		return TRUE
	else
		return FALSE
	ok

#--

#TODO // Move IsToListNamedParam(paList) here

func IsUntilListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UntilList)

		return TRUE
	else
		return FALSE
	ok

func IsUpToListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UpToList)

		return TRUE
	else
		return FALSE
	ok

#--

#TODO : Move IsToObjectNamedParam(paList) here

func IsUntilObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UntilObject)

		return TRUE
	else
		return FALSE
	ok

func IsUpToObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UpToObject)

		return TRUE
	else
		return FALSE
	ok

#--

func IsOneOfTheseNamedParams(paList, pacParamNames)
	if CheckParams()
		if NOT ( isList(paList) and len(paList) = 2 and isString(paList[1]) )
			StzRaise("Incorrect param type! paList must be a pair of items starting with a string.")
		ok

		if NOT ( isList(pacParamNames) and @IsListOfStrings(pacParamNames) )
			StzRaise("Incorrect param type! pacParamNames must be a list of strings.")
		ok
	ok

	nLen = len(pacParamNames)
	bResult = FALSE

	for i = 1 to nLen
		cCode = 'bFound = Is' + pacParamNames[i] + 'NamedParam(paList)'
		eval(cCode)
		if bFound
			bResult = TRUE
			exit
		ok
	next

	return bResult

	#< @functionMisspelledForm

	func IsOneTheseNamedParams(paList, pacParamNames)
		return This.IsOneOfTheseNamedParams(paList, pacParamNames)

	#>

func IsRemoveAtOptionsNamedParam(paList)
	bResult = FALSE
	oList = new stzList(paList)

	if oList.IsHashList() and

	   oList.ToStzHashList().KeysQ().IsMadeOfSome([
		:RemoveNCharsBefore, :RemoveNCharsAfter,
		:RemoveThisSubStringBefore,:RemoveThisSubStringAfter,
		:RemoveThisCharBefore,:RemoveThisCharBefore,
		:RemoveThisBound, :RemoveThisBoundingSubString,
		:CaseSensitive, :CS ])

		#NOTE// I've decided to keep CS as a suffix in the function
		# name and never use it as an internal option...

		#--> more work for me, but simpler user mental model to keep
		# things memorable

		if oList.ToStzHashList().
			KeysQR(:stzListOfStrings).
			ContainsBothCS(:CaseSensitive, :CS, FALSE)

			StzRaise("Incorrect format! :CaseSensitive and :CS can not be used both in the same time")
		ok

		if oList.ToStzHashList().
			KeysQR(:stzListOfStrings).
			ContainsBothCS(:RemoveThisBound, :RemoveThisBoundingSubString, FALSE)

			StzRaise("Incorrect format! :RemoveThisBound and :RemoveThisBoundingSubString can not be used both in the same time")
		ok

		bOk1 = FALSE
		nRemoveNCharsBefore = oList.Content()[ :RemoveNCharsBefore ]
		cType = ring_type(nRemoveNCharsBefore)
	   	if cType = "NUMBER" or ( cType = "STRING" and nRemoveNCharsBefore = NULL )
			bOk1 = TRUE
		ok

		bOk2 = FALSE
		nRemoveNCharsAfter = oList.Content()[ :RemoveNCharsAfter ]
		cType = ring_type(nRemoveNCharsAfter)
	   	if cType = "NUMBER" or ( cType = "STRING" and nRemoveNCharsAfter = NULL )
			bOk2 = TRUE
		ok

		bOk3 = FALSE
		cRemoveSubStringBefore = oList.Content()[ :RemoveSubStringBefore ]
		cType = ring_type(cRemoveSubStringBefore)
	   	if cType = "STRING"
			bOk3 = TRUE
		ok

		bOk4 = FALSE
		cRemoveSubStringAfter = This.Content()[ :RemoveSubStringAfter ]
		cType = ring_type(cRemoveSubStringAfter)
	   	if cType = "STRING"
			bOk4 = TRUE
		ok

		bOk5 = FALSE
		cRemoveThisBound = This.Content()[ :cRemoveThisBound ]
		cType = ring_type(cRemoveThisBound)
	   	if cType = "STRING"
			bOk5 = TRUE
		ok

		if bOk1 and bOk2 and bOk3 and bOk4 and bOk5
			bResult = TRUE
		ok
	ok

	return bResult

func IsTextBoxedOptionsNamedParam(paList)
	/*
	Example:

	? StzStringQ("TEXT1").BoxedXT([
		:Line = :Solid,	# or :Dashed
	
		:AllCorners = :Round # can also be :Rectangualr
		# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
	
		:Width = 17,
		:TextAdjustedTo = :Center # or :Left or :Right or :Justified,
		
		:EachChar = FALSE # TRUE,
		:Hilighted = [ 1, 3 ] # Hilight the 1st and 3rd chars,

		:Numbered = TRUE
	])
	*/

	if This.IsEmpty()
		return TRUE
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

		:PositionSign, :PositionChars,
		:Sectioned
	]

	nLen = len(paList)

	if nLen >= 1 and nLen <= len(aListOfBoxOptions)
		oList = new stzList(paList)
		if oList.IsHashList() and
		   StzHashListQ(This.Content()).KeysQ().IsMadeOfSome(aListOfBoxOptions)

			return TRUE
		ok

	ok

	return FALSE

func IsBoxOptionsNamedParam(paList)

	if This.IsEmpty()
		return TRUE
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

	nLen = len(paList)

	if nLen >= 1 and nLen <= len(aListOfBoxOptions)
		oList = new stzList(paList)
	  	if oList.IsHashList() and
	   	   oList.ToStzHashListQ().KeysQ().IsMadeOfSome(aListOfBoxOptions)
	
			return TRUE
		ok
	ok

	return FALSE

func IsConstraintsOptionsNamedParam(paList)
	/* EXAMPLE
	[
		:OnStzString = [
			:MustBeUppercase 	= '{ Q(@str).IsUppercase() }',
			:MustNotExceed@n@Chars 	= '{ Q(@str).NumberOfChars() <= n }',
			:MustBeginWithLetter@c@	= '{ Q(@str).BeginsWithCS(c, :CS = FALSE) }'
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

		return TRUE

	catch
		return FALSE
	done

#--

func IsCellNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Cell)

		return TRUE
	else
		return FALSE
	ok

func IsOfCellNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfCell)

		return TRUE
	else
		return FALSE
	ok

func IsCellsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Cells)

		return TRUE
	else
		return FALSE
	ok

func IsOfCellsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfCells)

		return TRUE
	else
		return FALSE
	ok

func IsInCellNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InCell)

		return TRUE
	else
		return FALSE
	ok

func IsInCellsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InCells)

		return TRUE
	else
		return FALSE
	ok

func IsCellValueNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :CellValue)

		return TRUE
	else
		return FALSE
	ok

func IsOfCellValueNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfCellValue)

		return TRUE
	else
		return FALSE
	ok

func IsCellPartNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :CellPart)

		return TRUE
	else
		return FALSE
	ok

func IsPartNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Part)

		return TRUE
	else
		return FALSE
	ok

func IsSubPartNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :SubPart)

		return TRUE
	else
		return FALSE
	ok
#--

func IsSubValueNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :SubValue)

		return TRUE
	else
		return FALSE
	ok

func IsOfSubValueNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfSubValue)

		return TRUE
	else
		return FALSE
	ok

func IsSubValuesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :SubValues)

		return TRUE
	else
		return FALSE
	ok

func IsOfSubValuesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfSubValues)

		return TRUE
	else
		return FALSE
	ok

#--

func IsOfCellPartNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfCellPart)

		return TRUE
	else
		return FALSE
	ok

func IsOfPartNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfPart)

		return TRUE
	else
		return FALSE
	ok

func IsOfSubPartNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfSubPart)

		return TRUE
	else
		return FALSE
	ok

#--

func IsColNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :Col or paList[1] = :Column) )

		return TRUE
	else
		return FALSE
	ok

	func IsColumnNamedParam(paList)
		return This.IsColNamedParam(paList)

func IsColNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :ColNumber or paList[1] = :ColumnNumber) )

		return TRUE
	else
		return FALSE
	ok

	func IsColumnNumberNamedParam(paList)
		return This.IsColNumberNamedParam(paList)

func IsColOrColNumberNamedParam(paList)
	if This.IsColNumberNamedParam(paList) or This.IsColNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsColOrColNumberNamedParams()
		return This.IsColOrColNumberNamedParam(paList)

	func IsColNumberOrColNamedParam(paList)
		return This.IsColOrColNumberNamedParam(paList)

	func IsColNumberOrColNamedParams()
		return This.IsColOrColNumberNamedParam(paList)

#--

func IsOfColNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :OfCol or paList[1] = :OfColumn) )

		return TRUE
	else
		return FALSE
	ok

	func IsOfColumnNamedParam(paList)
		return This.IsOfColNamedParam(paList)

func IsOfColOrColumnNamedParam(paList)
	if This.IsOfColNamedParam(paList) or This.IsOfColumnNamedParam(paList)
		return TRUE

	else
		return FALSE
	ok

	func IsOfColumnOrColNamedParam(paList)
		return This.IsOfColOrColumnNamedParam(paList)

	func IsOfColOrOfColumnNamedParam(paList)
		return This.IsOfColOrColumnNamedParam(paList)

	func IsOfColumnOrOfColNamedParam(paList)
		return This.IsOfColOrColumnNamedParam(paList)

	#--

	func IsOfColOrColumnNamedParams()
		return This.IsOfColOrColumnNamedParam(paList)

	func IsOfColumnOrColNamedParams()
		return This.IsOfColOrColumnNamedParam(paList)

	func IsOfColOrOfColumnNamedParams()
		return This.IsOfColOrColumnNamedParam(paList)

	func IsOfColumnOrOfColNamedParams()
		return This.IsOfColOrColumnNamedParam(paList)

#--

func IsInColNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :InCol or paList[1] = :InColumn) )

		return TRUE
	else
		return FALSE
	ok

	func IsInColumnNamedParam(paList)
		return This.IsInColNamedParam(paList)

func IsInColOrColumnNamedParam(paList)
	if This.IsInColNamedParam(paList) or This.IsInColumnNamedParam(paList)
		return TRUE

	else
		return FALSE
	ok

	func IsInColumnOrColNamedParam(paList)
		return This.IsInColOrColumnNamedParam(paList)

	func IsInColOrInColumnNamedParam(paList)
		return This.IsInColOrColumnNamedParam(paList)

	func IsInColumnOrInColNamedParam(paList)
		return This.IsInColOrColumnNamedParam(paList)

	#--

	func IsInColOrColumnNamedParams()
		return This.IsInColOrColumnNamedParam(paList)

	func IsInColumnOrColNamedParams()
		return This.IsInColOrColumnNamedParams()

	func IsInColOrInColumnNamedParams()
		return This.IsInColOrColumnNamedParams()

	func IsInColumnOrInColNamedParams()
		return This.IsInColOrColumnNamedParam(paList)

#--

func IsColsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :Cols or paList[1] = :Columns) )

		return TRUE
	else
		return FALSE
	ok

	func IsColumnsNamedParam(paList)
		return This.IsColsNamedParam(paList)

func IsColsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :ColsNumbers or paList[1] = :ColumnsNumbers) )

		return TRUE
	else
		return FALSE
	ok

	func IsColumnsNumbersNamedParam(paList)
		return This.IsColsNumbersNamedParam(paList)

func IsColsOrColsNumberNamedParam(paList)
	if This.IsColsNumbersNamedParam(paList) or This.IsColsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsColsNumbersOrColsNamedParam(paList)
		return This.IsColsOrColsNumberNamedParam(paList)

	func IsColsOrColsNumberNamedParams()
		return This.IsColsOrColsNumberNamedParam(paList)

	func IsColsNumbersOrColsNamedParams()
		return This.IsColsOrColsNumberNamedParam(paList)

#--

func IsOfColsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :OfCols or paList[1] = :OfColumns) )

		return TRUE
	else
		return FALSE
	ok

	func IsOfColumnsNamedParam(paList)
		return This.IsOfColsNamedParam(paList)

func IsOfColsOrColumnsNamedParam(paList)
	if This.IsOfColsNamedParam(paList) or This.IsOfColumnsNamedParam(paList)
		return TRUE

	else
		return FALSE
	ok

	func IsOfColumnsOrColsNamedParam(paList)
		return This.IsOfColsOrColumnsNamedParam(paList)

	func IsOfColsOrOfColumnsNamedParam(paList)
		return This.IsOfColsOrColumnsNamedParam(paList)

	func IsOfColumnsOrOfColsNamedParam(paList)
		return This.IsOfColsOrColumnsNamedParam(paList)

	#--

	func IsOfColsOrColumnsNamedParams()
		return This.IsOfColsOrColumnsNamedParam(paList)

	func IsOfColumnsOrColsNamedParams()
		return This.IsOfColsOrColumnsNamedParam(paList)

	func IsOfColsOrOfColumnsNamedParams()
		return This.IsOfColsOrColumnsNamedParam(paList)

	func IsOfColumnsOrOfColsNamedParams()
		return This.IsOfColsOrColumnsNamedParam(paList)

#--

func IsInColsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :InCols or paList[1] = :InColumns) )

		return TRUE
	else
		return FALSE
	ok

	func IsInColumnsNamedParam(paList)
		return This.IsInColsNamedParam(paList)

func IsInColsOrColumnsNamedParam(paList)
	if This.IsInColsNamedParam(paList) or This.IsInColumnsNamedParam(paList)
		return TRUE

	else
		return FALSE
	ok

	func IsInColumnsOrColNamedParam(paList)
		return This.IsInColsOrColumnsNamedParam(paList)

	func IsInColsOrInColumnsNamedParam(paList)
		return This.IsInColsOrColumnsNamedParam(paList)

	func IsInColumnsOrInColNamedParam(paList)
		return This.IsInColsOrColumnsNamedParam(paList)

	#--

	func IsInColsOrColumnsNamedParams()
		return This.IsInColsOrColumnsNamedParam(paList)

	func IsInColumnsOrColNamedParams()
		return This.IsInColsOrColumnsNamedParam(paList)

	func IsInColsOrInColumnsNamedParams()
		return This.IsInColsOrColumnsNamedParam(paList)

	func IsInColumnsOrInColNamedParams()
		return This.IsInColsOrColumnsNamedParam(paList)

#==

func IsByColNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :ByColNumber or paList[1] = :ByColumnNumber) )

		return TRUE
	else
		return FALSE
	ok

	func IsByColumnNumberNamedParam(paList)
		return This.IsByColNumberNamedParam(paList)

func IsByColOrByColNumberNamedParam(paList)
	if This.IsByColNumberNamedParam(paList) or This.IsByColNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByColOrByColNumberNamedParams()
		return This.IsByColOrByColNumberNamedParam(paList)

	func IsByColNumberOrByColNamedParam(paList)
		return This.IsByColOrByColNumberNamedParam(paList)

	func IsByColNumberOrColNamedParams()
		return This.IsByColOrByColNumberNamedParam(paList)

func IsByColsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :ByColsNumbers or paList[1] = :ByColumnsNumbers) )

		return TRUE
	else
		return FALSE
	ok

	func IsByColumnsNumbersNamedParam(paList)
		return This.IsByColsNumbersNamedParam(paList)

func IsByColsOrByColsNumbersNamedParam(paList)
	if This.IsByColsNumbersNamedParam(paList) or This.IsByColsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByColsOrByColsNumbersNamedParams()
		return This.IsByColsOrByColsNumbersNamedParam(paList)

	func IsByColsNumbersOrByColsNamedParam(paList)
		return This.IsByColsOrByColsNumbersNamedParam(paList)

	func IsByColsNumbersOrColsNamedParams()
		return This.IsByColsOrColsNumberNamedParam(paList)

#--

func IsInColNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :InColNumber or paList[1] = :InColumnNumber) )

		return TRUE
	else
		return FALSE
	ok

	func IsInColumnNumberNamedParam(paList)
		return This.IsInColNumberNamedParam(paList)

func IsInColOrInColNumberNamedParam(paList)
	if This.IsInColNumberNamedParam(paList) or This.IsInColNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInColOrInColNumberNamedParams()
		return This.IsInColOrInColNumberNamedParam(paList)

	func IsInColNumberOrInColNamedParam(paList)
		return This.IsInColOrInColNumberNamedParam(paList)

	func IsInColInNumberOrColNamedParams()
		return This.IsInColOrInColNumberNamedParam(paList)

func IsInColsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :InColsNumbers or paList[1] = :InColumnsNumbers) )

		return TRUE
	else
		return FALSE
	ok

	func IsInColumnsNumbersNamedParam(paList)
		return This.IsInColsNumbersNamedParam(paList)

func IsInColsOrInColsNumbersNamedParam(paList)
	if This.IsInColsNumbersNamedParam(paList) or This.IsInColsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInColsOrInColsNumbersNamedParams()
		return This.IsInColsOrInColsNumbersNamedParam(paList)

	func IsInColsNumbersOrInColsNamedParam(paList)
		return This.IsInColsOrinColsNumbersNamedParam(paList)

	func IsInColsNumbersOrInColsNamedParams()
		return This.IsInColsOrInColsNumberNamedParam(paList)

#--

func IsOfColNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :OfColNumber or paList[1] = :OfColumnNumber) )

		return TRUE
	else
		return FALSE
	ok

	func IsOfColumnNumberNamedParam(paList)
		return This.IsOfColNumberNamedParam(paList)

func IsOfColOrOfColNumberNamedParam(paList)
	if This.IsOfColNumberNamedParam(paList) or This.IsOfColNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfColOrOfColNumberNamedParams()
		return This.IsOfColOrOfColNumberNamedParam(paList)

	func IsOfColNumberOrOfColNamedParam(paList)
		return This.IsOfColOrOfColNumberNamedParam(paList)

	func IsOfColNumberOrOfColNamedParams()
		return This.IsOfColOrOfColNumberNamedParam(paList)

func IsOfColsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :OfColsNumbers or paList[1] = :OfColumnsNumbers) )

		return TRUE
	else
		return FALSE
	ok

	func IsOfColumnsNumbersNamedParam(paList)
		return This.IsOfColsNumbersNamedParam(paList)

func IsOfColsOrOfColsNumbersNamedParam(paList)
	if This.IsOfColsNumbersNamedParam(paList) or This.IsOfColsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfColsOrOfColsNumbersNamedParams()
		return This.IsOfColsOrOFColsNumbersNamedParam(paList)

	func IsOfColsNumbersOrOfColsNamedParam(paList)
		return This.IsOfColsOrOfColsNumbersNamedParam(paList)

	func IsOfColsNumbersOrOfColsNamedParams()
		return This.IsOfColsOrOfColsNumberNamedParam(paList)

#--

func IsToColNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :ToColNumber or paList[1] = :ToColumnNumber) )

		return TRUE
	else
		return FALSE
	ok

	func IsToColumnNumberNamedParam(paList)
		return This.IsToColNumberNamedParam(paList)

func IsToColOrToColNumberNamedParam(paList)
	if This.IsToColNumberNamedParam(paList) or This.IsToColNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToColOrToColNumberNamedParams()
		return This.IsToColOrToColNumberNamedParam(paList)

	func IsToColNumberOrToColNamedParam(paList)
		return This.IsToColOrToColNumberNamedParam(paList)

	func IsToColNumberOrToColNamedParams()
		return This.IsToColOrToColNumberNamedParam(paList)

func IsToColsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :ToColsNumbers or paList[1] = :ToColumnsNumbers) )

		return TRUE
	else
		return FALSE
	ok

	func IsToColumnsNumbersNamedParam(paList)
		return This.IsToColsNumbersNamedParam(paList)

func IsToColsOrToColsNumbersNamedParam(paList)
	if This.IsToColsNumbersNamedParam(paList) or This.IsToColsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToColsOrToColsNumbersNamedParams()
		return This.IsToColsOrToColsNumbersNamedParam(paList)

	func IsToColsNumbersOrToColsNamedParam(paList)
		return This.IsToColsOrToColsNumbersNamedParam(paList)

	func IsToColsNumbersOrtoColsNamedParams()
		return This.IsToColsOrToColsNumberNamedParam(paList)

#--

func IsUsingColNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :UsingColNumber or paList[1] = :UsingColumnNumber) )

		return TRUE
	else
		return FALSE
	ok

	func IsUsingColumnNumberNamedParam(paList)
		return This.IsUsingColNumberNamedParam(paList)

func IsUsingColOrUsingColNumberNamedParam(paList)
	if This.IsUsingColNumberNamedParam(paList) or This.IsUsingColNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsUsingColOrUsingColNumberNamedParams()
		return This.IsUsingColOrUsingColNumberNamedParam(paList)

	func IsUsingColNumberOrUsingColNamedParam(paList)
		return This.IsUsingColOrUsingColNumberNamedParam(paList)

	func IsUsingColNumberOrUsingColNamedParams()
		return This.IsUsingColOrUsingColNumberNamedParam(paList)

func IsUsingColsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :UsingColsNumbers or paList[1] = :UsingColumnsNumbers) )

		return TRUE
	else
		return FALSE
	ok

	func IsUsingColumnsNumbersNamedParam(paList)
		return This.IsUsingColsNumbersNamedParam(paList)

func IsUsingColsOrUsingColsNumbersNamedParam(paList)
	if This.IsUsingColsNumbersNamedParam(paList) or This.IsUsingColsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsUsingColsOrUsingColsNumbersNamedParams()
		return This.IsUsingColsOrUsingColsNumbersNamedParam(paList)

	func IsUsingColsNumbersOrUsingColsNamedParam(paList)
		return This.IsUsingColsOrUsingColsNumbersNamedParam(paList)

	func IsUsingColsNumbersOrUsingColsNamedParams()
		return This.IsUsingColsOrUsingColsNumberNamedParam(paList)

#--

func IsWithColNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :WithColNumber or paList[1] = :WithColumnNumber) )

		return TRUE
	else
		return FALSE
	ok

	func IsWithColumnNumberNamedParam(paList)
		return This.IsWithColNumberNamedParam(paList)

func IsWithColOrWithColNumberNamedParam(paList)
	if This.IsWithColNumberNamedParam(paList) or This.IsWithColNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithColOrWithColNumberNamedParams()
		return This.IsWithColOrWithColNumberNamedParam(paList)

	func IsWithColNumberOrWithColNamedParam(paList)
		return This.IsWithColOrWithColNumberNamedParam(paList)

	func IsWithColNumberOrWithColNamedParams()
		return This.IsWithColOrWithColNumberNamedParam(paList)

func IsWithColsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :WithColsNumbers or paList[1] = :WithColumnsNumbers) )

		return TRUE
	else
		return FALSE
	ok

	func IsWithColumnsNumbersNamedParam(paList)
		return This.IsWithColsNumbersNamedParam(paList)

func IsWithColsOrWithColsNumbersNamedParam(paList)
	if This.IsWithColsNumbersNamedParam(paList) or This.IsWithColsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithColsOrWithColsNumbersNamedParams()
		return This.IsWithColsOrWithColsNumbersNamedParam(paList)

	func IsWithColsNumbersOrWithColsNamedParam(paList)
		return This.IsWithColsOrWithColsNumbersNamedParam(paList)

	func IsWithColsNumbersOrWithColsNamedParams()
		return This.IsWithColsOrColsNumberNamedParam(paList)

#==

func IsByRowNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ByRowNumber )

		return TRUE
	else
		return FALSE
	ok


func IsByRowOrByRowNumberNamedParam(paList)
	if This.IsByRowNumberNamedParam(paList) or This.IsByRowNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByRowOrByRowNumberNamedParams()
		return This.IsByRowOrByRowNumberNamedParam(paList)

	func IsByRowNumberOrByRowNamedParam(paList)
		return This.IsByRowOrByRowNumberNamedParam(paList)

	func IsByRowNumberOrByRowNamedParams()
		return This.IsByRowOrByRowNumberNamedParam(paList)

func IsByRowsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ByRowsNumbers )

		return TRUE
	else
		return FALSE
	ok

func IsByRowsOrByRowsNumbersNamedParam(paList)
	if This.IsByRowsNumbersNamedParam(paList) or This.IsByRowsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByRowsOrByRowsNumbersNamedParams()
		return This.IsByRowsOrByRowsNumbersNamedParam(paList)

	func IsByRowsNumbersOrByRowsNamedParam(paList)
		return This.IsByRowsOrByRowsNumbersNamedParam(paList)

	func IsByRowsNumbersOrByRowsNamedParams()
		return This.IsByRowsOrByRowsNumberNamedParam(paList)

#--

func IsInRowNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InRowNumber )

		return TRUE
	else
		return FALSE
	ok

func IsInRowOrInRowNumberNamedParam(paList)
	if This.IsInRowNumberNamedParam(paList) or This.IsInRowNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInRowOrInRowNumberNamedParams()
		return This.IsInRowOrInRowNumberNamedParam(paList)

	func IsInRowNumberOrInRowNamedParam(paList)
		return This.IsInRowOrInRowNumberNamedParam(paList)

	func IsInRowNumberOrInRowNamedParams()
		return This.IsInRowOrInRowNumberNamedParam(paList)

func IsInRowsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InRowsNumbers )

		return TRUE
	else
		return FALSE
	ok

func IsInRowsOrInRowsNumbersNamedParam(paList)
	if This.IsInRowsNumbersNamedParam(paList) or This.IsInRowsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInRowsOrInRowsNumbersNamedParams()
		return This.IsInRowsOrInRowsNumbersNamedParam(paList)

	func IsInRowsNumbersOrInRowsNamedParam(paList)
		return This.IsInRowsOrInRowsNumbersNamedParam(paList)

	func IsInRowsNumbersOrInRowsNamedParams()
		return This.IsInRowsOrInRowsNumberNamedParam(paList)

#--

func IsOfRowNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfRowNumber )

		return TRUE
	else
		return FALSE
	ok

func IsOfRowOrOfRowNumberNamedParam(paList)
	if This.IsOfRowNumberNamedParam(paList) or This.IsOfRowNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfRowOrOfRowNumberNamedParams()
		return This.IsOfRowOrOfRowNumberNamedParam(paList)

	func IsOfRowNumberOrOfRowNamedParam(paList)
		return This.IsOfRowOrOfRowNumberNamedParam(paList)

	func IsOfRowNumberOrOfRowNamedParams()
		return This.IsOfRowOrOfRowNumberNamedParam(paList)

func IsOfRowsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfRowsNumbers )

		return TRUE
	else
		return FALSE
	ok

func IsOfRowsOrOfRowsNumbersNamedParam(paList)
	if This.IsOfRowsNumbersNamedParam(paList) or This.IsOfRowsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfRowsOrOfRowsNumbersNamedParams()
		return This.IsOfRowsOrOfRowsNumbersNamedParam(paList)

	func IsOfRowsNumbersOrOfRowsNamedParam(paList)
		return This.IsOfRowsOrOfRowsNumbersNamedParam(paList)

	func IsOfRowsNumbersOrOfRowsNamedParams()
		return This.IsOfRowsOrOfRowsNumberNamedParam(paList)

#--

func IsToRowNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToRowNumber )

		return TRUE
	else
		return FALSE
	ok

func IsToRowOrToRowNumberNamedParam(paList)
	if This.IsToRowNumberNamedParam(paList) or This.IsToRowNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToRowOrToRowNumberNamedParams()
		return This.IsToRowOrToRowNumberNamedParam(paList)

	func IsToRowNumberOrToRowNamedParam(paList)
		return This.IsToRowOrToRowNumberNamedParam(paList)

	func IsToRowNumberOrToRowNamedParams()
		return This.IsToRowOrToRowNumberNamedParam(paList)

func IsToRowsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToRowsNumbers )

		return TRUE
	else
		return FALSE
	ok

func IsToRowsOrToRowsNumbersNamedParam(paList)
	if This.IsToRowsNumbersNamedParam(paList) or This.IsToRowsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToRowsOrToRowsNumbersNamedParams()
		return This.IsToRowsOrToRowsNumbersNamedParam(paList)

	func IsToRowsNumbersOrToRowsNamedParam(paList)
		return This.IsToRowsOrToRowsNumbersNamedParam(paList)

	func IsToRowsNumbersOrToRowsNamedParams()
		return This.IsToRowsOrToRowsNumberNamedParam(paList)

#--

func IsUsingRowNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingRowNumber )

		return TRUE
	else
		return FALSE
	ok

func IsUsingRowOrUsingRowNumberNamedParam(paList)
	if This.IsUsingRowNumberNamedParam(paList) or This.IsUsingRowNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsUsingRowOrUsingRowNumberNamedParams()
		return This.IsUsingRowOrUsingRowNumberNamedParam(paList)

	func IsUsingRowNumberOrUsingRowNamedParam(paList)
		return This.IsUsingRowOrUsingRowNumberNamedParam(paList)

	func IsUsingRowNumberOrUsingRowNamedParams()
		return This.IsUsingRowOrUsingRowNumberNamedParam(paList)

func IsUsingRowsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingRowsNumbers )

		return TRUE
	else
		return FALSE
	ok

func IsUsingRowsOrUsingRowsNumbersNamedParam(paList)
	if This.IsUsingRowsNumbersNamedParam(paList) or This.IsUsingRowsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsUsingRowsOrUsingRowsNumbersNamedParams()
		return This.IsUsingRowsOrUsingRowsNumbersNamedParam(paList)

	func IsUsingRowsNumbersOrUsingRowsNamedParam(paList)
		return This.IsUsingRowsOrUsingRowsNumbersNamedParam(paList)

	func IsUsingRowsNumbersOrUsingRowsNamedParams()
		return This.IsUsingRowsOrUsingRowsNumberNamedParam(paList)

#--

func IsWithRowNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :WithRowNumber )

		return TRUE
	else
		return FALSE
	ok

func IsWithRowOrWithRowNumberNamedParam(paList)
	if This.IsWithRowNumberNamedParam(paList) or This.IsWithRowNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithRowOrWithRowNumberNamedParams()
		return This.IsWithRowOrWithRowNumberNamedParam(paList)

	func IsWithRowNumberOrWithRowNamedParam(paList)
		return This.IsWithRowOrWithRowNumberNamedParam(paList)

	func IsWithRowNumberOrWithRowNamedParams()
		return This.IsWithRowOrWithRowNumberNamedParam(paList)

func IsWithRowsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :WithRowsNumbers )

		return TRUE
	else
		return FALSE
	ok

func IsWithRowsOrWithRowsNumbersNamedParam(paList)
	if This.IsWithRowsNumbersNamedParam(paList) or This.IsWithRowsNumbersNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithRowsOrWithRowsNumbersNamedParams()
		return This.IsWithRowsOrWithRowsNumbersNamedParam(paList)

	func IsWithRowsNumbersOrWithRowsNamedParam(paList)
		return This.IsWithRowsOrWithRowsNumbersNamedParam(paList)

	func IsWithRowsNumbersOrWithRowsNamedParams()
		return This.IsWithRowsOrWithRowsNumberNamedParam(paList)

#==

func IsRowNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Row)

		return TRUE
	else
		return FALSE
	ok

func IsOfRowNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfRow)

		return TRUE
	else
		return FALSE
	ok

func IsInRowNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InRow)

		return TRUE
	else
		return FALSE
	ok

func IsRowsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Rows)

		return TRUE
	else
		return FALSE
	ok

func IsOfRowsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfRows)

		return TRUE
	else
		return FALSE
	ok

func IsInRowsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InRows)

		return TRUE
	else
		return FALSE
	ok

#--

func IsOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Occurrence)

		return TRUE
	else
		return FALSE
	ok

func IsNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Nth)

		return TRUE
	else
		return FALSE
	ok

func IsNthOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :NthOccurrence)

		return TRUE
	else
		return FALSE
	ok

func IsNNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :N)

		return TRUE
	else
		return FALSE
	ok
#--

func IsCaseSensitiveNamedParam(paList)
	aContent = This.Content()
	nLen = len(aContent)

	if NOT nLen = 2
		return FALSE
	ok

	if NOT isString(aContent[1])
		return FALSE
	ok

	if NOT isNumber(aContent[2])
		return FALSE
	ok

	if NOT ( aContent[1] = :CaseSensitive or aContent[1] = :CS )
		return FALSE
	ok

	if NOT ( aContent[2] = 0 or aContent[2] = 1 )
		return FALSE
	ok

	return TRUE

func IsRangeNamedParam(paList)

	if This.IsEmpty()
		return TRUE
	ok

	if NOT (This.IsHashList() and isList(paList) and len(paList) <= 2)
		return FALSE
	ok

	if isList(paList) and len(paList) = 1

		if paList[1][1] = :Start or paList[1][1] = :Range
			return TRUE
		ok
	ok

	if isList(paList) and len(paList) = 2

		if StzHashListQ( This.List() ).KeysQ().IsEqualTo([ :Start, :Range ]) and
		   StzHashListQ( This.List() ).ValuesQ().BothAreNumbers()

			return TRUE

		else

			return FALSE
		ok
	ok


#--

func IsStartingAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StartingAt )

		return TRUE

	else
		return FALSE
	ok

func IsStartingAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StartingAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsStartingAtOrStartingAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :StartingAtPosition or
		 paList[1] = :StartingAt) )

		return TRUE

	else
		return FALSE
	ok

	func IsStartingAtPositionOrStartingAtNamedParam(paList)
		return This.IsStartingAtOrStartingAtPositionNamedParam(paList)

func IsStartingAtOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StartingAtOccurrence )

		return TRUE

	else
		return FALSE
	ok

func IsStartAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StartAt )

		return TRUE

	else
		return FALSE
	ok

func IsStartsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StartAts )

		return TRUE

	else
		return FALSE
	ok

func IsStartAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StartAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsStartsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StartsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsStartAtOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StartAtOccurrence )

		return TRUE

	else
		return FALSE
	ok

func IsStartsAtOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StartsAtOccurrence )

		return TRUE

	else
		return FALSE
	ok

#--

func IsEndAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndAt )

		return TRUE

	else
		return FALSE
	ok

func IsEndsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndsAt )

		return TRUE

	else
		return FALSE
	ok

func IsEndingAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndingAt )

		return TRUE

	else
		return FALSE
	ok

func IsEndAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndAtPosition )

		return TRUE

	else
		return FALSE
	ok



func IsEndsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsEndingAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndingAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsEndingAtOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndingAtOccurrence )

		return TRUE

	else
		return FALSE
	ok

func IsStopAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StopAt )

		return TRUE

	else
		return FALSE
	ok

func IsStopsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StopsAt )

		return TRUE

	else
		return FALSE
	ok

func IsStopAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StopAt )

		return TRUE

	else
		return FALSE
	ok

func IsStopsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StopsAt )

		return TRUE

	else
		return FALSE
	ok

func IsEndiingAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndingAt )

		return TRUE

	else
		return FALSE
	ok

func IsStoppingAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StoppingAtPosition )

		return TRUE

	else
		return FALSE
	ok

#--

func IsStoppingAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StoppingAt )

		return TRUE

	else
		return FALSE
	ok

func IsStoppingAtOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StoppingAtOccurrence )

		return TRUE

	else
		return FALSE
	ok

func IsStopAtOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StopAtOccurrence )

		return TRUE

	else
		return FALSE
	ok

func IsStopsAtOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StopsAtOccurrence )

		return TRUE

	else
		return FALSE
	ok

func IsendAtOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndAtOccurrence )

		return TRUE

	else
		return FALSE
	ok

func IsendsAtOccurrenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EndsAtOccurrence )

		return TRUE

	else
		return FALSE
	ok

#--

func IsInStringNNamedParam(paList)
	if isList(paList) and len(paList) = 2 and

	   ( isString(paList[1]) and
	     ring_find([ :InStringAt, :inStringAtPosition, :InStringN ], paList[1]) > 0 )

		return TRUE

	else
		return FALSE
	ok

	func IsInStringAtPositionNNamedParam(paList)
		return This.IsInStringNNamedParam(paList)

	func IsInStringAtPositionNamedParam(paList)
		return This.IsInStringNNamedParam(paList)

func IsExceptNamedParam(paList)
	# Used initially by ReplaceWordsWithMarquersExceptXT(pcByOption, paExcept)
	#TODO // generalize to all the functions we want to provide exceptions to it

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Except )

		return TRUE

	else
		return FALSE
	ok

func IsAsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :As )

		return TRUE

	else
		return FALSE
	ok

func IsThenNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  (paList[1] = :Then or paList[1] = :Then@) )

		return TRUE

	else
		return FALSE
	ok

func IsAndThenNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  (paList[1] = :AndThen or paList[1] = :AndThen@) )

		return TRUE

	else
		return FALSE
	ok

func IsFromFileNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and  paList[1] = :FromFile

		return TRUE

	else
		return FALSE
	ok

func IsFromNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  (paList[1] = :From or paList[1] = :FromPosition)  )

		return TRUE

	else
		return FALSE
	ok

func IsFromOrOfNamedParam(paList)
	if This.IsFromNamedParam(paList) or This.IsOfNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsFromOrOfNamedParams()
		return This.IsFromOrOfNamedParam(paList)

	func IsOfOrFromNamedParam(paList)
		return This.IsFromOrOfNamedParam(paList)

	func IsOfOrFromNamedParams()
		return This.IsFromOrOfNamedParam(paList)

#--

func IsFromCellNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCell )

		return TRUE

	else
		return FALSE
	ok

func IsFromCellAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCellAt )

		return TRUE

	else
		return FALSE
	ok

func IsFromCellAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCellAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsFromCellsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCells )

		return TRUE

	else
		return FALSE
	ok

func IsFromCellsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCellsAt )

		return TRUE

	else
		return FALSE
	ok

func IsFromCellsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCellsAtPositions )

		return TRUE

	else
		return FALSE
	ok

#--

func IsToCellNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCell )

		return TRUE

	else
		return FALSE
	ok

func IsToCellAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCellAt )

		return TRUE

	else
		return FALSE
	ok

func IsToCellAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCellAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsToCellsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCells )

		return TRUE

	else
		return FALSE
	ok

func IsToCellsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCellsAt )

		return TRUE

	else
		return FALSE
	ok

func IsToCellsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCellsAtPositions )

		return TRUE

	else
		return FALSE
	ok

#--

func IsValueNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Value )

		return TRUE

	else
		return FALSE
	ok

func IsOfValueNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfValue )

		return TRUE

	else
		return FALSE
	ok

func IsValuesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Values )

		return TRUE

	else
		return FALSE
	ok

func IsStringOrSubStringNamedParam(paList)
	if This.IsStringNamedParam(paList) or This.IsSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsStringOrSubStringNamedParams()
		return This.IsStringOrSubStringNamedParam(paList)

	func IsSubStringOrStringONamedParam(paList)
		return This.IsStringOrSubStringNamedParam(paList)

	func IsSubStringOrStringONamedParams()
		return This.IsStringOrSubStringNamedParam(paList)

#--

func IsToOrOfNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsOfNamedParam(paList)
		return TRUE

	else
		return FALSE
	ok

	func IsToOrOfNamedParams()
		return This.IsToOrOfNamedParam(paList)

	func IsOfOrToNamedParam(paList)
		return This.IsToOrOfNamedParam(paList)

	func IsOfOrToNamedParams()
		return This.IsToOrOfNamedParam(paList)

#==

func IsToNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToNumber )

		return TRUE

	else
		return FALSE
	ok

func IsToNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToNumbers )

		return TRUE

	else
		return FALSE
	ok

func IsToStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToString )

		return TRUE

	else
		return FALSE
	ok

func IsToSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToSubString )

		return TRUE

	else
		return FALSE
	ok

func IsToSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToSubStrings )

		return TRUE

	else
		return FALSE
	ok

func IsToCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToChar )

		return TRUE

	else
		return FALSE
	ok

func IsToListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToList )

		return TRUE

	else
		return FALSE
	ok

func IsToListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToLists )

		return TRUE

	else
		return FALSE
	ok

func IsToPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToPair )

		return TRUE

	else
		return FALSE
	ok

func IsToHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToHashList )

		return TRUE

	else
		return FALSE
	ok

func IsToSetNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToSet )

		return TRUE

	else
		return FALSE
	ok

func IsToObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToObject )

		return TRUE

	else
		return FALSE
	ok

func IsToObjectsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToObjects )

		return TRUE

	else
		return FALSE
	ok

#--

func IsToOrToNumberNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsToNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToNumberOrToNamedParam(paList)
		return This.IsToOrToNumberNamedParam(paList)

	func IsToOrToNumberNamedParams()
		return This.IsToOrToNumberNamedParam(paList)

	func IsToNumberOrToNamedParams()
		return This.IsToOrToNumberNamedParam(paList)

func IsToOrToCharNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsToCharNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToCharOrToNamedParam(paList)
		return This.IsToOrToCharNamedParam(paList)

	func IsToOrToCharNamedParams()
		return This.IsToOrToCharNamedParam(paList)

	func IsToCharOrToNamedParams()
		return This.IsToOrToCharNamedParam(paList)

func IsToOrToStringNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsToStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToStringOrToNamedParam(paList)
		return This.IsToOrToStringNamedParam(paList)

	func IsToOrToStringNamedParams()
		return This.IsToOrToStringNamedParam(paList)

	func IsToStringOrToNamedParams()
		return This.IsToOrToStringNamedParam(paList)

func IsToOrToSubStringNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsToSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToSubStringOrToNamedParam(paList)
		return This.IsToOrToSubStringNamedParam(paList)

	func IsToOrToSubStringNamedParams()
		return This.IsToOrToSubStringNamedParam(paList)

	func IsToSubStringOrToNamedParams()
		return This.IsToOrToSubStringNamedParam(paList)

func IsToOrToListNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsToListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToListOrToNamedParam(paList)
		return This.IsToOrToListNamedParam(paList)

	func IsToOrToListNamedParams()
		return This.IsToOrToListNamedParam(paList)

	func IsToListOrToNamedParams()
		return This.IsToOrToListNamedParam(paList)

func IsToOrToHashListNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsToHashListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToHashListOrToNamedParam(paList)
		return This.IsToOrToHashListNamedParam(paList)

	func IsToOrToHashListNamedParams()
		return This.IsToOrToHashListNamedParam(paList)

	func IsToHashListOrToNamedParams()
		return This.IsToOrToHashListNamedParam(paList)

func IsToOrToPairNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsToPairNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToPairOrToNamedParam(paList)
		return This.IsToOrToPairNamedParam(paList)

	func IsToOrToPairNamedParams()
		return This.IsToOrToPairNamedParam(paList)

	func IsToPairOrToNamedParams()
		return This.IsToOrToPairNamedParam(paList)

func IsToOrToSetNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsToSetNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToSetOrToNamedParam(paList)
		return This.IsToOrToSetNamedParam(paList)

	func IsToOrToSetNamedParams()
		return This.IsToOrToSetNamedParam(paList)

	func IsToSetOrToNamedParams()
		return This.IsToOrToSetNamedParam(paList)

func IsToOrToObjectNamedParam(paList)
	if This.IsToNamedParam(paList) or This.IsToObjectNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsToStringOrToObjectParam()
		return This.IsToOrToStringNamedParam(paList)

	func IsToOrToObjectNamedParams()
		return This.IsToOrToObjectNamedParam(paList)

	func IsToStringOrToObjectParams()
		return This.IsToOrToStringNamedParam(paList)

#==

func IsOfNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfNumber )

		return TRUE

	else
		return FALSE
	ok

func IsOfStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfString )

		return TRUE

	else
		return FALSE
	ok

func IsOfSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfSubString )

		return TRUE

	else
		return FALSE
	ok

func IsOfCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfChar )

		return TRUE

	else
		return FALSE
	ok

func IsOfListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfList )

		return TRUE

	else
		return FALSE
	ok

func IsOfPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfPair )

		return TRUE

	else
		return FALSE
	ok

func IsOfHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfHashList )

		return TRUE

	else
		return FALSE
	ok

func IsOfSetNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfSet )

		return TRUE

	else
		return FALSE
	ok

func IsOfObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfObject )

		return TRUE

	else
		return FALSE
	ok

#--

func IsOfOrOfNumberNamedParam(paList)
	if This.IsOfNamedParam(paList) or This.IsOfNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfNumberOrOfNamedParam(paList)
		return This.IsOfOrOfNumberNamedParam(paList)

	func IsOfOrOfNumberNamedParams()
		return This.IsOfOrOfNumberNamedParam(paList)

	func IsOfNumberOrOfNamedParams()
		return This.IsOfOrOfNumberNamedParam(paList)

func IsOfOrOfCharNamedParam(paList)
	if This.IsOfNamedParam(paList) or This.IsOfCharNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfCharOrOfNamedParam(paList)
		return This.IsOfOrOfCharNamedParam(paList)

	func IsOfOrOfCharNamedParams()
		return This.IsOfOrOfCharNamedParam(paList)

	func IsOfCharOrOfNamedParams()
		return This.IsOfOrOfCharNamedParam(paList)

func IsOfOrOfStringNamedParam(paList)
	if This.IsOfNamedParam(paList) or This.IsOfStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfStringOrOfNamedParam(paList)
		return This.IsOfOrOfStringNamedParam(paList)

	func IsOfOrOfStringNamedParams()
		return This.IsOfOrOfStringNamedParam(paList)

	func IsOfStringOrOfNamedParams()
		return This.IsOfOrOfStringNamedParam(paList)

func IsOfOrOfSubStringNamedParam(paList)
	if This.IsOfNamedParam(paList) or This.IsOfSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfSubStringOrOfNamedParam(paList)
		return This.IsOfOrOfSubStringNamedParam(paList)

	func IsOfOrOfSubStringNamedParams()
		return This.IsOfOrOfSubStringNamedParam(paList)

	func IsOfSubStringOrOfNamedParams()
		return This.IsOfOrOfSubStringNamedParam(paList)

func IsOfOrOfListNamedParam(paList)
	if This.IsOfNamedParam(paList) or This.IsOfListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfListOrOfNamedParam(paList)
		return This.IsOfOrOfListNamedParam(paList)

	func IsOfOrOfListNamedParams()
		return This.IsOfOrOfListNamedParam(paList)

	func IsOfListOrOfNamedParams()
		return This.IsOfOrOfListNamedParam(paList)

func IsOfOrOfHashListNamedParam(paList)
	if This.IsOfNamedParam(paList) or This.IsOfHashListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfHashListOrOfNamedParam(paList)
		return This.IsOfOrOfHashListNamedParam(paList)

	func IsOfOrOfHashListNamedParams()
		return This.IsOfOrOfHashListNamedParam(paList)

	func IsOfHashListOrOfNamedParams()
		return This.IsOfOrOfHashListNamedParam(paList)

func IsOfOrOfPairNamedParam(paList)
	if This.IsOfNamedParam(paList) or This.IsOfPairNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfPairOrOfNamedParam(paList)
		return This.IsOfOrOfPairNamedParam(paList)

	func IsOfOrOfPairNamedParams()
		return This.IsOfOrOfPairNamedParam(paList)

	func IsOfPairOrOfNamedParams()
		return This.IsOfOrOfPairNamedParam(paList)

func IsOfOrOfSetNamedParam(paList)
	if This.IsOfNamedParam(paList) or This.IsOfSetNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfSetOrOfNamedParam(paList)
		return This.IsOfOrOfSetNamedParam(paList)

	func IsOfOrOfSetNamedParams()
		return This.IsOfOrOfSetNamedParam(paList)

	func IsOfSetOrOfNamedParams()
		return This.IsOfOrOfSetNamedParam(paList)

func IsOfOrOfObjectNamedParam(paList)
	if This.IsOfNamedParam(paList) or This.IsOfObjectNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfStringOrOfObjectParam()
		return This.IsOfOrOfStringNamedParam(paList)

	func IsOfOrOfObjectNamedParams()
		return This.IsOfOrOfObjectNamedParam(paList)

	func IsOfStringOrOfObjectParams()
		return This.IsOfOrOfStringNamedParam(paList)

#==

func IsByNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ByNumber )

		return TRUE

	else
		return FALSE
	ok

func IsByStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ByString )

		return TRUE

	else
		return FALSE
	ok

func IsBySubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BySubString )

		return TRUE

	else
		return FALSE
	ok

func IsByCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ByChar )

		return TRUE

	else
		return FALSE
	ok

func IsByListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ByList )

		return TRUE

	else
		return FALSE
	ok

func IsByPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ByPair )

		return TRUE

	else
		return FALSE
	ok

func IsByHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ByHashList )

		return TRUE

	else
		return FALSE
	ok

func IsBySetNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BySet )

		return TRUE

	else
		return FALSE
	ok

func IsByObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ByObject )

		return TRUE

	else
		return FALSE
	ok

#--

func IsByOrByNumberNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsByNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByNumberOrByNamedParam(paList)
		return This.IsByOrByNumberNamedParam(paList)

	func IsByOrByNumberNamedParams()
		return This.IsByOrByNumberNamedParam(paList)

	func IsByNumberOrByNamedParams()
		return This.IsByOrByNumberNamedParam(paList)

func IsByOrByCharNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsByCharNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByCharOrByNamedParam(paList)
		return This.IsByOrByCharNamedParam(paList)

	func IsByOrByCharNamedParams()
		return This.IsByOrByCharNamedParam(paList)

	func IsByCharOrByNamedParams()
		return This.IsByOrByCharNamedParam(paList)

func IsByOrByStringNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsByStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByStringOrByNamedParam(paList)
		return This.IsByOrByStringNamedParam(paList)

	func IsByOrByStringNamedParams()
		return This.IsByOrByStringNamedParam(paList)

	func IsByStringOrByNamedParams()
		return This.IsByOrByStringNamedParam(paList)

func IsByOrBySubStringNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsBySubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsBySubStringOrByNamedParam(paList)
		return This.IsByOrBySubStringNamedParam(paList)

	func IsByOrBySubStringNamedParams()
		return This.IsByOrBySubStringNamedParam(paList)

	func IsBySubStringOrByNamedParams()
		return This.IsByOrBySubStringNamedParam(paList)

func IsByOrByListNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsByListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByListOrByNamedParam(paList)
		return This.IsByOrByListNamedParam(paList)

	func IsByOrByListNamedParams()
		return This.IsByOrByListNamedParam(paList)

	func IsByListOrByNamedParams()
		return This.IsByOrByListNamedParam(paList)

func IsByOrByHashListNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsByHashListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByHashListOrByNamedParam(paList)
		return This.IsByOrByHashListNamedParam(paList)

	func IsByOrByHashListNamedParams()
		return This.IsByOrByHashListNamedParam(paList)

	func IsByHashListOrByNamedParams()
		return This.IsByOrByHashListNamedParam(paList)

func IsByOrByPairNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsByPairNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByPairOrByNamedParam(paList)
		return This.IsByOrByPairNamedParam(paList)

	func IsByOrByPairNamedParams()
		return This.IsByOrByPairNamedParam(paList)

	func IsByPairOrByNamedParams()
		return This.IsByOrByPairNamedParam(paList)

func IsByOrBySetNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsBySetNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsBySetOrByNamedParam(paList)
		return This.IsByOrBySetNamedParam(paList)

	func IsByOrBySetNamedParams()
		return This.IsByOrBySetNamedParam(paList)

	func IsBySetOrByNamedParams()
		return This.IsByOrBySetNamedParam(paList)

func IsByOrByObjectNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsByObjectNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByStringOrByObjectParam()
		return This.IsByOrByStringNamedParam(paList)

	func IsByOrByObjectNamedParams()
		return This.IsByOrByObjectNamedParam(paList)

	func IsByStringOrByObjectParams()
		return This.IsByOrByStringNamedParam(paList)

#==

func IsListOfListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ListOfLists )

		return TRUE

	else
		return FALSE
	ok

func IsGridNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Grid )

		return TRUE

	else
		return FALSE
	ok

func IsTableNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Table )

		return TRUE

	else
		return FALSE
	ok

func IsHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :HashList )

		return TRUE

	else
		return FALSE
	ok

func IsPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Pair )

		return TRUE

	else
		return FALSE
	ok

func IsListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :List )

		return TRUE

	else
		return FALSE
	ok

func IsObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Object )

		return TRUE

	else
		return FALSE
	ok

#==

func IsInNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InNumber )

		return TRUE

	else
		return FALSE
	ok

func IsInStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InString )

		return TRUE

	else
		return FALSE
	ok

func IsInSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InSubString )

		return TRUE

	else
		return FALSE
	ok

func IsInCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InChar )

		return TRUE

	else
		return FALSE
	ok

func IsInListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InList )

		return TRUE

	else
		return FALSE
	ok

func IsInPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InPair )

		return TRUE

	else
		return FALSE
	ok

func IsInHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InHashList )

		return TRUE

	else
		return FALSE
	ok

func IsInSetNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InSet )

		return TRUE

	else
		return FALSE
	ok

func IsInObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InObject )

		return TRUE

	else
		return FALSE
	ok

#--

func IsInOrInNumberNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInNumberOrInNamedParam(paList)
		return This.IsInOrInNumberNamedParam(paList)

	func IsInOrInNumberNamedParams()
		return This.IsInOrInNumberNamedParam(paList)

	func IsInNumberOrInNamedParams()
		return This.IsInOrInNumberNamedParam(paList)

func IsInOrInCharNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInCharNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInCharOrInNamedParam(paList)
		return This.IsInOrInCharNamedParam(paList)

	func IsInOrInCharNamedParams()
		return This.IsInOrInCharNamedParam(paList)

	func IsInCharOrInNamedParams()
		return This.IsInOrInCharNamedParam(paList)

func IsInOrInStringNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInStringOrInNamedParam(paList)
		return This.IsInOrInStringNamedParam(paList)

	func IsInOrInStringNamedParams()
		return This.IsInOrInStringNamedParam(paList)

	func IsInStringOrInNamedParams()
		return This.IsInOrInStringNamedParam(paList)

func IsInOrInSubStringNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInSubStringOrInNamedParam(paList)
		return This.IsInOrInSubStringNamedParam(paList)

	func IsInOrInSubStringNamedParams()
		return This.IsInOrInSubStringNamedParam(paList)

	func IsInSubStringOrInNamedParams()
		return This.IsInOrInSubStringNamedParam(paList)

func IsInOrInListNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInListOrInNamedParam(paList)
		return This.IsInOrInListNamedParam(paList)

	func IsInOrInListNamedParams()
		return This.IsInOrInListNamedParam(paList)

	func IsInListOrInNamedParams()
		return This.IsInOrInListNamedParam(paList)

func IsInOrInHashListNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInHashListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInHashListOrInNamedParam(paList)
		return This.IsInOrInHashListNamedParam(paList)

	func IsInOrInHashListNamedParams()
		return This.IsInOrInHashListNamedParam(paList)

	func IsInHashListOrInNamedParams()
		return This.IsInOrInHashListNamedParam(paList)

func IsInOrInPairNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInPairNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInPairOrInNamedParam(paList)
		return This.IsInOrInPairNamedParam(paList)

	func IsInOrInPairNamedParams()
		return This.IsInOrInPairNamedParam(paList)

	func IsInPairOrInNamedParams()
		return This.IsInOrInPairNamedParam(paList)

func IsInOrInSetNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInSetNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInSetOrInNamedParam(paList)
		return This.IsInOrInSetNamedParam(paList)

	func IsInOrInSetNamedParams()
		return This.IsInOrInSetNamedParam(paList)

	func IsInSetOrInNamedParams()
		return This.IsInOrInSetNamedParam(paList)

func IsInOrInObjectNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInObjectNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInObjectOrInNamedParam(paList)
		return This.IsInOrInStringNamedParam(paList)

	func IsInOrInObjectNamedParams()
		return This.IsInOrInObjectNamedParam(paList)

	func IsInObjectOrInNamedParams()
		return This.IsInOrInObjectNamedParam(paList)

#==

func IsWithNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithNumber )

		return TRUE

	else
		return FALSE
	ok

func IsWithStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithString )

		return TRUE

	else
		return FALSE
	ok

func IsWithSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithSubString )

		return TRUE

	else
		return FALSE
	ok

func IsWithCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithChar )

		return TRUE

	else
		return FALSE
	ok

func IsWithListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithList )

		return TRUE

	else
		return FALSE
	ok

func IsWithPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithPair )

		return TRUE

	else
		return FALSE
	ok

func IsWithHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithHashList )

		return TRUE

	else
		return FALSE
	ok

func IsWithSetNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithSet )

		return TRUE

	else
		return FALSE
	ok

func IsWithObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithObject )

		return TRUE

	else
		return FALSE
	ok

#--

func IsWithOrWithNumberNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsWithNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithNumberOrWithNamedParam(paList)
		return This.IsWithOrWithNumberNamedParam(paList)

	func IsWithOrWithNumberNamedParams()
		return This.IsWithOrWithNumberNamedParam(paList)

	func IsWithNumberOrWithNamedParams()
		return This.IsWithOrWithNumberNamedParam(paList)

func IsWithOrWithCharNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsWithCharNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithCharOrWithNamedParam(paList)
		return This.IsWithOrWithCharNamedParam(paList)

	func IsWithOrWithCharNamedParams()
		return This.IsWithOrWithCharNamedParam(paList)

	func IsWithCharOrWithNamedParams()
		return This.IsWithOrWithCharNamedParam(paList)

func IsWithOrWithStringNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsWithStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithStringOrWithNamedParam(paList)
		return This.IsWithOrWithStringNamedParam(paList)

	func IsWithOrWithStringNamedParams()
		return This.IsWithOrWithStringNamedParam(paList)

	func IsWithStringOrWithNamedParams()
		return This.IsWithOrWithStringNamedParam(paList)

func IsWithOrWithSubStringNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsWithSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithSubStringOrWithNamedParam(paList)
		return This.IsWithOrWithSubStringNamedParam(paList)

	func IsWithOrWithSubStringNamedParams()
		return This.IsWithOrWithSubStringNamedParam(paList)

	func IsWithSubStringOrWithNamedParams()
		return This.IsWithOrWithSubStringNamedParam(paList)

func IsWithOrWithListNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsWithListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithListOrWithNamedParam(paList)
		return This.IsWithOrWithListNamedParam(paList)

	func IsWithOrWithListNamedParams()
		return This.IsWithOrWithListNamedParam(paList)

	func IsWithListOrWithNamedParams()
		return This.IsWithOrWithListNamedParam(paList)

func IsWithOrWithHashListNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsWithHashListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithHashListOrWithNamedParam(paList)
		return This.IsWithOrWithHashListNamedParam(paList)

	func IsWithOrWithHashListNamedParams()
		return This.IsWithOrWithHashListNamedParam(paList)

	func IsWithHashListOrWithNamedParams()
		return This.IsWithOrWithHashListNamedParam(paList)

func IsWithOrWithPairNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsWithPairNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithPairOrWithNamedParam(paList)
		return This.IsWithOrWithPairNamedParam(paList)

	func IsWithOrWithPairNamedParams()
		return This.IsWithOrWithPairNamedParam(paList)

	func IsWithPairOrWithNamedParams()
		return This.IsWithOrWithPairNamedParam(paList)

func IsWithOrWithSetNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsWithSetNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithSetOrWithNamedParam(paList)
		return This.IsWithOrWithSetNamedParam(paList)

	func IsWithOrWithSetNamedParams()
		return This.IsWithOrWithSetNamedParam(paList)

	func IsWithSetOrWithNamedParams()
		return This.IsWithOrWithSetNamedParam(paList)

func IsWithOrWithObjectNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsWithObjectNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithObjectOrWithNamedParam(paList)
		return This.IsWithOrWithObjectNamedParam(paList)

	func IsWithOrWithObjectNamedParams()
		return This.IsWithOrWithObjectNamedParam(paList)

	func IsWithObjectOrWithNamedParams()
		return This.IsWithOrWithObjectNamedParam(paList)

#==

func IsInsideNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InsideNumber )

		return TRUE

	else
		return FALSE
	ok

func IsInsideStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InsideString )

		return TRUE

	else
		return FALSE
	ok

func IsInsideSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InsideSubString )

		return TRUE

	else
		return FALSE
	ok

func IsInsideCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InsideChar )

		return TRUE

	else
		return FALSE
	ok

func IsInsideListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InsideList )

		return TRUE

	else
		return FALSE
	ok

func IsInsidePairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InsidePair )

		return TRUE

	else
		return FALSE
	ok

func IsInsideHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InsideHashList )

		return TRUE

	else
		return FALSE
	ok

func IsInsideSetNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InsideSet )

		return TRUE

	else
		return FALSE
	ok

func IsInsideObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InsideObject )

		return TRUE

	else
		return FALSE
	ok

#--

func IsInsideOrInsideNumberNamedParam(paList)
	if This.IsInsideNamedParam(paList) or This.IsInsideNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInsideNumberOrInsideNamedParam(paList)
		return This.IsInsideOrInsideNumberNamedParam(paList)

	func IsInsideOrInsideNumberNamedParams()
		return This.IsInsideOrInsideNumberNamedParam(paList)

	func IsInsideNumberOrInsideNamedParams()
		return This.IsInsideOrInsideNumberNamedParam(paList)

func IsInsideOrInsideCharNamedParam(paList)
	if This.IsInsideNamedParam(paList) or This.IsInsideCharNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInsideCharOrInsideNamedParam(paList)
		return This.IsInsideOrInsideCharNamedParam(paList)

	func IsInsideOrInsideCharNamedParams()
		return This.IsInsideOrInsideCharNamedParam(paList)

	func IsInsideCharOrInsideNamedParams()
		return This.IsInsideOrInsideCharNamedParam(paList)

func IsInsideOrInsideStringNamedParam(paList)
	if This.IsInsideNamedParam(paList) or This.IsInsideStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInsideStringOrInsideNamedParam(paList)
		return This.IsInsideOrInsideStringNamedParam(paList)

	func IsInsideOrInsideStringNamedParams()
		return This.IsInsideOrInsideStringNamedParam(paList)

	func IsInsideStringOrInsideNamedParams()
		return This.IsInsideOrInsideStringNamedParam(paList)

func IsInsideOrInsideSubStringNamedParam(paList)
	if This.IsInsideNamedParam(paList) or This.IsInsideSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInsideSubStringOrInsideNamedParam(paList)
		return This.IsInsideOrInsideSubStringNamedParam(paList)

	func IsInsideOrInsideSubStringNamedParams()
		return This.IsInsideOrInsideSubStringNamedParam(paList)

	func IsInsideSubStringOrInsideNamedParams()
		return This.IsInsideOrInsideSubStringNamedParam(paList)

func IsInsideOrInsideListNamedParam(paList)
	if This.IsInsideNamedParam(paList) or This.IsInsideListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInsideListOrInsideNamedParam(paList)
		return This.IsInsideOrInsideListNamedParam(paList)

	func IsInsideOrInsideListNamedParams()
		return This.IsInsideOrInsideListNamedParam(paList)

	func IsInsideListOrInsideNamedParams()
		return This.IsInsideOrInsideListNamedParam(paList)

func IsInsideOrInsideHashListNamedParam(paList)
	if This.IsInsideNamedParam(paList) or This.IsInsideHashListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInsideHashListOrInsideNamedParam(paList)
		return This.IsInsideOrInsideHashListNamedParam(paList)

	func IsInsideOrInsideHashListNamedParams()
		return This.IsInsideOrInsideHashListNamedParam(paList)

	func IsInsideHashListOrInsideNamedParams()
		return This.IsInsideOrInsideHashListNamedParam(paList)

func IsInsideOrInsidePairNamedParam(paList)
	if This.IsInsideNamedParam(paList) or This.IsInsidePairNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInsidePairOrInsideNamedParam(paList)
		return This.IsInsideOrInsidePairNamedParam(paList)

	func IsInsideOrInsidePairNamedParams()
		return This.IsInsideOrInsidePairNamedParam(paList)

	func IsInsidePairOrInsideNamedParams()
		return This.IsInsideOrInsidePairNamedParam(paList)

func IsInsideOrInsideSetNamedParam(paList)
	if This.IsInsideNamedParam(paList) or This.IsInsideSetNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInsideSetOrInsideNamedParam(paList)
		return This.IsInsideOrInsideSetNamedParam(paList)

	func IsInsideOrInsideSetNamedParams()
		return This.IsInsideOrInsideSetNamedParam(paList)

	func IsInsideSetOrInsideNamedParams()
		return This.IsInsideOrInsideSetNamedParam(paList)

func IsInsideOrInsideObjectNamedParam(paList)
	if This.IsInsideNamedParam(paList) or This.IsInsideObjectNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsInsideObjectOrInsideNamedParam(paList)
		return This.IsInsideOrInsideObjectNamedParam(paList)

	func IsInsideOrInsideObjectNamedParams()
		return This.IsInsideOrInsideObjectNamedParam(paList)

	func IsInsideObjectOrInsideNamedParams()
		return This.IsInsideOrInsideObjectNamedParam(paList)

#==

func IsOnNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OnNumber )

		return TRUE

	else
		return FALSE
	ok

func IsOnStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OnString )

		return TRUE

	else
		return FALSE
	ok

func IsOnSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OnSubString )

		return TRUE

	else
		return FALSE
	ok

func IsOnCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OnChar )

		return TRUE

	else
		return FALSE
	ok

func IsOnListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OnList )

		return TRUE

	else
		return FALSE
	ok

func IsOnPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OnPair )

		return TRUE

	else
		return FALSE
	ok

func IsOnHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OnHashList )

		return TRUE

	else
		return FALSE
	ok

func IsOnSetNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OnSet )

		return TRUE

	else
		return FALSE
	ok

func IsOnObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OnObject )

		return TRUE

	else
		return FALSE
	ok

#--

func IsOnOrOnNumberNamedParam(paList)
	if This.IsOnNamedParam(paList) or This.IsOnNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOnNumberOrOnNamedParam(paList)
		return This.IsOnOrOnNumberNamedParam(paList)

	func IsOnOrOnNumberNamedParams()
		return This.IsOnOrOnNumberNamedParam(paList)

	func IsOnNumberOrOnNamedParams()
		return This.IsOnOrOnNumberNamedParam(paList)

func IsOnOrOnCharNamedParam(paList)
	if This.IsOnNamedParam(paList) or This.IsOnCharNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOnCharOrOnNamedParam(paList)
		return This.IsOnOrOnCharNamedParam(paList)

	func IsOnOrOnCharNamedParams()
		return This.IsOnOrOnCharNamedParam(paList)

	func IsOnCharOrOnNamedParams()
		return This.IsOnOrOnCharNamedParam(paList)

func IsOnOrOnStringNamedParam(paList)
	if This.IsOnNamedParam(paList) or This.IsOnStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOnStringOrOnNamedParam(paList)
		return This.IsOnOrOnStringNamedParam(paList)

	func IsOnOrOnStringNamedParams()
		return This.IsOnOrOnStringNamedParam(paList)

	func IsOnStringOrOnNamedParams()
		return This.IsOnOrOnStringNamedParam(paList)

func IsOnOrOnSubStringNamedParam(paList)
	if This.IsOnNamedParam(paList) or This.IsOnSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOnSubStringOrOnNamedParam(paList)
		return This.IsOnOrOnSubStringNamedParam(paList)

	func IsOnOrOnSubStringNamedParams()
		return This.IsOnOrOnSubStringNamedParam(paList)

	func IsOnSubStringOrOnNamedParams()
		return This.IsOnOrOnSubStringNamedParam(paList)

func IsOnOrOnListNamedParam(paList)
	if This.IsOnNamedParam(paList) or This.IsOnListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOnListOrOnNamedParam(paList)
		return This.IsOnOrOnListNamedParam(paList)

	func IsOnOrOnListNamedParams()
		return This.IsOnOrOnListNamedParam(paList)

	func IsOnListOrOnNamedParams()
		return This.IsOnOrOnListNamedParam(paList)

func IsOnOrOnHashListNamedParam(paList)
	if This.IsOnNamedParam(paList) or This.IsOnHashListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOnHashListOrOnNamedParam(paList)
		return This.IsOnOrOnHashListNamedParam(paList)

	func IsOnOrOnHashListNamedParams()
		return This.IsOnOrOnHashListNamedParam(paList)

	func IsOnHashListOrOnNamedParams()
		return This.IsOnOrOnHashListNamedParam(paList)

func IsOnOrOnPairNamedParam(paList)
	if This.IsOnNamedParam(paList) or This.IsOnPairNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOnPairOrOnNamedParam(paList)
		return This.IsOnOrOnPairNamedParam(paList)

	func IsOnOrOnPairNamedParams()
		return This.IsOnOrOnPairNamedParam(paList)

	func IsOnPairOrOnNamedParams()
		return This.IsOnOrOnPairNamedParam(paList)

func IsOnOrOnSetNamedParam(paList)
	if This.IsOnNamedParam(paList) or This.IsOnSetNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOnSetOrOnNamedParam(paList)
		return This.IsOnOrOnSetNamedParam(paList)

	func IsOnOrOnSetNamedParams()
		return This.IsOnOrOnSetNamedParam(paList)

	func IsOnSetOrOnNamedParams()
		return This.IsOnOrOnSetNamedParam(paList)

func IsOnOrOnObjectNamedParam(paList)
	if This.IsOnNamedParam(paList) or This.IsOnObjectNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOnObjectOrOnNamedParam(paList)
		return This.IsOnOrOnObjectNamedParam(paList)

	func IsOnOrOnObjectNamedParams()
		return This.IsOnOrOnObjectNamedParam(paList)

	func IsOnObjectOrOnNamedParams()
		return This.IsOnOrOnObjectNamedParam(paList)

#==

func IsOverNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverNumber )

		return TRUE

	else
		return FALSE
	ok

func IsOverStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverString )

		return TRUE

	else
		return FALSE
	ok

func IsOverSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverSubString )

		return TRUE

	else
		return FALSE
	ok

func IsOverCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverChar )

		return TRUE

	else
		return FALSE
	ok

func IsOverListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverList )

		return TRUE

	else
		return FALSE
	ok

func IsOverPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverPair )

		return TRUE

	else
		return FALSE
	ok

func IsOverHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverHashList )

		return TRUE

	else
		return FALSE
	ok

func IsOverSetNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverSet )

		return TRUE

	else
		return FALSE
	ok

func IsOverObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverObject )

		return TRUE

	else
		return FALSE
	ok

#--

func IsOverOrOverNumberNamedParam(paList)
	if This.IsOverNamedParam(paList) or This.IsOverNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOverNumberOrOverNamedParam(paList)
		return This.IsOverOrOverNumberNamedParam(paList)

	func IsOverOrOverNumberNamedParams()
		return This.IsOverOrOverNumberNamedParam(paList)

	func IsOverNumberOrOverNamedParams()
		return This.IsOverOrOverNumberNamedParam(paList)

func IsOverOrOverCharNamedParam(paList)
	if This.IsOverNamedParam(paList) or This.IsOverCharNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOverCharOrOverNamedParam(paList)
		return This.IsOverOrOverCharNamedParam(paList)

	func IsOverOrOverCharNamedParams()
		return This.IsOverOrOverCharNamedParam(paList)

	func IsOverCharOrOverNamedParams()
		return This.IsOverOrOverCharNamedParam(paList)

func IsOverOrOverStringNamedParam(paList)
	if This.IsOverNamedParam(paList) or This.IsOverStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOverStringOrOverNamedParam(paList)
		return This.IsOverOrOverStringNamedParam(paList)

	func IsOverOrOverStringNamedParams()
		return This.IsOverOrOverStringNamedParam(paList)

	func IsOverStringOrOverNamedParams()
		return This.IsOverOrOverStringNamedParam(paList)

func IsOverOrOverSubStringNamedParam(paList)
	if This.IsOverNamedParam(paList) or This.IsOverSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOverSubStringOrOverNamedParam(paList)
		return This.IsOverOrOverSubStringNamedParam(paList)

	func IsOverOrOverSubStringNamedParams()
		return This.IsOverOrOverSubStringNamedParam(paList)

	func IsOverSubStringOrOverNamedParams()
		return This.IsOverOrOverSubStringNamedParam(paList)

func IsOverOrOverListNamedParam(paList)
	if This.IsOverNamedParam(paList) or This.IsOverListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOverListOrOverNamedParam(paList)
		return This.IsOverOrOverListNamedParam(paList)

	func IsOverOrOverListNamedParams()
		return This.IsOverOrOverListNamedParam(paList)

	func IsOverListOrOverNamedParams()
		return This.IsOverOrOverListNamedParam(paList)

func IsOverOrOverHashListNamedParam(paList)
	if This.IsOverNamedParam(paList) or This.IsOverHashListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOverHashListOrOverNamedParam(paList)
		return This.IsOverOrOverHashListNamedParam(paList)

	func IsOverOrOverHashListNamedParams()
		return This.IsOverOrOverHashListNamedParam(paList)

	func IsOverHashListOrOverNamedParams()
		return This.IsOverOrOverHashListNamedParam(paList)

func IsOverOrOverPairNamedParam(paList)
	if This.IsOverNamedParam(paList) or This.IsOverPairNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOverPairOrOverNamedParam(paList)
		return This.IsOverOrOverPairNamedParam(paList)

	func IsOverOrOverPairNamedParams()
		return This.IsOverOrOverPairNamedParam(paList)

	func IsOverPairOrOverNamedParams()
		return This.IsOverOrOverPairNamedParam(paList)

func IsOverOrOverSetNamedParam(paList)
	if This.IsOverNamedParam(paList) or This.IsOverSetNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOverSetOrOverNamedParam(paList)
		return This.IsOverOrOverSetNamedParam(paList)

	func IsOverOrOverSetNamedParams()
		return This.IsOverOrOverSetNamedParam(paList)

	func IsOverSetOrOverNamedParams()
		return This.IsOverOrOverSetNamedParam(paList)

func IsOverOrOverObjectNamedParam(paList)
	if This.IsOverNamedParam(paList) or This.IsOverObjectNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOverObjectOrOverNamedParam(paList)
		return This.IsOverOrOverObjectNamedParam(paList)

	func IsOverOrOverObjectNamedParams()
		return This.IsOverOrOverObjectNamedParam(paList)

	func IsOverObjectOrOverNamedParams()
		return This.IsOverOrOverObjectNamedParam(paList)

#==

func IsAgainstNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverNumber )

		return TRUE

	else
		return FALSE
	ok

func IsAgainstStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverString )

		return TRUE

	else
		return FALSE
	ok

func IsAgainstSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverSubString )

		return TRUE

	else
		return FALSE
	ok

func IsAgainstCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverChar )

		return TRUE

	else
		return FALSE
	ok

func IsAgainstListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverList )

		return TRUE

	else
		return FALSE
	ok

func IsAgainstPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverPair )

		return TRUE

	else
		return FALSE
	ok

func IsAgainstHashListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverHashList )

		return TRUE

	else
		return FALSE
	ok

func IsAgainstSetNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverSet )

		return TRUE

	else
		return FALSE
	ok

func IsAgainstObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OverObject )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAgainstOrAgainstNumberNamedParam(paList)
	if This.IsAgainstNamedParam(paList) or This.IsAgainstNumberNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAgainstNumberOrAgainstNamedParam(paList)
		return This.IsAgainstOrAgainstNumberNamedParam(paList)

	func IsAgainstOrAgainstNumberNamedParams()
		return This.IsAgainstOrAgainstNumberNamedParam(paList)

	func IsAgainstNumberOrAgainstNamedParams()
		return This.IsAgainstOrAgainstNumberNamedParam(paList)

func IsAgainstOrAgainstCharNamedParam(paList)
	if This.IsAgainstNamedParam(paList) or This.IsAgainstCharNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAgainstCharOrAgainstNamedParam(paList)
		return This.IsAgainstOrAgainstCharNamedParam(paList)

	func IsAgainstOrAgainstCharNamedParams()
		return This.IsAgainstOrAgainstCharNamedParam(paList)

	func IsAgainstCharOrAgainstNamedParams()
		return This.IsAgainstOrAgainstCharNamedParam(paList)

func IsAgainstOrAgainstStringNamedParam(paList)
	if This.IsAgainstNamedParam(paList) or This.IsAgainstStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAgainstStringOrAgainstNamedParam(paList)
		return This.IsAgainstOrAgainstStringNamedParam(paList)

	func IsAgainstOrAgainstStringNamedParams()
		return This.IsAgainstOrAgainstStringNamedParam(paList)

	func IsAgainstStringOrAgainstNamedParams()
		return This.IsAgainstOrAgainstStringNamedParam(paList)

func IsAgainstOrAgainstSubStringNamedParam(paList)
	if This.IsAgainstNamedParam(paList) or This.IsAgainstSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAgainstSubStringOrAgainstNamedParam(paList)
		return This.IsAgainstOrAgainstSubStringNamedParam(paList)

	func IsAgainstOrAgainstSubStringNamedParams()
		return This.IsAgainstOrAgainstSubStringNamedParam(paList)

	func IsAgainstSubStringOrAgainstNamedParams()
		return This.IsAgainstOrAgainstSubStringNamedParam(paList)

func IsAgainstOrAgainstListNamedParam(paList)
	if This.IsAgainstNamedParam(paList) or This.IsAgainstListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAgainstListOrAgainstNamedParam(paList)
		return This.IsAgainstOrAgainstListNamedParam(paList)

	func IsAgainstOrAgainstListNamedParams()
		return This.IsAgainstOrAgainstListNamedParam(paList)

	func IsAgainstListOrAgainstNamedParams()
		return This.IsAgainstOrAgainstListNamedParam(paList)

func IsAgainstOrAgainstHashListNamedParam(paList)
	if This.IsAgainstNamedParam(paList) or This.IsAgainstHashListNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAgainstHashListOrAgainstNamedParam(paList)
		return This.IsAgainstOrAgainstHashListNamedParam(paList)

	func IsAgainstOrAgainstHashListNamedParams()
		return This.IsAgainstOrAgainstHashListNamedParam(paList)

	func IsAgainstHashListOrAgainstNamedParams()
		return This.IsAgainstOrAgainstHashListNamedParam(paList)

func IsAgainstOrAgainstPairNamedParam(paList)
	if This.IsAgainstNamedParam(paList) or This.IsAgainstPairNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAgainstPairOrAgainstNamedParam(paList)
		return This.IsAgainstOrAgainstPairNamedParam(paList)

	func IsAgainstOrAgainstPairNamedParams()
		return This.IsAgainstOrAgainstPairNamedParam(paList)

	func IsAgainstPairOrAgainstNamedParams()
		return This.IsAgainstOrAgainstPairNamedParam(paList)

func IsAgainstOrAgainstSetNamedParam(paList)
	if This.IsAgainstNamedParam(paList) or This.IsAgainstSetNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAgainstSetOrAgainstNamedParam(paList)
		return This.IsAgainstOrAgainstSetNamedParam(paList)

	func IsAgainstOrAgainstSetNamedParams()
		return This.IsAgainstOrAgainstSetNamedParam(paList)

	func IsAgainstSetOrAgainstNamedParams()
		return This.IsAgainstOrAgainstSetNamedParam(paList)

func IsAgainstOrAgainstObjectNamedParam(paList)
	if This.IsAgainstNamedParam(paList) or This.IsAgainstObjectNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAgainstObjectOrAgainstNamedParam(paList)
		return This.IsAgainstOrAgainstObjectNamedParam(paList)

	func IsAgainstOrAgainstObjectNamedParams()
		return This.IsAgainstOrAgainstObjectNamedParam(paList)

	func IsAgainstObjectOrAgainstNamedParams()
		return This.IsAgainstOrAgainstObjectNamedParam(paList)

#==

func IsRespectivelyNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Respectively )

		return TRUE

	else
		return FALSE
	ok

#==

func IsSeedNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Seed )

		return TRUE

	else
		return FALSE
	ok

#==

func IsEqualToNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EqualTo )

		return TRUE

	else
		return FALSE
	ok

func IsEqualsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Equals )

		return TRUE

	else
		return FALSE
	ok

#==

func IsToNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :To )

		return TRUE

	else
		return FALSE
	ok

func IsToTheseNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToThis )

		return TRUE

	else
		return FALSE
	ok

func IsToManyNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToMany )

		return TRUE

	else
		return FALSE
	ok

func IsToPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToPosition )

		return TRUE

	else
		return FALSE
	ok

func IsToPositionOfNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToPositionOf )

		return TRUE

	else
		return FALSE
	ok

func IsToOrToPositionNamedParam(paList)

	if This.IsToNamedParam(paList) or This.IsToPositionNamedParam(paList)
		return TRUE

	else
		return FALSE
	ok

	#< @functionAlternativeForms

	func IsToOrToPositionNamedParams()
		return This.IsToOrToPositionNamedParam(paList)

	func IsToPositionOrToNamedParam(paList)
		return This.IsToOrToPositionNamedParam(paList)

	func IsToPositionOrToNamedParams()
		return This.IsToOrToPositionNamedParam(paList)

	#>

func IsToPositionOfItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToPositionOfItem )

		return TRUE

	else
		return FALSE
	ok

func IsToPositionOfStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToPositionOfString )

		return TRUE

	else
		return FALSE
	ok

func IsToPositionOfCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToPositionOfChar )

		return TRUE

	else
		return FALSE
	ok

#--

func IsFromPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromPosition )

		return TRUE

	else
		return FALSE
	ok

func IsFromOrFromPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  (paList[1] = :FromPosition or paList[1] = :From)  )

		return TRUE

	else
		return FALSE
	ok

	#< @functionAlternativeForms

	func IsFromOrFromPositionNamedParams()
		return This.IsFromOrFromPositionNamedParam(paList)

	func IsFromPositionOrFromNamedParam(paList)
		return This.IsFromOrFromPositionNamedParam(paList)

	func IsFromPositionOrFromNamedParams()
		return This.IsFromOrFromPositionNamedParam(paList)

	#>

func IsFromPositionOfItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromPositionOfItem )

		return TRUE

	else
		return FALSE
	ok

func IsFromPositionOfStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromPositionOfString )

		return TRUE

	else
		return FALSE
	ok

func IsFromPositionOfCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromPositionOfChar )

		return TRUE

	else
		return FALSE
	ok

#--

func IsOfNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Of )

		return TRUE

	else
		return FALSE
	ok

func IsOnNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :On )

		return TRUE

	else
		return FALSE
	ok

func IsInNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :In )

		return TRUE

	else
		return FALSE
	ok

func IsInANamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :InA )

		return TRUE

	else
		return FALSE
	ok

#--

func IsInSideNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :InSide or paList[1] = :Inside@) )

		return TRUE

	else
		return FALSE
	ok

func IsInSideANamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and 
		(paList[1] = :InSideA or paList[1] = :InsideA@) )

		return TRUE

	else
		return FALSE
	ok

func IsInOrInsideNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsInsideNamedParam(paList)
		return TRUE

	else
		return FALSE
	ok

	func IsInOrInsideNamedParams()
		return This.IsInOrInsideNamedParam(paList)

	func IsInsideOrInNamedParam(paList)
		return This.IsInOrInsideNamedParam(paList)

	func IsInsideOrInNamedParams()
		return This.IsInOrInsideNamedParam(paList)

func IsWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Where ) and
	   isString( This.Item(2) )

		return TRUE

	else
		return FALSE
	ok

func IsWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WhereXT ) and
	   isString( This.Item(2) )

		return TRUE

	else
		return FALSE
	ok

func IsThatNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :That ) and
	   isString( This.Item(2) )

		return TRUE

	else
		return FALSE
	ok

func IsThatOrWhereNamedParam(paList)
	if This.IsThatNamedParam(paList) or This.IsWhereNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsThatOrWhereNamedParams()
		return This.IsThatOrWhereNamedParam(paList)

	func IsWhereOrThatNamedParam(paList)
		return This.IsThatOrWhereNamedParam(paList)

	func IsWhereOrThatNamedParams()
		return This.IsThatOrWhereNamedParam(paList)

func IsThatXTOrWhereXTNamedParam(paList)
	if This.IsThatXTNamedParam(paList) or This.IsWhereXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsThatXTOrWhereXTNamedParams()
		return This.IsThatXTOrWhereXTNamedParam(paList)

	func IsWhereXTOrThatXTNamedParam(paList)
		return This.IsThatXTOrWhereXTNamedParam(paList)

	func IsWherextOrThatxtNamedParams()
		return This.IsThatXTOrWhereXTNamedParam(paList)

func IsPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Position )

		return TRUE

	else
		return FALSE
	ok

func IsPositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :PositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsThisPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisPosition )

		return TRUE

	else
		return FALSE
	ok

func IsThisPositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisPositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Positions )

		return TRUE

	else
		return FALSE
	ok

func IsPositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :PositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsThesePositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThesePositions )

		return TRUE

	else
		return FALSE
	ok

func IsThesePositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThesePositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsPositionOrPositionsNamedParam(paList)
	if This.IsPositionNamedParam(paList) or This.IsPositionsNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsPositionOrPositionsNamedParams()
		return This.IsPositionOrPositionsNamedParam(paList)

func IsPositionIBOrPositionsibNamedParam(paList)
	if This.IsPositionIBNamedParam(paList) or This.IsPositionsIBNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsPositionIBOrPositionsIBNamedParams()
		return This.IsPositionIBOrPositionsIBNamedParam(paList)

func IsAlongWithNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  (paList[1] = :AlongWith or paList[1] = :AlongWith@)  )

		return TRUE

	else
		return FALSE
	ok

func IsAlongWithTheirNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  (paList[1] = :AlongWithTheir or paList[1] = :AlongWithTheir@)  )

		return TRUE

	else
		return FALSE
	ok

func IsOrOrAndNamedParam(paList)
	if This.IsOrNamedParam(paList) or This.AndNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAndOrOrNamedParam(paList)
		return This.IsOrOrAndNamedParam(paList)

func IsAndNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  (paList[1] = :And or paList[1] = :And@)  )

		return TRUE

	else
		return FALSE
	ok

func IsAndTheirNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  (paList[1] = :AndTheir or paList[1] = :AndTheir@)  )

		return TRUE

	else
		return FALSE
	ok

func IsAndItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndItem )

		return TRUE

	else
		return FALSE
	ok

func IsAndStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndString )

		return TRUE

	else
		return FALSE
	ok

func IsAndCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndChar )

		return TRUE

	else
		return FALSE
	ok

func IsAndPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndPosition )

		return TRUE

	else
		return FALSE
	ok

func IsAndPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndPositions )

		return TRUE

	else
		return FALSE
	ok

func IsAndItemAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndItemAt )

		return TRUE

	else
		return FALSE
	ok

func IsAndItemAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndItemAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsAndStringAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndStringAt )

		return TRUE

	else
		return FALSE
	ok

func IsAndStringAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndStringAtPosition )

		return TRUE

	else
		return FALSE
	ok

#--

func IsOrNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Or )

		return TRUE

	else
		return FALSE
	ok

func IsOrANamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OrA )

		return TRUE

	else
		return FALSE
	ok

func IsOrAnNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OrAn )

		return TRUE

	else
		return FALSE
	ok

#--

func IsNorNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Nor )

		return TRUE

	else
		return FALSE
	ok

func IsWhileNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :While )

		return TRUE

	else
		return FALSE
	ok

func IsNotNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Not )

		return TRUE

	else
		return FALSE
	ok

func IsIfNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   paList[1] = :If and
	   isString(This.Item(2))

		return TRUE

	else
		return FALSE
	ok

func IsIfOrWhereNamedParam(paList)
	return This.IsIfNamedParam(paList) or This.IsWhereNamedParam(paList)

	func IsWhereOrIfNamedParam(paList)
		return This.IsIfOrWhereNamedParam(paList)

	func IsWhereOrIfNamedParams()
		return This.IsIfOrWhereNamedParam(paList)

	func IsIfOrWhereNamedParams()
		return This.IsIfOrWhereNamedParam(paList)

func IsIfXTOrWhereXTNamedParam(paList)
	return This.IsIfXTNamedParam(paList) or This.IsWhereXTNamedParam(paList)

	func IsWhereXTOrIfXTNamedParam(paList)
		return This.IsIfXTOrWhereXTNamedParam(paList)

	func IsWhereXTOrIfXTNamedParams()
		return This.IsIfXTOrWhereXTNamedParam(paList)

	func IsIfXTOrWhereXTNamedParams()
		return This.IsIfXTOrWhereXTNamedParam(paList)

func IsWithNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :With or paList[1] = :With@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsWithManyNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :WithMany or paList[1] = :WithMany@ ) )
	  
		return TRUE

	else
		return FALSE
	ok

func IsWithOrAndNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsAndNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithOrAndNamedParams()
		return This.IsWithOrAndNamedParam(paList)

	func IsAndOrWithNamedParam(paList)
		return This.IsWithOrAndNamedParam(paList)

	func IsAndOrWithNamedParams()
		return This.IsWithOrAndNamedParam(paList)

func IsWithItemsInNamedParam(paList) 
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :By or paList[1] = :By@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsWithCharsInNamedParam(paList) 
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :WithCharsIn or paList[1] = :WithCharsIn@ ) )

		return TRUE

	else
		return FALSE
	ok

#==

func IsUsingItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingItem)

		return TRUE
	else
		return FALSE
	ok

func IsUsingThisItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingThisItem)

		return TRUE
	else
		return FALSE
	ok

func IsUsingItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingItems)

		return TRUE
	else
		return FALSE
	ok

func IsUsingTheseItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingTheseItems)

		return TRUE
	else
		return FALSE
	ok

#--

func IsUsingStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingString)

		return TRUE
	else
		return FALSE
	ok

func IsUsingThisStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingThisString)

		return TRUE
	else
		return FALSE
	ok

func IsUsingStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingStrings)

		return TRUE
	else
		return FALSE
	ok

func IsUsingTheseStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingTheseStrings)

		return TRUE
	else
		return FALSE
	ok

#--

func IsUsingSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingSubString)

		return TRUE
	else
		return FALSE
	ok

func IsUsingThisSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingThisSubString)

		return TRUE
	else
		return FALSE
	ok

func IsUsingSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingSubStrings)

		return TRUE
	else
		return FALSE
	ok

func IsUsingTheseSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :UsingTheseSubStrings)

		return TRUE
	else
		return FALSE
	ok

#==

func IsByItemsInNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :ByItemsIn or paList[1] = :ByItemsIn@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsUsingItemsInNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :UsingItemsIn or paList[1] = :UsingItemsIn@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsWithTheirNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :WithTheir or paList[1] = :WithTheir@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsByNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :By or paList[1] = :By@ ) )
	  
		return TRUE

	else
		return FALSE
	ok

func IsByManyNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :ByMany or paList[1] = :ByMany@ ) )
	  
		return TRUE

	else
		return FALSE
	ok

func IsByManyXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :ByManyXT or paList[1] = :ByManyXT@ ) )
	  
		return TRUE

	else
		return FALSE
	ok

func IsUsingManyXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :UsingManyXT or paList[1] = :UsingManyXT@ ) )
	  
		return TRUE

	else
		return FALSE
	ok

func IsWithManyXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :WithManyXT or paList[1] = :WithManyXT@ ) )
	  
		return TRUE

	else
		return FALSE
	ok

#--

func IsByOrUsingNamedParam(paList)
	if This.IsByNamedParam(paList) or This.IsUsingNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsByOrUsingNamedParams()
		return This.IsByOrUsingNamedParam(paList)

	func IsUsingOrByNamedParam(paList)
		return This.IsByOrUsingNamedParam(paList)

	func IsUsingOrByNamedParams()
		return This.IsByOrUsingNamedParam(paList)

#--

func IsByManyOrWithManyOrUsingManyNamedParam(paList)
	if This.IsByManyNamedParam(paList) or
	   This.IsWithNamedParam(paList) or
	   This.IsUsingNamedParam(paList)

		return TRUE
	else
		return FALSE
	ok

	#--

	func IsByManyOrUsingManyOrWithManyNamedParam(paList)
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	func IsWithManyOrByManyOrUsingManyNamedParam(paList)
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	func IsWithManyOrUsingManyOrByManyNamedParam(paList)
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	func IsUsingManyOrByManyOrWithManyNamedParam(paList)
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	func IsUsingManyOrWithManyOrByManyNamedParam(paList)
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	#-- ...Param(s) with s

	func IsByManyOrWithManyOrUsingManyNamedParams()
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	func IsByManyOrUsingManyOrWithManyNamedParams()
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	func IsWithManyOrByManyOrUsingManyNamedParams()
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	func IsWithManyOrUsingManyOrByManyNamedParams()
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	func IsUsingManyOrByManyOrWithManyNamedParams()
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

	func IsUsingManyOrWithManyOrByManyNamedParams()
		return This.IsByManyOrWithManyOrUsingManyNamedParam(paList)

#--

func IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)
	if This.IsByManyXTNamedParam(paList) or
	   This.IsWithXTNamedParam(paList) or
	   This.IsUsingXTNamedParam(paList)

		return TRUE
	else
		return FALSE
	ok

	#--

	func IsByManyXTOrUsingManyXTOrWithManyXTNamedParam(paList)
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	func IsWithManyXTOrByManyXTOrUsingManyXTNamedParam(paList)
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	func IsWithManyXTOrUsingManyXTOrByManyXTNamedParam(paList)
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	func IsUsingManyXTOrByManyXTOrWithManyXTNamedParam(paList)
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	func IsUsingManyXTOrWithManyXTOrByManyXTNamedParam(paList)
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	#-- ...Param(s) with s

	func IsByManyXTOrWithManyXTOrUsingManyXTNamedParams()
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	func IsByManyXTOrUsingManyXTOrWithManyXTNamedParams()
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	func IsWithManyXTOrByManyXTOrUsingManyXTNamedParams()
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	func IsWithManyXTOrUsingManyXTOrByManyXTNamedParams()
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	func IsUsingManyXTOrByManyXTOrWithManyXTNamedParams()
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

	func IsUsingManyXTOrWithManyXTOrByManyXTNamedParams()
		return This.IsByManyXTOrWithManyXTOrUsingManyXTNamedParam(paList)

#==

func IsByColNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
	     ring_find([ :ByCol, :ByCol@ ], paList[1]) > 0  )
	  
		return TRUE

	else
		return FALSE
	ok

func IsByColumnNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
	     ring_find([ :ByColumn, :ByColumn@ ], paList[1]) > 0  )
	  
		return TRUE

	else
		return FALSE
	ok

func IsUsingColNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
	     ring_find([ :UsingCol, :UsingCol@ ], paList[1]) > 0  )
		return TRUE

	else
		return FALSE
	ok

func IsUsingColumnNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
	     ring_find([ :UsingColumn, :UsingColumn@ ], paList[1]) > 0 )

		return TRUE

	else
		return FALSE
	ok

func IsWithColNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
	     ring_find([ :WithCol, :WithCol@ ], paList[1]) > 0 )
	  
		return TRUE

	else
		return FALSE
	ok

func IsWithColumnNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
	     ring_find([ :WithColumn, :WithColumn@ ], paList[1]) > 0 )
	  
		return TRUE

	else
		return FALSE
	ok

func IsByRowNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ByRow )
	  
		return TRUE

	else
		return FALSE
	ok

func IsWithRowNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithRow )
	  
		return TRUE

	else
		return FALSE
	ok

func IsUsingRowNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UsingRow )
	  
		return TRUE

	else
		return FALSE
	ok

func IsByCellNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ByCell )
	  
		return TRUE

	else
		return FALSE
	ok

func IsWithCellNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :WithCell )
	  
		return TRUE

	else
		return FALSE
	ok

func IsUsingCellNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UsingCell )
	  
		return TRUE

	else
		return FALSE
	ok

func IsWithOrByNamedParam(paList)
	return This.IsWithNamedParam(paList) OR This.IsByNamedParam(paList)

	func IsByOrWithNamedParam(paList)
		return This.IsWithOrByNamedParam(paList)

	func IsByOrWithNamedParams()
		return This.IsWithOrByNamedParam(paList)

	func IsWithOrByNamedParams()
		return This.IsWithOrByNamedParam(paList)

func IsUsingNamedParam(paList)
	if len(This.Content()) = 2 and ( isString(paList[1]) and
		( paList[1] = :Using or paList[1] = :Using@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsUsingManyNamedParam(paList)
	if isList(paList) and len(paList) = 2 and ( isString(paList[1]) and
		( paList[1] = :UsingMany or paList[1] = :UsingMany@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :At
		return TRUE

	else
		return FALSE
	ok

func IsAtIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :AtIB
		return TRUE

	else
		return FALSE
	ok

func IsAtOrUsingNamedParam(paList)
	if This.IsAtNamedParam(paList) or This.IsUsingNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsUsingOrAtNamedParam(paList)
		return This.IsAtOrUsingNamedParam(paList)

	func IsUsingOrAtNamedParams()
		return This.IsAtOrUsingNamedParam(paList)

	func IsAtOrUsingNamedParams()
		return This.IsAtOrUsingNamedParam(paList)

#--

func IsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsAtPositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtPositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisPosition )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisPositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisPositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsAtPositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtPositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtThesePositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThesePositions )

		return TRUE

	else
		return FALSE
	ok

func IsAtThesePositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThesePositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyPositions )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyPositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyPositionsIB )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtOrAtPositionNamedParam(paList)
	if This.IsAtNamedParam(paList) or
	   This.IsAtPositionNamedParam(paList)

		return TRUE

	else
		return FALSE
	ok

	func IsAtPositionOrAtNamedParam(paList)
		return This.IsAtOrAtPositionNamedParam(paList)

	func IsAtPositionOrAtNamedParams()
		return This.IsAtOrAtPositionNamedParam(paList)

	func IsAtOrAtPositionNamedParams()
		return This.IsAtOrAtPositionNamedParam(paList)

func IsAtOrAtPositionsNamedParam(paList)
	if This.IsAtNamedParam(paList) or
	   This.IsAtPositionsNamedParam(paList)

		return TRUE

	else
		return FALSE
	ok

	func IsAtPositionsOrAtNamedParam(paList)
		return This.IsAtOrAtPositionsNamedParam(paList)

	func IsAtPositionsOrAtNamedParams()
		return This.IsAtOrAtPositionsNamedParam(paList)

	func IsAtOrAtPositionsNamedParams()
		return This.IsAtOrAtPositionsNamedParam(paList)

#==

func IsAtItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtItem )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisItem )

		return TRUE

	else
		return FALSE
	ok

func IsAtItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtItems )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseItems )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyItems )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtString )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisString )

		return TRUE

	else
		return FALSE
	ok

func IsAtStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyStrings )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSubString )

		return TRUE

	else
		return FALSE
	ok

func IsAtSubStringIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSubStringIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtOrAtSubStringNamedParam(paList)
	if This.IsAtNamedParam(paList) or This.IsAtSubStringNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IfAtSubStringOrAtNamedParam(paList)
		return This.IsAtOrAtSubStringNamedParam(paList)

	func IsAtOrAtSubStringNamedParams()
		return This.IsAtOrAtSubStringNamedParam(paList)

	func IfAtSubStringOrAtNamedParams()
		return This.IsAtOrAtSubStringNamedParam(paList)

func IsAtThisSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisSubString )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisSubStringIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisSubStringIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSubStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAtSubStringsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSubStringsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseSubStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseSubStringsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseSubStringsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtManySubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManySubStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAtManySubStringsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManySubStringsIB )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AtChar )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AtThisChar )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtItemIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AtItemIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtItemsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AtItemsIB )

		return TRUE

	else
		return FALSE
	ok

#--

func IsBeforePositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforePositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeThisPositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeThisPositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforePositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforePositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeManyPositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeManyPositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeThesePositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeThesePositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeSubStringIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeSubStringIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeThisSubStringIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeThisSubStringIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeSubStringsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeSubStringsIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeTheseSubStringsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeTheseSubStringsIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeItemIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeItemIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeThisItemIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeThisItemIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeItemsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeItemsIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeTheseItemsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :BeforeTheseItemsIB )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAfterPositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterPositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterThisPositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterThisPositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterPositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterPositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterThesePositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterThesePositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterSubStringIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterSubStringIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterThisSubStringIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterThisSubStringIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterSubStringsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterSubStringsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterTheseSubStringsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterTheseSubStringsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterItemIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterItemIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterThisItemIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterThisItemIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterItemsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterItemsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterTheseItemsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AfterTheseItemsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundPositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundPositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundThisPositionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundThisPositionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundPositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundPositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundThesePositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundThesePositionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundSubStringIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundSubStringIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundThisSubStringIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundThisSubStringIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundSubStringsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundSubStringsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundTheseSubStringsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundTheseSubStringsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundItemIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundItemIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundThisItemIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundThisItemIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundItemsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundItemsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundTheseItemsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AroundtheseItemsIB )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isChar(paList[1]) and  paList[1] = :AtChars )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseChars )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyChars )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtNumber )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisNumber )

		return TRUE

	else
		return FALSE
	ok

func IsAtNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtNumbers )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseNumbers )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyNumbers )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtList )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisList )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyLists )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtSubListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSubList )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisSubListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisSubList )

		return TRUE

	else
		return FALSE
	ok

func IsAtSubListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSubLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseSubListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseSubLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtManySubListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManySubLists )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtPair )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisPairNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisPair )

		return TRUE

	else
		return FALSE
	ok

func IsAtPairsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtPairs )

		return TRUE

	else
		return FALSE
	ok

func IsAtThesePairsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThesePairs )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyPairsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyPairs )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListOfNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfNumbers )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfNumbers )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsOfNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfNumbers )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfNumbers )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfNumbers )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListOfCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfChars )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfChars )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsOfCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfChars )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfChars )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfChars )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListOfStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsOfStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfStrings )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListOfListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsOfListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfLists )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListOfSubListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfSubLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfSubListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfSubLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsOfSubListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfSubLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfSubListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfSubLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfSubListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfSubLists )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListOfPairsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfPairs )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfPairsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfPairs )

		return TRUE

	else
		return FALSE
	ok
func IsAtListsOfPairsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfPairs )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfPairsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfPairs )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfPairsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfPairs )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListOfHashListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfHashLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfHashListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfHashLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsOfHashListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfHashLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfHashListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfHashLists )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfHashListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfHashLists )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtObject )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisObject )

		return TRUE

	else
		return FALSE
	ok

func IsAtObjectsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtObjects )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseObjectsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseObjects )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyObjectsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyObjects )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSection )

		return TRUE

	else
		return FALSE
	ok

func IsAtSectionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSectionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisSection )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisSectionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisSectionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSections )

		return TRUE

	else
		return FALSE
	ok

func IsAtSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtSectionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseSections )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseSectionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtManySectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManySections )

		return TRUE

	else
		return FALSE
	ok

func IsAtManySectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManySectionsIB )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListOfSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfSections )

		return TRUE

	else
		return FALSE
	ok

func IsAtListOfSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfSectionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfSections )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfSectionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsOfSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfSections )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsOfSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfSectionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfSections )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfSectionsIB )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfSections )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfSectionsIB )

		return TRUE

	else
		return FALSE
	ok

#--

#TODO // Reorganise them near to IsBeforeSectionNamedParam(paList)

func IsBeforeSectionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :BeforeSectionIB )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :BeforeSectionsIB )

		return TRUE

	else
		return FALSE
	ok

#--

#TODO // Reorganise them near to IsBeforeSectionNamedParam(paList)

func IsAfterSectionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AfterSectionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAfterSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AfterSectionsIB )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAroundSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AroundSection )

		return TRUE

	else
		return FALSE
	ok

func IsAroundSectionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AroundSectionIB )

		return TRUE

	else
		return FALSE
	ok

func IsAroundSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AroundSections )

		return TRUE

	else
		return FALSE
	ok

func IsAroundSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AroundSectionsIB )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtRangeNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtRange )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisRangeNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisRange )

		return TRUE

	else
		return FALSE
	ok

func IsAtRangesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtRanges )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseRangesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseRanges )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyRangesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyRanges )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAtListOfRangesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListOfRanges )

		return TRUE

	else
		return FALSE
	ok

func IsAtThisListOfRangesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtThisListOfRanges )

		return TRUE

	else
		return FALSE
	ok

func IsAtListsOfRangesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtListsOfRanges )

		return TRUE

	else
		return FALSE
	ok

func IsAtTheseListsOfRangesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtTheseListsOfRanges )

		return TRUE

	else
		return FALSE
	ok

func IsAtManyListsOfRangesNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
		( isString(paList[1]) and  paList[1] = :AtManyListsOfRanges )

		return TRUE

	else
		return FALSE
	ok


#==

func IsUsingOrAtOrWhereNamedParam(paList)
	# Use IsOneOfTheseNamedParams([ ..., ..., ... ]) instead

	if This.IsUsingNamedParam(paList) or
	   This.IsAtNamedParam(paList) or
	   This.IsWhereNamedParam(paList)

		return TRUE
	else
		return FALSE
	ok

	#< @functionAlternativeForms

	func IsUsingOrWhereOrAtNamedParam(paList)
		return This.IsUsingOrAtOrWhereNamedParam(paList)
	
	func IsAtOrUsingOrWhereNamedParam(paList)
		return This.IsUsingOrAtOrWhereNamedParam(paList)

	func IsAtOrWhereOrUsingNamedParam(paList)
		return This.IsUsingOrAtOrWhereNamedParam(paList)

	func IsWhereOrAtOrUsingNamedParam(paList)
		return This.IsUsingOrAtOrWhereNamedParam(paList)

	func IsWhereOrUsingOrAtNamedParam(paList)
		return This.IsUsingOrAtOrWhereNamedParam(paList)

	#--

	func IsUsingOrWhereOrAtNamedParams()
		return This.IsUsingOrAtOrWhereNamedParam(paList)
	
	func IsAtOrUsingOrWhereNamedParams()
		return This.IsUsingOrAtOrWhereNamedParam(paList)

	func IsAtOrWhereOrUsingNamedParams()
		return This.IsUsingOrAtOrWhereNamedParam(paList)

	func IsWhereOrAtOrUsingNamedParams()
		return This.IsUsingOrAtOrWhereNamedParam(paList)

	func IsWhereOrUsingOrAtNamedParams()
		return This.IsUsingOrAtOrWhereNamedParam(paList)

	func IsUsingOrAtOrWhereNamedParams()
		return This.IsUsingOrAtOrWhereNamedParam(paList)

	#>

func IsUsingOrAtOrWhereXTNamedParam(paList)
	# Use IsOneOfTheseNamedParams([ ..., ..., ... ]) instead

	if This.IsUsingNamedParam(paList) or
	   This.IsAtNamedParam(paList) or
	   This.IsWhereXTNamedParam(paList)

		return TRUE
	else
		return FALSE
	ok

	#< @functionAlternativeForms

	func IsUsingOrWhereXTOrAtNamedParam(paList)
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)
	
	func IsAtOrUsingOrWhereXTNamedParam(paList)
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)

	func IsAtOrWhereXTOrUsingNamedParam(paList)
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)

	func IsWhereXTOrAtOrUsingNamedParam(paList)
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)

	func IsWhereXTOrUsingOrAtNamedParam(paList)
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)

	#--

	func IsUsingOrWhereXTOrAtNamedParams()
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)
	
	func IsAtOrUsingOrWhereXTNamedParams()
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)

	func IsAtOrWhereXTOrUsingNamedParams()
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)

	func IsWhereXTOrAtOrUsingNamedParams()
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)

	func IsWhereXTOrUsingOrAtNamedParams()
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)

	func IsUsingOrAtOrWhereXTNamedParams()
		return This.IsUsingOrAtOrWhereXTNamedParam(paList)

	#>
#==

func IsStepNamedParam(paList)

	if isList(paList) and len(paList) = 2 and

	   isString(paList[1]) and
	   paList[1] = :Step
	  
		return TRUE

	else
		return FALSE
	ok

func IsNameNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Name ) and
	   isString(This.Item(2))
	  
		return TRUE

	else
		return FALSE
	ok

func IsNamedNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Named ) and
	   isString(This.Item(2))
	  
		return TRUE

	else
		return FALSE
	ok

func IsNamedAsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :NamedAs ) and
	   isString(This.Item(2))
	  
		return TRUE

	else
		return FALSE
	ok

func IsRaiseNamedParam(paList)
	if isList(paList) and len(paList) <= 4 and
	   This.IsHashList() and
	   This.ToStzHashList().KeysQ().IsMadeOfSome([ :Where, :What, :Why, :Todo ]) and
	   This.ToStzHashList().ValuesQ().AllItemsVerifyW("isString(@item) and @item != NULL")

		return TRUE

	else
		return FALSE
	ok

func IsReturnedAsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and paList[1] = :ReturnedAs

		return TRUE

	else
		return FALSE
	ok

func IsAndReturnedAsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and paList[1] = :AndReturnedAs

		return TRUE

	else
		return FALSE
	ok

func IsReturnNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :Return

		return TRUE

	else
		return FALSE
	ok

func IsReturnAsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :ReturnAs

		return TRUE

	else
		return FALSE
	ok

func IsAndReturnAsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :AndReturnAs

		return TRUE

	else
		return FALSE
	ok

func IsReturnItAsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :ReturnItAs

		return TRUE

	else
		return FALSE
	ok

func IsAndReturnItAsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :AndReturnItAs

		return TRUE

	else
		return FALSE
	ok

func IsReturnThemAsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :ReturnThemAs

		return TRUE

	else
		return FALSE
	ok

func IsAndReturnThemAsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :AndReturnThemAs

		return TRUE

	else
		return FALSE
	ok

func IsReturningNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and Q(paList[1]).IsEqualToCS(:Returning, :CS = FALSE)

		return TRUE

	else
		return FALSE
	ok

func IsAndReturnNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and Q(paList[1]).IsEqualToCS(:AndReturn, :CS = FALSE)

		return TRUE

	else
		return FALSE
	ok

func IsAndReturningNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and Q(paList[1]).IsEqualToCS(:AndReturning, :CS = FALSE)

		return TRUE

	else
		return FALSE
	ok

func IsReturnNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and Q(paList[1]).IsEqualToCS(:ReturnNth, :CS = FALSE)

		return TRUE

	else
		return FALSE
	ok

func IsReturningNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and Q(paList[1]).IsEqualToCS(:ReturningNth, :CS = FALSE)

		return TRUE

	else
		return FALSE
	ok

func IsAndReturnNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and Q(paList[1]).IsEqualToCS(:AndReturnNth, :CS = FALSE)

		return TRUE

	else
		return FALSE
	ok

func IsAndReturningNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and Q(paList[1]).IsEqualToCS(:AndReturningNth, :CS = FALSE)

		return TRUE

	else
		return FALSE
	ok

func IsUpToNCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
 		   isString(paList[1]) and  paList[1] = :UpToNChars
	  
		return TRUE

	else
		return FALSE
	ok

func IsUpToNItemsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
 		   ( isString(paList[1]) and  paList[1] = :UpToNItems )
	  
		return TRUE

	else
		return FALSE
	ok

func IsUpToOrUpToNItemsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
 		   ( isString(paList[1]) and
		(paList[1] = :UpToNItems or paList[1] = :UpTo) )
	  
		return TRUE

	else
		return FALSE
	ok

	func IsUpToOrUpToNItemsNamedParams()
		return This.IsUpToOrUoToNItemsNamedParam(paList)

	func IsUpToNItemsOrUpToNamedParam(paList)
		return This.IsUpToOrUoToNItemsNamedParam(paList)

	func IsUpToNItemsOrUpToNamedParams()
		return This.IsUpToOrUoToNItemsNamedParam(paList)

func IsUpToOrUpToNPositionsNamedParam(paList)
	if ( This.NumberOfPositions() = 2 ) and
 		   ( isString(This.Position(1)) and
		(This.Position(1) = :UpToNPositions or This.Position(1) = :UpTo) )
	  
		return TRUE

	else
		return FALSE
	ok

	func IsUpToOrUpToNPositionsNamedParams()
		return This.IsUpToOrUoToNPositionsNamedParam(paList)

	func IsUpToNPositionsOrUpToNamedParam(paList)
		return This.IsUpToOrUoToNPositionsNamedParam(paList)

	func IsUpToNPositionsOrUpToNamedParams()
		return This.IsUpToOrUoToNPositionsNamedParam(paList)

func IsBeforeNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :Before )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeItemNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeItem )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeItemsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeItems )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeThisItemNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeThisItem )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeTheseItemsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeTheseItems )

		return TRUE
	else
		return FALSE
	ok

#--

func IsBeforePositionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforePosition )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeThisPositionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeThisPosition )

		return TRUE
	else
		return FALSE
	ok

func IsBeforePositionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforePositions )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeManyPositionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeManyPositions )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeThesePositionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeThesePositions )

		return TRUE
	else
		return FALSE
	ok

#--

func IsBeforeSubStringNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeSubString )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeThisSubStringNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeThisSubString )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeSubStringsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeSubStrings )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeTheseSubStringsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeTheseSubStrings )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeSubStringPositionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeSubStringPosition )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeThisSubStringPositionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeThisSubStringPosition )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeSubStringsPositionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeSubStringsPositions )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeTheseSubStringsPositionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeTheseSubStringsPositions )

		return TRUE
	else
		return FALSE
	ok

#--

func IsAfterSubStringNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterSubString )

		return TRUE
	else
		return FALSE
	ok

func IsAfterThisSubStringNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterThisSubString )

		return TRUE
	else
		return FALSE
	ok

func IsAfterSubStringsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterSubStrings )

		return TRUE
	else
		return FALSE
	ok

func IsAfterTheseSubStringsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterTheseSubStrings )

		return TRUE
	else
		return FALSE
	ok

func IsAfterSubStringPositionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterSubStringPosition )

		return TRUE
	else
		return FALSE
	ok

func IsAfterThisSubStringPositionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterThisSubStringPosition )

		return TRUE
	else
		return FALSE
	ok

func IsAfterSubStringsPositionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterSubStringsPositions )

		return TRUE
	else
		return FALSE
	ok

func IsAfterTheseSubStringsPositionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterTheseSubStringsPositions )

		return TRUE
	else
		return FALSE
	ok

#--

func IsBeforeSectionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeSection )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeThisSectionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeThisSection )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeSectionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeSections )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeTheseSectionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeTheseSections )

		return TRUE
	else
		return FALSE
	ok

#--

func IsAfterSectionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterSection )

		return TRUE
	else
		return FALSE
	ok

func IsAfterThisSectionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterThisSection )

		return TRUE
	else
		return FALSE
	ok

func IsAfterSectionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterSections )

		return TRUE
	else
		return FALSE
	ok

func IsAfterTheseSectionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterTheseSections )

		return TRUE
	else
		return FALSE
	ok

#--

func IsBeforeOrAtNamedParam(paList)
	if This.IsBeforeNamedParam(paList) or This.IsAtNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAtOrBeforeNamedParam(paList)
		return This.IsBeforeOrAtNamedParam(paList)

func IsAfterNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :After )

		return TRUE
	else
		return FALSE
	ok

func IsAfterTheseNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterThese )

		return TRUE
	else
		return FALSE
	ok

func IsAfterManyNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterMany )

		return TRUE
	else
		return FALSE
	ok

func IsAfterItemNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterItem )

		return TRUE
	else
		return FALSE
	ok

func IsAfterItemsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterItems )

		return TRUE
	else
		return FALSE
	ok

func IsAfterThisItemNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterThisItem )

		return TRUE
	else
		return FALSE
	ok

func IsAfterTheseItemsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterTheseItems )

		return TRUE
	else
		return FALSE
	ok

func IsAfterPositionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterPosition )

		return TRUE
	else
		return FALSE
	ok

func IsAfterThisPositionNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterThisPosition )

		return TRUE
	else
		return FALSE
	ok

func IsAfterPositionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterPositions )

		return TRUE
	else
		return FALSE
	ok

func IsAfterThesePositionsNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AfterThesePositions )

		return TRUE
	else
		return FALSE
	ok

func IsAfterOrAtNamedParam(paList)
	if This.IsAfterNamedParam(paList) or This.IsAtNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAtOrAfterNamedParam(paList)
		return This.IsAfterOrAtNamedParam(paList)

func IsBeforeOrAfterNamedParam(paList)
	if This.IsBeforeNamedParam(paList) or This.IsAfterNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAfterOrBeforeNamedParam(paList)
		return This.IsBeforeOrAfterNamedParam(paList)

func IsWidthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Width )

		return TRUE

	else
		return FALSE
	ok

func IsWithOrUsingNamedParam(paList)
	if This.IsWithNamedParam(paList) or This.IsUsingNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsWithOrUsingNamedParams()
		return This.IsWithOrUsingNamedParam(paList)

	func IsUsingOrWithNamedParam(paList)
		return This.IsWithOrUsingNamedParam(paList)

	func IsUsingOrWithNamedParams()
		return This.IsWithOrUsingNamedParam(paList)

func IsMadeOfNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :MadeOf )

		return TRUE

	else
		return FALSE
	ok

func IsNthTofirstNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :NthToFirst )

		return TRUE

	else
		return FALSE
	ok

func IsNthToFirstCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :NthToFirstChar )

		return TRUE

	else
		return FALSE
	ok

func IsNthToFirstItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :NthToFirstItem )

		return TRUE

	else
		return FALSE
	ok

func IsNthToLastNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :NthToLast )

		return TRUE

	else
		return FALSE
	ok

func IsNthToLastCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :NthToLastChar )

		return TRUE

	else
		return FALSE
	ok

func IsNthToLastItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :NthToLastItem )

		return TRUE

	else
		return FALSE
	ok

func IsStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :String )

		return TRUE

	else
		return FALSE
	ok

func IsThisStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisString )

		return TRUE

	else
		return FALSE
	ok

#--

func IsNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Number )

		return TRUE

	else
		return FALSE
	ok

func IsThisNumberNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisNumber )

		return TRUE

	else
		return FALSE
	ok

func IsNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Numbers )

		return TRUE

	else
		return FALSE
	ok

func IsTheseNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseNumbers )

		return TRUE

	else
		return FALSE
	ok

#--

func IsCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Char )

		return TRUE

	else
		return FALSE
	ok

func IsThisCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisChar )

		return TRUE

	else
		return FALSE
	ok

func IsCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Chars )

		return TRUE

	else
		return FALSE
	ok

func IsTheseCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseChars )

		return TRUE

	else
		return FALSE
	ok

#--

func IsThisItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisItem )

		return TRUE

	else
		return FALSE
	ok

func IsTheseItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseItems )

		return TRUE

	else
		return FALSE
	ok

func IsThisListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisList )

		return TRUE

	else
		return FALSE
	ok

func IsTheseListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseLists )

		return TRUE

	else
		return FALSE
	ok

func IsThisObjectNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisObject )

		return TRUE

	else
		return FALSE
	ok

func IsTheseObjectsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseObjects )

		return TRUE

	else
		return FALSE
	ok

#--

func IsItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Item )

		return TRUE

	else
		return FALSE
	ok

func IsItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Items )

		return TRUE

	else
		return FALSE
	ok

func IsItemAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ItemAt )

		return TRUE

	else
		return FALSE
	ok

func IsItemsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Items )

		return TRUE

	else
		return FALSE
	ok

func IsItemAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ItemAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsItemsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ItemsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsStringsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Strings )

		return TRUE

	else
		return FALSE
	ok

func IsTheseStringsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseStrings )

		return TRUE

	else
		return FALSE
	ok

func IsStringAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StringAt )

		return TRUE

	else
		return FALSE
	ok

func IsThisStringAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisStringAt )

		return TRUE

	else
		return FALSE
	ok

func IsStringAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StringAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsStringAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StringAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsItemAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ItemAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsItemsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ItemsAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsCharAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :CharAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsCharsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :CharsAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsSubStringAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :SubStringAt )

		return TRUE

	else
		return FALSE
	ok

func IsThisSubStringAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ThisSubStringAt )

		return TRUE

	else
		return FALSE
	ok

func IsSubStringsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :SubStringsAt )

		return TRUE

	else
		return FALSE
	ok

func IsTheseSubStringsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseSubStringsAt )

		return TRUE

	else
		return FALSE
	ok

func IsSubStringAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :SubStringAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsSubStringsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :SubStringsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Between )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenXT )

		return TRUE

	else
		return FALSE
	ok	

func IsBetweenIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenIB )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenIBSNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenIBS )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenSNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenS )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenCSNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenCS )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenPositions )

		return TRUE

	else
		return FALSE
	ok

#--

func IsBetweenRowNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenRow )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenRowAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenRowAt )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenRowAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenRowAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenRowsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenRowsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenRowsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenRowsAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenRowsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenRows )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenRowsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenRowsAt )

		return TRUE

	else
		return FALSE
	ok

#--

func IsBetweenColNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenCol )

		return TRUE

	else
		return FALSE
	ok

	func IsBetweenColumnNamedParam(paList)
		if isList(paList) and len(paList) = 2 and
		   ( isString(paList[1]) and  paList[1] = :BetweenColumn )

			return TRUE

		else
			return FALSE
		ok

func IsBetweenColAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenColAt )

		return TRUE

	else
		return FALSE
	ok

	func IsBetweenColumnAtNamedParam(paList)
		if isList(paList) and len(paList) = 2 and
		   ( isString(paList[1]) and  paList[1] = :BetweenColumnAt )

			return TRUE

		else
			return FALSE
		ok

func IsBetweenColAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenColAtPosition )

		return TRUE

	else
		return FALSE
	ok

	func IsBetweenColumnAtPositionNamedParam(paList)
		if isList(paList) and len(paList) = 2 and
		   ( isString(paList[1]) and  paList[1] = :BetweenColumnAtPosition )

			return TRUE

		else
			return FALSE
		ok

func IsBetweenColsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenColsAtPosition )

		return TRUE

	else
		return FALSE
	ok

	func IsBetweenColumnsAtPositionNamedParam(paList)
		if isList(paList) and len(paList) = 2 and
		   ( isString(paList[1]) and  paList[1] = :BetweenColumnsAtPosition )

			return TRUE

		else
			return FALSE
		ok

func IsBetweenColsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenColsAtPositions )

		return TRUE

	else
		return FALSE
	ok

	func IsBetweenColumnsAtPositionsNamedParam(paList)
		if isList(paList) and len(paList) = 2 and
		   ( isString(paList[1]) and  paList[1] = :BetweenColumnsAtPositions )

			return TRUE

		else
			return FALSE
		ok

func IsBetweenColsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenCols )

		return TRUE

	else
		return FALSE
	ok

	func IsBetweenColumnsNamedParam(paList)
		if isList(paList) and len(paList) = 2 and
		   ( isString(paList[1]) and  paList[1] = :BetweenColumns )

			return TRUE

		else
			return FALSE
		ok

func IsBetweenColsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenColsAt )

		return TRUE

	else
		return FALSE
	ok

	func IsBetweenColumnsAtNamedParam(paList)
		if isList(paList) and len(paList) = 2 and
		   ( isString(paList[1]) and  paList[1] = :BetweenColumnsAt )

			return TRUE

		else
			return FALSE
		ok

#--

func IsFromPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromPositions )

		return TRUE

	else
		return FALSE
	ok

func IsToPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToPositions )

		return TRUE

	else
		return FALSE
	ok

#--

func IsItemFromPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ItemFromPosition )

		return TRUE

	else
		return FALSE
	ok

func IsItemsFromPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ItemsFromPosition )

		return TRUE

	else
		return FALSE
	ok

func IsItemFromNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ItemFrom )

		return TRUE

	else
		return FALSE
	ok

func IsItemsFromNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ItemsFrom )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenItemAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenItemAt )

		return TRUE

	else
		return FALSE
	ok

func IsFromItemAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromItemAt )

		return TRUE

	else
		return FALSE
	ok

func IsToItemAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToItemAt )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenItemsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenItemsAt )

		return TRUE

	else
		return FALSE
	ok

func IsFromItemsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromItemsAt )

		return TRUE

	else
		return FALSE
	ok

func IsToItemsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToItemsAt )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenItemAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenItemAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenItemsAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenItemsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsFromItemAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromItemAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsFromItemsAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromItemsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsToItemAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToItemAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsToItemsAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToItemsAtPosition )

		return TRUE

	else
		return FALSE
	ok


func IsBetweenItemNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenItem )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenItemsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenItems )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenItemAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenItemAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsToItemAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToItemAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsFromItemAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromItemAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsFromItemPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromItemPosition )

		return TRUE

	else
		return FALSE
	ok

#--

func IsStringFromPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StringFromPosition )

		return TRUE

	else
		return FALSE
	ok

func IsStringsFromPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StringsFromPosition )

		return TRUE

	else
		return FALSE
	ok

func IsStringFromNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StringFrom )

		return TRUE

	else
		return FALSE
	ok

func IsStringsFromNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StringsFrom )

		return TRUE

	else
		return FALSE
	ok

func IsFromStringPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromStringPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenStringNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenString )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenStringsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenStrings )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenStringAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenStringAt )

		return TRUE

	else
		return FALSE
	ok

func IsToStringAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToStringAt )

		return TRUE

	else
		return FALSE
	ok

func IsFromStringAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromStringAt )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenStringAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenStringAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsFromStringAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromStringAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsToStringAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToStringAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenStringAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenStringAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsFromStringAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromStringAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsToStringAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToStringAtPositions )

		return TRUE

	else
		return FALSE
	ok

#--

func IsCharFromPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :CharFromPosition )

		return TRUE

	else
		return FALSE
	ok

func IsCharsFromPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :CharsFromPosition )

		return TRUE

	else
		return FALSE
	ok

func IsCharFromNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :CharFrom )

		return TRUE

	else
		return FALSE
	ok

func IsCharsFromNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :CharsFrom )

		return TRUE

	else
		return FALSE
	ok

func IsFromCharPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCharPosition )

		return TRUE

	else
		return FALSE
	ok

func IsCharAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :CharAt )

		return TRUE

	else
		return FALSE
	ok

func IsCharAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :CharAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenChar )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenChars )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenCharAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenCharAt )

		return TRUE

	else
		return FALSE
	ok

func IsFromCharAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCharAt )

		return TRUE

	else
		return FALSE
	ok

func IsFirstPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FirstPosition )

		return TRUE

	else
		return FALSE
	ok

func IsLastPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :LastPosition )

		return TRUE

	else
		return FALSE
	ok

func IsToCharAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCharAt )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenCharsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenCharsAt )

		return TRUE

	else
		return FALSE
	ok

func IsFromCharsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCharsAt )

		return TRUE

	else
		return FALSE
	ok

func IsToCharsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCharsAt )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenCharAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenCharAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsFromCharAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCharAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsToCharAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCharAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenCharAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenCharAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsToCharAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToCharAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsFromCharAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromCharAtPositions )

		return TRUE

	else
		return FALSE
	ok

#--

func IsStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Strings )

		return TRUE

	else
		return FALSE
	ok

func IsTheseStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseStrings )

		return TRUE

	else
		return FALSE
	ok

func IsStringsAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StringsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsTheseStringsAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :theseStringsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsStringsAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :StringsAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsTheseStringsAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseStringsAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsFromStringsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromStrings )

		return TRUE

	else
		return FALSE
	ok

func IsToStringsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToStrings )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenStringsAtNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenStringsAt )

		return TRUE

	else
		return FALSE
	ok

func IsFromStringsAtNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromStringsAt )

		return TRUE

	else
		return FALSE
	ok

func IsToStringsAtNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToStringsAt )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenStringsAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenStringsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsFromStringsAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromStringsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsToStringsAtPositionNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToStringsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsBetweenStringsAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :BetweenStringsAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsFromStringsAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :FromStringsAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsToStringsAtPositionsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToStringsAtPositions )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAndColNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndCol )

		return TRUE

	else
		return FALSE
	ok

func IsAndColumnNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndColumn )

		return TRUE

	else
		return FALSE
	ok

func IsAndColAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndColat )

		return TRUE

	else
		return FALSE
	ok

func IsAndColumnAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndColumnAt )

		return TRUE

	else
		return FALSE
	ok

func IsAndColAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndColAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsAndColumnAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndColumnAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsAndColNamedNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndColNamed )

		return TRUE

	else
		return FALSE
	ok

func IsAndColumnNamedNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndColumnNamed )

		return TRUE

	else
		return FALSE
	ok

func IsColsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Cols )

		return TRUE

	else
		return FALSE
	ok

func IsColumnsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Columns )

		return TRUE

	else
		return FALSE
	ok

func IsColsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ColsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsColumnsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ColumnsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsColsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ColsAtPositions )

		return TRUE

	else
		return FALSE
	ok

func IsColumnsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ColumnsAtPositions )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAndRowNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndRow )

		return TRUE

	else
		return FALSE
	ok

func IsAndRowAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndRowAt )

		return TRUE

	else
		return FALSE
	ok

func IsAndRowAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndRowAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsRowsAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :RowsAt )

		return TRUE

	else
		return FALSE
	ok

func IsRowsAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :RowsAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsRowsAtPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :RowsAtPositions )

		return TRUE

	else
		return FALSE
	ok

#--

func IsThisNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :This )

		return TRUE

	else
		return FALSE
	ok

func IsAndThisNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndThis )

		return TRUE

	else
		return FALSE
	ok

func IsAndThatNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :AndThat )

		return TRUE

	else
		return FALSE
	ok

#--

func IsEvalNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Eval )

		return TRUE

	else
		return FALSE
	ok

func IsEvaluateNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Evaluate )

		return TRUE

	else
		return FALSE
	ok

func IsEvalFromNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EvalFrom )

		return TRUE

	else
		return FALSE
	ok

func IsEvaluateFromNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EvaluateFrom )

		return TRUE

	else
		return FALSE
	ok

func IsEvalDirectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EvalDirection )

		return TRUE

	else
		return FALSE
	ok

func IsEvaluationDirectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :EvaluationDirection )

		return TRUE

	else
		return FALSE
	ok

func IsOrThisNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OrThis )

		return TRUE

	else
		return FALSE
	ok

func IsOrThatNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OrThat )

		return TRUE

	else
		return FALSE
	ok

#--

func IsSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :SubString )

		return TRUE
	else
		return FALSE
	ok

func IsSubstringOrSubstringsNamedParam(paList)
	if This.IsSubStringNamedParam(paList) or
	   This.IsSubStringsNamedParam(paList)

		return TRUE
	else
		return FALSE
	ok

	func IsSubStringsOrSubStringNamedParam(paList)
		return This.IsSubstringOrSubstringsNamedParam(paList)

	#--

	func IsSubstringOrSubstringsNamedParams()
		return This.IsSubstringOrSubstringsNamedParam(paList)

	func IsSubStringsOrSubStringNamedParams()
		return This.IsSubstringOrSubstringsNamedParam(paList)


func IsThisSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ThisSubString )

		return TRUE
	else
		return FALSE
	ok

func IsAndSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndSubString )

		return TRUE
	else
		return FALSE
	ok

func IsBetweenSubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BetweenSubString )

		return TRUE
	else
		return FALSE
	ok

func IsBoundedBySubStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BoundedBySubString )

		return TRUE
	else
		return FALSE
	ok

func IsSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :SubStrings )

		return TRUE
	else
		return FALSE
	ok

func IsTheseSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :TheseSubStrings )

		return TRUE

	else
		return FALSE
	ok

func IsAndSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndSubStrings )

		return TRUE
	else
		return FALSE
	ok

func IsOfSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfSubStrings )

		return TRUE
	else
		return FALSE
	ok

func IsInSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InSubStrings )

		return TRUE
	else
		return FALSE
	ok

func IsBetweenSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BetweenSubStrings )

		return TRUE
	else
		return FALSE
	ok

func IsBoundedBySubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BoundedBySubStrings )

		return TRUE
	else
		return FALSE
	ok

#--

func IsBoundedByNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BoundedBy )

		return TRUE
	else
		return FALSE
	ok

func IsBoundedByIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BoundedByIB )

		return TRUE
	else
		return FALSE
	ok


func IsIsBoundedByNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :IsBoundedBy )

		return TRUE
	else
		return FALSE
	ok

#--

func IsBoundsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Bounds )

		return TRUE
	else
		return FALSE
	ok

func IsBoundsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BoundsIB )

		return TRUE
	else
		return FALSE
	ok

func IsBoundedByOrBoundsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Bounds or paList[1] = :BoundedBy) )

		return TRUE
	else
		return FALSE
	ok

	func IsBoundsOrBoundedByNamedParam(paList)
		return This.IsBoundedByOrBoundsNamedParam(paList)

func IsBoundedByIBOrBoundsIBNamedParam(paList)
	if This.IsBoundedByIBNamedParam(paList) or This.IsBoundsIBNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsBoundsIBOrBoundedByIBNamedParam(paList)
		return This.IsBoundedByIBOrBoundsIBNamedParam(paList)

#==

func IsSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Section )

		return TRUE
	else
		return FALSE
	ok

func IsThisSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ThisSection )

		return TRUE
	else
		return FALSE
	ok

func IsSectionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :SectionIB )

		return TRUE
	else
		return FALSE
	ok

func IsThisSectionIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ThisSectionIB )

		return TRUE
	else
		return FALSE
	ok

func IsAndSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndSection )

		return TRUE
	else
		return FALSE
	ok

func IsOfSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfSection )

		return TRUE
	else
		return FALSE
	ok

func IsInSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InSection )

		return TRUE
	else
		return FALSE
	ok

func IsSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Sections )

		return TRUE
	else
		return FALSE
	ok

func IsTheseSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :TheseSections )

		return TRUE
	else
		return FALSE
	ok

func IsSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :SectionsIB )

		return TRUE
	else
		return FALSE
	ok

func IsTheseSectionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :TheseSectionsIB )

		return TRUE
	else
		return FALSE
	ok

func IsAndSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AndSections )

		return TRUE
	else
		return FALSE
	ok

func IsOfSubSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :OfSections )

		return TRUE
	else
		return FALSE
	ok

func IsInSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InSections )

		return TRUE
	else
		return FALSE
	ok

func IsSectionOrInSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :Section or paList[1] = :InSection) )

		return TRUE
	else
		return FALSE
	ok

func IsSectionsOrInSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :Sections or paList[1] = :InSections) )

		return TRUE
	else
		return FALSE
	ok

	func IsSectionsOrInSectionsNamedParams()
		return This.IsSectionsOrInSectionsNamedParam(paList)

func IsToSectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToSection )

		return TRUE
	else
		return FALSE
	ok

func IsToSectionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToSections )

		return TRUE
	else
		return FALSE
	ok

#==

func IsListSizeNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ListSize )

		return TRUE
	else
		return FALSE
	ok

func IsStringSizeNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :StringSize )

		return TRUE
	else
		return FALSE
	ok

func IsNumberOfItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :NumberOfItems )

		return TRUE
	else
		return FALSE
	ok

func IsNumberOfCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :NumberOfChars )

		return TRUE
	else
		return FALSE
	ok

func IsInAListOfNItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InAListOfNItems )

		return TRUE
	else
		return FALSE
	ok

func IsInAListOfSizeNNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InAListOfSizeN )

		return TRUE
	else
		return FALSE
	ok

func IsInAListOfSizeNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InAListOfSize )

		return TRUE
	else
		return FALSE
	ok

func IsInAListOfNNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InAListOfN )

		return TRUE
	else
		return FALSE
	ok

func IsInAListOfNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InAListOf )

		return TRUE
	else
		return FALSE
	ok

func IsInAStringOfNCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InAStringOfN )

		return TRUE
	else
		return FALSE
	ok

func IsInAStringOfSizeNNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InAStringOfSizeN )

		return TRUE
	else
		return FALSE
	ok

func IsInListOfNItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InListOfNItems )

		return TRUE
	else
		return FALSE
	ok

func IsInListOfSizeNNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InListOfSizeN )

		return TRUE
	else
		return FALSE
	ok

func IsInListOfSizeNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InListOfSize )

		return TRUE
	else
		return FALSE
	ok

func IsInListOfNNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InListOfN )

		return TRUE
	else
		return FALSE
	ok

func IsInListOfNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InListOf )

		return TRUE
	else
		return FALSE
	ok

func IsInStringOfNCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InStringOf )

		return TRUE
	else
		return FALSE
	ok

func IsInStringOfSizeNNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :InStringOfSizeN )

		return TRUE
	else
		return FALSE
	ok

#==

func IsStartNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Start )

		return TRUE
	else
		return FALSE
	ok

func IsStartOfStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :StartOfString )

		return TRUE
	else
		return FALSE
	ok

func IsStartOfListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :StartOfList )

		return TRUE
	else
		return FALSE
	ok


func IsEndNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :End )

		return TRUE
	else
		return FALSE
	ok

func IsEndOfListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :EndOfList )

		return TRUE
	else
		return FALSE
	ok

func IsEndOfStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :EndOfString )

		return TRUE
	else
		return FALSE
	ok

#--

func IsFromStartNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :FromStart )

		return TRUE
	else
		return FALSE
	ok

func IsFromStartOfStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :FromStartOfString )

		return TRUE
	else
		return FALSE
	ok

func IsFromStartOfListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :FromStartOfList )

		return TRUE
	else
		return FALSE
	ok


func IsFromEndNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :FromEnd )

		return TRUE
	else
		return FALSE
	ok

func IsFromEndOfListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :FromEndOfList )

		return TRUE
	else
		return FALSE
	ok

func IsFromEndOfStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :FromEndOfString )

		return TRUE
	else
		return FALSE
	ok

#--

func IsStartingAtCharNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :StartingAtChar )

		return TRUE
	else
		return FALSE
	ok

func IsStartingAtCharAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :StartingAtCharAt )

		return TRUE
	else
		return FALSE
	ok

func IsStartingAtCharAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :StartingAtCharAtPosition )

		return TRUE
	else
		return FALSE
	ok

func IsStartingAtItemNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :StartingAtItem )

		return TRUE
	else
		return FALSE
	ok

func IsStartingAtItemAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :StartingAtItemAt )

		return TRUE
	else
		return FALSE
	ok

func IsStartingAtItemAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :StartingAtItemAtPosition )

		return TRUE
	else
		return FALSE
	ok

#--

func IsToEndNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToEnd )

		return TRUE
	else
		return FALSE
	ok

func IsToEndOfStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToEndOfString )

		return TRUE
	else
		return FALSE
	ok

func IsToEndOfListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToEndOfList )

		return TRUE
	else
		return FALSE
	ok

func IsToStartNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToStart )

		return TRUE
	else
		return FALSE
	ok

func IsToStartofListNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToStartOfList )

		return TRUE
	else
		return FALSE
	ok

func IsToStartofStringNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :ToStartOfString )

		return TRUE
	else
		return FALSE
	ok

#==

func IsOfSizeNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :OfSize )

		return TRUE

	else
		return FALSE
	ok

func IsSizeNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Size )

		return TRUE

	else
		return FALSE
	ok

func IsDoNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Do )

		return TRUE

	else
		return FALSE
	ok

func IsUntilNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Until )

		return TRUE

	else
		return FALSE
	ok

func IsUntilPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UntilPosition )

		return TRUE

	else
		return FALSE
	ok

func IsUntilCharAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UntilCharAt )

		return TRUE

	else
		return FALSE
	ok

func IsUntilCharAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UntilCharAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsUntilItemAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UntilItemAt )

		return TRUE

	else
		return FALSE
	ok

func IsUntilItemAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UntilItemAtPosition )

		return TRUE

	else
		return FALSE
	ok


func IsUntilXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UntilXT )

		return TRUE

	else
		return FALSE
	ok

func IsUptoNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UpTo )

		return TRUE

	else
		return FALSE
	ok

func IsUptoPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UpToPosition )

		return TRUE

	else
		return FALSE
	ok

	# Misspelled form

	func IsUpToPosionNamedParam(paList)
		return This.IsUptoPositionNamedParam(paList)

func IsUpToNNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :UpToN or paList[1] = :UpToN@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsUpToCharAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UpToCharAt )

		return TRUE

	else
		return FALSE
	ok

func IsUpToCharAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UpToCharAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsUpToItemAtNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UpToItemAt )

		return TRUE

	else
		return FALSE
	ok

func IsUpToItemAtPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :UpToItemAtPosition )

		return TRUE

	else
		return FALSE
	ok

func IsUnderNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Under )

		return TRUE

	else
		return FALSE
	ok

func IsExpressionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :Expression )

		return TRUE

	else
		return FALSE
	ok

func IsToNCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToNChars )

		return TRUE

	else
		return FALSE
	ok

func IsToNItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToNItems )

		return TRUE

	else
		return FALSE
	ok

func IsToNStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToNStrings )

		return TRUE

	else
		return FALSE
	ok

func IsToNNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToNNumbers )

		return TRUE

	else
		return FALSE
	ok

func IsToNListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToNLists )

		return TRUE

	else
		return FALSE
	ok

func IsToNObjectsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and  paList[1] = :ToNObjects )

		return TRUE

	else
		return FALSE
	ok

func IsLastSepNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :LastSep or paList[1] = :LastSep@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsToEachNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :ToEach or paList[1] = :ToEach@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeEachNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :BeforeEach or paList[1] = :BeforeEach@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAfterEachNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :AfterEach or paList[1] = :AfterEach@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsToNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :ToNth or paList[1] = :ToNth@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsToFirstNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :ToFirst or paList[1] = :ToFirst@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsToLastNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :ToLast or paList[1] = :ToLast@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAfterNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :AfterNth or paList[1] = :AfterNth@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAfterFirstNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :AfterFirst or paList[1] = :AfterFirst@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAfterLastNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :AfterLast or paList[1] = :AfterLast@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :BeforeNth or paList[1] = :BeforeNth@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeTheseNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeThese )

		return TRUE
	else
		return FALSE
	ok

func IsBeforeManyNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :BeforeMany )

		return TRUE
	else
		return FALSE
	ok


func IsBeforeFirstNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :BeforeFirst or paList[1] = :BeforeFirst@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeLastNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :BeforeLast or paList[1] = :BeforeLast@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAroundNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Around or paList[1] = :Around@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAroundTheseNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AroundThese )

		return TRUE
	else
		return FALSE
	ok

func IsAroundManyNamedParam(paList)
	if ( isList(paList) and len(paList) = 2 ) and
	   ( isString(paList[1]) and paList[1] = :AroundMany )

		return TRUE
	else
		return FALSE
	ok

func IsAroundEachNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :AroundEach or paList[1] = :AroundEach@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAroundNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :AroundNth or paList[1] = :AroundNth@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAroundFirstNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :AroundFirst or paList[1] = :AroundFirst@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsAroundLastNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :AroundLast or paList[1] = :AroundLast@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsEachNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Each or paList[1] = :Each@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsFirstNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :First or paList[1] = :First@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsLastNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Last or paList[1] = :Last@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsConcatenatedNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Concatenated or paList[1] = :Concatenated@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsConcatenatedUsingNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :ConcatenatedUsing or paList[1] = :ConcatenatedUsing@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsConcatenatedWithNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :ConcatenatedWith or paList[1] = :ConcatenatedWith@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsEachNCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :EachNChars or paList[1] = :EachNChars@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsEachNItemsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :EachNItems or paList[1] = :EachNItems@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsEachNStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :EachNStrings or paList[1] = :EachNStrings@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsEachNNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :EachNNumbers or paList[1] = :EachNNumbers@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsEachNListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :EachNLists or paList[1] = :EachNLists@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsEachNPairsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :EachNPairs or paList[1] = :EachNPairs@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsEachNObjectsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :EachNObjects or paList[1] = :EachNObjects@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsDirectionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Direction or paList[1] = :Direction@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsGoingNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Going or paList[1] = :Going@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsDirectionOrGoingNamedParam(paList)
	if This.IsDirectionNamedParam(paList) or This.IsGoingNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsGoingOrDirectionNamedParam(paList)
		return This.IsDirectionOrGoingNamedParam(paList)

	#--

	func IsDirectionOrGoingNamedParams()
		return This.IsDirectionOrGoingNamedParam(paList)

	func IsGoingOrDirectionNamedParams()
		return This.IsDirectionOrGoingNamedParam(paList)

func IsComingNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Coming or paList[1] = :Coming@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsSteppingNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Stepping or paList[1] = :Stepping@ ) )

		return TRUE

	else
		return FALSE
	ok


func IsUsingOrWithOrByNamedParam(paList)

	if This.IsUsingNamedParam(paList) or
	   This.IsWithNamedParam(paList) or
	   This.IsByNamedParam(paList)

		return TRUE
	else
		return FALSE
	ok

	#< @functionAlternativeForms

	func IsUsingOrByOrWithNamedParam(paList)
		return This.IsUsingOrWithOrByNamedParam(paList)

	func IsByOrWithOrUsingNamedParam(paList)
		return This.IsUsingOrWithOrByNamedParam(paList)

	func IsByOrUsingOrWithNamedParam(paList)
		return This.IsUsingOrWithOrByNamedParam(paList)

	func IsWithOrByOrUsingNamedParam(paList)
		return This.IsUsingOrWithOrByNamedParam(paList)

	func IsWithOrUsingOrByNamedParam(paList)
		return This.IsUsingOrWithOrByNamedParam(paList)

	#--

	func IsUsingOrWithOrByNamedParams()
		return This.IsUsingOrWithOrByNamedParam(paList)

	func IsUsingOrByOrWithNamedParams()
		return This.IsUsingOrWithOrByNamedParam(paList)

	func IsByOrWithOrUsingNamedParams()
		return This.IsUsingOrWithOrByNamedParam(paList)

	func IsByOrUsingOrWithNamedParams()
		return This.IsUsingOrWithOrByNamedParam(paList)

	func IsWithOrByOrUsingNamedParams()
		return This.IsUsingOrWithOrByNamedParam(paList)

	func IsWithOrUsingOrByNamedParams()
		return This.IsUsingOrWithOrByNamedParam(paList)

	#>

func IsUsingOrWithOrByOrWhereNamedParam(paList)
	if This.IsUsingOrWithOrByNamedParam(paList) or This.IsWhereNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsUsingOrWithOrByOrWhereNamedParams()
		return This.IsUsingOrWithOrByOrWhereNamedParam(paList)

func IsNextNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Next or paList[1] = :Next@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsNextNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :NextNth or paList[1] = :NextNth@  or 
		 paList[1] = :NthNext or paList[1] = :NthNext@) )

		return TRUE

	else
		return FALSE
	ok

	func IsNthNextNamedParam(paList)
		return This.IsNextNthNamedParam(paList)

func IsPreviousNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Previous or paList[1] = :Previous@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsPreviousNthNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :PreviousNth or paList[1] = :PreviousNth@  or 
		 paList[1] = :NthPrevious or paList[1] = :NthPrevious@) )

		return TRUE

	else
		return FALSE
	ok

	func IsNthPreviousNamedParam(paList)
		return This.IsPreviousNthNamedParam(paList)

#--

func IsExactlyNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Exactly or paList[1] = :Exactly@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsMoreThenNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :MoreThen or paList[1] = :MoreThen@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsLessThenNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :LessThen or paList[1] = :LessThen@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsOfTheseNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :OfThese or paList[1] = :OfThese@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsOfTheseSubStringsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :OfTheseSubStrings or paList[1] = :OfTheseSubStrings@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsOfTheseNumbersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :OfTheseNumbers or paList[1] = :OfTheseNumbers@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsOfTheseListsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :OfTheseLists or paList[1] = :OfTheseLists@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsOfTheseObjectsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :OfTheseObjects or paList[1] = :OfTheseObjects@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsOfTheseCharsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :OfTheseChars or paList[1] = :OfTheseChars@ ) )

		return TRUE

	else
		return FALSE
	ok

func IsOfTheseLettersNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :OfTheseLetters or paList[1] = :OfTheseLetters@ ) )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAndOrAndPositionOrAndSubStringNamedParam(paList)
	if This.IsAndNamedParam(paList) or
	   This.IsAndPositionNamedParam(paList) or
	   This.IsAndSubstringNamedParam(paList)

		return TRUE
	else
		return FALSE
	ok

func IsAndOrAndSubStringOrAndPositionNamedParam(paList)
	return This.IsAndOrAndPositionOrAndSubStringNamedParam(paList)

#--

func IsAndOrAndPositionOrAndSubStringNamedParams()
	return This.IsAndOrAndPositionOrAndSubStringNamedParam(paList)

func IsAndOrAndSubStringOrAndPositionNamedParams()
	return This.IsAndOrAndSubStringOrAndPositionNamedParam(paList)

	#==

func IsAtCharsWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtCharsWhere )

		return TRUE

	else
		return FALSE
	ok

func IsAtCharsWNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtCharsW )

		return TRUE

	else
		return FALSE
	ok

func IsAtCharsWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtCharsWhereXT )

		return TRUE

	else
		return FALSE
	ok

func IsAtCharsWXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtCharsWXT )

		return TRUE

	else
		return FALSE
	ok

func IsAtSubStringsWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtSubStringsWhere )

		return TRUE

	else
		return FALSE
	ok

func IsAtSubStringsWNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtSubStringsW )

		return TRUE

	else
		return FALSE
	ok

func IsAtSubStringsWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtSubStringsWherexT )

		return TRUE

	else
		return FALSE
	ok

func IsAtSubStringsWXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AtSubStringsWXT )

		return TRUE

	else
		return FALSE
	ok

#--

func IsBeforeCharsWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeCharsWhere )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeCharsWNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeCharsW )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeCharsWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeCharsWhereXT )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeCharsWXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeCharsWXT )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeSubStringsWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeSubStringsWhere )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeSubStringsWNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeSubStringsW )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeSubStringsWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeSubStringsWhereXT )

		return TRUE

	else
		return FALSE
	ok

func IsBeforeSubStringsWXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :BeforeSubStringsWXT )

		return TRUE

	else
		return FALSE
	ok

#--

func IsAfterCharsWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AfterCharsWhere )

		return TRUE

	else
		return FALSE
	ok

func IsAfterCharsWNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AfterCharsW )

		return TRUE

	else
		return FALSE
	ok

func IsAfterCharsWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AfterCharsWhereXT )

		return TRUE

	else
		return FALSE
	ok

func IsAfterCharsWXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AfterCharsWXT )

		return TRUE

	else
		return FALSE
	ok

func IsAfterSubStringsWhereNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AftersubStringsWhere )

		return TRUE

	else
		return FALSE
	ok

func IsAfterSubStringsWNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AftersubStringsW )

		return TRUE

	else
		return FALSE
	ok

func IsAfterSubStringsWhereXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AftersubStringsWhereXT )

		return TRUE

	else
		return FALSE
	ok

func IsAfterSubStringsWXTNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :AftersubStringsWXT )

		return TRUE

	else
		return FALSE
	ok



func IsAtCharsWhereXTOrAtCharsWXTNamedParam(paList)
	if This.IsAtCharsWhereXTNamedParam(paList) or This.IsAtCharsWXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAtCharsWXTOrAtCharsWhereXTNamedParam(paList)
		return This.IsAtCharsWXTOrAtCharsWhereXTNamedParam(paList)

	#--

	func IsAtCharsWhereXTOrAtCharsWXTNamedParams()
		return This.IsAtCharsWhereXTOrAtCharsWXTNamedParam(paList)

	func IsAtCharsWXTOrAtCharsWhereXTNamedParams()
		return This.IsAtCharsWXTOrAtCharsWhereXTNamedParam(paList)


func IsBeforeCharsWhereXTOrBeforeCharsWXTNamedParam(paList)
	if This.IsBeforeCharsWhereXTNamedParam(paList) or This.IsBeforeCharsWXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsBeforeCharsWXTOrBeforeCharsWhereXTNamedParam(paList)
		return This.IsBeforeCharsWXTOrBeforeCharsWhereXTNamedParam(paList)

	#--

	func IsBeforeCharsWhereXTOrBeforeCharsWXTNamedParams()
		return This.IsBeforeCharsWhereXTOrBeforeCharsWXTNamedParam(paList)

	func IsBeforeCharsWXTOrBeforeCharsWhereXTNamedParams()
		return This.IsBeforeCharsWXTOrBeforeCharsWhereXTNamedParam(paList)

func IsAfterCharsWhereXTOrAfterCharsWXTNamedParam(paList)
	if This.IsAfterCharsWhereXTNamedParam(paList) or This.IsAfterCharsWXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAfterCharsWXTOrAfterCharsWhereXTNamedParam(paList)
		return This.IsAfterCharsWXTOrAfterCharsWhereXTNamedParam(paList)

	#--

	func IsAfterCharsWhereXTOrAfterCharsWXTNamedParams()
		return This.IsAfterCharsWhereXTOrAfterCharsWXTNamedParam(paList)

	func IsAfterCharsWXTOrAfterCharsWhereXTNamedParams()
		return This.IsAfterCharsWXTOrAfterCharsWhereXTNamedParam(paList)

func IsAtSubStringsWhereXTOrAtCharsWXTNamedParam(paList)
	if This.IsAtSubstringsWhereXTNamedParam(paList) or This.IsAtSubstringsWXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAtSubstringsWXTOrAtSubstringsWhereXTNamedParam(paList)
		return This.IsAtSubstringsWXTOrAtSubstringsWhereXTNamedParam(paList)

	#--

	func IsAtSubstringsWhereXTOrAtSubstringsWXTNamedParams()
		return This.IsAtSubstringsWhereXTOrAtSubstringsWXTNamedParam(paList)

	func IsAtSubstringsWXTOrAtSubstringsWhereXTNamedParams()
		return This.IsAtSubstringsWXTOrAtSubstringsWhereXTNamedParam(paList)

func IsBeforeSubStringsWhereXTOrBeforSubStringsWXTNamedParam(paList)
	if This.IsBeforeSubstringsWhereXTNamedParam(paList) or This.IsBeforeSubstringsWXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsBeforeSubstringsWXTOrBeforeSubstringsWhereXTNamedParam(paList)
		return This.IsBeforeSubstringsWXTOrBeforeSubstringsWhereXTNamedParam(paList)

	#--

	func IsBeforeSubstringsWhereXTOrBeforeSubstringsWXTNamedParams()
		return This.IsBeforeSubstringsWhereXTOrBeforeSubstringsWXTNamedParam(paList)

	func IsBeforeSubstringsWXTOrBeforeSubstringsWhereXTNamedParams()
		return This.IsBeforeSubstringsWXTOrBeforeSubstringsWhereXTNamedParam(paList)

func IsAfterSubStringsWhereXTOrAfterSubstringsWXTNamedParam(paList)
	if This.IsAfterSubstringsWhereXTNamedParam(paList) or This.IsAfterSubstringsWXTNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParam(paList)
		return This.IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParam(paList)

	#--

	func IsAfterSubstringsWhereXTOrAfterSubstringsWXTNamedParams()
		return This.IsAfterSubstringsWhereXTOrAfterSubstringsWXTNamedParam(paList)

	func IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParams()
		return This.IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParam(paList)

#--

func IsForwardNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Forward )

		return TRUE

	else
		return FALSE
	ok

func IsBackwardNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Backward )

		return TRUE

	else
		return FALSE
	ok

func IsForwardOrBackwardNamedParam(paList)
	if This.IsForwardNamedParam(paList) or This.IsBackwardNamedParam(paList)
		return TRUE
	else
		return FALE
	ok

	func IsForwardOrBackwardNamedParams()
		return This.IsForwardOrBAckwardNamedParam(paList)

	func IsBackwardOrforwardNamedParam(paList)
		return This.IsForwardOrBAckwardNamedParam(paList)

	func IsBackwardOrforwardNamedParams()
		return This.IsForwardOrBAckwardNamedParam(paList)

func IsJumpNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Jump )

		return TRUE

	else
		return FALSE
	ok

func IsInOrOfNamedParam(paList)
	if This.IsInNamedParam(paList) or This.IsOfNamedParam(paList)
		return TRUE
	else
		return FALSE
	ok

	func IsOfOrInNamedParam(paList)
		return IsInOrOfNamedParam(paList)

	func IsInOrOfNamedParams()
		return IsInOrOfNamedParam(paList)

	func IsOfOrInNamedParams()
		return IsInOrOfNamedParam(paList)

func IsNameOrNamedNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and (paList[1] = :Name or paList[1] = :Named ) )

		return TRUE

	else
		return FALSE
	ok

	func IsNameOrNamedNamedParams()
		return This.IsNameOrNamedNamedParam(paList)

func IsStartOrStartAtOrStaringAtNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :Start or paList[1] = :StartAt or paList[1] = :StartingAt )
	    )

		return TRUE

	else
		return FALSE
	ok

	func IsStartOrStartAtOrStaringAtNamedParams()
		return This.IsStartOrStartAtOrStaringAtNamedParam(paList)

func IsEndOrEndAtOrEndingAtNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and
		(paList[1] = :End or paList[1] = :EndAt or paList[1] = :EndingAt )
	    )

		return TRUE

	else
		return FALSE
	ok

	func IsEndOrEndAtOrEndingAtNamedParams()
		return This.IsEndOrEndAtOrEndingAtNamedParam(paList)

func IsNStepNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :NStep )

		return TRUE

	else
		return FALSE
	ok

func IsNStepsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :NStep )

		return TRUE

	else
		return FALSE
	ok


func IsStepsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   ( isString(paList[1]) and paList[1] = :Steps )

		return TRUE

	else
		return FALSE
	ok

func IsStepOrNSetpNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and

	   ( paList[1] = :End or paList[1] = :Step or paList[1] = :NStep )

		return TRUE

	else
		return FALSE
	ok

	func IsStepOrNSetpNamedParams()
		return This.IsStepOrNSetpNamedParam(paList)

func IsStepsOrNSetpsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1] and
	   ( paList[1] = :End or paList[1] = :Steps or paList[1] = :NSteps ) )

		return TRUE

	else
		return FALSE
	ok

	func IsStepsOrNSetpsNamedParams()
		return This.IsStepsOrNSetpsNamedParam(paList)

func IsStepOrStepsOrNStepOrNStepsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and

	   ( paList[1] = :Step or
	     paList[1] = :Steps or
	     paList[1] = :NStep or
	     paList[1] = :NSteps )

		return TRUE

	else
		return FALSE
	ok

	func IsStepOtNStepOrStepsOrNStepsNamedParam(paList)
		return This.IsStepOrStepsOrNStepOrNStepsNamedParam(paList)

	#--

	func IsStepOrStepsOrNStepOrNStepsNamedParams()
		return This.IsStepOrStepsOrNStepOrNStepsNamedParam(paList)

	func IsStepOtNStepOrStepsOrNStepsNamedParams()
		return This.IsStepOrStepsOrNStepOrNStepsNamedParam(paList)

func IsThanNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :Than

		return TRUE

	else
		return FALSE
	ok

func IsSeparatorNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and paList[1] = :Separator

		return TRUE

	else
		return FALSE
	ok

#--

func IsFirstCharsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :FirstChars

		return TRUE

	else
		return FALSE
	ok

func IsFirstNCharsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   ( paList[1] = :FirstNChars or paList[1] = :NFirstChars )

		return TRUE

	else
		return FALSE
	ok

	func IsNFirstCharsNamedParam(paList)
		return This.IsFirstNCharsNamedParam(paList)

func IsFirstNItemsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   ( paList[1] = :FirstNChars or paList[1] = :NFirstItems )

		return TRUE

	else
		return FALSE
	ok

	func IsNFirstItemsNamedParam(paList)
		return This.IsFirstNItemsNamedParam(paList)

#--

func IsLastCharsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :LastChars

		return TRUE

	else
		return FALSE
	ok

func IsLastNCharsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   ( paList[1] = :LastNChars or paList[1] = :NLastChars )

		return TRUE

	else
		return FALSE
	ok

	func IsNLastCharsNamedParam(paList)
		return This.IsLastNCharsNamedParam(paList)

func IsLastNItemsNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   ( paList[1] = :LastNChars or paList[1] = :NLastItems )

		return TRUE

	else
		return FALSE
	ok

	func IsNLastItemsNamedParam(paList)
		return This.IsLastNItemsNamedParam(paList)

func IsStartingAtOrAfterNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   ( paList[1] = :StartingAt or paList[1] = :After )

		return TRUE

	else
		return FALSE
	ok

	func IsStartingAtOrAfterNamedParams()
		return IsStartingAtOrAfterNamedParam(paList)

	func IsAfterOrStartingAtNamedParam(paList)
		return IsStartingAtOrAfterNamedParam(paList)

	func IsAfterOrStartingAtNamedParams()
		return IsStartingAtOrAfterNamedParam(paList)

func IsStartingAtOrBeforeNamedParam(paList)

	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   ( paList[1] = :StartingAt or paList[1] = :Before )

		return TRUE

	else
		return FALSE
	ok

	func IsStartingAtOrBeforeNamedParams()
		return IsStartingAtOrBeforeNamedParam(paList)

	func IsBeforeOrStartingAtNamedParam(paList)
		return IsStartingAtOrBeforeNamedParam(paList)

	func IsBeforeOrStartingAtNamedParams()
		return IsStartingAtOrBeforeNamedParam(paList)

func IsAtOrAtThisPositionNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   ( paList[1] = :At or paList[1] = :AthThisPosition )

		return TRUE

	else
		return FALSE
	ok

	func IsAtThisPositionOrAtNamedParam(paList)
		return This.IsAtThisPositionOrAtNamedParam(paList)

func IsAfterManyPositionsNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :AfterManyPositions

		return TRUE

	else
		return FALSE
	ok

func IsAfterManyPositionsIBNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :AfterManyPositionsIB

		return TRUE

	else
		return FALSE
	ok

#--

func IsToEndOfWordNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :ToEndOfWord

		return TRUE

	else
		return FALSE
	ok

func IsEndOfWordNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :EndOfWord

		return TRUE

	else
		return FALSE
	ok

func IsToEndOfLineNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :ToEndOfLine

		return TRUE

	else
		return FALSE
	ok

func IsEndOfLineNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :EndOfLine

		return TRUE

	else
		return FALSE
	ok

func IsToEndOfSentenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :ToEndOfSentence

		return TRUE

	else
		return FALSE
	ok

func IsEndOfSentenceNamedParam(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1]) and
	   paList[1] = :EndOfSentence

		return TRUE

	else
		return FALSE
	ok
