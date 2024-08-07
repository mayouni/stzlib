
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

#~~~~~~~~~~~~~~~~~~~#
#  STZ CORE NUMBER  #
#~~~~~~~~~~~~~~~~~~~#

class stzCoreNumber from stkNumber

class stkNumber
	@content

	@nRound = @CurrentRound()
	@bSpacify = FALSE
	@bShowPositive = FALSE

	@bMinusInDecPart = FALSE

	#----------------------------------------------------------------#
	#  INITIALISING THE NUMBER, FROM A NUMBER OR A NUMBER IN STRING  #
	#----------------------------------------------------------------#

	def init(pNumber)
		if NOT (isNumber(pNumber) or isString(pNumber))
			raise("ERR-" + StkErrror(:IncorrectParamType) )
		ok

		if isNumber(pNumber)
			@content = pNumber

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

		ok

	#--------------------------------------------#
	#  NUMBER VALUE, IN NUMBER AND STRING FORMS  #
	#--------------------------------------------#

	def Copy()
		oCopy = This
		return oCopy

	def Content()
		return @content

		#< @FunctionAlternativeForms

		def NContent()
			@content

		def Value()
			return @content

		def NValue()
			return @content

		#--

		def NumericContent()
			@content

		def NumericValue()
			return @content

		#>

	def String()

		cResult = This.StringIntegerPart() + "." + StringDecimalPartWithoutZeroDot()
		return cResult

		#< @FunctionAlternativeForms

		def SContent()
			return This.String()

		def SValue()
			return This.String()

		#--

		def StringContent()
			return This.String()

		def StringValue()
			return This.String()

		#>

	#-------------------------------------------------------#
	#  GETTING THE INTEGER PART IN NUMBER AND STRING FORMS  #
	#-------------------------------------------------------#

	def IntPart()
		if @content > 0
			return floor(@content)
		else
			return ceil(@content)
		ok

		#< @FunctionAlternativeFoms

		def Int()
			return This.IntPart()

		def IntegerPart()
			return This.IntPart()

		def NIntPart()
			return This.IntPart()

		def NInt()
			return This.IntPart()

		def NIntegerPart()
			return This.IntPart()

		def NumericIntegerPart()
			return This.IntPart()

		#>

	def SIntPart()
		if @content > 0
			n = floor(@content)
		else
			n = ceil(@content)
		ok

		if NOT @bSpacify
			if @bShowPositive and @content > 0
				return "+" + n
			ok
			return ""+ n
		else
			oTemp = new stkNumber(n)
			return oTemp.Spacified()
		ok

		#< @FunctionAlternativeForms

		def SInt()
			return This.SIntPart()

		def SIntegerPart()
			return This.SIntPart()

		def StringIntegerPart()
			return This.SIntPart()

		#>

	#------------------------------------------------------#
	#  GETTING THE STRING PART IN NUMBER AND STRING FORMS  #
	#------------------------------------------------------#

	def WithMinusInDecimalPart()
		@bMinusInDecPart = TRUE

	def NoMinusInDecimalPart()
		@bMinusInDecPart = FALSE

	def DecPart()
		n = @content
		if n < 0
			n = -n
		ok

		nResult = n - floor(n)

		if @bMinusInDecPart
			nResult = -nResult
		ok

		return nResult

		#< @FunctionAlternativeForms

		def Dec()
			return This.DecPart()

		def DecimalPart()
			return This.DecPart()

		def NDecPart()
			return This.DecPart()

		def NDec()
			return This.DecPart()

		def NDecimalPart()
			return This.DecPart()

		def NumericDecimalPart()
			return This.DecPart()

		#>

	def SDecPart()
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
				if @bMinusInDecPart
					cResult = "-0."
				else
					cResult = "0."
				ok
			else
				if @bShowPositive
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

		#< @FunctionAlternativeForms

		def SDec()
			return This.SDecPart()

		def SDecimalPart()
			return This.SDecPart()

		def StringDecimalPart()
			return This.SDecPart()

		#>

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

	def ShowPositive()
		@bShowPositive = TRUE

	def HidePositive()
		@bShowPositive = FALSE

	#----------------------------------------------------#
	#  GETTING THE SDTRING FORM OF THE NUMBER SPACIFIED  #
	#----------------------------------------------------#

	def Spacify()
		@bSpacify = TRUE

	def Unspacify()
		@bSpacify = FALSE

	def UnSpacified()
		return This.StringValue()

	def Spacified()

		cStringValue = This.StringValue()
		bHasDecPart = FALSE
		bHasSign = FALSE
		nDotPos = 0
		nLen = len(cStringValue)

		# Computing the start and end of the integer part

		n1 = 1
		if @content < 0
			bHasSign = TRUE
			n1 = 2
		ok

		n2 = substr(cStringValue, ".")

		if n2 = 0
			n2 = nLen
			nDotPos = n2
		else
			bHasDecPart = TRUE
			nDotPos = n2
			n2--
		ok

		# Spacifying the integer part

		j = 0
		cPart = ""

		for i = n2 to n1 step -1
			cPart += cStringValue[i]

			j++
			if j = 3 and i > n1
				cPart += "_"
				j = 0
			ok
		next

		# Compositing the spacified number in a string

		cResult = ""

		if bHasSign
			cResult += "-"

		but @bShowPositive
			cResult += "+"
		ok

		cResult += reverse(cPart)

		if bHasDecPart
			cResult += "." + This.StringDecimalPartWithoutZeroDot()
		ok

		return cResult

	def StringDecimalPartWithoutZeroDot()

		cDecimalPart = This.StringDecimalPart()
		cDecimalPart = substr(cDecimalPart, "0.", "")
		cDecimalPart = substr(cDecimalPart, "+", "")
		cDecimalPart = substr(cDecimalPart, "-", "")

		return cDecimalPart

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
				return oTempCopy.NumericValue()

			but isString(value)
				return oTempCopy.StringValue()

			else
				raise("ERR-" + StkError(:IncorrectParamType))
			ok

		but op = "-"

			oTempCopy = This.Copy()
			oTempCopy.Substruct(value)

			if isNumber(value)
				return oTempCopy.NumericValue()

			but isString(value)
				return oTempCopy.StringValue()

			else
				raise("ERR-" + StkError(:IncorrectParamType))
			ok

		but op = "*"

			oTempCopy = This.Copy()
			oTempCopy.Multiply(value)

			if isNumber(value)
				return oTempCopy.NumericValue()

			but isString(value)
				return oTempCopy.StringValue()

			else
				raise("ERR-" + StkError(:IncorrectParamType))
			ok

		but op = "/"

			oTempCopy = This.Copy()
			oTempCopy.Divide(value)

			if isNumber(value)
				return oTempCopy.NumericValue()

			but isString(value)
				return oTempCopy.StringValue()

			else
				raise("ERR-" + StkError(:IncorrectParamType))
			ok

		else
			raise( 'ERR-' + StkError(:UnsupportedOperator) )
		ok
