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

	func StzEngineMarshalList(_aList_)
		return StzEngineListMarshalFromRingList(_aList_)

	func StzEngineMarshalListValue(_aList_)
		pVal = StzEngineValueNewList()
		_nLen_ = len(_aList_)
		for _i_ = 1 to _nLen_
			item = _aList_[_i_]
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
				_aCopy_ = []
				_nItemLen_ = len(item)
				for _j_ = 1 to _nItemLen_
					_aCopy_ + item[_j_]
				next
				pSubVal = StzEngineMarshalListValue(_aCopy_)
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

		# Bulk engine->Ring unmarshal in ONE bridge call (engine builds the
		# whole Ring structure, nested lists included). The old per-item Ring
		# loop below made millions of FFI round-trips and was O(n)-with-huge-
		# constant at scale; kept only as a defensive fallback.
		_aFastEcf_ = StzEngineListContentToRingList(pList)
		if isList(_aFastEcf_)
			return _aFastEcf_
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
	_aResult_ = []
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
		if isString(paList[_i_])
			_aResult_ + StzLower(paList[_i_])
		else
			_aResult_ + paList[_i_]
		ok
	next
	return _aResult_

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
	_nLen_ = len(paList)
	if _nLen_ < 2
		return :Unsorted
	ok

	_bAsc_ = 1
	_bDesc_ = 1
	_bAnyComparable_ = 0

	for _i_ = 1 to _nLen_ - 1
		if isNumber(paList[_i_]) and isNumber(paList[_i_+1])
			_bAnyComparable_ = 1
			if paList[_i_] > paList[_i_+1]
				_bAsc_ = 0
			ok
			if paList[_i_] < paList[_i_+1]
				_bDesc_ = 0
			ok
		but isString(paList[_i_]) and isString(paList[_i_+1])
			_bAnyComparable_ = 1
			if strcmp(paList[_i_], paList[_i_+1]) > 0
				_bAsc_ = 0
			ok
			if strcmp(paList[_i_], paList[_i_+1]) < 0
				_bDesc_ = 0
			ok
		# incomparable pair (mixed/list items): no ordering info, skip it
		ok
		if _bAsc_ = 0 and _bDesc_ = 0
			return :Unsorted
		ok
	next

	# No comparable adjacent pair -> no ordering established -> Unsorted.
	if _bAnyComparable_ = 0
		return :Unsorted
	ok
	if _bAsc_ = 1
		return :Ascending
	ok
	if _bDesc_ = 1
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

	_nLenList_ = len(paList)
	if _nLenList_ = 0
		return 0
	ok

	_nLenItems_ = len(paItems)
	if _nLenItems_ = 0
		return 0
	ok

	_bResult_ = 0
	for _i_ = 1 to _nLenItems_
		if DeepContainsCS(paList, paItems[_i_], pCaseSensitive)
			_bResult_ = 1
			exit
		ok
	next

	return _bResult_

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

func @Map(_aList_, cFunc)

	if CheckParams()
		if not isList( _aList_ )
			raise( "Incorrect param type! aList must be a list.")
		ok
		If not @IsFunction(cFunc)
			raise("Incorrect param type! cFunc must be a function.")
		ok
	ok

	_aListCopy_ = _aList_
	_nLen_ = len(_aList_)

	for _i_ = 1 to _nLen_
		_aListCopy_[_i_] = call cFunc(_aListCopy_[_i_])
	next
	return _aListCopy_

# Executing a function on each item of the listinorder to filter items

func @Filter(_aList_, cFunc)
	if CheckParams()
		if not isList( _aList_ )
			raise( "Incorrect param type! aList must be a list.")
		ok
		If not @IsFunction(cFunc)
			raise("Incorrect param type! cFunc must be a function.")
		ok
	ok

	_nLen_ = len(_aList_)
	_aList2_ = []

	for _i_ = 1 to _nLen_

		if call cFunc(_aList_[_i_])
			_aList2_ + _aList_[_i_]
		ok
	next

	return _aList2_


# Applying function cFunc to each result xResult from a list aList,
# and return an accumulated value xResult

func @Reduce(_aList_, cFunc, _xInitial_)

	if CheckParams()
		if not isList( _aList_ )
			raise( "Incorrect param type! aList must be a list.")
		ok
		If not @IsFunction(cFunc)
			raise("Incorrect param type! cFunc must be a function.")
		ok
	ok

	_nNthElement_ = 0
	_xNthElement_ = NULL
	_nStart_ = 1
	_nLength_ = 0
	_sNthElementType_ = NULL
	_sElementType_ = NULL


	_nLength_ = Len(_aList_)



	if IsNULL(_xInitial_)
		// If the list is non-empty, then default xInitial to its first element
		if _nLength_ > 0
			_xInitial_ = _aList_[1]
			_nStart_ = 2
			_sElementType_ = type(_xInitial_)
		else
			raise("if xInitial is NULL, then Reduce() requires a non-empty list aList!")
		Ok
	else
		// If the List doesn't have at least one member, then return xInitial
		if _nLength_ < 1
			_xResult_ = _xInitial_
			return _xResult_
		Ok
	Ok

	_sElementType_ = type(_xInitial_)
	_xResult_ = _xInitial_

	// Loop through all of aList, and return an accumulated value after successfully applying cFunc to each result.
	for nElement = _nStart_ to _nLength_

		_xNthElement_ = _aList_[nElement]
		_sNthElementType_ = type(_xNthElement_)

		If not _sNthElementType_ = _sElementType_
			raise( "At least one of the elements in aList is " + _sNthElementType_ + ".  It should be " + _sElementType_ )
		ok

		_xResult_ = call cFunc(_xResult_, _xNthElement_)
	next

	return _xResult_

#===

func ListEqualsCS(paList1, paList2, pCaseSensitive)
	return StzListQ(paList1).IsEqualToCS(paList2, pCaseSensitive)

	func ListEquals(paList1, paList2)
		return StzListQ(paList1).IsEqualTo(paList2)

func Listify(cStrInList)
	if isList(cStrInlist)
		return StzListQ(cStrInlist).Listified()
	ok

	_oTempStr_ = new stzString(cStrInList)
	if _oTempStr_.IsListInString()
		_cCode_ = '_aResult_ = ' + _oTempStr_.Content()
		eval(_cCode_)
		return _aResult_
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

func FirstN(_n_, _aList_)
	if CheckParams()
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! aList must be a list.")
		ok

		if NOT isList(_aList_)
			StzRaise("Incorrect param type! aList must be a list.")
		ok
	ok

	_aResult_ = []
	_nLen_ = len(_aList_)
	if _n_ >= _nLen_
		return _aList_
	ok

	for _i_ = 1 to _n_
		_aResult_ + _aList_[_i_]
	next

	return _aResult_

	#< @FunctionAlternativeForms

	func FirstNItems(_aList_)
		return FirstN(_n_, _aList_)

	func @FirstN(_n_, _aList_)
		return FirstN(_n_, _aList_)

	func @FirstNItems(_n_, _aList_)
		return FirstN(_n_, _aList_)

	func NFirst(_n_, _aList_)
		return FirstN(_n_, _aList_)

	#--

	func NFirstItems(_aList_)
		return FirstN(_n_, _aList_)

	func @NFirst(_n_, _aList_)
		return FirstN(_n_, _aList_)

	func @NFirstItems(_n_, _aList_)
		return FirstN(_n_, _aList_)

	#>

func First3(_aList_)
	return FirstN(3, _aList_)

	#< @FunctionAlternativeForms

	func First3Items(_aList_)
		return First3(_aList_)

	func @First3(_aList_)
		return First3(_aList_)

	func @First3Items(_aList_)
		return First3(_aList_)

	func 3First(_aList_)
		return First3(_aList_)

	#--

	func 3FirstItems(_aList_)
		return First3(_aList_)

	func @3First(_aList_)
		return FirstN(_n_, _aList_)

	func @3FirstItems(_aList_)
		return First3(_aList_)

	#>

#===

func Slice(pStrOrList, _n1_, n2)
	if CheckParams()
		if NOT (isString(pStrOrList) or isList(pStrOrList))
			StzRaise("Incorrect param type! pStrOrList must be a string or list.")
		ok
	ok

	if isString(pStrOrList)
		return StkStringQ(pStrOrList).section(_n1_, n2)
	else
		_aResult_ = []
		_nLen_ = len(pStrOrList)

		for @i = _n1_ to n2
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

	_aResult_ = []

	for _i_ = 1 to nTimes
		_aResult_ + value
	next

	return _aResult_

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

	_acResult_ = []

	_nLen_ = len(paListOfThings)
	for _i_ = 1 to _nLen_
		_acResult_ + Q(paListOfThings[_i_]).SortingOrder()
	next

	return _acResult_

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

	_nLen_ = len(paLists)

	for _i_ = 1 to _nLen_
		ring_insert(paLists[_i_], len(paLists[_i_]), 1)
	next

	SortListsOn(paLists, 1)

	for _i_ = 1 to _nLen_
		ring_remove(paLists[_i_], 1)
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

	_aCols_ = StzListOfListsQ(paListOfLists).Cols()
	_nLen_ = len(_aCols_)

	_acColsStringified_ = []
	for _i_ = 1 to _nLen_
		_acColsStringified_ + ListStringifyXT(_aCols_[_i_])
	next

	_oLoL_ = StzListOfListsQ([])

	for _i_ = 1 to _nLen_
		_oLoL_.AddCol(_acColsStringified_[_i_])
	next

	_aResult_ = _oLoL_.Content()

	return _aResult_


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

	_nLen_ = len(paList)

	_nMaxSize_ = 0
	_nMaxLeft_ = 0
	_nMaxRight_ = 0

	_anNumbersPos_ = []

	for _i_ = 1 to _nLen_
		if isNumber(paList[_i_])

			_anNumbersPos_ + _i_

			_cNumber_ = ""+ paList[_i_]

			_nSize_ = StzLen(_cNumber_)
			if _nSize_ > _nMaxSize_
				_nMaxSize_ = _nSize_
			ok

			_nDotPos_ = ring_substr1( _cNumber_, "." )

			if _nDotPos_ = 0
				_nLenLeft_ = _nSize_
				_nLenRight_ = 0

			else
				_nLenLeft_ = _nDotPos_ - 1
				_nLenRight_ = _nSize_ - _nDotPos_

			ok

			if _nLenLeft_ > _nMaxLeft_
				_nMaxLeft_ = _nLenLeft_
			ok

			if _nLenRight_ > _nMaxRight_
				_nMaxRight_ = _nLenRight_
			ok
		ok
	next

	_nHowManyNumbers_ = len(_anNumbersPos_)

	# The numbers without decimal part are adjusted
	# first, by adding a dot and some 0s to them,
	# and then the numbers with dots are adjusted

	for _i_ = 1 to _nHowManyNumbers_
		_nPos_ = _anNumbersPos_[_i_]

		# Early check

		if paList[_nPos_] = 0
			paList[_nPos_] = "0."
			loop
		ok

		# In case where the number is not a zero

		_cNumber_ = ""+ paList[_nPos_]
		_nLenNumber_ = StzLen(_cNumber_)
		_nPosDot_ = ring_substr1(_cNumber_, ".")
			
		if _nPosDot_ = 0
				
			_nAddLeft_ = _nMaxLeft_ - _nLenNumber_
			_nAddRight_ = _nMaxRight_

			_cExtLeft_ = ""
			_cExtRight_ = ""

			for _j_ = 1 to _nAddLeft_
				_cExtLeft_ += "0"
			next

			for _j_ = 1 to _nAddRight_
				_cExtRight_ += "0"
			next

			_cNumber_ = _cExtLeft_ + _cNumber_ + "." + _cExtRight_

		else
			_nAddLeft_ = _nMaxLeft_ - (_nPosDot_ - 1)
			_nAddRight_ = _nMaxRight_ - (_nLenNumber_ - _nPosDot_)

			_cExtLeft_ = ""
			_cExtRight_ = ""

			for _j_ = 1 to _nAddLeft_
				_cExtLeft_ += "0"
			next

			for _j_ = 1 to _nAddRight_
				_cExtRight_ += "0"
			next

			_cNumber_ = _cExtLeft_ + _cNumber_ + _cExtRight_

		ok

		paList[_nPos_] = _cNumber_

	next

	# Now we stringify the items of the column that
	# are not numbers (usning @@() ~> ComputableForm())

	for _i_ = 1 to _nLen_
		if NOT isNumber(paList[_i_])
			paList[_i_] = @@(paList[_i_])
			loop
		ok

	next

	return paList

	func @ListStringifyXT(paList)
		return ListStringifyXT(paList)

func SortListsOn(paLists, _n_)

	# Sorts a list of lists on a given column by justifying
	# all the lists and stringifying any list item inf the
	# nth column ~> Makes it possible to internally use the
	# standard Ring sort(aListOfLits, ncol) function.

	if CheckingParam()

		# Swich params if necessary

		if isNumber(paLists) and isList(_n_)
			_temp_ = paLists
			paLists = _n_
			_n_ = _temp_
		ok

		if NOT ( isList(paLists) and @IsListOfLists(paLists) )
			StzRaise("Incorrect param type! paList must be a list of lists.")
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	# Early check 1 : If there is no lists or only one list

	_nLen_ = len(paLists)
	if _nLen_ = 0
		return []

	but _nLen_ = 1
		return paLists
	ok

	# Early check 2 : If One of the lists is empty

	for _i_ = 1 to _nLen_
		if len(paLists[_i_]) = 0
			return @SortList(paLists)
		ok
	next

	# Sort using the engine

	_oTemp_ = new stzList(paLists)
	pList = _oTemp_._EngineListFromContent()
	StzEngineListSortOn(pList, _n_)
	_aResult_ = StzEngineContentFromList(pList)
	StzEngineListFree(pList)
	return _aResult_


	#< @FunctionAlternativeForms

	func @SortListsOn(paLists, _n_)
		return SortListsOn(paLists, _n_)

	func SortOn(paLists, _n_)
		return SortListsOn(paLists, _n_)

	func @SortOn(paLists, _n_)
		return SortListsOn(paLists, _n_)

	#>

func SortOnUp(_n_, paList)
	return SortOn(_n_, paList)

	func @SortOnUp(_n_, paList)
		return SortOnUp(_n_, paList)

func SortOnDown(_n_, palist)
	return reverse(SortOn(_n_, paList))

	func @SortOnDown(_n_, palist)
		return SortOnDown(_n_, palist)

func SortOnXT(_n_, paList, pcDirection)
	if CheckParams()
		if isList(pcDirection) and IsDirectionOrGoingNamedParamList(pcDirection)
			pcDirection = pcDirection[2]
		ok
	ok

	if NOT isString(pcDirection)
		StzRaise("Incorrect param type! pcDirection must be a string.")
	ok

	if not StzFindFirst([ "ascending", "descending", "up", "down" ], StzLower(pcDirection))
		StzRaise("Incorrect param value! pcDirection can be :Forward or :Backward.")
	ok

	if pcDirection = "ascending" or pcDirection = "up"
		return SortOn(_n_, paList)
	else
		return reverse( SortOn(_n_, paList) )
	ok

	func @SortOnXT(_n_, paList, pcDirection)
		return SortOnXT(_n_, paList, pcDirection)

func @SortList(paList)

	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nLen_ = len(paList)
	if _nLen_ = 0
		return []
	ok

	_oTemp_ = new stzList(paList)
	return _oTemp_.Sorted()


	func SortList(paList)
		return @SortList(paList)

func @Sort(p)
	if NOT (isString(p) or isList(p))
		StzRaise("Incorrect param type! p must be a string or list.")
	ok

	if isString(p)
		_oStr_ = new stzString(p)
		_aChars_ = _oStr_.Chars()
		_oTemp_ = new stzList(_aChars_)
		return _oTemp_.Sorted()

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

	_nLen_ = len(paList)

	_anFirst_ = []
	for _i_ = 1 to _nLen_
		_anFirst_ + paList[_i_][1]
	next

	_anSecond_ = []
	for _i_ = 1 to _nLen_
		_anSecond_ + paList[_i_][2]
	next

	_oList1_ = new stzList(_anFirst_)
	_oList2_ = new stzList(_anSecond_)

	if ( _oList1_.IsSortedInAscending() and _oList2_.IsSortedInAscending() ) or
	   ( _oList2_.IsSortedInDescending() and _oList2_.IsSortedInDescending() )

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

	_nLen_ = len(paList)

	_anFirst_ = []
	for _i_ = 1 to _nLen_
		_anFirst_ + paList[_i_][1]
	next

	_anSecond_ = []
	for _i_ = 1 to _nLen_
		_anSecond_ + paList[_i_][2]
	next

	_oList1_ = new stzList(_anFirst_)
	_oList2_ = new stzList(_anSecond_)

	if _oList1_.IsSortedInAscending() and _oList2_.IsSortedInAscending()
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

	_nLen_ = len(paList)

	_anFirst_ = []
	for _i_ = 1 to _nLen_
		_anFirst_ + paList[_i_][1]
	next

	_anSecond_ = []
	for _i_ = 1 to _nLen_
		_anSecond_ + paList[_i_][2]
	next

	_oList1_ = new stzList(_anFirst_)
	_oList2_ = new stzList(_anSecond_)

	if _oList1_.IsSortedInDescending() and _oList2_.IsSortedInDescending()
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

	_nLen_ = len(paList)
	if _nLen_ = 0
		return 0   # empty is NOT a list-of-numbers (monolith semantics)
	ok

	for _i_ = 1 to _nLen_
		if not isNumber(paList[_i_])
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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsDecimalNumber(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfDecimalNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsBinaryNumber(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfBinaryNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsOctalNumber(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfOctalNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsHexNumber(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfHexNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	if _nLen_ = 0
		return 0   # empty is NOT a list-of-strings (monolith semantics)
	ok

	for _i_ = 1 to _nLen_
		if NOT isString(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStrings(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)

	for _i_ = 1 to _nLen_
		if NOT isList(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsHybridList(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfHybridLists(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)

	for _i_ = 1 to _nLen_
		if NOT isObject(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfObjects(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(pacList)
	for _i_ = 1 to _nLen_
			if Not IsChar(pacList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfChars(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsPair(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfPairs(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfPairsOfNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_


func IsListOfListsOfPairsOfStrings(paList)
	if NOT isList(paList)
		return 0
	ok

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfPairsOfStrings(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_


func IsListOfListsOfPairsOfLists(paList)
	if NOT isList(paList)
		return 0
	ok

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfPairsOfLists(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

func IsPairOfPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	if IsPair(paList[_i_][1]) and  IsPair(paList[2])
		return 1
	else
		return 0
	ok


func IsListOfPairsOfPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsPairOfPairs(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

func IsListOfListsOfPairsOfPairs(paList)
	if NOT isList(paList)
		return 0
	ok

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfPairsOfPairs(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_


func IsListOfListsOfPairsOfObjects(paList)
	if NOT isList(paList)
		return 0
	ok

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfPairsOfObjects(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_


func IsListOfSets(paList)
	if NOT isList(paList)
		return 0
	ok

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsSet(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfSets(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsHashList(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfHashLists(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsGrid(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfGrids(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfTables(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsTree(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfTrees(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzNumber(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzDecimalNumber(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzDecimalNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzBinaryNumber(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzBinaryNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzOctalNumber(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzOctalNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if NOT IsStzHexNumber(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzHexNumbers(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzString(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzStrings(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzList(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzLists(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzObject(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzObjects(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzChar(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzChars(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzPair(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzPairs(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzSet(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzSets(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzHashList(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzHashLists(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzGrid(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzGrids(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzTable(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzTables(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsStzTree(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_bResult_ = 1
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
			if Not IsListOfStzTrees(paList[_i_])
				_bResult_ = FALSE
				exit
			ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	if _nLen_ = 0
		return 0
	but _nLen_ = 1
		return 1
	ok

	_aStzObjects_ = []
	for _i_ = 1 to _nLen_
		aStzObects + Q(paList[_i_])
	next

	_bResult_ = 1
	for _i_ = 2 to _nLen_
		if NOT paList[_i_].IsEqualToCS(paList[1], pCaseSensitive)
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

	func IsUniformList(paList)
		return IsUniformListCS(paList, 1)


func IsDeepList(paList) // Contains at least an inner list
	if NOT isList(paList)
		return 0
	ok

	_bResult_ = 0
	_nLen_ = len(paList)

	for _i_ = 1 to _nLen_
		if isList(paList[_i_])
			_bResult_ = 1
			exit
		ok
	next

	return _bResult_


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

	_nLen_ = len(paList)
	if _nLen_ < 1
		return _FALSE
	ok

	_bResult_ = 1
	_acTypes_ = []

	for _i_ = 1 to _nLen_
		_acTypes_ + type(paList[_i_])
	next

	if len( U(_acTypes) ) != _nLen_
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

	_nLen_ = len(paList)
	if _nLen_ < 1
		return _FALSE
	ok

	_bResult_ = 1
	_acTypes_ = []

	for _i_ = 1 to _nLen_
		_acTypes_ + type(paList[_i_])
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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsBit(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsBoolean(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsLetter(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsQByteslist(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsStzByte(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

func IsListOfStzListOfBytes(paList)
	if NOT ( isList(paList) and IsListOfNumbers(paList) )
		return 0
	ok

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsListOfStzBytes(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT (isNumber(paList[_i_]) or isString(paList[_i_]))
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	if _nLen_ < 2
		return 0
	ok

	_acTypes_ = []
	for _i_ = 1 to _nLen_
		_acTypes_ + type(paList[_i_])
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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT (isString(paList[_i_]) or isPairOfStrings(paList[_i_]))
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT (isNumber(paList[_i_]) or isPairOfNumbers(paList[_i_]))
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT (isList(paList[_i_]) or IsPairOfLists(paList[_i_]))
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT (isObject(paList[_i_]) or IsPairOfobjects(paList[_i_]))
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfStrings(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfNumbers(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfSections(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfLists(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfObjects(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfStzObjects(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_
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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfStzNumbers(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfStzStings(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_


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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfStzLists(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfNumberAndString(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfStringAndNumber(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfNumberAndList(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfListAndNumber(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfNumberAndObject(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfObjectAndNumber(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfStringAndList(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfListAndString(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfStringAndObject(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfObjectAndString(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfListAndObject(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT IsPairOfChars(paList[_i_])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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

	_nLen_ = len(paList)
	if _nLen_ = 0
		return 0
	ok

	_bResult_ = 1

	for _i_ = 1 to _nLen_
		if NOT ( isString(paList[_i_]) or @IsPairOfStrings(paList[_i_]) )
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

	func @IsListOfStringsOrPairsOfStrings(paList)
		return IsListOfStringsOrPairsOfStrings(paList)

func IsListOfListsOfSameSize(paList)
	if NOT ( isList(paList) and IsListOfLists(paList) )
		return 0
	ok

	_nLen_ = len(paList)
	_anSizes_ = []
	for _i_ = 1 to _nLen_
		_nLenList_ = len(paList[_i_])
		if StzFindFirst(_anSizes_, _nLenList_)
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
	_bResult_ = StzStringQ(pcStr).IsListInString()
	return _bResult_

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

	_oList_ = new stzList(paNamed[2])
	_oList_.SetName(paNamed[1])
	return _oList_

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

	_nLen_ = len(paList)
	_anResult_ = []

	for _i_ = 1 to _nLen_
		if isNumber(paList[_i_])
			_anResult_ + paList[_i_]
		ok
	next

	return _anResult_


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

	_nLen_ = len(paList)
	_aResult_ = []
	_aTemp_ = []

	for _i_ = 1 to _nLen_
		if isList(paList[_i_])
			_aTemp_ = Flatten(paList[_i_]) # A recursive call
			_nLenTemp_ = len(_aTemp_)

			for _j_ = 1 to _nLenTemp_
				_aResult_ + _aTemp_[_j_]
			next
		else
			_aResult_ + paList[_i_]
		ok
	next

	return _aResult_

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
			_oTemp_ = new stzList(p)
			p = _oTemp_.Reversed()
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
	_oTempList_ = new stzList(paList)
	return _oTempList_.UpdateLastItem(pValue)

func FirstListIn(paList)
	_oTempList_ = new stzList(paList)
	return LastItemIn( _oTempList_.WalkUntilItemIsList() )

func GenerateListAccessCode_FromNameAndPath(pcListName, paPath)
	// Warining: aPath must contain only numbers!!!
	_cCode_ = pcListName
	_nPath1Len_ = len(paPath)
	for _iLoopPath1_ = 1 to _nPath1Len_
		_n_ = paPath[_iLoopPath1_]
		_cCode_ += ("["+ _n_ + ']')
	next

	return _cCode_

func ListItemsAreAllStrings(paList)
	_oTempList_ = new stzList(paList)
	return _oTempList_.ItemsAreAllStrings()

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

	_aResult_ = []
	_aOnObjects21_ = paOnObjects[2]
	_nOnObjects21Len_ = len(_aOnObjects21_)
	for _iLoopOnObjects21_ = 1 to _nOnObjects21Len_
		_cObjName_ = _aOnObjects21_[_iLoopOnObjects21_]
		_cCode_ = "aResult + " + _cObjName_ + "." + pcMethod
		eval(_cCode_)
	next
	return _aResult_

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
	_nLen_ = len(paValues)
	if _nLen_ < 2
		return 1
	ok

	# NAMED objects compare by NAME (the "named objects equality"
	# narrative): when every value is a named Softanza object, the
	# names decide.
	_bAllNamed_ = 1
	for _k = 1 to _nLen_
		if NOT isObject(paValues[_k])
			_bAllNamed_ = 0
			exit
		ok
		_cNm_ = ""
		try
			_cNm_ = paValues[_k].ObjectName()
		catch
			_bAllNamed_ = 0
			exit
		done
		if NOT (isString(_cNm_) and _cNm_ != "" and _cNm_ != "@noname")
			_bAllNamed_ = 0
			exit
		ok
	next
	if _bAllNamed_ = 1
		_cFirstNm_ = paValues[1].ObjectName()
		for _k = 2 to _nLen_
			if NOT (paValues[_k].ObjectName() = _cFirstNm_)
				return 0
			ok
		next
		return 1
	ok

	_bCaseSensitive_ = CaseSensitive(pCaseSensitive)
	for _k = 2 to _nLen_
		if _bCaseSensitive_
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

	_nLen_ = len(paValues)
	if _nLen_ = 0
		return 0
	but _nLen_ = 1
		return 1
	ok

	# Doing the job

	_bResult_ = 1

	if IsNumber(paValues[1])

		for _i_ = 2 to _nLen_
			if paValues[_i_] != paValues[1]
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

	but isString(paValues[1])
		if pCaseSensitive = 0
			for _i_ = 1 to _nLen_
				paValues[_i_] = StzLower(paValues[_i_])
			next
		ok

		for _i_ = 2 to _nLen_
			if paValues[_i_] != paValues[1]
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

	but isObject(paValues[1])
		return @AreEqualObjects(paValues)

	else

		for _i_ = 2 to _nLen_

			if NOT Q(paValues[_i_]).IsEqualToCS(paValues[1], pCaseSensitive)
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

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

	_nLen_ = len(paItems)
	if _nLen_ = 0
		return 0
	but _nLen_ = 1
		return 1
	ok

	# Case nLen >= 2

	_bResult_ = 1
	for _i_ = 2 to _nLen_
		if ring_type( paItems[1] ) != ring_type( paItems[_i_] )
			_bResult_ = 0
			exit
		ok
	next
	return _bResult_

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

	_bResult_ = 1
	_nItemsLen_ = len(paItems)
	for _i_ = 2 to _nItemsLen_
		_bOk_ = Q( @@( paItems[_i_] ) ).IsEqualTo( @@( paItems[1] ) )
		if NOT _bOk_
			_bResult_ = 0
			exit
		ok
	next
	return _bResult_

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
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
		if NOT isNumber(paList[_i_])
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
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
		if NOT isString(paList[_i_])
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
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
		if NOT isList(paList[_i_])
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
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
		if NOT isObject(paList[_i_])
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
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
		if NOT isNull(paList[_i_])
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
	_bResult_ = 1
	_nList2Len_ = len(paList)
	for _iLoopList2_ = 1 to _nList2Len_
		item = paList[_iLoopList2_]
		if isString(item) and isNull(item)
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

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
	_bResult_ = 1
	_nList1Len_ = len(paList)
	for _iLoopList1_ = 1 to _nList1Len_
		item = paList[_iLoopList1_]
		if isString(item)
			_bResult_ = 0
			exit
		ok
	next
	
	return _bResult_

	func @NoOneOfTheseIsAString(paList)
		return NoOneOfTheseIsAString(paList)

func List@(paList)
	if isList(paList)
		return ComputableForm(paList)
	ok

func ListFindAll(paList, p)
	_aResult_ = []
	_nLen_ = len(paList)
	for _i_ = 1 to _nLen_
		if BothAreEqual(paList[_i_], p)
			_aResult_ + _i_
		ok
	next
	return _aResult_

func ListOfNTimes(_n_, pItem)
	_aResult_ = []
	for _i_ = 1 to _n_
		_aResult_ + pItem
	next
	return _aResult_

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

	_nLen_ = len(paList)
	_aResult_ = []

	for _i_ = 1 to _nLen_
		if isString(paList[_i_])
			_aResult_ + palist[_i_]
		ok
	next

	return _aResult_

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

	_nLen_ = len(paList)
	_aResult_ = []

	for _i_ = 1 to _nLen_
		if isList(paList[_i_])
			_aResult_ + palist[_i_]
		ok
	next

	return _aResult_

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

	_nLen_ = len(paList)
	_aResult_ = []

	for _i_ = 1 to _nLen_
		if isObject(paList[_i_])
			_aResult_ + palist[_i_]
		ok
	next

	return _aResult_

	#< @FunctionAlternativeForms

	func @ObjectsIn(paList)
		return Objects(paList)

	#>

#===

func ListContainsCS(paList, pItem, pCaseSensitive)
	_nPos_ = @FindFirstCS(paList, pItem, pCaseSensitive)
	if _nPos_ > 0
		return 1
	else
		return 0
	ok

	func @ListContainsCS(paList, pItem, pCaseSensitive)
		return ListContainsCS(paList, pItem, pCaseSensitive)

#--

func ListContainsOneOfTheseCS(paList, paItems, pCaseSensitive)
	_nLen_ = len(paItems)
	_bResult_ = FALSE

	for _i_ = 1 to _nLen_
		if ListContainsCS(paList, paItems[_i_])
			_bResult_ = TRUE
			exit
		ok
	next

	return _bResult_

	func @ListContainsOneOfTheseCS(paList, paItems, pCaseSensitive)
		return ListContainsOneOfTheseCS(paList, paItems, pCaseSensitive)

func ListContainsOneOfThese(paList, paItems)
	return ListContainsOneOfTheseCS(paList, paItems, 1)

	func @ListContainsOneOfThese(paList, paItems)
		return SListContainsOneOfThese(paList, paItems)

#===

func ListCountCS(_aList_, pItem, pCaseSensitive)
	_nResult_ = StzListQ(_aList_).FindAllCS(_aList_, pItem, pCaseSensitive)

func ListCount(_aList_, pItem)
	return ListCountCS(_aList_, pItem, pCaseSensitive)


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


func @FindAll_NbrOrStr(_aList_, pItem)
	return @FindAllCS_NbrOrStr(_aList_, pItem, 1)


#---

func @FindFirstCS(_aList_, pStrOrNbr, pCaseSensitive)
	_nResult_ = @FindNthSTCS(_aList_, 1, pStrOrNbr, 1, pCaseSensitive)
	return _nResult_

	#< @FunctionAlternativeForms

	func FindFirstCS(_aList_, pStrOrNbr, pCaseSensitive)
		return @FindFirstCS(_aList_, pStrOrNbr, pCaseSensitive)

	#>

func @FindFirst(_aList_, pStrOrNbr)
	return @FindFirstCS(_aList_, pStrOrNbr, 1)

	#< @FunctionAlternativeForms

	func FindFirst(_aList_, pStrOrNbr)
		return @FindFirst(_aList_, pStrOrNbr)


	#>

#--

func @FindLastCS(_aList_, pStrOrNbr, pCaseSensitive)
	_nResult_ = len(_aList_) - @FindFirstCS( reverse(_aList_), pStrOrNbr, pCaseSensitive) + 1
	return _nResult_

	#< @FunctionAlternativeForms

	func FindLastCS(_aList_, pStrOrNbr, pCaseSensitive)
		return @FindLastCS(_aList_, pStrOrNbr, pCaseSensitive)

	#>

func @FindLast(_aList_, pStrOrNbr)
	return @FindLastCS(_aList_, pStrOrNbr, 1)

	#< @FunctionAlternativeForms

	func FindLast(_aList_, pStrOrNbr)
		return @FindLast(_aList_, pStrOrNbr)

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

	_nLen_ = len(_aListCopy_)
	_nPos_ = -1
	_n_ = 0

	while 1
		try
			_nPos_ = find(_aListCopy_, pItem)
		catch
			return -1
		done

		if _nPos_ = 0
			return 0
		ok

		_n_++
		if _n_ = nth
			exit
		ok

		_aListCopy_[_nPos_] += (""+ _aListCopy_[_nPos_]+1)
		
	end

	return _nPos_


	func @FindNthCS(_aList_, nth, pItem, pCaseSensitive)
		return @FindNthOccurrenceCS(_aList_, nth, pItem, pCaseSensitive)

func @FindNthOccurrence(_aList_, nth, pItem)
	return @FindNthOccurrenceCS(_aList_, nth, pItem, 1)

	func @FindNth(_aList_, nth, pItem)
		return @FindNthOccurrence(_aList_, nth, pItem)

#--

func @FindNthSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	if CheckingParams()
		if NOT isList(_aList_)
			StzRaise("Incorrect param type! aList must be a list.")
		ok

		if NOT isNumber(nth)
			StzRaise("Incorrect param type! nth must be a number.")
		ok

		if NOT (isString(pItem) or isNumber(pItem))
			return -1
		ok

		if isList(_nStart_) and IsStartingAtNamedParamList(_nStart_)
			_nStart_ = _nStart_[2]
		ok

		if NOT isNumber(_nStart_)
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

		_aList_ = ListLowercased(_aList_)
	ok

	_nLen_ = len(_aList_)
	_aContent_ = []

	for _i_ = _nStart_ to _nLen_
		_aContent_ + _aList_[_i_]
	next

	_nPos_ = -1
	_n_ = 0

	while 1
		try
			_nPos_ = find(_aContent_, pItem)
		catch
			return -1
		done

		if _nPos_ = 0
			exit
		ok

		_n_++
		if _n_ = nth
			exit
		ok

		_aContent_[_nPos_] += (""+ _aContent_[_nPos_]+1)
		
	end

	_nResult_ = 0

	if _nPos_ > 0

		_nResult_ = _nPos_ + _nStart_ - 1
	ok

	return _nResult_

	#< @FunctionAlternativeForms

	func FindNthSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return @FindNthSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func FindNthStartingAtCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return @FindNthSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func @FindNthStartingAtCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return @FindNthSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	#--

	func FindNthCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return @FindNthSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	#>

#-- CS

func @FindNthST(_aList_, nth, pItem, _nStart_)
	return @FindNthSTCS(_aList_, nth, pItem, _nStart_, 1)

	#< @FunctionAlternativeForms

	func FindNthST(_aList_, nth, pItem, _nStart_)
		return @FindNthST(_aList_, nth, pItem, _nStart_)

	func FindNthStartingAt(_aList_, nth, pItem, _nStart_)
		return @FindNthST(_aList_, nth, pItem, _nStart_)

	func @FindNthStartingAt(_aList_, nth, pItem, _nStart_)
		return @FindNthST(_aList_, nth, pItem, _nStart_)

	#--

	func FindNth(_aList_, nth, pItem, _nStart_)
		return @FindNthST(_aList_, nth, pItem, _nStart_)

	#>

#===

func FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	if CheckingParams() = 1
		if isList(_nStart_) and IsStartingAtNamedParamList(_nStart_)
			_nStart_ = _nStart_[2]
		ok
	ok

	return @FindNthSTCS(_aList_, nth, pItem, _nStart_+1, pCaseSensitive)

	#< @FunctionAlternativeForms

	def FindNextNthCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	def @FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	def @FindNextNthCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func @FindNthNextSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func @FindNextNthSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func FindNextNthSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func FindNthNextSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func FindNthNextStartingAtCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func FindNextNthStartingAtCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func @FindNextNthStartingAtCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func @FindNthNextStartingAtCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return FindNthNextCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	#>

#-- CS

func FindNthNext(_aList_, nth, pItem, _nStart_)
	return FindNthNextCS(_aList_, nth, pItem, _nStart_, 1)

	#< @FunctionAlternativeForms

	def FindNextNth(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	def @FindNthNext(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	def @FindNextNth(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	func @FindNthNextST(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	func @FindNextNthST(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	func FindNextNthST(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	func FindNthNextST(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	func FindNthNextStartingAt(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	func FindNextNthStartingAt(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	func @FindNextNthStartingAt(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	func @FindNthNextStartingAt(_aList_, nth, pItem, _nStart_)
		return FindNthNext(_aList_, nth, pItem, _nStart_)

	#>

#==

func @FindNextCS(_aList_, pItem, _nStart_, pCaseSensitive)
	return @FindNthNextSTCS(_aList_, 1, pItem, _nStart_, pCaseSensitive)

	func FindNextCS(_aList_, pItem, _nStart_, pCaseSensitive)
		return @FindNextCS(_aList_, pItem, _nStart_, pCaseSensitive)

	func FindNextSTCS(_aList_, pItem, _nStart_, pCaseSensitive)
		return @FindNextCS(_aList_, pItem, _nStart_, pCaseSensitive)

	func @FindNextSTCS(_aList_, pItem, _nStart_, pCaseSensitive)
		return @FindNextCS(_aList_, pItem, _nStart_, pCaseSensitive)

func @FindNext(_aList_, pItem, _nStart_)
	return @FindNextCS(_aList_, pItem, _nStart_, 1)

	func FindNext(_aList_, pItem, _nStart_)
		return @FindNext(_aList_, pItem, _nStart_)

	func FindNextST(_aList_, pItem, _nStart_)
		return @FindNext(_aList_, pItem, _nStart_)

	func @FindNextST(_aList_, pItem, _nStart_)
		return @FindNext(_aList_, pItem, _nStart_)

# Renders a stringified list-class key ("[ 1, 2, 3, 4, 5 ]") into its
# contiguous short form ("1:5") when the items are consecutive integers;
# otherwise returns the key unchanged. Used by ClassesSF / ClassifySF.

func _StzListKeyToShortForm(pcKey)
	_cSf_ = ring_trim(pcKey)
	if ring_left(_cSf_, 1) = "[" and ring_right(_cSf_, 1) = "]"
		_cSf_ = ring_trim(StzMid(_cSf_, 2, len(_cSf_) - 2))
	ok
	if _cSf_ = ""
		return pcKey
	ok
	_aSfParts_ = StzSplit(_cSf_, ",")
	_nSfN_ = len(_aSfParts_)
	_aSfNums_ = []
	for iSf = 1 to _nSfN_
		_cSfP_ = ring_trim(_aSfParts_[iSf])
		if NOT isNumber(0 + _cSfP_)
			return pcKey
		ok
		_aSfNums_ + (0 + _cSfP_)
	next
	if _nSfN_ < 2
		return pcKey
	ok
	_bSfContig_ = 1
	for iSf = 2 to _nSfN_
		if _aSfNums_[iSf] != _aSfNums_[iSf - 1] + 1
			_bSfContig_ = 0
			exit
		ok
	next
	if _bSfContig_
		return "" + _aSfNums_[1] + ":" + _aSfNums_[_nSfN_]
	ok
	return pcKey

# Collects every list-valued item at any depth, in depth-first pre-order.
# Ring objects are excluded naturally: isList() is false for an object.

func _StzCollectDeepLists(paList)
	_aCdlRes_ = []
	_nCdlLen_ = len(paList)
	for iCdl = 1 to _nCdlLen_
		if isList(paList[iCdl])
			_aCdlRes_ + paList[iCdl]
			_aCdlSub_ = _StzCollectDeepLists(paList[iCdl])
			_nCdlSub_ = len(_aCdlSub_)
			for jCdl = 1 to _nCdlSub_
				_aCdlRes_ + _aCdlSub_[jCdl]
			next
		ok
	next
	return _aCdlRes_

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

		_nLen_ = len(pListOrString)

		for _i_ = 1 to _nLen_
			if len(pListOrString[_i_]) = 0
				return 0
			ok
		next

		# Checking the columns one by one, and when we
		# find a column that is made of numbers and/or
		# strings and containing no dupplications, then
		# that column make the list of lists sortable

		_oLoL_ = new stzListOfLists(pListOrString)
		_nCols_ = _oLoL_.NumberOfCols()

		# Parsing all the columns one by one

		for _i_ = 1 to _nCols_

			# Assuming the current column is Ring sortable

			_bColSortable_ = 1

			# the column must contain only numbers and strings
			# and should not contain dupplicated items

			_aCol_ = _oLoL_.Col(_i_)

			_nLenCol_ = len(_aCol_)
			_aSeen_ = []

			for _j_ = 1 to _nLenCol_

				if NOT ( isString(_aCol_[_j_]) or isNumber(_aCol_[_j_]) )
					_bColSortable_ = 0
					exit
				else
					if StzFindFirst(_aSeen_, _aCol_[_j_]) = 0
						_aSeen_ + _aCol_[_j_]
					else
						_bColSortable_ = 0
						exit
					ok
				ok
			next

			if _bColSortable_ # We've got a ring-sortable column!
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

func IsRingSortableOn(paListOfLists, _n_)

	# In Ring, with the standard ring() function, to sort a list of
	# lists on a given column, that column must:

	# 1. the column of sort should have size as the first column
	# 2. be made of numbers or strings only (no lists or objects),
	# 3. must not contain dupllicated items (because in this case,
	#    the sorting result is not accurate - from Softanza point of view)

	if NOT ( isList(paListOfLists) and IsListOfLists(paListOfLists) )
		return 0
	ok

	if NOT isNumber(_n_)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	# Early check : case where at least one list is empty

	_nLen_ = len(paListOfLists)

	for _i_ = 1 to _nLen_
		if len(paListOfLists[_i_]) = 0
			return 0
		ok
	next

	# getting the items in the column n

	_oLoL_ = StzListOfListsQ(paListOfLists)
	_aCol_ = _oLoL_.Col(_n_)
	_nLen_ = len(_aCol_)

	# Early check: the column of sort should have
	# the same number of items as the first column

	if _n_ > 1
		_aCol1_ = _oLoL_.Col(1)
		_nLen1_ = len(_aCol1_)

		if _nLen_ != _nLen1_
			return 0
		ok
	ok

	_aSeen_ = []

	for _i_ = 1 to _nLen_
		if NOT ( isNumber(_aCol_[_i_]) or isString(_aCol_[_i_]) )
			return 0
		ok

		if StzFindFirst(_aSeen_, _aCol_[_i_]) = 0
			_aSeen_ + _aCol_[_i_]
		else
			return 0
		ok
	next

	return 1

	func @IsRingSortableOn(paListOfLists, _n_)
		return IsRingSortableOn(paListOfLists, _n_)
	
func Move(paList, _n1_, n2)

	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		if NOT isNumber(_n1_)
			StzRaise("Incorrect param type! n1 must be a number.")
		ok

		if NOT isNumber(n2)
			StzRaise("Incorrect param type! n2 must be a number.")
		ok
	ok

	item = paList[_n1_]
	ring_remove(paList, _n1_)
	_n_ = n2
	if _n1_ > n2
		_n_++
	ok
	ring_insert(paList, n2, item)
	return paList


	#< @FunctionAlternativeForms

	func @Move(paList, _n1_, n2)
		return Move(paList, _n1_, n2)

	func MoveItems(paList, _n1_, n2)
		return Move(paList, _n1_, n2)

	func @MoveItems(paList, _n1_, n2)
		return Move(paList, _n1_, n2)

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
	return new stzString( ComputableFormXT(pValue, _c_) )

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
Func generateCombinationsXT(paList, _nLen_, _nDepth_, _aCurrent_, _aResult_)
	if len(_aCurrent_) = _nDepth_
		_aResult_ + _aCurrent_
		return
	ok
	
	for _i_ = 1 to _nLen_
		_aCurrent_ + paList[_i_]
		generateCombinationsXT(paList, _nLen_, _nDepth_, _aCurrent_, _aResult_)
		del(_aCurrent_, len(_aCurrent_))
	next

# Function to generate all possible combinations including duplicates and inversions

Func CombinationsXT(_aList_, _n_)
	if CheckParams()
		if NOT isList(_aList_)
			StzRaise("Incorrect param type! aList must be a list.")
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	# Early check

	_nLen_ = len(_aList_)
	if _nLen_ = 0 or _n_ = 0
		return []

	but _nLen_ = 1 or _n_ = 1
		return _aList_
	ok

	# doing the job

	if _n_ > _nLen_
		StzRaise("Can't proceed! n must be lesser than the size of the list.")
	ok

	_aResult_ = []
	_aCurrent_ = []
	
	if _n_ > 0 and _n_ <= _nLen_
		generateCombinationsXT(_aList_, _nLen_, _n_, _aCurrent_, _aResult_)
	ok
	
	return _aResult_

	func @CombinationsXT(paList, _n_)
		return CombinationsXT(paList, _n_)

# Function to generate combinations without duplicates or inversions

func Combinations(_aList_, _n_)
	if CheckParams()
		if NOT isList(_aList_)
			StzRaise("Incorrect param type! aList must be a list.")
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	# Early check

	_nLen_ = len(_aList_)
	if _nLen_ = 0 or _n_ = 0
		return []

	but _nLen_ = 1 or _n_ = 1
		return _aList_
	ok

	# doing the job

	if _n_ > _nLen_
		StzRaise("Can't proceed! n must be lesser than the size of the list.")
	ok

	_aList_ = _aList_
	_aResult_ = []

	# Main loop for first element

	for @i = 1 to _nLen_ - _n_ + 1

		# Inner loop for remaining elements

		for @j = @i + 1 to _nLen_ - _n_ + 2
			_aCombination_ = []
			add(_aCombination_, _aList_[@i])

			# Additional loops for n > 2
			if _n_ > 2
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


	func @Combinations(_aList_, _n_)
		return Combinations(_aList_, _n_)

#===

func ListsHaveSameNumberOfItems(paList)

	if CheckParams()

		if NOT isList(paList)
			stzraise("Incorrect param type! paList must be alist.")
		ok

	ok

	_nLen_ = len(paList)

	if _nLen_ = 0
		StzRaise("Can't check inner lists! Because the list is empty.")
	ok

	_nLenTemp_ = 0

	for _i_ = 1 to _nLen_
		if isList(paList[_i_])
			_nLenList_ = len(paList[_i_])
			if _nLenTemp_ = 0
				_nLenTemp_ = _nLenList_
			else
				if _nLenList_ != _nLenTemp_
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

	_nLen_ = len(paList)
	if _nLen_ = 0
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
	_aCurrent_ = paList
	_nLen_ = len(pacKeys)
	
	for _i_ = 1 to _nLen_
		_cKey_ = pacKeys[_i_]
		
		# Check if current level is a list (can be traversed)
		if not isList(_aCurrent_)
			return FALSE
		ok
		
		# Try to find the key in current level
		_nPos_ = 0
		_nCurrentLen_ = len(_aCurrent_)
		
		for _j_ = 1 to _nCurrentLen_
			# Handle hashlist format [key, value]
			if isList(_aCurrent_[_j_]) and len(_aCurrent_[_j_]) >= 2
				if isString(_aCurrent_[_j_][1]) and StzLower(_aCurrent_[_j_][1]) = StzLower(_cKey_)
					_nPos_ = _j_
					exit
				ok
			ok
		next
		
		# If key not found at this level
		if _nPos_ = 0
			return FALSE
		ok
		
		# Move to the next level (the value of the found key)
		# Only do this if we're not at the last key
		if _i_ < _nLen_
			if isList(_aCurrent_[_nPos_]) and len(_aCurrent_[_nPos_]) >= 2
				_aCurrent_ = _aCurrent_[_nPos_][2]
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
		_nLen_ = len(paList)
		for _i_ = 1 to _nLen_
			if _StzItemEqTyped(paList[_i_], pVal) return TRUE ok
		next
		return FALSE

	#-- [[item, [positions...]], ...] in first-appearance order
	func _StzItemsWithPositions(_aContent_)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			_v_ = _aContent_[_i_]
			_nFound_ = 0
			_nR_ = len(_aRes_)
			for _j_ = 1 to _nR_
				if _StzItemEqTyped(_aRes_[_j_][1], _v_) _nFound_ = _j_ exit ok
			next
			if _nFound_ > 0
				add(_aRes_[_nFound_][2], _i_)
			else
				add(_aRes_, [ _v_, [_i_] ])
			ok
		next
		return _aRes_

	#-- [[item, count], ...] in first-appearance order (type-sensitive)
	func _StzItemsCount(_aContent_)
		_aWith_ = _StzItemsWithPositions(_aContent_)
		_aRes_ = []
		_nLen_ = len(_aWith_)
		for _i_ = 1 to _nLen_
			add(_aRes_, [ _aWith_[_i_][1], len(_aWith_[_i_][2]) ])
		next
		return _aRes_

	#-- first position whose item type-sensitively equals pItem (0 if none)
	func _StzFindFirstTyped(_aContent_, pItem)
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if _StzItemEqTyped(_aContent_[_i_], pItem) return _i_ ok
		next
		return 0

	#-- positions whose item is NOT a member of paItems (type-sensitive)
	func _StzFindAllExcept(_aContent_, paItems)
		_anRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT _StzHasItemTyped(paItems, _aContent_[_i_]) add(_anRes_, _i_) ok
		next
		return _anRes_

	#-- [[value, [repeat positions]], ...] for items occurring more than once
	#-- (repeat = every position after the first); first-appearance order
	func _StzFindDuplicatesOrigins(_aContent_)
		_aWith_ = _StzItemsWithPositions(_aContent_)
		_aRes_ = []
		_nLen_ = len(_aWith_)
		for _i_ = 1 to _nLen_
			_nP_ = len(_aWith_[_i_][2])
			if _nP_ > 1
				_aRep_ = []
				for _j_ = 2 to _nP_ add(_aRep_, _aWith_[_i_][2][_j_]) next
				add(_aRes_, [ _aWith_[_i_][1], _aRep_ ])
			ok
		next
		return _aRes_

	#-- content with the items at panPos (1-based) removed
	func _StzRemoveAtPositions(_aContent_, panPos)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT _StzHasItemTyped(panPos, _i_) add(_aRes_, _aContent_[_i_]) ok
		next
		return _aRes_

	#-- keep only items that ARE members of paItems (type-sensitive)
	func _StzKeepMembers(_aContent_, paItems)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if _StzHasItemTyped(paItems, _aContent_[_i_]) add(_aRes_, _aContent_[_i_]) ok
		next
		return _aRes_

	#-- drop the leading / trailing run equal to pItem
	func _StzRemoveLeadingRun(_aContent_, pItem)
		_nLen_ = len(_aContent_)
		_nStart_ = _nLen_ + 1
		_bDone_ = FALSE
		for _i_ = 1 to _nLen_
			if NOT _bDone_ and _StzItemEqTyped(_aContent_[_i_], pItem)
				# still in the leading run
			else
				_nStart_ = _i_
				_bDone_ = TRUE
				exit
			ok
		next
		_aRes_ = []
		for _i_ = _nStart_ to _nLen_ add(_aRes_, _aContent_[_i_]) next
		return _aRes_

	func _StzRemoveTrailingRun(_aContent_, pItem)
		_nLen_ = len(_aContent_)
		_nEnd_ = 0
		for _i_ = _nLen_ to 1 step -1
			if NOT _StzItemEqTyped(_aContent_[_i_], pItem)
				_nEnd_ = _i_
				exit
			ok
		next
		_aRes_ = []
		for _i_ = 1 to _nEnd_ add(_aRes_, _aContent_[_i_]) next
		return _aRes_

	#-- keep only items that occur more than once (remove the singletons)
	func _StzRemoveNonDuplicates(_aContent_)
		_aWith_ = _StzItemsWithPositions(_aContent_)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			_v_ = _aContent_[_i_]
			_nCnt_ = 0
			_nW_ = len(_aWith_)
			for _k_ = 1 to _nW_
				if _StzItemEqTyped(_aWith_[_k_][1], _v_) _nCnt_ = len(_aWith_[_k_][2]) exit ok
			next
			if _nCnt_ > 1 add(_aRes_, _v_) ok
		next
		return _aRes_

	#-- pick aAllPos[ panOcc[i] ] for each i (1-based, out-of-range skipped)
	func _StzPickPositions(panOcc, aAllPos)
		_aRes_ = []
		_nLen_ = len(panOcc)
		_nP_ = len(aAllPos)
		for _i_ = 1 to _nLen_
			if panOcc[_i_] >= 1 and panOcc[_i_] <= _nP_ add(_aRes_, aAllPos[ panOcc[_i_] ]) ok
		next
		return _aRes_

	#-- positions of items that are lists of exactly nWantLen elements
	func _StzFindListsOfLen(_aContent_, nWantLen)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if isList(_aContent_[_i_]) and len(_aContent_[_i_]) = nWantLen add(_aRes_, _i_) ok
		next
		return _aRes_

	func _StzItemsAtPos(_aContent_, panPos)
		_aRes_ = []
		_nLen_ = len(panPos)
		for _i_ = 1 to _nLen_ add(_aRes_, _aContent_[ panPos[_i_] ]) next
		return _aRes_

	#-- dedup a list structurally, first-appearance order
	func _StzUniqueItems(_aList_)
		_aRes_ = []
		_nLen_ = len(_aList_)
		for _i_ = 1 to _nLen_
			if NOT _StzHasItemTyped(_aRes_, _aList_[_i_]) add(_aRes_, _aList_[_i_]) ok
		next
		return _aRes_

	#-- [[value,[positions]],...] over the given positions, first-appearance
	func _StzGroupItemsAtPos(_aContent_, panPos)
		_aRes_ = []
		_nLen_ = len(panPos)
		for _i_ = 1 to _nLen_
			_v_ = _aContent_[ panPos[_i_] ]
			_nFound_ = 0
			_nR_ = len(_aRes_)
			for _j_ = 1 to _nR_
				if _StzItemEqTyped(_aRes_[_j_][1], _v_) _nFound_ = _j_ exit ok
			next
			if _nFound_ > 0
				add(_aRes_[_nFound_][2], panPos[_i_])
			else
				add(_aRes_, [ _v_, [ panPos[_i_] ] ])
			ok
		next
		return _aRes_

	#-- wrap each item as a 1-element list (scalar->[x], list->[firstElem])
	func _StzSinglified(_aContent_)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if isList(_aContent_[_i_])
				if len(_aContent_[_i_]) >= 1 add(_aRes_, [ _aContent_[_i_][1] ]) else add(_aRes_, []) ok
			else
				add(_aRes_, [ _aContent_[_i_] ])
			ok
		next
		return _aRes_

	#-- pad each non-pair item into a pair [item, NULL]; keep existing pairs
	func _StzPairified(_aContent_)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if isList(_aContent_[_i_]) and len(_aContent_[_i_]) = 2
				add(_aRes_, _aContent_[_i_])
			else
				add(_aRes_, [ _aContent_[_i_], NULL ])
			ok
		next
		return _aRes_

	#-- positions of items type-sensitively equal to pItem
	func _StzPositionsOf(_aContent_, pItem)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if _StzItemEqTyped(_aContent_[_i_], pItem) add(_aRes_, _i_) ok
		next
		return _aRes_

	#-- [[item, [positions]], ...] for each item in paItems (incl. empties)
	func _StzTheseItemsZ(_aContent_, paItems)
		_aRes_ = []
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			add(_aRes_, [ paItems[_i_], _StzPositionsOf(_aContent_, paItems[_i_]) ])
		next
		return _aRes_

	#-- distinct items whose occurrence count satisfies cOp vs nWant
	#-- (cOp: "ge" >= , "gt" > , "le" <= , "lt" < , "eq" ==); first-appearance
	func _StzItemsByCountOp(_aContent_, nWant, cOp)
		_aWith_ = _StzItemsWithPositions(_aContent_)
		_aRes_ = []
		_nLen_ = len(_aWith_)
		for _i_ = 1 to _nLen_
			_nC_ = len(_aWith_[_i_][2])
			_bKeep_ = FALSE
			switch cOp
			on "ge" _bKeep_ = (_nC_ >= nWant)
			on "gt" _bKeep_ = (_nC_ >  nWant)
			on "le" _bKeep_ = (_nC_ <= nWant)
			on "lt" _bKeep_ = (_nC_ <  nWant)
			on "eq" _bKeep_ = (_nC_ =  nWant)
			off
			if _bKeep_ add(_aRes_, _aWith_[_i_][1]) ok
		next
		return _aRes_

	func _StzAllEqualCS(_aContent_, pItem, _bCaseSensitive_)
		_nLen_ = len(_aContent_)
		if _nLen_ = 0 return TRUE ok
		for _i_ = 1 to _nLen_
			if isString(_aContent_[_i_]) and isString(pItem) and _bCaseSensitive_ = 0
				if StzLower(_aContent_[_i_]) != StzLower(pItem) return FALSE ok
			else
				if NOT _StzItemEqTyped(_aContent_[_i_], pItem) return FALSE ok
			ok
		next
		return TRUE

	func _StzAllSameType(_aContent_)
		_nLen_ = len(_aContent_)
		if _nLen_ <= 1 return TRUE ok
		_cT_ = type(_aContent_[1])
		for _i_ = 2 to _nLen_
			if type(_aContent_[_i_]) != _cT_ return FALSE ok
		next
		return TRUE

	func _StzAllEmptyLists(_aContent_)
		_nLen_ = len(_aContent_)
		if _nLen_ = 0 return FALSE ok
		for _i_ = 1 to _nLen_
			if NOT (isList(_aContent_[_i_]) and len(_aContent_[_i_]) = 0) return FALSE ok
		next
		return TRUE

	func _StzAllEqualTyped(_aContent_, pItem)
		_nLen_ = len(_aContent_)
		if _nLen_ = 0 return TRUE ok
		for _i_ = 1 to _nLen_
			if NOT _StzItemEqTyped(_aContent_[_i_], pItem) return FALSE ok
		next
		return TRUE

	#-- insert pItem after / before each position in panPos (1-based)
	func _StzInsertAfterPositions(_aContent_, panPos, pItem)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			add(_aRes_, _aContent_[_i_])
			if _StzHasItemTyped(panPos, _i_) add(_aRes_, pItem) ok
		next
		return _aRes_

	func _StzInsertBeforePositions(_aContent_, panPos, pItem)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if _StzHasItemTyped(panPos, _i_) add(_aRes_, pItem) ok
			add(_aRes_, _aContent_[_i_])
		next
		return _aRes_

	#-- TRUE if any item is of the given type tag (number/string/list/object)
	func _StzContainsType(_aContent_, cType)
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if _StzIsTypeTag(_aContent_[_i_], cType) return TRUE ok
		next
		return FALSE

	#-- how many DISTINCT members of paItems appear in aContent (type-sensitive)
	func _StzCountMembersPresent(_aContent_, paItems)
		_nCount_ = 0
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			if _StzHasItemTyped(_aContent_, paItems[_i_]) _nCount_++ ok
		next
		return _nCount_

	#-- WF (anonymous-function constraint) family. pFunc is a Ring function
	#-- f(item)->bool, called natively per item (no parsing, no eval). This is
	#-- the full-Ring-power escape hatch alongside the sandboxed W DSL.
	func _StzFindWF(_aContent_, pFunc)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if ( call pFunc(_aContent_[_i_]) ) add(_aRes_, _i_) ok
		next
		return _aRes_

	func _StzCheckWF(_aContent_, pFunc)
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT ( call pFunc(_aContent_[_i_]) ) return FALSE ok
		next
		return TRUE

	#-- keep only items for which pFunc is FALSE (remove the matching ones)
	func _StzRemoveWF(_aContent_, pFunc)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT ( call pFunc(_aContent_[_i_]) ) add(_aRes_, _aContent_[_i_]) ok
		next
		return _aRes_

	#-- replace each matching item with pNew
	func _StzReplaceWF(_aContent_, pFunc, pNew)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if ( call pFunc(_aContent_[_i_]) ) add(_aRes_, pNew) else add(_aRes_, _aContent_[_i_]) ok
		next
		return _aRes_

	#-- map: apply pFunc to every item, collecting the results
	func _StzMapWF(_aContent_, pFunc)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			add(_aRes_, call pFunc(_aContent_[_i_]))
		next
		return _aRes_

	#-- insert pItem after / before each matching item
	func _StzInsertAfterWF(_aContent_, pFunc, pItem)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			add(_aRes_, _aContent_[_i_])
			if ( call pFunc(_aContent_[_i_]) ) add(_aRes_, pItem) ok
		next
		return _aRes_

	func _StzInsertBeforeWF(_aContent_, pFunc, pItem)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if ( call pFunc(_aContent_[_i_]) ) add(_aRes_, pItem) ok
			add(_aRes_, _aContent_[_i_])
		next
		return _aRes_

	#-- Perform an action on the items matching a condition, both given as
	#-- anonymous functions: pCond(item)->bool selects, pAction(item)->newItem
	#-- transforms. Non-matching items are kept unchanged. (eval-free.)
	func _StzPerformWF(_aContent_, pCond, pAction)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if ( call pCond(_aContent_[_i_]) )
				add(_aRes_, call pAction(_aContent_[_i_]))
			else
				add(_aRes_, _aContent_[_i_])
			ok
		next
		return _aRes_

	#-- WF check restricted to the items at the given positions
	func _StzCheckItemsAtWF(_aContent_, panPos, pFunc)
		_nLen_ = len(panPos)
		_nC_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			p = panPos[_i_]
			if p >= 1 and p <= _nC_
				if NOT ( call pFunc(_aContent_[p]) ) return FALSE ok
			ok
		next
		return TRUE

	#-- TRUE iff every element of panSub is a member of panSet
	func _StzAllIn(panSub, panSet)
		_nLen_ = len(panSub)
		for _i_ = 1 to _nLen_
			if NOT _StzHasItemTyped(panSet, panSub[_i_]) return FALSE ok
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

	func _StzFindTypeRuns(_aContent_, cType)
		_aC_ = []
		_nC_ = len(_aContent_)
		for _i_ = 1 to _nC_ add(_aC_, _aContent_[_i_]) next
		if cType = "number" add(_aC_, "X") else add(_aC_, 0) ok

		_nLen_ = len(_aC_)
		if _nLen_ <= 1 return [] ok

		_aResult_ = []
		_n1_ = 1
		for _i_ = 2 to _nLen_ - 1
			if _StzIsTypeTag(_aC_[_i_], cType) and NOT _StzIsTypeTag(_aC_[_i_-1], cType)
				_n1_ = _i_
			ok
			if _StzIsTypeTag(_aC_[_i_], cType) and NOT _StzIsTypeTag(_aC_[_i_+1], cType)
				add(_aResult_, [ _n1_, _i_ ])
			ok
		next
		return _aResult_

	#-- consistent stringification for consecutive-equality comparison
	func _StzStringifyItem(pItem)
		if isNumber(pItem) return "" + pItem ok
		return @@(pItem)

	#-- [[value, [consecutive-dup positions]], ...] first-appearance order
	func _StzDupSecutiveItemsZ(_aContent_, _bCaseSensitive_)
		_anPos_ = _StzFindDupSecutive(_aContent_, _bCaseSensitive_)
		_aVals_ = _StzDupSecutiveValues(_aContent_, _bCaseSensitive_)
		_aRes_ = []
		_nV_ = len(_aVals_)
		for _i_ = 1 to _nV_
			_cTarget_ = _StzStringifyItem(_aVals_[_i_])
			if _bCaseSensitive_ = 0 _cTarget_ = StzLower(_cTarget_) ok
			_aP_ = []
			_nP_ = len(_anPos_)
			for _j_ = 1 to _nP_
				_c_ = _StzStringifyItem(_aContent_[ _anPos_[_j_] ])
				if _bCaseSensitive_ = 0 _c_ = StzLower(_c_) ok
				if _c_ = _cTarget_ add(_aP_, _anPos_[_j_]) ok
			next
			add(_aRes_, [ _aVals_[_i_], _aP_ ])
		next
		return _aRes_

	#-- content with the consecutive-duplicate items removed
	func _StzRemoveDupSecutive(_aContent_, _bCaseSensitive_)
		_anPos_ = _StzFindDupSecutive(_aContent_, _bCaseSensitive_)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT _StzHasItemTyped(_anPos_, _i_) add(_aRes_, _aContent_[_i_]) ok
		next
		return _aRes_

	#-- content with the consecutive-duplicates of pItem removed
	func _StzRemoveThisDupSecutive(_aContent_, pItem, _bCaseSensitive_)
		_anPos_ = _StzFindThisDupSecutive(_aContent_, pItem, _bCaseSensitive_)
		_aRes_ = []
		_nLen_ = len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT _StzHasItemTyped(_anPos_, _i_) add(_aRes_, _aContent_[_i_]) ok
		next
		return _aRes_

	#-- positions i where item[i] equals item[i-1] (consecutive duplicate)
	func _StzFindDupSecutive(_aContent_, _bCaseSensitive_)
		_nLen_ = len(_aContent_)
		if _nLen_ <= 1 return [] ok
		_acItems_ = []
		for _i_ = 1 to _nLen_
			_c_ = _StzStringifyItem(_aContent_[_i_])
			if _bCaseSensitive_ = 0 _c_ = StzLower(_c_) ok
			add(_acItems_, _c_)
		next
		_anRes_ = []
		for _i_ = 2 to _nLen_
			if _acItems_[_i_-1] = _acItems_[_i_] add(_anRes_, _i_) ok
		next
		return _anRes_

	#-- the distinct values (first-appearance) that occur consecutively
	#-- duplicated; dedup honors case-sensitivity (B and b merge when CS=0)
	func _StzDupSecutiveValues(_aContent_, _bCaseSensitive_)
		_anPos_ = _StzFindDupSecutive(_aContent_, _bCaseSensitive_)
		_aRes_ = []
		_aKeys_ = []
		_nLen_ = len(_anPos_)
		for _i_ = 1 to _nLen_
			_v_ = _aContent_[ _anPos_[_i_] ]
			_k_ = _StzStringifyItem(_v_)
			if _bCaseSensitive_ = 0 _k_ = StzLower(_k_) ok
			if NOT _StzHasItemTyped(_aKeys_, _k_)
				add(_aKeys_, _k_)
				add(_aRes_, _v_)
			ok
		next
		return _aRes_

	#-- positions among the consecutive-dups whose item equals pItem
	func _StzFindThisDupSecutive(_aContent_, pItem, _bCaseSensitive_)
		_anPos_ = _StzFindDupSecutive(_aContent_, _bCaseSensitive_)
		_cTarget_ = _StzStringifyItem(pItem)
		if _bCaseSensitive_ = 0 _cTarget_ = StzLower(_cTarget_) ok
		_aRes_ = []
		_nLen_ = len(_anPos_)
		for _i_ = 1 to _nLen_
			_c_ = _StzStringifyItem(_aContent_[ _anPos_[_i_] ])
			if _bCaseSensitive_ = 0 _c_ = StzLower(_c_) ok
			if _c_ = _cTarget_ add(_aRes_, _anPos_[_i_]) ok
		next
		return _aRes_


func @FindNthPreviousCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
	if isList(_nStart_) and IsStartingAtNamedParamList(_nStart_)
		_nStart_ = _nStart_[2]
	ok
	_nLen_ = len(_aList_)
	_nRevStart_ = _nLen_ - _nStart_ + 2
	_nRevPos_ = @FindNthSTCS(reverse(_aList_), nth, pItem, _nRevStart_, pCaseSensitive)
	if _nRevPos_ < 1
		return 0
	ok
	return _nLen_ - _nRevPos_ + 1

	func FindNthPreviousCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return @FindNthPreviousCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func @FindNthPreviousSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return @FindNthPreviousCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

	func FindNthPreviousSTCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)
		return @FindNthPreviousCS(_aList_, nth, pItem, _nStart_, pCaseSensitive)

func @FindNthPrevious(_aList_, nth, pItem, _nStart_)
	return @FindNthPreviousCS(_aList_, nth, pItem, _nStart_, 1)

	func FindNthPrevious(_aList_, nth, pItem, _nStart_)
		return @FindNthPrevious(_aList_, nth, pItem, _nStart_)

	func @FindNthPreviousST(_aList_, nth, pItem, _nStart_)
		return @FindNthPrevious(_aList_, nth, pItem, _nStart_)

	func FindNthPreviousST(_aList_, nth, pItem, _nStart_)
		return @FindNthPrevious(_aList_, nth, pItem, _nStart_)

func @FindPreviousCS(_aList_, pItem, _nStart_, pCaseSensitive)
	return @FindNthPreviousCS(_aList_, 1, pItem, _nStart_, pCaseSensitive)

	func FindPreviousCS(_aList_, pItem, _nStart_, pCaseSensitive)
		return @FindPreviousCS(_aList_, pItem, _nStart_, pCaseSensitive)

	func @FindPreviousSTCS(_aList_, pItem, _nStart_, pCaseSensitive)
		return @FindPreviousCS(_aList_, pItem, _nStart_, pCaseSensitive)

	func FindPreviousSTCS(_aList_, pItem, _nStart_, pCaseSensitive)
		return @FindPreviousCS(_aList_, pItem, _nStart_, pCaseSensitive)

func @FindPrevious(_aList_, pItem, _nStart_)
	return @FindPreviousCS(_aList_, pItem, _nStart_, 1)

	func FindPrevious(_aList_, pItem, _nStart_)
		return @FindPrevious(_aList_, pItem, _nStart_)

	func @FindPreviousST(_aList_, pItem, _nStart_)
		return @FindPrevious(_aList_, pItem, _nStart_)

	func FindPreviousST(_aList_, pItem, _nStart_)
		return @FindPrevious(_aList_, pItem, _nStart_)

  #=====================================================================#
 #  W-DSL CONDITIONAL CODE: LOWERING Q(EXPR).Method(...) TO ENGINE DSL  #
#=====================================================================#

# The W ("where") engine DSL is a small functional language:
# isNumber(@item), This[@i+1] = "*", and so on. But Softanza also lets
# you write the more expressive object form Q(EXPR).IsNotANumber(),
# Q(EXPR).IsDoubleOf(OTHER), etc. inside a conditional-code string.
#
# _StzLowerWPredicates() rewrites those Q(...).Method(...) chains into
# the equivalent engine-DSL expression so the engine can evaluate them.
# It scans with balanced-paren matching (so nested parens in EXPR/args
# are preserved) and leaves string literals untouched. Method names it
# does not know are left in place verbatim (the engine then reports the
# condition as unmatchable, exactly as before this lowering existed).
#
# The conditional code is ASCII DSL, so byte-wise scanning is safe here.

func _StzLowerWPredicates(_cCode_)
	if isNull(_cCode_) or NOT isString(_cCode_)
		return _cCode_
	ok

	_cRes_ = ""
	_n_ = len(_cCode_)
	_i_ = 1

	while _i_ <= _n_
		_c_ = _cCode_[_i_]

		# Copy string literals through verbatim (don't lower a Q( that
		# happens to live inside quotes).
		if _c_ = '"' or _c_ = "'"
			_cQuote_ = _c_
			_cRes_ += _c_
			_i_++
			while _i_ <= _n_
				_cRes_ += _cCode_[_i_]
				if _cCode_[_i_] = _cQuote_
					_i_++
					exit
				ok
				_i_++
			end
			loop
		ok

		# Detect a Q(...) wrapper at a word boundary.
		if (_c_ = "Q" or _c_ = "q") and _StzWBoundaryBefore(_cCode_, _i_)
			_j_ = _i_ + 1
			while _j_ <= _n_ and _cCode_[_j_] = " "
				_j_++
			end

			if _j_ <= _n_ and _cCode_[_j_] = "("
				_aExpr_ = _StzScanParen(_cCode_, _j_)
				if _aExpr_[2] > 0
					_cExpr_ = _aExpr_[1]
					_nClose_ = _aExpr_[2]

					_k_ = _nClose_ + 1
					while _k_ <= _n_ and _cCode_[_k_] = " "
						_k_++
					end

					if _k_ <= _n_ and _cCode_[_k_] = "."
						_k_++
						_cMeth_ = ""
						while _k_ <= _n_ and _StzIsIdentChar(_cCode_[_k_])
							_cMeth_ += _cCode_[_k_]
							_k_++
						end

						while _k_ <= _n_ and _cCode_[_k_] = " "
							_k_++
						end

						if _k_ <= _n_ and _cCode_[_k_] = "("
							_aArg_ = _StzScanParen(_cCode_, _k_)
							if _aArg_[2] > 0
								_cLow_ = _StzMapWPredicate(_cMeth_, _cExpr_, _aArg_[1])
								if _cLow_ != NULL
									_cRes_ += _cLow_
									_i_ = _aArg_[2] + 1
									loop
								ok
							ok
						ok
					ok
				ok
			ok
		ok

		_cRes_ += _c_
		_i_++
	end

	return _cRes_

# Scans cCode starting at the '(' located at nOpen and returns
# [ cInnerContent, nCloseIndex ] using balanced-paren matching, or
# [ NULL, 0 ] if no matching ')' is found.
func _StzScanParen(_cCode_, nOpen)
	_n_ = len(_cCode_)
	_nDepth_ = 0
	_cContent_ = ""
	_i_ = nOpen

	while _i_ <= _n_
		_c_ = _cCode_[_i_]
		if _c_ = "("
			_nDepth_++
			if _nDepth_ > 1
				_cContent_ += _c_
			ok
		but _c_ = ")"
			_nDepth_--
			if _nDepth_ = 0
				return [ _cContent_, _i_ ]
			else
				_cContent_ += _c_
			ok
		else
			if _nDepth_ >= 1
				_cContent_ += _c_
			ok
		ok
		_i_++
	end

	return [ NULL, 0 ]

func _StzIsIdentChar(_c_)
	if isNull(_c_) or len(_c_) = 0
		return FALSE
	ok
	# Ring's >/< operators coerce strings to numbers (R41), so test
	# membership against an explicit ASCII alphabet instead.
	return substr("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_", _c_) > 0

func _StzWBoundaryBefore(_cCode_, _i_)
	if _i_ <= 1
		return TRUE
	ok
	return NOT _StzIsIdentChar(_cCode_[_i_-1])

# Maps a Softanza predicate method to its engine-DSL equivalent.
# cExpr is the receiver expression, cArg the (possibly empty) argument.
# Returns NULL for unknown methods so the caller leaves them untouched.
func _StzMapWPredicate(_cMeth_, _cExpr_, cArg)
	_cM_ = lower(trim(_cMeth_))
	_cE_ = trim(_cExpr_)
	_cA_ = trim(cArg)

	# --- no-argument type/case predicates ---
	switch _cM_
	on "isnumber"      return "isNumber(" + _cE_ + ")"
	on "isanumber"     return "isNumber(" + _cE_ + ")"
	on "isnotanumber"  return "(NOT isNumber(" + _cE_ + "))"
	on "isnotnumber"   return "(NOT isNumber(" + _cE_ + "))"
	on "isstring"      return "isString(" + _cE_ + ")"
	on "isastring"     return "isString(" + _cE_ + ")"
	on "isnotastring"  return "(NOT isString(" + _cE_ + "))"
	on "isnotstring"   return "(NOT isString(" + _cE_ + "))"
	on "islist"        return "isList(" + _cE_ + ")"
	on "isalist"       return "isList(" + _cE_ + ")"
	on "isletter"      return "isLetter(" + _cE_ + ")"
	on "isaletter"     return "isLetter(" + _cE_ + ")"
	on "isnotletter"   return "(NOT isLetter(" + _cE_ + "))"
	on "isnotaletter"  return "(NOT isLetter(" + _cE_ + "))"
	on "isuppercase"   return "isUppercase(" + _cE_ + ")"
	on "islowercase"   return "isLowercase(" + _cE_ + ")"
	on "isdigit"       return "isDigit(" + _cE_ + ")"
	on "isspace"       return "isSpace(" + _cE_ + ")"
	on "iswhitespace"  return "isSpace(" + _cE_ + ")"
	on "isalphanumeric" return "isAlphanumeric(" + _cE_ + ")"
	on "isvowel"       return "isVowel(" + _cE_ + ")"
	on "isconsonant"   return "isConsonant(" + _cE_ + ")"
	on "ispunctuation" return "isPunctuation(" + _cE_ + ")"
	on "isnumberinstring"  return "isDigit(" + _cE_ + ")"
	on "isanumberinstring" return "isDigit(" + _cE_ + ")"
	on "isarabic"      return "isArabic(" + _cE_ + ")"
	on "isarabicletter" return "isArabic(" + _cE_ + ")"
	on "islatin"       return "isLatin(" + _cE_ + ")"
	on "islatinletter" return "isLatin(" + _cE_ + ")"
	on "iseven"        return "iseven(" + _cE_ + ")"
	on "isodd"         return "isodd(" + _cE_ + ")"
	on "ispositive"    return "ispositive(" + _cE_ + ")"
	on "isnegative"    return "isnegative(" + _cE_ + ")"
	off

	# --- one-argument numeric predicates ---
	if _cA_ = NULL or _cA_ = ""
		return NULL
	ok

	switch _cM_
	on "isdoubleof"     return "((" + _cE_ + ") = 2 * (" + _cA_ + "))"
	on "ishalfof"       return "((2 * (" + _cE_ + ")) = (" + _cA_ + "))"
	on "isdividableby"  return "(((" + _cE_ + ") % (" + _cA_ + ")) = 0)"
	on "isdivisibleby"  return "(((" + _cE_ + ") % (" + _cA_ + ")) = 0)"
	on "ismultipleof"   return "(((" + _cE_ + ") % (" + _cA_ + ")) = 0)"
	on "isequalto"      return "((" + _cE_ + ") = (" + _cA_ + "))"
	on "isbiggerthan"   return "((" + _cE_ + ") > (" + _cA_ + "))"
	on "isgreaterthan"  return "((" + _cE_ + ") > (" + _cA_ + "))"
	on "issmallerthan"  return "((" + _cE_ + ") < (" + _cA_ + "))"
	on "islessthan"     return "((" + _cE_ + ") < (" + _cA_ + "))"
	off

	return NULL

#-- Walker step helpers (produce [:Key, value] pairs for AddWalker).
#-- Named()/WhileWalking()/With()/Wk() live in stzWalker.ring; StartingAt()/
#-- EndingAt() live in stzFuncs.ring and return bare values (used positionally).

func NStepsATime(p)
	return [ :NStep, p ]

func TakingNEqualMoves(p)
	return [ :NEqualMoves, p ]

  /////////////////
 ///   CLASS   ///
/////////////////

class TempAndDumpyThing


