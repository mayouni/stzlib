


func SFraction(pNumber)
	oTempNumber = new stkNumber(pNumber)
	return oTempNumber.SFraction()

	func SFract(pNumber)
		return SFraction(pNumber)

	func SFractionalPart(pNumber)
		return SFraction(pNumber)

func NFraction(pNumber)
	oTempNumber = new stkNumber(pNumber)
	return oTempNumber.NFraction()

	func NFract(pNumber)
		return NFraction(pNumber)

	func NFractionalPart(pNumber)
		return NsFraction(pNumber)

func Rounded(pNumber, nRound) #TODO
		raise("TODO")

func Round(pNumber)

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

		cTempStr = substr(pNumber, "_", "")
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

func IsSafeNumber(n)
	
func IsInteger(n)
	if substr( ""+ n, '.') = 0
		return TRUE
	else
		return FALSE
	ok

func Max(panNumbers) // #TODO Move to stkListOfNumbers when made
	
	nLen = len(panNumbers)
	if nLen = 1
		return panNumbers[1]
	ok

	nMax = panNumbers[1]

	for i = 2 to nLen
		if panNumbers[i] > nMax
			nMax = panNumbers[i]
		ok
	next

	return nMax

	func @Max(panNumbers)
		return Max(panNumbers)

func Min(panNumbers) // #TODO Move to stkListOfNumbers when made
	nLen = len(panNumbers)
	if nLen = 1
		return panNumbers[1]
	ok

	nMin = panNumbers[1]

	for i = 2 to nLen
		if panNumbers[i] < nMin
			nMin = panNumbers[i]
		ok
	next

	return nMin

	func @Min(panNumbers)
		return Min(panNumbers)

func Abs(n) // #TODO Add it as a method inside stkNumber
	if n < 0
		n = -n
	ok

	return n

	func @Abs(n)
		return Abs(n)

func MaxInt(n)
	if n = 0 return ok

	nMaxRound = MaxRound(n)
	nResult = $MAX_NUMBER_SIZE - nMaxRound

	return nResult

func MaxRound(n)
	if n = 0 return $MAX_NUMBER_SIZE ok  // Special case for zero
	    
	nIntPart   = floor(Abs(n))
	nIntDigits = len(""+ intPart)

	if nIntDigits >= $MAX_NUMBER_SIZE
		return 0
	ok

	nMaxFractionalDigits = $MAX_NUMBER_SIZE - nIntDigits
	    
	// Ensure we have at least 1 fractional digit and no more than $MAX_NUMBER_SIZE

	if nMaxFractionalDigits > $MAX_NUMBER_SIZE
		nMaxFractionalDigits = $MAX_NUMBER_SIZE
	ok

	if nMaxFractionalDigits < 1
		nMaxFractionalDigits = 1
	ok

	return nMaxFractionalDigits
	
	func @MaxRound(paNumbers)
		return MaxRound(paNumbers)
	
#~~~~~~~~~~~~~~~~~~~#
#  STZ CORE NUMBER  #
#~~~~~~~~~~~~~~~~~~~#

class stzCoreNumber from stkNumber

class stkNumber
	@content
	@nRound

	@bSpacify = FALSE
	@nSpaceStep = 3
	@cSpaceChar = "_"

	#----------------------------------------------------------------#
	#  INITIALISING THE NUMBER, FROM A NUMBER OR A NUMBER IN STRING  #
	#----------------------------------------------------------------#

	def init(pNumber)
		if NOT (isNumber(pNumber) or isString(pNumber))
			raise("ERR-" + StkErrror(:IncorrectParamType) + NL )
		ok

		if isNumber(pNumber)

			@content = pNumber
			@nRound = @Round(""= @content)

		else # the number is provided in a string
			if substr(pNumber, '_') > 0

				@bSpacify = TRUE
			else
				@bSpacify = FALSE
			ok

			@content = @Val(pNumber)
			@nRound = @Round(@content)

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
			return @content

		def Value()
			return @content

	def SValue()
		
		cResult = This.SIntegerPart() + "." + SFractionalPartWithoutZeroDot()
		return cResult

	#-----------------------------------------------------#
	#  UPDATING THE NUMBER WITH A NUMBER OR STRING FORM   #
	#-----------------------------------------------------#

	def Update(pNumber)

		if isNumber(pNumber)

			@content = pNumber
			

		else # the number is provided in a string

			@content = @Val(pNumber)

			if substr(pNumber, '_') > 0
				@bSpacify = TRUE
			else
				@bSpacify = FALSE
			ok
		ok

		@nRound = @Round(pNumber)

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

		nInt = This.IntegerPart()
		nRound = @Round(nInt)
		cResult = NStringify(nInt, cSpaceChar, @nSpaceStep, nRound)

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

		def FPart()
			return This.FractionalPart()

		def FractionalValue()
			return This.FractionalPart()

		def FValue()
			return This.FractionalPart()

	def SFractionalPart()
		nTempRound = CurrentRound() # in Ring program
		nRound = This.Round()

		decimals(nRound)

		nRound = @Round(@content)

		cTempStr = "" + @content
		nLen = len(cTempStr)

		decimals(nTempRound)

		nPos = substr(cTempStr, ".")

		if nPos = 0
			return ""

		else
			if @content < 0
				cResult = "-0."
			else
				cResult = "0."
			ok

			n1 = nPos + 1
			n2 = nPos + nRound

			for i = n1 to n2
				cResult += cTempStr[i]
			next
		ok

		return cResult

		#< @FunctionAlternativeForms

		def SFPart()
			return This.SFractionalPart()

		def SFractionalValue()
			return This.SFractionalPart()

		def SFValue()
			return This.SFractionalPart()

		def SFraction()
			return This.SFractionalPart()
		#>

	def HasFractionalPart()
		if substr( This.SValue(), "." ) > 0
			return TRUE
		else
			return FALSE
		ok

		#< @FunctionAlternativeForms

		def HasFraction()
			return This.HasFractionalPart()

		def IsRealNumber()
			return This.HasFractionalPart()

		def IsReal()
			return This.HasFractionalPart()

		def HasFValue()
			return This.HasFractionalPart()

		def HasFPart()
			return This.HasFractionalPart()

		#>

	def SFractionalPartWithoutZeroDot()

		cResult = This.SFractionalPart()
		cResult = substr(cResult, "0.", "")
		cResult = substr(cResult, "+", "")
		cResult = substr(cResult, "-", "")

		return cResult

		#< @FunctionAlternativeForms

		def SFractionalValueWithoutZeroDot()
			return This.SFractionalPartWithoutZeroDot()

		def SFPartWithoutZeroDot()
			return This.SFractionalPartWithoutZeroDot()

		def SFValueWithoutZeroDot()
			return This.SFractionalPartWithoutZeroDot()

		def SFractionWithoutZeroDot()
			return This.SFractionalPartWithoutZeroDot()

		#>

	#-----------------------------------------------#
	#  GETTING AND SETTING THE ROUND OF THE NUMBER  #
	#-----------------------------------------------#

	def Round()
		return @nRound

	def SetRound(n)
		if not isNumber(n)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		@nRound = n

	def RoundedTo(n)
		if NOT isNumber(n)
			raise(StkError(:IncorrectParamType))
		ok

		nTempRound = CurrentRound()

		decimals(n)
		return @content


	def SRoundedTo(n)
		if NOT isNumber(n)
			raise(StkError(:IncorrectParamType))
		ok

		nTempRound = CurrentRound()

		decimals(n)
		cResult = ""+ @content
		decimals(nTempRound)

		return cResult

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
		
		cResult = NStringify(@content, @cSpaceChar, @nSpaceStep, @Round(@content))
		return cResult

	#-------------------------------------------#
	#  SETTING AND GETTING SPACE CHAR AND STEP  #
	#-------------------------------------------#

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

	func Abs()
		if @content > 0
			return @content
		else
			return -@content
		ok

	func SAbs()
		if @content > 0
			return This.SValue()
		else
			return "-" + SValue()
		ok	

	#------------------------------------------#
	#  CHECKING EQUALITY WITH AN OTHER NUMBER  #
	#------------------------------------------#

	def IsEqual(n)
		oOtherNumber = new stkNumber(n)
		if This.SNumber() = oOtherNumber.SNumber()
			return TRUE
		else
			return FALSE
		ok

		def Equals(n)
			return IsEqual(n)

		def IsEqualTo(n)
			return IsEqual(n)

	#------------------------#
	#  OVERLOADED OPERATORS  #
	#------------------------#

	def Operator(op, value)

		if op = "="
			return This.Equals(value)

		but op = "+"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				cTempStr = substr(value, "_", "")

				# Getting the numeric value

				nValue = @content + (0+ cTempStr)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				cSpaceChar = @cSpaceChar
				if not @bSpacify
					cSpaceChar = ""
				ok

				nRound1 = @Round(nValue)
				nRound2 = This.Round()

				if nRound1 < nRound2
					nRound = nRound1
				else
					nRound = nRound2
				ok
				
				cResult = NStringify(nValue, @bSpacify, cSpaceChar, nRound)

				# Returning the result

				return cResult

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok


		but op = "-"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				cTempStr = substr(value, "_", "")

				# Getting the numeric value

				nValue = @content - (0+ cTempStr)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				cSpaceChar = @cSpaceChar
				if not @bSpacify
					cSpaceChar = ""
				ok

				nRound1 = @Round(nValue)
				nRound2 = This.Round()

				if nRound1 < nRound2
					nRound = nRound1
				else
					nRound = nRound2
				ok

				cResult = NStringify(nValue, @bSpacify, cSpaceChar, nRound)

				# Returning the result

				return cResult

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok


		but op = "*"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				cTempStr = substr(value, "_", "")

				# Getting the numeric value

				nValue = @content * (0+ cTempStr)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				cSpaceChar = @cSpaceChar
				if not @bSpacify
					cSpaceChar = ""
				ok

				nRound1 = @Round(nValue)
				nRound2 = This.Round()

				if nRound1 < nRound2
					nRound = nRound1
				else
					nRound = nRound2
				ok

				cResult = NStringify(nValue, @bSpacify, cSpaceChar, nRound)

				# Returning the result

				return cResult

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok

		but op = "/"

			if isNumber(value)
				return @content + value

			but isString(value)

				# Removing potential "_"

				cTempStr = substr(value, "_", "")

				# Getting the numeric value

				nValue = @content + (0+ cTempStr)

				if not isNumber(nValue)
					raise("ERR-" + StkError(:IncorrectParamType) + NL)
				ok

				# Using NStringify to get the string value of the number

				cSpaceChar = @cSpaceChar
				if not @bSpacify
					cSpaceChar = ""
				ok

				nRound1 = nValue
				nRound2 = This.Round()

				if nRound1 < nRound2
					nRound = nRound1
				else
					nRound = nRound2
				ok

				cResult = NStringify(nValue, @bSpacify, cSpaceChar, nRound)

				# Returning the result

				return cResult

			else
				raise("ERR-" + StkError(:IncorrectParamType) + NL)
			ok

		else
			raise("ERR-" + StkError(:UnsupportedOperator) + NL)
		ok
