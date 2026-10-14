#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCLASSIFIER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List classifier subclass -- classification #
#                  and categorization of list items.           #
#                  For aliases, use stzListClassifierXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Groups the items of a list by equality or by an expression, counts them, and answers the most and least frequent, plus halves and chunks.
#
# It is the grouping helper of stzList, which builds one over itself for its Classify, Classes,
# ClassifyBy, NumberOfClasses and Frequencies methods; build one with new stzListClassifier when you
# only need to group. It never changes the list, so a stzList passed in stays intact. Classify
# answers [ item, positions ] pairs with positions counted from 1, and Frequencies answers [ item,
# count ] pairs, both in order of first appearance. Two limits found today: Classify, Classes and
# NumberOfClasses answer nothing for a list made of numbers, and the counting methods (Classify,
# Frequencies, Mode, MostFrequent, ItemsAppearing...) fold capital and small ASCII letters together
# and give the numbers back as texts, while FrequencyOf compares with case and type.
# ItemsAppearingNTimes and its kin keep each item's own type. Partition, Chunks, Bisect, FirstHalf
# and SecondHalf only cut the list by position. Hebrew, Arabic and emoji items are classed like any
# other text.
#
#   receiver   o1 = new stzListClassifier([ "a", "b", "a", "c", "a", "b" ])
#   example    ? @@( o1.Classify() )
#              #--> [ [ "a", [ 1, 3, 5 ] ], [ "b", [ 2, 6 ] ], [ "c", [ 4 ] ] ]
#              ? @@( o1.Frequencies() )
#              #--> [ [ "a", 3 ], [ "b", 2 ], [ "c", 1 ] ]
#              ? o1.MostFrequent()
#              #--> a
#              ? @@( o1.ItemsAppearingMoreThanNTimes(1) )
#              #--> [ "a", "b" ]
#              ? @@( o1.Chunks(4) )
#              #--> [ [ "a", "b", "a", "c" ], [ "a", "b" ] ]
#              o2 = new stzListClassifier([ "apple", "bob", "kiwi", "fig", "plum" ])
#              ? @@( o2.ClassifyBy("len(@item)") )
#              #--> [ [ "5", [ 1 ] ], [ "3", [ 2, 4 ] ], [ "4", [ 3, 5 ] ] ]
#              o3 = new stzListClassifier([ "שלום", "😀", "שלום" ])
#              ? @@( o3.Frequencies() )
#              #--> [ [ "שלום", 2 ], [ "😀", 1 ] ]
#   see        stzList, stzListDuplicates, stzListSplits
class stzListClassifier from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a classifier over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to analyse, or a stzList whose content is copied, any other value
	#                raises an error
	#   returns      nothing; the object is built
	#   note         the classifier never changes the list or the stzList you passed in
	#   see          Content, Classify
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListClassifier! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list the classifier works on.
	#
	#   returns    a list
	#   see        NumberOfItems, Copy
	def Content()
		return @oList.Content()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        Content, NumberOfClasses
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems, Content
	def IsEmpty()
		return @oList.IsEmpty()

	# Returns a new classifier over a copy of the list.
	#
	#   returns    a stzListClassifier
	#   see        Content, Classify
	def Copy()
		return new stzListClassifier( @oList.Content() )

	# Groups the positions of equal items together, one class per distinct item.
	#
	#   returns    a list of [ item, positions ] pairs, in order of first appearance
	#   note       the items are the keys, so a text keeps its spelling; ClassifyQ returns the
	#              answer as a stzList and Classified is the same call
	#   warning    a list made of numbers answers [ ] ([ 1, 2, 2, 3, 3, 3 ] and [ 1, 2, 2.5, 2, 3,
	#              3, 3, 1 ] were tried), while a list of texts or of sublists is grouped; capital
	#              and small ASCII letters fall into one class, so a and A group under the first
	#              spelling met, while é and É stay apart
	#   see        Classes, Parts, Frequencies, ClassifyBy
	#@ aka  Group the items into classes of equal values.
	def Classify()
		# Residency-aware: reuse @oList's warm engine handle (do NOT free it).
		_pClList_ = @oList._Engine()
		_pClResult_ = StzEngineListClassifyCS(_pClList_, 0)

		# Engine now emits the FINAL nested shape [ [keyString, [pos...]], ... ]
		# directly, so we just unmarshal once -- no Ring-side repackaging loop
		# (which copied every position sublist, O(n) in interpreted Ring and the
		# real cost of Classify() at scale).
		_aClResult_ = StzEngineListContentToRingList(_pClResult_)
		StzEngineListFree(_pClResult_)
		return _aClResult_

		def ClassifyQ()
			return new stzList(This.Classify())

	# The items grouped into classes of equal values, as data.
	def Classified()
		return This.Classify()

	# Returns the distinct items of the list, one per class, in order of first appearance.
	#
	#   returns    a list
	#   note       capital and small ASCII letters count as one class
	#   warning    a list of numbers answers [ ], as Classify does
	#   see        Classify, NumberOfClasses
	#@ aka  The distinct classes (values) of the list.
	def Classes()
		_aClsClassified_ = This.Classify()
		_nClsLen_ = len(_aClsClassified_)
		_aClsResult_ = []
		for _iCls_ = 1 to _nClsLen_
			@AddItem(_aClsResult_, _aClsClassified_[_iCls_][1])
		next
		return _aClsResult_

	# Groups the positions of the items by the value an expression gives for each item.
	#
	#   pcExpr     an expression of the current item, written with @item, such as "len(@item)"
	#   returns    a list of [ key, positions ] pairs, the key being the value written as a text
	#   note       on [ 1, 2, 2, 3, 3, 3 ] the expression "@item % 2" gives the classes "1" and "0";
	#              on texts "len(@item)" groups by length; keys are texts, so 10 comes back as "10";
	#              GroupBy is the same call
	#   see        Classify, Frequencies
	#@ aka  Group the items into classes by the given expression.
	def ClassifyBy(pcExpr)
		# Residency-aware: reuse @oList's warm engine handle (do NOT free it).
		_pCbList_ = @oList._Engine()
		_cCbMapExpr_ = "string(" + pcExpr + ")"
		_pCbMapped_ = StzEngineListMapExpr(_pCbList_, _cCbMapExpr_)

		_pCbResult_ = StzEngineListClassifyCS(_pCbMapped_, 1)
		StzEngineListFree(_pCbMapped_)

		# Engine emits the final nested [ [keyString, [pos...]], ... ] shape.
		_aCbResult_ = StzEngineListContentToRingList(_pCbResult_)
		StzEngineListFree(_pCbResult_)
		return _aCbResult_

	def PartsCS(pCaseSensitive)
		return This.Classify()

	# Groups the positions of equal items together, one part per distinct item.
	#
	#   returns    a list of [ item, positions ] pairs
	#   note       the same answer as Classify; PartsCS(pCaseSensitive) takes the flag but ignores
	#              it
	#   see        Classify, Chunks
	def Parts()
		return This.PartsCS(1)

	  #======================================================#
	 #   NUMBER OF CLASSES                                  #
	#======================================================#

	# Returns how many distinct items the list holds.
	#
	#   returns    a number
	#   note       a list of numbers answers 0, as Classify does
	#   see        Classes, Classify
	#@ aka  How many distinct classes the items form.
	def NumberOfClasses()
		return len(This.Classes())

	  #======================================================#
	 #   FREQUENCY OF EACH ITEM                             #
	#======================================================#

	# Returns each distinct item with how many times it occurs.
	#
	#   returns    a list of [ item, count ] pairs, in order of first appearance
	#   note       the items come back as texts, so the number 3 is "3", a text 1 and a number 1
	#              count together, and a sublist is written as text; capital and small ASCII letters
	#              are counted together under the first spelling; Histogram is the same call
	#   see        FrequencyOf, Mode, MostFrequent
	def Frequencies()
		_pFrList_ = @oList._EngineListFromContent()
		_pFrFreqs_ = StzEngineListFrequenciesCS(_pFrList_, 0)
		StzEngineListFree(_pFrList_)

		_aFrRaw_ = StzEngineListContentToRingList(_pFrFreqs_)
		StzEngineListFree(_pFrFreqs_)

		_nFrLen_ = len(_aFrRaw_)
		_aFrResult_ = []
		_iFr_ = 1
		for _kFr_ = 1 to _nFrLen_ / 2
			@AddItem(_aFrResult_, [_aFrRaw_[_iFr_], _aFrRaw_[_iFr_ + 1]])
			_iFr_ += 2
		next
		return _aFrResult_

	  #======================================================#
	 #   MOST / LEAST FREQUENT                              #
	#======================================================#

	# Returns the item that occurs most often.
	#
	#   returns    the item, as a text, or an empty text for an empty list
	#   note       with a tie it answers the one that appeared first; for all the tied items use
	#              Mode
	#   see        LeastFrequent, Mode, Frequencies
	def MostFrequent()
		_aMfFreqs_ = This.Frequencies()
		_nMfLen_ = len(_aMfFreqs_)
		if _nMfLen_ = 0
			return ""
		ok
		_nMfMax_ = 0
		_cMfResult_ = ""
		for _iMf_ = 1 to _nMfLen_
			if _aMfFreqs_[_iMf_][2] > _nMfMax_
				_nMfMax_ = _aMfFreqs_[_iMf_][2]
				_cMfResult_ = _aMfFreqs_[_iMf_][1]
			ok
		next
		return _cMfResult_

	# Returns the item that occurs least often.
	#
	#   returns    the item, as a text, or an empty text for an empty list
	#   note       with a tie it answers the one that appeared first
	#   see        MostFrequent, Frequencies
	def LeastFrequent()
		_aLfFreqs_ = This.Frequencies()
		_nLfLen_ = len(_aLfFreqs_)
		if _nLfLen_ = 0
			return ""
		ok
		_nLfMin_ = _aLfFreqs_[1][2]
		_cLfResult_ = _aLfFreqs_[1][1]
		for _iLf_ = 2 to _nLfLen_
			if _aLfFreqs_[_iLf_][2] < _nLfMin_
				_nLfMin_ = _aLfFreqs_[_iLf_][2]
				_cLfResult_ = _aLfFreqs_[_iLf_][1]
			ok
		next
		return _cLfResult_

	  #======================================================#
	 #   GROUP BY EXPRESSION                                #
	#======================================================#

	# Group the items by the given expression.
	def GroupBy(pcExpr)
		return This.ClassifyBy(pcExpr)

		def GroupByQ(pcExpr)
			return new stzList(This.GroupBy(pcExpr))

	  #======================================================#
	 #   PARTITION INTO N GROUPS                            #
	#======================================================#

	# Cuts the list into consecutive groups of equal size, the last one possibly shorter.
	#
	#   n          the number of groups wanted
	#   returns    a list of lists
	#   note       the group size is the count divided by n, rounded up, so the answer can hold
	#              fewer than n groups; an empty list gives [ ]
	#   warning    n = 0 raises error R1 Can't divide by zero
	#   see        Chunks, Bisect
	def Partition(n)
		_aPartContent_ = This.Content()
		_nPartLen_ = len(_aPartContent_)
		_aPartResult_ = []
		_nPartGroupSize_ = ceil(_nPartLen_ / n)
		_nPartStart_ = 1
		for _iPart_ = 1 to n
			_aPartGroup_ = []
			_nPartEnd_ = _nPartStart_ + _nPartGroupSize_ - 1
			if _nPartEnd_ > _nPartLen_
				_nPartEnd_ = _nPartLen_
			ok
			for _jPart_ = _nPartStart_ to _nPartEnd_
				@AddItem(_aPartGroup_, _aPartContent_[_jPart_])
			next
			if len(_aPartGroup_) > 0
				@AddItem(_aPartResult_, _aPartGroup_)
			ok
			_nPartStart_ = _nPartEnd_ + 1
		next
		return _aPartResult_

		def PartitionQ(n)
			return new stzList(This.Partition(n))

	  #======================================================#
	 #   HISTOGRAM -- FREQUENCY AS PAIRS [VALUE, COUNT]     #
	#======================================================#

	def Histogram()
		return This.Frequencies()

		def HistogramQ()
			return new stzList(This.Histogram())

	  #======================================================#
	 #   ITEMS APPEARING EXACTLY N TIMES                    #
	#======================================================#

	# The distinct items with how often each occurs, as [ item, count ] pairs in order of
	# first appearance. Frequencies keys every item as text ("3" for 3), so each key is
	# traced back to the first item of the list that produced it, and that item keeps its type.
	def _ItemsWithCounts()
		_aIwcFreqs_ = This.Frequencies()
		_nIwcFreqs_ = len(_aIwcFreqs_)
		_aIwcContent_ = @oList.Content()
		_nIwcLen_ = len(_aIwcContent_)

		# a list of text only: the keys ARE the items
		_bIwcText_ = 1
		for _iIwc_ = 1 to _nIwcLen_
			if NOT isString(_aIwcContent_[_iIwc_])
				_bIwcText_ = 0
				exit
			ok
		next
		if _bIwcText_
			return _aIwcFreqs_
		ok

		_aIwcKeys_ = []
		_aIwcItems_ = []
		_aIwcDone_ = []
		for _iIwc_ = 1 to _nIwcFreqs_
			_aIwcKeys_ + _aIwcFreqs_[_iIwc_][1]
			_aIwcItems_ + _aIwcFreqs_[_iIwc_][1]
			_aIwcDone_ + 0
		next
		_nIwcLeft_ = _nIwcFreqs_

		for _iIwc_ = 1 to _nIwcLen_
			if _nIwcLeft_ = 0
				exit
			ok
			_vIwcItem_ = _aIwcContent_[_iIwc_]
			if isString(_vIwcItem_)
				_cIwcKey_ = _vIwcItem_
			but isNumber(_vIwcItem_)
				_cIwcKey_ = string(_vIwcItem_)
			else
				_cIwcKey_ = @@(_vIwcItem_)
			ok
			_nIwcAt_ = find(_aIwcKeys_, _cIwcKey_)
			if _nIwcAt_ = 0 and isString(_vIwcItem_)
				_nIwcAt_ = find(_aIwcKeys_, lower(_vIwcItem_))
			ok
			if _nIwcAt_ = 0 and isNumber(_vIwcItem_)
				# the engine writes 2.5 where Ring's string() gives "2.50": drop the trailing zeros
				_nIwcCut_ = len(_cIwcKey_)
				if StzFind(".", _cIwcKey_) = 0
					_nIwcCut_ = 0
				ok
				while _nIwcCut_ > 1 and _cIwcKey_[_nIwcCut_] = "0"
					_nIwcCut_ = _nIwcCut_ - 1
				end
				if _nIwcCut_ > 0 and _cIwcKey_[_nIwcCut_] = "."
					_nIwcCut_ = _nIwcCut_ - 1
				ok
				if _nIwcCut_ > 0
					_cIwcShort_ = left(_cIwcKey_, _nIwcCut_)
					_nIwcAt_ = find(_aIwcKeys_, _cIwcShort_)
				ok
			ok
			if _nIwcAt_ > 0 and _aIwcDone_[_nIwcAt_] = 0
				_aIwcItems_[_nIwcAt_] = _vIwcItem_
				_aIwcDone_[_nIwcAt_] = 1
				_nIwcLeft_ = _nIwcLeft_ - 1
			ok
		next

		_aIwcResult_ = []
		for _iIwc_ = 1 to _nIwcFreqs_
			@AddItem(_aIwcResult_, [ _aIwcItems_[_iIwc_], _aIwcFreqs_[_iIwc_][2] ])
		next
		return _aIwcResult_

	# Returns the distinct items that occur exactly n times.
	#
	#   n          the exact number of occurrences
	#   returns    a list
	#   note       the items keep their type, so a number stays a number, unlike Frequencies;
	#              ItemsWithFrequency is the same call; capital and small ASCII letters are counted
	#              together
	#   see        ItemsAppearingMoreThanNTimes, Frequencies
	def ItemsAppearingNTimes(n)
		_aIntFreqs_ = This._ItemsWithCounts()
		_nIntLen_ = len(_aIntFreqs_)
		_aIntResult_ = []
		for _iInt_ = 1 to _nIntLen_
			if _aIntFreqs_[_iInt_][2] = n
				@AddItem(_aIntResult_, _aIntFreqs_[_iInt_][1])
			ok
		next
		return _aIntResult_

		def ItemsWithFrequency(n)
			return This.ItemsAppearingNTimes(n)

	  #======================================================#
	 #   ITEMS APPEARING MORE/LESS THAN N TIMES             #
	#======================================================#

	# Returns the distinct items that occur more than n times.
	#
	#   n          the number of occurrences to exceed
	#   returns    a list
	#   note       the items keep their type, as in ItemsAppearingNTimes
	#   see        ItemsAppearingLessThanNTimes, ItemsAppearingNTimes
	def ItemsAppearingMoreThanNTimes(n)
		_aImtFreqs_ = This._ItemsWithCounts()
		_nImtLen_ = len(_aImtFreqs_)
		_aImtResult_ = []
		for _iImt_ = 1 to _nImtLen_
			if _aImtFreqs_[_iImt_][2] > n
				@AddItem(_aImtResult_, _aImtFreqs_[_iImt_][1])
			ok
		next
		return _aImtResult_

	# Returns the distinct items that occur fewer than n times.
	#
	#   n          the number of occurrences to stay under
	#   returns    a list
	#   note       the items keep their type, as in ItemsAppearingNTimes
	#   see        ItemsAppearingMoreThanNTimes, ItemsAppearingNTimes
	def ItemsAppearingLessThanNTimes(n)
		_aIltFreqs_ = This._ItemsWithCounts()
		_nIltLen_ = len(_aIltFreqs_)
		_aIltResult_ = []
		for _iIlt_ = 1 to _nIltLen_
			if _aIltFreqs_[_iIlt_][2] < n
				@AddItem(_aIltResult_, _aIltFreqs_[_iIlt_][1])
			ok
		next
		return _aIltResult_

	  #======================================================#
	 #   FREQUENCY OF A SPECIFIC ITEM                       #
	#======================================================#

	# Returns how many times one item occurs in the list.
	#
	#   pItem      the item to count
	#   returns    a number
	#   note       unlike Frequencies it compares with case and with type: in a b A a, A counts 1
	#              and a 2, and a number 1 does not count a text 1; HowMany is the same call
	#   see        Frequencies, Mode
	def FrequencyOf(pItem)
		return @oList.CountCS(pItem, 1)

		def HowMany(pItem)
			return This.FrequencyOf(pItem)

	  #======================================================#
	 #   MODE -- MOST COMMON ITEMS (ALL TIES)               #
	#======================================================#

	# Returns every item that ties for the highest count.
	#
	#   returns    a list, [ ] for an empty list
	#   note       the items come back as texts, as in Frequencies
	#   see        MostFrequent, Frequencies
	def Mode()
		_aMdFreqs_ = This.Frequencies()
		_nMdLen_ = len(_aMdFreqs_)
		if _nMdLen_ = 0
			return []
		ok
		_nMdMax_ = 0
		for _iMd_ = 1 to _nMdLen_
			if _aMdFreqs_[_iMd_][2] > _nMdMax_
				_nMdMax_ = _aMdFreqs_[_iMd_][2]
			ok
		next
		_aMdResult_ = []
		for _jMd_ = 1 to _nMdLen_
			if _aMdFreqs_[_jMd_][2] = _nMdMax_
				@AddItem(_aMdResult_, _aMdFreqs_[_jMd_][1])
			ok
		next
		return _aMdResult_

	  #======================================================#
	 #   BISECTION -- SPLIT INTO HALVES                     #
	#======================================================#

	# Cuts the list into a first half and a second half.
	#
	#   returns    a list of two lists
	#   note       with an odd count the first half is the larger; BisectQ returns a stzList
	#   see        FirstHalf, SecondHalf, Partition
	def Bisect()
		_aBsContent_ = This.Content()
		_nBsLen_ = len(_aBsContent_)
		_nBsMid_ = ceil(_nBsLen_ / 2)

		_aBsFirst_ = []
		for _iBs_ = 1 to _nBsMid_
			@AddItem(_aBsFirst_, _aBsContent_[_iBs_])
		next

		_aBsSecond_ = []
		for _jBs_ = _nBsMid_ + 1 to _nBsLen_
			@AddItem(_aBsSecond_, _aBsContent_[_jBs_])
		next

		return [_aBsFirst_, _aBsSecond_]

		def BisectQ()
			return new stzList(This.Bisect())

	# Returns the first half of the list.
	#
	#   returns    a list
	#   note       with an odd count the first half holds the extra item
	#   see        SecondHalf, Bisect
	def FirstHalf()
		return This.Bisect()[1]

		def FirstHalfQ()
			return new stzList(This.FirstHalf())

	# Returns the second half of the list.
	#
	#   returns    a list
	#   note       with an odd count it holds one item fewer than the first half
	#   see        FirstHalf, Bisect
	def SecondHalf()
		return This.Bisect()[2]

		def SecondHalfQ()
			return new stzList(This.SecondHalf())

	  #======================================================#
	 #   PARTITION BY CONDITION                             #
	#======================================================#

	# Partition the items into [satisfying, not-satisfying] by the W
	# condition.
	def PartitionW(pcCondition)
		_aPwContent_ = This.Content()
		_nPwLen_ = len(_aPwContent_)
		_aPwTrue_ = []
		_aPwFalse_ = []

		# The condition is already Ring-evaluable after @item substitution; the
		# old StzCCodeToRingCode() wrapper does not exist (R3). Strip any outer
		# braces and use it directly, mirroring the engine-backed W-methods.
		_cPwCode_ = _StzStripBraces(pcCondition)

		for @i = 1 to _nPwLen_
			@item = _aPwContent_[@i]
			_cPwEval_ = StzReplace(_cPwCode_, "@item", @@(@item))
			eval("_bPwResult_ = ( " + _cPwEval_ + " )")
			if _bPwResult_
				@AddItem(_aPwTrue_, @item)
			else
				@AddItem(_aPwFalse_, @item)
			ok
		next

		return [_aPwTrue_, _aPwFalse_]

		def PartitionWQ(pcCondition)
			return new stzList(This.PartitionW(pcCondition))

		def PartitionWhere(pcCondition)
			return This.PartitionW(pcCondition)

		def SplitW(pcCondition)
			return This.PartitionW(pcCondition)

	  #======================================================#
	 #   CHUNK -- SPLIT INTO GROUPS OF SIZE N               #
	#======================================================#

	# Cuts the list into consecutive groups of n items, the last one possibly shorter.
	#
	#   n          how many items each group holds
	#   returns    a list of lists
	#   note       an n larger than the list gives one group, and 0 gives [ ]; SplitToPartsOfNItems
	#              is the same call and ChunksQ returns a stzList
	#   see        Partition, Bisect
	def Chunks(n)
		_pChList_ = @oList._EngineListFromContent()
		_pChResult_ = StzEngineListChunked(_pChList_, n)
		_aChResult_ = StzEngineListContentToRingList(_pChResult_)
		StzEngineListFree(_pChResult_)
		StzEngineListFree(_pChList_)
		return _aChResult_

		def ChunksQ(n)
			return new stzList(This.Chunks(n))

		def SplitToPartsOfNItems(n)
			return This.Chunks(n)
