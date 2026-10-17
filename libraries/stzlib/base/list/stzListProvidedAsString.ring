


# Holds a list that was provided as text, such as '[ 1, 2, "A" ]', and tells its values from its variable names.
#
# The idea, from the comment in its file: a list written as text can hold values (1, "A", [ 5, "V"
# ]) or variable names (n1, aList1), and a search must be able to look for a value wherever it is
# hosted or for a variable whatever its value. The text is read, never evaluated: nothing in it is
# run and no variable is looked up.
#
# What is read. The text must be one list in square brackets (spaces, tabs and new lines around it
# and between its items are free). It is cut at the commas that sit directly in that list, so a comma
# inside a quoted text, a nested list, a pair of parentheses or braces does not cut. A quote opened
# with ', " or ` ends at the next quote of the same kind, and a backslash is an ordinary character,
# as in Ring, which has no escapes. A single trailing comma is allowed, as in Ring. Any other text
# is NOT well formed (IsWellFormed): an unclosed bracket or quote, a mismatched closer, something
# after the closing bracket, an empty item such as [ 1,, 2 ]; it has no items and every test on it
# answers FALSE.
#
# Each item is of one kind:
#   value      a number (-3, 2.5, 1e3, 0x1F), a quoted text, a :name, or a nested list (whose inside
#              is not examined)
#   variable   a bare name made of letters (accented, Hebrew or any other), digits and _, not
#              starting with a digit, optionally starting with @ or $ and optionally dotted:
#              n1, aList1, oObj1, @x, $g, oObj.name. TRUE, FALSE and NULL are names here, since
#              the text is not evaluated
#   other      anything else, such as 1+2, f(x), or :name = "v" written directly in the list
#
# The empty list [ ] holds no value and no variable name, so it is neither a list of values nor a
# list of variable names nor a mix: all three tests answer FALSE for it, as IsListOfNumbers does for
# an empty list. An item of kind other keeps a list from being only values or only variables, and
# does not prevent it from mixing both.
#
#   receiver   o1 = new stzListProvidedAsString('[ 1, "A", [ 5, "V" ] ]')
#   example    ? @@( o1.Items() )
#              #--> [ "1", '"A"', '[ 5, "V" ]' ]
#              ? o1.IsListOfValues()
#              #--> 1
#              o2 = new stzListProvidedAsString("[ n1, aList1 ]")
#              ? o2.IsListOfVariables()
#              #--> 1
#   see        stzListInString, stzList
class stzListProvidedAsString from stzObject
	_cListAsString_
	_bWellFormed_
	_aItems_
	_aKinds_

	# Builds the object from a text that spells a list, such as '[ 1, 2, "A" ]', and splits out its items and their kinds.
	#
	#   pcListAsString   the text that spells the list, in square brackets
	#   returns          nothing; the object is built, and a text that is not a well formed list gives
	#                    an object with no items
	#   note             nothing is raised for a malformed text: ask IsWellFormed
	#   see              Items, IsWellFormed
	def init(pcListAsString)
		_cListAsString_ = pcListAsString
		_bWellFormed_ = 0
		_aItems_ = []
		_aKinds_ = []

		if NOT isString(pcListAsString)
			return
		ok

		_aScanned_ = This._ScanList(pcListAsString)
		if _aScanned_[1] = 1
			_bWellFormed_ = 1
			_aItems_ = _aScanned_[2]
			_nItems_ = ring_len(_aItems_)
			for _i_ = 1 to _nItems_
				_aKinds_ + This._KindOfItem(_aItems_[_i_])
			next
		ok

	  #------------------------------------#
	 #     LIST OF VALUES OR VARIABLES    #
	#------------------------------------#
	/*
		A ListOfValues contains only values, not variable names:
		[ 1, 2, "A", [ 5, "V" ] , [ :name = "Mansour", :job = "Programmer" ] ]
		=> Only numbers, strings and lists are used.

		A ListOfVariables contains only variables, no direct values:
		[ n1, n2, aList1, oObj1 ]
		where n1, n2, aList1, and oObj1 are variables names.

		Now : why are we making this differenciation?

		To make it possible to perform two kinds of search on the items of a list:

			1. Searching for a given value (1 or 2 or "A" or [5, "V"]...)
			   whatever form it takes in the list: directly as a value or
			   hosted in a variable.

			2. Searching for a given variable (n1 or n2 or aList1 or oObj1)
			   whatever value they have.
	*/

	# Returns the items of the list text as pieces of text, cut at the top-level commas, trimmed at both ends.
	#
	# The inside of an item is kept as written, spaces included: '[ "a b", [ 1, 2 ] ]' gives
	# [ '"a b"', "[ 1, 2 ]" ].
	#
	#   returns    a list of texts; [ ] for the text '[ ]' and for a text that is not well formed
	#   see        ItemKinds, IsWellFormed
	def Items()
		return _aItems_

	# Returns the kind of each item, in order: "value", "variable" or "other".
	#
	#   returns    a list of texts, as long as Items; [ ] when the text is not well formed
	#   see        Items, IsListOfValues
	def ItemKinds()
		return _aKinds_

	# Tells whether the text is one list in square brackets, with balanced brackets and quotes.
	#
	#   returns    1 or 0
	#   note       the empty list '[ ]' is well formed; a trailing comma is accepted, an empty item
	#              between two commas is not
	#   see        Items
	def IsWellFormed()
		return _bWellFormed_

	# Tells whether the list text holds only values (numbers, quoted texts, :names, nested lists) and no variable name.
	#
	#   returns    1 or 0; 0 for the empty list, for an item of kind other and for a malformed text
	#   see        IsListOfVariables, IsListOfValuesAndVariables, ContainsOnlyValues
	def IsListOfValues()
		_bAnswer_ = This.ContainsOnlyValues()
		return _bAnswer_

	# Tells whether the list text holds only variable names (bare names) and no value.
	#
	#   returns    1 or 0; 0 for the empty list, for an item of kind other and for a malformed text
	#   see        IsListOfValues, IsListOfValuesAndVariables, ContainsOnlyVariables
	def IsListOfVariables()
		_bAnswer_ = This.ContainsOnlyVariables()
		return _bAnswer_

	# Tells whether the list text mixes at least one value with at least one variable name.
	#
	#   returns    1 or 0; 0 for the empty list, for a malformed text, and for a list that has only
	#              values or only variable names
	#   see        IsListOfValues, IsListOfVariables, ContainsValuesAndVariables
	def IsListOfValuesAndVariables()
		_bAnswer_ = This.ContainsValuesAndVariables()
		return _bAnswer_

	# Tells whether every item of the list text is a value, such as a number, a quoted text or a nested list.
	#
	#   returns    1 or 0; 0 for the empty list (it holds no value), for an item that is a variable name
	#              or of kind other, and for a malformed text
	#   see        IsListOfValues, ContainsOnlyVariables
	def ContainsOnlyValues()
		return This._AllKindsAre("value")

	# Tells whether every item of the list text is a variable name, such as n1 or aList1.
	#
	#   returns    1 or 0; 0 for the empty list (it holds no name), for an item that is a value
	#              or of kind other, and for a malformed text
	#   see        IsListOfVariables, ContainsOnlyValues
	def ContainsOnlyVariables()
		return This._AllKindsAre("variable")

	# Tells whether the list text holds at least one value and at least one variable name.
	#
	#   returns    1 or 0; 0 for the empty list, for a malformed text, and when one of the two is missing
	#   note       an item of kind other is ignored: [ 1, n1, 2+3 ] mixes both
	#   see        IsListOfValuesAndVariables, ContainsOnlyValues, ContainsOnlyVariables
	def ContainsValuesAndVariables()
		_nValues_ = 0
		_nVars_ = 0
		_nKinds_ = ring_len(_aKinds_)
		for _i_ = 1 to _nKinds_
			if strcmp(_aKinds_[_i_], "value") = 0
				_nValues_++
			but strcmp(_aKinds_[_i_], "variable") = 0
				_nVars_++
			ok
		next
		if _nValues_ > 0 and _nVars_ > 0
			return 1
		ok
		return 0

	  #--------------------------------------#
	 #     READING THE TEXT (INTERNAL)      #
	#--------------------------------------#

	def _AllKindsAre(pcKind)
		_nKinds_ = ring_len(_aKinds_)
		if _nKinds_ = 0
			return 0
		ok
		for _i_ = 1 to _nKinds_
			if strcmp(_aKinds_[_i_], pcKind) != 0
				return 0
			ok
		next
		return 1

	# Reads pcText as one list: answers [ 1, aItems ] when it is well formed, [ 0, [ ] ] otherwise.
	# Only ASCII bytes are ever tested (brackets, commas, quotes, spaces), and a byte of a multibyte
	# character is never one of them, so the items are rebuilt byte by byte and stay valid UTF-8.
	def _ScanList(pcText)
		_nLen_ = ring_len(pcText)
		_aFound_ = []
		_aStack_ = []
		_nDepth_ = 0
		_nQuote_ = 0
		_bClosed_ = 0
		_bStarted_ = 0
		_cItem_ = ""
		_cPending_ = ""

		for _i_ = 1 to _nLen_
			_cCh_ = pcText[_i_]
			_n_ = ascii(_cCh_)
			_bSpace_ = (_n_ = 32 or _n_ = 9 or _n_ = 10 or _n_ = 13)

			if _bStarted_ = 0
				if _n_ = 91
					_bStarted_ = 1
					_nDepth_ = 1
					_aStack_ + 93
				but _bSpace_ = 0
					return [ 0, [] ]
				ok

			but _bClosed_ = 1
				if _bSpace_ = 0
					return [ 0, [] ]
				ok

			but _nQuote_ != 0
				_cItem_ += _cCh_
				if _n_ = _nQuote_
					_nQuote_ = 0
				ok

			but _bSpace_ = 1
				if ring_len(_cItem_) > 0
					_cPending_ += _cCh_
				ok

			but _n_ = 44 and _nDepth_ = 1
				if ring_len(_cItem_) = 0
					return [ 0, [] ]
				ok
				_aFound_ + _cItem_
				_cItem_ = ""
				_cPending_ = ""

			but _n_ = 93 or _n_ = 41 or _n_ = 125
				if _n_ != _aStack_[_nDepth_]
					return [ 0, [] ]
				ok
				_nDepth_--
				if _nDepth_ = 0
					_bClosed_ = 1
					if ring_len(_cItem_) > 0
						_aFound_ + _cItem_
					ok
					_cItem_ = ""
					_cPending_ = ""
				else
					_cItem_ += _cPending_ + _cCh_
					_cPending_ = ""
				ok

			but _n_ = 91 or _n_ = 40 or _n_ = 123
				_nDepth_++
				if _nDepth_ > ring_len(_aStack_)
					_aStack_ + 0
				ok
				if _n_ = 91
					_aStack_[_nDepth_] = 93
				but _n_ = 40
					_aStack_[_nDepth_] = 41
				else
					_aStack_[_nDepth_] = 125
				ok
				_cItem_ += _cPending_ + _cCh_
				_cPending_ = ""

			but _n_ = 34 or _n_ = 39 or _n_ = 96
				_nQuote_ = _n_
				_cItem_ += _cPending_ + _cCh_
				_cPending_ = ""

			else
				_cItem_ += _cPending_ + _cCh_
				_cPending_ = ""
			ok
		next

		if _bClosed_ = 0
			return [ 0, [] ]
		ok
		return [ 1, _aFound_ ]

	# The kind of one trimmed item: "value", "variable" or "other".
	def _KindOfItem(pcItem)
		_nLen_ = ring_len(pcItem)
		if _nLen_ = 0
			return "other"
		ok
		_n1_ = ascii(pcItem[1])

		# a quoted text must be ONE quoted text: the first quote closes at the next one of its kind
		if _n1_ = 34 or _n1_ = 39 or _n1_ = 96
			for _j_ = 2 to _nLen_
				if ascii(pcItem[_j_]) = _n1_
					if _j_ = _nLen_
						return "value"
					ok
					return "other"
				ok
			next
			return "other"
		ok

		# a nested list must be ONE list: the scan fails if anything follows its closing bracket
		if _n1_ = 91
			_aNested_ = This._ScanList(pcItem)
			if _aNested_[1] = 1
				return "value"
			ok
			return "other"
		ok

		if This._IsNumberText(pcItem) = 1
			return "value"
		ok

		# :name is a Ring text
		if _n1_ = 58
			if _nLen_ > 1
				if This._IsNameFrom(pcItem, 2, 0) = 1
					return "value"
				ok
			ok
			return "other"
		ok

		_nFrom_ = 1
		if _n1_ = 64 or _n1_ = 36
			_nFrom_ = 2
		ok
		if This._IsNameFrom(pcItem, _nFrom_, 1) = 1
			return "variable"
		ok
		return "other"

	# TRUE for a name from byte pnFrom to the end: letters (ASCII or any byte of a multibyte
	# letter), digits and _, not starting with a digit; pbDotted allows name.name.
	def _IsNameFrom(pcText, pnFrom, pbDotted)
		_nLen_ = ring_len(pcText)
		_bNeedStart_ = 1
		_i_ = pnFrom
		while _i_ <= _nLen_
			_n_ = ascii(pcText[_i_])
			_bLetter_ = ((_n_ >= 65 and _n_ <= 90) or (_n_ >= 97 and _n_ <= 122) or _n_ = 95 or _n_ >= 128)
			_bDigit_ = (_n_ >= 48 and _n_ <= 57)
			if _bNeedStart_ = 1
				if _bLetter_ = 0
					return 0
				ok
				_bNeedStart_ = 0
			but _bLetter_ = 1 or _bDigit_ = 1
				# inside a name
			but _n_ = 46 and pbDotted = 1
				_bNeedStart_ = 1
			else
				return 0
			ok
			_i_++
		end
		if _bNeedStart_ = 1
			return 0
		ok
		return 1

	# TRUE for a number written as Ring writes it: [+-]digits[.digits][e[+-]digits], or [+-]0xHEX.
	def _IsNumberText(pcText)
		_nLen_ = ring_len(pcText)
		_i_ = 1
		_n_ = ascii(pcText[1])
		if _n_ = 43 or _n_ = 45
			_i_ = 2
		ok
		if _i_ > _nLen_
			return 0
		ok

		# hexadecimal
		if _i_ + 2 <= _nLen_
			if ascii(pcText[_i_]) = 48 and (ascii(pcText[_i_ + 1]) = 120 or ascii(pcText[_i_ + 1]) = 88)
				for _k_ = _i_ + 2 to _nLen_
					_n_ = ascii(pcText[_k_])
					if NOT ((_n_ >= 48 and _n_ <= 57) or (_n_ >= 65 and _n_ <= 70) or (_n_ >= 97 and _n_ <= 102))
						return 0
					ok
				next
				return 1
			ok
		ok

		# digits
		_nStart_ = _i_
		while _i_ <= _nLen_
			_n_ = ascii(pcText[_i_])
			if _n_ < 48 or _n_ > 57
				exit
			ok
			_i_++
		end
		if _i_ = _nStart_
			return 0
		ok
		if _i_ > _nLen_
			return 1
		ok

		# fraction
		if ascii(pcText[_i_]) = 46
			_i_++
			_nStart_ = _i_
			while _i_ <= _nLen_
				_n_ = ascii(pcText[_i_])
				if _n_ < 48 or _n_ > 57
					exit
				ok
				_i_++
			end
			if _i_ = _nStart_
				return 0
			ok
			if _i_ > _nLen_
				return 1
			ok
		ok

		# exponent
		_n_ = ascii(pcText[_i_])
		if _n_ = 101 or _n_ = 69
			_i_++
			if _i_ <= _nLen_
				_n_ = ascii(pcText[_i_])
				if _n_ = 43 or _n_ = 45
					_i_++
				ok
			ok
			_nStart_ = _i_
			while _i_ <= _nLen_
				_n_ = ascii(pcText[_i_])
				if _n_ < 48 or _n_ > 57
					return 0
				ok
				_i_++
			end
			if _i_ > _nStart_
				return 1
			ok
		ok
		return 0

