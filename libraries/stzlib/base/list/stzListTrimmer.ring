#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTTRIMMER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List trimmer subclass -- trim leading and  #
#                  trailing empty items. For aliases, use      #
#                  stzListTrimmerXT.                            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Trims a list: empty items at its ends, a given item at its ends, blank texts throughout, runs of blanks, or everything past a size.
#
# Build one with new stzListTrimmer(aList) or over a stzList object; it keeps its own copy, so what
# you passed in is not changed, and Content gives the result. Each verb that changes the list has a
# passive twin that returns a trimmed copy instead (Trim and Trimmed, Compact and Compacted ...).
# Empty, for Trim, TrimLeft and TrimRight, means the number 0, an empty or blank text, an empty
# sublist or a false object, so a list of numbers loses its zeros at the ends; Compact, Squeeze and
# StripNulls look at texts and sublists only. The Q forms (TrimQ, CompactQ ...) return the trimmer
# to chain on.
#
#   receiver   o1 = new stzListTrimmer([ 0, "", "  ", "a", 0, "b", "", "שלום" ])
#   example    ? @@( o1.Compacted() )
#              #--> [ 0, "a", 0, "b", "שלום" ]
#              ? @@( o1.Trimmed() )
#              #--> [ "a", 0, "b", "", "שלום" ]
#              ? @@( o1.TrimmedToSize(2) )
#              #--> [ 0, "" ]
#   see        stzList, stzListLeadTrail, stzListRemover
class stzListTrimmer from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a trimmer over a list or over a stzList object, working on its own copy, so the list passed in is never changed.
	#
	#   pListOrObj   a list, or a stzList object, to be trimmed
	#   returns      nothing; the object is built
	#   warning      any other kind of value raises "Can't create stzListTrimmer! Parameter must be
	#                a list or stzList object."
	#   see          Content
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListTrimmer! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the items the trimmer holds, after any trim made through it.
	#
	#   returns    a list
	#   see        Trimmed
	def Content()
		return @oList.Content()

	# Returns how many items the list holds now.
	#
	#   returns    a number
	#   see        Content
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfItems
	def IsEmpty()
		return @oList.IsEmpty()

	# Remove the runs of EMPTY items (0, empty string, empty
	# sublist, false-object -- the monolith semantics) from BOTH
	# ends; a fully-empty list keeps one item (mutating).
	def TrimCS(pCaseSensitive)
		_oCopy_ = @oList.Copy()
		_oCopy_.TrimLeftCS(pCaseSensitive)
		_oCopy_.TrimRightCS(pCaseSensitive)
		@oList.UpdateWith(_oCopy_.Content())

		def TrimCSQ(pCaseSensitive)
			This.TrimCS(pCaseSensitive)
			return This

	# A copy with the empty boundary runs trimmed; the original is
	# unchanged.
	def TrimmedCS(pCaseSensitive)
		# Was @oList.Copy().TrimCSQ(...) -- but Copy() returns a plain stzList
		# which doesnt have the TrimCSQ method (its on stzListTrimmer).
		# Wrap in a fresh stzListTrimmer instead.
		_oTdCopy_ = new stzListTrimmer(@oList.Content())
		_oTdCopy_.TrimCS(pCaseSensitive)
		return _oTdCopy_.Content()

	# Removes the empty items at both ends of the list, in place; the number 0 and blank texts count as empty.
	#
	#   returns    nothing; use TrimQ to chain
	#   note       the number 0 counts as empty, so 0 0 a becomes a; a list made only of empty items
	#              keeps one item
	#   see        Trimmed, TrimLeft, TrimRight
	def Trim()
		This.TrimCS(1)

		def TrimQ()
			return This.TrimCSQ(1)

	# Returns a copy of the list without the empty items at both ends, leaving the object unchanged.
	#
	#   returns    a list
	#   note       empty means the number 0, an empty or blank text, an empty sublist or a false
	#              object
	#   see        Trim
	def Trimmed()
		return This.TrimmedCS(1)

	# Remove the leading run of empty items (0, empty string, empty
	# sublist, false-object) -- mutating.
	def TrimLeftCS(pCaseSensitive)
		_aTlcContent_ = This.Content()
		_nTlcLen_ = len(_aTlcContent_)
		if _nTlcLen_ < 1
			return
		ok
		# An "empty" (trimmable) item is the number 0, an empty string, an
		# empty sublist, or a false-object (monolith semantics). Stop at the
		# last element so a fully-empty list keeps one item.
		_nTlcStart_ = 0
		for _iTlc_ = 1 to _nTlcLen_ - 1
			if This._TrimItemIsEmpty(_aTlcContent_[_iTlc_])
				_nTlcStart_ = _iTlc_
			else
				exit
			ok
		next
		if _nTlcStart_ > 0
			@oList.RemoveSection(1, _nTlcStart_)
		ok

		def TrimLeftCSQ(pCaseSensitive)
			This.TrimLeftCS(pCaseSensitive)
			return This

	# Removes the empty items at the start of the list, in place.
	#
	#   returns    nothing
	#   note       the number 0, an empty or blank text and an empty sublist count as empty; the
	#              last item is never removed
	#   see        TrimmedLeft, Trim, TrimRight
	def TrimLeft()
		This.TrimLeftCS(1)

	# Returns a copy of the list without the empty items at its start, leaving the object unchanged.
	#
	#   returns    a list
	#   see        TrimLeft
	def TrimmedLeft()
		_o = new stzListTrimmer(@oList.Content())
		_o.TrimLeftCS(1)
		return _o.Content()

	# Remove the trailing run of empty items (mutating).
	def TrimRightCS(pCaseSensitive)
		_aTrcContent_ = This.Content()
		_nTrcLen_ = len(_aTrcContent_)
		if _nTrcLen_ < 1
			return
		ok
		_nTrcEnd_ = 0
		for _iTrc_ = _nTrcLen_ to 2 step -1
			if This._TrimItemIsEmpty(_aTrcContent_[_iTrc_])
				_nTrcEnd_ = _iTrc_
			else
				exit
			ok
		next
		if _nTrcEnd_ > 0
			@oList.RemoveSection(_nTrcEnd_, _nTrcLen_)
		ok

	#-- "Empty"/trimmable test shared by TrimLeft/TrimRight (monolith parity):
	#-- number 0, empty string, empty sublist, or a false-object.
	def _TrimItemIsEmpty(pItem)
		if isNumber(pItem) and pItem = 0
			return 1
		but isString(pItem) and ring_trim(pItem) = ""
			return 1
		but isList(pItem) and len(pItem) = 0
			return 1
		but isObject(pItem) and @IsFalseObject(pItem)
			return 1
		ok
		return 0

		def TrimRightCSQ(pCaseSensitive)
			This.TrimRightCS(pCaseSensitive)
			return This

	# Removes the empty items at the end of the list, in place.
	#
	#   returns    nothing
	#   note       the number 0, an empty or blank text and an empty sublist count as empty; the
	#              first item is never removed
	#   see        TrimmedRight, Trim, TrimLeft
	def TrimRight()
		This.TrimRightCS(1)

	# Returns a copy of the list without the empty items at its end, leaving the object unchanged.
	#
	#   returns    a list
	#   see        TrimRight
	def TrimmedRight()
		_o = new stzListTrimmer(@oList.Content())
		_o.TrimRightCS(1)
		return _o.Content()

	  #======================================================#
	 #   TRIM SPECIFIC ITEM                                 #
	#======================================================#

	def TrimItemCS(pItem, pCaseSensitive)
		This.TrimItemFromLeftCS(pItem, pCaseSensitive)
		This.TrimItemFromRightCS(pItem, pCaseSensitive)

		def TrimItemCSQ(pItem, pCaseSensitive)
			This.TrimItemCS(pItem, pCaseSensitive)
			return This

	# Removes every repeat of one given item at both ends of the list, in place, comparing case-sensitively.
	#
	#   pItem      the item to strip from both ends
	#   returns    nothing; use TrimItemQ to chain
	#   note       TrimItem("x") on x X a x b x X removes only the first x: a trailing X is another
	#              item; TrimItemCS(pItem, 0) ignores case
	#   see        TrimItemFromLeft, TrimItemFromRight
	def TrimItem(pItem)
		This.TrimItemCS(pItem, 1)

		def TrimItemQ(pItem)
			This.TrimItem(pItem)
			return This

	def TrimItemFromLeftCS(pItem, pCaseSensitive)
		if isString(pItem) and pCaseSensitive = 1
			_pTilList_ = @oList._EngineListFromContent()
			if _pTilList_ != ""
				StzEngineListTrimLeadingString(_pTilList_, pItem)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pTilList_))
				StzEngineListFree(_pTilList_)
				return
			ok
		ok
		_aTilContent_ = This.Content()
		_nTilLen_ = len(_aTilContent_)
		_nTilStart_ = 0
		for _iTil_ = 1 to _nTilLen_
			if BothAreEqualCS(_aTilContent_[_iTil_], pItem, pCaseSensitive)
				_nTilStart_ = _iTil_
			else
				exit
			ok
		next
		if _nTilStart_ > 0
			@oList.RemoveSection(1, _nTilStart_)
		ok

	# Removes every repeat of one given item from the start of the list, in place, comparing case-sensitively.
	#
	#   pItem      the item to strip from the start
	#   returns    nothing
	#   note       TrimItemFromLeftCS(pItem, 0) ignores case; a list of only that item is emptied
	#   see        TrimItem, TrimItemFromRight
	def TrimItemFromLeft(pItem)
		This.TrimItemFromLeftCS(pItem, 1)

	def TrimItemFromRightCS(pItem, pCaseSensitive)
		if isString(pItem) and pCaseSensitive = 1
			_pTirList_ = @oList._EngineListFromContent()
			if _pTirList_ != ""
				StzEngineListTrimTrailingString(_pTirList_, pItem)
				@oList.UpdateWith(@oList._ContentFromEngineList(_pTirList_))
				StzEngineListFree(_pTirList_)
				return
			ok
		ok
		_aTirContent_ = This.Content()
		_nTirLen_ = len(_aTirContent_)
		_nTirEnd_ = 0
		for _iTir_ = _nTirLen_ to 1 step -1
			if BothAreEqualCS(_aTirContent_[_iTir_], pItem, pCaseSensitive)
				_nTirEnd_ = _iTir_
			else
				exit
			ok
		next
		if _nTirEnd_ > 0
			@oList.RemoveSection(_nTirEnd_, _nTirLen_)
		ok

	# Removes every repeat of one given item from the end of the list, in place, comparing case-sensitively.
	#
	#   pItem      the item to strip from the end
	#   returns    nothing
	#   note       TrimItemFromRightCS(pItem, 0) ignores case; a list of only that item is emptied
	#   see        TrimItem, TrimItemFromLeft
	def TrimItemFromRight(pItem)
		This.TrimItemFromRightCS(pItem, 1)

	  #======================================================#
	 #   COMPACT (REMOVE ALL EMPTY ITEMS)                    #
	#======================================================#

	# Removes from the whole list the blank texts and the empty sublists, in place, and keeps everything else.
	#
	#   returns    nothing; use CompactQ to chain
	#   note       the number 0 is kept, unlike Trim
	#   see        Compacted, StripNulls
	#@ aka  Remove the blank strings (whitespace-only) and empty sublists throughout the list (mutating).
	def Compact()
		_aCpContent_ = This.Content()
		_nCpLen_ = len(_aCpContent_)
		_aCpResult_ = []

		for _iCp_ = 1 to _nCpLen_
			if isString(_aCpContent_[_iCp_])
				if ring_trim(_aCpContent_[_iCp_]) != ""
					@AddItem(_aCpResult_, _aCpContent_[_iCp_])
				ok
			but isList(_aCpContent_[_iCp_])
				if len(_aCpContent_[_iCp_]) > 0
					@AddItem(_aCpResult_, _aCpContent_[_iCp_])
				ok
			else
				@AddItem(_aCpResult_, _aCpContent_[_iCp_])
			ok
		next

		@oList.Update(_aCpResult_)

		def CompactQ()
			This.Compact()
			return This

	# Returns a copy of the list without its blank texts and empty sublists, leaving the object unchanged.
	#
	#   returns    a list
	#   see        Compact
	def Compacted()
		_o = new stzListTrimmer(@oList.Content())
		_o.Compact()
		return _o.Content()

	  #======================================================#
	 #   SQUEEZE (REMOVE CONSECUTIVE DUPLICATE EMPTY ITEMS) #
	#======================================================#

	# Reduces each run of blank texts to the first of them, in place.
	#
	#   returns    nothing; use SqueezeQ to chain
	#   note       only texts count; a run mixing "" and "  " keeps the first one as it is
	#   see        Squeezed, Compact
	#@ aka  Collapse each consecutive run of blank strings to a single one (mutating).
	def Squeeze()
		_aSqContent_ = This.Content()
		_nSqLen_ = len(_aSqContent_)
		if _nSqLen_ < 2
			return
		ok

		_aSqResult_ = [ _aSqContent_[1] ]
		for _iSq_ = 2 to _nSqLen_
			_bSqEmpty1_ = (isString(_aSqContent_[_iSq_-1]) and ring_trim(_aSqContent_[_iSq_-1]) = "")
			_bSqEmpty2_ = (isString(_aSqContent_[_iSq_]) and ring_trim(_aSqContent_[_iSq_]) = "")
			if NOT (_bSqEmpty1_ and _bSqEmpty2_)
				@AddItem(_aSqResult_, _aSqContent_[_iSq_])
			ok
		next

		@oList.Update(_aSqResult_)

		def SqueezeQ()
			This.Squeeze()
			return This

	# Returns a copy of the list with each run of blank texts reduced to one, leaving the object unchanged.
	#
	#   returns    a list
	#   see        Squeeze
	def Squeezed()
		_o = new stzListTrimmer(@oList.Content())
		_o.Squeeze()
		return _o.Content()

	  #======================================================#
	 #   STRIP NULLS (REMOVE NULLS AND EMPTY STRINGS)      #
	#======================================================#

	# Removes the empty texts from the whole list, in place; a text of spaces is kept.
	#
	#   returns    nothing; use StripNullsQ to chain
	#   note       Compact removes blank texts too
	#   see        NullsStripped, Compact
	def StripNulls()
		_aSnContent_ = This.Content()
		_nSnLen_ = len(_aSnContent_)
		_aSnResult_ = []

		for _iSn_ = 1 to _nSnLen_
			if isString(_aSnContent_[_iSn_])
				if _aSnContent_[_iSn_] != "" and _aSnContent_[_iSn_] != ""
					@AddItem(_aSnResult_, _aSnContent_[_iSn_])
				ok
			but isNull(_aSnContent_[_iSn_])
				# skip
			else
				@AddItem(_aSnResult_, _aSnContent_[_iSn_])
			ok
		next

		@oList.Update(_aSnResult_)

		def StripNullsQ()
			This.StripNulls()
			return This

	# Returns a copy of the list without its empty texts, leaving the object unchanged.
	#
	#   returns    a list
	#   see        StripNulls
	def NullsStripped()
		_o = new stzListTrimmer(@oList.Content())
		_o.StripNulls()
		return _o.Content()

	  #======================================================#
	 #   TRIM TO SIZE (KEEP ONLY FIRST N ITEMS)            #
	#======================================================#

	# Keeps only the first n items of the list, in place.
	#
	#   n          how many items to keep
	#   returns    nothing; use TrimToSizeQ to chain
	#   note       an n larger than the list changes nothing; 0 or a negative n empties the list
	#              without an error
	#   see        TrimmedToSize
	def TrimToSize(n)
		_aTtsContent_ = This.Content()
		_nTtsLen_ = len(_aTtsContent_)
		if n >= _nTtsLen_
			return
		ok

		_aTtsResult_ = []
		for _iTts_ = 1 to n
			@AddItem(_aTtsResult_, _aTtsContent_[_iTts_])
		next

		@oList.Update(_aTtsResult_)

		def TrimToSizeQ(n)
			This.TrimToSize(n)
			return This

	# Returns the first n items of the list, leaving the object unchanged.
	#
	#   n          how many items to keep
	#   returns    a list; the whole list when n is larger
	#   see        TrimToSize
	def TrimmedToSize(n)
		_aTtdsContent_ = This.Content()
		_nTtdsLen_ = len(_aTtdsContent_)
		if n >= _nTtdsLen_
			return _aTtdsContent_
		ok
		_aTtdsResult_ = []
		for _iTtds_ = 1 to n
			@AddItem(_aTtdsResult_, _aTtdsContent_[_iTtds_])
		next
		return _aTtdsResult_

	  #======================================================#
	 #   TRIM WHERE (REMOVE ITEMS MATCHING CONDITION)       #
	#======================================================#

	def TrimW(pcCondition)
		_cTwNegated_ = "not (" + _StzStripBraces(pcCondition) + ")"
		_aTwResult_ = @oList.Filter(_cTwNegated_)
		@oList.Update(_aTwResult_)

		def TrimWQ(pcCondition)
			This.TrimW(pcCondition)
			return This

	def TrimmedW(pcCondition)
		_o = new stzListTrimmer(@oList.Content())
		_o.TrimW(pcCondition)
		return _o.Content()
