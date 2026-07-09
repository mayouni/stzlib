# A small CSV class ~Softanza library

$cCSVSep = ";"

# Functions for setting and reading the default separator

func CSVSeparator()
	return $cCSVSep

	func CSVSep()
		return $cCSVSep

	func DefaultCSVSeparator()
		return $cCSVSep

	func DefaultCSVSep()

		return $cCSVSep

	#-- @FunctionMisspelledForm

	func CSVSeperator()
		return $cCSVSep

	func DefaultCSVSeperator()
		return $cCSVSep

func SetCSVSeparator(cSep)

	if CheckParams()
		if NOT isString(cSep)
			StzRaise("Incorrect param type! cSep must be a string.")
		ok
	ok

	$cCSVSep = cSep

	func SetCSVSep(cSep)
		SetCSVSeparator(cSep)

	#-- @Misspelled

	func SetCSVSeperator(cSep)
		return SetCSVSeparator(cSep)

# Functions for transformin a list to cCSV

func ListToCSV(aList)
	return ListToCSVXT(aList, CSVSeparator())

func ListToCSVXT(aList, cSep)

	if CheckParams()
		if NOT ( isList(aList) and IsList2D(aList))
			StzRaise("Incorrect param type! aList must be a 2D list.")
		ok
	ok

    _cResult_ = ""
    _nCols_ = len(aList)
    if _nCols_ = 0 return _cResult_ ok
    
    # Get number of rows from the first sublist
    _nRows_ = len(aList[1][2])
    
    # Add headers
    for i = 1 to _nCols_
        _cResult_ += aList[i][1]
        if i < _nCols_ _cResult_ += cSep ok
    next

    _cResult_ += nl
    
    # Add data rows
    for j = 1 to _nRows_
        for i = 1 to _nCols_
            _cResult_ += aList[i][2][j]
            if i < _nCols_ _cResult_ += cSep ok
        next
        if j < _nRows_ _cResult_ += nl ok
    next
    
    return _cResult_

	func List2DToCSVXT(aList, cSep)
		# Was `return ListToCSV(aList, cSep)` -- ListToCSV is 1-arg,
		# so passing the separator raised R20 and made the alias
		# unusable. Forward to the XT variant.
		return ListToCSVXT(aList, cSep)

# Function to transform a CSV string to a list

func StringToCSVList(_cStr_)
	return StringToCSVListXT(_cStr_, CSVSeparator())

	func CSVToList(_cStr_)
		return StringToCSVListXT(_cStr_, CSVSeparator())

func StringToCSVListXT(_cStr_, cSep)

	if CheckParams()
		if NOT isString(_cStr_)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok

		if NOT IsCSV(_cStr_)
			StzRaise("Can't proceed! The string must be in CSV format.")
		ok

	ok

		_cStr_ = @trim(_cStr_)

		if _cStr_ = ""
			return FALSE
		ok

		# Bug fix: the param cSep was being clobbered by the global
		# default (cSep = CSVSep()), so XT-form callers with a custom
		# separator were silently parsing with ';'.
		_acLines_ = @split(_cStr_, NL)
		_nLen_ = len(_acLines_)

		# First line

		_acItemsInFirstLine_ = @split(_acLines_[1], cSep)
		_nCols_ = len(_acItemsInFirstLine_)
		_bColNamesProvided_ = TRUE

		for i = 1 to _nCols_

			if @IsNumberInString(_acItemsInFirstLine_[i]) or
			   @IsListInString(_acItemsInFirstLine_[i]) #TODO // Check for perfmance
				_bColNamesProvided_ = FALSE
				exit
			ok

		next

		_aResult_ = []

		if NOT _bColNamesProvided_
			for i = 1 to _nCols_
				_aResult_ + [ ("COL"+i), _acItemsInFirstLine_[i] ]
			next

		else
			for i = 1 to _nCols_
				_aResult_ + [ _acItemsInFirstLine_[i], []]
			next

		ok
	
		# Other lines

		for i = 2 to _nLen_

			_acItems_ = @Split(_acLines_[i], cSep)

			for j = 1 to _nCols_

				_item_ = _acItems_[j]

				if @IsNumberInString(_item_)
					_item_ = 0+ _acItems_[j]

				but @IsListInString(_item_)
					_cCode_ = '_item_ = ' + _acItems_[j]
					eval(_cCode_)
				ok

				_aResult_[j][2] + _item_
			next

		next

		return _aResult_

	func CSVToListXT(_cStr_, cSep)
		return StringToCSvlistXT(_cStr_, cSep)

func IsCSV(_cStr_)
	return IsCSVXT(_cStr_, CSVSeparator())

func IsCSVXT(_cStr_, cSep)
	return StzEngineCSVIsValid(_cStr_, cSep)
