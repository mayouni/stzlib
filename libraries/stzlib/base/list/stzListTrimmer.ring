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

class stzListTrimmer from stzObject

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
			StzRaise("Can't create stzListTrimmer! Parameter must be a list or stzList object.")
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

	def Trim()
		This.TrimCS(1)

		def TrimQ()
			return This.TrimCSQ(1)

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

	def TrimLeft()
		This.TrimLeftCS(1)

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
			return TRUE
		but isString(pItem) and ring_trim(pItem) = ""
			return TRUE
		but isList(pItem) and len(pItem) = 0
			return TRUE
		but isObject(pItem) and @IsFalseObject(pItem)
			return TRUE
		ok
		return FALSE

		def TrimRightCSQ(pCaseSensitive)
			This.TrimRightCS(pCaseSensitive)
			return This

	def TrimRight()
		This.TrimRightCS(1)

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

	def TrimItem(pItem)
		This.TrimItemCS(pItem, 1)

		def TrimItemQ(pItem)
			This.TrimItem(pItem)
			return This

	def TrimItemFromLeftCS(pItem, pCaseSensitive)
		if isString(pItem) and pCaseSensitive = 1
			_pTilList_ = @oList._EngineListFromContent()
			if _pTilList_ != NULL
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

	def TrimItemFromLeft(pItem)
		This.TrimItemFromLeftCS(pItem, 1)

	def TrimItemFromRightCS(pItem, pCaseSensitive)
		if isString(pItem) and pCaseSensitive = 1
			_pTirList_ = @oList._EngineListFromContent()
			if _pTirList_ != NULL
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

	def TrimItemFromRight(pItem)
		This.TrimItemFromRightCS(pItem, 1)

	  #======================================================#
	 #   COMPACT (REMOVE ALL EMPTY ITEMS)                    #
	#======================================================#

	# Remove the blank strings (whitespace-only) and empty sublists
	# throughout the list (mutating).
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

	def Compacted()
		_o = new stzListTrimmer(@oList.Content())
		_o.Compact()
		return _o.Content()

	  #======================================================#
	 #   SQUEEZE (REMOVE CONSECUTIVE DUPLICATE EMPTY ITEMS) #
	#======================================================#

	# Collapse each consecutive run of blank strings to a single one
	# (mutating).
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

	def Squeezed()
		_o = new stzListTrimmer(@oList.Content())
		_o.Squeeze()
		return _o.Content()

	  #======================================================#
	 #   STRIP NULLS (REMOVE NULLS AND EMPTY STRINGS)      #
	#======================================================#

	def StripNulls()
		_aSnContent_ = This.Content()
		_nSnLen_ = len(_aSnContent_)
		_aSnResult_ = []

		for _iSn_ = 1 to _nSnLen_
			if isString(_aSnContent_[_iSn_])
				if _aSnContent_[_iSn_] != "" and _aSnContent_[_iSn_] != NULL
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

	def NullsStripped()
		_o = new stzListTrimmer(@oList.Content())
		_o.StripNulls()
		return _o.Content()

	  #======================================================#
	 #   TRIM TO SIZE (KEEP ONLY FIRST N ITEMS)            #
	#======================================================#

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
