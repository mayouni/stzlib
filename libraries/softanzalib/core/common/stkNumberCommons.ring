#---------------------------------#
#  COMMON FOR ALL NUMBER CLASSES  #
#---------------------------------#

$MAX_NUMBER_SIZE = 15	# Because Ring uses C DOUBLE

func MinNumber()
    return "2.2250738585072014e-308"

func MaxNumber()
    return "1.7976931348623157e+308"

func CurrentRound()
	cStringified = ""+ 0.1234567890123456789
	nPos = substr(cStringified, ".")
	nLen = len(cStringified)

	nResult = nLen - nPos
	return nResult

	func @CurrentRound()
		return CurrentRound()

func Val(cNumberInStr)
	if NOT isString(cNumberInStr)
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	if substr(cNumberInStr, "_") > 0
		cNumberInStr = substr(cNumberInStr, "_", "")
	ok

	nResult = 0+ cNumberInStr

	if NOT isNumber(nResult)
		raise("ERR-" + StkErrror(:IncorrectParamType) + NL )
	ok

	return nResult

	func @Val(cNumberInStr)
		return Val(cNumberInStr)

func NumberStringify(nNumber, cSpaceChar, nSpaceStep, nRound)

		if not isNumber(nNumber) and isString(cSpaceChar) and isNumber(nRound)
			raise("ERR-" + StkError(:IncorrectParamType) + NL)
		ok

		cStringified = ""+ nNumber

		# Spacifying the integer part

		nDotPos = substr(cStringified, ".")

		cIntegerPart = ""

		if nDotPos = 0
			cIntegerPart = cStringified

		else
			for i = 1 to nDotPos-1
				cIntegerPart += cStringified[i] 
			next
		ok

		if nNumber < 0
			cIntegerPart = substr(cIntegerPart, "-", "")
		ok

		nLen = len(cIntegerPart)

		cIntegerPartRev = reverse(cIntegerPart)

		cResult = ""
		j = 0

		for i = 1 to nLen
		
			cResult += cIntegerPartRev[i]

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
			cFractionalPart = ""
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
				cFractionalPart += cStringified[i]
			next

			cResult += ( "." + cFractionalPart )
		ok

		return cResult

		#< @FunctionAlternativeForms

		func @NumberStringify(nNumber, cSpaceChar, nSpaceStep, nRound)
			return NumberStringify(nNumber, cSpaceChar, nSpaceStep, nRound)

		func NStringify(nNumber, cSpaceChar, nSpaceStep, nRound)
			return NumberStringify(nNumber, cSpaceChar, nSpaceStep, nRound)

		func @NStringify(nNumber, cSpaceChar, nSpaceStep, nRound)
			return NumberStringify(nNumber, cSpaceChar, nSpaceStep, nRound)

		#>

