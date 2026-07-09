#---------------------------------#
#  COMMON FOR ALL NUMBER CLASSES  #
#---------------------------------#

$MAX_NUMBER_SIZE = 15			# Because Ring uses C DOUBLE
$MIN_NUMBER = "2.2250738585072014e-308"
$MAX_NUMBER = "1.7976931348623157e+308"

#-- Min and Max representable numbers 

func MinNumber()
	return $MIN_NUMBER

func MaxNumber()
	return $MAX_NUMBER

#-- Even or odd

func IsEven(_n_)
	if EvenOrOdd(_n_) = 2
		return TRUE
	else
		return FALSE
	ok

	func @IsEven(_n_)
		return IsEven(_n_)

func IsOdd(_n_)
	return NOT IsEven(_n_)

	func @IsOdd(_n_)
		return IsOdd(_n_)

#-- Number type

func IsInt(_n_)
	if ring_substr1( ""+ _n_, '.') = 0
		return TRUE
	else
		return FALSE
	ok

	func IsInteger(_n_)
		return IsInt(_n_)

	func @IsInt(_n_)
		return IsInt(_n_)

	func @IsInteger(_n_)
		return IsInt(_n_)

func IsFractNumber(_n_)
	return NOT IsInt(_n_)

	func @IsFractNumber(_n_)
		return NOT IsInt(_n_)

func IsBigNumber(_n_)
	raise("todo")

	func @IsBigNumber(_n_)
		return IsBigNumber(_n_)

func IsSafeNumber(_n_)
	return NOT IsBigNumber(_n_)

	func @IsSafeNumber(_n_)
		return NOT IsBigNumber(_n_)

#-- Rounds staff

func CurrentRound() # Current round in Ring actuated by decimals() function

	_cStringified_ = ""+ 0.1234567890123456789
	_nPos_ = ring_substr1(_cStringified_, ".")
	_nLen_ = len(_cStringified_)

	_nResult_ = _nLen_ - _nPos_
	return _nResult_

	func @CurrentRound()
		return CurrentRound()

func Round(pNumber) # Effective Round of a number (independently form current round)

	if isNumber(pNumber)

		# In case of integer, no rounds

		if IsInteger(pNumber)
			return 0
		ok

		# Store the current round in the program

		_nCurrentRound_ = CurrentRound()

		# We have a number with a fractional part, stringify it

		_nMax_ = $MAX_NUMBER_SIZE # the maximum possible (calculable) round in Ring
		decimals(_nMax_)
		_cTempStr_ = ""+ pNumber

		# Rounding the number to the most possible round depending
		# on the positions taken by the decimal digits and the sign

		_nLen_ = len(_cTempStr_)
		_nDotPos_ = ring_substr1(_cTempStr_, ".")

		_nMaxPossibleRound_ = _nMax_ - _nDotPos_

		if pNumber < 0
			_nMaxPossibleRound_--
		ok

		if _nMaxPossibleRound_ < 0
			raise("ERR-" + StkError(:OutOfRangeValue) + NL)
		ok
	
		decimals(_nMaxPossibleRound_)
		_cTempStr_ = ""+ pNumber

		# Restoring the current round in the program

		decimals(_nCurrentRound_)
	
		# Doing the job

		_nLen_ = len(_cTempStr_)
		_nResult_ = _nLen_ - _nDotPos_

		if _cTempStr_[_nLen_] != "0" and _cTempStr_[_nLen_] != "9"
			return _nResult_
		ok

		for i = _nLen_-1 to _nDotPos_+1 step - 1

			if _cTempStr_[i] = _cTempStr_[i+1] and
			   (_cTempStr_[i] = "0" or _cTempStr_[i] = "9")

				_nResult_--
			else
				exit
			ok
		
		next

		_nResult_--

		return _nResult_

	but isString(pNumber)

		_cTempStr_ = trim( ring_substr2(pNumber, "_", "") )
		_nValue_ = 0+ _cTempStr_

		if not isNumber(_nValue_)
			raise("ERR-" + StkError(:IncorrectParamValue) + NL)
		ok

		_nRound_ = 0
		_nDotPos_ = ring_substr1(_cTempStr_, ".")

		_nRoundMax_ = $MAX_NUMBER_SIZE - (_nDotPos_ - 1)

		if _nDotPos_ > 0
			_nRound_ = len(_cTempStr_) - _nDotPos_
		ok

		if _nRound_ > _nRoundMax_
			return _nRoundMax_
		else
			return _nRound_
		ok

	else
		raise("ERR-" + StkError(:IncorrectParamType) + NL)
	ok

	func @Round(pNumber)
		return Round(pNumber)

func MaxInt(_n_) # Maximum number of digits n can have in its integer part
	if _n_ = 0 return ok

	_nMaxRound_ = MaxRound(_n_)
	_nResult_ = $MAX_NUMBER_SIZE - _nMaxRound_

	return _nResult_

	func @MaxInt(_n_)
		return MaxInt(_n_)

func MaxRound(_n_) # Maximum number of digits n can have in its fractional part
	if _n_ = 0 return $MAX_NUMBER_SIZE ok  // Special case for zero
	    
	_nIntPart_   = floor(Abs(_n_))
	_nIntDigits_ = len(""+ intPart)

	if _nIntDigits_ >= $MAX_NUMBER_SIZE
		return 0
	ok

	_nMaxFractDigits_ = $MAX_NUMBER_SIZE - _nIntDigits_
	    
	// Ensure we have at least 1 fractional digit and no more than $MAX_NUMBER_SIZE

	if _nMaxFractDigits_ > $MAX_NUMBER_SIZE
		_nMaxFractDigits_ = $MAX_NUMBER_SIZE
	ok

	if _nMaxFractDigits_ < 1
		_nMaxFractDigits_ = 1
	ok

	return _nMaxFractDigits_
	
	func @MaxRound(paNumbers)
		return MaxRound(paNumbers)

#-- Absolute value of a number

func Abs(_n_)
	if _n_ < 0
		_n_ = -_n_
	ok

	return _n_

	func @Abs(_n_)
		return Abs(_n_)

#-- Number value from a string

func Val(_cNumberInStr_)
	if NOT isString(_cNumberInStr_)
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	if ring_substr1(_cNumberInStr_, "_") > 0
		_cNumberInStr_ = @trim( ring_substr2(_cNumberInStr_, "_", "") )
	ok

	_nResult_ = 0+ _cNumberInStr_

	if NOT isNumber(_nResult_)
		raise("ERR-" + StkErrror(:IncorrectParamType) + NL )
	ok

	return _nResult_

	func @Val(_cNumberInStr_)
		return Val(_cNumberInStr_)

#-- Stringifying a number with given round and spacification char

func NStringify(nNumber, cSpaceChar, nSpaceStep, _nRound_)

	if not ( isNumber(nNumber) and isString(cSpaceChar) and isNumber(_nRound_) )
		raise("ERR-" + StkError(:IncorrectParamType) + NL)
	ok

	_cStringified_ = ""+ nNumber

	# Spacifying the integer part

	_nDotPos_ = ring_substr1(_cStringified_, ".")

	_cIntPart_ = ""

	if _nDotPos_ = 0
		_cIntPart_ = _cStringified_

	else
		for i = 1 to _nDotPos_-1
			_cIntPart_ += _cStringified_[i] 
		next
	ok

	if nNumber < 0
		_cIntPart_ = ring_substr2(_cIntPart_, "-", "")
	ok

	_nLen_ = len(_cIntPart_)

	_cIntPartRev_ = reverse(_cIntPart_)

	_cResult_ = ""
	_j_ = 0

	for i = 1 to _nLen_
	
		_cResult_ += _cIntPartRev_[i]

		_j_++
		if _j_ = nSpaceStep and i < _nLen_
			_cResult_ += cSpaceChar
			_j_ = 0
		ok

	next

	_cResult_ = reverse(_cResult_)

	# Compositing the spacified number in a string

	if nNumber < 0
		_cResult_ = "-" + _cResult_
	ok

	if _nDotPos_ > 0
		_cFractPart_ = ""
		_nLen_ = len(_cStringified_)

		_nLenFract_ = _nLen_ - _nDotPos_

		_nMin_ = 0
		if _nLenFract_ < _nRound_
			_nMin_ = _nLenFract_
		else
			_nMin_ = _nRound_
		ok

		_nDotPos_++

		for i = _nDotPos_ to _nLen_
			_cFractPart_ += _cStringified_[i]
		next

		_cResult_ += ( "." + _cFractPart_ )
	ok

	return _cResult_

	#< @FunctionAlternativeForm

	func @NStringify(nNumber, cSpaceChar, nSpaceStep, _nRound_)
		return NStringify(nNumber, cSpaceChar, nSpaceStep, _nRound_)

	#>
