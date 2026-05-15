#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFUNC                #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Q-constructors and utility functions        #
#                  for stzList modular classes.                 #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///FUNCTIONS  ///
/////////////////

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

	  #============================================#
	 #  ESSENTIAL UTILITY FUNCTIONS               #
	#============================================#

	#-- Map / Filter / Reduce (functional programming)

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

	func @Reduce(aList, cFunc, xInitial)

		if CheckParams()
			if not isList( aList )
				raise( "Incorrect param type! aList must be a list.")
			ok
			If not @IsFunction(cFunc)
				raise("Incorrect param type! cFunc must be a function.")
			ok
		ok

		nStart = 1

		if IsNULL(xInitial)
			if len(aList) > 0
				xInitial = aList[1]
				nStart = 2
			else
				raise("if xInitial is NULL, then Reduce() requires a non-empty list!")
			ok
		else
			if len(aList) < 1
				return xInitial
			ok
		ok

		sElementType = type(xInitial)
		xResult = xInitial

		for nElement = nStart to len(aList)
			xNthElement = aList[nElement]
			sNthElementType = type(xNthElement)

			If not sNthElementType = sElementType
				raise( "Element type mismatch: " + sNthElementType + " vs " + sElementType )
			ok

			xResult = call cFunc(xResult, xNthElement)
		next

		return xResult

	#-- Comparison

	func ListEqualsCS(paList1, paList2, pCaseSensitive)
		return StzListQ(paList1).IsEqualToCS(paList2, pCaseSensitive)

	#-- Deep operations

	func DeepContainsCS(paList, pItem, pCaseSensitive)
		return StzListQ(paList).DeepContainsCS(pItem, pCaseSensitive)

		func @DeepContainsCS(paList, pItem, pCaseSensitive)
			return DeepContainsCS(paList, pItem, pCaseSensitive)

	func DeepContains(paList, pItem)
		return DeepContainsCS(paList, pItem, 0)

		func @DeepContains(paList, pItem)
			return DeepContains(paList, pItem)

	#-- Finding (optimized Ring-native functions)

	func @FindAllCS_NbrOrStr(paList, pItem, pCaseSensitive)

		if CheckingParams()
			if NOT isList(paList)
				StzRaise("Incorrect param type! paList must be a list.")
			ok

			if NOT (isString(pItem) or isNumber(pItem))
				return -1
			ok

			if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveNamedParam()
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
				pItem = lower(_item_)
			ok

			_aList_ = StzListQ(_aList_).Lowercased()
		ok

		_anResult_ = []
		_nPos_ = -1

		while 1
			try
				_nPos_ = find(_aList_, _item_)
			catch
				return -1
			done

			if _nPos_ = 0
				exit
			ok

			_anResult_ + _nPos_
			_aList_[ _nPos_ ] += (""+ _aList_[ _nPos_ ] + 1)
		end

		return _anResult_

	func @FindAll_NbrOrStr(aList, pItem)
		return @FindAllCS_NbrOrStr(aList, pItem, 1)

	func @FindFirstCS(aList, pStrOrNbr, pCaseSensitive)
		anPos = @FindAllCS_NbrOrStr(aList, pStrOrNbr, pCaseSensitive)
		if isList(anPos) and len(anPos) > 0
			return anPos[1]
		ok
		return 0

	func @FindFirst(aList, pStrOrNbr)
		return @FindFirstCS(aList, pStrOrNbr, 1)

	func @FindLastCS(aList, pStrOrNbr, pCaseSensitive)
		anPos = @FindAllCS_NbrOrStr(aList, pStrOrNbr, pCaseSensitive)
		if isList(anPos) and len(anPos) > 0
			return anPos[len(anPos)]
		ok
		return 0

	func @FindLast(aList, pStrOrNbr)
		return @FindLastCS(aList, pStrOrNbr, 1)

	#-- Sorting

	func @SortList(paList)
		return sort(paList)

	func @Sort(p)
		if isList(p)
			return @SortList(p)
		ok
		return p

	#-- Reverse

	func @Reverse(p)
		if isList(p)
			return ring_reverse(p)
		but isString(p)
			oStr = new stzString(p)
			return oStr.Reversed()
		ok
		return p

	#-- Slice / Repeat

	func Slice(pStrOrList, n1, n2)
		if isString(pStrOrList)
			return substr(pStrOrList, n1, n2 - n1 + 1)
		but isList(pStrOrList)
			return StzListQ(pStrOrList).Section(n1, n2)
		ok

	func Repeat(value, nTimes)
		aResult = []
		for i = 1 to nTimes
			aResult + value
		next
		return aResult

	func ListOfNTimes(n, pItem)
		return Repeat(pItem, n)

	#-- List utility

	func WithoutDuplication(paList)
		return StzListQ(paList).WithoutDuplication()

	func Stringify(p)
		if isList(p)
			return StzListQ(p).Stringified()
		else
			return "" + p
		ok

	func ListStringify(paList)
		return Stringify(paList)

	func IsEmptyList(paList)
		if isList(paList) and len(paList) = 0
			return 1
		else
			return 0
		ok

	func ListShow(paList)
		? @@(paList)

	func ListContainsCS(paList, pItem, pCaseSensitive)
		return StzListQ(paList).ContainsCS(pItem, pCaseSensitive)

	func ListContainsOneOfTheseCS(paList, paItems, pCaseSensitive)
		nLen = len(paItems)
		for i = 1 to nLen
			if ListContainsCS(paList, paItems[i], pCaseSensitive)
				return 1
			ok
		next
		return 0

	func ListContainsOneOfThese(paList, paItems)
		return ListContainsOneOfTheseCS(paList, paItems, 1)

	func ListCountCS(aList, pItem, pCaseSensitive)
		return len(@FindAllCS_NbrOrStr(aList, pItem, pCaseSensitive))

	func ListCount(aList, pItem)
		return ListCountCS(aList, pItem, 1)

	#-- Type checking (most common)

	func IsListOfNumbers(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isNumber(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfStrings(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isString(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfLists(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfObjects(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isObject(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfPairs(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT (isList(paList[i]) and len(paList[i]) = 2)
				return 0
			ok
		next
		return 1

	func IsListOfHashLists(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			oTemp = new stzList(paList[i])
			if NOT oTemp.IsHashList()
				return 0
			ok
		next
		return 1

	func IsHybridList(paList)
		nLen = len(paList)
		if nLen <= 1
			return 0
		ok
		cFirstType = type(paList[1])
		for i = 2 to nLen
			if type(paList[i]) != cFirstType
				return 1
			ok
		next
		return 0

	func IsPairOfStrings(paPair)
		if isList(paPair) and len(paPair) = 2 and
		   isString(paPair[1]) and isString(paPair[2])
			return 1
		ok
		return 0

	func IsPairOfNumbers(paPair)
		if isList(paPair) and len(paPair) = 2 and
		   isNumber(paPair[1]) and isNumber(paPair[2])
			return 1
		ok
		return 0

	#NOTE: The remaining ~200 type-checking functions (IsListOfPairsOfStrings,
	# IsListOfStzNumbers, etc.) remain in the monolith stzlist.ring and will
	# be progressively migrated here as part of M-S1 Phase 2.
