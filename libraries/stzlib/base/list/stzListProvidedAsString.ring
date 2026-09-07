


class stzListProvidedAsString from stzObject
	_cListAsString_
	_aItems_

	_oStzString_

	def init(pcListAsString)
		// Issuming the provided string is a well formed
		// list provided inside a string

		_cListAsString_ = pcListAsString
		_oStzString_ = new stzString(_cListAsString_)

		// Extracting list items. RemoveTheseBounds() MUTATES and returns
		// nothing -- the returning sister is BoundsRemoved() -- so the
		// result is read back from the object, not from the call.
		_oTempString_ = new stzString(_cListAsString_)
		_oTempString_.RemoveTheseBounds("[","]")

		// Split at DEPTH ZERO only. A plain Split(:Using = ",") cuts
		// [ 1, 2, "A", [ 5, "V" ] ] into "1" "2" '"A"' "[5" '"V"]' --
		// the nested list is torn in half at its own comma. And the
		// RemoveSpaces() that used to run here stripped the spaces
		// INSIDE quoted strings too, so "Mansour Ayouni" came back as
		// "MansourAyouni". _SplitTopLevel() trims each item instead.
		_aItems_ = This._SplitTopLevel(_oTempString_.Content())

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

	def Items()
		return _aItems_

	def IsListOfValues()
		return ContainsOnlyValues()

	def IsListOfVariables()
		return ContainsOnlyVariables()

	def IsListOfValuesAndVariables()
		return ContainsValuesAndVariables()

	/*
		The three predicates below all ask the same question of each item
		-- is this text a VALUE or a VARIABLE NAME? -- and differ only in
		how they add the answers up. So there is one classifier and three
		one-line readings of it.

		ContainsOnlyValues() used to be:

			_cListString_ = list2code(This.List)
			_oListString_ = new stzString(_cListString_)

		which raised Error (R12) : property not found: list -- there is no
		List property and no List() method on this class or on stzObject --
		and which, had it got past that, fell off the end of the method and
		so returned "" rather than a boolean. The other two were // TODO
		and returned "" in silence, which reads as FALSE at every call site.
	*/

	def ContainsOnlyValues()
		_nCovLen_ = len(_aItems_)
		if _nCovLen_ = 0 return FALSE ok

		for _iCov_ = 1 to _nCovLen_
			if This._IsVariableName(_aItems_[_iCov_])
				return FALSE
			ok
		next

		return TRUE

	def ContainsOnlyVariables()
		_nCovLen_ = len(_aItems_)
		if _nCovLen_ = 0 return FALSE ok

		for _iCov_ = 1 to _nCovLen_
			if NOT This._IsVariableName(_aItems_[_iCov_])
				return FALSE
			ok
		next

		return TRUE

	def ContainsValuesAndVariables()
		return NOT (This.ContainsOnlyValues() or This.ContainsOnlyVariables())

	  #-------------------------------------------#
	 #   TELLING A VALUE FROM A VARIABLE NAME    #
	#-------------------------------------------#

	# TRUE when this item's text names a VARIABLE rather than holding a
	# value. Everything the class comment calls a value -- a number, a
	# string, a list -- is recognised by its first character; a nested list
	# is asked recursively, because [ n1, 2 ] is a list that CONTAINS a
	# variable and must not pass as a plain value.
	def _IsVariableName(pcItem)
		_cIvn_ = trim(pcItem)
		_nIvn_ = len(_cIvn_)
		if _nIvn_ = 0 return FALSE ok

		_cIvnFirst_ = _cIvn_[1]

		# a string literal
		if _cIvnFirst_ = '"' or _cIvnFirst_ = "'" or _cIvnFirst_ = char(96)
			return FALSE
		ok

		# a number literal, signed or not. Compared through ascii() and
		# never with >= on the characters themselves: Ring reads "a" >= "0"
		# as an attempt at arithmetic and raises Error (R41) : Invalid
		# numeric string. ascii() is also the form that means the same
		# thing on both runtimes (FINDINGS F-54).
		_nIvnFirst_ = ascii(_cIvnFirst_)
		if (_nIvnFirst_ >= 48 and _nIvnFirst_ <= 57) or
		   _cIvnFirst_ = "-" or _cIvnFirst_ = "+" or _cIvnFirst_ = "."
			return FALSE
		ok

		# a nested list: variable if ANY of its own items is
		if _cIvnFirst_ = "["
			_cIvnInner_ = _cIvn_
			if _cIvn_[_nIvn_] = "]"
				_cIvnInner_ = substr(_cIvn_, 2, _nIvn_ - 2)
			else
				_cIvnInner_ = substr(_cIvn_, 2)
			ok

			_aIvnInner_ = This._SplitTopLevel(_cIvnInner_)
			_nIvnInner_ = len(_aIvnInner_)

			for _jIvn_ = 1 to _nIvnInner_
				if This._IsVariableName(_aIvnInner_[_jIvn_])
					return TRUE
				ok
			next

			return FALSE
		ok

		# a named pair -- :name = <something>. The KEY is a symbol, so
		# what decides is the value on the right.
		if _cIvnFirst_ = ":"
			_nIvnEq_ = This._TopLevelEqual(_cIvn_)
			if _nIvnEq_ = 0
				return FALSE
			ok
			return This._IsVariableName(substr(_cIvn_, _nIvnEq_ + 1))
		ok

		# anything else is a bare identifier: a variable name
		return TRUE

	# Split on commas at depth zero, outside quotes. Each piece is trimmed.
	def _SplitTopLevel(pcText)
		_aStlResult_ = []
		_nStlLen_ = len(pcText)			# hoisted: F-41
		if _nStlLen_ = 0 return _aStlResult_ ok

		_cStlCur_ = ""
		_nStlDepth_ = 0
		_cStlQuote_ = ""

		for _iStl_ = 1 to _nStlLen_
			_cStl_ = pcText[_iStl_]

			if _cStlQuote_ != ""
				_cStlCur_ += _cStl_
				if _cStl_ = _cStlQuote_
					_cStlQuote_ = ""
				ok
				loop
			ok

			if _cStl_ = '"' or _cStl_ = "'" or _cStl_ = char(96)
				_cStlQuote_ = _cStl_
				_cStlCur_ += _cStl_
				loop
			ok

			if _cStl_ = "[" _nStlDepth_++ ok
			if _cStl_ = "]" _nStlDepth_-- ok

			if _cStl_ = "," and _nStlDepth_ = 0
				_aStlResult_ + trim(_cStlCur_)
				_cStlCur_ = ""
				loop
			ok

			_cStlCur_ += _cStl_
		next

		if trim(_cStlCur_) != ""
			_aStlResult_ + trim(_cStlCur_)
		ok

		return _aStlResult_

	# The position of the first `=` at depth zero and outside quotes, or 0.
	def _TopLevelEqual(pcText)
		_nTleLen_ = len(pcText)
		_nTleDepth_ = 0
		_cTleQuote_ = ""

		for _iTle_ = 1 to _nTleLen_
			_cTle_ = pcText[_iTle_]

			if _cTleQuote_ != ""
				if _cTle_ = _cTleQuote_ _cTleQuote_ = "" ok
				loop
			ok

			if _cTle_ = '"' or _cTle_ = "'" or _cTle_ = char(96)
				_cTleQuote_ = _cTle_
				loop
			ok

			if _cTle_ = "[" _nTleDepth_++ ok
			if _cTle_ = "]" _nTleDepth_-- ok

			if _cTle_ = "=" and _nTleDepth_ = 0
				return _iTle_
			ok
		next

		return 0

