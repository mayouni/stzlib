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
				pItem = lower(_item_)
			ok

			_aList_ = ListLowercased(_aList_)
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
		return ListContainsCS(paList, pItem, pCaseSensitive)

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

	#-- Pair type checking

	func IsPairOfLists(paPair)
		if isList(paPair) and len(paPair) = 2 and
		   isList(paPair[1]) and isList(paPair[2])
			return 1
		ok
		return 0

	func IsPairOfObjects(paPair)
		if isList(paPair) and len(paPair) = 2 and
		   isObject(paPair[1]) and isObject(paPair[2])
			return 1
		ok
		return 0

	func IsPairOfNumberAndString(paList)
		if isList(paList) and len(paList) = 2 and
		   isNumber(paList[1]) and isString(paList[2])
			return 1
		ok
		return 0

	func IsPairOfStringAndNumber(paList)
		if isList(paList) and len(paList) = 2 and
		   isString(paList[1]) and isNumber(paList[2])
			return 1
		ok
		return 0

	func IsPairAndKeyIsString(paList)
		if isList(paList) and len(paList) = 2 and isString(paList[1])
			return 1
		ok
		return 0

	func IsPairOfChars(paList)
		if isList(paList) and len(paList) = 2 and
		   isString(paList[1]) and len(paList[1]) = 1 and
		   isString(paList[2]) and len(paList[2]) = 1
			return 1
		ok
		return 0

	func IsPairOfEmptyLists(paList)
		if isList(paList) and len(paList) = 2 and
		   isList(paList[1]) and len(paList[1]) = 0 and
		   isList(paList[2]) and len(paList[2]) = 0
			return 1
		ok
		return 0

	func IsPairOfPairs(paList)
		if isList(paList) and len(paList) = 2 and
		   isList(paList[1]) and len(paList[1]) = 2 and
		   isList(paList[2]) and len(paList[2]) = 2
			return 1
		ok
		return 0

	func IsPairOfSections(paPair)
		if isList(paPair) and len(paPair) = 2 and
		   isList(paPair[1]) and len(paPair[1]) = 2 and
		   isNumber(paPair[1][1]) and isNumber(paPair[1][2]) and
		   isList(paPair[2]) and len(paPair[2]) = 2 and
		   isNumber(paPair[2][1]) and isNumber(paPair[2][2])
			return 1
		ok
		return 0

	#-- IsListOf* compound types

	func IsListOfPairsOfStrings(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT IsPairOfStrings(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfPairsOfNumbers(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT IsPairOfNumbers(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfPairsOfLists(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT IsPairOfLists(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfPairsOfObjects(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT IsPairOfObjects(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfPairsOfPairs(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT IsPairOfPairs(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfPairsOfSections(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT IsPairOfSections(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfPairsOfChars(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT IsPairOfChars(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfPairsOfNumberAndString(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT IsPairOfNumberAndString(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfPairsOfStringAndNumber(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT IsPairOfStringAndNumber(paList[i])
				return 0
			ok
		next
		return 1

	#-- IsListOfListsOf* (nested type checking)

	func IsListOfListsOfNumbers(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if NOT IsListOfNumbers(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfListsOfStrings(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if NOT IsListOfStrings(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfListsOfLists(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if NOT IsListOfLists(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfListsOfObjects(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if NOT IsListOfObjects(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfListsOfPairs(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if NOT IsListOfPairs(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfListsOfHashLists(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if NOT IsListOfHashLists(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfListsOfHybridLists(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if NOT IsHybridList(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfListsOfPairsOfNumbers(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if NOT IsListOfPairsOfNumbers(paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfListsOfPairsOfStrings(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if NOT IsListOfPairsOfStrings(paList[i])
				return 0
			ok
		next
		return 1

	#-- Special list types

	func IsListOfChars(pacList)
		nLen = len(pacList)
		for i = 1 to nLen
			if NOT (isString(pacList[i]) and len(pacList[i]) = 1)
				return 0
			ok
		next
		return 1

	func IsListOfLetters(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isString(paList[i])
				return 0
			ok
			if len(paList[i]) != 1
				return 0
			ok
			c = ascii(paList[i])
			if NOT ((c >= 65 and c <= 90) or (c >= 97 and c <= 122))
				return 0
			ok
		next
		return 1

	func IsListOfBits(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT (isNumber(paList[i]) and (paList[i] = 0 or paList[i] = 1))
				return 0
			ok
		next
		return 1

	func IsListOfBoleans(paList)
		return IsListOfBits(paList)

	func IsListOfSets(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			oTemp = new stzList(paList[i])
			if oTemp.HasDuplicates()
				return 0
			ok
		next
		return 1

	func IsListOfNumbersInStrings(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isString(paList[i])
				return 0
			ok
			if NOT isNumber(0 + paList[i])
				return 0
			ok
		next
		return 1

	func IsListOfNumbersOrStrings(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT (isNumber(paList[i]) or isString(paList[i]))
				return 0
			ok
		next
		return 1

	func IsListOfNumbersAndStrings(paList)
		bHasNumber = 0
		bHasString = 0
		nLen = len(paList)

		for i = 1 to nLen
			if isNumber(paList[i])
				bHasNumber = 1
			but isString(paList[i])
				bHasString = 1
			else
				return 0
			ok
		next

		return bHasNumber and bHasString

	func IsListOfStringsAndPairsOfStrings(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if isString(paList[i])
				# ok
			but isList(paList[i]) and IsPairOfStrings(paList[i])
				# ok
			else
				return 0
			ok
		next
		return 1

	#-- Structure classification

	func IsDeepList(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if isList(paList[i])
				return 1
			ok
		next
		return 0

	func IsPureList(paList)
		nLen = len(paList)
		if nLen <= 1
			return 1
		ok

		cFirstType = type(paList[1])
		for i = 2 to nLen
			if type(paList[i]) != cFirstType
				return 0
			ok
		next
		return 1

	func IsOddList(paList)
		return (len(paList) % 2) = 1

	func IsEvenList(paList)
		return (len(paList) % 2) = 0

	func IsUniformListCS(paList, pCaseSensitive)
		nLen = len(paList)
		if nLen <= 1
			return 1
		ok

		cFirst = @@(paList[1])
		if pCaseSensitive = 0
			cFirst = ring_lower(cFirst)
		ok

		for i = 2 to nLen
			cItem = @@(paList[i])
			if pCaseSensitive = 0
				cItem = ring_lower(cItem)
			ok
			if cItem != cFirst
				return 0
			ok
		next
		return 1

	func IsListOfSameSize(paList)
		return IsListOfListsOfSameSize(paList)

	func IsListOfListsOfSameSize(paList)
		nLen = len(paList)
		if nLen <= 1
			return 1
		ok

		if NOT isList(paList[1])
			return 0
		ok

		nSize = len(paList[1])
		for i = 2 to nLen
			if NOT isList(paList[i])
				return 0
			ok
			if len(paList[i]) != nSize
				return 0
			ok
		next
		return 1

	func IsListOfSections(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT (isList(paList[i]) and len(paList[i]) = 2 and
			        isNumber(paList[i][1]) and isNumber(paList[i][2]))
				return 0
			ok
		next
		return 1

	func IsHashListOrListOfStrings(paList)
		if IsListOfStrings(paList)
			return 1
		ok
		if IsListOfHashLists(paList)
			return 1
		ok
		return 0

	#-- Sorting checks

	func IsSortedList(paList)
		return StzListQ(paList).IsSorted()

	func IsSortedListInAscending(paList)
		return StzListQ(paList).IsSortedInAscending()

	func IsSortedListInDescending(paList)
		return StzListQ(paList).IsSortedInDescending()

	func SortingOrder(p)
		return StzListQ(p).SortingOrder()

	func HaveSameSortingOrder(p1, p2)
		return StzListQ(p1).HasSameSortingOrderAs(p2)

	#-- Comparison functions

	func AreBothEqualCS(p1, p2, pCaseSensitive)
		if isNumber(p1) and isNumber(p2)
			return p1 = p2

		but isString(p1) and isString(p2)
			if pCaseSensitive = 1
				return p1 = p2
			else
				return ring_lower(p1) = ring_lower(p2)
			ok

		but isList(p1) and isList(p2)
			return StzListQ(p1).IsEqualToCS(p2, pCaseSensitive)

		ok
		return 0

	func AreBothEqual(p1, p2)
		return AreBothEqualCS(p1, p2, 1)

	func HaveSameType(paItems)
		nLen = len(paItems)
		if nLen <= 1
			return 1
		ok

		cType = type(paItems[1])
		for i = 2 to nLen
			if type(paItems[i]) != cType
				return 0
			ok
		next
		return 1

	func BothHaveSameType(p1, p2)
		return type(p1) = type(p2)

	func HaveBothSameType(p1, p2)
		return BothHaveSameType(p1, p2)

	#-- Type extraction

	func AreNumbers(paList)
		return IsListOfNumbers(paList)

	func AreStrings(paList)
		return IsListOfStrings(paList)

	func AreLists(paList)
		return IsListOfLists(paList)

	func AreObjects(paList)
		return IsListOfObjects(paList)

	func Types(paValues)
		nLen = len(paValues)
		acResult = []
		for i = 1 to nLen
			acResult + type(paValues[i])
		next
		return acResult

	func StringsIn(paList)
		nLen = len(paList)
		aResult = []
		for i = 1 to nLen
			if isString(paList[i])
				aResult + paList[i]
			ok
		next
		return aResult

	func ListsIn(paList)
		nLen = len(paList)
		aResult = []
		for i = 1 to nLen
			if isList(paList[i])
				aResult + paList[i]
			ok
		next
		return aResult

	func ObjectsIn(paList)
		nLen = len(paList)
		aResult = []
		for i = 1 to nLen
			if isObject(paList[i])
				aResult + paList[i]
			ok
		next
		return aResult

	func OnlyNumbers(paList)
		nLen = len(paList)
		aResult = []
		for i = 1 to nLen
			if isNumber(paList[i])
				aResult + paList[i]
			ok
		next
		return aResult

	#-- Null checking

	func AllTheseAreNull(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if NOT isNULL(paList[i])
				return 0
			ok
		next
		return 1

	func AllOfTheseAreNotNull(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if isNULL(paList[i])
				return 0
			ok
		next
		return 1

	func BothAreNull(p1, p2)
		return isNULL(p1) and isNULL(p2)

	func BothAreNotNull(p1, p2)
		return (NOT isNULL(p1)) and (NOT isNULL(p2))

	func NoOneOfTheseIsAString(paList)
		nLen = len(paList)
		for i = 1 to nLen
			if isString(paList[i])
				return 0
			ok
		next
		return 1

	#-- List access helpers

	func ListFirstItem(paList)
		if isList(paList) and len(paList) > 0
			return paList[1]
		ok
		return NULL

	func ListLastItem(paList)
		if isList(paList) and len(paList) > 0
			return paList[len(paList)]
		ok
		return NULL

	func ListFindAll(paList, p)
		return StzListQ(paList).FindAll(p)

	func ListToCode(paList)
		return @@(paList)

	func Move(paList, n1, n2)
		oTemp = new stzList(paList)
		oTemp.MoveItem(n1, n2)
		return oTemp.Content()

	func IsContiguous(paList)
		if NOT IsListOfNumbers(paList)
			return 0
		ok
		nLen = len(paList)
		if nLen <= 1
			return 1
		ok
		for i = 2 to nLen
			if paList[i] != paList[i-1] + 1
				return 0
			ok
		next
		return 1

	func FirstN(n, aList)
		return StzListQ(aList).NFirstItems(n)

	func ListsHaveSameNumberOfItems(paList)
		nLen = len(paList)
		if nLen <= 1
			return 1
		ok
		nSize = len(paList[1])
		for i = 2 to nLen
			if len(paList[i]) != nSize
				return 0
			ok
		next
		return 1

	func IsListInString(pcStr)
		if NOT isString(pcStr)
			return 0
		ok
		pcStr = trim(pcStr)
		if left(pcStr, 1) = "[" and right(pcStr, 1) = "]"
			return 1
		ok
		return 0

	func IsPairOf(pcType, paPair)
		if NOT (isList(paPair) and len(paPair) = 2)
			return 0
		ok
		return type(paPair[1]) = upper(pcType) and type(paPair[2]) = upper(pcType)

	func IsListOf(pcType, paList)
		nLen = len(paList)
		for i = 1 to nLen
			if type(paList[i]) != upper(pcType)
				return 0
			ok
		next
		return 1

	func ListLowercased(paList)
		aResult = []
		nLen = len(paList)
		for i = 1 to nLen
			if isString(paList[i])
				aResult + lower(paList[i])
			else
				aResult + paList[i]
			ok
		next
		return aResult

	func ListUppercased(paList)
		aResult = []
		nLen = len(paList)
		for i = 1 to nLen
			if isString(paList[i])
				aResult + upper(paList[i])
			else
				aResult + paList[i]
			ok
		next
		return aResult

	func ListReversed(paList)
		aResult = []
		nLen = len(paList)
		for i = nLen to 1 step -1
			aResult + paList[i]
		next
		return aResult
