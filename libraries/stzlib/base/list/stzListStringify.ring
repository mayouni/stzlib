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
		cResult = @@( This.Content() )
		return cResult

		def ToCodeQ()
			return new stzString(This.ToCode())

	  #------------------------------------------------------------------#
	 #  STRINGIFYING THE LIST (ALL ITEMS ARE FORCED TO BECOME STRINGS)  #
	#------------------------------------------------------------------#

	def Stringify()

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		for @i = 1 to _nLen_

			if isString(_aContent_[@i])
				loop

			but isNumber(_aContent_[@i])
				_aContent_[@i] = ""+ _aContent_[@i]

			but isList(_aContent_[@i])
				_aContent_[@i] = @@(_aContent_[@i])

			but isObject(_aContent_[@i])
				_aContent_[@i] = @ObjectVarName(_aContent_[@i])
			ok

		next

		@oList.UpdateWith(_aContent_)

		def StringifyQ()
			This.Stringify()
			return This

		def StringifyItems()
			This.Stringify()

	def Stringified()
		_acResult_ = @oList.Copy().StringifyQ().Content()
		return _acResult_

		def StringifiedItems()
			return This.Stringified()

	  #------------------------------------------------------------------#
	 #  STRINGIFYING THE LISTS INSIDE THE LIST                          #
	#------------------------------------------------------------------#

	def StringifyLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		for @i = 1 to _nLen_
			if isList(_aContent_[@i])
				_aContent_[@i] = @@(_aContent_[@i])
			ok
		next

		@oList.UpdateWith(_aContent_)

		def StringifyListsQ()
			This.StringifyLists()
			return This

	def ListsStringified()
		return @oList.Copy().StringifyListsQ().Content()

	  #------------------------------------------------------------------#
	 #  STRINGIFYING THE OBJECTS INSIDE THE LIST                        #
	#------------------------------------------------------------------#

	def StringifyObjects()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		for @i = 1 to _nLen_
			if isObject(_aContent_[@i])
				_aContent_[@i] = @ObjectVarName(_aContent_[@i])
			ok
		next

		@oList.UpdateWith(_aContent_)

		def StringifyObjectsQ()
			This.StringifyObjects()
			return This

	def ObjectsStringified()
		return @oList.Copy().StringifyObjectsQ().Content()

	  #================================================#
	 #   SINGLIFY -- REMOVE CONSECUTIVE DUPLICATES     #
	#================================================#

	def Singlify()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ <= 1
			return
		ok

		_aResult_ = [ _aContent_[1] ]

		for @i = 2 to _nLen_
			if NOT Q(_aContent_[@i]).IsEqualTo(_aContent_[@i - 1])
				_aResult_ + _aContent_[@i]
			ok
		next

		@oList.UpdateWith(_aResult_)

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
		cResult = This.ToCodeQ().ToListInShortForm()
		return cResult

		def ToListInShortForm()
			return This.ToListInStringInShortForm()

	  #======================================================#
	 #   JOIN -- CONCATENATE ITEMS INTO A STRING            #
	#======================================================#

	def Join(pcSep)
		_pJnList = @oList._EngineListFromContent()
		if _pJnList != NULL
			_cJnResult = StzEngineListJoin(_pJnList, pcSep)
			StzEngineListFree(_pJnList)
			return _cJnResult
		ok
		aContent = This.Content()
		nLen = len(aContent)
		cResult = ""
		for i = 1 to nLen
			if i > 1
				cResult += pcSep
			ok
			if isString(aContent[i])
				cResult += aContent[i]
			else
				cResult += "" + aContent[i]
			ok
		next
		return cResult

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
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if isString(aContent[i])
				aResult + StzLower(aContent[i])
			else
				aResult + aContent[i]
			ok
		next
		return aResult

		def LowercasedQ()
			return new stzList(This.Lowercased())

	def Uppercased()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if isString(aContent[i])
				aResult + StzUpper(aContent[i])
			else
				aResult + aContent[i]
			ok
		next
		return aResult

		def UppercasedQ()
			return new stzList(This.Uppercased())

	  #======================================================#
	 #   NUMBERS TO STRINGS / STRINGS TO NUMBERS            #
	#======================================================#

	def NumbersToStrings()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if isNumber(aContent[i])
				aResult + ("" + aContent[i])
			else
				aResult + aContent[i]
			ok
		next
		return aResult

	def StringsToNumbers()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if isString(aContent[i]) and isNumber(0 + aContent[i])
				aResult + (0 + aContent[i])
			else
				aResult + aContent[i]
			ok
		next
		return aResult
