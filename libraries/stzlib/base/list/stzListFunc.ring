#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFUNC                #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Q-constructors for stzList modular classes. #
#                  Utility functions (Map, Filter, Reduce,     #
#                  sorting, comparison, etc.) live in           #
#                  stzlist.ring to avoid redefinition errors.   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///FUNCTIONS  ///
/////////////////

	  #============================================#
	 #  ENGINE MARSHALING (Ring list -> Engine)   #
	#============================================#

	func StzEngineMarshalList(aList)
		return StzEngineListMarshalFromRingList(aList)

	func StzEngineMarshalListValue(aList)
		pVal = StzEngineValueNewList()
		nLen = len(aList)
		for i = 1 to nLen
			item = aList[i]
			if isNumber(item)
				if floor(item) = item
					pItem = StzEngineValueNewInt(item)
				else
					pItem = StzEngineValueNewFloat(item)
				ok
				StzEngineValueListAppend(pVal, pItem)
				StzEngineValueFree(pItem)
			but isString(item)
				pItem = StzEngineValueNewString(item)
				StzEngineValueListAppend(pVal, pItem)
				StzEngineValueFree(pItem)
			but isList(item)
				aCopy = []
				_nItemLen_ = len(item)
				for j = 1 to _nItemLen_
					aCopy + item[j]
				next
				pSubVal = StzEngineMarshalListValue(aCopy)
				StzEngineValueListAppend(pVal, pSubVal)
				StzEngineValueFree(pSubVal)
			ok
		next
		return pVal

	  #============================================#
	 #  ENGINE UNMARSHALING (Engine -> Ring list)  #
	#============================================#

	func StzEngineContentFromList(pList)
		if pList = NULL
			return []
		ok

		_nEcfLen_ = StzEngineListLen(pList)
		_aEcfResult_ = []

		for _iEcf_ = 1 to _nEcfLen_
			_nEcfType_ = StzEngineListItemType(pList, _iEcf_)
			switch _nEcfType_
			on 2
				_aEcfResult_ + StzEngineListGetInt(pList, _iEcf_)
			on 3
				_aEcfResult_ + StzEngineListGetFloat(pList, _iEcf_)
			on 4
				_aEcfResult_ + StzEngineListGetString(pList, _iEcf_)
			on 5
				_pEcfSub_ = StzEngineListGetSubList(pList, _iEcf_)
				if _pEcfSub_ != NULL
					# Save loop state before recursion (Ring vars are global)
					_nEcfSaveLen_ = _nEcfLen_
					_iEcfSave_ = _iEcf_

					_aEcfSubContent_ = StzEngineContentFromList(_pEcfSub_)
					add(_aEcfResult_, _aEcfSubContent_)
					StzEngineListFree(_pEcfSub_)

					# Restore loop state after recursion
					_nEcfLen_ = _nEcfSaveLen_
					_iEcf_ = _iEcfSave_
				else
					add(_aEcfResult_, [])
				ok
			other
				_aEcfResult_ + NULL
			off
		next

		return _aEcfResult_

	  #============================================#
	 #  Q-CONSTRUCTORS FOR MODULAR CLASSES        #
	#============================================#

	#-- Core

	func StzListCoreQ(paList)
		return new stzList(paList)

	#-- Extended (with aliases)

	func StzListXTQ(paList)
		return new stzListXT(paList)

	#-- Finder

	func StzListFinderQ(paList)
		return new stzListFinder(paList)

	func StzListFinderXTQ(paList)
		return new stzListFinderXT(paList)

	#-- Replacer

	func StzListReplacerQ(paList)
		return new stzListReplacer(paList)

	func StzListReplacerXTQ(paList)
		return new stzListReplacerXT(paList)

	#-- Remover

	func StzListRemoverQ(paList)
		return new stzListRemover(paList)

	func StzListRemoverXTQ(paList)
		return new stzListRemoverXT(paList)

	#-- Inserter

	func StzListInserterQ(paList)
		return new stzListInserter(paList)

	func StzListInserterXTQ(paList)
		return new stzListInserterXT(paList)

	#-- Sorter

	func StzListSorterQ(paList)
		return new stzListSorter(paList)

	func StzListSorterXTQ(paList)
		return new stzListSorterXT(paList)

	#-- Walker

	func StzListWalkerQ(paList)
		return new stzListWalker(paList)

	func StzListWalkerXTQ(paList)
		return new stzListWalkerXT(paList)

	#-- Checker

	func StzListCheckerQ(paList)
		return new stzListChecker(paList)

	func StzListCheckerXTQ(paList)
		return new stzListCheckerXT(paList)

	#-- Duplicates

	func StzListDuplicatesQ(paList)
		return new stzListDuplicates(paList)

	func StzListDuplicatesXTQ(paList)
		return new stzListDuplicatesXT(paList)

	#-- Bounder

	func StzListBounderQ(paList)
		return new stzListBounder(paList)

	func StzListBounderXTQ(paList)
		return new stzListBounderXT(paList)

	#-- Flattener

	func StzListFlattenerQ(paList)
		return new stzListFlattener(paList)

	func StzListFlattenerXTQ(paList)
		return new stzListFlattenerXT(paList)

	#-- Counter

	func StzListCounterQ(paList)
		return new stzListCounter(paList)

	func StzListCounterXTQ(paList)
		return new stzListCounterXT(paList)

	#-- Sections

	func StzListSectionsQ(paList)
		return new stzListSections(paList)

	func StzListSectionsXTQ(paList)
		return new stzListSectionsXT(paList)

	#-- Random

	func StzListRandomQ(paList)
		return new stzListRandom(paList)

	func StzListRandomXTQ(paList)
		return new stzListRandomXT(paList)

	#-- Splits

	func StzListSplitsQ(paList)
		return new stzListSplits(paList)

	func StzListSplitsXTQ(paList)
		return new stzListSplitsXT(paList)

	#-- Stringify

	func StzListStringifyQ(paList)
		return new stzListStringify(paList)

	func StzListStringifyXTQ(paList)
		return new stzListStringifyXT(paList)

	#-- NamedParams

	func StzListNamedParamsQ(paList)
		return new stzListNamedParams(paList)

	# Phase 3 Q-constructors

	func StzListGetterQ(paList)
		return new stzListGetter(paList)

	func StzListGetterXTQ(paList)
		return new stzListGetterXT(paList)

	func StzListExtractorQ(paList)
		return new stzListExtractor(paList)

	func StzListExtractorXTQ(paList)
		return new stzListExtractorXT(paList)

	func StzListTrimmerQ(paList)
		return new stzListTrimmer(paList)

	func StzListTrimmerXTQ(paList)
		return new stzListTrimmerXT(paList)

	func StzListMoverQ(paList)
		return new stzListMover(paList)

	func StzListMoverXTQ(paList)
		return new stzListMoverXT(paList)

	func StzListClassifierQ(paList)
		return new stzListClassifier(paList)

	func StzListClassifierXTQ(paList)
		return new stzListClassifierXT(paList)

	func StzListComparatorQ(paList)
		return new stzListComparator(paList)

	func StzListComparatorXTQ(paList)
		return new stzListComparatorXT(paList)

	func StzListLeadTrailQ(paList)
		return new stzListLeadTrail(paList)

	func StzListLeadTrailXTQ(paList)
		return new stzListLeadTrailXT(paList)

	func StzListPerformerQ(paList)
		return new stzListPerformer(paList)

	func StzListPerformerXTQ(paList)
		return new stzListPerformerXT(paList)

	func StzListMergerQ(paList)
		return new stzListMerger(paList)

	func StzListMergerXTQ(paList)
		return new stzListMergerXT(paList)

#============================================================#
#                                                            #
# GLOBAL FUNCTIONS (extracted from monolithic stzList.ring)  #
#                                                            #
#============================================================#

	# @AddItem wraps Ring's add() builtin so it can be called
	# from inside classes that define their own Add() method
	# (e.g. stzList). Ring is case-insensitive so add() inside
	# a class calls This.Add() instead of the builtin.

func @AddItem(paList, pItem)
	add(paList, pItem)
	return paList

func ListLowercased(paList)
	aResult = []
	nLen = len(paList)
	for i = 1 to nLen
		if isString(paList[i])
			aResult + StzLower(paList[i])
		else
			aResult + paList[i]
		ok
	next
	return aResult

func StzListQ(paList)
	return new stzList(paList)

	#-- @MISPELLED

	func StzLitsQ(paList)
		return StzListQ(paList)

	# Narrative aliases used by listofstrings / listofnumbers etc.
	# stzListOfStrings / stzListOfNumbers / stzListOfBytes live in
	# their own modules but most string-list narrative examples just
	# need a stzList. Provide the Q-form aliases that resolve back to
	# stzListQ unless overridden by the type-specific class file.
	func StzListOfStringsQ(paList)
		return new stzListOfStrings(paList)

	func ListOfStringsQ(paList)
		return new stzListOfStrings(paList)

#===

func _ListSortingOrder(paList)
	nLen = len(paList)
	if nLen < 2
		return :Unsorted
	ok

	bAsc = 1
	bDesc = 1

	for i = 1 to nLen - 1
		if isNumber(paList[i]) and isNumber(paList[i+1])
			if paList[i] > paList[i+1]
				bAsc = 0
			ok
			if paList[i] < paList[i+1]
				bDesc = 0
			ok
		but isString(paList[i]) and isString(paList[i+1])
			if strcmp(paList[i], paList[i+1]) > 0
				bAsc = 0
			ok
			if strcmp(paList[i], paList[i+1]) < 0
				bDesc = 0
			ok
		else
			return :Unsorted
		ok
		if bAsc = 0 and bDesc = 0
			return :Unsorted
		ok
	next

	if bAsc = 1
		return :Ascending
	ok
	if bDesc = 1
		return :Descending
	ok
	return :Unsorted

#===

func DeepContainsCS(paList, pItem, pCaseSensitive)
	return StzListQ(paList).DeepContainsCS(pItem, pCaseSensitive)

	func @DeepContainsCS(paList, pItem, pCaseSensitive)
		return DeepContainsCS(paList, pItem, pCaseSensitive)


func DeepContains(paList, pItem)
	return DeepContainsCS(paList, pItem, 0)

	func @DeepContains(paList, pItem)
		return DeepContains(paList, pItem)

#--

func DeepContainsOneOfTheseCS(paList, paItems, pCaseSensitive)
	if CheckParams()
		if NOT ( isList(paList) and isList(paItems) )
			StzRaise("Incorrect param type! paList and paItems must be both lists.")
		ok
	ok

	nLenList = len(paList)
	if nLenList = 0
		return 0
	ok

	nLenItems = len(paItems)
	if nLenItems = 0
		return 0
	ok

	bResult = 0
	for i = 1 to nLenItems
		if DeepContainsCS(paList, paItems[i], pCaseSensitive)
			bResult = 1
			exit
		ok
	next

	return bResult

	func @DeepContainsOneOfTheseCS(paList, paItems, pCaseSensitive)
		return DeepContainsOneOfTheseCS(paList, paItems, pCaseSensitive)


func DeepContainsOneOfThese(paList, paItems)
	return DeepContainsOneOfTheseCS(paList, paItems, 0)

	func @DeepContainsOneOfThese(paList, paItems)
		return DeepContainsOneOfThese(paList, paItems)


#===

#NOTE the next 3 fucntions are based on the implementation made for them
# by MahÙƒoud in the Ring StdLib. Here I rewrote them for better efficiency
#TODO // We may need more performant C-based implementation for large data!

# Executing a function on each list item

func @Map(aList, cFunc)

	if CheckParams()
		if not isList( aList )
			raise( "Incorrect param type! aList must be a list.")
		ok
		If not @IsFunction(cFunc)
			raise("Incorrect param type! cFunc must be a function.")
		ok
	ok

	aListCopy = aList
	nLen = len(aList)

	for i = 1 to nLen
		aListCopy[i] = call cFunc(aListCopy[i])
	next
	return aListCopy

# Executing a function on each item of the listinorder to filter items

func @Filter(aList, cFunc)
	if CheckParams()
		if not isList( aList )
			raise( "Incorrect param type! aList must be a list.")
		ok
		If not @IsFunction(cFunc)
			raise("Incorrect param type! cFunc must be a function.")
		ok
	ok

	nLen = len(aList)
	aList2 = []

	for i = 1 to nLen

		if call cFunc(aList[i])
			aList2 + aList[i]
		ok
	next

	return aList2


# Applying function cFunc to each result xResult from a list aList,
# and return an accumulated value xResult

func @Reduce(aList, cFunc, xInitial)

	if CheckParams()
		if not isList( aList )
			raise( "Incorrect param type! aList must be a list.")
		ok
		If not @IsFunction(cFunc)
			raise("Incorrect param type! cFunc must be a function.")
		ok
	ok

	nNthElement = 0
	xNthElement = NULL
	nStart = 1
	nLength = 0
	sNthElementType = NULL
	sElementType = NULL


	nLength = Len(aList)



	if IsNULL(xInitial)
		// If the list is non-empty, then default xInitial to its first element
		if nLength > 0
			xInitial = aList[1]
			nStart = 2
			sElementType = type(xInitial)
		else
			raise("if xInitial is NULL, then Reduce() requires a non-empty list aList!")
		Ok
	else
		// If the List doesn't have at least one member, then return xInitial
		if nLength < 1
			xResult = xInitial
			return xResult
		Ok
	Ok

	sElementType = type(xInitial)
	xResult = xInitial

	// Loop through all of aList, and return an accumulated value after successfully applying cFunc to each result.
	for nElement = nStart to nLength

		xNthElement = aList[nElement]
		sNthElementType = type(xNthElement)

		If not sNthElementType = sElementType
			raise( "At least one of the elements in aList is " + sNthElementType + ".  It should be " + sElementType )
		ok

		xResult = call cFunc(xResult, xNthElement)
	next

	return xResult

#===

func ListEqualsCS(paList1, paList2, pCaseSensitive)
	return StzListQ(paList1).IsEqualToCS(paList2, pCaseSensitive)

	func ListEquals(paList1, paList2)
		return StzListQ(paList1).IsEqualTo(paList2)

func Listify(cStrInList)
	if isList(cStrInlist)
		return StzListQ(cStrInlist).Listified()
	ok

	oTempStr = new stzString(cStrInList)
	if oTempStr.IsListInString()
		cCode = 'aResult = ' + oTempStr.Content()
		eval(ccode)
		return aResult
	ok

	StzRaise("Can't proceed! cStrInList must be a string containing a well formatted Ring list.")

	func @Listify(cStrInList)
		return Listify(cStrInList)

	func StringToList(cstrInList)
		if NOT isString(cStrInList)
			StzRaise("Incorrect param type! cStrInList must be a string.")
		ok

		return Listify(cStrInList)

#===

func FirstN(n, aList)
	if CheckParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! aList must be a list.")
		ok

		if NOT isList(aList)
			StzRaise("Incorrect param type! aList must be a list.")
		ok
	ok

	aResult = []
	nLen = len(aList)
	if n >= nLen
		return aList
	ok

	for i = 1 to n
		aResult + aList[i]
	next

	return aResult

	#< @FunctionAlternativeForms

	func FirstNItems(aList)
		return FirstN(n, aList)

	func @FirstN(n, aList)
		return FirstN(n, aList)

	func @FirstNItems(n, aList)
		return FirstN(n, aList)

	func NFirst(n, aList)
		return FirstN(n, aList)

	#--

	func NFirstItems(aList)
		return FirstN(n, aList)

	func @NFirst(n, aList)
		return FirstN(n, aList)

	func @NFirstItems(n, aList)
		return FirstN(n, aList)

	#>

func First3(aList)
	return FirstN(3, aList)

	#< @FunctionAlternativeForms

	func First3Items(aList)
		return First3(aList)

	func @First3(aList)
		return First3(aList)

	func @First3Items(aList)
		return First3(aList)

	func 3First(aList)
		return First3(aList)

	#--

	func 3FirstItems(aList)
		return First3(aList)

	func @3First(aList)
		return FirstN(n, aList)

	func @3FirstItems(aList)
		return First3(aList)

	#>

#===

func Slice(pStrOrList, n1, n2)
	if CheckParams()
		if NOT (isString(pStrOrList) or isList(pStrOrList))
			StzRaise("Incorrect param type! pStrOrList must be a string or list.")
		ok
	ok

	if isString(pStrOrList)
		return StkStringQ(pStrOrList).section(n1, n2)
	else
		_aResult_ = []
		_nLen_ = len(pStrOrList)

		for @i = n1 to n2
			_aResult_ + pStrOrList[@i]
		next

		return _aResult_
	ok


func Repeat(value, nTimes)
	if CheckParams()
		if NOT isNumber(nTimes)
			StzRaise("Incorrect param type! nTimes must be a number.")
		ok
	ok

	aResult = []

	for i = 1 to nTimes
		aResult + value
	next

	return aResult

	#< @FunctionAlternativeForms

	func @Repeat(value, nTimes)
		return Repeat(value, nTimes)

	func RepeatInList(value, nTimes)
		return Repeat(value, nTimes)

	func RepeatInAList(value, nTimes)
		return Repeat(value, nTimes)

	func @RepeatInList(value, nTimes)
		return StzRepeat(value, nTimes)

	func @RpeatInAList(value, nTimes)
		return Repeat(value, nTimes)

	func RepeatN(value, nTimes)
		return Repeat(value, nTimes)

	func @RepeatN(value, nTimes)
		return Repeat(value, nTimes)

	#>


func SortingOrder(p)
	return Q(p).SortingOrder()

func SortingOrders(paListOfThings)
	if NOT isList(paListOfThings)
		StzRaise("Incorrect param type! paListOfThings must be a list.")
	ok

	acResult = []

	nLen = len(paListOfThings)
	for i = 1 to nLen
		acResult + Q(paListOfThings[i]).SortingOrder()
	next

	return acResult

func HaveSameSortingOrder(p1, p2)
	return Q(p1).HasSameSortingOrderAs(p2)

	func HaveSameSortingOrders(p1, p2)
		return HaveSameSortingOrder(p1, p2)

func SortListsBySize(paLists)
	if CheckingParam()
		if NOT ( isList(paLists) and @IsListOfLists(paLists) )
			StzRaise("Incorrect param type! paLists must be a list of lists.")
		ok
	ok

	nLen = len(paLists)

	for i = 1 to nLen
		ring_insert(paLists[i], len(paLists[i]), 1)
	next

	SortListsOn(paLists, 1)

	for i = 1 to nLen
		ring_remove(paLists[i], 1)
	next

	return paLists

	func @SortListsBySize(paLists)
		return nSortListsBySize(paLists)

func SortLists(paLists)
	return SortListsOn(palists, 1)

	func @SortLists(paList)
		return SortLists(paList)

func ListsStringifyXT(paListOfLists)
	if CheckingParams()
		if NOT ( isList(paListOfLists) and @IsListOfLists(paListOfLists) )
			StzRaise("Incorrect param type! paListOfLists must be a list of Lists.")
		ok
	ok

	if len(paListOfLists) = 0
		return [ "" ]
	ok

	aCols = StzListOfListsQ(paListOfLists).Cols()
	nLen = len(aCols)

	acColsStringified = []
	for i = 1 to nLen
		acColsStringified + ListStringifyXT(aCols[i])
	next

	oLoL = StzListOfListsQ([])

	for i = 1 to nLen
		oLoL.AddCol(acColsStringified[i])
	next

	aResult = oLoL.Content()

	return aResult


	func @ListsStringifyXT(paListOfLists)
		return ListsStringifyXT(paListOfLists)

func ListStringifyXT(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	# If list contains numbers then we adjust
	# them before we stringify them

	# We start by getting the max left and right
	# number of digits (integer and decimal parts)

	nLen = len(paList)

	nMaxSize = 0
	nMaxLeft = 0
	nMaxRight = 0

	anNumbersPos = []

	for i = 1 to nLen
		if isNumber(paList[i])

			anNumbersPos + i

			cNumber = ""+ paList[i]

			nSize = StzLen(cNumber)
			if nSize > nMaxSize
				nMaxSize = nSize
			ok

			nDotPos = ring_substr1( cNumber, "." )

			if nDotPos = 0
				nLenLeft = nSize
				nLenRight = 0

			else
				nLenLeft = nDotPos - 1
				nLenRight = nSize - nDotPos

			ok

			if nLenLeft > nMaxLeft
				nMaxLeft = nLenLeft
			ok

			if nLenRight > nMaxRight
				nMaxRight = nLenRight
			ok
		ok
	next

	nHowManyNumbers = len(anNumbersPos)

	# The numbers without decimal part are adjusted
	# first, by adding a dot and some 0s to them,
	# and then the numbers with dots are adjusted

	for i = 1 to nHowManyNumbers
		nPos = anNumbersPos[i]

		# Early check

		if paList[nPos] = 0
			paList[nPos] = "0."
			loop
		ok

		# In case where the number is not a zero

		cNumber = ""+ paList[nPos]
		nLenNumber = StzLen(cNumber)
		nPosDot = ring_substr1(cNumber, ".")
			
		if nPosDot = 0
				
			nAddLeft = nMaxLeft - nLenNumber
			nAddRight = nMaxRight

			cExtLeft = ""
			cExtRight = ""

			for j = 1 to nAddLeft
				cExtLeft += "0"
			next

			for j = 1 to nAddRight
				cExtRight += "0"
			next

			cNumber = cExtLeft + cNumber + "." + cExtRight

		else
			nAddLeft = nMaxLeft - (nPosDot - 1)
			nAddRight = nMaxRight - (nLenNumber - nPosDot)

			cExtLeft = ""
			cExtRight = ""

			for j = 1 to nAddLeft
				cExtLeft += "0"
			next

			for j = 1 to nAddRight
				cExtRight += "0"
			next

			cNumber = cExtLeft + cNumber + cExtRight

		ok

		paList[nPos] = cNumber

	next

	# Now we stringify the items of the column that
	# are not numbers (usning @@() ~> ComputableForm())

	for i = 1 to nLen
		if NOT isNumber(paList[i])
			paList[i] = @@(paList[i])
			loop
		ok

	next

	return paList

	func @ListStringifyXT(paList)
		return ListStringifyXT(paList)

func SortListsOn(paLists, n)

	# Sorts a list of lists on a given column by justifying
	# all the lists and stringifying any list item inf the
	# nth column ~> Makes it possible to internally use the
	# standard Ring sort(aListOfLits, ncol) function.

	if CheckingParam()

		# Swich params if necessary

		if isNumber(paLists) and isList(n)
			temp = paLists
			paLists = n
			n = temp
		ok

		if NOT ( isList(paLists) and @IsListOfLists(paLists) )
			StzRaise("Incorrect param type! paList must be a list of lists.")
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	# Early check 1 : If there is no lists or only one list

	nLen = len(paLists)
	if nLen = 0
		return []

	but nLen = 1
		return paLists
	ok

	# Early check 2 : If One of the lists is empty

	for i = 1 to nLen
		if len(paLists[i]) = 0
			return @SortList(paLists)
		ok
	next

	# Sort using the engine

	oTemp = new stzList(paLists)
	pList = oTemp._EngineListFromContent()
	StzEngineListSortOn(pList, n)
	aResult = StzEngineContentFromList(pList)
	StzEngineListFree(pList)
	return aResult


	#< @FunctionAlternativeForms

	func @SortListsOn(paLists, n)
		return SortListsOn(paLists, n)

	func SortOn(paLists, n)
		return SortListsOn(paLists, n)

	func @SortOn(paLists, n)
		return SortListsOn(paLists, n)

	#>

func SortOnUp(n, paList)
	return SortOn(n, paList)

	func @SortOnUp(n, paList)
		return SortOnUp(n, paList)

func SortOnDown(n, palist)
	return reverse(SortOn(n, paList))

	func @SortOnDown(n, palist)
		return SortOnDown(n, palist)

func SortOnXT(n, paList, pcDirection)
	if CheckParams()
		if isList(pcDirection) and IsDirectionOrGoingNamedParamList(pcDirection)
			pcDirection = pcDirection[2]
		ok
	ok

	if NOT isString(pcDirection)
		StzRaise("Incorrect param type! pcDirection must be a string.")
	ok

	if not StzFind([ "ascending", "descending", "up", "down" ], StzLower(pcDirection))
		StzRaise("Incorrect param value! pcDirection can be :Forward or :Backward.")
	ok

	if pcDirection = "ascending" or pcDirection = "up"
		return SortOn(n, paList)
	else
		return reverse( SortOn(n, paList) )
	ok

	func @SortOnXT(n, paList, pcDirection)
		return SortOnXT(n, paList, pcDirection)

func @SortList(paList)

	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	nLen = len(paList)
	if nLen = 0
		return []
	ok

	oTemp = new stzList(paList)
	return oTemp.Sorted()


	func SortList(paList)
		return @SortList(paList)

func @Sort(p)
	if NOT (isString(p) or isList(p))
		StzRaise("Incorrect param type! p must be a string or list.")
	ok

	if isString(p)
		oStr = new stzString(p)
		aChars = oStr.Chars()
		oTemp = new stzList(aChars)
		return oTemp.Sorted()

	else
		return @SortList(p)
	ok

func SortListBy(paList, pcExpr)
	return StzListQ(paList).SortedBy(pcExpr)

	func @SortListBy(paList, pcExpr)
		return SortListBy(paList, pcExpr)

func SortBy(paList, pcExpr)
	if CheckingParams()
		if NOT isList(paList)
			Stzraise("Incorrect param type! paList must be a list.")
		ok
	ok

	return StzListQ(paList).SortedBy(pcExpr)


	func @SortBy(paList, pcExpr)
		return SortBy(paList, pcExpr)

#==========

func Types(paValues)

	if CheckParams()
		if NOT isList(paValues)
			StzRaise("Incorrect param type! paValues must be a list.")
		ok
	ok

	_nLen_ = len(paValues)
	_acResult_ = []

	for @i = 1 to _nLen_
		_acResult_ + type(paValues[@i])
	next

	return _acResult_
	
func TypesXT(paValues)

	if CheckParams()
		if NOT isList(paValues)
			StzRaise("Incorrect param type! paValues must be a list.")
		ok
	ok

	_nLen_ = len(paValues)
	_aResult_ = []

	for @i = 1 to _nLen_
		_aResult_ + [ paValues[@i], type(paValues[@i]) ]
	next

	return _aResult_


#---

func IsSortedList(paList)
	if IsSortedListInAscending(paList) or IsSortedListInDescending(paList)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsListSorted(paList)
		return IsSortedList(paList)

	#--

	func @IsSortedList(paList)
		return IsSortedList(paList)

	func @IsListSorted(paList)
		return IsSortedList(paList)

	#>

func IsSortedListInAscending(paList)
	if NOT isList(paList)
		return 0
	ok

	return StzListQ(palist).IsSortedInAscending()

	#< @FunctionAlternativeForms

	func IsListSortedInAscending(paList)
		return IsSortedListInAscending(paList)

	#--

	func IsSortedListUp(paList)
		return IsSortedListInAscending(paList)

	func IsSortedUpList(paList)
		return IsSortedListInAscending(paList)

	func IsListSortedUp(paList)
		return IsSortedListInAscending(paList)

	#==

	func @IsSortedListInAscending(paList)
		return IsSortedListInAscending(paList)

	func @IsListSortedInAscending(paList)
		return IsSortedListInAscending(paList)

	#--

	func @IsSortedListUp(paList)
		return IsSortedListInAscending(paList)

	func @IsSortedUpList(paList)
		return IsSortedListInAscending(paList)

	func @IsListSortedUp(paList)
		return IsSortedListInAscending(paList)

	#>

func IsSortedListInDescending(paList)
	if NOT isList(paList)
		return 0
	ok

	return StzListQ(palist).IsSortedInDescending()

	#< @FunctionAlternativeForms

	func IsListSortedInDescending(paList)
		return IsSortedListInDescending(paList)

	#--

	func IsSortedListDown(paList)
		return IsSortedListInDescending(paList)

	func IsSortedDownList(paList)
		return IsSortedListInDescending(paList)

	func IsListSortedDown(paList)
		return IsSortedListInDescending(paList)

	#==

	func @IsSortedListInDescending(paList)
		return IsSortedListInDescending(paList)

	func @IsListSortedInDescending(paList)
		return IsSortedListInDescending(paList)

	#--

	func @IsSortedListDown(paList)
		return IsSortedListInDescending(paList)

	func @IsSortedDownList(paList)
		return IsSortedListInDescending(paList)

	func @IsListSortedDown(paList)
		return IsSortedListInDescending(paList)

	#>

func IsSortedListOfPairsOfNumbers(paList)
	if NOT IsListOfPairsOfNumbers(paList) and IsSortedList(paList)
		return 0
	ok

	nLen = len(paList)

	anFirst = []
	for i = 1 to nLen
		anFirst + paList[i][1]
	next

	anSecond = []
	for i = 1 to nLen
		anSecond + paList[i][2]
	next

	oList1 = new stzList(anFirst)
	oList2 = new stzList(anSecond)

	if ( oList1.IsSortedInAscending() and oList2.IsSortedInAscending() ) or
	   ( oList2.IsSortedInDescending() and oList2.IsSortedInDescending() )

		return 1
	else
		return 0
	ok

	func @IsSortedListOfPairsOfNumbers(paList)
		return IsSortedListOfPairsOfNumbers(paList)

func IsSortedUpListOfPairsOfNumbers(paList)
	if NOT IsListOfPairsOfNumbers(paList) and IsSortedInAscending(paList)
		return 0
	ok

	nLen = len(paList)

	anFirst = []
	for i = 1 to nLen
		anFirst + paList[i][1]
	next

	anSecond = []
	for i = 1 to nLen
		anSecond + paList[i][2]
	next

	oList1 = new stzList(anFirst)
	oList2 = new stzList(anSecond)

	if oList1.IsSortedInAscending() and oList2.IsSortedInAscending()
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsSortedInAscendingListOfPairsOfNumbers(paList)
		return IsSortedUpListOfPairsOfNumbers(paList)

	func IsListOfPairsOfNumbersSortedInAscending(paList)
		return IsSortedUpListOfPairsOfNumbers(paList)

	func IsListOfPairsOfNumbersSortedUp(paList)
		return IsSortedUpListOfPairsOfNumbers(paList)

	#==

	func @IsSortedUpListOfPairsOfNumbers(paList)
		return IsSortedUpListOfPairsOfNumbers(paList)

	func @IsSortedInAscendingListOfPairsOfNumbers(paList)
		return IsSortedUpListOfPairsOfNumbers(paList)

	func @IsListOfPairsOfNumbersSortedInAscending(paList)
		return IsSortedUpListOfPairsOfNumbers(paList)

	func @IsListOfPairsOfNumbersSortedUp(paList)
		return IsSortedUpListOfPairsOfNumbers(paList)

	#>

func IsSortedDownListOfPairsOfNumbers(paList)

	if NOT IsListOfPairsOfNumbers(paList) and IsSortedInDescending(paList)
		return 0
	ok

	nLen = len(paList)

	anFirst = []
	for i = 1 to nLen
		anFirst + paList[i][1]
	next

	anSecond = []
	for i = 1 to nLen
		anSecond + paList[i][2]
	next

	oList1 = new stzList(anFirst)
	oList2 = new stzList(anSecond)

	if oList1.IsSortedInDescending() and oList2.IsSortedInDescending()
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsSortedInDescendingListOfPairsOfNumbers(paList)
		return IsSortedDownListOfPairsOfNumbers(paList)

	func IsListOfPairsOfNumbersSortedInDescending(paList)
		return IsSortedDownListOfPairsOfNumbers(paList)

	func IsListOfPairsOfNumbersSortedDown(paList)
		return IsSortedDownListOfPairsOfNumbers(paList)

	#==

	func @IsSortedDownListOfPairsOfNumbers(paList)
		return IsSortedDownListOfPairsOfNumbers(paList)

	func @IsSortedInDescendingListOfPairsOfNumbers(paList)
		return IsSortedDownListOfPairsOfNumbers(paList)

	func @IsListOfPairsOfNumbersSortedInDescending(paList)
		return IsSortedDownListOfPairsOfNumbers(paList)

	func @IsListOfPairsOfNumbersSortedDown(paList)
		return IsSortedDownListOfPairsOfNumbers(paList)

	#>


func IsListOfNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)

	for i = 1 to nLen
		if not isNumber(paList[i])
			return 0
		ok
	next

	return 1

	#< @FunctionAlternativeForms

	func @IsListOfNumbers(paList)
		return IsListOfNumbers(paList)

	func IsAListOfNumbers(paList)
		return IsListOfNumbers(paList)

	func @IsAListOfNumbers(paList)
		return IsListOfNumbers(paList)

	#>

func IsSortedListOfNumbers(paList)
	if IsListOfNumbers(paList) and IsSorted(paList)
		return 1
	else
		return 0

	ok

func IsListOfNumbersSortedInAscending(paList)
	if IsListOfNumbers(paList) and IsSortedInAscending(paList)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsListOfNumbersSortedUp(paList)
		return IsListOfNumbersSortedInAscending(paList)

	func IsSortedUpListOfNumbers(paList)
		return IsListOfNumbersSortedInAscending(paList)

	func IsSortedInAscendingListOfNumbers(paList)
		return IsListOfNumbersSortedInAscending(paList)

	#>

func IsListOfNumbersSortedInDesending(paList)
	if IsListOfNumbers(paList) and IsSortedInDescending(paList)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsListOfNumbersSortedDown(paList)
		return IsListOfNumbersSortedInDescending(paList)

	func IsSortedDownListOfNumbers(paList)
		return IsListOfNumbersSortedInDescending(paList)

	func IsSortedInDescendingListOfNumbers(paList)
		return IsListOfNumbersSortedInDescending(paList)

	#>

func IsListOfListsOfNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfNumbers(paList)
		return IsListOfListsOfNumbers(paList)

	func IsAListOfListsOfNumbers(paList)
		return IsListOfListsOfNumbers(paList)

	func @IsAListOfListsOfNumbers(paList)
		return IsListOfListsOfNumbers(paList)

	#>

func IsListOfDecimalNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsDecimalNumber(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfDecimalNumbers(paList)
		return IsListOfDecimalNumbers(paList)

	func IsAListOfDecimalNumbers(paList)
		return IsListOfDecimalNumbers(paList)

	func @IsAListOfDecimalNumbers(paList)
		return IsListOfDecimalNumbers(paList)

	#>

func IsListOfListsOfDecimalNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfDecimalNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfDecimalNumbers(paList)
		return IsListOfListsOfDecimalNumbers(paList)

	func IsAListOfListsOfDecimalNumbers(paList)
		return IsListOfListsOfDecimalNumbers(paList)

	func @IsAListOfListsOfDecimalNumbers(paList)
		return IsListOfListsOfDecimalNumbers(paList)

	#>

func IsListOfBinaryNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsBinaryNumber(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfBinaryNumbers(paList)
		return IsListOfBinaryNumbers(paList)

	func IsAListOfBinaryNumbers(paList)
		return IsListOfBinaryNumbers(paList)

	func @IsAListOfBinaryNumbers(paList)
		return IsListOfBinaryNumbers(paList)

	#>

func IsListOfListsOfBinaryNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfBinaryNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfBinaryNumbers(paList)
		return IsListOfListsOfBinaryNumbers(paList)

	func IsAListOfListsOfBinaryNumbers(paList)
		return IsListOfListsOfBinaryNumbers(paList)

	func @IsAListOfListsOfBinaryNumbers(paList)
		return IsListOfListsOfBinaryNumbers(paList)

	#>

func IsListOfOctalNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsOctalNumber(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfOctalNumbers(paList)
		return IsListOfOctalNumbers(paList)

	func IsAListOfOctalNumbers(paList)
		return IsListOfOctalNumbers(paList)

	func @IsAListOfOctalNumbers(paList)
		return IsListOfOctalNumbers(paList)

	#>

	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfOctalNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfOctalNumbers(paList)
		return IsListOfListsOfOctalNumbers(paList)

	func IsAListOfListsOfOctalNumbers(paList)
		return IsListOfListsOfOctalNumbers(paList)

	func @IsAListOfListsOfOctalNumbers(paList)
		return IsListOfListsOfOctalNumbers(paList)

	#>

func IsListOfHexNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsHexNumber(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfHexNumbers(paList)
		return IsListOfHexNumbers(paList)

	func IsAListOfHexNumbers(paList)
		return IsListOfHexNumbers(paList)

	func @IsAListOfHexNumbers(paList)
		return IsListOfHexNumbers(paList)

	#>

func IsListOfListsOfHexNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfHexNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfHexNumbers(paList)
		return IsListOfListsOfHexNumbers(paList)

	func IsAListOfListsOfHexNumbers(paList)
		return IsListOfListsOfHexNumbers(paList)

	func @IsAListOfListsOfHexNumbers(paList)
		return IsListOfListsOfHexNumbers(paList)

	#>

func IsListOfStrings(paList)
	#TODO
	# Use this implementation of all IsListOf...() functions
	# ~> More performant then usign stzObjects
	
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)

	for i = 1 to nLen
		if NOT isString(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStrings(paList)
		return IsListOfStrings(paList)

	func IsAListOfStrings(paList)
		return IsListOfStrings(paList)

	func @IsAListOfStrings(paList)
		return IsListOfStrings(paList)

	#>

	#< @FunctionMisspelledForm

	func @IsListOfSttrings(paList)
		return IsListOfStrings(paList)

	#>

func IsListOfListsOfStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStrings(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStrings(paList)
		return IsListOfListsOfStrings(paList)

	func IsAListOfListsOfStrings(paList)
		return IsListOfListsOfStrings(paList)

	func @IsAListOfListsOfStrings(paList)
		return IsListOfListsOfStrings(paList)

	#>

func IsListOfLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)

	for i = 1 to nLen
		if NOT isList(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfLists(paList)
		return IsListOfLists(paList)

	func IsAListOfLists(paList)
		return IsListOfLists(paList)

	func @IsAListOfLists(paList)
		return IsListOfLists(paList)

	#>

func IsListOfHybridLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsHybridList(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfHybridLists(paList)
		return IsListOfHybridLists(paList)

	func IsAListOfHybridLists(paList)
		return IsListOfHybridLists(paList)

	func @IsAListOfHybridLists(paList)
		return IsListOfHybridLists(paList)

	#>

func IsListOfListsOfHybridLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfHybridLists(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfHybridLists(paList)
		return IsListOfListsOfHybridLists(paList)

	func IsAListOfListsOfHybridLists(paList)
		return IsListOfListsOfHybridLists(paList)

	func @IsAListOfListsOfHybridLists(paList)
		return IsListOfListsOfHybridLists(paList)

	#>

func IsListOfListsOfLists(paList)
	if NOT isList(paList)
		return 0
	ok

	return IsListOfListsOfLists(paList)

	#< @FunctionAlternativeForms

	func @IsListOfListsOfLists(paList)
		return IsListOfListsOfLists(paList)

	func IsAListOfListsOfLists(paList)
		return IsListOfListsOfLists(paList)

	func @IsAListOfListsOfLists(paList)
		return IsListOfListsOfLists(paList)

	#>

func IsListOfObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)

	for i = 1 to nLen
		if NOT isObject(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	return IsListOfObjects(paList)

	#< @FunctionAlternativeForms

	func @IsListOfObjects(paList)
		return IsListOfObjects(paList)

	func IsAListOfObjects(paList)
		return IsListOfObjects(paList)

	func @IsAListOfObjects(paList)
		return IsListOfObjects(paList)

	#>

func IsListOfListsOfObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfObjects(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfObjects(paList)
		return IsListOfListsOfObjects(paList)

	func IsAListOfListsOfObjects(paList)
		return IsListOfListsOfObjects(paList)

	func @IsAListOfListsOfObjects(paList)
		return IsListOfListsOfObjects(paList)

	#>

func IsListOfChars(pacList)
	if NOT isList(pacList)
		return 0
	ok

	bResult = 1
	nLen = len(pacList)
	for i = 1 to nLen
			if Not IsChar(pacList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfChars(paList)
		return IsListOfChars(paList)

	func IsAListOfChars(paList)
		return IsListOfChars(paList)

	func @IsAListOfChars(paList)
		return IsListOfChars(paList)

	#>

func IsListOfListsOfChars(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfChars(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfChars(paList)
		return IsListOfListsOfChars(paList)

	func IsAListOfListsOfChars(paList)
		return IsListOfListsOfChars(paList)

	func @IsAListOfListsOfChars(paList)
		return IsListOfListsOfChars(paList)

	#>

func IsListOfPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsPair(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairs(paList)
		return IsListOfPairs(paList)

	func IsAListOfPairs(paList)
		return IsListOfPairs(paList)

	func @IsAListOfPairs(paList)
		return IsListOfPairs(paList)

	#>

func IsListOfListsOfPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfPairs(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfPairs(paList)
		return IsListOfListsOfPairs(paList)

	func IsAListOfListsOfPairs(paList)
		return IsListOfListsOfPairs(paList)

	func @IsAListOfListsOfPairs(paList)
		return IsListOfListsOfPairs(paList)

	#>


func IsListOfListsOfPairsOfNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfPairsOfNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult


func IsListOfListsOfPairsOfStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfPairsOfStrings(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult


func IsListOfListsOfPairsOfLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfPairsOfLists(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

func IsPairOfPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	if IsPair(paList[i][1]) and  IsPair(paList[2])
		return 1
	else
		return 0
	ok


func IsListOfPairsOfPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsPairOfPairs(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

func IsListOfListsOfPairsOfPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfPairsOfPairs(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult


func IsListOfListsOfPairsOfObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfPairsOfObjects(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult


func IsListOfSets(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsSet(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfSets(paList)
		return IsListOfSets(paList)

	func IsAListOfSets(paList)
		return IsListOfSets(paList)

	func @IsAListOfSets(paList)
		return IsListOfSets(paList)

	#>

func IsListOfListsOfSets(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfSets(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfSets(paList)
		return IsListOfListsOfSets(paList)

	func IsAListOfListsOfSets(paList)
		return IsListOfListsOfSets(paList)

	func @IsAListOfListsOfSets(paList)
		return IsListOfListsOfSets(paList)

	#>

func IsListOfHashLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsHashList(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfHashLists(paList)
		return IsListOfHashLists(paList)

	func IsAListOfHashLists(paList)
		return IsListOfHashLists(paList)

	func @IsAListOfHashLists(paList)
		return IsListOfHashLists(paList)

	#>

func IsListOfListsOfHashLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfHashLists(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfHashLists(paList)
		return IsListOfListsOfHashLists(paList)

	func IsAListOfListsOfHashLists(paList)
		return IsListOfListsOfHashLists(paList)

	func @IsAListOfListsOfHashLists(paList)
		return IsListOfListsOfHashLists(paList)

	#>

func IsListOfGrids(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsGrid(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfGrids(paList)
		return IsListOfGrids(paList)

	func IsAListOfGrids(paList)
		return IsListOfGrids(paList)

	func @IsAListOfGrids(paList)
		return IsListOfGrids(paList)

	#>

func IsListOfListsOfGrids(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfGrids(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfGrids(paList)
		return IsListOfListsOfGrids(paList)

	func IsAListOfListsOfGrids(paList)
		return IsListOfListsOfGrids(paList)

	func @IsAListOfListsOfGrids(paList)
		return IsListOfListsOfGrids(paList)

	#>


func IsListOfListsOfTables(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfTables(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfTables(paList)
		return IsListOfListsOfTables(paList)

	func IsAListOfListsOfTables(paList)
		return IsListOfListsOfTables(paList)

	func @IsAListOfListsOfTables(paList)
		return IsListOfListsOfTables(paList)

	#>

func IsListOfTrees(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsTree(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfTrees(paList)
		return IsListOfTrees(paList)

	func IsAListOfTrees(paList)
		return IsListOfTrees(paList)

	func @IsAListOfTrees(paList)
		return IsListOfTrees(paList)

	#>

func IsListOfListsOfTrees(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfTrees(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfTrees(paList)
		return IsListOfListsOfTrees(paList)

	func IsAListOfListsOfTrees(paList)
		return IsListOfListsOfTrees(paList)

	func @IsAListOfListsOfTrees(paList)
		return IsListOfListsOfTrees(paList)

	#>

func IsListOfStzNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzNumber(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzNumbers(paList)
		return IsListOfStzNumbers(paList)

	func IsAListOfStzNumbers(paList)
		return IsListOfStzNumbers(paList)

	func @IsAListOfStzNumbers(paList)
		return IsListOfStzNumbers(paList)

	#>

func IsListOfListsOfStzNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzNumbers(paList)
		return IsListOfListsOfStzNumbers(paList)

	func IsAListOfListsOfStzNumbers(paList)
		return IsListOfListsOfStzNumbers(paList)

	func @IsAListOfListsOfStzNumbers(paList)
		return IsListOfListsOfStzNumbers(paList)

	#>

func IsListOfStzDecimalNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzDecimalNumber(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzDecimalNumbers(paList)
		return IsListOfStzDecimalNumbers(paList)

	func IsAListOfStzDecimalNumbers(paList)
		return IsListOfStzDecimalNumbers(paList)

	func @IsAListOfStzDecimalNumbers(paList)
		return IsListOfStzDecimalNumbers(paList)

	#>

func IsListOfListsOfStzDecimalNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzDecimalNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzDecimalNumbers(paList)
		return IsListOfListsOfStzDecimalNumbers(paList)

	func IsAListOfListsOfStzDecimalNumbers(paList)
		return IsListOfListsOfStzDecimalNumbers(paList)

	func @IsAListOfListsOfStzDecimalNumbers(paList)
		return IsListOfListsOfStzDecimalNumbers(paList)

	#>

func IsListOfStzBinaryNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzBinaryNumber(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzBinaryNumbers(paList)
		return IsListOfStzBinaryNumbers(paList)

	func IsAListOfStzBinaryNumbers(paList)
		return IsListOfStzBinaryNumbers(paList)

	func @IsAListOfStzBinaryNumbers(paList)
		return IsListOfStzBinaryNumbers(paList)

	#>

func IsListOfListsOfStzBinaryNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzBinaryNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzBinaryNumbers(paList)
		return IsListOfListsOfStzBinaryNumbers(paList)

	func IsAListOfListsOfStzBinaryNumbers(paList)
		return IsListOfListsOfStzBinaryNumbers(paList)

	func @IsAListOfListsOfStzBinaryNumbers(paList)
		return IsListOfListsOfStzBinaryNumbers(paList)

	#>

func IsListOfStzOctalNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzOctalNumber(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzOctalNumbers(paList)
		return IsListOfStzOctalNumbers(paList)

	func IsAListOfStzOctalNumbers(paList)
		return IsListOfStzOctalNumbers(paList)

	func @IsAListOfStzOctalNumbers(paList)
		return IsListOfStzOctalNumbers(paList)

	#>

func IsListOfListsOfStzOctalNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzOctalNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzOctalNumbers(paList)
		return IsListOfListsOfStzOctalNumbers(paList)

	func IsAListOfListsOfStzOctalNumbers(paList)
		return IsListOfListsOfStzOctalNumbers(paList)

	func @IsAListOfListsOfStzOctalNumbers(paList)
		return IsListOfListsOfStzOctalNumbers(paList)

	#>

func IsListOfStzHexNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if NOT IsStzHexNumber(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzHexNumbers(paList)
		return IsListOfStzHexNumbers(paList)

	func IsAListOfStzHexNumbers(paList)
		return IsListOfStzHexNumbers(paList)

	func @IsAListOfStzHexNumbers(paList)
		return IsListOfStzHexNumbers(paList)

	#>

func IsListOfListsOfStzHexNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzHexNumbers(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzHexNumbers(paList)
		return IsListOfListsOfStzHexNumbers(paList)

	func IsAListOfListsOfStzHexNumbers(paList)
		return IsListOfListsOfStzHexNumbers(paList)

	func @IsAListOfListsOfStzHexNumbers(paList)
		return IsListOfListsOfStzHexNumbers(paList)

	#>

func IsListOfStzStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzString(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzStrings(paList)
		return IsListOfStzStrings(paList)

	func IsAListOfStzStrings(paList)
		return IsListOfStzStrings(paList)

	func @IsAListOfStzStrings(paList)
		return IsListOfStzStrings(paList)

	#>

func IsListOfListsOfStzStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzStrings(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzStrings(paList)
		return IsListOfListsOfStzStrings(paList)

	func IsAListOfListsOfStzStrings(paList)
		return IsListOfListsOfStzStrings(paList)

	func @IsAListOfListsOfStzStrings(paList)
		return IsListOfListsOfStzStrings(paList)

	#>

func IsListOfStzLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzList(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzLists(paList)
		return IsListOfStzLists(paList)

	func IsAListOfStzLists(paList)
		return IsListOfStzLists(paList)

	func @IsAListOfStzLists(paList)
		return IsListOfStzLists(paList)

	#>

func IsListOfListsOfStzLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzLists(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzLists(paList)
		return IsListOfListsOfStzLists(paList)

	func IsAListOfListsOfStzLists(paList)
		return IsListOfListsOfStzLists(paList)

	func @IsAListOfListsOfStzLists(paList)
		return IsListOfListsOfStzLists(paList)

	#>

func IsListOfStzObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzObject(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzObjects(paList)
		return IsListOfStzObjects(paList)

	func IsAListOfStzObjects(paList)
		return IsListOfStzObjects(paList)

	func @IsAListOfStzObjects(paList)
		return IsListOfStzObjects(paList)

	#>

func IsListOfListsOfStzObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzObjects(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzObjects(paList)
		return IsListOfListsOfStzObjects(paList)

	func IsAListOfListsOfStzObjects(paList)
		return IsListOfListsOfStzObjects(paList)

	func @IsAListOfListsOfStzObjects(paList)
		return IsListOfListsOfStzObjects(paList)

	#>

func IsListOfStzChars(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzChar(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzChars(paList)
		return IsListOfStzChars(paList)

	func IsAListOfStzChars(paList)
		return IsListOfStzChars(paList)

	func @IsAListOfStzChars(paList)
		return IsListOfStzChars(paList)

	#>

func IsListOfListsOfStzChars(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzChars(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzChars(paList)
		return IsListOfListsOfStzChars(paList)

	func IsAListOfListsOfStzChars(paList)
		return IsListOfListsOfStzChars(paList)

	func @IsAListOfListsOfStzChars(paList)
		return IsListOfListsOfStzChars(paList)

	#>

func IsListOfStzPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzPair(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzPairs(paList)
		return IsListOfStzPairs(paList)

	func IsAListOfStzPairs(paList)
		return IsListOfStzPairs(paList)

	func @IsAListOfStzPairs(paList)
		return IsListOfStzPairs(paList)

	#>

func IsListOfListsOfStzPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzPairs(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzPairs(paList)
		return IsListOfListsOfStzPairs(paList)

	func IsAListOfListsOfStzPairs(paList)
		return IsListOfListsOfStzPairs(paList)

	func @IsAListOfListsOfStzPairs(paList)
		return IsListOfListsOfStzPairs(paList)

	#>

func IsListOfStzSets(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzSet(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzSets(paList)
		return IsListOfStzSets(paList)

	func IsAListOfStzSets(paList)
		return IsListOfStzSets(paList)

	func @IsAListOfStzSets(paList)
		return IsListOfStzSets(paList)

	#>

func IsListOfListsOfStzSets(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzSets(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzSets(paList)
		return IsListOfListsOfStzSets(paList)

	func IsAListOfListsOfStzSets(paList)
		return IsListOfListsOfStzSets(paList)

	func @IsAListOfListsOfStzSets(paList)
		return IsListOfListsOfStzSets(paList)

	#>

func IsListOfStzHashLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzHashList(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzHashLists(paList)
		return IsListOfStzHashLists(paList)

	func IsAListOfStzHashLists(paList)
		return IsListOfStzHashLists(paList)

	func @IsAListOfStzHashLists(paList)
		return IsListOfStzHashLists(paList)

	#>

func IsListOfListsOfStzHashLists(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzHashLists(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzHashLists(paList)
		return IsListOfListsOfStzHashLists(paList)

	func IsAListOfListsOfStzHashLists(paList)
		return IsListOfListsOfStzHashLists(paList)

	func @IsAListOfListsOfStzHashLists(paList)
		return IsListOfListsOfStzHashLists(paList)

	#>

func IsListOfStzGrids(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzGrid(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzGrids(paList)
		return IsListOfStzGrids(paList)

	func IsAListOfStzGrids(paList)
		return IsListOfStzGrids(paList)

	func @IsAListOfStzGrids(paList)
		return IsListOfStzGrids(paList)

	#>

func IsListOfListsOfStzGrids(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzGrids(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzGrids(paList)
		return IsListOfListsOfStzGrids(paList)

	func IsAListOfListsOfStzGrids(paList)
		return IsListOfListsOfStzGrids(paList)

	func @IsAListOfListsOfStzGrids(paList)
		return IsListOfListsOfStzGrids(paList)

	#>

func IsListOfStzTables(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzTable(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzTables(paList)
		return IsListOfStzTables(paList)

	func IsAListOfStzTables(paList)
		return IsListOfStzTables(paList)

	func @IsAListOfStzTables(paList)
		return IsListOfStzTables(paList)

	#>

func IsListOfListsOfStzTables(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzTables(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzTables(paList)
		return IsListOfListsOfStzTables(paList)

	func IsAListOfListsOfStzTables(paList)
		return IsListOfListsOfStzTables(paList)

	func @IsAListOfListsOfStzTables(paList)
		return IsListOfListsOfStzTables(paList)

	#>

func IsListOfStzTrees(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsStzTree(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzTrees(paList)
		return IsListOfStzTrees(paList)

	func IsAListOfStzTrees(paList)
		return IsListOfStzTrees(paList)

	func @IsAListOfStzTrees(paList)
		return IsListOfStzTrees(paList)

	#>

func IsListOfListsOfStzTrees(paList)
	if NOT isList(paList)
		return 0
	ok

	bResult = 1
	nLen = len(paList)
	for i = 1 to nLen
			if Not IsListOfStzTrees(paList[i])
				bResult = FALSE
				exit
			ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsOfStzTrees(paList)
		return IsListOfListsOfStzTrees(paList)

	func IsAListOfListsOfStzTrees(paList)
		return IsListOfListsOfStzTrees(paList)

	func @IsAListOfListsOfStzTrees(paList)
		return IsListOfListsOfStzTrees(paList)

	#>

#===

func IsUniformListCS(paList, pCaseSensitive) # Is made of the same item
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	if nLen = 0
		return 0
	but nLen = 1
		return 1
	ok

	aStzObjects = []
	for i = 1 to nLen
		aStzObects + Q(paList[i])
	next

	bResult = 1
	for i = 2 to nLen
		if NOT paList[i].IsEqualToCS(paList[1], pCaseSensitive)
			bResult = 0
			exit
		ok
	next

	return bResult

	func IsUniformList(paList)
		return IsUniformListCS(paList, 1)


func IsDeepList(paList) // Contains at least an inner list
	if NOT isList(paList)
		return 0
	ok

	bResult = 0
	nLen = len(paList)

	for i = 1 to nLen
		if isList(paList[i])
			bResult = 1
			exit
		ok
	next

	return bResult


	#< @FunctionAlternativeForms

	func @IsDeepList(paList)
		return IsDeepList(paList)

	func IsADeepList(paList)
		return IsDeepList(paList)

	func @IsADeepList(paList)
		return IsDeepList(paList)

	#>

func IsHybridList(paList) # Contains at least two different types
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	if nLen < 1
		return _FALSE
	ok

	bResult = 1
	_acTypes_ = []

	for i = 1 to nLen
		_acTypes_ + type(paList[i])
	next

	if len( U(_acTypes) ) != nLen
		return 1
	else
		return 0
	ok


	#< @FunctionAlternativeForms

	func @IsHybridList(paList)
		return IsHybridList(paList)

	func IsAHybridList(paList)
		return IsHybridList(paList)

	func @IsAHybridList(paList)
		return IsHybridList(paList)

	#>

func IsPureList(paList) # Made of itmes of same type
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	if nLen < 1
		return _FALSE
	ok

	bResult = 1
	_acTypes_ = []

	for i = 1 to nLen
		_acTypes_ + type(paList[i])
	next

	if len( U(_acTypes) ) = 1
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPureList(paList)
		return IsPureList(paList)

	func IsAPureList(paList)
		return IsPureList(paList)

	func @IsAPureList(paList)
		return IsPureList(paList)

	#>

func IsOddList(paList)
	if NOT isList(paList)
		return 0
	ok

	return isOdd(len(paList))

	#< @FunctionAlternativeForms

	func @IsOddList(paList)
		return IsOddList(paList)

	func IsAOddList(paList)
		return IsOddList(paList)

	func @IsAOddList(paList)
		return IsOddList(paList)

	#--

	func IsFardiList(paList)
		return IsOddList(paList)

	func IsAFardiList(paList)
		return IsOddList(paList)

	func @IsFardiList(paList)
		return IsOddList(paList)

	func @IsAFardiList(paList)
		return IsOddList(paList)

	#>

func IsEvenList(paList)
	if NOT isList(paList)
		return 0
	ok

	return isEven(len(paList))

	#< @FunctionAlternativeForms

	func @IsEvenList(paList)
		return IsEvenList(paList)

	func IsAEvenList(paList)
		return IsEvenList(paList)

	func @IsAEvenList(paList)
		return IsEvenList(paList)

	#--

	func IsZawjiList(paList)
		return IsOddList(paList)

	func IsAZawjiList(paList)
		return IsOddList(paList)

	func @IsZawjiList(paList)
		return IsOddList(paList)

	func @IsAZawjiList(paList)
		return IsOddList(paList)

	#>

func IsListOfBits(paList)
	if NOT ( isList(paList) and IsListOfNumbers(paList) )
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsBit(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfBits(paList)
		return IsListOfBits(paList)

	func IsAListOfBits(paList)
		return IsListOfBits(paList)

	func @IsAListOfBits(paList)
		return IsListOfBits(paList)

	#>

func IsListOfBoleans(paList)
	if NOT ( isList(paList) and IsListOfNumbers(paList) )
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsBoolean(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func IsListOfZerosAndOnes(paList)
		return IsListOfBoleans(paList)

	func @IsListOfBoleans(paList)
		return IsListOfBoleans(paList)

	func @IsListOfZerosAndOnes(paList)
		return IsListOfBoleans(paList)

	func IsAListOfZerosAndOnes(paList)
		return IsListOfBoleans(paList)

	func @IsAListOfZerosAndOnes(paList)
		return IsListOfBoleans(paList)

	#>


#===

func IsListOfLetters(paList)
	if NOT (isList(paList) and IsListOfStrings(paList) )
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsLetter(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfLetters(paList)
		return IsListOfLetters(paList)

	func IsAListOfLetters(paList)
		return IsListOfLetters(paList)

	func @IsAListOfLetters(paList)
		return IsListOfLetters(paList)

	#>

func IsListOfQBytesLists(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsQByteslist(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfQBytesLists(paList)
		return IsListOfQBytesLists(paList)

	func IsAListOfQBytesLists(paList)
		return IsListOfQBytesLists(paList)

	func @IsAListOfQBytesLists(paList)
		return IsListOfQBytesLists(paList)

	#>

func IsListOfStzBytes(paList)
	if NOT ( isList(paList) and IsListOfNumbers(paList) )
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsStzByte(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

func IsListOfStzListOfBytes(paList)
	if NOT ( isList(paList) and IsListOfNumbers(paList) )
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsListOfStzBytes(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStzListOfBytes(paList)
		return IsListOfStzListOfBytes(paList)

	func IsAListOfStzListOfBytes(paList)
		return IsListOfStzListOfBytes(paList)

	func @IsAListOfStzListOfBytes(paList)
		return IsListOfStzListOfBytes(paList)

	#>

func IsListOfNumbersInStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	_nLen_ = len(paList)

	for @i = 1 to _nLen
		if NOT isString(paList[@i])
			return 0
		ok

		if NOT @IsNumberInString(paList[@i])
			return 0
		ok
	next

	return 1

	#TODO // Make all functions independent form Softanza classes

	#< @FunctionAlternativeForms

	func @IsListOfNumbersInStrings(paList)
		return IsListOfNumbersInStrings(paList)

	func IsAListOfNumbersInStrings(paList)
		return IsListOfNumbersInStrings(paList)

	func @IsAListOfNumbersInStrings(paList)
		return IsListOfNumbersInStrings(paList)

	#>

func IsListOfNumbersOrStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT (isNumber(paList[i]) or isString(paList[i]))
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfNumbersOrStrings(paList)
		return IsListOfNumbersOrStrings(paList)

	func IsAListOfNumbersOrStrings(paList)
		return IsListOfNumbersOrStrings(paList)

	func @IsAListOfNumbersOrStrings(paList)
		return IsListOfNumbersOrStrings(paList)

	#>

func IsListOfNumbersAndStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	if nLen < 2
		return 0
	ok

	_acTypes_ = []
	for i = 1 to nLen
		_acTypes_ + type(paList[i])
	next

	_acTypes_ = U(_acTypes_)

	if len(_acTypes_) = 2 and
		ring_substr1(_acTypes_, "NUMBER") > 0 and
		ring_substr1(_acTypes_, "STRING") > 0

			return 1
	else
			return _FALSE

	ok

	#< @FunctionAlternativeForms

	func @IsListOfNumbersAndStrings(paList)
		return IsListOfNumbersAndStrings(paList)

	func IsAListOfNumbersAndStrings(paList)
		return IsListOfNumbersAndStrings(paList)

	func @IsAListOfNumbersAndStrings(paList)
		return IsListOfNumbersAndStrings(paList)

	#>

func IsListOfNumbersOrListOfStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	return IsListOfNumbers(paList) or IsListOfStrings(paList)

	#< @FunctionAlternativeForms

	func @IsListOfNumbersOrListOfStrings(paList)
		return IsListOfNumbersOrListOfStrings(paList)

	func IsAListOfNumbersOrListOfStrings(paList)
		return IsListOfNumbersOrListOfStrings(paList)

	func @IsAListOfNumbersOrListOfStrings(paList)
		return IsListOfNumbersOrListOfStrings(paList)

	#--

	func IsListOfStringsOrListOfNumbers(paList)
		return IsListOfNumbersOrListOfStrings(paList)
	
	func @IsListOfStringsOrListOfNumbers(paList)
		return IsListOfNumbersOrListOfStrings(paList)
	
	func IsAListOfStringsOrListOfNumbers(paList)
		return IsListOfNumbersOrListOfStrings(paList)
	
	func @IsAListOfStringsOrListOfNumbers(paList)
		return IsListOfNumbersOrListOfStrings(paList)

	#>

func IsListOfStringsAndPairsOfStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT (isString(paList[i]) or isPairOfStrings(paList[i]))
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfStringsAndPairsOfStrings(paList)
		return IsListOfStringsAndPairsOfStrings(paList)

	func IsAListOfStringsAndPairsOfStrings(paList)
		return IsListOfStringsAndPairsOfStrings(paList)

	func @IsAListOfStringsAndPairsOfStrings(paList)
		return IsListOfStringsAndPairsOfStrings(paList)

	#>

func IsListOfNumbersAndPairsOfNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT (isNumber(paList[i]) or isPairOfNumbers(paList[i]))
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfNumbersAndPairsOfNumbers(paList)
		return IsListOfNumbersAndPairsOfNumbers(paList)

	func IsAListOfNumbersAndPairsOfNumbers(paList)
		return IsListOfNumbersAndPairsOfNumbers(paList)

	func @IsAListOfNumbersAndPairsOfNumbers(paList)
		return IsListOfNumbersAndPairsOfNumbers(paList)

	#>

func IsListOfListsAndPairsOfLists(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT (isList(paList[i]) or IsPairOfLists(paList[i]))
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfListsAndPairsOfLists(paList)
		return IsListOfListsAndPairsOfLists(paList)

	func IsAListOfListsAndPairsOfLists(paList)
		return IsListOfListsAndPairsOfLists(paList)

	func @IsAListOfListsAndPairsOfLists(paList)
		return IsListOfListsAndPairsOfLists(paList)

	#>

func IsListOfObjectsAndPairsOfObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT (isObject(paList[i]) or IsPairOfobjects(paList[i]))
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfObjectsAndPairsOfObjects(paList)
		return IsListOfObjectsAndPairsOfObjects(paList)

	func IsAListOfObjectsAndPairsOfObjects(paList)
		return IsListOfObjectsAndPairsOfObjects(paList)

	func @IsAListOfObjectsAndPairsOfObjects(paList)
		return IsListOfObjectsAndPairsOfObjects(paList)

	#>

func IsPairOfStrings(paPair)
	if isList(paPair) and len(paPair) = 2 and
	   isString(paPair[1]) and isString(paPair[2])

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfStrings(paPair)
		return IsPairOfStrings(paPair)

	func IsAPairOfStrings(paPair)
		return IsPairOfStrings(paPair)

	func @IsAPairOfStrings(paPair)
		return IsPairOfStrings(paPair)

	#>

func IsListOfPairsOfStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfStrings(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfStrings(paList)
		return IsListOfPairsOfStrings(paList)

	func IsAListOfPairsOfStrings(paList)
		return IsListOfPairsOfStrings(paList)

	func @IsAListOfPairsOfStrings(paList)
		return IsListOfPairsOfStrings(paList)

	#>

func IsPairOfNumbers(paPair)
	if isList(paPair) and len(paPair) = 2 and
	   isNumber(paPair[1]) and isNumber(paPair[2])

		return 1
	else

		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfNumbers(paPair)
		return IsPairOfNumbers(paPair)

	func IsAPairOfNumbers(paPair)
		return IsPairOfNumbers(paPair)

	func @IsAPairOfNumbers(paPair)
		return IsPairOfNumbers(paPair)

	#>

func IsListOfPairsOfNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfNumbers(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfNumbers(paList)
		return IsListOfPairsOfNumbers(paList)

	func IsAListOfPairsOfNumbers(paList)
		return IsListOfPairsOfNumbers(paList)

	func @IsAListOfPairsOfNumbers(paList)
		return IsListOfPairsOfNumbers(paList)

	#--

	func IsListOfSections(paList)
		return IsListOfPairsOfNumbers(paList)

	func @IsListOfSections(paList)
		return IsListOfPairsOfNumbers(paList)

	func IsAListOfSections(paList)
		return IsListOfPairsOfNumbers(paList)

	func @IsAListOfSections(paList)
		return IsListOfPairsOfNumbers(paList)

	#>

func IsPairOfSections(paPair)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if IsSection(paPair[1]) and IsSection(paPair[2])
		return 1
	else
		return 0
	ok


	#< @FunctionAlternativeForms

	func @IsPairOfSections(paPair)
		return IsPairOfSections(paPair)

	func IsAPairOfSections(paPair)
		return IsPairOfSections(paPair)

	func @IsAPairOfSections(paPair)
		return IsPairOfSections(paPair)

	#>

func IsListOfPairsOfSections(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfSections(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfSections(paList)
		return IsListOfPairsOfSections(paList)

	func IsAListOfPairsOfSections(paList)
		return IsListOfPairsOfSections(paList)

	func @IsAListOfPairsOfSections(paList)
		return IsListOfPairsOfSections(paList)

	#>

func IsPairOfLists(paPair)
	if isList(paList) and len(paList) = 2 and
	   isList(paList[1]) and isList(paList[2])

		return 1
	else

		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfLists(paPair)
		return IsPairOfLists(paPair)

	func IsAPairOfLists(paPair)
		return IsPairOfLists(paPair)

	func @IsAPairOfLists(paPair)
		return IsPairOfLists(paPair)

	#>

func IsListOfPairsOfLists(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfLists(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfLists(paList)
		return IsListOfPairsOfLists(paList)

	func IsAListOfPairsOfLists(paList)
		return IsListOfPairsOfLists(paList)

	func @IsAListOfPairsOfLists(paList)
		return IsListOfPairsOfLists(paList)

	#>

func IsPairOfObjects(paPair)
	if isList(paList) and len(paList) = 2 and
	   isObject(paList[1]) and isObject(paList[2])

		return 1
	else

		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfObjects(paPair)
		return IsPairOfObjects(paPair)

	func IsAPairOfObjects(paPair)
		return IsPairOfObjects(paPair)

	func @IsAPairOfObjects(paPair)
		return IsPairOfObjects(paPair)

	#>

func IsListOfPairsOfObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfObjects(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfObjects(paList)
		return IsListOfPairsOfObjects(paList)

	func IsAListOfPairsOfObjects(paList)
		return IsListOfPairsOfObjects(paList)

	func @IsAListOfPairsOfObjects(paList)
		return IsListOfPairsOfObjects(paList)

	#>

func IsPairAndKeyIsString(paList)
	if isList(paList) and len(paList) = 2 and
	   isString(paList[1])

		return 1
	else

		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairAndKeyIsString(paList)
		return IsPairAndKeyIsString(paList)

	func IsAPairAndKeyIsString(paList)
		return IsPairAndKeyIsString(paList)

	func @IsAPairAndKeyIsString(paList)
		return IsPairAndKeyIsString(paList)

	#>

func IsPairOfStzObjects(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if IsStzObject(paList[1]) and IsStzObject(paList[2])
		return 1
	else
		return 0
	ok


	#< @FunctionAlternativeForms

	func @IsPairOfStzObjects(paList)
		return IsPairOfStzObjects(paList)

	func IsAPairOfStzObjects(paList)
		return IsPairOfStzObjects(paList)

	func @IsAPairOfStzObjects(paList)
		return IsPairOfStzObjects(paList)

	#>

func IsListOfPairsOfStzObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfStzObjects(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult
	#< @FunctionAlternativeForms

	func @IsListOfPairsOfStzObjects(paList)
		return IsListOfPairsOfStzObjects(paList)

	func IsAListOfPairsOfStzObjects(paList)
		return IsListOfPairsOfStzObjects(paList)

	func @IsAListOfPairsOfStzObjects(paList)
		return IsListOfPairsOfStzObjects(paList)

	#>

func IsPairOfStzNumbers(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if IsStzNumber(paList[1]) and IsStzNumber(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfStzNumbers(paList)
		return IsPairOfStzNumbers(paList)

	func IsAPairOfStzNumbers(paList)
		return IsPairOfStzNumbers(paList)

	func @IsAPairOfStzNumbers(paList)
		return IsPairOfStzNumbers(paList)

	#>

func IsListOfPairsOfStzNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfStzNumbers(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfStzNumbers(paList)
		return IsListOfPairsOfStzNumbers(paList)

	func IsAListOfPairsOfStzNumbers(paList)
		return IsListOfPairsOfStzNumbers(paList)

	func @IsAListOfPairsOfStzNumbers(paList)
		return IsListOfPairsOfStzNumbers(paList)

	#>

func IsPairOfStzStrings(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if IsStzString(paList[1]) and IsStzString(paList[2])
		return 1
	else
		return 0
	ok


	#< @FunctionAlternativeForms

	func @IsPairOfStzStrings(paList)
		return IsPairOfStzStrings(paList)

	func IsAPairOfStzStrings(paList)
		return IsPairOfStzStrings(paList)

	func @IsAPairOfStzStrings(paList)
		return IsPairOfStzStrings(paList)

	#>


func IsListOfPairsOfStzStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfStzStings(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult


	#< @FunctionAlternativeForms

	func @IsListOfPairsOfStzStrings(paList)
		return IsListOfPairsOfStzStrings(paList)

	func IsAListOfPairsOfStzStrings(paList)
		return IsListOfPairsOfStzStrings(paList)

	func @IsAListOfPairsOfStzStrings(paList)
		return IsListOfPairsOfStzStrings(paList)

	#>

func IsPairOfStzLists(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if IsStzList(paList[1]) and IsStzList(paList[2])
		return 1
	else
		return 0
	ok


	#< @FunctionAlternativeForms

	func @IsPairOfStzLists(paList)
		return IsPairOfStzLists(paList)

	func IsAPairOfStzLists(paList)
		return IsPairOfStzLists(paPair)

	func @IsAPairOfStzLists(paPair)
		return IsPairOfStzLists(paList)

	#>

func IsListOfPairsOfStzLists(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfStzLists(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfStzLists(paList)
		return IsListOfPairsOfStzLists(paList)

	func IsAListOfPairsOfStzLists(paList)
		return IsListOfPairsOfStzLists(paList)

	func @IsALitsOfPairsOfStzLists(paList)
		return IsListOfPairsOfStzLists(paList)

	#>

func IsPairOfNumberAndString(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isNumber(paList[1]) and isString(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfNumberAndString(paList)
		return IsPairOfNumberAndString(paList)

	func IsAPairOfNumberAndString(paList)
		return IsPairOfNumberAndString(paList)

	func @IsAPairOfNumberAndString(paList)
		return IsPairOfNumberAndString(paList)

	#>

func IsListOfPairsOfNumberAndString(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfNumberAndString(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfNumberAndString(paList)
		return IsListOfPairsOfNumberAndString(paList)

	func IsAListOfPairsOfNumberAndString(paList)
		return IsListOfPairsOfNumberAndString(paList)

	func @IsAListOfPairsOfNumberAndString(paList)
		return IsListOfPairsOfNumberAndString(paList)

	#>

func IsPairOfStringAndNumber(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isString(paList[1]) and isNumber(paList[2])
		return 1
	else
		return 0
	ok


	#< @FunctionAlternativeForms

	func @IsPairOfStringAndNumber(paList)
		return IsPairOfStringAndNumber(paList)

	func IsAPairOfStringAndNumber(paList)
		return IsPairOfStringAndNumber(paList)

	func @IsAPairOfStringAndNumber(paList)
		return IsPairOfStringAndNumber(paList)

	#>

func IsListOfPairsOfStringAndNumber(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfStringAndNumber(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfStringAndNumber(paList)
		return IsListOfPairsOfStringAndNumber(paList)

	func IsAListOfPairsOfStringAndNumber(paList)
		return IsListOfPairsOfStringAndNumber(paList)

	func @IsAListOfPairsOfStringAndNumber(paList)
		return IsListOfPairsOfStringAndNumber(paList)

	#>

func IsPairOfNumberAndList(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isNumber(paList[1]) and isList(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfNumberAndList(paList)
		return IsPairOfNumberAndList(paList)

	func IsAPairOfNumberAndList(paList)
		return IsPairOfNumberAndList(paList)

	func @IsAPairOfNumberAndList(paList)
		return IsPairOfNumberAndList(paList)

	#>

func IsListOfPairsOfNumberAndList(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfNumberAndList(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfNumberAndList(paList)
		return IsListOfPairsOfNumberAndList(paList)

	func IsAListOfPairsOfNumberAndList(paList)
		return IsListOfPairsOfNumberAndList(paList)

	func @IsAListOfPairsOfNumberAndList(paList)
		return IsListOfPairsOfNumberAndList(paList)

	#>

func IsPairOfListAndNumber(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isList(paList[1]) and isNumber(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfListAndNumber(paList)
		return IsPairOfListAndNumber(paList)

	func IsAPairOfListAndNumber(paList)
		return IsPairOfListAndNumber(paList)

	func @IsAPairOfListAndNumber(paList)
		return IsPairOfListAndNumber(paList)

	#>

func IsListOfPairsOfListAndNumber(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfListAndNumber(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfListAndNumber(paList)
		return IsListOfPairsOfListAndNumber(paList)

	func IsAListOfPairsOfListAndNumber(paList)
		return IsListOfPairsOfListAndNumber(paList)

	func @IsAListOfPairsOfListAndNumber(paList)
		return IsListOfPairsOfListAndNumber(paList)

	#>

func IsPairOfNumberAndObject(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isNumber(paList[1]) and isObject(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfNumberAndObject(paList)
		return IsPairOfNumberAndObject(paList)

	func IsAPairOfNumberAndObject(paList)
		return IsPairOfNumberAndObject(paList)

	func @IsAPairOfNumberAndObject(paList)
		return IsPairOfNumberAndObject(paList)

	#>

func IsListOfPairsOfNumberAndObject(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfNumberAndObject(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfNumberAndObject(paList)
		return IsListOfPairsOfNumberAndObject(paList)

	func IsAListOfPairsOfNumberAndObject(paList)
		return IsListOfPairsOfNumberAndObject(paList)

	func @IsAListOfPairsOfNumberAndObject(paList)
		return IsListOfPairsOfNumberAndObject(paList)

	#>

func IsPairOfObjectAndNumber(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isObject(paList[1]) and isNumber(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfObjectAndNumber(paList)
		return IsPairOfObjectAndNumber(paList)

	func IsAPairOfObjectAndNumber(paList)
		return IsPairOfObjectAndNumber(paList)

	func @IsAPairOfObjectAndNumber(paList)
		return IsPairOfObjectAndNumber(paList)

	#>

func IsListOfPairsOfObjectAndNumber(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfObjectAndNumber(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfObjectAndNumber(paList)
		return IsListOfPairsOfObjectAndNumber(paList)

	func IsAListOfPairsOfObjectAndNumber(paList)
		return IsListOfPairsOfObjectAndNumber(paList)

	func @IsAListOfPairsOfObjectAndNumber(paList)
		return IsListOfPairsOfObjectAndNumber(paList)

	#>

func IsPairOfStringAndList(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isString(paList[1]) and isList(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfStringAndList(paList)
		return IsPairOfStringAndList(paList)

	func IsAPairOfStringAndList(paList)
		return IsPairOfStringAndList(paList)

	func @IsAPairOfStringAndList(paPair)
		return IsPairOfStringAndList(paPair)

	#>

func IsListOfPairsOfStringAndList(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfStringAndList(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfStringAndList(paList)
		return IsListOfPairsOfStringAndList(paList)

	func IsAListOfPairsOfStringAndList(paList)
		return IsListOfPairsOfStringAndList(paList)

	func @IsAListOfPairsOfStringAndList(paList)
		return IsListOfPairsOfStringAndList(paList)

	#>

func IsPairOfListAndString(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isList(paList[1]) and isString(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfListAndString(paList)
		return IsPairOfListAndString(paList)

	func IsAPairOfListAndString(paList)
		return IsPairOfListAndString(paList)

	func @IsAPairOfListAndString(paList)
		return IsPairOfListAndString(paList)

	#>

func IsListOfPairsOfListAndString(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfListAndString(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfListAndString(paList)
		return IsListOfPairsOfListAndString(paList)

	func IsAListOfPairsOfListAndString(paList)
		return IsListOfPairsOfListAndString(paList)

	func @IsAListOfPairsOfListAndString(paList)
		return IsListOfPairsOfListAndString(paList)

	#>

func IsPairOfStringAndObject(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isString(paList[1]) and isObject(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfStringAndObject(paList)
		return IsPairOfStringAndObject(paList)

	func IsAPairOfStringAndObject(paList)
		return IsPairOfStringAndObject(paList)

	func @IsAPairOfStringAndObject(paList)
		return IsPairOfStringAndObject(paList)

	#>

func IsListOfPairsOfStringAndObject(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfStringAndObject(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfStringAndObject(paList)
		return IsListOfPairsOfStringAndObject(paList)

	func IsAListOfPairsOfStringAndObject(paList)
		return IsListOfPairsOfStringAndObject(paList)

	func @IsAListOfPairsOfStringAndObject(paList)
		return IsListOfPairsOfStringAndObject(paList)

	#>

func IsPairOfObjectAndString(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isObject(paList[1]) and isString(paList[2])
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsPairOfObjectAndString(paList)
		return IsPairOfObjectAndString(paList)

	func IsAPairOfObjectAndString(paList)
		return IsPairOfObjectAndString(paList)

	func @IsAPairOfObjectAndString(paList)
		return IsPairOfObjectAndString(paList)

	#>

func IsListOfPairsOfObjectAndString(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfObjectAndString(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfObjectAndString(paList)
		return IsListOfPairsOfObjectAndString(paList)

	func IsAListOfPairsOfObjectAndString(paList)
		return IsListOfPairsOfObjectAndString(paList)

	func @IsAListOfPairsOfObjectAndString(paList)
		return IsListOfPairsOfObjectAndString(paList)

	#>

func IsPairOfListAndObject(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	if isList(paList[1]) and isobject(paList[2])
		return 1
	else
		return 0
	ok


	#< @FunctionAlternativeForms

	func @IsPairOfListAndObject(paList)
		return IsPairOfListAndObject(paList)

	func IsAPairOfListAndObject(paList)
		return IsPairOfListAndObject(paList)

	func @IsAPairOfListAndObject(paList)
		return IsPairOfListAndObject(paList)

	#>

func IsListOfPairsOfListAndObject(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfListAndObject(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfListAndObject(paList)
		return IsListOfPairsOfListAndObject(paList)

	func IsAListOfPairsOfListAndObject(paList)
		return IsListOfPairsOfListAndObject(paList)

	func @IsAListOfPairsOfListAndObject(paPair)
		return IsListOfPairsOfListAndObject(paList)

	#>

func IsPairOfChars(paList)
	if NOT ( isList(paList) and len(paList) = 2 )
		return 0
	ok

	return StzPairQ(paList).IsPairOfChars()

	#< @FunctionAlternativeForms

	func @IsPairOfChars(paList)
		return IsPairOfChars(paList)

	func IsAPairOfChars(paList)
		return IsPairOfChars(paList)

	func @IsAPairOfChars(paList)
		return IsPairOfChars(paList)

	#>

func IsListOfPairsOfChars(paList)
	if NOT isList(paList)
		return 0
	ok

	nLen = len(paList)
	bResult = 1

	for i = 1 to nLen
		if NOT IsPairOfChars(paList[i])
			bResult = 0
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfPairsOfChars(paList)
		return IsListOfPairsOfChars(paList)

	func IsAListOfPairsOfChars(paList)
		return IsListOfPairsOfChars(paList)

	func @IsAListOfPaisrOfChars(paList)
		return IsListOfPairsOfChars(paList)

	#>

func IsPairOfEmptyLists(paList)
	if isList(paList) and len(paList) = 2 and
	   isList(paList[1]) and len(paList[1]) = 0 and
	   isList(paList[2]) and len(paList[2]) = 0

		return 1
	else
		return 0
	ok

	func IsAPairOfEmptyLists(paList)
		return IsPairOfEmptyLists(paList)

	func @IsPairOfEmptyLists(paList)
		return IsPairOfEmptyLists(paList)

	func @IsAPairOfEmptyLists(paList)
		return IsPairOfEmptyLists(paList)

func IsPairOf(pcType, paPair)
	if NOT ( isList(paPair) and len(paPair) = 2 )
		return 0
	ok

	return StzPairQ(paPair).IsPairOf(pcType)

	#< @FunctionAlternativeForms

	func @IsPairOf(pcType, paPair)
		return IsPairOf(pcType, paPair)

	func IsAPairOf(pcType, paPair)
		return IsPairOf(pcType, paPair)

	func @IsAPairOf(pcType, paPair)
		return IsPairOf(pcType, paPair)

	#>

func IsListOf(pcType, paList)
	if NOT isList(paList)
		return 0
	ok

	return StzListQ(paList).IsListOf(pcType)

	#< @FunctionAlternativeForms

	func @IsListOf(pcType, paList)
		return IsListOf(pcType, paList)

	func IsAListOf(pcType, paList)
		return IsListOf(pcType, paList)

	func @IsAListOf(pcType, paList)
		return IsListOf(pcType, paList)

	#>


func IsHashListOrListOfStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	return IsHashList(paList) or IsListOfStrings(paList)

	#< @FunctionAlternativeForms

	func @IsHashListOrListOfStrings(paList)
		return IsHashListOrListOfStrings(paList)

	func IsAHashListOrListOfStrings(paList)
		return IsHashListOrListOfStrings(paList)

	func @IsAHashListOrListOfStrings(paList)
		return IsHashListOrListOfStrings(paList)

	#>

func IsListOfStringsOrPairsOfStrings(paList)

	if NOT isList(paList)
		StzRaise("Incorrect param type! paList must be a list.")
	ok

	nLen = len(paList)
	if nLen = 0
		return 0
	ok

	bResult = 1

	for i = 1 to nLen
		if NOT ( isString(paList[i]) or @IsPairOfStrings(paList[i]) )
			bResult = 0
			exit
		ok
	next

	return bResult

	func @IsListOfStringsOrPairsOfStrings(paList)
		return IsListOfStringsOrPairsOfStrings(paList)

func IsListOfListsOfSameSize(paList)
	if NOT ( isList(paList) and IsListOfLists(paList) )
		return 0
	ok

	nLen = len(paList)
	anSizes = []
	for i = 1 to nLen
		nLenList = len(paList[i])
		if StzFind(anSizes, nLenList)
			return 0
		ok
	next

	return 1

	#< @FunctionAlternativeForms

	func @IsListOfListsOfSameSize(paList)
		return IsListOfListsOfSameSize(paList)

	func IsAListOfListsOfSameSize(paList)
		return IsListOfListsOfSameSize(paList)

	func @IsAListOfListsOfSameSize(paList)
		return IsListOfListsOfSameSize(paList)

	#>

func IsListInString(pcStr)
	bResult = StzStringQ(pcStr).IsListInString()
	return bResult

	func IsAListInString(pcStr)
		return IsListInString(pcStr)

	func @IsListInString(pcStr)
		return IsListInString(pcStr)

	func @IsAListInString(pcStr)
		return IsListInString(pcStr)


#===

func ListStringify(paList)
	_nLen_ = len(paList)
	_aResult_ = []
	for _i_ = 1 to _nLen_
		_aResult_ + ("" + paList[_i_])
	next
	return _aResult_

func Stringify(p)
	return Q(p).Stringified()

	func @Stringify(p)
		return Stringify(p)

	func @string(p) #TODO #WARNING // check this name!
		return Stringify(p)

#--

func ListObjectify(paList)
	return StzListQ(paList).Objectified()

func Objectify(p)
	return Q(p).Objectified()

	func @Objectify(p)
		return Objectify(p)

	func @object(p) #TODO #WARNING // check this name!
		return Objectify(p)

#===

func StzNamedList(paNamed)
	if CheckingParams()
		if NOT (isList(paNamed) and IsPairOfStringAndList(paNamed))
			StzRaise("Incorrect param type! paNamed must be a pair of string and list.")
		ok
	ok

	oList = new stzList(paNamed[2])
	oList.SetName(paNamed[1])
	return oList

	func StzNamedListQ(paNamed)
		return StzNamedList(paNamed)

	func StzNamedListXTQ(paNamed)
		return StzNamedList(paNamed)

func StzListMethods()
	return Stz(:List, :Methods)

func StzListAttributes()
	return Stz(:List, :Attributes)

func StzListClassName()
	return "stzlist"

	func StzListClass()
		return "stzlist"

func OnlyNumbers(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	nLen = len(paList)
	anResult = []

	for i = 1 to nLen
		if isNumber(paList[i])
			anResult + paList[i]
		ok
	next

	return anResult


	func @OnlyNumbers(paList)
		return OnlyNumbers(paList)

	func OnlyNumbersIn(paList)
		return OnlyNumbers(paList)

	func @OnlyNumbersIn(paList)
		return OnlyNumbers(paList)

#TODO // Add OnlyStrings() and cie...

def Flatten(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	nLen = len(paList)
	aResult = []
	aTemp = []

	for i = 1 to nLen
		if isList(paList[i])
			aTemp = Flatten(paList[i]) # A recursive call
			nLenTemp = len(aTemp)

			for j = 1 to nLenTemp
				aResult + aTemp[j]
			next
		else
			aResult + paList[i]
		ok
	next

	return aResult

	func @Flatten(paList)
		return Flatten(paList)

	func ListInverse(paList)
		return reverse(paList)

	#NOTE // we have a more general function called @Reverse()
	# that reverses strings and lists. We made it because Ring
	# standard reverse() is not UNICODE-aware.

func @Reverse(p)
	if isString(p)
		if NOT @IsPalindrome(p)
			p = StzStringQ(p).Reversed()
		ok

		return p

	but isList(p)

		if NOT isPalindrom(p)
			oTemp = new stzList(p)
			p = oTemp.Reversed()
		ok

		return p
		
	else
		StzRaise("Incorrect param type! p must be a string or list.")
	ok

func ListFirstItem(paList)
	return paList[1]

	#< @AlternativeFunctionNames

	func FirstItem(paList)
		return ListFirstItem(paList)

	func FirstItemIn(paList)
		return ListFirstItem(paList)

	func FirstItemInList(paList)
		return ListFirstItem(paList)

	#---

	func @FirstItem(paList)
		return ListFirstItem(paList)

	func @FirstItemIn(paList)
		return ListFirstItem(paList)

	func @FirstItemInList(paList)
		return ListFirstItem(paList)

	#>

func ListLastItem(paList)
	return paList[ len(paList) ]

	#< @AlternativeFunctionNames

	func LastItem(paList)
		return ListLastItem(paList)

	func LastItemIn(paList)
		return ListLastItem(paList)

	func LastItemInList(paList)
		return ListLastItem(paList)

	#---

	func @LastItem(paList)
		return ListLastItem(paList)

	func @LastItemIn(paList)
		return ListLastItem(paList)

	func @LastItemInList(paList)
		return ListLastItem(paList)

	#>

func UpdateLastItem(paList, pValue)
	oTempList = new stzList(paList)
	return oTempList.UpdateLastItem(pValue)

func FirstListIn(paList)
	oTempList = new stzList(paList)
	return LastItemIn( oTempList.WalkUntilItemIsList() )

func GenerateListAccessCode_FromNameAndPath(pcListName, paPath)
	// Warining: aPath must contain only numbers!!!
	cCode = pcListName
	_nPath1Len_ = len(paPath)
	for _iLoopPath1_ = 1 to _nPath1Len_
		n = paPath[_iLoopPath1_]
		cCode += ("["+ n + ']')
	next

	return cCode

func ListItemsAreAllStrings(paList)
	oTempList = new stzList(paList)
	return oTempList.ItemsAreAllStrings()

	func ItemsAreAllStrings(paList)
		return ListItemsAreAllStrings()

	func @ItemsAreAllStrings(paList)
		return ListItemsAreAllStrings()

	func AllItemsAreStrings(paList)
		return ListItemsAreAllStrings(paList)

	func @AllItemsAreStrings(paList)
		return ListItemsAreAllStrings(paList)

func IsLocaleList(paList)
	# Was `return IsLocaleList(paList)` -- infinite recursion (R4
	# Stack Overflow at depth 997). Real impl: a locale list is a
	# hashlist with at least one of :Language, :Script, :Country.
	if NOT (isList(paList) and IsHashList(paList))
		return 0
	ok
	if HasKey(paList, :Language) or
	   HasKey(paList, :Script)   or
	   HasKey(paList, :Country)
		return 1
	ok
	return 0

	func @IsLocaleList(paList)
		# Was `return This.IsLocaleList(...)` -- `This.` doesn't work
		# inside a global func. Just forward to the func.
		return IsLocaleList(paList)

#===

# Calling a given method on many objects and get their output in a list

func CallMethod( pcMethod, paOnObjects )

	if NOT ( paOnObjects[1] = "on" and IsListOfStrings(paOnObjects[2]) )
		StzRaise(stzObjectError(:CanNotProcessMethodCall))
	ok

	aResult = []
	_aOnObjects21_ = paOnObjects[2]
	_nOnObjects21Len_ = len(_aOnObjects21_)
	for _iLoopOnObjects21_ = 1 to _nOnObjects21Len_
		cObjName = _aOnObjects21_[_iLoopOnObjects21_]
		cCode = "aResult + " + cObjName + "." + pcMethod
		eval(cCode)
	next
	return aResult

#====

func AreBothEqualCS(p1, p2, pCaseSensitive)

	if NOT type(p1) = type(p2)
		return 0
	ok

	if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
		pCaseSensitive = pCaseSensitive[2]
	ok

	if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
		StzRaise("Incorrect param! pCaseSensitive must be 1 or FALSE.")
	ok

	if isNumber(p1)
		return p1 = p2

	but isString(p1)

		if pCaseSensitive = 0
			p1 = StzLower(p1)
			p2 = StzLower(p2)
		ok

		return p1 = p2

	else
		return Q(p1).IsEqualToCS(p2, pCaseSensitive)
	ok

	#< @FunctionAlternativeForms

	func BothAreEqualCS(p1, p2, pCaseSensitive)
		return AreBothEqualCS(p1, p2, pCaseSensitive)

	func @AreBothEqualCS(p1, p2, pCaseSensitive)
		return AreBothEqualCS(p1, p2, pCaseSensitive)

	func @BothAreEqualCS(p1, p2, pCaseSensitive)
		return AreBothEqualCS(p1, p2, pCaseSensitive)

	#>

	#< @FunctionNegativeForms

	func BothAreNotEqualCS(p1, p2, pCaseSensitive)
		return NOT AreBothEqualCS(p1, p2, pCaseSensitive)

	func @AreNotBothEqualCS(p1, p2, pCaseSensitive)
		return BothAreNotEqualCS(p1, p2, pCaseSensitive)

	func @BothAreNotEqualCS(p1, p2, pCaseSensitive)
		return BothAreNotEqualCS(p1, p2, pCaseSensitive)

	#>

#-- WITHOUT CASESENSITIVITY

func AreBothEqual(p1, p2)
	return AreBothEqualCS(p1, p2, 1)

	#< @FunctionAlternativeForms

	func BothAreEqual(p1, p2)
		return AreBothEqual(p1, p2)

	func @AreBothEqual(p1, p2)
		return AreBothEqual(p1, p2)

	func @BothAreEqual(p1, p2)
		return AreBothEqual(p1, p2)

	#>

	#< @FunctionNegativeForms

	func BothAreNotEqual(p1, p2)
		return NOT AreBothEqual(p1, p2)

	func @AreNotBothEqual(p1, p2)
		return BothAreNotEqual(p1, p2)

	func @BothAreNotEqual(p1, p2)
		return BothAreNotEqual(p1, p2)

	#>


#===

func AreEqualCS(paValues, pCaseSensitive)
	if NOT isList(paValues)
		StzRaise("Incorrect param type! paValues must be a list.")
	ok

	# Check if all items are equal (inline without allocation)
	nLen = len(paValues)
	if nLen < 2
		return 1
	ok

	bCaseSensitive = CaseSensitive(pCaseSensitive)
	for _k = 2 to nLen
		if bCaseSensitive
			if NOT BothAreEqual(paValues[1], paValues[_k])
				return 0
			ok
		else
			if NOT BothAreEqualCS(paValues[1], paValues[_k], 0)
				return 0
			ok
		ok
	next
	return 1

	#NOTE //~> I left the old code commented so you can see
	# how mutch Softanza can optimise the codebase
	# at each refactoring

	/*--- START OF OLD UNUSED CODE

	if NOT isList(paValues)
		return 0
	ok

	if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
		pCaseSensitive = pCaseSensitive[2]
	ok

	if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
		StzRaise("Incorrect param! pCaseSensitive must be 1 or FALSE.")
	ok

	# Early checks

	nLen = len(paValues)
	if nLen = 0
		return 0
	but nLen = 1
		return 1
	ok

	# Doing the job

	bResult = 1

	if IsNumber(paValues[1])

		for i = 2 to nLen
			if paValues[i] != paValues[1]
				bResult = 0
				exit
			ok
		next

		return bResult

	but isString(paValues[1])
		if pCaseSensitive = 0
			for i = 1 to nLen
				paValues[i] = StzLower(paValues[i])
			next
		ok

		for i = 2 to nLen
			if paValues[i] != paValues[1]
				bResult = 0
				exit
			ok
		next

		return bResult

	but isObject(paValues[1])
		return @AreEqualObjects(paValues)

	else

		for i = 2 to nLen

			if NOT Q(paValues[i]).IsEqualToCS(paValues[1], pCaseSensitive)
				bResult = 0
				exit
			ok
		next

		return bResult

	ok

	--- END OF OLD UNUSED CODE
	*/

	#< @FunctionAlternativeForms

	func @AreEqualCS(paValues, pCaseSensitive)
		return AreEqualCS(paValues, pCaseSensitive)

	func AreAllEqualCS(paValues, pCaseSensitive)
		return AreEqualCS(paValues, pCaseSensitive)

	func @AreAllEqualCS(paValues, pCaseSensitive)
		return AreEqualCS(paValues, pCaseSensitive)

	func AllAreEqualCS(paValues, pCaseSensitive)
		return AreEqualCS(paValues, pCaseSensitive)

	func @AllAreEqualCS(paValues, pCaseSensitive)
		return AreEqualCS(paValues, pCaseSensitive)

	#>

	#< @FunctionNegativeForms

	func AreNotEqualCS(paValues, pCaseSensitive)
		return NOT AreEqualCS(paValues, pCaseSensitive)

	func @AreNotEqualCS(paValues, pCaseSensitive)
		return AreNotEqualCS(paValues, pCaseSensitive)

	func AreNotAllEqualCS(paValues, pCaseSensitive)
		return NOT AreEqualCS(paValues, pCaseSensitive)

	func @AreNotAllEqualCS(paValues, pCaseSensitive)
		return AreNotEqualCS(paValues, pCaseSensitive)

	func AllAreNotEqualCS(paValues, pCaseSensitive)
		return NOT AreEqualCS(paValues, pCaseSensitive)

	func @AllAreNotEqualCS(paValues, pCaseSensitive)
		return AreNotEqualCS(paValues, pCaseSensitive)

	#>

#-- WITHOUT CASESENSITIVITY

func AreEqual(paValues)
	return AreEqualCS(paValues, 1)

	#< @FunctionAlternativeForm

	func @AreEqual(paValues)
		return AreEqual(paValues)

	func AreAllEqual(paValues)
		return AreEqual(paValues)

	func @AreAllEqual(paValues)
		return AreEqual(paValues)

	func AllAreEqual(paValues)
		return AreEqual(paValues)

	func @AllAreEqual(paValues)
		return AreEqualCS(paValues)

	#>

	#< @FunctionNegativeForms

	func AreNotEqual(paValues)
		return NOT AreEqual(paValues)

	func @AreNotEqual(paValues)
		return AreNotEqual(paValues)

	func AreNotAllEqual(paValues)
		return AreNotEqual(paValues)

	func @AreNotAllEqual(paValues, pCaseSensitive)
		return AreNotEqual(paValues)

	func AllAreNotEqual(paValues, pCaseSensitive)
		return AreNotEqual(paValues)

	func @AllAreNotEqual(paValues, pCaseSensitive)
		return AreNotEqual(paValues)

	#>

#===

func HaveSameType(paItems)
	if NOT isList(paItems)
		StzRaise("Incorrect param type! paItems must be a list.")
	ok

	nLen = len(paItems)
	if nLen = 0
		return 0
	but nLen = 1
		return 1
	ok

	# Case nLen >= 2

	bResult = 1
	for i = 2 to nLen
		if ring_type( paItems[1] ) != ring_type( paItems[i] )
			bResult = 0
			exit
		ok
	next
	return bResult

	func @HaveSameType(paItems)
		return HaveSameType(paItems)

	func AllHaveSameType(paItems)
		return HaveSameType(paItems)

	func @AllHaveSameType(paItems)
		return HaveSameType(paItems)

func BothHaveSameType(p1, p2)
	return ring_type(p1) = ring_type(p2)

func HaveSameContent(paItems)
	/* Two items have same content when:
	 if they are stringified they are equal strings.

	Stringifying number 12 generate string "12"
	*/
	if NOT isList(paItems)
		StzRaise("Incorrect param type! paItems must be a list.")
	ok

	if len(paItems) = 1
		return 1
	ok

	bResult = 1
	_nItemsLen_ = len(paItems)
	for i = 2 to _nItemsLen_
		bOk = Q( @@( paItems[i] ) ).IsEqualTo( @@( paItems[1] ) )
		if NOT bOk
			bResult = 0
			exit
		ok
	next
	return bResult

	func @HaveSameContent(paItems)
		return HaveSameContent(paItems)

func HaveBothSameType(p1, p2)
	return ring_type(p1) = ring_type(p2)

	func @HaveBothSameType(p1, p2)
		return HaveBothSameType(p1, p2)

func IsEmptyList(paList)
	return isList(paList) and len(paList) = 0
		
	func IsAnEmptyList(paList)
		return IsEmptyList(paList)

	func @IsEmptyList(paList)
		return IsEmptyList(paList)

	func @IsAnEmptyList(paList)
		return IsEmptyList(paList)

#===

func ListShow(paList)
	StzListQ(paList).Show()

func AreNumbers(paList)
	nLen = len(paList)
	for i = 1 to nLen
		if NOT isNumber(paList[i])
			return 0
		ok
	next
	return 1

	#< @FunctionAlternativeForms

	func AllAreNumbers(paList)
		return AreNumbers(paList)

	func AreAllNumbers(paList)
		return AreNumbers(paList)

	func TheseAreNumbers(paList)
		return AreNumbers(paList)

	func AllTheseAreNumbers(paList)
		return AreNumbers(paList)

	func IsMadeOfNumbers(paList)
		return AreNumbers(paList)

	func IsMadeOfOnlyNumbers(paList)
		return AreNumbers(paList)

	func IsMadeOfJustNumbers(paList)
		return AreNumbers(paList)

	func ContainsOnlyNumbers(paList)
		return AreNumbers(paList)

	func ContainsJustNumbers(paList)
		return AreNumbers(paList)

	#--

	func @AreNumbers(paList)
		return AreNumbers(paList)

	func @AllAreNumbers(paList)
		return AreNumbers(paList)

	func @AreAllNumbers(paList)
		return AreNumbers(paList)

	func @IsMadeOfNumbers(paList)
		return AreNumbers(paList)

	func @IsMadeOfOnlyNumbers(paList)
		return AreNumbers(paList)

	func @IsMadeOfJustNumbers(paList)
		return AreNumbers(paList)

	func @ContainsOnlyNumbers(paList)
		return AreNumbers(paList)

	func @ContainsJustNumbers(paList)
		return AreNumbers(paList)

	#TODO : Add these alternatives to other similar functions
	#>

func AreStrings(paList)
	nLen = len(paList)
	for i = 1 to nLen
		if NOT isString(paList[i])
			return 0
		ok
	next
	return 1

	#< @FuncctionAlternativeForms

	func AllAreStrings(paList)
		return AreStrings(paList)

	func AreAllStrings(paList)
		return AreStrings(paList)

	func TheseAreStrings(paList)
		return AreStrings(paList)

	func AllTheseAreStrings(paList)
		return AreStrings(paList)

	#--

	func @AreStrings(paList)
		return AreStrings(paList)

	func @AllAreStrings(paList)
		return AreStrings(paList)

	func @AreAllStrings(paList)
		return AreStrings(paList)

	#>

func AreLists(paList)
	nLen = len(paList)
	for i = 1 to nLen
		if NOT isList(paList[i])
			return 0
		ok
	next
	return 1

	#< @FunctionAlternativeForms

	func AllAreLists(paList)
		return AreLists(paList)

	func AreAllLists(paList)
		return AreLists(paList)

	func TheseAreLists(paList)
		return AreLists(paList)

	#--

	func @AreLists(paList)
		return AreLists(paList)

	func @AllAreLists(paList)
		return AreLists(paList)

	func @AreAllLists(paList)
		return AreLists(paList)

	#>

func AreObjects(paList)
	nLen = len(paList)
	for i = 1 to nLen
		if NOT isObject(paList[i])
			return 0
		ok
	next
	return 1

	#< @FunctionAlternativeForms

	func AllAreObjects(paList)
		return AreObjects(paList)

	func AreAllObjects(paList)
		return AreObjects(paList)

	func TheseAreObjects(paList)
		return AreObjects(paList)

	#--

	func @AreObjects(paList)
		return AreObjects(paList)

	func @AllAreObjects(paList)
		return AreObjects(paList)

	func @AreAllObjects(paList)
		return AreObjects(paList)

	#>

	# NOTE: IsRangeNamedParamList is defined in stznamedparams_engine.ring
	# The duplicate was removed to avoid Ring's redefinition error.

	func @IsRangeNamedParamList(paList)
		return IsRangeNamedParamList(paList)

func ListToCode(paList)
	return @@(paList)


func AllTheseAreNull(paList)
	nLen = len(paList)
	for i = 1 to nLen
		if NOT isNull(paList[i])
			return 0
		ok
	next
	return 1

	func AllOfTheseAreNull(paList)
		return AllTheseAreNull(paList)

	func TheseAreNull(paList)
		return AllTheseAreNull(paList)

	#--

	func @AllTheseAreNull(paList)
		return AllTheseAreNull(paList)

	func @AllOfTheseAreNull(paList)
		return AllTheseAreNull(paList)

	func @TheseAreNull(paList)
		return AllTheseAreNull(paList)

func AllOfTheseAreNotNull(paList)
	bResult = 1
	_nList2Len_ = len(paList)
	for _iLoopList2_ = 1 to _nList2Len_
		item = paList[_iLoopList2_]
		if isString(item) and isNull(item)
			bResult = 0
			exit
		ok
	next

	return bResult

	func NoOneOfTheseIsNull(paList)
		return AllOfTheseAreNotNull(paList)

	func TheseAreNotNull(paList)
		return AllOfTheseAreNotNull(paList)

	#--

	func @AllOfTheseAreNotNull(paList)
		return AllOfTheseAreNotNull(paList)

	func @NoOneOfTheseIsNull(paList)
		return AllOfTheseAreNotNull(paList)

	func @TheseAreNotNull(paList)
		return AllOfTheseAreNotNull(paList)

func BothAreNull(p1, p2)
	return TheseAreNull([ p1, p2 ])

	func @BothAreNull(p1, p2)
		return BothAreNull(p1, p2)

func BothAreNotNull(p1, p2)
	return TheseAreNotNull([ p1, p2 ])

	func @BothAreNotNull(p1, p2)
		return BothAreNotNull(p1, p2)

func NoOneOfTheseIsAString(paList)
	bResult = 1
	_nList1Len_ = len(paList)
	for _iLoopList1_ = 1 to _nList1Len_
		item = paList[_iLoopList1_]
		if isString(item)
			bResult = 0
			exit
		ok
	next
	
	return bResult

	func @NoOneOfTheseIsAString(paList)
		return NoOneOfTheseIsAString(paList)

func List@(paList)
	if isList(paList)
		return ComputableForm(paList)
	ok

func ListFindAll(paList, p)
	aResult = []
	nLen = len(paList)
	for i = 1 to nLen
		if BothAreEqual(paList[i], p)
			aResult + i
		ok
	next
	return aResult

func ListOfNTimes(n, pItem)
	aResult = []
	for i = 1 to n
		aResult + pItem
	next
	return aResult

#--

func WithoutDuplication(paList)
	return UCS(paList, 1)

	func @WithoutDuplication(paList)
		return WithoutDuplication(paList)

	#-- @Misspelled (two p instead of one)

	func WithoutDupplication(paList)
		return WithoutDuplication(paList)

	func @WithoutDupplication(paList)
		return WithoutDuplication(paList)

func StringsIn(paList)
	if CheckingParams()
		if NOT IsList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	nLen = len(paList)
	aResult = []

	for i = 1 to nLen
		if isString(paList[i])
			aResult + palist[i]
		ok
	next

	return aResult

	#< @FunctionAlternativeForm

	func @StringsIn(paList)
		return Strings(paList)

	#>

func ListsIn(paList)
	if CheckingParams()
		if NOT IsList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	nLen = len(paList)
	aResult = []

	for i = 1 to nLen
		if isList(paList[i])
			aResult + palist[i]
		ok
	next

	return aResult

	#< @FunctionAlternativeForm

	func @ListsIn(paList)
		return Lists(paList)

	#>

func ObjectsIn(paList)
	if CheckingParams()
		if NOT IsList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	nLen = len(paList)
	aResult = []

	for i = 1 to nLen
		if isObject(paList[i])
			aResult + palist[i]
		ok
	next

	return aResult

	#< @FunctionAlternativeForms

	func @ObjectsIn(paList)
		return Objects(paList)

	#>

#===

func ListContainsCS(paList, pItem, pCaseSensitive)
	nPos = @FindFirstCS(paList, pItem, pCaseSensitive)
	if nPos > 0
		return 1
	else
		return 0
	ok

	func @ListContainsCS(paList, pItem, pCaseSensitive)
		return ListContainsCS(paList, pItem, pCaseSensitive)

#--

func ListContainsOneOfTheseCS(paList, paItems, pCaseSensitive)
	nLen = len(paItems)
	bResult = FALSE

	for i = 1 to nLen
		if ListContainsCS(paList, paItems[i])
			bResult = TRUE
			exit
		ok
	next

	return bResult

	func @ListContainsOneOfTheseCS(paList, paItems, pCaseSensitive)
		return ListContainsOneOfTheseCS(paList, paItems, pCaseSensitive)

func ListContainsOneOfThese(paList, paItems)
	return ListContainsOneOfTheseCS(paList, paItems, 1)

	func @ListContainsOneOfThese(paList, paItems)
		return SListContainsOneOfThese(paList, paItems)

#===

func ListCountCS(aList, pItem, pCaseSensitive)
	nResult = StzListQ(aList).FindAllCS(aList, pItem, pCaseSensitive)

func ListCount(aList, pItem)
	return ListCountCS(aList, pItem, pCaseSensitive)


#=== Enhance Ring+Softanza finding functions #todo #narration

#NOTE
# ~> These functions are based on Ring native find() function.
# ~> They can deal only with finding numbers or strings.
# ~> They are used used internally by stzList finding functions

# When searching for elements in a list, always start by
# checking if you can use these global @Find...() functions
# before using an stzList object.

# These functions can be used when the items youâ€™re looking for
# are either numbers or lists. Otherwise, the use of stzList is necessary.

# The option for the right approach can lead to significant performance gains.
# ~> See example in stzListTest.ring file

#WARNING Very important! Read the warning in @FindNthOccurrenceCS() function

func @FindAllCS_NbrOrStr(paList, pItem, pCaseSensitive)

	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		if NOT (isString(pItem) or isNumber(pItem))
			return -1
		ok

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			stzRaise("Incorrect param type! pCaseSensitive must be a boolean (1 or 0).")
		ok
	ok

	_aList_ = paList
	_nLen_ = len(_aList_)

	if _nLen_ = 0
		return []
	ok

	_item_ = pItem

	if pCaseSensitive = 0 
		if isString(_item_)
			pItem = StzLower(_item_)
		ok

		_aList_ = ListLowercased(_aList_)
	ok

	#TODO #IMPORTANT // protect all local variables that are modified
	# by any Softanza function or method, by enclosing them between
	# two _s, like in _nPos_ in the fellowing code.

	#~> // That's because when the calling Ring programm has also a
	# gloabl variable of the same name, this will be accidently
	# modified by the local Softanza code, and the user won't understand why!

	_anResult_ = []
	_nPos_ = -1

	while 1

		# Trying to find the item using Ring find()

		try
			_nPos_ = find(_aList_, _item_)

		catch
			return -1
		done

		if _nPos_ = 0
			exit
		ok

		_anResult_ + _nPos_

		# A touch of magic: to allow Ring's find() method
		# in the try block above to continue searching
		# through the remaining part of the list, we modify
		# the item at the position it just found to ensure
		# it is skipped.
		
		_aList_[ _nPos_ ] += (""+ _aList_[ _nPos_ ] + 1)
	end

	return _anResult_


func @FindAll_NbrOrStr(aList, pItem)
	return @FindAllCS_NbrOrStr(aList, pItem, 1)


#---

func @FindFirstCS(aList, pStrOrNbr, pCaseSensitive)
	nResult = @FindNthSTCS(aList, 1, pStrOrNbr, 1, pCaseSensitive)
	return nResult

	#< @FunctionAlternativeForms

	func FindFirstCS(aList, pStrOrNbr, pCaseSensitive)
		return @FindFirstCS(aList, pStrOrNbr, pCaseSensitive)

	#>

func @FindFirst(aList, pStrOrNbr)
	return @FindFirstCS(aList, pStrOrNbr, 1)

	#< @FunctionAlternativeForms

	func FindFirst(aList, pStrOrNbr)
		return @FindFirst(aList, pStrOrNbr)


	#>

#--

func @FindLastCS(aList, pStrOrNbr, pCaseSensitive)
	nResult = len(aList) - @FindFirstCS( reverse(aList), pStrOrNbr, pCaseSensitive) + 1
	return nResult

	#< @FunctionAlternativeForms

	func FindLastCS(aList, pStrOrNbr, pCaseSensitive)
		return @FindLastCS(aList, pStrOrNbr, pCaseSensitive)

	#>

func @FindLast(aList, pStrOrNbr)
	return @FindLastCS(aList, pStrOrNbr, 1)

	#< @FunctionAlternativeForms

	func FindLast(aList, pStrOrNbr)
		return @FindLast(aList, pStrOrNbr)

	#>

#--

func @FindNthOccurrenceCS(paList, nth, pItem, pCaseSensitive)

	#WARNING // Be careful! When using this function inside a stzList object,
	# dont' send directly the content of the object like this:

	#    @FindNthOccurrence(This.Content(), ...; ...)

	# because the content of the object can be modified by this function.

	# Instead of that you should protect the content by taking a copy first
	# and then sendÙ‡ng it to this function, like this:

	#    aTempContent = This.Content()
	#    @FindNthOccurrence(TaTempContent, ...; ...)

	# Same thing applies to simular functions in this section!

	#UPDATE // This should not be the case! This function itself should
	# be safe and work on a copy of the paList sent, and paList itself.
	#~> DONE
	# So we should not care anymore.

	#TODO // Check that all the global functions in the library are safe
	# and never alter the values of their params!

	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		if NOT isNumber(nth)
			StzRaise("Incorrect param type! nth must be a number.")
		ok

		if NOT (isString(pItem) or isNumber(pItem))
			return -1
		ok

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			stzRaise("Incorrect param type! pCaseSensitive must be a boolean (1 or 0).")
		ok
	ok

	if pCaseSensitive = 0 

		if isString(pItem)
			pItem = StzLower(pItem)
		ok

		paList = ListLowercased(paList)

	ok

	_aListCopy_ = paList

	nLen = len(_aListCopy_)
	nPos = -1
	n = 0

	while 1
		try
			nPos = find(_aListCopy_, pItem)
		catch
			return -1
		done

		if nPos = 0
			return 0
		ok

		n++
		if n = nth
			exit
		ok

		_aListCopy_[nPos] += (""+ _aListCopy_[nPos]+1)
		
	end

	return nPos


	func @FindNthCS(aList, nth, pItem, pCaseSensitive)
		return @FindNthOccurrenceCS(aList, nth, pItem, pCaseSensitive)

func @FindNthOccurrence(aList, nth, pItem)
	return @FindNthOccurrenceCS(aList, nth, pItem, 1)

	func @FindNth(aList, nth, pItem)
		return @FindNthOccurrence(aList, nth, pItem)

#--

func @FindNthSTCS(aList, nth, pItem, nStart, pCaseSensitive)

	if CheckingParams()
		if NOT isList(aList)
			StzRaise("Incorrect param type! aList must be a list.")
		ok

		if NOT isNumber(nth)
			StzRaise("Incorrect param type! nth must be a number.")
		ok

		if NOT (isString(pItem) or isNumber(pItem))
			return -1
		ok

		if isList(nStart) and IsStartingAtNamedParamList(nStart)
			nStart = nStart[2]
		ok

		if NOT isNumber(nStart)
			StzRaise("Incorrect param type! nStart must be a number.")
		ok

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( isNumber(pCaseSensitive) and (pCaseSensitive = 0 or pCaseSensitive = 1) )
			stzRaise("Incorrect param type! pCaseSensitive must be a boolean (1 or 0).")
		ok
	ok

	if pCaseSensitive = 0 
		if isString(pItem)
			pItem = StzLower(pItem)
		ok

		aList = ListLowercased(aList)
	ok

	nLen = len(aList)
	aContent = []

	for i = nStart to nLen
		aContent + aList[i]
	next

	nPos = -1
	n = 0

	while 1
		try
			nPos = find(aContent, pItem)
		catch
			return -1
		done

		if nPos = 0
			exit
		ok

		n++
		if n = nth
			exit
		ok

		aContent[nPos] += (""+ aContent[nPos]+1)
		
	end

	nResult = 0

	if nPos > 0

		nResult = nPos + nStart - 1
	ok

	return nResult

	#< @FunctionAlternativeForms

	func FindNthSTCS(aList, nth, pItem, nStart, pCaseSensitive)
		return @FindNthSTCS(aList, nth, pItem, nStart, pCaseSensitive)

	func FindNthStartingAtCS(aList, nth, pItem, nStart, pCaseSensitive)
		return @FindNthSTCS(aList, nth, pItem, nStart, pCaseSensitive)

	func @FindNthStartingAtCS(aList, nth, pItem, nStart, pCaseSensitive)
		return @FindNthSTCS(aList, nth, pItem, nStart, pCaseSensitive)

	#--

	func FindNthCS(aList, nth, pItem, nStart, pCaseSensitive)
		return @FindNthSTCS(aList, nth, pItem, nStart, pCaseSensitive)

	#>

#-- CS

func @FindNthST(aList, nth, pItem, nStart)
	return @FindNthSTCS(aList, nth, pItem, nStart, 1)

	#< @FunctionAlternativeForms

	func FindNthST(aList, nth, pItem, nStart)
		return @FindNthST(aList, nth, pItem, nStart)

	func FindNthStartingAt(aList, nth, pItem, nStart)
		return @FindNthST(aList, nth, pItem, nStart)

	func @FindNthStartingAt(aList, nth, pItem, nStart)
		return @FindNthST(aList, nth, pItem, nStart)

	#--

	func FindNth(aList, nth, pItem, nStart)
		return @FindNthST(aList, nth, pItem, nStart)

	#>

#===

func FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	if CheckingParams() = 1
		if isList(nStart) and IsStartingAtNamedParamList(nStart)
			nStart = nStart[2]
		ok
	ok

	return @FindNthSTCS(aList, nth, pItem, nStart+1, pCaseSensitive)

	#< @FunctionAlternativeForms

	def FindNextNthCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	def @FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	def @FindNextNthCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	func @FindNthNextSTCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	func @FindNextNthSTCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	func FindNextNthSTCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	func FindNthNextSTCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	func FindNthNextStartingAtCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	func FindNextNthStartingAtCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	func @FindNextNthStartingAtCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	func @FindNthNextStartingAtCS(aList, nth, pItem, nStart, pCaseSensitive)
		return FindNthNextCS(aList, nth, pItem, nStart, pCaseSensitive)

	#>

#-- CS

func FindNthNext(aList, nth, pItem, nStart)
	return FindNthNextCS(aList, nth, pItem, nStart, 1)

	#< @FunctionAlternativeForms

	def FindNextNth(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	def @FindNthNext(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	def @FindNextNth(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	func @FindNthNextST(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	func @FindNextNthST(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	func FindNextNthST(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	func FindNthNextST(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	func FindNthNextStartingAt(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	func FindNextNthStartingAt(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	func @FindNextNthStartingAt(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	func @FindNthNextStartingAt(aList, nth, pItem, nStart)
		return FindNthNext(aList, nth, pItem, nStart)

	#>

#==

func @FindNextCS(aList, pItem, nStart, pCaseSensitive)
	return @FindNthNextSTCS(aList, 1, pItem, nStart, pCaseSensitive)

	func FindNextCS(aList, pItem, nStart, pCaseSensitive)
		return @FindNextCS(aList, pItem, nStart, pCaseSensitive)

	func FindNextSTCS(aList, pItem, nStart, pCaseSensitive)
		return @FindNextCS(aList, pItem, nStart, pCaseSensitive)

	func @FindNextSTCS(aList, pItem, nStart, pCaseSensitive)
		return @FindNextCS(aList, pItem, nStart, pCaseSensitive)

func @FindNext(aList, pItem, nStart)
	return @FindNextCS(aList, pItem, nStart, 1)

	func FindNext(aList, pItem, nStart)
		return @FindNext(aList, pItem, nStart)

	func FindNextST(aList, pItem, nStart)
		return @FindNext(aList, pItem, nStart)

	func @FindNextST(aList, pItem, nStart)
		return @FindNext(aList, pItem, nStart)

# Renders a stringified list-class key ("[ 1, 2, 3, 4, 5 ]") into its
# contiguous short form ("1:5") when the items are consecutive integers;
# otherwise returns the key unchanged. Used by ClassesSF / ClassifySF.

func _StzListKeyToShortForm(pcKey)
	cSf = ring_trim(pcKey)
	if ring_left(cSf, 1) = "[" and ring_right(cSf, 1) = "]"
		cSf = ring_trim(StzMid(cSf, 2, len(cSf) - 2))
	ok
	if cSf = ""
		return pcKey
	ok
	aSfParts = StzSplit(cSf, ",")
	nSfN = len(aSfParts)
	aSfNums = []
	for iSf = 1 to nSfN
		cSfP = ring_trim(aSfParts[iSf])
		if NOT isNumber(0 + cSfP)
			return pcKey
		ok
		aSfNums + (0 + cSfP)
	next
	if nSfN < 2
		return pcKey
	ok
	bSfContig = 1
	for iSf = 2 to nSfN
		if aSfNums[iSf] != aSfNums[iSf - 1] + 1
			bSfContig = 0
			exit
		ok
	next
	if bSfContig
		return "" + aSfNums[1] + ":" + aSfNums[nSfN]
	ok
	return pcKey

# Collects every list-valued item at any depth, in depth-first pre-order.
# Ring objects are excluded naturally: isList() is false for an object.

func _StzCollectDeepLists(paList)
	aCdlRes = []
	nCdlLen = len(paList)
	for iCdl = 1 to nCdlLen
		if isList(paList[iCdl])
			aCdlRes + paList[iCdl]
			aCdlSub = _StzCollectDeepLists(paList[iCdl])
			nCdlSub = len(aCdlSub)
			for jCdl = 1 to nCdlSub
				aCdlRes + aCdlSub[jCdl]
			next
		ok
	next
	return aCdlRes

# Functions used internally with DeepFind method

func FindNumberOrStringInNestedList(pNbrOrStr, paList) #ai #claude #chat-gpt

    if CheckParams()
        if NOT ( isNumber(pNbrOrStr) or isString(pNbrOrStr) )
            StzRaise("Incorrect param type! pNbrOrStr must be a number or string.")
        ok

        if NOT isList(paList)
            StzRaise("Incorrect param type! paList must be a list.")
        ok
    ok

    _nLen_ = len(paList)
    _aPositions_ = []
    _nRootPos_ = 1

    for @i = 1 to _nLen_

        if isNumber(paList[@i]) or isString(paList[@i])
            if paList[@i] = pNbrOrStr
                _aPositions_ + [ _nRootPos_ ]
            ok

        but isList(paList[@i])

            _aSubPositions_ = FindNumberOrStringInNestedList(pNbrOrStr, paList[@i])
            _nLenPos_ = len(_aSubPositions_)

            # Process nested positions

            for @j = 1 to _nLenPos_
                if isList(_aSubPositions_[@j])
                    _aNewPath_ = [ _nRootPos_ ]
                    _nLenNewPath_ = len(_aSubPositions_[@j])

                    for @k = 1 to _nLenNewPath_
                        _aNewPath_ + _aSubPositions_[@j][@k]
                    next

                    _aPositions_ + _aNewPath_
                else
                    _aPositions_ + [ _nRootPos_, _aSubPositions_[@j] ]
                ok
            next
        ok

        _nRootPos_++

    next

    return _aPositions_

func FindStrListInNestedStrList(pcItemProvidedAsStr, pcListProvidedAsStr) #ai #claude
	if CheckParams()
		if NOT ( isString(pcItemProvidedAsStr) and isString(pcItemProvidedAsStr) )
			StzRaise("Incorrect param type! pcItemProvidedAsStr and pcItemProvidedAsStr must both be strings.")
		ok
	ok

	_aPositions_ = []
	_nLenItemProvidedAsStr_ = stzlen(pcItemProvidedAsStr)
	_nLenListProvidedAsStr_ = stzlen(pcListProvidedAsStr)

	# Main parsing loop

	_nRootPos_ = 1  # Track position at current depth
	_nCurrentIndex_ = 1
    
	while _nCurrentIndex_ <= _nLenListProvidedAsStr_

		# Check for direct match at current position

		if ExistsAt(pcItemProvidedAsStr, pcListProvidedAsStr, _nCurrentIndex_)

			_aPositions_ + [ _nRootPos_ ]  # Simply add current position
			_nCurrentIndex_ += _nLenItemProvidedAsStr_

		else
			# Check for nested lists

			if StzReplace(pcListProvidedAsStr, _nCurrentIndex_, 1) = "["

				_nSubEndPos_ = FindMatchingBracket(pcListProvidedAsStr, _nCurrentIndex_)

				if _nSubEndPos_ > _nCurrentIndex_ + 1

					_cSubStr_ = StzReplace( pcListProvidedAsStr, (_nCurrentIndex_ + 1), (_nSubEndPos_ - _nCurrentIndex_ - 1) )
					_aSubPositions_ = FindStrListInNestedStrList(pcItemProvidedAsStr, _cSubStr_)

					_nLenSubPos_ = len(_aSubPositions_)

					# Only handle nesting for non-root positions

					if _nRootPos_ != 1

						for @i = 1 to _nLenSubPos_

							if isList(_aSubPositions_[@i])

								_aNewPath_ = [ _nRootPos_ ]
								_nLenInnerSubPos_ = len(_aSubPositions_[@i])

								for @j = 1 to _nLenInnerSubPos_
									_aNewPath_ + _aSubPositions_[@i][@j]
								next

								_aPositions_ + _aNewPath_

							else
								_aPositions_ + [ _nRootPos_, _aSubPositions_[@i] ]
							ok
						next

					else
						# At root level, add positions as-is

						for @i = 1 to _nLenSubPos_
							_aPositions_ + _aSubPositions_[@i]
						next
					ok
				ok

				_nCurrentIndex_ = _nSubEndPos_

			ok

			_nCurrentIndex_++
		ok
        
		# Move to next item at current level

		if _nCurrentIndex_ <= _nLenListProvidedAsStr_ and 
		   StzReplace(pcListProvidedAsStr, _nCurrentIndex_, 1) = ","

			_nRootPos_++
			_nCurrentIndex_++
		ok

	end
    
	return _aPositions_

	func FindMatchingBracket(cStr, nStartPos)

		_nOpenCount_ = 1
		@i = nStartPos + 1
		_nLenStr_ = stzlen(cStr)
	
		while @i <= _nLenStr_

			if StzReplace(cStr, @i, 1) = "["
				_nOpenCount_++

			but StzReplace(cStr, @i, 1) = "]"

				_nOpenCount_--

				if _nOpenCount_ = 0
					return @i
				ok
			ok

			@i++
		end
	    
		return _nLenStr_
	
	func ExistsAt(pcSearchStr, pcMainStr, pnStartPos)
		if pnStartPos + stzlen(pcSearchStr) - 1 > stzlen(pcMainStr)
			return 0
		ok
	    
		return StzReplace(pcMainStr, pnStartPos, stzlen(pcSearchStr)) = pcSearchStr

		func @ExistsAt(pcSearchStr, pcMainStr, pnStartPos)
			return ExistsAt(pcSearchStr, pcMainStr, pnStartPos)

//func FindStrListInNestedStrList(pcItemProvidedAsStr, pcListProvidedAsStr) #ai #claude
//	positions = []
//	nLenItemProvidedAsStr = stzlen(pcItemProvidedAsStr)
//	nLenListProvidedAsStr = stzlen(pcListProvidedAsStr)
//	# Main parsing loop
//	rootPos = 1  # Track position at current depth
//	currentIndex = 1
//    
//	while currentIndex <= nLenListProvidedAsStr
//		# Check for direct match at current position
//		if ExistsAt(pcItemProvidedAsStr, pcListProvidedAsStr, currentIndex)
//			positions + [rootPos]  # Simply add current position
//			currentIndex += nLenItemProvidedAsStr
//		else
//			# Check for nested lists
//			if StzReplace(pcListProvidedAsStr, currentIndex, 1) = "["
//				subEnd = FindMatchingBracket(pcListProvidedAsStr, currentIndex)
//				if subEnd > currentIndex + 1
//					subStr = StzReplace(pcListProvidedAsStr, currentIndex + 1, subEnd - currentIndex - 1)
//					subPositions = FindStrListInNestedStrList(pcItemProvidedAsStr, subStr)
//					
//					# Only handle nesting for non-root positions
//					if rootPos != 1
//						for pos in subPositions
//							if isList(pos)
//								newPath = [rootPos]
//								for p in pos
//									newPath + p
//								next
//								positions + newPath
//							else
//								positions + [rootPos, pos]
//							ok
//						next
//					else
//						# At root level, add positions as-is
//						for pos in subPositions
//							positions + pos
//						next
//					ok
//				ok
//				currentIndex = subEnd
//			ok
//			currentIndex++
//		ok
//        
//		# Move to next item at current level
//		if currentIndex <= nLenListProvidedAsStr and 
//		   StzReplace(pcListProvidedAsStr, currentIndex, 1) = ","
//			rootPos++
//			currentIndex++
//		ok
//	end
//    
//	return positions
//
//	func FindMatchingBracket(pcStr, startPos)
//		openCount = 1
//		i = startPos + 1
//		nLenStr = stzlen(pcStr)
//	
//		while i <= nLenStr
//			if StzReplace(pcStr, i, 1) = "["
//				openCount++
//			but StzReplace(pcStr, i, 1) = "]"
//				openCount--
//				if openCount = 0
//					return i
//				ok
//			ok
//			i++
//		end
//	    
//		return nLenStr
//	
//	func ExistsAt(pcSearchStr, pcMainStr, pnStartPos)
//		if pnStartPos + stzlen(pcSearchStr) - 1 > stzlen(pcMainStr)
//			return false
//		ok
//	    
//		return StzReplace(pcMainStr, pnStartPos, stzlen(pcSearchStr)) = pcSearchStr
//

#=====

func IsRingSortable(pListOrString)

	# Ring can sort string ans lists.

	# In the case of lists, only lists made of numbers and strings
	# can be sorted. There is a special case though...

	# If the list is a list of lists, then Ring can sort it on
	# a given column, using ring(aList, nCol), but under a condition:

	# the column must be made of numbers and/or strings and must not
	# contain dupplicated items (because in this case, the output
	# is not accurate, at a hiher level, and should be managed by Softanza)

	if CheckingParams()
		if NOT ( isString(pListOrString) or isList(pListOrString) )
			StzRaise("Incorrect param type! pListOrString must be a list or string.")
		ok
	ok

	if isString(pListOrString)
		return 1
	ok

	# Case of a list

	if IsListOfNumbers(pListOrString) or
	   IsListOfStrings(pListOrString) or
	   IsListOfNumbersAndStrings(pListOrString)

		return 1

	but IsListOfLists(pListOrString)

		# Early check: case where one of the lists is empty

		nLen = len(pListOrString)

		for i = 1 to nLen
			if len(pListOrString[i]) = 0
				return 0
			ok
		next

		# Checking the columns one by one, and when we
		# find a column that is made of numbers and/or
		# strings and containing no dupplications, then
		# that column make the list of lists sortable

		oLoL = new stzListOfLists(pListOrString)
		nCols = oLoL.NumberOfCols()

		# Parsing all the columns one by one

		for i = 1 to nCols

			# Assuming the current column is Ring sortable

			bColSortable = 1

			# the column must contain only numbers and strings
			# and should not contain dupplicated items

			aCol = oLoL.Col(i)

			nLenCol = len(aCol)
			aSeen = []

			for j = 1 to nLenCol

				if NOT ( isString(aCol[j]) or isNumber(aCol[j]) )
					bColSortable = 0
					exit
				else
					if StzFind(aSeen, aCol[j]) = 0
						aSeen + aCol[j]
					else
						bColSortable = 0
						exit
					ok
				ok
			next

			if bColSortable # We've got a ring-sortable column!
				return 1
			ok

		next

		# We parsed all the list of lists, column by column, and
		# we did not find any ring-sortable column, so:

		return 0

	ok

	# In any other case

	return 0

	func @IsRingSortable(pListOrString)
		return IsRingSortable(pListOrString)

func IsRingSortableOn(paListOfLists, n)

	# In Ring, with the standard ring() function, to sort a list of
	# lists on a given column, that column must:

	# 1. the column of sort should have size as the first column
	# 2. be made of numbers or strings only (no lists or objects),
	# 3. must not contain dupllicated items (because in this case,
	#    the sorting result is not accurate - from Softanza point of view)

	if NOT ( isList(paListOfLists) and IsListOfLists(paListOfLists) )
		return 0
	ok

	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	# Early check : case where at least one list is empty

	nLen = len(paListOfLists)

	for i = 1 to nLen
		if len(paListOfLists[i]) = 0
			return 0
		ok
	next

	# getting the items in the column n

	oLoL = StzListOfListsQ(paListOfLists)
	aCol = oLoL.Col(n)
	nLen = len(aCol)

	# Early check: the column of sort should have
	# the same number of items as the first column

	if n > 1
		aCol1 = oLoL.Col(1)
		nLen1 = len(aCol1)

		if nLen != nLen1
			return 0
		ok
	ok

	aSeen = []

	for i = 1 to nLen
		if NOT ( isNumber(aCol[i]) or isString(aCol[i]) )
			return 0
		ok

		if StzFind(aSeen, aCol[i]) = 0
			aSeen + aCol[i]
		else
			return 0
		ok
	next

	return 1

	func @IsRingSortableOn(paListOfLists, n)
		return IsRingSortableOn(paListOfLists, n)
	
func Move(paList, n1, n2)

	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		if NOT isNumber(n1)
			StzRaise("Incorrect param type! n1 must be a number.")
		ok

		if NOT isNumber(n2)
			StzRaise("Incorrect param type! n2 must be a number.")
		ok
	ok

	item = paList[n1]
	ring_remove(paList, n1)
	n = n2
	if n1 > n2
		n++
	ok
	ring_insert(paList, n2, item)
	return paList


	#< @FunctionAlternativeForms

	func @Move(paList, n1, n2)
		return Move(paList, n1, n2)

	func MoveItems(paList, n1, n2)
		return Move(paList, n1, n2)

	func @MoveItems(paList, n1, n2)
		return Move(paList, n1, n2)

	#>

#NOTE: the mother function of the fellowing fluent forms
# is hosted in the stzDisplaySystem.ring file. They are
# put here because they are specific to Softanza classes,
# while all softanza systems files are can be used independently.

func ComputableShortFormQ(paList)
	return new stzString(ComputableShortForm(paList))

	func @@SFQ(paList)
		return ComputableShortFormQ(paList)

	func @@SQ(paList)
		return ComputableShortFormQ(paList)

	func ShortFormQ(paList)
		return ComputableShortFormQ(paList)

func ComputableFormXTQ(pValue, cSep1, cSep2)
	return new stzString( ComputableFormXT(pValue, c) )

	func @@XTQ(pValue, cSep1, cSep2)
		return new stzString( @@XT(pValue, cSep1, cSep2) )

	func CFXTQ(pValue, cSep1, cSep2)
		return new stzString( CFXT(pValue, cSep1, cSep2) )

	func @ComputableFormXTQ(pValue, cSep1, cSep2)
		return new stzString( @ComputableFormXT(pValue, cSep1, cSep2) )

func ComputableShortFormXTQ(paList, p)
	return new stzString(ComputableShortFormXT(paList, p))

	func ShortFormXTQ(paList, p)
		return new stzString(ShortFormXT(paList, p))

	func @@SFXTQ(paList, p)
		return new stzString(@@SFXT(paList, p))

	func @@SXTQ(paList, p)
		return new stzString(@@SFXT(paList, p))

func ComputableFormQ(pValue)
	return new stzString( ComputableForm(pValue) )

	func @@Q(pValue)
		return new stzString( @@(pValue) )

	func CFQ(pValue)
		return new stzString( CF(pValue) )

	func @ComputableFormQ(pValue)
		return new stzString( @ComputableForm(pValue) )

func ComputableFormNLQ(pValue)
	return new stzString( ComputableFormNL(pValue) )

	func @@NLQ(pValue)
		return ComputableFormNLQ(pValue)

	func @ComputableFormNLQ(pValue)
		return ComputableFormNLQ(pValue)

	func CFNLQ(pValue)
		return ComputableFormNLQ(pValue)

	func @@SPQ(pValue)
		return ComputableFormNLQ(pValue)

	func ComputableFormSPQ(pValue)
		return ComputableFormNLQ(pValue)

	func @ComputableFormSPQ(pValue)
		return ComputableFormNLQ(pValue)

	func ComputableFormSpacifiedQ(pValue)
		return ComputableFormNLQ(pValue)

	func @ComputableFormSpacifiedQ(pValue)
		return ComputableFormNLQ(pValue)

	func CFSPQ(pValue)
		return ComputableFormNLQ(pValue)

	func @CFSPQ(pValue)
		return ComputableFormNLQ(pValue)

#---

func IsContiguous(paList)
	if NOT isList(paList) return FALSE ok
	_nL_ = len(paList)
	if _nL_ < 2 return _nL_ = 1 ok
	for _i_ = 2 to _nL_
		_a_ = paList[_i_ - 1]
		_b_ = paList[_i_]
		if isNumber(_a_) and isNumber(_b_)
			if _b_ != _a_ + 1 return FALSE ok
		but isString(_a_) and isString(_b_) and len(_a_) = 1 and len(_b_) = 1
			if ascii(_b_) != ascii(_a_) + 1 return FALSE ok
		else
			return FALSE
		ok
	next
	return TRUE

	func IsContinuous(paList)
		return IsContiguous(paList)

	func IsConsecutive(paList)
		return IsContiguous(paList)

	#--

	func @IsContiguous(paList)
		return IsContiguous()

	func @IsContinuous()
		return IsContiguous()

	func @IsConsecutive()
			return IsContiguous()

#== Combinations functions by ClaudeAI #ai

# Helper function to generate combinations recursively
Func generateCombinationsXT(paList, nLen, nDepth, aCurrent, aResult)
	if len(aCurrent) = nDepth
		aResult + aCurrent
		return
	ok
	
	for i = 1 to nLen
		aCurrent + paList[i]
		generateCombinationsXT(paList, nLen, nDepth, aCurrent, aResult)
		del(aCurrent, len(aCurrent))
	next

# Function to generate all possible combinations including duplicates and inversions

Func CombinationsXT(aList, n)
	if CheckParams()
		if NOT isList(aList)
			StzRaise("Incorrect param type! aList must be a list.")
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	# Early check

	_nLen_ = len(aList)
	if _nLen_ = 0 or n = 0
		return []

	but _nLen_ = 1 or n = 1
		return aList
	ok

	# doing the job

	if n > _nLen_
		StzRaise("Can't proceed! n must be lesser than the size of the list.")
	ok

	_aResult_ = []
	_aCurrent_ = []
	
	if n > 0 and n <= _nLen_
		generateCombinationsXT(aList, _nLen_, n, _aCurrent_, _aResult_)
	ok
	
	return _aResult_

	func @CombinationsXT(paList, n)
		return CombinationsXT(paList, n)

# Function to generate combinations without duplicates or inversions

func Combinations(aList, n)
	if CheckParams()
		if NOT isList(aList)
			StzRaise("Incorrect param type! aList must be a list.")
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	# Early check

	_nLen_ = len(aList)
	if _nLen_ = 0 or n = 0
		return []

	but _nLen_ = 1 or n = 1
		return aList
	ok

	# doing the job

	if n > _nLen_
		StzRaise("Can't proceed! n must be lesser than the size of the list.")
	ok

	_aList_ = aList
	_aResult_ = []

	# Main loop for first element

	for @i = 1 to _nLen_ - n + 1

		# Inner loop for remaining elements

		for @j = @i + 1 to _nLen_ - n + 2
			_aCombination_ = []
			add(_aCombination_, _aList_[@i])

			# Additional loops for n > 2
			if n > 2
				for @k = @j + 1 to _nLen_
					_aTempComb_ = _aCombination_
					add(_aTempComb_, _aList_[@j])
					add(_aTempComb_, _aList_[@k])
					add(_aResult_, _aTempComb_)
				next
			else
				add(_aCombination_, _aList_[@j])
				add(_aResult_, _aCombination_)
			ok
		next
	next

	return _aResult_


	func @Combinations(aList, n)
		return Combinations(aList, n)

#===

func ListsHaveSameNumberOfItems(paList)

	if CheckParams()

		if NOT isList(paList)
			stzraise("Incorrect param type! paList must be alist.")
		ok

	ok

	nLen = len(paList)

	if nLen = 0
		StzRaise("Can't check inner lists! Because the list is empty.")
	ok

	nLenTemp = 0

	for i = 1 to nLen
		if isList(paList[i])
			nLenList = len(paList[i])
			if nLenTemp = 0
				nLenTemp = nLenList
			else
				if nLenList != nLenTemp
					return 0
				ok
			ok
		ok
	next

	return 1

	func AllListsHaveSameNumberOfItems(paList)
		return ListsHaveSameNumberOfItems(paList)

	func ListsHaveSameSize(paList)
		return ListsHaveSameNumberOfItems(paList)

	func AllListsHaveSameSize(paList)
		return ListsHaveSameNumberOfItems(paList)

	#--

	func @ListsHaveSameNumberOfItems(paList)
		return ListsHaveSameNumberOfItems(paList)

	func @AllListsHaveSameNumberOfItems(paList)
		return ListsHaveSameNumberOfItems(paList)

	func @ListsHaveSameSize(paList)
		return ListsHaveSameNumberOfItems(paList)

	func @AllListsHaveSameSize(paList)
		return ListsHaveSameNumberOfItems(paList)

#==

func AnyOf(paList)
	if CheckParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	nLen = len(paList)
	if nLen = 0
		StzRaise("Can't return any item! The list you provided is empty.")
	ok

	return paList[RandomIn(1:nLen)]

	func AnyItemOf(paList)
		return AnyOf(paList)

#===

func HasPath(paList, pacKeys)
	if CheckParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		if not (isList(pacKeys) and IsListOfStrings(pacKeys))
			StzRaise("Incorrect param type! pacKeys must be a list of strings.")
		ok
	ok

	# Start with the top-level list
	aCurrent = paList
	nLen = len(pacKeys)
	
	for i = 1 to nLen
		cKey = pacKeys[i]
		
		# Check if current level is a list (can be traversed)
		if not isList(aCurrent)
			return FALSE
		ok
		
		# Try to find the key in current level
		nPos = 0
		nCurrentLen = len(aCurrent)
		
		for j = 1 to nCurrentLen
			# Handle hashlist format [key, value]
			if isList(aCurrent[j]) and len(aCurrent[j]) >= 2
				if isString(aCurrent[j][1]) and StzLower(aCurrent[j][1]) = StzLower(cKey)
					nPos = j
					exit
				ok
			ok
		next
		
		# If key not found at this level
		if nPos = 0
			return FALSE
		ok
		
		# Move to the next level (the value of the found key)
		# Only do this if we're not at the last key
		if i < nLen
			if isList(aCurrent[nPos]) and len(aCurrent[nPos]) >= 2
				aCurrent = aCurrent[nPos][2]
			else
				return FALSE
			ok
		ok
	next

	return TRUE

	  #============================================#
	 #  HELPERS: items-with-positions, dup-runs   #
	#============================================#

	#-- type-sensitive item equality (distinguishes "1" from 1)
	func _StzItemEqTyped(pA, pB)
		if isString(pA) and isString(pB) return pA = pB ok
		if isNumber(pA) and isNumber(pB) return pA = pB ok
		if isList(pA) and isList(pB) return _DplListEq(pA, pB) ok
		return FALSE

	func _StzHasItemTyped(paList, pVal)
		nLen = len(paList)
		for i = 1 to nLen
			if _StzItemEqTyped(paList[i], pVal) return TRUE ok
		next
		return FALSE

	#-- [[item, [positions...]], ...] in first-appearance order
	func _StzItemsWithPositions(aContent)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			v = aContent[i]
			nFound = 0
			nR = len(aRes)
			for j = 1 to nR
				if _StzItemEqTyped(aRes[j][1], v) nFound = j exit ok
			next
			if nFound > 0
				add(aRes[nFound][2], i)
			else
				add(aRes, [ v, [i] ])
			ok
		next
		return aRes

	#-- [[item, count], ...] in first-appearance order (type-sensitive)
	func _StzItemsCount(aContent)
		aWith = _StzItemsWithPositions(aContent)
		aRes = []
		nLen = len(aWith)
		for i = 1 to nLen
			add(aRes, [ aWith[i][1], len(aWith[i][2]) ])
		next
		return aRes

	#-- first position whose item type-sensitively equals pItem (0 if none)
	func _StzFindFirstTyped(aContent, pItem)
		nLen = len(aContent)
		for i = 1 to nLen
			if _StzItemEqTyped(aContent[i], pItem) return i ok
		next
		return 0

	#-- positions whose item is NOT a member of paItems (type-sensitive)
	func _StzFindAllExcept(aContent, paItems)
		anRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if NOT _StzHasItemTyped(paItems, aContent[i]) add(anRes, i) ok
		next
		return anRes

	#-- [[value, [repeat positions]], ...] for items occurring more than once
	#-- (repeat = every position after the first); first-appearance order
	func _StzFindDuplicatesOrigins(aContent)
		aWith = _StzItemsWithPositions(aContent)
		aRes = []
		nLen = len(aWith)
		for i = 1 to nLen
			nP = len(aWith[i][2])
			if nP > 1
				aRep = []
				for j = 2 to nP add(aRep, aWith[i][2][j]) next
				add(aRes, [ aWith[i][1], aRep ])
			ok
		next
		return aRes

	#-- content with the items at panPos (1-based) removed
	func _StzRemoveAtPositions(aContent, panPos)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if NOT _StzHasItemTyped(panPos, i) add(aRes, aContent[i]) ok
		next
		return aRes

	#-- keep only items that ARE members of paItems (type-sensitive)
	func _StzKeepMembers(aContent, paItems)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if _StzHasItemTyped(paItems, aContent[i]) add(aRes, aContent[i]) ok
		next
		return aRes

	#-- drop the leading / trailing run equal to pItem
	func _StzRemoveLeadingRun(aContent, pItem)
		nLen = len(aContent)
		nStart = nLen + 1
		bDone = FALSE
		for i = 1 to nLen
			if NOT bDone and _StzItemEqTyped(aContent[i], pItem)
				# still in the leading run
			else
				nStart = i
				bDone = TRUE
				exit
			ok
		next
		aRes = []
		for i = nStart to nLen add(aRes, aContent[i]) next
		return aRes

	func _StzRemoveTrailingRun(aContent, pItem)
		nLen = len(aContent)
		nEnd = 0
		for i = nLen to 1 step -1
			if NOT _StzItemEqTyped(aContent[i], pItem)
				nEnd = i
				exit
			ok
		next
		aRes = []
		for i = 1 to nEnd add(aRes, aContent[i]) next
		return aRes

	#-- keep only items that occur more than once (remove the singletons)
	func _StzRemoveNonDuplicates(aContent)
		aWith = _StzItemsWithPositions(aContent)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			v = aContent[i]
			nCnt = 0
			nW = len(aWith)
			for k = 1 to nW
				if _StzItemEqTyped(aWith[k][1], v) nCnt = len(aWith[k][2]) exit ok
			next
			if nCnt > 1 add(aRes, v) ok
		next
		return aRes

	#-- pick aAllPos[ panOcc[i] ] for each i (1-based, out-of-range skipped)
	func _StzPickPositions(panOcc, aAllPos)
		aRes = []
		nLen = len(panOcc)
		nP = len(aAllPos)
		for i = 1 to nLen
			if panOcc[i] >= 1 and panOcc[i] <= nP add(aRes, aAllPos[ panOcc[i] ]) ok
		next
		return aRes

	#-- positions of items that are lists of exactly nWantLen elements
	func _StzFindListsOfLen(aContent, nWantLen)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if isList(aContent[i]) and len(aContent[i]) = nWantLen add(aRes, i) ok
		next
		return aRes

	func _StzItemsAtPos(aContent, panPos)
		aRes = []
		nLen = len(panPos)
		for i = 1 to nLen add(aRes, aContent[ panPos[i] ]) next
		return aRes

	#-- dedup a list structurally, first-appearance order
	func _StzUniqueItems(aList)
		aRes = []
		nLen = len(aList)
		for i = 1 to nLen
			if NOT _StzHasItemTyped(aRes, aList[i]) add(aRes, aList[i]) ok
		next
		return aRes

	#-- [[value,[positions]],...] over the given positions, first-appearance
	func _StzGroupItemsAtPos(aContent, panPos)
		aRes = []
		nLen = len(panPos)
		for i = 1 to nLen
			v = aContent[ panPos[i] ]
			nFound = 0
			nr = len(aRes)
			for j = 1 to nr
				if _StzItemEqTyped(aRes[j][1], v) nFound = j exit ok
			next
			if nFound > 0
				add(aRes[nFound][2], panPos[i])
			else
				add(aRes, [ v, [ panPos[i] ] ])
			ok
		next
		return aRes

	#-- wrap each item as a 1-element list (scalar->[x], list->[firstElem])
	func _StzSinglified(aContent)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if isList(aContent[i])
				if len(aContent[i]) >= 1 add(aRes, [ aContent[i][1] ]) else add(aRes, []) ok
			else
				add(aRes, [ aContent[i] ])
			ok
		next
		return aRes

	#-- pad each non-pair item into a pair [item, NULL]; keep existing pairs
	func _StzPairified(aContent)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if isList(aContent[i]) and len(aContent[i]) = 2
				add(aRes, aContent[i])
			else
				add(aRes, [ aContent[i], NULL ])
			ok
		next
		return aRes

	#-- positions of items type-sensitively equal to pItem
	func _StzPositionsOf(aContent, pItem)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if _StzItemEqTyped(aContent[i], pItem) add(aRes, i) ok
		next
		return aRes

	#-- [[item, [positions]], ...] for each item in paItems (incl. empties)
	func _StzTheseItemsZ(aContent, paItems)
		aRes = []
		nLen = len(paItems)
		for i = 1 to nLen
			add(aRes, [ paItems[i], _StzPositionsOf(aContent, paItems[i]) ])
		next
		return aRes

	#-- distinct items whose occurrence count satisfies cOp vs nWant
	#-- (cOp: "ge" >= , "gt" > , "le" <= , "lt" < , "eq" ==); first-appearance
	func _StzItemsByCountOp(aContent, nWant, cOp)
		aWith = _StzItemsWithPositions(aContent)
		aRes = []
		nLen = len(aWith)
		for i = 1 to nLen
			nC = len(aWith[i][2])
			bKeep = FALSE
			switch cOp
			on "ge" bKeep = (nC >= nWant)
			on "gt" bKeep = (nC >  nWant)
			on "le" bKeep = (nC <= nWant)
			on "lt" bKeep = (nC <  nWant)
			on "eq" bKeep = (nC =  nWant)
			off
			if bKeep add(aRes, aWith[i][1]) ok
		next
		return aRes

	func _StzAllEqualCS(aContent, pItem, bCaseSensitive)
		nLen = len(aContent)
		if nLen = 0 return TRUE ok
		for i = 1 to nLen
			if isString(aContent[i]) and isString(pItem) and bCaseSensitive = 0
				if StzLower(aContent[i]) != StzLower(pItem) return FALSE ok
			else
				if NOT _StzItemEqTyped(aContent[i], pItem) return FALSE ok
			ok
		next
		return TRUE

	func _StzAllSameType(aContent)
		nLen = len(aContent)
		if nLen <= 1 return TRUE ok
		cT = type(aContent[1])
		for i = 2 to nLen
			if type(aContent[i]) != cT return FALSE ok
		next
		return TRUE

	func _StzAllEmptyLists(aContent)
		nLen = len(aContent)
		if nLen = 0 return FALSE ok
		for i = 1 to nLen
			if NOT (isList(aContent[i]) and len(aContent[i]) = 0) return FALSE ok
		next
		return TRUE

	func _StzAllEqualTyped(aContent, pItem)
		nLen = len(aContent)
		if nLen = 0 return TRUE ok
		for i = 1 to nLen
			if NOT _StzItemEqTyped(aContent[i], pItem) return FALSE ok
		next
		return TRUE

	#-- insert pItem after / before each position in panPos (1-based)
	func _StzInsertAfterPositions(aContent, panPos, pItem)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			add(aRes, aContent[i])
			if _StzHasItemTyped(panPos, i) add(aRes, pItem) ok
		next
		return aRes

	func _StzInsertBeforePositions(aContent, panPos, pItem)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if _StzHasItemTyped(panPos, i) add(aRes, pItem) ok
			add(aRes, aContent[i])
		next
		return aRes

	#-- TRUE if any item is of the given type tag (number/string/list/object)
	func _StzContainsType(aContent, cType)
		nLen = len(aContent)
		for i = 1 to nLen
			if _StzIsTypeTag(aContent[i], cType) return TRUE ok
		next
		return FALSE

	#-- how many DISTINCT members of paItems appear in aContent (type-sensitive)
	func _StzCountMembersPresent(aContent, paItems)
		nCount = 0
		nLen = len(paItems)
		for i = 1 to nLen
			if _StzHasItemTyped(aContent, paItems[i]) nCount++ ok
		next
		return nCount

	#-- WF (anonymous-function constraint) family. pFunc is a Ring function
	#-- f(item)->bool, called natively per item (no parsing, no eval). This is
	#-- the full-Ring-power escape hatch alongside the sandboxed W DSL.
	func _StzFindWF(aContent, pFunc)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if ( call pFunc(aContent[i]) ) add(aRes, i) ok
		next
		return aRes

	func _StzCheckWF(aContent, pFunc)
		nLen = len(aContent)
		for i = 1 to nLen
			if NOT ( call pFunc(aContent[i]) ) return FALSE ok
		next
		return TRUE

	#-- keep only items for which pFunc is FALSE (remove the matching ones)
	func _StzRemoveWF(aContent, pFunc)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if NOT ( call pFunc(aContent[i]) ) add(aRes, aContent[i]) ok
		next
		return aRes

	#-- replace each matching item with pNew
	func _StzReplaceWF(aContent, pFunc, pNew)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if ( call pFunc(aContent[i]) ) add(aRes, pNew) else add(aRes, aContent[i]) ok
		next
		return aRes

	#-- map: apply pFunc to every item, collecting the results
	func _StzMapWF(aContent, pFunc)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			add(aRes, call pFunc(aContent[i]))
		next
		return aRes

	#-- insert pItem after / before each matching item
	func _StzInsertAfterWF(aContent, pFunc, pItem)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			add(aRes, aContent[i])
			if ( call pFunc(aContent[i]) ) add(aRes, pItem) ok
		next
		return aRes

	func _StzInsertBeforeWF(aContent, pFunc, pItem)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if ( call pFunc(aContent[i]) ) add(aRes, pItem) ok
			add(aRes, aContent[i])
		next
		return aRes

	#-- Perform an action on the items matching a condition, both given as
	#-- anonymous functions: pCond(item)->bool selects, pAction(item)->newItem
	#-- transforms. Non-matching items are kept unchanged. (eval-free.)
	func _StzPerformWF(aContent, pCond, pAction)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if ( call pCond(aContent[i]) )
				add(aRes, call pAction(aContent[i]))
			else
				add(aRes, aContent[i])
			ok
		next
		return aRes

	#-- WF check restricted to the items at the given positions
	func _StzCheckItemsAtWF(aContent, panPos, pFunc)
		nLen = len(panPos)
		nC = len(aContent)
		for i = 1 to nLen
			p = panPos[i]
			if p >= 1 and p <= nC
				if NOT ( call pFunc(aContent[p]) ) return FALSE ok
			ok
		next
		return TRUE

	#-- TRUE iff every element of panSub is a member of panSet
	func _StzAllIn(panSub, panSet)
		nLen = len(panSub)
		for i = 1 to nLen
			if NOT _StzHasItemTyped(panSet, panSub[i]) return FALSE ok
		next
		return TRUE

	#-- contiguous runs of items of a given type, as [start,end] sections.
	#-- A sentinel of a DIFFERENT type is appended so the final run closes
	#-- (mirrors the monolith's FindNumbersAsSections trick).
	func _StzIsTypeTag(pItem, cType)
		switch cType
		on "number" return isNumber(pItem)
		on "string" return isString(pItem)
		on "list"   return isList(pItem)
		on "object" return isObject(pItem)
		off
		return FALSE

	func _StzFindTypeRuns(aContent, cType)
		aC = []
		nC = len(aContent)
		for i = 1 to nC add(aC, aContent[i]) next
		if cType = "number" add(aC, "X") else add(aC, 0) ok

		nLen = len(aC)
		if nLen <= 1 return [] ok

		aResult = []
		n1 = 1
		for i = 2 to nLen - 1
			if _StzIsTypeTag(aC[i], cType) and NOT _StzIsTypeTag(aC[i-1], cType)
				n1 = i
			ok
			if _StzIsTypeTag(aC[i], cType) and NOT _StzIsTypeTag(aC[i+1], cType)
				add(aResult, [ n1, i ])
			ok
		next
		return aResult

	#-- consistent stringification for consecutive-equality comparison
	func _StzStringifyItem(pItem)
		if isNumber(pItem) return "" + pItem ok
		return @@(pItem)

	#-- [[value, [consecutive-dup positions]], ...] first-appearance order
	func _StzDupSecutiveItemsZ(aContent, bCaseSensitive)
		anPos = _StzFindDupSecutive(aContent, bCaseSensitive)
		aVals = _StzDupSecutiveValues(aContent, bCaseSensitive)
		aRes = []
		nV = len(aVals)
		for i = 1 to nV
			cTarget = _StzStringifyItem(aVals[i])
			if bCaseSensitive = 0 cTarget = StzLower(cTarget) ok
			aP = []
			nP = len(anPos)
			for j = 1 to nP
				c = _StzStringifyItem(aContent[ anPos[j] ])
				if bCaseSensitive = 0 c = StzLower(c) ok
				if c = cTarget add(aP, anPos[j]) ok
			next
			add(aRes, [ aVals[i], aP ])
		next
		return aRes

	#-- content with the consecutive-duplicate items removed
	func _StzRemoveDupSecutive(aContent, bCaseSensitive)
		anPos = _StzFindDupSecutive(aContent, bCaseSensitive)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if NOT _StzHasItemTyped(anPos, i) add(aRes, aContent[i]) ok
		next
		return aRes

	#-- content with the consecutive-duplicates of pItem removed
	func _StzRemoveThisDupSecutive(aContent, pItem, bCaseSensitive)
		anPos = _StzFindThisDupSecutive(aContent, pItem, bCaseSensitive)
		aRes = []
		nLen = len(aContent)
		for i = 1 to nLen
			if NOT _StzHasItemTyped(anPos, i) add(aRes, aContent[i]) ok
		next
		return aRes

	#-- positions i where item[i] equals item[i-1] (consecutive duplicate)
	func _StzFindDupSecutive(aContent, bCaseSensitive)
		nLen = len(aContent)
		if nLen <= 1 return [] ok
		acItems = []
		for i = 1 to nLen
			c = _StzStringifyItem(aContent[i])
			if bCaseSensitive = 0 c = StzLower(c) ok
			add(acItems, c)
		next
		anRes = []
		for i = 2 to nLen
			if acItems[i-1] = acItems[i] add(anRes, i) ok
		next
		return anRes

	#-- the distinct values (first-appearance) that occur consecutively
	#-- duplicated; dedup honors case-sensitivity (B and b merge when CS=0)
	func _StzDupSecutiveValues(aContent, bCaseSensitive)
		anPos = _StzFindDupSecutive(aContent, bCaseSensitive)
		aRes = []
		aKeys = []
		nLen = len(anPos)
		for i = 1 to nLen
			v = aContent[ anPos[i] ]
			k = _StzStringifyItem(v)
			if bCaseSensitive = 0 k = StzLower(k) ok
			if NOT _StzHasItemTyped(aKeys, k)
				add(aKeys, k)
				add(aRes, v)
			ok
		next
		return aRes

	#-- positions among the consecutive-dups whose item equals pItem
	func _StzFindThisDupSecutive(aContent, pItem, bCaseSensitive)
		anPos = _StzFindDupSecutive(aContent, bCaseSensitive)
		cTarget = _StzStringifyItem(pItem)
		if bCaseSensitive = 0 cTarget = StzLower(cTarget) ok
		aRes = []
		nLen = len(anPos)
		for i = 1 to nLen
			c = _StzStringifyItem(aContent[ anPos[i] ])
			if bCaseSensitive = 0 c = StzLower(c) ok
			if c = cTarget add(aRes, anPos[i]) ok
		next
		return aRes

  /////////////////
 ///   CLASS   ///
/////////////////

class TempAndDumpyThing

