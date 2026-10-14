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

# Writes a list out as text: as Ring code, with every item a text, joined with a separator, or converted between numbers and texts and in case.
#
# It is the writing-out helper of stzList, which builds one over itself for its Stringify,
# ToListInAString and ToListInAStringInShortForm methods; build one with new stzListStringify when
# you only need a text form. It works on its own copy, so a stzList passed in is never changed. A
# verb (Stringify, StringifyLists, StringifyObjects, Singlify) converts the held list in place and
# returns nothing, its Q form returning the stringifier for chaining; the past-tense forms
# (Stringified, ListsStringified, ObjectsStringified, Singlified) and the others (Lowercased,
# Uppercased, NumbersToStrings, StringsToNumbers, Join, ToCode) return the result and leave the
# stringifier alone. A number with decimals is written with two of them: 2.5 reads 2.50.
# StringsToNumbers raises on a text that is not numeric, and Join turns a sublist into an empty
# text. An object is written as the name of its variable, which is @noname when it has none. Hebrew,
# Arabic and emoji items are texts like any other.
#
#   receiver   o1 = new stzListStringify([ "a", 12, 2.5, [ 1, "b" ] ])
#   example    ? o1.ToCode()
#              #--> [ "a", 12, 2.50, [ 1, "b" ] ]
#              ? @@( o1.Stringified() )
#              #--> [ "a", "12", "2.50", '[ 1, "b" ]' ]
#              o2 = new stzListStringify([ "a", "b", 3, "c" ])
#              ? o2.Join("-")
#              #--> a-b-3-c
#              o3 = new stzListStringify([ 3, 4, 5, 6 ])
#              ? o3.ToListInAStringInShortForm()
#              #--> 3:6
#              o4 = new stzListStringify([ 1, 1, 2, 2, 2, 1 ])
#              ? @@( o4.Singlified() )
#              #--> [ 1, 2, 1 ]
#              o5 = new stzListStringify([ "12", "3.5", 4 ])
#              ? @@( o5.StringsToNumbers() )
#              #--> [ 12, 3.50, 4 ]
#              o6 = new stzListStringify([ "שלום", "😀", "x" ])
#              ? o6.Join("|")
#              #--> שלום|😀|x
#   see        stzList, stzString, stzListFlattener
class stzListStringify from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a stringifier over a list, given as a list or as a stzList object.
	#
	#   pListOrObj   the list to write out, or a stzList whose content is copied, any other value
	#                raises an error
	#   returns      nothing; the object is built
	#   note         the stringifier works on its own copy: Stringify and its kin never change the
	#                list or the stzList you passed in, so read the result with Content
	#   see          Content, ToCode
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

	# Returns the list as it stands now, after the in-place conversions made so far.
	#
	#   returns    a list
	#   see        NumberOfItems, Stringified
	def Content()
		return @oList.Content()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfItems, Content
	def IsEmpty()
		return @oList.IsEmpty()

	  #------------------------------------------------------------#
	 #  TRANSFORMING THE LIST TO ITS REPRESENTATION IN RING CODE  #
	#------------------------------------------------------------#

	# Returns the list written as Ring code, in one text.
	#
	#   returns    a text
	#   note       [ "a", 12, 2.5 ] gives the text [ "a", 12, 2.50 ], a number with decimals showing
	#              two of them; ToCodeQ returns the text as a stzString
	#   see        ComputableForm, ToListInAStringInShortForm
	def ToCode()
		_cTcResult_ = @@( This.Content() )
		return _cTcResult_

		def ToCodeQ()
			return new stzString(This.ToCode())

	  #------------------------------------------------------------------#
	 #  STRINGIFYING THE LIST (ALL ITEMS ARE FORCED TO BECOME STRINGS)  #
	#------------------------------------------------------------------#

	# Turns every item into a text, in place: numbers as digits, sublists as code, objects by their variable name.
	#
	#   returns    nothing; the content changes. StringifyQ returns the stringifier for chaining
	#   note       [ "a", 12, 2.5, [ 1, "b" ] ] becomes "a", "12", "2.50" and the text [ 1, "b" ];
	#              texts stay as they are; StringifyItems is the same call
	#   see        Stringified, StringifyLists, StringifyObjects
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

		# Turns every item into a text, in place: numbers as digits, sublists as code, objects by their variable name.
		#
		#   returns    nothing; the content changes
		#   note       the same call as Stringify
		#   see        Stringify, Stringified
		def StringifyItems()
			This.Stringify()

	# Returns the list with every item turned into a text, leaving the stringifier as it was.
	#
	#   returns    a list of texts
	#   note       StringifiedItems is the same call
	#   see        Stringify, ListsStringified
	def Stringified()
		_acSdResult_ = @oList.Copy().StringifyQ().Content()
		return _acSdResult_

		def StringifiedItems()
			return This.Stringified()

	  #------------------------------------------------------------------#
	 #  STRINGIFYING THE LISTS INSIDE THE LIST                          #
	#------------------------------------------------------------------#

	# Turns only the sublists into code texts, in place, leaving the other items as they are.
	#
	#   returns    nothing; the content changes. StringifyListsQ returns the stringifier for
	#              chaining
	#   note       [ "a", 12, [ 1, "b" ] ] keeps "a" and 12 and turns the sublist into the text [ 1,
	#              "b" ]
	#   see        ListsStringified, Stringify
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

	# Returns the list with only its sublists turned into code texts, leaving the stringifier as it was.
	#
	#   returns    a list
	#   see        StringifyLists, Stringified
	def ListsStringified()
		# Was @oList.Copy().StringifyListsQ -- not on core stzList
		_o = new stzListStringify(@oList.Content())
		_o.StringifyLists()
		return _o.Content()

	  #------------------------------------------------------------------#
	 #  STRINGIFYING THE OBJECTS INSIDE THE LIST                        #
	#------------------------------------------------------------------#

	# Turns only the objects of the list into texts, in place, leaving the other items as they are.
	#
	#   returns    nothing; the content changes. StringifyObjectsQ returns the stringifier for
	#              chaining
	#   note       an object is replaced by the name of the variable that holds it, which reads
	#              @noname when the object was created without a name, as a stzString held in a
	#              plain variable does
	#   see        ObjectsStringified, Stringify
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

	# Returns the list with only its objects turned into texts, leaving the stringifier as it was.
	#
	#   returns    a list
	#   note       the objects read @noname when they have no variable name
	#   see        StringifyObjects, Stringified
	def ObjectsStringified()
		# Was @oList.Copy().StringifyObjectsQ -- not on core stzList
		_o = new stzListStringify(@oList.Content())
		_o.StringifyObjects()
		return _o.Content()

	  #================================================#
	 #   SINGLIFY -- REMOVE CONSECUTIVE DUPLICATES     #
	#================================================#

	# Collapses each run of identical neighbouring items into one item, in place.
	#
	#   returns    nothing; the content changes. SinglifyQ returns the stringifier for chaining
	#   note       only neighbours are compared, so 1 1 2 2 2 1 becomes 1 2 1 and not 1 2; case
	#              counts, so a a A becomes a A
	#   see        Singlified, Stringify
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

	# Returns the list with each run of identical neighbouring items collapsed into one, leaving the stringifier as it was.
	#
	#   returns    a list
	#   note       1 1 2 2 2 1 gives 1 2 1; sublists are compared by content
	#   see        Singlify
	def Singlified()
		# Was @oList.Copy().SinglifyQ -- not on core stzList
		_o = new stzListStringify(@oList.Content())
		_o.Singlify()
		return _o.Content()

	  #===============================#
	 #   COMPUTABLE FORM             #
	#===============================#

	# Returns the list written as Ring code, in one text.
	#
	#   returns    a text
	#   note       the same answer as ToCode; ToListInString and ToListInAString are the same call
	#   see        ToCode, ToListInAStringInShortForm
	def ComputableForm()
		return @@( This.Content() )

		def ToListInString()
			return This.ComputableForm()

		def ToListInAString()
			return This.ComputableForm()

	# Returns the list as a range literal when it is a run of whole numbers going up or down by one, and as code otherwise.
	#
	#   returns    a text
	#   note       [ 3, 4, 5, 6 ] gives 3:6 and [ 5, 4, 3 ] gives 5:3, while [ 1, 3, 5 ], [ 7 ] and
	#              [ "x", 5 ] fall back to the code form; ToListInStringInShortForm and
	#              ToListInShortForm are the same call
	#   see        ToCode, ComputableForm
	#@ aka  Short form: a contiguous run of integers (a, a+1, ..., b -- or the descending a, a-1, ..., b) collapses to the range literal "a:b". Anything else falls back to the full stringified list.
	def ToListInAStringInShortForm()
		_aTlsfC_ = This.Content()
		_nTlsfN_ = len(_aTlsfC_)
		if _nTlsfN_ >= 2 and isNumber(_aTlsfC_[1]) and isNumber(_aTlsfC_[2])
			_nTlsfStep_ = _aTlsfC_[2] - _aTlsfC_[1]
			if _nTlsfStep_ = 1 or _nTlsfStep_ = -1
				_bTlsfRange_ = 1
				for _iTlsf_ = 2 to _nTlsfN_
					if NOT ( isNumber(_aTlsfC_[_iTlsf_]) and
						 _aTlsfC_[_iTlsf_] = _aTlsfC_[_iTlsf_ - 1] + _nTlsfStep_ )
						_bTlsfRange_ = 0
						exit
					ok
				next
				if _bTlsfRange_
					return "" + _aTlsfC_[1] + ":" + _aTlsfC_[_nTlsfN_]
				ok
			ok
		ok
		return This.ToListInAString()

		def ToListInAStringInShortFormQ()
			return new stzString( This.ToListInAStringInShortForm() )

	def ToListInStringInShortForm()
		return This.ToListInAStringInShortForm()

		def ToListInShortForm()
			return This.ToListInAStringInShortForm()

	  #======================================================#
	 #   JOIN -- CONCATENATE ITEMS INTO A STRING            #
	#======================================================#

	# Concatenates the items into one text, with a separator between two items.
	#
	#   pcSep      the text put between two items
	#   returns    a text
	#   note       numbers are written as digits; a sublist among the items becomes an empty text,
	#              so 1, [ 2, 3 ], 4 joined with + gives 1++4; an empty list gives an empty text;
	#              Joined and JoinWith are the same call and JoinQ returns a stzString
	#   see        ToCode, Stringified
	def Join(pcSep)
		_pJnList_ = @oList._EngineListFromContent()
		if _pJnList_ != ""
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

	# Returns the list with every text in lower case, leaving the other items as they are.
	#
	#   returns    a list
	#   note       Hebrew and other scripts without case are unchanged and accented letters are
	#              folded (É becomes é); the stringifier is left as it was
	#   see        Uppercased, Stringified
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

	# Returns the list with every text in upper case, leaving the other items as they are.
	#
	#   returns    a list
	#   note       accented letters are folded (é becomes É) and ß becomes SS, which lengthens the
	#              text; scripts without case are unchanged; the stringifier is left as it was
	#   see        Lowercased, Stringified
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

	# Returns the list with every number written as a text, leaving the other items as they are.
	#
	#   returns    a list
	#   note       2.5 becomes "2.50"; sublists are not touched, where Stringified writes them as
	#              code; the stringifier is left as it was
	#   see        StringsToNumbers, Stringified
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

	# Returns the list with every numeric text turned into a number, leaving the other items as they are.
	#
	#   returns    a list
	#   note       "12", "3.5" and "-2" become numbers; an empty text becomes 0; the stringifier is
	#              left as it was
	#   warning    a text that is not numeric raises error R41 Invalid numeric string, instead of
	#              being left alone ("abc", "x" and "7x" were tried)
	#   see        NumbersToStrings
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
