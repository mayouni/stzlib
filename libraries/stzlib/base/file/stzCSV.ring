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

		# ── Tokenize into rows of STRING cells ──
		#
		# A single-byte separator (the normal case: ; , | tab) goes through
		# the engine's CSV parser, which handles RFC-4180 quoting -- so a
		# separator INSIDE a "quoted, field" no longer splits the row. The
		# old @split path had no notion of quotes: `"hello; world"` came back
		# as two mangled fields.
		#
		# A multi-byte separator can't reach the engine (its sep is one byte),
		# so it keeps the codepoint-aware @split path -- no quoting there, but
		# it is a rare case and the alternative is not tokenizing it at all.
		if len(cSep) = 1
			_aRows_ = @CSVEngineRows(_cStr_, cSep)
		else
			_aRows_ = @CSVSplitRows(_cStr_, cSep)
		ok

		_nLen_ = len(_aRows_)
		if _nLen_ = 0 return FALSE ok

		# First row -- headers unless a cell looks like data (a number or a
		# bracketed list), in which case there are no headers and columns get
		# synthetic COLn names.
		_acFirst_ = _aRows_[1]
		_nCols_ = len(_acFirst_)
		_bColNamesProvided_ = TRUE

		for i = 1 to _nCols_
			if @IsNumberInString(_acFirst_[i]) or @IsListInString(_acFirst_[i])
				_bColNamesProvided_ = FALSE
				exit
			ok
		next

		_aResult_ = []
		_nFirstData_ = 2

		if NOT _bColNamesProvided_
			# The first row IS data -- synthesize names and seed it.
			for i = 1 to _nCols_
				_aResult_ + [ ("COL"+i), [ @CSVCoerceCell(_acFirst_[i]) ] ]
			next
			_nFirstData_ = 2
		else
			for i = 1 to _nCols_
				_aResult_ + [ _acFirst_[i], [] ]
			next
		ok

		# Data rows.
		for i = _nFirstData_ to _nLen_
			_acItems_ = _aRows_[i]
			_nAvail_ = len(_acItems_)
			for j = 1 to _nCols_
				# Pad a ragged row rather than crashing on a missing cell.
				if j <= _nAvail_
					_aResult_[j][2] + @CSVCoerceCell(_acItems_[j])
				else
					_aResult_[j][2] + ""
				ok
			next
		next

		return _aResult_

	func CSVToListXT(_cStr_, cSep)
		return StringToCSVListXT(_cStr_, cSep)

# Coerce one CSV cell to a number ONLY when nothing is lost by doing so.
#
# A cell becomes a number iff converting it and formatting it back yields the
# IDENTICAL string -- so "35" -> 35 (the documented, tested behaviour) but
# "007" stays "007" (a leading-zero id, phone number or zip code that the old
# `0 + cell` silently corrupted to 7), and "" stays "" (the old code made an
# empty field the number 0). Anything else -- text, "1e3", a bracketed list --
# stays the exact string it was.
#
# NO eval(). The old parser ran `eval('_item_ = ' + cell)` on any cell that
# looked like a list, which EXECUTED arbitrary Ring code from a data file: a
# cell "[1+1]" became [2], and a malicious cell could run anything. A data
# value is never code here.
#
# Note: Ring formats decimals with a fixed precision, so a value like "3.5"
# does not round-trip ("3.50" != "3.5") and stays a string. That errs on the
# side of PRESERVING the cell verbatim, which is the safe direction -- it
# never loses information, where coercing would.
#
# PERFORMANCE: the numeric test is a byte scan, NOT @IsNumberInString. That
# helper is rx(pat(:number)).Match() -- it COMPILES A REGEX per call, and at
# one call per cell it was the entire cost of parsing: 6000 cells took 3.1s,
# essentially all of it recompiling the same pattern. The scan does the same
# job in ~0.02s (156x). ascii() comparisons, never `>=` on strings (that
# coerces and raises R41 on non-numerics).
func @CSVCoerceCell(pcVal)
	if pcVal = ""
		return ""
	ok
	if @CSVLooksNumeric(pcVal)
		_n_ = 0 + pcVal
		if ("" + _n_) = pcVal
			return _n_
		ok
	ok
	return pcVal

# Cheap "could this be a number" screen: optional leading '-', digits, at most
# one '.'. Any non-ASCII byte fails the digit test, so multibyte cells are
# correctly rejected. This only GATES the `0 + pcVal` conversion (which raises
# on a non-number); the round-trip check in @CSVCoerceCell is what actually
# decides, so this can be permissive without being wrong.
func @CSVLooksNumeric(pcVal)
	_nL_ = len(pcVal)
	if _nL_ = 0 return FALSE ok
	_k_ = 1
	if ascii(pcVal[1]) = 45          # leading '-'
		_k_ = 2
	ok
	_bDot_ = FALSE
	_bDig_ = FALSE
	while _k_ <= _nL_
		_a_ = ascii(pcVal[_k_])
		if _a_ >= 48 and _a_ <= 57    # 0-9
			_bDig_ = TRUE
		but _a_ = 46                  # '.'
			if _bDot_ return FALSE ok  # a second dot -> not a number
			_bDot_ = TRUE
		else
			return FALSE
		ok
		_k_++
	end
	return _bDig_

# Engine-parsed rows: the WHOLE grid as a row-major list of string cells,
# quoting handled, in ONE engine call.
#
# This used to parse, then loop RowCount / ColCount / GetCell -- one
# Ring<->engine crossing per cell, ~8000 for a 2000-row file, ~3s. The dump
# builds the entire nested list inside the bridge (the per-cell walk is
# in-process Zig there) and hands it back in a single crossing.
func @CSVEngineRows(_cStr_, cSep)
	return StzEngineCSVDump(_cStr_, cSep)

# Fallback tokenizer for a multi-byte separator (codepoint-aware @split, no
# quote handling). Same row-major shape as @CSVEngineRows.
func @CSVSplitRows(_cStr_, cSep)
	_acLines_ = @Split(_cStr_, NL)
	_aRows_ = []
	_nL_ = len(_acLines_)
	for _i_ = 1 to _nL_
		_aRows_ + @Split(_acLines_[_i_], cSep)
	next
	return _aRows_

func IsCSV(_cStr_)
	return IsCSVXT(_cStr_, CSVSeparator())

func IsCSVXT(_cStr_, cSep)
	return StzEngineCSVIsValid(_cStr_, cSep)
