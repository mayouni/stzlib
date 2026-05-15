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

class stzListStringify from stzList

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

		This.UpdateWith(_aContent_)

		def StringifyQ()
			This.Stringify()
			return This

		def StringifyItems()
			This.Stringify()

	def Stringified()
		_acResult_ = This.Copy().StringifyQ().Content()
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

		This.UpdateWith(_aContent_)

		def StringifyListsQ()
			This.StringifyLists()
			return This

	def ListsStringified()
		return This.Copy().StringifyListsQ().Content()

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

		This.UpdateWith(_aContent_)

		def StringifyObjectsQ()
			This.StringifyObjects()
			return This

	def ObjectsStringified()
		return This.Copy().StringifyObjectsQ().Content()

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

		This.UpdateWith(_aResult_)

		def SinglifyQ()
			This.Singlify()
			return This

	def Singlified()
		return This.Copy().SinglifyQ().Content()

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
