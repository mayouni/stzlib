#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSTRINGIFY           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List stringify subclass -- converting list  #
#                  items to strings, code representation,      #
#                  singlification, and yield operations.        #
#                  For aliases, use stzListStringifyXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListStringify

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
			StzRaise("Can't create stzListStringify! Parameter must be a list or stzList object.")
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

	  #------------------------------------------------------------#
	 #  TRANSFORMING THE LIST TO ITS REPRESENTATION IN RING CODE  #
	#------------------------------------------------------------#

	def ToCode()
		_cTcResult_ = @@( This.Content() )
		return _cTcResult_

		def ToCodeQ()
			return new stzString(This.ToCode())

	  #------------------------------------------------------------------#
	 #  STRINGIFYING THE LIST (ALL ITEMS ARE FORCED TO BECOME STRINGS)  #
	#------------------------------------------------------------------#

	def Stringify()

		_aSfContent_ = This.Content()
		_nSfLen_ = len(_aSfContent_)

		for _iSf_ = 1 to _nSfLen_

			if isString(_aSfContent_[_iSf_])
				loop

			but isNumber(_aSfContent_[_iSf_])
				_aSfContent_[_iSf_] = ""+ _aSfContent_[_iSf_]

			but isList(_aSfContent_[_iSf_])
				_aSfContent_[_iSf_] = @@(_aSfContent_[_iSf_])

			but isObject(_aSfContent_[_iSf_])
				_aSfContent_[_iSf_] = @ObjectVarName(_aSfContent_[_iSf_])
			ok

		next

		@oList.UpdateWith(_aSfContent_)

		def StringifyQ()
			This.Stringify()
			return This

		def StringifyItems()
			This.Stringify()

	def Stringified()
		_acSdResult_ = @oList.Copy().StringifyQ().Content()
		return _acSdResult_

		def StringifiedItems()
			return This.Stringified()

	  #------------------------------------------------------------------#
	 #  STRINGIFYING THE LISTS INSIDE THE LIST                          #
	#------------------------------------------------------------------#

	def StringifyLists()
		_aSlContent_ = This.Content()
		_nSlLen_ = len(_aSlContent_)

		for _iSl_ = 1 to _nSlLen_
			if isList(_aSlContent_[_iSl_])
				_aSlContent_[_iSl_] = @@(_aSlContent_[_iSl_])
			ok
		next

		@oList.UpdateWith(_aSlContent_)

		def StringifyListsQ()
			This.StringifyLists()
			return This

	def ListsStringified()
		return @oList.Copy().StringifyListsQ().Content()

	  #------------------------------------------------------------------#
	 #  STRINGIFYING THE OBJECTS INSIDE THE LIST                        #
	#------------------------------------------------------------------#

	def StringifyObjects()
		_aSoContent_ = This.Content()
		_nSoLen_ = len(_aSoContent_)

		for _iSo_ = 1 to _nSoLen_
			if isObject(_aSoContent_[_iSo_])
				_aSoContent_[_iSo_] = @ObjectVarName(_aSoContent_[_iSo_])
			ok
		next

		@oList.UpdateWith(_aSoContent_)

		def StringifyObjectsQ()
			This.StringifyObjects()
			return This

	def ObjectsStringified()
		return @oList.Copy().StringifyObjectsQ().Content()

	  #================================================#
	 #   SINGLIFY -- REMOVE CONSECUTIVE DUPLICATES     #
	#================================================#

	def Singlify()
		_aSgContent_ = This.Content()
		_nSgLen_ = len(_aSgContent_)

		if _nSgLen_ <= 1
			return
		ok

		_aSgResult_ = [ _aSgContent_[1] ]

		for _iSg_ = 2 to _nSgLen_
			if NOT Q(_aSgContent_[_iSg_]).IsEqualTo(_aSgContent_[_iSg_ - 1])
				@AddItem(_aSgResult_, _aSgContent_[_iSg_])
			ok
		next

		@oList.UpdateWith(_aSgResult_)

		def SinglifyQ()
			This.Singlify()
			return This

	def Singlified()
		return @oList.Copy().SinglifyQ().Content()

	  #===============================#
	 #   COMPUTABLE FORM             #
	#===============================#

	def ComputableForm()
		return @@( This.Content() )

		def ToListInString()
			return This.ComputableForm()

		def ToListInAString()
			return This.ComputableForm()

	def ToListInStringInShortForm()
		_cTlisfResult_ = This.ToCodeQ().ToListInShortForm()
		return _cTlisfResult_

		def ToListInShortForm()
			return This.ToListInStringInShortForm()

	  #======================================================#
	 #   JOIN -- CONCATENATE ITEMS INTO A STRING            #
	#======================================================#

	def Join(pcSep)
		_pJnList_ = @oList._EngineListFromContent()
		if _pJnList_ != NULL
			_cJnResult_ = StzEngineListJoin(_pJnList_, pcSep)
			StzEngineListFree(_pJnList_)
			return _cJnResult_
		ok
		_aJnContent_ = This.Content()
		_nJnLen_ = len(_aJnContent_)
		_cJnFallback_ = ""
		for _iJn_ = 1 to _nJnLen_
			if _iJn_ > 1
				_cJnFallback_ += pcSep
			ok
			if isString(_aJnContent_[_iJn_])
				_cJnFallback_ += _aJnContent_[_iJn_]
			else
				_cJnFallback_ += "" + _aJnContent_[_iJn_]
			ok
		next
		return _cJnFallback_

		def JoinQ(pcSep)
			return new stzString(This.Join(pcSep))

		def Joined(pcSep)
			return This.Join(pcSep)

	def JoinWith(pcSep)
		return This.Join(pcSep)

	  #======================================================#
	 #   LOWERCASED / UPPERCASED                            #
	#======================================================#

	def Lowercased()
		_aLcContent_ = This.Content()
		_nLcLen_ = len(_aLcContent_)
		_aLcResult_ = []
		for _iLc_ = 1 to _nLcLen_
			if isString(_aLcContent_[_iLc_])
				@AddItem(_aLcResult_, StzLower(_aLcContent_[_iLc_]))
			else
				@AddItem(_aLcResult_, _aLcContent_[_iLc_])
			ok
		next
		return _aLcResult_

		def LowercasedQ()
			return new stzList(This.Lowercased())

	def Uppercased()
		_aUcContent_ = This.Content()
		_nUcLen_ = len(_aUcContent_)
		_aUcResult_ = []
		for _iUc_ = 1 to _nUcLen_
			if isString(_aUcContent_[_iUc_])
				@AddItem(_aUcResult_, StzUpper(_aUcContent_[_iUc_]))
			else
				@AddItem(_aUcResult_, _aUcContent_[_iUc_])
			ok
		next
		return _aUcResult_

		def UppercasedQ()
			return new stzList(This.Uppercased())

	  #======================================================#
	 #   NUMBERS TO STRINGS / STRINGS TO NUMBERS            #
	#======================================================#

	def NumbersToStrings()
		_aNtsContent_ = This.Content()
		_nNtsLen_ = len(_aNtsContent_)
		_aNtsResult_ = []
		for _iNts_ = 1 to _nNtsLen_
			if isNumber(_aNtsContent_[_iNts_])
				@AddItem(_aNtsResult_, "" + _aNtsContent_[_iNts_])
			else
				@AddItem(_aNtsResult_, _aNtsContent_[_iNts_])
			ok
		next
		return _aNtsResult_

	def StringsToNumbers()
		_aStnContent_ = This.Content()
		_nStnLen_ = len(_aStnContent_)
		_aStnResult_ = []
		for _iStn_ = 1 to _nStnLen_
			if isString(_aStnContent_[_iStn_]) and isNumber(0 + _aStnContent_[_iStn_])
				@AddItem(_aStnResult_, 0 + _aStnContent_[_iStn_])
			else
				@AddItem(_aStnResult_, _aStnContent_[_iStn_])
			ok
		next
		return _aStnResult_
