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

func IsEven(n)
	if EvenOrOdd(n) = 2
		return TRUE
	else
		return FALSE
	ok

	func @IsEven(n)
		return IsEven(n)

func IsOdd(n)
	return NOT IsEven(n)

	func @IsOdd(n)
		return IsOdd(n)

#-- Number type

func IsInt(n)
	if substr( ""+ n, '.') = 0
		return TRUE
	else
		return FALSE
	ok

	func IsInteger(n)
		return IsInt(n)

	func @IsInt(n)
		return IsInt(n)

	func @IsInteger(n)
		return IsInt(n)

func IsFractNumber(n)
	return NOT IsInt(n)

	func @IsFractNumber(n)
		return NOT IsInt(n)

func IsBigNumber(n)
	raise("todo")

	func @IsBigNumber(n)
		return IsBigNumber(n)

func IsSafeNumber(n)
	return NOT IsBigNumber(n)

	func @IsSafeNumber(n)
		return NOT IsBigNumber(n)

#-- Rounds staff

func CurrentRound() # Current round in Ring actuated by decimals() function

	cStringified = ""+ 0.1234567890123456789
	nPos = substr(cStringified, ".")
	nLen = len(cStringified)

	nResult = nLen - nPos
	return nResult

	func @CurrentRound()
		return CurrentRound()

func Round(pNumber) # Effective Round of a number (independently form current round)

	if isNumber(pNumber)

		# In case of integer, no rounds

		if IsInteger(pNumber)
			return 0
		ok

		# Store the current round in the program

		nCurrentRound = CurrentRound()

		# We have a number with a fractional part, stringify it

		nMax = $MAX_NUMBER_SIZE # the maximum possible (calculable) round in Ring
		decimals(nMax)
		cTempStr = ""+ pNumber

		# Rounding the number to the most possible round depending
		# on the positions taken by the decimal digits and the sign

		nLen = len(cTempStr)
		nDotPos = substr(cTempStr, ".")

		nMaxPossibleRound = nMax - nDotPos

		if pNumber < 0
			nMaxPossibleRound--
		ok

		if nMaxPossibleRound < 0
			raise("ERR-" + StkError(:OutOfRangeValue) + NL)
		ok
	
		decimals(nMaxPossibleRound)
		cTempStr = ""+ pNumber

		# Restoring the current round in the program

		decimals(nCurrentRound)
	
		# Doing the job

		nLen = len(cTempStr)
		nResult = nLen - nDotPos

		if cTempStr[nLen] != "0" and cTempStr[nLen] != "9"
			return nResult
		ok

		for i = nLen-1 to nDotPos+1 step - 1

			if cTempStr[i] = cTempStr[i+1] and
			   (cTempStr[i] = "0" or cTempStr[i] = "9")

				nResult--
			else
				exit
			ok
		
		next

		nResult--

		return nResult

	but isString(pNumber)

		cTempStr = trim( substr(pNumber, "_", "") )
		nValue = 0+ cTempStr

		if not isNumber(nValue)
			raise("ERR-" + StkError(:IncorrectParamValue) + NL)
		ok

		nRound = 0
		nDotPos = substr(cTempStr, ".")

		nRoundMax = $MAX_NUMBER_SIZE - (nDotPos - 1)

		if nDotPos > 0
			nRound = len(cTempStr) - nDotPos
		ok

		if nRound > nRoundMax
			return nRoundMax
		else
			return nRound
		ok

	else
		raise("ERR-" + StkError(:IncorrectParamType) + NL)
	ok

	func @Round(pNumber)
		return Round(pNumber)

func MaxInt(n) # Maximum number of digits n can have in its integer part
	if n = 0 return ok

	nMaxRound = MaxRound(n)
	nResult = $MAX_NUMBER_SIZE - nMaxRound

	return nResult

	func @MaxInt(n)
		return MaxInt(n)

func MaxRound(n) # Maximum number of digits n can have in its fractional part
	if n = 0 return $MAX_NUMBER_SIZE ok  // Special case for zero
	    
	nIntPart   = floor(Abs(n))
	nIntDigits = len(""+ intPart)

	if nIntDigits >= $MAX_NUMBER_SIZE
		return 0
	ok

	nMaxFractDigits = $MAX_NUMBER_SIZE - nIntDigits
	    
	// Ensure we have at least 1 fractional digit and no more than $MAX_NUMBER_SIZE

	if nMaxFractDigits > $MAX_NUMBER_SIZE
		nMaxFractDigits = $MAX_NUMBER_SIZE
	ok

	if nMaxFractDigits < 1
		nMaxFractDigits = 1
	ok

	return nMaxFractDigits
	
	func @MaxRound(paNumbers)
		return MaxRound(paNumbers)

#-- Absolute value of a number

func Abs(n)
	if n < 0
		n = -n
	ok

	return n

	func @Abs(n)
		return Abs(n)

#-- Number value from a string

func Val(cNumberInStr)
	if NOT isString(cNumberInStr)
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	if substr(cNumberInStr, "_") > 0
		cNumberInStr = trim( substr(cNumberInStr, "_", "") )
	ok

	nResult = 0+ cNumberInStr

	if NOT isNumber(nResult)
		raise("ERR-" + StkErrror(:IncorrectParamType) + NL )
	ok

	return nResult

	func @Val(cNumberInStr)
		return Val(cNumberInStr)

#-- Stringifying a number with given round and spacification char

func NStringify(nNumber, cSpaceChar, nSpaceStep, nRound)

	if not isNumber(nNumber) and isString(cSpaceChar) and isNumber(nRound)
		raise("ERR-" + StkError(:IncorrectParamType) + NL)
	ok

	cStringified = ""+ nNumber

	# Spacifying the integer part

	nDotPos = substr(cStringified, ".")

	cIntPart = ""

	if nDotPos = 0
		cIntPart = cStringified

	else
		for i = 1 to nDotPos-1
			cIntPart += cStringified[i] 
		next
	ok

	if nNumber < 0
		cIntPart = substr(cIntPart, "-", "")
	ok

	nLen = len(cIntPart)

	cIntPartRev = reverse(cIntPart)

	cResult = ""
	j = 0

	for i = 1 to nLen
	
		cResult += cIntPartRev[i]

		j++
		if j = nSpaceStep and i < nLen
			cResult += cSpaceChar
			j = 0
		ok

	next

	cResult = reverse(cResult)

	# Compositing the spacified number in a string

	if nNumber < 0
		cResult = "-" + cResult
	ok

	if nDotPos > 0
		cFractPart = ""
		nLen = len(cStringified)

		nLenFract = nLen - nDotPos

		nMin = 0
		if nLenFract < nRound
			nMin = nLenFract
		else
			nMin = nRound
		ok

		nDotPos++

		for i = nDotPos to nLen
			cFractPart += cStringified[i]
		next

		cResult += ( "." + cFractPart )
	ok

	return cResult

	#< @FunctionAlternativeForm

	func @NStringify(nNumber, cSpaceChar, nSpaceStep, nRound)
		return NStringify(nNumber, cSpaceChar, nSpaceStep, nRound)

	#>
