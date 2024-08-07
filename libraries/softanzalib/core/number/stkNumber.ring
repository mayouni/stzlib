
func CurrentRound()
	cStringified = ""+ 0.1234567890123456789
	nPos = substr(cStringified, ".")
	nLen = len(cStringified)

	nResult = nLen - nPos
	return nResult

	func @CurrentRound()
		return CurrentRound()

func Val(cNumberInStr)
	if substr(cNumberInStr, "_") > 0
		cNumberInStr = substr(cNumberInStr, "_", "")
	ok

	nResult = 0+ cNumberInStr

	if NOT isNumber(nResult)
		raise("ERR-" + StkErrror(:IncorrectParamType) )
	ok

	return nResult

	func @Val(cNumberInStr)
		return Val(cNumberInStr)

func NumberSpacify(nNumber, cSpaceChar, nSpaceStep, nRound)

		if not isNumber(nNumber) and isString(cSpaceChar) and isNumber(nRound)
			raise("ERR-" + StkError(:IncorrectParamType))
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

#~~~~~~~~~~~~~~~~~~~#
#  STZ CORE NUMBER  #
#~~~~~~~~~~~~~~~~~~~#

class stzCoreNumber from stkNumber

class stkNumber
	@content

	@nRound = 2

	@bSpacify = FALSE
	@nSpaceStep = 3
	@cSpaceChar = "_"


	#----------------------------------------------------------------#
	#  INITIALISING THE NUMBER, FROM A NUMBER OR A NUMBER IN STRING  #
	#----------------------------------------------------------------#

	def init(pNumber)
		if NOT (isNumber(pNumber) or isString(pNumber))
			raise("ERR-" + StkErrror(:IncorrectParamType) )
		ok

		if isNumber(pNumber)
			@content = pNumber
			@nRound = @CurrentRound()

		else # the number is provided in a string

			@content = @Val(pNumber)

			# Get the round from the number in string
	
			nPos = substr(pNumber, ".")
			if nPos > 0
				@nRound = len(pNumber) - nPos
			ok

			# The round will be used in displaying stringified
			# values of the number. While the numeric value will
			# always be in the current round defined in the Ring
			# program by decimals().

			if substr(pNumber, '_') > 0
				@bSpacify = TRUE
			else
				@bSpacify = FALSE
			ok
		ok

	#--------------------------------------------#
	#  NUMBER VALUE, IN NUMBER AND STRING FORMS  #
	#--------------------------------------------#

	def Copy()
		oCopy = This
		return oCopy

	def Content()
		return @content

		def NValue()

	def SValue()
		
		cResult = This.SIntegerPart() + "." + SFractionalPartWithoutZeroDot()
		return cResult

	#-------------------------------------------------------#
	#  GETTING THE INTEGER PART IN NUMBER AND STRING FORMS  #
	#-------------------------------------------------------#

	def IntegerPart()
		if @content > 0
			return floor(@content)
		else
			return ceil(@content)
		ok

	def SIntegerPart()

		cSpaceChar = ""
		if @bSpacify
			cSpaceChar = @cSpaceChar
		ok

		cResult = NumberSpacify(This.IntegerPart(), cSpaceChar, @nSpaceStep, @nRound)

		return cResult


	#------------------------------------------------------#
	#  GETTING THE STRING PART IN NUMBER AND STRING FORMS  #
	#------------------------------------------------------#


	def FractionalPart()

		n = @content
		if n < 0
			n = -n
		ok

		nResult = n - floor(n)
		return nResult


	def SFractionalPart()

		cSpaceChar = ""

		nTempRound = @CurrentRound()
		decimals(@nRound)

		cResult = NumberSpacify(This.FractionalPart(), cSpaceChar, @nSpaceStep, @nRound)

		decimals(nTempRound)

		return cResult
/*
		#NOTE
		# This function takes the current number value and
		# constructs a string containing its decimal part.

		# The number value @content is the single source
		# of truth about the number value in the class.

		# ~> Whaterver operation we need to make should
		# be based on that value and none of the other
		# string-based values generated.

		nCurrentRoundInRing = @CurrentRound()
		decimals(@nRound)
		cStringified = ""+ @content
		decimals(nCurrentRoundInRing)

		nLen = len(cStringified )
		nDotPos = substr(cStringified , ".")

		if nDotPos = 0

			# There is no decimal part

			return ""

		else
			if @content < 0
				if @bForceNegativeSignInFractionalPart
					cResult = "-0."
				else
					cResult = "0."
				ok
			else
				if @bForcePositiveSign
					cResult = "+0."
				else
					cResult = "0."
				ok
			ok
		ok

		n1 = nDotPos + 1
		n2 = nDotPos + @nRound # Limit decimal part round defined for the object
		if n2 > nLen
			n2 = nLen
		ok

		for i = n1 to n2
			cResult += cStringified[i]
		next

		return cResult
*/

	#-----------------------------------------------#
	#  GETTING AND SETTING THE ROUND OF THE NUMBER  #
	#-----------------------------------------------#

	def Round()
		return @nRound

	def SetRound(n)
		if NOT isNumber(n)
			raise(StkError(:IncorrectParamType))
		ok

		@nRound = n

	#----------------------------------#
	#  GETTING THE SIGN OF THE NUMBER  #
	#----------------------------------#

	def Sign()
		if @content < 0
			return "-"
		else
			return "+"
		ok

	#----------------------------------------------------#
	#  GETTING THE SDTRING FORM OF THE NUMBER SPACIFIED  #
	#----------------------------------------------------#

	def Spacify()
		@bSpacify = TRUE

	def Unspacify()
		@bSpacify = FALSE

	def UnSpacified()
		bTemp = @bSpacify
		@bSpacify = FALSE
		cResult This.SValue()
		@bSpacify = bTemp

	def Spacified()
		cResult = NumberSpacify(@content, @cSpaceChar, @nSpaceStep, @nRound)
		return cResult

/*
		cSpaceChar = ""
		if @bSpacify
			cSpaceChar = @cSpaceChar
		ok



		cResult = NumberSpacify(@content, cSpaceChar, true, false)

		# Spacifying the integer part

		cIntegerPart = This.StringIntegerPartWithoutSign()
		nLen = len(cIntegerPart)

		cIntegerPartRev = reverse(cIntegerPart)

		cResult = ""
		j = 0

		for i = 1 to nLen
		
			cResult += cIntegerPartRev[i]

			j++
			if j = @nSpaceStep and i < nLen
				cResult += @cSpaceChar
				j = 0
			ok

		next

		cResult = reverse(cResult)

		# Compositing the spacified number in a string

		if @content < 0
			cResult = "-" + cResult

		else
			if @bForcePositiveSign
				cResult = "+" + cResult
			ok
		ok

		if This.HasDecimalPart()
			cResult + "." + This.StringDecimalPartWithoutZeroDot()
		ok

		return cResult
*/
	def HasFractionalPart()
		if substr( This.SValue(), "." ) > 0
			return TRUE
		else
			return FALSE
		ok

	def SFractionalPartWithoutZeroDot()

		cResult = This.SFractionalPart()
		cResult = substr(cResult, "0.", "")
		cResult = substr(cResult, "+", "")
		cResult = substr(cResult, "-", "")

		return cResult



	def SpaceChar()
		return @cSpaceChar

	def SetSpaceChar(c)
		@cSpaceChar = c

	def SpaceStep()
		return @nSpaceStep

	def SetSpaceStep(n)
		@nSpaceStep = n

	#-------------------------#
	#  ARITHMETIC OPERATIONS  #
	#-------------------------#

	def Add(pNumber)
		if isNumber(pNumber)
			@content += pNumber

		but isString(pNumber)
			@content += @Val(pNumber)

		else
			raise(StkError(:IncorrectParamType))
		ok

	def Substruct(pNumber)
		if isNumber(pNumber)
			@content -= pNumber

		but isString(pNumber)
			@content -= @Val(pNumber)

		else
			raise(StkError(:IncorrectParamType))
		ok

		def Substract(pNumber)
			This.Substruct(pNumber)

	def MultiplyBy(pNumber)
		if isNumber(pNumber)
			@content *= pNumber

		but isString(pNumber)
			@content *= @Val(pNumber)

		else
			raise(StkError(:IncorrectParamType))
		ok

		def Multiply(pNumber)
			This.MultiplyBy(pNumber)

	def DivideBy(pNumber)
		if isNumber(pNumber)
			@content /= pNumber

		but isString(pNumber)
			@content /= @Val(pNumber)

		else
			raise(StkError(:IncorrectParamType))
		ok

		def Divide(pNumber)
			return This.DivideBy(pNumber)

	#------------------------#
	#  OVERLOADED OPERATORS  #
	#------------------------#

	def Operator(op, value)

		if op = "+"

			oTempCopy = This.Copy()
			oTempCopy.Add(value)

			if isNumber(value)
				return oTempCopy.NValue()

			but isString(value)
				return oTempCopy.SValue()

			else
				raise("ERR-" + StkError(:IncorrectParamType))
			ok

		but op = "-"

			oTempCopy = This.Copy()
			oTempCopy.Substruct(value)

			if isNumber(value)
				return oTempCopy.NValue()

			but isString(value)
				return oTempCopy.SValue()

			else
				raise("ERR-" + StkError(:IncorrectParamType))
			ok

		but op = "*"

			oTempCopy = This.Copy()
			oTempCopy.Multiply(value)

			if isNumber(value)
				return oTempCopy.NValue()

			but isString(value)
				return oTempCopy.SValue()

			else
				raise("ERR-" + StkError(:IncorrectParamType))
			ok

		but op = "/"

			oTempCopy = This.Copy()
			oTempCopy.Divide(value)

			if isNumber(value)
				return oTempCopy.NValue()

			but isString(value)
				return oTempCopy.SValue()

			else
				raise("ERR-" + StkError(:IncorrectParamType))
			ok

		else
			raise( 'ERR-' + StkError(:UnsupportedOperator) )
		ok
